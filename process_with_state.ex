defmodule ProcessWithState do
  def start(initial_state) do
    spawn(fn -> loop(initial_state) end)
  end

  defp loop(state) do
    receive do
      {:get_state, ref, caller_pid} ->
        send(caller_pid, {ref, state})
        loop(state)

      {:update_state, new_state} ->
        loop(new_state)
    end
  end
end
