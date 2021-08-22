import Config

config :mate,
  otp_app: :example,
  driver: Mate.Driver.Local,
  storage: Mate.Storage.S3,
  storage_opts: [
    bucket: "mate-integration",
    prefix: "github/",
    region: "eu-central-1",
    access_key_id: System.fetch_env!("AWS_ACCESS_KEY"),
    secret_access_key: System.fetch_env!("AWS_SECRET_ACCESS_KEY")
  ],
  module: Example

config :staging,
  server: "example.com",
  build_path: "/tmp/mate/example",
  release_path: "/opt/example"
