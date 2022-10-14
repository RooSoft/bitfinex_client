defmodule BitfinexClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :bitfinex_client,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.2", only: [:dev], runtime: false},
      {:websockex, "~> 0.4.3"},
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.4"}
    ]
  end
end
