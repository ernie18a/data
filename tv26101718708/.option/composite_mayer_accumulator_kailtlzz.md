# Composite + Mayer Accumulator

- url: https://www.tradingview.com/script/kailtlzZ-Composite-Mayer-Accumulator/
- type: indicator
- pine_id: PUB;6350404ff5d34e6a92411fb939218c52
- version: 2.0

## Description

It's looking at QQQ (or choice) and VIX over a longer timeframe to identify when the market is either deeply oversold or dangerously overextended. On the buy side it flags three levels of capitulation, from mild pullback to full crash. On the sell side it flags three levels of euphoria, from slightly stretched to historically overheated. It also tracks a Mayer Multiple, which is basically just asking whether the market is cheap or expensive relative to its own history. You check it once a day. It's not for scalping.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © eli2k_rodgers

//@version=6
indicator("Composite + Mayer Accumulator (Indicator)", overlay=true, max_labels_count=500)

// ──────────────────────────────────────────────
// 1. Configuration Inputs
// ──────────────────────────────────────────────
ticker_1x  = input.symbol("NASDAQ:QQQ", title="1x Underlying Index")
ticker_vix = input.symbol("TVC:VIX",    title="Volatility Index (VIX)")
length_sma = input.int(200, title="Baseline SMA Length")
length_rsi = input.int(14,  title="RSI Length")

// Mayer Multiple Thresholds
mm_buy_threshold = input.float(0.85, title="Mayer Multiple Deep Value")
mm_top_threshold = input.float(1.15, title="Mayer Multiple Euphoria")
vix_low_threshold = input.float(12.0, title="VIX Complacency Threshold (Tier 2 Top)")

// Visual toggles
show_shapes = input.bool(true,  title="Show Signal Markers", group="Display")
show_labels = input.bool(false, title="Show Signal Labels", group="Display")

// ──────────────────────────────────────────────
// 2. Macro Structural Data (1x Index & VIX)
// ──────────────────────────────────────────────
idx_close = request.security(ticker_1x, timeframe.period, close)
idx_sma   = request.security(ticker_1x, timeframe.period, ta.sma(close, length_sma))
idx_stdev = request.security(ticker_1x, timeframe.period, ta.stdev(close, length_sma))
idx_rsi   = request.security(ticker_1x, timeframe.period, ta.rsi(close, length_rsi))
vix_close = request.security(ticker_vix, timeframe.period, close)

// ──────────────────────────────────────────────
// 3. System Metrics
// ──────────────────────────────────────────────
z_score        = (idx_close - idx_sma) / idx_stdev
mayer_multiple = idx_close / idx_sma
is_bull        = idx_close > idx_sma

// ──────────────────────────────────────────────
// 4. Signal Conditions
// ──────────────────────────────────────────────
// Volatility-Adaptive Capitulation Bottoms
tier1_capitulation = (idx_rsi < 30 and z_score <= -2.0) or (idx_rsi < 35 and z_score <= -1.8 and vix_close >= 35.0)
tier2_capitulation = (z_score <= -2.8 and vix_close >= 35.0) or (z_score <= -2.0 and vix_close >= 45.0)
tier3_mayer_value  = (mayer_multiple <= mm_buy_threshold) or (mayer_multiple <= mm_buy_threshold + 0.03 and vix_close >= 35.0)

// Momentum-Exhaustive Euphoria Tops (Requires price to cross under 10 EMA to confirm rollover)
idx_ema10          = request.security(ticker_1x, timeframe.period, ta.ema(close, 10))
cross_below_ema10  = ta.crossunder(idx_close, idx_ema10)

t1_euph_zone       = idx_rsi > 70 and z_score >= 2.0
t3_euph_zone       = mayer_multiple >= mm_top_threshold

// Check if euphoria occurred within the last 5 bars (exhaustion window)
t1_euph_active     = ta.barssince(t1_euph_zone) < 5
t3_euph_active     = ta.barssince(t3_euph_zone) < 5

tier1_euphoria     = cross_below_ema10 and t1_euph_active
tier2_euphoria     = z_score >= 3.0 and vix_close <= vix_low_threshold and cross_below_ema10
tier3_mayer_top    = cross_below_ema10 and t3_euph_active

// ──────────────────────────────────────────────
// 5. State Management (Lockout for Signal Dedup)
// ──────────────────────────────────────────────
var int last_t1_bar = 0
var int last_t2_bar = 0
var int last_t3_bar = 0
var int t1_count    = 0
var int t2_count    = 0
var int t3_count    = 0

var int last_top1_bar = 0
var int last_top2_bar = 0
var int last_top3_bar = 0
var int top1_count    = 0
var int top2_count    = 0
var int top3_count    = 0

int lockout_period  = 5

// Filtered signals (respecting lockout)
bool t1_signal   = tier1_capitulation and (bar_index - last_t1_bar) > lockout_period
bool t2_signal   = tier2_capitulation and (bar_index - last_t2_bar) > lockout_period
bool t3_signal   = tier3_mayer_value  and (bar_index - last_t3_bar) > lockout_period

bool top1_signal = tier1_euphoria     and (bar_index - last_top1_bar) > lockout_period
bool top2_signal = tier2_euphoria     and (bar_index - last_top2_bar) > lockout_period
bool top3_signal = tier3_mayer_top    and (bar_index - last_top3_bar) > lockout_period

if t1_signal
    t1_count    += 1
    last_t1_bar := bar_index
if t2_signal
    t2_count    += 1
    last_t2_bar := bar_index
if t3_signal
    t3_count    += 1
    last_t3_bar := bar_index

if top1_signal
    top1_count    += 1
    last_top1_bar := bar_index
if top2_signal
    top2_count    += 1
    last_top2_bar := bar_index
if top3_signal
    top3_count    += 1
    last_top3_bar := bar_index

// ──────────────────────────────────────────────
// 6. Visual Interface — Background Shading
// ──────────────────────────────────────────────
bgcolor(tier1_capitulation ? color.new(color.green, 85) : na, title="Tier 1: Mild Capitulation Zone")
bgcolor(tier2_capitulation ? color.new(color.lime, 70)  : na, title="Tier 2: Severe Capitulation Zone")
bgcolor(tier3_mayer_value  ? color.new(color.teal, 80)  : na, title="Tier 3: Mayer Deep Value Zone")
bgcolor(tier1_euphoria     ? color.new(color.orange, 85): na, title="Tier 1: Mild Euphoria Zone")
bgcolor(tier2_euphoria     ? color.new(color.red, 70)   : na, title="Tier 2: Severe Euphoria Zone")
bgcolor(tier3_mayer_top    ? color.new(color.maroon, 80): na, title="Tier 3: Mayer Euphoria Zone")

// ──────────────────────────────────────────────
// 7. Visual Interface — Signal Markers
// ──────────────────────────────────────────────
plotshape(show_shapes and t1_signal, title="T1 Buy Signal",   style=shape.triangleup,   location=location.belowbar, color=color.green,  size=size.small,  text="T1")
plotshape(show_shapes and t2_signal, title="T2 Buy Signal",   style=shape.triangleup,   location=location.belowbar, color=color.lime,   size=size.normal, text="T2")
plotshape(show_shapes and t3_signal, title="T3 Buy Signal",   style=shape.diamond,      location=location.belowbar, color=color.teal,   size=size.small,  text="T3")
plotshape(show_shapes and top1_signal, title="T1 Top Signal", style=shape.triangledown, location=location.abovebar, color=color.orange, size=size.small,  text="Top1")
plotshape(show_shapes and top2_signal, title="T2 Top Signal", style=shape.triangledown, location=location.abovebar, color=color.red,    size=size.normal, text="Top2")
plotshape(show_shapes and top3_signal, title="T3 Top Signal", style=shape.diamond,      location=location.abovebar, color=color.maroon, size=size.small,  text="Top3")

// ──────────────────────────────────────────────
// 8. Visual Interface — Optional Labels
// ──────────────────────────────────────────────
if show_labels and t1_signal
    label.new(bar_index, low, "T1 Cap\nRSI:" + str.tostring(idx_rsi, "#.#") + " Z:" + str.tostring(z_score, "#.##"), style=label.style_label_up, color=color.new(color.green, 30), textcolor=color.white, size=size.small)
if show_labels and t2_signal
    label.new(bar_index, low, "T2 Crash\nVIX:" + str.tostring(vix_close, "#.#") + " Z:" + str.tostring(z_score, "#.##"), style=label.style_label_up, color=color.new(color.lime, 30), textcolor=color.black, size=size.small)
if show_labels and t3_signal
    label.new(bar_index, low, "T3 Mayer\nMM:" + str.tostring(mayer_multiple, "#.##"), style=label.style_label_up, color=color.new(color.teal, 30), textcolor=color.white, size=size.small)

if show_labels and top1_signal
    label.new(bar_index, high, "T1 Top\nRSI:" + str.tostring(idx_rsi, "#.#") + " Z:" + str.tostring(z_score, "#.##"), style=label.style_label_down, color=color.new(color.orange, 30), textcolor=color.white, size=size.small)
if show_labels and top2_signal
    label.new(bar_index, high, "T2 Euphoria\nVIX:" + str.tostring(vix_close, "#.#") + " Z:" + str.tostring(z_score, "#.##"), style=label.style_label_down, color=color.new(color.red, 30), textcolor=color.white, size=size.small)
if show_labels and top3_signal
    label.new(bar_index, high, "T3 Mayer Top\nMM:" + str.tostring(mayer_multiple, "#.##"), style=label.style_label_down, color=color.new(color.maroon, 30), textcolor=color.white, size=size.small)

// ──────────────────────────────────────────────
// 9. Informational Overlay (Data Table)
// ──────────────────────────────────────────────
var table infoPanel = table.new(position.top_right, 2, 12, bgcolor=color.new(color.black, 80), border_width=1)

if barstate.islast
    table.cell(infoPanel, 0, 0, "Metric",          text_color=color.white,  text_size=size.small)
    table.cell(infoPanel, 1, 0, "Value",            text_color=color.white,  text_size=size.small)
    
    z_color = z_score <= -2.0 ? color.green : z_score >= 2.0 ? color.orange : color.white
    table.cell(infoPanel, 0, 1, "Z-Score",          text_color=color.gray,   text_size=size.small)
    table.cell(infoPanel, 1, 1, str.tostring(z_score, "#.##"),        text_color=z_color,   text_size=size.small)
    
    mm_color = mayer_multiple <= mm_buy_threshold ? color.teal : mayer_multiple >= mm_top_threshold ? color.red : color.white
    table.cell(infoPanel, 0, 2, "Mayer Multiple",   text_color=color.gray,   text_size=size.small)
    table.cell(infoPanel, 1, 2, str.tostring(mayer_multiple, "#.##"), text_color=mm_color,  text_size=size.small)
    
    rsi_color = idx_rsi < 30 ? color.green : idx_rsi > 70 ? color.orange : color.white
    table.cell(infoPanel, 0, 3, "RSI",              text_color=color.gray,   text_size=size.small)
    table.cell(infoPanel, 1, 3, str.tostring(idx_rsi, "#.##"),        text_color=rsi_color, text_size=size.small)
    
    vix_color = vix_close >= 35 ? color.orange : vix_close <= vix_low_threshold ? color.red : color.white
    table.cell(infoPanel, 0, 4, "VIX",              text_color=color.gray,   text_size=size.small)
    table.cell(infoPanel, 1, 4, str.tostring(vix_close, "#.##"),      text_color=vix_color, text_size=size.small)
    
    regime_text  = is_bull ? "BULL" : "BEAR"
    regime_color = is_bull ? color.green : color.red
    table.cell(infoPanel, 0, 5, "Regime",           text_color=color.gray,   text_size=size.small)
    table.cell(infoPanel, 1, 5, regime_text,        text_color=regime_color, text_size=size.small, text_formatting=text.format_bold)
    
    table.cell(infoPanel, 0, 6, "T1 Bottoms",       text_color=color.gray,   text_size=size.small)
    table.cell(infoPanel, 1, 6, str.tostring(t1_count),               text_color=color.green,  text_size=size.small)
    table.cell(infoPanel, 0, 7, "T2 Bottoms",       text_color=color.gray,   text_size=size.small)
    table.cell(infoPanel, 1, 7, str.tostring(t2_count),               text_color=color.lime,   text_size=size.small)
    table.cell(infoPanel, 0, 8, "T3 Bottoms",       text_color=color.gray,   text_size=size.small)
    table.cell(infoPanel, 1, 8, str.tostring(t3_count),               text_color=color.teal,   text_size=size.small)
    table.cell(infoPanel, 0, 9, "T1 Tops",          text_color=color.gray,   text_size=size.small)
    table.cell(infoPanel, 1, 9, str.tostring(top1_count),             text_color=color.orange, text_size=size.small)
    table.cell(infoPanel, 0, 10, "T2 Tops",          text_color=color.gray,   text_size=size.small)
    table.cell(infoPanel, 1, 10, str.tostring(top2_count),             text_color=color.red,    text_size=size.small)
    table.cell(infoPanel, 0, 11, "T3 Tops",         text_color=color.gray,   text_size=size.small)
    table.cell(infoPanel, 1, 11, str.tostring(top3_count),            text_color=color.maroon, text_size=size.small)

// ──────────────────────────────────────────────
// 10. Alerts
// ──────────────────────────────────────────────
alertcondition(t1_signal,   title="Tier 1: Mild Capitulation",   message="T1 Capitulation — RSI < 30, Z ≤ -2.0")
alertcondition(t2_signal,   title="Tier 2: Severe Capitulation", message="T2 Crash — Z ≤ -3.0, VIX ≥ 35")
alertcondition(t3_signal,   title="Tier 3: Mayer Deep Value",    message="T3 Mayer — Multiple ≤ deep value threshold")
alertcondition(top1_signal, title="Tier 1 Top: Mild Euphoria",   message="T1 Top — RSI > 70, Z ≥ 2.0")
alertcondition(top2_signal, title="Tier 2 Top: Severe Euphoria", message="T2 Top — Z ≥ 3.0, VIX ≤ low threshold")
alertcondition(top3_signal, title="Tier 3 Top: Mayer Euphoria",  message="T3 Top — Multiple ≥ euphoria threshold")
````
