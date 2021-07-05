defmodule Mate.UtilsTest do
  use ExUnit.Case, async: true
  doctest Mate.Utils, except: [random_id: 0, random_id: 1]

  test "module/0 returns namespace module if set" do
    Application.put_env(:mate, :namespace, MyExample)
    assert "MyExample" == Mate.Utils.module()
    Application.delete_env(:mate, :namespace)
  end

  test "random_id/0 returns random value of 32 characters" do
    assert Regex.match?(~r/^[A-Z0-9]{32}$/, Mate.Utils.random_id())
  end

  test "random_id/1 returns random value of given length" do
    assert Regex.match?(~r/^[A-Z0-9]{6}$/, Mate.Utils.random_id(6))
  end

  test "random_id value is always different (sample size 1000)" do
    random_ids = Enum.map(1..1000, fn _ -> Mate.Utils.random_id(6) end)
    unique_random_ids = random_ids |> Enum.uniq()
    assert length(random_ids) == length(unique_random_ids)
  end
end
