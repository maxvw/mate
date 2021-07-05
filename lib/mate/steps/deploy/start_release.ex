defmodule Mate.Step.StartRelease do
  @moduledoc "Starts or restarts the new release on the remote release servers."
  use Mate.Pipeline.Step

  @impl true
  def run(%{remote: remote, config: %{otp_app: otp_app}} = session) do
    script = """
    #!/usr/bin/env bash
    set -euo pipefail
    cd "#{remote.release_path}"

    # attempt to stop
    bin/#{otp_app} stop || true
    for i in {1..20}; do
      bin/#{otp_app} pid >/dev/null 2>&1 || break || :
      sleep 1
    done

    # attempt to start
    bin/#{otp_app} daemon
    for i in {1..20}; do
      bin/#{otp_app} pid >/dev/null 2>&1 && break || :
      sleep 1
    done
    """

    with {:error, error} <- remote_script(session, script),
         do: bail(session, "Failed to start #{otp_app}.", error)

    {:ok, session}
  end
end
