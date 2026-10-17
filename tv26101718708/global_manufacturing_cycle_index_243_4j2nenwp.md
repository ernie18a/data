# Global Manufacturing Cycle Index 24/3

- url: https://www.tradingview.com/script/4j2nenwp-Global-Manufacturing-Cycle-Index-24-3/
- type: indicator
- pine_id: PUB;b23eb6b2d264498bba245759be9cb664
- version: 1.0

## Description

[b]Global Manufacturing Cycle Index[/b]
A composite cyclical indicator that aggregates Year-over-Year (YoY) manufacturing production across major economies, rendering the result as a normalized, smoothed cycle oscillator.

[i]The Motivation[/i]
TradingView lists ECONOMICS:WWMPMI (World Manufacturing PMI), but it does not plot because S&P Global keeps the underlying JPM Global PMI series behind a subscription wall. This script resolves that data gap by reconstructing a usable synthetic equivalent. It pulls publicly available country-level manufacturing data, aggregates it, and transforms the raw noisy YoY changes into a clean, actionable macroeconomic cycle signal.

[i]Core Mechanics[/i]
[list]
[*]Data Ingestion: Pulls YoY manufacturing production for up to five economies via request.security (Default: US, China, Eurozone, Japan, plus one optional slot).
[*]Aggregation: Combines regional data using Sum, Average, or Weighted modes. Default weights approximate global manufacturing share (China 30%, US 17%, Eurozone 15%, Japan 7%).
[*]Z-Score Normalization: Translates the raw data into standard deviation units based on a rolling window (default 24-months). This keeps the index responsive to the current monetary and trade regime rather than averaging across structurally different historical eras.
[*]EMA Smoothing: Applies a customizable EMA pass to strip monthly noise and isolate the underlying structural trend.
[/list]
[i]Visuals & Diagnostics[/i]
[list]
[*]Regime Backgrounds: The chart background automatically colors green when the index is above zero (expansion) and red when below zero (contraction).
[*]Standard Deviation Bands: Plots ±1 SD and ±2 SD lines to help identify cycle extremes and mean-reversion zones.
[*]Status Table: Includes a built-in diagnostic table in the top right corner to verify if the underlying macroeconomic data series have loaded successfully.
[*]Raw Data Toggle: Option to plot the raw, individual YoY series for each country to see what is driving the composite.
[/list]
[i]Signal Interpretation[/i]
Zero represents the historical mean over your chosen lookback window.
[list]
[*]Above Zero: The global manufacturing cycle is expanding. This macro regime is typically highly conducive to risk asset rotation and momentum-based breakout setups.
[*]Below Zero: Contraction or relative weakness.
[*]Actionable Signals: Look for sustained inflections through the zero line, or divergences between this index and risk assets (or Dr. Copper).
[/list]
[i]Customization Notes[/i]
All series are monthly, meaning the indicator updates on the underlying release cadence regardless of your chart's timeframe. The default 24-month lookback and 3-month EMA provide a responsive signal. Users wanting a slower, more strategic read can extend these settings (e.g., 120-month lookback with a 6-12 EMA) to produce a smooth, business cycle wave.

## Source Code

````pine
// This Pine Script™ is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/

//@version=6
indicator("Global Manufacturing Cycle Index 24/3", overlay=false, precision=2)

// ──────────────────────────────────────────────
// SYMBOLS - Manufacturing Production YoY
// ──────────────────────────────────────────────
string i_s1 = input.symbol("ECONOMICS:USMPRYY", "Series 1 (US)", group="Symbols")
string i_s2 = input.symbol("ECONOMICS:CNMPRYY", "Series 2 (China)", group="Symbols")
string i_s3 = input.symbol("ECONOMICS:EUMPRYY", "Series 3 (Eurozone)", group="Symbols")
string i_s4 = input.symbol("ECONOMICS:JPMPRYY", "Series 4 (Japan)", group="Symbols")
string i_s5 = input.symbol("", "Series 5 (optional)", group="Symbols")

// ──────────────────────────────────────────────
// COMPOSITE MODE & WEIGHTS
// ──────────────────────────────────────────────
string i_mode = input.string("Average", "Composite Mode", options=["Sum", "Average", "Weighted"], group="Calculation")

float i_w1 = input.float(0.17, "Weight 1 (US)", step=0.01, group="Weights")
float i_w2 = input.float(0.30, "Weight 2 (China)", step=0.01, group="Weights")
float i_w3 = input.float(0.15, "Weight 3 (Eurozone)", step=0.01, group="Weights")
float i_w4 = input.float(0.07, "Weight 4 (Japan)", step=0.01, group="Weights")
float i_w5 = input.float(0.00, "Weight 5", step=0.01, group="Weights")

// ──────────────────────────────────────────────
// NORMALIZATION & SMOOTHING (MacroMicro style)
// ──────────────────────────────────────────────
bool i_normalize = input.bool(true, "Z-Score Normalize (MacroMicro style)", group="Output Style")
int  i_zLookback = input.int(24, "Z-Score Lookback (months)", minval=24, group="Output Style")
int  i_smooth    = input.int(3, "Smoothing EMA (months)", minval=1, maxval=24, group="Output Style")
bool i_showIndiv = input.bool(false, "Show individual series (raw YoY)", group="Display")

// ──────────────────────────────────────────────
// DATA
// ──────────────────────────────────────────────
fetch(string sym) => sym == "" ? float(na) : request.security(sym, "M", close, lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true)

float p1 = fetch(i_s1)
float p2 = fetch(i_s2)
float p3 = fetch(i_s3)
float p4 = fetch(i_s4)
float p5 = fetch(i_s5)

var float p1F = na
var float p2F = na
var float p3F = na
var float p4F = na
var float p5F = na
p1F := not na(p1) ? p1 : p1F
p2F := not na(p2) ? p2 : p2F
p3F := not na(p3) ? p3 : p3F
p4F := not na(p4) ? p4 : p4F
p5F := not na(p5) ? p5 : p5F

// ──────────────────────────────────────────────
// COMPOSITE
// ──────────────────────────────────────────────
add(float v) => na(v) ? 0.0 : v
cnt(float v) => na(v) ? 0.0 : 1.0
wgt(float v, float w) => na(v) ? 0.0 : v * w
wsum(float v, float w) => na(v) ? 0.0 : w

float sum_ = add(p1F) + add(p2F) + add(p3F) + add(p4F) + add(p5F)
float n    = cnt(p1F) + cnt(p2F) + cnt(p3F) + cnt(p4F) + cnt(p5F)
float avg_ = n > 0 ? sum_ / n : na

float wTop = wgt(p1F, i_w1) + wgt(p2F, i_w2) + wgt(p3F, i_w3) + wgt(p4F, i_w4) + wgt(p5F, i_w5)
float wBot = wsum(p1F, i_w1) + wsum(p2F, i_w2) + wsum(p3F, i_w3) + wsum(p4F, i_w4) + wsum(p5F, i_w5)
float weighted = wBot > 0 ? wTop / wBot : na

float raw = i_mode == "Sum" ? sum_ : i_mode == "Average" ? avg_ : weighted

// ──────────────────────────────────────────────
// Z-SCORE NORMALIZATION
// ──────────────────────────────────────────────
float mean_ = ta.sma(raw, i_zLookback)
float sd_   = ta.stdev(raw, i_zLookback)
float z     = sd_ > 0 ? (raw - mean_) / sd_ : 0.0

float series_out = i_normalize ? z : raw
float final_     = i_smooth > 1 ? ta.ema(series_out, i_smooth) : series_out

// ──────────────────────────────────────────────
// PLOTS
// ──────────────────────────────────────────────
plot(final_, "Cycle Index", color=color.new(color.aqua, 0), linewidth=3)
hline(0,  "Zero",  color=color.new(color.gray, 30), linestyle=hline.style_dashed)
hline(1,  "+1 SD", color=color.new(color.green, 70), linestyle=hline.style_dotted)
hline(-1, "-1 SD", color=color.new(color.red, 70), linestyle=hline.style_dotted)
hline(2,  "+2 SD", color=color.new(color.green, 50), linestyle=hline.style_dotted)
hline(-2, "-2 SD", color=color.new(color.red, 50), linestyle=hline.style_dotted)

plot(i_showIndiv ? p1F : na, "US", color=color.new(color.blue, 40))
plot(i_showIndiv ? p2F : na, "China", color=color.new(color.red, 40))
plot(i_showIndiv ? p3F : na, "Eurozone", color=color.new(color.yellow, 40))
plot(i_showIndiv ? p4F : na, "Japan", color=color.new(color.purple, 40))
plot(i_showIndiv ? p5F : na, "Series 5", color=color.new(color.orange, 40))

color bg = not na(final_) and final_ > 0 ? color.new(color.green, 94) : not na(final_) and final_ < 0 ? color.new(color.red, 94) : na
bgcolor(bg)

// ──────────────────────────────────────────────
// STATUS TABLE
// ──────────────────────────────────────────────
var table tbl = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 80), border_width=1)
if barstate.islast
    table.cell(tbl, 0, 0, "Symbol", text_color=color.white, bgcolor=color.new(color.gray, 50))
    table.cell(tbl, 1, 0, "Loaded?", text_color=color.white, bgcolor=color.new(color.gray, 50))
    table.cell(tbl, 0, 1, i_s1 == "" ? "—" : i_s1, text_color=color.white)
    table.cell(tbl, 1, 1, na(p1F) ? "X" : "OK", text_color=na(p1F) ? color.red : color.lime)
    table.cell(tbl, 0, 2, i_s2 == "" ? "—" : i_s2, text_color=color.white)
    table.cell(tbl, 1, 2, na(p2F) ? "X" : "OK", text_color=na(p2F) ? color.red : color.lime)
    table.cell(tbl, 0, 3, i_s3 == "" ? "—" : i_s3, text_color=color.white)
    table.cell(tbl, 1, 3, na(p3F) ? "X" : "OK", text_color=na(p3F) ? color.red : color.lime)
    table.cell(tbl, 0, 4, i_s4 == "" ? "—" : i_s4, text_color=color.white)
    table.cell(tbl, 1, 4, na(p4F) ? "X" : "OK", text_color=na(p4F) ? color.red : color.lime)
    table.cell(tbl, 0, 5, i_s5 == "" ? "—" : i_s5, text_color=color.white)
    table.cell(tbl, 1, 5, na(p5F) ? "X" : "OK", text_color=na(p5F) ? color.red : color.lime)
````
