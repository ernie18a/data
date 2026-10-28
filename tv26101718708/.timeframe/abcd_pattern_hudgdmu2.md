# ABCD Pattern

- url: https://www.tradingview.com/script/HudGdMu2-ABCD-Pattern/
- type: indicator
- pine_id: PUB;678d7241348a432695c80bcd539b71a3
- version: 2.0

## Description

The ABCD Pattern indicator automatically detects and draws classic harmonic ABCD structures on any instrument and timeframe. The pattern consists of four alternating swing points — A, B, C, D — where the price action forms two consecutive price legs with a retracement between them, validated using Fibonacci ratios.

Pattern Structure

A bullish ABCD begins at a swing high (A), retraces to a swing low (B), rallies to a swing high (C) below A, then drops to a swing low (D) where the reversal is expected. A bearish ABCD mirrors this logic starting from a swing low.

The indicator uses an alternating pivot buffer that enforces strict alternation between highs and lows. When a new pivot is detected that matches the existing direction, it replaces the current pivot rather than creating a new leg — this ensures only clean, well-defined structures are tracked.

Fibonacci Validation

For a pattern to qualify, two conditions must be met simultaneously:

BC/AB retracement: the BC leg must retrace between 50% and 88.6% of the AB leg
CD/BC extension: the CD leg must extend between 113% and 161.8% of the BC leg
Both ranges are fully configurable from the inputs panel. Tightening the ranges produces fewer, higher-quality signals. Widening them detects more patterns with looser Fibonacci alignment.

PRZ — Potential Reversal Zone

Before the D point is confirmed, the indicator projects a D zone box onto the chart in real time. This box is calculated from the current C pivot using the configured Fibonacci extension range, giving the trader a visual target area to watch. The moment D is confirmed by the pivot lookback, the PRZ box closes at the D bar and the full zigzag is drawn.

Visual Output

When a pattern completes, the indicator draws:

Three connecting lines across the A→B→C→D zigzag (A→B and B→C in a lighter shade, C→D in full color)
Labels at each pivot point: A, B, C, and D with a directional arrow (↑ bullish, ↓ bearish)
A triangle signal shape below/above the D bar for quick visual scanning
Bullish patterns are shown in green, bearish in red. Both colors are fully customizable.

MTF Dashboard

A compact table in the top-right corner displays the last ABCD signal direction across three independently configurable timeframes using request.security(). Each cell shows ▲ (last signal was bullish) or ▼ (last signal was bearish), color-coded green or red. Signals older than a configurable number of bars are shown as neutral (grey) to avoid acting on stale context.

Settings

Left/right bars: controls pivot sensitivity (default 5/5)
BC/AB min and max retracement ratios
CD/BC min and max extension ratios
PRZ width in bars
Toggle: PRZ box, labels, zigzag lines, MTF dashboard
Bullish/bearish colors
Three MTF timeframes + stale threshold
No repainting. All signals fire only after the D pivot is fully confirmed by the right-bar lookback. Compatible with any plan — does not require premium features.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  ABCD PATTERN + PROJECTED D ZONE + MTF DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════
//  An ABCD is three confirmed swings and a fourth that has to land inside a
//  Fibonacci window. This script does two things beyond drawing the finished
//  shape:
//
//  1. IT PROJECTS D BEFORE IT EXISTS. Once A, B and C are confirmed, the zone
//     where D must complete is already known — it is CD extended off BC. That
//     zone, not the completed pattern, is the only part you can act on. A
//     pattern drawn after D has printed is a drawing, not a signal.
//
//  2. IT MARKS THE PATTERN WHERE IT HAPPENED. The swing that completes an ABCD
//     is only confirmed `Right bars` later, so a naive plot puts the arrow that
//     many bars past the point it refers to. Everything here is drawn on the
//     bar it belongs to.
//
//  Nothing repaints: every pivot is confirmed before it is used, which is also
//  why the completed pattern arrives late by design.
// ═══════════════════════════════════════════════════════════════════════════

indicator("ABCD Pattern + Projected D Zone", "ABCD+PRZ", overlay=true,
     max_labels_count=200, max_lines_count=200, max_boxes_count=50)

grp_sw  = "── Swings ──"
sw_left  = input.int(5, "Left bars",  group=grp_sw, minval=1, maxval=20)
sw_right = input.int(5, "Right bars", group=grp_sw, minval=1, maxval=20,
     tooltip="A pivot is confirmed this many bars after it forms. That delay is the price of not repainting, and it is why the completed pattern appears late.")

grp_fib = "── Fibonacci ──"
bc_min  = input.float(0.50,  "BC/AB retracement min", group=grp_fib, step=0.01, minval=0.10, maxval=0.99)
bc_max  = input.float(0.886, "BC/AB retracement max", group=grp_fib, step=0.01, minval=0.10, maxval=0.99)
cd_min  = input.float(1.13,  "CD/BC extension min",   group=grp_fib, step=0.01, minval=0.50, maxval=4.0)
cd_max  = input.float(1.618, "CD/BC extension max",   group=grp_fib, step=0.01, minval=0.50, maxval=4.0)

grp_flt = "── Significance filter ──"
min_leg = input.float(1.5, "Minimum AB leg (x ATR)", group=grp_flt, minval=0.0, step=0.1,
     tooltip="An ABCD spanning less than the average candle is geometry, not structure. The Fibonacci windows are wide enough that without a size filter every wiggle qualifies. Raise it until only the swings you would have drawn by hand survive.")

grp_vis = "── Display ──"
show_prz    = input.bool(true, "PRZ — projected D zone", group=grp_vis)
show_labels = input.bool(true, "ABCD labels",            group=grp_vis)
show_lines  = input.bool(true, "Zigzag lines",           group=grp_vis)
show_dash   = input.bool(true, "MTF dashboard",          group=grp_vis)
col_bull    = input.color(color.new(#00c853, 0), "Bullish", group=grp_vis)
col_bear    = input.color(color.new(#ff1744, 0), "Bearish", group=grp_vis)
prz_width   = input.int(15, "PRZ width (bars)", group=grp_vis, minval=3, maxval=100)

grp_mtf = "── MTF Dashboard ──"
tf_1    = input.timeframe("15",  "TF 1", group=grp_mtf)
tf_2    = input.timeframe("60",  "TF 2", group=grp_mtf)
tf_3    = input.timeframe("240", "TF 3", group=grp_mtf)
stale   = input.int(50, "Stale after (bars)", group=grp_mtf, minval=5, maxval=500,
     tooltip="Counted in bars OF THAT TIMEFRAME, so 50 means 50 x 4h on the H4 column, not 50 chart bars. That is usually what you want from a higher-timeframe column, but it is worth knowing before reading the row.")

atr14 = ta.atr(14)

ph = ta.pivothigh(high, sw_left, sw_right)
pl = ta.pivotlow(low,   sw_left, sw_right)
pb = bar_index - sw_right

var float p1 = na
var int   b1 = na
var bool  h1 = false
var float p2 = na
var int   b2 = na
var bool  h2 = false
var float p3 = na
var int   b3 = na
var bool  h3 = false
var float p4 = na
var int   b4 = na
var bool  h4 = false

new_pivot = false

if not na(ph)
    if na(p1) or not h1
        p4 := p3
        b4 := b3
        h4 := h3
        p3 := p2
        b3 := b2
        h3 := h2
        p2 := p1
        b2 := b1
        h2 := h1
        p1 := ph
        b1 := pb
        h1 := true
        new_pivot := true
    else if ph > p1
        p1 := ph
        b1 := pb

if not na(pl)
    if na(p1) or h1
        p4 := p3
        b4 := b3
        h4 := h3
        p3 := p2
        b3 := b2
        h3 := h2
        p2 := p1
        b2 := b1
        h2 := h1
        p1 := pl
        b1 := pb
        h1 := false
        new_pivot := true
    else if pl < p1
        p1 := pl
        b1 := pb

bull_signal = false
bear_signal = false

if new_pivot and not na(p4)
    if h4 and not h3 and h2 and not h1
        ab = p4 - p3
        bc = p2 - p3
        cd = p2 - p1
        // ab is the reference leg, so it is the one the size filter judges
        if ab >= min_leg * atr14 and ab > 0 and bc > 0 and cd > 0 and p2 < p4
            bc_r = bc / ab
            cd_r = cd / bc
            if bc_r >= bc_min and bc_r <= bc_max and cd_r >= cd_min and cd_r <= cd_max
                bull_signal := true
                _c  = color.new(col_bull,  0)
                _cf = color.new(col_bull, 35)
                if show_lines
                    line.new(b4, p4, b3, p3, color=_cf, width=1)
                    line.new(b3, p3, b2, p2, color=_cf, width=1)
                    line.new(b2, p2, b1, p1, color=_c,  width=2)
                if show_labels
                    label.new(b4, p4, "A",   color=_cf, textcolor=color.white, style=label.style_label_down, size=size.small)
                    label.new(b3, p3, "B",   color=_cf, textcolor=color.white, style=label.style_label_up,   size=size.small)
                    label.new(b2, p2, "C",   color=_cf, textcolor=color.white, style=label.style_label_down, size=size.small)
                    label.new(b1, p1, "D ↑", color=_c,  textcolor=color.white, style=label.style_label_up,   size=size.normal)

    if not h4 and h3 and not h2 and h1
        ab = p3 - p4
        bc = p3 - p2
        cd = p1 - p2
        if ab >= min_leg * atr14 and ab > 0 and bc > 0 and cd > 0 and p2 > p4
            bc_r = bc / ab
            cd_r = cd / bc
            if bc_r >= bc_min and bc_r <= bc_max and cd_r >= cd_min and cd_r <= cd_max
                bear_signal := true
                _c  = color.new(col_bear,  0)
                _cf = color.new(col_bear, 35)
                if show_lines
                    line.new(b4, p4, b3, p3, color=_cf, width=1)
                    line.new(b3, p3, b2, p2, color=_cf, width=1)
                    line.new(b2, p2, b1, p1, color=_c,  width=2)
                if show_labels
                    label.new(b4, p4, "A",   color=_cf, textcolor=color.white, style=label.style_label_up,   size=size.small)
                    label.new(b3, p3, "B",   color=_cf, textcolor=color.white, style=label.style_label_down, size=size.small)
                    label.new(b2, p2, "C",   color=_cf, textcolor=color.white, style=label.style_label_up,   size=size.small)
                    label.new(b1, p1, "D ↓", color=_c,  textcolor=color.white, style=label.style_label_down, size=size.normal)

// ── PROJECTED D ZONE ──────────────────────────────────────────────────────
// Built from the last THREE confirmed pivots, so it exists before D does.
// Created once and moved thereafter: the old version deleted and rebuilt the
// box on every realtime tick.
var box   prz_box  = na
var float prz_hi   = na
var float prz_lo   = na
var int   prz_dir  = 0

if show_prz and barstate.islast and not na(p3)
    prz_dir := 0
    if h3 and not h2 and h1
        ab = p3 - p2
        bc = p1 - p2
        if ab >= min_leg * atr14 and ab > 0 and bc > 0 and p1 < p3
            bc_r = bc / ab
            if bc_r >= bc_min and bc_r <= bc_max
                prz_hi  := p1 - bc * cd_min
                prz_lo  := p1 - bc * cd_max
                prz_dir := 1
    else if not h3 and h2 and not h1
        ab = p2 - p3
        bc = p2 - p1
        if ab >= min_leg * atr14 and ab > 0 and bc > 0 and p1 > p3
            bc_r = bc / ab
            if bc_r >= bc_min and bc_r <= bc_max
                prz_lo  := p1 + bc * cd_min
                prz_hi  := p1 + bc * cd_max
                prz_dir := -1

    if prz_dir == 0
        box.delete(prz_box)
        prz_box := na
    else
        color pc = prz_dir == 1 ? col_bull : col_bear
        if na(prz_box)
            prz_box := box.new(b1, prz_hi, bar_index + prz_width, prz_lo,
                 border_color = color.new(pc, 20), bgcolor = color.new(pc, 80),
                 text = prz_dir == 1 ? "D zone ↑" : "D zone ↓",
                 text_color = color.white, text_size = size.small)
        else
            box.set_lefttop(prz_box, b1, prz_hi)
            box.set_rightbottom(prz_box, bar_index + prz_width, prz_lo)
            box.set_border_color(prz_box, color.new(pc, 20))
            box.set_bgcolor(prz_box, color.new(pc, 80))
            box.set_text(prz_box, prz_dir == 1 ? "D zone ↑" : "D zone ↓")

// ── MTF DASHBOARD ─────────────────────────────────────────────────────────
var int last_dir     = 0
var int last_sig_bar = na

if bull_signal
    last_dir     := 1
    last_sig_bar := bar_index
if bear_signal
    last_dir     := -1
    last_sig_bar := bar_index

is_fresh = not na(last_sig_bar) and (bar_index - last_sig_bar) <= stale

[dir_tf1, fr_tf1] = request.security(syminfo.tickerid, tf_1, [last_dir, is_fresh], lookahead = barmerge.lookahead_off)
[dir_tf2, fr_tf2] = request.security(syminfo.tickerid, tf_2, [last_dir, is_fresh], lookahead = barmerge.lookahead_off)
[dir_tf3, fr_tf3] = request.security(syminfo.tickerid, tf_3, [last_dir, is_fresh], lookahead = barmerge.lookahead_off)

dash_cell_bg(dir, fr) =>
    not fr or dir == 0 ? color.new(#434651, 30) : dir == 1 ? color.new(col_bull, 25) : color.new(col_bear, 25)

dash_cell_txt(dir, fr) =>
    not fr or dir == 0 ? "–" : dir == 1 ? "▲" : "▼"

// Built once, cells updated. Rebuilding a nine-cell table on every tick to
// refresh three arrows is work nobody sees and everybody pays for.
var table dash = na

if show_dash and barstate.islast
    if na(dash)
        dash := table.new(position.top_right, 4, 2,
             bgcolor=color.new(#1e222d, 5),
             border_width=1, border_color=color.new(#434651, 40),
             frame_width=1,  frame_color=color.new(#434651, 20))
        c0 = color.new(#1e222d, 0)
        ct = color.new(#787b86, 0)
        table.cell(dash, 0, 0, "",     bgcolor=c0, text_color=ct,          text_size=size.tiny)
        table.cell(dash, 1, 0, tf_1,   bgcolor=c0, text_color=ct,          text_size=size.tiny)
        table.cell(dash, 2, 0, tf_2,   bgcolor=c0, text_color=ct,          text_size=size.tiny)
        table.cell(dash, 3, 0, tf_3,   bgcolor=c0, text_color=ct,          text_size=size.tiny)
        table.cell(dash, 0, 1, "ABCD", bgcolor=c0, text_color=color.white, text_size=size.tiny)

    table.cell(dash, 1, 1, dash_cell_txt(dir_tf1, fr_tf1), bgcolor=dash_cell_bg(dir_tf1, fr_tf1), text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 1, dash_cell_txt(dir_tf2, fr_tf2), bgcolor=dash_cell_bg(dir_tf2, fr_tf2), text_color=color.white, text_size=size.small)
    table.cell(dash, 3, 1, dash_cell_txt(dir_tf3, fr_tf3), bgcolor=dash_cell_bg(dir_tf3, fr_tf3), text_color=color.white, text_size=size.small)

// ── Markers ───────────────────────────────────────────────────────────────
// offset = -sw_right puts the arrow ON the D pivot. Without it the shape lands
// on the CONFIRMATION bar, several bars to the right of the D label it refers
// to — the pattern says one thing and the arrow points somewhere else.
plotshape(bull_signal, "ABCD Long",  shape.triangleup,   location.belowbar,
     color=color.new(#00e676, 0), size=size.small, offset=-sw_right)
plotshape(bear_signal, "ABCD Short", shape.triangledown, location.abovebar,
     color=color.new(#ff1744, 0), size=size.small, offset=-sw_right)

alertcondition(bull_signal,                "ABCD Long",  "ABCD: bullish pattern completed at D")
alertcondition(bear_signal,                "ABCD Short", "ABCD: bearish pattern completed at D")
alertcondition(bull_signal or bear_signal, "ABCD Any",   "ABCD: pattern completed")
````
