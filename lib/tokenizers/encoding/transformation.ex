defmodule Tokenizers.Encoding.Transformation do
  @moduledoc """
  Module containing handy functions to build the transformations list.

  This list is aplied to an encoding using `Tokenizers.Encoding.transform/2`.
  """

  @type t :: [
          {:pad, {non_neg_integer(), Tokenizers.Encoding.padding_opts()}},
          {:truncate, {non_neg_integer(), Tokenizers.Encoding.truncation_opts()}},
          {:set_sequence_id, non_neg_integer()}
        ]

  @doc """
  Generates the padding transformation.

  Check `Tokenizers.Encoding.pad/3` for more information.
  """
  @spec pad(non_neg_integer(), Tokenizers.Encoding.padding_opts()) ::
          {:pad, {non_neg_integer(), Tokenizers.Encoding.padding_opts()}}
  def pad(target_length, opts \\ []) do
    {:pad, {target_length, opts}}
  end

  @doc """
  Generates the truncation transformation.

  Check `Tokenizers.Encoding.truncate/3` for more information.
  """
  @spec truncate(non_neg_integer(), Tokenizers.Encoding.truncation_opts()) ::
          {:truncate, {non_neg_integer(), Tokenizers.Encoding.truncation_opts()}}
  def truncate(max_length, opts \\ []) do
    {:truncate, {max_length, opts}}
  end

  @doc """
  Generates the set_sequence_id transformation.

  Check `Tokenizers.Encoding.set_sequence_id/2` for more information.
  """
  @spec set_sequence_id(non_neg_integer()) ::
          {:set_sequence_id, non_neg_integer()}
  def set_sequence_id(id) do
    {:set_sequence_id, id}
  end
end
