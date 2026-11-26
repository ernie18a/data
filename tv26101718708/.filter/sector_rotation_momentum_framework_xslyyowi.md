# Sector Rotation Momentum Framework

- url: https://www.tradingview.com/script/xSLyyOwI-Sector-Rotation-Momentum-Framework/
- type: strategy
- pine_id: PUB;8ee07fc2871e4a5697279de9ca978175
- version: 1.0

## Description

[image]https://www.tradingview.com/x/B7oGWlcC/[/image]

[b]Overview[/b]
Markets rarely move with every sector advancing or declining at the same pace. At different stages of the market cycle, some sectors may strengthen while others lose momentum.

This framework compares the performance of a selected stock with a related sector ETF to provide additional context when evaluating trend direction. Rather than analyzing a stock in isolation, the script studies whether the stock is outperforming or underperforming its sector over time.

The objective is to demonstrate one approach to incorporating relative performance into a rules-based trading framework.

[b]Core Idea[/b]
A stock's price movement can be viewed alongside the broader sector it belongs to.
For example:
[list]
[*]NVIDIA compared with the Technology Select Sector SPDR Fund (XLK)
[*]JPMorgan Chase compared with the Financial Select Sector SPDR Fund (XLF)
[*]Exxon Mobil compared with the Energy Select Sector SPDR Fund (XLE)
[/list]
Comparing relative performance may provide additional context when studying trends.

[b]Strategy Logic[/b]

[b]Relative Performance[/b]
The framework calculates a ratio between the current chart and a selected benchmark ETF.
[list]
[*]When the ratio increases, the stock is outperforming the benchmark.
[*]When the ratio decreases, the stock is underperforming the benchmark.
[/list]

[b]Trend Confirmation[/b]
A moving average is used to identify the primary trend on the current chart.

[b]Relative Strength Filter[/b]
Trades are evaluated only when both:
[list]
[*]The trend direction aligns with the moving average.
[*]Relative performance remains above its smoothing average.
[/list]

[b]Risk Management[/b]
ATR-based stop-loss and target levels adjust according to market volatility.

[b]Features[/b]
[list]
[*]Relative performance comparison
[*]Sector benchmark analysis
[*]Trend confirmation
[*]ATR-based exits
[*]Configurable benchmark symbol
[/list]

[b]Intended Use[/b]
This framework is designed as an educational example of comparing a security with a sector benchmark. It can be used to study:
[list]
[*]Relative performance
[*]Trend alignment
[*]Sector participation
[*]Cross-market comparison
[/list]

[b]Disclaimer[/b]
This script is provided for educational and research purposes only. It demonstrates one approach to comparing a security with a benchmark using Pine Script. It does not predict future market behaviour and should be independently tested before being incorporated into any trading workflow.

## Source Code

````pine
//@version=6
strategy("Sector Rotation Momentum Framework", overlay=true,
     initial_capital=100000,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=5)

// Inputs
benchmark = input.symbol("AMEX:XLK", "Sector ETF")
fastLen = input.int(20, "Fast EMA")
slowLen = input.int(50, "Slow EMA")
rsLen = input.int(20, "Relative Strength EMA")
atrLen = input.int(14, "ATR Length")
atrMult = input.float(1.5, "ATR Stop Multiplier")
rr = input.float(2.0, "Risk Reward")

// Benchmark Price
benchmarkClose = request.security(
     benchmark,
     timeframe.period,
     close,
     lookahead=barmerge.lookahead_off)

// Relative Performance
relativeStrength = close / benchmarkClose
relativeMA = ta.ema(relativeStrength, rsLen)

// Trend
fastEMA = ta.ema(close, fastLen)
slowEMA = ta.ema(close, slowLen)

bullTrend = fastEMA > slowEMA
bearTrend = fastEMA < slowEMA

// Entry Conditions
longCondition =
     bullTrend and
     relativeStrength > relativeMA

shortCondition =
     bearTrend and
     relativeStrength < relativeMA

// Entries
if longCondition and strategy.position_size <= 0
    strategy.entry("Long", strategy.long)

if shortCondition and strategy.position_size >= 0
    strategy.entry("Short", strategy.short)

// ATR Risk Management
atr = ta.atr(atrLen)

longStop = strategy.position_avg_price - atr * atrMult
longTarget = strategy.position_avg_price + atr * atrMult * rr

shortStop = strategy.position_avg_price + atr * atrMult
shortTarget = strategy.position_avg_price - atr * atrMult * rr

strategy.exit("Exit Long", "Long",
     stop=longStop,
     limit=longTarget)

strategy.exit("Exit Short", "Short",
     stop=shortStop,
     limit=shortTarget)

// Visuals
plot(fastEMA, color=color.orange, title="Fast EMA")
plot(slowEMA, color=color.blue, title="Slow EMA")
plot(relativeMA * benchmarkClose, color=color.green, title="Relative Strength Trend")
````
