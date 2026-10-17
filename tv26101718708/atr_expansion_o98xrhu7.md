# ATR Expansion

- url: https://www.tradingview.com/script/o98xrhu7-ATR-Expansion/
- type: indicator
- pine_id: PUB;a341177fac6f4e5881cd598415c18e21
- version: 1.0

## Description

[b]Introduction[/b]
ATR Expansion is a volatility analysis indicator that measures whether the current Average True Range (ATR) is expanding or contracting relative to its recent historical average.

Rather than displaying ATR alone, the indicator compares the current ATR with a longer-term baseline, helping traders identify periods of increasing or decreasing market volatility.
The result is presented as a zero-centered histogram, making changes in volatility easy to recognize.

[b]How It Works[/b]
The indicator first calculates the Average True Range (ATR) using the selected ATR Length.
It then calculates a Simple Moving Average of the ATR to establish a volatility baseline.

The calculation is:
ATR Expansion = ((Current ATR − ATR Baseline) ÷ ATR Baseline) × 100

Positive values indicate current volatility is above its recent average.
Negative values indicate volatility is below its recent average.

[b]Key Features[/b]
[i]Volatility Monitoring[/i]
Instantly shows whether market volatility is expanding or contracting.

[i]Relative Measurement[/i]
Instead of relying on raw ATR values, the indicator compares ATR against its own historical average.

[i]Zero-Centered Histogram[/i]
The zero line clearly separates above-average volatility from below-average volatility.

[i]Lightweight Design[/i]
Only requires standard ATR and SMA calculations, making it efficient for every market and timeframe.

[b]Interpretation[/b]
[i]Above Zero[/i]
Current ATR is higher than its historical average.
This indicates increasing market volatility.

[i]Below Zero[/i]
Current ATR is lower than its historical average.
This suggests quieter market conditions.

[i]Expanding Histogram[/i]
A rising histogram indicates volatility is accelerating.
Large directional price moves often occur during these periods.

[i]Contracting Histogram[/i]
A falling histogram indicates volatility is decreasing.
Markets may be entering consolidation or reduced trading activity.

[b]Alert Conditions[/b]
The indicator includes two built-in alerts.
[i]ATR Expansion Increasing[/i]
Triggered when ATR moves above its historical average.

[i]ATR Expansion Decreasing[/i]
Triggered when ATR falls below its historical average.

[b]Example Applications[/b]
- Identifying volatility expansion.
- Detecting volatility contraction.
- Confirming breakout conditions.
- Monitoring changing market activity.
- Comparing volatility across multiple markets.

[b]Notes[/b]
ATR Expansion measures volatility only.

It does not indicate whether the market is bullish or bearish.

High volatility can occur during both strong rallies and sharp declines.

For best results, combine ATR Expansion with trend analysis and price action to determine both direction and market activity.

ATR Expansion provides a simple way to monitor changing market volatility by comparing today's ATR with its recent historical average, helping traders recognize when markets become more active or more quiet.

## Source Code

````pine
//@version=6
indicator("ATR Expansion", shorttitle="ATR Expansion", overlay=false)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
atrLength      = input.int(14, "ATR Length", minval=1)
baselineLength = input.int(50, "Baseline Length", minval=2)

//------------------------------------------------------------------------------
// Calculations
//------------------------------------------------------------------------------
atrValue = ta.atr(atrLength)
atrMA    = ta.sma(atrValue, baselineLength)

// ATR Expansion (%)
expansion = ((atrValue - atrMA) / atrMA) * 100

//------------------------------------------------------------------------------
// Colors
//------------------------------------------------------------------------------
expansionColor =
     expansion >= 20 ? color.lime :
     expansion >= 0  ? color.green :
     expansion >= -20 ? color.orange :
     color.red

//------------------------------------------------------------------------------
// Plot
//------------------------------------------------------------------------------
plot(
     expansion,
     title="ATR Expansion",
     style=plot.style_columns,
     linewidth=2,
     color=expansionColor)

hline(0, "Baseline", color=color.gray)

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(
     ta.crossover(expansion, 0),
     title="ATR Expansion Increasing",
     message="Current ATR has moved above its baseline.")

alertcondition(
     ta.crossunder(expansion, 0),
     title="ATR Expansion Decreasing",
     message="Current ATR has moved below its baseline.")
````
