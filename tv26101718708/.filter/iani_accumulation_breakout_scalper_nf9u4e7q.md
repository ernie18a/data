# IANI Accumulation Breakout Scalper

- url: https://www.tradingview.com/script/NF9u4E7Q-IANI-Accumulation-Breakout-Scalper/
- type: indicator
- pine_id: PUB;7b66b9c2e34c49bcbf581e0a63782004
- version: 1.0

## Description

IANI Accumulation Breakout Scalper is a price-action based scalping indicator designed for M1 and M5 intraday analysis.

It detects dynamic support and resistance trendlines, accumulation zones, breakout watch conditions, retest entries and basic reversal patterns such as Head & Shoulders, Inverse Head & Shoulders, Double Top and Double Bottom.

The pattern detection is based on confirmed pivot structure and neckline breakout confirmation. This helps avoid marking every random shape as a valid pattern.

Recommended use:
Start from M1 for entry timing, validate the structure on M5, and always check M15/H1 context before taking trades.

Best used for:
- Scalping
- XAUUSD
- Indices
- Crypto
- Accumulation breakout setups
- Breakout + retest entries
- Pattern confirmation after liquidity sweeps

This indicator should not be used as a blind buy/sell system. Confirm signals with market structure, liquidity, session timing and risk management.

## Source Code

````pine
//@version=5
indicator("IANI Accumulation Breakout Scalper", shorttitle="IANI ABS", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=500)

// ================= INPUTS =================
group_logic = "Logic - Scalp Defaults"
sourceMode  = input.string("Close", "Source Mode", options=["Close", "Wick"], group=group_logic)
lookback    = input.int(7, "Pivot Sensitivity", minval=2, maxval=30, group=group_logic)
minBreak    = input.float(1.00, "Break Confirmation", step=0.10, group=group_logic)
retestTol   = input.float(0.80, "Retest Tolerance", step=0.10, group=group_logic)
touchTol    = input.float(1.20, "Touch Tolerance", step=0.10, group=group_logic)
minTouches  = input.int(3, "Minimum Touches For Accumulation", minval=2, maxval=10, group=group_logic)
maxBarsWait = input.int(80, "Max Bars To Wait After Breakout", minval=5, maxval=300, group=group_logic)
touchLookbackBars = input.int(180, "Touch Count Lookback Bars", minval=30, maxval=500, group=group_logic)
minBarsBetweenTouches = input.int(3, "Min Bars Between Touches", minval=1, maxval=20, group=group_logic)

group_visual = "Visual"
showTrendlines = input.bool(true, "Show Trendlines", group=group_visual)
showTouchLabels = input.bool(true, "Show Touch Count Label", group=group_visual)
showAccumulation = input.bool(true, "Show Accumulation Label", group=group_visual)
showWatchDots = input.bool(true, "Show Watch Dots", group=group_visual)
showSignals = input.bool(true, "Show BUY/SELL Labels", group=group_visual)
showPivotMarks = input.bool(false, "Show HH/HL/LH/LL Pivot Marks", group=group_visual)

resColor = input.color(color.red, "Resistance Line Color", group=group_visual)
supColor = input.color(color.lime, "Support Line Color", group=group_visual)
accColor = input.color(color.orange, "Accumulation Color", group=group_visual)
lineWidth = input.int(2, "Trendline Width", minval=1, maxval=5, group=group_visual)

group_filters = "Filters"
showEma = input.bool(true, "Show EMA50 / EMA200", group=group_filters)
useEmaFilter = input.bool(false, "Use EMA Filter For Signals", group=group_filters)
showH1 = input.bool(true, "Show Previous H1 High/Low", group=group_filters)

group_patterns = "Patterns - Basic Detection"
showPatterns = input.bool(true, "Show Pattern Detection", group=group_patterns)
showHS = input.bool(true, "Show Head & Shoulders", group=group_patterns)
showIHS = input.bool(true, "Show Inverse Head & Shoulders", group=group_patterns)
showDoubleTop = input.bool(true, "Show Double Top", group=group_patterns)
showDoubleBottom = input.bool(true, "Show Double Bottom", group=group_patterns)
showPatternWatch = input.bool(true, "Show Pattern Watch Labels", group=group_patterns)
showPatternSignals = input.bool(true, "Show Pattern Break Signals", group=group_patterns)
patternTol = input.float(2.00, "Shoulder / Double Top-Bottom Tolerance", step=0.10, group=group_patterns)
neckBreakBuffer = input.float(0.50, "Neckline Break Buffer", step=0.10, group=group_patterns)
minPatternBars = input.int(8, "Min Bars Between Pattern Points", minval=3, maxval=100, group=group_patterns)
patternMaxWait = input.int(120, "Max Bars To Wait For Neckline Break", minval=10, maxval=500, group=group_patterns)
patternLineWidth = input.int(1, "Pattern Line Width", minval=1, maxval=4, group=group_patterns)

hsColor = input.color(color.red, "H&S Color", group=group_patterns)
ihsColor = input.color(color.lime, "Inverse H&S Color", group=group_patterns)
dtColor = input.color(color.orange, "Double Top Color", group=group_patterns)
dbColor = input.color(color.aqua, "Double Bottom Color", group=group_patterns)

// ================= EMA =================
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

plot(showEma ? ema50 : na, "EMA 50", color=color.red, linewidth=2)
plot(showEma ? ema200 : na, "EMA 200", color=color.white, linewidth=2)

emaBull = ema50 > ema200 or close > ema200
emaBear = ema50 < ema200 or close < ema200

// ================= H1 LEVELS - NO REPAINT =================
h1High = request.security(syminfo.tickerid, "60", high[1], lookahead=barmerge.lookahead_off)
h1Low  = request.security(syminfo.tickerid, "60", low[1], lookahead=barmerge.lookahead_off)

plot(showH1 ? h1High : na, "Previous H1 High", color=color.new(color.gray, 65), style=plot.style_stepline, linewidth=2)
plot(showH1 ? h1Low : na, "Previous H1 Low", color=color.new(color.gray, 65), style=plot.style_stepline, linewidth=2)

// ================= SOURCE =================
pivotHighSource = sourceMode == "Wick" ? high : close
pivotLowSource  = sourceMode == "Wick" ? low : close

touchHighSource = sourceMode == "Wick" ? high : close
touchLowSource  = sourceMode == "Wick" ? low : close

ph = ta.pivothigh(pivotHighSource, lookback, lookback)
pl = ta.pivotlow(pivotLowSource, lookback, lookback)

// ================= PIVOT MEMORY =================
var float high1 = na
var float high2 = na
var int high1x = na
var int high2x = na

var float low1 = na
var float low2 = na
var int low1x = na
var int low2x = na

var float prevHighPivot = na
var float prevLowPivot = na

// Pattern pivot sequence
var int[] pivType = array.new_int()
var int[] pivX = array.new_int()
var float[] pivY = array.new_float()

addPivot(_type, _x, _y) =>
    bool changed = false
    int n = array.size(pivType)

    if n == 0
        array.push(pivType, _type)
        array.push(pivX, _x)
        array.push(pivY, _y)
        changed := true
    else
        int lastIdx = n - 1
        int lastType = array.get(pivType, lastIdx)
        float lastY = array.get(pivY, lastIdx)

        if lastType == _type
            bool replacePivot = (_type == 1 and _y >= lastY) or (_type == -1 and _y <= lastY)
            if replacePivot
                array.set(pivX, lastIdx, _x)
                array.set(pivY, lastIdx, _y)
                changed := true
        else
            array.push(pivType, _type)
            array.push(pivX, _x)
            array.push(pivY, _y)
            changed := true

    if array.size(pivType) > 30
        array.shift(pivType)
        array.shift(pivX)
        array.shift(pivY)

    changed

bool newStructurePivot = false

// HH / LH label
if not na(ph)
    pivotX = bar_index - lookback
    pivotY = ph
    pivotText = na(prevHighPivot) ? "H" : pivotY > prevHighPivot ? "HH" : "LH"

    high2 := high1
    high2x := high1x
    high1 := pivotY
    high1x := pivotX
    prevHighPivot := pivotY

    newStructurePivot := addPivot(1, pivotX, pivotY)

    if showPivotMarks
        label.new(pivotX, pivotY, pivotText, style=label.style_label_down, color=color.new(resColor, 0), textcolor=color.white, size=size.tiny)

// HL / LL label
if not na(pl)
    pivotX = bar_index - lookback
    pivotY = pl
    pivotText = na(prevLowPivot) ? "L" : pivotY > prevLowPivot ? "HL" : "LL"

    low2 := low1
    low2x := low1x
    low1 := pivotY
    low1x := pivotX
    prevLowPivot := pivotY

    bool lowChanged = addPivot(-1, pivotX, pivotY)
    newStructurePivot := newStructurePivot or lowChanged

    if showPivotMarks
        label.new(pivotX, pivotY, pivotText, style=label.style_label_up, color=color.new(supColor, 0), textcolor=color.white, size=size.tiny)

// ================= TRENDLINES =================
var line resLine = na
var line supLine = na

resLineColor = showTrendlines ? color.new(resColor, 0) : color.new(resColor, 100)
supLineColor = showTrendlines ? color.new(supColor, 0) : color.new(supColor, 100)

if not na(high1) and not na(high2) and not na(high1x) and not na(high2x)
    line.delete(resLine)
    resLine := line.new(high2x, high2, high1x, high1, extend=extend.right, color=resLineColor, width=lineWidth)

if not na(low1) and not na(low2) and not na(low1x) and not na(low2x)
    line.delete(supLine)
    supLine := line.new(low2x, low2, low1x, low1, extend=extend.right, color=supLineColor, width=lineWidth)

// ================= LINE PRICES =================
resPrice = not na(resLine) ? line.get_price(resLine, bar_index) : na
supPrice = not na(supLine) ? line.get_price(supLine, bar_index) : na

// ================= TOUCH COUNT FUNCTION =================
countTouches(_line, _isResistance) =>
    int count = 0
    int lastTouchBar = na

    if not na(_line)
        for i = touchLookbackBars to 0
            x = bar_index - i

            if x >= 0
                linePrice = line.get_price(_line, x)

                if not na(linePrice)
                    src = _isResistance ? touchHighSource[i] : touchLowSource[i]
                    dist = math.abs(src - linePrice)
                    isTouch = dist <= touchTol
                    separated = na(lastTouchBar) or math.abs(x - lastTouchBar) >= minBarsBetweenTouches

                    if isTouch and separated
                        count += 1
                        lastTouchBar := x

    count

resTouches = countTouches(resLine, true)
supTouches = countTouches(supLine, false)

// ================= ACCUMULATION LOGIC =================
linesReady = not na(resPrice) and not na(supPrice)

upperLine = linesReady ? math.max(resPrice, supPrice) : na
lowerLine = linesReady ? math.min(resPrice, supPrice) : na

priceBetweenLines = linesReady and close < upperLine and close > lowerLine
enoughTouches = resTouches >= minTouches and supTouches >= minTouches

isAccumulation = linesReady and priceBetweenLines and enoughTouches

// ================= LABELS =================
var label touchLabel = na
var label accLabel = na

if barstate.islast
    label.delete(touchLabel)
    if showTouchLabels and linesReady
        touchLabel := label.new(
             bar_index,
             high,
             "Touches\nTop: " + str.tostring(resTouches) + "\nBottom: " + str.tostring(supTouches),
             style=label.style_label_left,
             color=color.new(color.black, 0),
             textcolor=color.white,
             size=size.small)

if barstate.islast
    label.delete(accLabel)
    if showAccumulation and isAccumulation
        accLabel := label.new(
             bar_index,
             close,
             "ACCUMULATION\nBreakout Watch",
             style=label.style_label_left,
             color=color.new(accColor, 0),
             textcolor=color.black,
             size=size.small)

// ================= BREAKOUT STATE =================
var bool accumulationArmed = false

var bool brokenUp = false
var bool brokenDown = false

var int brokenUpBar = na
var int brokenDownBar = na

if isAccumulation
    accumulationArmed := true

buyBreak = accumulationArmed and not na(resPrice) and ta.crossover(close, resPrice + minBreak)
sellBreak = accumulationArmed and not na(supPrice) and ta.crossunder(close, supPrice - minBreak)

if buyBreak
    brokenUp := true
    brokenDown := false
    brokenUpBar := bar_index
    brokenDownBar := na
    accumulationArmed := false

if sellBreak
    brokenDown := true
    brokenUp := false
    brokenDownBar := bar_index
    brokenUpBar := na
    accumulationArmed := false

if brokenUp and not na(brokenUpBar) and bar_index - brokenUpBar > maxBarsWait
    brokenUp := false
    brokenUpBar := na

if brokenDown and not na(brokenDownBar) and bar_index - brokenDownBar > maxBarsWait
    brokenDown := false
    brokenDownBar := na

// ================= RETEST ENTRY =================
buyFilterOk = not useEmaFilter or emaBull
sellFilterOk = not useEmaFilter or emaBear

buyRetest = brokenUp and not na(resPrice) and low <= resPrice + retestTol and close > resPrice and buyFilterOk
sellRetest = brokenDown and not na(supPrice) and high >= supPrice - retestTol and close < supPrice and sellFilterOk

if buyRetest
    brokenUp := false
    brokenUpBar := na

if sellRetest
    brokenDown := false
    brokenDownBar := na

// ================= VISUAL SIGNALS =================
plotshape(showSignals and buyRetest, title="BUY Retest", style=shape.labelup, location=location.belowbar, color=color.lime, text="BUY\nRETEST", textcolor=color.white, size=size.small)
plotshape(showSignals and sellRetest, title="SELL Retest", style=shape.labeldown, location=location.abovebar, color=color.red, text="SELL\nRETEST", textcolor=color.white, size=size.small)

plotchar(showWatchDots and brokenUp and not buyRetest, title="Buy Watch", char="•", location=location.belowbar, color=color.lime, size=size.tiny)
plotchar(showWatchDots and brokenDown and not sellRetest, title="Sell Watch", char="•", location=location.abovebar, color=color.red, size=size.tiny)

if buyBreak
    label.new(bar_index, low, "BUY WATCH\nAccumulation Breakout", style=label.style_label_up, color=color.lime, textcolor=color.white, size=size.tiny)

if sellBreak
    label.new(bar_index, high, "SELL WATCH\nAccumulation Breakdown", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.tiny)

// ====================================================================
// PATTERN DETECTION - BASIC PIVOT STRUCTURE
// ====================================================================

var bool activeHS = false
var bool activeIHS = false
var bool activeDT = false
var bool activeDB = false

var int hsRightX = na
var int ihsRightX = na
var int dtRightX = na
var int dbRightX = na

var int hsExpire = na
var int ihsExpire = na
var int dtExpire = na
var int dbExpire = na

var int lastHSSetupX = na
var int lastIHSSetupX = na
var int lastDTSetupX = na
var int lastDBSetupX = na

var line hsNeckLine = na
var line ihsNeckLine = na
var line dtNeckLine = na
var line dbNeckLine = na

// Detect new patterns only when a new confirmed pivot appears
if showPatterns and newStructurePivot
    int n = array.size(pivType)

    // ---------------- Head & Shoulders / Inverse H&S ----------------
    if n >= 5
        int t1 = array.get(pivType, n - 5)
        int t2 = array.get(pivType, n - 4)
        int t3 = array.get(pivType, n - 3)
        int t4 = array.get(pivType, n - 2)
        int t5 = array.get(pivType, n - 1)

        int x1 = array.get(pivX, n - 5)
        int x2 = array.get(pivX, n - 4)
        int x3 = array.get(pivX, n - 3)
        int x4 = array.get(pivX, n - 2)
        int x5 = array.get(pivX, n - 1)

        float y1 = array.get(pivY, n - 5)
        float y2 = array.get(pivY, n - 4)
        float y3 = array.get(pivY, n - 3)
        float y4 = array.get(pivY, n - 2)
        float y5 = array.get(pivY, n - 1)

        bool enoughBars = x5 - x1 >= minPatternBars

        bool hsStructure = showHS and t1 == 1 and t2 == -1 and t3 == 1 and t4 == -1 and t5 == 1
        bool hsShouldersOk = math.abs(y1 - y5) <= patternTol
        bool hsHeadOk = y3 > y1 + patternTol and y3 > y5 + patternTol
        bool hsCandidate = hsStructure and hsShouldersOk and hsHeadOk and enoughBars

        if hsCandidate and (na(lastHSSetupX) or x5 != lastHSSetupX)
            activeHS := true
            hsRightX := x5
            hsExpire := bar_index + patternMaxWait
            lastHSSetupX := x5

            line.delete(hsNeckLine)
            hsNeckLine := line.new(x2, y2, x4, y4, extend=extend.right, color=color.new(hsColor, 0), style=line.style_dashed, width=patternLineWidth)

            if showPatternWatch
                label.new(x5, y5, "H&S\nWatch", style=label.style_label_down, color=color.new(hsColor, 0), textcolor=color.white, size=size.tiny)

        bool ihsStructure = showIHS and t1 == -1 and t2 == 1 and t3 == -1 and t4 == 1 and t5 == -1
        bool ihsShouldersOk = math.abs(y1 - y5) <= patternTol
        bool ihsHeadOk = y3 < y1 - patternTol and y3 < y5 - patternTol
        bool ihsCandidate = ihsStructure and ihsShouldersOk and ihsHeadOk and enoughBars

        if ihsCandidate and (na(lastIHSSetupX) or x5 != lastIHSSetupX)
            activeIHS := true
            ihsRightX := x5
            ihsExpire := bar_index + patternMaxWait
            lastIHSSetupX := x5

            line.delete(ihsNeckLine)
            ihsNeckLine := line.new(x2, y2, x4, y4, extend=extend.right, color=color.new(ihsColor, 0), style=line.style_dashed, width=patternLineWidth)

            if showPatternWatch
                label.new(x5, y5, "Inverse H&S\nWatch", style=label.style_label_up, color=color.new(ihsColor, 0), textcolor=color.white, size=size.tiny)

    // ---------------- Double Top / Double Bottom ----------------
    if n >= 3
        int ta1 = array.get(pivType, n - 3)
        int ta2 = array.get(pivType, n - 2)
        int ta3 = array.get(pivType, n - 1)

        int xa1 = array.get(pivX, n - 3)
        int xa2 = array.get(pivX, n - 2)
        int xa3 = array.get(pivX, n - 1)

        float ya1 = array.get(pivY, n - 3)
        float ya2 = array.get(pivY, n - 2)
        float ya3 = array.get(pivY, n - 1)

        bool enoughBars3 = xa3 - xa1 >= minPatternBars

        bool dtCandidate = showDoubleTop and ta1 == 1 and ta2 == -1 and ta3 == 1 and math.abs(ya1 - ya3) <= patternTol and enoughBars3

        if dtCandidate and (na(lastDTSetupX) or xa3 != lastDTSetupX)
            activeDT := true
            dtRightX := xa3
            dtExpire := bar_index + patternMaxWait
            lastDTSetupX := xa3

            line.delete(dtNeckLine)
            dtNeckLine := line.new(xa2, ya2, bar_index, ya2, extend=extend.right, color=color.new(dtColor, 0), style=line.style_dotted, width=patternLineWidth)

            if showPatternWatch
                label.new(xa3, ya3, "Double Top\nWatch", style=label.style_label_down, color=color.new(dtColor, 0), textcolor=color.white, size=size.tiny)

        bool dbCandidate = showDoubleBottom and ta1 == -1 and ta2 == 1 and ta3 == -1 and math.abs(ya1 - ya3) <= patternTol and enoughBars3

        if dbCandidate and (na(lastDBSetupX) or xa3 != lastDBSetupX)
            activeDB := true
            dbRightX := xa3
            dbExpire := bar_index + patternMaxWait
            lastDBSetupX := xa3

            line.delete(dbNeckLine)
            dbNeckLine := line.new(xa2, ya2, bar_index, ya2, extend=extend.right, color=color.new(dbColor, 0), style=line.style_dotted, width=patternLineWidth)

            if showPatternWatch
                label.new(xa3, ya3, "Double Bottom\nWatch", style=label.style_label_up, color=color.new(dbColor, 0), textcolor=color.white, size=size.tiny)

// Expire active patterns
if activeHS and not na(hsExpire) and bar_index > hsExpire
    activeHS := false

if activeIHS and not na(ihsExpire) and bar_index > ihsExpire
    activeIHS := false

if activeDT and not na(dtExpire) and bar_index > dtExpire
    activeDT := false

if activeDB and not na(dbExpire) and bar_index > dbExpire
    activeDB := false

// Neckline prices
hsNeckPrice = activeHS and not na(hsNeckLine) ? line.get_price(hsNeckLine, bar_index) : na
ihsNeckPrice = activeIHS and not na(ihsNeckLine) ? line.get_price(ihsNeckLine, bar_index) : na
dtNeckPrice = activeDT and not na(dtNeckLine) ? line.get_price(dtNeckLine, bar_index) : na
dbNeckPrice = activeDB and not na(dbNeckLine) ? line.get_price(dbNeckLine, bar_index) : na

// Pattern confirmations
hsSellSignal = showPatterns and showHS and activeHS and not na(hsNeckPrice) and bar_index > hsRightX and close < hsNeckPrice - neckBreakBuffer
ihsBuySignal = showPatterns and showIHS and activeIHS and not na(ihsNeckPrice) and bar_index > ihsRightX and close > ihsNeckPrice + neckBreakBuffer

dtSellSignal = showPatterns and showDoubleTop and activeDT and not na(dtNeckPrice) and bar_index > dtRightX and close < dtNeckPrice - neckBreakBuffer
dbBuySignal = showPatterns and showDoubleBottom and activeDB and not na(dbNeckPrice) and bar_index > dbRightX and close > dbNeckPrice + neckBreakBuffer

if hsSellSignal
    activeHS := false
    if showPatternSignals
        label.new(bar_index, high, "H&S SELL\nNeckline Break", style=label.style_label_down, color=color.new(hsColor, 0), textcolor=color.white, size=size.small)

if ihsBuySignal
    activeIHS := false
    if showPatternSignals
        label.new(bar_index, low, "Inverse H&S BUY\nNeckline Break", style=label.style_label_up, color=color.new(ihsColor, 0), textcolor=color.white, size=size.small)

if dtSellSignal
    activeDT := false
    if showPatternSignals
        label.new(bar_index, high, "Double Top SELL\nNeckline Break", style=label.style_label_down, color=color.new(dtColor, 0), textcolor=color.white, size=size.small)

if dbBuySignal
    activeDB := false
    if showPatternSignals
        label.new(bar_index, low, "Double Bottom BUY\nNeckline Break", style=label.style_label_up, color=color.new(dbColor, 0), textcolor=color.white, size=size.small)

// ================= ALERTS =================
alertcondition(isAccumulation, title="Accumulation Detected", message="Accumulation detected between trendlines.")
alertcondition(buyBreak, title="Buy Watch - Accumulation Breakout", message="Accumulation breakout above resistance. Wait for retest.")
alertcondition(sellBreak, title="Sell Watch - Accumulation Breakdown", message="Accumulation breakdown below support. Wait for retest.")
alertcondition(buyRetest, title="BUY Retest Entry", message="BUY retest entry after accumulation breakout.")
alertcondition(sellRetest, title="SELL Retest Entry", message="SELL retest entry after accumulation breakdown.")

alertcondition(hsSellSignal, title="H&S SELL Signal", message="Head & Shoulders confirmed with neckline break.")
alertcondition(ihsBuySignal, title="Inverse H&S BUY Signal", message="Inverse Head & Shoulders confirmed with neckline break.")
alertcondition(dtSellSignal, title="Double Top SELL Signal", message="Double Top confirmed with neckline break.")
alertcondition(dbBuySignal, title="Double Bottom BUY Signal", message="Double Bottom confirmed with neckline break.")
````
