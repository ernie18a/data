# BBT EMA + Bollinger Bands BUY/SELL

- url: https://www.tradingview.com/script/wm3aATKi-BBT-EMA-Bollinger-Bands-BUY-SELL/
- type: indicator
- pine_id: PUB;b956ae18ac134ed8b2ee24b68c352afd
- version: 1.0

## Description

this indicator combines the 50EMA and 20-period bollinger bands with custom standard deviation.
features: 
50EMA trend line
20-period bollinger bands
adjustable standard deviation settings
BUY and SELL signals
works with stocks, options, futures, forex, and crypto
compatible with any time frame

diclaimer:
this indicator is provided for educational and informationl purposes only. it should not be considered financial or investing advise. all trades involve risk and past performance is not indicative of future results. always conduct your own analysis before placing trades.

## Source Code

````pine
//@version=6
indicator("Mike's EMA + Bollinger Bands", overlay=true)

// Inputs
emaLength = input.int(50, "EMA Length")
bbLength = input.int(20, "BB Length")
bbStdDev = input.float(2.0, "BB Standard Deviations")

// Calculations
emaLine = ta.ema(close, emaLength)

// Bollinger Bands
basis = ta.sma(close, bbLength)
dev = bbStdDev * ta.stdev(close, bbLength)
upperBand = basis + dev
lowerBand = basis - dev

// Plot EMA
plot(emaLine, title="9 EMA", color=color.red, linewidth=2)

// Plot Bollinger Bands
plot(basis, title="BB Middle", color=color.blue)
plot(upperBand, title="Upper Band", color=color.rgb(255, 0, 0))
plot(lowerBand, title="Lower Band", color=color.rgb(0, 255, 8))
fill(plot(upperBand), plot(lowerBand), color=color.new(color.green, 90))

// Buy/Sell Conditions
bullish = ta.crossover(close, emaLine) and close > basis
bearish = ta.crossunder(close, emaLine) and close < basis

// Signals
plotshape(bullish,
     title="BUY",
     text="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     textcolor=color.white)

plotshape(bearish,
     title="SELL",
     text="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     textcolor=color.white)
````
