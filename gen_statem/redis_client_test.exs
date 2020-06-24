Code.require_file("redis_client.ex", __DIR__)

ExUnit.start()

defmodule RedisClientTest do
  use ExUnit.Case

  test "start connection and PING" do
    assert {:ok, conn} = RedisClient.start_link(host: "localhost", port: 6379)

    assert RedisClient.command(conn, ["PING"]) == {:ok, "PONG"}
  end

  test "GET + SET" do
    assert {:ok, conn} = RedisClient.start_link(host: "localhost", port: 6379)

    assert RedisClient.command(conn, ["SET", "mykey", "myvalue"]) == {:ok, "OK"}
    assert RedisClient.command(conn, ["GET", "mykey"]) == {:ok, "myvalue"}
  end
end
