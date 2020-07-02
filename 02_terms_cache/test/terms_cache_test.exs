defmodule TermsCacheTest do
  use ExUnit.Case

  @tag :skip
  test "put + get" do
    {:ok, _pid} = TermsCache.start_link(_opts = [])

    assert :ok = TermsCache.put(:andrea, "Andrea Leopardi")

    assert TermsCache.get(:andrea) == "Andrea Leopardi"
    assert TermsCache.get(:jose) == nil
  end

  @tag :skip
  test "put with TTL" do
    {:ok, _pid} = TermsCache.start_link(_opts = [])
    key = :erlang.md5("https://elixir-lang.org")
    value = :crypto.strong_rand_bytes(100)

    assert :ok = TermsCache.put(key, value, 3000)

    assert TermsCache.get(key) == value

    Process.sleep(5_500)

    assert TermsCache.get(key) == nil
  end
end
