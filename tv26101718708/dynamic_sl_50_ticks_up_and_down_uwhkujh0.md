# Dynamic SL - 50 Ticks (Up and Down)

- url: https://www.tradingview.com/script/UWhkujH0-Dynamic-SL-50-Ticks-Up-and-Down/
- type: indicator
- pine_id: PUB;4de1572f131943b4a7b5196b0b261fa5
- version: 1.0

## Description

50 tick stop loss. 
moves with price all the time. 
can change line extension in source code. right/left/ or both. 
line size
color 
change tick size

## Source Code

````pine
//@version=5
indicator("Dynamic SL - 50 Ticks (Up and Down)", overlay=true)


pipSize = 12.50

upperLine = close + pipSize
lowerLine = close - pipSize

var line lastUpperLine = na
var line lastLowerLine = na

if not na(lastUpperLine)
    line.delete(lastUpperLine)
if not na(lastLowerLine)
    line.delete(lastLowerLine)

lastUpperLine := line.new(x1=bar_index, y1=upperLine, x2=bar_index + 5, y2=upperLine, width=4, color=color.rgb(255, 255, 0), extend=extend.right)
lastLowerLine := line.new(x1=bar_index, y1=lowerLine, x2=bar_index + 5, y2=lowerLine, width=4, color=color.rgb(255, 255, 0), extend=extend.right)
````
