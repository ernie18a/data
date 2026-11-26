# Aura RSP Matrix [Pineify]

- url: https://www.tradingview.com/script/rZyuX0sP-Aura-RSP-Matrix-Pineify/
- type: indicator
- pine_id: PUB;a146f5897c204cf6bcf9f305afc79d6d
- version: 1.0

## Description

[b] Pineify - Aura RSP Matrix - Relative Strength Phase Momentum[/b]

Aura RSP Matrix compares the chart symbol with a benchmark and classifies it into four relative-strength phases: Leading, Weakening, Lagging, and Improving. It shows whether relative performance is gaining or fading.

[b]Key Features[/b]

[list]
[*]Benchmark-relative RS Ratio and RS Momentum centered around 100.

[*]Phase coloring for the oscillator, bars, markers, and dashboard.

[*]Leading and Lagging labels fire only on the first bar of a new phase.
[/list]

[b]How It Works[/b]

The script requests the benchmark close on the timeframe, divides chart close by benchmark close, then normalizes the result with a [i]WMA[/i]. This creates RS Ratio, where values above 100 show relative strength above its recent baseline.

RS Momentum compares RS Ratio with its own WMA baseline. Both series are smoothed with an [i]EMA[/i] before phase detection. Smoothing reduces one-bar noise but adds lag.

[b]How the Components Work Together[/b]

RS Ratio shows whether the symbol is strong or weak versus the benchmark. RS Momentum shows whether that position is improving or fading. Leading means both are above 100; Weakening means strength remains above 100 while momentum slips; Lagging means both are below 100; Improving means momentum turns up before RS Ratio confirms.

[b]Trading Ideas and Insights[/b]

[list]
[*]Use Leading as confluence for bullish setups, not as an automatic entry.

[*]Watch Weakening after strong runs; it may show fading follow-through.

[*]Use Improving to find names recovering against a benchmark.

[*]Treat Lagging as a caution filter when stronger alternatives exist.
[/list]

Signals are phase-change markers, not performance guarantees. In choppy markets the matrix can rotate around 100, and live bars may change until close.

[b]Unique Aspects[/b]

[list]
[*]Two-stage WMA normalization separates relative strength from relative momentum.

[*]One four-state matrix keeps labels, bars, oscillator color, and dashboard status aligned.

[*]The benchmark input supports market, sector, crypto pair, or cross-asset comparison.
[/list]

[b]How to Use[/b]

[list=1]
[*]Add the indicator and choose a benchmark for your trading universe.

[*]Read the phase from bar color, oscillator color, and dashboard.

[*]Combine phases with price structure, volume, and higher-timeframe context.
[/list]

[b]Customization[/b]

[list]
[*][b]Calculation Window[/b] (default: 20) - WMA normalization period. Higher is smoother; lower is faster.

[*][b]Benchmark Ticker[/b] (default: SPX) - Relative strength comparison symbol.

[*][b]Smoothing Factor[/b] (default: 3) - EMA smoothing after RS calculations.

[*][b]Phase Colors and Toggles[/b] - Adjust colors, labels, and bar coloring.
[/list]

[b]Conclusion[/b]

Aura RSP Matrix is a relative strength context tool for rotation, watchlist filtering, and benchmark-relative trade selection. Use it with price action and risk controls, not as a standalone forecasting system.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pineify

//======================================================================//
//                    ____  _            _  __                          //
//                   |  _ \(_)_ __   ___(_)/ _|_   _                    //
//                   | |_) | | '_ \ / _ \ | |_| | | |                   //
//                   |  __/| | | | |  __/ |  _| |_| |                   //
//                   |_|   |_|_| |_|\___|_|_|  \__, |                   //
//                                             |___/                    //
//======================================================================//
//

//
// Aura RSP Matrix [Pineify]
// -------------------------
// This indicator maps a symbol's relative performance against a benchmark into
// a four-phase RS Ratio / RS Momentum matrix. It uses WMA-normalized relative
// strength to separate leadership from lagging behavior, then smooths the phase
// transitions so traders can track rotation without reacting to every small tick.
//
// Market states:
//   1. Leading - relative strength and relative momentum are both above equilibrium.
//   2. Weakening - relative strength remains positive, but momentum has rolled over.
//   3. Lagging - both relative strength and momentum are below equilibrium.
//   4. Improving - relative strength is still below equilibrium, but momentum is recovering.
//
//@version=6
indicator("Aura RSP Matrix [Pineify]")

//---------------------------------------------------------------------------------------------------------------------}
// INPUT SETTINGS
//---------------------------------------------------------------------------------------------------------------------{
grp_calc = "Relative Strength Settings"
grp_style = "Aesthetics & Colors"
grp_signals = "Signals & Bar Coloring"

length   = input.int(20, "Calculation Window", minval=2, group=grp_calc, tooltip="Lookback window used to normalize relative strength. Higher values make phase changes slower but less noisy.")
symBench = input.symbol("SPX", "Benchmark Ticker", group=grp_calc, tooltip="Benchmark symbol used as the comparison base. Broad indexes work well for market-relative rotation; sector or asset benchmarks can narrow the comparison.")
smooth   = input.int(3, "Smoothing Factor", minval=1, group=grp_calc, tooltip="EMA smoothing applied after RS Ratio and RS Momentum are calculated. Higher values reduce whipsaw but add lag.")

bullColor = input.color(#089981, "Leading (Green)", inline="colors", group=grp_style, tooltip="Color used when both relative strength and relative momentum are above the 100 equilibrium line.")
bearColor = input.color(#f23645, "Lagging (Red)", inline="colors", group=grp_style, tooltip="Color used when both relative strength and relative momentum are below the 100 equilibrium line.")
imprColor = input.color(#2157f3, "Improving (Blue)", inline="colors2", group=grp_style, tooltip="Color used when relative strength is still below equilibrium but relative momentum has turned positive.")
weakColor = input.color(#ffeb3b, "Weakening (Yellow)", inline="colors2", group=grp_style, tooltip="Color used when relative strength remains above equilibrium but relative momentum has slipped below 100.")

showLabels = input.bool(true, "Show Buy/Sell Signals", group=grp_signals, tooltip="Shows transition markers when the matrix first enters Leading or Lagging. These are phase-change markers, not standalone trade recommendations.")
colorBars  = input.bool(true, "Color Chart Bars", group=grp_signals, tooltip="Applies the current matrix phase color to chart bars so rotation can be read directly on price.")

//---------------------------------------------------------------------------------------------------------------------}
// CALCULATIONS
//---------------------------------------------------------------------------------------------------------------------{
// The benchmark is requested on the chart timeframe, with TradingView's default no-lookahead behavior.
// This keeps the relative-strength comparison aligned with the visible price bars.
bench = request.security(symBench, timeframe.period, close)

// Relative strength is normalized against its WMA baseline so the 100 level becomes a practical equilibrium.
// Values above 100 mean the symbol is outperforming its recent relative-strength baseline.
rs = close / bench
wma_rs = ta.wma(rs, length)
rs_ratio = ta.wma(rs / wma_rs, length) * 100

// Momentum measures the RS Ratio against its own WMA baseline. This separates sustained leadership
// from symbols that are still strong but starting to lose relative follow-through.
rs_mom = (rs_ratio / ta.wma(rs_ratio, length)) * 100

// A final EMA layer dampens one-bar noise before quadrant assignment. The tradeoff is intentional lag.
smooth_ratio = ta.ema(rs_ratio, smooth)
smooth_mom   = ta.ema(rs_mom, smooth)

//---------------------------------------------------------------------------------------------------------------------}
// CORE LOGIC
//---------------------------------------------------------------------------------------------------------------------{
// The 100 equilibrium line creates a simple four-state rotation map similar in spirit to RRG-style
// relative strength analysis [Source: Julius de Kempenaer, Relative Rotation Graphs methodology].
// Strength tells where the symbol is, momentum tells how it is changing.
isLeading   = smooth_ratio > 100 and smooth_mom > 100
isWeakening = smooth_ratio > 100 and smooth_mom <= 100
isLagging   = smooth_ratio <= 100 and smooth_mom <= 100
isImproving = smooth_ratio <= 100 and smooth_mom > 100

stateColor = isLeading ? bullColor : isLagging ? bearColor : isImproving ? imprColor : weakColor

//---------------------------------------------------------------------------------------------------------------------}
// PLOTTING & AESTHETICS
//---------------------------------------------------------------------------------------------------------------------{
hline(100, "Equilibrium", color=color.new(color.gray, 50), linestyle=hline.style_dashed)

// Momentum is the plotted oscillator because it usually turns before the slower RS Ratio.
// The phase color still depends on both values, so the area fill carries the full matrix context.
plot_mom   = plot(smooth_mom, "RS Momentum", color=color.new(stateColor, 80), style=plot.style_area)
// plot_ratio = plot(smooth_ratio, "RS Ratio", color=stateColor, linewidth=3)

//---------------------------------------------------------------------------------------------------------------------}
// SIGNALS
//---------------------------------------------------------------------------------------------------------------------{
// Only the first bar of a Leading or Lagging phase is marked. This avoids repeated labels while the
// symbol remains in the same quadrant and highlights the actual phase transition.
var bool wasLeading = false
var bool wasLagging = false

buySignal  = isLeading and not wasLeading
sellSignal = isLagging and not wasLagging

wasLeading := isLeading
wasLagging := isLagging

plotshape(showLabels and buySignal, "Buy Signal", shape.triangleup, location.bottom, bullColor, size=size.small)
plotshape(showLabels and sellSignal, "Sell Signal", shape.triangledown, location.top, bearColor, size=size.small)

barcolor(colorBars ? stateColor : na)

//---------------------------------------------------------------------------------------------------------------------}
// DASHBOARD
//---------------------------------------------------------------------------------------------------------------------{
var table dash = table.new(position.top_right, 2, 2, bgcolor=color.new(#1e222d, 10), border_width=1, border_color=color.new(color.gray, 80))
if barstate.islast
    table.cell(dash, 0, 0, "Current Phase", text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 1, "RSP Momentum", text_color=color.white, text_size=size.small)

    string stateText = isLeading ? "LEADING" : isLagging ? "LAGGING" : isImproving ? "IMPROVING" : "WEAKENING"
    table.cell(dash, 1, 0, stateText, text_color=stateColor, text_size=size.small, bgcolor=color.new(stateColor, 85))
    table.cell(dash, 1, 1, str.tostring(smooth_mom, "#.##"), text_color=smooth_mom > 100 ? bullColor : bearColor, text_size=size.small)
````
