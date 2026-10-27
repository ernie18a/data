# CRT+SMT

- url: https://www.tradingview.com/script/ZMoFy6D0-CRT-SMT/
- type: indicator
- pine_id: PUB;41f4490c5b224837896f74f47729ad4c
- version: 1.0

## Description

📊 Multi-Timeframe Key Levels + SMT Divergence Indicator

【Core Features】
This indicator displays horizontal ray lines of key high/low levels from multiple timeframes on the left side of the chart, helping traders quickly identify critical support and resistance levels. It also automatically detects SMT (Smart Money Technique) divergences between Gold and Silver.

【Displayed Timeframes】
• PWH/PWL - Previous Week High/Low
• PDH/PDL - Previous Day High/Low
• 4HH/4HL - Previous 4-Hour High/Low
• 1HH/1HL - Previous 1-Hour High/Low

【SMT Divergence Detection】
When Gold (XAUUSD) breaks the previous 1-hour high/low while Silver (XAGUSD) fails to follow, SMT divergence signals are automatically marked on the chart:
• 🔴 SMT High Divergence - Gold breaks previous high, Silver does not follow → Potential bearish signal
• 🔵 SMT Low Divergence - Gold breaks previous low, Silver does not follow → Potential bullish signal

【Customization Options】
✅ Independent on/off toggle for each timeframe
✅ Customizable colors and line widths for each period
✅ Adjustable SMT label sizes (Tiny/Small/Normal/Large)
✅ Adjustable left-side ray starting offset
✅ Real-time status table showing Gold/Silver breakout states in the bottom right corner

【Use Cases】
• Day trading and swing trading
• Key support/resistance level identification
• Gold and Silver correlation analysis
• SMT divergence trading strategy

【Recommended Instruments】
Gold (XAUUSD) as primary chart, Silver (XAGUSD) as comparison symbol

【Notes】
• Recommended for use on 15-minute or 1-hour charts
• SMT comparison symbol can be modified in settings
• Previous week/day levels are disabled by default, can be enabled as needed

## Source Code

````pine
//@version=6
indicator("Previous High/Low Rays with SMT", overlay=true, max_lines_count=100, max_labels_count=100)

// ===== 用户可调参数 =====
// 显示控制
showWeekly = input.bool(false, "显示前周高低点", group="显示控制")
showDaily = input.bool(true, "显示前日高低点", group="显示控制")
show4H = input.bool(true, "显示前4H高低点", group="显示控制")
show1H = input.bool(true, "显示前1H高低点", group="显示控制")

// 前4小时设置
h4Color = input.color(color.new(color.orange, 70), "前4H颜色", group="前4小时")
h4Width = input.int(1, "前4H线宽", minval=1, maxval=3, group="前4小时")

// 前1小时设置
h1Color = input.color(color.new(color.purple, 70), "前1H颜色", group="前1小时")
h1Width = input.int(1, "前1H线宽", minval=1, maxval=3, group="前1小时")

// 其他周期设置（默认关闭）
weekColor = input.color(color.new(color.blue, 50), "前周颜色", group="前周")
weekWidth = input.int(1, "前周线宽", minval=1, maxval=3, group="前周")

dayColor = input.color(color.new(color.green, 50), "前日颜色", group="前日")
dayWidth = input.int(1, "前日线宽", minval=1, maxval=3, group="前日")

// 显示设置
showLabels = input.bool(true, "显示标签", group="显示设置")
leftOffset = input.int(20, "左侧偏移K线数", minval=5, maxval=100, group="显示设置")
showDebug = input.bool(false, "显示调试信息", group="显示设置")

// ===== SMT设置 =====
smtEnabled = input.bool(true, "启用SMT检测", group="SMT设置")
smtSymbol = input.symbol("XAGUSD", "对比品种", group="SMT设置")
smtLookback = input.int(3, "检测K线数", minval=1, maxval=20, group="SMT设置")
smtLabelSize = input.string("Small", "SMT标签大小", options=["Tiny", "Small", "Normal", "Large"], group="SMT设置")
smtShowTable = input.bool(true, "显示状态表格", group="SMT设置")

// ===== 获取数据 =====
// 使用 lookahead=barmerge.lookahead_on 确保在15分钟图表上能正确获取数据
prevDayHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
prevDayLow = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)

prevWeekHigh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
prevWeekLow = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_on)

prev4hHigh = request.security(syminfo.tickerid, "240", high[1], lookahead=barmerge.lookahead_on)
prev4hLow = request.security(syminfo.tickerid, "240", low[1], lookahead=barmerge.lookahead_on)

prev1hHigh = request.security(syminfo.tickerid, "60", high[1], lookahead=barmerge.lookahead_on)
prev1hLow = request.security(syminfo.tickerid, "60", low[1], lookahead=barmerge.lookahead_on)

// ===== 获取对比品种数据 =====
smtHigh = request.security(smtSymbol, timeframe.period, high)
smtLow = request.security(smtSymbol, timeframe.period, low)
smtPrev1hHigh = request.security(smtSymbol, "60", high[1], lookahead=barmerge.lookahead_on)
smtPrev1hLow = request.security(smtSymbol, "60", low[1], lookahead=barmerge.lookahead_on)

// ===== SMT检测 =====
goldHighBreakRecent = ta.highest(high, smtLookback) > prev1hHigh
silverHighBreakRecent = ta.highest(smtHigh, smtLookback) > smtPrev1hHigh
goldLowBreakRecent = ta.lowest(low, smtLookback) < prev1hLow
silverLowBreakRecent = ta.lowest(smtLow, smtLookback) < smtPrev1hLow

smtHighSignal = goldHighBreakRecent and not silverHighBreakRecent
smtLowSignal = goldLowBreakRecent and not silverLowBreakRecent

// ===== 调试信息 =====
if barstate.islast and showDebug
    debugText = "前日高: " + str.tostring(prevDayHigh, "#.##") + "\n" +
                 "前日低: " + str.tostring(prevDayLow, "#.##") + "\n" +
                 "前4H高: " + str.tostring(prev4hHigh, "#.##") + "\n" +
                 "前4H低: " + str.tostring(prev4hLow, "#.##") + "\n" +
                 "前1H高: " + str.tostring(prev1hHigh, "#.##") + "\n" +
                 "前1H低: " + str.tostring(prev1hLow, "#.##")
    label.new(bar_index, high + 20, text=debugText, color=color.new(color.black, 80), 
              textcolor=color.white, style=label.style_label_up, size=size.small)

// ===== 存储和清理 =====
var line[] lines = array.new_line()
var label[] labels = array.new_label()

if barstate.islast
    // 删除所有之前绘制的线条
    for i = 0 to array.size(lines) - 1
        line.delete(array.get(lines, i))
    array.clear(lines)
    
    // 删除所有之前绘制的标签
    for i = 0 to array.size(labels) - 1
        label.delete(array.get(labels, i))
    array.clear(labels)

// ===== 绘制射线 =====
if barstate.islast
    leftStartIndex = bar_index - leftOffset
    
    // 前4小时
    if show4H and not na(prev4hHigh)
        l1 = line.new(leftStartIndex, prev4hHigh, bar_index, prev4hHigh, 
                 color=h4Color, width=h4Width, extend=extend.right, style=line.style_dashed)
        l2 = line.new(leftStartIndex, prev4hLow, bar_index, prev4hLow, 
                 color=h4Color, width=h4Width, extend=extend.right, style=line.style_dashed)
        array.push(lines, l1)
        array.push(lines, l2)
    
    // 前1小时
    if show1H and not na(prev1hHigh)
        l3 = line.new(leftStartIndex, prev1hHigh, bar_index, prev1hHigh, 
                 color=h1Color, width=h1Width, extend=extend.right, style=line.style_dashed)
        l4 = line.new(leftStartIndex, prev1hLow, bar_index, prev1hLow, 
                 color=h1Color, width=h1Width, extend=extend.right, style=line.style_dashed)
        array.push(lines, l3)
        array.push(lines, l4)
    
    // 前周
    if showWeekly and not na(prevWeekHigh)
        l5 = line.new(leftStartIndex, prevWeekHigh, bar_index, prevWeekHigh, 
                 color=weekColor, width=weekWidth, extend=extend.right, style=line.style_dashed)
        l6 = line.new(leftStartIndex, prevWeekLow, bar_index, prevWeekLow, 
                 color=weekColor, width=weekWidth, extend=extend.right, style=line.style_dashed)
        array.push(lines, l5)
        array.push(lines, l6)
    
    // 前日
    if showDaily and not na(prevDayHigh)
        l7 = line.new(leftStartIndex, prevDayHigh, bar_index, prevDayHigh, 
                 color=dayColor, width=dayWidth, extend=extend.right, style=line.style_dashed)
        l8 = line.new(leftStartIndex, prevDayLow, bar_index, prevDayLow, 
                 color=dayColor, width=dayWidth, extend=extend.right, style=line.style_dashed)
        array.push(lines, l7)
        array.push(lines, l8)

// ===== 标签显示 =====
if barstate.islast and showLabels
    labelLeftPos = bar_index - leftOffset - 1
    
    // 前4小时
    if show4H and not na(prev4hHigh)
        lbl1 = label.new(labelLeftPos, prev4hHigh, text="4HH", 
                  color=h4Color, textcolor=color.white, style=label.style_label_right, size=size.small)
        lbl2 = label.new(labelLeftPos, prev4hLow, text="4HL", 
                  color=h4Color, textcolor=color.white, style=label.style_label_right, size=size.small)
        array.push(labels, lbl1)
        array.push(labels, lbl2)
    
    // 前1小时
    if show1H and not na(prev1hHigh)
        lbl3 = label.new(labelLeftPos, prev1hHigh, text="1HH", 
                  color=h1Color, textcolor=color.white, style=label.style_label_right, size=size.small)
        lbl4 = label.new(labelLeftPos, prev1hLow, text="1HL", 
                  color=h1Color, textcolor=color.white, style=label.style_label_right, size=size.small)
        array.push(labels, lbl3)
        array.push(labels, lbl4)
    
    // 前周
    if showWeekly and not na(prevWeekHigh)
        lbl5 = label.new(labelLeftPos, prevWeekHigh, text="PWH", 
                  color=weekColor, textcolor=color.white, style=label.style_label_right, size=size.small)
        lbl6 = label.new(labelLeftPos, prevWeekLow, text="PWL", 
                  color=weekColor, textcolor=color.white, style=label.style_label_right, size=size.small)
        array.push(labels, lbl5)
        array.push(labels, lbl6)
    
    // 前日
    if showDaily and not na(prevDayHigh)
        lbl7 = label.new(labelLeftPos, prevDayHigh, text="PDH", 
                  color=dayColor, textcolor=color.white, style=label.style_label_right, size=size.small)
        lbl8 = label.new(labelLeftPos, prevDayLow, text="PDL", 
                  color=dayColor, textcolor=color.white, style=label.style_label_right, size=size.small)
        array.push(labels, lbl7)
        array.push(labels, lbl8)

// ===== SMT信号显示 =====
if smtEnabled
    // 获取SMT标签大小
    labelSize = switch smtLabelSize
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        => size.large
    
    if smtHighSignal
        lbl = label.new(bar_index, high, text="SMT高背离", 
                  color=color.new(color.red, 80), textcolor=color.white, 
                  style=label.style_label_down, size=labelSize)
        ln = line.new(bar_index, high, bar_index + 2, high, color=color.red, width=1, style=line.style_dotted)
        array.push(labels, lbl)
        array.push(lines, ln)
    
    if smtLowSignal
        lbl = label.new(bar_index, low, text="SMT低背离", 
                  color=color.new(color.blue, 80), textcolor=color.white, 
                  style=label.style_label_up, size=labelSize)
        ln = line.new(bar_index, low, bar_index + 2, low, color=color.blue, width=1, style=line.style_dotted)
        array.push(labels, lbl)
        array.push(lines, ln)

// ===== SMT状态表格 =====
if barstate.islast and smtEnabled and smtShowTable
    var table smtTable = table.new(position.bottom_right, 2, 3, bgcolor=color.new(color.black, 85), border_width=1)
    
    // 表头
    table.cell(smtTable, 0, 0, "品种", text_color=color.white, bgcolor=color.gray)
    table.cell(smtTable, 1, 0, "状态", text_color=color.white, bgcolor=color.gray)
    
    // 黄金状态
    goldStatus = goldHighBreakRecent ? "↑" : goldLowBreakRecent ? "↓" : "-"
    goldColor = goldHighBreakRecent ? color.green : goldLowBreakRecent ? color.red : color.gray
    table.cell(smtTable, 0, 1, "黄金", text_color=color.white)
    table.cell(smtTable, 1, 1, goldStatus, text_color=goldColor)
    
    // 白银状态
    silverStatus = silverHighBreakRecent ? "↑" : silverLowBreakRecent ? "↓" : "-"
    silverColor = silverHighBreakRecent ? color.green : silverLowBreakRecent ? color.red : color.gray
    table.cell(smtTable, 0, 2, "白银", text_color=color.white)
    table.cell(smtTable, 1, 2, silverStatus, text_color=silverColor)
````
