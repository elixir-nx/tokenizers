defmodule Tokenizers.Model.Unigram do
  @typedoc """
  Options for model initialisation.

    * `:byte_fallback`- whether to use the byte fallback trick
    * `:unk_id`- the unknown token id to be used by the model

  """
  @type options() :: [
          byte_fallback: boolean(),
          unk_id: integer()
        ]

  @doc """
  Instantiate a Unigram model from the given vocab.
  """
  @spec init([{String.t(), number()}], options()) :: {:ok, Tokenizers.Model.t()}
  defdelegate init(vocab, options \\ []),
    to: Tokenizers.Native,
    as: :models_unigram_init

  @doc """
  Instantiate an empty Unigram model
  """
  @spec empty() :: {:ok, Tokenizers.Model.t()}
  defdelegate empty(), to: Tokenizers.Native, as: :models_unigram_empty
end
