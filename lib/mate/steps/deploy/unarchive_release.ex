defmodule Mate.Step.UnarchiveRelease do
  use Mate.Pipeline.Step

  @impl true
  def run(%{remote: remote} = session) do
    archive_name = Path.basename(session.assigns.release_archive)

    test_writable = """
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p "#{remote.release_path}"
    cd "#{remote.release_path}"
    touch test-write
    rm test-write
    """

    with {:error, _error} <- Mate.remote_script(session, test_writable),
         do: bail("Deploy user not allowed to write to #{remote.release_path}")

    script = """
    #!/usr/bin/env bash
    set -euo pipefail
    cd "#{remote.release_path}"
    tar -xzvf "#{archive_name}"
    rm -rf "#{archive_name}"
    """

    with {:error, error} <- Mate.remote_script(session, script),
         do: bail("Failed to unarchive #{archive_name}.", error)

    {:ok, session}
  end
end
