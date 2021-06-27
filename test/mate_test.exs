defmodule MateTest do
  use ExUnit.Case
  doctest Mate

  test "greets the world" do
    assert Mate.hello() == :world
  end
end
