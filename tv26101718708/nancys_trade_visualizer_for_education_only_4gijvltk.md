# Nancy's Trade Visualizer - For Education Only

- url: https://www.tradingview.com/script/4gIJvLTK-Nancy-s-Trade-Visualizer-For-Education-Only/
- type: indicator
- pine_id: PUB;23d00ffa96b646918b6308131971d40c
- version: 1.0

## Description

Built this for one of my students to help her start recognizing setups on her own without having to hunt for everything manually. Nothing fancy, just a clean visual layer on top of price action.
Here's what it does:

[list]
[*]
Marks the long wick swing points (the A label) so she can start training her eye to spot them
Highlights the fair value gap that forms after the sweep (the B box) so the sequence is obvious
Drops a checklist right on the chart showing exactly which conditions passed or failed — long wick, gap, and stop loss under 40 points
Flags the entry as C Up or C Down so direction is never ambiguous
Kills the trade automatically if the stop is over 40 points and marks it purple so she knows not to touch it
Only runs during the 9:30–11:30 AM session so there's no noise outside the window we actually trade
Works across all historical bars so she can go back and study past price action
[/list]

Not a strategy, not a signal service — just a teaching tool so she can see the pattern repeat and start building the recognition herself.

## Source Code

````pine
//@version=6
indicator("Nancy's Trade Visualizer - For Education Only", overlay=true, max_labels_count=500, max_boxes_count=500)

// ─────────────────────────────────────────────
//  1. INPUTS
// ─────────────────────────────────────────────
max_candles = input.int(4, title="Max Candles After Sweep to Form Gap", minval=1, maxval=10)

// "America/New_York" = auto-handles EST/EDT — no manual DST shifting needed
in_session = not na(time(timeframe.period, "0930-1130:1234567", "America/New_York"))

// ─────────────────────────────────────────────
//  2. LEGEND TABLE  (upper right corner)
// ─────────────────────────────────────────────
var table legend = table.new(
     position     = position.top_right,
     columns      = 2,
     rows         = 4,
     bgcolor      = color.new(color.black, 20),
     border_color = color.new(color.white, 40),
     border_width = 1,
     frame_color  = color.new(color.white, 20),
     frame_width  = 1)

// Header
table.cell(legend, 0, 0, "KEY",
     text_color  = color.white,
     text_size   = size.normal,
     text_halign = text.align_center,
     bgcolor     = color.new(color.gray, 30))
table.cell(legend, 1, 0, "MEANING",
     text_color  = color.white,
     text_size   = size.normal,
     text_halign = text.align_left,
     bgcolor     = color.new(color.gray, 30))

// A row — blue
table.cell(legend, 0, 1, "A",
     text_color  = color.white,
     text_size   = size.large,
     text_halign = text.align_center,
     bgcolor     = color.new(color.blue, 20))
table.cell(legend, 1, 1, "Long wick with two shorter wicks on both sides",
     text_color  = color.white,
     text_size   = size.small,
     text_halign = text.align_left,
     bgcolor     = color.new(color.blue, 20))

// B row — green
table.cell(legend, 0, 2, "B",
     text_color  = color.white,
     text_size   = size.large,
     text_halign = text.align_center,
     bgcolor     = color.new(color.green, 20))
table.cell(legend, 1, 2, "Gap (Fair Value Gap / FVG)",
     text_color  = color.white,
     text_size   = size.normal,
     text_halign = text.align_left,
     bgcolor     = color.new(color.green, 20))

// C row — orange
table.cell(legend, 0, 3, "C",
     text_color  = color.white,
     text_size   = size.large,
     text_halign = text.align_center,
     bgcolor     = color.new(color.orange, 20))
table.cell(legend, 1, 3, "Potential Trade Entry (all 3 checks passed)",
     text_color  = color.white,
     text_size   = size.small,
     text_halign = text.align_left,
     bgcolor     = color.new(color.orange, 20))

// ─────────────────────────────────────────────
//  3. STATE VARIABLES
// ─────────────────────────────────────────────
var int   active_sl_idx = na
var float active_sl_val = na

var int   active_sh_idx = na
var float active_sh_val = na

// Reset at session boundaries
if not in_session
    active_sl_idx := na
    active_sl_val := na
    active_sh_idx := na
    active_sh_val := na

// ─────────────────────────────────────────────
//  4. CORE LOGIC
//     Runs on every historical bar inside session.
//     All drawings fire on confirmed (closed) bars only.
// ─────────────────────────────────────────────
if in_session

    // ══════════════════════════════════════════
    //  BULLISH  (Sweep Low → First Bull FVG)
    // ══════════════════════════════════════════

    is_swing_low = low[1] < low[2] and low[1] < low[0]
    if is_swing_low
        active_sl_idx := bar_index - 1
        active_sl_val := low[1]

    if not na(active_sl_idx) and (bar_index - active_sl_idx) > max_candles + 1
        active_sl_idx := na
        active_sl_val := na

    // Bullish FVG completes on close of bar[0] (3rd candle)
    bull_fvg = low[0] > high[2] and close[1] > open[1]

    if bull_fvg and not na(active_sl_idx)
        risk_points = high[2] - active_sl_val

        // ── A: Long-wick swing low — BLUE background ──
        label.new(
             active_sl_idx, active_sl_val,
             text      = "A",
             style     = label.style_label_up,
             color     = color.new(color.blue, 10),
             textcolor = color.white,
             size      = size.large)

        // ── B: Gap box — GREEN background, white "Gap" text ──
        box.new(
             left         = bar_index - 2,
             top          = low[0],
             right        = bar_index,
             bottom       = high[2],
             border_color = color.new(color.lime, 0),
             border_width = 2,
             bgcolor      = color.new(color.green, 40),
             text         = "Gap",
             text_color   = color.white,
             text_size    = size.large,
             text_valign  = text.align_center,
             text_halign  = text.align_center)

        // ── C: Entry or NO TRADE ──
        if risk_points > 40
            label.new(
                 bar_index, low[0],
                 text      = "⚠ NO TRADE\n✔ Long Wick\n✔ Gap\n✘ Stop Loss > 40 pts",
                 style     = label.style_label_left,
                 color     = color.new(color.purple, 10),
                 textcolor = color.white,
                 size      = size.normal)
        else
            label.new(
                 bar_index, low[0],
                 text      = "C Up\n✔ Long Wick\n✔ Gap\n✔ Stop Loss < 40 pts",
                 style     = label.style_label_left,
                 color     = color.new(color.orange, 10),
                 textcolor = color.white,
                 size      = size.normal)

        active_sl_idx := na
        active_sl_val := na


    // ══════════════════════════════════════════
    //  BEARISH  (Sweep High → First Bear FVG)
    // ══════════════════════════════════════════

    is_swing_high = high[1] > high[2] and high[1] > high[0]
    if is_swing_high
        active_sh_idx := bar_index - 1
        active_sh_val := high[1]

    if not na(active_sh_idx) and (bar_index - active_sh_idx) > max_candles + 1
        active_sh_idx := na
        active_sh_val := na

    // Bearish FVG completes on close of bar[0] (3rd candle)
    bear_fvg = high[0] < low[2] and close[1] < open[1]

    if bear_fvg and not na(active_sh_idx)
        risk_points = active_sh_val - low[2]

        // ── A: Long-wick swing high — BLUE background ──
        label.new(
             active_sh_idx, active_sh_val,
             text      = "A",
             style     = label.style_label_down,
             color     = color.new(color.blue, 10),
             textcolor = color.white,
             size      = size.large)

        // ── B: Gap box — GREEN background, white "Gap" text ──
        box.new(
             left         = bar_index - 2,
             top          = low[2],
             right        = bar_index,
             bottom       = high[0],
             border_color = color.new(color.lime, 0),
             border_width = 2,
             bgcolor      = color.new(color.green, 40),
             text         = "Gap",
             text_color   = color.white,
             text_size    = size.large,
             text_valign  = text.align_center,
             text_halign  = text.align_center)

        // ── C: Entry or NO TRADE ──
        if risk_points > 40
            label.new(
                 bar_index, low[2],
                 text      = "⚠ NO TRADE\n✔ Long Wick\n✔ Gap\n✘ Stop Loss > 40 pts",
                 style     = label.style_label_left,
                 color     = color.new(color.purple, 10),
                 textcolor = color.white,
                 size      = size.normal)
        else
            label.new(
                 bar_index, low[2],
                 text      = "C Down\n✔ Long Wick\n✔ Gap\n✔ Stop Loss < 40 pts",
                 style     = label.style_label_left,
                 color     = color.new(color.orange, 10),
                 textcolor = color.white,
                 size      = size.normal)

        active_sh_idx := na
        active_sh_val := na
````
