defmodule Tokenizers do
  @moduledoc """
  Elixir bindings to [Hugging Face Tokenizers](https://github.com/huggingface/tokenizers).

  Hugging Face describes the Tokenizers library as:

  > Fast State-of-the-art tokenizers, optimized for both research and production
  >
  > 🤗 Tokenizers provides an implementation of today’s most used tokenizers, with a focus on performance and versatility. These tokenizers are also used in 🤗 Transformers.

  This library has bindings to use pretrained tokenizers. Support for building and training
  a tokenizer from scratch is forthcoming.

  A tokenizer is effectively a pipeline of transforms to take some input text and return a
  `Tokenizers.Encoding.t()`. The main entrypoint to this library is the `Tokenizers.Tokenizer`
  module, which holds the `Tokenizers.Tokenizer.t()` struct, a container holding the constituent
  parts of the pipeline. Most functionality is there.
  """
end
