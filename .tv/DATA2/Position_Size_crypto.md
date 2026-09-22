<!-- tradingview-pine-id: PUB;3ec6ad4960a94d708ae3dab2c7e2ff8f -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Position Size crypto

Source: https://www.tradingview.com/script/Cgq8L4kM-Position-Size-crypto/

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
indicator("Position Size crypto", overlay=true, max_lines_count=3, max_labels_count=5, max_boxes_count=5)

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
maintenance_margin_pct = input.float(0.5, "Maintenance Margin (%)", minval=0.0, maxval=10.0, step=0.1, group="Multi-Position Leverage", display=display.none, tooltip="Used only to estimate liquidation vs stop. Raise this if the contract's maintenance margin is higher.")

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

position_size = valid_setup ? risk_per_position / risk_per_unit : na
position_value = valid_setup ? position_size * entry_price : na

// MULTI-POSITION LEVERAGE
total_allocated_margin = account_balance * (margin_allocation_pct / 100)
margin_per_position = total_allocated_margin / open_positions

minimum_leverage_raw = valid_setup and margin_per_position > 0 ? position_value / margin_per_position : na

// Always round UP to a whole-number leverage level.
minimum_leverage = na(minimum_leverage_raw) ? na : math.max(1.0, math.ceil(minimum_leverage_raw))

max_position_value = margin_per_position * max_exchange_leverage
capital_sufficient = valid_setup and position_value <= max_position_value

mmr = maintenance_margin_pct / 100.0
float liquidation_price = na
if valid_setup and not na(minimum_leverage) and minimum_leverage > 0
    if is_long
        liquidation_price := math.max(0.0, entry_price * (1.0 - 1.0 / minimum_leverage + mmr))
    else if is_short
        liquidation_price := entry_price * (1.0 + 1.0 / minimum_leverage - mmr)

show_liq_price = valid_setup and not na(minimum_leverage) and minimum_leverage > 1 and not na(liquidation_price) and liquidation_price > 0
liq_before_stop = show_liq_price and (
     (is_long and liquidation_price > stop_loss_price) or
     (is_short and liquidation_price < stop_loss_price))
liq_distance_pct = show_liq_price and entry_price > 0 ? (liquidation_price - entry_price) / entry_price * 100.0 : na

// PROFIT CALCULATIONS
gross_profit_per_unit = valid_setup ? math.abs(take_profit_price - entry_price) : na
tp_exit_fee_per_unit = valid_setup ? take_profit_price * exit_fee_rate : na

profit_per_unit = valid_setup ? gross_profit_per_unit - entry_fee_per_unit - tp_exit_fee_per_unit : na

potential_profit = valid_setup ? position_size * profit_per_unit : na

trade_direction = invalid_setup ? "INVALID SETUP" : invalid_tp ? "INVALID TP" : is_long ? "LONG" : "SHORT"

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

header_color = is_long ? color.rgb(25, 118, 210) : is_short ? color.rgb(239, 108, 0) : color.gray
sl_color = color.red
tp_color = color.lime
entry_line_color = color.blue

// LINES + BOXES (chart time, no date/time inputs)
var line entry_line = na
var line sl_line = na
var line tp_line = na
var box box_tp = na
var box box_sl = na
var label info_label = na
var label guide_label = na

if barstate.islast
    if not na(entry_line)
        line.delete(entry_line)
    if not na(sl_line)
        line.delete(sl_line)
    if not na(tp_line)
        line.delete(tp_line)
    if not na(box_tp)
        box.delete(box_tp)
    if not na(box_sl)
        box.delete(box_sl)
    if not na(info_label)
        label.delete(info_label)
    if not na(guide_label)
        label.delete(guide_label)

    box_start = nz(time[20], time)

    if show_active_levels
        entry_line := line.new(box_start, entry_price, timenow, entry_price, xloc=xloc.bar_time, extend=extend.right, color=color.new(entry_line_color, 0), width=3, style=line.style_dotted)
        sl_line := line.new(box_start, stop_loss_price, timenow, stop_loss_price, xloc=xloc.bar_time, extend=extend.right, color=color.new(sl_color, 0), width=3)
        tp_line := line.new(box_start, take_profit_price, timenow, take_profit_price, xloc=xloc.bar_time, extend=extend.right, color=color.new(tp_color, 0), width=3)

        tp_top = is_long ? take_profit_price : entry_price
        tp_bottom = is_long ? entry_price : take_profit_price
        box_tp := box.new(box_start, tp_top, timenow, tp_bottom, xloc=xloc.bar_time, border_color=color.new(tp_color, 0), bgcolor=color.new(tp_color, 85), border_width=1)

        sl_top = is_long ? entry_price : stop_loss_price
        sl_bottom = is_long ? stop_loss_price : entry_price
        box_sl := box.new(box_start, sl_top, timenow, sl_bottom, xloc=xloc.bar_time, border_color=color.new(sl_color, 0), bgcolor=color.new(sl_color, 85), border_width=1)

    if show_price_labels and not stale_levels and valid_setup
        info_text = "    Qty: " + str.tostring(position_size, "#.####") + "  |  Lev: " + str.tostring(minimum_leverage, "#") + "×    "
        info_label := label.new(timenow, entry_price, info_text, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, textcolor=color.black, color=color.white, size=size.small)

    if not valid_setup or stale_levels
        guide_text = "Invalid placement — ensure TP and SL are on opposite sides of Entry"
        if stale_levels
            guide_text := "RESET LEVELS — click Entry / SL near current price"
        else if invalid_setup
            guide_text := "Click Entry, then Stop (below for long, above for short)"
        else if invalid_tp
            guide_text := manual_tp_override ? "Click Take-Profit on the opposite side of Entry from Stop" : "Invalid TP — check Entry, Stop and Target R:R"
        guide_label := label.new(timenow, close, guide_text, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, textcolor=color.white, color=color.new(color.red, 0), size=size.small)

// DASHBOARD (Design 1)
var table dashboard = table.new(
     position.bottom_right, 2, 7,
     bgcolor=color.white,
     border_width=1,
     border_color=color.rgb(190, 190, 190))

label_bg = color.rgb(245, 247, 250)
ok_green = color.rgb(46, 125, 50)
warn_red = color.rgb(198, 40, 40)

if barstate.islast
    leverage_color = color.red
    if valid_setup and capital_sufficient and not liq_before_stop
        leverage_color := minimum_leverage <= 3 ? ok_green : minimum_leverage <= 10 ? color.rgb(245, 124, 0) : color.red

    status_text = trade_direction + " ✓"
    if stale_levels
        status_text := "RESET LEVELS"
    else if not valid_setup
        status_text := trade_direction
    else if not capital_sufficient
        status_text := "LEVERAGE TOO LOW"
    else if liq_before_stop
        status_text := "LIQ BEFORE STOP"

    status_color = header_color
    if stale_levels
        status_color := color.rgb(245, 124, 0)
    else if not valid_setup or not capital_sufficient or liq_before_stop
        status_color := warn_red

    liq_pct_text = ""
    if show_liq_price
        liq_pct_text := liq_distance_pct >= 0 ? "+" + str.tostring(liq_distance_pct, "#0.0") + "%" : str.tostring(liq_distance_pct, "#0.0") + "%"

    liq_text = "---"
    if valid_setup and not na(minimum_leverage)
        if not show_liq_price
            liq_text := "n/a (1×)"
        else
            liq_text := str.tostring(liquidation_price, format.mintick) + "  (" + liq_pct_text + ")"
            if liq_before_stop
                liq_text := liq_text + "  ·  before SL"

    liq_color = ok_green
    if not valid_setup or not show_liq_price
        liq_color := color.gray
    else if liq_before_stop
        liq_color := warn_red

    table.cell(dashboard, 0, 0, "POSITION SIZE", bgcolor=status_color, text_color=color.white, text_size=size.normal)
    table.cell(dashboard, 1, 0, status_text, bgcolor=status_color, text_color=color.white, text_size=size.normal)

    table.cell(dashboard, 0, 1, "Quantity", bgcolor=label_bg, text_color=color.black)
    table.cell(dashboard, 1, 1, na(position_size) ? "---" : str.tostring(position_size, "#,###.####"), text_color=color.blue)

    table.cell(dashboard, 0, 2, "Position value", bgcolor=label_bg, text_color=color.black)
    table.cell(dashboard, 1, 2, na(position_value) ? "---" : str.tostring(position_value, "#,###.##") + " USDT", text_color=color.blue)

    table.cell(dashboard, 0, 3, "Leverage", bgcolor=label_bg, text_color=color.black)
    table.cell(dashboard, 1, 3, na(minimum_leverage) ? "---" : str.tostring(minimum_leverage, "#") + "×", text_color=leverage_color)

    table.cell(dashboard, 0, 4, "Liquidation", bgcolor=label_bg, text_color=color.black)
    table.cell(dashboard, 1, 4, liq_text, text_color=liq_color)

    table.cell(dashboard, 0, 5, "Risk", bgcolor=label_bg, text_color=color.black)
    table.cell(dashboard, 1, 5, str.tostring(risk_per_position, "#,###.##") + " USDT", text_color=color.red)

    table.cell(dashboard, 0, 6, "Reward", bgcolor=label_bg, text_color=color.black)
    table.cell(dashboard, 1, 6, na(potential_profit) ? "---" : "+" + str.tostring(potential_profit, "#,###.##") + " USDT", text_color=ok_green)
````
