# Gann-Style MTF Alignment Indicator

- url: https://www.tradingview.com/script/e1E4P09o-Gann-Style-MTF-Alignment-Indicator/
- type: indicator
- pine_id: PUB;5a766a875cbb410a81b50e82b43ecb07
- version: 3.0

## Description

W.D. Gann theory in trading is a technical analysis approach developed by William Delbert Gann. It uses geometric, mathematical, and astrological concepts to predict price movements in financial markets. Gann's methods include the use of price and time cycles, angles (Gann angles), and patterns to identify support and resistance levels, trend changes, and potential market turning points. The theory emphasizes the relationship between price, time, and pattern geometry to forecast market behavior.

## Source Code

````pine
// This Pine Script™ v6 indicator is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/

//@version=6
indicator("Gann MTF Alignment Signals", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=50)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────

// Pivot / Gann Settings
pivotLen        = input.int(5, "Pivot Lookback Length", minval=2, maxval=20, group="Gann Structure")
minBreakBars    = input.int(1, "Min bars after pivot before breakout", minval=1, maxval=10, group="Gann Structure", tooltip="Prevents breakout detection on the same bar a pivot is confirmed")

// ATR Settings
atrLen          = input.int(14, "ATR Length", minval=1, group="ATR / Risk")
slMultiplier    = input.float(1.5, "Stop Loss ATR Multiplier", minval=0.5, step=0.1, group="ATR / Risk")
tp1Multiplier   = input.float(1.0, "TP1 ATR Multiplier", minval=0.5, step=0.1, group="ATR / Risk")
tp2Multiplier   = input.float(2.0, "TP2 ATR Multiplier", minval=0.5, step=0.1, group="ATR / Risk")
tp3Multiplier   = input.float(3.0, "TP3 ATR Multiplier", minval=0.5, step=0.1, group="ATR / Risk")

// Position Splits
split1Pct       = input.float(50.0, "Split 1 %", minval=0, maxval=100, step=1, group="Position Splits")
split2Pct       = input.float(30.0, "Split 2 %", minval=0, maxval=100, step=1, group="Position Splits")
split3Pct       = input.float(20.0, "Split 3 %", minval=0, maxval=100, step=1, group="Position Splits")

// Session Filter
useSession      = input.bool(true, "Enable Session Filter", group="Session")
sessionPreset   = input.string("Custom", "Session Preset", options=["Custom", "London", "New York", "London-New York Overlap", "Asian"], group="Session")
customSession   = input.session("0930-1600", "Custom Session (HHmm-HHmm)", group="Session")

// Cooldown
cooldownBars    = input.int(10, "Min bars between signals", minval=1, maxval=50, group="Signal Control", tooltip="Prevents repeated signals while alignment persists")

// Trailing Stop
useTrailing     = input.bool(true, "Enable Trailing Stop after TP1", group="Trailing Stop")
trailMultiplier = input.float(1.0, "Trailing Stop ATR Multiplier", minval=0.1, step=0.1, group="Trailing Stop")

// Slippage Bias Analysis
useSlippage     = input.bool(true, "Enable Slippage Bias Analysis", group="Slippage Analysis")
slipLen         = input.int(5, "Slippage Lookback Bars", minval=2, maxval=20, group="Slippage Analysis")
wGap            = input.float(0.25, "Gap Weight", minval=0, maxval=1, step=0.05, group="Slippage Analysis")
wWick           = input.float(0.25, "Wick Weight", minval=0, maxval=1, step=0.05, group="Slippage Analysis")
wVol            = input.float(0.30, "Volume Weight", minval=0, maxval=1, step=0.05, group="Slippage Analysis")
wATR            = input.float(0.20, "ATR Deviation Weight", minval=0, maxval=1, step=0.05, group="Slippage Analysis")

// Profit Tracking
profitTPChoice  = input.string("TP1", "Calculate Profit Using", options=["TP1", "TP2", "TP3"], group="Profit Tracking", tooltip="Select which take-profit level to use for the last-10-trades profit calculation")

// Display
showInfoBox     = input.bool(true, "Show Info Box", group="Display")
showTPSLLines   = input.bool(true, "Show TP/SL Lines on Chart", group="Display")
showPivotDots   = input.bool(true, "Show Pivot Dots", group="Display")
showLevelLabels = input.bool(true, "Show Level Labels (Entry/SL/TP)", group="Display")
infoBoxPosition = input.string("Top Right", "Info Box Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Display")

// ─────────────────────────────────────────────
// SPLIT VALIDATION
// ─────────────────────────────────────────────

splitTotal  = split1Pct + split2Pct + split3Pct
splitsValid = split1Pct > 0 and split2Pct > 0 and split3Pct > 0 and math.abs(splitTotal - 100.0) <= 0.05

var label splitWarnLabel = na
if barstate.islast and not splitsValid
    if not na(splitWarnLabel)
        label.delete(splitWarnLabel)
    splitWarnLabel := label.new(bar_index, high + ta.atr(14) * 2,
         "⚠ Split percentages must sum to 100%\nCurrent total: " + str.tostring(splitTotal, "#.##") + "%",
         color=color.red, textcolor=color.white, style=label.style_label_down, size=size.normal)
else if barstate.islast and not na(splitWarnLabel)
    label.delete(splitWarnLabel)

// ─────────────────────────────────────────────
// SESSION RESOLUTION
// ─────────────────────────────────────────────

sessionStr = switch sessionPreset
    "London"                  => "0800-1600:1234567"
    "New York"                => "0930-1600:1234567"
    "London-New York Overlap" => "1300-1600:1234567"
    "Asian"                   => "0000-0800:1234567"
    => customSession

inSession = not useSession or not na(time(timeframe.period, sessionStr))

// ─────────────────────────────────────────────
// ATR CALCULATION (CONFIRMED BARS ONLY)
// ─────────────────────────────────────────────

atrRaw = ta.atr(atrLen)
atrVal = barstate.isconfirmed ? atrRaw : nz(atrRaw[1])

// ─────────────────────────────────────────────
// GANN SWING DIRECTION FUNCTION
// ─────────────────────────────────────────────

gannDir(_pivotLen) =>
    var float _lastPH    = na
    var float _lastPL    = na
    var int   _lastPHBar = 0
    var int   _lastPLBar = 0
    var int   _dir       = 0

    _ph = ta.pivothigh(high, _pivotLen, _pivotLen)
    _pl = ta.pivotlow(low, _pivotLen, _pivotLen)

    if not na(_ph)
        _lastPH    := _ph
        _lastPHBar := bar_index

    if not na(_pl)
        _lastPL    := _pl
        _lastPLBar := bar_index

    _bullBreak = not na(_lastPH) and close > _lastPH and (bar_index - _lastPHBar) >= minBreakBars
    _bearBreak = not na(_lastPL) and close < _lastPL and (bar_index - _lastPLBar) >= minBreakBars

    if _bullBreak
        _dir := 1
    if _bearBreak
        _dir := -1

    [_dir, _lastPH, _lastPL, _ph, _pl]

// ─────────────────────────────────────────────
// DIRECTION-ONLY WRAPPER FOR HTF CALLS
// ─────────────────────────────────────────────

gannDirOnly(_pivotLen) =>
    [d, _, _, _, _] = gannDir(_pivotLen)
    d

// ─────────────────────────────────────────────
// HTF PIVOT DATA FOR STRENGTH ASSESSMENT
// ─────────────────────────────────────────────

gannPivots(_pivotLen) =>
    [_d, _ph, _pl, _, _] = gannDir(_pivotLen)
    [_d, _ph, _pl]

// ─────────────────────────────────────────────
// 15-MINUTE DIRECTION (CURRENT TF)
// ─────────────────────────────────────────────

[dir15Raw, lastPH15Raw, lastPL15Raw, ph15Raw, pl15Raw] = gannDir(pivotLen)

dir15    = barstate.isconfirmed ? dir15Raw    : nz(dir15Raw[1], 0)
lastPH15 = barstate.isconfirmed ? lastPH15Raw : nz(lastPH15Raw[1])
lastPL15 = barstate.isconfirmed ? lastPL15Raw : nz(lastPL15Raw[1])

// ─────────────────────────────────────────────
// HIGHER TIMEFRAME DIRECTIONS (NON-REPAINTING)
// ─────────────────────────────────────────────

dir1H = request.security(syminfo.tickerid, "60",  gannDirOnly(pivotLen)[1], lookahead=barmerge.lookahead_off)
dir4H = request.security(syminfo.tickerid, "240", gannDirOnly(pivotLen)[1], lookahead=barmerge.lookahead_off)

// ─────────────────────────────────────────────
// HTF STRENGTH CONTEXT
// ─────────────────────────────────────────────

[dir1H_full, lastPH_1H, lastPL_1H] = request.security(syminfo.tickerid, "60",  gannPivots(pivotLen), lookahead=barmerge.lookahead_off)
[dir4H_full, lastPH_4H, lastPL_4H] = request.security(syminfo.tickerid, "240", gannPivots(pivotLen), lookahead=barmerge.lookahead_off)

atr1H = request.security(syminfo.tickerid, "60",  ta.atr(atrLen)[1], lookahead=barmerge.lookahead_off)
atr4H = request.security(syminfo.tickerid, "240", ta.atr(atrLen)[1], lookahead=barmerge.lookahead_off)

htf1H_bullStrong = dir1H == 1  and not na(lastPH_1H) and not na(atr1H) and close > lastPH_1H + atr1H * 0.25
htf1H_bearStrong = dir1H == -1 and not na(lastPL_1H) and not na(atr1H) and close < lastPL_1H - atr1H * 0.25
htf4H_bullStrong = dir4H == 1  and not na(lastPH_4H) and not na(atr4H) and close > lastPH_4H + atr4H * 0.25
htf4H_bearStrong = dir4H == -1 and not na(lastPL_4H) and not na(atr4H) and close < lastPL_4H - atr4H * 0.25

// ─────────────────────────────────────────────
// SLIPPAGE BIAS ANALYSIS
// ─────────────────────────────────────────────

gapBias(len) =>
    float sumGap = 0.0
    for i = 0 to len - 1
        sumGap += open[i] - close[i + 1]
    sumGap

wickBias(len) =>
    float score = 0.0
    for i = 0 to len - 1
        body = math.abs(close[i] - open[i])
        upperWick = high[i] - math.max(close[i], open[i])
        lowerWick = math.min(close[i], open[i]) - low[i]
        score += (lowerWick - upperWick) / math.max(body, syminfo.mintick)
    score / len

volDrift(len) =>
    float sumUp = 0.0
    float sumDn = 0.0
    for i = 0 to len - 1
        change = close[i] - open[i]
        vol = nz(volume[i], 1.0)
        if change > 0
            sumUp += vol
        else if change < 0
            sumDn += vol
    (sumUp - sumDn) / math.max(sumUp + sumDn, 1.0)

atrDeviation(len, _atrVal) =>
    upMove = math.max(close - close[len], 0)
    dnMove = math.max(close[len] - close, 0)
    netMove = (upMove - dnMove) / math.max(_atrVal, syminfo.mintick)
    netMove

// Calculate slippage components
slipGap     = gapBias(slipLen)
slipWick    = wickBias(slipLen)
slipVol     = volDrift(slipLen)
slipATRDev  = atrDeviation(slipLen, atrVal)

// Normalize to -1 to +1 range
gapNorm  = math.max(-1.0, math.min(1.0, slipGap / math.max(atrVal * slipLen, syminfo.mintick) * 100))
wickNorm = math.max(-1.0, math.min(1.0, slipWick / 3.0))
volNorm  = slipVol
atrNorm  = math.max(-1.0, math.min(1.0, slipATRDev / 2.0))

// Adjust volume weight if no volume data available
hasVolume    = nz(volume) > 0
adjVolWeight = hasVolume ? wVol : 0.0
totalWeight  = wGap + wWick + adjVolWeight + wATR
safeWeight   = math.max(totalWeight, 0.01)

// Composite slippage score
slippageScore = useSlippage ? (gapNorm * wGap + wickNorm * wWick + volNorm * adjVolWeight + atrNorm * wATR) / safeWeight : 0.0
slippagePct   = slippageScore * 100

// Signal quality grading
signalGrade(isBull, score) =>
    threshold = isBull ? score : -score
    if threshold > 0.5
        "A"
    else if threshold > 0.15
        "B"
    else if threshold > -0.15
        "C"
    else if threshold > -0.5
        "D"
    else
        "F"

// ─────────────────────────────────────────────
// MULTI-TIMEFRAME ALIGNMENT
// ─────────────────────────────────────────────

bullAligned = dir15 == 1  and dir1H == 1  and dir4H == 1
bearAligned = dir15 == -1 and dir1H == -1 and dir4H == -1

bullAlignedStrong = bullAligned and htf1H_bullStrong and htf4H_bullStrong
bearAlignedStrong = bearAligned and htf1H_bearStrong and htf4H_bearStrong

// ─────────────────────────────────────────────
// SIGNAL GENERATION WITH COOLDOWN
// ─────────────────────────────────────────────

var int lastSignalBar = 0

bullTransition = bullAligned and not bullAligned[1]
bearTransition = bearAligned and not bearAligned[1]

bullSignal = bullTransition and inSession and splitsValid and barstate.isconfirmed and (bar_index - lastSignalBar) >= cooldownBars
bearSignal = bearTransition and inSession and splitsValid and barstate.isconfirmed and (bar_index - lastSignalBar) >= cooldownBars

if bullSignal or bearSignal
    lastSignalBar := bar_index

// ─────────────────────────────────────────────
// TRADE STATE MACHINE
// ─────────────────────────────────────────────

var int   tradeState  = 0    // 0=flat, 1=long, -1=short
var float entryPrice  = na
var float slPrice     = na
var float tp1Price    = na
var float tp2Price    = na
var float tp3Price    = na
var bool  tp1Hit      = false
var bool  tp2Hit      = false
var bool  tp3Hit      = false
var float trailStop   = na
var string lastGrade  = "—"

// ── ENTRY ──
if tradeState == 0 and bullSignal
    tradeState := 1
    entryPrice := close
    slPrice    := close - atrVal * slMultiplier
    tp1Price   := close + atrVal * tp1Multiplier
    tp2Price   := close + atrVal * tp2Multiplier
    tp3Price   := close + atrVal * tp3Multiplier
    tp1Hit     := false
    tp2Hit     := false
    tp3Hit     := false
    trailStop  := na
    lastGrade  := useSlippage ? signalGrade(true, slippageScore) : "—"

if tradeState == 0 and bearSignal
    tradeState := -1
    entryPrice := close
    slPrice    := close + atrVal * slMultiplier
    tp1Price   := close - atrVal * tp1Multiplier
    tp2Price   := close - atrVal * tp2Multiplier
    tp3Price   := close - atrVal * tp3Multiplier
    tp1Hit     := false
    tp2Hit     := false
    tp3Hit     := false
    trailStop  := na
    lastGrade  := useSlippage ? signalGrade(false, slippageScore) : "—"

// ── LONG TRADE MANAGEMENT ──
if tradeState == 1
    if not tp1Hit and high >= tp1Price
        tp1Hit  := true
        slPrice := entryPrice
    if not tp2Hit and high >= tp2Price
        tp2Hit := true
    if not tp3Hit and high >= tp3Price
        tp3Hit := true

    if useTrailing and tp1Hit and not tp3Hit
        newTrail = close - atrVal * trailMultiplier
        if na(trailStop)
            trailStop := newTrail
        else
            trailStop := math.max(trailStop, newTrail)
        slPrice := math.max(slPrice, trailStop)

    if tp3Hit or low <= slPrice or not bullAligned
        tradeState := 0

// ── SHORT TRADE MANAGEMENT ──
if tradeState == -1
    if not tp1Hit and low <= tp1Price
        tp1Hit  := true
        slPrice := entryPrice
    if not tp2Hit and low <= tp2Price
        tp2Hit := true
    if not tp3Hit and low <= tp3Price
        tp3Hit := true

    if useTrailing and tp1Hit and not tp3Hit
        newTrail = close + atrVal * trailMultiplier
        if na(trailStop)
            trailStop := newTrail
        else
            trailStop := math.min(trailStop, newTrail)
        slPrice := math.min(slPrice, trailStop)

    if tp3Hit or high >= slPrice or not bearAligned
        tradeState := 0

// ── CLEANUP ON FLAT ──
if tradeState == 0 and tradeState[1] != 0
    entryPrice := na
    slPrice    := na
    tp1Price   := na
    tp2Price   := na
    tp3Price   := na
    trailStop  := na

// ─────────────────────────────────────────────
// PROFIT TRACKING — LAST 10 TRADES
// ─────────────────────────────────────────────

profitTPMult = switch profitTPChoice
    "TP1" => tp1Multiplier
    "TP2" => tp2Multiplier
    "TP3" => tp3Multiplier
    => tp1Multiplier

var float[] tradeProfits = array.new_float(0)

if bullSignal or bearSignal
    float profit = atrVal * profitTPMult
    array.push(tradeProfits, profit)
    if array.size(tradeProfits) > 10
        array.shift(tradeProfits)

totalProfit = array.size(tradeProfits) > 0 ? array.sum(tradeProfits) : 0.0
tradeCount  = array.size(tradeProfits)

// ─────────────────────────────────────────────
// PIVOT DOTS
// ─────────────────────────────────────────────

if showPivotDots and not na(ph15Raw)
    label.new(bar_index - pivotLen, ph15Raw, "●", style=label.style_none, textcolor=color.new(color.red, 30), size=size.tiny)
if showPivotDots and not na(pl15Raw)
    label.new(bar_index - pivotLen, pl15Raw, "●", style=label.style_none, textcolor=color.new(color.green, 30), size=size.tiny)

// ─────────────────────────────────────────────
// SIGNAL LABELS
// ─────────────────────────────────────────────

if bullSignal
    gradeStr  = useSlippage ? " [" + lastGrade + "]" : ""
    strongStr = bullAlignedStrong ? "STRONG " : ""
    label.new(bar_index, low - atrVal * 0.5, "▲ " + strongStr + "BUY" + gradeStr,
         style=label.style_label_up,
         color=bullAlignedStrong ? color.green : color.new(color.green, 30),
         textcolor=color.white, size=size.normal)

if bearSignal
    gradeStr  = useSlippage ? " [" + lastGrade + "]" : ""
    strongStr = bearAlignedStrong ? "STRONG " : ""
    label.new(bar_index, high + atrVal * 0.5, "▼ " + strongStr + "SELL" + gradeStr,
         style=label.style_label_down,
         color=bearAlignedStrong ? color.red : color.new(color.red, 30),
         textcolor=color.white, size=size.normal)

// ─────────────────────────────────────────────
// LINE & LABEL HELPER FUNCTIONS
// ─────────────────────────────────────────────

f_manageLine(line _ln, int _x1, int _x2, float _price, color _col, int _width, string _style) =>
    lineStyle = switch _style
        "solid"  => line.style_solid
        "dashed" => line.style_dashed
        => line.style_dotted
    if na(_price)
        if not na(_ln)
            line.delete(_ln)
        line(na)
    else if na(_ln)
        line.new(_x1, _price, _x2, _price, xloc=xloc.bar_index, color=_col, width=_width, style=lineStyle)
    else
        line.set_xy1(_ln, _x1, _price)
        line.set_xy2(_ln, _x2, _price)
        line.set_color(_ln, _col)
        line.set_width(_ln, _width)
        line.set_style(_ln, lineStyle)
        _ln

f_manageLabel(label _lbl, int _x, float _price, string _name, color _col) =>
    if na(_price) or not showLevelLabels
        if not na(_lbl)
            label.delete(_lbl)
        label(na)
    else
        txt = _name + ": " + str.tostring(_price, format.mintick)
        if na(_lbl)
            label.new(_x, _price, txt, xloc=xloc.bar_index,
                 style=label.style_label_left, textcolor=color.white, color=_col, size=size.tiny)
        else
            label.set_xy(_lbl, _x, _price)
            label.set_text(_lbl, txt)
            label.set_color(_lbl, _col)
            _lbl

// ─────────────────────────────────────────────
// TP / SL LINES AND LABELS
// ─────────────────────────────────────────────

var line entryLine = na
var line slLine    = na
var line tp1Line   = na
var line tp2Line   = na
var line tp3Line   = na
var line trailLine = na

var label entryLbl = na
var label slLbl    = na
var label tp1Lbl   = na
var label tp2Lbl   = na
var label tp3Lbl   = na
var label trailLbl = na

if showTPSLLines
    x1 = tradeState != 0 ? bar_index - 1 : 0
    x2 = tradeState != 0 ? bar_index + 30 : 0
    labelX = bar_index + 31

    activeEntry = tradeState != 0 ? entryPrice : na
    activeSL    = tradeState != 0 ? slPrice : na
    activeTP1   = tradeState != 0 and not tp1Hit ? tp1Price : na
    activeTP2   = tradeState != 0 and not tp2Hit ? tp2Price : na
    activeTP3   = tradeState != 0 and not tp3Hit ? tp3Price : na
    activeTrail = tradeState != 0 and not na(trailStop) ? trailStop : na

    entryLine := f_manageLine(entryLine, x1, x2, activeEntry, color.white,         1, "solid")
    slLine    := f_manageLine(slLine,    x1, x2, activeSL,    color.red,           2, "dashed")
    tp1Line   := f_manageLine(tp1Line,   x1, x2, activeTP1,   color.new(color.green, 40), 1, "dotted")
    tp2Line   := f_manageLine(tp2Line,   x1, x2, activeTP2,   color.new(color.green, 20), 1, "dotted")
    tp3Line   := f_manageLine(tp3Line,   x1, x2, activeTP3,   color.green,         2, "solid")
    trailLine := f_manageLine(trailLine, x1, x2, activeTrail, color.orange,        1, "dashed")

    entryLbl := f_manageLabel(entryLbl, labelX, activeEntry, "Entry", color.white)
    slLbl    := f_manageLabel(slLbl,    labelX, activeSL,    "SL",    color.red)
    tp1Lbl   := f_manageLabel(tp1Lbl,   labelX, activeTP1,   "TP1",  color.green)
    tp2Lbl   := f_manageLabel(tp2Lbl,   labelX, activeTP2,   "TP2",  color.green)
    tp3Lbl   := f_manageLabel(tp3Lbl,   labelX, activeTP3,   "TP3",  color.green)
    trailLbl := f_manageLabel(trailLbl, labelX, activeTrail, "Trail", color.orange)

// ─────────────────────────────────────────────
// BACKGROUND COLORING
// ─────────────────────────────────────────────

bgcolor(bullAligned ? color.new(color.green, 92) : bearAligned ? color.new(color.red, 92) : na, title="Alignment Background")

// ─────────────────────────────────────────────
// INFO BOX
// ─────────────────────────────────────────────

var table infoTable = na

if showInfoBox and barstate.islast
    boxPos = switch infoBoxPosition
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

    if not na(infoTable)
        table.delete(infoTable)

    totalRows = 15
    infoTable := table.new(boxPos, 2, totalRows, bgcolor=color.new(color.black, 70), border_width=1, border_color=color.gray)

    // Header
    table.cell(infoTable, 0, 0, "Gann MTF Alignment", text_color=color.white, text_size=size.small, bgcolor=color.new(color.blue, 60))
    table.cell(infoTable, 1, 0, "",                    text_color=color.white, text_size=size.small, bgcolor=color.new(color.blue, 60))

    // Row 1: 15m Direction
    dir15Str = dir15 == 1 ? "BULL ▲" : dir15 == -1 ? "BEAR ▼" : "NEUTRAL —"
    dir15Clr = dir15 == 1 ? color.green : dir15 == -1 ? color.red : color.gray
    table.cell(infoTable, 0, 1, "15m",    text_color=color.white, text_size=size.tiny)
    table.cell(infoTable, 1, 1, dir15Str, text_color=dir15Clr,   text_size=size.tiny)

    // Row 2: 1H Direction
    dir1HStr = dir1H == 1 ? "BULL ▲" : dir1H == -1 ? "BEAR ▼" : "NEUTRAL —"
    dir1HClr = dir1H == 1 ? color.green : dir1H == -1 ? color.red : color.gray
    table.cell(infoTable, 0, 2, "1H",    text_color=color.white, text_size=size.tiny)
    table.cell(infoTable, 1, 2, dir1HStr, text_color=dir1HClr,   text_size=size.tiny)

    // Row 3: 4H Direction
    dir4HStr = dir4H == 1 ? "BULL ▲" : dir4H == -1 ? "BEAR ▼" : "NEUTRAL —"
    dir4HClr = dir4H == 1 ? color.green : dir4H == -1 ? color.red : color.gray
    table.cell(infoTable, 0, 3, "4H",    text_color=color.white, text_size=size.tiny)
    table.cell(infoTable, 1, 3, dir4HStr, text_color=dir4HClr,   text_size=size.tiny)

    // Row 4: Alignment
    alignStr = bullAligned ? "BULL ALIGNED" : bearAligned ? "BEAR ALIGNED" : "NO ALIGNMENT"
    alignClr = bullAligned ? color.green : bearAligned ? color.red : color.gray
    table.cell(infoTable, 0, 4, "Alignment", text_color=color.white, text_size=size.tiny)
    table.cell(infoTable, 1, 4, alignStr,    text_color=alignClr,   text_size=size.tiny)

    // Row 5: Strength
    strengthStr = bullAlignedStrong ? "STRONG ▲▲" : bearAlignedStrong ? "STRONG ▼▼" : bullAligned or bearAligned ? "MARGINAL" : "—"
    strengthClr = bullAlignedStrong ? color.lime : bearAlignedStrong ? color.fuchsia : color.gray
    table.cell(infoTable, 0, 5, "Strength",  text_color=color.white,  text_size=size.tiny)
    table.cell(infoTable, 1, 5, strengthStr, text_color=strengthClr, text_size=size.tiny)

    // Row 6: Session
    sessStr = inSession ? "ACTIVE ✓" : "INACTIVE ✗"
    sessClr = inSession ? color.green : color.orange
    table.cell(infoTable, 0, 6, "Session", text_color=color.white, text_size=size.tiny)
    table.cell(infoTable, 1, 6, sessStr,   text_color=sessClr,    text_size=size.tiny)

    // Row 7: ATR
    table.cell(infoTable, 0, 7, "ATR(" + str.tostring(atrLen) + ")", text_color=color.white, text_size=size.tiny)
    table.cell(infoTable, 1, 7, str.tostring(atrVal, format.mintick), text_color=color.yellow, text_size=size.tiny)

    // Row 8: Trade State
    tradeStr = tradeState == 1 ? "LONG" : tradeState == -1 ? "SHORT" : "FLAT"
    tradeClr = tradeState == 1 ? color.green : tradeState == -1 ? color.red : color.gray
    table.cell(infoTable, 0, 8, "Trade",  text_color=color.white, text_size=size.tiny)
    table.cell(infoTable, 1, 8, tradeStr, text_color=tradeClr,   text_size=size.tiny)

    // Row 9: TP Progress
    tpStr = tradeState != 0 ? (tp1Hit ? "1✓ " : "1○ ") + (tp2Hit ? "2✓ " : "2○ ") + (tp3Hit ? "3✓" : "3○") : "—"
    table.cell(infoTable, 0, 9, "TPs Hit", text_color=color.white, text_size=size.tiny)
    table.cell(infoTable, 1, 9, tpStr,     text_color=color.white, text_size=size.tiny)

    // Row 10: Entry / SL
    levelsStr = tradeState != 0 ? "E:" + str.tostring(entryPrice, format.mintick) + " SL:" + str.tostring(slPrice, format.mintick) : "—"
    table.cell(infoTable, 0, 10, "Levels",  text_color=color.white,  text_size=size.tiny)
    table.cell(infoTable, 1, 10, levelsStr, text_color=color.yellow, text_size=size.tiny)

    // Row 11: Splits
    splitStr = splitsValid ? str.tostring(split1Pct, "#") + "/" + str.tostring(split2Pct, "#") + "/" + str.tostring(split3Pct, "#") : "INVALID ⚠"
    splitClr = splitsValid ? color.white : color.red
    table.cell(infoTable, 0, 11, "Splits",  text_color=color.white, text_size=size.tiny)
    table.cell(infoTable, 1, 11, splitStr,  text_color=splitClr,   text_size=size.tiny)

    // Row 12: Slippage Bias
    if useSlippage
        biasDir  = slippageScore > 0.15 ? "BUY ▲" : slippageScore < -0.15 ? "SELL ▼" : "NEUTRAL"
        biasClr  = slippageScore > 0.15 ? color.green : slippageScore < -0.15 ? color.red : color.gray
        table.cell(infoTable, 0, 12, "Flow Bias", text_color=color.white, text_size=size.tiny)
        table.cell(infoTable, 1, 12, biasDir + " (" + str.tostring(slippagePct, "#.0") + "%)", text_color=biasClr, text_size=size.tiny)
    else
        table.cell(infoTable, 0, 12, "Flow Bias", text_color=color.white, text_size=size.tiny)
        table.cell(infoTable, 1, 12, "Disabled",  text_color=color.gray,  text_size=size.tiny)

    // Row 13: Signal Grade
    table.cell(infoTable, 0, 13, "Grade",    text_color=color.white, text_size=size.tiny)
    gradeClr = switch lastGrade
        "A" => color.lime
        "B" => color.green
        "C" => color.yellow
        "D" => color.orange
        "F" => color.red
        => color.gray
    table.cell(infoTable, 1, 13, lastGrade, text_color=gradeClr, text_size=size.tiny)

    // Row 14: Profit Tracking
    profitClr = totalProfit >= 0 ? color.lime : color.red
    table.cell(infoTable, 0, 14, "Last " + str.tostring(tradeCount) + " P/L", text_color=color.white, text_size=size.tiny)
    table.cell(infoTable, 1, 14, str.tostring(totalProfit, "#.##") + " (" + profitTPChoice + ")", text_color=profitClr, text_size=size.tiny)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────

alertcondition(bullSignal, title="Bull Alignment Signal", message="Gann MTF: Bullish alignment detected on {{ticker}}")
alertcondition(bearSignal, title="Bear Alignment Signal", message="Gann MTF: Bearish alignment detected on {{ticker}}")
alertcondition(bullSignal and bullAlignedStrong, title="Strong Bull Signal", message="Gann MTF: STRONG bullish alignment on {{ticker}}")
alertcondition(bearSignal and bearAlignedStrong, title="Strong Bear Signal", message="Gann MTF: STRONG bearish alignment on {{ticker}}")
alertcondition(tradeState == 1 and tp1Hit and not tp1Hit[1], title="Long TP1 Hit", message="Gann MTF: Long TP1 reached on {{ticker}}")
alertcondition(tradeState == -1 and tp1Hit and not tp1Hit[1], title="Short TP1 Hit", message="Gann MTF: Short TP1 reached on {{ticker}}")
alertcondition(tradeState[1] != 0 and tradeState == 0, title="Trade Closed", message="Gann MTF: Trade closed on {{ticker}}")

// ─────────────────────────────────────────────
// END OF SCRIPT
// ─────────────────────────────────────────────
````
