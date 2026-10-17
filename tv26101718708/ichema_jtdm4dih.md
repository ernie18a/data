# ichema

- url: https://www.tradingview.com/script/jtDm4DiH-ichema/
- type: indicator
- pine_id: PUB;c159b32b5d004aae8eb543afbf513230
- version: 1.0

## Description

ichi bounce with ema cross, enter on bounce, exit on pass through

## Source Code

````pine
//@version=6
indicator(title="EMA Ichimoku Cloud Bounce Indicator - 24/7", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
fastEmaLen = input.int(9, "Fast EMA Length", minval=1)
slowEmaLen = input.int(14, "Slow EMA Length", minval=1)

conversionPeriods = input.int(9, "Ichimoku Conversion Length", minval=1)
basePeriods = input.int(26, "Ichimoku Base Length", minval=1)
spanBPeriods = input.int(52, "Ichimoku Leading Span B Length", minval=1)
displacement = input.int(26, "Ichimoku Cloud Displacement", minval=1)

useVisibleShiftedCloudForLogic = input.bool(true, "Use Visible Shifted Cloud For Logic")
pullbackMode = input.string("Touch or near cloud edge", "Cloud Pullback Rule", options=["Close inside cloud", "Wick enters cloud", "Touch cloud edge", "Touch or near cloud edge"])
cloudEdgeBufferAtr = input.float(0.05, "Cloud Edge Retest Buffer In ATR", minval=0.0, step=0.01)

maxBarsAfterCloudBreak = input.int(100, "Max Bars After Cloud Break To Wait For EMAs", minval=1)
invalidateSetupOnOppositeClose = input.bool(true, "Invalidate Setup If Price Closes Through Opposite Side Of Cloud")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Chop Filters
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
useAdxFilter = input.bool(true, "Use ADX Trend Strength Filter")
adxLen = input.int(14, "ADX Length", minval=1)
adxSmoothing = input.int(14, "ADX Smoothing", minval=1)
minAdx = input.float(18.0, "Minimum ADX", minval=1.0, step=0.5)

useAdxRisingFilter = input.bool(false, "Require ADX Rising")
adxRisingLookback = input.int(3, "ADX Rising Lookback Bars", minval=1)

useCloudThicknessFilter = input.bool(true, "Use Cloud Thickness Filter")
atrLen = input.int(14, "ATR Length", minval=1)
minCloudThicknessAtr = input.float(0.12, "Minimum Cloud Thickness In ATR", minval=0.0, step=0.01)

useCloudSlopeFilter = input.bool(true, "Use Cloud Slope Filter")
cloudSlopeBars = input.int(5, "Cloud Slope Lookback Bars", minval=1)
minCloudSlopeAtr = input.float(0.02, "Minimum Cloud Slope In ATR", minval=0.0, step=0.01)

useEmaSpreadFilter = input.bool(true, "Use EMA Spread Filter")
minEmaSpreadAtr = input.float(0.04, "Minimum EMA Spread In ATR", minval=0.0, step=0.01)

useEmaSlopeFilter = input.bool(true, "Use EMA Slope Filter")
emaSlopeBars = input.int(3, "EMA Slope Lookback Bars", minval=1)

useBreakoutBuffer = input.bool(false, "Use Cloud Breakout Buffer")
breakoutBufferAtr = input.float(0.03, "Breakout Buffer In ATR", minval=0.0, step=0.01)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Display Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showEntryLabels = input.bool(true, "Show Entry Labels")
showExitLabels = input.bool(true, "Show Cloud Exit Labels")
showSetupMarkers = input.bool(true, "Show Setup Markers")
showPullbackMarkers = input.bool(true, "Show Pullback Markers")
showBlockedTradeMarkers = input.bool(true, "Show Blocked Trade Markers")
showChopBackground = input.bool(false, "Show Chop Background")
showConversionAndBase = input.bool(false, "Show Ichimoku Conversion/Base Lines")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
emaFast = ta.ema(close, fastEmaLen)
emaSlow = ta.ema(close, slowEmaLen)

emaBullish = emaFast > emaSlow
emaBearish = emaFast < emaSlow

emaFastRising = emaFast > emaFast[emaSlopeBars]
emaSlowRising = emaSlow > emaSlow[emaSlopeBars]

emaFastFalling = emaFast < emaFast[emaSlopeBars]
emaSlowFalling = emaSlow < emaSlow[emaSlopeBars]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Ichimoku
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
donchian(len) =>
    math.avg(ta.lowest(low, len), ta.highest(high, len))

conversionLine = donchian(conversionPeriods)
baseLine = donchian(basePeriods)

leadLine1 = math.avg(conversionLine, baseLine)
leadLine2 = donchian(spanBPeriods)

cloudShift = displacement - 1

logicLeadLine1 = useVisibleShiftedCloudForLogic ? leadLine1[cloudShift] : leadLine1
logicLeadLine2 = useVisibleShiftedCloudForLogic ? leadLine2[cloudShift] : leadLine2

cloudReady = not na(logicLeadLine1) and not na(logicLeadLine2)

cloudTop = cloudReady ? math.max(logicLeadLine1, logicLeadLine2) : na
cloudBottom = cloudReady ? math.min(logicLeadLine1, logicLeadLine2) : na
cloudThickness = cloudReady ? cloudTop - cloudBottom : na

atrValue = ta.atr(atrLen)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Cloud Position
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
priceAboveCloud = cloudReady and close > cloudTop
priceBelowCloud = cloudReady and close < cloudBottom

emasAboveCloud = cloudReady and emaFast > cloudTop and emaSlow > cloudTop
emasBelowCloud = cloudReady and emaFast < cloudBottom and emaSlow < cloudBottom

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Pullback Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullCloseInsideCloud = cloudReady and close <= cloudTop and close >= cloudBottom
bullWickEntersCloud = cloudReady and low <= cloudTop and high >= cloudBottom
bullTouchesCloudEdge = cloudReady and low <= cloudTop and close > cloudTop
bullNearCloudEdge = cloudReady and low <= cloudTop + atrValue * cloudEdgeBufferAtr and close > cloudTop

bearCloseInsideCloud = cloudReady and close <= cloudTop and close >= cloudBottom
bearWickEntersCloud = cloudReady and high >= cloudBottom and low <= cloudTop
bearTouchesCloudEdge = cloudReady and high >= cloudBottom and close < cloudBottom
bearNearCloudEdge = cloudReady and high >= cloudBottom - atrValue * cloudEdgeBufferAtr and close < cloudBottom

bullPricePulledIntoCloud = pullbackMode == "Close inside cloud" ? bullCloseInsideCloud : pullbackMode == "Wick enters cloud" ? bullWickEntersCloud : pullbackMode == "Touch cloud edge" ? bullWickEntersCloud or bullTouchesCloudEdge : bullWickEntersCloud or bullNearCloudEdge

bearPricePulledIntoCloud = pullbackMode == "Close inside cloud" ? bearCloseInsideCloud : pullbackMode == "Wick enters cloud" ? bearWickEntersCloud : pullbackMode == "Touch cloud edge" ? bearWickEntersCloud or bearTouchesCloudEdge : bearWickEntersCloud or bearNearCloudEdge

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Trend Quality
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[plusDi, minusDi, adxValue] = ta.dmi(adxLen, adxSmoothing)

emaSpread = math.abs(emaFast - emaSlow)

adxPass = not useAdxFilter or adxValue >= minAdx
adxRisingPass = not useAdxRisingFilter or adxValue > adxValue[adxRisingLookback]

cloudThicknessPass = not useCloudThicknessFilter or cloudThickness >= atrValue * minCloudThicknessAtr
emaSpreadPass = not useEmaSpreadFilter or emaSpread >= atrValue * minEmaSpreadAtr

bullEmaSlopePass = not useEmaSlopeFilter or emaFastRising and emaSlowRising
bearEmaSlopePass = not useEmaSlopeFilter or emaFastFalling and emaSlowFalling

bullBreakoutBufferPass = not useBreakoutBuffer or close >= cloudTop + atrValue * breakoutBufferAtr
bearBreakoutBufferPass = not useBreakoutBuffer or close <= cloudBottom - atrValue * breakoutBufferAtr

bullCloudTopRising = cloudReady and cloudTop > cloudTop[cloudSlopeBars] + atrValue * minCloudSlopeAtr
bullCloudBottomRising = cloudReady and cloudBottom >= cloudBottom[cloudSlopeBars]

bearCloudBottomFalling = cloudReady and cloudBottom < cloudBottom[cloudSlopeBars] - atrValue * minCloudSlopeAtr
bearCloudTopFalling = cloudReady and cloudTop <= cloudTop[cloudSlopeBars]

bullCloudSlopePass = not useCloudSlopeFilter or bullCloudTopRising and bullCloudBottomRising
bearCloudSlopePass = not useCloudSlopeFilter or bearCloudBottomFalling and bearCloudTopFalling

bullTrendQualityPass = cloudReady and adxPass and adxRisingPass and cloudThicknessPass and bullCloudSlopePass and emaSpreadPass and bullEmaSlopePass and bullBreakoutBufferPass
bearTrendQualityPass = cloudReady and adxPass and adxRisingPass and cloudThicknessPass and bearCloudSlopePass and emaSpreadPass and bearEmaSlopePass and bearBreakoutBufferPass

chopDetected = cloudReady and (not adxPass or not cloudThicknessPass or not bullCloudSlopePass and not bearCloudSlopePass)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// State Tracking
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var bool bullWasBelowCloud = false
var bool bullCloudBreakSeen = false
var bool bullSetupActive = false
var bool bullPullbackSeen = false
var int bullCloudBreakBar = na
var int bullSetupBar = na

var bool bearWasAboveCloud = false
var bool bearCloudBreakSeen = false
var bool bearSetupActive = false
var bool bearPullbackSeen = false
var int bearCloudBreakBar = na
var int bearSetupBar = na

var int virtualPosition = 0

bool bullSetupCondition = false
bool bearSetupCondition = false
bool bullPullbackCondition = false
bool bearPullbackCondition = false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Detect Setups 24/7
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if cloudReady and virtualPosition == 0
    if priceBelowCloud
        bullWasBelowCloud := true

    if priceAboveCloud
        bearWasAboveCloud := true

    if bullWasBelowCloud and priceAboveCloud
        bullCloudBreakSeen := true
        bullCloudBreakBar := bar_index
        bullWasBelowCloud := false

        bearCloudBreakSeen := false
        bearSetupActive := false
        bearPullbackSeen := false
        bearCloudBreakBar := na
        bearSetupBar := na

    if bearWasAboveCloud and priceBelowCloud
        bearCloudBreakSeen := true
        bearCloudBreakBar := bar_index
        bearWasAboveCloud := false

        bullCloudBreakSeen := false
        bullSetupActive := false
        bullPullbackSeen := false
        bullCloudBreakBar := na
        bullSetupBar := na

    if bullCloudBreakSeen and not na(bullCloudBreakBar) and bar_index - bullCloudBreakBar > maxBarsAfterCloudBreak
        bullCloudBreakSeen := false
        bullCloudBreakBar := na

    if bearCloudBreakSeen and not na(bearCloudBreakBar) and bar_index - bearCloudBreakBar > maxBarsAfterCloudBreak
        bearCloudBreakSeen := false
        bearCloudBreakBar := na

    if bullCloudBreakSeen and emaBullish and emasAboveCloud
        bullSetupCondition := true
        bullSetupActive := true
        bullPullbackSeen := false
        bullSetupBar := bar_index
        bullCloudBreakSeen := false
        bullCloudBreakBar := na

        bearSetupActive := false
        bearPullbackSeen := false
        bearCloudBreakSeen := false
        bearCloudBreakBar := na
        bearSetupBar := na

    if bearCloudBreakSeen and emaBearish and emasBelowCloud
        bearSetupCondition := true
        bearSetupActive := true
        bearPullbackSeen := false
        bearSetupBar := bar_index
        bearCloudBreakSeen := false
        bearCloudBreakBar := na

        bullSetupActive := false
        bullPullbackSeen := false
        bullCloudBreakSeen := false
        bullCloudBreakBar := na
        bullSetupBar := na

    if invalidateSetupOnOppositeClose and bullSetupActive and priceBelowCloud
        bullSetupActive := false
        bullPullbackSeen := false
        bullSetupBar := na

    if invalidateSetupOnOppositeClose and bearSetupActive and priceAboveCloud
        bearSetupActive := false
        bearPullbackSeen := false
        bearSetupBar := na

    if bullSetupActive and not na(bullSetupBar) and bar_index >= bullSetupBar and bullPricePulledIntoCloud
        bullPullbackSeen := true
        bullPullbackCondition := true

    if bearSetupActive and not na(bearSetupBar) and bar_index >= bearSetupBar and bearPricePulledIntoCloud
        bearPullbackSeen := true
        bearPullbackCondition := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Signal Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rawLongTrigger = cloudReady and virtualPosition == 0 and bullSetupActive and bullPullbackSeen and priceAboveCloud and emaBullish and emasAboveCloud
rawShortTrigger = cloudReady and virtualPosition == 0 and bearSetupActive and bearPullbackSeen and priceBelowCloud and emaBearish and emasBelowCloud

longTrigger = rawLongTrigger and bullTrendQualityPass
shortTrigger = rawShortTrigger and bearTrendQualityPass

blockedLongTrigger = rawLongTrigger and not bullTrendQualityPass
blockedShortTrigger = rawShortTrigger and not bearTrendQualityPass

bullCloudExit = cloudReady and virtualPosition == 1 and priceBelowCloud
bearCloudExit = cloudReady and virtualPosition == -1 and priceAboveCloud

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Virtual Position Handling
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if bullCloudExit or bearCloudExit
    virtualPosition := 0

if longTrigger
    virtualPosition := 1

    bullWasBelowCloud := false
    bullCloudBreakSeen := false
    bullSetupActive := false
    bullPullbackSeen := false
    bullCloudBreakBar := na
    bullSetupBar := na

    bearWasAboveCloud := false
    bearCloudBreakSeen := false
    bearSetupActive := false
    bearPullbackSeen := false
    bearCloudBreakBar := na
    bearSetupBar := na

if shortTrigger
    virtualPosition := -1

    bearWasAboveCloud := false
    bearCloudBreakSeen := false
    bearSetupActive := false
    bearPullbackSeen := false
    bearCloudBreakBar := na
    bearSetupBar := na

    bullWasBelowCloud := false
    bullCloudBreakSeen := false
    bullSetupActive := false
    bullPullbackSeen := false
    bullCloudBreakBar := na
    bullSetupBar := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plots
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(emaFast, title="9 EMA", linewidth=2, color=color.new(color.blue, 0))
plot(emaSlow, title="14 EMA", linewidth=2, color=color.new(color.purple, 0))

plot(showConversionAndBase ? conversionLine : na, title="Ichimoku Conversion Line", color=color.new(color.blue, 0))
plot(showConversionAndBase ? baseLine : na, title="Ichimoku Base Line", color=color.new(color.red, 0))

spanAPlot = plot(leadLine1, offset=cloudShift, color=color.new(color.green, 0), title="Leading Span A")
spanBPlot = plot(leadLine2, offset=cloudShift, color=color.new(color.red, 0), title="Leading Span B")

fill(spanAPlot, spanBPlot, title="Cloud Fill", color=leadLine1 > leadLine2 ? color.rgb(67, 160, 71, 85) : color.rgb(244, 67, 54, 85))

bgcolor(showChopBackground and chopDetected ? color.new(color.red, 92) : na, title="Chop Background")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Signal Markers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(showEntryLabels and longTrigger, title="BULL Entry", style=shape.labelup, location=location.belowbar, text="BULL", size=size.small, color=color.new(color.green, 0), textcolor=color.white)
plotshape(showEntryLabels and shortTrigger, title="BEAR Entry", style=shape.labeldown, location=location.abovebar, text="BEAR", size=size.small, color=color.new(color.red, 0), textcolor=color.white)

plotshape(showBlockedTradeMarkers and blockedLongTrigger, title="Blocked Bull Trade", style=shape.xcross, location=location.belowbar, text="BLOCK", size=size.tiny, color=color.new(color.gray, 0), textcolor=color.white)
plotshape(showBlockedTradeMarkers and blockedShortTrigger, title="Blocked Bear Trade", style=shape.xcross, location=location.abovebar, text="BLOCK", size=size.tiny, color=color.new(color.gray, 0), textcolor=color.white)

plotshape(showExitLabels and bullCloudExit, title="BULL Cloud Exit", style=shape.labeldown, location=location.abovebar, text="CLOUD EXIT", size=size.small, color=color.new(color.orange, 0), textcolor=color.white)
plotshape(showExitLabels and bearCloudExit, title="BEAR Cloud Exit", style=shape.labelup, location=location.belowbar, text="CLOUD EXIT", size=size.small, color=color.new(color.orange, 0), textcolor=color.white)

plotshape(showSetupMarkers and bullSetupCondition, title="Bull Setup Active", style=shape.circle, location=location.belowbar, text="BULL SETUP", size=size.tiny, color=color.new(color.green, 30), textcolor=color.white)
plotshape(showSetupMarkers and bearSetupCondition, title="Bear Setup Active", style=shape.circle, location=location.abovebar, text="BEAR SETUP", size=size.tiny, color=color.new(color.red, 30), textcolor=color.white)

plotshape(showPullbackMarkers and bullPullbackCondition, title="Bull Cloud Edge Pullback", style=shape.diamond, location=location.belowbar, text="PB", size=size.tiny, color=color.new(color.green, 0), textcolor=color.white)
plotshape(showPullbackMarkers and bearPullbackCondition, title="Bear Cloud Edge Pullback", style=shape.diamond, location=location.abovebar, text="PB", size=size.tiny, color=color.new(color.red, 0), textcolor=color.white)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(longTrigger, title="BULL Entry", message="BULL entry: price bounced above the visible Ichimoku cloud after bullish setup and passed trend/chop filters.")
alertcondition(shortTrigger, title="BEAR Entry", message="BEAR entry: price bounced below the visible Ichimoku cloud after bearish setup and passed trend/chop filters.")
alertcondition(blockedLongTrigger, title="Blocked BULL Entry", message="BULL setup happened, but trade was blocked by trend/chop filters.")
alertcondition(blockedShortTrigger, title="Blocked BEAR Entry", message="BEAR setup happened, but trade was blocked by trend/chop filters.")
alertcondition(bullCloudExit, title="BULL Cloud Exit", message="BULL exit: price closed below the visible Ichimoku cloud.")
alertcondition(bearCloudExit, title="BEAR Cloud Exit", message="BEAR exit: price closed above the visible Ichimoku cloud.")
````
