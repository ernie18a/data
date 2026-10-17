# iFCPO Session Law

- url: https://www.tradingview.com/script/V4XqCLT3-iFCPO-Session-Law/
- type: indicator
- pine_id: PUB;f3e9f133676048808dc0011dca95ef04
- version: 2.0

## Description

iFCPO Session-Timeframe Law Enforcer — visual reminder of the FCPO research law.

Greys out research-confirmed weak sessions (AM 10:30-12:30, Lunch 12:30-14:30, Night 21:00-23:30). Highlights PM 14:30-18:00 as the Edge Zone (W18 research). Auto-prints labels at session opens.

Use this as a discipline tool — only trade in the green-highlighted PM Edge Zone window. FCPO white-space pioneer.

FREE indicator from iFCPO — Malaysia palm-oil futures trading platform.

## Source Code

````pine
//@version=6
// iFCPO Session-Timeframe Law Enforcer — visual W18 Edge Zone gate
// Tier: FREE | Category: Sessions | Free-Tier ACTION layer
// Research anchor: W18 Session-Timeframe Law (PM 14:30-18:00 = the only edge zone on FCPO M5)
// Closed laws: AM 10:30-12:30 = research weak (W31 confirmed at depth), Night 21:00-23:30 = 8x weaker (W24)
// W229 quality refinement: 14:30-16:30 = sweet spot inside the W18 PM window
// Pair with: wick-hunter-lite (entry trigger), regime-meter (gate), holiday-skip (block)
indicator("iFCPO Session Law", "iFCPO SLw", overlay = true, max_labels_count = 100)

mute_am      = input.bool(true,  "Grey out AM (10:30-12:30) — W18 weak",   group = "Mute")
mute_lunch   = input.bool(true,  "Grey out Lunch (12:30-14:30) — closed",  group = "Mute")
mute_night   = input.bool(true,  "Grey out Night (21:00-23:30) — W24 weak", group = "Mute")
highlight_pm = input.bool(true,  "Highlight PM Edge Zone 14:30-18:00 (W18)", group = "Highlight")
highlight_w229 = input.bool(true, "Brighten W229 quality window 14:30-16:30", group = "Highlight")
show_table   = input.bool(true,  "Show research stats table",              group = "Display")
show_open_lbl = input.bool(true, "Label PM open + close events",           group = "Display")
table_pos    = input.string("top_left", "Table position", options = ["top_right","top_left","bottom_right","bottom_left"], group = "Display")

TZ = "Asia/Kuala_Lumpur"
in_am    = not na(time(timeframe.period, "1030-1230:23456", TZ))
in_lunch = not na(time(timeframe.period, "1230-1430:23456", TZ))
in_pm    = not na(time(timeframe.period, "1430-1800:23456", TZ))
in_w229  = not na(time(timeframe.period, "1430-1630:23456", TZ))
in_night = not na(time(timeframe.period, "2100-2330:23456", TZ))

session_lbl = in_w229 ? "★ W229 SWEET-SPOT" : in_pm ? "PM Edge (late)" : in_lunch ? "Lunch (closed)" : in_am ? "AM (W18 weak)" : in_night ? "Night (W24 weak)" : "Pre-/Post-market"
session_col = in_w229 ? #1FC77E : in_pm ? #E0B544 : color.new(color.white, 40)

hr_now = hour(time, TZ)
mn_now = minute(time, TZ)
mins_now = hr_now * 60 + mn_now
pm_open_mins = 14 * 60 + 30
pm_close_mins = 18 * 60
mins_to_pm_open = mins_now < pm_open_mins ? pm_open_mins - mins_now : 0
mins_left_in_pm = in_pm ? pm_close_mins - mins_now : 0

mute_col = color.new(color.gray, 88)
bgcolor(mute_am    and in_am    ? mute_col : na, title = "AM mute")
bgcolor(mute_lunch and in_lunch ? mute_col : na, title = "Lunch mute")
bgcolor(mute_night and in_night ? mute_col : na, title = "Night mute")
bgcolor(highlight_w229 and in_w229 ? color.new(#1FC77E, 92) : na, title = "W229 sweet-spot")
bgcolor(highlight_pm and in_pm and not in_w229 ? color.new(#E0B544, 95) : na, title = "PM Edge (late)")

if show_open_lbl and in_pm and not in_pm[1]
    label.new(bar_index, high, "★ PM Edge Zone OPEN — Trade window (14:30-18:00)\nW18 research law • W229 sweet-spot 14:30-16:30",
       color = color.new(#1FC77E, 30), textcolor = color.white, style = label.style_label_down, size = size.normal)
if show_open_lbl and in_pm[1] and not in_pm
    label.new(bar_index, high, "PM Edge Zone CLOSED",
       color = color.new(color.gray, 30), textcolor = color.white, style = label.style_label_down, size = size.small)
if show_open_lbl and in_am and not in_am[1]
    label.new(bar_index, high, "AM session — W18 weak (caution)",
       color = color.new(color.gray, 40), textcolor = color.white, style = label.style_label_down, size = size.tiny)

tbl_pos = table_pos == "top_right" ? position.top_right : table_pos == "top_left" ? position.top_left : table_pos == "bottom_right" ? position.bottom_right : position.bottom_left
var table tbl = table.new(tbl_pos, 2, 8, bgcolor = color.new(color.black, 15), border_width = 1, border_color = color.new(color.gray, 60))
if show_table and barstate.islast
    table.cell(tbl, 0, 0, "iFCPO • Session Law", bgcolor = color.new(#1FC77E, 30), text_color = color.white, text_size = size.small)
    table.merge_cells(tbl, 0, 0, 1, 0)
    table.cell(tbl, 0, 1, "State", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 1, session_lbl, text_color = session_col, text_size = size.small)
    time_lbl = mins_to_pm_open > 0 ? "PM in " + str.tostring(mins_to_pm_open) + " min" : in_pm ? str.tostring(mins_left_in_pm) + " min left" : "Closed"
    time_col = mins_to_pm_open > 0 and mins_to_pm_open < 60 ? #E0B544 : in_pm ? #1FC77E : color.new(color.white, 50)
    table.cell(tbl, 0, 2, "Time", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 2, time_lbl, text_color = time_col, text_size = size.tiny)
    table.cell(tbl, 0, 3, "W18 PM edge", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 3, "+RM94.56/day", text_color = #1FC77E, text_size = size.tiny)
    table.cell(tbl, 0, 4, "Night (W24)", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 4, "+RM11.5/day (8× weaker)", text_color = color.new(color.white, 60), text_size = size.tiny)
    table.cell(tbl, 0, 5, "AM (W31)", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 5, "PF 0.18-0.6 (avoid)", text_color = #FF3B5C, text_size = size.tiny)
    table.cell(tbl, 0, 6, "W229 sweet", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 6, "14:30-16:30 = peak", text_color = #1FC77E, text_size = size.tiny)
    table.cell(tbl, 0, 7, "Pair with", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 7, "wick-hunter, regime-meter", text_color = color.new(#3B82F6, 0), text_size = size.tiny)

alertcondition(in_pm and not in_pm[1], title = "PM Edge Zone OPEN", message = "iFCPO PM Edge Zone is now OPEN (14:30 MYT). W18 trade window engaged.")
alertcondition(in_w229 and not in_w229[1], title = "W229 sweet-spot OPEN", message = "iFCPO W229 quality window 14:30-16:30 OPEN — peak signal density.")

plot(in_pm    ? 1 : 0, "in_pm",    display = display.data_window)
plot(in_w229  ? 1 : 0, "in_w229",  display = display.data_window)
plot(in_am    ? 1 : 0, "in_am",    display = display.data_window)
plot(in_lunch ? 1 : 0, "in_lunch", display = display.data_window)
plot(in_night ? 1 : 0, "in_night", display = display.data_window)
plot(mins_to_pm_open,  "mins_to_pm_open", display = display.data_window)
plot(mins_left_in_pm,  "mins_left_in_pm", display = display.data_window)
````
