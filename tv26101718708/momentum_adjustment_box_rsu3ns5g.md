# Momentum Adjustment Box

- url: https://www.tradingview.com/script/rSu3nS5g/
- type: indicator
- pine_id: PUB;43c1b05953b949f2952daf347361f89d
- version: 1.0

## Description

原理
一段动能的释放后，需要一段适当长度的调整结构消化。
把这个过程用代码可视化，定量判断
用于判断这段动能是否被调整结构消化掉了
属于主观和定量相结合。

设置建议
箱体宽度计算方式为：按价格幅度
箱体宽度系数:0.5


以下为AI简介

动能调整结构工具 (Momentum Adjustment Box)
概述
这是一个 TradingView Pine Script v5 自定义指标，用于在强动能走势之后自动绘制旗帜式调整结构箱体。

核心原理：强动能上涨/下跌需要等长的时间来消化。箱体取趋势线中位到顶端（上涨）或中位到底端（下跌）的高度，形成旗帜形状。

视觉效果：趋势线像旗杆，箱体像旗帜——高度只有完整价格幅度的一半，宽度由价格振幅自动换算，呈现近似正方形。

功能特点
旗帜式箱体：上涨时箱体区间 = [50%中位, 顶端]；下跌时 = [底端, 50%中位]
橙色趋势线（旗杆）+ 红色半透明箱体（旗帜）
可选显示 50% 中轴线（黄色虚线）
箱体内显示"调整结构"标签 + 价格范围标签
右上角参数概览表格
所有颜色、线宽均可自定义
箱体宽度支持两种模式：按K线等宽 / 按价格幅度自动换算


---------------------------------------------------------------------------------------------------------------------principle
After a burst of kinetic energy, a properly timed adjustment phase is necessary for digestion.
Visualize this process with code and make quantitative judgments
Used to determine whether this kinetic energy has been adjusted and digested by the structure
It is a combination of subjective and quantitative approaches.

Configuration Recommendations
The calculation method for the box width is as follows: based on the price range
Cabinet width coefficient: 0.5


Here is an introduction to AI

Momentum Adjustment Box
Overview
This is a TradingView Pine Script v5 custom indicator designed to automatically plot flag pattern consolidation boxes following strong momentum trends.

Core Principle: A strong upward/downward momentum requires an equal amount of time to consolidate. The flag formation is created by measuring the height from the midpoint of the trend channel to the top (for an upward move) or from the midpoint to the bottom (for a downward move).

Visual effect: The trendline resembles a flagpole, while the box looks like a flag—its height is only half of the full price range, and its width is automatically converted based on price volatility, forming an approximately square shape.

Functional Features
Flag Pattern Box: During an uptrend, the box range = [50% median, top]; during a downtrend = [bottom, 50% median]
Orange trend line (flagpole) + red semi-transparent box (flag)
Optional display of 50% central axis (yellow dashed line)
The box displays the "Adjust Structure" label + price range label
Parameter Overview Table in the Top Right Corner
All colors and line widths can be customized
The box width supports two modes: equal width based on K-line / automatic conversion based on price range

## Source Code

````pine
//@version=6
indicator("Momentum Adjustment Box", shorttitle="MomAdjBox", overlay=true,
     max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ============================================================================
// 动能调整结构工具 (Momentum Adjustment Box) v1.3
// ============================================================================
// 功能：用户手动指定一段强动能走势的起点和终点，
//       系统自动在终点之后绘制旗帜式调整结构箱体。
// 原理：强动能上涨/下跌需要等长的时间来消化，
//       箱体取趋势线中位到顶端（上涨）或中位到底端（下跌）的高度，
//       形成旗帜形状。
// ============================================================================

// ======================== 动能段参数输入 ========================
start_offset = input.int(20, "动能起点距今K线数", minval=1, group="动能段",
               tooltip="动能段起始K线距离当前K线多少根（价格自动取该K线最低点）")
end_offset   = input.int(5, "动能终点距今K线数", minval=0, group="动能段",
               tooltip="动能段结束K线距离当前K线多少根（价格自动取该K线最高点）")

// ======================== 样式参数 ========================
line_color      = input.color(color.new(#FF6D00, 0), "趋势线颜色", group="样式")
box_fill_color  = input.color(color.new(color.red, 75), "箱体填充颜色", group="样式")
box_border_clr  = input.color(color.new(color.red, 50), "箱体边框颜色", group="样式")
midline_color   = input.color(color.new(#FFEB3B, 50), "中轴线颜色", group="样式")
show_label      = input.bool(true, "显示标签", group="样式")
show_midline    = input.bool(true, "显示中轴线 (50%)", group="样式")
line_width      = input.int(2, "趋势线宽度", minval=1, maxval=5, group="样式")
box_border_w    = input.int(1, "箱体边框宽度", minval=1, maxval=5, group="样式")

// ======================== 箱体宽度参数 ========================
box_width_mode = input.string("按价格幅度", "箱体宽度计算方式",
                 options=["按K线等宽", "按价格幅度"], group="箱体宽度",
                 tooltip="'按K线等宽': 宽度=动能段K线数\n'按价格幅度': 宽度由价格振幅自动换算")
box_width_mult = input.float(3.0, "箱体宽度系数", minval=0.5, maxval=20.0, step=0.5,
                 group="箱体宽度",
                 tooltip="调大→箱体变宽，调小→箱体变窄。配合'按价格幅度'模式使用")

// ============================================================================
// ATR 计算（用于价格幅度→K线数换算）
// ============================================================================
float atrVal = ta.atr(14)

// ============================================================================
// 持久化绘图对象引用
// ============================================================================
var line  trendLine   = na
var box   adjBox      = na
var line  midLine     = na
var label titleLabel  = na
var label priceLabel  = na
var int   actualBoxSpan = 0

// ============================================================================
// 辅助函数
// ============================================================================
deleteLine(line l) =>
    if not na(l)
        line.delete(l)

deleteBox(box b) =>
    if not na(b)
        box.delete(b)

deleteLabel(label lb) =>
    if not na(lb)
        label.delete(lb)

// 计算箱体K线宽度
calcBoxSpan(float boxHi, float boxLo, int barSpan) =>
    if box_width_mode == "按价格幅度"
        float priceAmp = boxHi - boxLo
        atrVal > 0 ? int(math.max(1, math.round((priceAmp / atrVal) * 14.0 * box_width_mult))) : barSpan
    else
        barSpan

// ============================================================================
// 核心绘制逻辑 — 仅在最后一根K线执行
// ============================================================================
if barstate.islast

    int s_bar = bar_index - start_offset
    int e_bar = bar_index - end_offset
    float s_prc = low[start_offset]
    float e_prc = high[end_offset]

    if s_bar < e_bar and s_bar >= 0
        int barSpan   = e_bar - s_bar
        float fullHi  = math.max(s_prc, e_prc)
        float fullLo  = math.min(s_prc, e_prc)
        float fullMid = (fullHi + fullLo) / 2.0

        // ── 旗帜式箱体：中位线到顶端（上涨）或中位线到底端（下跌） ──
        // 上涨时：箱体区间 = [中位, 顶端]
        // 下跌时：箱体区间 = [底端, 中位]
        float boxHi = fullMid
        float boxLo = fullLo
        bool isUp   = e_prc >= s_prc
        if isUp
            boxHi := fullHi
            boxLo := fullMid
        else
            boxHi := fullMid
            boxLo := fullLo

        float boxMid = (boxHi + boxLo) / 2.0
        int boxBarSpan = calcBoxSpan(fullHi, fullLo, barSpan)
        int boxEnd     = e_bar + boxBarSpan
        actualBoxSpan := boxBarSpan

        // ── 趋势线 ──
        deleteLine(trendLine)
        trendLine := line.new(
             x1 = s_bar, y1 = s_prc,
             x2 = e_bar, y2 = e_prc,
             color = line_color, width = line_width,
             style = line.style_solid)

        // ── 旗帜式箱体 ──
        deleteBox(adjBox)
        adjBox := box.new(
             left = e_bar, top = boxHi,
             right = boxEnd, bottom = boxLo,
             bgcolor = box_fill_color,
             border_color = box_border_clr,
             border_width = box_border_w,
             border_style = line.style_dashed)

        // ── 中轴线（旗帜箱体的50%位置） ──
        if show_midline
            deleteLine(midLine)
            midLine := line.new(
                 x1 = e_bar, y1 = boxMid,
                 x2 = boxEnd, y2 = boxMid,
                 color = midline_color, width = 1,
                 style = line.style_dashed)

        // ── 标签 ──
        if show_label
            deleteLabel(titleLabel)
            int labelBar = e_bar + math.round(boxBarSpan / 2)
            titleLabel := label.new(
                 x = labelBar, y = boxMid,
                 text = "调整结构",
                 color = color.new(color.red, 80),
                 style = label.style_label_center,
                 textcolor = color.white,
                 size = size.normal)

            deleteLabel(priceLabel)
            string pText = (isUp ? "顶:" : "底:") + str.tostring(isUp ? fullHi : fullLo, format.mintick) +
                 "\n50%:" + str.tostring(fullMid, format.mintick) +
                 "\n" + (isUp ? "旗顶:" : "旗底:") + str.tostring(boxMid, format.mintick)
            priceLabel := label.new(
                 x = boxEnd, y = boxMid,
                 text = pText,
                 color = color.new(color.red, 85),
                 style = label.style_label_left,
                 textcolor = color.white,
                 size = size.tiny)
        else
            deleteLabel(titleLabel)
            deleteLabel(priceLabel)
    else
        actualBoxSpan := 0

// ============================================================================
// 信息表格
// ============================================================================
var table infoTable = table.new(position.top_right, 2, 4,
     bgcolor=color.new(color.black, 80),
     border_color=color.new(color.gray, 70),
     border_width=1)

if barstate.islast
    table.cell(infoTable, 0, 0, "参数", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 0, "值", text_color=color.white, text_size=size.small)

    table.cell(infoTable, 0, 1, "起点→终点", text_color=color.orange, text_size=size.tiny)
    table.cell(infoTable, 1, 1,
         "Bar-" + str.tostring(start_offset) + " → Bar-" + str.tostring(end_offset),
         text_color=color.orange, text_size=size.tiny)

    table.cell(infoTable, 0, 2, "宽度模式 / 箱体宽度", text_color=color.white, text_size=size.tiny)
    table.cell(infoTable, 1, 2,
         box_width_mode + " / " + str.tostring(actualBoxSpan) + " bar",
         text_color=color.white, text_size=size.tiny)

    table.cell(infoTable, 0, 3, "提示", text_color=color.white, text_size=size.tiny)
    table.cell(infoTable, 1, 3, "起点=Low 终点=High", text_color=color.white, text_size=size.tiny)
````
