# iFCPO Session AVWAP

- url: https://www.tradingview.com/script/vg5y31SE-iFCPO-Session-AVWAP/
- type: indicator
- pine_id: PUB;e1ffea7306ba4f7a946c87aea39d56e2
- version: 1.0

## Description

iFCPO Session Anchored VWAP — three FCPO-relevant anchors for institutional reference price.

Anchor modes:
- AM Open (10:30 MYT)
- PM Open (14:30 MYT) - default, aligns with W18 Edge Zone start
- Custom date (any session anchor)

Plots VWAP + plus/minus 1 sigma bands. Cumulative price-volume + variance reset on anchor reset. Useful as institutional reference price for fade/breakout setups.

FREE indicator from iFCPO — Malaysia palm-oil futures trading platform.

## Source Code

````pine
//@version=6
// iFCPO Session Anchored VWAP — three FCPO-relevant anchors
// Tier: FREE | Category: Volume
indicator("iFCPO Session AVWAP", "iFCPO Vwp", overlay = true)

anchor_mode = input.string("PM Open", "Anchor", options = ["AM Open", "PM Open", "Custom date"], group = "Anchor")
custom_y    = input.int(2025, "Custom year",  minval = 2000, maxval = 2100, group = "Custom")
custom_m    = input.int(1,    "Custom month", minval = 1,    maxval = 12,   group = "Custom")
custom_d    = input.int(1,    "Custom day",   minval = 1,    maxval = 31,   group = "Custom")
show_bands  = input.bool(true,  "Show plus/minus 1 sigma bands", group = "Display")
band_mult   = input.float(1.0, "Band sigma multiplier", minval = 0.5, maxval = 3.0, step = 0.5, group = "Display")

vwap_col   = input.color(#3B82F6, "VWAP color",  group = "Colors")
band_col   = input.color(color.new(#3B82F6, 75), "Band color", group = "Colors")

TZ = "Asia/Kuala_Lumpur"

is_am_open = hour(time, TZ) == 10 and minute(time, TZ) >= 30 and minute(time, TZ) < 35
is_pm_open = hour(time, TZ) == 14 and minute(time, TZ) >= 30 and minute(time, TZ) < 35
is_custom_anchor = year(time, TZ) == custom_y and month(time, TZ) == custom_m and dayofmonth(time, TZ) == custom_d and is_pm_open

reset = anchor_mode == "AM Open" ? is_am_open
       : anchor_mode == "PM Open" ? is_pm_open
       : is_custom_anchor

var float cum_pv = na
var float cum_v  = na
var float cum_pv2 = na

src    = (high + low + close) / 3.0
volume_safe = nz(volume, 1.0)
pv     = src * volume_safe
pv2    = src * src * volume_safe

if reset
    cum_pv := pv
    cum_v  := volume_safe
    cum_pv2 := pv2
else
    cum_pv := nz(cum_pv) + pv
    cum_v  := nz(cum_v) + volume_safe
    cum_pv2 := nz(cum_pv2) + pv2

vwap = cum_v > 0 ? cum_pv / cum_v : na
variance = cum_v > 0 ? cum_pv2 / cum_v - (vwap * vwap) : na
sigma = variance > 0 ? math.sqrt(variance) : na

upper = vwap + sigma * band_mult
lower = vwap - sigma * band_mult

plot(vwap, "AVWAP", color = vwap_col, linewidth = 2)
plot(show_bands ? upper : na, "+sigma", color = band_col, linewidth = 1)
plot(show_bands ? lower : na, "-sigma", color = band_col, linewidth = 1)

if reset
    label.new(bar_index, high, anchor_mode + " anchor",
       color = color.new(vwap_col, 30), textcolor = color.white,
       style = label.style_label_down, size = size.tiny)
````
