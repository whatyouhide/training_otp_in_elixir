defmodule AsyncTest do
  use ExUnit.Case

  test "execute_async/1 + await_result/1" do
    start_time = System.monotonic_time(:millisecond)

    task =
      Async.execute_async(fn ->
        Process.sleep(500)
        :i_slept_for_half_second
      end)

    assert Async.await_result(task) == :i_slept_for_half_second

    assert System.monotonic_time(:millisecond) - start_time >= 500
  end

  test "execute_async/1 + await_result/2 (with timeout)" do
    task =
      Async.execute_async(fn ->
        Process.sleep(500)
        :i_slept_for_half_second
      end)

    assert Async.await_result(task, 100) == :timeout
  end

  test "execute_async/1 + await_or_kill/2" do
    task =
      Async.execute_async(fn ->
        Process.sleep(500)
        :i_slept_for_half_second
      end)

    assert Async.await_or_kill(task, 100) == :killed
  end

  test "execute_async_with_monitor/1 + await_or_kill_with_monitor/2" do
    successful_task =
      Async.execute_async_with_monitor(fn ->
        :i_returned
      end)

    assert Async.await_or_kill_with_monitor(successful_task, 100) == {:ok, :i_returned}

    crashing_task =
      Async.execute_async_with_monitor(fn ->
        exit(:crashed)
      end)

    assert {:error, :crashed} = Async.await_or_kill_with_monitor(crashing_task, 100)

    timeout_task =
      Async.execute_async_with_monitor(fn ->
        Process.sleep(500)
        :i_slept_for_half_second
      end)

    assert Async.await_or_kill_with_monitor(timeout_task, 100) == :killed
  end
end
