# Daily Open-to-Close & Close-to-Close Move (%)

- url: https://www.tradingview.com/script/x4WjoDI1-Daily-Open-to-Close-Close-to-Close-Move/
- type: indicator
- pine_id: PUB;b06a801c0b10469b83ee67fd35952e9d
- version: 1.0

## Description

Im seeing how often a ticker closes within a certain dollar amount of open or previous close, and how often it runs in streaks.

## Source Code

````pine
//@version=5
indicator(title="Daily Open-to-Close & Close-to-Close Move (%)", shorttitle="O→C / C→C Move %", overlay=false)

// --- Inputs ---
wing_pct = input.float(0.14, title="Wing Width (% of open)", minval=0.01, maxval=5.0, step=0.01, tooltip="One-sided wing as % of opening price. Total loss zone = 2x this value.")

use_mon = input.bool(true, title="Include Mondays",    group="Days of Week")
use_tue = input.bool(true, title="Include Tuesdays",   group="Days of Week")
use_wed = input.bool(true, title="Include Wednesdays", group="Days of Week")
use_thu = input.bool(true, title="Include Thursdays",  group="Days of Week")
use_fri = input.bool(true, title="Include Fridays",    group="Days of Week")

// --- Data (daily chart: request.security same as chart tf, no repeat issue) ---
daily_open  = request.security(syminfo.tickerid, "D", open,      lookahead=barmerge.lookahead_off)
daily_close = request.security(syminfo.tickerid, "D", close,     lookahead=barmerge.lookahead_off)
prev_close  = request.security(syminfo.tickerid, "D", close[1],  lookahead=barmerge.lookahead_off)
dow         = request.security(syminfo.tickerid, "D", dayofweek, lookahead=barmerge.lookahead_off)

wing_dollar = daily_open * (wing_pct / 100)
otc_pct     = (daily_close - daily_open) / daily_open * 100
ctc_pct     = (daily_close - prev_close) / prev_close * 100

day_included = (dow == dayofweek.monday    and use_mon) or
               (dow == dayofweek.tuesday   and use_tue) or
               (dow == dayofweek.wednesday and use_wed) or
               (dow == dayofweek.thursday  and use_thu) or
               (dow == dayofweek.friday    and use_fri)

// Use float comparison explicitly to avoid integer division bugs
is_loss = math.abs(otc_pct) < wing_pct
is_win  = not is_loss

// --- Running stats ---
var int   total_days      = 0
var int   win_days        = 0
var int   loss_days       = 0
var int   cur_win_streak  = 0
var int   cur_loss_streak = 0
var int   max_win_streak  = 0
var int   max_loss_streak = 0

if not na(otc_pct) and not na(daily_open) and day_included
    total_days += 1
    if is_win
        win_days        += 1
        cur_win_streak  += 1
        cur_loss_streak := 0
        max_win_streak  := math.max(max_win_streak, cur_win_streak)
    else
        loss_days       += 1
        cur_loss_streak += 1
        cur_win_streak  := 0
        max_loss_streak := math.max(max_loss_streak, cur_loss_streak)

// Cast to float before dividing to avoid integer division
win_rate = total_days > 0 ? (float(win_days) / float(total_days)) * 100.0 : 0.0

// --- Plots ---
plot(otc_pct, title="Open→Close (%)",  color=color.new(color.blue, 0), linewidth=2)
plot(ctc_pct, title="Close→Close (%)", color=color.new(color.red,  0), linewidth=2)

hline(0, "Zero", color=color.new(color.gray, 50), linewidth=1, linestyle=hline.style_dashed)

plot( wing_pct, title="+Wing %", color=color.new(color.orange, 40), linewidth=1)
plot(-wing_pct, title="-Wing %", color=color.new(color.orange, 40), linewidth=1)

bgcolor(is_loss and day_included ? color.new(color.red, 88) : na, title="Loss zone")

// --- Stats table ---
var table t = table.new(position.top_right, 2, 7,
     bgcolor=color.new(color.black, 80),
     border_width=1, border_color=color.new(color.gray, 60),
     frame_width=1,  frame_color=color.new(color.gray, 60))

if barstate.islast
    table.cell(t, 0, 0, "Metric",           text_color=color.gray,  text_size=size.small)
    table.cell(t, 1, 0, "Value",            text_color=color.gray,  text_size=size.small)

    table.cell(t, 0, 1, "Wing (each side)", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 1, str.tostring(wing_pct, "#.##") + "% / $" + str.tostring(wing_dollar, "#.##"), text_color=color.orange, text_size=size.small)

    table.cell(t, 0, 2, "Win rate",         text_color=color.white, text_size=size.small)
    table.cell(t, 1, 2, str.tostring(win_rate, "#.1f") + "% (" + str.tostring(win_days) + "/" + str.tostring(total_days) + " days)", text_color=color.green, text_size=size.small)

    table.cell(t, 0, 3, "Loss days",        text_color=color.white, text_size=size.small)
    table.cell(t, 1, 3, str.tostring(loss_days),                    text_color=color.red,   text_size=size.small)

    table.cell(t, 0, 4, "Longest W streak", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 4, str.tostring(max_win_streak) + " days",     text_color=color.green, text_size=size.small)

    table.cell(t, 0, 5, "Longest L streak", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 5, str.tostring(max_loss_streak) + " days",    text_color=color.red,   text_size=size.small)

    table.cell(t, 0, 6, "Current streak",   text_color=color.white, text_size=size.small)
    cur_streak_str = cur_win_streak > 0 ? str.tostring(cur_win_streak) + "W" : str.tostring(cur_loss_streak) + "L"
    cur_streak_col = cur_win_streak > 0 ? color.green : color.red
    table.cell(t, 1, 6, cur_streak_str, text_color=cur_streak_col, text_size=size.small)

    label.new(bar_index, otc_pct,
         text="O→C: " + str.tostring(otc_pct, "#.##") + "% ($" + str.tostring(daily_close - daily_open, "#.##") + ")",
         style=label.style_label_left, color=color.new(color.blue, 80), textcolor=color.blue, size=size.small)
    label.new(bar_index, ctc_pct,
         text="C→C: " + str.tostring(ctc_pct, "#.##") + "% ($" + str.tostring(daily_close - prev_close, "#.##") + ")",
         style=label.style_label_left, color=color.new(color.red, 80), textcolor=color.red, size=size.small)
    label.new(bar_index, -wing_pct - 0.03,
         text="Wing = $" + str.tostring(wing_dollar, "#.##") + " each side",
         style=label.style_label_left, color=color.new(color.orange, 80), textcolor=color.orange, size=size.small)
````
