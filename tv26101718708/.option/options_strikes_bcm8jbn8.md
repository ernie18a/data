# Options Strikes

- url: https://www.tradingview.com/script/BCM8JBN8-Options-Strikes/
- type: indicator
- pine_id: PUB;6674330f90424ff2b2ef9f609c5e950e
- version: 1.0

## Description

● Title: Options Strikes

Short description:                                                                                                      
Visualize your open options positions on any chart — horizontal lines from entry to expiration, color-coded by Put/Call. 
                                                                                                            
  ---

Full description:
Track up to 8 options contracts directly on your price chart. Each contract draws a horizontal line from your open date to the expiration date (4:00 PM ET), so you always see where your strikes sit relative to price and how much time is left.

Features
  - Up to 8 contracts simultaneously — Put and Call
  - Lines run from your open date to 4:00 PM ET on expiration day
  - Puts in red, Calls in blue (colors and opacity customizable)
  - Compact label at the end of each line: 610 P  May 1
  - Labels can be toggled on/off
  - Calendar pickers for both Open date and Expiration date
  - Auto-enable — a contract activates as soon as you enter a Strike value; set Strike to 0 to disable it
  - Ticker filter — set a symbol (e.g. META) so lines only appear on that specific chart, useful when switching between
  tickers
  - Works on any symbol and any timeframe

  How to use
  1. Add the indicator to your chart
  2. Open Settings → Inputs
  3. For each contract: enter a Strike, select Type (Put/Call), pick Open date and Exp date
  4. The line appears automatically — no need to toggle anything
  5. Optionally set the Ticker field to lock this instance to a specific symbol

  Tips
  - Leave Ticker blank → lines show on every chart
  - Open date defaults to today — change it only if you entered the position on a previous day
  - To remove a contract, set its Strike back to 0
  - Use contracts 5–8 for additional positions
  - Adjust colors and line width in the Style group

## Source Code

````pine
//@version=6
indicator("Options Strikes", overlay=true, max_lines_count=16, max_labels_count=16)

// ─── Style ────────────────────────────────────────────────────────────────────
col_put       = input.color(color.new(color.red,  50), "Put color",            group="Style")
col_call      = input.color(color.new(color.blue, 50), "Call color",           group="Style")
lw            = input.int(1, "Line width",               group="Style", minval=1, maxval=4)
show_labels   = input.bool(true, "Show labels",          group="Style")
ticker_filter = input.string("", "Ticker (blank = any)", group="Style", tooltip="e.g. META, SPY — lines only appear when this ticker is on chart")

// ─── Contract 1 ───────────────────────────────────────────────────────────────
c1_k     = input.float(0,     "Strike",    group="Contract 1", step=0.5, minval=0)
c1_t     = input.string("Put","Type",      options=["Put","Call"], group="Contract 1")
c1_start = input.time(1776859200000, "Open date", group="Contract 1")
c1_exp   = input.time(1776859200000, "Exp date",  group="Contract 1")

// ─── Contract 2 ───────────────────────────────────────────────────────────────
c2_k     = input.float(0,     "Strike",    group="Contract 2", step=0.5, minval=0)
c2_t     = input.string("Put","Type",      options=["Put","Call"], group="Contract 2")
c2_start = input.time(1776859200000, "Open date", group="Contract 2")
c2_exp   = input.time(1776859200000, "Exp date",  group="Contract 2")

// ─── Contract 3 ───────────────────────────────────────────────────────────────
c3_k     = input.float(0,     "Strike",    group="Contract 3", step=0.5, minval=0)
c3_t     = input.string("Put","Type",      options=["Put","Call"], group="Contract 3")
c3_start = input.time(1776859200000, "Open date", group="Contract 3")
c3_exp   = input.time(1776859200000, "Exp date",  group="Contract 3")

// ─── Contract 4 ───────────────────────────────────────────────────────────────
c4_k     = input.float(0,     "Strike",    group="Contract 4", step=0.5, minval=0)
c4_t     = input.string("Put","Type",      options=["Put","Call"], group="Contract 4")
c4_start = input.time(1776859200000, "Open date", group="Contract 4")
c4_exp   = input.time(1776859200000, "Exp date",  group="Contract 4")

// ─── Contract 5 ───────────────────────────────────────────────────────────────
c5_k     = input.float(0,     "Strike",    group="Contract 5", step=0.5, minval=0)
c5_t     = input.string("Put","Type",      options=["Put","Call"], group="Contract 5")
c5_start = input.time(1776859200000, "Open date", group="Contract 5")
c5_exp   = input.time(1776859200000, "Exp date",  group="Contract 5")

// ─── Contract 6 ───────────────────────────────────────────────────────────────
c6_k     = input.float(0,     "Strike",    group="Contract 6", step=0.5, minval=0)
c6_t     = input.string("Put","Type",      options=["Put","Call"], group="Contract 6")
c6_start = input.time(1776859200000, "Open date", group="Contract 6")
c6_exp   = input.time(1776859200000, "Exp date",  group="Contract 6")

// ─── Contract 7 ───────────────────────────────────────────────────────────────
c7_k     = input.float(0,     "Strike",    group="Contract 7", step=0.5, minval=0)
c7_t     = input.string("Put","Type",      options=["Put","Call"], group="Contract 7")
c7_start = input.time(1776859200000, "Open date", group="Contract 7")
c7_exp   = input.time(1776859200000, "Exp date",  group="Contract 7")

// ─── Contract 8 ───────────────────────────────────────────────────────────────
c8_k     = input.float(0,     "Strike",    group="Contract 8", step=0.5, minval=0)
c8_t     = input.string("Put","Type",      options=["Put","Call"], group="Contract 8")
c8_start = input.time(1776859200000, "Open date", group="Contract 8")
c8_exp   = input.time(1776859200000, "Exp date",  group="Contract 8")

// ─── Persistent drawing state ─────────────────────────────────────────────────
var line[]  _lines  = array.new_line()
var label[] _labels = array.new_label()

var string[] MONTHS = array.from(
     "", "Jan","Feb","Mar","Apr","May","Jun",
     "Jul","Aug","Sep","Oct","Nov","Dec")

// ─── Draw on last bar only ────────────────────────────────────────────────────
ticker_match = ticker_filter == "" or str.upper(ticker_filter) == syminfo.ticker

if barstate.islast
    for ln in _lines
        line.delete(ln)
    for lb in _labels
        label.delete(lb)
    array.clear(_lines)
    array.clear(_labels)

    if ticker_match
        k_arr     = array.from(c1_k,     c2_k,     c3_k,     c4_k,     c5_k,     c6_k,     c7_k,     c8_k)
        t_arr     = array.from(c1_t,     c2_t,     c3_t,     c4_t,     c5_t,     c6_t,     c7_t,     c8_t)
        start_arr = array.from(c1_start, c2_start, c3_start, c4_start, c5_start, c6_start, c7_start, c8_start)
        exp_arr   = array.from(c1_exp,   c2_exp,   c3_exp,   c4_exp,   c5_exp,   c6_exp,   c7_exp,   c8_exp)

        for i = 0 to 7
            k      = array.get(k_arr,   i)
            exp_ts = array.get(exp_arr, i)
            // Draw automatically when strike > 0
            if k > 0
                t      = array.get(t_arr,     i)
                x1_raw = array.get(start_arr, i)

                is_put = t == "Put"
                col    = is_put ? col_put : col_call
                ltr    = is_put ? "P" : "C"

                // Open date: use calendar value if changed from default, otherwise today
                x1_val = x1_raw != 1776859200000 ? x1_raw : time

                // Expiry at 4pm ET on the selected date
                tz        = "America/New_York"
                exp_yr    = year(exp_ts, tz)
                exp_mo    = month(exp_ts, tz)
                exp_dy    = dayofmonth(exp_ts, tz)
                exp_close = timestamp(tz, exp_yr, exp_mo, exp_dy, 16, 0, 0)
                exp_str   = array.get(MONTHS, exp_mo) + " " + str.tostring(exp_dy)
                k_str     = k == math.floor(k) ? str.tostring(int(k)) : str.tostring(k)

                ln = line.new(
                     x1    = x1_val,    y1 = k,
                     x2    = exp_close, y2 = k,
                     xloc  = xloc.bar_time,
                     color = col,       width = lw,
                     style = line.style_solid)
                array.push(_lines, ln)

                if show_labels
                    lb = label.new(
                         x         = exp_close,
                         y         = k,
                         xloc      = xloc.bar_time,
                         text      = k_str + " " + ltr + "  " + exp_str,
                         color     = color.new(col, 75),
                         textcolor = col,
                         style     = label.style_label_left,
                         size      = size.small)
                    array.push(_labels, lb)
````
