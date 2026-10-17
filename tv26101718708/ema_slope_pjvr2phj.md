# EMA Slope

- url: https://www.tradingview.com/script/pjVR2pHj-EMA-Slope/
- type: indicator
- pine_id: PUB;5dbed065183b49648b4bb309ab2a1ead
- version: 1.0

## Description

[b]Introduction[/b]
EMA Slope is a simple trend momentum indicator designed to measure how quickly an Exponential Moving Average (EMA) is rising or falling over a selected lookback period.

While moving averages are commonly used to identify trend direction, they often provide limited insight into the speed of trend development. EMA Slope addresses this by calculating the percentage change of an EMA over time, helping traders evaluate whether a trend is strengthening, weakening, or moving sideways.

The indicator is displayed as a histogram centered around a zero line, making it easy to identify bullish and bearish momentum shifts.

[b]How It Works[/b]
The indicator first calculates an Exponential Moving Average using the selected EMA Length.
It then measures the percentage change between the current EMA value and the EMA value from a specified number of bars ago:

EMA Slope = ((Current EMA - Previous EMA) / Previous EMA) × Scale Factor

Positive values indicate that the EMA is rising.

Negative values indicate that the EMA is falling.

Larger positive or negative values indicate a steeper slope and stronger directional momentum.

[b]Key Features[/b]

[i]Percentage-Based Measurement[/i]
Unlike raw EMA differences, the slope is expressed as a percentage change. This helps normalize values across instruments with different price ranges.

[i]Easy Trend Assessment[/i]
The histogram quickly reveals whether trend momentum is accelerating, decelerating, or remaining stable.

[i]Early Momentum Shifts[/i]
Crosses above and below the zero line can help identify potential changes in market direction before they become obvious on price charts.

[i]Lightweight and Fast[/i]
The indicator uses a straightforward calculation and is suitable for all timeframes and instruments.

[b]Interpretation[/b]
[i]Above Zero[/i]
When EMA Slope is above zero, the EMA is rising and trend momentum is bullish.
Higher positive values suggest stronger upward momentum.

[i]Below Zero[/i]
When EMA Slope is below zero, the EMA is falling and trend momentum is bearish.
Lower negative values suggest stronger downward momentum.

[i]Near Zero[/i]
Values near zero indicate a flat EMA and a market that may be consolidating or lacking directional conviction.

[i]Slope Expansion[/i]
Increasing histogram values indicate strengthening trend momentum.

[i]Slope Contraction[/i]
Decreasing histogram values indicate weakening trend momentum and potential trend exhaustion.

[b]Alert Conditions[/b]
The indicator includes two built-in alert conditions:
[i]Bullish Slope[/i]
	•	Triggered when EMA Slope crosses above zero.
[i]Bearish Slope[/i]
	•	Triggered when EMA Slope crosses below zero.
These alerts can help traders monitor changes in directional momentum without continuously watching charts.

[b]Example Applications[/b]
	•	Confirming trend direction.
	•	Identifying strengthening momentum.
	•	Monitoring trend slowdowns.
	•	Filtering trades in the direction of the prevailing trend.
	•	Comparing trend conditions across multiple instruments.

[b]Notes[/b]
EMA Slope is designed as a trend analysis tool rather than a complete trading system.
Like all trend-following indicators, it may produce delayed signals during sharp reversals and can generate whipsaws in highly ranging markets.

For best results, consider combining EMA Slope with price action analysis, support and resistance levels, or additional market context.

[i]EMA Slope helps traders move beyond simple trend direction by quantifying the speed of trend development, providing a clearer view of market momentum and trend quality.[/i]

## Source Code

````pine
//@version=6
indicator("EMA Slope", shorttitle="EMA Slope", overlay=false)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
emaLength   = input.int(50, "EMA Length", minval=1)
lookback    = input.int(5, "Slope Lookback", minval=1)
scaleFactor = input.float(100.0, "Scale Factor", step=10)

//------------------------------------------------------------------------------
// Calculation
//------------------------------------------------------------------------------
emaValue = ta.ema(close, emaLength)

// Percentage slope over the selected lookback
slope = ((emaValue - emaValue[lookback]) / emaValue[lookback]) * scaleFactor

//------------------------------------------------------------------------------
// Color
//------------------------------------------------------------------------------
slopeColor =
     slope > 2 ? color.lime :
     slope > 0 ? color.green :
     slope < -2 ? color.red :
     slope < 0 ? color.orange :
     color.gray

//------------------------------------------------------------------------------
// Plot
//------------------------------------------------------------------------------
plot(slope,
     title="EMA Slope",
     style=plot.style_columns,
     color=slopeColor)

hline(0, "Zero", color=color.gray)

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(ta.crossover(slope, 0),
     title="Bullish Slope",
     message="EMA Slope crossed above zero.")

alertcondition(ta.crossunder(slope, 0),
     title="Bearish Slope",
     message="EMA Slope crossed below zero.")
````
