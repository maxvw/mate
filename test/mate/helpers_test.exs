defmodule Mate.HelperTest do
  use ExUnit.Case, async: true
  alias Mate.Helpers
  alias Mate.Driver.Test, as: TestDriver

  setup do
    config = Mate.Config.read!("test/fixtures/config/basic_test_driver.exs")

    session =
      config
      |> Mate.Session.new(remote: Mate.Config.find_remote!(config, nil))
      |> TestDriver.sandbox()

    [session: session]
  end

  test "local_cmd/3 succeeds if exit code is 0", %{session: session} do
    assert {:ok, _} = Helpers.local_cmd(session, "bash", ["-c", "exit 0"])
  end

  test "local_cmd/3 trims stdout on success", %{session: session} do
    assert {:ok, "yes"} = Helpers.local_cmd(session, "bash", ["-c", "echo ' yes '"])
  end

  test "local_cmd/3 fails if exit code is not 0", %{session: session} do
    assert {:error, _} = Helpers.local_cmd(session, "bash", ["-c", "exit 1"])
  end

  test "local_script/2 succeeds if exit code is 0", %{session: session} do
    assert {:ok, _} =
             Helpers.local_script(session, """
             #!/usr/bin/env bash
             exit 0
             """)
  end

  test "local_script/2 trims stdout on success", %{session: session} do
    assert {:ok, "yes"} =
             Helpers.local_script(session, """
             #!/usr/bin/env bash
             echo " yes "
             exit 0
             """)
  end

  test "local_script/2 fails if exit code is not 0", %{session: session} do
    assert {:error, _} =
             Helpers.local_script(session, """
             #!/usr/bin/env bash
             exit 1
             """)
  end
end
