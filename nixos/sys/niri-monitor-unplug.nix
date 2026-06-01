{ lib, pkgs, unstable, ... }:

let
  flattenAfterMonitorUnplug = pkgs.writeShellScript "niri-flatten-after-monitor-unplug" ''
    set -euo pipefail

    ${pkgs.coreutils}/bin/sleep 1

    runtime="/run/user/$(${pkgs.coreutils}/bin/id -u)"
    [ -d "$runtime" ] || exit 0

    niri_socket="$(${pkgs.findutils}/bin/find "$runtime" -maxdepth 1 -type s -name 'niri.*.sock' -print -quit)"
    [ -n "$niri_socket" ] || exit 0

    export XDG_RUNTIME_DIR="$runtime"
    export NIRI_SOCKET="$niri_socket"
    export PATH="${lib.makeBinPath [
      unstable.niri
      pkgs.bash
      pkgs.coreutils
      pkgs.jq
    ]}:$PATH"

    ${pkgs.bash}/bin/bash /home/stephen/bin/niri-flatten-workspaces.sh
  '';
in
{
  systemd.services.niri-flatten-after-monitor-unplug = {
    description = "Flatten niri workspaces after external monitor unplug";
    serviceConfig = {
      Type = "oneshot";
      User = "stephen";
      ExecStart = flattenAfterMonitorUnplug;
    };
  };

  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="drm", KERNEL=="card*-DP-*", ATTR{status}=="disconnected", RUN+="${pkgs.systemd}/bin/systemctl --no-block start niri-flatten-after-monitor-unplug.service"
    ACTION=="change", SUBSYSTEM=="drm", KERNEL=="card*-HDMI-A-*", ATTR{status}=="disconnected", RUN+="${pkgs.systemd}/bin/systemctl --no-block start niri-flatten-after-monitor-unplug.service"
  '';
}
