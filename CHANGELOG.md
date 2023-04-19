# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [v0.3.2] - 2023-04-19

### Changed

- Bump [tokenizers](https://crates.io/crates/tokenizers) to v0.13.3 in the
  crate's dependencies.

## [v0.3.1] - 2023-04-06

### Added

- Add binary variants for accessing encoding data. This way we can convert encoding
  data to tensors without additional allocations. The following functions were added:

  - `get_u32_ids/1`
  - `get_u32_attention_mask/1`
  - `get_u32_type_ids/1`
  - `get_u32_special_tokens_mask/1`

## [v0.3.0] - 2023-03-04

### Added

- Add option to use cache when downloading pretrained files. We check the ETAG of
  the file before trying to download it. This introduces the `:use_cache` and `:cache_dir`
  options to the `Tokenizers.from_pretrained/2` function.

- Support adding special tokens when creating a tokenizer. This allows a pretrained
  tokenizer to be loaded with additional special tokens.

  This change adds the `:additional_special_tokens` option to the `Tokenizers.from_pretrained/2`
  function.

- Add support for the `riscv64gc-unknown-linux-gnu` target, which is useful for Nerves
  projects running on 64 bits RISC-V computers.
  This means that we are precompiling the project to run on those machines.

### Changed

- Change minimum required version of Rustler Precompiled to `~> 0.6`. With this, we have
  the `aarch64-unknown-linux-musl` and `riscv64gc-unknown-linux-gnu` as default targets.
  But we also drop support for the NIF version 2.14.

## [v0.2.0] - 2022-12-07

### Added

- Add a minimal http server to avoid problems with openssl
- Expose `Encoding.get_special_tokens_mask/1` and `Encoding.get_offsets/1` for NER

## [v0.1.0] - 2022-08-25

First release.

[Unreleased]: https://github.com/elixir-nx/tokenizers/compare/v0.3.2...HEAD
[v0.3.2]: https://github.com/elixir-nx/tokenizers/compare/v0.3.1...v0.3.2
[v0.3.1]: https://github.com/elixir-nx/tokenizers/compare/v0.3.0...v0.3.1
[v0.3.0]: https://github.com/elixir-nx/tokenizers/compare/v0.2.0...v0.3.0
[v0.2.0]: https://github.com/elixir-nx/tokenizers/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/elixir-nx/tokenizers/releases/tag/v0.1.0
