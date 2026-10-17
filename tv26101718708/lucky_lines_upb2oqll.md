# Lucky Lines

- url: https://www.tradingview.com/script/uPb2OQll-Lucky-Lines/
- type: indicator
- pine_id: PUB;365ebb357b2741508453f1859a0b2c5d
- version: 1.0

## Description

[b]Lucky Lines[/b]

Mark the moments that matter — before they happen.

Lucky Lines is a clean session and time marker built for traders who structure their day around key time levels. Set up to 4 custom vertical lines at any time of day, in any timezone, and they'll appear automatically on your chart — past sessions and the next upcoming occurrence included.

No more drawing lines manually every morning. Set it once, and Lucky Lines handles the rest.

---

[b]What It Does[/b]

- **4 fully customizable time lines** — each with its own color, style, width, and label
- **Timezone support per line** — set each line in LA, New York, Chicago, or UTC time independently
- **Auto future projection** — always draws the next upcoming line even before the session starts
- **Session history** — shows previous sessions so you can see how price reacted at the same time in the past
- **Fill zones between lines** — shade the time window between any two lines for instant visual context

---

[b]How To Use[/b]

1. Enable each line you need and set the hour and minute
2. Choose the timezone that matches how you read your schedule (e.g. New York for NY session opens)
3. Add a label like **Open**, **London Close**, **News**, or whatever fits your setup
4. Optionally enable fills between lines to highlight key trading windows

---

[b]Perfect For Marking[/b]

- Market opens and closes
- News release times
- Session overlaps (London/NY, Asia/London)
- Your personal trading window
- Pre-market and post-market levels

---

[b]Why I Built This[/b]

Every day I trade around the same key times. I needed a tool that marks those moments automatically — clean, precise, and always looking ahead to the next session. Lucky Lines keeps my chart organized so I can focus on the trade, not the clock.

*Structure your sessions. Trade your plan. Stay lucky.*

— LuckyJo

## Source Code

````pine
//@version=6
indicator("Lucky Lines", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=50)

// ══════════════════════════════════════════════
// LINE 1 — Market Open
// ══════════════════════════════════════════════
G1 = "Line 1 — Market Open"
l1_on   = input.bool(true,  "Show", group=G1, inline="l1a")
l1_col  = input.color(color.new(color.blue, 0), "Color", group=G1, inline="l1a")
l1_hour = input.int(6,  "H", minval=0, maxval=23, group=G1, inline="l1b")
l1_min  = input.int(30, "M", minval=0, maxval=59, group=G1, inline="l1b")
l1_tz   = input.string("America/Los_Angeles", "TZ", options=["America/Los_Angeles","America/New_York","America/Chicago","UTC"], group=G1, inline="l1b")
l1_wid  = input.int(2, "W", minval=1, maxval=4, group=G1, inline="l1c")
l1_sty  = input.string("Solid", "", options=["Solid","Dashed","Dotted"], group=G1, inline="l1c")
l1_lbl  = input.string("Open", "Label", group=G1, inline="l1c")

// ══════════════════════════════════════════════
// LINE 2 — Custom Time
// ══════════════════════════════════════════════
G2 = "Line 2 — Custom Time (Optional)"
l2_on   = input.bool(false, "Show", group=G2, inline="l2a")
l2_col  = input.color(color.new(color.orange, 0), "Color", group=G2, inline="l2a")
l2_hour = input.int(7, "H", minval=0, maxval=23, group=G2, inline="l2b")
l2_min  = input.int(0, "M", minval=0, maxval=59, group=G2, inline="l2b")
l2_tz   = input.string("America/Los_Angeles", "TZ", options=["America/Los_Angeles","America/New_York","America/Chicago","UTC"], group=G2, inline="l2b")
l2_wid  = input.int(2, "W", minval=1, maxval=4, group=G2, inline="l2c")
l2_sty  = input.string("Solid", "", options=["Solid","Dashed","Dotted"], group=G2, inline="l2c")
l2_lbl  = input.string("", "Label", group=G2, inline="l2c")

// ══════════════════════════════════════════════
// LINE 3 — Custom Time
// ══════════════════════════════════════════════
G3 = "Line 3 — Custom Time (Optional)"
l3_on   = input.bool(false, "Show", group=G3, inline="l3a")
l3_col  = input.color(color.new(color.lime, 0), "Color", group=G3, inline="l3a")
l3_hour = input.int(8, "H", minval=0, maxval=23, group=G3, inline="l3b")
l3_min  = input.int(0, "M", minval=0, maxval=59, group=G3, inline="l3b")
l3_tz   = input.string("America/Los_Angeles", "TZ", options=["America/Los_Angeles","America/New_York","America/Chicago","UTC"], group=G3, inline="l3b")
l3_wid  = input.int(2, "W", minval=1, maxval=4, group=G3, inline="l3c")
l3_sty  = input.string("Solid", "", options=["Solid","Dashed","Dotted"], group=G3, inline="l3c")
l3_lbl  = input.string("", "Label", group=G3, inline="l3c")

// ══════════════════════════════════════════════
// LINE 4 — Custom Time
// ══════════════════════════════════════════════
G4 = "Line 4 — Custom Time (Optional)"
l4_on   = input.bool(false, "Show", group=G4, inline="l4a")
l4_col  = input.color(color.new(color.red, 0), "Color", group=G4, inline="l4a")
l4_hour = input.int(9, "H", minval=0, maxval=23, group=G4, inline="l4b")
l4_min  = input.int(0, "M", minval=0, maxval=59, group=G4, inline="l4b")
l4_tz   = input.string("America/Los_Angeles", "TZ", options=["America/Los_Angeles","America/New_York","America/Chicago","UTC"], group=G4, inline="l4b")
l4_wid  = input.int(2, "W", minval=1, maxval=4, group=G4, inline="l4c")
l4_sty  = input.string("Solid", "", options=["Solid","Dashed","Dotted"], group=G4, inline="l4c")
l4_lbl  = input.string("", "Label", group=G4, inline="l4c")

// ══════════════════════════════════════════════
// FILL BETWEEN LINES
// ══════════════════════════════════════════════
GF      = "Fill Between Lines"
f12_on  = input.bool(false, "Fill Line 1 → 2", group=GF, inline="fa")
f12_col = input.color(color.new(color.blue, 85),   "", group=GF, inline="fa")
f23_on  = input.bool(false, "Fill Line 2 → 3", group=GF, inline="fb")
f23_col = input.color(color.new(color.orange, 85), "", group=GF, inline="fb")
f34_on  = input.bool(false, "Fill Line 3 → 4", group=GF, inline="fc")
f34_col = input.color(color.new(color.lime, 85),   "", group=GF, inline="fc")

// ══════════════════════════════════════════════
// DISPLAY / LOOKBACK
// ══════════════════════════════════════════════
GL       = "Display"
lookback = input.int(10, "Show N Previous Sessions", minval=1, maxval=500, group=GL)

// ──────────────────────────────────────────────
// HELPER
// ──────────────────────────────────────────────
f_sty(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

// ──────────────────────────────────────────────
// HIT DETECTION
// ──────────────────────────────────────────────
bar_end = time + timeframe.in_seconds() * 1000

t1 = timestamp(l1_tz, year(time, l1_tz), month(time, l1_tz), dayofmonth(time, l1_tz), l1_hour, l1_min, 0)
hit1 = l1_on and time <= t1 and t1 < bar_end

t2 = timestamp(l2_tz, year(time, l2_tz), month(time, l2_tz), dayofmonth(time, l2_tz), l2_hour, l2_min, 0)
hit2 = l2_on and time <= t2 and t2 < bar_end

t3 = timestamp(l3_tz, year(time, l3_tz), month(time, l3_tz), dayofmonth(time, l3_tz), l3_hour, l3_min, 0)
hit3 = l3_on and time <= t3 and t3 < bar_end

t4 = timestamp(l4_tz, year(time, l4_tz), month(time, l4_tz), dayofmonth(time, l4_tz), l4_hour, l4_min, 0)
hit4 = l4_on and time <= t4 and t4 < bar_end

// ──────────────────────────────────────────────
// ARRAYS
// ──────────────────────────────────────────────
var line[]  arr_l1      = array.new<line>()
var label[] arr_lb1     = array.new<label>()
var line[]  arr_l2      = array.new<line>()
var label[] arr_lb2     = array.new<label>()
var line[]  arr_l3      = array.new<line>()
var label[] arr_lb3     = array.new<label>()
var line[]  arr_l4      = array.new<line>()
var label[] arr_lb4     = array.new<label>()
var int[]   sess_starts   = array.new_int()
var int[]   sess_starts_2 = array.new_int()
var int[]   sess_starts_3 = array.new_int()

// ──────────────────────────────────────────────
// DRAW LINE 1
// ──────────────────────────────────────────────
if hit1
    ln = line.new(bar_index, high, bar_index, low, color=l1_col, width=l1_wid, style=f_sty(l1_sty), extend=extend.both)
    array.push(arr_l1, ln)
    if array.size(arr_l1) > lookback
        line.delete(array.shift(arr_l1))
    if l1_lbl != ""
        lb = label.new(bar_index, high, l1_lbl, color=color.new(l1_col, 75), textcolor=l1_col, style=label.style_label_down, size=size.small)
        array.push(arr_lb1, lb)
        if array.size(arr_lb1) > lookback
            label.delete(array.shift(arr_lb1))
    array.push(sess_starts, bar_index)
    if array.size(sess_starts) > lookback
        array.shift(sess_starts)

// ──────────────────────────────────────────────
// DRAW LINE 2
// ──────────────────────────────────────────────
if hit2
    ln2 = line.new(bar_index, high, bar_index, low, color=l2_col, width=l2_wid, style=f_sty(l2_sty), extend=extend.both)
    array.push(arr_l2, ln2)
    if array.size(arr_l2) > lookback
        line.delete(array.shift(arr_l2))
    if l2_lbl != ""
        lb2 = label.new(bar_index, high, l2_lbl, color=color.new(l2_col, 75), textcolor=l2_col, style=label.style_label_down, size=size.small)
        array.push(arr_lb2, lb2)
        if array.size(arr_lb2) > lookback
            label.delete(array.shift(arr_lb2))
    array.push(sess_starts_2, bar_index)
    if array.size(sess_starts_2) > lookback
        array.shift(sess_starts_2)

// ──────────────────────────────────────────────
// DRAW LINE 3
// ──────────────────────────────────────────────
if hit3
    ln3 = line.new(bar_index, high, bar_index, low, color=l3_col, width=l3_wid, style=f_sty(l3_sty), extend=extend.both)
    array.push(arr_l3, ln3)
    if array.size(arr_l3) > lookback
        line.delete(array.shift(arr_l3))
    if l3_lbl != ""
        lb3 = label.new(bar_index, high, l3_lbl, color=color.new(l3_col, 75), textcolor=l3_col, style=label.style_label_down, size=size.small)
        array.push(arr_lb3, lb3)
        if array.size(arr_lb3) > lookback
            label.delete(array.shift(arr_lb3))
    array.push(sess_starts_3, bar_index)
    if array.size(sess_starts_3) > lookback
        array.shift(sess_starts_3)

// ──────────────────────────────────────────────
// DRAW LINE 4
// ──────────────────────────────────────────────
if hit4
    ln4 = line.new(bar_index, high, bar_index, low, color=l4_col, width=l4_wid, style=f_sty(l4_sty), extend=extend.both)
    array.push(arr_l4, ln4)
    if array.size(arr_l4) > lookback
        line.delete(array.shift(arr_l4))
    if l4_lbl != ""
        lb4 = label.new(bar_index, high, l4_lbl, color=color.new(l4_col, 75), textcolor=l4_col, style=label.style_label_down, size=size.small)
        array.push(arr_lb4, lb4)
        if array.size(arr_lb4) > lookback
            label.delete(array.shift(arr_lb4))

// ──────────────────────────────────────────────
// BACKGROUND FILL
// ──────────────────────────────────────────────
bar_date_y  = year(time, l1_tz)
bar_date_mo = month(time, l1_tz)
bar_date_d  = dayofmonth(time, l1_tz)

// Fill L1 → L2
f12_start = timestamp(l1_tz, bar_date_y, bar_date_mo, bar_date_d, l1_hour, l1_min, 0)
f12_end   = timestamp(l1_tz, bar_date_y, bar_date_mo, bar_date_d, l2_hour, l2_min, 0)
if f12_end <= f12_start
    f12_end := f12_end + 86400000
in_f12 = time < f12_end and bar_end > f12_start
oldest_l1 = array.size(sess_starts) > 0 ? array.get(sess_starts, 0) : -1
bgcolor(f12_on and l1_on and l2_on and in_f12 and bar_index >= oldest_l1 and oldest_l1 >= 0 ? f12_col : na)

// Fill L2 → L3
f23_start = timestamp(l1_tz, bar_date_y, bar_date_mo, bar_date_d, l2_hour, l2_min, 0)
f23_end   = timestamp(l1_tz, bar_date_y, bar_date_mo, bar_date_d, l3_hour, l3_min, 0)
if f23_end <= f23_start
    f23_end := f23_end + 86400000
in_f23 = time < f23_end and bar_end > f23_start
oldest_l2 = array.size(sess_starts_2) > 0 ? array.get(sess_starts_2, 0) : -1
bgcolor(f23_on and l2_on and l3_on and in_f23 and bar_index >= oldest_l2 and oldest_l2 >= 0 ? f23_col : na)

// Fill L3 → L4
f34_start = timestamp(l1_tz, bar_date_y, bar_date_mo, bar_date_d, l3_hour, l3_min, 0)
f34_end   = timestamp(l1_tz, bar_date_y, bar_date_mo, bar_date_d, l4_hour, l4_min, 0)
if f34_end <= f34_start
    f34_end := f34_end + 86400000
in_f34 = time < f34_end and bar_end > f34_start
oldest_l3 = array.size(sess_starts_3) > 0 ? array.get(sess_starts_3, 0) : -1
bgcolor(f34_on and l3_on and l4_on and in_f34 and bar_index >= oldest_l3 and oldest_l3 >= 0 ? f34_col : na)

// ──────────────────────────────────────────────
// FUTURE LINES
// ──────────────────────────────────────────────
next_ts(tz, h, m) =>
    ty = year(timenow,  tz)
    tm = month(timenow, tz)
    td = dayofmonth(timenow, tz)
    candidate = timestamp(tz, ty, tm, td, h, m, 0)
    candidate < timenow ? candidate + 86400000 : candidate

var line  fut_l1     = na
var label fut_lb1    = na
var line  fut_l2     = na
var label fut_lb2    = na
var line  fut_l3     = na
var label fut_lb3    = na
var line  fut_l4     = na
var label fut_lb4    = na
var box   fut_box_12 = na
var box   fut_box_23 = na
var box   fut_box_34 = na

if barstate.islast
    price_range = ta.highest(high, 500) - ta.lowest(low, 500)
    box_top = ta.highest(high, 500) + price_range * 10
    box_bot = ta.lowest(low,  500) - price_range * 10

    if l1_on
        line.delete(fut_l1)
        label.delete(fut_lb1)
        ts1 = next_ts(l1_tz, l1_hour, l1_min)
        fut_l1 := line.new(x1=ts1, y1=high, x2=ts1, y2=low, xloc=xloc.bar_time, color=l1_col, width=l1_wid, style=f_sty(l1_sty), extend=extend.both)
        if l1_lbl != ""
            fut_lb1 := label.new(x=ts1, y=high, text=l1_lbl, xloc=xloc.bar_time, color=color.new(l1_col, 75), textcolor=l1_col, style=label.style_label_down, size=size.small)

    if l2_on
        line.delete(fut_l2)
        label.delete(fut_lb2)
        ts2 = next_ts(l2_tz, l2_hour, l2_min)
        fut_l2 := line.new(x1=ts2, y1=high, x2=ts2, y2=low, xloc=xloc.bar_time, color=l2_col, width=l2_wid, style=f_sty(l2_sty), extend=extend.both)
        if l2_lbl != ""
            fut_lb2 := label.new(x=ts2, y=high, text=l2_lbl, xloc=xloc.bar_time, color=color.new(l2_col, 75), textcolor=l2_col, style=label.style_label_down, size=size.small)

    if l3_on
        line.delete(fut_l3)
        label.delete(fut_lb3)
        ts3 = next_ts(l3_tz, l3_hour, l3_min)
        fut_l3 := line.new(x1=ts3, y1=high, x2=ts3, y2=low, xloc=xloc.bar_time, color=l3_col, width=l3_wid, style=f_sty(l3_sty), extend=extend.both)
        if l3_lbl != ""
            fut_lb3 := label.new(x=ts3, y=high, text=l3_lbl, xloc=xloc.bar_time, color=color.new(l3_col, 75), textcolor=l3_col, style=label.style_label_down, size=size.small)

    if l4_on
        line.delete(fut_l4)
        label.delete(fut_lb4)
        ts4 = next_ts(l4_tz, l4_hour, l4_min)
        fut_l4 := line.new(x1=ts4, y1=high, x2=ts4, y2=low, xloc=xloc.bar_time, color=l4_col, width=l4_wid, style=f_sty(l4_sty), extend=extend.both)
        if l4_lbl != ""
            fut_lb4 := label.new(x=ts4, y=high, text=l4_lbl, xloc=xloc.bar_time, color=color.new(l4_col, 75), textcolor=l4_col, style=label.style_label_down, size=size.small)

    if f12_on and l1_on and l2_on
        box.delete(fut_box_12)
        fts1 = next_ts(l1_tz, l1_hour, l1_min)
        fts2 = timestamp(l1_tz, year(fts1, l1_tz), month(fts1, l1_tz), dayofmonth(fts1, l1_tz), l2_hour, l2_min, 0)
        if fts2 <= fts1
            fts2 := fts2 + 86400000
        fut_box_12 := box.new(left=fts1, top=box_top, right=fts2, bottom=box_bot, xloc=xloc.bar_time, bgcolor=f12_col, border_color=na)

    if f23_on and l2_on and l3_on
        box.delete(fut_box_23)
        fts2 = next_ts(l2_tz, l2_hour, l2_min)
        fts3 = timestamp(l2_tz, year(fts2, l2_tz), month(fts2, l2_tz), dayofmonth(fts2, l2_tz), l3_hour, l3_min, 0)
        if fts3 <= fts2
            fts3 := fts3 + 86400000
        fut_box_23 := box.new(left=fts2, top=box_top, right=fts3, bottom=box_bot, xloc=xloc.bar_time, bgcolor=f23_col, border_color=na)

    if f34_on and l3_on and l4_on
        box.delete(fut_box_34)
        fts3 = next_ts(l3_tz, l3_hour, l3_min)
        fts4 = timestamp(l3_tz, year(fts3, l3_tz), month(fts3, l3_tz), dayofmonth(fts3, l3_tz), l4_hour, l4_min, 0)
        if fts4 <= fts3
            fts4 := fts4 + 86400000
        fut_box_34 := box.new(left=fts3, top=box_top, right=fts4, bottom=box_bot, xloc=xloc.bar_time, bgcolor=f34_col, border_color=na)
````
