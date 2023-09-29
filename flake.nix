{
  description = "zap dev shell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";


    # Used for shell.nix
    flake-compat = {
      url = github:edolstra/flake-compat;
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs: let
    # Our supported systems are the same supported systems as the Zig binaries
  in
    flake-utils.lib.eachDefaultSystem (system: let
        pkgs = import nixpkgs {inherit system; };
      in rec {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
              kotlin-language-server
          ];

          buildInputs = with pkgs; [
            # we need a version of bash capable of being interactive
            # as opposed to a bash just used for building this flake
            # in non-interactive mode
            bashInteractive
          ];

          shellHook = ''
            # once we set SHELL to point to the interactive bash, neovim will
            # launch the correct $SHELL in its :terminal
            export SHELL=${pkgs.bashInteractive}/bin/bash
            export LD_LIBRARY_PATH=${pkgs.zlib.out}/lib:${pkgs.icu.out}/lib:${pkgs.openssl.out}/lib:$LD_LIBRARY_PATH
          '';
        };

        packages.default = pkgs.stdenv.mkDerivation {
            name="kotlin language server";
            buildInputs = [
                pkgs.kotlin-language-server
            ];
            unpackPhase = "true";

            installPhase = ''
                mkdir $out
                cp -pr ${pkgs.kotlin-language-server.out}/* $out
            '';
        };
    });
}
