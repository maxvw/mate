defmodule Mate.Step.UnarchiveRelease do
  use Mate.Pipeline.Step

  @impl true
  def run(%{remote: remote} = session) do
    archive_name = Path.basename(session.assigns.release_archive)

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
