-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- https://wezfurlong.org/wezterm/colorschemes/c/index.html#catppuccin-mocha
config.color_scheme = "Catppuccin Mocha"
config.colors = {
	-- cursor_bg = "#52ad70",
}
config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 19

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

-- keyboard shortcuts - see https://wezfurlong.org/wezterm/config/lua/keyassignment/index.html
-- https://wezfurlong.org/wezterm/config/lua/config/native_macos_fullscreen_mode.html
config.native_macos_fullscreen_mode = true

-- https://github.com/wez/wezterm/discussions/3672#discussioncomment-10307119
config.mouse_bindings = {
	-- CMD-click will open the link under the mouse cursor
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
