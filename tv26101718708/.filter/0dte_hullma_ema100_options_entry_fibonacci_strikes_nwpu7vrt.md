# 0DTE HullMA + EMA100  Options Entry & Fibonacci Strikes

- url: https://www.tradingview.com/script/NWPU7VrT-0DTE-HullMA-EMA100-Options-Entry-Fibonacci-Strikes/
- type: indicator
- pine_id: PUB;6c78309a979e4895b0d64bc8b847aa3c
- version: 2.0

## Description

This is an indicator built for trading options on the 5-minute timeframe, designed for same-day expiration (0DTE) CALL and PUT buying. The thesis is the following:

[list]
[*]The EMA 100 defines the bias. If price is below the EMA 100, we only trade PUTs. If price is above the EMA 100, we only trade CALLs. We never fight the macro trend — the EMA 100 decides which direction is allowed, and nothing else.
[*]The HullMA (50) is the trigger. For a PUT, the signal fires when the HullMA flips from green to red while price is below the EMA 100. If the HullMA flips first but price hasn't crossed below the EMA 100 yet, the indicator waits a configurable number of candles (default 4) for that confirmation — if it never happens, the setup is discarded. For a CALL, it's the mirror: the HullMA flips from red to green while price sits above the EMA 100.
[/list]

The strike levels come from configurable Fibonacci targets. When a signal fires, the indicator measures the most recent swing (recent pivots, or the previous day's range — your choice) and projects three arrival levels: 0.382, 0.5 and 0.618 (all adjustable). These are your candidate strikes — the prices the underlying is likely to reach within the session. For a PUT, all three land below the entry price; for a CALL, above it.
Everything is captured in a "Last Signal" table that freezes at the moment of each trigger, showing the direction, entry price, how many candles ago it fired, the live price, and the three Fibonacci strikes — so you can pick a realistic strike and track progress toward it without cluttering the chart.

The strategy works on stocks, ETFs and crypto, and every visual element can be toggled on or off in the settings.

[i]This tool is for technical analysis only and is not financial advice. 0DTE options carry a high risk of total loss.[/i]

## Source Code

````pine
//@version=6
// © HassanAR700326
// ============================================================================
//  0DTE CALL/PUT — HullMA(50) + EMA(100) + Fibonacci Targets · 5m
//  Author:  Hassan Arteaga Rodriguez  (@HassanAR700326)
//  License: Mozilla Public License 2.0 — https://mozilla.org/MPL/2.0/
// ----------------------------------------------------------------------------
//  PUT : HullMA turns green->red AND price below EMA100 (waits up to N bars)
//  CALL: HullMA turns red->green AND price above EMA100 (waits up to N bars)
//  Strikes: Fib 0.382 / 0.5 / 0.618 as PRICE TARGETS (arrival levels).
//  Swing: recent pivots (recommended) or previous day range.
//  Works on stocks, ETFs and crypto. Everything toggleable in Settings.
// ============================================================================
indicator("0DTE HullMA+EMA100 — Entry + Fib Strikes", overlay=true, max_labels_count=500, max_lines_count=500)

// ----------------------------------------------------------------------------
//  SHOW / HIDE
// ----------------------------------------------------------------------------
grpShow = "Show / Hide"
showHull  = input.bool(true,  "HullMA (colored)", group=grpShow)
showEma   = input.bool(true,  "EMA 100", group=grpShow)
showTrig  = input.bool(true,  "CALL/PUT triggers", group=grpShow)
showPrevD = input.bool(false, "Previous day range (PDH/PDL)", group=grpShow)
showTable = input.bool(true,  "Strikes table", group=grpShow)

// ----------------------------------------------------------------------------
//  MOVING AVERAGES
// ----------------------------------------------------------------------------
grpMa = "Moving Averages"
hullLen = input.int(50,  "HullMA period", minval=2, group=grpMa)
emaLen  = input.int(100, "EMA period", minval=2, group=grpMa)
srcMa   = input.source(close, "Source", group=grpMa)

// HullMA
hma = ta.hma(srcMa, hullLen)
hmaUp = hma > hma[1]
hmaColor = hmaUp ? color.new(color.lime, 0) : color.new(color.red, 0)
// Slope turns
turnRed  = hmaUp[1] and not hmaUp   // green -> red
turnLime = not hmaUp[1] and hmaUp   // red   -> green

ema100 = ta.ema(close, emaLen)

// ----------------------------------------------------------------------------
//  HIGHER TIMEFRAME CONTEXT (informational only — does not filter signals)
// ----------------------------------------------------------------------------
grpHtf = "Higher Timeframe Context"
htfA      = input.timeframe("60",  "Context TF 1", group=grpHtf, tooltip="Session bias. Informational only, does not block signals.")
htfB      = input.timeframe("240", "Context TF 2", group=grpHtf, tooltip="Underlying tide. Informational only, does not block signals.")
htfEmaLen = input.int(50, "EMA length for context TFs", minval=2, group=grpHtf)

htfEmaA = request.security(syminfo.tickerid, htfA, ta.ema(close, htfEmaLen), lookahead=barmerge.lookahead_off)
htfEmaB = request.security(syminfo.tickerid, htfB, ta.ema(close, htfEmaLen), lookahead=barmerge.lookahead_off)
htfUpA  = close > htfEmaA
htfUpB  = close > htfEmaB

// ----------------------------------------------------------------------------
//  TRIGGER with confirmation WAIT (up to N bars)
// ----------------------------------------------------------------------------
grpTrig = "Trigger"
waitBars = input.int(4, "Bars to wait for price vs EMA100 confirmation", minval=0, maxval=12, group=grpTrig, tooltip="After the HullMA flips, wait up to N bars for price to move to the correct side of the EMA100.")
skipOpen = input.int(2, "Skip N bars after the open", minval=0, maxval=12, group=grpTrig)
cooldown = input.int(8, "Cooldown between triggers (bars)", minval=0, group=grpTrig)

newDay = ta.change(time("D")) != 0
var int barsFromOpen = 0
barsFromOpen := newDay ? 0 : barsFromOpen + 1
afterOpen = barsFromOpen >= skipOpen

// Bars since the last flip; check if price is on the correct side within the window
barsSinceRed  = ta.barssince(turnRed)
barsSinceLime = ta.barssince(turnLime)

belowEma = close < ema100
aboveEma = close > ema100

// PUT: red flip within <= waitBars AND price now below EMA100 (first time met)
putCondNow  = (barsSinceRed  <= waitBars) and belowEma and afterOpen
callCondNow = (barsSinceLime <= waitBars) and aboveEma and afterOpen

// Fire only on the bar it becomes true for the first time after the flip
putTrigRaw  = putCondNow  and not putCondNow[1]
callTrigRaw = callCondNow and not callCondNow[1]

var int lastSig = -1000
putSig  = putTrigRaw  and (bar_index - lastSig > cooldown)
callSig = callTrigRaw and (bar_index - lastSig > cooldown)
if putSig or callSig
    lastSig := bar_index

// ----------------------------------------------------------------------------
//  SWING for FIBONACCI (recent pivots)
// ----------------------------------------------------------------------------
grpFib = "Fibonacci (strikes)"
swingMode = input.string("Recent pivots", "Reference swing", options=["Recent pivots","Previous day range"], group=grpFib)
pivLen    = input.int(10, "Pivot sensitivity", minval=2, group=grpFib, tooltip="Bars on each side to confirm a pivot. Lower = more sensitive.")
f1 = input.float(0.382, "Fib 1", group=grpFib)
f2 = input.float(0.5,   "Fib 2", group=grpFib)
f3 = input.float(0.618, "Fib 3", group=grpFib)

// Pivots
ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low, pivLen, pivLen)
var float lastPH = na
var float lastPL = na
if not na(ph)
    lastPH := ph
if not na(pl)
    lastPL := pl

// Previous day range
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)

// Swing selection
swHigh = swingMode == "Recent pivots" ? lastPH : pdh
swLow  = swingMode == "Recent pivots" ? lastPL : pdl
swRange = swHigh - swLow

// Fibonacci TARGETS:
//  PUT  (down): levels = swHigh - f*range  (below entry price)
//  CALL (up):   levels = swLow  + f*range  (above entry price)
validSwing = not na(swHigh) and not na(swLow) and swRange > 0

// --- SNAPSHOT: frozen on the trigger bar ("Last Signal Details") ---
var string sigDir   = "-"
var float  sigEntry = na
var float  sigF1    = na
var float  sigF2    = na
var float  sigF3    = na
var int    sigBar   = na

if putSig and validSwing
    sigDir   := "PUT"
    sigEntry := close
    // PUT: targets are Fib fractions of the swing range, measured DOWN from entry
    sigF1    := close - f1 * swRange
    sigF2    := close - f2 * swRange
    sigF3    := close - f3 * swRange
    sigBar   := bar_index
if callSig and validSwing
    sigDir   := "CALL"
    sigEntry := close
    // CALL: targets measured UP from entry
    sigF1    := close + f1 * swRange
    sigF2    := close + f2 * swRange
    sigF3    := close + f3 * swRange
    sigBar   := bar_index

hasSig = sigDir != "-"

// ----------------------------------------------------------------------------
//  PLOTS — moving averages
// ----------------------------------------------------------------------------
plot(showHull ? hma : na, "HullMA", color=hmaColor, linewidth=3)
plot(showEma  ? ema100 : na, "EMA 100", color=color.new(color.white, 0), linewidth=2)

// Previous day pivots (optional)
plot(showPrevD ? pdh : na, "PDH", color=color.new(color.red, 40),   style=plot.style_linebr)
plot(showPrevD ? pdl : na, "PDL", color=color.new(color.green, 40), style=plot.style_linebr)

// Fib strikes: table only, not drawn on chart (keeps candles clean)

// Triggers
plotshape(showTrig and callSig, title="CALL", style=shape.labelup,   location=location.belowbar, color=color.new(color.green,0), textcolor=color.white, text="CALL", size=size.normal)
plotshape(showTrig and putSig,  title="PUT",  style=shape.labeldown, location=location.abovebar, color=color.new(color.red,0),   textcolor=color.white, text="PUT",  size=size.normal)

// ----------------------------------------------------------------------------
//  TABLE — Last Signal Details
// ----------------------------------------------------------------------------
if showTable and barstate.islast
    var table t = table.new(position.top_right, 2, 8, border_width=1)
    dirCol = sigDir == "CALL" ? color.new(color.green,0) : sigDir == "PUT" ? color.new(color.red,0) : color.new(color.gray,0)
    barsAgo = hasSig ? (bar_index - sigBar) : na
    ageTxt  = hasSig ? (str.tostring(barsAgo) + " bars ago") : "no signal yet"
    colA = htfUpA ? color.new(color.green,0) : color.new(color.red,0)
    colB = htfUpB ? color.new(color.green,0) : color.new(color.red,0)

    table.cell(t, 0, 0, "LAST SIGNAL", text_color=color.white, bgcolor=color.new(color.black,10), text_size=size.small)
    table.cell(t, 1, 0, sigDir, text_color=color.white, bgcolor=dirCol, text_size=size.small)
    table.cell(t, 0, 1, "Age", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 1, ageTxt, text_color=color.white, text_size=size.small)
    table.cell(t, 0, 2, "Entry", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 2, hasSig ? str.tostring(sigEntry, format.mintick) : "-", text_color=color.white, text_size=size.small)
    table.cell(t, 0, 3, "Strike "+str.tostring(f1), text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 3, hasSig ? str.tostring(sigF1, format.mintick) : "-", text_color=color.yellow, text_size=size.small)
    table.cell(t, 0, 4, "Strike "+str.tostring(f2), text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 4, hasSig ? str.tostring(sigF2, format.mintick) : "-", text_color=color.orange, text_size=size.small)
    table.cell(t, 0, 5, "Strike "+str.tostring(f3), text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 5, hasSig ? str.tostring(sigF3, format.mintick) : "-", text_color=color.fuchsia, text_size=size.small)
    table.cell(t, 0, 6, "Trend "+htfA, text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 6, htfUpA ? "UP" : "DOWN", text_color=color.white, bgcolor=colA, text_size=size.small)
    table.cell(t, 0, 7, "Trend "+htfB, text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 7, htfUpB ? "UP" : "DOWN", text_color=color.white, bgcolor=colB, text_size=size.small)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
alertcondition(callSig, "CALL", "CALL 0DTE — HullMA green + price above EMA100")
alertcondition(putSig,  "PUT",  "PUT 0DTE — HullMA red + price below EMA100")
````
