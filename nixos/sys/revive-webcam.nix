{ config, pkgs, lib, ... }:

{
  systemd.services.revive-webcam = {
    description = "Revive webcam after suspend";
    wantedBy = [ "sleep.target" ];
    before = [ "sleep.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "revive-webcam" ''
        has_video() {
          [ -n "$(ls /dev/video* 2>/dev/null)" ]
        }

        if has_video; then
          exit 0
        fi

        for dev in /sys/bus/pci/devices/*; do
          if [ "$(basename "$(readlink -f "$dev/driver" 2>/dev/null)")" = "xhci_hcd" ]; then
            pci_addr=$(basename "$dev")
            echo "Rebinding USB controller $pci_addr..."
            echo "$pci_addr" > /sys/bus/pci/drivers/xhci_hcd/unbind
            sleep 1
            echo "$pci_addr" > /sys/bus/pci/drivers/xhci_hcd/bind
            sleep 2
            if has_video; then
              echo "Webcam is back!"
              break
            fi
          fi
        done
      '';
    };
  };
}

