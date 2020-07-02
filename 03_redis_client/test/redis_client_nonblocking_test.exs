defmodule RedisClientNonblockingTest do
  use ExUnit.Case

  test "start connection and PING" do
    assert {:ok, conn} = RedisClientNonblocking.start_link(host: "localhost", port: 6379)

    assert RedisClientNonblocking.command(conn, ["PING"]) == "PONG"
  end

  test "GET + SET" do
    assert {:ok, conn} = RedisClientNonblocking.start_link(host: "localhost", port: 6379)

    assert RedisClientNonblocking.command(conn, ["SET", "mykey", "myvalue"]) == "OK"
    assert RedisClientNonblocking.command(conn, ["GET", "mykey"]) == "myvalue"
  end
end
