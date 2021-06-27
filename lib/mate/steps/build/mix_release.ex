defmodule Mate.Step.MixRelease do
  use Mate.Pipeline.Step

  @impl true
  def run(%{remote: remote, config: config} = session) do
    script = """
    #!/usr/bin/env bash
    set -euo pipefail
    export MIX_ENV="#{config.mix_env}"
    cd "#{remote.build_path}"
    mix release --overwrite
    """

    with {:ok, stdout} <- Mate.remote_script(session, script),
         [[tar_gz]] <- Regex.scan(~r/\/[^ ]+\.tar\.gz/, stdout) do
      {:ok, assign(session, :release_archive, tar_gz)}
    else
      {:error, error} -> bail("Failed to run mix release.", error)
      _ -> bail("Could not find tar.gz release, is your mix project configured with `:tar`?")
    end
  end
end
