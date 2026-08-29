<!-- tradingview-pine-id: PUB;641fae5340b74d6ab68230e61db7eaa7 -->
<!-- tradingviewscripts-format: 1 -->
# TJR US Open Macro Marker Lines

Source: https://www.tradingview.com/script/2NP4qLKb-TJR-US-Open-Macro-Marker-Lines/

## Description

TJR US Open Macro Marker Lines
Version 1.0.0

Marks the US-open macro time windows from TJR's methodology on the US500 and USTEC indices, so you can see at a glance where each window starts and ends as the New York open plays out. It draws vertical boundary lines and a small top-pinned label for each window, and nothing else, keeping the chart clean.

WHAT IT DRAWS
• Five vertical boundary lines, running the full height of the chart, at the four macro-window edges: 08:30, 09:30, 09:50, 10:10 and 10:30 New York time.
• Four top-pinned labels, one centred over each window: Pre., Man., Ent. and L.Ent.
• Nothing else. There is no background shading and no on-chart clutter.

THE FOUR WINDOWS (New York time)
• Pre: 08:30-09:30
• Manipulation: 09:30-09:50
• Entry: 09:50-10:10
• Late Entry: 10:10-10:30

HOW IT WORKS
• The 08:30 line sits on the candle that opens the Pre window. The 09:30, 09:50, 10:10 and 10:30 lines are pulled back one candle so the marked candle is the one that CLOSES at that boundary time, which is where each window actually ends.
• The windows are US-anchored via the "UK-US Time Difference" input. Leave it at 5 normally, and set it to 4 for the weeks each year when the UK and US daylight-saving changeovers are out of step, which keeps every line tracking the true New York clock.
• The correct clock time is used whatever timezone your chart is set to; only where the candles fall on the time axis changes.
• Show History draws prior days as well as today. History Range limits that to the last 5 trading days (weekends are not counted, which is lighter and faster on scroll) or the full loaded history.

WHAT IT RUNS ON
• US500 and USTEC only. On any other symbol it draws nothing.
• The 1m and 5m timeframes only. TJR's macros are read on those timeframes, and the one-candle pull-back lands cleanly only on those grids. Nothing draws on any other timeframe.

HOW TO USE
• Add it to a 1m or 5m US500 or USTEC chart. The lines and labels mark out the Pre, Manipulation, Entry and Late Entry windows across the New York open.
• Each boundary line has its own colour; line width, style and opacity are shared across all five. Each label has its own colour; label opacity is shared across all four. Set them to suit your chart.
• During the DST-mismatch weeks, switch the UK-US Time Difference input to 4 so the windows stay on the New York clock.

INITIAL RELEASE
Version 1.0.0. First public release. Marks the TJR US-open macro windows (Pre, Manipulation, Entry, Late Entry) on US500 and USTEC, 1m and 5m only, with per-line and per-label colours, shared line width/style/opacity and label opacity, a 5/4 US-anchoring input for the DST-mismatch weeks, and a Show History toggle with a 5-trading-day or full-history range.

FEEDBACK
Please let me know if you experience any issues, or have feedback for improvements or additions in the comments below. Thank you, Tom

---

## Source Code

````pine
//@version=6
// =============================================================================
// TJR US OPEN MACRO MARKER LINES
// =============================================================================
// Author:       Tom Brown
// Description:  Marks the TJR US-open macro windows on US500 and USTEC only:
//               Pre (08:30-09:30 NY), Manipulation (09:30-09:50 NY), Entry
//               (09:50-10:10 NY) and Late Entry (10:10-10:30 NY). Draws vertical
//               boundary lines at the five NY boundaries and top-pinned labels
//               centred over each zone, on the 1m and 5m timeframes ONLY. All zones
//               are US-anchored and shift together on the manual 5/4 UK-US Time
//               Difference toggle. Draws nothing on any other symbol.
// Version:      1.1.0
// Date:         2026-08-06
// =============================================================================
// Notes for future-me:
//   - US500 (Chicago) and USTEC (New York) only; every draw is gated on the ticker.
//   - Locked to the 1m and 5m timeframes ONLY (TJR reads these macros on 1m/5m); the
//     one-candle pull-back also only lands cleanly on those grids. Nothing draws elsewhere.
//   - Session-drawing engine adapted from
//     CODING_SKILLS/PINE/snippets/recipes/uk-anchored-session-drawing-engine.md —
//     the boundary lines use its proven draw_uk_start_line / draw_uk_start_hist
//     (UK-anchored via timestamp("Europe/London", …), correct on any exchange tz),
//     the anchoring block is bar-replay-safe-today-anchor, and the history gate is
//     trading-days-history-cutoff. No bgcolor here, so the projection furniture
//     (in_uk_window / lon_offset_bars) is deliberately not carried over.
//   - NY 08:30/09:30/09:50/10:10/10:30 = UK 13:30/14:30/14:50/15:10/15:30 at a 5h
//     difference; the single 5/4 toggle covers all five boundaries (and the four
//     midpoints) via us_gap.

indicator("TJR US Open Macro Marker Lines", overlay = true, max_lines_count = 500, max_bars_back = 5000)

// --- input group headers ------------------------------------------------------
grp_time_zone = "════ TIME ZONE ADJUSTMENT ════"
grp_history   = "════ HISTORY RANGE ════"
grp_lines     = "════ ZONE BOUNDARY LINES ════"
grp_labels    = "════ ZONE LABELS ════"

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ════ TIME ZONE ADJUSTMENT ════
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
lon_ukus_time_difference = input.int(5, "UK-US Time Difference", options = [5, 4], group = grp_time_zone, tooltip = "Hours between UK and US clocks: 5 normally, 4 during the spring/autumn DST-gap weeks. Shifts all four zones (US-anchored) together.")

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ════ HISTORY RANGE ════
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
show_history  = input.bool(true, "Show History", group = grp_history, tooltip = "Draw prior days' lines and labels, not just today's.")
history_range = input.string("5 Days", "History range", options = ["5 Days", "Max History"], group = grp_history, tooltip = "Limit historical drawing to the last 5 TRADING days (weekends excluded; lighter / faster on scroll), or draw the full loaded history.")

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ════ ZONE BOUNDARY LINES ════
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// One colour per boundary line; shared width / style / opacity. Five lines at
// 08:30 / 09:30 / 09:50 / 10:10 / 10:30 NY.
l1_color     = input.color(color.orange,            "08:30 Line Colour (Pre start)",          group = grp_lines, tooltip = "Colour of the 08:30 NY boundary line (Pre zone start).")
l2_color     = input.color(color.red,               "09:30 Line Colour (Manipulation start)", group = grp_lines, tooltip = "Colour of the 09:30 NY boundary line (Pre end / Manipulation start).")
l3_color     = input.color(color.rgb(76, 175, 80),  "09:50 Line Colour (Entry start)",        group = grp_lines, tooltip = "Colour of the 09:50 NY boundary line (Manipulation end / Entry start).")
l4_color     = input.color(color.rgb(76, 175, 80),  "10:10 Line Colour (Late Entry start)",   group = grp_lines, tooltip = "Colour of the 10:10 NY boundary line (Entry end / Late Entry start).")
l5_color     = input.color(color.black,             "10:30 Line Colour (Late Entry end)",     group = grp_lines, tooltip = "Colour of the 10:30 NY boundary line (Late Entry end).")
line_width   = input.int(1, "Boundary Line Width", minval = 1, group = grp_lines, tooltip = "Width of the zone-boundary lines.")
line_style   = input.string(line.style_solid, "Boundary Line Style", options = [line.style_solid, line.style_dotted, line.style_dashed], group = grp_lines, tooltip = "Style of the zone-boundary lines.")
line_opacity = input.int(25, "Boundary Line Opacity", minval = 0, maxval = 100, group = grp_lines, tooltip = "0 = invisible, 100 = solid. Higher = more solid.")

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ════ ZONE LABELS ════
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// One colour per zone label; shared opacity. Label size is fixed at Small: plotshape's
// size argument requires a const, so it cannot be exposed as a user input. Labels pin to
// the top of the pane (location.top), centred over each zone's midpoint (09:00 / 09:40 / 10:00 / 10:20 NY).
pre_color     = input.color(color.rgb(255, 179, 0),   "Pre Label Colour",          group = grp_labels, tooltip = "Colour of the 'Pre.' label (Pre zone, 08:30-09:30 NY).")
man_color     = input.color(color.red,                "Manipulation Label Colour", group = grp_labels, tooltip = "Colour of the 'Man.' label (Manipulation zone, 09:30-09:50 NY).")
ent_color     = input.color(color.rgb(76, 175, 80),   "Entry Label Colour",        group = grp_labels, tooltip = "Colour of the 'Ent.' label (Entry zone, 09:50-10:10 NY).")
lent_color    = input.color(color.rgb(165, 214, 167), "Late Entry Label Colour",   group = grp_labels, tooltip = "Colour of the 'L.Ent.' label (Late Entry zone, 10:10-10:30 NY).")
label_opacity = input.int(100, "Label Opacity", minval = 0, maxval = 100, group = grp_labels, tooltip = "0 = invisible, 100 = solid. Higher = more solid.")

// --- resolved colours ---------------------------------------------------------
final_l1_color = color.new(l1_color, 100 - line_opacity)
final_l2_color = color.new(l2_color, 100 - line_opacity)
final_l3_color = color.new(l3_color, 100 - line_opacity)
final_l4_color = color.new(l4_color, 100 - line_opacity)
final_l5_color = color.new(l5_color, 100 - line_opacity)
final_pre_color  = color.new(pre_color,  100 - label_opacity)
final_man_color  = color.new(man_color,  100 - label_opacity)
final_ent_color  = color.new(ent_color,  100 - label_opacity)
final_lent_color = color.new(lent_color, 100 - label_opacity)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SHARED STATE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Anchor "now" to the LAST BAR's time, not wall-clock timenow, so today/yesterday
// follow Bar Replay (live, last_bar_time == the current forming bar → same result).
// See bar-replay-safe-today-anchor.md.
ref_now      = last_bar_time
is_today     = dayofmonth(time) == dayofmonth(ref_now) and month(time) == month(ref_now) and year(time) == year(ref_now)
is_yesterday = dayofmonth(time) == dayofmonth(ref_now - 86400000) and month(time) == month(ref_now - 86400000) and year(time) == year(ref_now - 86400000)

// US500 (Chicago) and USTEC (New York) only — every draw is gated on this.
is_us_symbol = syminfo.ticker == "US500" or syminfo.ticker == "USTEC"

// Timeframe gate: 1m and 5m ONLY. TJR's US-open macros are only ever read on 1m and 5m,
// and the one-candle pull-back lands cleanly only on those grids (on 2m/3m/4m the pulled-
// back boundary minutes fall between bars). Intraday, non-seconds, multiplier 1 or 5.
tf_ok = timeframe.isintraday and not timeframe.isseconds and (timeframe.multiplier == 1 or timeframe.multiplier == 5)

// History range gate — "5 Days" = the last 5 TRADING days (weekends do NOT count),
// applied to BOTH the lines and the labels. See trading-days-history-cutoff.md.
cal_days_back     = dayofweek(ref_now) == dayofweek.friday ? 4 : dayofweek(ref_now) == dayofweek.saturday ? 5 : 6
range_cut_ms      = ref_now - cal_days_back * 86400000
range_cutoff      = timestamp("UTC", year(range_cut_ms), month(range_cut_ms), dayofmonth(range_cut_ms), 0, 0)
hist_within_range = history_range == "Max History" or time >= range_cutoff

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUNCTIONS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Session-drawing engine adapted from
// CODING_SKILLS/PINE/snippets/recipes/uk-anchored-session-drawing-engine.md
// (draw_uk_start_line / draw_uk_start_hist, plus the close_adjust pull-back from the
// recipe's draw_uk_sess_line). UK-anchored via timestamp("Europe/London", …) so it lands
// correctly on any exchange tz (US500 = Chicago, USTEC = New York). us_anchored → the
// bound shifts one hour earlier in the DST-mismatch weeks (us_gap). is_close → the line
// is pulled back one candle so it sits on the bar that CLOSES at the boundary time
// (14:30 → 14:25 on 5m, 14:29 on 1m); the close of that bar IS the boundary.

// Pull a boundary time back one candle (subtract the timeframe's minutes), with hour
// borrow. General over the timeframe (1m/5m here). See session-close-back-nudge.
close_adjust(h, m) =>
    adj_h = h
    adj_m = m - timeframe.multiplier
    if adj_m < 0
        adj_m := adj_m + 60
        adj_h := (h - 1 + 24) % 24
    [adj_h, adj_m]

// Zone-boundary line at a UK time (today's date). is_close pulls it back one candle.
draw_uk_start_line(uk_h, uk_m, us_anchored, is_close, ln_color, ln_width, ln_style) =>
    us_gap = 5 - lon_ukus_time_difference
    bh = uk_h
    bm = uk_m
    if is_close
        [ch, cm] = close_adjust(uk_h, uk_m)
        bh := ch
        bm := cm
    h = bh - (us_anchored ? us_gap : 0)
    t = timestamp("Europe/London", year(ref_now, "Europe/London"), month(ref_now, "Europe/London"), dayofmonth(ref_now, "Europe/London"), h, bm)
    line.new(t, high, t, low, xloc = xloc.bar_time, extend = extend.both, color = ln_color, width = ln_width, style = ln_style)

// Historical twin — draws on the matching prior-day bar, detected in UK time.
draw_uk_start_hist(uk_h, uk_m, us_anchored, is_close, ln_color, ln_width, ln_style) =>
    us_gap = 5 - lon_ukus_time_difference
    bh = uk_h
    bm = uk_m
    if is_close
        [ch, cm] = close_adjust(uk_h, uk_m)
        bh := ch
        bm := cm
    h = bh - (us_anchored ? us_gap : 0)
    if hour(time, "Europe/London") == h and minute(time, "Europe/London") == bm
        line.new(bar_index, high, bar_index, low, extend = extend.both, color = ln_color, width = ln_width, style = ln_style)

// True on the DETECTION bar: the bar sitting lead_ms earlier than this zone's centre, so a
// matching positive plotshape offset can project the label forward onto the centre bar, drawing
// it in advance (before price arrives) the way the boundary lines project via absolute future
// timestamps. The centre is the NOMINAL zone midpoint (uk_h:uk_m, US-anchored via us_gap) shifted
// EARLIER by back_ms, because the boundary lines are pulled back one candle: a zone with both edges
// pulled back has its centre pulled back a full candle; the Pre zone, whose left (08:30) edge is NOT
// pulled back, has its centre pulled back only half a candle. lead_ms is a whole number of bars
// (lead_ms = label_offset_bars * candle_ms), so the detection bar is exactly label_offset_bars bars
// before the centre bar on both 1m and 5m, and the offset lands the label back on the centre bar.
// Detected in UK time on the bar's own UK date, so it fires once per qualifying day across history.
label_on_midpoint(uk_h, uk_m, back_ms, lead_ms) =>
    us_gap = 5 - lon_ukus_time_difference
    h = uk_h - us_gap
    base   = timestamp("Europe/London", year(time, "Europe/London"), month(time, "Europe/London"), dayofmonth(time, "Europe/London"), h, uk_m)
    det_ts = base - back_ms - lead_ms
    time <= det_ts and det_ts < time_close

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ZONE LABELS (top-pinned, one per zone, centred over the midpoint, projected in advance)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// plotshape at location.top pins the text to a fixed height at the top of the pane,
// regardless of price. The shape itself is transparent so only the text shows.
// Nominal midpoints: Pre 09:00 NY (14:00 UK), Man 09:40 NY (14:40 UK), Entry 10:00 NY
// (15:00 UK), Late Entry 10:20 NY (15:20 UK). Each is shifted earlier to sit centred
// between its two pulled-back boundary lines: a full candle back for Man/Ent/L.Ent (both
// edges pulled), half a candle for Pre (only its right edge pulled). One candle =
// timeframe.multiplier minutes = timeframe.multiplier * 60000 ms. 1m and 5m only.
//
// FORWARD PROJECTION so today's labels appear IN ADVANCE, like the lines. A plotshape only
// renders on a bar that already exists, so firing it on the midpoint bar would hide today's label
// until price arrived. Instead each label is DETECTED label_lead_hours hours early (label_lead_ms)
// and the plotshape is pushed the SAME span forward (offset = label_offset_bars) so it lands back on
// the midpoint bar. The offset MUST be constant (it cannot vary per bar); label_offset_bars is derived
// purely from timeframe.multiplier (the recipe's lon_bars_in_1_hour idiom), so it is a valid simple
// int. The lead and the offset are the same span expressed two ways (label_lead_ms =
// label_offset_bars * candle_ms), which is why the label lands on exactly the midpoint bar on both
// the 1m and 5m grids. One offset serves both today (projected into empty space) and every
// historical day (projected onto that day's real midpoint bar); no separate today/history passes.
candle_ms         = timeframe.multiplier * 60000
label_lead_hours  = 7                                                            // detect each label this many hours before its midpoint...
label_offset_bars = int(math.round(60.0 / timeframe.multiplier * label_lead_hours))   // ...and project the shape that same span forward, in bars. Const int, from timeframe.multiplier only (recipe's lon_bars_in_1_hour idiom); math.round returns float, so int() to match plotshape's series-int offset.
label_lead_ms     = label_lead_hours * 3600000                                   // the same lead in ms for the detection pre-shift (equals label_offset_bars * candle_ms on the 1m/5m grid)
label_gate = is_us_symbol and tf_ok and (show_history or is_today) and hist_within_range
pre_fire   = label_gate and label_on_midpoint(14, 0,  candle_ms / 2, label_lead_ms)
man_fire   = label_gate and label_on_midpoint(14, 40, candle_ms,     label_lead_ms)
ent_fire   = label_gate and label_on_midpoint(15, 0,  candle_ms,     label_lead_ms)
lent_fire  = label_gate and label_on_midpoint(15, 20, candle_ms,     label_lead_ms)

plotshape(pre_fire,  title = "Pre Label",          text = "Pre.",  location = location.top, offset = label_offset_bars, style = shape.cross, color = color.new(color.black, 100), textcolor = final_pre_color,  size = size.small)
plotshape(man_fire,  title = "Manipulation Label", text = "Man.",  location = location.top, offset = label_offset_bars, style = shape.cross, color = color.new(color.black, 100), textcolor = final_man_color,  size = size.small)
plotshape(ent_fire,  title = "Entry Label",        text = "Ent.",  location = location.top, offset = label_offset_bars, style = shape.cross, color = color.new(color.black, 100), textcolor = final_ent_color,  size = size.small)
plotshape(lent_fire, title = "Late Entry Label",   text = "L.Ent.", location = location.top, offset = label_offset_bars, style = shape.cross, color = color.new(color.black, 100), textcolor = final_lent_color, size = size.small)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TODAY'S BOUNDARY LINES (drawn once, on the yesterday->today roll)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Five US-anchored boundaries: 13:30 / 14:30 / 14:50 / 15:10 / 15:30 UK (08:30 /
// 09:30 / 09:50 / 10:10 / 10:30 NY). US500 / USTEC only, 1m/5m only.
var bool today_drawn = false
if is_yesterday and tf_ok and is_us_symbol and not today_drawn
    today_drawn := true
    draw_uk_start_line(13, 30, true, false, final_l1_color, line_width, line_style)   // 08:30 NY — Pre start (ON its bar, no pull-back)
    draw_uk_start_line(14, 30, true, true,  final_l2_color, line_width, line_style)   // 09:30 NY — 1 candle before (closes at boundary)
    draw_uk_start_line(14, 50, true, true,  final_l3_color, line_width, line_style)   // 09:50 NY — 1 candle before
    draw_uk_start_line(15, 10, true, true,  final_l4_color, line_width, line_style)   // 10:10 NY — 1 candle before
    draw_uk_start_line(15, 30, true, true,  final_l5_color, line_width, line_style)   // 10:30 NY — 1 candle before

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HISTORICAL BOUNDARY LINES (prior days, drawn on the matching bar)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if show_history and tf_ok and is_us_symbol and not is_today and hist_within_range
    draw_uk_start_hist(13, 30, true, false, final_l1_color, line_width, line_style)   // 08:30 NY — Pre start (ON its bar, no pull-back)
    draw_uk_start_hist(14, 30, true, true,  final_l2_color, line_width, line_style)   // 09:30 NY — 1 candle before (closes at boundary)
    draw_uk_start_hist(14, 50, true, true,  final_l3_color, line_width, line_style)   // 09:50 NY — 1 candle before
    draw_uk_start_hist(15, 10, true, true,  final_l4_color, line_width, line_style)   // 10:10 NY — 1 candle before
    draw_uk_start_hist(15, 30, true, true,  final_l5_color, line_width, line_style)   // 10:30 NY — 1 candle before
````
