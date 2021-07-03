import Config

config :mate,
  otp_app: :example,
  module: Example

config :staging,
  server: "staging.example.com",
  build_path: "/tmp/mate/example",
  release_path: "/opt/example"

config :production,
  server: "example.com",
  build_path: "/tmp/mate/example",
  release_path: "/opt/example"
