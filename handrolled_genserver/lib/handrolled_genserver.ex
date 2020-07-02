defmodule HandrolledGenServer do
  @type state() :: term()
  @type command() :: term()

  ## Callbacks

  @doc """
  Simplified initialization.

  Must return the initial state.
  """
  @callback init(term()) :: initial_state :: state()

  @doc """
  Simplified cast.

  Must return an updated state.
  """
  @callback handle_cast(command(), state()) :: new_state :: state()

  @doc """
  Simplified call.

  Can only return a tuple with `{reply, new_state}`, so can only reply synchronously
  to the caller. This is in contrast with the `{:noreply, state}` tuple provided by GenServer
  alongside `GenServer.reply/2`.
  """
  @callback handle_call(command(), state()) :: {reply :: term(), new_state :: state()}

  @doc """
  Simplified message handling.

  Must return an updated state.
  """
  @callback handle_info(message :: term(), state()) :: new_state :: state()

  ## Public API

  @doc """
  Starts a "handrolled GenServer" process using `callback_module` as the module that
  implements this behaviour and `init_arg` as the initial argument.

  ## Example

      {:ok, pid} = HandrolledGenServer.start_link(Stack, _init_arg = [])

  """
  @spec start_link(module(), state()) :: {:ok, pid()}
  def start_link(callback_module, init_arg) do
    caller = self()
    ref = make_ref()

    # Here we first call the init/1 callback to initialize the process. Then we send a :ready
    # message to the caller and start the process loop. This way, the caller process can
    # wait until init/1 returns before considering the start_link successful. Note that linking
    # makes sure that whichever process goes down brings the other one down too so there's
    # no need for monitoring.
    pid =
      spawn_link(fn ->
        initial_state = callback_module.init(init_arg)
        send(caller, {:ready, ref})
        loop(callback_module, initial_state)
      end)

    receive do
      {:ready, ^ref} -> {:ok, pid}
    after
      # The timeout here is hardcoded but it would be simple enough to pass it as an argument.
      5000 -> exit({:timeout, 5000})
    end
  end

  @doc """
  Sends a cast to the given process.

  ## Examples

      HandrolledGenServer.cast(pid, {:push, 1})
      #=> :ok

  """
  @spec cast(pid(), command()) :: :ok
  def cast(pid, command) do
    send(pid, {:"$genserver_cast", command})
    :ok
  end

  @doc """
  Sends a call to the given process and waits for a reply.

  ## Examples

      HandrolledGenServer.call(pid, :pop)
      #=> 1

  """
  @spec call(pid(), command(), timeout()) :: term()
  def call(pid, command, timeout \\ 5000) do
    # We monitor the GenServer so that if it goes down while the current process is waiting
    # for a reply, then we can exit the current process. We also use the returned monitor ref
    # to "tag" the call and reply.
    ref = Process.monitor(pid)

    send(pid, {:"$genserver_call", ref, self(), command})

    receive do
      {^ref, reply} ->
        # It's important to *demonitor* a process if we're done with it because otheriwse
        # the monitor will stay on and if the GenServer will eventually go down, we'll find
        # ourselves with a :DOWN message sitting in this process' mailbox. The :flush option
        # ensures that if the monitored process goes down while we call Process.demonitor/2,
        # then it will "eat" the :DOWN message. Essentially, calling Process.demonitor/2
        # with the :flush option makes sure there's no monitor and no leaked :DOWN messages.
        Process.demonitor(ref, [:flush])
        reply

      {:DOWN, ^ref, _, _, reason} ->
        exit(reason)
    after
      timeout -> exit({:timeout, timeout})
    end
  end

  ## Process loop

  defp loop(callback_module, state) do
    receive do
      {:"$genserver_cast", command} ->
        new_state = callback_module.handle_cast(command, state)
        loop(callback_module, new_state)

      {:"$genserver_call", ref, caller_pid, command} ->
        {reply, new_state} = callback_module.handle_call(command, state)
        send(caller_pid, {ref, reply})
        loop(callback_module, new_state)

      other ->
        new_state = callback_module.handle_info(other, state)
        loop(callback_module, new_state)
    end
  end
end
