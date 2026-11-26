# EMA MTF + BOS Cont

- url: https://www.tradingview.com/script/LeMrjkJZ-EMA-MTF-BOS-Cont/
- type: indicator
- pine_id: PUB;fb07add872064eefa17d8a17440b0ecf
- version: 3.0

## Description

EMA MTF Scanner + BOS Continuation toward DOL (FVG +IFVG)

## Source Code

````pine
// EMA MTF Watchlist Alert Scanner + Continuation BOS Watch + DOL/iFVG Continuation Model
//@version=6
indicator("EMA MTF Alerts + Continuation BOS Watch", shorttitle="EMA MTF BOS Watch", overlay=true, max_labels_count=500, max_lines_count=100, scale=scale.none)

//==============================================================================
// INPUTS
//==============================================================================

emaLen = input.int(13, "EMA Length", minval=1)
emaMidLen = input.int(21, "EMA Mid Length", minval=1, group="Continuation Watch")
emaSlowLen = input.int(34, "EMA Slow Length", minval=1, group="Continuation Watch")

requiredCount = input.int(4, "Required TFs Aligned", minval=1, maxval=6)

matchMode = input.string("All Enabled Timeframes", "Match Mode", options=["All Enabled Timeframes", "At Least Required Count"])
scanDirection = input.string("Either", "Scan Direction", options=["Either", "Above EMA", "Below EMA"])

useTf1 = input.bool(true, "Use TF1", inline="tf1")
tf1 = input.timeframe("5", "", inline="tf1")

useTf2 = input.bool(true, "Use TF2", inline="tf2")
tf2 = input.timeframe("15", "", inline="tf2")

useTf3 = input.bool(true, "Use TF3", inline="tf3")
tf3 = input.timeframe("30", "", inline="tf3")

useTf4 = input.bool(true, "Use TF4", inline="tf4")
tf4 = input.timeframe("60", "", inline="tf4")

useTf5 = input.bool(true, "Use TF5", inline="tf5")
tf5 = input.timeframe("240", "", inline="tf5")

// Weekly removed from default table. TF6 is now Daily and OFF by default.
useTf6 = input.bool(false, "Use TF6", inline="tf6")
tf6 = input.timeframe("1D", "", inline="tf6")

// Continuation Watch
enableBosWatch = input.bool(true, "Enable Continuation BOS Watch", group="Continuation Watch")
bosLen = input.int(5, "BOS Swing Length", minval=2, maxval=50, group="Continuation Watch")
requireEmaStack = input.bool(true, "Require EMA 13/21/34 Stack", group="Continuation Watch")
requirePullback = input.bool(true, "Require Pullback Into EMA Zone", group="Continuation Watch")
pullbackAtrBuffer = input.float(0.25, "EMA Zone Buffer x ATR", minval=0, step=0.05, group="Continuation Watch")
atrLen = input.int(14, "ATR Length", minval=1, group="Continuation Watch")
showBosLabels = input.bool(true, "Show Tiny BOS Watch Labels", group="Continuation Watch")

// DOL + Continuation Model
showDolLine = input.bool(true, "Show DOL Dashed Line", group="DOL + iFVG Continuation")
dolSwingLen = input.int(10, "DOL Swing Length", minval=2, maxval=100, group="DOL + iFVG Continuation")
contDirectionSource = input.string("DOL + Structure", "Continuation Direction Source", options=["DOL + Structure", "EMA Alignment", "Manual Bias"], group="DOL + iFVG Continuation")
manualBias = input.string("Neutral", "Manual Bias", options=["Neutral", "Bull", "Bear"], group="DOL + iFVG Continuation")
htfFvg1 = input.timeframe("5", "HTF FVG TF 1", group="DOL + iFVG Continuation")
htfFvg2 = input.timeframe("15", "HTF FVG TF 2", group="DOL + iFVG Continuation")
fvgMinAtrMult = input.float(0.35, "FVG Min Size x ATR", minval=0.0, step=0.05, group="DOL + iFVG Continuation")
ifvgLookbackBars = input.int(60, "LTF iFVG Valid Bars", minval=5, maxval=500, group="DOL + iFVG Continuation")
requireHtfFvgForTrigger = input.bool(false, "Require HTF FVG Before iFVG Trigger", group="DOL + iFVG Continuation")

showTable = input.bool(true, "Show Table")

tablePosition = input.string(
     "Lower Left",
     "Table Position",
     options=[
         "Upper Left",
         "Upper Center",
         "Upper Right",
         "Middle Left",
         "Middle Center",
         "Middle Right",
         "Lower Left",
         "Lower Center",
         "Lower Right"
     ])

tablePos = switch tablePosition
    "Upper Left" => position.top_left
    "Upper Center" => position.top_center
    "Upper Right" => position.top_right
    "Middle Left" => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right" => position.middle_right
    "Lower Left" => position.bottom_left
    "Lower Center" => position.bottom_center
    "Lower Right" => position.bottom_right

//==============================================================================
// MTF EMA DIRECTION
//==============================================================================

f_dir(_emaLen) =>
    _ema = ta.ema(close, _emaLen)
    close > _ema ? 1 : close < _ema ? -1 : 0

d1 = useTf1 ? request.security(syminfo.tickerid, tf1, f_dir(emaLen)) : 0
d2 = useTf2 ? request.security(syminfo.tickerid, tf2, f_dir(emaLen)) : 0
d3 = useTf3 ? request.security(syminfo.tickerid, tf3, f_dir(emaLen)) : 0
d4 = useTf4 ? request.security(syminfo.tickerid, tf4, f_dir(emaLen)) : 0
d5 = useTf5 ? request.security(syminfo.tickerid, tf5, f_dir(emaLen)) : 0
d6 = useTf6 ? request.security(syminfo.tickerid, tf6, f_dir(emaLen)) : 0

activeCount =
     (useTf1 ? 1 : 0) +
     (useTf2 ? 1 : 0) +
     (useTf3 ? 1 : 0) +
     (useTf4 ? 1 : 0) +
     (useTf5 ? 1 : 0) +
     (useTf6 ? 1 : 0)

bullCount =
     (useTf1 and d1 == 1 ? 1 : 0) +
     (useTf2 and d2 == 1 ? 1 : 0) +
     (useTf3 and d3 == 1 ? 1 : 0) +
     (useTf4 and d4 == 1 ? 1 : 0) +
     (useTf5 and d5 == 1 ? 1 : 0) +
     (useTf6 and d6 == 1 ? 1 : 0)

bearCount =
     (useTf1 and d1 == -1 ? 1 : 0) +
     (useTf2 and d2 == -1 ? 1 : 0) +
     (useTf3 and d3 == -1 ? 1 : 0) +
     (useTf4 and d4 == -1 ? 1 : 0) +
     (useTf5 and d5 == -1 ? 1 : 0) +
     (useTf6 and d6 == -1 ? 1 : 0)

needed = matchMode == "All Enabled Timeframes" ? activeCount : requiredCount

bullAligned = bullCount >= needed
bearAligned = bearCount >= needed

bullAllowed = scanDirection == "Either" or scanDirection == "Above EMA"
bearAllowed = scanDirection == "Either" or scanDirection == "Below EMA"

bullSignal = bullAllowed and bullAligned
bearSignal = bearAllowed and bearAligned

alignmentSignal = bullSignal or bearSignal
newAlignmentSignal = alignmentSignal and not alignmentSignal[1]

directionText = bullSignal ? "BULLISH" : bearSignal ? "BEARISH" : "MIXED"
alignedCount = bullSignal ? bullCount : bearSignal ? bearCount : math.max(bullCount, bearCount)

signalCode = bullSignal ? 1 : bearSignal ? -1 : 0

//==============================================================================
// CONTINUATION BOS WATCH LOGIC
//==============================================================================

emaFast = ta.ema(close, emaLen)
emaMid = ta.ema(close, emaMidLen)
emaSlow = ta.ema(close, emaSlowLen)
watchAtr = ta.atr(atrLen)
zoneBuffer = watchAtr * pullbackAtrBuffer

bullStack = emaFast > emaMid and emaMid > emaSlow
bearStack = emaFast < emaMid and emaMid < emaSlow

bullStackOk = not requireEmaStack or bullStack
bearStackOk = not requireEmaStack or bearStack

emaZoneTop = math.max(emaFast, math.max(emaMid, emaSlow)) + zoneBuffer
emaZoneBottom = math.min(emaFast, math.min(emaMid, emaSlow)) - zoneBuffer

bullPullback = low <= emaZoneTop and close >= emaFast
bearPullback = high >= emaZoneBottom and close <= emaFast

bullPullbackOk = not requirePullback or bullPullback
bearPullbackOk = not requirePullback or bearPullback

ph = ta.pivothigh(bosLen, bosLen)
pl = ta.pivotlow(bosLen, bosLen)

var float lastSwingHigh = na
var float lastSwingLow = na

if not na(ph)
    lastSwingHigh := ph

if not na(pl)
    lastSwingLow := pl

bullBos = not na(lastSwingHigh) and close > lastSwingHigh
bearBos = not na(lastSwingLow) and close < lastSwingLow

bullWatchSetup = enableBosWatch and bullSignal and bullStackOk and bullPullbackOk
bearWatchSetup = enableBosWatch and bearSignal and bearStackOk and bearPullbackOk

var int watchDir = 0

bullBosWatch = false
bearBosWatch = false
bullBosConfirmed = false
bearBosConfirmed = false
alignmentFailed = false
wrongBos = false

if watchDir == 1
    if not bullSignal
        alignmentFailed := true
        watchDir := 0
    else if bearBos
        wrongBos := true
        watchDir := 0
    else if bullBos
        bullBosConfirmed := true
        watchDir := 0

if watchDir == -1
    if not bearSignal
        alignmentFailed := true
        watchDir := 0
    else if bullBos
        wrongBos := true
        watchDir := 0
    else if bearBos
        bearBosConfirmed := true
        watchDir := 0

if watchDir == 0
    if bullWatchSetup and not bearWatchSetup
        watchDir := 1
        bullBosWatch := true
    else if bearWatchSetup and not bullWatchSetup
        watchDir := -1
        bearBosWatch := true

watchText =
     bullBosConfirmed ? "BULL BOS CONFIRMED" :
     bearBosConfirmed ? "BEAR BOS CONFIRMED" :
     watchDir == 1 ? "LOOK FOR BULL BOS" :
     watchDir == -1 ? "LOOK FOR BEAR BOS" :
     "WAIT"

bosText =
     bullBosConfirmed ? "Bull Confirmed" :
     bearBosConfirmed ? "Bear Confirmed" :
     wrongBos ? "Wrong BOS -> Wait" :
     alignmentFailed ? "Align Failed -> Wait" :
     "WAIT"

//==============================================================================
// DOL TARGET LOGIC
//==============================================================================

[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead=barmerge.lookahead_on)

shDol = ta.pivothigh(dolSwingLen, dolSwingLen)
slDol = ta.pivotlow(dolSwingLen, dolSwingLen)

var float lastDolSwingHigh = na
var float lastDolSwingLow = na

if not na(shDol)
    lastDolSwingHigh := shDol
if not na(slDol)
    lastDolSwingLow := slDol

f_nearestAbove(_a, _b, _c) =>
    float best = na
    string name = "None"
    if not na(_a) and _a > close
        best := _a
        name := "PDH"
    if not na(_b) and _b > close and (na(best) or _b - close < best - close)
        best := _b
        name := "PWH"
    if not na(_c) and _c > close and (na(best) or _c - close < best - close)
        best := _c
        name := "Swing High"
    [best, name]

f_nearestBelow(_a, _b, _c) =>
    float best = na
    string name = "None"
    if not na(_a) and _a < close
        best := _a
        name := "PDL"
    if not na(_b) and _b < close and (na(best) or close - _b < close - best)
        best := _b
        name := "PWL"
    if not na(_c) and _c < close and (na(best) or close - _c < close - best)
        best := _c
        name := "Swing Low"
    [best, name]

[buyDol, buyDolName] = f_nearestAbove(pdh, pwh, lastDolSwingHigh)
[sellDol, sellDolName] = f_nearestBelow(pdl, pwl, lastDolSwingLow)

buyDist = not na(buyDol) ? buyDol - close : na
sellDist = not na(sellDol) ? close - sellDol : na
nearestDolDir = na(buyDist) and na(sellDist) ? 0 : na(sellDist) ? 1 : na(buyDist) ? -1 : buyDist <= sellDist ? 1 : -1

//==============================================================================
// HTF FVG + LTF IFVG CONTINUATION MODEL
//==============================================================================

f_fvgDir(_atrLen, _minAtr) =>
    _atr = ta.atr(_atrLen)
    _bull = low > high[2] and close[1] > high[2] and (low - high[2]) >= _atr * _minAtr
    _bear = high < low[2] and close[1] < low[2] and (low[2] - high) >= _atr * _minAtr
    _bull ? 1 : _bear ? -1 : 0

htfFvgDir1 = request.security(syminfo.tickerid, htfFvg1, f_fvgDir(atrLen, fvgMinAtrMult))
htfFvgDir2 = request.security(syminfo.tickerid, htfFvg2, f_fvgDir(atrLen, fvgMinAtrMult))
htfFvgDir = htfFvgDir1 != 0 ? htfFvgDir1 : htfFvgDir2

ltfBullFvg = low > high[2] and close[1] > high[2] and (low - high[2]) >= watchAtr * fvgMinAtrMult
ltfBearFvg = high < low[2] and close[1] < low[2] and (low[2] - high) >= watchAtr * fvgMinAtrMult

var float bullFvgTop = na
var float bullFvgBottom = na
var int bullFvgCreated = na
var float bearFvgTop = na
var float bearFvgBottom = na
var int bearFvgCreated = na

if ltfBullFvg
    bullFvgTop := low
    bullFvgBottom := high[2]
    bullFvgCreated := bar_index

if ltfBearFvg
    bearFvgTop := low[2]
    bearFvgBottom := high
    bearFvgCreated := bar_index

bullFvgActive = not na(bullFvgCreated) and bar_index - bullFvgCreated <= ifvgLookbackBars
bearFvgActive = not na(bearFvgCreated) and bar_index - bearFvgCreated <= ifvgLookbackBars

// Inverse FVG logic:
// Bull IFVG = previous bearish FVG gets reclaimed above its top.
// Bear IFVG = previous bullish FVG gets rejected/broken below its bottom.
bullIfvg = bearFvgActive and not na(bearFvgTop) and close > bearFvgTop
bearIfvg = bullFvgActive and not na(bullFvgBottom) and close < bullFvgBottom

// Structure direction is allowed to override raw EMA alignment on lower timeframes.
structureDir = bullIfvg or bullBos ? 1 : bearIfvg or bearBos ? -1 : 0
emaDir = bullSignal ? 1 : bearSignal ? -1 : 0
manualDir = manualBias == "Bull" ? 1 : manualBias == "Bear" ? -1 : 0

contDir = switch contDirectionSource
    "EMA Alignment" => emaDir
    "Manual Bias" => manualDir
    => structureDir != 0 ? structureDir : nearestDolDir

activeDol = contDir == 1 ? buyDol : contDir == -1 ? sellDol : na
activeDolName = contDir == 1 ? buyDolName : contDir == -1 ? sellDolName : "None"
dolText = contDir == 1 ? activeDolName + " ↑" : contDir == -1 ? activeDolName + " ↓" : "None"
dolDist = not na(activeDol) ? math.abs(activeDol - close) : na

contFvgText =
     bullIfvg ? "BULL IFVG SEEN" :
     bearIfvg ? "BEAR IFVG SEEN" :
     contDir == 1 and htfFvgDir == 1 ? "LOOK FOR BULL IFVG" :
     contDir == -1 and htfFvgDir == -1 ? "LOOK FOR BEAR IFVG" :
     contDir == 1 ? "LOOK FOR BULL FVG" :
     contDir == -1 ? "LOOK FOR BEAR FVG" :
     "WAIT"

htfFvgText = htfFvgDir == 1 ? "BULL FVG" : htfFvgDir == -1 ? "BEAR FVG" : "WAIT"

allowBullTrigger = contDir == 1 and bullIfvg and (not requireHtfFvgForTrigger or htfFvgDir == 1)
allowBearTrigger = contDir == -1 and bearIfvg and (not requireHtfFvgForTrigger or htfFvgDir == -1)

contFinalText = allowBullTrigger ? "BUY CONT" : allowBearTrigger ? "SELL CONT" : contDir == 1 ? "BULL WATCH" : contDir == -1 ? "BEAR WATCH" : "WAIT"

finalText =
     allowBullTrigger ? "BUY NOW" :
     allowBearTrigger ? "SELL NOW" :
     bullBosConfirmed ? "BULL CONT READY" :
     bearBosConfirmed ? "BEAR CONT READY" :
     watchDir == 1 ? "BULL BOS WATCH" :
     watchDir == -1 ? "BEAR BOS WATCH" :
     "WAIT"

// DOL drawing
var line dolLine = na
var label dolLabel = na
if barstate.islast and showDolLine
    line.delete(dolLine)
    label.delete(dolLabel)
    if not na(activeDol)
        dolColor = contDir == 1 ? color.new(color.green, 0) : color.new(color.red, 0)
        dolLine := line.new(bar_index - 50, activeDol, bar_index + 25, activeDol, color=dolColor, style=line.style_dashed, width=1)
        dolLabel := label.new(bar_index + 25, activeDol, "🎯 DOL " + activeDolName, color=color.new(dolColor, 85), textcolor=dolColor, style=label.style_label_left, size=size.tiny)

//==============================================================================
// HIDDEN PLOTS FOR ALERT/SCANNER USE
//==============================================================================

plot(signalCode, "Signal Code", display=display.none)
plot(bullCount, "Bull Count", display=display.none)
plot(bearCount, "Bear Count", display=display.none)
plot(activeCount, "Active TF Count", display=display.none)
plot(watchDir, "BOS Watch Direction", display=display.none)
plot(contDir, "Continuation Direction", display=display.none)

//==============================================================================
// LABELS - STATIC TEXT ONLY TO AVOID PINE COMPILE ISSUES
//==============================================================================

plotshape(showBosLabels and bullBosWatch, title="Look For Bull BOS", text="BOS?", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 60), textcolor=color.white, size=size.tiny)
plotshape(showBosLabels and bearBosWatch, title="Look For Bear BOS", text="BOS?", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 60), textcolor=color.white, size=size.tiny)

plotshape(showBosLabels and bullBosConfirmed, title="Bull BOS Confirmed", text="BOS✓", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 25), textcolor=color.white, size=size.tiny)
plotshape(showBosLabels and bearBosConfirmed, title="Bear BOS Confirmed", text="BOS✓", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 25), textcolor=color.white, size=size.tiny)

plotshape(showBosLabels and allowBullTrigger, title="Bull Continuation Trigger", text="iFVG✓", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 20), textcolor=color.white, size=size.tiny)
plotshape(showBosLabels and allowBearTrigger, title="Bear Continuation Trigger", text="iFVG✓", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 20), textcolor=color.white, size=size.tiny)

//==============================================================================
// ALERTS
//==============================================================================

alertcondition(newAlignmentSignal, title="EMA MTF Alignment Detected", message="{{ticker}} EMA MTF alignment detected")

if newAlignmentSignal
    alert(
         "EMA MTF ALIGNMENT: " + syminfo.ticker +
         " | Direction: " + directionText +
         " | " + str.tostring(alignedCount) + "/" + str.tostring(activeCount) +
         " TFs aligned with EMA" + str.tostring(emaLen),
         alert.freq_once_per_bar_close)

bosWatchSignal = bullBosWatch or bearBosWatch
bosConfirmedSignal = bullBosConfirmed or bearBosConfirmed
contWatchSignal = (contDir == 1 or contDir == -1) and not allowBullTrigger and not allowBearTrigger
contTriggerSignal = allowBullTrigger or allowBearTrigger

alertcondition(bosWatchSignal, title="BOS WATCH", message="{{ticker}} BOS watch active")
alertcondition(bosConfirmedSignal, title="BOS CONFIRMED", message="{{ticker}} BOS confirmed")
alertcondition(contWatchSignal, title="CONTINUATION WATCH", message="{{ticker}} continuation watch active")
alertcondition(contTriggerSignal, title="CONTINUATION TRIGGER", message="{{ticker}} continuation trigger")

if bosWatchSignal
    alert(
         syminfo.ticker + " " + timeframe.period +
         " → " + watchText +
         "\nEMA alignment: " + str.tostring(alignedCount) + "/" + str.tostring(activeCount) +
         "\nDirection: " + directionText,
         alert.freq_once_per_bar_close)

if bosConfirmedSignal
    alert(
         syminfo.ticker + " " + timeframe.period +
         " → " + watchText +
         "\nContinuation setup active" +
         "\nEMA alignment: " + str.tostring(alignedCount) + "/" + str.tostring(activeCount),
         alert.freq_once_per_bar_close)

if contTriggerSignal
    alert(
         syminfo.ticker + " " + timeframe.period +
         " → " + finalText +
         "\nDOL: " + dolText +
         "\nHTF FVG: " + htfFvgText +
         "\nLTF: " + contFvgText,
         alert.freq_once_per_bar_close)

//==============================================================================
// TABLE
//==============================================================================

// NOTE:
// Pine tables do not allow true pixel-level row-height control.
// The table is now rearranged into a wider 6-column / shorter 10-row layout.
// This preserves all fields while reducing overall table height versus the old 3-column / 16-row layout.

var table t = table.new(tablePos, 6, 10, border_width=0, frame_width=0)

tableTextSize = size.tiny

f_txt(_d) =>
    _d == 1 ? "Above" : _d == -1 ? "Below" : "Flat"

f_bg(_d) =>
    _d == 1 ? color.new(color.green, 25) : _d == -1 ? color.new(color.red, 25) : color.gray

f_statusBg(_txt) =>
    str.contains(_txt, "BULL") or str.contains(_txt, "Bull") or str.contains(_txt, "BUY") ? color.new(color.green, 10) :
     str.contains(_txt, "BEAR") or str.contains(_txt, "Bear") or str.contains(_txt, "SELL") ? color.new(color.red, 10) :
     str.contains(_txt, "WATCH") or str.contains(_txt, "LOOK") ? color.new(color.orange, 15) :
     color.gray

f_cell(int _col, int _row, string _txt, color _bg, color _tc) =>
    table.cell(t, _col, _row, _txt, bgcolor=_bg, text_color=_tc, text_size=tableTextSize)

if barstate.islast and showTable
    // Left side: EMA MTF status
    f_cell(0, 0, "TF", color.black, color.white)
    f_cell(1, 0, "EMA", color.black, color.white)
    f_cell(2, 0, "Status", color.black, color.white)

    f_cell(0, 1, tf1, na, chart.fg_color)
    f_cell(1, 1, str.tostring(emaLen), na, chart.fg_color)
    f_cell(2, 1, useTf1 ? f_txt(d1) : "Off", useTf1 ? f_bg(d1) : color.gray, color.white)

    f_cell(0, 2, tf2, na, chart.fg_color)
    f_cell(1, 2, str.tostring(emaLen), na, chart.fg_color)
    f_cell(2, 2, useTf2 ? f_txt(d2) : "Off", useTf2 ? f_bg(d2) : color.gray, color.white)

    f_cell(0, 3, tf3, na, chart.fg_color)
    f_cell(1, 3, str.tostring(emaLen), na, chart.fg_color)
    f_cell(2, 3, useTf3 ? f_txt(d3) : "Off", useTf3 ? f_bg(d3) : color.gray, color.white)

    f_cell(0, 4, tf4, na, chart.fg_color)
    f_cell(1, 4, str.tostring(emaLen), na, chart.fg_color)
    f_cell(2, 4, useTf4 ? f_txt(d4) : "Off", useTf4 ? f_bg(d4) : color.gray, color.white)

    f_cell(0, 5, tf5, na, chart.fg_color)
    f_cell(1, 5, str.tostring(emaLen), na, chart.fg_color)
    f_cell(2, 5, useTf5 ? f_txt(d5) : "Off", useTf5 ? f_bg(d5) : color.gray, color.white)

    f_cell(0, 6, tf6, na, chart.fg_color)
    f_cell(1, 6, str.tostring(emaLen), na, chart.fg_color)
    f_cell(2, 6, useTf6 ? f_txt(d6) : "Off", useTf6 ? f_bg(d6) : color.gray, color.white)

    // Right side: continuation / DOL model
    f_cell(3, 0, "Metric", color.black, color.white)
    f_cell(4, 0, "Type", color.black, color.white)
    f_cell(5, 0, "Status", color.black, color.white)

    alignBg = bullSignal ? color.green : bearSignal ? color.red : color.gray

    f_cell(3, 1, "Align", color.black, color.white)
    f_cell(4, 1, str.tostring(alignedCount) + "/" + str.tostring(activeCount), color.black, color.white)
    f_cell(5, 1, directionText, alignBg, color.white)

    f_cell(3, 2, "DOL", color.black, color.white)
    f_cell(4, 2, contDir == 1 ? "Buy" : contDir == -1 ? "Sell" : "-", color.black, color.white)
    f_cell(5, 2, dolText, f_statusBg(dolText), color.white)

    f_cell(3, 3, "Dist", color.black, color.white)
    f_cell(4, 3, "DOL", color.black, color.white)
    f_cell(5, 3, not na(dolDist) ? str.tostring(math.round_to_mintick(dolDist)) : "-", color.gray, color.white)

    f_cell(3, 4, "HTF", color.black, color.white)
    f_cell(4, 4, "FVG", color.black, color.white)
    f_cell(5, 4, htfFvgText, f_statusBg(htfFvgText), color.white)

    f_cell(3, 5, "Cont", color.black, color.white)
    f_cell(4, 5, "iFVG", color.black, color.white)
    f_cell(5, 5, contFvgText, f_statusBg(contFvgText), color.white)

    f_cell(3, 6, "Cont", color.black, color.white)
    f_cell(4, 6, "Final", color.black, color.white)
    f_cell(5, 6, contFinalText, f_statusBg(contFinalText), color.white)

    f_cell(3, 7, "Watch", color.black, color.white)
    f_cell(4, 7, "BOS", color.black, color.white)
    f_cell(5, 7, watchText, f_statusBg(watchText), color.white)

    f_cell(3, 8, "BOS", color.black, color.white)
    f_cell(4, 8, "-", color.black, color.white)
    f_cell(5, 8, bosText, f_statusBg(bosText), color.white)

    f_cell(3, 9, "Final", color.black, color.white)
    f_cell(4, 9, "-", color.black, color.white)
    f_cell(5, 9, finalText, f_statusBg(finalText), color.white)

if barstate.islast and not showTable
    table.clear(t, 0, 0, 5, 9)
````
