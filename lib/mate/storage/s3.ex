defmodule Mate.Storage.S3 do
  @moduledoc """
  This S3 Storage module can be used to store your release archives in a
  S3 bucket. This does require the addition of `ex_aws` and `ex_aws_s3`
  in your `mix.exs` file, Mate does not have them as direct dependencies.

  ## How to use

  To add them update your `mix.exs` file with:

      def deps do
        [
          {:ex_aws, "~> 2.0", only: :dev},
          {:ex_aws_s3, "~> 2.0", only: :dev}
        ]
      end

  **NOTE** If you use ExAws in your own project, you can of course omit the
  `only: :dev` part here.

  Then configure your `.mate.exs` to use this module:

      config :mate,
        storage: Mate.Storage.S3,
        storage_opts: [
          bucket: "mate-releases",
          prefix: "my/prefix/"
        ],

  The `storage_opts` can also be used to set any `ex_aws` configuration you
  might want to change. It just forwards all values to `ExAws.Config.new(:s3, storage_opts)`

      storage_opts: [
        bucket: "mate-releases",
        prefix: "my/prefix/",
        region: "eu-east-1",
        access_key_id: System.fetch_env!("AWS_ACCESS_KEY"),
        secret_access_key: System.fetch_env!("AWS_SECRET_ACCESS_KEY")
      ],

  ## How does it work?
  It will create presigned requests for uploading or downloading on the local machine that
  runs `mate`, and then send them for upload/download using `cURL` on either the build server
  or the deploy servers.
  """
  alias Mate.Helpers
  use Mate.Storage

  @impl true
  def download(session, file) do
    with {:ok, signed_url} <- signed_url(:get, session, file) do
      Helpers.remote_cmd(session, "curl", ["-v", "-L", "-o", file, signed_url])
    else
      {:error, _} -> {:error, "Failed to download"}
    end
  end

  @impl true
  def upload(session, file) do
    with {:ok, signed_url} <- signed_url(:put, session, file) do
      Helpers.remote_cmd(session, "curl", ["-v", "--upload-file", file, signed_url])
    else
      {:error, _} -> {:error, "Failed to download"}
    end
  end

  defp signed_url(method, session, file) do
    bucket = config(session, :bucket)
    prefix = config(session, :prefix)
    path = Path.join(prefix, Path.basename(file))

    aws_config(session)
    |> ExAws.S3.presigned_url(method, bucket, path)
  end

  defp aws_config(%{config: %{storage_opts: aws_config}}) do
    ExAws.Config.new(:s3, aws_config)
  end

  defp config(%{config: %{storage_opts: config}}, key) do
    Keyword.get(config, key) ||
      Mix.raise("Looks like you forget to configure storage_opts.#{key}")
  end
end
