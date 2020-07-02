defmodule SharedStateTest do
  use ExUnit.Case

  test "start/1 + get/1" do
    pid = SharedState.start(_initial_state = 1)
    assert is_pid(pid)

    assert SharedState.get(pid) == 1
  end

  test "start/1 + update/2 + get/1" do
    pid = SharedState.start(_initial_state = 1)
    assert is_pid(pid)

    assert :ok = SharedState.update(pid, &(&1 + 1))

    assert SharedState.get(pid) == 2
  end

  test "update/2 executes the function in the state process" do
    test_pid = self()
    ref = make_ref()

    pid = SharedState.start(_initial_state = 1)

    assert :ok =
             SharedState.update(pid, fn state ->
               send(test_pid, {:update_called, ref, self()})
               state
             end)

    assert_receive {:update_called, ^ref, ^pid}
  end
end
