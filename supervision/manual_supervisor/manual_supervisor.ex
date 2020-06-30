defmodule ManualSupervisor do
  use GenServer

  require Logger

  defstruct children: %{}

  def start_link({mod, args} = _child) do
    child_spec = mod.child_spec(args)
    GenServer.start_link(__MODULE__, child_spec)
  end

  @impl true
  def init(child_spec) do
    Process.flag(:trap_exit, true)

    state = %__MODULE__{}

    case start_child(child_spec) do
      {:ok, pid} ->
        state = put_in(state.children[child_spec.id], {child_spec, pid})
        {:ok, state}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_info({:EXIT, pid, reason}, %__MODULE__{children: children} = state) do
    child_spec =
      Enum.find_value(children, fn
        {_child_id, {child_spec, ^pid}} -> child_spec
        _other -> nil
      end)

    if child_spec do
      case start_child(child_spec) do
        {:ok, pid} ->
          state = put_in(state.children[child_spec.id], {child_spec, pid})
          {:noreply, state}

        {:error, reason} ->
          {:stop, reason}
      end
    else
      _ =
        Logger.warn(
          "Received EXIT signal from process #{inspect(pid)} with reason #{inspect(reason)}"
        )

      {:noreply, state}
    end
  end

  defp start_child(child_spec) when is_map(child_spec) do
    %{start: {mod, fun, args}} = child_spec
    apply(mod, fun, args)
  end
end
