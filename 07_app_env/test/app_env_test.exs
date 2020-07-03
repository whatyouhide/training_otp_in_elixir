defmodule AppEnvTest do
  use ExUnit.Case
  doctest AppEnv

  test "greets the world" do
    assert AppEnv.hello() == :world
  end
end
