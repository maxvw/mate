defmodule Mate.Remote do
  defstruct [
    :id,
    :server,
    :build_path,
    :release_path,
    :storage_path,
    :build_server,
    :deploy_server,
    build_secrets: %{}
  ]

  @type t() :: %__MODULE__{
          id: atom(),
          server: String.t(),
          build_path: String.t(),
          release_path: String.t(),
          storage_path: String.t(),
          build_server: String.t(),
          deploy_server: String.t() | list(String.t()),
          build_secrets: map()
        }

  @spec new(atom()) :: Mate.Remote.t()
  @spec new(atom(), map()) :: Mate.Remote.t()
  def new(id, params \\ %{}) do
    struct(__MODULE__, params)
    |> set_id(id)
    |> set_servers()
  end

  @spec set_id(Mate.Remote.t(), atom()) :: Mate.Remote.t()
  defp set_id(remote, id) do
    %{remote | id: id}
  end

  @spec set_servers(Mate.Remote.t()) :: Mate.Remote.t()
  defp set_servers(remote) do
    build_server = Map.get(remote, :build_server) || remote.server
    deploy_server = Map.get(remote, :deploy_server) || remote.server

    if is_nil(build_server), do: Mix.raise("Missing build server configuration")
    if is_nil(deploy_server), do: Mix.raise("Missing build server configuration")

    %{remote | build_server: build_server, deploy_server: deploy_server}
  end
end
