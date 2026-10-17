# HMA Trend Color-AJ BRT

- url: https://www.tradingview.com/script/QOe6rXA5-HMA-Trend-Color-AJ-BRT/
- type: indicator
- pine_id: PUB;b3173f647dcf4becb44cebab00dcbdb2
- version: 1.0

## Description

Try this one to fight against big whales.  The higher the value smoother the indicator. I am doing this for the sake of the betterment the whole trading community. good luck

## Source Code

````pine
//@version=5
indicator("HMA Trend Color", overlay=true, max_bars_back=500)

// ─── Inputs ─────────────────────────────────────────────────
length = input.int(20,  title="HMA Length", minval=1)
src    = input.source(close, title="Source")

// ─── Hull Moving Average ─────────────────────────────────────
half   = math.floor(length / 2)
wma1   = ta.wma(src, half)
wma2   = ta.wma(src, length)
raw    = 2 * wma1 - wma2
sqrtN  = math.floor(math.sqrt(length))
hma    = ta.wma(raw, sqrtN)

// ─── Trend Detection ─────────────────────────────────────────
isUp     = hma > hma[1]
hmaColor = isUp ? color.new(color.green, 0) : color.new(color.red, 0)

// ─── Plot HMA line ───────────────────────────────────────────
plot(hma, title="HMA", color=hmaColor, linewidth=2)

// ─── Background highlight ────────────────────────────────────
bgColor = isUp ? color.new(color.green, 92) : color.new(color.red, 92)
bgcolor(bgColor, title="Trend Background")

// ─── Flip markers ────────────────────────────────────────────
flipUp   = isUp and not isUp[1]
flipDown = not isUp and isUp[1]

plotshape(flipUp,   style=shape.triangleup,   color=color.green,
          location=location.belowbar, size=size.small, title="Turned Up")
plotshape(flipDown, style=shape.triangledown, color=color.red,
          location=location.abovebar, size=size.small, title="Turned Down")

// ─── Alerts ──────────────────────────────────────────────────
alertcondition(flipUp,   title="HMA turned UP",   message="HMA slope flipped bullish")
alertcondition(flipDown, title="HMA turned DOWN", message="HMA slope flipped bearish")
````
