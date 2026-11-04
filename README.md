# theosis-kit

Scripts and config files for building out an Ubuntu 26.04.1 install on an ASUS Vivobook Pro 15 OLED (N6506MV, Core Ultra 9 185H, RTX 4060 Laptop): cleanup, performance settings, a Hyprland 0.57.1 Lua config, an agent memory box, and VMD off.

Start with the guide: `guide/theosis-linux-guide.html`. Open it in a browser and follow it step by step. Every step has the command, what you should see, what to do if it fails, and how to undo it.

```
git clone https://github.com/velluu/theosis-kit ~/theosis-kit
xdg-open ~/theosis-kit/guide/theosis-linux-guide.html
```

## Layout

| folder | holds |
|---|---|
| `guide/` | the step-by-step guide |
| `scripts/` | `step0-inventory.sh` (read only), `safe-purge.sh` (removes packages only after an apt dry run shows nothing protected goes), `remove-snaps.sh`, `make-agents-slice.sh`, `make-dri-rules.sh`, `send-logs-to-windows.sh` |
| `etc/` | system files: charge limit service, zram sysctls, nosnap apt pin, bubblewrap AppArmor profile |
| `user/` | user files: build jobs, claude wrapper, hidden autostarts |
| `hypr/` | Hyprland 0.57.1 Lua config (inspired by PewDiePie's dionysus rice), hypridle, hyprlock, uwsm env, notes |

Logs the scripts write go to `~/theosis-kit/logs`, which is not tracked.

Written for one specific machine. Read each step before running it on anything else.
