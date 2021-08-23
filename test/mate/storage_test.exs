defmodule Mate.StorageTests do
  use ExUnit.Case, async: true
  alias Mate.Storage.S3
  alias Mate.Storage.Local, as: LocalStorage
  alias Mate.Storage.BuildServer, as: BuildStorage

  describe "Mate.Storage.S3" do
    setup do
      config = Mate.Config.read!("test/fixtures/config/storage_s3.exs")

      session =
        config
        |> Mate.Session.new(remote: Mate.Config.find_remote!(config, nil))

      [session: session]
    end

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

  describe "Mate.Storage.Local" do
    setup do
      config = Mate.Config.read!("test/fixtures/config/storage_local.exs")

      session =
        config
        |> Mate.Session.new(remote: Mate.Config.find_remote!(config, nil))

      # Prepare storage so the file is available for download tests
      file = Path.expand("test/fixtures/release.tar.gz")
      File.mkdir_p("tmp/archives/local")
      File.copy(file, "tmp/archives/local/release.tar.gz")

      [session: session]
    end

    test "uploads release archive to LocalStorage", %{session: session} do
      file = Path.expand("test/fixtures/release.tar.gz")
      assert {:ok, _} = LocalStorage.upload(session, file)
      assert File.exists?("tmp/archives/local/release.tar.gz")
    end

    test "downloads release archive from LocalStorage", %{session: session} do
      File.mkdir_p("tmp/storage")
      file = Path.expand("tmp/storage/release.tar.gz")
      assert {:ok, _} = LocalStorage.download(session, file)
      assert File.exists?(file)
    end
  end

  describe "Mate.Storage.BuildServer" do
    setup do
      config = Mate.Config.read!("test/fixtures/config/storage_build.exs")

      session =
        config
        |> Mate.Session.new(remote: Mate.Config.find_remote!(config, nil))

      # Prepare storage so the file is available for download tests
      file = Path.expand("test/fixtures/release.tar.gz")
      File.mkdir_p("tmp/archives/build")
      File.copy(file, "tmp/archives/build/release.tar.gz")

      [session: session]
    end

    test "uploads release archive to BuildStorage", %{session: session} do
      file = Path.expand("test/fixtures/release.tar.gz")
      assert {:ok, _} = BuildStorage.upload(session, file)
      assert File.exists?("tmp/archives/build/release.tar.gz")
    end

    test "downloads release archive from BuildStorage", %{session: session} do
      File.mkdir_p("tmp/storage")
      file = Path.expand("tmp/storage/release.tar.gz")
      assert {:ok, _} = BuildStorage.download(session, file)
      assert File.exists?(file)
    end
  end
end
