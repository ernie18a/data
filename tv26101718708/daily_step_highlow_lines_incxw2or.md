# Daily Step High/Low Lines

- url: https://www.tradingview.com/script/iNcXW2Or-Daily-Step-High-Low-Lines/
- type: indicator
- pine_id: PUB;581dab5a7e0d4b87a502b6a13b4e4662
- version: 1.0

## Description

Daily Step High/Low Lines
This indicator traces the intraday movement of highs and lows as a staircase-style step line, resetting cleanly at the start of each new trading day. Rather than connecting prices with a diagonal trendline, it plots each bar's high and low as a horizontal hold followed by a vertical jump — making it easy to visually read whether price is making stepped advances or retreats throughout the session.
Each step is colour-coded in real time:

🟢 Green — price stepped up from the previous bar
🔴 Red — price stepped down from the previous bar
⚪ Gray — no change

Source options let you choose what defines the high and low of each bar:

Wicks — uses the full candle high/low (solid lines)
Body — uses the open/close extremes only (dashed lines)
Both — plots all four simultaneously, giving a complete picture of both wick and body structure

Green Lows & Red Highs filter is an optional mode that cuts through the noise and shows only the most meaningful steps — lower highs (red) and higher lows (green). This is particularly useful for spotting intraday compression, price coiling, or the early formation of a tightening range before a breakout.
Fully customisable line widths and colours. Works on any intraday timeframe.

## Source Code

````pine
//@version=5
indicator("Daily Step High/Low Lines", overlay=true, max_lines_count=500)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grp_src  = "Source"
src_type = input.string("Wicks", "Price Source",
             options=["Body", "Wicks", "Both"], group=grp_src,
             tooltip="Body = open/close extremes (dashed) | Wicks = high/low (solid) | Both = all four")

grp_sty  = "Style"
lw_wick  = input.int   (2, "Wick Line Width", minval=1, maxval=5, group=grp_sty)
lw_body  = input.int   (2, "Body Line Width", minval=1, maxval=5, group=grp_sty)
col_up   = input.color (color.new(color.green, 0), "Step Up",   group=grp_sty)
col_dn   = input.color (color.new(color.red,   0), "Step Down", group=grp_sty)
col_flat = input.color (color.new(color.gray,  0), "Flat",      group=grp_sty)

// ── ADDON ────────────────────────────────────────────────────────────────────
grp_flt   = "Filter: Green Lows & Red Highs"
filter_on = input.bool(false, "Enable filter", group=grp_flt,
              tooltip="ON: highs shown only on red steps, lows only on green steps")

// ─────────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────────
body_hi()  => math.max(open, close)
body_lo()  => math.min(open, close)
body_hi1() => math.max(open[1], close[1])
body_lo1() => math.min(open[1], close[1])

step_color(curr, prev) =>
    curr > prev ? col_up : curr < prev ? col_dn : col_flat

draw_step(x1, y1, x2, y2, col, lw, sty) =>
    line.new(x1, y1, x2, y1, color=col, width=lw, style=sty)
    line.new(x2, y1, x2, y2, color=col, width=lw, style=sty)

// ─────────────────────────────────────────────────────────────────────────────
//  FLAGS
// ─────────────────────────────────────────────────────────────────────────────
is_new_day = ta.change(time("D")) != 0
use_wicks  = src_type == "Wicks" or src_type == "Both"
use_body   = src_type == "Body"  or src_type == "Both"

// ─────────────────────────────────────────────────────────────────────────────
//  MAIN
// ─────────────────────────────────────────────────────────────────────────────
if not is_new_day and not barstate.isfirst

    // ── Wick step lines (solid) ──────────────────────────────────────────────
    if use_wicks
        hi_col_w  = step_color(high, high[1])
        lo_col_w  = step_color(low,  low[1])
        show_hi_w = not filter_on or hi_col_w == col_dn
        show_lo_w = not filter_on or lo_col_w == col_up
        if show_hi_w
            draw_step(bar_index-1, high[1], bar_index, high, hi_col_w, lw_wick, line.style_solid)
        if show_lo_w
            draw_step(bar_index-1, low[1],  bar_index, low,  lo_col_w, lw_wick, line.style_solid)

    // ── Body step lines (dashed) ─────────────────────────────────────────────
    if use_body
        hi_col_b  = step_color(body_hi(), body_hi1())
        lo_col_b  = step_color(body_lo(), body_lo1())
        show_hi_b = not filter_on or hi_col_b == col_dn
        show_lo_b = not filter_on or lo_col_b == col_up
        if show_hi_b
            draw_step(bar_index-1, body_hi1(), bar_index, body_hi(), hi_col_b, lw_body, line.style_dashed)
        if show_lo_b
            draw_step(bar_index-1, body_lo1(), bar_index, body_lo(), lo_col_b, lw_body, line.style_dashed)
````
