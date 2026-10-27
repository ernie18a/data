# Perfect MACD Signal Long & Short

- url: https://www.tradingview.com/script/61R87V7g-perfect-macd-signal-long-short/
- type: indicator
- pine_id: PUB;cafbdc29b9df4d729634b332a2d6c9d1
- version: 1.0

## Description

Perfect MACD Signal — Long & Short
This indicator identifies high-probability entry points by combining four independent conditions into a single confluence signal. It filters out the noise of standard MACD crossovers and only fires when the market structure, momentum, and volume all align at the same time.
How it works:
An Ideal Long signal requires all four conditions to be true simultaneously:

MACD crosses above the signal line (bullish crossover)
Bullish divergence: price makes a new low, but MACD does not (MACD below zero)
Price is near a key support level (auto-detected via pivot lows)
Volume is above its moving average (above-average participation)

An Ideal Short signal mirrors this logic:

MACD crosses below the signal line
Bearish divergence: price makes a new high, but MACD does not (MACD above zero)
Price is near a key resistance level (auto-detected via pivot highs)
Volume is above its moving average

Partial signals (MACD crossover + high volume only) are also shown as smaller triangles, giving you early awareness even when the full setup is not yet complete.
Visual elements:

🔶 Orange diamond below the bar — Ideal Long
🔴 Red diamond above the bar — Ideal Short
Teal triangle — Partial Long
Red triangle — Partial Short
Dashed teal line — Dynamic support level
Dashed red line — Dynamic resistance level
Detailed label on each ideal signal with condition checklist
Background highlight on ideal signal bars

Alerts included: Ideal Long, Ideal Short, Partial Long, Partial Short.
Customizable settings: MACD periods, volume MA length, pivot lookback bars (left/right), proximity tolerance for support/resistance levels, and display toggles for levels and divergences.

The core idea is simple: the more conditions align, the higher the quality of the signal. Ideal signals are rare — and that's the point.

Works on any asset and any timeframe.


🇷🇺 РУССКИЙ
Идеальный сигнал MACD — Лонг и Шорт
Индикатор определяет точки входа с высокой вероятностью отработки, объединяя четыре независимых условия в единый confluenceсигнал. Он устраняет шум обычных пересечений MACD и срабатывает только тогда, когда структура рынка, импульс и объём совпадают одновременно.
Принцип работы:
Идеальный лонг требует одновременного выполнения всех четырёх условий:

MACD пересекает сигнальную линию снизу вверх (бычье пересечение)
Бычья дивергенция: цена обновляет минимум, а MACD — нет (MACD ниже нуля)
Цена находится вблизи ключевого уровня поддержки (определяется автоматически через pivot-минимумы)
Объём выше своей скользящей средней (повышенная активность участников)

Идеальный шорт — зеркальная логика:

MACD пересекает сигнальную линию сверху вниз
Медвежья дивергенция: цена обновляет максимум, а MACD — нет (MACD выше нуля)
Цена находится вблизи ключевого уровня сопротивления (определяется автоматически через pivot-максимумы)
Объём выше своей скользящей средней

Частичные сигналы (только пересечение MACD + высокий объём) отображаются в виде треугольников меньшего размера — они сигнализируют о потенциальной точке входа, даже если полный набор условий ещё не сформирован.
Визуальные элементы:

🔶 Оранжевый бриллиант под баром — Идеальный лонг
🔴 Красный бриллиант над баром — Идеальный шорт
Бирюзовый треугольник — Частичный лонг
Красный треугольник — Частичный шорт
Бирюзовая пунктирная линия — Динамический уровень поддержки
Красная пунктирная линия — Динамический уровень сопротивления
Подробная подпись на каждом идеальном сигнале с чеклистом условий
Цветная подсветка фона на барах с идеальным сигналом

Алерты: Идеальный лонг, Идеальный шорт, Частичный лонг, Частичный шорт.
Настраиваемые параметры: периоды MACD, длина MA объёма, количество баров для определения фракталов (левые/правые), допуск близости к уровням поддержки/сопротивления, переключатели отображения уровней и дивергенций.

Основная идея проста: чем больше условий совпадает — тем выше качество сигнала. Идеальные сигналы появляются редко, и именно в этом их ценность.

Работает на любом инструменте и любом таймфрейме.

## Source Code

````pine
//@version=6
indicator("Идеальный сигнал MACD — Лонг и Шорт", overlay = true)

// ── Настройки MACD ─────────────────────────────────────────
fast_len    = input.int   (12,   "MACD быстрая EMA",     minval = 1)
slow_len    = input.int   (26,   "MACD медленная EMA",   minval = 1)
signal_len  = input.int   (9,    "MACD сигнальная EMA",  minval = 1)

// ── Настройки объёма ───────────────────────────────────────
vol_ma_len  = input.int   (20,   "Период MA объёма",     minval = 1)

// ── Настройки уровней ──────────────────────────────────────
pivot_left  = input.int   (10,   "Левые бары фрактала",  minval = 1)
pivot_right = input.int   (10,   "Правые бары фрактала", minval = 1)
supp_tol    = input.float (0.003,"Допуск уровня (%)",    minval = 0.0001, step = 0.0005)

// ── Настройки отображения ──────────────────────────────────
show_support = input.bool (true, "Показывать уровни поддержки")
show_resist  = input.bool (true, "Показывать уровни сопротивления")
show_diverg  = input.bool (true, "Показывать дивергенции")

// ── Расчёт MACD ────────────────────────────────────────────
[macd, signal, hist] = ta.macd(close, fast_len, slow_len, signal_len)
cross_up   = ta.crossover (macd, signal)
cross_down = ta.crossunder(macd, signal)

// ── Расчёт объёма ──────────────────────────────────────────
vol_ma   = ta.sma(volume, vol_ma_len)
high_vol = volume > vol_ma

// ── Уровень поддержки (pivot low) ─────────────────────────
pivot_low  = ta.pivotlow (low,  pivot_left, pivot_right)
pivot_high = ta.pivothigh(high, pivot_left, pivot_right)

var float support_level = na
var float resist_level  = na
var line  support_line  = na
var line  resist_line   = na

if not na(pivot_low)
    if not na(support_line)
        line.delete(support_line)
    support_level := pivot_low
    if show_support
        support_line := line.new(
             bar_index, pivot_low, bar_index + 1, pivot_low,
             color  = color.new(color.aqua, 40),
             width  = 1,
             extend = extend.right,
             style  = line.style_dashed)

if not na(pivot_high)
    if not na(resist_line)
        line.delete(resist_line)
    resist_level := pivot_high
    if show_resist
        resist_line := line.new(
             bar_index, pivot_high, bar_index + 1, pivot_high,
             color  = color.new(color.red, 40),
             width  = 1,
             extend = extend.right,
             style  = line.style_dashed)

near_support = not na(support_level) and
               math.abs(close - support_level) / close <= supp_tol

near_resist  = not na(resist_level) and
               math.abs(close - resist_level) / close <= supp_tol

// ── Бычья дивергенция (для лонга) ─────────────────────────
lookback_div = 14
price_lower  = low  < ta.lowest (low,  lookback_div)[1]
macd_higher  = macd > ta.lowest (macd, lookback_div)[1]
bull_div     = price_lower and macd_higher and macd < 0

// ── Медвежья дивергенция (для шорта) ──────────────────────
price_higher = high  > ta.highest(high,  lookback_div)[1]
macd_lower   = macd  < ta.highest(macd,  lookback_div)[1]
bear_div     = price_higher and macd_lower and macd > 0

// ── Идеальный сигнал ЛОНГ ─────────────────────────────────
ideal_buy =
     cross_up     and
     bull_div     and
     near_support and
     high_vol

// ── Идеальный сигнал ШОРТ ─────────────────────────────────
ideal_sell =
     cross_down  and
     bear_div    and
     near_resist and
     high_vol

// ── Частичные сигналы ─────────────────────────────────────
partial_buy  = cross_up   and high_vol and not ideal_buy
partial_sell = cross_down and high_vol and not ideal_sell

// ── Отображение ЛОНГ сигналов ──────────────────────────────
plotshape(ideal_buy,
          title    = "Идеальный лонг",
          location = location.belowbar,
          style    = shape.diamond,
          size     = size.large,
          color    = color.new(#ff9800, 0),
          text     = "LONG")

plotshape(partial_buy,
          title    = "Частичный лонг",
          location = location.belowbar,
          style    = shape.triangleup,
          size     = size.normal,
          color    = color.new(#26a69a, 0))

// ── Отображение ШОРТ сигналов ──────────────────────────────
plotshape(ideal_sell,
          title    = "Идеальный шорт",
          location = location.abovebar,
          style    = shape.diamond,
          size     = size.large,
          color    = color.new(#ff1744, 0),
          text     = "SHORT")

plotshape(partial_sell,
          title    = "Частичный шорт",
          location = location.abovebar,
          style    = shape.triangledown,
          size     = size.normal,
          color    = color.new(#ef5350, 0))



// ── Фоновая подсветка ──────────────────────────────────────
bgcolor(ideal_buy  ? color.new(#ff9800, 85) : na, title = "Фон лонг сигнала")
bgcolor(ideal_sell ? color.new(#ff1744, 85) : na, title = "Фон шорт сигнала")

// ── Подписи с деталями ─────────────────────────────────────
if ideal_buy
    label.new(bar_index, low,
              text =
                   "ИДЕАЛЬНЫЙ ЛОНГ\n" +
                   "Пересечение MACD: да\n" +
                   "Бычья дивергенция: да\n" +
                   "Уровень поддержки: да\n" +
                   "Объём выше MA: да",
              style     = label.style_label_up,
              color     = color.new(#ff9800, 10),
              textcolor = color.white,
              size      = size.normal)

if ideal_sell
    label.new(bar_index, high,
              text =
                   "ИДЕАЛЬНЫЙ ШОРТ\n" +
                   "Пересечение MACD: да\n" +
                   "Медвежья дивергенция: да\n" +
                   "Уровень сопротивления: да\n" +
                   "Объём выше MA: да",
              style     = label.style_label_down,
              color     = color.new(#ff1744, 10),
              textcolor = color.white,
              size      = size.normal)

// ── Алерты ─────────────────────────────────────────────────
alertcondition(ideal_buy,   "Идеальный лонг",  "Все 4 условия совпали — идеальный сигнал на покупку!")
alertcondition(ideal_sell,  "Идеальный шорт",  "Все 4 условия совпали — идеальный сигнал на продажу!")
alertcondition(partial_buy, "Частичный лонг",  "MACD пересечение вверх + высокий объём")
alertcondition(partial_sell,"Частичный шорт",  "MACD пересечение вниз + высокий объём")
````
