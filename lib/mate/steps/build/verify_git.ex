defmodule Mate.Step.VerifyGit do
  @moduledoc """
  This verifies git both on the local machine and the build server.

  ## Local Machine
  On your local machine it will ensure there is a git remote configured for the
  current remote (e.g. staging, production) to the build server. It will also
  get the name of the current branch on your local machine.

  ## Build Server
  On the build server it will ensure that the build path exists, that it is a
  git repository, that is is configured to receive commits, it is given a hard
  reset and checkout to the same branch that is currently used on the local machine.
  """
  use Mate.Pipeline.Step

  @impl true
  def run(%{remote: remote} = session) do
    test_writable = """
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p "#{remote.build_path}"
    cd "#{remote.build_path}"
    touch test-write
    rm test-write
    """

    with {:error, _error} <- Mate.remote_script(session, test_writable),
         do: bail("Build user not allowed to write to #{remote.build_path}")

    # Understand local branch
    branch =
      with {:ok, branch} when branch != "" <-
             Mate.local_cmd(session, "git", ~w{rev-parse --abbrev-ref HEAD}) do
        branch
      else
        {:ok, ""} ->
          bail("Current git branch name empty? Check `git rev-parse --abbrev-ref HEAD`")

        {:error, error} ->
          bail("Failed to get current branch name", error)
      end

    script = """
    #!/usr/bin/env bash
    set -euo pipefail
    cd "#{remote.build_path}"
    git init
    git config receive.denyCurrentBranch updateInstead
    git reset --hard
    git checkout "#{branch}"
    """

    # Setup remote
    with {:error, error} <- Mate.remote_script(session, script),
         do: bail("Failed to ensure git on remote host.", error)

    # Setup local
    git_remote_name = "mate-#{remote.id}"
    git_remote_url = "#{remote.build_server}:#{remote.build_path}"

    with {:error, _error} <-
           Mate.local_cmd(session, "git", ~w{remote get-url #{git_remote_name}}),
         {:error, error} <-
           Mate.local_cmd(session, "git", ~w{remote add #{git_remote_name} #{git_remote_url}}),
         do: bail("Failed to ensure remote origin on local git repository.", error)

    {:ok, session |> assign(:git_branch, branch)}
  end
end
