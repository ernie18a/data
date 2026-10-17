# Volume with Candle Color + Marker

- url: https://www.tradingview.com/script/qZVzyaxP/
- type: indicator
- pine_id: PUB;c12f03f63cd64730b4bff65281d6f49d
- version: 1.0

## Description

好用

## Source Code

````pine
//@version=6
indicator("Volume with Candle Color + Marker", overlay=false, max_labels_count=50)

// === 1️⃣ 成交量颜色逻辑 ===
isUp   = close >= open
isDown = close < open

volColor = isUp ? color.green : color.red

// === 2️⃣ 画成交量柱 ===
plot(volume, 
     title="Volume", 
     style=plot.style_columns, 
     color=volColor)

// === 3️⃣ 交互式选择要标记的那根K线 ===
anchorTime = input.time(
     defval = timestamp("2026-04-14 09:30 -0700"),
     title = "点击选择要标记的量柱",
     confirm = true
)

// 标签文字
markText = input.string("重点量", "标签文字")

// === 4️⃣ 标签 ===
var label volLabel = na

if not na(volLabel)
    label.delete(volLabel)
    volLabel := na

isTargetBar = time == anchorTime

if isTargetBar
    volLabel := label.new(
         x = bar_index,
         y = volume * 1.1,
         text = markText,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_label_down,
         color = color.blue,
         textcolor = color.white,
         size = size.small
     )
````
