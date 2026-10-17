# Daily Candle Range (1D)

- url: https://www.tradingview.com/script/MjhpMWHc-Daily-Candle-Range-1D/
- type: indicator
- pine_id: PUB;d180d3b2929341449a569c8e88c469f4
- version: 1.0

## Description

Daily Range Labels automatically calculates and displays the total range (High–Low) of each completed daily candle in points.

This indicator is useful for:

* Measuring daily volatility at a glance.
* Comparing the size of daily moves over time.
* Studying historical expansion and contraction in price.
* Understanding how much an asset typically moves in a single trading day.
* Eliminating the need to manually use TradingView’s Price Range tool on every candle.

Features:

* Displays the range of each completed daily candle in points.
* Adjustable number of historical labels to display.
* Customizable label color, text color, and size.
* Lightweight and easy to read.

Ideal for traders who analyze volatility in cryptocurrencies, indices, forex, stocks, or any market available on TradingView.

## Source Code

````pine
//@version=6
indicator("Daily Range Labels", overlay=true, max_labels_count=500)

// ===== Inputs =====
candlesToShow = input.int(20, "Number of Labels", minval=1, maxval=500)
labelColor    = input.color(color.blue, "Label Color")
textColor     = input.color(color.white, "Text Color")
labelSize     = input.string("Small", "Label Size", options=["Tiny","Small","Normal","Large"])

// Convert size
sizeValue = switch labelSize
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    => size.large

// Store labels
var label[] labels = array.new<label>()

if timeframe.isdaily and barstate.isconfirmed
    rangePts = high - low

    lbl = label.new(
         x=bar_index,
         y=high,
         text=str.tostring(rangePts, "#.0") + " pts",
         style=label.style_label_down,
         color=labelColor,
         textcolor=textColor,
         size=sizeValue)

    array.push(labels, lbl)

    while array.size(labels) > candlesToShow
        label.delete(array.shift(labels))
````
