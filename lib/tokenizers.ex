defmodule Tokenizers do
  @moduledoc """
  Elixir bindings to [Hugging Face Tokenizers](https://github.com/huggingface/tokenizers).

  Hugging Face describes the Tokenizers library as:

  > Fast State-of-the-art tokenizers, optimized for both research and
  > production
  >
  > 🤗 Tokenizers provides an implementation of today’s most used
  > tokenizers, with a focus on performance and versatility. These
  > tokenizers are also used in 🤗 Transformers.

  A tokenizer is effectively a pipeline of transformations that take
  a text input and return an encoded version of that text (`t:Tokenizers.Encoding.t/0`).

  The main entrypoint to this library is the `Tokenizers.Tokenizer`
  module, which defines the `t:Tokenizers.Tokenizer.t/0` struct, a
  container holding the constituent parts of the pipeline. Most
  functionality is in that module.
  """
end
