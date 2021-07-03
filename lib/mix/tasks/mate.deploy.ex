defmodule Mix.Tasks.Mate.Deploy do
  alias Mate.Session
  alias Mate.Pipeline

  alias Mate.Step.{
    CopyToDeployHost,
    UnarchiveRelease,
    StartRelease
  }

  use Mix.Task

  @shortdoc "Deploys the current commit of your application"

  @switches [
    verbose: [:integer, :count]
  ]

  @aliases [
    v: :verbose
  ]

  @moduledoc """
  Builds a new release and deploys it too

  ## Command line options

    * `-v`, `--verbose` - increases verbosity level (more output!)

  """

  @doc false
  def run(args) do
    {opts, argv} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)
    verbosity = Keyword.get(opts, :verbose, 0)

    config = Mate.Config.read!(".mate.exs")
    remote = Mate.Config.find_remote!(config, List.first(argv))

    Mix.shell().info(["Starting build on", " ", :bright, to_string(remote.id)])

    build_session = Session.new(config, remote: remote, verbosity: verbosity)
    {:ok, build_session} = Mate.Pipeline.run(build_session)

    hosts = [remote.deploy_server] |> List.flatten() |> Enum.join(", ")

    unless Mix.shell().yes?("Do you want to deploy this build to #{hosts}?"),
      do: exit(:normal)

    Mix.shell().info(["Starting deploy on", " ", :bright, to_string(remote.id)])

    deploy_session =
      Session.new(config,
        verbosity: verbosity,
        assigns: build_session.assigns,
        context: :deploy,
        remote: remote,
        driver: Mate.Driver.SSH,
        pipeline:
          Pipeline.new([
            CopyToDeployHost,
            UnarchiveRelease,
            StartRelease
          ])
      )

    Mate.Pipeline.run(deploy_session)
  end
end
