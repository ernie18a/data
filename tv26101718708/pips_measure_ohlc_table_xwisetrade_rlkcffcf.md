# Pips Measure & OHLC Table [XWiseTrade]

- url: https://www.tradingview.com/script/rLKCffcf-Pips-Measure-OHLC-Table-XWiseTrade/
- type: indicator
- pine_id: PUB;48fa3586864342fe8282c247f755aa90
- version: 1.0

## Description

Precise pips calculation and OHLC info for every candle.

This indicator provides:
• H-L and O-C pips on bar labels
• Hover tooltip with full OHLC table
• Optional static table for the last bar
• Customizable price digit display

Features:
• Accurate pip sizing (mintick-based)
• Three display modes (labels, tooltip, static table)
• Clean, professional formatting

Essential for forex traders tracking precise price movement and candle structure.

## Source Code

````pine
//@version=6
indicator("Pips Measure & OHLC Table [XWiseTrade]", overlay=true, max_labels_count=500)

// === 用户输入参数 ===
showLabels = input.bool(true, "Show Labels on Each Bar")
showTooltips = input.bool(true, "Show Tooltips on Hover (Alternative to Dynamic Table)")
showHighLow = input.bool(true, "Show H-L Pips in Label/Tooltip")
showBody = input.bool(true, "Show O-C Pips in Label/Tooltip")
labelOffset = input.int(10, "Label Movement in Vertical(pips)", step=1)
tooltipOffset = input.int(0, "Tooltip Trigger Vertical Offset (pips)", step=1)
intPartLen = input.int(1, "Show the number of digits of the integer part", minval=0, maxval=5)
fracPartLen = input.int(5, "Show the number of digits of the decimal part", minval=0, maxval=5)

showStaticTable = input.bool(false, "Show Static Table for Last Bar")
tablePosition = input.string("Top Right", "Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"])
debugTooltip = input.bool(false, "Debug: Show Tooltip Label Visibly")

// === Pip 值计算 ===
pipValue = syminfo.mintick * 10.0
highLowPips = math.abs(high - low) / pipValue
bodyPips = math.abs(close - open) / pipValue

// === 收盘价所占整根蜡烛的百分比 ===
closePercent = high != low ? (close - low) / (high - low) * 100 : 0.0

// === 价格格式化函数（支持整数/小数位控制，支持四舍五入） ===
f_formatPrice(val, intLen, fracLen) =>
    format = "#." + str.repeat("0", fracLen)
    raw = str.tostring(val, format)
    dotIndex = str.pos(raw, ".")
    if na(dotIndex)
        raw
    else
        rawInt = str.substring(raw, 0, dotIndex)
        rawFrac = str.substring(raw, dotIndex + 1, str.length(raw))
        intNeeded = intLen - str.length(rawInt)
        paddedInt = intNeeded > 0 ? str.repeat("0", intNeeded) + rawInt : rawInt
        paddedInt + "." + rawFrac

// === 获取格式化字符串 ===
openPriceStr = f_formatPrice(open, intPartLen, fracPartLen)
highPriceStr = f_formatPrice(high, intPartLen, fracPartLen)
lowPriceStr = f_formatPrice(low, intPartLen, fracPartLen)
closePriceStr = f_formatPrice(close, intPartLen, fracPartLen)
highLowPipsStr = str.tostring(highLowPips, "#.#")
bodyPipsStr = str.tostring(bodyPips, "#.#")
closePercentStr = str.tostring(closePercent, "#.#") + "%"

// === 拼接标签内容（如果启用标签） ===
string labelText = ""
if showHighLow
    labelText := "H / L:  " + highLowPipsStr
if showBody
    labelText := labelText + (showHighLow ? "\n" : "") + "O / C:  " + bodyPipsStr
labelText := labelText + "\nH:  " + highPriceStr + "\nL:  " + lowPriceStr

// === 创建标签（如果启用） ===
if showLabels
    label.new(bar_index, high + labelOffset * pipValue, labelText, style=label.style_text_outline, textcolor=color.white, size=size.normal, color=color.new(color.black, 0))

// === 拼接工具提示内容（模拟表格，使用更多固定宽度对齐以改善外观） ===
string tooltipText = "Item          Value\n" + 
                     "------------- ------------\n" + 
                     "Open          " + openPriceStr + "\n" + 
                     "High          " + highPriceStr + "\n" + 
                     "Low           " + lowPriceStr + "\n" + 
                     "Close         " + closePriceStr + "\n" + 
                     "------------- ------------\n" + 
                     "H-L Pips      " + highLowPipsStr + "\n" + 
                     "O-C Pips      " + bodyPipsStr + "\n" + 
                     "Close %       " + closePercentStr

// === 创建工具提示标签（如果启用，位置调整到蜡烛中间并添加偏移，便于悬停，使用多行窄文本使hover区域更窄更高） ===
if showTooltips
    string tall_text = debugTooltip ? "Hover me\n(for debug)" : str.repeat("\n ", 30)  // 更多行，少空格，使宽度窄似蜡烛宽度，高度覆盖蜡烛
    lbl_style = debugTooltip ? label.style_label_center : label.style_none
    lbl_color = debugTooltip ? color.new(color.blue, 80) : color.black
    lbl_textcolor = debugTooltip ? color.white : color.blue
    label.new(bar_index, (high + low) / 2 + tooltipOffset * pipValue, text=tall_text, yloc=yloc.price, style=lbl_style, color=lbl_color, textcolor=lbl_textcolor, tooltip=tooltipText, size=size.large)

// === 创建静态表格（如果启用，仅最后一根蜡烛） ===
if showStaticTable and barstate.islast
    pos = position.top_right
    switch tablePosition
        "Top Left" => pos := position.top_left
        "Top Center" => pos := position.top_center
        "Top Right" => pos := position.top_right
        "Middle Left" => pos := position.middle_left
        "Middle Center" => pos := position.middle_center
        "Middle Right" => pos := position.middle_right
        "Bottom Left" => pos := position.bottom_left
        "Bottom Center" => pos := position.bottom_center
        "Bottom Right" => pos := position.bottom_right

    var table infoTable = table.new(pos, columns=2, rows=8, border_width=1, frame_width=1, bgcolor=color.new(color.gray, 80))

    // 表头
    table.cell(infoTable, 0, 0, "Item", bgcolor=color.new(color.blue, 20), text_color=color.white)
    table.cell(infoTable, 1, 0, "Value", bgcolor=color.new(color.blue, 20), text_color=color.white)

    // OHLC
    table.cell(infoTable, 0, 1, "Open")
    table.cell(infoTable, 1, 1, openPriceStr)
    table.cell(infoTable, 0, 2, "High")
    table.cell(infoTable, 1, 2, highPriceStr)
    table.cell(infoTable, 0, 3, "Low")
    table.cell(infoTable, 1, 3, lowPriceStr)
    table.cell(infoTable, 0, 4, "Close")
    table.cell(infoTable, 1, 4, closePriceStr)

    // Pips
    table.cell(infoTable, 0, 5, "H-L Pips")
    table.cell(infoTable, 1, 5, highLowPipsStr)
    table.cell(infoTable, 0, 6, "O-C Pips")
    table.cell(infoTable, 1, 6, bodyPipsStr)
    table.cell(infoTable, 0, 7, "Close %")
    table.cell(infoTable, 1, 7, closePercentStr)
````
