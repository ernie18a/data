# ETH HOD/LOD VWAP

- url: https://www.tradingview.com/script/qzPyeYwP-ETH-HOD-LOD-VWAP/
- type: indicator
- pine_id: PUB;ea67c017191b41c38319a9185ad59038
- version: 2.0

## Description

Written for: TradingView users reading the indicator's description.

ETH HOD/LOD VWAP

This indicator draws two anchored VWAPs: one from the high of day and one from the low of day of the full Globex (ETH) session, 18:00–17:00 New York time.

When price makes a new session high, the H-VWAP (red) re-anchors to that bar and builds its VWAP from there. The L-VWAP (cyan) does the same from each new session low. Both reset at the start of every new ETH session, including the Sunday open.

The two lines show the volume-weighted average price of everyone who has traded since the current extreme. That makes them useful as dynamic support and resistance, and for judging whether buyers or sellers are in control after the high or low is set.

Notes

Turn on Extended Trading Hours on your chart, or the overnight highs and lows will be missed.
Built for CME futures (NQ, ES, etc.). Works on any intraday timeframe.
You can change the line colors, line thickness and label offset.

## Source Code

````pine
//@version=6
indicator("ETH HOD/LOD VWAP", overlay = true, precision = 2, max_bars_back = 5000)

// ─── Inputs ───────────────────────────────────────────────────────────────────
string anchor_src = input.string("Close", "Anchor On", options = ["Close", "Wick"], group = "Settings",
     tooltip = "Close = highest/lowest candle close of the session. Wick = session high/low.")

color color_hod = input.color(color.new(#ff5252, 0), "HOD Line",      group = "Aesthetics")
color color_lod = input.color(color.new(#00f2ff, 0), "LOD Line",      group = "Aesthetics")
int   width_hod = input.int(1, "HOD Thickness", minval = 1, maxval = 4, group = "Aesthetics")
int   width_lod = input.int(1, "LOD Thickness", minval = 1, maxval = 4, group = "Aesthetics")
int   label_off = input.int(2, "Label Offset", minval = 0,              group = "Aesthetics")

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
float bar_vwp = hlc3 * volume

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

if barstate.islast
    lb_h.set_xy(bar_index + label_off, vwap_h)
    lb_h.set_text("H-VWAP: " + str.tostring(vwap_h, "#.##"))
    lb_l.set_xy(bar_index + label_off, vwap_l)
    lb_l.set_text("L-VWAP: " + str.tostring(vwap_l, "#.##"))
````
