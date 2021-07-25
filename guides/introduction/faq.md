# F.A.Q.

## Does it work with distillery?
Out of the box no, but perhaps you could make this work by building one ore more [custom steps](how_to/custom_steps.md) and replacing the default `Mate.Step.MixRelease` step.

## Does it support appups?
Out of the box no, but perhaps you could make this work by building one ore more [custom steps](how_to/custom_steps.md).

## Does it support auto-versioning?
Currently no, but this might be interesting to add for the future.

## Can it help create a Docker container?
By itself no, you could maybe do something with a `Dockerfile` and using the `Local` driver but if your end goal is to create a docker image you might not even need Mate.
