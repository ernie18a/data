# Colored Bollinger BandWidth [AMLQ]

- url: https://www.tradingview.com/script/TAELoRUR-Colored-Bollinger-BandWidth-AMLQ/
- type: indicator
- pine_id: PUB;019dd377259240bd8fce5b195bdf4706
- version: 1.0

## Description

[b]Overview[/b]
This indicator tracks market volatility cycles by isolating Bollinger BandWidth (BBW) into an oscillator panel. It pairs standard volatility measurements with a directional trend filter and historical boundary channels, making it easy to identify volatility squeezes, breakout expansions, and market exhaustion points.

[b]Core Components & Mechanics[/b]
Bollinger BandWidth (BBW): Calculated as ((Upper Band - Lower Band) / Basis) * 100 using a 60-period length and 2.0 standard deviations. It measures the percentage spread between bands relative to the mean.

Trend-Biased Coloring:
[list]
[*]Blue Line: Price is trading above the trend baseline (Close > SMA). Signals bullish momentum.
[*]Red Line: Price is trading below the trend baseline (Close < SMA). Signals bearish momentum.
[/list]
60-Period BBW SMA (Gray Line): A simple moving average of the BandWidth itself. Acts as a baseline filter to determine whether current volatility is expanding or contracting relative to its 60-bar average.

Highest Expansion (Red Boundary): The 125-bar rolling maximum of BBW. Highlights peak volatility levels where moves are historically stretched.

Lowest Contraction (Green Boundary): The 125-bar rolling minimum of BBW. Pinpoints extreme compression zones where explosive breakouts originate.

[b]Trading Rules & Setups[/b]
Volatility Squeeze (Setup Zone):
[list]
[*]When the BBW line hugs or tests the green lowest contraction line, price is heavily compressed. Avoid chop trading and prepare for a high-momentum breakout.
[/list]
Bullish Breakout (Long Entry):
[list]
[*]The BBW line crosses above its gray 60-period SMA while plotted in Blue. This confirms that volatility is accelerating in the direction of an upward trend.
[/list]
Bearish Breakdown (Short Entry):
[list]
[*]The BBW line crosses above its gray 60-period SMA while plotted in Red. This confirms that volatility is expanding in the direction of a downward trend.
[/list]
Volatility Exhaustion (Take Profit / Tighten Stops):
[list]
[*]When the BBW line nears the red highest expansion line, volatility has reached statistical extremes. Expect consolidation, pullbacks, or sideways drift rather than continuation.
[/list]
[b]Pine Script Implementation Note[/b]
In the script, the variable ma60 is set to ta.sma(src, 30) rather than a 60-period length. To align the code with the naming and indicator title, update that calculation to ta.sma(src, 60) or declare it as an adjustable input parameter.

## Source Code

````pine
//@version=6
indicator(title="Colored Bollinger BandWidth [AMLQ]",format=format.price, precision=2, timeframe="", timeframe_gaps=true)

// Input parameters
length = input.int(60,    minval = 1, title="BBW Length")
src    = input(close,     title = "Source")
mult   = input.float(2.0, minval = 0.001, maxval =50, title ="StdDev")

expansionLengthInput   = input.int(125, "Highest Expansion Length",  display = display.data_window)
contractionLengthInput = input.int(125, "Lowest Contraction Length", display = display.data_window)

// Input for the moving average length of BBW
maLength = input.int(60, minval = 1, title="BBW SMA Length")

// Calculate the 20-period moving average
ma60 = ta.sma(src, 30)

// Calculate Bollinger Bands
basis = ta.sma(src, length)
dev   = mult * ta.stdev(src, length)
upper = basis + dev
lower = basis - dev
bbw   = ((upper - lower) / basis) * 100

// Determine the color of the Bollinger BandWidth plot
bbwColor = close > ma60 ? color.blue : color.red

// Plot Bollinger BandWidth with conditional color
plot(bbw, "Bollinger BandWidth", color = bbwColor)

// Calculate the 60-period SMA of the BBW
bbwSMA = ta.sma(bbw, maLength)

// Plot the 60-period SMA of the BBW
plot(bbwSMA, "BBW 60-period SMA", color = color.gray, linewidth = 1)

// Plot Highest Expansion and Lowest Contraction
plot(ta.highest(bbw, expansionLengthInput),  "Highest Expansion",  color = color.new(#F23645, 50))
plot(ta.lowest(bbw, contractionLengthInput), "Lowest Contraction", color = color.new(#089981, 50))
````
