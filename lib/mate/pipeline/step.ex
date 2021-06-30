defmodule Mate.Pipeline.Step do
  @moduledoc """
  This behaviour is used for every step in the pipeline
  """
  defmacro __using__(_) do
    quote do
      @behaviour Mate.Pipeline.Step
      import Mate.Helpers
      alias Mate.Utils
      use Mate.Session
    end
  end

  @doc """
  Run this step within the given session
  """
  @callback run(session :: Mate.Session.t()) ::
              {:ok, Mate.Session.t()} | no_return
end
