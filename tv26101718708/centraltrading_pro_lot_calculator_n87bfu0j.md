# CentralTrading PRO Lot Calculator

- url: https://www.tradingview.com/script/N87BFU0j/
- type: indicator
- pine_id: PUB;4f10d74bbfca45bbb073289a1ae3c71f
- version: 1.0

## Description

🚀 CentralTrading PRO Lot Calculator

Advanced Risk Management & Position Sizing Tool

🧠 Description

CentralTrading PRO Lot Calculator is a professional-grade trading tool designed for traders who understand that consistent profitability comes from risk management, not entries.

This indicator automatically calculates your optimal lot size based on your account balance, predefined risk percentage, and stop loss distance. It provides a structured and disciplined approach to position sizing, eliminating emotional decision-making and helping you execute trades with precision.

Built with the mindset of funded traders and institutional risk models, this tool allows you to operate with a clear, rule-based system directly on your chart.

⚙️ Key Features

✔ Automatic lot size calculation based on risk (%)
✔ Real-time risk display in monetary value
✔ Stop Loss integration for precise position sizing
✔ Clean and professional on-chart dashboard
✔ Fixed panel (non-moving) for better usability
✔ Compatible with Forex, Indices, and Metals

## Source Code

````pine
//@version=5
indicator("CentralTrading PRO Lot Calculator", overlay=true)

// INPUTS
balance = input.float(10000, "Cuenta ($)")
riskPercent = input.float(1, "Riesgo (%)")
sl_pips = input.float(13, "Stop Loss (pips)")
pip_value = input.float(10, "Valor por pip")

// CALCULOS
risk_amount = balance * (riskPercent / 100)
lot_size = sl_pips > 0 ? risk_amount / (sl_pips * pip_value) : na

// TABLA PRO
var panel = table.new(position.bottom_right, 1, 6, border_width=2)

// COLORES
bg_main = color.new(color.black, 10)
bg_header = color.new(color.blue, 80)

// CONTENIDO (TODO EN UNA LINEA)
if barstate.islast
    table.cell(panel, 0, 0, "⚡ Sebastian Figueroa", text_color=color.rgb(7, 177, 234, 14), bgcolor=bg_header, text_halign=text.align_center)
    table.cell(panel, 0, 1, "CentralTrading", text_color=color.aqua, bgcolor=bg_main, text_halign=text.align_center)
    table.cell(panel, 0, 2, "💰 Balance: $" + str.tostring(balance), text_color=color.white, bgcolor=bg_main)
    table.cell(panel, 0, 3, "⚠️ Risk: $" + str.tostring(risk_amount), text_color=color.orange, bgcolor=bg_main)
    table.cell(panel, 0, 4, "📉 SL: " + str.tostring(sl_pips) + " pips", text_color=color.red, bgcolor=bg_main)
    table.cell(panel, 0, 5, "📊 Lot: " + str.tostring(lot_size, "#.##"), text_color=color.lime, bgcolor=bg_main)
````
