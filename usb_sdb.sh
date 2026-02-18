#!/usr/bin/env bash

UUID="$USBSTICK_UUID" # see .secret-env
DRIVE="usb_sdb"
MAPPER_POINT="/dev/mapper/${DRIVE}"
MOUNT_POINT="/mnt/${DRIVE}"

close() {
  sudo umount /mnt/usb_sdb
  sudo cryptsetup luksClose usb_sdb
}

open() {
  sudo cryptsetup luksOpen UUID="$UUID" "$DRIVE"
  sudo mount "$MAPPER_POINT" "$MOUNT_POINT"
}


if [[ "$1" == "open" ]]; then
  open
elif [[ "$1" == "close" ]]; then
  close
elif [[ "$1" == "force-close" ]]; then
  fuser -k "$MOUNT_POINT"
  close
else
  echo "usage: ${0##*/} open|close|force-close";
fi

