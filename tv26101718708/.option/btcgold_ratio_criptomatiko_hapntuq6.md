# BTC/Gold Ratio - CriptoMatiko

- url: https://www.tradingview.com/script/HAPNTuq6-BTC-Gold-Ratio-CriptoMatiko/
- type: indicator
- pine_id: PUB;47b85ba55cb44fa198938dbb0b2a0348
- version: 1.0

## Description

The BTC/Gold Ratio plots the ratio between Bitcoin (BTCUSD) and Gold (XAUUSD) prices — expressing Bitcoin's value in terms of gold ounces over time. Beyond the raw ratio, this script adds two analytical layers that most ratio plots omit.

─────────────────────────────────────────────
ANALYTICAL LAYERS
─────────────────────────────────────────────

**1. Days since last peak counter**

The script tracks how many calendar days have elapsed since the ratio last set a new all-time high. The counter resets only when the ratio makes a new peak. This measurement is relevant because Bitcoin's ratio against gold has historically entered extended consolidation phases after each cycle peak, and the length of those phases has been broadly consistent across cycles.

**2. Historical bounce zone**

Based on previous cycle data, the ratio has historically found support and reversed upward approximately 390 days after each major peak. The script highlights this zone with a green background and displays a label on the last bar when the day counter enters the configured range. The threshold is fully adjustable.

When both conditions are true (you are inside the bounce zone), the chart background turns green and a label appears showing the exact number of days since the peak.

─────────────────────────────────────────────
DATA SOURCE
─────────────────────────────────────────────

Both BTCUSD and XAUUSD are always fetched on the daily ("D") timeframe, regardless of the chart's active timeframe. This design choice avoids the heavy processing cost of loading intraday ticks for two separate assets and ensures the ratio is always based on daily reference prices — the standard for cycle analysis.

─────────────────────────────────────────────
VISUAL OUTPUTS
─────────────────────────────────────────────

- Main plot: BTC/Gold ratio (teal line)
- Optional EMA of the ratio (orange line) — configurable period, useful as a trend reference
- Green background when the day counter is inside the bounce zone
- Label on the last bar: shows days since peak (visible only when inside the bounce zone)
- Info table (top right):
  - Current Ratio: latest ratio value
  - Days Since Peak: counter in calendar days
  - Bounce Zone: Active (green) or Waiting (yellow)

─────────────────────────────────────────────
INPUTS
─────────────────────────────────────────────

Settings:
- EMA Period: period for the ratio EMA (default 100, range 50–500)
- Days since peak → bounce zone: day threshold to activate the bounce zone highlight (default 390, range 100–700)

Visual:
- Show EMA: toggle EMA line on/off
- Highlight historical bounce zone: toggle green background on/off

─────────────────────────────────────────────
ALERTS
─────────────────────────────────────────────

- "Bounce zone reached": fires once when the day counter hits the configured threshold
- "Ratio crossed above EMA": fires on EMA crossover (potential trend reversal confirmation)

─────────────────────────────────────────────
RECOMMENDED USAGE
─────────────────────────────────────────────

Apply to any chart — the ratio is always computed from daily BTCUSD and XAUUSD data regardless of chart timeframe. Recommended: view on a Daily (1D) chart for cleaner visual alignment with the ratio's native resolution.

─────────────────────────────────────────────
CHART ANNOTATIONS
─────────────────────────────────────────────

The publication chart includes manual drawings to illustrate the historical cycle data described above. The blue horizontal arrows with "395 bars / 395d" labels mark the measured duration between the ratio's last two major peaks and their respective bounce zones — showing that both cycles lasted approximately 395 days. The red descending arrows mark the peak-to-trough trajectory of the ratio in each cycle. These drawings are included to help readers visually connect the script's bounce zone logic to the actual historical data.

For educational purposes only. Not financial advice.

## Source Code

````pine
// ─────────────────────────────────────────────────────────────────────────────
// BTC/Gold Ratio — CriptoMatiko
// Author: Vernon
//
// What it does:
//   Plots the ratio between Bitcoin price (BTCUSD) and Gold (XAUUSD).
//   Tracks how many days have passed since the ratio's last peak and highlights
//   the historical bounce zone (390-430 days since peak = previous cycles).
//
// How to use:
//   1. Open the Pine Script Editor in TradingView
//   2. Paste this code and click "Add to chart"
//   3. Works on any timeframe — recommended: 1D
//
// Recommended plan: Essential (real-time data for XAUUSD)
// ─────────────────────────────────────────────────────────────────────────────

//@version=5
indicator("BTC/Gold Ratio — CriptoMatiko", shorttitle="BTC/XAU", overlay=false, max_bars_back=500)

// ── INPUTS ───────────────────────────────────────────────────────────────────
ma_length   = input.int(100,  "EMA Period",                      minval=50,  maxval=500, group="Settings")
rebote_dias = input.int(390,  "Days since peak → bounce zone",   minval=100, maxval=700, group="Settings")
show_ma     = input.bool(true, "Show EMA",                                               group="Visual")
show_bg     = input.bool(true, "Highlight historical bounce zone",                       group="Visual")

// ── DATA — always 1D to avoid overload on intraday timeframes ────────────────
btc   = request.security("BTCUSD", "D", close)
xau   = request.security("XAUUSD", "D", close)
ratio = btc / xau

// ── EMA OF RATIO ─────────────────────────────────────────────────────────────
ma = ta.ema(ratio, ma_length)

// ── COUNTER: days since last ratio peak ───────────────────────────────────────
var float pico_ratio = na
var int   pico_bar   = na

if na(pico_ratio) or ratio >= pico_ratio
    pico_ratio := ratio
    pico_bar   := bar_index

dias_desde_pico = bar_index - pico_bar

// ── BOUNCE ZONE ───────────────────────────────────────────────────────────────
zona_rebote = dias_desde_pico >= rebote_dias

// ── PLOTS ─────────────────────────────────────────────────────────────────────
plot(ratio,
     title     = "BTC/Gold Ratio",
     color     = color.new(color.teal, 0),
     linewidth = 2)

plot(show_ma ? ma : na,
     title     = "EMA of Ratio",
     color     = color.new(color.orange, 0),
     linewidth = 1)

// ── GREEN BACKGROUND IN BOUNCE ZONE ──────────────────────────────────────────
bgcolor(show_bg and zona_rebote ? color.new(color.green, 85) : na, title = "Historical bounce zone")

// ── LABEL ON LAST BAR (with cleanup to prevent accumulation) ─────────────────
var label lbl_rebote = na
if zona_rebote and barstate.islast
    label.delete(lbl_rebote)
    lbl_rebote := label.new(
         bar_index, ratio,
         "⚡ " + str.tostring(dias_desde_pico) + " days since peak\nHistorical Bounce Zone",
         color     = color.new(color.green, 15),
         textcolor = color.white,
         style     = label.style_label_left,
         size      = size.normal)

// ── INFO TABLE (top right corner) ────────────────────────────────────────────
var table painel = table.new(
     position.top_right, 2, 4,
     bgcolor      = color.new(color.navy, 10),
     border_color = color.new(color.teal, 40),
     border_width = 1,
     frame_color  = color.new(color.teal, 40),
     frame_width  = 1)

if barstate.islast
    // Header
    table.cell(painel, 0, 0, "BTC/Gold Ratio",
               text_color = color.new(color.teal, 0),
               text_size  = size.normal,
               bgcolor    = color.new(color.navy, 5))
    table.cell(painel, 1, 0, "",
               bgcolor    = color.new(color.navy, 5))

    // Current ratio
    table.cell(painel, 0, 1, "Current Ratio",   text_color = color.gray,  text_size = size.small)
    table.cell(painel, 1, 1, str.tostring(math.round(ratio, 2)),
               text_color = color.white, text_size = size.small, text_halign = text.align_right)

    // Days since peak
    table.cell(painel, 0, 2, "Days Since Peak", text_color = color.gray,  text_size = size.small)
    table.cell(painel, 1, 2, str.tostring(dias_desde_pico),
               text_color  = dias_desde_pico >= rebote_dias ? color.lime : color.white,
               text_size   = size.small,
               text_halign = text.align_right)

    // Zone status
    table.cell(painel, 0, 3, "Bounce Zone",     text_color = color.gray,  text_size = size.small)
    table.cell(painel, 1, 3, zona_rebote ? "Active" : "Waiting",
               text_color  = zona_rebote ? color.lime : color.yellow,
               text_size   = size.small,
               text_halign = text.align_right)

// ── ALERTS ───────────────────────────────────────────────────────────────────
alertcondition(
     dias_desde_pico == rebote_dias,
     title   = "Bounce zone reached",
     message = "BTC/Gold Ratio entered the historical bounce zone — days since peak reached the configured threshold")

alertcondition(
     ta.crossover(ratio, ma),
     title   = "Ratio crossed above EMA",
     message = "BTC/Gold Ratio crossed above the EMA — possible confirmed reversal")
````
