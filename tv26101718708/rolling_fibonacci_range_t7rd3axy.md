# Rolling Fibonacci Range

- url: https://www.tradingview.com/script/t7rD3AxY-Rolling-Fibonacci-Range/
- type: indicator
- pine_id: PUB;9113b5a8f19c47fea31d58a6e91824e7
- version: 1.0

## Description

Automatically plots rolling Fibonacci levels from the highest high and lowest low of the last N candles. Includes dynamic current-timeframe levels and static Daily Fibonacci levels for multi-timeframe support and resistance analysis. Suitable for intraday, swing, and positional trading across stocks, indices, forex, futures, and cryptocurrencies.

Rolling Fibonacci Range is a dynamic support and resistance indicator that automatically calculates Fibonacci levels from the highest high and lowest low of the last N candles. It helps traders identify important price zones without manually drawing Fibonacci retracements.

The indicator also includes a Multi-Timeframe Daily Fibonacci, allowing traders to monitor higher-timeframe levels while trading on lower timeframes.

Features

✅ Automatic Fibonacci calculation using the last N candles (default: 19)

✅ Dynamic levels that update with every new candle

✅ Static Daily Fibonacci that remains unchanged when switching between intraday timeframes

✅ Works on all markets:

Stocks
Indices
Futures
Forex
Crypto

✅ Supports all chart timeframes

Fibonacci Levels

The indicator calculates:

0.00 → Highest High
0.25
0.50
0.75
1.00 → Lowest Low

These levels act as potential:

Support
Resistance
Pullback zones
Breakout confirmation areas
Current Timeframe Levels

The purple levels represent the rolling Fibonacci range calculated using the current chart timeframe.

Example:

5-minute chart → Last 19 five-minute candles
15-minute chart → Last 19 fifteen-minute candles
1-hour chart → Last 19 one-hour candles

These levels continuously adapt to market structure.

Daily Fibonacci

The orange levels are calculated using the last 19 Daily candles.

Unlike the current timeframe levels, these remain constant while viewing:

1 Minute
3 Minute
5 Minute
15 Minute
30 Minute
1 Hour
4 Hour

The Daily Fibonacci updates only when a new daily candle is completed.

This helps intraday traders trade with higher-timeframe support and resistance.

How to Use
Bullish Market
Price holding above the 0.50 level suggests buyers remain in control.
A breakout above 0.25 often indicates bullish momentum.
A move above 0.00 (Highest High) may signal continuation.
Bearish Market
Price below 0.50 indicates weakness.
Rejection near 0.25 can provide short opportunities.
A break below 1.00 (Lowest Low) may confirm bearish continuation.
Best Use Cases

This indicator works well for:

Trend Following
Breakout Trading
Pullback Entries
Swing Trading
Intraday Trading
Support & Resistance Analysis
Multi-Timeframe Confluence
Recommended Settings

Default Lookback:

20 Candles

You can increase the lookback for smoother levels or decrease it for faster adaptation.

## Source Code

````pine
//@version=6
indicator("Rolling Fibonacci Range", overlay = true, max_lines_count = 100)

lookback = input.int(20, "Lookback", minval = 2)
extendBars = input.int(20, "Extend Right")

HH = ta.highest(high, lookback)
LL = ta.lowest(low, lookback)

priceRange  = HH - LL

L0   = HH
L25  = HH - priceRange  * 0.25
L50  = HH - priceRange  * 0.50
L75  = HH - priceRange  * 0.75
L100 = LL

left  = bar_index - lookback + 1
right = bar_index + extendBars

var line l0   = na
var line l25  = na
var line l50  = na
var line l75  = na
var line l100 = na

if barstate.islast
    line.delete(l0)
    line.delete(l25)
    line.delete(l50)
    line.delete(l75)
    line.delete(l100)

    l0   := line.new(left, L0, right, L0, color=color.purple, width=2)
    l25  := line.new(left, L25, right, L25, color=color.purple)
    l50  := line.new(left, L50, right, L50, color=color.purple)
    l75  := line.new(left, L75, right, L75, color=color.purple)
    l100 := line.new(left, L100, right, L100, color=color.purple, width=2)
````
