<!-- tradingview-pine-id: PUB;251ba0c5f75a4c43b6ae4e3c4baa67e3 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Position Size V95

Source: https://www.tradingview.com/script/k3aHxOe4-Position-Size-V95/

## Description

This indicator helps you decide how much you should trade based on your risk.

You simply set your:
- Account Balance
- Risk per Trade (%)
- Entry Price
- Stop-Loss Price

The indicator then automatically calculates:
- Position Size
- Position Value
- Risk per Trade
- Minimum Leverage
- Take Profit
- Potential Profit
- Margin Required
- Trading Fees & GST
- Risk for Multiple Positions

How to Use
1. Set your Account Balance and Risk %
Enter your account balance and how much you want to risk per trade.
2. Set Entry & Stop Loss
When adding the indicator to your chart for the first time, set your Entry Price and Stop-Loss Price.
3. Drag the levels
Once they are set, you can simply drag the Entry and Stop-Loss levels directly on the chart. The calculations will update automatically.
4. Set your Risk:Reward
Choose your preferred R:R, and the indicator will calculate the Take Profit automatically.
5. Check your position size
The dashboard will show your recommended Position Size, Risk, Leverage, Margin and Potential Profit.

Note: This indicator does not provide buy/sell signals or guarantee profits. It is designed only for position sizing and risk management.

---

## Source Code

````pine
//@version=6
indicator("Position Size V95", overlay=true, scale=scale.none, max_lines_count=3, max_labels_count=3)

// ACCOUNT & RISK
account_balance = input.float(1000, "Account Balance (USDT)", minval=0, group="Account & Risk", display=display.none)
risk_percent = input.float(2.0, "Risk per Position (%)", minval=0.1, maxval=100, step=0.1, group="Account & Risk", display=display.none)
desired_rr = input.float(2.0, "Target Risk : Reward", minval=0.1, maxval=100, step=0.1, group="Account & Risk", display=display.none)

// MANUAL DRAG LEVELS
entry_price = input.price(0.20, "Drag Entry Price", group="Manual Drag Levels", confirm=true, display=display.none, tooltip="Click chart to set Entry when adding. Drag its price marker later.")
stop_loss_price = input.price(0.18, "Drag Stop Loss Price", group="Manual Drag Levels", confirm=true, display=display.none, tooltip="Click chart to set Stop Loss when adding. Drag its price marker later.")

manual_tp_override = input.bool(false, "Drag Take Profit Manually", group="Manual Drag Levels", display=display.none, tooltip="Enable to manually set and drag TP. Disable to calculate TP from Target R:R.")
manual_tp_price = input.price(0.25, "Drag Take Profit Price", group="Manual Drag Levels", active=manual_tp_override, display=display.none, tooltip="Used only when Drag Take Profit Manually is enabled.")

// MULTI-POSITION LEVERAGE
open_positions = input.int(1, "Open Positions at Once", minval=1, maxval=20, group="Multi-Position Leverage", display=display.none, tooltip="Trading margin is split equally between these simultaneous positions.")
margin_allocation_pct = input.float(100, "Capital Allocated to Trading (%)", minval=1, maxval=100, step=1, group="Multi-Position Leverage", display=display.none)
max_exchange_leverage = input.float(20, "Maximum Available Leverage", minval=1, maxval=125, step=1, group="Multi-Position Leverage", display=display.none)

// DELTA EXCHANGE FEES
use_delta_fees = input.bool(true, "Include Delta Trading Fees", group="Delta Exchange Fees", display=display.none, tooltip="Disable this to calculate position sizing and profit without fees.")
entry_order_type = input.string("Maker", "Entry Order Type", options=["Maker", "Taker"], group="Delta Exchange Fees", active=use_delta_fees, display=display.none)
exit_order_type = input.string("Taker", "Exit Order Type", options=["Maker", "Taker"], group="Delta Exchange Fees", active=use_delta_fees, display=display.none)
include_gst = input.bool(true, "Include 18% GST on Fees", group="Delta Exchange Fees", active=use_delta_fees, display=display.none)

// DISPLAY
show_price_labels = input.bool(true, "Show Price Labels", group="Display", display=display.none)
show_trade_lines = input.bool(true, "Show Entry / SL / TP Lines", group="Display", display=display.none)
hide_stale_levels = input.bool(true, "Hide Levels Far From Current Price", group="Display", display=display.none, tooltip="Hides old manual levels after switching to a pair with a very different price.")
stale_distance_pct = input.float(50, "Maximum Distance From Market (%)", minval=1, maxval=1000, step=1, group="Display", display=display.none)

// TRADE LEVELS
is_long = entry_price > stop_loss_price
is_short = entry_price < stop_loss_price
invalid_setup = entry_price == stop_loss_price

raw_risk_per_unit = math.abs(entry_price - stop_loss_price)

auto_take_profit_price = is_long ? entry_price + raw_risk_per_unit * desired_rr :
                         is_short ? entry_price - raw_risk_per_unit * desired_rr :
                         entry_price

take_profit_price = manual_tp_override ? manual_tp_price : auto_take_profit_price

invalid_tp = (is_long and take_profit_price <= entry_price) or
             (is_short and take_profit_price >= entry_price) or
             take_profit_price <= 0

// DELTA FEES
maker_fee_pct = 0.02
taker_fee_pct = 0.05
gst_multiplier = include_gst ? 1.18 : 1.0

entry_base_fee_pct = entry_order_type == "Maker" ? maker_fee_pct : taker_fee_pct
exit_base_fee_pct = exit_order_type == "Maker" ? maker_fee_pct : taker_fee_pct

entry_fee_rate = use_delta_fees ? (entry_base_fee_pct * gst_multiplier) / 100 : 0.0
exit_fee_rate = use_delta_fees ? (exit_base_fee_pct * gst_multiplier) / 100 : 0.0

// POSITION SIZING
entry_fee_per_unit = entry_price * entry_fee_rate
stop_exit_fee_per_unit = stop_loss_price * exit_fee_rate
risk_per_unit = raw_risk_per_unit + entry_fee_per_unit + stop_exit_fee_per_unit

valid_setup = not invalid_setup and not invalid_tp and risk_per_unit > 0

risk_per_position = account_balance * (risk_percent / 100)
total_portfolio_risk = risk_per_position * open_positions

position_size = valid_setup ? risk_per_position / risk_per_unit : na
position_value = valid_setup ? position_size * entry_price : na

// MULTI-POSITION LEVERAGE
total_allocated_margin = account_balance * (margin_allocation_pct / 100)
margin_per_position = total_allocated_margin / open_positions

minimum_leverage_raw = valid_setup and margin_per_position > 0 ?
     position_value / margin_per_position :
     na

// Always round UP to a whole-number leverage level.
minimum_leverage = na(minimum_leverage_raw) ?
     na :
     math.max(1.0, math.ceil(minimum_leverage_raw))

max_position_value = margin_per_position * max_exchange_leverage
capital_sufficient = valid_setup and position_value <= max_position_value

// PROFIT CALCULATIONS
gross_profit_per_unit = valid_setup ? math.abs(take_profit_price - entry_price) : na
tp_exit_fee_per_unit = valid_setup ? take_profit_price * exit_fee_rate : na

profit_per_unit = valid_setup ?
     gross_profit_per_unit - entry_fee_per_unit - tp_exit_fee_per_unit :
     na

potential_profit = valid_setup ? position_size * profit_per_unit : na

trade_direction = invalid_setup ? "INVALID SETUP" :
                  invalid_tp ? "INVALID TP" :
                  is_long ? "LONG" : "SHORT"

// STALE-LEVEL PROTECTION
entry_distance_pct = close > 0 ? math.abs(entry_price - close) / close * 100 : 0
sl_distance_pct = close > 0 ? math.abs(stop_loss_price - close) / close * 100 : 0
tp_distance_pct = close > 0 ? math.abs(take_profit_price - close) / close * 100 : 0

stale_levels = hide_stale_levels and (
     entry_distance_pct > stale_distance_pct or
     sl_distance_pct > stale_distance_pct or
     tp_distance_pct > stale_distance_pct)

show_active_levels = show_trade_lines and not stale_levels

plot(na, title="Position Size", display=display.none)

// LINES
entry_color = is_long ? color.rgb(33, 150, 243) : is_short ? color.rgb(255, 152, 0) : color.gray
sl_color = color.rgb(239, 83, 80)
tp_color = color.rgb(76, 175, 80)

var line entry_line = na
var line sl_line = na
var line tp_line = na

if na(entry_line)
    entry_line := line.new(bar_index, entry_price, bar_index + 1, entry_price, color=entry_color, width=2, extend=extend.both)
    sl_line := line.new(bar_index, stop_loss_price, bar_index + 1, stop_loss_price, color=sl_color, width=2, extend=extend.both)
    tp_line := line.new(bar_index, take_profit_price, bar_index + 1, take_profit_price, color=tp_color, width=2, extend=extend.both)

line.set_y1(entry_line, entry_price)
line.set_y2(entry_line, entry_price)
line.set_color(entry_line, show_active_levels ? entry_color : color.new(entry_color, 100))

line.set_y1(sl_line, stop_loss_price)
line.set_y2(sl_line, stop_loss_price)
line.set_color(sl_line, show_active_levels ? sl_color : color.new(sl_color, 100))

line.set_y1(tp_line, take_profit_price)
line.set_y2(tp_line, take_profit_price)
line.set_color(tp_line, show_active_levels ? tp_color : color.new(tp_color, 100))

// DASHBOARD
var table dashboard = table.new(
     position.bottom_right, 2, 13,
     bgcolor=color.white,
     border_width=1,
     border_color=color.rgb(190, 190, 190))

label_bg = color.rgb(245, 247, 250)
header_color = is_long ? color.rgb(25, 118, 210) : is_short ? color.rgb(239, 108, 0) : color.gray

if barstate.islast
    leverage_color = not valid_setup or not capital_sufficient ? color.red :
                     minimum_leverage <= 3 ? color.rgb(46, 125, 50) :
                     minimum_leverage <= 10 ? color.rgb(245, 124, 0) :
                     color.red

    status_text = stale_levels ? "RESET LEVELS" :
                  not valid_setup ? trade_direction :
                  not capital_sufficient ? "LEVERAGE TOO LOW" :
                  trade_direction + " ✓"

    status_color = stale_levels ? color.rgb(245, 124, 0) :
                   not valid_setup or not capital_sufficient ? color.rgb(198, 40, 40) :
                   header_color

    profit_title = use_delta_fees ? "Net Potential Profit" : "Potential Profit"

    table.cell(dashboard, 0, 0, "POSITION SIZE V9.5", bgcolor=status_color, text_color=color.white, text_size=size.normal)
    table.cell(dashboard, 1, 0, status_text, bgcolor=status_color, text_color=color.white, text_size=size.normal)

    table.cell(dashboard, 0, 1, "Account Balance", bgcolor=label_bg, text_color=color.black)
    table.cell(dashboard, 1, 1, str.tostring(account_balance, "#,###.##") + " USDT", text_color=color.black)

    table.cell(dashboard, 0, 2, "Open Positions", bgcolor=label_bg, text_color=color.black)
    table.cell(dashboard, 1, 2, str.tostring(open_positions) + " positions", text_color=color.rgb(123, 31, 162))

    table.cell(dashboard, 0, 3, "Margin per Position", bgcolor=label_bg, text_color=color.black)
    table.cell(dashboard, 1, 3, str.tostring(margin_per_position, "#,###.##") + " USDT", text_color=color.rgb(123, 31, 162))

    table.cell(dashboard, 0, 4, "Risk per Position", bgcolor=label_bg, text_color=color.black)
    table.cell(dashboard, 1, 4, str.tostring(risk_per_position, "#,###.##") + " USDT  (" + str.tostring(risk_percent, "#0.##") + "%)", text_color=color.red)

    table.cell(dashboard, 0, 5, "Total Portfolio Risk", bgcolor=label_bg, text_color=color.black)
    table.cell(dashboard, 1, 5, str.tostring(total_portfolio_risk, "#,###.##") + " USDT  (" + str.tostring(risk_percent * open_positions, "#0.##") + "%)", text_color=color.red)

    table.cell(dashboard, 0, 6, "Target R:R", bgcolor=label_bg, text_color=color.black)
    table.cell(dashboard, 1, 6, "1:" + str.tostring(desired_rr, "#0.0"), text_color=color.rgb(46, 125, 50))

    table.cell(dashboard, 0, 7, "Position Size", bgcolor=label_bg, text_color=color.black)
    table.cell(dashboard, 1, 7, na(position_size) ? "---" : str.tostring(position_size, "#,###.####") + " units", text_color=color.blue)

    table.cell(dashboard, 0, 8, "Position Value", bgcolor=label_bg, text_color=color.black)
    table.cell(dashboard, 1, 8, na(position_value) ? "---" : str.tostring(position_value, "#,###.##") + " USDT", text_color=color.blue)

    table.cell(dashboard, 0, 9, "Minimum Leverage", bgcolor=label_bg, text_color=color.black)
    table.cell(dashboard, 1, 9, na(minimum_leverage) ? "---" : str.tostring(minimum_leverage, "#") + "×", text_color=leverage_color)

    table.cell(dashboard, 0, 10, "Maximum Position Value", bgcolor=label_bg, text_color=color.black)
    table.cell(dashboard, 1, 10, str.tostring(max_position_value, "#,###.##") + " USDT", text_color=color.black)

    table.cell(dashboard, 0, 11, "Margin Status", bgcolor=label_bg, text_color=color.black)
    table.cell(dashboard, 1, 11, stale_levels ? "Reset Entry / SL points" : not valid_setup ? "Fix setup first" : capital_sufficient ? "Sufficient ✓" : "Increase leverage / reduce size", text_color=stale_levels or not capital_sufficient or not valid_setup ? color.red : color.rgb(46, 125, 50))

    table.cell(dashboard, 0, 12, profit_title, bgcolor=label_bg, text_color=color.black)
    table.cell(dashboard, 1, 12, na(potential_profit) ? "---" : "+" + str.tostring(potential_profit, "#,###.##") + " USDT", text_color=color.rgb(46, 125, 50))

// RIGHT-SIDE LABELS
var label entry_label = na
var label tp_label = na
var label sl_label = na

if na(entry_label)
    entry_label := label.new(bar_index, entry_price, "", style=label.style_label_left, size=size.small)
    tp_label := label.new(bar_index, take_profit_price, "", style=label.style_label_left, size=size.small)
    sl_label := label.new(bar_index, stop_loss_price, "", style=label.style_label_left, size=size.small)

if barstate.islast
    profit_prefix = use_delta_fees ? "Net +" : "Profit +"

    entry_text = valid_setup ?
         trade_direction + " ENTRY  " + str.tostring(entry_price, format.mintick) +
         "  |  Qty: " + str.tostring(position_size, "#,###.####") +
         "  |  Lev: " + str.tostring(minimum_leverage, "#") + "×" :
         "INVALID SETUP — Check Entry, SL and TP"

    tp_text = valid_setup ?
         "TAKE PROFIT  " + str.tostring(take_profit_price, format.mintick) +
         "  |  " + profit_prefix + str.tostring(potential_profit, "#,###.##") + " USDT" :
         ""

    sl_text = valid_setup ?
         "STOP LOSS  " + str.tostring(stop_loss_price, format.mintick) +
         "  |  Risk -" + str.tostring(risk_per_position, "#,###.##") + " USDT" :
         ""

    label.set_xy(entry_label, bar_index + 15, entry_price)
    label.set_text(entry_label, show_price_labels and not stale_levels ? entry_text : "")
    label.set_color(entry_label, color.new(entry_color, 15))
    label.set_textcolor(entry_label, color.white)

    label.set_xy(tp_label, bar_index + 15, take_profit_price)
    label.set_text(tp_label, show_price_labels and not stale_levels ? tp_text : "")
    label.set_color(tp_label, color.new(tp_color, 15))
    label.set_textcolor(tp_label, color.black)

    label.set_xy(sl_label, bar_index + 15, stop_loss_price)
    label.set_text(sl_label, show_price_labels and not stale_levels ? sl_text : "")
    label.set_color(sl_label, color.new(sl_color, 15))
    label.set_textcolor(sl_label, color.white)
````
