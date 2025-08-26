{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.strings) concatMapStrings;
  # This probably sucks, but how else do I propagate `scripts` to other files without 
  # double importing ./scripts.nix ?
  scripts = import ./scripts.nix {inherit pkgs lib;};
  plugins = import ./config/plugins.nix {inherit pkgs lib scripts;};
  settings = import ./config/settings.nix {inherit pkgs lib scripts;};
  config-files = [
    settings
    plugins
  ];
  # Populate `tmux-main.conf` with imports for other files
  tmux-main = pkgs.writeText "tmux-main.conf" (
    concatMapStrings (x: "source-file " + x + "\n") config-files
  );
in
  pkgs.stdenv.mkDerivation {
    pname = "tmux";
    version = "1.0.0";

    src = ./.;

    nativeBuildInputs = [
      pkgs.makeBinaryWrapper
    ];

    # tmux will use this derivation's hash as its socket name.
    installPhase = ''
      mkdir -p $out/bin
      echo $hash
      makeWrapper ${lib.getExe pkgs.tmux} $out/bin/tmux \
        --add-flags "-f${tmux-main} -L$(basename $out | head -c 32)-nix"
    '';
  }
