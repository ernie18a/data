# Double ATR Reversal

- url: https://www.tradingview.com/script/QAtF1fF0-Double-ATR-Reversal/
- type: indicator
- pine_id: PUB;a23d4438e71648fe95bcddf123ce4428
- version: 1.0

## Description

// ════════════════════════════════════════════════════════════════════════════
// DOUBLE ATR REVERSAL — Chandelier-style trailing stop + ATR expansion scanner
// ────────────────────────────────────────────────────────────────────────────
// METHOD
//   1. Trailing stop. A ratcheting stop is computed from the rolling extreme
//      (highest src_h or lowest src_l over N bars) offset by a multiple of
//      Wilder's ATR. The long stop only ratchets up; the short stop only
//      ratchets down. When price crosses the opposite side's stop, the
//      trend "flips." This is the same construction as the standard
//      Chandelier Exit; the "Double ATR" naming refers to the default
//      multiplier of 2.0 (faster reversals than the conventional 3.0).
//
//   2. Reversal events. A bull reversal fires on the bar where the trend
//      flips from -1 to +1; a bear reversal on +1 to -1. These are
//      point-in-time events, distinct from the persistent trend state.
//
//   3. Volatility expansion overlay. Current ATR is compared to a rolling
//      SMA of ATR over `expand_len` bars. A separate signal fires when
//      current ATR exceeds expand_mult × baseline. This catches news /
//      volatility events that are independent of trend direction and is
//      the primary addition over a plain trailing-stop indicator.
//
// SOURCE TOGGLE
//   `use_close` selects whether the rolling extremes use closing prices
//   (smoother, fewer whipsaws) or wicks (more sensitive to spikes). This
//   meaningfully changes signal frequency on noisy instruments and is
//   exposed as an input rather than hard-coded.
//
// OUTPUTS
//   • Trailing stop line, color-coded by trend state
//   • Optional bar coloring by trend
//   • Bullish / bearish reversal triangles + optional price-annotated labels
//   • Yellow background flash + diamond marker on ATR expansion bars
//   • Info table: trend, ATR (absolute and as % of price), trail stop,
//     multiplier, and expansion state
//   • Four alertconditions: bull reversal, bear reversal, any reversal,
//     and volatility expansion — suitable for cross-symbol scanning via
//     TradingView alert lists
//
// NOT A STRATEGY: orders, slippage, and returns are not modeled.
// ════════════════════════════════════════════════════════════════════════════

## Source Code

````pine
//@version=6
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dublin_capital

//@version=6
indicator("Double ATR Reversal", shorttitle="2×ATR Rev", overlay=true, max_labels_count=500)

// ════════════════════════════════════════════════════════════════════════════
// DOUBLE ATR REVERSAL — Chandelier-style trailing stop + ATR expansion scanner
// ────────────────────────────────────────────────────────────────────────────
// METHOD
//   1. Trailing stop. A ratcheting stop is computed from the rolling extreme
//      (highest src_h or lowest src_l over N bars) offset by a multiple of
//      Wilder's ATR. The long stop only ratchets up; the short stop only
//      ratchets down. When price crosses the opposite side's stop, the
//      trend "flips." This is the same construction as the standard
//      Chandelier Exit; the "Double ATR" naming refers to the default
//      multiplier of 2.0 (faster reversals than the conventional 3.0).
//
//   2. Reversal events. A bull reversal fires on the bar where the trend
//      flips from -1 to +1; a bear reversal on +1 to -1. These are
//      point-in-time events, distinct from the persistent trend state.
//
//   3. Volatility expansion overlay. Current ATR is compared to a rolling
//      SMA of ATR over `expand_len` bars. A separate signal fires when
//      current ATR exceeds expand_mult × baseline. This catches news /
//      volatility events that are independent of trend direction and is
//      the primary addition over a plain trailing-stop indicator.
//
// SOURCE TOGGLE
//   `use_close` selects whether the rolling extremes use closing prices
//   (smoother, fewer whipsaws) or wicks (more sensitive to spikes). This
//   meaningfully changes signal frequency on noisy instruments and is
//   exposed as an input rather than hard-coded.
//
// OUTPUTS
//   • Trailing stop line, color-coded by trend state
//   • Optional bar coloring by trend
//   • Bullish / bearish reversal triangles + optional price-annotated labels
//   • Yellow background flash + diamond marker on ATR expansion bars
//   • Info table: trend, ATR (absolute and as % of price), trail stop,
//     multiplier, and expansion state
//   • Four alertconditions: bull reversal, bear reversal, any reversal,
//     and volatility expansion — suitable for cross-symbol scanning via
//     TradingView alert lists
//
// NOT A STRATEGY: orders, slippage, and returns are not modeled.
// ════════════════════════════════════════════════════════════════════════════


// ── INPUTS ─────────────────────────────────────────────────────────────────

g1 = "ATR Settings"
atr_len   = input.int(14, "ATR Length", minval=1, group=g1,
            tooltip="Wilder's ATR period. Standard default = 14.")
atr_mult  = input.float(2.0, "ATR Multiplier (Double ATR = 2.0)", minval=0.5, step=0.5, group=g1,
            tooltip="Distance from rolling extreme to trailing stop, in ATR multiples.\n2.0 = Double ATR.\nHigher values → fewer signals, wider stops, longer trend confirmation.")
use_close = input.bool(true, "Use Closing Prices for Extremes", group=g1,
            tooltip="ON  → rolling highest/lowest of close (smoother, fewer whipsaws).\nOFF → rolling highest/lowest of high/low wicks (more sensitive to spikes).")

g2 = "ATR Expansion Scanner"
show_expand = input.bool(true,  "Show ATR Expansion Signals",       group=g2,
              tooltip="Flags bars where ATR is well above its recent average — useful for spotting news / volatility events independent of trend direction.")
expand_len  = input.int(20,     "Expansion Baseline Period (bars)", minval=5, group=g2,
              tooltip="Bars used to compute the average ATR baseline for comparison.")
expand_mult = input.float(2.0,  "Expansion Threshold (× Avg ATR)",  minval=1.1, step=0.1, group=g2,
              tooltip="Signal fires when current ATR exceeds this multiple of the baseline average.")

g3 = "Display"
show_trail   = input.bool(true, "Show ATR Trail Line",   group=g3)
show_signals = input.bool(true, "Show Reversal Arrows",  group=g3)
show_labels  = input.bool(true, "Show Reversal Labels",  group=g3)
color_bars   = input.bool(true, "Color Bars by Trend",   group=g3)
show_table   = input.bool(true, "Show Info Table",       group=g3)

g4 = "Colors"
bull_col   = input.color(#00e676, "Bullish Color",       group=g4)
bear_col   = input.color(#ff1744, "Bearish Color",       group=g4)
expand_col = input.color(#ffeb3b, "ATR Expansion Color", group=g4)


// ── ATR ─────────────────────────────────────────────────────────────────────
atr     = ta.atr(atr_len)
atr_pct = (atr / close) * 100

src_h = use_close ? close : high
src_l = use_close ? close : low


// ── TRAILING STOP (Chandelier-style ratchet) ───────────────────────────────
// Long  stop = highest(src_h, N) − mult × ATR, ratcheted upward.
// Short stop = lowest(src_l, N)  + mult × ATR, ratcheted downward.
// Stops reset when the trend flips (close breaches the opposite stop).

long_stop_raw  = ta.highest(src_h, atr_len) - atr_mult * atr
short_stop_raw = ta.lowest(src_l,  atr_len) + atr_mult * atr

var float long_stop  = na
var float short_stop = na

long_stop  := close[1] > nz(long_stop[1],  long_stop_raw)
             ? math.max(long_stop_raw,  nz(long_stop[1],  long_stop_raw))
             : long_stop_raw

short_stop := close[1] < nz(short_stop[1], short_stop_raw)
             ? math.min(short_stop_raw, nz(short_stop[1], short_stop_raw))
             : short_stop_raw


// ── TREND DIRECTION (+1 bull / −1 bear) ────────────────────────────────────
var int dir = 1
dir := close > nz(short_stop[1], short_stop) ?  1
     : close < nz(long_stop[1],  long_stop)  ? -1
     : nz(dir[1], 1)

float trail = dir == 1 ? long_stop : short_stop


// ── REVERSAL & EXPANSION DETECTION ──────────────────────────────────────────
bull_rev = dir ==  1 and nz(dir[1], 1) == -1
bear_rev = dir == -1 and nz(dir[1], 1) ==  1

avg_atr    = ta.sma(atr, expand_len)
atr_expand = show_expand and (atr > avg_atr * expand_mult)


// ── PLOTS ───────────────────────────────────────────────────────────────────

trail_color = dir == 1 ? color.new(bull_col, 20) : color.new(bear_col, 20)
plot(show_trail ? trail : na,
     "ATR Trail Stop", color=trail_color, linewidth=2, style=plot.style_linebr)

barcolor(color_bars
         ? (dir == 1 ? color.new(bull_col, 65) : color.new(bear_col, 65))
         : na)

bgcolor(atr_expand ? color.new(expand_col, 82) : na, title="ATR Expansion Flash")

plotshape(show_signals and bull_rev,
          "▲ Bullish Reversal",
          shape.triangleup, location.belowbar, bull_col, size=size.normal)

plotshape(show_signals and bear_rev,
          "▼ Bearish Reversal",
          shape.triangledown, location.abovebar, bear_col, size=size.normal)

plotshape(show_expand and atr_expand and not (bull_rev or bear_rev),
          "◆ ATR Expansion Spike",
          shape.diamond, location.abovebar, expand_col, size=size.tiny)

if show_labels and bull_rev
    label.new(bar_index, low - atr * 0.9,
              "▲ BULL REV\n" + str.tostring(close, format.mintick),
              color=bull_col, textcolor=color.black,
              style=label.style_label_up, size=size.small)

if show_labels and bear_rev
    label.new(bar_index, high + atr * 0.9,
              "▼ BEAR REV\n" + str.tostring(close, format.mintick),
              color=bear_col, textcolor=color.white,
              style=label.style_label_down, size=size.small)


// ── INFO TABLE (bottom-right) ──────────────────────────────────────────────

var table tbl = table.new(position.bottom_right, 2, 6,
     bgcolor      = color.new(color.black, 55),
     border_color = color.new(color.gray,  40),
     border_width = 1,
     frame_color  = color.gray,
     frame_width  = 1)

if show_table and barstate.islast
    t_txt          = dir == 1 ? "▲  BULLISH" : "▼  BEARISH"
    t_col2         = dir == 1 ? bull_col     : bear_col
    expand_txt     = atr_expand ? "⚡ ACTIVE" : "normal"
    expand_txt_col = atr_expand ? expand_col  : color.silver

    table.cell(tbl, 0, 0, "  2×ATR Reversal  ",
               bgcolor=color.new(color.black, 20), text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 0, "", bgcolor=color.new(color.black, 20))

    table.cell(tbl, 0, 1, "Trend", text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 1, t_txt,   text_color=t_col2,       text_size=size.small)

    table.cell(tbl, 0, 2, "ATR(" + str.tostring(atr_len) + ")",
               text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 2, str.tostring(atr, "#.00") + "  (" + str.tostring(atr_pct, "#.00") + "%)",
               text_color=color.white, text_size=size.small)

    table.cell(tbl, 0, 3, "Trail Stop", text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 3, str.tostring(trail, format.mintick),
               text_color=t_col2, text_size=size.small)

    table.cell(tbl, 0, 4, "Multiplier", text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 4, str.tostring(atr_mult, "#.0") + "×  (Double ATR)",
               text_color=color.white, text_size=size.small)

    table.cell(tbl, 0, 5, "ATR Expand", text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 5, expand_txt,   text_color=expand_txt_col, text_size=size.small)


// ── ALERTS ──────────────────────────────────────────────────────────────────
// Condition-descriptive; suitable for cross-symbol scanning via alert lists.

alertcondition(bull_rev,
               "2×ATR — Bullish Reversal",
               "{{ticker}} bullish reversal: close crossed above prior bearish trail stop | Close: {{close}}")

alertcondition(bear_rev,
               "2×ATR — Bearish Reversal",
               "{{ticker}} bearish reversal: close crossed below prior bullish trail stop | Close: {{close}}")

alertcondition(bull_rev or bear_rev,
               "2×ATR — Any Reversal",
               "{{ticker}} ATR trail-stop reversal | Close: {{close}}")

alertcondition(atr_expand,
               "2×ATR — Volatility Expansion",
               "{{ticker}} ATR expansion: current ATR exceeds rolling baseline | Close: {{close}}")
````
