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

  defmacro __using__(_) do
    quote do
      alias Mate.Session

      defp assign(%Session{assigns: assigns} = session, key, value) when is_atom(key) do
        %{session | assigns: Map.put(assigns, key, value)}
      end

      defp assign(%Session{assigns: assigns} = session, new_assigns)
           when is_map(new_assigns) do
        %{session | assigns: Map.merge(assigns, new_assigns)}
      end

      defp assign(%Session{assigns: assigns} = session, new_assigns)
           when is_list(new_assigns) do
        new_assigns = Map.new(new_assigns)
        %{session | assigns: Map.merge(assigns, new_assigns)}
      end
    end
  end

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
