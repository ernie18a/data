<!-- tradingview-pine-id: PUB;a221671bf97a4d4cbb6081a52620aa92 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Shock Percentile Moving Average | NAL

Source: https://www.tradingview.com/script/r6kisZj3-Shock-Percentile-Moving-Average-NAL/

## Description

1. Overview

Shock Percentile Moving Average | NAL is an event-driven trend filter designed to react selectively to unusually strong price movements.

Instead of updating continuously like a conventional moving average, the SPMA only refreshes when the current price change ranks high enough relative to recent returns. When that condition is not met, the moving average holds its previous value.

This creates a stepped adaptive baseline that places greater emphasis on meaningful price shocks while filtering out a large portion of lower-impact movement.

2. Calculation

The indicator begins by measuring the current one-bar price change.

[pine]Ret = close - close[1][/pine]

That return is then ranked against recent historical returns using a percentile rank.

[pine]Per = ta.percentrank(Ret, percentrank_lookback)[/pine]

The percentile gate determines whether the baseline is allowed to update.

[pine]Gate = Per > percentile_gate[/pine]

When the return exceeds the selected percentile threshold, the SPMA updates to the current EMA value. When the threshold is not met, the previous SPMA value is retained.

[pine]MA := na(MA[1]) ? emaValue : Gate ? emaValue : MA[1][/pine]

This means the baseline does not continuously follow every movement in price. Its structure changes primarily when the market produces sufficiently strong ranked shocks.

A second layer measures the percentage slope of the SPMA over a selected lookback.

[pine]SlopePer = (SPMA - SPMA[SlopeLen]) / SPMA[SlopeLen] * 100
SlopeGate = SlopePer > SlopeGateL[/pine]

When the optional slope gate is enabled, a bullish regime requires both an upward SPMA movement and sufficient positive slope.

The bearish state remains based on downward movement in the SPMA.

[pine]NAL := SPMA > SPMA[1] and (UseSlope ? SlopeGate : true) ? 1 : SPMA < SPMA[1] ? -1 : nz(NAL[1], 0)[/pine]

When neither directional condition is satisfied, the previous regime is retained.

3. Key Features

[*]Percentile-ranked return filtering.
[*]Event-driven moving average updates.
[*]Baseline remains unchanged during lower-ranked price movement.
[*]Configurable shock threshold and historical ranking window.
[*]Optional percentage-slope confirmation for bullish states.
[*]Persistent directional regime logic.
[*]State-based SPMA and candle coloring.

4. Use

Shock Percentile Moving Average is designed to isolate trend development that occurs around statistically stronger price movements.

Because the baseline only updates when the return percentile exceeds the selected gate, the SPMA can remain stable through lower-impact movement and reposition itself when more significant price shocks occur.

The optional slope gate adds another layer of selectivity by requiring the updated structure to demonstrate sufficient positive acceleration before establishing a bullish state.

SPMA is designed as a specialized structural component within a complete strategy framework. Its role is to isolate price movement associated with stronger ranked shocks and convert those events into a persistent directional baseline that can be incorporated into a broader market decision process.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NordicAlphaLab

//@version=6
indicator("Shock Percentile Moving Average | NAL", "Shock Percentile MA",overlay = true)


//                                     ███╗   ██╗ █████╗ ██╗
//                                     ████╗  ██║██╔══██╗██║
//                                     ██╔██╗ ██║███████║██║
//                                     ██║╚██╗██║██╔══██║██║
//                                     ██║ ╚████║██║  ██║███████╗
//                                     ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝


// ══════════════════════════════════════ ◈ Visuals & Tooltips ◈ ══════════════════════════════════════

col_mode = input.string("Standard", title = "Color Mode", group = "Visuals", options = ["Standard", "Nordic", "Simple"])

[col_up, col_dn, col_nu] = switch col_mode
    "Standard"  => [color.rgb(0, 255, 200), color.rgb(32, 94, 144), color.gray]
    "Nordic"    => [color.rgb(0, 96, 175), color.rgb(150, 154, 169), color.gray]
    "Simple"    => [color.lime, color.red, color.gray]

// ══════════════════════════════════════ ◈ Inputs ◈ ══════════════════════════════════════

G  = "SPMA Settings"
G2 = "Slope Gate"

Length   = input.int(30, "Baseline Length", group = G)
Lookback = input.int(30, "Percentrank Lookback", minval = 2, tooltip = "Number of historical bars used to rank the current returns. Lower values react faster but produce a less stable rank. Higher values compare the current shock against a broader historical sample.", group = G)
GateInp = input.int(50, "% Gate", minval = 0, maxval = 99, tooltip = "Minimum percentile rank required for the SPMA to update. A value of 50 updates on above-median positive price shocks, while higher values restrict updates to increasingly unusual shocks. When the gate is not met, the SPMA holds its previous value.", group = G)

UseSlope = input.bool(true, "Use Slope Gate?", tooltip = "Requires the SPMA percentage slope to exceed the Slope Gate before a bullish state can activate. When disabled, any upward SPMA movement can produce a bullish state. The bearish condition is not affected by this setting.", group = G2)
SlopeLen = input.int(9, "Slope Lookback (bars)", group = G2)
SlopeGateL = input.float(0.75, "% Slope Gate", step = 0.1, group = G2)

// ══════════════════════════════════════ ◈ Logic ◈ ══════════════════════════════════════

f_SPMA(simple int percentrank_lookback, simple int ma_length, simple int percentile_gate) =>
    float Ret = close - close[1]
    float Per = ta.percentrank(Ret, percentrank_lookback)
    bool  Gate = Per > percentile_gate
    float emaValue = ta.ema(close, ma_length)

    var float MA = na
    MA := na(MA[1]) ? emaValue : Gate ? emaValue : MA[1]
    MA

float SPMA = f_SPMA(Lookback, Length, GateInp)

//Signal Enhancement Gate
SlopePer = (SPMA - SPMA[SlopeLen]) / SPMA[SlopeLen] * 100
SlopeGate = SlopePer > SlopeGateL

var int NAL = 0
NAL := SPMA > SPMA[1] and (UseSlope ? SlopeGate : true) ? 1 : SPMA < SPMA[1] ? -1 : nz(NAL[1], 0)

// ══════════════════════════════════════ ◈ Plots and Visuals ◈ ══════════════════════════════════════

color col = NAL == 1 ? col_up : NAL == -1 ? col_dn : col_nu

plot(SPMA, "Shock Percentile Moving Average", color = col, linewidth = 2)

plotcandle(open, high, low, close, "Candles", color = col, wickcolor = col, bordercolor = col, display = display.pane, force_overlay = true)
barcolor(col)
````
