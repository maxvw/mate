defmodule Mate.Step.CopyToStorage do
  @moduledoc "This copies the release tarball to storage."
  use Mate.Pipeline.Step

  @impl true
  def run(%{config: %{storage: storage}} = session) do
    remote_path = session.assigns.release_archive
    archive_name = Path.basename(remote_path)

    with {:error, error} <- storage.download(session, remote_path),
         do: bail(session, "Failed to copy #{archive_name} to local storage.", error)

    {:ok, session}
  end
end
