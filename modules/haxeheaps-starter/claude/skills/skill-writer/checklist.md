# Skill review checklist

Прогнать перед коммитом skill-а. Каждый пункт — да/нет.

## Frontmatter

- [ ] `name` задан, kebab-case, `[a-z0-9-]`, ≤64 символов.
- [ ] `name` совпадает с именем директории (`claude/skills/<name>/SKILL.md`).
- [ ] `description` задан, ≤1536 символов, в идеале 200–400.
- [ ] `description` front-loaded: сначала что делает, потом явные "use when" + "do NOT use for".
- [ ] Нет выдуманных полей (`when_to_use`, `argument-hint`, `allowed-tools`, и т.д.) — или проверено в доках, что поддерживается в текущей версии.
- [ ] YAML-блок валиден (между `---` с пустой строкой до тела).

## Тело

- [ ] Структура короткая: API, ключевые файлы, типовые задачи, анти-паттерны, ссылки.
- [ ] Код-блоки с языковым тегом (` ```haxe `, не голый ` ``` `).
- [ ] Никакой длинной прозы — список или короткий параграф.
- [ ] Анти-паттерны явные, с "почему".
- [ ] Ссылки на связанные skill-ы / модули.

## Supporting files

- [ ] `template.md` / `examples/` / `checklist.md` — только если экономят модели усилия.
- [ ] Ссылки на supporting files через `${CLAUDE_SKILL_DIR}/...`, не абсолютные пути.

## Путь и интеграция

- [ ] Файлы в `modules/<module>/claude/skills/<name>/`.
- [ ] `modules/<module>/enable.sh` существует (скопирован из шаблона).
- [ ] `modules/<module>/CLAUDE.md` существует и упоминает этот skill.
- [ ] Запуск `bash modules/<module>/enable.sh` кладёт симлинк в `<project>/.claude/skills/<name>/`.

## Валидация активации

- [ ] В новой сессии Claude Code в корне проекта `/skills` показывает skill.
- [ ] Запрос на сценарий, описанный в `description`, — активирует skill.
- [ ] Запрос на анти-сценарий — skill НЕ активируется ложно.

## Гит и Windows

- [ ] `.claude/skills/` игнорируется gitignore (симлинки не коммитим).
- [ ] `enable.sh` устанавливает `MSYS=winsymlinks:nativestrict` (Windows Git Bash).
- [ ] Симлинк на директорию, не на файл (junctions на Windows поддерживают только директории).
