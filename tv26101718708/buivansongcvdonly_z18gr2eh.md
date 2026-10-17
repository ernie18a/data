# buivansongcvdonly

- url: https://www.tradingview.com/script/z18gR2Eh-buivansongcvdonly/
- type: indicator
- pine_id: PUB;96313dd05e774b4eae5d9755c41fe3a6
- version: 1.0

## Description

sdfsdf sdfsdfdsfasdfasdfsad sadfa sdf ádfasdfasdf ádf ádfasdf

## Source Code

````pine
//@version=6
indicator("CVD Only", shorttitle="CVD", overlay=false)

import TradingView/ta/8

//=====================================================
// INPUTS
//=====================================================
group_cvd = "CVD Settings"

anchorInput = input.timeframe("1D", "Anchor Period", group=group_cvd)
cvdMaxHeight = input.float(30.0, "Độ cao tối đa của CVD (0-100)", minval=5, maxval=50, group=group_cvd)

//=====================================================
// GET CVD DATA
//=====================================================
var string lowTF = timeframe.isintraday ? "1" : "60"

[oV, hV, lV, cV] = ta.requestVolumeDelta(lowTF, anchorInput)

//=====================================================
// NORMALIZATION
//=====================================================
float maxDelta = ta.highest(math.abs(nz(cV)), 100)

float normalizedCV =
     (nz(cV) / (maxDelta == 0 ? 1 : maxDelta))
     * cvdMaxHeight

float cvdEMA = ta.ema(normalizedCV, 9)

//=====================================================
// PLOTS
//=====================================================
hline(0, "CVD Zero", color=color.new(color.gray, 50))

color c_hist =
     normalizedCV >= nz(normalizedCV[1])
     ? color.new(color.teal, 40)
     : color.new(color.red, 40)

plot(
     normalizedCV,
     title="CVD Histogram",
     style=plot.style_columns,
     color=c_hist,
     histbase=0)

plot(
     cvdEMA,
     title="CVD EMA",
     color=color.yellow,
     linewidth=2)
````
