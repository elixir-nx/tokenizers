defmodule Tokenizers.Tokenizer do
  @moduledoc """
  The struct and associated functions for a tokenizer.

  A `Tokenizers.Tokenizer.t()` is a container that holds the constituent parts of the tokenization pipeline.

  When you call `Tokenizers.Tokenizer.encode/3`, the input text goes through the following pipeline:

  - normalization
  - pre-tokenization
  - model
  - post-processing

  This returns a `Tokenizers.Encoding.t()`, which can then give you the token ids for each token in the input text. These token ids are usually used as the input for natural language processing machine learning models.
  """

  @type t :: %__MODULE__{resource: binary(), reference: reference()}
  defstruct resource: nil, reference: nil

  alias Tokenizers.Model
  alias Tokenizers.Native
  alias Tokenizers.Shared

  @doc """
  Instantiate a new tokenizer from an existing file on the Hugging Face Hub.
  """
  @spec from_pretrained(String.t()) :: {:ok, Tokenizer.t()} | {:error, term()}
  def from_pretrained(identifier), do: Native.from_pretrained(identifier)

  @doc """
  Instantiate a new tokenizer from the file at the given path.
  """
  @spec from_file(String.t()) :: {:ok, Tokenizer.t()} | {:error, term()}
  def from_file(path), do: Native.from_file(path)

  @doc """
  Save the tokenizer to the provided path.
  """
  @spec save(Tokenizer.t(), String.t()) :: {:ok, String.t()} | {:error, term()}
  def save(tokenizer, path) do
    case Native.save(tokenizer, path, true) do
      {:ok, _} -> {:ok, path}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Encode the given sequence or batch of sequences to a `Tokenizers.Encoding.t()`.
  """
  @spec encode(Tokenizer.t(), String.t() | [String.t()], Keyword.t()) ::
          {:ok, Encoding.t() | [Encoding.t()]} | {:error, term()}
  def encode(tokenizer, input, opts \\ []) do
    add_special_tokens = Keyword.get(opts, :add_special_tokens, false)
    do_encode(tokenizer, input, add_special_tokens)
  end

  defp do_encode(tokenizer, input, add_special_tokens) when is_binary(input) do
    Native.encode(tokenizer, input, add_special_tokens)
  end

  defp do_encode(tokenizer, input, add_special_tokens) when is_list(input) do
    Native.encode_batch(tokenizer, input, add_special_tokens)
  end

  @doc """
  Decode the given list of ids or list of lists of ids back to strings.
  """
  @spec decode(Tokenizer.t(), non_neg_integer() | [non_neg_integer()], Keyword.t()) ::
          {:ok, String.t() | [String.t()]} | {:error, term()}
  def decode(tokenizer, ids, opts \\ []) do
    skip_special_tokens = Keyword.get(opts, :skip_special_tokens, false)
    do_decode(tokenizer, ids, skip_special_tokens)
  end

  defp do_decode(tokenizer, [first | _] = ids, skip_special_tokens) when is_integer(first),
    do: Native.decode(tokenizer, ids, skip_special_tokens)

  defp do_decode(tokenizer, [first | _] = ids, skip_special_tokens) when is_list(first),
    do: Native.decode_batch(tokenizer, ids, skip_special_tokens)

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

  @doc """
  Get the `Tokenizer`'s `Model`.
  """
  @spec get_model(Tokenizer.t()) :: Model.t()
  def get_model(tokenizer), do: tokenizer |> Native.get_model() |> Shared.unwrap()
end

defimpl Inspect, for: Tokenizers.Tokenizer do
  import Inspect.Algebra

  alias Tokenizers.Model
  alias Tokenizers.Tokenizer

  def inspect(tokenizer, opts) do
    model_details =
      tokenizer
      |> Tokenizer.get_model()
      |> Model.get_model_details()
      |> Keyword.new(fn {k, v} -> {String.to_atom(k), v} end)

    attrs =
      Keyword.merge(
        [
          vocab_size: Tokenizer.get_vocab_size(tokenizer)
        ],
        model_details
      )

    concat(["#Tokenizers.Tokenizer<", to_doc(attrs, opts), ">"])
  end
end
