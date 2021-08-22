defmodule Mate.Storage.BuildServer do
  @moduledoc """
  This BuildServer Storage module can be used to store your release archives
  somewhere on the build-server. There could be a variety of reasons to want
  this, for example you could be building and deploying on the same server
  for small hobby projects, have a mounted network share where you want to
  store your release archives or perhaps hand it off to another script/program
  to continue your deployment pipeline, just to name a few example use cases.

  ## How to use

  Configure your `.mate.exs` to use this module:

      config :mate,
        storage: Mate.Storage.BuildServer,
        storage_opts: [
          release_dir: "/path/to/releases/"
        ]
  """
  alias Mate.Helpers
  use Mate.Storage

  @impl true
  def download(session, file) do
    dir = storage_dir(session)
    filename = Path.basename(file)
    remote_path = Path.join(dir, filename) |> Path.expand()

    with {:error, error} <- Helpers.remote_cmd(session, "cp", [remote_path, file]),
         do:
           Helpers.bail(session, "Failed to copy release archive from release directory.", error)

    {:ok, session}
  end

  @impl true
  def upload(session, file) do
    dir = storage_dir(session)
    filename = Path.basename(file)
    remote_path = Path.join(dir, filename) |> Path.expand()

    with {:error, error} <- Helpers.remote_cmd(session, "mkdir", ["-p", dir]),
         do: Helpers.bail(session, "Release directory not found and could not be created.", error)

    with {:error, error} <- Helpers.remote_cmd(session, "cp", [file, remote_path]),
         do: Helpers.bail(session, "Failed to copy release archive to release directory.", error)

    {:ok, session}
  end

  defp storage_dir(%{config: %{storage_opts: config}} = session) do
    unless config[:release_dir],
      do:
        Helpers.bail(
          session,
          "Cannot find `storage_opts.release_dir` in your `.mate.exs` configuration file"
        )

    config[:release_dir]
  end
end
