-- Theosis Hyprland config, piece 1 (Hyprland only)
-- Target: Hyprland 0.57.1 from ppa:cppiber/hyprland, Lua config format
-- Look: inspired by PewDiePie's dionysus rice (neon cyan on dark Nord/One Dark)
-- Every option here was checked against the v0.57.1 source and the PPA's hl.meta.lua stubs.
-- Install path: ~/.config/hypr/hyprland.lua


-----------------
---- CHOICES ----
-----------------

-- CONFIRM: keyboard layout. "us" is a placeholder until Karth confirms.
local kbLayout  = "us"
local kbVariant = ""

-- Set to false only if Hyprland is started without uwsm (plain "Hyprland" session entry).
local useUwsm = true

-- Apps. foot and fuzzel come from the Ubuntu archive, brave from Brave's own apt repo.
local terminal    = "foot"
local browser     = "brave-browser --enable-features=UseOzonePlatform --ozone-platform=wayland"
local fileManager = "nautilus" -- CONFIRM: GNOME's file manager, already installed with Ubuntu desktop
local launcher    = "fuzzel"

local mainMod = "SUPER"
local appMod  = "ALT"

-- Under uwsm every app runs as its own systemd unit (wiki uwsm page).
local function app(cmd)
    if useUwsm then
        return "uwsm app -- " .. cmd
    end
    return cmd
end

local launcherCmd = launcher
if useUwsm then
    launcherCmd = launcher .. " --launch-prefix='uwsm app --'"
end


-----------------
---- PALETTE ----
-----------------

-- dionysus colours, taken from his waybar style.css, rofi theme.rasi and hyprland.conf
local c = {
    glow     = "rgba(1fbeffee)", -- his shadow colour
    cyan     = "rgba(56b6c2ff)", -- his main accent
    sky      = "rgba(61afefff)", -- his active border and rofi border
    ice      = "rgba(9cdef2ff)", -- his waybar text
    nordDark = "rgba(3b4252aa)", -- Nord polar night, used for inactive borders
    base     = "rgba(1e1e2eff)", -- darkest background in his waybar
}


------------------
---- MONITORS ----
------------------

-- Built-in OLED. 2880/1.5 = 1920 and 1620/1.5 = 1080, so 1.5 passes Hyprland's clean-divisor check.
hl.monitor({
    output   = "eDP-1",
    mode     = "2880x1620@120",
    position = "0x0",
    scale    = 1.5,
})

-- Anything else (USB-C on the Intel iGPU, HDMI on the 4060) gets its preferred mode to the right.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- With uwsm, env lives in ~/.config/uwsm/env and env-hyprland (wiki uwsm page says keep it out of this file).
-- This block only runs for a session started without uwsm.
if not useUwsm then
    hl.env("AQ_DRM_DEVICES", "/dev/dri/intel-igpu") -- needs the udev symlink from NOTES.md
    hl.env("XCURSOR_SIZE", "24")
    hl.env("HYPRCURSOR_SIZE", "24")
    hl.env("GDK_SCALE", "2") -- X11 GTK apps only, pairs with force_zero_scaling below
end


-------------------
---- AUTOSTART ----
-------------------

-- Runs once at login, not on reload. The portal needs no line here, D-Bus starts it on demand.
hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start hyprpolkitagent.service")
    hl.exec_cmd("systemctl --user start hypridle.service")
    hl.exec_cmd(app("wl-paste --watch cliphist store"))
end)


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Gaps, borders and layout, dionysus numbers with a cyan gradient border
hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 20,
        border_size = 2,

        col = {
            active_border   = { colors = { c.glow, c.cyan }, angle = 45 },
            inactive_border = c.nordDark,
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },
})

-- Near-square corners, cyan glow shadow, light dark blur (all dionysus values)
hl.config({
    decoration = {
        rounding       = 1, -- raise to 6 to 10 for softer corners
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled        = true,
            range          = 5,
            render_power   = 4,
            color          = c.glow,
            color_inactive = "rgba(1fbeff33)", -- dimmer glow so focus stands out
        },

        blur = {
            enabled    = true,
            size       = 2,
            passes     = 1,
            brightness = 0.4,
            xray       = true, -- floating windows blur only the wallpaper, cheaper
        },
    },
})


--------------------
---- ANIMATIONS ----
--------------------

-- His bezier curves. Speed is in deciseconds, so 4.79 means 479 ms.
hl.config({ animations = { enabled = true } })

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- His animation lines, windows use easeOutQuint like dionysus (not the stock spring)
hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })


-----------------
---- LAYOUTS ----
-----------------

-- Dwindle is the default. SUPER+SHIFT+T flips the whole session to master and back.
hl.config({
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
})


----------------
----  MISC  ----
----------------

-- No anime wallpaper or logo, plain dark background until a wallpaper tool is added.
-- debug.vfr stays at its default (true), the source says do not turn it off unless debugging.
hl.config({
    misc = {
        force_default_wallpaper    = 0,
        disable_hyprland_logo      = true,
        disable_splash_rendering   = true,
        background_color           = c.base,
        allow_session_lock_restore = true, -- lets a crashed hyprlock be restarted from a TTY
    },
    xwayland = {
        force_zero_scaling = true, -- X11 apps stay sharp at 1.5, GDK_SCALE sizes them
    },
})


---------------
---- INPUT ----
---------------

-- Keyboard from the CHOICES block, touchpad with natural scroll and tap to click
hl.config({
    input = {
        kb_layout  = kbLayout,
        kb_variant = kbVariant,
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0, -- -1.0 to 1.0, 0 means no change

        touchpad = {
            natural_scroll       = true,
            tap_to_click         = true,
            disable_while_typing = true,
        },
    },
})

-- Three-finger horizontal swipe switches workspaces
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})


---------------------
---- KEYBINDINGS ----
---------------------

-- App launches on ALT, the dionysus way
hl.bind(appMod .. " + T",     hl.dsp.exec_cmd(app(terminal)))
hl.bind(appMod .. " + B",     hl.dsp.exec_cmd(app(browser)))
hl.bind(appMod .. " + F",     hl.dsp.exec_cmd(app(fileManager)))
hl.bind(appMod .. " + SPACE", hl.dsp.exec_cmd(launcherCmd))

-- Window basics
hl.bind(mainMod .. " + Q",         hl.dsp.window.close())
hl.bind(mainMod .. " + V",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + P",         hl.dsp.window.pseudo())
hl.bind(mainMod .. " + T",         hl.dsp.layout("togglesplit")) -- dwindle only

-- Flip between dwindle and master for the whole session (reload returns to dwindle)
hl.bind(mainMod .. " + SHIFT + T", function()
    local current = hl.get_config("general.layout")
    local nextLayout = "dwindle"
    if current == "dwindle" then
        nextLayout = "master"
    end
    hl.config({ general = { layout = nextLayout } })
end)

-- Exit. Under uwsm, "uwsm stop" gives a clean shutdown (wiki uwsm page).
if useUwsm then
    hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("uwsm stop"))
else
    hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())
end

-- Reload this file (it also reloads on save by default)
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.reload_config())

-- Focus with arrows or hjkl, move the window with SHIFT added
local dirs = {
    { "left",  "h", "left"  },
    { "right", "l", "right" },
    { "up",    "k", "up"    },
    { "down",  "j", "down"  },
}
for _, d in ipairs(dirs) do
    hl.bind(mainMod .. " + " .. d[1],              hl.dsp.focus({ direction = d[3] }))
    hl.bind(mainMod .. " + " .. d[2],              hl.dsp.focus({ direction = d[3] }))
    hl.bind(mainMod .. " + SHIFT + " .. d[1],      hl.dsp.window.move({ direction = d[3] }))
    hl.bind(mainMod .. " + SHIFT + " .. d[2],      hl.dsp.window.move({ direction = d[3] }))
end

-- Quick resize with CTRL held, 40 px per step, repeats while held
local step = 40
local resizeSteps = {
    { "left",  "h", -step, 0     },
    { "right", "l",  step, 0     },
    { "up",    "k",  0,   -step  },
    { "down",  "j",  0,    step  },
}
for _, r in ipairs(resizeSteps) do
    local dsp = hl.dsp.window.resize({ x = r[3], y = r[4], relative = true })
    hl.bind(mainMod .. " + CTRL + " .. r[1], dsp, { repeating = true })
    hl.bind(mainMod .. " + CTRL + " .. r[2], dsp, { repeating = true })
end

-- Resize mode: SUPER+R, then arrows or hjkl, Escape or Return to leave
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    for _, r in ipairs(resizeSteps) do
        local dsp = hl.dsp.window.resize({ x = r[3], y = r[4], relative = true })
        hl.bind(r[1], dsp, { repeating = true })
        hl.bind(r[2], dsp, { repeating = true })
    end
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("return", hl.dsp.submap("reset"))
end)

-- Workspaces 1 to 10 (key 0 is workspace 10), SHIFT sends the window there
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad special workspace
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("scratch"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:scratch" }))

-- Scroll through open workspaces with SUPER + wheel
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- SUPER + left drag moves, SUPER + right drag resizes
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshots go to the clipboard and to ~/Pictures/Screenshots (POSIX sh, exec runs /bin/sh)
local shotFile = 'f="$HOME/Pictures/Screenshots/$(date +%Y-%m-%d-%H%M%S).png" && mkdir -p "$HOME/Pictures/Screenshots"'
local shotRegion = shotFile .. ' && g="$(slurp)" && grim -g "$g" "$f" && wl-copy --type image/png < "$f"'
local shotFull   = shotFile .. ' && grim "$f" && wl-copy --type image/png < "$f"'
hl.bind(appMod .. " + P",  hl.dsp.exec_cmd(shotRegion))
hl.bind("SHIFT + Print",   hl.dsp.exec_cmd(shotRegion))
hl.bind("Print",           hl.dsp.exec_cmd(shotFull))

-- Clipboard history picker
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu --with-nth=2 | cliphist decode | wl-copy"))

-- Lock now
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))

-- Volume and mic, work on the lock screen too
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })

-- Brightness, -n2 keeps the OLED from going fully black
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Media keys
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })


----------------------
---- WINDOW RULES ----
----------------------

-- Regex here is a full match, so patterns cover the whole class or title.

-- Ignore apps asking to maximize themselves (stock example rule)
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix drag glitches with untitled XWayland popups (stock example rule)
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- File pickers from the GTK portal (Brave, Electron apps) and GTK's own dialogs
hl.window_rule({
    name  = "float-portal-picker",
    match = { class = "^(xdg-desktop-portal-gtk)$" },
    float  = true,
    center = true,
    size   = { "monitor_w * 0.6", "monitor_h * 0.65" },
})
hl.window_rule({
    name  = "float-file-dialogs",
    match = { title = "^(Open File|Open Files|Open Folder|Select Folder|Save File|Save As|File Upload|Choose Files?)(.*)$" },
    float  = true,
    center = true,
})

-- Modal popups such as "are you sure" boxes
hl.window_rule({
    name  = "float-modals",
    match = { modal = true },
    float  = true,
    center = true,
})

-- Small settings tools float at a fixed size
hl.window_rule({
    name  = "float-settings-tools",
    match = { class = "^(org\\.pulseaudio\\.pavucontrol|pavucontrol|blueman-manager|nm-connection-editor)$" },
    float  = true,
    center = true,
    size   = { 900, 600 },
})

-- Browser picture-in-picture stays on top of every workspace
hl.window_rule({
    name  = "pip",
    match = { title = "^(Picture[- ]in[- ][Pp]icture)$" },
    float = true,
    pin   = true,
})
