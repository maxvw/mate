# Custom Build Steps
When you are creating a new build with Mate it does this in multiple steps, the default steps can be overridden completely or manipulated with a custom `Mate.Pipeline` in your `.mate.exs` configuration file.

## Behaviour
Custom steps should use the `Mate.Pipeline.Step` behaviour.

When your step is called the `run/1` function receives the current `Mate.Session` object. It should return the session object in an `{:ok, session}` tuple, or if something went wrong in your step it should return an error tuple with a descriptive error string `{:error, "My step failed because of reasons"}`. You can assign custom properties to your `Mate.Session` if you want to pass along data across multiple steps.

    defmodule CustomStep do
      use Mate.Pipeline.Step

      @impl true
      def run(session) do
        IO.puts("Execute my custom code")
        {:ok, session}
      end
    end


## Using my custom step
When you create a custom step, you need to customise the build steps to make sure it's included. You can define your own pipeline by just specifying a List of steps in your configuration file.

    config :mate,
      steps: [
        VerifyElixir,
        PrepareSource,
        LinkBuildSecrets,
        CleanBuild,
        MixDeps,
        MixCompile,
        MixRelease,
        CopyToStorage
      ]

But maybe you are happy enough with the default pipeline and just want to change it slightly, by adding, replacing or removing a step. You can do this with some useful functions from `Mate.Pipeline` like this:

    config :mate,
      steps: fn steps, pipeline ->
        steps
        |> pipeline.insert_before(Mate.Step.CleanBuild, MyCustomStep)
      end

Other useful functions for this are `insert_before/3`, `insert_after/3`, `replace/3` and `remove/2`.

## Replace a built-in step
By creating a custom step you could override  built-in steps as well, for example if you don't want to use `mix release` but another system you could create a step that executes another build system and replace `MixRelease`.

> **NOTE:** For this example I should note that the `MixRelease` step itself should add an assign `:release_archive` containing a path to the release archive on the build server. If this is missing the system will show an error of course.
