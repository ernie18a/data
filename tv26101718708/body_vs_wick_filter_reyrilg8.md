# Body vs Wick Filter

- url: https://www.tradingview.com/script/ReyRIlg8-Body-vs-Wick-Filter/
- type: indicator
- pine_id: PUB;17f6e72eec3049fd8aa9fd3cffa5f381
- version: 1.0

## Description

**Body vs Wick Filter**

The Body vs Wick Filter is a candle analysis tool that identifies candles with a significant body relative to their total range. The core idea behind this indicator is that candles with a large body and small wicks represent strong, decisive price movement, while candles with small bodies and large wicks indicate indecision, rejection or failed attempts to move in a direction. By filtering for candles that meet a minimum body percentage, traders can visually separate high-conviction moves from noise.

**How it works**

For every candle on the chart, the indicator calculates three values: the total candle range from high to low, the body size from open to close, and the remaining wick size. It then expresses the body as a percentage of the total range. A candle where the body takes up 80% of the total range is a strong, directional candle. A candle where the body is only 20% of the range is mostly wick and represents uncertainty in the market.

**Coloring and visual output**

Candles that meet or exceed your minimum body percentage threshold are highlighted directly on the chart. Bullish candles that qualify receive one color and bearish candles that qualify receive a separate color, both fully customizable in the settings. Candles that do not meet the threshold are left in their original chart color, so your attention is naturally drawn to the qualifying candles only.

An optional percentage label is displayed above each candle within the lookback window, showing the exact body percentage so you can quickly assess the strength of any candle at a glance.

**How to use it**

1. Set your minimum body percentage in the settings, for example 60%, to only highlight candles where the body makes up at least 60% of the total range
2. Choose your preferred colors for bullish and bearish qualifying candles
3. Adjust the lookback window to control how many recent candles display the percentage label
4. Use the Data Window by hovering over any candle to see the exact body percentage, wick percentage, total candle size in pips and body size in pips

**Practical applications**

This indicator is particularly useful for traders who base entries on candlestick structure, such as identifying strong momentum candles, confirming breakouts, or filtering out indecisive price action around key levels. It works on any timeframe and any instrument.

## Source Code

````pine
//@version=6
indicator("Body vs Wick Filter", overlay=true)

// Inputs
min_body_pct   = input.float(60.0, title="Minimaal body %", minval=1, maxval=100, step=1)
lookback       = input.int(100, title="Lookback candles", minval=1)
show_label     = input.bool(true, title="Toon % label op candle")
bullish_color  = input.color(color.new(color.yellow, 0), title="Kleur bullish candle")
bearish_color  = input.color(color.new(color.blue, 0),   title="Kleur bearish candle")

// Candle grootte berekeningen
candle_range = high - low
body_size    = math.abs(close - open)
wick_size    = candle_range - body_size

body_pct = candle_range != 0 ? (body_size / candle_range) * 100 : 0
wick_pct = candle_range != 0 ? (wick_size / candle_range) * 100 : 0

is_valid   = body_pct >= min_body_pct
is_bullish = close >= open

// Kleur op basis van richting candle
valid_color = is_bullish ? bullish_color : bearish_color
barcolor(is_valid ? valid_color : na)

// Label
if show_label and bar_index >= last_bar_index - lookback
    label_txt = str.tostring(math.round(body_pct, 1)) + "%"
    label.new(
      x         = bar_index,
      y         = high,
      text      = label_txt,
      style     = label.style_label_down,
      color     = is_valid ? valid_color : color.gray,
      textcolor = color.white,
      size      = size.tiny)

// Data window
plot(body_pct,                       title="Body %",      color=color.blue,   display=display.data_window)
plot(wick_pct,                       title="Wick %",      color=color.orange, display=display.data_window)
plot(candle_range / syminfo.mintick, title="Candle pips", color=color.purple, display=display.data_window)
plot(body_size   / syminfo.mintick,  title="Body pips",   color=color.teal,   display=display.data_window)
````
