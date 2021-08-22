defmodule Mate.Session do
  @moduledoc """
  This module contains all relevant information to the current session when
  running the `mate.deploy` mix task.

  It keeps track of the current configuration, build pipeline, assigns that
  can be used to transfer information between build steps, the current context to
  determine wheter this is a building session or a deploying session, and more!
  """
  alias Mate.Pipeline

  defstruct [
    :pipeline,
    :remote,
    :driver,
    :storage,
    :config,
    :conn,
    started_at: nil,
    finished_at: nil,
    verbosity: 0,
    context: :build,
    assigns: %{}
  ]

  @type t() :: %Mate.Session{
          pipeline: Pipeline.t(),
          remote: Mate.Remote.t(),
          driver: atom(),
          storage: atom(),
          config: Mate.Config.t(),
          conn: any(),
          started_at: DateTime.t() | nil,
          finished_at: DateTime.t() | nil,
          verbosity: integer(),
          context: :build | :deploy,
          assigns: map()
        }

  defmacro __using__(_) do
    quote do
      alias Mate.Session

      @spec assign(Session.t(), atom(), any()) :: Session.t()
      defp assign(%Session{assigns: assigns} = session, key, value) when is_atom(key) do
        %{session | assigns: Map.put(assigns, key, value)}
      end

      @spec assign(Session.t(), map() | keyword()) :: Session.t()
      defp assign(%Session{assigns: assigns} = session, new_assigns)
           when is_list(new_assigns) do
        new_assigns = Map.new(new_assigns)
        %{session | assigns: Map.merge(assigns, new_assigns)}
      end
    end
  end

  @doc """
  Creates a new `Mate.Session` struct based on the given config file and
  optionally any other options can be set.
  """
  @spec new(config :: Mate.Config.t()) :: Mate.Session.t()
  @spec new(config :: Mate.Config.t(), keyword()) :: Mate.Session.t()
  def new(config, opts \\ []) do
    %Mate.Session{
      config: config,
      driver: config.driver,
      storage: config.storage,
      started_at: DateTime.utc_now(),
      pipeline: Pipeline.new(config.steps)
    }
    |> Map.merge(Map.new(opts))
  end
end
