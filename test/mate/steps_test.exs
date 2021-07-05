defmodule Mate.StepTests do
  use ExUnit.Case, async: true
  alias Mate.Pipeline
  alias Mate.Driver.Test, as: TestDriver

  alias Mate.Step.{
    CleanBuild,
    MixCompile,
    MixDeps,
    MixDigest,
    MixRelease,
    NpmBuild,
    NpmInstall,
    VerifyElixir,
    VerifyGit,
    VerifyNode,
    CopyToStorage,
    LinkBuildSecrets,
    PrepareSource,
    CopyToDeployHost,
    StartRelease,
    UnarchiveRelease
  }

  setup do
    config = Mate.Config.read!("test/fixtures/config/basic_test_driver.exs")

    session =
      config
      |> Mate.Session.new(remote: Mate.Config.find_remote!(config, nil))
      |> TestDriver.sandbox()
      |> assign(:git_branch, "main")
      |> assign(:release_archive, "/path/to/release.tar.gz")
      |> set_secrets(%{
        "prod.secret.exs" => "/home/elixir/secrets/prod.secret.exs"
      })
      |> set_verbose(2)

    TestDriver.response_for(session, :current_host, do: "test-host")
    TestDriver.response_for(session, :stop, do: "bye")

    [session: session]
  end

  scenarios = [
    {:success, CleanBuild,
     for path <- ~w{_build rel priv/generated priv/static} do
       [{:ok, "done"}, {:exec, "rm", ["-rf", "/tmp/mate/example/" <> path]}]
     end},
    {:failure, CleanBuild,
     for path <- ~w{_build rel priv/generated priv/static} do
       [{:error, "Permission denied"}, {:exec, "rm", ["-rf", "/tmp/mate/example/" <> path]}]
     end},
    {:failure, MixCompile,
     [
       [{:error, "Permission denied"}, {:exec_script, ~r/mix compile/}]
     ]},
    {:success, MixCompile,
     [
       [{:ok, "done"}, {:exec_script, ~r/mix compile/}]
     ]},
    {:failure, MixDeps,
     [
       [{:error, "Permission denied"}, {:exec_script, ~r/mix deps.get/}]
     ]},
    {:success, MixDeps,
     [
       [{:ok, "done"}, {:exec_script, ~r/mix deps.get/}]
     ]},
    {:failure, MixDigest,
     [
       [{:error, "Permission denied"}, {:exec_script, ~r/mix phx.digest/}]
     ]},
    {:success, MixDigest,
     [
       [{:ok, "done"}, {:exec_script, ~r/mix phx.digest/}]
     ]},
    {:failure, MixRelease,
     [
       [{:error, "Permission denied"}, {:exec_script, ~r/mix release/}]
     ]},
    {:failure, MixRelease,
     [
       [{:ok, "output missing tar.gz"}, {:exec_script, ~r/mix release/}]
     ]},
    {:success, MixRelease,
     [
       [{:ok, "done at /build/dir/release.tar.gz"}, {:exec_script, ~r/mix release/}]
     ]},
    {:failure, NpmBuild,
     [
       [{:error, "Permission denied"}, {:exec_script, ~r/npm run deploy/}]
     ]},
    {:success, NpmBuild,
     [
       [{:ok, "done"}, {:exec_script, ~r/npm run deploy/}]
     ]},
    {:failure, NpmInstall,
     [
       [{:error, "Permission denied"}, {:exec_script, ~r/npm install/}]
     ]},
    {:success, NpmInstall,
     [
       [{:ok, "done"}, {:exec_script, ~r/npm install/}]
     ]},
    {:failure, VerifyElixir,
     [
       [{:error, "Permission denied"}, {:exec, "which", ["elixir"]}]
     ]},
    {:failure, VerifyElixir,
     [
       [{:ok, "found"}, {:exec, "which", ["elixir"]}],
       [{:error, "not found"}, {:exec, "which", ["mix"]}]
     ]},
    {:success, VerifyElixir,
     [
       [{:ok, "found"}, {:exec, "which", ["elixir"]}],
       [{:ok, "found"}, {:exec, "which", ["mix"]}]
     ]},
    {:failure, VerifyNode,
     [
       [{:error, "not found"}, {:exec, "which", ["node"]}]
     ]},
    {:failure, VerifyNode,
     [
       [{:ok, "found"}, {:exec, "which", ["node"]}],
       [{:error, "not found"}, {:exec, "which", ["npm"]}]
     ]},
    {:success, VerifyNode,
     [
       [{:ok, "found"}, {:exec, "which", ["node"]}],
       [{:ok, "found"}, {:exec, "which", ["npm"]}]
     ]},
    {:failure, VerifyGit,
     [
       [{:error, "permission denied"}, {:exec_script, ~r/test-write/}]
     ]},
    {:failure, VerifyGit,
     [
       [{:ok, "done"}, {:exec_script, ~r/test-write/}],
       [{:error, "error"}, {:exec_script, ~r/git init/}]
     ]},
    {:success, VerifyGit,
     [
       [{:ok, "done"}, {:exec_script, ~r/test-write/}],
       [{:ok, "done"}, {:exec_script, ~r/git init/}]
     ]},
    {:success, CopyToStorage,
     [
       [{:ok, "done"}, {:copy, "/path/to/release.tar.gz", ~r/release.tar.gz/}]
     ]},
    {:failure, CopyToStorage,
     [
       [{:error, "failed"}, {:copy, "/path/to/release.tar.gz", ~r/release.tar.gz/}]
     ]},
    {:success, CopyToDeployHost,
     [
       [{:ok, "done"}, {:exec_script, ~r/test-write/}],
       [{:ok, "done"}, {:copy, "/path/to/release.tar.gz", ~r/release.tar.gz/}]
     ]},
    {:failure, CopyToDeployHost,
     [
       [{:error, "Permission denied"}, {:exec_script, ~r/test-write/}]
     ]},
    {:failure, CopyToDeployHost,
     [
       [{:ok, "done"}, {:exec_script, ~r/test-write/}],
       [{:error, "failed"}, {:copy, "/path/to/release.tar.gz", ~r/release.tar.gz/}]
     ]},
    {:success, PrepareSource,
     [
       [{:ok, "done"}, :prepare_source]
     ]},
    {:success, UnarchiveRelease,
     [
       [{:ok, "done"}, {:exec_script, ~r/tar -xzvf \\"release.tar.gz\\"/}]
     ]},
    {:failure, UnarchiveRelease,
     [
       [{:error, "error"}, {:exec_script, ~r/tar -xzvf \\"release.tar.gz\\"/}]
     ]},
    {:success, StartRelease,
     [
       [{:ok, "done"}, {:exec_script, ~r/bin\/example daemon/}]
     ]},
    {:failure, StartRelease,
     [
       [{:error, "error"}, {:exec_script, ~r/bin\/example daemon/}]
     ]},
    {:success, LinkBuildSecrets,
     [
       [{:ok, "done"}, {:exec_script, ~r/ln .*\/prod.secret.exs/}]
     ]},
    {:failure, LinkBuildSecrets,
     [
       [{:error, "failed"}, {:exec_script, ~r/ln .*\/prod.secret.exs/}]
     ]}
  ]

  for {{expect, step_module, step_mocks}, index} <- Enum.with_index(scenarios) do
    @tag mod: step_module, mocks: step_mocks, expect: expect
    test "step ##{index} - expect #{expect} for #{step_module}", %{
      session: session,
      expect: expect,
      mocks: mocks,
      mod: mod
    } do
      session = set_step(session, mod)

      for [res, req] <- mocks do
        TestDriver.response_for(session, req, do: res)
      end

      if expect == :success do
        Pipeline.run(session)
      else
        assert_raise Mix.Error, fn ->
          Pipeline.run(session)
        end
      end
    end
  end

  defp set_step(session, step_mod) do
    %{session | pipeline: %{session.pipeline | steps: [step_mod]}}
  end

  defp assign(session, key, value) do
    %{session | assigns: Map.put(session.assigns, key, value)}
  end

  defp set_secrets(%{config: %{remotes: [remote]} = config} = session, secrets) do
    remote = %{remote | build_secrets: secrets}
    %{session | remote: remote, config: %{config | remotes: [remote]}}
  end

  defp set_verbose(session, verbose) do
    %{session | verbosity: verbose}
  end
end
