# Dynamic Risk Position Sizer v2

- url: https://www.tradingview.com/script/YBefxQDi-Dynamic-Risk-Position-Sizer-v2/
- type: indicator
- pine_id: PUB;6bcd0ddfccb9425aa393909d892cd0fb
- version: 1.0

## Description

added option of adding SL value in addition to % based SL.

## Source Code

````pine
//@version=5
indicator("Dynamic Risk Position Sizer v2", overlay=true)

// --- 1. INPUTS ---
group_acc = "Account Settings"
group_trade = "Trade Settings"

portfolio_val = input.float(100000, "Total Account Margin", minval=1, group=group_acc)
risk_perc     = input.float(0.65, "Portfolio Risk (%)", step=0.05, group=group_acc, tooltip="Percent of portfolio lost if SL is hit")

// SL Method Toggle
sl_type       = input.string("Percentage", "SL Calculation Mode", options=["Percentage", "Absolute Value"], group=group_trade, tooltip="Choose how to define your Stop Loss")
sl_perc       = input.float(2.0, "Stop Loss (%)", step=0.1, group=group_trade, tooltip="Distance from entry in %")
sl_absolute   = input.float(5.0, "Stop Loss (Price Points)", step=0.1, group=group_trade, tooltip="Fixed price distance from entry (e.g., $5.00 or 50 points)")

// --- 2. CALCULATIONS ---
// Fetch price data
timeframe_val = timeframe.isweekly ? "W" : "D"
close_price = request.security(syminfo.tickerid, timeframe_val, close)

// Determine Risk Per Share based on chosen method
float risk_per_share = 0.0

if sl_type == "Percentage"
    risk_per_share := close_price * (sl_perc / 100)
else
    risk_per_share := sl_absolute

// Position Sizing Logic
risk_dollars = portfolio_val * (risk_perc / 100)
pos_size = risk_per_share > 0 ? math.round(risk_dollars / risk_per_share, 0) : 0
notional_value = pos_size * close_price

// --- 3. DISPLAY TABLE ---
var table riskTable = table.new(position.top_right, 2, 4, border_width = 1, frame_color=color.gray, border_color=color.gray)

if barstate.islast
    // Headers
    table.cell(riskTable, 0, 0, "Account Metric", bgcolor=color.gray, text_color=color.white)
    table.cell(riskTable, 1, 0, "Calculation", bgcolor=color.gray, text_color=color.white)
    
    // Row 1: Portfolio Risk in Dollars
    table.cell(riskTable, 0, 1, "Total Risk ($)", text_color=color.blue, text_halign=text.align_left)
    table.cell(riskTable, 1, 1, str.tostring(risk_dollars, "###,###.##"), text_color=color.white)
    
    // Row 2: Shares to Buy
    table.cell(riskTable, 0, 2, "Shares to Buy", text_color=color.orange, text_halign=text.align_left)
    table.cell(riskTable, 1, 2, str.tostring(pos_size, "0"), text_color=color.white)
    
    // Row 3: Total Position Value
    table.cell(riskTable, 0, 3, "Position Value", text_color=color.rgb(120, 0, 136), text_halign=text.align_left)
    table.cell(riskTable, 1, 3, str.tostring(notional_value, "###,###.##"), text_color=color.white)
````
