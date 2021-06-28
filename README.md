# Mate
_Customisable Deployment for Elixir / Phoenix_
---

Elixir is fun to work with, releasing should be fun too. This project aims to help with that.

**NOTE** Documentation is one of the next things on my list.

## What about [edeliver](https://github.com/edeliver/edeliver)?
It's the inspiration behind this, but I wanted something that is compatible with `mix release`, something more customisable and a codebase that is better readable. This project aims to be that, but as it is still early if you are looking for something more stable, [edeliver](https://github.com/edeliver/edeliver) might still be the better choice – for now.

## Documentation
The documentation for `mate` can be found on [hexdocs.pm/mate](https://hexdocs.pm/mate/).

## Installation
Add `mate` to your dependencies in the `mix.exs` file, you only need it for `:dev` as you run it locally from your machine.
```elixir
def deps do
  [
    {:mate, "~> 0.1.1", only: :dev}
  ]
end
```

Then you can get the latest dependencies and use `mix mate.init` to get started!
- `$ mix deps.get`
- `$ mix mate.init`

## Why is it called Mate?
Naming is hard and I wanted something short. Most deployment software seems to stick to a nautical theme with their naming, so I ended up with mate.
