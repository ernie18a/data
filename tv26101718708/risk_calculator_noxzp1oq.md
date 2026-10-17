# Risk calculator

- url: https://www.tradingview.com/script/nOxZP1Oq-risk-calculator/
- type: indicator
- pine_id: PUB;78b713275da34c739b4377ba43cb11db
- version: 1.0

## Description

Script Name
Risk Calculator

Purpose
A trading tool that calculates position size (lot/coin quantity) based on a fixed percentage risk of the account balance. The script visualizes entry, stop-loss, and take-profit levels on the chart and displays detailed trade statistics in a table.

Core Workflow
User Input: balance, maximum risk percentage, entry/stop/take prices (manually confirmed on the chart).

Direction Detection: analyzes price positions to determine if the trade is LONG (take > stop) or SHORT (take < stop). Invalid combinations trigger "SETUP ERROR".

Key Metrics Calculation:

Maximum loss in dollars (max_loss_usd)

Distance from entry to stop and take in points and percentages

Position Sizing (two scenarios):

If stop percentage < max risk: volume = balance / entry price (entire balance at risk, but stop triggers earlier)

Otherwise: volume = max loss / distance to stop (risk strictly limited to the set percentage)

Profit/Loss Calculation in dollars and risk/reward ratio (RR).

Visual Elements Rendering on the last confirmed or real-time bar:

Green profit zone (between entry and take)

Red loss zone (between stop and entry)

Horizontal level lines with labels

Information table in the bottom-right corner

Technologies / Libraries Used
Pine Script v6 — TradingView's native scripting language

Built-in functions:

input.float(), input.price() — data input

math.round_to_mintick() — rounding to minimum tick size

math.abs() — absolute value

table.new(), table.cell() — table creation

box.new() — rectangular areas

line.new() — trend lines

label.new() — text labels

Input Data
Balance ($) — account balance in USD (default: 1000)

Max Risk (%) — maximum risk per trade as percentage of balance (preset options: 0.25, 0.5, 0.75, 1, 2, 3, 5)

ENTRY — entry price (confirmed by clicking on the chart)

STOP — stop-loss price (confirmed by clicking on the chart)

TAKE — take-profit price (confirmed by clicking on the chart)

Output Data
Chart Visuals:

Colored profit (green) and loss (red) zones

Horizontal lines with price labels

Information Table (bottom-right corner):

Balance

Maximum risk in % and $

Trade amount in $

Volume in coins

Stop in % and $ (loss)

Take in % and $ (profit)

Risk/Reward ratio (1:X)

Key Features
Automatic position sizing with strict risk limitation

Level visualization directly on the chart for clear analysis

Flexible setup via manual price input on the chart

Risk/Reward ratio display (RR) for trade efficiency assessment

Support for both directions (LONG and SHORT) with automatic detection

Error protection: handles invalid price combinations (displays "ERROR" in the table)

Error Handling & Exceptions
Invalid price layouts (e.g., LONG with take < stop or entry outside the range) display "ERROR" in all table cells instead of numbers.

The direction variable is set to "SETUP ERROR", which blocks calculations and shows errors across all table fields.

The err flag checks for errors and replaces all numeric values with "ERROR" strings.

Dependencies & Environment Requirements
Platform: TradingView (web or desktop application)

Pine Script Version: v6

Timeframe: any (script is timeframe-independent)

Ticker: any (cryptocurrencies, stocks, forex, etc.)

No additional installations required — the script runs natively within TradingView

Implementation Details
Objects (lines, boxes, table) are created once on the last bar using barstate.islastconfirmedhistory and the objects_created flag to prevent redrawing on chart updates.

Visual elements are drawn with a 30-bar horizontal offset to the right for convenient label placement.

All calculations are performed in real-time as input parameters change.

## Source Code

````pine
//@version=6
indicator("Risk calculator", overlay=true)

// Inputs
balance = input.float(1000.00, "Balance ($)")
max_loss_pct = input.float(2, "Max Risk (%)", options=[0.25,0.5,0.75,1,2,3,5])
entry = math.round_to_mintick(input.price(21000, "ENTRY", confirm=true))
stop = math.round_to_mintick(input.price(20500, "STOP", confirm=true))
take = math.round_to_mintick(input.price(22000, "TAKE", confirm=true))

// Direction logic
is_long = take > stop and entry > take ? false : take > stop and entry < stop ? false : take > stop
is_short = take < stop and entry < take ? false : take < stop and entry > stop ? false : take < stop
direction = is_long ? "LONG" : is_short ? "SHORT" : "SETUP ERROR"

// Calculations
max_loss_usd = max_loss_pct / 100 * balance
entry_to_stop = math.abs(stop - entry)
entry_to_take = math.abs(take - entry)
stop_pct = entry_to_stop / entry * 100
take_pct = entry_to_take / entry * 100
risk_pct_diff = balance / 100 * max_loss_pct

// Position sizing
var float qty_coin = na
var float loss_usd = na
var float profit_usd = na
var float qty_usd = na

if stop_pct < max_loss_pct
    qty_coin := balance / entry
    loss_usd := balance / 100 * stop_pct
    profit_usd := balance / 100 * take_pct
    qty_usd := balance
else
    qty_coin := max_loss_usd / entry_to_stop
    loss_usd := qty_coin * entry_to_stop
    profit_usd := qty_coin * entry_to_take
    qty_usd := qty_coin * entry

rr_ratio = profit_usd / loss_usd

// Labels text
label_tp = "Take: " + str.tostring(take)
label_entry = "Entry: " + str.tostring(entry)
label_sl = "Stop: " + str.tostring(stop)

// Persistent objects
var bool objects_created = false
var table tbl = na
var box profit_box = na
var box loss_box = na
var line entry_line = na
var line tp_line = na
var line sl_line = na
var label tp_label = na
var label entry_label = na
var label sl_label = na

// Create objects once on the last bar
if (barstate.islastconfirmedhistory or barstate.isrealtime) and not objects_created
    objects_created := true
    
    // Create table
    tbl := table.new(position.bottom_right, 2, 7, 
      frame_color=color.white, 
      frame_width=1,
      border_color=color.white,
      border_width=1,
      bgcolor=color.new(#11182b, 0))
    
    err = direction == "SETUP ERROR"
    
    // Table rows
    table.cell(tbl, 0, 0, "Balance:", text_color=color.white, text_halign=text.align_left, text_size=size.small)
    table.cell(tbl, 1, 0, "$" + str.tostring(balance), text_color=color.white, text_halign=text.align_left, text_size=size.small)
    
    table.cell(tbl, 0, 1, "Max Risk:", text_color=color.white, text_halign=text.align_left, text_size=size.small)
    table.cell(tbl, 1, 1, str.tostring(max_loss_pct) + "% ($" + str.tostring(risk_pct_diff, '#.##') + ")", text_color=color.white, text_halign=text.align_left, text_size=size.small)
    
    table.cell(tbl, 0, 2, "Amount:", text_color=color.white, text_halign=text.align_left, text_size=size.small)
    table.cell(tbl, 1, 2, err ? "ERROR" : "$" + str.tostring(qty_usd, '#.##'), text_color=color.white, text_halign=text.align_left, text_size=size.small)
    
    table.cell(tbl, 0, 3, "Volume:", text_color=color.white, text_halign=text.align_left, text_size=size.small)
    table.cell(tbl, 1, 3, err ? "ERROR" : str.tostring(qty_coin, '#.##'), text_color=color.white, text_halign=text.align_left, text_size=size.small)
    
    table.cell(tbl, 0, 4, "Stop:", text_color=color.white, text_halign=text.align_left, text_size=size.small)
    table.cell(tbl, 1, 4, err ? "ERROR" : str.tostring(stop_pct, '#.##') + "% ($" + str.tostring(loss_usd, '#.##') + ")", text_color=color.white, text_halign=text.align_left, text_size=size.small)
    
    table.cell(tbl, 0, 5, "Take:", text_color=color.white, text_halign=text.align_left, text_size=size.small)
    table.cell(tbl, 1, 5, err ? "ERROR" : str.tostring(take_pct, '#.##') + "% ($" + str.tostring(profit_usd, '#.##') + ")", text_color=color.white, text_halign=text.align_left, text_size=size.small)
    
    table.cell(tbl, 0, 6, "Stop/Take:", text_color=color.white, text_halign=text.align_left, text_size=size.small)
    table.cell(tbl, 1, 6, err ? "ERROR" : "1:" + str.tostring(rr_ratio, '#.##'), text_color=color.white, text_halign=text.align_left, text_size=size.small)
    
    // Create visual elements on current bar
    start = bar_index
    finish = bar_index + 30
    
    // Profit and loss zones
    profit_box := box.new(start, take, finish, entry, bgcolor=color.new(color.green, 90), border_width=0)
    loss_box := box.new(start, stop, finish, entry, bgcolor=color.new(color.red, 90), border_width=0)
    
    // Horizontal lines
    entry_line := line.new(start, entry, finish, entry, color=color.blue, width=2)
    tp_line := line.new(start, take, finish, take, color=color.green, width=2)
    sl_line := line.new(start, stop, finish, stop, color=color.red, width=2)
    
    // Labels
    tp_label := label.new(finish, take, label_tp, style=label.style_label_left, color=color.teal, textcolor=color.white)
    entry_label := label.new(finish, entry, label_entry, style=label.style_label_left, color=color.blue, textcolor=color.white)
    sl_label := label.new(finish, stop, label_sl, style=label.style_label_left, color=color.rgb(255, 82, 82), textcolor=color.white)
````
