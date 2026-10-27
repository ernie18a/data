# BB + MACD v6.1.5 (Qing Smart Distribution)

- url: https://www.tradingview.com/script/qo43NaGV-BB-MACD-v6-1-5-Qing-Smart-Distribution/
- type: strategy
- pine_id: PUB;e54a7c8ff8994acba4d0514c8fd5860d
- version: 1.0

## Description

Strategy Summary: Qing BB + MACD v6.1.5 (Smart Distribution)
Concept
A long‑only momentum strategy that catches confirmed breakouts (Bollinger Basis + MACD) and actively manages exits by detecting distribution, trend exhaustion, or blow‑off tops. The goal is to ride the middle part of a trend while exiting before a major reversal.

📈 Entry – “ECU Confirming Solid Rise”
Conditions (all required):

Price breakout – close crosses above the 20‑period SMA (Bollinger Basis) or MACD line crosses above signal line while price is already above the Basis and histogram > 0.

Solid momentum – MACD histogram is positive and rising (higher than previous bar).

Volume confirmation – current volume ≥ 20‑period average (optional but enabled by default).

Bullish candle – close > open.

Why: Only enter when momentum is actively accelerating – not on weak or fading bounces.

📉 Exits – Three Independent Stop/Target Mechanisms
Exit Type	Condition	When triggered
Smart Distribution	Price touched or approached upper BB within last 3 bars + MACD histogram shrinking for 2 consecutive bars + red candle & no new high	Exits near potential tops where smart money may be distributing
Hard Trend End	close < (Basis – ATR(14)×0.5) and red candle	Breaks trend support – ATR‑based safety net
Blow‑off Top	close > upper BB and MACD line > 0 and MACD line > signal line × 2.5	Captures extreme parabolic moves (exits early, avoids deep retrace)
⚠️ The strategy exits completely when any of the three conditions becomes true.

🎛️ User Inputs (adjustable)
Bollinger Bands: length 20, multiplier 2.0

MACD: (6, 12, 8)

Exit ATR buffer: 0.5 (hard trend end sensitivity)

Volume filter: on/off

🧠 Key Insight
Most breakout strategies buy the break and hold until a trailing stop is hit.
This script instead watches how the market behaves near resistance (upper BB, stalling candles, shrinking histogram).
It treats those as early warnings that the trend is losing internal strength – even if price hasn’t reversed yet.

## Source Code

````pine
//@version=6
strategy("Qing BB + MACD v6.1.5 (Smart Distribution)", overlay=true, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=100, commission_type=strategy.commission.percent, commission_value=0.1)

// ==========================================
// 1. INPUTS & SETTINGS
// ==========================================
bbLength = input.int(20, "BB Length", group="Bollinger Bands")
bbMult   = input.float(2.0, "BB Multiplier", group="Bollinger Bands")

fastLen  = input.int(6, "MACD Fast Length", group="MACD")
slowLen  = input.int(12, "MACD Slow Length", group="MACD")
sigLen   = input.int(8, "MACD Signal Length", group="MACD")

atrMult  = input.float(0.5, "Exit ATR Buffer (Trend End)", group="Filters")
useVol   = input.bool(true, "Require Volume Confirmation", group="Filters")

// ==========================================
// 2. DATA PROCESSING (SENSORS)
// ==========================================
basis = ta.sma(close, bbLength)
dev   = bbMult * ta.stdev(close, bbLength)
upper = basis + dev
lower = basis - dev

[macdLine, signalLine, hist] = ta.macd(close, fastLen, slowLen, sigLen)

atr = ta.atr(14)
avgVol = ta.sma(volume, 20)
volOK = useVol ? (volume >= avgVol) : true // Requires volume to be at least average

// ==========================================
// 3. ECU ENTRY LOGIC (Confirming Solid Rise)
// ==========================================
// ECU Rule: When price crosses the Basis, is it a SOLID rise?
// Answer: MACD must be bullish, Histogram must be growing (momentum), and Volume must be strong.
isSolidMomentum = (macdLine > signalLine) and (hist > 0) and (hist > hist[1])
priceBreakout   = ta.crossover(close, basis) and isSolidMomentum
macdBreakout    = ta.crossover(macdLine, signalLine) and (close > basis) and (hist > 0)

entrySignal = (priceBreakout or macdBreakout) and volOK and (close > open)

// ==========================================
// 4. ECU EXIT LOGIC (Detecting Distribution)
// ==========================================
// STATE A: "Smart Money Distribution" (The Top Trap)
// 1. Price recently touched or is very close to the Upper BB (within last 3 days)
nearUpperBB = ta.highest(high, 3) >= upper[1]
// 2. MACD Momentum is weakening (Histogram has been shrinking for 2 days in a row)
macdBleeding = (hist < hist[1]) and (hist[1] < hist[2])
// 3. Price is stalling (Printed a red candle, failing to make a new high)
priceStalling = (close < open) and (close <= close[1])

exitDistribution = nearUpperBB and macdBleeding and priceStalling

// STATE B: "Hard Trend End" (From v6.1 - The ATR Safety Net)
exitTrendEnd = (close < (basis - (atr * atrMult))) and (close < open)

// STATE C: "Blow-off Top" (Your brilliant original rule)
exitExhaustion = (close > upper) and (macdLine > 0) and (macdLine > (signalLine * 2.5))

// ==========================================
// 5. EXECUTION & PLOTTING
// ==========================================
if entrySignal
    strategy.entry("Long", strategy.long)

if exitDistribution or exitTrendEnd or exitExhaustion
    strategy.close("Long", comment = exitDistribution ? "Distribution Exit" : (exitExhaustion ? "Blow-off Exit" : "Trend End Exit"))

// Plotting
plot(basis, "Basis", color=color.white, linewidth=2)
p1 = plot(upper, "Upper", color=color.rgb(242, 54, 69))
p2 = plot(lower, "Lower", color=color.rgb(8, 153, 129))
fill(p1, p2, title="BB Background", color=color.new(color.blue, 90))

// Buffer Line
plot(basis - (atr * atrMult), "Exit Buffer Limit", color=color.new(color.orange, 50), style=plot.style_cross)

// Markers
plotshape(entrySignal and strategy.position_size == 0, title="Buy Signal", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(exitDistribution and strategy.position_size > 0, title="Distribution Exit", style=shape.triangledown, location=location.abovebar, color=color.fuchsia, size=size.small, text="DIST")
plotshape(exitExhaustion and strategy.position_size > 0, title="Blow-off TP", style=shape.triangledown, location=location.abovebar, color=color.orange, size=size.small, text="PEAK")
````
