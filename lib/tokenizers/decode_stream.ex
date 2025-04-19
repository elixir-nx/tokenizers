defmodule Tokenizers.DecodeStream do
  @moduledoc """
  Implements streaming decoding functionality for tokenizers.
  """

  @enforce_keys [:resource]
  defstruct [:resource]

  @type t :: %__MODULE__{
          resource: reference()
        }

  @doc """
  Creates a new decode stream.

  The `skip_special_tokens` option determines whether special tokens should be skipped during decoding.
  By default, it is set to `false`.
  """
  @spec new(boolean()) :: t()
  def new(skip_special_tokens \\ false) do
    Tokenizers.Native.decoder_stream_new(skip_special_tokens)
  end

  @doc """
  Steps through the decode stream with the given tokenizer and token ID.

  Returns `{:ok, string}` if there's a decoded string, or `{:ok, nil}` if there's nothing more to decode.
  Returns `{:error, reason}` if an error occurs during decoding.
  """
  def step(%__MODULE__{} = decode_stream, tokenizer, id) when is_integer(id) do
    Tokenizers.Native.decoder_stream_step(decode_stream, tokenizer, id)
  end

  @doc """
  Returns information about the decode stream state.
  """
  defdelegate info(decode_stream), to: Tokenizers.Native, as: :decoder_stream_info

  defimpl Inspect do
    import Inspect.Algebra
    alias Tokenizers.DecodeStream

    def inspect(decode_stream, opts) do
      "#Tokenizers.DecodeStream<#{to_doc(DecodeStream.info(decode_stream), opts)}>"
    end
  end
end
