# AetherEdge - Smart RSI Divergence Hunter

- url: https://www.tradingview.com/script/mAd4iDWL/
- type: indicator
- pine_id: PUB;8cea45de77c846de86427b8cd3048f21
- version: 2.0

## Description

🖊️ Overview
AetherEdge Smart RSI Divergence Hunter is a next-generation divergence engine that automatically detects all four types of RSI divergences (Regular Bullish/Bearish, Hidden Bullish/Bearish) and fully integrates them with price structure (HH/HL/LH/LL) to extract only the highest-precision signals. Through three-layer verification—RSI pivot tracking, structure filtering, and OB/OS confirmation—it never misses the silent "divergence between price and momentum" the market emits. Both reversal and trend-continuation strategies are unified in a single indicator.

🔶 Key Features

Full 4-Type Divergence Coverage: Regular Bullish/Bearish + Hidden Bullish/Bearish
RSI Pivot-Based Detection: High-precision swing point identification
Price Structure Filter: Auto HH/HL/LH/LL detection for trend alignment
Intelligent OB/OS Confirmation: Regular fires in extremes, Hidden in continuation zones
Pivot Spacing Control: minBars / lookback to suppress over-detection
Type-Specific Color System: Instant 4-type identification via AetherEdge palette
Structure Markers: HH/HL/LH/LL plotted directly on chart
Star ⭐ Signals: High-conviction divergences highlighted
Auto Divergence Line Drawing: Visual representation of price/RSI divergence
Integrated Dashboard: Current structure, latest divergence, RSI status
Premium Dark Mode UI: Professional brand-themed design
🧠 Technical Architecture
This indicator evolves divergence detection from "simple discovery" to "structural confirmation" via a sophisticated engine.

Dual Pivot Tracking: ta.pivothigh/pivotlow detects pivots on RSI; latest two points (rsiPH1/PH2, rsiPL1/PL2) are recorded across price, RSI, and bar index axes.
4-Type Divergence Logic:
Regular Bullish: pxPL1 < pxPL2 AND rsiPL1 > rsiPL2 (price LL × RSI HL)
Regular Bearish: pxPH1 > pxPH2 AND rsiPH1 < rsiPH2 (price HH × RSI LH)
Hidden Bullish: pxPL1 > pxPL2 AND rsiPL1 < rsiPL2 (uptrend pullback continuation)
Hidden Bearish: pxPH1 < pxPH2 AND rsiPH1 > rsiPH2 (downtrend rally continuation)
Structure Engine: From structLen-based swing detection, the latest 2 swings are compared to dynamically determine HH/HL/LH/LL, generating isUptrend/isDowntrend.
Trend Compatibility Filter: A logically correct hierarchical filter—regular divergences require "not opposite trend" while hidden divergences require "matching trend."
OB/OS Confirmation: When requireOBOS is ON, bullish fires at rsiOS+10 or below, bearish at rsiOB-10 or above—reinforcing reversal conviction in extremes.
Pivot Spacing Control: minBars excludes adjacent pivots; lookback filters out stale divergences. Balanced noise reduction and effectiveness.
Auto Line & Label Drawing: 4-color system visualizes by type, retaining historical divergences on chart.
⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (4H–Daily): rsiLen=14, pivLeft/Right=5, structLen=20 (standard is optimal)
ETH (1H–4H): pivLeft/Right=4, lookback=80 for slightly earlier detection
SOL (High-Vol): pivLeft/Right=6, minBars=8 to exclude false divergences
XRP (Range-Heavy): requireOBOS=true, useStruct=true for strict filtering
Tuning Guide:

Day Trading: Default settings, operate 15M–1H
Swing Trading: rsiLen=21, structLen=30 for macro divergences
Scalping: pivLeft/Right=3, minBars=3 for fast short-term detection
Reversal-Focused: useRegBull/Bear=true, requireOBOS=true for max conviction
Trend-Following: useHidBull/Bear=true, useStruct=true for continuation signals
Excess Signals: minBars=10, lookback=40 to prioritize precision
Sparse Signals: useStruct=false, requireOBOS=false to relax detection
💡 How to Use in Practice

Regular Bullish + RSI ≤30: Strongest reversal setup at bottoms
Regular Bearish + RSI ≥70: Top-zone short entry candidate
Hidden Bullish + HL Structure: Perfect pullback-buy signal in uptrend continuation
Hidden Bearish + LH Structure: Rally-sell entry in downtrend continuation
Multi-Timeframe Synergy: Higher-TF structure confirmation + lower-TF divergence firing = ultimate setup
AetherEdge Synergy: Self-Evolving S/R Grid strong line + Divergence Hunter reversal signal = dual confirmation
Squeeze Breaker Fusion: Divergence forms during squeeze → directional confirmation on release = explosive entry
Double Divergence: Two consecutive same-direction divergences = ultra-high conviction—entry reinforcement
⚠️ Important Notes

Pivot Lag: pivRight bars of confirmation delay; caution with real-time unconfirmed signals
Avoid Counter-Trend in Strong Trends: Regular divergences become invalid during powerful trend continuations
Hidden Structure Dependency: With structure filter ON, no firing if not aligned with trend direction
Lookback Limit: Stale divergences are invalidated; tune accordingly on long-term charts
OB/OS Filter Trade-off: requireOBOS=true increases conviction but reduces signal count
🚨 Disclaimer
This indicator is a technical analysis tool provided for educational and research purposes only and does not constitute financial advice. Divergence detection and signal generation are probabilistic evaluations based on historical price and RSI data and do not guarantee future market behavior. All trading decisions are made at your own risk and should be accompanied by proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge - Smart RSI Divergence Hunter(alert)", "AE-RSI Divergence(alert)", overlay=true, max_lines_count=200, max_labels_count=300)

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
grpRSI = "① RSI"
rsiLen = input.int(14, "RSI Length", minval=2, group=grpRSI)
rsiOB  = input.int(70, "Overbought", minval=50, maxval=95, group=grpRSI)
rsiOS  = input.int(30, "Oversold",   minval=5,  maxval=50, group=grpRSI)

grpPIV = "② Pivot Detection"
pivLeft  = input.int(5, "Pivot Left",  minval=1, group=grpPIV)
pivRight = input.int(5, "Pivot Right", minval=1, group=grpPIV)
lookback = input.int(60, "Max Lookback Bars", minval=10, maxval=200, group=grpPIV)
minBars  = input.int(5,  "Min Bars Between Pivots", minval=2, group=grpPIV)

grpDIV = "③ Divergence Types"
useRegBull = input.bool(true, "Regular Bullish (price LL + RSI HL)", group=grpDIV)
useRegBear = input.bool(true, "Regular Bearish (price HH + RSI LH)", group=grpDIV)
useHidBull = input.bool(true, "Hidden Bullish (price HL + RSI LL)",  group=grpDIV)
useHidBear = input.bool(true, "Hidden Bearish (price LH + RSI HH)",  group=grpDIV)

grpSTR = "④ Structure Filter"
useStruct  = input.bool(true, "Require Price Structure Alignment", group=grpSTR)
structLen  = input.int(20, "Structure Swing Length", minval=5, group=grpSTR)
requireOBOS= input.bool(false, "Require RSI OB/OS at signal", group=grpSTR)

grpUI = "🎨 Display"
darkMode  = input.bool(true,  "Dark Mode", group=grpUI)
showLines = input.bool(true,  "Show Divergence Lines", group=grpUI)
showStars = input.bool(true,  "Show Star Signals", group=grpUI)
showLabels= input.bool(true,  "Show Divergence Labels", group=grpUI)
showStruct= input.bool(true,  "Show HH/HL/LH/LL Markers", group=grpUI)
showDash  = input.bool(true,  "Show Dashboard", group=grpUI)
dashPos   = input.string("Top Right", "Dashboard Position",options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=grpUI)

// ═══════════════════════════════════════════════════════════════
//  COLORS — AetherEdge palette
// ═══════════════════════════════════════════════════════════════
cBg      = darkMode ? color.new(#0b1221, 10) : color.new(#f7f9fc, 10)
cBgAlt   = darkMode ? color.new(#111a2e, 15) : color.new(#ffffff, 0)
cBorder  = darkMode ? color.new(#1f2a44, 0)  : color.new(#d8dee9, 0)
cText    = darkMode ? color.new(#e6edf7, 0)  : color.new(#1a202c, 0)
cMute    = darkMode ? color.new(#8892b0, 0)  : color.new(#64748b, 0)
cAccent  = color.new(#00d4ff, 0)

cRegBull = color.new(#00e5a0, 0)   // green  — regular bullish
cRegBear = color.new(#ff3d71, 0)   // red    — regular bearish
cHidBull = color.new(#00d4ff, 0)   // cyan   — hidden bullish
cHidBear = color.new(#ff8c42, 0)   // orange — hidden bearish
cNeutral = color.new(#5c6b7d, 0)

// ═══════════════════════════════════════════════════════════════
//  RSI
// ═══════════════════════════════════════════════════════════════
rsi = ta.rsi(close, rsiLen)

// ═══════════════════════════════════════════════════════════════
//  PIVOTS — on RSI (price references same bar)
// ═══════════════════════════════════════════════════════════════
pivHigh = ta.pivothigh(rsi, pivLeft, pivRight)
pivLow  = ta.pivotlow(rsi,  pivLeft, pivRight)

// Track last two pivot highs & lows with their price & RSI & bar index
var float rsiPH1 = na, var float rsiPH2 = na
var float pxPH1  = na, var float pxPH2  = na
var int   barPH1 = na, var int   barPH2 = na

var float rsiPL1 = na, var float rsiPL2 = na
var float pxPL1  = na, var float pxPL2  = na
var int   barPL1 = na, var int   barPL2 = na

if not na(pivHigh)
    rsiPH2 := rsiPH1
    pxPH2  := pxPH1
    barPH2 := barPH1
    rsiPH1 := pivHigh
    pxPH1  := high[pivRight]
    barPH1 := bar_index - pivRight

if not na(pivLow)
    rsiPL2 := rsiPL1
    pxPL2  := pxPL1
    barPL2 := barPL1
    rsiPL1 := pivLow
    pxPL1  := low[pivRight]
    barPL1 := bar_index - pivRight

// ═══════════════════════════════════════════════════════════════
//  PRICE STRUCTURE — HH / HL / LH / LL
// ═══════════════════════════════════════════════════════════════
swingH = ta.pivothigh(high, structLen, structLen)
swingL = ta.pivotlow(low,   structLen, structLen)

var float lastSH = na, var float prevSH = na
var float lastSL = na, var float prevSL = na
var string structState = "—"

// Structure detection booleans for alerts
isHH = false
isLH = false
isHL = false
isLL = false

if not na(swingH)
    prevSH := lastSH
    lastSH := swingH
    if not na(prevSH)
        if swingH > prevSH
            structState := "HH"
            isHH := true
        else
            structState := "LH"
            isLH := true

if not na(swingL)
    prevSL := lastSL
    lastSL := swingL
    if not na(prevSL)
        if swingL > prevSL
            structState := "HL"
            isHL := true
        else
            structState := "LL"
            isLL := true

isUptrend   = structState == "HH" or structState == "HL"
isDowntrend = structState == "LH" or structState == "LL"

// ═══════════════════════════════════════════════════════════════
//  DIVERGENCE DETECTION — evaluated when new pivot confirmed
// ═══════════════════════════════════════════════════════════════
newPH = not na(pivHigh) and not na(rsiPH2)
newPL = not na(pivLow)  and not na(rsiPL2)

validHighGap = newPH and (barPH1 - barPH2 >= minBars) and (bar_index - barPH2 <= lookback)
validLowGap  = newPL and (barPL1 - barPL2 >= minBars) and (bar_index - barPL2 <= lookback)

// Regular Bullish: price LL, RSI HL
regBullRaw = validLowGap and pxPL1 < pxPL2 and rsiPL1 > rsiPL2
// Regular Bearish: price HH, RSI LH
regBearRaw = validHighGap and pxPH1 > pxPH2 and rsiPH1 < rsiPH2
// Hidden Bullish: price HL, RSI LL (continuation in uptrend)
hidBullRaw = validLowGap and pxPL1 > pxPL2 and rsiPL1 < rsiPL2
// Hidden Bearish: price LH, RSI HH (continuation in downtrend)
hidBearRaw = validHighGap and pxPH1 < pxPH2 and rsiPH1 > rsiPH2

// OB/OS filter (optional)
obosBull = not requireOBOS or rsiPL1 <= rsiOS + 10
obosBear = not requireOBOS or rsiPH1 >= rsiOB - 10

// Structure filter
structBullOK = not useStruct or not isDowntrend   // allow neutral/uptrend for hidden, any for regular reversal
structBearOK = not useStruct or not isUptrend

// Hidden divergences REQUIRE trend alignment when structure filter on
hidBullStructOK = not useStruct or isUptrend
hidBearStructOK = not useStruct or isDowntrend

regBull = useRegBull and regBullRaw and obosBull and structBullOK
regBear = useRegBear and regBearRaw and obosBear and structBearOK
hidBull = useHidBull and hidBullRaw and obosBull and hidBullStructOK
hidBear = useHidBear and hidBearRaw and obosBear and hidBearStructOK

anyBull = regBull or hidBull
anyBear = regBear or hidBear

// ═══════════════════════════════════════════════════════════════
//  DRAW DIVERGENCE LINES & LABELS
// ═══════════════════════════════════════════════════════════════
f_drawLine(b1, p1, b2, p2, col, style) =>
    line.new(b1, p1, b2, p2, color=col, width=2, style=style)

f_drawLabel(b, p, txt, col, style) =>
    label.new(b, p, txt, style=style, color=col, textcolor=color.white, size=size.small)

if showLines and regBull
    f_drawLine(barPL2, pxPL2, barPL1, pxPL1, cRegBull, line.style_solid)
if showLines and regBear
    f_drawLine(barPH2, pxPH2, barPH1, pxPH1, cRegBear, line.style_solid)
if showLines and hidBull
    f_drawLine(barPL2, pxPL2, barPL1, pxPL1, cHidBull, line.style_dashed)
if showLines and hidBear
    f_drawLine(barPH2, pxPH2, barPH1, pxPH1, cHidBear, line.style_dashed)

if showLabels and regBull
    f_drawLabel(barPL1, pxPL1, "Reg Bull", cRegBull, label.style_label_up)
if showLabels and regBear
    f_drawLabel(barPH1, pxPH1, "Reg Bear", cRegBear, label.style_label_down)
if showLabels and hidBull
    f_drawLabel(barPL1, pxPL1, "Hid Bull", cHidBull, label.style_label_up)
if showLabels and hidBear
    f_drawLabel(barPH1, pxPH1, "Hid Bear", cHidBear, label.style_label_down)

// ═══════════════════════════════════════════════════════════════
//  STAR SIGNALS
// ═══════════════════════════════════════════════════════════════
plotshape(showStars and regBull ? low  : na, title="★ Regular Bull",
     style=shape.labelup,   location=location.belowbar, color=cRegBull, textcolor=color.white, size=size.normal, text="★", offset=-pivRight)
plotshape(showStars and regBear ? high : na, title="★ Regular Bear",
     style=shape.labeldown, location=location.abovebar, color=cRegBear, textcolor=color.white, size=size.normal, text="★", offset=-pivRight)
plotshape(showStars and hidBull ? low  : na, title="☆ Hidden Bull",
     style=shape.labelup,   location=location.belowbar, color=cHidBull, textcolor=color.white, size=size.small,  text="☆", offset=-pivRight)
plotshape(showStars and hidBear ? high : na, title="☆ Hidden Bear",
     style=shape.labeldown, location=location.abovebar, color=cHidBear, textcolor=color.white, size=size.small,  text="☆", offset=-pivRight)

// ═══════════════════════════════════════════════════════════════
//  STRUCTURE MARKERS (HH/HL/LH/LL)
// ═══════════════════════════════════════════════════════════════
if showStruct and not na(swingH) and not na(prevSH)
    sLabel = swingH > prevSH ? "HH" : "LH"
    sCol   = swingH > prevSH ? cRegBull : cRegBear
    label.new(bar_index - structLen, swingH, sLabel, style=label.style_label_down, color=color.new(sCol, 70), textcolor=color.white, size=size.tiny)

if showStruct and not na(swingL) and not na(prevSL)
    sLabel = swingL > prevSL ? "HL" : "LL"
    sCol   = swingL > prevSL ? cRegBull : cRegBear
    label.new(bar_index - structLen, swingL, sLabel, style=label.style_label_up, color=color.new(sCol, 70), textcolor=color.white, size=size.tiny)

// ═══════════════════════════════════════════════════════════════
//  BACKGROUND TINT
// ═══════════════════════════════════════════════════════════════
bgcolor(regBull ? color.new(cRegBull, 90) : na)
bgcolor(regBear ? color.new(cRegBear, 90) : na)
bgcolor(hidBull ? color.new(cHidBull, 92) : na)
bgcolor(hidBear ? color.new(cHidBear, 92) : na)

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

f_rsiZone(r) =>
    r >= rsiOB        ? "OVERBOUGHT" :
     r <= rsiOS        ? "OVERSOLD"   :
     r >= 55           ? "BULL ZONE"  :
     r <= 45           ? "BEAR ZONE"  :
                         "NEUTRAL"

f_rsiColor(r) =>
    r >= rsiOB ? cRegBear :
     r <= rsiOS ? cRegBull :
     r >= 55    ? color.new(#26a69a, 0) :
     r <= 45    ? color.new(#ef5350, 0) :
                  cNeutral

f_structColor(s) =>
    s == "HH" or s == "HL" ? cRegBull :
     s == "LH" or s == "LL" ? cRegBear :
                              cNeutral

// Current live signal status
var string liveSignal = "— no signal"
var color  liveCol    = cNeutral
if regBull
    liveSignal := "★ REGULAR BULL"
    liveCol    := cRegBull
else if regBear
    liveSignal := "★ REGULAR BEAR"
    liveCol    := cRegBear
else if hidBull
    liveSignal := "☆ HIDDEN BULL"
    liveCol    := cHidBull
else if hidBear
    liveSignal := "☆ HIDDEN BEAR"
    liveCol    := cHidBear

// Track last signal info for dashboard
var string lastSigType = "—"
var int    lastSigBar  = na
if regBull
    lastSigType := "Reg Bull"
    lastSigBar  := bar_index
if regBear
    lastSigType := "Reg Bear"
    lastSigBar  := bar_index
if hidBull
    lastSigType := "Hid Bull"
    lastSigBar  := bar_index
if hidBear
    lastSigType := "Hid Bear"
    lastSigBar  := bar_index

var table dash = na
if barstate.islast and showDash
    dash := table.new(f_pos(dashPos), 2, 9, bgcolor=cBg, border_color=cBorder, border_width=1, frame_color=cAccent, frame_width=1)

    table.cell(dash, 0, 0, "★ AETHEREDGE  DIVERGENCE HUNTER ★", text_color=cAccent, bgcolor=cBgAlt, text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 1, 0)

    // RSI value
    table.cell(dash, 0, 1, "RSI", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(rsi, "#.00"), text_color=color.white, bgcolor=f_rsiColor(rsi), text_halign=text.align_center)

    // RSI zone
    table.cell(dash, 0, 2, "ZONE", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 2, f_rsiZone(rsi), text_color=color.white, bgcolor=f_rsiColor(rsi), text_halign=text.align_center)

    // Structure
    table.cell(dash, 0, 3, "STRUCTURE", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 3, structState, text_color=color.white, bgcolor=f_structColor(structState), text_halign=text.align_center)

    // Trend bias
    trendTxt = isUptrend ? "▲ UPTREND" : isDowntrend ? "▼ DOWNTREND" : "— RANGE"
    trendCol = isUptrend ? cRegBull : isDowntrend ? cRegBear : cNeutral
    table.cell(dash, 0, 4, "TREND BIAS", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 4, trendTxt, text_color=color.white, bgcolor=trendCol, text_halign=text.align_center)

    // Live signal
    table.cell(dash, 0, 5, "SIGNAL", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 5, liveSignal, text_color=color.white, bgcolor=liveCol, text_halign=text.align_center)

    // Last signal type
    table.cell(dash, 0, 6, "LAST TYPE", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 6, lastSigType, text_color=cText, bgcolor=cBg, text_halign=text.align_center)

    // Bars since last signal
    barsSince = na(lastSigBar) ? na : bar_index - lastSigBar
    table.cell(dash, 0, 7, "BARS SINCE", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 7, na(barsSince) ? "—" : str.tostring(barsSince), text_color=cText, bgcolor=cBg, text_halign=text.align_center)

    // Active filters summary
    filtCount = (useRegBull ? 1 : 0) + (useRegBear ? 1 : 0) + (useHidBull ? 1 : 0) + (useHidBear ? 1 : 0)
    table.cell(dash, 0, 8, "SCANNING", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(filtCount) + "/4 types" + (useStruct ? " + struct" : ""), text_color=cText, bgcolor=cBg, text_halign=text.align_center)

// ═══════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════
// --- Divergence Alerts ---
alertcondition(regBull, "★ Regular Bullish",  "AetherEdge: ★ REGULAR BULLISH divergence — potential reversal UP")
alertcondition(regBear, "★ Regular Bearish",  "AetherEdge: ★ REGULAR BEARISH divergence — potential reversal DOWN")
alertcondition(hidBull, "☆ Hidden Bullish",   "AetherEdge: ☆ HIDDEN BULLISH divergence — trend continuation UP")
alertcondition(hidBear, "☆ Hidden Bearish",   "AetherEdge: ☆ HIDDEN BEARISH divergence — trend continuation DOWN")
alertcondition(anyBull, "Any Bullish Signal", "AetherEdge: Bullish divergence detected")
alertcondition(anyBear, "Any Bearish Signal", "AetherEdge: Bearish divergence detected")

// --- Structure Marker Alerts (HH / HL / LH / LL) ---
alertcondition(isHH, "Structure: HH (Higher High)", "AetherEdge: Structure — HIGHER HIGH detected (bullish continuation)")
alertcondition(isHL, "Structure: HL (Higher Low)",  "AetherEdge: Structure — HIGHER LOW detected (bullish continuation)")
alertcondition(isLH, "Structure: LH (Lower High)",  "AetherEdge: Structure — LOWER HIGH detected (bearish continuation)")
alertcondition(isLL, "Structure: LL (Lower Low)",   "AetherEdge: Structure — LOWER LOW detected (bearish continuation)")
alertcondition(isHH or isHL, "Structure: Any Bullish (HH or HL)", "AetherEdge: Structure — Bullish structure detected (HH or HL)")
alertcondition(isLH or isLL, "Structure: Any Bearish (LH or LL)", "AetherEdge: Structure — Bearish structure detected (LH or LL)")
alertcondition(isHH or isHL or isLH or isLL, "Structure: Any Change", "AetherEdge: Structure — New structure marker detected")
````
