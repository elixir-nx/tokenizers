defmodule Tokenizers.Decoder do
  @moduledoc """
  Decoders and decoding functions.

  Decoder transforms a sequence of token ids back to a readable piece
  of text.

  Some normalizers and pre-tokenizers use special characters or
  identifiers that need special logic to be reverted.
  """

  defstruct [:resource]

  @type t() :: %__MODULE__{resource: reference()}

  @doc """
  Decodes tokens into string with provided decoder.
  """
  @spec decode(t(), [String.t()]) :: {:ok, String.t()} | {:error, any()}
  defdelegate decode(decoder, tokens), to: Tokenizers.Native, as: :decoders_decode

  @doc """
  Creates a BPE decoder.

  ## Options

    * `suffix` - the suffix to add to the end of each word. Defaults
      to `</w>`

  """
  @spec bpe(keyword()) :: t()
  defdelegate bpe(opts \\ []), to: Tokenizers.Native, as: :decoders_bpe

  @doc """
  Creates a ByteFallback decoder.
  """
  @spec byte_fallback() :: t()
  defdelegate byte_fallback(), to: Tokenizers.Native, as: :decoders_byte_fallback

  @doc """
  Creates a ByteLevel decoder.
  """
  @spec byte_level() :: t()
  defdelegate byte_level(), to: Tokenizers.Native, as: :decoders_byte_level

  @doc """
  Creates a CTC decoder.

  ## Options

    * `pad_token` - the token used for padding. Defaults to `<pad>`

    * `word_delimiter_token` - the token used for word delimiter.
      Defaults to `|`

    * `cleanup` - whether to cleanup tokenization artifacts, defaults
      to `true`

  """
  @spec ctc(keyword()) :: t()
  defdelegate ctc(opts \\ []), to: Tokenizers.Native, as: :decoders_ctc

  @doc """
  Creates a Fuse decoder.
  """
  @spec fuse :: t()
  defdelegate fuse(), to: Tokenizers.Native, as: :decoders_fuse

  @doc """
  Creates a Metaspace decoder.

  ## Options

    * `replacement` - the replacement character. Defaults to `▁`
      (as char)

    * `add_prefix_space` - whether to add a space to the first word.
      Defaults to `true`

  """
  @spec metaspace(keyword()) :: t()
  defdelegate metaspace(opts \\ []),
    to: Tokenizers.Native,
    as: :decoders_metaspace

  @doc """
  Creates a Replace decoder.
  """
  @spec replace(String.t(), String.t()) :: t()
  defdelegate replace(pattern, content), to: Tokenizers.Native, as: :decoders_replace

  @doc """
  Combines a list of decoders into a single sequential decoder.
  """
  @spec sequence(decoders :: [t()]) :: t()
  defdelegate sequence(decoders), to: Tokenizers.Native, as: :decoders_sequence

  @doc """
  Creates a Strip decoder.

  It expects a character and the number of times to strip the
  character on `left` and `right` sides.
  """
  @spec strip(char(), non_neg_integer(), non_neg_integer()) :: t()
  defdelegate strip(content, left, right), to: Tokenizers.Native, as: :decoders_strip

  @doc """
  Creates a WordPiece decoder.

  ## Options

    * `prefix` - The prefix to use for subwords. Defaults to `##`

    * `cleanup` - Whether to cleanup tokenization artifacts. Defaults
      to `true`

  """
  @spec word_piece(keyword()) :: t()
  defdelegate word_piece(opts \\ []),
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
