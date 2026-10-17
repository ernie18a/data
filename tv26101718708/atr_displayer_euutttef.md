# ATR Displayer

- url: https://www.tradingview.com/script/euUTTTEF-ATR-Displayer/
- type: indicator
- pine_id: PUB;77d08b028012477f9fdd308466428640
- version: 1.0

## Description

Displays ATR in tick in the corner of your chart. You can choose the corner, the colors, and the periodicity of the ATR.

## Source Code

````pine
//@version=6
indicator("ATR Displayer", overlay=true)

atrPeriod     = input.int(14, "ATR Period", minval=1)
displayCorner = input.string("top_left", "Display Position",
     options=["top_left", "top_right", "bottom_left", "bottom_right"])
txtColor      = input.color(color.new(color.teal, 0), "Text Color")
txtSize       = input.string(size.normal, "Font Size",
     options=[size.tiny, size.small, size.normal, size.large, size.huge])

atrValue = ta.atr(atrPeriod)
atrTicks = math.round(atrValue / syminfo.mintick)

pos = displayCorner == "top_right"    ? position.top_right    :
      displayCorner == "bottom_left"  ? position.bottom_left  :
      displayCorner == "bottom_right" ? position.bottom_right :
      position.top_left

var table tbl = table.new(
     position     = pos,
     columns      = 1,
     rows         = 1,
     bgcolor      = color.new(color.black, 85),
     border_color = color.new(color.gray, 60),
     border_width = 1
     )

if barstate.islast and not na(atrTicks)
    table.cell(tbl,
         column     = 0,
         row        = 0,
         text       = "ATR: " + str.tostring(atrTicks) + " ticks",
         text_color = txtColor,
         text_size  = txtSize,
         bgcolor    = color.new(color.black, 85)
         )
````
