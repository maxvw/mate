defmodule Mate.Remote do
  @moduledoc """
  This module stores all information about a remote.

  A remote in `mate` is your server environment, e.g. staging or production.
  """
  alias Mate.Utils

  defstruct [
    :id,
    :server,
    :build_path,
    :release_path,
    :build_server,
    :deploy_server,
    build_secrets: %{}
  ]

  @type t() :: %Mate.Remote{
          id: atom(),
          server: String.t(),
          build_path: String.t(),
          release_path: String.t(),
          build_server: String.t(),
          deploy_server: String.t() | list(String.t()),
          build_secrets: map()
        }

  @doc "Creates a new `Mate.Remote` stuct with the given id and parameters."
  @spec new(id :: atom(), params :: map()) :: Mate.Remote.t()
  def new(id, params) do
    struct(Mate.Remote, params)
    |> set_id(id)
    |> set_servers()
    |> validate()
  end

  @spec set_id(remote :: Mate.Remote.t(), id :: atom()) :: Mate.Remote.t()
  defp set_id(remote, id) do
    %{remote | id: id}
  end

  @spec set_servers(remote :: Mate.Remote.t()) :: Mate.Remote.t()
  defp set_servers(remote) do
    build_server =
      [Map.get(remote, :build_server) || remote.server]
      |> List.flatten()
      |> List.first()

    deploy_server =
      [Map.get(remote, :deploy_server) || remote.server || []]
      |> List.flatten()

    %{remote | build_server: build_server, deploy_server: deploy_server}
  end

  @spec validate(remote :: Mate.Remote.t()) :: Mate.Remote.t()
  defp validate(remote) do
    if Utils.empty?(remote.build_server), do: Mix.raise("Missing build_server configuration")
    if Utils.empty?(remote.deploy_server), do: Mix.raise("Missing deploy_server configuration")

    if Utils.empty?(remote.build_path), do: Mix.raise("Missing build_path in configuration")
    if Utils.empty?(remote.release_path), do: Mix.raise("Missing release_path in configuration")

    remote
  end
end
