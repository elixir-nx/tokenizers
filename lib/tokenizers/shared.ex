defmodule Tokenizers.Shared do
  @moduledoc false

  # __Private__ shared internal functions.

  def unwrap({:ok, value}), do: value
  def unwrap({:error, reason}), do: raise(reason)
end
