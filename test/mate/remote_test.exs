defmodule Mate.RemoteTest do
  use ExUnit.Case, async: true
  alias Mate.Remote

  test "new/1 creates a new Remote" do
    remote =
      Remote.new(:staging, %{
        server: "example.com",
        build_path: "/build/app",
        release_path: "/release/app"
      })

    assert remote.id == :staging
  end

  test "new/1 raises when missing server config" do
    assert_raise Mix.Error, fn ->
      Remote.new(:staging, %{
        build_path: "/build/app",
        release_path: "/release/app"
      })
    end
  end

  test "new/1 raises when missing deploy_server" do
    assert_raise Mix.Error, fn ->
      Remote.new(:staging, %{
        build_server: "build.example.com",
        build_path: "/build/app",
        release_path: "/release/app"
      })
    end
  end

  test "new/1 raises when missing build_server" do
    assert_raise Mix.Error, fn ->
      Remote.new(:staging, %{
        deploy_server: "deploy.example.com",
        build_path: "/build/app",
        release_path: "/release/app"
      })
    end
  end

  test "new/1 raises when missing build_path" do
    assert_raise Mix.Error, fn ->
      Remote.new(:staging, %{
        server: "example.com",
        release_path: "/release/app"
      })
    end
  end

  test "new/1 raises when missing release_path" do
    assert_raise Mix.Error, fn ->
      Remote.new(:staging, %{
        server: "example.com",
        build_path: "/build/app"
      })
    end
  end
end
