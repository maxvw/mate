defmodule Mate.Storage do
  @moduledoc """
  This is the behaviour for Mate Storage engines

  The idea behind supporting multiple storage engines is allowing the user to
  decide how and where they want to upload their completed builds. By default
  it will upload and download using SCP but for example you might be interested
  in using S3 or any other source.
  """
  alias Mate.Session

  defmacro __using__(_) do
    quote do
      @behaviour Mate.Storage

      @spec assign(session :: Session.t(), key :: atom(), value :: any()) :: Session.t()
      defp assign(%{assigns: assigns} = session, key, value) when is_atom(key) do
        %{session | assigns: Keyword.put(assigns, key, value)}
      end
    end
  end

  @doc """
  Connect to your storage host.
  """
  @callback connect(session :: Session.t()) :: {:ok, Session.t()} | {:error, String.t()}

  @doc """
  Close the connection to your storage host.
  """
  @callback close(session :: Session.t()) :: {:ok, Session.t()} | {:error, String.t()}

  @doc """
  Upload the given file from your local machine to the storage host.
  """
  @callback upload(session :: Session.t(), file :: String.t()) ::
              {:ok, Session.t()} | {:error, String.t()}

  @doc """
  Download the given file from the storage host to your local machine.
  """
  @callback download(session :: Session.t(), file :: String.t()) ::
              {:ok, Session.t()} | {:error, String.t()}

  @optional_callbacks connect: 1,
                      close: 1
end
