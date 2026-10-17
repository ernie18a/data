# Market Structure Mechanics - MSS

- url: https://www.tradingview.com/script/HPvKEAaC-Market-Structure-Mechanics-MSS/
- type: indicator
- pine_id: PUB;17835d3d939c41339a51376ed0928e01
- version: 1.0

## Description

This script is an automated structural mapping tool designed to read price action through the strict lens of the ICT (Inner Circle Trader) algorithmic framework. It doesn't just mark every high and low; it intelligently categorizes how price interacts with structural levels to tell you whether the trend is continuing, reversing, or manipulating.

Here is a breakdown of how the script interprets market mechanics:

1. Trend Tracking & Pivot Identification
The script actively tracks the most recent swing high (sh) and swing low (sl) to determine the current trend (bullish or bearish). It uses a customizable pivot length (default 5 bars) to identify these structural turning points.

2. Break of Structure (BOS)
A BOS signals that the current trend is continuing.

If the trend is Bullish and a candle closes decisively above the active Swing High, the script draws a solid blue line and labels it BOS.

If the trend is Bearish and a candle closes decisively below the active Swing Low, it draws a solid red line labeled BOS.

3. Market Structure Shift (MSS) with Displacement
An MSS is a high-probability signal that the overall trend has reversed. However, the script is designed to filter out fake reversals by enforcing the Displacement Rule.

If the trend is Bullish, but price suddenly closes below the active Swing Low, the algorithm checks the recent down-move to see if a Bearish Fair Value Gap (FVG) was formed.

If an FVG is present, it means the move had massive institutional momentum (Displacement). It will draw a thick red line labeled MSS, and the trend will officially shift to bearish.

If it breaks the low but no FVG is found, the script flags it as a low-probability, invalid break (drawn as a dotted gray line).

4. Liquidity Sweeps (Stop Hunts)
This is where the script shines at reading manipulation.

If price pushes past a structural high or low to trigger retail stop losses, but the candle ultimately fails to close beyond the level (leaving a wick), the script immediately recognizes this as a stop hunt.

It will draw a dashed orange line and label it Sweep.
The script also features a built-in "Smart Label Merger", meaning if a level gets Swept and then Broken on the exact same candle, the labels will neatly combine (e.g., "Sweep, BOS") instead of creating a messy, overlapping clump of text on your chart.

## Source Code

````pine
//@version=6
indicator("ICT Market Structure Mechanics", overlay=true, max_lines_count=500, max_labels_count=500)

// =====================================================================
// ICT Market Structure Mechanics
// Differentiates between:
// - BOS (Break of Structure): Trend continuation with decisive close.
// - MSS (Market Structure Shift): Trend reversal with decisive close + Displacement.
// - Sweep (Liquidity Hunt): Wick past a structural pivot without closing beyond it.
// =====================================================================

// --- Inputs ---
grp_pivots = "Structure Settings"
pivot_len = input.int(5, title="Pivot Length", group=grp_pivots, tooltip="Lookback/lookforward for swing highs and lows.")
disp_len = input.int(10, title="Displacement Lookback", group=grp_pivots, tooltip="How many bars back to check for an FVG to validate an MSS.")

grp_style = "Visual Styling"
bull_col = input.color(color.new(color.blue, 0), title="Bullish Break (BOS/MSS) Color", group=grp_style)
bear_col = input.color(color.new(color.red, 0), title="Bearish Break (BOS/MSS) Color", group=grp_style)
sweep_col = input.color(color.new(color.orange, 0), title="Liquidity Sweep Color", group=grp_style)
invalid_col = input.color(color.new(color.gray, 50), title="Invalid Break Color", group=grp_style)

// --- Pivot Detection ---
ph = ta.pivothigh(high, pivot_len, pivot_len)
pl = ta.pivotlow(low, pivot_len, pivot_len)

var int trend = 1 // 1 for Bullish, -1 for Bearish

var float sh = na
var int sh_x = na
var bool sh_swept = false

var float sl = na
var int sl_x = na
var bool sl_swept = false

if not na(ph)
    sh := ph
    sh_x := bar_index[pivot_len]
    sh_swept := false

if not na(pl)
    sl := pl
    sl_x := bar_index[pivot_len]
    sl_swept := false

// --- Displacement Detection (FVGs) ---
is_bull_fvg = low > high[2]
is_bear_fvg = high < low[2]

var int last_bull_fvg = na
var int last_bear_fvg = na

if is_bull_fvg
    last_bull_fvg := bar_index[1]
if is_bear_fvg
    last_bear_fvg := bar_index[1]

// --- Smart Label Merger ---
var label[] active_labels = array.new_label()

f_smart_label(_x, _y, _txt, _color, _style, _size) =>
    bool merged = false
    if array.size(active_labels) > 0
        // Check recent labels to see if one exists at the exact coordinate
        for i = array.size(active_labels) - 1 to math.max(0, array.size(active_labels) - 20)
            lbl = array.get(active_labels, i)
            if label.get_x(lbl) == _x and label.get_y(lbl) == _y
                current_txt = label.get_text(lbl)
                // Merge text with comma if it's not already in the label
                if not str.contains(current_txt, _txt)
                    label.set_text(lbl, current_txt + ", " + _txt)
                merged := true
                break
    if not merged
        lbl = label.new(x=_x, y=_y, text=_txt, color=color.new(color.white,100), textcolor=_color, style=_style, size=_size)
        array.push(active_labels, lbl)
        if array.size(active_labels) > 400
            label.delete(array.shift(active_labels))

// --- Breakout & Sweep Logic ---
if barstate.isconfirmed
    // -------------------------
    // Bullish Trend Mechanics
    // -------------------------
    if trend == 1
        // Check Highs (BOS)
        if not na(sh) and high > sh
            if close > sh
                // BOS
                line.new(x1=sh_x, y1=sh, x2=bar_index, y2=sh, color=bull_col, style=line.style_solid, width=1)
                f_smart_label(bar_index, sh, "BOS", bull_col, label.style_label_down, size.small)
                sh := na // Level broken
            else if not sh_swept
                // Sweep
                line.new(x1=sh_x, y1=sh, x2=bar_index, y2=sh, color=sweep_col, style=line.style_dashed, width=1)
                f_smart_label(bar_index, sh, "Sweep", sweep_col, label.style_label_down, size.small)
                sh_swept := true // Prevent multiple sweep labels on the same level
                
        // Check Lows (MSS)
        if not na(sl) and low < sl
            if close < sl
                // Check for Displacement (Recent Bearish FVG)
                has_disp = not na(last_bear_fvg) and (bar_index - last_bear_fvg) <= disp_len
                if has_disp
                    // Valid MSS
                    line.new(x1=sl_x, y1=sl, x2=bar_index, y2=sl, color=bear_col, style=line.style_solid, width=2)
                    f_smart_label(bar_index, sl, "MSS", bear_col, label.style_label_up, size.normal)
                    trend := -1 // Trend shifts to Bearish
                else
                    // Invalid Break (No displacement)
                    line.new(x1=sl_x, y1=sl, x2=bar_index, y2=sl, color=invalid_col, style=line.style_dotted, width=1)
                sl := na // Level broken
            else if not sl_swept
                // Sweep
                line.new(x1=sl_x, y1=sl, x2=bar_index, y2=sl, color=sweep_col, style=line.style_dashed, width=1)
                f_smart_label(bar_index, sl, "Sweep", sweep_col, label.style_label_up, size.small)
                sl_swept := true

    // -------------------------
    // Bearish Trend Mechanics
    // -------------------------
    else if trend == -1
        // Check Lows (BOS)
        if not na(sl) and low < sl
            if close < sl
                // BOS
                line.new(x1=sl_x, y1=sl, x2=bar_index, y2=sl, color=bear_col, style=line.style_solid, width=1)
                f_smart_label(bar_index, sl, "BOS", bear_col, label.style_label_up, size.small)
                sl := na // Level broken
            else if not sl_swept
                // Sweep
                line.new(x1=sl_x, y1=sl, x2=bar_index, y2=sl, color=sweep_col, style=line.style_dashed, width=1)
                f_smart_label(bar_index, sl, "Sweep", sweep_col, label.style_label_up, size.small)
                sl_swept := true
                
        // Check Highs (MSS)
        if not na(sh) and high > sh
            if close > sh
                // Check for Displacement (Recent Bullish FVG)
                has_disp = not na(last_bull_fvg) and (bar_index - last_bull_fvg) <= disp_len
                if has_disp
                    // Valid MSS
                    line.new(x1=sh_x, y1=sh, x2=bar_index, y2=sh, color=bull_col, style=line.style_solid, width=2)
                    f_smart_label(bar_index, sh, "MSS", bull_col, label.style_label_down, size.normal)
                    trend := 1 // Trend shifts to Bullish
                else
                    // Invalid Break
                    line.new(x1=sh_x, y1=sh, x2=bar_index, y2=sh, color=invalid_col, style=line.style_dotted, width=1)
                sh := na // Level broken
            else if not sh_swept
                // Sweep
                line.new(x1=sh_x, y1=sh, x2=bar_index, y2=sh, color=sweep_col, style=line.style_dashed, width=1)
                f_smart_label(bar_index, sh, "Sweep", sweep_col, label.style_label_down, size.small)
                sh_swept := true
````
