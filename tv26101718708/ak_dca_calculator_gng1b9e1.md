# AK - DCA Calculator

- url: https://www.tradingview.com/script/Gng1b9e1-AK-DCA-Calculator/
- type: indicator
- pine_id: PUB;fbc8962496b44828942635d566eb2100
- version: 1.0

## Description

This indicator visualizes your Dollar Cost Averaging (DCA) strategy directly on your chart — no backtesting, no strategy tester, just a clean plot showing exactly where your money stands today.

What it does
Set your start date, buy frequency, and investment amount — the indicator calculates how many units you would have accumulated through consistent DCA purchases, then plots your total invested capital against your current portfolio value in a separate pane below the chart.

Features

📅 Configurable start date — model your DCA from any point in history
🔁 Three buy frequencies — Daily, Weekly, or Monthly
💵 Custom investment amount per purchase
📊 Separate pane — does not clutter your main price chart
🟢 Green fill when you're in profit, red fill when underwater
🏷️ Live labels on the last bar showing exact invested vs. current value
📋 Summary table (top-right) showing: buys made, average cost per unit, total invested, current portfolio value, and P&L in both $ and %
🎨 Fully customizable colors for all plot elements


How to use

Add the indicator to any ticker
Open Settings and set your Start Date, Buy Frequency, and Amount per Purchase
Best used on a Daily or Weekly chart for accurate frequency simulation

Works on any asset — stocks, crypto, forex, indices.

## Source Code

````pine
//@version=5
indicator(
     title        = "DCA Calculator",
     shorttitle   = "DCA",
     overlay      = false,
     format       = format.price,
     precision    = 2
 )

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
grp_dca = "DCA Settings"

dca_start   = input.time(
     defval  = timestamp("2023-01-01 00:00 +0000"),
     title   = "Start Date",
     group   = grp_dca
 )

dca_freq    = input.string(
     defval  = "Monthly",
     title   = "Buy Frequency",
     options = ["Daily", "Weekly", "Monthly"],
     group   = grp_dca
 )

dca_amount  = input.float(
     defval  = 500.0,
     minval  = 1.0,
     title   = "Amount per Purchase (USD)",
     group   = grp_dca
 )

// ─────────────────────────────────────────────
// DISPLAY SETTINGS
// ─────────────────────────────────────────────
grp_display = "Display"

col_invested = input.color(color.new(color.blue, 20),   "Invested Color",        group = grp_display)
col_value    = input.color(color.new(color.teal, 20),   "Portfolio Value Color",  group = grp_display)
col_profit   = input.color(color.new(color.green, 20),  "Profit Color",          group = grp_display)
col_loss     = input.color(color.new(color.red, 20),    "Loss Color",            group = grp_display)
show_labels  = input.bool(true, "Show Labels on Chart", group = grp_display)

// ─────────────────────────────────────────────
// FREQUENCY HELPERS
// ─────────────────────────────────────────────
is_buy_bar() =>
    if dca_freq == "Daily"
        ta.change(time("D")) != 0 or timeframe.isdaily
    else if dca_freq == "Weekly"
        ta.change(time("W")) != 0 or timeframe.isweekly
    else
        ta.change(time("M")) != 0 or timeframe.ismonthly

// ─────────────────────────────────────────────
// CORE DCA LOGIC
// ─────────────────────────────────────────────
var float total_invested = 0.0
var float total_units    = 0.0
var float buy_count      = 0.0

after_start = time >= dca_start

if after_start and is_buy_bar()
    buy_price      = close
    units_bought   = dca_amount / buy_price
    total_invested := total_invested + dca_amount
    total_units    := total_units    + units_bought
    buy_count      := buy_count      + 1

portfolio_value = total_units * close

pnl_abs = portfolio_value - total_invested
pnl_pct = total_invested > 0 ? (pnl_abs / total_invested) * 100 : 0.0

// ─────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────
plot_invested = plot(
     after_start ? total_invested : na,
     title     = "Total Invested ($)",
     color     = col_invested,
     linewidth = 2,
     style     = plot.style_line
 )

plot_value = plot(
     after_start ? portfolio_value : na,
     title     = "Portfolio Value ($)",
     color     = pnl_abs >= 0 ? col_value : col_loss,
     linewidth = 2,
     style     = plot.style_line
 )

fill(
     plot_invested,
     plot_value,
     color = pnl_abs >= 0
         ? color.new(col_profit, 80)
         : color.new(col_loss,   80),
     title = "P&L Fill"
 )

hline(0, "Zero", color = color.new(color.gray, 60), linestyle = hline.style_dotted)

// ─────────────────────────────────────────────
// LABELS (last bar only)
// ─────────────────────────────────────────────
if barstate.islast and show_labels and after_start
    label.new(
         x         = bar_index,
         y         = total_invested,
         text      = "Invested\n$" + str.tostring(total_invested, "#,###.00"),
         color     = col_invested,
         textcolor = color.white,
         style     = label.style_label_left,
         size      = size.small
     )
    label.new(
         x         = bar_index,
         y         = portfolio_value,
         text      = "Value\n$" + str.tostring(portfolio_value, "#,###.00"),
         color     = pnl_abs >= 0 ? col_value : col_loss,
         textcolor = color.white,
         style     = label.style_label_left,
         size      = size.small
     )

// ─────────────────────────────────────────────
// INFO TABLE
// ─────────────────────────────────────────────
var table info_table = table.new(
     position     = position.top_right,
     columns      = 2,
     rows         = 6,
     bgcolor      = color.new(color.black, 75),
     border_color = color.new(color.gray, 60),
     border_width = 1
 )

cell_txt(col, row, txt, clr) =>
    table.cell(
         info_table,
         column     = col,
         row        = row,
         text       = txt,
         text_color = clr,
         text_size  = size.small,
         bgcolor    = color.new(color.black, 85)
     )

if barstate.islast and after_start
    table.cell(info_table, 0, 0, "DCA Summary",
         text_color = color.white, text_size = size.normal,
         bgcolor    = color.new(color.blue, 50))
    table.cell(info_table, 1, 0, syminfo.ticker,
         text_color = color.yellow, text_size = size.normal,
         bgcolor    = color.new(color.blue, 50))

    cell_txt(0, 1, "Buys Made",      color.gray)
    cell_txt(1, 1, str.tostring(int(buy_count)), color.white)

    cell_txt(0, 2, "Avg Cost/Unit",  color.gray)
    avg_cost = total_units > 0 ? total_invested / total_units : 0
    cell_txt(1, 2, "$" + str.tostring(avg_cost, "#,###.00"), color.white)

    cell_txt(0, 3, "Total Invested", color.gray)
    cell_txt(1, 3, "$" + str.tostring(total_invested, "#,###.00"), color.white)

    cell_txt(0, 4, "Current Value",  color.gray)
    cell_txt(1, 4, "$" + str.tostring(portfolio_value, "#,###.00"),
         pnl_abs >= 0 ? color.teal : color.red)

    cell_txt(0, 5, "P&L", color.gray)
    pnl_sign = pnl_abs >= 0 ? "+" : ""
    cell_txt(1, 5,
         pnl_sign + "$" + str.tostring(pnl_abs, "#,###.00") +
         " (" + pnl_sign + str.tostring(pnl_pct, "#.##") + "%)",
         pnl_abs >= 0 ? color.green : color.red)
````
