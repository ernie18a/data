# Normalized Coefficient of Variation

- url: https://www.tradingview.com/script/7N5bd8rz-Normalized-Coefficient-of-Variation/
- type: indicator
- pine_id: PUB;6489417d877b43b3be4000a5ee7522e1
- version: 1.0

## Description

# Normalized Coefficient of Variation (CV)

This indicator measures market volatility using the **Coefficient of Variation (CV)**, defined as the ratio of the standard deviation to the simple moving average (SMA), expressed as a percentage.

Unlike the traditional CV, which has no upper limit and can vary significantly across different assets and market conditions, this indicator applies a **Rolling Min-Max Normalization** over a user-defined lookback period. The result is a dynamic oscillator scaled between **0 and 100**, making it easier to compare relative volatility across different symbols and timeframes.

## Formula

**Coefficient of Variation**

CV = (Standard Deviation / SMA) × 100

**Normalization**

Normalized CV = 100 × (CV − Lowest CV) / (Highest CV − Lowest CV)

where the lowest and highest CV values are calculated over the selected normalization lookback period.

## Features

* Rolling Min-Max normalization (0-100 scale)
* User-selectable calculation timeframe
* Adjustable CV period (default: 24)
* Adjustable normalization lookback (default: 250)
* Uses Simple Moving Average (SMA)
* White oscillator line for clear visualization
* Dotted reference levels at 10 and 30
* Hidden raw CV value available in the Data Window

## Interpretation

* Values below **10** indicate relatively low volatility compared to recent history.
* Values above **30** indicate relatively high volatility compared to recent history.
* Values approaching **100** represent the highest relative volatility observed within the selected normalization window.
* Values approaching **0** represent the lowest relative volatility observed within the selected normalization window.

Because the indicator is normalized, the displayed values represent **relative volatility within the selected lookback period**, not the absolute Coefficient of Variation percentage. This makes the indicator especially useful for comparing changing volatility regimes across different markets and timeframes.

This indicator is intended as a volatility analysis tool and should be used alongside price action and other technical indicators rather than as a standalone trading signal.

## Source Code

````pine
//@version=6
indicator("Normalized Coefficient of Variation", shorttitle="CV-N", overlay=false)

//====================================================
// Inputs
//====================================================
timeframeInput = input.timeframe("", "Calculation Timeframe")
period = input.int(24, "CV Period", minval=2)
lookback = input.int(250, "Normalization Lookback", minval=50)
source = input.source(close, "Source")

//====================================================
// Source
//====================================================
price = timeframeInput == ""
     ? source
     : request.security(syminfo.tickerid, timeframeInput, source)

//====================================================
// Coefficient of Variation
//====================================================
meanValue = ta.sma(price, period)
stdDev = ta.stdev(price, period)

cv = meanValue != 0.0
     ? (stdDev / meanValue) * 100.0
     : na

//====================================================
// Rolling Min-Max Normalization
//====================================================
cvMin = ta.lowest(cv, lookback)
cvMax = ta.highest(cv, lookback)

cvRange = cvMax - cvMin

normalizedCV =
     bar_index >= (period + lookback - 1) and
     cvRange > 0
     ? 100.0 * (cv - cvMin) / cvRange
     : na

// Keep values inside 0-100
normalizedCV := math.max(0.0, math.min(100.0, normalizedCV))

//====================================================
// Plot
//====================================================
plot(
     normalizedCV,
     title="Normalized CV",
     color=color.white,
     linewidth=2
)

// Hidden actual CV for Data Window
plot(
     cv,
     title="Actual CV",
     display=display.none
)

//====================================================
// Reference Levels
//====================================================
hline(
     10,
     title="Low Volatility",
     color=color.green,
     linestyle=hline.style_dotted
)

hline(
     30,
     title="High Volatility",
     color=color.red,
     linestyle=hline.style_dotted
)
````
