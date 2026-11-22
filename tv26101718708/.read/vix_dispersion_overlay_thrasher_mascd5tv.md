# VIX Dispersion Overlay Thrasher

- url: https://www.tradingview.com/script/mASCD5TV-VIX-Dispersion-Overlay-Thrasher/
- type: indicator
- pine_id: PUB;75b11fb38bf347ecae874d099ab47c8a
- version: 2.0

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
The overlay script colours your price chart background and marks signal bars with directional triangles. The companion pane script plots the two StdDev lines against their threshold levels, with a scaled VIX level in the background for low-VIX context. A live status table shows current readings for VIX SD, VVIX SD, VIX level, VVIX level, VIX term structure spread (VIX3M − VIX), and days since last signal.

Inputs
All thresholds are adjustable. Thrasher's original values (VIX SD ≤ 0.86, VVIX SD ≤ 3.16) represent the 15th percentile of each series from 2006–2016. A de-clustering filter suppresses repeat signals within a configurable lookback window.

Usage
Add both scripts to any SPX, SPY, or equity index chart on the daily timeframe. Data is sourced directly from CBOE:VIX, CBOE:VVIX, and CBOE:VIX3M via request.security regardless of chart symbol. Five alert conditions are included: combined signal, compound danger, VIX-only, VVIX-only, and the most extreme case — combined signal with simultaneous VIX term structure backwardation.

Reference
Thrasher, A. (2017). Forecasting a Volatility Tsunami. Journal of Technical Analysis, Q4 2017. Thresholds and signal definitions are implemented as described in the original paper and have not been curve-fitted to subsequent data.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jimmy_Trader

//@version=6
// ═══════════════════════════════════════════════════════════════
//  VIX DISPERSION SIGNAL — OVERLAY  [Thrasher]
//  Add this to your SPX / SPY / XJO price chart.
//  Pair with the companion pane script for the StdDev lines.
// ═══════════════════════════════════════════════════════════════
indicator("VIX Dispersion — Overlay [Thrasher]", shorttitle="VIX Dis OL", overlay=true, max_labels_count=500)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
grp_thresh = "Thresholds (Thrasher 2017 — 15th percentile)"
vix_thresh  = input.float(0.86, "VIX 20d StdDev threshold",  minval=0.1, step=0.01, group=grp_thresh)
vvix_thresh = input.float(3.16, "VVIX 20d StdDev threshold", minval=0.5, step=0.01, group=grp_thresh)
sd_period   = input.int(20,    "StdDev period",              minval=5,              group=grp_thresh)

grp_filter = "Signal filters"
dedup_bars   = input.int(10,   "Min bars between signals",   minval=1, group=grp_filter)
vix_low_flag = input.float(15.0, "Low VIX compound danger level", minval=5.0, group=grp_filter)

grp_disp = "Display"
show_bg     = input.bool(true,  "Background colour on signal",   group=grp_disp)
show_labels = input.bool(true,  "Show signal labels on chart",   group=grp_disp)
show_days   = input.bool(true,  "Show days-since label",         group=grp_disp)
show_table  = input.bool(true,  "Show status table",             group=grp_disp)

// ─────────────────────────────────────────────
// DATA — pulled from CBOE regardless of chart symbol
// ─────────────────────────────────────────────
vix_close  = request.security("CBOE:VIX",  timeframe.period, close, gaps=barmerge.gaps_off)
vvix_close = request.security("CBOE:VVIX", timeframe.period, close, gaps=barmerge.gaps_off)
vix3m      = request.security("CBOE:VIX3M", timeframe.period, close, gaps=barmerge.gaps_off)

// ─────────────────────────────────────────────
// 20-DAY POPULATION STANDARD DEVIATION
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

var int bars_since = 999
bars_since := combined ? 0 : bars_since + 1

combined_dedup  = combined and bars_since[1] >= dedup_bars
compound_danger = combined_dedup and vix_close < vix_low_flag

ts_spread     = vix3m - vix_close
backwardation = ts_spread < 0
vvix_high     = vvix_close > 120
vvix_stress   = vvix_close > 100 and not vvix_high

// ─────────────────────────────────────────────
// COLOURS
// ─────────────────────────────────────────────
col_lime  = color.new(#c8ff00, 0)
col_red   = color.new(#ff3b3b, 0)
col_amber = color.new(#ff8c00, 0)
col_green = color.new(#00e676, 0)
col_muted = color.new(#555555, 0)
col_text  = color.new(#f0f4ff, 0)

// ─────────────────────────────────────────────
// BACKGROUND COLOUR ON PRICE BARS
// ─────────────────────────────────────────────
bg_col = compound_danger     ? color.new(#ff3b3b, 82) :
         combined            ? color.new(#ff8c00, 82) :
         vvix_alert          ? color.new(#ff8c00, 90) :
         vix_alert           ? color.new(#c8ff00, 92) : na

bgcolor(show_bg ? bg_col : na, title="Signal background")

// ─────────────────────────────────────────────
// SIGNAL SHAPES — plotted at bar high/low
// ─────────────────────────────────────────────

// Combined signal — triangle above bar
plotshape(combined_dedup and not compound_danger,
     title="Combined Signal",
     style=shape.triangledown,
     location=location.abovebar,
     color=col_amber, size=size.small)

// Compound danger — larger red triangle above bar
plotshape(compound_danger,
     title="Compound Danger",
     style=shape.triangledown,
     location=location.abovebar,
     color=col_red, size=size.normal)

// VIX-only caution dot
plotshape(vix_alert and not vvix_alert,
     title="VIX Only (Caution)",
     style=shape.circle,
     location=location.abovebar,
     color=color.new(col_amber, 55), size=size.tiny)

// VVIX-only warning dot
plotshape(vvix_alert and not vix_alert,
     title="VVIX Only (Warning)",
     style=shape.circle,
     location=location.abovebar,
     color=color.new(#00b4ff, 55), size=size.tiny)

// ─────────────────────────────────────────────
// LABELS — signal annotation
// ─────────────────────────────────────────────
if show_labels and combined_dedup
    lbl_text = compound_danger
         ? "⚡ COMPOUND DANGER\nLow VIX + Both compressed\nVIX " + str.tostring(math.round(vix_close, 2)) + "  VVIX " + str.tostring(math.round(vvix_close, 1))
         : "⚡ TSUNAMI ALERT\nVIX + VVIX dispersion compressed\nVIX " + str.tostring(math.round(vix_close, 2)) + "  VVIX " + str.tostring(math.round(vvix_close, 1))
    lbl_col = compound_danger ? col_red : col_amber
    label.new(bar_index, high,
         text=lbl_text,
         yloc=yloc.abovebar,
         style=label.style_label_down,
         color=color.new(#111111, 10),
         textcolor=lbl_col,
         size=size.small)

// Days-since on current bar
if show_days and barstate.islast
    days_txt = bars_since == 0
         ? "⚡ Signal ACTIVE"
         : "Last signal: " + str.tostring(bars_since) + "d ago"
    days_col = bars_since == 0     ? col_red  :
               bars_since <= 15    ? col_amber : col_muted
    label.new(bar_index, high,
         text=days_txt,
         yloc=yloc.abovebar,
         style=label.style_label_left,
         color=color.new(#111111, 20),
         textcolor=days_col,
         size=size.normal)

// ─────────────────────────────────────────────
// STATUS TABLE
// ─────────────────────────────────────────────
var table t = table.new(position.top_right, 2, 8,
     bgcolor=color.new(#111111, 10),
     border_color=color.new(#222222, 0), border_width=1,
     frame_color=color.new(#333333, 0),  frame_width=1)

_c(r, c, txt, tcol) =>
    table.cell(t, c, r, txt, text_color=tcol, text_size=size.small, bgcolor=color.new(#111111, 10))

if barstate.islast and show_table
    sig_state = compound_danger  ? "⚡ COMPOUND DANGER" : combined ? "⚡ TSUNAMI ALERT" : vvix_alert  ? "WARNING" :  vix_alert ? "CAUTION" : "RISK ON" 
    sig_col = (compound_danger or combined) ? col_red :  (vix_alert or vvix_alert)  ? col_amber : col_green

    _c(0, 0, "SIGNAL",     col_muted)
    _c(0, 1, sig_state,    sig_col)
    _c(1, 0, "VIX SD",     col_muted)
    _c(1, 1, str.tostring(math.round(vix_sd,  3)) + " / " + str.tostring(vix_thresh),  vix_alert  ? col_red : col_green)
    _c(2, 0, "VVIX SD",    col_muted)
    _c(2, 1, str.tostring(math.round(vvix_sd, 3)) + " / " + str.tostring(vvix_thresh), vvix_alert ? col_red : col_green)
    _c(3, 0, "VIX",        col_muted)
    _c(3, 1, str.tostring(math.round(vix_close,  2)), vix_close < vix_low_flag ? col_amber : col_text)
    _c(4, 0, "VVIX",       col_muted)
    _c(4, 1, str.tostring(math.round(vvix_close, 1)), vvix_high ? col_red : vvix_stress ? col_amber : col_text)
    _c(5, 0, "TS Spread",  col_muted)
    _c(5, 1, (ts_spread >= 0 ? "+" : "") + str.tostring(math.round(ts_spread, 2)), backwardation ? col_red : col_green)
    _c(6, 0, "Days Since", col_muted)
    _c(6, 1, bars_since == 0 ? "ACTIVE" : str.tostring(bars_since), bars_since == 0 ? col_red : bars_since <= 15 ? col_amber : col_muted)
    _c(7, 0, "Chart",      col_muted)
    _c(7, 1, syminfo.ticker, col_text)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(combined_dedup,
     title="Combined VIX + VVIX Dispersion Signal",
     message="⚡ Tsunami Alert — Both VIX and VVIX dispersion compressed. VIX={{request.security('CBOE:VIX', 'D', close)}}")

alertcondition(compound_danger,
     title="Compound Danger: Low VIX + Combined Signal",
     message="⚡ Compound Danger — Low VIX + combined dispersion signal. Raise cash.")

alertcondition(vix_alert and not vvix_alert,
     title="VIX Dispersion Only — Caution",
     message="Caution: VIX 20d StdDev compressed below threshold.")

alertcondition(vvix_alert and not vix_alert,
     title="VVIX Dispersion Only — Warning",
     message="Warning: VVIX 20d StdDev compressed below threshold.")

alertcondition(backwardation and combined,
     title="Backwardation + Combined Signal — Extreme",
     message="⚡ Extreme Warning — VIX term structure inverted AND combined dispersion signal active.")
````
