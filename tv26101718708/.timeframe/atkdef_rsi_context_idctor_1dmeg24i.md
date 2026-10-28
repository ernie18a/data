# ATK/DEF RSI Context idctor

- url: https://www.tradingview.com/script/1dmeG24i/
- type: indicator
- pine_id: PUB;f3f23c363f7a4a969849a98827952e62
- version: 2.0

## Description

RSI Context is an advanced Relative Strength Index analysis tool designed to provide a deeper understanding of RSI behavior, momentum conditions, volatility changes, and market context through a structured visual dashboard.

Traditional RSI indicators mainly display a single RSI line with fixed overbought and oversold levels. RSI Context expands this concept by analyzing RSI from multiple perspectives, including RSI strength, movement direction, volatility range, historical behavior, and important RSI events.

This indicator focuses on helping users study how RSI behaves under different market conditions and provides additional context for interpreting momentum changes.

## RSI Core Analysis

The indicator calculates RSI based on the selected RSI period and analyzes its current position and behavior.

The RSI analysis includes:

• Current RSI value
• RSI movement direction
• RSI strength and weakness conditions
• RSI relationship with the 50 midpoint level
• Momentum acceleration and deceleration
• Overbought and oversold areas

The system categorizes RSI behavior into different states to provide a clearer visual understanding of current momentum conditions.

## Dynamic RSI Volatility Framework

Unlike fixed RSI interpretation alone, RSI Context includes a dynamic volatility framework based on RSI statistical behavior.

The indicator uses RSI volatility measurements to create adaptive reference areas:

• RSI standard deviation calculation
• Dynamic upper and lower RSI boundaries
• RSI volatility expansion detection
• RSI volatility contraction observation
• Abnormal RSI movement identification

These dynamic levels help users compare current RSI movement with its recent historical behavior.

## RSI Behavior Classification

The indicator evaluates different RSI conditions and classifies them into readable states, including:

• Strong upward RSI movement
• Weakening upward momentum
• Strong downward RSI movement
• Recovery and rebound conditions
• Overboug conditions
• Oversod conditions
• Neutral and flat RSI conditions

This classification provides additional context beyond simply reading RSI valu.

## RSI Midpoint Analysis

The RSI 50 level is included as an important momentum reference area.

The indicator observes:

• Movement above the 50 level
• Movement below the 50 level
• Cross events around the midpoint
• Changes in RSI momentum direction

This helps users study transitions in RSI positioning and changes in momentum structure.

## RSI Event Detection

RSI Context automatically identifies several RSI-related events:

• RSI crossing above 50
• RSI crossing below 50
• Potential bullish divergence observation
• Potential bearish divergence observation

Detected events are displayed visually on the RSI panel for easier historical review.

The event system is designed as an analytical reference to highlight changes in RSI behavior.

## Divergence Analysis

The indicator includes price and RSI comparison logic to observe possible momentum differences.

The divergence module monitors situations where:

• Prce reaches a new recent high while RSI shows reduced strength
• Prce reaches a new recent low while RSI shows stronger RSI behavior

These observations help users study the relationship between prce movement and momentum changes.

## Historical RSI Context Table

The integrated dashboard provides recent RSI information in a structured table format.

The table includes:

• Recent bar references
• RSI values
• RSI behavior classification
• Dynamic RSI upper range
• RSI midpoint reference
• Dynamic RSI lower range
• Detected RSI events
• Context interpretation

This allows users to compare recent RSI development instead of focusing only on the current RSI reading.

## Visual RSI Dashboard

The indicator provides a complete RSI information panel containing:

• Main RSI line
• Dynamic RSI volatility bands
• 70 / 30 reference levels
• RSI 50 midpoint reference
• RSI event labels
• Historical RSI comparison table

The visual design helps users quickly review RSI structure and momentum information directly from the chart.

## Designed For

RSI Context is designed for users who study:

• RSI behavior
• Momentum analysis
• Technical analysis concepts
• Market condition observation
• Indicator research
• Price and momentum relationships

This tool can be used as part of a broader chart analysis process together with other forms of market evaluation.

## Usage Philosophy

RSI Context focuses on observation and analysis rather than automated decision-making.

The indicator presents RSI information in a structured format so users can independently interpret momentum conditions and market context.

It is designed to support learning, research, and visual analysis of RSI behavior.

## Important Notes

RSI Context is an analytical and educational indicator.

It does not provide guaranteed outcomes, financial advice, or automated trading decisions.

Users should apply their own analysis methods, timeframe selection, and risk management practices when interpreting market information.

The indicator is intended to improve understanding of RSI behavior and provide additional context for technical analysis studies.

## Source Code

````pine
//@version=6
indicator("ATK/DEF RSI Context idctor", overlay=false, precision=1, max_labels_count=500, max_lines_count=500)

// ==========================================
// 1. 参数设置 (Inputs)
// ==========================================
// --- RSI 核心参数 ---
grp_rsi         = "=== RSI 基础参数 ==="
rsiLen          = input.int(14, "RSI 周期长度", minval=1, group=grp_rsi)
rsiSrc          = input.source(close, "价格源", group=grp_rsi)
obLevel         = input.int(70, "超买阈值 (Overbought)", minval=50, maxval=95, group=grp_rsi)
osLevel         = input.int(30, "超卖阈值 (Oversold)", minval=5, maxval=50, group=grp_rsi)

// --- 多周期设置 (HTF / MTF / LTF) ---
grp_tf          = "=== 周期选择 (LTF / MTF / HTF) ==="
useTF1          = input.bool(true, "", inline="tf1", group=grp_tf)
tf1             = input.timeframe("5", "LTF 1 (短周期 1)", inline="tf1", group=grp_tf)

useTF2          = input.bool(true, "", inline="tf2", group=grp_tf)
tf2             = input.timeframe("15", "LTF 2 (短周期 2)", inline="tf2", group=grp_tf)

useTF3          = input.bool(true, "", inline="tf3", group=grp_tf)
tf3             = input.timeframe("60", "MTF 1 (中周期 1)", inline="tf3", group=grp_tf)

useTF4          = input.bool(true, "", inline="tf4", group=grp_tf)
tf4             = input.timeframe("240", "MTF 2 (中周期 2)", inline="tf4", group=grp_tf)

useTF5          = input.bool(true, "", inline="tf5", group=grp_tf)
tf5             = input.timeframe("D", "HTF 1 (长周期 1)", inline="tf5", group=grp_tf)

useTF6          = input.bool(true, "", inline="tf6", group=grp_tf)
tf6             = input.timeframe("W", "HTF 2 (长周期 2)", inline="tf6", group=grp_tf)

// --- 仪表盘视觉设置 ---
grp_ui          = "=== 仪表盘与热力图样式 ==="
tablePos        = input.string("右上 (Top Right)", "仪表盘位置", 
                  options=["右上 (Top Right)", "右下 (Bottom Right)", "左上 (Top Left)", "左下 (Bottom Left)"], group=grp_ui)
tableTextSize   = input.string("小 (Small)", "表格字体大小", 
                  options=["微小 (Tiny)", "小 (Small)", "正常 (Normal)", "大 (Large)"], group=grp_ui)

// 热力图配色阶梯
c_extreme_ob    = input.color(color.rgb(244, 67, 54),   "极度超买 (RSI >= 75)", group=grp_ui)
c_ob            = input.color(color.rgb(255, 138, 101), "超买偏强 (60 <= RSI < 75)", group=grp_ui)
c_neutral       = input.color(color.rgb(120, 144, 156), "中性盘整 (40 <= RSI < 60)", group=grp_ui)
c_os            = input.color(color.rgb(129, 199, 132), "超卖偏弱 (25 <= RSI < 40)", group=grp_ui)
c_extreme_os    = input.color(color.rgb(0, 200, 83),    "极度超卖 (RSI < 25)", group=grp_ui)

// ==========================================
// 2. 工具函数与防重绘计算
// ==========================================
// 获取无未来函数/防重绘的跨周期 RSI
f_getRSI(string tf) =>
    rsiVal = ta.rsi(rsiSrc, rsiLen)
    request.security(syminfo.tickerid, tf, rsiVal, barmerge.gaps_off, barmerge.lookahead_off)

// 热力图颜色梯度函数
f_getHeatColor(float val) =>
    if na(val)
        color.gray
    else if val >= 75.0
        c_extreme_ob
    else if val >= 60.0
        c_ob
    else if val >= 40.0
        c_neutral
    else if val >= 25.0
        c_os
    else
        c_extreme_os

// 状态文字描述函数
f_getStatusText(float val) =>
    if na(val)
        "无数据"
    else if val >= 75.0
        "极度超买 🔴"
    else if val >= 60.0
        "多头偏强 🟠"
    else if val >= 40.0
        "中性震荡 ⚪"
    else if val >= 25.0
        "空头偏弱 🟢"
    else
        "极度超卖 🟢🔥"

// 转换表格位置
f_getTablePos(string p) =>
    switch p
        "右下 (Bottom Right)" => position.bottom_right
        "左上 (Top Left)"     => position.top_left
        "左下 (Bottom Left)"  => position.bottom_left
        => position.top_right

// 转换字号
f_getTableSize(string s) =>
    switch s
        "微小 (Tiny)"   => size.tiny
        "正常 (Normal)" => size.normal
        "大 (Large)"   => size.large
        => size.small

// ==========================================
// 3. 计算各周期 RSI
// ==========================================
curRSI = ta.rsi(rsiSrc, rsiLen)

rsi1 = useTF1 ? f_getRSI(tf1) : na
rsi2 = useTF2 ? f_getRSI(tf2) : na
rsi3 = useTF3 ? f_getRSI(tf3) : na
rsi4 = useTF4 ? f_getRSI(tf4) : na
rsi5 = useTF5 ? f_getRSI(tf5) : na
rsi6 = useTF6 ? f_getRSI(tf6) : na

// 计算启用的有效周期平均 RSI (综合市场动能评分)
var float[] activeRSIs = array.new_float(0)
array.clear(activeRSIs)
if useTF1 and not na(rsi1)
    array.push(activeRSIs, rsi1)
if useTF2 and not na(rsi2)
    array.push(activeRSIs, rsi2)
if useTF3 and not na(rsi3)
    array.push(activeRSIs, rsi3)
if useTF4 and not na(rsi4)
    array.push(activeRSIs, rsi4)
if useTF5 and not na(rsi5)
    array.push(activeRSIs, rsi5)
if useTF6 and not na(rsi6)
    array.push(activeRSIs, rsi6)

avgRSI = array.size(activeRSIs) > 0 ? array.avg(activeRSIs) : curRSI

// ==========================================
// 4. 下方副图绘制 (当前 RSI + 综合均值热力线)
// ==========================================
h_ob = hline(obLevel, "超买线 (70)", color=color.new(color.red, 40), linestyle=hline.style_dashed)
h_mid= hline(50,      "中轴线 (50)", color=color.new(color.gray, 60), linestyle=hline.style_dotted)
h_os = hline(osLevel, "超卖线 (30)", color=color.new(color.green, 40), linestyle=hline.style_dashed)
fill(h_ob, h_os, color=color.new(color.blue, 96), title="正常波动区间")

plot(curRSI, title="当前图表 RSI", color=color.new(color.white, 20), linewidth=1)
plot(avgRSI, title="多周期综合平均 RSI (MTF Composite)", color=f_getHeatColor(avgRSI), linewidth=3)

// ==========================================
// 5. 仪表盘表格绘制 (Dashboard Table)
// ==========================================
var table heatmapTbl = table.new(position=f_getTablePos(tablePos), columns=4, rows=8, 
                                 bgcolor=color.rgb(20, 24, 35, 30), 
                                 border_color=color.rgb(50, 60, 80, 50), 
                                 border_width=1, 
                                 frame_color=color.rgb(70, 80, 100, 50), 
                                 frame_width=2)

if barstate.islast
    t_size = f_getTableSize(tableTextSize)
    
    // 表头
    table.cell(heatmapTbl, 0, 0, "周期层级", bgcolor=color.rgb(30, 36, 50), text_color=color.white, text_size=t_size)
    table.cell(heatmapTbl, 1, 0, "周期",     bgcolor=color.rgb(30, 36, 50), text_color=color.white, text_size=t_size)
    table.cell(heatmapTbl, 2, 0, "RSI 数值", bgcolor=color.rgb(30, 36, 50), text_color=color.white, text_size=t_size)
    table.cell(heatmapTbl, 3, 0, "热力状态", bgcolor=color.rgb(30, 36, 50), text_color=color.white, text_size=t_size)
    
    // 使用 Pine Script 标准 array.from 构建数据集合
    tfLabels  = array.from("LTF 1", "LTF 2", "MTF 1", "MTF 2", "HTF 1", "HTF 2")
    tfNames   = array.from(tf1, tf2, tf3, tf4, tf5, tf6)
    tfValues  = array.from(rsi1, rsi2, rsi3, rsi4, rsi5, rsi6)
    tfActives = array.from(useTF1, useTF2, useTF3, useTF4, useTF5, useTF6)

    int rowIdx = 1
    for i = 0 to array.size(tfLabels) - 1
        if array.get(tfActives, i)
            val = array.get(tfValues, i)
            c_bg = f_getHeatColor(val)
            table.cell(heatmapTbl, 0, rowIdx, array.get(tfLabels, i), bgcolor=color.rgb(25, 30, 42), text_color=color.silver, text_size=t_size)
            table.cell(heatmapTbl, 1, rowIdx, array.get(tfNames, i),  bgcolor=color.rgb(25, 30, 42), text_color=color.white, text_size=t_size)
            table.cell(heatmapTbl, 2, rowIdx, str.tostring(val, "#.#"), bgcolor=c_bg, text_color=color.white, text_size=t_size)
            table.cell(heatmapTbl, 3, rowIdx, f_getStatusText(val),   bgcolor=c_bg, text_color=color.white, text_size=t_size)
            rowIdx += 1

    // 综合平均行
    avg_c = f_getHeatColor(avgRSI)
    table.cell(heatmapTbl, 0, rowIdx, "综合", bgcolor=color.rgb(35, 42, 60), text_color=color.yellow, text_size=t_size)
    table.cell(heatmapTbl, 1, rowIdx, "多周期均值", bgcolor=color.rgb(35, 42, 60), text_color=color.yellow, text_size=t_size)
    table.cell(heatmapTbl, 2, rowIdx, str.tostring(avgRSI, "#.#"), bgcolor=avg_c, text_color=color.white, text_size=t_size)
    table.cell(heatmapTbl, 3, rowIdx, f_getStatusText(avgRSI), bgcolor=avg_c, text_color=color.white, text_size=t_size)
````
