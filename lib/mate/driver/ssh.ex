defmodule Mate.Driver.SSH do
  @moduledoc """
  The SSH driver is used to execute commands via SSH.

  It will maintain a connection using `ControlMaster` and send commands and/or
  files over that connection, instead of reconnecting for every given command.
  """
  alias Mate.Utils
  use Mate.Session
  use Mate.Driver
  use GenServer

  @impl true
  def start(session, host) do
    with {:ok, conn} <-
           GenServer.start_link(__MODULE__, %{
             conn: nil,
             host: host,
             args: [],
             socket_file: nil,
             session: session
           }) do
      {:ok, session |> set_conn(conn)}
    else
      {:error, _} = error -> error
    end
  end

  @impl true
  def close(%Session{conn: conn} = session) do
    GenServer.stop(conn, :normal, 5_000)
    {:ok, session}
  end

  @impl true
  def exec(%Session{conn: conn}, command, args) do
    GenServer.call(conn, {:ssh, command, args}, :infinity)
  end

  @impl true
  def exec_script(session, script) do
    exec(session, script, [])
  end

  @impl true
  def copy_from(%Session{conn: conn, remote: remote}, remote_src, local_dest) do
    remote_abs = remote.build_server <> ":" <> remote_src
    GenServer.call(conn, {:scp, remote_abs, local_dest}, :infinity)
  end

  @impl true
  def copy_to(%Session{conn: conn, remote: remote}, local_src, remote_dest) do
    remote_abs = remote.deploy_server <> ":" <> remote_dest
    GenServer.call(conn, {:scp, local_src, remote_abs}, :infinity)
  end

  @impl true
  def prepare_source(session) do
    with {:ok, session} <- Mate.Step.VerifyGit.run(session),
         {:ok, session} <- Mate.Step.SendGitCommit.run(session) do
      {:ok, session}
    else
      error -> error
    end
  end

  @impl true
  def init(state) do
    socket_file = "/tmp/.mate-ssh-" <> Utils.random_id(6) <> ".sock"
    args = ["-oControlMaster=yes", "-oControlPath=#{socket_file}", "-T" | state.args]
    command = [state.host | args]

    opts = [:stream, :binary, :exit_status, :hide, :use_stdio, args: command]
    conn = Port.open({:spawn_executable, "/usr/bin/ssh"}, opts)

    # Awaiting connection to become available
    result =
      Enum.reduce_while(1..10, {:error, :no_connection}, fn _i, acc ->
        System.cmd("ssh", ["-oControlPath=#{socket_file}", "-O", "check", state.host],
          stderr_to_stdout: true
        )
        |> case do
          {_, 0} ->
            {:halt, {:ok, nil}}

          _ ->
            :timer.sleep(1000)
            {:cont, acc}
        end
      end)

    case result do
      {:error, reason} ->
        {:stop, reason}

      {:ok, _} ->
        {:ok,
         %{
           state
           | socket_file: socket_file,
             conn: conn
         }}
    end
  end

  @impl true
  def handle_call({:ssh, command, user_args}, _, state) do
    args = [
      "-oControlMaster=no",
      "-oControlPath=#{state.socket_file}",
      state.host,
      "-T",
      command | user_args
    ]

    case System.cmd("ssh", args, stderr_to_stdout: true) do
      {stdout, _exit_status = 0} ->
        {:reply, {:ok, String.trim(stdout)}, state}

      {stdout, exit_status} ->
        {:reply,
         {:error,
          "Remote command exited with non-ok exit status (#{exit_status})\n\nCommand: #{command} #{Enum.join(user_args, " ")}\nOutput:\n#{stdout}"},
         state}
    end
  end

  def handle_call({:scp, src, dest}, _, state) do
    args = [
      "-oControlMaster=no",
      "-oControlPath=#{state.socket_file}",
      src,
      dest
    ]

    case System.cmd("scp", args, stderr_to_stdout: true) do
      {stdout, _exit_status = 0} ->
        {:reply, {:ok, String.trim(stdout)}, state}

      {stdout, exit_status} ->
        {:reply,
         {:error,
          "Remote command exited with non-ok exit status (#{exit_status})\n\nCommand: scp #{Enum.join(args, " ")}\nOutput:\n#{stdout}"},
         state}
    end
  end

  @impl true
  def handle_info({conn, {:data, _data}}, %{conn: conn} = state) do
    # TODO: Logging (optional?)
    {:noreply, state}
  end

  def handle_info({conn, {:exit_status, 0}}, %{conn: conn} = state) do
    # TODO: Logging (optional?)
    {:noreply, state}
  end

  def handle_info({conn, {:exit_status, status}}, %{conn: conn} = _state) do
    Mix.raise("SSH ControlMaster exited unexpectedly with exit code #{status}")
  end
end
