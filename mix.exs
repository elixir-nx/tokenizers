defmodule Tokenizers.MixProject do
  use Mix.Project

  @source_url "https://github.com/elixir-nx/tokenizers"
  @version "0.1.1"

  def project do
    [
      app: :tokenizers,
      name: "Tokenizers",
      description: "Bindings to Hugging Face Tokenizers for Elixir",
      version: @version,
      elixir: "~> 1.13",
      package: package(),
      deps: deps(),
      docs: docs(),
      preferred_cli_env: [
        docs: :docs,
        "hex.publish": :docs
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.28", only: :docs, runtime: false},
      {:rustler, ">= 0.0.0", optional: true},
      {:rustler_precompiled, "~> 0.5"}
    ]
  end

  defp docs do
    [
      main: "Tokenizers",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["LICENSE", "notebooks/pretrained.livemd"]
    ]
  end

  defp package do
    [
      files: [
        "lib",
        "native",
        "checksum-*.exs",
        "mix.exs",
        "LICENSE"
      ],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url},
      maintainers: ["Christopher Grainger"]
    ]
  end
end
