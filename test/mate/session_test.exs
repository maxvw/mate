defmodule Mate.SessionTest do
  use ExUnit.Case, async: true

  defmodule Example do
    use Mate.Session

    def test_assign3(session) do
      assign(session, :test, 42)
    end

    def test_assign2(session) do
      assign(session, test: 42, foo: :bar)
    end
  end

  test "new/1 should create a new session based on the given config" do
    config = %Mate.Config{steps: []}
    session = Mate.Session.new(config)
    assert session.config == config
    assert session.driver == config.driver
    refute is_nil(session.started_at)
    assert %Mate.Pipeline{steps: []} == session.pipeline
    assert session.context == :build
  end

  test "new/2 should create a new session with custom properties" do
    config = %Mate.Config{steps: []}
    session = Mate.Session.new(config, context: :deploy)
    assert session.context == :deploy
  end

  test "using Mate.Session adds private assign/3 function" do
    session =
      %Mate.Session{}
      |> Example.test_assign3()

    assert session.assigns == %{test: 42}
  end

  test "using Mate.Session adds private assign/2 function" do
    session =
      %Mate.Session{}
      |> Example.test_assign2()

    assert session.assigns == %{test: 42, foo: :bar}
  end
end
