defmodule Mate.Step.CopyToStorage do
  @moduledoc "This copies the release tarball to storage."
  use Mate.Pipeline.Step
  alias Mate.Storage

  @impl true
  def run(session) do
    remote_path = session.assigns.release_archive
    archive_name = Path.basename(remote_path)

    with {:error, error} <- Storage.upload(session, remote_path),
         do: bail(session, "Failed to copy #{archive_name} to local storage.", error)

    {:ok, session}
  end
end
