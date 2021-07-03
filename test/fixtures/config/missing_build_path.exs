import Config

config :mate,
  otp_app: :example,
  module: Example

config :staging,
  server: "example.com",
  release_path: "/opt/example"
