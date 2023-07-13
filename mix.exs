defmodule Tokenizers.MixProject do
  use Mix.Project

  @source_url "https://github.com/elixir-nx/tokenizers"
  @version "0.13.0"

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
    [
      extra_applications: [:logger, :inets, :public_key]
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.3", only: [:test, :dev], runtime: false},
      {:castore, "~> 0.1 or ~> 1.0"},
      {:ex_doc, "~> 0.28", only: :docs, runtime: false},
      {:rustler, ">= 0.0.0", optional: true},
      {:rustler_precompiled, "~> 0.6"}
    ]
  end

  defp docs do
    [
      main: "Tokenizers",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["LICENSE", "notebooks/quicktour.livemd", "notebooks/pretrained.livemd"],
      groups_for_docs: [
        Creation: &(&1[:section] == :creators),
        Setup: &(&1[:section] == :setup),
        Inference: &(&1[:section] == :infer),
        Training: &(&1[:section] == :train)
      ],
      groups_for_modules: [
        Tokenization: [
          Tokenizers.Tokenizer,
          Tokenizers.Encoding
        ],
        Components: [
          Tokenizers.Decoder,
          Tokenizers.Normalizer,
          Tokenizers.PreTokenizer,
          Tokenizers.PostProcessor,
          Tokenizers.Trainer,
          Tokenizers.Model
        ],
        Models: [
          Tokenizers.Model.BPE,
          Tokenizers.Model.WordLevel,
          Tokenizers.Model.WordPiece,
          Tokenizers.Model.Unigram
        ]
      ]
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
