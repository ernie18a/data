# Dual EMA ZloiV

- url: https://www.tradingview.com/script/RreiQdLk-Dual-EMA-ZloiV/
- type: indicator
- pine_id: PUB;3f1b84c4944f4060af363f2dd971ae65
- version: 1.0

## Description

OVERVIEW

Dual EMA ZloiV is a trend‑following indicator based on two exponential moving averages that color both the EMAs and the ribbon between them according to the current market direction. It is designed as a clean trend filter that quickly highlights bullish, bearish, and neutral phases without additional oscillators or visual noise.

FEATURES

Two customizable EMAs (fast and slow) with separate length and color settings for uptrend and downtrend, so you can adapt the tool to any market or timeframe.

Dynamic color change of each EMA depending on its slope and relative position, making trend shifts visually obvious on the chart.

Optional ribbon between the EMAs that reflects the overall trend direction (bullish/bearish/neutral) and helps you see momentum transitions at a glance.

Minimalistic design focused purely on trend visualization, so you can use it as a universal building block on top of your own strategies, entries and exits.

HOW TO USE

Use Dual EMA ZloiV as your primary trend filter: trade in the direction of the ribbon and EMA colors, and avoid or size down trades that go against the current trend.

Shorter EMA lengths work better for scalping and intraday trading, while longer lengths are more suitable for swing and positional setups.

Combine the indicator with your preferred entry tools (RSI, Stoch RSI, price action patterns, volume, etc.): Dual EMA ZloiV defines the direction, and other tools fine‑tune entries and exits.

LIMITATIONS

This script does not generate trade signals or execute orders; it only visualizes trend conditions based on two EMAs.

In choppy or low‑volatility markets the EMAs can frequently change color, so consider adding a separate trend/volatility filter (e.g., ADX, ATR, volume) in your system to reduce whipsaws.

## Source Code

````pine
//@version=6
indicator("Dual EMA ZloiV", overlay = true)

// ==================== ПАРАМЕТРЫ EMA ====================
ema1_length = input.int(10,  title = "EMA 1 Length (Fast)", minval = 1, group = "EMA Settings")
ema2_length = input.int(50, title = "EMA 2 Length (Slow)", minval = 1, group = "EMA Settings")

// Настройка цветов для EMA 1
ema1_color_up   = input.color(color.green,  title = "EMA 1 - Uptrend Color",   group = "EMA 1 Colors")
ema1_color_down = input.color(color.red,    title = "EMA 1 - Downtrend Color", group = "EMA 1 Colors")
ema1_color_flat = input.color(color.gray,   title = "EMA 1 - Flat/Neutral",    group = "EMA 1 Colors")

// Настройка цветов для EMA 2
ema2_color_up   = input.color(color.green,   title = "EMA 2 - Uptrend Color",   group = "EMA 2 Colors")
ema2_color_down = input.color(color.red, title = "EMA 2 - Downtrend Color", group = "EMA 2 Colors")
ema2_color_flat = input.color(color.gray,   title = "EMA 2 - Flat/Neutral",    group = "EMA 2 Colors")

// Период для определения направления тренда (для окраски самих EMA)
trend_lookback = input.int(3, title = "Trend Detection Period", minval = 1, group = "EMA Settings")

// ==================== РАСЧЕТ EMA ====================
ema1 = ta.ema(close, ema1_length)
ema2 = ta.ema(close, ema2_length)

// Направление для каждой EMA (для цвета линий)
ema1_rising  = ta.rising(ema1, trend_lookback)
ema1_falling = ta.falling(ema1, trend_lookback)

ema2_rising  = ta.rising(ema2, trend_lookback)
ema2_falling = ta.falling(ema2, trend_lookback)

ema1_trend_color = ema1_rising ? ema1_color_up : ema1_falling ? ema1_color_down : ema1_color_flat
ema2_trend_color = ema2_rising ? ema2_color_up : ema2_falling ? ema2_color_down : ema2_color_flat

// ==================== УСЛОВИЕ ДЛЯ ЛЕНТЫ ====================
// ТОЛЬКО это правило:
// быстрая ниже медленной => красная
// быстрая выше медленной => зелёная
fast_below_slow = ema1 < ema2
fast_above_slow = ema1 > ema2

// ==================== ПОСТРОЕНИЕ ЛИНИЙ EMA ====================
p1 = plot(ema1, color = ema1_trend_color, title = "EMA 1 (Fast)", linewidth = 2)
p2 = plot(ema2, color = ema2_trend_color, title = "EMA 2 (Slow)", linewidth = 2)

// ==================== ЛЕНТА МЕЖДУ EMA ====================
show_ribbon = input.bool(true, "Show Ribbon Between EMAs", group = "Ribbon Settings")

ribbon_color =
     fast_below_slow ? color.new(color.red,   80) :   // быстрая ниже медленной
     fast_above_slow ? color.new(color.green, 80) :   // быстрая выше медленной
                       color.new(color.gray,  90)     // равны / флет

fill(p1, p2, color = show_ribbon ? ribbon_color : na)
````
