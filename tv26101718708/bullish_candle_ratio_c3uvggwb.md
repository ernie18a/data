# Bullish Candle Ratio

- url: https://www.tradingview.com/script/c3uvGGwb-Bullish-Candle-Ratio/
- type: indicator
- pine_id: PUB;d00f9d0bd17447b5a7bfba6cb69187f1
- version: 1.0

## Description

[b]Introduction[/b]
Bullish Candle Ratio is a market statistics indicator that measures the percentage of bullish candles within a selected lookback period.

Instead of focusing on price levels or moving averages, the indicator evaluates the balance between bullish and bearish candles. This provides a simple overview of market participation and directional dominance over recent bars.

The result is displayed as a percentage between 0% and 100%, making it easy to assess whether buyers or sellers have been more active during the selected period.

[b]How It Works[/b]
The indicator counts how many candles closed above their opening price during the selected lookback period.

The Bullish Candle Ratio is calculated as:
Bullish Candle Ratio = (Number of Bullish Candles ÷ Lookback Period) × 100

For example, if 15 out of the last 20 candles are bullish, the Bullish Candle Ratio equals 75%.

[b]Key Features[/b]
[i]Market Participation[/i]
Quickly measures whether buyers or sellers have dominated recent price action.

[i]Easy to Read[/i]
Values range from 0% to 100%, making interpretation straightforward.

[i]Trend Confirmation[/i]
High readings often support bullish market conditions, while low readings indicate bearish dominance.

[i]Lightweight[/i]
Requires only basic candle calculations, making it suitable for all markets and timeframes.

[b]Interpretation[/b]
[i]Above 80%[/i]
Strong bullish dominance.
Most recent candles have closed higher than they opened.

[i]Between 60% and 80%[/i]
Moderately bullish conditions.
Buyers are controlling the majority of recent price action.

[i]Around 50%[/i]
Balanced market.
Neither buyers nor sellers have established clear dominance.

[i]Between 20% and 40%[/i]
Moderately bearish conditions.
Selling pressure has become more noticeable.

[i]Below 20%[/i]
Strong bearish dominance.
Most recent candles have closed lower than they opened.

[b]Alert Conditions[/b]
The indicator includes two alert conditions.

[i]Bullish Ratio Increasing[/i]
Triggered when the Bullish Candle Ratio crosses above 60%.

[i]Bearish Ratio Increasing[/i]
Triggered when the Bullish Candle Ratio crosses below 40%.

[b]Example Applications[/b]
- Measuring short-term market sentiment.
- Confirming trend strength.
- Monitoring shifts in buying and selling pressure.
- Comparing bullish participation across different markets.
- Supporting price action analysis.

[b]Notes[/b]
Bullish Candle Ratio is intended to measure market participation rather than generate trading signals.

A high bullish ratio does not guarantee that prices will continue rising, just as a low ratio does not guarantee further declines.

The indicator is most effective when combined with trend analysis, support and resistance, and overall market structure.

[i]Bullish Candle Ratio provides a simple statistical view of recent market sentiment by measuring the balance between bullish and bearish candles within a selected period.[/i]

## Source Code

````pine
//@version=6
indicator("Bullish Candle Ratio", shorttitle="Bull Ratio", overlay=false)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
lookback = input.int(20, "Lookback Period", minval=2)

//------------------------------------------------------------------------------
// Calculations
//------------------------------------------------------------------------------
bullishBars = math.sum(close > open ? 1 : 0, lookback)
bullRatio = (bullishBars / lookback) * 100

//------------------------------------------------------------------------------
// Colors
//------------------------------------------------------------------------------
ratioColor =
     bullRatio >= 80 ? color.lime :
     bullRatio >= 60 ? color.green :
     bullRatio >= 40 ? color.gray :
     bullRatio >= 20 ? color.orange :
     color.red

//------------------------------------------------------------------------------
// Plot
//------------------------------------------------------------------------------
plot(
     bullRatio,
     title="Bullish Candle Ratio",
     color=ratioColor,
     linewidth=2)

hline(80, "Strong Bullish", color=color.new(color.green, 70))
hline(60, "Bullish", color=color.new(color.green, 85))
hline(50, "Neutral", color=color.gray)
hline(40, "Bearish", color=color.new(color.red, 85))
hline(20, "Strong Bearish", color=color.new(color.red, 70))

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(
     ta.crossover(bullRatio, 60),
     title="Bullish Ratio Increasing",
     message="Bullish Candle Ratio crossed above 60%.")

alertcondition(
     ta.crossunder(bullRatio, 40),
     title="Bearish Ratio Increasing",
     message="Bullish Candle Ratio crossed below 40%.")
````
