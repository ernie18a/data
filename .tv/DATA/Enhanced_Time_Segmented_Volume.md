<!-- tradingview-pine-id: PUB;QTlxjSAaeL25I1c4igYQzqip0MYXnjFy -->
<!-- tradingviewscripts-format: 1 -->
# Enhanced Time Segmented Volume

Source: https://www.tradingview.com/script/672uPH9q-Enhanced-Time-Segmented-Volume/

## Description

Time Segmented Volume was developed by Worden Brothers, Inc to be a leading indicator by comparing various time segments of both price and volume. Essentialy it is designed to measure the amount of money flowing in and out of an instrument. 

Time Segmented Volume was originally ported to TradingView by user @liw0 and later corrected by user @vitelot. I never quite understood how to read Time Segmented Volume until I ran across a version by user @storma where they indicated when price would be long or short, but that code also utilized the incorrect calculation from user @liw0.

In an effort to make Time Segmented Volume more accessible and easier to read, I have re-coded it here. The calculations are based on the code from @vitelot and I have added direction indicators below the chart. 

If the histogram (TSV) is greater than zero and greater than the moving average, price should be moving long and there will be a green box below the chart. 
If TSV falls below the moving average while still being greater than zero, the trend may be exhausting and has been coded to read Price Action Long - FAILURE with a black x below the chart.

If the histogram (TSV) is less than zero and less than the moving average, price should be moving short and there will be a red box below the chart.
If TSV rises above the moving average while still being less than zero, the trend may be exhausting and has been coded to read Price Action Short - FAILURE with a black x below the chart.

At times, the moving average may be above zero while TSV is below zero or vice versa. In these situations the chart will indicate long or short based on whether or not TSV is greater or less than zero. It is possible a new trend may be forming as the moving average obviously lags, but also possible price is consolidating with little volume and causing TSV to oscillate close to zero.

More information regarding Time Segmented Volume can be found here: www.worden.com/TekeChartHelp/Content/Indicators/Time_Segmented_Volume.htm

Original code ported by @liw0
Corrected by @vitelot
Updated/Enhancements by @eylwithsteph with inspiration from @storma

As always, trade at your own risk.

---

## Source Code

````pine
//@version=4
//      Written by liw0 active on https://www.tradingview.com/u/liw0
//      corrected version by vitelot December 2018 -- no charity required
//      Updated/Enhanced version by @eylwithsteph inspired by @storma
//      CREDITS: http://quant.stackexchange.com/questions/2816/how-to-calculate-time-segmented-volume
study("Enhanced Time Segmented Volume", shorttitle="TSV")

l = input(13, title="TSV Length")
l_ma = input(7, title="MA Length")

t = sum(close > close[1] ? volume * (close - close[1]) : close < close[1] ? volume * (close - close[1]) : 0, l)
m = sma(t, l_ma)

PAL = (t > m) and (t > 0) 
PAL_fail = (t < m) and (t > 0)
PAS = (t < m) and (t < 0)
PAS_fail = (t > m) and (t < 0)

plot(t, color=color.red, style=plot.style_histogram, title="TSV")
plot(m, color=color.green, title="MA")

plotshape(PAL, title="Price Action Long", location=location.bottom, style=shape.square, size=size.auto, color=color.green, transp=80)
plotshape(PAS, title="Price Action Short", location=location.bottom, style=shape.square, size=size.auto, color=color.red, transp=80)
plotshape(PAL_fail, title="Price Action Long - FAILURE", location=location.bottom, style=shape.xcross, size=size.auto, color=color.black, transp=60)
plotshape(PAS_fail, title="Price Action Short - FAILURE", location=location.bottom, style=shape.xcross, size=size.auto, color=color.black, transp=60)
````
