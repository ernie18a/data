# Institutional Early Entry OB Signals

- url: https://www.tradingview.com/script/KcSDb5Xs-Institutional-Early-Entry-OB-Signals/
- type: indicator
- pine_id: PUB;dcf87d224f9349d1b50c1fb5defcd39f
- version: 1.0

## Description

This script is an early institutional order block signal indicator for TradingView. It is designed mainly for short intraday timeframes like 1-minute, 3-minute, and 5-minute, especially for instruments such as Nifty and Bank Nifty.

The main purpose is to find a possible institutional entry area before a full move starts, then show: 
EARLY BUY / EARLY SELL setup
BUY / SELL confirmed entry
Stop-loss level
Target level
Exit signal

How The Script Works

First, the script checks for a break of structure.

A bullish break of structure happens when price closes above the recent high. A bearish break of structure happens when price closes below the recent low. This helps identify where momentum may be shifting.

After a structure break, the script marks a possible order block.

For a bullish setup, it finds the last bearish candle before the bullish breakout. That candle becomes the bullish order block zone.

For a bearish setup, it finds the last bullish candle before the bearish breakdown. That candle becomes the bearish order block zone.

The script then waits for price to come back and retest that order block area. This retest is treated as a possible institutional entry zone.

Early Signal

The script gives an EARLY BUY or EARLY SELL when price enters the order block area and the basic confirmations are already supporting the trade.

This is meant to warn you before the final confirmed signal appears.
EARLY BUY = price enters bullish order block + EMA trend supports buy + RSI supports buy + volume confirms
EARLY SELL = price enters bearish order block + EMA trend supports sell + RSI supports sell + volume confirms

Confirmed Entry Signal

The script gives a confirmed BUY or SELL only after price shows rejection from the order block.

For buy trades, price should show bullish rejection by closing green or closing above the order block midpoint.

For sell trades, price should show bearish rejection by closing red or closing below the order block midpoint.

So the confirmed signal uses:
Order block retest
EMA trend direction
RSI momentum
Volume confirmation
Optional Stochastic confirmation
Rejection candle confirmation

MA Confirmation

The script uses two EMAs:

Fast EMA
Slow EMA
In Aggressive Mode, price only needs to be above the fast EMA for buy or below the fast EMA for sell.
In Balanced Mode, the fast EMA must also be above the slow EMA for buy, or below the slow EMA for sell.

In Conservative Mode, the EMA trend must be aligned, and the fast EMA must also be sloping in the trade direction.

RSI Confirmation

RSI is used to confirm momentum.

For buy trades:
RSI must be above the Buy Level

For sell trades:

RSI must be below the Sell Level
For intraday Nifty / Bank Nifty, the script uses flexible levels like:

Buy above 48
Sell below 52
This helps catch earlier entries instead of waiting for RSI to fully cross 50.

Volume Confirmation

Volume is used to confirm participation.

The script compares current volume with the average volume.

Example:

Current volume > Volume MA x Volume Multiplier
If volume is stronger than normal, the signal is considered more valid.

For 1-minute and 3-minute trading, a low multiplier like 1.0 to 1.05 helps avoid missing too many trades.

Stochastic Confirmation

Stochastic is optional.

By default, it is better to keep it OFF for 1-minute and 3-minute charts because it can delay signals and cause missed opportunities.

If turned ON, it adds one more momentum confirmation.

Stop Loss

For a buy trade, stop loss is placed below the bullish order block with an ATR buffer.

For a sell trade, stop loss is placed above the bearish order block with an ATR buffer.

This gives the trade some breathing room based on market volatility.

Target

The target is calculated using your selected risk-reward ratio.

Example:

Risk Reward: 2.0
If your stop loss risk is 20 points, target will be 40 points.

For Bank Nifty, you can test:

Risk Reward: 2.0 or 2.5
Exit Signal

The script shows an EXIT signal when either:

Target is reached
or

Stop loss is reached
Best Use

This indicator is best used when the market has direction and momentum. It works better during active intraday sessions, especially after a breakout and pullback.

It may give weaker signals during sideways or low-volume markets.

In simple words: this script tries to find where institutions may have entered after a structure break, waits for price to return to that area, checks trend, momentum and volume, then gives early and confirmed buy/sell signals with stop loss and target.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ARUN_RAJAN

//@version=6
indicator("Institutional Early Entry OB Signals", overlay=true, max_labels_count=500)
//inputs

// Inputs
mode = input.string("Balanced", "Signal Mode", options=["Aggressive", "Balanced", "Conservative"])

structureLen = input.int(10, "Structure Lookback", minval=3)
obValidBars  = input.int(40, "Order Block Valid Bars", minval=5)

fastEmaLen = input.int(21, "Fast EMA")
slowEmaLen = input.int(100, "Slow EMA")

rsiLen = input.int(14, "RSI Length")
rsiBuyLevel = input.float(48.0, "RSI Buy Level")
rsiSellLevel = input.float(52.0, "RSI Sell Level")

useStoch = input.bool(false, "Use Stochastic Confirmation")
stochLen = input.int(14, "Stochastic Length")
smoothK = input.int(3, "Stoch K")
smoothD = input.int(3, "Stoch D")

useVolume = input.bool(true, "Use Volume Confirmation")
volLen = input.int(20, "Volume MA Length")
volMultiplier = input.float(1.05, "Volume Multiplier", step=0.05)

atrLen = input.int(14, "ATR Length")
atrBuffer = input.float(0.25, "Stop Loss ATR Buffer", step=0.05)
riskReward = input.float(2.0, "Risk Reward", step=0.25)

showEarlySignal = input.bool(true, "Show Early Setup Signal")
showExitSignal = input.bool(true, "Show Exit Signal")

// Indicators
emaFast = ta.ema(close, fastEmaLen)
emaSlow = ta.ema(close, slowEmaLen)
rsiVal = ta.rsi(close, rsiLen)
atrVal = ta.atr(atrLen)

stochRaw = ta.stoch(close, high, low, stochLen)
k = ta.sma(stochRaw, smoothK)
d = ta.sma(k, smoothD)

volMA = ta.sma(volume, volLen)
volumeConfirm = not useVolume or volume > volMA * volMultiplier

// Market structure
prevHigh = ta.highest(high[1], structureLen)
prevLow = ta.lowest(low[1], structureLen)

bullBOS = close > prevHigh
bearBOS = close < prevLow

// Institutional order block approximation
lastBearHigh = ta.valuewhen(close < open, high, 0)
lastBearLow = ta.valuewhen(close < open, low, 0)

lastBullHigh = ta.valuewhen(close > open, high, 0)
lastBullLow = ta.valuewhen(close > open, low, 0)

bullObHigh = ta.valuewhen(bullBOS, lastBearHigh, 0)
bullObLow = ta.valuewhen(bullBOS, lastBearLow, 0)

bearObHigh = ta.valuewhen(bearBOS, lastBullHigh, 0)
bearObLow = ta.valuewhen(bearBOS, lastBullLow, 0)

barsSinceBullBOS = ta.barssince(bullBOS)
barsSinceBearBOS = ta.barssince(bearBOS)

bullObActive = not na(barsSinceBullBOS) and barsSinceBullBOS <= obValidBars and (na(barsSinceBearBOS) or barsSinceBullBOS < barsSinceBearBOS)
bearObActive = not na(barsSinceBearBOS) and barsSinceBearBOS <= obValidBars and (na(barsSinceBullBOS) or barsSinceBearBOS < barsSinceBullBOS)

// Retest zones
inBullOB = bullObActive and not na(bullObHigh) and low <= bullObHigh and high >= bullObLow
inBearOB = bearObActive and not na(bearObHigh) and high >= bearObLow and low <= bearObHigh

bullMid = (bullObHigh + bullObLow) / 2
bearMid = (bearObHigh + bearObLow) / 2

// Confirmation logic
emaBullAggressive = close > emaFast
emaBearAggressive = close < emaFast

emaBullBalanced = emaFast > emaSlow and close > emaFast
emaBearBalanced = emaFast < emaSlow and close < emaFast

emaBullConservative = emaFast > emaSlow and close > emaFast and emaFast > emaFast[1]
emaBearConservative = emaFast < emaSlow and close < emaFast and emaFast < emaFast[1]

emaBull = mode == "Aggressive" ? emaBullAggressive : mode == "Balanced" ? emaBullBalanced : emaBullConservative
emaBear = mode == "Aggressive" ? emaBearAggressive : mode == "Balanced" ? emaBearBalanced : emaBearConservative

rsiBull = rsiVal > rsiBuyLevel
rsiBear = rsiVal < rsiSellLevel

stochBull = not useStoch or k > d or k > 50
stochBear = not useStoch or k < d or k < 50

bullRejection = close > open or close > bullMid
bearRejection = close < open or close < bearMid

// Early setup signals
earlyBuy = showEarlySignal and inBullOB and emaBull and rsiBull and volumeConfirm
earlySell = showEarlySignal and inBearOB and emaBear and rsiBear and volumeConfirm

// Confirmed entry signals
buySignal = inBullOB and bullRejection and emaBull and rsiBull and stochBull and volumeConfirm
sellSignal = inBearOB and bearRejection and emaBear and rsiBear and stochBear and volumeConfirm

buyEntry = buySignal and not buySignal[1]
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

// Active trade tracking without var
lastBuyBars = ta.barssince(validBuy)
lastSellBars = ta.barssince(validSell)

buyIsLatest = not na(lastBuyBars) and (na(lastSellBars) or lastBuyBars < lastSellBars)
sellIsLatest = not na(lastSellBars) and (na(lastBuyBars) or lastSellBars < lastBuyBars)

activeBuyStop = ta.valuewhen(validBuy, buyStop, 0)
activeBuyTarget = ta.valuewhen(validBuy, buyTarget, 0)

activeSellStop = ta.valuewhen(validSell, sellStop, 0)
activeSellTarget = ta.valuewhen(validSell, sellTarget, 0)

buyExitSL = buyIsLatest and low <= activeBuyStop
buyExitTP = buyIsLatest and high >= activeBuyTarget

sellExitSL = sellIsLatest and high >= activeSellStop
sellExitTP = sellIsLatest and low <= activeSellTarget

exitBuy = showExitSignal and (buyExitSL or buyExitTP)
exitSell = showExitSignal and (sellExitSL or sellExitTP)

// Plots
plot(emaFast, "Fast EMA", color=color.orange)
plot(emaSlow, "Slow EMA", color=color.blue)

plot(bullObActive ? bullObHigh : na, "Bullish OB High", color=color.green, style=plot.style_linebr)
plot(bullObActive ? bullObLow : na, "Bullish OB Low", color=color.green, style=plot.style_linebr)

plot(bearObActive ? bearObHigh : na, "Bearish OB High", color=color.red, style=plot.style_linebr)
plot(bearObActive ? bearObLow : na, "Bearish OB Low", color=color.red, style=plot.style_linebr)

plot(buyIsLatest ? activeBuyStop : na, "Buy Stop Loss", color=color.red, style=plot.style_linebr, linewidth=2)
plot(buyIsLatest ? activeBuyTarget : na, "Buy Target", color=color.green, style=plot.style_linebr, linewidth=2)

plot(sellIsLatest ? activeSellStop : na, "Sell Stop Loss", color=color.red, style=plot.style_linebr, linewidth=2)
plot(sellIsLatest ? activeSellTarget : na, "Sell Target", color=color.green, style=plot.style_linebr, linewidth=2)

// Signal labels
plotshape(earlyBuy and not buySignal, title="Early Buy Setup", text="EARLY BUY", style=shape.triangleup, location=location.belowbar, color=color.new(color.green, 20), textcolor=color.white, size=size.tiny)
plotshape(earlySell and not sellSignal, title="Early Sell Setup", text="EARLY SELL", style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 20), textcolor=color.white, size=size.tiny)

plotshape(validBuy, title="Buy Entry", text="BUY", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white)
plotshape(validSell, title="Sell Entry", text="SELL", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white)

plotshape(exitBuy, title="Buy Exit", text="EXIT", style=shape.xcross, location=location.abovebar, color=color.yellow, textcolor=color.black)
plotshape(exitSell, title="Sell Exit", text="EXIT", style=shape.xcross, location=location.belowbar, color=color.yellow, textcolor=color.black)

// Alerts
alertcondition(earlyBuy, title="Early Buy Setup", message="Early BUY setup: price is entering bullish institutional order block")
alertcondition(earlySell, title="Early Sell Setup", message="Early SELL setup: price is entering bearish institutional order block")

alertcondition(validBuy, title="Buy Entry", message="BUY entry confirmed with order block, EMA, RSI and volume")
alertcondition(validSell, title="Sell Entry", message="SELL entry confirmed with order block, EMA, RSI and volume")

alertcondition(exitBuy, title="Buy Exit", message="Exit BUY trade: stop loss or target reached")
alertcondition(exitSell, title="Sell Exit", message="Exit SELL trade: stop loss or target reached")
````
