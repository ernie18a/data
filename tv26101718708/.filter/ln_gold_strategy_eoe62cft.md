# LN Gold Strategy

- url: https://www.tradingview.com/script/eOe62cft-LN-Gold-Strategy/
- type: strategy
- pine_id: PUB;55beee3caad74520b8b1de661557d222
- version: 2.0

## Description

Strategy Summary:

This strategy combines ZigZag structure, Fair Value Gaps (FVG), and EMA trend filtering to identify high-probability trade setups.
Trades are taken when price aligns with the trend (EMA), confirms structure (ZigZag), and interacts with a valid FVG zone.

The system uses a fixed risk-to-reward ratio, with built-in stop loss, take profit, and optional lock-profit (break-even) management to protect gains.

It is designed for precision entries, controlled risk, and consistent execution, mainly on lower timeframes.

## Source Code

````pine
//@version=5
strategy("ZigZag + Used FVG + EMA Strategy RR + LP + Continuation + Previous S/R Flip Filter", overlay=true, max_bars_back=5000, max_lines_count=500, max_labels_count=500, max_boxes_count=300, pyramiding=0, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=10, process_orders_on_close=false)

//--------------------------------------------------
// Inputs
//--------------------------------------------------
length      = input.int(20, "ZigZag Length", minval=2)
extendLast  = input.bool(true, "Extend To Last Bar")
showLabels  = input.bool(true, "Show LL/HH/HL/LH Labels")
showPoints  = input.bool(true, "Show Swing Points")
showZigZagLines = input.bool(true, "Show ZigZag Lines")

bullCol     = input.color(color.lime, "Bullish Swing Color")
bearCol     = input.color(color.red, "Corrective Swing Color")
pointLowCol = input.color(color.blue, "Low Point Color")
pointHiCol  = input.color(color.orange, "High Point Color")

//--------------------------------------------------
// Trend / Consolidation Filter
//--------------------------------------------------
groupTrend     = "Trend / Consolidation Filter"
useTrendFilter = input.bool(true, "Block Trades In Consolidation", group=groupTrend)
adxLen         = input.int(14, "ADX DI Length", minval=2, group=groupTrend)
adxSmooth      = input.int(14, "ADX Smoothing", minval=2, group=groupTrend)
adxThreshold   = input.float(20.0, "Trending ADX Minimum", minval=1.0, step=0.5, group=groupTrend)

//--------------------------------------------------
// Confirmation / Continuation
//--------------------------------------------------
groupConfirm = "Confirmation / Continuation"
confirmTf    = input.timeframe("1", "Confirmation Timeframe", group=groupConfirm)
allowContinuationAfterCross = input.bool(true, "Allow Continuation After EMA Trend", group=groupConfirm)

//--------------------------------------------------
// Quality Filters
//--------------------------------------------------
groupQuality = "Quality Filters"
useImpulseFilter = input.bool(true, "Require Impulse Candle", group=groupQuality)
minBodyPct = input.float(50.0, "Min Body % Of Candle Range", minval=1.0, maxval=100.0, step=1.0, group=groupQuality)

useFvgAgeFilter = input.bool(true, "Use FVG Max Age", group=groupQuality)
maxFvgAge = input.int(20, "Max FVG Age Bars", minval=1, maxval=500, group=groupQuality)

useRetestDepthFilter = input.bool(true, "Use Max Retest Depth", group=groupQuality)
maxRetestDepthPct = input.float(70.0, "Max Retest Depth %", minval=1.0, maxval=100.0, step=1.0, group=groupQuality)

//--------------------------------------------------
// Sessions
//--------------------------------------------------
groupSess = "Sessions"
sessionTz = input.string("exchange", "Session Timezone", options=["exchange", "UTC", "America/New_York", "Europe/London", "Asia/Tokyo"], group=groupSess)

useSession1 = input.bool(true, "Use Session 1", group=groupSess)
session1 = input.session("0000-2359", "Session 1 Time", group=groupSess)

useSession2 = input.bool(false, "Use Session 2", group=groupSess)
session2 = input.session("0700-1000", "Session 2 Time", group=groupSess)

useSession3 = input.bool(false, "Use Session 3", group=groupSess)
session3 = input.session("0930-1200", "Session 3 Time", group=groupSess)

useSession4 = input.bool(false, "Use Session 4", group=groupSess)
session4 = input.session("1300-1600", "Session 4 Time", group=groupSess)

//--------------------------------------------------
// Risk / Reward
//--------------------------------------------------
groupRisk       = "Risk / Reward"
slTicks         = input.int(300, "SL Distance In Ticks", minval=1, group=groupRisk)
rrTarget        = input.float(2.0, "Risk Reward Target", minval=0.1, step=0.1, group=groupRisk)
moveAtProfitPct = input.float(50.0, "Show LP After Closed Profit %", minval=1.0, maxval=100.0, step=1.0, group=groupRisk)
lockProfitPct   = input.float(10.0, "LP Line Profit % Of TP Distance", minval=0.0, maxval=100.0, step=1.0, group=groupRisk)

//--------------------------------------------------
// Fair Value Gap
//--------------------------------------------------
groupFVG          = "Fair Value Gap"
showUsedFVG       = input.bool(true, "Show Only Used FVG", group=groupFVG)
extendUsedFVG     = input.int(20, "Used FVG Extend Bars", minval=1, maxval=300, group=groupFVG)
maxStoredFVG      = input.int(80, "Max Stored FVGs", minval=20, maxval=300, group=groupFVG)
showConfirmSigs   = input.bool(true, "Show Confirmation Triangles", group=groupFVG)
showLPSigs        = input.bool(true, "Show LP Activation Triangles", group=groupFVG)
showTradeLines    = input.bool(true, "Show ETY / SL / TP / LP Lines", group=groupFVG)
showMoveLabel     = input.bool(true, "Show Live Trade Movement Label", group=groupFVG)

bullFvgCol        = input.color(color.new(color.lime, 82), "Used Bullish FVG Color", group=groupFVG)
bearFvgCol        = input.color(color.new(color.red, 82), "Used Bearish FVG Color", group=groupFVG)
bullFvgBrd        = input.color(color.new(color.lime, 35), "Used Bullish FVG Border", group=groupFVG)
bearFvgBrd        = input.color(color.new(color.red, 35), "Used Bearish FVG Border", group=groupFVG)

entryLineCol      = input.color(color.white, "ETY Line Color", group=groupFVG)
slLineCol         = input.color(color.fuchsia, "SL Line Color", group=groupFVG)
tpLineCol         = input.color(color.aqua, "TP Line Color", group=groupFVG)
lpLineCol         = input.color(color.orange, "LP Line Color", group=groupFVG)
moveProfitCol     = input.color(color.lime, "Movement Profit Color", group=groupFVG)
moveLossCol       = input.color(color.red, "Movement Loss Color", group=groupFVG)
moveFlatCol       = input.color(color.gray, "Movement Flat Color", group=groupFVG)

tradeTextSizeOpt  = input.string("Small", "ETY / SL / TP / LP Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=groupFVG)

//--------------------------------------------------
// EMA
//--------------------------------------------------
groupEMA = "EMA"
showEMA1 = input.bool(true, "Show EMA Small", group=groupEMA)
emaLen1  = input.int(50, "Small EMA Length", minval=1, group=groupEMA)

showEMA2 = input.bool(true, "Show EMA Big", group=groupEMA)
emaLen2  = input.int(100, "Big EMA Length", minval=1, group=groupEMA)

//--------------------------------------------------
// Previous S/R Flip Filter
//--------------------------------------------------
groupSR = "Previous S/R Flip Filter"
useSRFlipFilter = input.bool(true, "Use Previous S/R Flip Filter", group=groupSR)
srZoneTicks = input.int(80, "S/R Zone Thickness In Ticks", minval=1, group=groupSR)
srRetestBars = input.int(40, "Max Bars After Break For Retest", minval=1, group=groupSR)
showSRZones = input.bool(true, "Show Previous S/R Zones", group=groupSR)
showFlipLabels = input.bool(true, "Show S/R Flip Labels", group=groupSR)

supportColor = input.color(color.new(color.lime, 85), "Support Zone Color", group=groupSR)
resistColor  = input.color(color.new(color.red, 85), "Resistance Zone Color", group=groupSR)
flipColor    = input.color(color.new(color.aqua, 80), "Flipped Zone Color", group=groupSR)

//--------------------------------------------------
// Helpers
//--------------------------------------------------
f_textSize(_opt) =>
    _opt == "Tiny" ? size.tiny :
     _opt == "Small" ? size.small :
     _opt == "Normal" ? size.normal :
     _opt == "Large" ? size.large :
     size.huge

f_price(_p) =>
    str.tostring(_p, format.mintick)

f_ticks(_entry, _price) =>
    math.round(math.abs(_price - _entry) / syminfo.mintick)

f_tradeText(_name, _price, _entry, _showTicks) =>
    _showTicks ? _name + " " + f_price(_price) + " | " + str.tostring(f_ticks(_entry, _price)) + " ticks" : _name + " " + f_price(_price)

f_resultLabel(_txt, _y, _col) =>
    label.new(bar_index, _y, _txt, xloc=xloc.bar_index, style=label.style_none, color=color.new(color.black, 100), textcolor=_col, size=size.huge)

f_inSession(_sess) =>
    sessionTz == "exchange" ? not na(time(timeframe.period, _sess)) : not na(time(timeframe.period, _sess, sessionTz))

f_inZone(_top, _bot) =>
    not na(_top) and not na(_bot) and low <= _top and high >= _bot

//--------------------------------------------------
// Sessions
//--------------------------------------------------
inSession1 = useSession1 and f_inSession(session1)
inSession2 = useSession2 and f_inSession(session2)
inSession3 = useSession3 and f_inSession(session3)
inSession4 = useSession4 and f_inSession(session4)
sessionOk = inSession1 or inSession2 or inSession3 or inSession4

//--------------------------------------------------
// ZigZag Core
//--------------------------------------------------
src = close
n   = bar_index

upper = ta.highest(src, length)
lower = ta.lowest(src, length)

var int os = 0
os := src[length] > upper ? 0 : src[length] < lower ? 1 : nz(os[1], 0)

btm = os == 1 and os[1] != 1
top = os == 0 and os[1] != 0

//--------------------------------------------------
// Filters / EMAs
//--------------------------------------------------
[plusDI, minusDI, adxValue] = ta.dmi(adxLen, adxSmooth)
isTrending = not useTrendFilter or adxValue >= adxThreshold

emaSmall = ta.ema(close, emaLen1)
emaBig   = ta.ema(close, emaLen2)

emaBullTrend = emaSmall > emaBig
emaBearTrend = emaSmall < emaBig

candleRange = high - low
bodySize = math.abs(close - open)
bodyPct = candleRange > 0 ? bodySize / candleRange * 100.0 : 0.0
bullImpulseOk = not useImpulseFilter or (close > open and bodyPct >= minBodyPct)
bearImpulseOk = not useImpulseFilter or (close < open and bodyPct >= minBodyPct)

//--------------------------------------------------
// Lower Timeframe Confirmation
//--------------------------------------------------
f_mtfConfirm(_lenSmall, _lenBig) =>
    _emaSmall = ta.ema(close, _lenSmall)
    _emaBig   = ta.ema(close, _lenBig)

    _bullBreak = close > _emaSmall and close[1] <= _emaSmall[1]
    _bearBreak = close < _emaSmall and close[1] >= _emaSmall[1]

    _aboveBoth = close > _emaSmall and close > _emaBig
    _belowBoth = close < _emaSmall and close < _emaBig

    [_bullBreak, _bearBreak, _aboveBoth, _belowBoth]

[bullEmaBreak, bearEmaBreak, mtfAboveBoth, mtfBelowBoth] = request.security(syminfo.tickerid, confirmTf, f_mtfConfirm(emaLen1, emaLen2), barmerge.gaps_off, barmerge.lookahead_off)

//--------------------------------------------------
// Swing Storage + Previous S/R Zones
//--------------------------------------------------
var float lastLowPrice  = na
var int   lastLowIdx    = na
var float prevLowPrice  = na
var int   prevLowIdx    = na

var float lastHighPrice = na
var int   lastHighIdx   = na
var float prevHighPrice = na
var int   prevHighIdx   = na

var int swingDir = 0

srThickness = srZoneTicks * syminfo.mintick

var float prevSupportTop = na
var float prevSupportBot = na
var int   prevSupportIdx = na

var float prevResTop = na
var float prevResBot = na
var int   prevResIdx = na

var bool supportBrokenDown = false
var int  supportBreakBar = na

var bool resistanceBrokenUp = false
var int  resistanceBreakBar = na

var box supportBox = na
var box resistBox = na

f_label(_x, _y, _txt, _up) =>
    if showLabels
        label.new(_x, _y, _txt, xloc=xloc.bar_index, style=_up ? label.style_label_up : label.style_label_down, color=color.new(color.black, 100), textcolor=color.white, size=size.small)

// New support swing
if btm
    newLowPrice = low[length]
    newLowIdx   = n[length]

    prevLowPrice := lastLowPrice
    prevLowIdx   := lastLowIdx
    lastLowPrice := newLowPrice
    lastLowIdx   := newLowIdx

    prevSupportTop := newLowPrice + srThickness
    prevSupportBot := newLowPrice - srThickness
    prevSupportIdx := newLowIdx
    supportBrokenDown := false
    supportBreakBar := na

    if showSRZones
        if not na(supportBox)
            box.delete(supportBox)
        supportBox := box.new(prevSupportIdx, prevSupportTop, bar_index + 100, prevSupportBot, xloc=xloc.bar_index, bgcolor=supportColor, border_color=color.new(color.lime, 35))

    if showZigZagLines and not na(lastHighPrice) and not na(lastHighIdx)
        line.new(lastHighIdx, lastHighPrice, lastLowIdx, lastLowPrice, xloc=xloc.bar_index, color=bearCol, width=3)

    if not na(prevLowPrice)
        txt = newLowPrice < prevLowPrice ? "LL" : "HL"
        f_label(newLowIdx, newLowPrice, txt, true)
    else
        f_label(newLowIdx, newLowPrice, "LL", true)

    swingDir := 1

// New resistance swing
if top
    newHighPrice = high[length]
    newHighIdx   = n[length]

    prevHighPrice := lastHighPrice
    prevHighIdx   := lastHighIdx
    lastHighPrice := newHighPrice
    lastHighIdx   := newHighIdx

    prevResTop := newHighPrice + srThickness
    prevResBot := newHighPrice - srThickness
    prevResIdx := newHighIdx
    resistanceBrokenUp := false
    resistanceBreakBar := na

    if showSRZones
        if not na(resistBox)
            box.delete(resistBox)
        resistBox := box.new(prevResIdx, prevResTop, bar_index + 100, prevResBot, xloc=xloc.bar_index, bgcolor=resistColor, border_color=color.new(color.red, 35))

    if showZigZagLines and not na(lastLowPrice) and not na(lastLowIdx)
        line.new(lastLowIdx, lastLowPrice, lastHighIdx, lastHighPrice, xloc=xloc.bar_index, color=bullCol, width=3)

    if not na(prevHighPrice)
        txt = newHighPrice > prevHighPrice ? "HH" : "LH"
        f_label(newHighIdx, newHighPrice, txt, false)
    else
        f_label(newHighIdx, newHighPrice, "HH", false)

    swingDir := -1

//--------------------------------------------------
// Update S/R Boxes
//--------------------------------------------------
if showSRZones
    if not na(supportBox)
        box.set_right(supportBox, bar_index + 100)
        box.set_bgcolor(supportBox, supportBrokenDown ? flipColor : supportColor)

    if not na(resistBox)
        box.set_right(resistBox, bar_index + 100)
        box.set_bgcolor(resistBox, resistanceBrokenUp ? flipColor : resistColor)

//--------------------------------------------------
// S/R Break + Retest Logic
//--------------------------------------------------
supportBreakNow = not na(prevSupportBot) and close < prevSupportBot
resistanceBreakNow = not na(prevResTop) and close > prevResTop

if supportBreakNow and not supportBrokenDown
    supportBrokenDown := true
    supportBreakBar := bar_index
    if showFlipLabels
        label.new(bar_index, high, "Support Broken", xloc=xloc.bar_index, style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white, size=size.tiny)

if resistanceBreakNow and not resistanceBrokenUp
    resistanceBrokenUp := true
    resistanceBreakBar := bar_index
    if showFlipLabels
        label.new(bar_index, low, "Resistance Broken", xloc=xloc.bar_index, style=label.style_label_up, color=color.new(color.lime, 0), textcolor=color.white, size=size.tiny)

inOldSupport = f_inZone(prevSupportTop, prevSupportBot)
inOldResistance = f_inZone(prevResTop, prevResBot)

supportRetestValid = supportBrokenDown and not na(supportBreakBar) and bar_index > supportBreakBar and bar_index - supportBreakBar <= srRetestBars and inOldSupport and close < prevSupportTop
resistanceRetestValid = resistanceBrokenUp and not na(resistanceBreakBar) and bar_index > resistanceBreakBar and bar_index - resistanceBreakBar <= srRetestBars and inOldResistance and close > prevResBot

srShortOk = not useSRFlipFilter or not inOldSupport or supportRetestValid
srLongOk  = not useSRFlipFilter or not inOldResistance or resistanceRetestValid

//--------------------------------------------------
// FVG Storage
//--------------------------------------------------
var float[] fvgTops       = array.new_float()
var float[] fvgBots       = array.new_float()
var int[]   fvgDirs       = array.new_int()
var int[]   fvgStates     = array.new_int()
var int[]   fvgBirthBars  = array.new_int()
var int[]   fvgRetestBars = array.new_int()

//--------------------------------------------------
// Trade Visual State
//--------------------------------------------------
var line activeEntryLine = na
var line activeSLLine = na
var line activeTPLine = na
var line activeLPLine = na

var label activeEntryLabel = na
var label activeSLLabel = na
var label activeTPLabel = na
var label activeLPLabel = na
var label activeMoveLabel = na

var int visualEntryBar = na
var float visualEntryPrice = na
var float visualBaseSL = na
var float visualTP = na
var float visualLP = na
var bool lpArmed = false

tradeTextSize = f_textSize(tradeTextSizeOpt)

//--------------------------------------------------
// FVG Detection
//--------------------------------------------------
bullFVG = low > high[2]
bearFVG = high < low[2]

if bullFVG
    array.push(fvgTops, low)
    array.push(fvgBots, high[2])
    array.push(fvgDirs, 1)
    array.push(fvgStates, 0)
    array.push(fvgBirthBars, bar_index)
    array.push(fvgRetestBars, na)

if bearFVG
    array.push(fvgTops, low[2])
    array.push(fvgBots, high)
    array.push(fvgDirs, -1)
    array.push(fvgStates, 0)
    array.push(fvgBirthBars, bar_index)
    array.push(fvgRetestBars, na)

if array.size(fvgTops) > maxStoredFVG
    array.shift(fvgTops)
    array.shift(fvgBots)
    array.shift(fvgDirs)
    array.shift(fvgStates)
    array.shift(fvgBirthBars)
    array.shift(fvgRetestBars)

//--------------------------------------------------
// FVG Retest + Confirmation
//--------------------------------------------------
bodyHigh = math.max(open, close)
bodyLow  = math.min(open, close)

bullConfirmation = false
bearConfirmation = false

if array.size(fvgTops) > 0
    for i = 0 to array.size(fvgTops) - 1
        topFvg    = array.get(fvgTops, i)
        botFvg    = array.get(fvgBots, i)
        dir       = array.get(fvgDirs, i)
        state     = array.get(fvgStates, i)
        birthBar  = array.get(fvgBirthBars, i)
        retestBar = array.get(fvgRetestBars, i)

        if state >= 0
            fvgHeight = math.abs(topFvg - botFvg)
            bullRetestDepth = fvgHeight > 0 ? math.max(0.0, topFvg - low) / fvgHeight * 100.0 : 0.0
            bearRetestDepth = fvgHeight > 0 ? math.max(0.0, high - botFvg) / fvgHeight * 100.0 : 0.0

            bullDepthOk = not useRetestDepthFilter or bullRetestDepth <= maxRetestDepthPct
            bearDepthOk = not useRetestDepthFilter or bearRetestDepth <= maxRetestDepthPct

            fvgAge = bar_index - birthBar
            ageOk = not useFvgAgeFilter or fvgAge <= maxFvgAge

            bullInvalid = dir == 1 and bodyLow < botFvg
            bearInvalid = dir == -1 and bodyHigh > topFvg

            touchedZone = low <= topFvg and high >= botFvg
            canRetest = bar_index > birthBar

            validBullRetest = dir == 1 and state == 0 and canRetest and touchedZone and not bullInvalid and ageOk and bullDepthOk
            validBearRetest = dir == -1 and state == 0 and canRetest and touchedZone and not bearInvalid and ageOk and bearDepthOk

            if validBullRetest or validBearRetest
                array.set(fvgStates, i, 1)
                array.set(fvgRetestBars, i, bar_index)
                state := 1
                retestBar := bar_index

            bullConfirmModeOk = bullEmaBreak or allowContinuationAfterCross
            bearConfirmModeOk = bearEmaBreak or allowContinuationAfterCross

            bullReady = dir == 1 and state == 1 and bar_index > retestBar and bullConfirmModeOk and mtfAboveBoth and emaBullTrend and isTrending and bullImpulseOk and sessionOk and srLongOk and strategy.position_size == 0
            bearReady = dir == -1 and state == 1 and bar_index > retestBar and bearConfirmModeOk and mtfBelowBoth and emaBearTrend and isTrending and bearImpulseOk and sessionOk and srShortOk and strategy.position_size == 0

            if bullReady
                bullConfirmation := true
                array.set(fvgStates, i, 2)

                if showUsedFVG
                    box.new(left=birthBar - 2, top=topFvg, right=bar_index + extendUsedFVG, bottom=botFvg, xloc=xloc.bar_index, bgcolor=bullFvgCol, border_color=bullFvgBrd)

            if bearReady
                bearConfirmation := true
                array.set(fvgStates, i, 2)

                if showUsedFVG
                    box.new(left=birthBar - 2, top=topFvg, right=bar_index + extendUsedFVG, bottom=botFvg, xloc=xloc.bar_index, bgcolor=bearFvgCol, border_color=bearFvgBrd)

            if bullInvalid or bearInvalid or (useFvgAgeFilter and fvgAge > maxFvgAge)
                array.set(fvgStates, i, -1)

//--------------------------------------------------
// Strategy Orders
//--------------------------------------------------
if bullConfirmation and strategy.position_size == 0
    strategy.entry("Long", strategy.long, alert_message='{"action":"BUY","symbol":"{{ticker}}"}')

if bearConfirmation and strategy.position_size == 0
    strategy.entry("Short", strategy.short, alert_message='{"action":"SELL","symbol":"{{ticker}}"}')

riskDistance = slTicks * syminfo.mintick

lpActivatedThisBar = false

if strategy.position_size > 0
    entry = strategy.position_avg_price
    baseSL = entry - riskDistance
    tp = entry + riskDistance * rrTarget
    lp = entry + (tp - entry) * (lockProfitPct / 100.0)
    trigger = entry + (tp - entry) * (moveAtProfitPct / 100.0)

    if not lpArmed and high >= trigger
        lpArmed := true
        lpActivatedThisBar := true

    exitSL = lpArmed ? lp : baseSL
    strategy.exit("Long Exit", from_entry="Long", stop=exitSL, limit=tp, alert_message='{"action":"EXIT_LONG","symbol":"{{ticker}}"}')

if strategy.position_size < 0
    entry = strategy.position_avg_price
    baseSL = entry + riskDistance
    tp = entry - riskDistance * rrTarget
    lp = entry - (entry - tp) * (lockProfitPct / 100.0)
    trigger = entry - (entry - tp) * (moveAtProfitPct / 100.0)

    if not lpArmed and low <= trigger
        lpArmed := true
        lpActivatedThisBar := true

    exitSL = lpArmed ? lp : baseSL
    strategy.exit("Short Exit", from_entry="Short", stop=exitSL, limit=tp, alert_message='{"action":"EXIT_SHORT","symbol":"{{ticker}}"}')

//--------------------------------------------------
// Visual Trade Lines
//--------------------------------------------------
newLongPos = strategy.position_size > 0 and strategy.position_size[1] == 0
newShortPos = strategy.position_size < 0 and strategy.position_size[1] == 0
flatNow = strategy.position_size == 0 and strategy.position_size[1] != 0

if showTradeLines and (newLongPos or newShortPos)
    visualEntryBar := bar_index
    visualEntryPrice := strategy.position_avg_price
    lpArmed := false

    visualRisk = slTicks * syminfo.mintick
    visualBaseSL := newLongPos ? visualEntryPrice - visualRisk : visualEntryPrice + visualRisk
    visualTP := newLongPos ? visualEntryPrice + visualRisk * rrTarget : visualEntryPrice - visualRisk * rrTarget
    visualLP := newLongPos ? visualEntryPrice + (visualTP - visualEntryPrice) * (lockProfitPct / 100.0) : visualEntryPrice - (visualEntryPrice - visualTP) * (lockProfitPct / 100.0)

    activeEntryLine := line.new(bar_index, visualEntryPrice, bar_index, visualEntryPrice, xloc=xloc.bar_index, color=entryLineCol, width=2)
    activeSLLine := line.new(bar_index, visualBaseSL, bar_index, visualBaseSL, xloc=xloc.bar_index, color=slLineCol, width=2)
    activeTPLine := line.new(bar_index, visualTP, bar_index, visualTP, xloc=xloc.bar_index, color=tpLineCol, width=2)

    activeEntryLabel := label.new(bar_index, visualEntryPrice, f_tradeText("ETY", visualEntryPrice, visualEntryPrice, false), xloc=xloc.bar_index, style=label.style_none, textcolor=entryLineCol, color=color.new(color.black, 100), size=tradeTextSize)
    activeSLLabel := label.new(bar_index, visualBaseSL, f_tradeText("SL", visualBaseSL, visualEntryPrice, true), xloc=xloc.bar_index, style=label.style_none, textcolor=slLineCol, color=color.new(color.black, 100), size=tradeTextSize)
    activeTPLabel := label.new(bar_index, visualTP, f_tradeText("TP", visualTP, visualEntryPrice, true), xloc=xloc.bar_index, style=label.style_none, textcolor=tpLineCol, color=color.new(color.black, 100), size=tradeTextSize)

if showTradeLines and strategy.position_size != 0 and not na(activeEntryLine)
    isLong = strategy.position_size > 0
    lpTrigger = isLong ? visualEntryPrice + (visualTP - visualEntryPrice) * (moveAtProfitPct / 100.0) : visualEntryPrice - (visualEntryPrice - visualTP) * (moveAtProfitPct / 100.0)

    if (isLong and high >= lpTrigger) or (not isLong and low <= lpTrigger)
        lpArmed := true

    if lpArmed and na(activeLPLine)
        activeLPLine := line.new(visualEntryBar, visualLP, bar_index, visualLP, xloc=xloc.bar_index, color=lpLineCol, width=2)
        activeLPLabel := label.new(bar_index, visualLP, f_tradeText("LP", visualLP, visualEntryPrice, true), xloc=xloc.bar_index, style=label.style_none, textcolor=lpLineCol, color=color.new(color.black, 100), size=tradeTextSize)

    line.set_x2(activeEntryLine, bar_index)
    line.set_x2(activeSLLine, bar_index)
    line.set_x2(activeTPLine, bar_index)

    if not na(activeLPLine)
        line.set_x2(activeLPLine, bar_index)

    midX = math.round((visualEntryBar + bar_index) / 2)

    label.set_x(activeEntryLabel, midX)
    label.set_y(activeEntryLabel, visualEntryPrice)
    label.set_text(activeEntryLabel, f_tradeText("ETY", visualEntryPrice, visualEntryPrice, false))
    label.set_size(activeEntryLabel, tradeTextSize)

    label.set_x(activeSLLabel, midX)
    label.set_y(activeSLLabel, visualBaseSL)
    label.set_text(activeSLLabel, f_tradeText("SL", visualBaseSL, visualEntryPrice, true))
    label.set_size(activeSLLabel, tradeTextSize)

    label.set_x(activeTPLabel, midX)
    label.set_y(activeTPLabel, visualTP)
    label.set_text(activeTPLabel, f_tradeText("TP", visualTP, visualEntryPrice, true))
    label.set_size(activeTPLabel, tradeTextSize)

    if not na(activeLPLabel)
        label.set_x(activeLPLabel, midX)
        label.set_y(activeLPLabel, visualLP)
        label.set_text(activeLPLabel, f_tradeText("LP", visualLP, visualEntryPrice, true))
        label.set_size(activeLPLabel, tradeTextSize)

    moveTicks = isLong ? math.round((close - visualEntryPrice) / syminfo.mintick) : math.round((visualEntryPrice - close) / syminfo.mintick)
    moveCol = moveTicks > 0 ? moveProfitCol : moveTicks < 0 ? moveLossCol : moveFlatCol
    moveSign = moveTicks > 0 ? "+" : ""
    moveText = "PRICE " + f_price(close) + " | " + moveSign + str.tostring(moveTicks) + " ticks"

    if showMoveLabel
        if na(activeMoveLabel)
            activeMoveLabel := label.new(bar_index, close, moveText, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.black, 80), textcolor=moveCol, size=tradeTextSize)
        else
            label.set_x(activeMoveLabel, bar_index)
            label.set_y(activeMoveLabel, close)
            label.set_text(activeMoveLabel, moveText)
            label.set_textcolor(activeMoveLabel, moveCol)
            label.set_size(activeMoveLabel, tradeTextSize)

//--------------------------------------------------
// Result Markers
//--------------------------------------------------
plotshape(showLPSigs and lpActivatedThisBar, title="LP Activated", style=shape.triangleup, location=location.belowbar, color=color.orange, size=size.small, text="LP")

longTPHit = strategy.position_size[1] > 0 and not na(visualTP) and high >= visualTP
shortTPHit = strategy.position_size[1] < 0 and not na(visualTP) and low <= visualTP

longSLHit = strategy.position_size[1] > 0 and not lpArmed[1] and not na(visualBaseSL) and low <= visualBaseSL
shortSLHit = strategy.position_size[1] < 0 and not lpArmed[1] and not na(visualBaseSL) and high >= visualBaseSL

longLPHit = strategy.position_size[1] > 0 and lpArmed[1] and not na(visualLP) and low <= visualLP and high < visualTP
shortLPHit = strategy.position_size[1] < 0 and lpArmed[1] and not na(visualLP) and high >= visualLP and low > visualTP

if flatNow
    if longTPHit or shortTPHit
        f_resultLabel("✓", visualTP, color.lime)
    else if longLPHit or shortLPHit
        f_resultLabel("✓", visualLP, color.orange)
    else if longSLHit or shortSLHit
        f_resultLabel("X", visualBaseSL, color.red)

    if not na(activeMoveLabel)
        label.delete(activeMoveLabel)

    visualEntryBar := na
    visualEntryPrice := na
    visualBaseSL := na
    visualTP := na
    visualLP := na
    lpArmed := false

    activeEntryLine := na
    activeSLLine := na
    activeTPLine := na
    activeLPLine := na

    activeEntryLabel := na
    activeSLLabel := na
    activeTPLabel := na
    activeLPLabel := na
    activeMoveLabel := na

//--------------------------------------------------
// Live ZigZag Line
//--------------------------------------------------
var line liveLine = na

if barstate.islast
    if not na(liveLine)
        line.delete(liveLine)
        liveLine := na

    if showZigZagLines and extendLast
        if swingDir == 1 and not na(lastLowPrice) and not na(lastLowIdx)
            liveLine := line.new(lastLowIdx, lastLowPrice, bar_index, close, xloc=xloc.bar_index, color=bullCol, width=2, extend=extend.none)
        else if swingDir == -1 and not na(lastHighPrice) and not na(lastHighIdx)
            liveLine := line.new(lastHighIdx, lastHighPrice, bar_index, close, xloc=xloc.bar_index, color=bearCol, width=2, extend=extend.none)

//--------------------------------------------------
// Plots
//--------------------------------------------------
plot(showEMA1 ? emaSmall : na, "EMA Small", color=color.yellow, linewidth=2)
plot(showEMA2 ? emaBig : na, "EMA Big", color=color.red, linewidth=2)

plotshape(showConfirmSigs and bullConfirmation, title="BUY Confirmation", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, text="CONF")
plotshape(showConfirmSigs and bearConfirmation, title="SELL Confirmation", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="CONF")

plot(showPoints and btm ? low[length] : na, "Low Points", color=pointLowCol, style=plot.style_circles, offset=-length, linewidth=2)
plot(showPoints and top ? high[length] : na, "High Points", color=pointHiCol, style=plot.style_circles, offset=-length, linewidth=2)
````
