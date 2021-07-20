# Getting Started
This guide will briefly explain how to get started with using Mate. It assumes you already have an Elixir project and a build and/or deploy server that you can access via SSH.

## Installation
Mate is available via [https://hex.pm/packages/mate](hex.pm). Add `mate` to your dependencies in the `mix.exs` file, you only need it for `:dev` as you only use it to run locally from your machine.
```elixir
def deps do
  [
    {:mate, "~> 0.1.5", only: :dev}
  ]
end
```

After adding this to your `mix.exs` file, run `mix deps.get` to download it and then continue.

## First time configuration
All configuration will be stored in a file called `.mate.exs` and uses [the default Config syntax](https://hexdocs.pm/elixir/master/Config.html) from Elixir.

To get you started Mate includes a task to create your configuration file using `mix mate.init`. You can optionally pass it some arguments to change it for your usecase.

After running this command you should have a new `.mate.exs` file looking something like this:

```elixir
import Config

config :mate,
  otp_app: :my_app,
  module: MyApp

# This simple configuration will build and deploy to the same server
config :staging,
  server: "example.com",
  build_path: "/tmp/mate/my_app",
  release_path: "/opt/my_app",

# Specify secret files, if they are already present on your build server.
# config :staging,
#   build_secrets: %{
#     "prod.secret.exs" => "/mnt/secrets/prod.secret.exs"
#   }

# You can specify separate servers like this:
# config :production,
#   build_server: "build.example.com",
#   deploy_server: "www.example.com"

# For `deploy_server` you can also set a list like this:
# config :production,
#   deploy_server: [
#     "www1.example.com",
#     "www2.example.com"
#   ]
```

The main things to configure are the `server`, `build_path` and `release_path` values. If needed you can also configure your secret files by linking them to files already on the build server.

It is also possible to configure a separate `build_server` and `deploy_server`, the default `server` command expects them both to be the same value.

## First release
Running `mix mate.deploy` will start the build process, based on your configuration file. What exactly happens there can be changed with [custom steps](how_to/custom_steps.md). If something goes wrong Mate should return a useful error message, and if everything goes according to plan you should end up with a release tarball in your project directory.

After building your release Mate will prompt you if you want to deploy this release to the configured deploy servers, if you do this it will first copy the release tarball to all configured deploy servers, stop the current release (if any), unarchive the new release and start the new release.

## What's next?
Hopefully everything worked, so what's next depends on what you want. There are some customization options available, different build strategies, all of which are described in this documentation.
