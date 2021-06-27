defmodule Mate.Remote do
  defstruct [
    :id,
    :server,
    :build_path,
    :release_path,
    :storage_path,
    :build_server,
    :deploy_server,
    build_secrets: []
  ]

  def new(id, params \\ %{}) do
    struct(__MODULE__, params)
    |> set_id(id)
    |> set_servers()
  end

  defp set_id(remote, id) do
    %{remote | id: id}
  end

  defp set_servers(remote) do
    build_server = Map.get(remote, :build_server) || remote.server
    deploy_server = Map.get(remote, :deploy_server) || remote.server

    if is_nil(build_server), do: Mix.raise("Missing build server configuration")
    if is_nil(deploy_server), do: Mix.raise("Missing build server configuration")

    %{remote | build_server: build_server, deploy_server: deploy_server}
  end
end
