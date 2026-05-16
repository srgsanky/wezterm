local wezterm = require("wezterm")

local act = wezterm.action

local M = {}

local tab_mru_by_window_id = {}
local active_tab_by_window_id = {}

-- This runs from the status callback, so keep it strictly O(1). Do not call
-- tabs_with_info() here; that can marshal every tab into Lua.
local function active_tab_id_from_context(window, pane)
	if pane then
		local ok, tab = pcall(function()
			return pane:tab()
		end)

		if ok and tab then
			return tostring(tab:tab_id())
		end
	end

	local ok, tab = pcall(function()
		return window:active_tab()
	end)

	if ok and tab then
		return tostring(tab:tab_id())
	end

	ok, tab = pcall(function()
		return window:mux_window():active_tab()
	end)

	if ok and tab then
		return tostring(tab:tab_id())
	end

	return nil
end

local function move_tab_to_mru_front(window_id, tab_id)
	local mru = tab_mru_by_window_id[window_id] or {}
	tab_mru_by_window_id[window_id] = mru

	for index = #mru, 1, -1 do
		if mru[index] == tab_id then
			table.remove(mru, index)
		end
	end

	table.insert(mru, 1, tab_id)
end

function M.record_active_tab(window, pane)
	local mux_window = window:mux_window()
	local window_id = tostring(mux_window:window_id())
	local active_tab_id = active_tab_id_from_context(window, pane)

	if not active_tab_id then
		return
	end

	if active_tab_by_window_id[window_id] ~= active_tab_id then
		active_tab_by_window_id[window_id] = active_tab_id
		move_tab_to_mru_front(window_id, active_tab_id)
	end
end

local function shorten_home_dir(path)
	local home = wezterm.home_dir

	if path == home then
		return "~"
	end

	if path:sub(1, #home + 1) == home .. "/" then
		return "~" .. path:sub(#home + 1)
	end

	return path
end

local function pane_current_directory(pane)
	if not pane then
		return nil
	end

	local cwd = pane:get_current_working_dir()
	if not cwd then
		return nil
	end

	local ok, file_path = pcall(function()
		return cwd.file_path
	end)

	if ok and file_path and file_path ~= "" then
		return shorten_home_dir(file_path)
	end

	local cwd_uri = tostring(cwd)
	ok, file_path = pcall(function()
		return wezterm.url.parse(cwd_uri).file_path
	end)

	if ok and file_path and file_path ~= "" then
		return shorten_home_dir(file_path)
	end

	return cwd_uri
end

local function tab_switcher_label(tab_info)
	local tab_number = tab_info.index + 1
	local title = tab_info.tab:get_title()
	local active_pane = tab_info.tab:active_pane()

	if title == "" and active_pane then
		title = active_pane:get_title()
	end

	if title == "" then
		title = "Tab " .. tab_number
	end

	local parts = {
		string.format("%d: %s", tab_number, title),
	}

	local pane_count = #tab_info.tab:panes()
	if pane_count > 1 then
		table.insert(parts, string.format("[%d panes]", pane_count))
	end

	local cwd = pane_current_directory(active_pane)
	if cwd then
		table.insert(parts, cwd)
	end

	return table.concat(parts, " - ")
end

local activate_selected_tab = wezterm.action_callback(function(window, pane, id)
	if not id then
		return
	end

	local window_id = tostring(window:mux_window():window_id())
	move_tab_to_mru_front(window_id, id)

	local ok, selected_tab = pcall(function()
		return wezterm.mux.get_tab(tonumber(id))
	end)

	if ok and selected_tab then
		selected_tab:activate()
		return
	end

	for _, tab_info in ipairs(window:mux_window():tabs_with_info()) do
		if tostring(tab_info.tab:tab_id()) == id then
			window:perform_action(act.ActivateTab(tab_info.index), pane)
			return
		end
	end
end)

local function show_tab_switcher(window, pane)
	M.record_active_tab(window, pane)

	-- Build the detailed list only when the switcher is opened. This keeps
	-- title/cwd/pane-count work out of per-refresh GUI callbacks.
	local choices = {}
	local added_tab_ids = {}
	local mux_window = window:mux_window()
	local window_id = tostring(mux_window:window_id())
	local active_tab_id = active_tab_id_from_context(window, pane) or active_tab_by_window_id[window_id]
	local present_tab_ids = {}
	local tabs_by_id = {}
	local tabs_in_position_order = {}

	for _, tab_info in ipairs(mux_window:tabs_with_info()) do
		local tab_id = tostring(tab_info.tab:tab_id())
		present_tab_ids[tab_id] = true
		tabs_by_id[tab_id] = tab_info
		table.insert(tabs_in_position_order, { id = tab_id, info = tab_info })

		if tab_info.is_active then
			active_tab_id = tab_id
		end
	end

	if active_tab_id then
		active_tab_by_window_id[window_id] = active_tab_id
	end

	local mru = tab_mru_by_window_id[window_id] or {}
	for index = #mru, 1, -1 do
		if not present_tab_ids[mru[index]] then
			table.remove(mru, index)
		end
	end

	for _, tab_id in ipairs(mru) do
		local tab_info = tabs_by_id[tab_id]
		if tab_info and tab_id ~= active_tab_id then
			table.insert(choices, {
				id = tab_id,
				label = tab_switcher_label(tab_info),
			})
			added_tab_ids[tab_id] = true
		end
	end

	for _, tab in ipairs(tabs_in_position_order) do
		if tab.id ~= active_tab_id and not added_tab_ids[tab.id] then
			table.insert(choices, {
				id = tab.id,
				label = tab_switcher_label(tab.info),
			})
		end
	end

	if #choices == 0 then
		return
	end

	window:perform_action(
		act.InputSelector({
			title = "Select Tab",
			choices = choices,
			fuzzy = true,
			fuzzy_description = "Tab number or title: ",
			action = activate_selected_tab,
		}),
		pane
	)
end

function M.key_binding()
	return {
		key = "e",
		mods = "CMD",
		action = wezterm.action_callback(show_tab_switcher),
	}
end

return M
