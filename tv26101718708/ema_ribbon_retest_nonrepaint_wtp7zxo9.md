# EMA Ribbon Retest (Non-Repaint)

- url: https://www.tradingview.com/script/WTp7Zxo9/
- type: indicator
- pine_id: PUB;36d3d124f1cb4a9c9e42142c5c25cc54
- version: 5.0

## Description

EMA Ribbon Retest (Non-Repaint) + Stochastic RSI Exit System
Overview

This indicator combines an EMA Ribbon structure, a trend-based retest detection system, and a Stochastic RSI exit mechanism to provide clean, non-repainting buy/sell signals with structured trade management logic.

It is designed for traders who focus on trend continuation entries after pullbacks (retests) and want a systematic exit strategy based on momentum exhaustion.

Core Components
1. EMA Ribbon Trend Structure

The indicator uses four exponential moving averages:

EMA 20
EMA 50
EMA 100
EMA 200

These EMAs form a trend ribbon that defines market direction:

Bullish Trend: EMA 20 > EMA 50 > EMA 100 > EMA 200
Bearish Trend: EMA 20 < EMA 50 < EMA 100 < EMA 200

This structure filters trades only in clear directional markets.

2. Ribbon Compression Filter

Before a valid setup is considered, the indicator checks for EMA ribbon compression.

Ribbon width is calculated as the percentage distance between the highest and lowest EMA relative to price.
When this width is below the defined threshold, the market is considered compressed (consolidation phase).

This helps identify accumulation zones before breakout continuation moves.

3. Retest Logic (Entry Signals)

The system looks for price returning to the midpoint of the EMA ribbon after compression.

Buy Setup:

A BUY signal is triggered when:

Market is in bullish trend
Previous candle shows ribbon compression
Price retests the mid-ribbon zone
Price closes back above the midpoint
Sell Setup:

A SELL signal is triggered when:

Market is in bearish trend
Previous candle shows ribbon compression
Price retests the mid-ribbon zone
Price closes back below the midpoint

This creates a trend continuation after pullback strategy.

4. Non-Repaint Signal Engine

To ensure reliability:

Signals are only confirmed on closed candles
A cooldown period prevents repeated signals in a short time
Prevents signal clustering during choppy market conditions
5. Stochastic RSI Exit System

The indicator includes a momentum-based exit filter using Stochastic RSI (K & D lines).

Long Position Exit:
Triggered when Stochastic RSI is above the upper band (default 80)
AND a bearish crossover occurs (K crosses below D)
Short Position Exit:
Triggered when Stochastic RSI is below the lower band (default 20)
AND a bullish crossover occurs (K crosses above D)

This ensures exits happen when momentum starts fading, not randomly.

Position State Logic

The script maintains internal position tracking:

Activates long state after BUY signal
Activates short state after SELL signal
Resets position state on exit conditions

This allows structured trade lifecycle logic inside an indicator.

Visual Features
EMA ribbon displayed with 4 colored EMAs
Background highlight during compression phases
BUY / SELL labels directly on chart
EXIT markers for trade management
Clean and minimal visual structure for clarity
Alerts

The script includes alert conditions for:

BUY signals
SELL signals
BUY exits
SELL exits

These can be used for real-time notifications or automation workflows.

Strategy Concept

This indicator is based on a three-stage market model:

Compression Phase → Market builds energy
Retest Phase → Price revisits equilibrium zone
Continuation Phase → Trend resumes

Combined with momentum-based exits, it creates a full trend continuation system with structured risk control.

Best Use Cases
Trend trading
Swing trading
Breakout continuation strategies
Multi-timeframe analysis (higher TF = stronger signals)
Notes
This is a non-repainting indicator
Signals are confirmed only on closed candles
Best performance in trending markets

## Source Code

````pine
//@version=6
indicator("EMA Ribbon Retest (Non-Repaint)", overlay=true, max_labels_count=500)

//══════════════════════════════
// EMA SETTINGS
//══════════════════════════════
ema1Len = input.int(20, "EMA 1")
ema2Len = input.int(50, "EMA 2")
ema3Len = input.int(100, "EMA 3")
ema4Len = input.int(200, "EMA 4")

// Ribbon compression setting
compressionPerc = input.float(1.0, "Ribbon Compression %", step=0.1)

// Retest tolerance
retestTolerance = input.float(0.3, "Retest Tolerance %", step=0.1)

// Signal cooldown bars
cooldownBars = input.int(10, "Signal Cooldown Bars")

//══════════════════════════════
// EMA CALCULATION
//══════════════════════════════
ema1 = ta.ema(close, ema1Len)
ema2 = ta.ema(close, ema2Len)
ema3 = ta.ema(close, ema3Len)
ema4 = ta.ema(close, ema4Len)

//══════════════════════════════
// EMA RIBBON WIDTH
//══════════════════════════════
highestEMA = math.max(math.max(ema1, ema2), math.max(ema3, ema4))
lowestEMA  = math.min(math.min(ema1, ema2), math.min(ema3, ema4))

ribbonWidth = ((highestEMA - lowestEMA) / close) * 100

// Compression
isCompressed = ribbonWidth < compressionPerc

//══════════════════════════════
// TREND DIRECTION
//══════════════════════════════
bullTrend = ema1 > ema2 and ema2 > ema3 and ema3 > ema4
bearTrend = ema1 < ema2 and ema2 < ema3 and ema3 < ema4

//══════════════════════════════
// RETEST ZONE
//══════════════════════════════
midRibbon = (highestEMA + lowestEMA) / 2

bullRetest =
     bullTrend and
     isCompressed[1] and
     low <= midRibbon * (1 + retestTolerance / 100) and
     close > midRibbon

bearRetest =
     bearTrend and
     isCompressed[1] and
     high >= midRibbon * (1 - retestTolerance / 100) and
     close < midRibbon

//══════════════════════════════
// NON-REPAINT SIGNAL FILTER
//══════════════════════════════
var int lastBuyBar = na
var int lastSellBar = na

buySignal =
     bullRetest and
     barstate.isconfirmed and
     (na(lastBuyBar) or bar_index - lastBuyBar > cooldownBars)

sellSignal =
     bearRetest and
     barstate.isconfirmed and
     (na(lastSellBar) or bar_index - lastSellBar > cooldownBars)

if buySignal
    lastBuyBar := bar_index

if sellSignal
    lastSellBar := bar_index

//══════════════════════════════
// CHART
//══════════════════════════════
plot(ema1, color=color.green, linewidth=2)
plot(ema2, color=color.lime, linewidth=2)
plot(ema3, color=color.orange, linewidth=2)
plot(ema4, color=color.red, linewidth=2)

bgcolor(isCompressed ? color.new(color.yellow, 90) : na)

//══════════════════════════════
// SIGNALS
//══════════════════════════════
plotshape(
     buySignal,
     title="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="BUY",
     textcolor=color.white,
     size=size.small)

plotshape(
     sellSignal,
     title="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SELL",
     textcolor=color.white,
     size=size.small)

//══════════════════════════════
// ALERTS
//══════════════════════════════
alertcondition(buySignal, title="BUY ALERT", message="EMA Ribbon BUY Retest")
alertcondition(sellSignal, title="SELL ALERT", message="EMA Ribbon SELL Retest")
//══════════════════════════════
// SUPERTREND (EXIT SIGNALS)
//══════════════════════════════
stAtrPeriod = input.int(10, "EXIT ATR Period")
stFactor    = input.float(3.0, "EXIT Factor", step=0.1)

[supertrend, stDirection] = ta.supertrend(stFactor, stAtrPeriod)

// SuperTrend BUY / SELL
stBuySignal  = ta.change(stDirection) < 0
stSellSignal = ta.change(stDirection) > 0

// SuperTrend Line
plot(
     supertrend,
     title="SuperTrend",
     color=stDirection < 0 ? color.green : color.red,
     linewidth=2)

// SuperTrend Signals
plotshape(
     stBuySignal,
     title="EXIT SELL",
     style=shape.labelup,
     location=location.belowbar,
     color=color.new(color.green, 0),
     text="EXIT SELL",
     textcolor=color.white,
     size=size.small)

plotshape(
     stSellSignal,
     title="EXIT BUY",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.new(color.red, 0),
     text="EXIT BUY",
     textcolor=color.white,
     size=size.small)

// SuperTrend Alerts
alertcondition(
     stBuySignal,
     title="EXIT SELL",
     message="SuperTrend BUY Signal")

alertcondition(
     stSellSignal,
     title="EXIT BUY",
     message="SuperTrend SELL Signal")
````
