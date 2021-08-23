# Overview
Mate is a library you can add to your Elixir/Phoenix project to help you build it on remote servers via SSH, on Docker Images or just on your local machine. It is compareable to [edeliver](https://github.com/edeliver/edeliver) but actually written in Elixir instead of many, many Bash scripts. This enables you to create [custom drivers](how_to/custom_driver.md) for [build strategies](introduction/build_strategies.md) if the built-in ones (ssh, docker, local) are not enough, or [custom steps](how_to/custom_steps.md) if you want to perform additional commands while building your application.

By default it will use [mix release](https://hexdocs.pm/mix/Mix.Tasks.Release.html), which is available since Elixir 1.9. But using it with something like [distillery](https://hexdocs.pm/distillery) should be fairly trivial and potentially support for this will be built-in to Mate in the near future.

## How does it work?
By default it will run the built-in steps for a standard Elixir application, if `assets/package.json` exists it will also run additional steps to install the dependencies and run the deploy and digest scripts for that as well.

It does this on a clean copy of your current Git commit, if you have any (un)staged files that are not yet committed they will _not_ be included in the release. Any secrets should be available in your build environment and can be symlinked via the configuration file.

Based on your [configured build strategy](introduction/build_strategies.md) it will run the build steps on either a remote server via SSH, using a Docker image or on your local machine directly. Make sure you choose the right one because you can't compile cross-platform or cross-arch.

The result of the build should be a tarball (`tar.gz`) that ends up in a `Mate.Storage` option of your choice, by default is uses `Mate.Storage.Local` which is just your project root on your local machine. Although you can configure a different directory as well. The other included storage modules are `Mate.Storage.S3` and `Mate.Storage.BuildServer` to store on either S3 (using `ex_aws`) or the build server where you build the release. It is also possible to [write your own `Mate.Storage` module for any other storage needs](how_to/custom_steps.md).

With `mix mate.deploy` it will also ask you if you want to deploy your newly built release. This will be sent to all configured deploy servers via ssh and automatically (re)started. This is optional.

Want to try it out? [Continue to Get Started](introduction/getting_started.md)
