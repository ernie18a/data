# ziqiao

- url: https://www.tradingview.com/script/2WllVyOW/
- type: indicator
- pine_id: PUB;6846c146e1dc41e89a4e916d9f2f107e
- version: 2.0

## Description

版本2｜正常版

子乔趋势 Spectre 更新提示版
本脚本主要用于在图表中显示更新提示、联系方式和版本状态，方便用户第一时间查看脚本更新内容并领取最新版本。

## Source Code

````pine
//@version=6
indicator("子乔更新提示表格版", overlay = true, max_labels_count = 100)

//=====================
// 参数
//=====================
showTable  = input.bool(true, "显示表格")
tablePos   = input.string("top_right", "表格位置", options = ["top_right", "top_left", "bottom_right", "bottom_left"])

showMidTip = input.bool(true, "显示中间提示")
tipBarsBack = input.int(18, "提示偏左K数", minval = 5, maxval = 100)
lookbackBars = input.int(80, "中间提示参考K数", minval = 20, maxval = 300)

//=====================
// 表格位置
//=====================
tablePosition = switch tablePos
    "top_left" => position.top_left
    "bottom_right" => position.bottom_right
    "bottom_left" => position.bottom_left
    => position.top_right

//=====================
// 表格
//=====================
var table infoTbl = table.new(tablePosition, 2, 4, border_width = 1)

if showTable and barstate.islast
    table.cell(infoTbl, 0, 0, "项目", text_color = color.white, bgcolor = color.gray)
    table.cell(infoTbl, 1, 0, "内容", text_color = color.white, bgcolor = color.gray)

    table.cell(infoTbl, 0, 1, "版本状态", text_color = color.white)
    table.cell(infoTbl, 1, 1, "脚本已更新", text_color = color.white, bgcolor = color.new(color.green, 0))

    table.cell(infoTbl, 0, 2, "联系方式", text_color = color.white)
    table.cell(infoTbl, 1, 2, "QQ私信1760577949", text_color = color.white, bgcolor = color.new(color.blue, 20))

    table.cell(infoTbl, 0, 3, "提示", text_color = color.white)
    table.cell(infoTbl, 1, 3, "私信领取新版本", text_color = color.white, bgcolor = color.new(color.orange, 0))

//=====================
// 中间提示
//=====================
var label midTipLabel = na

if barstate.islast and showMidTip
    if not na(midTipLabel)
        label.delete(midTipLabel)

    midPrice = (ta.highest(high, lookbackBars) + ta.lowest(low, lookbackBars)) / 2
    tipX = math.max(0, bar_index - tipBarsBack)
    tipText = "本版更新文字\nQQ私信1760577949\n更新新版本"

    midTipLabel := label.new(
         tipX,
         midPrice,
         tipText,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_label_down,
         color = color.new(color.black, 70),
         textcolor = color.white,
         size = size.normal)
````
