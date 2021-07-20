defmodule Mate.MixProject do
  use Mix.Project

  def project do
    [
      app: :mate,
      version: "0.1.5",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      dialyzer: [
        plt_local_path: "priv/plts",
        plt_core_path: "priv/plts",
        plt_add_apps: [:mix]
      ],
      description: description(),
      package: package(),
      deps: deps(),
      name: "Mate",
      docs: [
        main: "overview",
        extra_section: "GUIDES",
        groups_for_extras: groups_for_extras(),
        groups_for_modules: groups_for_modules(),
        extras: extras()
      ],
      source_url: "https://github.com/maxvw/mate"
    ]
  end

  defp package() do
    [
      files: ~w(lib priv/run-wrapper.sh .formatter.exs mix.exs CHANGELOG* README* LICENSE*),
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
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end

  defp extras do
    [
      "guides/introduction/overview.md",
      "guides/introduction/getting_started.md",
      "guides/introduction/build_strategies.md",
      "guides/how_to/custom_driver.md",
      "guides/how_to/custom_steps.md"
    ]
  end

  defp groups_for_extras do
    [
      Introduction: ~r/guides\/introduction\/.?/,
      "How To's": ~r/guides\/how_to\/.?/
    ]
  end

  defp groups_for_modules do
    [
      Testing: [
        Mate.Driver.Test
      ],
      "Build Drivers": [
        Mate.Driver.SSH,
        Mate.Driver.Docker,
        Mate.Driver.Local
      ],
      "Available Steps": [
        Mate.Step.CleanBuild,
        Mate.Step.CopyToStorage,
        Mate.Step.LinkBuildSecrets,
        Mate.Step.MixCompile,
        Mate.Step.MixDeps,
        Mate.Step.MixDigest,
        Mate.Step.MixRelease,
        Mate.Step.NpmBuild,
        Mate.Step.NpmInstall,
        Mate.Step.PrepareSource,
        Mate.Step.SendGitCommit,
        Mate.Step.VerifyElixir,
        Mate.Step.VerifyGit,
        Mate.Step.VerifyNode,
        Mate.Step.CopyToDeployHost,
        Mate.Step.StartRelease,
        Mate.Step.StopRelease,
        Mate.Step.UnarchiveRelease
      ]
    ]
  end
end
