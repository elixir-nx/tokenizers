defmodule Tokenizers.MixProject do
  use Mix.Project

  @source_url "https://github.com/elixir-nx/tokenizers"
  @version "0.1.0-dev"

  def project do
    [
      app: :tokenizers,
      name: "Tokenizers",
      version: @version,
      elixir: "~> 1.13",
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.28", only: :dev, runtime: false},
      {:nx, "~> 0.1"},
      {:rustler, "~> 0.23"}
    ]
  end

  defp docs do
    [
      main: "Tokenizers",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end
