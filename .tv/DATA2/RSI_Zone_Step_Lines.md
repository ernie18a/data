<!-- tradingview-pine-id: PUB;6327ac8400944ebcbd63f46adf684eab -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# RSI Zone Step Lines

Source: https://www.tradingview.com/script/tmQKPi4G-RSI-Zone-Step-Lines/

## Description

RSI Zone Step Lines — Momentum-Bound Price Zone :

This indicator plots a dynamic price zone bounded by two independent step lines, each anchored to price at the moment RSI crosses a customizable upper or lower threshold. Rather than a single reference point, you get a full band that expands, contracts, and shifts as momentum moves between overbought and oversold territory — giving a visual read on where price sits relative to recent RSI extremes.

How the two boundary lines are built ? :

RSI (default length 9, source close, both adjustable) is checked against two thresholds — an upper threshold (default 55) and a lower threshold (default 45), both customizable in the inputs panel.

The upper level (green line) snaps to whatever price closed at the exact bar RSI crosses above the upper threshold. It then holds flat until the next upper-threshold cross.
The lower level (red line) snaps to price the moment RSI crosses below the lower threshold, and likewise holds flat until its next cross.

These two lines move completely independently of each other — the upper line only reacts to upper-threshold crosses, the lower line only to lower-threshold crosses. This means the zone width is not fixed: it can widen, narrow, or occasionally invert briefly if RSI whipsaws rapidly between both thresholds.

The zone fill :

The space between the two step lines is shaded continuously, and its color reflects RSI's current position — not which line moved most recently:

Green — RSI currently above the upper threshold → momentum extended to the bullish side
Red — RSI currently below the lower threshold → momentum extended to the bearish side
Grey — RSI sitting in the neutral 45–55 band → no clear momentum extreme

This lets you see at a glance not just where the momentum-derived price boundaries are, but whether RSI is actively pushing an extreme right now or has settled back into neutral.

Cross markers (the dots):

A small circle prints on each bar where a threshold cross occurs — green dots for upper crosses, red dots for lower crosses — so every boundary update is easy to spot even when the step lines blend into a long flat run.

What this indicator does and does not do? :

This tool visualizes a momentum-derived price band and its current bias; it does not generate buy/sell signals, predict future price direction, or manage risk. All thresholds, RSI settings, line colors, and zone fill colors are fully adjustable in the settings panel. As with any indicator, it's intended to be read alongside broader market structure and your own risk framework, not used in isolation.

---

## Source Code

````pine
//@version=6
indicator("RSI Zone Step Lines", timeframe="",overlay=true)

// ───────────── Inputs ─────────────
rsiLength   = input.int(9, title="RSI Length", minval=1)
rsiSource   = input.source(close, title="RSI Source")
upperThresh = input.int(55, title="Upper RSI Threshold", minval=1, maxval=99)
lowerThresh = input.int(45, title="Lower RSI Threshold", minval=1, maxval=99)

lineWidth   = input.int(2, title="Line Width", minval=1, maxval=5)
upperColor  = input.color(color.new(color.green, 0), title="Upper Level Color")
lowerColor  = input.color(color.new(color.red, 0), title="Lower Level Color")

zoneGreen   = input.color(color.new(color.green, 85), title="Zone Fill: RSI Above Upper")
zoneRed     = input.color(color.new(color.red, 85), title="Zone Fill: RSI Below Lower")
zoneGrey    = input.color(color.new(color.gray, 85), title="Zone Fill: RSI Between")

// ───────────── RSI ─────────────
rsiValue = ta.rsi(rsiSource, rsiLength)

// ───────────── Step Level Logic ─────────────
// Upper level: snaps to price whenever RSI crosses above the upper threshold.
// Lower level: snaps to price whenever RSI crosses below the lower threshold.
// Each holds flat independently until its own next crossing event.
var float upperLevel = na
var float lowerLevel = na

crossUp   = ta.crossover(rsiValue, upperThresh)
crossDown = ta.crossunder(rsiValue, lowerThresh)

if crossUp
    upperLevel := close

if crossDown
    lowerLevel := close

// ───────────── Zone Color (driven by current RSI position) ─────────────
zoneColor = rsiValue > upperThresh ? zoneGreen :
             rsiValue < lowerThresh ? zoneRed :
             zoneGrey

// ───────────── Plots ─────────────
pUpper = plot(upperLevel, title="Upper Level (RSI Cross Above)", style=plot.style_stepline, color=upperColor, linewidth=lineWidth)
pLower = plot(lowerLevel, title="Lower Level (RSI Cross Below)", style=plot.style_stepline, color=lowerColor, linewidth=lineWidth)

fill(pUpper, pLower, color=zoneColor, title="RSI Zone")

// Cross markers for reference
plotshape(crossUp ? close : na, title="Cross Above Upper", style=shape.circle, location=location.absolute, size=size.tiny, color=upperColor)
plotshape(crossDown ? close : na, title="Cross Below Lower", style=shape.circle, location=location.absolute, size=size.tiny, color=lowerColor)
````
