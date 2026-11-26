# Wave Sniper

- url: https://www.tradingview.com/script/YYfajVSu-Wave-Sniper/
- type: indicator
- pine_id: PUB;680a8fd5ec35458dbdb6c11670b82ffa
- version: 6.0

## Description

# Wave Sniper — Elliott Wave Flat & Confluence Detector
**by SRUS**

Wave Sniper is an advanced Elliott Wave overlay that automatically detects **flat corrections**, **3-wave pullbacks**, and **multi-timeframe wave structure** — then scores each setup for quality and confluence before marking it on your chart.

Built for traders who want clean wave-based entries without manually counting every pivot across timeframes.

---

## What It Detects

### Flat Corrections (A–B–C)
- **Regular Flat** — B retraces ~90–100% of A, C completes near A
- **Expanded Flat** — B exceeds A (up to 138.2%), C extends 123.6–161.8% of A
- **Running Flat** — B exceeds A, C fails to reach A (truncated C)

Each flat is validated with Fibonacci ratios, optional B-wave close validation, RSI momentum divergence, and volume confirmation at the C pivot.

### 3-Wave Pullbacks
- **Continuation** — three-wave pullback in the direction of the prevailing trend
- **Reversal** — three-wave structure signaling a potential turn

### 5-Wave Retest
After a flat completes, Wave Sniper tracks whether price forms a valid 5-wave extension and flags **retest opportunities** at the prior correction zone.

### Multi-Timeframe Wave Engine (15m · 1H · 4H · Daily)
Independent pivot engines run on four higher timeframes, each maintaining its own wave count state:
`WAVE_1` through `WAVE_5`, `WAVE_A/B/C`, impulse complete, correction complete.

---

## Signal System

### Triangle Markers
Confirmed setups print a **small triangle** at the C pivot:
- ▲ Green/Purple = Long bias
- ▼ Red = Short bias

Triangle color and line weight reflect the **confluence tier** — not just pattern type.

### Confluence Tiers (HTF Bonus)
| Tier | HTF Bonus | Visual |
|------|-----------|--------|
| CASCADE | 100+ | Boldest lines + chart flash |
| TRIPLE | 70–99 | Strong color, width 3 |
| WAVE | 40–69 | Medium color, width 2 |
| Single | Below 40 | Gray tint, width 1 |

**Base pattern score (0–100)** rates Fib accuracy, momentum, volume, and B-wave validation.
**HTF bonus (0–130)** adds points when chart and higher timeframes align on wave direction, impulse structure, RSI divergence, and volume behavior.

Full scoring breakdown is shown in the **info panel** (top right).

---

## Key Features

**Wave 4 Watch System**
- Detects when price enters the 23.6–38.2% Fib retrace zone of HTF Wave 3
- Confirms with RSI behavior, volume contraction, and a completing 3-wave structure
- Draws W4 MIN / W4 MAX levels and `W4 WATCH` / `W4 ✅ LOAD W5` labels

**HTF Fib Zones**
- Auto-draws Wave 4 expected retrace boxes per active timeframe
- Projects W5 targets: MIN, STANDARD, 161.8%, 261.8%

**⚡ Prime Zone**
When an HTF Wave 4 Fib zone overlaps a confirmed flat correction zone on your chart timeframe, a bright **PRIME ZONE** box highlights the overlap — highest-probability confluence area.

**Auto-Invalidation**
Patterns that break structure fade to gray and are removed from active tracking.

**Adaptive Pivots**
Pivot strength auto-adjusts to ATR and timeframe so detection stays consistent across instruments and chart periods.

**Focus Mode**
Toggle to show flats only and reduce chart clutter.

**Lookback Filter**
Auto / 1 Day / 1 Week / 1 Month / All — control how far back patterns are drawn.

---

## Info Panel

Live readout includes:
- Daily · 4H · 1H · 15m wave states
- HTF Bias (Long/Short)
- Prime Zone status
- Current chart wave state

---

## Alerts

Built-in alert conditions:
- ⚡ Wave 4 Approaching
- ✅ Wave 4 Confirmed — W5 Loading
- 🔥 Cascade Signal — All TFs Aligned
- ⚡ Prime Zone Active
- 🔁 Wave Count Invalidated (per TF)
- 🎯 Wave 5 Target Hit (MIN / 161.8%)
- Flat detected (Regular / Expanded / Running)
- 3-Wave Continuation / Reversal
- 5-Wave retest confirmed
- B-wave confirmed — watching for C

---

## Recommended Settings

| Use Case | Suggestion |
|----------|------------|
| Scalping (1m–5m) | Enable 15m + 1H layers, Min Score 65, Min HTF Bonus 40 |
| Swing (15m–1H) | All HTF layers on, Min Score 60, Min HTF Bonus 30 |
| Position (4H–D) | Daily + 4H layers, Wave Degree = Intermediate |
| Clean chart | Focus Mode ON, Max Visible = 3 |

---

## How to Read a Setup

1. **Triangle appears** at C pivot → flat or pullback confirmed
2. Check **info panel** for HTF alignment and tier
3. Watch for **W4 zone** or **Prime Zone** for entry refinement
4. Use **W5 projection lines** for targets
5. Set alerts for CASCADE or Prime Zone for hands-free monitoring

---

## Disclaimer

Wave Sniper is a **technical analysis tool**, not financial advice. Elliott Wave counting is interpretive — always confirm with your own analysis, risk management, and market context. Past pattern performance does not guarantee

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator("Wave Sniper", overlay=true, precision=2, max_lines_count=500, max_labels_count=500, max_boxes_count=500, calc_bars_count=1200)

// ═════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═════════════════════════════════════════════════════════════════════════════

// Pivot Settings
grp_pivot = "📊 Pivot Settings"
pivotStrength = input.int(5, title="Pivot Strength", minval=2, maxval=20, group=grp_pivot)
adaptiveMode = input.bool(true, title="Adaptive Mode", group=grp_pivot)
atrPeriod = input.int(14, title="ATR Period", minval=5, maxval=50, group=grp_pivot)
waveDegree = input.string("Minor", title="Wave Degree", options=["Minor", "Intermediate", "Primary"], group=grp_pivot)

// Flat Validation
grp_flat = "🔄 Flat Validation"
tolerancePct = input.float(5.0, title="Tolerance %", minval=0.5, maxval=20.0, step=0.5, group=grp_flat)
baMinPct = input.float(90.0, title="B/A Min % (Regular)", minval=50.0, maxval=100.0, step=0.1, group=grp_flat)
baMaxPct = input.float(138.2, title="B/A Max % (Expanded)", minval=100.0, maxval=200.0, step=0.1, group=grp_flat)
caMinPct = input.float(123.6, title="C/A Min % (Expanded)", minval=100.0, maxval=200.0, step=0.1, group=grp_flat)
caMaxPct = input.float(161.8, title="C/A Max % (Expanded)", minval=100.0, maxval=300.0, step=0.1, group=grp_flat)
bCloseValidation = input.bool(true, title="B-Wave Close Validation", group=grp_flat)
momentumConfirmation = input.bool(true, title="Require Momentum Confirmation", group=grp_flat)
volumeConfirmation = input.bool(true, title="Require Volume Spike at C", group=grp_flat)

// Display Settings
grp_display = "Chart Patterns"
showFlatLabels = input.bool(true, title="Show Flat Labels", group=grp_display)
showImpulseLabels = input.bool(true, title="Show Impulse 1-5 Labels", group=grp_display)
showLiveWave = input.bool(false, title="Show Live Forming Wave (dashed to price)", group=grp_display)
showFibRatios = input.bool(true, title="Show Fib Ratios on Patterns", group=grp_display)
showScore = input.bool(true, title="Show Pattern Score", group=grp_display)
minScore = input.int(60, title="Minimum Score to Display", minval=0, maxval=100, group=grp_display)
lookbackWindow = input.string("Auto", title="Lookback Window", options=["Auto", "1 Day", "1 Week", "1 Month", "All"], group=grp_display)
regularColor = input.color(color.new(color.purple, 0), title="Regular Flat Color", group=grp_display)
expandedColor = input.color(color.new(color.orange, 0), title="Expanded Flat Color", group=grp_display)
enableRetest = input.bool(true, title="Enable 5-Wave Retest Signals", group=grp_display)
focusMode = input.bool(false, title="Focus Mode (Flats Only) — Hides pullbacks, keeps flats", group=grp_display)
maxVisible = input.int(12, title="Max Visible Patterns", minval=1, maxval=25, group=grp_display)

grp_markers = "Neon Markers"
showPatternZones = input.bool(true, title="Pattern Zone Boxes", group=grp_markers)
showW4Markers = input.bool(true, title="W4 Destination Zones (W3→W4)", group=grp_markers)
showW5Markers = input.bool(true, title="W5 Destination Boxes (W4→W5)", group=grp_markers)
showW2Markers = input.bool(true, title="W2 Pullback & W3 Projection Zones", group=grp_markers)
showPrimeMarkers = input.bool(true, title="Prime Zone Box", group=grp_markers)
showFibCTargets = input.bool(false, title="Fib C Target Boxes", group=grp_markers)
showZonePct = input.bool(true, title="Show Zone Distance %", group=grp_markers)
labelRightBars = input.int(12, title="Marker Right Offset (bars)", minval=2, maxval=40, group=grp_markers)
zoneMarkerBars = input.int(5, title="Marker Width (bars)", minval=2, maxval=12, group=grp_markers)
w4ZoneColor = input.color(#00E5FF, title="W4 Zone Color", group=grp_markers)
w5MinColor = input.color(#B388FF, title="W5 MIN Color", group=grp_markers)
w5StdColor = input.color(#FFE600, title="W5 STD Color", group=grp_markers)
w5Ext1Color = input.color(#FF8C00, title="W5 161% Color", group=grp_markers)
w5Ext2Color = input.color(#FF00AA, title="W5 261% Color", group=grp_markers)
w2W3TargetColor = input.color(#00FF66, title="W2→W3 Target Color", group=grp_markers)
w2W3ExtColor = input.color(#39FF14, title="W2→W3 2.0 Ext Color", group=grp_markers)
w2PullbackColor = input.color(#FF66AA, title="W2 Pullback Zone Color", group=grp_markers)
fibC100Color = input.color(#FFFFFF, title="Fib C 100% Color", group=grp_markers)
fibC123Color = input.color(#00FFAA, title="Fib C 123.6% Color", group=grp_markers)
fibC161Color = input.color(#FF66CC, title="Fib C 161.8% Color", group=grp_markers)
primeLongColor = input.color(#00FFB3, title="Prime Zone Long Color", group=grp_markers)
primeShortColor = input.color(#FF3131, title="Prime Zone Short Color", group=grp_markers)

grp_trend = "Trend Alignment"
enableTrendFilter = input.bool(true, title="Require Wave Direction Align with EMA Trend", group=grp_trend)
trendEmaLength = input.int(50, title="EMA Trend Length", minval=10, maxval=200, group=grp_trend)
trendFilterMode = input.string("Direction", title="Trend Filter Mode", options=["Direction", "Direction+Above/Below"], group=grp_trend)

// 3-Wave Pullback Detection Settings
grp_pullback = "📉 3-Wave Pullback"
enablePullback = input.bool(true, title="Enable 3-Wave Pullback Detection", group=grp_pullback)
pullbackTolerance = input.float(10.0, title="Pullback Tolerance %", minval=5.0, maxval=30.0, step=1.0, group=grp_pullback)
continuationColor = input.color(#00BFFF, title="Continuation Color", group=grp_pullback)
reversalColor = input.color(#FF3131, title="Reversal Color", group=grp_pullback)
pullbackCircleColor = input.color(#87CEEB, title="Pullback Circle Color", group=grp_pullback)

// HTF Layer Inputs
grp_htf = "⏱️ Multi-Timeframe Layers"
enableHtf15 = input.bool(true, title="Enable 15m Layer", group=grp_htf)
enableHtf60 = input.bool(true, title="Enable 1H Layer", group=grp_htf)
enableHtf240 = input.bool(true, title="Enable 4H Layer", group=grp_htf)
enableHtfD = input.bool(true, title="Enable Daily Layer", group=grp_htf)
enableMicro1 = input.bool(true, title="Enable 1m Sub-Wave Layer", group=grp_htf)
enableMicro3 = input.bool(true, title="Enable 3m Sub-Wave Layer", group=grp_htf)
enableMicro5 = input.bool(true, title="Enable 5m Sub-Wave Layer", group=grp_htf)
minHtfBonus = input.int(30, title="Minimum HTF Confluence Bonus", minval=0, maxval=170, group=grp_htf)

// Predictive Flat Detection Settings
grp_predictive = "🔮 Predictive Flat Detection"
enablePredictive = input.bool(true, title="Enable Predictive A→B→C Projection", group=grp_predictive)
showBZone = input.bool(true, title="Show B Projection Zone", group=grp_predictive)
showCZone = input.bool(true, title="Show C Projection Zone", group=grp_predictive)
showTradePreview = input.bool(true, title="Show Trade Setup Preview", group=grp_predictive)
minAStrengthATR = input.float(0.5, title="Min A-Wave Length (x ATR)", minval=0.0, maxval=5.0, step=0.1, group=grp_predictive)
entryZoneATR = input.float(0.5, title="Entry Zone Proximity (x ATR)", minval=0.1, maxval=2.0, step=0.1, group=grp_predictive)
enableFlatStack = input.bool(true, title="Enable Multi-TF Flat Stack", group=grp_predictive)
enableFractalCascade = input.bool(true, title="Enable Fractal Cascade Tier-0", group=grp_predictive)
enableW4Progress = input.bool(true, title="Enable W4 Live Progress Bar", group=grp_predictive)
enableHitRate = input.bool(true, title="Enable Historical Zone Hit Rate", group=grp_predictive)
hitRateLookbackBars = input.int(500, title="Hit Rate Lookback (bars)", minval=100, maxval=2000, step=100, group=grp_predictive)
enableTruncatedSignal = input.bool(true, title="Enable Truncated W5 Reversal Signal", group=grp_predictive)
enablePreEntry = input.bool(true, title="Enable B-Wave Pre-Entry Signal", group=grp_predictive)
enableInvalidationVisuals = input.bool(true, title="Fade Invalidated Patterns + Red X", group=grp_predictive)
enableStaleDimming = input.bool(true, title="Fade Stale Patterns (>50% Lookback)", group=grp_predictive)
staleThresholdPct = input.float(50.0, title="Stale Dimming Threshold %", minval=10.0, maxval=90.0, step=5.0, group=grp_predictive)
runningColor = input.color(color.new(color.yellow, 0), title="Running Flat Color", group=grp_predictive)
flatStackColor = input.color(color.new(#00E5FF, 0), title="Flat Stack Color", group=grp_predictive)
cascadeTier0Color = input.color(color.new(#FF00FF, 0), title="Fractal Cascade Flash Color", group=grp_predictive)
invalidColor = input.color(color.new(color.gray, 0), title="Invalidated Pattern Color", group=grp_predictive)
truncatedColor = input.color(color.new(#FF3131, 0), title="Truncated W5 Color", group=grp_predictive)
preEntryColor = input.color(color.new(#00FFB3, 0), title="Pre-Entry Zone Color", group=grp_predictive)
progressBarColor = input.color(color.new(#FFE600, 0), title="W4 Progress Bar Color", group=grp_predictive)

grp_leading = "🎯 Leading Probability"
enableTimeProj = input.bool(false, title="Fib Time Projection (W3→W4 timing only)", group=grp_leading)
enableW3Exhaust = input.bool(false, title="Enable W3 Exhaustion Pre-Signal", group=grp_leading)
exhaustRsiLen = input.int(14, title="Exhaustion RSI Period", minval=5, maxval=30, group=grp_leading)
exhaustLookback = input.int(5, title="Exhaustion Divergence Lookback", minval=3, maxval=20, group=grp_leading)
exhaustColor = input.color(#FFE600, title="W3 Exhaustion Color", group=grp_leading)
enableLeadTarget = input.bool(true, title="Enable Leading Target Box", group=grp_leading)
leadTargetLongColor = input.color(#00FFB3, title="Leading Target Long Color", group=grp_leading)
leadTargetShortColor = input.color(#FF3131, title="Leading Target Short Color", group=grp_leading)
enableCProj = input.bool(true, title="Enable Flat C Projection After B", group=grp_leading)
showCChartLines = input.bool(true, title="Draw C Target Lines on Chart (from B pivot)", group=grp_leading)
enableCProjExt = input.bool(true, title="Show Expanded Flat C Zone", group=grp_leading)
enableCProjRun = input.bool(true, title="Show Running Flat C Level", group=grp_leading)

// ═════════════════════════════════════════════════════════════════════════════
// CONSTANTS
// ═════════════════════════════════════════════════════════════════════════════

var int MAX_PATTERNS = 25
var int MAX_PIVOT_HISTORY = 60

// HTF lite mode — 4H+ charts skip security calls & heavy layers to avoid memory errors
int chartSecVal = math.max(timeframe.in_seconds(), 60)
bool isHighTf = chartSecVal >= 14400
int pivotHistoryCap = isHighTf ? 28 : MAX_PIVOT_HISTORY

// Pattern type constants
var int PATTERN_NONE = 0
var int PATTERN_REGULAR = 1
var int PATTERN_EXPANDED = 2
var int PATTERN_RUNNING = 3

// Pullback type constants
var int PULLBACK_NONE = 0
var int PULLBACK_CONTINUATION = 1
var int PULLBACK_REVERSAL = 2

// Timeframe-aware lookback in bars (capped to avoid memory blowups on HTF)
getLookbackBars(string mode) =>
    float tfSec = math.max(timeframe.in_seconds(), 60.0)
    int autoBars = int(math.ceil(7776000.0 / tfSec))  // ~90 days
    int hardCap = tfSec >= 86400 ? 300 : tfSec >= 14400 ? 400 : tfSec >= 3600 ? 1500 : 5000
    int cappedAuto = math.min(autoBars, hardCap)
    switch mode
        "1 Day"   => int(math.ceil(86400.0 / tfSec))
        "1 Week"  => int(math.ceil(604800.0 / tfSec))
        "1 Month" => int(math.ceil(2592000.0 / tfSec))
        "All"     => hardCap
        => cappedAuto

// Scale pivot strength by wave degree
getDegreeScale(string degree) =>
    switch degree
        "Minor"        => 1.0
        "Intermediate" => 2.5
        "Primary"      => 5.0
        => 1.0

// Scale pivot strength by chart TF — fewer pivots on HTF (less memory)
getTfPivotScale() =>
    float tfMin = timeframe.in_seconds() / 60.0
    tfMin <= 240.0 ? math.sqrt(240.0 / math.max(tfMin, 1.0)) : math.sqrt(math.max(tfMin, 240.0) / 240.0)

// Check if A-B-C bars already used by another pattern
isBarsUsed(int b1, int b2, int b3, int[] aBars, int[] bBars, int[] cBars) =>
    bool used = false
    int n = array.size(aBars)
    for i = 0 to (n == 0 ? na : n - 1)
        if array.get(aBars, i) == b1 or array.get(bBars, i) == b2 or array.get(cBars, i) == b3
            used := true
            break
    used

shiftOldestGraphics(label[] sigA, label[] sigB, label[] sigC, label[] lblA, label[] lblB, label[] lblC, line[] lnAB, line[] lnBC, box[] bx) =>
    label sA = array.shift(sigA)
    label sB = array.shift(sigB)
    label sC = array.shift(sigC)
    if not na(sA)
        label.delete(sA)
    if not na(sB)
        label.delete(sB)
    if not na(sC)
        label.delete(sC)
    label lA = array.shift(lblA)
    label lB = array.shift(lblB)
    label lC = array.shift(lblC)
    if not na(lA)
        label.delete(lA)
    if not na(lB)
        label.delete(lB)
    if not na(lC)
        label.delete(lC)
    line.delete(array.shift(lnAB))
    line.delete(array.shift(lnBC))
    box oldBox = array.shift(bx)
    if not na(oldBox)
        box.delete(oldBox)

removeGraphicsAt(label[] sigA, label[] sigB, label[] sigC, label[] lblA, label[] lblB, label[] lblC, label[] lblType, line[] lnAB, line[] lnBC, box[] bx, int idx) =>
    label sA = array.remove(sigA, idx)
    label sB = array.remove(sigB, idx)
    label sC = array.remove(sigC, idx)
    if not na(sA)
        label.delete(sA)
    if not na(sB)
        label.delete(sB)
    if not na(sC)
        label.delete(sC)
    label lA = array.remove(lblA, idx)
    label lB = array.remove(lblB, idx)
    label lC = array.remove(lblC, idx)
    if not na(lA)
        label.delete(lA)
    if not na(lB)
        label.delete(lB)
    if not na(lC)
        label.delete(lC)
    label lt = array.remove(lblType, idx)
    if not na(lt)
        label.delete(lt)
    line.delete(array.remove(lnAB, idx))
    line.delete(array.remove(lnBC, idx))
    box oldBox = array.remove(bx, idx)
    if not na(oldBox)
        box.delete(oldBox)

isFiveWaveTracked(int cBar, int[] trackedCBars) =>
    bool tracked = false
    int n = array.size(trackedCBars)
    for i = 0 to (n == 0 ? na : n - 1)
        if array.get(trackedCBars, i) == cBar
            tracked := true
            break
    tracked

// Pine limits bar_index drawings to ~500 bars from current bar
const int MAX_DRAW_BARS = 500

// Map HTF bar_index to drawable chart bar_index (handles TF mismatch + lookback cap)
clampDrawBar(int srcBar) =>
    math.max(bar_index - MAX_DRAW_BARS, math.min(srcBar, bar_index))

rightLabelBar() =>
    bar_index + labelRightBars

tfMarkerAnchor(int layerIdx) =>
    bar_index + labelRightBars + layerIdx * (zoneMarkerBars + 2)

cProjMarginAnchor(int slot) =>
    bar_index + labelRightBars + 4 + slot * (zoneMarkerBars + 3)

chartTfName() =>
    timeframe.period

isTfValid(string targetTf) =>
    int targetSec = timeframe.in_seconds(targetTf)
    int chartSec = timeframe.in_seconds()
    not na(targetSec) and not na(chartSec) and targetSec >= chartSec

htfLayerPriority(string name) =>
    name == "D" ? 3 : name == "4H" ? 2 : name == "1H" ? 1 : 0

string validHtf15 = isTfValid("15") ? "15" : ""
string validHtf60 = isTfValid("60") ? "60" : ""
string validHtf240 = isTfValid("240") ? "240" : ""
string validHtfD = isTfValid("D") ? "D" : ""
string validMicro1 = isTfValid("1") ? "1" : ""
string validMicro3 = isTfValid("3") ? "3" : ""
string validMicro5 = isTfValid("5") ? "5" : ""

// When we are on a higher timeframe, disable ALL security calls + heavy layers (chart-only mode)
// Only fetch TF layers above chart TF / micro below — skips redundant security calls
bool useHtf15 = enableHtf15 and validHtf15 != "" and not isHighTf and chartSecVal < 900
bool useHtf60 = enableHtf60 and validHtf60 != "" and not isHighTf and chartSecVal < 3600
bool useHtf240 = enableHtf240 and validHtf240 != "" and not isHighTf and chartSecVal < 14400
bool useHtfD = enableHtfD and validHtfD != "" and not isHighTf and chartSecVal < 86400
bool useMicro1 = enableMicro1 and validMicro1 != "" and not isHighTf and chartSecVal > 60
bool useMicro3 = enableMicro3 and validMicro3 != "" and not isHighTf and chartSecVal > 180
bool useMicro5 = enableMicro5 and validMicro5 != "" and not isHighTf and chartSecVal > 300
bool runHeavyLayers = not isHighTf

int effMaxVisible = isHighTf ? math.min(maxVisible, 6) : maxVisible

tfWeightFromName(string name) =>
    name == "D" ? 4 : name == "4H" ? 3 : name == "1H" ? 2 : name == "15m" ? 1 : 1

leadMarkerAnchor() =>
    bar_index + math.max(2, labelRightBars - zoneMarkerBars - 3)

leadPhaseBonus(string tag, int w3, int w4, int w5) =>
    float b = 0.0
    if tag == "W4 DEST"
        b := w3 * 15.0 - w4 * 4.0
    else if tag == "W5 STD"
        b := w4 * 22.0 + w5 * 3.0
    else if tag == "W5 MIN"
        b := w4 * 10.0 + w5 * 2.0
    else if tag == "W5 EXT"
        b := w5 * 12.0 + w4 * 4.0
    math.max(b, 0.0)

leadDirBonus(float targetPrice, float refDir) =>
    refDir == 1.0 ? (targetPrice > close ? 12.0 : 0.0) : refDir == -1.0 ? (targetPrice < close ? 12.0 : 0.0) : 0.0

pushLeadCand(float[] lows, float[] highs, string[] tags, int[] tfWts, float zLo, float zHi, string tag, int tw) =>
    array.push(lows, math.min(zLo, zHi))
    array.push(highs, math.max(zLo, zHi))
    array.push(tags, tag)
    array.push(tfWts, tw)
    true

impulseWaveCount(string state) =>
    switch state
        "WAVE_1" => 1
        "WAVE_2" => 2
        "WAVE_3" => 3
        "WAVE_4" => 4
        "WAVE_5" => 5
        => 0

isNearImpulsePivot(int patBar, int ib1, int ib2, int ib3, int ib4, int ib5, int waves) =>
    bool near = false
    if waves >= 1 and math.abs(patBar - ib1) <= 3
        near := true
    if waves >= 2 and math.abs(patBar - ib2) <= 3
        near := true
    if waves >= 3 and math.abs(patBar - ib3) <= 3
        near := true
    if waves >= 4 and math.abs(patBar - ib4) <= 3
        near := true
    if waves >= 5 and math.abs(patBar - ib5) <= 3
        near := true
    near

getImpulseLblStyle(bool bullish, int waveNum) =>
    bool sameSide = waveNum % 2 == 1
    bool useDown = bullish ? sameSide : not sameSide
    useDown ? label.style_label_down : label.style_label_up

getImpulseWaveText(int waveNum, bool truncated) =>
    waveNum == 4 ? "⚡4" : (waveNum == 5 and truncated ? "5T" : str.tostring(waveNum))

getImpulseWaveColor(int waveNum, bool bullish) =>
    switch waveNum
        1 => color.new(color.white, 0)
        2 => color.new(color.white, 0)
        3 => bullish ? color.new(color.lime, 0) : color.new(color.red, 0)
        4 => color.new(color.yellow, 0)
        5 => color.new(color.orange, 0)
        => color.gray

getImpulseLineColor(int segNum, bool bullish) =>
    switch segNum
        1 => color.new(color.gray, 30)
        2 => bullish ? color.new(color.lime, 0) : color.new(color.red, 0)
        3 => color.new(color.yellow, 0)
        4 => color.new(color.orange, 0)
        => color.gray

// ═════════════════════════════════════════════════════════════════════════════
// PREDICTIVE FLAT & REVERSAL HELPERS
// ═════════════════════════════════════════════════════════════════════════════

// Compute B-wave target zones once A is confirmed
computeBZones(float pOrigin, float pA, bool aUp) =>
    float waveA = math.abs(pA - pOrigin)
    float regLo = aUp ? pA - waveA : pA + waveA * 0.50
    float regHi = aUp ? pA - waveA * 0.50 : pA + waveA
    float expLo = aUp ? pA - waveA * 1.382 : pA + waveA * 1.0
    float expHi = aUp ? pA - waveA * 1.0 : pA + waveA * 1.382
    [regLo, regHi, expLo, expHi]

// Resolve most recent potential Wave A (single counter-trend pivot)
getAContext(float[] prices, int[] bars, int[] dirs) =>
    bool active = false
    float pOrigin = na
    float pA = na
    bool aUp = false
    int bA = na
    int psz = array.size(prices)
    if psz >= 2
        int d1 = array.get(dirs, psz - 1)
        int d0 = array.get(dirs, psz - 2)
        if d1 != d0
            pA := array.get(prices, psz - 1)
            pOrigin := array.get(prices, psz - 2)
            aUp := pA > pOrigin
            bA := array.get(bars, psz - 1)
            active := true
    [active, pOrigin, pA, aUp, bA]

// Validate Wave A has size, decent retrace of prior leg, and volume
isAValid(float pOrigin, float pA, float[] prices, float[] vols, float[] volAvgs, float atrVal) =>
    float waveA = math.abs(pA - pOrigin)
    bool lenOk = waveA >= atrVal * minAStrengthATR
    bool retraceOk = true
    if array.size(prices) >= 3
        float priorWave = math.abs(pOrigin - array.get(prices, array.size(prices) - 3))
        retraceOk := priorWave > 0 ? (waveA / priorWave >= 0.382 and waveA / priorWave <= 0.886) : true
    int idx = array.size(prices) - 1
    bool volOk = idx >= 0 ? array.get(vols, idx) > array.get(volAvgs, idx) : true
    lenOk and retraceOk and volOk

// Classify which flat type is forming from B position
classifyFlatTypeFromB(float pOrigin, float pA, float pB) =>
    int type = PATTERN_NONE
    float waveA = math.abs(pA - pOrigin)
    bool aUp = pA > pOrigin
    bool bInside = aUp ? pB >= pOrigin and pB <= pA : pB <= pOrigin and pB >= pA
    bool bBeyond = aUp ? pB < pOrigin : pB > pOrigin
    float ba = waveA > 0 ? math.abs(pB - pA) / waveA * 100 : 0
    if bInside and ba >= 50 and ba <= 105
        type := PATTERN_REGULAR
    else if bBeyond and ba >= 95 and ba <= 150
        type := PATTERN_EXPANDED
    else if bBeyond and ba > 100
        type := PATTERN_RUNNING
    type

// Draw a horizontal dashed line extending right from a start bar
hlineRight(int startBar, float price, color col, int width) =>
    line.new(startBar, price, bar_index + labelRightBars, price, color=col, width=width, style=line.style_dashed, extend=extend.right)

// Historical price-level reversal hit rate (lookback bars)
levelHitRate(float level, int expectedDir, int lookback) =>
    int touches = 0
    int reversals = 0
    int maxBack = math.min(lookback, bar_index - 10)
    if maxBack > 10
        for i = 10 to maxBack
            bool touched = low[i] <= level and high[i] >= level
            if touched
                touches += 1
                bool success = expectedDir == 1 ? close[i - 5] > close[i] : close[i - 5] < close[i]
                if success
                    reversals += 1
    float rate = touches > 0 ? reversals / touches * 100 : 0.0
    rate

formatHitRate(float level, int expectedDir) =>
    if not enableHitRate
        ""
    else
        float r = levelHitRate(level, expectedDir, hitRateLookbackBars)
        " [" + str.tostring(r, "#") + "%]"

// ═════════════════════════════════════════════════════════════════════════════
// HTF PIVOT & WAVE-STATE HELPERS
// ═════════════════════════════════════════════════════════════════════════════

pushHtfPivot(float[] prices, int[] bars, int[] dirs, int lastDir, float price, int dir, int bar) =>
    int newLastDir = lastDir
    if lastDir == dir and array.size(prices) > 0
        int idx = array.size(prices) - 1
        float prev = array.get(prices, idx)
        bool replace = (dir == 1 and price > prev) or (dir == -1 and price < prev)
        if replace
            array.set(prices, idx, price)
            array.set(bars, idx, bar)
        newLastDir := dir
    else
        array.push(prices, price)
        array.push(bars, bar)
        array.push(dirs, dir)
        newLastDir := dir
    while array.size(prices) > pivotHistoryCap
        array.shift(prices)
        array.shift(bars)
        array.shift(dirs)
    newLastDir

extractHtfLast6(float[] prices, int[] bars, int[] dirs) =>
    int n = array.size(prices)
    float p0 = n >= 6 ? array.get(prices, n - 6) : (n >= 1 ? array.get(prices, 0) : na)
    float p1 = n >= 6 ? array.get(prices, n - 5) : (n >= 2 ? array.get(prices, 1) : na)
    float p2 = n >= 6 ? array.get(prices, n - 4) : (n >= 3 ? array.get(prices, 2) : na)
    float p3 = n >= 6 ? array.get(prices, n - 3) : (n >= 4 ? array.get(prices, 3) : na)
    float p4 = n >= 6 ? array.get(prices, n - 2) : (n >= 5 ? array.get(prices, 4) : na)
    float p5 = n >= 6 ? array.get(prices, n - 1) : na
    int b0 = n >= 6 ? array.get(bars, n - 6) : (n >= 1 ? array.get(bars, 0) : na)
    int b1 = n >= 6 ? array.get(bars, n - 5) : (n >= 2 ? array.get(bars, 1) : na)
    int b2 = n >= 6 ? array.get(bars, n - 4) : (n >= 3 ? array.get(bars, 2) : na)
    int b3 = n >= 6 ? array.get(bars, n - 3) : (n >= 4 ? array.get(bars, 3) : na)
    int b4 = n >= 6 ? array.get(bars, n - 2) : (n >= 5 ? array.get(bars, 4) : na)
    int b5 = n >= 6 ? array.get(bars, n - 1) : na
    int d0 = n >= 6 ? array.get(dirs, n - 6) : (n >= 1 ? array.get(dirs, 0) : na)
    int d1 = n >= 6 ? array.get(dirs, n - 5) : (n >= 2 ? array.get(dirs, 1) : na)
    int d2 = n >= 6 ? array.get(dirs, n - 4) : (n >= 3 ? array.get(dirs, 2) : na)
    int d3 = n >= 6 ? array.get(dirs, n - 3) : (n >= 4 ? array.get(dirs, 3) : na)
    int d4 = n >= 6 ? array.get(dirs, n - 2) : (n >= 5 ? array.get(dirs, 4) : na)
    int d5 = n >= 6 ? array.get(dirs, n - 1) : na
    [p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5]

classifyWaveState(float p0, float p1, float p2, float p3, float p4, float p5, int d0, int d1, int d2, int d3, int d4, int d5) =>
    string state = "UNKNOWN"
    float dir = 0.0
    bool truncated = false
    bool validImpulse = false
    bool w5fibValid = false
    float w3MinMult = waveDegree == "Primary" ? 1.382 : waveDegree == "Intermediate" ? 1.236 : 1.0

    // 5-wave impulse (last 6 pivots)
    if not na(p5)
        bool alt = (d0 != d1) and (d1 != d2) and (d2 != d3) and (d3 != d4) and (d4 != d5)
        bool macroUp = p5 > p0
        bool macroDown = p5 < p0
        if alt and (macroUp or macroDown)
            float w1 = math.abs(p1 - p0)
            float w2 = math.abs(p2 - p1)
            float w3 = math.abs(p3 - p2)
            float w4 = math.abs(p4 - p3)
            float w5 = math.abs(p5 - p4)
            bool w2noCross = macroUp ? (p2 > p0) : (p2 < p0)
            bool w2valid = w2 >= w1 * 0.236 and w2 < w1 * 0.999 and w2noCross
            bool w3valid = w3 >= w1 * w3MinMult
            float w1high = math.max(p0, p1)
            float w1low = math.min(p0, p1)
            float w4overlapTol = w1 * 0.10
            bool w4valid = macroUp ? (p4 > p1 - w4overlapTol) : (p4 < p1 + w4overlapTol)
            bool w5extend = macroUp ? (p5 > p3) : (p5 < p3)
            if w2valid and w3valid and w4valid
                validImpulse := true
                truncated := not w5extend
                state := "WAVE_5"
                dir := macroUp ? 1.0 : -1.0
                float w5w1ratio = w1 > 0 ? w5 / w1 : 0.0
                w5fibValid := (w5w1ratio >= 0.50 and w5w1ratio <= 0.786) or (w5w1ratio >= 0.90 and w5w1ratio <= 1.10) or (w5w1ratio >= 1.50 and w5w1ratio <= 1.80)

    // WAVE_4
    if state == "UNKNOWN" and not na(p4)
        bool alt = (d0 != d1) and (d1 != d2) and (d2 != d3) and (d3 != d4)
        bool macroUp = p4 > p0
        bool macroDown = p4 < p0
        if alt and (macroUp or macroDown)
            float w1 = math.abs(p1 - p0)
            float w2 = math.abs(p2 - p1)
            float w3 = math.abs(p3 - p2)
            float w4 = math.abs(p4 - p3)
            bool w2noCross = macroUp ? (p2 > p0) : (p2 < p0)
            bool w2valid = w2 >= w1 * 0.236 and w2 < w1 * 0.999 and w2noCross
            bool w3valid = w3 >= w1 * w3MinMult
            float w1high = math.max(p0, p1)
            float w1low = math.min(p0, p1)
            float w4overlapTol = w1 * 0.10
            bool w4valid = macroUp ? (p4 > p1 - w4overlapTol) : (p4 < p1 + w4overlapTol)
            if w2valid and w3valid and w4valid
                state := "WAVE_4"
                dir := macroUp ? 1.0 : -1.0

    // WAVE_3
    if state == "UNKNOWN" and not na(p3)
        bool alt = (d0 != d1) and (d1 != d2) and (d2 != d3)
        bool macroUp = p3 > p0
        bool macroDown = p3 < p0
        if alt and (macroUp or macroDown)
            float w1 = math.abs(p1 - p0)
            float w2 = math.abs(p2 - p1)
            float w3 = math.abs(p3 - p2)
            bool w2noCross = macroUp ? (p2 > p0) : (p2 < p0)
            bool w2valid = w2 >= w1 * 0.236 and w2 < w1 * 0.999 and w2noCross
            bool w3valid = w3 >= w1 * w3MinMult
            if w2valid and w3valid
                state := "WAVE_3"
                dir := macroUp ? 1.0 : -1.0

    // WAVE_2
    if state == "UNKNOWN" and not na(p2)
        bool alt = (d0 != d1) and (d1 != d2)
        bool macroUp = p2 > p0
        bool macroDown = p2 < p0
        if alt and (macroUp or macroDown)
            float w1 = math.abs(p1 - p0)
            float w2 = math.abs(p2 - p1)
            bool w2noCross = macroUp ? (p2 > p0) : (p2 < p0)
            bool w2valid = w2 >= w1 * 0.236 and w2 < w1 * 0.999 and w2noCross
            if w2valid
                state := "WAVE_2"
                dir := macroUp ? 1.0 : -1.0

    // WAVE_1
    if state == "UNKNOWN" and not na(p1)
        bool alt = d0 != d1
        bool macroUp = p1 > p0
        bool macroDown = p1 < p0
        if alt and (macroUp or macroDown)
            state := "WAVE_1"
            dir := macroUp ? 1.0 : -1.0

    // Corrective ABC structure
    if state == "UNKNOWN" and not na(p3)
        if d1 == d3 and d0 != d1 and d1 != d2
            float wA = math.abs(p1 - p0)
            float wC = math.abs(p3 - p2)
            float wB = math.abs(p2 - p1)
            bool cMinExt = wA > 0 ? wC >= wA * 0.618 : true
            bool bRetrace = wA > 0 ? (wB / wA >= 0.382 and wB / wA <= 0.886) : true
            if cMinExt and bRetrace
                state := "WAVE_C"
                dir := math.sign(p0 - p3)
    if state == "UNKNOWN" and not na(p2)
        if d0 != d1 and d1 != d2
            float wA2 = math.abs(p1 - p0)
            float wB2 = math.abs(p2 - p1)
            bool bMinRetrace = wA2 > 0 ? wB2 / wA2 >= 0.382 : true
            if bMinRetrace
                state := "WAVE_B"
                dir := math.sign(p0 - p2)
    if state == "UNKNOWN" and not na(p1)
        if d0 != d1
            state := "WAVE_A"
            dir := math.sign(p0 - p1)

    [state, dir, truncated, validImpulse, w5fibValid]

resolveHtfState(bool enabled, float p0, float p1, float p2, float p3, float p4, float p5, int d0, int d1, int d2, int d3, int d4, int d5) =>
    if enabled
        classifyWaveState(p0, p1, p2, p3, p4, p5, d0, d1, d2, d3, d4, d5)
    else
        ["UNKNOWN", 0.0, false, false, false]

// ═════════════════════════════════════════════════════════════════════════════
// HTF PIVOT ENGINES (one per timeframe)
// ═════════════════════════════════════════════════════════════════════════════

calcHtf15() =>
    var float[] hPrices = array.new_float(0)
    var int[] hBars = array.new_int(0)
    var int[] hDirs = array.new_int(0)
    var int lastHDir = 0
    float ph = ta.pivothigh(high, 5, 5)
    float pl = ta.pivotlow(low, 5, 5)
    if not na(ph)
        lastHDir := pushHtfPivot(hPrices, hBars, hDirs, lastHDir, ph, 1, bar_index)
    if not na(pl)
        lastHDir := pushHtfPivot(hPrices, hBars, hDirs, lastHDir, pl, -1, bar_index)
    [p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5] = extractHtfLast6(hPrices, hBars, hDirs)
    [open, high, low, close, volume, p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5]

calcHtf60() =>
    var float[] hPrices = array.new_float(0)
    var int[] hBars = array.new_int(0)
    var int[] hDirs = array.new_int(0)
    var int lastHDir = 0
    float ph = ta.pivothigh(high, 8, 8)
    float pl = ta.pivotlow(low, 8, 8)
    if not na(ph)
        lastHDir := pushHtfPivot(hPrices, hBars, hDirs, lastHDir, ph, 1, bar_index)
    if not na(pl)
        lastHDir := pushHtfPivot(hPrices, hBars, hDirs, lastHDir, pl, -1, bar_index)
    [p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5] = extractHtfLast6(hPrices, hBars, hDirs)
    [open, high, low, close, volume, p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5]

calcHtf240() =>
    var float[] hPrices = array.new_float(0)
    var int[] hBars = array.new_int(0)
    var int[] hDirs = array.new_int(0)
    var int lastHDir = 0
    float ph = ta.pivothigh(high, 10, 10)
    float pl = ta.pivotlow(low, 10, 10)
    if not na(ph)
        lastHDir := pushHtfPivot(hPrices, hBars, hDirs, lastHDir, ph, 1, bar_index)
    if not na(pl)
        lastHDir := pushHtfPivot(hPrices, hBars, hDirs, lastHDir, pl, -1, bar_index)
    [p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5] = extractHtfLast6(hPrices, hBars, hDirs)
    [open, high, low, close, volume, p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5]

calcHtfD() =>
    var float[] hPrices = array.new_float(0)
    var int[] hBars = array.new_int(0)
    var int[] hDirs = array.new_int(0)
    var int lastHDir = 0
    float ph = ta.pivothigh(high, 5, 5)
    float pl = ta.pivotlow(low, 5, 5)
    if not na(ph)
        lastHDir := pushHtfPivot(hPrices, hBars, hDirs, lastHDir, ph, 1, bar_index)
    if not na(pl)
        lastHDir := pushHtfPivot(hPrices, hBars, hDirs, lastHDir, pl, -1, bar_index)
    [p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5] = extractHtfLast6(hPrices, hBars, hDirs)
    [open, high, low, close, volume, p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5]

calcMicro1() =>
    var float[] hPrices = array.new_float(0)
    var int[] hBars = array.new_int(0)
    var int[] hDirs = array.new_int(0)
    var int lastHDir = 0
    float ph = ta.pivothigh(high, 3, 3)
    float pl = ta.pivotlow(low, 3, 3)
    if not na(ph)
        lastHDir := pushHtfPivot(hPrices, hBars, hDirs, lastHDir, ph, 1, bar_index)
    if not na(pl)
        lastHDir := pushHtfPivot(hPrices, hBars, hDirs, lastHDir, pl, -1, bar_index)
    [p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5] = extractHtfLast6(hPrices, hBars, hDirs)
    [open, high, low, close, volume, p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5]

calcMicro3() =>
    var float[] hPrices = array.new_float(0)
    var int[] hBars = array.new_int(0)
    var int[] hDirs = array.new_int(0)
    var int lastHDir = 0
    float ph = ta.pivothigh(high, 3, 3)
    float pl = ta.pivotlow(low, 3, 3)
    if not na(ph)
        lastHDir := pushHtfPivot(hPrices, hBars, hDirs, lastHDir, ph, 1, bar_index)
    if not na(pl)
        lastHDir := pushHtfPivot(hPrices, hBars, hDirs, lastHDir, pl, -1, bar_index)
    [p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5] = extractHtfLast6(hPrices, hBars, hDirs)
    [open, high, low, close, volume, p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5]

calcMicro5() =>
    var float[] hPrices = array.new_float(0)
    var int[] hBars = array.new_int(0)
    var int[] hDirs = array.new_int(0)
    var int lastHDir = 0
    float ph = ta.pivothigh(high, 4, 4)
    float pl = ta.pivotlow(low, 4, 4)
    if not na(ph)
        lastHDir := pushHtfPivot(hPrices, hBars, hDirs, lastHDir, ph, 1, bar_index)
    if not na(pl)
        lastHDir := pushHtfPivot(hPrices, hBars, hDirs, lastHDir, pl, -1, bar_index)
    [p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5] = extractHtfLast6(hPrices, hBars, hDirs)
    [open, high, low, close, volume, p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5]

htfEmptyTuple() =>
    [open, high, low, close, volume, float(na), float(na), float(na), float(na), float(na), float(na), int(na), int(na), int(na), int(na), int(na), int(na), int(na), int(na), int(na), int(na), int(na), int(na)]

fetchHtf15(bool enabled) =>
    [o, h, l, c, v, p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5] = request.security(syminfo.tickerid, "15", calcHtf15(), lookahead=barmerge.lookahead_off)
    if isHighTf or not enabled
        htfEmptyTuple()
    else
        [o, h, l, c, v, p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5]

fetchHtf60(bool enabled) =>
    [o, h, l, c, v, p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5] = request.security(syminfo.tickerid, "60", calcHtf60(), lookahead=barmerge.lookahead_off)
    if isHighTf or not enabled
        htfEmptyTuple()
    else
        [o, h, l, c, v, p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5]

fetchHtf240(bool enabled) =>
    [o, h, l, c, v, p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5] = request.security(syminfo.tickerid, "240", calcHtf240(), lookahead=barmerge.lookahead_off)
    if isHighTf or not enabled
        htfEmptyTuple()
    else
        [o, h, l, c, v, p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5]

fetchHtfD(bool enabled) =>
    [o, h, l, c, v, p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5] = request.security(syminfo.tickerid, "D", calcHtfD(), lookahead=barmerge.lookahead_off)
    if isHighTf or not enabled
        htfEmptyTuple()
    else
        [o, h, l, c, v, p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5]

fetchMicro1(bool enabled) =>
    [o, h, l, c, v, p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5] = request.security(syminfo.tickerid, "1", calcMicro1(), lookahead=barmerge.lookahead_off)
    if isHighTf or not enabled
        htfEmptyTuple()
    else
        [o, h, l, c, v, p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5]

fetchMicro3(bool enabled) =>
    [o, h, l, c, v, p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5] = request.security(syminfo.tickerid, "3", calcMicro3(), lookahead=barmerge.lookahead_off)
    if isHighTf or not enabled
        htfEmptyTuple()
    else
        [o, h, l, c, v, p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5]

fetchMicro5(bool enabled) =>
    [o, h, l, c, v, p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5] = request.security(syminfo.tickerid, "5", calcMicro5(), lookahead=barmerge.lookahead_off)
    if isHighTf or not enabled
        htfEmptyTuple()
    else
        [o, h, l, c, v, p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, d0, d1, d2, d3, d4, d5]

// ═════════════════════════════════════════════════════════════════════════════
// MOMENTUM & VOLUME HELPERS
// ═════════════════════════════════════════════════════════════════════════════

// RSI divergence check
rsi = ta.rsi(close, 14)
rsiHigh = ta.pivothigh(rsi, 5, 5)
rsiLow = ta.pivotlow(rsi, 5, 5)

// MACD histogram
[macdLine, signalLine, macdHist] = ta.macd(close, 12, 26, 9)

// Volume average
volAvg = ta.sma(volume, 20)
volAvg10 = ta.sma(volume, 10)
rsiExNow = exhaustRsiLen == 14 ? rsi : ta.rsi(close, exhaustRsiLen)
rsiExPrev = ta.rsi(close[exhaustLookback], exhaustRsiLen)
projRngHi = ta.highest(high, 50)
projRngLo = ta.lowest(low, 50)
atr14 = ta.atr(14)
trendEma = ta.ema(close, trendEmaLength)

waveDirAligned(float waveDir) =>
    if not enableTrendFilter or waveDir == 0.0
        true
    else
        bool emaBull = close > trendEma
        bool aligned = (waveDir == 1.0 and emaBull) or (waveDir == -1.0 and not emaBull)
        if trendFilterMode == "Direction+Above/Below"
            aligned
        else
            aligned or close == trendEma

neonMarkerHalfHeight() =>
    math.max(atr14 * 0.08, syminfo.mintick * 25)

drawNeonZoneBox(float top, float bottom, color neonCol, int anchorRight) =>
    int boxR = anchorRight
    int boxL = boxR - zoneMarkerBars
    float half = neonMarkerHalfHeight()
    float effTop = top
    float effBot = bottom
    if effTop - effBot < half * 2
        float mid = math.avg(top, bottom)
        effTop := mid + half
        effBot := mid - half
    box.new(boxL, effTop, boxR, effBot, bgcolor=color.new(neonCol, 50), border_color=neonCol, border_width=2)

drawNeonPriceTick(float price, color neonCol, int anchorRight) =>
    int boxR = anchorRight
    int boxL = boxR - zoneMarkerBars
    float half = neonMarkerHalfHeight()
    box.new(boxL, price + half, boxR, price - half, bgcolor=color.new(neonCol, 50), border_color=neonCol, border_width=2)

drawLeadTargetTick(float price, color leadCol, int anchorRight) =>
    int boxR = anchorRight
    int boxL = boxR - zoneMarkerBars - 2
    float half = neonMarkerHalfHeight() * 1.35
    box.new(boxL, price + half, boxR, price - half, bgcolor=color.new(leadCol, 25), border_color=leadCol, border_width=3)

formatPctFromClose(float level) =>
    float pct = close != 0 ? (level - close) / close * 100.0 : 0.0
    string sign = pct >= 0 ? "+" : ""
    sign + str.tostring(pct, "#.##") + "%"

formatZonePctFromClose(float top, float bottom) =>
    if close >= bottom and close <= top
        "IN"
    else
        float ref = close < bottom ? bottom : top
        formatPctFromClose(ref)

levelLabelText(string name, float level) =>
    showZonePct ? name + " " + formatPctFromClose(level) : name

zoneLabelText(string name, float top, float bottom) =>
    showZonePct ? name + " " + formatZonePctFromClose(top, bottom) : name

levelLabelTextHR(string name, float level, int expectedDir) =>
    showZonePct ? name + " " + formatPctFromClose(level) + formatHitRate(level, expectedDir) : name

zonesPriceOverlap(float lo1, float hi1, float lo2, float hi2) =>
    float aLo = math.min(lo1, hi1)
    float aHi = math.max(lo1, hi1)
    float bLo = math.min(lo2, hi2)
    float bHi = math.max(lo2, hi2)
    aLo <= bHi and bLo <= aHi

countZoneOverlaps(int idx, float[] lows, float[] highs) =>
    int cnt = 1
    float zLo = array.get(lows, idx)
    float zHi = array.get(highs, idx)
    int n = array.size(lows)
    if n > 1
        for j = 0 to n - 1
            if j != idx and zonesPriceOverlap(zLo, zHi, array.get(lows, j), array.get(highs, j))
                cnt += 1
    cnt

pushMagnetZone(float[] lows, float[] highs, string[] tags, float zLo, float zHi, string tag) =>
    array.push(lows, math.min(zLo, zHi))
    array.push(highs, math.max(zLo, zHi))
    array.push(tags, tag)
    true

priceBand(float price) =>
    float band = math.abs(price) * 0.005
    [price - band, price + band]

awaitingFlatC(float[] prices, int[] dirs) =>
    int psz = array.size(prices)
    bool result = false
    if psz >= 2
        int dB = array.get(dirs, psz - 1)
        int dA = array.get(dirs, psz - 2)
        result := dA != dB
        if psz >= 4
            int dO = array.get(dirs, psz - 4)
            int d1 = array.get(dirs, psz - 3)
            int d2 = array.get(dirs, psz - 2)
            int d3 = array.get(dirs, psz - 1)
            bool flatConfirmed = (d1 == d3) and (d1 != d2) and (dO != d1)
            if flatConfirmed
                result := false
    result

isFlatABCComplete(int psz, int[] dirs) =>
    bool done = false
    if psz >= 4
        int dO = array.get(dirs, psz - 4)
        int dA = array.get(dirs, psz - 3)
        int dB = array.get(dirs, psz - 2)
        int dC = array.get(dirs, psz - 1)
        done := dA == dC and dA != dB and dO != dA
    done

computeFlatCLevels(float pOrigin, float pA, float pB, bool hasOrigin) =>
    float waveA = hasOrigin ? math.abs(pA - pOrigin) : math.abs(pB - pA)
    bool cUp = hasOrigin ? pA > pOrigin : pB > pA
    float C_min = cUp ? pB + waveA : pB - waveA
    float C_std = cUp ? pB + waveA * 1.236 : pB - waveA * 1.236
    float C_ext = cUp ? pB + waveA * 1.618 : pB - waveA * 1.618
    float C_run = cUp ? pB + waveA * 0.618 : pB - waveA * 0.618
    [C_min, C_std, C_ext, C_run, cUp]

// Resolve B-confirmed flat context for C projection (zigzag B or WAVE_B state)
getCAwaitingContext(string cState, float cp0, float cp1, float cp2, float[] prices, int[] dirs) =>
    bool active = false
    float pB = na
    float pA = na
    float pOrigin = na
    bool hasOrigin = false
    if awaitingFlatC(prices, dirs) and array.size(prices) >= 2
        int psz = array.size(prices)
        pB := array.get(prices, psz - 1)
        pA := array.get(prices, psz - 2)
        hasOrigin := psz >= 3
        pOrigin := hasOrigin ? array.get(prices, psz - 3) : na
        active := true
    else if cState == "WAVE_B" and not na(cp2) and not na(cp1)
        pB := cp2
        pA := cp1
        pOrigin := cp0
        hasOrigin := not na(cp0)
        active := true
    [active, pOrigin, pA, pB, hasOrigin]

// Reserve history for dynamic close lookups at pivot bar_index offsets
const int MAX_HIST_LOOKBACK = 1200
max_bars_back(close, MAX_HIST_LOOKBACK)
max_bars_back(high, MAX_HIST_LOOKBACK)
max_bars_back(low, MAX_HIST_LOOKBACK)
max_bars_back(volume, MAX_HIST_LOOKBACK)
max_bars_back(time, MAX_HIST_LOOKBACK)

// Precompute divergence inputs every bar (avoids CW10003)
float divPriceHigh = ta.highest(high, 10)
float divRsiHigh = ta.highest(rsi, 10)
float divPrevPriceHigh = ta.highest(high[10], 10)
float divPrevRsiHigh = ta.highest(rsi[10], 10)
float divPriceLow = ta.lowest(low, 10)
float divRsiLow = ta.lowest(rsi, 10)
float divPrevPriceLow = ta.lowest(low[10], 10)
float divPrevRsiLow = ta.lowest(rsi[10], 10)
bool bearishMomDiv = divPriceHigh > divPrevPriceHigh and divRsiHigh < divPrevRsiHigh
bool bullishMomDiv = divPriceLow < divPrevPriceLow and divRsiLow > divPrevRsiLow

// Safe historical close lookup from pivot bar_index
closeAtBar(int pivotBar) =>
    int barsBack = bar_index - pivotBar
    barsBack >= 0 and barsBack <= MAX_HIST_LOOKBACK ? close[barsBack] : na

hasMomentumDivergence(int cDir) =>
    cDir == 1 ? bearishMomDiv : bullishMomDiv

// ═════════════════════════════════════════════════════════════════════════════
// ADAPTIVE PIVOT STRENGTH
// ═════════════════════════════════════════════════════════════════════════════

float rawStrength = pivotStrength * getTfPivotScale() * getDegreeScale(waveDegree)
if adaptiveMode
    float atr = ta.atr(atrPeriod)
    float priceRange = ta.highest(high, atrPeriod) - ta.lowest(low, atrPeriod)
    float atrRatio = priceRange > 0 ? atr / priceRange : 0.5
    rawStrength := math.round(rawStrength * (1 + (atrRatio - 0.5) * 2))

float adaptiveStrength = math.round(ta.sma(rawStrength, 3))
float tfMinStrength = chartSecVal >= 14400 ? 6.0 : chartSecVal >= 7200 ? 5.0 : chartSecVal >= 3600 ? 4.0 : 2.0
adaptiveStrength := math.max(tfMinStrength, math.min(20, adaptiveStrength))

int lookbackBars = getLookbackBars(lookbackWindow)
int cutoffBar = bar_index - lookbackBars

// ═════════════════════════════════════════════════════════════════════════════
// ZIGZAG PIVOT ENGINE
// ═════════════════════════════════════════════════════════════════════════════

// Pivot detection
float pivotHigh = ta.pivothigh(high, int(adaptiveStrength), int(adaptiveStrength))
float pivotLow = ta.pivotlow(low, int(adaptiveStrength), int(adaptiveStrength))

// Track last pivot direction and values
var int lastPivotDir = 0     // 0=none, 1=high, -1=low
var float lastPivotPrice = na
var int lastPivotBar = na

// Arrays for storing pivot data
var float[] pivotPrices = array.new_float(0)
var int[] pivotBars = array.new_int(0)
var int[] pivotTimes = array.new_int(0)
var int[] pivotDirs = array.new_int(0)
var float[] pivotVols = array.new_float(0)
var float[] pivotVolAvgs = array.new_float(0)
var float[] pivotVolAvg10s = array.new_float(0)

// Detect new pivots
bool newHigh = not na(pivotHigh)
bool newLow = not na(pivotLow)
int pivotOffset = int(adaptiveStrength)
int pivotTime = time[pivotOffset]

// Replace same-direction pivots: keep the extreme one
if newHigh
    if lastPivotDir == 1 and array.size(pivotPrices) > 0
        // Same direction: replace if higher
        float prevHigh = array.get(pivotPrices, array.size(pivotPrices) - 1)
        if pivotHigh > prevHigh
            array.set(pivotPrices, array.size(pivotPrices) - 1, pivotHigh)
            array.set(pivotBars, array.size(pivotBars) - 1, bar_index - pivotOffset)
            array.set(pivotTimes, array.size(pivotTimes) - 1, pivotTime)
            array.set(pivotVols, array.size(pivotVols) - 1, volume[pivotOffset])
            array.set(pivotVolAvgs, array.size(pivotVolAvgs) - 1, volAvg[pivotOffset])
            array.set(pivotVolAvg10s, array.size(pivotVolAvg10s) - 1, volAvg10[pivotOffset])
        lastPivotPrice := pivotHigh
        lastPivotBar := bar_index - pivotOffset
    else
        // New direction
        array.push(pivotPrices, pivotHigh)
        array.push(pivotBars, bar_index - pivotOffset)
        array.push(pivotTimes, pivotTime)
        array.push(pivotDirs, 1)
        array.push(pivotVols, volume[pivotOffset])
        array.push(pivotVolAvgs, volAvg[pivotOffset])
        array.push(pivotVolAvg10s, volAvg10[pivotOffset])
        lastPivotDir := 1
        lastPivotPrice := pivotHigh
        lastPivotBar := bar_index - pivotOffset

if newLow
    if lastPivotDir == -1 and array.size(pivotPrices) > 0
        // Same direction: replace if lower
        float prevLow = array.get(pivotPrices, array.size(pivotPrices) - 1)
        if pivotLow < prevLow
            array.set(pivotPrices, array.size(pivotPrices) - 1, pivotLow)
            array.set(pivotBars, array.size(pivotBars) - 1, bar_index - pivotOffset)
            array.set(pivotTimes, array.size(pivotTimes) - 1, pivotTime)
            array.set(pivotVols, array.size(pivotVols) - 1, volume[pivotOffset])
            array.set(pivotVolAvgs, array.size(pivotVolAvgs) - 1, volAvg[pivotOffset])
            array.set(pivotVolAvg10s, array.size(pivotVolAvg10s) - 1, volAvg10[pivotOffset])
        lastPivotPrice := pivotLow
        lastPivotBar := bar_index - pivotOffset
    else
        // New direction
        array.push(pivotPrices, pivotLow)
        array.push(pivotBars, bar_index - pivotOffset)
        array.push(pivotTimes, pivotTime)
        array.push(pivotDirs, -1)
        array.push(pivotVols, volume[pivotOffset])
        array.push(pivotVolAvgs, volAvg[pivotOffset])
        array.push(pivotVolAvg10s, volAvg10[pivotOffset])
        lastPivotDir := -1
        lastPivotPrice := pivotLow
        lastPivotBar := bar_index - pivotOffset

// Cap chart pivot history (prevents memory errors on 2H+ timeframes)
while array.size(pivotBars) > 0 and array.get(pivotBars, 0) < cutoffBar
    array.shift(pivotPrices)
    array.shift(pivotBars)
    array.shift(pivotTimes)
    array.shift(pivotDirs)
    array.shift(pivotVols)
    array.shift(pivotVolAvgs)
    array.shift(pivotVolAvg10s)
while array.size(pivotPrices) > pivotHistoryCap
    array.shift(pivotPrices)
    array.shift(pivotBars)
    array.shift(pivotTimes)
    array.shift(pivotDirs)
    array.shift(pivotVols)
    array.shift(pivotVolAvgs)
    array.shift(pivotVolAvg10s)

// ═════════════════════════════════════════════════════════════════════════════
// MULTI-TIMEFRAME DATA PULLS & WAVE STATES
// ═════════════════════════════════════════════════════════════════════════════

[htf1_o, htf1_h, htf1_l, htf1_c, htf1_v, htf1_p0, htf1_p1, htf1_p2, htf1_p3, htf1_p4, htf1_p5, htf1_b0, htf1_b1, htf1_b2, htf1_b3, htf1_b4, htf1_b5, htf1_d0, htf1_d1, htf1_d2, htf1_d3, htf1_d4, htf1_d5] = fetchHtf15(useHtf15)
[htf2_o, htf2_h, htf2_l, htf2_c, htf2_v, htf2_p0, htf2_p1, htf2_p2, htf2_p3, htf2_p4, htf2_p5, htf2_b0, htf2_b1, htf2_b2, htf2_b3, htf2_b4, htf2_b5, htf2_d0, htf2_d1, htf2_d2, htf2_d3, htf2_d4, htf2_d5] = fetchHtf60(useHtf60)
[htf3_o, htf3_h, htf3_l, htf3_c, htf3_v, htf3_p0, htf3_p1, htf3_p2, htf3_p3, htf3_p4, htf3_p5, htf3_b0, htf3_b1, htf3_b2, htf3_b3, htf3_b4, htf3_b5, htf3_d0, htf3_d1, htf3_d2, htf3_d3, htf3_d4, htf3_d5] = fetchHtf240(useHtf240)
[htf4_o, htf4_h, htf4_l, htf4_c, htf4_v, htf4_p0, htf4_p1, htf4_p2, htf4_p3, htf4_p4, htf4_p5, htf4_b0, htf4_b1, htf4_b2, htf4_b3, htf4_b4, htf4_b5, htf4_d0, htf4_d1, htf4_d2, htf4_d3, htf4_d4, htf4_d5] = fetchHtfD(useHtfD)

[htf1_state, htf1_dir, htf1_truncated, htf1_valid, htf1_w5fibValid] = resolveHtfState(useHtf15, htf1_p0, htf1_p1, htf1_p2, htf1_p3, htf1_p4, htf1_p5, htf1_d0, htf1_d1, htf1_d2, htf1_d3, htf1_d4, htf1_d5)
[htf2_state, htf2_dir, htf2_truncated, htf2_valid, htf2_w5fibValid] = resolveHtfState(useHtf60, htf2_p0, htf2_p1, htf2_p2, htf2_p3, htf2_p4, htf2_p5, htf2_d0, htf2_d1, htf2_d2, htf2_d3, htf2_d4, htf2_d5)
[htf3_state, htf3_dir, htf3_truncated, htf3_valid, htf3_w5fibValid] = resolveHtfState(useHtf240, htf3_p0, htf3_p1, htf3_p2, htf3_p3, htf3_p4, htf3_p5, htf3_d0, htf3_d1, htf3_d2, htf3_d3, htf3_d4, htf3_d5)
[htf4_state, htf4_dir, htf4_truncated, htf4_valid, htf4_w5fibValid] = resolveHtfState(useHtfD, htf4_p0, htf4_p1, htf4_p2, htf4_p3, htf4_p4, htf4_p5, htf4_d0, htf4_d1, htf4_d2, htf4_d3, htf4_d4, htf4_d5)

[micro1_o, micro1_h, micro1_l, micro1_c, micro1_v, micro1_p0, micro1_p1, micro1_p2, micro1_p3, micro1_p4, micro1_p5, micro1_b0, micro1_b1, micro1_b2, micro1_b3, micro1_b4, micro1_b5, micro1_d0, micro1_d1, micro1_d2, micro1_d3, micro1_d4, micro1_d5] = fetchMicro1(useMicro1)
[micro3_o, micro3_h, micro3_l, micro3_c, micro3_v, micro3_p0, micro3_p1, micro3_p2, micro3_p3, micro3_p4, micro3_p5, micro3_b0, micro3_b1, micro3_b2, micro3_b3, micro3_b4, micro3_b5, micro3_d0, micro3_d1, micro3_d2, micro3_d3, micro3_d4, micro3_d5] = fetchMicro3(useMicro3)
[micro5_o, micro5_h, micro5_l, micro5_c, micro5_v, micro5_p0, micro5_p1, micro5_p2, micro5_p3, micro5_p4, micro5_p5, micro5_b0, micro5_b1, micro5_b2, micro5_b3, micro5_b4, micro5_b5, micro5_d0, micro5_d1, micro5_d2, micro5_d3, micro5_d4, micro5_d5] = fetchMicro5(useMicro5)

[micro1_state, micro1_dir, micro1_truncated, micro1_valid, micro1_w5fibValid] = resolveHtfState(useMicro1, micro1_p0, micro1_p1, micro1_p2, micro1_p3, micro1_p4, micro1_p5, micro1_d0, micro1_d1, micro1_d2, micro1_d3, micro1_d4, micro1_d5)
[micro3_state, micro3_dir, micro3_truncated, micro3_valid, micro3_w5fibValid] = resolveHtfState(useMicro3, micro3_p0, micro3_p1, micro3_p2, micro3_p3, micro3_p4, micro3_p5, micro3_d0, micro3_d1, micro3_d2, micro3_d3, micro3_d4, micro3_d5)
[micro5_state, micro5_dir, micro5_truncated, micro5_valid, micro5_w5fibValid] = resolveHtfState(useMicro5, micro5_p0, micro5_p1, micro5_p2, micro5_p3, micro5_p4, micro5_p5, micro5_d0, micro5_d1, micro5_d2, micro5_d3, micro5_d4, micro5_d5)

// Pattern age as a fraction of the active lookback window
patternAgePct(int cBar) =>
    float age = bar_index - cBar
    age / math.max(1, lookbackBars)

// Check whether current flat coincides with same-direction corrective HTF state
isFlatStack(int patType, int patDir) =>
    bool stack = false
    if patType == PATTERN_REGULAR or patType == PATTERN_EXPANDED
        if (useHtf15 and htf1_state == "WAVE_C" and htf1_dir == patDir) or (useHtf60 and htf2_state == "WAVE_C" and htf2_dir == patDir) or (useHtf240 and htf3_state == "WAVE_C" and htf3_dir == patDir) or (useHtfD and htf4_state == "WAVE_C" and htf4_dir == patDir) or (useHtf15 and htf1_state == "WAVE_B" and htf1_dir == patDir) or (useHtf60 and htf2_state == "WAVE_B" and htf2_dir == patDir) or (useHtf240 and htf3_state == "WAVE_B" and htf3_dir == patDir) or (useHtfD and htf4_state == "WAVE_B" and htf4_dir == patDir)
            stack := true
    stack

// Highest-probability fractal cascade: micro C inside HTF W4
isFractalCascade(int patDir) =>
    bool microCorrective = (useMicro1 and (micro1_state == "WAVE_C" or micro1_state == "WAVE_B") and micro1_dir == patDir) or (useMicro5 and (micro5_state == "WAVE_C" or micro5_state == "WAVE_B") and micro5_dir == patDir)
    bool htfW4 = (useHtf15 and htf1_state == "WAVE_4" and htf1_dir == patDir) or (useHtf60 and htf2_state == "WAVE_4" and htf2_dir == patDir)
    enableFractalCascade and microCorrective and htfW4

bool microScalpActive = useMicro1 and micro1_state == "WAVE_5" and (htf1_state == "WAVE_3" or htf1_state == "WAVE_C" or htf2_state == "WAVE_3" or htf2_state == "WAVE_C")

countTfAligned(float refDir) =>
    int n = 0
    if refDir != 0.0
        if useHtfD and htf4_state != "UNKNOWN" and htf4_dir == refDir
            n += 1
        if useHtf240 and htf3_state != "UNKNOWN" and htf3_dir == refDir
            n += 1
        if useHtf60 and htf2_state != "UNKNOWN" and htf2_dir == refDir
            n += 1
        if useHtf15 and htf1_state != "UNKNOWN" and htf1_dir == refDir
            n += 1
        if useMicro5 and micro5_state != "UNKNOWN" and micro5_dir == refDir
            n += 1
        if useMicro3 and micro3_state != "UNKNOWN" and micro3_dir == refDir
            n += 1
        if useMicro1 and micro1_state != "UNKNOWN" and micro1_dir == refDir
            n += 1
    n

getCurrentWaveState() =>
    [cp0, cp1, cp2, cp3, cp4, cp5, cb0, cb1, cb2, cb3, cb4, cb5, cd0, cd1, cd2, cd3, cd4, cd5] = extractHtfLast6(pivotPrices, pivotBars, pivotDirs)
    [cstate, cdir, ctrunc, cvalid, cw5fibValid] = classifyWaveState(cp0, cp1, cp2, cp3, cp4, cp5, cd0, cd1, cd2, cd3, cd4, cd5)
    float cw1 = math.abs(cp1 - cp0)
    float cw2 = math.abs(cp2 - cp1)
    float cw3 = math.abs(cp3 - cp2)
    float cw4 = math.abs(cp4 - cp3)
    float cw5 = math.abs(cp5 - cp4)
    [cstate, cdir, ctrunc, cvalid, cw1, cw2, cw3, cw4, cw5, cb3, cb4, cw5fibValid]

[chartState, chartDir, chartTruncated, chartValidImpulse, chartW1, chartW2, chartW3, chartW4, chartW5, chartW3Bar, chartW4Bar, chartW5FibValid] = getCurrentWaveState()

bool truncatedW5Active = enableTruncatedSignal and chartState == "WAVE_5" and chartTruncated and chartValidImpulse
float effTolerancePct = truncatedW5Active ? tolerancePct * 1.4 : tolerancePct

int pivotCount = array.size(pivotPrices)
bool bConfirmed = awaitingFlatC(pivotPrices, pivotDirs)

// Latch flat B→C context from B pivot until C completes (survives extra pivot history)
var bool flatBLatched = false
var float flatLatchP0 = na
var float flatLatchPA = na
var float flatLatchPB = na
var int flatLatchBBar = na
var int prevLastPivotBar = na

if barstate.isconfirmed and pivotCount >= 1
    int lastBar = array.get(pivotBars, pivotCount - 1)
    bool newPivot = na(prevLastPivotBar) or lastBar != prevLastPivotBar
    if newPivot and pivotCount >= 3
        int dB = array.get(pivotDirs, pivotCount - 1)
        int dA = array.get(pivotDirs, pivotCount - 2)
        int dO = array.get(pivotDirs, pivotCount - 3)
        float p0 = array.get(pivotPrices, pivotCount - 3)
        float pA = array.get(pivotPrices, pivotCount - 2)
        float pB = array.get(pivotPrices, pivotCount - 1)
        float wA = math.abs(pA - p0)
        float wB = math.abs(pB - pA)
        bool validBCandidate = dO != dA and dA != dB and wA > 0 and wB / wA >= 0.25
        bool completingC = pivotCount >= 4 and array.get(pivotDirs, pivotCount - 3) == dB
        if validBCandidate and not completingC
            flatBLatched := true
            flatLatchP0 := p0
            flatLatchPA := pA
            flatLatchPB := pB
            flatLatchBBar := lastBar
    if flatBLatched and pivotCount >= 4 and isFlatABCComplete(pivotCount, pivotDirs)
        int cBar = array.get(pivotBars, pivotCount - 1)
        if cBar > flatLatchBBar
            flatBLatched := false
    if flatBLatched and not na(flatLatchP0)
        bool invBreak = flatLatchPA > flatLatchP0 ? close < flatLatchP0 : close > flatLatchP0
        if invBreak
            flatBLatched := false
    prevLastPivotBar := lastBar
bool chartW3W4VolOk = false
if (chartState == "WAVE_4" or chartState == "WAVE_5") and pivotCount >= 3
    int w3idx = chartState == "WAVE_4" ? pivotCount - 2 : pivotCount - 3
    int w4idx = chartState == "WAVE_4" ? pivotCount - 1 : pivotCount - 2
    float w3v = array.get(pivotVols, w3idx)
    float w3va = array.get(pivotVolAvgs, w3idx)
    float w4v = array.get(pivotVols, w4idx)
    float w4va10 = array.get(pivotVolAvg10s, w4idx)
    chartW3W4VolOk := w3v > w3va * 1.2 and w4v < w4va10

var bool tier1Flash = false
var int tier1FlashDir = 0
var bool cascadeAlerted = false
var bool fractalCascadeAlerted = false
tier1Flash := false
cascadeAlerted := false
fractalCascadeAlerted := false

// HTF confluence bonus helper (called when a pattern is confirmed)
calcHtfBonus(int patDir) =>
    int signalDir = -patDir
    float bonus = 0.0
    if chartState == "WAVE_5" and chartValidImpulse
        bonus += 30
    if chartDir != 0.0 and htf1_state != "UNKNOWN" and chartDir == htf1_dir
        bonus += 25
    if htf1_dir != 0.0 and htf2_state != "UNKNOWN" and htf1_dir == htf2_dir
        bonus += 20
    if htf2_dir != 0.0 and htf3_state != "UNKNOWN" and htf2_dir == htf3_dir
        bonus += 15
    if htf4_dir != 0.0 and signalDir == int(htf4_dir)
        bonus += 10
    if hasMomentumDivergence(patDir)
        bonus += 10
    if chartW3W4VolOk
        bonus += 10
    // W3 is longest wave
    if (chartState == "WAVE_3" or chartState == "WAVE_4" or chartState == "WAVE_5") and chartW3 >= chartW1 and (chartState == "WAVE_3" ? true : chartW3 >= chartW5)
        bonus += 5
    // W5 Fib ratio alignment
    if chartState == "WAVE_5" and chartW5FibValid
        bonus += 5
    // Fib relationships valid (W2 50-78.6% of W1, W4 23.6-38.2% of W3)
    bool fibRelOk = false
    if chartW1 > 0
        float w2ratio = chartW2 / chartW1
        bool w2fib = w2ratio >= 0.50 and w2ratio <= 0.786
        bool w4fib = true
        if chartState == "WAVE_4" or chartState == "WAVE_5"
            if chartW3 > 0
                float w4ratio = chartW4 / chartW3
                w4fib := w4ratio >= 0.236 and w4ratio <= 0.382
            else
                w4fib := false
        fibRelOk := w2fib and w4fib
    if fibRelOk
        bonus += 5
    // Micro timeframe alignment bonuses
    if useMicro5 and micro5_dir != 0.0 and htf1_state != "UNKNOWN" and micro5_dir == htf1_dir
        bonus += 15
    if useMicro1 and micro1_state == "WAVE_5" and micro5_dir != 0.0 and micro1_dir == micro5_dir
        bonus += 10
    if useMicro1 and useMicro3 and useMicro5 and micro1_dir != 0.0 and micro1_dir == micro3_dir and micro1_dir == micro5_dir
        bonus += 10
    if chartState == "WAVE_5" and useMicro5 and micro5_state == "WAVE_3"
        bonus += 5
    math.min(170, bonus)

float htfBonusForPat1 = calcHtfBonus(1)
float htfBonusForPatNeg1 = calcHtfBonus(-1)

// ═════════════════════════════════════════════════════════════════════════════
// CHART IMPULSE 1-2-3-4-5 RENDERING
// ═════════════════════════════════════════════════════════════════════════════

var label[] impulseLabels = array.new_label(0)
var line[] impulseLines = array.new_line(0)
var label microScalpLbl = na
var line liveWaveLine = na
var label liveWaveLbl = na
var label truncatedW5Lbl = na
var label w4ProgressLbl = na
var box w4ProgressBox = na
var line projALine = na
var box projBBox = na
var label projBLbl = na
var line projBLine = na
var box projCBox = na
var label projCLbl = na
var line projCLine = na
var line tradeEntryLine = na
var line tradeSLLine = na
var line tradeTP1Line = na
var line tradeTP2Line = na
var label tradeRRLabel = na
var line cChartLine100 = na
var line cChartLine124 = na
var line cChartLine162 = na
var label cChartLbl = na
var label preEntryLbl = na
var bool truncatedW5Alerted = false
var bool preEntryAlerted = false
var int lastPredictiveDrawBar = -1
var string prevChartState = "UNKNOWN"
var bool prevChartTruncated = false
var bool prevCascadeScalp = false
var bool prevMicro1W5 = false

[ip0, ip1, ip2, ip3, ip4, ip5, ib0, ib1, ib2, ib3, ib4, ib5, id0, id1, id2, id3, id4, id5] = extractHtfLast6(pivotPrices, pivotBars, pivotDirs)
[ctxAwaiting, ctxPorigin, ctxPa, ctxPb, ctxHasOrigin] = getCAwaitingContext(chartState, ip0, ip1, ip2, pivotPrices, pivotDirs)
bool cAwaiting = flatBLatched or ctxAwaiting
float cPorigin = flatBLatched ? flatLatchP0 : ctxPorigin
float cPa = flatBLatched ? flatLatchPA : ctxPa
float cPb = flatBLatched ? flatLatchPB : ctxPb
bool cHasOrigin = flatBLatched ? not na(flatLatchP0) : ctxHasOrigin
int cBBar = flatBLatched ? flatLatchBBar : (pivotCount >= 1 ? array.get(pivotBars, pivotCount - 1) : bar_index)
int impulseWaves = impulseWaveCount(chartState)
bool bullishImpulse = chartDir == 1.0

while array.size(impulseLabels) > 0
    label.delete(array.shift(impulseLabels))
while array.size(impulseLines) > 0
    line.delete(array.shift(impulseLines))
if not na(microScalpLbl)
    label.delete(microScalpLbl)
    microScalpLbl := na
if not na(truncatedW5Lbl)
    label.delete(truncatedW5Lbl)
    truncatedW5Lbl := na

// In Focus Mode we still always draw flat patterns; impulse labels are controlled by showImpulseLabels
bool hideImpulseLabels = focusMode ? true : not showImpulseLabels

if not hideImpulseLabels
    if chartState == "UNKNOWN"
        if pivotCount > 0
            int lastB = clampDrawBar(array.get(pivotBars, pivotCount - 1))
            float lastP = array.get(pivotPrices, pivotCount - 1)
            array.push(impulseLabels, label.new(lastB, lastP, "?", style=label.style_label_center, color=color.new(color.gray, 70), textcolor=color.gray, size=size.tiny))
    else if impulseWaves >= 1
        for w = 1 to impulseWaves
            float wp = w == 1 ? ip1 : w == 2 ? ip2 : w == 3 ? ip3 : w == 4 ? ip4 : ip5
            int wb = w == 1 ? clampDrawBar(ib1) : w == 2 ? clampDrawBar(ib2) : w == 3 ? clampDrawBar(ib3) : w == 4 ? clampDrawBar(ib4) : clampDrawBar(ib5)
            if not na(wp) and not na(wb)
                if w == 3
                    array.push(impulseLabels, label.new(wb, wp, "3", style=getImpulseLblStyle(bullishImpulse, w), color=color.new(bullishImpulse ? color.lime : color.red, 30), textcolor=color.black, size=size.small, yloc=yloc.price))
                else if w == 4
                    array.push(impulseLabels, label.new(wb, wp, "⚡4", style=getImpulseLblStyle(bullishImpulse, w), color=color.new(color.yellow, 20), textcolor=color.black, size=size.small, yloc=yloc.price))
                else if w == 5
                    array.push(impulseLabels, label.new(wb, wp, chartTruncated ? "5T" : "5", style=getImpulseLblStyle(bullishImpulse, w), color=color.new(chartTruncated ? color.gray : color.orange, 20), textcolor=color.white, size=size.small, yloc=yloc.price))
                else
                    array.push(impulseLabels, label.new(wb, wp, str.tostring(w), style=getImpulseLblStyle(bullishImpulse, w), color=color.new(color.gray, 88), textcolor=color.white, size=size.tiny, yloc=yloc.price))
        for seg = 1 to impulseWaves
            float pA = seg == 1 ? ip0 : seg == 2 ? ip1 : seg == 3 ? ip2 : seg == 4 ? ip3 : ip4
            float pB = seg == 1 ? ip1 : seg == 2 ? ip2 : seg == 3 ? ip3 : seg == 4 ? ip4 : ip5
            int bA = seg == 1 ? clampDrawBar(ib0) : seg == 2 ? clampDrawBar(ib1) : seg == 3 ? clampDrawBar(ib2) : seg == 4 ? clampDrawBar(ib3) : clampDrawBar(ib4)
            int bB = seg == 1 ? clampDrawBar(ib1) : seg == 2 ? clampDrawBar(ib2) : seg == 3 ? clampDrawBar(ib3) : seg == 4 ? clampDrawBar(ib4) : clampDrawBar(ib5)
            if not na(pA) and not na(pB) and not na(bA) and not na(bB)
                array.push(impulseLines, line.new(bA, pA, bB, pB, color=getImpulseLineColor(seg, bullishImpulse), width=2, style=line.style_solid))

    // Truncated W5 reversal marker
    if enableTruncatedSignal and chartState == "WAVE_5" and chartTruncated and chartValidImpulse
        float tw5Y = chartDir == 1.0 ? high + atr14 * 0.7 : low - atr14 * 0.7
        truncatedW5Lbl := label.new(bar_index, tw5Y, "5T REVERSAL", style=chartDir == 1.0 ? label.style_label_down : label.style_label_up, color=color.new(truncatedColor, 20), textcolor=color.white, size=size.small, yloc=yloc.price)

if showImpulseLabels and not focusMode
    // Live forming wave (optional — off by default; draws to current price)
    if not na(liveWaveLine)
        line.delete(liveWaveLine)
        liveWaveLine := na
    if not na(liveWaveLbl)
        label.delete(liveWaveLbl)
        liveWaveLbl := na
    if not na(w4ProgressLbl)
        label.delete(w4ProgressLbl)
        w4ProgressLbl := na
    if not na(w4ProgressBox)
        box.delete(w4ProgressBox)
        w4ProgressBox := na

    if showLiveWave and chartState != "UNKNOWN" and pivotCount >= 1
        int nextWaveNum = impulseWaves + 1
        int lastPivBar = clampDrawBar(array.get(pivotBars, pivotCount - 1))
        float lastPivPrice = array.get(pivotPrices, pivotCount - 1)

        if nextWaveNum >= 1 and nextWaveNum <= 5
            color liveCol = getImpulseWaveColor(nextWaveNum, bullishImpulse)

            bool inW4Zone = false
            if nextWaveNum == 4 and not na(ip3) and chartW3 > 0
                float w4ZMin = chartDir == 1.0 ? ip3 - chartW3 * 0.382 : ip3 + chartW3 * 0.236
                float w4ZMax = chartDir == 1.0 ? ip3 - chartW3 * 0.236 : ip3 + chartW3 * 0.382
                inW4Zone := close >= math.min(w4ZMin, w4ZMax) and close <= math.max(w4ZMin, w4ZMax)

            liveWaveLine := line.new(
                 lastPivBar, lastPivPrice,
                 bar_index, close,
                 color=inW4Zone ? color.new(color.yellow, 20) : color.new(liveCol, 50),
                 width=1,
                 style=inW4Zone ? line.style_solid : line.style_dashed)

            string liveText = str.tostring(nextWaveNum) + "→"
            if inW4Zone
                liveText := "⚡4→"
            if nextWaveNum == 5 and not na(ip3)
                bool pastMin = chartDir == 1.0 ? close >= ip3 : close <= ip3
                if pastMin
                    liveText := "5→MIN✓"
            liveWaveLbl := label.new(
                 bar_index, close, liveText,
                 style=bullishImpulse ? label.style_label_down : label.style_label_up,
                 color=inW4Zone ? color.new(color.yellow, 40) : color.new(liveCol, 70),
                 textcolor=color.white,
                 size=size.tiny,
                 yloc=yloc.price)

    // Wave 4 live Fib progress bar
    if enableW4Progress and chartState == "WAVE_4" and not na(ip4) and chartW3 > 0 and not na(ip3)
        float zoneLo = chartDir == 1.0 ? ip3 - chartW3 * 0.382 : ip3 + chartW3 * 0.236
        float zoneHi = chartDir == 1.0 ? ip3 - chartW3 * 0.236 : ip3 + chartW3 * 0.382
        float zoneSpan = math.abs(zoneHi - zoneLo)
        float dist = chartDir == 1.0 ? ip3 - close : close - ip3
        float pct = zoneSpan > 0 ? math.max(0.0, math.min(100.0, dist / zoneSpan * 100.0)) : 0.0
        string pctText = "W4: " + str.tostring(pct, "#") + "% into zone"
        float lblY = chartDir == 1.0 ? low - atr14 * 0.8 : high + atr14 * 0.8
        w4ProgressLbl := label.new(bar_index, lblY, pctText, style=chartDir == 1.0 ? label.style_label_up : label.style_label_down, color=color.new(progressBarColor, 20), textcolor=color.black, size=size.small, yloc=yloc.price)
        // Mini progress bar box
        float half = atr14 * 0.1
        w4ProgressBox := box.new(bar_index - 3, lblY + half, bar_index + 3, lblY - half, bgcolor=color.new(progressBarColor, 50), border_color=color.new(progressBarColor, 0), border_width=1)

// Micro sub-wave labels (recent bars only)
float chartTfMin = timeframe.in_seconds() / 60.0
bool onMicroChart = chartTfMin <= 5.0
if not focusMode and onMicroChart and (useMicro1 or useMicro3 or useMicro5)
    color microCol = micro1_dir == 1.0 ? color.new(#00FFB3, 0) : color.new(#FF6B6B, 0)
    if useMicro5 and micro5_state != "UNKNOWN" and bar_index - clampDrawBar(micro5_b3) <= 20
        array.push(impulseLabels, label.new(bar_index - 1, high, "5m" + str.replace(micro5_state, "WAVE_", ""), style=label.style_label_lower_left, color=na, textcolor=microCol, size=size.tiny))

// Cascade alignment (info table + alerts only)
float refDir = chartDir != 0.0 ? chartDir : htf1_dir
int alignedCount = countTfAligned(refDir)

// Impulse / micro / cascade alerts
if barstate.isconfirmed
    if chartState == "WAVE_5" and chartValidImpulse and prevChartState != "WAVE_5"
        string impSide = chartDir == 1.0 ? "LONG" : "SHORT"
        alert("🔢 IMPULSE COMPLETE — Full 1-2-3-4-5 confirmed on chart TF. Direction: " + impSide, alert.freq_once_per_bar_close)
    if chartState == "WAVE_4" and prevChartState != "WAVE_4"
        alert("⚡4 WAVE 4 LIVE — Chart Wave 4 in progress. Load W5 position.", alert.freq_once_per_bar_close)
    if chartState == "WAVE_5" and chartTruncated and prevChartState != "WAVE_5"
        alert("⚠️ TRUNCATED W5 — Wave 5 truncated on chart TF. Weakness signal.", alert.freq_once_per_bar_close)
    if microScalpActive and not prevMicro1W5
        string scalpSide = micro1_dir == 1.0 ? "LONG" : "SHORT"
        alert("⚡ MICRO W5 COMPLETE — 1m Wave 5 finished inside HTF Wave 3. SCALP " + scalpSide, alert.freq_once_per_bar_close)
    if alignedCount >= 3 and microScalpActive and not prevCascadeScalp
        string casSide = refDir == 1.0 ? "LONG" : "SHORT"
        alert("🔥 CASCADE — " + str.tostring(alignedCount) + " timeframes aligned " + casSide + ". Micro W5 scalp active.", alert.freq_once_per_bar_close)
    prevChartState := chartState
    prevChartTruncated := chartTruncated
    prevMicro1W5 := microScalpActive
    prevCascadeScalp := alignedCount >= 3 and microScalpActive

// ═════════════════════════════════════════════════════════════════════════════
// PREDICTIVE A→B→C PROJECTION (drawn before the flat is fully confirmed)
// ═════════════════════════════════════════════════════════════════════════════

// Clean up projection objects from previous bar
if not na(projALine)
    line.delete(projALine)
    projALine := na
if not na(projBBox)
    box.delete(projBBox)
    projBBox := na
if not na(projBLbl)
    label.delete(projBLbl)
    projBLbl := na
if not na(projBLine)
    line.delete(projBLine)
    projBLine := na
if not na(projCBox)
    box.delete(projCBox)
    projCBox := na
if not na(projCLbl)
    label.delete(projCLbl)
    projCLbl := na
if not na(projCLine)
    line.delete(projCLine)
    projCLine := na
if not na(tradeEntryLine)
    line.delete(tradeEntryLine)
    tradeEntryLine := na
if not na(tradeSLLine)
    line.delete(tradeSLLine)
    tradeSLLine := na
if not na(tradeTP1Line)
    line.delete(tradeTP1Line)
    tradeTP1Line := na
if not na(tradeTP2Line)
    line.delete(tradeTP2Line)
    tradeTP2Line := na
if not na(tradeRRLabel)
    label.delete(tradeRRLabel)
    tradeRRLabel := na

bool predictiveActive = enablePredictive and not isHighTf
int aPsz = array.size(pivotPrices)
bool waveAState = chartState == "WAVE_A"
bool waveBState = chartState == "WAVE_B" or cAwaiting

// Always show predictive projection when a potential flat / ABC correction is forming
bool showPredictiveNow = predictiveActive and aPsz >= 2

// Stage 1 & 2: A confirmed → project B zone; B confirmed → project C zone + trade preview
if showPredictiveNow
    [aActive, pOrigin, pA, aUp, bA] = getAContext(pivotPrices, pivotBars, pivotDirs)
    int endBar = bar_index + labelRightBars + zoneMarkerBars
    bool aValid = aActive and isAValid(pOrigin, pA, pivotPrices, pivotVols, pivotVolAvgs, atr14)

    // Stage 1: B projection (requires valid A)
    if aValid and showBZone and waveAState
        float waveA = math.abs(pA - pOrigin)
        [regLo, regHi, expLo, expHi] = computeBZones(pOrigin, pA, aUp)
        float regMid = math.avg(regLo, regHi)
        float expMid = math.avg(expLo, expHi)
        int bAnchor = rightLabelBar()
        projALine := line.new(clampDrawBar(bA), pA, endBar, regMid, color=color.new(regularColor, 0), width=2, style=line.style_dashed)
        projBBox := drawNeonZoneBox(regHi, regLo, regularColor, bAnchor)
        projBLbl := label.new(bAnchor + 1, regMid, zoneLabelText("→B REG", regHi, regLo), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.white, size=size.small)
        if showCZone
            int expAnchor = bAnchor + zoneMarkerBars + 3
            projBLine := line.new(clampDrawBar(bA), pA, endBar, expMid, color=color.new(expandedColor, 0), width=2, style=line.style_dashed)
            box expBox = drawNeonZoneBox(expHi, expLo, expandedColor, expAnchor)
            label expLbl = label.new(expAnchor + 1, expMid, zoneLabelText("→B EXP", expHi, expLo), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.white, size=size.small)
            projCBox := expBox
            projCLbl := expLbl

    // Stage 2: C projection after B — independent of A validation (B trigger is the gate)
    if waveBState and not na(cPb)
        float waveA = cHasOrigin ? math.abs(cPa - cPorigin) : math.abs(cPb - cPa)
        int leanType = classifyFlatTypeFromB(cPorigin, cPa, cPb)
        [C_min, C_std, C_ext, C_run, cUp] = computeFlatCLevels(cPorigin, cPa, cPb, cHasOrigin)
        int cAnchor = rightLabelBar()
        int bBar = aPsz >= 1 ? array.get(pivotBars, aPsz - 1) : bar_index
        if flatBLatched
            bBar := flatLatchBBar

        if showCZone
            color cCol = leanType == PATTERN_EXPANDED ? expandedColor : leanType == PATTERN_RUNNING ? runningColor : regularColor
            float cMid = leanType == PATTERN_EXPANDED ? math.avg(C_std, C_ext) : leanType == PATTERN_RUNNING ? C_run : math.avg(C_min, C_std)
            float cTop = leanType == PATTERN_EXPANDED ? C_ext : leanType == PATTERN_RUNNING ? C_std : C_std
            float cBot = leanType == PATTERN_EXPANDED ? C_std : leanType == PATTERN_RUNNING ? C_min : C_min
            projCLine := line.new(clampDrawBar(bBar), cPb, endBar, cMid, color=color.new(cCol, 0), width=2, style=line.style_dashed)
            projCBox := drawNeonZoneBox(cTop, cBot, cCol, cAnchor)
            string cName = leanType == PATTERN_EXPANDED ? "→C EXT" : leanType == PATTERN_RUNNING ? "→C RUN" : "→C REG"
            projCLbl := label.new(cAnchor + 1, math.avg(cTop, cBot), zoneLabelText(cName, cTop, cBot), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.white, size=size.small)

        if showTradePreview and leanType != PATTERN_RUNNING and aActive
            float entry = math.avg(C_min, C_std)
            bool expandedFlat = leanType == PATTERN_EXPANDED
            float sl = expandedFlat ? (cUp ? cPb + atr14 * 0.3 : cPb - atr14 * 0.3) : (cUp ? math.max(pOrigin, cPa) + atr14 * 0.2 : math.min(pOrigin, cPa) - atr14 * 0.2)
            float tp1 = cHasOrigin ? cPorigin : cPa
            float waveRange = math.max(waveA, math.abs(cPb - cPa))
            float tp2 = cUp ? tp1 - waveRange * 1.618 : tp1 + waveRange * 1.618
            color tradeCol = color.new(preEntryColor, 0)
            int startBar = bar_index
            tradeEntryLine := hlineRight(startBar, entry, tradeCol, 1)
            tradeSLLine := hlineRight(startBar, sl, color.new(color.red, 0), 1)
            tradeTP1Line := hlineRight(startBar, tp1, color.new(color.lime, 0), 1)
            tradeTP2Line := hlineRight(startBar, tp2, color.new(color.aqua, 0), 1)
            float rr = math.abs(entry - tp1) / math.abs(sl - entry)
            tradeRRLabel := label.new(bar_index + 2, entry, "R/R " + str.tostring(rr, "#.##"), style=label.style_label_left, color=color.new(#0D0D0D, 10), textcolor=tradeCol, size=size.tiny)

lastPredictiveDrawBar := bar_index

// ═════════════════════════════════════════════════════════════════════════════
// PATTERN DETECTION
// ═════════════════════════════════════════════════════════════════════════════

// Arrays for storing confirmed patterns
var float[] patternA = array.new_float(0)
var float[] patternB = array.new_float(0)
var float[] patternC = array.new_float(0)
var float[] patternP0 = array.new_float(0)
var int[] patternABar = array.new_int(0)
var int[] patternBBar = array.new_int(0)
var int[] patternCBar = array.new_int(0)
var int[] patternCTime = array.new_int(0)
var int[] patternType = array.new_int(0)
var float[] patternBARatio = array.new_float(0)
var float[] patternCARatio = array.new_float(0)
var int[] patternDir = array.new_int(0)
var float[] patternScore = array.new_float(0)
var float[] patternHtfBonus = array.new_float(0)
var float[] patternQuality = array.new_float(0)
var int[] patternRevFactors = array.new_int(0)
var bool[] patternInvalid = array.new_bool(0)

// Arrays for pattern objects (3 signals + 3 letter labels + 1 type label, 2 lines, 1 box)
var label[] patternSigA = array.new_label(0)
var label[] patternSigB = array.new_label(0)
var label[] patternSigC = array.new_label(0)
var label[] patternLblA = array.new_label(0)
var label[] patternLblB = array.new_label(0)
var label[] patternLblC = array.new_label(0)
var label[] patternLblType = array.new_label(0)
var line[] patternLineAB = array.new_line(0)
var line[] patternLineBC = array.new_line(0)
var box[] patternBox = array.new_box(0)
var label[] patternFacDot0 = array.new_label(0)
var label[] patternFacDot1 = array.new_label(0)
var label[] patternFacDot2 = array.new_label(0)
var label[] patternFacDot3 = array.new_label(0)
var label[] patternFacDot4 = array.new_label(0)

// Extra pattern state arrays
var bool[] patternFlatStack = array.new_bool(0)
var bool[] patternIsCascade = array.new_bool(0)
var bool[] patternStale = array.new_bool(0)
var line[] patternInvalidX1 = array.new_line(0)
var line[] patternInvalidX2 = array.new_line(0)

// Predictive projection objects declared above (impulse rendering section)

// Arrays for 5-wave completion tracking
var int[] fiveWavePatternIdx = array.new_int(0)
var float[] fiveWaveP4 = array.new_float(0)
var float[] fiveWaveP5 = array.new_float(0)
var int[] fiveWaveP4Bar = array.new_int(0)
var int[] fiveWaveP5Bar = array.new_int(0)
var int[] fiveWaveDir = array.new_int(0)
var bool[] fiveWaveComplete = array.new_bool(0)
var bool[] fiveWaveRetestActive = array.new_bool(0)
var bool[] fiveWaveRetestConfirmed = array.new_bool(0)
var label[] fiveWaveLabels = array.new_label(0)
var label[] retestLabels = array.new_label(0)

purgeFiveWaveForPattern(int removedIdx) =>
    int j = 0
    while j < array.size(fiveWavePatternIdx)
        int pIdx = array.get(fiveWavePatternIdx, j)
        if pIdx == removedIdx
            array.remove(fiveWavePatternIdx, j)
            array.remove(fiveWaveP4, j)
            array.remove(fiveWaveP5, j)
            array.remove(fiveWaveP4Bar, j)
            array.remove(fiveWaveP5Bar, j)
            array.remove(fiveWaveDir, j)
            array.remove(fiveWaveComplete, j)
            array.remove(fiveWaveRetestActive, j)
            array.remove(fiveWaveRetestConfirmed, j)
            label lblRm = array.remove(fiveWaveLabels, j)
            if not na(lblRm)
                label.delete(lblRm)
        if pIdx != removedIdx
            if pIdx > removedIdx
                array.set(fiveWavePatternIdx, j, pIdx - 1)
            j += 1

purgePatternFactorDots(int idx) =>
    label d0 = array.remove(patternFacDot0, idx)
    label d1 = array.remove(patternFacDot1, idx)
    label d2 = array.remove(patternFacDot2, idx)
    label d3 = array.remove(patternFacDot3, idx)
    label d4 = array.remove(patternFacDot4, idx)
    if not na(d0)
        label.delete(d0)
    if not na(d1)
        label.delete(d1)
    if not na(d2)
        label.delete(d2)
    if not na(d3)
        label.delete(d3)
    if not na(d4)
        label.delete(d4)

removeFlatPatternAt(int idx) =>
    purgeFiveWaveForPattern(idx)
    removeGraphicsAt(patternSigA, patternSigB, patternSigC, patternLblA, patternLblB, patternLblC, patternLblType, patternLineAB, patternLineBC, patternBox, idx)
    purgePatternFactorDots(idx)
    line ix1 = array.remove(patternInvalidX1, idx)
    line ix2 = array.remove(patternInvalidX2, idx)
    if not na(ix1)
        line.delete(ix1)
    if not na(ix2)
        line.delete(ix2)
    array.remove(patternA, idx)
    array.remove(patternB, idx)
    array.remove(patternC, idx)
    array.remove(patternP0, idx)
    array.remove(patternABar, idx)
    array.remove(patternBBar, idx)
    array.remove(patternCBar, idx)
    array.remove(patternCTime, idx)
    array.remove(patternType, idx)
    array.remove(patternBARatio, idx)
    array.remove(patternCARatio, idx)
    array.remove(patternDir, idx)
    array.remove(patternScore, idx)
    array.remove(patternHtfBonus, idx)
    array.remove(patternQuality, idx)
    array.remove(patternRevFactors, idx)
    array.remove(patternInvalid, idx)
    array.remove(patternFlatStack, idx)
    array.remove(patternIsCascade, idx)
    array.remove(patternStale, idx)

// Fade a pattern to gray and draw a red X over it (invalidation visual)
markPatternInvalidAt(int idx) =>
    if idx < array.size(patternA)
        line lnAB = array.get(patternLineAB, idx)
        line lnBC = array.get(patternLineBC, idx)
        label lblA = array.get(patternLblA, idx)
        label lblB = array.get(patternLblB, idx)
        label lblC = array.get(patternLblC, idx)
        box bx = array.get(patternBox, idx)
        if not na(lnAB)
            line.set_color(lnAB, color.new(invalidColor, 60))
        if not na(lnBC)
            line.set_color(lnBC, color.new(invalidColor, 60))
        if not na(lblA)
            label.set_textcolor(lblA, invalidColor)
        if not na(lblB)
            label.set_textcolor(lblB, invalidColor)
        if not na(lblC)
            label.set_textcolor(lblC, invalidColor)
        if not na(bx)
            box.set_border_color(bx, invalidColor)
            box.set_bgcolor(bx, color.new(invalidColor, 92))
        float pA = array.get(patternA, idx)
        float pB = array.get(patternB, idx)
        float pC = array.get(patternC, idx)
        int bA = clampDrawBar(array.get(patternABar, idx))
        int bB = clampDrawBar(array.get(patternBBar, idx))
        int bC = clampDrawBar(array.get(patternCBar, idx))
        float pad = atr14 * 0.4
        float top = math.max(pA, math.max(pB, pC)) + pad
        float bot = math.min(pA, math.min(pB, pC)) - pad
        line x1 = line.new(bA, top, bC, bot, color=color.new(color.red, 0), width=2, style=line.style_solid)
        line x2 = line.new(bA, bot, bC, top, color=color.new(color.red, 0), width=2, style=line.style_solid)
        array.set(patternInvalidX1, idx, x1)
        array.set(patternInvalidX2, idx, x2)
        // Hide factor dots
        for fi = 0 to 4
            label dot = fi == 0 ? array.get(patternFacDot0, idx) : fi == 1 ? array.get(patternFacDot1, idx) : fi == 2 ? array.get(patternFacDot2, idx) : fi == 3 ? array.get(patternFacDot3, idx) : array.get(patternFacDot4, idx)
            if not na(dot)
                label.set_textcolor(dot, color.new(color.gray, 100))

// Dim a pattern that has grown stale (without deleting it)
dimPatternAt(int idx) =>
    if idx < array.size(patternA)
        line lnAB = array.get(patternLineAB, idx)
        line lnBC = array.get(patternLineBC, idx)
        if not na(lnAB)
            line.set_color(lnAB, color.new(color.gray, 50))
        if not na(lnBC)
            line.set_color(lnBC, color.new(color.gray, 50))
        label lblA = array.get(patternLblA, idx)
        label lblB = array.get(patternLblB, idx)
        label lblC = array.get(patternLblC, idx)
        if not na(lblA)
            label.set_textcolor(lblA, color.new(color.gray, 50))
        if not na(lblB)
            label.set_textcolor(lblB, color.new(color.gray, 50))
        if not na(lblC)
            label.set_textcolor(lblC, color.new(color.gray, 50))
        box bx = array.get(patternBox, idx)
        if not na(bx)
            box.set_bgcolor(bx, color.new(color.gray, 85))

// Track 5-wave count for alerts
var int last5WaveCount = 0

// Track pattern count for alerts
var int lastPatternCount = 0
var int lastPullbackCount = 0

// Arrays for pullback detection
var float[] pullbackA = array.new_float(0)
var float[] pullbackB = array.new_float(0)
var float[] pullbackC = array.new_float(0)
var int[] pullbackABar = array.new_int(0)
var int[] pullbackBBar = array.new_int(0)
var int[] pullbackCBar = array.new_int(0)
var int[] pullbackType = array.new_int(0)
var int[] pullbackDir = array.new_int(0)
var float[] pullbackBARatio = array.new_float(0)
var float[] pullbackCARatio = array.new_float(0)

// Arrays for pullback objects
var label[] pullbackLblA = array.new_label(0)
var label[] pullbackLblB = array.new_label(0)
var label[] pullbackLblC = array.new_label(0)
var label[] pullbackLblType = array.new_label(0)
var line[] pullbackLineAB = array.new_line(0)
var line[] pullbackLineBC = array.new_line(0)
var box[] pullbackBox = array.new_box(0)
var float[] pullbackP0 = array.new_float(0)
var int[] pullbackADir = array.new_int(0)

removePullbackAt(int idx) =>
    label.delete(array.remove(pullbackLblA, idx))
    label.delete(array.remove(pullbackLblB, idx))
    label.delete(array.remove(pullbackLblC, idx))
    label.delete(array.remove(pullbackLblType, idx))
    line.delete(array.remove(pullbackLineAB, idx))
    line.delete(array.remove(pullbackLineBC, idx))
    box oldPbBox = array.remove(pullbackBox, idx)
    if not na(oldPbBox)
        box.delete(oldPbBox)
    array.remove(pullbackA, idx)
    array.remove(pullbackB, idx)
    array.remove(pullbackC, idx)
    array.remove(pullbackABar, idx)
    array.remove(pullbackBBar, idx)
    array.remove(pullbackCBar, idx)
    array.remove(pullbackType, idx)
    array.remove(pullbackDir, idx)
    array.remove(pullbackBARatio, idx)
    array.remove(pullbackCARatio, idx)
    array.remove(pullbackP0, idx)
    array.remove(pullbackADir, idx)

// Check for 4-pivot flat patterns (p0→A→B→C)
// Flat detection is always active regardless of Focus Mode — this is the primary purpose of the indicator.
if array.size(pivotPrices) >= 4 and barstate.isconfirmed
    int size = array.size(pivotPrices)
    
    // Get last 4 pivots: p0=start of A, p1=A, p2=B, p3=C
    float p3 = array.get(pivotPrices, size - 1)
    float p2 = array.get(pivotPrices, size - 2)
    float p1 = array.get(pivotPrices, size - 3)
    float p0 = array.get(pivotPrices, size - 4)
    
    int b3 = array.get(pivotBars, size - 1)
    int b2 = array.get(pivotBars, size - 2)
    int b1 = array.get(pivotBars, size - 3)
    int b0 = array.get(pivotBars, size - 4)
    
    int d3 = array.get(pivotDirs, size - 1)
    int d2 = array.get(pivotDirs, size - 2)
    int d1 = array.get(pivotDirs, size - 3)
    int d0 = array.get(pivotDirs, size - 4)
    
    // Flat: A and C pivots same direction, B opposite
    // Check if this is a flat (counter-trend move)
    bool isFlat = (d1 == d3) and (d1 != d2) and (d0 != d1)
    
    if isFlat
        // Correct wave lengths: A=p0→p1, B=p1→p2, C=p2→p3
        float waveA = math.abs(p1 - p0)
        float waveB = math.abs(p2 - p1)
        float waveC = math.abs(p3 - p2)
        
        // B/A ratio (retracement)
        float baRatio = waveA > 0 ? (waveB / waveA) * 100 : 0
        
        // C/A ratio (extension)
        float caRatio = waveA > 0 ? (waveC / waveA) * 100 : 0
        
        // Determine pattern type
        int detectedType = PATTERN_NONE
        
        // Regular Flat: B/A 90-100%, C/A 100-105%
        bool isRegular = (baRatio >= baMinPct - effTolerancePct) and (baRatio <= 100 + effTolerancePct) and 
                          (caRatio >= 100 - effTolerancePct) and (caRatio <= 105 + effTolerancePct)
        
        // Expanded Flat: B/A 100-138.2%, C/A 123.6-161.8%
        bool isExpanded = (baRatio >= 100 - effTolerancePct) and (baRatio <= baMaxPct + effTolerancePct) and 
                           (caRatio >= caMinPct - effTolerancePct) and (caRatio <= caMaxPct + effTolerancePct)
        
        // Running Flat: B > 100%, C fails to reach A's end (C/A < 100%)
        bool isRunning = (baRatio > 100) and (caRatio < 100 - effTolerancePct)
        
        if isRegular
            detectedType := PATTERN_REGULAR
        else if isExpanded
            detectedType := PATTERN_EXPANDED
        else if isRunning
            detectedType := PATTERN_RUNNING
        
        bool aStrongEnough = false
        if detectedType != PATTERN_NONE
            aStrongEnough := isAValid(p0, p1, pivotPrices, pivotVols, pivotVolAvgs, atr14)

        if detectedType != PATTERN_NONE
            bool isDuplicate = isBarsUsed(b1, b2, b3, patternABar, patternBBar, patternCBar)
            
            if not isDuplicate
                // Calculate pattern score
                float score = 50.0
                if not aStrongEnough
                    score := score - 15.0
                
                // B/A ratio closeness to ideal (100% for regular, 123.6% for expanded)
                float idealBA = detectedType == PATTERN_REGULAR ? 100.0 : (detectedType == PATTERN_EXPANDED ? 123.6 : 138.2)
                float baScore = 100 - math.abs(baRatio - idealBA)
                score := score + baScore * 0.2
                
                // C/A ratio closeness to ideal
                float idealCA = detectedType == PATTERN_REGULAR ? 100.0 : (detectedType == PATTERN_EXPANDED ? 138.2 : 161.8)
                float caScore = 100 - math.abs(caRatio - idealCA)
                score := score + caScore * 0.2
                
                // Momentum confirmation
                bool momDiv = d1 == 1 ? bearishMomDiv : bullishMomDiv
                if momDiv or not momentumConfirmation
                    score := score + 15
                
                // Volume confirmation (snapshotted at pivot confirmation)
                int cIdx = size - 1
                float cVol = array.get(pivotVols, cIdx)
                float cVolAvg = array.get(pivotVolAvgs, cIdx)
                bool volSpike = cVol > cVolAvg * 1.5
                if volSpike or not volumeConfirmation
                    score := score + 10
                
                // B-wave close validation
                bool bCloseValid = true
                if bCloseValidation and detectedType == PATTERN_EXPANDED
                    float b2Close = closeAtBar(b2)
                    if not na(b2Close)
                        bCloseValid := d1 == 1 ? b2Close > p0 : b2Close < p0
                    else
                        bCloseValid := false
                if bCloseValid
                    score := score + 5
                
                // Flat pattern quality score
                float flatQuality = 0.0
                if detectedType == PATTERN_REGULAR
                    float bDev = math.abs(baRatio - 100.0)
                    float cDev = math.abs(caRatio - 100.0)
                    flatQuality := math.max(0.0, 100.0 - (bDev + cDev) / 2.0)
                    bool cNear100 = caRatio >= 95.0 and caRatio <= 105.0
                    if cNear100
                        flatQuality := math.min(100.0, flatQuality + 10.0)
                else if detectedType == PATTERN_EXPANDED
                    float bDev = math.abs(baRatio - 123.6)
                    float cDev = math.abs(caRatio - 138.2)
                    flatQuality := math.max(0.0, 100.0 - (bDev + cDev) / 2.0)
                    bool bCloseExpanded = bCloseValid
                    if bCloseExpanded
                        flatQuality := math.min(100.0, flatQuality + 15.0)
                    bool cNear161 = caRatio >= 155.0 and caRatio <= 168.0
                    if cNear161
                        flatQuality := math.min(100.0, flatQuality + 10.0)
                else if detectedType == PATTERN_RUNNING
                    // Running flat ideal: B extends ~123.6% of A, C fails near 78.6% of A
                    float bDev = math.abs(baRatio - 123.6)
                    float cDev = math.abs(caRatio - 78.6)
                    flatQuality := math.max(0.0, 100.0 - (bDev + cDev) / 2.0)
                    // Strong continuation context: C wave volume + trend alignment
                    if volSpike
                        flatQuality := math.min(100.0, flatQuality + 10.0)
                    if waveDirAligned(float(d1))
                        flatQuality := math.min(100.0, flatQuality + 10.0)
                
                score := score + flatQuality * 0.15
                score := math.min(100, score)
                
                // HTF confluence bonus
                float htfBonus = d1 == 1 ? htfBonusForPat1 : htfBonusForPatNeg1
                int signalDir = detectedType == PATTERN_RUNNING ? d1 : -d1
                
                // 5-factor reversal confirmation
                bool rFactor1 = momDiv
                bool rFactor2 = volSpike
                bool rFactor3 = (caRatio >= 95 and caRatio <= 108) or (caRatio >= 118 and caRatio <= 132) or (caRatio >= 153 and caRatio <= 170)
                bool rFactor4 = htf1_state == "WAVE_4" or htf2_state == "WAVE_4" or htf1_state == "WAVE_C" or htf2_state == "WAVE_C" or htf3_state == "WAVE_4" or htf3_state == "WAVE_C"
                bool rFactor5 = waveDirAligned(float(signalDir))
                int rFactorCount = (rFactor1 ? 1 : 0) + (rFactor2 ? 1 : 0) + (rFactor3 ? 1 : 0) + (rFactor4 ? 1 : 0) + (rFactor5 ? 1 : 0)
                
                // Combined tier score
                int combinedTier = 0
                if htfBonus >= 100 and rFactorCount >= 4
                    combinedTier := 4
                else if htfBonus >= 70 and rFactorCount >= 3
                    combinedTier := 3
                else if htfBonus >= 40 and rFactorCount >= 2
                    combinedTier := 2
                else
                    combinedTier := 1

                // Fractal Cascade Tier-0 override
                bool isCascade = isFractalCascade(d1)
                if isCascade
                    combinedTier := 0

                // Multi-Timeframe Flat Stack bonus
                bool flatStack = isFlatStack(detectedType, d1)
                if flatStack and enableFlatStack
                    htfBonus := math.min(170.0, htfBonus + 35.0)
                    if combinedTier > 0 and combinedTier < 4
                        combinedTier += 1
                
                // Always store confirmed flats; score/htf gate controls emphasis + alerts only
                bool displayQualified = score >= minScore and htfBonus >= minHtfBonus
                if true
                    // Determine label styles based on direction
                    string aStyle = d1 == 1 ? label.style_label_down : label.style_label_up
                    string bStyle = d2 == 1 ? label.style_label_down : label.style_label_up
                    string cStyle = d3 == 1 ? label.style_label_down : label.style_label_up
                    
                    // Store pattern data
                    array.push(patternP0, p0)
                    array.push(patternA, p1)
                    array.push(patternB, p2)
                    array.push(patternC, p3)
                    array.push(patternABar, b1)
                    array.push(patternBBar, b2)
                    array.push(patternCBar, b3)
                    array.push(patternCTime, array.get(pivotTimes, size - 1))
                    array.push(patternType, detectedType)
                    array.push(patternBARatio, baRatio)
                    array.push(patternCARatio, caRatio)
                    array.push(patternDir, d1)
                    array.push(patternScore, score)
                    array.push(patternHtfBonus, htfBonus)
                    array.push(patternQuality, flatQuality)
                    array.push(patternRevFactors, rFactorCount)
                    array.push(patternInvalid, false)
                    
                    // Base colors
                    color typeColor = detectedType == PATTERN_REGULAR ? regularColor : (detectedType == PATTERN_EXPANDED ? expandedColor : runningColor)
                    if flatStack and enableFlatStack
                        typeColor := flatStackColor
                    color longColor = color.new(#800080, 0)
                    color shortColor = color.new(color.red, 0)
                    
                    // Tier styling (0 = fractal cascade)
                    int lineWidth = combinedTier == 0 ? 5 : combinedTier == 4 ? 4 : combinedTier == 3 ? 3 : combinedTier == 2 ? 2 : 1
                    lineStyle = combinedTier == 0 or combinedTier >= 3 ? line.style_solid : line.style_dashed
                    color lineColor = combinedTier == 0 ? color.new(cascadeTier0Color, 0) : combinedTier == 4 ? (signalDir == 1 ? color.new(#800080, 0) : color.new(color.red, 0)) : combinedTier == 3 ? (signalDir == 1 ? color.new(#800080, 30) : color.new(color.red, 30)) : combinedTier == 2 ? (signalDir == 1 ? color.new(#800080, 60) : color.new(color.red, 60)) : color.new(color.gray, 70)
                    if not displayQualified
                        lineColor := color.new(lineColor, 55)
                        lineWidth := math.max(1, lineWidth - 1)
                    
                    if combinedTier == 0
                        tier1Flash := true
                        tier1FlashDir := signalDir
                        cascadeAlerted := true
                        fractalCascadeAlerted := true
                    else if combinedTier == 4
                        tier1Flash := true
                        tier1FlashDir := signalDir
                        cascadeAlerted := true
                    
                    bool nearImpulse = isNearImpulsePivot(b1, clampDrawBar(ib1), clampDrawBar(ib2), clampDrawBar(ib3), clampDrawBar(ib4), clampDrawBar(ib5), impulseWaves) or isNearImpulsePivot(b2, clampDrawBar(ib1), clampDrawBar(ib2), clampDrawBar(ib3), clampDrawBar(ib4), clampDrawBar(ib5), impulseWaves) or isNearImpulsePivot(b3, clampDrawBar(ib1), clampDrawBar(ib2), clampDrawBar(ib3), clampDrawBar(ib4), clampDrawBar(ib5), impulseWaves)
                    float flatOffset = nearImpulse ? atr14 * 1.5 : 0.0
                    
                    // A/B/C labels
                    color aLblColor = color.new(typeColor, 70)
                    color bLblColor = color.new(color.gray, 80)
                    color cLblColor = color.new(lineColor, 40 - combinedTier * 8)
                    string cLblText = "C"
                    string aLblText = "A"
                    string bLblText = "B"
                    if showScore
                        cLblText := "C" + str.tostring(int(flatQuality)) + "Q"
                    if showFibRatios
                        aLblText := "A " + str.tostring(baRatio, "#.1") + "%"
                        bLblText := "B " + str.tostring(baRatio, "#.1") + "%"
                        string cFibPart = " | C " + str.tostring(caRatio, "#.1") + "%"
                        cLblText := showScore ? cLblText + cFibPart : "C " + str.tostring(caRatio, "#.1") + "%"
                    if flatStack and enableFlatStack
                        cLblText := "STACK " + cLblText
                    if isCascade and enableFractalCascade
                        cLblText := "⚡CASCADE " + cLblText

                    if showFlatLabels
                        float offA = d1 == 1 ? flatOffset : -flatOffset
                        float offB = d2 == 1 ? flatOffset : -flatOffset
                        float offC = d3 == 1 ? flatOffset : -flatOffset
                        label lblA = label.new(b1, p1 + offA, aLblText, style=aStyle, 
                             color=aLblColor, textcolor=color.white, size=size.tiny)
                        label lblB = label.new(b2, p2 + offB, bLblText, style=bStyle, 
                             color=bLblColor, textcolor=color.white, size=size.tiny)
                        label lblC = label.new(b3, p3 + offC, cLblText, style=cStyle, 
                             color=cLblColor, textcolor=color.white, size=combinedTier == 0 or combinedTier >= 3 ? size.small : size.tiny)
                        array.push(patternLblA, lblA)
                        array.push(patternLblB, lblB)
                        array.push(patternLblC, lblC)
                    else
                        array.push(patternLblA, na)
                        array.push(patternLblB, na)
                        array.push(patternLblC, na)
                    
                    // Tiered signal at C
                    label sigLbl = na
                    label glowLbl = na
                    if combinedTier == 0
                        glowLbl := label.new(b3, p3, "⬤",
                             style=label.style_label_center,
                             color=na,
                             textcolor=color.new(cascadeTier0Color, 50),
                             size=size.huge,
                             yloc=yloc.price)
                        sigLbl := label.new(b3, p3, "C0",
                             style=label.style_label_center,
                             color=na,
                             textcolor=color.new(cascadeTier0Color, 0),
                             size=size.normal,
                             yloc=yloc.price)
                    else if combinedTier == 4
                        glowLbl := label.new(b3, p3, "⬤",
                             style=label.style_label_center,
                             color=na,
                             textcolor=color.new(signalDir == 1 ? #800080 : color.red, 60),
                             size=size.large,
                             yloc=yloc.price)
                        sigLbl := label.new(b3, p3, signalDir == 1 ? "▲" : "▼",
                             style=label.style_label_center,
                             color=na,
                             textcolor=signalDir == 1 ? color.new(#800080, 0) : color.new(color.red, 0),
                             size=size.normal,
                             yloc=yloc.price)
                    else if combinedTier == 3
                        sigLbl := label.new(b3, p3, "",
                             style=signalDir == 1 ? label.style_triangleup : label.style_triangledown,
                             color=lineColor,
                             size=size.small,
                             yloc=yloc.price)
                    else if combinedTier == 2
                        sigLbl := label.new(b3, p3, signalDir == 1 ? "△" : "▽",
                             style=label.style_label_center,
                             color=na,
                             textcolor=lineColor,
                             size=size.small,
                             yloc=yloc.price)
                    else
                        sigLbl := label.new(b3, p3, "·",
                             style=label.style_label_center,
                             color=na,
                             textcolor=color.new(color.gray, 50),
                             size=size.tiny,
                             yloc=yloc.price)
                    
                    // Create lines with tier-based width/opacity
                    line lineAB = line.new(b1, p1, b2, p2, color=lineColor, 
                         width=lineWidth, style=lineStyle)
                    line lineBC = line.new(b2, p2, b3, p3, color=lineColor, 
                         width=lineWidth, style=lineStyle)
                    
                    // Pattern zone (single box — no gradient leak)
                    box zoneBox = na
                    if showPatternZones and (combinedTier >= 2 or combinedTier == 0)
                        float patTop = math.max(p1, math.max(p2, p3))
                        float patBot = math.min(p1, math.min(p2, p3))
                        int fillTransp = combinedTier == 0 ? 60 : combinedTier == 4 ? 72 : combinedTier == 3 ? 80 : 88
                        int borderTransp = combinedTier == 0 ? 0 : 100 - combinedTier * 15
                        int borderWidth = combinedTier == 0 or combinedTier >= 3 ? 2 : 0
                        zoneBox := box.new(b1, patTop, b3, patBot,
                             bgcolor=color.new(typeColor, fillTransp),
                             border_color=color.new(typeColor, borderTransp),
                             border_width=borderWidth)
                    
                    // Circle signals at A, B pivots
                    label signalA = label.new(b1, p1, "●", style=label.style_label_center, color=na, textcolor=lineColor, size=size.tiny, yloc=yloc.price)
                    label signalB = label.new(b2, p2, "●", style=label.style_label_center, color=na, textcolor=lineColor, size=size.tiny, yloc=yloc.price)
                    // C pivot: glow in sigC slot, signal in typeLbl slot for PRIME / CASCADE
                    label signalC = combinedTier == 0 or combinedTier == 4 ? glowLbl : sigLbl
                    label typeLbl = combinedTier == 0 or combinedTier == 4 ? sigLbl : na
                    
                    // Factor indicator dots (per-pattern slots — 1:1 with patternA index)
                    float dotOffset = atr14 * 0.3
                    float dotBase = signalDir == 1 ? p3 - dotOffset : p3 + dotOffset
                    bool[] factors = array.from(rFactor1, rFactor2, rFactor3, rFactor4, rFactor5)
                    color[] factorColors = array.from(color.new(#00E5FF, 0), color.new(#FFE600, 0),
                         color.new(#00FF66, 0), color.new(#B388FF, 0), color.new(color.white, 0))
                    label fd0 = na
                    label fd1 = na
                    label fd2 = na
                    label fd3 = na
                    label fd4 = na
                    if combinedTier >= 2
                        int dotX = b3 - 2
                        int dotSlot = 0
                        for fi = 0 to 4
                            if array.get(factors, fi)
                                label dotLbl = label.new(dotX - fi, dotBase, "●",
                                     style=label.style_label_center,
                                     color=na,
                                     textcolor=array.get(factorColors, fi),
                                     size=size.tiny,
                                     yloc=yloc.price)
                                if dotSlot == 0
                                    fd0 := dotLbl
                                else if dotSlot == 1
                                    fd1 := dotLbl
                                else if dotSlot == 2
                                    fd2 := dotLbl
                                else if dotSlot == 3
                                    fd3 := dotLbl
                                else
                                    fd4 := dotLbl
                                dotSlot += 1
                    array.push(patternFacDot0, fd0)
                    array.push(patternFacDot1, fd1)
                    array.push(patternFacDot2, fd2)
                    array.push(patternFacDot3, fd3)
                    array.push(patternFacDot4, fd4)
                    
                    array.push(patternSigA, signalA)
                    array.push(patternSigB, signalB)
                    array.push(patternSigC, signalC)
                    array.push(patternLblType, typeLbl)
                    array.push(patternLineAB, lineAB)
                    array.push(patternLineBC, lineBC)
                    array.push(patternBox, zoneBox)
                    array.push(patternFlatStack, flatStack)
                    array.push(patternIsCascade, isCascade)
                    array.push(patternStale, false)
                    array.push(patternInvalidX1, na)
                    array.push(patternInvalidX2, na)
                    
                    // Update pattern count for alerts
                    lastPatternCount := array.size(patternA)
                    
                    // Check for 5-wave completion (pattern + 2 more pivots)
                    if array.size(pivotPrices) >= 6
                        // Get pivots 4 and 5 (after the pattern)
                        float p4 = array.get(pivotPrices, size - 2)
                        float p5 = array.get(pivotPrices, size - 1)
                        int b4 = array.get(pivotBars, size - 2)
                        int b5 = array.get(pivotBars, size - 1)
                        int d4 = array.get(pivotDirs, size - 2)
                        int d5 = array.get(pivotDirs, size - 1)
                        
                        // 5-wave completion: P4 and P5 should extend beyond the pattern's C point
                        bool is5WaveComplete = false
                        if d1 == 1  // Bearish pattern (A/C at highs)
                            is5WaveComplete := d5 == -1 and p5 < p3
                        else  // Bullish pattern (A/C at lows)
                            is5WaveComplete := d5 == 1 and p5 > p3
                        
                        if is5WaveComplete
                            // Check if this 5-wave is already tracked
                            bool is5WaveDuplicate = false
                            int n5 = array.size(fiveWavePatternIdx)
                            for j = 0 to (n5 == 0 ? na : n5 - 1)
                                if array.get(fiveWavePatternIdx, j) == array.size(patternA) - 1
                                    is5WaveDuplicate := true
                                    break
                            
                            if not is5WaveDuplicate
                                // Store 5-wave data
                                array.push(fiveWavePatternIdx, array.size(patternA) - 1)
                                array.push(fiveWaveP4, p4)
                                array.push(fiveWaveP5, p5)
                                array.push(fiveWaveP4Bar, b4)
                                array.push(fiveWaveP5Bar, b5)
                                array.push(fiveWaveDir, d1)
                                array.push(fiveWaveComplete, false)
                                array.push(fiveWaveRetestActive, false)
                                array.push(fiveWaveRetestConfirmed, false)
                                
                                // Create 5-wave completion label
                                float wave5Size = math.abs(p5 - p4)
                                float labelY5 = d5 == -1 ? p5 - (wave5Size * 0.1) : p5 + (wave5Size * 0.1)
                                string wave5Text = "W5 ✅"
                                color wave5Color = d1 == 1 ? color.new(color.lime, 20) : color.new(color.red, 20)
                                
                                label wave5Lbl = label.new(b5, labelY5, wave5Text, 
                                     style=d5 == -1 ? label.style_triangledown : label.style_triangleup, color=wave5Color, 
                                     textcolor=color.white, size=size.small, yloc=yloc.price)
                                
                                array.push(fiveWaveLabels, wave5Lbl)
                                
                                // Update count
                                last5WaveCount := array.size(fiveWavePatternIdx)
                                
                                // Limit max 5-wave patterns
                                if array.size(fiveWavePatternIdx) > MAX_PATTERNS
                                    array.remove(fiveWavePatternIdx, 0)
                                    array.remove(fiveWaveP4, 0)
                                    array.remove(fiveWaveP5, 0)
                                    array.remove(fiveWaveP4Bar, 0)
                                    array.remove(fiveWaveP5Bar, 0)
                                    array.remove(fiveWaveDir, 0)
                                    array.remove(fiveWaveComplete, 0)
                                    array.remove(fiveWaveRetestActive, 0)
                                    array.remove(fiveWaveRetestConfirmed, 0)
                                    label.delete(array.shift(fiveWaveLabels))

                    // Keep only the most recent valid patterns on chart
                    while array.size(patternA) > effMaxVisible
                        removeFlatPatternAt(0)

// TIER 1 CASCADE BACKGROUND FLASH & ALERT
// ═════════════════════════════════════════════════════════════════════════════

color cascadeFlashColor = fractalCascadeAlerted ? color.new(cascadeTier0Color, 88) : (tier1Flash ? (tier1FlashDir == 1 ? color.new(#800080, 90) : color.new(color.red, 90)) : na)
bgcolor(cascadeFlashColor, title="CASCADE Flash")

if fractalCascadeAlerted and barstate.isconfirmed
    string casSide = tier1FlashDir == 1 ? "LONG" : "SHORT"
    alert("🌌 FRACTAL CASCADE TIER-0 FLASH — " + casSide + " setup across timeframes", alert.freq_once_per_bar_close)

if cascadeAlerted and not fractalCascadeAlerted and barstate.isconfirmed
    string cascadeSide = tier1FlashDir == 1 ? "LONG" : "SHORT"
    alert("🔥 CASCADE SIGNAL — All TFs aligned " + cascadeSide, alert.freq_once_per_bar_close)

// ═════════════════════════════════════════════════════════════════════════════
// 5-WAVE RETEST DETECTION
// ═════════════════════════════════════════════════════════════════════════════

// Check for retests after 5-wave completion
if array.size(fiveWavePatternIdx) > 0 and barstate.isconfirmed
    int i = 0
    while i < array.size(fiveWavePatternIdx)
        int patternIdx = array.get(fiveWavePatternIdx, i)
        
        // Get pattern zone
        float zoneTop = math.max(array.get(patternA, patternIdx), math.max(array.get(patternB, patternIdx), array.get(patternC, patternIdx)))
        float zoneBottom = math.min(array.get(patternA, patternIdx), math.min(array.get(patternB, patternIdx), array.get(patternC, patternIdx)))
        float zoneHeight = zoneTop - zoneBottom
        
        // Get 5-wave data
        float p4 = array.get(fiveWaveP4, i)
        float p5 = array.get(fiveWaveP5, i)
        int p4Bar = array.get(fiveWaveP4Bar, i)
        int p5Bar = array.get(fiveWaveP5Bar, i)
        int waveDir = array.get(fiveWaveDir, i)
        bool complete = array.get(fiveWaveComplete, i)
        bool retestActive = array.get(fiveWaveRetestActive, i)
        bool retestConfirmed = array.get(fiveWaveRetestConfirmed, i)
        
        // Check if price has moved beyond P5 (wave 5 completion confirmed)
        if not complete
            bool wave5Confirmed = false
            if waveDir == 1  // Bearish pattern (A/C at highs)
                wave5Confirmed := low < p5
            else
                wave5Confirmed := high > p5
            
            if wave5Confirmed
                array.set(fiveWaveComplete, i, true)
                complete := true
        
        // Check for retest of the zone after 5-wave completion
        if complete and not retestConfirmed
            bool inZone = (high >= zoneBottom) and (low <= zoneTop)
            bool beyondZone = false
            bool reversalSignal = false
            
            if waveDir == 1  // Bearish pattern: price should retest from below, then reverse down
                // Price comes up into zone, then reverses
                beyondZone := high > zoneTop
                if inZone and close < open  // Bearish candle in zone
                    reversalSignal := true
            else  // Bullish pattern: price should retest from above, then reverse up
                // Price comes down into zone, then reverses
                beyondZone := low < zoneBottom
                if inZone and close > open  // Bullish candle in zone
                    reversalSignal := true
            
            // Mark retest as active when price enters zone
            if inZone and not retestActive
                array.set(fiveWaveRetestActive, i, true)
                retestActive := true
            
            // Draw X marker when retest is active and reversal signal confirmed
            if retestActive and reversalSignal
                // Calculate X position - at the reversal candle
                float xY = close
                color xColor = waveDir == 1 ? color.new(color.red, 0) : color.new(color.white, 0)
                
                // Draw small X at the retest point (bar_index, close)
                label xSignal = label.new(bar_index, xY, "✕", 
                     style=label.style_label_center, color=na, 
                     textcolor=xColor, size=size.tiny, yloc=yloc.price)
                
                array.push(retestLabels, xSignal)
                
                // Mark as confirmed so we don't draw multiple X's
                array.set(fiveWaveRetestConfirmed, i, true)
                
                // Send alert
                string alertMsg = waveDir == 1 ? "Bearish retest detected - potential reversal down" : "Bullish retest detected - potential reversal up"
                alert(alertMsg, alert.freq_once_per_bar_close)
        
        i += 1

// ═════════════════════════════════════════════════════════════════════════════
// LOOKBACK WINDOW FILTER FOR 5-WAVE PATTERNS
// ═════════════════════════════════════════════════════════════════════════════

if array.size(fiveWaveP5Bar) > 0
    int i = 0
    while i < array.size(fiveWaveP5Bar)
        if array.get(fiveWaveP5Bar, i) < cutoffBar
            array.remove(fiveWavePatternIdx, i)
            array.remove(fiveWaveP4, i)
            array.remove(fiveWaveP5, i)
            array.remove(fiveWaveP4Bar, i)
            array.remove(fiveWaveP5Bar, i)
            array.remove(fiveWaveDir, i)
            array.remove(fiveWaveComplete, i)
            array.remove(fiveWaveRetestActive, i)
            array.remove(fiveWaveRetestConfirmed, i)
            label.delete(array.remove(fiveWaveLabels, i))
        else
            i += 1

// Clean up old retest labels
if array.size(retestLabels) > 0
    int i = 0
    while i < array.size(retestLabels)
        label lbl = array.get(retestLabels, i)
        int lblBar = label.get_x(lbl)
        if lblBar < cutoffBar
            label.delete(array.remove(retestLabels, i))
        else
            i += 1

// ═════════════════════════════════════════════════════════════════════════════
// LOOKBACK WINDOW FILTER
// ═════════════════════════════════════════════════════════════════════════════

// Filter flat patterns outside lookback window
if array.size(patternCBar) > 0
    int i = 0
    while i < array.size(patternCBar)
        if array.get(patternCBar, i) < cutoffBar
            removeFlatPatternAt(i)
        else
            i += 1

// ═════════════════════════════════════════════════════════════════════════════
// AUTO-INVALIDATION — fade broken patterns and draw a red X; remove after lookback expires
// ═════════════════════════════════════════════════════════════════════════════

if array.size(patternA) > 0 and barstate.isconfirmed
    int i = 0
    while i < array.size(patternA)
        if array.get(patternInvalid, i)
            // Keep invalidated flats visible (gray + X) until lookback window expires
            i += 1
        else
            int dir = array.get(patternDir, i)
            int patType = array.get(patternType, i)
            float p0 = array.get(patternP0, i)
            bool invalid = patType == PATTERN_RUNNING ? false : (dir == 1 ? close > p0 : close < p0)
            if invalid
                if enableInvalidationVisuals
                    array.set(patternInvalid, i, true)
                    markPatternInvalidAt(i)
                    i += 1
                else
                    removeFlatPatternAt(i)
            else
                // Stale pattern dimming
                if enableStaleDimming
                    int cBar = array.get(patternCBar, i)
                    float agePct = patternAgePct(cBar)
                    bool alreadyStale = array.get(patternStale, i)
                    if agePct >= staleThresholdPct / 100.0 and not alreadyStale
                        dimPatternAt(i)
                        array.set(patternStale, i, true)
                i += 1

// ═════════════════════════════════════════════════════════════════════════════
// C WAVE PROJECTION — margin-only (B confirmed → show C before it forms)
// ═════════════════════════════════════════════════════════════════════════════

var box[] cProjBoxes = array.new_box(0)
var label[] cProjLabels = array.new_label(0)

if not na(cChartLine100)
    line.delete(cChartLine100)
    cChartLine100 := na
if not na(cChartLine124)
    line.delete(cChartLine124)
    cChartLine124 := na
if not na(cChartLine162)
    line.delete(cChartLine162)
    cChartLine162 := na
if not na(cChartLbl)
    label.delete(cChartLbl)
    cChartLbl := na

if barstate.islast
    while array.size(cProjBoxes) > 0
        box cb = array.shift(cProjBoxes)
        if not na(cb)
            box.delete(cb)
    while array.size(cProjLabels) > 0
        label cl = array.shift(cProjLabels)
        if not na(cl)
            label.delete(cl)
    if not na(preEntryLbl)
        label.delete(preEntryLbl)
        preEntryLbl := na
    bool inPreEntryZone = false
    if enableCProj and cAwaiting and not na(cPb)
        [C_min, C_std, C_ext, C_run, cUp] = computeFlatCLevels(cPorigin, cPa, cPb, cHasOrigin)
        if showCChartLines
            int drawB = clampDrawBar(cBBar)
            cChartLine100 := line.new(drawB, C_min, bar_index + labelRightBars, C_min, color=color.new(fibC100Color, 0), width=2, style=line.style_dashed, extend=extend.right)
            cChartLine124 := line.new(drawB, C_std, bar_index + labelRightBars, C_std, color=color.new(fibC123Color, 0), width=2, style=line.style_dashed, extend=extend.right)
            cChartLine162 := line.new(drawB, C_ext, bar_index + labelRightBars, C_ext, color=color.new(fibC161Color, 0), width=2, style=line.style_dashed, extend=extend.right)
            cChartLbl := label.new(bar_index + 2, C_std, "→C LOADING", style=label.style_label_left, color=color.new(preEntryColor, 10), textcolor=color.black, size=size.normal)
        int aBanner = cProjMarginAnchor(0) - zoneMarkerBars - 2
        array.push(cProjLabels, label.new(aBanner + 1, cPb, "→C LOADING", style=label.style_label_left, color=color.new(preEntryColor, 10), textcolor=color.black, size=size.small))
        int a0 = cProjMarginAnchor(0)
        float regTop = math.max(C_min, C_std)
        float regBot = math.min(C_min, C_std)
        array.push(cProjBoxes, drawNeonZoneBox(regTop, regBot, regularColor, a0))
        array.push(cProjLabels, label.new(a0 + 1, math.avg(regTop, regBot), zoneLabelText("→C REG", regTop, regBot), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.white, size=size.small))
        if enableCProjExt
            int a1 = cProjMarginAnchor(1)
            float extTop = math.max(C_std, C_ext)
            float extBot = math.min(C_std, C_ext)
            array.push(cProjBoxes, drawNeonZoneBox(extTop, extBot, expandedColor, a1))
            array.push(cProjLabels, label.new(a1 + 1, math.avg(extTop, extBot), zoneLabelText("→C EXT", extTop, extBot), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.white, size=size.small))
        int a2 = cProjMarginAnchor(2)
        array.push(cProjBoxes, drawNeonPriceTick(C_min, fibC100Color, a2))
        array.push(cProjLabels, label.new(a2 + 1, C_min, levelLabelText("C100", C_min), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.white, size=size.tiny))
        int a3 = cProjMarginAnchor(3)
        array.push(cProjBoxes, drawNeonPriceTick(C_std, fibC123Color, a3))
        array.push(cProjLabels, label.new(a3 + 1, C_std, levelLabelText("C124", C_std), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.white, size=size.tiny))
        int a4 = cProjMarginAnchor(4)
        array.push(cProjBoxes, drawNeonPriceTick(C_ext, fibC161Color, a4))
        array.push(cProjLabels, label.new(a4 + 1, C_ext, levelLabelText("C162", C_ext), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.white, size=size.tiny))
        if enableCProjRun
            int a5 = cProjMarginAnchor(5)
            array.push(cProjBoxes, drawNeonPriceTick(C_run, color.gray, a5))
            array.push(cProjLabels, label.new(a5 + 1, C_run, levelLabelText("CRUN", C_run), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.gray, size=size.tiny))
        // B-Wave pre-entry signal (zigzag B or impulse WAVE_B)
        if enablePreEntry and cAwaiting
            float proximity = atr14 * entryZoneATR
            float nearest = math.min(math.abs(close - C_min), math.min(math.abs(close - C_std), math.abs(close - C_ext)))
            if nearest <= proximity
                inPreEntryZone := true
                float lblY = cUp ? high + atr14 * 0.6 : low - atr14 * 0.6
                preEntryLbl := label.new(bar_index, lblY, "ENTRY ZONE APPROACHING", style=cUp ? label.style_label_down : label.style_label_up, color=color.new(preEntryColor, 20), textcolor=color.black, size=size.small, yloc=yloc.price)
    else if showFibCTargets and not enableCProj and bConfirmed
        int psz = array.size(pivotPrices)
        float p2 = array.get(pivotPrices, psz - 1)
        float p1 = array.get(pivotPrices, psz - 2)
        float p0f = psz >= 3 ? array.get(pivotPrices, psz - 3) : na
        [t100, t124, t162, tRun, cUpF] = computeFlatCLevels(p0f, p1, p2, psz >= 3)
        int anchor = rightLabelBar()
        array.push(cProjBoxes, drawNeonPriceTick(t100, fibC100Color, anchor))
        array.push(cProjBoxes, drawNeonPriceTick(t124, fibC123Color, anchor + zoneMarkerBars + 3))
        array.push(cProjBoxes, drawNeonPriceTick(t162, fibC161Color, anchor + (zoneMarkerBars + 3) * 2))
        int lblX = anchor + 1
        array.push(cProjLabels, label.new(lblX, t100, levelLabelText("C 100", t100), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.white, size=size.small))
        array.push(cProjLabels, label.new(lblX, t124, levelLabelText("C 124", t124), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.white, size=size.small))
        array.push(cProjLabels, label.new(lblX, t162, levelLabelText("C 162", t162), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.white, size=size.small))
    if inPreEntryZone and not preEntryAlerted
        alert("🎯 ENTRY ZONE APPROACHING — Price within " + str.tostring(entryZoneATR, "#.1") + " ATR of projected C zone", alert.freq_once_per_bar_close)
        preEntryAlerted := true
    if not inPreEntryZone
        preEntryAlerted := false

// ═════════════════════════════════════════════════════════════════════════════
// W2 PULLBACK + W2→W3 PROJECTION (margin markers)
// ═════════════════════════════════════════════════════════════════════════════

var box[] w2w3TargetBoxes = array.new_box(0)
var label[] w2w3TargetLabels = array.new_label(0)

if barstate.islast
    while array.size(w2w3TargetBoxes) > 0
        box b = array.shift(w2w3TargetBoxes)
        if not na(b)
            box.delete(b)
    while array.size(w2w3TargetLabels) > 0
        label l = array.shift(w2w3TargetLabels)
        if not na(l)
            label.delete(l)
    if showW2Markers and chartState == "WAVE_1" and not na(ip1) and not na(ip0) and chartW1 > 0 and waveDirAligned(chartDir)
        float w2Top = chartDir == 1.0 ? ip1 - chartW1 * 0.50 : ip1 + chartW1 * 0.786
        float w2Bot = chartDir == 1.0 ? ip1 - chartW1 * 0.786 : ip1 + chartW1 * 0.50
        int w2Anchor = rightLabelBar()
        array.push(w2w3TargetBoxes, drawNeonZoneBox(w2Top, w2Bot, w2PullbackColor, w2Anchor))
        array.push(w2w3TargetLabels, label.new(w2Anchor + 1, math.avg(w2Top, w2Bot), zoneLabelText("W2 PB", w2Top, w2Bot), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.white, size=size.small))
    else if showW2Markers and chartState == "WAVE_2" and not na(ip2) and chartW1 > 0 and waveDirAligned(chartDir)
        float w3target162 = chartDir == 1.0 ? ip2 + chartW1 * 1.618 : ip2 - chartW1 * 1.618
        float w3target200 = chartDir == 1.0 ? ip2 + chartW1 * 2.0 : ip2 - chartW1 * 2.0
        int anchor = rightLabelBar()
        array.push(w2w3TargetBoxes, drawNeonPriceTick(w3target162, w2W3TargetColor, anchor))
        array.push(w2w3TargetBoxes, drawNeonPriceTick(w3target200, w2W3ExtColor, anchor))
        int lblX = anchor + 1
        array.push(w2w3TargetLabels, label.new(lblX, w3target162, levelLabelText("W3 162", w3target162), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.white, size=size.small))
        array.push(w2w3TargetLabels, label.new(lblX, w3target200, levelLabelText("W3 200", w3target200), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.white, size=size.small))

// ═════════════════════════════════════════════════════════════════════════════
// 3-WAVE PULLBACK DETECTION
// ═════════════════════════════════════════════════════════════════════════════

if not focusMode and array.size(pivotPrices) >= 4 and enablePullback and barstate.isconfirmed
    int size = array.size(pivotPrices)
    
    // Get last 4 pivots: p0=trend start, p1=A, p2=B, p3=C
    float p3 = array.get(pivotPrices, size - 1)
    float p2 = array.get(pivotPrices, size - 2)
    float p1 = array.get(pivotPrices, size - 3)
    float p0 = array.get(pivotPrices, size - 4)
    
    int b3 = array.get(pivotBars, size - 1)
    int b2 = array.get(pivotBars, size - 2)
    int b1 = array.get(pivotBars, size - 3)
    int b0 = array.get(pivotBars, size - 4)
    
    int d3 = array.get(pivotDirs, size - 1)
    int d2 = array.get(pivotDirs, size - 2)
    int d1 = array.get(pivotDirs, size - 3)
    int d0 = array.get(pivotDirs, size - 4)
    
    // 3-wave pullback: A and C are same direction (counter-trend), B is opposite
    bool isPullback = (d1 == d3) and (d1 != d2) and (d0 != d1)
    
    if isPullback
        // Wave measurements
        float trendWave = math.abs(p1 - p0)
        float waveA = math.abs(p1 - p0)
        float waveB = math.abs(p2 - p1)
        float waveC = math.abs(p3 - p2)
        
        // B/A ratio
        float baRatio = waveA > 0 ? (waveB / waveA) * 100 : 0
        
        // C/A ratio
        float caRatio = waveA > 0 ? (waveC / waveA) * 100 : 0
        
        // Determine if continuation or reversal
        bool isContinuation = false
        bool isReversal = false
        
        if d0 == 1  // Uptrend
            if p3 > p0 * (1 - pullbackTolerance / 100)
                isContinuation := true
            else if p3 < p0 * (1 - pullbackTolerance / 100)
                isReversal := true
        else  // Downtrend
            if p3 < p0 * (1 + pullbackTolerance / 100)
                isContinuation := true
            else if p3 > p0 * (1 + pullbackTolerance / 100)
                isReversal := true
        
        // Additional check: ABC pattern should be roughly equal legs
        bool validABC = math.abs(caRatio - 100) <= pullbackTolerance
        
        if (isContinuation or isReversal) and validABC
            int detectedType = isContinuation ? PULLBACK_CONTINUATION : PULLBACK_REVERSAL
            
            // Check for duplicates
            bool isDuplicate = false
            int existingSize = array.size(pullbackA)
            for i = 0 to (existingSize == 0 ? na : existingSize - 1)
                if array.get(pullbackABar, i) == b1 or array.get(pullbackBBar, i) == b2 or array.get(pullbackCBar, i) == b3
                    isDuplicate := true
                    break
            
            if not isDuplicate
                // Store pullback data
                array.push(pullbackP0, p0)
                array.push(pullbackADir, d1)
                array.push(pullbackA, p1)
                array.push(pullbackB, p2)
                array.push(pullbackC, p3)
                array.push(pullbackABar, b1)
                array.push(pullbackBBar, b2)
                array.push(pullbackCBar, b3)
                array.push(pullbackType, detectedType)
                array.push(pullbackDir, d0)
                array.push(pullbackBARatio, baRatio)
                array.push(pullbackCARatio, caRatio)
                
                // Determine colors and labels
                color pbColor = detectedType == PULLBACK_CONTINUATION ? continuationColor : reversalColor
                
                // Create labels
                label lblA = label.new(b1, p1, "A", style=d1 == 1 ? label.style_label_down : label.style_label_up,
                     color=color.new(color.gray, 80), textcolor=color.white, size=size.small)
                label lblB = label.new(b2, p2, "B", style=d2 == 1 ? label.style_label_down : label.style_label_up,
                     color=color.new(color.gray, 80), textcolor=color.white, size=size.small)
                label lblC = label.new(b3, p3, "C", style=d3 == 1 ? label.style_label_down : label.style_label_up,
                     color=color.new(color.gray, 80), textcolor=color.white, size=size.small)
                
                // Simple signal triangle at C
                label typeLbl = label.new(b3, p3, "",
                     style=d3 == -1 ? label.style_triangleup : label.style_triangledown,
                     color=pbColor, textcolor=pbColor, size=size.tiny, yloc=yloc.price)
                
                // Create lines
                line lineAB = line.new(b1, p1, b2, p2, color=pbColor,
                     width=2, style=line.style_solid)
                line lineBC = line.new(b2, p2, b3, p3, color=pbColor,
                     width=2, style=line.style_solid)
                
                // Compact neon zone marker at pullback end
                box zoneBox = na
                if showPatternZones
                    zoneBox := drawNeonPriceTick(p3, pbColor, b3)
                
                // Store objects
                array.push(pullbackLblA, lblA)
                array.push(pullbackLblB, lblB)
                array.push(pullbackLblC, lblC)
                array.push(pullbackLblType, typeLbl)
                array.push(pullbackLineAB, lineAB)
                array.push(pullbackLineBC, lineBC)
                array.push(pullbackBox, zoneBox)
                
                // Update count
                lastPullbackCount := array.size(pullbackA)
                
                // Keep only recent valid pullbacks on chart
                while array.size(pullbackA) > effMaxVisible
                    removePullbackAt(0)

// ═════════════════════════════════════════════════════════════════════════════
// LOOKBACK WINDOW FILTER FOR PULLBACKS
// ═════════════════════════════════════════════════════════════════════════════

if not focusMode and array.size(pullbackCBar) > 0
    int i = 0
    while i < array.size(pullbackCBar)
        if array.get(pullbackCBar, i) < cutoffBar
            removePullbackAt(i)
        else
            i += 1

// Remove invalidated pullbacks (price closed beyond pattern origin)
if not focusMode and array.size(pullbackA) > 0 and barstate.isconfirmed
    int i = 0
    while i < array.size(pullbackA)
        float p0 = array.get(pullbackP0, i)
        int aDir = array.get(pullbackADir, i)
        bool pbInvalid = aDir == 1 ? close > p0 : close < p0
        if pbInvalid
            removePullbackAt(i)
        else
            i += 1

// ═════════════════════════════════════════════════════════════════════════════
// PULLBACK ALERTS
// ═════════════════════════════════════════════════════════════════════════════

if not focusMode and array.size(pullbackA) > lastPullbackCount and barstate.isconfirmed
    int lastIdx = array.size(pullbackA) - 1
    int lastType = array.get(pullbackType, lastIdx)
    float lastBA = array.get(pullbackBARatio, lastIdx)
    float lastCA = array.get(pullbackCARatio, lastIdx)
    
    string alertType = lastType == PULLBACK_CONTINUATION ? "CONTINUATION" : "REVERSAL"
    string alertMsg = "3-WAVE " + alertType + " detected! B/A: " + str.tostring(lastBA, "#.1") + 
         "%, C/A: " + str.tostring(lastCA, "#.1") + "%"
    
    alert(alertMsg, alert.freq_once_per_bar_close)
    lastPullbackCount := array.size(pullbackA)

// ═════════════════════════════════════════════════════════════════════════════
// WAVE 4 EARLY WARNING, FIB ZONES & PRIME ZONES
// ═════════════════════════════════════════════════════════════════════════════

var box[] htfW4Boxes = array.new_box(0)
var label[] htfW5Labels = array.new_label(0)
var box[] primeBoxes = array.new_box(0)
var bool w4ApproachingNow = false
var bool w4ConfirmedNow = false
var float w4ZoneLow = na
var float w4ZoneHigh = na
var int w4Dir = 0
var int w4W3Bar = na
var bool w4ApproachingPrev = false
var bool w4ConfirmedPrev = false

w4ApproachingNow := false
w4ConfirmedNow := false
w4ZoneLow := na
w4ZoneHigh := na
w4Dir := 0
w4W3Bar := na

// Clear & redraw neon markers on last bar only
if barstate.islast
    while array.size(htfW4Boxes) > 0
        box b = array.shift(htfW4Boxes)
        if not na(b)
            box.delete(b)
    while array.size(htfW5Labels) > 0
        label lbl = array.shift(htfW5Labels)
        if not na(lbl)
            label.delete(lbl)
    while array.size(primeBoxes) > 0
        box b = array.shift(primeBoxes)
        if not na(b)
            box.delete(b)

// Build per-HTF arrays for iteration
string[] htfNames = array.new_string(0)
string[] htfStates = array.new_string(0)
float[] htfDirs = array.new_float(0)
float[] htfP0s = array.new_float(0)
float[] htfP1s = array.new_float(0)
float[] htfP2s = array.new_float(0)
float[] htfP3s = array.new_float(0)
float[] htfP4s = array.new_float(0)
int[] htfB3s = array.new_int(0)
int[] htfB4s = array.new_int(0)

// Chart TF layer (always first column on margin)
array.push(htfNames, chartTfName())
array.push(htfStates, chartState)
array.push(htfDirs, chartDir)
array.push(htfP0s, ip0)
array.push(htfP1s, ip1)
array.push(htfP2s, ip2)
array.push(htfP3s, ip3)
array.push(htfP4s, ip4)
array.push(htfB3s, ib3)
array.push(htfB4s, ib4)

if useHtf15
    array.push(htfNames, "15m")
    array.push(htfStates, htf1_state)
    array.push(htfDirs, htf1_dir)
    array.push(htfP0s, htf1_p0)
    array.push(htfP1s, htf1_p1)
    array.push(htfP2s, htf1_p2)
    array.push(htfP3s, htf1_p3)
    array.push(htfP4s, htf1_p4)
    array.push(htfB3s, htf1_b3)
    array.push(htfB4s, htf1_b4)
if useHtf60
    array.push(htfNames, "1H")
    array.push(htfStates, htf2_state)
    array.push(htfDirs, htf2_dir)
    array.push(htfP0s, htf2_p0)
    array.push(htfP1s, htf2_p1)
    array.push(htfP2s, htf2_p2)
    array.push(htfP3s, htf2_p3)
    array.push(htfP4s, htf2_p4)
    array.push(htfB3s, htf2_b3)
    array.push(htfB4s, htf2_b4)
if useHtf240
    array.push(htfNames, "4H")
    array.push(htfStates, htf3_state)
    array.push(htfDirs, htf3_dir)
    array.push(htfP0s, htf3_p0)
    array.push(htfP1s, htf3_p1)
    array.push(htfP2s, htf3_p2)
    array.push(htfP3s, htf3_p3)
    array.push(htfP4s, htf3_p4)
    array.push(htfB3s, htf3_b3)
    array.push(htfB4s, htf3_b4)
if useHtfD
    array.push(htfNames, "D")
    array.push(htfStates, htf4_state)
    array.push(htfDirs, htf4_dir)
    array.push(htfP0s, htf4_p0)
    array.push(htfP1s, htf4_p1)
    array.push(htfP2s, htf4_p2)
    array.push(htfP3s, htf4_p3)
    array.push(htfP4s, htf4_p4)
    array.push(htfB3s, htf4_b3)
    array.push(htfB4s, htf4_b4)

var bool primeZonePrev = false
var string w4AlertTf = ""

int nHtf = array.size(htfStates)
bool primeZoneActive = false

if nHtf > 0
    for i = 0 to nHtf - 1
        string state = array.get(htfStates, i)
        float dir = array.get(htfDirs, i)
        float p0 = array.get(htfP0s, i)
        float p1 = array.get(htfP1s, i)
        float p2 = array.get(htfP2s, i)
        float p3 = array.get(htfP3s, i)
        float p4 = array.get(htfP4s, i)
        int b3 = clampDrawBar(array.get(htfB3s, i))
        int b4 = clampDrawBar(array.get(htfB4s, i))
        string name = array.get(htfNames, i)

        // HTF WAVE_B → C projection ticks (independent of impulse W3/W4/W5 state)
        if barstate.islast and enableCProj and state == "WAVE_B" and dir != 0.0 and not na(p2) and not na(p1) and not na(p0)
            float htfWaveA = math.abs(p1 - p0)
            bool htfCUp = p1 > p0
            float htfCmin = htfCUp ? p2 + htfWaveA : p2 - htfWaveA
            float htfCstd = htfCUp ? p2 + htfWaveA * 1.236 : p2 - htfWaveA * 1.236
            float htfCext = htfCUp ? p2 + htfWaveA * 1.618 : p2 - htfWaveA * 1.618
            int htfAnchor = tfMarkerAnchor(i)
            array.push(htfW4Boxes, drawNeonPriceTick(htfCmin, color.new(fibC100Color, 50), htfAnchor))
            array.push(htfW4Boxes, drawNeonPriceTick(htfCstd, color.new(fibC123Color, 50), htfAnchor))
            array.push(htfW4Boxes, drawNeonPriceTick(htfCext, color.new(fibC161Color, 50), htfAnchor))
            int htfLblX = htfAnchor + 1
            array.push(htfW5Labels, label.new(htfLblX, htfCmin, levelLabelText("C100 " + name, htfCmin), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.white, size=size.tiny))
            array.push(htfW5Labels, label.new(htfLblX, htfCstd, levelLabelText("C124 " + name, htfCstd), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.white, size=size.tiny))
            array.push(htfW5Labels, label.new(htfLblX, htfCext, levelLabelText("C162 " + name, htfCext), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.white, size=size.tiny))

        // W1 → W2 pullback zone on margin (WAVE_1 only)
        if barstate.islast and showW2Markers and waveDirAligned(dir) and state == "WAVE_1" and dir != 0.0 and not na(p1) and not na(p0)
            float w1lenPb = math.abs(p1 - p0)
            float w2Top = dir == 1.0 ? p1 - w1lenPb * 0.50 : p1 + w1lenPb * 0.786
            float w2Bot = dir == 1.0 ? p1 - w1lenPb * 0.786 : p1 + w1lenPb * 0.50
            int w2Anchor = tfMarkerAnchor(i)
            array.push(htfW4Boxes, drawNeonZoneBox(w2Top, w2Bot, color.new(w2PullbackColor, 30), w2Anchor))
            array.push(htfW5Labels, label.new(w2Anchor + 1, math.avg(w2Top, w2Bot), zoneLabelText("W2 " + name, w2Top, w2Bot), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.white, size=size.tiny))

        bool activeState = state == "WAVE_3" or state == "WAVE_4" or state == "WAVE_5" or state == "WAVE_C"
        if activeState and dir != 0.0 and not na(p3) and not na(p2)
            float waveLen = math.abs(p3 - p2)
            float z23 = p3 - dir * waveLen * 0.236
            float z38 = p3 - dir * waveLen * 0.382
            float zoneLow = math.min(z23, z38)
            float zoneHigh = math.max(z23, z38)
            float w1high = math.max(p0, p1)
            float w1low = math.min(p0, p1)

            // Per-TF destination markers (chart + every enabled HTF)
            if barstate.islast
                int zoneAnchor = tfMarkerAnchor(i)

                // W3 / WAVE_C → compact W4 target tick on margin only
                if showW4Markers and waveDirAligned(dir) and (state == "WAVE_3" or state == "WAVE_C")
                    float w4Mid = math.avg(zoneLow, zoneHigh)
                    array.push(htfW4Boxes, drawNeonPriceTick(w4Mid, w4ZoneColor, zoneAnchor))
                    array.push(htfW5Labels, label.new(zoneAnchor + 1, w4Mid, levelLabelTextHR("W4 " + name, w4Mid, int(dir)), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.white, size=size.tiny))

                // W4 confirmed → W5 price ticks only (no tall MIN–STD box)
                if showW5Markers and waveDirAligned(dir) and (state == "WAVE_4" or state == "WAVE_5") and not na(p4) and not na(p0) and not na(p1)
                    float w1len = math.abs(p1 - p0)
                    float w5min = p3
                    float w5std = p4 + dir * w1len
                    float w5ext1 = p4 + dir * w1len * 1.618
                    float w5ext2 = p4 + dir * w1len * 2.618
                    int revDir = int(-dir)
                    array.push(htfW4Boxes, drawNeonPriceTick(w5min, w5MinColor, zoneAnchor))
                    array.push(htfW4Boxes, drawNeonPriceTick(w5std, w5StdColor, zoneAnchor))
                    array.push(htfW4Boxes, drawNeonPriceTick(w5ext1, w5Ext1Color, zoneAnchor))
                    array.push(htfW4Boxes, drawNeonPriceTick(w5ext2, w5Ext2Color, zoneAnchor))
                    int lblX = zoneAnchor + 1
                    array.push(htfW5Labels, label.new(lblX, w5min, levelLabelTextHR("MIN", w5min, revDir), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.white, size=size.tiny))
                    array.push(htfW5Labels, label.new(lblX, w5std, levelLabelTextHR("STD", w5std, revDir), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.white, size=size.tiny))
                    array.push(htfW5Labels, label.new(lblX, w5ext1, levelLabelTextHR("161", w5ext1, revDir), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.white, size=size.tiny))
                    array.push(htfW5Labels, label.new(lblX, w5ext2, levelLabelTextHR("261", w5ext2, revDir), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.white, size=size.tiny))

            // WAVE 4 early warning
            if state == "WAVE_3" or state == "WAVE_C"
                bool inZone = close >= zoneLow and close <= zoneHigh
                bool pullingBack = dir == 1.0 ? (close < high[1]) : (close > low[1])
                bool rsiDeclining = dir == 1.0 ? (rsi < rsi[1]) : (rsi > rsi[1])
                bool rsiLevel = dir == 1.0 ? (rsi > 40) : (rsi < 60)
                bool volContract = volume < volAvg10
                if inZone and pullingBack and rsiDeclining and rsiLevel and volContract
                    w4ApproachingNow := true
                    w4AlertTf := name
                    if na(w4ZoneLow)
                        w4ZoneLow := zoneLow
                        w4ZoneHigh := zoneHigh
                        w4Dir := int(dir)
                        w4W3Bar := b3

                // W4 confirmed
                bool newFlat = array.size(patternCBar) > 0 and array.get(patternCBar, array.size(patternCBar) - 1) == bar_index
                bool newPullback = array.size(pullbackCBar) > 0 and array.get(pullbackCBar, array.size(pullbackCBar) - 1) == bar_index
                bool new3wave = newFlat or newPullback
                bool holdsW1 = dir == 1.0 ? (low > w1low) : (high < w1high)
                bool rsiTurn = dir == 1.0 ? (rsi > rsi[1]) : (rsi < rsi[1])
                if inZone and new3wave and holdsW1 and rsiTurn
                    w4ConfirmedNow := true
                    w4AlertTf := name
                    if na(w4ZoneLow)
                        w4ZoneLow := zoneLow
                        w4ZoneHigh := zoneHigh
                        w4Dir := int(dir)
                        w4W3Bar := b3

            // PRIME ZONE overlap with current-chart flat/pullback zones
            int nPat = array.size(patternA)
            if nPat > 0
                for j = 0 to nPat - 1
                    if not array.get(patternInvalid, j)
                        float pa = array.get(patternA, j)
                        float pb = array.get(patternB, j)
                        float pc = array.get(patternC, j)
                        int pBar = array.get(patternCBar, j)
                        int pDir = array.get(patternDir, j)
                        float patTop = math.max(pa, math.max(pb, pc))
                        float patBottom = math.min(pa, math.min(pb, pc))
                        bool overlap = patBottom <= zoneHigh and patTop >= zoneLow
                        bool priceInOverlap = close >= math.max(patBottom, zoneLow) and close <= math.min(patTop, zoneHigh)
                        if overlap and priceInOverlap
                            primeZoneActive := true
                            if barstate.islast and showPrimeMarkers
                                float primeTop = math.min(patTop, zoneHigh)
                                float primeBottom = math.max(patBottom, zoneLow)
                                color primeNeon = pDir == -1 ? primeLongColor : primeShortColor
                                int primeAnchor = rightLabelBar()
                                box primeBox = drawNeonZoneBox(primeTop, primeBottom, primeNeon, primeAnchor)
                                array.push(primeBoxes, primeBox)
                                label primeLbl = label.new(primeAnchor + 1, math.avg(primeTop, primeBottom), zoneLabelText("PRIME", primeTop, primeBottom), style=label.style_label_left, color=color.new(#0D0D0D, 20), textcolor=color.white, size=size.small)
                                array.push(htfW5Labels, primeLbl)

// W4 alerts (no floating chart label — alerts + info table only)
if w4ApproachingNow and not w4ApproachingPrev and barstate.isconfirmed
    alert("⚡ WAVE 4 APPROACHING — " + w4AlertTf + " entering W4 zone", alert.freq_once_per_bar_close)
if w4ConfirmedNow and not w4ConfirmedPrev and barstate.isconfirmed
    alert("✅ WAVE 4 CONFIRMED — W5 loading on " + w4AlertTf, alert.freq_once_per_bar_close)

if primeZoneActive and not primeZonePrev and barstate.isconfirmed
    alert("⚡ PRIME ZONE ACTIVE — Flat + W4 overlap on " + syminfo.ticker, alert.freq_once_per_bar_close)
primeZonePrev := primeZoneActive

w4ApproachingPrev := w4ApproachingNow
w4ConfirmedPrev := w4ConfirmedNow

color w4FlashColor = w4ConfirmedNow and not na(w4ZoneLow) ? color.new(color.yellow, 90) : na
bgcolor(w4FlashColor, title="W4 Confirmed Flash")

// Wave-count invalidated alerts per HTF
var string prevHtf1State = "UNKNOWN"
var string prevHtf2State = "UNKNOWN"
var string prevHtf3State = "UNKNOWN"
var string prevHtf4State = "UNKNOWN"

if barstate.isconfirmed
    if prevHtf1State != "UNKNOWN" and htf1_state == "UNKNOWN"
        alert("🔁 WAVE COUNT INVALIDATED — Recounting 15m", alert.freq_once_per_bar_close)
    if prevHtf2State != "UNKNOWN" and htf2_state == "UNKNOWN"
        alert("🔁 WAVE COUNT INVALIDATED — Recounting 1H", alert.freq_once_per_bar_close)
    if prevHtf3State != "UNKNOWN" and htf3_state == "UNKNOWN"
        alert("🔁 WAVE COUNT INVALIDATED — Recounting 4H", alert.freq_once_per_bar_close)
    if prevHtf4State != "UNKNOWN" and htf4_state == "UNKNOWN"
        alert("🔁 WAVE COUNT INVALIDATED — Recounting Daily", alert.freq_once_per_bar_close)
    prevHtf1State := htf1_state
    prevHtf2State := htf2_state
    prevHtf3State := htf3_state
    prevHtf4State := htf4_state

// ═════════════════════════════════════════════════════════════════════════════
// WAVE 5 TARGET HIT ALERTS
// ═════════════════════════════════════════════════════════════════════════════

var bool htf1W5MinHit = false
var bool htf2W5MinHit = false
var bool htf3W5MinHit = false
var bool htf4W5MinHit = false
var bool htf1W5ExtHit = false
var bool htf2W5ExtHit = false
var bool htf3W5ExtHit = false
var bool htf4W5ExtHit = false

if barstate.isconfirmed
    if prevHtf1State != htf1_state
        htf1W5MinHit := false
        htf1W5ExtHit := false
    if prevHtf2State != htf2_state
        htf2W5MinHit := false
        htf2W5ExtHit := false
    if prevHtf3State != htf3_state
        htf3W5MinHit := false
        htf3W5ExtHit := false
    if prevHtf4State != htf4_state
        htf4W5MinHit := false
        htf4W5ExtHit := false

    // 15m
    if useHtf15 and (htf1_state == "WAVE_4" or htf1_state == "WAVE_5") and htf1_dir != 0.0 and not na(htf1_p4)
        float w1len1 = math.abs(htf1_p1 - htf1_p0)
        float w5min1 = htf1_p3
        float w5ext1 = htf1_p4 + htf1_dir * w1len1 * 1.618
        bool rmin1 = htf1_dir == 1.0 ? close >= w5min1 : close <= w5min1
        bool rext1 = htf1_dir == 1.0 ? close >= w5ext1 : close <= w5ext1
        if rmin1 and not htf1W5MinHit
            alert("🎯 WAVE 5 TARGET HIT — W5 MIN reached [15m]", alert.freq_once_per_bar_close)
            htf1W5MinHit := true
        if rext1 and not htf1W5ExtHit
            alert("🎯 WAVE 5 TARGET HIT — W5 EXT 161 reached [15m]", alert.freq_once_per_bar_close)
            htf1W5ExtHit := true
    // 1H
    if useHtf60 and (htf2_state == "WAVE_4" or htf2_state == "WAVE_5") and htf2_dir != 0.0 and not na(htf2_p4)
        float w1len2 = math.abs(htf2_p1 - htf2_p0)
        float w5min2 = htf2_p3
        float w5ext2 = htf2_p4 + htf2_dir * w1len2 * 1.618
        bool rmin2 = htf2_dir == 1.0 ? close >= w5min2 : close <= w5min2
        bool rext2 = htf2_dir == 1.0 ? close >= w5ext2 : close <= w5ext2
        if rmin2 and not htf2W5MinHit
            alert("🎯 WAVE 5 TARGET HIT — W5 MIN reached [1H]", alert.freq_once_per_bar_close)
            htf2W5MinHit := true
        if rext2 and not htf2W5ExtHit
            alert("🎯 WAVE 5 TARGET HIT — W5 EXT 161 reached [1H]", alert.freq_once_per_bar_close)
            htf2W5ExtHit := true
    // 4H
    if useHtf240 and (htf3_state == "WAVE_4" or htf3_state == "WAVE_5") and htf3_dir != 0.0 and not na(htf3_p4)
        float w1len3 = math.abs(htf3_p1 - htf3_p0)
        float w5min3 = htf3_p3
        float w5ext3 = htf3_p4 + htf3_dir * w1len3 * 1.618
        bool rmin3 = htf3_dir == 1.0 ? close >= w5min3 : close <= w5min3
        bool rext3 = htf3_dir == 1.0 ? close >= w5ext3 : close <= w5ext3
        if rmin3 and not htf3W5MinHit
            alert("🎯 WAVE 5 TARGET HIT — W5 MIN reached [4H]", alert.freq_once_per_bar_close)
            htf3W5MinHit := true
        if rext3 and not htf3W5ExtHit
            alert("🎯 WAVE 5 TARGET HIT — W5 EXT 161 reached [4H]", alert.freq_once_per_bar_close)
            htf3W5ExtHit := true
    // Daily
    if useHtfD and (htf4_state == "WAVE_4" or htf4_state == "WAVE_5") and htf4_dir != 0.0 and not na(htf4_p4)
        float w1len4 = math.abs(htf4_p1 - htf4_p0)
        float w5min4 = htf4_p3
        float w5ext4 = htf4_p4 + htf4_dir * w1len4 * 1.618
        bool rmin4 = htf4_dir == 1.0 ? close >= w5min4 : close <= w5min4
        bool rext4 = htf4_dir == 1.0 ? close >= w5ext4 : close <= w5ext4
        if rmin4 and not htf4W5MinHit
            alert("🎯 WAVE 5 TARGET HIT — W5 MIN reached [Daily]", alert.freq_once_per_bar_close)
            htf4W5MinHit := true
        if rext4 and not htf4W5ExtHit
            alert("🎯 WAVE 5 TARGET HIT — W5 EXT 161 reached [Daily]", alert.freq_once_per_bar_close)
            htf4W5ExtHit := true

// ═════════════════════════════════════════════════════════════════════════════
// LEADING PROBABILITY — TIME PROJ, W3 EXHAUSTION
// ═════════════════════════════════════════════════════════════════════════════

var line[] timeProjLines = array.new_line(0)
var label[] timeProjLabels = array.new_label(0)
var box leadTargetBox = na
var label leadTargetLbl = na
var label w3ExhaustLbl = na
var line w3ExhaustLine = na
var box w3ExhaustBox = na
var bool w3ExhaustPrev = false
var bool timeProjAlerted = false
var string leadTargetPrev = ""

bool w3ExhaustNow = false
int w4NormBarsProj = na
string leadTargetName = ""
float leadTargetPrice = na
int leadTargetScore = 0
int leadTargetOverlap = 0
color leadTargetCol = color.white

// --- System 4: W3 Exhaustion Pre-Signal ---
if enableW3Exhaust and runHeavyLayers and (chartState == "WAVE_3" or chartState == "WAVE_C") and chartDir != 0.0
    bool bullExhaust = chartDir == 1.0 and close > close[exhaustLookback] and rsiExNow < rsiExPrev and rsiExNow > 60
    bool bearExhaust = chartDir == -1.0 and close < close[exhaustLookback] and rsiExNow > rsiExPrev and rsiExNow < 40
    bool volDeclining = volume < volAvg10
    bool macdShrinking = chartDir == 1.0 ? macdHist < macdHist[1] : macdHist > macdHist[1]
    if (bullExhaust or bearExhaust) and (volDeclining or macdShrinking)
        w3ExhaustNow := true

if not na(w3ExhaustLbl)
    label.delete(w3ExhaustLbl)
    w3ExhaustLbl := na
if not na(w3ExhaustLine)
    line.delete(w3ExhaustLine)
    w3ExhaustLine := na
if not na(w3ExhaustBox)
    box.delete(w3ExhaustBox)
    w3ExhaustBox := na

if enableW3Exhaust and w3ExhaustNow
    w3ExhaustLine := line.new(bar_index - exhaustLookback, close, bar_index + 10, close, color=color.new(exhaustColor, 0), width=1, style=line.style_dashed, extend=extend.none)
    float exhaustY = chartDir == 1.0 ? high + atr14 * 0.5 : low - atr14 * 0.5
    string exhaustText = "W3 EXHAUSTING\nW4 LOADING →"
    w3ExhaustLbl := label.new(bar_index, exhaustY, exhaustText, style=chartDir == 1.0 ? label.style_label_down : label.style_label_up, color=color.new(exhaustColor, 20), textcolor=color.black, size=size.small, yloc=yloc.price)
    w3ExhaustBox := box.new(bar_index - 1, high, bar_index, low,
         bgcolor=color.new(exhaustColor, 80),
         border_color=color.new(exhaustColor, 40),
         border_width=1)

if w3ExhaustNow and not w3ExhaustPrev and barstate.isconfirmed
    string exSide = chartDir == 1.0 ? "BULL" : "BEAR"
    alert("⚠️ W3 EXHAUSTING — " + exSide + " Wave 3 showing divergence. W4 loading.", alert.freq_once_per_bar_close)

w3ExhaustPrev := w3ExhaustNow

bgcolor(enableW3Exhaust and w3ExhaustNow ? color.new(exhaustColor, 93) : na, title="W3 Exhaustion Tint")

// --- Systems 1 & 2: Time Projection + Leading Target (last bar only) ---
if barstate.islast
    while array.size(timeProjLines) > 0
        line tl = array.shift(timeProjLines)
        if not na(tl)
            line.delete(tl)
    while array.size(timeProjLabels) > 0
        label tll = array.shift(timeProjLabels)
        if not na(tll)
            label.delete(tll)

    // System 2: Fibonacci Time Projection
    if enableTimeProj and runHeavyLayers and (chartState == "WAVE_3" or chartState == "WAVE_4" or chartState == "WAVE_5") and not na(ib0) and not na(ib1) and not na(ib2) and not na(ib3)
        int w1Bars = ib1 - ib0
        int w3Bars = ib3 - ib2
        if w1Bars > 0 and w3Bars > 0
            int w4ShortBars = ib3 + int(w3Bars * 0.236)
            int w4NormBars = ib3 + int(w3Bars * 0.382)
            int w4ExtBars = ib3 + int(w3Bars * 0.618)
            w4NormBarsProj := w4NormBars
            int w4Anchor = chartState == "WAVE_4" or chartState == "WAVE_5" ? (not na(ib4) ? ib4 : w4NormBars) : w4NormBars
            int w5ShortBars = w4Anchor + int(w1Bars * 0.618)
            int w5NormBars = w4Anchor + int(w1Bars * 1.0)
            int w5ExtBars = w4Anchor + int(w1Bars * 1.618)
            float rngHi = projRngHi
            float rngLo = projRngLo
            int[] w4ProjBars = array.from(w4ShortBars, w4NormBars, w4ExtBars)
            int[] w5ProjBars = array.from(w5ShortBars, w5NormBars, w5ExtBars)
            string[] w4ProjNames = array.from("W4?", "W4", "W4+")
            string[] w5ProjNames = array.from("W5?", "W5", "W5+")
            for pi = 0 to 2
                int w4Bar = math.min(bar_index + 300, array.get(w4ProjBars, pi))
                if w4Bar > bar_index
                    line w4Ln = line.new(w4Bar, rngLo, w4Bar, rngHi, color=color.new(w4ZoneColor, 30), width=1, style=line.style_dashed, extend=extend.none)
                    array.push(timeProjLines, w4Ln)
                    label w4Lbl = label.new(w4Bar, rngHi, array.get(w4ProjNames, pi), style=label.style_label_down, color=na, textcolor=w4ZoneColor, size=size.tiny)
                    array.push(timeProjLabels, w4Lbl)
                int w5Bar = math.min(bar_index + 300, array.get(w5ProjBars, pi))
                if w5Bar > bar_index
                    line w5Ln = line.new(w5Bar, rngLo, w5Bar, rngHi, color=color.new(w5StdColor, 30), width=1, style=line.style_dashed, extend=extend.none)
                    array.push(timeProjLines, w5Ln)
                    label w5Lbl = label.new(w5Bar, rngHi, array.get(w5ProjNames, pi), style=label.style_label_down, color=na, textcolor=w5StdColor, size=size.tiny)
                    array.push(timeProjLabels, w5Lbl)

    // Leading Target — highest-probability destination across all TFs
    if not na(leadTargetBox)
        box.delete(leadTargetBox)
        leadTargetBox := na
    if not na(leadTargetLbl)
        label.delete(leadTargetLbl)
        leadTargetLbl := na

    if enableLeadTarget and nHtf > 0 and runHeavyLayers
        int phW3 = 0
        int phW4 = 0
        int phW5 = 0
        for pi = 0 to nHtf - 1
            string ps = array.get(htfStates, pi)
            if ps == "WAVE_3" or ps == "WAVE_C"
                phW3 += 1
            else if ps == "WAVE_4"
                phW4 += 1
            else if ps == "WAVE_5"
                phW5 += 1
        float[] cLows = array.new_float(0)
        float[] cHighs = array.new_float(0)
        string[] cTags = array.new_string(0)
        int[] cTfWts = array.new_int(0)
        for mi = 0 to nHtf - 1
            string mState = array.get(htfStates, mi)
            float mDir = array.get(htfDirs, mi)
            string mName = array.get(htfNames, mi)
            float mp0 = array.get(htfP0s, mi)
            float mp1 = array.get(htfP1s, mi)
            float mp2 = array.get(htfP2s, mi)
            float mp3 = array.get(htfP3s, mi)
            float mp4 = array.get(htfP4s, mi)
            int mWt = tfWeightFromName(mName)
            if waveDirAligned(mDir) and mDir != 0.0 and not na(mp3) and not na(mp2)
                if mState == "WAVE_3" or mState == "WAVE_C"
                    float mWaveLen = math.abs(mp3 - mp2)
                    float mz23 = mp3 - mDir * mWaveLen * 0.236
                    float mz38 = mp3 - mDir * mWaveLen * 0.382
                    pushLeadCand(cLows, cHighs, cTags, cTfWts, mz23, mz38, "W4 DEST", mWt)
                if (mState == "WAVE_4" or mState == "WAVE_5") and not na(mp4) and not na(mp0) and not na(mp1)
                    float mw1len = math.abs(mp1 - mp0)
                    float mw5min = mp3
                    float mw5std = mp4 + mDir * mw1len
                    float mw5ext = mp4 + mDir * mw1len * 1.618
                    [minLo, minHi] = priceBand(mw5min)
                    [stdLo, stdHi] = priceBand(mw5std)
                    [extLo, extHi] = priceBand(mw5ext)
                    pushLeadCand(cLows, cHighs, cTags, cTfWts, minLo, minHi, "W5 MIN", mWt + 1)
                    pushLeadCand(cLows, cHighs, cTags, cTfWts, stdLo, stdHi, "W5 STD", mWt + 2)
                    pushLeadCand(cLows, cHighs, cTags, cTfWts, extLo, extHi, "W5 EXT", mWt)
        int candN = array.size(cLows)
        if candN > 0
            int bestIdx = 0
            float bestScore = -1.0
            float useDir = refDir != 0.0 ? refDir : chartDir
            for ci = 0 to candN - 1
                int overlaps = countZoneOverlaps(ci, cLows, cHighs)
                float cLo = array.get(cLows, ci)
                float cHi = array.get(cHighs, ci)
                float mid = math.avg(cLo, cHi)
                string ctag = array.get(cTags, ci)
                float score = overlaps * 25.0 + array.get(cTfWts, ci) + leadPhaseBonus(ctag, phW3, phW4, phW5) + leadDirBonus(mid, useDir)
                if primeZoneActive and ctag == "W4 DEST"
                    score += 18.0
                if w4ConfirmedNow and ctag == "W5 STD"
                    score += 12.0
                if score > bestScore
                    bestScore := score
                    bestIdx := ci
            leadTargetName := array.get(cTags, bestIdx)
            leadTargetPrice := math.avg(array.get(cLows, bestIdx), array.get(cHighs, bestIdx))
            leadTargetScore := int(bestScore)
            leadTargetOverlap := countZoneOverlaps(bestIdx, cLows, cHighs)
            leadTargetCol := useDir == 1.0 ? leadTargetLongColor : useDir == -1.0 ? leadTargetShortColor : color.white
            int leadAnch = leadMarkerAnchor()
            leadTargetBox := drawLeadTargetTick(leadTargetPrice, leadTargetCol, leadAnch)
            string leadStars = leadTargetOverlap >= 4 ? " ★★★★" : leadTargetOverlap == 3 ? " ★★★" : leadTargetOverlap == 2 ? " ★★" : ""
            string leadTxt = "► LEAD " + leadTargetName + " " + formatPctFromClose(leadTargetPrice) + leadStars
            leadTargetLbl := label.new(leadAnch + 1, leadTargetPrice, leadTxt, style=label.style_label_left, color=color.new(#0D0D0D, 10), textcolor=leadTargetCol, size=size.small)

// Time projection alert
if chartState != "WAVE_3"
    timeProjAlerted := false
if enableTimeProj and chartState == "WAVE_3" and not timeProjAlerted and barstate.isconfirmed and not na(w4NormBarsProj)
    int barsToW4 = w4NormBarsProj - bar_index
    if barsToW4 > 0 and barsToW4 <= 300
        alert("⏱ TIME PROJECTION — W4 expected to complete in ~" + str.tostring(barsToW4) + " bars.", alert.freq_once_per_bar_close)
        timeProjAlerted := true

string leadKey = leadTargetName + str.tostring(leadTargetPrice)
if enableLeadTarget and leadKey != leadTargetPrev and leadKey != "" and barstate.isconfirmed
    alert("► LEAD TARGET — " + leadTargetName + " @ " + str.tostring(leadTargetPrice, "#.##") + " (" + str.tostring(leadTargetOverlap) + " TF overlap)", alert.freq_once_per_bar_close)
leadTargetPrev := leadKey

// ═════════════════════════════════════════════════════════════════════════════
// ALERTS
// ═════════════════════════════════════════════════════════════════════════════

// Alert on new pattern detection (qualified flats only)
if array.size(patternA) > lastPatternCount and barstate.isconfirmed
    int lastIdx = array.size(patternA) - 1
    float lastScore = array.get(patternScore, lastIdx)
    float lastHtf = array.get(patternHtfBonus, lastIdx)
    if lastScore >= minScore and lastHtf >= minHtfBonus
        int lastType = array.get(patternType, lastIdx)
        float lastBA = array.get(patternBARatio, lastIdx)
        float lastCA = array.get(patternCARatio, lastIdx)
        int lastRevFactors = array.get(patternRevFactors, lastIdx)
        float lastQuality = array.get(patternQuality, lastIdx)
        int lastDir = array.get(patternDir, lastIdx)
        int signalDir = -lastDir
        bool lastStack = array.get(patternFlatStack, lastIdx)
        bool lastCascade = array.get(patternIsCascade, lastIdx)
        float lastP0 = array.get(patternP0, lastIdx)
        float lastPA = array.get(patternA, lastIdx)
        float lastPB = array.get(patternB, lastIdx)
        bool hasOrigin = not na(lastP0)
        [botCmin, botCstd, botCext, botCrun, botCUp] = computeFlatCLevels(lastP0, lastPA, lastPB, hasOrigin)
        float botEntry = math.avg(botCmin, botCstd)
        bool botExpanded = lastType == PATTERN_EXPANDED
        float botSL = botExpanded ? (botCUp ? lastPB + atr14 * 0.3 : lastPB - atr14 * 0.3) : (botCUp ? math.max(lastP0, lastPA) + atr14 * 0.2 : math.min(lastP0, lastPA) - atr14 * 0.2)
        float botTP1 = hasOrigin ? lastP0 : lastPA
        float botRange = math.max(math.abs(lastPA - lastP0), math.abs(lastPB - lastPA))
        float botTP2 = botCUp ? botTP1 - botRange * 1.618 : botTP1 + botRange * 1.618

        string alertType = lastType == PATTERN_REGULAR ? "REGULAR FLAT" : (lastType == PATTERN_EXPANDED ? "EXPANDED FLAT" : "RUNNING FLAT")
        string humanMsg = alertType + " | Score: " + str.tostring(lastScore, "#.") +
             " | Rev Factors: " + str.tostring(lastRevFactors) + "/5" +
             " | B/A: " + str.tostring(lastBA, "#.1") + "%" +
             " | C/A: " + str.tostring(lastCA, "#.1") + "%" +
             (lastStack ? " | FLAT STACK" : "") +
             (lastCascade ? " | FRACTAL CASCADE" : "")

        string botJson = "{\"event\":\"flat_signal\",\"type\":\"" + alertType + "\",\"side\":\"" + (signalDir == 1 ? "LONG" : "SHORT") + "\",\"dir\":" + str.tostring(signalDir) +
             ",\"score\":" + str.tostring(lastScore, "#.") + ",\"quality\":" + str.tostring(lastQuality, "#.") +
             ",\"factors\":" + str.tostring(lastRevFactors) + ",\"ba_pct\":" + str.tostring(lastBA, "#.##") +
             ",\"ca_pct\":" + str.tostring(lastCA, "#.##") + ",\"flat_stack\":" + (lastStack ? "true" : "false") +
             ",\"cascade\":" + (lastCascade ? "true" : "false") + ",\"ticker\":\"" + syminfo.ticker + "\",\"tf\":\"" + timeframe.period + "\"" +
             ",\"entry\":" + str.tostring(botEntry, "#.#####") + ",\"sl\":" + str.tostring(botSL, "#.#####") +
             ",\"tp1\":" + str.tostring(botTP1, "#.#####") + ",\"tp2\":" + str.tostring(botTP2, "#.#####") + "}"

        alert(humanMsg + " | BOT: " + botJson, alert.freq_once_per_bar_close)

        if lastStack and enableFlatStack
            alert("🔥 FLAT STACK — " + alertType + " confirmed while HTF is forming the same flat type", alert.freq_once_per_bar_close)

        if lastCascade and enableFractalCascade
            alert("⚡ FRACTAL CASCADE TIER-0 — Micro flat inside HTF W4. Highest probability reversal.", alert.freq_once_per_bar_close)

        // Composite high-priority reversal alert
        if lastRevFactors >= 4 or lastCascade
            string signalEmoji = lastCascade ? "🌌" : (lastRevFactors == 5 ? "🔥" : "⚡")
            string signalTier = lastCascade ? "TIER 0" : (lastRevFactors == 5 ? "PRIME" : "STRONG")
            string flatName = lastType == PATTERN_REGULAR ? "REG FLAT" :
                              lastType == PATTERN_EXPANDED ? "EXP FLAT" : "RUN FLAT"
            string sideStr = signalDir == 1 ? "LONG" : "SHORT"
            alert(signalEmoji + " " + signalTier + " REVERSAL — " + flatName + " " + sideStr +
                 " | " + str.tostring(lastRevFactors) + "/5 factors | Score: " +
                 str.tostring(int(lastScore)) + " | Quality: " + str.tostring(int(lastQuality)),
                 alert.freq_once_per_bar_close)

    lastPatternCount := array.size(patternA)

// Truncated W5 bot-ready alert
if enableTruncatedSignal and chartState == "WAVE_5" and chartTruncated and chartValidImpulse and not truncatedW5Alerted and barstate.isconfirmed
    string tw5Side = chartDir == 1.0 ? "SHORT" : "LONG"
    string tw5Json = "{\"event\":\"truncated_w5\",\"side\":\"" + tw5Side + "\",\"ticker\":\"" + syminfo.ticker + "\",\"tf\":\"" + timeframe.period + "\"}"
    alert("⚠️ 5T REVERSAL — Truncated W5 on chart TF. Weak impulse, sharp " + tw5Side + " likely. | BOT: " + tw5Json, alert.freq_once_per_bar_close)
    truncatedW5Alerted := true
if not (chartState == "WAVE_5" and chartTruncated and chartValidImpulse)
    truncatedW5Alerted := false

// C wave projection alerts
var bool cAwaitingPrev = false

if cAwaiting and not cAwaitingPrev and barstate.isconfirmed and enableCProj
    bool htfSupportive = htf1_state == "WAVE_4" or htf2_state == "WAVE_4" or htf1_state == "WAVE_C" or htf2_state == "WAVE_C"
    string urgency = htfSupportive ? "⚡ HIGH PRIORITY" : "📐"
    string cProjJson = "{\"event\":\"c_wave_loading\",\"ticker\":\"" + syminfo.ticker + "\",\"tf\":\"" + timeframe.period + "\",\"htf_supportive\":" + (htfSupportive ? "true" : "false") + "}"
    alert(urgency + " C WAVE LOADING — B confirmed. HTF " +
         (htfSupportive ? "supportive (" + htf1_state + "/" + htf2_state + ")" : "neutral") +
         ". C targets drawn on margin. | BOT: " + cProjJson, alert.freq_once_per_bar_close)
cAwaitingPrev := cAwaiting

// ═════════════════════════════════════════════════════════════════════════════
// SRUS BRANDING WATERMARK
// ═════════════════════════════════════════════════════════════════════════════

var label watermark = na
if barstate.islast
    if na(watermark)
        watermark := label.new(bar_index, high, "SRUS Wave Sniper", 
             style=label.style_label_center, color=na, 
             textcolor=color.new(color.purple, 50), size=size.tiny, 
             yloc=yloc.abovebar)
    else
        label.set_x(watermark, bar_index)
        label.set_y(watermark, high)

// ═════════════════════════════════════════════════════════════════════════════
// END OF SCRIPT
// ═════════════════════════════════════════════════════════════════════════════
````
