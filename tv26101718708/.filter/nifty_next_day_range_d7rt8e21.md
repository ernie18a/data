# Nifty Next Day Range

- url: https://www.tradingview.com/script/D7rt8e21-Nifty-Next-Day-Range/
- type: indicator
- pine_id: PUB;a59f80746e8e4a49810a223c5fd060c9
- version: 1.0

## Description

This Pine Script indicator, "Nifty Next Day Range", calculates and displays expected price ranges for the Nifty 50 index based on the India VIX (volatility index).

How It Works
The script uses daily closing prices and applies a standard volatility-based formula:

Data Sources (from previous day's close):

Nifty 50 closing price

India VIX closing price

Key Calculations:

A = VIX Close ÷ 16 (converts annualized volatility to daily)

AA = (Nifty Close × A) ÷ 100 (daily expected move in points)

Upside Range = Nifty Close + AA

Downside Range = Nifty Close - AA

Visual Elements:

Green line: Upside resistance level

Red line: Downside support level

Gray line: Previous day's closing price (baseline)

Purple fill: The calculated range zone

Background color: Green when price exceeds upside range, red when below downside range

Information Table (top-right corner):

Displays all calculated values (Nifty close, VIX close, A value, range width, upside/downside levels)

Alerts:

Triggers when Nifty crosses above the upside range or below the downside range

Practical Use
This is a volatility-based range forecast tool. Traders use it to identify:

Expected support/resistance levels for the next trading day

Overbought/oversold conditions (when price trades outside the calculated range)

Volatility-adjusted price targets

The formula (VIX ÷ 16) is the standard method for converting annualized implied volatility into a 1-standard-deviation daily expected move (assuming 252 trading days: √252 ≈ 16).

## Source Code

````pine
//@version=6
indicator(title="Nifty Next Day Range", shorttitle="Nifty Next Day Range", overlay=true)

// -----------------------------------------------------------------------------
// 1. GET DAILY CLOSING VALUES (Using Current Day's Close)
// -----------------------------------------------------------------------------
// Get daily close values with proper lookahead settings
nifty_daily = request.security("NSE:NIFTY", "D", close, lookahead=barmerge.lookahead_off)
vix_daily = request.security("NSE:INDIAVIX", "D", close, lookahead=barmerge.lookahead_off)

// USING CURRENT DAY'S CLOSE (Matches "PREV. Day" column on NSE website)
prev_day_close_nifty = nifty_daily
prev_day_close_vix = vix_daily

// -----------------------------------------------------------------------------
// 2. CALCULATIONS (CORRECTED: VIX ÷ 16, NOT VIX × 16)
// -----------------------------------------------------------------------------
// A = INDIAVIX Close ÷ 16
A = prev_day_close_vix / 16

// AA = (NIFTY Close × A) / 100
AA = (prev_day_close_nifty * A) / 100

// Nifty Upside Range = NIFTY Close + AA
nifty_upside_range = prev_day_close_nifty + AA

// Nifty Downside Range = NIFTY Close - AA
nifty_downside_range = prev_day_close_nifty - AA

// -----------------------------------------------------------------------------
// 3. CURRENT DAY'S DATA FOR REFERENCE
// -----------------------------------------------------------------------------
today_open = request.security("NSE:NIFTY", "D", open, lookahead=barmerge.lookahead_off)
today_high = request.security("NSE:NIFTY", "D", high, lookahead=barmerge.lookahead_off)
today_low = request.security("NSE:NIFTY", "D", low, lookahead=barmerge.lookahead_off)

// -----------------------------------------------------------------------------
// 4. PLOTTING
// -----------------------------------------------------------------------------
// Plot the range levels
plot(nifty_upside_range, title="Upside Range", color=color.new(color.green, 0), 
     linewidth=2, style=plot.style_stepline)

plot(nifty_downside_range, title="Downside Range", color=color.new(color.red, 0), 
     linewidth=2, style=plot.style_stepline)

plot(prev_day_close_nifty, title="NIFTY Close (Base)", color=color.new(color.gray, 70), 
     linewidth=1, style=plot.style_stepline)

// Fill the range between upside and downside
fill(plot(nifty_upside_range, title="Upside", display=display.none), 
     plot(nifty_downside_range, title="Downside", display=display.none), 
     color=color.new(color.purple, 90), title="Range Fill")

// -----------------------------------------------------------------------------
// 5. BACKGROUND COLOR BASED ON CURRENT PRICE POSITION
// -----------------------------------------------------------------------------
bgcolor(close > nifty_upside_range ? color.new(color.green, 85) : 
        close < nifty_downside_range ? color.new(color.red, 85) : na)

// -----------------------------------------------------------------------------
// 6. TABLE DISPLAY (Shows all calculated values)
// -----------------------------------------------------------------------------
var table range_table = table.new(position.top_right, 2, 7, bgcolor=color.new(color.black, 80), 
                                  border_color=color.new(color.white, 50), frame_width=1)

// Headers
table.cell(range_table, 0, 0, "Parameter", text_color=color.white, text_size=size.small, bgcolor=color.new(color.blue, 0))
table.cell(range_table, 1, 0, "Value", text_color=color.white, text_size=size.small, bgcolor=color.new(color.blue, 0))

// Values
table.cell(range_table, 0, 1, "NIFTY Close (Base)", text_color=color.white, text_size=size.small)
table.cell(range_table, 1, 1, str.tostring(prev_day_close_nifty, "#.##"), text_color=color.new(color.green, 0), text_size=size.small)

table.cell(range_table, 0, 2, "VIX Close", text_color=color.white, text_size=size.small)
table.cell(range_table, 1, 2, str.tostring(prev_day_close_vix, "#.##"), text_color=color.new(color.orange, 0), text_size=size.small)

table.cell(range_table, 0, 3, "A = VIX ÷ 16", text_color=color.white, text_size=size.small)
table.cell(range_table, 1, 3, str.tostring(A, "#.##"), text_color=color.new(color.yellow, 0), text_size=size.small)

table.cell(range_table, 0, 4, "AA = Range Width", text_color=color.white, text_size=size.small)
table.cell(range_table, 1, 4, str.tostring(AA, "#.##"), text_color=color.new(color.yellow, 0), text_size=size.small)

table.cell(range_table, 0, 5, "Upside Range", text_color=color.white, text_size=size.small)
table.cell(range_table, 1, 5, str.tostring(nifty_upside_range, "#.##"), text_color=color.new(color.green, 0), text_size=size.small)

table.cell(range_table, 0, 6, "Downside Range", text_color=color.white, text_size=size.small)
table.cell(range_table, 1, 6, str.tostring(nifty_downside_range, "#.##"), text_color=color.new(color.red, 0), text_size=size.small)

// -----------------------------------------------------------------------------
// 7. ALERT CONDITIONS
// -----------------------------------------------------------------------------
alertcondition(ta.crossover(close, nifty_upside_range), title="Above Upside Range", message="Nifty crossed above upside range")
alertcondition(ta.crossunder(close, nifty_downside_range), title="Below Downside Range", message="Nifty crossed below downside range")
````
