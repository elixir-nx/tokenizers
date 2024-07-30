defmodule Tokenizers.PostProcessor do
  @moduledoc """
  Post-processors.

  After the whole pipeline, we sometimes want to insert some special
  tokens before we feed the encoded text into a model like
  ”[CLS] My horse is amazing [SEP]”, we can do that with a post-processor.
  """

  defstruct [:resource]

  @type t() :: %__MODULE__{resource: reference()}

  @doc """
  Creates a Bert post-processor with the given tokens.
  """
  @spec bert({String.t(), integer()}, {String.t(), integer()}) :: t()
  defdelegate bert(sep, cls), to: Tokenizers.Native, as: :post_processors_bert

  @doc """
  Creates a Roberta post-processor.

  ## Options

    * `:trim_offsets` - whether to trim the whitespaces in the produced
      offsets. Defaults to `true`

    * `:add_prefix_space` - whether add_prefix_space was ON during the
      pre-tokenization. Defaults to `true`

  """
  @spec roberta({String.t(), integer()}, {String.t(), integer()}, keyword()) :: t()
  defdelegate roberta(sep, cls, opts \\ []), to: Tokenizers.Native, as: :post_processors_roberta

  @doc """
  Creates a ByteLevel post-processor.

  ## Options

    * `:trim_offsets` - whether to trim the whitespaces in the produced
      offsets. Defaults to `true`

  """
  @spec byte_level(keyword()) :: t()
  defdelegate byte_level(opts \\ []), to: Tokenizers.Native, as: :post_processors_byte_level

  @doc """
  Creates a Template post-processor.

  Lets you easily template the post processing, adding special tokens
  and specifying the type id for each sequence/special token. The
  template is given two strings representing the single sequence and
  the pair of sequences, as well as a set of special tokens to use.

  For example, when specifying a template with these values:

  * single: `"[CLS] $A [SEP]"`
  * pair: `"[CLS] $A [SEP] $B [SEP]"`
  * special tokens:
    * `"[CLS]"`
    * `"[SEP]"`

  > Input: `("I like this", "but not this")`
  > Output: `"[CLS] I like this [SEP] but not this [SEP]"`

  ## Options

    * `:single` - a string describing the template for a single
      sequence

    * `:pair` - a string describing the template for a pair of
      sequences

    * `:special_tokens` - a list of special tokens to use in the
      template. Must be a list of `{token, token_id}` tuples

  """
  @spec template(keyword()) :: t()
  defdelegate template(opts \\ []), to: Tokenizers.Native, as: :post_processors_template

  @doc """
  Instantiate a new Sequence post-processor
  """
  @spec sequence(post_processors :: [t()]) :: t()
  defdelegate sequence(post_processors), to: Tokenizers.Native, as: :post_processors_sequence
end

defimpl Inspect, for: Tokenizers.PostProcessor do
  import Inspect.Algebra

  def inspect(decoder, opts) do
    attrs =
      decoder
      |> Tokenizers.Native.post_processors_info()
      |> Keyword.new(fn {k, v} -> {String.to_atom(k), v} end)

    concat(["#Tokenizers.PostProcessor<", to_doc(attrs, opts), ">"])
  end
end
