defmodule Mate.Step.VerifyNode do
  @moduledoc "This will verify node is available in PATH on the build server."
  use Mate.Pipeline.Step

  @impl true
  def run(session) do
    with {:error, error} <- remote_cmd(session, "which", ["node"]),
         do: bail(session, "Node not found in PATH on remote server.", error)

    with {:error, error} <- remote_cmd(session, "which", ["npm"]),
         do: bail(session, "NPM not found in PATH on remote server.", error)

    {:ok, session}
  end
end
