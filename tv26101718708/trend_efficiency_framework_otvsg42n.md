# Trend Efficiency Framework

- url: https://www.tradingview.com/script/oTVSg42n-Trend-Efficiency-Framework/
- type: strategy
- pine_id: PUB;495d82fe3b3c4940b710a12159be0007
- version: 1.0

## Description

[b]Overview[/b]
Not every trend develops with the same characteristics. Some trends move steadily with limited pullbacks, while others experience frequent reversals and uneven price movement.

This framework studies trend efficiency, which describes how directly price moves from one point to another over a selected period. Instead of measuring only trend direction, it evaluates how consistently that movement develops.

The objective is to provide an additional perspective on trend behaviour that can be used alongside other forms of technical analysis.

[b]Core Idea[/b]
[list]
[*]The framework compares the market's overall progress with the total distance travelled by price.
[*]A trend is considered more efficient when price moves consistently in one direction with relatively small pullbacks.
[*]A trend is considered less efficient when price frequently changes direction, creating larger swings without making significant overall progress.
[/list]

[b]Strategy Logic[/b]
[list]
[*]Net Movement
[/list]
The framework measures the overall price change across a selected lookback period.
[list]
[*]Total Movement
[/list]
The total movement is calculated by summing the absolute price changes from one bar to the next.
[list]
[*]Efficiency Score
[/list]
The efficiency score is calculated as:
[b]Net Price Movement ÷ Total Price Movement[/b]
[list]
[*]Higher values indicate that price has moved more directly.
[*]Lower values indicate that price has travelled a greater distance while making less overall progress.
[/list]

[b]Trend Filter[/b]
Moving averages are used to define the primary market direction.
Long opportunities are evaluated when:
[list]
[*]The trend is upward.
[*]The efficiency score exceeds the selected threshold.
[/list]
Short opportunities are evaluated when:
[list]
[*]The trend is downward.
[*]The efficiency score exceeds the selected threshold.
[/list]

[b]Risk Management[/b]
ATR-based stop-loss and target levels are used to adapt risk parameters to changing market volatility.

[b]Features[/b]
[list]
[*]Trend efficiency measurement
[*]Directional trend confirmation
[*]Volatility-adjusted exits
[*]Configurable efficiency threshold
[*]Research-oriented framework
[/list]

[b]Intended Use[/b]
This framework is designed to study how efficiently trends develop over time.
It may be used to compare different markets, symbols, and timeframes while exploring the relationship between trend quality and price movement.

[b]Disclaimer[/b]
This script is provided for educational and research purposes only. It demonstrates one approach to measuring trend efficiency using Pine Script. It does not predict future market behaviour and should be independently tested before being incorporated into any trading workflow.

## Source Code

````pine
//@version=6
strategy("Trend Efficiency Framework", overlay=true, initial_capital=100000, default_qty_type=strategy.percent_of_equity, default_qty_value=5)

// ───── Inputs ─────
fastLen = input.int(20, "Fast EMA")
slowLen = input.int(50, "Slow EMA")
lookback = input.int(20, "Efficiency Lookback")
effThreshold = input.float(0.55, "Efficiency Threshold", step=0.05)

atrLen = input.int(14, "ATR Length")
atrMult = input.float(1.5, "ATR Stop Multiplier")
rr = input.float(2.0, "Risk Reward")

// ───── Trend ─────
fastEMA = ta.ema(close, fastLen)
slowEMA = ta.ema(close, slowLen)

bullTrend = fastEMA > slowEMA
bearTrend = fastEMA < slowEMA

// ───── Trend Efficiency ─────
netMove = math.abs(close - close[lookback])

float totalMove = 0.0

for i = 0 to lookback - 1
    totalMove += math.abs(close[i] - close[i + 1])

efficiency = totalMove != 0 ? netMove / totalMove : 0.0

// ───── Entry Conditions ─────
longCondition = bullTrend and efficiency > effThreshold
shortCondition = bearTrend and efficiency > effThreshold

if longCondition and strategy.position_size <= 0
    strategy.entry("Long", strategy.long)

if shortCondition and strategy.position_size >= 0
    strategy.entry("Short", strategy.short)

// ───── Risk Management ─────
atrValue = ta.atr(atrLen)

longStop = strategy.position_avg_price - atrValue * atrMult
longTarget = strategy.position_avg_price + atrValue * atrMult * rr

shortStop = strategy.position_avg_price + atrValue * atrMult
shortTarget = strategy.position_avg_price - atrValue * atrMult * rr

strategy.exit("Exit Long", from_entry="Long", stop=longStop, limit=longTarget)
strategy.exit("Exit Short", from_entry="Short", stop=shortStop, limit=shortTarget)

// ───── Visuals ─────
plot(fastEMA, color=color.orange, title="Fast EMA")
plot(slowEMA, color=color.blue, title="Slow EMA")
plot(efficiency, title="Trend Efficiency", color=color.green, display=display.pane)
````
