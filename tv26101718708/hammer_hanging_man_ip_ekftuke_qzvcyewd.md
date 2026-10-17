# Hammer & Hanging Man | IP | EkF.TUKE

- url: https://www.tradingview.com/script/qZVcYEwD-hammer-hanging-man-ip-ekf-tuke/
- type: indicator
- pine_id: PUB;9813c9246a064b81b5a932694511c2a5
- version: 1.0

## Description

This algorithm is used to automatically identify the Hammer and Hanging Man candlestick patterns on price charts, mark them visually in TradingView, and enable their further testing on historical market data, which makes it possible to evaluate whether these patterns actually provide reliable trading signals under different market conditions.

## Source Code

````pine
//@version=6
indicator("Hammer & Hanging Man | IP | EkF.TUKE", shorttitle="Hammer + HM | IP | EkF.TUKE", overlay=true)

// ===== Inputs =====
showHammer      = input.bool(true, "Show Hammer")
showHangingMan  = input.bool(true, "Show Hanging Man")
strictColors    = input.bool(false, "Strict colors: green Hammer / red Hanging Man")

mainShadowRatio  = input.float(2.2, "Min lower shadow / body", minval=1.0, step=0.1)
smallShadowRatio = input.float(0.25, "Max upper shadow / body", minval=0.0, step=0.05)
maxBodyToRange   = input.float(0.35, "Max body / candle range", minval=0.05, maxval=0.8, step=0.05)

trendBars        = input.int(3, "Trend candles before pattern", minval=2, maxval=5)
useExtremes      = input.bool(true, "Use local high/low filter")
extremeLookback  = input.int(10, "Local extreme lookback", minval=3)

// ===== Candle structure =====
bodyHigh    = math.max(open, close)
bodyLow     = math.min(open, close)
body        = bodyHigh - bodyLow
candleRange = high - low
upperWick   = high - bodyHigh
lowerWick   = bodyLow - low

validCandle = candleRange > 0 and body > 0
isBullish   = close > open
isBearish   = open > close

// ===== Shared shape =====
smallBody      = validCandle and body <= candleRange * maxBodyToRange
longLower      = validCandle and lowerWick >= body * mainShadowRatio
tinyUpper      = validCandle and upperWick <= body * smallShadowRatio
bodyOnTop      = validCandle and bodyLow >= low + candleRange * 0.5
lowerDominates = validCandle and lowerWick > upperWick * 2

shapeBase = smallBody and longLower and tinyUpper and bodyOnTop and lowerDominates

// ===== Trend context =====
downtrend = true
uptrend   = true

for i = 1 to trendBars
    downtrend := downtrend and close[i] < open[i]
    uptrend   := uptrend and close[i] > open[i]

// ===== Local extremes =====
atLocalLow  = low <= ta.lowest(low, extremeLookback)
atLocalHigh = high >= ta.highest(high, extremeLookback)

lowFilter  = not useExtremes or atLocalLow
highFilter = not useExtremes or atLocalHigh

// ===== Color filter =====
hammerColorOk  = not strictColors or isBullish
hangingColorOk = not strictColors or isBearish

// ===== Final patterns =====
hammer     = showHammer and shapeBase and downtrend and lowFilter and hammerColorOk
hangingMan = showHangingMan and shapeBase and uptrend and highFilter and hangingColorOk

// ===== Plot =====
plotshape(
     hammer,
     title="Hammer",
     style=shape.labelup,
     location=location.belowbar,
     text="Hammer",
     color=color.green,
     textcolor=color.white,
     size=size.small)

plotshape(
     hangingMan,
     title="Hanging Man",
     style=shape.labeldown,
     location=location.abovebar,
     text="Hanging Man",
     color=color.red,
     textcolor=color.white,
     size=size.small)

// ===== Alerts =====
alertcondition(hammer, title="Hammer detected", message="Hammer detected")
alertcondition(hangingMan, title="Hanging Man detected", message="Hanging Man detected")
````
