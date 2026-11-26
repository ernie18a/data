# Volume Plain JZ

- url: https://www.tradingview.com/script/InWPZSlq-Volume-Plain-JZ/
- type: indicator
- pine_id: PUB;b615eb4c6ff14dcd9cc194478d33851c
- version: 1.0

## Description

Clean volume at the bottom of the chart, simple view of how many trades are in each candle

## Source Code

````pine
//@version=5
indicator("Volume Exact", overlay=false, max_labels_count=500)

// === Bar color logic ===
isBlack = bar_index % 5 == 0
isBull  = close >= open

barColor = isBlack ? color.black : isBull ? color.new(color.green, 0) : color.new(color.red, 0)

// === Volume columns ===
plot(volume, style=plot.style_columns, color=barColor, linewidth=1)

// === Labels — only on every 5th (black) bar ===
var label[] labelArray = array.new_label()

if barstate.isconfirmed and isBlack
    lbl = label.new(
         x         = bar_index,
         y         = volume,
         text      = str.tostring(volume, "#"),
         style     = label.style_label_down,
         color     = color.new(color.white, 100),
         textcolor = color.black,
         size      = size.tiny
     )
    array.push(labelArray, lbl)

    if array.size(labelArray) > 500
        label.delete(array.shift(labelArray))
````
