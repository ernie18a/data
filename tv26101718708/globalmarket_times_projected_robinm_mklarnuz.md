# GlobalMarket Times (Projected) - RobinM

- url: https://www.tradingview.com/script/MklARnuZ-GlobalMarket-Times-Projected-RobinM/
- type: indicator
- pine_id: PUB;f25ae7e0a0d8412990c10d7ca272e240
- version: 1.0

## Description

Visualize the opening and closing times of the world’s most important financial markets directly on your chart.

This indicator automatically plots clear vertical lines and labels for major market sessions, helping traders instantly identify when liquidity enters or leaves the market. Perfect for understanding session-based volatility, timing breakouts, and spotting shifts in momentum throughout the trading day.

Included market sessions:

* Tokyo
* China / Hong Kong
* Europe / London
* United States

Features:

* Automatic market open and close markers
* Clean vertical line visualization
* Session labels directly on chart
* Historical session plotting for previous days
* Future projected session timestamps
* Accurate timezone handling (including CEST/DST support)
* Fully customizable visibility and styling options

Whether you trade forex, indices, crypto, commodities, or stocks, this tool gives you a clear visual framework of global market activity so you always know which financial centers are active.

## Source Code

````pine
//@version=6
indicator("GlobalMarket Times (Projected) - RobinM", overlay=true, max_labels_count=500, max_lines_count=500)

// Toggle displays
show_nyse_open   = input.bool(true, "Show NYSE Open")
show_nyse_close  = input.bool(true, "Show NYSE Close")
show_lse_open    = input.bool(true, "Show LSE Open")
show_lse_close   = input.bool(true, "Show LSE Close")
show_tokyo_open  = input.bool(true, "Show Tokyo Open")
show_tokyo_close = input.bool(true, "Show Tokyo Close")
show_hk_open     = input.bool(true, "Show HK/China Open")
show_hk_close    = input.bool(true, "Show HK/China Close")

// Global toggles
show_lines  = input.bool(true, "Show Lines")
show_labels = input.bool(true, "Show Labels")

// Colors
col_nyse  = input.color(color.red,    "NYSE Color")
col_lse   = input.color(color.blue,   "LSE Color")
col_tokyo = input.color(color.green,  "Tokyo Color")
col_hk    = input.color(color.orange, "HK/China Color")

// Timezones
tz_nyse  = "America/New_York"
tz_lse   = "Europe/London"
tz_tokyo = "Asia/Tokyo"
tz_hk    = "Asia/Hong_Kong"

// Helper: true if local time _h:_m in _tz falls within this bar
f_eventInBar(_tz, _h, _m) =>
    if not timeframe.isintraday
        false
    else
        yy   = year(time, _tz)
        mo   = month(time, _tz)
        dd   = dayofmonth(time, _tz)
        evTs = timestamp(_tz, yy, mo, dd, _h, _m)
        dur  = str.tonumber(timeframe.period) * 60000
        time >= evTs and time < evTs + dur

// Helper: same but for tomorrow (+1 day = +86400000ms), only draw on last bar
f_eventNextDay(_tz, _h, _m) =>
    if not timeframe.isintraday or not barstate.islast
        false
    else
        tomorrowTs = timenow + 86400000
        yy = year(tomorrowTs, _tz)
        mo = month(tomorrowTs, _tz)
        dd = dayofmonth(tomorrowTs, _tz)
        evTs = timestamp(_tz, yy, mo, dd, _h, _m)
        evTs > timenow  // only if it hasn't happened yet

// Draw helper for future events (projects line/label into future bars)
f_drawFuture(_tz, _h, _m, _label, _col, _isOpen) =>
    if timeframe.isintraday and barstate.islast
        yy   = year(timenow, _tz)
        mo   = month(timenow, _tz)
        dd   = dayofmonth(timenow, _tz)
        evTs = timestamp(_tz, yy, mo, dd, _h, _m)
        if evTs > timenow
            dur       = str.tonumber(timeframe.period) * 60000
            barsAhead = math.round((evTs - time) / dur)
            futureIdx = bar_index + barsAhead
            if show_lines
                line.new(futureIdx, high, futureIdx, low, xloc=xloc.bar_index, extend=extend.both, color=_col, width=1, style=line.style_dashed)
            if show_labels
                if _isOpen
                    label.new(futureIdx, high, _label, xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=_col)
                else
                    label.new(futureIdx, low, _label, xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=_col)
// ===== TODAY =====
open_nyse   = show_nyse_open   and f_eventInBar(tz_nyse,  9, 30)
open_lse    = show_lse_open    and f_eventInBar(tz_lse,   8,  0)
open_tokyo  = show_tokyo_open  and f_eventInBar(tz_tokyo, 9,  0)
open_hk     = show_hk_open     and f_eventInBar(tz_hk,    9, 30)
close_nyse  = show_nyse_close  and f_eventInBar(tz_nyse,  16,  0)
close_lse   = show_lse_close   and f_eventInBar(tz_lse,   16, 30)
close_tokyo = show_tokyo_close and f_eventInBar(tz_tokyo, 15,  0)
close_hk    = show_hk_close    and f_eventInBar(tz_hk,    16,  0)

// Draw NYSE
if open_nyse
    if show_lines
        line.new(bar_index, high, bar_index, low, xloc=xloc.bar_index, extend=extend.both, color=col_nyse, width=1)
    if show_labels
        label.new(bar_index, high, "NYSE Open", yloc=yloc.abovebar, style=label.style_label_down, color=col_nyse)
if close_nyse
    if show_lines
        line.new(bar_index, high, bar_index, low, xloc=xloc.bar_index, extend=extend.both, color=col_nyse, width=1)
    if show_labels
        label.new(bar_index, low, "NYSE Close", yloc=yloc.belowbar, style=label.style_label_up, color=col_nyse)

// Draw LSE
if open_lse
    if show_lines
        line.new(bar_index, high, bar_index, low, xloc=xloc.bar_index, extend=extend.both, color=col_lse, width=1)
    if show_labels
        label.new(bar_index, high, "LSE Open", yloc=yloc.abovebar, style=label.style_label_down, color=col_lse)
if close_lse
    if show_lines
        line.new(bar_index, high, bar_index, low, xloc=xloc.bar_index, extend=extend.both, color=col_lse, width=1)
    if show_labels
        label.new(bar_index, low, "LSE Close", yloc=yloc.belowbar, style=label.style_label_up, color=col_lse)

// Draw Tokyo
if open_tokyo
    if show_lines
        line.new(bar_index, high, bar_index, low, xloc=xloc.bar_index, extend=extend.both, color=col_tokyo, width=1)
    if show_labels
        label.new(bar_index, high, "Tokyo Open", yloc=yloc.abovebar, style=label.style_label_down, color=col_tokyo)
if close_tokyo
    if show_lines
        line.new(bar_index, high, bar_index, low, xloc=xloc.bar_index, extend=extend.both, color=col_tokyo, width=1)
    if show_labels
        label.new(bar_index, low, "Tokyo Close", yloc=yloc.belowbar, style=label.style_label_up, color=col_tokyo)

// Draw HK/China
if open_hk
    if show_lines
        line.new(bar_index, high, bar_index, low, xloc=xloc.bar_index, extend=extend.both, color=col_hk, width=1)
    if show_labels
        label.new(bar_index, high, "HK/CN Open", yloc=yloc.abovebar, style=label.style_label_down, color=col_hk)
if close_hk
    if show_lines
        line.new(bar_index, high, bar_index, low, xloc=xloc.bar_index, extend=extend.both, color=col_hk, width=1)
    if show_labels
        label.new(bar_index, low, "HK/CN Close", yloc=yloc.belowbar, style=label.style_label_up, color=col_hk)

// ===== TOMORROW (dashed, projected) =====
if show_nyse_open
    f_drawFuture(tz_nyse,  9, 30, "NYSE Open",    col_nyse,  true)
if show_nyse_close
    f_drawFuture(tz_nyse,  16,  0, "NYSE Close",  col_nyse,  false)
if show_lse_open
    f_drawFuture(tz_lse,   8,  0, "LSE Open",     col_lse,   true)
if show_lse_close
    f_drawFuture(tz_lse,   16, 30, "LSE Close",   col_lse,   false)
if show_tokyo_open
    f_drawFuture(tz_tokyo, 9,  0, "Tokyo Open",   col_tokyo, true)
if show_tokyo_close
    f_drawFuture(tz_tokyo, 15,  0, "Tokyo Close", col_tokyo, false)
if show_hk_open
    f_drawFuture(tz_hk,    9, 30, "HK/CN Open",   col_hk,    true)
if show_hk_close
    f_drawFuture(tz_hk,    16,  0, "HK/CN Close", col_hk,    false)
````
