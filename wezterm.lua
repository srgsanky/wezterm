-- Pull in the wezterm API
local wezterm = require("wezterm")

local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- https://wezfurlong.org/wezterm/colorschemes/c/index.html#catppuccin-mocha
config.color_scheme = "Catppuccin Mocha"
config.colors = {
	tab_bar = {
		-- The color of the inactive tab bar edge/divider
		inactive_tab_edge = "#575757",
	},
}

-- Previously used font: MesloLGS Nerd Font Mono
config.font = wezterm.font("JetBrains Mono")
config.font_size = 18

-----------------------------------------------------------------------------------------
--Tab bar
-----------------------------------------------------------------------------------------
config.enable_tab_bar = true
-- https://wezfurlong.org/wezterm/config/lua/config/tab_bar_at_bottom.html
config.tab_bar_at_bottom = true
-- The following is available only in nightly build as of now
-- <https://wezfurlong.org/wezterm/config/lua/config/show_close_tab_button_in_tabs.html>
-- config.show_close_tab_button_in_tabs = false

-- https://wezfurlong.org/wezterm/config/appearance.html#tab-bar-appearance-colors
config.window_frame = {
	-- The font used in the tab bar.
	-- Roboto Bold is the default; this font is bundled with wezterm.
	-- Whatever font is selected here, it will have the main font setting appended to it to pick up any
	-- fallback fonts you may have used there.
	font = wezterm.font({ family = "Roboto", weight = "Bold" }),

	-- The size of the font in the tab bar.
	-- Default to 10.0 on Windows but 12.0 on other systems
	font_size = 14.0,
}

-- https://wezfurlong.org/wezterm/config/lua/config/tab_bar_style.html
-----------------------------------------------------------------------------------------

-- INTEGRATED_BUTTONS will show the close, minimize, maximize buttons along with the tab bar
-- config.window_decorations = "RESIZE | INTEGRATED_BUTTONS"
config.window_decorations = "RESIZE"

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
		mods = "CMD",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},

	-- https://www.reddit.com/r/wezterm/comments/10jda7o/is_there_a_way_not_to_open_urls_on_simple_click/
	-- Disable the default behavior that opens URL with a mouse click without CMD
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = wezterm.action.DisableDefaultAssignment,
	},
	-- Disable the Ctrl-click down event to stop programs from seeing it when a URL is clicked
	{
		event = { Down = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = wezterm.action.Nop,
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
