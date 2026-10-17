# Lunar Cycles - Moon Phases Indicator

- url: https://www.tradingview.com/script/eMhOpDLV-lunar-cycles-moon-phases-indicator/
- type: indicator
- pine_id: PUB;142789b926b6439a982a4adceb96ac33
- version: 1.0

## Description

# 🌙 Lunar Cycles — Фазы Луны на графике

Индикатор отображает фазы Луны прямо на ценовом графике. Многие трейдеры считают, что лунный цикл влияет на рыночные настроения — особенно на крипте, золоте и волатильных инструментах. Этот индикатор позволяет легко отслеживать ключевые точки цикла и проверить теорию на своём опыте.

## ✨ Возможности

- 4 ключевые фазы Луны: 🌑 Новолуние, 🌓 Первая четверть, 🌕 Полнолуние, 🌗 Последняя четверть
- Вертикальные линии на новолуние и полнолуние — для удобного визуального анализа
- Гибкие настройки: можно включать/выключать любую фазу
- 5 размеров луны на выбор (от tiny до huge)
- 3 стиля линий: сплошная, пунктирная, точечная
- Опциональный показ даты под каждой фазой
- Точный астрономический расчёт на основе синодического месяца (29.5306 дней)

## 📊 Как использовать

Классическая теория лунного цикла в трейдинге:

🌕 Полнолуние — часто совпадает с локальными максимумами, эмоциональными пиками рынка, потенциальными разворотами вниз
🌑 Новолуние — часто совпадает с локальными минимумами, периодами накопления, потенциальными разворотами вверх
🌓🌗 Четверти — переходные точки, используются как контекст

Простейшая стратегия: покупать ближе к новолунию, продавать ближе к полнолунию. Лучше всего работает на дневном таймфрейме на криптовалютах, золоте и индексах.

## ⚙️ Настройки

**Группа «Фазы»** — включение/выключение каждой из 4 фаз отдельно

**Группа «Вид»**:
- Размер луны
- Включение вертикальных линий
- Цвет линии новолуния (по умолчанию синий)
- Цвет линии полнолуния (по умолчанию жёлтый)
- Стиль линий
- Показ даты под луной

## 📈 Рекомендуемые таймфреймы

Дневной (1D) — оптимально, по одной метке на нужный день
4-часовой (4H) — тоже подходит
Часовой и ниже — работает, но метки появляются на конкретном баре пересечения фазы

## ⚠️ Важно

Влияние Луны на рынки — спорная концепция. Научные исследования (Yuan, Zheng, Zhu, 2006) находили слабый эффект (~3-5% годовой разницы между фазами), но он нестабилен и не является самостоятельным торговым сигналом. Используйте индикатор как дополнительный контекст к вашему основному анализу, а не как готовую систему.

## 🔧 Техническая основа

Расчёт ведётся от опорного новолуния 6 января 2000, 18:14 UTC. Длина синодического месяца — 29.530588853 дней. Точность — в пределах нескольких часов от реальных астрономических событий.

---

Если индикатор оказался полезным — поставьте лайк 👍 и подпишитесь. Буду рад фидбэку и предложениям в комментариях!

## Source Code

````pine
//@version=5
indicator("Лунные циклы by Zybkin", overlay=true, max_labels_count=500, max_lines_count=500)

// === Настройки фаз ===
showNew    = input.bool(true,  "🌑 Новолуние",          group="Фазы")
showFirstQ = input.bool(true,  "🌓 Первая четверть",    group="Фазы")
showFull   = input.bool(true,  "🌕 Полнолуние",         group="Фазы")
showLastQ  = input.bool(true,  "🌗 Последняя четверть", group="Фазы")

// === Настройки отображения ===
moonSize    = input.string("normal", "Размер луны", options=["tiny","small","normal","large","huge"], group="Вид")
showLines   = input.bool(true,  "Вертикальные линии для новолуния/полнолуния", group="Вид")
newLineCol  = input.color(color.new(color.blue, 70),   "Линия новолуния",   group="Вид")
fullLineCol = input.color(color.new(color.yellow, 60), "Линия полнолуния",  group="Вид")
lineStyle   = input.string("dashed", "Стиль линий", options=["solid","dashed","dotted"], group="Вид")
showDate    = input.bool(false, "Показывать дату под луной", group="Вид")

sz = moonSize=="tiny"?size.tiny : moonSize=="small"?size.small : moonSize=="large"?size.large : moonSize=="huge"?size.huge : size.normal
ls = lineStyle=="solid"?line.style_solid : lineStyle=="dotted"?line.style_dotted : line.style_dashed

// === Расчёт фазы ===
refNewMoon = timestamp("UTC", 2000, 1, 6, 18, 14)
synodicMs  = 29.530588853 * 86400000.0

cyclesNow  = (time    - refNewMoon) / synodicMs
cyclesPrev = (time[1] - refNewMoon) / synodicMs

phaseNow  = cyclesNow  - math.floor(cyclesNow)
phasePrev = cyclesPrev - math.floor(cyclesPrev)

// === Определение фаз ===
isNew    = phasePrev > 0.9  and phaseNow < 0.1
isFirstQ = phasePrev < 0.25 and phaseNow >= 0.25
isFull   = phasePrev < 0.5  and phaseNow >= 0.5
isLastQ  = phasePrev < 0.75 and phaseNow >= 0.75

// === Вспомогательная функция ===
transparent = color.new(color.black, 100)

drawMoon(cond, emoji, name) =>
    if cond
        txt = showDate ? emoji + "\n" + str.format_time(time, "dd.MM", "UTC") : emoji
        label.new(bar_index, high, txt, yloc=yloc.abovebar, color=transparent, style=label.style_none, size=sz, tooltip=name)

// === Метки ===
drawMoon(showNew    and isNew,    "🌑", "Новолуние")
drawMoon(showFirstQ and isFirstQ, "🌓", "Первая четверть")
drawMoon(showFull   and isFull,   "🌕", "Полнолуние")
drawMoon(showLastQ  and isLastQ,  "🌗", "Последняя четверть")

// === Вертикальные линии ===
if showLines and showNew and isNew
    line.new(bar_index, low, bar_index, high, extend=extend.both, color=newLineCol, style=ls)

if showLines and showFull and isFull
    line.new(bar_index, low, bar_index, high, extend=extend.both, color=fullLineCol, style=ls)
````
