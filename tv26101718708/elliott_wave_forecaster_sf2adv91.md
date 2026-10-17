# Elliott Wave Forecaster  

- url: https://www.tradingview.com/script/Sf2Adv91-Elliott-Wave-Forecaster/
- type: indicator
- pine_id: PUB;8bbdb023bc3244fdb1626dde0e9c9017
- version: 2.0

## Description

Elliott Wave Forecaster — Indicator Overview
An educational Elliott Wave tool for TradingView that automatically detects, scores, and projects wave structures across multiple degrees. This post explains what the indicator observes and how to read its output. It is not trading advice.

1. Purpose
Elliott Wave analysis is subjective — two analysts can label the same chart differently. This indicator aims to reduce that subjectivity by:

Automatically detecting swing pivots at multiple degrees

Scoring impulse and ABC correction candidates against Fibonacci guidelines

Projecting the most likely next wave structure

Tracking whether past projections actually hit their targets

Everything is rule-based, so labels and forecasts are reproducible rather than discretionary.

2. What the Indicator Detects
Impulse Patterns (1-2-3-4-5)
Wave 2 does not retrace more than 100% of Wave 1

Wave 3 exceeds Wave 1's extreme

Wave 4 does not overlap Wave 1 (unless diagonal mode is enabled)

Wave 5 exceeds Wave 3

Wave 3 is not the shortest of Waves 1, 3, 5

ABC Corrections
Wave B stays within Wave A's range

Wave C exceeds Wave A's extreme

Ratios scored against Fibonacci guidelines

Each candidate is scored — a higher score means the wave ratios are closer to textbook Fibonacci relationships. Only patterns above your configured Minimum Score are drawn.

Multi-Degree Nesting
Three pivot lengths run in parallel (Minor, Primary, Cycle). This lets you see how the current count sits inside a higher-degree structure — similar to how an analyst would zoom out.

3. How to Read the Chart
Wave Labels
Numbers (0-5) — parent impulse count

Letters (A-B-C) — parent correction count

Roman numerals (i-v) — sub-waves of the current impulse

Lowercase (a-b-c) — sub-waves of a correction

Colors reflect direction and type:

Green = bullish impulse

Red = bearish impulse

Orange = correction

Forecast Boxes
Dashed boxes on the right of the chart show where the next waves are projected to land, based on your Fibonacci inputs. These update as the count evolves.

Invalidation Line (magenta)
Marks the price level that would void the current count. This is derived from the wave structure itself — for a completed impulse, it's typically Wave 4's extreme.

Signal Markers
When a completed pattern meets your R:R and stop-distance filters, the indicator plots a triangle (L for long, S for short). Whether it fades or follows the pattern is set by Signal Mode.

Interpretation Label
A plain-English summary drawn on the chart (bottom-right by default) covering:

Pattern quality tier

Freshness

Direction and pattern type

Completion state

Channel and invalidation status

Signal state

Forecast bias

The Table
A compact readout of the current state: pattern type, direction, wave completion, score, age, freshness, channel status, invalidation status, signal mode, degrees, wave ratios, and walk-forward hit rates.

4. Key Concepts for Interpretation
Pattern Score
Ranges roughly from 1 to 12+. Higher scores mean the wave ratios are closer to Fibonacci guidelines. A score just above the minimum is a weaker count; scores of 7+ suggest ratios are well-aligned.

Freshness
Patterns age. The Freshness filter hides counts whose terminal pivot is too old relative to the average wave length. This helps avoid acting on stale structures that price has already moved past.

Invalidation
If price closes through the invalidation level, the count is dropped. This is by design — Elliott counts are conditional, and one that has been violated should not linger on the chart.

In-Channel Filter
For impulses, a 2–4 channel is drawn. If price leaves the channel, the forecast is suppressed unless you disable the filter. This is an extra sanity check on structural validity.

Walk-Forward Stats
The indicator logs every projection it makes in real time, then checks after a configurable horizon whether price reached the projection within a tolerance. It reports hit rate vs baseline — baseline being whether price moved the same distance without Fibonacci targeting. This tells you whether the Fibonacci projections actually added predictive value historically on this instrument and timeframe. A hit rate below or at baseline suggests the projections are not statistically special.

5. Suggested Observation Workflow
A general way to approach the indicator — not a trading strategy:

Check freshness and invalidation status first. If the count is stale or invalidated, there is nothing actionable.

Read the interpretation label for a quick state summary.

Look at the degree table to see whether the current count agrees with the higher-degree structure. Alignment across degrees tends to be more informative than a single-degree count.

Compare wave ratios (W2/W1, W3/W1, W4/W3, W5/W1) to textbook values. A well-formed impulse will show ratios close to the configured Fibonacci numbers.

Review the walk-forward hit rates before placing too much weight on a forecast. On many instruments and timeframes, projection hit rates are close to baseline — the forecast exists, but its edge is not automatic.

Check the R:R and stop-distance filters. Signals only fire when both thresholds are met. If no signal appears despite a completed pattern, it's usually one of those filters blocking it.

Cross-check the invalidation line against your own risk framework. The indicator's invalidation is a structural level, not a stop-loss suggestion.

6. Settings Overview
Auto Detect — auto-tunes all timeframe-sensitive settings. Turn off for manual control.

Reliability Filters — score threshold, completeness requirement, channel filter, invalidation drop.

Freshness — how old a pattern can be before it's hidden.

Signal Emission — fade vs trend-follow, R:R, stop distance, timing (completion bar vs invalidation break).

Degree Nesting — pivot lengths for Primary and Cycle degrees.

Backtest / Validation — hit-rate stats and data-window export.

Fibonacci Targets — all projection ratios (W2, W3, W4, W5, B, C) and tolerance.

Visual Style — colors and transparency.

Label Size / Table / Interpretation Label — display options.

7. Scope and Limitations
Timeframe sensitivity. Below 15m, pivots become noisy and patterns fragment. The indicator displays a warning label on lower timeframes.

Degree ambiguity. Elliott Wave degree assignment is inherently fuzzy. The nesting feature offers one interpretation, not the only one.

Completed vs developing patterns. Completed patterns (Impulse W5, ABC C) are more reliable than partially formed ones. The indicator draws both, but the forecast branch behaves differently depending on completion state.

Forecast is not a prediction. Projections are Fibonacci-derived scenarios conditioned on the count remaining valid. They are invalidated frequently — that is the nature of the method.

Walk-forward stats are historical. Past hit rates do not guarantee future results, and they are instrument- and timeframe-specific.

8. Why an Interpretation Label Instead of More Rows
The table already carries the raw numbers. The interpretation label condenses them into a single sentence so the chart stays readable. You can move it to any of 9 positions, resize it, or hide it entirely.

9. Summary
The Elliott Wave Forecaster gtp3 is a structured, rule-based implementation of Elliott Wave analysis on TradingView. It:

Detects impulse and ABC patterns automatically

Scores them against Fibonacci guidelines

Projects the next wave structure

Filters by freshness, channel, and invalidation

Tracks historical projection accuracy

Summarizes the state in plain English

It is designed as an observation and study tool. It does not tell you what to trade — it tells you what wave structure the algorithm currently sees, how confident the ratios are, and where that structure would be invalidated. How you use that information is up to you.

This indicator is provided for educational and research purposes. It does not constitute financial advice. Elliott Wave analysis is inherently probabilistic and no configuration guarantees any outcome.

## Source Code

````pine

//@version=6
indicator("Elliott Wave Forecaster ", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_bars_back=500)

grpAuto = "Auto Detect"
autoMode = input.bool(true, "Auto-detect settings from timeframe", group=grpAuto, tooltip="When ON, all timeframe-sensitive inputs are computed from the current chart timeframe. Turn OFF to use the manual values below.")

grpMain = "Main (manual overrides)"
pivotLenMan = input.int(8, "Pivot Length", minval=2, maxval=50, group=grpMain)
maxSwings = input.int(30, "Max Stored Swings", minval=8, maxval=80, group=grpMain)
minWaveBarsMan = input.int(3, "Min Bars Per Wave", minval=1, maxval=50, group=grpMain)
allowDiagonal = input.bool(false, "Allow Wave 4 / Wave 1 Overlap (Diagonal)", group=grpMain)
showLabels = input.bool(true, "Show Wave Labels", group=grpMain)
showForecast = input.bool(true, "Show Forecast", group=grpMain)

grpForecast = "Forecast"
forecastStart = input.string("Auto", "Forecast Start", options = ["Auto", "A", "B", "C", "Wave 1", "Wave 2", "Wave 3", "Wave 4", "Wave 5"], group = grpForecast)

showInvalid = input.bool(true, "Show Invalidation Line", group=grpMain)
showChannel = input.bool(true, "Show 2-4 / A-C Channel", group=grpMain)
showTable = input.bool(true, "Show Wave Table", group=grpMain)
showDebug = input.bool(false, "Show Debug", group=grpMain)

grpRel = "Reliability Filters"
useRecency = input.bool(true, "Use Recency Bias (off = prefer complete patterns)", group=grpRel)
recencyWeight = input.float(0.5, "Recency Weight (if enabled)", minval=0.0, maxval=10.0, step=0.5, group=grpRel)
minScoreMan = input.float(4.0, "Minimum Pattern Score", minval=0.0, maxval=20.0, step=0.5, group=grpRel)
requireComplete = input.bool(true, "Only Draw Completed Patterns (Impulse W5 / ABC C)", group=grpRel)
requireInChannel = input.bool(true, "Only Forecast When Price In Channel", group=grpRel)
dropOnInvalidation = input.bool(true, "Drop Count When Price Breaks Invalidation (on close)", group=grpRel)

grpFresh = "Freshness"
enableFreshness = input.bool(true, "Ignore Old Patterns (freshness filter)", group=grpFresh)
freshMode = input.string("x avgWaveBars", "Freshness Mode", options=["x avgWaveBars", "Fixed bars"], group=grpFresh)
freshMultMan = input.float(3.0, "Max Pattern Age (x avgWaveBars)", minval=0.5, maxval=10.0, step=0.5, group=grpFresh)
freshFixedMan = input.int(60, "Max Pattern Age (bars)", minval=5, maxval=500, group=grpFresh)
freshFloorMan = input.int(20, "Minimum Freshness Floor (bars)", minval=5, maxval=200, group=grpFresh)

grpSig = "Signal Emission"
emitSignals = input.bool(true, "Emit Trade Signals", group=grpSig)
signalMode = input.string("Fade (mean-revert)", "Signal Mode", options=["Fade (mean-revert)", "Trend-follow"], group=grpSig)
sigRiskRewardMan = input.float(2.0, "Minimum R:R for Signal", minval=0.5, maxval=10.0, step=0.1, group=grpSig)
sigMaxStopATRMan = input.float(3.0, "Max Stop Distance (ATR)", minval=0.25, maxval=10.0, step=0.25, group=grpSig)
sigSemantics = input.string("Completion bar", "Signal Timing", options=["Completion bar", "Invalidation break", "Both"], group=grpSig)
requireFreshSignal = input.bool(true, "Signal only on the completion bar", group=grpSig)

grpDegree = "Degree Nesting (manual overrides)"
degreePivot2Man = input.int(21, "Primary Pivot Length", minval=10, maxval=100, group=grpDegree)
degreePivot3Man = input.int(55, "Cycle Pivot Length", minval=20, maxval=200, group=grpDegree)

grpBack = "Backtest / Validation"
showBacktest = input.bool(false, "Show Projection Hit-Rate Stats", group=grpBack)
btHorizonMultMan = input.float(2.0, "Hit Horizon (x avgWaveBars)", minval=0.5, maxval=5.0, step=0.5, group=grpBack)
btTolATRMan = input.float(0.5, "Hit Tolerance (ATR)", minval=0.1, maxval=3.0, step=0.1, group=grpBack)
btExport = input.bool(true, "Export Walk-Forward Hit/Miss to Data Window", group=grpBack)

grpSub = "Sub Waves"
showSubWaves = input.bool(true, "Show Sub Waves", group=grpSub)
subPivotLenMan = input.int(3, "Sub-Wave Pivot Length", minval=2, maxval=20, group=grpSub)
maxSubSwings = input.int(80, "Max Sub Swings", minval=20, maxval=200, group=grpSub)
minSubBarsMan = input.int(2, "Min Bars Per Sub Wave", minval=1, maxval=20, group=grpSub)
showSubForecast = input.bool(true, "Forecast Current Sub Wave", group=grpSub)

grpFib = "Fibonacci Targets"
w2Fib = input.float(0.618, "Wave 2 Retrace of W1", minval=0.236, maxval=0.999, step=0.001, group=grpFib)
w3Fib = input.float(1.618, "Wave 3 Extension of W1", minval=1.0, maxval=4.236, step=0.001, group=grpFib)
w4Fib = input.float(0.382, "Wave 4 Retrace of W3", minval=0.146, maxval=0.786, step=0.001, group=grpFib)
w5Fib = input.float(1.0, "Wave 5 vs Wave 1", minval=0.382, maxval=2.618, step=0.001, group=grpFib)
w5AltFib = input.float(0.618, "Wave 5 vs Waves 1-3", minval=0.236, maxval=1.618, step=0.001, group=grpFib)
bFib = input.float(0.618, "Wave B Retrace of A", minval=0.146, maxval=0.999, step=0.001, group=grpFib)
cFib = input.float(1.0, "Wave C vs Wave A", minval=0.618, maxval=2.618, step=0.001, group=grpFib)
fibTol = input.float(0.25, "Guideline Score Tolerance", minval=0.05, maxval=0.8, step=0.05, group=grpFib)

grpVis = "Visual Style"
bullCol = input.color(color.new(color.lime, 0), "Bull Impulse", group=grpVis)
bearCol = input.color(color.new(color.red, 0), "Bear Impulse", group=grpVis)
corrCol = input.color(color.new(color.orange, 0), "Correction", group=grpVis)
subBullCol = input.color(color.new(#80cbc4, 0), "Sub Bull", group=grpVis)
subBearCol = input.color(color.new(#ef9a9a, 0), "Sub Bear", group=grpVis)
fcstAlpha = input.int(35, "Forecast Transparency", minval=0, maxval=90, group=grpVis)
invCol = input.color(color.new(color.fuchsia, 0), "Invalidation", group=grpVis)
sigLongCol = input.color(color.new(#26a69a, 0), "Signal Long", group=grpVis)
sigShortCol = input.color(color.new(#ef5350, 0), "Signal Short", group=grpVis)

grpLblSize = "Label Size"
labelSize = input.string("small", "Wave / Forecast / Status Label Size", options=["tiny", "small", "normal", "large", "huge"], group=grpLblSize)

grpTbl = "Table"
tablePos = input.string("top_right", "Table Position", options=["top_left", "top_center", "top_right", "middle_left", "middle_center", "middle_right", "bottom_left", "bottom_center", "bottom_right"], group=grpTbl)
tableTextSize = input.string("small", "Table Text Size", options=["tiny", "small", "normal", "large", "huge"], group=grpTbl)

grpInterp = "Interpretation Label"
showInterpretation = input.bool(true, "Show Interpretation Label", group=grpInterp)
interpPos = input.string("bottom_right", "Interpretation Position", options=["top_left", "top_center", "top_right", "middle_left", "middle_center", "middle_right", "bottom_left", "bottom_center", "bottom_right"], group=grpInterp)
interpSize = input.string("normal", "Interpretation Text Size", options=["tiny", "small", "normal", "large", "huge"], group=grpInterp)

sizeOf(string s) =>
    s == "tiny" ? size.tiny : s == "small" ? size.small : s == "normal" ? size.normal : s == "large" ? size.large : size.huge

tablePosOf(string s) =>
    s == "top_left" ? position.top_left : s == "top_center" ? position.top_center : s == "top_right" ? position.top_right : s == "middle_left" ? position.middle_left : s == "middle_center" ? position.middle_center : s == "middle_right" ? position.middle_right : s == "bottom_left" ? position.bottom_left : s == "bottom_center" ? position.bottom_center : position.bottom_right

float tfSec = timeframe.in_seconds()
float tfMin = na(tfSec) ? 15.0 : tfSec / 60.0
int tfMs = na(tfSec) ? na : int(math.round(tfSec * 1000.0))

int autoPivotLen = tfMin <= 5 ? 14 : tfMin <= 20 ? 12 : tfMin <= 90 ? 10 : tfMin <= 300 ? 9 : 8
int pivotLen = autoMode ? autoPivotLen : pivotLenMan
int autoMinWaveBars = tfMin <= 5 ? 5 : tfMin <= 20 ? 4 : tfMin <= 90 ? 4 : tfMin <= 300 ? 3 : 3
int minWaveBars = autoMode ? autoMinWaveBars : minWaveBarsMan
int autoSubPivot = tfMin <= 5 ? 5 : tfMin <= 20 ? 4 : 3
int subPivotLen = autoMode ? autoSubPivot : subPivotLenMan
int autoMinSubBars = tfMin <= 20 ? 3 : 2
int minSubBars = autoMode ? autoMinSubBars : minSubBarsMan
int autoDeg2 = tfMin <= 5 ? 42 : tfMin <= 20 ? 36 : tfMin <= 90 ? 24 : tfMin <= 300 ? 21 : 21
int autoDeg3 = tfMin <= 5 ? 120 : tfMin <= 20 ? 96 : tfMin <= 90 ? 120 : tfMin <= 300 ? 89 : 89
int degreePivot2 = autoMode ? autoDeg2 : degreePivot2Man
int degreePivot3 = autoMode ? autoDeg3 : degreePivot3Man
float autoMinScore = tfMin <= 20 ? 4.0 : tfMin <= 90 ? 4.0 : tfMin <= 300 ? 4.5 : 4.5
float minScore = autoMode ? autoMinScore : minScoreMan
float autoFreshMult = tfMin <= 20 ? 3.0 : tfMin <= 90 ? 3.0 : tfMin <= 300 ? 3.5 : 4.0
float freshMult = autoMode ? autoFreshMult : freshMultMan
int autoFreshFloor = tfMin <= 20 ? 20 : tfMin <= 90 ? 20 : tfMin <= 300 ? 25 : 30
int freshFloor = autoMode ? autoFreshFloor : freshFloorMan
int freshFixed = freshFixedMan
float autoRR = tfMin <= 90 ? 2.0 : tfMin <= 300 ? 2.5 : 2.5
float autoStopATR = tfMin <= 90 ? 3.0 : tfMin <= 300 ? 3.5 : 4.0
float sigRiskReward = autoMode ? autoRR : sigRiskRewardMan
float sigMaxStopATR = autoMode ? autoStopATR : sigMaxStopATRMan
float autoBTHorizon = tfMin <= 90 ? 2.0 : tfMin <= 300 ? 2.5 : 2.5
float autoBTTol = tfMin <= 90 ? 0.5 : tfMin <= 300 ? 0.6 : 0.75
float btHorizonMult = autoMode ? autoBTHorizon : btHorizonMultMan
float btTolATR = autoMode ? autoBTTol : btTolATRMan

atr = ta.atr(14)
bool tfOk = not na(tfSec) and tfSec >= 900

drawLeg(int tStart, float pStart, int tEnd, float pEnd, color col, int w) =>
    if not na(tStart) and not na(tEnd) and not na(pStart) and not na(pEnd)
        line.new(tStart, pStart, tEnd, pEnd, xloc=xloc.bar_time, color=col, width=w)
    true

putWave(int tm, float px, string txt, bool upLbl, color col, string sz) =>
    if showLabels and not na(tm) and not na(px)
        label.new(tm, px, txt, xloc=xloc.bar_time, style=upLbl ? label.style_label_up : label.style_label_down, color=col, textcolor=color.white, size=sizeOf(sz))
    true

drawFcst(int tStart, float pStart, int tEnd, float pEnd, string txt, bool top, color col) =>
    if not na(tStart) and not na(tEnd) and not na(pStart) and not na(pEnd)
        color fc = color.new(col, fcstAlpha)
        line.new(tStart, pStart, tEnd, pEnd, xloc=xloc.bar_time, color=fc, width=2, style=line.style_dashed)
        box.new(tStart, math.max(pStart, pEnd), tEnd, math.min(pStart, pEnd), xloc=xloc.bar_time, bgcolor=fc, border_color=fc)
        label.new(tEnd, pEnd, "FCST " + txt, xloc=xloc.bar_time, style=top ? label.style_label_down : label.style_label_up, color=color.new(col, 20), textcolor=color.white, size=sizeOf(labelSize))
    true

var float[] swP = array.new_float()
var int[] swT = array.new_int()
var int[] swB = array.new_int()
var bool[] swHi = array.new_bool()
var float[] suP = array.new_float()
var int[] suT = array.new_int()
var int[] suB = array.new_int()
var bool[] suHi = array.new_bool()
var float[] d2P = array.new_float()
var int[] d2T = array.new_int()
var int[] d2B = array.new_int()
var bool[] d2Hi = array.new_bool()
var float[] d3P = array.new_float()
var int[] d3T = array.new_int()
var int[] d3B = array.new_int()
var bool[] d3Hi = array.new_bool()

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)
sph = ta.pivothigh(high, subPivotLen, subPivotLen)
spl = ta.pivotlow(low, subPivotLen, subPivotLen)
d2h = ta.pivothigh(high, degreePivot2, degreePivot2)
d2l = ta.pivotlow(low, degreePivot2, degreePivot2)
d3h = ta.pivothigh(high, degreePivot3, degreePivot3)
d3l = ta.pivotlow(low, degreePivot3, degreePivot3)

pushSwing(float[] ap, int[] at, int[] ab, bool[] ah, float px, int tm, int bi, bool isHigh, int cap) =>
    int n = array.size(ap)
    bool merged = false
    if n > 0 and array.get(ah, n - 1) == isHigh
        float lastP = array.get(ap, n - 1)
        bool moreExt = isHigh ? px >= lastP : px <= lastP
        if moreExt
            array.set(ap, n - 1, px)
            array.set(at, n - 1, tm)
            array.set(ab, n - 1, bi)
        merged := true
    if not merged
        array.push(ap, px)
        array.push(at, tm)
        array.push(ab, bi)
        array.push(ah, isHigh)
        if array.size(ap) > cap
            array.shift(ap)
            array.shift(at)
            array.shift(ab)
            array.shift(ah)
    true

bool newSwingThisBar = false
if barstate.isconfirmed and not na(ph)
    pushSwing(swP, swT, swB, swHi, ph, time[pivotLen], bar_index - pivotLen, true, maxSwings)
    newSwingThisBar := true
if barstate.isconfirmed and not na(pl)
    pushSwing(swP, swT, swB, swHi, pl, time[pivotLen], bar_index - pivotLen, false, maxSwings)
    newSwingThisBar := true
if barstate.isconfirmed and not na(sph)
    pushSwing(suP, suT, suB, suHi, sph, time[subPivotLen], bar_index - subPivotLen, true, maxSubSwings)
if barstate.isconfirmed and not na(spl)
    pushSwing(suP, suT, suB, suHi, spl, time[subPivotLen], bar_index - subPivotLen, false, maxSubSwings)
if barstate.isconfirmed and not na(d2h)
    pushSwing(d2P, d2T, d2B, d2Hi, d2h, time[degreePivot2], bar_index - degreePivot2, true, 30)
if barstate.isconfirmed and not na(d2l)
    pushSwing(d2P, d2T, d2B, d2Hi, d2l, time[degreePivot2], bar_index - degreePivot2, false, 30)
if barstate.isconfirmed and not na(d3h)
    pushSwing(d3P, d3T, d3B, d3Hi, d3h, time[degreePivot3], bar_index - degreePivot3, true, 20)
if barstate.isconfirmed and not na(d3l)
    pushSwing(d3P, d3T, d3B, d3Hi, d3l, time[degreePivot3], bar_index - degreePivot3, false, 20)

waveLen(float a, float b) =>
    math.abs(b - a)
retrOf(float startP, float endP, float retrP) =>
    waveLen(startP, retrP) / math.max(waveLen(startP, endP), syminfo.mintick)
fibScore(float actual, float target, float tol) =>
    float rel = math.abs(actual - target) / math.max(math.abs(target), 0.0001)
    math.max(0.0, 1.0 - rel / math.max(tol, 0.01))
barsBetween(int a, int b) =>
    math.abs(b - a)
resolveBarIdx(int[] arrT, int[] arrB, int tm) =>
    int out = na
    if not na(tm)
        int m = array.size(arrT)
        for i = 0 to m - 1
            if array.get(arrT, i) == tm
                out := array.get(arrB, i)
                break
    out

var float[] wp = array.new_float()
var int[] wt = array.new_int()
var int[] wb = array.new_int()
var bool[] wh = array.new_bool()

addWin(float px, int tm, int bi, bool isHigh) =>
    int n = array.size(wp)
    bool sameSide = n > 0 and array.get(wh, n - 1) == isHigh
    if sameSide
        float lastP = array.get(wp, n - 1)
        bool moreExt = isHigh ? px >= lastP : px <= lastP
        if moreExt
            array.set(wp, n - 1, px)
            array.set(wt, n - 1, tm)
            array.set(wb, n - 1, bi)
    else
        array.push(wp, px)
        array.push(wt, tm)
        array.push(wb, bi)
        array.push(wh, isHigh)
    true

buildWindow(int fromBar, int toBar, float fromP, float toP, int fromT, int toT, bool startHigh, bool includeSub) =>
    array.clear(wp)
    array.clear(wt)
    array.clear(wb)
    array.clear(wh)
    addWin(fromP, fromT, fromBar, startHigh)
    if includeSub
        int ns = array.size(suP)
        if ns > 0
            for i = 0 to ns - 1
                int bi = array.get(suB, i)
                if bi > fromBar and bi < toBar
                    addWin(array.get(suP, i), array.get(suT, i), bi, array.get(suHi, i))
    addWin(toP, toT, toBar, not startHigh)
    true

buildMainWindow() =>
    array.clear(wp)
    array.clear(wt)
    array.clear(wb)
    array.clear(wh)
    int n = array.size(swP)
    if n > 0
        for i = 0 to n - 1
            addWin(array.get(swP, i), array.get(swT, i), array.get(swB, i), array.get(swHi, i))
    true

buildWindowFrom(float[] ap, int[] at, int[] ab, bool[] ah) =>
    array.clear(wp)
    array.clear(wt)
    array.clear(wb)
    array.clear(wh)
    int n = array.size(ap)
    if n > 0
        for i = 0 to n - 1
            addWin(array.get(ap, i), array.get(at, i), array.get(ab, i), array.get(ah, i))
    true

scanWindow(bool wantMotive, bool preferBull, int minBars, bool requireFreshEnd) =>
    string typ = "None"
    bool bullOut = preferBull
    int doneOut = 0
    float scoreOut = -1.0
    float a0 = na
    float a1 = na
    float a2 = na
    float a3 = na
    float a4 = na
    float a5 = na
    int c0 = na
    int c1 = na
    int c2 = na
    int c3 = na
    int c4 = na
    int c5 = na
    int n = array.size(wp)
    int freshEndBar = bar_index - pivotLen
    if n >= 3
        int maxStart = n - 3
        for s = 0 to maxStart
            bool h0 = array.get(wh, s)
            float x0 = array.get(wp, s)
            float x1 = array.get(wp, s + 1)
            float x2 = array.get(wp, s + 2)
            int y0 = array.get(wt, s)
            int y1 = array.get(wt, s + 1)
            int y2 = array.get(wt, s + 2)
            int z0 = array.get(wb, s)
            int z1 = array.get(wb, s + 1)
            int z2 = array.get(wb, s + 2)
            bool altOk = array.get(wh, s + 1) != h0 and array.get(wh, s + 2) != array.get(wh, s + 1)
            bool spanOk = barsBetween(z0, z1) >= minBars and barsBetween(z1, z2) >= minBars
            if altOk and spanOk
                bool startLow = not h0
                bool bull = startLow
                float w1 = waveLen(x0, x1)
                float w2 = waveLen(x1, x2)
                if wantMotive
                    bool rule2 = bull ? x2 > x0 : x2 < x0
                    bool recOk = w1 > 0 and w2 <= w1 * 1.001
                    if rule2 and recOk and bull == preferBull
                        float sc = 1.0 + fibScore(retrOf(x0, x1, x2), w2Fib, fibTol)
                        int done = 2
                        float x3 = na
                        float x4 = na
                        float x5 = na
                        int y3 = na
                        int y4 = na
                        int y5 = na
                        int z3 = na
                        int z4 = na
                        int z5 = na
                        if s + 3 < n and array.get(wh, s + 3) == array.get(wh, s + 1) and barsBetween(z2, array.get(wb, s + 3)) >= minBars
                            float candidate3 = array.get(wp, s + 3)
                            bool beyond1 = bull ? candidate3 > x1 : candidate3 < x1
                            if beyond1
                                x3 := candidate3
                                y3 := array.get(wt, s + 3)
                                z3 := array.get(wb, s + 3)
                                float w3 = waveLen(x2, x3)
                                done := 3
                                sc += 1.4 + fibScore(w3 / math.max(w1, syminfo.mintick), w3Fib, fibTol)
                                if s + 4 < n and array.get(wh, s + 4) == array.get(wh, s + 2) and barsBetween(z3, array.get(wb, s + 4)) >= minBars
                                    float candidate4 = array.get(wp, s + 4)
                                    float w4 = waveLen(x3, candidate4)
                                    bool noOverlap = allowDiagonal or (bull ? candidate4 > x1 : candidate4 < x1)
                                    if w4 > 0 and w4 < w3 and noOverlap
                                        x4 := candidate4
                                        y4 := array.get(wt, s + 4)
                                        z4 := array.get(wb, s + 4)
                                        done := 4
                                        sc += 1.1 + fibScore(retrOf(x2, x3, x4), w4Fib, fibTol)
                                        if s + 5 < n and array.get(wh, s + 5) == array.get(wh, s + 1) and barsBetween(z4, array.get(wb, s + 5)) >= minBars
                                            float candidate5 = array.get(wp, s + 5)
                                            float w5 = waveLen(x4, candidate5)
                                            bool beyond3 = bull ? candidate5 > x3 : candidate5 < x3
                                            bool w3NotShortest = not (w3 < w1 and w3 < w5)
                                            if beyond3 and w5 > 0 and w3NotShortest
                                                x5 := candidate5
                                                y5 := array.get(wt, s + 5)
                                                z5 := array.get(wb, s + 5)
                                                done := 5
                                                float w13 = w1 + w3
                                                float w5AltActual = w5 / math.max(w13, syminfo.mintick)
                                                sc += 1.0 + math.max(fibScore(w5 / math.max(w1, syminfo.mintick), w5Fib, fibTol), fibScore(w5AltActual, w5AltFib, fibTol))
                        int endBar = done == 5 ? z5 : done == 4 ? z4 : done == 3 ? z3 : z2
                        int firstBar = array.get(wb, 0)
                        int lastBar = array.get(wb, n - 1)
                        float recency = (endBar - firstBar) / math.max(lastBar - firstBar, 1)
                        sc += 0.35 * done
                        if useRecency
                            sc += recencyWeight * recency
                        bool freshOk = not requireFreshEnd or endBar == freshEndBar
                        if sc > scoreOut and freshOk
                            scoreOut := sc
                            typ := "Impulse"
                            bullOut := bull
                            doneOut := done
                            a0 := x0
                            a1 := x1
                            a2 := x2
                            a3 := x3
                            a4 := x4
                            a5 := x5
                            c0 := y0
                            c1 := y1
                            c2 := y2
                            c3 := y3
                            c4 := y4
                            c5 := y5
                else
                    bool corrDown = not startLow
                    bool bRule = corrDown ? (x2 < x0 and x2 > x1) : (x2 > x0 and x2 < x1)
                    if w1 > 0 and bRule and w2 <= w1 * 1.25
                        float scA = 0.8 + fibScore(retrOf(x0, x1, x2), bFib, fibTol)
                        int doneA = 2
                        float x3a = na
                        int y3a = na
                        int z3a = na
                        if s + 3 < n and array.get(wh, s + 3) == array.get(wh, s + 1) and barsBetween(z2, array.get(wb, s + 3)) >= minBars
                            float candidateC = array.get(wp, s + 3)
                            bool cBeyondA = corrDown ? candidateC <= x1 : candidateC >= x1
                            if cBeyondA
                                x3a := candidateC
                                y3a := array.get(wt, s + 3)
                                z3a := array.get(wb, s + 3)
                                doneA := 3
                                scA += 1.1 + fibScore(waveLen(x2, x3a) / math.max(w1, syminfo.mintick), cFib, fibTol)
                        int endBarA = doneA == 3 ? z3a : z2
                        int firstBarA = array.get(wb, 0)
                        int lastBarA = array.get(wb, n - 1)
                        float recencyA = (endBarA - firstBarA) / math.max(lastBarA - firstBarA, 1)
                        scA += 0.35 * doneA
                        if useRecency
                            scA += recencyWeight * recencyA
                        bool freshOkA = not requireFreshEnd or endBarA == freshEndBar
                        if scA > scoreOut and freshOkA
                            scoreOut := scA
                            typ := "ABC"
                            bullOut := not corrDown
                            doneOut := doneA
                            a0 := x0
                            a1 := x1
                            a2 := x2
                            a3 := x3a
                            a4 := na
                            a5 := na
                            c0 := y0
                            c1 := y1
                            c2 := y2
                            c3 := y3a
                            c4 := na
                            c5 := na
    [typ, bullOut, doneOut, scoreOut, a0, a1, a2, a3, a4, a5, c0, c1, c2, c3, c4, c5]

drawSubCount(color col, bool motive, string typ, bool sBull, int sDone, float a0, float a1, float a2, float a3, float a4, float a5, int c0, int c1, int c2, int c3, int c4, int c5) =>
    if typ != "None" and not na(a0)
        if motive and typ == "Impulse"
            drawLeg(c0, a0, c1, a1, col, 1)
            drawLeg(c1, a1, c2, a2, col, 1)
            putWave(c1, a1, "i", sBull, col, "tiny")
            putWave(c2, a2, "ii", not sBull, col, "tiny")
            if sDone >= 3
                drawLeg(c2, a2, c3, a3, col, 1)
                putWave(c3, a3, "iii", sBull, col, "tiny")
            if sDone >= 4
                drawLeg(c3, a3, c4, a4, col, 1)
                putWave(c4, a4, "iv", not sBull, col, "tiny")
            if sDone >= 5
                drawLeg(c4, a4, c5, a5, col, 1)
                putWave(c5, a5, "v", sBull, col, "tiny")
        else if not motive and typ == "ABC"
            drawLeg(c0, a0, c1, a1, col, 1)
            drawLeg(c1, a1, c2, a2, col, 1)
            putWave(c1, a1, "a", not sBull, col, "tiny")
            putWave(c2, a2, "b", sBull, col, "tiny")
            if sDone >= 3
                drawLeg(c2, a2, c3, a3, col, 1)
                putWave(c3, a3, "c", not sBull, col, "tiny")
    sDone

runSub(int fromBar, int toBar, float fromP, float toP, int fromT, int toT, bool startHigh, bool wantMotive, bool preferBull, color col) =>
    string typ = "None"
    bool sBull = preferBull
    int sDone = 0
    float sScore = -1.0
    float a0 = float(na)
    float a1 = float(na)
    float a2 = float(na)
    float a3 = float(na)
    float a4 = float(na)
    float a5 = float(na)
    int c0 = int(na)
    int c1 = int(na)
    int c2 = int(na)
    int c3 = int(na)
    int c4 = int(na)
    int c5 = int(na)
    if not na(fromBar) and not na(toBar) and toBar > fromBar and not na(fromP) and not na(toP)
        buildWindow(fromBar, toBar, fromP, toP, fromT, toT, startHigh, true)
        [typ, sBull, sDone, sScore, a0, a1, a2, a3, a4, a5, c0, c1, c2, c3, c4, c5] = scanWindow(wantMotive, preferBull, minSubBars, false)
        drawSubCount(col, wantMotive, typ, sBull, sDone, a0, a1, a2, a3, a4, a5, c0, c1, c2, c3, c4, c5)
    [sDone, typ, sBull, a0, a1, a2]

var bool  sigLongBar   = false
var bool  sigShortBar  = false
var float sigEntryBar  = na
var float sigStopBar   = na
var float sigTargetBar = na
var string lastSigSide   = "-"
var float  lastSigEntry  = na
var float  lastSigStop   = na
var float  lastSigTarget = na
var int    lastSigBar    = na
var int    lastSigTime   = na
var string lastSigKind   = "-"
var string lastSigHit    = "open"

var string[] sigHistSide = array.new_string()
var float[]  sigHistEntry = array.new_float()
var float[]  sigHistStop = array.new_float()
var float[]  sigHistTarget = array.new_float()
var int[]    sigHistConfirmTime = array.new_int()
var int[]    sigHistWaveTime = array.new_int()
var string[] sigHistKind = array.new_string()
var int[]    sigHistHitBar = array.new_int()
var string[] sigHistHitKind = array.new_string()

var bool pendingLong = false
var bool pendingShort = false
var float pendingEntry = na
var float pendingStop = na
var float pendingTarget = na
var float pendingWatch = na
var int pendingWaveTime = na
var int pendingAge = 0
var int pendingMaxAge = 0

bool newLongSignal  = false
bool newShortSignal = false
string newSigKind = ""
int newWaveTime = na

pushSigHist(string side, float entry, float stop, float target, int confirmTime, int waveTime, string kind) =>
    array.push(sigHistSide, side)
    array.push(sigHistEntry, entry)
    array.push(sigHistStop, stop)
    array.push(sigHistTarget, target)
    array.push(sigHistConfirmTime, confirmTime)
    array.push(sigHistWaveTime, waveTime)
    array.push(sigHistKind, kind)
    array.push(sigHistHitBar, na)
    array.push(sigHistHitKind, "")
    if array.size(sigHistSide) > 25
        array.shift(sigHistSide)
        array.shift(sigHistEntry)
        array.shift(sigHistStop)
        array.shift(sigHistTarget)
        array.shift(sigHistConfirmTime)
        array.shift(sigHistWaveTime)
        array.shift(sigHistKind)
        array.shift(sigHistHitBar)
        array.shift(sigHistHitKind)
    true

if barstate.isconfirmed and newSwingThisBar and emitSignals
    buildMainWindow()
    bool wantFresh = requireFreshSignal
    [mType, mBull, mDone, mScore, m0, m1, m2, m3, m4, m5, mt0, mt1, mt2, mt3, mt4, mt5] = scanWindow(true, true, minWaveBars, wantFresh)
    [bType, bBull, bDone, bScore, bp0, bp1, bp2, bp3, bp4, bp5, bt0, bt1, bt2, bt3, bt4, bt5] = scanWindow(true, false, minWaveBars, wantFresh)
    [cType, cBull, cDone, cScore, cp0, cp1, cp2, cp3, cp4, cp5, ct0, ct1, ct2, ct3, ct4, ct5] = scanWindow(false, true, minWaveBars, wantFresh)
    float mCand = mScore
    float bCand = bScore
    float cCand = cScore
    string sType = "None"
    bool sBull = true
    int sDone = 0
    float sScore = -1.0
    float sp0 = na
    float sp1 = na
    float sp2 = na
    float sp3 = na
    float sp4 = na
    float sp5 = na
    int waveEndTime = time[pivotLen]
    if mCand >= bCand and mCand >= cCand and mCand >= 0
        sType := "Impulse"
        sBull := mBull
        sDone := mDone
        sScore := mCand
        sp0 := m0
        sp1 := m1
        sp2 := m2
        sp3 := m3
        sp4 := m4
        sp5 := m5
        waveEndTime := sDone == 5 ? mt5 : sDone == 3 ? mt3 : mt2
    if bCand > mCand and bCand >= cCand and bCand >= 0
        sType := "Impulse"
        sBull := bBull
        sDone := bDone
        sScore := bCand
        sp0 := bp0
        sp1 := bp1
        sp2 := bp2
        sp3 := bp3
        sp4 := bp4
        sp5 := bp5
        waveEndTime := sDone == 5 ? bt5 : sDone == 3 ? bt3 : bt2
    if cCand > mCand and cCand > bCand and cCand >= 0
        sType := "ABC"
        sBull := cBull
        sDone := cDone
        sScore := cCand
        sp0 := cp0
        sp1 := cp1
        sp2 := cp2
        sp3 := cp3
        sp4 := cp4
        sp5 := cp5
        waveEndTime := sDone == 3 ? ct3 : ct2
    bool sComplete = (sType == "Impulse" and sDone == 5) or (sType == "ABC" and sDone == 3)
    bool sPassScore = sScore >= minScore
    if sComplete and sPassScore
        float sInv = sType == "Impulse" ? sp4 : sp0
        bool fade = signalMode == "Fade (mean-revert)"
        float entry = na
        float stop = na
        float target = na
        bool isLong = false
        bool isShort = false
        if sType == "Impulse" and sBull
            if fade
                isShort := true
                entry := sp5
                stop := sp5 + atr * 0.5
                target := sp5 - waveLen(sp0, sp5) * 0.618
            else
                isLong := true
                entry := sp5
                stop := sp4 - atr * 0.5
                target := sp5 + waveLen(sp0, sp5) * 0.618
        else if sType == "Impulse" and not sBull
            if fade
                isLong := true
                entry := sp5
                stop := sp5 - atr * 0.5
                target := sp5 + waveLen(sp0, sp5) * 0.618
            else
                isShort := true
                entry := sp5
                stop := sp4 + atr * 0.5
                target := sp5 - waveLen(sp0, sp5) * 0.618
        else if sType == "ABC" and sBull
            if fade
                isShort := true
                entry := sp3
                stop := sp3 + atr * 0.5
                target := sp3 - waveLen(sp0, sp3) * 0.618
            else
                isLong := true
                entry := sp3
                stop := sp2 - atr * 0.5
                target := sp3 + waveLen(sp0, sp3) * 0.618
        else if sType == "ABC" and not sBull
            if fade
                isLong := true
                entry := sp3
                stop := sp3 - atr * 0.5
                target := sp3 + waveLen(sp0, sp3) * 0.618
            else
                isShort := true
                entry := sp3
                stop := sp2 + atr * 0.5
                target := sp3 - waveLen(sp0, sp3) * 0.618
        if isLong or isShort
            float stopDist = math.abs(entry - stop)
            float tgtDist = math.abs(target - entry)
            bool rrOk = stopDist > 0 and (tgtDist / stopDist) >= sigRiskReward
            bool stopOk = stopDist <= atr * sigMaxStopATR
            if not (rrOk and stopOk)
                isLong := false
                isShort := false
        bool fireNow = sigSemantics == "Completion bar" or sigSemantics == "Both"
        bool armPending = sigSemantics == "Invalidation break" or sigSemantics == "Both"
        if fireNow and (isLong or isShort)
            newLongSignal := isLong
            newShortSignal := isShort
            newSigKind := "completion"
            newWaveTime := waveEndTime
            sigEntryBar := entry
            sigStopBar := stop
            sigTargetBar := target
        if armPending and (isLong or isShort)
            pendingLong := isLong
            pendingShort := isShort
            pendingEntry := entry
            pendingStop := stop
            pendingTarget := target
            pendingWatch := sInv
            pendingWaveTime := waveEndTime
            pendingAge := 0
            int ageBase = enableFreshness ? (freshMode == "x avgWaveBars" ? int(math.round(freshMult * 10)) : freshFixed) : 999
            pendingMaxAge := math.max(freshFloor, ageBase)

if barstate.isconfirmed and (pendingLong or pendingShort)
    pendingAge += 1
    float watchLevel = pendingWatch
    bool broke = not na(watchLevel) and (pendingLong ? close < watchLevel : close > watchLevel)
    if broke
        if sigSemantics == "Invalidation break" or sigSemantics == "Both"
            newLongSignal := pendingLong
            newShortSignal := pendingShort
            newSigKind := "invalidation break"
            newWaveTime := pendingWaveTime
            sigEntryBar := pendingEntry
            sigStopBar := pendingStop
            sigTargetBar := pendingTarget
        pendingLong := false
        pendingShort := false
        pendingWatch := na
    else if pendingAge > pendingMaxAge
        pendingLong := false
        pendingShort := false
        pendingWatch := na

sigLongBar := newLongSignal
sigShortBar := newShortSignal

if barstate.isconfirmed and (newLongSignal or newShortSignal)
    lastSigSide := newLongSignal ? "LONG" : "SHORT"
    lastSigEntry := sigEntryBar
    lastSigStop := sigStopBar
    lastSigTarget := sigTargetBar
    lastSigBar := bar_index
    lastSigTime := time
    lastSigKind := newSigKind
    lastSigHit := "open"
    pushSigHist(lastSigSide, lastSigEntry, lastSigStop, lastSigTarget, time, newWaveTime, newSigKind)

// SL / PT: first touch after the confirm bar. Same candle = SL.
if barstate.isconfirmed and array.size(sigHistSide) > 0
    for si = 0 to array.size(sigHistSide) - 1
        if na(array.get(sigHistHitBar, si)) and time > array.get(sigHistConfirmTime, si)
            bool wasLong = array.get(sigHistSide, si) == "LONG"
            float stopP = array.get(sigHistStop, si)
            float tgtP = array.get(sigHistTarget, si)
            bool stopHit = wasLong ? low <= stopP : high >= stopP
            bool tgtHit = wasLong ? high >= tgtP : low <= tgtP
            if stopHit or tgtHit
                string hitKind = stopHit ? "SL" : "PT"
                array.set(sigHistHitBar, si, time)
                array.set(sigHistHitKind, si, hitKind)
                if si == array.size(sigHistSide) - 1
                    lastSigHit := hitKind

var string bestType = "None"
var bool   bestBull = true
var int    bestDone = 0
var float  bestScore = -1.0
var float  p0 = na
var float  p1 = na
var float  p2 = na
var float  p3 = na
var float  p4 = na
var float  p5 = na
var int    t0 = na
var int    t1 = na
var int    t2 = na
var int    t3 = na
var int    t4 = na
var int    t5 = na
var int    b0 = na
var int    b1 = na
var int    b2 = na
var int    b3 = na
var int    b4 = na
var int    b5 = na
var int    sub1n = 0
var int    sub2n = 0
var int    sub3n = 0
var int    sub4n = 0
var int    sub5n = 0
var int    subLiveN = 0
var bool   countDropped = false
var bool   countFresh = true
var int    patternAge = 0
var int    freshnessLimit = 0

if barstate.islast
    bestType := "None"
    bestBull := true
    bestScore := -1.0
    bestDone := 0
    p0 := na
    p1 := na
    p2 := na
    p3 := na
    p4 := na
    p5 := na
    t0 := na
    t1 := na
    t2 := na
    t3 := na
    t4 := na
    t5 := na
    b0 := na
    b1 := na
    b2 := na
    b3 := na
    b4 := na
    b5 := na
    sub1n := 0
    sub2n := 0
    sub3n := 0
    sub4n := 0
    sub5n := 0
    subLiveN := 0
    countDropped := false
    countFresh := true
    patternAge := 0
    freshnessLimit := 0
    int n = array.size(swP)
    if n >= 3
        buildMainWindow()
        [mType, mBull, mDone, mScore, m0, m1, m2, m3, m4, m5, mt0, mt1, mt2, mt3, mt4, mt5] = scanWindow(true, true, minWaveBars, false)
        [bType, bBull, bDone, bScore, bp0, bp1, bp2, bp3, bp4, bp5, bt0, bt1, bt2, bt3, bt4, bt5] = scanWindow(true, false, minWaveBars, false)
        [cType, cBull, cDone, cScore, cp0, cp1, cp2, cp3, cp4, cp5, ct0, ct1, ct2, ct3, ct4, ct5] = scanWindow(false, true, minWaveBars, false)
        float mCandidate = mScore
        float bCandidate = bScore
        float cCandidate = cScore
        if mCandidate >= bCandidate and mCandidate >= cCandidate and mCandidate >= 0
            bestScore := mCandidate
            bestType := "Impulse"
            bestBull := mBull
            bestDone := mDone
            p0 := m0
            p1 := m1
            p2 := m2
            p3 := m3
            p4 := m4
            p5 := m5
            t0 := mt0
            t1 := mt1
            t2 := mt2
            t3 := mt3
            t4 := mt4
            t5 := mt5
        if bCandidate > mCandidate and bCandidate >= cCandidate and bCandidate >= 0
            bestScore := bCandidate
            bestType := "Impulse"
            bestBull := bBull
            bestDone := bDone
            p0 := bp0
            p1 := bp1
            p2 := bp2
            p3 := bp3
            p4 := bp4
            p5 := bp5
            t0 := bt0
            t1 := bt1
            t2 := bt2
            t3 := bt3
            t4 := bt4
            t5 := bt5
        if cCandidate > mCandidate and cCandidate > bCandidate and cCandidate >= 0
            bestScore := cCandidate
            bestType := "ABC"
            bestBull := cBull
            bestDone := cDone
            p0 := cp0
            p1 := cp1
            p2 := cp2
            p3 := cp3
            p4 := cp4
            p5 := cp5
            t0 := ct0
            t1 := ct1
            t2 := ct2
            t3 := ct3
            t4 := ct4
            t5 := ct5
        b0 := resolveBarIdx(swT, swB, t0)
        b1 := resolveBarIdx(swT, swB, t1)
        b2 := resolveBarIdx(swT, swB, t2)
        b3 := resolveBarIdx(swT, swB, t3)
        b4 := resolveBarIdx(swT, swB, t4)
        b5 := resolveBarIdx(swT, swB, t5)
        int lastPivotBar = bestDone == 5 ? b5 : bestDone == 4 ? b4 : bestDone == 3 ? b3 : b2
        if not na(lastPivotBar)
            patternAge := bar_index - lastPivotBar
        int avgWaveBarsLocal = math.max(3, int(math.round(1.0 / math.max(tfSec / 86400.0, 0.0001))))
        if not na(b0) and not na(b2) and bestDone >= 2
            avgWaveBarsLocal := math.max(3, int(math.round((b2 - b0) / 2.0)))
        if not na(b0) and not na(b4) and bestDone >= 4
            avgWaveBarsLocal := math.max(3, int(math.round((b4 - b0) / 4.0)))
        freshnessLimit := enableFreshness ? (freshMode == "x avgWaveBars" ? math.max(freshFloor, int(math.round(freshMult * avgWaveBarsLocal))) : freshFixed) : 99999
        countFresh := not enableFreshness or patternAge <= freshnessLimit

float w1Len = not na(p0) and not na(p1) ? waveLen(p0, p1) : na
float w3Len = not na(p2) and not na(p3) ? waveLen(p2, p3) : na
float dirSign = bestBull ? 1.0 : -1.0
float projW3 = not na(p2) and not na(w1Len) ? p2 + dirSign * w1Len * w3Fib : na
float projW4 = not na(p3) and not na(w3Len) ? p3 - dirSign * w3Len * w4Fib : na
float projW5eq = not na(p4) and not na(w1Len) ? p4 + dirSign * w1Len * w5Fib : na
float projW5alt = not na(p4) and not na(w3Len) ? p4 + dirSign * (w1Len + w3Len) * w5AltFib : na
float invLevel = na
if bestType == "Impulse" and not na(p0)
    invLevel := bestDone <= 2 ? p0 : bestDone == 3 or bestDone == 4 ? (allowDiagonal ? p0 : p1) : p4
if bestType == "ABC" and not na(p0)
    invLevel := p0
if dropOnInvalidation and bestType != "None" and not na(invLevel)
    bool brokeInv = bestBull ? close < invLevel : close > invLevel
    if brokeInv
        countDropped := true
if enableFreshness and not countFresh
    bestType := "None"
    bestDone := 0
    p0 := na
    p1 := na
    p2 := na
    p3 := na
    p4 := na
    p5 := na
    t0 := na
    t1 := na
    t2 := na
    t3 := na
    t4 := na
    t5 := na
    b0 := na
    b1 := na
    b2 := na
    b3 := na
    b4 := na
    b5 := na
    invLevel := na
    projW3 := na
    projW4 := na
    projW5eq := na
    projW5alt := na
if countDropped
    bestType := "None"
    bestBull := true
    bestDone := 0
    bestScore := -1.0
    p0 := na
    p1 := na
    p2 := na
    p3 := na
    p4 := na
    p5 := na
    t0 := na
    t1 := na
    t2 := na
    t3 := na
    t4 := na
    t5 := na
    b0 := na
    b1 := na
    b2 := na
    b3 := na
    b4 := na
    b5 := na
    invLevel := na
    projW3 := na
    projW4 := na
    projW5eq := na
    projW5alt := na

int defaultWaveBars = math.max(3, int(math.round(1.0 / math.max(tfSec / 86400.0, 0.0001))))
int avgWaveBars = defaultWaveBars
if not na(b0) and not na(b2) and bestDone >= 2
    avgWaveBars := math.max(3, int(math.round((b2 - b0) / 2.0)))
if not na(b0) and not na(b4) and bestDone >= 4
    avgWaveBars := math.max(3, int(math.round((b4 - b0) / 4.0)))

scanDegree(float[] ap, int[] at, int[] ab, bool[] ah) =>
    buildWindowFrom(ap, at, ab, ah)
    [dType, dBull, dDone, dScore, _, _, _, _, _, _, _, _, _, _, _, _] = scanWindow(true, true, minWaveBars, false)
    [dType2, dBull2, dDone2, dScore2, _, _, _, _, _, _, _, _, _, _, _, _] = scanWindow(false, true, minWaveBars, false)
    string outType = dScore >= dScore2 ? dType : dType2
    bool outBull = dScore >= dScore2 ? dBull : dBull2
    int outDone = dScore >= dScore2 ? dDone : dDone2
    float outScore = math.max(dScore, dScore2)
    [outType, outBull, outDone, outScore]

var string deg0Type = "None"
var bool deg0Bull = true
var int deg0Done = 0
var string deg1Type = "None"
var bool deg1Bull = true
var int deg1Done = 0
var string deg2Type = "None"
var bool deg2Bull = true
var int deg2Done = 0

if barstate.islast
    deg0Type := bestType
    deg0Bull := bestBull
    deg0Done := bestDone
    if array.size(d2P) >= 3
        [t1a, b1a, d1a, _] = scanDegree(d2P, d2T, d2B, d2Hi)
        deg1Type := t1a
        deg1Bull := b1a
        deg1Done := d1a
    else
        deg1Type := "None"
        deg1Done := 0
    if array.size(d3P) >= 3
        [t2a, b2a, d2a, _] = scanDegree(d3P, d3T, d3B, d3Hi)
        deg2Type := t2a
        deg2Bull := b2a
        deg2Done := d2a
    else
        deg2Type := "None"
        deg2Done := 0
    if array.size(swP) >= 3
        buildMainWindow()

float chUpper = na
float chLower = na
if bestType == "Impulse" and bestDone >= 4 and not na(t2) and not na(t4)
    float slope = (p4 - p2) / math.max(t4 - t2, 1)
    float chOff = p1 - p2
    float tNow = time
    float baseNow = p2 + slope * (tNow - t2)
    chUpper := baseNow + chOff
    chLower := baseNow
if bestType == "ABC" and bestDone >= 3 and not na(t0) and not na(t2)
    float slope2 = (p2 - p0) / math.max(t2 - t0, 1)
    float tNow2 = time
    float baseNow2 = p0 + slope2 * (tNow2 - t0)
    chUpper := math.max(baseNow2, p2 + slope2 * (tNow2 - t2))
    chLower := math.min(baseNow2, p2 + slope2 * (tNow2 - t2))
bool priceInChannel = true
if requireInChannel and not na(chUpper) and not na(chLower)
    priceInChannel := close <= chUpper and close >= chLower

var int[] wfQKind = array.new_int()
var int[] wfQStart = array.new_int()
var int[] wfQEval = array.new_int()
var float[] wfQProj = array.new_float()
var float[] wfQBase = array.new_float()
var bool[] wfQBull = array.new_bool()
var float[] wfQTol = array.new_float()
var float[] wfQMaxHi = array.new_float()
var float[] wfQMinLo = array.new_float()
var int wfW3Hit = 0
var int wfW3Total = 0
var int wfW3BaseHit = 0
var int wfW5Hit = 0
var int wfW5Total = 0
var int wfW5BaseHit = 0
int newW3Hit = 0
int newW3Total = 0
int newW3BaseHit = 0
int newW5Hit = 0
int newW5Total = 0
int newW5BaseHit = 0

if barstate.isconfirmed and btExport and newSwingThisBar
    int nQ = array.size(swP)
    if nQ >= 6
        int i5 = nQ - 1
        int i4 = i5 - 1
        int i3 = i4 - 1
        int i2 = i3 - 1
        int i1 = i2 - 1
        int i0 = i1 - 1
        if i0 >= 0
            bool h0 = array.get(swHi, i0)
            bool altOk = array.get(swHi, i1) != h0 and array.get(swHi, i2) != array.get(swHi, i1) and array.get(swHi, i3) != array.get(swHi, i2) and array.get(swHi, i4) != array.get(swHi, i3) and array.get(swHi, i5) != array.get(swHi, i4)
            bool lastIsFresh = array.get(swB, i5) == bar_index - pivotLen
            if altOk and lastIsFresh
                float q0 = array.get(swP, i0)
                float q1 = array.get(swP, i1)
                float q2 = array.get(swP, i2)
                float q3 = array.get(swP, i3)
                float q4 = array.get(swP, i4)
                int b2i = array.get(swB, i2)
                int b4i = array.get(swB, i4)
                bool bull = not h0
                float w1i = waveLen(q0, q1)
                float w3i = waveLen(q2, q3)
                int horizon = math.min(200, math.max(5, int(math.round(avgWaveBars * btHorizonMult))))
                float tol = atr * btTolATR
                if w1i > 0
                    int evalW3 = b2i + horizon
                    if evalW3 > bar_index
                        array.push(wfQKind, 0)
                        array.push(wfQStart, b2i)
                        array.push(wfQEval, evalW3)
                        array.push(wfQProj, q2 + (bull ? 1.0 : -1.0) * w1i * w3Fib)
                        array.push(wfQBase, q2 + (bull ? 1.0 : -1.0) * w1i)
                        array.push(wfQBull, bull)
                        array.push(wfQTol, tol)
                        array.push(wfQMaxHi, low)
                        array.push(wfQMinLo, high)
                    if w3i > 0
                        int evalW5 = b4i + horizon
                        if evalW5 > bar_index
                            array.push(wfQKind, 1)
                            array.push(wfQStart, b4i)
                            array.push(wfQEval, evalW5)
                            array.push(wfQProj, q4 + (bull ? 1.0 : -1.0) * w1i * w5Fib)
                            array.push(wfQBase, q4 + (bull ? 1.0 : -1.0) * w3i)
                            array.push(wfQBull, bull)
                            array.push(wfQTol, tol)
                            array.push(wfQMaxHi, low)
                            array.push(wfQMinLo, high)

if barstate.isconfirmed and btExport and array.size(wfQKind) > 0
    for qi = 0 to array.size(wfQKind) - 1
        int startB = array.get(wfQStart, qi)
        int evalB = array.get(wfQEval, qi)
        if bar_index > startB and bar_index <= evalB
            float curMax = array.get(wfQMaxHi, qi)
            float curMin = array.get(wfQMinLo, qi)
            if high > curMax
                array.set(wfQMaxHi, qi, high)
            if low < curMin
                array.set(wfQMinLo, qi, low)

if barstate.isconfirmed and btExport and array.size(wfQKind) > 0
    for qi = array.size(wfQKind) - 1 to 0
        int evalBar = array.get(wfQEval, qi)
        if bar_index >= evalBar
            int kind = array.get(wfQKind, qi)
            float proj = array.get(wfQProj, qi)
            float base = array.get(wfQBase, qi)
            bool bull = array.get(wfQBull, qi)
            float tol = array.get(wfQTol, qi)
            float maxHi = array.get(wfQMaxHi, qi)
            float minLo = array.get(wfQMinLo, qi)
            bool hit = bull ? maxHi >= proj - tol : minLo <= proj + tol
            bool baseHit = bull ? maxHi >= base - tol : minLo <= base + tol
            if kind == 0
                newW3Total += 1
                if hit
                    newW3Hit += 1
                if baseHit
                    newW3BaseHit += 1
            else
                newW5Total += 1
                if hit
                    newW5Hit += 1
                if baseHit
                    newW5BaseHit += 1
            array.remove(wfQKind, qi)
            array.remove(wfQStart, qi)
            array.remove(wfQEval, qi)
            array.remove(wfQProj, qi)
            array.remove(wfQBase, qi)
            array.remove(wfQBull, qi)
            array.remove(wfQTol, qi)
            array.remove(wfQMaxHi, qi)
            array.remove(wfQMinLo, qi)

wfW3Hit += newW3Hit
wfW3Total += newW3Total
wfW3BaseHit += newW3BaseHit
wfW5Hit += newW5Hit
wfW5Total += newW5Total
wfW5BaseHit += newW5BaseHit

plot(btExport ? (wfW3Total > 0 ? wfW3Hit * 100.0 / wfW3Total : na) : na, "WF W3 hit %", color=color.aqua, display=display.data_window)
plot(btExport ? (wfW3Total > 0 ? wfW3BaseHit * 100.0 / wfW3Total : na) : na, "WF W3 baseline %", color=color.gray, display=display.data_window)
plot(btExport ? (wfW5Total > 0 ? wfW5Hit * 100.0 / wfW5Total : na) : na, "WF W5 hit %", color=color.orange, display=display.data_window)
plot(btExport ? (wfW5Total > 0 ? wfW5BaseHit * 100.0 / wfW5Total : na) : na, "WF W5 baseline %", color=color.gray, display=display.data_window)
plot(btExport ? newW3Hit : na, "WF W3 hit event", color=color.new(color.aqua, 60), display=display.data_window)
plot(btExport ? newW3Total : na, "WF W3 event count", color=color.new(color.aqua, 60), display=display.data_window)
plot(btExport ? newW5Hit : na, "WF W5 hit event", color=color.new(color.orange, 60), display=display.data_window)
plot(btExport ? newW5Total : na, "WF W5 event count", color=color.new(color.orange, 60), display=display.data_window)

plotshape(sigLongBar, title="Signal Long", style=shape.triangleup, location=location.belowbar, color=sigLongCol, size=size.tiny, text="L")
plotshape(sigShortBar, title="Signal Short", style=shape.triangledown, location=location.abovebar, color=sigShortCol, size=size.tiny, text="S")
plot(sigLongBar or sigShortBar ? sigEntryBar : na, "Signal Entry", color=color.new(color.white, 40), display=display.data_window)
plot(sigLongBar or sigShortBar ? sigStopBar : na, "Signal Stop", color=color.new(color.red, 40), display=display.data_window)
plot(sigLongBar or sigShortBar ? sigTargetBar : na, "Signal Target", color=color.new(color.lime, 40), display=display.data_window)

alertcondition(sigLongBar, title="Elliott Long Signal", message="Elliott: long signal")
alertcondition(sigShortBar, title="Elliott Short Signal", message="Elliott: short signal")
alertcondition(sigLongBar or sigShortBar, title="Elliott Any Signal", message="Elliott: signal fired")
alertcondition(countDropped, title="Elliott Count Invalidated", message="Elliott: count invalidated by price action")

interpretationText() =>
    string out = "-"
    if bestType == "None"
        if not countFresh
            out := "Pattern stale (age " + str.tostring(patternAge) + "b > " + str.tostring(freshnessLimit) + "b). Waiting for new setup."
        else if countDropped
            out := "Count invalidated (price broke invalidation). Waiting for new structure."
        else
            out := "No valid Elliott pattern detected on this timeframe."
    else
        string dir = bestBull ? "bullish" : "bearish"
        string cmp = bestType == "Impulse" ? "impulse" : "ABC correction"
        string doneStr = bestType == "Impulse" ? (bestDone == 5 ? "5 waves complete" : bestDone == 4 ? "Wave 4 done, W5 pending" : bestDone == 3 ? "Wave 3 done" : "Wave 2 done") : (bestDone == 3 ? "A-B-C complete" : bestDone == 2 ? "A-B done, C pending" : "Wave A done")
        string qual = bestScore >= 8.0 ? "high-quality" : bestScore >= 6.0 ? "solid" : bestScore >= minScore ? "acceptable" : "weak"
        string sigTxt = lastSigSide == "-" ? "no signal yet" : "last " + lastSigSide + " " + lastSigKind + " at " + str.tostring(lastSigEntry, format.mintick) + " (" + lastSigHit + ")"
        out := qual + " " + (countFresh ? "fresh" : "STALE") + " " + dir + " " + cmp + " (" + doneStr + "), " + (priceInChannel ? "in-channel" : "out-of-channel") + ", count " + (countDropped ? "INVALIDATED" : "valid") + ". " + sigTxt + "."
    out

if barstate.islast
    if array.size(box.all) > 0
        for i = array.size(box.all) - 1 to 0
            box.delete(array.get(box.all, i))
    if array.size(line.all) > 0
        for i = array.size(line.all) - 1 to 0
            line.delete(array.get(line.all, i))
    if array.size(label.all) > 0
        for i = array.size(label.all) - 1 to 0
            label.delete(array.get(label.all, i))

    color mainCol = bestType == "ABC" ? corrCol : bestBull ? bullCol : bearCol
    color subCol = bestBull ? subBullCol : subBearCol
    string liveTyp = "None"
    bool liveBull = bestBull
    float live0 = na
    float live1 = na
    float live2 = na

    if bestType == "Impulse" and not na(p0)
        drawLeg(t0, p0, t1, p1, mainCol, 2)
        drawLeg(t1, p1, t2, p2, mainCol, 2)
        putWave(t0, p0, "0", not bestBull, color.new(color.gray, 0), labelSize)
        putWave(t1, p1, "1", bestBull, mainCol, labelSize)
        putWave(t2, p2, "2", not bestBull, mainCol, labelSize)
        if bestDone >= 3
            drawLeg(t2, p2, t3, p3, mainCol, 2)
            putWave(t3, p3, "3", bestBull, mainCol, labelSize)
        if bestDone >= 4
            drawLeg(t3, p3, t4, p4, mainCol, 2)
            putWave(t4, p4, "4", not bestBull, mainCol, labelSize)
        if bestDone >= 5
            drawLeg(t4, p4, t5, p5, mainCol, 2)
            putWave(t5, p5, "5", bestBull, mainCol, labelSize)
    if bestType == "ABC" and not na(p0)
        drawLeg(t0, p0, t1, p1, corrCol, 2)
        drawLeg(t1, p1, t2, p2, corrCol, 2)
        putWave(t0, p0, "0", bestBull, color.new(color.gray, 0), labelSize)
        putWave(t1, p1, "A", not bestBull, corrCol, labelSize)
        putWave(t2, p2, "B", bestBull, corrCol, labelSize)
        if bestDone >= 3
            drawLeg(t2, p2, t3, p3, corrCol, 2)
            putWave(t3, p3, "C", not bestBull, corrCol, labelSize)

    if showSubWaves and bestType == "Impulse" and not na(b0)
        bool startHi = not bestBull
        [i1d, i1t, i1b, i10, i11, i12] = runSub(b0, b1, p0, p1, t0, t1, startHi, true, bestBull, subCol)
        [i2d, i2t, i2b, i20, i21, i22] = runSub(b1, b2, p1, p2, t1, t2, bestBull, false, bestBull, corrCol)
        sub1n := i1d
        sub2n := i2d
        if bestDone >= 3
            [i3d, i3t, i3b, i30, i31, i32] = runSub(b2, b3, p2, p3, t2, t3, startHi, true, bestBull, subCol)
            sub3n := i3d
        if bestDone >= 4
            [i4d, i4t, i4b, i40, i41, i42] = runSub(b3, b4, p3, p4, t3, t4, bestBull, false, bestBull, corrCol)
            sub4n := i4d
        if bestDone >= 5
            [i5d, i5t, i5b, i50, i51, i52] = runSub(b4, b5, p4, p5, t4, t5, startHi, true, bestBull, subCol)
            sub5n := i5d
        if bestDone == 2
            [l2d, l2t, l2b, l20, l21, l22] = runSub(b2, bar_index, p2, close, t2, time, startHi, true, bestBull, subCol)
            subLiveN := l2d
            liveTyp := l2t
            liveBull := l2b
            live0 := l20
            live1 := l21
            live2 := l22
        if bestDone == 3
            [l3d, l3t, l3b, l30, l31, l32] = runSub(b3, bar_index, p3, close, t3, time, bestBull, false, bestBull, corrCol)
            subLiveN := l3d
            liveTyp := l3t
            liveBull := l3b
            live0 := l30
            live1 := l31
            live2 := l32
        if bestDone == 4
            [l4d, l4t, l4b, l40, l41, l42] = runSub(b4, bar_index, p4, close, t4, time, startHi, true, bestBull, subCol)
            subLiveN := l4d
            liveTyp := l4t
            liveBull := l4b
            live0 := l40
            live1 := l41
            live2 := l42
    if showSubWaves and bestType == "ABC" and not na(b0)
        bool aStartHi = bestBull
        [a1d, a1t, a1b, a10, a11, a12] = runSub(b0, b1, p0, p1, t0, t1, aStartHi, true, not bestBull, subCol)
        [a2d, a2t, a2b, a20, a21, a22] = runSub(b1, b2, p1, p2, t1, t2, not bestBull, false, bestBull, corrCol)
        sub1n := a1d
        sub2n := a2d
        if bestDone >= 3
            [a3d, a3t, a3b, a30, a31, a32] = runSub(b2, b3, p2, p3, t2, t3, aStartHi, true, not bestBull, subCol)
            sub3n := a3d
        if bestDone == 2
            [aLd, aLt, aLb, aL0, aL1, aL2] = runSub(b2, bar_index, p2, close, t2, time, aStartHi, true, not bestBull, subCol)
            subLiveN := aLd
            liveTyp := aLt
            liveBull := aLb
            live0 := aL0
            live1 := aL1
            live2 := aL2
    if showSubForecast and showSubWaves and not na(tfMs) and liveTyp == "Impulse" and subLiveN == 2 and not na(live2)
        float sw1 = waveLen(live0, live1)
        float sDir = liveBull ? 1.0 : -1.0
        float sW3 = live2 + sDir * sw1 * w3Fib
        int sT1 = t2 + math.max(3, avgWaveBars) * tfMs
        drawFcst(t2, p2, sT1, sW3, "iii", liveBull, subCol)
    if showChannel and bestType == "Impulse" and bestDone >= 4 and not na(t2) and not na(t4)
        line.new(t2, p2, t4, p4, xloc=xloc.bar_time, extend=extend.right, color=color.new(mainCol, 40), width=1, style=line.style_dashed)
        float chOff2 = p1 - p2
        line.new(t2, p2 + chOff2, t4, p4 + chOff2, xloc=xloc.bar_time, extend=extend.right, color=color.new(mainCol, 60), width=1, style=line.style_dotted)
    if showInvalid and not na(invLevel) and not na(tfMs)
        line.new(time, invLevel, time + 30 * tfMs, invLevel, xloc=xloc.bar_time, color=invCol, width=2, style=line.style_dotted)
        label.new(time + 8 * tfMs, invLevel, "Invalidation", xloc=xloc.bar_time, style=label.style_label_left, color=invCol, textcolor=color.white, size=sizeOf(labelSize))

    if showForecast and bestType != "None" and not na(tfMs) and (requireComplete ? ((bestType == "Impulse" and bestDone == 5) or (bestType == "ABC" and bestDone == 3)) : true) and bestScore >= minScore and priceInChannel
        bool manualStart = forecastStart != "Auto"
        int autoAnchorT = bestDone == 2 ? t2 : bestDone == 3 ? t3 : bestDone == 4 ? t4 : bestDone == 5 ? t5 : t1
        float autoAnchorP = bestDone == 2 ? p2 : bestDone == 3 ? p3 : bestDone == 4 ? p4 : bestDone == 5 ? p5 : p1
        int selectedT = na
        float selectedP = na
        if bestType == "Impulse"
            if forecastStart == "Wave 1"
                selectedT := t1
                selectedP := p1
            else if forecastStart == "Wave 2"
                selectedT := t2
                selectedP := p2
            else if forecastStart == "Wave 3"
                selectedT := t3
                selectedP := p3
            else if forecastStart == "Wave 4"
                selectedT := t4
                selectedP := p4
            else if forecastStart == "Wave 5"
                selectedT := t5
                selectedP := p5
        else if bestType == "ABC"
            if forecastStart == "A"
                selectedT := t1
                selectedP := p1
            else if forecastStart == "B"
                selectedT := t2
                selectedP := p2
            else if forecastStart == "C"
                selectedT := t3
                selectedP := p3
        bool selectedValid = not na(selectedT) and not na(selectedP)
        string effectiveStart = manualStart and selectedValid ? forecastStart : "Auto"
        int anchorT = manualStart and selectedValid ? selectedT : autoAnchorT
        float anchorP = manualStart and selectedValid ? selectedP : autoAnchorP
        int nextT1 = anchorT + avgWaveBars * tfMs
        int nextT2 = anchorT + 2 * avgWaveBars * tfMs
        int nextT3 = anchorT + 3 * avgWaveBars * tfMs
        if bestType == "Impulse"
            if effectiveStart == "Auto" and bestDone == 5 and not na(p5)
                float aTgt = p5 - dirSign * waveLen(p0, p5) * 0.382
                float bTgt = aTgt + dirSign * waveLen(p5, aTgt) * bFib
                float cTgt = bTgt - dirSign * waveLen(p5, aTgt) * cFib
                drawFcst(anchorT, anchorP, nextT1, aTgt, "A", not bestBull, corrCol)
                drawFcst(nextT1, aTgt, nextT2, bTgt, "B", bestBull, corrCol)
                drawFcst(nextT2, bTgt, nextT3, cTgt, "C", not bestBull, corrCol)
            else if effectiveStart == "Auto" and bestDone == 4 and not na(projW5eq)
                drawFcst(anchorT, anchorP, nextT1, projW5eq, "W5=" + str.tostring(w5Fib) + "xW1", bestBull, mainCol)
            else if effectiveStart == "Auto" and bestDone == 3 and not na(projW4)
                drawFcst(anchorT, anchorP, nextT1, projW4, "W4 " + str.tostring(w4Fib), not bestBull, mainCol)
                drawFcst(nextT1, projW4, nextT2, projW4 + dirSign * w1Len * w5Fib, "W5 " + str.tostring(w5Fib), bestBull, mainCol)
            else if effectiveStart == "Auto" and bestDone == 2 and not na(projW3)
                drawFcst(anchorT, anchorP, nextT1, projW3, "W3 " + str.tostring(w3Fib), bestBull, mainCol)
        if bestType == "ABC" and effectiveStart == "Auto" and bestDone == 2 and not na(p2) and not na(w1Len)
            float cDir = bestBull ? 1.0 : -1.0
            drawFcst(anchorT, anchorP, nextT1, p2 + cDir * w1Len * cFib, "C " + str.tostring(cFib) + "xA", not bestBull, corrCol)

    int nSig = array.size(sigHistSide)
    if nSig > 0
        for si = 0 to nSig - 1
            string side = array.get(sigHistSide, si)
            float entry = array.get(sigHistEntry, si)
            float stopP = array.get(sigHistStop, si)
            float tgtP = array.get(sigHistTarget, si)
            int confirmT = array.get(sigHistConfirmTime, si)
            int waveT = array.get(sigHistWaveTime, si)
            string kind = array.get(sigHistKind, si)
            bool wasLong = side == "LONG"
            color sc = wasLong ? sigLongCol : sigShortCol
            if kind == "completion" and not na(waveT)
                label.new(waveT, entry, side + " WAVE-END\n" + str.tostring(entry, format.mintick), xloc=xloc.bar_time, style=wasLong ? label.style_label_up : label.style_label_down, color=sc, textcolor=color.white, size=size.small)
            if not na(confirmT)
                label.new(confirmT, entry, side + " " + kind + "\nentry " + str.tostring(entry, format.mintick) + "\nstop " + str.tostring(stopP, format.mintick) + "\ntarget " + str.tostring(tgtP, format.mintick), xloc=xloc.bar_time, style=wasLong ? label.style_label_up : label.style_label_down, color=color.new(sc, 15), textcolor=color.white, size=size.tiny)
            int hitT = array.get(sigHistHitBar, si)
            string hitKind = array.get(sigHistHitKind, si)
            if not na(hitT) and hitKind != ""
                float hitPx = hitKind == "SL" ? stopP : tgtP
                label.new(hitT, hitPx, hitKind + " " + side + "\n" + str.tostring(hitPx, format.mintick), xloc=xloc.bar_time, style=hitKind == "SL" ? label.style_label_down : label.style_label_up, color=hitKind == "SL" ? color.red : color.green, textcolor=color.white, size=size.small)

    string status = bestType == "None" ? (not countFresh ? "Pattern stale" : countDropped ? "Count invalidated" : "No valid count") : bestType + (bestBull ? " bull" : " bear") + " W" + str.tostring(bestDone) + "  score " + str.tostring(bestScore, "#.2") + "  age " + str.tostring(patternAge) + "b"
    label.new(bar_index + 3, high + atr * 1.5, status, xloc=xloc.bar_index, style=label.style_label_down, color=color.new(mainCol, 20), textcolor=color.white, size=sizeOf(labelSize))
    if showInterpretation
        string interpStyle = interpPos == "bottom_left" or interpPos == "middle_left" or interpPos == "top_left" ? label.style_label_right : interpPos == "bottom_right" or interpPos == "middle_right" or interpPos == "top_right" ? label.style_label_left : label.style_label_up
        int xOff = interpPos == "top_left" or interpPos == "middle_left" or interpPos == "bottom_left" ? -3 : interpPos == "top_right" or interpPos == "middle_right" or interpPos == "bottom_right" ? 3 : 0
        float yLevel = interpPos == "top_left" or interpPos == "top_center" or interpPos == "top_right" ? high + atr * 4 : interpPos == "bottom_left" or interpPos == "bottom_center" or interpPos == "bottom_right" ? low - atr * 4 : close
        label.new(bar_index + xOff, yLevel, interpretationText(), xloc=xloc.bar_index, style=interpStyle, color=color.new(#37474f, 0), textcolor=color.white, size=sizeOf(interpSize))
    if not tfOk
        label.new(bar_index, high + atr * 3.2, "Elliott on " + timeframe.period + " is noisy\nUse 15m or higher", style=label.style_label_down, color=color.new(color.red, 20), textcolor=color.white, size=sizeOf(labelSize))

var table tbl = table.new(tablePosOf(tablePos), 2, 21, border_width=1)
if barstate.islast and showTable
    color hd = color.new(color.teal, 0)
    color bgA = color.new(#102428, 0)
    color bgB = color.new(#163038, 0)
    color fg = color.white
    txtSz = sizeOf(tableTextSize)
    table.cell(tbl, 0, 0, "ELLIOTT COUNT", bgcolor=hd, text_color=color.white, text_size=txtSz)
    table.cell(tbl, 1, 0, bestType, bgcolor=hd, text_color=color.white, text_size=txtSz)
    table.cell(tbl, 0, 1, "Timeframe / Auto", bgcolor=bgA, text_color=fg, text_size=txtSz)
    table.cell(tbl, 1, 1, timeframe.period + (autoMode ? " (auto)" : " (manual)"), bgcolor=bgA, text_color=fg, text_size=txtSz)
    table.cell(tbl, 0, 2, "Direction", bgcolor=bgB, text_color=fg, text_size=txtSz)
    table.cell(tbl, 1, 2, bestType == "None" ? "-" : bestBull ? "Bull" : "Bear", bgcolor=bgB, text_color=fg, text_size=txtSz)
    table.cell(tbl, 0, 3, "Completed", bgcolor=bgA, text_color=fg, text_size=txtSz)
    table.cell(tbl, 1, 3, str.tostring(bestDone), bgcolor=bgA, text_color=fg, text_size=txtSz)
    table.cell(tbl, 0, 4, "Score", bgcolor=bgB, text_color=fg, text_size=txtSz)
    table.cell(tbl, 1, 4, bestScore < 0 ? "-" : str.tostring(bestScore, "#.2"), bgcolor=bgB, text_color=fg, text_size=txtSz)
    table.cell(tbl, 0, 5, "Age (bars)", bgcolor=bgA, text_color=fg, text_size=txtSz)
    table.cell(tbl, 1, 5, str.tostring(patternAge) + " / " + str.tostring(freshnessLimit), bgcolor=bgA, text_color=fg, text_size=txtSz)
    table.cell(tbl, 0, 6, "Fresh", bgcolor=bgB, text_color=fg, text_size=txtSz)
    table.cell(tbl, 1, 6, countFresh ? "Yes" : "Stale", bgcolor=bgB, text_color=countFresh ? fg : color.orange, text_size=txtSz)
    table.cell(tbl, 0, 7, "In Channel", bgcolor=bgA, text_color=fg, text_size=txtSz)
    table.cell(tbl, 1, 7, priceInChannel ? "Yes" : "No", bgcolor=bgA, text_color=fg, text_size=txtSz)
    table.cell(tbl, 0, 8, "Invalidated", bgcolor=bgB, text_color=color.fuchsia, text_size=txtSz)
    table.cell(tbl, 1, 8, countDropped ? "Yes" : "No", bgcolor=bgB, text_color=color.fuchsia, text_size=txtSz)
    table.cell(tbl, 0, 9, "Signal Mode", bgcolor=bgA, text_color=fg, text_size=txtSz)
    table.cell(tbl, 1, 9, signalMode + " / " + sigSemantics, bgcolor=bgA, text_color=fg, text_size=txtSz)
    table.cell(tbl, 0, 10, "Last Signal", bgcolor=bgB, text_color=fg, text_size=txtSz)
    table.cell(tbl, 1, 10, lastSigSide == "-" ? "-" : lastSigSide + " " + lastSigKind + " / " + lastSigHit, bgcolor=bgB, text_color=lastSigHit == "PT" ? color.lime : lastSigHit == "SL" ? color.red : fg, text_size=txtSz)
    table.cell(tbl, 0, 11, "Entry / Stop / Target", bgcolor=bgA, text_color=fg, text_size=txtSz)
    table.cell(tbl, 1, 11, (na(lastSigEntry) or na(lastSigStop) or na(lastSigTarget)) ? "-" : str.tostring(lastSigEntry, format.mintick) + " / " + str.tostring(lastSigStop, format.mintick) + " / " + str.tostring(lastSigTarget, format.mintick), bgcolor=bgA, text_color=fg, text_size=txtSz)
    table.cell(tbl, 0, 12, "Pending", bgcolor=bgB, text_color=fg, text_size=txtSz)
    table.cell(tbl, 1, 12, pendingLong ? "Long armed" : pendingShort ? "Short armed" : "-", bgcolor=bgB, text_color=fg, text_size=txtSz)
    table.cell(tbl, 0, 13, "Degree (Minor)", bgcolor=bgA, text_color=fg, text_size=txtSz)
    table.cell(tbl, 1, 13, deg0Type + " W" + str.tostring(deg0Done), bgcolor=bgA, text_color=fg, text_size=txtSz)
    table.cell(tbl, 0, 14, "Degree (Primary)", bgcolor=bgB, text_color=fg, text_size=txtSz)
    table.cell(tbl, 1, 14, deg1Type + " W" + str.tostring(deg1Done), bgcolor=bgB, text_color=fg, text_size=txtSz)
    table.cell(tbl, 0, 15, "Degree (Cycle)", bgcolor=bgA, text_color=fg, text_size=txtSz)
    table.cell(tbl, 1, 15, deg2Type + " W" + str.tostring(deg2Done), bgcolor=bgA, text_color=fg, text_size=txtSz)
    float r2v = not na(p0) and not na(p1) and not na(p2) ? retrOf(p0, p1, p2) : na
    float r3v = not na(p2) and not na(p3) and not na(w1Len) ? waveLen(p2, p3) / math.max(w1Len, syminfo.mintick) : na
    float r4v = not na(p2) and not na(p3) and not na(p4) ? retrOf(p2, p3, p4) : na
    float r5v = not na(p4) and not na(p5) and not na(w1Len) ? waveLen(p4, p5) / math.max(w1Len, syminfo.mintick) : na
    table.cell(tbl, 0, 16, "W2/W1 · W3/W1", bgcolor=bgB, text_color=fg, text_size=txtSz)
    table.cell(tbl, 1, 16, (na(r2v) ? "-" : str.tostring(r2v, "#.3")) + " · " + (na(r3v) ? "-" : str.tostring(r3v, "#.3")), bgcolor=bgB, text_color=fg, text_size=txtSz)
    table.cell(tbl, 0, 17, "W4/W3 · W5/W1", bgcolor=bgA, text_color=fg, text_size=txtSz)
    table.cell(tbl, 1, 17, (na(r4v) ? "-" : str.tostring(r4v, "#.3")) + " · " + (na(r5v) ? "-" : str.tostring(r5v, "#.3")), bgcolor=bgA, text_color=fg, text_size=txtSz)
    float w3rate = wfW3Total > 0 ? wfW3Hit * 100.0 / wfW3Total : na
    float w5rate = wfW5Total > 0 ? wfW5Hit * 100.0 / wfW5Total : na
    table.cell(tbl, 0, 18, "WF W3 hit %", bgcolor=bgA, text_color=color.aqua, text_size=txtSz)
    table.cell(tbl, 1, 18, showBacktest and not na(w3rate) ? str.tostring(w3rate, "#.1") : "-", bgcolor=bgA, text_color=color.aqua, text_size=txtSz)
    table.cell(tbl, 0, 19, "WF W5 hit %", bgcolor=bgB, text_color=color.aqua, text_size=txtSz)
    table.cell(tbl, 1, 19, showBacktest and not na(w5rate) ? str.tostring(w5rate, "#.1") : "-", bgcolor=bgB, text_color=color.aqua, text_size=txtSz)
    table.cell(tbl, 0, 20, "Swings / Sub", bgcolor=bgA, text_color=fg, text_size=txtSz)
    table.cell(tbl, 1, 20, str.tostring(array.size(swP)) + " / " + str.tostring(array.size(suP)), bgcolor=bgA, text_color=fg, text_size=txtSz)

if barstate.islast and not showTable
    table.clear(tbl, 0, 0, 1, 20)
````
