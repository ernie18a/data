# Gianluca ATR Volatility Regime [CCE_Charts]

- url: https://www.tradingview.com/script/GYG3M1lM-Gianluca-ATR-Volatility-Regime-CCE-Charts/
- type: indicator
- pine_id: PUB;1d3e07ef42b6478c9b0be2cd6670a3d1
- version: 2.0

## Description

[b]ATR Volatility Regime[/b]

This indicator classifies the current market volatility into four objective regimes using ATR Percentile.

The methodology uses the following calibration:

- [b]ATR Length[/b]: 14
- [b]Percentile Length[/b]: 200

The current ATR is compared against its historical values over the percentile lookback period. This converts the absolute ATR value into a relative volatility measure from 0 to 100.

[b]Volatility Regimes[/b]

| ATR Percentile | Regime |
|---|---|
| 0–25 | LOW |
| 26–50 | MEDIUM |
| 51–75 | HIGH |
| 76–100 | EXTREME |

The purpose of the indicator is to make volatility regimes objective and comparable across different market conditions. Instead of asking whether a particular ATR value is "high" or "low", the indicator shows where the current volatility stands relative to its recent historical distribution.

The 14 / 200 calibration follows the methodology presented by Gianluca in his trading framework and is intended as a volatility-regime classification rather than a standalone trading signal.

[b]Important[/b]: This indicator does not predict price direction or provide buy/sell signals. It identifies the current volatility environment, which can then be used to filter and evaluate a trading strategy.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CCE_Charts

//@version=6
indicator("Gianluca ATR Volatility Regime [CCE_Charts]", shorttitle="CCE - ATR Regime", overlay=false)

// Gianluca's calibration
atrLength = input.int(14, "ATR Length", minval=1)
percentileLength = input.int(200, "Percentile Length", minval=2)

// ATR
atr = ta.atr(atrLength)

// ATR percentile
atrPercentile = ta.percentrank(atr, percentileLength)

// Volatility regime
regime =
     atrPercentile <= 25 ? "LOW" :
     atrPercentile <= 50 ? "MEDIUM" :
     atrPercentile <= 75 ? "HIGH" :
     "EXTREME"

// Numeric regime
regimeValue =
     atrPercentile <= 25 ? 1 :
     atrPercentile <= 50 ? 2 :
     atrPercentile <= 75 ? 3 :
     4

// Percentile plot
plot(
     atrPercentile,
     title="ATR Percentile",
     linewidth=2
)

// Regime boundaries
hline(25, "LOW / MEDIUM", linestyle=hline.style_dashed)
hline(50, "MEDIUM / HIGH", linestyle=hline.style_dashed)
hline(75, "HIGH / EXTREME", linestyle=hline.style_dashed)

// Background
bgcolor(
     regimeValue == 1 ? color.new(color.blue, 90) :
     regimeValue == 2 ? color.new(color.green, 90) :
     regimeValue == 3 ? color.new(color.orange, 90) :
     color.new(color.red, 90)
)

// Current regime table
var table regimeTable = table.new(
     position.top_right,
     2,
     2
)

if barstate.islast
    table.cell(regimeTable, 0, 0, "ATR %ile")
    table.cell(regimeTable, 1, 0, str.tostring(atrPercentile, "#.0"))

    table.cell(regimeTable, 0, 1, "REGIME")
    table.cell(regimeTable, 1, 1, regime)

// Alert conditions
alertcondition(
     regimeValue == 1 and regimeValue[1] != 1,
     title="ATR Regime → LOW",
     message="ATR Volatility Regime changed to LOW"
)

alertcondition(
     regimeValue == 2 and regimeValue[1] != 2,
     title="ATR Regime → MEDIUM",
     message="ATR Volatility Regime changed to MEDIUM"
)

alertcondition(
     regimeValue == 3 and regimeValue[1] != 3,
     title="ATR Regime → HIGH",
     message="ATR Volatility Regime changed to HIGH"
)

alertcondition(
     regimeValue == 4 and regimeValue[1] != 4,
     title="ATR Regime → EXTREME",
     message="ATR Volatility Regime changed to EXTREME"
)
````
