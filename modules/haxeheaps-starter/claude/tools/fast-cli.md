# Fast CLI Utilities

Используй быстрые утилиты вместо стандартных.

## Таблица замен

| Вместо | Используй | Ускорение |
|--------|-----------|-----------|
| `find` | `fd` / `fdd` / `fdf` | 10-20x |
| `grep` | `rg` | 10-50x |
| `ls` | `eza` | 2-5x |
| `cat` | `bat` | 1.5x+ |

## Команды

### Поиск файлов

```bash
fd "pattern"              # Вместо find . -name "pattern"
fdd "Level*"              # Только директории
fdf "*.cs"                # Только файлы
fdf "*.cs" --changed-within 1hour  # Недавно изменённые
```

### Поиск в коде

```bash
rg "pattern"              # Вместо grep -r "pattern"
rg -n "pattern"           # С номерами строк
rg "class Player" --type cs
```

### Просмотр

```bash
eza -la                   # Вместо ls -la
eza --tree --level=2      # Дерево
bat file.cs               # Вместо cat (с подсветкой)
```

## Примеры для Unity

```bash
# Найти все скрипты
fdf "*.cs" Assets/Scripts/

# Поиск класса
rg "class PlayerEntity" --type cs

# Недавние изменения
fdf "*.cs" --changed-within 1day
```
