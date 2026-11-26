# Forum Initium + LTA Session Breaks (Merged)

- url: https://www.tradingview.com/script/f5E3LQ64-Forum-Initium-LTA-Session-Breaks-Merged/
- type: indicator
- pine_id: PUB;a5f033d5ea2945a79c6ef676bf58e4af
- version: 1.0

## Description

🟡 LTA ALL-IN-ONE INDICATOR
Pine Script v6 | TradingView | Free to Use
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Built around the Lorenzo Trading Academy
methodology. Combines 5 core concepts
into a single clean indicator so you
never need to juggle multiple tools.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT IT PLOTS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 FORUM INITIUM (FI)
→ Auto-detects the Sunday weekly open
   every single week — no manual input
→ Draws a gold line as your weekly
   bias anchor
→ Live table shows if price is ABOVE
   (bullish) or BELOW (bearish) FI
→ Background highlights when price
   is within 5 pts of FI level
→ Updates automatically every Sunday

📊 PREVIOUS WEEK HIGH / LOW
→ PWH and PWL plotted automatically
→ Key structural reference levels
→ Labelled on the right of your chart

🕒 SESSION BREAK MARKERS
→ Vertical dotted lines at every
   daily session open
→ Separate dashed line at NY 18:00
   (weekly session reference point)
→ All fully toggle-able

📈 CURRENT WEEK VOLUME PROFILE
→ Auto-calculates POC, VAH and VAL
   for the current live week
→ 128 row resolution (LTA standard)
→ 70% Value Area (LTA standard)
→ Value area shaded automatically

📉 PREVIOUS WEEK VOLUME PROFILE
→ Same levels for last week
→ POC, VAH, VAL all plotted
→ Dashed style to separate from
   current week visually

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BUILT-IN ALERTS (12 total):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⬆️ Price crosses ABOVE Forum Initium
⬇️ Price crosses BELOW Forum Initium
⚠️ Price approaching FI (within 5 pts)
🎯 Price touching FI level
🗓️ New week opened — FI set
⬆️ Above / ⬇️ Below CW POC
⬆️ Above / ⬇️ Below PW POC
⬆️ Above CW VAH (breakout mode)
⬇️ Below CW VAL (breakdown mode)
🕕 NY 18:00 session marker

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EVERYTHING IS TOGGLE-ABLE:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
→ Turn any layer on or off
→ Change all colours to your preference
→ Adjust line widths
→ Change value area % and row count
→ Works on any timeframe
→ Best used on 5M and 1M charts

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COMPATIBLE WITH:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ XAUUSD (Gold) — primary use case
✅ Forex pairs
✅ Indices (US30, NAS100, GER30)
✅ Crypto (BTCUSD etc)
✅ TradingView Essential plan or above
✅ Pine Script v6

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO INSTALL:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Open TradingView → Pine Editor
2. Select All (Ctrl+A) → Delete
3. Paste the full script
4. Save (Ctrl+S)
5. Click Add to Chart
6. Set your alerts via Right Click
   → Add Alert on indicator

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Not a signal tool — a confluence tool.
Use it to identify your key levels,
then apply your own entry process.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Source Code

````pine
//@version=6
indicator("Forum Initium + LTA Session Breaks (Merged)", overlay=true, max_lines_count=200, max_labels_count=200)

// ============================================================
// MERGED FEATURES
// 1. Forum Initium / Sunday Open fixed line
// 2. Previous Week High / Low
// 3. Session Break vertical markers
// 4. NY 18:00 timestamp markers (LTA style reference)
// 5. Weekly bias table
// 6. Approach zone highlight + alerts
// ============================================================

// ─────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────
grp_fi = "📍 Forum Initium"
fi_color = input.color(color.new(#F5C842, 0), "Sunday Open / FI Colour", group=grp_fi)
fi_width = input.int(2, "FI Width", minval=1, maxval=4, group=grp_fi)
show_fi_label = input.bool(true, "Show FI Label", group=grp_fi)
show_bias = input.bool(true, "Show Weekly Bias Table", group=grp_fi)
show_approach = input.bool(true, "Show FI Approach Zone", group=grp_fi)
approach_pts = input.float(5.0, "Approach Zone (pts)", minval=0.1, step=0.1, group=grp_fi)

grp_pw = "📊 Previous Week"
show_pw = input.bool(true, "Show Previous Week High / Low", group=grp_pw)
pw_hi_col = input.color(color.new(#26A69A, 60), "PW High Colour", group=grp_pw)
pw_lo_col = input.color(color.new(#EF5350, 60), "PW Low Colour", group=grp_pw)
show_pw_labels = input.bool(true, "Show PWH / PWL Labels", group=grp_pw)

grp_sb = "🕒 Session Breaks"
show_daily_breaks = input.bool(true, "Show Daily Session Breaks", group=grp_sb)
daily_break_color = input.color(color.new(color.gray, 65), "Daily Break Colour", group=grp_sb)
daily_break_width = input.int(1, "Daily Break Width", minval=1, maxval=3, group=grp_sb)
show_ny_1800 = input.bool(true, "Show 18:00 New York Markers", group=grp_sb)
ny_line_color = input.color(color.new(#4A9EFF, 55), "NY 18:00 Colour", group=grp_sb)
ny_line_width = input.int(1, "NY 18:00 Width", minval=1, maxval=3, group=grp_sb)
ny_tz = input.string("America/New_York", "Timezone for 18:00 Marker", group=grp_sb)
show_break_labels = input.bool(false, "Show Break Labels", group=grp_sb)

// ─────────────────────────────────────────
// FORUM INITIUM (WEEKLY OPEN / SUNDAY OPEN)
// ─────────────────────────────────────────
is_new_week = ta.change(time("W")) != 0
var float forum_initium = na
if is_new_week
    forum_initium := open

plot(forum_initium, "Forum Initium", color=fi_color, linewidth=fi_width)

if show_fi_label and barstate.islast and not na(forum_initium)
    label.new(bar_index + 2, forum_initium, "FI " + str.tostring(forum_initium, format.mintick),
      style=label.style_label_left, color=color.new(fi_color, 5), textcolor=color.black, size=size.small)

// ─────────────────────────────────────────
// PREVIOUS WEEK LEVELS
// ─────────────────────────────────────────
[pw_high, pw_low] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead=barmerge.lookahead_on)
plot(show_pw ? pw_high : na, "Previous Week High", color=pw_hi_col, linewidth=1, style=plot.style_circles)
plot(show_pw ? pw_low : na, "Previous Week Low", color=pw_lo_col, linewidth=1, style=plot.style_circles)

if show_pw and show_pw_labels and barstate.islast
    label.new(bar_index + 2, pw_high, "PWH", style=label.style_label_left, color=color.new(#26A69A, 15), textcolor=color.white, size=size.tiny)
    label.new(bar_index + 2, pw_low, "PWL", style=label.style_label_left, color=color.new(#EF5350, 15), textcolor=color.white, size=size.tiny)

// ─────────────────────────────────────────
// WEEKLY BIAS TABLE
// ─────────────────────────────────────────
bullish_bias = close > forum_initium
bias_text = bullish_bias ? "🟢 ABOVE FI — Bullish Bias" : "🔴 BELOW FI — Bearish Bias"
bias_col = bullish_bias ? color.new(#26A69A, 0) : color.new(#EF5350, 0)

if show_bias and barstate.islast and not na(forum_initium)
    var table bias_tbl = table.new(position.top_right, 1, 2, bgcolor=color.new(color.black, 70), border_width=1)
    table.cell(bias_tbl, 0, 0, "Forum Initium: " + str.tostring(forum_initium, format.mintick), text_color=color.new(fi_color, 0), text_size=size.small)
    table.cell(bias_tbl, 0, 1, bias_text, text_color=bias_col, text_size=size.small)

// ─────────────────────────────────────────
// APPROACH ZONE
// ─────────────────────────────────────────
in_fi_zone = show_approach and not na(forum_initium) and math.abs(close - forum_initium) <= approach_pts
bgcolor(in_fi_zone ? color.new(fi_color, 88) : na, title="FI Approach Zone")

// ─────────────────────────────────────────
// SESSION BREAKS (DAILY)
// ─────────────────────────────────────────
new_day = ta.change(time("D")) != 0
if show_daily_breaks and new_day
    line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=daily_break_color, width=daily_break_width, style=line.style_dotted)
    if show_break_labels
        label.new(bar_index, high, "Day", style=label.style_label_down, color=color.new(daily_break_color, 10), textcolor=color.white, size=size.tiny)

// ─────────────────────────────────────────
// NEW YORK 18:00 MARKERS (LTA-style timestamp reference)
// ─────────────────────────────────────────
ny_hour = hour(time, ny_tz)
ny_min = minute(time, ny_tz)
ny_1800 = ny_hour == 18 and ny_min == 0

if show_ny_1800 and ny_1800
    line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=ny_line_color, width=ny_line_width, style=line.style_dashed)
    if show_break_labels
        label.new(bar_index, high, "NY 18:00", style=label.style_label_down, color=color.new(#4A9EFF, 10), textcolor=color.white, size=size.tiny)

// ─────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────
alertcondition(ta.crossover(close, forum_initium),
 title="⬆️ Crossed Above Forum Initium",
 message="{{ticker}} crossed ABOVE Forum Initium at {{close}}. Weekly bias now BULLISH.")

alertcondition(ta.crossunder(close, forum_initium),
 title="⬇️ Crossed Below Forum Initium",
 message="{{ticker}} crossed BELOW Forum Initium at {{close}}. Weekly bias now BEARISH.")

alertcondition(in_fi_zone and not in_fi_zone[1],
 title="⚠️ Approaching Forum Initium",
 message="{{ticker}} is approaching the Forum Initium level at {{close}}. Check for rejection or acceptance.")

alertcondition(is_new_week,
 title="🗓️ New Week — Forum Initium Set",
 message="New weekly candle opened. Forum Initium set at {{open}} on {{ticker}}.")

alertcondition(show_ny_1800 and ny_1800,
 title="🕕 NY 18:00 Marker",
 message="{{ticker}} printed the 18:00 New York timestamp marker.")
````
