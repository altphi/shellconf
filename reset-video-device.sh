#!/usr/bin/env bash
set -e

has_video() {
    [ -n "$(ls /dev/video* 2>/dev/null)" ]
}

if has_video; then
    echo "Webcam already present: $(ls /dev/video*)"
    exit 0
fi

for dev in /sys/bus/pci/devices/*; do
    if [ "$(basename "$(readlink -f "$dev/driver" 2>/dev/null)")" = "xhci_hcd" ]; then
        pci_addr=$(basename "$dev")
        echo "Trying controller $pci_addr..."

        # Unbind and rebind
        echo "$pci_addr" | sudo tee /sys/bus/pci/drivers/xhci_hcd/unbind
        sleep 1
        echo "$pci_addr" | sudo tee /sys/bus/pci/drivers/xhci_hcd/bind
        sleep 2

        if has_video; then
            echo "Webcam restored: $(ls /dev/video*)"
            exit 0
        fi
    fi
done

echo "No webcam found after cycling all controllers."
exit 1

