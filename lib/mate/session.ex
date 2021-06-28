defmodule Mate.Session do
  alias Mate.Pipeline

  defstruct [
    :pipeline,
    :remote,
    :driver,
    :config,
    :conn,
    started_at: nil,
    finished_at: nil,
    verbosity: 0,
    context: :build,
    assigns: %{}
  ]

  @type t() :: %__MODULE__{
          pipeline: Pipeline.t(),
          remote: Mate.Remote.t(),
          driver: atom(),
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

  @spec new(Mate.Config.t()) :: Mate.Session.t()
  @spec new(Mate.Config.t(), keyword()) :: Mate.Session.t()
  def new(config, opts \\ []) do
    %__MODULE__{
      config: config,
      driver: config.driver,
      started_at: DateTime.utc_now(),
      pipeline: Pipeline.new(config.steps)
    }
    |> Map.merge(Map.new(opts))
  end
end
