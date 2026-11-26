# ARvADR Regulars edition 

- url: https://www.tradingview.com/script/jHzp5fja-ARvADR-Regulars-edition/
- type: indicator
- pine_id: PUB;53e74a3609c248eb90f212b0b057c2f8
- version: 1.0

## Description

For the regulars 

Tracks ADR against AR to take us to infinity and beyond

## Source Code

````pine
//@version=6
indicator("ar vs adr (locked at asia end)", overlay=true, max_labels_count=50)

// inputs
show = input.bool(true, "show")
sess = input.session("1900-0245", "asia session (ny)")
tz   = input.string("America/New_York", "timezone (dst-safe)")

adr_len = input.int(14, "adr length", minval=1)
cmp_th  = input.float(0.30, "compressed threshold", step=0.01)
str_th  = input.float(0.60, "stretched threshold", step=0.01)

lbl_xbars = input.int(3, "label x offset (bars)", minval=0)
lbl_size  = input.string("small", "label size", options=["tiny","small","normal","large","huge"])
var table t = table.new(position.top_right, 1, 1, border_width=1)
// --- helpers
f_lbl_size(s) =>
    if s == "tiny"
        size.tiny
    else if s == "small"
        size.small
    else if s == "normal"
        size.normal
    else if s == "large"
        size.large
    else
        size.huge
/// --- adr (daily) computed on daily timeframe (completed days only)
day_adr = request.security(
     syminfo.tickerid,
     "D",
     ta.sma(high[1] - low[1], adr_len),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

// --- asia range (build live during session)
in_sess  = not na(time(timeframe.period, sess, tz))
end_sess = not in_sess and in_sess[1]


var float sess_hi = na
var float sess_lo = na

new_day = ta.change(time("D", tz)) != 0

if new_day
    sess_hi := na
    sess_lo := na
if in_sess
    sess_hi := na(sess_hi) ? high : math.max(sess_hi, high)
    sess_lo := na(sess_lo) ? low  : math.min(sess_lo, low)

// live values
ar_live  = (na(sess_hi) or na(sess_lo)) ? na : (sess_hi - sess_lo)
pct_live = (not na(ar_live) and day_adr != 0) ? (ar_live / day_adr) : na

// --- freeze once when asia completes
var float ar_fix  = na
var float adr_fix = na
var float pct_fix = na

if new_day
    ar_fix  := na
    adr_fix := na
    pct_fix := na

if end_sess
    ar_fix  := ar_live[1]
    adr_fix := day_adr[1]
    pct_fix := (not na(ar_fix) and adr_fix != 0) ? (ar_fix / adr_fix) : na

// classify using frozen value (falls back to live until frozen exists)
pct_used = na(pct_fix) ? pct_live : pct_fix

state =
     na(pct_used) ? "na" :
     pct_used < cmp_th ? "compressed" :
     pct_used > str_th ? "stretched" :
     "normal"

if barstate.islast and show
    txt = (
        "ar: " + str.tostring(ar_fix, format.mintick) +
        "\nadr(" + str.tostring(adr_len) + "): " + str.tostring(adr_fix, format.mintick) +
        "\nar/adr %: " + (na(pct_fix) ? "na" : str.tostring(math.round(pct_fix * 1000) / 10)) +
        "\nstate: " + state
    )

    table.cell(t, 0, 0, txt, text_color=color.white, text_size=size.normal)
````
