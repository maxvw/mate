defmodule Mate.Step.StartRelease do
  @moduledoc "Starts or restarts the new release on the remote release servers."
  use Mate.Pipeline.Step

  @impl true
  def run(%{remote: remote, config: %{otp_app: otp_app}} = session) do
    script = """
    #!/usr/bin/env bash
    set -euo pipefail
    cd "#{remote.release_path}"

    # ensure app is not running
    if bin/#{otp_app} pid >/dev/null 2>&1; then
      echo "Application already running? Did you use StopRelease first?"
      exit 1
    fi

    # attempt to start
    bin/#{otp_app} daemon
    for i in {1..20}; do
      bin/#{otp_app} pid >/dev/null 2>&1 && break || :
      sleep 1
    done

    # ensure app is running
    if ! bin/#{otp_app} pid >/dev/null 2>&1; then
      echo "Failed to start application"
      exit 1
    fi

    echo "Application started"
    """

    with {:error, error} <- remote_script(session, script),
         do: bail(session, "Failed to start #{otp_app}.", error)

    {:ok, session}
  end
end
