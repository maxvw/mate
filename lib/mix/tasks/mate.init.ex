defmodule Mix.Tasks.Mate.Init do
  use Mix.Task
  import Mix.Generator

  @shortdoc "Configures your application for deployments"
  @filename ".mate.exs"

  @switches [
    force: [:boolean, :keep]
  ]

  @aliases [
    f: :force
  ]

  @moduledoc """
  Creates a new mate configuration file (#{@filename})

  ## Command line options

    * `-f`, `--force` - force create file, overwrite if one already exists

  """

  @doc false
  def run(args) do
    {opts, _} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)

    force_write? = Keyword.get(opts, :force, false)

    assigns = [
      otp_app: Mate.Utils.otp_app(),
      module: Mate.Utils.module()
    ]

    create_file(@filename, config_template(assigns), force: force_write?)

    Mix.shell().info("")

    Mix.shell().info([:bright, "You're almost ready to deploy!"])

    Mix.shell().info("""
    Edit the configuration file `#{@filename}` to make sure you are using
    the correct servers, paths and secret config files (if needed).

    Also make sure that `mix release` is configured to output a tarball,
    you can configure this in `mix.exs` with something like this:

        def project do
          [
            releases: [
              #{Mate.Utils.otp_app()}: [
                include_executables_for: [:unix],
                steps: [:assemble, :tar]
              ]
            ],
          ]
        end

    When everything is setup correctly, run `mix mate.deploy`.
    """)
  end

  embed_template(:config, """
  import Config

  config :mate,
    otp_app: :<%= @otp_app %>,
    module: <%= @module %>

  config :staging,
    server: "example.com",
    build_path: "/tmp/mate/<%= @otp_app %>",
    release_path: "/opt/<%= @otp_app %>",

  # You can also specify secret files, if they are present on your build server.
  # config :staging,
  #   build_secrets: %{
  #     "prod.secret.exs" => "/mnt/secrets/prod.secret.exs"
  #   }

  # You can specify separate servers like this:
  # config :production,
  #   build_server: "build.example.com",
  #   deploy_server: "www.example.com"
  """)
end
