# Smooths 50 Point Levels

- url: https://www.tradingview.com/script/tkizhsPQ-Smooths-50-Point-Levels/
- type: indicator
- pine_id: PUB;8dab76538c6c425983425153dcc01741
- version: 2.0

## Description

Smooth's 50-Point Levels
Overview
This indicator automatically plots horizontal price levels at every 50-point interval across the chart, centered around the current price. It is designed specifically for futures traders (NQ, ES, MNQ, MES) who use round-number price levels as key reference points for support, resistance, entries, and targets.
How It Works
The indicator calculates the nearest 50-point boundary to the current price using math.round(price / 50) * 50 as its base, then draws a configurable number of levels above and below that base. Levels are split into two distinct categories:

Round Hundreds (X00) — levels ending in 00 (e.g. 19800, 19900, 20000). These represent major psychological price levels where institutional activity and order flow tend to concentrate.
Half-Hundreds (X50) — levels ending in 50 (e.g. 19850, 19950). These act as midpoint references between the major levels, useful for identifying equilibrium zones and scalp targets.

Session Reset
Lines reset visually at a user-defined time each day (default 16:00 ET), meaning the left edge of every line anchors to that bar. This keeps the chart clean and session-specific — only showing levels relevant to the current trading session. A toggle allows lines to be extended further left for historical context.
How To Use

Use Round Hundred levels as primary support/resistance and trade targets
Use Half-Hundred levels as midpoint references and short-term scalp zones
Levels reset at 16:00 ET daily to reflect the new session's relevant price range
Adjust the number of levels displayed to match your trading range
Enable left extension when reviewing previous session price action

Customization
Each level group has independent controls for color, line style (solid/dashed/dotted), line width, label visibility, and label size. Right extension allows lines to project into future bars for forward reference.

## Source Code

````pine
//@version=6
indicator("Smooth's 50-Point Levels", overlay=true, max_lines_count=500, max_labels_count=500)

// ─── GENERAL ───────────────────────────────────────────────────────────────────
show_hundreds = input.bool(true,  "Show Round Hundreds  (e.g. 19800, 19900)", group="General")
show_fifties  = input.bool(true,  "Show Half-Hundreds   (e.g. 19850, 19950)", group="General")
num_levels    = input.int(20, "Levels Above / Below Price", minval=5, maxval=50, group="General")

// ─── DISPLAY MODE ─────────────────────────────────────────────────────────────
right_mode  = input.bool(false, "Right Side Only Mode",
               tooltip="Lines float right of the current bar with inline text — mirrors the Tradovate layout.",
               group="Display Mode")
gap_bars    = input.int(2,  "Gap — bars from current bar",  minval=0, maxval=20,  group="Display Mode")
line_length = input.int(30, "Line Length — bars",            minval=5, maxval=200, group="Display Mode")
text_gap    = input.int(5,  "Text Gap — bars either side",  minval=1, maxval=20,  group="Display Mode")

// ─── ORIGINAL MODE ─────────────────────────────────────────────────────────────
line_right  = input.int(50,   "Bars Right",               minval=0,  maxval=500, group="Original Mode")
extend_left = input.bool(false, "Extend Lines Left",       group="Original Mode")
line_left   = input.int(200,  "Bars Left (when extended)", minval=10, maxval=500, group="Original Mode")

// ─── SESSION RESET — original mode only ────────────────────────────────────────
tz         = input.string("America/New_York", "Timezone", group="Session Reset",
               options=["America/New_York","America/Chicago","America/Los_Angeles","Europe/London","UTC"])
reset_hour = input.int(16, "Reset Hour (24h)", minval=0, maxval=23, group="Session Reset")

// ─── ROUND HUNDREDS (X00) ──────────────────────────────────────────────────────
h_col       = input.color(#FFFFFF,  "Color",      group="Round Hundreds  ──  X00")
h_style_str = input.string("Solid", "Line Style", group="Round Hundreds  ──  X00", options=["Solid","Dashed","Dotted"])
h_width     = input.int(1,          "Width",       group="Round Hundreds  ──  X00", minval=1, maxval=4)
h_lbl       = input.bool(true,      "Show Label",  group="Round Hundreds  ──  X00")
h_lbl_size  = input.string("Small", "Label Size",  group="Round Hundreds  ──  X00", options=["Tiny","Small","Normal","Large"])

// ─── HALF-HUNDREDS (X50) ───────────────────────────────────────────────────────
f_col       = input.color(#555555,   "Color",      group="Half-Hundreds   ──  X50")
f_style_str = input.string("Dashed", "Line Style", group="Half-Hundreds   ──  X50", options=["Solid","Dashed","Dotted"])
f_width     = input.int(1,           "Width",       group="Half-Hundreds   ──  X50", minval=1, maxval=4)
f_lbl       = input.bool(true,       "Show Label",  group="Half-Hundreds   ──  X50")
f_lbl_size  = input.string("Small",  "Label Size",  group="Half-Hundreds   ──  X50", options=["Tiny","Small","Normal","Large"])

// ─── HELPERS ───────────────────────────────────────────────────────────────────
f_line_style(s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        =>          line.style_solid

f_label_size(s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Large"  => size.large
        =>          size.small

// ─── SESSION RESET TRACKING ────────────────────────────────────────────────────
is_reset_bar = hour(time, tz) == reset_hour and minute(time, tz) == 0

var int reset_bar_idx = na
if is_reset_bar
    reset_bar_idx := bar_index

// ─── DRAWING STATE ─────────────────────────────────────────────────────────────
var line[]  all_lines  = array.new<line>()
var label[] all_labels = array.new<label>()

// ─── DRAW ──────────────────────────────────────────────────────────────────────
if barstate.islast
    for ln in all_lines
        line.delete(ln)
    for lb in all_labels
        label.delete(lb)
    array.clear(all_lines)
    array.clear(all_labels)

    base = math.round(close / 50) * 50

    for i = -num_levels to num_levels
        level     = base + i * 50
        remainder = math.abs(level % 100)

        is_hundred = remainder == 0
        is_fifty   = remainder == 50

        if (is_hundred and show_hundreds) or (is_fifty and show_fifties)
            lcolor = is_hundred ? h_col : f_col
            lstyle = is_hundred ? f_line_style(h_style_str) : f_line_style(f_style_str)
            lwidth = is_hundred ? h_width : f_width
            do_lbl = is_hundred ? h_lbl   : f_lbl
            lsize  = is_hundred ? f_label_size(h_lbl_size) : f_label_size(f_lbl_size)

            if right_mode
                // ── Right Side Only — two halves with inline label at midpoint ──
                x_start = bar_index + gap_bars
                x_mid   = bar_index + gap_bars + math.round(line_length / 2)
                x_end   = bar_index + gap_bars + line_length

                // Left half
                if x_mid - text_gap > x_start
                    ln1 = line.new(
                         x1=x_start, y1=level, x2=x_mid - text_gap, y2=level,
                         xloc=xloc.bar_index, color=lcolor, style=lstyle, width=lwidth)
                    array.push(all_lines, ln1)

                // Right half
                if x_end > x_mid + text_gap
                    ln2 = line.new(
                         x1=x_mid + text_gap, y1=level, x2=x_end, y2=level,
                         xloc=xloc.bar_index, color=lcolor, style=lstyle, width=lwidth)
                    array.push(all_lines, ln2)

                // Inline label centered at midpoint, transparent background
                if do_lbl
                    lb = label.new(
                         x         = x_mid,
                         y         = level,
                         text      = str.tostring(level),
                         xloc      = xloc.bar_index,
                         color     = color.new(color.black, 100),
                         textcolor = lcolor,
                         style     = label.style_label_center,
                         size      = lsize)
                    array.push(all_labels, lb)

            else
                // ── Original Mode — full line from session reset to right edge ──
                x_left = extend_left
                     ? bar_index - line_left
                     : na(reset_bar_idx) ? bar_index - 50 : reset_bar_idx

                ln = line.new(
                     x1=x_left, y1=level, x2=bar_index + line_right, y2=level,
                     xloc=xloc.bar_index, color=lcolor, style=lstyle, width=lwidth)
                array.push(all_lines, ln)

                if do_lbl
                    lb = label.new(
                         x         = bar_index + line_right,
                         y         = level,
                         text      = str.tostring(level),
                         xloc      = xloc.bar_index,
                         color     = color.new(color.black, 100),
                         textcolor = lcolor,
                         style     = label.style_label_left,
                         size      = lsize)
                    array.push(all_labels, lb)
````
