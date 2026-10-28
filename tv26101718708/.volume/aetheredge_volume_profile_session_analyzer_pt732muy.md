# AetherEdge - Volume Profile Session Analyzer

- url: https://www.tradingview.com/script/pt732MUy/
- type: indicator
- pine_id: PUB;366867833888486a98bcb92723eaf035
- version: 1.0

## Description

🖊️ Overview
AetherEdge Volume Profile Session Analyzer is a professional-grade session analysis engine that constructs independent volume profiles for the three major global sessions—Asia / London / New York. It computes and visualizes POC (Point of Control), VAH (Value Area High), and VAL (Value Area Low) for each session in real time, clearly mapping the institutional trading concentration zones. This is a world-class market structure analysis tool that captures distinct liquidity layers across timezones.

🔶 Key Features

3-Session Independent Profiling: Constructs separate volume distributions for Asia / London / NY
Dynamic POC / VAH / VAL Calculation: Extracts institutional zones from price×volume heatmaps
Customizable Resolution: 10–150 bin precision grid for adjustable analytical granularity
Adjustable Value Area %: Define trading concentration zone with 50–95% custom setting
Session Background Shading: Instant visual identification of time periods
Previous Session Level Extension: Project past POC/VA levels forward as S/R
Timezone Support: GMT, Exchange, NY, London, Tokyo selectable
Integrated Dashboard: One-glance display of key levels across 3 sessions
AetherEdge Premium UI: Dark mode support, refined color palette

🧠 Technical Architecture

This indicator is an advanced market microstructure analysis system that decomposes Volume Profile theory along the time axis (sessions).

Session Detection Logic: Timezone-aware session judgment via time(timeframe.period, sessionStr, tzStr). Start/End edge detection captures precise session boundaries.
Bin Array Architecture: Each session maintains an independent array<float> volume bin. Auto-resets at session start, archived as finalized values at end.
Volume Distribution Algorithm:
Splits each bar's price range (high-low) into corresponding bins within session range
binSize = sessionRange / bins calculates each bin's price width
perBin = barVolume / nCells evenly distributes bar volume across relevant bins
Results in true price-by-volume distribution
POC Calculation: Extracts maximum value index from bin array, identifies the price level with highest trading concentration
Value Area Calculation: Expands up/down from POC until cumulative volume reaches vaPct (default 70%). Defines the consensus zone of market participants.
Dynamic Range Update: hiRef = max(prevHi, currentHigh) continuously tracks session highs/lows
Persistence Management: var variables retain previous session values, drawing extension lines after session ends
Multi-Object Management: array<box>, array<line>, array<label> integrate drawing objects per session

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults (24/7 markets):

BTC (1H–4H): bins=50, vaPct=70, high precision standard
ETH (15M–1H): bins=70 for high-resolution profile
SOL (high-vol): bins=40 for smoothing, noise reduction
XRP (mixed liquidity): bins=60, vaPct=68
Timezone Recommendations:

Crypto: GMT for global standard analysis
Stock CFDs: Exchange TZ
FX: America/New_York for major session sync
Tuning Guide:

Detailed Analysis: bins=100+ for precise institutional order detection
Macro View: bins=30 to extract major zones only
Wide VA: vaPct=80 for breakout point identification
Narrow VA: vaPct=60 for core zone clarity
Day Trading: extendPrev=true to leverage prior session boundaries
Swing: profileWidth=50 for enhanced visibility

💡 How to Use in Practice

POC Touch Reaction: Institutional position concentration zone—critical for pullback long / rebound short
VAH/VAL Break: Value Area breakthrough is a strong new trend initiation signal
Session Transition: Use POC position at London→NY handoff for day-trade direction bias
Asia POC Utility: Critical S/R during European/American sessions, range-trade baseline
VA Overlap Zones: Price areas where multiple session VAs coincide = ultra-strong S/R
Naked POC: Untested POCs act as future magnetic targets
AetherEdge Synergy:
Self-Evolving S/R Grid strong line + session POC alignment = ultra-high-conviction zone
Hull MA Ribbon Strong Bull + VAH break = perfect long entry
Order Block Detector OB + previous session VAL = institutional accumulation zone
Multi-TF Application: Confirm session VA on 4H chart → precision entry on 15M

⚠️ Important Notes

Session Time Configuration: Manual adjustment recommended at DST transitions
Initial Data Accumulation: Requires at least one completed session before display
Low-Volume Symbols: Profile precision degrades; reduce bin count
Bin Resolution Trade-off: Higher resolution = more precision but heavier rendering
Timezone Consistency: GMT/Exchange misconfiguration causes session boundary drift
max_boxes_count Limit: Old sessions auto-deleted on long-term display

🚨 Disclaimer

This indicator is a technical analysis tool provided for educational and research purposes only and does not constitute financial advice. Volume profile and session analysis is statistical visualization based on historical market data and does not guarantee future price behavior. All trading decisions are made at your own risk and should be accompanied by proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge - Volume Profile Session Analyzer", "AE-VP Sessions", overlay=true,
     max_boxes_count=500, max_lines_count=500, max_labels_count=100)

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
grpS = "① Sessions (Exchange Time)"
asiaSess     = input.session("2100-0600", "Asia Session",    group=grpS)
londonSess   = input.session("0700-1600", "London Session",  group=grpS)
nySess       = input.session("1300-2200", "New York Session",group=grpS)
tz           = input.string("GMT",        "Timezone",        options=["GMT","Exchange","America/New_York","Europe/London","Asia/Tokyo"], group=grpS)

grpVP = "② Volume Profile"
bins         = input.int(50,   "Profile Rows (resolution)", minval=10, maxval=150, group=grpVP)
vaPct        = input.float(70.0, "Value Area %",            minval=50.0, maxval=95.0, step=1.0, group=grpVP)
profileWidth = input.int(30,   "Profile Width (bars)",      minval=5,   maxval=80, group=grpVP)

grpD = "③ Display Per Session"
showAsia     = input.bool(true, "Show Asia Profile",   group=grpD, inline="a")
showLondon   = input.bool(true, "Show London Profile", group=grpD, inline="l")
showNY       = input.bool(true, "Show NY Profile",     group=grpD, inline="n")
showPOC      = input.bool(true, "Show POC",   group=grpD, inline="poc")
showVA       = input.bool(true, "Show VAH/VAL", group=grpD, inline="poc")
showBG       = input.bool(true, "Shade Session Background", group=grpD)
extendPrev   = input.bool(true, "Extend Previous Session Levels", group=grpD)

grpC = "🎨 Colors"
darkMode     = input.bool(true, "Dark Mode", group=grpC)
asiaCol      = input.color(#ffa94d, "Asia",   group=grpC, inline="c1")
londonCol    = input.color(#4dabf7, "London", group=grpC, inline="c1")
nyCol        = input.color(#51cf66, "NY",     group=grpC, inline="c1")

grpT = "📊 Dashboard"
showDash     = input.bool(true, "Show Dashboard", group=grpT)
dashPos      = input.string("Top Right", "Position",
               options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=grpT)

// ═══════════════════════════════════════════════════════════════
//  PALETTE
// ═══════════════════════════════════════════════════════════════
cBg     = darkMode ? color.new(#0b1221, 10) : color.new(#f7f9fc, 10)
cBgAlt  = darkMode ? color.new(#111a2e, 15) : color.new(#ffffff, 0)
cBorder = darkMode ? color.new(#1f2a44, 0)  : color.new(#d8dee9, 0)
cText   = darkMode ? color.new(#e6edf7, 0)  : color.new(#1a202c, 0)
cMute   = darkMode ? color.new(#8892b0, 0)  : color.new(#64748b, 0)
cAccent = color.new(#00d4ff, 0)

// ═══════════════════════════════════════════════════════════════
//  SESSION DETECTION
// ═══════════════════════════════════════════════════════════════
tzStr = tz == "Exchange" ? syminfo.timezone : tz

f_inSess(sp) =>
    not na(time(timeframe.period, sp, tzStr))

inAsia   = f_inSess(asiaSess)
inLondon = f_inSess(londonSess)
inNY     = f_inSess(nySess)

asiaStart   = inAsia   and not inAsia[1]
asiaEnd     = not inAsia   and inAsia[1]
londonStart = inLondon and not inLondon[1]
londonEnd   = not inLondon and inLondon[1]
nyStart     = inNY     and not inNY[1]
nyEnd       = not inNY     and inNY[1]

// ═══════════════════════════════════════════════════════════════
//  PER-SESSION STATE (accumulators)
// ═══════════════════════════════════════════════════════════════
// Each session keeps: start time, start bar, hi, lo, vol bins array
var array<float> asiaBins   = array.new_float(bins, 0.0)
var array<float> londonBins = array.new_float(bins, 0.0)
var array<float> nyBins     = array.new_float(bins, 0.0)

var float asiaHi = na, var float asiaLo = na
var float londonHi = na, var float londonLo = na
var float nyHi = na, var float nyLo = na

var int asiaStartTime = na, var int asiaStartBar = na
var int londonStartTime = na, var int londonStartBar = na
var int nyStartTime = na, var int nyStartBar = na

// Finalized previous session values (shown as reference lines)
var float prevAsiaPOC = na, var float prevAsiaVAH = na, var float prevAsiaVAL = na, var int prevAsiaEndTime = na
var float prevLondonPOC = na, var float prevLondonVAH = na, var float prevLondonVAL = na, var int prevLondonEndTime = na
var float prevNYPOC = na, var float prevNYVAH = na, var float prevNYVAL = na, var int prevNYEndTime = na

// Previous session boxes storage for redraw
var array<box>   asiaBoxes   = array.new_box()
var array<line>  asiaLines   = array.new_line()
var array<label> asiaLabels  = array.new_label()
var array<box>   londonBoxes = array.new_box()
var array<line>  londonLines = array.new_line()
var array<label> londonLabels= array.new_label()
var array<box>   nyBoxes     = array.new_box()
var array<line>  nyLines     = array.new_line()
var array<label> nyLabels    = array.new_label()

// Previous-session extended lines (persistent)
var line extAsiaPOC = na, var line extAsiaVAH = na, var line extAsiaVAL = na
var line extLondonPOC = na, var line extLondonVAH = na, var line extLondonVAL = na
var line extNYPOC = na, var line extNYVAH = na, var line extNYVAL = na

// ═══════════════════════════════════════════════════════════════
//  RESET HANDLERS (at session start)
// ═══════════════════════════════════════════════════════════════
f_resetBins(arr) =>
    for i = 0 to array.size(arr) - 1
        array.set(arr, i, 0.0)

if asiaStart
    f_resetBins(asiaBins)
    asiaHi := high
    asiaLo := low
    asiaStartTime := time
    asiaStartBar := bar_index

if londonStart
    f_resetBins(londonBins)
    londonHi := high
    londonLo := low
    londonStartTime := time
    londonStartBar := bar_index

if nyStart
    f_resetBins(nyBins)
    nyHi := high
    nyLo := low
    nyStartTime := time
    nyStartBar := bar_index

// ═══════════════════════════════════════════════════════════════
//  ACCUMULATE VOLUME INTO BINS (during active session)
// ═══════════════════════════════════════════════════════════════
f_addBar(arr, hiRef, loRef, h, l, v, nBins) =>
    if not na(hiRef) and not na(loRef) and hiRef > loRef and v > 0
        rng = hiRef - loRef
        binSize = rng / nBins
        // distribute bar's volume across its price range
        barLo = math.max(l, loRef)
        barHi = math.min(h, hiRef)
        if barHi > barLo
            loIdx = math.max(0, math.floor((barLo - loRef) / binSize))
            hiIdx = math.min(nBins - 1, math.floor((barHi - loRef) / binSize))
            nCells = hiIdx - loIdx + 1
            perBin = v / nCells
            for i = loIdx to hiIdx
                array.set(arr, i, array.get(arr, i) + perBin)

// Update range & bins for active sessions
if inAsia
    asiaHi := math.max(nz(asiaHi, high), high)
    asiaLo := math.min(nz(asiaLo, low),  low)
    f_addBar(asiaBins, asiaHi, asiaLo, high, low, volume, bins)

if inLondon
    londonHi := math.max(nz(londonHi, high), high)
    londonLo := math.min(nz(londonLo, low),  low)
    f_addBar(londonBins, londonHi, londonLo, high, low, volume, bins)

if inNY
    nyHi := math.max(nz(nyHi, high), high)
    nyLo := math.min(nz(nyLo, low),  low)
    f_addBar(nyBins, nyHi, nyLo, high, low, volume, bins)

// ═══════════════════════════════════════════════════════════════
//  CORE: compute POC / VAH / VAL from bin array
// ═══════════════════════════════════════════════════════════════
f_computeVA(arr, hiRef, loRef, vaTarget) =>
    n = array.size(arr)
    binSize = (hiRef - loRef) / n
    totalVol = array.sum(arr)
    pocIdx = 0
    pocVol = 0.0
    for i = 0 to n - 1
        v = array.get(arr, i)
        if v > pocVol
            pocVol := v
            pocIdx := i
    // Value Area expansion: start at POC, expand outward to adjacent pair of bins with larger sum
    target = totalVol * vaTarget / 100.0
    accum = pocVol
    upIdx = pocIdx
    dnIdx = pocIdx
    while accum < target and (upIdx < n - 1 or dnIdx > 0)
        upPair = 0.0
        dnPair = 0.0
        if upIdx < n - 1
            upPair := array.get(arr, upIdx + 1) + (upIdx + 2 <= n - 1 ? array.get(arr, upIdx + 2) : 0.0)
        if dnIdx > 0
            dnPair := array.get(arr, dnIdx - 1) + (dnIdx - 2 >= 0 ? array.get(arr, dnIdx - 2) : 0.0)
        if upPair >= dnPair and upIdx < n - 1
            stepN = math.min(2, n - 1 - upIdx)
            for k = 1 to stepN
                accum += array.get(arr, upIdx + k)
            upIdx += stepN
        else if dnIdx > 0
            stepN = math.min(2, dnIdx)
            for k = 1 to stepN
                accum += array.get(arr, dnIdx - k)
            dnIdx -= stepN
        else
            break
    pocPrice = loRef + (pocIdx + 0.5) * binSize
    vahPrice = loRef + (upIdx + 1) * binSize
    valPrice = loRef + dnIdx * binSize
    [pocPrice, vahPrice, valPrice, pocVol, totalVol]

// ═══════════════════════════════════════════════════════════════
//  DRAW: volume profile histogram as boxes at session end
// ═══════════════════════════════════════════════════════════════
f_clearBoxes(arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            box.delete(array.get(arr, i))
        array.clear(arr)

f_clearLines(arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            line.delete(array.get(arr, i))
        array.clear(arr)

f_clearLabels(arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            label.delete(array.get(arr, i))
        array.clear(arr)

f_drawProfile(arr, hiRef, loRef, startBar, endBar, widthBars, baseCol, poc, vah, val, boxes, lines, labels, sessName, showP, showV) =>
    n = array.size(arr)
    if n > 0 and not na(hiRef) and not na(loRef) and hiRef > loRef
        binSize = (hiRef - loRef) / n
        maxV = 0.0
        for i = 0 to n - 1
            v = array.get(arr, i)
            if v > maxV
                maxV := v
        // Anchor profile at session end bar, extending to the right
        xStart = endBar
        xMax = endBar + widthBars
        for i = 0 to n - 1
            v = array.get(arr, i)
            if v > 0 and maxV > 0
                w = math.round(widthBars * v / maxV)
                if w >= 1
                    binLo = loRef + i * binSize
                    binHi = loRef + (i + 1) * binSize
                    // POC bin uses stronger color, VA bins medium, outside VA faded
                    binMid = (binLo + binHi) / 2
                    isPOC = binMid >= (poc - binSize/2) and binMid <= (poc + binSize/2)
                    inVA  = binMid >= val and binMid <= vah
                    fillCol = isPOC ? color.new(baseCol, 15) : inVA ? color.new(baseCol, 55) : color.new(baseCol, 80)
                    b = box.new(xStart, binHi, xStart + w, binLo,
                         border_color=color.new(baseCol, 90), bgcolor=fillCol, border_width=1)
                    array.push(boxes, b)

        // POC / VAH / VAL horizontal rays across session range
        if showP
            l = line.new(startBar, poc, xMax, poc, color=color.new(baseCol, 0), width=2, style=line.style_solid)
            array.push(lines, l)
            lb = label.new(xMax, poc, sessName + " POC " + str.tostring(poc, format.mintick),
                 color=color.new(baseCol, 20), textcolor=color.white, style=label.style_label_left, size=size.small)
            array.push(labels, lb)
        if showV
            l1 = line.new(startBar, vah, xMax, vah, color=color.new(baseCol, 30), width=1, style=line.style_dashed)
            array.push(lines, l1)
            l2 = line.new(startBar, val, xMax, val, color=color.new(baseCol, 30), width=1, style=line.style_dashed)
            array.push(lines, l2)
            lb1 = label.new(xMax, vah, sessName + " VAH " + str.tostring(vah, format.mintick),
                  color=color.new(baseCol, 50), textcolor=color.white, style=label.style_label_left, size=size.tiny)
            array.push(labels, lb1)
            lb2 = label.new(xMax, val, sessName + " VAL " + str.tostring(val, format.mintick),
                  color=color.new(baseCol, 50), textcolor=color.white, style=label.style_label_left, size=size.tiny)
            array.push(labels, lb2)

// ═══════════════════════════════════════════════════════════════
//  FINALIZE AT SESSION END
// ═══════════════════════════════════════════════════════════════
if asiaEnd and showAsia and not na(asiaHi) and not na(asiaLo) and asiaHi > asiaLo
    [poc, vah, val, pv, tv] = f_computeVA(asiaBins, asiaHi, asiaLo, vaPct)
    prevAsiaPOC := poc
    prevAsiaVAH := vah
    prevAsiaVAL := val
    prevAsiaEndTime := time
    f_clearBoxes(asiaBoxes)
    f_clearLines(asiaLines)
    f_clearLabels(asiaLabels)
    f_drawProfile(asiaBins, asiaHi, asiaLo, asiaStartBar, bar_index, profileWidth, asiaCol,
         poc, vah, val, asiaBoxes, asiaLines, asiaLabels, "ASIA", showPOC, showVA)

if londonEnd and showLondon and not na(londonHi) and not na(londonLo) and londonHi > londonLo
    [poc, vah, val, pv, tv] = f_computeVA(londonBins, londonHi, londonLo, vaPct)
    prevLondonPOC := poc
    prevLondonVAH := vah
    prevLondonVAL := val
    prevLondonEndTime := time
    f_clearBoxes(londonBoxes)
    f_clearLines(londonLines)
    f_clearLabels(londonLabels)
    f_drawProfile(londonBins, londonHi, londonLo, londonStartBar, bar_index, profileWidth, londonCol,
         poc, vah, val, londonBoxes, londonLines, londonLabels, "LON", showPOC, showVA)

if nyEnd and showNY and not na(nyHi) and not na(nyLo) and nyHi > nyLo
    [poc, vah, val, pv, tv] = f_computeVA(nyBins, nyHi, nyLo, vaPct)
    prevNYPOC := poc
    prevNYVAH := vah
    prevNYVAL := val
    prevNYEndTime := time
    f_clearBoxes(nyBoxes)
    f_clearLines(nyLines)
    f_clearLabels(nyLabels)
    f_drawProfile(nyBins, nyHi, nyLo, nyStartBar, bar_index, profileWidth, nyCol,
         poc, vah, val, nyBoxes, nyLines, nyLabels, "NY", showPOC, showVA)

// ═══════════════════════════════════════════════════════════════
//  EXTEND PREVIOUS-SESSION LEVELS (dotted rays)
// ═══════════════════════════════════════════════════════════════
if barstate.islast and extendPrev
    if not na(prevAsiaPOC)
        line.delete(extAsiaPOC)
        line.delete(extAsiaVAH)
        line.delete(extAsiaVAL)
        extAsiaPOC := line.new(bar_index - 200, prevAsiaPOC, bar_index + 20, prevAsiaPOC, color=color.new(asiaCol, 40), width=1, style=line.style_dotted)
        extAsiaVAH := line.new(bar_index - 200, prevAsiaVAH, bar_index + 20, prevAsiaVAH, color=color.new(asiaCol, 60), width=1, style=line.style_dotted)
        extAsiaVAL := line.new(bar_index - 200, prevAsiaVAL, bar_index + 20, prevAsiaVAL, color=color.new(asiaCol, 60), width=1, style=line.style_dotted)
    if not na(prevLondonPOC)
        line.delete(extLondonPOC)
        line.delete(extLondonVAH)
        line.delete(extLondonVAL)
        extLondonPOC := line.new(bar_index - 200, prevLondonPOC, bar_index + 20, prevLondonPOC, color=color.new(londonCol, 40), width=1, style=line.style_dotted)
        extLondonVAH := line.new(bar_index - 200, prevLondonVAH, bar_index + 20, prevLondonVAH, color=color.new(londonCol, 60), width=1, style=line.style_dotted)
        extLondonVAL := line.new(bar_index - 200, prevLondonVAL, bar_index + 20, prevLondonVAL, color=color.new(londonCol, 60), width=1, style=line.style_dotted)
    if not na(prevNYPOC)
        line.delete(extNYPOC)
        line.delete(extNYVAH)
        line.delete(extNYVAL)
        extNYPOC := line.new(bar_index - 200, prevNYPOC, bar_index + 20, prevNYPOC, color=color.new(nyCol, 40), width=1, style=line.style_dotted)
        extNYVAH := line.new(bar_index - 200, prevNYVAH, bar_index + 20, prevNYVAH, color=color.new(nyCol, 60), width=1, style=line.style_dotted)
        extNYVAL := line.new(bar_index - 200, prevNYVAL, bar_index + 20, prevNYVAL, color=color.new(nyCol, 60), width=1, style=line.style_dotted)

// ═══════════════════════════════════════════════════════════════
//  SESSION BACKGROUND SHADING
// ═══════════════════════════════════════════════════════════════
bgcolor(showBG and inAsia   and showAsia   ? color.new(asiaCol,   93) : na, title="Asia BG")
bgcolor(showBG and inLondon and showLondon ? color.new(londonCol, 93) : na, title="London BG")
bgcolor(showBG and inNY     and showNY     ? color.new(nyCol,     93) : na, title="NY BG")

// ═══════════════════════════════════════════════════════════════
//  LIVE INTRADAY POC/VAH/VAL (current active session)
// ═══════════════════════════════════════════════════════════════
var line liveP = na, var line liveVH = na, var line liveVL = na
var label liveLbl = na

if barstate.islast
    line.delete(liveP)
    line.delete(liveVH)
    line.delete(liveVL)
    label.delete(liveLbl)

    activeArr   = inAsia ? asiaBins : inLondon ? londonBins : inNY ? nyBins : na
    activeHi    = inAsia ? asiaHi   : inLondon ? londonHi   : inNY ? nyHi   : na
    activeLo    = inAsia ? asiaLo   : inLondon ? londonLo   : inNY ? nyLo   : na
    activeStart = inAsia ? asiaStartBar : inLondon ? londonStartBar : inNY ? nyStartBar : na
    activeCol   = inAsia ? asiaCol  : inLondon ? londonCol  : inNY ? nyCol  : cAccent
    activeName  = inAsia ? "ASIA (live)" : inLondon ? "LON (live)" : inNY ? "NY (live)" : ""

    if not na(activeHi) and not na(activeLo) and activeHi > activeLo and array.sum(activeArr) > 0
        [lpoc, lvah, lval, _pv, _tv] = f_computeVA(activeArr, activeHi, activeLo, vaPct)
        liveP  := line.new(activeStart, lpoc, bar_index + 30, lpoc, color=color.new(activeCol, 0),  width=3, style=line.style_solid)
        liveVH := line.new(activeStart, lvah, bar_index + 30, lvah, color=color.new(activeCol, 40), width=1, style=line.style_dashed)
        liveVL := line.new(activeStart, lval, bar_index + 30, lval, color=color.new(activeCol, 40), width=1, style=line.style_dashed)
        liveLbl:= label.new(bar_index + 30, lpoc, activeName + " POC " + str.tostring(lpoc, format.mintick),
                  color=color.new(activeCol, 20), textcolor=color.white, style=label.style_label_left, size=size.small)

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

var table dash = na
if barstate.islast and showDash
    dash := table.new(f_pos(dashPos), 5, 7, bgcolor=cBg, border_color=cBorder, border_width=1, frame_color=cAccent, frame_width=1)

    // Header
    table.cell(dash, 0, 0, "★ AETHEREDGE  VP SESSIONS ★", text_color=cAccent, bgcolor=cBgAlt, text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 4, 0)

    // Column headers
    table.cell(dash, 0, 1, "SESSION",  text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 1, "STATUS",   text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_center)
    table.cell(dash, 2, 1, "POC",      text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_center)
    table.cell(dash, 3, 1, "VAH",      text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_center)
    table.cell(dash, 4, 1, "VAL",      text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_center)

    // Asia row
    aStat = inAsia ? "● LIVE" : not na(prevAsiaPOC) ? "◌ CLOSED" : "— N/A"
    aStatCol = inAsia ? asiaCol : cMute
    table.cell(dash, 0, 2, "🌏 ASIA",  text_color=color.white, bgcolor=color.new(asiaCol, 50), text_halign=text.align_left)
    table.cell(dash, 1, 2, aStat,      text_color=color.white, bgcolor=color.new(aStatCol, 40), text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 2, na(prevAsiaPOC) ? "—" : str.tostring(prevAsiaPOC, format.mintick), text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 3, 2, na(prevAsiaVAH) ? "—" : str.tostring(prevAsiaVAH, format.mintick), text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 4, 2, na(prevAsiaVAL) ? "—" : str.tostring(prevAsiaVAL, format.mintick), text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)

    // London row
    lStat = inLondon ? "● LIVE" : not na(prevLondonPOC) ? "◌ CLOSED" : "— N/A"
    lStatCol = inLondon ? londonCol : cMute
    table.cell(dash, 0, 3, "🇬🇧 LONDON",text_color=color.white, bgcolor=color.new(londonCol, 50), text_halign=text.align_left)
    table.cell(dash, 1, 3, lStat,       text_color=color.white, bgcolor=color.new(lStatCol, 40), text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 3, na(prevLondonPOC) ? "—" : str.tostring(prevLondonPOC, format.mintick), text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 3, 3, na(prevLondonVAH) ? "—" : str.tostring(prevLondonVAH, format.mintick), text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 4, 3, na(prevLondonVAL) ? "—" : str.tostring(prevLondonVAL, format.mintick), text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)

    // NY row
    nStat = inNY ? "● LIVE" : not na(prevNYPOC) ? "◌ CLOSED" : "— N/A"
    nStatCol = inNY ? nyCol : cMute
    table.cell(dash, 0, 4, "🇺🇸 NEW YORK", text_color=color.white, bgcolor=color.new(nyCol, 50), text_halign=text.align_left)
    table.cell(dash, 1, 4, nStat,          text_color=color.white, bgcolor=color.new(nStatCol, 40), text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 4, na(prevNYPOC) ? "—" : str.tostring(prevNYPOC, format.mintick), text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 3, 4, na(prevNYVAH) ? "—" : str.tostring(prevNYVAH, format.mintick), text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 4, 4, na(prevNYVAL) ? "—" : str.tostring(prevNYVAL, format.mintick), text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)

    // Current price vs POC distance
    refPOC = inNY ? prevNYPOC : inLondon ? prevLondonPOC : inAsia ? prevAsiaPOC : prevNYPOC
    distTxt = na(refPOC) ? "—" : str.tostring((close - refPOC) / syminfo.mintick, "#") + " ticks"
    distCol = na(refPOC) ? cMute : close > refPOC ? color.new(#00d4a0, 0) : color.new(#ff5577, 0)
    table.cell(dash, 0, 5, "PRICE vs PREV POC", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.merge_cells(dash, 0, 5, 2, 5)
    table.cell(dash, 3, 5, distTxt, text_color=color.white, bgcolor=color.new(distCol, 40), text_halign=text.align_center, text_size=size.small)
    table.merge_cells(dash, 3, 5, 4, 5)

    // Profile config summary
    table.cell(dash, 0, 6, "CONFIG", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(bins) + " bins", text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 6, "VA " + str.tostring(vaPct, "#") + "%", text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 3, 6, tzStr, text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)
    table.merge_cells(dash, 3, 6, 4, 6)

// ═══════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(asiaEnd,   "Asia Session Closed",   "AetherEdge: Asia VP finalized (POC/VAH/VAL ready)")
alertcondition(londonEnd, "London Session Closed", "AetherEdge: London VP finalized")
alertcondition(nyEnd,     "NY Session Closed",     "AetherEdge: NY VP finalized")

crossPrevAsiaPOC   = not na(prevAsiaPOC)   and (ta.crossover(close, prevAsiaPOC)   or ta.crossunder(close, prevAsiaPOC))
crossPrevLondonPOC = not na(prevLondonPOC) and (ta.crossover(close, prevLondonPOC) or ta.crossunder(close, prevLondonPOC))
crossPrevNYPOC     = not na(prevNYPOC)     and (ta.crossover(close, prevNYPOC)     or ta.crossunder(close, prevNYPOC))

alertcondition(crossPrevAsiaPOC,   "Cross Asia POC",   "AetherEdge: Price crossed previous Asia POC")
alertcondition(crossPrevLondonPOC, "Cross London POC", "AetherEdge: Price crossed previous London POC")
alertcondition(crossPrevNYPOC,     "Cross NY POC",     "AetherEdge: Price crossed previous NY POC")
````
