defmodule Tokenizers.Tokenizer do
  @type t :: %__MODULE__{resource: binary(), reference: reference()}
  defstruct resource: nil, reference: nil
end
