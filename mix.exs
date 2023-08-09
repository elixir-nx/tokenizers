defmodule Tokenizers.MixProject do
  use Mix.Project

  @source_url "https://github.com/elixir-nx/tokenizers"
  @version "0.4.0-dev"

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
      extras: ["notebooks/pretrained.livemd", "notebooks/training.livemd", "LICENSE"],
      groups_for_modules: [
        Tokenization: [
          Tokenizers.Tokenizer,
          Tokenizers.Encoding,
          Tokenizers.Encoding.Transformation,
          Tokenizers.Decoder
        ],
        Pipeline: [
          Tokenizers.Normalizer,
          Tokenizers.PreTokenizer,
          Tokenizers.PostProcessor
        ],
        Training: [
          Tokenizers.Model,
          Tokenizers.Model.BPE,
          Tokenizers.Model.Unigram,
          Tokenizers.Model.WordLevel,
          Tokenizers.Model.WordPiece,
          Tokenizers.Trainer,
          Tokenizers.AddedToken
        ],
        Other: [
          Tokenizers.HTTPClient
        ]
      ],
      groups_for_functions: [
        # Tokenizers.Tokenizer
        Loading: &(&1[:type] == :loading),
        Inference: &(&1[:type] == :inference),
        Configuration: &(&1[:type] == :configuration),
        Training: &(&1[:type] == :training)
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
