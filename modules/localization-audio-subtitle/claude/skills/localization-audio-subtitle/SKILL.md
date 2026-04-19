---
name: localization-audio-subtitle
description: Skeleton module for voice-line subtitles. v1 contains ONLY src/loc/audio/_ModuleMarker.hx — no contracts, no runtime. Use this skill only to remind that the module is empty and to NOT implement runtime subtitle logic before contracts are defined. If the user asks to add subtitles, first extend contracts in localization-base, then come back here.
---

# localization-audio-subtitle

**v1 status:** skeleton. Единственный файл — `src/loc/audio/_ModuleMarker.hx`. Контрактов и реализации нет.

## Что делать при запросе "добавь субтитры"

1. **Стоп-писать код в этом модуле.** Сначала определить контракт.
2. Контрактные типы (`SubtitleCue`, `VoiceLineId`, общий `LocaleId`) → в `localization-base`.
3. Потом — рантайм-реализация в этом модуле (loader, timing, sync с `hxd.snd.Channel`).

## Что точно НЕ делать

- Не копировать код из `localization-text` сюда.
- Не импортировать `loc.text.*` в этом модуле.
- Не писать runtime без согласованного контракта.

Полный контекст — `modules/localization-audio-subtitle/CLAUDE.md`.
