# Contributing to spot.nvim

Thank you for your interest. This document covers everything you need to understand the codebase, run it locally, and submit changes.

## Table of contents

1. [Project philosophy](#1-project-philosophy)
2. [Repository layout](#2-repository-layout)
3. [How the pieces fit together](#3-how-the-pieces-fit-together)
4. [Setting up your environment](#4-setting-up-your-environment)
5. [Adding a new source](#5-adding-a-new-source)
6. [Changing the UI](#6-changing-the-ui)
7. [Coding conventions](#7-coding-conventions)
8. [Submitting a pull request](#8-submitting-a-pull-request)

## 1. Project philosophy

spot.nvim has three rules that every change must respect:

**One concern per module.** `router.lua` only resolves prefixes. `layout.lua` only computes geometry. `source/files.lua` only knows about files. If you find yourself importing five modules into a new file, the concern probably belongs somewhere that already exists.

**Dependencies flow downward, never sideways.** `ui/init.lua` is the only module allowed to import all UI sub-modules together. Sub-modules receive what they need as function arguments (callbacks, handles), not as `require()` calls to siblings. This makes each sub-module independently readable.

**The Source interface is the extension point.** Adding a new mode to the command palette means creating one new file in `source/`. The router, picker, UI, and state are untouched.

## 2. Repository layout

```
plugin/
  spot.lua               Neovim entry point — registers :Spot, :SpotToggle, etc.
                         Intentionally thin: no logic, only command registration.

lua/spot/
  init.lua               Public API. The only file users interact with directly.
                         Exports: setup(), open(), close(), toggle(), focus().

  config.lua             Configuration management.
                         M.defaults holds the canonical defaults (never mutated).
                         config.get() always returns a valid table, even before setup().

  state.lua              Single source of truth for all runtime state.
                         All fields are private. Access is through explicit
                         getters (get_*) and setters (set_*).
                         state.reset() returns everything to initial values.

  router.lua             Prefix resolution.
                         router.resolve(query) → { source, query, desc }
                         Reads the prefix table from config — no hardcoded prefixes.
                         Tries longer prefixes first to resolve ambiguity.

  picker.lua             Load / filter / display / execute orchestration.
                         The bridge between a source and the UI.
                         On every update_query() call it checks whether the
                         resolved source changed and reloads entries if needed.

  source/
    init.lua             Source registry (register, get, list).
                         Validates that sources implement the full interface.

    files.lua            Built-in source: filesystem via fd.
    keymaps.lua          Built-in source: registered Neovim keymaps.

  ui/
    init.lua             UI orchestrator. The ONLY module that imports all
                         UI sub-modules. Passes action callbacks down explicitly.

    layout.lua           Window geometry. Returns { row, col, width, height }.
                         Add a new window type here, not inside window.lua.

    window.lua           Thin wrapper around nvim_open_win.
                         open(), close(), link_close(), resize(), focus().

    buffer.lua           Scratch buffer factory.
                         create() and set_lines() — the only sanctioned way
                         to write to a results buffer from outside ui/.

    highlight.lua        Highlight group definitions.
                         highlight.setup() defines groups.
                         highlight.apply(win) sets window-local options.

    keymaps.lua          Picker keymap registration.
                         Receives an actions table — no imports of other modules.

    search.lua           TextChangedI autocmd.
                         Receives an on_change callback — no imports of other modules.
```

## 3. How the pieces fit together

### Open sequence

```
:Spot
  → spot.open()
      state.set_origin_win(current_win)
      picker.load()             ← calls default_source.load(), fills state
      ui.open()
          buffer.create() × 2
          layout.search() / layout.results()
          window.open() × 2
          window.link_close(search_win, results_win)
          highlight.setup() + highlight.apply()
          render(state.get_results())
          search.setup(buf, { on_change = … })
          keymaps.setup(buf, { cursor_down = …, confirm = …, … })
          vim.cmd("startinsert")
      state.set_open(true)
```

### Query update sequence

```
user types ">" in the search buffer
  → TextChangedI fires
      on_change(">")
          picker.update_query(">")
              router.resolve(">") → { source="keymaps", query=">", desc="keymaps" }
              "keymaps" ≠ current source "files"
                  → load_source("keymaps")   ← keymaps.load(), updates state
              filter_entries(entries, ">")   ← substring match on full query
              state.set_results(filtered)
              return route
          update_title("keymaps")            ← window title changes in real time
          render(state.get_results())
```

### Execute sequence

```
user presses <CR>
  → picker.execute_selected(close_windows)
      entry = state.get_results()[state.get_selected_index()]
      close_windows()            ← state.reset(), windows closed
      active_source.execute(entry, state)
```

## 4. Setting up your environment

Clone the repo and add it to Neovim's runtime path for development:

```lua
-- In your Neovim config, for local development only:
vim.opt.runtimepath:prepend("/path/to/spot.nvim")
```

Or with lazy.nvim, use the `dir` option:

```lua
{ dir = "/path/to/spot.nvim", config = function() require("spot").setup() end }
```

**Verify it loads:**

```
:Spot
```

**Inspect state at runtime:**

```lua
:lua print(vim.inspect(require("spot.state").get_results()))
:lua print(vim.inspect(require("spot.source").list()))
```

**Reload a module without restarting Neovim:**

```lua
:lua package.loaded["spot.picker"] = nil
:lua package.loaded["spot"] = nil
```

## 5. Adding a new source

This is the most common contribution. The entire change is **one new file** in `lua/spot/source/` and **one line** in `config.lua`.

### The Source interface

Every source must implement these three functions and one field:

```lua
--- @class spot.Source
--- @field name string
---   Unique identifier. Used in config.sources, config.prefixes, and state.
---   Must be a non-empty string with no spaces.

--- @field load fun(): string[]
---   Called once when the source becomes active (picker open or prefix typed).
---   Returns the full unfiltered entry list.
---   Results are cached in state — load() is NOT called on every keystroke.
---   Expensive operations (filesystem, API calls) belong here, not in display().

--- @field display fun(entries: string[]): string[]
---   Transforms raw entries into display lines shown in the results window.
---   MUST return a table of the same length as `entries` and in the same order.
---   The picker uses position to map a display line back to its raw entry.
---   Keep this fast — it runs on every keystroke while the source is active.

--- @field execute fun(entry: string, state: spot.State)
---   Called after the user confirms a selection. The picker closes first,
---   then execute() is called with the raw entry (not the display line).
---   Use state.get_origin_win() to restore context before acting.
```

### Step-by-step example: a `buffers` source

**1. Create `lua/spot/source/buffers.lua`:**

```lua
local M = {}

M.name = "buffers"

function M.load()
  local entries = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local name = vim.api.nvim_buf_get_name(buf)
      if name and name ~= "" then
        -- Raw entry is the buffer number as a string so execute() can parse it
        entries[#entries + 1] = tostring(buf) .. "\t" .. name
      end
    end
  end
  return entries
end

function M.display(entries)
  local lines = {}
  for _, entry in ipairs(entries) do
    local _, name = entry:match("^(%d+)\t(.+)$")
    local basename = vim.fs.basename(name)
    local parent   = vim.fs.dirname(name)
    lines[#lines + 1] = basename .. "  " .. parent
  end
  return lines
end

function M.execute(entry, state)
  local bufnr = tonumber(entry:match("^(%d+)\t"))
  if not bufnr then return end

  local origin = state.get_origin_win()
  if origin and vim.api.nvim_win_is_valid(origin) then
    vim.api.nvim_set_current_win(origin)
  end
  vim.api.nvim_set_current_buf(bufnr)
end

return M
```

**2. Register it in `config.lua` defaults:**

```lua
sources = { "files", "keymaps", "buffers" },   -- add "buffers"
prefixes = {
  ["#"] = { source = "buffers", desc = "buffers" },  -- already there
  ...
},
```

That is the entire change. The router, picker, state, and all UI modules are untouched.

### Rules for sources

- `load()` must return `string[]`. No exceptions — the filter operates on strings.
- `display()` must return a table of **exactly** the same length as `entries`. The picker maps positions, not values.
- If your source needs to associate rich data with an entry (like `keymaps.lua` does), use a module-level cache table populated in `load()` and read in `display()` / `execute()`. Reset the cache at the top of every `load()` call.
- If your source is **dynamic** (its entries depend on the current query, like a shell runner), set `M.dynamic = true`. The picker checks this flag and calls `load()` on every keystroke instead of once. Document that you are doing this because it has performance implications.

## 6. Changing the UI

### Adding a new window

1. Add a geometry function to `ui/layout.lua` — it returns `{ row, col, width, height }`.
2. Add handles to the `windows` table in `state.lua` with a getter and setter.
3. Open the window in `ui/init.lua` using `window.open(buf, geometry, opts)`.

Do not put coordinate arithmetic inside `window.lua`. That module is a thin wrapper; all positioning logic belongs in `layout.lua`.

### Changing the title bar

The search window title is updated in `ui/init.lua` inside the `on_change` callback via `update_title(route.desc)`. `route.desc` comes from the router and maps to the `desc` field in `config.prefixes`. Change the desc string in your config to change what the title shows.

### Changing picker keymaps

Edit `ui/keymaps.lua`. Each keymap receives a callback from `ui/init.lua` — the callbacks are defined there, not inside `keymaps.lua`. If you need a new action, add it to the `spot.Keymaps.Actions` class annotation, wire it in `ui/init.lua`, and register it in `keymaps.lua`.

## 7. Coding conventions

**Module structure.** Every file follows this order:

```
1. Module-level docstring (what this module does and doesn't do)
2. local requires
3. local M = {}
4. Internal helpers (local functions, prefixed with a --- comment block)
5. Public API (M.foo functions, each with LuaDoc annotations)
6. return M
```

**LuaDoc annotations.** All public functions must have `@param` and `@return` annotations. All classes must have `@class` and `@field` annotations. Use the types already defined in the codebase (`spot.Config`, `spot.Source`, `spot.State`, etc.) rather than `table` or `any`.

**No global state outside `state.lua`.** If you need to persist something between calls, add a getter and setter to `state.lua`. Module-level variables are allowed inside source files for per-source caches (see `keymaps.lua`), but they must be reset at the top of `load()`.

**Error handling.** Use `vim.notify(msg, vim.log.levels.WARN)` for recoverable problems (missing binary, unregistered source). Use `error()` only for programmer errors that indicate a broken invariant (wrong argument type passed to a public function).

**No silent failures.** If `load()` returns an empty list because something went wrong, it must notify the user why.

## 8. Submitting a pull request

1. **Open an issue first** for any change larger than a bug fix. Describe the problem you are solving, not the solution. This avoids duplicated effort.

2. **One concern per PR.** A new source, a bug fix, or a refactor — not all three at once.

3. **Update the docs.** If your change adds a config option, update the `M.defaults` table comment in `config.lua` and the Configuration section of `README.md`. If it adds a source, add a row to the Prefixes table in `README.md`.

4. **Test manually** by opening Neovim with the local dev setup described in section 4. Confirm that:
   - `:Spot` opens with the default source
   - Typing a prefix switches the title and results correctly
   - `<CR>` executes the selected entry in the origin window
   - `<Esc>` and `q` close the picker cleanly

5. **Commit messages** follow the format: `type(scope): description` — for example `feat(source): add buffers source` or `fix(router): handle empty prefix table`.
