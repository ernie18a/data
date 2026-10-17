#  Algo torma RiskManager

- url: https://www.tradingview.com/script/6FjGTnPn-Algo-torma-RiskManager/
- type: indicator
- pine_id: PUB;25b28fb12196406186267659ea62b366
- version: 1.0

## Description

Algo Torma RiskManager — Adjustable RR Tool

Managing risk is the most important skill in trading, yet it's the one most beginners overlook. This indicator was built specifically for novice traders who want to stay disciplined and protect their account from the start.

**What it does**
Once added to your chart, set your account size, how much you're willing to risk per trade (recommended 1%), your stop-loss distance in points, and your target risk:reward ratio. The tool then:
- Calculates your exact position size so you never risk more than your defined percentage
- Draws your entry, stop-loss, and take-profit levels directly on the chart as colored boxes and lines, scaled to your risk (red box) and reward (green box) zones
- Tracks losses across up to six trades you log manually and tells you how much of your daily loss budget remains
- Displays everything in a single on-chart info panel for quick reference

**How it works (the concepts behind the math)**
The core calculation is a standard fixed-fractional position sizing model: position size = (account size × risk %) ÷ (stop distance in points × contract size). This is the same method used by most professional risk-management plans — you decide the dollar amount you're willing to lose on a single trade, and the tool works backward from your stop distance to tell you how many contracts or units that translates to. The take-profit level is derived from your chosen risk:reward multiple applied to the same stop distance, so your boxes always reflect a consistent R-multiple rather than an arbitrary price target. The daily loss tracker simply sums the trade losses you input and compares that running total against a max-daily-loss threshold you set as a percentage of your account, flagging when you've hit your limit for the session.

**How to use it**
1. Add the indicator to your chart.
2. In settings, enter your account size, risk per trade %, and max daily loss %.
3. Enter your planned entry price (or leave at 0 to use the current price), your stop-loss distance in points, direction (Long/Short), and target R:R ratio.
4. Set the contract size for your instrument (tooltip includes common futures multipliers: MNQ, MES, NQ, MGC, GC — adjust for other instruments accordingly).
5. Optionally log losses from trades taken earlier in the session into the Daily Loss Tracker fields to see your remaining risk budget update in real time.
6. Use the on-chart boxes, lines, and info panel to confirm your position size and risk before entering a trade manually.

**Important notes**
This is a manual planning and visualization tool only. It does not generate buy or sell signals, does not analyze price action or market structure, and does not predict market direction — the Long/Short selector simply tells the tool which side of your entry to draw the stop and target on. All outputs are derived purely from the numbers you enter; the indicator performs no backtesting and makes no claims about historical or future performance.

This script is for educational and informational purposes only and does not constitute financial, investment, or trading advice. Trading involves substantial risk of loss, and you are solely responsible for your own trading decisions. Always perform your own due diligence and risk management. The author assumes no responsibility for any losses incurred through the use of this tool.

This script is open-source so you can review exactly how each calculation is performed.

## Source Code

````pine
//@version=6
indicator(" Algo torma RiskManager — Adjustable RR Tool", overlay = true, max_boxes_count = 20, max_lines_count = 20, max_labels_count = 20)

//────────────────────────────────────────────
// ACCOUNT SETTINGS
//────────────────────────────────────────────
grp1 = "💰 Account Settings"

account_size   = input.float(10000, "Account Size ($)", group = grp1, step = 100)
risk_percent   = input.float(1.0, "Risk Per Trade (%)", group = grp1, step = 0.1)
max_daily_loss = input.float(3.0, "Max Daily Loss (%)", group = grp1, step = 0.1)

//────────────────────────────────────────────
// TRADE SETTINGS
//────────────────────────────────────────────
grp2 = "📍 Trade Setup"

entry_price = input.float(0.0, "Entry Price (0 = Current Price)", group = grp2)
stop_points = input.float(50.0, "Stop Loss (Points from Entry)", group = grp2, step = 1, minval = 1, tooltip = "Number of points below (Long) or above (Short) your entry.")

direction = input.string(
     "Long",
     "Direction",
     options = ["Long", "Short"],
     group = grp2
)

rr_target = input.float(2.0, "Risk Reward Ratio", group = grp2, step = 0.1)

contract_size = input.float(
     5.0,
     "Contract Size",
     group = grp2,
     tooltip = "MNQ=2 | MES=5 | NQ=20 | MGC=10 | GC=100"
)

//────────────────────────────────────────────
// DISPLAY SETTINGS
//────────────────────────────────────────────
grp3 = "🎨 Display Settings"

projection_bars = input.int(5, "Box Width (Bars)", group = grp3, minval = 1, maxval = 100)
offset_right    = input.int(2, "Offset From Current Candle", group = grp3, minval = 0, maxval = 50)

show_boxes      = input.bool(true, "Show RR Boxes", group = grp3)
show_labels     = input.bool(true, "Show Labels", group = grp3)
show_info_panel = input.bool(true, "Show Info Panel", group = grp3)

entry_color = input.color(color.white, "Entry Line Color", group = grp3)
sl_color    = input.color(color.red,   "Stop Loss Color",  group = grp3)
tp_color    = input.color(color.lime,  "Take Profit Color", group = grp3)

//────────────────────────────────────────────
// DAILY LOSS TRACKER
//────────────────────────────────────────────
grp4 = "📊 Daily Loss Tracker"

trade1 = input.float(0.0, "Trade 1 Loss", group = grp4)
trade2 = input.float(0.0, "Trade 2 Loss", group = grp4)
trade3 = input.float(0.0, "Trade 3 Loss", group = grp4)
trade4 = input.float(0.0, "Trade 4 Loss", group = grp4)
trade5 = input.float(0.0, "Trade 5 Loss", group = grp4)
trade6 = input.float(0.0, "Trade 6 Loss", group = grp4)

//────────────────────────────────────────────
// PANEL POSITION
//────────────────────────────────────────────
grp5 = "📌 Panel Position"

panel_pos = input.string(
     "Top Right", "Panel Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     group = grp5
)

//────────────────────────────────────────────
// CALCULATIONS
//────────────────────────────────────────────

entry = entry_price == 0 ? close : entry_price

isLong = direction == "Long"

sl            = isLong ? entry - stop_points : entry + stop_points
risk_distance = stop_points

risk_percent_price    = entry > 0 ? (risk_distance / entry) * 100 : 0
account_risk          = account_size * (risk_percent / 100)
max_daily_loss_dollar = account_size * (max_daily_loss / 100)

float position_size = na
if risk_distance > 0
    position_size := account_risk / (risk_distance * contract_size)

float tp = na
if isLong
    tp := entry + (risk_distance * rr_target)
else
    tp := entry - (risk_distance * rr_target)

dollar_at_risk = position_size * risk_distance * contract_size

//────────────────────────────────────────────
// DAILY LOSSES
//────────────────────────────────────────────
daily_losses     = trade1 + trade2 + trade3 + trade4 + trade5 + trade6
remaining_budget = max_daily_loss_dollar - daily_losses
daily_loss_pct   = account_size > 0 ? (daily_losses / account_size) * 100 : 0
current_trade_over_limit = remaining_budget > 0 and dollar_at_risk > remaining_budget

//────────────────────────────────────────────
// BOX POSITIONING
//────────────────────────────────────────────
left_bar  = bar_index + offset_right
right_bar = left_bar + projection_bars

risk_top    = math.max(entry, sl)
risk_bottom = math.min(entry, sl)

float reward_top    = na
float reward_bottom = na

if isLong
    reward_top    := tp
    reward_bottom := entry
else
    reward_top    := entry
    reward_bottom := tp

//────────────────────────────────────────────
// OBJECTS
//────────────────────────────────────────────
var box risk_box     = na
var box reward_box   = na
var line entry_line  = na
var line sl_line     = na
var line tp_line     = na
var label entry_lbl  = na
var label sl_lbl     = na
var label tp_lbl     = na

if not na(risk_box)
    box.delete(risk_box)
if not na(reward_box)
    box.delete(reward_box)
if not na(entry_line)
    line.delete(entry_line)
if not na(sl_line)
    line.delete(sl_line)
if not na(tp_line)
    line.delete(tp_line)
if not na(entry_lbl)
    label.delete(entry_lbl)
if not na(sl_lbl)
    label.delete(sl_lbl)
if not na(tp_lbl)
    label.delete(tp_lbl)

//────────────────────────────────────────────
// DRAW BOXES
//────────────────────────────────────────────
if show_boxes
    risk_box := box.new(
         left         = left_bar,
         right        = right_bar,
         top          = risk_top,
         bottom       = risk_bottom,
         bgcolor      = color.new(color.red, 88),
         border_color = color.new(color.red, 20)
     )
    reward_box := box.new(
         left         = left_bar,
         right        = right_bar,
         top          = reward_top,
         bottom       = reward_bottom,
         bgcolor      = color.new(color.green, 88),
         border_color = color.new(color.green, 20)
     )

//────────────────────────────────────────────
// DRAW LINES
//────────────────────────────────────────────
entry_line := line.new(
     x1    = left_bar,
     y1    = entry,
     x2    = right_bar,
     y2    = entry,
     color = entry_color,
     width = 2
)

sl_line := line.new(
     x1    = left_bar,
     y1    = sl,
     x2    = right_bar,
     y2    = sl,
     color = sl_color,
     width = 2,
     style = line.style_dashed
)

tp_line := line.new(
     x1    = left_bar,
     y1    = tp,
     x2    = right_bar,
     y2    = tp,
     color = tp_color,
     width = 2,
     style = line.style_dashed
)

//────────────────────────────────────────────
// LABELS
//────────────────────────────────────────────
if show_labels
    entry_lbl := label.new(
         x         = right_bar,
         y         = entry,
         text      = "⚡ ENTRY " + str.tostring(entry, "#.##"),
         style     = label.style_label_left,
         color     = color.black,
         textcolor = color.white,
         size      = size.small
     )

    sl_lbl := label.new(
         x         = right_bar,
         y         = sl,
         text      = "🛑 STOP " + str.tostring(sl, "#.##") +
             " | -" + str.tostring(stop_points, "#") +
             " pts | -" + str.tostring(risk_percent_price, "#.##") + "%",
         style     = label.style_label_left,
         color     = sl_color,
         textcolor = color.white,
         size      = size.small
     )

    tp_lbl := label.new(
         x         = right_bar,
         y         = tp,
         text      = "🎯 TARGET " + str.tostring(tp, "#.##") +
             " | RR " + str.tostring(rr_target, "#.#") + "R",
         style     = label.style_label_left,
         color     = tp_color,
         textcolor = color.white,
         size      = size.small
     )

//────────────────────────────────────────────
// PANEL POSITION
//────────────────────────────────────────────
panel_position =
     panel_pos == "Top Right"    ? position.top_right  :
     panel_pos == "Top Left"     ? position.top_left   :
     panel_pos == "Bottom Right" ? position.bottom_right :
     position.bottom_left

//────────────────────────────────────────────
// INFO PANEL
//────────────────────────────────────────────
var table panel = table.new(
     panel_position, 2, 12,
     bgcolor      = color.new(color.black, 15),
     border_width = 1,
     border_color = color.new(color.gray, 60)
)

if barstate.islast and show_info_panel

    table.cell(panel, 0, 0, "⚡ RISK MANAGER", text_color = color.yellow)
    table.cell(panel, 1, 0,
         isLong ? "🟢 LONG" : "🔴 SHORT",
         text_color = isLong ? color.green : color.red)

    table.cell(panel, 0, 1, "Account Size")
    table.cell(panel, 1, 1, "$ " + str.tostring(account_size, "#,###"))

    table.cell(panel, 0, 2, "Risk Per Trade")
    table.cell(panel, 1, 2,
         str.tostring(risk_percent, "#.##") + "% = $" + str.tostring(account_risk, "#.##"),
         text_color = color.orange)

    table.cell(panel, 0, 3, "Stop Distance")
    table.cell(panel, 1, 3,
         str.tostring(stop_points, "#") + " pts (" + str.tostring(risk_percent_price, "#.##") + "%)",
         text_color = color.red)

    table.cell(panel, 0, 4, "Position Size")
    table.cell(panel, 1, 4,
         str.tostring(position_size, "#.####") + " units",
         text_color = color.aqua)

    table.cell(panel, 0, 5, "$ At Risk")
    table.cell(panel, 1, 5,
         "$ " + str.tostring(dollar_at_risk, "#.##"),
         text_color = current_trade_over_limit ? color.red : color.green)

    table.cell(panel, 0, 6, "Take Profit")
    table.cell(panel, 1, 6, str.tostring(tp, "#.##"), text_color = color.lime)

    table.cell(panel, 0, 7, "R:R Ratio")
    table.cell(panel, 1, 7,
         "1 : " + str.tostring(rr_target, "#.##"),
         text_color = color.green)

    table.cell(panel, 0, 8, "──── DAILY LOSS ────", text_color = color.gray)

    table.cell(panel, 0, 9, "Losses Today")
    table.cell(panel, 1, 9,
         "-$ " + str.tostring(daily_losses, "#.##") +
         " (" + str.tostring(daily_loss_pct, "#.##") + "%)",
         text_color = daily_losses > 0 ? color.orange : color.white)

    table.cell(panel, 0, 10, "Daily Limit")
    table.cell(panel, 1, 10, "$ " + str.tostring(max_daily_loss_dollar, "#.##"))

    table.cell(panel, 0, 11, "Remaining")
    table.cell(panel, 1, 11,
         remaining_budget <= 0
             ? "🚫 STOP"
             : "✅ $" + str.tostring(remaining_budget, "#.##"),
         text_color = remaining_budget <= 0 ? color.red : color.green)
````
