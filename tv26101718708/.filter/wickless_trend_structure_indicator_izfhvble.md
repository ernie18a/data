# Wickless Trend Structure Indicator

- url: https://www.tradingview.com/script/IZFhvBLE-Wickless-Trend-Structure-Indicator/
- type: indicator
- pine_id: PUB;4efb55b5bbe04a48a48df979ccef331e
- version: 1.0

## Description

Detect wickless candles
Define external trend (higher timeframe bias via EMA)
Define internal structure (short-term BOS-style logic)
Classify signals:
✅ High probability = wickless with external + internal trend
⚠️ Low probability = wickless against or during structure shift

## Source Code

````pine
//@version=5
indicator("Wickless Trend Structure Indicator", overlay=true)

// =========================
// INPUTS
// =========================
htf        = input.timeframe("60", "Higher Timeframe")
emaLength  = input.int(50, "HTF EMA Length")
structureLen = input.int(5, "Internal Structure Lookback")
wickThreshold = input.float(0.1, "Wick Threshold (%)", step=0.1)

// =========================
// WICKLESS DETECTION
// =========================
body = math.abs(close - open)
upperWick = high - math.max(close, open)
lowerWick = math.min(close, open) - low

isBullWickless = lowerWick <= body * wickThreshold
isBearWickless = upperWick <= body * wickThreshold

// =========================
// EXTERNAL TREND (HTF EMA)
// =========================
htfClose = request.security(syminfo.tickerid, htf, close)
htfEMA   = request.security(syminfo.tickerid, htf, ta.ema(close, emaLength))

externalBull = htfClose > htfEMA
externalBear = htfClose < htfEMA

// =========================
// INTERNAL STRUCTURE (BOS)
// =========================
hh = ta.highest(high, structureLen)
ll = ta.lowest(low, structureLen)

bullStructure = close > hh[1]
bearStructure = close < ll[1]

// Track internal trend direction
var intTrend = 0
if bullStructure
    intTrend := 1
else if bearStructure
    intTrend := -1

// =========================
// CLASSIFICATION
// =========================
highProbBull = isBullWickless and externalBull and intTrend == 1
highProbBear = isBearWickless and externalBear and intTrend == -1

lowProbBull  = isBullWickless and (not externalBull or intTrend != 1)
lowProbBear  = isBearWickless and (not externalBear or intTrend != -1)

// =========================
// PLOTTING
// =========================
plotshape(highProbBull, title="High Prob Bull", location=location.belowbar, color=color.green, style=shape.triangleup, size=size.small)
plotshape(highProbBear, title="High Prob Bear", location=location.abovebar, color=color.red, style=shape.triangledown, size=size.small)

plotshape(lowProbBull, title="Low Prob Bull", location=location.belowbar, color=color.new(color.green, 70), style=shape.circle, size=size.tiny)
plotshape(lowProbBear, title="Low Prob Bear", location=location.abovebar, color=color.new(color.red, 70), style=shape.circle, size=size.tiny)

// =========================
// VISUAL TREND HELP
// =========================
bgcolor(externalBull ? color.new(color.green, 90) : externalBear ? color.new(color.red, 90) : na)
````
