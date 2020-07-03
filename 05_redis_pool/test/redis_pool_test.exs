defmodule RedisPoolTest do
  use ExUnit.Case

  test "starting and using the pool" do
    assert {:ok, sup} = RedisPool.start_link(name: MyPool)
    assert is_pid(sup)

    assert Redix.command(RedisPool.connection(MyPool), ["PING"]) == {:ok, "PONG"}
  end
end
