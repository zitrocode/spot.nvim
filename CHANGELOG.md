# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-04-29

### Added

- Command palette architecture with prefix-based source routing (`router.lua`)
- `spot.source` registry — a Provider pattern that allows registering any number
  of sources without touching the core modules
- Built-in `files` source: discovers files using `fd` with two-column display
  (basename + parent directory) and depth-first sorting
- Built-in `keymaps` source: declared interface and module scaffold; full
  implementation is planned for `v0.2.0`
- `spot.state` module with encapsulated getters and setters — no more direct
  field mutation from outside modules
- `spot.config` with a safe `get()` accessor that falls back to defaults even
  when `setup()` has not been called
- `spot.picker` as the single orchestrator for load / filter / display / execute;
  switches source automatically when the active prefix changes mid-query
- `ui/layout.lua` centralising all window geometry so positioning logic lives
  in one place
- `ui/window.lua` as a thin wrapper around `nvim_open_win` with `open`,
  `close`, `link_close`, `resize`, and `focus`
- `ui/keymaps.lua` receiving action callbacks explicitly — no coupling to
  concrete modules
- `ui/search.lua` receiving an `on_change` handler explicitly — no coupling to
  `picker` or `buffer` directly
- Live title bar update: the search window title changes to the active source
  name as the user types a prefix
- Configurable prefix routing table (`config.prefixes`) — users can remap or
  add prefixes without modifying plugin code
- Default prefix table: `>` → keymaps, `:` → commands, `#` → buffers,
  `$` → shell (sources for the last three are planned)
- User commands: `:Spot`, `:SpotToggle`, `:SpotFocus`, `:SpotClose`
- Default picker keymaps: `j`/`k` to move, `<CR>` to confirm, `<Esc>`/`q`
  to close
- `README.md` with installation, usage, prefix table, configuration reference,
  custom source guide, and architecture overview
- `CONTRIBUTING.md` with module layout, open/query/execute flow diagrams,
  local dev setup, step-by-step source authoring guide, coding conventions,
  and PR guidelines

[Unreleased]: https://github.com/zitrocode/spot.nvim/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/zitrocode/spot.nvim/releases/tag/v0.1.0
