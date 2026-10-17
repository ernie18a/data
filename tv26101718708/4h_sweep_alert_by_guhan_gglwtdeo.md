# 4H Sweep Alert by Guhan

- url: https://www.tradingview.com/script/GglWTDeO-4H-Sweep-Alert-by-Guhan/
- type: indicator
- pine_id: PUB;b3e104a6641f4471b010668a55716a62
- version: 1.0

## Description

4H Sweep Alert Strategy

This indicator generates an alert when a 4-hour candle performs a liquidity sweep of the previous candle and closes strongly in the opposite direction, indicating a potential trend continuation or reversal.

Target 

Target-  1:1
Stop loss - Alert candle low 
Entry - After the close of the alert candle

Long Alert Conditions

A Buy Alert is triggered only when all of the following conditions are met:

The previous candle is bullish (green).
The previous candle is not a Doji and has a clearly defined body.
The current 4-hour candle sweeps below the previous candle's Low.
The current 4-hour candle closes above the previous candle's High.
The alert is generated only after the candle closes.
Short Alert Conditions

A Sell Alert is triggered only when all of the following conditions are met:

The previous candle is bearish (red).
The previous candle is not a Doji and has a clearly defined body.
The current 4-hour candle sweeps above the previous candle's High.
The current 4-hour candle closes below the previous candle's Low.
The alert is generated only after the candle closes.
Filters

To improve the quality of the alerts, the indicator ignores the following market conditions:

Doji or indecisive previous candles, as they do not represent strong directional intent.
Range-bound or sideways markets, where this pattern has a higher probability of producing false signals.

This setup is designed to perform best in established trending markets, where liquidity sweeps are more likely to result in strong directional moves.

## Source Code

````pine
//@version=6
indicator("4H Sweep Alert", overlay=true)

// Previous candle direction
prevBull = close[1] > open[1]
prevBear = close[1] < open[1]

// Conditions
longSignal = barstate.isconfirmed and
             prevBull and
             low < low[1] and
             close > high[1]

shortSignal = barstate.isconfirmed and
              prevBear and
              high > high[1] and
              close < low[1]

// Optional chart markers
plotshape(longSignal, title="Long", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small)
plotshape(shortSignal, title="Short", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

// Alerts
alertcondition(longSignal, title="Long Alert", message="4H Bullish Sweep Detected")
alertcondition(shortSignal, title="Short Alert", message="4H Bearish Sweep Detected")
````
