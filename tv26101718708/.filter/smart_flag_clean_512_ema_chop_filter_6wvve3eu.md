# Smart Flag Clean 5/12 EMA + Chop Filter

- url: https://www.tradingview.com/script/6WVve3Eu-Smart-Flag-Clean-5-12-EMA-Chop-Filter/
- type: indicator
- pine_id: PUB;b5d8c122c4e94dc68216d550b276ad9b
- version: 1.0

## Description

This is an updated version to my previous 5/12 EMA crossover with buy/sell flags. In this version I've attempted to have the flags labeled based on setup. Still a work in progress but basically I've found that if the SMA 20 is moving through the candles instead of having some separation that the crossovers don't work as well. So, I'm still trying to perfect this script to eliminate flags in choppy situations. Feel free to take it and modify it anyway you want. I'm publishing it so that maybe someone out there can take this concept and improve upon it. 

thanks,
Ajroland

## Source Code

````pine
//@version=5
indicator("Smart Flag Pro Clean 5/12 EMA + Chop Filter", overlay=true, max_labels_count=500)

//====================================================
// Inputs
//====================================================
fastLen            = input.int(5, "Fast EMA")
slowLen            = input.int(12, "Slow EMA")
trendLen           = input.int(20, "Trend SMA")
volLen             = input.int(20, "Volume Average Length")
swingLookback      = input.int(10, "Swing Lookback")
atrLen             = input.int(14, "ATR Length")

minRoomATR         = input.float(0.60, "Min Room (ATR)", step=0.05)
strongRoomATR      = input.float(1.00, "Strong Room (ATR)", step=0.05)
flatSlopeThresh    = input.float(0.01, "EMA Flat Slope Threshold (%)", step=0.001)

showSkipSignals    = input.bool(true, "Show Skip Signals")
showBSignals       = input.bool(true, "Show B Signals")
onlyASetups        = input.bool(false, "Only Show A Setups")
useVWAPFilter      = input.bool(false, "Use VWAP Filter")
showDebugPlots     = input.bool(false, "Show Debug Plots")

flagOffsetATR      = input.float(0.55, "Flag Offset (ATR)", step=0.05)

// Chop filter inputs
useChopFilter      = input.bool(true, "Use 20 SMA Chop Filter")
maxDistFrom20ATR   = input.float(0.25, "Max Distance From 20 SMA (ATR)", step=0.05)
max20SlopePct      = input.float(0.015, "Max 20 SMA Slope For Chop (%)", step=0.001)
useCandleOverlap20 = input.bool(true, "Require Candle Overlap With 20 SMA")
minBarsMeanChop    = input.int(6, "Bars Needed For Mean Chop", minval=1, maxval=10)

//====================================================
// Core calculations
//====================================================
emaFast   = ta.ema(close, fastLen)
emaSlow   = ta.ema(close, slowLen)
smaTrend  = ta.sma(close, trendLen)
atr       = ta.atr(atrLen)
volAvg    = ta.sma(volume, volLen)
vwapValue = ta.vwap(close)

emaFastSlopePct  = emaFast[1]  != 0 ? ((emaFast  - emaFast[1])  / emaFast[1])  * 100.0 : 0.0
emaSlowSlopePct  = emaSlow[1]  != 0 ? ((emaSlow  - emaSlow[1])  / emaSlow[1])  * 100.0 : 0.0
smaTrendSlopePct = smaTrend[1] != 0 ? ((smaTrend - smaTrend[1]) / smaTrend[1]) * 100.0 : 0.0

recentLow  = ta.lowest(low, swingLookback)
recentHigh = ta.highest(high, swingLookback)

roomBelow    = close - recentLow
roomAbove    = recentHigh - close
roomBelowATR = atr > 0 ? roomBelow / atr : 0.0
roomAboveATR = atr > 0 ? roomAbove / atr : 0.0

candleBody  = math.abs(close - open)
candleRange = high - low
bodyPct     = candleRange > 0 ? candleBody / candleRange : 0.0

isBearCandle = close < open
isBullCandle = close > open

bearReject = isBearCandle and bodyPct >= 0.45 and close <= low  + (high - low) * 0.35
bullReject = isBullCandle and bodyPct >= 0.45 and close >= high - (high - low) * 0.35

volOkay   = volume >= volAvg
volStrong = volume >= volAvg * 1.20

bearStack = emaFast < emaSlow
bullStack = emaFast > emaSlow

fastDown = emaFastSlopePct < -flatSlopeThresh
slowDown = emaSlowSlopePct < -flatSlopeThresh
fastUp   = emaFastSlopePct >  flatSlopeThresh
slowUp   = emaSlowSlopePct >  flatSlopeThresh

emaBearAligned = bearStack and fastDown and slowDown
emaBullAligned = bullStack and fastUp and slowUp

emaFlat  = math.abs(emaFastSlopePct) <= flatSlopeThresh and math.abs(emaSlowSlopePct) <= flatSlopeThresh
emaTight = math.abs(emaFast - emaSlow) <= atr * 0.10

belowTrend  = close < smaTrend
aboveTrend  = close > smaTrend
trendDownOk = smaTrendSlopePct <= 0
trendUpOk   = smaTrendSlopePct >= 0

lowerHighContext = high < high[1] and high[1] <= high[2]
higherLowContext = low > low[1] and low[1] >= low[2]

failedPop   = high < recentHigh and close < open and close < emaFast
lostFastEMA = close < emaFast and close < emaSlow

inMiddleOfRange = close > recentLow + (recentHigh - recentLow) * 0.35 and close < recentLow + (recentHigh - recentLow) * 0.65
chopZone        = emaFlat or emaTight

shortVWAPOk = not useVWAPFilter or close < vwapValue
longVWAPOk  = not useVWAPFilter or close > vwapValue

//====================================================
// 20 SMA Chop Filter
//====================================================
distFrom20ATR  = atr > 0 ? math.abs(close - smaTrend) / atr : 0.0
sma20Flat      = math.abs(smaTrendSlopePct) <= max20SlopePct
candleTouches20 = low <= smaTrend and high >= smaTrend

meanChopBar = distFrom20ATR <= maxDistFrom20ATR and sma20Flat and (not useCandleOverlap20 or candleTouches20)
meanChop    = useChopFilter and ta.lowest(meanChopBar ? 1 : 0, minBarsMeanChop) == 1

//====================================================
// Cross signals
//====================================================
sellCross = ta.crossunder(emaFast, emaSlow)
buyCross  = ta.crossover(emaFast, emaSlow)

//====================================================
// Scoring
//====================================================
trendShortScore = 0
trendShortScore += bearStack ? 1 : 0
trendShortScore += emaBearAligned ? 2 : 0
trendShortScore += belowTrend ? 1 : 0
trendShortScore += trendDownOk ? 1 : 0
trendShortScore += lowerHighContext ? 1 : 0
trendShortScore += bearReject ? 1 : 0
trendShortScore += volOkay ? 1 : 0
trendShortScore += volStrong ? 1 : 0
trendShortScore += roomBelowATR >= minRoomATR ? 1 : 0
trendShortScore += roomBelowATR >= strongRoomATR ? 1 : 0
trendShortScore += shortVWAPOk ? 1 : 0
trendShortScore -= chopZone ? 2 : 0
trendShortScore -= roomBelowATR < minRoomATR ? 2 : 0
trendShortScore -= meanChop ? 3 : 0

reversalShortScore = 0
reversalShortScore += bearStack ? 1 : 0
reversalShortScore += fastDown ? 1 : 0
reversalShortScore += slowDown ? 1 : 0
reversalShortScore += lowerHighContext ? 1 : 0
reversalShortScore += bearReject ? 1 : 0
reversalShortScore += failedPop ? 1 : 0
reversalShortScore += lostFastEMA ? 1 : 0
reversalShortScore += volOkay ? 1 : 0
reversalShortScore += volStrong ? 1 : 0
reversalShortScore += roomBelowATR >= minRoomATR ? 1 : 0
reversalShortScore += roomBelowATR >= strongRoomATR ? 1 : 0
reversalShortScore += shortVWAPOk ? 1 : 0
reversalShortScore -= chopZone ? 1 : 0
reversalShortScore -= inMiddleOfRange ? 1 : 0
reversalShortScore -= roomBelowATR < minRoomATR ? 2 : 0
reversalShortScore -= meanChop ? 3 : 0

longScore = 0
longScore += bullStack ? 1 : 0
longScore += emaBullAligned ? 2 : 0
longScore += aboveTrend ? 1 : 0
longScore += trendUpOk ? 1 : 0
longScore += higherLowContext ? 1 : 0
longScore += bullReject ? 1 : 0
longScore += volOkay ? 1 : 0
longScore += volStrong ? 1 : 0
longScore += roomAboveATR >= minRoomATR ? 1 : 0
longScore += roomAboveATR >= strongRoomATR ? 1 : 0
longScore += longVWAPOk ? 1 : 0
longScore -= chopZone ? 2 : 0
longScore -= roomAboveATR < minRoomATR ? 2 : 0
longScore -= meanChop ? 3 : 0

//====================================================
// Final grading
//====================================================
isATrendShortRaw    = sellCross and trendShortScore >= 6 and emaBearAligned and belowTrend and roomBelowATR >= strongRoomATR and not chopZone and shortVWAPOk
isAReversalShortRaw = sellCross and reversalShortScore >= 5 and bearStack and roomBelowATR >= minRoomATR and not emaFlat and shortVWAPOk
isAShortRaw         = isATrendShortRaw or isAReversalShortRaw
isBShortRaw         = sellCross and not isAShortRaw and (trendShortScore >= 4 or reversalShortScore >= 4)
isSkipShortRaw      = sellCross and not isAShortRaw and not isBShortRaw

isALongRaw          = buyCross and longScore >= 6 and emaBullAligned and aboveTrend and roomAboveATR >= strongRoomATR and not chopZone and longVWAPOk
isBLongRaw          = buyCross and not isALongRaw and longScore >= 4
isSkipLongRaw       = buyCross and not isALongRaw and not isBLongRaw

// Suppress A/B signals during mean chop
isATrendShort    = isATrendShortRaw and not meanChop
isAReversalShort = isAReversalShortRaw and not meanChop
isAShort         = isATrendShort or isAReversalShort
isBShort         = isBShortRaw and not meanChop and not isAShort
isSkipShort      = sellCross and not isAShort and not isBShort

isALong          = isALongRaw and not meanChop
isBLong          = isBLongRaw and not meanChop and not isALong
isSkipLong       = buyCross and not isALong and not isBLong

plotAShort = isAShort
plotBShort = showBSignals and not onlyASetups and isBShort
plotALong  = isALong
plotBLong  = showBSignals and not onlyASetups and isBLong
plotSkipS  = showSkipSignals and not onlyASetups and isSkipShort
plotSkipL  = showSkipSignals and not onlyASetups and isSkipLong

//====================================================
// Plots
//====================================================
plot(emaFast, "5 EMA", color=color.green, linewidth=2)
plot(emaSlow, "12 EMA", color=color.red, linewidth=2)
plot(smaTrend, "20 SMA", color=color.yellow, linewidth=2)
plot(useVWAPFilter ? vwapValue : na, "VWAP", color=color.white, linewidth=1)

//====================================================
// Labels
//====================================================
makeLabel(_barIndex, _price, _text, _style, _bg, _txtColor) =>
    label.new(_barIndex, _price, _text, style=_style, color=_bg, textcolor=_txtColor, size=size.small)

shortLabelPrice = high + atr * flagOffsetATR
longLabelPrice  = low  - atr * flagOffsetATR

if plotAShort and isATrendShort
    makeLabel(bar_index, shortLabelPrice, "A SHORT T", label.style_label_down, color.new(color.red, 0), color.white)

if plotAShort and isAReversalShort
    makeLabel(bar_index, shortLabelPrice, "A SHORT R", label.style_label_down, color.new(color.fuchsia, 0), color.white)

if plotBShort
    makeLabel(bar_index, shortLabelPrice, "B SHORT", label.style_label_down, color.new(color.orange, 0), color.white)

if plotSkipS
    makeLabel(bar_index, shortLabelPrice, "SKIP S", label.style_label_down, color.new(color.gray, 10), color.white)

if plotALong
    makeLabel(bar_index, longLabelPrice, "A LONG", label.style_label_up, color.new(color.lime, 0), color.black)

if plotBLong
    makeLabel(bar_index, longLabelPrice, "B LONG", label.style_label_up, color.new(color.teal, 0), color.white)

if plotSkipL
    makeLabel(bar_index, longLabelPrice, "SKIP L", label.style_label_up, color.new(color.gray, 10), color.white)

//====================================================
// Background highlight
//====================================================
bgcolor(plotAShort ? color.new(color.red, 90) : na)
bgcolor(plotALong ? color.new(color.green, 90) : na)
bgcolor(meanChop ? color.new(color.orange, 92) : na)

//====================================================
// Alerts
//====================================================
alertcondition(isATrendShort, title="A Short Trend", message="A SHORT TREND on {{ticker}}")
alertcondition(isAReversalShort, title="A Short Reversal", message="A SHORT REVERSAL on {{ticker}}")
alertcondition(isBShort, title="B Short", message="B SHORT on {{ticker}}")
alertcondition(isALong, title="A Long", message="A LONG on {{ticker}}")
alertcondition(isBLong, title="B Long", message="B LONG on {{ticker}}")

//====================================================
// Debug
//====================================================
plot(showDebugPlots ? trendShortScore : na, "Trend Short Score", color=color.red)
plot(showDebugPlots ? reversalShortScore : na, "Reversal Short Score", color=color.fuchsia)
plot(showDebugPlots ? longScore : na, "Long Score", color=color.green)
plot(showDebugPlots ? roomBelowATR : na, "Room Below ATR", color=color.orange)
plot(showDebugPlots ? roomAboveATR : na, "Room Above ATR", color=color.blue)
plot(showDebugPlots ? distFrom20ATR : na, "Distance From 20 ATR", color=color.white)
plot(showDebugPlots ? smaTrendSlopePct : na, "20 SMA Slope %", color=color.yellow)
````
