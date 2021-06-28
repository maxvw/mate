defmodule Mate.Step.CleanBuild do
  @moduledoc "This removes the specified `config.clean_paths`."
  use Mate.Pipeline.Step

  @impl true
  def run(%{remote: remote, config: config} = session) do
    absolute_clean_paths =
      config.clean_paths
      |> Enum.map(&Path.join(remote.build_path, &1))

    for clean_path <- absolute_clean_paths do
      with {:error, error} <- remote_cmd(session, "rm", ["-rf", clean_path]),
           do: bail("Failed to clean build directory: #{clean_path}", error)
    end

    {:ok, session}
  end
end
