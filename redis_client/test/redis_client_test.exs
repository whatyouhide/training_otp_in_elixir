defmodule RedisClientTest do
  use ExUnit.Case

  alias RedisClientNonblocking, as: RedisClient

  test "start connection and PING" do
    assert {:ok, conn} = RedisClient.start_link(host: "localhost", port: 6379)

    assert RedisClient.command(conn, ["PING"]) == "PONG"
  end

  test "GET + SET" do
    assert {:ok, conn} = RedisClient.start_link(host: "localhost", port: 6379)

    assert RedisClient.command(conn, ["SET", "mykey", "myvalue"]) == "OK"
    assert RedisClient.command(conn, ["GET", "mykey"]) == "myvalue"
  end
end
