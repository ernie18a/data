# Multi-Timeframe Trend Alignment Framework

- url: https://www.tradingview.com/script/NEtMdbmJ-Multi-Timeframe-Trend-Alignment-Framework/
- type: strategy
- pine_id: PUB;b02ff7707ced41178db8290013f2a82e
- version: 1.0

## Description

[b]Overview[/b]
Markets can look completely different depending on the timeframe being analyzed. A trend that appears strong on a 15-minute chart may simply be a pullback on a 4-hour chart.

This framework explores how multiple timeframes can be combined to provide additional market context. Instead of relying on a single chart, the approach examines higher-timeframe direction while using the current timeframe for trade identification.

The goal is to create a structured process for studying trend alignment across different market conditions.

[b]Core Idea[/b]
The framework separates market analysis into different layers:

[i]Higher Timeframe[/i]
The higher timeframe is used to establish the broader market direction.
Examples:
[list]
[*]Daily trend
[*]4-Hour trend
[*]1-Hour trend
[/list]
This helps identify whether the market is generally moving upward, downward, or sideways.

[i]Current Timeframe[/i]
The current timeframe is used to identify opportunities that align with the broader trend.
Rather than treating every signal equally, the framework studies signals that occur in the same direction as the higher-timeframe trend.

[i]Lower Timeframe (Optional)[/i]
Some traders use lower timeframes for additional timing and execution analysis.
The lower timeframe does not determine market direction but may provide additional detail about short-term price behavior.

[b]Framework Logic[/b]
[i]Step 1: Define Trend Direction[/i]
A moving average or other trend measure is used to identify the direction of the higher timeframe.
[i]Step 2: Confirm Alignment[/i]
The current timeframe is compared against the higher timeframe.
When both point in the same direction, the market is considered aligned.
[i]Step 3: Evaluate Opportunities[/i]
Signals are evaluated only when alignment exists between the selected timeframes.
[i]Step 4: Manage Risk[/i]
Risk parameters should be defined independently of trend direction and adjusted according to market volatility.

[b]Why Traders Study Trend Alignment[/b]
[i]Additional Market Context[/i]
Multiple timeframes can provide a broader view of market structure.
[i]Structured Decision-Making[/i]
The framework encourages consistency by defining market direction before evaluating potential entries.
[i]Cross-Market Application[/i]
The concept can be applied to:
[list]
[*]Stocks
[*]Forex
[*]Cryptocurrencies
[*]Indexes
[*]Commodities
[/list]

[b]Notes[/b]
Trend alignment does not guarantee future price movement. Different markets and timeframes may behave differently, and alignment can change as new price data becomes available.
This framework is intended as a research and educational tool for studying multi-timeframe trend behavior.

[b]Disclaimer[/b]
This framework is provided for educational and research purposes only. It demonstrates one way to analyze trend relationships across multiple timeframes and should be independently tested before being incorporated into any trading workflow.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AIScripts

//@version=6
strategy("Multi-Timeframe Trend Alignment Framework", overlay=true, initial_capital=100000, default_qty_type=strategy.percent_of_equity, default_qty_value=5)

// Inputs
higherTF = input.timeframe("240", "Higher Timeframe")
fastLen = input.int(20, "Fast EMA")
slowLen = input.int(50, "Slow EMA")
htfLen = input.int(200, "Higher TF EMA")
atrLen = input.int(14, "ATR Length")
atrMult = input.float(1.5, "Stop ATR Multiplier")
rr = input.float(2.0, "Risk Reward")

// Current Timeframe EMAs
fastEMA = ta.ema(close, fastLen)
slowEMA = ta.ema(close, slowLen)

// Higher Timeframe Trend
htfEMA = request.security(
     syminfo.tickerid,
     higherTF,
     ta.ema(close, htfLen),
     lookahead = barmerge.lookahead_off
)

// Trend Alignment
bullTrend = close > htfEMA
bearTrend = close < htfEMA

// Cross Signals
bullCross = ta.crossover(fastEMA, slowEMA)
bearCross = ta.crossunder(fastEMA, slowEMA)

// Entry Conditions
longCondition = bullTrend and bullCross
shortCondition = bearTrend and bearCross

// Entries
if longCondition and strategy.position_size <= 0
    strategy.entry("Long", strategy.long)

if shortCondition and strategy.position_size >= 0
    strategy.entry("Short", strategy.short)

// ATR Risk Management
atrValue = ta.atr(atrLen)

longStop = strategy.position_avg_price - atrValue * atrMult
longTarget = strategy.position_avg_price + atrValue * atrMult * rr

shortStop = strategy.position_avg_price + atrValue * atrMult
shortTarget = strategy.position_avg_price - atrValue * atrMult * rr

strategy.exit("Exit Long", from_entry="Long", stop=longStop, limit=longTarget)
strategy.exit("Exit Short", from_entry="Short", stop=shortStop, limit=shortTarget)

// Visuals
plot(fastEMA, color=color.orange, title="Fast EMA")
plot(slowEMA, color=color.blue, title="Slow EMA")
plot(htfEMA, color=color.green, title="Higher Timeframe EMA", linewidth=2)
````
