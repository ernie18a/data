# QAI-Visible Range High/Low

- url: https://www.tradingview.com/script/MK52GO1r/
- type: indicator
- pine_id: PUB;c128e74337444fd6a9baff394cf7d05b
- version: 2.0

## Description

QAI-Visible Range High/Low

QAI-Visible Range High/Low is a professional overlay indicator for TradingView, meticulously developed by 无秋⁶⁶⁶. It solves the common pain point of manually identifying price extremes while zooming or panning charts by automatically detecting and labeling the highest and lowest prices within the currently visible chart range.

[b]Core Value[/b]

Powered by the official PineCoders VisibleChart library, the indicator dynamically calculates the exact high and low across all bars visible on screen. Labels are intelligently auto-positioned with collision-avoidance offset, fully customizable in style, color, size, and content (price only or price + timestamp), and support bilingual Chinese/English display with rich tooltips.

[b]Key Features[/b]

[list]
[*]Smart High/Low Labels: Automatically marks the visible-range high and low with multiple visual styles (arrows, box, or none). Labels can display price + time in both Chinese and English, complete with detailed bilingual tooltips.
[*]Multi-Statistics Dashboard: Optional professional panel showing visible-range Open, Close, % Change, Volume, Volatility, plus daily Open/Close prices for instant market context.
[*]Extensive Customization: Label colors, text colors (static or dynamic based on last candle direction), sizes (tiny to huge), offset multiplier, and minimal mode can all be fine-tuned to match any trading style or screen setup.
[*]Professional Craftsmanship: Clean UI, built-in educational tooltips, copyright protection, and bilingual interface designed for serious traders.
[/list]

[b]Ideal Use Cases[/b]

Day trading & swing trading: Instantly identify support/resistance, breakout levels, and potential reversal zones in the current view.
Technical analysis & strategy backtesting: Combine with other indicators for faster, more confident decision-making.
Multi-timeframe workflows: Works seamlessly across 5-minute, 15-minute, daily, or any other timeframe.

[b]Recommended Settings[/b]

Use arrow styles + dynamic text color in trending markets; increase offset multiplier in ranging markets to prevent label overlap; keep the statistics panel off during live trading for a cleaner chart and turn it on only when reviewing data.

This script is intended for educational and learning purposes only. Trading involves substantial risk of loss. Always perform your own due diligence and consult a qualified financial advisor before making any investment decisions.

© 无秋⁶⁶⁶ | QAI Indicator Series

## Source Code

````pine
// © 无秋⁶⁶⁶ | 秋AI-可视高低点 | QAI-Visible Range High/Low

//@version=6
indicator(title="秋AI-可视高低点 | QAI-Visible Range High/Low", 
          shorttitle="秋AI-可视高低点 | QAI-Visible Range High/Low", 
          overlay=true, 
          max_labels_count=50)

// ──────────────────────────────────────────────────────────────
//  导入库
// ──────────────────────────────────────────────────────────────
import PineCoders/VisibleChart/5 as PCVC 

// ──────────────────────────────────────────────────────────────
//  保留设置
// ──────────────────────────────────────────────────────────────
highLabelColor = input.color(color.rgb(0, 165, 49, 0), title="最高价标签背景色\nHigh Label Color", tooltip="【最高价标签背景颜色】\n科普：此颜色用于显示当前屏幕可见K线区间中最高价的标签背景。\nNewbie Tip：透明度建议保持在0-30之间（默认0=完全不透明）。\n实战建议：绿色系代表多头强势/阻力位。\n推荐参数：默认完全不透明 #00A531。\n\nEnglish: Background color of the Visible Range High label. Default: fully opaque.")

highTextColor = input.color(color.white, title="最高价标签文字颜色\nHigh Text Color", tooltip="【最高价标签文字颜色】\n科普：控制最高价标签上显示的价格数字颜色。\nNewbie Tip：必须与背景形成高对比度。\n实战建议：纯白色在绝大多数背景下清晰度最高。\n推荐参数：默认白色。\n\nEnglish: Text color of the price displayed on the High label.")

lowLabelColor = input.color(color.rgb(255, 109, 90, 0), title="最低价标签背景色\nLow Label Color", tooltip="【最低价标签背景颜色】\n科普：此颜色用于显示当前屏幕可见K线区间中最低价的标签背景。\nNewbie Tip：透明度建议0-30（默认完全不透明）。\n实战建议：红色系代表空头支撑位。\n推荐参数：默认完全不透明 #FF6D5A。\n\nEnglish: Background color of the Visible Range Low label. Default: fully opaque.")

lowTextColor = input.color(color.white, title="最低价标签文字颜色\nLow Text Color", tooltip="【最低价标签文字颜色】\n科普：控制最低价标签上显示的价格数字颜色。\nNewbie Tip：文字颜色需与背景对比强烈。\n实战建议：白色最友好。\n推荐参数：默认白色。\n\nEnglish: Text color of the price displayed on the Low label.")

labelSizeStr = input.string("small", title="标签大小 / Label Size", options=["tiny", "small", "normal", "large", "huge"], tooltip="【气泡标签大小】\n科普：控制标签整体大小。\nNewbie Tip：默认Small适合大多数图表。\n实战建议：Large适合大屏幕。\n推荐参数：默认 Small。\n\nEnglish: Size of the on-chart labels. Default: Small.")

offsetMultiplier = input.float(0.015, title="标签避让距离倍数\nLabel Offset Multiplier", minval=0.0, maxval=0.1, step=0.001, tooltip="【标签位置自动避让】\n科普：根据可见范围自动偏移，避免高低标签重叠。\nNewbie Tip：默认0.015即可清晰分离。\n实战建议：窄幅震荡市调高至0.025。\n推荐参数：默认0.015。\n\nEnglish: Auto-avoidance multiplier. Default 0.015.")

// 已移除「标签样式」选项（原逻辑无效），现固定使用最直观的箭头样式：
// 最高点标签使用向下箭头，最低点标签使用向上箭头，视觉指向更清晰专业。

showTimeInLabel = input.bool(true, title="标签内显示时间 / Show Time in Label", tooltip="【是否在标签文字中显示时间】\n科普：开启后标签将同时显示价格 + 时间（中英双语）。\nNewbie Tip：关闭可让标签更简洁。\n实战建议：短线交易建议开启。\n推荐参数：默认开启。\n\nEnglish: Show bar time inside the label text.")

minimalMode = input.bool(false, title="极简模式 / Minimal Mode", tooltip="【一键极简模式】\n科普：开启后标签只显示价格数字。\nNewbie Tip：适合屏幕空间紧张的交易者。\n实战建议：适合需要极简界面的场景。\n推荐参数：默认关闭。\n\nEnglish: Minimal mode - only shows price number.")

dynamicTextColor = input.bool(false, title="动态文字颜色跟随K线涨跌 / Dynamic Text Color", tooltip="【动态文字颜色】\n科普：开启后文字颜色自动跟随最后一根K线颜色（涨=绿 / 跌=红）。\nNewbie Tip：关闭则使用手动设置的颜色。\n实战建议：趋势跟踪者推荐开启。\n推荐参数：默认关闭。\n\nEnglish: Text color automatically follows last candle color.")

// ──────────────────────────────────────────────────────────────
//  Multi Stat 设置
// ──────────────────────────────────────────────────────────────
showMultiStat = input.bool(false, title="显示可见范围统计面板 / Show Multi Stat Panel", tooltip="【可见范围统计面板开关】\n科普：开启后显示Open/Close/涨跌幅/成交量/波动率 + 日线数据。\nNewbie Tip：默认关闭，可一键开启。\n实战建议：需要时再打开，避免图表过乱。\n推荐参数：默认关闭。\n\nEnglish: Show multi-stat dashboard. Default: hidden.")

tablePositionStr = input.string("Top Right", title="统计面板位置 / Table Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], tooltip="【统计面板位置】\n科普：控制统计表格显示位置。\nNewbie Tip：Top Right 最常用。\n推荐参数：默认 Top Right。\n\nEnglish: Position of the multi-stat table.")

showOpen   = input.bool(true,  title="显示开盘价 / Show Open", tooltip="【显示可见范围开盘价】\n推荐参数：默认开启。\n\nEnglish: Show visible range Open price.")
showClose  = input.bool(true,  title="显示收盘价 / Show Close", tooltip="【显示可见范围收盘价】\n推荐参数：默认开启。\n\nEnglish: Show visible range Close price.")
showChange = input.bool(true,  title="显示涨跌幅% / Show Change %", tooltip="【显示可见范围涨跌幅%】\n推荐参数：默认开启。\n\nEnglish: Show visible range percentage change.")
showVolume = input.bool(true,  title="显示成交量 / Show Volume", tooltip="【显示可见范围成交量】\n推荐参数：默认开启。\n\nEnglish: Show visible range total volume.")
showVolatility = input.bool(true, title="显示波动率% / Show Volatility %", tooltip="【显示可见范围波动率%】\n推荐参数：默认开启。\n\nEnglish: Show visible range volatility % (proxy for ATR).")

// ──────────────────────────────────────────────────────────────
//  日线数据 + 可见范围数据
// ──────────────────────────────────────────────────────────────
dailyOpen  = request.security(syminfo.tickerid, "D", open)
dailyClose = request.security(syminfo.tickerid, "D", close)

[chartOpen, chartHigh, chartLow, chartClose, chartVolume] = PCVC.ohlcv()
int highTime = PCVC.highBarTime()
int lowTime  = PCVC.lowBarTime()

// ──────────────────────────────────────────────────────────────
//  创建标签 + 统计面板
// ──────────────────────────────────────────────────────────────
var label highLabel = label.new(x=na, y=na, text=na, xloc=xloc.bar_time, yloc=yloc.price, color=highLabelColor, style=label.style_label_down, textcolor=highTextColor, size=size.small, textalign=text.align_center)
var label lowLabel  = label.new(x=na, y=na, text=na, xloc=xloc.bar_time, yloc=yloc.price, color=lowLabelColor, style=label.style_label_up, textcolor=lowTextColor, size=size.small, textalign=text.align_center)

var table statsTable = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 0), border_width=1, border_color=color.new(color.white, 80))

// ──────────────────────────────────────────────────────────────
//  实时更新
// ──────────────────────────────────────────────────────────────
if barstate.islast
    // 1. VR 高低点标签（永不消失）
    float visRange = chartHigh - chartLow
    float offset   = visRange * offsetMultiplier
    label.set_xy(highLabel, highTime, chartHigh + offset)
    label.set_xy(lowLabel,  lowTime,  chartLow  - offset)

    // 标签样式已固定为箭头样式（最高点向下箭头，最低点向上箭头），视觉指向清晰专业

    string highText = minimalMode ? str.tostring(chartHigh, format.mintick) : "当前最高点 / Current High\n" + str.tostring(chartHigh, format.mintick) + (showTimeInLabel ? "\n" + str.format("{0,date,HH:mm}", highTime) : "")
    string lowText  = minimalMode ? str.tostring(chartLow, format.mintick)  : "当前最低点 / Current Low\n"  + str.tostring(chartLow, format.mintick)  + (showTimeInLabel ? "\n" + str.format("{0,date,HH:mm}", lowTime) : "")
    label.set_text(highLabel, highText)
    label.set_text(lowLabel, lowText)

    color finalHighTextColor = dynamicTextColor and chartClose > chartOpen ? color.new(color.green, 0) : highTextColor
    color finalLowTextColor  = dynamicTextColor and chartClose < chartOpen ? color.new(color.red, 0)   : lowTextColor
    label.set_color(highLabel, highLabelColor)
    label.set_textcolor(highLabel, finalHighTextColor)
    label.set_color(lowLabel, lowLabelColor)
    label.set_textcolor(lowLabel, finalLowTextColor)

    label_size = labelSizeStr == "tiny" ? size.tiny : labelSizeStr == "small" ? size.small : labelSizeStr == "normal" ? size.normal : labelSizeStr == "large" ? size.large : size.huge
    label.set_size(highLabel, label_size)
    label.set_size(lowLabel, label_size)

    label.set_tooltip(highLabel, "📈 可见范围最高价\nVisible Range High\n\n价格 / Price: " + str.tostring(chartHigh, format.mintick) + "\n时间 / Time: " + str.format("{0,date,yyyy-MM-dd HH:mm}", time) + "\n\n这是当前屏幕可见K线区间中的最高点\nThis is the highest price in the currently visible chart area.")
    label.set_tooltip(lowLabel,  "📉 可见范围最低价\nVisible Range Low\n\n价格 / Price: "  + str.tostring(chartLow, format.mintick)  + "\n时间 / Time: " + str.format("{0,date,yyyy-MM-dd HH:mm}", time)  + "\n\n这是当前屏幕可见K线区间中的最低点\nThis is the lowest price in the currently visible chart area.")

    // 2. 统计面板
    if showMultiStat
        table_position = tablePositionStr == "Top Left" ? position.top_left : tablePositionStr == "Top Right" ? position.top_right : tablePositionStr == "Bottom Left" ? position.bottom_left : position.bottom_right
        table.set_position(statsTable, table_position)
        table.clear(statsTable, 0, 0)

        table.cell(statsTable, 0, 0, "统计项\nStat", text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.small)
        table.cell(statsTable, 1, 0, "数值\nValue", text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.small)

        row = 1
        if showOpen
            table.cell(statsTable, 0, row, "可见范围开盘 / Visible Open", text_color=color.white, text_size=size.small)
            table.cell(statsTable, 1, row, str.tostring(chartOpen, format.mintick), text_color=color.white, text_size=size.small)
            row += 1
        if showClose
            table.cell(statsTable, 0, row, "可见范围收盘 / Visible Close", text_color=color.white, text_size=size.small)
            table.cell(statsTable, 1, row, str.tostring(chartClose, format.mintick), text_color=color.white, text_size=size.small)
            row += 1
        if showChange
            changePct = (chartClose - chartOpen) / chartOpen * 100
            changeColor = changePct >= 0 ? color.new(color.green, 0) : color.new(color.red, 0)
            table.cell(statsTable, 0, row, "涨跌幅 / Change %", text_color=color.white, text_size=size.small)
            table.cell(statsTable, 1, row, str.tostring(changePct, "0.00") + "%", text_color=changeColor, text_size=size.small)
            row += 1
        if showVolume
            table.cell(statsTable, 0, row, "成交量 / Volume", text_color=color.white, text_size=size.small)
            volM = str.tostring(chartVolume / 1000000, "0.00") + "M"
            table.cell(statsTable, 1, row, volM, text_color=color.white, text_size=size.small)
            row += 1
        if showVolatility
            volatilityPct = (chartHigh - chartLow) / chartClose * 100
            table.cell(statsTable, 0, row, "波动率 / Volatility %", text_color=color.white, text_size=size.small)
            table.cell(statsTable, 1, row, str.tostring(volatilityPct, "0.00") + "%", text_color=color.white, text_size=size.small)
            row += 1
        table.cell(statsTable, 0, row, "日线开盘价 / Daily Open", text_color=color.white, text_size=size.small)
        table.cell(statsTable, 1, row, str.tostring(dailyOpen, format.mintick), text_color=color.white, text_size=size.small)
        row += 1
        table.cell(statsTable, 0, row, "日线收盘价 / Daily Close", text_color=color.white, text_size=size.small)
        table.cell(statsTable, 1, row, str.tostring(dailyClose, format.mintick), text_color=color.white, text_size=size.small)
        row += 1

// ──────────────────────────────────────────────────────────────
//  版权声明
// ──────────────────────────────────────────────────────────────
// © 无秋⁶⁶⁶
// 秋AI-可视高低点 | QAI-Visible Range High/Low
// 本脚本仅供学习交流使用，交易有风险，投资需谨慎。
// This script is for educational purposes only. Trading involves risk.
````
