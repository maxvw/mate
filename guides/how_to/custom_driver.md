# Custom Driver Module
Mate by default ships with four driver modules; `Mate.Driver.SSH`, `Mate.Driver.Docker`, `Mate.Driver.Local` and finally `Mate.Driver.Test` which is used for testing.

All code that is executed for building and copying the release tarball will be executed through the driver, deployments also happen through the driver but those will always be done via the `Mate.Driver.SSH` driver currently. For SSH this means it will maintain an active SSH connection and execute command and scripts over this active connection, for Docker it means it will start a new Docker container and keep it alive to execute commands and scripts, and locally just performs these steps on your local machine.

If the default options don't suffice for your usecase, you can make your own!

## The Driver Behaviour
A driver should use the `Mate.Driver` behaviour, the documentation for that module explains all available functions.

It can store the current connection after `start/2` inside the `Mate.Session` as the `conn` property. The `Mate.Session` object will be passed along for every function so you can reference it, and pass data between steps by using `assigns` on the `Mate.Session`.
