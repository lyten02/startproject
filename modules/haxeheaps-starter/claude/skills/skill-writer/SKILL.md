---
name: skill-writer
description: Author new Claude Code skills for haxeheaps-based projects. Use when the user asks to "write a skill", "create a SKILL.md", "add a Claude skill for module X", or needs guidance on the official SKILL.md format (frontmatter, discovery, symlink workflow). Includes a ready-to-copy template and a review checklist. Do NOT use for generic Claude Code questions — use the claude-code-guide agent instead.
---

# skill-writer

Фабрика Claude Code skill-ов для haxeheaps-модулей. Следует официальному формату: https://code.claude.com/docs/en/skills.md

## Формат SKILL.md (минимум)

```markdown
---
name: <kebab-case-name>
description: <what it does + when it activates; verbs front-loaded; ≤1536 chars; 200–400 typical>
---

# <Name>

<Короткая референсная выжимка: ключевые файлы, API, типовые задачи, анти-паттерны.>
```

Полный шаблон — `template.md` в этой же папке. Ссылка из моделе: `${CLAUDE_SKILL_DIR}/template.md`.
Чек-лист ревью перед коммитом — `${CLAUDE_SKILL_DIR}/checklist.md`.

## Правила frontmatter

- `name` — обязательно, kebab-case (`a-z`, `0-9`, `-`), ≤64 символов. Совпадает с именем директории.
- `description` — обязательно. Модель читает его, чтобы решить активировать skill или нет. Front-loading: сначала "что делает", потом "когда использовать". Включить явные триггеры ("use when...") и анти-триггеры ("do NOT use for...").
- **Не использовать** поля, не описанные в официальных доках: `when_to_use`, `argument-hint`, `allowed-tools`, `disable-model-invocation`, `user-invocable`, `paths`, `context`, `agent`, `model`, `effort`, `shell` — проверяй каждый раз в доках, поддерживается ли оно в текущей версии Claude Code. Если сомневаешься — не писать.

## Конвенция размещения для haxeheaps-проекта

```
modules/<module>/
├── CLAUDE.md                            правила модуля
├── enable.sh                            symlink-скрипт (шаблон одинаковый везде)
└── claude/skills/<skill-name>/
    ├── SKILL.md                         frontmatter + тело
    ├── template.md        (optional)    supporting file
    └── checklist.md       (optional)    supporting file
```

После создания skill-а: `bash modules/<module>/enable.sh` — симлинкует в `<project>/.claude/skills/`, и в новой сессии Claude skill становится видимым в `/skills`.

## Шаги написания skill-а

1. Определить единственный use-case: что пользователь хочет, чтобы делать, когда этот skill активен.
2. Сформулировать `description` как "what + when" в ≤400 символах. Front-load глаголы.
3. Перечислить в теле: ключевые файлы, публичное API (только то, что импортируется снаружи), типовые задачи ("как добавить X"), анти-паттерны.
4. Добавить supporting files (template, примеры), если они экономят модели усилия.
5. Прогнать по `checklist.md` — проверить длину, kebab-case, отсутствие выдуманных полей.
6. `bash modules/<module>/enable.sh`.
7. В новой сессии: `/skills` — увидеть свой skill; описать сценарий, на который он должен реагировать — убедиться, что активируется.

## Когда skill НЕ нужен

- **Информация уже в CLAUDE.md проекта.** Skill лишний.
- **Разовая задача.** Пиши инлайн в промпте, не skill.
- **Почти пустой модуль** (как `localization-audio-subtitle`). Лучше минимальный skill с "do NOT do X", чем пустой.

## Типовые ошибки

- `description` содержит только "what", без "when". Модель не активирует.
- `name` не совпадает с именем директории → skill не загружается.
- Создан skill, но `enable.sh` не запущен → `.claude/skills/<name>/` нет → skill невидим.
- Симлинк на Windows без `MSYS=winsymlinks:nativestrict` → `ln -s` делает копию; при обновлении skill-а копия не обновляется.
- В теле skill-а — длинная проза. Модель читает лучше коротких списков и блоков кода.

## Ссылки

- Официальные доки: https://code.claude.com/docs/en/skills.md
- Шаблон SKILL.md: `${CLAUDE_SKILL_DIR}/template.md`
- Чек-лист: `${CLAUDE_SKILL_DIR}/checklist.md`
