defmodule Tokenizers.PostProcessor do
  @moduledoc """
  After the whole pipeline, we sometimes want to insert some special tokens
  before feed a tokenized string into a model like ”[CLS] My horse is amazing [SEP]”.
  The PostProcessor is the component doing just that.
  """

  @type t() :: %__MODULE__{resource: reference()}
  defstruct [:resource]

  @doc """
  Instantiate a new BertProcessing with the given tokens

  Params are tuple with the string representation of the token, and its id
  """
  @spec bert(
          sep :: {String.t(), integer()},
          cls :: {String.t(), integer()}
        ) :: t()
  defdelegate bert(sep, cls), to: Tokenizers.Native, as: :post_processors_bert

  @typedoc """
  Options for Roberta post-processor. All values are optional.

  * `:trim_offest` (default `true`) - Whether to trim the whitespaces in the produced offsets
  * `:add_prefix_space` (default `true`) - Whether add_prefix_space was ON during the pre-tokenization.
  """
  @type roberta_opts() :: [
          trim_offsets: boolean(),
          add_prefix_space: boolean()
        ]

  @doc """
  Creates Roberta post-processor.
  """
  @spec roberta(
          sep :: {String.t(), integer()},
          cls :: {String.t(), integer()},
          opts :: roberta_opts()
        ) :: t()
  defdelegate roberta(sep, cls, opts \\ []), to: Tokenizers.Native, as: :post_processors_roberta

  @typedoc """
  Options for ByteLevel post-processor. All values are optional.

  * `:trim_offsets` (default `true`) - Whether to trim the whitespaces in the produced offsets
  """
  @type byte_level_opts() :: [
          trim_offsets: boolean()
        ]

  @doc """
  Creates ByteLevel post-processor.
  """
  @spec byte_level(opts :: byte_level_opts()) :: t()
  defdelegate byte_level(opts \\ []), to: Tokenizers.Native, as: :post_processors_byte_level

  @typedoc """
  Options for Template post-processor.

  * `:single` - A string describing the template for a single sequence.
  * `:pair` - A string describing the template for a pair of sequences.
  * `:special_tokens` - A list of special tokens to use in the template.
  """
  @type template_opts() :: [
          single: String.t(),
          pair: String.t(),
          special_tokens: [{String.t(), integer()}]
        ]

  @doc """
  Creates Template post-processor.

  Let’s you easily template the post processing, adding special tokens,
  and specifying the type_id for each sequence/special token.
  The template is given two strings representing the single sequence and the pair of sequences,
  as well as a set of special tokens to use.

  Example, when specifying a template with these values:

  * single: `"[CLS] $A [SEP]"`
  * pair: `"[CLS] $A [SEP] $B [SEP]"`
  * special tokens:
    * `"[CLS]"`
    * `"[SEP]"`

  > Input: `("I like this", "but not this")`
  > Output: `"[CLS] I like this [SEP] but not this [SEP]"`
  """
  @spec template(opts :: template_opts()) :: t()
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
