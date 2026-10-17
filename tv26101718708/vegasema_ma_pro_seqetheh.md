# Vegas+ema ma Pro

- url: https://www.tradingview.com/script/sEqeTHeh/
- type: indicator
- pine_id: PUB;5a54e66cd93546bd9f6944739d4b6bf8
- version: 2.0

## Description

Vegas双通道 + 均线系统 Pro

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © qwe84fg

//@version=6
//@version=6
indicator("Vegas + 均线系统 Pro + RSI过滤", shorttitle="Vegas+MA+RSI", overlay=true)

// ======================================================
// Vegas 双通道
// ======================================================

a = input.int(12, title='Vegas过滤线')
b = input.int(144, title='Vegas A组1')
c = input.int(169, title='Vegas A组2')
d = input.int(576, title='Vegas B组1')
e = input.int(676, title='Vegas B组2')

vegasEma1 = ta.ema(close, a)
vegasEma2 = ta.ema(close, b)
vegasEma3 = ta.ema(close, c)
vegasEma4 = ta.ema(close, d)
vegasEma5 = ta.ema(close, e)

plot(vegasEma1, title='Vegas过滤线', color=color.green, linewidth=2)

pVegasA1 = plot(vegasEma2, title='Vegas A组1', color=color.blue, linewidth=2)
pVegasA2 = plot(vegasEma3, title='Vegas A组2', color=color.blue, linewidth=2)

pVegasB1 = plot(vegasEma4, title='Vegas B组1', color=color.red, linewidth=2)
pVegasB2 = plot(vegasEma5, title='Vegas B组2', color=color.red, linewidth=2)

fill(pVegasA1, pVegasA2, color=color.new(color.blue, 90))
fill(pVegasB1, pVegasB2, color=color.new(color.red, 92))

// ======================================================
// 均线系统
// ======================================================

sma20 = ta.sma(close, 20)
sma60 = ta.sma(close, 60)
sma120 = ta.sma(close, 120)
sma200 = ta.sma(close, 200)

ema20 = ta.ema(close, 20)
ema60 = ta.ema(close, 60)
ema120 = ta.ema(close, 120)
ema200 = ta.ema(close, 200)

p1 = plot(sma20, color=color.black, title='SMA20', linewidth=2)
p2 = plot(ema20, color=color.new(color.black, 50), title='EMA20')

p3 = plot(sma60, color=color.orange, title='SMA60', linewidth=2)
p4 = plot(ema60, color=color.new(color.orange, 50), title='EMA60')

p5 = plot(sma120, color=color.purple, title='SMA120', linewidth=2)
p6 = plot(ema120, color=color.new(color.purple, 50), title='EMA120')

p7 = plot(sma200, color=color.fuchsia, title='SMA200', linewidth=2)
p8 = plot(ema200, color=color.new(color.fuchsia, 50), title='EMA200')

fill(p1, p2, color=color.new(color.black, 92))
fill(p3, p4, color=color.new(color.orange, 92))
fill(p5, p6, color=color.new(color.purple, 92))
fill(p7, p8, color=color.new(color.fuchsia, 92))

// ======================================================
// RSI 过滤
// ======================================================

rsiLength = input.int(14, title="RSI周期")
rsiBull = input.int(55, title="多头RSI过滤")
rsiBear = input.int(45, title="空头RSI过滤")

rsi = ta.rsi(close, rsiLength)

// RSI状态
rsiStrong = rsi > rsiBull
rsiWeak = rsi < rsiBear

// ======================================================
// 趋势判断
// ======================================================

bull =
     ema20 > ema60 and
     ema60 > ema120 and
     ema120 > ema200 and
     rsiStrong

bear =
     ema20 < ema60 and
     ema60 < ema120 and
     ema120 < ema200 and
     rsiWeak

bgcolor(bull ? color.new(color.green, 93) : na)
bgcolor(bear ? color.new(color.red, 93) : na)

// ======================================================
// 金叉死叉 + RSI过滤
// ======================================================

golden =
     ta.crossover(ema20, ema60) and
     rsiStrong

death =
     ta.crossunder(ema20, ema60) and
     rsiWeak

plotshape(
     golden,
     title="RSI金叉",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.small
)

plotshape(
     death,
     title="RSI死叉",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.small
)

// ======================================================
// RSI 数值显示
// ======================================================

rsiColor =
     rsi >= 70 ? color.red :
     rsi <= 30 ? color.green :
     color.yellow

plotchar(rsi, title="RSI", char='•', location=location.top, color=rsiColor)

// ======================================================
// RSI 背离侦测
// ======================================================

pivotLen = input.int(5, title="背离Pivot长度")

// RSI
rsiValue = ta.rsi(close, rsiLength)

// Pivot High / Low
priceHigh = ta.pivothigh(high, pivotLen, pivotLen)
priceLow  = ta.pivotlow(low, pivotLen, pivotLen)

rsiHigh = ta.pivothigh(rsiValue, pivotLen, pivotLen)
rsiLow  = ta.pivotlow(rsiValue, pivotLen, pivotLen)

// 保存前一个高低点
var float prevPriceHigh = na
var float prevRsiHigh = na

var float prevPriceLow = na
var float prevRsiLow = na

// ======================================================
// 顶背离
// ======================================================

bearDiv = false

if not na(priceHigh) and not na(rsiHigh)

    bearDiv :=
         priceHigh > prevPriceHigh and
         rsiHigh < prevRsiHigh

    prevPriceHigh := priceHigh
    prevRsiHigh := rsiHigh

// ======================================================
// 底背离
// ======================================================

bullDiv = false

if not na(priceLow) and not na(rsiLow)

    bullDiv :=
         priceLow < prevPriceLow and
         rsiLow > prevRsiLow

    prevPriceLow := priceLow
    prevRsiLow := rsiLow

// ======================================================
// 背离标记
// ======================================================

plotshape(
     bullDiv,
     title="RSI底背离",
     style=shape.labelup,
     location=location.belowbar,
     color=color.lime,
     text="Bull Div",
     textcolor=color.black,
     size=size.small,
     offset=-pivotLen
)

plotshape(
     bearDiv,
     title="RSI顶背离",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="Bear Div",
     textcolor=color.white,
     size=size.small,
     offset=-pivotLen
)
// ======================================================
// Supertrend 过滤
// ======================================================

// 参数
stAtrLen = input.int(10, title="Supertrend ATR周期")
stFactor = input.float(3.0, title="Supertrend倍数", step=0.1)

// Supertrend
[supertrend, direction] = ta.supertrend(stFactor, stAtrLen)

// direction:
// -1 = 多头
//  1 = 空头

// 绘制Supertrend
plot(
     direction < 0 ? supertrend : na,
     title="Supertrend Bull",
     color=color.lime,
     linewidth=2,
     style=plot.style_linebr
)

plot(
     direction > 0 ? supertrend : na,
     title="Supertrend Bear",
     color=color.red,
     linewidth=2,
     style=plot.style_linebr
)

// ======================================================
// Supertrend 趋势过滤
// ======================================================

superBull = direction < 0
superBear = direction > 0

// ======================================================
// 超级趋势翻转信号
// ======================================================

superBuy =
     direction[1] > 0 and
     direction < 0

superSell =
     direction[1] < 0 and
     direction > 0

plotshape(
     superBuy,
     title="Supertrend Buy",
     style=shape.circle,
     location=location.belowbar,
     color=color.lime,
     size=size.small,
     text="ST"
)

plotshape(
     superSell,
     title="Supertrend Sell",
     style=shape.circle,
     location=location.abovebar,
     color=color.red,
     size=size.small,
     text="ST"
)
````
