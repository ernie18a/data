# Flex EMA Ribbon   10 Customizable Lines

- url: https://www.tradingview.com/script/4VCvVTxX/
- type: indicator
- pine_id: PUB;a8d488b492934773b98cf289fc9bec6b
- version: 1.0

## Description

Flex EMA Ribbon — 10 Customizable Lines is a flexible trend indicator that displays up to 10 exponential moving averages (EMAs) directly on the price chart.
The default periods are 5, 10, 20, 30, 50, 60, 100, 120, 200, and 250. Each period can be changed independently, and each line can be shown or hidden using its “Show” checkbox. Calculations automatically follow the chart timeframe: daily charts use daily EMAs, weekly charts use weekly EMAs, and the same applies to monthly, yearly, and intraday charts.
The interface separates controls into three areas:
- EMA Settings: Adjust periods and enable or disable individual lines.
- Style: Customize each line’s color, width, and line style.
- Panel Settings: Show or hide the compact EMA panel and choose any of the four chart corners.
The panel displays only enabled EMAs, pairing each period with its latest value. It updates as the latest bar changes; it does not follow the mouse cursor. Historical values can be viewed in TradingView’s native Data Window.
Designed for comparing short-, medium-, and long-term trends with a customizable chart layout. This indicator does not generate buy or sell signals.
-------------------------------------------------------------------------------------------
**Flex EMA Ribbon — 10 Customizable Lines（可调 EMA 均线带）**是一款在价格主图上显示最多 10 条指数移动平均线（EMA）的趋势观察指标。
默认周期为 5、10、20、30、50、60、100、120、200、250。每条均线的周期均可独立修改，也可以通过“Show”复选框单独显示或隐藏。计算周期自动跟随图表：日线图使用日 EMA，周线图使用周 EMA，同样适用于月线、年线及盘中周期。
界面分为三个设置区域：
- **EMA Settings（均线设置）：**修改周期，开启或关闭各条均线。
- **Style（样式）：**调整每条线的颜色、粗细和线型。
- **Panel Settings（面板设置）：**显示或隐藏简洁的数据面板，并选择放在图表的四个角落之一。
数据面板仅显示已启用的均线，并列出实际周期和最新 EMA 数值。面板随最新 K 线变化更新，不跟随鼠标移动；历史数值可通过 TradingView 原生数据窗口查看。
适合对比短、中、长期趋势，并根据个人习惯调整图表布局。本指标不生成买卖信号。

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © huajunweng

//@version=6
indicator("Flex EMA Ribbon — 10 Customizable Lines",
     shorttitle="Flex EMA", overlay=true)

// Calculations follow the chart timeframe.
// Each period represents a number of chart bars.
// Customize line colors and widths in Settings > Style.
// The panel displays enabled EMAs at the latest chart bar.

// ===== EMA Settings =====
show1 = input.bool(true, "Show", inline="L1", group="EMA Settings")
len1 = input.int(5, "EMA 1 Period", minval=1,
     inline="L1", group="EMA Settings", display=display.none)

show2 = input.bool(true, "Show", inline="L2", group="EMA Settings")
len2 = input.int(10, "EMA 2 Period", minval=1,
     inline="L2", group="EMA Settings", display=display.none)

show3 = input.bool(true, "Show", inline="L3", group="EMA Settings")
len3 = input.int(20, "EMA 3 Period", minval=1,
     inline="L3", group="EMA Settings", display=display.none)

show4 = input.bool(true, "Show", inline="L4", group="EMA Settings")
len4 = input.int(30, "EMA 4 Period", minval=1,
     inline="L4", group="EMA Settings", display=display.none)

show5 = input.bool(true, "Show", inline="L5", group="EMA Settings")
len5 = input.int(50, "EMA 5 Period", minval=1,
     inline="L5", group="EMA Settings", display=display.none)

show6 = input.bool(true, "Show", inline="L6", group="EMA Settings")
len6 = input.int(60, "EMA 6 Period", minval=1,
     inline="L6", group="EMA Settings", display=display.none)

show7 = input.bool(true, "Show", inline="L7", group="EMA Settings")
len7 = input.int(100, "EMA 7 Period", minval=1,
     inline="L7", group="EMA Settings", display=display.none)

show8 = input.bool(true, "Show", inline="L8", group="EMA Settings")
len8 = input.int(120, "EMA 8 Period", minval=1,
     inline="L8", group="EMA Settings", display=display.none)

show9 = input.bool(true, "Show", inline="L9", group="EMA Settings")
len9 = input.int(200, "EMA 9 Period", minval=1,
     inline="L9", group="EMA Settings", display=display.none)

show10 = input.bool(true, "Show", inline="L10", group="EMA Settings")
len10 = input.int(250, "EMA 10 Period", minval=1,
     inline="L10", group="EMA Settings", display=display.none)

// ===== Panel Settings =====
showPanel = input.bool(true, "Show EMA Panel", group="Panel Settings")

panelLocation = input.string("Top Right", "Panel Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     group="Panel Settings", display=display.none)

panelPosition = switch panelLocation
    "Top Left" => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left" => position.bottom_left
    => position.top_right

// ===== EMA Calculations =====
ema1 = ta.ema(close, len1)
ema2 = ta.ema(close, len2)
ema3 = ta.ema(close, len3)
ema4 = ta.ema(close, len4)
ema5 = ta.ema(close, len5)
ema6 = ta.ema(close, len6)
ema7 = ta.ema(close, len7)
ema8 = ta.ema(close, len8)
ema9 = ta.ema(close, len9)
ema10 = ta.ema(close, len10)

// ===== EMA Plots =====
// Constant plot colors keep Style color pickers available.
// Disabled EMAs are hidden from the chart and Data Window.

plot(ema1, title="EMA 1", color=color.red, linewidth=1,
     editable=true, display=show1 ? display.all : display.none)

plot(ema2, title="EMA 2", color=color.orange, linewidth=1,
     editable=true, display=show2 ? display.all : display.none)

plot(ema3, title="EMA 3", color=color.yellow, linewidth=2,
     editable=true, display=show3 ? display.all : display.none)

plot(ema4, title="EMA 4", color=color.lime, linewidth=1,
     editable=true, display=show4 ? display.all : display.none)

plot(ema5, title="EMA 5", color=color.green, linewidth=2,
     editable=true, display=show5 ? display.all : display.none)

plot(ema6, title="EMA 6", color=color.aqua, linewidth=2,
     editable=true, display=show6 ? display.all : display.none)

plot(ema7, title="EMA 7", color=color.teal, linewidth=2,
     editable=true, display=show7 ? display.all : display.none)

plot(ema8, title="EMA 8", color=color.blue, linewidth=2,
     editable=true, display=show8 ? display.all : display.none)

plot(ema9, title="EMA 9", color=color.fuchsia, linewidth=3,
     editable=true, display=show9 ? display.all : display.none)

plot(ema10, title="EMA 10", color=color.purple, linewidth=3,
     editable=true, display=show10 ? display.all : display.none)

// ===== Selected EMA Panel =====
// Avoid color.new() with chart colors to preserve Style color pickers.

var table emaPanel = table.new(panelPosition, 2, 11)

if barstate.islast
    table.clear(emaPanel, 0, 0, 1, 10)

    if showPanel
        enabled = array.from(
             show1, show2, show3, show4, show5,
             show6, show7, show8, show9, show10)

        periods = array.from(
             len1, len2, len3, len4, len5,
             len6, len7, len8, len9, len10)

        values = array.from(
             ema1, ema2, ema3, ema4, ema5,
             ema6, ema7, ema8, ema9, ema10)

        int row = 1

        for i = 0 to 9
            if array.get(enabled, i)
                if row == 1
                    table.cell(emaPanel, 0, 0, "EMA",
                         text_color=chart.fg_color,
                         bgcolor=color.new(color.gray, 85),
                         text_size=size.small)

                    table.cell(emaPanel, 1, 0, "Value",
                         text_color=chart.fg_color,
                         bgcolor=color.new(color.gray, 85),
                         text_size=size.small)

                periodText = "EMA " + str.tostring(array.get(periods, i))
                emaValue = array.get(values, i)
                valueText = na(emaValue) ? "N/A" : str.tostring(emaValue, format.mintick)

                table.cell(emaPanel, 0, row, periodText,
                     text_color=chart.fg_color,
                     bgcolor=chart.bg_color,
                     text_size=size.small)

                table.cell(emaPanel, 1, row, valueText,
                     text_color=chart.fg_color,
                     bgcolor=chart.bg_color,
                     text_size=size.small)

                row += 1
````
