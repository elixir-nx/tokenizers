defmodule Tokenizers.Model.WordLevel do
  @typedoc """
  Options for model initialisation. All options can be ommited.

  * `:unk_token` (default `"[UNK]"`) - The unknown token to be used by the model.
  """
  @type options() :: [
          unk_token: String.t()
        ]

  @doc """
  Instantiate a WordLevel model from the given vocab
  """
  @spec init(
          vocab :: %{String.t() => integer()},
          options :: options()
        ) :: {:ok, Tokenizers.Model.t()}
  defdelegate init(vocab, options \\ []),
    to: Tokenizers.Native,
    as: :models_wordlevel_init

  @doc """
  Instantiate an empty WordLevel model
  """
  @spec empty() :: {:ok, Tokenizers.Model.t()}
  defdelegate empty(), to: Tokenizers.Native, as: :models_wordlevel_empty

  @doc """
  Instantiate a WordLevel model from the given vocab file
  """
  @spec from_file(
          vocab :: String.t(),
          options :: options()
        ) :: {:ok, Tokenizers.Model.t()}
  defdelegate from_file(vocab, options \\ []),
    to: Tokenizers.Native,
    as: :models_wordlevel_from_file
end
