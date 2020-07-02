defmodule Async do
  ## With reply

  def execute_async(fun) do
    caller = self()
    ref = make_ref()

    spawn(fn ->
      result = fun.()
      send(caller, {ref, result})
    end)

    ref
  end

  def await_result(ref) do
    receive do
      {^ref, result} -> result
    end
  end

  # If we add :infinity as the default timeout, we don't need await_result/1 anymore.
  def await_result(ref, timeout) do
    receive do
      {^ref, result} -> {:ok, result}
    after
      timeout -> :timeout
    end
  end

  # We need to start returning {pid, ref} instead of just ref.
  def await_or_kill({pid, ref}, timeout) do
    receive do
      {^ref, result} -> {:ok, result}
    after
      timeout ->
        # Race condition: what if the task sent the message before being killed?
        Process.exit(pid, :kill)
        :killed
    end
  end

  def execute_async_with_monitor(fun) do
    caller = self()
    ref = make_ref()

    {pid, monitor_ref} =
      spawn_monitor(fn ->
        result = fun.()
        send(caller, {ref, result})
      end)

    {pid, ref, monitor_ref}
  end

  def await_or_kill_with_monitor({pid, ref, monitor_ref}, timeout) do
    receive do
      {^ref, result} ->
        Process.demonitor(monitor_ref, [:flush])
        {:ok, result}

      {:DOWN, ^monitor_ref, _, _, reason} ->
        {:error, reason}
    after
      timeout ->
        # We have to wait for the :DOWN message too here...
        Process.exit(pid, :kill)
        :killed
    end
  end
end
