defmodule Mate.Step.MixRelease do
  @moduledoc "This will run `mix release --overwrite` on the build server."
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
         {:ok, tar_gz} <- find_tar_path(stdout) do
      {:ok, assign(session, :release_archive, tar_gz)}
    else
      {:error, :not_found} ->
        bail("Could not find tar.gz release, is your mix project configured with `:tar`?")

      {:error, error} ->
        bail("Failed to run mix release.", error)
    end
  end

  defp find_tar_path(stdout) do
    case Regex.scan(~r/\/[^ ]+\.tar\.gz/, stdout) do
      [[tar_gz]] -> {:ok, tar_gz}
      _ -> {:error, :not_found}
    end
  end
end
