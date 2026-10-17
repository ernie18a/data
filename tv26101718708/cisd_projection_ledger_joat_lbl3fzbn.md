# CISD Projection Ledger [JOAT]

- url: https://www.tradingview.com/script/lbl3FZbn-CISD-Projection-Ledger-JOAT/
- type: indicator
- pine_id: PUB;1b66e1af78f541199a7b5d83c45eabbd
- version: 1.0

## Description

[b]CISD Projection Ledger [JOAT][/b]

[b]Introduction[/b]

CPL CISD Projection Ledger is an open-source projection overlay that detects confirmed directional delivery shifts, then projects a structured target ledger from the qualifying run range.

The indicator focuses on one job: finding a qualifying run, confirming the open-cross shift on a closed bar, and tracking which projection tiers have been reached or invalidated.

[image]https://www.tradingview.com/x/9RDmkhRE/[/image]

[b]Core Concepts[/b]

[b]1. Directional Run Engine[/b]
Bars are grouped into directional runs based on close-to-close progression. A run must meet the minimum bar count before it can qualify.

[b]2. Edge Filter[/b]
The prior run must form near the upper or lower region of the recent lookback range before a CISD event can trigger.

[b]3. Open-Cross Confirmation[/b]
A bullish CISD requires a prior bearish run and a confirmed close back above the prior run open. Bearish logic is mirrored.

[b]4. Projection Ledger[/b]
Five tiers are projected from the confirmed run range using configurable multipliers.

[b]5. Reached and Invalid States[/b]
Each tier fades after it is reached. The whole ledger invalidates if price closes beyond the opposite reference side.

[b]Features[/b]

[list]
[*][b]Confirmed CISD trigger:[/b] Uses closed-bar open-cross confirmation
[*][b]Range edge filter:[/b] Avoids projecting every minor run flip
[*][b]Five-tier ledger:[/b] Customizable projection multipliers
[*][b]Reached-level tracking:[/b] Levels visually fade after completion
[*][b]Invalidation logic:[/b] Opposite-side failure changes state
[*][b]Ledger band:[/b] Transparent fill from base to furthest target
[*][b]Top-right dashboard:[/b] Shows base, range, tier prices, reached status, and active state
[*][b]Alerts:[/b] Includes bullish and bearish CISD confirmations
[/list]

[b]Input Parameters[/b]

[b]Run Engine:[/b]
[list]
[*]Minimum Run Bars
[*]Range Lookback
[*]Edge Window
[/list]

[b]Ledger:[/b]
[list]
[*]Tier 1 through Tier 5 multipliers
[/list]

[b]How to Use[/b]

[b]Step 1:[/b] Wait for a confirmed bullish or bearish CISD state in the dashboard.

[b]Step 2:[/b] Use the base level and projected tiers as a structured map of possible delivery objectives.

[b]Step 3:[/b] Watch reached status. Faded levels indicate completed tiers.

[b]Step 4:[/b] Respect invalidation. An invalid ledger means the original delivery thesis failed.

[b]Limitations[/b]

[list]
[*]Projection levels are analytical references, not guaranteed targets
[*]Strong reversals can invalidate a ledger quickly
[*]The edge filter may skip valid-looking setups that are not near the configured range edge
[*]The indicator should not be used without independent trade management
[/list]

[b]Originality Statement[/b]

CPL is an original JOAT implementation that transforms directional run logic into a confirmed CISD ledger with tier tracking, invalidation, and a restrained institutional visual system.

[b]Disclaimer[/b]

This script is for educational and informational purposes only. It is not financial advice and does not guarantee future results. Trading involves risk, and users should apply their own risk management.

Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("CISD Projection Ledger [JOAT]", shorttitle="CPL [JOAT]", overlay=true, max_lines_count=80, max_labels_count=20, max_boxes_count=10)

//------------------------------------------------------------------------------
// JOAT CISD Projection Ledger
// - Tracks directional runs from bar-to-bar close progression.
// - Confirms CISD only when the prior run breaks its open on a closed bar.
// - Projects a ladder of unreached/reached targets from the run extreme.
// - Uses a compact top-right ledger and clean horizontal levels.
//------------------------------------------------------------------------------

cplGroupRun = "Run Engine"
cplGroupLedger = "Ledger"
cplGroupVisuals = "Visuals"
cplGroupSignals = "Signal Engine"

minRunBars = input.int(3, "Minimum Run Bars", minval=2, group=cplGroupRun)
rangeLookback = input.int(40, "Range Lookback", minval=10, group=cplGroupRun)
edgeWindow = input.float(0.25, "Edge Window", minval=0.05, maxval=0.5, step=0.01, group=cplGroupRun)

mult1 = input.float(1.0, "Tier 1 Multiplier", minval=0.1, step=0.1, group=cplGroupLedger)
mult2 = input.float(2.0, "Tier 2 Multiplier", minval=0.1, step=0.1, group=cplGroupLedger)
mult3 = input.float(2.5, "Tier 3 Multiplier", minval=0.1, step=0.1, group=cplGroupLedger)
mult4 = input.float(4.0, "Tier 4 Multiplier", minval=0.1, step=0.1, group=cplGroupLedger)
mult5 = input.float(4.5, "Tier 5 Multiplier", minval=0.1, step=0.1, group=cplGroupLedger)

showLedgerBand = input.bool(true, "Show Ledger Band", group=cplGroupVisuals)
showDashboard = input.bool(true, "Show Dashboard", group=cplGroupVisuals)
showBackground = input.bool(true, "Show Bias Tint", group=cplGroupVisuals)
bullColor = input.color(color.rgb(8, 153, 129), "Bull Color", group=cplGroupVisuals)
bearColor = input.color(color.rgb(242, 54, 69), "Bear Color", group=cplGroupVisuals)
neutralColor = input.color(color.rgb(160, 166, 178), "Neutral Color", group=cplGroupVisuals)
bandTransp = input.int(88, "Band Transparency", minval=0, maxval=100, group=cplGroupVisuals)
bgTransp = input.int(94, "Background Transparency", minval=0, maxval=100, group=cplGroupVisuals)

signalThreshold = input.int(3, "Completion Threshold", minval=1, maxval=5, group=cplGroupSignals)

f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_tint(int bias, int transp) =>
    bias > 0 ? color.new(bullColor, transp) : bias < 0 ? color.new(bearColor, transp) : color.new(neutralColor, transp)

f_bias_text(int bias) =>
    bias > 0 ? "BULL" : bias < 0 ? "BEAR" : "NEUT"

f_status_text(bool invalid, int hitCount, int totalCount) =>
    invalid ? "INVALID" : hitCount >= totalCount ? "COMPLETE" : "ACTIVE"

f_edge_ok(int priorDir, float priorHigh, float priorLow) =>
    lookHigh = ta.highest(high, rangeLookback)
    lookLow = ta.lowest(low, rangeLookback)
    lookRange = math.max(lookHigh - lookLow, syminfo.mintick)
    priorDir < 0 ? priorLow <= lookLow + lookRange * edgeWindow : priorHigh >= lookHigh - lookRange * edgeWindow

f_destroy_line(line id) =>
    if not na(id)
        line.delete(id)

f_level_color(bool hit, color baseColor) =>
    hit ? color.new(baseColor, 45) : color.new(baseColor, 0)

//------------------------------------------------------------------------------
// Directional run engine.
//------------------------------------------------------------------------------
currDir = na(close[1]) ? 1 : close >= close[1] ? 1 : -1

var int runDir = na
var float runOpen = na
var float runHigh = na
var float runLow = na
var int runBars = 0
var int runStartBar = na

var int priorDir = na
var float priorOpen = na
var float priorHigh = na
var float priorLow = na
var int priorBars = 0

newRun = na(runDir) or currDir != runDir
bullTrigger = false
bearTrigger = false

if na(runDir)
    runDir := currDir
    runOpen := open
    runHigh := high
    runLow := low
    runBars := 1
    runStartBar := bar_index
else if not newRun
    runHigh := math.max(runHigh, high)
    runLow := math.min(runLow, low)
    runBars += 1
else
    // Finalize the prior run before starting the next one.
    priorDir := runDir
    priorOpen := runOpen
    priorHigh := runHigh
    priorLow := runLow
    priorBars := runBars

    bullTrigger := barstate.isconfirmed and priorDir == -1 and priorBars >= minRunBars and close > priorOpen and close[1] <= priorOpen and f_edge_ok(priorDir, priorHigh, priorLow)
    bearTrigger := barstate.isconfirmed and priorDir == 1 and priorBars >= minRunBars and close < priorOpen and close[1] >= priorOpen and f_edge_ok(priorDir, priorHigh, priorLow)

    runDir := currDir
    runOpen := open
    runHigh := high
    runLow := low
    runBars := 1
    runStartBar := bar_index

//------------------------------------------------------------------------------
// Current ledger state.
//------------------------------------------------------------------------------
var bool ledgerActive = false
var int ledgerDir = 0
var float ledgerBase = na
var float ledgerRange = na
var float ledgerStopRef = na
var int ledgerTriggerBar = na
var bool ledgerInvalid = false
var color ledgerColor = neutralColor

var float lvl1 = na
var float lvl2 = na
var float lvl3 = na
var float lvl4 = na
var float lvl5 = na

var bool hit1 = false
var bool hit2 = false
var bool hit3 = false
var bool hit4 = false
var bool hit5 = false

var line baseLine = na
var line line1 = na
var line line2 = na
var line line3 = na
var line line4 = na
var line line5 = na

if bullTrigger or bearTrigger
    // Replace the prior ledger with the newest confirmed CISD setup.
    f_destroy_line(baseLine)
    f_destroy_line(line1)
    f_destroy_line(line2)
    f_destroy_line(line3)
    f_destroy_line(line4)
    f_destroy_line(line5)

    ledgerActive := true
    ledgerDir := bullTrigger ? 1 : -1
    ledgerColor := bullTrigger ? bullColor : bearColor
    ledgerBase := bullTrigger ? priorHigh : priorLow
    ledgerRange := math.max(priorHigh - priorLow, syminfo.mintick)
    ledgerStopRef := bullTrigger ? priorLow : priorHigh
    ledgerTriggerBar := bar_index
    ledgerInvalid := false

    lvl1 := ledgerBase + ledgerDir * ledgerRange * mult1
    lvl2 := ledgerBase + ledgerDir * ledgerRange * mult2
    lvl3 := ledgerBase + ledgerDir * ledgerRange * mult3
    lvl4 := ledgerBase + ledgerDir * ledgerRange * mult4
    lvl5 := ledgerBase + ledgerDir * ledgerRange * mult5

    hit1 := false
    hit2 := false
    hit3 := false
    hit4 := false
    hit5 := false

    baseLine := line.new(ledgerTriggerBar, ledgerBase, bar_index, ledgerBase, extend=extend.right, color=color.new(neutralColor, 0), style=line.style_dotted, width=2)
    line1 := line.new(ledgerTriggerBar, lvl1, bar_index, lvl1, extend=extend.right, color=color.new(bullTrigger ? bullColor : bearColor, 0), style=line.style_solid, width=2)
    line2 := line.new(ledgerTriggerBar, lvl2, bar_index, lvl2, extend=extend.right, color=color.new(bullTrigger ? bullColor : bearColor, 8), style=line.style_solid, width=2)
    line3 := line.new(ledgerTriggerBar, lvl3, bar_index, lvl3, extend=extend.right, color=color.new(bullTrigger ? bullColor : bearColor, 14), style=line.style_dashed, width=2)
    line4 := line.new(ledgerTriggerBar, lvl4, bar_index, lvl4, extend=extend.right, color=color.new(bullTrigger ? bullColor : bearColor, 20), style=line.style_dashed, width=2)
    line5 := line.new(ledgerTriggerBar, lvl5, bar_index, lvl5, extend=extend.right, color=color.new(bullTrigger ? bullColor : bearColor, 26), style=line.style_dotted, width=2)

// Mark levels as reached only on closed bars.
if ledgerActive and barstate.isconfirmed and not ledgerInvalid
    if ledgerDir > 0
        hit1 := hit1 or high >= lvl1
        hit2 := hit2 or high >= lvl2
        hit3 := hit3 or high >= lvl3
        hit4 := hit4 or high >= lvl4
        hit5 := hit5 or high >= lvl5
        ledgerInvalid := close < ledgerStopRef
    else if ledgerDir < 0
        hit1 := hit1 or low <= lvl1
        hit2 := hit2 or low <= lvl2
        hit3 := hit3 or low <= lvl3
        hit4 := hit4 or low <= lvl4
        hit5 := hit5 or low <= lvl5
        ledgerInvalid := close > ledgerStopRef

// Fade levels as they are reached or invalidated.
if not na(line1)
    line.set_color(line1, ledgerInvalid ? color.new(neutralColor, 70) : f_level_color(hit1, ledgerColor))
if not na(line2)
    line.set_color(line2, ledgerInvalid ? color.new(neutralColor, 76) : f_level_color(hit2, ledgerColor))
if not na(line3)
    line.set_color(line3, ledgerInvalid ? color.new(neutralColor, 80) : f_level_color(hit3, ledgerColor))
if not na(line4)
    line.set_color(line4, ledgerInvalid ? color.new(neutralColor, 84) : f_level_color(hit4, ledgerColor))
if not na(line5)
    line.set_color(line5, ledgerInvalid ? color.new(neutralColor, 88) : f_level_color(hit5, ledgerColor))
if not na(baseLine)
    line.set_color(baseLine, ledgerInvalid ? color.new(neutralColor, 60) : color.new(neutralColor, 0))

furthestTarget = ledgerDir == 0 ? na : lvl5
completedCount = (hit1 ? 1 : 0) + (hit2 ? 1 : 0) + (hit3 ? 1 : 0) + (hit4 ? 1 : 0) + (hit5 ? 1 : 0)
activeStatus = ledgerInvalid ? "INVALID" : (completedCount >= signalThreshold ? "COMPLETE" : "ACTIVE")

//------------------------------------------------------------------------------
// Ledger band and background.
//------------------------------------------------------------------------------
pLedgerBase = plot(showLedgerBand and ledgerActive ? ledgerBase : na, "Ledger Base", color=color.new(neutralColor, 100), display=display.none)
pLedgerEdge = plot(showLedgerBand and ledgerActive ? furthestTarget : na, "Ledger Edge", color=color.new(neutralColor, 100), display=display.none)
fill(pLedgerBase, pLedgerEdge, color=showLedgerBand and ledgerActive and not na(furthestTarget) ? color.new(ledgerDir > 0 ? bullColor : bearColor, bandTransp) : na)

bgcolor(showBackground and ledgerActive and barstate.isconfirmed ? color.new(ledgerDir > 0 ? bullColor : bearColor, bgTransp) : na)

//------------------------------------------------------------------------------
// Dashboard.
//------------------------------------------------------------------------------
var table dash = table.new(position.top_right, 3, 8, frame_color=color.new(color.rgb(65, 70, 84), 20), frame_width=1, border_color=color.new(color.rgb(65, 70, 84), 35))

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "CPL Ledger", text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 1, 0, "Run", text_color=color.silver, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 2, 0, "State", text_color=color.silver, bgcolor=color.new(color.rgb(16, 20, 28), 0))

    table.cell(dash, 0, 1, "CISD", text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 1, 1, f_bias_text(ledgerDir), text_color=color.white, bgcolor=color.new(f_tint(ledgerDir, 10), 10))
    table.cell(dash, 2, 1, activeStatus, text_color=color.white, bgcolor=ledgerInvalid ? color.new(neutralColor, 20) : color.new(f_tint(ledgerDir, 0), 12))

    table.cell(dash, 0, 2, "Base", text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 1, 2, na(ledgerBase) ? "n/a" : str.tostring(ledgerBase, format.mintick), text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 2, 2, "Range " + (na(ledgerRange) ? "n/a" : str.tostring(ledgerRange, format.mintick)), text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))

    table.cell(dash, 0, 3, "Tier 1", text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 1, 3, na(lvl1) ? "n/a" : str.tostring(lvl1, format.mintick), text_color=color.white, bgcolor=f_level_color(hit1, ledgerDir > 0 ? bullColor : bearColor))
    table.cell(dash, 2, 3, hit1 ? "REACHED" : "WAIT", text_color=color.white, bgcolor=hit1 ? color.new(color.rgb(56, 60, 72), 10) : color.new(color.rgb(16, 20, 28), 0))

    table.cell(dash, 0, 4, "Tier 2", text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 1, 4, na(lvl2) ? "n/a" : str.tostring(lvl2, format.mintick), text_color=color.white, bgcolor=f_level_color(hit2, ledgerDir > 0 ? bullColor : bearColor))
    table.cell(dash, 2, 4, hit2 ? "REACHED" : "WAIT", text_color=color.white, bgcolor=hit2 ? color.new(color.rgb(56, 60, 72), 10) : color.new(color.rgb(16, 20, 28), 0))

    table.cell(dash, 0, 5, "Tier 3", text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 1, 5, na(lvl3) ? "n/a" : str.tostring(lvl3, format.mintick), text_color=color.white, bgcolor=f_level_color(hit3, ledgerDir > 0 ? bullColor : bearColor))
    table.cell(dash, 2, 5, hit3 ? "REACHED" : "WAIT", text_color=color.white, bgcolor=hit3 ? color.new(color.rgb(56, 60, 72), 10) : color.new(color.rgb(16, 20, 28), 0))

    table.cell(dash, 0, 6, "Tier 4", text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 1, 6, na(lvl4) ? "n/a" : str.tostring(lvl4, format.mintick), text_color=color.white, bgcolor=f_level_color(hit4, ledgerDir > 0 ? bullColor : bearColor))
    table.cell(dash, 2, 6, hit4 ? "REACHED" : "WAIT", text_color=color.white, bgcolor=hit4 ? color.new(color.rgb(56, 60, 72), 10) : color.new(color.rgb(16, 20, 28), 0))

    table.cell(dash, 0, 7, "Tier 5", text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 1, 7, na(lvl5) ? "n/a" : str.tostring(lvl5, format.mintick), text_color=color.white, bgcolor=f_level_color(hit5, ledgerDir > 0 ? bullColor : bearColor))
    table.cell(dash, 2, 7, hit5 ? "REACHED" : "WAIT", text_color=color.white, bgcolor=hit5 ? color.new(color.rgb(56, 60, 72), 10) : color.new(color.rgb(16, 20, 28), 0))

alertcondition(bullTrigger, "CPL Bullish CISD", "CPL bullish CISD confirmed on a closed bar.")
alertcondition(bearTrigger, "CPL Bearish CISD", "CPL bearish CISD confirmed on a closed bar.")
````
