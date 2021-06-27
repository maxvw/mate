defmodule Mate.Step.LinkBuildSecrets do
  use Mate.Pipeline.Step

  @impl true
  def run(%{remote: remote} = session) do
    for {config_name, secret_file} <- remote.build_secrets do
      script = """
      #!/usr/bin/env bash
      ln -sfn #{secret_file} #{remote.build_path}/config/#{config_name}
      """

      with {:error, error} <- Mate.remote_script(session, script),
           do: bail("Failed to link #{config_name} to #{secret_file}.", error)
    end

    {:ok, session}
  end
end
