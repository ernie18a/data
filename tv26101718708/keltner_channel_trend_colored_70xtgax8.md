# Keltner Channel (Trend Colored)

- url: https://www.tradingview.com/script/70XtGax8/
- type: indicator
- pine_id: PUB;583617f74ba44284b6dabb4f0f272c24
- version: 1.0

## Description

Was macht der Indikator?
Standard-Keltner-Channel mit einer cleveren Farb-Logik:

GRÜN → wenn der Trend steigt (bullish)
ROT → wenn der Trend fällt (bearish)
Alle drei Linien (oberes Band, EMA-Mitte, unteres Band) wechseln synchron die Farbe, und der Bereich zwischen den Bändern wird transparent in der passenden Trendfarbe gefüllt.

## Source Code

````pine
//@version=6
indicator("Keltner Channel (Trend Colored)", overlay=true, timeframe="", timeframe_gaps=true)

// --- Inputs ---
emaLength   = input.int(20, "EMA Length", minval=1)
atrLength   = input.int(10, "ATR Length", minval=1)
multiplier  = input.float(2.0, "ATR Multiplier", step=0.1, minval=0.1)
src         = input(close, "Source")

// Color mode: EMA direction (smoother) or close direction (more responsive)
useEmaDirection = input.bool(true, "Use EMA direction (smoother)")

// --- Calculations ---
emaVal    = ta.ema(src, emaLength)
atrVal    = ta.atr(atrLength)

upperBand = emaVal + multiplier * atrVal
lowerBand = emaVal - multiplier * atrVal

// --- Color Logic ---
// Trend direction: rising EMA or rising close
bool isBullish = useEmaDirection ? (emaVal > emaVal[1]) : (close > close[1])

bullColor = color.new(color.green, 0)
bearColor = color.new(color.red, 0)

lineColor = isBullish ? bullColor : bearColor

// Filled background (semi-transparent)
fillColor = isBullish ? color.new(color.green, 85) : color.new(color.red, 85)

// --- Plots ---
plot(emaVal,     "Middle (EMA)",  lineColor, 2)
plot(upperBand,  "Upper Band",    lineColor, 1)
plot(lowerBand,  "Lower Band",    lineColor, 1)

// Fill between upper and lower
pUpper = plot(upperBand, display=display.none)
pLower = plot(lowerBand, display=display.none)
fill(pUpper, pLower, fillColor, title="Channel Fill")
````
