defmodule Tokenizers.Model do
  @moduledoc """
  The struct and associated functions for the tokenizer model.
  """

  @typedoc """
  Represents different kind of models that can be used across the library.
  """
  @type t() :: %__MODULE__{resource: reference()}
  defstruct [:resource]

  @doc """
  Retrieves information about the model.

  Information retrieved differs per model but all include `model_type`.
  """
  @spec info(model :: __MODULE__.t()) :: map()
  defdelegate info(model), to: Tokenizers.Native, as: :models_info

  @doc """
  Save the current model in the given folder, using the given name for the various files that will get created.
  Any file with the same name that already exist in this folder will be overwritten.
  """
  @spec save(model :: t(), folder :: String.t(), prefix :: String.t()) ::
          {:ok, file_pathes :: [String.t()]} | {:error, any()}
  defdelegate save(model, folder, prefix \\ ""), to: Tokenizers.Native, as: :models_save
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
