# POC MONTHLY + PIVOT

- url: https://www.tradingview.com/script/uO8KAvDs-POC-MONTHLY-PIVOT/
- type: indicator
- pine_id: PUB;284e8ea45eb04404a4abf3bdd94613cb
- version: 1.0

## Description

POC Monthly + Pivot — Code Explanation
This is a Pine Script v5 TradingView indicator that combines two powerful concepts: Monthly Volume Profile (with POC/VAH/VAL) and Swing Support & Resistance levels. Here's a breakdown:  1. User Inputs
pinerows      = 48   // How many price rows to split the month into
va_pct    = 70   // Value Area = 70% of total volume
lookback  = 10   // How many bars to look back for swing highs/lows
rs_len    = 8    // Visual length of S/R lines (in bars)
Plus color and style settings for boxes, POC line, and volume bars.

📐 2. Support & Resistance (Swing High/Low)
pineswingHigh = ta.pivothigh(high, lookback, lookback)
swingLow  = ta.pivotlow (low,  lookback, lookback)

Detects pivot highs (Resistance) and pivot lows (Support) using TradingView's built-in functions.
For each detected swing, it draws:

A horizontal line centered on that bar
A label showing "R 1234.56" (above) or "S 1234.56" (below)


Red = Resistance, Green = Support


📊 3. Monthly Volume Profile — Data Collection
This is the heart of the indicator. It tracks volume per price row within each month.
New Month Detection
pineis_new_month = ta.change(time("M")) != 0
When a new month begins:

The previous month's data is saved (prev_high, prev_low, prev_vol[], prev_start)
Current month arrays are reset to zero

Volume Distribution
Each candle's volume is distributed across the price rows it spans:
pinerow_size   = (month_high - month_low) / rows
candle_vol = volume / number_of_rows_spanned
This spreads each candle's volume proportionally across all rows it touches — a simplified but effective TPO-style volume profile.

🎨 4. draw_profile() — The Drawing Function
This function does all the visual work for a given month's data:
Step 1 — Find the POC (Point of Control)
pine// Row with the highest volume = POC
The POC is the price level where the most volume was traded that month.
Step 2 — Calculate Value Area (VAH & VAL)
Starting from the POC, it expands outward (up or down, whichever row has more volume) until 70% of total volume is captured:

VAH = Value Area High (top of the 70% zone)
VAL = Value Area Low (bottom of the 70% zone)

Step 3 — Draw Everything
ElementWhat it isbox (big)The Value Area rectangle (VAL → VAH)box (small, per row)Individual volume bars — wider = more volumePOC rowRed-tinted barValue Area rowsTeal-tinted barsOutside VA rowsGray barsPOC lineRed horizontal line across the monthLabelsVAH, POC, VAL prices on the right edge

🔄 5. When Does It Draw?
pine// Draw PREVIOUS month's profile when a new month starts
if is_new_month and not na(prev_high) ...
    draw_profile(prev_vol, ...)

// Draw CURRENT month's profile (live, updating) on the last bar
if barstate.islast and not na(month_high) ...
    draw_profile(vol_by_row, ..., bar_index + 10)

Past months: drawn once when the month closes ✅
Current month: redrawn live on every new bar, extending slightly to the right (+10 bars) 🔄


🧠 Key Concepts Summary
POC  → Price with most volume = strongest magnet/fair value
VAH  → Top of Value Area → potential resistance
VAL  → Bottom of Value Area → potential support
R/S  → Swing pivot levels for short-term structure
The idea is that price tends to return to the POC and respect VAH/VAL as key zones — combining this with swing levels gives you a layered view of where the market has found value and where it may react.

## Source Code

````pine
//@version=5
indicator("POC MONTHLY + PIVOT", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ─── קלט ─────────────────────────────────────────────────────────────────────
rows      = input.int(48,   "Profile Rows",           minval=10, maxval=100)
va_pct    = input.float(70, "Value Area %",           minval=50, maxval=100)
lookback  = input.int(10,   "R&S Lookback Period",    minval=3)
rs_len    = input.int(8,    "R&S Line Length (bars)", minval=2, maxval=30)

box_col   = input.color(color.new(color.gray, 93),  "Value Area Color")
poc_col   = input.color(color.new(color.red, 40),   "POC Line Color")
va_border = input.color(color.new(color.gray, 70),  "Border Color")
bar_col   = input.color(color.new(color.teal, 70),  "Volume Bar Color")
bar_width = input.float(0.4, "Volume Bar Width", minval=0.1, maxval=1.0, step=0.1)

// ─── R & S ───────────────────────────────────────────────────────────────────
swingHigh = ta.pivothigh(high, lookback, lookback)
swingLow  = ta.pivotlow (low,  lookback, lookback)

if not na(swingHigh)
    line.new(
         x1    = bar_index[lookback] - math.round(rs_len / 2),
         y1    = swingHigh,
         x2    = bar_index[lookback] + math.round(rs_len / 2),
         y2    = swingHigh,
         color = color.new(color.red, 40),
         width = 2)
    label.new(
         x         = bar_index[lookback],
         y         = swingHigh,
         text      = "R " + str.tostring(swingHigh, "#.##"),
         style     = label.style_none,
         textcolor = color.new(color.red, 40),
         size      = size.small,
         yloc      = yloc.abovebar)

if not na(swingLow)
    line.new(
         x1    = bar_index[lookback] - math.round(rs_len / 2),
         y1    = swingLow,
         x2    = bar_index[lookback] + math.round(rs_len / 2),
         y2    = swingLow,
         color = color.new(color.green, 40),
         width = 2)
    label.new(
         x         = bar_index[lookback],
         y         = swingLow,
         text      = "S " + str.tostring(swingLow, "#.##"),
         style     = label.style_none,
         textcolor = color.new(color.green, 40),
         size      = size.small,
         yloc      = yloc.belowbar)

// ─── Volume Profile חודשי ─────────────────────────────────────────────────────
is_new_month = ta.change(time("M")) != 0

var float[] vol_by_row = array.new_float(100, 0.0)
var float   month_high = na
var float   month_low  = na
var int     month_start = na

var float   prev_high  = na
var float   prev_low   = na
var float[] prev_vol   = array.new_float(100, 0.0)
var int     prev_start = na

if is_new_month
    prev_high  := month_high
    prev_low   := month_low
    prev_start := month_start
    for i = 0 to rows - 1
        array.set(prev_vol, i, array.get(vol_by_row, i))
    month_high  := high
    month_low   := low
    month_start := bar_index
    for i = 0 to rows - 1
        array.set(vol_by_row, i, 0.0)

if not na(month_high)
    month_high := math.max(month_high, high)
    month_low  := math.min(month_low,  low)

if not na(month_high) and month_high != month_low
    row_size   = (month_high - month_low) / rows
    candle_vol = volume / math.max(1, math.ceil((high - low) / row_size))
    lo_row     = math.max(0,        math.floor((low  - month_low) / row_size))
    hi_row     = math.min(rows - 1, math.floor((high - month_low) / row_size))
    for i = lo_row to hi_row
        array.set(vol_by_row, i, array.get(vol_by_row, i) + candle_vol)

draw_profile(v_arr, v_high, v_low, v_start, v_end) =>
    r = rows
    row_size = (v_high - v_low) / r
    box_w    = v_end - v_start

    poc_idx = 0
    poc_vol = 0.0
    for i = 0 to r - 1
        v = array.get(v_arr, i)
        if v > poc_vol
            poc_vol := v
            poc_idx := i

    poc_price = v_low + (poc_idx + 0.5) * row_size

    total_vol = 0.0
    for i = 0 to r - 1
        total_vol += array.get(v_arr, i)

    target = total_vol * (va_pct / 100)
    va_vol = poc_vol
    lo_idx = poc_idx
    hi_idx = poc_idx

    for _ = 0 to r * 2
        if va_vol >= target
            break
        add_low  = lo_idx > 0      ? array.get(v_arr, lo_idx - 1) : 0.0
        add_high = hi_idx < r - 1  ? array.get(v_arr, hi_idx + 1) : 0.0
        if add_high >= add_low and hi_idx < r - 1
            hi_idx += 1
            va_vol += add_high
        else if lo_idx > 0
            lo_idx -= 1
            va_vol += add_low
        else
            break

    vah = v_low + (hi_idx + 1) * row_size
    val = v_low + lo_idx * row_size

    box.new(v_start, vah, v_end, val, bgcolor=box_col, border_color=va_border, border_width=1)

    max_bar_w = math.round(box_w * bar_width)
    for i = 0 to r - 1
        row_vol  = array.get(v_arr, i)
        row_bot  = v_low + i * row_size
        row_top  = row_bot + row_size
        scaled_w = math.round(max_bar_w * (row_vol / poc_vol))
        if scaled_w > 0
            b_col = i == poc_idx ? color.new(color.red, 60) :
                     i >= lo_idx and i <= hi_idx ? color.new(color.teal, 75) :
                     color.new(color.gray, 88)
            box.new(v_start, row_top, v_start + scaled_w, row_bot, bgcolor=b_col, border_color=color.new(color.gray, 95), border_width=1)

    line.new(v_start, poc_price, v_end, poc_price, color=color.new(color.red, 40), width=2)

    label.new(v_end, vah,       "VAH " + str.tostring(math.round(vah,       2), "#.##"), style=label.style_none, textcolor=color.new(color.gray, 30), size=size.small)
    label.new(v_end, poc_price, "POC " + str.tostring(math.round(poc_price, 2), "#.##"), style=label.style_none, textcolor=color.new(color.red,  40), size=size.small)
    label.new(v_end, val,       "VAL " + str.tostring(math.round(val,       2), "#.##"), style=label.style_none, textcolor=color.new(color.gray, 30), size=size.small)

if is_new_month and not na(prev_high) and prev_high != prev_low and not na(prev_start)
    draw_profile(prev_vol, prev_high, prev_low, prev_start, bar_index)

if barstate.islast and not na(month_high) and month_high != month_low
    draw_profile(vol_by_row, month_high, month_low, month_start, bar_index + 10)
````
