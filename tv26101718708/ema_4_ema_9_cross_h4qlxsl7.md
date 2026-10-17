# EMA 4 / EMA 9 Cross

- url: https://www.tradingview.com/script/h4qlxSL7-EMA-4-EMA-9-Cross/
- type: indicator
- pine_id: PUB;f8534457c481451ba9dc5dd8aa44259a
- version: 1.0

## Description

Best for 5 minute candlestick strategy. 
For buy: If the candle closes above the EMA 4 and 9 (the band is green) and crosses up the VWAP, there is an opportunity to buy. Also, if the candle closes above the EMA 4 and 9 (the band is green) and way below the VWAP, there is an opportunity to buy. 
For sell: If the candle closes below the EMA 4 and 9 (the band is red) and crosses down the VWAP, there is an opportunity to sell. Also, if the candle closes below the EMA 4 and 9 (the band is red) and way above the VWAP, there is an opportunity to sell.

## Source Code

````pine
//@version=5
indicator(title="EMA 4 / EMA 9 Cross", overlay=true)

// --- Inputs
ema4_len = input.int(4, title="EMA 4 Length")
ema9_len = input.int(9, title="EMA 9 Length")

// --- EMA Calculations
ema4 = ta.ema(close, ema4_len)
ema9 = ta.ema(close, ema9_len)

// --- Plot EMAs
p4 = plot(ema4, title="EMA 4", color=color.orange, linewidth=2)
p9 = plot(ema9, title="EMA 9", color=color.new(color.aqua, 0), linewidth=2)

// --- Fill Color Logic
fillColor = ema4 > ema9 ? color.new(color.green, 75) : color.new(color.red, 75)

// --- Fill Between EMAs
fill(p4, p9, color=fillColor, title="EMA Fill")
````
