# Triple Anchored VWAP [D/W/M]

- url: https://www.tradingview.com/script/TS3psnL2-Triple-Anchored-VWAP-D-W-M/
- type: indicator
- pine_id: PUB;b9ecc8b2e4ec4a6680e8205be72aee0f
- version: 3.0

## Description

Triple Anchored VWAP [D/W/M]

Institutional-grade volume-weighted average price analysis across three timeframes — all in one clean, customizable indicator.

This script plots three independently anchored VWAPs that reset at the start of each session, week, and month. Each VWAP acts as a dynamic fair-value level, showing where the average trader has been positioned over that period weighted by actual volume — making them far more meaningful than simple moving averages.

─── What's included ───

• Daily VWAP — resets every session, ideal for intraday and short-term traders
• Weekly VWAP — tracks fair value over the rolling week, great for swing setups
• Monthly VWAP — macro-level mean reversion and trend bias reference

Each VWAP includes:
→ 2 standard deviation bands (Band 1 and Band 2) with adjustable multipliers
→ Full color customization for the VWAP line and both deviation bands
→ Adjustable line width per timeframe
→ Toggle visibility of each VWAP and its bands independently
→ End-of-line labels (D-VWAP / W-VWAP / M-VWAP) so you always know what you're looking at
→ Source selection (HLC3, close, open, HL2, etc.)

─── Alerts ───

6 built-in alert conditions — price cross above and below each of the three VWAPs. Set them up in TradingView's Alerts menu and never miss a key level again.

─── How to use it ───

The deviation bands act as dynamic support and resistance. Price hugging the VWAP = balanced market. Price stretched toward Band 2 = extended, watch for reversion. A clean break and hold above the Weekly or Monthly VWAP often signals a shift in trend bias.

Works best on intraday charts (1m–4H) for the Daily VWAP, and daily/weekly charts for the Weekly and Monthly levels.

─── Settings ───

All three VWAPs are fully independent — toggle them on/off, adjust colors, band multipliers, line width, source, and labels separately. No clutter, just the levels you want.

Open-source and free for the community. Feedback and suggestions welcome.

## Source Code

````pine
//@version=6
indicator(title="Triple Anchored VWAP [D/W/M]", shorttitle="Triple AVWAP", overlay=true)
// v2 — label reprint fix + Pine v6 migration

// ─────────────────────────────────────────────
// DAILY VWAP SETTINGS
// ─────────────────────────────────────────────
grpD = "── Daily VWAP ──"
showD       = input.bool(true,              "Show Daily VWAP",          group=grpD)
srcD        = input.source(hlc3,            "Source",                   group=grpD)
colorD      = input.color(color.new(#2196F3, 0),  "Line Color",         group=grpD)
widthD      = input.int(2, "Line Width", minval=1, maxval=5,            group=grpD)
styleD_raw  = input.string("Solid", "Line Style", options=["Solid","Dashed","Dotted"], group=grpD)
showBandsD  = input.bool(true,              "Show Bands",               group=grpD)
band1MultD  = input.float(1.0, "Band 1 Multiplier", step=0.25,          group=grpD)
band2MultD  = input.float(2.0, "Band 2 Multiplier", step=0.25,          group=grpD)
bandColorD  = input.color(color.new(#2196F3, 0),  "Band Color",         group=grpD)
showLabelD  = input.bool(true,              "Show Label",               group=grpD)

// ─────────────────────────────────────────────
// WEEKLY VWAP SETTINGS
// ─────────────────────────────────────────────
grpW = "── Weekly VWAP ──"
showW       = input.bool(true,              "Show Weekly VWAP",         group=grpW)
srcW        = input.source(hlc3,            "Source",                   group=grpW)
colorW      = input.color(color.new(#FF9800, 0),  "Line Color",         group=grpW)
widthW      = input.int(2, "Line Width", minval=1, maxval=5,            group=grpW)
styleW_raw  = input.string("Solid", "Line Style", options=["Solid","Dashed","Dotted"], group=grpW)
showBandsW  = input.bool(true,              "Show Bands",               group=grpW)
band1MultW  = input.float(1.0, "Band 1 Multiplier", step=0.25,          group=grpW)
band2MultW  = input.float(2.0, "Band 2 Multiplier", step=0.25,          group=grpW)
bandColorW  = input.color(color.new(#FF9800, 0),  "Band Color",         group=grpW)
showLabelW  = input.bool(true,              "Show Label",               group=grpW)

// ─────────────────────────────────────────────
// MONTHLY VWAP SETTINGS
// ─────────────────────────────────────────────
grpM = "── Monthly VWAP ──"
showM       = input.bool(true,              "Show Monthly VWAP",        group=grpM)
srcM        = input.source(hlc3,            "Source",                   group=grpM)
colorM      = input.color(color.new(#E040FB, 0),  "Line Color",         group=grpM)
widthM      = input.int(2, "Line Width", minval=1, maxval=5,            group=grpM)
styleM_raw  = input.string("Solid", "Line Style", options=["Solid","Dashed","Dotted"], group=grpM)
showBandsM  = input.bool(true,              "Show Bands",               group=grpM)
band1MultM  = input.float(1.0, "Band 1 Multiplier", step=0.25,          group=grpM)
band2MultM  = input.float(2.0, "Band 2 Multiplier", step=0.25,          group=grpM)
bandColorM  = input.color(color.new(#E040FB, 0),  "Band Color",         group=grpM)
showLabelM  = input.bool(true,              "Show Label",               group=grpM)

// ─────────────────────────────────────────────
// HELPER: Line style resolver
// ─────────────────────────────────────────────
lineStyle(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

// ─────────────────────────────────────────────
// VWAP CALCULATION FUNCTION
// Returns [vwap, upper1, lower1, upper2, lower2]
// ─────────────────────────────────────────────
calcVWAP(src, isNewPeriod, mult1, mult2) =>
    var float cumVolPrice = 0.0
    var float cumVol      = 0.0
    var float cumVolPrice2 = 0.0

    if isNewPeriod
        cumVolPrice  := 0.0
        cumVol       := 0.0
        cumVolPrice2 := 0.0

    cumVolPrice  += src * volume
    cumVol       += volume
    cumVolPrice2 += src * src * volume

    vwapVal = cumVol != 0 ? cumVolPrice / cumVol : src
    variance = cumVol != 0 ? math.max(cumVolPrice2 / cumVol - vwapVal * vwapVal, 0.0) : 0.0
    stdev    = math.sqrt(variance)

    upper1 = vwapVal + mult1 * stdev
    lower1 = vwapVal - mult1 * stdev
    upper2 = vwapVal + mult2 * stdev
    lower2 = vwapVal - mult2 * stdev

    [vwapVal, upper1, lower1, upper2, lower2]

// ─────────────────────────────────────────────
// ANCHOR DETECTION
// ─────────────────────────────────────────────
isNewDay   = timeframe.change("D")
isNewWeek  = timeframe.change("W")
isNewMonth = timeframe.change("M")

// ─────────────────────────────────────────────
// CALCULATIONS
// ─────────────────────────────────────────────
[vwapD, dU1, dL1, dU2, dL2] = calcVWAP(srcD, isNewDay,   band1MultD, band2MultD)
[vwapW, wU1, wL1, wU2, wL2] = calcVWAP(srcW, isNewWeek,  band1MultW, band2MultW)
[vwapM, mU1, mL1, mU2, mL2] = calcVWAP(srcM, isNewMonth, band1MultM, band2MultM)

// ─────────────────────────────────────────────
// PLOTS — Daily
// ─────────────────────────────────────────────
pD    = plot(showD ? vwapD : na, "D-VWAP",    color=colorD, linewidth=widthD)
pDU1  = plot(showD and showBandsD ? dU1 : na, "D Band +1",  color=bandColorD, linewidth=1)
pDL1  = plot(showD and showBandsD ? dL1 : na, "D Band -1",  color=bandColorD, linewidth=1)
pDU2  = plot(showD and showBandsD ? dU2 : na, "D Band +2",  color=bandColorD, linewidth=1, style=plot.style_circles)
pDL2  = plot(showD and showBandsD ? dL2 : na, "D Band -2",  color=bandColorD, linewidth=1, style=plot.style_circles)

// ─────────────────────────────────────────────
// PLOTS — Weekly
// ─────────────────────────────────────────────
pW    = plot(showW ? vwapW : na, "W-VWAP",    color=colorW, linewidth=widthW)
pWU1  = plot(showW and showBandsW ? wU1 : na, "W Band +1",  color=bandColorW, linewidth=1)
pWL1  = plot(showW and showBandsW ? wL1 : na, "W Band -1",  color=bandColorW, linewidth=1)
pWU2  = plot(showW and showBandsW ? wU2 : na, "W Band +2",  color=bandColorW, linewidth=1, style=plot.style_circles)
pWL2  = plot(showW and showBandsW ? wL2 : na, "W Band -2",  color=bandColorW, linewidth=1, style=plot.style_circles)

// ─────────────────────────────────────────────
// PLOTS — Monthly
// ─────────────────────────────────────────────
pM    = plot(showM ? vwapM : na, "M-VWAP",    color=colorM, linewidth=widthM)
pMU1  = plot(showM and showBandsM ? mU1 : na, "M Band +1",  color=bandColorM, linewidth=1)
pML1  = plot(showM and showBandsM ? mL1 : na, "M Band -1",  color=bandColorM, linewidth=1)
pMU2  = plot(showM and showBandsM ? mU2 : na, "M Band +2",  color=bandColorM, linewidth=1, style=plot.style_circles)
pML2  = plot(showM and showBandsM ? mL2 : na, "M Band -2",  color=bandColorM, linewidth=1, style=plot.style_circles)

// ─────────────────────────────────────────────
// LABELS  (single persistent label per VWAP — no reprint)
// var keeps each handle alive across bars, so instead of
// spawning a fresh label every bar we reposition ONE label
// to the last bar. This kills the comet-trail.
// ─────────────────────────────────────────────
var label lblD = na
var label lblW = na
var label lblM = na

if barstate.islast
    // Daily
    if showD and showLabelD
        if na(lblD)
            lblD := label.new(bar_index, vwapD, "D-VWAP", color=color.new(colorD, 20), textcolor=color.white, style=label.style_label_left, size=size.small)
        else
            label.set_xy(lblD, bar_index, vwapD)
    else if not na(lblD)
        label.delete(lblD)
        lblD := na

    // Weekly
    if showW and showLabelW
        if na(lblW)
            lblW := label.new(bar_index, vwapW, "W-VWAP", color=color.new(colorW, 20), textcolor=color.white, style=label.style_label_left, size=size.small)
        else
            label.set_xy(lblW, bar_index, vwapW)
    else if not na(lblW)
        label.delete(lblW)
        lblW := na

    // Monthly
    if showM and showLabelM
        if na(lblM)
            lblM := label.new(bar_index, vwapM, "M-VWAP", color=color.new(colorM, 20), textcolor=color.white, style=label.style_label_left, size=size.small)
        else
            label.set_xy(lblM, bar_index, vwapM)
    else if not na(lblM)
        label.delete(lblM)
        lblM := na

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(ta.crossover(close, vwapD),  "Price crossed ABOVE D-VWAP", "Price crossed above Daily VWAP")
alertcondition(ta.crossunder(close, vwapD), "Price crossed BELOW D-VWAP", "Price crossed below Daily VWAP")
alertcondition(ta.crossover(close, vwapW),  "Price crossed ABOVE W-VWAP", "Price crossed above Weekly VWAP")
alertcondition(ta.crossunder(close, vwapW), "Price crossed BELOW W-VWAP", "Price crossed below Weekly VWAP")
alertcondition(ta.crossover(close, vwapM),  "Price crossed ABOVE M-VWAP", "Price crossed above Monthly VWAP")
alertcondition(ta.crossunder(close, vwapM), "Price crossed BELOW M-VWAP", "Price crossed below Monthly VWAP")
````
