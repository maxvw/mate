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

      @spec bail(String.t()) :: no_return
      @spec bail(String.t(), String.t()) :: no_return
      defp bail(message, error \\ "") do
        if error != "",
          do: Mix.raise("#{message}\r\n\r\n#{error}"),
          else: Mix.raise(message)
      end
    end
  end

  @doc """
  Run this step within the given session
  """
  @callback run(session :: Mate.Session.t()) ::
              {:ok, Mate.Session.t()} | no_return
end
