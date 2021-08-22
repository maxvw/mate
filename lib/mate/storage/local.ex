defmodule Mate.Storage.Local do
  @moduledoc """
  This storage driver will store your release archives to your local machine,
  and upload them to the deploy servers from your local machine as well.

  To use this module you can specify it in your `.mate.exs` module, however
  currently `Mate.Storage.Local` is the default so it is optional.

  In your `.mate.exs` you can specify it as such:

      config :mate,
        storage: Mate.Storage.Local

  By default this will copy the release archive to the project root, from
  where you are running the `mate` commands. However, you can optionally
  configure the local storage driver to store them in another directory.

      config :mate,
        storage_opts: [
          release_dir: "/path/to/dir"
        ]

  **NOTE** This can also be relative, from the current working directory.
  """
  alias Mate.Helpers
  use Mate.Storage

  @impl true
  def download(session, file) do
    Helpers.copy_to(session, to_local(session, file), file)
  end

  @impl true
  def upload(session, file) do
    Helpers.copy_from(session, file, to_local(session, file))
  end

  defp to_local(%{config: %{storage_opts: config}}, file) do
    filename = Path.basename(file)

    if config[:release_dir] do
      release_path = Path.join(config[:release_dir], filename) |> Path.expand()
      release_dir = Path.dirname(release_path)

      if File.exists?(release_dir) and not File.dir?(release_dir),
        do: Mix.raise("Configured release dir (#{config[:release_dir]}) appears to be a file")

      if not File.exists?(release_dir),
        do: File.mkdir_p!(release_dir)

      release_path
    else
      Path.expand(filename)
    end
  end
end
