defmodule Mate.Step.SendGitCommit do
  use Mate.Pipeline.Step

  @impl true
  def run(%{remote: remote} = session) do
    git_remote_name = "mate-#{remote.id}"

    with {:error, error} <- Mate.local_cmd(session, "git", ~w{push #{git_remote_name} head}),
         do: bail("Failed to push commit to build_server.", error)

    {:ok, session}
  end
end
