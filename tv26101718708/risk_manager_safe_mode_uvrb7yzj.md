# Risk Manager + Safe Mode 

- url: https://www.tradingview.com/script/UVrB7yzJ-risk-manager-safe-mode/
- type: indicator
- pine_id: PUB;251e4ad6c04b4e1da40bd081e9d5b7f5
- version: 1.0

## Description

This script is a TradingView Pine Script risk manager for leveraged trades.
It calculates position size, stop loss, liquidation price, margin, and take profit automatically.

Main features:

Safe Mode → limits risk based on % of deposit.
Full Mode → uses full available margin.
Supports Long and Short trades.
Automatic Stop Loss and Liquidation calculations.
Displays trade info in a table on the chart.
Draws Entry, Stop Loss, Liquidation, and Take Profit lines.
Includes risk profiles: Safe / Normal / Risk.
Prevents invalid trades with error checks.

Purpose:
Helps traders manage leverage and avoid over-risking positions.

## Source Code

````pine
//@version=6
indicator("Risk Manager + Safe Mode Toggle (FIXED)", overlay=true)

// ===== ACCOUNT =====
deposit  = input.float(341, "Deposit ($)", group="Account")
leverage = input.int(15, "Leverage (x)", group="Account")

useManualMargin = input.bool(false, "Use Manual Margin", group="Account")
manualMargin    = input.float(100, "Manual Margin ($)", group="Account")

safeMode = input.bool(true, "Safe Mode (Risk Limiter)", group="Account",
     tooltip="ON = risk-based sizing | OFF = full margin")

direction = input.string("Short", "Direction", options=["Long", "Short"], group="Trade")

// ===== ENTRY =====
useCurrentPrice = input.bool(true, "Use current price as entry", group="Trade")
entryPrice      = input.float(688, "Manual entry price", group="Trade")

// ===== STOP LOSS =====
riskProfile = input.string("Normal", "Risk Profile", options=["Safe", "Normal", "Risk"], group="Stop Loss")

safePercent   = input.float(4.0, "Safe (%)", group="Stop Loss") / 100
normalPercent = input.float(3.0, "Normal (%)", group="Stop Loss") / 100
riskPercent   = input.float(2.0, "Risk (%)", group="Stop Loss") / 100

riskCapitalPercent = input.float(2.0, "Risk per trade (%)", group="Risk Management") / 100

// ===== TP =====
tpPercentInput = input.float(0, "Take Profit (%)", group="Trade")

// ===== CORE =====
realEntry = useCurrentPrice ? close : entryPrice

selectedPercent =
     riskProfile == "Safe" ? safePercent :
     riskProfile == "Normal" ? normalPercent :
     riskPercent

stopLoss =
     direction == "Short" ? realEntry * (1 + selectedPercent)
                           : realEntry * (1 - selectedPercent)

liqPrice =
     direction == "Short" ? realEntry * (1 + 1.0 / leverage)
                           : realEntry * (1 - 1.0 / leverage)

tpPrice = tpPercentInput > 0 ?
     (direction == "Short" ? realEntry * (1 - tpPercentInput / 100)
                           : realEntry * (1 + tpPercentInput / 100))
     : na

// ===== RISK CALC =====
riskCapital = deposit * riskCapitalPercent
slDistance  = math.abs(realEntry - stopLoss)

maxPositionFromMargin =
     (useManualMargin ? manualMargin : deposit) * leverage

positionUSD =
     safeMode ?
         (slDistance != 0
             ? math.min(riskCapital / (slDistance / realEntry), maxPositionFromMargin)
             : 0)
     : maxPositionFromMargin

qty = positionUSD / realEntry

requiredMargin =
     useManualMargin ? manualMargin : positionUSD / leverage

slLossUSD = slDistance * qty
profitPerPercent = positionUSD * 0.01

// ===== ERRORS =====
isError = false
errorMsg = ""

if direction == "Short" and stopLoss <= realEntry
    isError := true
    errorMsg := "Short: stop must be ABOVE entry"

if direction == "Long" and stopLoss >= realEntry
    isError := true
    errorMsg := "Long: stop must be BELOW entry"

if requiredMargin > deposit
    isError := true
    errorMsg := "Not enough deposit"

// ===== LINES =====
var line entryLine = na
var line stopLine  = na
var line liqLine   = na
var line tpLine    = na

if barstate.islast and not isError

    if na(entryLine)
        entryLine := line.new(bar_index, realEntry, bar_index+20, realEntry,
             color = direction == "Long" ? color.green : color.red, width=2)
    else
        line.set_xy1(entryLine, bar_index, realEntry)
        line.set_xy2(entryLine, bar_index+20, realEntry)

    if na(stopLine)
        stopLine := line.new(bar_index, stopLoss, bar_index+20, stopLoss,
             color=color.orange, style=line.style_dashed)
    else
        line.set_xy1(stopLine, bar_index, stopLoss)
        line.set_xy2(stopLine, bar_index+20, stopLoss)

    if na(liqLine)
        liqLine := line.new(bar_index, liqPrice, bar_index+20, liqPrice,
             color=color.purple)
    else
        line.set_xy1(liqLine, bar_index, liqPrice)
        line.set_xy2(liqLine, bar_index+20, liqPrice)

    if not na(tpPrice)
        if na(tpLine)
            tpLine := line.new(bar_index, tpPrice, bar_index+20, tpPrice,
                 color=color.blue)
        else
            line.set_xy1(tpLine, bar_index, tpPrice)
            line.set_xy2(tpLine, bar_index+20, tpPrice)

// ===== TABLE =====
var table riskTable = table.new(position.top_right, 2, 10,
     border_color=color.gray, border_width=1)

if barstate.islast

    table.clear(riskTable, 0, 0, 1, 9)

    if isError
        table.cell(riskTable, 0, 0, "ERROR", text_color=color.red)
        table.cell(riskTable, 1, 0, errorMsg, text_color=color.red)

    else
        table.cell(riskTable, 0, 0, "Type")
        table.cell(riskTable, 1, 0,
             direction + " (" + str.tostring(leverage) + "x)" +
             (safeMode ? " [SAFE]" : " [FULL]"),
             text_color = direction == "Long" ? color.green : color.red)

        table.cell(riskTable, 0, 1, "Entry")
        table.cell(riskTable, 1, 1,
             "$" + str.tostring(math.round_to_mintick(realEntry)))

        table.cell(riskTable, 0, 2, "Risk Profile")
        table.cell(riskTable, 1, 2, riskProfile)

        table.cell(riskTable, 0, 3, "Stop Loss")
        table.cell(riskTable, 1, 3,
             "$" + str.tostring(math.round_to_mintick(stopLoss)) +
             " (-$" + str.tostring(math.round(slLossUSD, 2)) + ")",
             text_color=color.orange)

        table.cell(riskTable, 0, 4, "Stop Distance")
        table.cell(riskTable, 1, 4,
             str.tostring(math.round(slDistance / realEntry * 100, 2)) + "%")

        table.cell(riskTable, 0, 5, "Coins")
        table.cell(riskTable, 1, 5,
             str.tostring(math.round(qty, 6)) +
             " ($" + str.tostring(math.round(positionUSD, 2)) + ")",
             text_color=color.aqua)

        table.cell(riskTable, 0, 6, "Margin")
        table.cell(riskTable, 1, 6,
             "$" + str.tostring(math.round(requiredMargin, 2)))

        table.cell(riskTable, 0, 7, "Move 1%")
        table.cell(riskTable, 1, 7,
             "$" + str.tostring(math.round(profitPerPercent, 2)))

        liqPercent = math.round(math.abs(realEntry - liqPrice) / realEntry * 100, 2)

        table.cell(riskTable, 0, 8, "Liquidation")
        table.cell(riskTable, 1, 8,
             "$" + str.tostring(math.round_to_mintick(liqPrice)) +
             " (" + str.tostring(liqPercent) + "%)",
             text_color=color.purple)

        if not na(tpPrice)
            tpProfit = math.abs(tpPrice - realEntry) * qty

            table.cell(riskTable, 0, 9, "Take Profit")
            table.cell(riskTable, 1, 9,
                 "$" + str.tostring(math.round_to_mintick(tpPrice)) +
                 " (+$" + str.tostring(math.round(tpProfit, 2)) + ")",
                 text_color=color.blue)
````
