defmodule RedisClientGenStatemTest do
  use ExUnit.Case

  test "start connection and PING" do
    assert {:ok, conn} = RedisClientGenStatem.start_link(host: "localhost", port: 6379)

    assert RedisClientGenStatem.command(conn, ["PING"]) == {:ok, "PONG"}
  end

  test "GET + SET" do
    assert {:ok, conn} = RedisClientGenStatem.start_link(host: "localhost", port: 6379)

    assert RedisClientGenStatem.command(conn, ["SET", "mykey", "myvalue"]) == {:ok, "OK"}
    assert RedisClientGenStatem.command(conn, ["GET", "mykey"]) == {:ok, "myvalue"}
  end
end
