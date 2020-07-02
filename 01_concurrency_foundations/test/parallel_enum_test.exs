defmodule ParallelEnumTest do
  use ExUnit.Case

  @tag :skip
  test "each/2" do
    test_pid = self()
    ref = make_ref()

    ParallelEnum.each(1..5, fn item ->
      send(test_pid, {ref, self(), item})
    end)

    pids =
      for expected_item <- 1..5, into: MapSet.new() do
        assert_receive {^ref, spawned_pid, ^expected_item}
        spawned_pid
      end

    assert MapSet.size(pids) == 5
  end

  @tag :skip
  test "map/2" do
    pids_and_items =
      ParallelEnum.map(1..5, fn item ->
        {self(), item}
      end)

    {pids, items} = Enum.unzip(pids_and_items)

    assert pids |> MapSet.new() |> MapSet.size() == 5

    assert Enum.sort(items) == Enum.sort(1..5)
  end
end
