# Mate
_Customisable Deployment for Elixir / Phoenix_

Elixir is fun to work with, releasing should be fun too. This project aims to help with that.

**NOTE** Documentation is one of the next things on my list.

## What about [edeliver](https://github.com/edeliver/edeliver)?
It's the inspiration behind this, but I wanted something that is compatible with `mix release`, something more customisable and a codebase that is better readable. This project aims to be that, but as it is still early if you are looking for something more stable, [edeliver](https://github.com/edeliver/edeliver) might still be the better choice – for now.

## Installation

```elixir
def deps do
  [
    {:mate, "~> 0.1.0", only: :dev}
  ]
end
```

- `$ mix deps.get
- `$ mix mate.init`

