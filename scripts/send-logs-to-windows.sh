#!/usr/bin/env bash
#Theosis: copies ~/theosis-kit/logs to the Windows Downloads folder, so Claude on Windows can read the results.
set -e
win=$(lsblk -rno NAME,FSTYPE,SIZE | awk '$2=="ntfs" {print $1}' | while read p; do s=$(lsblk -bno SIZE /dev/$p); echo "$s $p"; done | sort -n | tail -1 | awk '{print $2}')
echo "Windows partition: /dev/$win"
mnt=$(findmnt -rno TARGET /dev/$win || true)
if [ -z "$mnt" ]; then udisksctl mount -b /dev/$win; mnt=$(findmnt -rno TARGET /dev/$win); fi
dest="$mnt/Users/karth/Downloads/theosis-kit-logs"
mkdir -p "$dest"
cp -rv "$HOME/theosis-kit/logs/." "$dest/"
echo "Copied to $dest"
