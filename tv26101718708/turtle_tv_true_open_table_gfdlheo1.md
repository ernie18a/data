# Turtle TV True Open Table

- url: https://www.tradingview.com/script/gfdlheO1-Turtle-TV-True-Open-Table/
- type: indicator
- pine_id: PUB;50f2cecfb37648b386ca8fa2339c221a
- version: 1.0

## Description

📊 True Open [TTV] — Session Level Indicator

Track the most important price levels of the trading day with the True Open TTV indicator. This tool plots five key session open levels directly on your chart and gives you a live status table showing whether price is trading Above, Below, or At each open.

──────────────────────────
🔑 LEVELS TRACKED
──────────────────────────
• TMSO — Tokyo Midnight Session Open
• NYO  — New York Open (09:30 ET)
• TDO  — Today's Daily Open
• TWO  — This Week's Open (Monday)
• TMO  — This Month's Open

──────────────────────────
📋 FEATURES
──────────────────────────
✅ Live status table (Above / Below / At) with color coding
✅ Horizontal level lines with price labels on the chart
✅ Auto-captures session opens from live price action
✅ Manual level override inputs for custom session times
✅ Fully customizable — colors, line style, table position
✅ Works on any instrument: futures, forex, indices, crypto

──────────────────────────
🎨 COLOR LOGIC
──────────────────────────
🔴 Red    → Price is ABOVE the open (bearish bias vs. that level)
🟢 Green  → Price is BELOW the open (bullish bias vs. that level)
🟡 Amber  → Price is AT the open (within 1 point — key decision zone)

──────────────────────────
⚙️ SETTINGS
──────────────────────────
All inputs are adjustable in the settings panel:
• Show/hide table, lines, and labels
• Table position (Top Right / Left / Bottom)
• Line style: Solid, Dashed, or Dotted
• Manual price overrides for each session level
• Custom colors for Above, Below, At, and table background

──────────────────────────
📌 HOW TO USE
──────────────────────────
Session opens are auto-detected using UTC time. If your broker's data feed uses a different session boundary, use the manual override inputs in the settings to pin each level manually.

Best used on intraday timeframes (1m–1H) for NQ, ES, YM, GC, currencies, or any instrument where session opens act as key support/resistance.

──────────────────────────
If you find this useful, please give it a ⭐ and share your feedback in the comments. Suggestions for new session levels or features are welcome!

#futures #NQ #ES #sessionlevels #trueopen #TTV #daytrading #priceaction

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Turtle_tv4

//@version=5
indicator(title="TTV True Open Levels", shorttitle="True Opens By Turtle TV", overlay=true, max_lines_count=10, max_labels_count=50)

// ─── INPUTS ────────────────────────────────────────────────────────────────

grp_style = "Style"
show_table      = input.bool(true,  "Show Status Table",       group=grp_style)
show_lines      = input.bool(true,  "Show Level Lines",        group=grp_style)
show_labels     = input.bool(true,  "Show Labels on Lines",    group=grp_style)
show_price_tag  = input.bool(true,  "Show Price on Labels",    group=grp_style)
table_pos       = input.string("Top Right", "Table Position",  group=grp_style,
                     options=["Top Right","Top Left","Bottom Right","Bottom Left"])
line_width      = input.int(1, "Line Width", minval=1, maxval=4, group=grp_style)
line_style_inp  = input.string("Dashed", "Line Style",         group=grp_style,
                     options=["Solid","Dashed","Dotted"])

grp_col = "Colors"
col_above       = input.color(color.new(#e24b4a, 0),  "Above Color",  group=grp_col)
col_below       = input.color(color.new(#1d9e75, 0),  "Below Color",  group=grp_col)
col_at          = input.color(color.new(#ef9f27, 0),  "At Open Color",group=grp_col)
col_bg_table    = input.color(color.new(#1a1a2e, 85), "Table BG",     group=grp_col)
col_txt         = input.color(color.new(color.white,0),"Table Text",  group=grp_col)

grp_sess = "Session Opens (UTC)"
// Default values approximate real NQ session opens — adjust to your symbol/timezone
tmso_src = input.float(0.0, "TMSO — Tokyo Midnight (override, 0=auto)", group=grp_sess, step=0.25)
nyo_src  = input.float(0.0, "NYO  — New York Open  (override, 0=auto)", group=grp_sess, step=0.25)
tdo_src  = input.float(0.0, "TDO  — Today Open     (override, 0=auto)", group=grp_sess, step=0.25)
two_src  = input.float(0.0, "TWO  — This Week Open (override, 0=auto)", group=grp_sess, step=0.25)
tmo_src  = input.float(0.0, "TMO  — This Month Open(override, 0=auto)", group=grp_sess, step=0.25)

// ─── SESSION DETECTION ─────────────────────────────────────────────────────

// Tokyo Midnight Session Open  — 00:00 UTC
is_tmso = hour(time, "UTC") == 0 and minute(time, "UTC") == 0

// New York Open — 13:30 UTC (09:30 ET)
is_nyo  = hour(time, "UTC") == 13 and minute(time, "UTC") == 30

// Today's Daily Open — first bar of the calendar day (UTC)
is_tdo  = hour(time, "UTC") == 0 and minute(time, "UTC") == 0   // same as TMSO on daily boundary; adjust per broker

// Week Open — Monday 00:00 UTC
is_two  = dayofweek(time, "UTC") == dayofweek.monday and
          hour(time, "UTC") == 0 and minute(time, "UTC") == 0

// Month Open — 1st of month 00:00 UTC
is_tmo  = dayofmonth(time, "UTC") == 1 and
          hour(time, "UTC") == 0 and minute(time, "UTC") == 0

// ─── CAPTURE OPEN PRICES ───────────────────────────────────────────────────

var float tmso_level = na
var float nyo_level  = na
var float tdo_level  = na
var float two_level  = na
var float tmo_level  = na

// Auto-capture from chart (open of that bar) unless user overrides
if is_tmso
    tmso_level := open
if is_nyo
    nyo_level := open
if is_tdo
    tdo_level := open
if is_two
    two_level := open
if is_tmo
    tmo_level := open

// Apply manual overrides if non-zero
tmso_level := tmso_src != 0 ? tmso_src : tmso_level
nyo_level  := nyo_src  != 0 ? nyo_src  : nyo_level
tdo_level  := tdo_src  != 0 ? tdo_src  : tdo_level
two_level  := two_src  != 0 ? two_src  : two_level
tmo_level  := tmo_src  != 0 ? tmo_src  : tmo_level

// ─── HELPERS ───────────────────────────────────────────────────────────────

f_line_style() =>
    line_style_inp == "Dashed" ? line.style_dashed :
     line_style_inp == "Dotted" ? line.style_dotted : line.style_solid

f_status(price, lvl) =>
    if na(lvl)
        "—"
    else if math.abs(price - lvl) <= 1.0
        "At"
    else if price > lvl
        "Above"
    else
        "Below"

f_color(status) =>
    status == "Above" ? col_above :
     status == "Below" ? col_below : col_at

// ─── DRAW LINES ────────────────────────────────────────────────────────────

f_draw_line(lvl, col) =>
    var line ln = na
    if show_lines and not na(lvl) and barstate.islast
        line.delete(ln)
        ln := line.new(bar_index - 300, lvl, bar_index + 30, lvl,
             extend=extend.right, color=col,
             style=f_line_style(), width=line_width)

f_draw_label(lvl, txt, col) =>
    var label lb = na
    if show_labels and not na(lvl) and barstate.islast
        label.delete(lb)
        lb := label.new(bar_index + 5, lvl,
             text=show_price_tag ? txt + "\n" + str.tostring(lvl, "#.##") : txt,
             color=color.new(col, 75),
             textcolor=col, style=label.style_label_left,
             size=size.small)

p  = close
s1 = f_status(p, tmso_level)
s2 = f_status(p, nyo_level)
s3 = f_status(p, tdo_level)
s4 = f_status(p, two_level)
s5 = f_status(p, tmo_level)

f_draw_line(tmso_level, f_color(s1))
f_draw_line(nyo_level,  f_color(s2))
f_draw_line(tdo_level,  f_color(s3))
f_draw_line(two_level,  f_color(s4))
f_draw_line(tmo_level,  f_color(s5))

f_draw_label(tmso_level, "TMSO", f_color(s1))
f_draw_label(nyo_level,  "NYO",  f_color(s2))
f_draw_label(tdo_level,  "TDO",  f_color(s3))
f_draw_label(two_level,  "TWO",  f_color(s4))
f_draw_label(tmo_level,  "TMO",  f_color(s5))

// ─── STATUS TABLE ──────────────────────────────────────────────────────────

var table tbl = na

if show_table and barstate.islast
    table.delete(tbl)

    tpos = table_pos == "Top Right"    ? position.top_right    :
           table_pos == "Top Left"     ? position.top_left     :
           table_pos == "Bottom Right" ? position.bottom_right :
                                         position.bottom_left

    tbl := table.new(tpos, 3, 7,
         bgcolor=col_bg_table,
         border_color=color.new(color.white, 80),
         border_width=1, frame_width=1,
         frame_color=color.new(color.white, 60))

    // Header row
    table.cell(tbl, 0, 0, "True Open [TTV]", text_color=col_txt,
         text_size=size.small, bgcolor=color.new(#2a2a4a, 60))
    table.cell(tbl, 1, 0, "Level",           text_color=col_txt,
         text_size=size.small, bgcolor=color.new(#2a2a4a, 60))
    table.cell(tbl, 2, 0, "Status",          text_color=col_txt,
         text_size=size.small, bgcolor=color.new(#2a2a4a, 60))

    // Data rows
    sessions = array.from("TMSO","NYO","TDO","TWO","TMO")
    levels   = array.from(tmso_level, nyo_level, tdo_level, two_level, tmo_level)
    statuses = array.from(s1, s2, s3, s4, s5)

    for i = 0 to 4
        row    = i + 1
        sess   = array.get(sessions, i)
        lvl    = array.get(levels,   i)
        st     = array.get(statuses, i)
        st_col = f_color(st)
        lv_str = na(lvl) ? "—" : str.tostring(lvl, "#.##")

        table.cell(tbl, 0, row, sess,   text_color=col_txt,  text_size=size.small)
        table.cell(tbl, 1, row, lv_str, text_color=col_txt,  text_size=size.small)
        table.cell(tbl, 2, row, st,     text_color=st_col,   text_size=size.small,
             text_halign=text.align_center)

// ─── BACKGROUND FILL (optional shading above/below nearest level) ──────────
// Uncomment below to shade the space between price and nearest TTU level

// nearest = na
// for lvl in array.from(tmso_level, nyo_level, tdo_level, two_level, tmo_level)
//     if not na(lvl)
//         nearest := na(nearest) ? lvl : math.abs(close - lvl) < math.abs(close - nearest) ? lvl : nearest
// bgcolor(not na(nearest) ? color.new(close > nearest ? col_above : col_below, 95) : na)
````
