# RSI Extreme Divergence

- url: https://www.tradingview.com/script/vNt1KGi7/
- type: indicator
- pine_id: PUB;c5cc4805ddb342aca90838ebd9f3b7d6
- version: 2.0

## Description

# RSI Extreme Divergence

An RSI divergence indicator designed to highlight only high-probability reversal signals.

Unlike standard divergence indicators, this script only detects divergences when the RSI reaches extreme conditions, helping filter out weaker signals during normal market fluctuations.

## Features

* Displays **RSI** with customizable length.
* Highlights **Overbought** and **Oversold** zones.
* Detects **Bullish Divergence** only when RSI is below the Oversold level.
* Detects **Bearish Divergence** only when RSI is above the Overbought level.
* Draws divergence lines directly on the RSI.
* Displays buy and sell arrows on both the RSI panel and the price chart.
* Includes alert support for bullish and bearish divergence signals.

## Why use this indicator?

Many divergence indicators generate too many signals during ranging markets.

This indicator focuses only on divergences that occur in extreme RSI conditions (default: above 70 or below 30), helping traders concentrate on higher-quality reversal opportunities.

## Default Settings

* RSI Length: **9**
* Pivot Length: **5**
* Overbought: **70**
* Oversold: **30**

These settings are optimized for swing trading but can be adjusted to suit different markets and trading styles.

## Source Code

````pine
//@version=6
indicator("RSI Extreme Divergence", overlay=false, max_lines_count=100)

// ===== Inputs =====
rsiLength = input.int(9, "RSI Length")
pivotLen  = input.int(5, "Pivot Length")

overBought = input.float(65.0, "Overbought")
overSold   = input.float(35.0, "Oversold")

showPriceSignals = input.bool(true, "Show signals on price chart")
showRsiLines     = input.bool(true, "Show divergence lines on RSI")

// ===== RSI =====
rsi = ta.rsi(close, rsiLength)

// ===== RSI Plot =====
plot(rsi, title="RSI", color=color.white, linewidth=2)

hline(overBought, "Overbought", color=color.red)
hline(50, "Middle", color=color.gray)
hline(overSold, "Oversold", color=color.green)

bgcolor(rsi >= overBought ? color.new(color.red, 90) :
     rsi <= overSold ? color.new(color.green, 90) :
     na)

// ===== Pivot =====
rsiLowPivot  = ta.pivotlow(rsi, pivotLen, pivotLen)
rsiHighPivot = ta.pivothigh(rsi, pivotLen, pivotLen)

// ===== Previous pivot values =====
var float prevPriceLow = na
var float prevRsiLow   = na
var int   prevLowBar   = na

var float prevPriceHigh = na
var float prevRsiHigh   = na
var int   prevHighBar   = na

bullDiv = false
bearDiv = false

// ===== Bullish Divergence =====
// Price: lower low
// RSI: higher low
// RSI is in oversold zone
if not na(rsiLowPivot)
    currPriceLow = low[pivotLen]
    currRsiLow   = rsiLowPivot
    currLowBar   = bar_index - pivotLen

    bullDiv :=
         not na(prevPriceLow) and
         not na(prevRsiLow) and
         currPriceLow < prevPriceLow and
         currRsiLow > prevRsiLow and
         currRsiLow <= overSold

    if bullDiv and showRsiLines
        line.new(
             prevLowBar,
             prevRsiLow,
             currLowBar,
             currRsiLow,
             color=color.lime,
             width=2
        )

    prevPriceLow := currPriceLow
    prevRsiLow   := currRsiLow
    prevLowBar   := currLowBar

// ===== Bearish Divergence =====
// Price: higher high
// RSI: lower high
// RSI is in overbought zone
if not na(rsiHighPivot)
    currPriceHigh = high[pivotLen]
    currRsiHigh   = rsiHighPivot
    currHighBar   = bar_index - pivotLen

    bearDiv :=
         not na(prevPriceHigh) and
         not na(prevRsiHigh) and
         currPriceHigh > prevPriceHigh and
         currRsiHigh < prevRsiHigh and
         currRsiHigh >= overBought

    if bearDiv and showRsiLines
        line.new(
             prevHighBar,
             prevRsiHigh,
             currHighBar,
             currRsiHigh,
             color=color.red,
             width=2
        )

    prevPriceHigh := currPriceHigh
    prevRsiHigh   := currRsiHigh
    prevHighBar   := currHighBar

// ===== RSI pane signals =====
plotshape(
     bullDiv ? rsiLowPivot : na,
     title="Bullish Divergence",
     style=shape.triangleup,
     location=location.absolute,
     color=color.lime,
     size=size.small,
     offset=-pivotLen
)

plotshape(
     bearDiv ? rsiHighPivot : na,
     title="Bearish Divergence",
     style=shape.triangledown,
     location=location.absolute,
     color=color.red,
     size=size.small,
     offset=-pivotLen
)

// ===== Price chart signals =====
plotshape(
     showPriceSignals and bullDiv,
     title="Bullish Divergence on Price",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.small,
     offset=-pivotLen,
     force_overlay=true
)

plotshape(
     showPriceSignals and bearDiv,
     title="Bearish Divergence on Price",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.small,
     offset=-pivotLen,
     force_overlay=true
)

// ===== Alert =====
divSignal = bullDiv or bearDiv

alertcondition(
     divSignal,
     title="RSI Extreme Divergence",
     message="RSI divergence detected in overbought/oversold zone."
)
````
