defmodule Mate.Step.VerifyElixir do
  @moduledoc "This will verify Elixir is available in PATH on the build server."
  use Mate.Pipeline.Step

  @impl true
  def run(session) do
    with {:error, error} <- remote_cmd(session, "which", ["elixir"]),
         do: bail(session, "Elixir not found in PATH on remote server.", error)

    with {:error, error} <- remote_cmd(session, "which", ["mix"]),
         do: bail(session, "Mix not found in PATH on remote server.", error)

    {:ok, session}
  end
end
