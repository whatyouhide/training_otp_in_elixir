defmodule SharedState do
  ## Public API

  @spec start(term()) :: pid()
  def start(initial_state) do
    spawn(fn -> loop(initial_state) end)
  end

  @spec get(pid()) :: term()
  def get(pid) do
    ref = make_ref()
    send(pid, {:get_state, ref, self()})

    receive do
      {^ref, state} -> state
    end
  end

  @spec update(pid(), (term() -> term())) :: :ok
  def update(pid, update_fun) when is_function(update_fun, 1) do
    send(pid, {:update_state, update_fun})
    :ok
  end

  ## Process loop

  defp loop(state) do
    receive do
      {:get_state, ref, caller_pid} ->
        send(caller_pid, {ref, state})
        loop(state)

      {:update_state, update_fun} ->
        new_state = update_fun.(state)
        loop(new_state)
    end
  end
end
