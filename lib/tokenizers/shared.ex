defmodule Tokenizers.Shared do
  @moduledoc false

  def unwrap({:ok, value}), do: value
  def unwrap({:error, reason}), do: raise(reason)
end
