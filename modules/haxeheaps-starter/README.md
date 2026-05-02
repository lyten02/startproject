# haxeheaps-starter

Core framework module for Haxe/Heaps.io game projects. Used as a
git-subrepo'd module.

## What's Inside

| Path | Purpose |
|------|---------|
| `src/starter/` | Core framework (AppBase, IGame, IModule, save system) |
| `claude/scripts/` | Claude Code hooks (linked into project's `.claude/scripts/`) |
| `claude/skills/` | Generic skills (skill-writer, haxe-modular-tests, …) — namespace-copied to `.claude/skills/haxeheaps-starter__<name>/` |
| `.claude/settings.json` | Claude settings (linked into project's `.claude/settings.json`) |
| `templates/` | One-shot clone sources for new projects (README, public/index.html, .github/copilot-instructions.md) |
| `.gitignore_project` | `.gitignore` template (cloned into project root) |
| `module.json` | Declarative lifecycle metadata (links + clones + sourcePaths + skillsDir) |
| `CLAUDE.md` | Generic Haxe/Heaps AI guidance |

## Setup

```bash
# Add as a git-subrepo (preferred — content lives in main repo history):
git subrepo clone https://github.com/Lyten02/haxeheaps-starter.git modules/haxeheaps-starter

# Activate via the host runner (Noreline UI → project Modules tab → Enable).
```

The host runner reads `module.json` and performs four kinds of operation on
enable:

1. **Links** — symlink (or junction on Windows / fallback copy) of
   `.claude/settings.json` and `claude/scripts` into the project tree.
   Updates propagate when the module is updated upstream.
2. **Clones** — one-shot copies of `.gitignore`, `public/index.html`,
   `.github/copilot-instructions.md`, `README.md`. The project owns them
   afterward; re-enabling never overwrites (`ifMissing: true`).
3. **sourcePaths** — adds `modules/haxeheaps-starter/src` to
   `build/profiles/main.json.sourcePaths` so the compiler picks up the
   `AppBase`/`IGame`/`IModule` framework.
4. **skillsDir** — copies each subdir of `claude/skills/` into
   `.claude/skills/haxeheaps-starter__<skill>/` (namespaced).

Disable reverses 1 + 3 + 4 (clones stay — project owns them).

## Build System

The build system lives in a separate module:
[gd-builder](https://github.com/Lyten02/gd-builder).

```bash
git subrepo clone https://github.com/Lyten02/gd-builder.git modules/gd-builder
# Then enable both modules through the host runner.
```

## Documentation

See `CLAUDE.md` in this directory for generic Haxe/Heaps rules. Per-skill
docs live in `claude/skills/<skill>/SKILL.md`.

## License

Private template for Lyten02 projects
