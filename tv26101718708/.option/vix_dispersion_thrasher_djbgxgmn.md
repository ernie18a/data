# VIX Dispersion Thrasher

- url: https://www.tradingview.com/script/djBgXgMN-VIX-Dispersion-Thrasher/
- type: indicator
- pine_id: PUB;76548b7e35c84e95881c65f920786374
- version: 1.0

## Description

VIX Dispersion Signal [Thrasher]

Identifies conditions that historically precede large volatility spikes, based on the methodology published by Andrew Thrasher CMT in Forecasting a Volatility Tsunami (Journal of Technical Analysis, Q4 2017).

Core concept
Rather than treating a low VIX as a sell signal, Thrasher found that the strongest warning comes from measuring the dispersion of the VIX itself — its 20-day standard deviation. When the VIX stops moving and trades in an unusually narrow range, volatility is coiling. The same logic applied to the VVIX (the volatility of the VIX) improves timing further. When both compress simultaneously, the historical record shows a clear edge: nearly every combined signal was followed by a 30%+ VIX spike within 15 trading days, with an average maximum move of +27.5%.
Signal states

🟢 Risk On — both readings above threshold, normal conditions
🟡 Caution — VIX dispersion compressed (≤ 0.86), tighten stops
🟡 Warning — VVIX dispersion compressed (≤ 3.16), reduce exposure
🔴 Tsunami Alert — both thresholds breached simultaneously, raise cash
🔴 Compound Danger — Tsunami Alert firing while VIX is also sub-15, highest historical risk

What's plotted
The script plots the two StdDev lines against their threshold levels, with a scaled VIX level in the background for low-VIX context.

All thresholds are adjustable. Thrasher's original values (VIX SD ≤ 0.86, VVIX SD ≤ 3.16) represent the 15th percentile of each series from 2006–2016. A de-clustering filter suppresses repeat signals within a configurable lookback window.

Usage
Add script to any SPX, SPY, or equity index chart on the daily timeframe. Data is sourced directly from CBOE:VIX, CBOE:VVIX, and CBOE:VIX3M via request.security regardless of chart symbol. Five alert conditions are included: combined signal, compound danger, VIX-only, VVIX-only, and the most extreme case — combined signal with simultaneous VIX term structure backwardation.

Reference
Thrasher, A. (2017). Forecasting a Volatility Tsunami. Journal of Technical Analysis, Q4 2017. Thresholds and signal definitions are implemented as described in the original paper and have not been curve-fitted to subsequent data.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jimmy_Trader

//@version=6
// ═══════════════════════════════════════════════════════════════
//  VIX DISPERSION SIGNAL — INDICATOR PANE  [Thrasher]
//  Add this as a separate pane beneath your SPX / SPY chart.
//  Companion to the overlay script — use identical threshold inputs.
// ═══════════════════════════════════════════════════════════════
indicator("VIX Dispersion — Pane [Thrasher]", shorttitle="VIX Disp", overlay=false, max_labels_count=100)

// ─────────────────────────────────────────────
// INPUTS  (keep in sync with overlay script)
// ─────────────────────────────────────────────
grp_thresh = "Thresholds (Thrasher 2017 — 15th percentile)"
vix_thresh  = input.float(0.86, "VIX 20d StdDev threshold",  minval=0.1, step=0.01, group=grp_thresh)
vvix_thresh = input.float(3.16, "VVIX 20d StdDev threshold", minval=0.5, step=0.01, group=grp_thresh)
sd_period   = input.int(20,    "StdDev period",              minval=5,              group=grp_thresh)

grp_disp = "Display"
show_vix_sd  = input.bool(true,  "Show VIX StdDev line",    group=grp_disp)
show_vvix_sd = input.bool(true,  "Show VVIX StdDev line",   group=grp_disp)
show_thresh  = input.bool(true,  "Show threshold lines",    group=grp_disp)
show_bg      = input.bool(true,  "Background on signal",    group=grp_disp)
show_vix_lvl = input.bool(true,  "Show VIX level (right axis)", group=grp_disp)

// ─────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────
vix_close  = request.security("CBOE:VIX",  timeframe.period, close, gaps=barmerge.gaps_off)
vvix_close = request.security("CBOE:VVIX", timeframe.period, close, gaps=barmerge.gaps_off)

// ─────────────────────────────────────────────
// POPULATION STDDEV
// ─────────────────────────────────────────────
vix_mean  = ta.sma(vix_close,  sd_period)
vvix_mean = ta.sma(vvix_close, sd_period)

vix_var  = 0.0
vvix_var = 0.0
for i = 0 to sd_period - 1
    vix_var  := vix_var  + math.pow(vix_close[i]  - vix_mean,  2)
    vvix_var := vvix_var + math.pow(vvix_close[i] - vvix_mean, 2)

vix_sd  = math.sqrt(vix_var  / sd_period)
vvix_sd = math.sqrt(vvix_var / sd_period)

// ─────────────────────────────────────────────
// SIGNAL CONDITIONS
// ─────────────────────────────────────────────
vix_alert  = vix_sd  <= vix_thresh
vvix_alert = vvix_sd <= vvix_thresh
combined   = vix_alert and vvix_alert

// ─────────────────────────────────────────────
// COLOURS
// ─────────────────────────────────────────────
col_lime    = color.new(#c8ff00, 0)
col_red     = color.new(#ff3b3b, 0)
col_amber   = color.new(#ff8c00, 0)
col_green   = color.new(#00e676, 0)
col_blue    = color.new(#00b4ff, 0)
col_muted   = color.new(#555555, 0)

col_vix_line  = vix_alert  ? col_red  : col_lime
col_vvix_line = vvix_alert ? col_red  : col_blue

// ─────────────────────────────────────────────
// BACKGROUND
// ─────────────────────────────────────────────
bg_col = combined   ? color.new(#ff8c00, 88) :
         vvix_alert ? color.new(#ff8c00, 93) :
         vix_alert  ? color.new(#c8ff00, 93) : na
bgcolor(show_bg ? bg_col : na, title="Signal background")

// ─────────────────────────────────────────────
// STDDEV LINES
// ─────────────────────────────────────────────
plot(show_vix_sd  ? vix_sd  : na, "VIX 20d StdDev",  color=col_vix_line,  linewidth=2)
plot(show_vvix_sd ? vvix_sd : na, "VVIX 20d StdDev", color=col_vvix_line, linewidth=2)

// Threshold lines
plot(show_thresh ? vix_thresh  : na, "VIX Threshold",
     color=color.new(col_lime, 50), linewidth=1, style=plot.style_line)
plot(show_thresh ? vvix_thresh : na, "VVIX Threshold",
     color=color.new(col_blue, 60), linewidth=1, style=plot.style_line)

// Zero baseline
hline(0, color=color.new(#222222, 0), linestyle=hline.style_solid, linewidth=1)

// ─────────────────────────────────────────────
// SIGNAL DOTS (bottom of pane)
// ─────────────────────────────────────────────
plotshape(combined,
     title="Combined Signal",
     style=shape.triangleup, location=location.bottom,
     color=col_amber, size=size.small)

plotshape(vix_alert and not vvix_alert,
     title="VIX Only",
     style=shape.circle, location=location.bottom,
     color=color.new(col_lime, 55), size=size.tiny)

plotshape(vvix_alert and not vix_alert,
     title="VVIX Only",
     style=shape.circle, location=location.bottom,
     color=color.new(col_blue, 55), size=size.tiny)

// ─────────────────────────────────────────────
// VIX LEVEL — plotted on secondary axis (scaled)
// Scaled to roughly overlap StdDev range (÷20)
// Toggle off if distracting
// ─────────────────────────────────────────────
vix_scaled = vix_close / 20
plot(show_vix_lvl ? vix_scaled : na, "VIX Level (÷20)",
     color=color.new(col_muted, 40), linewidth=1,
     style=plot.style_area)

// ─────────────────────────────────────────────
// THRESHOLD LABELS on right edge
// ─────────────────────────────────────────────
if barstate.islast
    label.new(bar_index + 1, vix_thresh,
         text="VIX " + str.tostring(vix_thresh),
         style=label.style_label_left,
         color=na, textcolor=color.new(col_lime, 30), size=size.tiny)
    label.new(bar_index + 1, vvix_thresh,
         text="VVIX " + str.tostring(vvix_thresh),
         style=label.style_label_left,
         color=na, textcolor=color.new(col_blue, 30), size=size.tiny)
````
