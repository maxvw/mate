defmodule Mate.Step.VerifyGit do
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

    script = """
    #!/usr/bin/env bash
    set -euo pipefail
    cd "#{remote.build_path}"
    git init
    git config receive.denyCurrentBranch updateInstead
    git reset --hard
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

    {:ok, session}
  end
end
