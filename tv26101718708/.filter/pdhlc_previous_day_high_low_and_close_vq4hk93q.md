# PDHLC Previous Day High, Low, and Close

- url: https://www.tradingview.com/script/VQ4HK93q-PDHLC-Previous-Day-High-Low-and-Close/
- type: indicator
- pine_id: PUB;c3fe371819944b29b38040a2aef0f2a1
- version: 1.0

## Description

## PDHLC — Previous Day High, Low, and Close

PDHLC is a customizable market-reference indicator that displays the previous trading day’s high, low, and close.

It was designed primarily for futures traders, but the user-defined trading-day start time allows it to be adapted to different instruments, sessions, and trading methodologies.

The indicator tracks three key reference levels:

* **PDH — Previous Day High**
* **PDL — Previous Day Low**
* **PDC — Previous Day Close**

## Key Features

### Custom Trading-Day Start Time

Users can define exactly when a new trading day begins using Eastern Time.

The default setting is:

* **6:00 PM ET**
* **18:00 using the 24-hour clock**

This matches the standard futures-session rollover used by many CME futures markets.

The start hour and minute can be changed independently, allowing the indicator to support:

* Different futures sessions
* Regular trading hours
* Overnight sessions
* Custom trading plans
* Non-futures instruments

The new trading day begins on the first chart bar at or after the selected start time.

### Previous Day High and Low

PDHLC calculates and displays the completed prior trading day’s:

* Highest traded price
* Lowest traded price
* Closing price

Each line begins at the opening bar of the current user-defined trading day.

### Confirmed PDH and PDL Breaches

PDH and PDL are not considered breached merely because price trades through them intrabar.

A confirmed breach requires:

* A candle close above PDH
* A candle close below PDL

Once a breach is confirmed, the corresponding line automatically changes to a dashed style for the remainder of the trading day.

This creates an immediate visual distinction between:

* Active, unbreached liquidity levels
* Levels that have already been closed through

The breach status resets when the next user-defined trading day begins.

### Directional PDC Coloring

The Previous Day Close dynamically changes color based on the current price relationship to PDC:

* **Bullish:** Price is above PDC
* **Bearish:** Price is below PDC
* **Neutral:** Price is equal to PDC

Bullish, bearish, and neutral PDC colors can be configured independently.

The original PDC directional logic remains separate from the PDH and PDL breach logic.

### Customizable Labels

Users can control:

* Label visibility
* Label size
* Label offset from the current bar

Available label sizes include:

* Small
* Normal
* Large

### Customizable Information Table

The built-in information table displays the current value and status of each level:

* **PDH:** Active or Breached
* **PDL:** Active or Breached
* **PDC:** Bullish, Bearish, or Neutral

## Why PDHLC Is Unique

Many previous-day indicators rely on fixed calendar days, automatically extend lines across the chart, or treat any temporary move beyond a level as a confirmed breakout.

PDHLC is different because it combines:

* A fully customizable trading-day start time
* A futures-compatible default of 6:00 PM ET
* Candle-close confirmation for PDH and PDL breaches
* Automatic dashed styling after confirmed breaches
* Separate directional logic for PDC
* Lines that begin at the current trading-day open
* Lines that end exactly at their labels
* Adjustable label distance from current price
* Fully customizable table size and location

This makes PDHLC useful for traders who incorporate previous-day liquidity, session structure, breakout confirmation, directional bias, and daily reference levels into their analysis.

## Intended Use

PDHLC can be used to identify:

* Previous-day liquidity targets
* Potential support and resistance
* Confirmed high or low breaks
* Current price location relative to the prior close
* Daily directional context
* Untouched versus breached prior-day levels

This indicator does not generate trade-entry signals and does not guarantee future results. It is intended as a market-structure, session-reference, and discretionary trading-analysis tool.

## Source Code

````pine
//@version=6
indicator(title="PDHLC", shorttitle="PDHLC", overlay=true)

// ══════════════════════════════════════════════
//   SETTINGS / INPUTS
// ══════════════════════════════════════════════
grp_colors = "PDC Colors"
col_pdc_bull = input.color(color.new(color.green, 0), "PDC Bullish Color", group=grp_colors)
col_pdc_bear = input.color(color.new(color.red, 0), "PDC Bearish Color", group=grp_colors)
col_pdc_neut = input.color(color.new(color.gray, 0), "PDC Neutral Color", group=grp_colors)

grp_trading_day = "Trading Day"
trading_day_start_hour = input.int(18, "Start Hour (ET)", minval=0, maxval=23, group=grp_trading_day,
     tooltip="Hour when the trading day begins, using Eastern Time and a 24-hour clock. Default 18 = 6:00 PM ET.")
trading_day_start_minute = input.int(0, "Start Minute", minval=0, maxval=59, group=grp_trading_day,
     tooltip="Minute when the trading day begins. The new day starts on the first chart bar at or after this time.")

grp_hl_colors = "PDH / PDL Colors"
col_pdh = input.color(color.new(color.green, 0), "PDH Color", group=grp_hl_colors)
col_pdl = input.color(color.new(color.red, 0), "PDL Color", group=grp_hl_colors)

grp_lines = "Line Style"
lw = input.int(1, "Line Width", minval=1, maxval=4, group=grp_lines)
ls = input.string("─────", "Line Style",
     options=["─────","- - -","·····"], group=grp_lines)

grp_labels = "Labels"
show_labels = input.bool(true, "Show Labels", group=grp_labels)
label_size  = input.string("Normal", "Label Size",
     options=["Small","Normal","Large"], group=grp_labels)
label_offset = input.int(1, "Label Offset from Current Bar", minval=0, maxval=500, group=grp_labels,
     tooltip="Moves the labels this many bars to the right of the current bar. Each line ends exactly at its label.")

grp_table = "Table"
table_location = input.string("Top Right", "Table Location",
     options=["Top Left","Top Center","Top Right",
              "Middle Left","Middle Center","Middle Right",
              "Bottom Left","Bottom Center","Bottom Right"],
     group=grp_table)
table_size = input.string("Small", "Table Size",
     options=["Tiny","Small","Normal","Large","Huge"],
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
//   USER-DEFINED TRADING DAY LOGIC
//   The default remains 6:00 PM Eastern Time.
// ══════════════════════════════════════════════
et_tz = "America/New_York"
ms_in_day = 24 * 60 * 60 * 1000

f_futures_day_id() =>
    y = year(time, et_tz)
    m = month(time, et_tz)
    d = dayofmonth(time, et_tz)
    current_minutes = hour(time, et_tz) * 60 + minute(time, et_tz)
    start_minutes = trading_day_start_hour * 60 + trading_day_start_minute
    calendar_day_start = timestamp(et_tz, y, m, d, 0, 0)
    current_minutes >= start_minutes ? calendar_day_start + ms_in_day : calendar_day_start

futures_day_id = f_futures_day_id()
is_new_futures_day = timeframe.isintraday and (barstate.isfirst or futures_day_id != futures_day_id[1])

// ══════════════════════════════════════════════
//   PERSISTENT VALUES
// ══════════════════════════════════════════════
var float val_high  = na
var float val_low   = na
var float val_close = na
var int   day_start_bar = na

var float active_day_high = na
var float active_day_low  = na

var bool pdh_breached = false
var bool pdl_breached = false

// Build each futures day's high and low. At the first bar of a new futures
// day, preserve the completed prior day's high, low, and close.
if barstate.isfirst
    active_day_high := high
    active_day_low  := low
else if is_new_futures_day
    val_high      := active_day_high
    val_low       := active_day_low
    val_close     := close[1]
    day_start_bar := bar_index

    active_day_high := high
    active_day_low  := low

    pdh_breached := false
    pdl_breached := false
else
    active_day_high := na(active_day_high) ? high : math.max(active_day_high, high)
    active_day_low  := na(active_day_low)  ? low  : math.min(active_day_low, low)

// A PDH/PDL breach requires a candle close beyond the level.
// Once breached, the state remains active until the next futures day.
if not na(val_high) and close > val_high
    pdh_breached := true

if not na(val_low) and close < val_low
    pdl_breached := true

// ══════════════════════════════════════════════
//   PDC BULLISH / BEARISH LOGIC
//   Original logic and colors are unchanged.
// ══════════════════════════════════════════════
pdc_bullish = not na(val_close) and close > val_close
pdc_bearish = not na(val_close) and close < val_close

pdc_color = pdc_bullish ? col_pdc_bull :
     pdc_bearish ? col_pdc_bear :
     col_pdc_neut

pdc_status = pdc_bullish ? "Bullish" :
     pdc_bearish ? "Bearish" :
     "Neutral"

pdh_status = pdh_breached ? "Breached" : "Active"
pdl_status = pdl_breached ? "Breached" : "Active"

// ══════════════════════════════════════════════
//   DRAW LINES AND LABELS
//   Lines begin at the current futures-day open and end at their labels.
// ══════════════════════════════════════════════
var line  ln_h = na
var line  ln_l = na
var line  ln_c = na
var label lb_h = na
var label lb_l = na
var label lb_c = na

label_bar = bar_index + label_offset
pdh_line_style = pdh_breached ? line.style_dashed : f_style()
pdl_line_style = pdl_breached ? line.style_dashed : f_style()

if is_new_futures_day and not na(val_close) and not na(val_high) and not na(val_low) and not na(day_start_bar)
    line.delete(ln_h)
    line.delete(ln_l)
    line.delete(ln_c)
    label.delete(lb_h)
    label.delete(lb_l)
    label.delete(lb_c)

    ln_h := f_line(val_high,  col_pdh,    day_start_bar, label_bar, pdh_line_style)
    ln_l := f_line(val_low,   col_pdl,    day_start_bar, label_bar, pdl_line_style)
    ln_c := f_line(val_close, pdc_color,  day_start_bar, label_bar, f_style())

    if show_labels
        lb_h := f_label(val_high,  "PDH " + str.tostring(val_high,  format.mintick), col_pdh,   label_bar)
        lb_l := f_label(val_low,   "PDL " + str.tostring(val_low,   format.mintick), col_pdl,   label_bar)
        lb_c := f_label(val_close, "PDC " + str.tostring(val_close, format.mintick), pdc_color, label_bar)

// Delete labels immediately when labels are disabled.
if not show_labels
    label.delete(lb_h)
    label.delete(lb_l)
    label.delete(lb_c)
    lb_h := na
    lb_l := na
    lb_c := na

// Recreate labels when labels are enabled during an active futures day.
if show_labels
    if na(lb_h) and not na(val_high)
        lb_h := f_label(val_high, "PDH " + str.tostring(val_high, format.mintick), col_pdh, label_bar)
    if na(lb_l) and not na(val_low)
        lb_l := f_label(val_low, "PDL " + str.tostring(val_low, format.mintick), col_pdl, label_bar)
    if na(lb_c) and not na(val_close)
        lb_c := f_label(val_close, "PDC " + str.tostring(val_close, format.mintick), pdc_color, label_bar)

// Keep every line anchored to the open of the current futures day.
// The right endpoint is exactly the label location, with no extension beyond it.
if not na(ln_h) and not na(day_start_bar)
    line.set_x1(ln_h, day_start_bar)
    line.set_y1(ln_h, val_high)
    line.set_x2(ln_h, label_bar)
    line.set_y2(ln_h, val_high)
    line.set_color(ln_h, col_pdh)
    line.set_width(ln_h, lw)
    line.set_style(ln_h, pdh_line_style)
    line.set_extend(ln_h, extend.none)

if not na(ln_l) and not na(day_start_bar)
    line.set_x1(ln_l, day_start_bar)
    line.set_y1(ln_l, val_low)
    line.set_x2(ln_l, label_bar)
    line.set_y2(ln_l, val_low)
    line.set_color(ln_l, col_pdl)
    line.set_width(ln_l, lw)
    line.set_style(ln_l, pdl_line_style)
    line.set_extend(ln_l, extend.none)

if not na(ln_c) and not na(day_start_bar)
    line.set_x1(ln_c, day_start_bar)
    line.set_y1(ln_c, val_close)
    line.set_x2(ln_c, label_bar)
    line.set_y2(ln_c, val_close)
    line.set_color(ln_c, pdc_color)
    line.set_width(ln_c, lw)
    line.set_style(ln_c, f_style())
    line.set_extend(ln_c, extend.none)

// Update labels.
if show_labels and not na(lb_h)
    label.set_x(lb_h, label_bar)
    label.set_y(lb_h, val_high)
    label.set_size(lb_h, f_lsize())
    label.set_textcolor(lb_h, col_pdh)
    label.set_color(lb_h, color.new(col_pdh, 85))
    label.set_text(lb_h, "PDH " + str.tostring(val_high, format.mintick) + (pdh_breached ? " Breached" : ""))

if show_labels and not na(lb_l)
    label.set_x(lb_l, label_bar)
    label.set_y(lb_l, val_low)
    label.set_size(lb_l, f_lsize())
    label.set_textcolor(lb_l, col_pdl)
    label.set_color(lb_l, color.new(col_pdl, 85))
    label.set_text(lb_l, "PDL " + str.tostring(val_low, format.mintick) + (pdl_breached ? " Breached" : ""))

if show_labels and not na(lb_c)
    label.set_x(lb_c, label_bar)
    label.set_y(lb_c, val_close)
    label.set_size(lb_c, f_lsize())
    label.set_textcolor(lb_c, pdc_color)
    label.set_color(lb_c, color.new(pdc_color, 85))
    label.set_text(lb_c, "PDC " + str.tostring(val_close, format.mintick) + " " + pdc_status)

// ══════════════════════════════════════════════
//   INFO TABLE
// ══════════════════════════════════════════════
var table info = table.new(
     position     = f_table_position(),
     columns      = 3,
     rows         = 4,
     border_width = 1,
     border_color = color.new(color.gray, 60),
     bgcolor      = color.new(color.black, 75))

if barstate.islast and not na(val_close)
    table.cell(info, 0, 0, "Level",  text_color=color.white, text_size=f_table_size(), bgcolor=color.new(color.gray, 60))
    table.cell(info, 1, 0, "Price",  text_color=color.white, text_size=f_table_size(), bgcolor=color.new(color.gray, 60))
    table.cell(info, 2, 0, "Status", text_color=color.white, text_size=f_table_size(), bgcolor=color.new(color.gray, 60))

    table.cell(info, 0, 1, "PDH", text_color=col_pdh, text_size=f_table_size())
    table.cell(info, 1, 1, str.tostring(val_high, format.mintick), text_color=col_pdh, text_size=f_table_size())
    table.cell(info, 2, 1, pdh_status, text_color=color.white, text_size=f_table_size(), bgcolor=color.new(col_pdh, 20))

    table.cell(info, 0, 2, "PDL", text_color=col_pdl, text_size=f_table_size())
    table.cell(info, 1, 2, str.tostring(val_low, format.mintick), text_color=col_pdl, text_size=f_table_size())
    table.cell(info, 2, 2, pdl_status, text_color=color.white, text_size=f_table_size(), bgcolor=color.new(col_pdl, 20))

    table.cell(info, 0, 3, "PDC", text_color=pdc_color, text_size=f_table_size())
    table.cell(info, 1, 3, str.tostring(val_close, format.mintick), text_color=pdc_color, text_size=f_table_size())
    table.cell(info, 2, 3, pdc_status, text_color=color.white, text_size=f_table_size(), bgcolor=color.new(pdc_color, 20))
````
