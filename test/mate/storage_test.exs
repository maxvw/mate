defmodule Mate.StorageTests do
  use ExUnit.Case, async: true
  alias Mate.Storage.S3

  setup do
    config = Mate.Config.read!("test/fixtures/config/storage_s3.exs")

    session =
      config
      |> Mate.Session.new(remote: Mate.Config.find_remote!(config, nil))

    [session: session]
  end

  describe "Mate.Storage.S3" do
    test "uploads release archive to S3", %{session: session} do
      file = Path.expand("test/fixtures/release.tar.gz")
      assert {:ok, _} = S3.upload(session, file)
    end

    test "downloads release archive from S3", %{session: session} do
      file = Path.expand("downloaded.tar.gz")
      assert {:ok, _} = S3.download(session, file)
      assert File.exists?(file)
      File.rm(file)
    end
  end
end
