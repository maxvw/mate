defmodule Mix.Tasks.Mate do
  use Mix.Task

  @shortdoc "Prints Mate help information"

  @moduledoc """
  Prints Mate tasks and their information.

      mix mate
  """

  @doc false
  def run(_args) do
    Mix.shell().info("Mate v0.1.7")
    Mix.shell().info("Manage your Elixir Application Deployment")
    Mix.shell().info("\nAvailable tasks:\n")
    Mix.Tasks.Help.run(["--search", "mate."])
  end
end
