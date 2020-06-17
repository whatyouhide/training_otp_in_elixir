defmodule HandrolledGenServerStack do
  def start(initial_state) do
    spawn(fn -> loop(initial_state) end)
  end

  def cast(pid, command) do
    send(pid, {:"$genserver_cast", command})
  end

  def call(pid, command, timeout) do
    ref = make_ref()
    send(pid, {:"$genserver_call", ref, self(), command})

    receive do
      {^ref, reply} ->
        reply
    after
      timeout ->
        exit(:timeout)
    end
  end

  defp loop(state) do
    receive do
      {:"$genserver_cast", command} ->
        new_state = handle_cast(command, state)
        loop(new_state)

      {:"$genserver_call", ref, caller_pid, command} ->
        {reply, new_state} = handle_call(command, state)
        send(caller_pid, {ref, reply})
        loop(new_state)
    end
  end

  defp handle_cast({:push, element}, state) do
    [element | state]
  end

  defp handle_call(:pop, [element | rest]) do
    {element, rest}
  end
end
