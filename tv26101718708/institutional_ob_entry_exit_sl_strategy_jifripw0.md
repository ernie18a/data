# Institutional OB Entry Exit SL Strategy

- url: https://www.tradingview.com/script/jIfrIPW0-Institutional-OB-Entry-Exit-SL-Strategy/
- type: strategy
- pine_id: PUB;5fef1fb95aa946d299c95ff5de7a01ca
- version: 1.0

## Description

This strategy is designed to identify possible institutional-style entries using order blocks, market structure, and momentum confirmation.

The strategy first looks for a break of structure. A bullish structure break happens when price closes above the recent swing high. A bearish structure break happens when price closes below the recent swing low. After this break, the script marks a possible order block zone: for bullish setups, it uses the most recent bearish candle before the bullish breakout; for bearish setups, it uses the most recent bullish candle before the bearish breakdown.

A trade is not taken immediately after the breakout. The strategy waits for price to return to, or retest, the order block area. This is meant to approximate an institutional entry zone where price may revisit liquidity before continuing in the breakout direction.

For extra confirmation, the script uses three filters:

EMA confirmation: Buy trades require the fast EMA to be above the slow EMA, and price must be above the fast EMA. Sell trades require the fast EMA to be below the slow EMA, and price must be below the fast EMA.
RSI confirmation: Buy trades require RSI above 50, showing bullish momentum. Sell trades require RSI below 50, showing bearish momentum.
Stochastic confirmation: Buy trades require the Stochastic K line to be above the D line and below the overbought zone. Sell trades require the K line to be below the D line and above the oversold zone.
A buy entry is triggered when price retests a bullish order block, closes above the midpoint of that order block, and all EMA, RSI, and Stochastic confirmations agree.

A sell entry is triggered when price retests a bearish order block, closes below the midpoint of that order block, and all confirmation indicators agree.

The stop loss is placed beyond the order block, with an ATR-based buffer. For buy trades, the stop loss is below the bullish order block. For sell trades, the stop loss is above the bearish order block.

The take profit is calculated using a fixed risk-to-reward ratio. By default, the target is set at 2:1, meaning the profit target is twice the distance of the stop loss.

In simple terms, this strategy attempts to trade in the direction of institutional momentum after a structure break, but only after price returns to a key order block zone and receives confirmation from trend and momentum indicators.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ARUN_RAJAN

//@version=6
strategy("Institutional OB Entry Exit SL Strategy", overlay=true, pyramiding=0, process_orders_on_close=true)

// Inputs
structureLen = input.int(20, "Structure Lookback", minval=5)
fastEmaLen   = input.int(50, "Fast EMA")
slowEmaLen   = input.int(200, "Slow EMA")
rsiLen       = input.int(14, "RSI Length")
stochLen     = input.int(14, "Stochastic Length")
smoothK      = input.int(3, "Stoch K Smoothing")
smoothD      = input.int(3, "Stoch D Smoothing")
atrLen       = input.int(14, "ATR Length")
atrBuffer    = input.float(0.25, "Stop Loss ATR Buffer", step=0.05)
riskReward   = input.float(2.0, "Risk Reward", step=0.25)

// Indicators
emaFast = ta.ema(close, fastEmaLen)
emaSlow = ta.ema(close, slowEmaLen)
rsiVal  = ta.rsi(close, rsiLen)
atrVal  = ta.atr(atrLen)

stochRaw = ta.stoch(close, high, low, stochLen)
k = ta.sma(stochRaw, smoothK)
d = ta.sma(k, smoothD)

// Market structure
prevHigh = ta.highest(high[1], structureLen)
prevLow  = ta.lowest(low[1], structureLen)

bullBOS = close > prevHigh
bearBOS = close < prevLow

// Order block approximation
lastBearHigh = ta.valuewhen(close < open, high, 0)
lastBearLow  = ta.valuewhen(close < open, low, 0)

lastBullHigh = ta.valuewhen(close > open, high, 0)
lastBullLow  = ta.valuewhen(close > open, low, 0)

bullObHigh = ta.valuewhen(bullBOS, lastBearHigh, 0)
bullObLow  = ta.valuewhen(bullBOS, lastBearLow, 0)

bearObHigh = ta.valuewhen(bearBOS, lastBullHigh, 0)
bearObLow  = ta.valuewhen(bearBOS, lastBullLow, 0)

// Active order block direction
barsSinceBull = ta.barssince(bullBOS)
barsSinceBear = ta.barssince(bearBOS)

bullActive = not na(barsSinceBull) and (na(barsSinceBear) or barsSinceBull < barsSinceBear)
bearActive = not na(barsSinceBear) and (na(barsSinceBull) or barsSinceBear < barsSinceBull)

// Confirmation
emaBull = emaFast > emaSlow and close > emaFast
emaBear = emaFast < emaSlow and close < emaFast

rsiBull = rsiVal > 50
rsiBear = rsiVal < 50

stochBull = k > d and k < 80
stochBear = k < d and k > 20

// Retest of order block
inBullOB = bullActive and not na(bullObHigh) and low <= bullObHigh and high >= bullObLow
inBearOB = bearActive and not na(bearObHigh) and high >= bearObLow and low <= bearObHigh

bullMid = (bullObHigh + bullObLow) / 2
bearMid = (bearObHigh + bearObLow) / 2

// Entry conditions
buySignal  = inBullOB and close > bullMid and emaBull and rsiBull and stochBull
sellSignal = inBearOB and close < bearMid and emaBear and rsiBear and stochBear

buyEntry  = buySignal and not buySignal[1]
sellEntry = sellSignal and not sellSignal[1]

// Stop loss and target
buyStop = bullObLow - atrVal * atrBuffer
buyRisk = close - buyStop
buyTarget = close + buyRisk * riskReward

sellStop = bearObHigh + atrVal * atrBuffer
sellRisk = sellStop - close
sellTarget = close - sellRisk * riskReward

validBuy = buyEntry and buyRisk > syminfo.mintick
validSell = sellEntry and sellRisk > syminfo.mintick

// Strategy orders
if validBuy
    strategy.close("Sell")
    strategy.entry("Buy", strategy.long)
    strategy.exit("Buy Exit", "Buy", stop=buyStop, limit=buyTarget)

if validSell
    strategy.close("Buy")
    strategy.entry("Sell", strategy.short)
    strategy.exit("Sell Exit", "Sell", stop=sellStop, limit=sellTarget)

// Plots
plot(emaFast, "Fast EMA", color=color.orange)
plot(emaSlow, "Slow EMA", color=color.blue)

plot(bullActive ? bullObHigh : na, "Bullish Order Block High", color=color.green, style=plot.style_linebr)
plot(bullActive ? bullObLow : na, "Bullish Order Block Low", color=color.green, style=plot.style_linebr)

plot(bearActive ? bearObHigh : na, "Bearish Order Block High", color=color.red, style=plot.style_linebr)
plot(bearActive ? bearObLow : na, "Bearish Order Block Low", color=color.red, style=plot.style_linebr)

plotshape(validBuy, title="Buy Entry", text="BUY", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white)
plotshape(validSell, title="Sell Entry", text="SELL", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white)

plot(validBuy ? buyStop : na, "Buy Stop Loss", color=color.red, style=plot.style_circles, linewidth=2)
plot(validBuy ? buyTarget : na, "Buy Target", color=color.green, style=plot.style_circles, linewidth=2)

plot(validSell ? sellStop : na, "Sell Stop Loss", color=color.red, style=plot.style_circles, linewidth=2)
plot(validSell ? sellTarget : na, "Sell Target", color=color.green, style=plot.style_circles, linewidth=2)

// Alerts
alertcondition(validBuy, title="Buy Alert", message="BUY: Institutional order block entry confirmed")
alertcondition(validSell, title="Sell Alert", message="SELL: Institutional order block entry confirmed")
````
