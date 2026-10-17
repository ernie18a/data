# Fair Value Gap Continuation Framework

- url: https://www.tradingview.com/script/4uYwBCmZ-Fair-Value-Gap-Continuation-Framework/
- type: strategy
- pine_id: PUB;9fb21a1667bb4d898f50256bb0e14122
- version: 1.0

## Description

[b]Overview[/b]
This strategy studies how price interacts with Fair Value Gaps (FVGs), which are areas that can form after strong directional price movement.

The script identifies potential imbalance zones and monitors future price interaction with those areas. Rather than entering immediately after a gap forms, the strategy waits for price to revisit the zone and show signs of continuing in the original direction.

The objective is to explore how imbalance zones may be incorporated into a rules-based trading framework.

[b]What Is a Fair Value Gap?[/b]

A Fair Value Gap is commonly described as an area created when price moves rapidly, leaving a gap between portions of surrounding candles.

In this script:
[list]
[*]Bullish gaps are identified after upward displacement.
[*]Bearish gaps are identified after downward displacement.
[/list]
Previously identified zones remain available for future analysis when price revisits them.

[b]Strategy Logic[/b]
[i]Gap Identification[/i]
The script searches for simple three-candle imbalance patterns that may indicate a Fair Value Gap.
[i]Zone Retest[/i]
Once a gap has been identified, the strategy waits for price to return to that area.
[i]Continuation Confirmation[/i]
A trade is considered only after price revisits the zone and closes back in the direction of the original move.
[i]Risk Management[/i]
Stop-loss and target levels are calculated using ATR, allowing risk parameters to adapt to changing volatility conditions.
[b]Features[/b]
[list]
[*]Fair Value Gap detection
[*]Retest-based entries
[*]ATR-based risk management
[*]Trend continuation framework
[*]Research and testing focused design
[/list]
[i]Intended Use[/i]
This script is designed as an educational example demonstrating one approach to identifying and testing Fair Value Gap behavior.
It may be used to study:
[list]
[*]Price imbalances
[*]Retest behavior
[*]Trend continuation concepts
[*]Volatility-adjusted exits
[/list]
Users may choose to modify parameters and test the script across different symbols and timeframes.

[b]Notes[/b]
Fair Value Gap concepts are interpreted differently by different traders. This script provides one simplified implementation and should not be considered a complete representation of all Fair Value Gap methodologies.

[b]Disclaimer[/b]
This script is provided for educational and research purposes only. It demonstrates one method of identifying and testing Fair Value Gap behavior using Pine Script. The script does not predict future market direction and should be evaluated through independent testing before being incorporated into any trading process.

## Source Code

````pine
//@version=6
strategy("Fair Value Gap Continuation Framework", overlay=true, initial_capital=100000)

// Inputs
atrLen   = input.int(14, "ATR Length")
atrMult  = input.float(1.5, "Stop ATR Multiplier")
rr       = input.float(2.0, "Risk Reward")
trendLen = input.int(50, "Trend EMA Length")

// Trend Filter
emaTrend = ta.ema(close, trendLen)

// ATR
atrValue = ta.atr(atrLen)

// Fair Value Gap Detection
bullFVG = low > high[2]
bearFVG = high < low[2]

// Store Latest FVG Zones
var float bullTop = na
var float bullBottom = na

var float bearTop = na
var float bearBottom = na

if bullFVG
    bullTop := low
    bullBottom := high[2]

if bearFVG
    bearTop := low[2]
    bearBottom := high

// Retest Logic
bullRetest = not na(bullTop) and low <= bullTop and close > bullTop
bearRetest = not na(bearBottom) and high >= bearBottom and close < bearBottom

// Trend Confirmation
longCondition = bullRetest and close > emaTrend
shortCondition = bearRetest and close < emaTrend

// Entries
if longCondition and strategy.position_size <= 0
    strategy.entry("Long", strategy.long)

if shortCondition and strategy.position_size >= 0
    strategy.entry("Short", strategy.short)

// Risk Management
longStop   = strategy.position_avg_price - atrValue * atrMult
longTarget = strategy.position_avg_price + atrValue * atrMult * rr

shortStop   = strategy.position_avg_price + atrValue * atrMult
shortTarget = strategy.position_avg_price - atrValue * atrMult * rr

strategy.exit("Exit Long", from_entry="Long", stop=longStop, limit=longTarget)
strategy.exit("Exit Short", from_entry="Short", stop=shortStop, limit=shortTarget)

// Visuals
plot(emaTrend, title="Trend EMA", color=color.orange)

plot(bullTop, title="Bullish FVG", color=color.green, linewidth=2)
plot(bearBottom, title="Bearish FVG", color=color.red, linewidth=2)
````
