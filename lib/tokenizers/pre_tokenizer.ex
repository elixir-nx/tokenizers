defmodule Tokenizers.PreTokenizer do
  @moduledoc """
  Pre-tokenizers.

  A pre-tokenizer takes care of splitting the input according to a set
  of rules. This pre-processing lets you ensure that the underlying
  model does not build tokens across multiple “splits”. For example
  if you don’t want to have whitespaces inside a token, then you can
  have a pre-tokenizer that splits on these whitespaces.

  You can easily combine multiple pre-tokenizers together using
  `sequence/1`.

  A pre-tokenizer is also allowed to modify the string, just like a
  normalizer does. This is necessary to allow some complicated
  algorithms that require to split before normalizing (e.g. ByteLevel).
  """

  defstruct [:resource]

  @type t() :: %__MODULE__{resource: reference()}

  @doc """
  Converts a string into a sequence of pre-tokens.
  """
  @spec pre_tokenize(t(), String.t()) :: {:ok, [{String.t(), {integer(), integer()}}]}
  defdelegate pre_tokenize(pre_tokenizer, input),
    to: Tokenizers.Native,
    as: :pre_tokenizers_pre_tokenize

  @doc """
  Creates a ByteLevel pre-tokenizer.

  Splits on whitespaces while remapping all the bytes to a set of
  visible characters. This technique has been introduced by OpenAI
  with GPT-2 and has some more or less nice properties:

    * Since it maps on bytes, a tokenizer using this only requires
      256 characters as initial alphabet (the number of values a byte
      can have), as opposed to the 130,000+ Unicode characters.

    * A consequence of the previous point is that it is absolutely
      unnecessary to have an unknown token using this since we can
      represent anything with 256 tokens (Youhou!! 🎉🎉)

    * For non ascii characters, it gets completely unreadable, but it
      works nonetheless!

  ## Options

    * `:add_prefix_space` - whether to add a space to the first word
      if there isn’t already one. This lets us treat hello exactly
      like say hello. Defaults to `true`

    * `:use_regex` - set this to `false` to prevent this pre-tokenizer
      from using the GPT2 specific regexp for splitting on whitespace.
      Defaults to `true`

  """
  @spec byte_level(keyword()) :: t()
  defdelegate byte_level(opts \\ []), to: Tokenizers.Native, as: :pre_tokenizers_byte_level

  @doc """
  Gets ByteLevel pre-tokenizer's alphabet.
  """
  @spec byte_level_alphabet() :: charlist()
  defdelegate byte_level_alphabet(),
    to: Tokenizers.Native,
    as: :pre_tokenizers_byte_level_alphabet

  @doc """
  Creates a Whitespace pre-tokenizer.

  Splits on word boundaries. Uses the following regular expression:
  `\w+|[^\w\s]+`.
  """
  @spec whitespace() :: t()
  defdelegate whitespace(), to: Tokenizers.Native, as: :pre_tokenizers_whitespace

  @doc """
  Creates a WhitespaceSplit pre-tokenizer.

  Splits on any whitespace character.
  """
  @spec whitespace_split() :: t()
  defdelegate whitespace_split(), to: Tokenizers.Native, as: :pre_tokenizers_whitespace_split

  @doc """
  Creates a BertPreTokenizer pre-tokenizer.

  Splits for use in Bert models.
  """
  @spec bert_pre_tokenizer() :: t()
  defdelegate bert_pre_tokenizer(), to: Tokenizers.Native, as: :pre_tokenizers_bert

  @doc """
  Creates Metaspace pre-tokenizer.

  Splits on whitespaces and replaces them with a special char “▁”
  (U+2581).

  ## Options

    * `:replacement` - the replacement character to use. Defaults to `"▁"`

    * `:prepend_scheme` - whether to add a space to the first word if there
      isn't already one. This lets us treat "hello" exactly like "say hello".
      Either of `:always`, `:never`, `:first`. `:first` means the space is
      only added on the first token (relevant when special tokens are used
      or other pre_tokenizer are used). Defaults to `:always`

  """
  @spec metaspace(keyword()) :: t()
  defdelegate metaspace(opts \\ []), to: Tokenizers.Native, as: :pre_tokenizers_metaspace

  @doc """
  Creates a CharDelimiterSplit pre-tokenizer.

  This pre-tokenizer simply splits on the provided delimiter. Works
  almost like simple split function, except that it accounts for
  multiple consecutive spaces.
  """
  @spec char_delimiter_split(char()) :: t()
  defdelegate char_delimiter_split(delimiter),
    to: Tokenizers.Native,
    as: :pre_tokenizers_char_delimiter_split

  @typedoc """
  Specifies how delimiter should behave for several pretokenizers.
  """
  @type split_delimiter_behaviour() ::
          :removed
          | :isolated
          | :merged_with_previous
          | :merged_with_next
          | :contiguous

  @doc """
  Creates a Split pre-tokenizer using a string as split pattern.

  Versatile pre-tokenizer that splits on provided pattern and according
  to provided behavior.

  ## Options

    * `:invert` - whether to invert the split or not. Defaults to `false`

  """
  @spec split(String.t(), split_delimiter_behaviour(), keyword()) :: t()
  def split(pattern, behavior, opts \\ []) when is_binary(pattern) do
    Tokenizers.Native.pre_tokenizers_split({:string, pattern}, behavior, opts)
  end

  @doc ~S"""
  Creates a Split pre-tokenizer using a regular expression as split pattern.

  Versatile pre-tokenizer that splits on provided regex pattern and according
  to provided behavior.

  The `pattern` should be a string representing a regular expression
  according to the [Oniguruma Regex Engine](https://github.com/kkos/oniguruma).

  ## Options

    * `:invert` - whether to invert the split or not. Defaults to `false`

  ## Example

      iex> Tokenizers.PreTokenizer.split_regex(~S(\?\d{2}\?), :removed)
      #Tokenizers.PreTokenizer<[pre_tokenizer_type: "Split"]>

  """
  @spec split_regex(String.t(), split_delimiter_behaviour(), keyword()) :: t()
  def split_regex(pattern, behavior, opts \\ []) when is_binary(pattern) do
    Tokenizers.Native.pre_tokenizers_split({:regex, pattern}, behavior, opts)
  end

  @doc """
  Creates a Punctuation pre-tokenizer.

  Will isolate all punctuation characters.
  """
  @spec punctuation(split_delimiter_behaviour()) :: t()
  defdelegate punctuation(behaviour), to: Tokenizers.Native, as: :pre_tokenizers_punctuation

  @doc """
  Creates a Sequence pre-tokenizer.

  Lets you compose multiple pre-tokenizers that will be run in the
  given order.
  """
  @spec sequence([t()]) :: t()
  defdelegate sequence(pre_tokenizers), to: Tokenizers.Native, as: :pre_tokenizers_sequence

  @doc """
  Creates a Digits pre-tokenizer.

  Splits the numbers from any other characters.

  ## Options

    * `:individual_digits` - whether to split individual digits or not.
      Defaults to `false`

  """
  @spec digits(keyword()) :: t()
  defdelegate digits(opts \\ []),
    to: Tokenizers.Native,
    as: :pre_tokenizers_digits
end

defimpl Inspect, for: Tokenizers.PreTokenizer do
  import Inspect.Algebra

  def inspect(decoder, opts) do
    attrs =
      decoder
      |> Tokenizers.Native.pre_tokenizers_info()
      |> Keyword.new(fn {k, v} -> {String.to_atom(k), v} end)

    concat(["#Tokenizers.PreTokenizer<", to_doc(attrs, opts), ">"])
  end
end
