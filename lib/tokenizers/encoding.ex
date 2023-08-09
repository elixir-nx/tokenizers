defmodule Tokenizers.Encoding do
  @moduledoc """
  Encoding is the result of passing a text through tokenization pipeline.

  This function defines a struct and a number of functions to retrieve
  information about the encoded text.

  For further machine learning processing you most likely want to
  access the encoded token ids via `get_ids/1`. If you want to convert
  the ids to a tensor, use `get_u32_ids/1` to get a zero-copy binary.
  """

  defstruct resource: nil

  @type t :: %__MODULE__{resource: reference()}

  @doc """
  Returns the number of tokens in `encoding`.
  """
  @spec get_length(t()) :: non_neg_integer()
  defdelegate get_length(encoding), to: Tokenizers.Native, as: :encoding_get_length

  @doc """
  Returns the number of sequences combined in `encoding`.
  """
  @spec get_n_sequences(t()) :: non_neg_integer()
  defdelegate get_n_sequences(encoding), to: Tokenizers.Native, as: :encoding_get_n_sequences

  @doc """
  Sets the given sequence id for all tokens contained in `encoding`.
  """
  @spec set_sequence_id(t(), non_neg_integer()) :: t()
  defdelegate set_sequence_id(encoding, id), to: Tokenizers.Native, as: :encoding_set_sequence_id

  @doc """
  Returns the ids from `encoding`.
  """
  @spec get_ids(t()) :: [integer()]
  defdelegate get_ids(encoding), to: Tokenizers.Native, as: :encoding_get_ids

  @doc """
  Same as `get_ids/1`, but returns binary with u32 values.
  """
  @spec get_u32_ids(t()) :: binary()
  defdelegate get_u32_ids(encoding), to: Tokenizers.Native, as: :encoding_get_u32_ids

  @doc """
  Returns token type ids from `encoding`.
  """
  @spec get_type_ids(t()) :: [integer()]
  defdelegate get_type_ids(encoding), to: Tokenizers.Native, as: :encoding_get_type_ids

  @doc """
  Same as `get_type_ids/1`, but returns binary with u32 values.
  """
  @spec get_u32_type_ids(t()) :: binary()
  defdelegate get_u32_type_ids(encoding), to: Tokenizers.Native, as: :encoding_get_u32_type_ids

  @doc """
  Returns the attention mask from `encoding`.
  """
  @spec get_attention_mask(t()) :: [integer()]
  defdelegate get_attention_mask(encoding),
    to: Tokenizers.Native,
    as: :encoding_get_attention_mask

  @doc """
  Same as `get_attention_mask/1`, but returns binary with u32 values.
  """
  @spec get_u32_attention_mask(t()) :: binary()
  defdelegate get_u32_attention_mask(encoding),
    to: Tokenizers.Native,
    as: :encoding_get_u32_attention_mask

  @doc """
  Returns the special tokens mask from `encoding`.
  """
  @spec get_special_tokens_mask(t()) :: [integer()]
  defdelegate get_special_tokens_mask(encoding),
    to: Tokenizers.Native,
    as: :encoding_get_special_tokens_mask

  @doc """
  Same as `get_special_tokens_mask/1`, but returns binary with u32 values.
  """
  @spec get_u32_special_tokens_mask(t()) :: binary()
  defdelegate get_u32_special_tokens_mask(encoding),
    to: Tokenizers.Native,
    as: :encoding_get_u32_special_tokens_mask

  @doc """
  Returns the tokens from `encoding`.
  """
  @spec get_tokens(t()) :: [binary()]
  defdelegate get_tokens(encoding), to: Tokenizers.Native, as: :encoding_get_tokens

  @doc """
  Returns word ids from `encoding`.
  """
  @spec get_word_ids(t()) :: [non_neg_integer() | nil]
  defdelegate get_word_ids(encoding), to: Tokenizers.Native, as: :encoding_get_word_ids

  @doc """
  Returns sequence ids from `encoding`.
  """
  @spec get_sequence_ids(t()) :: [non_neg_integer() | nil]
  defdelegate get_sequence_ids(encoding), to: Tokenizers.Native, as: :encoding_get_sequence_ids

  @doc """
  Returns offsets from `encoding`.

  The offsets are expressed in terms of UTF-8 bytes.
  """
  @spec get_offsets(t()) :: [{integer(), integer()}]
  defdelegate get_offsets(encoding), to: Tokenizers.Native, as: :encoding_get_offsets

  @doc """
  Returns the overflow from `encoding`.
  """
  @spec get_overflowing(t()) :: [t()]
  defdelegate get_overflowing(encoding), to: Tokenizers.Native, as: :encoding_get_overflowing

  @doc """
  Returns the encoded tokens corresponding to the word at the given
  index in the input sequence, with the form `{start_token, end_token + 1}`.
  """
  @spec word_to_tokens(t(), non_neg_integer(), non_neg_integer()) ::
          {non_neg_integer(), non_neg_integer()} | nil
  defdelegate word_to_tokens(encoding, word, seq_id),
    to: Tokenizers.Native,
    as: :encoding_word_to_tokens

  @doc """
  Returns the offsets of the word at the given index in the input
  sequence.
  """
  @spec word_to_chars(t(), non_neg_integer(), non_neg_integer()) ::
          {non_neg_integer(), non_neg_integer()} | nil
  defdelegate word_to_chars(encoding, word, seq_id),
    to: Tokenizers.Native,
    as: :encoding_word_to_chars

  @doc """
  Returns the index of the sequence containing the given token.
  """
  @spec token_to_sequence(t(), non_neg_integer()) :: non_neg_integer() | nil
  defdelegate token_to_sequence(encoding, token),
    to: Tokenizers.Native,
    as: :encoding_token_to_sequence

  @doc """
  Returns the offsets of the token at the given index.
  """
  @spec token_to_chars(t(), non_neg_integer()) ::
          {non_neg_integer(), {non_neg_integer(), non_neg_integer()}} | nil
  defdelegate token_to_chars(encoding, token), to: Tokenizers.Native, as: :encoding_token_to_chars

  @doc """
  Returns the word that contains the token at the given index.
  """
  @spec token_to_word(t(), non_neg_integer()) ::
          {non_neg_integer(), non_neg_integer()} | nil
  defdelegate token_to_word(encoding, token), to: Tokenizers.Native, as: :encoding_token_to_word

  @doc """
  Returns the token that contains the given char.
  """
  @spec char_to_token(t(), non_neg_integer(), non_neg_integer()) ::
          non_neg_integer() | nil
  defdelegate char_to_token(encoding, position, seq_id),
    to: Tokenizers.Native,
    as: :encoding_char_to_token

  @doc """
  Returns the word that contains the given char.
  """
  @spec char_to_word(t(), non_neg_integer(), non_neg_integer()) ::
          non_neg_integer() | nil
  defdelegate char_to_word(encoding, position, seq_id),
    to: Tokenizers.Native,
    as: :encoding_char_to_word

  @typedoc """
  Options for padding. All options can be ommited.
  * `direction` (default `:right`) - The padding direction.
  * `pad_id` (default `0`) - The id corresponding to the padding token.
  * `pad_type_id` (default `0`) - The type ID corresponding to the padding token.
  * `pad_token` (default `[PAD]`) - The padding token to use.
  """
  @type padding_opts :: [
          pad_id: non_neg_integer(),
          pad_type_id: non_neg_integer(),
          pad_token: String.t(),
          direction: :left | :right
        ]

  @doc """
  Pad the encoding to the given length.

  ## Options

    * `direction` (default `:right`) - the padding direction

    * `pad_id` (default `0`) - the id corresponding to the padding
      token

    * `pad_type_id` (default `0`) - the type ID corresponding to the
      padding token

    * `pad_token` (default `[PAD]`) - the padding token to use

  """
  @spec pad(t(), non_neg_integer(), opts :: padding_opts()) :: t()
  defdelegate pad(encoding, target_length, opts \\ []),
    to: Tokenizers.Native,
    as: :encoding_pad

  @typedoc """
  Options for truncation. All options can be ommited.
  * `stride` (default `0`) - The length of previous content to be included in each overflowing piece.
  * `direction` (default `:right`) - The truncation direction.
  """
  @type truncation_opts :: [stride: non_neg_integer(), direction: :left | :right]

  @doc """
  Truncate the encoding to the given length.

  ## Options

    * `stride` (default `0`) - the length of previous content to be
      included in each overflowing piece

    * `direction` (default `:right`) - the truncation direction

  """
  @spec truncate(t(), non_neg_integer(), opts :: truncation_opts()) :: t()
  defdelegate truncate(encoding, max_length, opts \\ []),
    to: Tokenizers.Native,
    as: :encoding_truncate

  @doc """
  Returns the number of tokens in `encoding`.
  """
  @spec n_tokens(encoding :: t()) :: non_neg_integer()
  defdelegate n_tokens(encoding), to: Tokenizers.Native, as: :encoding_get_length

  @doc """
  Performs set of transformations to given encoding, creating a new one.
  Transformations are applied in order they are given.

  While all these transformations can be done one by one, this function
  is more efficient as it avoids multiple allocations and Garbage Collection
  for intermediate encodings.

  Check the module `Tokenizers.Encoding.Transformation` for handy functions,
  that can be used to build the transformations list.
  Also, you can build this list manually, as long as it follows the format.
  """
  defdelegate transform(encoding, transformations), to: Tokenizers.Native, as: :encoding_transform
end

defimpl Inspect, for: Tokenizers.Encoding do
  import Inspect.Algebra

  alias Tokenizers.Encoding

  def inspect(encoding, opts) do
    attrs = [
      length: Encoding.get_length(encoding),
      ids: Encoding.get_ids(encoding)
    ]

    concat(["#Tokenizers.Encoding<", to_doc(attrs, opts), ">"])
  end
end
