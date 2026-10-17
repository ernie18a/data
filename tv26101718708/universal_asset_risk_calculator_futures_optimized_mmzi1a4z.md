# Universal Asset Risk Calculator - Futures Optimized

- url: https://www.tradingview.com/script/MmzI1A4z-Universal-Asset-Risk-Calculator-Futures-Optimized/
- type: indicator
- pine_id: PUB;b08f347f4119474594049f78511a9dcd
- version: 2.0

## Description

Easy to use Risk Calculator (rounds to the nearest contract amount for futures) that will tell your total risk with an adjustable account size and adjustable risk based on percentage or cash amount.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Universal Risk Calc - Draggable + Table Logic", overlay = true)

// --- Groups ---
const string G1 = "Interactive Anchor Points"
const string G2 = "Risk & Table Settings"
const string G3 = "Take Profit Logic"

// --- 1. Draggable Price Inputs (Blue Handles) ---
float entryPrice = input.price(0, "Entry (Drag Handle)", group = G1, confirm = true)
float slPrice    = input.price(0, "SL (Drag Handle)", group = G1, confirm = true)
float manualTP   = input.price(0, "Manual TP (Drag Handle)", group = G1, confirm = true)

// --- 2. Risk Management (Adjustable via Settings, Reflects in Table) ---
string riskMode   = input.string("Percentage", "Risk Mode", options = ["Cash", "Percentage"], group = G2)
float riskValue   = input.float(1.0, "Risk Value (Reflected in Table)", group = G2)
float accountSize = input.float(10000.0, "Account Size", group = G2)
int precision     = input.int(2, "Size Decimals", minval = 0, maxval = 8, group = G2)

// --- 3. TP Logic (Adjustable R/R) ---
string tpMode    = input.string("Manual", "TP Target Mode", options = ["Manual", "Fixed R/R"], group = G3, tooltip = "In Fixed R/R mode, the TP line automatically follows Entry/SL to maintain the ratio.")
float targetRR   = input.float(2.0, "Target R/R Ratio", minval = 0.1, step = 0.1, group = G3)

// --- Logic: Calculations ---
float priceDist = math.abs(entryPrice - slPrice)
bool isLong     = entryPrice > slPrice

// Determine TP Price based on Mode
float tpPrice = tpMode == "Fixed R/R" ? (isLong ? entryPrice + (priceDist * targetRR) : entryPrice - (priceDist * targetRR)) : manualTP

float riskPerUnit    = priceDist * syminfo.pointvalue 
float targetRiskCash = riskMode == "Percentage" ? (riskValue / 100) * accountSize : riskValue
float finalPosSize   = math.round((riskPerUnit > 0 ? targetRiskCash / riskPerUnit : 0), precision)
float actualRiskCash = finalPosSize * riskPerUnit
float rrRatio        = priceDist > 0 ? math.abs(tpPrice - entryPrice) / priceDist : 0

// --- Visuals: Objects ---
var line lEntry = line.new(na, na, na, na, color = #5b9cf6, width = 2)
var line lSL    = line.new(na, na, na, na, color = #f23645, width = 2, style = line.style_dashed)
var line lTP    = line.new(na, na, na, na, color = #089981, width = 2)

var label lblE  = label.new(na, na, "ENTRY", style=label.style_label_left, color=#00000000, textcolor = #5b9cf6)
var label lblS  = label.new(na, na, "STOP LOSS", style=label.style_label_left, color=#00000000, textcolor = #f23645)
var label lblT  = label.new(na, na, "TAKE PROFIT", style=label.style_label_left, color=#00000000, textcolor = #089981)

if barstate.islast
    int start = last_bar_index - 50
    int end   = last_bar_index + 20
    
    line.set_xy1(lEntry, start, entryPrice), line.set_xy2(lEntry, end, entryPrice)
    line.set_xy1(lSL, start, slPrice),       line.set_xy2(lSL, end, slPrice)
    line.set_xy1(lTP, start, tpPrice),       line.set_xy2(lTP, end, tpPrice)
    
    label.set_xy(lblE, end+1, entryPrice)
    label.set_xy(lblS, end+1, slPrice)
    label.set_xy(lblT, end+1, tpPrice)

// --- Info Table ---
var table riskTable = table.new(position.top_right, 2, 5, bgcolor=color.new(color.black, 40), border_color=color.gray, border_width=1)
if barstate.islast
    table.cell(riskTable, 0, 0, "Position", text_color=color.white)
    table.cell(riskTable, 1, 0, isLong ? "LONG" : "SHORT", text_color=isLong ? #089981 : #f23645)
    table.cell(riskTable, 0, 1, "Risk Setting", text_color=color.white)
    table.cell(riskTable, 1, 1, str.tostring(riskValue) + (riskMode == "Percentage" ? "%" : " USD"), text_color=color.white)
    table.cell(riskTable, 0, 2, "Size", text_color=color.yellow)
    table.cell(riskTable, 1, 2, str.tostring(finalPosSize, "#.########"), text_color=color.yellow)
    table.cell(riskTable, 0, 3, "Actual Risk $", text_color=color.white)
    table.cell(riskTable, 1, 3, "$" + str.tostring(actualRiskCash, "#.##"), text_color = color.white)
    table.cell(riskTable, 0, 4, "R/R Ratio", text_color=color.white)
    table.cell(riskTable, 1, 4, str.tostring(rrRatio, "0.00"), text_color = color.white)
````
