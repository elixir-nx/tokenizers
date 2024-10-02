defmodule Tokenizers.Normalizer do
  @moduledoc """
  Normalizers and normalization functions.

  A normalizer is in charge of pre-processing the input string in
  order to normalize it as relevant for the given use case.

  Some common examples of normalization are the Unicode normalization
  algorithms (NFD, NFKD, NFC & NFKC) or lowercasing. The specificity
  of tokenizers is that we keep track of the alignment while
  normalizing. This is essential to allow mapping from the generated
  tokens back to the input text.
  """

  defstruct [:resource]

  @type t() :: %__MODULE__{resource: reference()}

  @doc """
  Normalizes the given text input.
  """
  @spec normalize(t(), String.t()) :: {:ok, String.t()}
  defdelegate normalize(normalizer, input), to: Tokenizers.Native, as: :normalizers_normalize

  # Normalizer entities. Following the order in https://docs.rs/tokenizers/0.20.0/src/tokenizers/normalizers/mod.rs.html#24

  @doc """
  Takes care of normalizing raw text before giving it to a BERT model.

  This includes cleaning the text, handling accents, Chinese chars and
  lowercasing.

  ## Options

    * `:clean_text` - whether to clean the text, by removing any
      control characters and replacing all whitespaces by the classic
      one. Defaults to `true`

    * `:handle_chinese_chars` - whether to handle chinese chars by
      putting spaces around them. Default `true`

    * `:strip_accents` - whether to strip all accents. If this option
      is not specified, then it will be determined by the value for
      lowercase (as in the original Bert)

    * `:lowercase` - whether to lowercase. Default `true`

  """
  @spec bert_normalizer(keyword()) :: t()
  defdelegate bert_normalizer(opts \\ []),
    to: Tokenizers.Native,
    as: :normalizers_bert_normalizer

  @doc """
  Creates a Strip normalizer.

  Removes all whitespace characters on the specified sides (left,
  right or both) of the input

  ## Options

    * `:left` - whether to strip left side. Defaults to `true`

    * `:right` - whether to strip right side. Defaults to `true`

  """
  @spec strip(keyword()) :: t()
  defdelegate strip(opts \\ []), to: Tokenizers.Native, as: :normalizers_strip

  @doc """
  Creates a Strip Accent normalizer.

  Removes all accent symbols in unicode (to be used with NFD for
  consistency).
  """
  @spec strip_accents :: t()
  defdelegate strip_accents(), to: Tokenizers.Native, as: :normalizers_strip_accents

  @doc """
  Creates a NFC Unicode normalizer.
  """
  @spec nfc :: t()
  defdelegate nfc(), to: Tokenizers.Native, as: :normalizers_nfc

  @doc """
  Creates a NFD Unicode normalizer.
  """
  @spec nfd :: t()
  defdelegate nfd(), to: Tokenizers.Native, as: :normalizers_nfd

  @doc """
  Creates a NFKC Unicode normalizer.
  """
  @spec nfkc :: t()
  defdelegate nfkc(), to: Tokenizers.Native, as: :normalizers_nfkc

  @doc """
  Creates a NFKD Unicode normalizer.
  """
  @spec nfkd :: t()
  defdelegate nfkd(), to: Tokenizers.Native, as: :normalizers_nfkd

  @doc """
  Composes multiple normalizers that will run in the provided order.
  """
  @spec sequence([t()]) :: t()
  defdelegate sequence(normalizers), to: Tokenizers.Native, as: :normalizers_sequence

  @doc """
  Replaces all uppercase to lowercase
  """
  @spec lowercase :: t()
  defdelegate lowercase(), to: Tokenizers.Native, as: :normalizers_lowercase

  @doc """
  Creates a Nmt normalizer.
  """
  @spec nmt :: t()
  defdelegate nmt(), to: Tokenizers.Native, as: :normalizers_nmt

  @doc """
  Precompiled normalizer.

  Don’t use manually it is used for compatibility with SentencePiece.
  """
  @spec precompiled(binary()) :: {:ok, t()} | {:error, any()}
  defdelegate precompiled(data), to: Tokenizers.Native, as: :normalizers_precompiled

  @doc """
  Replaces a custom `search` string with the given `content`.
  """
  @spec replace(String.t(), String.t()) :: t()
  def replace(search, content) do
    Tokenizers.Native.normalizers_replace({:string, search}, content)
  end

  @doc """
  Replaces occurrences of a custom regexp `pattern` with the given `content`.

  The `pattern` should be a string representing a regular expression
  according to the [Oniguruma Regex Engine](https://github.com/kkos/oniguruma).
  """
  @spec replace_regex(String.t(), String.t()) :: t()
  def replace_regex(pattern, content) do
    Tokenizers.Native.normalizers_replace({:regex, pattern}, content)
  end

  @doc """
  Creates a Prepend normalizer.
  """
  @spec prepend(prepend :: String.t()) :: t()
  defdelegate prepend(prepend), to: Tokenizers.Native, as: :normalizers_prepend

  @doc """
  Created ByteLevel normalizer.
  """
  @spec byte_level :: t()
  defdelegate byte_level(), to: Tokenizers.Native, as: :normalizers_byte_level
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

defmodule Tokenizers.Normalizer.ByteLevel do
  @doc """
  Gets ByteLevel normalizer's alphabet.
  """
  defdelegate alphabet(), to: Tokenizers.Native, as: :normalizers_byte_level_alphabet
end
