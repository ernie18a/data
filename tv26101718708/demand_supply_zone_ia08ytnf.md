# Demand & Supply Zone

- url: https://www.tradingview.com/script/ia08YtNF-Demand-Supply-Zone/
- type: indicator
- pine_id: PUB;49450f29fe6c47b49107b15fa7636b8a
- version: 1.0

## Description

általam meghatározott supply és demand zonák . 
aktuális zónák időzónáktól függően

## Source Code

````pine
//@version=6
indicator("Demand & Supply Zone", overlay=true, max_boxes_count=200, max_labels_count=200)

swingLen = input.int(10, "Swing hossz", minval=3)
atr = ta.atr(14)

swingHigh = ta.pivothigh(high, swingLen, swingLen)
swingLow = ta.pivotlow(low, swingLen, swingLen)

box.new(not na(swingLow) ? bar_index-swingLen-2 : na, not na(swingLow) ? math.min(open[swingLen],close[swingLen]) : na, not na(swingLow) ? last_bar_index : na, not na(swingLow) ? swingLow : na, border_color=color.new(color.lime,20), bgcolor=color.new(color.lime,85), border_width=1)
box.new(not na(swingHigh) ? bar_index-swingLen-2 : na, not na(swingHigh) ? swingHigh : na, not na(swingHigh) ? last_bar_index : na, not na(swingHigh) ? math.max(open[swingLen],close[swingLen]) : na, border_color=color.new(color.red,20), bgcolor=color.new(color.red,85), border_width=1)

label.new(not na(swingLow) ? bar_index-swingLen : na, not na(swingLow) ? swingLow-atr*0.3 : na, "Demand", color=color.lime, textcolor=color.black, style=label.style_label_up, size=size.small)
label.new(not na(swingHigh) ? bar_index-swingLen : na, not na(swingHigh) ? swingHigh+atr*0.3 : na, "Supply", color=color.red, textcolor=color.white, style=label.style_label_down, size=size.small)
````
