defmodule HandrolledSupervisor do
  use GenServer

  require Logger

  defstruct [:children]

  @doc """
  Starts a supervisor with the given list of `children`.

  `children` has to be a list of `{module, init_arg}` tuple, which is common for
  Elixir modules. Each `module` must implement `child_spec/1` that returns a
  `t:Supervisor.child_spec/1`.
  """
  @spec start_link([child, ...]) :: GenServer.on_start()
        when child: {module(), init_arg :: term()}
  def start_link(children) when is_list(children) and children != [] do
    child_specs = Enum.map(children, fn {mod, args} -> mod.child_spec(args) end)
    GenServer.start_link(__MODULE__, child_specs)
  end

  @impl true
  def init(child_specs) do
    # The first thing we need to do is trap exits. This ensures that if the supervisor
    # shuts down (or crashes), then all of its children *need* to also exit to avoid
    # "zombie" processes that will never be shut down. However, we don't want the supervisor
    # to crash if one of its children crashes, so we need to trap exits in the supervisor
    # so that children exiting are translated into :EXIT messages. The supervisor will use
    # those to detect children going down and restart them.
    Process.flag(:trap_exit, true)

    case start_children(child_specs, _acc = []) do
      {:ok, children} -> {:ok, %__MODULE__{children: children}}
      {:error, reason} -> {:stop, reason}
    end
  end

  # This is the juice of the restarting: one of our children went down.
  @impl true
  def handle_info({:EXIT, pid, reason}, %__MODULE__{children: children} = state) do
    case List.keyfind(children, pid, 1) do
      {child_spec, ^pid} ->
        # If we have this child, now it's the time to restart it.
        case start_child(child_spec) do
          {:ok, new_pid} ->
            # We replace the child's old PID with its new PID in the list of children.
            children = List.keyreplace(children, pid, 1, {child_spec, new_pid})
            state = %__MODULE__{state | children: children}
            {:noreply, state}

          # We're being dramatic here, but if any child that crashes then fails to
          # start up again, we're going to bring the whole circus down and shut down
          # the supervisor. All or nothing.
          {:error, reason} ->
            {:stop, reason}
        end

      # This is really just a fail safe in case we get linked to another process that then
      # exits (which results in us getting an :EXIT message since we're trapping exits).
      nil ->
        _ = Logger.error("Received EXIT signal from process that is not a child")
        {:noreply, state}
    end
  end

  defp start_children([child_spec | child_specs], acc) do
    case start_child(child_spec) do
      {:ok, pid} ->
        # We store {child_spec, pid} tuples in the list of children. We could store
        # children as a map instead but that would prevent us from implementing strategies
        # like :one_for_all and :rest_for_one, where we need to know the original child order
        # when a child crashes in order to restart other children correctly.
        start_children(child_specs, [{child_spec, pid} | acc])

      # If any of the children fail to start, we stop the whole show. This is a simplification
      # as we might want to give a chance to children to start a few times when erroring out.
      # Moreover, we have some children that might have been started successfully at this point
      # that it would be nice to shut down gracefully, but we can avoid caring too much
      # since they are linked to this supervisor. That means that when this supervisor will
      # die, they'll also die and not be left behind as zombie processes.
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp start_children([], acc) do
    {:ok, Enum.reverse(acc)}
  end

  # The child_spec is a map that contains the :start key with value {mod, fun, args} used
  # to start the process (by calling mod.fun(args...)).
  defp start_child(child_spec) when is_map(child_spec) do
    %{start: {mod, fun, args}} = child_spec
    apply(mod, fun, args)
  end
end
