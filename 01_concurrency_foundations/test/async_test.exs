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
end
