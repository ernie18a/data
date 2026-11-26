# VWAP [D/W/M]

- url: https://www.tradingview.com/script/KLI7YdXK/
- type: indicator
- pine_id: PUB;f02be0a35ae747558ea55fa87c6e9e82
- version: 1.0

## Description

VWAP Suite [D/W/M]

OVERVIEW
VWAP Suite [D/W/M] plots Daily, Weekly, and Monthly Volume-Weighted Average Price on a single chart, with independent visibility, color, and line width for each. It's built for traders who use multiple VWAP anchors at once (e.g., daily VWAP for intraday context alongside weekly/monthly VWAP for higher-timeframe bias) without needing three separate indicators.

HOW IT WORKS
Each VWAP (Daily/Weekly/Monthly) is calculated as a running sum of typical price (hlc3) × volume, divided by cumulative volume, reset at the start of each new day/week/month. The calculation can run either on the chart's own timeframe or on an independently selected timeframe via request.security(), so a Daily VWAP can, for example, be calculated from 1-minute data even while viewing a 4-hour chart for a smoother, more accurate line.

To keep higher-timeframe charts uncluttered, each VWAP line has its own maximum display timeframe — once the chart timeframe exceeds that threshold, the corresponding line is automatically hidden (e.g., Daily VWAP only shows up to 30m by default, since a daily VWAP has little meaning on a weekly chart).

The script also includes a configurable alert system: it can fire when price comes within a chosen percentage distance of any of the three VWAPs, optionally restricted to a specific hour-range time window in a selectable timezone.

SETTINGS
- VWAP Display: toggle, color, and line width for Daily/Weekly/Monthly VWAP.
- Calculation Timeframe: per VWAP, choose "Chart" (use the chart's own timeframe) or an independent timeframe (seconds to 4h, or Daily) the VWAP is computed from.
- Display Timeframe Filter: maximum chart timeframe at which each VWAP line is still shown.
- Alerts: global time-window filter (active hours + timezone), minimum distance to VWAP (%) required to trigger, and individual enable switches for Daily/Weekly/Monthly alerts plus a combined "any VWAP" alert condition.

USAGE
Use the Daily VWAP as an intraday fair-value reference, and the Weekly/Monthly VWAPs as higher-timeframe trend/bias levels. Price holding above/below a VWAP is commonly read as directional bias; reactions at a VWAP (rejection, reclaim) are often used as confluence with other levels. The built-in alerts let you get notified when price approaches any of these levels without watching the chart continuously.

LIMITATIONS
- VWAP values calculated on a different (lower) timeframe via request.security() rely on that timeframe's data being available for the symbol.
- Like any cumulative VWAP, daily/weekly/monthly resets depend on the exchange's session and calendar data; behavior can vary slightly across symbols/exchanges with non-standard sessions.
- Alerts only evaluate while the script is running on an open chart, or via TradingView's standard alert infrastructure once configured from this indicator.

## Source Code

````pine
//@version=6
indicator("VWAP Suite [D/W/M]", overlay=true, max_bars_back=5000)

// ═══════════════════════════════════════════════════════════════
// SETTINGS – VWAP DISPLAY (D / W / M)
// ═══════════════════════════════════════════════════════════════
show_d    = input.bool(true,  "Daily VWAP",   group="VWAP DISPLAY", inline="d")
col_d     = input.color(color.new(#000000, 0), "", group="VWAP DISPLAY", inline="d")
width_d   = input.int(1, "px", minval=1, maxval=5, group="VWAP DISPLAY", inline="d")

show_w    = input.bool(true,  "Weekly VWAP",  group="VWAP DISPLAY", inline="w")
col_w     = input.color(color.new(#2962ff, 0), "", group="VWAP DISPLAY", inline="w")
width_w   = input.int(2, "px", minval=1, maxval=5, group="VWAP DISPLAY", inline="w")

show_m    = input.bool(true,  "Monthly VWAP", group="VWAP DISPLAY", inline="m")
col_m     = input.color(color.new(#f23645, 0), "", group="VWAP DISPLAY", inline="m")
width_m   = input.int(3, "px", minval=1, maxval=5, group="VWAP DISPLAY", inline="m")

// ═══════════════════════════════════════════════════════════════
// SETTINGS – CALCULATION TIMEFRAME (D / W / M)
// ═══════════════════════════════════════════════════════════════
d_calc_raw   = input.string("Chart", "Daily   calculate on",
               options=["Chart","1S","5S","10S","15S","30S","1","3","5","15","30","60","240","D"],
               group="CALCULATION TIMEFRAME",
               tooltip="'Chart' = current chart timeframe. Seconds: 1S/5S/10S/15S/30S. Minutes: 1/3/5/15/30/60/240.")
w_calc_raw   = input.string("Chart", "Weekly  calculate on",
               options=["Chart","1S","5S","10S","15S","30S","1","3","5","15","30","60","240","D"],
               group="CALCULATION TIMEFRAME")
m_calc_raw   = input.string("Chart", "Monthly calculate on",
               options=["Chart","1S","5S","10S","15S","30S","1","3","5","15","30","60","240","D"],
               group="CALCULATION TIMEFRAME")

d_tf   = d_calc_raw   == "Chart" ? timeframe.period : d_calc_raw
w_tf   = w_calc_raw   == "Chart" ? timeframe.period : w_calc_raw
m_tf   = m_calc_raw   == "Chart" ? timeframe.period : m_calc_raw

// ═══════════════════════════════════════════════════════════════
// SETTINGS – DISPLAY TIMEFRAME FILTER (D / W / M)
// ═══════════════════════════════════════════════════════════════
tf_d_max = input.string("30m",   "Daily max. display TF",
           options=["1m","5m","15m","30m","1h","4h","1D","1W","All"],
           group="DISPLAY TIMEFRAME FILTER",
           tooltip="Daily VWAP is hidden when the chart TF >= this value")
tf_w_max = input.string("4h",   "Weekly max. display TF",
           options=["1m","5m","15m","30m","1h","4h","1D","1W","All"],
           group="DISPLAY TIMEFRAME FILTER")
tf_m_max = input.string("4h", "Monthly max. display TF",
           options=["1m","5m","15m","30m","1h","4h","1D","1W","All"],
           group="DISPLAY TIMEFRAME FILTER")

// ═══════════════════════════════════════════════════════════════
// SETTINGS – ALERTS (global)
// ═══════════════════════════════════════════════════════════════
use_tw  = input.bool(true, "Time window active", group="ALERTS")
tw_from = input.int(8,  "From hour", minval=0, maxval=23, group="ALERTS")
tw_to   = input.int(22, "To hour", minval=0, maxval=23, group="ALERTS")
tz      = input.string("Europe/Berlin", "Timezone",
          options=["UTC","Europe/Berlin","Europe/London","America/New_York",
                   "America/Chicago","America/Los_Angeles","Asia/Tokyo",
                   "Asia/Singapore","Asia/Hong_Kong"],
          group="ALERTS")
min_pct = input.float(0.9, "Minimum distance to VWAP (%)", minval=0.01, maxval=20.0, step=0.1, group="ALERTS")

al_d   = input.bool(false, "Alert Daily VWAP",   group="ALERTS")
al_w   = input.bool(true,  "Alert Weekly VWAP",  group="ALERTS")
al_m   = input.bool(true,  "Alert Monthly VWAP", group="ALERTS")

// ═══════════════════════════════════════════════════════════════
// DISPLAY TF FILTER
// ═══════════════════════════════════════════════════════════════
tf_to_min(tf) =>
    switch tf
        "1m"  => 1.0
        "5m"  => 5.0
        "15m" => 15.0
        "30m" => 30.0
        "1h"  => 60.0
        "4h"  => 240.0
        "1D"  => 1440.0
        "1W"  => 10080.0
        => 999999.0

chart_min = timeframe.in_seconds() / 60.0
tf_ok_d   = tf_d_max == "All" or chart_min < tf_to_min(tf_d_max)
tf_ok_w   = tf_w_max == "All" or chart_min < tf_to_min(tf_w_max)
tf_ok_m   = tf_m_max == "All" or chart_min < tf_to_min(tf_m_max)

// ═══════════════════════════════════════════════════════════════
// VWAP FUNCTIONS – D / W / M
// ═══════════════════════════════════════════════════════════════
f_vwap_d() =>
    var float _tpv = 0.0
    var float _vol = 0.0
    _new  = ta.change(time("D")) != 0
    _tpv := _new ? hlc3 * volume : _tpv + hlc3 * volume
    _vol := _new ? volume        : _vol + volume
    _vol > 0 ? _tpv / _vol : na

f_vwap_w() =>
    var float _tpv = 0.0
    var float _vol = 0.0
    _new  = ta.change(time("W")) != 0
    _tpv := _new ? hlc3 * volume : _tpv + hlc3 * volume
    _vol := _new ? volume        : _vol + volume
    _vol > 0 ? _tpv / _vol : na

f_vwap_m() =>
    var float _tpv = 0.0
    var float _vol = 0.0
    _new  = ta.change(time("M")) != 0
    _tpv := _new ? hlc3 * volume : _tpv + hlc3 * volume
    _vol := _new ? volume        : _vol + volume
    _vol > 0 ? _tpv / _vol : na

// ═══════════════════════════════════════════════════════════════
// CALCULATIONS via request.security
// ═══════════════════════════════════════════════════════════════
vwap_d   = request.security(syminfo.tickerid, d_tf,   f_vwap_d(),   gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
vwap_w   = request.security(syminfo.tickerid, w_tf,   f_vwap_w(),   gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
vwap_m   = request.security(syminfo.tickerid, m_tf,   f_vwap_m(),   gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ═══════════════════════════════════════════════════════════════
// PLOT
// ═══════════════════════════════════════════════════════════════
p_d   = show_d   and tf_ok_d ? vwap_d   : na
p_w   = show_w   and tf_ok_w ? vwap_w   : na
p_m   = show_m   and tf_ok_m ? vwap_m   : na

plot(p_d,   "Daily VWAP",   col_d,   width_d)
plot(p_w,   "Weekly VWAP",  col_w,   width_w)
plot(p_m,   "Monthly VWAP", col_m,   width_m)

// ═══════════════════════════════════════════════════════════════
// LABELS
// ═══════════════════════════════════════════════════════════════
var label lb_d   = na
var label lb_w   = na
var label lb_m   = na

if barstate.islast
    lx = bar_index + 2
    sz = size.small
    st = label.style_none

    label.delete(lb_d)
    label.delete(lb_w)
    label.delete(lb_m)

    if not na(p_d)
        lb_d   := label.new(lx, vwap_d,   "D-VWAP",   textcolor=col_d,   style=st, size=sz)
    if not na(p_w)
        lb_w   := label.new(lx, vwap_w,   "W-VWAP",   textcolor=col_w,   style=st, size=sz)
    if not na(p_m)
        lb_m   := label.new(lx, vwap_m,   "M-VWAP",   textcolor=col_m,   style=st, size=sz)

// ═══════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════
cur_h = hour(time, tz)
in_tw = not use_tw or (cur_h >= tw_from and cur_h < tw_to)

near(v) => not na(v) and v > 0 and math.abs(close - v) / v * 100 <= min_pct

trig_d   = in_tw and al_d    and near(vwap_d)
trig_w   = in_tw and al_w    and near(vwap_w)
trig_m   = in_tw and al_m    and near(vwap_m)

alertcondition(trig_d,   "Daily VWAP Alert",   "Price near Daily VWAP | {{ticker}} | {{close}}")
alertcondition(trig_w,   "Weekly VWAP Alert",  "Price near Weekly VWAP | {{ticker}} | {{close}}")
alertcondition(trig_m,   "Monthly VWAP Alert", "Price near Monthly VWAP | {{ticker}} | {{close}}")
alertcondition(trig_d or trig_w or trig_m,
               "VWAP Suite – Any Alert",
               "Price near VWAP | {{ticker}} | {{close}}")
````
