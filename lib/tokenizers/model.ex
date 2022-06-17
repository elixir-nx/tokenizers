defmodule Tokenizers.Model do
  @moduledoc """
  The struct and associated functions for the tokenizer model.
  """

  @type t :: %__MODULE__{resource: binary(), reference: reference()}
  defstruct resource: nil, reference: nil

  alias Tokenizers.Native
  alias Tokenizers.Shared

  @doc """
  Retrieves information about the model.

  Infomration retrieved differs per model but all include `model_type`.
  """
  @spec get_model_details(model :: __MODULE__.t()) :: map()
  def get_model_details(model), do: model |> Native.get_model_details() |> Shared.unwrap()
end

defimpl Inspect, for: Tokenizers.Model do
  import Inspect.Algebra

  alias Tokenizers.Model

  def inspect(model, opts) do
    attrs =
      model
      |> Model.get_model_details()
      |> Keyword.new(fn {k, v} -> {String.to_atom(k), v} end)

    concat(["#Tokenizers.Model<", to_doc(attrs, opts), ">"])
  end
end
