# PTHLC Previous Timeframe High, Low, and Close

- url: https://www.tradingview.com/script/aExwoRxu-PTHLC-Previous-Timeframe-High-Low-and-Close/
- type: indicator
- pine_id: PUB;2a556badf3174e7ba0fb7bcb8c1564b7
- version: 4.0

## Description

PTHLC — Previous Timeframe High, Low, and Close

PTHLC is a multi-timeframe market-structure indicator that displays the previous completed candle’s high, low, and close from a user-selected timeframe.

Unlike standard previous-day indicators, PTHLC can be applied to intraday or higher timeframes, making it useful for tracking levels from the previous 15-minute, 1-hour, 4-hour, daily, or other selected candle.

Major Features

Previous Timeframe Levels

The indicator plots:

PTH — Previous Timeframe High
PTL — Previous Timeframe Low
PTC — Previous Timeframe Close

The levels are based on the previous fully completed candle to provide stable, non-repainting reference points.

Automatic Timeframe Adjustment

When the selected reference timeframe is lower than the chart timeframe, the indicator automatically uses the chart timeframe instead of producing an error.

This allows the script to remain active as traders move between chart timeframes.

Confirmed Breach Detection

PTH and PTL are considered breached only after price closes beyond the level.

A close above PTH confirms a high breach.
A close below PTL confirms a low breach.

Breached levels are visually distinguished from active levels.

Bullish and Bearish Retest Logic

After a confirmed breach, PTHLC tracks the first return to the level.

A retest that closes above the level is classified as Retest Bullish.
A retest that closes below the level is classified as Retest Bearish.

The line, label, and table status update to reflect the retest direction.

Directional Previous Close

PTC provides immediate directional context:

Bullish when price is above PTC
Bearish when price is below PTC
Neutral when price is at PTC

PTC logic remains separate from the breach and retest logic used for PTH and PTL.

What Makes PTHLC Unique

Most previous-level indicators only plot static support and resistance lines.

PTHLC adds a complete level-state framework:

Active → Breached → Bullish or Bearish Retest

This helps traders quickly identify whether a previous timeframe level is untouched, broken, successfully held, or rejected after a retest.

PTHLC is designed for traders who use multi-timeframe structure, liquidity levels, breakout confirmation, support-and-resistance flips, and retest-based directional bias.

This indicator is intended as a market-analysis tool and does not provide guaranteed trade signals.

## Source Code

````pine
//@version=6

indicator(title="PTHLC — Previous Timeframe High, Low, and Close", shorttitle="PTHLC", overlay=true)

// ══════════════════════════════════════════════

//   SETTINGS / INPUTS

// ══════════════════════════════════════════════

grp_timeframe = "Reference Timeframe"

auto_htf = input.bool(true, "Auto Higher Timeframe", group=grp_timeframe,

     tooltip="Automatically uses a higher reference timeframe based on the chart: below 5m → 5m, 5m to below 15m → 15m, 15m to below 1H → 1H, 1H to below 4H → 4H, 4H to below 1D → 1D, 1D to below 1W → 1W, and 1W to below 1M → 1M.")

reference_tf = input.timeframe("60", "Manual Previous Candle Timeframe", group=grp_timeframe,

     tooltip="Used only when Auto Higher Timeframe is disabled, or when the chart timeframe is monthly or higher.")

grp_colors = "PTC Colors"

col_ptc_bull = input.color(color.new(color.green, 0), "PTC Bullish Color", group=grp_colors)

col_ptc_bear = input.color(color.new(color.red, 0), "PTC Bearish Color", group=grp_colors)

col_ptc_neut = input.color(color.new(color.gray, 0), "PTC Neutral Color", group=grp_colors)

grp_hl_colors = "PTH / PTL Colors"

col_hl_active = input.color(color.new(color.gray, 0), "Active Level Color", group=grp_hl_colors)

col_pth_breached = input.color(color.new(color.green, 0), "PTH Bullish Breach Color", group=grp_hl_colors,

     tooltip="After either level has been breached, this color is used while price is above that level.")

col_ptl_breached = input.color(color.new(color.red, 0), "PTL Bearish Breach Color", group=grp_hl_colors,

     tooltip="After either level has been breached, this color is used while price is below that level.")

grp_lines = "Line Style"

lw = input.int(1, "Line Width", minval=1, maxval=4, group=grp_lines)

ls = input.string("─────", "Line Style",

     options=["─────", "- - -", "·····"], group=grp_lines)

grp_labels = "Labels"

show_labels = input.bool(true, "Show Labels", group=grp_labels)

label_size = input.string("Normal", "Label Size",

     options=["Small", "Normal", "Large"], group=grp_labels)

label_offset = input.int(7, "Label Offset from Current Bar", minval=0, maxval=500, group=grp_labels,

     tooltip="Moves the labels this many bars to the right of the current bar. Each line ends exactly at its label.")

grp_table = "Table"

table_location = input.string("Top Right", "Table Location",

     options=["Top Left", "Top Center", "Top Right",

              "Middle Left", "Middle Center", "Middle Right",

              "Bottom Left", "Bottom Center", "Bottom Right"],

     group=grp_table)

table_size = input.string("Small", "Table Size",

     options=["Tiny", "Small", "Normal", "Large", "Huge"],

     group=grp_table)

// ══════════════════════════════════════════════

//   HELPERS

// ══════════════════════════════════════════════

f_style() =>

    ls == "- - -" ? line.style_dashed :

     ls == "·····" ? line.style_dotted :

     line.style_solid

f_lsize() =>

    label_size == "Small" ? size.small :

     label_size == "Large" ? size.large :

     size.normal

f_table_position() =>

    table_location == "Top Left" ? position.top_left :

     table_location == "Top Center" ? position.top_center :

     table_location == "Top Right" ? position.top_right :

     table_location == "Middle Left" ? position.middle_left :

     table_location == "Middle Center" ? position.middle_center :

     table_location == "Middle Right" ? position.middle_right :

     table_location == "Bottom Left" ? position.bottom_left :

     table_location == "Bottom Center" ? position.bottom_center :

     position.bottom_right

f_table_size() =>

    table_size == "Tiny" ? size.tiny :

     table_size == "Small" ? size.small :

     table_size == "Normal" ? size.normal :

     table_size == "Large" ? size.large :

     size.huge

f_line(float price, color col, int start_bar, int end_bar, line_style) =>

    line.new(

         x1     = start_bar,

         y1     = price,

         x2     = end_bar,

         y2     = price,

         color  = col,

         width  = lw,

         style  = line_style,

         extend = extend.none)

f_label(float price, string txt, color col, int label_bar) =>

    label.new(

         x         = label_bar,

         y         = price,

         text      = txt,

         color     = color.new(col, 85),

         textcolor = col,

         style     = label.style_label_left,

         size      = f_lsize())

// ══════════════════════════════════════════════

//   EFFECTIVE REFERENCE TIMEFRAME

//   Auto mode always selects a higher structural timeframe for supported

//   intraday, daily, and weekly chart timeframes. Monthly and higher charts

//   use the manual selection.

// ══════════════════════════════════════════════

chart_seconds = timeframe.in_seconds()

month_seconds = timeframe.in_seconds("M")

auto_mapped_tf = na(chart_seconds) ? reference_tf :

     chart_seconds < timeframe.in_seconds("5")   ? "5"   :

     chart_seconds < timeframe.in_seconds("15")  ? "15"  :

     chart_seconds < timeframe.in_seconds("60")  ? "60"  :

     chart_seconds < timeframe.in_seconds("240") ? "240" :

     chart_seconds < timeframe.in_seconds("D")   ? "D"   :

     chart_seconds < timeframe.in_seconds("W")   ? "W"   :

     chart_seconds < month_seconds                ? "M"   :

     reference_tf

auto_mapping_active = auto_htf and not na(chart_seconds) and chart_seconds < month_seconds

effective_tf = auto_mapping_active ? auto_mapped_tf : reference_tf

effective_tf_status = auto_mapping_active ? "Auto HTF" : "Manual TF"

f_tf_label(string tf) =>

    tf == "60"  ? "1H" :

     tf == "120" ? "2H" :

     tf == "180" ? "3H" :

     tf == "240" ? "4H" :

     tf == "D"   ? "1D" :

     tf == "W"   ? "1W" :

     tf == "M"   ? "1M" :

     not na(str.tonumber(tf)) ? tf + "m" : tf

effective_tf_label = f_tf_label(effective_tf)

// ══════════════════════════════════════════════

//   STANDARD MARKET DATA

//   Use actual market OHLC even when the chart uses Heikin Ashi or another

//   synthetic chart type. Previous levels remain confirmed and non-repainting.

// ══════════════════════════════════════════════

standard_ticker = ticker.standard(syminfo.tickerid)

[prev_high, prev_low, prev_close] = request.security(

     standard_ticker,

     effective_tf,

     [high[1], low[1], close[1]],

     gaps      = barmerge.gaps_off,

     lookahead = barmerge.lookahead_on)

[market_high, market_low, market_close] = request.security(

     standard_ticker,

     timeframe.period,

     [high, low, close],

     gaps      = barmerge.gaps_off,

     lookahead = barmerge.lookahead_off)

reference_open_time = time(effective_tf)

is_new_reference_period = barstate.isfirst or ta.change(reference_open_time) != 0

// ══════════════════════════════════════════════

//   PERSISTENT VALUES

// ══════════════════════════════════════════════

var int period_start_bar = na

var bool pth_breached = false

var bool ptl_breached = false

if is_new_reference_period

    period_start_bar := bar_index

    pth_breached := false

    ptl_breached := false

// Breach detection uses standard-market wicks, including the live bar.

// High/low retain a sweep after price retraces, including intrabar rollback.

// Once breached, the state remains active until the next reference period.

if not pth_breached and not na(prev_high) and market_high > prev_high

    pth_breached := true

if not ptl_breached and not na(prev_low) and market_low < prev_low

    ptl_breached := true

// ══════════════════════════════════════════════

//   PTC BULLISH / BEARISH LOGIC

// ══════════════════════════════════════════════

ptc_bullish = not na(prev_close) and market_close > prev_close

ptc_bearish = not na(prev_close) and market_close < prev_close

ptc_color = ptc_bullish ? col_ptc_bull :

     ptc_bearish ? col_ptc_bear :

     col_ptc_neut

ptc_status = ptc_bullish ? "Bullish" :

     ptc_bearish ? "Bearish" :

     "Neutral"

pth_status = pth_breached ? "Breached" : "Active"

ptl_status = ptl_breached ? "Breached" : "Active"

// Before a recorded breach, both levels remain active gray.

// After a level has been breached, its color follows price dynamically:

// above the level = bullish green, below the level = bearish red,

// exactly at the level = active gray.

pth_display_color = not pth_breached ? col_hl_active :

     market_close > prev_high ? col_pth_breached :

     market_close < prev_high ? col_ptl_breached :

     col_hl_active

ptl_display_color = not ptl_breached ? col_hl_active :

     market_close > prev_low ? col_pth_breached :

     market_close < prev_low ? col_ptl_breached :

     col_hl_active

pth_label_suffix = pth_breached ? " Breached" : ""

ptl_label_suffix = ptl_breached ? " Breached" : ""

// ══════════════════════════════════════════════

//   DRAW LINES AND LABELS

//   Lines begin at the open of the current effective timeframe

//   and end exactly at their labels.

// ══════════════════════════════════════════════

var line ln_h = na

var line ln_l = na

var line ln_c = na

var label lb_h = na

var label lb_l = na

var label lb_c = na

label_bar = bar_index + label_offset

pth_line_style = pth_breached ? line.style_dashed : f_style()

ptl_line_style = ptl_breached ? line.style_dashed : f_style()

if is_new_reference_period and not na(prev_close) and not na(prev_high) and not na(prev_low) and not na(period_start_bar)

    line.delete(ln_h)

    line.delete(ln_l)

    line.delete(ln_c)

    label.delete(lb_h)

    label.delete(lb_l)

    label.delete(lb_c)

    ln_h := f_line(prev_high, pth_display_color, period_start_bar, label_bar, pth_line_style)

    ln_l := f_line(prev_low, ptl_display_color, period_start_bar, label_bar, ptl_line_style)

    ln_c := f_line(prev_close, ptc_color, period_start_bar, label_bar, f_style())

    if show_labels

        lb_h := f_label(prev_high, "PTH " + str.tostring(prev_high, format.mintick), pth_display_color, label_bar)

        lb_l := f_label(prev_low, "PTL " + str.tostring(prev_low, format.mintick), ptl_display_color, label_bar)

        lb_c := f_label(prev_close, "PTC " + str.tostring(prev_close, format.mintick) + " " + ptc_status + " " + effective_tf_label, ptc_color, label_bar)

// Delete labels immediately when labels are disabled.

if not show_labels

    label.delete(lb_h)

    label.delete(lb_l)

    label.delete(lb_c)

    lb_h := na

    lb_l := na

    lb_c := na

// Recreate labels when labels are enabled during an active reference period.

if show_labels

    if na(lb_h) and not na(prev_high)

        lb_h := f_label(prev_high, "PTH " + str.tostring(prev_high, format.mintick), pth_display_color, label_bar)

    if na(lb_l) and not na(prev_low)

        lb_l := f_label(prev_low, "PTL " + str.tostring(prev_low, format.mintick), ptl_display_color, label_bar)

    if na(lb_c) and not na(prev_close)

        lb_c := f_label(prev_close, "PTC " + str.tostring(prev_close, format.mintick) + " " + ptc_status + " " + effective_tf_label, ptc_color, label_bar)

// Keep every line anchored to the open of the current reference period.

// The right endpoint is exactly the label location, with no extension beyond it.

if not na(ln_h) and not na(period_start_bar)

    line.set_x1(ln_h, period_start_bar)

    line.set_y1(ln_h, prev_high)

    line.set_x2(ln_h, label_bar)

    line.set_y2(ln_h, prev_high)

    line.set_color(ln_h, pth_display_color)

    line.set_width(ln_h, lw)

    line.set_style(ln_h, pth_line_style)

    line.set_extend(ln_h, extend.none)

if not na(ln_l) and not na(period_start_bar)

    line.set_x1(ln_l, period_start_bar)

    line.set_y1(ln_l, prev_low)

    line.set_x2(ln_l, label_bar)

    line.set_y2(ln_l, prev_low)

    line.set_color(ln_l, ptl_display_color)

    line.set_width(ln_l, lw)

    line.set_style(ln_l, ptl_line_style)

    line.set_extend(ln_l, extend.none)

if not na(ln_c) and not na(period_start_bar)

    line.set_x1(ln_c, period_start_bar)

    line.set_y1(ln_c, prev_close)

    line.set_x2(ln_c, label_bar)

    line.set_y2(ln_c, prev_close)

    line.set_color(ln_c, ptc_color)

    line.set_width(ln_c, lw)

    line.set_style(ln_c, f_style())

    line.set_extend(ln_c, extend.none)

// Update labels.

if show_labels and not na(lb_h)

    label.set_x(lb_h, label_bar)

    label.set_y(lb_h, prev_high)

    label.set_size(lb_h, f_lsize())

    label.set_textcolor(lb_h, pth_display_color)

    label.set_color(lb_h, color.new(pth_display_color, 85))

    label.set_text(lb_h, "PTH " + str.tostring(prev_high, format.mintick) + pth_label_suffix)

if show_labels and not na(lb_l)

    label.set_x(lb_l, label_bar)

    label.set_y(lb_l, prev_low)

    label.set_size(lb_l, f_lsize())

    label.set_textcolor(lb_l, ptl_display_color)

    label.set_color(lb_l, color.new(ptl_display_color, 85))

    label.set_text(lb_l, "PTL " + str.tostring(prev_low, format.mintick) + ptl_label_suffix)

if show_labels and not na(lb_c)

    label.set_x(lb_c, label_bar)

    label.set_y(lb_c, prev_close)

    label.set_size(lb_c, f_lsize())

    label.set_textcolor(lb_c, ptc_color)

    label.set_color(lb_c, color.new(ptc_color, 85))

    label.set_text(lb_c, "PTC " + str.tostring(prev_close, format.mintick) + " " + ptc_status + " " + effective_tf_label)

// ══════════════════════════════════════════════

//   INFO TABLE

// ══════════════════════════════════════════════

var table info = table.new(

     position     = f_table_position(),

     columns      = 3,

     rows         = 5,

     border_width = 1,

     border_color = color.new(color.gray, 60),

     bgcolor      = color.new(color.black, 75))

if barstate.islast and not na(prev_close)

    table.cell(info, 0, 0, "Level", text_color=color.white, text_size=f_table_size(), bgcolor=color.new(color.gray, 60))

    table.cell(info, 1, 0, "Price", text_color=color.white, text_size=f_table_size(), bgcolor=color.new(color.gray, 60))

    table.cell(info, 2, 0, "Status", text_color=color.white, text_size=f_table_size(), bgcolor=color.new(color.gray, 60))

    table.cell(info, 0, 1, "PTH", text_color=pth_display_color, text_size=f_table_size())

    table.cell(info, 1, 1, str.tostring(prev_high, format.mintick), text_color=pth_display_color, text_size=f_table_size())

    table.cell(info, 2, 1, pth_status, text_color=color.white, text_size=f_table_size(), bgcolor=color.new(pth_display_color, 20))

    table.cell(info, 0, 3, "PTL", text_color=ptl_display_color, text_size=f_table_size())

    table.cell(info, 1, 3, str.tostring(prev_low, format.mintick), text_color=ptl_display_color, text_size=f_table_size())

    table.cell(info, 2, 3, ptl_status, text_color=color.white, text_size=f_table_size(), bgcolor=color.new(ptl_display_color, 20))

    table.cell(info, 0, 2, "PTC", text_color=ptc_color, text_size=f_table_size())

    table.cell(info, 1, 2, str.tostring(prev_close, format.mintick), text_color=ptc_color, text_size=f_table_size())

    table.cell(info, 2, 2, ptc_status, text_color=color.white, text_size=f_table_size(), bgcolor=color.new(ptc_color, 20))

    table.cell(info, 0, 4, "TF", text_color=color.white, text_size=f_table_size())

    table.cell(info, 1, 4, effective_tf, text_color=color.white, text_size=f_table_size())

    table.cell(info, 2, 4, effective_tf_status, text_color=color.white, text_size=f_table_size(),

         bgcolor=auto_mapping_active ? color.new(color.orange, 20) : color.new(color.gray, 60))
````
