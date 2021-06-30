defmodule Mate.Driver.Docker do
  @moduledoc """
  The Docker driver is used to execute commands via Docker.

  Configure the docker image to use by setting it as the `build_server` in your
  local `.mate.exs` configuration file. The image you are using should contain
  everything you need for your application, for example Elixir and NodeJS.
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
             docker_bin: nil,
             container_name: nil,
             container_id: nil,
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
    GenServer.call(conn, {:exec, command, args}, :infinity)
  end

  @impl true
  def exec_script(session, script) do
    exec(session, "bash", ["-c", script])
  end

  @impl true
  def prepare_source(%Session{conn: conn, remote: remote} = session) do
    # Create the build dir
    GenServer.call(conn, {:exec, "mkdir", ["-p", remote.build_path]})

    # Clone from the mounted "/repo" dir to the build dir
    GenServer.call(
      conn,
      {:exec, "git", ["clone", "--depth", "1", "/repo", remote.build_path]},
      :infinity
    )

    {:ok, session}
  end

  @impl true
  def copy_from(%Session{conn: conn}, remote_src, local_dest) do
    GenServer.call(conn, {:copy, :from, remote_src, local_dest}, :infinity)
  end

  @impl true
  def copy_to(%Session{conn: conn}, local_src, remote_dest) do
    GenServer.call(conn, {:copy, :to, local_src, remote_dest}, :infinity)
  end

  @impl true
  def init(state) do
    container_name = "mate-" <> Utils.random_id(6)

    docker_bin = System.find_executable("docker")
    if is_nil(docker_bin), do: Mix.raise("Cannot find the docker binary on your local machine.")

    run_wrapper = Application.app_dir(:mate, "priv/run-wrapper.sh")
    current_dir = File.cwd!()

    command = [
      docker_bin,
      "run",
      "--rm",
      "-t",
      "-v",
      current_dir <> ":/repo",
      "--name",
      container_name,
      state.host,
      "/bin/bash" | state.args
    ]

    opts = [:stream, :binary, :exit_status, :hide, :use_stdio, args: command]
    conn = Port.open({:spawn_executable, run_wrapper}, opts)

    # Awaiting container to become available
    result =
      Enum.reduce_while(1..50, {:error, :no_connection}, fn _i, acc ->
        System.cmd(docker_bin, ["ps", "-aqf", "name=^#{container_name}$"], stderr_to_stdout: true)
        |> case do
          {container_id, _exit_status} ->
            container_id = String.trim(container_id)

            if container_id != "" do
              {:halt, {:ok, container_id}}
            else
              :timer.sleep(1000)
              {:cont, acc}
            end
        end
      end)

    case result do
      {:error, reason} ->
        {:stop, reason}

      {:ok, container_id} ->
        {:ok,
         %{
           state
           | conn: conn,
             docker_bin: docker_bin,
             container_id: container_id,
             container_name: container_name
         }}
    end
  end

  @impl true
  def handle_call({:exec, command, user_args}, _, state) do
    container_id = state.container_id
    docker_bin = state.docker_bin

    args = ["exec", "-t", container_id, command | user_args]

    case System.cmd(docker_bin, args, stderr_to_stdout: true) do
      {stdout, _exit_status = 0} ->
        {:reply, {:ok, String.trim(stdout)}, state}

      {stdout, exit_status} ->
        {:reply,
         {:error,
          "Remote command exited with non-ok exit status (#{exit_status})\n\nCommand: #{command} #{Enum.join(user_args, " ")}\nOutput:\n#{stdout}"},
         state}
    end
  end

  def handle_call({:copy, direction, src, dest}, _, state) do
    container_id = state.container_id
    docker_bin = state.docker_bin

    src =
      if direction == :from,
        do: container_id <> ":" <> src,
        else: src

    dest =
      if direction == :to,
        do: container_id <> ":" <> dest,
        else: dest

    args = ["cp", src, dest]

    case System.cmd(docker_bin, args, stderr_to_stdout: true) do
      {stdout, _exit_status = 0} ->
        {:reply, {:ok, String.trim(stdout)}, state}

      {stdout, exit_status} ->
        {:reply,
         {:error,
          "Failed to copy #{src} command exited with non-ok exit status (#{exit_status})\nOutput:\n#{stdout}"},
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
    Mix.raise("Docker exited unexpectedly with exit code #{status}")
  end
end
