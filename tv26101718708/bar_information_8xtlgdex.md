# Bar information

- url: https://www.tradingview.com/script/8xtlGDEX/
- type: indicator
- pine_id: PUB;cc4a18fae6b84f8d8799575803e08dc4
- version: 1.0

## Description

这是关于k线的详细信息振幅的脚本

## Source Code

````pine
//@version=5

indicator("Tooltip", overlay = true, max_labels_count = 500)

import PineCoders/VisibleChart/4 as labelCount
// ------------------------------
// 一、前置计算
// ------------------------------

// 1.1 计算 K 线整根中点
float pxBarMid = (high + low) / 2.0

// 1.2 计算 K 线整根幅度、实体幅度、上影线幅度、下影线幅度
float ptsBarRange   = high - low
float ptsBodyRange  = math.abs(close - open)
float pxBodyTop     = math.max(open, close)
float pxBodyBottom  = math.min(open, close)
float ptsUpTail     = high - pxBodyTop
float ptsLoTail     = pxBodyBottom - low

// 1.3 计算 K 线实体占整根幅度的比例、上影线占整根幅度的比例、下影线占整根幅度的比例
float pctBodyOfBarRange   = ptsBarRange == 0.0 ? na : ptsBodyRange / ptsBarRange * 100.0
float pctUpTailOfBarRange = ptsBarRange == 0.0 ? na : ptsUpTail   / ptsBarRange * 100.0
float pctLoTailOfBarRange = ptsBarRange == 0.0 ? na : ptsLoTail   / ptsBarRange * 100.0


// ------------------------------
// 二、绘制悬浮数据视窗
// ------------------------------

// 2.1 在当前视窗可见的每一根 K 线低点建立一个透明的标签，作为鼠标悬停以显示 tooltip 的触发区
var label tooltipLabel = na
if labelCount.barIsVisible()
    color tooltipBackground = color.new(color.white, 100)
    tooltipLabel := label.new(bar_index, high, color = tooltipBackground)

    // 编写悬浮数据视窗中所要显示的文字
    string tooltipText =
          "整体中点  " + str.tostring(pxBarMid, format.mintick) +
          "\n整体幅度  " + str.tostring(ptsBarRange, format.mintick) +
          "\n实体幅度  " + str.tostring(ptsBodyRange, format.mintick) +
          "\n上影幅度  " + str.tostring(ptsUpTail, format.mintick) +
          "\n下影幅度  " + str.tostring(ptsLoTail, format.mintick) +
          "\n实体比例  " + (na(pctBodyOfBarRange)   ? "na" : str.format("{0,number,00.0}%", pctBodyOfBarRange)) +
          "\n上影比例  " + (na(pctUpTailOfBarRange) ? "na" : str.format("{0,number,00.0}%", pctUpTailOfBarRange)) +
          "\n下影比例  " + (na(pctLoTailOfBarRange) ? "na" : str.format("{0,number,00.0}%", pctLoTailOfBarRange))

    label.set_tooltip(tooltipLabel, tooltipText)
````
