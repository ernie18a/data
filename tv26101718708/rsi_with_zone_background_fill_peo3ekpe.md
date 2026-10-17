# RSI with Zone Background Fill

- url: https://www.tradingview.com/script/Peo3eKpe-rsi-with-zone-background-fill/
- type: indicator
- pine_id: PUB;545fecb6e68c4bfdb80b7ddb6425ff78
- version: 1.0

## Description

This indicator visually highlights overbought and oversold RSI zones directly on the price chart (since overlay=true).

What it does exactly:

Calculates the standard RSI (period 14, source close).

When RSI is above the specified level (default 70) — the chart background is colored reddish (overbought).

When RSI is below the specified level (default 30) — the background is colored greenish (oversold).

Fill transparency is adjustable (default 85% — barely noticeable).

The RSI line itself is not drawn on the chart (it is only displayed in the Data Window) to avoid cluttering the price chart.

Why it's useful:
To quickly see when the price is in extreme RSI zones without opening a separate indicator window. Convenient for context — for example, to look for reversals or confirm overbought/oversold conditions directly on the candles.[url=https://prnt.sc/LvQLG-ft971R]https://prnt.sc/LvQLG-ft971R[/url]

## Source Code

````pine
//@version=6
indicator("RSI with Zone Background Fill", overlay=true, format=format.price, precision=2)

// --- Settings Groups ---
var string G1 = "RSI Parameters"
rsiLen = input.int(14, "RSI Length", minval=1, group=G1)
rsiSrc = input.source(close, "Source", group=G1)

var string G2 = "Levels & Visuals"
obLevel = input.int(70, "Overbought Level", minval=50, maxval=100, group=G2)
osLevel = input.int(30, "Oversold Level", minval=0, maxval=50, group=G2)
transp  = input.int(85, "Fill Transparency", minval=0, maxval=100, group=G2)

// --- Calculations ---
rsiVal = ta.rsi(rsiSrc, rsiLen)

// --- Logic for Background Fill ---
// When RSI is above Overbought level -> Reddish fill
// When RSI is below Oversold level   -> Greenish fill
isOB = rsiVal > obLevel
isOS = rsiVal < osLevel

bgColor = isOB ? color.new(color.red, transp) : isOS ? color.new(color.green, transp) : na

// --- Rendering ---
bgcolor(bgColor, title="RSI Zone Fill")

// --- Plotting RSI in Data Window Only (since overlay=true) ---
plot(rsiVal, "RSI Value", display=display.data_window)
````
