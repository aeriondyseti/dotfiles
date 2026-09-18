-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Minimize: hide the focused window on the special:minimized workspace.
-- The Aerion taskbar shows it dimmed; click its icon to restore it.
o.bind("SUPER + M", "Minimize window", hl.dsp.window.move({ workspace = "special:minimized", follow = false }))

-- Choose where the NEXT window opens (dwindle preselect; one-shot, then back to auto).
-- Windows Terminal muscle memory: minus = below, equal (plus) = right.
-- These replace Omarchy's "Expand/Shrink window left a little" (Super+Alt+-/=);
-- Super+-/= and Super+Ctrl+-/= still resize.
-- Omarchy binds these by key code (code:20 = minus, code:21 = equal), so unbind the same codes.
hl.unbind("SUPER + ALT + code:20")
hl.unbind("SUPER + ALT + code:21")
o.bind("SUPER + ALT + code:20", "Split horizontally: next window opens below", hl.dsp.layout("preselect d"))
o.bind("SUPER + ALT + code:21", "Split vertically: next window opens to the right", hl.dsp.layout("preselect r"))

-- Super + mouse side button (mouse:275, "Back" on its own) toggles the scratchpad, like Super+S.
-- The button alone still works as Back in browsers.
o.bind("SUPER + mouse:275", "Toggle scratchpad (Super + mouse side button)", hl.dsp.workspace.toggle_special("scratchpad"))
