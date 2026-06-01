{ lib, pkgs, unstable, ... }:

let
  niriMonitorUnplugListener = pkgs.writeShellScriptBin "niri-monitor-unplug-listener" ''
    set -u

    export PATH="${lib.makeBinPath [
      unstable.niri
      pkgs.bash
      pkgs.coreutils
      pkgs.findutils
      pkgs.jq
      pkgs.util-linux
    ]}:$PATH"

    if [ -z "''${XDG_RUNTIME_DIR:-}" ]; then
      export XDG_RUNTIME_DIR="/run/user/$(id -u)"
    fi

    state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}"
    mkdir -p "$state_dir"
    log_file="$state_dir/niri-monitor-unplug.log"

    log() {
      printf '%s %s\n' "$(date --iso-8601=seconds)" "$*" >> "$log_file"
    }

    find_niri_socket() {
      if [ -n "''${NIRI_SOCKET:-}" ] && [ -S "$NIRI_SOCKET" ]; then
        return 0
      fi

      niri_socket="$(find "$XDG_RUNTIME_DIR" -maxdepth 1 -type s -name 'niri.*.sock' -print -quit)"
      if [ -z "$niri_socket" ]; then
        return 1
      fi

      export NIRI_SOCKET="$niri_socket"
    }

    lock_file="$XDG_RUNTIME_DIR/niri-monitor-unplug-listener.lock"
    exec 9>"$lock_file"
    flock -n 9 || exit 0

    flatten_workspaces() {
      sleep 1
      if ${pkgs.bash}/bin/bash /home/stephen/bin/niri-flatten-workspaces.sh >> "$log_file" 2>&1; then
        log "flattened workspaces after monitor unplug"
      else
        status=$?
        log "flatten script failed with status $status"
      fi
    }

    if ! find_niri_socket; then
      log "no niri socket found"
      exit 0
    fi

    log "watching $NIRI_SOCKET"
    prev=""

    while IFS= read -r event; do
      next="$(
        jq -r '
          if has("WorkspacesChanged") then
            [
              .WorkspacesChanged.workspaces[].output
              | select(test("^(eDP|LVDS|DSI)-") | not)
            ]
            | unique
            | length
          else
            empty
          end
        ' <<<"$event" 2>/dev/null || true
      )"

      [ -n "$next" ] || continue

      if [ -z "$prev" ]; then
        prev="$next"
        log "started with $prev external output(s)"
        continue
      fi

      if [ "$next" -lt "$prev" ]; then
        log "external output count decreased: $prev -> $next"
        flatten_workspaces
      fi

      prev="$next"
    done < <(niri msg -j event-stream 2>> "$log_file")

    log "event stream ended"
  '';
in
{
  environment.systemPackages = [
    niriMonitorUnplugListener
  ];
}
