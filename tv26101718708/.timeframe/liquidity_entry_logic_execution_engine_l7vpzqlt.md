# Liquidity Entry Logic Execution Engine 

- url: https://www.tradingview.com/script/l7VPZQlT-Liquidity-Entry-Logic-Execution-Engine/
- type: strategy
- pine_id: PUB;6f0823eb24d64d55a51d2bba2190e19f
- version: 1.0

## Description

Liquidity Entry Logic is a price-action driven trading system built around how markets actually move:
liquidity → manipulation → expansion.

Instead of relying on traditional lagging indicators, this model focuses on:

Liquidity sweeps (stop hunts)
Market structure alignment
Momentum (displacement)
Session-based timing

The goal is simple:
 Enter trades only after the market reveals its true direction.

 What It’s Made Of

This system is built from five core components:

1.  Liquidity Engine (Asian Range)
Tracks the Asian session high/low
Identifies where liquidity (stops) builds overnight
These levels become targets for manipulation
2.  Liquidity Sweep Detection
Detects when price raids Asia highs/lows
Filters for strong sweeps (not weak breakouts)
Confirms manipulation before entry
3.  Structure & Trend Alignment
Uses Triple EMA (Fast / Mid / Slow) as structure filters
Confirms directional bias:
Bullish → price above structure
Bearish → price below structure
Includes higher timeframe (HTF) confirmation for trend consistency
4.  Displacement / Momentum Confirmation
Requires a strong impulse candle after the sweep
Prevents entering during weak or indecisive moves
Ensures the move has real intent behind it
5.  Session Timing (New York Focus)
Trades are filtered to high-probability sessions
Primarily optimized for:
New York Open
Early NY volatility window

 How the Strategy Works
Trade Flow Model:
Asia builds liquidity
Price sweeps high or low (stop hunt)
Market confirms direction
Impulse candle appears
Entry triggers with trend alignment

Best Timeframes
 Ideal Setup:
HTF Bias: 4H or Daily
Setup: 1H
Entry: 15m or 5m

 Why:
Higher timeframes define direction
Lower timeframes refine entries
Best Markets to Trade

This system performs best in high-liquidity, high-volatility markets:

Recommended:
Indices: NAS100 (NQ), S&P 500 (ES)
Forex: EURUSD, GBPUSD
Gold (XAUUSD)

Avoid:
Low volatility pairs
Illiquid markets
Random altcoins (inconsistent behavior)

How to Use It Effectively

 Focus on A+ Setups Only:
Clean sweep of Asia high/low
Strong impulse after sweep
EMA structure aligned
HTF bias confirmed

 Avoid These Mistakes:
Entering before sweep happens
Trading during sideways/choppy markets
Ignoring higher timeframe direction
Taking every signal blindly

## Source Code

````pine
//@version=6
strategy("Liquidity Entry Logic v14 – Execution Engine", overlay=true,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=100,
     max_labels_count=500,
     max_boxes_count=300)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
fastLen = input.int(21)
midLen  = input.int(321)
slowLen = input.int(440)

htf_tf = input.timeframe("240")

atrLen = input.int(14)
slATR  = input.float(1.5)
tpATR  = input.float(3.0)

minAplusScore = input.int(6, "A+ Threshold (0–8)")
onlyAplus     = input.bool(true, "Only Take A+ Trades")

asiaSession = input.session("1800-0000")
nySession   = input.session("0930-1200")

// ─────────────────────────────────────────────
// STRUCTURE
// ─────────────────────────────────────────────
fastEMA = ta.ema(close, fastLen)
midEMA  = ta.ema(close, midLen)
slowEMA = ta.ema(close, slowLen)

htfMid  = request.security(syminfo.tickerid, htf_tf, ta.ema(close, midLen))
htfSlow = request.security(syminfo.tickerid, htf_tf, ta.ema(close, slowLen))

bullHTF = htfMid > htfSlow
bearHTF = htfMid < htfSlow

// ─────────────────────────────────────────────
// SESSION + LIQUIDITY
// ─────────────────────────────────────────────
inAsia = not na(time(timeframe.period, asiaSession))
inNY   = not na(time(timeframe.period, nySession))

var float asiaHigh = na
var float asiaLow  = na

if inAsia and not inAsia[1]
    asiaHigh := high
    asiaLow  := low

if inAsia
    asiaHigh := math.max(asiaHigh, high)
    asiaLow  := math.min(asiaLow, low)

// ─────────────────────────────────────────────
// MARKET REGIME DETECTION (KEY UPGRADE)
// ─────────────────────────────────────────────
rangeSize = ta.sma(high - low, 20)
trendSize = math.abs(close - close[10])

isTrending = trendSize > rangeSize * 1.2
isRanging  = not isTrending
isChoppy   = ta.sma(rangeSize, 10) < ta.sma(rangeSize, 50)

// ─────────────────────────────────────────────
// LIQUIDITY SWEEP (2-STEP CONFIRMATION)
// ─────────────────────────────────────────────
wick = high - low
upperW = high - math.max(open, close)
lowerW = math.min(open, close) - low

rawSweepHigh = high > asiaHigh and upperW > wick * 0.45
rawSweepLow  = low < asiaLow and lowerW > wick * 0.45

confirmedSweepHigh = rawSweepHigh and close < open
confirmedSweepLow  = rawSweepLow and close > open

// ─────────────────────────────────────────────
// DISPLACEMENT CONFIRMATION
// ─────────────────────────────────────────────
avgRange = ta.sma(high - low, 10)

bullImpulse = close > open and (high - low) > avgRange * 1.3
bearImpulse = close < open and (high - low) > avgRange * 1.3

// ─────────────────────────────────────────────
// STRUCTURE ALIGNMENT
// ─────────────────────────────────────────────
trendBull = close > midEMA and midEMA > slowEMA
trendBear = close < midEMA and midEMA < slowEMA

// ─────────────────────────────────────────────
// SCORE SYSTEM (A+ MODEL)
// ─────────────────────────────────────────────
bullScore = 0
bullScore += confirmedSweepLow ? 2 : 0
bullScore += bullImpulse ? 1 : 0
bullScore += trendBull ? 1 : 0
bullScore += bullHTF ? 1 : 0
bullScore += inNY ? 1 : 0
bullScore += isTrending ? 1 : 0
bullScore += not isChoppy ? 1 : 0

bearScore = 0
bearScore += confirmedSweepHigh ? 2 : 0
bearScore += bearImpulse ? 1 : 0
bearScore += trendBear ? 1 : 0
bearScore += bearHTF ? 1 : 0
bearScore += inNY ? 1 : 0
bearScore += isTrending ? 1 : 0
bearScore += not isChoppy ? 1 : 0

// ─────────────────────────────────────────────
// FINAL FILTER
// ─────────────────────────────────────────────
longCondition  = bullScore >= minAplusScore
shortCondition = bearScore >= minAplusScore

// optional restriction
longCondition  := onlyAplus ? longCondition : (bullScore >= 4)
shortCondition := onlyAplus ? shortCondition : (bearScore >= 4)

// ─────────────────────────────────────────────
// EXECUTION
// ─────────────────────────────────────────────
atr = ta.atr(atrLen)

longSL = close - atr * slATR
longTP = close + atr * tpATR

shortSL = close + atr * slATR
shortTP = close - atr * tpATR

if (longCondition and strategy.position_size <= 0)
    strategy.entry("Long", strategy.long)

if (shortCondition and strategy.position_size >= 0)
    strategy.entry("Short", strategy.short)

strategy.exit("L Exit", from_entry="Long", stop=longSL, limit=longTP)
strategy.exit("S Exit", from_entry="Short", stop=shortSL, limit=shortTP)

// ─────────────────────────────────────────────
// VISUALS
// ─────────────────────────────────────────────
plot(fastEMA, color=color.red)
plot(midEMA, color=color.white)
plot(slowEMA, color=color.blue)

plotshape(longCondition, location=location.belowbar, color=color.lime, style=shape.triangleup)
plotshape(shortCondition, location=location.abovebar, color=color.red, style=shape.triangledown)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(longCondition, "LONG A+", "Liquidity Entry Logic v14 LONG")
alertcondition(shortCondition, "SHORT A+", "Liquidity Entry Logic v14 SHORT")
````
