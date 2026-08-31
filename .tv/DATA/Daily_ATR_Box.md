<!-- tradingview-pine-id: PUB;e994c2095adb49ab8b6e7469dca11ea8 -->
<!-- tradingviewscripts-format: 1 -->
# Daily ATR Box

Source: https://www.tradingview.com/script/4JjkN9Mk-Daily-ATR-Box/

## Description

Daily ATR Box

A compact stats table — ATR, gap size, pre-market volume, and how much of the stock's typical daily range is already used — in one glance instead of eyeballing the chart and doing the math yourself. Renders in its own pane, not as an overlay on price.

What it shows

ATR(N) — the stock's N-day average true range (default 14), pulled from the daily timeframe.
Gap — today's gap vs. the prior session's close, in price and as a % of ATR. Live against last price during pre-market; freezes at the official 9:30 open print once the regular session starts, so the number stops drifting once the real open is in.
PM Vol — pre-market volume as a % of average daily volume (ADV, default 20-day lookback). Color-coded green at 30%+ ADV, yellow at 10%+ — rough thresholds for "is this actually in play" pre-market. Needs an intraday chart with extended-hours data on; reads 0 on an RTH-only chart, and is only as complete as your feed's extended-hours reporting.
Used — % of the stock's typical daily range (ATR) already consumed by today's regular-session high-low range. Green under 50%, yellow 50–79%, red 80%+, as a heads-up for when the day's typical move is mostly spent.
Left — remaining ATR in absolute price terms (floored at zero).
vs O — current price change vs. today's regular-session open.
Notes on accuracy

Range and gap tracking reset at the daily rollover rather than at the 9:30 session start, so pre-market always reflects the current day instead of showing yesterday's stale numbers. Prior close is tracked from the last regular-session bar actually seen rather than a fixed one-bar lookback on the daily series, which avoids the gap reading against the wrong day around weekends and holidays.

Inputs: ATR length, ADV lookback (days), table position, text size.

---

## Source Code

````pine
//@version=6
indicator("Daily ATR Box", overlay=false)

// — Inputs
atr_length = input.int(14, "ATR Length", minval=1)
adv_length = input.int(20, "ADV Length (days)", minval=1)
tbl_pos    = input.string("bottom_right", "Position",
             options=["top_left","top_right","bottom_left","bottom_right","middle_left","middle_right"])
txt_size   = input.string("small", "Text Size",
             options=["tiny","small","normal","large","huge"])

// — Colours
c_bg      = color.new(#0d1117, 5)
c_border  = color.new(#00e5ff, 40)
c_label   = color.new(#00e5ff, 10)
c_value   = color.white
c_green   = color.new(#00e676, 0)
c_yellow  = color.new(#ffeb3b, 0)
c_red     = color.new(#ff1744, 0)
c_magenta = color.new(#e040fb, 0)

// — Daily series. NOTE: no daily close[1] here — during pre-market the
//   current daily bar is still YESTERDAY's, so close[1] reaches back two
//   days (Thursday on a Monday) and the gap reads absurdly large. Prior
//   close is tracked locally from RTH bars instead.
d_atr = request.security(syminfo.tickerid, "D", ta.atr(atr_length), lookahead=barmerge.lookahead_off)
adv   = request.security(syminfo.tickerid, "D", ta.sma(volume, adv_length), lookahead=barmerge.lookahead_off)

// — Day rollover
new_day = ta.change(time("D")) != 0

// — Pre-market volume (needs an intraday chart with extended hours ON;
//   reads 0 on an RTH-only chart, and only counts what the chart's data
//   feed reports — Cboe One real-time understates it). Frozen once RTH starts.
var float pm_vol = 0.0
if new_day
    pm_vol := 0.0
if session.ispremarket
    pm_vol += volume
pm_adv_pct = adv > 0 ? pm_vol / adv * 100 : na

// — Prior-day close, tracked locally (see NOTE above)
var float day_close      = na   // last RTH close seen so far
var float prev_day_close = na   // final close of the prior RTH day

// — RTH tracking. Reset MUST also fire on new_day: on an RTH-only chart the
//   bar before today's open is yesterday's 15:59 (still in-session), so a
//   pure session-transition check never resets and the range accumulates
//   across days.
rth_start = session.ismarket and (not session.ismarket[1] or new_day)

var float rth_open = na
var float rth_high = na
var float rth_low  = na

// Recalibrate at the DAY roll, not 9:30 — otherwise yesterday's Used/vs O
// linger through pre-market as stale noise.
if new_day
    rth_open := na
    rth_high := na
    rth_low  := na

if rth_start
    prev_day_close := day_close
    rth_open := open
    rth_high := high
    rth_low  := low
else if session.ismarket
    rth_high := math.max(rth_high, high)
    rth_low  := math.min(rth_low,  low)

if session.ismarket
    day_close := close

// — Derived values (Used = today's RTH range only; gap shown on its own row)
day_range     = (na(rth_high) or na(rth_low)) ? 0.0 : rth_high - rth_low
atr_used_pct  = d_atr > 0 ? (day_range / d_atr * 100) : 0.0
atr_remaining = math.max(d_atr - day_range, 0)
vs_open       = na(rth_open) ? na : close - rth_open

// Gap: pre-market → last price vs yesterday's RTH close (live);
// RTH / after-hours → today's 9:30 open vs yesterday's close (frozen).
float gap_val = na
if session.ispremarket
    gap_val := na(day_close) ? na : close - day_close
else
    gap_val := na(rth_open) or na(prev_day_close) ? na : rth_open - prev_day_close
gap_atr_pct = na(gap_val) or d_atr <= 0 ? na : gap_val / d_atr * 100

// — Table
pos = switch tbl_pos
    "top_left"     => position.top_left
    "top_right"    => position.top_right
    "bottom_left"  => position.bottom_left
    "bottom_right" => position.bottom_right
    "middle_left"  => position.middle_left
    => position.middle_right

sz = switch txt_size
    "tiny"   => size.tiny
    "small"  => size.small
    "normal" => size.normal
    "large"  => size.large
    => size.huge

var table t = table.new(pos, 2, 6,
     bgcolor=c_bg, border_width=1, border_color=c_border)

if barstate.islast
    table.cell(t, 0, 0, "ATR(" + str.tostring(atr_length) + ")",
         text_color=c_label, text_size=sz, bgcolor=c_bg)
    table.cell(t, 1, 0, str.tostring(d_atr, "#.##"),
         text_color=c_value, text_size=sz, bgcolor=c_bg)

    gap_col  = na(gap_val) ? c_value : gap_val > 0 ? c_green : gap_val < 0 ? c_red : c_value
    gap_sign = na(gap_val) or gap_val <= 0 ? "" : "+"
    gap_txt  = na(gap_val) ? "—" :
         gap_sign + str.tostring(gap_val, "#.##") + " · " + str.tostring(gap_atr_pct, "#") + "% ATR"
    table.cell(t, 0, 1, "Gap",
         text_color=c_label, text_size=sz, bgcolor=c_bg)
    table.cell(t, 1, 1, gap_txt,
         text_color=gap_col, text_size=sz, bgcolor=c_bg)

    // 30%+ of ADV pre-market = watchlist criterion → green
    pm_col = na(pm_adv_pct) ? c_value : pm_adv_pct >= 30 ? c_green : pm_adv_pct >= 10 ? c_yellow : c_value
    pm_txt = na(pm_adv_pct) ? "—" : str.tostring(pm_adv_pct, "#.#") + "% ADV"
    table.cell(t, 0, 2, "PM Vol",
         text_color=pm_col, text_size=sz, bgcolor=c_bg)
    table.cell(t, 1, 2, pm_txt,
         text_color=pm_col, text_size=sz, bgcolor=c_bg)

    used_col = atr_used_pct >= 80 ? c_red : atr_used_pct >= 50 ? c_yellow : c_green
    table.cell(t, 0, 3, "Used",
         text_color=c_label, text_size=sz, bgcolor=c_bg)
    table.cell(t, 1, 3, str.tostring(atr_used_pct, "#.#") + "%",
         text_color=used_col, text_size=sz, bgcolor=c_bg)

    table.cell(t, 0, 4, "Left",
         text_color=c_label, text_size=sz, bgcolor=c_bg)
    table.cell(t, 1, 4, str.tostring(atr_remaining, "#.##"),
         text_color=c_magenta, text_size=sz, bgcolor=c_bg)

    vo_col  = na(vs_open) ? c_value : vs_open > 0 ? c_green : vs_open < 0 ? c_red : c_value
    vo_sign = na(vs_open) or vs_open <= 0 ? "" : "+"
    vo_txt  = na(vs_open) ? "—" : vo_sign + str.tostring(vs_open, "#.##")
    table.cell(t, 0, 5, "vs O",
         text_color=c_label, text_size=sz, bgcolor=c_bg)
    table.cell(t, 1, 5, vo_txt,
         text_color=vo_col, text_size=sz, bgcolor=c_bg)

plot(na)
````
