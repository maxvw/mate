defmodule Mate.Driver do
  alias Mate.Session

  defmacro __using__(_) do
    quote do
      @behaviour Mate.Driver

      defp set_conn(session, conn) do
        %{session | conn: conn}
      end

      defp assign(%{assigns: assigns} = session, key, value) when is_atom(key) do
        %{session | assigns: Keyword.put(assigns, key, value)}
      end
    end
  end

  @doc """
  Starts the driver, for example create an SSH connection, start a docker container,
  or whatever else might be needed for your new session.
  """
  @callback start(session :: Session.t(), host :: String.t()) ::
              {:ok, Session.t()} | {:error, any()}

  @doc """
  Executes a command using the driver
  """
  @callback exec(session :: Session.t(), command :: String.t(), args :: list(String.t())) ::
              {:ok, Session.t()} | {:error, any()}

  @doc """
  Copy a file from remote to local
  """
  @callback copy_from(session :: Session.t(), src :: String.t(), dest :: String.t()) ::
              {:ok, Session.t()} | {:error, any()}

  @doc """
  Copy a file from local to remote
  """
  @callback copy_to(session :: Session.t(), src :: String.t(), dest :: String.t()) ::
              {:ok, Session.t()} | {:error, any()}

  @doc """
  This one is optional and can be used to close the current connection, cleanup
  or whatever else might be needed.
  """
  @callback close(session :: Session.t()) :: {:ok, Session.t()}

  @optional_callbacks close: 1
end
