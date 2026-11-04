#!/usr/bin/env bash
#Theosis: removes every snap in a safe order (apps, then runtimes, then bases, then snapd itself).
#Stops if Brave or Claude is installed as a snap, because removing snapd would delete it.
LOG="$HOME/theosis-kit/logs/debloat.txt"
if snap list 2>/dev/null | awk 'NR>1 {print $1}' | grep -q -i -E '^(brave|claude)'; then
  echo "STOPPED: Brave or Claude is a snap here. Install it from its apt repo first. Nothing changed."
  exit 1
fi
snap list --all > "$HOME/theosis-kit/logs/snaps-before.txt" 2>&1
sudo snap set system snapshots.automatic.retention=no
apps="firefox thunderbird snap-store firmware-updater desktop-security-center prompting-client snapd-desktop-integration hwctl ubuntu-desktop-bootstrap"
runtimes="gnome-46-2404 mesa-2404 gtk-common-themes"
for s in $apps $runtimes; do
  if snap list "$s" >/dev/null 2>&1; then echo "removing $s"; sudo snap remove --purge "$s"; fi
done
#anything else that is not a base or snapd
for s in $(snap list 2>/dev/null | awk 'NR>1 {print $1}' | grep -v -E '^(core[0-9]*|bare|snapd)$'); do
  echo "removing leftover $s"; sudo snap remove --purge "$s"
done
for s in $(snap list 2>/dev/null | awk 'NR>1 {print $1}' | grep -E '^(core[0-9]*|bare)$'); do
  echo "removing base $s"; sudo snap remove --purge "$s"
done
if snap list snapd >/dev/null 2>&1; then sudo snap remove --purge snapd; fi
echo "== $(date -Is) snaps removed" >> "$LOG"
snap list 2>&1 | tee -a "$LOG"
echo "Now continue with the apt purge of snapd in the guide."
