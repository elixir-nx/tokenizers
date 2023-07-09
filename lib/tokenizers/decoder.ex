defmodule Tokenizers.Decoder do
  @moduledoc """
  The Decoder knows how to go from the IDs used by the Tokenizer, back to a readable piece of text.
  Some Normalizer and PreTokenizer use special characters or identifiers that need to be reverted.
  """

  defstruct [:resource]
  @type t() :: %__MODULE__{resource: reference()}

  @doc """
  Decodes tokens into string with provided decoder.
  """
  @spec decode(t(), [String.t()]) :: {:ok, String.t()} | {:error, any()}
  defdelegate decode(decoder, tokens), to: Tokenizers.Native, as: :decoders_decode

  @typedoc """
  Options for BPE decoder initialization. All options can be ommited.

  * `suffix` - The suffix to add to the end of each word, defaults to `</w>`
  """
  @type bpe_options :: [suffix: String.t()]

  @doc """
  Creates new BPE decoder
  """
  @spec bpe(bpe_options :: bpe_options()) :: t()
  defdelegate bpe(options \\ []), to: Tokenizers.Native, as: :decoders_bpe

  @doc """
  Creates new ByteFallback decoder
  """
  @spec byte_fallback() :: t()
  defdelegate byte_fallback(), to: Tokenizers.Native, as: :decoders_byte_fallback

  @doc """
  Creates new ByteLevel decoder
  """
  @spec byte_level() :: t()
  defdelegate byte_level(), to: Tokenizers.Native, as: :decoders_byte_level

  @typedoc """
  Options for CTC decoder initialization. All options can be ommited.

  * `pad_token` - The token used for padding, defaults to `<pad>`
  * `word_delimiter_token` - The token used for word delimiter, defaults to `|`
  * `cleanup` - Whether to cleanup tokenization artifacts, defaults to `true`
  """
  @type ctc_options :: [
          pad_token: String.t(),
          word_delimiter_token: String.t(),
          cleanup: boolean()
        ]

  @doc """
  Creates new CTC decoder
  """
  @spec ctc(ctc_options :: ctc_options()) :: t()
  defdelegate ctc(options \\ []), to: Tokenizers.Native, as: :decoders_ctc

  @doc """
  Creates new Fuse decoder
  """
  @spec fuse :: t()
  defdelegate fuse(), to: Tokenizers.Native, as: :decoders_fuse

  @typedoc """
  Options for Metaspace decoder initialization. All options can be ommited.

  * `replacement` - The replacement character, defaults to `▁` (as char)
  * `add_prefix_space` - Whether to add a space to the first word, defaults to `true`
  """

  @type metaspace_options :: [
          replacement: char(),
          add_prefix_space: boolean()
        ]

  @doc """
  Creates new Metaspace decoder
  """
  @spec metaspace(metaspace_options :: metaspace_options()) :: t()
  defdelegate metaspace(options \\ []),
    to: Tokenizers.Native,
    as: :decoders_metaspace

  @doc """
  Creates new Replace decoder
  """
  @spec replace(pattern :: String.t(), content :: String.t()) :: t()
  defdelegate replace(pattern, content), to: Tokenizers.Native, as: :decoders_replace

  @doc """
  Creates new Sequence decoder
  """
  @spec sequence(decoders :: [Tokenizers.Decoder.t()]) :: t()
  defdelegate sequence(decoders), to: Tokenizers.Native, as: :decoders_sequence

  @doc """
  Creates new Strip decoder
  """
  @spec strip(content :: char(), left :: non_neg_integer(), right :: non_neg_integer()) :: t()
  defdelegate strip(content, left, right), to: Tokenizers.Native, as: :decoders_strip

  @typedoc """
  Options for WordPiece decoder initialization. All options can be ommited.

  * `prefix` - The prefix to use for subwords, defaults to `##`
  * `cleanup` - Whether to cleanup tokenization artifacts, defaults to `true`
  """
  @type word_piece_options :: [
          prefix: String.t(),
          cleanup: boolean()
        ]

  @doc """
  Creates new WordPiece decoder
  """
  @spec word_piece(word_piece_options :: word_piece_options()) :: t()
  defdelegate word_piece(options \\ []),
    to: Tokenizers.Native,
    as: :decoders_wordpiece
end

defimpl Inspect, for: Tokenizers.Decoder do
  import Inspect.Algebra

  @spec inspect(Tokenizers.Decoder.t(), Inspect.Opts.t()) :: Inspect.Algebra.t()
  def inspect(decoder, opts) do
    attrs =
      decoder
      |> Tokenizers.Native.decoders_info()
      |> Keyword.new(fn {k, v} -> {String.to_atom(k), v} end)

    concat(["#Tokenizers.Decoder<", to_doc(attrs, opts), ">"])
  end
end
