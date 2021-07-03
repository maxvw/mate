import Config

config :mate,
  otp_app: :example,
  module: Example,
  steps: fn ->
    [MyStep]
  end

config :staging,
  server: "example.com",
  build_path: "/tmp/mate/example",
  release_path: "/opt/example"
