# Previous Candle High Low [JoeyWave]

- url: https://www.tradingview.com/script/mIrEacNV-Previous-Candle-High-Low-JoeyWave/
- type: indicator
- pine_id: PUB;393c1120faee44a1b4ea71592942f4b7
- version: 1.0

## Description

Previous Candle High Low [JoeyWave]

The previous candle's High and Low for any timeframe — set it once, read it on any chart.

█ WHAT IT DOES

Draws two horizontal levels: the High and the Low of the previous candle on your chosen timeframe (default H4). Same idea as Previous Day High/Low (PDH/PDL), but the period is yours to pick — H1, H4, Daily, Weekly, anything.

These levels are clean liquidity references: the prior candle's extremes are where stops rest and where price often reacts.

█ FEATURES

▮ Any timeframe
Pick the period once (default H4). The label auto-names itself — "Previous H4 High", "Previous D1 Low", etc.

▮ Smart timeframe clamp
View a chart below your chosen timeframe (e.g. M5 chart, H4 setting) and it auto-raises to the chart timeframe instead of breaking — always a valid level, no errors.

▮ Non-repainting
Levels are taken from the last fully closed candle of the chosen timeframe — they don't repaint.

▮ Fully customizable
Line style (solid / dashed / dotted), colors, label on/off, price on/off, and label offset to push the text toward the right edge.

█ SETTINGS

· Timeframe — which period's previous candle to read (default H4)
· Show Previous High / Low — toggle each level
· Line Style / Colors — appearance
· Show Labels / Show Price / Label Offset — label control

█ NOTES

· Works on every market and timeframe
· Choosing a timeframe ≥ chart timeframe gives the truest reading
· Pairs well with market-structure and liquidity-based setups

Built on Pine v6.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JoeyWave
// Previous candle's High & Low of a chosen timeframe (default H4).
// Same logic & drawing as the PDH/PDL levels in JoeyWave - ICT Levels,
// only the period is user-selectable.

//@version=6
indicator("Previous Candle High Low [JoeyWave]", "Prev Candle HL [JoeyWave]", overlay=true, max_lines_count=50, max_labels_count=50)

// ========== INPUTS ==========
tf         = input.timeframe("240", "Timeframe", tooltip="Which timeframe's previous candle to read. Default 240 = H4.")
i_ph       = input.bool(true, "Show Previous High", group="Levels")
i_pl       = input.bool(true, "Show Previous Low",  group="Levels")
i_style    = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], group="Display")
i_col_h    = input.color(#F23645, "High Color", group="Display")
i_col_l    = input.color(#089981, "Low Color",  group="Display")
show_label = input.bool(true, "Show Labels", group="Display")
show_price = input.bool(true, "Show Price in Label", group="Display")
i_offset   = input.int(20, "Label Offset (bars)", minval=0, maxval=200, group="Display", tooltip="How far right of the last candle to place the label. Increase to push it toward the right edge.")

// Smart clamp: a TF lower than the chart can't give a valid "previous candle"
// (sub-candles collapse to one). So auto-raise the effective TF to the chart TF.
eff_tf = timeframe.in_seconds(tf) < timeframe.in_seconds() ? timeframe.period : tf

// ========== TRACK PERIOD O/H/L → CAPTURE PREVIOUS AT BOUNDARY ==========
// Manual tracking (same as ICT Levels) avoids large request.security lookback on LTF.
p_time = request.security(syminfo.tickerid, eff_tf, time, lookahead=barmerge.lookahead_on)
new_p  = not na(p_time) and p_time != nz(p_time[1])

var float cur_h    = na, var float cur_l    = na
var float prev_h   = na, var float prev_l   = na
var int   start_bar = na

if new_p
    prev_h := cur_h
    prev_l := cur_l
    cur_h  := high
    cur_l  := low
    start_bar := bar_index
else
    cur_h := math.max(nz(cur_h, high), high)
    cur_l := math.min(nz(cur_l, low),  low)

get_style() => i_style == "Dashed" ? line.style_dashed : i_style == "Dotted" ? line.style_dotted : line.style_solid

// Readable timeframe name for labels ("240" → "H4", "1D" → "D1", ...)
tf_name(t) => t == "1" ? "M1" : t == "3" ? "M3" : t == "5" ? "M5" : t == "15" ? "M15" : t == "30" ? "M30" : t == "60" ? "H1" : t == "120" ? "H2" : t == "180" ? "H3" : t == "240" ? "H4" : (t == "1D" or t == "D") ? "D1" : (t == "1W" or t == "W") ? "W1" : (t == "1M" or t == "M") ? "MN" : t
tfn = tf_name(eff_tf)

// ========== DRAW (barstate.islast, line from current period start → extend right) ==========
var line  hiLine = na, var line  loLine = na
var label hiLbl  = na, var label loLbl  = na

if barstate.islast
    line.delete(hiLine), line.delete(loLine)
    label.delete(hiLbl), label.delete(loLbl)
    x1 = na(start_bar) ? bar_index - 50 : math.max(math.min(start_bar, bar_index - 1), bar_index - 4500)
    lbl_x = bar_index + i_offset   // forward into the empty future zone
    if i_ph and not na(prev_h)
        hiLine := line.new(x1, prev_h, bar_index, prev_h, xloc=xloc.bar_index, extend=extend.right, color=i_col_h, style=get_style(), width=1)
        if show_label
            txt = "Previous " + tfn + " High" + (show_price ? " " + str.tostring(prev_h, format.mintick) : "")
            // style_label_down + transparent bg = clean text sitting ABOVE the line
            hiLbl := label.new(lbl_x, prev_h, txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(color.white, 100), textcolor=i_col_h, size=size.normal)
    if i_pl and not na(prev_l)
        loLine := line.new(x1, prev_l, bar_index, prev_l, xloc=xloc.bar_index, extend=extend.right, color=i_col_l, style=get_style(), width=1)
        if show_label
            txt = "Previous " + tfn + " Low" + (show_price ? " " + str.tostring(prev_l, format.mintick) : "")
            // style_label_up + transparent bg = clean text sitting BELOW the line
            loLbl := label.new(lbl_x, prev_l, txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.new(color.white, 100), textcolor=i_col_l, size=size.normal)
````
