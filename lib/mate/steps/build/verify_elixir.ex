defmodule Mate.Step.VerifyElixir do
  use Mate.Pipeline.Step

  @impl true
  def run(session) do
    with {:error, error} <- Mate.remote_cmd(session, "which", ["elixir"]),
         do: bail("Elixir not found in PATH on remote server.", error)

    with {:error, error} <- Mate.remote_cmd(session, "which", ["mix"]),
         do: bail("Mix not found in PATH on remote server.", error)

    {:ok, session}
  end
end
