# Ultimate Hull Suite

- url: https://www.tradingview.com/script/e8F3onnL-Ultimate-Hull-Suite/
- type: indicator
- pine_id: PUB;bec1395039ba4fb891c85eaafcb50faa
- version: 1.0

## Description

Greymyst Ultimate Hull Suite
The Greymyst Ultimate Hull Suite is a premium, multi-functional trend-following indicator designed to provide traders with highly accurate, low-lag momentum signals. Built entirely from the ground up for professional trading, this suite combines advanced Moving Average variations with dynamic volatility filters and multi-timeframe analysis to offer extreme confluence in a single tool.

🌟 Core Concepts & Features
1. Advanced Hull Variations
Traditional moving averages often suffer from lag. The Hull Moving Average solves this by prioritizing recent price action. This suite allows you to toggle between three powerful variations:

HMA (Standard Hull): The classic low-lag moving average.
EHMA (Exponential Hull): Uses exponential calculations to react even faster to sudden price spikes.
THMA (Triple Hull): Offers ultra-smooth trend detection, practically eliminating market noise and false signals during choppy ranges.
2. Multi-Timeframe (MTF) Alignment
Trading against the macro trend is a common pitfall. The built-in MTF engine allows you to anchor your Hull Moving Average to a higher timeframe (e.g., viewing the 4-Hour Hull trend on a 15-minute chart). This ensures you are only taking trades that align with the dominant market direction.

3. Dynamic Volatility Bands (Hull Envelopes)
Instead of static support and resistance, this suite wraps the Hull Moving Average in ATR-based Volatility Bands.

Trend Cloud: The area between the Hull and the bands is filled with a bullish (green) or bearish (red) cloud.
Mean Reversion: When price action aggressively pierces the upper or lower bands, it signals an overextended market, warning you of potential pullbacks or mean-reversion opportunities.
4. Squeeze Momentum Confluence Filter
A trend is only as strong as the volume and volatility behind it. This indicator integrates a hidden Squeeze Volatility Engine (combining Bollinger Bands and Keltner Channels).

The Filter: Buy and Sell signals are strictly suppressed if the market is stuck in a low-volatility "squeeze" (consolidation).
Signals are only generated when the Hull changes direction AND volatility is actively expanding, keeping you out of flat, choppy markets.
5. Automated Signals & Alerts
The suite visually prints clear B (Buy) and S (Sell) markers on your chart when high-probability confluence is met (Trend Shift + Volatility Expansion).

It includes comprehensive, ready-to-use Alert Conditions so you can automate your trading via webhooks or receive notifications directly to your phone.
⚙️ How to Use It for Confluence
Trend Confirmation: Use the color of the Hull MA (Green for Up, Red for Down) as your primary directional bias.
Entry Triggers: Look for Buy/Sell markers printed by the indicator. Because of the built-in Squeeze filter, these markers represent moments where price is reversing with momentum.
Take Profit / Stop Loss: Use the outer ATR bands as dynamic profit targets or trailing stop-loss zones.
(Created by greymyst)

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © greymyst

//@version=6
indicator("Ultimate Hull Suite", shorttitle="GM Hull", overlay=true)

// =====================================================================================================================
// BRANDING & METADATA
// =====================================================================================================================
// Created by greymyst
// Advanced Hull Suite with Multi-Timeframe, Volatility Bands, and Confluence Filters

// --- Inputs ---
grp_main = "Main Settings (created by greymyst)"
hull_type = input.string("EHMA", "Hull Variation", options=["HMA", "EHMA", "THMA"], group=grp_main, tooltip="Select the type of Hull Moving Average to use.")
hull_length = input.int(55, "Hull Length", minval=1, group=grp_main)
hull_src = input.source(close, "Source", group=grp_main)

grp_mtf = "Multi-Timeframe (MTF)"
use_mtf = input.bool(false, "Enable MTF?", group=grp_mtf)
mtf_res = input.timeframe("240", "MTF Resolution", group=grp_mtf)

grp_bands = "Volatility Bands (created by greymyst)"
show_bands = input.bool(true, "Show ATR Bands?", group=grp_bands)
atr_length = input.int(14, "ATR Length", minval=1, group=grp_bands)
atr_mult = input.float(2.0, "ATR Multiplier", minval=0.1, step=0.1, group=grp_bands)

grp_filters = "Confluence Filters"
use_squeeze = input.bool(true, "Use Squeeze Volatility Filter?", group=grp_filters, tooltip="Only trigger signals when the squeeze momentum indicates volatility expansion.")
sqz_len = input.int(20, "Squeeze Length", group=grp_filters)
sqz_mult = input.float(2.0, "Squeeze BB Multiplier", group=grp_filters)
sqz_kc_mult = input.float(1.5, "Squeeze KC Multiplier", group=grp_filters)

grp_style = "Style & Colors (created by greymyst)"
col_up = input.color(#00ff00, "Uptrend Color", group=grp_style)
col_down = input.color(#ff0000, "Downtrend Color", group=grp_style)
col_bands = input.color(color.new(color.blue, 80), "Bands Color", group=grp_style)

// --- Functions ---
// Standard HMA
f_hma(src, length) =>
    ta.wma(2 * ta.wma(src, math.max(1, math.floor(length / 2))) - ta.wma(src, length), math.max(1, math.floor(math.sqrt(length))))

// Exponential HMA (EHMA)
f_ehma(src, length) =>
    ta.ema(2 * ta.ema(src, math.max(1, math.floor(length / 2))) - ta.ema(src, length), math.max(1, math.floor(math.sqrt(length))))

// Triple HMA (THMA)
f_thma(src, length) =>
    ta.wma(ta.wma(src, math.max(1, math.floor(length / 3))) * 3 - ta.wma(src, math.max(1, math.floor(length / 2))) - ta.wma(src, length), length)

// Get selected hull type
f_get_hull(src, length, type) =>
    type == "HMA" ? f_hma(src, length) : type == "EHMA" ? f_ehma(src, length) : f_thma(src, length)

// Squeeze filter function (Returns true if volatility is expanding - 'Squeeze Off')
f_squeeze(src, length, bb_mult, kc_mult) =>
    basis = ta.sma(src, length)
    dev = bb_mult * ta.stdev(src, length)
    upperBB = basis + dev
    lowerBB = basis - dev
    
    tr_val = ta.tr(true)
    rangema = ta.sma(tr_val, length)
    upperKC = basis + rangema * kc_mult
    lowerKC = basis - rangema * kc_mult
    
    // sqzOn = (lowerBB > lowerKC) and (upperBB < upperKC)
    sqzOff = (lowerBB < lowerKC) and (upperBB > upperKC)
    
    // Return true if squeeze is off (volatility expanding)
    sqzOff

// --- Core Calculations ---

// Base Hull
hull_base = f_get_hull(hull_src, hull_length, hull_type)

// MTF Hull Request (with repainting control)
hull_mtf = request.security(syminfo.tickerid, mtf_res, f_get_hull(hull_src, hull_length, hull_type), barmerge.gaps_off, barmerge.lookahead_off)

// Select Hull
hull = use_mtf ? hull_mtf : hull_base

// Hull Trend & Color
is_up = hull > hull[1]
is_down = hull < hull[1]
hull_col = is_up ? col_up : is_down ? col_down : color.gray

// ATR Bands
atr_val = ta.atr(atr_length)
upper_band = hull + (atr_val * atr_mult)
lower_band = hull - (atr_val * atr_mult)

// Volatility Filter (Squeeze)
is_volatility_expanding = use_squeeze ? f_squeeze(close, sqz_len, sqz_mult, sqz_kc_mult) : true

// --- Confluence Signals ---
// Signal happens on Hull slope change (turn) AND volatility expanding
turn_up = ta.crossover(hull, hull[1])
turn_down = ta.crossunder(hull, hull[1])

buy_signal = turn_up and is_volatility_expanding
sell_signal = turn_down and is_volatility_expanding

// --- Plotting & Visuals ---

// Plot Hull
p_hull = plot(hull, title="Greymyst Hull MA", color=hull_col, linewidth=3)

// Plot Bands
p_upper = plot(show_bands ? upper_band : na, title="Upper ATR Band", color=col_bands, style=plot.style_line, linewidth=1)
p_lower = plot(show_bands ? lower_band : na, title="Lower ATR Band", color=col_bands, style=plot.style_line, linewidth=1)

// Cloud Fill
fill(p_upper, p_hull, color=color.new(col_up, 90), title="Bullish Cloud")
fill(p_hull, p_lower, color=color.new(col_down, 90), title="Bearish Cloud")

// Signal Markers
plotshape(buy_signal, title="Buy Signal (greymyst)", style=shape.triangleup, location=location.belowbar, color=col_up, size=size.small, text="B")
plotshape(sell_signal, title="Sell Signal (greymyst)", style=shape.triangledown, location=location.abovebar, color=col_down, size=size.small, text="S")

// --- Alerts ---
alertcondition(turn_up, title="Hull Turned Up", message="Greymyst Hull Suite: Hull turned UP")
alertcondition(turn_down, title="Hull Turned Down", message="Greymyst Hull Suite: Hull turned DOWN")
alertcondition(buy_signal, title="Confluence Buy Signal", message="Greymyst Hull Suite: Strong Buy Signal (Trend + Volatility)")
alertcondition(sell_signal, title="Confluence Sell Signal", message="Greymyst Hull Suite: Strong Sell Signal (Trend + Volatility)")
````
