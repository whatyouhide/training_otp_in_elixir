defmodule RedisPoolTest do
  use ExUnit.Case

  test "starting and using the pool", context do
    assert {:ok, sup} = RedisPool.start_link(name: context.test)
    assert is_pid(sup)

    assert RedisPool.command(context.test, ["PING"]) == {:ok, "PONG"}
  end

  test "with two connections, requests are routed at random", context do
    assert {:ok, sup} = RedisPool.start_link(name: context.test, connections: 2)
    assert is_pid(sup)

    # If we request the client ID of the connected client 200 times, it's *very* unlikely
    # that we'll only go through one connection so it's Good Enough™ for this test.
    client_ids =
      for _ <- 1..200, into: MapSet.new() do
        assert {:ok, client_id} = RedisPool.command(context.test, ["CLIENT", "ID"])
        client_id
      end

    assert MapSet.size(client_ids) == 2
  end
end
