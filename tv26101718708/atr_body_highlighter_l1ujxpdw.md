# ATR Body Highlighter

- url: https://www.tradingview.com/script/l1ujxpdw-ATR-Body-Highlighter/
- type: indicator
- pine_id: PUB;db1c387013444def934c1467f242acb5
- version: 1.0

## Description

Highlights bars whose bodies are more than n * ATR (e.g 1.5 times ATR). You can choose the ATR  multiplier, the highlighting color, and the opacity.

## Source Code

````pine
//@version=6
indicator("ATR Body Highlighter", overlay=true)

// ─── Inputs ───────────────────────────────────────────────────────────────────
atrPeriod  = input.int(14,    "ATR Period",        minval=1)
atrMult    = input.float(1.5, "ATR Threshold",     minval=0.1, step=0.1,
             tooltip="e.g. 1.5 = 150% of one ATR")
hlColor    = input.color(color.new(color.yellow, 50), "Highlight Color")

// ─── Calculations ─────────────────────────────────────────────────────────────
atrValue    = ta.atr(atrPeriod)
bodySize    = math.abs(close - open)
isTriggered = bodySize >= atrValue * atrMult

// ─── Recolor native candles ───────────────────────────────────────────────────
barcolor(isTriggered ? hlColor : na)
````
