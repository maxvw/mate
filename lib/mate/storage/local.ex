defmodule Mate.Storage.Local do
  @moduledoc """
  This storage driver will store your release archives to your local machine,
  and upload them to the deploy servers from your local machine as well.

  To use this module you can specify it in your `.mate.exs` module, however
  currently `Mate.Storage.Local` is the default so it is optional.

  In your `.mate.exs` you can specify it as such:

      config :mate,
        storage: Mate.Storage.Local,
        storage_opts: [],
  """
  alias Mate.Helpers
  use Mate.Storage

  @impl true
  def download(session, file) do
    Helpers.copy_to(session, to_local(file), file)
  end

  @impl true
  def upload(session, file) do
    Helpers.copy_from(session, file, to_local(file))
  end

  defp to_local(file) do
    file
    |> Path.basename()
    |> Path.expand()
  end
end
