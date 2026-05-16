# Visual Tab Switcher

This config maps `Cmd+E` to a visual tab switcher implemented with WezTerm's
`InputSelector`. It is intended to feel like IntelliJ's recent-file switcher:
press `Cmd+E`, then press `Enter` to jump to the most recently used non-current
tab, or type a tab number/title fragment to filter the list.

## Behavior

- The current tab is not shown.
- Tabs are ordered by most recently used first.
- The first item is the previous tab, so `Cmd+E`, `Enter` toggles between the two
  most recent tabs.
- Each entry is prefixed with the 1-based tab number, so typing `12` filters to
  tab 12 when it exists.
- Each entry also includes:
  - the tab title, falling back to the active pane title
  - `[N panes]` when the tab has splits
  - the active pane's current working directory, shortened under `$HOME` to `~`

Example label:

```text
12: api-server - [3 panes] - ~/src/api
```

## Recency Tracking

WezTerm does not expose a stable "active tab changed" window event in the config
API. To keep recency working for tab changes made with the mouse, built-in
`Cmd+1`-style bindings, or this switcher, the config records the active tab from
the existing `update-right-status` callback.

That callback must stay cheap. It only resolves the active pane's tab id and
updates an in-memory MRU list keyed by mux window id. It deliberately does not
call `tabs_with_info()` or build tab labels from the status callback.

After a config reload, recency starts fresh. Unseen tabs are appended in visible
tab-bar order until they have been visited.

## Performance Notes

This repo previously had a serious CPU issue from a custom `format-tab-title`
callback. That callback ran synchronously on the GUI thread and caused WezTerm to
marshal tab state into Lua on frequent title refreshes. Commit `e177e4e` removed
that callback and replaced it with built-in tab bar styling.

The switcher follows the same rule: no expensive tab enumeration on GUI refresh
paths.

Current performance shape:

- `update-right-status`: O(1), active tab id only.
- Selecting a tab: O(1) via `wezterm.mux.get_tab(tab_id):activate()`, with an
  O(tab count) fallback only if direct lookup fails.
- Opening `Cmd+E`: O(tab count) to build the selector choices. This is the only
  place where the config enumerates tabs and reads label details.

The `Cmd+E` path intentionally does the richer work there because the user asked
for directory and split information in the visible switcher. For very high tab
counts, the main cost at open time is expected to be:

- `mux_window:tabs_with_info()` to enumerate tabs and preserve current tab-bar
  order
- `tab:active_pane()` and `pane:get_current_working_dir()` to show cwd
- `tab:panes()` to count splits

Those calls are kept out of the hot status/title paths. Do not move them into
`format-tab-title`, `format-window-title`, `update-status`, or
`update-right-status`.

## Maintenance Guardrails

- Do not reintroduce `format-tab-title` for styling tab labels.
- Do not call `tabs_with_info()` from periodic or title-formatting callbacks.
- Keep `record_active_tab` O(1).
- Keep detailed label generation inside `show_tab_switcher`.
- Prefer stable tab ids for stored MRU state; resolve to tab objects only when
  activating or rendering the selector.

## Verification

Use WezTerm's config loader to catch syntax and action-constructor mistakes:

```sh
wezterm --config-file wezterm.lua show-keys --lua
```

Manual checks after `Cmd+R`:

1. Visit tab A, then tab B.
2. Press `Cmd+E`; tab A should be first and tab B should be absent.
3. Press `Enter`; focus should return to tab A.
4. Press `Cmd+E`, `Enter` again; focus should return to tab B.
5. Create a split in one tab; that tab should show `[2 panes]` or higher.
6. Change directories in a pane; reopening `Cmd+E` should show the updated cwd.
