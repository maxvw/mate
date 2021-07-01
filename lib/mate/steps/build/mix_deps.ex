defmodule Mate.Step.MixDeps do
  @moduledoc "This will install the mix dependencies."
  use Mate.Pipeline.Step

  @impl true
  def run(%{remote: remote, config: config} = session) do
    script = """
    #!/usr/bin/env bash
    set -euo pipefail
    export MIX_ENV="#{config.mix_env}"
    cd "#{remote.build_path}"
    mix local.hex --force
    mix deps.get --only prod
    """

    with {:error, error} <- remote_script(session, script),
         do: bail(session, "Failed to download mix dependencies.", error)

    {:ok, session}
  end
end
