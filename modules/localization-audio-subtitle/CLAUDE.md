# localization-audio-subtitle

> **Purpose:** Skeleton модуля для субтитров к озвучке. **v1 — контракты не написаны.**
> **Language:** First Russian, Second English.

## Состояние

Модуль пока содержит только `src/loc/audio/_ModuleMarker.hx` — маркер, чтобы билд-система видела путь. Ни контрактов, ни реализации — нет.

## Что тут НЕ делать

- **Не писать runtime-реализацию** (loader субтитров, voice cue-и) пока не определены контракты.
- **Не копировать код из `localization-text`.** Текст и субтитры имеют разные времянные характеристики (cue start/end, синхронизация со звуком).
- **Не лить зависимости от `localization-text` сюда.** Если нужен общий контракт — выносить в `localization-base`.

## Что делать при расширении

1. Определить контракт: что такое `SubtitleCue`, как связан с voice-line id, как синхронизируется с `hxd.snd.Channel`.
2. Вынести нейтральные типы в `localization-base` (`LocaleId` уже там).
3. Только потом — runtime-реализацию в этом модуле.

## Skill

`claude/skills/localization-audio-subtitle/SKILL.md` — короткий маркер, сообщающий, что v1 пуст. Подключение: `bash modules/localization-audio-subtitle/enable.sh`.
