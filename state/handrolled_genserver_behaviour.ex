defmodule HandrolledGenServer do
  @callback handle_cast(command :: term(), state :: term()) :: new_state :: term()

  @callback handle_call(command :: term(), state :: term()) ::
              {reply :: term(), new_state :: term()}

  def start(callback_module, initial_state) do
    spawn(fn -> loop(callback_module, initial_state) end)
  end

  def cast(pid, command) do
    send(pid, {:"$genserver_cast", command})
  end

  def call(pid, command, timeout \\ 5000) do
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

  defp loop(callback_module, state) do
    receive do
      {:"$genserver_cast", command} ->
        new_state = callback_module.handle_cast(command, state)
        loop(callback_module, new_state)

      {:"$genserver_call", ref, caller_pid, command} ->
        {reply, new_state} = callback_module.handle_call(command, state)
        send(caller_pid, {ref, reply})
        loop(callback_module, new_state)
    end
  end
end
