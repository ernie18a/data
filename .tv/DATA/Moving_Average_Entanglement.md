<!-- tradingview-pine-id: PUB;7QB02zxrFZAquFsbxcXv1l076LmDp9w9 -->
<!-- tradingviewscripts-format: 1 -->
# Moving Average Entanglement

Source: https://www.tradingview.com/script/QVsW9gUP-Moving-Average-Entanglement/

## Description

This script uses the gap in moving averages standardized to the average true range to determine entry and exit points.  
The red line represents the current percentage of ATR that is deemed "The Dead Zone" - a move that is too small to be reliable.  
The histogram represents the gap between moving averages.  When the histogram is above the red line, it confirms a breakout move.
The dashed line an be used as a secondary filter and is a moving average of the histogram.
When Standard Deviation mode is on, a third line is displayed, which represents how many standard Deviations the current histogram bar represents, and can be also used as a filter.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jwammo12

//@version=4
study(title="Moving Average Entanglement", shorttitle="MAEntangle", overlay=false)

source = input(close)
fastMALength = input(3)
slowMALength = input(14)
ATRDeadZoneLength = input(10)
volatilityPeriod = input(10)
DeadZonePercentage = input(40)


StandardDeviationMode = input(false)
DeviationMultiplier = input(2.5)



MAType = input(defval = "SMA",title = "MA Type", type = input.string,  options = ["EMA", "SMA"])
ColorHistogram = input(false)

fastMA = (MAType == "SMA" ? sma(source,fastMALength) : ema(source,fastMALength))
slowMA = (MAType == "SMA" ? sma(source,slowMALength) : ema(source,slowMALength))

Gapping = abs(fastMA-slowMA)
atrDeadZone = atr(ATRDeadZoneLength)*DeadZonePercentage*.01

bufferMA = (MAType == "SMA" ? sma(Gapping,volatilityPeriod) : ema(Gapping,volatilityPeriod))
stdDeviationBuffer = stdev(Gapping,volatilityPeriod) * DeviationMultiplier

colored = ColorHistogram ? (fastMA>slowMA ? color.green : color.red) : color.yellow

alertcondition(fastMA>slowMA and Gapping > atrDeadZone and not (fastMA[1]>slowMA[1] and Gapping[1] > atrDeadZone) , "Dead Zone Buy Signal")
alertcondition(fastMA<slowMA and Gapping > atrDeadZone and not (fastMA[1]<slowMA[1] and Gapping[1] > atrDeadZone), "Dead Zone Sell Signal")

alertcondition(fastMA>slowMA and Gapping > bufferMA and not (fastMA[1]>slowMA[1] and Gapping[1] > bufferMA), "Dead Zone Secondary Buy Signal")
alertcondition(fastMA<slowMA and Gapping > bufferMA and not (fastMA[1]<slowMA[1] and Gapping[1] > bufferMA), "Dead Zone Secondary Sell Signal")

alertcondition(fastMA>slowMA and Gapping > stdDeviationBuffer and not (fastMA[1]>slowMA[1] and Gapping[1] > stdDeviationBuffer), "Dead Zone Std Deviation Buy Signal")
alertcondition(fastMA<slowMA and Gapping > stdDeviationBuffer and not (fastMA[1]<slowMA[1] and Gapping[1] > stdDeviationBuffer), "Dead Zone Std Deviation Sell Signal")

alertcondition(fastMA<slowMA and fastMA[1]>=slowMA[1] and fastMA[2]>=slowMA[2], "Histogram Trend Change Buy Signal")
alertcondition(fastMA<slowMA and fastMA[1]>=slowMA[1] and fastMA[2]>=slowMA[2], "Histogram Trend Change Sell Signal")

alertcondition(stdDeviationBuffer > bufferMA and stdDeviationBuffer[1] <= bufferMA[1], "Std Deviation MA Crossover Buy Signal")
alertcondition(stdDeviationBuffer < bufferMA and stdDeviationBuffer[1] >= bufferMA[1], "Std Deviation MA Crossunder Sell Signal")


plot(Gapping, style=plot.style_columns, color=colored)
plot(atrDeadZone, color=color.red,linewidth=2)
plot(bufferMA, color= bar_index %2==0 ? color.fuchsia : #00000000, linewidth=2)
plot(stdDeviationBuffer, color=StandardDeviationMode ? color.blue : #00000000, linewidth=2)
````
