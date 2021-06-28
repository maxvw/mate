defmodule Mate.Config do
  alias Mate.Remote
  alias Mate.Pipeline

  defstruct [
    :otp_app,
    :module,
    :steps,
    driver: Mate.Driver.SSH,
    mix_env: :dev,
    clean_paths: ~w{_build rel priv/generated priv/static},
    remotes: []
  ]

  @type t() :: %__MODULE__{
          otp_app: atom(),
          module: String.t(),
          steps: list(atom()) | function(),
          driver: atom(),
          mix_env: atom(),
          clean_paths: list(String.t()),
          remotes: list(Remote.t())
        }

  @spec read!() :: Mate.Config.t()
  def read! do
    config = Config.Reader.read!(".mate.exs")
    remotes = config |> Keyword.drop([:mate])
    config = struct(__MODULE__, config[:mate])

    config
    |> parse_remotes(remotes)
    |> parse_steps(config.steps)
  end

  @spec find_remote(Mate.Config.t(), atom() | String.t()) :: {:ok, Remote.t()} | {:error, any()}
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

  @spec find_remote!(Mate.Config.t(), atom() | String.t()) :: Remote.t()
  def find_remote!(config, remote) do
    find_remote(config, remote)
    |> case do
      {:ok, remote} -> remote
      {:error, :no_remotes} -> Mix.raise("No remotes have been configured in .mate.exs")
      _ -> Mix.raise("Failed to find remote configuration for: #{remote}")
    end
  end

  @spec parse_remotes(Mate.Config.t(), list(keyword())) :: Mate.Config.t()
  defp parse_remotes(config, remotes) do
    remotes =
      remotes
      |> Enum.map(fn {k, v} -> Remote.new(k, v) end)

    %{config | remotes: remotes}
  end

  @spec parse_steps(Mate.Config.t(), function()) :: Mate.Config.t()
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

  @spec parse_steps(Mate.Config.t(), list(atom())) :: Mate.Config.t()
  defp parse_steps(config, steps) when is_list(steps) do
    %{config | steps: steps}
  end
end
