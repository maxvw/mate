# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

########################################
# NOTE: Don't commit real secrets, this is a dummy project so it doesn't matter.
########################################
secret_key_base = "PiRGiSrTebHSNDsEazakxMOWekIl/UjGbCJrBucusvMBEcB0MVj6Xxs8e9vYI2Qg"

config :docker_project, DockerProjectWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :docker_project, DockerProjectWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
