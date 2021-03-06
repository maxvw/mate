defmodule Mate.Step.MixDigest do
  @moduledoc "This will run `mix phx.digest.clean` and `mix phx.digest` on the build server."
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

    with {:error, error} <- remote_script(session, script),
         do: bail(session, "Failed to create front-end digest.", error)

    {:ok, session}
  end
end
