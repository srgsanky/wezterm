-- Pull in the wezterm API
local wezterm = require("wezterm")

local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- https://wezfurlong.org/wezterm/colorschemes/c/index.html#catppuccin-mocha
config.color_scheme = "Catppuccin Mocha"
config.colors = {
	-- cursor_bg = "#52ad70",
}

-- Previously used font: MesloLGS Nerd Font Mono
config.font = wezterm.font("JetBrains Mono")
config.font_size = 18

config.enable_tab_bar = true

-- INTEGRATED_BUTTONS will show the close, minimize, maximize buttons along with the tab bar
config.window_decorations = "RESIZE | INTEGRATED_BUTTONS"

config.window_background_opacity = 1.0
config.macos_window_background_blur = 10

-- https://wezfurlong.org/wezterm/config/lua/config/window_padding.html
config.window_padding = {
	left = "1cell",
	right = "1cell",
	top = "0.5cell",
	bottom = "0.5cell",
}

-- https://wezfurlong.org/wezterm/scrollback.html
-- How many lines of scrollback you want to retain per tab
config.scrollback_lines = 1000000

-- keyboard shortcuts - see https://wezfurlong.org/wezterm/config/lua/keyassignment/index.html
-- https://wezfurlong.org/wezterm/config/lua/config/native_macos_fullscreen_mode.html
config.native_macos_fullscreen_mode = true

-- Modifiers: https://wezfurlong.org/wezterm/config/keys.html#configuring-key-assignments
-- Note: Key is case sensitive
config.keys = {
	-- https://wezfurlong.org/wezterm/config/lua/keyassignment/PaneSelect.html
	-- activate pane selection mode with the default alphabet (labels are "a", "s", "d", "f" and so on)
	{ key = "8", mods = "CTRL", action = act.PaneSelect },

	-- activate pane selection mode with numeric labels
	{
		key = "9",
		mods = "CTRL",
		action = act.PaneSelect({
			alphabet = "1234567890",
		}),
	},

	-- https://wezfurlong.org/wezterm/config/lua/keyassignment/ClearScrollback.html
	-- Clears the scrollback and viewport, and then sends CTRL-L to ask the
	-- shell to redraw its prompt. This mimics the equivalent behavior in iTerm2 and macOS terminal.
	{
		key = "k", -- Note: case-sensitive
		mods = "CMD",
		action = act.Multiple({
			act.ClearScrollback("ScrollbackAndViewport"),
			act.SendKey({ key = "L", mods = "CTRL" }),
		}),
	},
	-- Alternate way to clear scrollback
	{
		key = "K",
		mods = "CTRL|SHIFT",
		action = act.ClearScrollback("ScrollbackAndViewport"),
	},

	-- https://wezfurlong.org/wezterm/config/lua/keyassignment/ClearSelection.html
	{
		-- CTRL + SHIFT + c to copy selected text. Once the text is copied, reset the selection.
		-- Using y will result in a similar behavior
		key = "c",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			local has_selection = window:get_selection_text_for_pane(pane) ~= ""
			if has_selection then
				window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
				window:perform_action(act.ClearSelection, pane)
			end
		end),
	},
}

-- https://github.com/wez/wezterm/discussions/3672#discussioncomment-10307119
config.mouse_bindings = {
	-- CMD+click will open the link under the mouse cursor
	-- When in tmux, use CMD+SHIFT+click`. See <https://github.com/wez/wezterm/issues/2003>
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "SUPER",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
}

-- This is apparantly required for the cmd + click to work.
wezterm.on("open-uri", function(window, pane, uri)
	-- wezterm.log_info(window)
	-- wezterm.log_info(pane)
	-- wezterm.log_info(uri)
end)

-- and finally, return the configuration to wezterm
return config
