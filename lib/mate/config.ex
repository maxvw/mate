defmodule Mate.Config do
  alias Mate.Remote
  alias Mate.Pipeline

  defstruct [
    :otp_app,
    :module,
    driver: Mate.Driver.SSH,
    mix_env: :dev,
    steps: Pipeline.default_steps(),
    remotes: []
  ]

  def read! do
    config = Config.Reader.read!(".mate.exs")

    struct(__MODULE__, config[:mate])
    |> Map.merge(%{
      remotes:
        config
        |> Keyword.drop([:mate])
        |> Enum.map(fn {k, v} -> Remote.new(k, v) end)
    })
    |> parse_steps()
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

  defp parse_steps(%{steps: user_fn} = config) when is_function(user_fn) do
    default_steps = Pipeline.default_steps()

    steps =
      case :erlang.fun_info(user_fn)[:arity] do
        1 -> user_fn.(default_steps)
        2 -> user_fn.(default_steps, Mate.Pipeline)
        _ -> Mix.raise("Custom steps function should have either /1 or /2 arity.")
      end

    %{config | steps: steps}
  end

  defp parse_steps(config), do: config
end
