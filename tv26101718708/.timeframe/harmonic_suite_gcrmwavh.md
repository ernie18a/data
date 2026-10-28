# Harmonic Suite

- url: https://www.tradingview.com/script/GCrmWavH-Harmonic-Suite/
- type: indicator
- pine_id: PUB;dec1720546c54b2092a56cba2c14bc5b
- version: 1.0

## Description

Automatically detects the four most reliable harmonic patterns (Gartley, Bat, Butterfly, Crab) on any symbol and timeframe. Uses an alternating 5-point pivot buffer (X→A→B→C→D) with Fibonacci ratio validation at every leg. When a pattern completes at D, it fires a signal and draws the full XABCD structure. While waiting for D, a PRZ box (Potential Reversal Zone) projects forward so you can see the target zone before price arrives.

Patterns detected

Pattern AB/XA CD/BC XD/XA (key)
Gartley ~0.618 1.272–1.618 ~0.786
Bat 0.382–0.500 1.618–2.618 ~0.886
Butterfly ~0.786 1.618–2.618 1.272–1.618
Crab 0.382–0.618 2.618–3.618 ~1.618
BC/AB must be 0.382–0.886 for all patterns. Priority order when ratios overlap: Gartley → Bat → Butterfly → Crab.

Settings

Patterns — toggle each pattern on/off individually
Left/Right bars — pivot sensitivity (5/5 default; lower = more signals, higher = fewer but cleaner)
Ratio tolerance (%) — how much leeway on exact Fibonacci ratios (5% default)
PRZ box — show/hide the projected D zone
XABCD labels — show/hide pivot labels
Zigzag lines — show/hide leg lines
PRZ width (bars) — how far right the PRZ box extends
Bullish / Bearish color — fully customizable
How to use

Add to any chart. Works best on 15m and above.
Watch for the PRZ box to form — price approaching it is your setup window.
Wait for the D label to appear with the pattern name + ↑/↓. That's the confirmed signal.
Set alerts via EV Harmonic Long, EV Harmonic Short, or EV Harmonic Any to get notified without watching the screen.
Use together with EV ABCD Pattern and EV Wyckoff Phases for confluence.
Alerts included

EV Harmonic Long — bullish D confirmed
EV Harmonic Short — bearish D confirmed
EV Harmonic Any — either direction
yesterday
Release Notes
Added a Multi-Timeframe Dashboard and improved default sensitivity so the indicator marks more patterns out of the box.

What's new

MTF Dashboard — a compact table in the top-right corner showing the direction of the last confirmed harmonic pattern across three independent timeframes:


15 1h 4h
Harm. ▼ ▲ –
▲ green — last confirmed pattern was bullish (D ↑)
▼ red — last confirmed pattern was bearish (D ↓)
– gray — no signal in the last N bars (stale or no setup yet)
The gray state is intentional: it prevents you from acting on a direction that happened 200 bars ago.

Improved defaults — swing bars reduced to 2/2 and ratio tolerance raised to 11%, giving significantly more pattern detections across all timeframes and instruments while keeping the Fibonacci structure intact.

New settings (MTF Dashboard group)

TF 1 / TF 2 / TF 3 — choose any three timeframes (default: 15, 60, 240)
Stale after (bars) — how many bars back to consider a signal "fresh" (default: 50)
MTF dashboard toggle — show/hide the table
How to use

Check the dashboard before entering at D. A harmonic signal on your entry timeframe is significantly stronger when the 1h and 4h are aligned in the same direction. Gray cells are a warning — wait for a fresh signal on that TF before adding it as confluence.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © EVLabs —

//@version=6
indicator("Harmonic Suite", overlay=true, max_labels_count=300, max_lines_count=300, max_boxes_count=50)

grp_pat = "── Patterns ──"
show_gartley   = input.bool(true, "Gartley",   group=grp_pat)
show_bat       = input.bool(true, "Bat",        group=grp_pat)
show_butterfly = input.bool(true, "Butterfly",  group=grp_pat)
show_crab      = input.bool(true, "Crab",       group=grp_pat)

grp_sw = "── Swings ──"
sw_left  = input.int(2, "Left bars",  group=grp_sw, minval=1, maxval=20)
sw_right = input.int(2, "Right bars", group=grp_sw, minval=1, maxval=20)

grp_tol = "── Tolerance ──"
err_pct = input.float(11.0, "Ratio tolerance (%)", group=grp_tol, minval=1.0, maxval=20.0, step=0.5)

grp_vis = "── Display ──"
show_prz    = input.bool(true, "PRZ box",        group=grp_vis)
show_labels = input.bool(true, "XABCD labels",   group=grp_vis)
show_lines  = input.bool(true, "Zigzag lines",   group=grp_vis)
show_dash   = input.bool(true, "MTF dashboard",  group=grp_vis)
col_bull    = input.color(color.new(#00c853, 0), "Bullish", group=grp_vis)
col_bear    = input.color(color.new(#ff1744, 0), "Bearish", group=grp_vis)
prz_width   = input.int(15, "PRZ width (bars)",  group=grp_vis, minval=3, maxval=100)

grp_mtf = "── MTF Dashboard ──"
tf_1  = input.timeframe("15",  "TF 1", group=grp_mtf)
tf_2  = input.timeframe("60",  "TF 2", group=grp_mtf)
tf_3  = input.timeframe("240", "TF 3", group=grp_mtf)
stale = input.int(50, "Stale after (bars)", group=grp_mtf, minval=5, maxval=500)

tol = err_pct / 100.0
w(val, tgt) => tgt > 0 and math.abs(val - tgt) / tgt <= tol
r(val, lo, hi) => val >= lo * (1.0 - tol) and val <= hi * (1.0 + tol)

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
var float p5 = na
var int   b5 = na
var bool  h5 = false

var box prz_box = na

new_pivot = false

if not na(ph)
    if na(p1) or not h1
        p5 := p4
        b5 := b4
        h5 := h4
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
        p5 := p4
        b5 := b4
        h5 := h4
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

if new_pivot and not na(p5)
    if not h5 and h4 and not h3 and h2 and not h1
        xa = p4 - p5
        ab = p4 - p3
        bc = p2 - p3
        cd = p2 - p1
        xd = p4 - p1
        if xa > 0 and ab > 0 and bc > 0 and cd > 0 and xd > 0
            ab_xa = ab / xa
            bc_ab = bc / ab
            cd_bc = cd / bc
            xd_xa = xd / xa
            pat = ""
            if r(bc_ab, 0.382, 0.886)
                if      show_gartley   and w(ab_xa, 0.618) and r(cd_bc, 1.272, 1.618) and w(xd_xa, 0.786)
                    pat := "Gartley"
                else if show_bat       and r(ab_xa, 0.382, 0.500) and r(cd_bc, 1.618, 2.618) and w(xd_xa, 0.886)
                    pat := "Bat"
                else if show_butterfly and w(ab_xa, 0.786) and r(cd_bc, 1.618, 2.618) and r(xd_xa, 1.272, 1.618)
                    pat := "Butterfly"
                else if show_crab      and r(ab_xa, 0.382, 0.618) and r(cd_bc, 2.618, 3.618) and w(xd_xa, 1.618)
                    pat := "Crab"
            if pat != ""
                bull_signal := true
                _c  = color.new(col_bull,  0)
                _cf = color.new(col_bull, 40)
                if show_lines
                    line.new(b5, p5, b4, p4, color=_cf, width=1)
                    line.new(b4, p4, b3, p3, color=_cf, width=1)
                    line.new(b3, p3, b2, p2, color=_cf, width=1)
                    line.new(b2, p2, b1, p1, color=_c,  width=2)
                if show_labels
                    label.new(b5, p5, "X",        color=_cf, textcolor=color.white, style=label.style_label_up,   size=size.tiny)
                    label.new(b4, p4, "A",        color=_cf, textcolor=color.white, style=label.style_label_down, size=size.tiny)
                    label.new(b3, p3, "B",        color=_cf, textcolor=color.white, style=label.style_label_up,   size=size.tiny)
                    label.new(b2, p2, "C",        color=_cf, textcolor=color.white, style=label.style_label_down, size=size.tiny)
                    label.new(b1, p1, pat + " ↑", color=_c,  textcolor=color.white, style=label.style_label_up,   size=size.small)
                if not na(prz_box)
                    box.set_right(prz_box, b1)
                    box.set_extend(prz_box, extend.none)
                    prz_box := na

    if h5 and not h4 and h3 and not h2 and h1
        xa = p5 - p4
        ab = p3 - p4
        bc = p3 - p2
        cd = p1 - p2
        xd = p1 - p4
        if xa > 0 and ab > 0 and bc > 0 and cd > 0 and xd > 0
            ab_xa = ab / xa
            bc_ab = bc / ab
            cd_bc = cd / bc
            xd_xa = xd / xa
            pat = ""
            if r(bc_ab, 0.382, 0.886)
                if      show_gartley   and w(ab_xa, 0.618) and r(cd_bc, 1.272, 1.618) and w(xd_xa, 0.786)
                    pat := "Gartley"
                else if show_bat       and r(ab_xa, 0.382, 0.500) and r(cd_bc, 1.618, 2.618) and w(xd_xa, 0.886)
                    pat := "Bat"
                else if show_butterfly and w(ab_xa, 0.786) and r(cd_bc, 1.618, 2.618) and r(xd_xa, 1.272, 1.618)
                    pat := "Butterfly"
                else if show_crab      and r(ab_xa, 0.382, 0.618) and r(cd_bc, 2.618, 3.618) and w(xd_xa, 1.618)
                    pat := "Crab"
            if pat != ""
                bear_signal := true
                _c  = color.new(col_bear,  0)
                _cf = color.new(col_bear, 40)
                if show_lines
                    line.new(b5, p5, b4, p4, color=_cf, width=1)
                    line.new(b4, p4, b3, p3, color=_cf, width=1)
                    line.new(b3, p3, b2, p2, color=_cf, width=1)
                    line.new(b2, p2, b1, p1, color=_c,  width=2)
                if show_labels
                    label.new(b5, p5, "X",        color=_cf, textcolor=color.white, style=label.style_label_down, size=size.tiny)
                    label.new(b4, p4, "A",        color=_cf, textcolor=color.white, style=label.style_label_up,   size=size.tiny)
                    label.new(b3, p3, "B",        color=_cf, textcolor=color.white, style=label.style_label_down, size=size.tiny)
                    label.new(b2, p2, "C",        color=_cf, textcolor=color.white, style=label.style_label_up,   size=size.tiny)
                    label.new(b1, p1, pat + " ↓", color=_c,  textcolor=color.white, style=label.style_label_down, size=size.small)
                if not na(prz_box)
                    box.set_right(prz_box, b1)
                    box.set_extend(prz_box, extend.none)
                    prz_box := na

if show_prz and barstate.islast and not na(p4)
    if not na(prz_box)
        box.delete(prz_box)
        prz_box := na
    if not h4 and h3 and not h2 and h1
        xa = p3 - p4
        ab = p3 - p2
        bc = p1 - p2
        if xa > 0 and ab > 0 and bc > 0 and p1 < p3
            ab_xa = ab / xa
            bc_ab = bc / ab
            if r(bc_ab, 0.382, 0.886)
                d_vals = array.new_float()
                if show_gartley and w(ab_xa, 0.618)
                    array.push(d_vals, p3 - xa * 0.786 * (1.0 + tol))
                    array.push(d_vals, p3 - xa * 0.786 * (1.0 - tol))
                if show_bat and r(ab_xa, 0.382, 0.500)
                    array.push(d_vals, p3 - xa * 0.886 * (1.0 + tol))
                    array.push(d_vals, p3 - xa * 0.886 * (1.0 - tol))
                if show_butterfly and w(ab_xa, 0.786)
                    array.push(d_vals, p3 - xa * 1.272 * (1.0 - tol))
                    array.push(d_vals, p3 - xa * 1.618 * (1.0 + tol))
                if show_crab and r(ab_xa, 0.382, 0.618)
                    array.push(d_vals, p3 - xa * 1.618 * (1.0 - tol))
                    array.push(d_vals, p3 - xa * 1.618 * (1.0 + tol))
                if array.size(d_vals) > 0
                    prz_box := box.new(b1, array.max(d_vals), bar_index + prz_width, array.min(d_vals),
                        border_color=color.new(col_bull, 20),
                        bgcolor=color.new(col_bull, 80),
                        text="D zone ↑", text_color=color.white, text_size=size.small)
    else if h4 and not h3 and h2 and not h1
        xa = p4 - p3
        ab = p2 - p3
        bc = p2 - p1
        if xa > 0 and ab > 0 and bc > 0 and p1 > p3
            ab_xa = ab / xa
            bc_ab = bc / ab
            if r(bc_ab, 0.382, 0.886)
                d_vals = array.new_float()
                if show_gartley and w(ab_xa, 0.618)
                    array.push(d_vals, p3 + xa * 0.786 * (1.0 - tol))
                    array.push(d_vals, p3 + xa * 0.786 * (1.0 + tol))
                if show_bat and r(ab_xa, 0.382, 0.500)
                    array.push(d_vals, p3 + xa * 0.886 * (1.0 - tol))
                    array.push(d_vals, p3 + xa * 0.886 * (1.0 + tol))
                if show_butterfly and w(ab_xa, 0.786)
                    array.push(d_vals, p3 + xa * 1.272 * (1.0 - tol))
                    array.push(d_vals, p3 + xa * 1.618 * (1.0 + tol))
                if show_crab and r(ab_xa, 0.382, 0.618)
                    array.push(d_vals, p3 + xa * 1.618 * (1.0 - tol))
                    array.push(d_vals, p3 + xa * 1.618 * (1.0 + tol))
                if array.size(d_vals) > 0
                    prz_box := box.new(b1, array.max(d_vals), bar_index + prz_width, array.min(d_vals),
                        border_color=color.new(col_bear, 20),
                        bgcolor=color.new(col_bear, 80),
                        text="D zone ↓", text_color=color.white, text_size=size.small)

var int last_dir     = 0
var int last_sig_bar = na

if bull_signal
    last_dir     := 1
    last_sig_bar := bar_index
if bear_signal
    last_dir     := -1
    last_sig_bar := bar_index

is_fresh = not na(last_sig_bar) and (bar_index - last_sig_bar) <= stale

[dir_tf1, fr_tf1] = request.security(syminfo.tickerid, tf_1, [last_dir, is_fresh])
[dir_tf2, fr_tf2] = request.security(syminfo.tickerid, tf_2, [last_dir, is_fresh])
[dir_tf3, fr_tf3] = request.security(syminfo.tickerid, tf_3, [last_dir, is_fresh])

dash_cell_bg(dir, fr) =>
    not fr or dir == 0 ? color.new(#434651, 30) : dir == 1 ? color.new(col_bull, 25) : color.new(col_bear, 25)

dash_cell_txt(dir) =>
    dir == 1 ? "▲" : dir == -1 ? "▼" : "–"

var table dash = na

if show_dash and barstate.islast
    if not na(dash)
        table.delete(dash)
    dash := table.new(position.top_right, 4, 2,
         bgcolor=color.new(#1e222d, 5),
         border_width=1, border_color=color.new(#434651, 40),
         frame_width=1,  frame_color=color.new(#434651, 20))

    _c0 = color.new(#1e222d, 0)
    _ct = color.new(#787b86, 0)
    table.cell(dash, 0, 0, "",      bgcolor=_c0, text_color=_ct,         text_size=size.tiny)
    table.cell(dash, 1, 0, tf_1,    bgcolor=_c0, text_color=_ct,         text_size=size.tiny)
    table.cell(dash, 2, 0, tf_2,    bgcolor=_c0, text_color=_ct,         text_size=size.tiny)
    table.cell(dash, 3, 0, tf_3,    bgcolor=_c0, text_color=_ct,         text_size=size.tiny)
    table.cell(dash, 0, 1, "Harm.", bgcolor=_c0, text_color=color.white, text_size=size.tiny)
    table.cell(dash, 1, 1, dash_cell_txt(dir_tf1), bgcolor=dash_cell_bg(dir_tf1, fr_tf1), text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 1, dash_cell_txt(dir_tf2), bgcolor=dash_cell_bg(dir_tf2, fr_tf2), text_color=color.white, text_size=size.small)
    table.cell(dash, 3, 1, dash_cell_txt(dir_tf3), bgcolor=dash_cell_bg(dir_tf3, fr_tf3), text_color=color.white, text_size=size.small)

plotshape(bull_signal, "Harmonic Long",  shape.triangleup,   location.belowbar, color=color.new(#00e676, 0), size=size.small)
plotshape(bear_signal, "Harmonic Short", shape.triangledown, location.abovebar, color=color.new(#ff1744, 0), size=size.small)

alertcondition(bull_signal,                "EV Harmonic Long",  "EV Harmonic: Bullish pattern at D ↑")
alertcondition(bear_signal,                "EV Harmonic Short", "EV Harmonic: Bearish pattern at D ↓")
alertcondition(bull_signal or bear_signal, "EV Harmonic Any",   "EV Harmonic: Pattern completed")
````
