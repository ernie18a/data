# RSI+BB BANDS[jackieee]

- url: https://www.tradingview.com/script/mOIHHxy5-RSI-BB-BANDS-jackieee/
- type: indicator
- pine_id: PUB;014d54b444df49d8895248fc8c5adcd4
- version: 1.0

## Description

RSI + BB Bands [jackieee]

This indicator combines RSI, a moving average of RSI, and Bollinger Bands built on RSI into one panel, helping traders evaluate momentum, volatility, and market rhythm in a clearer way.

The core idea is simple:

RSI shows momentum strength and overbought/oversold conditions
RSI MA helps smooth short-term noise and makes shifts in momentum easier to read
Bollinger Bands on RSI show whether RSI is expanding, compressing, or pushing toward relative extremes within its own recent range
What this indicator includes
RSI line
RSI moving average
Bollinger Band basis line
Upper and lower Bollinger Bands
Custom overbought and oversold reference lines
How it can be used

This tool can help traders:

identify when RSI is stretching toward the upper or lower side of its recent range
observe whether momentum is accelerating or fading
track short-term pullbacks and recoveries with the RSI moving average
spot periods of compression and expansion in RSI behavior through the Bollinger Bands
Basic interpretation
When RSI pushes near or above the upper band, momentum is strengthening and price may be entering an extended phase
When RSI moves near or below the lower band, momentum is weakening and the market may be approaching an exhaustion area
The RSI MA can be used as a smoother guide for short-term momentum direction
Wider bands suggest stronger RSI volatility, while tighter bands suggest compression and possible expansion ahead
Inputs

The script allows full customization of:

RSI source
RSI length
overbought / oversold thresholds
RSI MA length
Bollinger Band length
Bollinger Band multiplier

This makes the indicator flexible for different markets, timeframes, and personal trading styles.

Notes

This indicator is designed as a visual analysis tool and should be used together with price structure, trend context, and risk management.

## Source Code

````pine
//@version=6
indicator('RSI+BB BANDS[jackieee]')

// RSI

src_rsi = input(close, title = 'RSI Source')
length_rsi = input.int(14, minval = 1, title = 'RSI Length')
rsi = ta.rsi(src_rsi, length_rsi)

oversold_line = input.int(30, minval = 1, title = 'RSI Oversold Threshold')
overbought_line = input.int(70, minval = 1, title = 'RSI Overbought Threshold')

// Moving Average RSI
ma_length_rsi = input.int(6, minval = 1, title = 'RSI MA Length')
ma_rsi = ta.sma(rsi, ma_length_rsi)

// Bollinger Bands

src = rsi
length = input.int(20, minval = 1, title = 'BB Length')
mult = input.float(2.0, minval = 0.001, maxval = 50, title = 'BB Mult')
basis = ta.sma(src, length)
dev = mult * ta.stdev(src, length)
upper = basis + dev
lower = basis - dev

// Plots 

plot(basis, title = 'BB Basis', color = color.new(color.black, 70))
p1 = plot(upper, title = 'BB Upper', color = color.new(color.red, 50))
p2 = plot(lower, title = 'BB Lower', color = color.new(color.green, 0))
fill(p1, p2, title = 'BB Background', color = color.new(color.black, 95))

plot(rsi, title = 'RSI Plot', color = color.new(color.purple, 0), style = plot.style_line)
plot(ma_rsi, title = 'MA Plot', color = color.new(color.aqua, 50), style = plot.style_line)

hline(oversold_line, title = 'RSI Oversold Line', color = color.new(color.black, 20), linestyle = hline.style_dotted, linewidth = 1)
hline(overbought_line, title = 'RSI Overbought Line', color = color.new(color.black, 20), linestyle = hline.style_dotted, linewidth = 1)
````
