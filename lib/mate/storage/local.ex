defmodule Mate.Storage.Local do
  alias Mate.Helpers
  use Mate.Storage

  @impl true
  def upload(session, file) do
    Helpers.copy_to(session, file, to_local(file))
  end

  @impl true
  def download(session, file) do
    Helpers.copy_from(session, to_local(file), file)
  end

  defp to_local(file) do
    file
    |> Path.basename()
    |> Path.expand()
  end
end
