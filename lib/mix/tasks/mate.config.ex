defmodule Mix.Tasks.Mate.Config do
  use Mix.Task
  alias Mate.Utils

  @shortdoc "Displays the current configuration."

  @moduledoc """
  Displays the current configuration of `.mate.exs`
  """

  @doc false
  def run(_args) do
    config = Mate.Config.read!(".mate.exs")

    Mix.shell().info([:green, :bright, "\t\t\tMate Information"])
    Mix.shell().info(["Configuration file:", :bright, "\t", Path.absname(".mate.exs")])
    Mix.shell().info(["OTP Application:", :bright, "\t", inspect(config.otp_app)])
    Mix.shell().info(["Module Namespace:", :bright, "\t", Utils.module_name(config.module)])

    Mix.shell().info("")
    Mix.shell().info([:green, :bright, "\t\t\tBuild Information"])

    Mix.shell().info(["Using MIX_ENV:", :bright, "\t\t", inspect(config.mix_env)])
    Mix.shell().info(["Build with", :bright, "\t\t", Utils.module_name(config.driver)])

    for {k, v} <- config.driver_opts do
      Mix.shell().info([:yellow, "\t\t\t#{k}: ", :bright, "#{v}"])
    end

    Mix.shell().info("")

    if config.clean_paths != [] do
      [path | paths] = config.clean_paths
      Mix.shell().info(["Clean paths:", :bright, "\t\t#{path}"])

      for path <- paths do
        Mix.shell().info([:bright, "\t\t\t#{path}"])
      end
    end

    [step | steps] = List.flatten(config.steps)
    Mix.shell().info("")
    Mix.shell().info(["Build steps:", :bright, "\t\t", inspect(step)])

    for step <- steps do
      Mix.shell().info([:bright, "\t\t\t", inspect(step)])
    end

    for remote <- config.remotes do
      Mix.shell().info("")
      Mix.shell().info([:cyan, :bright, "\t\t\tRemote \"#{remote.id}\""])

      Mix.shell().info(["ID", :bright, "\t\t\t", inspect(remote.id)])
      Mix.shell().info(["Build Server", :bright, "\t\t", remote.build_server])
      Mix.shell().info(["Build Path", :bright, "\t\t", remote.build_path])
      Mix.shell().info(["Release Path", :bright, "\t\t", remote.release_path])

      case remote.deploy_server do
        server when is_binary(server) ->
          Mix.shell().info(["Deploy Server", :bright, "\t\t", server])

        [server | servers] ->
          Mix.shell().info(["Deploy Servers", :bright, "\t\t", server])

          for server <- servers do
            Mix.shell().info([:bright, "\t\t\t", server])
          end
      end

      for {secret, file} <- remote.build_secrets do
        Mix.shell().info([:bright, "\t\t\t", secret, :reset, " <-> #{file}"])
      end
    end
  end
end
