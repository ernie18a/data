# Candle Range Comparison Oscillator

- url: https://www.tradingview.com/script/UYrP3gnI-Candle-Range-Comparison-Oscillator/
- type: indicator
- pine_id: PUB;6a37d8ea97b8424fa121a2204d513cf3
- version: 1.0

## Description

A great replacement for volume on cfd's since you cant get true volume there, also combined with volume on futures gives you a pretty strong signal when big players enter the market.
Candle Range Comparison Oscillator
Candle Range Comparison Oscillator
Candle Range Comparison Oscillator

## Source Code

````pine
//@version=6
indicator("Candle Range Comparison Oscillator", overlay=false, max_labels_count=500)

// ----------------------------------------------------
// Inputs
// ----------------------------------------------------
lookback = input.int(30, "Compare To Previous N Candles", minval=1)

rangeType = input.string("High-Low", "Range Type", options=["High-Low", "True Range", "Body"])

smoothLen = input.int(1, "Smooth Oscillator", minval=1)

showLevels = input.bool(true, "Show Reference Levels")
showTable = input.bool(true, "Show Status Table")

// ----------------------------------------------------
// Candle range calculation
// ----------------------------------------------------
candleRange = switch rangeType
    "High-Low" => high - low
    "True Range" => math.max(high - low, math.max(math.abs(high - close[1]), math.abs(low - close[1])))
    "Body" => math.abs(close - open)

// ----------------------------------------------------
// Compare current closed candle to previous N candles
// Uses [1] so current candle is NOT included in its own average
// ----------------------------------------------------
avgPrevRange = math.sum(candleRange[1], lookback) / lookback

rangeRatioRaw = avgPrevRange > 0 ? candleRange / avgPrevRange : na

rangeRatio = smoothLen > 1 ? ta.ema(rangeRatioRaw, smoothLen) : rangeRatioRaw

// ----------------------------------------------------
// Classification
// ----------------------------------------------------
rangeText = rangeRatio < 0.50 ? "Very Small" :
     rangeRatio < 0.70 ? "Small Range" :
     rangeRatio < 1.00 ? "Below Normal" :
     rangeRatio < 1.30 ? "Normal / Mild Expansion" :
     rangeRatio < 1.70 ? "Large Range" :
     rangeRatio < 2.00 ? "Very Large Range" :
     "Extreme Range"

// ----------------------------------------------------
// Plots
// ----------------------------------------------------
plot(rangeRatio, "Range Ratio vs Previous 30 Candles", linewidth=2, style=plot.style_columns)

hline(1.0, "Normal 1.0x", linestyle=hline.style_solid)

hline(showLevels ? 0.50 : na, "Very Small 0.50x", linestyle=hline.style_dotted)
hline(showLevels ? 0.70 : na, "Small 0.70x", linestyle=hline.style_dotted)
hline(showLevels ? 1.30 : na, "Large 1.30x", linestyle=hline.style_dotted)
hline(showLevels ? 1.70 : na, "Very Large 1.70x", linestyle=hline.style_dotted)
hline(showLevels ? 2.00 : na, "Extreme 2.00x", linestyle=hline.style_dotted)

// ----------------------------------------------------
// Table
// ----------------------------------------------------
var table t = table.new(position.top_right, 2, 4, border_width=1)

if barstate.islast and showTable
    table.cell(t, 0, 0, "Metric", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(t, 1, 0, "Value", text_color=color.white, bgcolor=color.new(color.black, 0))

    table.cell(t, 0, 1, "Range Ratio", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(t, 1, 1, str.tostring(rangeRatio, "#.##") + "x", text_color=color.white, bgcolor=color.new(color.black, 0))

    table.cell(t, 0, 2, "Read", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(t, 1, 2, rangeText, text_color=color.white, bgcolor=color.new(color.black, 0))

    table.cell(t, 0, 3, "Lookback", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(t, 1, 3, str.tostring(lookback) + " candles", text_color=color.white, bgcolor=color.new(color.black, 0))

// ----------------------------------------------------
// Data window
// ----------------------------------------------------
plot(candleRange, "Current Candle Range", display=display.data_window)
plot(avgPrevRange, "Average Previous 30 Candle Range", display=display.data_window)
````
