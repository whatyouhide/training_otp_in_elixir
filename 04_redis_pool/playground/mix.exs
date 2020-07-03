defmodule Playground.MixProject do
  use Mix.Project

  def project do
    [
      app: :playground,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Playground.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:redis_pool, path: ".."}
    ]
  end
end
