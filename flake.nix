{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = inputs @ {nixpkgs, ...}: let
    systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
  in {
    packages = nixpkgs.lib.genAttrs systems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
      in rec {
        tmux = import ./package.nix {
          inherit pkgs inputs;
          inherit (nixpkgs) lib;
        };

        default = tmux;
      }
    );
  };
}
