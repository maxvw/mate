import Config

config :mate,
  otp_app: :example,
  driver: Mate.Driver.Local,
  storage: Mate.Storage.BuildServer,
  storage_opts: [
    release_dir: "tmp/archives/build/"
  ],
  module: Example

config :staging,
  server: "example.com",
  build_path: "/tmp/mate/example",
  release_path: "/opt/example"
