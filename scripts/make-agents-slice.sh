#!/usr/bin/env bash
#Theosis: writes ~/.config/systemd/user/agents.slice, the shared memory box for all agent sessions.
#Run it with ONLY the desktop and Brave open (no agents, no builds). What is free right now is what agents may use.
#MemoryMax = MemAvailable now (total minus what the desktop and browser hold). MemoryHigh = 1 GiB below that.
set -e
availkb=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
maxmb=$(( availkb / 1024 ))
highmb=$(( maxmb - 1024 ))
limit=$(systemctl show "user@$(id -u).service" -p ManagedOOMMemoryPressureLimit --value)
mkdir -p "$HOME/.config/systemd/user"
{
  echo "#Theosis agents.slice, written $(date -Is) by make-agents-slice.sh"
  echo "#MemAvailable at write time: ${maxmb} MiB"
  echo "[Slice]"
  echo "MemoryHigh=${highmb}M"
  echo "MemoryMax=${maxmb}M"
  echo "CPUWeight=50"
  echo "ManagedOOMMemoryPressure=kill"
  if [ -n "$limit" ] && [ "$limit" != "0" ]; then echo "ManagedOOMMemoryPressureLimit=${limit}"; fi
} > "$HOME/.config/systemd/user/agents.slice"
systemctl --user daemon-reload
echo "Wrote ~/.config/systemd/user/agents.slice:"
cat "$HOME/.config/systemd/user/agents.slice"
