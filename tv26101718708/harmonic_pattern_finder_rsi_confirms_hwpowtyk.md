# Harmonic Pattern Finder - RSI Confirms

- url: https://www.tradingview.com/script/HwpoWtYk-Harmonic-Pattern-Finder-RSI-Confirms/
- type: indicator
- pine_id: PUB;c7cef4aecfcf45dc9a8eecb111d1b4c9
- version: 2.0

## Description

# HarmonicPatternFinder TV v2 — PDF Index Edition

## TradingView Publication Description

---

### Short Description (for title area)

> Advanced harmonic pattern detection engine with row-specific PRZ completion formulas, RSI momentum confluence, and real-time projection tracking. Covers 50+ pattern variations across 8 harmonic families.

---

### Full Description (copy below for publication)

---

**HarmonicPatternFinder TV v2 — PDF Index Edition**

An advanced harmonic pattern detection engine built from the ground up in Pine Script v6. Unlike conventional harmonic indicators that use broad Fibonacci ranges, this indicator implements **row-specific PRZ completion formulas** derived from a comprehensive Pattern Index reference — giving you precise, granular pattern identification across 50+ distinct harmonic variations.

---

#### 🔍 WHAT IT DETECTS

**8 Harmonic Pattern Families:**

| Family | Variations | Type |
|--------|-----------|------|
| AB=CD | 7 ratios (0.382 – 0.886) | 4-Point |
| Alternate AB=CD | 9 ratios (1.13 – 3.618) | 4-Point |
| Reciprocal AB=CD | 6 ratios (1.13 – 3.618) | 4-Point |
| Gartley | 4 PRZ rows | 5-Point (XABCD) |
| Bat / Alt Bat | 6 + 4 PRZ rows | 5-Point (XABCD) |
| Butterfly | 3 PRZ rows | 5-Point (XABCD) |
| Crab / Deep Crab | 3 + 4 PRZ rows | 5-Point (XABCD) |
| Cypher | 3 PRZ rows | 5-Point (XABCD) |
| Shark | 5 PRZ rows | 5-Point (XABCD) |
| 5-0 | 3 PRZ rows | 5-Point (XABCD) |
| Three Drives | 2 variations | 5-Point (XABCD) |

Each pattern variation has its own **unique set of Fibonacci constraints** — not a single broad range, but exact row-level ratios as defined in the Harmonic Pattern PRZ Index.

---

#### ⚙️ DETECTION ENGINE

- **ATR-Based ZigZag**: Adaptive pivot detection using ATR multiplier with configurable period constraints. Supports real-time pivot updates.
- **Multi-Constraint Validation**: Every pattern is validated against multiple Fibonacci ratios simultaneously (AB/XA, BC/AB, CD/BC, AD/XA, CD/XC, XC/XA, CD/AB, BC/XA, CD/AD) — depending on pattern family.
- **Configurable Slack**: Separate tolerance for singular ratios (exact Fib levels) and range ratios, allowing you to fine-tune detection sensitivity.
- **Timezone Filtering**: Optional filters for patterns that complete too early or too late relative to their expected time proportion.
- **Purist PRZ Mode**: Optional strict containment filter that ensures all Fibonacci projections overlap within the PRZ zone.
- **Overlap Management**: Configurable maximum shared points between patterns to prevent cluttered output.

---

#### 📊 THREE PATTERN STATES

1. **Confirmed Patterns** — Point D has been reached and validated. The pattern structure (X-A-B-C-D legs) is drawn with solid lines. Clean display without PRZ overlay since the reversal zone has already been tested.

2. **Emerging / Projection Patterns** — Price is approaching but has not yet reached the PRZ zone. Drawn with dashed lines and a visible PRZ box + dashed PRZ line to highlight the potential reversal area ahead.

3. **One-Ahead Projections** — Speculative patterns where only X-A-B-C are confirmed and the indicator projects where D *could* form if the current swing continues. Useful for anticipating setups before they materialize.

---

#### 📈 RSI CONFLUENCE FILTER

A built-in RSI validation layer adds momentum confluence to harmonic patterns:

**For Confirmed Patterns (D already formed):**
- Displays the actual RSI value at bar D on the point label
- Validates whether RSI was in overbought (bearish) or oversold (bullish) territory when D formed
- **Strict Mode**: Automatically removes patterns where RSI does not confirm the expected reversal direction

**For Projection Patterns (D not yet reached):**
- Displays **current RSI** with honest labeling ("RSI Now") — not a fabricated future value
- Shows RSI **trend direction** (rising / falling / flat) by comparing current RSI vs 3 bars ago
- Shows **proximity to target zone** (e.g., "near OS" for bullish projections approaching oversold)
- Filters projections by RSI momentum direction (bullish projections need RSI below threshold, bearish above)

> **Design Philosophy**: The indicator never pretends to predict future RSI values. For projections where price hasn't reached the PRZ, it transparently shows current RSI conditions and momentum direction so you can assess confluence in real time.

---

#### 🎨 DISPLAY & CUSTOMIZATION

- **Separate color schemes** for 4-point and 5-point patterns, bullish and bearish, confirmed and projected
- **Ratio lines** (dotted X-B, A-C, B-D connectors) for visual Fibonacci structure analysis
- **Fade projections** option for softer visual distinction between confirmed and emerging patterns
- **Configurable label sizes** (tiny / small / normal)
- **Adjustable PRZ extend bars** to control how far the reversal zone projects forward
- **Max pattern limits** for both confirmed and emerging patterns to keep charts clean

---

#### ⚡ SETTINGS GUIDE

**ZigZag** — Controls pivot detection sensitivity. Higher ATR multiplier = fewer, larger swings. Lower = more granular patterns.

**Engine** — Core detection parameters:
- *Max Bars Per Pattern*: Maximum span a single pattern can cover
- *History Bars*: How far back to scan (200–5000)
- *Fib Slack*: Tolerance for ratio matching (increase for more patterns, decrease for stricter)

**Pattern Groups** — Toggle each family on/off independently.

**RSI Filter** — Enable/disable RSI validation. Configure OB/OS levels, strict vs display-only mode, and projection filtering.

---

#### 💡 USAGE TIPS

1. **Start with defaults** — The indicator ships with balanced settings suitable for most timeframes and instruments.
2. **Use RSI Filter for higher-quality setups** — Enable RSI in strict mode to automatically filter patterns without momentum confirmation.
3. **Watch projection PRZ zones** — These highlight areas where price *may* reverse if a harmonic pattern completes. The RSI momentum info helps assess probability.
4. **Reduce noise** — Disable pattern groups you don't trade (e.g., turn off Reciprocal AB=CD if you focus on XABCD patterns).
5. **Adjust Fib Slack** — Tighter slack (0.02–0.03) gives stricter, textbook-quality patterns. Looser slack (0.08–0.15) finds more patterns but with less precision.

---

#### ⚠️ DISCLAIMER

This indicator is a **technical analysis tool** for educational and informational purposes. Harmonic patterns represent potential reversal zones based on Fibonacci relationships — they are not guaranteed trade signals. Always use proper risk management and combine with your own analysis. Past pattern completion does not guarantee future results.

---

**Works on all instruments and timeframes. Built with Pine Script v6.**

## Source Code

````pine
//@version=6
// PRZ matrix aligned with Harmonic_Pattern_PRZ_Index.xlsx,
// which expands the textbook Pattern Index into row-specific completion formulas.
indicator("Harmonic Pattern Finder - RSI Confirms", "HPF [XRX]", overlay = true, format = format.price, max_bars_back = 5000, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 200)

const int GROUP_ABCD = 0
const int GROUP_ALT_ABCD = 1
const int GROUP_REC_ABCD = 2
const int GROUP_XABCD = 3
const int GROUP_SHARK = 4
const int GROUP_CYPHER = 5
const int GROUP_FIVEO = 6
const int GROUP_THREEDRIVES = 7

const int STATE_PERSISTENT = 0
const int STATE_TRANSIENT = 1
const int STATE_PROJECTION = 2
const int STATE_ONE_AHEAD = 3

const int PIVOT_TROUGH = -1
const int PIVOT_PEAK = 1
const int TIMELY_TOO_EARLY = 0
const int TIMELY_OK = 1
const int TIMELY_TOO_LATE = 2
const float BIG = 1e10

zigzagGroup = "ZigZag"
zzAtrMultiplier = input.float(2.0, "ATR Multiplier", minval = 0.1, step = 0.1, group = zigzagGroup)
zzAtrPeriod = input.int(50, "ATR Period", minval = 1, group = zigzagGroup)
zzMaxPeriod = input.int(10, "Max Period", minval = 1, group = zigzagGroup)
zzMinPeriod = input.int(3, "Min Period", minval = 0, group = zigzagGroup)
zzRealtime = input.bool(true, "Realtime ZigZag", group = zigzagGroup)

engineGroup = "Engine"
barsAnalyzed = input.int(300, "Max Bars Per Pattern", minval = 50, maxval = 2000, group = engineGroup)
historyBars = input.int(1000, "History Bars To Process", minval = 200, maxval = 5000, group = engineGroup)
maxSharedPoints = input.int(2, "Max Shared Points Per Pattern", minval = 0, maxval = 4, group = engineGroup)
slackRange = input.float(0.05, "Fib Slack (Range)", minval = 0.0, maxval = 0.5, step = 0.005, group = engineGroup)
slackSingular = input.float(0.10, "Fib Slack (Unary)", minval = 0.0, maxval = 0.5, step = 0.005, group = engineGroup)
tooEarly = input.float(0.382, "Too Early Timezone", minval = 0.0, step = 0.001, group = engineGroup)
idealTime = input.float(1.0, "Ideal Timezone", minval = 0.0, step = 0.001, group = engineGroup)
tooLate = input.float(1.618, "Too Late Timezone", minval = 0.0, step = 0.001, group = engineGroup)
puristPrz = input.bool(false, "Filter PRZ Outside Pure Fib Containment", group = engineGroup)
timeFilterEarly = input.bool(false, "Filter Too Early Patterns", group = engineGroup)
timeFilterLate = input.bool(false, "Filter Too Late Patterns", group = engineGroup)

quickGroup = "Pattern Groups"
showABCD = input.bool(true, "Show AB=CD", group = quickGroup)
showAltABCD = input.bool(true, "Show Alternate AB=CD", group = quickGroup)
showRecABCD = input.bool(false, "Show Reciprocal AB=CD", group = quickGroup)
showXabcd = input.bool(true, "Show Gartley/Bat/Crab Family", group = quickGroup)
showShark = input.bool(true, "Show Shark", group = quickGroup)
showCypher = input.bool(true, "Show Cypher", group = quickGroup)
showFiveO = input.bool(true, "Show 5-0", group = quickGroup)
showThreeDrives = input.bool(true, "Show Three Drives", group = quickGroup)

displayGroup = "Display"
showOldPatterns = input.bool(true, "Show Confirmed Patterns", group = displayGroup)
showEmergingPatterns = input.bool(true, "Show Emerging Patterns", group = displayGroup)
showOneAheadProjections = input.bool(false, "Show One-Ahead Projections", group = displayGroup)
showSoftProjections = input.bool(true, "Fade Projection Bodies", group = displayGroup)
showDescriptions = input.bool(true, "Show Point Labels", group = displayGroup)
showRatioLines = input.bool(true, "Show Ratio Lines", group = displayGroup)
showPrzLine = input.bool(true, "Show PRZ / PRS Line", group = displayGroup)
showPrzBox = input.bool(true, "Show PRZ / PRS Box", group = displayGroup)
maxConfirmedDraw = input.int(6, "Max Confirmed Patterns Drawn", minval = 1, maxval = 20, group = displayGroup)
maxEmergingDraw = input.int(6, "Max Emerging Patterns Drawn", minval = 1, maxval = 20, group = displayGroup)
przExtendBars = input.int(40, "PRZ Extend Bars", minval = 5, maxval = 300, group = displayGroup)

colorGroup = "Colors"
clrBull = input.color(color.rgb(135, 206, 250), "Bullish 5P", group = colorGroup)
clrBear = input.color(color.rgb(255, 182, 193), "Bearish 5P", group = colorGroup)
clrBull4 = input.color(color.rgb(0, 191, 255), "Bullish 4P", group = colorGroup)
clrBear4 = input.color(color.rgb(255, 20, 147), "Bearish 4P", group = colorGroup)
clrBullProj = input.color(color.rgb(46, 139, 87), "Bullish Projection 5P", group = colorGroup)
clrBearProj = input.color(color.rgb(255, 140, 0), "Bearish Projection 5P", group = colorGroup)
clrBullProj4 = input.color(color.rgb(154, 205, 50), "Bullish Projection 4P", group = colorGroup)
clrBearProj4 = input.color(color.rgb(255, 215, 0), "Bearish Projection 4P", group = colorGroup)
clrRatio = input.color(color.silver, "Ratio Line Color", group = colorGroup)

styleGroup = "Stroke"
mainWidth = input.int(2, "Confirmed Width", minval = 1, maxval = 5, group = styleGroup)
projectionWidth = input.int(1, "Projection Width", minval = 1, maxval = 4, group = styleGroup)
ratioWidth = input.int(1, "Ratio Width", minval = 1, maxval = 3, group = styleGroup)
fontSizeInput = input.string("small", "Label Size", options = ["tiny", "small", "normal"], group = styleGroup)
labelSize = fontSizeInput == "tiny" ? size.tiny : fontSizeInput == "normal" ? size.normal : size.small

rsiGroup = "RSI Filter"
useRsiFilter       = input.bool(false, "Enable RSI Filter", group = rsiGroup, tooltip = "Filter harmonic patterns using RSI validation at point D")
rsiLength          = input.int(14, "RSI Length", minval = 2, maxval = 100, group = rsiGroup)
rsiOverbought      = input.float(70.0, "Overbought Level", minval = 50.0, maxval = 95.0, step = 1.0, group = rsiGroup)
rsiOversold        = input.float(30.0, "Oversold Level", minval = 5.0, maxval = 50.0, step = 1.0, group = rsiGroup)
rsiStrictMode      = input.bool(true, "Strict Mode (remove invalid)", group = rsiGroup, tooltip = "ON = remove patterns with invalid RSI. OFF = show all patterns but display RSI value on label")
rsiFilterProjection = input.bool(true, "Filter Projections by RSI", group = rsiGroup, tooltip = "Filter projection/prediction patterns using current RSI momentum direction")
rsiProjThreshold   = input.float(50.0, "Projection RSI Threshold", minval = 20.0, maxval = 80.0, step = 1.0, group = rsiGroup, tooltip = "For projections: bullish needs RSI below this, bearish needs RSI above this")
showRsiOnLabel     = input.bool(true, "Show RSI Value on D Label", group = rsiGroup)
showRsiOnPrz       = input.bool(true, "Show RSI Potential on PRZ", group = rsiGroup, tooltip = "Display current RSI value and OB/OS status on PRZ box label")

obGroup = "Order Block Filter"
useOBFilter      = input.bool(false, "Enable OB Filter", group = obGroup, tooltip = "Filter patterns: PRZ must overlap with active Order Block")
obSwingLen       = input.int(10, "OB Swing Lookback", minval = 3, group = obGroup)
obMaxCount       = input.int(5, "Max OB Tracked", minval = 1, maxval = 20, group = obGroup)
obUseBody        = input.bool(false, "OB Use Candle Body", group = obGroup)
obStrictMode     = input.bool(true, "Strict Mode (remove invalid)", group = obGroup, tooltip = "ON = remove patterns without OB confirmation. OFF = show all with label")
showOBOnLabel    = input.bool(true, "Show OB Status on Label", group = obGroup)

fvgGroup = "FVG Filter"
useFVGFilter     = input.bool(false, "Enable FVG Filter", group = fvgGroup, tooltip = "Filter patterns: PRZ must overlap with un-mitigated FVG")
fvgAutoThreshold = input.bool(true, "FVG Auto Threshold", group = fvgGroup)
fvgMaxCount      = input.int(10, "Max FVG Tracked", minval = 1, maxval = 30, group = fvgGroup)
fvgStrictMode    = input.bool(true, "Strict Mode (remove invalid)", group = fvgGroup, tooltip = "ON = remove patterns without FVG confirmation. OFF = show all with label")
showFVGOnLabel   = input.bool(true, "Show FVG Status on Label", group = fvgGroup)

type PatternDesc
    float ab2xaMin
    float ab2xaMax
    float bc2abMin
    float bc2abMax
    float cd2bcMin
    float cd2bcMax
    float ad2xaMin
    float ad2xaMax
    float cd2xcMin
    float cd2xcMax
    float xc2xaMin
    float xc2xaMax
    float cd2abMin
    float cd2abMax
    float bc2xaMin
    float bc2xaMax
    float cd2adMin
    float cd2adMax
    string name
    bool is4p
    int groupCode

type PivotEvent
    int barIndex
    float price
    int kind

type PatternMatch
    bool bullish
    int xIndex
    int aIndex
    int bIndex
    int cIndex
    int dIndex
    float x
    float a
    float b
    float c
    float d
    float nearD
    float farD
    int patternIndex

type OBZone
    float top
    float btm
    int   barIdx

type FVGZone
    float top
    float btm
    int   barIdx
    int   createArrIdx
    bool  mitigated = false
    bool  isBullish

patternDef(float ab2xaMin, float ab2xaMax, float bc2abMin, float bc2abMax, float cd2bcMin, float cd2bcMax, float ad2xaMin, float ad2xaMax, float cd2xcMin, float cd2xcMax, float xc2xaMin, float xc2xaMax, float cd2abMin, float cd2abMax, string name, bool is4p, int groupCode) =>
    PatternDesc.new(ab2xaMin, ab2xaMax, bc2abMin, bc2abMax, cd2bcMin, cd2bcMax, ad2xaMin, ad2xaMax, cd2xcMin, cd2xcMax, xc2xaMin, xc2xaMax, cd2abMin, cd2abMax, 0.0, 0.0, 0.0, 0.0, name, is4p, groupCode)

fullPatternDef(float ab2xaMin, float ab2xaMax, float bc2abMin, float bc2abMax, float cd2bcMin, float cd2bcMax, float ad2xaMin, float ad2xaMax, float cd2xcMin, float cd2xcMax, float xc2xaMin, float xc2xaMax, float cd2abMin, float cd2abMax, float bc2xaMin, float bc2xaMax, float cd2adMin, float cd2adMax, string name, bool is4p, int groupCode) =>
    PatternDesc.new(ab2xaMin, ab2xaMax, bc2abMin, bc2abMax, cd2bcMin, cd2bcMax, ad2xaMin, ad2xaMax, cd2xcMin, cd2xcMax, xc2xaMin, xc2xaMax, cd2abMin, cd2abMax, bc2xaMin, bc2xaMax, cd2adMin, cd2adMax, name, is4p, groupCode)

addPattern(array<PatternDesc> defs, array<string> names, PatternDesc pat) =>
    array.push(defs, pat)
    array.push(names, pat.name)

invertPattern(PatternDesc original, string name, bool is4p, int groupCode) =>
    float ab2xaMin = original.cd2bcMax != 0.0 ? 1.0 / original.cd2bcMax : 0.0
    float ab2xaMax = original.cd2bcMin != 0.0 ? 1.0 / original.cd2bcMin : 0.0
    float bc2abMin = original.bc2abMax != 0.0 ? 1.0 / original.bc2abMax : 0.0
    float bc2abMax = original.bc2abMin != 0.0 ? 1.0 / original.bc2abMin : 0.0
    float cd2bcMin = original.ab2xaMax != 0.0 ? 1.0 / original.ab2xaMax : 0.0
    float cd2bcMax = original.ab2xaMin != 0.0 ? 1.0 / original.ab2xaMin : 0.0
    float ad2xaMin = original.cd2xcMax != 0.0 ? 1.0 / original.cd2xcMax : 0.0
    float ad2xaMax = original.cd2xcMin != 0.0 ? 1.0 / original.cd2xcMin : 0.0
    float cd2xcMin = original.ad2xaMax != 0.0 ? 1.0 / original.ad2xaMax : 0.0
    float cd2xcMax = original.ad2xaMin != 0.0 ? 1.0 / original.ad2xaMin : 0.0
    float xc2xaMin = 0.0
    float xc2xaMax = 0.0
    float cd2abMin = 0.0
    float cd2abMax = 0.0
    float bc2xaMin = original.cd2abMax != 0.0 ? 1.0 / original.cd2abMax : 0.0
    float bc2xaMax = original.cd2abMin != 0.0 ? 1.0 / original.cd2abMin : 0.0
    float cd2adMin = original.xc2xaMax != 0.0 ? 1.0 / original.xc2xaMax : 0.0
    float cd2adMax = original.xc2xaMin != 0.0 ? 1.0 / original.xc2xaMin : 0.0
    fullPatternDef(ab2xaMin, ab2xaMax, bc2abMin, bc2abMax, cd2bcMin, cd2bcMax, ad2xaMin, ad2xaMax, cd2xcMin, cd2xcMax, xc2xaMin, xc2xaMax, cd2abMin, cd2abMax, bc2xaMin, bc2xaMax, cd2adMin, cd2adMax, name, is4p, groupCode)

var array<PatternDesc> patterns = array.new<PatternDesc>()
var array<string> patternNames = array.new_string()
var array<line> drawnLines = array.new_line()
var array<label> drawnLabels = array.new_label()
var array<box> drawnBoxes = array.new_box()
var array<int> drawBarIndices = array.new_int()
var array<int> drawBarTimes = array.new_int()
var array<OBZone>  g_bullOBs = array.new<OBZone>()
var array<OBZone>  g_bearOBs = array.new<OBZone>()
var array<FVGZone> g_bullFVGs = array.new<FVGZone>()
var array<FVGZone> g_bearFVGs = array.new<FVGZone>()

// Workbook mapping:
// - XABCD rows: C -> AB/XA, D -> BC/AB, E -> CD/BC, description -> AD/XA and optional CD/AB
// - Cypher rows: C -> AB/XA, D -> XC/XA, E -> CD/XC, description -> CD/BC
// - Shark rows: C -> BC/XA, D -> BC/AB, E -> CD/BC, description -> CD/XC
initPatterns(array<PatternDesc> patterns, array<string> patternNames) =>
    if array.size(patterns) == 0
        addPattern(patterns, patternNames, patternDef(0, 0, 0.382, 0.382, 2.618, 2.618, 0, 0, 0, 0, 0, 0, 1, 1, "AB=CD 0.382", true, GROUP_ABCD))
        addPattern(patterns, patternNames, patternDef(0, 0, 0.44, 0.44, 2.24, 2.24, 0, 0, 0, 0, 0, 0, 1, 1, "AB=CD 0.44", true, GROUP_ABCD))
        addPattern(patterns, patternNames, patternDef(0, 0, 0.5, 0.5, 2.0, 2.0, 0, 0, 0, 0, 0, 0, 1, 1, "AB=CD 0.50", true, GROUP_ABCD))
        addPattern(patterns, patternNames, patternDef(0, 0, 0.618, 0.618, 1.618, 1.618, 0, 0, 0, 0, 0, 0, 1, 1, "AB=CD 0.618", true, GROUP_ABCD))
        addPattern(patterns, patternNames, patternDef(0, 0, 0.707, 0.707, 1.414, 1.414, 0, 0, 0, 0, 0, 0, 1, 1, "AB=CD 0.707", true, GROUP_ABCD))
        addPattern(patterns, patternNames, patternDef(0, 0, 0.786, 0.786, 1.272, 1.272, 0, 0, 0, 0, 0, 0, 1, 1, "AB=CD 0.786", true, GROUP_ABCD))
        addPattern(patterns, patternNames, patternDef(0, 0, 0.886, 0.886, 1.13, 1.13, 0, 0, 0, 0, 0, 0, 1, 1, "AB=CD 0.886", true, GROUP_ABCD))

        addPattern(patterns, patternNames, patternDef(0, 0, 0.382, 0.886, 0, 0, 0, 0, 0, 0, 0, 0, 1.13, 1.13, "Alt AB=CD 1.13", true, GROUP_ALT_ABCD))
        addPattern(patterns, patternNames, patternDef(0, 0, 0.382, 0.886, 0, 0, 0, 0, 0, 0, 0, 0, 1.272, 1.272, "Alt AB=CD 1.272", true, GROUP_ALT_ABCD))
        addPattern(patterns, patternNames, patternDef(0, 0, 0.382, 0.886, 0, 0, 0, 0, 0, 0, 0, 0, 1.414, 1.414, "Alt AB=CD 1.414", true, GROUP_ALT_ABCD))
        addPattern(patterns, patternNames, patternDef(0, 0, 0.382, 0.886, 0, 0, 0, 0, 0, 0, 0, 0, 1.618, 1.618, "Alt AB=CD 1.618", true, GROUP_ALT_ABCD))
        addPattern(patterns, patternNames, patternDef(0, 0, 0.382, 0.886, 0, 0, 0, 0, 0, 0, 0, 0, 2.0, 2.0, "Alt AB=CD 2.0", true, GROUP_ALT_ABCD))
        addPattern(patterns, patternNames, patternDef(0, 0, 0.382, 0.886, 0, 0, 0, 0, 0, 0, 0, 0, 2.24, 2.24, "Alt AB=CD 2.24", true, GROUP_ALT_ABCD))
        addPattern(patterns, patternNames, patternDef(0, 0, 0.382, 0.886, 0, 0, 0, 0, 0, 0, 0, 0, 2.618, 2.618, "Alt AB=CD 2.618", true, GROUP_ALT_ABCD))
        addPattern(patterns, patternNames, patternDef(0, 0, 0.382, 0.886, 0, 0, 0, 0, 0, 0, 0, 0, 3.14, 3.14, "Alt AB=CD 3.14", true, GROUP_ALT_ABCD))
        addPattern(patterns, patternNames, patternDef(0, 0, 0.382, 0.886, 0, 0, 0, 0, 0, 0, 0, 0, 3.618, 3.618, "Alt AB=CD 3.618", true, GROUP_ALT_ABCD))

        addPattern(patterns, patternNames, patternDef(0, 0, 2.24, 3.618, 0.382, 0.44, 0, 0, 0, 0, 0, 0, 1, 1, "Recip AB=CD 2.24-3.618", true, GROUP_REC_ABCD))
        addPattern(patterns, patternNames, patternDef(0, 0, 2.0, 2.0, 0.5, 0.5, 0, 0, 0, 0, 0, 0, 1, 1, "Recip AB=CD 2.0", true, GROUP_REC_ABCD))
        addPattern(patterns, patternNames, patternDef(0, 0, 1.618, 1.618, 0.618, 0.618, 0, 0, 0, 0, 0, 0, 1, 1, "Recip AB=CD 1.618", true, GROUP_REC_ABCD))
        addPattern(patterns, patternNames, patternDef(0, 0, 1.414, 1.414, 0.707, 0.707, 0, 0, 0, 0, 0, 0, 1, 1, "Recip AB=CD 1.414", true, GROUP_REC_ABCD))
        addPattern(patterns, patternNames, patternDef(0, 0, 1.272, 1.272, 0.786, 0.786, 0, 0, 0, 0, 0, 0, 1, 1, "Recip AB=CD 1.272", true, GROUP_REC_ABCD))
        addPattern(patterns, patternNames, patternDef(0, 0, 1.13, 1.13, 0.886, 0.886, 0, 0, 0, 0, 0, 0, 1, 1, "Recip AB=CD 1.13", true, GROUP_REC_ABCD))

        addPattern(patterns, patternNames, patternDef(0.618, 0.618, 0.886, 0.886, 1.272, 1.272, 0.786, 0.786, 0, 0, 0, 0, 1.13, 1.13, "Gartley PRZ 1", false, GROUP_XABCD))
        addPattern(patterns, patternNames, patternDef(0.618, 0.618, 0.786, 0.786, 1.272, 1.272, 0.786, 0.786, 0, 0, 0, 0, 0.786, 0.786, "Gartley PRZ 2", false, GROUP_XABCD))
        addPattern(patterns, patternNames, patternDef(0.618, 0.618, 0.707, 0.707, 1.414, 1.414, 0.786, 0.786, 0, 0, 0, 0, 0.707, 0.707, "Gartley PRZ 3", false, GROUP_XABCD))
        addPattern(patterns, patternNames, patternDef(0.618, 0.618, 0.618, 0.618, 1.414, 1.618, 0.786, 0.786, 0, 0, 0, 0, 0.618, 0.618, "Gartley PRZ 4", false, GROUP_XABCD))

        addPattern(patterns, patternNames, patternDef(0.5, 0.5, 0.786, 0.786, 2.0, 2.0, 0.886, 0.886, 0, 0, 0, 0, 1.618, 1.618, "Bat PRZ 1", false, GROUP_XABCD))
        addPattern(patterns, patternNames, patternDef(0.5, 0.5, 0.707, 0.707, 2.0, 2.0, 0.886, 0.886, 0, 0, 0, 0, 1.414, 1.414, "Bat PRZ 2", false, GROUP_XABCD))
        addPattern(patterns, patternNames, patternDef(0.5, 0.5, 0.618, 0.618, 2.24, 2.24, 0.886, 0.886, 0, 0, 0, 0, 1.414, 1.414, "Bat PRZ 3", false, GROUP_XABCD))
        addPattern(patterns, patternNames, patternDef(0.5, 0.5, 0.5, 0.5, 2.618, 2.618, 0.886, 0.886, 0, 0, 0, 0, 1.272, 1.272, "Bat PRZ 4", false, GROUP_XABCD))
        addPattern(patterns, patternNames, patternDef(0.382, 0.382, 0.886, 0.886, 2.618, 2.618, 0.886, 0.886, 0, 0, 0, 0, 2.24, 2.24, "Bat PRZ 5", false, GROUP_XABCD))
        addPattern(patterns, patternNames, patternDef(0.382, 0.382, 0.786, 0.786, 2.618, 2.618, 0.886, 0.886, 0, 0, 0, 0, 2.0, 2.0, "Bat PRZ 6", false, GROUP_XABCD))

        addPattern(patterns, patternNames, patternDef(0.786, 0.786, 0.618, 0.618, 2.0, 2.0, 1.272, 1.272, 0, 0, 0, 0, 1.272, 1.272, "Butterfly PRZ 1", false, GROUP_XABCD))
        addPattern(patterns, patternNames, patternDef(0.786, 0.786, 0.5, 0.5, 2.24, 2.24, 1.272, 1.272, 0, 0, 0, 0, 1.13, 1.13, "Butterfly PRZ 2", false, GROUP_XABCD))
        addPattern(patterns, patternNames, patternDef(0.786, 0.786, 0.382, 0.382, 2.618, 2.618, 1.272, 1.272, 0, 0, 0, 0, 0.382, 0.382, "Butterfly PRZ 3", false, GROUP_XABCD))

        addPattern(patterns, patternNames, patternDef(0.618, 0.618, 0.707, 0.707, 3.14, 3.14, 1.618, 1.618, 0, 0, 0, 0, 2.24, 2.24, "Crab PRZ 1", false, GROUP_XABCD))
        addPattern(patterns, patternNames, patternDef(0.618, 0.618, 0.618, 0.618, 3.618, 3.618, 1.618, 1.618, 0, 0, 0, 0, 2.24, 2.24, "Crab PRZ 2", false, GROUP_XABCD))
        addPattern(patterns, patternNames, patternDef(0.5, 0.5, 0.886, 0.886, 3.618, 3.618, 1.618, 1.618, 0, 0, 0, 0, 3.14, 3.14, "Crab PRZ 3", false, GROUP_XABCD))

        addPattern(patterns, patternNames, patternDef(0.382, 0.382, 0.886, 0.886, 3.14, 3.14, 1.13, 1.13, 0, 0, 0, 0, 2.618, 2.618, "Alt Bat PRZ 1", false, GROUP_XABCD))
        addPattern(patterns, patternNames, patternDef(0.382, 0.382, 0.786, 0.786, 3.618, 3.618, 1.13, 1.13, 0, 0, 0, 0, 2.618, 2.618, "Alt Bat PRZ 2", false, GROUP_XABCD))
        addPattern(patterns, patternNames, patternDef(0.382, 0.382, 0.707, 0.707, 3.618, 3.618, 1.13, 1.13, 0, 0, 0, 0, 2.618, 2.618, "Alt Bat PRZ 3", false, GROUP_XABCD))
        addPattern(patterns, patternNames, patternDef(0.382, 0.382, 0.618, 0.618, 4.23, 4.23, 1.13, 1.13, 0, 0, 0, 0, 2.618, 2.618, "Alt Bat PRZ 4", false, GROUP_XABCD))

        addPattern(patterns, patternNames, patternDef(0.886, 0.886, 0.786, 0.786, 2.0, 2.0, 1.618, 1.618, 0, 0, 0, 0, 1.618, 1.618, "Deep Crab PRZ 1", false, GROUP_XABCD))
        addPattern(patterns, patternNames, patternDef(0.886, 0.886, 0.707, 0.707, 2.24, 2.24, 1.618, 1.618, 0, 0, 0, 0, 1.618, 1.618, "Deep Crab PRZ 2", false, GROUP_XABCD))
        addPattern(patterns, patternNames, patternDef(0.886, 0.886, 0.5, 0.5, 2.618, 2.618, 1.618, 1.618, 0, 0, 0, 0, 1.272, 1.272, "Deep Crab PRZ 3", false, GROUP_XABCD))
        addPattern(patterns, patternNames, patternDef(0.886, 0.886, 0.382, 0.382, 3.14, 3.14, 1.618, 1.618, 0, 0, 0, 0, 1.272, 1.272, "Deep Crab PRZ 4", false, GROUP_XABCD))

        addPattern(patterns, patternNames, patternDef(0.382, 0.618, 0, 0, 1.13, 1.13, 0, 0, 0.786, 0.786, 1.272, 1.272, 0, 0, "Cypher PRZ 1", false, GROUP_CYPHER))
        addPattern(patterns, patternNames, patternDef(0.5, 0.5, 0, 0, 1.272, 1.272, 0, 0, 0.786, 0.786, 1.272, 1.272, 0, 0, "Cypher PRZ 2", false, GROUP_CYPHER))
        addPattern(patterns, patternNames, patternDef(0.382, 0.382, 0, 0, 1.414, 1.414, 0, 0, 0.786, 0.786, 1.414, 1.414, 0, 0, "Cypher PRZ 3", false, GROUP_CYPHER))

        addPattern(patterns, patternNames, fullPatternDef(0, 0, 1.272, 1.272, 1.618, 1.618, 0, 0, 1.13, 1.13, 0, 0, 0, 0, 0.618, 0.618, 0, 0, "Shark PRZ 1", false, GROUP_SHARK))
        addPattern(patterns, patternNames, fullPatternDef(0, 0, 1.272, 1.272, 2.0, 2.0, 0, 0, 1.13, 1.13, 0, 0, 0, 0, 0.5, 0.5, 0, 0, "Shark PRZ 2", false, GROUP_SHARK))
        addPattern(patterns, patternNames, fullPatternDef(0, 0, 1.618, 1.618, 2.24, 2.24, 0, 0, 1.13, 1.13, 0, 0, 0, 0, 0.382, 0.382, 0, 0, "Shark PRZ 3", false, GROUP_SHARK))
        addPattern(patterns, patternNames, fullPatternDef(0, 0, 1.272, 1.272, 1.618, 1.618, 0, 0, 0.886, 0.886, 0, 0, 0, 0, 0.5, 0.5, 0, 0, "Shark PRZ 4", false, GROUP_SHARK))
        addPattern(patterns, patternNames, fullPatternDef(0, 0, 1.272, 1.272, 2.0, 2.0, 0, 0, 0.886, 0.886, 0, 0, 0, 0, 0.382, 0.382, 0, 0, "Shark PRZ 5", false, GROUP_SHARK))

        addPattern(patterns, patternNames, patternDef(1.618, 1.618, 1.618, 1.618, 0.5, 0.618, 0, 0, 0, 0, 0, 0, 0, 0, "5-0 PRZ 1", false, GROUP_FIVEO))
        addPattern(patterns, patternNames, patternDef(1.13, 1.13, 2.0, 2.0, 0.5, 0.5, 0, 0, 0, 0, 0, 0, 0, 0, "5-0 PRZ 2", false, GROUP_FIVEO))
        addPattern(patterns, patternNames, patternDef(1.618, 1.618, 2.24, 2.24, 0.5, 0.5, 0, 0, 0, 0, 0, 0, 0, 0, "5-0 PRZ 3", false, GROUP_FIVEO))

        addPattern(patterns, patternNames, patternDef(1.618, 1.618, 0.618, 0.618, 1.618, 1.618, 0, 0, 0, 0, 0, 0, 0, 0, "Three Drives 1", false, GROUP_THREEDRIVES))
        addPattern(patterns, patternNames, patternDef(1.272, 1.272, 0.786, 0.786, 1.272, 1.272, 0, 0, 0, 0, 0, 0, 0, 0, "Three Drives 2", false, GROUP_THREEDRIVES))

constraintActive(float minV, float maxV) =>
    minV != 0.0 and maxV != 0.0

effectiveSlack(float minV, float maxV) =>
    minV == maxV ? slackSingular : slackRange

shouldDisplayPattern(PatternDesc pat) =>
    switch pat.groupCode
        GROUP_ABCD => showABCD
        GROUP_ALT_ABCD => showAltABCD
        GROUP_REC_ABCD => showRecABCD
        GROUP_XABCD => showXabcd
        GROUP_SHARK => showShark
        GROUP_CYPHER => showCypher
        GROUP_FIVEO => showFiveO
        GROUP_THREEDRIVES => showThreeDrives
        => false

harmonicWindow(PatternDesc pat, bool startsInTrough, float X, float A, float B, float C) =>
    bool ad2xaConstraint = constraintActive(pat.ad2xaMin, pat.ad2xaMax)
    bool cd2bcConstraint = constraintActive(pat.cd2bcMin, pat.cd2bcMax)
    bool cd2xcConstraint = constraintActive(pat.cd2xcMin, pat.cd2xcMax)
    bool cd2abConstraint = constraintActive(pat.cd2abMin, pat.cd2abMax)
    bool cd2adConstraint = constraintActive(pat.cd2adMin, pat.cd2adMax)
    float ad2xaSlack = effectiveSlack(pat.ad2xaMin, pat.ad2xaMax)
    float cd2bcSlack = effectiveSlack(pat.cd2bcMin, pat.cd2bcMax)
    float cd2xcSlack = effectiveSlack(pat.cd2xcMin, pat.cd2xcMax)
    float cd2abSlack = effectiveSlack(pat.cd2abMin, pat.cd2abMax)
    float cd2adSlack = effectiveSlack(pat.cd2adMin, pat.cd2adMax)
    float XA = math.abs(A - X)
    float XC = math.abs(X - C)
    float AB = math.abs(A - B)
    float BC = math.abs(C - B)
    float nearD = startsInTrough ? BIG : -BIG
    float farD = startsInTrough ? -BIG : BIG
    if cd2bcConstraint
        float nearVal = startsInTrough ? C - (pat.cd2bcMin - cd2bcSlack) * BC : C + (pat.cd2bcMin - cd2bcSlack) * BC
        float farVal = startsInTrough ? C - (pat.cd2bcMax + cd2bcSlack) * BC : C + (pat.cd2bcMax + cd2bcSlack) * BC
        nearD := startsInTrough ? math.min(nearD, nearVal) : math.max(nearD, nearVal)
        farD := startsInTrough ? math.max(farD, farVal) : math.min(farD, farVal)
    if ad2xaConstraint
        float nearVal = startsInTrough ? A - (pat.ad2xaMin - ad2xaSlack) * XA : A + (pat.ad2xaMin - ad2xaSlack) * XA
        float farVal = startsInTrough ? A - (pat.ad2xaMax + ad2xaSlack) * XA : A + (pat.ad2xaMax + ad2xaSlack) * XA
        nearD := startsInTrough ? math.min(nearD, nearVal) : math.max(nearD, nearVal)
        farD := startsInTrough ? math.max(farD, farVal) : math.min(farD, farVal)
    if cd2xcConstraint
        float nearVal = startsInTrough ? C - (pat.cd2xcMin - cd2xcSlack) * XC : C + (pat.cd2xcMin - cd2xcSlack) * XC
        float farVal = startsInTrough ? C - (pat.cd2xcMax + cd2xcSlack) * XC : C + (pat.cd2xcMax + cd2xcSlack) * XC
        nearD := startsInTrough ? math.min(nearD, nearVal) : math.max(nearD, nearVal)
        farD := startsInTrough ? math.max(farD, farVal) : math.min(farD, farVal)
    if cd2abConstraint
        float nearVal = startsInTrough ? C - (pat.cd2abMin - cd2abSlack) * AB : C + (pat.cd2abMin - cd2abSlack) * AB
        float farVal = startsInTrough ? C - (pat.cd2abMax + cd2abSlack) * AB : C + (pat.cd2abMax + cd2abSlack) * AB
        nearD := startsInTrough ? math.min(nearD, nearVal) : math.max(nearD, nearVal)
        farD := startsInTrough ? math.max(farD, farVal) : math.min(farD, farVal)
    if cd2adConstraint and (pat.cd2adMin - cd2adSlack) != 1.0 and (pat.cd2adMax + cd2adSlack) != 1.0
        float cd2ad1 = math.abs((C - (pat.cd2adMin - cd2adSlack) * A) / ((pat.cd2adMin - cd2adSlack) - 1.0))
        float cd2ad2 = math.abs((C - (pat.cd2adMax + cd2adSlack) * A) / ((pat.cd2adMax + cd2adSlack) - 1.0))
        float nearVal = startsInTrough ? math.max(cd2ad1, cd2ad2) : math.min(cd2ad1, cd2ad2)
        float farVal = startsInTrough ? math.min(cd2ad1, cd2ad2) : math.max(cd2ad1, cd2ad2)
        nearD := startsInTrough ? math.min(nearD, nearVal) : math.max(nearD, nearVal)
        farD := startsInTrough ? math.max(farD, farVal) : math.min(farD, farVal)
    [nearD, farD]

isPuristPRZ(PatternDesc pat, bool startsInTrough, float X, float A, float B, float C, float nearD, float farD) =>
    bool ok = true
    float XA = math.abs(A - X)
    float XC = math.abs(X - C)
    float AB = math.abs(A - B)
    float BC = math.abs(C - B)
    if ok and constraintActive(pat.cd2bcMin, pat.cd2bcMax)
        float nearRatio = startsInTrough ? C - pat.cd2bcMin * BC : C + pat.cd2bcMin * BC
        float farRatio = startsInTrough ? C - pat.cd2bcMax * BC : C + pat.cd2bcMax * BC
        ok := startsInTrough ? (nearD >= farRatio and nearRatio >= farD) : (nearD <= farRatio and nearRatio <= farD)
    if ok and constraintActive(pat.ad2xaMin, pat.ad2xaMax)
        float nearRatio = startsInTrough ? A - pat.ad2xaMin * XA : A + pat.ad2xaMin * XA
        float farRatio = startsInTrough ? A - pat.ad2xaMax * XA : A + pat.ad2xaMax * XA
        ok := startsInTrough ? (nearD >= farRatio and nearRatio >= farD) : (nearD <= farRatio and nearRatio <= farD)
    if ok and constraintActive(pat.cd2xcMin, pat.cd2xcMax)
        float nearRatio = startsInTrough ? C - pat.cd2xcMin * XC : C + pat.cd2xcMin * XC
        float farRatio = startsInTrough ? C - pat.cd2xcMax * XC : C + pat.cd2xcMax * XC
        ok := startsInTrough ? (nearD >= farRatio and nearRatio >= farD) : (nearD <= farRatio and nearRatio <= farD)
    if ok and constraintActive(pat.cd2abMin, pat.cd2abMax)
        float nearRatio = startsInTrough ? C - pat.cd2abMin * AB : C + pat.cd2abMin * AB
        float farRatio = startsInTrough ? C - pat.cd2abMax * AB : C + pat.cd2abMax * AB
        ok := startsInTrough ? (nearD >= farRatio and nearRatio >= farD) : (nearD <= farRatio and nearRatio <= farD)
    if ok and constraintActive(pat.cd2adMin, pat.cd2adMax) and pat.cd2adMin != 1.0 and pat.cd2adMax != 1.0
        float cd2ad1 = math.abs((C - pat.cd2adMin * A) / (pat.cd2adMin - 1.0))
        float cd2ad2 = math.abs((C - pat.cd2adMax * A) / (pat.cd2adMax - 1.0))
        float nearRatio = startsInTrough ? math.max(cd2ad1, cd2ad2) : math.min(cd2ad1, cd2ad2)
        float farRatio = startsInTrough ? math.min(cd2ad1, cd2ad2) : math.max(cd2ad1, cd2ad2)
        ok := startsInTrough ? (nearD >= farRatio and nearRatio >= farD) : (nearD <= farRatio and nearRatio <= farD)
    ok

patternTimeliness(PatternDesc pat, int xIdx, int aIdx, int bIdx, int cIdx, int dIdx) =>
    int baseBars = pat.is4p ? (bIdx - aIdx) : (bIdx - xIdx)
    int fixBar = pat.is4p ? cIdx : bIdx
    if dIdx < fixBar + int(math.floor(tooEarly * baseBars))
        TIMELY_TOO_EARLY
    else if dIdx < fixBar + int(math.ceil(tooLate * baseBars))
        TIMELY_OK
    else
        TIMELY_TOO_LATE

matchAllowedMatched(PatternDesc pat, PatternMatch match) =>
    bool ok = true
    if puristPrz
        ok := isPuristPRZ(pat, match.bullish, match.x, match.a, match.b, match.c, match.nearD, match.farD)
    if ok and (timeFilterEarly or timeFilterLate)
        int timeState = patternTimeliness(pat, match.xIndex, match.aIndex, match.bIndex, match.cIndex, match.dIndex)
        ok := not (timeFilterEarly and timeState == TIMELY_TOO_EARLY)
        ok := ok and not (timeFilterLate and timeState == TIMELY_TOO_LATE)
    ok

matchAllowedUndershot(PatternDesc pat, PatternMatch match, int currentBarAbs) =>
    bool ok = true
    if puristPrz
        ok := isPuristPRZ(pat, match.bullish, match.x, match.a, match.b, match.c, match.nearD, match.farD)
    if ok and timeFilterLate
        ok := patternTimeliness(pat, match.xIndex, match.aIndex, match.bIndex, match.cIndex, currentBarAbs) != TIMELY_TOO_LATE
    ok

firstNonZeroFrom(int start, array<float> src) =>
    int found = na
    if array.size(src) > 0 and start >= 0
        int i = start
        while i >= 0
            if array.get(src, i) != 0.0
                found := i
                break
            i -= 1
    found

zigzagDirection(int idx, array<float> peaks, array<float> troughs) =>
    int lastPeakBefore = firstNonZeroFrom(idx - 1, peaks)
    int lastTroughBefore = firstNonZeroFrom(idx - 1, troughs)
    int dir = 0
    while not na(lastPeakBefore) and not na(lastTroughBefore) and lastPeakBefore == lastTroughBefore
        lastPeakBefore := firstNonZeroFrom(lastPeakBefore - 1, peaks)
        lastTroughBefore := firstNonZeroFrom(lastTroughBefore - 1, troughs)
    if na(lastPeakBefore) or na(lastTroughBefore)
        dir := 0
    else
        dir := lastPeakBefore < lastTroughBefore ? -1 : 1
    dir

sortMatchesByDIndex(array<PatternMatch> matches) =>
    int sz = array.size(matches)
    if sz > 1
        for i = 1 to sz - 1
            int j = i
            while j > 0
                PatternMatch left = array.get(matches, j - 1)
                PatternMatch right = array.get(matches, j)
                if left.dIndex > right.dIndex
                    array.set(matches, j - 1, right)
                    array.set(matches, j, left)
                else
                    break
                j -= 1

sortMatchesByNearD(array<PatternMatch> matches) =>
    int sz = array.size(matches)
    if sz > 1
        for i = 1 to sz - 1
            int j = i
            while j > 0
                PatternMatch left = array.get(matches, j - 1)
                PatternMatch right = array.get(matches, j)
                if left.nearD > right.nearD
                    array.set(matches, j - 1, right)
                    array.set(matches, j, left)
                else
                    break
                j -= 1

sortMatchesByDDesc(array<PatternMatch> matches) =>
    int sz = array.size(matches)
    if sz > 1
        for i = 1 to sz - 1
            int j = i
            while j > 0
                PatternMatch left = array.get(matches, j - 1)
                PatternMatch right = array.get(matches, j)
                if left.dIndex < right.dIndex
                    array.set(matches, j - 1, right)
                    array.set(matches, j, left)
                else
                    break
                j -= 1

countCoreMatches(PatternMatch a, PatternMatch b, bool is4p) =>
    int numMatches = 0
    if not is4p and a.xIndex == b.xIndex
        numMatches += 1
    if a.aIndex == b.aIndex
        numMatches += 1
    if a.bIndex == b.bIndex
        numMatches += 1
    if a.cIndex == b.cIndex
        numMatches += 1
    numMatches

overlapsStored(PatternMatch match, array<PatternMatch> persistent, array<PatternMatch> transient, bool is4p) =>
    bool hit = false
    int needSame = 3 + (is4p ? 0 : 1)
    int szPersist = array.size(persistent)
    if szPersist > 0
        for i = 0 to szPersist - 1
            PatternMatch stored = array.get(persistent, i)
            int numMatches = countCoreMatches(match, stored, is4p)
            if numMatches >= needSame
                hit := true
                break
            if stored.dIndex == match.dIndex
                numMatches += 1
            if numMatches > maxSharedPoints
                hit := true
                break
    if not hit
        int szTransient = array.size(transient)
        if szTransient > 0
            for i = 0 to szTransient - 1
                PatternMatch stored = array.get(transient, i)
                int numMatches = countCoreMatches(match, stored, is4p)
                if numMatches >= needSame
                    hit := true
                    break
                if stored.dIndex == match.dIndex
                    numMatches += 1
                if numMatches > maxSharedPoints
                    hit := true
                    break
    hit

projectionConflicts(PatternMatch match, array<PatternMatch> accepted, bool is4p) =>
    bool hit = false
    int sz = array.size(accepted)
    if sz > 0
        for i = 0 to sz - 1
            PatternMatch stored = array.get(accepted, i)
            int numMatches = countCoreMatches(match, stored, is4p)
            if numMatches > maxSharedPoints
                hit := true
                break
    hit

clearDrawings() =>
    while array.size(line.all) > 0
        line.delete(array.get(line.all, array.size(line.all) - 1))
    while array.size(label.all) > 0
        label.delete(array.get(label.all, array.size(label.all) - 1))
    while array.size(box.all) > 0
        box.delete(array.get(box.all, array.size(box.all) - 1))
    int lineCount = array.size(drawnLines)
    if lineCount > 0
        for i = 0 to lineCount - 1
            line.delete(array.get(drawnLines, i))
    array.clear(drawnLines)
    int labelCount = array.size(drawnLabels)
    if labelCount > 0
        for i = 0 to labelCount - 1
            label.delete(array.get(drawnLabels, i))
    array.clear(drawnLabels)
    int boxCount = array.size(drawnBoxes)
    if boxCount > 0
        for i = 0 to boxCount - 1
            box.delete(array.get(drawnBoxes, i))
    array.clear(drawnBoxes)

pushLine(line id) =>
    array.push(drawnLines, id)

pushLabel(label id) =>
    array.push(drawnLabels, id)

pushBox(box id) =>
    array.push(drawnBoxes, id)

rebuildDrawAnchorMap(array<int> barArr, array<int> timeArr) =>
    array.clear(drawBarIndices)
    array.clear(drawBarTimes)
    int count = array.size(barArr)
    if count > 0
        for i = 0 to count - 1
            array.push(drawBarIndices, array.get(barArr, i))
            array.push(drawBarTimes, array.get(timeArr, i))

barTimeFromIndex(int absBarIndex) =>
    int anchorTime = time
    int count = array.size(drawBarIndices)
    if count > 0
        int firstBar = array.get(drawBarIndices, 0)
        int lastBar = array.get(drawBarIndices, count - 1)
        int stepMs = int(timeframe.in_seconds() * 1000)
        if stepMs <= 0
            stepMs := 60000
        if absBarIndex >= firstBar and absBarIndex <= lastBar
            anchorTime := array.get(drawBarTimes, absBarIndex - firstBar)
        else if absBarIndex > lastBar
            anchorTime := array.get(drawBarTimes, count - 1) + (absBarIndex - lastBar) * stepMs
        else
            anchorTime := array.get(drawBarTimes, 0) - (firstBar - absBarIndex) * stepMs
    anchorTime

projectionLegColor(color baseColor) =>
    showSoftProjections ? color.new(baseColor, 78) : baseColor

projectionRatioColor(color baseColor) =>
    showSoftProjections ? color.new(baseColor, 80) : baseColor

przOverlapsOB(bool bullish, float nearD, float farD) =>
    bool overlap = false
    float przTop = math.max(nearD, farD)
    float przBtm = math.min(nearD, farD)
    int sz = bullish ? array.size(g_bullOBs) : array.size(g_bearOBs)
    if sz > 0
        for i = 0 to sz - 1
            OBZone z = bullish ? array.get(g_bullOBs, i) : array.get(g_bearOBs, i)
            if przBtm <= z.top and przTop >= z.btm
                overlap := true
                break
    overlap

przOverlapsFVG(bool bullish, float nearD, float farD) =>
    bool overlap = false
    float przTop = math.max(nearD, farD)
    float przBtm = math.min(nearD, farD)
    int sz = bullish ? array.size(g_bullFVGs) : array.size(g_bearFVGs)
    if sz > 0
        for i = 0 to sz - 1
            FVGZone z = bullish ? array.get(g_bullFVGs, i) : array.get(g_bearFVGs, i)
            if not z.mitigated and przBtm <= z.top and przTop >= z.btm
                overlap := true
                break
    overlap

mainColorFor(PatternDesc pat, bool bullish, bool projectionLike) =>
    pat.is4p ? (projectionLike ? (bullish ? clrBullProj4 : clrBearProj4) : (bullish ? clrBull4 : clrBear4)) : (projectionLike ? (bullish ? clrBullProj : clrBearProj) : (bullish ? clrBull : clrBear))

makeLine(int x1, float y1, int x2, float y2, color lineColor, lineStyle, int width) =>
    line.new(barTimeFromIndex(x1), y1, barTimeFromIndex(x2), y2, xloc = xloc.bar_time, extend = extend.none, color = lineColor, style = lineStyle, width = width, force_overlay = true)

makeLabel(int x, float y, string labelText, color textColor) =>
    label.new(barTimeFromIndex(x), y, labelText, xloc = xloc.bar_time, style = label.style_none, textcolor = textColor, size = labelSize, color = color.new(color.black, 100), force_overlay = true)

drawPrz(PatternDesc pat, PatternMatch match, bool projectionLike, float rsiValue, float rsiPrev, float rsiNow) =>
    if projectionLike
        color przColor = mainColorFor(pat, match.bullish, projectionLike)
        float przPrice = match.nearD
        if showPrzLine
            pushLine(makeLine(match.dIndex - 1, przPrice, match.dIndex + przExtendBars, przPrice, przColor, line.style_dashed, 1))
        if showPrzBox and match.nearD != match.farD
            float top = math.max(match.nearD, match.farD)
            float bottom = math.min(match.nearD, match.farD)
            pushBox(box.new(barTimeFromIndex(match.dIndex - 1), top, barTimeFromIndex(match.dIndex + przExtendBars), bottom, xloc = xloc.bar_time, bgcolor = color.new(przColor, 88), border_color = color.new(przColor, 55), force_overlay = true))
        if match.nearD != match.farD
            float top = math.max(match.nearD, match.farD)
            float bottom = math.min(match.nearD, match.farD)
            float midPrz = (top + bottom) / 2.0
            string przNameText = pat.name + (match.bullish ? " ▲" : " ▼")
            if showRsiOnPrz and (useRsiFilter or showRsiOnLabel) and not na(rsiNow)
                string rsiStr = str.tostring(rsiNow, "#.#")
                string trendDir = not na(rsiPrev) ? (rsiNow > rsiPrev + 1.0 ? " naik" : rsiNow < rsiPrev - 1.0 ? " turun" : " datar") : ""
                float distToTarget = match.bullish ? rsiNow - rsiOversold : rsiOverbought - rsiNow
                string proximity = ""
                if match.bullish
                    proximity := distToTarget <= 0 ? " | sudah OS" : distToTarget <= 10 ? " | dekat OS" : " | jauh dari OS"
                else
                    proximity := distToTarget <= 0 ? " | sudah OB" : distToTarget <= 10 ? " | dekat OB" : " | jauh dari OB"
                przNameText := przNameText + "\nRSI Now: " + rsiStr + trendDir + proximity
            if showOBOnLabel
                bool obOK = przOverlapsOB(match.bullish, match.nearD, match.farD)
                przNameText := przNameText + "\nOB: " + (obOK ? "✓" : "✗")
            if showFVGOnLabel
                bool fvgOK = przOverlapsFVG(match.bullish, match.nearD, match.farD)
                przNameText := przNameText + "\nFVG: " + (fvgOK ? "✓" : "✗")
            pushLabel(label.new(barTimeFromIndex(match.dIndex + przExtendBars), midPrz, przNameText, xloc = xloc.bar_time, style = label.style_none, textcolor = przColor, size = labelSize, color = color.new(color.black, 100), force_overlay = true))

pointTextColor(PatternDesc pat, bool bullish, bool projectionLike) =>
    projectionLike ? projectionLegColor(mainColorFor(pat, bullish, true)) : mainColorFor(pat, bullish, false)

drawPointLabel(int x, float y, string labelText, color clr) =>
    pushLabel(makeLabel(x, y, labelText, clr))

getRsiAtBar(array<int> barArr, array<float> rsiArr, int absBarIndex) =>
    int baseBar = array.size(barArr) > 0 ? array.get(barArr, 0) : 0
    int idx = absBarIndex - baseBar
    if idx >= 0 and idx < array.size(rsiArr)
        array.get(rsiArr, idx)
    else
        50.0

isRsiValidConfirmed(bool bullish, float rsiValue) =>
    bullish ? rsiValue <= rsiOversold : rsiValue >= rsiOverbought

isRsiValidProjection(bool bullish, float rsiValue) =>
    bullish ? rsiValue <= rsiProjThreshold : rsiValue >= rsiProjThreshold

filterByRsi(array<PatternMatch> matches, array<int> barArr, array<float> rsiArr, bool isProjection) =>
    int i = array.size(matches) - 1
    while i >= 0
        PatternMatch m = array.get(matches, i)
        float rsiVal = getRsiAtBar(barArr, rsiArr, m.dIndex)
        bool valid = isProjection ? isRsiValidProjection(m.bullish, rsiVal) : isRsiValidConfirmed(m.bullish, rsiVal)
        if not valid
            array.remove(matches, i)
        i -= 1

buildConfirmLabel(string baseLabelText, bool bullish, float rsiValue, bool projectionLike, float nearD, float farD) =>
    string texts = baseLabelText
    if showRsiOnLabel and useRsiFilter and not na(rsiValue)
        string rsiStr = str.tostring(rsiValue, "#.#")
        bool valid = projectionLike ? isRsiValidProjection(bullish, rsiValue) : isRsiValidConfirmed(bullish, rsiValue)
        string status = valid ? "✓" : "✗"
        texts := texts + "\n[RSI:" + rsiStr + " " + status + "]"
    if showOBOnLabel
        bool obOK = przOverlapsOB(bullish, nearD, farD)
        texts := texts + "\n[OB:" + (obOK ? "✓" : "✗") + "]"
    if showFVGOnLabel
        bool fvgOK = przOverlapsFVG(bullish, nearD, farD)
        texts := texts + "\n[FVG:" + (fvgOK ? "✓" : "✗") + "]"
    texts

buildOrderBlocks(array<int> barArr, array<float> openArr, array<float> highArr, array<float> lowArr, array<float> closeArr) =>
    array.clear(g_bullOBs)
    array.clear(g_bearOBs)
    int count = array.size(highArr)
    if count > obSwingLen * 2
        int os = 0
        float topY = na
        int topX = 0
        bool topCrossed = true
        float btmY = na
        int btmX = 0
        bool btmCrossed = true
        for bar = obSwingLen to count - 1
            int checkIdx = bar - obSwingLen
            float upper = array.get(highArr, checkIdx + 1)
            float lower = array.get(lowArr, checkIdx + 1)
            if checkIdx + 2 <= bar
                for j = checkIdx + 2 to bar
                    upper := math.max(upper, array.get(highArr, j))
                    lower := math.min(lower, array.get(lowArr, j))
            int prevOs = os
            if array.get(highArr, checkIdx) > upper
                os := 0
            else if array.get(lowArr, checkIdx) < lower
                os := 1
            if os == 0 and prevOs != 0
                topY := array.get(highArr, checkIdx)
                topX := checkIdx
                topCrossed := false
            if os == 1 and prevOs != 1
                btmY := array.get(lowArr, checkIdx)
                btmX := checkIdx
                btmCrossed := false
            float barClose = array.get(closeArr, bar)
            float barOpen = array.get(openArr, bar)
            float barHigh = array.get(highArr, bar)
            float barLow = array.get(lowArr, bar)
            float barMax = obUseBody ? math.max(barClose, barOpen) : barHigh
            float barMin = obUseBody ? math.min(barClose, barOpen) : barLow
            if not na(topY) and not topCrossed and barClose > topY
                topCrossed := true
                float minLow = barMin
                float corrHigh = barMax
                int searchEnd = bar - topX - 1
                if searchEnd >= 1
                    for i = 1 to searchEnd
                        int idx = bar - i
                        if idx >= 0
                            float cMin = obUseBody ? math.min(array.get(closeArr, idx), array.get(openArr, idx)) : array.get(lowArr, idx)
                            float cMax = obUseBody ? math.max(array.get(closeArr, idx), array.get(openArr, idx)) : array.get(highArr, idx)
                            if cMin < minLow
                                minLow := cMin
                                corrHigh := cMax
                array.unshift(g_bullOBs, OBZone.new(corrHigh, minLow, array.get(barArr, bar)))
            if not na(btmY) and not btmCrossed and barClose < btmY
                btmCrossed := true
                float maxHigh = barMax
                float corrLow = barMin
                int searchEnd = bar - btmX - 1
                if searchEnd >= 1
                    for i = 1 to searchEnd
                        int idx = bar - i
                        if idx >= 0
                            float cMax = obUseBody ? math.max(array.get(closeArr, idx), array.get(openArr, idx)) : array.get(highArr, idx)
                            float cMin = obUseBody ? math.min(array.get(closeArr, idx), array.get(openArr, idx)) : array.get(lowArr, idx)
                            if cMax > maxHigh
                                maxHigh := cMax
                                corrLow := cMin
                array.unshift(g_bearOBs, OBZone.new(maxHigh, corrLow, array.get(barArr, bar)))
            int bullSize = array.size(g_bullOBs)
            if bullSize > 0
                for i = bullSize - 1 to 0
                    OBZone z = array.get(g_bullOBs, i)
                    if barMin < z.btm
                        array.remove(g_bullOBs, i)
            int bearSize = array.size(g_bearOBs)
            if bearSize > 0
                for i = bearSize - 1 to 0
                    OBZone z = array.get(g_bearOBs, i)
                    if barMax > z.top
                        array.remove(g_bearOBs, i)
        while array.size(g_bullOBs) > obMaxCount
            array.pop(g_bullOBs)
        while array.size(g_bearOBs) > obMaxCount
            array.pop(g_bearOBs)

buildFVGZones(array<int> barArr, array<float> openArr, array<float> highArr, array<float> lowArr, array<float> closeArr) =>
    array.clear(g_bullFVGs)
    array.clear(g_bearFVGs)
    int count = array.size(highArr)
    if count >= 3
        float avgRange = 0.0
        int avgCount = math.min(20, count)
        for i = 0 to avgCount - 1
            avgRange += array.get(highArr, count - 1 - i) - array.get(lowArr, count - 1 - i)
        avgRange := avgRange / avgCount
        float threshold = fvgAutoThreshold ? avgRange * 0.1 : 0.0
        for bar = 2 to count - 1
            float c0o = array.get(openArr, bar)
            float c0c = array.get(closeArr, bar)
            float c0h = array.get(highArr, bar)
            float c0l = array.get(lowArr, bar)
            float c1o = array.get(openArr, bar - 1)
            float c1c = array.get(closeArr, bar - 1)
            float c2h = array.get(highArr, bar - 2)
            float c2l = array.get(lowArr, bar - 2)
            float c2o = array.get(openArr, bar - 2)
            float c2c = array.get(closeArr, bar - 2)
            bool c0bull = c0c > c0o
            bool c1bull = c1c > c1o
            bool c2bull = c2c > c2o
            if c0l > c2h and c1c > c2h and c0bull and c1bull and c2bull
                float fvgSize = c0l - c2h
                if fvgSize >= threshold
                    array.unshift(g_bullFVGs, FVGZone.new(c0l, c2h, array.get(barArr, bar - 1), bar, false, true))
            bool c0bear = c0c < c0o
            bool c1bear = c1c < c1o
            bool c2bear = c2c < c2o
            if c0h < c2l and c1c < c2l and c0bear and c1bear and c2bear
                float fvgSize = c2l - c0h
                if fvgSize >= threshold
                    array.unshift(g_bearFVGs, FVGZone.new(c2l, c0h, array.get(barArr, bar - 1), bar, false, false))
            int bullFVGSize = array.size(g_bullFVGs)
            if bullFVGSize > 0
                for i = 0 to bullFVGSize - 1
                    FVGZone fz = array.get(g_bullFVGs, i)
                    if not fz.mitigated and bar > fz.createArrIdx
                        if c0l <= fz.top
                            fz.mitigated := true
            int bearFVGSize = array.size(g_bearFVGs)
            if bearFVGSize > 0
                for i = 0 to bearFVGSize - 1
                    FVGZone fz = array.get(g_bearFVGs, i)
                    if not fz.mitigated and bar > fz.createArrIdx
                        if c0h >= fz.btm
                            fz.mitigated := true
            while array.size(g_bullFVGs) > fvgMaxCount * 3
                array.pop(g_bullFVGs)
            while array.size(g_bearFVGs) > fvgMaxCount * 3
                array.pop(g_bearFVGs)
        while array.size(g_bullFVGs) > fvgMaxCount
            array.pop(g_bullFVGs)
        while array.size(g_bearFVGs) > fvgMaxCount
            array.pop(g_bearFVGs)

filterByOB(array<PatternMatch> matches) =>
    int i = array.size(matches) - 1
    while i >= 0
        PatternMatch m = array.get(matches, i)
        if not przOverlapsOB(m.bullish, m.nearD, m.farD)
            array.remove(matches, i)
        i -= 1

filterByFVG(array<PatternMatch> matches) =>
    int i = array.size(matches) - 1
    while i >= 0
        PatternMatch m = array.get(matches, i)
        if not przOverlapsFVG(m.bullish, m.nearD, m.farD)
            array.remove(matches, i)
        i -= 1

drawPatternMatch(PatternDesc pat, PatternMatch match, int state, array<int> barArr, array<float> rsiArr) =>
    bool projectionLike = state == STATE_PROJECTION or state == STATE_ONE_AHEAD
    color mainClr = projectionLike ? projectionLegColor(mainColorFor(pat, match.bullish, true)) : mainColorFor(pat, match.bullish, false)
    color ratioClr = projectionLike ? projectionRatioColor(clrRatio) : clrRatio
    int widthMain = projectionLike ? projectionWidth : mainWidth
    mainStyle = projectionLike ? line.style_dashed : line.style_solid
    float rsiAtD = getRsiAtBar(barArr, rsiArr, match.dIndex)
    if pat.is4p
        pushLine(makeLine(match.aIndex, match.a, match.bIndex, match.b, mainClr, mainStyle, widthMain))
        pushLine(makeLine(match.bIndex, match.b, match.cIndex, match.c, mainClr, mainStyle, widthMain))
        pushLine(makeLine(match.cIndex, match.c, match.dIndex, projectionLike ? match.nearD : match.d, mainClr, mainStyle, widthMain))
        if showDescriptions and not (projectionLike and showSoftProjections)
            color labelClr = pointTextColor(pat, match.bullish, projectionLike)
            drawPointLabel(match.aIndex, match.a, "A " + (projectionLike ? "" : pat.name), labelClr)
            drawPointLabel(match.bIndex, match.b, "B", labelClr)
            drawPointLabel(match.cIndex, match.c, "C", labelClr)
            string dLabelBase = projectionLike ? "D " + pat.name : "D"
            string dLabelText = buildConfirmLabel(dLabelBase, match.bullish, rsiAtD, projectionLike, match.nearD, match.farD)
            color dLabelClr = projectionLike ? mainColorFor(pat, match.bullish, true) : labelClr
            drawPointLabel(match.dIndex, projectionLike ? match.nearD : match.d, dLabelText, dLabelClr)
    else
        pushLine(makeLine(match.xIndex, match.x, match.aIndex, match.a, mainClr, mainStyle, widthMain))
        pushLine(makeLine(match.aIndex, match.a, match.bIndex, match.b, mainClr, mainStyle, widthMain))
        pushLine(makeLine(match.bIndex, match.b, match.cIndex, match.c, mainClr, mainStyle, widthMain))
        pushLine(makeLine(match.cIndex, match.c, match.dIndex, projectionLike ? match.nearD : match.d, mainClr, mainStyle, widthMain))
        if showRatioLines
            pushLine(makeLine(match.xIndex, match.x, match.bIndex, match.b, ratioClr, line.style_dotted, ratioWidth))
            if not str.startswith(pat.name, "5-0")
                pushLine(makeLine(match.xIndex, match.x, match.dIndex, projectionLike ? match.nearD : match.d, ratioClr, line.style_dotted, ratioWidth))
            pushLine(makeLine(match.aIndex, match.a, match.cIndex, match.c, ratioClr, line.style_dotted, ratioWidth))
            pushLine(makeLine(match.bIndex, match.b, match.dIndex, projectionLike ? match.nearD : match.d, ratioClr, line.style_dotted, ratioWidth))
        if showDescriptions and not (projectionLike and showSoftProjections)
            color labelClr = pointTextColor(pat, match.bullish, projectionLike)
            drawPointLabel(match.xIndex, match.x, "X " + (projectionLike ? "" : pat.name), labelClr)
            drawPointLabel(match.aIndex, match.a, "A", labelClr)
            drawPointLabel(match.bIndex, match.b, "B", labelClr)
            drawPointLabel(match.cIndex, match.c, "C", labelClr)
            string dLabelBase = projectionLike ? "D " + pat.name : "D"
            string dLabelText = buildConfirmLabel(dLabelBase, match.bullish, rsiAtD, projectionLike, match.nearD, match.farD)
            color dLabelClr = projectionLike ? mainColorFor(pat, match.bullish, true) : labelClr
            drawPointLabel(match.dIndex, projectionLike ? match.nearD : match.d, dLabelText, dLabelClr)
    // RSI untuk PRZ: rsiAtD = RSI di titik D, rsiNow = RSI bar terakhir, rsiPrev = RSI 3 bar sebelumnya (untuk tren)
    int lastIdx = array.size(rsiArr) - 1
    float rsiNow = lastIdx >= 0 ? array.get(rsiArr, lastIdx) : 50.0
    float rsiPrev = lastIdx >= 3 ? array.get(rsiArr, lastIdx - 3) : na
    drawPrz(pat, match, projectionLike, rsiAtD, rsiPrev, rsiNow)

buildZigZag(array<float> openArr, array<float> highArr, array<float> lowArr, array<float> closeArr, array<float> peaks, array<float> troughs) =>
    array.clear(peaks)
    array.clear(troughs)
    int count = array.size(highArr)
    for _ = 0 to count - 1
        array.push(peaks, 0.0)
        array.push(troughs, 0.0)
    if count <= 1
        na
    bool zzLastDirection = false
    bool realtimeChange = false
    int lastIndex = 0
    int lastIndex2 = 0
    int contraIndex = 0
    float atr = 0.0
    int limit = count > 1 ? count - 1 - (zzRealtime ? 0 : 1) : 0
    if count > 1 and limit < 1
        limit := 1
    for bar = 1 to limit
        bool realtimeBar = bar == count - 1
        if not realtimeBar
            float tr = math.max(array.get(highArr, bar), array.get(closeArr, bar - 1)) - math.min(array.get(lowArr, bar), array.get(closeArr, bar - 1))
            atr += (tr - atr) * (2.0 / (1.0 + zzAtrPeriod))
            if realtimeChange and zzRealtime
                if zzLastDirection
                    array.set(peaks, lastIndex, array.get(highArr, lastIndex))
                else
                    array.set(troughs, lastIndex, array.get(lowArr, lastIndex))
                array.set(peaks, count - 1, 0.0)
                array.set(troughs, count - 1, 0.0)
                realtimeChange := false
            array.set(troughs, bar, 0.0)
            array.set(peaks, bar, 0.0)
        bool shouldntChange = bar - lastIndex < zzMinPeriod
        bool shallChange = bar - lastIndex > zzMaxPeriod
        bool mustChange = false
        bool shouldChange = false
        bool canChange = false
        if zzLastDirection
            mustChange := array.get(lowArr, bar) < array.get(lowArr, lastIndex2)
            shouldChange := array.get(peaks, lastIndex) - array.get(lowArr, bar) > atr * zzAtrMultiplier
            canChange := array.get(lowArr, bar) < array.get(lowArr, contraIndex)
        else
            mustChange := array.get(highArr, bar) > array.get(highArr, lastIndex2)
            shouldChange := array.get(highArr, bar) - array.get(troughs, lastIndex) > atr * zzAtrMultiplier
            canChange := array.get(highArr, bar) > array.get(highArr, contraIndex)
        bool changeNow = mustChange or (canChange and shouldChange and not shouldntChange)
        if realtimeBar and zzRealtime
            if zzLastDirection
                bool peakRealtimeUpdated = false
                if not realtimeChange and array.get(highArr, bar) > array.get(peaks, lastIndex)
                    array.set(peaks, lastIndex, 0.0)
                    array.set(peaks, bar, array.get(highArr, bar))
                    realtimeChange := true
                    peakRealtimeUpdated := true
                if not peakRealtimeUpdated and realtimeChange and array.get(highArr, bar) > array.get(peaks, bar)
                    array.set(peaks, bar, array.get(highArr, bar))
            else
                bool troughRealtimeUpdated = false
                if not realtimeChange and array.get(lowArr, bar) < array.get(troughs, lastIndex)
                    array.set(troughs, lastIndex, 0.0)
                    array.set(troughs, bar, array.get(lowArr, bar))
                    realtimeChange := true
                    troughRealtimeUpdated := true
                if not troughRealtimeUpdated and realtimeChange and array.get(lowArr, bar) < array.get(troughs, bar)
                    array.set(troughs, bar, array.get(lowArr, bar))
        else
            if canChange
                contraIndex := bar
            if zzLastDirection
                if array.get(highArr, bar) > array.get(peaks, lastIndex)
                    array.set(peaks, lastIndex, 0.0)
                    array.set(peaks, bar, array.get(highArr, bar))
                    if array.get(openArr, bar) > array.get(closeArr, bar)
                        shouldntChange := 0 < zzMinPeriod
                        shouldChange := array.get(peaks, bar) - array.get(lowArr, bar) > atr * zzAtrMultiplier
                        changeNow := mustChange or (canChange and shouldChange and not shouldntChange)
                        if changeNow
                            array.set(troughs, bar, array.get(lowArr, bar))
                            zzLastDirection := false
                            lastIndex2 := bar
                    else if changeNow
                        array.set(peaks, lastIndex, array.get(highArr, lastIndex))
                        array.set(troughs, bar, array.get(lowArr, bar))
                        lastIndex2 := bar
                    lastIndex := bar
                    contraIndex := bar
                else if changeNow
                    array.set(troughs, bar, array.get(lowArr, bar))
                    zzLastDirection := false
                    lastIndex2 := lastIndex
                    lastIndex := bar
                    contraIndex := bar
                else if shallChange
                    int startSkip = array.get(troughs, lastIndex) == 0.0 ? 0 : 1
                    if array.get(openArr, lastIndex) < array.get(closeArr, lastIndex) and startSkip == 0
                        startSkip += 1
                    int minIdx = lastIndex + startSkip
                    for probe = lastIndex + startSkip to bar
                        if array.get(lowArr, probe) <= array.get(lowArr, minIdx)
                            minIdx := probe
                    array.set(troughs, minIdx, array.get(lowArr, minIdx))
                    zzLastDirection := false
                    lastIndex2 := lastIndex
                    lastIndex := minIdx
                    contraIndex := minIdx
            else
                if array.get(lowArr, bar) < array.get(troughs, lastIndex)
                    array.set(troughs, lastIndex, 0.0)
                    array.set(troughs, bar, array.get(lowArr, bar))
                    if array.get(openArr, bar) < array.get(closeArr, bar)
                        shouldntChange := 0 < zzMinPeriod
                        shouldChange := array.get(highArr, bar) - array.get(troughs, bar) > atr * zzAtrMultiplier
                        changeNow := mustChange or (canChange and shouldChange and not shouldntChange)
                        if changeNow
                            array.set(peaks, bar, array.get(highArr, bar))
                            zzLastDirection := true
                            lastIndex2 := bar
                    else if changeNow
                        array.set(troughs, lastIndex, array.get(lowArr, lastIndex))
                        array.set(peaks, bar, array.get(highArr, bar))
                        lastIndex2 := bar
                    lastIndex := bar
                    contraIndex := bar
                else if changeNow
                    array.set(peaks, bar, array.get(highArr, bar))
                    zzLastDirection := true
                    lastIndex2 := lastIndex
                    lastIndex := bar
                    contraIndex := bar
                else if shallChange
                    int startSkip = array.get(peaks, lastIndex) == 0.0 ? 0 : 1
                    if array.get(openArr, lastIndex) > array.get(closeArr, lastIndex) and startSkip == 0
                        startSkip += 1
                    int maxIdx = lastIndex + startSkip
                    for probe = lastIndex + startSkip to bar
                        if array.get(highArr, probe) >= array.get(highArr, maxIdx)
                            maxIdx := probe
                    array.set(peaks, maxIdx, array.get(highArr, maxIdx))
                    zzLastDirection := true
                    lastIndex2 := lastIndex
                    lastIndex := maxIdx
                    contraIndex := maxIdx
            array.set(peaks, count - 1, 0.0)
            array.set(troughs, count - 1, 0.0)

buildEvents(array<int> barArr, array<float> openArr, array<float> closeArr, array<float> peaks, array<float> troughs, array<PivotEvent> events) =>
    array.clear(events)
    int count = array.size(barArr)
    if count > 0
        for i = 0 to count - 1
            float pk = array.get(peaks, i)
            float tr = array.get(troughs, i)
            if pk != 0.0 or tr != 0.0
                int absBar = array.get(barArr, i)
                if pk != 0.0 and tr != 0.0
                    bool bullBody = array.get(closeArr, i) >= array.get(openArr, i)
                    if bullBody
                        array.push(events, PivotEvent.new(absBar, tr, PIVOT_TROUGH))
                        array.push(events, PivotEvent.new(absBar, pk, PIVOT_PEAK))
                    else
                        array.push(events, PivotEvent.new(absBar, pk, PIVOT_PEAK))
                        array.push(events, PivotEvent.new(absBar, tr, PIVOT_TROUGH))
                else if tr != 0.0
                    array.push(events, PivotEvent.new(absBar, tr, PIVOT_TROUGH))
                else
                    array.push(events, PivotEvent.new(absBar, pk, PIVOT_PEAK))

findPatternCandidates(PatternDesc pat, int patternIndex, int startBarAbs, int currentBarAbs, int lastPeakAbs, int lastTroughAbs, array<PivotEvent> events, array<PatternMatch> matched, array<PatternMatch> undershot) =>
    array.clear(matched)
    array.clear(undershot)
    int eventCount = array.size(events)
    if eventCount >= 4
        bool ab2xaConstraint = constraintActive(pat.ab2xaMin, pat.ab2xaMax)
        bool bc2abConstraint = constraintActive(pat.bc2abMin, pat.bc2abMax)
        bool xc2xaConstraint = constraintActive(pat.xc2xaMin, pat.xc2xaMax)
        bool bc2xaConstraint = constraintActive(pat.bc2xaMin, pat.bc2xaMax)
        float ab2xaSlack = effectiveSlack(pat.ab2xaMin, pat.ab2xaMax)
        float bc2abSlack = effectiveSlack(pat.bc2abMin, pat.bc2abMax)
        float xc2xaSlack = effectiveSlack(pat.xc2xaMin, pat.xc2xaMax)
        float bc2xaSlack = effectiveSlack(pat.bc2xaMin, pat.bc2xaMax)
        int lastEventIndex = eventCount - 1
        for xi = 0 to eventCount - 4
            PivotEvent xEv = array.get(events, xi)
            if xEv.barIndex < startBarAbs
                continue
            bool startsInTrough = xEv.kind == PIVOT_TROUGH
            float X = xEv.price
            float extremeA = startsInTrough ? -BIG : BIG
            bool xBroken = false
            for ai = xi + 1 to eventCount - 3
                PivotEvent aEv = array.get(events, ai)
                if aEv.kind == xEv.kind
                    if (startsInTrough and aEv.price < X) or ((not startsInTrough) and aEv.price > X)
                        xBroken := true
                        break
                    continue
                if xBroken
                    break
                float A = aEv.price
                if (startsInTrough and A < extremeA) or ((not startsInTrough) and A > extremeA)
                    continue
                extremeA := A
                float XA = math.abs(A - X)
                if XA == 0.0
                    continue
                float extremeB = startsInTrough ? BIG : -BIG
                bool aBroken = false
                for bi = ai + 1 to eventCount - 2
                    PivotEvent bEv = array.get(events, bi)
                    if bEv.kind == aEv.kind
                        if (startsInTrough and bEv.price > A) or ((not startsInTrough) and bEv.price < A)
                            aBroken := true
                            break
                        continue
                    if aBroken
                        break
                    float B = bEv.price
                    if (startsInTrough and B > extremeB) or ((not startsInTrough) and B < extremeB)
                        continue
                    extremeB := B
                    float AB = math.abs(A - B)
                    if AB == 0.0
                        continue
                    float ab2xaRatio = AB / XA
                    if ab2xaConstraint and ab2xaRatio < pat.ab2xaMin - ab2xaSlack
                        continue
                    if ab2xaConstraint and ab2xaRatio > pat.ab2xaMax + ab2xaSlack
                        break
                    float extremeC = startsInTrough ? -BIG : BIG
                    bool bBroken = false
                    for ci = bi + 1 to lastEventIndex
                        PivotEvent cEv = array.get(events, ci)
                        if cEv.kind == bEv.kind
                            if (startsInTrough and cEv.price < B) or ((not startsInTrough) and cEv.price > B)
                                bBroken := true
                                break
                            continue
                        if bBroken
                            break
                        float C = cEv.price
                        if (startsInTrough and C < extremeC) or ((not startsInTrough) and C > extremeC)
                            continue
                        extremeC := C
                        float BC = math.abs(C - B)
                        float XC = math.abs(X - C)
                        if BC == 0.0 or XC == 0.0
                            continue
                        float bc2abRatio = BC / AB
                        float xc2xaRatio = XC / XA
                        float bc2xaRatio = BC / XA
                        if (bc2abConstraint and bc2abRatio < pat.bc2abMin - bc2abSlack) or (xc2xaConstraint and xc2xaRatio < pat.xc2xaMin - xc2xaSlack) or (bc2xaConstraint and bc2xaRatio < pat.bc2xaMin - bc2xaSlack)
                            continue
                        if (bc2abConstraint and bc2abRatio > pat.bc2abMax + bc2abSlack) or (xc2xaConstraint and xc2xaRatio > pat.xc2xaMax + xc2xaSlack) or (bc2xaConstraint and bc2xaRatio > pat.bc2xaMax + bc2xaSlack)
                            break
                        bool lastExtremeC = true
                        if ci < lastEventIndex
                            for futureC = ci + 1 to lastEventIndex
                                PivotEvent probeC = array.get(events, futureC)
                                if probeC.kind == cEv.kind and ((startsInTrough and probeC.price > C) or ((not startsInTrough) and probeC.price < C))
                                    lastExtremeC := false
                                    break
                        [nearD, farD] = harmonicWindow(pat, startsInTrough, X, A, B, C)
                        nearD := math.max(nearD, 0.0)
                        farD := math.max(farD, 0.0)
                        if nearD <= 0.0 and farD <= 0.0
                            continue
                        if (startsInTrough and farD > nearD) or ((not startsInTrough) and farD < nearD)
                            continue
                        float extremeD = startsInTrough ? BIG : -BIG
                        bool producedProjection = false
                        if ci < lastEventIndex
                            for di = ci + 1 to lastEventIndex
                                PivotEvent dEv = array.get(events, di)
                                if dEv.kind == cEv.kind
                                    if ((not startsInTrough) and dEv.price < C) or (startsInTrough and dEv.price > C)
                                        break
                                    continue
                                float D = dEv.price
                                if (startsInTrough and D > extremeD) or ((not startsInTrough) and D < extremeD)
                                    continue
                                extremeD := D
                                bool lastExtremeD = true
                                if di < lastEventIndex
                                    for futureD = di + 1 to lastEventIndex
                                        PivotEvent probeD = array.get(events, futureD)
                                        if probeD.kind == dEv.kind and (((not startsInTrough) and probeD.price > D) or (startsInTrough and probeD.price < D))
                                            lastExtremeD := false
                                            break
                                PatternMatch match = PatternMatch.new(startsInTrough, xEv.barIndex, aEv.barIndex, bEv.barIndex, cEv.barIndex, dEv.barIndex, X, A, B, C, D, nearD, farD, patternIndex)
                                if (startsInTrough and D > nearD) or ((not startsInTrough) and D < nearD)
                                    if lastExtremeC and lastExtremeD and matchAllowedUndershot(pat, match, currentBarAbs)
                                        array.push(undershot, match)
                                        producedProjection := true
                                        break
                                else if (startsInTrough and D < farD) or ((not startsInTrough) and D > farD)
                                    break
                                else
                                    if matchAllowedMatched(pat, match)
                                        array.push(matched, match)
                        bool oneAhead = startsInTrough ? (cEv.barIndex == lastPeakAbs and (na(lastTroughAbs) or lastTroughAbs <= lastPeakAbs)) : (cEv.barIndex == lastTroughAbs and (na(lastPeakAbs) or lastPeakAbs <= lastTroughAbs))
                        if not producedProjection and lastExtremeC and oneAhead
                            PatternMatch projection = PatternMatch.new(startsInTrough, xEv.barIndex, aEv.barIndex, bEv.barIndex, cEv.barIndex, currentBarAbs, X, A, B, C, nearD, nearD, farD, patternIndex)
                            if matchAllowedUndershot(pat, projection, currentBarAbs)
                                array.push(undershot, projection)

processPatternResults(PatternDesc pat, int patternIndex, array<PatternMatch> rawMatched, array<PatternMatch> rawUndershot, int lastPeakAbs, int lastTroughAbs, bool endsInTrough, array<PatternMatch> confirmedOut, array<PatternMatch> transientOut, array<PatternMatch> projectionsOut, array<PatternMatch> oneAheadOut) =>
    array<PatternMatch> acceptedPersistent = array.new<PatternMatch>()
    array<PatternMatch> acceptedTransient = array.new<PatternMatch>()
    sortMatchesByDIndex(rawMatched)
    int matchedCount = array.size(rawMatched)
    if matchedCount > 0
        for i = 0 to matchedCount - 1
            PatternMatch match = array.get(rawMatched, i)
            if not overlapsStored(match, acceptedPersistent, acceptedTransient, pat.is4p)
                bool activeSwing = (endsInTrough and match.bullish and match.dIndex == lastTroughAbs) or ((not endsInTrough) and (not match.bullish) and match.dIndex == lastPeakAbs)
                if activeSwing
                    array.push(acceptedTransient, match)
                    array.push(transientOut, match)
                else
                    array.push(acceptedPersistent, match)
                    array.push(confirmedOut, match)
    sortMatchesByNearD(rawUndershot)
    array<PatternMatch> bearishAcceptedProj = array.new<PatternMatch>()
    array<PatternMatch> bullishAcceptedProj = array.new<PatternMatch>()
    int underCount = array.size(rawUndershot)
    if underCount > 0
        for i = 0 to underCount - 1
            PatternMatch match = array.get(rawUndershot, i)
            if not match.bullish and not overlapsStored(match, acceptedPersistent, acceptedTransient, pat.is4p) and not projectionConflicts(match, bearishAcceptedProj, pat.is4p)
                bool oneAhead = match.cIndex == lastTroughAbs and (na(lastPeakAbs) or lastPeakAbs <= lastTroughAbs)
                array.push(bearishAcceptedProj, match)
                if oneAhead
                    array.push(oneAheadOut, match)
                else
                    array.push(projectionsOut, match)
        for rev = 0 to underCount - 1
            int i = underCount - 1 - rev
            PatternMatch match = array.get(rawUndershot, i)
            if match.bullish and not overlapsStored(match, acceptedPersistent, acceptedTransient, pat.is4p) and not projectionConflicts(match, bullishAcceptedProj, pat.is4p)
                bool oneAhead = match.cIndex == lastPeakAbs and (na(lastTroughAbs) or lastTroughAbs <= lastPeakAbs)
                array.push(bullishAcceptedProj, match)
                if oneAhead
                    array.push(oneAheadOut, match)
                else
                    array.push(projectionsOut, match)

trimMatches(array<PatternMatch> matches, int maxCount) =>
    sortMatchesByDDesc(matches)
    while array.size(matches) > maxCount
        array.pop(matches)

drawMatchArray(array<PatternMatch> matches, int state, array<int> barArr, array<float> rsiArr) =>
    int count = array.size(matches)
    if count > 0
        for i = 0 to count - 1
            PatternMatch match = array.get(matches, i)
            PatternDesc pat = array.get(patterns, match.patternIndex)
            drawPatternMatch(pat, match, state, barArr, rsiArr)

if barstate.islast
    initPatterns(patterns, patternNames)
    clearDrawings()
    int histCount = math.min(historyBars, bar_index + 1)
    array<int> barArr = array.new_int()
    array<int> timeArr = array.new_int()
    array<float> openArr = array.new_float()
    array<float> highArr = array.new_float()
    array<float> lowArr = array.new_float()
    array<float> closeArr = array.new_float()
    for i = 0 to histCount - 1
        int offset = histCount - 1 - i
        array.push(barArr, bar_index - offset)
        array.push(timeArr, time[offset])
        array.push(openArr, open[offset])
        array.push(highArr, high[offset])
        array.push(lowArr, low[offset])
        array.push(closeArr, close[offset])
    rebuildDrawAnchorMap(barArr, timeArr)
    array<float> peaks = array.new_float()
    array<float> troughs = array.new_float()
    buildZigZag(openArr, highArr, lowArr, closeArr, peaks, troughs)

    // ── RSI Calculation ──────────────────────────────────────────
    array<float> rsiArr = array.new_float(histCount, 50.0)
    if useRsiFilter or showRsiOnLabel
        float avgGain = 0.0
        float avgLoss = 0.0
        if histCount > 1
            for i = 1 to histCount - 1
                float chg = array.get(closeArr, i) - array.get(closeArr, i - 1)
                float gain = chg > 0 ? chg : 0.0
                float loss = chg < 0 ? -chg : 0.0
                if i <= rsiLength
                    avgGain += gain / rsiLength
                    avgLoss += loss / rsiLength
                else
                    avgGain := (avgGain * (rsiLength - 1) + gain) / rsiLength
                    avgLoss := (avgLoss * (rsiLength - 1) + loss) / rsiLength
                if i >= rsiLength
                    float rs = avgLoss == 0.0 ? 100.0 : avgGain / avgLoss
                    array.set(rsiArr, i, 100.0 - 100.0 / (1.0 + rs))

    // ── OB Detection ──────────────────────────────────────────
    if useOBFilter or showOBOnLabel
        buildOrderBlocks(barArr, openArr, highArr, lowArr, closeArr)
    // ── FVG Detection ─────────────────────────────────────────
    if useFVGFilter or showFVGOnLabel
        buildFVGZones(barArr, openArr, highArr, lowArr, closeArr)

    int lastPeakIdx = firstNonZeroFrom(array.size(peaks) - 1, peaks)
    int lastTroughIdx = firstNonZeroFrom(array.size(troughs) - 1, troughs)
    if not na(lastPeakIdx) and not na(lastTroughIdx)
        bool endsInTrough = lastTroughIdx > lastPeakIdx
        if lastTroughIdx == lastPeakIdx
            int zzDir = zigzagDirection(lastPeakIdx, peaks, troughs)
            if zzDir == -1
                endsInTrough := true
            else if zzDir == 1
                endsInTrough := false
        int lastPeakAbs = array.get(barArr, lastPeakIdx)
        int lastTroughAbs = array.get(barArr, lastTroughIdx)
        int currentBarAbs = array.get(barArr, array.size(barArr) - 1)
        int searchStartBar = math.max(array.get(barArr, 0), currentBarAbs - barsAnalyzed)
        array<PivotEvent> events = array.new<PivotEvent>()
        buildEvents(barArr, openArr, closeArr, peaks, troughs, events)
        array<PatternMatch> confirmedMatches = array.new<PatternMatch>()
        array<PatternMatch> transientMatches = array.new<PatternMatch>()
        array<PatternMatch> projectionMatches = array.new<PatternMatch>()
        array<PatternMatch> oneAheadMatches = array.new<PatternMatch>()
        int totalPatterns = array.size(patterns)
        if totalPatterns > 0
            for patternIndex = 0 to totalPatterns - 1
                PatternDesc pat = array.get(patterns, patternIndex)
                if shouldDisplayPattern(pat)
                    array<PatternMatch> rawMatched = array.new<PatternMatch>()
                    array<PatternMatch> rawUndershot = array.new<PatternMatch>()
                    findPatternCandidates(pat, patternIndex, searchStartBar, currentBarAbs, lastPeakAbs, lastTroughAbs, events, rawMatched, rawUndershot)
                    processPatternResults(pat, patternIndex, rawMatched, rawUndershot, lastPeakAbs, lastTroughAbs, endsInTrough, confirmedMatches, transientMatches, projectionMatches, oneAheadMatches)

        // ── RSI Post-Process Filter ──────────────────────────────
        if useRsiFilter and rsiStrictMode
            filterByRsi(confirmedMatches, barArr, rsiArr, false)
            filterByRsi(transientMatches, barArr, rsiArr, false)
        if useRsiFilter and rsiStrictMode and rsiFilterProjection
            filterByRsi(projectionMatches, barArr, rsiArr, true)
            filterByRsi(oneAheadMatches, barArr, rsiArr, true)

        // ── OB Post-Process Filter ────────────────────────────
        if useOBFilter and obStrictMode
            filterByOB(confirmedMatches)
            filterByOB(transientMatches)
            filterByOB(projectionMatches)
            filterByOB(oneAheadMatches)
        // ── FVG Post-Process Filter ───────────────────────────
        if useFVGFilter and fvgStrictMode
            filterByFVG(confirmedMatches)
            filterByFVG(transientMatches)
            filterByFVG(projectionMatches)
            filterByFVG(oneAheadMatches)

        if showOldPatterns
            trimMatches(confirmedMatches, maxConfirmedDraw)
            drawMatchArray(confirmedMatches, STATE_PERSISTENT, barArr, rsiArr)
        if showEmergingPatterns
            trimMatches(transientMatches, maxEmergingDraw)
            trimMatches(projectionMatches, maxEmergingDraw)
            drawMatchArray(transientMatches, STATE_TRANSIENT, barArr, rsiArr)
            drawMatchArray(projectionMatches, STATE_PROJECTION, barArr, rsiArr)
        if showOneAheadProjections
            trimMatches(oneAheadMatches, maxEmergingDraw)
            drawMatchArray(oneAheadMatches, STATE_ONE_AHEAD, barArr, rsiArr)

plot(na)
````
