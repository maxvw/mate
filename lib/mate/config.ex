defmodule Mate.Config do
  @moduledoc """
  The configuration for mate deployments is stored in your applications root
  directory, in a file named `.mate.exs`. This uses `import Config` as you might
  already be used to.

  To get started you can use the mix task `mix mate.init` to help generate one for you.

  The configuration exists out of two parts:

  ## 1. Mate configuration
  This configures `mate` itself, a full example would be:

      config :mate,
        otp_app: :my_app,
        driver: Mate.Driver.SSH,
        mix_env: :prod,
        clean_paths: ~w{_build rel priv/generated priv/static}

  You can also customise the build steps that are executed, but more information
  about that can be found in `Mate.Pipeline`.

  ## 2. Remote configuration
  You can specify one or more remotes, for example you could configure a staging
  and production environment. But you can add as many as you want, with whichever
  names you want to use.

  A remote ends up as a `%Mate.Remote{}` struct, so a very complete example is:

      config :staging,
        build_server: "build.example.com",
        deploy_server: "www.example.com",
        build_path: "/tmp/build/my-app",
        release_path: "/opt/my-app",
        build_secrets: %{
          "prod.secret.exs" => "/home/elixir/secrets/prod.secret.exs"
        }

  If both servers are the same you can also opt to just configure `server` instead
  of having to specify both `build_server` and `deploy_server`. For small setups it
  might be more likely for you to not have a separate build server yet.

      config :staging,
        server: "www.example.com",

  You can also specify multiple deploy servers by turning them into a list as such:

      config :staging,
        deploy_server: ["www1.example.com", "www2.example.com", "www3.example.com"]

  """
  alias Mate.Remote
  alias Mate.Pipeline

  defstruct [
    :otp_app,
    :module,
    :steps,
    driver: Mate.Driver.SSH,
    driver_opts: [],
    mix_env: :prod,
    clean_paths: ~w{_build rel priv/generated priv/static},
    remotes: []
  ]

  @type t() :: %__MODULE__{
          otp_app: atom(),
          module: String.t(),
          steps: list(atom()) | function() | nil,
          driver: atom(),
          driver_opts: keyword(),
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

  @spec parse_steps(Mate.Config.t(), nil) :: Mate.Config.t()
  defp parse_steps(config, nil) do
    %{config | steps: Pipeline.default_steps()}
  end
end
