defmodule Mix.Tasks.Mate.Init do
  use Mix.Task
  import Mix.Generator

  @shortdoc "Configures your application for deployments"
  @filename ".mate.exs"

  @switches [
    docker: [:boolean, :keep],
    local: [:boolean, :keep],
    force: [:boolean, :keep]
  ]

  @aliases [
    f: :force
  ]

  @moduledoc """
  Creates a new mate configuration file (#{@filename})

  ## Command line options

    * `--docker` - create file with Docker driver as default
    * `--local` - create file with Local driver as default
    * `-f`, `--force` - force create file, overwrite if one already exists

  """

  @doc false
  def run(args) do
    {opts, _} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)

    force_write? = Keyword.get(opts, :force, false)
    docker? = Keyword.get(opts, :docker, false)
    local? = Keyword.get(opts, :local, false)

    assigns = [
      otp_app: Mate.Utils.otp_app(),
      module: Mate.Utils.module()
    ]

    template =
      cond do
        docker? and local? -> Mix.raise("Cannot use both docker and local flags combined.")
        docker? -> docker_template(assigns)
        local? -> local_template(assigns)
        true -> ssh_template(assigns)
      end

    create_file(@filename, template, force: force_write?)

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

  embed_template(:ssh, """
  import Config

  config :mate,
    otp_app: :<%= @otp_app %>,
    module: <%= @module %>

  # This simple configuration will build and deploy to the same server
  config :staging,
    server: "example.com",
    build_path: "/tmp/mate/<%= @otp_app %>",
    release_path: "/opt/<%= @otp_app %>",

  # Specify secret files, if they are already present on your build server.
  # config :staging,
  #   build_secrets: %{
  #     "prod.secret.exs" => "/mnt/secrets/prod.secret.exs"
  #   }

  # You can specify separate servers like this:
  # config :production,
  #   build_server: "build.example.com",
  #   deploy_server: "www.example.com"

  # For `deploy_server` you can also set a list like this:
  # config :production,
  #   deploy_server: [
  #     "www1.example.com",
  #     "www2.example.com"
  #   ]
  """)

  embed_template(:docker, """
  import Config

  config :mate,
    otp_app: :<%= @otp_app %>,
    module: <%= @module %>,
    driver: Mate.Driver.Docker,
    driver_opts: [
      image: "bitwalker/alpine-elixir-phoenix"
    ]

  # This simple configuration will build and deploy to the same server
  config :staging,
    server: "example.com",
    build_path: "/tmp/mate/<%= @otp_app %>",
    release_path: "/opt/<%= @otp_app %>",

  # Specify secret files, if they are already present on your build server.
  # config :staging,
  #   build_secrets: %{
  #     "prod.secret.exs" => "/repo/config/prod.secret.exs"
  #   }

  # You can specify separate servers like this:
  # config :production,
  #   build_server: "build.example.com",
  #   deploy_server: "www.example.com"

  # For `deploy_server` you can also set a list like this:
  # config :production,
  #   deploy_server: [
  #     "www1.example.com",
  #     "www2.example.com"
  #   ]
  """)

  embed_template(:local, """
  import Config

  config :mate,
    otp_app: :<%= @otp_app %>,
    module: <%= @module %>,
    driver: Mate.Driver.Local

  # This simple configuration will build and deploy to the same server
  config :staging,
    server: "example.com",
    build_path: "/tmp/mate/<%= @otp_app %>",
    release_path: "/opt/<%= @otp_app %>"

  # Specify secret files, if they are already present on your build server.
  # config :staging,
  #   build_secrets: %{
  #     "prod.secret.exs" => "#{File.cwd!()}/config/prod.secret.exs"
  #   }

  # You can specify separate servers like this:
  # config :production,
  #   build_server: "build.example.com",
  #   deploy_server: "www.example.com"

  # For `deploy_server` you can also set a list like this:
  # config :production,
  #   deploy_server: [
  #     "www1.example.com",
  #     "www2.example.com"
  #   ]
  """)
end
