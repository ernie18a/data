# SMC Structures and FVG [Produced by Wanfeng]

- url: https://www.tradingview.com/script/8RC7W7lM/
- type: indicator
- pine_id: PUB;08601a0489b74d3f832f03ddb5b29cb2
- version: 2.0

## Description

中文简介
SMC 结构综合指标 | FVG 公允价值缺口 + BOS/CHoCH 结构突破 + 趋势防守位 + 区间比例线
指标核心功能
FVG 公允价值缺口
自动识别传统 3 根 K 线标准供需缺口，区分看涨 / 看跌缺口；价格触碰缺口后自动变灰淡化，支持一键收缩被触碰区间，可自定义显示历史缺口数量；不适配跳空大缺口行情。
SMC 结构识别（BOS/CHoCH）
内置回溯周期算法自动判定市场结构：顺势突破 BOS、逆势转换 CHoCH；支持自定义线条颜色、线型、粗细，可限制图表留存历史突破标记数量。
假破待确认虚线
价格试探结构高低但未收盘突破时，自动绘制待确认虚线；区分普通顺势假破、防守位假破两种样式，直观分辨有效突破与诱多 / 诱空假破。
动态趋势防守位
跟随当前市场结构实时切换防守基准：上涨趋势以阶段低点为防守、下跌趋势以阶段高点为防守；出现防守位假破时自动切换至假破极值作为临时防守，加粗实线标注并附带文字标签。
区间比例分割线
基于当前完整结构区间自动计算自定义百分比分割线（默认 50% 中位线），同步适配假破后的区间重构；可显示百分比数值标签，辅助找订单流关键支撑阻力。
参数分组说明
公允价值缺口：控制 FVG 显示、配色、触碰收缩、历史数量
结构突破：结构回溯周期、BOS/CHoCH 线条、当前完整结构轮廓线、假破待确认线
防守位：防守实线配色粗细、防守位假破虚线开关与样式
结构比例线：自定义分割百分比、比例线样式、数值标签开关
使用提示
结构回溯 K 线参数为算法基准，不建议随意修改，修改会破坏防守位判定逻辑；
FVG 仅识别标准 3K 缺口，指数、外汇大幅跳空行情下缺口识别会失真；
突破触发自动警报，BOS 代表顺势延续、CHoCH 代表趋势反转信号；
所有线条、色块透明度、线型、线宽均可自由自定义适配个人图表风格。
English Introduction
SMC Market Structure All-in-One Toolkit | FVG + BOS & CHoCH Breakout + Dynamic Defense Level + Ratio Split Line
Core Features
Fair Value Gap (FVG)
Detect standard 3-bar institutional liquidity gaps (bullish & bearish). FVG boxes turn gray once mitigated, with optional shrink function for touched zones. Adjustable max historical FVG count. Not recommended for large gap/jump markets.
SMC Structure Detection (BOS / CHoCH)
Built-in lookback algorithm to identify institutional market structure: BOS (Break of Structure, trend continuation) & CHoCH (Change of Character, trend reversal). Fully customizable line color, style, width, and limited historical breakout markers to avoid chart clutter.
Pending Fake Breakout Dashed Line
Draw temporary pending lines when price tests swing high/low without close breakout. Separate styles for regular trend fakeouts and defense level fakeouts, easily distinguish valid breaks vs liquidity hunts.
Dynamic Trend Defense Level
Auto-switch defense baseline based on current market bias: swing low for uptrend, swing high for downtrend. Temporarily shift defense level to fakeout extreme when liquidity hunt occurs, with thick solid line and text label.
Range Ratio Split Line
Auto calculate user-defined percentage split level (default 50% midpoint) over active market range, compatible with post-fakeout restructured ranges. Optional percentage value label for key order flow support/resistance zones.
Input Groups
Fair Value Gap: Toggle FVG display, color palette, mitigate shrink, max historical boxes
Market Structure: Structure lookback period, BOS/CHoCH line settings, full swing structure outline, pending fake breakout lines
Defense Level: Solid defense line config, toggle & style for defense fakeout dashed lines
Range Ratio Line: Custom split percentage, ratio line appearance, value label switch
Important Notes
Structure lookback bar count is core algorithm parameter, DO NOT modify arbitrarily; wrong value breaks defense level calculation.
This FVG logic only works for standard 3-bar gaps; performance degrades on assets with massive overnight jumps/gaps.
Built-in alert triggers on confirmed breakouts: BOS = trend continuation signal, CHoCH = trend reversal signal.
Full customization of all line width, color transparency, dash/dot/solid styles to match your chart layout preference.

## Source Code

````pine
//@version=6
indicator("SMC 结构+FVG+防守位+比例线 【FVG不适合跳空缺口】", overlay = true)
import LudoGH68/Drawings_public/1 as d

// ---------- 辅助函数 ----------
getLineStyle(lineOption) =>
    lineOption == "┈" ? line.style_dotted : lineOption == "╌" ? line.style_dashed : line.style_solid

get_structure_highest_bar(lookback) =>
    idx = 0
    maxBar = bar_index > lookback ? ta.highestbars(high, lookback) : ta.highestbars(high, bar_index + 1)
    for i = 0 to lookback - 1 by 1
        if high[i+1] > high[i+2] and high[i] <= high[i+1] and ((i+1) * -1) >= maxBar
            idx := (i+1) * -1
    idx := idx == 0 ? maxBar : idx
    idx

get_structure_lowest_bar(lookback) =>
    idx = 0
    minBar = bar_index > lookback ? ta.lowestbars(low, lookback) : ta.lowestbars(low, bar_index + 1)
    for i = 0 to lookback - 1 by 1
        if low[i+1] < low[i+2] and low[i] >= low[i+1] and ((i+1) * -1) >= minBar
            idx := (i+1) * -1
    idx := idx == 0 ? minBar : idx
    idx

// ========== 停滞统计设置 双语输入 ==========
stagnationWarningBars = input.int(55, "停滞警告 K线数 / Stagnation Warn Bars", minval=0, maxval=500, group="结构突破 / Market Structure", tooltip="连续无突破达到此数，显示提示标签（0=禁用）| Show warning label when no breakout reach this value (0=disable)")
stagnationStopBars     = input.int(250, "停止绘制 K线数 / Stop Draw Bars", minval=0, maxval=500, group="结构突破 / Market Structure", tooltip="连续无突破达到此数，停止绘制结构相关线条（0=禁用）| Stop drawing all structure lines after this count (0=disable)")
showStagnationTable    = input.bool(true, "显示停滞信息表格 / Show Stagnation Table", group="结构突破 / Market Structure")

// 停滞全局变量
var int   barsSinceBreakout   = 0
var label stagnationLabel     = na
var table infoTable           = na
var bool  isStructureStopped  = false

barsSinceBreakout := barsSinceBreakout + 1

// ---------- FVG 设置 ----------
isFvgToShow          = input(true, title='显示 FVG / Show FVG', group="公允价值缺口 / Fair Value Gap")
bullishFvgColor      = input(color.new(color.green, 70), '看涨 FVG 颜色 / Bullish FVG Color', group="公允价值缺口 / Fair Value Gap")
bearishFvgColor      = input(color.new(color.red, 70), '看跌 FVG 颜色 / Bearish FVG Color', group="公允价值缺口 / Fair Value Gap")
mitigatedFvgColor    = input(color.new(color.gray, 70), '触及后 FVG 颜色 / Mitigated FVG Color', group="公允价值缺口 / Fair Value Gap")
fvgHistoryNbr        = input.int(5, '显示 FVG 数量 / Max FVG Count', minval=1, maxval=50, group="公允价值缺口 / Fair Value Gap")
isMitigatedFvgToReduce = input(true, title='缩减触及后的 FVG / Shrink Mitigated FVG', group="公允价值缺口 / Fair Value Gap")

// ---------- 结构突破设置 ----------
structLookback          = input.int(10, '结构回溯K线数【确定防守位不建议修改】/ Swing Lookback (Do Not Modify)', minval=1, maxval=100, group="结构突破 / Market Structure", tooltip='用于确定结构的防守位，强烈建议不要修改 | Core swing calculation param, changing breaks defense level logic')
isCurrentStructToShow   = input(false, title='显示当前结构线 / Show Active Swing Lines', group="结构突破 / Market Structure")
bullishBosColor         = input(color.green, '看涨 BOS 颜色 / Bullish BOS Color', group="结构突破 / Market Structure")
bearishBosColor         = input(color.red, '看跌 BOS 颜色 / Bearish BOS Color', group="结构突破 / Market Structure")
bosLineStyleOption      = input.string("─", title="BOS 样式 / BOS Line Style", group="结构突破 / Market Structure", options=["─", "┈", "╌"])
bosLineStyle            = getLineStyle(bosLineStyleOption)
bosLineWidth            = input.int(1, title="BOS 线宽 / BOS Width", group="结构突破 / Market Structure", minval=1, maxval=10)
bullishChochColor       = input(color.green, '看涨 CHoCH 颜色 / Bullish CHoCH Color', group="结构突破 / Market Structure")
bearishChochColor       = input(color.red, '看跌 CHoCH 颜色 / Bearish CHoCH Color', group="结构突破 / Market Structure")
chochLineStyleOption    = input.string("─", title="CHoCH 样式 / CHoCH Line Style", group="结构突破 / Market Structure", options=["─", "┈", "╌"])
chochLineStyle          = getLineStyle(chochLineStyleOption)
chochLineWidth          = input.int(1, title="CHoCH 线宽 / CHoCH Width", group="结构突破 / Market Structure", minval=1, maxval=10)
currentStructColor      = input(color.blue, '当前结构线颜色 / Swing Line Color', group="结构突破 / Market Structure")
currentStructLineStyleOption = input.string("─", title="当前结构样式 / Swing Line Style", group="结构突破 / Market Structure", options=["─", "┈", "╌"])
currentStructLineStyle  = getLineStyle(currentStructLineStyleOption)
currentStructLineWidth  = input.int(1, title="当前结构线宽 / Swing Line Width", group="结构突破 / Market Structure", minval=1, maxval=10)
structHistoryNbr        = input.int(10, '显示突破数量 / Max Breakout Record', minval=1, maxval=50, group="结构突破 / Market Structure")

// ---------- 假破待确认线设置（顺势） ----------
showPendingLine = input(true, title="显示顺势突破待确认线 / Show Trend Fakeout Line", group="结构突破 / Market Structure")
pendingLineColor = input(color.blue, title="顺势待确认线颜色 / Fakeout Line Color", group="结构突破 / Market Structure")
pendingLineStyleOption = input.string("╌", title="顺势待确认线样式 / Fakeout Style", group="结构突破 / Market Structure", options=["─", "┈", "╌"])
pendingLineStyle = getLineStyle(pendingLineStyleOption)
pendingLineWidth = input.int(1, title="顺势待确认线宽 / Fakeout Width", group="结构突破 / Market Structure", minval=1, maxval=10)

// ---------- 防守位设置 ----------
showDefenseLine = input(true, title="显示趋势防守位 / Show Defense Level", group="防守位 / Defense Zone")
defenseLineColor = input(color.purple, title="防守位实线颜色 / Defense Solid Color", group="防守位 / Defense Zone")
defenseLineStyleOption = input.string("─", title="防守位实线样式 / Defense Solid Style", group="防守位 / Defense Zone", options=["─", "┈", "╌"])
defenseLineStyle = getLineStyle(defenseLineStyleOption)
defenseLineWidth = input.int(2, title="防守位实线宽 / Defense Solid Width", group="防守位 / Defense Zone", minval=1, maxval=10)
showDefensePending = input(false, title="显示防守位待破位线 / Show Defense Fakeout Line", group="防守位 / Defense Zone")
defensePendingColor = input(color.new(color.purple, 0), title="待破位虚线颜色 / Defense Fakeout Color", group="防守位 / Defense Zone")
defensePendingLineStyleOption = input.string("╌", title="待破位虚线样式 / Defense Fakeout Style", group="防守位 / Defense Zone", options=["─", "┈", "╌"])
defensePendingLineStyle = getLineStyle(defensePendingLineStyleOption)
defensePendingWidth = input.int(1, title="防守位待破位线宽 / Defense Fakeout Width", group="防守位 / Defense Zone", minval=1, maxval=10)

// ---------- 结构比例线设置 ----------
showRatioLine = input(true, title="显示结构比例线 / Show Range Ratio Line", group="结构比例线 / Range Ratio")
ratioPercent = input.int(50, title="分割比例 (%) / Split Percentage", minval=0, maxval=100, group="结构比例线 / Range Ratio", tooltip="0%对应区间下沿，100%对应区间上沿 | 0% = range low, 100% = range high")
ratioLineColor = input(color.new(color.teal, 0), title="比例线颜色 / Ratio Line Color", group="结构比例线 / Range Ratio")
ratioLineWidth = input.int(1, title="比例线线宽 / Ratio Line Width", minval=1, maxval=10, group="结构比例线 / Range Ratio")
ratioLineStyleOption = input.string("╌", title="比例线样式 / Ratio Line Style", group="结构比例线 / Range Ratio", options=["─", "┈", "╌"])
ratioLineStyle = getLineStyle(ratioLineStyleOption)
showRatioLabel = input(true, title="显示比例数值标签 / Show Ratio Label", group="结构比例线 / Range Ratio")

// ---------- FVG 绘制函数 ----------
FVGDraw(_boxes, _fvgTypes, _isFvgMitigated) => 
    for [index, value] in _boxes
        if array.get(_fvgTypes, index)
            if low <= box.get_bottom(value)
                array.remove(_boxes, index)
                array.remove(_fvgTypes, index)
                array.remove(_isFvgMitigated, index)
                box.delete(value)
            else 
                if low < box.get_top(value)
                    box.set_bgcolor(value, mitigatedFvgColor)
                    if not array.get(_isFvgMitigated, index)
                        alert("FVG 已被触及 / FVG Mitigated", alert.freq_once_per_bar)
                        array.set(_isFvgMitigated, index, true)
                    if isMitigatedFvgToReduce
                        box.set_top(value, low)
                box.set_right(value, bar_index)
        else
            if high >= box.get_top(value)
                array.remove(_boxes, index)
                array.remove(_fvgTypes, index)
                array.remove(_isFvgMitigated, index)
                box.delete(value)
            else
                if high > box.get_bottom(value)
                    box.set_bgcolor(value, mitigatedFvgColor)
                    if not array.get(_isFvgMitigated, index)
                        alert("FVG 已被触及 / FVG Mitigated", alert.freq_once_per_bar)
                        array.set(_isFvgMitigated, index, true)
                    if isMitigatedFvgToReduce
                        box.set_bottom(value, high)
                box.set_right(value, bar_index)

// ---------- 全局变量 ----------
var array<line>  structureLines  = array.new_line(0)
var array<label> structureLabels = array.new_label(0)
var array<box>   fvgBoxes        = array.new_box(0)
var array<bool>  fvgTypes        = array.new_bool(0)
var array<bool>  isFvgMitigated  = array.new_bool(0)

var float structureHigh = 0.0
var float structureLow  = 0.0

var int structureHighStartIndex = 0
var int structureLowStartIndex  = 0
var int structureDirection      = 0

var line  structureHighLine = na
var line  structureLowLine  = na

var bool isBOSAlert   = false
var bool isCHOCHAlert = false

// ---------- 假破待确认核心变量 ----------
var bool  pending_breakout = false
var int   pending_direction = 0
var float pending_extreme = 0.0
var int   pending_start_index = 0
var line  pending_line = na

// ---------- 防守位 & 比例线变量 ----------
var line  defenseLine = na
var label defenseLabel = na
var line  ratioLine = na
var label ratioLabel = na

// ---------- FVG 检测与绘制 ----------
isBullishFVG = high[3] < low[1]
isBearishFVG = low[3] > high[1]

if isBullishFVG and isFvgToShow
    box _box = box.new(left=bar_index - 2, top=low[1], right=bar_index[1], bottom=high[3], border_style=line.style_solid, border_width=1, bgcolor=bullishFvgColor, border_color=color.new(color.green, 100))
    array.push(fvgBoxes, _box)
    array.push(fvgTypes, true)
    array.push(isFvgMitigated, false)
    if array.size(fvgBoxes) > fvgHistoryNbr + 1
        box.delete(array.get(fvgBoxes, 0))
        array.remove(fvgBoxes, 0)
        array.remove(fvgTypes, 0)
        array.remove(isFvgMitigated, 0)

if isBearishFVG and isFvgToShow
    box _box = box.new(left=bar_index - 2, top=low[3], right=bar_index[1], bottom=high[1], border_style=line.style_solid, border_width=1, bgcolor=bearishFvgColor, border_color=color.new(color.red, 100))
    array.push(fvgBoxes, _box)
    array.push(fvgTypes, false)
    array.push(isFvgMitigated, false)
    if array.size(fvgBoxes) > fvgHistoryNbr + 1
        box.delete(array.get(fvgBoxes, 0))
        array.remove(fvgBoxes, 0)
        array.remove(fvgTypes, 0)
        array.remove(isFvgMitigated, 0)

FVGDraw(fvgBoxes, fvgTypes, isFvgMitigated)

// ---------- 结构基础计算 ----------
if bar_index == 0
    structureHighStartIndex := bar_index
    structureLowStartIndex  := bar_index
    structureHigh := high
    structureLow  := low 

structureMaxBar = bar_index + get_structure_highest_bar(structLookback)
structureMinBar = bar_index + get_structure_lowest_bar(structLookback)

low_struct_valid = bar_index[1] > structureLowStartIndex and bar_index[2] > structureLowStartIndex and bar_index[3] > structureLowStartIndex
high_struct_valid = bar_index[1] > structureHighStartIndex and bar_index[2] > structureHighStartIndex and bar_index[3] > structureHighStartIndex

isDefensePending = (structureDirection == 1 and pending_direction == 2) or (structureDirection == 2 and pending_direction == 1)
isTrendPending = (structureDirection == 1 and pending_direction == 1) or (structureDirection == 2 and pending_direction == 2)

// ---------- 核心：突破判定逻辑 ----------
isBOSAlert := false
isCHOCHAlert := false

if pending_breakout
    if pending_direction == 2
        if close < structureLow and low_struct_valid
            pending_breakout := false
            pending_direction := 0
            pending_extreme := 0.0
            pending_start_index := 0
            line.delete(pending_line)
            pending_line := na
            
            if array.size(structureLines) >= structHistoryNbr
                d.delete_line(array.get(structureLines, 0), array.get(structureLabels, 0))
                array.remove(structureLabels, 0)
                array.remove(structureLines, 0)
            
            if structureDirection == 1  
                array.push(structureLines, line.new(structureLowStartIndex, structureLow, bar_index, structureLow, xloc=xloc.bar_index, extend=extend.none, color=bearishBosColor, style=bosLineStyle, width=bosLineWidth))
                array.push(structureLabels, label.new((bar_index + structureLowStartIndex) / 2, structureLow, text="BOS", style=label.style_none, textcolor=bearishBosColor))
                isBOSAlert := true
            else
                array.push(structureLines, line.new(structureLowStartIndex, structureLow, bar_index, structureLow, xloc=xloc.bar_index, extend=extend.none, color=bearishChochColor, style=chochLineStyle, width=chochLineWidth))
                array.push(structureLabels, label.new((bar_index + structureLowStartIndex) / 2, structureLow, text="CHoCH", style=label.style_none, textcolor=bearishChochColor))
                isCHOCHAlert := true
            
            structureDirection := 1
            structureHighStartIndex := structureMaxBar
            structureLowStartIndex  := bar_index
            structureHigh := high[bar_index - structureHighStartIndex]
            structureLow  := low
        
        else if close > pending_extreme
            pending_breakout := false
            pending_direction := 0
            pending_extreme := 0.0
            pending_start_index := 0
            line.delete(pending_line)
            pending_line := na
            
            if array.size(structureLines) >= structHistoryNbr
                d.delete_line(array.get(structureLines, 0), array.get(structureLabels, 0))
                array.remove(structureLabels, 0)
                array.remove(structureLines, 0)
            
            if structureDirection == 2  
                array.push(structureLines, line.new(structureHighStartIndex, structureHigh, bar_index, structureHigh, xloc=xloc.bar_index, extend=extend.none, color=bullishBosColor, style=bosLineStyle, width=bosLineWidth))
                array.push(structureLabels, label.new((bar_index + structureHighStartIndex) / 2, structureHigh, text="BOS", style=label.style_none, textcolor=bullishBosColor))
                isBOSAlert := true
            else
                array.push(structureLines, line.new(structureHighStartIndex, structureHigh, bar_index, structureHigh, xloc=xloc.bar_index, extend=extend.none, color=bullishChochColor, style=chochLineStyle, width=chochLineWidth))
                array.push(structureLabels, label.new((bar_index + structureHighStartIndex) / 2, structureHigh, text="CHoCH", style=label.style_none, textcolor=bullishChochColor))
                isCHOCHAlert := true
            
            structureDirection := 2
            structureHighStartIndex := bar_index 
            structureLowStartIndex  := structureMinBar
            structureHigh := high 
            structureLow  := low[bar_index - structureLowStartIndex]
        
        else if high > pending_extreme and close <= pending_extreme
            pending_extreme := high
            if (showPendingLine and not isDefensePending) or (showDefensePending and isDefensePending)
                if not na(pending_line)
                    line.set_y1(pending_line, pending_extreme)
                    line.set_y2(pending_line, pending_extreme)
                    line.set_x2(pending_line, bar_index)
        
        if (showPendingLine and not isDefensePending) or (showDefensePending and isDefensePending)
            if not na(pending_line)
                line.set_x2(pending_line, bar_index)

    else if pending_direction == 1
        if close > structureHigh and high_struct_valid
            pending_breakout := false
            pending_direction := 0
            pending_extreme := 0.0
            pending_start_index := 0
            line.delete(pending_line)
            pending_line := na
            
            if array.size(structureLines) >= structHistoryNbr
                d.delete_line(array.get(structureLines, 0), array.get(structureLabels, 0))
                array.remove(structureLabels, 0)
                array.remove(structureLines, 0)
            
            if structureDirection == 2
                array.push(structureLines, line.new(structureHighStartIndex, structureHigh, bar_index, structureHigh, xloc=xloc.bar_index, extend=extend.none, color=bullishBosColor, style=bosLineStyle, width=bosLineWidth))
                array.push(structureLabels, label.new((bar_index + structureHighStartIndex) / 2, structureHigh, text="BOS", style=label.style_none, textcolor=bullishBosColor))
                isBOSAlert := true
            else
                array.push(structureLines, line.new(structureHighStartIndex, structureHigh, bar_index, structureHigh, xloc=xloc.bar_index, extend=extend.none, color=bullishChochColor, style=chochLineStyle, width=chochLineWidth))
                array.push(structureLabels, label.new((bar_index + structureHighStartIndex) / 2, structureHigh, text="CHoCH", style=label.style_none, textcolor=bullishChochColor))
                isCHOCHAlert := true
            
            structureDirection := 2
            structureHighStartIndex := bar_index 
            structureLowStartIndex  := structureMinBar
            structureHigh := high 
            structureLow  := low[bar_index - structureLowStartIndex]
        
        else if close < pending_extreme
            pending_breakout := false
            pending_direction := 0
            pending_extreme := 0.0
            pending_start_index := 0
            line.delete(pending_line)
            pending_line := na
            
            if array.size(structureLines) >= structHistoryNbr
                d.delete_line(array.get(structureLines, 0), array.get(structureLabels, 0))
                array.remove(structureLabels, 0)
                array.remove(structureLines, 0)
            
            if structureDirection == 1  
                array.push(structureLines, line.new(structureLowStartIndex, structureLow, bar_index, structureLow, xloc=xloc.bar_index, extend=extend.none, color=bearishBosColor, style=bosLineStyle, width=bosLineWidth))
                array.push(structureLabels, label.new((bar_index + structureLowStartIndex) / 2, structureLow, text="BOS", style=label.style_none, textcolor=bearishBosColor))
                isBOSAlert := true
            else
                array.push(structureLines, line.new(structureLowStartIndex, structureLow, bar_index, structureLow, xloc=xloc.bar_index, extend=extend.none, color=bearishChochColor, style=chochLineStyle, width=chochLineWidth))
                array.push(structureLabels, label.new((bar_index + structureLowStartIndex) / 2, structureLow, text="CHoCH", style=label.style_none, textcolor=bearishChochColor))
                isCHOCHAlert := true
            
            structureDirection := 1
            structureHighStartIndex := structureMaxBar
            structureLowStartIndex  := bar_index
            structureHigh := high[bar_index - structureHighStartIndex]
            structureLow  := low
        
        else if low < pending_extreme and close >= pending_extreme
            pending_extreme := low
            if (showPendingLine and not isDefensePending) or (showDefensePending and isDefensePending)
                if not na(pending_line)
                    line.set_y1(pending_line, pending_extreme)
                    line.set_y2(pending_line, pending_extreme)
                    line.set_x2(pending_line, bar_index)
        
        if (showPendingLine and not isDefensePending) or (showDefensePending and isDefensePending)
            if not na(pending_line)
                line.set_x2(pending_line, bar_index)

else
    if close < structureLow and low_struct_valid
        if array.size(structureLines) >= structHistoryNbr
            d.delete_line(array.get(structureLines, 0), array.get(structureLabels, 0))
            array.remove(structureLabels, 0)
            array.remove(structureLines, 0)
        
        if structureDirection == 1  
            array.push(structureLines, line.new(structureLowStartIndex, structureLow, bar_index, structureLow, xloc=xloc.bar_index, extend=extend.none, color=bearishBosColor, style=bosLineStyle, width=bosLineWidth))
            array.push(structureLabels, label.new((bar_index + structureLowStartIndex) / 2, structureLow, text="BOS", style=label.style_none, textcolor=bearishBosColor))
            isBOSAlert := true
        else
            array.push(structureLines, line.new(structureLowStartIndex, structureLow, bar_index, structureLow, xloc=xloc.bar_index, extend=extend.none, color=bearishChochColor, style=chochLineStyle, width=chochLineWidth))
            array.push(structureLabels, label.new((bar_index + structureLowStartIndex) / 2, structureLow, text="CHoCH", style=label.style_none, textcolor=bearishChochColor))
            isCHOCHAlert := true
        
        structureDirection := 1
        structureHighStartIndex := structureMaxBar
        structureLowStartIndex  := bar_index
        structureHigh := high[bar_index - structureHighStartIndex]
        structureLow  := low
    
    else if close > structureHigh and high_struct_valid
        if array.size(structureLines) >= structHistoryNbr
            d.delete_line(array.get(structureLines, 0), array.get(structureLabels, 0))
            array.remove(structureLabels, 0)
            array.remove(structureLines, 0)
        
        if structureDirection == 2  
            array.push(structureLines, line.new(structureHighStartIndex, structureHigh, bar_index, structureHigh, xloc=xloc.bar_index, extend=extend.none, color=bullishBosColor, style=bosLineStyle, width=bosLineWidth))
            array.push(structureLabels, label.new((bar_index + structureHighStartIndex) / 2, structureHigh, text="BOS", style=label.style_none, textcolor=bullishBosColor))
            isBOSAlert := true
        else
            array.push(structureLines, line.new(structureHighStartIndex, structureHigh, bar_index, structureHigh, xloc=xloc.bar_index, extend=extend.none, color=bullishChochColor, style=chochLineStyle, width=chochLineWidth))
            array.push(structureLabels, label.new((bar_index + structureHighStartIndex) / 2, structureHigh, text="CHoCH", style=label.style_none, textcolor=bullishChochColor))
            isCHOCHAlert := true
        
        structureDirection := 2
        structureHighStartIndex := bar_index 
        structureLowStartIndex  := structureMinBar
        structureHigh := high 
        structureLow  := low[bar_index - structureLowStartIndex]
    
    else
        if high > structureHigh and close <= structureHigh and high_struct_valid
            pending_breakout := true
            pending_direction := 2
            pending_extreme := high
            pending_start_index := bar_index
            isDef = (structureDirection == 1)
            showLine = isDef ? showDefensePending : showPendingLine
            lineColor = isDef ? defensePendingColor : pendingLineColor
            useStyle = isDef ? defensePendingLineStyle : pendingLineStyle
            lineWidth = isDef ? defensePendingWidth : pendingLineWidth
            if showLine
                pending_line := line.new(bar_index, pending_extreme, bar_index, pending_extreme, xloc.bar_index, color=lineColor, style=useStyle, width=lineWidth)
        
        else if low < structureLow and close >= structureLow and low_struct_valid
            pending_breakout := true
            pending_direction := 1
            pending_extreme := low
            pending_start_index := bar_index
            isDef = (structureDirection == 2)
            showLine = isDef ? showDefensePending : showPendingLine
            lineColor = isDef ? defensePendingColor : pendingLineColor
            useStyle = isDef ? defensePendingLineStyle : pendingLineStyle
            lineWidth = isDef ? defensePendingWidth : pendingLineWidth
            if showLine
                pending_line := line.new(bar_index, pending_extreme, bar_index, pending_extreme, xloc.bar_index, color=lineColor, style=useStyle, width=lineWidth)
        
        else
            if high > structureHigh and (structureDirection == 0 or structureDirection == 2)
                if not high_struct_valid
                    structureHigh := high
                    structureHighStartIndex := bar_index
            else if low < structureLow and (structureDirection == 0 or structureDirection == 1)
                if not low_struct_valid
                    structureLow := low
                    structureLowStartIndex := bar_index

structureRange = math.abs(structureHigh - structureLow)

// ========== 停滞计数重置 & 停绘判断 ==========
if isBOSAlert or isCHOCHAlert
    barsSinceBreakout := 0

isStructureStopped := stagnationStopBars > 0 and barsSinceBreakout >= stagnationStopBars

// 超时清除所有结构绘图
if isStructureStopped
    line.delete(structureHighLine)
    line.delete(structureLowLine)
    line.delete(defenseLine)
    line.delete(ratioLine)
    line.delete(pending_line)
    label.delete(defenseLabel)
    label.delete(ratioLabel)
    structureHighLine := na
    structureLowLine  := na
    defenseLine       := na
    ratioLine         := na
    pending_line      := na
    defenseLabel      := na
    ratioLabel        := na

// ========== 停滞顶部警告标签 ==========
if stagnationWarningBars > 0 and barsSinceBreakout >= stagnationWarningBars and not isStructureStopped
    label.delete(stagnationLabel)
    stagnationLabel := label.new(bar_index, high + ta.atr(20) * 0.5, text="走势停滞 | No Break: " + str.tostring(barsSinceBreakout) + "K", style=label.style_label_center, color=color.orange, textcolor=color.white, size=size.small)
else if not na(stagnationLabel)
    label.delete(stagnationLabel)
    stagnationLabel := na

// ========== 右下角停滞信息表格【仅保留table.cell支持的text_color】 ==========
if showStagnationTable
    if barstate.islast
        // table.new仅允许：位置、列、行、边框宽度
        infoTable := table.new(position.bottom_right, 2, 5, border_width=1)
        // 仅支持 text_color，删除 bg_color、colspan 等不兼容参数
        table.cell(infoTable, 0,0, "项目 / Item", text_color=color.blue)
        table.cell(infoTable, 1,0, "数值 / Value", text_color=color.blue)

        table.cell(infoTable, 0,1, "连续无突破K线", text_color=color.black)
        txtColor1 = isStructureStopped ? color.red : barsSinceBreakout >= stagnationWarningBars ? color.orange : color.green
        table.cell(infoTable, 1,1, str.tostring(barsSinceBreakout), text_color=txtColor1)

        table.cell(infoTable, 0,2, "警告阈值 Warn Thresh", text_color=color.black)
        table.cell(infoTable, 1,2, str.tostring(stagnationWarningBars), text_color=color.orange)

        table.cell(infoTable, 0,3, "停绘阈值 Stop Thresh", text_color=color.black)
        table.cell(infoTable, 1,3, str.tostring(stagnationStopBars), text_color=color.red)

        table.cell(infoTable, 0,4, "当前绘制状态 Draw State", text_color=color.black)
        drawStatusTxt = isStructureStopped ? "已停止 / Stopped" : "正常绘制 / Active"
        drawStatusCol = isStructureStopped ? color.red : color.green
        table.cell(infoTable, 1,4, drawStatusTxt, text_color=drawStatusCol)

// ---------- 绘制当前结构线 ----------
if isCurrentStructToShow and not isStructureStopped
    line.delete(structureHighLine)
    line.delete(structureLowLine)
    structureHighLine := line.new(structureHighStartIndex, structureHigh, bar_index, structureHigh, xloc.bar_index, color=currentStructColor, style = currentStructLineStyle, width = currentStructLineWidth)
    structureLowLine  := line.new(structureLowStartIndex, structureLow, bar_index, structureLow, xloc.bar_index, color=currentStructColor, style = currentStructLineStyle, width = currentStructLineWidth)

// ---------- 绘制防守位 ----------
if showDefenseLine and structureDirection != 0 and not isStructureStopped
    line.delete(defenseLine)
    label.delete(defenseLabel)
    
    float defPrice = na
    int defStartIndex = na
    if pending_breakout and isDefensePending
        defPrice := pending_extreme
        defStartIndex := pending_start_index
    else if structureDirection == 1
        defPrice := structureHigh
        defStartIndex := structureHighStartIndex
    else if structureDirection == 2
        defPrice := structureLow
        defStartIndex := structureLowStartIndex
    
    defenseLine := line.new(defStartIndex, defPrice, bar_index, defPrice, xloc.bar_index, color=defenseLineColor, style=defenseLineStyle, width=defenseLineWidth)
    defenseLabel := label.new(bar_index, defPrice, text="防守位 / Defense", style=label.style_label_left, textcolor=defenseLineColor, color=color.new(color.white, 100), size=size.small)

// ---------- 绘制结构比例线 ----------
if showRatioLine and structureDirection != 0 and not isStructureStopped
    line.delete(ratioLine)
    label.delete(ratioLabel)

    float ratioPrice = na
    int rangeStart = na
    float upperBound = na
    float lowerBound = na

    if pending_breakout and isTrendPending
        if structureDirection == 1
            upperBound := structureHigh
            lowerBound := pending_extreme
            rangeStart := math.max(structureHighStartIndex, pending_start_index)
        else
            upperBound := pending_extreme
            lowerBound := structureLow
            rangeStart := math.max(structureLowStartIndex, pending_start_index)
        
        rangeSize = upperBound - lowerBound
        ratioPrice := lowerBound + rangeSize * ratioPercent / 100
    else if pending_breakout and isDefensePending
        if structureDirection == 1
            upperBound := pending_extreme
            lowerBound := structureLow
            rangeStart := math.max(structureLowStartIndex, pending_start_index)
        else
            upperBound := structureHigh
            lowerBound := pending_extreme
            rangeStart := math.max(structureHighStartIndex, pending_start_index)
        
        rangeSize = upperBound - lowerBound
        ratioPrice := lowerBound + rangeSize * ratioPercent / 100
    else
        ratioPrice := structureLow + structureRange * ratioPercent / 100
        rangeStart := math.max(structureHighStartIndex, structureLowStartIndex)

    ratioLine := line.new(rangeStart, ratioPrice, bar_index, ratioPrice, xloc.bar_index, color=ratioLineColor, style=ratioLineStyle, width=ratioLineWidth)
    
    if showRatioLabel
        ratioLabel := label.new(bar_index, ratioPrice, text=str.tostring(ratioPercent) + "%", style=label.style_label_left, textcolor=ratioLineColor, color=color.new(color.white, 100), size=size.small)

// ---------- 突破警报 双语提示 ----------
alertcondition(condition = isBOSAlert,  title = "BOS 顺势突破 / BOS Trend Break",  message = "BOS 顺势结构突破确认 | BOS Trend Structure Break Confirmed")
alertcondition(condition = isCHOCHAlert, title = "CHoCH 趋势转换 / CHoCH Trend Shift", message = "CHoCH 结构反转确认 | CHoCH Structure Reversal Confirmed")

plot(na)
````
