# Harmonic Pattern Finder -  [XoRonX]

- url: https://www.tradingview.com/script/f22Ph8nG-Harmonic-Pattern-Finder-XoRonX/
- type: indicator
- pine_id: PUB;a71fad7fda774e2890b6f7086fc04942
- version: 1.0

## Description

[b]Overview[/b]
[b]Harmonic Pattern Finder[/b] is an institutional-grade, fully automatic pattern detection and projection tool designed to identify and scan harmonic patterns on your charts in real time. Ported to Pine Script v6, this advanced version introduces volatility-based swing detection, multi-criteria structural filtering, real-time projections, and built-in historical statistics.

The indicator uses a dynamic ATR-based ZigZag engine to establish structural swings. It then checks these swings against precise Fibonacci ratio rules to identify both completed and emerging harmonic structures, outlining the exact Potential Reversal Zone (PRZ) for potential trade setups.

---

[b]Supported Patterns[/b]
This indicator automatically scans for 7 classic harmonic pattern variations (supporting both Bullish and Bearish structures):
[list=1]
[*] Gartley
[*] Bat
[*] Butterfly
[*] Crab
[*] Deep Crab
[*] Cypher
[*] Shark
[/list]

Each pattern can be individually toggled on or off in the user settings.

---

[b]Key Features[/b]

[b]# 1. Volatility-Adaptive ZigZag Engine[/b]
Unlike static depth-based ZigZags, this script uses an Average True Range (ATR) filter. This allows swing points to dynamically adapt to shifting market volatility across different assets, timeframes, and market conditions.

[b]# 2. Potential Reversal Zone (PRZ) Boxes & Lines[/b]
For every detected pattern, the indicator plots a highlighted PRZ Box and a PRZ Line extending into the future. 
[list]
[*] PRZ Box: Clearly visualizes the range between the near and far target zones.
[*] PRZ Extensions: Extends to the right, letting you monitor price reactions upon entering the zone.
[/list] 

[b]# 3. Real-time Projections & Emerging Patterns[/b]
Never miss a setup. The indicator displays:
[list]
[*] Confirmed Patterns: Completed structures.
[*] Transient & Emerging Patterns: Patterns that are actively developing in real time.
[*] One-Ahead Projections: Projects the D-leg before it completes, allowing you to prepare for potential entries in advance.
[/list]

[b]# 4. Leg Balance & Time Filters[/b]
Eliminate noisy, deformed, or rushed structures. The script incorporates:
[list]
[*] Leg Balance Filter: Verifies that the time duration (number of bars) of each leg (XA, AB, BC, CD) is balanced and proportional.
[*] Time Filters: Eliminates patterns that complete "too early" or "too late" relative to the structural timeframe of the pattern.
[*] Purist PRZ: Filter patterns that don't have their Fibonacci ratios landing precisely in the PRZ.
[*]
[/list]

[b]# 5. Focus Details Mode[/b]
Enable the Focus Details setting to isolate a specific pattern and display detailed target Fibonacci ratios (AD2XA, CD2XC, CD2BC, etc.) and time targets ("early", "ideal", "late" boundaries) directly on the chart.

[b]# 6. Live Statistical Dashboard (Win-Rate Table)[/b]
A clean, table-based dashboard on the top-left calculates historical pattern outcomes based on the visible chart history:
[list]
[*] P. (Persistent / Completed)
[*] T. (Transient / Active)
[*] O. (Overshot / Failed)
[/list]
It calculates and displays the historical success probability for each pattern.

---

[b]How to Trade with This Indicator[/b]
[list=1]
[*] Identify the PRZ: Watch for the highlighted box and lines when a pattern is nearing completion.
[*] Wait for Price Action Confirmation: Do not blindly enter at the PRZ. Look for reversal candlestick patterns (e.g., pinbars, engulfing candles) or momentum divergence (RSI/MACD) inside the PRZ box.
[*] Stop Loss (SL): Positioned just beyond the "PRZ Stop" line (the far limit of the PRZ).
[*] Take Profit (TP): Typically targeted at key Fibonacci retracements of the AD leg (usually 38.2% and 61.8%).
[/list]

---
*Disclaimer: Harmonic patterns are structural guides and are most effective when combined with other indicators (RSI, volume, key support/resistance) and proper risk management. Past performance does not guarantee future results.*

## Source Code

````pine
//@version=6
indicator("HarmonicPatternFinderV3 -  [XoRonX]", "HPF [XoRonX]", overlay=true, format=format.price, max_bars_back=5000, max_lines_count=500, max_labels_count=500, max_boxes_count=250)

const int PAT_BAT = 0
const int PAT_BUTTERFLY = 1
const int PAT_SHARK = 2
const int PAT_CYPHER = 3
const int PAT_CRAB = 4
const int PAT_DEEPCRAB = 5
const int PAT_GARTLEY = 6
const int NUM_PATTERNS = 7

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

zigzagGroup = "ZigZag Settings"
zzAtrMultiplier = input.float(2.0, "ATR ZZ atr multiplier", minval=0.1, step=0.1, group=zigzagGroup)
zzAtrPeriod = input.int(50, "ATR ZZ atr period", minval=1, group=zigzagGroup)
zzMaxPeriod = input.int(10, "ATR ZZ max period", minval=1, group=zigzagGroup)
zzMinPeriod = input.int(3, "ATR ZZ min period", minval=0, group=zigzagGroup)
zzRealtime = input.bool(true, "ATR ZZ realtime", group=zigzagGroup)

engineGroup = "Indicator Settings"
barsAnalyzed = input.int(300, "Max. bars per pattern", minval=50, maxval=2000, group=engineGroup)
historyBars = input.int(1000, "Max. history bars to process", minval=200, maxval=5000, group=engineGroup)
maxSharedPoints = input.int(2, "Max. shared points per pattern", minval=0, maxval=4, group=engineGroup)
slackRange = input.float(0.05, "Max. slack for fib ratios (range)", minval=0.0, maxval=0.5, step=0.005, group=engineGroup)
slackSingular = input.float(0.10, "Max. slack for fib ratios (unary)", minval=0.0, maxval=0.5, step=0.005, group=engineGroup)
tooEarly = input.float(0.382, "Too early timezone", minval=0.0, step=0.001, group=engineGroup)
idealTime = input.float(1.0, "Ideal timezone", minval=0.0, step=0.001, group=engineGroup)
tooLate = input.float(1.618, "Too late timezone", minval=0.0, step=0.001, group=engineGroup)
puristPrz = input.bool(false, "Filter patterns without fib ratios in PRZ", group=engineGroup)
timeFilterEarly = input.bool(false, "Filter too early patterns", group=engineGroup)
timeFilterLate = input.bool(false, "Filter too late patterns", group=engineGroup)
legBarsFilter = input.bool(true, "Filter unbalanced candle counts", group=engineGroup)
minLegBars = input.int(3, "Min candles per XA/AB/BC/CD", minval=1, group=engineGroup)
minLegBarsRatio = input.float(0.25, "Min next/previous leg candle ratio", minval=0.0, step=0.05, group=engineGroup)
maxLegBarsRatio = input.float(3.0, "Max next/previous leg candle ratio", minval=0.0, step=0.1, group=engineGroup)
maxCdToXaBarsRatio = input.float(3.0, "Max CD candles / XA candles", minval=0.0, step=0.1, group=engineGroup)

displayGroup = "Display Settings"
clrBull = input.color(color.rgb(135, 206, 250), "Color for bullish patterns (5 points)", group=displayGroup)
clrBear = input.color(color.rgb(255, 182, 193), "Color for bearish patterns (5 points)", group=displayGroup)
clrBullProjection = input.color(color.rgb(46, 139, 87), "Color for proj. bullish patterns (5P)", group=displayGroup)
clrBearProjection = input.color(color.rgb(255, 140, 0), "Color for proj. bearish patterns (5P)", group=displayGroup)
clrFocus = input.color(color.white, "Color for focused patterns", group=displayGroup)
fillPatterns = input.bool(false, "Fill 5 point patterns found", group=displayGroup)
showDescriptions = input.bool(true, "Show pattern descriptions", group=displayGroup)
showEmergingPatterns = input.bool(true, "Show emerging patterns", group=displayGroup)
showOldPatterns = input.bool(true, "Show past patterns", group=displayGroup)
showOneAheadProjection = input.bool(false, "Show one-ahead projections", group=displayGroup)
showSoftProjections = input.bool(true, "Draw projections bodies in soft color", group=displayGroup)
showPatternNames = input.bool(true, "Show comment box", group=displayGroup)
showRatioLines = input.bool(true, "Show ratio lines", group=displayGroup)
showPrzLine = input.bool(true, "Show PRZ / PRS line", group=displayGroup)
showPrzBox = input.bool(true, "Show PRZ / PRS box", group=displayGroup)
maxConfirmedDraw = input.int(6, "Max confirmed patterns drawn", minval=1, maxval=20, group=displayGroup)
maxEmergingDraw = input.int(6, "Max emerging/projection patterns drawn", minval=1, maxval=20, group=displayGroup)
przExtendBars = input.int(40, "PRZ extend bars", minval=5, maxval=300, group=displayGroup)

strokeGroup = "Stroke"
lineWidth = input.int(2, "Pattern line width", minval=1, maxval=5, group=strokeGroup)
lineWidthProj = input.int(1, "Emerging patterns line width", minval=1, maxval=4, group=strokeGroup)
lineWidthFoc = input.int(3, "Focused patterns line width", minval=1, maxval=6, group=strokeGroup)
fontSizeInput = input.string("small", "Font size", options=["tiny", "small", "normal"], group=strokeGroup)
style5P = input.string("solid", "Style for 5 point patterns", options=["solid", "dash", "dot"], group=strokeGroup)
styleProj = input.string("dash", "Style for projections", options=["solid", "dash", "dot"], group=strokeGroup)
styleRatio = input.string("dot", "Style for ratio lines", options=["solid", "dash", "dot"], group=strokeGroup)
stylePRZ = input.string("dash", "Style for PRZ", options=["solid", "dash", "dot"], group=strokeGroup)

focusGroup = "Focus Details"
showFocusDetails = input.bool(false, "Show focused PRZ levels and timezones", group=focusGroup)
focusDrawSlot = input.int(1, "Focused drawn pattern slot, 1 = newest", minval=1, maxval=40, group=focusGroup)

patternGroup = "Patterns"
showBat = input.bool(true, "Display Bat", group=patternGroup)
showButterfly = input.bool(true, "Display Butterfly", group=patternGroup)
showShark = input.bool(true, "Display Shark", group=patternGroup)
showCypher = input.bool(true, "Display Cypher", group=patternGroup)
showCrab = input.bool(true, "Display Crab", group=patternGroup)
showDeepCrab = input.bool(true, "Display Deepcrab", group=patternGroup)
showGartley = input.bool(true, "Display Gartley", group=patternGroup)

labelSize = fontSizeInput == "normal" ? size.normal : fontSizeInput == "tiny" ? size.tiny : size.small

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
    int id

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

var array<PatternDesc> patterns = array.new<PatternDesc>()
var array<string> patternNames = array.new_string()
var array<line> drawnLines = array.new_line()
var array<label> drawnLabels = array.new_label()
var array<box> drawnBoxes = array.new_box()
var array<linefill> drawnFills = array.new_linefill()
var array<int> drawBarIndices = array.new_int()
var array<int> drawBarTimes = array.new_int()
var table commentTable = table.new(position.top_left, 1, 11, border_width=1, border_color=color.gray)

patternDef(float ab2xaMin, float ab2xaMax, float bc2abMin, float bc2abMax, float cd2bcMin, float cd2bcMax, float ad2xaMin, float ad2xaMax, float cd2xcMin, float cd2xcMax, float xc2xaMin, float xc2xaMax, float cd2abMin, float cd2abMax, string name, int id) =>
    PatternDesc.new(ab2xaMin, ab2xaMax, bc2abMin, bc2abMax, cd2bcMin, cd2bcMax, ad2xaMin, ad2xaMax, cd2xcMin, cd2xcMax, xc2xaMin, xc2xaMax, cd2abMin, cd2abMax, 0.0, 0.0, 0.0, 0.0, name, id)

addPattern(PatternDesc pat) =>
    array.push(patterns, pat)
    array.push(patternNames, pat.name)
    0

initPatterns() =>
    if array.size(patterns) == 0
        addPattern(patternDef(0.382, 0.5, 0.382, 0.886, 1.618, 2.618, 0.886, 0.886, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "Bat", PAT_BAT))
        addPattern(patternDef(0.786, 0.786, 0.382, 0.886, 1.618, 2.618, 1.272, 1.272, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "Butterfly", PAT_BUTTERFLY))
        addPattern(patternDef(0.0, 0.0, 1.13, 1.618, 1.618, 2.24, 0.0, 0.0, 0.886, 1.13, 0.0, 0.0, 0.0, 0.0, "Shark", PAT_SHARK))
        addPattern(patternDef(0.382, 0.618, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.786, 0.786, 1.13, 1.414, 0.0, 0.0, "Cypher", PAT_CYPHER))
        addPattern(patternDef(0.382, 0.618, 0.382, 0.886, 2.24, 3.618, 1.618, 1.618, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "Crab", PAT_CRAB))
        addPattern(patternDef(0.886, 0.886, 0.382, 0.886, 2.0, 3.618, 1.618, 1.618, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "Deep Crab", PAT_DEEPCRAB))
        addPattern(patternDef(0.618, 0.618, 0.382, 0.886, 1.272, 1.618, 0.786, 0.786, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "Gartley", PAT_GARTLEY))
    0

shouldDisplayPattern(PatternDesc pat) =>
    switch pat.id
        PAT_BAT => showBat
        PAT_BUTTERFLY => showButterfly
        PAT_SHARK => showShark
        PAT_CYPHER => showCypher
        PAT_CRAB => showCrab
        PAT_DEEPCRAB => showDeepCrab
        PAT_GARTLEY => showGartley
        => false

lineStyleFrom(string styleName) =>
    styleName == "dot" ? line.style_dotted : styleName == "dash" ? line.style_dashed : line.style_solid

constraintActive(float minV, float maxV) =>
    minV != 0.0 and maxV != 0.0

effectiveSlack(float minV, float maxV) =>
    minV == maxV ? slackSingular : slackRange

isLegBarsValid(int xIdx, int aIdx, int bIdx, int cIdx, int dIdx) =>
    if not legBarsFilter
        true
    else
        int xaBars = aIdx - xIdx
        int abBars = bIdx - aIdx
        int bcBars = cIdx - bIdx
        int cdBars = dIdx - cIdx
        bool ok = xaBars >= minLegBars and abBars >= minLegBars and bcBars >= minLegBars and cdBars >= minLegBars
        if ok and minLegBarsRatio > 0
            ok := abBars / xaBars >= minLegBarsRatio and bcBars / abBars >= minLegBarsRatio and cdBars / bcBars >= minLegBarsRatio
        if ok and maxLegBarsRatio > 0
            ok := abBars / xaBars <= maxLegBarsRatio and bcBars / abBars <= maxLegBarsRatio and cdBars / bcBars <= maxLegBarsRatio
        if ok and maxCdToXaBarsRatio > 0
            ok := cdBars / xaBars <= maxCdToXaBarsRatio
        ok

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

harmonicRatios(PatternDesc pat, bool startsInTrough, float X, float A, float B, float C) =>
    float XA = math.abs(A - X)
    float XC = math.abs(X - C)
    float AB = math.abs(A - B)
    float BC = math.abs(C - B)
    float cd2bc = na
    float ad2xa = na
    float cd2xc = na
    float cd2ab = na
    float cd2ad = na
    if constraintActive(pat.cd2bcMin, pat.cd2bcMax) and pat.cd2bcMin == pat.cd2bcMax
        cd2bc := startsInTrough ? C - pat.cd2bcMin * BC : C + pat.cd2bcMin * BC
    if constraintActive(pat.ad2xaMin, pat.ad2xaMax) and pat.ad2xaMin == pat.ad2xaMax
        ad2xa := startsInTrough ? A - pat.ad2xaMin * XA : A + pat.ad2xaMin * XA
    if constraintActive(pat.cd2xcMin, pat.cd2xcMax) and pat.cd2xcMin == pat.cd2xcMax
        cd2xc := startsInTrough ? C - pat.cd2xcMin * XC : C + pat.cd2xcMin * XC
    if constraintActive(pat.cd2abMin, pat.cd2abMax) and pat.cd2abMin == pat.cd2abMax
        cd2ab := startsInTrough ? C - pat.cd2abMin * AB : C + pat.cd2abMin * AB
    if constraintActive(pat.cd2adMin, pat.cd2adMax) and pat.cd2adMin == pat.cd2adMax and pat.cd2adMin != 1.0
        cd2ad := math.abs((C - pat.cd2adMin * A) / (pat.cd2adMin - 1.0))
    [cd2bc, ad2xa, cd2xc, cd2ab, cd2ad]

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

patternTimeliness(int xIdx, int aIdx, int bIdx, int cIdx, int dIdx) =>
    int baseBars = bIdx - xIdx
    int fixBar = bIdx
    dIdx < fixBar + int(math.floor(tooEarly * baseBars)) ? TIMELY_TOO_EARLY : dIdx < fixBar + int(math.ceil(tooLate * baseBars)) ? TIMELY_OK : TIMELY_TOO_LATE

matchAllowedMatched(PatternDesc pat, PatternMatch match) =>
    bool ok = true
    if puristPrz
        ok := isPuristPRZ(pat, match.bullish, match.x, match.a, match.b, match.c, match.nearD, match.farD)
    if ok and (timeFilterEarly or timeFilterLate)
        int timeState = patternTimeliness(match.xIndex, match.aIndex, match.bIndex, match.cIndex, match.dIndex)
        ok := not (timeFilterEarly and timeState == TIMELY_TOO_EARLY)
        ok := ok and not (timeFilterLate and timeState == TIMELY_TOO_LATE)
    ok

matchAllowedUndershot(PatternDesc pat, PatternMatch match, int currentBarAbs) =>
    bool ok = true
    if puristPrz
        ok := isPuristPRZ(pat, match.bullish, match.x, match.a, match.b, match.c, match.nearD, match.farD)
    if ok and timeFilterLate
        ok := patternTimeliness(match.xIndex, match.aIndex, match.bIndex, match.cIndex, currentBarAbs) != TIMELY_TOO_LATE
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
    0

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
    0

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
    0

countCoreMatches(PatternMatch a, PatternMatch b) =>
    int numMatches = 0
    if a.xIndex == b.xIndex
        numMatches += 1
    if a.aIndex == b.aIndex
        numMatches += 1
    if a.bIndex == b.bIndex
        numMatches += 1
    if a.cIndex == b.cIndex
        numMatches += 1
    numMatches

overlapsStored(PatternMatch match, array<PatternMatch> persistent, array<PatternMatch> transient) =>
    bool hit = false
    int needSame = 4
    int szPersist = array.size(persistent)
    if szPersist > 0
        for i = 0 to szPersist - 1
            PatternMatch stored = array.get(persistent, i)
            int numMatches = countCoreMatches(match, stored)
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
                int numMatches = countCoreMatches(match, stored)
                if numMatches >= needSame
                    hit := true
                    break
                if stored.dIndex == match.dIndex
                    numMatches += 1
                if numMatches > maxSharedPoints
                    hit := true
                    break
    hit

projectionConflicts(PatternMatch match, array<PatternMatch> accepted) =>
    bool hit = false
    int sz = array.size(accepted)
    if sz > 0
        for i = 0 to sz - 1
            PatternMatch stored = array.get(accepted, i)
            int numMatches = countCoreMatches(match, stored)
            if numMatches > maxSharedPoints
                hit := true
                break
    hit

clearDrawings() =>
    while array.size(drawnLines) > 0
        line.delete(array.pop(drawnLines))
    while array.size(drawnLabels) > 0
        label.delete(array.pop(drawnLabels))
    while array.size(drawnBoxes) > 0
        box.delete(array.pop(drawnBoxes))
    while array.size(drawnFills) > 0
        linefill.delete(array.pop(drawnFills))
    0

pushLine(line id) =>
    array.push(drawnLines, id)
    id

pushLabel(label id) =>
    array.push(drawnLabels, id)
    id

pushBox(box id) =>
    array.push(drawnBoxes, id)
    id

pushFill(linefill id) =>
    array.push(drawnFills, id)
    id

rebuildDrawAnchorMap(array<int> barArr, array<int> timeArr) =>
    array.clear(drawBarIndices)
    array.clear(drawBarTimes)
    int count = array.size(barArr)
    if count > 0
        for i = 0 to count - 1
            array.push(drawBarIndices, array.get(barArr, i))
            array.push(drawBarTimes, array.get(timeArr, i))
    0

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

mainColorFor(bool bullish, bool projectionLike) =>
    projectionLike ? (bullish ? clrBullProjection : clrBearProjection) : (bullish ? clrBull : clrBear)

makeLine(int x1, float y1, int x2, float y2, color lineColor, string styleName, int width) =>
    line.new(barTimeFromIndex(x1), y1, barTimeFromIndex(x2), y2, xloc=xloc.bar_time, extend=extend.none, color=lineColor, style=lineStyleFrom(styleName), width=width, force_overlay=true)

makeLabel(int x, float y, string labelText, color textColor) =>
    label.new(barTimeFromIndex(x), y, labelText, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_none, textcolor=textColor, size=labelSize, color=color.new(color.black, 100), force_overlay=true)

makeBox(int x1, float top, int x2, float bottom, color borderColor, color bgColor) =>
    box.new(left=barTimeFromIndex(x1), top=top, right=barTimeFromIndex(x2), bottom=bottom, xloc=xloc.bar_time, bgcolor=bgColor, border_color=borderColor, force_overlay=true)

drawPrzLevel(int dIndex, float level, string texts, color clr) =>
    if not na(level) and level > 0
        pushLine(makeLine(dIndex - 1, level, dIndex + przExtendBars, level, clr, stylePRZ, 1))
        pushLabel(makeLabel(dIndex + przExtendBars, level, texts + " " + str.tostring(level, format.mintick), clr))
    0

drawVerticalTimeLine(int barAbs, float y1, float y2, string txt, color clr) =>
    pushLine(line.new(barTimeFromIndex(barAbs), y1, barTimeFromIndex(barAbs), y2, xloc=xloc.bar_time, color=color.new(clr, 30), style=line.style_dotted, width=1, force_overlay=true))
    pushLabel(label.new(barTimeFromIndex(barAbs), y2, txt, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_none, textcolor=color.new(clr, 0), size=size.tiny, color=color.new(color.black, 100), force_overlay=true))
    0

drawFocusDetails(PatternDesc pat, PatternMatch match) =>
    color focClr = clrFocus
    [lvlCd2bc, lvlAd2xa, lvlCd2xc, lvlCd2ab, lvlCd2ad] = harmonicRatios(pat, match.bullish, match.x, match.a, match.b, match.c)
    drawPrzLevel(match.dIndex, match.farD, pat.name + " PRZ stop", focClr)
    drawPrzLevel(match.dIndex, lvlAd2xa, "AD2XA", focClr)
    drawPrzLevel(match.dIndex, lvlCd2xc, "CD2XC", focClr)
    drawPrzLevel(match.dIndex, lvlCd2bc, "CD2BC", focClr)
    drawPrzLevel(match.dIndex, lvlCd2ab, "CD2AB", focClr)
    drawPrzLevel(match.dIndex, lvlCd2ad, "CD2AD", focClr)
    float yMin = math.min(math.min(math.min(match.x, match.a), math.min(match.b, match.c)), math.min(match.nearD, match.farD))
    float yMax = math.max(math.max(math.max(match.x, match.a), math.max(match.b, match.c)), math.max(match.nearD, match.farD))
    float pad = math.max((yMax - yMin) * 0.15, syminfo.mintick * 10)
    int baseBars = math.max(1, match.bIndex - match.xIndex)
    int earlyBar = match.bIndex + int(math.floor(tooEarly * baseBars))
    int idealBar = match.bIndex + int(math.round(idealTime * baseBars))
    int lateBar = match.bIndex + int(math.ceil(tooLate * baseBars))
    drawVerticalTimeLine(earlyBar, yMin - pad, yMax + pad, "early", focClr)
    drawVerticalTimeLine(idealBar, yMin - pad, yMax + pad, "ideal", focClr)
    drawVerticalTimeLine(lateBar, yMin - pad, yMax + pad, "late", focClr)
    0

drawPatternMatch(PatternDesc pat, PatternMatch match, int state, int slot) =>
    bool projectionLike = state == STATE_PROJECTION or state == STATE_ONE_AHEAD
    color rawMain = mainColorFor(match.bullish, projectionLike)
    color mainClr = projectionLike ? projectionLegColor(rawMain) : rawMain
    color ratioClr = projectionLike ? projectionRatioColor(color.silver) : color.silver
    int widthMain = projectionLike ? lineWidthProj : lineWidth
    string mainStyle = projectionLike ? styleProj : style5P
    float dPrice = projectionLike ? match.nearD : match.d
    bool focused = showFocusDetails and focusDrawSlot == slot
    if focused
        mainClr := clrFocus
        ratioClr := clrFocus
        widthMain := lineWidthFoc
    line lXA = pushLine(makeLine(match.xIndex, match.x, match.aIndex, match.a, mainClr, mainStyle, widthMain))
    line lAB = pushLine(makeLine(match.aIndex, match.a, match.bIndex, match.b, mainClr, mainStyle, widthMain))
    line lBC = pushLine(makeLine(match.bIndex, match.b, match.cIndex, match.c, mainClr, mainStyle, widthMain))
    line lCD = pushLine(makeLine(match.cIndex, match.c, match.dIndex, dPrice, mainClr, mainStyle, widthMain))
    line lXB = na
    line lBD = na
    if showRatioLines or fillPatterns
        lXB := pushLine(makeLine(match.xIndex, match.x, match.bIndex, match.b, fillPatterns and not showRatioLines ? color.new(ratioClr, 100) : ratioClr, styleRatio, 1))
        pushLine(makeLine(match.xIndex, match.x, match.dIndex, dPrice, ratioClr, styleRatio, 1))
        pushLine(makeLine(match.aIndex, match.a, match.cIndex, match.c, ratioClr, styleRatio, 1))
        lBD := pushLine(makeLine(match.bIndex, match.b, match.dIndex, dPrice, fillPatterns and not showRatioLines ? color.new(ratioClr, 100) : ratioClr, styleRatio, 1))
    if fillPatterns and not projectionLike and not na(lXB) and not na(lBD)
        pushFill(linefill.new(lXA, lXB, color.new(mainClr, 88)))
        pushFill(linefill.new(lBC, lBD, color.new(mainClr, 88)))
    if showDescriptions and not (projectionLike and showSoftProjections)
        pushLabel(makeLabel(match.xIndex, match.x, "X " + (projectionLike ? "" : pat.name), mainClr))
        pushLabel(makeLabel(match.aIndex, match.a, "A", mainClr))
        pushLabel(makeLabel(match.bIndex, match.b, "B", mainClr))
        pushLabel(makeLabel(match.cIndex, match.c, "C", mainClr))
        string dLabel = projectionLike ? "D " + pat.name : "D"
        pushLabel(makeLabel(match.dIndex, dPrice, dLabel, projectionLike ? rawMain : mainClr))
    if showPrzLine
        float przPrice = projectionLike ? match.nearD : match.farD
        pushLine(makeLine(match.dIndex - 1, przPrice, match.dIndex + przExtendBars, przPrice, focused ? clrFocus : rawMain, stylePRZ, focused ? 2 : 1))
    if showPrzBox and match.nearD != match.farD
        float top = math.max(match.nearD, match.farD)
        float bottom = math.min(match.nearD, match.farD)
        pushBox(makeBox(match.dIndex - 1, top, match.dIndex + przExtendBars, bottom, color.new(focused ? clrFocus : rawMain, 55), color.new(rawMain, 88)))
    if focused
        PatternMatch focusMatch = PatternMatch.new(match.bullish, match.xIndex, match.aIndex, match.bIndex, match.cIndex, match.dIndex, match.x, match.a, match.b, match.c, dPrice, match.nearD, match.farD, match.patternIndex)
        drawFocusDetails(pat, focusMatch)
    0

buildZigZag(array<float> openArr, array<float> highArr, array<float> lowArr, array<float> closeArr, array<float> peaks, array<float> troughs) =>
    array.clear(peaks)
    array.clear(troughs)
    int count = array.size(highArr)
    for _ = 0 to count - 1
        array.push(peaks, 0.0)
        array.push(troughs, 0.0)
    if count > 1
        bool zzLastDirection = false
        bool realtimeChange = false
        int lastIndex = 0
        int lastIndex2 = 0
        int contraIndex = 0
        float atr = 0.0
        array.set(troughs, 0, array.get(lowArr, 0))
        int limit = count - 1 - (zzRealtime ? 0 : 1)
        if limit < 1
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
                        if minIdx <= bar
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
                        if maxIdx <= bar
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
    0

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
    0

findPatternCandidates(PatternDesc pat, int patternIndex, int startBarAbs, int currentBarAbs, int lastPeakAbs, int lastTroughAbs, array<PivotEvent> events, array<PatternMatch> matched, array<PatternMatch> undershot, array<PatternMatch> overshot) =>
    array.clear(matched)
    array.clear(undershot)
    array.clear(overshot)
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
                                if not isLegBarsValid(match.xIndex, match.aIndex, match.bIndex, match.cIndex, match.dIndex)
                                    continue
                                if (startsInTrough and D > nearD) or ((not startsInTrough) and D < nearD)
                                    if lastExtremeC and lastExtremeD and matchAllowedUndershot(pat, match, currentBarAbs)
                                        array.push(undershot, match)
                                        producedProjection := true
                                        break
                                else if (startsInTrough and D < farD) or ((not startsInTrough) and D > farD)
                                    if matchAllowedMatched(pat, match)
                                        array.push(overshot, match)
                                    break
                                else
                                    if matchAllowedMatched(pat, match)
                                        array.push(matched, match)
                        bool oneAhead = startsInTrough ? (cEv.barIndex == lastPeakAbs and (na(lastTroughAbs) or lastTroughAbs <= lastPeakAbs)) : (cEv.barIndex == lastTroughAbs and (na(lastPeakAbs) or lastPeakAbs <= lastTroughAbs))
                        if not producedProjection and lastExtremeC and oneAhead
                            PatternMatch projection = PatternMatch.new(startsInTrough, xEv.barIndex, aEv.barIndex, bEv.barIndex, cEv.barIndex, currentBarAbs, X, A, B, C, nearD, nearD, farD, patternIndex)
                            if isLegBarsValid(projection.xIndex, projection.aIndex, projection.bIndex, projection.cIndex, projection.dIndex) and matchAllowedUndershot(pat, projection, currentBarAbs)
                                array.push(undershot, projection)
    0

processPatternResults(PatternDesc pat, array<PatternMatch> rawMatched, array<PatternMatch> rawUndershot, array<PatternMatch> rawOvershot, int lastPeakAbs, int lastTroughAbs, bool endsInTrough, array<PatternMatch> confirmedOut, array<PatternMatch> transientOut, array<PatternMatch> projectionsOut, array<PatternMatch> oneAheadOut, array<PatternMatch> overshotOut) =>
    array<PatternMatch> acceptedPersistent = array.new<PatternMatch>()
    array<PatternMatch> acceptedTransient = array.new<PatternMatch>()
    sortMatchesByDIndex(rawMatched)
    int matchedCount = array.size(rawMatched)
    if matchedCount > 0
        for i = 0 to matchedCount - 1
            PatternMatch match = array.get(rawMatched, i)
            if not overlapsStored(match, acceptedPersistent, acceptedTransient)
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
            if not match.bullish and not overlapsStored(match, acceptedPersistent, acceptedTransient) and not projectionConflicts(match, bearishAcceptedProj)
                bool oneAhead = match.cIndex == lastTroughAbs and (na(lastPeakAbs) or lastPeakAbs <= lastTroughAbs)
                array.push(bearishAcceptedProj, match)
                if oneAhead
                    array.push(oneAheadOut, match)
                else
                    array.push(projectionsOut, match)
        for rev = 0 to underCount - 1
            int i = underCount - 1 - rev
            PatternMatch match = array.get(rawUndershot, i)
            if match.bullish and not overlapsStored(match, acceptedPersistent, acceptedTransient) and not projectionConflicts(match, bullishAcceptedProj)
                bool oneAhead = match.cIndex == lastPeakAbs and (na(lastTroughAbs) or lastTroughAbs <= lastPeakAbs)
                array.push(bullishAcceptedProj, match)
                if oneAhead
                    array.push(oneAheadOut, match)
                else
                    array.push(projectionsOut, match)
    sortMatchesByDIndex(rawOvershot)
    array<PatternMatch> acceptedOvershot = array.new<PatternMatch>()
    int overCount = array.size(rawOvershot)
    if overCount > 0
        for i = 0 to overCount - 1
            PatternMatch match = array.get(rawOvershot, i)
            if not overlapsStored(match, acceptedPersistent, acceptedTransient) and not projectionConflicts(match, acceptedOvershot)
                array.push(acceptedOvershot, match)
                array.push(overshotOut, match)
    0

trimMatches(array<PatternMatch> matches, int maxCount) =>
    sortMatchesByDDesc(matches)
    while array.size(matches) > maxCount
        array.pop(matches)
    0

drawMatchArray(array<PatternMatch> matches, int state, int startSlot) =>
    int slot = startSlot
    int count = array.size(matches)
    if count > 0
        for i = 0 to count - 1
            PatternMatch match = array.get(matches, i)
            PatternDesc pat = array.get(patterns, match.patternIndex)
            slot += 1
            drawPatternMatch(pat, match, state, slot)
    slot

countPatternMatches(array<PatternMatch> matches, int patternIndex) =>
    int count = 0
    int sz = array.size(matches)
    if sz > 0
        for i = 0 to sz - 1
            PatternMatch match = array.get(matches, i)
            if match.patternIndex == patternIndex
                count += 1
    count

probText(int patternIndex, array<PatternMatch> confirmed, array<PatternMatch> transient, array<PatternMatch> overshot) =>
    int wins = countPatternMatches(confirmed, patternIndex) + countPatternMatches(transient, patternIndex)
    int fails = countPatternMatches(overshot, patternIndex)
    int total = wins + fails
    total > 0 ? str.tostring(100.0 * wins / total, "#.##") : "0.00"

commentLine(string prefix, PatternMatch match, array<PatternMatch> confirmed, array<PatternMatch> transient, array<PatternMatch> overshot) =>
    PatternDesc pat = array.get(patterns, match.patternIndex)
    string dir = match.bullish ? "Bull. " : "Bear. "
    string dt = str.format_time(barTimeFromIndex(match.dIndex), "yyyy-MM-dd HH:mm", syminfo.timezone)
    prefix + dir + pat.name + " @ " + dt + " Prob. " + probText(match.patternIndex, confirmed, transient, overshot)

drawCommentBox(array<PatternMatch> confirmed, array<PatternMatch> transient, array<PatternMatch> overshot) =>
    for r = 0 to 10
        table.cell(commentTable, 0, r, "", text_color=color.white, bgcolor=color.new(color.black, 100), text_size=size.tiny)
    if showPatternNames
        table.cell(commentTable, 0, 0, "HarmonicPatternFinderV3 TV", text_color=color.white, bgcolor=color.new(color.black, 5), text_size=size.tiny)
        int row = 1
        int cCount = math.min(array.size(confirmed), 4)
        if cCount > 0
            for i = 0 to cCount - 1
                PatternMatch match = array.get(confirmed, i)
                color txt = match.bullish ? clrBull : clrBear
                table.cell(commentTable, 0, row, commentLine("P. ", match, confirmed, transient, overshot), text_color=txt, bgcolor=color.new(color.black, 10), text_size=size.tiny)
                row += 1
        int tCount = math.min(array.size(transient), 3)
        if tCount > 0
            for i = 0 to tCount - 1
                PatternMatch match = array.get(transient, i)
                color txt = match.bullish ? clrBull : clrBear
                table.cell(commentTable, 0, row, commentLine("T. ", match, confirmed, transient, overshot), text_color=txt, bgcolor=color.new(color.black, 10), text_size=size.tiny)
                row += 1
        int oCount = math.min(array.size(overshot), 2)
        if oCount > 0
            for i = 0 to oCount - 1
                PatternMatch match = array.get(overshot, i)
                color txt = match.bullish ? color.new(clrBull, 15) : color.new(clrBear, 15)
                table.cell(commentTable, 0, row, commentLine("O. ", match, confirmed, transient, overshot), text_color=txt, bgcolor=color.new(color.black, 10), text_size=size.tiny)
                row += 1
    0

if barstate.islast
    initPatterns()
    clearDrawings()
    int slotCounter = 0
    int histCount = math.min(historyBars, bar_index + 1)
    array<int> barArr = array.new_int()
    array<int> timeArr = array.new_int()
    array<float> openArr = array.new_float()
    array<float> highArr = array.new_float()
    array<float> lowArr = array.new_float()
    array<float> closeArr = array.new_float()
    if histCount > 0
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
    int lastPeakIdx = firstNonZeroFrom(array.size(peaks) - 1, peaks)
    int lastTroughIdx = firstNonZeroFrom(array.size(troughs) - 1, troughs)
    array<PatternMatch> confirmedMatches = array.new<PatternMatch>()
    array<PatternMatch> transientMatches = array.new<PatternMatch>()
    array<PatternMatch> projectionMatches = array.new<PatternMatch>()
    array<PatternMatch> oneAheadMatches = array.new<PatternMatch>()
    array<PatternMatch> overshotMatches = array.new<PatternMatch>()
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
        int totalPatterns = array.size(patterns)
        if totalPatterns > 0
            for patternIndex = 0 to totalPatterns - 1
                PatternDesc pat = array.get(patterns, patternIndex)
                if shouldDisplayPattern(pat)
                    array<PatternMatch> rawMatched = array.new<PatternMatch>()
                    array<PatternMatch> rawUndershot = array.new<PatternMatch>()
                    array<PatternMatch> rawOvershot = array.new<PatternMatch>()
                    findPatternCandidates(pat, patternIndex, searchStartBar, currentBarAbs, lastPeakAbs, lastTroughAbs, events, rawMatched, rawUndershot, rawOvershot)
                    processPatternResults(pat, rawMatched, rawUndershot, rawOvershot, lastPeakAbs, lastTroughAbs, endsInTrough, confirmedMatches, transientMatches, projectionMatches, oneAheadMatches, overshotMatches)
    sortMatchesByDDesc(confirmedMatches)
    sortMatchesByDDesc(transientMatches)
    sortMatchesByDDesc(projectionMatches)
    sortMatchesByDDesc(oneAheadMatches)
    sortMatchesByDDesc(overshotMatches)
    if showOldPatterns
        trimMatches(confirmedMatches, maxConfirmedDraw)
        slotCounter := drawMatchArray(confirmedMatches, STATE_PERSISTENT, slotCounter)
    if showEmergingPatterns
        trimMatches(transientMatches, maxEmergingDraw)
        trimMatches(projectionMatches, maxEmergingDraw)
        slotCounter := drawMatchArray(transientMatches, STATE_TRANSIENT, slotCounter)
        slotCounter := drawMatchArray(projectionMatches, STATE_PROJECTION, slotCounter)
    if showOneAheadProjection
        trimMatches(oneAheadMatches, maxEmergingDraw)
        slotCounter := drawMatchArray(oneAheadMatches, STATE_ONE_AHEAD, slotCounter)
    drawCommentBox(confirmedMatches, transientMatches, overshotMatches)

plot(na)
````
