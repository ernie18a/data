# c-c/MA (Simplified 2-Color)

- url: https://www.tradingview.com/script/ViwsvlwE/
- type: indicator
- pine_id: PUB;cf053476b4044d65a3cbb66d974bf76c
- version: 1.0

## Description

c-c/MA (Simplified 2-Color)

This indicator is a simple momentum analysis tool that visualizes price movement by comparing the current price with the price from a specified number of periods ago.

It displays the price difference as a histogram and applies a Simple Moving Average (SMA) to help identify trend strength and momentum shifts.

 Features

 Price Difference (c-c)

The indicator calculates the difference between the current closing price and the closing price from a specified number of bars ago:

* Positive values indicate that the current price is higher than the past price.
* Negative values indicate that the current price is lower than the past price.

 SMA Smoothing

A Simple Moving Average (SMA) is applied to the histogram to smooth short-term fluctuations and highlight the overall momentum trend.

 Two-Color Histogram

The histogram changes color based on its relationship to the SMA:

* Above SMA: Indicates relatively stronger momentum.
* Below SMA: Indicates weaker or slowing momentum.

 Zero Line

The zero line represents the point where the current price equals the price from the selected lookback period:

* Above zero: Bullish momentum.
* Below zero: Bearish momentum.

 How to Use

This indicator can be used to:

* Identify trend direction
* Evaluate momentum strength
* Detect potential trend shifts
* Complement other indicators such as RSI, volume analysis, or moving averages

Note: This indicator is designed as a supporting analytical tool and should be used alongside other forms of market analysis and risk management.

## Source Code

````pine
//@version=6
indicator(title="c-c/MA (Simplified 2-Color)", shorttitle="c-c/MA", overlay=false)

// Parameters
length_input = input.int(14, "c-c Period", minval=1)
sma_length   = input.int(14, "SMA Period", minval=1)

barColorAbove = input.color(color.rgb(55, 211, 44), "Bar Color Above SMA")
barColorBelow = input.color(color.rgb(39, 162, 119), "Bar Color Below SMA")
smaLineColor  = input.color(color.lime, "SMA Line Color")

// c-c calculation
cc_value = close - close[length_input]

// SMA of c-c
sma_cc = ta.sma(cc_value, sma_length)

// Bar color based on SMA
bar_color = cc_value > sma_cc ? barColorAbove : barColorBelow

// Bar chart
plot(cc_value, title="c-c Bar", style=plot.style_columns, color=bar_color)

// SMA line
plot(sma_cc, title="SMA of c-c", color=smaLineColor, linewidth=1)

// Zero line
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dotted)
````
