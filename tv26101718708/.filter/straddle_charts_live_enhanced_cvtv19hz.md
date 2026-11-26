# Straddle Charts - Live (Enhanced)

- url: https://www.tradingview.com/script/CvTv19HZ-Straddle-Charts-Live-Enhanced/
- type: indicator
- pine_id: PUB;4548110536ac45fdb0015be36d0508c9
- version: 1.0

## Description

Track options straddles with ease using the Straddle Charts - Live (Enhanced) indicator! Originally inspired by @mudraminer, this Pine Script v5 tool visualizes live call, put, and straddle prices for instruments like BANKNIFTY. Plotting call (green), put (red), and straddle (black) prices in a separate pane, it offers real-time insights for straddle strategy traders.

Key Features:





Live Data: Fetches 1-minute (customizable) option prices with error handling for invalid symbols.



Price Table: Displays call, put, straddle prices, and percentage change in a top-left table.



Volatility Alerts: Highlights bars with straddle price changes above a user-defined threshold (default 5%) with a yellow background and concise % labels.



Robust Design: Prevents plot errors with na checks and provides clear error messages.

How to Use: Input your call/put option symbols (e.g., NSE:NIFTY250814C24700), set the timeframe, and adjust the volatility threshold. Monitor straddle costs and volatility for informed trading decisions.

Perfect for options traders seeking a simple, reliable tool to track straddle performance. Check it out and share your feedback!

## Source Code

````pine
//@version=5
indicator("Straddle Charts - Live (Enhanced)", overlay=false, shorttitle="Straddle Enhanced")

// Credits: Original concept by @mudraminer, enhanced with error handling, table display, and volatility alerts.

// Step 1: User inputs
call_option_symbol = input.symbol(title="Call Option", defval="NIFTY250814C24700")
put_option_symbol = input.symbol(title="Put Option", defval="NIFTY250814P24700")
timeframe = input.timeframe(title="Timeframe", defval="1", tooltip="Timeframe for fetching option prices (e.g., 1 for 1-minute)")
volatility_threshold = input.float(title="Volatility Threshold (%)", defval=5.0, minval=0.1, step=0.1, tooltip="Highlight straddle price changes above this percentage")

// Step 2: Fetch live prices for call and put options
call_price = request.security(call_option_symbol, timeframe, close, ignore_invalid_symbol=true)
put_price = request.security(put_option_symbol, timeframe, close, ignore_invalid_symbol=true)

// Step 3: Calculate straddle price
straddle_price = na(call_price) or na(put_price) ? na : call_price + put_price

// Step 4: Error handling for invalid data
if na(call_price) or na(put_price)
    label.new(bar_index, high, "Error: Invalid symbol or no data for Call/Put", color=color.red, style=label.style_label_down, textcolor=color.white)

// Step 5: Calculate straddle price change (for volatility detection)
straddle_change = ta.change(straddle_price) / straddle_price[1] * 100
highlight_volatility = not na(straddle_change) and math.abs(straddle_change) > volatility_threshold

// Step 6: Plot call, put, and straddle prices
plot_call = plot(not na(call_price) ? call_price : na, color=color.green, linewidth=2, title="Call Option Price")
plot_put = plot(not na(put_price) ? put_price : na, color=color.red, linewidth=2, title="Put Option Price")
plot_straddle = plot(not na(straddle_price) ? straddle_price : na, color=color.white, linewidth=2, title="Straddle Price")

// Step 7: Highlight significant straddle price changes
bgcolor(highlight_volatility ? color.new(color.yellow, 80) : na, title="Volatility Highlight")

// Step 8: Display prices in a table
var table price_table = table.new(position.top_left, 3, 4, border_width=1, border_color=color.gray)
if barstate.islast
    table.cell(price_table, 0, 0, "Call Price", bgcolor=color.green, text_color=color.white)
    table.cell(price_table, 1, 0, not na(call_price) ? str.tostring(call_price, "#.##") : "N/A", bgcolor=color.green, text_color=color.white)
    table.cell(price_table, 0, 1, "Put Price", bgcolor=color.red, text_color=color.white)
    table.cell(price_table, 1, 1, not na(put_price) ? str.tostring(put_price, "#.##") : "N/A", bgcolor=color.red, text_color=color.white)
    table.cell(price_table, 0, 2, "Straddle Price", bgcolor=color.black, text_color=color.white)
    table.cell(price_table, 1, 2, not na(straddle_price) ? str.tostring(straddle_price, "#.##") : "N/A", bgcolor=color.black, text_color=color.white)
    table.cell(price_table, 0, 3, "Straddle Change (%)", bgcolor=color.gray, text_color=color.white)
    table.cell(price_table, 1, 3, not na(straddle_change) ? str.tostring(straddle_change, "#.##") : "N/A", bgcolor=color.gray, text_color=color.white)

// Step 9: Debugging labels for straddle price
if highlight_volatility
    label.new(bar_index, straddle_price, "V: " + str.tostring(straddle_change, "#.##") + "%", color=color.yellow, style=label.style_label_down, textcolor=color.black)
````
