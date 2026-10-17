# Three Black Crows & Three White Soldiers | IP | EkF.TUKE

- url: https://www.tradingview.com/script/eZVXcI18-three-black-crows-three-white-soldiers-ip-ekf-tuke/
- type: indicator
- pine_id: PUB;769e3051cbf4439d81c7114862b1ba17
- version: 1.0

## Description

This algorithm is used to automatically detect the Three Black Crows and Three White Soldiers candlestick patterns on price charts, display them directly in TradingView, and support their testing on historical market data, which makes it possible to examine whether these three-candle reversal formations provide reliable bearish or bullish signals in different market conditions.

## Source Code

````pine
//@version=6
indicator("Three Black Crows & Three White Soldiers | IP | EkF.TUKE", shorttitle="3BC + 3WS | IP | EkF.TUKE", overlay=true)

// ===== Inputs =====
showThreeBlackCrows    = input.bool(true, "Show Three Black Crows")
showThreeWhiteSoldiers = input.bool(true, "Show Three White Soldiers")

useTrendFilter         = input.bool(true, "Use trend filter")
trendBars              = input.int(2, "Trend candles before pattern", minval=1, maxval=5)

useBodyFilter          = input.bool(true, "Use long body filter")
minBodyToRange         = input.float(0.45, "Min body / candle range", minval=0.1, maxval=1.0, step=0.05)

useShadowFilter        = input.bool(true, "Use short shadow filter")
maxShadowToBody        = input.float(0.35, "Max shadow / body", minval=0.0, maxval=1.0, step=0.05)

useOpenInsideRule      = input.bool(false, "Require next open inside previous body")
useCloseProgression    = input.bool(true, "Require progressive closes")

useSmaFilter           = input.bool(false, "Use SMA trend filter")
smaLen                 = input.int(20, "SMA length", minval=5)

// ===== Helpers =====
body(i) =>
    math.abs(close[i] - open[i])

range_(i) =>
    high[i] - low[i]

bodyHigh(i) =>
    math.max(open[i], close[i])

bodyLow(i) =>
    math.min(open[i], close[i])

upperWick(i) =>
    high[i] - bodyHigh(i)

lowerWick(i) =>
    bodyLow(i) - low[i]

isBull(i) =>
    close[i] > open[i]

isBear(i) =>
    open[i] > close[i]

bodyRatio(i) =>
    range_(i) > 0 ? body(i) / range_(i) : 0.0

// ===== Current 3 candles = [2], [1], [0] =====
longBody0 = not useBodyFilter or bodyRatio(0) >= minBodyToRange
longBody1 = not useBodyFilter or bodyRatio(1) >= minBodyToRange
longBody2 = not useBodyFilter or bodyRatio(2) >= minBodyToRange

shortDnShadow0 = not useShadowFilter or lowerWick(0) <= body(0) * maxShadowToBody
shortDnShadow1 = not useShadowFilter or lowerWick(1) <= body(1) * maxShadowToBody
shortDnShadow2 = not useShadowFilter or lowerWick(2) <= body(2) * maxShadowToBody

shortUpShadow0 = not useShadowFilter or upperWick(0) <= body(0) * maxShadowToBody
shortUpShadow1 = not useShadowFilter or upperWick(1) <= body(1) * maxShadowToBody
shortUpShadow2 = not useShadowFilter or upperWick(2) <= body(2) * maxShadowToBody

// ===== Trend context before pattern =====
downtrend = true
uptrend   = true

for i = 3 to trendBars + 2
    downtrend := downtrend and close[i] < open[i]
    uptrend   := uptrend and close[i] > open[i]

smaValue     = ta.sma(close, smaLen)
smaDowntrend = close[2] < smaValue[2]
smaUptrend   = close[2] > smaValue[2]

downtrendOk = (not useTrendFilter or downtrend) and (not useSmaFilter or smaDowntrend)
uptrendOk   = (not useTrendFilter or uptrend) and (not useSmaFilter or smaUptrend)

// ===== Three Black Crows =====
threeBearBodies  = isBear(2) and isBear(1) and isBear(0)
threeBearLong    = longBody2 and longBody1 and longBody0
threeBearShadows = shortDnShadow2 and shortDnShadow1 and shortDnShadow0

openInsidePrevBear =
     open[1] <= bodyHigh(2) and open[1] >= bodyLow(2) and
     open[0] <= bodyHigh(1) and open[0] >= bodyLow(1)

closeProgressBear =
     close[1] < close[2] and
     close[0] < close[1]

threeBlackCrows =
     showThreeBlackCrows and
     uptrendOk and
     threeBearBodies and
     threeBearLong and
     threeBearShadows and
     (not useOpenInsideRule or openInsidePrevBear) and
     (not useCloseProgression or closeProgressBear)

// ===== Three White Soldiers =====
threeBullBodies  = isBull(2) and isBull(1) and isBull(0)
threeBullLong    = longBody2 and longBody1 and longBody0
threeBullShadows = shortUpShadow2 and shortUpShadow1 and shortUpShadow0

openInsidePrevBull =
     open[1] <= bodyHigh(2) and open[1] >= bodyLow(2) and
     open[0] <= bodyHigh(1) and open[0] >= bodyLow(1)

closeProgressBull =
     close[1] > close[2] and
     close[0] > close[1]

threeWhiteSoldiers =
     showThreeWhiteSoldiers and
     downtrendOk and
     threeBullBodies and
     threeBullLong and
     threeBullShadows and
     (not useOpenInsideRule or openInsidePrevBull) and
     (not useCloseProgression or closeProgressBull)

// ===== Plot =====
plotshape(
     threeBlackCrows,
     title="Three Black Crows",
     style=shape.labeldown,
     location=location.abovebar,
     text="3BC",
     color=color.red,
     textcolor=color.white,
     size=size.small)

plotshape(
     threeWhiteSoldiers,
     title="Three White Soldiers",
     style=shape.labelup,
     location=location.belowbar,
     text="3WS",
     color=color.green,
     textcolor=color.white,
     size=size.small)

// ===== Alerts =====
alertcondition(
     threeBlackCrows,
     title="Three Black Crows detected",
     message="Three Black Crows detected")

alertcondition(
     threeWhiteSoldiers,
     title="Three White Soldiers detected",
     message="Three White Soldiers detected")
````
