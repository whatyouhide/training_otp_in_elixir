defmodule ETSTermsCacheTest do
  use ExUnit.Case

  @tag :skip
  test "put + get" do
    {:ok, _pid} = ETSTermsCache.start_link(_opts = [])

    assert :ok = ETSTermsCache.put(:andrea, "Andrea Leopardi")

    assert ETSTermsCache.get(:andrea) == "Andrea Leopardi"
    assert ETSTermsCache.get(:jose) == nil
  end

  @tag :skip
  test "put with TTL" do
    {:ok, _pid} = ETSTermsCache.start_link(_opts = [])
    key = :erlang.md5("https://elixir-lang.org")
    value = :crypto.strong_rand_bytes(100)

    assert :ok = ETSTermsCache.put(key, value, 3000)

    assert ETSTermsCache.get(key) == value

    Process.sleep(5_500)

    assert ETSTermsCache.get(key) == nil
  end
end
