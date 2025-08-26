{ pkgs, lib, ... }:
{
  smart-split = pkgs.writeShellScript "tmux-smart-split" ''
    WIDTH=$(($(tmux display -p "#{pane_width}") / 2 - 10));
    HEIGHT=$(tmux display -p "#{pane_height}");

    if [ "$WIDTH" -gt "$HEIGHT" ]; then
      tmux split-window -h;
    else
      tmux split-window -v;
    fi
  '';

  get-battery-icon = pkgs.writeShellScript "get-battery-icon" ''
    battery_info=$(upower -e | grep --line-buffered BAT | head -n 1 | xargs upower -i)

    percent=$(echo "$battery_info" | grep percentage | awk '{ print $2 }' | sed 's/%//g')
    status=$(echo "$battery_info" | grep state | awk '{ print $2 }')

    if [[ "$status" == "charging" ]]; then
      icon="󰂄"
    elif (( percent >= 90 )); then
      icon="󰁹"
    elif (( percent >= 70 )); then
      icon="󰂁"
    elif (( percent >= 50 )); then
      icon="󰂀"
    elif (( percent >= 30 )); then
      icon="󰁾"
    elif (( percent >= 15 )); then
      icon="󰁻"
    else
      icon="!!!"
    fi

    echo "$icon"
  '';
  
  get-battery-capacity = pkgs.writeShellScript "get-battery-capacity" ''
    upower -e | grep --line-buffered BAT | head -n 1 | xargs upower -i | grep percentage | awk '{ print $2 }' | sed 's/%//g'
  '';

  rename-session = pkgs.writeShellScript "rename-session" ''
    tmux send-keys Enter
    tmux choose-session
    tmux command-prompt -p "New session name:" -I "#{session_name}" "rename-session '%%'"
  '';
}
