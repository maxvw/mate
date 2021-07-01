defmodule Mate.MixProject do
  use Mix.Project

  def project do
    [
      app: :mate,
      version: "0.1.3",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      dialyzer: [plt_add_apps: [:mix]],
      description: description(),
      package: package(),
      deps: deps(),
      name: "Mate",
      docs: [
        main: "about",
        extras: [
          "README.md": [filename: "about", title: "About Mate"]
        ]
      ],
      source_url: "https://github.com/maxvw/mate"
    ]
  end

  defp package() do
    [
      files: ~w(lib priv .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/maxvw/mate"}
    ]
  end

  defp description() do
    "Customisable Deployment for Elixir / Phoenix"
  end

  def application do
    [
      extra_applications: [:logger, :eex, :crypto]
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end
end
