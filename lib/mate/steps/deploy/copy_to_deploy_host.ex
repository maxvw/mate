defmodule Mate.Step.CopyToDeployHost do
  @moduledoc "Copies the release tarball from storage to remote deploy servers."
  use Mate.Pipeline.Step
  alias Mate.Storage

  @impl true
  def run(%{remote: remote} = session) do
    remote_path = session.assigns.release_archive
    archive_name = Path.basename(remote_path)
    remote_path = Path.join(remote.release_path, archive_name)

    test_writable = """
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p "#{remote.release_path}"
    cd "#{remote.release_path}"
    touch test-write
    rm test-write
    """

    with {:error, _error} <- remote_script(session, test_writable),
         do: bail(session, "Deploy user not allowed to write to #{remote.release_path}")

    with {:error, error} <- Storage.download(session, remote_path),
         do: bail(session, "Failed to copy #{archive_name} to deploy host.", error)

    {:ok, session}
  end
end
