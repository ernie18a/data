# Automated Position size calculator

- url: https://www.tradingview.com/script/1I7CIxos-Automated-Position-size-calculator/
- type: indicator
- pine_id: PUB;81d908e50476465d968adf735f772349
- version: 1.0

## Description

This is a position size calculator that automatically tracks the current best market price.
Its simple to use
you just set your account size, max position size and maximum risk percentage per trade.

Set your stop loss which can then be dragged on the chart and it will give you a live position size that moves with price.

This allows fast traders who get in their trades with market orders to get in with an accurate position once they have defined the stop loss for the trade.

This is incredibly efficient compared to any other position size calculations including the standard long and short position tools on trading view

you can remove all the noise in the settings and just have you stop loss and take profit lines with the readout of current correct position size.

Stop over or under positioning when getting in fast.

## Source Code

````pine
//@version=6
indicator("Dynamic Risk Manager Pro", overlay=true, max_labels_count=500)

//=====================================================
// INPUTS
//=====================================================

tradeDirection = input.string(
     "Long",
     "Trade Direction",
     options=["Long", "Short"])

accountSize = input.float(
     50000,
     "Account Size ($)",
     minval=1)

riskPercent = input.float(
     1.0,
     "Risk Per Trade (%)",
     minval=0.01,
     step=0.1)

maxPositionValue = input.float(
     50000,
     "Max Position Value ($)",
     minval=1)

slPrice = input.price(
     0.0,
     "Stop Loss")

tp1Price = input.price(
     0.0,
     "Take Profit 1")

tp2Price = input.price(
     0.0,
     "Take Profit 2")

tp3Price = input.price(
     0.0,
     "Take Profit 3")

//=====================================================
// TRADE DIRECTION
//=====================================================

isLong = tradeDirection == "Long"
isShort = tradeDirection == "Short"

//=====================================================
// LIVE ENTRY
//=====================================================

entryPrice = close

//=====================================================
// RISK CALCULATIONS
//=====================================================

riskAmount = accountSize * riskPercent / 100

stopDistance =
     isLong ?
     math.max(entryPrice - slPrice, syminfo.mintick) :
     math.max(slPrice - entryPrice, syminfo.mintick)

rawShares = riskAmount / stopDistance

maxSharesAllowed = maxPositionValue / entryPrice

shares = math.floor(math.min(rawShares, maxSharesAllowed))

positionValue = shares * entryPrice

actualRisk = shares * stopDistance

//=====================================================
// R:R CALCULATIONS
//=====================================================

rr1 =
     isLong ?
     (tp1Price - entryPrice) / stopDistance :
     (entryPrice - tp1Price) / stopDistance

rr2 =
     isLong ?
     (tp2Price - entryPrice) / stopDistance :
     (entryPrice - tp2Price) / stopDistance

rr3 =
     isLong ?
     (tp3Price - entryPrice) / stopDistance :
     (entryPrice - tp3Price) / stopDistance

//=====================================================
// VALIDATION
//=====================================================

validLong = isLong and slPrice < entryPrice
validShort = isShort and slPrice > entryPrice

validTrade = validLong or validShort

//=====================================================
// PLOTS
//=====================================================

entryColor = color.new(color.lime, 0)
stopColor = color.new(color.red, 0)
tpColor = color.new(color.aqua, 0)

entryPlot = plot(
     entryPrice,
     title="Live Entry",
     color=entryColor,
     linewidth=3)

stopPlot = plot(
     slPrice,
     title="Stop Loss",
     color=stopColor,
     linewidth=3)

plot(
     tp1Price,
     title="TP1",
     color=tpColor,
     linewidth=2)

plot(
     tp2Price,
     title="TP2",
     color=tpColor,
     linewidth=2)

plot(
     tp3Price,
     title="TP3",
     color=tpColor,
     linewidth=2)

//=====================================================
// RISK ZONE
//=====================================================

riskUpper =
     isLong ? entryPrice : slPrice

riskLower =
     isLong ? slPrice : entryPrice

riskUpperPlot = plot(
     riskUpper,
     color=color.new(color.red, 100))

riskLowerPlot = plot(
     riskLower,
     color=color.new(color.red, 100))

fill(
     riskUpperPlot,
     riskLowerPlot,
     color=color.new(color.red, 88))

//=====================================================
// REWARD ZONE (TP1)
//=====================================================

rewardUpper =
     isLong ? tp1Price : entryPrice

rewardLower =
     isLong ? entryPrice : tp1Price

rewardUpperPlot = plot(
     rewardUpper,
     color=color.new(color.green, 100))

rewardLowerPlot = plot(
     rewardLower,
     color=color.new(color.green, 100))

fill(
     rewardUpperPlot,
     rewardLowerPlot,
     color=color.new(color.green, 88))

//=====================================================
// LARGE POSITION LABEL
//=====================================================

var label positionLabel = na
var label infoLabel = na

if barstate.islast

    label.delete(positionLabel)
    label.delete(infoLabel)

    positionColor =
         validTrade ?
         color.new(color.green, 0) :
         color.new(color.red, 0)

    positionText =
         validTrade ?
         str.tostring(shares) + " SHARES" :
         "INVALID\nSTOP"

    positionLabel := label.new(
         x=bar_index + 5,
         y=entryPrice,
         text=positionText,
         style=label.style_label_left,
         color=positionColor,
         textcolor=color.white,
         size=size.huge)

    infoText =
         "Risk: $" + str.tostring(actualRisk, "#.##") +
         "\nValue: $" + str.tostring(positionValue, "#,###") +
         "\nEntry: " + str.tostring(entryPrice, format.mintick) +
         "\nStop: " + str.tostring(slPrice, format.mintick) +
         "\nTP1: " + str.tostring(rr1, "#.##") + "R" +
         "\nTP2: " + str.tostring(rr2, "#.##") + "R" +
         "\nTP3: " + str.tostring(rr3, "#.##") + "R"

    infoLabel := label.new(
         x=bar_index + 5,
         y=entryPrice - (stopDistance * 2),
         text=infoText,
         style=label.style_label_left,
         color=color.black,
         textcolor=color.white,
         size=size.normal)

//=====================================================
// ALERT CONDITIONS
//=====================================================

alertcondition(
     close <= slPrice and isLong,
     "Long Stop Hit",
     "Long stop loss has been hit")

alertcondition(
     close >= slPrice and isShort,
     "Short Stop Hit",
     "Short stop loss has been hit")

alertcondition(
     close >= tp1Price and isLong,
     "Long TP1 Hit",
     "Long TP1 reached")

alertcondition(
     close <= tp1Price and isShort,
     "Short TP1 Hit",
     "Short TP1 reached")

alertcondition(
     close >= tp2Price and isLong,
     "Long TP2 Hit",
     "Long TP2 reached")

alertcondition(
     close <= tp2Price and isShort,
     "Short TP2 Hit",
     "Short TP2 reached")

alertcondition(
     close >= tp3Price and isLong,
     "Long TP3 Hit",
     "Long TP3 reached")

alertcondition(
     close <= tp3Price and isShort,
     "Short TP3 Hit",
     "Short TP3 reached")
````
