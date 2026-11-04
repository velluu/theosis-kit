#!/usr/bin/env bash
#Theosis step 0: read-only inventory. Changes nothing on the machine.
#Writes everything to ~/theosis-kit/logs/step0-<date>.txt so it can come back to the vault.
#Run: bash ~/theosis-kit/scripts/step0-inventory.sh

KIT="$HOME/theosis-kit"
mkdir -p "$KIT/logs"
OUT="$KIT/logs/step0-$(date +%Y%m%d-%H%M).txt"

#run one labelled command, never stop on error
r() {
  echo "===== $*" >> "$OUT"
  bash -c "$*" >> "$OUT" 2>&1
  echo "" >> "$OUT"
}

echo "Theosis step 0 inventory, $(date -Is)" > "$OUT"
echo "sudo will ask for your password once, for the few reads that need root."
sudo -v

#boot, Secure Boot, keys
r "mokutil --sb-state"
r "mokutil --db | grep -i 'Subject:'"
r "mokutil --kek | grep -i 'Subject:'"
r "cat /sys/kernel/security/lockdown"
r "sudo efibootmgr -v"
r "grep -E '^GRUB_(DEFAULT|TIMEOUT|CMDLINE_LINUX_DEFAULT|SAVEDEFAULT)' /etc/default/grub"
r "ls /etc/default/grub.d/"
r "grep -E \"^menuentry|^submenu\" /boot/grub/grub.cfg | cut -c1-160"
r "cat /etc/fstab"
r "lsblk -f"

#full baselines kept as separate files
mokutil --db > "$KIT/logs/baseline-mokutil-db.txt" 2>&1
sudo efibootmgr -v > "$KIT/logs/baseline-efibootmgr.txt" 2>&1

#kernel, drivers, packages
r "uname -a"
r "lsb_release -a"
r "dpkg -l | grep -E 'nvidia-dkms|linux-modules-nvidia' | cut -c1-120"
r "apt policy linux-generic-hwe-26.04"
r "grep CONFIG_VMD= /boot/config-\$(uname -r)"
r "dpkg -l coreutils-from-uutils coreutils-from-gnu 2>&1 | tail -3"
r "ls --version | head -1"
r "sudo --version | head -1"
r "dpkg -l ubuntu-desktop ubuntu-desktop-minimal 2>&1 | tail -3"
r "apt-mark showmanual"
r "snap list"
r "apt-cache policy | grep -E 'http|ppa' | sort -u"

#memory and swap
r "free -h"
r "swapon --show"
r "findmnt /tmp"
r "cat /sys/module/zswap/parameters/enabled"
r "cat /etc/sysctl.d/99-tuning.conf"
r "systemctl is-enabled systemd-oomd"
r "oomctl"
r "systemd-analyze cat-config systemd/system/user@.service"
r "systemctl show user@\$(id -u).service -p ManagedOOMMemoryPressure -p ManagedOOMMemoryPressureLimit -p ManagedOOMSwap"
r "sysctl kernel.apparmor_restrict_unprivileged_userns"

#services and boot time, for the cleanup step
r "systemd-analyze"
r "systemd-analyze blame | head -40"
r "systemd-analyze critical-chain"
r "systemctl list-unit-files --state=enabled --no-pager"
r "systemctl --user list-unit-files --state=enabled --no-pager"
r "systemctl list-timers --all --no-pager"
r "ls /etc/xdg/autostart/ ~/.config/autostart/"
r "ps -eo pid,rss,pcpu,comm --sort=-rss | head -40"

#network
r "nmcli -g 802-1x.password-flags connection show IITDAD-WiFi1"
r "nmcli -f NAME,TYPE,AUTOCONNECT connection show"
r "systemctl is-active tailscaled sshd ssh.socket"
r "sudo ufw status verbose"

#lid, power, battery, thermal
r "cat /etc/systemd/logind.conf.d/90-theosis-lid.conf"
r "powerprofilesctl get"
r "ls -d /sys/class/power_supply/BAT*"
r "cat /sys/class/power_supply/BAT*/charge_control_end_threshold"
r "cat /sys/bus/pci/devices/0000:00:04.0/tcc_offset_degree_celsius"
r "lscpu -e"

#GPU and display (lspci wakes the NVIDIA card for a moment, that is fine)
r "lspci -D | grep -i -E 'vga|3d|display'"
r "ls -l /dev/dri/ /dev/dri/by-path/"
r "cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status"

#keyboard layout for the Hyprland config
r "localectl status"
r "gsettings get org.gnome.desktop.input-sources sources"


#cleanup inventory (Part E)
r "systemctl --user list-timers --all --no-pager"
r "systemd-analyze --user blame | head -20"
r "systemctl list-dependencies --reverse network-online.target"
r "systemctl list-dependencies --reverse systemd-udev-settle.service"
r "snap list --all"
r "du -sh /var/lib/snapd"
r "findmnt -t squashfs | wc -l"
r "gnome-extensions list --enabled"
r "dpkg -l apport whoopsie ubuntu-report ubuntu-insights localsearch evolution-data-server packagekit modemmanager avahi-daemon cups hplip brltty orca speech-dispatcher gnome-remote-desktop gamemode wsdd hwctl cloud-init fprintd iio-sensor-proxy libreoffice-core rhythmbox shotwell showtime transmission-gtk remmina deja-dup gnome-snapshot simple-scan thunderbird firefox gnome-initial-setup ubuntu-docs gnome-user-docs brave-browser 2>&1 | grep -E '^(ii|rc|un)'"
r "sudo pro config show"
r "ls /etc/cloud/cloud-init.disabled"
r "mmcli -L"
r "lsusb"
r "update-alternatives --query sudo | head -5"
r "cat /proc/sys/kernel/core_pattern"

#tuning checks from 11-02/03
r "bash ~/projects/tuning/bench/verify-all.sh"

#Claude Code on this install
r "type claude"
r "claude --version"
r "grep -n -A12 'Theosis tuning C09' ~/.bashrc"

echo ""
echo "Done. Saved to: $OUT"
echo "Lines: $(wc -l < "$OUT")"
