# Directional Purity

- url: https://www.tradingview.com/script/bk8SieSg-Directional-Purity/
- type: indicator
- pine_id: PUB;d93e6e64b18e4f1fa562fd0b853b738c
- version: 6.0

## Description

Directional Purity [Community Edition]

Rather than a simple standalone strategy, Directional Purity is a professional trend-filtering and directional stability engine designed to supercharge any existing trading strategy. It eliminates the fatal flaw of traditional indicators like ADX—which measure trend strength with significant lag—by equipping your strategy with a zero-lag, mathematically precise gauge of directional purity.

Traditionally, ADX relies on double-smoothed EMAs of directional movements, causing delayed responses to trend breakouts and exhaustion. Directional Purity resolves this by using the mathematical equivalence of Chande's CMO and Kaufman's Efficiency Ratio (ER) as a volatility index to dynamically adapt a 13-period VIDYA (Variable Index Dynamic Average) base.

By utilizing a telescoping sum optimization, this script is fully vectorized (loop-free), ensuring extremely fast execution on any time frame.

Features:
- Live Dashboard: Shows real-time market state (Trending Bullish, Trending Bearish, Ranging) and Trend Purity %.
- Visual Fills: Highlights ranging zones in gray to prevent overtrading.
- Built-in Alerts: Triggers for trend breakouts, entering ranges, and direction shifts.
```

## Source Code

````pine
//@version=6
// © trendmastera
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

indicator("Directional Purity", shorttitle="DirPurity", overlay=false, precision=4, max_labels_count=500)

// ── Description ──────────────────────────────────────────────────────────
// Developed by trendmastera
//
// "Directional Purity" is a momentum and trend strength indicator.
// Traditionally, trend strength indicators like ADX suffer from significant lag
// because they rely on double-smoothed moving averages of directional movement.
//
// This indicator resolves the lag problem by applying the math of Kaufman's
// Efficiency Ratio (ER) as a "Directional Purity" regulator, which is then used
// dynamically as the smoothing multiplier (vi) inside a 13-period VIDYA
// (Variable Index Dynamic Average) framework.
//
// The core insight:
// Chande's CMO absolute value and Kaufman's Efficiency Ratio (ER) are mathematically
// equivalent when calculated via a telescoping sum. By identifying this relationship,
// we can implement a highly optimized, loop-free, vectorized calculation that runs
// instantaneously on large histories.
//
// REAL-TIME BEHAVIOR & ALERTS:
// On the live (unconfirmed) bar, values update tick by tick; signals may appear
// and disappear intrabar until the bar closes. This is standard indicator behavior,
// not lookahead repainting — historical bars never change. To avoid intrabar noise,
// either enable "Calculate Only on Bar Close" in the settings, or configure your
// alerts with the "Once Per Bar Close" trigger option.

// ── Inputs ────────────────────────────────────────────────────────────────
cmo_period     = input.int  (9,    "CMO/ER Period",    minval=1, group="Indicator Parameters", tooltip="Period used to calculate the Directional Purity (Efficiency Ratio). Smaller values react faster; larger values are smoother.")
vidya_period   = input.int  (13,   "VIDYA Period",     minval=1, group="Indicator Parameters", tooltip="Base period for the VIDYA recursive smoothing anchor. Default is 13.")
threshold      = input.float(0.25, "Trend Threshold",  minval=0.0, maxval=1.0, step=0.05, group="Indicator Parameters", tooltip="Purity level below which the market is considered to be ranging/consolidating.")
smooth_period  = input.int  (3,    "Purity Smoothing Period", minval=1, group="Indicator Parameters", tooltip="Smooths the Directional Purity line using an EMA to filter out high-frequency noise. Set to 1 for raw values.")
hysteresis_val = input.float(0.05, "Hysteresis Buffer",  minval=0.0, maxval=0.2, step=0.01, group="Indicator Parameters", tooltip="Prevents rapid transitions. Purity must fall this much below the threshold to return to a ranging state. The lower threshold is floored at 0.")
calc_on_close  = input.bool(false, "Calculate Only on Bar Close", group="Indicator Parameters", tooltip="When enabled, calculations are only updated when a bar closes. This prevents real-time fluctuations (jitter) from price ticks.")

// Colors
col_bull  = input.color(#089981, "Bullish", group="Colors", inline="c1")
col_bear  = input.color(#F23645, "Bearish", group="Colors", inline="c1")
col_range = input.color(#787B86, "Ranging", group="Colors", inline="c1")
col_bg_range = color.new(col_range, 92)

// Visual Settings & Displays
show_dashboard      = input.bool(true,  "Show Info Dashboard on Main Chart", group="Visual Settings & Dashboard", tooltip="Displays a mini table panel with real-time stats directly on the main price chart.")
dashboard_pos       = input.string(position.top_right, "Dashboard Position", options=[position.top_right, position.top_left, position.bottom_right, position.bottom_left], group="Visual Settings & Dashboard", tooltip="Position of the info dashboard.")
show_vidya_on_main  = input.bool(true,  "Show 13 VIDYA Line on Main Chart", group="Visual Settings & Dashboard", tooltip="Plots the color-coded VIDYA trend line overlay on the main price chart.")
show_signals        = input.bool(true,  "Show Breakout Signals on Main Chart", group="Visual Settings & Dashboard", tooltip="Displays breakout triangle shapes on the main chart when a new trend starts.")
color_bars          = input.bool(false, "Color Price Bars based on Trend", group="Visual Settings & Dashboard", tooltip="Colors main price candlesticks according to the current trend state.")
show_range_bg       = input.bool(true,  "Highlight Range on Main Background", group="Visual Settings & Dashboard", tooltip="Fills the background of the main price chart during ranging/consolidation periods.")

// ── Real-Time Normalization ──────────────────────────────────────────────
src = calc_on_close and not barstate.isconfirmed ? close[1] : close

// ── Mathematical Engine (Vectorized) ──────────────────────────────────────
// Mathematically equivalent to the manual loop but computes exponentially faster in TradingView's runtime.
f_directional_purity(src_val, len) =>
    change = math.abs(src_val - src_val[len])
    volatility = math.sum(math.abs(src_val - src_val[1]), len)
    volatility == 0.0 ? 0.0 : change / volatility

// ── VIDYA (Recursive) ─────────────────────────────────────────────────────
var float vidya = na
k = 2.0 / (vidya_period + 1.0)
raw_vi = f_directional_purity(src, cmo_period)
vi_ema = ta.ema(raw_vi, smooth_period)
vi = smooth_period > 1 ? vi_ema : raw_vi

// Maintain stability during startup when vi is na
if na(vi)
    vidya := src
else
    vidya := na(vidya[1]) ? src : vidya[1] + k * vi * (src - vidya[1])

// Hide unstable values until the ER window and its smoothing EMA are fully primed
warmup_done = bar_index >= cmo_period + smooth_period

// ── State & Trend Logic ───────────────────────────────────────────────────
purity  = vi
// Floored at 0 so the ranging state always stays reachable (purity is never negative)
lower_threshold = math.max(threshold - hysteresis_val, 0.0)
var bool ranging = true

if not na(purity)
    if purity >= threshold
        ranging := false
    else if purity < lower_threshold
        ranging := true

// Determine Trend Direction relative to VIDYA
is_bullish = src > vidya
is_bearish = not is_bullish

// Assign colors based on state
col = ranging    ? col_range :
      is_bullish ? col_bull  :
                   col_bear

// ── Plots in Sub-Pane (overlay = false) ───────────────────────────────────
// Plot the Directional Purity line
plot(purity, "Directional Purity", color=col, linewidth=2, style=plot.style_line)

// Baseline bands
hline(threshold, "Threshold Line", color=color.new(col_range, 50), linestyle=hline.style_dashed)
plot(hysteresis_val > 0 ? lower_threshold : na, "Lower Threshold Line", color=color.new(col_range, 70), style=plot.style_circles)
hline(1.0,       "Top Band",  color=color.new(col_range, 75))
hline(0.0,       "Zero Band", color=color.new(col_range, 75))

// Threshold value label on the right side of the sub-pane
var label thresh_label = na
if barstate.islast
    label_text = "Threshold: " + str.tostring(threshold, "0.00") + (hysteresis_val > 0 ? " (Hyst: " + str.tostring(lower_threshold, "0.00") + ")" : "")
    if na(thresh_label)
        thresh_label := label.new(
             x=bar_index + 2,
             y=threshold,
             text=label_text,
             color=color.new(col_range, 20),
             textcolor=color.white,
             style=label.style_label_left,
             size=size.small
         )
    else
        label.set_x(thresh_label, bar_index + 2)
        label.set_y(thresh_label, threshold)
        label.set_text(thresh_label, label_text)

// ── Plots on Main Chart (force_overlay = true) ────────────────────────────
// Plot the 13 VIDYA Trend Line on the Main Chart
plot(show_vidya_on_main and warmup_done ? vidya : na, "13 VIDYA Trend Line", color=col, linewidth=3, force_overlay=true)

// Trend Breakout & Reversal Signals on the Main Chart
trend_breakout_bull = (ranging[1] and not ranging) and is_bullish
trend_breakout_bear = (ranging[1] and not ranging) and is_bearish
trend_reversal_bull = (not ranging and not ranging[1]) and (is_bullish and is_bearish[1])
trend_reversal_bear = (not ranging and not ranging[1]) and (is_bearish and is_bullish[1])

bull_signal = warmup_done and (trend_breakout_bull or trend_reversal_bull)
bear_signal = warmup_done and (trend_breakout_bear or trend_reversal_bear)

plotshape(show_signals and bull_signal, title="Bullish Breakout", style=shape.triangleup, location=location.belowbar, color=col_bull, size=size.small, force_overlay=true)
plotshape(show_signals and bear_signal, title="Bearish Breakout", style=shape.triangledown, location=location.abovebar, color=col_bear, size=size.small, force_overlay=true)

// Color price bars on the Main Chart (inherently overlays on price bars)
barcolor(color_bars and warmup_done ? col : na, title="Trend Bar Color")

// Highlight range background on the Main Chart
bgcolor(show_range_bg and warmup_done and ranging ? col_bg_range : na, title="Range Background Highlight", force_overlay=true)

// ── Info Dashboard on Main Chart (force_overlay = true) ───────────────────
var table info_table = show_dashboard ? table.new(dashboard_pos, 2, 3, bgcolor=color.new(color.black, 30), border_width=1, border_color=color.new(col_range, 50), force_overlay=true) : na
if show_dashboard and barstate.islast
    // Header Row
    table.cell(info_table, 0, 0, "Metric",           bgcolor=color.new(col_range, 30), text_color=color.white, text_size=size.small, text_halign=text.align_center)
    table.cell(info_table, 1, 0, "Value",            bgcolor=color.new(col_range, 30), text_color=color.white, text_size=size.small, text_halign=text.align_center)
    
    // Row 1: State
    state_text = ranging ? "Ranging" : (is_bullish ? "Trending Bullish" : "Trending Bearish")
    state_col  = ranging ? col_range : (is_bullish ? col_bull : col_bear)
    table.cell(info_table, 0, 1, "Market State",     bgcolor=color.new(color.black, 50),   text_color=color.white, text_size=size.small)
    table.cell(info_table, 1, 1, state_text,          bgcolor=color.new(state_col, 80),     text_color=color.white, text_size=size.small, text_halign=text.align_center)
    
    // Row 2: Trend Strength (Purity)
    purity_str = na(purity) ? "N/A" : str.tostring(purity, "0.00")
    table.cell(info_table, 0, 2, "Purity (Strength)", bgcolor=color.new(color.black, 50),   text_color=color.white, text_size=size.small)
    table.cell(info_table, 1, 2, purity_str,          bgcolor=color.new(color.black, 50),   text_color=state_col, text_size=size.small, text_halign=text.align_center)

// ── Alert Conditions ──────────────────────────────────────────────────────
alertcondition(ta.change(ranging) and not ranging, title="Trend Breakout", message="DirPurity {{ticker}} {{interval}}: purity crossed above threshold — trend is accelerating.")
alertcondition(ta.change(ranging) and ranging,     title="Consolidation Range", message="DirPurity {{ticker}} {{interval}}: purity fell below lower threshold — market entering a range.")
alertcondition(is_bullish != is_bullish[1] and not ranging and not ranging[1], title="Trend Direction Change", message="DirPurity {{ticker}} {{interval}}: trend direction flipped relative to VIDYA base.")
````
