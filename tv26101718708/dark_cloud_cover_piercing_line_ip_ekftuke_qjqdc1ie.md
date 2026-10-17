# Dark Cloud Cover & Piercing Line | IP | EkF.TUKE

- url: https://www.tradingview.com/script/qJqdc1Ie-dark-cloud-cover-piercing-line-ip-ekf-tuke/
- type: indicator
- pine_id: PUB;c226cf5298004f2eb2b588d93b313d42
- version: 1.0

## Description

This algorithm is used to automatically identify the Dark Cloud Cover and Piercing Line candlestick patterns on price charts, mark them directly in TradingView, and enable their testing on historical market data, which helps evaluate whether these two-candle reversal formations generate reliable bearish or bullish signals under different market conditions.

## Source Code

````pine
//@version=6
indicator("Dark Cloud Cover & Piercing Line | IP | EkF.TUKE", shorttitle="DCC + PL | IP | EkF.TUKE", overlay=true)

// ===== Inputs =====
showDarkCloud    = input.bool(true, "Show Dark Cloud Cover")
showPiercingLine = input.bool(true, "Show Piercing Line")

patternMode      = input.string("Basic", "Pattern mode", options=["Basic", "Strict"])

useTrendFilter   = input.bool(true, "Use trend filter")
trendBars        = input.int(3, "Trend candles before pattern", minval=2, maxval=6)

useBodyFilter    = input.bool(true, "Use strong body filter")
minBodyToRange1  = input.float(0.55, "Min first body / range", minval=0.1, maxval=1.0, step=0.05)
minBodyToRange2  = input.float(0.40, "Min second body / range", minval=0.1, maxval=1.0, step=0.05)

useMidpointRule  = input.bool(true, "Require midpoint penetration")
midpointBuffer   = input.float(0.02, "Midpoint buffer (part of first body)", minval=0.0, maxval=0.3, step=0.01)

useExtremes      = input.bool(true, "Use local high/low filter")
extremeLookback  = input.int(10, "Local extreme lookback", minval=3)

useSmaFilter     = input.bool(false, "Use SMA trend filter")
smaLen           = input.int(20, "SMA length", minval=5)

// ===== Current candle =====
body        = math.abs(close - open)
candleRange = high - low
isBull      = close > open
isBear      = open > close
bodyRatio   = candleRange > 0 ? body / candleRange : 0.0

// ===== Previous candle =====
prevOpen    = open[1]
prevClose   = close[1]
prevHigh    = high[1]
prevLow     = low[1]
prevBody    = math.abs(prevClose - prevOpen)
prevRange   = prevHigh - prevLow
prevBull    = prevClose > prevOpen
prevBear    = prevOpen > prevClose
prevMid     = (prevOpen + prevClose) / 2.0
prevRatio   = prevRange > 0 ? prevBody / prevRange : 0.0

// ===== Candle strength =====
firstBodyOk  = not useBodyFilter or prevRatio >= minBodyToRange1
secondBodyOk = not useBodyFilter or bodyRatio >= minBodyToRange2

// ===== Trend context =====
downtrend = true
uptrend   = true

for i = 1 to trendBars
    downtrend := downtrend and close[i] < open[i]
    uptrend   := uptrend and close[i] > open[i]

smaValue     = ta.sma(close, smaLen)
smaDowntrend = close[1] < smaValue[1]
smaUptrend   = close[1] > smaValue[1]

downtrendOk = (not useTrendFilter or downtrend[1]) and (not useSmaFilter or smaDowntrend)
uptrendOk   = (not useTrendFilter or uptrend[1]) and (not useSmaFilter or smaUptrend)

// ===== Local extremes =====
atLocalLow  = prevLow  <= ta.lowest(low, extremeLookback)[1]
atLocalHigh = prevHigh >= ta.highest(high, extremeLookback)[1]

lowFilter   = not useExtremes or atLocalLow
highFilter  = not useExtremes or atLocalHigh

// ===== Mode =====
strictMode = patternMode == "Strict"

// ===== Midpoint buffer =====
midBuf = prevBody * midpointBuffer

// ===== Dark Cloud Cover =====
dccBase = prevBull and isBear

dccOpenBasic  = open >= prevClose
dccOpenStrict = open >= prevHigh
dccOpenOk     = strictMode ? dccOpenStrict : dccOpenBasic

dccCloseMid   = close < (prevMid - midBuf)
dccCloseUpper = close > prevOpen
dccCloseOk    = (not useMidpointRule or dccCloseMid) and dccCloseUpper

darkCloud = showDarkCloud and dccBase and dccOpenOk and dccCloseOk and uptrendOk and highFilter and firstBodyOk and secondBodyOk

// ===== Piercing Line =====
plBase = prevBear and isBull

plOpenBasic  = open <= prevClose
plOpenStrict = open <= prevLow
plOpenOk     = strictMode ? plOpenStrict : plOpenBasic

plCloseMid   = close > (prevMid + midBuf)
plCloseLower = close < prevOpen
plCloseOk    = (not useMidpointRule or plCloseMid) and plCloseLower

piercingLine = showPiercingLine and plBase and plOpenOk and plCloseOk and downtrendOk and lowFilter and firstBodyOk and secondBodyOk

// ===== Plot =====
plotshape(
     darkCloud,
     title="Dark Cloud Cover",
     style=shape.labeldown,
     location=location.abovebar,
     text="Dark Cloud",
     color=color.red,
     textcolor=color.white,
     size=size.small)

plotshape(
     piercingLine,
     title="Piercing Line",
     style=shape.labelup,
     location=location.belowbar,
     text="Piercing",
     color=color.green,
     textcolor=color.white,
     size=size.small)

// ===== Alerts =====
alertcondition(
     darkCloud,
     title="Dark Cloud Cover detected",
     message="Dark Cloud Cover detected")

alertcondition(
     piercingLine,
     title="Piercing Line detected",
     message="Piercing Line detected")
````
