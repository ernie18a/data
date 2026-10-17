# 20 EMA Trend Pullback Alert - Calls & Puts

- url: https://www.tradingview.com/script/AlFoBoNp-20-EMA-Trend-Pullback-Alert-Calls-Puts/
- type: indicator
- pine_id: PUB;1fa8fea8eacc477c8d8bdf7fd2726692
- version: 1.0

## Description

The updated Pine Script identifies high-quality 20 EMA pullback setups on a 2-minute chart for both calls and puts. It filters signals using EMA slope strength, recent trend quality, price proximity to the EMA, a “not too extended” rule, and a recent push-away-from-EMA requirement to reduce chop signals. It plots CALL/PUT labels on valid pullbacks and provides separate TradingView alerts for bullish and bearish setups.

## Source Code

````pine
//@version=5
indicator("20 EMA Trend Pullback Alert - Calls & Puts", overlay=true, max_labels_count=500)

//------------------------------------------------------
// Inputs
//------------------------------------------------------
emaLength          = input.int(20, "EMA Length", minval=1)
slopeLookback      = input.int(5, "EMA Slope Lookback Candles", minval=1)
minSlopePct        = input.float(0.08, "Minimum EMA Slope %", step=0.01)

nearEmaPct         = input.float(0.15, "Near EMA Threshold %", step=0.01) / 100
maxExtensionPct    = input.float(0.80, "Max Current Extension From EMA %", step=0.05) / 100

trendBars          = input.int(10, "Trend Quality Lookback Candles", minval=1)
minTrendCloses     = input.int(7, "Minimum Closes on Trend Side", minval=1)

requireRecentPush  = input.bool(true, "Require Recent Push Away From EMA?")
recentPushBars     = input.int(8, "Recent Push Lookback Candles", minval=1)
minRecentPushPct   = input.float(0.30, "Minimum Recent Push From EMA %", step=0.05) / 100

requireConfirmation = input.bool(false, "Require Confirmation Candle?")
showDebugLabels     = input.bool(false, "Show Debug Labels?")

//------------------------------------------------------
// EMA
//------------------------------------------------------
ema20 = ta.ema(close, emaLength)
plot(ema20, color=color.blue, linewidth=2, title="20 EMA")

//------------------------------------------------------
// Normalized EMA slope
//------------------------------------------------------
emaSlopePct = ((ema20 - ema20[slopeLookback]) / ema20[slopeLookback]) * 100

emaSlopeUp   = emaSlopePct >= minSlopePct
emaSlopeDown = emaSlopePct <= -minSlopePct

//------------------------------------------------------
// Trend quality: how many recent closes respected EMA
//------------------------------------------------------
barsAbove = 0
barsBelow = 0

for i = 1 to trendBars
    barsAbove += close[i] > ema20[i] ? 1 : 0
    barsBelow += close[i] < ema20[i] ? 1 : 0

validCallTrend = emaSlopeUp and barsAbove >= minTrendCloses
validPutTrend  = emaSlopeDown and barsBelow >= minTrendCloses

//------------------------------------------------------
// Pullback / touch logic
//------------------------------------------------------
closeNearEma = math.abs(close - ema20) / close <= nearEmaPct
wickTouchesEma = low <= ema20 and high >= ema20

callPullbackToEma = low <= ema20 * (1 + nearEmaPct) and low >= ema20 * (1 - nearEmaPct)
putPullbackToEma  = high >= ema20 * (1 - nearEmaPct) and high <= ema20 * (1 + nearEmaPct)

nearOrTouchCall = closeNearEma or wickTouchesEma or callPullbackToEma
nearOrTouchPut  = closeNearEma or wickTouchesEma or putPullbackToEma

//------------------------------------------------------
// Not-too-extended filter
//------------------------------------------------------
currentExtensionPct = math.abs(close - ema20) / close
notTooExtended = currentExtensionPct <= maxExtensionPct

//------------------------------------------------------
// Recent push requirement
// This helps avoid alerts in flat chop where price never really trended.
//------------------------------------------------------
highestExtensionAbove = 0.0
highestExtensionBelow = 0.0

for i = 1 to recentPushBars
    aboveExtension = close[i] > ema20[i] ? (close[i] - ema20[i]) / close[i] : 0.0
    belowExtension = close[i] < ema20[i] ? (ema20[i] - close[i]) / close[i] : 0.0

    highestExtensionAbove := math.max(highestExtensionAbove, aboveExtension)
    highestExtensionBelow := math.max(highestExtensionBelow, belowExtension)

hadRecentCallPush = highestExtensionAbove >= minRecentPushPct
hadRecentPutPush  = highestExtensionBelow >= minRecentPushPct

recentPushOkCall = requireRecentPush ? hadRecentCallPush : true
recentPushOkPut  = requireRecentPush ? hadRecentPutPush : true

//------------------------------------------------------
// Optional confirmation candle
//------------------------------------------------------
// For calls: candle shows rejection upward from EMA area.
// For puts: candle shows rejection downward from EMA area.
bullishConfirmation = close > open and close > ema20
bearishConfirmation = close < open and close < ema20

confirmationOkCall = requireConfirmation ? bullishConfirmation : true
confirmationOkPut  = requireConfirmation ? bearishConfirmation : true

//------------------------------------------------------
// Final setup logic
//------------------------------------------------------
callSetup =
     validCallTrend
     and nearOrTouchCall
     and notTooExtended
     and recentPushOkCall
     and confirmationOkCall

putSetup =
     validPutTrend
     and nearOrTouchPut
     and notTooExtended
     and recentPushOkPut
     and confirmationOkPut

//------------------------------------------------------
// Visual signals
//------------------------------------------------------
plotshape(callSetup,
     title="CALL Pullback Setup",
     style=shape.labelup,
     text="CALL\n20 EMA",
     color=color.green,
     textcolor=color.white,
     location=location.belowbar,
     size=size.small)

plotshape(putSetup,
     title="PUT Pullback Setup",
     style=shape.labeldown,
     text="PUT\n20 EMA",
     color=color.red,
     textcolor=color.white,
     location=location.abovebar,
     size=size.small)

//------------------------------------------------------
// Alerts
//------------------------------------------------------
alertcondition(callSetup,
     title="CALL Pullback to 20 EMA",
     message="CALL watch: valid uptrend pullback near/touching the 20 EMA.")

alertcondition(putSetup,
     title="PUT Pullback to 20 EMA",
     message="PUT watch: valid downtrend pullback near/touching the 20 EMA.")

//------------------------------------------------------
// Optional debug labels
//------------------------------------------------------
if showDebugLabels and barstate.islast
    label.new(bar_index,
         high,
         "EMA Slope %: " + str.tostring(emaSlopePct, "#.###") +
         "\nBars Above: " + str.tostring(barsAbove) +
         "\nBars Below: " + str.tostring(barsBelow) +
         "\nCurrent Ext %: " + str.tostring(currentExtensionPct * 100, "#.###") +
         "\nRecent Above Push %: " + str.tostring(highestExtensionAbove * 100, "#.###") +
         "\nRecent Below Push %: " + str.tostring(highestExtensionBelow * 100, "#.###"),
         style=label.style_label_left,
         textcolor=color.white,
         color=color.gray)
````
