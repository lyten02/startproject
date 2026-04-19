# localization-text

> **Purpose:** Runtime i18n для Heaps-проектов — строки, шрифты, конфиги, reactive-текст.
> **Language:** First Russian, Second English.

## Правила этого модуля

1. **Зависимости.** `libs: ["heaps:git", "deepnightLibs"]`. Никакого `domkit` сюда — UI-слой в основном проекте.
2. **Контракты — из `localization-base`.** Реализации методов `I18n.t/setLanguage/current` должны соответствовать `loc.base.I18nContract`.
3. **Публичное API — только через `I18n`.** Пользовательский код не должен дергать `I18nStore`, `I18nLoader`, `MissingKeyLogger` напрямую — это внутренности.

## Публичное API

```haxe
I18n.init(?base:LocaleId)                    // инициализирует, загружает base-язык
I18n.setLanguage(lang:LocaleId)              // переключает текущий язык, диспатчит Change
I18n.t(key:String, ?args:PlaceholderArgs)    // "ui.start" -> "Start" или "Начать"
I18n.current():LocaleId                      // текущий язык
I18n.base():LocaleId                         // базовый язык (fallback)
I18n.has(key:String):Bool                    // есть ли ключ в текущем языке
I18n.signal                                  // I18nSignal: подписка на Loaded/Change/MissingKey
I18n.flushMissing()                          // сбросить лог отсутствующих ключей

// Только для тестов:
I18n.feedFlat(lang, Map<String,String>)     // посадить строки в обход hxd.Res
I18n.resetForTests()                         // сброс singleton'а
```

## Структура

```
src/loc/text/
├── I18n.hx                    статический фасад (публичное API)
├── I18nSignal.hx              подписка на LocEvent
├── I18nStore.hx               внутренний стор ключ->значение
├── I18nLoader.hx              загрузка из hxd.Res
├── MissingKeyLogger.hx        учёт missing keys
├── PlaceholderFormatter.hx    форматтер {name} плейсхолдеров
├── config/                    пользовательский конфиг (JSON-схема, миграции, бэкапы)
├── font/                      FontRegistry, FontSpec, LangFontMap (шрифт под язык)
├── macro/I18nValidator.hx     compile-time проверка ключей
└── reactive/
    ├── LocalizedBindings.hx
    └── ReactiveText.hx        h2d.Text, авто-обновляется при Change
```

## Fallback-правила

1. `I18n.t("foo.bar")` → пробует текущий язык.
2. Если нет — диспатчит `MissingKey(key, currentLang)`, пробует `baseLang`.
3. Если и там нет — возвращает `"#foo.bar"` (видимо в UI как маркер).

## Плейсхолдеры

```haxe
I18n.t("ui.hello", {name: "Alex"})   // "Hello, {name}" -> "Hello, Alex"
```

`PlaceholderArgs = haxe.DynamicAccess<String>` (из `localization-base`).

## Reactive UI

`reactive/ReactiveText.hx` — `h2d.Text`, который сам подписан на `I18n.signal` и пересчитывает значение при `Change(lang)`. Используется в основном проекте вместо ручного `text.text = I18n.t(...)`.

## Macro validation

`macro/I18nValidator.hx` — compile-time проверяет, что ключи в `I18n.t("...")` существуют во всех загруженных locale-файлах (в `res/locale/*.json`). Ошибка компиляции = забыли перевод.

## Анти-паттерны

- `I18nStore.resolve(...)` напрямую из UI-кода — идти через `I18n.t()`.
- `h2d.Text` без `ReactiveText` для переводимого текста — не обновится при смене языка.
- Сохранение `I18n.current()` в поле объекта — через сессию это может измениться. Лучше подписка на `signal`.

## Skill

Claude-skill для этого модуля — `claude/skills/localization-text/SKILL.md`.
Подключение: `bash modules/localization-text/enable.sh`.
