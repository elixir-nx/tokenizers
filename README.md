# Tokenizers

![CI](https://github.com/elixir-nx/explorer/actions/workflows/ci.yml/badge.svg)

Elixir bindings for [Hugging Face Tokenizers](https://github.com/huggingface/tokenizers).

## Installation

You can add `:tokenizers` as dependency in your `mix.exs`:

```elixir
def deps do
  [
    {:tokenizers, "~> 0.3.0"},
  ]
end
```

If you are using Livebook or IEx, you can instead run:

```elixir
Mix.install([
  {:tokenizers, "~> 0.3.0"},
])
```

## Example

You can use any pre-trained tokenizer from any model repo on Hugging Face Hub, such as [bert-base-cased](https://huggingface.co/bert-base-cased).

```elixir
{:ok, tokenizer} = Tokenizers.Tokenizer.from_pretrained("bert-base-cased")
{:ok, encoding} = Tokenizers.Tokenizer.encode(tokenizer, "Hello there!")
Tokenizers.Encoding.get_tokens(encoding)
#=> ["Hello", "there", "!"]
Tokenizers.Encoding.get_ids(encoding)
#=> [8667, 1175, 106]
```

The [notebooks](./notebooks) directory has [an introductory Livebook](./notebooks/pretrained.livemd) to give you a feel for the API.

## Contributing

Tokenizers uses Rust to call functionality from the Hugging Face Tokenizers library. While
Rust is not necessary to use Tokenizers as a package, you need Rust tooling installed on
your machine if you want to compile from source, which is the case when contributing to
Tokenizers. In particular, you will need Rust Stable, which can be installed with
[Rustup](https://rust-lang.github.io/rustup/installation/index.html).

## License

Copyright (c) 2022 Christopher Grainger

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
