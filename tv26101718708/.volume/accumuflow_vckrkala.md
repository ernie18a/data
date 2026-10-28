# AccumuFlow 

- url: https://www.tradingview.com/script/vcKrKaLa-AccumuFlow/
- type: indicator
- pine_id: PUB;3dc12565110f4e7cbb9e92dbb5be2bbb
- version: 2.0

## Description

Measuring up vol v down vol. Hoping this will be useful in sideways or drifting markets, hoping to spot insider or smarter money accumulation. Still very much "in beta."

## Source Code

````pine
//@version=6
// =============================================================================
// Accumulation Order-Flow (CVD) — TradingView companion to orderflow/
// =============================================================================
// Visualizes the two signals that proved useful on real data:
//   1. CVD (Cumulative Volume Delta) — rising CVD while price is flat is the
//      accumulation footprint: demand met by supply WITHOUT lifting price.
//   2. Absorption bars — high relative volume with a narrow body (a lot of
//      shares changed hands but price barely moved).
//
// HOW DELTA IS APPROXIMATED:
//   TradingView has no bid/ask in Pine, so we can't run the true Lee-Ready
//   classifier the Python tool uses. Instead we pull INTRABAR data from a lower
//   timeframe and classify each intrabar by close-vs-open (the tick-rule proxy),
//   then sum to a per-bar delta. This matches orderflow/analyze.py's BAR path,
//   not its tick path — directionally right, not exact.
//
// USE ON an hourly or daily chart (chart TF must be higher than the intrabar TF).
// Intrabar history/﻿count is limited by your TradingView plan.
// =============================================================================

indicator("Accumulation Order-Flow (CVD)", shorttitle="AccFlow", overlay=false)

// ----------------------------- Inputs ---------------------------------------
ltf        = input.timeframe("1",  "Intrabar timeframe for delta")
rvolLen    = input.int(20,         "Relative-volume lookback (bars)", minval=2)
rvolMin    = input.float(2.0,      "Absorption: min relative volume", step=0.1)
bodyMax    = input.float(0.35,     "Absorption: max body/range ratio", step=0.05)
anchorSess = input.bool(false,     "Reset CVD each session")
showHL     = input.bool(false,     "Highlight a date range")
hlStart    = input.time(timestamp("2026-05-01 00:00 GMT-4"), "  Highlight start")
hlEnd      = input.time(timestamp("2026-05-29 00:00 GMT-4"), "  Highlight end")

// --------------------- Lower-timeframe volume delta --------------------------
arrC = request.security_lower_tf(syminfo.tickerid, ltf, close)
arrO = request.security_lower_tf(syminfo.tickerid, ltf, open)
arrV = request.security_lower_tf(syminfo.tickerid, ltf, volume)

barDelta = 0.0
n = array.size(arrC)
if n > 0
    for i = 0 to n - 1
        c = array.get(arrC, i)
        o = array.get(arrO, i)
        v = array.get(arrV, i)
        dir = c > o ? 1.0 : c < o ? -1.0 : 0.0
        barDelta += dir * v
else
    // No intrabar data for this chart bar — fall back to the chart bar itself
    barDelta := (close > open ? 1.0 : close < open ? -1.0 : 0.0) * volume

// ------------------------------- CVD -----------------------------------------
var float cvd = 0.0
isNewDay = ta.change(time("D")) != 0
if anchorSess and isNewDay
    cvd := 0.0
cvd += barDelta

plot(cvd, "CVD (full history)", color = cvd >= 0 ? color.teal : color.red, linewidth=2)
hline(0, "Zero", color=color.gray, linestyle=hline.style_dotted)
plot(barDelta, "Bar delta", style=plot.style_columns,
     color = barDelta >= 0 ? color.new(color.green, 55) : color.new(color.red, 55))

// ----------------------- Windowed CVD (the "zoom") ---------------------------
// When a date range is highlighted, accumulate a SECOND CVD that resets to 0 at
// the window start and runs only inside it. Its value = net flow during just
// that consolidation — the Pine analog of orderflow analyze --start/--end. Read
// the orange line's level at the right edge of the band: up = net buying in the
// window, down = net selling.
inWindow = showHL and time >= hlStart and time <= hlEnd
var float winCVD = na
if inWindow
    winCVD := (na(winCVD[1]) ? 0.0 : winCVD[1]) + barDelta
else
    winCVD := na
plot(winCVD, "Window CVD", color=color.orange, linewidth=3)

// --------------------- Absorption bars (on price chart) ----------------------
rvol      = volume / ta.sma(volume, rvolLen)
rng       = high - low
bodyRatio = rng > 0 ? math.abs(close - open) / rng : na
absorption = rvol >= rvolMin and bodyRatio <= bodyMax

plotshape(absorption, "Absorption bar", style=shape.triangleup,
          location=location.belowbar, color=color.aqua, size=size.tiny,
          force_overlay=true)

// Faint band on BOTH the price pane (force_overlay) and this CVD pane so the
// window is visible wherever you're looking.
bgcolor(inWindow ? color.new(color.yellow, 80) : na, title="Date-range highlight")
bgcolor(inWindow ? color.new(color.yellow, 85) : na, title="Date-range highlight (price)", force_overlay=true)

alertcondition(absorption, "Absorption bar",
     "High-volume narrow-body bar — possible absorption/accumulation")
````
