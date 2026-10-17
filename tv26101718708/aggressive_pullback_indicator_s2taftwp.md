# Aggressive Pullback Indicator

- url: https://www.tradingview.com/script/s2tAfTWp-Aggressive-Pullback-Indicator/
- type: indicator
- pine_id: PUB;ZvRXzWxlhR83EKGkRHM2zSyOGyFlAWw0
- version: 12.0

## Description

This indicator is designed to be used with the rules of Steven Hart's Aggressive Pullback Strategy. It is intended for use on the 4-hour timeframe of certain currency pairs, but will work on all timeframes and instruments. The rules are customizable, but the default settings are designed to reflect the rules of Steven's pullback strategy as closely as possible.

[b]To enable alerts:[/b] Add the indicator to the chart and create a new alert with the settings Condition: API , Frequency: Once Per Bar (on Close).

Feel free to message me if you have any questions :)

[b]- Matt.[/b]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ZenAndTheArtOfTrading / PineScriptMastery
// @version=6
indicator(title="Aggressive Pullback Indicator", shorttitle="API", overlay=true)

// Get user input
emaLength       = input.int(title="EMA Length:", defval=50, minval=1, tooltip="Exponential moving average period")
stopSizeInput   = input.float(title="Stop Distance (ATR):", defval=1.0, minval=0.0, tooltip="Stop loss distance from highs/lows as an ATR multiplier")
riskToReward    = input.float(title="R:R:", defval=1.0, minval=0.1, tooltip="Risk:Reward profile")

// Get EMA & ATR
ema = ta.ema(close, emaLength)
currentATR = ta.atr(14)

// Calculate stop loss size
stopSize = currentATR * stopSizeInput

// Get SL and Target prices
tradeStopPrice = 0.0
tradeTargetPrice = 0.0
longEntrySize = close - ta.lowest(low, 5) + stopSize
shortEntrySize = ta.highest(high, 5) - close + stopSize

// Validate long signals
rule1L = close > ema and 
   open[1] > close[1] and close > open and close >= open[1] and close[1] >= open and 
   close - open > open[1] - close[1]  // Bullish engulfing?
rule2L = open < open[2]  // Satisfies pullback rule?
rule3L = close < open[5]  // Satisfies maximum engulfing rule?
rule4L = close < ta.highest(open, 5)  // Satisfies swing high and ATR validation?
rule5L = ta.highest(high, 5) > ema and (high[1] > ema or high[2] > ema)  // Make sure the past 2 candles have at least touched or stayed above the ema, cleans up some invalid signals
rule6L = close > ema and (close[1] > ema or close[2] > ema)  // Make sure no more than 1 candle has recently closed below EMA
validLong = rule1L and rule2L and (rule3L or rule4L) and rule5L and rule6L

// Validate short signals
rule1S = close < ema and 
   close[1] > open[1] and open > close and open >= close[1] and open[1] >= close and 
   open - close > close[1] - open[1]  // Bearish engulfing?
rule2S = open > open[2]  // Satisfies pullback rule?
rule3S = close > open[5]  // Satisfies maximum engulfing rule?
rule4S = close > ta.lowest(open, 5)  // Satisfies swing low and ATR validation?
rule5S = ta.lowest(low, 5) < ema and (low[1] < ema or low[2] < ema)  // Make sure the past 2 candles have at least touched or stayed below the ema, cleans up some invalid signals
rule6S = close < ema and (close[1] < ema or close[2] < ema)  // Make sure no more than 1 candle has recently closed above EMA
validShort = rule1S and rule2S and (rule3S or rule4S) and rule5S and rule6S

// Store long signal stop loss & target for drawing later
if validLong
    tradeStopPrice := close - longEntrySize
    tradeTargetPrice := close + longEntrySize * riskToReward

// Store short signal stop loss & target for drawing later
if validShort
    tradeStopPrice := close + shortEntrySize
    tradeTargetPrice := close - shortEntrySize * riskToReward
    
// Draw EMA
plot(ema, title="EMA", color=color.red, linewidth=1)

// Draw signals
plotshape(validLong, title="Bullish Engulfing", location=location.belowbar, color=color.green, style=shape.triangleup)
plotshape(validShort, title="Bearish Engulfing", color=color.red, style=shape.triangledown)

// Draw stops & targets over 2 bars so the lines are more visible
plot(validLong or validLong[1] ? validLong ? tradeStopPrice : tradeStopPrice[1] : na, title="Long Stop Price", color=color.red, style=plot.style_linebr)
plot(validShort or validShort[1] ? validShort ? tradeStopPrice : tradeStopPrice[1] : na, title="Short Stop Price", color=color.red, style=plot.style_linebr)
plot(validLong or validLong[1] ? validLong ? tradeTargetPrice : tradeTargetPrice[1] : na, title="Long Target Price", color=color.green, style=plot.style_linebr)
plot(validShort or validShort[1] ? validShort ? tradeTargetPrice : tradeTargetPrice[1] : na, title="Short Target Price", color=color.green, style=plot.style_linebr)

// Send out an alert if this candle meets our conditions
alertcondition(validLong or validShort, title="API Alert!", message="Pullback signal for {{ticker}}")
````
