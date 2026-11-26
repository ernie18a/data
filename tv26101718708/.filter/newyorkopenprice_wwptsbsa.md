# NewYorkOpenPrice

- url: https://www.tradingview.com/script/wwpTSBSA/
- type: indicator
- pine_id: PUB;ddf943746628489692a9ba5d1156f10b
- version: 1.0

## Description

该指标旨在为日内交易者提供最精准的美股开盘价 (NY Open) 参考线。脚本通过锁定纽约当地时间 09:30，自动获取当前标的的开盘价格，并以射线的形式展现在图表上。

This indicator provides day traders with a precise reference for the New York Session Open (09:30 AM). It automatically captures the opening price and plots it as a clean, customizable ray.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © li-xiaoyao


// @version=6
indicator("NewYorkOpenPrice", overlay=true)

// --- 1. 图形化输入设置 ---
lineGroup    = "线条外观设置"
labelGroup   = "标签数值设置"

lineColor    = input.color(color.blue, "线条颜色", group=lineGroup)
lineWidth    = input.int(2, "线条宽度 (1-10)", minval=1, maxval=10, group=lineGroup)
lineStyleStr = input.string("──────", "线条类型", options=["──────", "----------", "··········"], group=lineGroup)

showLabel    = input.bool(false, "展示价格标签？", group=labelGroup)
labelOffset  = input.int(20, "标签右侧偏移量 (Bars)", group=labelGroup)

// --- 2. 核心逻辑处理 ---
getLineStyle(s) =>
    switch s
        "──────"      => line.style_solid
        "----------"  => line.style_dashed
        "··········"  => line.style_dotted
        => line.style_solid

// 核心：在 1 分钟周期获取 09:30 的价格
get_ny_open() =>
    nyHour   = hour(time, "America/New_York")
    nyMinute = minute(time, "America/New_York")
    // 使用 fixnan 确保在 09:31 之后的一整天里都能拿到 09:30 的那个价格
    var float dailyOpen = na
    if nyHour == 9 and nyMinute == 30
        dailyOpen := open
    dailyOpen

// 跨周期抓取
nyOpenPriceExact = request.security(syminfo.tickerid, "1", get_ny_open())

// 持久化变量
var line  rayLine     = na
var label priceLabel  = na

// --- 3. 绘图与更新逻辑 ---
// 只要拿到了有效价格，就开始处理
if not na(nyOpenPriceExact)
    // 如果是新的一天价格变动，或者图表刚加载
    if (nyOpenPriceExact != nyOpenPriceExact[1]) or na(rayLine)
        line.delete(rayLine)
        label.delete(priceLabel)

        // 创建射线
        rayLine := line.new(
             x1=bar_index, 
             y1=nyOpenPriceExact, 
             x2=bar_index + 1, 
             y2=nyOpenPriceExact, 
             width=lineWidth, 
             color=lineColor, 
             style=getLineStyle(lineStyleStr),
             extend=extend.right
             )
        
        if showLabel
            priceLabel := label.new(
                 x=last_bar_index + labelOffset, 
                 y=nyOpenPriceExact, 
                 text="NY Open: " + str.tostring(nyOpenPriceExact, format.mintick), 
                 style=label.style_none, 
                 textcolor=lineColor
                 )

// --- 4. 每根 K 线执行的同步逻辑 ---
if not na(rayLine)
    // 确保线样式实时更新
    line.set_y1(rayLine, nyOpenPriceExact)
    line.set_y2(rayLine, nyOpenPriceExact)
    line.set_width(rayLine, lineWidth)
    line.set_style(rayLine, getLineStyle(lineStyleStr))
    line.set_color(rayLine, lineColor)

if not na(priceLabel)
    if showLabel
        label.set_x(priceLabel, last_bar_index + labelOffset)
        label.set_y(priceLabel, nyOpenPriceExact)
        label.set_text(priceLabel, "NY Open: " + str.tostring(nyOpenPriceExact, format.mintick))
    else
        label.delete(priceLabel)
        priceLabel := na
````
