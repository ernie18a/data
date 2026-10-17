# Trend Persistence Analysis Framework

- url: https://www.tradingview.com/script/MI47rsio-Trend-Persistence-Analysis-Framework/
- type: strategy
- pine_id: PUB;5cf782acf6d94e8390c27598723b1073
- version: 1.0

## Description

[b]Overview[/b]
Many trend-based strategies focus on identifying direction. This framework takes a different approach by studying how long a trend remains intact before signs of deterioration appear.
Rather than asking whether a market is moving up or down, the objective is to measure trend persistence and evaluate whether the current trend continues to maintain its structure over time.
This framework combines trend direction, trend duration, and volatility-based risk management into a rules-based testing model.

[b]Core Idea[/b]
A trend often develops through a series of higher highs and higher lows during an uptrend, or lower highs and lower lows during a downtrend.
The framework tracks whether the trend remains intact and only considers opportunities when persistence conditions continue to be met.
The goal is to study periods where market direction remains consistent over multiple bars rather than reacting to every short-term fluctuation.

[b]Strategy Logic[/b]
[b]Trend Identification[/b]
The framework uses a combination of fast and slow moving averages to establish market direction.

[b]Persistence Measurement[/b]
A trend is considered persistent when:
[list]
[*]The fast moving average remains above the slow moving average during an uptrend.
[*]The fast moving average remains below the slow moving average during a downtrend.
[*]Trend alignment remains intact for a minimum number of bars.
[/list]

[b]Entry Conditions[/b]
Long opportunities are evaluated when:
[list]
[*]Uptrend conditions exist.
[*]Trend persistence exceeds the minimum threshold.
[/list]
[b][/b]Short opportunities are evaluated when:
[list]
[*]Downtrend conditions exist.
[*]Trend persistence exceeds the minimum threshold.
[/list]
[b]Risk Management[/b]
The strategy uses ATR-based stop-loss and target levels to adapt to changing market volatility.

[b]Why Study Trend Persistence?[/b]
[b]Market Context[/b]
Trend persistence can provide additional information about the stability of a move.
[b]Reduced Noise[/b]
By requiring trends to remain intact for a period of time, the framework avoids reacting to every short-term change in direction.
[b]Research and Testing[/b]
The model provides a structured way to analyze trend behavior across different symbols and timeframes.

[b]Notes[/b]
This framework is intended as an educational example demonstrating one approach to studying trend duration and trend quality.
Trend persistence does not predict future price movement and should be evaluated across different market environments.

[b]Disclaimer[/b]
This script is provided for educational and research purposes only. It demonstrates one way to study trend persistence using Pine Script. Results will vary across symbols, timeframes, and market conditions. Independent testing is recommended before incorporating any methodology into a trading workflow.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AIScripts

//@version=6
strategy("Trend Persistence Analysis Framework", overlay=true, initial_capital=100000, default_qty_type=strategy.percent_of_equity, default_qty_value=5)

// Inputs
fastLen = input.int(20, "Fast EMA")
slowLen = input.int(50, "Slow EMA")
minTrendBars = input.int(10, "Minimum Trend Duration")
atrLen = input.int(14, "ATR Length")
atrMult = input.float(1.5, "Stop ATR Multiplier")
rr = input.float(2.0, "Risk Reward")

// Trend Calculation
fastEMA = ta.ema(close, fastLen)
slowEMA = ta.ema(close, slowLen)

// Trend State
bullTrend = fastEMA > slowEMA
bearTrend = fastEMA < slowEMA

// Persistence Counters
var int bullBars = 0
var int bearBars = 0

bullBars := bullTrend ? bullBars + 1 : 0
bearBars := bearTrend ? bearBars + 1 : 0

// Entry Conditions
longCondition = bullTrend and bullBars >= minTrendBars
shortCondition = bearTrend and bearBars >= minTrendBars

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
plot(fastEMA, title="Fast EMA", color=color.orange)
plot(slowEMA, title="Slow EMA", color=color.blue)
````
