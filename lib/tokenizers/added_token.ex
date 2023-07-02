defmodule Tokenizers.AddedToken do
  @moduledoc """
  This struct represents AddedTokens
  """

  @type t() :: %__MODULE__{resource: reference()}
  defstruct [:resource]

  @doc """
  Create a new AddedToken. You can choos if it's special or not.

  It's created with defaults:

  * `single_word` is `false`
  * `lstrip` is `false`
  * `rstrip` is `false`
  * `normalized` is `true` for not special tokens, `false` for special tokens.
  """
  @spec new(token :: String.t(), is_special :: boolean()) :: t()
  defdelegate new(token, is_special \\ false), to: Tokenizers.Native, as: :added_token_new

  @doc """
  Creates new `AddedToken` from existing with single_word option set.

  Defines whether this token should only match single words.
  If `True`, this token will never match inside of a word.
  For example the token `ing` would match on `tokenizing` if this option is `False`,
  but not if it is `True`.
  The notion of ”inside of a word” is defined by the word boundaries pattern
  in regular expressions (ie. the token should start and end with word boundaries).
  """
  @spec single_word(t(), boolean()) :: t()
  defdelegate single_word(token, single_word), to: Tokenizers.Native, as: :added_token_single_word

  @doc """
  Creates new `AddedToken` from existing with lstrip option set.

  Defines whether this token should strip all potential whitespaces on its left side.
  If `True`, this token will greedily match any whitespace on its left.
  For example if we try to match the token `[MASK]` with `lstrip=True`,
  in the text `"I saw a [MASK]"`, we would match on `" [MASK]"`. (Note the space on the left).
  """
  @spec lstrip(t(), boolean()) :: t()
  defdelegate lstrip(token, lstrip), to: Tokenizers.Native, as: :added_token_lstrip

  @doc """
  Creates new `AddedToken` from existing with rstrip option set.

  Defines whether this token should strip all potential whitespaces on its right side.
  If `True`, this token will greedily match any whitespace on its right.
  It works just like `lstrip` but on the right.
  """
  @spec rstrip(t(), boolean()) :: t()
  defdelegate rstrip(token, rstrip), to: Tokenizers.Native, as: :added_token_rstrip

  @doc """
  Creates new `AddedToken` from existing with normalized option set.

  Defines whether this token should match against the normalized version of the input text.
  For example, with the added token `"yesterday"`,
  and a normalizer in charge of lowercasing the text,
  the token could be extract from the input `"I saw a lion Yesterday"`.
  """
  @spec normalized(t(), boolean()) :: t()
  defdelegate normalized(token, normalized), to: Tokenizers.Native, as: :added_token_normalized
end

defimpl Inspect, for: Tokenizers.AddedToken do
  import Inspect.Algebra

  @spec inspect(Tokenizers.AddedToken.t(), Inspect.Opts.t()) :: Inspect.Algebra.t()
  def inspect(decoder, opts) do
    attrs =
      decoder
      |> Tokenizers.Native.added_token_info()
      |> Keyword.new(fn {k, v} -> {String.to_atom(k), v} end)

    concat(["#Tokenizers.PreTokenizer<", to_doc(attrs, opts), ">"])
  end
end
