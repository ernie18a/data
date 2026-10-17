# Risk Engine  Futures Position Size Calculator 

- url: https://www.tradingview.com/script/pwaBrkqY-Risk-Engine-Futures-Position-Size-Calculator/
- type: indicator
- pine_id: PUB;3699da378e094aaaa05fccb126750130
- version: 1.0

## Description

🔥 Risk Engine (TradingView Indicator)

Stop guessing your position size directly on the chart.

Risk Engine is a TradingView indicator designed to help futures traders calculate exact contract size, risk, and profit targets in real time—without leaving the chart.

⚡ What it does
Calculates max contracts allowed based on your risk
Converts your stop loss into ticks automatically
Displays actual risk per trade
Shows target profit based on RR
Updates instantly as you adjust your setup
🎯 Built for real trading

This indicator is made for:

Futures traders (ES, MES, NQ, MNQ, GC, CL, etc.)
Prop firm traders (Topstep, funded accounts)
Anyone serious about risk management and consistency
📊 Why it matters

Most traders don’t fail because of entries—they fail because of position sizing.

One oversized trade can:

Wipe out multiple winners
Break your risk rules
Kill your consistency

Risk Engine keeps every trade inside your plan.

🚀 Features
Real-time contract sizing
SL in ticks (structure-based trading)
Built-in risk & reward calculator
Clean on-chart display (no clutter)
Works on any timeframe
No external tools needed
🧠 How to use
Add the indicator to your chart
Set your risk ($) and RR
Input your stop loss (ticks or price)
Let Risk Engine calculate your contracts
💡 Bottom line

If you’re trading without knowing your exact position size…
you’re gambling.

Risk Engine turns your setup into a calculated trade.

⚠️ Disclaimer

This tool is for educational purposes only.
You are responsible for your own trading decisions.

## Source Code

````pine
//@version=6
indicator("Risk Engine - Futures Position Calculator", overlay=true)

// Inputs
riskDollars = input.float(150, "Risk Per Trade ($)", minval=1)
slTicks     = input.float(10, "Stop Loss (Ticks)", minval=1)
rr          = input.float(3.0, "Risk Reward", minval=0.1, step=0.1)

contract = input.string("MES", "Contract", options=["MES", "ES", "MNQ", "NQ", "MGC", "GC", "MCL", "CL", "Custom"])

customTickValue = input.float(1.25, "Custom Tick Value ($)", minval=0.01)
customTickSize  = input.float(0.25, "Custom Tick Size", minval=0.0001)

// Contract tick values
tickValue = switch contract
    "MES" => 1.25
    "ES"  => 12.50
    "MNQ" => 0.50
    "NQ"  => 5.00
    "MGC" => 1.00
    "GC"  => 10.00
    "MCL" => 1.00
    "CL"  => 10.00
    => customTickValue

tickSize = switch contract
    "MES" => 0.25
    "ES"  => 0.25
    "MNQ" => 0.25
    "NQ"  => 0.25
    "MGC" => 0.10
    "GC"  => 0.10
    "MCL" => 0.01
    "CL"  => 0.01
    => customTickSize

// Calculations
riskPerContract = slTicks * tickValue
contractsAllowed = math.floor(riskDollars / riskPerContract)

actualRisk = contractsAllowed * riskPerContract
tpTicks = slTicks * rr
targetProfit = actualRisk * rr

slPoints = slTicks * tickSize
tpPoints = tpTicks * tickSize

// Table
var table riskTable = table.new(position.top_right, 2, 9, border_width=1)

if barstate.islast
    table.cell(riskTable, 0, 0, "Risk Engine", bgcolor=color.rgb(6,18,12), text_color=color.rgb(245,197,66))
    table.cell(riskTable, 1, 0, contract, bgcolor=color.rgb(6,18,12), text_color=color.white)

    table.cell(riskTable, 0, 1, "Risk $", text_color=color.white)
    table.cell(riskTable, 1, 1, "$" + str.tostring(riskDollars), text_color=color.white)

    table.cell(riskTable, 0, 2, "SL Ticks", text_color=color.white)
    table.cell(riskTable, 1, 2, str.tostring(slTicks), text_color=color.white)

    table.cell(riskTable, 0, 3, "Max Contracts", text_color=color.white)
    table.cell(riskTable, 1, 3, str.tostring(contractsAllowed), text_color=color.lime)

    table.cell(riskTable, 0, 4, "Actual Risk", text_color=color.white)
    table.cell(riskTable, 1, 4, "$" + str.tostring(actualRisk), text_color=color.red)

    table.cell(riskTable, 0, 5, "RR Target", text_color=color.white)
    table.cell(riskTable, 1, 5, str.tostring(rr) + "R", text_color=color.rgb(245,197,66))

    table.cell(riskTable, 0, 6, "Target Profit", text_color=color.white)
    table.cell(riskTable, 1, 6, "$" + str.tostring(targetProfit), text_color=color.rgb(245,197,66))

    table.cell(riskTable, 0, 7, "SL Points", text_color=color.white)
    table.cell(riskTable, 1, 7, str.tostring(slPoints), text_color=color.white)

    table.cell(riskTable, 0, 8, "TP Points", text_color=color.white)
    table.cell(riskTable, 1, 8, str.tostring(tpPoints), text_color=color.white)
````
