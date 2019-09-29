defmodule SignalTower.Mixfile do
  use Mix.Project

  def project do
    [
      app: :signal_tower,
      version: "1.0.1",
      elixir: "~> 1.7",
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      mod: { SignalTower, [] },
      applications: [:logger, :cowboy, :poison]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:cowboy, "~> 2.6.0"},
      {:poison, "~> 4.0.1"}
    ]
  end
end
