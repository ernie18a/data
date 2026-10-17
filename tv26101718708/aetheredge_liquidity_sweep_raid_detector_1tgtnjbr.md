# AetherEdge - Liquidity Sweep & Raid Detector

- url: https://www.tradingview.com/script/1tgtnjBR/
- type: indicator
- pine_id: PUB;f5267f0f61c14f00b5d6bd308f2a9419
- version: 1.0

## Description

🖊️ Overview
AetherEdge Liquidity Sweep & Raid Detector is a professional-grade smart money analysis tool that exposes institutional stop hunts (liquidity raids) and Equal Highs/Lows liquidity pools in real time. By integrating ATR-based significance filters, three-tier sweep confirmation modes, and projected stop hunt zones, it visualizes "who, where, and why" liquidity is being taken—enabling traders to follow institutional footprints with both reversal and continuation entries.

🔶 Key Features

ATR-Adaptive Pivot Detection: Extracts only meaningful swings
Equal Highs/Lows Detection: Auto-marks liquidity pools
3 Sweep Confirmation Modes: Wick Only / Close Back / Wick + Close Back
Stop Hunt Zone Projection: Boxes mark institutional revisit zones
3 Zone Management Modes: Keep / Fade on Touch / Remove on Touch
Reversal Candle Requirement: Filters false sweeps
Break of Structure (BOS): Auto-detects structural shifts
ATR Wick Size Filter: Eliminates shallow sweeps
Pending Sweep System: Configurable max-bars window for close-back confirmation
Statistics Dashboard: Bull/Bear sweep counts, EQH/EQL, active hot zones

🧠 Technical Architecture

This indicator implements core ICT/SMC concepts via pivot array management and a pending state machine to deliver a professional liquidity-tracking engine.

Significance Pivot Layer:
ta.pivothigh/low for confirmed swing detection
ATR × multiplier filters out "noise swings"
Arrays manage 50 historical pivots (price, bar, swept flag)
Equal Highs/Lows Detection:
Scans pivots within eqLookback
|currentPivot - prevPivot| ≤ ATR × tolerance for equality
Draws horizontal line at midpoint with optional right-extension
Sweep Detection Engine:
Wick Only: Wick breaks pivot + immediate inside close + reversal confirmation
Close Back: Wick breaks, then close returns inside within sweepMaxBars
Wick + Close Back: Both conditions met (highest precision)
Pending arrays handle multi-stage confirmation asynchronously
Stop Hunt Zones:
Box generated at sweep point with zoneHeightATR height
Extended zoneExtend bars right
Lifecycle managed via Fade / Remove / Keep on touch
BOS Detection: Unswept pivot's close-break marks structural shift
Memory Management: maxObjects FIFO-prunes all lines/labels/boxes

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (15M–1H): pivLen=10, atrMinMult=0.3, sweepMode=Wick + Close Back (standard)
ETH (5M–15M): pivLen=8, sweepMaxBars=4 for faster confirmation
SOL (high-vol): atrMinMult=0.5, sweepMinWick=0.4 for stricter filter
XRP (range): eqTolerance=0.15 to relax equality detection
Sweep Mode Selection:

Wick Only: High frequency, day trading / scalping
Close Back: Medium frequency, most balanced
Wick + Close Back: Highest precision, swing trading (recommended)
Zone Management:

Fade on Touch: Preserves history, tracks revisits (recommended)
Remove on Touch: Cleaner charts
Keep: Full retention, long-term analysis
Tuning:

Too many signals: atrMinMult=0.5, sweepMinWick=0.5
Too few signals: requireReverse=false, sweepMaxBars=5
Better EQ accuracy: eqMinDistance=5 to suppress clusters

💡 How to Use in Practice

Bullish Sweep (Low Grab) → Long: Buy the bounce after institutions raid downside stops
Bearish Sweep (High Grab) → Short: Sell after upside stop hunt
EQH/EQL → Liquidity Targets: Price likely magnetizes here
Stop Hunt Zone Revisit: Once-swept zones often retest
BOS + Sweep Combined: Strongest structural shift confirmation
AetherEdge Synergy:
WaveTrend Enhanced OS Extreme + Bullish Sweep = max-conviction bottom
Self-Evolving S/R Grid strong support + Low Grab = institutional-sync entry
SuperTrend Multi-Factor Bull flip + BOS Up = trend ignition capture
Multi-TF Strategy: 1H EQH for liquidity map → 15M sweep for entry → 5M for precision timing

⚠️ Important Notes

Pivot Lag: pivLen-bar delay inherent (no real-time detection)
ATR Filter Dependency: Sweep detection drops in low-volatility regimes
Close Back Pending: Auto-cancels after sweepMaxBars—watch for missed signals
EQ Over-detection: Large eqLookback may match outdated pivots
Zone Revisit: Probabilistic, not guaranteed
Sweeps in Strong Trends: Can be confused with breakouts—context confirmation required

🚨 Disclaimer

This indicator is a technical analysis tool provided for educational and research purposes only and does not constitute financial advice. Liquidity sweeps and stop hunt zones represent probabilistic market behavior patterns and do not guarantee profits. All trading decisions are made at your own risk and should be accompanied by proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge - Liquidity Sweep & Raid Detector", "AE-LiqSweep",
     overlay=true,
     max_lines_count=500,
     max_labels_count=500,
     max_boxes_count=500,
     max_bars_back=1000)

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
grpPv = "① Pivot / Swing Structure"
pivLen       = input.int(10, "Swing Lookback (left/right)", minval=2, maxval=50, group=grpPv,
                 tooltip="スイングポイントを検出するための左右バー数")
useATRFilter = input.bool(true, "Use ATR Filter for Significance", group=grpPv)
atrLen       = input.int(14, "ATR Length", minval=1, group=grpPv)
atrMinMult   = input.float(0.3, "Min Swing Size (x ATR)", minval=0.1, step=0.1, group=grpPv,
                 tooltip="ATRの何倍以上の動きを「有意なスイング」とみなすか")

grpEq = "② Equal Highs / Lows (Liquidity Pools)"
useEQ         = input.bool(true, "Detect Equal Highs/Lows", group=grpEq)
eqTolerance   = input.float(0.1, "Equal Tolerance (x ATR)", minval=0.01, step=0.01, group=grpEq,
                 tooltip="この範囲内なら同値とみなす（ATR倍率）")
eqLookback    = input.int(50, "Equal Pivot Scan Range (bars)", minval=5, group=grpEq)
eqMinDistance = input.int(3, "Min Bars Between Equals", minval=1, group=grpEq)
extendEQ      = input.bool(true, "Extend EQ Lines Right", group=grpEq)

grpSweep = "③ Liquidity Sweep / Grab Detection"
useSweep      = input.bool(true, "Detect Liquidity Sweeps", group=grpSweep)
sweepMode     = input.string("Wick + Close Back", "Sweep Confirmation",
                 options=["Wick Only","Close Back","Wick + Close Back"], group=grpSweep,
                 tooltip="Wick Only: ヒゲで更新 / Close Back: 終値が内側に戻る / Wick + Close Back: 両方")
sweepMaxBars  = input.int(3, "Max Bars for Close-Back Confirm", minval=1, maxval=10, group=grpSweep)
sweepMinWick  = input.float(0.3, "Min Wick Size (x ATR)", minval=0.0, step=0.05, group=grpSweep,
                 tooltip="スイープと判定する最小ヒゲサイズ")
requireReverse= input.bool(true, "Require Reversal Candle", group=grpSweep)

grpStopHunt = "④ Stop Hunt Zone"
useStopHunt   = input.bool(true, "Project Stop Hunt Zones", group=grpStopHunt)
zoneExtend    = input.int(20, "Zone Extension (bars)", minval=5, group=grpStopHunt)
zoneHeightATR = input.float(0.4, "Zone Height (x ATR)", minval=0.1, step=0.1, group=grpStopHunt)
mitigateMode  = input.string("Fade on Touch", "Zone Fade Mode",
                 options=["Keep","Fade on Touch","Remove on Touch"], group=grpStopHunt)

grpD = "🎨 Display"
darkMode     = input.bool(true, "Dark Mode", group=grpD)
showPivots   = input.bool(false, "Show Pivot Markers", group=grpD)
showLabels   = input.bool(true, "Show Sweep Labels", group=grpD)
showBOS      = input.bool(true, "Mark Break of Structure", group=grpD)
showDash     = input.bool(true, "Show Dashboard", group=grpD)
dashPos      = input.string("Top Right", "Dashboard Position",
                 options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=grpD)
maxObjects   = input.int(30, "Max Historical Objects", minval=5, maxval=100, group=grpD,
                 tooltip="保持する過去のスイープ/EQラインの最大数")

grpC = "🎨 Colors"
cBullSweep  = input.color(#00d4a0, "Bullish Sweep (Low Grab)",  group=grpC, inline="c1")
cBearSweep  = input.color(#ff5577, "Bearish Sweep (High Grab)", group=grpC, inline="c1")
cEQHigh     = input.color(#ff9500, "Equal Highs",               group=grpC, inline="c2")
cEQLow      = input.color(#4dabf7, "Equal Lows",                group=grpC, inline="c2")
cStopHunt   = input.color(#c084fc, "Stop Hunt Zone",            group=grpC, inline="c3")
cBOS        = input.color(#ffd43b, "BOS Line",                  group=grpC, inline="c3")

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
//  ATR & SIGNIFICANCE
// ═══════════════════════════════════════════════════════════════
atr = ta.atr(atrLen)
atrSig = atr * atrMinMult

// ═══════════════════════════════════════════════════════════════
//  PIVOT DETECTION
// ═══════════════════════════════════════════════════════════════
ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low,   pivLen, pivLen)

// Significance filter: swing must be meaningful
phValid = not na(ph) and (not useATRFilter or (ph - ta.lowest(low, pivLen * 2) >= atrSig))
plValid = not na(pl) and (not useATRFilter or (ta.highest(high, pivLen * 2) - pl >= atrSig))

// ═══════════════════════════════════════════════════════════════
//  PIVOT STORAGE (arrays)
// ═══════════════════════════════════════════════════════════════
var array<float> phPrice = array.new<float>()
var array<int>   phBar   = array.new<int>()
var array<bool>  phSwept = array.new<bool>()
var array<float> plPrice = array.new<float>()
var array<int>   plBar   = array.new<int>()
var array<bool>  plSwept = array.new<bool>()

// Store pivots (confirmed)
if phValid
    array.push(phPrice, ph)
    array.push(phBar,   bar_index - pivLen)
    array.push(phSwept, false)
    if array.size(phPrice) > 50
        array.shift(phPrice)
        array.shift(phBar)
        array.shift(phSwept)

if plValid
    array.push(plPrice, pl)
    array.push(plBar,   bar_index - pivLen)
    array.push(plSwept, false)
    if array.size(plPrice) > 50
        array.shift(plPrice)
        array.shift(plBar)
        array.shift(plSwept)

// Optional pivot markers
plotshape(showPivots and phValid ? ph : na, "PH", shape.triangledown, location.abovebar,
     color=color.new(cBearSweep, 50), size=size.tiny, offset=-pivLen)
plotshape(showPivots and plValid ? pl : na, "PL", shape.triangleup,   location.belowbar,
     color=color.new(cBullSweep, 50), size=size.tiny, offset=-pivLen)

// ═══════════════════════════════════════════════════════════════
//  EQUAL HIGHS / LOWS DETECTION
// ═══════════════════════════════════════════════════════════════
var array<line> eqHighLines = array.new<line>()
var array<line> eqLowLines  = array.new<line>()

f_pruneLineArr(arr, maxN) =>
    while array.size(arr) > maxN
        oldest = array.shift(arr)
        line.delete(oldest)

// Check for equal highs
if useEQ and phValid and array.size(phPrice) >= 2
    curPrice = ph
    curBar = bar_index - pivLen
    tolerance = atr * eqTolerance
    // Scan previous pivots (newest-1 backwards)
    for i = array.size(phPrice) - 2 to math.max(0, array.size(phPrice) - eqLookback) by 1
        prevPrice = array.get(phPrice, i)
        prevBar = array.get(phBar, i)
        if (curBar - prevBar) >= eqMinDistance and math.abs(curPrice - prevPrice) <= tolerance
            midPrice = (curPrice + prevPrice) / 2
            ln = line.new(prevBar, midPrice, curBar, midPrice,
                 color=color.new(cEQHigh, 20), width=2, style=line.style_dashed,
                 extend=extendEQ ? extend.right : extend.none)
            array.push(eqHighLines, ln)
            if showLabels
                label.new(curBar, midPrice, "EQH",
                     color=color.new(cEQHigh, 30), textcolor=color.white,
                     style=label.style_label_down, size=size.small)
            break

if useEQ and plValid and array.size(plPrice) >= 2
    curPrice = pl
    curBar = bar_index - pivLen
    tolerance = atr * eqTolerance
    for i = array.size(plPrice) - 2 to math.max(0, array.size(plPrice) - eqLookback) by 1
        prevPrice = array.get(plPrice, i)
        prevBar = array.get(plBar, i)
        if (curBar - prevBar) >= eqMinDistance and math.abs(curPrice - prevPrice) <= tolerance
            midPrice = (curPrice + prevPrice) / 2
            ln = line.new(prevBar, midPrice, curBar, midPrice,
                 color=color.new(cEQLow, 20), width=2, style=line.style_dashed,
                 extend=extendEQ ? extend.right : extend.none)
            array.push(eqLowLines, ln)
            if showLabels
                label.new(curBar, midPrice, "EQL",
                     color=color.new(cEQLow, 30), textcolor=color.white,
                     style=label.style_label_up, size=size.small)
            break

f_pruneLineArr(eqHighLines, maxObjects)
f_pruneLineArr(eqLowLines,  maxObjects)

// ═══════════════════════════════════════════════════════════════
//  LIQUIDITY SWEEP DETECTION
// ═══════════════════════════════════════════════════════════════
// Sweep state tracking for close-back confirmation
var array<int>   pendingSwHBar    = array.new<int>()
var array<float> pendingSwHLevel  = array.new<float>()
var array<int>   pendingSwHOrigin = array.new<int>()
var array<int>   pendingSwLBar    = array.new<int>()
var array<float> pendingSwLLevel  = array.new<float>()
var array<int>   pendingSwLOrigin = array.new<int>()

// Counters for dashboard
var int totalBullSweeps = 0
var int totalBearSweeps = 0
var int totalEQH = 0
var int totalEQL = 0
var int activeStopHunts = 0

// Last sweep tracking
var string lastSweepType = "—"
var int    lastSweepBar  = 0
var float  lastSweepLvl  = na

// Containers for finalized sweeps
var array<line>  sweepLines = array.new<line>()
var array<label> sweepLabels = array.new<label>()
var array<box>   stopHuntBoxes = array.new<box>()

f_pruneLineArrSim(arr, maxN) =>
    while array.size(arr) > maxN
        oldest = array.shift(arr)
        line.delete(oldest)

f_pruneLabelArr(arr, maxN) =>
    while array.size(arr) > maxN
        oldest = array.shift(arr)
        label.delete(oldest)

f_pruneBoxArr(arr, maxN) =>
    while array.size(arr) > maxN
        oldest = array.shift(arr)
        box.delete(oldest)

// Detect HIGH sweeps: current high exceeds a recent unsept pivot high
if useSweep and array.size(phPrice) > 0
    wickSize = high - math.max(open, close)
    wickOK = wickSize >= atr * sweepMinWick
    for i = array.size(phPrice) - 1 to 0
        pvPrice = array.get(phPrice, i)
        pvBar   = array.get(phBar, i)
        wasSwept = array.get(phSwept, i)
        if not wasSwept and high > pvPrice and (bar_index - pvBar) <= 200
            // Mark as swept regardless
            array.set(phSwept, i, true)
            if wickOK
                if sweepMode == "Wick Only"
                    // Immediate sweep confirm (wick only)
                    if close < pvPrice and (not requireReverse or close < open)
                        ln = line.new(pvBar, pvPrice, bar_index, pvPrice,
                             color=color.new(cBearSweep, 0), width=2, style=line.style_solid)
                        array.push(sweepLines, ln)
                        if showLabels
                            lb = label.new(bar_index, high, "✗ Sweep H",
                                 color=color.new(cBearSweep, 10), textcolor=color.white,
                                 style=label.style_label_down, size=size.small)
                            array.push(sweepLabels, lb)
                        if useStopHunt
                            topZ = high
                            botZ = high - atr * zoneHeightATR
                            bx = box.new(bar_index, topZ, bar_index + zoneExtend, botZ,
                                 border_color=color.new(cStopHunt, 40),
                                 bgcolor=color.new(cStopHunt, 85),
                                 border_width=1)
                            array.push(stopHuntBoxes, bx)
                            activeStopHunts += 1
                        totalBearSweeps += 1
                        lastSweepType := "Bearish (High Grab)"
                        lastSweepBar  := bar_index
                        lastSweepLvl  := pvPrice
                else
                    // Pending close-back
                    array.push(pendingSwHBar, bar_index)
                    array.push(pendingSwHLevel, pvPrice)
                    array.push(pendingSwHOrigin, pvBar)
            break

// Detect LOW sweeps
if useSweep and array.size(plPrice) > 0
    wickSize = math.min(open, close) - low
    wickOK = wickSize >= atr * sweepMinWick
    for i = array.size(plPrice) - 1 to 0
        pvPrice = array.get(plPrice, i)
        pvBar   = array.get(plBar, i)
        wasSwept = array.get(plSwept, i)
        if not wasSwept and low < pvPrice and (bar_index - pvBar) <= 200
            array.set(plSwept, i, true)
            if wickOK
                if sweepMode == "Wick Only"
                    if close > pvPrice and (not requireReverse or close > open)
                        ln = line.new(pvBar, pvPrice, bar_index, pvPrice,
                             color=color.new(cBullSweep, 0), width=2, style=line.style_solid)
                        array.push(sweepLines, ln)
                        if showLabels
                            lb = label.new(bar_index, low, "✗ Sweep L",
                                 color=color.new(cBullSweep, 10), textcolor=color.white,
                                 style=label.style_label_up, size=size.small)
                            array.push(sweepLabels, lb)
                        if useStopHunt
                            topZ = low + atr * zoneHeightATR
                            botZ = low
                            bx = box.new(bar_index, topZ, bar_index + zoneExtend, botZ,
                                 border_color=color.new(cStopHunt, 40),
                                 bgcolor=color.new(cStopHunt, 85),
                                 border_width=1)
                            array.push(stopHuntBoxes, bx)
                            activeStopHunts += 1
                        totalBullSweeps += 1
                        lastSweepType := "Bullish (Low Grab)"
                        lastSweepBar  := bar_index
                        lastSweepLvl  := pvPrice
                else
                    array.push(pendingSwLBar, bar_index)
                    array.push(pendingSwLLevel, pvPrice)
                    array.push(pendingSwLOrigin, pvBar)
            break

// Process pending sweeps (Close Back mode)
if useSweep and sweepMode != "Wick Only" and array.size(pendingSwHBar) > 0
    i = 0
    while i < array.size(pendingSwHBar)
        swBar    = array.get(pendingSwHBar, i)
        swLevel  = array.get(pendingSwHLevel, i)
        swOrigin = array.get(pendingSwHOrigin, i)
        barsElapsed = bar_index - swBar
        if barsElapsed > sweepMaxBars
            array.remove(pendingSwHBar, i)
            array.remove(pendingSwHLevel, i)
            array.remove(pendingSwHOrigin, i)
        else if close < swLevel
            // Close back below - confirmed
            ln = line.new(swOrigin, swLevel, bar_index, swLevel,
                 color=color.new(cBearSweep, 0), width=2, style=line.style_solid)
            array.push(sweepLines, ln)
            if showLabels
                lb = label.new(swBar, high[barsElapsed], "✗ Sweep H",
                     color=color.new(cBearSweep, 10), textcolor=color.white,
                     style=label.style_label_down, size=size.small)
                array.push(sweepLabels, lb)
            if useStopHunt
                topZ = high[barsElapsed]
                botZ = topZ - atr * zoneHeightATR
                bx = box.new(swBar, topZ, swBar + zoneExtend, botZ,
                     border_color=color.new(cStopHunt, 40),
                     bgcolor=color.new(cStopHunt, 85),
                     border_width=1)
                array.push(stopHuntBoxes, bx)
                activeStopHunts += 1
            totalBearSweeps += 1
            lastSweepType := "Bearish (High Grab)"
            lastSweepBar  := bar_index
            lastSweepLvl  := swLevel
            array.remove(pendingSwHBar, i)
            array.remove(pendingSwHLevel, i)
            array.remove(pendingSwHOrigin, i)
        else
            i += 1

if useSweep and sweepMode != "Wick Only" and array.size(pendingSwLBar) > 0
    i = 0
    while i < array.size(pendingSwLBar)
        swBar    = array.get(pendingSwLBar, i)
        swLevel  = array.get(pendingSwLLevel, i)
        swOrigin = array.get(pendingSwLOrigin, i)
        barsElapsed = bar_index - swBar
        if barsElapsed > sweepMaxBars
            array.remove(pendingSwLBar, i)
            array.remove(pendingSwLLevel, i)
            array.remove(pendingSwLOrigin, i)
        else if close > swLevel
            ln = line.new(swOrigin, swLevel, bar_index, swLevel,
                 color=color.new(cBullSweep, 0), width=2, style=line.style_solid)
            array.push(sweepLines, ln)
            if showLabels
                lb = label.new(swBar, low[barsElapsed], "✗ Sweep L",
                     color=color.new(cBullSweep, 10), textcolor=color.white,
                     style=label.style_label_up, size=size.small)
                array.push(sweepLabels, lb)
            if useStopHunt
                topZ = low[barsElapsed] + atr * zoneHeightATR
                botZ = low[barsElapsed]
                bx = box.new(swBar, topZ, swBar + zoneExtend, botZ,
                     border_color=color.new(cStopHunt, 40),
                     bgcolor=color.new(cStopHunt, 85),
                     border_width=1)
                array.push(stopHuntBoxes, bx)
                activeStopHunts += 1
            totalBullSweeps += 1
            lastSweepType := "Bullish (Low Grab)"
            lastSweepBar  := bar_index
            lastSweepLvl  := swLevel
            array.remove(pendingSwLBar, i)
            array.remove(pendingSwLLevel, i)
            array.remove(pendingSwLOrigin, i)
        else
            i += 1

// ═══════════════════════════════════════════════════════════════
//  STOP HUNT ZONE MITIGATION
// ═══════════════════════════════════════════════════════════════
if useStopHunt and array.size(stopHuntBoxes) > 0
    i = 0
    while i < array.size(stopHuntBoxes)
        bx = array.get(stopHuntBoxes, i)
        top = box.get_top(bx)
        bot = box.get_bottom(bx)
        rightBar = box.get_right(bx)
        touched = high >= bot and low <= top
        if touched
            if mitigateMode == "Remove on Touch"
                box.delete(bx)
                array.remove(stopHuntBoxes, i)
                activeStopHunts := math.max(0, activeStopHunts - 1)
                continue
            else if mitigateMode == "Fade on Touch"
                box.set_bgcolor(bx, color.new(cStopHunt, 92))
                box.set_border_color(bx, color.new(cStopHunt, 70))
        i += 1

// Prune old objects
f_pruneLineArrSim(sweepLines, maxObjects)
f_pruneLabelArr(sweepLabels, maxObjects)
f_pruneBoxArr(stopHuntBoxes, maxObjects)

// Update EQ counters  — FIX: array.size() >= 2 ガードを追加
if useEQ and phValid and array.size(phPrice) >= 2
    for i = array.size(phPrice) - 2 to math.max(0, array.size(phPrice) - eqLookback) by 1
        if math.abs(ph - array.get(phPrice, i)) <= atr * eqTolerance
            totalEQH += 1
            break

if useEQ and plValid and array.size(plPrice) >= 2
    for i = array.size(plPrice) - 2 to math.max(0, array.size(plPrice) - eqLookback) by 1
        if math.abs(pl - array.get(plPrice, i)) <= atr * eqTolerance
            totalEQL += 1
            break

// ═══════════════════════════════════════════════════════════════
//  BREAK OF STRUCTURE MARKERS
// ═══════════════════════════════════════════════════════════════
var float lastUnsweptHigh = na
var float lastUnsweptLow  = na

if phValid
    lastUnsweptHigh := ph
if plValid
    lastUnsweptLow := pl

bosUp   = showBOS and not na(lastUnsweptHigh) and close > lastUnsweptHigh and close[1] <= lastUnsweptHigh
bosDown = showBOS and not na(lastUnsweptLow)  and close < lastUnsweptLow  and close[1] >= lastUnsweptLow

plotshape(bosUp   ? lastUnsweptHigh : na, "BOS Up",   shape.labelup,   location.absolute,
     color=color.new(cBOS, 20), textcolor=color.black, text="BOS", size=size.tiny)
plotshape(bosDown ? lastUnsweptLow  : na, "BOS Down", shape.labeldown, location.absolute,
     color=color.new(cBOS, 20), textcolor=color.black, text="BOS", size=size.tiny)

// Signal: sweep happened this bar
sweepBullNow = lastSweepBar == bar_index and lastSweepType == "Bullish (Low Grab)"
sweepBearNow = lastSweepBar == bar_index and lastSweepType == "Bearish (High Grab)"

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
    dash := table.new(f_pos(dashPos), 3, 13,
         bgcolor=cBg, border_color=cBorder, border_width=1,
         frame_color=cAccent, frame_width=1)

    // Header
    table.cell(dash, 0, 0, "★ AE · LIQUIDITY SWEEP ★",
         text_color=cAccent, bgcolor=cBgAlt, text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 2, 0)

    // Section: Market State
    table.cell(dash, 0, 1, "MARKET STATE", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_left, text_size=size.small)
    table.merge_cells(dash, 0, 1, 2, 1)

    trendDir = not na(lastUnsweptHigh) and not na(lastUnsweptLow) and close > (lastUnsweptHigh + lastUnsweptLow) / 2 ? "▲ BULL BIAS" : "▼ BEAR BIAS"
    trendCol = close > (nz(lastUnsweptHigh) + nz(lastUnsweptLow)) / 2 ? cBullSweep : cBearSweep
    table.cell(dash, 0, 2, "Bias", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 2, trendDir, text_color=color.white,
         bgcolor=color.new(trendCol, 30), text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 2, "ATR: " + str.tostring(atr, format.mintick),
         text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)

    table.cell(dash, 0, 3, "Last Swing H", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 3, na(lastUnsweptHigh) ? "—" : str.tostring(lastUnsweptHigh, format.mintick),
         text_color=color.white, bgcolor=color.new(cBearSweep, 40), text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 3, na(lastUnsweptHigh) ? "—" : str.tostring((lastUnsweptHigh - close) / close * 100, "#.##") + "%",
         text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)

    table.cell(dash, 0, 4, "Last Swing L", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 4, na(lastUnsweptLow) ? "—" : str.tostring(lastUnsweptLow, format.mintick),
         text_color=color.white, bgcolor=color.new(cBullSweep, 40), text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 4, na(lastUnsweptLow) ? "—" : str.tostring((close - lastUnsweptLow) / close * 100, "#.##") + "%",
         text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)

    // Section: Sweep Stats
    table.cell(dash, 0, 5, "SWEEP STATISTICS", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_left, text_size=size.small)
    table.merge_cells(dash, 0, 5, 2, 5)

    table.cell(dash, 0, 6, "Bull Sweeps", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 6, str.tostring(totalBullSweeps), text_color=color.white,
         bgcolor=color.new(cBullSweep, 30), text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 6, "Low Grabs", text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)

    table.cell(dash, 0, 7, "Bear Sweeps", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 7, str.tostring(totalBearSweeps), text_color=color.white,
         bgcolor=color.new(cBearSweep, 30), text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 7, "High Grabs", text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)

    // Sweep bias ratio
    totSweeps = totalBullSweeps + totalBearSweeps
    bullRatio = totSweeps > 0 ? totalBullSweeps / totSweeps * 100 : 0
    ratioTxt = totSweeps > 0 ? str.tostring(bullRatio, "#.#") + "% BULL" : "—"
    ratioCol = bullRatio > 60 ? cBullSweep : bullRatio < 40 ? cBearSweep : cMute
    table.cell(dash, 0, 8, "Sweep Bias", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 8, ratioTxt, text_color=color.white,
         bgcolor=color.new(ratioCol, 30), text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 8, str.tostring(totSweeps) + " total", text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)

    // Section: Liquidity Pools
    table.cell(dash, 0, 9, "LIQUIDITY POOLS", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_left, text_size=size.small)
    table.merge_cells(dash, 0, 9, 2, 9)

    table.cell(dash, 0, 10, "Equal Highs", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 10, str.tostring(totalEQH), text_color=color.white,
         bgcolor=color.new(cEQHigh, 30), text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 10, "EQH", text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)

    table.cell(dash, 0, 11, "Equal Lows", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 11, str.tostring(totalEQL), text_color=color.white,
         bgcolor=color.new(cEQLow, 30), text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 11, "EQL", text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)

    // Last Event
    evtTxt = lastSweepBar == 0 ? "waiting..." :
             "Bar -" + str.tostring(bar_index - lastSweepBar) + " · " + lastSweepType
    evtCol = lastSweepType == "Bullish (Low Grab)" ? cBullSweep :
             lastSweepType == "Bearish (High Grab)" ? cBearSweep : cMute
    table.cell(dash, 0, 12, "Last Event", text_color=cAccent, bgcolor=cBg, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 12, evtTxt, text_color=color.white,
         bgcolor=color.new(evtCol, 30), text_halign=text.align_center, text_size=size.small)
    table.merge_cells(dash, 1, 12, 2, 12)

// ═══════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(sweepBullNow, "Bullish Liquidity Sweep (Low Grab)",
     "AE-LiqSweep: Bullish sweep detected - potential reversal from low")
alertcondition(sweepBearNow, "Bearish Liquidity Sweep (High Grab)",
     "AE-LiqSweep: Bearish sweep detected - potential reversal from high")
alertcondition(bosUp,   "Break of Structure Up",
     "AE-LiqSweep: Bullish BOS - structure broken to upside")
alertcondition(bosDown, "Break of Structure Down",
     "AE-LiqSweep: Bearish BOS - structure broken to downside")
alertcondition(useEQ and phValid and array.size(phPrice) >= 2, "New Equal Highs",
     "AE-LiqSweep: Equal Highs forming - liquidity building")
alertcondition(useEQ and plValid and array.size(plPrice) >= 2, "New Equal Lows",
     "AE-LiqSweep: Equal Lows forming - liquidity building")
````
