# Mate
_Customisable Deployment for Elixir / Phoenix_

[![Hex pm](http://img.shields.io/hexpm/v/mate.svg?style=flat)](https://hex.pm/packages/mate)
[![License](http://img.shields.io/hexpm/l/mate.svg?style=flat)](https://github.com/maxvw/mate/blob/main/LICENSE.md)
[![GitHub Actions](https://img.shields.io/github/workflow/status/maxvw/mate/tests)](https://github.com/maxvw/mate/actions)

Elixir is fun to work with, releasing should be fun too. This project aims to help with that.

You can choose to build your release remotely via SSH, locally via Docker or just locally in general. Of course when building locally remember that the system architecture should match with your deploy servers. After building your application, you can also deploy it to one or multiple servers over an SSH connection.

## What about [edeliver](https://github.com/edeliver/edeliver)?
It's the inspiration behind this, but I wanted something that is compatible with `mix release`, something more customisable and a codebase that is better readable. This project aims to be that, but as it is still early if you are looking for something more stable, [edeliver](https://github.com/edeliver/edeliver) might still be the better choice – for now.

## Documentation
The documentation for `mate` can be found on [hexdocs.pm/mate](https://hexdocs.pm/mate/).

## Installation
`mate` is available via [https://hex.pm/packages/mate](hex.pm). Just add `mate` to your dependencies in the `mix.exs` file, you only need it for `:dev` as you run it locally from your machine.
```elixir
def deps do
  [
    {:mate, "~> 0.1.7", only: :dev}
  ]
end
```

Then you can get the latest dependencies and use `mix mate.init` to get started!
- `$ mix deps.get`
- `$ mix mate.init`

## Why is it called Mate?
Naming is hard and I wanted something short. Most deployment software seems to stick to a nautical theme with their naming, so I ended up with mate. But I am open to other suggestions while the project is still in it's early beginnings.
