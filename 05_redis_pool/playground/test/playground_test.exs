defmodule PlaygroundTest do
  use ExUnit.Case
  doctest Playground

  test "greets the world" do
    assert Playground.hello() == :world
  end
end
