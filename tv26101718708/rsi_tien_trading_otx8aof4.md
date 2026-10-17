# RSI Tien Trading

- url: https://www.tradingview.com/script/Otx8aOf4/
- type: indicator
- pine_id: PUB;a4fd76de940d417887a4e6026310416c
- version: 1.0

## Description

Đây là chỉ báo mua bán được test chưa chính xác , mọi người cẩn thận trước khi áp dụng

## Source Code

````pine
// @version=5
indicator(title="RSI Tien Trading", format=format.price, timeframe="", timeframe_gaps=true)
len = input.int(title="RSI Period", minval=1, defval=14)
src = input(title="RSI Source", defval=close)
lbR = input.int(title="Pivot Lookback Right", defval=5)
lbL = input.int(title="Pivot Lookback Left", defval=5)
rangeUpper = input.int(title="Max of Lookback Range", defval=60)
rangeLower = input.int(title="Min of Lookback Range", defval=5)
plotBull = input.bool(title="Plot Bullish", defval=true)
plotHiddenBull = input.bool(title="Plot Hidden Bullish", defval=false)
plotBear = input.bool(title="Plot Bearish", defval=true)
plotHiddenBear = input.bool(title="Plot Hidden Bearish", defval=false)
bearColor = color.red
bullColor = color.green
hiddenBullColor = color.new(color.green, 80)
hiddenBearColor = color.new(color.red, 80)
textColor = color.white
noneColor = color.new(color.white, 100)
osc = ta.rsi(src, len)

// Calculate Moving Averages
maFast = ta.sma(osc, 6)
maSlow = ta.sma(osc, 30)

// Plot RSI
rsiPlot = plot(osc, title="RSI", linewidth=1, color=color.new(color.purple, 0))

// Plot Moving Averages
plot(maFast, title="Fast MA (9)", color=color.yellow, linewidth=1)
plot(maSlow, title="Slow MA (45)", color=color.blue, linewidth=1)

// Middle line
midline = hline(50, title="Middle Line", color=color.red, linestyle=hline.style_dotted)
obLevel = hline(70, title="Overbought", color=color.gray, linestyle=hline.style_dotted)
osLevel = hline(30, title="Oversold", color=color.gray, linestyle=hline.style_dotted)

// Overbought/Oversold thresholds
obThreshold = hline(80, title="Overbought Threshold", color=color.gray, linestyle=hline.style_dashed)
osThreshold = hline(20, title="Oversold Threshold", color=color.gray, linestyle=hline.style_dashed)

// Background fill
fill(obLevel, osLevel, title="Background", color=color.new(color.purple, 90))

// Gradient fills
midLinePlot = plot(50, color=na, display=display.none)
fill(rsiPlot, midLinePlot, top_value=100, bottom_value=70, top_color=color.new(color.green, 0), bottom_color=color.new(color.green, 100), title="Overbought Gradient Fill")
fill(rsiPlot, midLinePlot, top_value=30, bottom_value=0, top_color=color.new(color.red, 100), bottom_color=color.new(color.red, 0), title="Oversold Gradient Fill")

// Plot vertical bars
plotshape(osc > 80 ? osc : na, title="Overbought Bar", style=shape.triangleup, location=location.absolute, color=color.green, size=size.tiny)
plotshape(osc < 20 ? osc : na, title="Oversold Bar", style=shape.triangledown, location=location.absolute, color=color.orange, size=size.tiny)

plFound = not na(ta.pivotlow(osc, lbL, lbR))
phFound = not na(ta.pivothigh(osc, lbL, lbR))
inRange(cond) =>
    bars = ta.barssince(cond)
    rangeLower <= bars and bars <= rangeUpper

// Regular Bullish
inRangePl = inRange(plFound[1])
oscHL = osc[lbR] > ta.valuewhen(plFound, osc[lbR], 1) and inRangePl
priceLL = low[lbR] < ta.valuewhen(plFound, low[lbR], 1)
bullCondAlert = priceLL and oscHL and plFound
bullCond = plotBull and bullCondAlert

plot(plFound ? osc[lbR] : na, offset=-lbR, title="Regular Bullish", linewidth=2, color=bullCond ? bullColor : noneColor)
plotshape(bullCond ? osc[lbR] : na, offset=-lbR, title="Regular Bullish Label", text=" Bull ", style=shape.labelup, location=location.absolute, color=bullColor, textcolor=textColor)

// Hidden Bullish
oscLL = osc[lbR] < ta.valuewhen(plFound, osc[lbR], 1) and inRangePl
priceHL = low[lbR] > ta.valuewhen(plFound, low[lbR], 1)
hiddenBullCondAlert = priceHL and oscLL and plFound
hiddenBullCond = plotHiddenBull and hiddenBullCondAlert

plot(plFound ? osc[lbR] : na, offset=-lbR, title="Hidden Bullish", linewidth=2, color=hiddenBullCond ? hiddenBullColor : noneColor)
plotshape(hiddenBullCond ? osc[lbR] : na, offset=-lbR, title="Hidden Bullish Label", text=" H Bull ", style=shape.labelup, location=location.absolute, color=bullColor, textcolor=textColor)

// Regular Bearish
inRangePh = inRange(phFound[1])
oscLH = osc[lbR] < ta.valuewhen(phFound, osc[lbR], 1) and inRangePh
priceHH = high[lbR] > ta.valuewhen(phFound, high[lbR], 1)
bearCondAlert = priceHH and oscLH and phFound
bearCond = plotBear and bearCondAlert

plot(phFound ? osc[lbR] : na, offset=-lbR, title="Regular Bearish", linewidth=2, color=bearCond ? bearColor : noneColor)
plotshape(bearCond ? osc[lbR] : na, offset=-lbR, title="Regular Bearish Label", text=" Bear ", style=shape.labeldown, location=location.absolute, color=bearColor, textcolor=textColor)

// Hidden Bearish
oscHH = osc[lbR] > ta.valuewhen(phFound, osc[lbR], 1) and inRangePh
priceLH = high[lbR] < ta.valuewhen(phFound, high[lbR], 1)
hiddenBearCondAlert = priceLH and oscHH and phFound
hiddenBearCond = plotHiddenBear and hiddenBearCondAlert

plot(phFound ? osc[lbR] : na, offset=-lbR, title="Hidden Bearish", linewidth=2, color=hiddenBearCond ? hiddenBearColor : noneColor)
plotshape(hiddenBearCond ? osc[lbR] : na, offset=-lbR, title="Hidden Bearish Label", text=" H Bear ", style=shape.labeldown, location=location.absolute, color=bearColor, textcolor=textColor)

// Alerts
alertcondition(bullCondAlert, title="Regular Bullish Divergence", message="Found a new Regular Bullish Divergence, Pivot Lookback Right bars to the left")
alertcondition(hiddenBullCondAlert, title="Hidden Bullish Divergence", message="Found a new Hidden Bullish Divergence, Pivot Lookback Right bars to the left")
alertcondition(bearCondAlert, title="Regular Bearish Divergence", message="Found a new Regular Bearish Divergence, Pivot Lookback Right bars to the left")
alertcondition(hiddenBearCondAlert, title="Hidden Bearish Divergence", message="Found a new Hidden Bearish Divergence, Pivot Lookback Right bars to the left")
````
