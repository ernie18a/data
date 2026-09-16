<!-- tradingview-pine-id: PUB;6beee011c6ab417b9ff55c00a5f2a242 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Normalized SPMA | NAL

Source: https://www.tradingview.com/script/uxjZW9Os-Normalized-SPMA-NAL/

## Description

1. Overview

Normalized SPMA | NAL is a selective trend-regime oscillator built around the Shock Percentile Moving Average (SPMA) concept.

Unlike a conventional moving average that continuously absorbs every new bar, SPMA is deliberately selective. It evaluates current price movement relative to its own historical distribution and only allows qualifying movements to update the underlying baseline.

Normalized SPMA takes this concept further by expressing the relationship between price and the selective baseline in normalized form, then combining it with a volatility-adjusted boundary.

The result is a compact regime model designed to distinguish meaningful directional structure from lower-impact market movement.

2. Shock Percentile Moving Average

The foundation of the indicator is its percentile-gated moving average.

Current price change is ranked against a configurable historical window:

[pine]float Ret = close - close[1]
float Per = ta.percentrank(Ret, percentrank_lookback)
bool Gate = Per > percentile_gate[/pine]

Rather than updating continuously, the SPMA only accepts a new EMA value when the percentile condition is satisfied. Otherwise, its previous value is retained.

[pine]MA := na(MA[1]) ? emaValue : Gate ? emaValue : MA[1][/pine]

This creates a form of selective memory: ordinary movement can leave the baseline unchanged, while sufficiently significant positive price events are allowed to reshape it.

3. Normalized Regime Structure

The SPMA is then normalized relative to current price, allowing the model to study the relationship between the selective baseline and the market on a proportional scale.

A rolling standard-deviation component is applied to this normalized structure, creating a second volatility-sensitive series.

[pine]float normalizedSPMA = close != 0.0 ? -SPMA / close : na
float normalizedSD = ta.stdev(normalizedSPMA, normSDLen)
float normalizedLowerSD = normalizedSPMA - normalizedSD[/pine]

The interaction between these two measurements and the normalized reference level forms the final regime logic.

This combination is what gives Normalized SPMA its distinctive character: event-selective trend memory combined with normalized volatility structure.

4. Key Features

[*]Percentile-Gated Trend Filtering
[*]Selective Market Memory
[*]Price Normalization
[*]Volatility-Adjusted Confirmation
[*]Persistent Regime State
[*]Colored Candles and Clear Visualization

5. Purpose

Normalized SPMA was developed to explore a simple idea:

What happens when a trend model is allowed to remember important movement while becoming selectively insensitive to everything else?

By combining percentile-based event selection, adaptive baseline memory, normalization and volatility analysis, the indicator provides a different perspective on directional market structure than a continuously updating moving average.

It is intentionally compact, but the underlying interaction between selectivity, memory, normalization and volatility can produce a remarkably clean representation of changing market regimes.

Normalized SPMA | NAL is provided free and open source for research, experimentation and further study.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NordicAlphaLab

//@version=6
indicator("Normalized SPMA | NAL", "Normalized SPMA", overlay = false)

//                                     ███╗   ██╗ █████╗ ██╗
//                                     ████╗  ██║██╔══██╗██║
//                                     ██╔██╗ ██║███████║██║
//                                     ██║╚██╗██║██╔══██║██║
//                                     ██║ ╚████║██║  ██║███████╗
//                                     ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝

// ══════════════════════════════════════ ◈ Visuals & Tooltips ◈ ══════════════════════════════════════

col_mode = input.string("Standard", title = "Color Mode", group = "Visuals", options = ["Standard", "Nordic", "Simple"])

[col_up, col_dn, col_nu] = switch col_mode
    "Standard" => [color.rgb(0, 255, 200), color.rgb(32, 94, 144), color.gray]
    "Nordic"   => [color.rgb(0, 96, 175), color.rgb(150, 154, 169), color.gray]
    "Simple"   => [color.lime, color.red, color.gray]

// ══════════════════════════════════════ ◈ Inputs ◈ ══════════════════════════════════════

G = "Normalized SPMA"

Lookback   = input.int(50, "Percentrank Lookback", minval = 2, group = G, tooltip = "Number of historical bars used to rank the current returns.")
GateInp    = input.int(50, "% Gate", minval = 0, maxval = 99, group = G, tooltip = "Minimum percentile rank required for the SPMA to update.")
normLength = input.int(20, "Normalized SPMA Length", minval = 1, group = G)
normSDLen  = input.int(30, "Normalized SD Length", minval = 2, group = G)

// ══════════════════════════════════════ ◈ Logic ◈ ══════════════════════════════════════

f_SPMA(simple int percentrank_lookback, simple int ma_length, simple int percentile_gate) =>
    float Ret = close - close[1]
    float Per = ta.percentrank(Ret, percentrank_lookback)
    bool Gate = Per > percentile_gate
    float emaValue = ta.ema(close, ma_length)

    var float MA = na
    MA := na(MA[1]) ? emaValue : Gate ? emaValue : MA[1]
    MA

float SPMA = f_SPMA(Lookback, normLength, GateInp)

float normalizedSPMA = close != 0.0 ? -SPMA / close : na
float normalizedSD = ta.stdev(normalizedSPMA, normSDLen)
float normalizedLowerSD = normalizedSPMA - normalizedSD

bool Long  = normalizedLowerSD > -1.0
bool Short = normalizedSPMA < -1.0

var int NAL = 0
NAL := Long ? 1 : Short ? -1 : nz(NAL[1], 0)

// ══════════════════════════════════════ ◈ Plots and Visuals ◈ ══════════════════════════════════════

color col = NAL == 1 ? col_up : NAL == -1 ? col_dn : col_nu

color normCol   = Short ? col_dn : col_nu
color normSDCol = Long ? col_up : col_nu

plot(normalizedSPMA, "Normalized SPMA", color = normCol, linewidth = 1)
plot(normalizedLowerSD, "Normalized SPMA Lower SD", color = normSDCol, linewidth = 1)

hline(-1.0, "Normalized Midline", color = color.new(color.white, 50), linestyle = hline.style_dashed)

plotcandle(open, high, low, close, "Candles", color = col, wickcolor = col, bordercolor = col, display = display.pane, force_overlay = true)
barcolor(col)
````
