defmodule BlueStar.MixProject do
  use Mix.Project

  def project do
    [
      app: :blue_star,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:crypto, :logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.4"},
      {:floki, "~> 0.34.0", only: :test}
    ]
  end
end
