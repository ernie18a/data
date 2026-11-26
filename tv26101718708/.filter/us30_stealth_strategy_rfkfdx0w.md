# US30 Stealth Strategy

- url: https://www.tradingview.com/script/rfKfdX0W-US30-Stealth-Strategy/
- type: strategy
- pine_id: PUB;2de07cc2b1aa44b7a95ee50896a81c2c
- version: 1.0

## Description

Only works on US30 (CAPITALCOM) 5 Minute chart
📈 Core Concept:
This is a trend-following strategy that captures strong market continuations by entering on:

The 3rd swing in the current trend,

Confirmed by a volume-verified engulfing candle,

With adaptive SL/TP and position sizing based on risk.

🧠 Entry Logic:
✅ Trend Filter
Uses a 50-period Simple Moving Average (SMA).

Buy only if price is above SMA → Uptrend

Sell only if price is below SMA → Downtrend

✅ Swing Count Logic
For buy: Wait for the 3rd higher low

For sell: Wait for the 3rd lower high

Uses a 5-bar lookback to detect highs/lows

This ensures you’re not buying early — but after trend is confirmed with structure.

✅ Engulfing Candle Confirmation
Bullish engulfing for buys

Bearish engulfing for sells

Candle must engulf previous bar completely (body logic)

✅ Volume Filter
Current candle volume must be greater than the 20-period volume average

Ensures trades only occur with institutional participation

✅ MA Slope Filter
Requires the slope of the 50 SMA over the last 3 candles to exceed 0.1

Avoids chop or flat trends

Adds momentum confirmation to the trade

✅ Session Filter (Time Filter)
Trades only executed between:

2:00 AM to 11:00 PM Oman Time (UTC+4)

Helps avoid overnight chop and illiquidity

📊 Position Sizing & Risk Management
✅ Smart SL (Adaptive Stop Loss)
SL is based on full size of the signal candle (including wick)

But if candle is larger than 25 points, SL is cut to half the size

This prevents oversized risk from long signals during volatile moves.

## Source Code

````pine
// @version=6
strategy("US30 Stealth Strategy", overlay=true, default_qty_type=strategy.cash, default_qty_value=100)


// === USER INPUTS ===
maLen = input.int(50, "Trend MA Length")
volMaLen = input.int(20, "Volume MA Length")
hlLookback = input.int(5, "Lookback for High/Low Detection")
rrRatio = input.float(2.2, "Risk-to-Reward Ratio", step=0.1)
maxCandleSize = input.float(30.0, "Max Candle Size (pips/points)")
pipValue = input.float(1.0, "Pip Value (USD per pip/point)")
riskAmount = input.float(50.0, "Risk Per Trade (USD)")
largeCandleThreshold = input.float(25.0, "Threshold for large candles")
maSlopeLen = input.int(3, "MA Slope Lookback Bars")
minSlope = input.float(0.1, "Min Slope Threshold")


// === TREND DETECTION ===
ma = ta.sma(close, maLen)
slope = ma - ma[maSlopeLen]
isSlopeUp = slope > minSlope
isSlopeDown = slope < -minSlope
isDownTrend = close < ma and isSlopeDown
isUpTrend = close > ma and isSlopeUp


// === COUNTERS ===
var int lhCount = 0
var int hlCount = 0


// === LOWER HIGH DETECTION ===
isLowerHigh = high < ta.highest(high[1], hlLookback)
if isLowerHigh
    lhCount += 1


// === HIGHER LOW DETECTION ===
isHigherLow = low > ta.lowest(low[1], hlLookback)
if isHigherLow
    hlCount += 1


// === ENGULFING DETECTIONS ===
bearEng = (close < open) and (close < open[1]) and (open > close[1]) and (close <= open[1]) and (open >= close[1])
bullEng = (close > open) and (close > open[1]) and (open < close[1]) and (close >= open[1]) and (open <= close[1])


// === VOLUME FILTER ===
volMA = ta.sma(volume, volMaLen)
volOK = volume > volMA


// === TIME FILTER (Oman 2AM–11PM = UTC 22:00–19:00) ===
inSession = (hour >= 22 or hour < 19)


// === CANDLE SIZE & SL LOGIC ===
rawCandleSize = high - low
useHalfCandle = rawCandleSize > largeCandleThreshold
slSize = useHalfCandle ? rawCandleSize / 2 : rawCandleSize
validSize = rawCandleSize <= maxCandleSize


// === SIGNAL CONDITIONS ===
sellSig = inSession and isDownTrend and (lhCount % 3 == 0) and bearEng and volOK and validSize
buySig  = inSession and isUpTrend and (hlCount % 3 == 0) and bullEng and volOK and validSize


// === RISK-CALCULATED POSITION SIZE ===
positionSize = riskAmount / (slSize * pipValue)


// === SL/TP LEVELS ===
bearSL = close + slSize
bearTP = close - rrRatio * slSize


bullSL = close - slSize
bullTP = close + rrRatio * slSize


// === EXECUTIONS ===
if sellSig
    strategy.entry("Sell", strategy.short, qty=positionSize)
    strategy.exit("TP/SL Sell", from_entry="Sell", stop=bearSL, limit=bearTP)
    lhCount := 0


if buySig
    strategy.entry("Buy", strategy.long, qty=positionSize)
    strategy.exit("TP/SL Buy", from_entry="Buy", stop=bullSL, limit=bullTP)
    hlCount := 0
````
