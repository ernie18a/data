# AlgoSentry VWAP Slope Confluence [Non-Repaint]

- url: https://www.tradingview.com/script/6t8k5ydD-AlgoSentry-VWAP-Slope-Confluence-Non-Repaint/
- type: indicator
- pine_id: PUB;eb550ed0048347e99e4ffbf2f399e862
- version: 1.0

## Description

A session-VWAP and EMA confluence tool with a statistical slope-quality engine, built to confirm trend strength rather than just trend direction. Non-repaint by default: every discrete signal locks at candle close.

What makes it different
Most VWAP/EMA tools only ask whether price is above or below the line. This one measures how strong and how clean the move is before it colors a trend or prints a signal, so weak, choppy drifts are not treated like real momentum.

The slope-quality engine
For both the session VWAP and the EMA(45), every bar it computes:
- An ATR-normalized linear-regression slope, turned into a rolling z-score (is this slope unusually strong versus its own recent history?).
- Kaufman's Efficiency Ratio — a directional move, or just noise?
- R-squared — how well does a straight line actually explain the move?
These pass a vote system: you choose how many must agree (1–3) before a slope counts as a real, tradable trend. More votes means stricter and cleaner, with fewer signals.

Orthogonal confirmation
- Volume — an independent axis from slope shape. Real moves carry participation; thin drifts do not. Signals can require above-average volume.
- Lower-timeframe slope — via request.security_lower_tf (no lookahead, default 2-minute). When the chart timeframe and the lower timeframe agree, the line thickens as a visual double-confirmation.

The signals
- Cross — the fast EMA crossing the session VWAP.
- Retest — price returning to test VWAP after a cross (wick-rejection filter plus a cooldown to stop clusters).
- Locked (yellow) — the first candle after a retest where both the VWAP and EMA(45) slopes are confirmed in the signal's direction. This is the confluence trigger.
- Invalidation — a locked setup dies the moment price crosses VWAP against it.
A live confluence score (0–100) and an on-chart dashboard expose the engine's internal strength.

Non-repaint (please read)
Default signal timing is bar close: every cross, retest and locked signal confirms on candle close (barstate.isconfirmed) and never repaints — what you see in history is what you would have seen live. A real-time mode exists and is clearly labelled; it updates intrabar for faster alerts and will repaint until the bar closes. That is your explicit choice, not a hidden default. Line coloring updates live — that is visualization, not a discrete signal.

How to use it
Built for intraday charts. The confirmation timeframe must be lower than your chart timeframe (on a 1-minute chart, lower-timeframe confirmation is inactive and the script tells you so). Start with the defaults, then tune ease, votes and warmup on your own out-of-sample data. There are deliberately no per-instrument presets — over-fitting one setting to past data is exactly how a setup looks perfect in backtest and falls apart live. Every filter toggles on and off.

Notes
Educational tool for studying VWAP/EMA trend structure. Not financial advice; it does not predict the market and guarantees nothing. Signals are descriptive, not recommendations.

## Source Code

````pine
//@version=6
// =====================================================================
// AlgoSentry VWAP Slope Confluence [Non-Repaint]   (v11 — Premium Dark)
// =====================================================================
// v11 over v10:
//   LOGIC
//     + Volume confirmation — an ORTHOGONAL filter. (z-score / ER / R^2 all
//       measure "trendiness"; volume measures participation, a different axis.)
//     + Setup invalidation — a signal dies when price crosses VWAP against it.
//     + Confluence Score 0-100 — exposes the engine's internal strength.
//     + Retest quality — wick-rejection filter + cooldown de-dup.
//     + Selectable VWAP anchor — Session / Week / Month.
//   VISUAL (premium dark — LuxAlgo / ChartPrime language, AlgoSentry brand)
//     + Glowing dynamic lines, gradient ribbon fill, institutional diamond
//       nodes, premium "LOCKED" labels, dark dashboard with magenta accents.
//
// NON-REPAINT: default Signal Timing = Bar Close. Every discrete signal locks
// at candle close (barstate.isconfirmed). Coloring/fills update live (visual).
//
// NOTE: the two request.security_lower_tf calls are kept separate (not merged)
// on purpose — clarity + safety over a marginal perf gain in open-source code.
// =====================================================================
indicator("AlgoSentry VWAP Slope Confluence [Non-Repaint]", overlay=true, max_bars_back=300, max_labels_count=500)

//==================================================
// THEME (Premium Dark)
//==================================================
grpTheme = "Theme — Premium Dark"
bullCol  = input.color(#00E5C7, "Bullish Color", group=grpTheme)
bearCol  = input.color(#FF2E92, "Bearish Color", group=grpTheme)
brandCol = input.color(#E41EB2, "Brand Accent (Magenta)", group=grpTheme)
goldCol  = input.color(#FFC04A, "Confluence / Locked Color", group=grpTheme)
baseCol  = input.color(#5A6378, "Neutral Color", group=grpTheme)
useGlow      = input.bool(true,  "Glow Lines", group=grpTheme)
useRibbon    = input.bool(true,  "Gradient Ribbon Fill (VWAP↔EMA45)", group=grpTheme)
colorCandles = input.bool(false, "Color Candles by Confluence", group=grpTheme)
color PANEL_BG = #0B0F1A
color PANEL_TX = #E8ECF4
color PANEL_GD = #1C2434

//==================================================
// CORE INPUTS
//==================================================
grpStyle = "Lines"
emaFastLen = input.int(6, "Fast EMA Length", minval=1, group=grpStyle)
vwapWidth  = input.int(2, "VWAP Width", minval=1, maxval=5, group=grpStyle)
ema45Width = input.int(2, "EMA 45 Width", minval=1, maxval=5, group=grpStyle)

grpAnchor = "VWAP Anchor"
anchorType = input.string("Session", "VWAP Anchor", options=["Session", "Week", "Month"], group=grpAnchor,
     tooltip="Where the volume-weighted average price resets. Session = daily (intraday futures/FX), Week/Month for swing context.")

grpAuto = "Auto Slope Engine"
useVwapSlopeColor  = input.bool(true, "Enable VWAP Auto Slope Color", group=grpAuto)
useEma45SlopeColor = input.bool(true, "Enable EMA 45 Auto Slope Color", group=grpAuto)
sessionWarmupBars  = input.int(10, "Session Warmup Bars", minval=0, group=grpAuto,
     tooltip="Bars to skip after each anchor reset before slope coloring activates, so VWAP can stabilize.")
chartEaseFactor    = input.float(1.00, "Chart TF Slope Ease", minval=0.01, maxval=2.00, step=0.01, group=grpAuto,
     tooltip="Lower = stricter (fewer, stronger). 1.0 is neutral. Optimize on YOUR out-of-sample data — do not curve-fit per instrument.")
useERFilter        = input.bool(true, "Use Efficiency Ratio Filter", group=grpAuto)
useR2Filter        = input.bool(true, "Use R-Squared Filter", group=grpAuto)
chartMinVotes      = input.int(1, "Chart TF Required Filters Passed", minval=1, maxval=3, group=grpAuto)

grpVol = "Volume Confirmation (orthogonal)"
useVolFilter = input.bool(true, "Require Above-Average Volume on Signals", group=grpVol,
     tooltip="Volume is an INDEPENDENT dimension from slope-shape filters. Real moves carry participation; thin drifts don't.")
volLen  = input.int(20, "Volume Average Length", minval=2, group=grpVol)
volMult = input.float(1.0, "Volume Multiplier", minval=0.1, step=0.1, group=grpVol)

grpMTF = "Lower-TF Confirmation"
enable2mConfirm      = input.bool(true, "Enable Lower-TF Slope Confirmation", group=grpMTF)
confirmTf            = input.timeframe("2", "Confirmation Timeframe", group=grpMTF,
     tooltip="Must be LOWER than the chart timeframe (it reads intrabars). On a 1-min chart this is inactive.")
requireSameDirection = input.bool(true, "Require Same Direction on Lower TF", group=grpMTF)
vwapConfirmWidth     = input.int(4, "VWAP Width When Lower TF Confirms", minval=1, maxval=10, group=grpMTF)
ema45ConfirmWidth    = input.int(4, "EMA 45 Width When Lower TF Confirms", minval=1, maxval=10, group=grpMTF)
ltfEaseFactor        = input.float(0.30, "Lower-TF Slope Ease", minval=0.01, maxval=2.00, step=0.01, group=grpMTF)
ltfUseERFilter       = input.bool(true, "Lower-TF Use Efficiency Ratio Filter", group=grpMTF)
ltfUseR2Filter       = input.bool(true, "Lower-TF Use R-Squared Filter", group=grpMTF)
ltfMinVotes          = input.int(2, "Lower-TF Required Filters Passed", minval=1, maxval=3, group=grpMTF)
ltfMinConfirmCount   = input.int(1, "Lower-TF Min Intrabars Same Direction", minval=1, maxval=20, group=grpMTF)

grpSignals = "Signals"
showCross    = input.bool(true, "Show Cross Nodes", group=grpSignals)
showRetest   = input.bool(true, "Show Retest Triangles", group=grpSignals)
useWickReject  = input.bool(true, "Require Wick Rejection on Retest", group=grpSignals,
     tooltip="Only count a VWAP retest if the candle closed back in the trend direction (rejection), not a clean break-through.")
retestCooldown = input.int(3, "Retest Cooldown (bars)", minval=0, group=grpSignals,
     tooltip="Minimum bars between retest triangles — stops a cluster of triangles while price hovers on VWAP.")

grpYellow = "Locked Confluence (Yellow)"
enableYellowThickTrigger = input.bool(true, "Enable Locked Signal (triangle + double-thick)", group=grpYellow)
onlyFirstAfterSignal     = input.bool(true, "Only First Lock Until New Signal", group=grpYellow)

grpInval = "Invalidation"
showInvalidation = input.bool(true, "Show Setup Invalidation (✕)", group=grpInval,
     tooltip="Marks when a locked signal is invalidated: price crosses VWAP against the signal's direction.")

grpStd = "VWAP StdDev Bands"
enableVwapStdRetest = input.bool(false, "Enable VWAP StdDev Retest", group=grpStd)
vwapStdDevMult      = input.float(1.0, "VWAP StdDev Multiplier", minval=0.1, step=0.1, group=grpStd)
showVwapStdVisual   = input.bool(false, "Show VWAP StdDev Bands", group=grpStd)

grpDash = "Dashboard"
showDash = input.bool(true, "Show Dashboard", group=grpDash)
dashPos  = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpDash)

grpAlert = "Alerts"
signalTiming = input.string("Bar Close (No Repaint)", "Signal Timing",
     options=["Bar Close (No Repaint)", "Real-Time (Repaints)"], group=grpAlert,
     tooltip="Bar Close = signals lock at candle close and never repaint (AlgoSentry standard). Real-Time = intrabar, faster alerts, WILL repaint until the bar closes.")
bool useBarClose = signalTiming == "Bar Close (No Repaint)"

//==================================================
// HELPERS
//==================================================
f_auto_slope_len(tfMin) =>
    int result = 12
    if tfMin <= 1
        result := 24
    else if tfMin <= 2
        result := 20
    else if tfMin <= 5
        result := 16
    else if tfMin <= 15
        result := 14
    else if tfMin <= 60
        result := 12
    else if tfMin <= 240
        result := 10
    else
        result := 8
    result

f_auto_atr_len(tfMin) =>
    int result = 12
    if tfMin <= 5
        result := 10
    else if tfMin <= 60
        result := 10
    else
        result := 8
    result

f_auto_lookback(tfMin) =>
    int result = 60
    if tfMin <= 2
        result := 70
    else if tfMin <= 5
        result := 60
    else if tfMin <= 15
        result := 50
    else if tfMin <= 60
        result := 40
    else
        result := 30
    result

f_er(src, len) =>
    float net = math.abs(src - src[len])
    float avg = ta.sma(math.abs(src - src[1]), len)
    float tot = avg * len
    tot != 0.0 ? net / tot : 0.0

f_r2(src, len) =>
    float c = ta.correlation(src, float(bar_index), len)
    not na(c) ? c * c : 0.0

f_signed_strength(src, slopeLen, atrLen, lookback, easeFactor, useER, useR2, minVotes) =>
    float lr = ta.linreg(src, slopeLen, 0)
    float atrv = ta.atr(atrLen)
    float normSlope = atrv != 0.0 ? (lr - lr[1]) / atrv : 0.0

    float absSlope = math.abs(normSlope)
    float slopeMean = ta.sma(absSlope, lookback)
    float slopeSd   = ta.stdev(absSlope, lookback)
    float slopeZ    = slopeSd != 0.0 ? (absSlope - slopeMean) / slopeSd : 0.0

    int erLen = math.max(3, int(math.round(slopeLen * 0.6)))
    int r2Len = math.max(5, int(math.round(slopeLen * 1.0)))

    float erNow  = f_er(src, erLen)
    float erBase = ta.sma(erNow, lookback)

    float r2Now  = f_r2(src, r2Len)
    float r2Base = ta.sma(r2Now, lookback)

    float zBase = ta.sma(slopeZ, lookback)
    float zSd   = ta.stdev(slopeZ, lookback)
    float zGate = (zBase * 0.25 + zSd * 0.10) * easeFactor

    bool slopeOK = slopeZ > zGate
    bool erOK    = not useER or erNow >= erBase * easeFactor
    bool r2OK    = not useR2 or r2Now >= r2Base * easeFactor

    int votes = 0
    if slopeOK
        votes += 1
    if erOK
        votes += 1
    if r2OK
        votes += 1

    int out = 0
    if votes >= minVotes
        if normSlope > 0
            out := 1
        else if normSlope < 0
            out := -1
    out

f_count_pos_int(arr) =>
    int cnt = 0
    int sz = array.size(arr)
    if sz > 0
        for i = 0 to sz - 1
            if array.get(arr, i) > 0
                cnt += 1
    cnt

f_count_neg_int(arr) =>
    int cnt = 0
    int sz = array.size(arr)
    if sz > 0
        for i = 0 to sz - 1
            if array.get(arr, i) < 0
                cnt += 1
    cnt

//==================================================
// CORE SERIES
//==================================================
string anchorTf = anchorType == "Week" ? "W" : anchorType == "Month" ? "M" : "D"
bool isNewSession = ta.change(time(anchorTf)) != 0
var int barsFromSessionStart = 0
barsFromSessionStart := isNewSession ? 0 : barsFromSessionStart + 1
bool sessionReady = barsFromSessionStart >= sessionWarmupBars

[vwapCalc, vwapUpperStd, vwapLowerStd] = ta.vwap(hlc3, isNewSession, vwapStdDevMult)
vwap    = vwapCalc
emaFast = ta.ema(close, emaFastLen)
ema45   = ta.ema(close, 45)

float chartTfMin = timeframe.in_seconds() / 60.0
int autoSlopeLen = f_auto_slope_len(chartTfMin)
int autoAtrLen   = f_auto_atr_len(chartTfMin)
int autoLookback = f_auto_lookback(chartTfMin)

float ltfMin = timeframe.in_seconds(confirmTf) / 60.0
int ltfSlopeLen = f_auto_slope_len(ltfMin)
int ltfAtrLen   = f_auto_atr_len(ltfMin)
int ltfLookback = f_auto_lookback(ltfMin)

// Volume confirmation (orthogonal to slope shape)
float avgVol = ta.sma(volume, volLen)
bool volOK = not useVolFilter or (na(avgVol) ? true : volume > avgVol * volMult)

// Guard: lower-TF confirmation needs chart TF >= confirmation TF
bool tfTooLow = enable2mConfirm and timeframe.in_seconds() < timeframe.in_seconds(confirmTf)
var label warnLbl = na
if barstate.islast
    label.delete(warnLbl)
    if tfTooLow
        warnLbl := label.new(bar_index, high,
             "AlgoSentry: chart TF < confirmation TF (" + confirmTf + ")\nLower-TF confirmation INACTIVE. Use a chart ≥ " + confirmTf,
             color=color.new(bearCol, 10), textcolor=PANEL_TX, style=label.style_label_down, size=size.normal)

//==================================================
// SLOPE ENGINE — CHART TF
//==================================================
int vwapSignedChart  = f_signed_strength(vwap, autoSlopeLen, autoAtrLen, autoLookback, chartEaseFactor, useERFilter, useR2Filter, chartMinVotes)
int ema45SignedChart = f_signed_strength(ema45, autoSlopeLen, autoAtrLen, autoLookback, chartEaseFactor, useERFilter, useR2Filter, chartMinVotes)

bool vwapUpChart   = useVwapSlopeColor and sessionReady and vwapSignedChart > 0
bool vwapDownChart = useVwapSlopeColor and sessionReady and vwapSignedChart < 0
bool ema45UpChart   = useEma45SlopeColor and ema45SignedChart > 0
bool ema45DownChart = useEma45SlopeColor and ema45SignedChart < 0

color vwapColor  = vwapUpChart ? bullCol : vwapDownChart ? bearCol : baseCol
color ema45Color = ema45UpChart ? bullCol : ema45DownChart ? bearCol : baseCol

//==================================================
// SLOPE ENGINE — LOWER TF
//==================================================
vwap2mSignedArr = request.security_lower_tf(syminfo.tickerid, confirmTf,
     f_signed_strength(ta.vwap(hlc3), ltfSlopeLen, ltfAtrLen, ltfLookback, ltfEaseFactor, ltfUseERFilter, ltfUseR2Filter, ltfMinVotes))
ema452mSignedArr = request.security_lower_tf(syminfo.tickerid, confirmTf,
     f_signed_strength(ta.ema(close, 45), ltfSlopeLen, ltfAtrLen, ltfLookback, ltfEaseFactor, ltfUseERFilter, ltfUseR2Filter, ltfMinVotes))

int vwapUp2mCount    = f_count_pos_int(vwap2mSignedArr)
int vwapDown2mCount  = f_count_neg_int(vwap2mSignedArr)
int ema45Up2mCount   = f_count_pos_int(ema452mSignedArr)
int ema45Down2mCount = f_count_neg_int(ema452mSignedArr)

bool vwapUp2m    = vwapUp2mCount >= ltfMinConfirmCount
bool vwapDown2m  = vwapDown2mCount >= ltfMinConfirmCount
bool ema45Up2m   = ema45Up2mCount >= ltfMinConfirmCount
bool ema45Down2m = ema45Down2mCount >= ltfMinConfirmCount
bool vwapAny2m   = vwapUp2m or vwapDown2m
bool ema45Any2m  = ema45Up2m or ema45Down2m

bool vwapDoubleSlopeUp    = enable2mConfirm and vwapUpChart and (requireSameDirection ? vwapUp2m : vwapAny2m)
bool vwapDoubleSlopeDown  = enable2mConfirm and vwapDownChart and (requireSameDirection ? vwapDown2m : vwapAny2m)
bool ema45DoubleSlopeUp   = enable2mConfirm and ema45UpChart and (requireSameDirection ? ema45Up2m : ema45Any2m)
bool ema45DoubleSlopeDown = enable2mConfirm and ema45DownChart and (requireSameDirection ? ema45Down2m : ema45Any2m)

//==================================================
// CONFLUENCE SCORE (0-100)
//==================================================
int bullScore = (vwapUpChart ? 25 : 0) + (ema45UpChart ? 25 : 0) + (enable2mConfirm and vwapUp2m ? 20 : 0) + (enable2mConfirm and ema45Up2m ? 20 : 0)
int bearScore = (vwapDownChart ? 25 : 0) + (ema45DownChart ? 25 : 0) + (enable2mConfirm and vwapDown2m ? 20 : 0) + (enable2mConfirm and ema45Down2m ? 20 : 0)
if volOK and useVolFilter
    if bullScore > bearScore
        bullScore += 10
    else if bearScore > bullScore
        bearScore += 10
int maxPossible = 50 + (enable2mConfirm ? 40 : 0) + (useVolFilter ? 10 : 0)
int confluenceRaw = math.max(bullScore, bearScore)
int confluence = maxPossible > 0 ? int(math.round(confluenceRaw * 100.0 / maxPossible)) : 0
int confDir = bullScore > bearScore ? 1 : bearScore > bullScore ? -1 : 0

//==================================================
// CROSS LOGIC
//==================================================
bool crossUp   = ta.crossover(emaFast, vwap)
bool crossDown = ta.crossunder(emaFast, vwap)
bool cross     = crossUp or crossDown
bool crossTrigger = useBarClose ? (cross and barstate.isconfirmed) : cross

//==================================================
// PERSISTENT RETEST DIRECTION + QUALITY
//==================================================
var int retestDirection = 0
if crossDown
    retestDirection := -1
if crossUp
    retestDirection := 1

// wick rejection: retest only counts if the candle closed back in the trend direction
bool rejBelow = not useWickReject or close < vwap
bool rejAbove = not useWickReject or close > vwap

bool touchVwapFromBelow = retestDirection == -1 and open < vwap and high >= vwap and rejBelow
bool touchVwapFromAbove = retestDirection == 1 and open > vwap and low  <= vwap and rejAbove
bool touchStdFromBelow = enableVwapStdRetest and retestDirection == -1 and open < vwap and high >= vwapLowerStd and rejBelow
bool touchStdFromAbove = enableVwapStdRetest and retestDirection == 1 and open > vwap and low  <= vwapUpperStd and rejAbove

bool touchFromBelow = touchVwapFromBelow or touchStdFromBelow
bool touchFromAbove = touchVwapFromAbove or touchStdFromAbove

// cooldown de-dup
var int lastRetestBar = -100000
bool cooldownOK = (bar_index - lastRetestBar) > retestCooldown
bool retestRaw  = (touchFromBelow or touchFromAbove) and cooldownOK
bool retestTrigger = (useBarClose ? (retestRaw and barstate.isconfirmed) : retestRaw) and volOK
if retestTrigger
    lastRetestBar := bar_index

//==================================================
// LOCKED CONFLUENCE (YELLOW) — state machine preserved from v10
//==================================================
var bool yellowArmed = false
var bool yellowLockWhileBothThick = false
var bool yellowUsedForCurrentSignal = false
var int  yellowSignalDirection = 0

bool triangleSignal = retestTrigger
if triangleSignal
    yellowArmed := true
    yellowUsedForCurrentSignal := false
    yellowLockWhileBothThick := false
    yellowSignalDirection := touchFromBelow ? -1 : touchFromAbove ? 1 : 0

bool bothThickSameDirectionNow =
     (yellowSignalDirection == -1 and vwapDoubleSlopeDown and ema45DoubleSlopeDown) or
     (yellowSignalDirection ==  1 and vwapDoubleSlopeUp   and ema45DoubleSlopeUp)

bool firstBothThickAfterArm = enableYellowThickTrigger and yellowArmed and bothThickSameDirectionNow and not yellowLockWhileBothThick
bool allowedBySecondCheckbox = not onlyFirstAfterSignal or (onlyFirstAfterSignal and not yellowUsedForCurrentSignal)
bool yellowBarTrigger = firstBothThickAfterArm and allowedBySecondCheckbox and (not useBarClose or barstate.isconfirmed)

if firstBothThickAfterArm
    yellowLockWhileBothThick := true
if yellowLockWhileBothThick and not bothThickSameDirectionNow
    yellowLockWhileBothThick := false
if yellowBarTrigger and onlyFirstAfterSignal
    yellowUsedForCurrentSignal := true

//==================================================
// INVALIDATION — locked signal dies on opposite VWAP cross
//==================================================
var int activeSignalDir = 0
if yellowBarTrigger
    activeSignalDir := yellowSignalDirection
bool invalidated = false
if activeSignalDir == 1 and crossDown
    invalidated := true
    activeSignalDir := 0
if activeSignalDir == -1 and crossUp
    invalidated := true
    activeSignalDir := 0
bool invalTrigger = showInvalidation and invalidated and (not useBarClose or barstate.isconfirmed)

//==================================================
// VISUALS — premium dark
//==================================================
// --- Glow lines (drawn back-to-front: wide+transparent → core) ---
plot(useGlow ? vwap : na,  "VWAP glow",  color.new(vwapColor, 82), vwapWidth + 8)
plot(useGlow ? vwap : na,  "VWAP haze",  color.new(vwapColor, 60), vwapWidth + 4)
vwapPlot  = plot(vwap,  "Session VWAP", vwapColor, vwapWidth)

plot(useGlow ? ema45 : na, "EMA45 glow", color.new(ema45Color, 84), ema45Width + 6)
ema45Plot = plot(ema45, "EMA 45", ema45Color, ema45Width)

plot(emaFast, "Fast EMA", color.new(brandCol, 15), 1)

// --- Gradient ribbon fill between VWAP and EMA45 ---
fill(vwapPlot, ema45Plot, color = not useRibbon ? na : (close >= vwap ? color.new(bullCol, 90) : color.new(bearCol, 90)), title="Ribbon")

// --- VWAP StdDev bands ---
uBand = plot(showVwapStdVisual ? vwapUpperStd : na, "VWAP Upper", color.new(baseCol, 55), 1)
lBand = plot(showVwapStdVisual ? vwapLowerStd : na, "VWAP Lower", color.new(baseCol, 55), 1)
fill(uBand, lBand, color = showVwapStdVisual ? color.new(brandCol, 94) : na, title="Band Fill")

// --- Lower-TF "double confirm" thick overlays (glow) ---
plot(vwapDoubleSlopeUp ? vwap : na,   "VWAP LTF Up",   color.new(bullCol, 25), vwapConfirmWidth, style=plot.style_linebr)
plot(vwapDoubleSlopeDown ? vwap : na, "VWAP LTF Down", color.new(bearCol, 25), vwapConfirmWidth, style=plot.style_linebr)
plot(ema45DoubleSlopeUp ? ema45 : na,   "EMA45 LTF Up",   color.new(bullCol, 25), ema45ConfirmWidth, style=plot.style_linebr)
plot(ema45DoubleSlopeDown ? ema45 : na, "EMA45 LTF Down", color.new(bearCol, 25), ema45ConfirmWidth, style=plot.style_linebr)

// --- Candle coloring (optional) ---
barcolor(colorCandles and confluence >= 50 ? (confDir == 1 ? bullCol : confDir == -1 ? bearCol : na) : na, title="Confluence Candles")
barcolor(yellowBarTrigger ? goldCol : na, title="Locked Candle")

// --- Markers: institutional diamond nodes + premium labels ---
plotshape(showCross and crossTrigger and crossUp   ? vwap : na, "Cross Up Node",   shape.diamond, location.absolute, color.new(bullCol, 20), size=size.tiny)
plotshape(showCross and crossTrigger and crossDown ? vwap : na, "Cross Down Node", shape.diamond, location.absolute, color.new(bearCol, 20), size=size.tiny)

float markerOffset = ta.atr(5) * 0.65
plotshape(showRetest and retestTrigger and touchFromAbove ? low - markerOffset : na,  "Retest Long",  shape.triangleup,   location.absolute, bullCol, size=size.small)
plotshape(showRetest and retestTrigger and touchFromBelow ? high + markerOffset : na, "Retest Short", shape.triangledown, location.absolute, bearCol, size=size.small)

// Locked premium labels (the high-confidence signal)
if yellowBarTrigger
    bool isLong = yellowSignalDirection == 1
    label.new(bar_index, isLong ? low - markerOffset : high + markerOffset,
         (isLong ? "◆ LONG" : "◆ SHORT") + "  " + str.tostring(confluence),
         style = isLong ? label.style_label_up : label.style_label_down,
         color = color.new(goldCol, 8), textcolor = #0A0E17, size = size.normal)

// Invalidation marker
plotshape(invalTrigger ? close : na, "Invalidation", shape.xcross, location.absolute, color.new(baseCol, 0), size=size.tiny)

//==================================================
// DASHBOARD — dark panel, magenta frame
//==================================================
f_dashPos() =>
    switch dashPos
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

var table dash = na
if showDash and barstate.islast
    if na(dash)
        dash := table.new(f_dashPos(), 2, 6, bgcolor=PANEL_BG, border_color=PANEL_GD, border_width=1, frame_color=brandCol, frame_width=1)
    color dirCol = confDir == 1 ? bullCol : confDir == -1 ? bearCol : baseCol
    string trendTxt = confDir == 1 ? "▲ BULLISH" : confDir == -1 ? "▼ BEARISH" : "— NEUTRAL"
    string ltfTxt = not enable2mConfirm ? "off" : tfTooLow ? "n/a (raise TF)" : (vwapAny2m or ema45Any2m ? "✓ confirm" : "· waiting")
    string volTxt = not useVolFilter ? "off" : (volOK ? "✓ above avg" : "· thin")
    string lockTxt = activeSignalDir == 1 ? "◆ LONG live" : activeSignalDir == -1 ? "◆ SHORT live" : "· none"

    table.cell(dash, 0, 0, "◆ AlgoSentry", text_color=brandCol, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "VWAP Slope", text_color=PANEL_TX, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 1, "Trend", text_color=PANEL_TX, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, trendTxt, text_color=dirCol, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 2, "Confluence", text_color=PANEL_TX, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(confluence) + " / 100", text_color=dirCol, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 3, "Lower TF", text_color=PANEL_TX, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, ltfTxt, text_color=PANEL_TX, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 4, "Volume", text_color=PANEL_TX, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, volTxt, text_color=PANEL_TX, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 5, "Locked", text_color=PANEL_TX, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, lockTxt, text_color=activeSignalDir == 0 ? baseCol : goldCol, text_size=size.small, text_halign=text.align_right)

//==================================================
// ALERTS
//==================================================
alertcondition(crossTrigger, "VWAP/Fast EMA Cross", "AlgoSentry: VWAP / Fast EMA cross")
alertcondition(retestTrigger, "VWAP Retest After Cross", "AlgoSentry: VWAP retest after cross")
alertcondition(yellowBarTrigger, "Locked Confluence Signal", "AlgoSentry: LOCKED confluence — VWAP & EMA45 both confirmed in the signal direction")
alertcondition(invalTrigger, "Setup Invalidated", "AlgoSentry: setup invalidated — price crossed VWAP against the signal")
if crossTrigger
    alert("AlgoSentry: VWAP / Fast EMA cross", alert.freq_once_per_bar)
if retestTrigger
    alert("AlgoSentry: VWAP retest after cross", alert.freq_once_per_bar)
if yellowBarTrigger
    alert("AlgoSentry: LOCKED confluence signal", alert.freq_once_per_bar)
if invalTrigger
    alert("AlgoSentry: setup invalidated", alert.freq_once_per_bar)
````
