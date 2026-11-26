# SUPER INDIBOT kd v2

- url: https://www.tradingview.com/script/nLvLAbAA-SUPER-INDIBOT-kd-v2/
- type: indicator
- pine_id: PUB;9ceceefe2e8e41bfa378af93cb0165c9
- version: 1.0

## Description

SUPER INDIBOT – EMA Ribbon Trend Indicator v2 with profitiability tracking, free for everyone since everyone wanted it back.  Credit to the original owner kd who developed the original version.

SUPER INDIBOT is a trend-following indicator designed to help traders visualize market momentum and direction using a dynamic EMA Ribbon system. The indicator overlays directly on the chart and combines multiple Exponential Moving Averages (EMAs) to provide a clear view of short-term to mid-term trend structure.

The EMA Ribbon consists of 8 EMAs (5, 11, 15, 18, 21, 24, 28, and 34) which work together to show market flow and trend strength.

Key Features:

Displays an EMA Ribbon to identify trend direction.

Helps traders recognize trend continuation and possible reversals.

Customizable EMA lengths to fit different trading styles.

Designed to work well across multiple timeframes.

Optimized for traders who follow price structure and momentum.

When the EMAs are aligned and expanding, it indicates strong market momentum.
When the EMAs compress or cross, it may signal consolidation or a potential trend change.

SUPER INDIBOT is ideal for traders who want a clean visual representation of trend structure, making it easier to follow market movement and make more confident trading decisions.

## Source Code

````pine
//@version=6
indicator("SUPER INDIBOT", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=100)

// === INPUTS ===
showRibbon = input.bool(true, "Show EMA Ribbon", group="EMA Settings")
ema1Len = input.int(5, "EMA 1 Length", group="EMA Settings")
ema2Len = input.int(11, "EMA 2 Length", group="EMA Settings")
ema3Len = input.int(15, "EMA 3 Length", group="EMA Settings")
ema4Len = input.int(18, "EMA 4 Length", group="EMA Settings")
ema5Len = input.int(21, "EMA 5 Length", group="EMA Settings")
ema6Len = input.int(24, "EMA 6 Length", group="EMA Settings")
ema7Len = input.int(28, "EMA 7 Length", group="EMA Settings")
ema8Len = input.int(34, "EMA 8 Length", group="EMA Settings")
emaExtraLen = input.int(200, "Extra EMA Length", group="EMA Settings", tooltip="Visual reference only, not used in signals.")

tpCount = input.int(4, "Number of Take Profits", minval=1, maxval=4, group="Trade Management")
atrrMultiplier = input.float(2, "ATR Multiplier for SL", group="Trade Management")
// ─── UPDATED: default RR is now 1:1.5 ───
atrrTPFactor = input.float(1.5, "TP Multiplier (RR per TP)", minval=0.5, maxval=10.0, step=0.1, group="Trade Management", tooltip="TP1 = this × SL distance. 1.5 = 1:1.5 RR. TP2=2×, TP3=3×, TP4=4× of TP1.")
atrLen = input.int(14, "ATR Length", group="Trade Management")
showTP_SL_Lines = input.bool(true,"Show TP/SL Lines & Boxes", group="Trade Management")

// ─── HISTORICAL SIGNAL SETTINGS ───
showHistory     = input.bool(true, "Show Historical Signals", group="Historical Signals")
showHistOutcome = input.bool(true, "Show Historical TP/SL Hits (stacked)", group="Historical Signals")
showHistResult  = input.bool(true, "Show Win/Loss Marker (✔ / ✘)", group="Historical Signals")
historyOffset   = input.int(10, "Historical Label Offset (bars)", minval=0, maxval=50, group="Historical Signals")
stackGapATR     = input.float(0.35, "Stack Spacing (× ATR)", minval=0.05, maxval=3.0, step=0.05, group="Historical Signals")
historyBars     = input.int(7, "History Window (days)", minval=1, maxval=60, group="Historical Signals", tooltip="Rolling window — signals older than this are removed.")
resetHistory    = input.bool(false, "Reset Historical Signals", group="Historical Signals", tooltip="Toggle ON to clear all stored historical labels, then toggle OFF.")

// ─── STATS TABLE SETTINGS ───
showStats       = input.bool(true, "Show Weekly Stats Table", group="Stats Table")
statsPosition   = input.string("Bottom Left", "Stats Table Position", options=["Top Left","Top Right","Bottom Left","Bottom Right"], group="Stats Table")

showDashboard = input.bool(true, "Show Trend Analysis Dashboard", group="Dashboard Settings")
dashboardPosition = input.string("Bottom Right", "Dashboard Position", options=["Top Left","Top Right","Bottom Left","Bottom Right"], group="Dashboard Settings")
combinedTrendTF1 = input.string("5", "Trend Timeframe 1", options=["5","15","30","60","240","D"], group="Dashboard Settings")
combinedTrendTF2 = input.string("15", "Trend Timeframe 2", options=["5","15","30","60","240","D"], group="Dashboard Settings")
combinedTrendTF3 = input.string("30", "Trend Timeframe 3", options=["5","15","30","60","240","D"], group="Dashboard Settings")
widgetBorderColor = input.color(#000000, "Border Color", group="Widget Style")

showScreener = input.bool(true, "Show Screener", group="Screener Settings")
screenerPosition = input.string("Top Right","Screener Position", options=["Top Left","Top Right","Bottom Left","Bottom Right"], group="Screener Settings")
maxSymbols = input.int(9, "Max Symbols", minval=1, maxval=9, group="Screener Settings")
symbol1 = input.symbol("NSE:BANKNIFTY","Symbol 1", group="Screener Symbols")
symbol2 = input.symbol("NSE:NIFTY", "Symbol 2", group="Screener Symbols")
symbol3 = input.symbol("NSE:SBIN", "Symbol 3", group="Screener Symbols")
symbol4 = input.symbol("NSE:HCLTECH", "Symbol 4", group="Screener Symbols")
symbol5 = input.symbol("NSE:ICICIBANK","Symbol 5", group="Screener Symbols")
symbol6 = input.symbol("NSE:RELIANCE", "Symbol 6", group="Screener Symbols")
symbol7 = input.symbol("NSE:TATASTEEL","Symbol 7", group="Screener Symbols")
symbol8 = input.symbol("NSE:HAVELLS", "Symbol 8", group="Screener Symbols")
symbol9 = input.symbol("NSE:ITC", "Symbol 9", group="Screener Symbols")

// ─── HELPER FUNCTIONS ───────────────────────────────────────────────────────
getTablePosition(pos) =>
    switch pos
        "Top Left" => position.top_left
        "Top Right" => position.top_right
        "Bottom Left" => position.bottom_left
        "Bottom Right" => position.bottom_right
        => position.top_right

getSymbolName(fullSymbol) =>
    parts = str.split(fullSymbol, ":")
    array.size(parts) > 1 ? array.get(parts, 1) : fullSymbol

// ─── EMA CALCULATIONS ────────────────────────────────────────────────────────
ema1 = ta.ema(close, ema1Len)
ema2 = ta.ema(close, ema2Len)
ema3 = ta.ema(close, ema3Len)
ema4 = ta.ema(close, ema4Len)
ema5 = ta.ema(close, ema5Len)
ema6 = ta.ema(close, ema6Len)
ema7 = ta.ema(close, ema7Len)
ema8 = ta.ema(close, ema8Len)
emaExtra = ta.ema(close, emaExtraLen)

ribbonDir = ema8 < ema2

// ─── NON-REPAINT SIGNAL ──────────────────────────────────────────────────────
ema2_confirmed = ta.ema(close[1], ema2Len)
ema8_confirmed = ta.ema(close[1], ema8Len)
longSignal  = ta.crossover(ema2_confirmed, ema8_confirmed) and barstate.isconfirmed
shortSignal = ta.crossover(ema8_confirmed, ema2_confirmed) and barstate.isconfirmed

// ─── PLOTS ───────────────────────────────────────────────────────────────────
p1 = plot(ema1, color=showRibbon ? (ribbonDir ? #1573d4 : color.gray) : na, linewidth=2, title="EMA 1")
p2 = plot(ema2, color=showRibbon ? (ribbonDir ? #3096ff : color.gray) : na, linewidth=2, title="EMA 2")
plot(ema3, color=showRibbon ? (ribbonDir ? #57abff : color.gray) : na, linewidth=2, title="EMA 3")
plot(ema4, color=showRibbon ? (ribbonDir ? #85c2ff : color.gray) : na, linewidth=2, title="EMA 4")
plot(ema5, color=showRibbon ? (ribbonDir ? #9bcdff : color.gray) : na, linewidth=2, title="EMA 5")
plot(ema6, color=showRibbon ? (ribbonDir ? #b3d9ff : color.gray) : na, linewidth=2, title="EMA 6")
plot(ema7, color=showRibbon ? (ribbonDir ? #c9e5ff : color.gray) : na, linewidth=2, title="EMA 7")
p8 = plot(ema8, color=showRibbon ? (ribbonDir ? #dfecfb : color.gray) : na, linewidth=2, title="EMA 8")
plot(emaExtra, "Extra EMA", color.new(color.purple, 0), 2)
fill(p1, p8, color=showRibbon ? (ribbonDir ? color.new(#1573d4, 85) : color.new(color.gray, 85)) : na)

// ─── TRADE STATE VARIABLES (CURRENT TRADE) ───────────────────────────────────
var label signalLabel = na
var array<float> currentTPLevels = array.new<float>()
var array<bool> tpHitStatus = array.new<bool>()
var float currentSLLevel = na
var int tradeDirection = 0
var bool tradeActive = false
var int tradeEndX = na
var array<line> tpLines = array.new<line>()
var line slLine = na
var line entryLine = na
var array<label> rightLabels = array.new<label>()
var float plotEntryLevelVal = na
var float plotSLLevelVal = na
var float plotTP4LevelVal = na
var box tpBox = na
var box slBox = na

// ─── HISTORICAL SIGNAL STORAGE ───────────────────────────────────────────────
var array<label> histDotLabels   = array.new<label>()
var array<int>   histDirection   = array.new<int>()
var array<int>   histEntryBar    = array.new<int>()
var array<int>   histEntryTime   = array.new<int>()
var array<float> histEntryPrice  = array.new<float>()
var array<float> histSLPrice     = array.new<float>()
var array<float> histSignalY     = array.new<float>()
var array<int>   histStackCount  = array.new<int>()
var array<label> histSLLabels    = array.new<label>()
var array<bool>  histSLHit       = array.new<bool>()
var array<float> histTP1 = array.new<float>()
var array<float> histTP2 = array.new<float>()
var array<float> histTP3 = array.new<float>()
var array<float> histTP4 = array.new<float>()
var array<label> histTP1Lbl = array.new<label>()
var array<label> histTP2Lbl = array.new<label>()
var array<label> histTP3Lbl = array.new<label>()
var array<label> histTP4Lbl = array.new<label>()
var array<bool>  histTP1Hit = array.new<bool>()
var array<bool>  histTP2Hit = array.new<bool>()
var array<bool>  histTP3Hit = array.new<bool>()
var array<bool>  histTP4Hit = array.new<bool>()
var array<bool>  histActive = array.new<bool>()
var array<label> histResultLbl = array.new<label>()
var array<bool>  histWon     = array.new<bool>()

atr = ta.atr(atrLen)

// ─── RESET HISTORY ───────────────────────────────────────────────────────────
if resetHistory
    for i = 0 to array.size(histDotLabels) - 1
        label.delete(array.get(histDotLabels, i))
    for i = 0 to array.size(histSLLabels) - 1
        if not na(array.get(histSLLabels, i))
            label.delete(array.get(histSLLabels, i))
    for i = 0 to array.size(histTP1Lbl) - 1
        if not na(array.get(histTP1Lbl, i))
            label.delete(array.get(histTP1Lbl, i))
    for i = 0 to array.size(histTP2Lbl) - 1
        if not na(array.get(histTP2Lbl, i))
            label.delete(array.get(histTP2Lbl, i))
    for i = 0 to array.size(histTP3Lbl) - 1
        if not na(array.get(histTP3Lbl, i))
            label.delete(array.get(histTP3Lbl, i))
    for i = 0 to array.size(histTP4Lbl) - 1
        if not na(array.get(histTP4Lbl, i))
            label.delete(array.get(histTP4Lbl, i))
    for i = 0 to array.size(histResultLbl) - 1
        if not na(array.get(histResultLbl, i))
            label.delete(array.get(histResultLbl, i))

    array.clear(histDotLabels)
    array.clear(histDirection)
    array.clear(histEntryBar)
    array.clear(histEntryTime)
    array.clear(histEntryPrice)
    array.clear(histSLPrice)
    array.clear(histSignalY)
    array.clear(histStackCount)
    array.clear(histSLLabels)
    array.clear(histSLHit)
    array.clear(histTP1)
    array.clear(histTP2)
    array.clear(histTP3)
    array.clear(histTP4)
    array.clear(histTP1Lbl)
    array.clear(histTP2Lbl)
    array.clear(histTP3Lbl)
    array.clear(histTP4Lbl)
    array.clear(histTP1Hit)
    array.clear(histTP2Hit)
    array.clear(histTP3Hit)
    array.clear(histTP4Hit)
    array.clear(histActive)
    array.clear(histResultLbl)
    array.clear(histWon)

// ─── SIGNAL HANDLING ─────────────────────────────────────────────────────────
if longSignal or shortSignal
    if not na(signalLabel)
        label.delete(signalLabel)
    if array.size(tpLines) > 0
        for i = 0 to array.size(tpLines) - 1
            line.delete(array.get(tpLines, i))
        array.clear(tpLines)
    if not na(slLine)
        line.delete(slLine)
        slLine := na
    if not na(entryLine)
        line.delete(entryLine)
        entryLine := na
    if array.size(rightLabels) > 0
        for i = 0 to array.size(rightLabels) - 1
            label.delete(array.get(rightLabels, i))
        array.clear(rightLabels)
    if not na(tpBox)
        box.delete(tpBox)
        tpBox := na
    if not na(slBox)
        box.delete(slBox)
        slBox := na

    tradeActive := true
    tradeEndX := na
    tradeDirection := longSignal ? 1 : -1
    entry = close
    currentSLLevel := entry - tradeDirection * atr * atrrMultiplier
    array.clear(currentTPLevels)
    array.clear(tpHitStatus)
    for i = 1 to tpCount
        tp = entry + tradeDirection * atr * atrrMultiplier * atrrTPFactor * i
        array.push(currentTPLevels, tp)
        array.push(tpHitStatus, false)
    plotEntryLevelVal := entry
    plotSLLevelVal := currentSLLevel
    plotTP4LevelVal := array.size(currentTPLevels) >= 4 ? array.get(currentTPLevels, 3) : na

    if showHistory
        histY = tradeDirection > 0 ? low - atr * 0.5 : high + atr * 0.5
        dot = label.new(
             x = bar_index - historyOffset,
             y = histY,
             text = tradeDirection > 0 ? "B" : "S",
             style = label.style_label_center,
             color = tradeDirection > 0 ? color.new(#00c853, 20) : color.new(#d50000, 20),
             textcolor = color.white,
             size = size.tiny,
             tooltip = (tradeDirection > 0 ? "BUY @ " : "SELL @ ") + str.tostring(entry, format.mintick))

        array.push(histDotLabels, dot)
        array.push(histDirection, tradeDirection)
        array.push(histEntryBar, bar_index)
        array.push(histEntryTime, time)
        array.push(histEntryPrice, entry)
        array.push(histSLPrice, currentSLLevel)
        array.push(histSignalY, histY)
        array.push(histStackCount, 0)
        array.push(histSLLabels, na)
        array.push(histSLHit, false)
        array.push(histTP1, array.size(currentTPLevels) >= 1 ? array.get(currentTPLevels, 0) : na)
        array.push(histTP2, array.size(currentTPLevels) >= 2 ? array.get(currentTPLevels, 1) : na)
        array.push(histTP3, array.size(currentTPLevels) >= 3 ? array.get(currentTPLevels, 2) : na)
        array.push(histTP4, array.size(currentTPLevels) >= 4 ? array.get(currentTPLevels, 3) : na)
        array.push(histTP1Lbl, na)
        array.push(histTP2Lbl, na)
        array.push(histTP3Lbl, na)
        array.push(histTP4Lbl, na)
        array.push(histTP1Hit, false)
        array.push(histTP2Hit, false)
        array.push(histTP3Hit, false)
        array.push(histTP4Hit, false)
        array.push(histActive, true)
        array.push(histResultLbl, na)
        array.push(histWon, false)

    signalLabel := label.new(bar_index,
         y = tradeDirection > 0 ? low : high,
         text = tradeDirection > 0 ? "BUY" : "SELL",
         style = tradeDirection > 0 ? label.style_label_up : label.style_label_down,
         color = tradeDirection > 0 ? color.green : color.red,
         textcolor = color.white,
         size = size.small)

    int xR = bar_index + 10
    if showTP_SL_Lines
        array.push(rightLabels, label.new(xR, entry, "ENTRY " + str.tostring(entry, format.mintick),
             style=label.style_label_left, color=#fff100, textcolor=color.black, size=size.normal))
        entryLine := line.new(bar_index, entry, xR, entry, color=#fff100, style=line.style_solid, width=2)
        for i = 0 to array.size(currentTPLevels) - 1
            yVal = array.get(currentTPLevels, i)
            array.push(tpLines, line.new(bar_index, yVal, xR, yVal, color=#00ff00, style=line.style_solid, width=2))
            rrLabel = str.tostring((i+1) * atrrTPFactor, "#.##") + "R"
            array.push(rightLabels, label.new(xR, yVal, "TP " + str.tostring(i+1) + " (" + rrLabel + ") : " + str.tostring(yVal, format.mintick),
                 style=label.style_label_left, color=#00ff00, textcolor=color.black, size=size.normal))
        slLine := line.new(bar_index, currentSLLevel, xR, currentSLLevel, color=color.red, style=line.style_solid, width=2)
        array.push(rightLabels, label.new(xR, currentSLLevel, "SL (1R) : " + str.tostring(currentSLLevel, format.mintick),
             style=label.style_label_left, color=color.red, textcolor=color.white, size=size.normal))
        if not na(plotTP4LevelVal)
            tpBox := box.new(left=bar_index, top=math.max(entry, plotTP4LevelVal),
                 bottom=math.min(entry, plotTP4LevelVal), right=xR,
                 bgcolor=color.new(#089981, 80), border_color=color.rgb(0,0,0,100))
        if not na(plotSLLevelVal)
            slBox := box.new(left=bar_index, top=math.max(entry, plotSLLevelVal),
                 bottom=math.min(entry, plotSLLevelVal), right=xR,
                 bgcolor=color.new(#f23645, 80), border_color=color.rgb(0,0,0,100))

// ─── TRADE MANAGEMENT (current signal) ───────────────────────────────────────
if tradeActive and showTP_SL_Lines
    xRC = bar_index + 10
    if not na(entryLine)
        line.set_x2(entryLine, xRC)
    for i = 0 to array.size(tpLines) - 1
        if not na(array.get(tpLines, i))
            line.set_x2(array.get(tpLines, i), xRC)
    if not na(slLine)
        line.set_x2(slLine, xRC)
    for i = 0 to array.size(rightLabels) - 1
        if not na(array.get(rightLabels, i))
            label.set_x(array.get(rightLabels, i), xRC)
    if not na(tpBox)
        box.set_right(tpBox, xRC)
    if not na(slBox)
        box.set_right(slBox, xRC)

slHit = tradeActive and ((tradeDirection > 0 and low <= currentSLLevel) or (tradeDirection < 0 and high >= currentSLLevel))
bool allTPsHit = true
for i = 0 to array.size(currentTPLevels) - 1
    if i < array.size(tpHitStatus)
        tpLevel = array.get(currentTPLevels, i)
        if (tradeDirection > 0 and high >= tpLevel) or (tradeDirection < 0 and low <= tpLevel)
            array.set(tpHitStatus, i, true)
        if not array.get(tpHitStatus, i)
            allTPsHit := false
    else
        allTPsHit := false
        break

if tradeActive and (slHit or allTPsHit)
    tradeActive := false
    tradeEndX := bar_index

if not tradeActive and not na(tradeEndX) and showTP_SL_Lines
    fxR = tradeEndX + 10
    if not na(entryLine) and line.get_x2(entryLine) != fxR
        line.set_x2(entryLine, fxR)
    for i = 0 to array.size(tpLines) - 1
        if not na(array.get(tpLines, i)) and line.get_x2(array.get(tpLines, i)) != fxR
            line.set_x2(array.get(tpLines, i), fxR)
    if not na(slLine) and line.get_x2(slLine) != fxR
        line.set_x2(slLine, fxR)
    for i = 0 to array.size(rightLabels) - 1
        if not na(array.get(rightLabels, i)) and label.get_x(array.get(rightLabels, i)) != fxR
            label.set_x(array.get(rightLabels, i), fxR)
    if not na(tpBox) and box.get_right(tpBox) != fxR
        box.set_right(tpBox, fxR)
    if not na(slBox)
        box.set_right(slBox, fxR)

// ─── HISTORICAL TP / SL STACKED OUTCOME TAGS + WIN/LOSS MARKER ───────────────
if showHistory and showHistOutcome and array.size(histDotLabels) > 0
    for i = 0 to array.size(histDotLabels) - 1
        if array.get(histActive, i)
            dir      = array.get(histDirection, i)
            entryBar = array.get(histEntryBar, i)
            slPrice  = array.get(histSLPrice, i)
            baseY    = array.get(histSignalY, i)
            tp1      = array.get(histTP1, i)
            tp2      = array.get(histTP2, i)
            tp3      = array.get(histTP3, i)
            tp4      = array.get(histTP4, i)
            stackN   = array.get(histStackCount, i)
            gap      = atr * stackGapATR

            yOffset = dir > 0 ? (stackN + 1) * gap : -((stackN + 1) * gap)
            nextY   = baseY + yOffset

            if bar_index > entryBar
                anyTPHit = array.get(histTP1Hit, i) or array.get(histTP2Hit, i) or array.get(histTP3Hit, i) or array.get(histTP4Hit, i)
                slTouch  = (dir > 0 and low <= slPrice) or (dir < 0 and high >= slPrice)

                if not array.get(histTP1Hit, i) and not na(tp1) and ((dir > 0 and high >= tp1) or (dir < 0 and low <= tp1))
                    array.set(histTP1Hit, i, true)
                    lbl = label.new(entryBar - historyOffset, nextY,
                         text = "TP1", style = label.style_label_center,
                         color = color.new(#00c853, 10), textcolor = color.white, size = size.tiny,
                         tooltip = "TP1 hit @ " + str.tostring(tp1, format.mintick))
                    array.set(histTP1Lbl, i, lbl)
                    stackN := stackN + 1
                    yOffset := dir > 0 ? (stackN + 1) * gap : -((stackN + 1) * gap)
                    nextY := baseY + yOffset
                if not array.get(histTP2Hit, i) and not na(tp2) and ((dir > 0 and high >= tp2) or (dir < 0 and low <= tp2))
                    array.set(histTP2Hit, i, true)
                    lbl = label.new(entryBar - historyOffset, nextY,
                         text = "TP2", style = label.style_label_center,
                         color = color.new(#00c853, 10), textcolor = color.white, size = size.tiny,
                         tooltip = "TP2 hit @ " + str.tostring(tp2, format.mintick))
                    array.set(histTP2Lbl, i, lbl)
                    stackN := stackN + 1
                    yOffset := dir > 0 ? (stackN + 1) * gap : -((stackN + 1) * gap)
                    nextY := baseY + yOffset
                if not array.get(histTP3Hit, i) and not na(tp3) and ((dir > 0 and high >= tp3) or (dir < 0 and low <= tp3))
                    array.set(histTP3Hit, i, true)
                    lbl = label.new(entryBar - historyOffset, nextY,
                         text = "TP3", style = label.style_label_center,
                         color = color.new(#00c853, 10), textcolor = color.white, size = size.tiny,
                         tooltip = "TP3 hit @ " + str.tostring(tp3, format.mintick))
                    array.set(histTP3Lbl, i, lbl)
                    stackN := stackN + 1
                    yOffset := dir > 0 ? (stackN + 1) * gap : -((stackN + 1) * gap)
                    nextY := baseY + yOffset
                if not array.get(histTP4Hit, i) and not na(tp4) and ((dir > 0 and high >= tp4) or (dir < 0 and low <= tp4))
                    array.set(histTP4Hit, i, true)
                    lbl = label.new(entryBar - historyOffset, nextY,
                         text = "TP4", style = label.style_label_center,
                         color = color.new(#00c853, 10), textcolor = color.white, size = size.tiny,
                         tooltip = "TP4 hit @ " + str.tostring(tp4, format.mintick))
                    array.set(histTP4Lbl, i, lbl)
                    stackN := stackN + 1

                array.set(histStackCount, i, stackN)

                anyTPHit := array.get(histTP1Hit, i) or array.get(histTP2Hit, i) or array.get(histTP3Hit, i) or array.get(histTP4Hit, i)
                allTPsHitNow = array.get(histTP1Hit, i) and array.get(histTP2Hit, i) and array.get(histTP3Hit, i) and array.get(histTP4Hit, i)

                if allTPsHitNow
                    array.set(histActive, i, false)
                    array.set(histWon, i, true)
                    label.set_color(array.get(histDotLabels, i), color.new(color.gray, 40))
                    if showHistResult
                        resY = dir > 0 ? baseY + (stackN + 1) * gap : -((stackN + 1) * gap) + baseY
                        resLbl = label.new(entryBar - historyOffset, resY,
                             text = "✔", style = label.style_label_center,
                             color = color.new(#00c853, 0), textcolor = color.white, size = size.small,
                             tooltip = "WIN — all TPs hit")
                        array.set(histResultLbl, i, resLbl)
                else if slTouch
                    if anyTPHit
                        array.set(histActive, i, false)
                        array.set(histWon, i, true)
                        label.set_color(array.get(histDotLabels, i), color.new(color.gray, 40))
                        if showHistResult
                            resY = dir > 0 ? baseY + (stackN + 1) * gap : -((stackN + 1) * gap) + baseY
                            resLbl = label.new(entryBar - historyOffset, resY,
                                 text = "✔", style = label.style_label_center,
                                 color = color.new(#00c853, 0), textcolor = color.white, size = size.small,
                                 tooltip = "WIN (partial) — SL reached after TP1+ was hit")
                            array.set(histResultLbl, i, resLbl)
                    else
                        array.set(histSLHit, i, true)
                        array.set(histActive, i, false)
                        array.set(histWon, i, false)
                        slLbl = label.new(entryBar - historyOffset, nextY,
                             text = "SL", style = label.style_label_center,
                             color = color.new(#d50000, 10), textcolor = color.white, size = size.tiny,
                             tooltip = "SL hit @ " + str.tostring(slPrice, format.mintick))
                        array.set(histSLLabels, i, slLbl)
                        stackN := stackN + 1
                        array.set(histStackCount, i, stackN)
                        label.set_color(array.get(histDotLabels, i), color.new(color.gray, 60))
                        if showHistResult
                            lossY = dir > 0 ? baseY + (stackN + 1) * gap : -((stackN + 1) * gap) + baseY
                            resLbl = label.new(entryBar - historyOffset, lossY,
                                 text = "✘", style = label.style_label_center,
                                 color = color.new(#d50000, 0), textcolor = color.white, size = size.small,
                                 tooltip = "LOSS — SL @ " + str.tostring(slPrice, format.mintick))
                            array.set(histResultLbl, i, resLbl)

// ─── ROLLING 1-WEEK PRUNE ────────────────────────────────────────────────────
if array.size(histDotLabels) > 0
    cutoffMs = historyBars * 86400000
    keepPruning = true
    while keepPruning and array.size(histDotLabels) > 0
        oldTime = array.get(histEntryTime, 0)
        if (time - oldTime) > cutoffMs
            oldDot = array.shift(histDotLabels)
            label.delete(oldDot)
            oldSL = array.shift(histSLLabels)
            if not na(oldSL)
                label.delete(oldSL)
            oldTP1 = array.shift(histTP1Lbl)
            if not na(oldTP1)
                label.delete(oldTP1)
            oldTP2 = array.shift(histTP2Lbl)
            if not na(oldTP2)
                label.delete(oldTP2)
            oldTP3 = array.shift(histTP3Lbl)
            if not na(oldTP3)
                label.delete(oldTP3)
            oldTP4 = array.shift(histTP4Lbl)
            if not na(oldTP4)
                label.delete(oldTP4)
            oldRes = array.shift(histResultLbl)
            if not na(oldRes)
                label.delete(oldRes)
            array.shift(histDirection)
            array.shift(histEntryBar)
            array.shift(histEntryTime)
            array.shift(histEntryPrice)
            array.shift(histSLPrice)
            array.shift(histSignalY)
            array.shift(histStackCount)
            array.shift(histSLHit)
            array.shift(histTP1)
            array.shift(histTP2)
            array.shift(histTP3)
            array.shift(histTP4)
            array.shift(histTP1Hit)
            array.shift(histTP2Hit)
            array.shift(histTP3Hit)
            array.shift(histTP4Hit)
            array.shift(histActive)
            array.shift(histWon)
        else
            keepPruning := false

alertcondition(longSignal, title="Long EMA Cross", message="Long EMA Crossover Signal")
alertcondition(shortSignal, title="Short EMA Cross", message="Short Crossover Signal")

// ─── SECURITY REQUESTS ───────────────────────────────────────────────────────
[s1e2, s1e8] = request.security(symbol1, timeframe.period, [ta.ema(close, ema2Len), ta.ema(close, ema8Len)], lookahead=barmerge.lookahead_off)
[s2e2, s2e8] = request.security(symbol2, timeframe.period, [ta.ema(close, ema2Len), ta.ema(close, ema8Len)], lookahead=barmerge.lookahead_off)
[s3e2, s3e8] = request.security(symbol3, timeframe.period, [ta.ema(close, ema2Len), ta.ema(close, ema8Len)], lookahead=barmerge.lookahead_off)
[s4e2, s4e8] = request.security(symbol4, timeframe.period, [ta.ema(close, ema2Len), ta.ema(close, ema8Len)], lookahead=barmerge.lookahead_off)
[s5e2, s5e8] = request.security(symbol5, timeframe.period, [ta.ema(close, ema2Len), ta.ema(close, ema8Len)], lookahead=barmerge.lookahead_off)
[s6e2, s6e8] = request.security(symbol6, timeframe.period, [ta.ema(close, ema2Len), ta.ema(close, ema8Len)], lookahead=barmerge.lookahead_off)
[s7e2, s7e8] = request.security(symbol7, timeframe.period, [ta.ema(close, ema2Len), ta.ema(close, ema8Len)], lookahead=barmerge.lookahead_off)
[s8e2, s8e8] = request.security(symbol8, timeframe.period, [ta.ema(close, ema2Len), ta.ema(close, ema8Len)], lookahead=barmerge.lookahead_off)
[s9e2, s9e8] = request.security(symbol9, timeframe.period, [ta.ema(close, ema2Len), ta.ema(close, ema8Len)], lookahead=barmerge.lookahead_off)

// MTF dashboard data
[tf5e2, tf5e8]   = request.security(syminfo.tickerid, "5",   [ta.ema(close, ema2Len), ta.ema(close, ema8Len)], lookahead=barmerge.lookahead_off)
[tf15e2, tf15e8] = request.security(syminfo.tickerid, "15",  [ta.ema(close, ema2Len), ta.ema(close, ema8Len)], lookahead=barmerge.lookahead_off)
[tf30e2, tf30e8] = request.security(syminfo.tickerid, "30",  [ta.ema(close, ema2Len), ta.ema(close, ema8Len)], lookahead=barmerge.lookahead_off)
[tf60e2, tf60e8] = request.security(syminfo.tickerid, "60",  [ta.ema(close, ema2Len), ta.ema(close, ema8Len)], lookahead=barmerge.lookahead_off)
[tf4he2, tf4he8] = request.security(syminfo.tickerid, "240", [ta.ema(close, ema2Len), ta.ema(close, ema8Len)], lookahead=barmerge.lookahead_off)
[tfDe2, tfDe8]   = request.security(syminfo.tickerid, "D",   [ta.ema(close, ema2Len), ta.ema(close, ema8Len)], lookahead=barmerge.lookahead_off)

// Crossovers
s1Long = ta.crossover(s1e2, s1e8)
s1Short = ta.crossover(s1e8, s1e2)
s2Long = ta.crossover(s2e2, s2e8)
s2Short = ta.crossover(s2e8, s2e2)
s3Long = ta.crossover(s3e2, s3e8)
s3Short = ta.crossover(s3e8, s3e2)
s4Long = ta.crossover(s4e2, s4e8)
s4Short = ta.crossover(s4e8, s4e2)
s5Long = ta.crossover(s5e2, s5e8)
s5Short = ta.crossover(s5e8, s5e2)
s6Long = ta.crossover(s6e2, s6e8)
s6Short = ta.crossover(s6e8, s6e2)
s7Long = ta.crossover(s7e2, s7e8)
s7Short = ta.crossover(s7e8, s7e2)
s8Long = ta.crossover(s8e2, s8e8)
s8Short = ta.crossover(s8e8, s8e2)
s9Long = ta.crossover(s9e2, s9e8)
s9Short = ta.crossover(s9e8, s9e2)

// ─── SCREENER TABLE ──────────────────────────────────────────────────────────
var table screenerTable = table.new(getTablePosition(screenerPosition), 2, 10,
     bgcolor=color.new(color.rgb(33,33,33), 80),
     border_width=2, border_color=color.new(widgetBorderColor, 0),
     frame_width=3, frame_color=color.new(widgetBorderColor, 0))

var array<string> symNames = array.new<string>()
var array<float>  e2Vals   = array.new<float>()
var array<float>  e8Vals   = array.new<float>()
var array<bool>   lCrosses = array.new<bool>()
var array<bool>   sCrosses = array.new<bool>()

if showScreener and barstate.islast
    table.cell(screenerTable, 0, 0, "SCREENER", text_color=color.black, bgcolor=#03f7ff, text_size=size.small, text_halign=text.align_center)
    table.merge_cells(screenerTable, 0, 0, 1, 0)

    array.clear(symNames)
    array.clear(e2Vals)
    array.clear(e8Vals)
    array.clear(lCrosses)
    array.clear(sCrosses)

    array.push(symNames, getSymbolName(symbol1))
    array.push(symNames, getSymbolName(symbol2))
    array.push(symNames, getSymbolName(symbol3))
    array.push(symNames, getSymbolName(symbol4))
    array.push(symNames, getSymbolName(symbol5))
    array.push(symNames, getSymbolName(symbol6))
    array.push(symNames, getSymbolName(symbol7))
    array.push(symNames, getSymbolName(symbol8))
    array.push(symNames, getSymbolName(symbol9))

    array.push(e2Vals, s1e2)
    array.push(e2Vals, s2e2)
    array.push(e2Vals, s3e2)
    array.push(e2Vals, s4e2)
    array.push(e2Vals, s5e2)
    array.push(e2Vals, s6e2)
    array.push(e2Vals, s7e2)
    array.push(e2Vals, s8e2)
    array.push(e2Vals, s9e2)

    array.push(e8Vals, s1e8)
    array.push(e8Vals, s2e8)
    array.push(e8Vals, s3e8)
    array.push(e8Vals, s4e8)
    array.push(e8Vals, s5e8)
    array.push(e8Vals, s6e8)
    array.push(e8Vals, s7e8)
    array.push(e8Vals, s8e8)
    array.push(e8Vals, s9e8)

    array.push(lCrosses, s1Long)
    array.push(lCrosses, s2Long)
    array.push(lCrosses, s3Long)
    array.push(lCrosses, s4Long)
    array.push(lCrosses, s5Long)
    array.push(lCrosses, s6Long)
    array.push(lCrosses, s7Long)
    array.push(lCrosses, s8Long)
    array.push(lCrosses, s9Long)

    array.push(sCrosses, s1Short)
    array.push(sCrosses, s2Short)
    array.push(sCrosses, s3Short)
    array.push(sCrosses, s4Short)
    array.push(sCrosses, s5Short)
    array.push(sCrosses, s6Short)
    array.push(sCrosses, s7Short)
    array.push(sCrosses, s8Short)
    array.push(sCrosses, s9Short)

    for i = 0 to math.min(maxSymbols, 9) - 1
        isBull = array.get(e8Vals, i) < array.get(e2Vals, i)
        isLong = array.get(lCrosses, i)
        isShort = array.get(sCrosses, i)
        sig = isLong ? "Long" : isShort ? "Short" : isBull ? "Bullish" : "Bearish"
        sigClr = isLong ? color.new(#00ff00,0) : isShort ? color.new(#ff0000,0) : isBull ? color.new(#ffff00,0) : color.new(#ff6600,0)
        table.cell(screenerTable, 0, i+1, array.get(symNames, i), text_color=color.black, bgcolor=#03f7ff, text_size=size.small)
        table.cell(screenerTable, 1, i+1, sig, text_color=color.rgb(0,0,0), bgcolor=sigClr, text_size=size.small)

// ─── WEEKLY STATS TABLE (with RR and break-even) ─────────────────────────────
var table statsTable = table.new(getTablePosition(statsPosition), 3, 11,
     bgcolor=color.new(color.rgb(33,33,33), 80),
     border_width=2, border_color=color.new(widgetBorderColor, 0),
     frame_width=3, frame_color=color.new(widgetBorderColor, 0))

if showStats and barstate.islast
    tp1Count = 0
    tp2Count = 0
    tp3Count = 0
    tp4Count = 0
    slCount  = 0
    winCount = 0
    lossCount = 0

    totalSignals = array.size(histDotLabels)

    for i = 0 to totalSignals - 1
        hit1 = array.get(histTP1Hit, i)
        hit2 = array.get(histTP2Hit, i)
        hit3 = array.get(histTP3Hit, i)
        hit4 = array.get(histTP4Hit, i)
        won  = array.get(histWon, i)
        lost = array.get(histSLHit, i)

        if hit1
            tp1Count += 1
        if hit2
            tp2Count += 1
        if hit3
            tp3Count += 1
        if hit4
            tp4Count += 1
        if lost
            slCount += 1
        if won
            winCount += 1
        else if lost
            lossCount += 1

    totalClosed = winCount + lossCount
    overallWinRate = totalClosed > 0 ? (winCount / totalClosed) * 100 : 0.0

    // % of ALL trades that reached each level
    tp1Pct = totalSignals > 0 ? (tp1Count / totalSignals) * 100 : 0.0
    tp2Pct = totalSignals > 0 ? (tp2Count / totalSignals) * 100 : 0.0
    tp3Pct = totalSignals > 0 ? (tp3Count / totalSignals) * 100 : 0.0
    tp4Pct = totalSignals > 0 ? (tp4Count / totalSignals) * 100 : 0.0
    slPct  = totalSignals > 0 ? (slCount  / totalSignals) * 100 : 0.0

    // ─── RR and break-even calculations ───
    // The SL is always 1R. TP1 is at atrrTPFactor × SL distance = atrrTPFactor R.
    rrRatio        = atrrTPFactor                             // e.g. 1.5 for 1:1.5
    breakevenRate  = (1.0 / (1.0 + rrRatio)) * 100.0          // %
    // Expectancy using overall win rate at TP1-equivalent RR
    wr             = overallWinRate / 100.0
    expectancy     = (wr * rrRatio) - ((1.0 - wr) * 1.0)      // in R per trade

    table.cell(statsTable, 0, 0, "WEEKLY STATS", text_color=color.black, bgcolor=#03f7ff, text_size=size.small, text_halign=text.align_center)
    table.merge_cells(statsTable, 0, 0, 2, 0)

    grayBg  = color.new(color.gray, 60)
    greenBg = color.new(#00c853, 0)
    redBg   = color.new(#d50000, 0)
    cyanBg  = color.new(#03f7ff, 40)

    // RR info row
    table.cell(statsTable, 0, 1, "RR", text_color=color.white, bgcolor=color.new(color.gray, 30), text_size=size.small, text_halign=text.align_left)
    table.cell(statsTable, 1, 1, "1 : " + str.tostring(rrRatio, "#.##"), text_color=color.black, bgcolor=cyanBg, text_size=size.small, text_halign=text.align_center)
    table.cell(statsTable, 2, 1, "BE " + str.tostring(breakevenRate, "#.#") + "%", text_color=color.black, bgcolor=cyanBg, text_size=size.small, text_halign=text.align_center)

    // Header row
    table.cell(statsTable, 0, 2, "Level", text_color=color.white, bgcolor=color.new(color.gray, 30), text_size=size.small, text_halign=text.align_left)
    table.cell(statsTable, 1, 2, "Hits",  text_color=color.white, bgcolor=color.new(color.gray, 30), text_size=size.small, text_halign=text.align_center)
    table.cell(statsTable, 2, 2, "Win %", text_color=color.white, bgcolor=color.new(color.gray, 30), text_size=size.small, text_halign=text.align_center)

    // TP1 row
    table.cell(statsTable, 0, 3, "TP1 (" + str.tostring(rrRatio, "#.##") + "R)", text_color=color.white, bgcolor=grayBg, text_size=size.small, text_halign=text.align_left)
    table.cell(statsTable, 1, 3, str.tostring(tp1Count), text_color=color.black, bgcolor=greenBg, text_size=size.small, text_halign=text.align_center)
    table.cell(statsTable, 2, 3, str.tostring(tp1Pct, "#.#") + "%", text_color=color.black, bgcolor=cyanBg, text_size=size.small, text_halign=text.align_center)

    // TP2 row
    table.cell(statsTable, 0, 4, "TP2 (" + str.tostring(rrRatio * 2, "#.##") + "R)", text_color=color.white, bgcolor=grayBg, text_size=size.small, text_halign=text.align_left)
    table.cell(statsTable, 1, 4, str.tostring(tp2Count), text_color=color.black, bgcolor=greenBg, text_size=size.small, text_halign=text.align_center)
    table.cell(statsTable, 2, 4, str.tostring(tp2Pct, "#.#") + "%", text_color=color.black, bgcolor=cyanBg, text_size=size.small, text_halign=text.align_center)

    // TP3 row
    table.cell(statsTable, 0, 5, "TP3 (" + str.tostring(rrRatio * 3, "#.##") + "R)", text_color=color.white, bgcolor=grayBg, text_size=size.small, text_halign=text.align_left)
    table.cell(statsTable, 1, 5, str.tostring(tp3Count), text_color=color.black, bgcolor=greenBg, text_size=size.small, text_halign=text.align_center)
    table.cell(statsTable, 2, 5, str.tostring(tp3Pct, "#.#") + "%", text_color=color.black, bgcolor=cyanBg, text_size=size.small, text_halign=text.align_center)

    // TP4 row
    table.cell(statsTable, 0, 6, "TP4 (" + str.tostring(rrRatio * 4, "#.##") + "R)", text_color=color.white, bgcolor=grayBg, text_size=size.small, text_halign=text.align_left)
    table.cell(statsTable, 1, 6, str.tostring(tp4Count), text_color=color.black, bgcolor=greenBg, text_size=size.small, text_halign=text.align_center)
    table.cell(statsTable, 2, 6, str.tostring(tp4Pct, "#.#") + "%", text_color=color.black, bgcolor=cyanBg, text_size=size.small, text_halign=text.align_center)

    // SL row
    table.cell(statsTable, 0, 7, "SL (-1R)", text_color=color.white, bgcolor=grayBg, text_size=size.small, text_halign=text.align_left)
    table.cell(statsTable, 1, 7, str.tostring(slCount), text_color=color.white, bgcolor=redBg, text_size=size.small, text_halign=text.align_center)
    table.cell(statsTable, 2, 7, str.tostring(slPct, "#.#") + "%", text_color=color.white, bgcolor=redBg, text_size=size.small, text_halign=text.align_center)

    // Overall win rate row
    table.cell(statsTable, 0, 8, "OVERALL WR", text_color=color.white, bgcolor=color.new(color.gray, 30), text_size=size.small, text_halign=text.align_left)
    table.cell(statsTable, 1, 8, str.tostring(winCount) + "W/" + str.tostring(lossCount) + "L", text_color=color.black, bgcolor=cyanBg, text_size=size.small, text_halign=text.align_center)
    table.cell(statsTable, 2, 8, str.tostring(overallWinRate, "#.#") + "%", text_color=color.black, bgcolor=cyanBg, text_size=size.small, text_halign=text.align_center)

    // Expectancy row (in R per trade) — colour coded
    expColor = expectancy > 0 ? greenBg : redBg
    table.cell(statsTable, 0, 9, "EXPECTANCY", text_color=color.white, bgcolor=color.new(color.gray, 30), text_size=size.small, text_halign=text.align_left)
    table.cell(statsTable, 1, 9, str.tostring(expectancy, "#.###") + "R", text_color=color.black, bgcolor=expColor, text_size=size.small, text_halign=text.align_center)
    table.cell(statsTable, 2, 9, expectancy > 0 ? "PROFIT" : "LOSS", text_color=color.black, bgcolor=expColor, text_size=size.small, text_halign=text.align_center)

    // Sample-size note
    table.cell(statsTable, 0, 10, "Signals", text_color=color.white, bgcolor=grayBg, text_size=size.small, text_halign=text.align_left)
    table.cell(statsTable, 1, 10, str.tostring(totalSignals), text_color=color.black, bgcolor=color.new(color.gray, 40), text_size=size.small, text_halign=text.align_center)
    table.cell(statsTable, 2, 10, str.tostring(historyBars) + "d", text_color=color.black, bgcolor=color.new(color.gray, 40), text_size=size.small, text_halign=text.align_center)

// ─── TREND ANALYSIS DASHBOARD ────────────────────────────────────────────────
var table dashboardTable = table.new(getTablePosition(dashboardPosition), 2, 7,
     bgcolor=color.new(color.rgb(33,33,33), 80),
     border_width=2, border_color=color.new(widgetBorderColor, 0),
     frame_width=3, frame_color=color.new(widgetBorderColor, 0))

if showDashboard and barstate.islast
    table.cell(dashboardTable, 0, 0, "TREND ANALYSIS", text_color=color.black, bgcolor=#03f7ff, text_size=size.small, text_halign=text.align_center)
    table.merge_cells(dashboardTable, 0, 0, 1, 0)

    tf1Bull = switch combinedTrendTF1
        "5" => tf5e8 < tf5e2
        "15" => tf15e8 < tf15e2
        "30" => tf30e8 < tf30e2
        "60" => tf60e8 < tf60e2
        "240" => tf4he8 < tf4he2
        "D" => tfDe8 < tfDe2
        => false
    tf2Bull = switch combinedTrendTF2
        "5" => tf5e8 < tf5e2
        "15" => tf15e8 < tf15e2
        "30" => tf30e8 < tf30e2
        "60" => tf60e8 < tf60e2
        "240" => tf4he8 < tf4he2
        "D" => tfDe8 < tfDe2
        => false
    tf3Bull = switch combinedTrendTF3
        "5" => tf5e8 < tf5e2
        "15" => tf15e8 < tf15e2
        "30" => tf30e8 < tf30e2
        "60" => tf60e8 < tf60e2
        "240" => tf4he8 < tf4he2
        "D" => tfDe8 < tfDe2
        => false

    bullCnt = (tf1Bull ? 1 : 0) + (tf2Bull ? 1 : 0) + (tf3Bull ? 1 : 0)
    overallTrend = bullCnt >= 2 ? "BULLISH" : "BEARISH"
    overallClr = bullCnt >= 2 ? color.new(#00ff00, 0) : color.new(#ff0000, 0)
    grayBg = color.new(color.gray, 60)

    table.cell(dashboardTable, 0, 1, combinedTrendTF1 + "m", text_color=color.white, bgcolor=grayBg, text_size=size.small)
    table.cell(dashboardTable, 1, 1, tf1Bull ? "Bullish":"Bearish", text_color=color.black, bgcolor=tf1Bull ? color.new(#00ff00,0):color.new(#ff0000,0), text_size=size.small)
    table.cell(dashboardTable, 0, 2, combinedTrendTF2 + "m", text_color=color.white, bgcolor=grayBg, text_size=size.small)
    table.cell(dashboardTable, 1, 2, tf2Bull ? "Bullish":"Bearish", text_color=color.black, bgcolor=tf2Bull ? color.new(#00ff00,0):color.new(#ff0000,0), text_size=size.small)
    table.cell(dashboardTable, 0, 3, combinedTrendTF3 + "m", text_color=color.white, bgcolor=grayBg, text_size=size.small)
    table.cell(dashboardTable, 1, 3, tf3Bull ? "Bullish":"Bearish", text_color=color.black, bgcolor=tf3Bull ? color.new(#00ff00,0):color.new(#ff0000,0), text_size=size.small)
    table.cell(dashboardTable, 0, 4, "Current TF", text_color=color.white, bgcolor=grayBg, text_size=size.small)
    table.cell(dashboardTable, 1, 4, ribbonDir ? "Bullish":"Bearish", text_color=color.black, bgcolor=ribbonDir ? color.new(#00ff00,0):color.new(#ff0000,0), text_size=size.small)
    table.cell(dashboardTable, 0, 5, "ATR", text_color=color.white, bgcolor=grayBg, text_size=size.small)
    table.cell(dashboardTable, 1, 5, str.tostring(atr, format.mintick), text_color=color.black, bgcolor=color.new(color.gray,40), text_size=size.small)
    table.cell(dashboardTable, 0, 6, "Overall", text_color=color.white, bgcolor=grayBg, text_size=size.small)
    table.cell(dashboardTable, 1, 6, overallTrend, text_color=color.black, bgcolor=overallClr, text_size=size.small)
````
