# Multi-Anchor VWAP

- url: https://www.tradingview.com/script/8iHpFY5L/
- type: indicator
- pine_id: PUB;a536cdcfb21d46b0bdadba1b10fae668
- version: 1.0

## Description

This indicator plots daily, weekly and monthly anchored VWAPs on one chart, with optional standard-deviation bands around the daily anchor.

How it works

Each VWAP accumulates volume-weighted typical price (HLC3) from its anchor point — the start of the day, week or month — and resets when a new period begins. The deviation bands are computed from the volume-weighted variance of price around the daily VWAP, so they widen naturally on volatile days. Each anchor can be toggled independently, and alert conditions fire when price crosses the daily or weekly VWAP.

Notes and limitations

VWAP is meaningful on intraday charts for the daily anchor; on higher timeframes the daily line follows each bar closely. As with all volume-derived tools, data quality depends on the market — forex volume is tick-based. A VWAP is a description of average transacted price, not a prediction of where price will go.

## Source Code

````pine
//@version=6
// ============================================================
//  Multi-Anchor VWAP
//  Daily, weekly and monthly session-anchored VWAPs with
//  optional standard-deviation bands on the daily anchor.
// ============================================================
indicator("Multi-Anchor VWAP", overlay = true)

// ---------- Inputs ----------
grpA = "Anchors"
showD = input.bool(true,  "Daily VWAP",   group = grpA)
showW = input.bool(true,  "Weekly VWAP",  group = grpA)
showM = input.bool(false, "Monthly VWAP", group = grpA)

grpB = "Deviation bands (daily anchor)"
showB1 = input.bool(true,  "±1σ bands", group = grpB)
showB2 = input.bool(false, "±2σ bands", group = grpB)

grpC = "Colors"
colD = input.color(color.new(#2962ff, 0),  "Daily",   group = grpC)
colW = input.color(color.new(#ff9800, 0),  "Weekly",  group = grpC)
colM = input.color(color.new(#ab47bc, 0),  "Monthly", group = grpC)

src = hlc3

// ---------- VWAP engine ----------
// Returns [vwap, stdev] anchored to `reset`
f_vwap(bool reset) =>
    var float cumPV  = na
    var float cumPV2 = na
    var float cumV   = na
    if reset or na(cumV)
        cumPV  := src * volume
        cumPV2 := src * src * volume
        cumV   := volume
    else
        cumPV  += src * volume
        cumPV2 += src * src * volume
        cumV   += volume
    vw = cumV > 0 ? cumPV / cumV : na
    variance = cumV > 0 ? math.max(cumPV2 / cumV - vw * vw, 0.0) : na
    [vw, math.sqrt(variance)]

[vwD, sdD] = f_vwap(timeframe.change("D"))
[vwW, _w]  = f_vwap(timeframe.change("W"))
[vwM, _m]  = f_vwap(timeframe.change("M"))

// ---------- Plots ----------
plot(showD ? vwD : na, "Daily VWAP",   colD, 2, plot.style_linebr)
plot(showW ? vwW : na, "Weekly VWAP",  colW, 2, plot.style_linebr)
plot(showM ? vwM : na, "Monthly VWAP", colM, 2, plot.style_linebr)

u1 = plot(showD and showB1 ? vwD + sdD : na,     "+1σ", color.new(colD, 55), 1, plot.style_linebr)
l1 = plot(showD and showB1 ? vwD - sdD : na,     "-1σ", color.new(colD, 55), 1, plot.style_linebr)
u2 = plot(showD and showB2 ? vwD + 2 * sdD : na, "+2σ", color.new(colD, 70), 1, plot.style_linebr)
l2 = plot(showD and showB2 ? vwD - 2 * sdD : na, "-2σ", color.new(colD, 70), 1, plot.style_linebr)
fill(u1, l1, color.new(colD, 94), "±1σ fill")

// ---------- Alerts ----------
alertcondition(ta.cross(close, vwD), "Price crossed daily VWAP",  "Multi-Anchor VWAP: price crossed the daily VWAP")
alertcondition(ta.cross(close, vwW), "Price crossed weekly VWAP", "Multi-Anchor VWAP: price crossed the weekly VWAP")
````
