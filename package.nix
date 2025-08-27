{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.strings) concatMapStrings;
  scripts = pkgs.callPackage ./scripts.nix {};
  plugins = pkgs.callPackage ./config/plugins.nix { inherit scripts; };
  settings = pkgs.callPackage ./config/settings.nix { inherit scripts; };
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
    inherit (pkgs.tmux) pname version;

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
