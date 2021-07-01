defmodule Mate.Step.LinkBuildSecrets do
  @moduledoc """
  This will create symlinks for secret configuration files like `prod.secret.exs`
  so the build process can include them in the build.

  ## Configuration
  If you want to use this functionality, in your `.mate.exs` file you can specify
  this for every remote. For example like this:

      config :staging,
        server: "build-server",
        build_path: "/tmp/mate/project",
        release_path: "/home/elixir/releases/project",
        build_secrets: %{
          "prod.secret.exs" => "/mnt/secrets/prod.secret.exs"
        }
  """
  use Mate.Pipeline.Step

  @impl true
  def run(%{remote: remote} = session) do
    for {config_name, secret_file} <- remote.build_secrets do
      script = """
      #!/usr/bin/env bash
      ln -sfn #{secret_file} #{remote.build_path}/config/#{config_name}
      """

      with {:error, error} <- remote_script(session, script),
           do: bail(session, "Failed to link #{config_name} to #{secret_file}.", error)
    end

    {:ok, session}
  end
end
