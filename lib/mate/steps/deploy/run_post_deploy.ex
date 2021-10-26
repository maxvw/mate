defmodule Mate.Step.RunPostDeploy do
  @moduledoc "Runs commands on the deploy targets after starting."
  use Mate.Pipeline.Step

  @impl true
  def run(%{remote: remote, config: %{otp_app: otp_app}} = session) do
    otp_app_bin = Path.join(remote.release_path, "/bin/#{otp_app}")

    for {command, args} <- remote.post_deploy do
      args = List.flatten([to_string(command) | [args]])

      with {:error, error} <- remote_cmd(session, otp_app_bin, args),
           do:
             bail(session, "Failed to run #{otp_app} #{command} #{Enum.join(args, " ")}.", error)
    end

    {:ok, session}
  end
end
