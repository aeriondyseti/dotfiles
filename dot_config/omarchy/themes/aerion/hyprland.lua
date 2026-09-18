-- Aerion: teal HUD look. Theme-owned so switching themes swaps it cleanly.
-- Active window: angled teal gradient border + soft teal glow (shadow with no offset).
local active_border_color = { colors = { "rgba(00e9e9ee)", "rgba(277b8eee)" }, angle = 45 }
local inactive_border_color = "rgba(1c2426cc)"
local active_shadow_color = "rgba(0d2e33ee)"
local inactive_shadow_color = "rgba(00000066)"

hl.config({
  general = {
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  group = {
    col = {
      border_active = { colors = { "rgba(f0a820ee)", "rgba(a07020ee)" }, angle = 45 },
      border_inactive = inactive_border_color,
    },
  },

  decoration = {
    shadow = {
      enabled = true,
      range = 10,
      render_power = 3,
      offset = { 0, 0 },
      color = active_shadow_color,
      color_inactive = inactive_shadow_color,
    },
  },
})
