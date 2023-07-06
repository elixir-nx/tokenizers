defmodule Tokenizers.AddedToken do
  @moduledoc """
  This struct represents AddedTokens
  """

  @type t() :: %__MODULE__{resource: reference()}
  defstruct [:resource]

  @typedoc """
  Options for added token initialisation. All options can be ommited.
  """
  @type opts() :: [
          special: boolean(),
          single_word: boolean(),
          lstrip: boolean(),
          rstrip: boolean(),
          normalized: boolean()
        ]

  @doc """
  Create a new AddedToken.

  * `special` (deafult `false`) - defines whether this token is a special token.
  * `single_word` (default `false`) - defines whether this token should only match single words.
    If `True`, this token will never match inside of a word.
    For example the token `ing` would match on `tokenizing` if this option is `False`,
    but not if it is `True`.
    The notion of ”inside of a word” is defined by the word boundaries pattern
    in regular expressions (ie. the token should start and end with word boundaries).
  * `lstrip` (default `false`) - defines whether this token should strip all potential whitespaces on its left side.
    If `True`, this token will greedily match any whitespace on its left.
    For example if we try to match the token `[MASK]` with `lstrip=True`,
    in the text `"I saw a [MASK]"`, we would match on `" [MASK]"`. (Note the space on the left).
  * `rstrip` (default `false`) - defines whether this token should strip all potential whitespaces on its right side.
    If `True`, this token will greedily match any whitespace on its right.
    It works just like `lstrip` but on the right.
  * `normalized` (default `true` for not special tokens, `false` for special tokens) - defines whether this token should match against the normalized version of the input text.
    For example, with the added token `"yesterday"`,
    and a normalizer in charge of lowercasing the text,
    the token could be extract from the input `"I saw a lion Yesterday"`.
    If `True`, the token will be extracted from the normalized input `"i saw a lion yesterday"`.
    If `False`, the token will be extracted from the original input `"I saw a lion Yesterday"`.
  """
  @spec new(token :: String.t(), opts :: opts()) :: t()
  defdelegate new(token, opts \\ []), to: Tokenizers.Native, as: :added_token_new

  @doc """
  Retrieves information about added token.
  """
  @spec info(added_token :: __MODULE__.t()) :: map()
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

    concat(["#Tokenizers.PreTokenizer<", to_doc(attrs, opts), ">"])
  end
end
