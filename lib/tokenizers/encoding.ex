defmodule Tokenizers.Encoding do
  @moduledoc """
  The struct and associated functions for an encoding, the output of a tokenizer.

  Use these functions to retrieve the inputs needed for a natural language processing machine learning model.
  """

  @type t :: %__MODULE__{resource: reference()}
  defstruct resource: nil

  @doc """
  Get the number of tokens in an encoding.
  """
  @spec get_length(__MODULE__.t()) :: non_neg_integer()
  defdelegate get_length(encoding), to: Tokenizers.Native, as: :encoding_get_length

  @doc """
  Return the number of sequences combined in this Encoding
  """
  @spec get_n_sequences(__MODULE__.t()) :: non_neg_integer()
  defdelegate get_n_sequences(encoding), to: Tokenizers.Native, as: :encoding_get_n_sequences

  @doc """
  Set the given sequence id for the whole range of tokens contained in this Encoding.
  """
  @spec set_sequence_id(__MODULE__.t(), non_neg_integer()) :: __MODULE__.t()
  defdelegate set_sequence_id(encoding, id), to: Tokenizers.Native, as: :encoding_set_sequence_id

  @doc """
  Get the ids from an encoding.
  """
  @spec get_ids(__MODULE__.t()) :: [integer()]
  defdelegate get_ids(encoding), to: Tokenizers.Native, as: :encoding_get_ids

  @doc """
  Same as `get_ids/1`, but returns binary with u32 values.
  """
  @spec get_u32_ids(__MODULE__.t()) :: binary()
  defdelegate get_u32_ids(encoding), to: Tokenizers.Native, as: :encoding_get_u32_ids

  @doc """
  Get token type ids from an encoding.
  """
  @spec get_type_ids(__MODULE__.t()) :: [integer()]
  defdelegate get_type_ids(encoding), to: Tokenizers.Native, as: :encoding_get_type_ids

  @doc """
  Same as `get_type_ids/1`, but returns binary with u32 values.
  """
  @spec get_u32_type_ids(__MODULE__.t()) :: binary()
  defdelegate get_u32_type_ids(encoding), to: Tokenizers.Native, as: :encoding_get_u32_type_ids

  @doc """
  Get the attention mask from an encoding.
  """
  @spec get_attention_mask(__MODULE__.t()) :: [integer()]
  defdelegate get_attention_mask(encoding),
    to: Tokenizers.Native,
    as: :encoding_get_attention_mask

  @doc """
  Same as `get_attention_mask/1`, but returns binary with u32 values.
  """
  @spec get_u32_attention_mask(__MODULE__.t()) :: binary()
  defdelegate get_u32_attention_mask(encoding),
    to: Tokenizers.Native,
    as: :encoding_get_u32_attention_mask

  @doc """
  Get the special tokens mask from an encoding.
  """
  @spec get_special_tokens_mask(__MODULE__.t()) :: [integer()]
  defdelegate get_special_tokens_mask(encoding),
    to: Tokenizers.Native,
    as: :encoding_get_special_tokens_mask

  @doc """
  Same as `get_special_tokens_mask/1`, but returns binary with u32 values.
  """
  @spec get_u32_special_tokens_mask(__MODULE__.t()) :: binary()
  defdelegate get_u32_special_tokens_mask(encoding),
    to: Tokenizers.Native,
    as: :encoding_get_u32_special_tokens_mask

  @doc """
  Get the tokens from an encoding.
  """
  @spec get_tokens(__MODULE__.t()) :: [binary()]
  defdelegate get_tokens(encoding), to: Tokenizers.Native, as: :encoding_get_tokens

  @doc """
  Get word ids from an encoding.
  """
  @spec get_word_ids(__MODULE__.t()) :: [non_neg_integer() | nil]
  defdelegate get_word_ids(encoding), to: Tokenizers.Native, as: :encoding_get_word_ids

  @doc """
  Get sequence ids from an encoding.
  """
  @spec get_sequence_ids(__MODULE__.t()) :: [non_neg_integer() | nil]
  defdelegate get_sequence_ids(encoding), to: Tokenizers.Native, as: :encoding_get_sequence_ids

  @doc """
  Get offsets from an encoding.

  The offsets are expressed in terms of UTF-8 bytes.
  """
  @spec get_offsets(__MODULE__.t()) :: [{integer(), integer()}]
  defdelegate get_offsets(encoding), to: Tokenizers.Native, as: :encoding_get_offsets

  @doc """
  Get the overflow from an encoding.
  """
  @spec get_overflowing(__MODULE__.t()) :: [__MODULE__.t()]
  defdelegate get_overflowing(encoding), to: Tokenizers.Native, as: :encoding_get_overflowing

  @doc """
  Get the encoded tokens corresponding to the word at the given index in the input sequence,
  with the form (start_token, end_token + 1)
  """
  @spec word_to_tokens(__MODULE__.t(), non_neg_integer(), non_neg_integer()) ::
          {non_neg_integer(), non_neg_integer()} | nil
  defdelegate word_to_tokens(encoding, word, seq_id),
    to: Tokenizers.Native,
    as: :encoding_word_to_tokens

  @doc """
  Get the offsets of the word at the given index in the input sequence.
  """
  @spec word_to_chars(__MODULE__.t(), non_neg_integer(), non_neg_integer()) ::
          {non_neg_integer(), non_neg_integer()} | nil
  defdelegate word_to_chars(encoding, word, seq_id),
    to: Tokenizers.Native,
    as: :encoding_word_to_chars

  @doc """
  Returns the index of the sequence containing the given token
  """
  @spec token_to_sequence(__MODULE__.t(), non_neg_integer()) :: non_neg_integer() | nil
  defdelegate token_to_sequence(encoding, token),
    to: Tokenizers.Native,
    as: :encoding_token_to_sequence

  @doc """
  Get the offsets of the token at the given index.
  """
  @spec token_to_chars(__MODULE__.t(), non_neg_integer()) ::
          {non_neg_integer(), {non_neg_integer(), non_neg_integer()}} | nil
  defdelegate token_to_chars(encoding, token), to: Tokenizers.Native, as: :encoding_token_to_chars

  @doc """
  Get the word that contains the token at the given index.
  """
  @spec token_to_word(__MODULE__.t(), non_neg_integer()) ::
          {non_neg_integer(), non_neg_integer()} | nil
  defdelegate token_to_word(encoding, token), to: Tokenizers.Native, as: :encoding_token_to_word

  @doc """
  Get the token that contains the given char.
  """
  @spec char_to_token(__MODULE__.t(), non_neg_integer(), non_neg_integer()) ::
          non_neg_integer() | nil
  defdelegate char_to_token(encoding, position, seq_id),
    to: Tokenizers.Native,
    as: :encoding_char_to_token

  @doc """
  Get the word that contains the given char.
  """
  @spec char_to_word(__MODULE__.t(), non_neg_integer(), non_neg_integer()) ::
          non_neg_integer() | nil
  defdelegate char_to_word(encoding, position, seq_id),
    to: Tokenizers.Native,
    as: :encoding_char_to_word

  @typedoc """
  Options for padding. All options can be ommited.

  * `direction` (default `:right`) - The padding direction.
  * `pad_id` (default `0`) - The id corresponding to the padding token.
  * `pad_type_id` (default `0`) - The type ID corresponding to the padding token.
  * `pad_token` (default `[PDA]`) - The padding token to use.

  """
  @type padding_opts :: [
          pad_id: non_neg_integer(),
          pad_type_id: non_neg_integer(),
          pad_token: String.t(),
          direction: :left | :right
        ]

  @doc """
  Pad the encoding to the given length.
  """
  @spec pad(__MODULE__.t(), non_neg_integer(), padding_opts()) :: __MODULE__.t()
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
  """
  @spec truncate(__MODULE__.t(), non_neg_integer(), truncation_opts()) :: __MODULE__.t()
  defdelegate truncate(encoding, max_length, opts \\ []),
    to: Tokenizers.Native,
    as: :encoding_truncate

  @doc """
  Returns the number of tokens in an `__MODULE__.t()`.
  """
  @spec n_tokens(encoding :: __MODULE__.t()) :: non_neg_integer()
  defdelegate n_tokens(encoding), to: Tokenizers.Native, as: :encoding_get_length
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
