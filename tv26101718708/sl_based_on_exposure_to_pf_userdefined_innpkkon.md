# SL based on exposure to PF (User-Defined)

- url: https://www.tradingview.com/script/INNpkkON-SL-based-on-exposure-to-PF-User-Defined/
- type: indicator
- pine_id: PUB;2c2e1ee3c2124efb90080f66ace1fac7
- version: 1.0

## Description

SL based on Exposure to PF (User-Defined) is a portfolio risk management indicator designed to help traders visualize stop-loss levels based on how much of their total portfolio they are willing to risk on a position. Instead of using arbitrary price percentages, this tool converts portfolio exposure into actionable price levels directly on the chart.

Simply enter your total portfolio value and position size, and the script automatically calculates the number of shares/contracts held. It then plots up to five customizable stop-loss levels based on selected percentages of portfolio risk (for example: risking 0.1%, 0.2%, 0.3%, etc. of total capital). This gives you a clearer understanding of where price should move before a defined portfolio drawdown is reached.

Additional optional price-drop levels can also be displayed (such as 1%, 3%, 5% below current price) for quick market context.

The script also includes a built-in trading discipline reminder panel where users can display messages such as Trading Today or Not Trading Today, helping reinforce consistency and emotional control.

Key Features:
Risk-based stop-loss levels using total portfolio exposure
Automatic position sizing based on live market price
Up to 5 customizable portfolio risk levels
Optional fixed % price-drop markers
Clean chart overlays with labels
Trading discipline reminder panel
Supports dark/light mode display preferences
Best For:
Swing traders
Position traders
Risk-focused investors
Traders managing multiple accounts or larger capital bases

This indicator helps turn portfolio risk into precise chart levels, making stop-loss planning more structured, disciplined, and repeatable.

## Source Code

````pine
//@version=6
indicator("SL based on exposure to PF (User-Defined)", overlay=true, scale = scale.none)

// Ask the user for the number of levels to plot (1-5 levels) via checkboxes
show_level_1 = input.bool(true, title="Show Exposure Level 1")
show_level_2 = input.bool(true, title="Show Exposure Level 2")
show_level_3 = input.bool(true, title="Show Exposure Level 3")
show_level_4 = input.bool(true, title="Show Exposure Level 4")
show_level_5 = input.bool(false, title="Show Exposure Level 5")  // Default to false


show_price_level_1 = input.bool(false, title="Show price Level 1")
show_price_level_2 = input.bool(false, title="Show price Level 2")
show_price_level_3 = input.bool(false, title="Show price Level 3")

// Get the live price (last traded price) of the chart's symbol on the current timeframe
live_price = request.security(syminfo.tickerid, timeframe.period, close, lookahead=barmerge.lookahead_on)

// User Inputs
portfolio_val = input(3000000, title="Portfolio Value")
position_size = input(16.66, title="Position Size (%)")/100

// Assuming live_price is available
num_share = math.floor((portfolio_val * position_size) / live_price)

// Ask the user to provide percentage levels (1-5)
percent1 = input.float(0.1, title="Level 1 | Pf % | Default(.1%)", inline="level1")/100
percent2 = input.float(0.2, title="Level 2 | Pf % | Default(.2%)", inline="level2")/100
percent3 = input.float(0.3, title="Level 3 | Pf % | Default(.3%)", inline="level3")/100
percent4 = input.float(0.4, title="Level 4 | Pf % | Default(.4%)", inline="level4")/100
percent5 = input.float(0.5, title="Level 5 | Pf % | Default(.5%)", inline="level5")/100

// Calculate percentage levels based on the live price
level1_price = live_price - (portfolio_val*percent1)/num_share
level2_price = live_price - (portfolio_val*percent2)/num_share
level3_price = live_price - (portfolio_val*percent3)/num_share
level4_price = live_price - (portfolio_val*percent4)/num_share
level5_price = live_price - (portfolio_val*percent5)/num_share


price_level_1 = input.float(1, title="% Price down from curr price | Default(1%)", inline="level1")/100
price_level_2 = input.float(3, title="% Price down from curr price | Default(1%) Default(2%)", inline="level2")/100
price_level_3 = input.float(5, title="% Price down from curr price | Default(1%)| Default(3%)", inline="level3")/100



// Price in % from curr price
price_1 = live_price*(1-price_level_1)
price_2 = live_price*(1-price_level_2)
price_3 = live_price*(1-price_level_3)


// Check if this is the last bar
is_last_bar = (bar_index == last_bar_index)

// Plot lines, labels, and annotate the live price used for calculations
if is_last_bar
    label.new(bar_index + 15, live_price, str.tostring(num_share), color=color.white, textcolor=color.white, style=label.style_none)
    // Conditional plotting based on user input (checkboxes)
    if show_level_1
        line.new(bar_index, level1_price, bar_index + 4, level1_price, color=color.white, width=1, style=line.style_dashed)
        label.new(bar_index + 10, level1_price, str.tostring(percent1*100) + "% | " + str.tostring(level1_price, "#.1"), color=color.white, textcolor=color.white, style=label.style_none)
        

    if show_level_2
        line.new(bar_index, level2_price, bar_index + 4, level2_price, color=color.white, width=1, style=line.style_dashed)
        label.new(bar_index + 10, level2_price, str.tostring(percent2*100) + "% | " + str.tostring(level2_price, "#.1"), color=color.white, textcolor=color.white, style=label.style_none)

    if show_level_3
        line.new(bar_index, level3_price, bar_index + 4, level3_price, color=color.white, width=1, style=line.style_dashed)
        label.new(bar_index + 10, level3_price, str.tostring(percent3*100) + "% | " + str.tostring(level3_price, "#.1"), color=color.white, textcolor=color.white, style=label.style_none)

    if show_level_4
        line.new(bar_index, level4_price, bar_index + 4, level4_price, color=color.white, width=1, style=line.style_dashed)
        label.new(bar_index + 10, level4_price, str.tostring(percent4*100) + "% | " + str.tostring(level4_price, "#.1"), color=color.white, textcolor=color.white, style=label.style_none)

    if show_level_5
        line.new(bar_index, level5_price, bar_index + 4, level5_price, color=color.white, width=1, style=line.style_dashed)
        label.new(bar_index + 10, level5_price, str.tostring(percent5*100) + "% | " + str.tostring(level5_price, "#.1"), color=color.white, textcolor=color.white, style=label.style_none)


    if show_price_level_1
        line.new(bar_index + 2, price_1, bar_index + 3, price_1, color=color.rgb(232, 235, 236), width=1, style=line.style_solid)

    if show_price_level_2
        line.new(bar_index + 2, price_2, bar_index + 3, price_2, color=color.rgb(232, 235, 236), width=1, style=line.style_solid)

    if show_price_level_3
        line.new(bar_index + 2, price_3, bar_index + 3, price_3, color=color.rgb(232, 235, 236), width=1, style=line.style_solid)


// User inputs for toggling a message. Helps sticking to a process. 
darkMode = input.bool(false, title = 'Enable Dark Mode')
showDisclaimer = input.string('None', title = 'Trade plan', options = ['Trading', 'Not trading', 'None'])
tablePosition = input.string('top_right', title = 'Table Position', options = ['top_right', 'bottom_right'])

userDisclaimer = ''
if showDisclaimer == 'Trading'
    userDisclaimer := 'Trading Today! Stick to the selected stock!!'
else
    userDisclaimer := 'Not trading Today! Turn off the screen!!! Drawdown is happening!!'

// Table
var table disclaimerTable = table.new(position = tablePosition == 'top_right' ? position.top_right : position.bottom_right, columns = 1, rows = 1)
textColor = darkMode ? color.white : color.black

if showDisclaimer != 'None'
    table.cell(disclaimerTable, 0, 0, userDisclaimer, text_color = textColor, text_size = size.large, text_formatting = text.format_none)
````
