# Market Breadth Trend Strategy

- url: https://www.tradingview.com/script/JBDWeA0T-Market-Breadth-Trend-Strategy/
- type: strategy
- pine_id: PUB;5313ec78d92e4f1a9511b865dbe14907
- version: 1.0

## Description

[b]Overview[/b]
Many traders focus on major indexes such as the S&P 500 or Nasdaq when evaluating market conditions. While indexes show overall price movement, they do not always reflect how broadly that movement is supported across the market.
Market breadth is a way of studying participation. It can help traders understand whether strength or weakness is concentrated in a small group of stocks or spread across a wider portion of the market.
A market move supported by broad participation may provide different context than a move driven by only a few heavily weighted stocks.

[b]Understanding Market Participation[/b]
Market breadth generally refers to the number of securities contributing to a market move.
Examples of breadth-related observations include:

[list]
[*]The balance between advancing and declining stocks
[*]The number of stocks reaching new highs or lows
[*]The percentage of stocks trading above key moving averages
[/list]

These measurements can provide additional perspective alongside price action and trend analysis.

[b]Why Traders Monitor Breadth[/b]

[b]Participation Matters[/b]

Strong participation may indicate that market activity is occurring across a wider group of stocks rather than being concentrated in a few names.

[b]Additional Context[/b]
Breadth can be used as a supplementary tool when evaluating trends, momentum, and overall market conditions.

[b]Market Observation[/b]
Some traders monitor breadth metrics to better understand changes in participation over time and how those changes compare with index performance.

[b]Strategy Concept[/b]
This script uses a simplified breadth-style proxy derived from the chart's relationship to a long-term moving average.

It is important to note that this script does not use actual exchange-wide market breadth data. Instead, it creates a participation-style filter using price behavior on the current chart.

The strategy combines:

[list]
[*]Trend identification using moving averages
[*]A breadth-style participation filter
[*]ATR-based risk management
[/list]

The objective is to demonstrate how participation concepts can be incorporated into a trend-following framework for research and testing purposes.

[b]Important Notes[/b]

[list]
[*]This script uses a simplified participation-style filter and is not a substitute for exchange-wide breadth indicators.
[*]Results will vary across symbols, timeframes, and market conditions.
[*]The script is intended for educational, research, and testing purposes.
[/list]

[b]Disclaimer[/b]
This script is provided for educational and research purposes only. It demonstrates one way to combine trend analysis with a breadth-style participation filter. It is not financial advice and should be tested across different symbols, market conditions, and timeframes before being used in any trading workflow.
This version avoids performance claims, avoids implying predictive ability, and clearly explains the limitations of the breadth proxy.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AIScripts

//@version=6
strategy("Market Breadth Trend Strategy", overlay=true, initial_capital=100000)

// Inputs
emaFastLen = input.int(50, "Fast EMA")
emaSlowLen = input.int(200, "Slow EMA")
atrLen = input.int(14, "ATR Length")
atrMult = input.float(1.5, "ATR Stop Multiplier")
rr = input.float(2.0, "Risk Reward")

// Trend
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

trendBull = emaFast > emaSlow
trendBear = emaFast < emaSlow

// Simplified Breadth-Style Proxy
breadthLine = ta.sma(close > emaSlow ? 100 : 0, 20)

strongBreadth = breadthLine > 60
weakBreadth = breadthLine < 40

// Entries
longCondition = trendBull and strongBreadth
shortCondition = trendBear and weakBreadth

if longCondition and strategy.position_size <= 0
    strategy.entry("Long", strategy.long)

if shortCondition and strategy.position_size >= 0
    strategy.entry("Short", strategy.short)

// Risk Management
atrValue = ta.atr(atrLen)

longStop = strategy.position_avg_price - atrValue * atrMult
longTarget = strategy.position_avg_price + atrValue * atrMult * rr

shortStop = strategy.position_avg_price + atrValue * atrMult
shortTarget = strategy.position_avg_price - atrValue * atrMult * rr

strategy.exit("Exit Long", from_entry="Long", stop=longStop, limit=longTarget)
strategy.exit("Exit Short", from_entry="Short", stop=shortStop, limit=shortTarget)

// Visuals
plot(emaFast, color=color.orange, title="Fast EMA")
plot(emaSlow, color=color.blue, title="Slow EMA")
````
