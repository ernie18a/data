# Net RR Calculator

- url: https://www.tradingview.com/script/p9MPLAZL-net-rr-calculator/
- type: indicator
- pine_id: PUB;31a9750c5fb744a1beaa08f80b48be19
- version: 6.0

## Description

Net RR Calculator — Risk/Reward Calculator with Net Commission.

A precision risk/reward tool for long and short positions that goes beyond structural RR by calculating your real, net RR after trading fees.

How it works:
Click three times on the chart — entry, stop loss, and take profit — and the indicator instantly draws your risk/reward zones and displays a full breakdown of the trade.

What it calculates:
- Structural RR (raw ratio without fees)
- Net RR (actual ratio after open & close commissions)
- Position size based on your deposit and risk percentage
- Commission cost for both winning and losing scenarios
- Net profit and risk amount in your chosen currency

Key features:
- Automatic Long / Short detection based on stop placement
- Separate commission inputs for open and close (maker/taker friendly)
- Supports USD, EUR, RUB and USDT display
- Fully customizable zone colors, width and decimal precision
- Clean, non-intrusive overlay with dark-themed labels

Who it's for:
Traders who want to see the true cost of a trade before entering — accounting for exchange fees that silently erode your RR on every position.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────
// RR Calculator | Long & Short | Net RR with Commission
//
// HOW TO USE:
//   1. Add the indicator to the chart
//   2. Click the ENTRY price level
//   3. Click the STOP LOSS level  (below entry = Long, above = Short)
//   4. Click the TAKE PROFIT level
//   → Zones and calculations appear automatically
//
// To reposition: right-click the indicator → "Edit Indicator" → Inputs
// ─────────────────────────────────────────────────────────────
indicator("Net RR Calculator", overlay=true, max_boxes_count=10, max_labels_count=10, max_lines_count=5)

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════

var G1 = "📍 Click on chart: Entry → Stop → Target"
entry_price = input.price(0.0, "1. Entry Price",  confirm=true, group=G1,
     tooltip="The price at which the position is opened. Click the desired level on the chart.")
sl_price    = input.price(0.0, "2. Stop Loss",    confirm=true, group=G1,
     tooltip="The level at which the position is closed with a loss. Below entry = Long, above entry = Short.")
tp_price    = input.price(0.0, "3. Take Profit",  confirm=true, group=G1,
     tooltip="The target level for taking profit. Must be on the opposite side of the stop loss relative to the entry.")

var G2 = "💰 Deposit & Risk"
currency        = input.string("USDT", "Currency",                  options=["USDT", "USD", "EUR", "RUB"], group=G2,
     tooltip="Display currency for all monetary values. Does not convert prices — used as a label only.")
trading_deposit = input.float(1000.0, "Trading Deposit",            minval=1,    step=100,   group=G2,
     tooltip="The capital you intend to trade with. Used to calculate position size based on the risk percentage. May be larger than your actual account balance.")
use_balance     = input.bool(false, "Use Account Balance",          group=G2,
     tooltip="Enable when your real account balance is smaller than the trading deposit. When ON, leverage is calculated against the account balance (real margin requirement). When OFF, leverage is calculated against the trading deposit.")
account_balance = input.float(1000.0, "Account Balance",            minval=1,    step=100,   group=G2,
     tooltip="Actual funds available on your account. Used only when 'Use Account Balance' is enabled — leverage = position size / account balance. This shows the real leverage you must set on the exchange.")
risk_pct_i      = input.float(1.0,   "Risk per trade (%)",          minval=0.01, step=0.1,   group=G2,
     tooltip="Percentage of the trading deposit you are willing to lose on a single trade. Example: 1% of 1000 = 10 at risk.")
comm_open       = input.float(0.04,  "Commission on open (%)",      minval=0.0,  step=0.001, group=G2,
     tooltip="Broker/exchange fee when opening a position, as a percentage of trade volume. Limit orders (maker) are usually lower than market orders (taker).")
comm_close      = input.float(0.04,  "Commission on close (%)",     minval=0.0,  step=0.001, group=G2,
     tooltip="Broker/exchange fee when closing a position, as a percentage of trade volume. Applied separately to take profit and stop loss exits.")

var G3 = "🎨 Visuals"
clr_risk   = input.color(color.new(#3d1515, 55), "Risk zone color",   group=G3,
     tooltip="Fill color for the zone between the entry price and stop loss.")
clr_reward = input.color(color.new(#0d3d28, 55), "Reward zone color", group=G3,
     tooltip="Fill color for the zone between the entry price and take profit.")
bars_width = input.int(50,    "Zone width (bars)", minval=5, maxval=500, group=G3,
     tooltip="How many bars to the right the risk and reward zones extend.")
show_qty      = input.bool(true, "Show position volume", group=G3,
     tooltip="Display the calculated position volume in the TP and SL labels.")
show_position = input.bool(true, "Show position size (currency + asset quantity)", group=G3,
     tooltip="Display the position size for the current instrument: amount in the selected currency (deposit currency), quantity in units of the chart's base asset (e.g. BTC, AAPL), and required leverage. Disable to hide if you only need RR/PnL info.")
price_decs    = input.int(2,    "Price decimal places", group=G3, minval=0, maxval=8,
     tooltip="Number of decimal places used when displaying prices. Increase to 4–6 for low-price crypto assets.")

// ═══════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════

// Currency symbol
cur = currency == "USD" ? " USD" : currency == "EUR" ? " EUR" : currency == "RUB" ? " RUB" : " USDT"

p(v)   => str.tostring(math.round(v, price_decs))
pct(v) => str.tostring(math.round(v, 3))
u(v)   => str.tostring(math.round(v, 2)) + cur

// Smart formatter for asset quantity: more decimals for sub-1 quantities (e.g. 0.0234 BTC),
// fewer for large ones (e.g. 1500 shares).
qty_fmt(q) =>
    aq = math.abs(q)
    decs = aq >= 100 ? 2 : aq >= 1 ? 4 : aq >= 0.01 ? 6 : 8
    str.tostring(math.round(q, decs))

// Asset name for the current chart instrument: prefer base currency (BTC, ETH),
// fall back to ticker symbol (AAPL, SBER) when base is empty.
asset_name() =>
    syminfo.basecurrency != "" ? syminfo.basecurrency : syminfo.ticker

// ═══════════════════════════════════════════════════════════════
// CALCULATIONS
// ═══════════════════════════════════════════════════════════════

risk_amt = trading_deposit * risk_pct_i / 100

is_long = sl_price < entry_price

risk_pts   = math.abs(entry_price - sl_price)
reward_pts = math.abs(tp_price    - entry_price)

valid = risk_pts > 0 and reward_pts > 0 and entry_price > 0 and (is_long ? tp_price > entry_price : tp_price < entry_price)

risk_pct_val   = risk_pts   / entry_price * 100
reward_pct_val = reward_pts / entry_price * 100

// Position sizing: cover BOTH the price-move loss AND the round-trip commission within risk_amt.
// Per-unit loss at SL = price move + open fee on entry + close fee on SL price.
// qty = risk_amt / per-unit loss → ensures actual loss at SL ≈ risk_amt (matches the
// reference web calculator: positionSize = riskAmount / ((slPct + 2·fee%) / 100)).
loss_per_unit = risk_pts + entry_price * comm_open / 100 + sl_price * comm_close / 100
qty = loss_per_unit > 0 ? risk_amt / loss_per_unit : 0.0

struct_rr = reward_pts / risk_pts

vol_entry = qty * entry_price
vol_tp    = qty * tp_price
vol_sl    = qty * sl_price

comm_open_amt   = vol_entry * comm_open  / 100
comm_close_win  = vol_tp    * comm_close / 100
comm_close_loss = vol_sl    * comm_close / 100
comm_total_win  = comm_open_amt + comm_close_win
comm_total_loss = comm_open_amt + comm_close_loss

net_profit = qty * reward_pts - comm_total_win
net_loss   = qty * risk_pts   + comm_total_loss
net_rr     = net_loss > 0 ? net_profit / net_loss : 0.0

// Leverage base: account balance when toggle is ON (real margin requirement),
// trading deposit otherwise (notional sizing reference).
leverage_base = use_balance ? account_balance : trading_deposit
leverage      = leverage_base > 0 ? vol_entry / leverage_base : 0.0

// ═══════════════════════════════════════════════════════════════
// DRAWING
// ═══════════════════════════════════════════════════════════════

var box   b_risk   = na
var box   b_reward = na
var line  l_entry  = na
var label lbl_tp   = na
var label lbl_sl   = na
var label lbl_rr   = na

if barstate.islast
    box.delete(b_risk),   box.delete(b_reward)
    line.delete(l_entry)
    label.delete(lbl_tp), label.delete(lbl_sl), label.delete(lbl_rr)

    if valid
        lb  = bar_index + 5
        rb  = lb + bars_width
        mid = math.round((lb + rb) / 2)

        sl_top = is_long ? entry_price : sl_price
        sl_bot = is_long ? sl_price    : entry_price
        tp_top = is_long ? tp_price    : entry_price
        tp_bot = is_long ? entry_price : tp_price

        b_risk   := box.new(lb, sl_top, rb, sl_bot, bgcolor=clr_risk,   border_color=color.new(color.black, 100), border_width=0)
        b_reward := box.new(lb, tp_top, rb, tp_bot, bgcolor=clr_reward, border_color=color.new(color.black, 100), border_width=0)
        l_entry  := line.new(lb, entry_price, rb, entry_price, color=color.new(color.white, 60), style=line.style_dashed, width=1)

        vol_tp_str = show_qty ? "\nVolume: " + u(vol_tp) : ""
        vol_sl_str = show_qty ? "\nVolume: " + u(vol_sl) : ""

        // For LONG: TP label sits at top of reward box (label points down)
        // For SHORT: TP label sits at bottom of reward box (label points up)
        tp_lbl_y     = is_long ? tp_top : tp_bot
        tp_lbl_style = is_long ? label.style_label_down : label.style_label_up

        // For LONG: SL label sits at bottom of risk box (label points up)
        // For SHORT: SL label sits at top of risk box (label points down)
        sl_lbl_y     = is_long ? sl_bot : sl_top
        sl_lbl_style = is_long ? label.style_label_up : label.style_label_down

        lbl_tp := label.new(mid, tp_lbl_y,
                            "Target: " + p(tp_price) + "  (+" + pct(reward_pct_val) + "%)  +" + p(reward_pts) + vol_tp_str,
                            style=tp_lbl_style,
                            color=color.new(#0d3d28, 20), textcolor=color.new(#aaffcc, 0), size=size.normal)

        lbl_sl := label.new(mid, sl_lbl_y,
                            "Stop: " + p(sl_price) + "  (-" + pct(risk_pct_val) + "%)  -" + p(risk_pts) + vol_sl_str,
                            style=sl_lbl_style,
                            color=color.new(#3d1515, 20), textcolor=color.new(#ffaaaa, 0), size=size.normal)

        dir_txt = is_long ? "LONG" : "SHORT"

        position_block = show_position ?
             " Position:  " + u(vol_entry) + "\n" +
             " Quantity:  " + qty_fmt(qty) + " " + asset_name() + "\n" +
             " Leverage:  " + str.tostring(math.round(leverage, 2)) + "x\n" +
             " ───────────────────\n" : ""

        // Show Account Balance line only when toggle is on, so users see both
        // the sizing base (Trading Deposit) and the leverage base (Account Balance).
        balance_line = use_balance ? " Account Balance:  " + u(account_balance) + "\n" : ""

        lbl_rr := label.new(rb + 5, entry_price,
                            " " + dir_txt + "\n" +
                            " ───────────────────\n" +
                            " Structural RR:  1 : " + str.tostring(math.round(struct_rr, 2)) + "\n" +
                            " Net RR:         1 : " + str.tostring(math.round(net_rr, 2))    + "\n" +
                            " ───────────────────\n" +
                            position_block +
                            " Trading Deposit:  " + u(trading_deposit) + "\n" +
                            balance_line +
                            " Risk:     -" + u(risk_amt)       + " (" + str.tostring(risk_pct_i) + "%)\n" +
                            " Profit:   +" + u(net_profit)     + "\n" +
                            " Commission: " + u(comm_total_win),
                            style=label.style_label_left,
                            color=color.new(#141414, 10), textcolor=color.new(color.silver, 0), size=size.normal)

    else if entry_price != 0 or sl_price != 0 or tp_price != 0
        label.new(bar_index, high,
                  "⚠️  Check levels: SL and TP must be on opposite sides of the entry price",
                  style=label.style_label_left,
                  color=color.new(color.yellow, 20), textcolor=color.black, size=size.normal)
````
