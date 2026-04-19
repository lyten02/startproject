# haxeheaps-starter

Core framework module for Haxe/Heaps.io game projects. Used as a git submodule.

## What's Inside

| Path | Purpose |
|------|---------|
| `src/starter/` | Core framework (AppBase, IGame, IModule, save system) |
| `.claude/` | AI configuration (commands, docs, agents, tools) |
| `.codex/` | Codex AI config |
| `.vscode/` | VS Code settings, file templates, debugger, profile |
| `build/` | Haxe build configs (.hxml), Makefile.hlc |
| `setup.sh` | Creates symlinks + copies .gitignore + copies build/ |
| `.gitignore` | Template (copied as readonly to project) |
| `CLAUDE.md` | AI assistant instructions |

## Setup

```bash
# Add as a git subtree (preferred — content lives in main repo history):
git subtree add \
  --prefix=modules/haxeheaps-starter \
  https://github.com/Lyten02/haxeheaps-starter.git main --squash

# Activate from project root:
bash modules/haxeheaps-starter/enable.sh
```

`enable.sh` performs four stages (see `modules/CLAUDE.md` in host project):

1. **Symlinks** — `CLAUDE.md`, `.claude/settings.json`, `.claude/scripts` point
   at the starter module (updates propagate on `git subtree pull`).
2. **Clones** — one-shot copies of `.gitignore`, `public/index.html`,
   `.github/copilot-instructions.md`, `README.md` (the project owns them
   afterward; re-running enable never overwrites).
3. **Profile** — adds `modules/haxeheaps-starter/src` to
   `build/profiles/main.json` `sourcePaths`.
4. **Skills** — symlinks this module's Claude skills into `.claude/skills/`.

To deactivate: `bash modules/haxeheaps-starter/disable.sh` (reverses 1, 3, 4 —
does not delete cloned templates).

## Build System

The build system lives in a separate module: [gd-builder](https://github.com/Lyten02/gd-builder)

```bash
git submodule add https://github.com/Lyten02/gd-builder.git modules/gd-builder
bash modules/gd-builder/setup.sh
```

## Documentation

See `.claude/docs/` for architecture documentation.

## License

Private template for Lyten02 projects
