defmodule HandrolledSupervisorTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  defmodule Counter do
    use Agent

    def start_link(opts) do
      {initial_value, opts} = Keyword.pop!(opts, :initial_value)
      Agent.start_link(fn -> initial_value end, opts)
    end
  end

  test "starts a few children" do
    children = [
      {Counter, initial_value: 1, name: :small_counter},
      {Counter, initial_value: 10, name: :medium_counter},
      {Counter, initial_value: 100, name: :large_counter}
    ]

    assert {:ok, sup} = HandrolledSupervisor.start_link(children)
    assert is_pid(sup)

    assert Agent.get(:small_counter, & &1) == 1
    assert Agent.get(:medium_counter, & &1) == 10
    assert Agent.get(:large_counter, & &1) == 100

    assert :ok = Agent.update(:medium_counter, &(&1 + 1))

    assert Agent.get(:medium_counter, & &1) == 11

    capture_log(fn ->
      assert :ok = Agent.cast(:medium_counter, fn _state -> exit(:oops) end)
      Process.sleep(100)
    end)

    assert :medium_counter |> Process.whereis() |> Process.alive?()

    assert Agent.get(:medium_counter, & &1) == 10
  end
end
