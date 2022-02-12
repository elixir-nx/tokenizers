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

The [notebooks](./notebooks) directory has [an introductory Livebook](./notebooks/pretrained.livemd) to give you a feel for the API.
