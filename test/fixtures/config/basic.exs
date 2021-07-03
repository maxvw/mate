import Config

config :mate,
  otp_app: :example,
  module: Example

config :staging,
  server: "example.com",
  build_path: "/tmp/mate/example",
  release_path: "/opt/example"
