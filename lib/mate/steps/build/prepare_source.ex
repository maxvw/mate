defmodule Mate.Step.PrepareSource do
  @moduledoc """
  This will prepare the source code for building, for example when using the
  `Mate.Driver.SSH` driver it will push the latest commit to the build server.
  """
  use Mate.Pipeline.Step

  @impl true
  def run(%{driver: driver} = session) do
    with true <- function_exported?(driver, :prepare_source, 1),
         {:error, error} <- driver.prepare_source(session),
         do: bail(session, "Failed to push commit to build_server.", error)

    {:ok, session}
  end
end
