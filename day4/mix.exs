defmodule Day4.MixProject do
  use Mix.Project

  def project do
    [
      app: :day4,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      escript: [main_module: Day4],
      deps: []
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end
end
