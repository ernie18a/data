# ETH HOD/LOD VWAP +

- url: https://www.tradingview.com/script/5vkaQpJv-ETH-HOD-LOD-VWAP/
- type: indicator
- pine_id: PUB;77a8623383b4486091dbb35d3b7a857f
- version: 1.0

## Description

ETH HOD/LOD VWAP

Plots three volume-weighted average prices (VWAPs) for futures traders on the full electronic trading hours (ETH) session, 18:00–17:00 New York time:

H-VWAP (red): anchored at the session's highest point so far.
L-VWAP (cyan): anchored at the session's lowest point so far.
A-VWAP (yellow): anchored at a date/time you choose, or restarted daily at a set time.
How it works

A new session starts at 18:00 New York time, the CME Globex open. This also handles the Friday-to-Sunday weekend gap and daylight saving changes. Each time the session makes a new high, H-VWAP restarts from that bar. Each time it makes a new low, L-VWAP restarts from that bar. The two lines always show the average price paid since the current extreme was set.

Price above H-VWAP means buyers since the high are back in profit.
Price below L-VWAP means sellers since the low are back in profit.
Price between the two lines means the session is balanced.
H-VWAP and L-VWAP are drawn for the current session only. The A-VWAP line shows its full history.

Settings

Anchor On: "Close" anchors on the highest or lowest candle close of the session, which ignores wicks. "Wick" anchors on the session's true high and low.
VWAP Price: HLC3 (high + low + close) / 3, or OHLC4 (open + high + low + close) / 4.
Anchored VWAP, Fixed date/time: one start point. Useful for a contract-roll VWAP: set it to 18:00 the evening before the first session of the new contract.
Anchored VWAP, Daily time: restarts every day at the New York time you set (default 09:30) and stops at the end time (default 16:55). Windows that run past midnight are supported, e.g. 18:00 → 16:55.
Aesthetics: line colours, thicknesses and label offset. Each line's current value is labelled at the right edge.
Notes

Built for futures with volume data (e.g. NQ, ES). Without volume, the VWAP values are meaningless.
Use an intraday chart. Lower timeframes (1–5 min) place the anchors most precisely.
This indicator shows levels only. It does not generate trade signals.

## Source Code

````pine
//@version=6
indicator("ETH HOD/LOD VWAP", overlay = true, precision = 2, max_bars_back = 5000)

// ─── Inputs ───────────────────────────────────────────────────────────────────
string anchor_src = input.string("Close", "Anchor On", options = ["Close", "Wick"], group = "Settings",
     tooltip = "Close = highest/lowest candle close of the session. Wick = session high/low.")
string calc_src   = input.string("HLC3", "VWAP Price", options = ["HLC3", "OHLC4"], group = "Settings",
     tooltip = "Price used for every VWAP. HLC3 = (H+L+C)/3. OHLC4 = (O+H+L+C)/4.")

color color_hod = input.color(color.new(#ff5252, 0), "HOD Line",      group = "Aesthetics")
color color_lod = input.color(color.new(#00f2ff, 0), "LOD Line",      group = "Aesthetics")
int   width_hod = input.int(1, "HOD Thickness", minval = 1, maxval = 4, group = "Aesthetics")
int   width_lod = input.int(1, "LOD Thickness", minval = 1, maxval = 4, group = "Aesthetics")
int   label_off = input.int(2, "Label Offset", minval = 0,              group = "Aesthetics")

string GA        = "Anchored VWAP"
bool   show_a    = input.bool(true, "Show Anchored VWAP", group = GA)
string a_mode    = input.string("Fixed date/time", "Anchor", options = ["Fixed date/time", "Daily time"], group = GA,
     tooltip = "Fixed = one start point (e.g. the contract-roll session, 18:00 the evening before). Daily = restarts every day at the time below (New York).")
int    a_time    = input.time(timestamp("15 Sep 2026 18:00 -0400"), "Fixed anchor", group = GA)
int    a_hour    = input.int(9, "Daily anchor (NY)  hour", minval = 0, maxval = 23, inline = "d", group = GA)
int    a_min     = input.int(30, "min", minval = 0, maxval = 59, inline = "d", group = GA)
int    e_hour    = input.int(16, "Daily end (NY)  hour", minval = 0, maxval = 23, inline = "e", group = GA)
int    e_min     = input.int(55, "min", minval = 0, maxval = 59, inline = "e", group = GA,
     tooltip = "Daily mode only: the line stops here and restarts at the next anchor time.")
color  color_a   = input.color(color.new(#ffd54f, 0), "Line", inline = "a", group = GA)
int    width_a   = input.int(2, "Thickness", minval = 1, maxval = 4, inline = "a", group = GA)

// ─── ETH Session (18:00 → 17:00 New York) ─────────────────────────────────────
// Shift time +6h so 18:00 NY rolls to the next calendar day; a change in that
// day marks a new Globex session (also handles the Fri→Sun weekend gap and DST).
int  eth_day     = dayofmonth(time + 6 * 3600000, "America/New_York")
bool is_eth_open = na(eth_day[1]) or eth_day != eth_day[1]

float src_hi = anchor_src == "Close" ? close : high
float src_lo = anchor_src == "Close" ? close : low

// ─── State ────────────────────────────────────────────────────────────────────
var float eth_high    = na
var float eth_low     = na
var float h_vol_price = 0.0
var float h_vol       = 0.0
var float l_vol_price = 0.0
var float l_vol       = 0.0

var array<chart.point> h_points = array.new<chart.point>()
var array<chart.point> l_points = array.new<chart.point>()

var polyline pl_h = na
var polyline pl_l = na

// ─── Accumulation ─────────────────────────────────────────────────────────────
float vwap_price = calc_src == "OHLC4" ? ohlc4 : hlc3
float bar_vwp    = vwap_price * volume

if is_eth_open
    eth_high    := src_hi
    eth_low     := src_lo
    h_vol_price := bar_vwp
    h_vol       := volume
    l_vol_price := bar_vwp
    l_vol       := volume
    h_points.clear()
    l_points.clear()
else
    if src_hi > eth_high
        eth_high    := src_hi
        h_vol_price := bar_vwp
        h_vol       := volume
        h_points.clear()
    else
        h_vol_price += bar_vwp
        h_vol       += volume

    if src_lo < eth_low
        eth_low     := src_lo
        l_vol_price := bar_vwp
        l_vol       := volume
        l_points.clear()
    else
        l_vol_price += bar_vwp
        l_vol       += volume

float vwap_h = h_vol > 0 ? h_vol_price / h_vol : na
float vwap_l = l_vol > 0 ? l_vol_price / l_vol : na

if not na(vwap_h)
    h_points.push(chart.point.from_time(time, vwap_h))
if not na(vwap_l)
    l_points.push(chart.point.from_time(time, vwap_l))

// ─── Anchored VWAP ────────────────────────────────────────────────────────────
int  ny_min   = hour(time, "America/New_York") * 60 + minute(time, "America/New_York")
int  ny_day   = dayofmonth(time, "America/New_York")
int  d_anchor = a_hour * 60 + a_min
bool a_reset  = a_mode == "Fixed date/time" ?
     time >= a_time and (na(time[1]) or time[1] < a_time) :
     ny_min >= d_anchor and (na(ny_min[1]) or ny_min[1] < d_anchor or ny_day != ny_day[1])

// daily window: anchor → end (also works if it runs past midnight, e.g. 18:00 → 16:55)
int  d_end    = e_hour * 60 + e_min
bool a_active = a_mode == "Fixed date/time" or
     (d_end > d_anchor ? ny_min >= d_anchor and ny_min < d_end : ny_min >= d_anchor or ny_min < d_end)

var float a_vol_price = na
var float a_vol       = na

if a_reset
    a_vol_price := bar_vwp
    a_vol       := volume
else if not na(a_vol) and a_active
    a_vol_price += bar_vwp
    a_vol       += volume

float vwap_a = show_a and a_active and a_vol > 0 ? a_vol_price / a_vol : na

// line breaks at each daily restart (no joining segment)
plot(vwap_a, "Anchored VWAP", color = a_reset ? na : color_a, linewidth = width_a, style = plot.style_line)

// ─── Draw on last bar ─────────────────────────────────────────────────────────
if barstate.islast
    pl_h.delete()
    pl_l.delete()

    if h_points.size() >= 2
        pl_h := polyline.new(h_points, curved = false, line_color = color_hod, line_width = width_hod, xloc = xloc.bar_time)
    if l_points.size() >= 2
        pl_l := polyline.new(l_points, curved = false, line_color = color_lod, line_width = width_lod, xloc = xloc.bar_time)

// ─── Labels ───────────────────────────────────────────────────────────────────
var label lb_h = label.new(bar_index, na, "", style = label.style_label_left,
     textcolor = color.white, color = color_hod, size = size.small)
var label lb_l = label.new(bar_index, na, "", style = label.style_label_left,
     textcolor = color.white, color = color_lod, size = size.small)
var label lb_a = label.new(bar_index, na, "", style = label.style_label_left,
     textcolor = color.black, color = color_a, size = size.small)

if barstate.islast
    lb_h.set_xy(bar_index + label_off, vwap_h)
    lb_h.set_text("H-VWAP: " + str.tostring(vwap_h, "#.##"))
    lb_l.set_xy(bar_index + label_off, vwap_l)
    lb_l.set_text("L-VWAP: " + str.tostring(vwap_l, "#.##"))
    lb_a.set_xy(bar_index + label_off, vwap_a)
    lb_a.set_text(na(vwap_a) ? "" : "A-VWAP: " + str.tostring(vwap_a, "#.##"))
    lb_a.set_color(na(vwap_a) ? color.new(color_a, 100) : color_a)
````
