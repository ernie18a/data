# PSP RSI Buy Sell Signal Indicator

- url: https://www.tradingview.com/script/NufjhSBV-PSP-RSI-Buy-Sell-Signal-Indicator/
- type: indicator
- pine_id: PUB;ed6d62580a224d038d6740b9e15c0e96
- version: 1.0

## Description

PSP RSI Buy Sell 30MTF 75% Target Next Week CE/PE Buy [PSP RSI Buy Sell Signal Indicator]

This indicator is based on RSI crossover and crossunder logic for 30-minute timeframe trading.

How it works:
• BUY Signal: When RSI crosses above the lower band/oversold level.
• SELL Signal: When RSI crosses below the high band/overbought level.
• Default RSI Length: 14
• Default Buy Level: 30
• Default Sell Level: 70

Trading Rules:
• Time Frame: 30 Minutes
• Target: 50% to 100%
• Option Selection: Prefer Next Week CE/PE only
• Stop Loss: No fixed SL, use safe trailing SL
• Position Type: Carry Forward CE/PE
• Initial Quantity: Only 1 Lot

This indicator also includes a trading rules table on the chart and alert conditions for Buy and Sell signals.

Note:
This script is for educational and analysis purposes only. Please do your own research before taking any trade.

## Source Code

````pine
//@version=6
indicator("PSP RSI Buy Sell 30MTF 75% Target Next Week CE Buy", overlay=true)

// --- RSI Inputs & Logic ---
rsiLength   = input.int(14, title="RSI Length", minval=1)
rsiSource   = input.source(close, title="RSI Source")
overbought  = input.int(70, title="RSI High Band (Sell Entry)", minval=1, maxval=100)
oversold    = input.int(30, title="RSI Lower Band (Buy Entry)", minval=1, maxval=100)

rsiValue    = ta.rsi(rsiSource, rsiLength)
buySignal   = ta.crossover(rsiValue, oversold)
sellSignal  = ta.crossunder(rsiValue, overbought)

// --- Plotting Buy/Sell Labels ---
plotshape(buySignal, title="Buy Label", style=shape.labelup, location=location.belowbar, color=color.green, text="BUY", textcolor=color.white, size=size.small)
plotshape(sellSignal, title="Sell Label", style=shape.labeldown, location=location.abovebar, color=color.red, text="SELL", textcolor=color.white, size=size.small)

// --- Info Table (Top Right Corner) ---
var table infoTable = table.new(position.top_right, 2, 7, bgcolor=color.new(color.black, 10), border_width=1, border_color=color.gray)

if barstate.islast
    // Table Header
    table.cell(infoTable, 0, 0, "Trading Rules", text_color=color.yellow, text_halign=text.align_center)
    table.merge_cells(infoTable, 0, 0, 1, 0)
    
    // Row 1: Time Frame
    table.cell(infoTable, 0, 1, "Time Frame", text_color=color.white, text_halign=text.align_left)
    table.cell(infoTable, 1, 1, "30 Mins", text_color=color.aqua, text_halign=text.align_left)
    
    // Row 2: Target
    table.cell(infoTable, 0, 2, "Target", text_color=color.white, text_halign=text.align_left)
    table.cell(infoTable, 1, 2, "50% - 100% (Safe SL Trailing)", text_color=color.green, text_halign=text.align_left)
    
    // Row 3: Option Selection
    table.cell(infoTable, 0, 3, "Option Type", text_color=color.white, text_halign=text.align_left)
    table.cell(infoTable, 1, 3, "Next Week's CE/PE Only", text_color=color.orange, text_halign=text.align_left)
    
    // Row 4: Stop Loss
    table.cell(infoTable, 0, 4, "SL Strategy", text_color=color.white, text_halign=text.align_left)
    table.cell(infoTable, 1, 4, "No Fixed SL", text_color=color.red, text_halign=text.align_left)
    
    // Row 5: Position
    table.cell(infoTable, 0, 5, "Hold Type", text_color=color.white, text_halign=text.align_left)
    table.cell(infoTable, 1, 5, "Carry Forward CE/PE", text_color=color.silver, text_halign=text.align_left)
    
    // Row 6: Quantity
    table.cell(infoTable, 0, 6, "Initial Qty", text_color=color.white, text_halign=text.align_left)
    table.cell(infoTable, 1, 6, "Only 1 Lot", text_color=color.yellow, text_halign=text.align_left)

// --- Alerts ---
alertcondition(buySignal, title="Buy Signal Alert", message="RSI Buy Signal: Check Next Week CE")
alertcondition(sellSignal, title="Sell Signal Alert", message="RSI Sell Signal: Check Next Week PE")
````
