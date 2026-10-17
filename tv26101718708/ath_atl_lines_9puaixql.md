# ATH & ATL Lines

- url: https://www.tradingview.com/script/9pUaIxql-ATH-ATL-Lines/
- type: indicator
- pine_id: PUB;6a61749911154f1f91adb10bf75ca7be
- version: 1.0

## Description

Lines on ATH and ATL levels
The lines get moved everytime a new ATH or ATL is printed

## Source Code

````pine
//@version=5
indicator(title="ATH & ATL Lines", overlay=true)

// — Calcolo ATH e ATL sull'intera storia disponibile
var float ath = na
var float atl = na

if na(ath) or high > ath
    ath := high

if na(atl) or low < atl
    atl := low

// — Disegno delle linee orizzontali continue
plot(ath, title="All-Time High", color=color.blue,  linewidth=2, style=plot.style_line)
plot(atl, title="All-Time Low",  color=color.red,   linewidth=2, style=plot.style_line)

// — Label ATH
if barstate.islast
    label.new(
         x       = bar_index,
         y       = ath,
         text    = "ATH: " + str.tostring(ath, format.mintick),
         color   = color.blue,
         textcolor = color.white,
         style   = label.style_label_left,
         size    = size.small
     )
    label.new(
         x       = bar_index,
         y       = atl,
         text    = "ATL: " + str.tostring(atl, format.mintick),
         color   = color.red,
         textcolor = color.white,
         style   = label.style_label_left,
         size    = size.small
     )
````
