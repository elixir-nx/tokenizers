defmodule Tokenizers.Model.BPE do
  @typedoc """
  Options for model initialisation.

    * `:byte_fallback`- whether to use the byte fallback trick

    * `:cache_capacity` - the number of words that the BPE cache can
      contain. The cache allows to speed-up the process by keeping
      the result of the merge operations for a number of words.
      Defaults to `10_000`

    * `:dropout` - The BPE dropout to use. Must be an float between
      0 and 1

    * `:unk_token` - The unknown token to be used by the model

    * `:continuing_subword_prefix` - The prefix to attach to subword
      units that don't represent a beginning of word

    * `:end_of_word_suffix` - The suffix to attach to subword units
      that represent an end of word

  """
  @type options() :: [
          cache_capacity: number(),
          dropout: float(),
          unk_token: String.t(),
          continuing_subword_prefix: String.t(),
          end_of_word_suffix: String.t(),
          fuse_unk: boolean(),
          byte_fallback: boolean()
        ]

  @doc """
  Instantiate a BPE model from the given vocab and merges.
  """
  @spec init(
          %{String.t() => integer()},
          [{String.t(), String.t()}],
          options()
        ) :: {:ok, Tokenizers.Model.t()}
  defdelegate init(vocab, merges, options \\ []), to: Tokenizers.Native, as: :models_bpe_init

  @doc """
  Instantiate an empty BPE model.
  """
  @spec empty() :: {:ok, Tokenizers.Model.t()}
  defdelegate empty(), to: Tokenizers.Native, as: :models_bpe_empty

  @doc """
  Instantiate a BPE model from the given vocab and merges files.
  """
  @spec from_file(String.t(), String.t(), options()) :: {:ok, Tokenizers.Model.t()}
  defdelegate from_file(vocab_path, merges_path, options \\ []),
    to: Tokenizers.Native,
    as: :models_bpe_from_file
end
