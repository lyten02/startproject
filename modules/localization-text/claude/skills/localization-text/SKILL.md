---
name: localization-text
description: Runtime i18n for Heaps — translate UI strings with I18n.t(), switch languages with I18n.setLanguage(), bind reactive text that auto-updates on locale change, manage per-language fonts, and validate keys at compile time. Use when adding/translating a UI string, wiring a text to locale changes, adding a new locale, registering a font for a language, or debugging missing-key fallbacks. Do NOT put contract changes here — those go in localization-base.
---

# localization-text

Рантайм локализации для Heaps. Фасад: `loc.text.I18n`. Контракт — `loc.base.I18nContract` из `localization-base`.

## Публичный API (используй только его)

```haxe
import loc.text.I18n;
import loc.base.LocaleId;

I18n.init(LocaleId.EN);                        // once, at boot
I18n.setLanguage(LocaleId.RU);                 // switch, dispatches Change(RU)
var s = I18n.t("ui.start");                    // "Start" / "Начать"
var g = I18n.t("ui.hello", {name: "Alex"});    // "{name}" placeholder
var lang = I18n.current();                     // LocaleId
I18n.signal.add(e -> switch e {                // subscribe
    case Loaded(l): trace('loaded $l');
    case Change(l): trace('switched to $l');
    case MissingKey(k, l): trace('miss $k@$l');
});
```

`PlaceholderArgs = haxe.DynamicAccess<String>` — то есть object literal `{key: "val"}`.

## Ключевые файлы (для чтения, не для прямого использования)

- `src/loc/text/I18n.hx` — фасад, статические методы.
- `src/loc/text/I18nSignal.hx` — диспатчер LocEvent.
- `src/loc/text/I18nStore.hx` — key→value хранилище (внутренне).
- `src/loc/text/I18nLoader.hx` — загрузка из `hxd.Res` (внутренне).
- `src/loc/text/PlaceholderFormatter.hx` — `{name}` подстановки.
- `src/loc/text/macro/I18nValidator.hx` — compile-time валидатор ключей.
- `src/loc/text/reactive/ReactiveText.hx` — `h2d.Text`, обновляется на `Change`.
- `src/loc/text/font/FontRegistry.hx` — шрифт для каждой локали (CJK, Cyrillic, Latin).
- `src/loc/text/config/ConfigManager.hx` — пользовательские настройки (язык, размер, …).

## Fallback chain

1. Resolve `key` в `currentLang`. Если найдено — форматировать и вернуть.
2. Если нет в current — `signal.dispatch(MissingKey(key, currentLang))`, резолвить в `baseLang`.
3. Если нет и в base — `logger.report(key, baseLang)` и вернуть `"#" + key` (видимый маркер в UI).

## Типовые задачи

### Добавить строку в UI

1. Добавить ключ во все `res/locale/*.json` (en, ru, …).
2. Использовать: `I18n.t("section.subsection.key")`.
3. Для `h2d.Text` в UI — использовать `ReactiveText`, чтобы обновлялся при смене языка.

### Переключить язык из UI

```haxe
I18n.setLanguage(LocaleId.RU);
// ReactiveText подписчики обновятся автоматически на Change-событии
```

### Добавить новую локаль

1. Добавить вариант в `loc.base.LocaleId` (модуль `localization-base`).
2. Создать `res/locale/<code>.json` со всеми ключами.
3. При необходимости — зарегистрировать шрифт в `FontRegistry` / `LangFontMap`.

### Подписаться на смену языка

```haxe
I18n.signal.add(e -> switch e {
    case Change(lang): refreshMyUI(lang);
    case _:
});
```

Отписаться — через возвращённое значение `.add` (детали в `I18nSignal.hx`).

### Тесты

```haxe
I18n.resetForTests();
I18n.feedFlat(LocaleId.EN, ["ui.start" => "Start"]);
I18n.init(LocaleId.EN);
Assert.equals("Start", I18n.t("ui.start"));
```

## Анти-паттерны

- **Прямое обращение к `I18nStore`/`I18nLoader`.** Только через `I18n.*`.
- **Кэширование `I18n.t(...)` в поле объекта.** Устареет после `setLanguage`.
- **Обычный `h2d.Text` для переводимой строки.** Используй `ReactiveText`, иначе не обновится.
- **`hxd.Res.locale_*` напрямую.** Идёт через `I18nLoader` — не обходить.
- **Добавить метод в `I18n.hx` без обновления `I18nContract`.** Контракт в `localization-base` — обновлять в паре.

## Связанные модули

- `localization-base` — контракты (`I18nContract`, `LocaleId`, `LocEvent`).
- `localization-audio-subtitle` — отдельный skeleton под субтитры голоса (v1 — пусто).
