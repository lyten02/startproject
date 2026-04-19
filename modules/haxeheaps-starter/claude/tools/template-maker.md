# File Templates Plugin

VSCode плагин для создания файлов по шаблонам с поддержкой переменных.

## Быстрый старт

1. ПКМ на папке в нужном контексте → **"New File from Template"**
2. Выбрать шаблон
3. Ввести имя класса
4. Для YAML: запустить `./tools/generate.sh`

## Доступные шаблоны

```text
.vscode/file-templates/
├── Atomic/
│   ├── Behaviour          # Entity Init поведение
│   ├── SceneEntityInstaller   # MonoBehaviour installer
│   └── EntityAPI          # YAML для генерации extension методов
├── Shader/
│   └── DefaultShader      # Unity shader
└── Tests/
    └── UnitTest           # Unit тест
```

## Переменные контекстов

Каждый контекст имеет `.local_variables` с автоподстановкой:

| Контекст       | NAMESPACE        | ENTITY_INTERFACE | SCENE_INSTALLER_BASE          |
|----------------|------------------|------------------|-------------------------------|
| ProjectContext | ProjectContext   | IProjectEntity   | SceneProjectEntityInstaller   |
| UIContext      | UIContext        | IUIEntity        | SceneUIEntityInstaller        |
| GameContext    | GameContext      | IGameEntity      | SceneGameEntityInstaller      |

Дополнительно: `GENERATE_DIR` — путь для сгенерированных файлов.

## Структура шаблона

Каждый шаблон состоит из двух файлов:

### Метаданные (*.meta.json)

```json
{
  "displayName": "Scene Entity Installer",
  "fileName": "$INPUT_FILE_NAME$.cs",
  "parameters": [
    {
      "name": "INPUT_FILE_NAME",
      "prompt": "Введите имя класса (например: PlayerInstaller)",
      "defaultValue": "NewInstaller"
    }
  ]
}
```

| Поле | Описание |
|------|----------|
| `displayName` | Название в меню |
| `fileName` | Имя файла (поддерживает переменные) |
| `parameters` | Параметры для ввода пользователем |

### Содержимое (*.tpl)

Переменные в формате `$VARIABLE_NAME$`:

```csharp
using Atomic.Entities;

namespace $NAMESPACE$
{
    public sealed class $INPUT_FILE_NAME$ : $SCENE_INSTALLER_BASE$
    {
        public override void Install($ENTITY_INTERFACE$ entity)
        {
            $CURSOR$
        }
    }
}
```

### Специальные переменные

| Переменная | Описание                       |
|------------|--------------------------------|
| `$CURSOR$` | Позиция курсора после создания |

## Локальные переменные (.local_variables)

JSON-файлы определяют переменные для папки и всех вложенных:

```json
{
  "NAMESPACE": "GameContext",
  "ENTITY_INTERFACE": "IGameEntity",
  "SCENE_INSTALLER_BASE": "SceneGameEntityInstaller",
  "GENERATE_DIR": "Assets/Scripts/Game/GameContext/Generate/"
}
```

**Приоритет:** локальные переменные переопределяют глобальные (из корня проекта).

## Добавление нового контекста

1. Создать папку `Assets/Scripts/Game/NewContext/`

2. Добавить `.local_variables`:

   ```json
   {
     "NAMESPACE": "NewContext",
     "ENTITY_INTERFACE": "INewEntity",
     "SCENE_INSTALLER_BASE": "SceneNewEntityInstaller",
     "GENERATE_DIR": "Assets/Scripts/Game/NewContext/Generate/"
   }
   ```

3. Создать YAML через шаблон **Entity API (YAML)**
4. Запустить `./tools/generate.sh`

## Создание нового шаблона

1. Создать папку-группу в `.vscode/file-templates/` (или использовать существующую)
2. Добавить `TemplateName.meta.json` с настройками
3. Добавить `TemplateName.tpl` с содержимым
4. Использовать переменные из `.local_variables` или определить в `parameters`

## Связь с генератором

Шаблон **Entity API (YAML)** создаёт файлы для генератора:

```yaml
namespace: $NAMESPACE$
className: PlayerAPI
directory: $GENERATE_DIR$
entityType: $ENTITY_INTERFACE$

values:
  - Health: IVariable<int>
  - Speed: float
```

После создания/изменения YAML запустить:

```bash
./tools/generate.sh
```

Генератор создаст extension методы в папке `Generate/`:

- `entity.HasHealth()`, `entity.GetHealth()`, `entity.AddHealth()`
- и т.д.
