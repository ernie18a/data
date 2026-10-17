# WinRate & Profit Calculator [AloneMask]

- url: https://www.tradingview.com/script/mWB45hmk-WinRate-Profit-Calculator-AloneMask/
- type: indicator
- pine_id: PUB;f1d2aff786be42818734ae7293752e32
- version: 2.0

## Description

Very simple calculator for WinRate or amount of your win/loss trades. Very helpful for backtesting strategies. After opening the settings (or doubleclick directly on the table in the chart), a table will open in which you simply write the size of your trading account and gradually add the number of win/loss trades and the value of the win/loss trades. The calculator will calculate the total number of trades, the dollar value and the winrate. If you only want to calculate the winrate, leave the dollar value and account size fields empty. No more Windows Excel sheets, no more papers on your table - all directly in your chart! If this simple tool is useful for you, click the Boost button to get more exposure for other users.
[image]https://www.tradingview.com/x/el2ZsHpZ/[/image]

## Source Code

````pine
//@version=6
indicator("WinRate & Profit Calculator [AloneMask]", overlay=true)

// --- Inputs ---
account_val = input.float(0.0, "Account [$]", step=0.1, group="Stats")

wins = input.int(0, "Wins", minval=0, group="Stats")
wins_val = input.float(0.0, "Wins [$]", step=0.1, group="Stats")

losses = input.int(0, "Losses", minval=0, group="Stats")
losses_val = input.float(0.0, "Losses [$]", step=0.1, group="Stats")

draws = input.int   (0, "Draws", minval=0, group="Stats")

transparency = input.int(0, "Transparency (%)", minval=0, maxval=100, step=10, group="Style", tooltip="0% = opaque, 100% = fully transparent")

// Table transparency
apply_transparency(col, trans) =>
    color.new(col, trans)

// --- Calculation ---
total_trades = wins + losses + draws
float winRate = (wins + losses) > 0 ? (wins / (wins + losses)) * 100 : 0
float total_price = wins_val - losses_val
float balance_val = account_val + total_price

// Table rendering
var table manualTable = table.new(position.top_right, 3, 8, border_width=1, border_color=color.gray)

if barstate.islast
    // Definition of colors with transparency
    bg_black  = apply_transparency(color.black, transparency)
    bg_green  = apply_transparency(color.green, transparency)
    bg_red    = apply_transparency(color.red, transparency)
    bg_gray   = apply_transparency(color.gray, transparency)
    bg_blue   = apply_transparency(color.blue, transparency)
    bg_navy   = apply_transparency(color.purple, transparency)
    bg_teal   = apply_transparency(color.blue, transparency)
    bg_orange = apply_transparency(color.blue, transparency)
    bg_white  = apply_transparency(color.white, transparency)

    // Text colors
    text_black = color.black
    text_gray  = color.gray

    // 0. Heading
    table.cell(manualTable, 0, 0, "Statistics", bgcolor=bg_black, text_color=color.white, text_size=size.small)
    table.cell(manualTable, 1, 0, "Amount", bgcolor=bg_black, text_color=color.white, text_size=size.small)
    table.cell(manualTable, 2, 0, "Price [$]", bgcolor=bg_black, text_color=color.white, text_size=size.small)
    
    // 1. Account
    table.cell(manualTable, 0, 1, "Account", bgcolor=bg_teal, text_color=color.white, text_size=size.small)
    table.cell(manualTable, 1, 1, "-", bgcolor=bg_white, text_color=text_gray, text_size=size.small) 
    table.cell(manualTable, 2, 1, str.tostring(account_val, "0.0"), bgcolor=bg_white, text_color=text_black, text_size=size.small)
    
    // 2. Wins
    table.cell(manualTable, 0, 2, "Wins", bgcolor=bg_green, text_color=color.white, text_size=size.small)
    table.cell(manualTable, 1, 2, str.tostring(wins), bgcolor=bg_white, text_color=text_black, text_size=size.small)
    table.cell(manualTable, 2, 2, str.tostring(wins_val, "0.0"), bgcolor=bg_white, text_color=text_black, text_size=size.small)
    
    // 3. Losses
    table.cell(manualTable, 0, 3, "Losses", bgcolor=bg_red, text_color=color.white, text_size=size.small)
    table.cell(manualTable, 1, 3, str.tostring(losses), bgcolor=bg_white, text_color=text_black, text_size=size.small)
    table.cell(manualTable, 2, 3, str.tostring(losses_val, "0.0"), bgcolor=bg_white, text_color=text_black, text_size=size.small)
    
    // 4. Draws
    table.cell(manualTable, 0, 4, "Draws", bgcolor=bg_gray, text_color=color.white, text_size=size.small)
    table.cell(manualTable, 1, 4, str.tostring(draws), bgcolor=bg_white, text_color=text_black, text_size=size.small)
    table.cell(manualTable, 2, 4, "-", bgcolor=bg_white, text_color=text_gray, text_size=size.small) 
    
    // 5. Total
    table.cell(manualTable, 0, 5, "Total", bgcolor=bg_blue, text_color=color.white, text_size=size.small)
    table.cell(manualTable, 1, 5, str.tostring(total_trades), bgcolor=bg_white, text_color=text_black, text_size=size.small)
    table.cell(manualTable, 2, 5, str.tostring(total_price, "0.0"), bgcolor=bg_white, text_color=text_black, text_size=size.small) 

    // 6. Balance
    table.cell(manualTable, 0, 6, "Balance", bgcolor=bg_orange, text_color=color.white, text_size=size.small)
    table.cell(manualTable, 1, 6, "-", bgcolor=bg_white, text_color=text_gray, text_size=size.small) 
    table.cell(manualTable, 2, 6, str.tostring(balance_val, "0.0"), bgcolor=bg_white, text_color=text_black, text_size=size.small)
    
    // 7. WinRate
    table.cell(manualTable, 0, 7, "WinRate %", bgcolor=bg_navy, text_color=color.white, text_size=size.small)
    table.cell(manualTable, 1, 7, str.tostring(winRate, "#.##") + "%", bgcolor=bg_white, text_color=text_black, text_size=size.small)
    table.cell(manualTable, 2, 7, "-", bgcolor=bg_white, text_color=text_gray, text_size=size.small)
````
