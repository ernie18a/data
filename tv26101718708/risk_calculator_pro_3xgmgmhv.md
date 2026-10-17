# Risk Calculator PRO 

- url: https://www.tradingview.com/script/3XgmgmHV-Risk-Calculator-PRO/
- type: indicator
- pine_id: PUB;19b57191502042d7959e57b5df9f70f3
- version: 1.0

## Description

Risk Calculator PRO 

A professional all-in-one risk management panel for TradingView designed to help traders instantly calculate trade exposure, risk percentage, and reward targets directly on the chart.

Features
Calculates potential loss in dollars based on stop distance and lot size
Displays account risk percentage automatically
Supports Forex pairs including JPY calculations
Works with other markets using symbol point value
Shows Risk-to-Reward targets:
1:1
1:2
1:3
Live pip value calculation
Clean dark-mode optimized dashboard
Lightweight and easy to use
Inputs
Account Size ($)
Stop Distance
Lot Size
Perfect For
Forex traders
Scalpers
Day traders
Swing traders
Risk-focused trading plans

This tool helps traders maintain disciplined position sizing and consistent risk management before entering any trade.

## Source Code

````pine
//@version=5
indicator("Risk Calculator PRO (Full)", overlay=true)

// === INPUTS ===
account = input.float(1000, "Account Size ($)")
stop    = input.float(100, "Stop Distance")
lot     = input.float(0.05, "Lot Size")

// === SYMBOL LOGIC ===
isForex = syminfo.type == "forex"
pipSize = isForex ? (str.contains(syminfo.ticker, "JPY") ? 0.01 : 0.0001) : syminfo.mintick

float pipValue = na
if isForex
    pipValue := (pipSize / close) * 100000
else
    pipValue := syminfo.pointvalue

// === RISK ===
loss = stop * lot * pipValue
risk = (loss / account) * 100

// === RR ===
rr1 = stop
rr2 = stop * 2
rr3 = stop * 3

// === TABLE ===
var table t = table.new(position.top_right, 2, 8, border_width=2)

// 🎨 COLORS (black background optimized)
bgMain   = color.rgb(10,10,10)
bgAlt    = color.rgb(20,20,20)
bgHeader = color.rgb(35,35,35)

txtWhite = color.white
txtGray  = color.rgb(180,180,180)

accent   = color.rgb(0,200,255)
green    = color.rgb(0,255,120)
red      = color.rgb(255,80,80)

riskColor = risk <= 1 ? green : red

if barstate.islast
    // HEADER
    table.cell(t, 0, 0, "RISK PANEL", text_color=txtWhite, bgcolor=bgHeader)
    table.cell(t, 1, 0, syminfo.ticker, text_color=accent, bgcolor=bgHeader)

    // RISK
    table.cell(t, 0, 1, "Loss ($)", text_color=txtGray, bgcolor=bgMain)
    table.cell(t, 1, 1, "$" + str.tostring(loss, "#.##"), text_color=txtWhite, bgcolor=bgAlt)

    table.cell(t, 0, 2, "Risk (%)", text_color=txtGray, bgcolor=bgMain)
    table.cell(t, 1, 2, str.tostring(risk, "#.##") + "%", text_color=riskColor, bgcolor=bgAlt)

    table.cell(t, 0, 3, "Lot", text_color=txtGray, bgcolor=bgMain)
    table.cell(t, 1, 3, str.tostring(lot, "#.###"), text_color=accent, bgcolor=bgAlt)

    // RR
    table.cell(t, 0, 4, "RR 1:1", text_color=txtGray, bgcolor=bgMain)
    table.cell(t, 1, 4, str.tostring(rr1), text_color=green, bgcolor=bgAlt)

    table.cell(t, 0, 5, "RR 1:2", text_color=txtGray, bgcolor=bgMain)
    table.cell(t, 1, 5, str.tostring(rr2), text_color=green, bgcolor=bgAlt)

    table.cell(t, 0, 6, "RR 1:3", text_color=txtGray, bgcolor=bgMain)
    table.cell(t, 1, 6, str.tostring(rr3), text_color=green, bgcolor=bgAlt)

    // PIP VALUE
    table.cell(t, 0, 7, "Pip Value", text_color=txtGray, bgcolor=bgMain)
    table.cell(t, 1, 7, str.tostring(pipValue, "#.###"), text_color=txtWhite, bgcolor=bgAlt)
````
