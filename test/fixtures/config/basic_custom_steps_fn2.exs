import Config

config :mate,
  otp_app: :example,
  module: Example,
  steps: fn steps, pipeline ->
    steps
    |> pipeline.insert_before(Mate.Step.CleanBuild, MyStep)
  end

config :staging,
  server: "example.com",
  build_path: "/tmp/mate/example",
  release_path: "/opt/example"
