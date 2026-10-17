# Bitcoin Cycle Fibonacci Time Projections | Astral Vision 

- url: https://www.tradingview.com/script/dkkGsFsl/
- type: indicator
- pine_id: PUB;26448489280249728a6112a743664a56
- version: 1.0

## Description

[b]Bitcoin Cycle Fibonacci Time Projections | Astral Vision 🌠💠[/b]

This indicator projects key Bitcoin cycle inflection points forward in time by applying Fibonacci ratios to the duration of each historical market cycle, using the time elapsed from cycle low to cycle top as the base measurement unit. The underlying premise is that market cycles do not repeat at fixed calendar intervals but rather at proportional time distances derived from the same mathematical ratios that govern price retracements and extensions, applied to the time axis instead of the price axis.

[b]Calculation ⚙️[/b]

For each cycle, the user defines two anchor dates: the cycle low and the cycle top. The indicator computes the time difference in milliseconds between these two dates, call it D. This duration D becomes the base unit for all subsequent projections.

A set of 22 Fibonacci time ratios is applied to D, each multiplied by D and added to the cycle low date to produce a future timestamp. The ratios used are: 0, 0.236, 0.382, 0.618, 0.786, 1.0, 1.236, 1.382, 1.618, 1.786, 2.0, 2.236, 2.382, 2.618, 2.786, 3.0, 3.236, 3.382, 3.618, 3.786, 4.0, 4.236. Each ratio T_n produces a projected date equal to: cycle low date + (T_n × D).

From this full set of projections, five specific time levels are selected and displayed as the analytically relevant inflection zones, based on historical observation of where Bitcoin cycles have tended to find significant turning points relative to their own low-to-top duration. These are: T7 (ratio 1.618 from the low), marked as a projected secondary low; T11-T12 (ratios 2.382 to 2.618), displayed as a zone representing the projected secondary top; T13-T14 (ratios 2.786 to 3.0), displayed as a zone representing a projected second low; T18 (ratio 3.786), marked as a projected third top; and T20 (ratio 4.236), marked as a projected third low.

Zones between two consecutive ratios are rendered as a highlighted region with dashed boundary lines and a solid centerline, visually representing a window of time rather than a precise date. Single projections are rendered as solid vertical lines.

An optional Gold Zone mode overlays a highlighted box starting from each cycle top and extending forward by a configurable number of days, marking the historically observed period during which gold has tended to outperform Bitcoin following a BTC cycle top, with entry and exit labels at either end of the zone.

The indicator supports three independent cycles simultaneously, each with its own configurable low date, top date, and color. All drawing is executed only on the last bar to avoid per-bar recalculation overhead.

[b]Plots 📊[/b]
[list]
[*]Anchor labels at cycle low and cycle top with date and price information
[*]Solid vertical lines at single Fibonacci time projections (T7, T18, T20)
[*]Highlighted zones with dashed boundary lines and solid centerline at Fibonacci time windows (T11-T12, T13-T14)
[*]Gold Zone highlighted box from cycle top forward by a configurable number of days, with entry and exit labels (Gold Zone mode)
[*]All elements independently togglable per cycle
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]Show Cycle 1, 2, 3: toggle each cycle independently
[*]Low Date and Top Date: anchor dates for each cycle in YYYY-MM-DD format
[*]Cycle Color: independent color per cycle
[*]Show Gold Zones Only: switch to Gold Zone mode, hiding Fibonacci lines and showing only the post-top gold window
[*]Gold Zone Duration: number of days the gold zone box extends from each cycle top
[/list]

[b]Colors 🎨[/b]
Each cycle uses a fully configurable color input. Default colors: aqua for Cycle 1, blue for Cycle 2, purple for Cycle 3.

[b]Purpose 🎯[/b]
Standard Fibonacci tools on TradingView apply ratios to price levels on the vertical axis. This indicator applies the same mathematical framework to the horizontal time axis, treating cycle duration as the measurement unit instead of price range. The result is a set of time projections that are self-referential to each cycle's own internal structure rather than imposed from external calendar periods. Supporting three independent cycles simultaneously allows direct comparison of whether the current cycle is tracking ahead of, behind, or in line with the timing patterns established in previous cycles, which is not possible with single-cycle Fibonacci time tools.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("Bitcoin Cycle Fibonacci Time Projections | Astral Vision 🌠💠", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=200)

string g1 = "Cycle 1"
string g2 = "Cycle 2"
string g3 = "Cycle 3"
string g4 = "Gold Zones"

show_c1    = input.bool(true,  "Show Cycle 1",  group=g1)
c1_low_str = input.string("2015-01-13", "Low Date (YYYY-MM-DD)",  group=g1)
c1_top_str = input.string("2017-12-18", "Top Date (YYYY-MM-DD)",  group=g1)
col_c1     = input.color(color.aqua, "Cycle 1 Color", group=g1)

show_c2    = input.bool(true,  "Show Cycle 2",  group=g2)
c2_low_str = input.string("2018-12-15", "Low Date (YYYY-MM-DD)",  group=g2)
c2_top_str = input.string("2021-11-11", "Top Date (YYYY-MM-DD)",  group=g2)
col_c2     = input.color(color.blue,  "Cycle 2 Color", group=g2)

show_c3    = input.bool(true,  "Show Cycle 3",  group=g3)
c3_low_str = input.string("2022-11-22", "Low Date (YYYY-MM-DD)",  group=g3)
c3_top_str = input.string("2025-10-06", "Top Date (YYYY-MM-DD)",  group=g3)
col_c3     = input.color(color.purple, "Cycle 3 Color", group=g3)

show_gold  = input.bool(false, "Show Gold Zones Only", group=g4)
gold_days  = input.int(120, "Gold Zone Duration (days)", group=g4)

fib_ratios = array.from(
     0.0,  0.236, 0.382, 0.618, 0.786,
     1.0,  1.236, 1.382, 1.618, 1.786,
     2.0,  2.236, 2.382, 2.618, 2.786,
     3.0,  3.236, 3.382, 3.618, 3.786,
     4.0,  4.236)

fib_time(t_start, diff, i) => int(t_start + diff * array.get(fib_ratios, i))

parse_date(s) =>
    parts = str.split(s, "-")
    int y = int(str.tonumber(array.get(parts, 0)))
    int m = int(str.tonumber(array.get(parts, 1)))
    int d = int(str.tonumber(array.get(parts, 2)))
    timestamp(y, m, d, 0, 0)

int c1_low_t = parse_date(c1_low_str)
int c1_top_t = parse_date(c1_top_str)
int c2_low_t = parse_date(c2_low_str)
int c2_top_t = parse_date(c2_top_str)
int c3_low_t = parse_date(c3_low_str)
int c3_top_t = parse_date(c3_top_str)

var float c1_low_p = na
var float c1_top_p = na
var float c2_low_p = na
var float c2_top_p = na
var float c3_low_p = na
var float c3_top_p = na

if time == c1_low_t
    c1_low_p := low
if time == c1_top_t
    c1_top_p := high
if time == c2_low_t
    c2_low_p := low
if time == c2_top_t
    c2_top_p := high
if time == c3_low_t
    c3_low_p := low
if time == c3_top_t
    c3_top_p := high

draw_anchor(t, price, label_txt, col) =>
    label.new(t, price, xloc=xloc.bar_time,
         text      = label_txt,
         color     = color.new(col, 20),
         textcolor = color.white,
         style     = label.style_label_right,
         size      = size.small)

draw_zone(t_a, t_b, col, lbl) =>
    int mid = int((t_a + t_b) / 2)
    line.new(t_a, high * 100, t_a, low * 0.01,
         xloc  = xloc.bar_time,
         color = color.new(col, 40),
         style = line.style_dashed,
         width = 1)
    line.new(t_b, high * 100, t_b, low * 0.01,
         xloc  = xloc.bar_time,
         color = color.new(col, 40),
         style = line.style_dashed,
         width = 1)
    line.new(mid, high * 100, mid, low * 0.01,
         xloc  = xloc.bar_time,
         color = color.new(col, 10),
         style = line.style_solid,
         width = 2)
    label.new(mid, high * 100, xloc=xloc.bar_time,
         text      = lbl,
         color     = color.new(col, 10),
         textcolor = color.white,
         style     = label.style_label_down,
         size      = size.tiny)

draw_vline(t, col, lbl) =>
    line.new(t, high * 100, t, low * 0.01,
         xloc  = xloc.bar_time,
         color = color.new(col, 10),
         style = line.style_solid,
         width = 2)
    label.new(t, high * 100, xloc=xloc.bar_time,
         text      = lbl,
         color     = color.new(col, 10),
         textcolor = color.white,
         style     = label.style_label_down,
         size      = size.tiny)

draw_gold_zone(t_top, p_top, dur_days) =>
    int t_end = t_top + dur_days * 86400000
    box.new(t_top, high * 100, t_end, low * 0.01,
         xloc         = xloc.bar_time,
         bgcolor      = color.new(color.yellow, 78),
         border_color = color.new(color.yellow, 30),
         border_width = 1)
    label.new(t_top, p_top, xloc=xloc.bar_time,
         text      = "BUY GOLD",
         color     = color.new(color.yellow, 20),
         textcolor = color.black,
         style     = label.style_label_right,
         size      = size.small)
    label.new(t_end, p_top, xloc=xloc.bar_time,
         text      = "SELL GOLD",
         color     = color.new(color.yellow, 20),
         textcolor = color.black,
         style     = label.style_label_left,
         size      = size.small)

draw_cycle(show, low_t, top_t, low_p, top_p, col, c_lbl, low_date, top_date, diff) =>
    if show and not na(low_p) and not na(top_p)
        if not show_gold
            draw_anchor(low_t, low_p, c_lbl + " Low\n" + low_date + "\n$" + str.tostring(low_p, "#.00"), col)
            draw_anchor(top_t, top_p, c_lbl + " Top\n" + top_date + "\n$" + str.tostring(top_p, "#.00"), col)
            draw_vline(fib_time(low_t, diff,  7), col, "↓ Low T7 "    + c_lbl)
            draw_zone (fib_time(low_t, diff, 11), fib_time(low_t, diff, 12), col, "↑ Top T11.5 " + c_lbl)
            draw_zone (fib_time(low_t, diff, 13), fib_time(low_t, diff, 14), col, "↓ Low² T13.5 " + c_lbl)
            draw_vline(fib_time(low_t, diff, 18), col, "↑ Top² T18 "  + c_lbl)
            draw_vline(fib_time(low_t, diff, 20), col, "↓ Low³ T20 "  + c_lbl)
        if show_gold
            draw_gold_zone(top_t, top_p, gold_days)

if barstate.islast
    draw_cycle(show_c1, c1_low_t, c1_top_t, c1_low_p, c1_top_p, col_c1, "C1", c1_low_str, c1_top_str, c1_top_t - c1_low_t)
    draw_cycle(show_c2, c2_low_t, c2_top_t, c2_low_p, c2_top_p, col_c2, "C2", c2_low_str, c2_top_str, c2_top_t - c2_low_t)
    draw_cycle(show_c3, c3_low_t, c3_top_t, c3_low_p, c3_top_p, col_c3, "C3", c3_low_str, c3_top_str, c3_top_t - c3_low_t)
````
