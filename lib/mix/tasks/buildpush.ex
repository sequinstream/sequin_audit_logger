defmodule Mix.Tasks.Buildpush do
  @shortdoc "Builds and pushes the Docker image"
  @moduledoc false
  # credo:disable-for-this-file
  use Mix.Task

  @green "\e[32m"
  @red "\e[31m"
  @blue "\e[34m"
  @reset "\e[0m"
  @yellow "\e[33m"

  def run(args) do
    start_time = System.monotonic_time(:second)

    Mix.Task.run("app.config")

    config = load_config()

    owner = trimmed_cmd("gh", ~w(repo view --json owner --jq .owner.login))
    repo = trimmed_cmd("gh", ~w(repo view --json name --jq .name))
    sha = trimmed_cmd("git", ~w(rev-parse HEAD))
    branch = trimmed_cmd("git", ~w(rev-parse --abbrev-ref HEAD))

    with :ok <- verify_clean_workdir(args),
         :ok <- verify_branch(branch) do
      build_and_push(start_time, owner, repo, sha, config)
    else
      {:error, message} ->
        exit_with_duration(start_time, message)
    end
  end

  defp load_config do
    case Application.fetch_env!(:sequin_audit_logger, :buildpush) do
      nil ->
        IO.puts(:stderr, """
        #{@red}Error: Configuration for :buildpush not found.
        Please ensure you have the following in your config/dev.secret.exs:

        config :ix,
          buildpush: [
            aws_region: "us-east-1",
            aws_access_key_id: "secret",
            aws_secret_access_key: "secret",
            dockerhub_username: "sequin",
            dockerhub_token: "secret",
            ecr_url: "{accnt-id}.dkr.ecr.us-east-1.amazonaws.com",
            image_name: "sequin_audit_logger",
            slack_bots_webhook_url: "someurl",
            buddy_webhook_token_main: "secret"
          ]
        #{@reset}
        """)

        exit(:shutdown)

      config ->
        config
    end
  end

  defp verify_branch(branch) do
    if branch == "main" do
      IO.puts("#{@green}On main branch. Proceeding...#{@reset}")
      :ok
    else
      {:error, "Not on main branch. Current branch: #{branch}"}
    end
  end

  defp build_and_push(start_time, _owner, _repo, sha, config) do
    IO.puts("#{@blue}Building and pushing Docker image...#{@reset}")

    env = [
      {"AWS_REGION", config[:aws_region]},
      {"AWS_ACCESS_KEY_ID", config[:aws_access_key_id]},
      {"AWS_SECRET_ACCESS_KEY", config[:aws_secret_access_key]},
      {"DOCKERHUB_USERNAME", config[:dockerhub_username]},
      {"DOCKERHUB_TOKEN", config[:dockerhub_token]}
    ]

    build_args = [
      "MIGRATOR=SequinAuditLogger.Release",
      "RELEASE_NAME=sequin_audit_logger"
    ]

    # Login to Docker Hub
    res =
      System.cmd(
        "sh",
        [
          "-c",
          "echo #{config[:dockerhub_token]} | docker login -u #{config[:dockerhub_username]} --password-stdin"
        ],
        env: env
      )

    case res do
      {_, 0} ->
        IO.puts("#{@green}Successfully logged in to Docker Hub#{@reset}")

      {_output, _} ->
        exit_with_duration(start_time, "Error logging in to Docker Hub")
    end

    # Login to Amazon ECR
    res =
      :os.cmd(
        ~c"aws ecr get-login-password --region #{config[:aws_region]} | docker login --username AWS --password-stdin #{config[:ecr_url]}"
      )

    if String.contains?(to_string(res), "Login Succeeded") do
      IO.puts("#{@green}Successfully logged in to Amazon ECR#{@reset}")
    else
      exit_with_duration(start_time, "Error logging in to Amazon ECR: #{res}")
    end

    cmd =
      [
        "buildx",
        "build",
        "--push",
        "--tag",
        "#{config[:ecr_url]}/#{config[:image_name]}:#{sha}",
        "--tag",
        "#{config[:ecr_url]}/#{config[:image_name]}:latest",
        "--cache-from",
        "type=registry,ref=#{config[:ecr_url]}/#{config[:image_name]}:cache",
        "--cache-to",
        "type=registry,image-manifest=true,oci-mediatypes=true,ref=#{config[:ecr_url]}/#{config[:image_name]}:cache,mode=max",
        "--provenance=false"
      ] ++ Enum.flat_map(build_args, fn arg -> ["--build-arg", arg] end) ++ ["."]

    res =
      System.cmd("docker", cmd, env: env, into: IO.stream(:stdio, :line), stderr_to_stdout: true)

    # Build and push the Docker image
    case res do
      {_, 0} ->
        IO.puts("#{@green}Successfully built and pushed Docker image#{@reset}")

      {_output, _} ->
        exit_with_duration(start_time, "Error building and pushing Docker image")
    end

    IO.puts("#{@green}Build and push completed successfully#{@reset}")
  end

  defp trimmed_cmd(cmd, args) do
    case System.cmd(cmd, args) do
      {output, 0} ->
        String.trim(output)

      {_, _} ->
        IO.puts(:stderr, "Error executing command '#{cmd} #{Enum.join(args, " ")}'")
        exit(:shutdown)
    end
  end

  defp format_duration(seconds) do
    minutes = div(seconds, 60)
    remaining_seconds = rem(seconds, 60)
    "#{minutes}m#{remaining_seconds}s"
  end

  defp exit_with_duration(start_time, error) do
    end_time = System.monotonic_time(:second)
    duration = format_duration(end_time - start_time)
    IO.puts(:stderr, "#{@red}#{error}")
    IO.puts(:stderr, "#{@red}Exited after #{duration}#{@reset}")
    exit(:shutdown)
  end

  defp verify_clean_workdir(args) do
    if "--dirty" in args do
      IO.puts("#{@yellow}Warning: Running buildpush on a dirty repository.#{@reset}")
      IO.puts("#{@yellow}Current git status:#{@reset}")
      System.cmd("git", ["status", "--short"], into: IO.stream(:stdio, :line))
      IO.puts("")
      :ok
    else
      case System.cmd("git", ["status", "--porcelain"]) do
        {"", 0} ->
          :ok

        {_, 0} ->
          {:error, "Repository is dirty. Use 'mix buildpush --dirty' to override."}

        _ ->
          {:error, "Failed to check repository status"}
      end
    end
  end
end
