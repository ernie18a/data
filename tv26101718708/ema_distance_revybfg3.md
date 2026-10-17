# EMA Distance

- url: https://www.tradingview.com/script/rEVybFG3-EMA-Distance/
- type: indicator
- pine_id: PUB;f251802d03f34623a03bfedb04acf489
- version: 1.0

## Description

[b]Introduction[/b]
EMA Distance is a simple trend analysis indicator that measures how far the current price is trading from an Exponential Moving Average (EMA).

While an EMA helps identify the prevailing market trend, it does not indicate whether price is trading close to its average value or has extended significantly away from it. EMA Distance addresses this by expressing the difference between price and the EMA as a percentage, providing a normalized view of price extension.

The indicator is displayed as a histogram centered around a zero line, making it easy to distinguish whether price is trading above or below the selected EMA.

[b]How It Works[/b]
The indicator first calculates an Exponential Moving Average using the selected EMA Length.
It then measures the percentage distance between the current closing price and the EMA using the following calculation:

EMA Distance = ((Close − EMA) / EMA) × Scale Factor

Positive values indicate that price is trading above the EMA.
Negative values indicate that price is trading below the EMA.
Larger positive or negative values indicate that price is moving further away from its average, while values closer to zero suggest that price is trading near the EMA.

[b]Key Features[/b]
[i]Percentage-Based Measurement[/i]
EMA Distance expresses the difference between price and the EMA as a percentage, making the indicator applicable across different markets and price levels.

[i]Quick Trend Bias[/i]
The zero line immediately shows whether price is trading above or below the selected EMA.

[i]Monitor Price Extension[/i]
Large positive or negative values may indicate that price has moved significantly away from its average and could be approaching a temporary overextended condition.

[i]Lightweight and Fast[/i]
The indicator uses a simple calculation that is suitable for all markets and timeframes.

[b]Interpretation[/b]
[i]Above Zero[/i]
Positive values indicate that price is trading above the EMA, suggesting bullish market conditions.

The larger the value, the further price has moved above its average.

[i]Below Zero[/i]
Negative values indicate that price is trading below the EMA, suggesting bearish market conditions.

Increasingly negative values reflect greater downside extension.

[i]Near Zero[/i]
Values close to zero indicate that price is trading near the EMA.
This often occurs during consolidations, pullbacks, or periods of reduced momentum.

[i]Expanding Distance[/i]
When the histogram continues moving away from zero, price is increasing its distance from the EMA.

This may reflect strengthening momentum but can also indicate that the market is becoming increasingly extended.

[i]Contracting Distance[/i]
When the histogram moves back toward zero, price is returning closer to its average.
This often occurs during pullbacks, consolidations, or weakening trends.

[b]Alert Conditions[/b]
The indicator includes two built-in alert conditions:
[i]Price Crossed Above EMA[/i]
- Triggered when the EMA Distance crosses above zero, indicating that price has moved above the selected EMA.

[i]Price Crossed Below EMA[/i]
- Triggered when the EMA Distance crosses below zero, indicating that price has moved below the selected EMA.

These alerts help traders monitor changes in market bias without continuously watching the chart.

[b]Example Applications[/b]
- Identifying bullish or bearish market bias.
- Measuring how far price has extended from the EMA.
- Monitoring pullbacks toward the moving average.
- Comparing trend extension across different markets and timeframes.
- Supporting trend-following strategies by observing price location relative to the EMA.

[b]Notes[/b]
EMA Distance is designed as a market context indicator rather than a standalone trading system.

A large distance from the EMA does not necessarily indicate an immediate reversal. Strong trends can remain extended for prolonged periods before retracing.

For best results, combine EMA Distance with price action, support and resistance, and other trend analysis techniques to better understand overall market conditions.

[i]EMA Distance provides a simple way to visualize how far price has moved from its average, helping traders evaluate trend extension, market bias, and potential pullback opportunities.[/i]

## Source Code

````pine
//@version=6
indicator("EMA Distance", shorttitle="EMA Dist", overlay=false)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
emaLength   = input.int(50, "EMA Length", minval=1)
scaleFactor = input.float(100.0, "Scale Factor", step=1)

//------------------------------------------------------------------------------
// Calculations
//------------------------------------------------------------------------------
emaValue = ta.ema(close, emaLength)

// Percentage distance between price and EMA
distance = ((close - emaValue) / emaValue) * scaleFactor

//------------------------------------------------------------------------------
// Color Logic
//------------------------------------------------------------------------------
distanceColor =
     distance > 2 ? color.lime :
     distance > 0 ? color.green :
     distance < -2 ? color.red :
     distance < 0 ? color.orange :
     color.gray

//------------------------------------------------------------------------------
// Plot
//------------------------------------------------------------------------------
plot(
     distance,
     title="EMA Distance",
     style=plot.style_columns,
     color=distanceColor,
     linewidth=2)

hline(0, "EMA", color=color.gray)

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(
     ta.crossover(distance, 0),
     title="Price Crossed Above EMA",
     message="Price has crossed above the EMA.")

alertcondition(
     ta.crossunder(distance, 0),
     title="Price Crossed Below EMA",
     message="Price has crossed below the EMA.")
````
