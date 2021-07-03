defmodule Mate.ConfigTest do
  use ExUnit.Case

  test "raises when file does not exist" do
    assert_raise File.Error, fn ->
      Mate.Config.read!("test/fixtures/config/does-not-exist.exs")
    end
  end

  test "parses basic config" do
    config = config(:basic)

    assert config.driver == Mate.Driver.SSH
    assert config.driver_opts == []
    assert config.mix_env == :prod
    assert config.otp_app == :example
    assert config.module == Example
    assert config.steps == Mate.Pipeline.default_steps()

    assert config.clean_paths == ~w{_build rel priv/generated priv/static},
           assert(
             [
               %Mate.Remote{
                 id: :staging,
                 server: "example.com",
                 build_server: "example.com",
                 deploy_server: ["example.com"],
                 build_path: "/tmp/mate/example",
                 release_path: "/opt/example",
                 build_secrets: %{}
               }
             ] = config.remotes
           )
  end

  test "parses config with build secrets" do
    remote = remote(:basic_with_secret)
    assert remote.build_secrets["prod.secret.exs"] == "/path/to/secrets/prod.secret.exs"
  end

  test "parses config with separate build and deploy server" do
    remote = remote(:basic_with_different_servers)
    assert remote.build_server == "build.example.com"
    assert remote.deploy_server == ["www.example.com"]
  end

  test "parses config with multiple deploy server" do
    remote = remote(:basic_with_multiple_deploy_servers)
    assert remote.deploy_server == ["www1.example.com", "www2.example.com"]
  end

  test "parses config with custom steps (list)" do
    config = config(:basic_custom_steps)
    assert config.steps == [Mate.Step.VerifyElixir]
  end

  test "parses config with custom steps (fun/1)" do
    config = config(:basic_custom_steps_fn)
    default_steps = Mate.Pipeline.default_steps()
    assert config.steps == [MyStep | default_steps]
  end

  test "parses config with custom steps (fun/2)" do
    config = config(:basic_custom_steps_fn2)

    custom_steps =
      Mate.Pipeline.default_steps()
      |> Mate.Pipeline.insert_before(Mate.Step.CleanBuild, MyStep)

    assert config.steps == custom_steps
  end

  test "raises on invalid custom steps arity" do
    assert_raise Mix.Error, fn ->
      config(:invalid_custom_steps_fn)
    end
  end

  test "find_remote/2 returns :ok tuple if the remote exists" do
    config = config(:basic)
    assert {:ok, %Mate.Remote{}} = Mate.Config.find_remote(config, "staging")
  end

  test "find_remote/2 returns :error tuple when it cannot find the remote" do
    config = config(:basic)
    assert {:error, :not_found} = Mate.Config.find_remote(config, "production")
  end

  test "find_remote!/2 returns the remote if it exists" do
    config = config(:basic_multiple_remotes)
    assert %Mate.Remote{} = Mate.Config.find_remote!(config, "production")
  end

  test "find_remote!/2 returns the first found remote when no query specified" do
    config = config(:basic_multiple_remotes)
    assert %Mate.Remote{id: :staging} = Mate.Config.find_remote!(config, nil)
  end

  test "find_remote!/2 raises when it can't find the remote" do
    config = config(:basic)

    assert_raise Mix.Error, fn ->
      Mate.Config.find_remote!(config, "production")
    end
  end

  test "find_remote!/2 raises when there are no remotes defined" do
    config = config(:missing_remotes)

    assert_raise Mix.Error, fn ->
      Mate.Config.find_remote!(config, "production")
    end
  end

  test "raises when remote missing build_server" do
    assert_raise Mix.Error, fn ->
      remote(:missing_build_server)
    end
  end

  test "raises when remote missing deploy_server" do
    assert_raise Mix.Error, fn ->
      remote(:missing_deploy_server)
    end
  end

  test "raises when remote missing build_path" do
    assert_raise Mix.Error, fn ->
      remote(:missing_build_path)
    end
  end

  test "raises when remote missing release_path" do
    assert_raise Mix.Error, fn ->
      remote(:missing_release_path)
    end
  end

  defp config(type) do
    Mate.Config.read!("test/fixtures/config/#{type}.exs")
  end

  defp remote(type) do
    config(type).remotes |> List.first()
  end
end
