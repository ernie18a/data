# 44 EMA & VWAP 

- url: https://www.tradingview.com/script/Hm10YbQb-44-EMA-VWAP/
- type: indicator
- pine_id: PUB;a0c9b8b4e9374d8e99a94f0d8bbcb24e
- version: 5.0

## Description

The 44 EMA: A medium-fast moving average that reacts quickly to recent price changes while filtering out minor noise.

VWAP: Calculated by taking the sum of (Price × Volume) divided by Total Volume.

## Source Code

````pine
//@version=6
indicator("[Removed] Script Content Removed", overlay = true)

// Satisfies the compiler requirement
plot(na, title="Placeholder")

// Displays a message box on the last bar of the chart
var label msg = label.new(bar_index, high, text="Script content removed by author", color=color.gray, textcolor=color.white, style=label.style_label_down)
label.set_xy(msg, bar_index, high)
label.set_text(msg, "Script content removed by author")
````
