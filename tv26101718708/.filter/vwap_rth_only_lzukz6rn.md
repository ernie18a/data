# VWAP - RTH Only 

- url: https://www.tradingview.com/script/lzUkZ6Rn-VWAP-RTH-Only/
- type: indicator
- pine_id: PUB;098ad0287d824d21ae858b9dc1e976ed
- version: 1.0

## Description

This indicator uses the same logic as the default VWAP indicator. But, this indictor doesn't take into calculation the candles formed during the pre-market or afterhours. So, the calculation for VWAP is accurate even though when the ETH ( extended trading hours) session is used in trading view.

## Source Code

````pine
//@version=6
indicator(title = "VWAP - RTH Only (IST Friendly)", shorttitle = "RTH VWAP IST", overlay = true)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
show_bands1 = input.bool(true,  "Show SD1 Bands")
show_bands2 = input.bool(true,  "Show SD2 Bands")
show_bands3 = input.bool(false, "Show SD3 Bands")
mult1       = input.float(1.0,  "SD Multiplier 1", step = 0.1, minval = 0.1)
mult2       = input.float(2.0,  "SD Multiplier 2", step = 0.1, minval = 0.1)
mult3       = input.float(3.0,  "SD Multiplier 3", step = 0.1, minval = 0.1)
show_label  = input.bool(true,  "Show IST session label on chart")

vwap_color  = input.color(color.new(#2196F3, 0),  "VWAP Line Color")
band1_color = input.color(color.new(#FF9800, 60), "SD1 Band Color")
band2_color = input.color(color.new(#F44336, 60), "SD2 Band Color")
band3_color = input.color(color.new(#9C27B0, 60), "SD3 Band Color")
label_color = input.color(color.new(#2196F3, 80), "Session Label Background")

// ─────────────────────────────────────────────
// RTH FILTER — America/New_York 09:30–16:00
// TradingView handles EST↔EDT (DST) automatically
// via the "America/New_York" timezone string.
//
// IST (UTC+5:30) never observes DST, so the RTH
// window in IST shifts by 1 hour each US season:
//   EDT (Mar–Nov): 19:00 IST → 01:30 IST (+1 day)
//   EST (Nov–Mar): 20:00 IST → 02:30 IST (+1 day)
// ─────────────────────────────────────────────
int  rth_time = time(timeframe.period, "0930-1600", "America/New_York")
bool is_rth   = not na(rth_time)

// ─────────────────────────────────────────────
// DST DETECTION
// Compare UTC hour vs New York local hour.
// EDT = UTC-4  →  difference is 4
// EST = UTC-5  →  difference is 5
// ─────────────────────────────────────────────
int  ny_hour   = hour(time, "America/New_York")
int  utc_hour  = hour(time, "UTC")
int  utc_to_ny = (utc_hour - ny_hour + 24) % 24
bool is_edt    = utc_to_ny == 4

string ist_open  = is_edt ? "19:00 IST"            : "20:00 IST"
string ist_close = is_edt ? "01:30 IST (+1 day)"   : "02:30 IST (+1 day)"
string dst_note  = is_edt ? "EDT active (US Summer)": "EST active (US Winter)"

// ─────────────────────────────────────────────
// SESSION START DETECTION
// Fires on the first RTH bar of each trading day
// ─────────────────────────────────────────────
bool is_new_day       = dayofmonth(time) != dayofmonth(time[1])
bool is_session_start = is_rth and (is_new_day or (not is_rth[1] and is_rth))

// ─────────────────────────────────────────────
// VWAP CALCULATION (RTH bars only)
// Uses volume-weighted typical price (HLC/3)
// Resets at the start of every RTH session
// ─────────────────────────────────────────────
var float cum_vol = 0.0
var float cum_vp  = 0.0   // Σ volume × typical_price
var float cum_vp2 = 0.0   // Σ volume × typical_price² (for variance)

float typical_price = (high + low + close) / 3.0

if is_session_start
    cum_vol := 0.0
    cum_vp  := 0.0
    cum_vp2 := 0.0

if is_rth
    cum_vol += volume
    cum_vp  += volume * typical_price
    cum_vp2 += volume * math.pow(typical_price, 2)

float vwap_val = cum_vol > 0.0 ? cum_vp / cum_vol : na
float variance = cum_vol > 0.0 ? (cum_vp2 / cum_vol) - math.pow(vwap_val, 2) : na
float std_dev  = variance > 0.0 ? math.sqrt(variance) : na

float upper1 = vwap_val + mult1 * std_dev
float lower1 = vwap_val - mult1 * std_dev
float upper2 = vwap_val + mult2 * std_dev
float lower2 = vwap_val - mult2 * std_dev
float upper3 = vwap_val + mult3 * std_dev
float lower3 = vwap_val - mult3 * std_dev

// ─────────────────────────────────────────────
// PLOTS — na outside RTH so lines stay clean
// ─────────────────────────────────────────────
float plot_vwap = is_rth ? vwap_val : na
float plot_u1   = is_rth and show_bands1 ? upper1 : na
float plot_l1   = is_rth and show_bands1 ? lower1 : na
float plot_u2   = is_rth and show_bands2 ? upper2 : na
float plot_l2   = is_rth and show_bands2 ? lower2 : na
float plot_u3   = is_rth and show_bands3 ? upper3 : na
float plot_l3   = is_rth and show_bands3 ? lower3 : na

// VWAP main line
plot(plot_vwap, title = "RTH VWAP", color = vwap_color, linewidth = 2)

// SD1 band + fill
plotObj_u1 = plot(plot_u1, title = "SD1 Upper", color = band1_color, linewidth = 1)
plotObj_l1 = plot(plot_l1, title = "SD1 Lower", color = band1_color, linewidth = 1)
fill(plotObj_u1, plotObj_l1, color = color.new(band1_color, 90), title = "SD1 Fill")

// SD2 band + fill
plotObj_u2 = plot(plot_u2, title = "SD2 Upper", color = band2_color, linewidth = 1)
plotObj_l2 = plot(plot_l2, title = "SD2 Lower", color = band2_color, linewidth = 1)
fill(plotObj_u2, plotObj_l2, color = color.new(band2_color, 92), title = "SD2 Fill")

// SD3 band + fill
plotObj_u3 = plot(plot_u3, title = "SD3 Upper", color = band3_color, linewidth = 1)
plotObj_l3 = plot(plot_l3, title = "SD3 Lower", color = band3_color, linewidth = 1)
fill(plotObj_u3, plotObj_l3, color = color.new(band3_color, 94), title = "SD3 Fill")

// ─────────────────────────────────────────────
// IST SESSION LABEL
// Shown once at each RTH session open.
// Displays IST window + current DST status.
// ─────────────────────────────────────────────
if show_label and is_session_start and barstate.isconfirmed
    label.new(
      x         = bar_index,
      y         = vwap_val,
      text      = "RTH VWAP Start\n" + ist_open + " → " + ist_close + "\n(" + dst_note + ")",
      style     = label.style_label_right,
      color     = label_color,
      textcolor = color.white,
      size      = size.small
     )
````
