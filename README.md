# Tokenizers

Elixir bindings for [Hugging Face Tokenizers](https://github.com/huggingface/tokenizers).

## Getting started

In order to use `Tokenizers`, you will need Elixir and Rust (stable) installed. Then create an Elixir project via the `mix` build tool:

```
$ mix new my_app
```

Then you can add `Tokenizers` as dependency in your `mix.exs`. At the moment you will have to use a Git dependency while we work on our first release:

```elixir
def deps do
  [
    {:tokenizers, "~> 0.1.0-dev", github: "elixir-nx/tokenizers", branch: "main"},
  ]
end
```

If you are using Livebook or IEx, you can instead run:

```elixir
Mix.install([
  {:tokenizers, "~> 0.1.0-dev", github: "elixir-nx/tokenizers", branch: "main"},
])
```

## Quick example

```elixir
# Go get a tokenizer -- any from the Hugging Face models repo will do
{:ok, tokenizer} = Tokenizers.from_pretrained("bert-base-cased")
{:ok, encoding} = Tokenizers.encode(tokenizer, "Hello there!")
Tokenizers.get_tokens(encoding)
# {:ok, ["Hello", "there", "!"]}
Tokenizers.get_ids(encoding)
# {:ok, [8667, 1175, 106]}
```

The [notebooks](./notebooks) directory has [an introductory Livebook](./notebooks/pretrained.livemd) to give you a feel for the API.

While this project is prerelease, the docs can be accessed on [GitHub pages](https://elixir-nx.github.io/tokenizers/).

## License

Copyright (c) 2022 Christopher Grainger

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
