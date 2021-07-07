import Config

config :mate,
  otp_app: :docker_project,
  module: DockerProject,
  driver: Mate.Driver.Docker,
  driver_opts: [
    image: "bitwalker/alpine-elixir-phoenix"
  ]

config :staging,
  server: "example.com",
  build_path: "/tmp/mate/docker_project",
  release_path: "/opt/docker_project"
