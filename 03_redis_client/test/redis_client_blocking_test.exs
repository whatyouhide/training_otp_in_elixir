defmodule RedisClientBlockingTest do
  use ExUnit.Case

  test "start connection and PING" do
    assert {:ok, conn} = RedisClientBlocking.start_link(host: "localhost", port: 6379)

    assert RedisClientBlocking.command(conn, ["PING"]) == "PONG"
  end

  test "GET + SET" do
    assert {:ok, conn} = RedisClientBlocking.start_link(host: "localhost", port: 6379)

    assert RedisClientBlocking.command(conn, ["SET", "mykey", "myvalue"]) == "OK"
    assert RedisClientBlocking.command(conn, ["GET", "mykey"]) == "myvalue"
  end
end
