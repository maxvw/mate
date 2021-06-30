defmodule Mate.Step.MixCompile do
  @moduledoc "This will run `mix compile` on the build server."
  use Mate.Pipeline.Step

  @impl true
  def run(%{remote: remote, config: config} = session) do
    script = """
    #!/usr/bin/env bash
    set -euo pipefail
    export MIX_ENV="#{config.mix_env}"
    cd "#{remote.build_path}"
    mix compile
    """

    with {:error, error} <- remote_script(session, script),
         do: bail("Failed to compile application.", error)

    {:ok, session}
  end
end
