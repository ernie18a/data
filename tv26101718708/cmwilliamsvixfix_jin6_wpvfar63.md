# CM_Williams_Vix_Fix - (jin6)

- url: https://www.tradingview.com/script/wPvFAR63/
- type: indicator
- pine_id: PUB;ab18d494b89e4211aa5c5c9eb42f122f
- version: 1.0

## Description

方便进行股票筛选器里进行筛选

## Source Code

````pine
//@version=6
indicator("CM_Williams_Vix_Fix - 筛选版", overlay=false)

pd = input(22, "LookBack Period")
bbl = input(20, "Bollinger Length")
mult = input.float(2.0, "SD Multiplier")
lb = input(50, "Percentile Lookback")
ph = input(.85, "Percentile")

// 计算底部信号（红色柱）
wvf = ((ta.highest(close, pd) - low) / ta.highest(close, pd)) * 100
sDev = mult * ta.stdev(wvf, bbl)
midLine = ta.sma(wvf, bbl)
upperBand = midLine + sDev
rangeHigh = ta.highest(wvf, lb) * ph
is_bottom = wvf >= upperBand or wvf >= rangeHigh

// 计算顶部信号（绿色柱）
wvf1 = ((ta.lowest(close, pd) - high) / ta.lowest(close, pd)) * 100
sDev1 = mult * ta.stdev(wvf1, bbl)
midLine1 = ta.sma(wvf1, bbl)
lowerBand1 = midLine1 - sDev1
rangeLow1 = ta.lowest(wvf1, lb) * ph
is_top = wvf1 <= lowerBand1 or wvf1 <= rangeLow1

// === 筛选器可识别的输出（最重要！）===
plot(is_bottom ? 1 : 0, "底部信号(红柱)", color=color.red, linewidth=2)
plot(is_top ? 1 : 0, "顶部信号(绿柱)", color=color.new(color.lime,0), linewidth=2)

// === 原来的柱子画图保留 ===
plot(-1 * wvf, "Bottom", style=plot.style_columns, color=is_bottom ? color.red : color.gray, linewidth=4)
plot(-1 * wvf1, "Top", style=plot.style_columns, color=is_top ? color.lime : color.gray, linewidth=4)

hline(0)
````
