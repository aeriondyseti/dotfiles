-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- hl.config({
--   general = {
--     -- No gaps between windows or borders.
--     gaps_in = 0,
--     gaps_out = 0,
--     border_size = 0,
--
--     -- Change to niri-like side-scrolling layout.
--     layout = "scrolling",
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--
--     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
--     dim_inactive = true,
--     dim_strength = 0.15,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })

-- ─────────────────────────────────────────
-- Aerion rice: frosted glass, wider frame, snappier HUD-style motion.
-- Colors (borders, glow) live in the Aerion theme's hyprland.lua.
-- ─────────────────────────────────────────
hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 14,
  },

  decoration = {
    rounding = 0,
    blur = {
      enabled = true,
      size = 12,
      passes = 3,
      noise = 0.02,
      contrast = 1.0,
      brightness = 0.85,
      vibrancy = 0.2,
      new_optimizations = true,
      xray = false,
    },
  },
})

-- Quick pop-in with a slight overshoot, plus a fast workspace slide.
hl.curve("overshot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.08 } } })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.2, bezier = "overshot", style = "popin 90%" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2.6, bezier = "easeOutQuint", style = "slide" })
