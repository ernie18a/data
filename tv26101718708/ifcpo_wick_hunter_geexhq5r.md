# iFCPO Wick Hunter

- url: https://www.tradingview.com/script/GEeXHQ5R-iFCPO-Wick-Hunter/
- type: indicator
- pine_id: PUB;f180fdc0e6314874b20b3b9a6a851fd5
- version: 3.0

## Description

iFCPO Wick Hunter Lite — single-purpose W229 LONG signal for FCPO PM session.

Detects lower-wick > 10pts (size of the rejection wick below the candle body). Default filters:
- PM-only (14:30-16:30 MYT, W229 research)
- Skip Tuesday (W250 No-Tuesday law)
- Mute after 16:30 (frequency exhaustion)

Green up-triangle below bar marks valid LONG signal. Outputs trigger + wick_size booleans.

FREE indicator from iFCPO — Malaysia palm-oil futures trading platform.

## Source Code

````pine
//@version=6
// iFCPO Wick Hunter — W229-B/W250 PM lower-wick entry trigger
// Tier: FREE | Category: Price Action | Free-Tier ACTION layer
// Research anchor: W229-B (lower-wick > 10pt PM long edge) + W250 (No-Tuesday law)
// KPI: T:107, +RM20,690 net, DD 1.03%, +RM193/trade (W229-B PM 14:30-16:30 NoTue)
// Pair with: regime-meter (gate), session-law-enforcer (window), mpob-volume-spike (event flag), myr-context + soyoil-spread (conviction modifiers)
indicator("iFCPO Wick Hunter", "iFCPO Wick", overlay = true, max_labels_count = 250)

// ── Inputs ──
wick_thresh    = input.float(10, "Wick threshold (pts) — W229 default 10", minval = 1, group = "Detection")
gate_pm        = input.bool(true,  "Gate: 14:30-16:30 PM only (W229 quality window)", group = "Filters")
gate_no_tue    = input.bool(true,  "Gate: skip Tuesday (W250 No-Tue law)",            group = "Filters")
suppress_late  = input.bool(true,  "Mute after 16:30 (W229 sweet-spot)",              group = "Filters")
gate_long_only = input.bool(true,  "LONG-only (W229 PM asymmetry — shorts dead)",     group = "Filters")
show_table     = input.bool(true,  "Show research stats table",                       group = "Display")
show_pm_tint   = input.bool(true,  "Tint PM Edge Zone background",                    group = "Display")
show_wick_lbl  = input.bool(true,  "Label wick size on triggers",                     group = "Display")
table_pos      = input.string("top_right", "Table position", options = ["top_right","top_left","bottom_right","bottom_left"], group = "Display")

// ── Time gates ──
TZ = "Asia/Kuala_Lumpur"
in_pm_window = not na(time(timeframe.period, "1430-1630:23456", TZ))
in_pm_full   = not na(time(timeframe.period, "1430-1800:23456", TZ))
late_pm      = hour(time, TZ) * 60 + minute(time, TZ) >= 16 * 60 + 30
is_tue       = dayofweek(time, TZ) == dayofweek.tuesday
dow_v        = dayofweek(time, TZ)
day_lbl      = dow_v == dayofweek.monday ? "Mon" : dow_v == dayofweek.tuesday ? "Tue" : dow_v == dayofweek.wednesday ? "Wed" : dow_v == dayofweek.thursday ? "Thu" : dow_v == dayofweek.friday ? "Fri" : "Wknd"

// ── Wick math ──
wick_lo = math.min(open, close) - low
wick_ok = wick_lo > wick_thresh

// ── Composite trigger ──
pm_ok    = not gate_pm or in_pm_window
tue_ok   = not (gate_no_tue and is_tue)
late_ok  = not (suppress_late and late_pm)
quality_ok = pm_ok and tue_ok and late_ok
trigger  = wick_ok and quality_ok

// Detail flags for table
gate_pm_lbl   = pm_ok    ? "✓" : "✗"
gate_tue_lbl  = tue_ok   ? "✓" : "✗"
gate_late_lbl = late_ok  ? "✓" : "✗"

// ── Today's signal count ──
new_day = ta.change(dayofmonth(time, TZ)) != 0
var int signals_today = 0
if new_day
    signals_today := 0
if trigger
    signals_today += 1

// ── Bars-since-last-trigger ──
var int last_trigger_bar = na
if trigger
    last_trigger_bar := bar_index
bars_since = na(last_trigger_bar) ? na : bar_index - last_trigger_bar

// ── Visualization ──
bgcolor(show_pm_tint and in_pm_window ? color.new(#1FC77E, 96) : na, title = "PM Edge Zone")
bgcolor(show_pm_tint and in_pm_full and not in_pm_window ? color.new(#E0B544, 96) : na, title = "PM Late (muted)")

plotshape(trigger, "Wick LONG signal", style = shape.triangleup, location = location.belowbar, color = color.new(#1FC77E, 0), size = size.normal, text = "WICK")

if show_wick_lbl and trigger
    label.new(bar_index, low, str.tostring(wick_lo, "#") + "pt",
       color = color.new(#1FC77E, 30), textcolor = color.white,
       style = label.style_label_up, size = size.small)

// ── Status table ──
tbl_pos = table_pos == "top_right" ? position.top_right : table_pos == "top_left" ? position.top_left : table_pos == "bottom_right" ? position.bottom_right : position.bottom_left
var table tbl = table.new(tbl_pos, 2, 9, bgcolor = color.new(color.black, 15), border_width = 1, border_color = color.new(color.gray, 60))
if show_table and barstate.islast
    table.cell(tbl, 0, 0, "iFCPO • Wick Hunter", bgcolor = color.new(#1FC77E, 30), text_color = color.white, text_size = size.small)
    table.merge_cells(tbl, 0, 0, 1, 0)
    // Wick measurement
    wick_col = wick_ok ? #1FC77E : color.new(color.white, 50)
    table.cell(tbl, 0, 1, "Wick now", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 1, str.tostring(wick_lo, "#.#") + " / " + str.tostring(wick_thresh, "#") + "pt", text_color = wick_col, text_size = size.tiny)
    // Day check
    table.cell(tbl, 0, 2, "Today", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 2, day_lbl + (is_tue ? " (W250 dead)" : " ✓"), text_color = is_tue ? #FF3B5C : #1FC77E, text_size = size.tiny)
    // PM gate
    pm_state = in_pm_window ? "OPEN (14:30-16:30)" : in_pm_full ? "Late PM (muted)" : "Closed"
    pm_col   = in_pm_window ? #1FC77E : in_pm_full ? #E0B544 : color.new(color.white, 50)
    table.cell(tbl, 0, 3, "PM Gate", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 3, pm_state, text_color = pm_col, text_size = size.tiny)
    // Today's signal count
    table.cell(tbl, 0, 4, "Signals today", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 4, str.tostring(signals_today), text_color = color.white, text_size = size.tiny)
    // Composite state
    state_lbl = trigger ? "★ FIRING NOW" : quality_ok ? "Armed — waiting wick" : "Disarmed"
    state_col = trigger ? #1FC77E : quality_ok ? #E0B544 : color.new(color.white, 40)
    table.cell(tbl, 0, 5, "State", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 5, state_lbl, text_color = state_col, text_size = size.small)
    // Research provenance
    table.cell(tbl, 0, 6, "W229-B KPI", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 6, "+RM193/trade", text_color = #1FC77E, text_size = size.tiny)
    table.cell(tbl, 0, 7, "Trade rule", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 7, "TP=100 SL=15 (W32)", text_color = color.new(color.white, 80), text_size = size.tiny)
    // Pair-with
    table.cell(tbl, 0, 8, "Pair with", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 8, "regime, sess, mpob, myr, soy", text_color = color.new(#3B82F6, 0), text_size = size.tiny)

// ── Alerts ──
alertcondition(trigger, title = "iFCPO Wick LONG (W229-B)", message = "iFCPO Wick LONG fired — W229-B PM gate + No-Tue. Wick > 10pt detected.")

// ── Chainable boolean outputs (for system stacking) ──
plot(trigger ? 1 : 0,        "wick_trigger",  display = display.data_window)
plot(wick_ok ? 1 : 0,        "wick_ok",       display = display.data_window)
plot(quality_ok ? 1 : 0,     "quality_ok",    display = display.data_window)
plot(in_pm_window ? 1 : 0,   "in_pm_window",  display = display.data_window)
plot(is_tue ? 1 : 0,         "is_tuesday",    display = display.data_window)
plot(wick_lo,                "wick_size_pts", display = display.data_window)
````
