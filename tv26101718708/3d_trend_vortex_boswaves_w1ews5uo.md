# 3D Trend Vortex [BOSWaves]

- url: https://www.tradingview.com/script/w1EWS5UO-3D-Trend-Vortex-BOSWaves/
- type: indicator
- pine_id: PUB;4f748d91181b45efacd24d391b6e0d81
- version: 1.0

## Description

[b]3D Trend Vortex [BOSWaves] - Slope-Adaptive Gradient Bands with Polyline 3D Extrusion and Zone Entry Signal Detection[/b]

[b]Overview[/b]

3D Trend Vortex [BOSWaves] is a slope-driven trend band system that constructs a pair of eight-layer gradient bands positioned above and below price using ATR-scaled offsets from a configurable moving average baseline, where band width breathes inversely with slope magnitude, candle gradient intensity reflects normalized slope strength, and a polyline-based three-dimensional extrusion renders the outer and inner band edges as volumetric ribbon geometry that follows the bands across the configured display length.

[image]https://www.tradingview.com/x/BU6ikruC/[/image]

Instead of relying on static symmetric bands or fixed volatility channels, the band width contracts when trend slope is strong and expands when slope is flat or weakening, producing a visual breathing effect that communicates momentum intensity through band geometry rather than through a separate indicator. The eight gradient fill layers within each band progress from near-transparent at the inner edge to full opacity at the outer edge, creating a visual depth effect that reinforces the three-dimensional extrusion rendered at the current bar.

This creates a trend framework where every visual layer simultaneously communicates the same underlying information from a different angle. The gradient bands reveal momentum intensity through their width. The candle gradient communicates slope conviction through brightness. The 3D extrusion at the band edges provides spatial depth cues that make the band structure immediately readable across varying zoom levels. Signal labels fire when price first enters either band after the cooldown period, identifying the specific bars where price has moved into the zone of interest defined by the ATR-offset band boundary.

Price is therefore tracked not just for its directional relationship to the basis MA but for its position within or outside a dynamically breathing gradient band system whose visual geometry encodes slope strength and momentum quality on every bar.

[b]Conceptual Framework[/b]

3D Trend Vortex is founded on the principle that trend band visualization should communicate momentum quality through the geometric properties of the bands themselves rather than requiring separate momentum indicators, and that introducing three-dimensional spatial depth into the band rendering provides immediate structural legibility that flat two-dimensional bands cannot achieve regardless of color or transparency settings.

Traditional band indicators apply fixed widths or static volatility multiples that remain visually identical whether momentum is surging or stalling, requiring traders to consult separate oscillators for conviction context. This framework embeds conviction directly into band geometry through the breathing width mechanism, where strong slope produces tighter, more concentrated bands reflecting focused directional commitment and weak slope produces wider, more diffuse bands reflecting reduced momentum quality. The three-dimensional extrusion layer adds spatial depth cues that reinforce the structural separation between the supply zone above price and the demand zone below.

Three core principles guide the design:
[list=1]
[*]Band width should adapt to slope magnitude, contracting during strong momentum and expanding during low-conviction conditions, encoding trend health directly into the geometric properties of the bands without requiring a separate momentum indicator.
[*]The gradient fill system across eight layers within each band should provide visual depth that reinforces the three-dimensional extrusion, creating a consistent spatial reading between the flat fill and the extruded geometry at the current bar edge.
[*]Signals should fire on first entry into band territory after the cooldown period rather than on crossover of a single line, capturing the structural significance of price reaching the offset zone while preventing signal clustering during extended band interactions.
[/list]
This shifts trend band analysis from static channel monitoring into a momentum-adaptive visual system where band breathing, candle intensity, and three-dimensional geometry collectively communicate trend conviction across every bar of the display window.

[b]Theoretical Foundation[/b]

The indicator combines configurable moving average baseline selection, ATR-based band offset and width calculation with slope-driven breathing modulation, eight-level gradient fill construction across inner-to-outer band subdivisions, polyline-based three-dimensional extrusion geometry using depth offset coordinates, and slope-normalized candle gradient coloring.

The basis MA is computed in the selected type over the configured length and the three-bar slope is measured as the difference between current and three-bar-lagged values. The slope magnitude is normalized against its highest value over an eighty-bar window, producing a 0-1 score that drives the breathing multiplier applied to the band width. ATR is smoothed over fifty bars to reduce sensitivity to individual volatility spikes, providing a stable scaling unit for both band offset and width calculations. The eight gradient fill layers divide the inner-to-outer band distance into equal steps with progressively increasing opacity, connecting smoothly to the polyline faces of the 3D extrusion that render the outer edge face, top face, and inner top face as separate filled polygon regions at configurable depth offsets.

Four internal systems operate in tandem:
[list]
[*][i]Slope-Adaptive Band Engine[/i]: Calculates ATR-smoothed band offset and width, applies EMA smoothing to all four band edges, and modulates total band width by a breathing factor derived from normalized slope magnitude so that bands contract proportionally during high-momentum conditions.
[*][i]Eight-Layer Gradient Fill System[/i]: Subdivides the inner-to-outer band width into eight equal steps and fills each interval with progressively decreasing transparency, producing a continuous opacity gradient from the near-transparent inner edge to the full-opacity outer edge across both the top and bottom bands.
[*][i]Three-Dimensional Extrusion Engine[/i]: On the last bar, constructs polyline polygon arrays for the outer face, top face, and inner top face of each band by combining current bar coordinates with depth-offset coordinates at the configured bar and ATR depth, rendering six filled polyline regions that create the illusion of volumetric band geometry extending from the current bar edge into the chart space.
[*][i]Zone Entry Signal System[/i]: Monitors price crossing into the top or bottom band on each bar, applying independent cooldown tracking for each side to prevent signal clustering during extended band interactions.
[/list]
This design allows band geometry, candle coloring, and 3D extrusion to all derive from the same underlying slope and ATR measurements, ensuring visual consistency across every layer of the indicator.

[b]How It Works[/b]

3D Trend Vortex evaluates price through a sequence of slope-aware band construction and visualization processes:
[list=1]
[*][i]Basis MA Calculation[/i]: The selected moving average type is calculated over the configured length, providing the directional baseline from which all band positions and slope measurements are derived.
[*][i]ATR Smoothing[/i]: Raw ATR over fourteen bars is smoothed with a fifty-bar SMA to produce a stable volatility unit that prevents individual spike bars from distorting band positioning across the display window.
[*][i]Slope Measurement and Normalization[/i]: The three-bar change in basis MA is measured and its absolute value is normalized against the highest absolute slope over eighty bars, producing a 0-1 score reflecting how strong the current slope is relative to recent momentum history.
[*][i]Breathing Width Calculation[/i]: The normalized slope score is scaled and subtracted from 1.0 to produce a breathing multiplier that reduces band width proportionally during high-slope conditions, causing bands to contract during strong momentum and expand during low-conviction flat conditions.
[*][i]Band Edge Calculation and Smoothing[/i]: Inner and outer edges for both the top and bottom bands are calculated by adding and subtracting ATR-scaled offset and width values from the basis MA, then smoothed with the configured EMA length to prevent jagged edge movement.
[*][i]Eight-Layer Gradient Fill Rendering[/i]: The inner-to-outer distance of each band is divided into eight equal steps and plot-fill pairs are rendered at each subdivision with transparency increasing from outer to inner, producing a smooth opacity gradient across the band depth.
[*][i]Candle Gradient Coloring[/i]: The normalized slope score is power-transformed and mapped to a gradient from a dimmed version of the trend color at low slope to full saturation at high slope, coloring chart candles proportionally to current momentum conviction.
[*][i]Zone Entry Detection[/i]: Price crossing into the top band from below or the bottom band from above is detected with independent cooldown tracking for each side. When entry is confirmed and cooldown is satisfied, a signal label is placed at the bar high or low respectively.
[*][i]3D Extrusion Construction[/i]: On the last bar, polyline arrays are constructed for each of the six extruded faces using combinations of current and depth-offset bar indices and price coordinates, rendering the outer face, top face, and inner top face for both the top and bottom bands as filled polygon regions.
[/list]
Together, these elements form a continuously updating slope-adaptive band system where gradient geometry, candle brightness, and three-dimensional extrusion simultaneously communicate trend direction, momentum conviction, and structural band positioning across the full display window.

[b]Interpretation[/b]

3D Trend Vortex should be interpreted as a slope-driven momentum band system with spatial depth visualization and zone entry monitoring:
[list]
[*][i]Bullish Trend State (Green)[/i]: Active when the basis MA slope is positive, with the bottom gradient band rendered in green and candles coloring green with intensity proportional to slope strength.
[*][i]Bearish Trend State (Red)[/i]: Active when the basis MA slope is negative, with the top gradient band rendered in red and candles coloring red with intensity proportional to slope strength.
[*][i]Band Width Dynamics[/i]: Narrow bands indicate strong slope momentum with high directional conviction. Wide bands indicate weak slope with reduced momentum quality. Monitoring band width evolution provides real-time conviction context without requiring a separate momentum oscillator.
[*][i]Eight-Layer Gradient Fill[/i]: The opacity gradient from inner to outer edge provides visual depth within each band, with the near-transparent inner boundary representing the threshold where price enters the zone of interest and the fully opaque outer boundary representing the extreme of the ATR-scaled offset distance.
[*][i]3D Extrusion[/i]: The three-dimensional polyline faces rendered at the current bar edge provide spatial depth cues that reinforce the structural separation between the top supply zone and bottom demand zone, making band positioning immediately readable across varying chart zoom levels.
[*][i]▲ Buy Signals[/i]: Green upward triangles mark the first bar where price enters the bottom band after the cooldown period, identifying price reaching the lower ATR-offset zone of interest.
[*][i]▼ Sell Signals[/i]: Red downward triangles mark the first bar where price enters the top band after the cooldown period, identifying price reaching the upper ATR-offset zone of interest.
[*][i]Candle Gradient[/i]: Price candles brighten toward full trend color saturation as slope strengthens and dim toward a muted version of the trend color as slope weakens, providing bar-level momentum conviction readings directly on the candlestick display.
[/list]
Band width dynamics, candle gradient intensity, signal zone entry, and 3D extrusion depth collectively provide more momentum and structural context than any element in isolation.

[b]Signal Logic & Visual Cues[/b]

3D Trend Vortex presents two zone entry signal types with independent cooldown enforcement:
[list=1]
[*][i]Buy Signal (▲)[/i]: Green triangle placed below the bar when price first closes below the bottom band inner edge after the configured cooldown period has elapsed since the previous buy signal, identifying price entry into the lower ATR-offset demand zone.
[*][i]Sell Signal (▼)[/i]: Red triangle placed above the bar when price first closes above the top band inner edge after the configured cooldown period has elapsed since the previous sell signal, identifying price entry into the upper ATR-offset supply zone.
[/list]
Independent per-side cooldown tracking prevents consecutive signals on the same side while allowing the opposite side to signal freely, ensuring that transitions between upper and lower zone interactions are captured without artificial suppression.

Alert generation covers buy and sell zone entry events for systematic monitoring workflows.

[b]Strategy Integration[/b]

3D Trend Vortex fits within momentum-informed band interaction and zone-based directional approaches:
[list=1]
[*][i]Band Width Conviction Reading[/i]: Use band width as a continuous momentum quality gauge. Entering a position during a narrow-band high-slope period indicates stronger directional conviction than entries during wide-band low-slope conditions where momentum quality is reduced.
[*][i]Zone Entry Signal Framework[/i]: Use buy and sell signals as structural alerts that price has reached the ATR-offset zone of interest rather than as standalone entry triggers. Evaluate slope direction and band width at the signal bar to assess whether the zone entry occurs during supporting or deteriorating momentum conditions.
[*][i]Candle Gradient Momentum Monitoring[/i]: Use the brightness of trend-colored candles as a bar-level momentum reading throughout the trend. Progressively brightening candles indicate strengthening slope. Dimming candles within an established trend suggest momentum deterioration before band width changes confirm it visually.
[*][i]3D Extrusion Spatial Reference[/i]: Use the three-dimensional band faces at the current bar edge as a visual anchor for where the current supply and demand zones sit relative to price, with the depth extending into future chart space providing an intuitive structural reference for the zone boundaries.
[*][i]Basis Type Selection[/i]: Use EMA for standard responsive trend tracking. Use HMA for lower-lag applications requiring faster slope detection with minimal smoothing delay. Use WMA for weighted recent-bar emphasis. Use SMA for a simpler unweighted baseline reference.
[*][i]Multi-Timeframe Band Alignment[/i]: Apply higher-timeframe slope direction and band positioning as a directional bias filter, engaging with lower-timeframe zone entry signals only when they align with the established higher-timeframe momentum state.
[/list]
[b]Technical Implementation Details[/b]
[list]
[*][i]Basis Engine[/i]: Configurable EMA, SMA, WMA, or HMA with slope measurement and normalization against eighty-bar highest absolute slope
[*][i]Band Construction[/i]: Smoothed ATR offset and width with slope-derived breathing modulation across four band edges
[*][i]Gradient System[/i]: Eight equal subdivisions between inner and outer band edges with plot-fill pairs at progressively increasing transparency
[*][i]3D Extrusion[/i]: Polyline polygon arrays for outer face, top face, and inner top face of each band using depth-offset bar index and ATR height coordinates
[*][i]Signal Logic[/i]: Zone entry detection with independent per-side cooldown bar tracking
[*][i]Candle Coloring[/i]: Power-transformed slope normalization mapped to trend-color gradient
[*][i]Performance Profile[/i]: 3D extrusion triggered only on last bar with full polyline rebuild and cleanup each render cycle, configurable display length cap for object management
[/list]
[b]Optimal Application Parameters[/b]

Timeframe Guidance:
[list]
[*][i]1 - 5 min[/i]: Intraday zone monitoring for scalping with shorter basis length and tighter band offset for responsive zone positioning on fast intraday momentum
[*][i]15 - 60 min[/i]: Session-level momentum band tracking with balanced basis length and moderate offset for meaningful zone separation across typical intraday swings
[*][i]4H - Daily[/i]: Swing-level momentum band analysis with longer basis length for sustained slope readings and wider offset reflecting larger price excursions from trend
[/list]
Suggested Baseline Configuration:
[list]
[*][i]Basis Length[/i]: 21
[*][i]Basis Type[/i]: EMA
[*][i]Band Offset (ATR×)[/i]: 3.0
[*][i]Band Width (ATR×)[/i]: 0.9
[*][i]Band Smoothing[/i]: 65
[*][i]3D Display Length[/i]: 400
[*][i]3D Depth (Bars)[/i]: 8
[*][i]3D Height (ATR×)[/i]: 0.5
[*][i]Show Signals[/i]: Enabled
[*][i]Signal Cooldown[/i]: 20
[*][i]Color Candles[/i]: Enabled (requires disabling original chart candles in chart settings)
[/list]
These suggested parameters should be used as a baseline; their effectiveness depends on the instrument's volatility characteristics, typical ATR range, and preferred band sensitivity, so fine-tuning is expected for optimal performance.

[b]Parameter Calibration Notes[/b]

Use the following adjustments to refine behavior without altering the core logic:
[list]
[*][i]Bands too far from price[/i]: Decrease Band Offset to bring the inner band edge closer to price, reducing the ATR distance required for price to reach the signal zone.
[*][i]Bands too close to price[/i]: Increase Band Offset to push bands further from price, requiring more significant price extension before zone entry signals fire.
[*][i]Band width breathing too pronounced[/i]: The breathing effect scales with slope normalization. On instruments with highly variable slope the breathing range may appear extreme. Reduce Band Width to compress the overall width range and make breathing less visually dramatic.
[*][i]Bands too jagged or smooth[/i]: Adjust Band Smoothing to control EMA smoothing on band edges. Higher values produce smoother, more gradual band curves. Lower values produce more responsive edges that track price structure changes faster.
[*][i]Too many signals[/i]: Increase Signal Cooldown to enforce greater bar separation between consecutive zone entry signals on the same side, focusing attention on less frequent but more structurally spaced entries.
[*][i]3D extrusion too deep or shallow[/i]: Adjust 3D Depth (Bars) to change the horizontal extent of the extruded faces and 3D Height (ATR×) to change the vertical depth of the extrusion, calibrating the spatial effect to the chart's aspect ratio and zoom level.
[*][i]3D extrusion covers too many or too few bars[/i]: Adjust 3D Display Length to control how many recent bars receive the polyline extrusion rendering, reducing for performance on slower systems or increasing to extend the visual depth effect further back into price history.
[/list]
Adjustments should be incremental and evaluated across multiple session types rather than isolated market conditions.

[b]Performance Characteristics[/b]

High Effectiveness:
[list]
[*]Trending markets with clear directional momentum where slope normalization produces meaningful band breathing dynamics and candle gradient provides reliable conviction context throughout the trend
[*]Instruments with consistent ATR behavior where the volatility-scaled band offset positions zones at structurally meaningful distances from price across varying market conditions
[*]Zone interaction strategies where price reaching the ATR-offset band boundary identifies structurally significant extension events worth monitoring for reversal or continuation behavior
[*]Visualization-focused workflows where the three-dimensional band geometry provides spatial chart reading advantages that improve structural awareness relative to flat two-dimensional bands
[/list]
Reduced Effectiveness:
[list]
[*]Choppy, trendless markets where slope alternates rapidly in direction, causing frequent trend color flips and band breathing that produces no sustained directional momentum context
[*]Extremely high-volatility instruments where ATR spikes push band offsets to distances so large that price rarely reaches the zone boundaries and signals become infrequent regardless of cooldown settings
[*]Low-ATR instruments where the extrusion height and band width produce visually imperceptible geometry requiring significant parameter adjustment to produce meaningful spatial depth
[*]Markets with highly irregular slope profiles where the eighty-bar normalization window consistently registers outlier slope readings that compress the breathing range for typical bars
[*]Consolidation environments where flat slope produces maximum band width expansion and near-neutral candle coloring simultaneously, reducing the visual differentiation that makes momentum context readable
[/list]
[b]Integration Guidelines[/b]
[list]
[*][i]Confluence[/i]: Combine with BOSWaves order flow tools, structural analysis, or momentum oscillators to validate zone entry signals with broader analytical context before acting on band boundary interactions
[*][i]Band Breathing Awareness[/i]: Monitor band width evolution throughout established trends as a continuous slope health indicator. Progressively widening bands during a trend suggest slope is weakening and conviction is diminishing before price structure confirms the change.
[*][i]Candle Gradient Divergence[/i]: Watch for price extending toward the outer band while candles are simultaneously dimming, indicating momentum deterioration during price extension that may precede reversal toward the basis MA.
[*][i]3D Depth Calibration[/i]: Adjust 3D Depth and Height parameters until the extrusion provides clear spatial depth without obscuring price action. The extrusion is a visualization aid and should complement rather than dominate the chart reading experience.
[*][i]State Discipline[/i]: Maintain directional bias aligned with current slope direction until slope reverses. Zone entry signals within the same trend direction represent extension events rather than reversal triggers and should be interpreted as monitoring alerts rather than directional change signals.
[/list]
[b]Disclaimer[/b]

3D Trend Vortex [BOSWaves] is a professional-grade slope-adaptive trend visualization and zone monitoring tool. It uses moving average slope normalization with ATR-scaled breathing band construction and polyline three-dimensional extrusion but does not predict future price movements. Results depend on market conditions, instrument momentum characteristics, parameter selection, and disciplined execution. BOSWaves recommends deploying this indicator within a broader analytical framework that incorporates order flow context, structural analysis, and comprehensive risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BOSWaves

//@version=6
indicator("3D Trend Vortex [BOSWaves]", overlay = true, max_polylines_count = 100, max_lines_count = 50, max_labels_count = 50, calc_bars_count = 500, max_bars_back = 500)

// ┌────────────────────────────── BOSWaves ─ Inputs ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
const string gCore = "Trend Engine"
const string gBand = "Band Settings"
const string g3D   = "3D Rendering"
const string gVis  = "Display"

int    basisLen    = input.int(21, "Basis Length", minval = 5, group = gCore, tooltip = "Center MA that drives trend direction and band positioning.")
string basisType   = input.string("EMA", "Basis Type", options = ["EMA", "SMA", "WMA", "HMA"], group = gCore, tooltip = "Moving-average formula for the basis line. EMA is responsive, SMA is smoothest, WMA/HMA sit in between — HMA being the most reactive.")
float  bandOffset  = input.float(3, "Band Offset (ATR×)", minval = 0.3, maxval = 5.0, step = 0.1, group = gBand, tooltip = "How far the bands sit from price.")
float  bandWidth   = input.float(0.9, "Band Width (ATR×)", minval = 0.2, maxval = 3.0, step = 0.1, group = gBand, tooltip = "Thickness of each gradient band.")
int    bandSmooth  = input.int(65, "Band Smoothing", minval = 5, maxval = 100, group = gBand, tooltip = "EMA smoothing on band edges.")
int    gradLevels  = 8
int    dispLen3D   = input.int(400, "3D Display Length", group = g3D, tooltip = "How many recent bars get the 3D extrusion effect.")
int    depthBars   = input.int(8, "3D Depth (Bars)", minval = 1, maxval = 8, group = g3D, tooltip = "Horizontal shift (in bars) of the extruded faces — larger values push the 3D depth further to the right.")
float  depthATR    = input.float(0.5, "3D Height (ATR×)", step = 0.01, group = g3D, tooltip = "Vertical height of the 3D extrusion in ATR multiples — higher values make the bands look taller.")
bool   showSignals = input.bool(true, "Show Signals", group = gVis, tooltip = "Plot ▲ / ▼ labels when price enters the buy or sell zone.")
int    sigCooldown = input.int(20, "Signal Cooldown", minval = 5, maxval = 100, group = gVis, tooltip = "Minimum bars between signals.")
bool   paintBars   = input.bool(true, "Color Candles", group = gVis, tooltip = "Recolor candles by trend direction, with intensity scaled to slope strength.")
int    fillTransp  = input.int(50, "Band Transparency", minval = 10, maxval = 90, group = gVis, tooltip = "Base transparency of the gradient band fills — higher values are more see-through.")
color  bullCol     = input.color(#00ff00, "Bullish", inline = "c", group = gVis, tooltip = "Color for bullish trend, the lower band, and buy signals.")
color  bearCol     = input.color(#ff0000, "Bearish", inline = "c", group = gVis, tooltip = "Color for bearish trend, the upper band, and sell signals.")

// ┌────────────────────────────── BOSWaves ─ Basis MA ───────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float basis = switch basisType
    "SMA" => ta.sma(close, basisLen)
    "WMA" => ta.wma(close, basisLen)
    "HMA" => ta.hma(close, basisLen)
    => ta.ema(close, basisLen)

float atr  = ta.atr(14)
float atrS = ta.sma(atr, 50)

// ┌────────────────────────────── BOSWaves ─ Trend from Basis ───────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float slope  = basis - basis[3]
bool  bullish = slope > 0
color trendCol = bullish ? bullCol : bearCol

// Slope magnitude drives candle gradient
float slopeMax = ta.highest(math.abs(slope), 80)
float slopeN   = slopeMax > 0 ? math.abs(slope) / slopeMax : 0.5
float breathe  = 1.0 - slopeN * 0.3

// ┌────────────────────────────── BOSWaves ─ Band Levels ────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float totalOff   = nz(atrS) * bandOffset
float totalWidth = nz(atrS) * bandWidth * breathe

float topInner  = ta.ema(basis + totalOff, bandSmooth)
float topOuter  = ta.ema(basis + totalOff + totalWidth, bandSmooth)
float botInner  = ta.ema(basis - totalOff, bandSmooth)
float botOuter  = ta.ema(basis - totalOff - totalWidth, bandSmooth)

float topStep = (topOuter - topInner) / gradLevels
float botStep = (botInner - botOuter) / gradLevels

float t0 = topInner,                float t1 = topInner + topStep * 1
float t2 = topInner + topStep * 2,  float t3 = topInner + topStep * 3
float t4 = topInner + topStep * 4,  float t5 = topInner + topStep * 5
float t6 = topInner + topStep * 6,  float t7 = topInner + topStep * 7
float t8 = topOuter

float b0 = botInner,                float b1 = botInner - botStep * 1
float b2 = botInner - botStep * 2,  float b3 = botInner - botStep * 3
float b4 = botInner - botStep * 4,  float b5 = botInner - botStep * 5
float b6 = botInner - botStep * 6,  float b7 = botInner - botStep * 7
float b8 = botOuter

// ┌────────────────────────────── BOSWaves ─ Gradient Fills ─────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
pt0 = plot(t0, display = display.none, editable = false)
pt1 = plot(t1, display = display.none, editable = false)
pt2 = plot(t2, display = display.none, editable = false)
pt3 = plot(t3, display = display.none, editable = false)
pt4 = plot(t4, display = display.none, editable = false)
pt5 = plot(t5, display = display.none, editable = false)
pt6 = plot(t6, display = display.none, editable = false)
pt7 = plot(t7, display = display.none, editable = false)
pt8 = plot(t8, display = display.none, editable = false)

pb0 = plot(b0, display = display.none, editable = false)
pb1 = plot(b1, display = display.none, editable = false)
pb2 = plot(b2, display = display.none, editable = false)
pb3 = plot(b3, display = display.none, editable = false)
pb4 = plot(b4, display = display.none, editable = false)
pb5 = plot(b5, display = display.none, editable = false)
pb6 = plot(b6, display = display.none, editable = false)
pb7 = plot(b7, display = display.none, editable = false)
pb8 = plot(b8, display = display.none, editable = false)

fill(pt0, pt1, color.new(bearCol, fillTransp + 35))
fill(pt1, pt2, color.new(bearCol, fillTransp + 30))
fill(pt2, pt3, color.new(bearCol, fillTransp + 25))
fill(pt3, pt4, color.new(bearCol, fillTransp + 20))
fill(pt4, pt5, color.new(bearCol, fillTransp + 15))
fill(pt5, pt6, color.new(bearCol, fillTransp + 10))
fill(pt6, pt7, color.new(bearCol, fillTransp + 5))
fill(pt7, pt8, color.new(bearCol, fillTransp))

fill(pb0, pb1, color.new(bullCol, fillTransp + 35))
fill(pb1, pb2, color.new(bullCol, fillTransp + 30))
fill(pb2, pb3, color.new(bullCol, fillTransp + 25))
fill(pb3, pb4, color.new(bullCol, fillTransp + 20))
fill(pb4, pb5, color.new(bullCol, fillTransp + 15))
fill(pb5, pb6, color.new(bullCol, fillTransp + 10))
fill(pb6, pb7, color.new(bullCol, fillTransp + 5))
fill(pb7, pb8, color.new(bullCol, fillTransp))

// ┌────────────────────────────── BOSWaves ─ Zone Signals ───────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
bool priceInTop = close > topInner
bool priceInBot = close < botInner

var int lastBuyBar  = -999
var int lastSellBar = -999

bool enterBot = priceInBot and not priceInBot[1] and (bar_index - lastBuyBar >= sigCooldown)
bool enterTop = priceInTop and not priceInTop[1] and (bar_index - lastSellBar >= sigCooldown)

if enterBot
    lastBuyBar := bar_index
if enterTop
    lastSellBar := bar_index

// ┌────────────────────────────── BOSWaves ─ Candle Coloring ────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float power = math.pow(slopeN, 0.6)
color bodyC = paintBars ? color.from_gradient(power, 0, 1, color.new(trendCol, 65), trendCol) : na
color wickC = paintBars ? color.from_gradient(power, 0, 1, color.new(trendCol, 55), color.new(trendCol, 5)) : na

plotcandle(open, high, low, close, "Candles",
     color = bodyC, wickcolor = wickC, bordercolor = bodyC,
     display = paintBars ? display.all : display.none)

// ┌────────────────────────────── BOSWaves ─ Signal Labels ──────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
if showSignals and enterBot
    label.new(bar_index, low, "▲",
         style = label.style_label_up, color = bullCol,
         textcolor = color.black, size = size.normal)

if showSignals and enterTop
    label.new(bar_index, high, "▼",
         style = label.style_label_down, color = bearCol,
         textcolor = color.white, size = size.normal)

// ┌────────────────────────────── BOSWaves ─ 3D Storage ─────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
var polyline[] activePolys = array.new<polyline>()

// ┌────────────────────────────── BOSWaves ─ 3D Extrusion ───────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
if barstate.islast
    for p in activePolys
        p.delete()
    activePolys.clear()

    int maxOff = math.min(dispLen3D, bar_index, 490)
    float depY = nz(atrS) * depthATR

    // ── Top band (red) 3D ──
    topOutFront = array.new<chart.point>()
    for off = maxOff to 0
        topOutFront.push(chart.point.from_index(bar_index - off, t8[off]))
    for off = 0 to maxOff
        topOutFront.push(chart.point.from_index(bar_index - off, t7[off]))
    if topOutFront.size() > 2
        activePolys.push(polyline.new(topOutFront, true, true,
             line_color = color.new(bearCol, 30), fill_color = color.new(bearCol, 35)))

    topOutTop = array.new<chart.point>()
    for off = maxOff to 0
        topOutTop.push(chart.point.from_index(bar_index - off, t8[off]))
    for off = 0 to maxOff
        topOutTop.push(chart.point.from_index(bar_index - off + depthBars, t8[off] + depY))
    if topOutTop.size() > 2
        activePolys.push(polyline.new(topOutTop, true, true,
             line_color = color.new(bearCol, 50), fill_color = color.new(bearCol, 55)))

    topInTop = array.new<chart.point>()
    for off = maxOff to 0
        topInTop.push(chart.point.from_index(bar_index - off, t0[off]))
    for off = 0 to maxOff
        topInTop.push(chart.point.from_index(bar_index - off + depthBars, t0[off] + depY))
    if topInTop.size() > 2
        activePolys.push(polyline.new(topInTop, true, true,
             line_color = color.new(bearCol, 70), fill_color = color.new(bearCol, 75)))

    // ── Bottom band (green) 3D ──
    botOutFront = array.new<chart.point>()
    for off = maxOff to 0
        botOutFront.push(chart.point.from_index(bar_index - off, b8[off]))
    for off = 0 to maxOff
        botOutFront.push(chart.point.from_index(bar_index - off, b7[off]))
    if botOutFront.size() > 2
        activePolys.push(polyline.new(botOutFront, true, true,
             line_color = color.new(bullCol, 30), fill_color = color.new(bullCol, 35)))

    botOutBot = array.new<chart.point>()
    for off = maxOff to 0
        botOutBot.push(chart.point.from_index(bar_index - off, b8[off]))
    for off = 0 to maxOff
        botOutBot.push(chart.point.from_index(bar_index - off + depthBars, b8[off] - depY))
    if botOutBot.size() > 2
        activePolys.push(polyline.new(botOutBot, true, true,
             line_color = color.new(bullCol, 50), fill_color = color.new(bullCol, 55)))

    botInBot = array.new<chart.point>()
    for off = maxOff to 0
        botInBot.push(chart.point.from_index(bar_index - off, b0[off]))
    for off = 0 to maxOff
        botInBot.push(chart.point.from_index(bar_index - off + depthBars, b0[off] - depY))
    if botInBot.size() > 2
        activePolys.push(polyline.new(botInBot, true, true,
             line_color = color.new(bullCol, 70), fill_color = color.new(bullCol, 75)))

    // ── Side faces ──
    topSide = array.new<chart.point>()
    topSide.push(chart.point.from_index(bar_index, t8))
    topSide.push(chart.point.from_index(bar_index, t0))
    topSide.push(chart.point.from_index(bar_index + depthBars, t0 + depY))
    topSide.push(chart.point.from_index(bar_index + depthBars, t8 + depY))
    topSide.push(chart.point.from_index(bar_index, t8))
    activePolys.push(polyline.new(topSide, true, true,
         line_color = color.new(bearCol, 25), fill_color = color.new(bearCol, 30)))

    botSide = array.new<chart.point>()
    botSide.push(chart.point.from_index(bar_index, b0))
    botSide.push(chart.point.from_index(bar_index, b8))
    botSide.push(chart.point.from_index(bar_index + depthBars, b8 - depY))
    botSide.push(chart.point.from_index(bar_index + depthBars, b0 - depY))
    botSide.push(chart.point.from_index(bar_index, b0))
    activePolys.push(polyline.new(botSide, true, true,
         line_color = color.new(bullCol, 25), fill_color = color.new(bullCol, 30)))

// ┌────────────────────────────── BOSWaves ─ Alerts ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
alertcondition(enterBot, "Buy Signal", "Price entered buy zone on {{ticker}}")
alertcondition(enterTop, "Sell Signal", "Price entered sell zone on {{ticker}}")
````
