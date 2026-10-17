# ATR Strength Marker

- url: https://www.tradingview.com/script/jZ9LLqoD/
- type: indicator
- pine_id: PUB;da5a2d6837e646639aa8a08a56978f73
- version: 1.0

## Description

实体/ATR 强度标记

## Source Code

````pine
//@version=5
indicator("实体/ATR 强度标记", overlay=true)

// 参数
atrLength = input.int(14, "ATR 周期", minval=1)

// 计算
bodySize = math.abs(close - open)      // K线实体大小
atrValue = ta.atr(atrLength)            // ATR值

// 核心条件：实体 > ATR
isStrong = bodySize > atrValue

// 在主图上标记
// 阳线且实体>ATR：K线下方画绿色三角
plotshape(isStrong and close > open, style=shape.triangleup, location=location.belowbar, color=color.new(#00C851, 0), size=size.small, title="强势阳线")
// 阴线且实体>ATR：K线上方画红色三角  
plotshape(isStrong and close < open, style=shape.triangledown, location=location.abovebar, color=color.new(#FF4444, 0), size=size.small, title="强势阴线")

// 在图表左上角显示当前比值
var table infoTable = table.new(position.top_right, 2, 2, bgcolor=color.black, border_width=1)
if barstate.islast
    table.cell(infoTable, 0, 0, "实体/ATR:", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 0, str.tostring(bodySize/atrValue, "#.##"), text_color=bodySize > atrValue ? color.green : color.gray, text_size=size.small)
    table.cell(infoTable, 0, 1, "ATR数值:", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 1, str.tostring(atrValue, "#.#"), text_color=color.white, text_size=size.small)
````
