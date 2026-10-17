# Arc Momentum Oscillator [BOSWaves]

- url: https://www.tradingview.com/script/8NtmLeZI-Arc-Momentum-Oscillator-BOSWaves/
- type: indicator
- pine_id: PUB;18a08323a989471a8268a559c9d5d5f5
- version: 1.0

## Description

[b]Arc Momentum Oscillator [BOSWaves] - Acceleration-Driven Arc Engine with Adaptive Momentum Tracking and Divergence Detection[/b]

[b]Overview[/b]

Arc Momentum Oscillator [BOSWaves] is a momentum-based trend oscillator that tracks directional price commitment through an acceleration-driven arc engine, where arc positioning, trend state, and flip signal generation are determined by the relationship between a smoothed centered RSI momentum line and a dynamically accelerating arc that chases momentum from a volatility-scaled starting distance rather than from fixed thresholds or static level crossovers.

[image]https://www.tradingview.com/x/zJ1Z7ook/[/image]

Instead of relying on conventional overbought and oversold threshold crossings or moving average crossovers, trend state is determined by the relative position of momentum and the arc, with the arc launching from a standard deviation-scaled offset on each trend flip and accelerating progressively toward momentum until the relationship reverses. This creates a trend detection mechanism that adapts its sensitivity to the instrument's actual momentum volatility rather than applying identical thresholds regardless of market conditions.

This creates an oscillator that reflects genuine momentum dynamics rather than arbitrary indicator levels. The arc contracts toward momentum during sustained trending conditions as acceleration builds, produces flip signals only when momentum crosses the arc with sufficient separation to clear a volatility-scaled buffer, and maps momentum strength visually through cloud fill intensity, strength bands, and extreme zone highlighting that collectively reveal conviction state at a glance.

Price is therefore evaluated against an arc that adapts to momentum volatility, accelerates with trend persistence, and resets to a calibrated starting distance on each directional change rather than reacting identically to every momentum fluctuation.

[b]Conceptual Framework[/b]

Arc Momentum Oscillator is founded on the principle that meaningful trend signals in momentum space emerge from the acceleration dynamics between price momentum and a trailing arc, not from momentum crossing fixed reference levels that carry no adaptive relationship to the instrument's current volatility regime.

Traditional momentum oscillators identify directional changes through threshold crossovers at fixed levels such as 50, 70, or 30, which treat all momentum readings identically regardless of how significant they are relative to recent momentum behavior. This framework replaces static-threshold logic with an acceleration-based arc system where flip significance is measured relative to the current standard deviation of momentum, and arc behavior evolves continuously based on how long the current trend has persisted.

Three core principles guide the design:
[list=1]
[*]Trend flips should require momentum to breach the arc by a volatility-scaled buffer, ensuring signal generation reflects statistically meaningful momentum displacement rather than marginal crossovers.
[*]The arc should accelerate progressively during trend persistence, contracting toward momentum as conviction builds and reflecting weakening trend strength as the gap narrows.
[*]Momentum strength and extreme conditions should be visualized through adaptive fills and strength bands rather than fixed reference lines, providing continuous conviction context across varying volatility regimes.
[/list]
This shifts oscillator analysis from static threshold monitoring into dynamic arc-momentum relationship tracking where signal significance is continuously calibrated to prevailing momentum volatility.

[b]Theoretical Foundation[/b]

The indicator combines RSI-based momentum sourcing, exponential smoothing and centering, standard deviation-based adaptive unit calculation, acceleration-driven arc mechanics, and pivot-based divergence detection between price and the oscillator.

The RSI is calculated over a short configurable period and centered around zero by subtracting fifty, creating a momentum reading that oscillates between negative and positive territory reflecting bearish and bullish momentum respectively. An EMA smoothing pass reduces noise before the arc engine processes the momentum line. The standard deviation of momentum over a rolling window provides the adaptive unit that scales all arc behavior, including launch distance, flip buffer, and step size, ensuring the system responds proportionally to actual momentum variance. The arc accelerates by incrementing its velocity on a configurable smoothing interval, producing progressively faster convergence toward momentum during sustained trends.

Four internal systems operate in tandem:
[list]
[*][i]Momentum Source Engine[/i]: Calculates RSI over the configured length, centers it around zero, and applies EMA smoothing to produce a clean directional momentum reading that serves as the primary oscillator line.
[*][i]Adaptive Unit Calculation[/i]: Derives a rolling standard deviation of momentum to produce a volatility-normalized unit that scales arc launch distance, flip buffer threshold, and step size adaptively to current momentum behavior.
[*][i]Arc Acceleration Engine[/i]: Maintains arc position and velocity state, launching the arc from a standard deviation-scaled offset on each flip, incrementing velocity on each smoothing interval, and advancing the arc toward momentum at a rate that grows with trend persistence.
[*][i]Divergence Detection System[/i]: Identifies confirmed pivot highs and lows on the momentum oscillator and compares them against corresponding price pivots, detecting regular bearish divergence where price makes higher highs against lower oscillator highs and regular bullish divergence where price makes lower lows against higher oscillator lows.
[/list]
This design allows the oscillator to reflect both the direction and the conviction dynamics of momentum while simultaneously monitoring the relationship between price structure and oscillator structure for divergence conditions.

[b]How It Works[/b]

Arc Momentum Oscillator evaluates price through a sequence of momentum-aware and acceleration-driven processes:
[list=1]
[*][i]RSI Calculation and Centering[/i]: RSI is calculated over the configured length and shifted by subtracting fifty, producing a centered momentum reading where positive values reflect bullish RSI conditions and negative values reflect bearish conditions.
[*][i]Momentum Smoothing[/i]: EMA smoothing is applied to the centered RSI over the configured smoothing length, reducing bar-to-bar noise and producing the primary momentum line that the arc engine tracks.
[*][i]Adaptive Unit Derivation[/i]: The standard deviation of momentum over a 100-bar rolling window provides the adaptive unit that governs all volatility-scaled arc behavior throughout the session.
[*][i]Arc Initialization[/i]: On first activation after sufficient bars for standard deviation calculation, the arc is placed below momentum at a distance equal to the adaptive unit multiplied by the Start Distance parameter, with velocity initialized to zero.
[*][i]Flip Detection[/i]: Each bar tests whether momentum has crossed the arc by more than a volatility-scaled buffer in the opposing direction. A cross below the arc minus buffer triggers a bearish flip; a cross above the arc plus buffer triggers a bullish flip.
[*][i]Arc Reset on Flip[/i]: When a flip is detected, the arc resets to a new starting position on the opposite side of momentum at the full Start Distance offset and velocity resets to zero, beginning a fresh acceleration cycle in the new trend direction.
[*][i]Arc Acceleration[/i]: On bars that fall on the configured smoothing interval, arc velocity increments by the configured Arc Speed value and the arc advances toward momentum by the adaptive step size multiplied by current velocity, producing progressively faster arc convergence as the trend persists.
[*][i]Cloud Fill Rendering[/i]: The area between the arc and momentum line is filled with the trend direction color at a configurable transparency, with fill intensity providing a visual representation of the gap between arc and momentum.
[*][i]Strength Band Rendering[/i]: Gradient-filled bands in the extreme oscillator zones scale their opacity based on how far momentum sits from the midline relative to the configured range, providing a continuous strength visualization that intensifies as momentum approaches extreme territory.
[*][i]Divergence Evaluation[/i]: On each confirmed momentum pivot, recent pivot history is scanned for divergence conditions between price and oscillator structure within the configured minimum and maximum pivot distance range, with qualifying divergences drawing connecting lines on both the oscillator and the price chart.
[/list]
Together, these elements form a continuously updating momentum framework where arc dynamics reveal trend conviction, flip signals reflect statistically significant momentum shifts, and divergence detection identifies structural disagreement between price and momentum before directional changes occur.

[b]Interpretation[/b]

Arc Momentum Oscillator should be interpreted as an acceleration-driven momentum conviction system with structural divergence monitoring:
[list]
[*][i]Bullish Trend State (Green)[/i]: Active when momentum is above the arc with sufficient buffer separation, indicating upward momentum has breached the arc threshold and the arc is accelerating from below to track the developing upside conviction.
[*][i]Bearish Trend State (Red)[/i]: Active when momentum is below the arc with sufficient buffer separation, indicating downward momentum has breached the arc threshold and the arc is accelerating from above to track the developing downside conviction.
[*][i]Arc Line[/i]: The grey trailing arc represents the dynamic boundary that momentum must cross to trigger a trend flip. Its proximity to momentum reflects accumulated trend age as the arc accelerates and converges toward the momentum line during sustained conditions.
[*][i]Momentum Line[/i]: The colored primary oscillator line reflects smoothed centered RSI momentum, with positive readings above zero indicating bullish momentum dominance and negative readings below zero indicating bearish momentum dominance.
[*][i]Cloud Fill[/i]: The gradient fill between arc and momentum line is colored by current trend direction, with a wider gap producing a more prominent fill that visually represents the distance between momentum and its trailing arc.
[*][i]Strength Bands[/i]: Gradient-filled zones in the upper and lower extreme areas intensify in opacity as momentum approaches and enters extreme territory, providing a continuous strength reading that reflects how far momentum has extended relative to the oscillator's range.
[*][i]Extreme Zone Background[/i]: Subtle background tinting activates when momentum exceeds the configured extreme threshold in either direction, providing an immediate visual cue that momentum is in statistically elevated territory.
[*][i]Reference Rails[/i]: The zero midline, plus and minus 25 reference levels, and the configurable extreme threshold lines provide orientation anchors across the oscillator's momentum range without imposing fixed signal thresholds.
[*][i]Flip Arrows[/i]: Small triangle markers appear on the price chart at arc flip bars, with upward triangles for bullish flips and downward triangles for bearish flips, positioned at a configurable offset from the arc for visibility.
[*][i]Divergence Lines[/i]: Connecting lines drawn on both the oscillator and the price chart at divergence pivot points highlight structural disagreement between price and momentum, with bullish divergence lines in green and bearish divergence lines in red.
[*][i]Divergence Labels[/i]: Bull and Bear labels appear at confirmed divergence pivot points on the oscillator pane, identifying the divergence type for immediate reference.
[*][i]Trend Candles[/i]: Optional candle coloring on the price chart reflects current arc trend state, providing directional context on the main chart without requiring the oscillator pane to be in view.
[/list]
Arc proximity to momentum, flip signal frequency, strength band opacity, and divergence conditions collectively provide more information than any element in isolation.

[b]Signal Logic & Visual Cues[/b]

Arc Momentum Oscillator presents two primary arc interaction signals alongside continuous divergence monitoring:
[list=1]
[*][i]Bullish Arc Flip[/i]: Triggered when momentum crosses above the arc by more than the volatility-scaled buffer, causing the arc to reset below momentum at the full Start Distance offset and begin a fresh bullish acceleration cycle.
[*][i]Bearish Arc Flip[/i]: Triggered when momentum crosses below the arc by more than the volatility-scaled buffer, causing the arc to reset above momentum at the full Start Distance offset and begin a fresh bearish acceleration cycle.
[/list]
Divergence detection provides secondary reversal context, with bullish divergence identifying price weakness not confirmed by oscillator structure and bearish divergence identifying price strength not confirmed by oscillator structure.

Alert generation covers bullish and bearish arc flips and entry into bull and bear extreme zones for systematic momentum monitoring workflows.

[b]Strategy Integration[/b]

Arc Momentum Oscillator fits within momentum-informed and conviction-tracking approaches across trend-following and reversal frameworks:
[list]
[*][i]Flip-Based Directional Entries[/i]: Use arc flip signals as momentum regime change confirmations, entering in the flip direction when the arc reset occurs after a statistically significant momentum breach rather than at arbitrary oscillator levels.
[*][i]Arc Convergence Monitoring[/i]: Track the closing distance between the arc and momentum during established trends as a real-time conviction gauge; tight arc-to-momentum gaps indicate mature trend conditions where a flip becomes increasingly possible with minimal additional momentum deterioration.
[*][i]Extreme Zone Context[/i]: Use extreme background tinting and strength band intensity as momentum extension warnings rather than reversal signals, treating extended extreme readings with the caution appropriate to overextended momentum states.
[*][i]Divergence-Confirmed Reversals[/i]: Use divergence signals as anticipatory context for potential arc flips, weighting flip signals more heavily when a divergence condition has formed in the bars preceding the flip rather than treating them as independent signals.
[*][i]Trend Candle Alignment[/i]: Use trend candle coloring on the price chart to maintain arc trend state awareness when analyzing price action directly, ensuring entry and exit decisions remain aligned with the current oscillator regime.
[*][i]Multi-Timeframe Momentum Confirmation[/i]: Apply higher-timeframe arc trend state as a directional momentum filter, favoring trades where lower-timeframe flip signals align with the established higher-timeframe arc direction rather than opposing it.
[/list]
[b]Technical Implementation Details[/b]
[list]
[*][i]Momentum Source[/i]: RSI-centered around zero with configurable length and EMA smoothing pass
[*][i]Adaptive Unit[/i]: Rolling 100-bar standard deviation of momentum for volatility-normalized arc scaling
[*][i]Arc Engine[/i]: Stateful acceleration system with velocity accumulation, smoothing-interval advancement, and flip-triggered reset
[*][i]Flip Buffer[/i]: Volatility-scaled separation requirement preventing marginal arc crossovers from triggering flips
[*][i]Divergence System[/i]: Pivot array-based regular divergence detection with configurable pivot size, minimum and maximum distance, and cooloff between successive divergences of the same type
[*][i]Visualization[/i]: Cloud fill, adaptive strength bands, extreme background tinting, reference rails, and divergence lines on both oscillator and price chart
[*][i]Signal Output[/i]: Flip arrows on price chart, divergence labels on oscillator pane, and optional trend candle coloring
[*][i]Performance Profile[/i]: Optimized for real-time execution across all timeframes with adaptive unit calculation ensuring consistent behavior across instruments with different volatility characteristics
[/list]
[b]Optimal Application Parameters[/b]

Timeframe Guidance:
[list]
[*][i]1 - 5 min[/i]: Rapid flip detection for scalping with shorter RSI length and higher arc speed for faster momentum tracking
[*][i]15 - 60 min[/i]: Intraday momentum regime identification with balanced smoothing and moderate arc acceleration settings
[*][i]4H - Daily[/i]: Swing-level momentum trend tracking with longer smoothing and slower arc speed for sustained conviction measurement
[/list]
Suggested Baseline Configuration:
[list]
[*][i]RSI Length[/i]: 5
[*][i]Momentum Smoothing[/i]: 17
[*][i]Arc Speed[/i]: 0.11
[*][i]Start Distance (σx)[/i]: 3.5
[*][i]Arc Smoothing[/i]: 5
[*][i]Extreme Threshold[/i]: 30
[*][i]Show Cloud Fill[/i]: Enabled
[*][i]Show Reference Rails[/i]: Enabled
[*][i]Highlight Extremes[/i]: Enabled
[*][i]Calculate Divergences[/i]: Enabled
[*][i]Show Trend Candles[/i]: Enabled
[/list]
These suggested parameters should be used as a baseline; their effectiveness depends on the instrument's momentum characteristics, volatility profile, and preferred flip frequency, so fine-tuning is expected for optimal performance.

[b]Parameter Calibration Notes[/b]

Use the following adjustments to refine behavior without altering the core logic:
[list]
[*][i]Too many arc flips[/i]: Increase Start Distance to place the arc further from momentum on each reset, requiring more sustained momentum displacement before a flip registers, or increase Momentum Smoothing to reduce the noise feeding into the arc engine.
[*][i]Arc flips too infrequent[/i]: Decrease Start Distance toward 2.0 for a tighter initial arc offset, or increase Arc Speed so the arc converges faster and becomes more sensitive to momentum reversals as the trend matures.
[*][i]Arc converges too slowly[/i]: Increase Arc Speed to accelerate the rate at which the arc closes the gap to momentum, producing earlier flip sensitivity during sustained trend conditions.
[*][i]Arc converges too quickly[/i]: Decrease Arc Speed toward 0.02 to slow convergence, maintaining a wider arc-to-momentum gap for longer and requiring more significant momentum deterioration before a flip becomes possible.
[*][i]Momentum line too noisy[/i]: Increase Momentum Smoothing toward 20 for a cleaner momentum line with less bar-to-bar reactivity, or increase RSI Length for a slower underlying momentum source.
[*][i]Extreme highlights activating too often[/i]: Increase Extreme Threshold toward 40 or 50 to restrict background tinting to only the most significant momentum extension events.
[*][i]Too many divergence signals[/i]: Increase Pivot Left and Right values to demand more structurally significant pivot confirmations, or increase the minimum pivot distance to prevent closely-spaced pivots from qualifying for divergence comparison.
[/list]
Adjustments should be incremental and evaluated across multiple session types rather than isolated market conditions.

[b]Performance Characteristics[/b]

High Effectiveness:
[list]
[*]Trending markets where momentum builds and sustains in one direction, allowing arc acceleration to develop meaningful convergence before the next flip
[*]Instruments with consistent RSI behavior where centered momentum reliably reflects directional conviction and the standard deviation unit stabilizes quickly after initialization
[*]Momentum continuation strategies using arc flip signals as regime change confirmations rather than as precise entry timing tools
[*]Divergence-aware reversal approaches where oscillator structure disagrees with price structure ahead of trend changes, providing anticipatory context for flip signals
[/list]
Reduced Effectiveness:
[list]
[*]Choppy, low-momentum markets where rapid alternation between bullish and bearish RSI conditions produces frequent arc flips without sustained directional follow-through
[*]Extremely low-volatility environments where momentum standard deviation collapses and the adaptive unit loses its discriminative power for scaling arc behavior
[*]News-driven or gap-heavy instruments where sudden momentum spikes trigger arc flips that immediately reverse before the acceleration cycle develops meaningful convergence
[*]Markets with inconsistent RSI dynamics where the centered momentum line fails to produce clean pivot structure, reducing divergence detection reliability
[*]Consolidation and sideways conditions where momentum oscillates near zero without sufficient directional displacement to sustain arc trend states or produce clean flip sequences
[/list]
[b]Integration Guidelines[/b]
[list]
[*][i]Confluence[/i]: Combine with BOSWaves structural tools, volume analysis, or adaptive band indicators to validate arc flip signals with price structure and participation context
[*][i]Arc Convergence Awareness[/i]: Monitor arc-to-momentum distance as a real-time trend maturity indicator; tightly converged arc conditions suggest a flip requires minimal further momentum deterioration and warrant increased vigilance
[*][i]Divergence Respect[/i]: Treat divergence signals as context-building evidence rather than standalone triggers; their value increases when they precede an arc flip in the divergence direction rather than occurring in isolation
[*][i]Extreme Zone Caution[/i]: Avoid initiating new positions in the direction of extreme momentum readings; use extreme zone detection as a signal to monitor for arc convergence and potential flip conditions rather than as a continuation entry context
[*][i]State Discipline[/i]: Maintain directional bias aligned with the current arc trend state until a confirmed flip occurs. Short-term momentum oscillations toward zero that do not breach the arc with sufficient buffer do not constitute trend changes.
[/list]
[b]Disclaimer[/b]

Arc Momentum Oscillator [BOSWaves] is a professional-grade momentum analysis and divergence detection tool. It uses acceleration-driven arc mechanics with volatility-normalized momentum measurement but does not predict future price movements. Results depend on market conditions, instrument momentum characteristics, parameter selection, and disciplined execution. BOSWaves recommends deploying this indicator within a broader analytical framework that incorporates price structure, volume context, and comprehensive risk management.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BOSWaves

//@version=6
indicator("Arc Momentum Oscillator [BOSWaves]", overlay = false, precision = 2)

int   rsiLen     = input.int(5, "RSI Length", minval = 2, maxval = 100,tooltip = "Length of the underlying RSI used as the momentum source. Higher = smoother momentum, slower flips.")
int   rsiSmooth  = input.int(17, "Momentum Smoothing", minval = 1, maxval = 20,tooltip = "ema smoothing applied to the centered RSI before the arc engine sees it. Higher = cleaner momentum line, less noise.")

float accelRate  = input.float(0.11, "Arc Speed", step = 0.01, minval = 0.01,tooltip = "Base acceleration rate of the arc as it chases momentum. Higher = arc closes the gap faster.")
float startMult  = input.float(3.5, "Start Distance (σ×)", step = 0.1,tooltip = "How far the arc is placed from momentum when a new trend begins, measured in multiples of momentum standard deviation. Higher = more breathing room before a flip.")
int   smooth     = input.int(5, "Arc Smoothing", minval = 1, maxval = 10,tooltip = "Bars used to smooth the arc curve. Higher = silkier arc, more lag.")
float arrowOffset = input.float(8.0, "Arrow Offset", step = 0.5, minval = 0.1,tooltip = "How far flip arrows are pushed away from the arc, in oscillator units.")

bool  showCloud   = input.bool(true,  "Show Cloud Fill",tooltip = "Fill between arc and momentum line, colored by trend direction.")
bool  showRails   = input.bool(true,  "Show Reference Rails",tooltip = "Show the 0 mid-line and ±25 / ±extreme reference levels.")
bool  showExtBg   = input.bool(true,  "Highlight Extremes",tooltip = "Tint the background when momentum is in extreme territory.")
float extremeLvl  = input.float(30, "Extreme Threshold", minval = 10, maxval = 50, step = 1,tooltip = "Absolute momentum level above which extreme background tint activates. Default 30 means tint above +30 / below -30.")

color colUp       = input.color(#1ac200, "Bull Color", inline = "c",tooltip = "Color used for bullish arc, cloud, candles, and flip markers.")
color colDn       = input.color(#ff4040, "Bear Color", inline = "c",tooltip = "Color used for bearish arc, cloud, candles, and flip markers.")
bool showCandles  = input.bool(true, "Show Trend Candles")

const string tt12 = "Enable regular bullish/bearish divergence detection between price and the oscillator. This is required for divergence alerts."
const string tt13 = "Pivot size used to confirm swing points for divergence detection. Higher values reduce noise but trigger fewer signals."
const string tt14 = "Minimum bars allowed between pivots being compared."
bool show_divergences = input.bool(true, "Calculate Divergences",tooltip=tt12, display=display.data_window)
bool show_div_labels  = input.bool(true, "Show Divergence Labels")
bool show_div_lines   = input.bool(true, "Show Divergence Lines on Price")

int div_left      = input.int(20, "Pivot Left",  minval=1,tooltip=tt13, inline="div1")
int div_right     = input.int(20, "Right",       minval=1,tooltip=tt13, inline="div1")
int div_range_min = input.int(5,  "Min Pivot Distance", minval=1,tooltip=tt14, inline="div2")
int div_range_max = input.int(60, "Max",                minval=1,tooltip=tt14, inline="div2")
// ┌───────────────────────────── BOSWaves ─ Momentum Source ─────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

float rsi      = ta.rsi(close, rsiLen)
float momentum = ta.ema(rsi - 50.0, rsiSmooth)  // centered: -50 to +50

float momStd   = ta.stdev(momentum, 100)
float unit     = nz(momStd, 10.0) // adaptive unit replacing ATR

// ┌───────────────────────────── BOSWaves ─ Arc Engine ──────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

var bool  trend    = true
var float arc      = na
var float velocity = 0.0
var bool  initDone = false

if not initDone and not na(momStd) and bar_index > 100
    arc      := momentum - unit * startMult
    trend    := true
    initDone := true

if initDone
    float flipBuffer = unit * 0.20

    if momentum < arc - flipBuffer
        trend := false
    if momentum > arc + flipBuffer
        trend := true

bool rawFlipped = initDone and trend != trend[1]

if rawFlipped and trend
    arc      := momentum - unit * startMult
    velocity := 0.0

if rawFlipped and not trend
    arc      := momentum + unit * startMult
    velocity := 0.0

float stepSize = unit * 0.15

if initDone and bar_index % smooth == 0
    velocity += accelRate
    if trend
        arc += stepSize * velocity
    else
        arc -= stepSize * velocity

float arcSmooth = ta.sma(arc, smooth)
// Clamp visually so the arc never escapes the pane
float arcDisp   = math.max(-55.0, math.min(55.0, arcSmooth))

color trendcol  = trend ? colUp : colDn

// ┌───────────────────────────── BOSWaves ─ Background Tint ─────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

bool inExtreme = math.abs(momentum) >= extremeLvl
color bgClr = showExtBg and inExtreme ? (momentum >= 0 ? color.new(colUp, 92) : color.new(colDn, 92)) : na
bgcolor(bgClr, title = "Extreme Zone")

// ┌───────────────────────────── BOSWaves ─ Reference Rails ─────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

hline(0,            "Mid",         color = color.new(chart.fg_color, 65), linestyle = hline.style_solid)
hline(showRails ?  25 : na, "Upper Mid",   color = color.new(chart.fg_color, 85), linestyle = hline.style_dotted)
hline(showRails ? -25 : na, "Lower Mid",   color = color.new(chart.fg_color, 85), linestyle = hline.style_dotted)
hline(showRails ?  extremeLvl  : na, "Upper Extreme", color = color.new(colUp, 75), linestyle = hline.style_dashed)
hline(showRails ? -extremeLvl  : na, "Lower Extreme", color = color.new(colDn, 75), linestyle = hline.style_dashed)

// ┌───────────────────────────── BOSWaves ─ Plot ────────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

// Arc only draws when not on a flip bar (keeps the line clean across flips)
float arcPlotVal = initDone and not rawFlipped ? arcDisp : na
float momPlotVal = initDone ? momentum : na

pArc = plot(arcPlotVal, "Arc",      color = color.new(chart.fg_color, 50), linewidth = 1, style = plot.style_linebr)
pMom = plot(momPlotVal, "Momentum", color = color.new(trendcol, 0),         linewidth = 2)

// Cloud fill between arc and momentum, color = trend
color fillClr = showCloud and initDone ? color.new(trendcol, 70) : na
fill(pArc, pMom, arcDisp, momentum, fillClr, color(na))

plotcandle(open,high,low,close, "Trend Candles", trendcol, trendcol, true, bordercolor = trendcol, display = showCandles?display.all:display.none, force_overlay = true)
// ┌───────────────────────────── BOSWaves ─ Flip Arrows ─────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

float bullArrowY = rawFlipped and trend     ? arcDisp - arrowOffset : na
float bearArrowY = rawFlipped and not trend ? arcDisp + arrowOffset : na

plotshape(bullArrowY, "Bull Flip",
     style = shape.triangleup, location = location.belowbar,
     color = colUp, size = size.tiny, force_overlay=true)

plotshape(bearArrowY, "Bear Flip",
     style = shape.triangledown, location = location.abovebar,
     color = colDn, size = size.tiny, force_overlay=true)

// ┌───────────────────────────── BOSWaves ─ Strength Bands ──────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

clamp(value, min_val, max_val) =>
    math.max(min_val, math.min(value, max_val))

float lo  = float(-35)
float hi  = float(35)
float mid = float(0)
float max_strength = (hi - lo) * 0.5

float osc_clamped  = clamp(momentum, lo, hi)
float strength     = math.abs(osc_clamped - mid)
float strength_pct = max_strength > 0 ? math.min(strength / max_strength * 100.0, 100.0) : 0.0
int   alpha_val    = int(100.0 - strength_pct)

plot_u1 = plot(showRails ?  50 : na, "Upper Extreme", color=#00000000)
plot_u2 = plot(showRails ?  40 : na, "Upper Band",    color=#00000000)
fill(plot_u1, plot_u2,
     osc_clamped > mid ? color.new(colUp, alpha_val) : color.new(color.white, 100),
     "Upper Strength")

plot_l1 = plot(showRails ? -50 : na, "Lower Extreme", color=#00000000)
plot_l2 = plot(showRails ? -40 : na, "Lower Band",    color=#00000000)
fill(plot_l1, plot_l2,
     osc_clamped < mid ? color.new(colDn, alpha_val) : color.new(color.white, 100),
     "Lower Strength")

// ┌────────────────────────────── BOSWaves ─ Divergences ────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

bool pl_found = false
bool ph_found = false
bool bull_div = false
bool bear_div = false

float osc_r = momentum[div_right]

if show_divergences
    var int[]   ph_bars   = array.new_int()
    var float[] ph_vals   = array.new_float()
    var float[] ph_prices = array.new_float()
    var int[]   pl_bars   = array.new_int()
    var float[] pl_vals   = array.new_float()
    var float[] pl_prices = array.new_float()

    var int lastBearDivBar = 0
    var int lastBullDivBar = 0

    float ph = ta.pivothigh(momentum, div_left, div_right)
    if not na(ph)
        ph_found := true
        array.push(ph_bars, bar_index[div_right])
        array.push(ph_vals, ph)
        array.push(ph_prices, high[div_right])

        if array.size(ph_bars) > 20
            array.shift(ph_bars)
            array.shift(ph_vals)
            array.shift(ph_prices)

        if array.size(ph_bars) >= 2
            for i = array.size(ph_bars) - 2 to math.max(0, array.size(ph_bars) - 6)
                int bar1     = array.get(ph_bars, i)
                float val1   = array.get(ph_vals, i)
                float price1 = array.get(ph_prices, i)
                int bar2     = bar_index[div_right]
                float val2   = ph
                float price2 = high[div_right]

                int barDiff = bar2 - bar1

                if barDiff >= div_range_min and barDiff <= div_range_max
                    if price2 > price1 and val2 < val1
                        if bar2 - lastBearDivBar > div_left * 2
                            bear_div := true
                            lastBearDivBar := bar2

                            if show_div_lines
                                line.new(bar1, val1, bar2, val2, color=color.new(colDn, 20), width=3)

                            if show_div_lines
                                line.new(bar1, price1, bar2, price2, color=color.new(colDn, 30), width=3, force_overlay=true)
                            break

    float pl = ta.pivotlow(momentum, div_left, div_right)
    if not na(pl)
        pl_found := true
        array.push(pl_bars, bar_index[div_right])
        array.push(pl_vals, pl)
        array.push(pl_prices, low[div_right])

        if array.size(pl_bars) > 20
            array.shift(pl_bars)
            array.shift(pl_vals)
            array.shift(pl_prices)

        if array.size(pl_bars) >= 2
            for i = array.size(pl_bars) - 2 to math.max(0, array.size(pl_bars) - 6)
                int bar1     = array.get(pl_bars, i)
                float val1   = array.get(pl_vals, i)
                float price1 = array.get(pl_prices, i)
                int bar2     = bar_index[div_right]
                float val2   = pl
                float price2 = low[div_right]

                int barDiff = bar2 - bar1

                if barDiff >= div_range_min and barDiff <= div_range_max
                    if price2 < price1 and val2 > val1
                        if bar2 - lastBullDivBar > div_left * 2
                            bull_div := true
                            lastBullDivBar := bar2

                            if show_div_lines
                                line.new(bar1, val1, bar2, val2, color=color.new(colUp, 20), width=3)

                            if show_div_lines
                                line.new(bar1, price1, bar2, price2, color=color.new(colUp, 30), width=3, force_overlay=true)
                            break

plot(pl_found and show_divergences ? osc_r : na, title="Bull Pivot (osc)", offset=-div_right, linewidth=3, color=color.new(colUp, bull_div ? 0 : 100), display=display.pane, editable=show_divergences)
plot(ph_found and show_divergences ? osc_r : na, title="Bear Pivot (osc)", offset=-div_right, linewidth=3, color=color.new(colDn, bear_div ? 0 : 100), display=display.pane, editable=show_divergences)

plotshape(show_divergences and show_div_labels and bull_div ? osc_r : na, title="Bullish Divergence", offset=-div_right, style=shape.labelup,   location=location.absolute, color=colUp, text="𝐁𝐮𝐥𝐥", textcolor=chart.fg_color, display=display.pane)
plotshape(show_divergences and show_div_labels and bear_div ? osc_r : na, title="Bearish Divergence", offset=-div_right, style=shape.labeldown, location=location.absolute, color=colDn, text="𝐁𝐞𝐚𝐫", textcolor=chart.fg_color, display=display.pane)
// ┌───────────────────────────── BOSWaves ─ Alerts ──────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

alertcondition(rawFlipped and trend,         "Bullish Arc Flip",     "Arc Momentum Oscillator flipped bullish on {{ticker}}")
alertcondition(rawFlipped and not trend,     "Bearish Arc Flip",     "Arc Momentum Oscillator flipped bearish on {{ticker}}")
alertcondition(momentum >= extremeLvl and momentum[1] < extremeLvl,   "Entered Bull Extreme", "Arc Momentum entered bull extreme zone on {{ticker}}")
alertcondition(momentum <= -extremeLvl and momentum[1] > -extremeLvl, "Entered Bear Extreme", "Arc Momentum entered bear extreme zone on {{ticker}}")
````
