---
name: localization-base
description: Pure i18n contracts — interfaces, events, LocaleId enum. Zero runtime deps (no Heaps, no hxd, no deepnightLibs). Use when adding a new locale id, defining a new LocEvent variant, extending I18nContract, or referring to what a backend must implement. Do NOT use for text loading or UI wiring — that is localization-text.
---

# localization-base

Слой контрактов для системы локализации Heaps-проектов. Runtime реализация — в `localization-text`.

## Файловая структура

Все файлы в `src/loc/base/` модуля `localization-base`:

- `I18nContract.hx` — `typedef I18nContract = { function t(key, ?args):String; function setLanguage(id):Void; function current():LocaleId; }` + `typedef PlaceholderArgs = haxe.DynamicAccess<String>`.
- `LocaleId.hx` — enum abstract с ISO-кодами локалей.
- `LocEvent.hx` — enum: `Loaded(lang) | Change(lang) | MissingKey(key, lang)`.
- `IKeyResolver.hx` — интерфейс для пользовательских резолверов ключей.
- `KeyNamespace.hx` — утилиты для namespace'ов (`ui.menu.start`).

## Инварианты

- `libs: []` в `module.json`. Никаких import из `h2d`, `hxd`, `heaps`, `deepnightLibs`, или любых UI/асет-API.
- Контракт, реализуемый `localization-text/I18n`. Менять сигнатуры — только с обновлением всех реализующих классов.
- Если нужен I/O, сигналы, Heaps — код идёт не сюда.

## Типовые задачи

- **Добавить локаль:** новый вариант в `LocaleId.hx`. Затем обновить конфиги в `localization-text` и `res/locale/`.
- **Новое событие локали:** вариант в `LocEvent`. Диспатчится в `I18n.signal` из `localization-text`.
- **Расширить контракт:** добавить метод в `I18nContract` typedef — но проверить, что `loc.text.I18n` реализует.

## Анти-паттерны

- `import h2d.Text;` — base не знает про Heaps. Сигнал, что код идёт не в base.
- Конкретная реализация (resolve ключа, загрузка ресурса) в base — всё это `localization-text`.
- Импорт из `localization-text` — циклическая зависимость. Base низший слой.

## Связанные модули

- `localization-text` — реализация контракта (`loc.text.I18n`).
- `localization-audio-subtitle` — отдельный контракт для субтитров (пока skeleton).
