{
  description = "Tokenizers";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [
      flake-utils.lib.system.x86_64-linux
      flake-utils.lib.system.aarch64-darwin
      flake-utils.lib.system.x86_64-darwin
    ] (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs;
            [
              act
              binutils
              cargo
              cc
              clang
              clippy
              elixir
              erlang
              gdb
              gcc
              libiconv
              openssl
              pkg-config
              rustc
            ] ++ lib.optionals stdenv.isDarwin [
              darwin.apple_sdk.frameworks.Foundation
              darwin.apple_sdk.frameworks.Carbon
              darwin.apple_sdk.frameworks.AppKit
            ];
          shellHook = ''
            mkdir -p .nix-mix
            mkdir -p .nix-hex
            export MIX_HOME=$PWD/.nix-mix
            export HEX_HOME=$PWD/.nix-hex
            export PATH=$MIX_HOME/bin:$PATH
            export PATH=$HEX_HOME/bin:$PATH
            export PATH=$MIX_HOME/escripts:$PATH
            export ERL_AFLAGS="-kernel shell_history enabled"
          '';
        };
      });
}
