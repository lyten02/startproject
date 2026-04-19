# Skill: Disable Pull-To-Refresh / Swipe-To-Refresh

> **Когда использовать:** При создании fullscreen web-игры или приложения, которое должно работать в iframe (Yandex Games, GamePush, CrazyGames) и на мобильных браузерах без нежелательной перезагрузки при свайпе вниз.

## Проблема

Pull-to-refresh (PTR) — жест "свайп вниз" для перезагрузки страницы. В мобильных браузерах и WebView он срабатывает даже внутри iframe, ломая игровой процесс. Ни одно решение в отдельности не покрывает все браузеры — нужна многоуровневая защита.

## 6 уровней защиты

### Уровень 1: HTML Meta (viewport)

**Что покрывает:** Предотвращает зум и масштабирование на всех мобильных браузерах.

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover" />
<meta name="apple-mobile-web-app-capable" content="yes" />
```

**Зачем:** `user-scalable=no` + `maximum-scale=1.0` блокируют pinch-zoom, который может вызвать PTR-подобное поведение. `viewport-fit=cover` убирает safe area gaps на iPhone с notch.

---

### Уровень 2: Early CSS (inline в `<head>`)

**Что покрывает:** Chrome, Edge, Firefox на Android; Safari на iOS (частично).

```html
<style>
  html, body {
    position: fixed;
    inset: 0;
    width: 100%;
    height: 100%;
    overflow: hidden !important;
    overscroll-behavior: none !important;
    overscroll-behavior-x: none !important;
    overscroll-behavior-y: none !important;
    touch-action: none !important;
  }
</style>
```

**Зачем:** Inline стили в `<head>` применяются МГНОВЕННО, до загрузки любого JS/CSS. Это критично — без них есть окно в ~100-500мс где PTR работает. `position: fixed` + `overflow: hidden` убирает скролл документа. `overscroll-behavior: none` блокирует PTR в Chrome/Edge/Firefox. `touch-action: none` блокирует все жесты браузера.

---

### Уровень 3: Global CSS (файл стилей)

**Что покрывает:** Дублирует уровень 2 для надёжности + добавляет класс для динамического управления.

```css
html, body {
  position: fixed;
  inset: 0;
  height: 100%;
  width: 100%;
  overflow: hidden;
  overscroll-behavior: none;
  overscroll-behavior-x: none;
  overscroll-behavior-y: none;
}

body {
  touch-action: none;
  -webkit-touch-callout: none;
  -webkit-user-select: none;
  user-select: none;
}

#root,
.app {
  overscroll-behavior: none;
}

/* Класс для усиленной блокировки (например, во время геймплея) */
html.game-scroll-lock,
body.game-scroll-lock,
body.game-scroll-lock #root,
body.game-scroll-lock .app {
  overflow: hidden !important;
  overscroll-behavior: none !important;
  overscroll-behavior-x: none !important;
  overscroll-behavior-y: none !important;
}

body.game-scroll-lock #root,
body.game-scroll-lock .app {
  touch-action: none !important;
}
```

**Динамическое управление классом (React):**

```tsx
useEffect(() => {
  const isGameScreen = state.screen === 'game';
  const html = document.documentElement;
  const body = document.body;
  html.classList.toggle('game-scroll-lock', isGameScreen);
  body.classList.toggle('game-scroll-lock', isGameScreen);

  return () => {
    html.classList.remove('game-scroll-lock');
    body.classList.remove('game-scroll-lock');
  };
}, [state.screen]);
```

---

### Уровень 4: JS Touch Interception (основной уровень для iOS)

**Что покрывает:** iOS Safari в iframe (Yandex Games, GamePush), Yandex Browser на Android.

```html
<script>
  // Pull-to-refresh prevention for iOS Safari iframe & Yandex Browser.
  // CSS overscroll-behavior doesn't work in iOS WebKit iframes.
  // Strategy: block ALL touchmove by default; only allow inside scrollable containers
  // with scroll room in the gesture direction.
  (function() {
    var startY = null;
    var startTarget = null;

    document.addEventListener('touchstart', function(e) {
      if (e.touches.length === 1) {
        startY = e.touches[0].clientY;
        startTarget = e.target;
      }
    }, { passive: true });

    document.addEventListener('touchmove', function(e) {
      if (e.touches.length !== 1) { e.preventDefault(); return; }

      // Find scrollable ancestor from touch origin
      var scrollable = null;
      var el = startTarget;
      while (el && el !== document.documentElement) {
        var style = window.getComputedStyle(el);
        var ov = style.overflowY;
        if ((ov === 'auto' || ov === 'scroll') && el.scrollHeight > el.clientHeight) {
          scrollable = el;
          break;
        }
        el = el.parentElement;
      }

      // No scrollable container — block everything
      if (!scrollable) { e.preventDefault(); return; }

      // Check scroll room in gesture direction
      var deltaY = e.touches[0].clientY - (startY || 0);
      var atTop = scrollable.scrollTop <= 0;
      var atBottom = scrollable.scrollTop + scrollable.clientHeight >= scrollable.scrollHeight - 1;

      // Swiping down (finger moves down) but already at top — block
      if (deltaY > 0 && atTop) { e.preventDefault(); return; }
      // Swiping up (finger moves up) but already at bottom — block
      if (deltaY < 0 && atBottom) { e.preventDefault(); return; }

      // Has scroll room — allow
    }, { passive: false });

    document.addEventListener('touchend', function() { startY = null; startTarget = null; }, { passive: true });
    document.addEventListener('touchcancel', function() { startY = null; startTarget = null; }, { passive: true });
  })();
</script>
```

**Зачем:** iOS Safari в iframe ИГНОРИРУЕТ `overscroll-behavior: none`. Единственный способ — перехватить `touchmove` и вызвать `preventDefault()`. Алгоритм умный: он не блокирует скролл внутри скроллируемых контейнеров (лидерборд, чат), но блокирует когда контейнер уже на краю (top/bottom bounce → PTR).

---

### Уровень 5: Viewport Sync

**Что покрывает:** Все мобильные браузеры с динамической адресной строкой (Chrome, Safari, Yandex).

```html
<script>
  // Keep viewport-bound dimensions in sync on mobile to avoid pull-to-refresh gaps.
  function syncMobileViewport() {
    var width = window.innerWidth + 'px';
    var height = window.innerHeight + 'px';
    var html = document.documentElement;
    var body = document.body;
    var canvas = document.getElementById('webgl');

    html.style.width = width;
    html.style.height = height;
    body.style.width = width;
    body.style.height = height;

    if (canvas) {
      canvas.style.width = width;
      canvas.style.height = height;
    }
  }

  // Re-run once after browser chrome animation settles (address bar show/hide).
  function scheduleMobileViewportSync() {
    syncMobileViewport();
    window.setTimeout(syncMobileViewport, 280);
  }

  scheduleMobileViewportSync();

  window.addEventListener('resize', scheduleMobileViewportSync);
  window.addEventListener('orientationchange', scheduleMobileViewportSync);
  if (window.visualViewport && window.visualViewport.addEventListener) {
    window.visualViewport.addEventListener('resize', scheduleMobileViewportSync);
  }
</script>
```

**Зачем:** Когда адресная строка прячется/появляется, `window.innerHeight` меняется. Если html/body не синхронизированы, появляется "зазор" — пустое пространство, которое браузер может интерпретировать как overscroll. Таймаут 280мс нужен потому что анимация адресной строки не мгновенная.

---

### Уровень 6: Scroll Reset

**Что покрывает:** Страховка от случайного смещения viewport.

```html
<script>
  function keepPageAtTop() {
    if (window.scrollX !== 0 || window.scrollY !== 0) {
      window.scrollTo(0, 0);
    }
  }

  keepPageAtTop();
  window.addEventListener('scroll', keepPageAtTop, { passive: true });
</script>
```

**Зачем:** Если что-то всё-таки сместило страницу (баг браузера, динамический контент), моментально возвращаем на `0,0`. Без этого смещённый viewport может "застрять" и показать белое пространство.

---

## Исключения для скроллируемых контейнеров

Некоторые элементы ДОЛЖНЫ скроллиться (лидерборд, чат, списки). Для них нужны CSS-исключения:

```css
.scrollable-list {
  overflow-y: auto;
  overscroll-behavior: contain;    /* Не пробрасывать overscroll наверх */
  -webkit-overflow-scrolling: touch; /* Инерционный скролл на iOS */
  touch-action: pan-y;             /* Разрешить вертикальный скролл */
}
```

**Ключевые свойства:**
- `overscroll-behavior: contain` — скролл не "пробивает" за пределы контейнера
- `touch-action: pan-y` — разрешает вертикальный скролл, блокирует горизонтальный и zoom
- `-webkit-overflow-scrolling: touch` — плавный скролл на iOS

JS Touch Interception (уровень 4) автоматически находит такие контейнеры через `getComputedStyle` и разрешает в них скролл, пока есть "запас" (scroll room).

---

## Дополнительно: блокировка контекстного меню и выделения

```html
<script>
  document.addEventListener('contextmenu', e => e.preventDefault());
  document.addEventListener('selectstart', e => e.preventDefault());
</script>
```

```css
body {
  -webkit-touch-callout: none;
  -webkit-user-select: none;
  user-select: none;
}
```

---

## Таблица совместимости

| Браузер / Платформа | Уровень 1 (meta) | Уровень 2 (early CSS) | Уровень 3 (global CSS) | Уровень 4 (JS touch) | Уровень 5 (viewport sync) | Уровень 6 (scroll reset) |
|---|---|---|---|---|---|---|
| Chrome Android | zoom | overscroll-behavior | + | fallback | address bar | fallback |
| Edge Android | zoom | overscroll-behavior | + | fallback | address bar | fallback |
| Firefox Android | zoom | overscroll-behavior | + | fallback | - | fallback |
| Safari iOS (standalone) | zoom | overscroll-behavior | + | fallback | address bar | fallback |
| Safari iOS (iframe) | zoom | **не работает** | **не работает** | **основной** | address bar | fallback |
| Yandex Browser Android | zoom | частично | частично | **основной** | address bar | fallback |
| Samsung Internet | zoom | overscroll-behavior | + | fallback | address bar | fallback |

**Легенда:**
- **основной** — это решение критично для данного браузера
- **+** — работает, дублирует
- **fallback** — страховка
- **не работает** — CSS решение игнорируется браузером

---

## Порядок размещения в HTML

```
<head>
  1. viewport meta
  2. early CSS (inline <style>)
  3. external CSS (global.css)
</head>
<body>
  ... content ...
  4. contextmenu/selectstart блокировка
  5. viewport sync (syncMobileViewport)
  6. scroll reset (keepPageAtTop)
  7. JS touch interception (touchstart/touchmove/touchend)
</body>
```

Порядок важен: CSS должен быть до JS, early CSS до external CSS, viewport sync до touch interception.

# Mobile Web Issue Playbook: Swipe-to-Refresh + Startup Fullscreen

Дата: 2026-02-23
Обновлено: 2026-02-23
Статус: Решено (шаблон для будущих проектов)

## Что за проблема

На мобильных веб-проектах при вертикальном свайпе браузер может запускать pull-to-refresh (swipe-to-refresh). Это вызывает:
- нежелательную перезагрузку страницы;
- "прыжки" layout и визуальные зазоры;
- потерю иммерсивного режима.

Отдельно связанная проблема: fullscreen при старте может не включиться с первой попытки из-за gesture-ограничений браузера.

## Слои защиты (Defense in Depth)

### Слой 1: Early Inline CSS (head)

Применяется мгновенно до загрузки JS/Vite/React:

```css
html, body {
  width: 100%;
  height: 100%;
  overflow: hidden !important;
  overscroll-behavior: none !important;
  overscroll-behavior-x: none !important;
  overscroll-behavior-y: none !important;
}
```

**Работает в:** Chrome, Edge, Brave, Firefox
**НЕ работает в:** Яндекс Браузер (non-fullscreen mode)

### Слой 2: Canvas touch-action

```html
<canvas id="webgl" style="...;touch-action:none;"></canvas>
```

Блокирует браузерные жесты на уровне canvas-элемента.

### Слой 3: Viewport Sync

JS-скрипт синхронизирует `html`, `body`, `canvas` размеры с `window.innerWidth/innerHeight`:
- на старте
- на `resize`
- на `orientationchange`
- на `visualViewport.resize`

Предотвращает зазоры, через которые браузер может "поймать" жест.

### Слой 4: Scroll Guard

```javascript
function keepPageAtTop() {
  if (window.scrollX !== 0 || window.scrollY !== 0) {
    window.scrollTo(0, 0);
  }
}
window.addEventListener('scroll', keepPageAtTop, { passive: true });
```

Мгновенно возвращает страницу в позицию (0,0).

### Слой 5: React CSS (`global.css`)

Класс `game-scroll-lock` на `body` дублирует защиту в React-слое:
```css
body.game-scroll-lock {
  touch-action: none;
  overflow: hidden;
}
```

### Слой 6: Fullscreen Retry Loop

Mobile-only цикл:
- детект мобильного устройства
- попытка fullscreen каждые 100ms
- дополнительные попытки на `pointerdown`/`touchstart`
- остановка только после реального успеха

### Слой 7: JS touchmove preventDefault (Яндекс Браузер fix)

**Проблема:** Яндекс Браузер игнорирует CSS `overscroll-behavior: none` в режиме без fullscreen. Все 6 предыдущих слоёв не помогают — PTR всё равно срабатывает.

**Решение:** JS-обработчик `touchmove` с `{ passive: false }`:

```javascript
(function() {
  var startY = null;
  var startTarget = null;

  document.addEventListener('touchstart', function(e) {
    if (e.touches.length === 1) {
      startY = e.touches[0].clientY;
      startTarget = e.target;
    }
  }, { passive: true });

  document.addEventListener('touchmove', function(e) {
    if (startY === null || e.touches.length !== 1) return;
    var deltaY = e.touches[0].clientY - startY;
    // Only block downward swipe when page is at top (PTR gesture)
    if (deltaY <= 0 || window.scrollY > 0) return;

    // Allow scroll inside scrollable containers (e.g. leaderboard list)
    var el = startTarget;
    while (el && el !== document.documentElement) {
      var style = window.getComputedStyle(el);
      if (style.overflowY === 'auto' || style.overflowY === 'scroll') {
        if (el.scrollTop > 0) return;
        break;
      }
      el = el.parentElement;
    }
    e.preventDefault();
  }, { passive: false });

  document.addEventListener('touchend', function() { startY = null; startTarget = null; }, { passive: true });
  document.addEventListener('touchcancel', function() { startY = null; startTarget = null; }, { passive: true });
})();
```

**Логика:**
1. `touchstart` — запоминает начальную Y-координату и target-элемент
2. `touchmove` — проверяет условия:
   - `deltaY > 0` (свайп вниз) И `scrollY === 0` (страница наверху) → это PTR-жест
   - Если target внутри scrollable-контейнера (`overflow-y: auto/scroll`) и контейнер не в верхней позиции (`scrollTop > 0`) → разрешаем скролл
   - Иначе → `preventDefault()` блокирует PTR
3. `touchend`/`touchcancel` — сброс состояния

**Файлы:** `ui/index.html`, `ui/index.template.html` (inline script перед `</body>`)

**Совместимость:**

| Браузер | CSS защита работает | JS touchmove нужен | Результат |
|---------|--------------------|--------------------|-----------|
| Chrome/Edge/Brave | Да | Нет (дублирует) | OK |
| Firefox | Да | Нет (дублирует) | OK |
| Safari iOS | Да (нет PTR, rubber-band) | Нет (нейтрален) | OK |
| Яндекс Браузер (fullscreen) | Да | Нет (дублирует) | OK |
| Яндекс Браузер (non-fullscreen) | **НЕТ** | **ДА, критично** | OK с JS fix |
| Desktop | N/A | N/A (touch events не срабатывают) | OK |

## FAQ

**Q: Почему `{ passive: false }`?**
A: Браузер по умолчанию делает touch-события passive для лучшей производительности скролла. Но passive listener не может вызвать `preventDefault()`. Явный `{ passive: false }` разрешает блокировку.

**Q: Не ухудшит ли это производительность скролла?**
A: Нет. Обработчик срабатывает только при `deltaY > 0 && scrollY === 0` — это редкое условие. В остальных случаях `return` выполняется мгновенно.

**Q: Почему inline-скрипт, а не модуль?**
A: Загружается рано, до React/Vite, защита активна с первого кадра.

---

## Чеклист интеграции

1. **Яндекс Браузер (non-fullscreen):** свайп вниз в меню → НЕТ перезагрузки
2. **Яндекс Браузер:** рисование на canvas → работает нормально
3. **Яндекс Браузер:** скролл leaderboard → плавный скролл
4. **Яндекс Браузер:** leaderboard наверху + свайп вниз → PTR заблокирован
5. **Chrome/Edge:** регрессий нет
6. **Safari iOS:** rubber-band не сломан, UI работает

- [ ] Viewport meta с `user-scalable=no, maximum-scale=1.0, viewport-fit=cover`
- [ ] Inline `<style>` в `<head>` с `position: fixed; overflow: hidden; overscroll-behavior: none`
- [ ] Global CSS с `overscroll-behavior: none` на html, body, #root, .app
- [ ] Класс `game-scroll-lock` с `!important` для усиленной блокировки во время геймплея
- [ ] JS touch interception с `{ passive: false }` на `touchmove`
- [ ] Viewport sync на `resize`, `orientationchange`, `visualViewport.resize`
- [ ] Scroll reset на `scroll` event
- [ ] Скроллируемые контейнеры: `overscroll-behavior: contain; touch-action: pan-y`
- [ ] Тест на iOS Safari в iframe (Yandex Games / GamePush)
- [ ] Тест на Yandex Browser Android
