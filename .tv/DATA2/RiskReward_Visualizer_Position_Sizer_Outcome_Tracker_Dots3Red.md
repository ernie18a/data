<!-- tradingview-pine-id: PUB;533e51a6ec1b42c5b71bc156c139554d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Risk/Reward Visualizer  - Position Sizer & Outcome Tracker [Dots3Red]

Source: https://www.tradingview.com/script/qZsf5hbg-Risk-Reward-Visualizer-Trade-Management-Dots3Red/

## Description

🎯 RISK/REWARD VISUALIZER — POSITION SIZER & OUTCOME TRACKER [Dots3Red]
A risk/reward calculator answers one question and then forgets it existed. Click three prices on your chart — entry, stop, target — and this tool draws the zones, sizes the position from your account risk, and shows the ratio plainly. But it also remembers. Every plan you set is tracked to its actual outcome, building a real record of how your own planning has played out over time.

✨ WHY THIS MATTERS
This script treats every set of levels you draw as a real plan worth remembering — not just a static suggestion.

📊 Plans Resolved: 14W / 6L   Hit Rate: 70%   Total R: +9.2R
That's not a backtest of a strategy. It's a running record of the actual entry/stop/target combinations you personally set on this chart and what genuinely happened to each one afterward.

⚙️ HOW IT WORKS
🖱️ Click-to-place levels — Entry, Stop Loss, and Target are set by clicking directly on the chart rather than typing numbers into a settings box. Direction is detected automatically: if your stop sits below entry, it's read as long; above entry, short.

💰 Position sizing from account risk — enter your account size and how much of it you're willing to risk per trade (as a percentage), and the script calculates exactly how large a position keeps that risk fixed regardless of how wide your stop is. The result is rounded to whatever step size fits your instrument — whole shares, or fractional units for crypto.

📏 Risk and reward zones — the space between entry and stop is shaded as your risk; the space between entry and target as your reward. Seeing both zones side by side on the chart makes a lopsided plan (all risk, little reward) visually obvious in a way a bare number doesn't.

🧾 Plan tracking — every distinct entry/stop/target combination is treated as its own plan. When price later reaches either level, the plan resolves:
• Target hit — counted as a win, and the actual R multiple achieved is added to your running total
• Stop hit — counted as a loss (–1R)
• Same-bar ambiguity (a single bar's range touches both stop and target) always resolves as a loss — the conservative, honest call when intrabar order can't be known
• Neither hit within the tracking window — dropped from the record entirely, counted as neither a win nor a loss

Setting new levels automatically starts a new plan; the previous one, if still unresolved, is simply dropped from active tracking without being force-graded.

🔒 Non-repainting — all outcome grading happens strictly on confirmed bars.

🧭 HOW TO USE
1️⃣ Set your account size and risk % first, before placing levels — this is what turns a simple price plan into an actual position size you can act on.

2️⃣ Click Entry, then Stop, then Target on the chart. The dashboard updates immediately with direction, R:R ratio, position size, and dollar risk/reward.

3️⃣ Use the zones to sanity-check the plan visually before committing — a reward zone that looks tiny next to a wide risk zone is worth reconsidering even if the calculated ratio technically clears your minimum.

4️⃣ Check your plan history periodically, not just the current plan. A single setup can look great in isolation; the accumulated hit rate and total R tell you whether your actual level-picking has been working over time.

5️⃣ Adjust the tracking window to match your typical hold time — a scalper and a swing trader need very different values for how many bars a plan should be given before it's dropped as inconclusive.

🛠️ SETTINGS
🎯 Trade Levels — Entry, Stop Loss, Target — each set by clicking on the chart

💰 Account & Risk
• Account Size, Risk per Trade (%) — drive the position size calculation
• Position Size Rounding — match this to your instrument's minimum tradable increment

🎨 Visualization
• Risk/Reward Zones, Level Labels — toggle independently
• Max Bars to Track a Plan — how long an unresolved plan stays active before being dropped

🖥️ Dashboard — show/hide, position — direction, R:R ratio, position size, dollar risk/reward, and the full plan history in one place

📝 NOTES
Only one plan is actively tracked for outcome purposes at a time — setting new levels while a previous plan is still pending drops that previous plan from the record without grading it, rather than running two plans in parallel. This is a planning and tracking tool: it does not know your actual fills, slippage, or whether you genuinely took the trade — it measures what price did relative to the levels you set, not your live trading result.

⚠️ DISCLAIMER
This is an analytical and visualization tool. It does not generate trade signals, does not execute trades, and does not constitute financial advice. Historical plan outcomes do not guarantee how any future plan will resolve.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Dots3Red
// TradingView: https://www.tradingview.com/u/Dots3Red/

//@version=6
indicator("Risk/Reward Visualizer  - Position Sizer & Outcome Tracker [Dots3Red]",
          shorttitle = "R:R Visualizer [D3R]",
          overlay    = true,
          max_lines_count  = 500,
          max_labels_count = 500,
          max_boxes_count  = 500)


// COLORS
C_BULL    = color.new(#00f0ff, 0)
C_BEAR    = color.new(#ff00aa, 0)
C_GREEN   = color.new(#00c896, 0)
C_RED     = color.new(#ff4466, 0)
C_AMBER   = color.new(#ffb700, 0)
C_NEUTRAL = color.new(#64748b, 0)
C_BG      = color.new(#131722, 5)
C_TXT     = color.new(#f8fafc, 0)
C_DIM     = color.new(#94a3b8, 0)
C_BORD    = color.new(#334155, 0)


// INPUTS
GRP_LVL = "🎯 Trade Levels"
GRP_ACC = "💰 Account & Risk"
GRP_VIS = "🎨 Visualization"
GRP_HUD = "🖥️ Dashboard"


entry_price = input.price(title="Entry", defval=0.0, confirm=true, group=GRP_LVL,
              tooltip="Click on the chart to set your entry price.")
stop_price  = input.price(title="Stop Loss", defval=0.0, confirm=true, group=GRP_LVL,
              tooltip="Click on the chart to set your stop-loss price.")
target_price = input.price(title="Target", defval=0.0, confirm=true, group=GRP_LVL,
              tooltip="Click on the chart to set your take-profit target.")

account_size = input.float(10000.0, "Account Size", minval=1.0, group=GRP_ACC)
risk_pct     = input.float(1.0, "Risk per Trade (%)", minval=0.01, maxval=100.0, step=0.1, group=GRP_ACC)
qty_step     = input.float(0.0001, "Position Size Rounding", minval=0.00000001, group=GRP_ACC,
              tooltip="Rounds the calculated position size to this step (e.g. 0.0001 for crypto, 1 for whole shares).")

show_zones  = input.bool(true, "Risk/Reward Zones", group=GRP_VIS)
show_labels = input.bool(true, "Level Labels", group=GRP_VIS)
outcome_bars_max = input.int(500, "Max Bars to Track a Plan", minval=20, maxval=2000, group=GRP_VIS,
              tooltip="A plan that hasn't hit stop or target within this many bars is dropped from tracking (neither win nor loss).")

show_hud = input.bool(true, "Show Dashboard", group=GRP_HUD)
hud_pos  = input.string("Top Right", "Position",
           options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GRP_HUD)


bool levels_set = entry_price != 0.0 and stop_price != 0.0 and target_price != 0.0 and entry_price != stop_price
bool is_long = levels_set and stop_price < entry_price
bool is_short = levels_set and stop_price > entry_price
bool valid_direction = is_long ? target_price > entry_price : is_short ? target_price < entry_price : false
bool plan_valid = levels_set and valid_direction

float risk_per_unit   = plan_valid ? math.abs(entry_price - stop_price) : na
float reward_per_unit = plan_valid ? math.abs(target_price - entry_price) : na
float rr_ratio        = plan_valid and risk_per_unit > 0 ? reward_per_unit / risk_per_unit : na

float risk_dollars = plan_valid ? account_size * risk_pct / 100.0 : na
float pos_size_raw = plan_valid and risk_per_unit > 0 ? risk_dollars / risk_per_unit : na
float pos_size      = plan_valid ? math.round(pos_size_raw / qty_step) * qty_step : na
float reward_dollars = plan_valid ? pos_size * reward_per_unit : na

float risk_pct_price   = plan_valid and entry_price != 0 ? risk_per_unit / entry_price * 100.0 : na
float reward_pct_price = plan_valid and entry_price != 0 ? reward_per_unit / entry_price * 100.0 : na


// PLAN TRACKING FOR OUTCOME STATISTICS 
var float track_entry  = na
var float track_stop   = na
var float track_target = na
var bool  track_is_long = false
var int   track_start_bar = na
var bool  track_active = false

var int total_plans   = 0
var int wins          = 0
var int losses         = 0
var float total_r_sum = 0.0

bool just_hit_stop   = false
bool just_hit_target = false

bool plan_changed = plan_valid and (na(track_entry) or entry_price != track_entry or stop_price != track_stop or target_price != track_target)

if barstate.isconfirmed and plan_changed
    track_entry     := entry_price
    track_stop      := stop_price
    track_target    := target_price
    track_is_long   := is_long
    track_start_bar := bar_index
    track_active    := true

if barstate.isconfirmed and track_active
    bool hit_stop   = track_is_long ? low  <= track_stop   : high >= track_stop
    bool hit_target = track_is_long ? high >= track_target : low  <= track_target
    int  age = bar_index - track_start_bar

    if hit_stop      
        losses += 1
        total_plans += 1
        total_r_sum += -1.0
        track_active := false
        just_hit_stop := true
    else if hit_target
        wins += 1
        total_plans += 1
        float r_ratio_this = math.abs(track_target - track_entry) / math.abs(track_entry - track_stop)
        total_r_sum += r_ratio_this
        track_active := false
        just_hit_target := true
    else if age >= outcome_bars_max
        track_active := false  


// VISUALS 
var line  ln_entry  = na
var line  ln_stop   = na
var line  ln_target = na
var label lb_entry  = na
var label lb_stop   = na
var label lb_target = na
var box   box_risk   = na
var box   box_reward = na

if plan_valid
    if not na(ln_entry)
        line.delete(ln_entry)
        line.delete(ln_stop)
        line.delete(ln_target)
    if not na(lb_entry)
        label.delete(lb_entry)
        label.delete(lb_stop)
        label.delete(lb_target)
    if not na(box_risk)
        box.delete(box_risk)
        box.delete(box_reward)

    int x1 = bar_index - 10
    int x2 = bar_index + 15

    ln_entry  := line.new(x1, entry_price,  x2, entry_price,  color=color.new(C_TXT, 20), width=2)
    ln_stop   := line.new(x1, stop_price,   x2, stop_price,   color=color.new(C_RED, 20), width=2, style=line.style_dashed)
    ln_target := line.new(x1, target_price, x2, target_price, color=color.new(C_GREEN, 20), width=2, style=line.style_dashed)

    if show_zones
        box_risk   := box.new(x1, entry_price, x2, stop_price,
                              border_color=color.new(C_RED, 70), bgcolor=color.new(C_RED, 88))
        box_reward := box.new(x1, entry_price, x2, target_price,
                              border_color=color.new(C_GREEN, 70), bgcolor=color.new(C_GREEN, 88))

    if show_labels
        lb_entry := label.new(x2, entry_price,
                    "ENTRY " + str.tostring(entry_price, format.mintick),
                    style=label.style_label_left, color=color.new(#000000, 100),
                    textcolor=C_TXT, size=size.small)
        lb_stop := label.new(x2, stop_price,
                    "SL " + str.tostring(stop_price, format.mintick) + "  (-" + str.tostring(risk_pct_price, "#.##") + "%)",
                    style=label.style_label_left, color=color.new(#000000, 100),
                    textcolor=C_RED, size=size.small)
        lb_target := label.new(x2, target_price,
                    "TP " + str.tostring(target_price, format.mintick) + "  (+" + str.tostring(reward_pct_price, "#.##") + "%)",
                    style=label.style_label_left, color=color.new(#000000, 100),
                    textcolor=C_GREEN, size=size.small)


// DASHBOARD
f_hud_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        =>                position.bottom_left

var table hud = table.new(f_hud_pos(hud_pos), 2, 10,
                           bgcolor=C_BG, border_color=C_BORD,
                           border_width=1, frame_color=C_BORD, frame_width=2)

if show_hud and barstate.islast
    table.cell(hud, 0, 0, "R:R VISUALIZER [D3R]", text_color=C_TXT,
               bgcolor=color.new(#1e293b, 0), text_size=11, text_halign=text.align_center)
    table.merge_cells(hud, 0, 0, 1, 0)

    table.cell(hud, 0, 1, "Direction", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 1, not plan_valid ? "—" : is_long ? "▲ LONG" : "▼ SHORT",
               text_color=not plan_valid ? C_DIM : is_long ? C_BULL : C_BEAR,
               bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 2, "R : R", text_color=C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11)
    table.cell(hud, 1, 2, na(rr_ratio) ? "—" : "1 : " + str.tostring(rr_ratio, "#.##"),
               text_color=na(rr_ratio) ? C_DIM : rr_ratio >= 2.0 ? C_GREEN : rr_ratio >= 1.0 ? C_AMBER : C_RED,
               bgcolor=color.new(#0f172a, 40), text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 3, "Position Size", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 3, na(pos_size) ? "—" : str.tostring(pos_size, format.mintick),
               text_color=C_TXT, bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 4, "Risk Amount", text_color=C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11)
    table.cell(hud, 1, 4, na(risk_dollars) ? "—" : "$" + str.tostring(risk_dollars, "#.##"),
               text_color=C_RED, bgcolor=color.new(#0f172a, 40), text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 5, "Reward Amount", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 5, na(reward_dollars) ? "—" : "$" + str.tostring(reward_dollars, "#.##"),
               text_color=C_GREEN, bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 6, "─── Plan History ───", text_color=C_DIM,
               bgcolor=color.new(#0f172a, 0), text_size=11, text_halign=text.align_center)
    table.merge_cells(hud, 0, 6, 1, 6)

    string wl_str = total_plans > 0 ? str.tostring(wins) + "W / " + str.tostring(losses) + "L" : "—"
    table.cell(hud, 0, 7, "Plans Resolved", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 7, wl_str, text_color=C_TXT, bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)

    float win_rate = total_plans > 0 ? float(wins) / float(total_plans) * 100.0 : na
    table.cell(hud, 0, 8, "Hit Rate", text_color=C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11)
    table.cell(hud, 1, 8, na(win_rate) ? "—" : str.tostring(math.round(win_rate)) + "%",
               text_color=na(win_rate) ? C_DIM : win_rate >= 50 ? C_GREEN : C_RED,
               bgcolor=color.new(#0f172a, 40), text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 9, "Total R", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 9, total_plans > 0 ? str.tostring(total_r_sum, "#.##") + "R" : "—",
               text_color=total_plans == 0 ? C_DIM : total_r_sum > 0 ? C_GREEN : C_RED,
               bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)


// ALERTS
alertcondition(just_hit_stop,   "Stop Hit",   "D3R R:R Visualizer: plan hit stop-loss")
alertcondition(just_hit_target, "Target Hit", "D3R R:R Visualizer: plan hit target")
````
