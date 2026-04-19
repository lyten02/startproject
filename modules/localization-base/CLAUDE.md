# localization-base

> **Purpose:** Pure i18n contracts — interfaces, events, locale ids. Zero runtime deps.
> **Language:** First Russian, Second English.

## Правила этого модуля

1. **`libs: []`.** Никаких `import h2d.*`, `import hxd.*`, `import heaps.*`, никаких `deepnightLibs`. Если нужен рантайм — код идёт в `localization-text`, не сюда.
2. **Только контракты.** Typedef'ы, интерфейсы, enum abstract, события. Реализации — в других модулях локализации.
3. **Стабильность API.** Любое изменение `I18nContract` ломает `localization-text` и пользовательский код. Меняй типы только с миграционным планом.

## Файлы

```
src/loc/base/
├── I18nContract.hx   typedef { t, setLanguage, current }
├── IKeyResolver.hx   интерфейс резолвера ключей
├── KeyNamespace.hx   утилиты для namespace'ов ключей
├── LocaleId.hx       enum abstract (EN, RU, …)
└── LocEvent.hx       enum: Loaded(lang) | Change(lang) | MissingKey(key, lang)
```

## Что типично добавляют сюда

- Новый `LocaleId` (ISO-код локали).
- Новый `LocEvent` (например, `FontSwap(lang)`).
- Расширение `I18nContract` (с обновлением всех реализующих классов).

## Что сюда НЕ добавляют

- Загрузку ресурсов (это `I18nLoader` в `localization-text`).
- Сигналы Heaps (`hxd.Event`, `h2d.*`) — base не знает про Heaps.
- Логику plural/gender/date-format — это runtime concern.

## Skill

Claude-skill для этого модуля — `claude/skills/localization-base/SKILL.md`.
Подключается командой: `bash modules/localization-base/enable.sh`.
