# Wick to Close Distance (Pips)

- url: https://www.tradingview.com/script/13gJPimb-Wick-to-Close-Distance-Pips/
- type: indicator
- pine_id: PUB;3b99b13b90674427ac216afac3e93c0d
- version: 1.0

## Description

This indicator measures the distance between the candle wicks and the closing price.

For every candle:

* Upper value = distance from High to Close
* Lower value = distance from Low to Close

Unlike traditional wick calculations, this tool always uses the **closing price as the anchor point**, ignoring the open price and candle direction.

Key Features:

* Works on Forex pairs, Gold (XAUUSD), and other instruments
* Automatically adjusts using tick size for accurate pip/point calculation
* Displays values directly on the chart for quick analysis
* Clean visualization with color-coded labels:

  * Red = Upper distance (High → Close)
  * Green = Lower distance (Low → Close)

Use Case:
This helps identify rejection strength and price behavior around the closing price, which can be useful for spotting liquidity grabs, reversals, and momentum shifts.

Settings:

* Option to filter minimum distance
* Option to limit number of labels for better chart clarity

Best used for:
Scalping, intraday trading, and price action strategies.

## Source Code

````pine
//@version=5
indicator("Wick to Close Distance (Pips)", overlay=true, max_labels_count=500)

// Inputs
candlesToShow = input.int(100, "Show Labels For Last X Candles", minval=1)
minDistance   = input.float(0.0, "Minimum Distance Filter", minval=0.0, step=0.1)

// Pip size
pip = syminfo.mintick * 10

// Distance measured only from wick to close
upper = (high - close) / pip
lower = (close - low) / pip

// Round to 1 decimal place
upperValue = math.round(upper * 10) / 10
lowerValue = math.round(lower * 10) / 10

// Show only latest X candles
showBar = bar_index >= math.max(last_bar_index - candlesToShow + 1, 0)

// Apply minimum filter
showUpper = showBar and upperValue >= minDistance
showLower = showBar and lowerValue >= minDistance

// Labels
if showUpper
    label.new(
         bar_index, high,
         text=str.tostring(upperValue),
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.tiny)

if showLower
    label.new(
         bar_index, low,
         text=str.tostring(lowerValue),
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.tiny)
````
