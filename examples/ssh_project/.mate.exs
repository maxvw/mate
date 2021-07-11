import Config

config :mate,
  otp_app: :ssh_project,
  module: SSHProject

config :staging,
  server: "localhost",
  build_path: "/tmp/mate/ssh_project",
  release_path: "/opt/ssh_project"
