defmodule Tokenizers.AddedToken do
  @moduledoc """
  This struct represents a token added to tokenizer vocabulary.
  """

  @type t() :: %__MODULE__{resource: reference()}
  defstruct [:resource]

  @doc """
  Builds a new added token.

  ## Options

    * `:special` - defines whether this token is a special token.
      Defaults to `false`

    * `:single_word` - defines whether this token should only match
      single words. If `true`, this token will never match inside of a
      word. For example the token `ing` would match on `tokenizing` if
      this option is `false`. The notion of ”inside of a word” is
      defined by the word boundaries pattern in regular expressions
      (i.e. the token should start and end with word boundaries).
      Defaults to `false`

    * `:lstrip` - defines whether this token should strip all potential
      whitespace on its left side. If `true`, this token will greedily
      match any whitespace on its left. For example if we try to match
      the token `[MASK]` with `lstrip=true`, in the text `"I saw a [MASK]"`,
      we would match on `" [MASK]"`. (Note the space on the left).
      Defaults to `false`

    * `:rstrip` - defines whether this token should strip all potential
      whitespaces on its right side. If `true`, this token will greedily
      match any whitespace on its right. It works just like `:lstrip`,
      but on the right. Defaults to `false`

    * `:normalized` - defines whether this token should match against
      the normalized version of the input text. For example, with the
      added token `"yesterday"`, and a normalizer in charge of
      lowercasing the text, the token could be extract from the input
      `"I saw a lion Yesterday"`. If `true`, the token will be extracted
      from the normalized input `"i saw a lion yesterday"`. If `false`,
      the token will be extracted from the original input
      `"I saw a lion Yesterday"`. Defaults to `false` for special tokens
      and `true` otherwise

  """
  @spec new(token :: String.t(), keyword()) :: t()
  defdelegate new(token, opts \\ []), to: Tokenizers.Native, as: :added_token_new

  @doc """
  Retrieves information about added token.
  """
  @spec info(added_token :: t()) :: map()
  defdelegate info(model), to: Tokenizers.Native, as: :added_token_info
end

defimpl Inspect, for: Tokenizers.AddedToken do
  import Inspect.Algebra

  @spec inspect(Tokenizers.AddedToken.t(), Inspect.Opts.t()) :: Inspect.Algebra.t()
  def inspect(decoder, opts) do
    attrs =
      decoder
      |> Tokenizers.Native.added_token_info()
      |> Keyword.new(fn {k, v} -> {String.to_atom(k), v} end)

    concat(["#Tokenizers.AddedToken<", to_doc(attrs, opts), ">"])
  end
end
