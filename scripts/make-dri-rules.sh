#!/usr/bin/env bash
#Theosis: writes /etc/udev/rules.d/95-theosis-dri.rules so Hyprland can name each GPU by a fixed path.
#/dev/dri/intel-igpu = the Intel Arc that drives the laptop panel. /dev/dri/nvidia-dgpu = the RTX 4060 (HDMI port).
set -e
igpu=$(lspci -D | awk '/VGA compatible controller: Intel/ {print $1; exit}')
dgpu=$(lspci -D | awk '/NVIDIA/ && /VGA|3D/ {print $1; exit}')
echo "Intel GPU at: $igpu"
echo "NVIDIA GPU at: $dgpu"
if [ -z "$igpu" ] || [ -z "$dgpu" ]; then echo "Could not find both GPUs, stopping. Paste lspci -D output into the log."; exit 1; fi
tmp=$(mktemp)
echo "#Theosis: stable names for the two GPUs, written $(date -Is)" > "$tmp"
echo "KERNEL==\"card*\", KERNELS==\"$igpu\", SUBSYSTEM==\"drm\", SUBSYSTEMS==\"pci\", SYMLINK+=\"dri/intel-igpu\"" >> "$tmp"
echo "KERNEL==\"card*\", KERNELS==\"$dgpu\", SUBSYSTEM==\"drm\", SUBSYSTEMS==\"pci\", SYMLINK+=\"dri/nvidia-dgpu\"" >> "$tmp"
sudo install -m 644 "$tmp" /etc/udev/rules.d/95-theosis-dri.rules
rm "$tmp"
sudo udevadm control --reload
sudo udevadm trigger --subsystem-match=drm
sleep 1
ls -l /dev/dri/intel-igpu /dev/dri/nvidia-dgpu
