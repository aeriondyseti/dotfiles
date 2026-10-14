-- ~/.wezterm.lua  (chezmoi source: dot_wezterm.lua)
-- WezTerm config: tmux-style panes, a status bar, and layout resurrection.

local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

--------------------------------------------------------------------------------
-- Shell / appearance
--------------------------------------------------------------------------------
-- Launch PowerShell 7 by default on Windows; leave the OS default elsewhere.
if wezterm.target_triple:find("windows") then
  config.default_prog = { "pwsh.exe", "-NoLogo" }
end

-- Visual settings ported from Windows Terminal's default "PowerShell" profile.
config.color_scheme = "Builtin Solarized Dark"
config.font = wezterm.font_with_fallback({ "FiraCode Nerd Font Mono", "Consolas" })
config.font_size = 11.0
config.window_background_opacity = 1.0
config.window_decorations = "RESIZE"
config.scrollback_lines = 10000

-- Background image: the lightning PNG at 0.2 opacity over base color #000608,
-- matching Windows Terminal's backgroundImage / backgroundImageOpacity / background.
config.background = {
  { source = { Color = "#000608" }, width = "100%", height = "100%" },
  {
    source = {
      File = "C:/Users/Kevin/Downloads/u6812683223_A_subtle_and_unobtrusive_black_and_blue_lightning_00e97d86-c1b0-4ec9-9182-09860f2192ca_3.png",
    },
    width = "Cover",
    height = "Cover",
    horizontal_align = "Center",
    vertical_align = "Middle",
    opacity = 0.2,
  },
}
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
config.window_padding = { left = 6, right = 6, top = 6, bottom = 2 }

-- Dim inactive panes so the active pane is unmistakable, and give panes a
-- visible divider — the closest WezTerm gets to tmux's per-pane borders.
config.inactive_pane_hsb = { saturation = 0.8, brightness = 0.6 }
config.colors = {
  split = "#89b4fa",
  tab_bar = {
    active_tab = { bg_color = "#000608", fg_color = "#89b4fa" },
    inactive_tab = { bg_color = "#001018", fg_color = "#a6adc8" },
  },
}

--------------------------------------------------------------------------------
-- Leader key (tmux-style). CTRL+a, then a chord.
--------------------------------------------------------------------------------
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
  -- Splits: LEADER + \ (right), LEADER + - (down). Also | and _ for muscle memory.
  { key = "\\", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "|",  mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "-",  mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "_",  mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

  -- Pane navigation: LEADER + h/j/k/l (vim-style).
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

  -- Pane resize: LEADER + arrows.
  { key = "LeftArrow",  mods = "LEADER", action = act.AdjustPaneSize({ "Left", 5 }) },
  { key = "DownArrow",  mods = "LEADER", action = act.AdjustPaneSize({ "Down", 5 }) },
  { key = "UpArrow",    mods = "LEADER", action = act.AdjustPaneSize({ "Up", 5 }) },
  { key = "RightArrow", mods = "LEADER", action = act.AdjustPaneSize({ "Right", 5 }) },

  -- Pane management.
  { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
  { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
  { key = "Space", mods = "LEADER", action = act.RotatePanes("Clockwise") },

  -- Tabs (tmux "windows").
  { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
  { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
  { key = "&", mods = "LEADER", action = act.CloseCurrentTab({ confirm = true }) },

  -- Workspaces: LEADER + w picks/creates, LEADER + $ renames.
  { key = "w", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
  {
    key = "$", mods = "LEADER",
    action = act.PromptInputLine({
      description = "Rename workspace:",
      action = wezterm.action_callback(function(win, _, line)
        if line and #line > 0 then
          wezterm.mux.rename_workspace(win:active_workspace(), line)
        end
      end),
    }),
  },

  -- Copy/scrollback mode.
  { key = "[", mods = "LEADER", action = act.ActivateCopyMode },
}

-- LEADER + 1..9 jumps to tab N.
for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = "LEADER",
    action = act.ActivateTab(i - 1),
  })
end

--------------------------------------------------------------------------------
-- Tab titles: show the active pane's foreground process (or its title).
--------------------------------------------------------------------------------
wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
  local pane = tab.active_pane
  local title = pane.foreground_process_name or ""
  title = title:gsub(".*[/\\]", ""):gsub("%.exe$", "") -- basename, drop .exe
  if title == "" then
    title = pane.title
  end
  local label = " " .. (tab.tab_index + 1) .. ": " .. title .. " "
  if #label > max_width then
    label = label:sub(1, max_width - 1) .. "…"
  end
  return label
end)

--------------------------------------------------------------------------------
-- Status bar
--------------------------------------------------------------------------------
-- Right side: workspace name + date/time. Left side: LEADER indicator.
wezterm.on("update-status", function(window, _)
  local leader = ""
  if window:leader_is_active() then
    leader = wezterm.format({
      { Foreground = { Color = "#f38ba8" } },
      { Text = " ⌨ LEADER " },
    })
  end
  window:set_left_status(leader)

  local ws = window:active_workspace()
  local date = wezterm.strftime("%a %b %-d  %H:%M")
  window:set_right_status(wezterm.format({
    { Foreground = { Color = "#89b4fa" } },
    { Text = "  " .. ws .. "  " },
    { Foreground = { Color = "#a6adc8" } },
    { Text = "│ " .. date .. "  " },
  }))
end)

-- NOTE: Layout persistence (resurrect.wezterm) is deferred — the plugin currently
-- fails to load on Windows (libgit2 safe.directory error). Panes/status/appearance
-- below do not depend on it. Revisit LEADER s/r once that's resolved.

return config
