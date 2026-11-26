# Daily/Weekly/Monthly Levels

- url: https://www.tradingview.com/script/USoLaRhp-Daily-Weekly-Monthly-Levels/
- type: indicator
- pine_id: PUB;27143d5e5ce84837b0033666f07dec97
- version: 1.0

## Description

## Daily/Weekly/Monthly Levels

Automatically draws horizontal levels where consecutive opposite candles meet on Daily, Weekly, and Monthly timeframes.

When a bullish candle is followed by a bearish candle (or vice versa), a level is plotted at their shared close/open — the exact price where momentum reversed.

### Features
- **Multi-timeframe**: Independent levels from Daily, Weekly, and Monthly candles
- **Remove on touch**: Levels automatically disappear once price revisits them
- **Merge nearby levels**: Clusters levels within a configurable % threshold into a single label, defaulting to the higher timeframe's color and line
- **Customizable**: Per-timeframe color, line style, width, and max level count
- **Clean labels**: Fixed-position labels at the chart's right edge that don't shift when zooming

### How it works
The indicator tracks consecutive candles on each higher timeframe. When two adjacent candles have opposite bodies (one bullish, one bearish), the close of the first candle — which equals the open of the second — marks a level where buyers and sellers exchanged control.

### Settings
| Setting | Default | Description |
|---|---|---|
| Label offset | 150 bars | Push labels past the right edge |
| Show Price | On | Include price in label text |
| Remove Touched | On | Remove levels once price crosses them |
| Merge Levels | On | Combine nearby levels into one label |
| Merge Threshold | 1% | Max distance for merging |
| Max Levels | 10 per TF | How many levels to keep per timeframe |

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ParagonIndicators

//@version=6
indicator("Daily/Weekly/Monthly Levels", shorttitle="DWM Levels", overlay=true, max_lines_count=500, max_labels_count=500)

// ─── Settings ────────────────────────────────────────────────────────────────
grpG        = "Settings"
lbl_offset  = input.int(150, "Label offset (bars)", group=grpG, minval=0, maxval=500,
              tooltip="Extra bars to push labels past the right edge. Use different values per indicator to avoid overlap.")
show_price  = input.bool(true, "Show Price", group=grpG)
remove_touched = input.bool(true, "Remove Touched Levels", group=grpG,
                 tooltip="When price touches a level, remove it from the chart")
merge_levels = input.bool(true, "Merge Levels", group=grpG)
merge_pct    = input.float(1.0, "Merge Threshold (%)", group=grpG, minval=0.01, maxval=5.0, step=0.01,
               tooltip="Levels within this % of each other are merged into one line with combined labels")

// ─── Daily ───────────────────────────────────────────────────────────────────
grpD         = "Daily Levels"
show_d       = input.bool(true, "Show Daily", group=grpD)
max_d        = input.int(10, "Max Daily Levels", minval=1, maxval=30, group=grpD)
col_d        = input.color(color.blue, "Color", group=grpD)
style_d_in   = input.string("Solid", "Style", ["Solid", "Dashed", "Dotted"], group=grpD)
width_d      = input.int(1, "Width", minval=1, maxval=4, group=grpD)

// ─── Weekly ──────────────────────────────────────────────────────────────────
grpW         = "Weekly Levels"
show_w       = input.bool(true, "Show Weekly", group=grpW)
max_w        = input.int(10, "Max Weekly Levels", minval=1, maxval=30, group=grpW)
col_w        = input.color(color.orange, "Color", group=grpW)
style_w_in   = input.string("Solid", "Style", ["Solid", "Dashed", "Dotted"], group=grpW)
width_w      = input.int(1, "Width", minval=1, maxval=4, group=grpW)

// ─── Monthly ─────────────────────────────────────────────────────────────────
grpM         = "Monthly Levels"
show_m       = input.bool(true, "Show Monthly", group=grpM)
max_m        = input.int(10, "Max Monthly Levels", minval=1, maxval=30, group=grpM)
col_m        = input.color(color.purple, "Color", group=grpM)
style_m_in   = input.string("Solid", "Style", ["Solid", "Dashed", "Dotted"], group=grpM)
width_m      = input.int(1, "Width", minval=1, maxval=4, group=grpM)

f_line_style(_s) =>
    _s == "Dashed" ? line.style_dashed : _s == "Dotted" ? line.style_dotted : line.style_solid

// ─── HTF Boundary Detection ─────────────────────────────────────────────────
htf_d_time = show_d ? request.security(syminfo.tickerid, "D", time, lookahead=barmerge.lookahead_on) : na
htf_w_time = show_w ? request.security(syminfo.tickerid, "W", time, lookahead=barmerge.lookahead_on) : na
htf_m_time = show_m ? request.security(syminfo.tickerid, "M", time, lookahead=barmerge.lookahead_on) : na

// ─── Level Storage ───────────────────────────────────────────────────────────
var float[] d_prices  = array.new_float(0)
var int[]   d_draws   = array.new_int(0)
var int[]   d_touches = array.new_int(0)
var line[]  d_lines   = array.new_line(0)
var label[] d_labels  = array.new_label(0)

var float[] w_prices  = array.new_float(0)
var int[]   w_draws   = array.new_int(0)
var int[]   w_touches = array.new_int(0)
var line[]  w_lines   = array.new_line(0)
var label[] w_labels  = array.new_label(0)

var float[] m_prices  = array.new_float(0)
var int[]   m_draws   = array.new_int(0)
var int[]   m_touches = array.new_int(0)
var line[]  m_lines   = array.new_line(0)
var label[] m_labels  = array.new_label(0)

// ─── Helpers ─────────────────────────────────────────────────────────────────
f_add_level(_prices, _draws, _touches, _lines, _labels, _price, _draw_bar, _touch_after, _col, _style, _width, _max, _prefix) =>
    _txt = show_price ? _prefix + "  " + str.tostring(_price, format.mintick) : _prefix
    _l = line.new(_draw_bar, _price, bar_index, _price, color=_col, style=_style, width=_width, extend=extend.right)
    _b = label.new(bar_index + lbl_offset, _price, _txt, textcolor=_col,
         style=label.style_none, size=size.small, color=chart.bg_color)
    array.unshift(_prices, _price)
    array.unshift(_draws, _draw_bar)
    array.unshift(_touches, _touch_after)
    array.unshift(_lines, _l)
    array.unshift(_labels, _b)
    while array.size(_prices) > _max
        array.pop(_prices)
        array.pop(_draws)
        array.pop(_touches)
        line.delete(array.pop(_lines))
        label.delete(array.pop(_labels))

// ─── Daily Candle Tracking ──────────────────────────────────────────────────
// c2 = older completed candle, c1 = newer completed candle, cur = forming
var float  d_c2_open  = na,  var float  d_c2_close = na
var float  d_c1_open  = na,  var float  d_c1_close = na
var int    d_c1_bar   = na
var float  d_cur_open = na,  var float  d_cur_close = na
var int    d_cur_bar  = na
var int    d_prev_htf = na

if show_d and not na(htf_d_time)
    if na(d_prev_htf) or htf_d_time != d_prev_htf
        d_c2_open  := d_c1_open
        d_c2_close := d_c1_close
        d_c1_open  := d_cur_open
        d_c1_close := d_cur_close
        d_c1_bar   := d_cur_bar
        d_cur_open := open
        d_cur_close := close
        d_cur_bar  := bar_index
        d_prev_htf := htf_d_time

        if not na(d_c2_close) and not na(d_c1_close)
            bull_1 = d_c2_close > d_c2_open
            bear_1 = d_c2_close < d_c2_open
            bull_2 = d_c1_close > d_c1_open
            bear_2 = d_c1_close < d_c1_open
            if (bull_1 and bear_2) or (bear_1 and bull_2)
                f_add_level(d_prices, d_draws, d_touches, d_lines, d_labels, d_c2_close, d_c1_bar, time, col_d, f_line_style(style_d_in), width_d, max_d, "daily level")
    else
        d_cur_close := close

// ─── Weekly Candle Tracking ─────────────────────────────────────────────────
var float  w_c2_open  = na,  var float  w_c2_close = na
var float  w_c1_open  = na,  var float  w_c1_close = na
var int    w_c1_bar   = na
var float  w_cur_open = na,  var float  w_cur_close = na
var int    w_cur_bar  = na
var int    w_prev_htf = na

if show_w and not na(htf_w_time)
    if na(w_prev_htf) or htf_w_time != w_prev_htf
        w_c2_open  := w_c1_open
        w_c2_close := w_c1_close
        w_c1_open  := w_cur_open
        w_c1_close := w_cur_close
        w_c1_bar   := w_cur_bar
        w_cur_open := open
        w_cur_close := close
        w_cur_bar  := bar_index
        w_prev_htf := htf_w_time

        if not na(w_c2_close) and not na(w_c1_close)
            bull_1 = w_c2_close > w_c2_open
            bear_1 = w_c2_close < w_c2_open
            bull_2 = w_c1_close > w_c1_open
            bear_2 = w_c1_close < w_c1_open
            if (bull_1 and bear_2) or (bear_1 and bull_2)
                f_add_level(w_prices, w_draws, w_touches, w_lines, w_labels, w_c2_close, w_c1_bar, time, col_w, f_line_style(style_w_in), width_w, max_w, "weekly level")
    else
        w_cur_close := close

// ─── Monthly Candle Tracking ────────────────────────────────────────────────
var float  m_c2_open  = na,  var float  m_c2_close = na
var float  m_c1_open  = na,  var float  m_c1_close = na
var int    m_c1_bar   = na
var float  m_cur_open = na,  var float  m_cur_close = na
var int    m_cur_bar  = na
var int    m_prev_htf = na

if show_m and not na(htf_m_time)
    if na(m_prev_htf) or htf_m_time != m_prev_htf
        m_c2_open  := m_c1_open
        m_c2_close := m_c1_close
        m_c1_open  := m_cur_open
        m_c1_close := m_cur_close
        m_c1_bar   := m_cur_bar
        m_cur_open := open
        m_cur_close := close
        m_cur_bar  := bar_index
        m_prev_htf := htf_m_time

        if not na(m_c2_close) and not na(m_c1_close)
            bull_1 = m_c2_close > m_c2_open
            bear_1 = m_c2_close < m_c2_open
            bull_2 = m_c1_close > m_c1_open
            bear_2 = m_c1_close < m_c1_open
            if (bull_1 and bear_2) or (bear_1 and bull_2)
                f_add_level(m_prices, m_draws, m_touches, m_lines, m_labels, m_c2_close, m_c1_bar, time, col_m, f_line_style(style_m_in), width_m, max_m, "monthly level")
    else
        m_cur_close := close

// ─── Remove touched levels ──────────────────────────────────────────────────
f_remove_touched(_prices, _draws, _touches, _lines, _labels) =>
    if array.size(_prices) > 0
        for i = array.size(_prices) - 1 to 0
            lvl = array.get(_prices, i)
            t_after = array.get(_touches, i)
            if time >= t_after and low <= lvl and high >= lvl
                array.remove(_prices, i)
                array.remove(_draws, i)
                array.remove(_touches, i)
                line.delete(array.remove(_lines, i))
                label.delete(array.remove(_labels, i))

if remove_touched
    if show_d
        f_remove_touched(d_prices, d_draws, d_touches, d_lines, d_labels)
    if show_w
        f_remove_touched(w_prices, w_draws, w_touches, w_lines, w_labels)
    if show_m
        f_remove_touched(m_prices, m_draws, m_touches, m_lines, m_labels)

// ─── Float endpoints every bar ──────────────────────────────────────────────
f_float_endpoints(_prices, _labels) =>
    _rt = last_bar_index + lbl_offset
    if array.size(_prices) > 0
        for i = 0 to array.size(_prices) - 1
            label.set_x(array.get(_labels, i), _rt)

// Rebuild original label text
f_make_txt(_prefix, _price) =>
    show_price ? _prefix + "  " + str.tostring(_price, format.mintick) : _prefix

// Restore original label text and line colors before merging
f_restore_labels(_prices, _labels, _prefix) =>
    if array.size(_prices) > 0
        for i = 0 to array.size(_prices) - 1
            label.set_text(array.get(_labels, i), f_make_txt(_prefix, array.get(_prices, i)))

f_restore_lines(_lines, _col) =>
    if array.size(_lines) > 0
        for i = 0 to array.size(_lines) - 1
            line.set_color(array.get(_lines, i), _col)

if show_d
    f_restore_labels(d_prices, d_labels, "daily level")
    f_restore_lines(d_lines, col_d)
if show_w
    f_restore_labels(w_prices, w_labels, "weekly level")
    f_restore_lines(w_lines, col_w)
if show_m
    f_restore_labels(m_prices, m_labels, "monthly level")
    f_restore_lines(m_lines, col_m)

if show_d
    f_float_endpoints(d_prices, d_labels)
if show_w
    f_float_endpoints(w_prices, w_labels)
if show_m
    f_float_endpoints(m_prices, m_labels)

// ─── Merge nearby levels ────────────────────────────────────────────────────
f_get_lbl(_src, _idx) =>
    _src == 0 ? array.get(d_labels, _idx) : _src == 1 ? array.get(w_labels, _idx) : array.get(m_labels, _idx)

f_get_ln(_src, _idx) =>
    _src == 0 ? array.get(d_lines, _idx) : _src == 1 ? array.get(w_lines, _idx) : array.get(m_lines, _idx)

f_get_col(_src) =>
    _src == 0 ? col_d : _src == 1 ? col_w : col_m

if merge_levels
    var float[] all_prices = array.new_float(0)
    var int[]   all_src    = array.new_int(0)
    var int[]   all_idx    = array.new_int(0)
    array.clear(all_prices)
    array.clear(all_src)
    array.clear(all_idx)

    if show_d and array.size(d_prices) > 0
        for i = 0 to array.size(d_prices) - 1
            array.push(all_prices, array.get(d_prices, i))
            array.push(all_src, 0)
            array.push(all_idx, i)
    if show_w and array.size(w_prices) > 0
        for i = 0 to array.size(w_prices) - 1
            array.push(all_prices, array.get(w_prices, i))
            array.push(all_src, 1)
            array.push(all_idx, i)
    if show_m and array.size(m_prices) > 0
        for i = 0 to array.size(m_prices) - 1
            array.push(all_prices, array.get(m_prices, i))
            array.push(all_src, 2)
            array.push(all_idx, i)

    n = array.size(all_prices)
    if n > 1
        threshold = close * merge_pct / 100.0
        var bool[] merged = array.new_bool(0)
        array.clear(merged)
        for _k = 0 to n - 1
            array.push(merged, false)

        for i = 0 to n - 2
            if not array.get(merged, i)
                // find all neighbors and pick highest timeframe as winner
                var int[] cluster = array.new_int(0)
                array.clear(cluster)
                array.push(cluster, i)
                best_src = array.get(all_src, i)
                best_k   = i
                for j = i + 1 to n - 1
                    if not array.get(merged, j)
                        if math.abs(array.get(all_prices, i) - array.get(all_prices, j)) <= threshold
                            array.push(cluster, j)
                            if array.get(all_src, j) > best_src
                                best_src := array.get(all_src, j)
                                best_k   := j

                if array.size(cluster) > 1
                    // build combined text from all cluster members, winner first
                    lbl_win = f_get_lbl(array.get(all_src, best_k), array.get(all_idx, best_k))
                    win_col = f_get_col(best_src)
                    combined_txt = label.get_text(lbl_win)
                    for ci = 0 to array.size(cluster) - 1
                        k = array.get(cluster, ci)
                        if k != best_k
                            array.set(merged, k, true)
                            lbl_k = f_get_lbl(array.get(all_src, k), array.get(all_idx, k))
                            ln_k  = f_get_ln(array.get(all_src, k), array.get(all_idx, k))
                            combined_txt += " / " + label.get_text(lbl_k)
                            label.set_text(lbl_k, "")
                            line.set_color(ln_k, color.new(color.black, 100))
                    label.set_text(lbl_win, combined_txt)
                    label.set_textcolor(lbl_win, win_col)
````
