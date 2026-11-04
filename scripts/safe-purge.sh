#!/usr/bin/env bash
#Theosis: purge packages only if apt's dry run removes nothing GNOME, boot, Wi-Fi or the GPU needs.
#Usage: bash ~/theosis-kit/scripts/safe-purge.sh pkg1 pkg2 ...
#Skips packages that are not installed. Stops before changing anything if a protected package would go.
LOG="$HOME/theosis-kit/logs/debloat.txt"
mkdir -p "$(dirname "$LOG")"
protect='^(ubuntu-desktop|ubuntu-desktop-minimal|ubuntu-minimal|ubuntu-standard|ubuntu-session|gdm3|gnome-shell|gnome-shell-ubuntu-extensions|gnome-session-bin|gnome-control-center|gnome-settings-daemon|nautilus|xdg-desktop-portal-gnome|network-manager|wpasupplicant|software-properties-common|packagekit|ubuntu-pro-client|update-notifier|update-manager|update-manager-core|yelp|geoclue-2.0|localsearch|tinysparql|whoopsie-preferences|power-profiles-daemon|fwupd|chrony|kdump-tools|switcheroo-control|ubuntu-drivers-common|brave-browser|tailscale|sudo|sudo-rs|coreutils|systemd|apt|dpkg|grub-.*|shim-signed|linux-.*|nvidia-.*|libnvidia-.*|hypr.*|uwsm|bluez)$'
pkgs=()
for p in "$@"; do
  st=$(dpkg-query -W -f='${db:Status-Abbrev}' "$p" 2>/dev/null)
  case "$st" in ii*|rc*|iU*|iF*) pkgs+=("$p") ;; *) echo "skip $p (not installed)" ;; esac
done
if [ ${#pkgs[@]} -eq 0 ]; then echo "Nothing to remove."; exit 0; fi
echo "Dry run for: ${pkgs[*]}"
sim=$(apt-get -s purge "${pkgs[@]}" 2>&1)
rc=$?
gone=$(echo "$sim" | awk '/^(Purg|Remv) / {print $2}')
#a failed or impossible dry run must never count as safe
if [ $rc -ne 0 ] || echo "$sim" | grep -q -E '^E:|unmet dependencies|impossible situation|WARNING: The following essential'; then
  echo "STOPPED. apt's dry run failed or warned. Nothing was changed. Its output:"
  echo "$sim" | tail -20
  { echo "== $(date -Is) DRY RUN FAILED for: ${pkgs[*]}"; echo "$sim" | tail -20; } >> "$LOG"
  exit 1
fi
if [ -z "$gone" ]; then echo "apt would remove nothing. Nothing to do."; exit 0; fi
bad=$(echo "$gone" | grep -E "$protect")
echo "Would remove:"
echo "$gone" | sed 's/^/  /'
if [ -n "$bad" ]; then
  echo ""
  echo "STOPPED. These protected packages would be removed:"
  echo "$bad" | sed 's/^/  /'
  echo "Nothing was changed."
  { echo "== $(date -Is) STOPPED for: ${pkgs[*]}"; echo "$bad"; } >> "$LOG"
  exit 1
fi
echo ""
echo "Safe. apt will now ask you to confirm."
{ echo "== $(date -Is) purge: ${pkgs[*]}"; echo "$gone"; } >> "$LOG"
sudo apt purge "${pkgs[@]}"
