defmodule Mate.PipelineTest do
  use ExUnit.Case
  alias Mate.Pipeline

  defmodule ExampleGood do
    use Mate.Pipeline.Step

    def run(session) do
      session = %{session | assigns: Map.put(session.assigns, :test, true)}
      {:ok, session}
    end
  end

  defmodule ExampleBad do
    use Mate.Pipeline.Step

    def run(_session) do
      {:error, "Something is wrong"}
    end
  end

  setup do
    config = Mate.Config.read!("test/fixtures/config/basic.exs")
    session = Mate.Session.new(config)
    [session: session]
  end

  test "default_steps/0 returns default steps" do
    assert Pipeline.default_steps() == [
             Mate.Step.VerifyElixir,
             Mate.Step.PrepareSource,
             Mate.Step.LinkBuildSecrets,
             Mate.Step.CleanBuild,
             Mate.Step.MixDeps,
             Mate.Step.MixCompile,
             Mate.Step.MixRelease,
             Mate.Step.CopyToStorage
           ]
  end

  test "default_steps/0 returns default steps (detects assets/package.json)" do
    cwd = File.cwd!()
    File.cd!("test/fixtures/project_with_assets")

    assert Pipeline.default_steps() == [
             Mate.Step.VerifyElixir,
             Mate.Step.VerifyNode,
             Mate.Step.PrepareSource,
             Mate.Step.LinkBuildSecrets,
             Mate.Step.CleanBuild,
             Mate.Step.NpmInstall,
             Mate.Step.MixDeps,
             Mate.Step.MixCompile,
             [Mate.Step.NpmBuild, Mate.Step.MixDigest],
             Mate.Step.MixRelease,
             Mate.Step.CopyToStorage
           ]

    File.cd!(cwd)
  end

  test "new/0 returns Pipeline with default steps" do
    default_steps = Pipeline.default_steps()
    %Pipeline{steps: ^default_steps} = Pipeline.new()
  end

  test "new/1 returns Pipeline with custom steps" do
    %Pipeline{steps: [MyStep]} = Pipeline.new([MyStep])
  end

  test "insert_before/3 insert custom step before existing step" do
    steps = Pipeline.default_steps()
    before = length(steps)
    steps = Pipeline.insert_before(steps, Mate.Step.CleanBuild, MyStep)

    assert length(steps) == before + 1
    assert Enum.member?(steps, MyStep)

    assert Enum.find_index(steps, &(&1 == MyStep)) <
             Enum.find_index(steps, &(&1 == Mate.Step.CleanBuild))
  end

  test "insert_after/3 insert custom step after existing step" do
    steps = Pipeline.default_steps()
    before = length(steps)
    steps = Pipeline.insert_after(steps, Mate.Step.CleanBuild, MyStep)

    assert length(steps) == before + 1
    assert Enum.member?(steps, MyStep)

    assert Enum.find_index(steps, &(&1 == MyStep)) >
             Enum.find_index(steps, &(&1 == Mate.Step.CleanBuild))
  end

  test "replace/3 replaces existing step with custom step" do
    steps = Pipeline.default_steps()
    before = Enum.find_index(steps, &(&1 == Mate.Step.CleanBuild))
    steps = Pipeline.replace(steps, Mate.Step.CleanBuild, MyStep)
    assert Enum.member?(steps, MyStep)
    refute Enum.member?(steps, Mate.Step.CleanBuild)
    assert Enum.find_index(steps, &(&1 == MyStep)) == before
  end

  test "remove/2 removes an existing step" do
    steps = Pipeline.default_steps()
    steps = Pipeline.remove(steps, Mate.Step.CleanBuild)
    refute Enum.member?(steps, Mate.Step.CleanBuild)
  end

  test "run_step/2 runs a step function", %{session: session} do
    session = %{session | assigns: %{current_host: "test"}}
    refute session.assigns[:test]

    session =
      Pipeline.run_step(session, fn session ->
        {:ok, %{session | assigns: Map.put(session.assigns, :test, true)}}
      end)

    assert session.assigns[:test]
  end

  test "run_step/2 raises on a step function that does not have /1 arity", %{session: session} do
    session = %{session | assigns: %{current_host: "test"}}

    assert_raise Mix.Error, fn ->
      Pipeline.run_step(session, fn ->
        {:ok, session}
      end)
    end
  end

  test "run_step/2 runs a step function that returns an error", %{session: session} do
    session = %{session | assigns: %{current_host: "test"}}

    assert_raise Mix.Error, fn ->
      Pipeline.run_step(session, fn _session ->
        {:error, "this went wrong"}
      end)
    end
  end

  test "run_step/2 runs a step module", %{session: session} do
    session = %{session | assigns: %{current_host: "test"}}
    refute session.assigns[:test]
    session = Pipeline.run_step(session, ExampleGood)
    assert session.assigns[:test]
  end

  test "run_step/2 runs a step nmodule that returns an error", %{session: session} do
    session = %{session | assigns: %{current_host: "test"}}

    assert_raise Mix.Error, fn ->
      Pipeline.run_step(session, ExampleBad)
    end
  end

  # def run(%Session{pipeline: %{steps: steps}} = session) do
  # def run_step(%{context: context} = session, step) do
end
