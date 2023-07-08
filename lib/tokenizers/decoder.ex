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

  @doc """
  Creates new BPE decoder
  """
  @spec bpe(suffix :: String.t()) :: t()
  defdelegate bpe(suffix \\ "</w>"), to: Tokenizers.Native, as: :decoders_bpe

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

  @doc """
  Creates new CTC decoder
  """
  @spec ctc(pad_token :: String.t(), word_delimiter_token :: String.t(), cleanup :: boolean()) ::
          t()
  defdelegate ctc(pad_token \\ "<pad>", word_delimiter_token \\ "|", cleanup \\ true),
    to: Tokenizers.Native,
    as: :decoders_ctc

  @doc """
  Creates new Fuse decoder
  """
  @spec fuse :: t()
  defdelegate fuse(), to: Tokenizers.Native, as: :decoders_fuse

  @doc """
  Creates new Metaspace decoder
  """
  @spec metaspace(replacement :: char(), prefix_space :: boolean()) :: t()
  defdelegate metaspace(replacement \\ ?▁, add_prefix_space \\ true),
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

  @doc """
  Creates new WordPiece decoder
  """
  @spec word_piece(prefix :: String.t(), cleanup :: boolean()) :: t()
  defdelegate word_piece(prefix \\ "##", cleanup \\ true),
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
