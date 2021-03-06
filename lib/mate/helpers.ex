defmodule Mate.Helpers do
  @moduledoc """
  This module contains helper functions that can be used to execute commands
  on the local machine, or the remote machine using the configured driver ƒrom
  `.mate.exs`. It also have functions to copy files from or to the remote server.

  These helpers are automatically imported in a custom `Mate.Pipeline.Step`.

  For example:

        defmodule CustomHelloUser do
          use Mate.Pipeline.Step

          @impl true
          def run(session) do
            {:ok, user} = remote_cmd(session, "whoami")
            IO.puts "Hello " <> user
            {:ok, session}
          end
        end
  """
  alias Mate.Session

  @doc "Execute a command (with arguments) on the local machine"
  @spec local_cmd(session :: Session.t(), command :: String.t()) ::
          {:ok, String.t()} | {:error, String.t()}
  @spec local_cmd(session :: Session.t(), command :: String.t(), args :: list(String.t())) ::
          {:ok, String.t()} | {:error, String.t()}
  def local_cmd(%Session{} = session, cmd, args \\ []) when is_list(args) do
    if session.verbosity > 0,
      do:
        Mix.shell().info([
          :yellow,
          :bright,
          "local >",
          :reset,
          " ",
          cmd,
          " ",
          Enum.join(args, " ")
        ])

    case System.cmd(cmd, args, stderr_to_stdout: true) do
      {stdout, _exit_status = 0} ->
        {:ok, String.trim(stdout)}

      {stdout, exit_status} ->
        {:error,
         "Local command exited with non-ok exit status (#{exit_status})\n\nCommand: #{cmd} #{Enum.join(args, " ")}\nOutput:\n#{stdout}"}
    end
    |> print_result("local", session.verbosity)
  end

  @doc "Execute a script on the local machine"
  @spec local_script(session :: Session.t(), script :: String.t()) ::
          {:ok, String.t()} | {:error, String.t()}
  def local_script(%Session{} = session, script) do
    if session.verbosity > 0,
      do: Mix.shell().info([:yellow, "local >", :reset, " ", script])

    case System.cmd("bash", ["-c", script], stderr_to_stdout: true) do
      {stdout, _exit_status = 0} ->
        {:ok, String.trim(stdout)}

      {stdout, exit_status} ->
        {:error,
         "Local script exited with non-ok exit status (#{exit_status})\n\nScript:\n #{script}\n\nOutput:\n#{stdout}"}
    end
    |> print_result("local", session.verbosity)
  end

  @doc "Execute a command (with arguments) on the remote machine"
  @spec remote_cmd(session :: Session.t(), cmd :: String.t()) ::
          {:ok, String.t()} | {:error, String.t()}
  @spec remote_cmd(session :: Session.t(), cmd :: String.t(), args :: list(String.t())) ::
          {:ok, String.t()} | {:error, String.t()}
  def remote_cmd(%Session{driver: driver} = session, cmd, args \\ []) when is_list(args) do
    if session.verbosity > 0,
      do: Mix.shell().info([:yellow, "remote >", :reset, " ", cmd, " ", Enum.join(args, " ")])

    driver.exec(session, cmd, args)
    |> print_result("remote", session.verbosity)
  end

  @doc "Execute a script on the remote machine"
  @spec remote_script(session :: Session.t(), script :: String.t()) ::
          {:ok, String.t()} | {:error, String.t()}
  def remote_script(%Session{driver: driver} = session, script) do
    if session.verbosity > 0,
      do: Mix.shell().info([:yellow, "remote > ", :reset, " ", script])

    driver.exec_script(session, script)
    |> print_result("remote", session.verbosity)
  end

  @doc "Copy a file from the remote server to the local machine"
  @spec copy_from(session :: Session.t(), src :: String.t(), dest :: String.t()) ::
          {:ok, String.t()} | {:error, String.t()}
  def copy_from(%Session{driver: driver} = session, src, dest) do
    if session.verbosity > 0,
      do:
        Mix.shell().info([
          :cyan,
          "remote -> local",
          :reset,
          " ",
          "copying",
          :bright,
          src,
          :reset,
          " to ",
          :bright,
          dest
        ])

    driver.copy_from(session, src, dest)
  end

  @doc "Copy a file from your local machine to the remote server"
  @spec copy_to(session :: Session.t(), src :: String.t(), dest :: String.t()) ::
          {:ok, String.t()} | {:error, String.t()}
  def copy_to(%Session{driver: driver} = session, src, dest) do
    if session.verbosity > 0,
      do:
        Mix.shell().info([
          :cyan,
          "local -> remote",
          :reset,
          " ",
          "copying",
          :bright,
          src,
          :reset,
          " to ",
          :bright,
          dest
        ])

    driver.copy_to(session, src, dest)
  end

  @doc "Safely terminate connections and raises error"
  @spec bail(session :: Mate.Session.t(), message :: String.t()) :: no_return
  @spec bail(session :: Mate.Session.t(), message :: String.t(), error :: String.t()) :: no_return
  def bail(%{driver: driver} = session, message, error \\ "") do
    if function_exported?(driver, :close, 1) do
      driver.close(session)
    end

    if function_exported?(session.storage, :close, 1) do
      session.storage.close(session)
    end

    if error != "",
      do: Mix.raise("#{message}\r\n\r\n#{error}"),
      else: Mix.raise(message)
  end

  @spec print_result({:ok, String.t()} | {:error, String.t()}, String.t(), integer()) ::
          {:ok, String.t()} | {:error, String.t()}
  defp print_result({:ok, stdout} = result, tag, verbosity) when verbosity > 1 do
    Mix.shell().info([:green, :bright, "#{tag} <", :reset, " ", stdout])
    result
  end

  defp print_result(result, _tag, _verbosity), do: result
end
