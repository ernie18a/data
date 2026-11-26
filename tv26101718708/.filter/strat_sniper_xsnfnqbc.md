# Strat Sniper

- url: https://www.tradingview.com/script/xSnfNQBc-Strat-Sniper/
- type: indicator
- pine_id: PUB;094aaf466d2648ea8e9f2eddd0e4886d
- version: 2.0

## Description

Strat Sniper is a multi-timeframe continuity indicator designed to help traders identify high-probability Strat opportunities while eliminating lower-quality setups.

Instead of signaling every Strat pattern, this indicator filters setups using higher-timeframe continuity to focus on the trades that align with broader market direction.

The result is a cleaner chart, fewer false signals, and greater confidence in execution.


Features

Dynamic Timeframe Selection

Analyze Strat setups on any timeframe.

* Leave Execution TF blank to use the current chart timeframe.
* Select a specific timeframe to scan setups independently from the chart.

Examples:

* Trade 5-minute entries using 1-hour setups
* Trade 15-minute entries using 4-hour setups
* Scan Daily setups while viewing intraday charts


Supported Strat Patterns

Bullish:

* 2-1-2 Reversal
* 3-1-2 Continuation
* 2-2 Reversal

Bearish:

* 2-1-2 Reversal
* 3-1-2 Continuation
* 2-2 Reversal


## Disclaimer

This indicator is for educational purposes only and does not provide financial advice. All trading involves risk. Always use proper risk management and perform your own analysis before entering any trade.

## Source Code

````pine
//@version=6
indicator("Strat Execution Assistant Pro v6", overlay=true, max_labels_count=500, max_lines_count=500)

// === INPUTS ===
execTF = input.timeframe("", "Execution TF - Blank = Chart")
rr = input.float(2.0, "Risk Reward Target", step=0.25)

showFTCGrid = input.bool(true, "Show MTF Continuity Grid")
showSetupBox = input.bool(true, "Show Setup Details Box")
showPrevLevels = input.bool(true, "Show Previous Levels")

showPDH = input.bool(true, "PDH")
showPDL = input.bool(true, "PDL")
showPWH = input.bool(true, "PWH")
showPWL = input.bool(true, "PWL")

showPriorTwoCandleTypes = input.bool(true, "Show Prior 2 Candle Numbers")
showFormingSetupLabel = input.bool(true, "Show Forming Strat Setup Label")
candleTypeOffsetATR = input.float(0.45, "Candle Number Offset ATR", minval=0.1, step=0.1)

useVolumeConfirm = input.bool(true, "Use Volume Confirmation")
volumeLength = input.int(20, "Volume SMA Length")

useSessionFilter = input.bool(false, "Use Session Filter")
tradeSession = input.session("0930-1130,1500-1600", "Preferred Trading Sessions")

labelOffsetATR = input.float(1.75, "Box Offset ATR", minval=0.5, step=0.25)

useTF = execTF == "" ? timeframe.period : execTF

// === COLORS ===
bullColor = color.rgb(0, 95, 45)
bearColor = color.rgb(180, 40, 40)
insideColor = color.rgb(246, 190, 0)
outsideColor = color.fuchsia
blackBg = color.black

// === FILTERS ===
inSession = not useSessionFilter or not na(time(timeframe.period, tradeSession))
volConfirm = not useVolumeConfirm or volume > ta.sma(volume, volumeLength)

// === MTF DIRECTION ===
tfDir(tf) =>
    request.security(syminfo.tickerid, tf, close >= open ? 1 : -1, barmerge.gaps_off, barmerge.lookahead_off)

tfType(tf) =>
    request.security(syminfo.tickerid, tf, high <= high[1] and low >= low[1] ? 1 : high > high[1] and low < low[1] ? 3 : 0, barmerge.gaps_off, barmerge.lookahead_off)

dir60 = tfDir("60")
dir4H = tfDir("240")
dirD = tfDir("D")
dirW = tfDir("W")
dirM = tfDir("M")

type60 = tfType("60")
type4H = tfType("240")
typeD = tfType("D")
typeW = tfType("W")
typeM = tfType("M")

bullScore = (dir60 == 1 ? 1 : 0) + (dir4H == 1 ? 1 : 0) + (dirD == 1 ? 1 : 0) + (dirW == 1 ? 1 : 0)
bearScore = (dir60 == -1 ? 1 : 0) + (dir4H == -1 ? 1 : 0) + (dirD == -1 ? 1 : 0) + (dirW == -1 ? 1 : 0)

gradeLong = bullScore >= 4 and volConfirm ? "A+ SETUP" : bullScore >= 3 ? "A SETUP" : bullScore >= 2 ? "B SETUP" : "LOW QUALITY"
gradeShort = bearScore >= 4 and volConfirm ? "A+ SETUP" : bearScore >= 3 ? "A SETUP" : bearScore >= 2 ? "B SETUP" : "LOW QUALITY"

// === DEVELOPING 2-1-2 ===
strat212Developing() =>
    insideBar = high <= high[1] and low >= low[1]
    twoUpBar = high > high[1] and not (low < low[1])
    twoDownBar = low < low[1] and not (high > high[1])

    pendingBull = twoDownBar[1] and insideBar
    pendingBear = twoUpBar[1] and insideBar

    longEntry = high
    longStop = low
    longTarget = longEntry + ((longEntry - longStop) * rr)

    shortEntry = low
    shortStop = high
    shortTarget = shortEntry - ((shortStop - shortEntry) * rr)

    [pendingBull, pendingBear, longEntry, longStop, longTarget, shortEntry, shortStop, shortTarget]

[pendingBullRaw, pendingBearRaw, longEntry, longStop, longTarget, shortEntry, shortStop, shortTarget] = request.security(syminfo.tickerid, useTF, strat212Developing(), barmerge.gaps_off, barmerge.lookahead_off)

pendingBull = pendingBullRaw and inSession
pendingBear = pendingBearRaw and inSession

// === STATUS ===
longTriggered = pendingBull and high >= longEntry
shortTriggered = pendingBear and low <= shortEntry

longStopped = longTriggered and low <= longStop
shortStopped = shortTriggered and high >= shortStop

longTargetHit = longTriggered and high >= longTarget
shortTargetHit = shortTriggered and low <= shortTarget

// === ATR / LABEL POSITIONING ===
atr = ta.atr(14)
bullLabelY = low - atr * labelOffsetATR
bearLabelY = high + atr * labelOffsetATR

// === SETUP DETAIL BOX ===
var label setupBox = na
var int activeSide = 0

newBullSetup = pendingBull and activeSide != 1
newBearSetup = pendingBear and activeSide != -1
noSetup = not pendingBull and not pendingBear

if noSetup and activeSide != 0
    label.delete(setupBox)
    activeSide := 0

if newBullSetup
    label.delete(setupBox)
    activeSide := 1

if newBearSetup
    label.delete(setupBox)
    activeSide := -1

if pendingBull and activeSide == 1
    status = longTargetHit ? "TARGET HIT" : longStopped ? "STOPPED OUT" : longTriggered ? "TRIGGERED" : "DEVELOPING"
    txt = gradeLong + "\nSTRAT SETUP: 2-1-2 BULL\nSTATUS: " + status + "\nTF: " + useTF + "\nHTF: " + str.tostring(bullScore) + "/4 Bullish\nVolume: " + (volConfirm ? "Confirmed" : "Weak") + "\nENTRY LEVEL: " + str.tostring(longEntry, format.mintick) + "\nSTOP LOSS: " + str.tostring(longStop, format.mintick) + "\nTARGET: " + str.tostring(longTarget, format.mintick)

    if showSetupBox
        if na(setupBox)
            setupBox := label.new(bar_index, bullLabelY, txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=bullColor, textcolor=color.white, size=size.small)
        else
            label.set_x(setupBox, bar_index)
            label.set_y(setupBox, bullLabelY)
            label.set_text(setupBox, txt)
            label.set_color(setupBox, bullColor)
            label.set_style(setupBox, label.style_label_up)

if pendingBear and activeSide == -1
    status = shortTargetHit ? "TARGET HIT" : shortStopped ? "STOPPED OUT" : shortTriggered ? "TRIGGERED" : "DEVELOPING"
    txt = gradeShort + "\nSTRAT SETUP: 2-1-2 BEAR\nSTATUS: " + status + "\nTF: " + useTF + "\nHTF: " + str.tostring(bearScore) + "/4 Bearish\nVolume: " + (volConfirm ? "Confirmed" : "Weak") + "\nENTRY LEVEL: " + str.tostring(shortEntry, format.mintick) + "\nSTOP LOSS: " + str.tostring(shortStop, format.mintick) + "\nTARGET: " + str.tostring(shortTarget, format.mintick)

    if showSetupBox
        if na(setupBox)
            setupBox := label.new(bar_index, bearLabelY, txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=bearColor, textcolor=color.white, size=size.small)
        else
            label.set_x(setupBox, bar_index)
            label.set_y(setupBox, bearLabelY)
            label.set_text(setupBox, txt)
            label.set_color(setupBox, bearColor)
            label.set_style(setupBox, label.style_label_down)

// === PRIOR 2 CANDLE NUMBERS + FORMING SETUP LABEL ===
getCandleType(offset) =>
    inside = high[offset] <= high[offset + 1] and low[offset] >= low[offset + 1]
    outside = high[offset] > high[offset + 1] and low[offset] < low[offset + 1]
    twoUp = high[offset] > high[offset + 1] and not (low[offset] < low[offset + 1])
    twoDown = low[offset] < low[offset + 1] and not (high[offset] > high[offset + 1])
    inside ? "1" : outside ? "3" : twoUp ? "2U" : twoDown ? "2D" : ""

getCandleColor(txt) =>
    txt == "1" ? insideColor : txt == "3" ? outsideColor : txt == "2U" ? bullColor : txt == "2D" ? bearColor : color.gray

var label priorOneLabel = na
var label priorTwoLabel = na
var label formingSetupLabel = na

priorOneType = getCandleType(1)
priorTwoType = getCandleType(2)

formingText = pendingBull ? "FORMING: 2-1-2 BULL\nTrigger Above: " + str.tostring(longEntry, format.mintick) : pendingBear ? "FORMING: 2-1-2 BEAR\nTrigger Below: " + str.tostring(shortEntry, format.mintick) : "NO 2-1-2 FORMING"
formingColor = pendingBull ? bullColor : pendingBear ? bearColor : color.gray

if barstate.islast
    label.delete(priorOneLabel)
    label.delete(priorTwoLabel)
    label.delete(formingSetupLabel)

    if showPriorTwoCandleTypes
        priorOneLabel := label.new(bar_index - 1, low[1] - atr * candleTypeOffsetATR, priorOneType, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=getCandleColor(priorOneType), textcolor=color.white, size=size.small)
        priorTwoLabel := label.new(bar_index - 2, low[2] - atr * candleTypeOffsetATR, priorTwoType, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=getCandleColor(priorTwoType), textcolor=color.white, size=size.small)

    if showFormingSetupLabel
        formingSetupLabel := label.new(bar_index, low - atr * (candleTypeOffsetATR + 0.7), formingText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=formingColor, textcolor=color.white, size=size.small)

// === SINGLE PREVIOUS LEVEL LINES ===
prevDayHigh = request.security(syminfo.tickerid, "D", high[1], barmerge.gaps_off, barmerge.lookahead_off)
prevDayLow = request.security(syminfo.tickerid, "D", low[1], barmerge.gaps_off, barmerge.lookahead_off)
prevWeekHigh = request.security(syminfo.tickerid, "W", high[1], barmerge.gaps_off, barmerge.lookahead_off)
prevWeekLow = request.security(syminfo.tickerid, "W", low[1], barmerge.gaps_off, barmerge.lookahead_off)

var line pdhLine = na
var line pdlLine = na
var line pwhLine = na
var line pwlLine = na

var label pdhLabel = na
var label pdlLabel = na
var label pwhLabel = na
var label pwlLabel = na

if barstate.islast
    if showPrevLevels and showPDH
        if na(pdhLine)
            pdhLine := line.new(bar_index - 1, prevDayHigh, bar_index, prevDayHigh, xloc=xloc.bar_index, extend=extend.right, color=bullColor, width=2)
            pdhLabel := label.new(bar_index + 1, prevDayHigh, "PDH " + str.tostring(prevDayHigh, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=bullColor, textcolor=color.white, size=size.small)
        else
            line.set_xy1(pdhLine, bar_index - 1, prevDayHigh)
            line.set_xy2(pdhLine, bar_index, prevDayHigh)
            label.set_x(pdhLabel, bar_index + 1)
            label.set_y(pdhLabel, prevDayHigh)
            label.set_text(pdhLabel, "PDH " + str.tostring(prevDayHigh, format.mintick))

    if showPrevLevels and showPDL
        if na(pdlLine)
            pdlLine := line.new(bar_index - 1, prevDayLow, bar_index, prevDayLow, xloc=xloc.bar_index, extend=extend.right, color=bearColor, width=2)
            pdlLabel := label.new(bar_index + 1, prevDayLow, "PDL " + str.tostring(prevDayLow, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=bearColor, textcolor=color.white, size=size.small)
        else
            line.set_xy1(pdlLine, bar_index - 1, prevDayLow)
            line.set_xy2(pdlLine, bar_index, prevDayLow)
            label.set_x(pdlLabel, bar_index + 1)
            label.set_y(pdlLabel, prevDayLow)
            label.set_text(pdlLabel, "PDL " + str.tostring(prevDayLow, format.mintick))

    if showPrevLevels and showPWH
        if na(pwhLine)
            pwhLine := line.new(bar_index - 1, prevWeekHigh, bar_index, prevWeekHigh, xloc=xloc.bar_index, extend=extend.right, color=color.orange, width=2)
            pwhLabel := label.new(bar_index + 1, prevWeekHigh, "PWH " + str.tostring(prevWeekHigh, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.orange, textcolor=color.white, size=size.small)
        else
            line.set_xy1(pwhLine, bar_index - 1, prevWeekHigh)
            line.set_xy2(pwhLine, bar_index, prevWeekHigh)
            label.set_x(pwhLabel, bar_index + 1)
            label.set_y(pwhLabel, prevWeekHigh)
            label.set_text(pwhLabel, "PWH " + str.tostring(prevWeekHigh, format.mintick))

    if showPrevLevels and showPWL
        if na(pwlLine)
            pwlLine := line.new(bar_index - 1, prevWeekLow, bar_index, prevWeekLow, xloc=xloc.bar_index, extend=extend.right, color=color.purple, width=2)
            pwlLabel := label.new(bar_index + 1, prevWeekLow, "PWL " + str.tostring(prevWeekLow, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.purple, textcolor=color.white, size=size.small)
        else
            line.set_xy1(pwlLine, bar_index - 1, prevWeekLow)
            line.set_xy2(pwlLine, bar_index, prevWeekLow)
            label.set_x(pwlLabel, bar_index + 1)
            label.set_y(pwlLabel, prevWeekLow)
            label.set_text(pwlLabel, "PWL " + str.tostring(prevWeekLow, format.mintick))

// === MTF GRID ===
dirText(d) =>
    d == 1 ? "Bull" : "Bear"

dirColor(d) =>
    d == 1 ? bullColor : bearColor

typeText(t) =>
    t == 1 ? "IN" : t == 3 ? "OUT" : ""

typeColor(t) =>
    t == 1 ? insideColor : t == 3 ? outsideColor : blackBg

var table ftcTable = table.new(position.top_right, 4, 7, border_width=1)

if showFTCGrid and barstate.islast
    table.cell(ftcTable, 0, 0, "TF", text_color=color.white, bgcolor=blackBg)
    table.cell(ftcTable, 1, 0, "Dir", text_color=color.white, bgcolor=blackBg)
    table.cell(ftcTable, 2, 0, "Type", text_color=color.white, bgcolor=blackBg)
    table.cell(ftcTable, 3, 0, "Score", text_color=color.white, bgcolor=blackBg)

    table.cell(ftcTable, 0, 1, "1H", text_color=color.white, bgcolor=blackBg)
    table.cell(ftcTable, 1, 1, dirText(dir60), text_color=color.white, bgcolor=dirColor(dir60))
    table.cell(ftcTable, 2, 1, typeText(type60), text_color=color.white, bgcolor=typeColor(type60))
    table.cell(ftcTable, 3, 1, "", bgcolor=blackBg)

    table.cell(ftcTable, 0, 2, "4H", text_color=color.white, bgcolor=blackBg)
    table.cell(ftcTable, 1, 2, dirText(dir4H), text_color=color.white, bgcolor=dirColor(dir4H))
    table.cell(ftcTable, 2, 2, typeText(type4H), text_color=color.white, bgcolor=typeColor(type4H))
    table.cell(ftcTable, 3, 2, "", bgcolor=blackBg)

    table.cell(ftcTable, 0, 3, "D", text_color=color.white, bgcolor=blackBg)
    table.cell(ftcTable, 1, 3, dirText(dirD), text_color=color.white, bgcolor=dirColor(dirD))
    table.cell(ftcTable, 2, 3, typeText(typeD), text_color=color.white, bgcolor=typeColor(typeD))
    table.cell(ftcTable, 3, 3, "", bgcolor=blackBg)

    table.cell(ftcTable, 0, 4, "W", text_color=color.white, bgcolor=blackBg)
    table.cell(ftcTable, 1, 4, dirText(dirW), text_color=color.white, bgcolor=dirColor(dirW))
    table.cell(ftcTable, 2, 4, typeText(typeW), text_color=color.white, bgcolor=typeColor(typeW))
    table.cell(ftcTable, 3, 4, "", bgcolor=blackBg)

    table.cell(ftcTable, 0, 5, "M", text_color=color.white, bgcolor=blackBg)
    table.cell(ftcTable, 1, 5, dirText(dirM), text_color=color.white, bgcolor=dirColor(dirM))
    table.cell(ftcTable, 2, 5, typeText(typeM), text_color=color.white, bgcolor=typeColor(typeM))
    table.cell(ftcTable, 3, 5, "", bgcolor=blackBg)

    table.cell(ftcTable, 0, 6, "Alignment", text_color=color.white, bgcolor=blackBg)
    table.cell(ftcTable, 1, 6, bullScore >= bearScore ? "Bull" : "Bear", text_color=color.white, bgcolor=bullScore >= bearScore ? bullColor : bearColor)
    table.cell(ftcTable, 2, 6, str.tostring(math.max(bullScore, bearScore)) + "/4", text_color=color.white, bgcolor=blackBg)
    table.cell(ftcTable, 3, 6, bullScore >= 4 or bearScore >= 4 ? "A+" : math.max(bullScore, bearScore) >= 3 ? "A" : "B", text_color=color.white, bgcolor=math.max(bullScore, bearScore) >= 3 ? bullColor : color.gray)

// === ALERTS ===
alertcondition(newBullSetup, title="Bull 2-1-2 Developing", message="Bullish 2-1-2 developing.")
alertcondition(newBearSetup, title="Bear 2-1-2 Developing", message="Bearish 2-1-2 developing.")

alertcondition(longTriggered and not longTriggered[1], title="Bull 2-1-2 Triggered", message="Bullish 2-1-2 entry triggered.")
alertcondition(shortTriggered and not shortTriggered[1], title="Bear 2-1-2 Triggered", message="Bearish 2-1-2 entry triggered.")

alertcondition(longTargetHit and not longTargetHit[1], title="Bull 2-1-2 Target Hit", message="Bullish 2-1-2 target hit.")
alertcondition(shortTargetHit and not shortTargetHit[1], title="Bear 2-1-2 Target Hit", message="Bearish 2-1-2 target hit.")

alertcondition(longStopped and not longStopped[1], title="Bull 2-1-2 Stop Hit", message="Bullish 2-1-2 stop hit.")
alertcondition(shortStopped and not shortStopped[1], title="Bear 2-1-2 Stop Hit", message="Bearish 2-1-2 stop hit.")
````
