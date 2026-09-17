<!-- tradingview-pine-id: PUB;8fab51dd178f451f82e510e87cece7a8 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Dual Shock SPMA | NAL

Source: https://www.tradingview.com/script/VaXi43Pc-Dual-Shock-SPMA-NAL/

## Description

1. Overview

Dual Shock SPMA | NAL is a dual-memory trend indicator designed to separately track how significant bullish and bearish price shocks are developing through time.

Unlike the standard Shock Percentile Moving Average, the Dual Shock SPMA maintains two independent adaptive baselines. Positive shocks update the Bull Shock SPMA, while negative shocks update the Bear Shock SPMA.

This creates two separate memories of where statistically stronger directional moves have occurred, allowing the indicator to evaluate the relationship between bullish and bearish shock structure rather than treating all large movements as one stream.

2. Calculation

The indicator begins by calculating the percentage return of the selected source and ranking the absolute magnitude of that return against recent history.

[pine]Ret = not na(source[1]) ? (source - source[1]) / math.max(math.abs(source[1]), syminfo.mintick) : 0.0
ShockRank = ta.percentrank(math.abs(Ret), percentrank_lookback)[/pine]

Because the percentile calculation uses the absolute return, bullish and bearish shocks are ranked against the same magnitude distribution.

The direction of the return then determines which baseline is allowed to update.

[pine]BullGate = Ret > 0.0 and not na(ShockRank) and ShockRank > percentile_gate
BearGate = Ret < 0.0 and not na(ShockRank) and ShockRank > percentile_gate[/pine]

A qualifying positive shock updates only the Bull Shock SPMA. A qualifying negative shock updates only the Bear Shock SPMA. Otherwise, each baseline retains its previous value.

[pine]BullMA := na(BullMA[1]) ? emaValue : BullGate ? emaValue : BullMA[1]
BearMA := na(BearMA[1]) ? emaValue : BearGate ? emaValue : BearMA[1][/pine]

Each shock stream then maintains its own directional memory.

A rising Bull SPMA means significant positive shocks are occurring at progressively higher price levels. A rising Bear SPMA means significant negative shocks are also occurring at progressively higher levels. The inverse applies when either baseline is declining.

[pine]BullTrend := BullSPMA > BullSPMA[1] ? 1 : BullSPMA < BullSPMA[1] ? -1 : nz(BullTrend[1], 0)
BearTrend := BearSPMA > BearSPMA[1] ? 1 : BearSPMA < BearSPMA[1] ? -1 : nz(BearTrend[1], 0)[/pine]

The final state requires agreement between both shock memories.

For a bullish regime, both baselines must be trending upward and the Bull SPMA must remain above the Bear SPMA. For a bearish regime, both must be trending downward and their ordering must reverse.

An optional midpoint gate can additionally require price to remain aligned with the center of the dual-shock structure.

[pine]ShockMid = math.avg(BullSPMA, BearSPMA)

Long = BullTrend == 1 and BearTrend == 1 and (not UseMidGate or close > ShockMid) and BullSPMA > BearSPMA
Short = BearTrend == -1 and BullTrend == -1 and (not UseMidGate or close < ShockMid) and BullSPMA < BearSPMA[/pine]

3. Key Features

[*]Separate bullish and bearish shock-memory baselines.
[*]Absolute-return percentile ranking for directly comparable shock magnitude.
[*]Event-driven updates restricted to statistically stronger price movements.
[*]Independent directional memory for positive and negative shocks.
[*]Dual-baseline agreement and relative-position logic.
[*]Optional price midpoint confirmation.
[*]Optional neutral state during unresolved shock structure.
[*]Shock-memory spread visualization and state-based candle coloring.

4. Use

Dual Shock SPMA is designed to analyze how significant positive and negative price events are evolving relative to one another.

Rather than treating volatility as a single undifferentiated stream, the indicator preserves separate memories for each side of the market. This makes the relationship between bullish and bearish shock structure itself part of the signal.

The spread between the two baselines visually represents this evolving relationship, while the midpoint provides a central reference for the combined shock structure.

Dual Shock SPMA is designed as a specialized structural component within a complete strategy framework. Its role is to identify when independently maintained bullish and bearish shock memories begin establishing directional agreement, providing a distinct layer of information about the underlying development of larger price movements.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NordicAlphaLab

//@version=6
indicator("Dual Shock SPMA | NAL", "Dual Shock SPMA", overlay = true)


//                                     ███╗   ██╗ █████╗ ██╗
//                                     ████╗  ██║██╔══██╗██║
//                                     ██╔██╗ ██║███████║██║
//                                     ██║╚██╗██║██╔══██║██║
//                                     ██║ ╚████║██║  ██║███████╗
//                                     ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝


// ══════════════════════════════════════ ◈ Visuals & Tooltips ◈ ══════════════════════════════════════

col_mode = input.string("Standard", title = "Color Mode", group = "Visuals", options = ["Standard", "Nordic", "Simple"])
nu_state = input.bool(false, "Allow Neutral State?", group = "Visuals")

[col_up, col_dn, col_nu] = switch col_mode
    "Standard" => [color.rgb(0, 255, 200), color.rgb(32, 94, 144), color.gray]
    "Nordic"   => [color.rgb(0, 96, 175), color.rgb(150, 154, 169), color.gray]
    "Simple"   => [color.lime, color.red, color.gray]

// ══════════════════════════════════════ ◈ Inputs ◈ ══════════════════════════════════════

G  = "Dual Shock SPMA"
G2 = "Signal"

src      = input.source(close, "Source", group = G)
Length   = input.int(21, "Baseline Length", minval = 1, group = G)
Lookback = input.int(50, "Shock Percentile Lookback", minval = 2, tooltip = "Number of bars used to rank the magnitude of the current return shock. Both bullish and bearish shocks use the same magnitude distribution so their thresholds remain directly comparable.", group = G)
GateInp  = input.int(20, "% Shock Gate", minval = 0, maxval = 99, tooltip = "Minimum percentile rank required for a price move to update one of the shock baselines. Positive shocks update only the Bull Shock SPMA, while negative shocks update only the Bear Shock SPMA. Higher values react only to more extreme moves.", group = G)

UseMidGate = input.bool(true, "Use Price Midpoint Gate?", tooltip = "Requires price to be above the midpoint of the two shock baselines for a bullish state, or below it for a bearish state. This prevents directional agreement between the two memories from producing a signal when price itself is no longer aligned.", group = G2)

// ══════════════════════════════════════ ◈ Logic ◈ ══════════════════════════════════════

f_dual_SPMA(series float source, simple int percentrank_lookback, simple int ma_length, simple int percentile_gate) =>
    float Ret = not na(source[1]) ? (source - source[1]) / math.max(math.abs(source[1]), syminfo.mintick) : 0.0
    float ShockRank = ta.percentrank(math.abs(Ret), percentrank_lookback)

    bool BullGate = Ret > 0.0 and not na(ShockRank) and ShockRank > percentile_gate
    bool BearGate = Ret < 0.0 and not na(ShockRank) and ShockRank > percentile_gate

    float emaValue = ta.ema(source, ma_length)

    var float BullMA = na
    var float BearMA = na

    BullMA := na(BullMA[1]) ? emaValue : BullGate ? emaValue : BullMA[1]
    BearMA := na(BearMA[1]) ? emaValue : BearGate ? emaValue : BearMA[1]

    [BullMA, BearMA, BullGate, BearGate, ShockRank]

[BullSPMA, BearSPMA, BullShock, BearShock, ShockRank] = f_dual_SPMA(src, Lookback, Length, GateInp)

// Each shock stream keeps its own directional memory.
// BullSPMA rising = positive shocks are occurring at progressively higher price levels.
// BearSPMA rising = negative shocks are also occurring at progressively higher price levels.
var int BullTrend = 0
var int BearTrend = 0

BullTrend := BullSPMA > BullSPMA[1] ? 1 : BullSPMA < BullSPMA[1] ? -1 : nz(BullTrend[1], 0)
BearTrend := BearSPMA > BearSPMA[1] ? 1 : BearSPMA < BearSPMA[1] ? -1 : nz(BearTrend[1], 0)

float ShockMid = math.avg(BullSPMA, BearSPMA)

// Require agreement between the positive-shock and negative-shock memories.
bool Long = BullTrend == 1 and BearTrend == 1 and (not UseMidGate or close > ShockMid)    and BullSPMA > BearSPMA
bool Short = BearTrend == -1 and BullTrend == -1 and (not UseMidGate or close < ShockMid) and BullSPMA < BearSPMA

int NAL = 0
NAL := Long ? 1 : Short ? -1 : (nu_state ? 0 : NAL[1])

// ══════════════════════════════════════ ◈ Plots and Visuals ◈ ══════════════════════════════════════

color col = NAL == 1 ? col_up : NAL == -1 ? col_dn : col_nu
color bullSPMACol = BullTrend == 1 ? col_up : BullTrend == -1 ? col_dn : col_nu
color bearSPMACol = BearTrend == 1 ? col_up : BearTrend == -1 ? col_dn : col_nu

bullPlot = plot(BullSPMA, "Bull Shock SPMA", color = bullSPMACol, linewidth = 2)
bearPlot = plot(BearSPMA, "Bear Shock SPMA", color = bearSPMACol, linewidth = 2)
plot(ShockMid, "Dual Shock Midpoint", color = color.new(color.white, 60), linewidth = 1)

fill(bullPlot, bearPlot, color = color.new(col, 90), title = "Shock Memory Spread")

plotcandle(open, high, low, close, "Candles", color = col, wickcolor = col, bordercolor = col, display = display.pane, force_overlay = true)
barcolor(col)
````
