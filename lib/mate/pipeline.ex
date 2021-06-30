defmodule Mate.Pipeline do
  @moduledoc """
  This module keeps track of the build and deploy pipelines.

  It will use the given `steps` from your `Mate.Config` to either build or deploy
  your application on the specified servers. The default steps will attempt to sniff
  whether or not you are in need of the assets pipeline, which uses `npm` by default.

  The pipeline can be updated with custom steps using the configuration file `.mate.exs`,
  for example you can add a custom step module with the `Mate.Pipeline.Step` behaviour.

      config :mate,
        steps: fn steps, pipeline ->
          pipeline.insert_before(steps, Mate.Step.CleanBuild, CustomStep)
        end,

        defmodule CustomStep do
          use Mate.Pipeline.Step

          @impl true
          def run(session) do
            IO.puts("Execute my custom code")
            {:ok, session}
          end
        end

  You can also use useful commands like `local_cmd/2`, `local_cmd/3`,
  `local_script/2`, `remote_cmd/2`, `remote_cmd/3`, `remote_script/2`,
  `copy_from/3` and `copy_to/3` to interact with the local machine or with
  the build server in various ways.
  """
  alias Mate.Utils

  alias Mate.Step.{
    CopyToStorage,
    LinkBuildSecrets,
    CleanBuild,
    MixCompile,
    MixDigest,
    MixDeps,
    MixRelease,
    NpmBuild,
    NpmInstall,
    PrepareSource,
    VerifyElixir,
    VerifyNode
  }

  use Mate.Session

  defstruct prev_step: nil,
            next_step: nil,
            current_step: nil,
            steps: []

  @type t() :: %__MODULE__{
          prev_step: atom(),
          next_step: atom(),
          current_step: atom(),
          steps: list(atom() | function())
        }

  def default_steps do
    package_json = Path.join("assets", "package.json") |> Path.absname()

    steps = [
      VerifyElixir,
      PrepareSource,
      LinkBuildSecrets,
      CleanBuild,
      MixDeps,
      MixCompile,
      MixRelease,
      CopyToStorage
    ]

    if File.exists?(package_json) do
      steps
      |> insert_after(VerifyElixir, VerifyNode)
      |> insert_before(MixDeps, NpmInstall)
      |> insert_before(MixRelease, [NpmBuild, MixDigest])
    else
      steps
    end
  end

  def new, do: new(default_steps())

  def new(steps) when is_list(steps) do
    %__MODULE__{
      steps: steps
    }
  end

  def run(%Session{pipeline: %{steps: steps}} = session) do
    hosts =
      case session do
        %{context: :build} -> [[session.remote.build_server] |> List.first()]
        %{context: :deploy} -> [session.remote.deploy_server]
        %{context: context} -> Mix.raise("Unknown context (#{context})")
      end
      |> List.flatten()

    sessions =
      for host <- hosts do
        {:ok, session} = session.driver.start(session, host)
        session |> assign(current_host: host)
      end

    steps
    |> List.flatten()
    |> run_step(sessions)
  end

  def insert_before(steps, target, new) do
    {:ok, target_index} = find_index(steps, target)

    steps
    |> List.insert_at(target_index, new)
  end

  def insert_after(steps, target, new) do
    {:ok, target_index} = find_index(steps, target)

    steps
    |> List.insert_at(target_index + 1, new)
  end

  def replace(steps, target, new) do
    {:ok, target_index} = find_index(steps, target)

    steps
    |> List.replace_at(target_index, new)
  end

  defp run_step([step | rest], [%{context: context} | _] = sessions) do
    step_name =
      if is_function(step),
        do: "(custom user function)",
        else: Utils.module_name(step) |> String.replace(~r/^Mate\.Step\./i, "")

    sessions =
      for session <- sessions do
        Mix.shell().info([
          :magenta,
          "[#{context}]",
          :reset,
          " running ",
          :bright,
          step_name,
          :reset,
          ", host: ",
          session.assigns.current_host
        ])

        %{
          session
          | pipeline: %{
              session.pipeline
              | prev_step: session.pipeline.current_step,
                next_step: List.first(rest),
                current_step: step
            }
        }
        |> do_perform(step)
        |> case do
          {:error, error} when is_function(step) ->
            Mix.raise(
              "Failed executing your custom function, got some error:\n\n#{inspect(error)}"
            )

          {:error, error} ->
            Mix.raise("Failed executing #{inspect(step)}, got some error:\n\n#{inspect(error)}")

          {:ok, session} ->
            session
        end
      end

    run_step(rest, sessions)
  end

  defp run_step([], sessions) do
    [session | _] =
      for session <- sessions do
        if function_exported?(session.driver, :close, 1) do
          session.driver.close(session)
        end

        %{session | finished_at: DateTime.utc_now()}
      end

    duration = DateTime.diff(session.finished_at, session.started_at, :second)

    Mix.shell().info([:green, "Completed in #{duration} seconds!"])
    {:ok, session}
  end

  defp do_perform(session, step_fn) when is_function(step_fn) do
    case :erlang.fun_info(step_fn)[:arity] do
      0 -> step_fn.()
      1 -> step_fn.(session)
      _ -> {:error, "Custom step function should have either /0 or /1 arity."}
    end
  end

  defp do_perform(session, step) when is_atom(step), do: step.run(session)

  defp find_index(steps, target) do
    steps
    |> Enum.with_index()
    |> Enum.find(fn
      {^target, _} -> true
      _ -> false
    end)
    |> case do
      {^target, index} -> {:ok, index}
      _ -> {:error, :not_found}
    end
  end
end
