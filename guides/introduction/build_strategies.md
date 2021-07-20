# Build Strategies
Mate comes with three different build strategies built-in, this guide tries to explain them in brief.

For all strategies it is important to note that releases are not made to be cross platform or architecture e.g. Building on arm and running om amd64 is not possible, just like building on MacOS and deploying to a Debian server won't work.

Using the SSH strategy and a build server that is as closely similar to your deployment servers as possible is the recommended route. But there are plenty of valid reasons to want to use one of the other strategies. It is also possible to create your own strategy entirely by creating a [custom driver](how_to/custom_driver.md).

## SSH (default)
The default strategy is to build your application on a remote server via an SSH connection. First it will push the current commit to the build server via SSH, then it will connect to the SSH server once and keep the connection open to send commands and eventually download the release tarball, if everything went according to plan.

This is probably the most common usecase, where you use a build server to prepare the release before you start deploying it to your actual server(s).

## Docker
The Docker strategy can be used to build your application inside of a Docker container, it works mostly the same as SSH except it will use the Docker command line client start a new container, mounted to the project directory to then copy the latest commit and create the build in there until finally the release tarball is copied to your local disk.

An important distinction here is that the resulting file is not a Docker image, if this is what you want it is recommended to use a `Dockerfile`.

## Local
The Local strategy can be used to run all the build steps on your local machine. There isn't really much added benefit to this over running the commands yourself directly, besides ensuring it is run on a clean copy of the latest commit and you just type one command instead of multiple.

It is only useful if you will deploy your application on a similar platform/architecture as your local machine.

## Custom
You can create your own strategy as well by [creating a custom driver](how_to/custom_driver.md).
