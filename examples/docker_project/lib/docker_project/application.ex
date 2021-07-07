defmodule DockerProject.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      DockerProjectWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: DockerProject.PubSub},
      # Start the Endpoint (http/https)
      DockerProjectWeb.Endpoint
      # Start a worker by calling: DockerProject.Worker.start_link(arg)
      # {DockerProject.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DockerProject.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DockerProjectWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
