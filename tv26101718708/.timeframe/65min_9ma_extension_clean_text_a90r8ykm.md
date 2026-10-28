# 65min 9MA Extension Clean Text

- url: https://www.tradingview.com/script/a90R8ykm-65min-9MA-Extension-Clean-Text/
- type: indicator
- pine_id: PUB;2133e5492bab491bbb4b0f58e2704129
- version: 1.0

## Description

Displays a box on chart which shows current price extension from 65min 9ma. Primarily used when trading qqq or nq to prepare for eminent reversals. Turns green when extended more than .52% from ma to downside, turns red when extended to the upside.

## Source Code

````pine
//@version=6
indicator("65min 9MA Extension Clean Text", overlay=true)

maLength = input.int(9, title="MA Length")
tfInput = input.timeframe("65", title="Timeframe Anchor")
// Hardcoded default optimized to 0.52% for reliable intraday exhaustion setups
targetPct = input.float(0.52, title="Target Extension Threshold (%)")
boxPosition = input.string("top_right", title="Box Position", options=["top_right", "bottom_right", "top_left", "bottom_left"])
defaultTxtColor = input.color(color.gray, title="Normal Text Color")

tablePos = boxPosition == "bottom_right" ? position.bottom_right : boxPosition == "top_left" ? position.top_left : boxPosition == "bottom_left" ? position.bottom_left : position.top_right

localMA = ta.sma(close, maLength)
htfMA = timeframe.isintraday and timeframe.multiplier == 65 and timeframe.period == "65" ? localMA : request.security(syminfo.tickerid, tfInput, ta.sma(close, maLength), gaps=barmerge.gaps_off)

pctExtension = ((close - htfMA) / htfMA) * 100

dynamicTextColor = pctExtension >= targetPct ? color.red : pctExtension <= -targetPct ? color.green : defaultTxtColor

var table displayBox = table.new(position.top_right, 1, 2)

labelText = "65m 9MA Ext: " + (pctExtension >= 0 ? "+" : "") + str.tostring(pctExtension, "#.00") + "%"

table.clear(displayBox, 0, 0, 0, 1)
table.cell(displayBox, 0, 0, text="", bgcolor=color.new(color.black, 100), width=15, height=14)
table.cell(displayBox, 0, 1, text=labelText, bgcolor=color.new(color.black, 100), text_color=dynamicTextColor, text_size=size.small)
````
