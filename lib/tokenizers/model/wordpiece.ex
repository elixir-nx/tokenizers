defmodule Tokenizers.Model.WordPiece do
  @typedoc """
  Options for model initialisation.

    * `:unk_token` - the unknown token to be used by the model.
      Defaults to `"[UNK]"`

    * `:max_input_chars_per_word` - the maximum number of characters
      to allow in a single word. Defaults to `100`

    * `:continuing_subword_prefix` - the prefix to attach to subword
      units that don't represent a beginning of word. Defaults to `"##"`.

  """
  @type options() :: [
          unk_token: String.t(),
          max_input_chars_per_word: number(),
          continuing_subword_prefix: String.t()
        ]

  @doc """
  Instantiate a WordPiece model from the given vocab.
  """
  @spec init(%{String.t() => integer()}, options()) :: {:ok, Tokenizers.Model.t()}
  defdelegate init(vocab, options \\ []),
    to: Tokenizers.Native,
    as: :models_wordpiece_init

  @doc """
  Instantiate an empty WordPiece model.
  """
  @spec empty() :: {:ok, Tokenizers.Model.t()}
  defdelegate empty(), to: Tokenizers.Native, as: :models_wordpiece_empty

  @doc """
  Instantiate a WordPiece model from the given vocab file.
  """
  @spec from_file(String.t(), options()) :: {:ok, Tokenizers.Model.t()}
  defdelegate from_file(vocab_path, options \\ []),
    to: Tokenizers.Native,
    as: :models_wordpiece_from_file
end
