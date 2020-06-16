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
  def await_result(ref, timeout \\ :infinity) do
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
end
