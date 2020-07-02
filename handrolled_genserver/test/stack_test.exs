defmodule HandrolledGenserverTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  test "start_link + push + pop" do
    {:ok, pid} = Stack.start_link([])

    assert Stack.push(pid, 1) == :ok
    assert Stack.push(pid, 2) == :ok
    assert Stack.push(pid, 3) == :ok

    assert Stack.pop(pid) == 3
    assert Stack.pop(pid) == 2
  end

  test "sending an unknown message to the stack process logs an errors" do
    {:ok, pid} = Stack.start_link([])

    log =
      capture_log(fn ->
        send(pid, :unknown_message)
        Process.sleep(100)
      end)

    assert log =~ "Received unknown message: :unknown_message"
  end
end
