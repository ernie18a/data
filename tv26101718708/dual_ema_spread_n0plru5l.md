# Dual EMA Spread

- url: https://www.tradingview.com/script/N0plRU5l-Dual-EMA-Spread/
- type: indicator
- pine_id: PUB;00340baf05464318b6bec1bf2cfa0b02
- version: 1.0

## Description

[b]Introduction[/b]
Dual EMA Spread is a trend analysis indicator that measures the percentage difference between a fast Exponential Moving Average (EMA) and a slow Exponential Moving Average.

While moving average crossovers are commonly used to identify potential trend changes, they do not reveal how far apart the two averages are. Dual EMA Spread addresses this by quantifying the separation between the fast and slow EMAs, helping traders evaluate whether trend momentum is strengthening, weakening, or transitioning.

The indicator is displayed as a histogram centered around a zero line, providing a simple visual representation of the relationship between the two moving averages.

[b]How It Works[/b]
The indicator calculates two Exponential Moving Averages using user-defined periods.
It then measures the percentage difference between the fast EMA and the slow EMA using the following formula:

Dual EMA Spread = ((Fast EMA − Slow EMA) / Slow EMA) × Scale Factor

Positive values indicate that the fast EMA is trading above the slow EMA.
Negative values indicate that the fast EMA is trading below the slow EMA.
As the spread widens, the indicator suggests that the distance between the two averages is increasing, reflecting stronger directional momentum.

[b]Key Features[/b]
[i]Percentage-Based Spread[/i]
The difference between the two EMAs is expressed as a percentage rather than an absolute price value, making the indicator more consistent across instruments with different price ranges.

[i]Trend Bias at a Glance[/i]
The zero line clearly shows whether the fast EMA is positioned above or below the slow EMA, providing an immediate view of the prevailing market bias.

[i]Trend Strength Visualization[/i]
Changes in the histogram help visualize whether the separation between the two moving averages is expanding or contracting.

[i]Lightweight and Efficient[/i]
The indicator performs a straightforward calculation, making it suitable for all markets and timeframes without adding unnecessary complexity.

[b]Interpretation[/b]
[i]Above Zero[/i]
Positive values indicate that the fast EMA is above the slow EMA, suggesting bullish market conditions.

An expanding positive histogram often reflects increasing bullish momentum.

[i]Below Zero[/i]
Negative values indicate that the fast EMA is below the slow EMA, suggesting bearish market conditions.

An expanding negative histogram indicates strengthening bearish momentum.

[i]Near Zero[/i]
Values close to zero indicate that the two EMAs are converging.

This frequently occurs during consolidation, trend transitions, or periods of reduced momentum.

[i]Expanding Spread[/i]
When the histogram moves further away from zero, the distance between the fast and slow EMAs is increasing.

This generally reflects strengthening trend momentum.

[i]Contracting Spread[/i]
When the histogram moves back toward zero, the two EMAs are converging.
This often indicates slowing momentum or the early stages of market consolidation.

[b]Alert Conditions[/b]
The indicator includes two built-in alert conditions:
[i]Bullish EMA Spread[/i]
- Triggered when the fast EMA crosses above the slow EMA, causing the spread to cross above zero.

[i]Bearish EMA Spread[/i]
- Triggered when the fast EMA crosses below the slow EMA, causing the spread to cross below zero.

These alerts help traders monitor potential changes in market direction without continuously watching the chart.

[b]Example Applications[/b]
- Identifying bullish and bearish market bias.
- Confirming moving average crossovers.
- Measuring trend strength through EMA separation.
- Monitoring momentum expansion and contraction.
- Comparing trend conditions across multiple instruments and timeframes.

[b]Notes[/b]
Dual EMA Spread is designed as a trend analysis tool rather than a standalone trading system.
Although an expanding spread often reflects strengthening momentum, it should not be interpreted as a guarantee that the trend will continue. Likewise, a contracting spread does not necessarily indicate an immediate reversal.

For best results, use Dual EMA Spread together with price action, market structure, and support and resistance analysis to build a more complete understanding of market conditions.

[i]Dual EMA Spread provides a simple and intuitive way to measure the relationship between fast and slow moving averages, helping traders visualize trend strength, momentum expansion, and potential market transitions.[/i]

## Source Code

````pine
//@version=6
indicator("Dual EMA Spread", shorttitle="EMA Spread", overlay=false)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
fastLength  = input.int(20, "Fast EMA", minval=1)
slowLength  = input.int(50, "Slow EMA", minval=1)
scaleFactor = input.float(100.0, "Scale Factor", step=1)

//------------------------------------------------------------------------------
// Calculations
//------------------------------------------------------------------------------
fastEMA = ta.ema(close, fastLength)
slowEMA = ta.ema(close, slowLength)

// Percentage spread
spread = ((fastEMA - slowEMA) / slowEMA) * scaleFactor

//------------------------------------------------------------------------------
// Color Logic
//------------------------------------------------------------------------------
spreadColor =
     spread > 1 ? color.lime :
     spread > 0 ? color.green :
     spread < -1 ? color.red :
     spread < 0 ? color.orange :
     color.gray

//------------------------------------------------------------------------------
// Plot
//------------------------------------------------------------------------------
plot(
     spread,
     title="EMA Spread",
     style=plot.style_columns,
     color=spreadColor,
     linewidth=2)

hline(0, "Zero", color=color.gray)

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(
     ta.crossover(spread, 0),
     title="Bullish EMA Spread",
     message="Fast EMA crossed above Slow EMA.")

alertcondition(
     ta.crossunder(spread, 0),
     title="Bearish EMA Spread",
     message="Fast EMA crossed below Slow EMA.")
````
