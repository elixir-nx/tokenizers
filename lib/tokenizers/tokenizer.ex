defmodule Tokenizers.Tokenizer do
  @type t :: %__MODULE__{resource: binary(), reference: reference()}
  defstruct resource: nil, reference: nil

  alias Tokenizers.Native
  alias Tokenizers.Shared

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
  @spec get_vocab(Tokenizer.t()) :: %{binary() => integer()}
  def get_vocab(tokenizer), do: tokenizer |> Native.get_vocab(false) |> Shared.unwrap()

  @doc """
  Get the number of tokens in the vocabulary.
  """
  @spec get_vocab_size(Tokenizer.t()) :: non_neg_integer()
  def get_vocab_size(tokenizer), do: tokenizer |> Native.get_vocab_size(true) |> Shared.unwrap()

  @doc """
  Convert a given id to its token.
  """
  @spec id_to_token(Tokenizer.t(), integer()) :: String.t()
  def id_to_token(tokenizer, id), do: tokenizer |> Native.id_to_token(id) |> Shared.unwrap()

  @doc """
  Convert a given token to its id.
  """
  @spec token_to_id(Tokenizer.t(), binary()) :: non_neg_integer()
  def token_to_id(tokenizer, token), do: tokenizer |> Native.token_to_id(token) |> Shared.unwrap()
end

defimpl Inspect, for: Tokenizers.Tokenizer do
  import Inspect.Algebra

  alias Tokenizers.Tokenizer

  def inspect(tokenizer, opts) do
    attrs = [vocab_size: Tokenizer.get_vocab_size(tokenizer)]
    concat(["#Tokenizer<", to_doc(attrs, opts), ">"])
  end
end
