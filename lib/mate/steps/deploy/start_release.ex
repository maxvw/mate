defmodule Mate.Step.StartRelease do
  @moduledoc "Starts or restarts the new release on the remote release servers."
  use Mate.Pipeline.Step

  @impl true
  def run(%{remote: remote, config: %{otp_app: otp_app}} = session) do
    script = """
    #!/usr/bin/env bash
    set -euo pipefail
    cd "#{remote.release_path}"
    current_pid=$(bin/#{otp_app} pid || echo "0")
    if [[ $current_pid == "0" ]]; then
      bin/#{otp_app} daemon
    else
      bin/#{otp_app} restart
    fi;
    """

    with {:error, error} <- Mate.remote_script(session, script),
         do: bail("Failed to start #{otp_app}.", error)

    {:ok, session}
  end
end
