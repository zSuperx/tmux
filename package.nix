{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.strings) concatMapStrings;
  scripts = import ./config/scripts.nix {inherit pkgs lib;};
  plugins = import ./config/plugins.nix {inherit pkgs lib scripts;};
  settings = import ./config/settings.nix {inherit pkgs lib scripts;};
  conf-files = [
    settings
    plugins
  ];
  tmux-main = pkgs.writeText "tmux-main.conf" (
    concatMapStrings (x: "source-file " + x + "\n") conf-files
  );
in
  pkgs.stdenv.mkDerivation {
    pname = "tmux";
    version = "1.0.0";

    src = ./.;

    nativeBuildInputs = [
      pkgs.makeBinaryWrapper
    ];

    installPhase = ''
      mkdir -p $out/bin
      echo $hash
      makeWrapper ${lib.getExe pkgs.tmux} $out/bin/tmux \
        --add-flags "-f${tmux-main} -L$(basename $out | head -c 32)-nix"
    '';
  }
