# 9/20 EMA Trend Pullback Alert - Calls & Puts

- url: https://www.tradingview.com/script/7AbTIzc1-9-20-EMA-Trend-Pullback-Alert-Calls-Puts/
- type: indicator
- pine_id: PUB;b93befbb8873401b98d0133528f77373
- version: 1.0

## Description

Pine Script using both the 9 EMA and 20 EMA:

* 20 EMA = main trend and primary pullback zone
* 9 EMA = momentum filter and aggressive pullback zone
* Separate alerts for:
    * Conservative 20 EMA pullback
    * Aggressive 9 EMA pullback
    * Combined CALL / PUT setup

## Source Code

````pine
//@version=5
indicator("9/20 EMA Trend Pullback Alert - Calls & Puts", overlay=true, max_labels_count=500)

//------------------------------------------------------
// Inputs
//------------------------------------------------------
fastEmaLength       = input.int(9, "Fast EMA Length", minval=1)
slowEmaLength       = input.int(20, "Slow EMA Length", minval=1)

slopeLookback       = input.int(5, "20 EMA Slope Lookback Candles", minval=1)
minSlopePct         = input.float(0.08, "Minimum 20 EMA Slope %", step=0.01)

nearFastEmaPct      = input.float(0.10, "Near 9 EMA Threshold %", step=0.01) / 100
nearSlowEmaPct      = input.float(0.15, "Near 20 EMA Threshold %", step=0.01) / 100

maxExtensionPct     = input.float(0.90, "Max Current Extension From 20 EMA %", step=0.05) / 100

trendBars           = input.int(10, "Trend Quality Lookback Candles", minval=1)
minTrendCloses      = input.int(7, "Minimum Closes on Trend Side of 20 EMA", minval=1)

requireRecentPush   = input.bool(true, "Require Recent Push Away From 20 EMA?")
recentPushBars      = input.int(8, "Recent Push Lookback Candles", minval=1)
minRecentPushPct    = input.float(0.30, "Minimum Recent Push From 20 EMA %", step=0.05) / 100

allowAggressive9Ema = input.bool(true, "Allow Aggressive 9 EMA Pullback Alerts?")
requireConfirmation = input.bool(false, "Require Confirmation Candle?")
showDebugLabels     = input.bool(false, "Show Debug Labels?")

//------------------------------------------------------
// EMAs
//------------------------------------------------------
ema9  = ta.ema(close, fastEmaLength)
ema20 = ta.ema(close, slowEmaLength)

plot(ema9, color=color.orange, linewidth=1, title="9 EMA")
plot(ema20, color=color.blue, linewidth=2, title="20 EMA")

//------------------------------------------------------
// 20 EMA normalized slope
//------------------------------------------------------
ema20SlopePct = ((ema20 - ema20[slopeLookback]) / ema20[slopeLookback]) * 100

ema20SlopeUp   = ema20SlopePct >= minSlopePct
ema20SlopeDown = ema20SlopePct <= -minSlopePct

//------------------------------------------------------
// EMA alignment / momentum filter
//------------------------------------------------------
bullishEmaAlignment = ema9 > ema20
bearishEmaAlignment = ema9 < ema20

priceAbove20 = close > ema20
priceBelow20 = close < ema20

//------------------------------------------------------
// Trend quality: recent closes on correct side of 20 EMA
//------------------------------------------------------
barsAbove20 = 0
barsBelow20 = 0

for i = 1 to trendBars
    barsAbove20 += close[i] > ema20[i] ? 1 : 0
    barsBelow20 += close[i] < ema20[i] ? 1 : 0

validCallTrend =
     ema20SlopeUp
     and bullishEmaAlignment
     and priceAbove20
     and barsAbove20 >= minTrendCloses

validPutTrend =
     ema20SlopeDown
     and bearishEmaAlignment
     and priceBelow20
     and barsBelow20 >= minTrendCloses

//------------------------------------------------------
// Pullback logic: 20 EMA primary zone
//------------------------------------------------------
callPullbackTo20 =
     low <= ema20 * (1 + nearSlowEmaPct)
     and low >= ema20 * (1 - nearSlowEmaPct)

putPullbackTo20 =
     high >= ema20 * (1 - nearSlowEmaPct)
     and high <= ema20 * (1 + nearSlowEmaPct)

wickTouches20 = low <= ema20 and high >= ema20

nearOrTouch20Call = callPullbackTo20 or wickTouches20
nearOrTouch20Put  = putPullbackTo20 or wickTouches20

//------------------------------------------------------
// Pullback logic: 9 EMA aggressive zone
//------------------------------------------------------
callPullbackTo9 =
     low <= ema9 * (1 + nearFastEmaPct)
     and low >= ema9 * (1 - nearFastEmaPct)

putPullbackTo9 =
     high >= ema9 * (1 - nearFastEmaPct)
     and high <= ema9 * (1 + nearFastEmaPct)

wickTouches9 = low <= ema9 and high >= ema9

nearOrTouch9Call = callPullbackTo9 or wickTouches9
nearOrTouch9Put  = putPullbackTo9 or wickTouches9

//------------------------------------------------------
// Not-too-extended filter from 20 EMA
//------------------------------------------------------
currentExtensionFrom20 = math.abs(close - ema20) / close
notTooExtended = currentExtensionFrom20 <= maxExtensionPct

//------------------------------------------------------
// Recent push requirement from 20 EMA
//------------------------------------------------------
highestExtensionAbove20 = 0.0
highestExtensionBelow20 = 0.0

for i = 1 to recentPushBars
    aboveExtension = close[i] > ema20[i] ? (close[i] - ema20[i]) / close[i] : 0.0
    belowExtension = close[i] < ema20[i] ? (ema20[i] - close[i]) / close[i] : 0.0

    highestExtensionAbove20 := math.max(highestExtensionAbove20, aboveExtension)
    highestExtensionBelow20 := math.max(highestExtensionBelow20, belowExtension)

hadRecentCallPush = highestExtensionAbove20 >= minRecentPushPct
hadRecentPutPush  = highestExtensionBelow20 >= minRecentPushPct

recentPushOkCall = requireRecentPush ? hadRecentCallPush : true
recentPushOkPut  = requireRecentPush ? hadRecentPutPush : true

//------------------------------------------------------
// Optional confirmation candle
//------------------------------------------------------
bullishConfirmation =
     close > open
     and close > ema9
     and close > ema20

bearishConfirmation =
     close < open
     and close < ema9
     and close < ema20

confirmationOkCall = requireConfirmation ? bullishConfirmation : true
confirmationOkPut  = requireConfirmation ? bearishConfirmation : true

//------------------------------------------------------
// Conservative 20 EMA setups
//------------------------------------------------------
callSetup20 =
     validCallTrend
     and nearOrTouch20Call
     and notTooExtended
     and recentPushOkCall
     and confirmationOkCall

putSetup20 =
     validPutTrend
     and nearOrTouch20Put
     and notTooExtended
     and recentPushOkPut
     and confirmationOkPut

//------------------------------------------------------
// Aggressive 9 EMA setups
//------------------------------------------------------
callSetup9 =
     allowAggressive9Ema
     and validCallTrend
     and nearOrTouch9Call
     and notTooExtended
     and recentPushOkCall
     and confirmationOkCall

putSetup9 =
     allowAggressive9Ema
     and validPutTrend
     and nearOrTouch9Put
     and notTooExtended
     and recentPushOkPut
     and confirmationOkPut

//------------------------------------------------------
// Combined setup logic
//------------------------------------------------------
callSetup = callSetup20 or callSetup9
putSetup  = putSetup20 or putSetup9

//------------------------------------------------------
// Visual signals
//------------------------------------------------------
plotshape(callSetup20,
     title="CALL 20 EMA Pullback",
     style=shape.labelup,
     text="CALL\n20 EMA",
     color=color.green,
     textcolor=color.white,
     location=location.belowbar,
     size=size.small)

plotshape(putSetup20,
     title="PUT 20 EMA Pullback",
     style=shape.labeldown,
     text="PUT\n20 EMA",
     color=color.red,
     textcolor=color.white,
     location=location.abovebar,
     size=size.small)

plotshape(callSetup9 and not callSetup20,
     title="CALL 9 EMA Pullback",
     style=shape.labelup,
     text="CALL\n9 EMA",
     color=color.lime,
     textcolor=color.black,
     location=location.belowbar,
     size=size.tiny)

plotshape(putSetup9 and not putSetup20,
     title="PUT 9 EMA Pullback",
     style=shape.labeldown,
     text="PUT\n9 EMA",
     color=color.orange,
     textcolor=color.black,
     location=location.abovebar,
     size=size.tiny)

//------------------------------------------------------
// Alerts
//------------------------------------------------------
alertcondition(callSetup20,
     title="CALL Pullback to 20 EMA",
     message="CALL watch: valid trend pullback near/touching the 20 EMA.")

alertcondition(putSetup20,
     title="PUT Pullback to 20 EMA",
     message="PUT watch: valid trend pullback near/touching the 20 EMA.")

alertcondition(callSetup9,
     title="CALL Pullback to 9 EMA",
     message="Aggressive CALL watch: valid trend pullback near/touching the 9 EMA while 20 EMA trend is bullish.")

alertcondition(putSetup9,
     title="PUT Pullback to 9 EMA",
     message="Aggressive PUT watch: valid trend pullback near/touching the 9 EMA while 20 EMA trend is bearish.")

alertcondition(callSetup,
     title="CALL Pullback to 9 or 20 EMA",
     message="CALL watch: valid bullish trend pullback near/touching the 9 EMA or 20 EMA.")

alertcondition(putSetup,
     title="PUT Pullback to 9 or 20 EMA",
     message="PUT watch: valid bearish trend pullback near/touching the 9 EMA or 20 EMA.")

//------------------------------------------------------
// Optional debug label
//------------------------------------------------------
if showDebugLabels and barstate.islast
    label.new(bar_index,
         high,
         "20 EMA Slope %: " + str.tostring(ema20SlopePct, "#.###") +
         "\n9 > 20: " + str.tostring(bullishEmaAlignment) +
         "\n9 < 20: " + str.tostring(bearishEmaAlignment) +
         "\nBars Above 20: " + str.tostring(barsAbove20) +
         "\nBars Below 20: " + str.tostring(barsBelow20) +
         "\nExt From 20 %: " + str.tostring(currentExtensionFrom20 * 100, "#.###") +
         "\nRecent Above Push %: " + str.tostring(highestExtensionAbove20 * 100, "#.###") +
         "\nRecent Below Push %: " + str.tostring(highestExtensionBelow20 * 100, "#.###"),
         style=label.style_label_left,
         textcolor=color.white,
         color=color.gray)
````
