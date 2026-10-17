# Trading Sessions

- url: https://www.tradingview.com/script/kJAA5Rjh-Trading-Sessions/
- type: indicator
- pine_id: PUB;a1d0c660d6564b509df21d5836e2c590
- version: 1.0

## Description

Simple indicator that marks out global trading session windows.

## Source Code

````pine

//@version=6
indicator("MNQ Trading Sessions", overlay=true, max_boxes_count=500)

TZ = "America/New_York"

// Non-overlapping session windows (ET)
in_asia    = not na(time(timeframe.period, "2000-0300", TZ))
in_london  = not na(time(timeframe.period, "0300-0800", TZ))
in_premkt  = not na(time(timeframe.period, "0800-0930", TZ))
in_ny      = not na(time(timeframe.period, "0930-1600", TZ))

// Session start / end flags
asia_start   = in_asia   and not in_asia[1]
london_start = in_london and not in_london[1]
premkt_start = in_premkt and not in_premkt[1]
ny_start     = in_ny     and not in_ny[1]

asia_end     = not in_asia   and in_asia[1]
london_end   = not in_london and in_london[1]
premkt_end   = not in_premkt and in_premkt[1]
ny_end       = not in_ny     and in_ny[1]

// Track per-session high/low and start bar
var int   a_bar = na
var float a_hi  = na
var float a_lo  = na
var int   l_bar = na
var float l_hi  = na
var float l_lo  = na
var int   p_bar = na
var float p_hi  = na
var float p_lo  = na
var int   n_bar = na
var float n_hi  = na
var float n_lo  = na

// Colors
c_asia   = color.new(#4C9BE8, 82)
c_london = color.new(#E8834C, 82)
c_premkt = color.new(#8BC34A, 82)
c_ny     = color.new(#F5C518, 82)

c_asia_b   = color.new(#4C9BE8, 20)
c_london_b = color.new(#E8834C, 20)
c_premkt_b = color.new(#8BC34A, 20)
c_ny_b     = color.new(#F5C518, 20)

// Asia
if asia_start
    a_bar := bar_index
    a_hi  := high
    a_lo  := low
if in_asia
    a_hi := math.max(a_hi, high)
    a_lo := math.min(a_lo, low)
if asia_end
    box.new(a_bar, a_hi, bar_index - 1, a_lo,
     border_color=c_asia_b, bgcolor=c_asia,
     text="Asia", text_size=size.small,
     text_color=color.white, text_halign=text.align_left, text_valign=text.align_top)

// London
if london_start
    l_bar := bar_index
    l_hi  := high
    l_lo  := low
if in_london
    l_hi := math.max(l_hi, high)
    l_lo := math.min(l_lo, low)
if london_end
    box.new(l_bar, l_hi, bar_index - 1, l_lo,
     border_color=c_london_b, bgcolor=c_london,
     text="London", text_size=size.small,
     text_color=color.white, text_halign=text.align_left, text_valign=text.align_top)

// Pre-Market
if premkt_start
    p_bar := bar_index
    p_hi  := high
    p_lo  := low
if in_premkt
    p_hi := math.max(p_hi, high)
    p_lo := math.min(p_lo, low)
if premkt_end
    box.new(p_bar, p_hi, bar_index - 1, p_lo,
     border_color=c_premkt_b, bgcolor=c_premkt,
     text="Pre-Mkt", text_size=size.small,
     text_color=color.white, text_halign=text.align_left, text_valign=text.align_top)

// New York RTH
if ny_start
    n_bar := bar_index
    n_hi  := high
    n_lo  := low
if in_ny
    n_hi := math.max(n_hi, high)
    n_lo := math.min(n_lo, low)
if ny_end
    box.new(n_bar, n_hi, bar_index - 1, n_lo,
     border_color=c_ny_b, bgcolor=c_ny,
     text="NY RTH", text_size=size.small,
     text_color=color.white, text_halign=text.align_left, text_valign=text.align_top)
````
