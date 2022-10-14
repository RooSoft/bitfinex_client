defmodule BitfinexClient.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :bitfinex_client,
      version: @version,
      description: "Gets realtime BTCUSD prices from Bitfinex",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp docs do
    [
      # The main page in the docs
      main: "BitfinexClient",
      source_ref: @version,
      source_url: "https://github.com/RooSoft/bitfinex_client"
    ]
  end

  def package do
    [
      maintainers: ["Marc Lacoursière"],
      licenses: ["Unlicence"],
      links: %{"GitHub" => "https://github.com/RooSoft/bitfinex_client"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:dialyxir, "~> 1.2", only: [:dev], runtime: false},
      {:websockex, "~> 0.4.3"},
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.4"}
    ]
  end
end
