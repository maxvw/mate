defmodule Mate.Driver do
  @moduledoc """
  This is the behaviour for Mate Drivers.

  The idea behind supporting multiple drivers is allowing the user to decide
  how and where they want to build their application. By default it will use
  the SSH driver, but you can also use Docker or Local. It is also possible
  to write your own. For an example I recommend looking at `Mate.Driver.SSH`.

  **NOTE:** Deployments (after build) currently always use the `Mate.Driver.SSH`.
  """
  alias Mate.Session

  defmacro __using__(_) do
    quote do
      @behaviour Mate.Driver

      @spec set_conn(session :: Session.t(), conn :: any()) :: Session.t()
      defp set_conn(session, conn) do
        %{session | conn: conn}
      end

      @spec assign(session :: Session.t(), key :: atom(), value :: any()) :: Session.t()
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
              {:ok, Session.t()} | {:error, String.t()}

  @doc """
  Executes a command using the driver
  """
  @callback exec(session :: Session.t(), command :: String.t(), args :: list(String.t())) ::
              {:ok, String.t()} | {:error, String.t()}

  @doc """
  Executes a script using the driver
  """
  @callback exec_script(session :: Session.t(), script :: String.t()) ::
              {:ok, String.t()} | {:error, String.t()}

  @doc """
  Prepare the source for building, for example send it to the build server.
  """
  @callback prepare_source(session :: Session.t()) :: {:ok, Session.t()} | {:error, String.t()}

  @doc """
  Copy a file from remote to local
  """
  @callback copy_from(session :: Session.t(), src :: String.t(), dest :: String.t()) ::
              {:ok, String.t()} | {:error, String.t()}

  @doc """
  Copy a file from local to remote
  """
  @callback copy_to(session :: Session.t(), src :: String.t(), dest :: String.t()) ::
              {:ok, String.t()} | {:error, String.t()}

  @doc """
  This one is optional and can be used to close the current connection, cleanup
  or whatever else might be needed.
  """
  @callback close(session :: Session.t()) :: {:ok, Session.t()}

  @doc """
  Returns a description of the current host (defaults to context hostname)
  """
  @callback current_host(session :: Session.t()) :: String.t()

  @optional_callbacks close: 1,
                      prepare_source: 1,
                      current_host: 1
end
