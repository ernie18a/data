# SMMA13K

- url: https://www.tradingview.com/script/KF200dxx/
- type: indicator
- pine_id: PUB;0a88b776312a4f8da7e6cdd28316ce04
- version: 1.0

## Description

SMMA13 变色K线

## Source Code

````pine
//@version=5
indicator("SMMA13 变色K线", overlay=true, shorttitle="SMMA13-K", precision=2)

// 1. 参数设置
len = input.int(13, minval=1, title="SMMA 周期")
src = input(close, title="Source")

// 2. 手动实现 SMMA 计算
smmaValue = 0.0
smmaValue := na(smmaValue[1]) ? ta.sma(src, len) : (smmaValue[1] * (len - 1) + src) / len

// 3. 判断上穿、下穿
crossUp  = ta.crossover(close, smmaValue)  // 收盘价上穿SMMA13
crossDn  = ta.crossunder(close, smmaValue) // 收盘价下穿SMMA13
above    = close > smmaValue               // 价格在均线上方
below    = close < smmaValue               // 价格在均线下方

// 4. K线颜色逻辑：上穿/在上方=蓝色，下穿/在下方=红色
kColor = below ? color.red : color.blue

// 5. 均线颜色逻辑：先声明变量，再递推赋值
var color maColor = color.gray // 初始默认颜色为灰色
maColor := crossUp ? color.blue : crossDn ? color.red : maColor[1]

// 6. 绘制变色K线和均线
plotcandle(open, high, low, close, color=kColor, wickcolor=kColor)
plot(smmaValue, color=maColor, title="SMMA13", linewidth=2)
````
