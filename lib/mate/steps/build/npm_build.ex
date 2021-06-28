defmodule Mate.Step.NpmBuild do
  @moduledoc "This will run `npm run deploy` on the build server."
  use Mate.Pipeline.Step

  @impl true
  def run(%{remote: remote} = session) do
    script = """
    #!/usr/bin/env bash
    set -euo pipefail
    cd "#{remote.build_path}/assets"
    npm run deploy
    """

    with {:error, error} <- remote_script(session, script),
         do: bail("Failed to build front-end dependencies.", error)

    {:ok, session}
  end
end
