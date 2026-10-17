# Power Cross

- url: https://www.tradingview.com/script/uylqI49d-Power-Cross/
- type: indicator
- pine_id: PUB;1e78b7d4cde147f591f2e6f73ccb3e59
- version: 1.0

## Description

The Power Cross indicator is a trend-following crossover system built using the 20 EMA and 50 SMA. The script calculates the 20-period Exponential Moving Average to track short-term momentum and the 50-period Simple Moving Average to identify the medium-term trend direction. A bullish signal is generated when the 20 EMA crosses above the 50 SMA, indicating strengthening upward momentum and a possible start of a new uptrend. A bearish signal occurs when the 20 EMA crosses below the 50 SMA, signaling weakening momentum and potential downside movement. The script visually highlights these crossover points by changing the candle color, plotting directional arrows, and applying subtle background shading for easier chart analysis. This system works best in trending markets and is mainly used for swing trading breakouts, pullbacks, and trend continuation setups. However, it may produce false signals during sideways or low-volatility market conditions.

## Source Code

````pine
//@version=6
indicator("Power Cross", shorttitle="PowerCross", overlay=true)

// Calculate the moving averages
ema20 = ta.ema(close, 20)
sma50 = ta.sma(close, 50)

// Plot the moving averages
plot(ema20, color=color.blue, title="20 EMA", linewidth=2)
plot(sma50, color=color.orange, title="50 SMA", linewidth=2)

// Detect crossovers
bullCross = ta.crossover(ema20, sma50)   // 20 EMA crosses above 50 SMA
bearCross = ta.crossunder(ema20, sma50)  // 20 EMA crosses below 50 SMA

// Mark the crossover candle
barcolor(bullCross ? color.green : bearCross ? color.red : na)

// Arrows for visual signals
plotshape(bullCross, title="Bullish Crossover", location=location.belowbar, 
          color=color.green, style=shape.triangleup, size=size.small)
plotshape(bearCross, title="Bearish Crossover", location=location.abovebar, 
          color=color.red, style=shape.triangledown, size=size.small)

// Subtle background highlight
bgcolor(bullCross ? color.new(color.green, 90) : bearCross ? color.new(color.red, 90) : na)
````
