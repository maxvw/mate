# Storage Options
Mate comes with three different storage modules built-in, this guide tries to explain them in brief.

## Local (defaul)
The default storage module (`Mate.Storage.Local`) will store the final release archive on your local machine, and when deploying it will upload it from your local machine to all deploy servers. By default it stores the file in the project root, however you can customise this by configuring the `storage_opts` in your `.mate.exs` file.

      config :mate,
        storage: Mate.Storage.Local,
        storage_opts: [
          release_dir: "/path/to/dir"
        ]

## S3
The S3 storage modules  (`Mate.Storage.S3`) can be used to store your release archives in a S3 bucket. This uses `ex_aws` to communicate with AWS, which you can configure using `storage_opts` in your `.mate.exs` file. All settings will be forwarded to the `ex_aws` configuration so you can easily change anything.

The way it works is by generating presigned urls for both uploading and downloading, it will perform the actual upload to or download from S3 on the actual servers itself.

      config :mate,
        storage: Mate.Storage.S3,
        storage_opts: [
          bucket: "mate-releases",
          prefix: "my/prefix/",
          region: "eu-east-1",
          access_key_id: System.fetch_env!("AWS_ACCESS_KEY"),
          secret_access_key: System.fetch_env!("AWS_SECRET_ACCESS_KEY")
        ]

## BuildServer
The build server module (`Mate.Storage.BuildServer`) can be used to store the release archives on the build server itself. It is basically just a "local" copy, but it makes it more difficult to deploy the release archive to *other* deploy servers than itself. It's useful for example when for small hobby projects where you build and deploy to the same server, use mounted network storage across your servers or want to hand off the release archive to another script/application on the build server to continue the rest of deployment for you, just to name a few example use cases.

      config :mate,
        storage: Mate.Storage.BuildServer,
        storage_opts: [
          release_dir: "/path/to/releases/"
        ]

## Custom
You can also create your own strategy by [creating a custom storage module](how_to/custom_storage.md).
