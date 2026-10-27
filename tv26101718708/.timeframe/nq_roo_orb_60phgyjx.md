# NQ ROO ORB

- url: https://www.tradingview.com/script/60pHgyJx-NQ-ROO-ORB/
- type: indicator
- pine_id: PUB;f4324a4ab23d474bad7d135d67b7f80b
- version: 1.0

## Description

The ORB (Opening Range Breakout) indicator on NQ identifies the high and low of the market's opening range and plots these levels as key support and resistance zones for the trading session. Traders use breaks above the opening range high or below the opening range low to identify potential breakout opportunities, often confirming entries with volume and price action.

## Source Code

````pine
//@version=6
// =============================================================================
//  NQ ORB Prop Clean
//  -------------------------------------------------------------------------
//  A stripped-down Opening Range Breakout tool built for prop-firm rules where
//  you cannot sit through deep intraday pullbacks. It takes the break DIRECTLY
//  (no retests, no multi-targets, no extra noise), aims for a fixed 10-20 point
//  move, uses a tight stop for a strong reward-to-risk ratio, and only fires
//  when there is CLEAR ROOM to the target (no prior support/resistance in the
//  way).
//
//  No repaint: breakouts are evaluated on the bar CLOSE; swing S/R levels are
//  confirmed pivots; prior-day levels reference the completed daily bar.
// =============================================================================

indicator("NQ ORB Prop Clean", "NQ ORB Prop", overlay = true, max_lines_count = 500, max_labels_count = 500)

// =============================================================================
//  INPUTS
// =============================================================================
g1 = "Opening Range"
orTypeInput = input.string("15 min", "OR Duration", options = ["5 min", "15 min", "30 min"], group = g1, tooltip = "Range built from the 09:30 ET open.")

g2 = "Target / Risk"
targetPts = input.float(15.0, "Target (points)", minval = 1.0, step = 1.0, group = g2, tooltip = "Fixed profit target in index points. For NQ aim 10-20.")
stopMode  = input.string("Fixed Points", "Stop Type", options = ["Fixed Points", "ATR"], group = g2)
stopPts   = input.float(7.0, "Stop (points)", minval = 0.25, step = 0.25, group = g2, tooltip = "Used when Stop Type = Fixed Points.")
atrLen    = input.int(14, "ATR Length", minval = 1, group = g2)
atrMult   = input.float(1.0, "ATR Stop Mult", minval = 0.1, step = 0.1, group = g2, tooltip = "Used when Stop Type = ATR.")

g3 = "Quality Filters"
useBody = input.bool(true, "Require Strong Body", group = g3)
minBody = input.float(0.50, "Min Body %", minval = 0.0, maxval = 1.0, step = 0.05, group = g3)
useVol  = input.bool(true, "Require Volume > Avg", group = g3)
volLen  = input.int(20, "Volume MA Length", minval = 1, group = g3)

g4 = "Support / Resistance"
useSR     = input.bool(true, "Require Clear Room to Target", group = g4, tooltip = "Block the trade if a prior S/R level sits between entry and the target.")
pivotLen  = input.int(10, "Swing Strength", minval = 2, group = g4, tooltip = "Bars on each side that define a swing high/low.")
showSR    = input.bool(true, "Show Prior Day High/Low", group = g4)

g5 = "Session"
tz      = "America/New_York"
useSess = input.bool(true, "Signals only 09:30-11:30 ET", group = g5)

g6 = "Visuals"
showDash = input.bool(true, "Show Info Table", group = g6)

// OR selection -> minutes -> session end string.
orMinutes = orTypeInput == "5 min" ? 5 : orTypeInput == "30 min" ? 30 : 15
orEndStr  = orMinutes == 5 ? "0935" : orMinutes == 30 ? "1000" : "0945"
orSession = "0930-" + orEndStr

// =============================================================================
//  SESSION / OPENING RANGE
// =============================================================================
inRTH    = not na(time(timeframe.period, "0930-1600", tz))
inOR     = not na(time(timeframe.period, orSession, tz))
inSignal = not na(time(timeframe.period, "0930-1130", tz))
newDay   = inRTH and not inRTH[1]
canSig   = inRTH and (not useSess or inSignal)

var float orHigh   = na
var float orLow    = na
var bool  orLocked = false

firstORbar = inOR and not inOR[1]
if firstORbar
    orHigh   := high
    orLow    := low
    orLocked := false
else if inOR
    orHigh := math.max(orHigh, high)
    orLow  := math.min(orLow, low)

if inRTH and not inOR and not na(orHigh)
    orLocked := true

if newDay and not inOR
    orHigh   := na
    orLow    := na
    orLocked := false

// =============================================================================
//  INDICATORS + PRIOR-DAY LEVELS
// =============================================================================
atr   = ta.atr(atrLen)
volMA = ta.sma(volume, volLen)

// Previous day high / low / close (completed daily bar -> non-repainting).
pdh = request.security(syminfo.tickerid, "D", high[1],  lookahead = barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1],   lookahead = barmerge.lookahead_on)
pdc = request.security(syminfo.tickerid, "D", close[1], lookahead = barmerge.lookahead_on)

// Confirmed swing pivots collected into rolling arrays (recent S/R memory).
var array<float> hiPv = array.new<float>()
var array<float> loPv = array.new<float>()
ph = ta.pivothigh(pivotLen, pivotLen)
pl = ta.pivotlow(pivotLen, pivotLen)
if not na(ph)
    array.push(hiPv, ph)
    if array.size(hiPv) > 30
        array.shift(hiPv)
if not na(pl)
    array.push(loPv, pl)
    if array.size(loPv) > 30
        array.shift(loPv)

// Nearest resistance above / support below a given price.
f_resAbove(price, arr, a, b) =>
    float r = na
    if not na(a) and a > price
        r := na(r) ? a : math.min(r, a)
    if not na(b) and b > price
        r := na(r) ? b : math.min(r, b)
    sz = array.size(arr)
    if sz > 0
        for i = 0 to sz - 1
            v = array.get(arr, i)
            if v > price
                r := na(r) ? v : math.min(r, v)
    r

f_supBelow(price, arr, a, b) =>
    float s = na
    if not na(a) and a < price
        s := na(s) ? a : math.max(s, a)
    if not na(b) and b < price
        s := na(s) ? b : math.max(s, b)
    sz = array.size(arr)
    if sz > 0
        for i = 0 to sz - 1
            v = array.get(arr, i)
            if v < price
                s := na(s) ? v : math.max(s, v)
    s

resAbove = f_resAbove(close, hiPv, pdh, pdc)
supBelow = f_supBelow(close, loPv, pdl, pdc)

// Clear-room check: is the target reachable before hitting a prior level?
roomLong  = not useSR or na(resAbove) or (resAbove - close) >= targetPts
roomShort = not useSR or na(supBelow) or (close - supBelow) >= targetPts

// =============================================================================
//  CANDLE QUALITY
// =============================================================================
body    = math.abs(close - open)
rng     = high - low
bodyPct = rng > 0 ? body / rng : 0.0
bodyOK  = not useBody or bodyPct >= minBody
volOK   = not useVol or volume > volMA

// =============================================================================
//  BREAKOUT SIGNALS (direct, one per side until price re-enters the range)
// =============================================================================
var bool longDone  = false
var bool shortDone = false

if orLocked and not na(orHigh) and not na(orLow)
    if close < orHigh
        longDone := false
    if close > orLow
        shortDone := false
if newDay
    longDone  := false
    shortDone := false

longSig  = orLocked and not na(orHigh) and canSig and not longDone  and close > orHigh and math.min(open, close) > orHigh and bodyOK and volOK and roomLong
shortSig = orLocked and not na(orLow)  and canSig and not shortDone and close < orLow  and math.max(open, close) < orLow  and bodyOK and volOK and roomShort

if longSig
    longDone := true
if shortSig
    shortDone := true

// =============================================================================
//  TRADE LEVELS
// =============================================================================
stopDist = stopMode == "ATR" ? atrMult * atr : stopPts

var float entryPrice = na
var float stopPrice  = na
var float tgtPrice   = na
var int   dir        = 0
var float rr         = na

if newDay
    entryPrice := na
    stopPrice  := na
    tgtPrice   := na
    dir        := 0
    rr         := na

if longSig
    entryPrice := close
    stopPrice  := close - stopDist
    tgtPrice   := close + targetPts
    dir        := 1
    rr         := stopDist > 0 ? targetPts / stopDist : na
else if shortSig
    entryPrice := close
    stopPrice  := close + stopDist
    tgtPrice   := close - targetPts
    dir        := -1
    rr         := stopDist > 0 ? targetPts / stopDist : na

active = dir != 0

// =============================================================================
//  PLOTS
// =============================================================================
plotOR = orLocked and inRTH
plot(plotOR ? orHigh : na, "OR High", color = color.new(color.green, 0), linewidth = 2, style = plot.style_linebr)
plot(plotOR ? orLow  : na, "OR Low",  color = color.new(color.red, 0),   linewidth = 2, style = plot.style_linebr)

// Prior-day support / resistance (faint reference lines).
plot(showSR ? pdh : na, "Prev Day High", color = color.new(color.gray, 40), linewidth = 1, style = plot.style_circles)
plot(showSR ? pdl : na, "Prev Day Low",  color = color.new(color.gray, 40), linewidth = 1, style = plot.style_circles)

// Active-trade stop (dotted) and single target line.
plot(active ? stopPrice : na, "Stop",   color = color.new(color.maroon, 0), linewidth = 1, style = plot.style_circles)
plot(active ? tgtPrice  : na, "Target", color = color.new(color.teal, 0),   linewidth = 2, style = plot.style_linebr)

// Entry arrows.
plotshape(longSig,  title = "Long Entry",  style = shape.triangleup,   location = location.belowbar, color = color.new(color.green, 0), textcolor = color.white, size = size.normal, text = "LONG")
plotshape(shortSig, title = "Short Entry", style = shape.triangledown, location = location.abovebar, color = color.new(color.red, 0),   textcolor = color.white, size = size.normal, text = "SHORT")

// =============================================================================
//  ALERTS
// =============================================================================
alertcondition(longSig,  title = "Long Entry",  message = "NQ ORB Prop: LONG break with clear room to target")
alertcondition(shortSig, title = "Short Entry", message = "NQ ORB Prop: SHORT break with clear room to target")

// =============================================================================
//  INFO TABLE
// =============================================================================
roomTxt = dir == 1 ? (na(resAbove) ? "Open sky" : str.tostring(resAbove - entryPrice, "#.#") + " pts") : dir == -1 ? (na(supBelow) ? "Open sky" : str.tostring(entryPrice - supBelow, "#.#") + " pts") : "-"
dirTxt  = dir == 1 ? "LONG" : dir == -1 ? "SHORT" : "Flat"
dirCol  = dir == 1 ? color.green : dir == -1 ? color.red : color.gray

var table dash = na
if showDash
    if na(dash)
        dash := table.new(position.top_right, 2, 6, border_width = 1)
    if barstate.islast
        table.cell(dash, 0, 0, "Signal",   text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = size.small)
        table.cell(dash, 1, 0, dirTxt,     text_color = color.white, bgcolor = color.new(dirCol, 20),     text_size = size.small)
        table.cell(dash, 0, 1, "Entry",    text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
        table.cell(dash, 1, 1, na(entryPrice) ? "-" : str.tostring(entryPrice, format.mintick), text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
        table.cell(dash, 0, 2, "Stop",     text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
        table.cell(dash, 1, 2, na(stopPrice) ? "-" : str.tostring(stopPrice, format.mintick), text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
        table.cell(dash, 0, 3, "Target",   text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
        table.cell(dash, 1, 3, na(tgtPrice) ? "-" : str.tostring(tgtPrice, format.mintick), text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
        table.cell(dash, 0, 4, "R : R",    text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
        table.cell(dash, 1, 4, na(rr) ? "-" : str.tostring(rr, "#.##") + " : 1", text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
        table.cell(dash, 0, 5, "Room",     text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
        table.cell(dash, 1, 5, roomTxt,    text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
````
