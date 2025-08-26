{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.strings) concatMapStrings;
  inherit (lib) types;
  plugins = import ./config/plugins.nix {inherit pkgs lib;};
  pluginName = p:
    if types.package.check p
    then p.pname
    else p.plugin.pname;
  conf-files = [
    (pkgs.writeText "plugins.conf" ''
      ${
        (lib.concatMapStringsSep "\n\n" (p: ''
            # ${pluginName p}
            # ---------------------
            ${p.extraConfig or ""}
            run-shell ${
              if types.package.check p
              then p.rtp
              else p.plugin.rtp
            }
          '')
          plugins)
      }
    '')

    ./config/settings.conf
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
