defmodule Mate.Driver.Test do
  @moduledoc """
  The Test driver is used for testing.
  """
  use Mate.Session
  use Mate.Driver
  use GenServer

  @impl true
  def start(session, _host) do
    if is_nil(session.conn),
      do:
        raise("""
        Failed to start test driver!

        Be sure to sandbox your test driver before running the pipeline with it,
        you can do that using the `sandbox/1` function like this:

            test "My test", %{session: session} do
              session = Mate.Driver.Test.sandbox(session)

              Mate.Driver.Test.response_for {:exec, "whoami", []} do
                {:ok, "username"}
              end

              Mate.Pipeline.run(session)
            end
        """)

    {:ok, session}
  end

  # Test functions
  def sandbox(session) do
    opts = %{
      calls: %{},
      responses: [],
      session: session
    }

    with {:ok, conn} <- GenServer.start_link(__MODULE__, opts),
         do: session |> set_conn(conn)
  end

  def response_for(%Session{conn: conn}, request, do: response) do
    GenServer.call(conn, {:set_response, request, response})
  end

  @impl true
  def close(%Session{conn: conn} = session) do
    GenServer.call(conn, :stop)
    {:ok, session}
  end

  @impl true
  def current_host(%Session{conn: conn}) do
    GenServer.call(conn, :current_host)
  end

  @impl true
  def exec(%Session{conn: conn}, command, args) do
    GenServer.call(conn, {:exec, command, args}, :infinity)
  end

  @impl true
  def exec_script(%Session{conn: conn}, script) do
    GenServer.call(conn, {:exec_script, script}, :infinity)
  end

  @impl true
  def copy_from(%Session{conn: conn}, remote_src, local_dest) do
    GenServer.call(conn, {:copy, remote_src, local_dest}, :infinity)
  end

  @impl true
  def copy_to(%Session{conn: conn}, local_src, remote_dest) do
    GenServer.call(conn, {:copy, local_src, remote_dest}, :infinity)
  end

  @impl true
  def prepare_source(%Session{conn: conn} = session) do
    GenServer.call(conn, :prepare_source)
    {:ok, session}
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:set_response, request, response}, _, state) do
    {:reply, :ok, %{state | responses: state.responses ++ [{request, response}]}}
  end

  def handle_call(call, _, state) do
    response_index =
      state.responses
      |> Enum.find_index(fn
        {^call, _response} -> true
        {%Regex{} = regex, _response} -> Regex.match?(regex, inspect(call))
        {{_, %Regex{} = regex}, _response} -> Regex.match?(regex, inspect(call))
        {{_, %Regex{} = regex, _}, _response} -> Regex.match?(regex, inspect(call))
        {{_, _, %Regex{} = regex}, _response} -> Regex.match?(regex, inspect(call))
        _ -> false
      end)

    if is_nil(response_index),
      do:
        raise("""
        Missing response for:

            #{inspect(call)}

        Define a response for this call by using `response_for/3`, like so:

            Mate.Driver.Test.response_for session, {:exec, "whoami", []} do
              {:ok, "username"}
            end
        """)

    {{_call, response}, responses} = List.pop_at(state.responses, response_index)
    {:reply, response, %{state | responses: responses}}
  end
end
