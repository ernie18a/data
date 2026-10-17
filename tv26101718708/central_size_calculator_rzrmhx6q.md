# CENTRAL Size Calculator

- url: https://www.tradingview.com/script/RzrMhX6Q/
- type: indicator
- pine_id: PUB;67d264d7fa274cc9b4057fb146e6a0f8
- version: 1.0

## Description

This tool calculates position size based on account balance, risk percentage, stop loss in pips, and pip value.

It is designed to help traders apply consistent risk management across different market conditions.

Formula used:
Position Size = Risk Amount / (Stop Loss × Pip Value)

Example:
If you risk 1% of a $10,000 account with a 10 pip stop loss, the tool will automatically calculate the correct lot size.

Author: Sebastián Figueroa

## Source Code

````pine
//@version=5
indicator("CENTRAL Size Calculator", overlay=true)

// ===== INPUTS =====
balance      = input.float(10000, "Account Balance ($)", minval=0)
riskPercent  = input.float(1, "Risk (%)", minval=0.1)
sl_pips      = input.float(13, "Stop Loss (pips)", minval=0.1)

// AVANZADO
use_manual   = input.bool(false, "Manual Pip Value")
manual_value = input.float(10, "Manual Value")

// ===== DETECCION =====
isForex = syminfo.type == "forex"
isJPY   = str.contains(syminfo.ticker, "JPY")

pip_size = isForex ? (isJPY ? 0.01 : 0.0001) : syminfo.mintick

auto_pip = (pip_size / syminfo.mintick) * syminfo.pointvalue
pip_value = use_manual ? manual_value : auto_pip

// ===== CALC =====
risk_amount = balance * (riskPercent / 100)
lot_size    = sl_pips > 0 ? risk_amount / (sl_pips * pip_value) : na
lot_final   = math.round(lot_size * 100) / 100

// ===== UI =====
var table panel = table.new(position.bottom_right, 2, 7, border_width=1)

// COLORES PROFESIONALES
bg_main   = color.new(color.black, 0)
bg_header = color.rgb(20, 20, 20)
bg_cell   = color.rgb(15, 15, 15)

txt_main  = color.white
txt_sub   = color.gray
accent    = color.rgb(0, 140, 255)

// ===== DISPLAY =====
if barstate.islast
    
    // HEADER
    table.cell(panel, 0, 0, "POSITION SIZE", text_color=txt_main, bgcolor=bg_header)
    table.cell(panel, 1, 0, "CALCULATOR", text_color=accent, bgcolor=bg_header)
    
    // AUTHOR (discreto)
    table.cell(panel, 0, 1, "Author", text_color=txt_sub, bgcolor=bg_cell)
    table.cell(panel, 1, 1, "Sebastián Figueroa", text_color=txt_main, bgcolor=bg_cell)
    
    // SYMBOL
    table.cell(panel, 0, 2, "Symbol", text_color=txt_sub, bgcolor=bg_cell)
    table.cell(panel, 1, 2, syminfo.ticker, text_color=txt_main, bgcolor=bg_cell)
    
    // BALANCE
    table.cell(panel, 0, 3, "Balance", text_color=txt_sub, bgcolor=bg_cell)
    table.cell(panel, 1, 3, "$" + str.tostring(balance), text_color=txt_main, bgcolor=bg_cell)
    
    // RISK
    table.cell(panel, 0, 4, "Risk", text_color=txt_sub, bgcolor=bg_cell)
    table.cell(panel, 1, 4, "$" + str.tostring(risk_amount), text_color=color.orange, bgcolor=bg_cell)
    
    // SL
    table.cell(panel, 0, 5, "Stop Loss", text_color=txt_sub, bgcolor=bg_cell)
    table.cell(panel, 1, 5, str.tostring(sl_pips) + " pips", text_color=color.red, bgcolor=bg_cell)
    
    // RESULTADO (DESTACADO)
    table.cell(panel, 0, 6, "Lot Size", text_color=accent, bgcolor=bg_cell)
    table.cell(panel, 1, 6, str.tostring(lot_final), text_color=color.lime, bgcolor=bg_cell)
````
