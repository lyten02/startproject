---
name: haxe-modular-tests
description: Write and fix utest specs for the Haxe/Heaps modular project (Node.js pure-logic tests). Use when user asks to add a test, write a spec, fix a failing test, increase coverage, verify a class, or diagnose test output. Do NOT use for Heaps runtime/UI tests or integration tests — this project only supports pure-logic unit tests under Node.js via `python build.py test`.
---

# haxe-modular-tests

Guide Claude to write correct utest specs for OverCooked. All tests run under Node.js (no Heaps runtime), are auto-collected by a macro, and have `--ai` JSON output for programmatic verification.

## Где лежат тесты

| Что тестируем | Путь | Пакет (cp-корень) |
|---|---|---|
| Логика самого проекта (`src/`) | `test/<pkg>/<Name>Spec.hx` | `test/` |
| Логика модуля (`modules/<mod>/src/`) | `modules/<mod>/test/unit/<Name>Spec.hx` | `modules/<mod>/test/` |
| Моки и фикстуры | `*Fixture.hx` рядом с тестом, или `test/fixtures/` | любой |

Макрос `TestCollector` сканирует `test/` + `modules/*/test/` и авто-регистрирует спеки. Ничего руками не регистрируем.

## Конвенции именования

- Имя файла == имя класса (правило проекта, см. `CLAUDE.md`).
- `*Spec.hx` — предпочтительный BDD-стиль.
- `Test*.hx` — legacy, тоже подхватывается.
- Имя **не должно** заканчиваться на `Fixture` — такие файлы макрос пропустит.
- Класс обязан быть `extends utest.Test` (или `extends Test` при `import utest.Test`).

## Шаблон спека

Полный, готовый для копирования → `${CLAUDE_SKILL_DIR}/template.md`.

Минимум:

```haxe
package game.core;

import utest.Test;
import utest.Assert;
import game.core.Vec2;

class Vec2Spec extends Test {
    var v:Vec2;

    public function setup() {
        v = new Vec2(0, 0);
    }

    public function testAddMutates() {
        v.add(3, 4);
        Assert.equals(3.0, v.x);
        Assert.equals(4.0, v.y);
    }
}
```

## Какие `Assert.*` использовать

| Сценарий | API |
|---|---|
| Равенство примитивов | `Assert.equals(expected, actual)` |
| Неравенство | `Assert.notEquals(a, b)` |
| Булево | `Assert.isTrue(x)`, `Assert.isFalse(x)` |
| Null-чеки | `Assert.isNull(x)`, `Assert.notNull(x)` |
| Глубокая структурная эквивалентность | `Assert.same(expected, actual)` |
| Float с epsilon | `Assert.floatEquals(expected, actual, 0.0001)` |
| Исключение | `Assert.raises(() -> risky(), ExceptionType)` |
| Regex | `Assert.match(~/pattern/, actual)` |

## Ограничения из CLAUDE.md (правила A–H)

- **D**: в тестах запрещены `import h2d.*`, `import hxd.*`, `import h3d.*`. Под Node.js Heaps недоступен — упадёт и в runtime, и на линтере.
- **H**: нельзя `hxd.Key.*`. Моки ввода — только через `GameAction` + `InputBindings`.
- Только чистая логика. Файлы из `res/` читаем через `typedef`-ы (пример: `MapData.hx`), не через `sys.io.File`.

## Запуск и интерпретация

Команды (из корня проекта):

```bash
python build.py test                         # все тесты, читабельный отчёт utest
python build.py test --module=<name>         # только тесты одного модуля
python build.py test --project-only          # только тесты самого проекта
python build.py test --ai                    # JSON одной строкой на stdout
python build.py test --module=<name> --ai    # JSON по модулю
```

Структура JSON от `--ai`:

```json
{
  "ok": true,
  "module": null,
  "project_only": false,
  "assertions": 1810,
  "successes": 1810,
  "errors": 0,
  "failures": 0,
  "failing_lines": []
}
```

Алгоритм для Claude после правок:
1. Запустить `python build.py test --ai` (или `--module=X --ai`).
2. Прочитать `ok`. `true` → готово.
3. `false` → смотреть `failing_lines`, чинить причину (не сам тест, если только red-TDD стадия), повторять.

## Что НЕ нужно делать

- Править `test/TestMain.hx` — макрос `TestCollector` сам подхватит новый файл.
- Регистрировать класс в каком-либо массиве.
- Создавать/копировать `test.hxml` — он живёт в `build/test.hxml`.
- Оборачивать тесты в `try/catch` — пусть падает, `Assert.*` и `raises` диагностируют.
- Устанавливать порядок тестов — utest прогоняет методы независимо, зависимости между ними запрещены.

## Анти-паттерны

- **Heaps-импорты** в спеке. Симптом: `ReferenceError` в Node или ошибка компиляции. См. правило D.
- **Чтение `res/` через `sys.io.File.getContent`** — проект использует typedef'ы и in-memory JSON в тестах.
- **Тесты приватных полей** — тестируем публичный контракт класса.
- **Глобальное состояние между тестами** — всегда инициализируйся в `setup()`, не полагайся на порядок.
- **Ассерты в `setup()`** — setup только инициализация; проверки только в `test*` методах.
- **Имя `XxxFixture.hx`** для класса теста — `TestCollector` его отфильтрует, тест не попадёт в прогон. Фикстуры — только для моков.

## Ключевые файлы

- `test/TestCollector.hx` — макрос автосбора, не трогать.
- `test/TestMain.hx` — entry point, одна строка, не трогать.
- `test/I18nTestFixture.hx` — пример фикстуры (подменяет i18n-строки для Node-тестов).
- `build/test.hxml` — cp/lib/defines для компиляции тестов.
- `build.py` — CLI с флагами `--module`/`--project-only`/`--ai`.

## Чеклист перед «готово»

Короткий ревью-лист → `${CLAUDE_SKILL_DIR}/checklist.md`.

## Связанные skill-ы

- `skill-writer` — когда нужно писать новый skill, а не тест.
- `localization-base`, `localization-text` — при добавлении тестов на i18n-логику.
