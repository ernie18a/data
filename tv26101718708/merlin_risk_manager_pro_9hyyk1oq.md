# Merlin Risk Manager PRO

- url: https://www.tradingview.com/script/9HYyk1oq-Merlin-Risk-Manager-PRO/
- type: indicator
- pine_id: PUB;5ab66883f4294e1cb8e3168fb4d57e1e
- version: 1.0

## Description

Professional position sizing and risk management tool for discretionary traders.

This indicator helps calculate the optimal position size based on account balance, predefined risk percentage, entry price, stop loss

## Source Code

````pine

//@version=6
indicator("Merlin Risk Manager PRO", overlay=true)

// ===== INPUTS =====
accountSize = input.float(47000, "Account Size ($)", minval=100)

riskPercent = input.float(
     1.0,
     "Risk %",
     minval=0.1,
     maxval=5,
     step=0.1)

entryPrice = input.float(100.0, "Entry Price")
stopPrice = input.float(95.0, "Stop Loss")
takeProfit = input.float(110.0, "Take Profit")

// ===== CALCULATIONS =====

riskAmount = accountSize * riskPercent / 100

stopDistance =
     math.abs(entryPrice - stopPrice)

stopDistancePct =
     stopDistance / entryPrice

positionSizeUSD =
     stopDistancePct > 0 ?
     riskAmount / stopDistancePct :
     na

quantity =
     positionSizeUSD / entryPrice

rr =
     stopDistance > 0 ?
     math.abs(takeProfit - entryPrice) / stopDistance :
     na

potentialProfit =
     quantity *
     math.abs(takeProfit - entryPrice)

requiredLeverage =
     positionSizeUSD / accountSize

// ===== COLORS =====

rrColor =
     rr >= 3 ? color.green :
     rr >= 2 ? color.yellow :
     color.red

// ===== TABLE =====

var table t =
     table.new(
     position.top_right,
     2,
     12,
     border_width = 1)

if barstate.islast

    table.cell(t,0,0,"Metric",
         bgcolor=color.gray,
         text_color=color.white)

    table.cell(t,1,0,"Value",
         bgcolor=color.gray,
         text_color=color.white)

    table.cell(t,0,1,"Account")
    table.cell(t,1,1,"$"+str.tostring(accountSize,"#.##"))

    table.cell(t,0,2,"Risk")
    table.cell(t,1,2,"$"+str.tostring(riskAmount,"#.##"))

    table.cell(t,0,3,"Stop %")
    table.cell(t,1,3,
         str.tostring(stopDistancePct*100,"#.##")+"%")

    table.cell(t,0,4,"Position")
    table.cell(t,1,4,
         "$"+str.tostring(positionSizeUSD,"#.##"))

    table.cell(t,0,5,"Quantity")
    table.cell(t,1,5,
         str.tostring(quantity,"#.####"))

    table.cell(t,0,6,"RR")
    table.cell(t,1,6,
         str.tostring(rr,"#.##"),
         bgcolor=rrColor,
         text_color=color.black)

    table.cell(t,0,7,"Profit")
    table.cell(t,1,7,
         "$"+str.tostring(potentialProfit,"#.##"))

    table.cell(t,0,8,"Loss")
    table.cell(t,1,8,
         "$"+str.tostring(riskAmount,"#.##"))

    table.cell(t,0,9,"Leverage")

    table.cell(t,1,9,
         str.tostring(requiredLeverage,"#.##")+"x")

    table.cell(t,0,10,"Signal")

    signal =
         rr >= 3 ? "A+" :
         rr >= 2 ? "A" :
         "SKIP"

    signalColor =
         rr >= 3 ? color.green :
         rr >= 2 ? color.yellow :
         color.red

    table.cell(
         t,
         1,
         10,
         signal,
         bgcolor=signalColor,
         text_color=color.black)

    table.cell(t,0,11,"Risk Check")

    warning =
         requiredLeverage > 3 ?
         "HIGH SIZE" :
         "OK"

    warningColor =
         requiredLeverage > 3 ?
         color.orange :
         color.green

    table.cell(
         t,
         1,
         11,
         warning,
         bgcolor=warningColor,
         text_color=color.black)
````
