# Theosis Hyprland piece 1: notes

Written 2026-11-04 17:41 +04. Target: Hyprland 0.57.1-1ppa1~1resolute1 (ppa:cppiber/hyprland), hypridle 0.1.8, hyprlock 0.9.7, hyprpolkitagent 0.2.0.

## Files and where they go

| file here | install path |
|---|---|
| hyprland.lua | ~/.config/hypr/hyprland.lua |
| hypridle.conf | ~/.config/hypr/hypridle.conf |
| hyprlock.conf | ~/.config/hypr/hyprlock.conf |
| uwsm/env | ~/.config/uwsm/env |
| uwsm/env-hyprland | ~/.config/uwsm/env-hyprland |

Log in with the "Hyprland (uwsm-managed)" session entry (the PPA ships /usr/share/wayland-sessions/hyprland-uwsm.desktop). If you use the plain "Hyprland" entry instead, set `useUwsm = false` at the top of hyprland.lua.

## Before the first login

1. udev symlink for the iGPU (wiki multi-gpu page form, which adds `SUBSYSTEMS=="pci"` to the blueprint's rule). Confirm the address first with `lspci -D -d ::03xx`.
   - File `/etc/udev/rules.d/intel-igpu-dev-path.rules`, one line:
     `KERNEL=="card*", KERNELS=="0000:00:02.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/intel-igpu"`
   - `sudo udevadm control --reload`
   - `sudo udevadm trigger`
   - `ls -l /dev/dri/intel-igpu` must point at a cardN
   - Do not use /dev/dri/by-path. Those names contain colons, and colons separate entries in AQ_DRM_DEVICES (wiki multi-gpu page).
2. Packages this config calls: foot, fuzzel, grim, slurp, wl-clipboard, cliphist, brightnessctl, playerctl, hypridle, hyprlock, hyprpolkitagent, xdg-desktop-portal-hyprland, xdg-desktop-portal-gtk, uwsm, lua5.4 (for the syntax check only).
3. `brightnessctl -l` must list the OLED backlight.

## Validate before logging in

Run from a TTY or the GNOME session:

1. `luac5.4 -p ~/.config/hypr/hyprland.lua`
   - Pure syntax check. The PPA build links liblua5.4-0, so 5.4 is the matching parser.
2. `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`
   - Runs the config without starting the compositor and prints `======== Config parsing result:` then `config ok` or the error list (src/main.cpp and Compositor.cpp at v0.57.1).
3. Optional editor help: point lua-language-server at `/usr/share/hypr/stubs/hl.meta.lua` (shipped in the PPA .deb).

hypridle and hyprlock have no verify flag in these versions. Check them after login:
- `systemctl --user status hypridle.service`
- `journalctl --user -u hypridle.service -b | grep -i error`
- `hyprlock --verbose` (this really locks, unlock with your password and read the terminal)

## Inside the session

- `hyprctl configerrors` lists current errors
- Saving hyprland.lua reloads it automatically (misc.disable_autoreload defaults to false)
- Manual reload: SUPER+SHIFT+R or `hyprctl reload`
- Live tweak without editing: `hyprctl eval 'hl.config({ decoration = { blur = { enabled = false } } })'`
- `hyprctl keyword` no longer exists on the server side in 0.57.1, `hyprctl eval` replaces it
- `hyprctl monitors` should show eDP-1 at 2880x1620@120.00 and scale 1.50
- GPU acceptance from the blueprint: 4060 `runtime_status` reads `suspended`, `lsof /dev/nvidia*` is empty

## Crashed lock screen recovery

`misc.allow_session_lock_restore = true` is set. From a TTY (Ctrl+Alt+F3), log in, then either:
- `hyprctl --instance 0 dispatch 'hl.dsp.exec_cmd("hyprlock")'` to start a fresh hyprlock, then unlock normally
- `hyprctl --instance 0 eval 'hl.clear_crashed_lockscreen()'` to drop the dead lock (refuses while a live lock client holds it)

## Keybinds

| keys | action |
|---|---|
| ALT+T / ALT+B / ALT+F / ALT+SPACE | foot / Brave / Nautilus / fuzzel |
| ALT+P or SHIFT+Print | region screenshot to clipboard and ~/Pictures/Screenshots |
| Print | full screenshot, same targets |
| SUPER+Q | close window |
| SUPER+SHIFT+E | exit (uwsm stop) |
| SUPER+SHIFT+R | reload config |
| SUPER+V / SUPER+F / SUPER+SHIFT+F | float / fullscreen / maximize |
| SUPER+P / SUPER+T | pseudotile / toggle split (dwindle) |
| SUPER+SHIFT+T | switch layout dwindle and master |
| SUPER+arrows or hjkl | focus |
| SUPER+SHIFT+arrows or hjkl | move window |
| SUPER+CTRL+arrows or hjkl | resize 40 px |
| SUPER+R | resize mode, Escape or Return leaves |
| SUPER+1..0 / SUPER+SHIFT+1..0 | workspace / send window |
| SUPER+S / SUPER+SHIFT+S | scratchpad / send to scratchpad |
| SUPER+wheel | next and previous workspace |
| SUPER+left drag / right drag | move / resize |
| SUPER+SHIFT+V | clipboard history |
| SUPER+Escape | lock |
| media, volume, mic, brightness keys | wpctl, playerctl, brightnessctl |
| 3-finger horizontal swipe | workspace |

## dionysus palette (from his waybar style.css and rofi theme.rasi)

One Dark accents on Nord and Catppuccin darks. Cyan #56b6c2 (main accent), blue #61afef (borders), ice #9cdef2 (text), glow #1fbeff (window shadow), peach #fab387 and gold #e5c07b (warm highlights), red #e06c75 / #bf616a / #f38ba8 (alerts), darks #1e1e2e #191919 #282c34 #292e36, Nord #2e3440 #3b4252 #4c566a. Font JetBrainsMono Nerd Font.

## Verified this session (sources)

- Hyprland v0.57.1 tag (VERSION reads 0.57.1): example/hyprland.lua, src/config/values/ConfigValues.cpp (option names and defaults), src/config/lua/ConfigManager.cpp (`:` becomes `.` and `-` becomes `_` in Lua keys, so tap-to-click is `tap_to_click`), src/config/lua/bindings/* (hl.* and hl.dsp.* names and arguments), src/output/Monitor.cpp (scale clean-divisor check), src/desktop/rule/* (match props, effects, regex is RE2 FullMatch), src/ipc/s1/Commands.cpp (hyprctl commands), src/main.cpp (--verify-config).
- PPA .deb hyprland_0.57.1-1ppa1~1resolute1_amd64: shipped example identical to the tag, ships hl.meta.lua stubs, hyprland-uwsm.desktop, hyprland-portals.conf (`default=hyprland;gtk`), links liblua5.4-0.
- PPA .debs hypridle 0.1.8 and hyprpolkitagent 0.2.0: both ship systemd user units (`hypridle.service`, `hyprpolkitagent.service`).
- hypridle v0.1.8 and hyprlock v0.9.7 tags: both still hyprlang. Keys checked against their ConfigManager.cpp.
- wiki.hypr.land source (hyprwm/hyprland-wiki, commit 0636506, 2026-11-03): multi-gpu, uwsm, environment-variables, xwayland, autostart, submaps, window-rules, animations, hyprpolkitagent, code-snippets.
- hypr.land/news/update57: ".conf configs are no longer supported".
- cliphist v0.5.0 readme, fuzzel 1.12.0 man page (`--dmenu`, `--with-nth`, `--launch-prefix`), brightnessctl 0.5.1 source (`-n` and `-e` take attached values), wl-copy 2.2.1 (`--type`).
- A mock of the 0.57.1 API built from those source lists ran hyprland.lua with zero errors, and caught every planted mistake in a negative control.

## Not verified

- Hyprland was not run. This WSL box cannot execute the Ubuntu 26.04 binary (glibc 2.43 needed), so `--verify-config` on Theosis is the first real run.
- That `--verify-config` works from inside a GNOME session or TTY without side effects (source suggests yes, it returns before creating the Wayland display).
- Whether `systemctl --user start hypridle.service` at hyprland.start sees WAYLAND_DISPLAY in time (units carry `ConditionEnvironment=WAYLAND_DISPLAY`). If a unit is skipped, use `systemctl --user enable hypridle.service hyprpolkitagent.service` once instead and delete those two lines.
- Window class of the GTK portal file chooser (`xdg-desktop-portal-gtk`) and of pavucontrol (`org.pulseaudio.pavucontrol`). Check with `hyprctl clients` and fix the rule.
- The keysym names for the ASUS media and brightness keys. Check with `wev` if a key does nothing.
- Whether Brave on Ubuntu still needs the ozone Wayland flags (the wiki says Chromium browsers do).
- Whether pango accepts "JetBrains Mono" from fonts-jetbrains-mono. It falls back to the default font if not.
- GDK_SCALE=2 makes X11 GTK apps about a third larger than native apps at scale 1.5. Remove it if they look too big.
- Wiki quirk: the animations page shows a `curve =` field, but the 0.57.1 source reads only `bezier =` or `spring =`. This config uses `bezier`.
