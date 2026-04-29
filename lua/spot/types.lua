--- @class spot.Search.Handlers
--- @field on_change function(query: string)
---   Called on every keystroke in insert mode with the current buffer content.

--- @class spot.Keymap.Actions
--- @field cursor_down function: move the result cursor down one row.
--- @field cursor_up function: move the result cursor up one row.
--- @field confirm function: confirm the current selection.
--- @field close function: close the picker without selecting.

--- @class spot.Layout.Geometry
--- @field row integer: top row (0-based, relative to editor).
--- @field col integer: left column (0-based, relative to editor).
--- @field width integer: window width in columns.
--- @field height integer: window height in rows.

--- @class spot.Window.Opts
--- @field title? string: title shown in the window border.
--- @field enter? boolean: whether Neovim should enter the window on creation

--- @class spot.Buffer.Opts
--- @field modifiable? boolean: whether the buffer accepts user input (default: false).

--- @class spot.Source
--- @field name string: unique identifier used in config and state.
--- @field load function(): string[]
---   Returns the full, unfiltered list of entries
---   Called once per picker open (results are cached in state).
--- @field display function(entries: string[]): string[]
---   Transforms raw entries into display lines (one per result row).
---   Must return a table with the same lenght as `entries`.
--- @field execute function(entry: string, state: spot.State)
---    Called when the user confirms a selection.
---    Receives then raw entry string (not the display line).

--- @class spot.Router.Result
--- @field source string: name of the source to load entries from.
--- @field query string: the full query string (prefix included).
--- @field title string: human-read label for the active mode (for the title bar)

--- @class spot.State.Windows
--- @field search { buf: integer | nil, win: integer | nil }
--- @field results { buf: integer | nil, win: integer | nil }

--- @class spot.State
--- @field is_open boolean: whether the picker is currently visible.
--- @field query string: the current search query string.
--- @field entries string[]: the full, unfiltered list form the active sources.
--- @field results string[]: the filtered subset currently displayed.
--- @field selected_index integer: 1-based cursor position in the results list
--- @field origin_win integer | nil: the window handle active before the picker opened.
--- @field source_name string: name of the curretly active source.
--- @field windows spot.State.Windows: buffer and window handles for the picker UI

--- @class spot.Config.Windows
--- @field width integer: total width (columns) of the floating windows.
--- @field max_height integer: maximum number of visible result rows.

--- @class spot.Config.Prefix
--- @field source string: name of the source to activate when this prefix is detected.
--- @field desc string: short human-readable label shown in the title bar.

--- @class spot.Config
--- @field windows spot.Config.Windows
--- @field sources string[]: all source names to register on startup.
--- @field default_source string: source used when no prefix matches.
--- @field prefixes table<string, spot.Config.Prefix>
---   Maps a prefix string to the source it activates.
---   The prefix is kept inside the query — the source's filter sees the full
---   string including the prefix character.
---   Longer prefixes take priority over shorter ones (">>" beats ">").
