<!-- tradingview-pine-id: PUB;99fe13d083ea42fe9eae0ed433ef0a81 -->
<!-- tradingviewscripts-format: 1 -->
# VWAP1

Source: https://www.tradingview.com/script/6cPQ8YZo/

## Description

vwap:hlc/3
three brand
two session:Assian/American

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © w2305991845
//@version=6
indicator("VWAP1", overlay=true, max_bars_back=5000)

// ============ 输入 ============
tzInput = input.string("UTC+2", "时区 (需与图表右下角时区一致)", group="计算设置", tooltip="必须和你图表右下角显示的时区一致，否则时段会错位")

sess1 = input.session("0000-1429", "时段1 (00:00-14:29:59)", group="计算设置")
sess2 = input.session("1430-2359", "时段2 (14:30-23:59)", group="计算设置")

mult1 = input.float(0.5, "带宽倍数1", step=0.1, group="计算设置")
mult2 = input.float(1.5, "带宽倍数2", step=0.1, group="计算设置")
mult3 = input.float(2.0, "带宽倍数3", step=0.1, group="计算设置")

showDivider = input.bool(true, "显示分割线", group="计算设置")

// ============ 颜色 (每条线独立，可在"样式"面板单独调) ============
vwapColor = input.color(color.new(color.blue, 0), "VWAP 主线", group="样式颜色")
col1Up = input.color(color.new(#2962FF, 40), "±0.5 上轨", group="样式颜色")
col1Dn = input.color(color.new(#2962FF, 40), "±0.5 下轨", group="样式颜色")
col2Up = input.color(color.new(#FF6D00, 50), "±1.5 上轨", group="样式颜色")
col2Dn = input.color(color.new(#FF6D00, 50), "±1.5 下轨", group="样式颜色")
col3Up = input.color(color.new(#9C27B0, 60), "±2.0 上轨", group="样式颜色")
col3Dn = input.color(color.new(#9C27B0, 60), "±2.0 下轨", group="样式颜色")
colDiv = input.color(color.new(color.gray, 30), "分割线", group="样式颜色")

fillOn = input.bool(true, "填充±0.5内部区域", group="样式颜色")
fillColor = input.color(color.new(#2962FF, 92), "填充颜色", group="样式颜色")

// ============ 计算源: 直接用图表原生数据，不经过request.security，避免滞后/偏移 ============
srcInput = (high + low + close) / 3
volInput = volume

// ============ 时段判断 (显式传入时区) ============
inSess1 = not na(time(timeframe.period, sess1, tzInput))
inSess2 = not na(time(timeframe.period, sess2, tzInput))
inAnySess = inSess1 or inSess2

// 排除脚本运行的第一根K线，避免历史数据加载不全时误判"新时段"
newSess1 = inSess1 and not inSess1[1] and not barstate.isfirst
newSess2 = inSess2 and not inSess2[1] and not barstate.isfirst
newSess  = newSess1 or newSess2

// ============ 累积变量 ============
var float sumPV  = 0.0
var float sumV   = 0.0
var float sumPV2 = 0.0
var bool validStart = false   // 是否已经历过一次真实的时段起点

if newSess
    sumPV  := 0.0
    sumV   := 0.0
    sumPV2 := 0.0
    validStart := true

// ============ VWAP + 带宽计算 ============
float vwap    = na
float devUp1  = na
float devDn1  = na
float devUp2  = na
float devDn2  = na
float devUp3  = na
float devDn3  = na

if inAnySess
    sumPV  := sumPV + srcInput * volInput
    sumV   := sumV + volInput
    sumPV2 := sumPV2 + volInput * math.pow(srcInput, 2)
    vwap := sumV != 0 ? sumPV / sumV : na
    variance = sumV != 0 ? (sumPV2 / sumV) - math.pow(vwap, 2) : na
    stdev = variance > 0 ? math.sqrt(variance) : 0.0
    devUp1 := vwap + mult1 * stdev
    devDn1 := vwap - mult1 * stdev
    devUp2 := vwap + mult2 * stdev
    devDn2 := vwap - mult2 * stdev
    devUp3 := vwap + mult3 * stdev
    devDn3 := vwap - mult3 * stdev

// 只有确认经历过真实时段起点后才输出，避免加载不全时显示错误数据
plotVwap = validStart ? vwap : na
plotUp1  = validStart ? devUp1 : na
plotDn1  = validStart ? devDn1 : na
plotUp2  = validStart ? devUp2 : na
plotDn2  = validStart ? devDn2 : na
plotUp3  = validStart ? devUp3 : na
plotDn3  = validStart ? devDn3 : na

// ============ 绘图 ============
p_vwap = plot(plotVwap, "VWAP", vwapColor, 2)
p_up1  = plot(plotUp1, "上轨0.5", col1Up, 1)
p_dn1  = plot(plotDn1, "下轨0.5", col1Dn, 1)
p_up2  = plot(plotUp2, "上轨1.5", col2Up, 1)
p_dn2  = plot(plotDn2, "下轨1.5", col2Dn, 1)
p_up3  = plot(plotUp3, "上轨2.0", col3Up, 1)
p_dn3  = plot(plotDn3, "下轨2.0", col3Dn, 1)

fill(p_up1, p_dn1, fillOn ? fillColor : na)

// ============ 分割线 ============
if showDivider and newSess
    line.new(bar_index, low, bar_index, high, xloc.bar_index, extend=extend.both, color=colDiv, style=line.style_dotted, width=1)
````
