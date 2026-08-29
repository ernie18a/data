<!-- tradingview-pine-id: PUB;83a3e1c16c844d81a726d8f8e56965f9 -->
<!-- tradingviewscripts-format: 1 -->
# Median Convergence Divergence

Source: https://www.tradingview.com/script/odyzZlzU-Median-Convergence-Divergence/

## Description

Introduction
The Median Convergence Divergence (MCD) is a derivative of the Moving Average Convergence Divergence (MACD). The difference is the change in the use of the measure of central tendency. In MACD, moving average (mean) is used, whereas, in MCD, the median is used instead. The purpose of using the median is to eliminate the outlying values, which would be calculated for a moving average. The outliers would affect the value of the moving average. 

For example: 3, 5, 7, 8, 5, 4, 2, 1, 6, 21, 8. The data set average is 6.3, whereas the median value is 5. There is a difference of about 23% in the example. The reason is the outlying value '21' in the data set. 

As the markets are volatile, outlying values can always emerge. A moving average will consider those values; on the other hand, the median will ignore. If the strategy calls for a tool to ignore the outliers, the Median Convergence Divergence would be a great centered oscillator. 

The default values have changed to suit the current trading days in a week. When the MACD was introduced, there would be six trading days in a week. Therefore, it used 12 (2 weeks), 26(4 weeks), and 9 ( 1.5 weeks). But now that there are five trading days per week. The default values are adapted to them. Feel free to change them as per your wish.

Recommended Settings
The current settings are set to be used for the Daily Time Frame: 5 day period for the fast line, a 20 day period for the slow line, and a 10 day period for the signal line. (5 days represent a trading week, 10 days is two weeks, and 20 days is 4 weeks or a month)

For the weekly charts, use 4 week period for the fast line, 13 week period for the slow line, and 8 week period for the signal line. (4 weeks represent a month, 8 weeks is two months, and 13 weeks is 3 months or quarterly)

And for monthly charts, use 3 month period for the fast line, 12 month period for the slow line, and 6 month period for the signal line. (3 months is quarterly, 6 months is bi-yearly, and 12 month is yearly)

It'll be challenging to measure for intraday since there are many different timeframes within intraday. The settings mentioned above should also be customized as per the requirements of the trading strategy.

Strategy
The strategy application is the same as the MACD, i.e., Signal Line Crossovers, Zero Line Crossovers, and Divergence.

Signal Line Crossovers: When the MCD line crosses above the Signal line, it's a bullish crossover. When the MCD line crosses below the Signal line, it's a bearish crossover.
Zero Line Crossovers: It's a bullish crossover when the MCD line crosses above the Zero line. When the MCD line crosses below the Zero Line, it's a bearish crossover.
Divergence: When price shows a lower low, but MCD shows a higher low, it's a bullish divergence. When the price shows a higher high but MCD shows a lower high, it's a bearish divergence.

Using other indicators in conjunction with the Median Convergence Divergence is recommended to take entry and exit signals.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © maksumit

//@version=5
indicator("Median Convergence Divergence", "MCD", timeframe="", timeframe_gaps=true)
//Inputs
fast = input.int(5, "Fast Length", 1)
slow = input.int(20, "Slow Length", 1)
src = input.source(close, "Source")
signal = input.int(10, "Signal Length", 1)

//Median, Median Convergence Divergence, Signal and Histogram
medianF = ta.median(src, fast)
medianS = ta.median(src, slow)
mcd = medianF - medianS
mcds = ta.median(mcd, signal)
hist = mcd - mcds

//Plots
plot(hist, "Histogram", style=plot.style_columns, color=hist<hist[1] and hist>0 ? color.green:hist>0 ? color.lime:hist>hist[1] ? color.maroon:color.red)
plot(mcds, "Signal Line", color=color.orange, linewidth=2)
plot(mcd, "MCD Line", color=color.blue, linewidth=2)
hline(0, "Zero Line")
````
