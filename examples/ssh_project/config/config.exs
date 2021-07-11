# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :ssh_project, SSHProjectWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "zGtfdg2ioociKT87LrDPsV+g5e+W8gs1I9l0v48F4NkSgvMZHU7aiAjPKFgpxFS+",
  render_errors: [view: SSHProjectWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: SSHProject.PubSub,
  live_view: [signing_salt: "025y2zKb"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
