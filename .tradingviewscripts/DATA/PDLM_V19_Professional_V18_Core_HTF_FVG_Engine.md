<!-- tradingview-pine-id: PUB;365a39d752ff47c58de67085b890807a -->
<!-- tradingviewscripts-format: 1 -->
# PDLM V19 Professional - V18 Core + HTF FVG Engine

Source: https://www.tradingview.com/script/1FDNYAo8-PDLM-V19-Professional-V18-Core-HTF-FVG-Engine/

## Description

gold trading strategy, with buy and sell signals during asia sessions

---

## Source Code

````pine
//@version=6
indicator("PDLM V19 Professional - V18 Core + HTF FVG Engine", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// INPUTS
groupSessions = "Sessions"
tz = input.string("Asia/Tokyo", "Session Timezone", group=groupSessions)
pmSession = input.session("1300-1600", "PM Session", group=groupSessions)
asiaMSession = input.session("0800-0900", "Asia M Session", group=groupSessions)
asiaDSession = input.session("0900-0930", "Asia D Session", group=groupSessions)
londonSession = input.session("1600-1900", "London Session", group=groupSessions)

groupLogic = "Core Logic"
dispMult = input.float(1.1, "Displacement Strength", step=0.1, group=groupLogic)
midBuffer = input.float(2.0, "Midpoint Buffer Points", step=0.5, group=groupLogic)
rr = input.float(3.0, "Risk Reward", step=0.5, group=groupLogic)

groupRegime = "Regime Detection"
midCrossThreshold = input.int(3, "Midpoint Crosses For Range", minval=1, group=groupRegime)
overlapLength = input.int(10, "Overlap Lookback", minval=2, group=groupRegime)
overlapThreshold = input.float(0.65, "Average Overlap Threshold", minval=0.0, maxval=1.0, step=0.05, group=groupRegime)

groupManager = "Trade Manager"
mode = input.string("Research", "Mode", options=["Asia Only", "London Only", "Adaptive", "Research"], group=groupManager)
oneTradePerCycle = input.bool(true, "One Official Trade Per Cycle", group=groupManager)
cooldownBars = input.int(15, "Signal Cooldown Bars", minval=0, group=groupManager)
allowOppositeReversal = input.bool(true, "Allow Opposite Reversal", group=groupManager)
resetOnMidFailure = input.bool(true, "Reset Lock On Midpoint Failure", group=groupManager)

groupRisk = "Risk Management"
atrLength = input.int(14, "ATR Length", minval=1, group=groupRisk)
stopAtrBuffer = input.float(0.15, "Stop ATR Buffer", step=0.05, group=groupRisk)
stopMode = input.string("Structural", "Stop Placement", options=["Structural", "Confirmation Candle", "Asia Extreme"], group=groupRisk)

groupDisplay = "Display"
showPanel = input.bool(true, "Show Panel", group=groupDisplay)
showBoxes = input.bool(true, "Show Session Boxes", group=groupDisplay)
showTradeLines = input.bool(true, "Show Entry / Invalidation / SL / TP", group=groupDisplay)
showRawV5 = input.bool(false, "Show Raw V5 Signals", group=groupDisplay)

// HTF FVG INPUTS
groupFVG = "V19 HTF Fair Value Gaps"
show15mFVG = input.bool(true, "Show 15 Minute FVG", group=groupFVG)
show30mFVG = input.bool(true, "Show 30 Minute FVG", group=groupFVG)
show1hFVG = input.bool(true, "Show 1 Hour FVG", group=groupFVG)
show2hFVG = input.bool(true, "Show 2 Hour FVG", group=groupFVG)
show4hFVG = input.bool(true, "Show 4 Hour FVG", group=groupFVG)
fvgFilterMode = input.string("Block Opposing", "FVG Signal Filter", options=["Off", "Score Only", "Block Opposing"], group=groupFVG)
fvgMitigationMode = input.string("Close Through", "Remove FVG After", options=["First Touch", "Full Fill", "Close Through"], group=groupFVG)
fvgReactionMemory = input.int(120, "FVG Rejection Memory Bars", minval=1, group=groupFVG)
maxActiveFVGs = input.int(80, "Maximum Active FVG Zones", minval=10, maxval=150, group=groupFVG)
showFVGMidpoint = input.bool(true, "Show FVG 50% Level", group=groupFVG)
showBlockedFVGSignals = input.bool(true, "Show Signals Blocked By FVG", group=groupFVG)

bull15Color = input.color(color.new(color.teal, 84), "15M Bullish FVG", group=groupFVG)
bear15Color = input.color(color.new(color.red, 84), "15M Bearish FVG", group=groupFVG)
bull30Color = input.color(color.new(color.aqua, 85), "30M Bullish FVG", group=groupFVG)
bear30Color = input.color(color.new(color.orange, 85), "30M Bearish FVG", group=groupFVG)
bull1hColor = input.color(color.new(color.green, 84), "1H Bullish FVG", group=groupFVG)
bear1hColor = input.color(color.new(color.fuchsia, 84), "1H Bearish FVG", group=groupFVG)
bull2hColor = input.color(color.new(color.blue, 85), "2H Bullish FVG", group=groupFVG)
bear2hColor = input.color(color.new(color.purple, 84), "2H Bearish FVG", group=groupFVG)
bull4hColor = input.color(color.new(color.navy, 82), "4H Bullish FVG", group=groupFVG)
bear4hColor = input.color(color.new(color.maroon, 82), "4H Bearish FVG", group=groupFVG)

// SESSION STATES
inPM = not na(time(timeframe.period, pmSession, tz))
inAsiaM = not na(time(timeframe.period, asiaMSession, tz))
inAsiaD = not na(time(timeframe.period, asiaDSession, tz))
inLondon = not na(time(timeframe.period, londonSession, tz))
newPM = inPM and not inPM[1]
newAsiaM = inAsiaM and not inAsiaM[1]
endAsiaM = not inAsiaM and inAsiaM[1]
newAsiaD = inAsiaD and not inAsiaD[1]
newLondon = inLondon and not inLondon[1]
newDay = ta.change(time("D")) != 0

// DAILY + PM BIAS
dailyOpen = request.security(syminfo.tickerid, "D", open)
dailyBull = close > dailyOpen
dailyBear = close < dailyOpen

var float pmOpen = na
var float pmClose = na
var float pmHigh = na
var float pmLow = na
var bool pmHighSwept = false
var bool pmLowSwept = false

if newPM
    pmOpen := open
    pmClose := close
    pmHigh := high
    pmLow := low
    pmHighSwept := false
    pmLowSwept := false

if inPM
    pmClose := close
    pmHigh := math.max(nz(pmHigh, high), high)
    pmLow := math.min(nz(pmLow, low), low)

if not inPM and not na(pmHigh) and high > pmHigh
    pmHighSwept := true
if not inPM and not na(pmLow) and low < pmLow
    pmLowSwept := true

pmBull = not na(pmOpen) and not na(pmClose) and pmClose > pmOpen
pmBear = not na(pmOpen) and not na(pmClose) and pmClose < pmOpen
bullBiasScore = (dailyBull ? 2 : 0) + (pmBull ? 2 : 0)
bearBiasScore = (dailyBear ? 2 : 0) + (pmBear ? 2 : 0)
biasBull = bullBiasScore >= 2
biasBear = bearBiasScore >= 2

// ASIA M RANGE
var float asiaHigh = na
var float asiaLow = na
var float asiaMid = na
var box asiaBox = na
var line midLine = na
var line midUpperLine = na
var line midLowerLine = na

if newAsiaM
    asiaHigh := high
    asiaLow := low
    asiaMid := na
    if showBoxes
        asiaBox := box.new(bar_index, high, bar_index, low, bgcolor=color.new(color.red, 88), border_color=color.red)

if inAsiaM
    asiaHigh := math.max(nz(asiaHigh, high), high)
    asiaLow := math.min(nz(asiaLow, low), low)
    if showBoxes and not na(asiaBox)
        box.set_right(asiaBox, bar_index)
        box.set_top(asiaBox, asiaHigh)
        box.set_bottom(asiaBox, asiaLow)

if endAsiaM
    asiaMid := (asiaHigh + asiaLow) / 2.0
    if not na(midLine)
        line.delete(midLine)
    if not na(midUpperLine)
        line.delete(midUpperLine)
    if not na(midLowerLine)
        line.delete(midLowerLine)
    midLine := line.new(bar_index, asiaMid, bar_index + 180, asiaMid, color=color.blue, width=2)
    midUpperLine := line.new(bar_index, asiaMid + midBuffer, bar_index + 180, asiaMid + midBuffer, color=color.new(color.blue, 65), style=line.style_dotted)
    midLowerLine := line.new(bar_index, asiaMid - midBuffer, bar_index + 180, asiaMid - midBuffer, color=color.new(color.blue, 65), style=line.style_dotted)

rangeBuilt = not na(asiaHigh) and not na(asiaLow) and not na(asiaMid)
midUpper = rangeBuilt ? asiaMid + midBuffer : na
midLower = rangeBuilt ? asiaMid - midBuffer : na
aboveMid = rangeBuilt and close > asiaMid
belowMid = rangeBuilt and close < asiaMid
touchMidZone = rangeBuilt and high >= midLower and low <= midUpper

// ASIA D
var float asiaDOpen = na
var box asiaDBox = na

if newAsiaD
    asiaDOpen := open
    if showBoxes
        asiaDBox := box.new(bar_index, high, bar_index, low, bgcolor=color.new(color.green, 88), border_color=color.green)

if inAsiaD and showBoxes and not na(asiaDBox)
    box.set_right(asiaDBox, bar_index)
    box.set_top(asiaDBox, math.max(box.get_top(asiaDBox), high))
    box.set_bottom(asiaDBox, math.min(box.get_bottom(asiaDBox), low))

dOpenAbove = rangeBuilt and not na(asiaDOpen) and asiaDOpen > asiaMid
dOpenBelow = rangeBuilt and not na(asiaDOpen) and asiaDOpen < asiaMid

// SWEEPS
sweepHigh = rangeBuilt and high > asiaHigh and close < asiaHigh
sweepLow = rangeBuilt and low < asiaLow and close > asiaLow

var bool highSweptToday = false
var bool lowSweptToday = false
var float latestHighSweep = na
var float latestLowSweep = na

if newDay or newAsiaM
    highSweptToday := false
    lowSweptToday := false
    latestHighSweep := na
    latestLowSweep := na

if sweepHigh
    highSweptToday := true
    latestHighSweep := high
if sweepLow
    lowSweptToday := true
    latestLowSweep := low

failedHighSweep = not highSweptToday
failedLowSweep = not lowSweptToday

// DISPLACEMENT + MSS
body = math.abs(close - open)
avgBody = ta.sma(math.abs(close - open), 20)
bullDisp = close > open and body > avgBody * dispMult
bearDisp = close < open and body > avgBody * dispMult
disp = bullDisp or bearDisp
bullMSS = close > ta.highest(high[1], 5)
bearMSS = close < ta.lowest(low[1], 5)

// FVG ARRAYS
var box[] fvgBoxes = array.new_box()
var line[] fvgMidLines = array.new_line()
var int[] fvgDirections = array.new_int()
var float[] fvgTops = array.new_float()
var float[] fvgBottoms = array.new_float()
var string[] fvgTimeframes = array.new_string()
var int[] fvgWeights = array.new_int()

f_removeFVG(int index) =>
    box currentBox = array.get(fvgBoxes, index)
    line currentMid = array.get(fvgMidLines, index)
    if not na(currentBox)
        box.delete(currentBox)
    if not na(currentMid)
        line.delete(currentMid)
    array.remove(fvgBoxes, index)
    array.remove(fvgMidLines, index)
    array.remove(fvgDirections, index)
    array.remove(fvgTops, index)
    array.remove(fvgBottoms, index)
    array.remove(fvgTimeframes, index)
    array.remove(fvgWeights, index)

f_trimOldFVGs() =>
    while array.size(fvgBoxes) > maxActiveFVGs
        box oldestBox = array.shift(fvgBoxes)
        line oldestMid = array.shift(fvgMidLines)
        if not na(oldestBox)
            box.delete(oldestBox)
        if not na(oldestMid)
            line.delete(oldestMid)
        array.shift(fvgDirections)
        array.shift(fvgTops)
        array.shift(fvgBottoms)
        array.shift(fvgTimeframes)
        array.shift(fvgWeights)

f_addFVG(bool enabled, bool newTfBar, bool bullCondition, bool bearCondition, float bullTop, float bullBottom, float bearTop, float bearBottom, int startingTime, string tfName, int tfWeight, color bullColor, color bearColor) =>
    if enabled and newTfBar and not na(startingTime)
        if bullCondition and bullTop > bullBottom
            float bullMid = (bullTop + bullBottom) / 2.0
            box newBullBox = box.new(left=startingTime, top=bullTop, right=time, bottom=bullBottom, xloc=xloc.bar_time, extend=extend.right, bgcolor=bullColor, border_color=color.new(bullColor, 0), border_width=1, text=tfName + " BULL FVG", text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
            line newBullMid = na
            if showFVGMidpoint
                newBullMid := line.new(x1=startingTime, y1=bullMid, x2=time, y2=bullMid, xloc=xloc.bar_time, extend=extend.right, color=color.new(color.white, 45), style=line.style_dotted, width=1)
            array.push(fvgBoxes, newBullBox)
            array.push(fvgMidLines, newBullMid)
            array.push(fvgDirections, 1)
            array.push(fvgTops, bullTop)
            array.push(fvgBottoms, bullBottom)
            array.push(fvgTimeframes, tfName)
            array.push(fvgWeights, tfWeight)

        if bearCondition and bearTop > bearBottom
            float bearMid = (bearTop + bearBottom) / 2.0
            box newBearBox = box.new(left=startingTime, top=bearTop, right=time, bottom=bearBottom, xloc=xloc.bar_time, extend=extend.right, bgcolor=bearColor, border_color=color.new(bearColor, 0), border_width=1, text=tfName + " BEAR FVG", text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
            line newBearMid = na
            if showFVGMidpoint
                newBearMid := line.new(x1=startingTime, y1=bearMid, x2=time, y2=bearMid, xloc=xloc.bar_time, extend=extend.right, color=color.new(color.white, 45), style=line.style_dotted, width=1)
            array.push(fvgBoxes, newBearBox)
            array.push(fvgMidLines, newBearMid)
            array.push(fvgDirections, -1)
            array.push(fvgTops, bearTop)
            array.push(fvgBottoms, bearBottom)
            array.push(fvgTimeframes, tfName)
            array.push(fvgWeights, tfWeight)

        f_trimOldFVGs()

// FIXED TUPLE DECLARATIONS
[bull15, bear15, bull15Top, bull15Bottom, bear15Top, bear15Bottom, left15] = request.security(syminfo.tickerid, "15", [low[1] > high[3], high[1] < low[3], low[1], high[3], low[3], high[1], time[3]], lookahead=barmerge.lookahead_on)
[bull30, bear30, bull30Top, bull30Bottom, bear30Top, bear30Bottom, left30] = request.security(syminfo.tickerid, "30", [low[1] > high[3], high[1] < low[3], low[1], high[3], low[3], high[1], time[3]], lookahead=barmerge.lookahead_on)
[bull1h, bear1h, bull1hTop, bull1hBottom, bear1hTop, bear1hBottom, left1h] = request.security(syminfo.tickerid, "60", [low[1] > high[3], high[1] < low[3], low[1], high[3], low[3], high[1], time[3]], lookahead=barmerge.lookahead_on)
[bull2h, bear2h, bull2hTop, bull2hBottom, bear2hTop, bear2hBottom, left2h] = request.security(syminfo.tickerid, "120", [low[1] > high[3], high[1] < low[3], low[1], high[3], low[3], high[1], time[3]], lookahead=barmerge.lookahead_on)
[bull4h, bear4h, bull4hTop, bull4hBottom, bear4hTop, bear4hBottom, left4h] = request.security(syminfo.tickerid, "240", [low[1] > high[3], high[1] < low[3], low[1], high[3], low[3], high[1], time[3]], lookahead=barmerge.lookahead_on)

new15Bar = ta.change(time("15")) != 0
new30Bar = ta.change(time("30")) != 0
new1hBar = ta.change(time("60")) != 0
new2hBar = ta.change(time("120")) != 0
new4hBar = ta.change(time("240")) != 0

f_addFVG(show15mFVG, new15Bar, bull15, bear15, bull15Top, bull15Bottom, bear15Top, bear15Bottom, left15, "15M", 1, bull15Color, bear15Color)
f_addFVG(show30mFVG, new30Bar, bull30, bear30, bull30Top, bull30Bottom, bear30Top, bear30Bottom, left30, "30M", 2, bull30Color, bear30Color)
f_addFVG(show1hFVG, new1hBar, bull1h, bear1h, bull1hTop, bull1hBottom, bear1hTop, bear1hBottom, left1h, "1H", 3, bull1hColor, bear1hColor)
f_addFVG(show2hFVG, new2hBar, bull2h, bear2h, bull2hTop, bull2hBottom, bear2hTop, bear2hBottom, left2h, "2H", 4, bull2hColor, bear2hColor)
f_addFVG(show4hFVG, new4hBar, bull4h, bear4h, bull4hTop, bull4hBottom, bear4hTop, bear4hBottom, left4h, "4H", 5, bull4hColor, bear4hColor)

// ACTIVE FVG CONTEXT
var int lastBullFVGRejectionBar = na
var int lastBearFVGRejectionBar = na

int bullishFVGCount = 0
int bearishFVGCount = 0
int bullishFVGWeight = 0
int bearishFVGWeight = 0
string strongestBullFVG = "None"
string strongestBearFVG = "None"
bool insideBullFVG = false
bool insideBearFVG = false

int fvgIndex = array.size(fvgBoxes) - 1

while fvgIndex >= 0
    int currentDirection = array.get(fvgDirections, fvgIndex)
    float currentTop = array.get(fvgTops, fvgIndex)
    float currentBottom = array.get(fvgBottoms, fvgIndex)
    string currentTF = array.get(fvgTimeframes, fvgIndex)
    int currentWeight = array.get(fvgWeights, fvgIndex)

    bool candleOverlapsZone = high >= currentBottom and low <= currentTop
    bool closeInsideZone = close <= currentTop and close >= currentBottom
    bool removeCurrentFVG = false

    if currentDirection == 1
        if closeInsideZone
            insideBullFVG := true
            bullishFVGCount += 1
            if currentWeight > bullishFVGWeight
                bullishFVGWeight := currentWeight
                strongestBullFVG := currentTF

        bool bullishRejection = low <= currentTop and close > currentTop
        if bullishRejection
            lastBullFVGRejectionBar := bar_index

        bool bullishFirstTouch = candleOverlapsZone
        bool bullishFullFill = low <= currentBottom
        bool bullishCloseThrough = close < currentBottom
        removeCurrentFVG := fvgMitigationMode == "First Touch" ? bullishFirstTouch : fvgMitigationMode == "Full Fill" ? bullishFullFill : bullishCloseThrough

    if currentDirection == -1
        if closeInsideZone
            insideBearFVG := true
            bearishFVGCount += 1
            if currentWeight > bearishFVGWeight
                bearishFVGWeight := currentWeight
                strongestBearFVG := currentTF

        bool bearishRejection = high >= currentBottom and close < currentBottom
        if bearishRejection
            lastBearFVGRejectionBar := bar_index

        bool bearishFirstTouch = candleOverlapsZone
        bool bearishFullFill = high >= currentTop
        bool bearishCloseThrough = close > currentTop
        removeCurrentFVG := fvgMitigationMode == "First Touch" ? bearishFirstTouch : fvgMitigationMode == "Full Fill" ? bearishFullFill : bearishCloseThrough

    if removeCurrentFVG
        f_removeFVG(fvgIndex)

    fvgIndex -= 1

recentBullFVGRejection = not na(lastBullFVGRejectionBar) and bar_index - lastBullFVGRejectionBar <= fvgReactionMemory
recentBearFVGRejection = not na(lastBearFVGRejectionBar) and bar_index - lastBearFVGRejectionBar <= fvgReactionMemory
bullFVGSupport = insideBullFVG or recentBullFVGRejection
bearFVGResistance = insideBearFVG or recentBearFVGRejection
bullFVGScoreBonus = insideBullFVG ? (bullishFVGCount >= 2 ? 3 : 2) : recentBullFVGRejection ? 1 : 0
bearFVGScoreBonus = insideBearFVG ? (bearishFVGCount >= 2 ? 3 : 2) : recentBearFVGRejection ? 1 : 0

// V5 CORE SIGNALS
typeA_Buy = biasBull and rangeBuilt and sweepLow and bullDisp and bullMSS
typeA_Sell = biasBear and rangeBuilt and sweepHigh and bearDisp and bearMSS
typeB_Buy = biasBull and rangeBuilt and inAsiaD and dOpenAbove and failedLowSweep and aboveMid and bullDisp
typeB_Sell = biasBear and rangeBuilt and inAsiaD and dOpenBelow and failedHighSweep and belowMid and bearDisp
typeC_Buy = biasBull and rangeBuilt and touchMidZone and close > asiaMid and bullDisp
typeC_Sell = biasBear and rangeBuilt and touchMidZone and close < asiaMid and bearDisp
typeD_Buy = biasBull and rangeBuilt and inAsiaD and low <= midUpper and close > asiaMid and bullDisp
typeD_Sell = biasBear and rangeBuilt and inAsiaD and high >= midLower and close < asiaMid and bearDisp
typeE_Buy = biasBull and rangeBuilt and lowSweptToday and close > asiaMid and low <= midUpper and close > midLower and bullDisp
typeE_Sell = biasBear and rangeBuilt and highSweptToday and close < asiaMid and high >= midLower and close < midUpper and bearDisp
v5BuyRaw = typeE_Buy or typeA_Buy or typeB_Buy or typeC_Buy or typeD_Buy
v5SellRaw = typeE_Sell or typeA_Sell or typeB_Sell or typeC_Sell or typeD_Sell

// RANGE / REGIME
var int midCrosses = 0
var int lastOuterSide = 0
outerSide = not rangeBuilt ? 0 : close > midUpper ? 1 : close < midLower ? -1 : 0

if newAsiaM
    midCrosses := 0
    lastOuterSide := 0

if rangeBuilt and not inAsiaM
    if outerSide != 0 and lastOuterSide != 0 and outerSide != lastOuterSide
        midCrosses += 1
    if outerSide != 0
        lastOuterSide := outerSide

barRange = math.max(high - low, syminfo.mintick)
priorRange = math.max(high[1] - low[1], syminfo.mintick)
overlapPoints = math.max(0.0, math.min(high, high[1]) - math.max(low, low[1]))
overlapRatio = overlapPoints / math.min(barRange, priorRange)
avgOverlap = ta.sma(overlapRatio, overlapLength)
asiaRangeRegime = rangeBuilt and (midCrosses >= midCrossThreshold or avgOverlap >= overlapThreshold)
asiaTrendRegime = rangeBuilt and not asiaRangeRegime

// LONDON MODEL
londonBuy = inLondon and rangeBuilt and biasBull and lowSweptToday and bullDisp and bullMSS and close > asiaMid
londonSell = inLondon and rangeBuilt and biasBear and highSweptToday and bearDisp and bearMSS and close < asiaMid

// MODE + FVG FILTER
allowAsia = mode == "Asia Only" or mode == "Research" or (mode == "Adaptive" and asiaTrendRegime)
allowLondon = mode == "London Only" or mode == "Research" or (mode == "Adaptive" and asiaRangeRegime)
candidateBuyBase = (allowAsia and v5BuyRaw) or (allowLondon and londonBuy)
candidateSellBase = (allowAsia and v5SellRaw) or (allowLondon and londonSell)
buyBlockedByFVG = fvgFilterMode == "Block Opposing" and bearFVGResistance and not bullFVGSupport
sellBlockedByFVG = fvgFilterMode == "Block Opposing" and bullFVGSupport and not bearFVGResistance
blockedBuySignal = candidateBuyBase and buyBlockedByFVG
blockedSellSignal = candidateSellBase and sellBlockedByFVG
candidateBuy = candidateBuyBase and not buyBlockedByFVG
candidateSell = candidateSellBase and not sellBlockedByFVG

// TRADE MANAGER
var int directionLock = 0
var int lastOfficialSignalBar = na
var bool cycleTraded = false

if newDay or newAsiaM or newLondon
    cycleTraded := false

midpointFailure = rangeBuilt and ((directionLock == 1 and close < midLower) or (directionLock == -1 and close > midUpper))

if resetOnMidFailure and midpointFailure
    directionLock := 0

if allowOppositeReversal
    if directionLock == 1 and candidateSell
        directionLock := 0
    if directionLock == -1 and candidateBuy
        directionLock := 0

cooldownOK = na(lastOfficialSignalBar) or bar_index - lastOfficialSignalBar >= cooldownBars
cycleOK = not oneTradePerCycle or not cycleTraded
officialBuy = candidateBuy and directionLock != 1 and cooldownOK and cycleOK
officialSell = candidateSell and directionLock != -1 and cooldownOK and cycleOK

if officialBuy
    directionLock := 1
    lastOfficialSignalBar := bar_index
    cycleTraded := true

if officialSell
    directionLock := -1
    lastOfficialSignalBar := bar_index
    cycleTraded := true

// SCORE
bullScore = bullBiasScore
bullScore += lowSweptToday ? 2 : 0
bullScore += rangeBuilt and close > asiaMid ? 2 : 0
bullScore += bullDisp ? 1 : 0
bullScore += bullMSS ? 1 : 0
bullScore += not pmLowSwept ? 1 : 0
bullScore += inLondon and asiaRangeRegime ? 1 : 0
bullScore += fvgFilterMode != "Off" ? bullFVGScoreBonus : 0

bearScore = bearBiasScore
bearScore += highSweptToday ? 2 : 0
bearScore += rangeBuilt and close < asiaMid ? 2 : 0
bearScore += bearDisp ? 1 : 0
bearScore += bearMSS ? 1 : 0
bearScore += not pmHighSwept ? 1 : 0
bearScore += inLondon and asiaRangeRegime ? 1 : 0
bearScore += fvgFilterMode != "Off" ? bearFVGScoreBonus : 0

activeScore = officialBuy ? bullScore : officialSell ? bearScore : math.max(bullScore, bearScore)
grade = activeScore >= 11 ? "A+" : activeScore >= 8 ? "A" : activeScore >= 6 ? "B" : "PASS"

// RISK
atr = ta.atr(atrLength)
buyStructuralInvalidation = not na(latestLowSweep) ? latestLowSweep : rangeBuilt ? math.min(asiaLow, low) : low
sellStructuralInvalidation = not na(latestHighSweep) ? latestHighSweep : rangeBuilt ? math.max(asiaHigh, high) : high
buyInvalidation = stopMode == "Confirmation Candle" ? low : stopMode == "Asia Extreme" and rangeBuilt ? asiaLow : buyStructuralInvalidation
sellInvalidation = stopMode == "Confirmation Candle" ? high : stopMode == "Asia Extreme" and rangeBuilt ? asiaHigh : sellStructuralInvalidation
buySL = buyInvalidation - atr * stopAtrBuffer
sellSL = sellInvalidation + atr * stopAtrBuffer
buyRisk = close - buySL
sellRisk = sellSL - close
buyTP = close + buyRisk * rr
sellTP = close - sellRisk * rr
validBuyRisk = buyRisk > syminfo.mintick
validSellRisk = sellRisk > syminfo.mintick

var line entryLine = na
var line invalidLine = na
var line slLine = na
var line tpLine = na
var label tradeLabel = na

clearTradeObjects() =>
    if not na(entryLine)
        line.delete(entryLine)
    if not na(invalidLine)
        line.delete(invalidLine)
    if not na(slLine)
        line.delete(slLine)
    if not na(tpLine)
        line.delete(tpLine)
    if not na(tradeLabel)
        label.delete(tradeLabel)

if showTradeLines and officialBuy and validBuyRisk
    clearTradeObjects()
    entryLine := line.new(bar_index, close, bar_index + 60, close, color=color.blue, width=2)
    invalidLine := line.new(bar_index, buyInvalidation, bar_index + 60, buyInvalidation, color=color.orange, width=2, style=line.style_dashed)
    slLine := line.new(bar_index, buySL, bar_index + 60, buySL, color=color.red, width=2)
    tpLine := line.new(bar_index, buyTP, bar_index + 60, buyTP, color=color.green, width=2)
    tradeLabel := label.new(bar_index, low, "PDLM BUY " + grade + "\nEntry: " + str.tostring(close, format.mintick) + "\nInvalid: " + str.tostring(buyInvalidation, format.mintick) + "\nSL: " + str.tostring(buySL, format.mintick) + "\nTP: " + str.tostring(buyTP, format.mintick) + "\nRR: 1:" + str.tostring(rr), style=label.style_label_up, color=color.green, textcolor=color.white)

if showTradeLines and officialSell and validSellRisk
    clearTradeObjects()
    entryLine := line.new(bar_index, close, bar_index + 60, close, color=color.blue, width=2)
    invalidLine := line.new(bar_index, sellInvalidation, bar_index + 60, sellInvalidation, color=color.orange, width=2, style=line.style_dashed)
    slLine := line.new(bar_index, sellSL, bar_index + 60, sellSL, color=color.red, width=2)
    tpLine := line.new(bar_index, sellTP, bar_index + 60, sellTP, color=color.green, width=2)
    tradeLabel := label.new(bar_index, high, "PDLM SELL " + grade + "\nEntry: " + str.tostring(close, format.mintick) + "\nInvalid: " + str.tostring(sellInvalidation, format.mintick) + "\nSL: " + str.tostring(sellSL, format.mintick) + "\nTP: " + str.tostring(sellTP, format.mintick) + "\nRR: 1:" + str.tostring(rr), style=label.style_label_down, color=color.red, textcolor=color.white)

// PLOTS
plotshape(officialBuy, title="Official Buy", text="PDLM\nBUY", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.small)
plotshape(officialSell, title="Official Sell", text="PDLM\nSELL", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.small)
plotshape(showBlockedFVGSignals and blockedBuySignal, title="Buy Blocked By Bearish HTF FVG", text="BUY\nBLOCKED\nHTF FVG", style=shape.labelup, location=location.belowbar, color=color.gray, textcolor=color.white, size=size.tiny)
plotshape(showBlockedFVGSignals and blockedSellSignal, title="Sell Blocked By Bullish HTF FVG", text="SELL\nBLOCKED\nHTF FVG", style=shape.labeldown, location=location.abovebar, color=color.gray, textcolor=color.white, size=size.tiny)

plotshape(showRawV5 and typeE_Buy, title="Raw E Buy", text="E+", style=shape.triangleup, location=location.belowbar, color=color.yellow, size=size.tiny)
plotshape(showRawV5 and typeE_Sell, title="Raw E Sell", text="E+", style=shape.triangledown, location=location.abovebar, color=color.yellow, size=size.tiny)
plotshape(showRawV5 and typeA_Buy, title="Raw A Buy", text="A", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.tiny)
plotshape(showRawV5 and typeA_Sell, title="Raw A Sell", text="A", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny)
plotshape(showRawV5 and typeB_Buy, title="Raw B Buy", text="B", style=shape.triangleup, location=location.belowbar, color=color.teal, size=size.tiny)
plotshape(showRawV5 and typeB_Sell, title="Raw B Sell", text="B", style=shape.triangledown, location=location.abovebar, color=color.orange, size=size.tiny)
plotshape(showRawV5 and typeC_Buy, title="Raw C Buy", text="C", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.tiny)
plotshape(showRawV5 and typeC_Sell, title="Raw C Sell", text="C", style=shape.triangledown, location=location.abovebar, color=color.maroon, size=size.tiny)
plotshape(showRawV5 and typeD_Buy, title="Raw D Buy", text="D", style=shape.triangleup, location=location.belowbar, color=color.aqua, size=size.tiny)
plotshape(showRawV5 and typeD_Sell, title="Raw D Sell", text="D", style=shape.triangledown, location=location.abovebar, color=color.purple, size=size.tiny)

// PANEL
var table panel = table.new(position.top_right, 2, 22, border_width=1)
sessionPlan = mode == "Asia Only" ? "ASIA ONLY" : mode == "London Only" ? "LONDON ONLY" : mode == "Research" ? "RESEARCH BOTH" : asiaRangeRegime ? "WAIT FOR LONDON" : "ASIA ELIGIBLE"
status = officialBuy ? "BUY" : officialSell ? "SELL" : "WAIT"
activeType = officialBuy and londonBuy ? "London Buy" : officialSell and londonSell ? "London Sell" : officialBuy ? "Asia Buy" : officialSell ? "Asia Sell" : "Waiting"
fvgContextText = insideBearFVG ? "INSIDE BEAR FVG" : insideBullFVG ? "INSIDE BULL FVG" : recentBearFVGRejection ? "BEAR REJECTION" : recentBullFVGRejection ? "BULL REJECTION" : "NEUTRAL"
strongestFVGText = insideBearFVG ? strongestBearFVG + " BEAR" : insideBullFVG ? strongestBullFVG + " BULL" : recentBearFVGRejection ? "BEAR REJECTION" : recentBullFVGRejection ? "BULL REJECTION" : "NONE"
fvgPermissionText = buyBlockedByFVG ? "BUY BLOCKED" : sellBlockedByFVG ? "SELL BLOCKED" : "BOTH ELIGIBLE"

if showPanel and barstate.islast
    table.cell(panel, 0, 0, "PDLM V19 PRO", bgcolor=color.black, text_color=color.white)
    table.cell(panel, 1, 0, status, bgcolor=color.black, text_color=color.white)
    table.cell(panel, 0, 1, "Mode")
    table.cell(panel, 1, 1, mode)
    table.cell(panel, 0, 2, "Session Plan")
    table.cell(panel, 1, 2, sessionPlan)
    table.cell(panel, 0, 3, "Active Type")
    table.cell(panel, 1, 3, activeType)
    table.cell(panel, 0, 4, "Score")
    table.cell(panel, 1, 4, str.tostring(activeScore) + "/15")
    table.cell(panel, 0, 5, "Grade")
    table.cell(panel, 1, 5, grade)
    table.cell(panel, 0, 6, "Daily Bias")
    table.cell(panel, 1, 6, dailyBull ? "Bullish" : dailyBear ? "Bearish" : "Neutral")
    table.cell(panel, 0, 7, "PM Bias")
    table.cell(panel, 1, 7, pmBull ? "Bullish" : pmBear ? "Bearish" : "Neutral")
    table.cell(panel, 0, 8, "PM High")
    table.cell(panel, 1, 8, pmHighSwept ? "Swept" : "Untaken")
    table.cell(panel, 0, 9, "PM Low")
    table.cell(panel, 1, 9, pmLowSwept ? "Swept" : "Untaken")
    table.cell(panel, 0, 10, "Asia High")
    table.cell(panel, 1, 10, highSweptToday ? "Swept" : "Untaken")
    table.cell(panel, 0, 11, "Asia Low")
    table.cell(panel, 1, 11, lowSweptToday ? "Swept" : "Untaken")
    table.cell(panel, 0, 12, "Mid Crosses")
    table.cell(panel, 1, 12, str.tostring(midCrosses))
    table.cell(panel, 0, 13, "Avg Overlap")
    table.cell(panel, 1, 13, str.tostring(avgOverlap * 100.0, "#.0") + "%")
    table.cell(panel, 0, 14, "Regime")
    table.cell(panel, 1, 14, asiaRangeRegime ? "RANGE" : "TREND POSSIBLE")
    table.cell(panel, 0, 15, "Midpoint")
    table.cell(panel, 1, 15, aboveMid ? "Above" : belowMid ? "Below" : "Neutral")
    table.cell(panel, 0, 16, "Displacement")
    table.cell(panel, 1, 16, disp ? "YES" : "NO")
    table.cell(panel, 0, 17, "Trade Lock")
    table.cell(panel, 1, 17, directionLock == 1 ? "BUY LOCK" : directionLock == -1 ? "SELL LOCK" : "OPEN")
    table.cell(panel, 0, 18, "HTF FVG Context")
    table.cell(panel, 1, 18, fvgContextText)
    table.cell(panel, 0, 19, "Strongest FVG")
    table.cell(panel, 1, 19, strongestFVGText)
    table.cell(panel, 0, 20, "FVG Confluence")
    table.cell(panel, 1, 20, "Bull " + str.tostring(bullishFVGCount) + " / Bear " + str.tostring(bearishFVGCount))
    table.cell(panel, 0, 21, "FVG Permission")
    table.cell(panel, 1, 21, fvgPermissionText)

// ALERTS
alertcondition(officialBuy, title="PDLM V19 Pro Buy", message="PDLM V19 PRO BUY. Check Entry, Invalidation, SL and TP.")
alertcondition(officialSell, title="PDLM V19 Pro Sell", message="PDLM V19 PRO SELL. Check Entry, Invalidation, SL and TP.")
alertcondition(asiaRangeRegime and not asiaRangeRegime[1], title="PDLM Asia Range Detected", message="PDLM V19 PRO: Asia range detected. Adaptive mode will wait for London.")
alertcondition(blockedBuySignal, title="PDLM V19 Buy Blocked By HTF FVG", message="PDLM V19: A V18 buy setup was blocked because bearish HTF FVG resistance is active.")
alertcondition(blockedSellSignal, title="PDLM V19 Sell Blocked By HTF FVG", message="PDLM V19: A V18 sell setup was blocked because bullish HTF FVG support is active.")
alertcondition(insideBullFVG and not insideBullFVG[1], title="Price Entered Bullish HTF FVG", message="PDLM V19: Price entered an active bullish higher-timeframe FVG.")
alertcondition(insideBearFVG and not insideBearFVG[1], title="Price Entered Bearish HTF FVG", message="PDLM V19: Price entered an active bearish higher-timeframe FVG.")
alertcondition(recentBullFVGRejection and not recentBullFVGRejection[1], title="Bullish HTF FVG Rejection", message="PDLM V19: Price rejected an active bullish higher-timeframe FVG.")
alertcondition(recentBearFVGRejection and not recentBearFVGRejection[1], title="Bearish HTF FVG Rejection", message="PDLM V19: Price rejected an active bearish higher-timeframe FVG.")
````
