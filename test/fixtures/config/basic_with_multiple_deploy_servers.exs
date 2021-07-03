import Config

config :mate,
  otp_app: :example,
  module: Example

config :staging,
  build_server: "build.example.com",
  deploy_server: [
    "www1.example.com",
    "www2.example.com"
  ],
  build_path: "/tmp/mate/example",
  release_path: "/opt/example"
