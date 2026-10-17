# AetherEdge - Order Block + FVG Detector

- url: https://www.tradingview.com/script/FLI6Eyql/
- type: indicator
- pine_id: PUB;12e4478f152f42b19c9938190f663766
- version: 1.0

## Description

🖊️ Overview
AetherEdge Order Block + FVG Detector is a high-precision engine that integrates the two core elements of Smart Money Concepts (SMC)—Order Blocks (OB) and Fair Value Gaps (FVG)—to visualize institutional footprints on your chart. It features BOS (Break of Structure)-driven OB identification, automatic price gap mapping, mitigation tracking, and a beginner-friendly "Entry Zone" mode. The zone-based strategies practiced by professional traders are reproduced visually and systematically, all within a single indicator.

🔶 Key Features

BOS-Driven Order Block Detection: Auto-identifies the last opposite candle before structure break
Bullish/Bearish OB Support: Functions in both long and short scenarios
Auto Fair Value Gap Detection: Captures 3-bar price imbalances
Mitigation Tracking: Wick/Close toggle, Touch/50%/Full thresholds
Entry Zone Mode: 4 modes—OB only / FVG only / Either / Both overlap
Auto BOS Line Drawing: Visualizes structure break points
Active Zone Management: obMaxShow/fvgMaxShow retain only latest zones
Right-Side Auto Extension: Untouched zones extended forward
Integrated Dashboard: Active OB/FVG count, latest BOS direction
Premium AetherEdge UI: Dark-mode professional design

🧠 Technical Architecture

This indicator crystallizes SMC theory into implementable logic—a sophisticated zone detection engine.

Structure Detection (BOS Engine): ta.pivothigh/pivotlow detects swing points based on obSwingLen. lastSwingH/L updates dynamically; close > lastSwingH (with prior bar below) fires bosUp, and the inverse fires bosDown.
Order Block Identification Logic: On BOS trigger, scans up to 20 bars back for the "last opposite candle." On bullish BOS, the last bearish candle becomes Bull OB; on bearish BOS, the last bullish candle becomes Bear OB. This is the classical SMC logic capturing institutional "final accumulation/distribution points."
OB Data Structure: Custom type OB integrates box/top/bot/createdBar/bullish/mitigated/label. Array-based lifecycle management.
FVG Detection Logic: 3-bar pattern detects high[2] < low[0] (bullish FVG) or low[2] > high[0] (bearish FVG). fvgMinSize filters minimum gap size.
Mitigation Logic:
Wick mode: Consumed when wick reaches zone
Close mode: Consumed when close penetrates zone (stricter)
FVG uses Touch/50%/Full for graded judgment
Entry Zone Composition: 4 signal logics from OB+FVG overlap/standalone/selection modes. Both overlap = strongest confluence.
Dynamic Zone Management: Zones exceeding max array size auto-deleted, keeping chart clean.

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (4H–Daily): obSwingLen=10, fvgMinSize=0.1, obMitigate=Wick (standard)
ETH (1H–4H): obSwingLen=8, fvgMinSize=0.05 for slightly higher sensitivity
SOL (High-Vol): obSwingLen=15, fvgMinSize=0.2 for large zones only
XRP (Range): obMitigate=Close, fvgFill=50% for strict judgment
Tuning Guide:

Day Trading: obSwingLen=8-10, obExtend=30-50, primary 1H
Swing: obSwingLen=20-30, obExtend=100 for macro zones
Scalping: obSwingLen=5, fvgMinSize=0.0 for short-term zones
Conservative Traders: ezRequire="Both overlap" for OB+FVG overlap only
Aggressive Traders: ezRequire="Either" to maximize signals
Excess Zones: obMaxShow=3, fvgMaxShow=5 to prioritize precision
Strong Trends: obSwingLen=15 for major structure only, avoiding fake BOS

💡 How to Use in Practice

Bull OB Retest: Price returning to Bull OB after BOS = golden long entry timing
FVG Fill Strategy: 50% gap fill confirms reversal, enter in trend direction
OB+FVG Overlap Zones: Both overlap mode pinpoints highest-conviction entries
BOS Line Break Confirmation: Retest after structure break confirms trend continuation
Multi-Timeframe Synergy: Higher-TF OB for direction + lower-TF FVG for precise entry
AetherEdge Synergy:
Self-Evolving S/R Grid strong line + OB overlap = triple confirmation
RSI Divergence Hunter signal + OB retest = max reversal conviction
Squeeze Breaker breakout direction + FVG fill = entry timing decision
Target Setting: Use opposite OB/FVG as profit-taking targets

⚠️ Important Notes

BOS Confirmation Lag: obSwingLen bars of confirmation delay; some real-time uncertainty
OB Search Range: No OB generated if no opposite candle exists within past 20 bars
Post-Mitigation Effect: Consumed OB/FVG tend to weaken; prioritize fresh zones
Consecutive BOS in Strong Trends: Mass OB generation possible in short periods; recommend limiting via obMaxShow
FVG Min Size: fvgMinSize=0 detects micro-gaps; tune based on market conditions

🚨 Disclaimer

This indicator is a technical analysis tool provided for educational and research purposes only and does not constitute financial advice. Order Block and FVG detection is a structural evaluation based on historical price data and does not guarantee future market behavior. All trading decisions are made at your own risk and should be accompanied by proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge - Order Block + FVG Detector", "AE-OB+FVG", overlay=true, max_boxes_count=500, max_lines_count=200, max_labels_count=300)

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
grpOB = "① Order Block"
obEnable   = input.bool(true,  "Detect Order Blocks", group=grpOB)
obSwingLen = input.int(10, "Swing Length (structure break)", minval=3, maxval=50, group=grpOB)
obMaxShow  = input.int(5,  "Max Active OBs per side", minval=1, maxval=20, group=grpOB)
obMitigate = input.string("Wick", "Mitigation Rule", options=["Wick","Close"], group=grpOB)
obExtend   = input.int(30, "Extend Right (bars)", minval=5, maxval=500, group=grpOB)

grpFVG = "② Fair Value Gap"
fvgEnable  = input.bool(true,  "Detect Fair Value Gaps", group=grpFVG)
fvgMinSize = input.float(0.0,  "Min Gap Size (% of price)", minval=0.0, step=0.01, group=grpFVG)
fvgMaxShow = input.int(10, "Max Active FVGs", minval=1, maxval=30, group=grpFVG)
fvgFill    = input.string("50%", "Mitigation Threshold", options=["Touch","50%","Full"], group=grpFVG)
fvgExtend  = input.int(30, "Extend Right (bars)", minval=5, maxval=500, group=grpFVG)

grpEZ = "③ Entry Zone (Beginner Mode)"
ezEnable   = input.bool(true,  "Show Entry Zones", group=grpEZ)
ezRequire  = input.string("Either", "Trigger", options=["OB only","FVG only","Either","Both overlap"], group=grpEZ)
ezTag      = input.bool(true,  "Show Entry Labels", group=grpEZ)

grpUI = "🎨 Display"
darkMode   = input.bool(true,  "Dark Mode", group=grpUI)
showBOS    = input.bool(true,  "Show BOS Lines", group=grpUI)
showDash   = input.bool(true,  "Show Dashboard", group=grpUI)
dashPos    = input.string("Top Right", "Dashboard Position",
             options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=grpUI)

// ═══════════════════════════════════════════════════════════════
//  COLORS — AetherEdge palette
// ═══════════════════════════════════════════════════════════════
cBg      = darkMode ? color.new(#0b1221, 10) : color.new(#f7f9fc, 10)
cBgAlt   = darkMode ? color.new(#111a2e, 15) : color.new(#ffffff, 0)
cBorder  = darkMode ? color.new(#1f2a44, 0)  : color.new(#d8dee9, 0)
cText    = darkMode ? color.new(#e6edf7, 0)  : color.new(#1a202c, 0)
cMute    = darkMode ? color.new(#8892b0, 0)  : color.new(#64748b, 0)
cAccent  = color.new(#00d4ff, 0)

cBullOB  = color.new(#00e5a0, 0)
cBearOB  = color.new(#ff3d71, 0)
cBullFVG = color.new(#26a69a, 0)
cBearFVG = color.new(#ef5350, 0)
cEntry   = color.new(#ffd23f, 0)
cBOS     = color.new(#00d4ff, 0)

// ═══════════════════════════════════════════════════════════════
//  STRUCTURE — swing highs / lows for BOS detection
// ═══════════════════════════════════════════════════════════════
swingH = ta.pivothigh(high, obSwingLen, obSwingLen)
swingL = ta.pivotlow(low,   obSwingLen, obSwingLen)

var float lastSwingH = na
var float lastSwingL = na
var int   lastSwingHBar = na
var int   lastSwingLBar = na

if not na(swingH)
    lastSwingH := swingH
    lastSwingHBar := bar_index - obSwingLen
if not na(swingL)
    lastSwingL := swingL
    lastSwingLBar := bar_index - obSwingLen

// Break of Structure
bosUp   = not na(lastSwingH) and close > lastSwingH and close[1] <= lastSwingH
bosDown = not na(lastSwingL) and close < lastSwingL and close[1] >= lastSwingL

// ═══════════════════════════════════════════════════════════════
//  ORDER BLOCK DETECTION
//  Bullish OB: last DOWN candle before a BOS-up move
//  Bearish OB: last UP candle before a BOS-down move
// ═══════════════════════════════════════════════════════════════
type OB
    box   bx
    float top
    float bot
    int   createdBar
    bool  bullish
    bool  mitigated
    label lb

var array<OB> bullOBs = array.new<OB>()
var array<OB> bearOBs = array.new<OB>()

f_findLastDownCandle() =>
    idx = -1
    for i = 1 to 20
        if close[i] < open[i]
            idx := i
            break
    idx

f_findLastUpCandle() =>
    idx = -1
    for i = 1 to 20
        if close[i] > open[i]
            idx := i
            break
    idx

if obEnable and bosUp
    i = f_findLastDownCandle()
    if i >= 0
        obTop = high[i]
        obBot = low[i]
        bx = box.new(bar_index - i, obTop, bar_index + obExtend, obBot,
                 border_color=cBullOB, bgcolor=color.new(cBullOB, 82),
                 border_width=1, extend=extend.none)
        lb = label.new(bar_index - i, obBot, "Bull OB", style=label.style_label_up,
                 color=color.new(cBullOB, 30), textcolor=color.white, size=size.tiny)
        newOB = OB.new(bx, obTop, obBot, bar_index - i, true, false, lb)
        array.push(bullOBs, newOB)
        if array.size(bullOBs) > obMaxShow
            old = array.shift(bullOBs)
            box.delete(old.bx)
            label.delete(old.lb)

if obEnable and bosDown
    i = f_findLastUpCandle()
    if i >= 0
        obTop = high[i]
        obBot = low[i]
        bx = box.new(bar_index - i, obTop, bar_index + obExtend, obBot,
                 border_color=cBearOB, bgcolor=color.new(cBearOB, 82),
                 border_width=1, extend=extend.none)
        lb = label.new(bar_index - i, obTop, "Bear OB", style=label.style_label_down,
                 color=color.new(cBearOB, 30), textcolor=color.white, size=size.tiny)
        newOB = OB.new(bx, obTop, obBot, bar_index - i, false, false, lb)
        array.push(bearOBs, newOB)
        if array.size(bearOBs) > obMaxShow
            old = array.shift(bearOBs)
            box.delete(old.bx)
            label.delete(old.lb)

// BOS lines
if showBOS and bosUp and not na(lastSwingHBar)
    line.new(lastSwingHBar, lastSwingH, bar_index, lastSwingH,
         color=cBOS, width=1, style=line.style_dashed)
    label.new(bar_index, lastSwingH, "BOS ▲", style=label.style_label_left,
         color=color.new(cBOS, 30), textcolor=color.white, size=size.tiny)

if showBOS and bosDown and not na(lastSwingLBar)
    line.new(lastSwingLBar, lastSwingL, bar_index, lastSwingL,
         color=cBOS, width=1, style=line.style_dashed)
    label.new(bar_index, lastSwingL, "BOS ▼", style=label.style_label_left,
         color=color.new(cBOS, 30), textcolor=color.white, size=size.tiny)

// ═══════════════════════════════════════════════════════════════
//  OB MITIGATION CHECK
// ═══════════════════════════════════════════════════════════════
f_mitigatedBull(top, bot) =>
    obMitigate == "Wick" ? low <= top : close <= top

f_mitigatedBear(top, bot) =>
    obMitigate == "Wick" ? high >= bot : close >= bot

if array.size(bullOBs) > 0
    for i = array.size(bullOBs) - 1 to 0
        ob = array.get(bullOBs, i)
        if not ob.mitigated and f_mitigatedBull(ob.top, ob.bot) and low <= ob.top and high >= ob.bot
            ob.mitigated := true
            box.set_bgcolor(ob.bx, color.new(cMute, 90))
            box.set_border_color(ob.bx, color.new(cMute, 50))
            label.set_text(ob.lb, "Bull OB ✓")
            label.set_color(ob.lb, color.new(cMute, 50))

if array.size(bearOBs) > 0
    for i = array.size(bearOBs) - 1 to 0
        ob = array.get(bearOBs, i)
        if not ob.mitigated and f_mitigatedBear(ob.top, ob.bot) and low <= ob.top and high >= ob.bot
            ob.mitigated := true
            box.set_bgcolor(ob.bx, color.new(cMute, 90))
            box.set_border_color(ob.bx, color.new(cMute, 50))
            label.set_text(ob.lb, "Bear OB ✓")
            label.set_color(ob.lb, color.new(cMute, 50))

// Extend active OB boxes
if array.size(bullOBs) > 0
    for i = 0 to array.size(bullOBs) - 1
        ob = array.get(bullOBs, i)
        if not ob.mitigated
            box.set_right(ob.bx, bar_index + obExtend)

if array.size(bearOBs) > 0
    for i = 0 to array.size(bearOBs) - 1
        ob = array.get(bearOBs, i)
        if not ob.mitigated
            box.set_right(ob.bx, bar_index + obExtend)

// ═══════════════════════════════════════════════════════════════
//  FAIR VALUE GAP DETECTION
//  Bullish FVG: low[0] > high[2]   → gap between bar-2 high and bar-0 low
//  Bearish FVG: high[0] < low[2]   → gap between bar-0 high and bar-2 low
// ═══════════════════════════════════════════════════════════════
type FVG
    box   bx
    float top
    float bot
    int   createdBar
    bool  bullish
    bool  mitigated

var array<FVG> bullFVGs = array.new<FVG>()
var array<FVG> bearFVGs = array.new<FVG>()

gapPct = close > 0 ? fvgMinSize / 100.0 * close : 0.0

bullFVGcond = fvgEnable and low > high[2] and (low - high[2]) >= gapPct
bearFVGcond = fvgEnable and high < low[2] and (low[2] - high) >= gapPct

if bullFVGcond
    top = low
    bot = high[2]
    bx = box.new(bar_index - 1, top, bar_index + fvgExtend, bot,
             border_color=color.new(cBullFVG, 40), bgcolor=color.new(cBullFVG, 85),
             border_width=1, border_style=line.style_dotted, extend=extend.none)
    newF = FVG.new(bx, top, bot, bar_index, true, false)
    array.push(bullFVGs, newF)
    if array.size(bullFVGs) > fvgMaxShow
        old = array.shift(bullFVGs)
        box.delete(old.bx)

if bearFVGcond
    top = low[2]
    bot = high
    bx = box.new(bar_index - 1, top, bar_index + fvgExtend, bot,
             border_color=color.new(cBearFVG, 40), bgcolor=color.new(cBearFVG, 85),
             border_width=1, border_style=line.style_dotted, extend=extend.none)
    newF = FVG.new(bx, top, bot, bar_index, false, false)
    array.push(bearFVGs, newF)
    if array.size(bearFVGs) > fvgMaxShow
        old = array.shift(bearFVGs)
        box.delete(old.bx)

// FVG mitigation
f_fvgMitigated(top, bot, bull) =>
    mid = (top + bot) / 2.0
    if fvgFill == "Touch"
        bull ? low <= top : high >= bot
    else if fvgFill == "50%"
        bull ? low <= mid : high >= mid
    else
        bull ? low <= bot : high >= top

if array.size(bullFVGs) > 0
    for i = array.size(bullFVGs) - 1 to 0
        fv = array.get(bullFVGs, i)
        if not fv.mitigated and f_fvgMitigated(fv.top, fv.bot, true)
            fv.mitigated := true
            box.set_bgcolor(fv.bx, color.new(cMute, 92))
            box.set_border_color(fv.bx, color.new(cMute, 60))

if array.size(bearFVGs) > 0
    for i = array.size(bearFVGs) - 1 to 0
        fv = array.get(bearFVGs, i)
        if not fv.mitigated and f_fvgMitigated(fv.top, fv.bot, false)
            fv.mitigated := true
            box.set_bgcolor(fv.bx, color.new(cMute, 92))
            box.set_border_color(fv.bx, color.new(cMute, 60))

// Extend active FVG boxes
if array.size(bullFVGs) > 0
    for i = 0 to array.size(bullFVGs) - 1
        fv = array.get(bullFVGs, i)
        if not fv.mitigated
            box.set_right(fv.bx, bar_index + fvgExtend)

if array.size(bearFVGs) > 0
    for i = 0 to array.size(bearFVGs) - 1
        fv = array.get(bearFVGs, i)
        if not fv.mitigated
            box.set_right(fv.bx, bar_index + fvgExtend)

// ═══════════════════════════════════════════════════════════════
//  ENTRY ZONE — beginner mode
//  When price enters an active OB or FVG → flash Entry label
// ═══════════════════════════════════════════════════════════════
f_inZone(top, bot) => low <= top and high >= bot

// Bullish entry triggers
bullOBhit = false
bearOBhit = false
bullFVGhit = false
bearFVGhit = false

if array.size(bullOBs) > 0
    for i = 0 to array.size(bullOBs) - 1
        ob = array.get(bullOBs, i)
        if not ob.mitigated and f_inZone(ob.top, ob.bot)
            bullOBhit := true
            break

if array.size(bearOBs) > 0
    for i = 0 to array.size(bearOBs) - 1
        ob = array.get(bearOBs, i)
        if not ob.mitigated and f_inZone(ob.top, ob.bot)
            bearOBhit := true
            break

if array.size(bullFVGs) > 0
    for i = 0 to array.size(bullFVGs) - 1
        fv = array.get(bullFVGs, i)
        if not fv.mitigated and f_inZone(fv.top, fv.bot)
            bullFVGhit := true
            break

if array.size(bearFVGs) > 0
    for i = 0 to array.size(bearFVGs) - 1
        fv = array.get(bearFVGs, i)
        if not fv.mitigated and f_inZone(fv.top, fv.bot)
            bearFVGhit := true
            break

bullEntry = ezEnable and (
     ezRequire == "OB only"      ? bullOBhit :
     ezRequire == "FVG only"     ? bullFVGhit :
     ezRequire == "Either"       ? (bullOBhit or bullFVGhit) :
                                   (bullOBhit and bullFVGhit))

bearEntry = ezEnable and (
     ezRequire == "OB only"      ? bearOBhit :
     ezRequire == "FVG only"     ? bearFVGhit :
     ezRequire == "Either"       ? (bearOBhit or bearFVGhit) :
                                   (bearOBhit and bearFVGhit))

// Prevent spamming: only first bar that enters each zone type
bullEntryNew = bullEntry and not bullEntry[1]
bearEntryNew = bearEntry and not bearEntry[1]

plotshape(bullEntryNew, title="▲ Bull Entry Zone", style=shape.labelup, location=location.belowbar,
     color=cEntry, textcolor=color.black, size=size.normal, text="BUY\nZONE")
plotshape(bearEntryNew, title="▼ Bear Entry Zone", style=shape.labeldown, location=location.abovebar,
     color=cEntry, textcolor=color.black, size=size.normal, text="SELL\nZONE")

bgcolor(bullEntryNew ? color.new(cBullOB, 92) : na)
bgcolor(bearEntryNew ? color.new(cBearOB, 92) : na)

// ═══════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════
f_pos(p) =>
    p == "Top Right"    ? position.top_right    :
     p == "Top Left"     ? position.top_left     :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Left"  ? position.middle_left  :
     p == "Bottom Right" ? position.bottom_right :
                           position.bottom_left

f_countActive(arrOB) =>
    int n = 0
    if array.size(arrOB) > 0
        for i = 0 to array.size(arrOB) - 1
            ob = array.get(arrOB, i)
            if not ob.mitigated
                n += 1
    n

f_countActiveFVG(arrF) =>
    int n = 0
    if array.size(arrF) > 0
        for i = 0 to array.size(arrF) - 1
            fv = array.get(arrF, i)
            if not fv.mitigated
                n += 1
    n

// Live bias
biasTxt = ""
biasCol = cMute
if bullEntry
    biasTxt := "★ BUY ZONE ACTIVE"
    biasCol := cBullOB
else if bearEntry
    biasTxt := "★ SELL ZONE ACTIVE"
    biasCol := cBearOB
else if bosUp
    biasTxt := "▲ BOS — bullish break"
    biasCol := cBullOB
else if bosDown
    biasTxt := "▼ BOS — bearish break"
    biasCol := cBearOB
else
    biasTxt := "— monitoring"
    biasCol := cMute

var table dash = na
if barstate.islast and showDash
    activeBullOB  = f_countActive(bullOBs)
    activeBearOB  = f_countActive(bearOBs)
    activeBullFVG = f_countActiveFVG(bullFVGs)
    activeBearFVG = f_countActiveFVG(bearFVGs)

    dash := table.new(f_pos(dashPos), 2, 9, bgcolor=cBg, border_color=cBorder, border_width=1, frame_color=cAccent, frame_width=1)

    table.cell(dash, 0, 0, "★ AETHEREDGE  OB + FVG ★", text_color=cAccent, bgcolor=cBgAlt, text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 1, 0)

    table.cell(dash, 0, 1, "PRICE", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(close, format.mintick), text_color=cText, bgcolor=cBg, text_halign=text.align_center)

    table.cell(dash, 0, 2, "BULL OB", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(activeBullOB) + " active", text_color=color.white, bgcolor=color.new(cBullOB, 40), text_halign=text.align_center)

    table.cell(dash, 0, 3, "BEAR OB", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(activeBearOB) + " active", text_color=color.white, bgcolor=color.new(cBearOB, 40), text_halign=text.align_center)

    table.cell(dash, 0, 4, "BULL FVG", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(activeBullFVG) + " active", text_color=color.white, bgcolor=color.new(cBullFVG, 40), text_halign=text.align_center)

    table.cell(dash, 0, 5, "BEAR FVG", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(activeBearFVG) + " active", text_color=color.white, bgcolor=color.new(cBearFVG, 40), text_halign=text.align_center)

    table.cell(dash, 0, 6, "LAST BOS", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    lastBosTxt = bosUp ? "▲ UP" : bosDown ? "▼ DOWN" : "—"
    lastBosCol = bosUp ? cBullOB : bosDown ? cBearOB : cMute
    table.cell(dash, 1, 6, lastBosTxt, text_color=color.white, bgcolor=lastBosCol, text_halign=text.align_center)

    table.cell(dash, 0, 7, "SIGNAL", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 7, biasTxt, text_color=color.white, bgcolor=biasCol, text_halign=text.align_center, text_size=size.small)

    table.cell(dash, 0, 8, "MITIGATION", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 8, "OB: " + obMitigate + " / FVG: " + fvgFill, text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)

// ═══════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(bullEntryNew, "★ Bull Entry Zone", "AetherEdge: BUY zone — price tapping bullish OB/FVG")
alertcondition(bearEntryNew, "★ Bear Entry Zone", "AetherEdge: SELL zone — price tapping bearish OB/FVG")
alertcondition(bosUp,   "BOS Up",   "AetherEdge: Bullish Break of Structure")
alertcondition(bosDown, "BOS Down", "AetherEdge: Bearish Break of Structure")
````
