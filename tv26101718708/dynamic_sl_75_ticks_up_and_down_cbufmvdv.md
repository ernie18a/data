# Dynamic SL - 75 Ticks (Up and Down)

- url: https://www.tradingview.com/script/CBUfMVdv-Dynamic-SL-75-Ticks-Up-and-Down/
- type: indicator
- pine_id: PUB;9783522efd1d404097264df3dd845e15
- version: 1.0

## Description

75 tick stop loss. moves with price all the time. 
can change tick size in source code. 
left/right or both extension in source code. 
color.

## Source Code

````pine
//@version=5
indicator("Dynamic SL - 75 Ticks (Up and Down)", overlay=true)


pipSize = 18.75

upperLine = close + pipSize
lowerLine = close - pipSize

var line lastUpperLine = na
var line lastLowerLine = na

if not na(lastUpperLine)
    line.delete(lastUpperLine)
if not na(lastLowerLine)
    line.delete(lastLowerLine)

lastUpperLine := line.new(x1=bar_index, y1=upperLine, x2=bar_index + 5, y2=upperLine, width=4, color=color.rgb(255, 115, 0), extend=extend.right)
lastLowerLine := line.new(x1=bar_index, y1=lowerLine, x2=bar_index + 5, y2=lowerLine, width=4, color=color.rgb(255, 115, 0), extend=extend.right)
````
