{
  pkgs,
  lib,
  scripts,
}: let
  inherit (lib) types;
  pluginName = p:
    if types.package.check p
    then p.pname
    else p.plugin.pname;

  plugins = with pkgs.tmuxPlugins; [
    battery
    tmux-fzf
    {
      plugin = catppuccin;
      extraConfig = ''
        set -g @catppuccin_flavor "mocha"
        set -g @catppuccin_window_status_style "slanted"

        # Make the status line pretty and add some modules
        set -g status-right-length 100
        set -g status-left-length 100
        set -g status-left ""

        set -g status-right ""
        set -ag status-right "#{E:@catppuccin_status_application}"

        set -ag status-right '#{?pane_synchronized,#[bg=#{@thm_green}],#[bg=#{@thm_red}]}#[fg#{@thm_mantle}]#[reverse]#[noreverse]'
        set -ag status-right '#{?pane_synchronized,#[bg=#{@thm_green}],#[bg=#{@thm_red}]}#[fg#{@thm_crust}]  '
        set -ag status-right "#[fg=#{@thm_fg},bg=#{@thm_surface_0}] sync "

        set -ag status-right "#{E:@catppuccin_status_session}"
        set -ag status-right "#{E:@catppuccin_status_date_time}"

        set -ag status-right "#[bg=#{@thm_yellow},fg=#{@thm_surface_0}]#[reverse]#[noreverse]"
        set -ag status-right "#[bg=#{@thm_yellow},fg=#{@thm_crust}]#(${scripts.get-battery-icon}) "
        set -ag status-right "#[fg=#{@thm_fg},bg=#{@thm_surface_0}] #(${scripts.get-battery-capacity})% "

        # Stylix Theme

        set -ogq @thm_bg "#3b4252"
        set -ogq @thm_fg "#e5e9f0"

        # Colors
        set -ogq @thm_rosewater "#eceff4"
        set -ogq @thm_flamingo "#5e81ac"
        set -ogq @thm_pink "#5e81ac"
        set -ogq @thm_mauve "#b48ead"
        set -ogq @thm_red "#bf616a"
        set -ogq @thm_maroon "#bf616a"
        set -ogq @thm_peach "#d08770"
        set -ogq @thm_yellow "#ebcb8b"
        set -ogq @thm_green "#a3be8c"
        set -ogq @thm_teal "#88c0d0"
        set -ogq @thm_sky "#88c0d0"
        set -ogq @thm_sapphire "#81a1c1"
        set -ogq @thm_blue "#81a1c1"
        set -ogq @thm_lavender "#8fbcbb"

        # Surfaces and overlays
        set -ogq @thm_subtext_0 "#bac2de"
        set -ogq @thm_subtext_1 "#a6adc8"

        set -ogq @thm_overlay_0 "#6c7086"
        set -ogq @thm_overlay_1 "#7f849c"
        set -ogq @thm_overlay_2 "#9399b2"

        set -ogq @thm_surface_0 "#434c5e"
        set -ogq @thm_surface_1 "#4c566a"
        set -ogq @thm_surface_2 "#d8dee9"

        set -ogq @thm_mantle "#3b4252"
        set -ogq @thm_crust "#11111b"
      '';
    }
  ];
in
  pkgs.writeText "plugins.conf" ''
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
  ''
