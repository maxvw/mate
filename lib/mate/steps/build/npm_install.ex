defmodule Mate.Step.NpmInstall do
  @moduledoc "This will install the front-end dependencies using npm."
  use Mate.Pipeline.Step

  @impl true
  def run(%{remote: remote} = session) do
    script = """
    #!/usr/bin/env bash
    set -euo pipefail
    cd "#{remote.build_path}/assets"
    npm install -f
    """

    with {:error, error} <- remote_script(session, script),
         do: bail(session, "Failed to download all front-end dependencies.", error)

    {:ok, session}
  end
end
