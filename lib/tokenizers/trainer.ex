defmodule Tokenizers.Trainer do
  @moduledoc """
  A Trainer has the responsibility to train a model.
  We feed it with lines/sentences and then it can train the given Model.
  """
  defstruct [:resource]
  @type t() :: %__MODULE__{resource: reference()}

  @doc """
  Get trainer info
  """
  @spec info(t()) :: map()
  defdelegate info(trainer), to: Tokenizers.Native, as: :trainers_info

  @doc """
  The actual training method.
  This will mutate a Model as well as return a list of special_tokens to be added directly to the tokenizer along with the model.
  """
  @spec train(t(), Tokenizers.Model.t()) :: {:ok, [String.t()]} | {:error, any()}
  defdelegate train(trainer, model), to: Tokenizers.Native, as: :trainers_train

  @typedoc """
  Options for BPE trainer initialisation. All options can be ommited.
  """
  @type bpe_options() :: [
          vocab_size: non_neg_integer(),
          min_frequency: non_neg_integer(),
          special_tokens: [String.t()],
          limit_alphabet: non_neg_integer(),
          initial_alphabet: [char()],
          show_progress: boolean(),
          continuing_subword_prefix: String.t(),
          end_of_word_suffix: String.t()
        ]

  @doc """
  Creates a new BPE Trainer.
  """
  @spec bpe(bpe_options()) :: {:ok, t()} | {:error, any()}
  defdelegate bpe(options \\ []), to: Tokenizers.Native, as: :trainers_bpe_trainer

  @typedoc """
  Options for WordPiece trainer initialisation. All options can be ommited.
  """
  @type wordpiece_options() :: [
          vocab_size: non_neg_integer(),
          min_frequency: non_neg_integer(),
          special_tokens: [String.t()],
          limit_alphabet: non_neg_integer(),
          initial_alphabet: [char()],
          show_progress: boolean(),
          continuing_subword_prefix: String.t(),
          end_of_word_suffix: String.t()
        ]

  @doc """
  Creates a new WordPiece Trainer.
  """
  @spec wordpiece(wordpiece_options()) :: {:ok, t()} | {:error, any()}
  defdelegate wordpiece(options \\ []), to: Tokenizers.Native, as: :trainers_wordpiece_trainer

  @typedoc """
  Options for WordLevel trainer initialisation. All options can be ommited.
  """
  @type wordlevel_options() :: [
          vocab_size: non_neg_integer(),
          min_frequency: non_neg_integer(),
          special_tokens: [String.t()],
          show_progress: boolean()
        ]

  @doc """
  Creates a new WordLevel Trainer.
  """
  @spec wordlevel(wordlevel_options()) :: {:ok, t()} | {:error, any()}
  defdelegate wordlevel(options \\ []), to: Tokenizers.Native, as: :trainers_wordlevel_trainer

  @typedoc """
  Options for Unigram trainer initialisation. All options can be ommited.
  """
  @type unigram_options() :: [
          vocab_size: non_neg_integer(),
          n_sub_iterations: non_neg_integer(),
          shrinking_factor: float(),
          special_tokens: [String.t()],
          initial_alphabet: [char()],
          uni_token: String.t(),
          max_piece_length: non_neg_integer(),
          seed_size: non_neg_integer(),
          show_progress: boolean()
        ]

  @doc """
  Creates a new Unigram Trainer.
  """
  @spec unigram(unigram_options()) :: {:ok, t()} | {:error, any()}
  defdelegate unigram(options \\ []), to: Tokenizers.Native, as: :trainers_unigram_trainer
end

defimpl Inspect, for: Tokenizers.Trainer do
  import Inspect.Algebra

  @spec inspect(Tokenizers.Trainer.t(), Inspect.Opts.t()) :: Inspect.Algebra.t()
  def inspect(trainer, opts) do
    attrs =
      trainer
      |> Tokenizers.Trainer.info()
      |> Keyword.new(fn {k, v} -> {String.to_atom(k), v} end)

    concat(["#Tokenizers.Trainer<", to_doc(attrs, opts), ">"])
  end
end
