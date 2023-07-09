defmodule Tokenizers.Normalizer do
  @moduledoc """
  A Normalizer is in charge of pre-processing the input string
  in order to normalize it as relevant for a given use case.

  Some common examples of normalization are the Unicode normalization algorithms
  (NFD, NFKD, NFC & NFKC), lowercasing etc...
  The specificity of tokenizers is that we keep track of the alignment while normalizing.
  This is essential to allow mapping from the generated tokens back to the input text.

  The Normalizer is optional.
  """

  @type t() :: %__MODULE__{resource: reference()}
  defstruct [:resource]

  @doc """
  Normalizes the input presented as string into new string
  """
  @spec normalize(normalizer :: t(), input :: String.t()) :: {:ok, String.t()}
  defdelegate normalize(normalizer, input), to: Tokenizers.Native, as: :normalizers_normalize

  @typedoc """
  Options for BERT normalizer initialisation. All values are optional.

  * `:clean_text` (default `true`) - Whether to clean the text, by removing any control characters and replacing all whitespaces by the classic one.
  * `:handle_chinese_chars` (default `true`) - Whether to handle chinese chars by putting spaces around them.
  * `:strip_accents` - Whether to strip all accents. If this option is not specified, then it will be determined by the value for lowercase (as in the original Bert).
  * `:lowercase` (default `true`) - Whether to lowercase.
  """
  @type bert_opts() :: [
          clean_text: boolean(),
          handle_chinese_chars: boolean(),
          strip_accents: boolean(),
          lowercase: boolean()
        ]
  @doc """
  Takes care of normalizing raw text before giving it to a Bert model. This includes cleaning the text, handling accents, chinese chars and lowercasing.
  """
  @spec bert_normalizer(opts :: bert_opts()) :: t()
  defdelegate bert_normalizer(opts \\ []),
    to: Tokenizers.Native,
    as: :normalizers_bert_normalizer

  @doc """
  NFD Unicode Normalizer,
  """
  @spec nfd :: t()
  defdelegate nfd(), to: Tokenizers.Native, as: :normalizers_nfd

  @doc """
  NFKD Unicode Normalizer
  """
  @spec nfkd :: t()
  defdelegate nfkd(), to: Tokenizers.Native, as: :normalizers_nfkd

  @doc """
  NFC Unicode Normalizer
  """
  @spec nfc :: t()
  defdelegate nfc(), to: Tokenizers.Native, as: :normalizers_nfc

  @doc """
  NFKC Unicode Normalizer
  """
  @spec nfkc :: t()
  defdelegate nfkc(), to: Tokenizers.Native, as: :normalizers_nfkc

  @typedoc """
  Options for Strip normalizer initialisation. All values are optional.

  * `:left` (default `true`) - Whether to strip left side.
  * `:right` (default `true`) - Whether to strip right side.
  """
  @type strip_opts() :: [
          left: boolean(),
          right: boolean()
        ]
  @doc """
  Strip normalizer. Removes all whitespace characters on the specified sides (left, right or both) of the input
  """
  @spec strip(opts :: strip_opts()) :: t()
  defdelegate strip(opts \\ []), to: Tokenizers.Native, as: :normalizers_strip

  @doc """
  Prepend normalizer.
  """
  @spec prepend(prepend :: String.t()) :: t()
  defdelegate prepend(prepend), to: Tokenizers.Native, as: :normalizers_prepend

  @doc """
  Strip Accent normalizer. Removes all accent symbols in unicode (to be used with NFD for consistency).
  """
  @spec strip_accents :: t()
  defdelegate strip_accents(), to: Tokenizers.Native, as: :normalizers_strip_accents

  @doc """
  Composes multiple normalizers that will run in the provided order.
  """
  @spec sequence(normalizers :: [t()]) :: t()
  defdelegate sequence(normalizers), to: Tokenizers.Native, as: :normalizers_sequence

  @doc """
  Replaces all uppercase to lowercase
  """
  @spec lowercase :: t()
  defdelegate lowercase(), to: Tokenizers.Native, as: :normalizers_lowercase

  @doc """
  Replaces a custom string or regexp and changes it with given content
  """
  @spec replace(pattern :: String.t(), content :: String.t()) ::
          t()
  defdelegate replace(pattern, content),
    to: Tokenizers.Native,
    as: :normalizers_replace

  @doc """
  Nmt normalizer
  """
  @spec nmt :: t()
  defdelegate nmt(), to: Tokenizers.Native, as: :normalizers_nmt

  @doc """
  Precompiled normalizer. Don’t use manually it is used for compatiblity for SentencePiece.
  """
  @spec precompiled(data :: binary()) :: {:ok, t()} | {:error, any()}
  defdelegate precompiled(data), to: Tokenizers.Native, as: :normalizers_precompiled
end

defimpl Inspect, for: Tokenizers.Normalizer do
  import Inspect.Algebra

  def inspect(decoder, opts) do
    attrs =
      decoder
      |> Tokenizers.Native.normalizers_info()
      |> Keyword.new(fn {k, v} -> {String.to_atom(k), v} end)

    concat(["#Tokenizers.Normalizer<", to_doc(attrs, opts), ">"])
  end
end
