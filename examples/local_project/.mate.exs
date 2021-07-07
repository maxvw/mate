import Config

config :mate,
  otp_app: :local_project,
  module: LocalProject,
  driver: Mate.Driver.Local

config :staging,
  server: "example.com",
  build_path: "/tmp/mate/local_project",
  release_path: "/opt/local_project"
