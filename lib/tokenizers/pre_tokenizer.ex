defmodule Tokenizers.PreTokenizer do
  @moduledoc """
  The `PreTokenizer` takes care of splitting the input according to a set of rules.
  This pre-processing lets you ensure that the underlying `Model`
  does not build tokens across multiple “splits”.
  For example if you don’t want to have whitespaces inside a token,
  then you can have a `PreTokenizer` that splits on these whitespaces.

  You can easily combine multiple `PreTokenizer` together using a `Sequence` (see below).
  The `PreTokenizer` is also allowed to modify the string, just like a `Normalizer` does.
  This is necessary to allow some complicated algorithms
  that require to split before normalizing (e.g. the ByteLevel)
  """

  @type t() :: %__MODULE__{resource: reference()}
  defstruct [:resource]

  @doc """
  Converts a string into a sequence of pre-tokens.
  """
  @spec pre_tokenize(pre_tokenizer :: t(), sequence :: String.t()) ::
          {:ok, [{String.t(), {integer(), integer()}}]}
  defdelegate pre_tokenize(normalizer, input),
    to: Tokenizers.Native,
    as: :pre_tokenizers_pre_tokenize

  @typedoc """
  Options for ByteLevel pre-tokenizer. All values are optional.

  * `:add_prefix_space` (default `true`) - Whether to add a space to the first word if there isn’t already one. This lets us treat hello exactly like say hello.
  * `:use_regex` (default `true`) - Set this to False to prevent this pre_tokenizer from using the GPT2 specific regexp for spliting on whitespace.
  """
  @type byte_level_opts() :: [
          add_prefix_space: boolean(),
          use_regex: boolean()
        ]

  @doc """
  Creates ByteLevel PreTokenizer.

  Splits on whitespaces while remapping all the bytes to a set of visible characters.
  This technique as been introduced by OpenAI with GPT-2 and has some more or less nice properties:

  * Since it maps on bytes, a tokenizer using this only requires 256 characters
    as initial alphabet (the number of values a byte can have),
    as opposed to the 130,000+ Unicode characters.
  * A consequence of the previous point is that it is absolutely unnecessary
    to have an unknown token using this since we can represent anything
    with 256 tokens (Youhou!! 🎉🎉)
  * For non ascii characters, it gets completely unreadable, but it works nonetheless!
  """
  @spec byte_level(opts :: byte_level_opts()) :: t()
  defdelegate byte_level(opts), to: Tokenizers.Native, as: :pre_tokenizers_byte_level

  @doc """
  Gets ByteLevel pre-tokenizer's alphabet.
  """
  @spec byte_level_alphabet() :: charlist()
  defdelegate byte_level_alphabet(),
    to: Tokenizers.Native,
    as: :pre_tokenizers_byte_level_alphabet

  @doc """
  Creates Whitespace pre-tokenizer.

  Splits on word boundaries (using the following regular expression: `\w+|[^\w\s]+`
  """
  @spec whitespace() :: t()
  defdelegate whitespace(), to: Tokenizers.Native, as: :pre_tokenizers_whitespace

  @doc """
  Creates WhitespaceSplit pre-tokenizer.

  Splits on any whitespace character
  """
  @spec whitespace_split() :: t()
  defdelegate whitespace_split(), to: Tokenizers.Native, as: :pre_tokenizers_whitespace_split

  @doc """
  Creates BertPreTokenizer pre-tokenizer.

  Splits for use in Bert models.
  """
  @spec bert_pre_tokenizer() :: t()
  defdelegate bert_pre_tokenizer(), to: Tokenizers.Native, as: :pre_tokenizers_bert

  @typedoc """
  Options for Metaspace pre-tokenizer. All values are optional.

  * `:replacement` (default `"▁"`) - The replacement character to use.
  * `:add_prefix_space` (default `true`) - Whether to add a space to the first word if there isn’t already one. This lets us treat hello exactly like say hello.
  """
  @type metaspace_opts() :: [
          replacement: char(),
          add_prefix_space: boolean()
        ]

  @doc """
  Creates Metaspace pre-tokenizer.

  Splits on whitespaces and replaces them with a special char “▁” (U+2581)
  """
  @spec metaspace(opts :: metaspace_opts()) :: t()
  defdelegate metaspace(opts), to: Tokenizers.Native, as: :pre_tokenizers_metaspace

  @doc """
  Creates CharDelimiterSplit pre-tokenizer.

  This pre-tokenizer simply splits on the provided delimiter. Works almost like the `.split(delimiter)`
  function, except that it accounts for multiple consecutive spaces
  """

  @spec char_delimiter_split(delimiter :: char()) :: t()
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
  Creates Split pre-tokenizer.

  Versatile pre-tokenizer that splits on provided pattern and according to provided behavior.
  The pattern can be inverted if necessary.

  * pattern should be either a custom string or regexp.
  * behavior should be one of:

    * removed
    * isolated
    * merged_with_previous
    * merged_with_next
    * contiguous
  """
  @spec split(
          pattern :: String.t(),
          behavior :: split_delimiter_behaviour(),
          invert :: boolean()
        ) :: t()
  defdelegate split(pattern, behavior, invert \\ false),
    to: Tokenizers.Native,
    as: :pre_tokenizers_split

  @doc """
  Creates Punctuation pre-tokenizer.

  Will isolate all punctuation characters.
  """
  @spec punctuation(behavor :: split_delimiter_behaviour()) :: t()
  defdelegate punctuation(behavor), to: Tokenizers.Native, as: :pre_tokenizers_punctuation

  @doc """
  Creates Sequence pre-tokenizer.

  Lets you compose multiple `PreTokenizer` that will be run in the given order
  """
  @spec sequence(pre_tokenizers :: [t()]) :: t()
  defdelegate sequence(pre_tokenizers), to: Tokenizers.Native, as: :pre_tokenizers_sequence

  @doc """
  Creates Digits pre-tokenizer.

  Splits the numbers from any other characters.
  """
  @spec digits(individual_digits :: boolean()) :: t()
  defdelegate digits(individual_digits \\ false),
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
