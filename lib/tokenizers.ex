defmodule Tokenizers do
  @moduledoc """
  Documentation for `Tokenizers`.
  """

  alias Tokenizers.Encoding
  alias Tokenizers.Tokenizer
  alias Tokenizers.Native

  @doc """
  Instantiate a new tokenizer from an existing file on the Hugging Face Hub.
  """
  @spec from_pretrained(binary()) :: Tokenizer.t()
  def from_pretrained(identifier), do: Native.from_pretrained(identifier)

  @doc """
  Instantiate a new tokenizer from the file at the given path.
  """
  @spec from_file(binary()) :: Tokenizer.t()
  def from_file(path), do: Native.from_file(path)

  @doc """
  Save the tokenizer to the provided path.
  """
  @spec save(Tokenizer.t(), binary()) :: term()
  def save(tokenizer, path), do: Native.save(tokenizer, path, true)

  @doc """
  Encode the given sequence or batch of sequences to ids.
  """
  @spec encode(Tokenizer.t(), binary() | [binary()]) :: Encoding.t() | [Encoding.t()]
  def encode(tokenizer, input) when is_binary(input), do: Native.encode(tokenizer, input, false)

  def encode(tokenizer, input) when is_list(input),
    do: Native.encode_batch(tokenizer, input, false)

  @doc """
  Decode the given list of ids or list of lists of ids back to strings.
  """
  @spec decode(Tokenizer.t(), binary() | [binary()]) ::
          {:ok, Encoding.t() | [Encoding.t()]} | {:error, term()}
  def decode(tokenizer, [first | _] = ids) when is_integer(first),
    do: Native.decode(tokenizer, ids, false)

  def decode(tokenizer, [first | _] = ids) when is_list(first),
    do: Native.decode_batch(tokenizer, ids, false)

  @doc """
  Get the tokenizer's vocabulary as a map of token to id.
  """
  @spec get_vocab(Tokenizer.t()) :: {:ok, %{binary() => integer()}} | {:error, term()}
  def get_vocab(tokenizer), do: Native.get_vocab(tokenizer, false)

  @doc """
  Get the number of tokens in the vocabulary.
  """
  @spec get_vocab_size(Tokenizer.t()) :: {:ok, integer()} | {:error, term()}
  def get_vocab_size(tokenizer), do: Native.get_vocab_size(tokenizer, false)

  @doc """
  Get the tokens from an encoding.
  """
  @spec get_tokens(Encoding.t()) :: {:ok, [binary()]} | {:error, term()}
  def get_tokens(encoding), do: Native.get_tokens(encoding)

  @doc """
  Get the ids from an encoding.
  """
  @spec get_ids(Encoding.t()) :: {:ok, [integer()]} | {:error, term()}
  def get_ids(encoding), do: Native.get_ids(encoding)

  @doc """
  Get the attention_mask from an encoding.
  """
  @spec get_attention_mask(Encoding.t()) :: {:ok, [integer()]} | {:error, term()}
  def get_attention_mask(encoding), do: Native.get_attention_mask(encoding)

  @doc """
  Convert a given id to its token.
  """
  @spec id_to_token(Tokenizer.t(), integer()) :: {:ok, binary()} | {:error, term()}
  def id_to_token(tokenizer, id), do: Native.id_to_token(tokenizer, id)

  @doc """
  Convert a given token to its id.
  """
  @spec token_to_id(Tokenizer.t(), binary()) :: {:ok, integer()} | {:error, term()}
  def token_to_id(tokenizer, token), do: Native.token_to_id(tokenizer, token)

  @doc """
  Truncate the encoding to the given length.

  ## Options
    * `direction` - The truncation direction. Can be `:right` or `:left`. Default: `:right`.
    * `stride` - The length of previous content to be included in each overflowing piece. Default: `0`.
  """
  @spec truncate(encoding :: Encoding.t(), length :: integer(), opts :: Keyword.t()) ::
          {:ok, Encoding.t()} | {:error, term()}
  def truncate(encoding, max_len, opts \\ []) do
    opts = Keyword.validate!(opts, direction: :right, stride: 0)
    Native.truncate(encoding, max_len, opts[:stride], "#{opts[:direction]}")
  end

  @doc """
  Pad the encoding to the given length.

  ## Options
    * `direction` - The padding direction. Can be `:right` or `:left`. Default: `:right`.
    * `pad_id` - The id corresponding to the padding token. Default: `0`.
    * `pad_token` - The padding token to use. Default: `"[PAD]"`.
    * `pad_type_id` - The type ID corresponding to the padding token. Default: `0`.
  """
  @spec pad(encoding :: Encoding.t(), length :: pos_integer(), opts :: Keyword.t()) ::
          Encoding.t()
  def pad(encoding, length, opts \\ []) do
    opts =
      Keyword.validate!(opts, direction: :right, pad_id: 0, pad_type_id: 0, pad_token: "[PAD]")

    Native.pad(
      encoding,
      length,
      opts[:pad_id],
      opts[:pad_type_id],
      opts[:pad_token],
      "#{opts[:direction]}"
    )
  end
end
