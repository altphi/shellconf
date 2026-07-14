#!/usr/bin/env bash
set -a

SRC_CONFIG="${HOME}/.config/"
SRC_VAULTS="${HOME}/vaults/"
SRC_TODOS="${HOME}/todos/"

TGT_DROPBOX="${HOME}/Dropbox/backups/"
TGT_SYNCTHING="${HOME}/syncedthings/backups/"

sync() {
	rsync -aP --delete \
		--exclude="Slack/" \
		--exclude="HEY/" \
		--exclude="Code - OSS/" \
		--exclude="chromium/" \
		--exclude="go/telemetry/" \
		--exclude="chrom.*flags.conf" \
		--exclude="electron.*flags.conf" \
		--exclude="microsoft.*flags.conf" \
		--exclude="youtube.*flags.conf" \
		--exclude="spotify/" \
		--exclude="discord/" \
		--exclude="Signal/" \
		--exclude="Todoist/" \
		--exclude="zsh/.zcompdump*" \
		"${SRC_CONFIG}" "${1}dotconfig/"

	rsync -aP --delete "${SRC_VAULTS}" "${1}vaults/"
	rsync -aP --delete "${SRC_TODOS}" "${1}todos/"
}

sync "${TGT_DROPBOX}"
sync "${TGT_SYNCTHING}"

# .local/share
# SRC_SHARE="${HOME}/.local/share/"
# TGT_SHARE="${HOME}/Dropbox/backups/dotlocal-share/"

dotssh() (
	cd "$HOME" || exit
	tar --numeric-owner --xattrs --acls -czf .ssh-backup.tar.gz .ssh
	gpg -e -r beck@j38.uk -o "${TGT_SYNCTHING}dotssh.tar.gz.gpg" .ssh-backup.tar.gz
	rm .ssh-backup.tar.gz
)
dotssh
