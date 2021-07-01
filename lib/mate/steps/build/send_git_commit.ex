defmodule Mate.Step.SendGitCommit do
  @moduledoc "This will push the current branch/commit to the build server."
  use Mate.Pipeline.Step

  @impl true
  def run(%{remote: remote} = session) do
    git_remote_name = "mate-#{remote.id}"
    git_branch = session.assigns.git_branch

    with {:error, error} <-
           local_cmd(session, "git", ~w{push #{git_remote_name} #{git_branch}}),
         do: bail(session, "Failed to push commit to build_server.", error)

    script = """
    #!/usr/bin/env bash
    set -euo pipefail
    cd "#{remote.build_path}"
    git checkout "#{git_branch}"
    """

    # Setup remote
    with {:error, error} <- remote_script(session, script),
         do: bail(session, "Failed to checkout #{git_branch} on remote host.", error)

    {:ok, session}
  end
end
