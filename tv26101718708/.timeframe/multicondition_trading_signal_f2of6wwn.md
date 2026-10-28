# Multi-Condition Trading Signal

- url: https://www.tradingview.com/script/F2OF6wWN-Multi-Condition-Trading-Signal/
- type: indicator
- pine_id: PUB;4c5eb74c83174254b49252d08a864f69
- version: 1.0

## Description

Adjustable Rate of Change, MAs, Volume, Stoploss, Buy Sell Stratedgy!, Let me know if we can improve it.> Enjoy!..

## Source Code

````pine
//@version=5
indicator("Multi-Condition Trading Signal", overlay=true)

// INPUT PARAMETERS
ma200Length = input.int(200, title="200-Day MA Length", minval=1)
ma200Type = input.string("SMA", title="200-Day MA Type", options=["SMA", "EMA"])

ema20Length = input.int(20, title="20-Week EMA Length", minval=1)
ema20Type = input.string("EMA", title="20-Week MA Type", options=["SMA", "EMA"])

slEmaLength = input.int(10, title="Stop Loss MA Length", minval=1)
slEmaType = input.string("EMA", title="Stop Loss MA Type", options=["SMA", "EMA"])

rocPeriod = input.int(20, title="ROC Period (weeks)", minval=1)
rocThreshold = input.float(30, title="ROC Threshold (%)", minval=0, step=0.5)
minVolume = input.float(100000, title="Min Weekly Price*Volume ($)", minval=0)
showOnlyLast = input.bool(true, title="Show Only Last Buy/Sell Signals")

// CALCULATE CONDITIONS
ma200 = ma200Type == "EMA" ? ta.ema(close, ma200Length) : ta.sma(close, ma200Length)
condition1 = close >= ma200

ema20w = ema20Type == "EMA" ? ta.ema(close, ema20Length) : ta.sma(close, ema20Length)
condition2 = close >= ema20w

rocValue = ta.roc(close, rocPeriod)
condition3 = rocValue >= rocThreshold

weeklyPriceVolume = request.security(syminfo.tickerid, "W", close * volume)
condition4 = weeklyPriceVolume > minVolume

slEma = slEmaType == "EMA" ? ta.ema(close, slEmaLength) : ta.sma(close, slEmaLength)

// SIGNALS - TRACK LAST BUY AND SELL
var bool inPosition = false
var int lastBuyBar = na
var int lastSellBar = na

allConditionsMet = condition1 and condition2 and condition3 and condition4
priceBeowSL = ta.crossunder(close, slEma)

if allConditionsMet and not inPosition
    inPosition := true
    lastBuyBar := bar_index
else if priceBeowSL and inPosition
    inPosition := false
    lastSellBar := bar_index

buyOnce = allConditionsMet and not inPosition[1]
sellOnce = priceBeowSL and inPosition[1]

// APPLY FILTER - SHOW ONLY LAST SIGNALS IF ENABLED
buySignal = showOnlyLast ? (buyOnce and bar_index == lastBuyBar) : buyOnce
sellSignal = showOnlyLast ? (sellOnce and bar_index == lastSellBar) : sellOnce

// PLOT LINES
plot(ma200, title="200-Day MA", color=color.blue, linewidth=2)
plot(ema20w, title="20-Week EMA", color=color.orange, linewidth=2)
plot(slEma, title="Stop Loss EMA", color=color.red, linewidth=2)

// PLOT SIGNALS
plotshape(buySignal, title="BUY", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(sellSignal, title="SELL", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

// ALERTS
alertcondition(buySignal, title="BUY Signal", message="BUY Signal!")
alertcondition(sellSignal, title="SELL Signal", message="SELL Signal!")
````
