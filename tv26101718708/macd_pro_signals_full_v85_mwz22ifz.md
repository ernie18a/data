# MACD Pro Signals Full v8.5

- url: https://www.tradingview.com/script/MWZ22IFz/
- type: indicator
- pine_id: PUB;d416683649364fa2aa144feed09e8b0c
- version: 1.0

## Description

2. Detailed Description (Large Text Box)
🌟 Indicator Introduction
This is a full-featured enhanced MACD indicator. Based on the classic MACD formula, it adds advanced visual upgrades, signal enhancements, and automatic divergence detection. It is suitable for all markets such as Stocks, Futures, Forex, and Cryptocurrencies.
It helps you quickly identify trends, momentum, trading signals, and reversal opportunities at a glance.
✨ Core Features
Color-Coded Momentum HistogramAutomatically distinguishes 4 states: Strong Bullish / Weak Bullish / Strong Bearish / Weak Bearish.Clearly shows the strength of current momentum and trend continuity, making it easy to judge whether the price is accelerating or weakening.
MACD & Signal Line Candle VisualizationConverts the traditional MACD line and Signal line into candlestick style.The color changes automatically with upward/downward trends, making trend turning points and momentum more intuitive than traditional lines.
Dual-Position Golden/Death Cross Markers
Main Chart: Displays "👍" (Golden Cross) and "👎" (Death Cross) above/below price bars for clear entry signals.
Subwindow: Synchronous markers on the MACD area, no overlap on the main chart, double confirmation without missing signals.
Auto Bullish/Bearish Divergence DetectionAutomatically scans price and MACD divergence structures.Draws divergence lines in the subwindow and marks strength percentage (0-100%) on the main chart.Perfect for capturing high-probability trend reversals.
Full CustomizationSupports adjusting MACD periods, all element colors, label offsets, and pivot parameters.Adaptable to different assets and time frames.
📊 How to Use
Bullish Signal: Golden Cross 👍 + Zero Line Above + Expanding Bullish Histogram + Bullish Divergence = Strong Long Opportunity
Bearish Signal: Death Cross 👎 + Zero Line Below + Expanding Bearish Histogram + Bearish Divergence = Strong Short Opportunity
Divergence Usage: The higher the percentage, the stronger the divergence signal, and the higher the probability of a trend reversal.

## Source Code

````pine
//@version=6
indicator("MACD Pro 信号全开 v8.5", shorttitle="MACD v8.5", overlay=false, precision=4, max_labels_count=500, max_lines_count=500)

// ====================== 【1. 参数与颜色】 ======================
gParam = "MACD参数", gColor = "颜色自定义", gSignal = "信号调节"

src     = input.source(close, "数据源", group=gParam)
lenFast = input.int(12, "快线", group=gParam)
lenSlow = input.int(26, "慢线", group=gParam)
lenSig  = input.int(9,  "信号", group=gParam)

// 动能柱颜色
hUpStrong = input.color(#26a69a, "多头柱-强", group=gColor), hUpWeak = input.color(#b2dfdb, "多头柱-衰", group=gColor)
hDnStrong = input.color(#ff5252, "空头柱-强", group=gColor), hDnWeak = input.color(#ffcdd2, "空头柱-衰", group=gColor)

// 快慢线K线颜色
macdUp = input.color(color.lime, "快线-升"), macdDn = input.color(color.red, "快线-降")
sigUp  = input.color(color.aqua, "慢线-升"), sigDn  = input.color(color.fuchsia, "慢线-降")

// 手指位置调节
mainLabelOffset = input.float(0.003, "主图手指贴合度", minval=0, maxval=0.05, step=0.001, group=gSignal)
subLabelOffset  = input.float(0.05, "副图手指偏移量", minval=0, maxval=1, step=0.01, group=gSignal)

// 背离参数
lbL = input.int(5, "左拐点K数", group=gSignal)
lbR = input.int(2, "右确认K数", group=gSignal)
strengthPeriod = input.int(50, "强度计算周期", group=gSignal)

// ====================== 【2. 核心计算】 ======================
mac  = ta.ema(src, lenFast) - ta.ema(src, lenSlow)
sig  = ta.ema(mac, lenSig)
hist = mac - sig

// ====================== 【3. 副图绘制】 ======================
// 动能柱
plot(hist, "动能柱", hist >= 0 ? (hist > hist[1] ? hUpStrong : hUpWeak) : (hist < hist[1] ? hDnStrong : hDnWeak), style = plot.style_columns)

// 慢线K线
sigColor = sig > sig[1] ? sigUp : sigDn
plotcandle(open=sig[1], close=sig, high=sig, low=sig[1], color=color.new(sigColor, 40), bordercolor=color.new(sigColor, 20), title="信号K线")

// 快线K线
macColor = mac >= mac[1] ? macdUp : macdDn
plotcandle(open=mac[1], close=mac, high=mac, low=mac[1], color=macColor, bordercolor=color.new(macColor, 10), title="快线K线")

// 零轴
hline(0, "零轴", color.new(color.gray, 50))

// ====================== 【4. 金叉死叉手指】 ======================
goldCross = ta.crossover(mac, sig)
deadCross = ta.crossunder(mac, sig)

// 主图手指
if goldCross
    label.new(bar_index, low * (1 - mainLabelOffset), "👍", yloc=yloc.price, color=color.new(color.yellow, 100), textcolor=#FFEB3B, style=label.style_label_up, size=size.normal, force_overlay=true)

if deadCross
    label.new(bar_index, high * (1 + mainLabelOffset), "👎", yloc=yloc.price, color=color.new(color.yellow, 100), textcolor=#FFEB3B, style=label.style_label_down, size=size.normal, force_overlay=true)

// 副图手指
if goldCross
    label.new(bar_index, mac - subLabelOffset, "👍", color=color.new(color.yellow, 100), textcolor=#FFEB3B, style=label.style_label_up, size=size.small)

if deadCross
    label.new(bar_index, mac + subLabelOffset, "👎", color=color.new(color.yellow, 100), textcolor=#FFEB3B, style=label.style_label_down, size=size.small)

// ====================== 【5. 背离信号】 ======================
ph = ta.pivothigh(mac, lbL, lbR)
pl = ta.pivotlow(mac, lbL, lbR)

maxH = ta.highest(math.abs(hist), strengthPeriod)
strength = math.round(math.abs(hist) / (maxH == 0 ? 1 : maxH) * 100)

var float lastPlMac = na
var float lastPlLow = na
var float lastPhMac = na
var float lastPhHigh = na

barsSincePl = ta.barssince(not na(pl))
barsSincePh = ta.barssince(not na(ph))

// 底背离
if not na(pl)
    currentPlMac = mac[lbR]
    currentPlLow = low[lbR]
    
    if not na(lastPlMac) and currentPlLow < lastPlLow and currentPlMac > lastPlMac
        line.new(bar_index[barsSincePl + lbR], lastPlMac, bar_index[lbR], currentPlMac, color=color.new(color.lime, 0), width=2)
        label.new(bar_index[lbR], currentPlLow, "▲\n" + str.tostring(strength) + "%", yloc=yloc.belowbar, color=color.new(color.green, 30), textcolor=color.white, style=label.style_label_up, size=size.small, force_overlay=true)
    
    lastPlMac := currentPlMac
    lastPlLow := currentPlLow

// 顶背离
if not na(ph)
    currentPhMac = mac[lbR]
    currentPhHigh = high[lbR]
    
    if not na(lastPhMac) and currentPhHigh > lastPhHigh and currentPhMac < lastPhMac
        line.new(bar_index[barsSincePh + lbR], lastPhMac, bar_index[lbR], currentPhMac, color=color.new(color.red, 0), width=2)
        label.new(bar_index[lbR], currentPhHigh, "▼\n" + str.tostring(strength) + "%", yloc=yloc.abovebar, color=color.new(color.red, 30), textcolor=color.white, style=label.style_label_down, size=size.small, force_overlay=true)
    
    lastPhMac := currentPhMac
    lastPhHigh := currentPhHigh
````
