defmodule Tokenizers.Model.WordPiece do
  @typedoc """
  Options for model initialisation. All options can be ommited.

  * `:unk_token` (default `"[UNK]"`) - The unknown token to be used by the model.
  * `:max_input_chars_per_word` (default `100`) - The maximum number of characters to authorize in a single word.
  * `:continuing_subword_prefix` (default `"##"`) - The prefix to attach to subword units that don't represent a beginning of word
  """
  @type options() :: [
          unk_token: String.t(),
          max_input_chars_per_word: number(),
          continuing_subword_prefix: String.t()
        ]

  @doc """
  Instantiate a WordPiece model from the given vocab
  """
  @spec init(
          vocab :: %{String.t() => integer()},
          options :: options()
        ) :: {:ok, Tokenizers.Model.t()}
  defdelegate init(vocab, options \\ []),
    to: Tokenizers.Native,
    as: :models_wordpiece_init

  @doc """
  Instantiate an empty WordPiece model
  """
  @spec empty() :: {:ok, Tokenizers.Model.t()}
  defdelegate empty(), to: Tokenizers.Native, as: :models_wordpiece_empty

  @doc """
  Instantiate a WordPiece model from the given vocab file
  """
  @spec from_file(
          vocab :: String.t(),
          options :: options()
        ) :: {:ok, Tokenizers.Model.t()}
  defdelegate from_file(vocab, options \\ []),
    to: Tokenizers.Native,
    as: :models_wordpiece_from_file
end
