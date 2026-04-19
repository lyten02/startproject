# utest Spec template

Copy-paste and fill the `<...>` placeholders. Save under:

- `test/<pkg>/<Name>Spec.hx` для классов из `src/`
- `modules/<mod>/test/unit/<Name>Spec.hx` для классов из `modules/<mod>/src/`

## Базовый шаблон

```haxe
package <pkg>;

import utest.Test;
import utest.Assert;
import <full.qualified.pkg>.<ClassToTest>;

class <Name>Spec extends Test {
    var subject:<ClassToTest>;

    public function setup() {
        subject = new <ClassToTest>(<...ctor args>);
    }

    public function test<BehaviourUnderTest>() {
        // given
        var input = <...>;

        // when
        var actual = subject.<method>(input);

        // then
        Assert.equals(<expected>, actual);
    }

    public function test<AnotherBehaviour>() {
        Assert.isTrue(subject.<predicate>());
    }
}
```

## Шаблон с ожидаемым исключением

```haxe
public function testInvalidInputRaises() {
    Assert.raises(() -> subject.parse(null), String);
    // второй аргумент — тип исключения (класс или enum). Для String throws — `String`.
}
```

## Шаблон с глубокой структурной эквивалентностью

```haxe
public function testParserReturnsMap() {
    var result = MapLoader.parse(jsonString);
    Assert.same({ width: 10, height: 5, entities: [] }, result);
}
```

## Шаблон с фикстурой (мок)

Фикстура рядом: `test/<pkg>/<Name>Fixture.hx` (класс без `extends Test`, макрос его пропустит). В спеке:

```haxe
import <pkg>.<Name>Fixture;

class <Name>Spec extends Test {
    public function setup() {
        <Name>Fixture.install();
    }

    public function testUsesFixture() {
        Assert.equals("stubbed", <SomeClassUnderTest>.readValue());
    }
}
```

## Правила

- `setup()` — только инициализация, без `Assert.*`.
- Все `test*` методы публичные, без аргументов, без возвращаемого значения (кроме async-тестов — см. utest docs).
- Имя файла == имя класса. Нельзя `<Name>Fixture.hx` для класса теста — макрос отфильтрует.
- Нет `import h2d|hxd|h3d` (правило D из `CLAUDE.md`).
- Нет `hxd.Key.*` (правило H).
