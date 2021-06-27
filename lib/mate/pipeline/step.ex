defmodule Mate.Pipeline.Step do
  defmacro __using__(_) do
    quote do
      @behaviour Mate.Pipeline.Step
      alias Mate.Utils
      use Mate.Session

      defp bail(message, error \\ nil) do
        if error,
          do: Mix.raise("#{message}\r\n\r\n#{error}"),
          else: Mix.raise(message)
      end
    end
  end

  @doc """
  Run this step within the given session
  """
  @callback run(session :: Session.t()) :: {:ok, Session.t()} | {:error, term()}
end
