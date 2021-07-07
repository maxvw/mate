defmodule Mix.Tasks.Mate.Build do
  alias Mate.Session
  alias Mate.Pipeline

  use Mix.Task

  @shortdoc "Builds the release archive for the current commit of your application"

  @switches [
    verbose: [:integer, :count]
  ]

  @aliases [
    v: :verbose
  ]

  @moduledoc """
  Builds a new release only, no deploying.

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
    Pipeline.run(build_session)
  end
end
