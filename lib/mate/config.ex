defmodule Mate.Config do
  alias Mate.Remote
  alias Mate.Pipeline

  defstruct [
    :otp_app,
    :module,
    :steps,
    driver: Mate.Driver.SSH,
    mix_env: :dev,
    remotes: []
  ]

  def read! do
    config = Config.Reader.read!(".mate.exs")
    remotes = config |> Keyword.drop([:mate])
    config = struct(__MODULE__, config[:mate])

    config
    |> parse_remotes(remotes)
    |> parse_steps(config.steps)
  end

  def find_remote(%{remotes: []}, _), do: {:error, :no_remotes}
  def find_remote(%{remotes: [remote | _]}, nil), do: {:ok, remote}

  def find_remote(config, remote) do
    config.remotes
    |> Enum.find(&(to_string(&1.id) == remote))
    |> case do
      nil -> {:error, :not_found}
      remote -> {:ok, remote}
    end
  end

  def find_remote!(config, remote) do
    find_remote(config, remote)
    |> case do
      {:ok, remote} -> remote
      {:error, :no_remotes} -> Mix.raise("No remotes have been configured in .mate.exs")
      _ -> Mix.raise("Failed to find remote configuration for: #{remote}")
    end
  end

  defp parse_remotes(config, remotes) do
    remotes =
      remotes
      |> Enum.map(fn {k, v} -> Remote.new(k, v) end)

    %{config | remotes: remotes}
  end

  defp parse_steps(config, steps_fn) when is_function(steps_fn) do
    default_steps = Pipeline.default_steps()

    steps =
      case :erlang.fun_info(steps_fn)[:arity] do
        1 -> steps_fn.(default_steps)
        2 -> steps_fn.(default_steps, Pipeline)
        _ -> Mix.raise("Custom steps function should have either /1 or /2 arity.")
      end

    %{config | steps: steps}
  end

  defp parse_steps(config, steps) when is_list(steps) do
    %{config | steps: steps}
  end

  defp parse_steps(config, _),
    do: %{config | steps: Pipeline.default_steps()}
end
