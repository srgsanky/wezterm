-- Pull in the wezterm API
local wezterm = require("wezterm")

-- Detect the operating system
-- https://wezfurlong.org/wezterm/config/lua/wezterm/target_triple.html
local is_mac = wezterm.target_triple == "aarch64-apple-darwin" or wezterm.target_triple == "x86_64-apple-darwin"

local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- https://wezfurlong.org/wezterm/colorschemes/c/index.html#catppuccin-mocha
-- Plain Catppuccin Mocha doesn't work well with Zellij (it causes extra orange background at the
-- top and bottom which are distracting). The Gogh version doesn't have this problem and practically
-- looks the same as the plain one (I couldn't tell the difference).
-- config.color_scheme = "Catppuccin Mocha"
config.color_scheme = "Catppuccin Mocha (Gogh)"
config.colors = {
	tab_bar = {
		-- The color of the inactive tab bar edge/divider
		inactive_tab_edge = "#575757",
	},
}

local font_size = 16

-- Previously used font: MesloLGS Nerd Font Mono
config.font = wezterm.font("JetBrains Mono")
config.font_size = font_size

-- Always show scroll bar on the right to get a sense of the scrollback length.
config.enable_scroll_bar = true

-----------------------------------------------------------------------------------------
--Tab bar
-----------------------------------------------------------------------------------------
config.enable_tab_bar = true
-- https://wezfurlong.org/wezterm/config/lua/config/tab_bar_at_bottom.html
config.tab_bar_at_bottom = true
-- The following is available only in nightly build as of now
-- <https://wezfurlong.org/wezterm/config/lua/config/show_close_tab_button_in_tabs.html>
-- config.show_close_tab_button_in_tabs = false

-- This is valid only when retro tab mode is used. Otherwise it is noop.
-- config.tab_max_width = 16

-- https://wezfurlong.org/wezterm/config/appearance.html#tab-bar-appearance-colors
config.window_frame = {
	-- The font used in the tab bar.
	-- Roboto Bold is the default; this font is bundled with wezterm.
	-- Whatever font is selected here, it will have the main font setting appended to it to pick up any
	-- fallback fonts you may have used there.
	font = wezterm.font({ family = "Roboto", weight = "Bold" }),

	-- The size of the font in the tab bar.
	-- Default to 10.0 on Windows but 12.0 on other systems
	font_size = font_size,
}

-- https://wezfurlong.org/wezterm/config/lua/window-events/format-tab-title.html

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
-- TODO: wezterm uses the title prefix "Copy mode:" when the pane enters copy mode.
--	     How to replicate this behavior when using custom tab title?
local function tab_title(tab_info)
	-- https://wezfurlong.org/wezterm/config/lua/TabInformation.html
	local title = tab_info.tab_title
	-- Use 1 based index
	local title_prefix = (tab_info.tab_index + 1) .. ": "
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title_prefix .. title
	end
	-- Otherwise, use the title from the active pane in that tab
	return title_prefix .. tab_info.active_pane.title
end

wezterm.on("format-tab-title", function(tab, _, _, _, hover, max_width)
	local edge_background = "#0b0022"

	-- Color for inactive tab
	local background = "#200c08" -- Black bean
	local foreground = "#D3D3D3" -- light gray

	if tab.is_active then
		background = "#FFA500" -- orange
		foreground = "#333333" -- gray
	elseif hover then
		background = "#3b3052"
		foreground = "#909090"
	end

	local edge_foreground = background

	local title = wezterm.truncate_right(tab_title(tab), max_width)
	return {
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
	}
end)

-- When in Copy mode, show an indicator at the bottom right.
-- https://wezfurlong.org/wezterm/config/lua/window/set_right_status.html
wezterm.on("update-right-status", function(window, _)
	local mode = window:active_key_table()

	local status = ""

	if mode == "copy_mode" then
		status = "  Copy mode  "
	end
	window:set_right_status(wezterm.format({
		{ Foreground = { AnsiColor = "Fuchsia" } },
		{ Background = { Color = "blue" } },
		{ Text = status },
	}))
end)

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
	bottom = "0cell",
}

-- https://wezfurlong.org/wezterm/scrollback.html
-- How many lines of scrollback you want to retain per tab
config.scrollback_lines = 1000000

-- keyboard shortcuts - see https://wezfurlong.org/wezterm/config/lua/keyassignment/index.html
-- https://wezfurlong.org/wezterm/config/lua/config/native_macos_fullscreen_mode.html
config.native_macos_fullscreen_mode = true

-- Modifiers: https://wezfurlong.org/wezterm/config/keys.html#configuring-key-assignments
-- Note: Key is case sensitive
--
-- NOTE: Make sure not to use <C-a> as the prefix for tmux. Otherwise, the tmux keybindings will be
--       painful.
-- <https://wezfurlong.org/wezterm/config/keys.html#leader-key>
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

-- https://wezfurlong.org/wezterm/config/default-keys.html
-- Use the following command to show code that you can copy paste.
-- wezterm show-keys --lua
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

	-- Zoom current pane (similar to <prefix> z in tmux)
	-- Default shortcut is CTRL + SHIFT + Z
	--
	-- CTRL + Z puts the current process in the background
	-- https://wezfurlong.org/wezterm/config/lua/keyassignment/TogglePaneZoomState.html
	-- {
	-- 	key = "Z",
	-- 	mods = "CTRL",
	-- 	action = wezterm.action.TogglePaneZoomState,
	-- },
	--
	{
		key = "z",
		mods = "LEADER",
		action = wezterm.action.TogglePaneZoomState,
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

	-- Split pane. v and s are inspired by Vim's split keybindings.
	-- Note the terms horizontal and vertical are inverted compared to Vim.
	{
		-- https://wezfurlong.org/wezterm/config/lua/keyassignment/SplitHorizontal.html
		key = "v",
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		-- https://wezfurlong.org/wezterm/config/lua/keyassignment/SplitVertical.html
		key = "s",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},

	-- Alternate split pane keybindings inspired by tmux.
	{
		key = "%",
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = '"',
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},

	-- Pass through leader key
	-- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
	{
		key = "a",
		mods = "LEADER|CTRL",
		action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }),
	},

	-- Resizing pane
	-- https://wezfurlong.org/wezterm/config/lua/keyassignment/AdjustPaneSize.html
	{
		key = "h",
		mods = "LEADER",
		action = act.AdjustPaneSize({ "Left", 10 }),
	},
	{
		key = "j",
		mods = "LEADER",
		action = act.AdjustPaneSize({ "Down", 10 }),
	},
	{
		key = "k",
		mods = "LEADER",
		action = act.AdjustPaneSize({ "Up", 10 }),
	},
	{
		key = "l",
		mods = "LEADER",
		action = act.AdjustPaneSize({ "Right", 10 }),
	},

	-- Disable the keybinding for full screen. My window is managed by aerospace.
	-- https://wezfurlong.org/wezterm/config/keys.html
	{ key = "Enter", mods = "ALT", action = act.DisableDefaultAssignment },

	-- Move current pane to new window
	{
		key = "!",
		mods = "LEADER",
		action = wezterm.action_callback(function(_, pane)
			pane:move_to_new_window()
		end),
	},
}

if is_mac then
	-- Default
	--    CTRL                 +                  ->   IncreaseFontSize
	--    SHIFT | CTRL         +                  ->   IncreaseFontSize
	--    SHIFT | CTRL         -                  ->   DecreaseFontSize
	--    SUPER                -                  ->   DecreaseFontSize
	--    CTRL                 _                  ->   DecreaseFontSize
	--    SHIFT | CTRL         _                  ->   DecreaseFontSize
	--    CTRL                 =                  ->   IncreaseFontSize
	--    SHIFT | CTRL         =                  ->   IncreaseFontSize
	table.insert(config.keys, { key = "+", mods = "CTRL", action = "DisableDefaultAssignment" })
	table.insert(config.keys, { key = "-", mods = "CTRL", action = "DisableDefaultAssignment" })
	table.insert(config.keys, { key = "_", mods = "CTRL", action = "DisableDefaultAssignment" })
	table.insert(config.keys, { key = "=", mods = "CTRL", action = "DisableDefaultAssignment" })
	table.insert(config.keys, { key = "+", mods = "SHIFT | CTRL", action = "DisableDefaultAssignment" })
	table.insert(config.keys, { key = "-", mods = "SHIFT | CTRL", action = "DisableDefaultAssignment" })
	table.insert(config.keys, { key = "_", mods = "SHIFT | CTRL", action = "DisableDefaultAssignment" })
	table.insert(config.keys, { key = "=", mods = "SHIFT | CTRL", action = "DisableDefaultAssignment" })
end

-- <https://wezfurlong.org/wezterm/config/keyboard-concepts.html#macos-left-and-right-option-key>
-- They help configure the behavior of left and right alt keys.
-- Composed key allows you to modify the input character. For e.g. alt + p can produce the symbol
-- pi. To use alt with readline, you don't want the behavior of composed keys.
--
-- <https://github.com/wez/wezterm/issues/216> is a good troubleshooting issue that motivated these
-- configurations. It resulted in the addition of an FAQ about readline configurations <https://github.com/wez/wezterm/commit/b936e9685b9ea1543376d5e4bb4b30bed38d339f>
-- Introduced as part of
-- <https://github.com/wez/wezterm/commit/2803e8fc58bd6adad2d549db11f4d3224dddc675#diff-3e1c02dfda2f6fbdd0890cce0b05013db7884e83461cb7d905a28afbe4559badR25>
--
-- These are the defaults. I have added them for visibility.
config.send_composed_key_when_left_alt_is_pressed = false -- Equivalent to Meta or Esc+ in iTerm
config.send_composed_key_when_right_alt_is_pressed = true -- Equivalent to Normal in iTerm

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

-----------------------------------------------------------------------------------------
-- Bell
-----------------------------------------------------------------------------------------
-- https://wezfurlong.org/wezterm/config/lua/config/audible_bell.html
config.audible_bell = "Disabled"
-- https://wezfurlong.org/wezterm/config/lua/config/visual_bell.html
config.visual_bell = {
	fade_out_function = "EaseOut",
	fade_out_duration_ms = 100,
}
config.colors = {
	visual_bell = "#A0522D",
}

-- Increasing the fps for a much smoother rendering experience.
config.max_fps = 120
-----------------------------------------------------------------------------------------

-- Kitty image protocol <https://github.com/wezterm/wezterm/issues/986>
config.enable_kitty_graphics = true

-- and finally, return the configuration to wezterm
return config
