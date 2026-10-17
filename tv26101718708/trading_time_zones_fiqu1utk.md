# Trading Time Zones

- url: https://www.tradingview.com/script/FiQU1UtK-Trading-Time-Zones/
- type: indicator
- pine_id: PUB;d2fa04ddf62047b0bc622b02ea860e0a
- version: 4.0

## Description

[b]Trading Time Zones[/b]

Marks the key trading sessions directly on your chart as shaded boxes with high/low lines that extend to the latest candle. Works on any instrument — stocks, indices, futures, crypto, commodities — and on any display timezone.

[b]Sessions included:[/b]

[list]
[*]Asia Early — 9:00 AM to 3:00 PM Tokyo time
[*]Asia Late — 3:00 PM to 7:00 PM Tokyo time
[*]Frankfurt — 9:00 AM to 10:00 AM Frankfurt time
[*]London — 8:00 AM to 11:00 AM London time
[*]NY Early — 7:00 AM to 9:30 AM New York time
[*]NY AM — 9:30 AM to 11:00 AM New York time
[*]NY Lunch — 12:00 PM to 1:00 PM New York time
[*]NY PM — 1:30 PM to 4:00 PM New York time
[/list]

[b]Features:[/b]

Each session can be shown or hidden independently
Per-session color customization
Session box with adjustable transparency
High and low lines that extend to the current candle, so key levels remain visible throughout the day
Labels on the session box and on each high/low line
Keep 1 to 5 past days on the chart
Daylight Saving Time:
Each session is anchored to its own regional timezone — Tokyo for Asian sessions, London for the London session, Berlin for Frankfurt, and New York for all US sessions. This means EU and US clock changes are handled independently and the correct local times are always shown, even during the weeks when one region has changed clocks and the other has not.

[b]How to use:[/b]
Enable only the sessions relevant to the instrument you are trading. For US equities, NY Early, NY AM, and NY PM are the most useful. For forex and indices that trade across regions, enabling London alongside the NY sessions helps identify the overlap, which is typically the highest-volume period of the day. The high and low lines of each session act as natural support and resistance reference points for the rest of the trading day.

[b]CREDITS[/b]
Inspired by "ICT Kill Zones + Pivots" by tradeforopp on TradingView. Session box concept and pivot line approach are adapted from that work. This version uses per-session regional timezones so that Asian, European, and US sessions each observe their own daylight saving rules independently. Additional sessions — Asia Early, Asia Late, Frankfurt, and NY Early — are included, and H/L lines extend continuously to the latest candle rather than stopping at price mitigation.

## Source Code

````pine
//@version=6
indicator("Trading Time Zones", "Time Zones", overlay = true,
     max_boxes_count = 200, max_lines_count = 400, max_labels_count = 400)

// Each session is defined in its own local timezone so that regional DST
// changes are handled independently. US, EU and Asian clocks change on
// different dates — anchoring everything to one timezone causes ±1 hour
// drift during the gap weeks. Per-session timezones eliminate that entirely.

// ── Helpers ───────────────────────────────────────────────────────────────────
line_style_opt(s) =>
    switch s
        "Solid"  => line.style_solid
        "Dotted" => line.style_dotted
        "Dashed" => line.style_dashed

// ── Inputs ────────────────────────────────────────────────────────────────────
var g_AS = "Asia Early  ·  9:00 AM – 3:00 PM  (Tokyo)"
show_as  = input.bool(true,     "Show", inline = "AS", group = g_AS)
as_col   = input.color(#1565c0, "",     inline = "AS", group = g_AS)

var g_AL = "Asia Late  ·  3:00 PM – 7:00 PM  (Tokyo)"
show_al  = input.bool(false,    "Show", inline = "AL", group = g_AL)
al_col   = input.color(#0288d1, "",     inline = "AL", group = g_AL)

var g_FR = "Frankfurt  ·  9:00 AM – 10:00 AM  (Frankfurt)"
show_fr  = input.bool(false,    "Show", inline = "FR", group = g_FR)
fr_col   = input.color(#795548, "",     inline = "FR", group = g_FR)

var g_LO = "London  ·  8:00 AM – 11:00 AM  (London)"
show_lo  = input.bool(true,     "Show", inline = "LO", group = g_LO)
lo_col   = input.color(#6a1b9a, "",     inline = "LO", group = g_LO)

var g_NE = "NY Early  ·  7:00 AM – 9:30 AM  (New York)"
show_ne  = input.bool(true,     "Show", inline = "NE", group = g_NE)
ne_col   = input.color(#558b2f, "",     inline = "NE", group = g_NE)

var g_NA = "NY AM  ·  9:30 AM – 11:00 AM  (New York)"
show_na  = input.bool(true,     "Show", inline = "NA", group = g_NA)
na_col   = input.color(#1b5e20, "",     inline = "NA", group = g_NA)

var g_NL = "NY Lunch  ·  12:00 PM – 1:00 PM  (New York)"
show_nl  = input.bool(false,    "Show", inline = "NL", group = g_NL)
nl_col   = input.color(#e65100, "",     inline = "NL", group = g_NL)

var g_NP = "NY PM  ·  1:30 PM – 4:00 PM  (New York)"
show_np  = input.bool(true,     "Show", inline = "NP", group = g_NP)
np_col   = input.color(#b71c1c, "",     inline = "NP", group = g_NP)

var g_A    = "Appearance"
show_box   = input.bool(true,  "Session Box",                                                                  inline = "BX", group = g_A)
box_transp = input.int(85,     "",              0, 100,                                                        inline = "BX", group = g_A)
show_hl    = input.bool(true,  "H/L Lines",                                                                   inline = "HL", group = g_A)
hl_style   = line_style_opt(input.string("Dashed", "", options = ["Solid", "Dotted", "Dashed"],               inline = "HL", group = g_A))
hl_width   = input.int(1,      "",              1, 3,                                                         inline = "HL", group = g_A)
show_lbl   = input.bool(true,  "Labels",                                                                      group = g_A)
keep       = input.int(1,      "Days to Show",  1, 5, tooltip = "Number of past days to keep on the chart",  group = g_A)

// ── Type ──────────────────────────────────────────────────────────────────────
type KZ
    array<box>   boxes
    array<line>  hi_lines
    array<line>  lo_lines
    array<label> box_labels
    array<label> hi_labels
    array<label> lo_labels
    float        hi = na
    float        lo = na

// ── State ─────────────────────────────────────────────────────────────────────
new_kz() => KZ.new(array.new_box(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_label())

var as_kz = new_kz()
var al_kz = new_kz()
var fr_kz = new_kz()
var lo_kz = new_kz()
var ne_kz = new_kz()
var na_kz = new_kz()
var nl_kz = new_kz()
var np_kz = new_kz()

var T = color.new(color.white, 100)

// ── Core ──────────────────────────────────────────────────────────────────────
manage_kz(KZ kz, bool enabled, string sess, string tz, color col, string name) =>
    if enabled
        in_sess  = not na(time("", sess, tz))
        in_prev  = not na(time("", sess, tz, bars_back = 1))
        starting = in_sess and not in_prev

        // ── Session start: create box, lines, labels ─────────────────────────
        if starting
            kz.hi := high
            kz.lo := low

            if show_box
                kz.boxes.unshift(
                     box.new(bar_index, high, bar_index + 1, low,
                     bgcolor      = color.new(col, box_transp),
                     border_color = color(na),
                     border_width = 0))

            if show_lbl
                kz.box_labels.unshift(
                     label.new(bar_index, high, name,
                     style     = label.style_label_right,
                     color     = color.new(col, 60),
                     textcolor = color.white,
                     size      = size.small))

            if show_hl
                kz.hi_lines.unshift(
                     line.new(bar_index, high, bar_index + 1, high,
                     color = col, style = hl_style, width = hl_width))
                kz.lo_lines.unshift(
                     line.new(bar_index, low, bar_index + 1, low,
                     color = col, style = hl_style, width = hl_width))
                if show_lbl
                    kz.hi_labels.unshift(
                         label.new(bar_index, high, name + " H",
                         style     = label.style_label_left,
                         color     = T,
                         textcolor = col,
                         size      = size.small))
                    kz.lo_labels.unshift(
                         label.new(bar_index, low, name + " L",
                         style     = label.style_label_left,
                         color     = T,
                         textcolor = col,
                         size      = size.small))

            // Prune beyond keep limit
            if show_box and kz.boxes.size() > keep
                kz.boxes.pop().delete()
            if show_lbl and kz.box_labels.size() > keep
                kz.box_labels.pop().delete()
            if show_hl
                if kz.hi_lines.size() > keep
                    kz.hi_lines.pop().delete()
                    kz.lo_lines.pop().delete()
                if show_lbl
                    if kz.hi_labels.size() > keep
                        kz.hi_labels.pop().delete()
                    if kz.lo_labels.size() > keep
                        kz.lo_labels.pop().delete()

        // ── Inside session: grow box and track H/L ───────────────────────────
        if in_sess
            kz.hi := math.max(kz.hi, high)
            kz.lo := math.min(kz.lo, low)

            if show_box and kz.boxes.size() > 0
                b = kz.boxes.get(0)
                b.set_right(bar_index + 1)
                b.set_top(kz.hi)
                b.set_bottom(kz.lo)

            if show_lbl and kz.box_labels.size() > 0
                kz.box_labels.get(0).set_xy(bar_index, kz.hi)

            if show_hl
                if kz.hi_lines.size() > 0
                    kz.hi_lines.get(0).set_y1(kz.hi)
                    kz.hi_lines.get(0).set_y2(kz.hi)
                    kz.hi_lines.get(0).set_x2(bar_index + 1)
                if kz.lo_lines.size() > 0
                    kz.lo_lines.get(0).set_y1(kz.lo)
                    kz.lo_lines.get(0).set_y2(kz.lo)
                    kz.lo_lines.get(0).set_x2(bar_index + 1)
                if show_lbl
                    if kz.hi_labels.size() > 0
                        kz.hi_labels.get(0).set_y(kz.hi)
                    if kz.lo_labels.size() > 0
                        kz.lo_labels.get(0).set_y(kz.lo)

        // ── Every bar outside session: pull all lines to latest candle ────────
        // Guard each loop explicitly — Pine Script executes `for i = 0 to -1`
        // once rather than skipping when the array is empty .
        if not in_sess and show_hl
            if kz.hi_lines.size() > 0
                for i = 0 to kz.hi_lines.size() - 1
                    kz.hi_lines.get(i).set_x2(bar_index)
            if kz.lo_lines.size() > 0
                for i = 0 to kz.lo_lines.size() - 1
                    kz.lo_lines.get(i).set_x2(bar_index)
            if show_lbl
                if kz.hi_labels.size() > 0
                    for i = 0 to kz.hi_labels.size() - 1
                        kz.hi_labels.get(i).set_x(bar_index)
                if kz.lo_labels.size() > 0
                    for i = 0 to kz.lo_labels.size() - 1
                        kz.lo_labels.get(i).set_x(bar_index)

// ── Per-bar execution ─────────────────────────────────────────────────────────
// Sessions are meaningless on daily/weekly/monthly charts — skip entirely.
if timeframe.isintraday
    //                             session string        timezone
    manage_kz(as_kz, show_as, "0900-1500:1234567", "Asia/Tokyo",        as_col, "Asia Early")
    manage_kz(al_kz, show_al, "1500-1900:1234567", "Asia/Tokyo",        al_col, "Asia Late")
    manage_kz(fr_kz, show_fr, "0900-1000:23456",   "Europe/Berlin",     fr_col, "Frankfurt")
    manage_kz(lo_kz, show_lo, "0800-1100:23456",   "Europe/London",     lo_col, "London")
    manage_kz(ne_kz, show_ne, "0700-0930:23456",   "America/New_York",  ne_col, "NY Early")
    manage_kz(na_kz, show_na, "0930-1100:23456",   "America/New_York",  na_col, "NY AM")
    manage_kz(nl_kz, show_nl, "1200-1300:23456",   "America/New_York",  nl_col, "NY Lunch")
    manage_kz(np_kz, show_np, "1330-1600:23456",   "America/New_York",  np_col, "NY PM")
````
