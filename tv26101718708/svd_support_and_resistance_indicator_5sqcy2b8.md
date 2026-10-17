# svd support and resistance indicator

- url: https://www.tradingview.com/script/5sQCY2B8-svd-support-and-resistance-indicator/
- type: indicator
- pine_id: PUB;28058a6a2116442ca2c43b6a934e9a44
- version: 2.0

## Description

support and resistance indicator  for intraday in 1 minute to 4 minuts

## Source Code

````pine
//@version=6
indicator('SVD REAL TIME 360 SUN RAYS', overlay = true, max_bars_back = 5000)

ht(amp) =>
    var float hl_t = na
    closeMA = ta.sma(close, amp)
    highestHigh = ta.highest(high, amp)
    lowestLow = ta.lowest(low, amp)

    hl_t := na(hl_t[1]) ? close : hl_t[1]

    if closeMA < hl_t and highestHigh < hl_t
        hl_t := highestHigh
        hl_t
    else if closeMA > hl_t and lowestLow > hl_t
        hl_t := lowestLow
        hl_t

    hl_t

ht4 = ht(4)
ht13 = ht(13)
ht40 = ht(40)
ht120 = ht(120)
ht360 = ht(360)
ht1080 = ht(1080)
ht3240 = ht(3240)
ht5000 = ht(5000)

plot(ht4, color = color.aqua)
plot(ht13, color = color.blue)
plot(ht40, color = color.green)
plot(ht120, color = color.lime)
plot(ht360, color = color.yellow)
plot(ht1080, color = color.orange)
plot(ht3240, color = color.red, linewidth = 2)
plot(ht5000, color = color.fuchsia, linewidth = 3)

// Labels
if barstate.islast
    label.new(bar_index, ht4, '4', color = color.aqua, textcolor = color.white, style = label.style_label_left)
    label.new(bar_index, ht13, '13', color = color.blue, textcolor = color.white, style = label.style_label_left)
    label.new(bar_index, ht40, '40', color = color.green, textcolor = color.white, style = label.style_label_left)
    label.new(bar_index, ht120, '120', color = color.lime, textcolor = color.black, style = label.style_label_left)
    label.new(bar_index, ht360, '360', color = color.yellow, textcolor = color.black, style = label.style_label_left)
    label.new(bar_index, ht1080, '1080', color = color.orange, textcolor = color.white, style = label.style_label_left)
    label.new(bar_index, ht3240, '3240', color = color.red, textcolor = color.white, style = label.style_label_left)
    label.new(bar_index, ht5000, '5000', color = color.fuchsia, textcolor = color.white, style = label.style_label_left)
````
