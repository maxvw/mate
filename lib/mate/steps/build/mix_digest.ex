defmodule Mate.Step.MixDigest do
  use Mate.Pipeline.Step

  @impl true
  def run(%{remote: remote, config: config} = session) do
    script = """
    #!/usr/bin/env bash
    set -euo pipefail
    export MIX_ENV="#{config.mix_env}"
    cd "#{remote.build_path}"
    mix phx.digest.clean
    mix phx.digest
    """

    with {:error, error} <- Mate.remote_script(session, script),
         do: bail("Failed to create front-end digest.", error)

    {:ok, session}
  end
end
