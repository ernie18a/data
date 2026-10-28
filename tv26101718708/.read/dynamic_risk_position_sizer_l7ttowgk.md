# Dynamic Risk Position Sizer

- url: https://www.tradingview.com/script/l7ttoWGk-Dynamic-Risk-Position-Sizer/
- type: indicator
- pine_id: PUB;142164c6b040468d8170d679aa09474c
- version: 1.0

## Description

calculates the position size based on fixed portfolio risk and fixed SL %.

## Source Code

````pine
//@version=5
indicator("Dynamic Risk Position Sizer", overlay=true)

// --- 1. INPUTS ---
portfolio_val = input.float(100000, "Total Account Margin", minval=1, group="Account Settings")
risk_perc     = input.float(0.65, "Portfolio Risk (%)", step=0.05, group="Account Settings", tooltip="Percent of portfolio lost if SL is hit")
sl_perc       = input.float(2.0, "Stop Loss (%)", step=0.1, group="Trade Settings", tooltip="Distance from entry to your Stop Loss")

// --- 2. CALCULATIONS ---
// Fetch price data (using the same Daily/Weekly logic from your original code)
timeframe_val = timeframe.isweekly ? "W" : "D"
close_price = request.security(syminfo.tickerid, timeframe_val, close)

// Position Sizing Logic
risk_dollars = portfolio_val * (risk_perc / 100)
risk_per_share = close_price * (sl_perc / 100)
pos_size = risk_per_share > 0 ? math.round(risk_dollars / risk_per_share, 0) : 0
notional_value = pos_size * close_price

// --- 3. DISPLAY TABLE ---
var table riskTable = table.new(position.top_right, 2, 4, border_width = 1, frame_color=color.gray, border_color=color.gray)

if barstate.islast
    // Headers
    table.cell(riskTable, 0, 0, "Account Metric", bgcolor=color.gray, text_color=color.white)
    table.cell(riskTable, 1, 0, "Calculation", bgcolor=color.gray, text_color=color.white)
    
    // Row 1: Portfolio Risk in Dollars
    table.cell(riskTable, 0, 1, "Total Risk", text_color=color.blue, text_halign=text.align_left)
    table.cell(riskTable, 1, 1, str.tostring(risk_dollars, "###,###.##"), text_color=color.rgb(254, 254, 255))
    
    // Row 2: Shares to Buy
    table.cell(riskTable, 0, 2, "Shares to Buy", text_color=color.red, text_halign=text.align_left)
    table.cell(riskTable, 1, 2, str.tostring(pos_size, "0"), text_color=color.rgb(255, 255, 255))
    
    // Row 3: Total Position Value (Leverage Check)
    table.cell(riskTable, 0, 3, "Position Value", text_color=color.rgb(120, 0, 136), text_halign=text.align_left)
    table.cell(riskTable, 1, 3, str.tostring(notional_value, "###,###.##"), text_color=color.rgb(253, 253, 255))
````
