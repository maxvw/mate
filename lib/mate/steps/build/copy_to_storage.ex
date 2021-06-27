defmodule Mate.Step.CopyToStorage do
  use Mate.Pipeline.Step

  @impl true
  def run(session) do
    remote_path = session.assigns.release_archive
    archive_name = Path.basename(remote_path)
    local_path = Path.absname(archive_name)

    with {:error, error} <- Mate.copy_from(session, remote_path, local_path),
         do: bail("Failed to copy #{archive_name} to local storage.", error)

    {:ok, session}
  end
end
