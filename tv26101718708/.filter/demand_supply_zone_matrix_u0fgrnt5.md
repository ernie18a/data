# Demand Supply Zone Matrix

- url: https://www.tradingview.com/script/u0FgrNt5/
- type: indicator
- pine_id: PUB;1ee9a10abec74805a5ff464c3a8f1db7
- version: 4.0

## Description

[b]Demand Supply Zone Matrix by DayTradeSetup [/b]
[b]Demand Supply Zone Matrix[/b] is an automatic Demand & Supply Zone indicator designed to help traders identify important price areas more clearly without manually drawing every zone.

The system detects potential Supply and Demand zones based on market momentum, volume activity, and the strength of price movement. It also includes zone grading, touch tracking, mitigation reference levels, alerts, and a dashboard summary to help traders filter key zones more efficiently.

[b]Key Features[/b]

• Automatic Demand & Supply Zones
Automatically detects potential Supply and Demand zones based on strong directional price movement.

• Strength Grade / Score
Each zone is graded with an A / B / C score to help traders evaluate the quality and strength of each zone more easily.

• 50% Mitigation Line
Displays the midpoint of each zone, which can be used as a reference area for mitigation, retest, or reaction analysis.

• Touch Counter
Tracks how many times price has returned to test a zone, helping traders identify whether a zone is still fresh or has already been tested.

• Zone Retest Alert
Sends an alert when price comes back to test an active Supply or Demand zone.

• Zone Break Alert
Sends an alert when a zone is invalidated or broken by price action.

• Dashboard Summary
Includes a dashboard showing Supply/Demand zone count, best grade, total volume, and overall market bias.

[b]How to Use[/b]
This indicator is designed to be used as a technical analysis tool for identifying areas where buying or selling pressure may appear.

Suggested workflow:

1. Check whether Supply or Demand is currently dominant.
2. Focus on higher-grade zones such as A or B.
3. Wait for price to return and test the zone.
4. Use additional confirmation such as Price Action, Market Structure, Trend Direction, or Risk Management before entering a trade.

Suitable For

This indicator is suitable for traders who use concepts such as:

[list]
[*]Demand & Supply
[*]Smart Money Concepts
[*]Price Action
[*]Retest Zones
[*]Momentum Trading
[*]Intraday Trading
[/list]

It can be applied to multiple markets, including XAUUSD, Forex, Crypto, Indices, and different timeframes depending on the trader’s strategy.

[b]Disclaimer[/b]
This indicator is a technical analysis tool only. It is not a direct Buy/Sell signal and does not guarantee trading results. Traders should always combine it with their own trading plan, risk management, and additional confirmation before making any trading decisions.

[b]Risk Warning: [/b]Trading involves risk. Please study and understand the risks carefully before making any investment or trading decision.

## Source Code

````pine
//@version=6
// Copyright © 2026 Day Trade Setup (DTS). All Rights Reserved.
// DTS - DM Zone Matrix
//
// This script is proprietary software developed by Day Trade Setup.
// The codebase and implementation were independently written by Day Trade Setup.
//
// General supply and demand zone concepts are widely used in technical analysis.
// This script does not claim ownership over general trading concepts or market theories.
//
// Unauthorized copying, redistribution, resale, modification, republishing,
// or commercial use of this script without written permission is strictly prohibited.
//
// This indicator is provided for educational and technical analysis purposes only.
// It does not constitute financial advice or guarantee any trading results.
// Trading involves risk. Users are responsible for their own trading decisions.

indicator("Day Trade Setup - Demand Supply Zone Matrix", overlay=true, max_boxes_count=40, max_labels_count=40, max_lines_count=40)

// ─── Inputs ───────────────────────────────────────────────────────────────────
showSupply = input.bool(true, "Supply Zones", group="Display")
showDemand = input.bool(true, "Demand Zones", group="Display")
showMid    = input.bool(true, "50% Mitigation Line", group="Display")
showScore  = input.bool(true, "Show Strength Grade/Score", group="Display")
maxKeep    = input.int(5,  "Keep Latest Zones / Type", group="Display", minval=1, maxval=10)

runBars    = input.int(3,    "Momentum Bars", group="Filters", minval=2, maxval=6,
              tooltip="Require N consecutive one-way candles to count as a meaningful move")
lookBase   = input.int(5,    "Base Lookback (bars)", group="Filters", minval=2, maxval=12)
heightMult = input.float(2.0,"Zone Height x ATR",    group="Filters", minval=0.5, maxval=5.0, step=0.1)
atrLook    = input.int(200,  "ATR Period",           group="Filters", minval=10, maxval=300)
guardBars  = input.int(15,   "Cooldown (bars)",      group="Filters", minval=1, maxval=100)
volLen     = input.int(20,   "Vol MA Period",        group="Filters", minval=5)

colSup = input.color(color.rgb(255, 0, 0), "Supply", group="Colors")
colDem = input.color(color.rgb(0, 187, 255), "Demand", group="Colors")

// ─── Basics ───────────────────────────────────────────────────────────────────
atrRaw = ta.atr(atrLook)
band   = atrRaw * heightMult
avgVol = ta.sma(volume, volLen)
hotVol = volume[1] > avgVol[1]

// Non-repaint: only act on confirmed (closed) bars
confirmed = barstate.isconfirmed

upBar(i)   => close[i] > open[i]
downBar(i) => close[i] < open[i]

runDown() =>
    r = true
    for i = 0 to runBars - 1
        if not downBar(i)
            r := false
            break
    r
runUp() =>
    r = true
    for i = 0 to runBars - 1
        if not upBar(i)
            r := false
            break
    r

// Sum of momentum-bar bodies (measures the strength of the departure)
runBody() =>
    s = 0.0
    for i = 0 to runBars - 1
        s += math.abs(close[i] - open[i])
    s

fmtVol(v) =>
    v >= 1e9 ? str.tostring(math.round(v/1e9, 2)) + "B"
     : v >= 1e6 ? str.tostring(math.round(v/1e6, 2)) + "M"
     : v >= 1e3 ? str.tostring(math.round(v/1e3, 2)) + "K"
     : str.tostring(math.round(v, 0))

gradeOf(s) =>
    s >= 75 ? "A" : s >= 50 ? "B" : "C"

// Base score 0-80: Volume (max 50) + impulse strength (max 30)
baseScore(flow, body) =>
    vf  = avgVol > 0 ? math.abs(flow) / (avgVol * runBars) : 0.0
    imp = atrRaw > 0 ? body / atrRaw : 0.0
    math.min(vf, 2) / 2 * 50 + math.min(imp, 2) / 2 * 30

// ─── Zone type (UDT) ──────────────────────────────────────────────────────────
type Zone
    box   bx
    label lb
    line  ml
    float flow
    float base
    int   touch
    bool  inside

// Display score = base + freshness bonus (untested = strongest)
dispScore(z) =>
    fresh = z.touch == 0 ? 20.0 : z.touch == 1 ? 10.0 : 0.0
    math.min(z.base + fresh, 100)

zoneLabel(name, z) =>
    s = name
    if showScore
        s += "  [" + gradeOf(dispScore(z)) + " " + str.tostring(math.round(dispScore(z))) + "]"
    s += "  " + fmtVol(math.abs(z.flow)) + "  T" + str.tostring(z.touch)
    s

// ─── State ────────────────────────────────────────────────────────────────────
var array<Zone> sup = array.new<Zone>()
var array<Zone> dem = array.new<Zone>()
var int sLock = 0
var int dLock = 0

// Cooldown counts down once per confirmed bar (avoids intrabar drift)
if confirmed and sLock > 0
    sLock -= 1
if confirmed and dLock > 0
    dLock -= 1

// Alert flags (reset each bar)
supNew    = false
demNew    = false
supRetest = false
demRetest = false
supBreak  = false
demBreak  = false

// Check if a new zone overlaps an existing one
overlap(arr, top, bot) =>
    hit = false
    if array.size(arr) > 0
        for z in arr
            if top >= box.get_bottom(z.bx) and bot <= box.get_top(z.bx)
                hit := true
                break
    hit

// ─── Create Supply: after a down-run, anchor zone at the base (last up candle) ─
// Non-repaint: creation only fires on a confirmed bar
if confirmed and showSupply and runDown() and hotVol and sLock == 0
    flow   = 0.0
    placed = false
    j      = 0
    while j <= lookBase and not placed
        if upBar(j)
            top = low[j] + band
            bot = low[j]
            if not overlap(sup, top, bot)
                mid = (top + bot) / 2
                nb = box.new(bar_index - j, top, bar_index, bot,
                     bgcolor=color.new(colSup, 90), border_color=colSup,
                     border_width=2, border_style=line.style_solid)
                nl = label.new(bar_index + 1, mid, "Supply",
                     style=label.style_label_left, color=color.new(color.black, 100),
                     textcolor=colSup, size=size.normal)
                nm = showMid ? line.new(bar_index - j, mid, bar_index, mid,
                     color=color.new(colSup, 35), style=line.style_dotted, width=1) : na
                array.push(sup, Zone.new(nb, nl, nm, flow, baseScore(flow, runBody()), 0, false))
                sLock  := guardBars
                supNew := true
            placed := true
        else
            flow += downBar(j) ? -volume[j] : volume[j]
            j += 1

// ─── Create Demand: after an up-run, anchor zone at the base (last down candle) ─
if confirmed and showDemand and runUp() and hotVol and dLock == 0
    flow   = 0.0
    placed = false
    j      = 0
    while j <= lookBase and not placed
        if downBar(j)
            top = high[j]
            bot = high[j] - band
            if not overlap(dem, top, bot)
                mid = (top + bot) / 2
                nb = box.new(bar_index - j, top, bar_index, bot,
                     bgcolor=color.new(colDem, 90), border_color=colDem,
                     border_width=2, border_style=line.style_solid)
                nl = label.new(bar_index + 1, mid, "Demand",
                     style=label.style_label_left, color=color.new(color.black, 100),
                     textcolor=colDem, size=size.normal)
                nm = showMid ? line.new(bar_index - j, mid, bar_index, mid,
                     color=color.new(colDem, 35), style=line.style_dotted, width=1) : na
                array.push(dem, Zone.new(nb, nl, nm, flow, baseScore(flow, runBody()), 0, false))
                dLock  := guardBars
                demNew := true
            placed := true
        else
            flow += upBar(j) ? volume[j] : -volume[j]
            j += 1

// ─── Manage Supply Zones ──────────────────────────────────────────────────────
// Visual (extend right) updates every tick; break/touch only on confirmed bars
if array.size(sup) > 0
    for i = array.size(sup) - 1 to 0
        z   = array.get(sup, i)
        top = box.get_top(z.bx)
        bot = box.get_bottom(z.bx)

        if confirmed and close > top  // close above zone = invalidated
            box.delete(z.bx)
            label.delete(z.lb)
            if not na(z.ml)
                line.delete(z.ml)
            array.remove(sup, i)
            supBreak := true
        else
            box.set_right(z.bx, bar_index)
            label.set_x(z.lb, bar_index + 1)
            if not na(z.ml)
                line.set_x2(z.ml, bar_index)
            // Touch: price overlaps zone + some bars passed → count + dashed border
            if confirmed
                touching = high >= bot and low <= top
                if touching and not z.inside and (bar_index - box.get_left(z.bx)) > runBars
                    z.touch  += 1
                    z.inside := true
                    supRetest := true
                    box.set_border_style(z.bx, line.style_dashed)
                    box.set_border_width(z.bx, 1)
                if not touching
                    z.inside := false
            label.set_text(z.lb, zoneLabel("Supply", z))

// ─── Manage Demand Zones ──────────────────────────────────────────────────────
if array.size(dem) > 0
    for i = array.size(dem) - 1 to 0
        z   = array.get(dem, i)
        top = box.get_top(z.bx)
        bot = box.get_bottom(z.bx)

        if confirmed and close < bot  // close below zone = invalidated
            box.delete(z.bx)
            label.delete(z.lb)
            if not na(z.ml)
                line.delete(z.ml)
            array.remove(dem, i)
            demBreak := true
        else
            box.set_right(z.bx, bar_index)
            label.set_x(z.lb, bar_index + 1)
            if not na(z.ml)
                line.set_x2(z.ml, bar_index)
            if confirmed
                touching = high >= bot and low <= top
                if touching and not z.inside and (bar_index - box.get_left(z.bx)) > runBars
                    z.touch  += 1
                    z.inside := true
                    demRetest := true
                    box.set_border_style(z.bx, line.style_dashed)
                    box.set_border_width(z.bx, 1)
                if not touching
                    z.inside := false
            label.set_text(z.lb, zoneLabel("Demand", z))

// ─── FIFO: keep only the latest zones per maxKeep ─────────────────────────────
while array.size(sup) > maxKeep
    old = array.shift(sup)
    box.delete(old.bx)
    label.delete(old.lb)
    if not na(old.ml)
        line.delete(old.ml)

while array.size(dem) > maxKeep
    old = array.shift(dem)
    box.delete(old.bx)
    label.delete(old.lb)
    if not na(old.ml)
        line.delete(old.ml)

// ─── Alerts ───────────────────────────────────────────────────────────────────
alertcondition(supNew,                 "New Supply",   "New Supply zone formed")
alertcondition(demNew,                 "New Demand",   "New Demand zone formed")
alertcondition(supRetest or demRetest, "Zone Retest",  "Price is testing a zone")
alertcondition(supBreak or demBreak,   "Zone Break",   "A zone was invalidated")

// ─── Dashboard ────────────────────────────────────────────────────────────────
showDash = input.bool(true, "Show Dashboard", group="Dashboard")
dashPosI = input.string("Top Right", "Position", group="Dashboard",
            options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"])
dashSzI  = input.string("Small", "Text Size", group="Dashboard",
            options=["Small","Normal","Large"])

dashPos = dashPosI == "Top Left"     ? position.top_left     :
          dashPosI == "Bottom Right" ? position.bottom_right :
          dashPosI == "Bottom Left"  ? position.bottom_left  :
          dashPosI == "Middle Right" ? position.middle_right :
          position.top_right
dashSz  = dashSzI == "Small" ? size.small :
          dashSzI == "Large" ? size.large :
          size.normal

var table dash = table.new(dashPos, 3, 6, border_width=1, border_color=color.new(color.gray, 70))

if showDash and barstate.islast
    sCount = array.size(sup)
    dCount = array.size(dem)
    sVol  = 0.0
    sBest = 0.0
    for z in sup
        sVol  += math.abs(z.flow)
        sBest := math.max(sBest, dispScore(z))
    dVol  = 0.0
    dBest = 0.0
    for z in dem
        dVol  += math.abs(z.flow)
        dBest := math.max(dBest, dispScore(z))

    // Bias: which side has the dominant volume
    isBear   = sVol > dVol * 1.15
    isBull   = dVol > sVol * 1.15
    bias     = isBear ? "Bearish" : isBull ? "Bullish" : "Neutral"
    biasTxt  = isBear ? #FF8A80 : isBull ? #B9F6CA : color.silver       // light red / light green
    biasBg   = isBear ? color.new(#D50000, 55) : isBull ? color.new(#00C853, 55) : color.new(color.gray, 55)

    bg  = color.new(#0c0e16, 10)
    hdr = color.new(#787d86, 20)
    hd  = color.new(#b300ff, 20)

    // Header (merged across 3 cols)
    table.cell(dash, 0, 0, "DTS - DM Zone Matrix", text_color=color.white, bgcolor=hd, text_size=dashSz)
    table.merge_cells(dash, 0, 0, 2, 0)

    // Column headers
    table.cell(dash, 0, 1, "",       bgcolor=bg, text_size=dashSz)
    table.cell(dash, 1, 1, "Supply", text_color=colSup, bgcolor=bg, text_size=dashSz)
    table.cell(dash, 2, 1, "Demand", text_color=colDem, bgcolor=bg, text_size=dashSz)

    // Zone count
    table.cell(dash, 0, 2, "Zones",              text_color=color.silver, bgcolor=bg, text_size=dashSz)
    table.cell(dash, 1, 2, str.tostring(sCount), text_color=color.white,  bgcolor=bg, text_size=dashSz)
    table.cell(dash, 2, 2, str.tostring(dCount), text_color=color.white,  bgcolor=bg, text_size=dashSz)

    // Best grade
    table.cell(dash, 0, 3, "Best Grade",                     bgcolor=bg, text_color=color.silver, text_size=dashSz)
    table.cell(dash, 1, 3, sCount > 0 ? gradeOf(sBest) : "-", bgcolor=bg, text_color=colSup,       text_size=dashSz)
    table.cell(dash, 2, 3, dCount > 0 ? gradeOf(dBest) : "-", bgcolor=bg, text_color=colDem,       text_size=dashSz)

    // Total volume
    table.cell(dash, 0, 4, "Volume",                        bgcolor=bg, text_color=color.silver, text_size=dashSz)
    table.cell(dash, 1, 4, sCount > 0 ? fmtVol(sVol) : "-", bgcolor=bg, text_color=color.white,  text_size=dashSz)
    table.cell(dash, 2, 4, dCount > 0 ? fmtVol(dVol) : "-", bgcolor=bg, text_color=color.white,  text_size=dashSz)

    // Bias (merged across 3 cols)
    table.cell(dash, 0, 5, bias, text_color=biasTxt, bgcolor=biasBg, text_size=dashSz)
    table.merge_cells(dash, 0, 5, 2, 5)
````
