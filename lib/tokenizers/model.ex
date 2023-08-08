defmodule Tokenizers.Model do
  @moduledoc """
  The struct and associated functions for the tokenizer model.
  """

  defstruct [:resource]

  @typedoc """
  Represents different kind of models that can be used across the library.
  """
  @type t() :: %__MODULE__{resource: reference()}

  @doc """
  Retrieves information about the model.

  Information retrieved differs per model but all include `model_type`.
  """
  @spec info(t()) :: map()
  defdelegate info(model), to: Tokenizers.Native, as: :models_info

  @doc """
  Saves the given model in the given directory.

  This function generates a couple files with predefined names, you
  can specify `:prefix` to scope them. Existing files with the same
  names in this directory will be overridden.

  ## Options

    * `:prefix` - the prefix to use for all the files that will get
      created. Defaults to `""`

  """
  @spec save(t(), String.t(), keyword()) :: {:ok, file_paths :: [String.t()]} | {:error, any()}
  defdelegate save(model, directory, opts \\ []), to: Tokenizers.Native, as: :models_save
end

defimpl Inspect, for: Tokenizers.Model do
  import Inspect.Algebra

  alias Tokenizers.Model

  @spec inspect(Tokenizers.Model.t(), Inspect.Opts.t()) :: Inspect.Algebra.t()
  def inspect(model, opts) do
    attrs =
      model
      |> Model.info()
      |> Keyword.new(fn {k, v} -> {String.to_atom(k), v} end)

    concat(["#Tokenizers.Model<", to_doc(attrs, opts), ">"])
  end
end
