# Meridian Stochastic Regime Suite [JOAT]

- url: https://www.tradingview.com/script/BoLz43XC-Meridian-Stochastic-Regime-Suite-JOAT/
- type: indicator
- pine_id: PUB;1e4a70933ff04b6085f47435294d7c0e
- version: 1.0

## Description

[b]Meridian Stochastic Regime Suite [JOAT][/b]

[b]Introduction[/b]

Meridian Stochastic Regime Suite is an open-source adaptive oscillator built for traders who want more context than a standard stochastic line can provide. The script combines a centered stochastic engine, an adaptive response model, and a regime profile so the oscillator changes character as the market shifts between trend, compression, expansion, and balance.

The problem Meridian solves is signal quality. Standard oscillators often look clean, but they do not explain whether momentum is occurring inside a compressed market, an expanding breakout phase, or a stable trend. Meridian adds that context directly into the oscillator architecture so the same reading can be interpreted differently depending on the active regime profile.

[image]https://www.tradingview.com/x/DfRuJ0dP/[/image]

[b]Core Concepts[/b]

[b]1. Centered stochastic architecture[/b]

Price is pre-smoothed first, then converted into a stochastic reading that is centered around 50 so directional pressure is easy to interpret:

[pine]
smoothHigh  = ta.ema(high, priceSmoothLen)
smoothLow   = ta.ema(low, priceSmoothLen)
smoothClose = ta.ema(close, priceSmoothLen)
rawStoch    = 100.0 * (smoothClose - ta.lowest(smoothLow, stochLen)) / stochRange
[/pine]

[b]2. Adaptive response engine[/b]

The main oscillator does not use static smoothing alone. Its response speed and gain expand or contract based on the regime profile:

[pine]
gainBias  = gainBase + trendScore * 0.38 + expansionScore * 0.18 - compressionScore * 0.12
speedBias = responseBase + trendScore * 0.08 + expansionScore * 0.04
adaptiveOsc := adaptiveOsc[1] + speedBias * (adaptiveSeed - adaptiveOsc[1])
[/pine]

This helps the oscillator respond differently in directional and compressed conditions.

[b]3. Embedded regime scoring[/b]

Meridian computes four internal state scores:

[list]
[*]Trend
[*]Compression
[*]Expansion
[*]Balance
[/list]

Those scores are derived from ATR behavior, path efficiency, and slope strength, then normalized into a regime profile shown in the dashboard.

[b]4. Spread and signal layer[/b]

The script compares the adaptive oscillator to a slower signal line and visualizes the spread around the neutral axis. This gives a direct view of acceleration versus drag.

[b]5. Institutional oscillator panel[/b]

The panel uses restrained zones, layered fills, and a top-right dashboard instead of loud markers. The result stays readable while still carrying multiple analytical dimensions.

[image]https://www.tradingview.com/x/cNTbJiLK/[/image]

[b]Features[/b]

[list]
[*][b]Centered stochastic core:[/b] Keeps the oscillator readable around a neutral midpoint
[*][b]Adaptive response model:[/b] Gain and speed shift with the internal regime profile
[*][b]Four-state regime map:[/b] Trend, Compression, Expansion, and Balance
[*][b]Fast line and signal line:[/b] Shows momentum acceleration versus stabilization
[*][b]Spread shading:[/b] Highlights when the adaptive oscillator is separating from the signal line
[*][b]Regime dashboard:[/b] Displays state, confidence, adaptive reading, signal reading, and regime profile shares
[*][b]Confirmed-bar flips:[/b] Internal state transitions are tracked on closed bars
[*][b]Non-repainting design:[/b] Uses only current-timeframe data and no future references
[/list]

[b]Input Parameters[/b]

[b]Stochastic Core:[/b]
[list]
[*]Price Pre-Smoothing
[*]Stochastic Length
[*]Fast Smoothing
[*]Adaptive Signal Smoothing
[/list]

[b]Regime Filter:[/b]
[list]
[*]Regime Window
[*]ATR Window
[*]Base Oscillator Gain
[*]Base Response Speed
[/list]

[b]Visual Output:[/b]
[list]
[*]Show Adaptive Zones
[*]Show Centered Fast Line
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Start with the regime[/b]
Read the dashboard first. Trend and Expansion regimes support directional interpretation. Compression and Balance call for more caution.

[b]Step 2: Watch adaptive versus signal spread[/b]
When the adaptive line separates cleanly from the signal line, momentum is strengthening. When the spread compresses, the move is losing urgency.

[b]Step 3: Use the centered fast line as timing context[/b]
The fast line helps show whether short-term momentum is leading or lagging the adaptive engine.

[b]Step 4: Avoid isolated readings[/b]
Meridian is strongest when used alongside a structure or value-based tool rather than as a standalone trade trigger.

[b]Indicator Limitations[/b]

[list]
[*]Like all oscillators, Meridian can remain elevated or depressed during strong directional trends
[*]Compression states may delay re-acceleration readings until volatility expands again
[*]The regime profile is descriptive, not predictive
[/list]

[b]Originality Statement[/b]

Meridian Stochastic Regime Suite is original in how it embeds a four-state regime profile directly into the adaptive behavior of a centered stochastic engine. It is published because:

[list]
[*]The oscillator response changes with internal market-state measurements instead of using only fixed smoothing
[*]The script surfaces trend, compression, expansion, and balance as percentages inside the same panel
[*]The panel and dashboard design turn regime context into an interpretable momentum framework rather than a generic stochastic clone
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to trade. Oscillator readings can remain extreme for extended periods, and regime classifications can shift as conditions evolve. Always use independent judgment and proper risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Meridian Stochastic Regime Suite [JOAT]", "MRS [JOAT]", overlay = false, max_bars_back = 2000, max_labels_count = 10)

//--------------------------------------------------------------------------------------------------
// Color system
//--------------------------------------------------------------------------------------------------
color BG        = #0e1217
color PANEL     = #121822
color BORDER    = #263141
color TEXT      = #d8e1ec
color MUTED     = #8f9bad
color ACCENT    = #6ea8ff
color BULL      = #25d4b2
color BEAR      = #ff6b7a
color AMBER     = #f4c86a
color SOFT      = #9cb1d1

//--------------------------------------------------------------------------------------------------
// Inputs
//--------------------------------------------------------------------------------------------------
string coreGroup    = "Stochastic Core"
int priceSmoothLen   = input.int(8,  "Price Pre-Smoothing", minval = 1, group = coreGroup)
int stochLen         = input.int(20, "Stochastic Length", minval = 2, group = coreGroup)
int kSmoothLen       = input.int(5,  "Fast Smoothing", minval = 1, group = coreGroup)
int dSmoothLen       = input.int(9,  "Adaptive Signal Smoothing", minval = 1, group = coreGroup)

string regimeGroup   = "Regime Filter"
int regimeLen        = input.int(34, "Regime Window", minval = 5, group = regimeGroup)
int atrLen           = input.int(14, "ATR Window", minval = 1, group = regimeGroup)
float gainBase       = input.float(0.62, "Base Oscillator Gain", minval = 0.1, step = 0.01, group = regimeGroup)
float responseBase   = input.float(0.12, "Base Response Speed", minval = 0.01, step = 0.01, group = regimeGroup)

string viewGroup     = "Visual Output"
bool showZones       = input.bool(true, "Show Adaptive Zones", group = viewGroup)
bool showFastLine    = input.bool(true, "Show Centered Fast Line", group = viewGroup)
bool tintCandles     = input.bool(true, "Tint Candles", group = viewGroup)
bool showBackdrop    = input.bool(true, "Show Chart Backdrop", group = viewGroup)
bool showImpulseBars = input.bool(true, "Show Impulse Columns", group = viewGroup)

//--------------------------------------------------------------------------------------------------
// Utility helpers
//--------------------------------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_safe_div(float num, float den) =>
    den != 0.0 ? num / den : 0.0

f_pct(float x) =>
    str.tostring(x, "0.0") + "%"

f_state_text(int state) =>
    state == 1 ? "TREND" : state == 2 ? "COMPRESSION" : state == 3 ? "EXPANSION" : "BALANCE"

f_state_color(int state) =>
    state == 1 ? BULL : state == 2 ? AMBER : state == 3 ? ACCENT : SOFT

f_table_cell(table t, int col, int row, string txt, color txtColor, color bgColor, string align) =>
    table.cell(t, col, row, txt, text_color = txtColor, bgcolor = bgColor, text_halign = align, text_size = size.normal)

//--------------------------------------------------------------------------------------------------
// Core stochastic engine
//--------------------------------------------------------------------------------------------------
float smoothHigh  = ta.ema(high, priceSmoothLen)
float smoothLow   = ta.ema(low, priceSmoothLen)
float smoothClose = ta.ema(close, priceSmoothLen)

float stochRange  = ta.highest(smoothHigh, stochLen) - ta.lowest(smoothLow, stochLen)
float rawStoch    = 100.0 * f_safe_div(smoothClose - ta.lowest(smoothLow, stochLen), stochRange)
float clampedK    = f_clamp(rawStoch, 0.0, 100.0)
float centeredK   = clampedK - 50.0

// The centered fast line keeps the oscillator readable while remaining responsive to fresh price action.
float fastCentered = 50.0 + (ta.ema(clampedK, kSmoothLen) - 50.0) * 0.72

//--------------------------------------------------------------------------------------------------
// Regime metrics
//--------------------------------------------------------------------------------------------------
float atrValue     = ta.atr(atrLen)
float atrBaseline  = ta.ema(atrValue, regimeLen)
float volRatio     = f_safe_div(atrValue, atrBaseline)
float volGap       = math.abs(volRatio - 1.0)

float pathMove     = math.sum(math.abs(close - close[1]), regimeLen)
float netMove      = math.abs(close - close[regimeLen])
float efficiency   = f_safe_div(netMove, pathMove)

float slopeValue   = ta.linreg(close, regimeLen, 0) - ta.linreg(close, regimeLen, 1)
float slopeNorm    = f_clamp(math.abs(f_safe_div(slopeValue, atrValue + 1e-10)), 0.0, 2.5) / 2.5

// Trend strength favors directional persistence and clean slope.
float trendScore   = f_clamp(0.58 * efficiency + 0.42 * slopeNorm, 0.0, 1.0)

// Compression rises when volatility contracts and directional efficiency fades.
float compressionScore = f_clamp((1.15 - volRatio) * (1.0 - trendScore), 0.0, 1.0)

// Expansion is strongest when volatility opens up without a fully exhausted trend profile.
float expansionScore = f_clamp((volRatio - 0.95) * 0.72 + slopeNorm * 0.28, 0.0, 1.0)

// Balance captures the residual state when no other regime is dominant.
float balanceScore  = f_clamp(1.0 - math.max(math.max(trendScore, compressionScore), expansionScore), 0.0, 1.0)

float regimeSum     = trendScore + compressionScore + expansionScore + balanceScore
float trendPct      = 100.0 * f_safe_div(trendScore, regimeSum)
float compressionPct = 100.0 * f_safe_div(compressionScore, regimeSum)
float expansionPct  = 100.0 * f_safe_div(expansionScore, regimeSum)
float balancePct    = 100.0 * f_safe_div(balanceScore, regimeSum)

int regimeState = trendScore >= compressionScore and trendScore >= expansionScore and trendScore >= balanceScore ? 1 :
     compressionScore >= trendScore and compressionScore >= expansionScore and compressionScore >= balanceScore ? 2 :
     expansionScore >= trendScore and expansionScore >= compressionScore and expansionScore >= balanceScore ? 3 : 0

float regimeConfidence = f_clamp(math.max(math.max(trendScore, compressionScore), math.max(expansionScore, balanceScore)), 0.0, 1.0)

//--------------------------------------------------------------------------------------------------
// Adaptive oscillator engine
//--------------------------------------------------------------------------------------------------
float gainBias     = f_clamp(gainBase + trendScore * 0.38 + expansionScore * 0.18 - compressionScore * 0.12, 0.25, 1.35)
float speedBias    = f_clamp(responseBase + trendScore * 0.08 + expansionScore * 0.04 + balanceScore * 0.02, 0.03, 0.32)

float adaptiveSeed = 50.0 + centeredK * gainBias
var float adaptiveOsc = 50.0
adaptiveOsc := nz(adaptiveOsc[1], 50.0) + speedBias * (adaptiveSeed - nz(adaptiveOsc[1], 50.0))

float signalLine   = ta.ema(adaptiveOsc, dSmoothLen)
float spread       = adaptiveOsc - signalLine
float spreadScale  = 1.7 + trendScore * 0.7 + expansionScore * 0.5
float spreadPlot   = 50.0 + spread * spreadScale

// Confirmed-bar regime turns for real-time safety.
bool confirmedBullCross = barstate.isconfirmed and ta.crossover(adaptiveOsc, signalLine)
bool confirmedBearCross = barstate.isconfirmed and ta.crossunder(adaptiveOsc, signalLine)

var int lastFlipBar = na
var string lastFlipText = "None"
if confirmedBullCross
    lastFlipBar := bar_index
    lastFlipText := "Bull cross"
else if confirmedBearCross
    lastFlipBar := bar_index
    lastFlipText := "Bear cross"

int barsSinceFlip = na(lastFlipBar) ? na : bar_index - lastFlipBar

// Locked bias is only updated on confirmed bars so the dashboard remains realtime-safe.
var int lockedBias = 0
if barstate.isconfirmed
    lockedBias := adaptiveOsc > signalLine ? 1 : adaptiveOsc < signalLine ? -1 : lockedBias

string biasText = lockedBias == 1 ? "BULL" : lockedBias == -1 ? "BEAR" : "NEUTRAL"
color biasColor = lockedBias == 1 ? BULL : lockedBias == -1 ? BEAR : SOFT
color regimeGlow = regimeState == 1 ? BULL : regimeState == 2 ? AMBER : regimeState == 3 ? ACCENT : SOFT
float signedConfidence = regimeConfidence * (lockedBias == 1 ? 1.0 : lockedBias == -1 ? -1.0 : 0.0)

//--------------------------------------------------------------------------------------------------
// Visual architecture
//--------------------------------------------------------------------------------------------------
hline(80, "Upper Reference", color.new(TEXT, 70), linestyle = hline.style_dashed)
hline(50, "Center", color.new(TEXT, 82), linestyle = hline.style_dotted)
hline(20, "Lower Reference", color.new(TEXT, 70), linestyle = hline.style_dashed)

plotMid = plot(50, "Center Anchor", color = na, display = display.none)
plotFast = plot(showFastLine ? fastCentered : na, "Centered Fast", color = color.new(ACCENT, 35), linewidth = 1, style = plot.style_line)
plotAdaptive = plot(adaptiveOsc, "Adaptive Meridian", color = biasColor, linewidth = 2)
plotSignal = plot(signalLine, "Signal Meridian", color = color.new(SOFT, 20), linewidth = 1, style = plot.style_line)
plot(spreadPlot, "Spread Meridian", color = color.new(biasColor, 70), linewidth = 1, style = plot.style_line)

float zoneSpan = 11.0 + trendScore * 8.0 + expansionScore * 6.0 - compressionScore * 4.0
float zoneUpper = 50.0 + zoneSpan
float zoneLower = 50.0 - zoneSpan

plotZoneUpper = plot(showZones ? zoneUpper : na, "Upper Zone", color = na)
plotZoneLower = plot(showZones ? zoneLower : na, "Lower Zone", color = na)
fill(plotZoneUpper, plotZoneLower, color = color.new(biasColor, 90), title = "Adaptive Zone Fill")

fill(plotAdaptive, plotSignal, color = color.new(biasColor, 82), title = "Oscillator Spread Fill")
fill(plotFast, plotMid, color = color.new(ACCENT, 94), title = "Fast Center Fill")
plot(showImpulseBars ? 50.0 + signedConfidence * 34.0 : na, "Confidence Impulse", color = color.new(regimeGlow, 10), linewidth = 4, style = plot.style_columns)
plot(50.0 + trendScore * 30.0, "Trend Field", color = color.new(BULL, 80), linewidth = 1, style = plot.style_area)
plot(50.0 - compressionScore * 30.0, "Compression Field", color = color.new(AMBER, 82), linewidth = 1, style = plot.style_area)

barcolor(tintCandles ? color.new(color.from_gradient(spread, -12.0, 12.0, BEAR, BULL), lockedBias == 0 ? 38 : 0) : na)
bgcolor(showBackdrop ? color.new(regimeGlow, regimeState == 2 ? 92 : 95) : na)
plotshape(confirmedBullCross ? 14 : na, "Bull Cross Pulse", shape.circle, location.absolute, color.new(BULL, 0), size = size.tiny)
plotshape(confirmedBearCross ? 86 : na, "Bear Cross Pulse", shape.circle, location.absolute, color.new(BEAR, 0), size = size.tiny)
plotshape(barstate.isconfirmed and regimeState == 3 ? 92 : na, "Expansion Pulse", shape.diamond, location.absolute, color.new(ACCENT, 10), size = size.tiny)
plotshape(barstate.isconfirmed and regimeState == 2 ? 8 : na, "Compression Pulse", shape.diamond, location.absolute, color.new(AMBER, 10), size = size.tiny)

//--------------------------------------------------------------------------------------------------
// Dashboard
//--------------------------------------------------------------------------------------------------
var table dash = table.new(position.top_right, 2, 9, bgcolor = PANEL, border_width = 0, frame_color = BORDER, frame_width = 1)

if barstate.islast
    table.merge_cells(dash, 0, 0, 1, 0)
    f_table_cell(dash, 0, 0, "MERIDIAN SUITE", TEXT, color.new(regimeGlow, 84), text.align_center)

    table.cell(dash, 0, 1, "Regime", text_color = MUTED, bgcolor = color.new(regimeGlow, 93), text_halign = text.align_left, text_size = size.normal)
    table.cell(dash, 1, 1, f_state_text(regimeState), text_color = f_state_color(regimeState), bgcolor = color.new(regimeGlow, 93), text_halign = text.align_right, text_size = size.normal)

    table.cell(dash, 0, 2, "Confidence", text_color = MUTED, bgcolor = color.new(regimeGlow, 94), text_halign = text.align_left, text_size = size.normal)
    table.cell(dash, 1, 2, f_pct(regimeConfidence * 100.0), text_color = TEXT, bgcolor = color.new(regimeGlow, 94), text_halign = text.align_right, text_size = size.normal)

    table.cell(dash, 0, 3, "Bias", text_color = MUTED, bgcolor = color.new(biasColor, 93), text_halign = text.align_left, text_size = size.normal)
    table.cell(dash, 1, 3, biasText, text_color = biasColor, bgcolor = color.new(biasColor, 93), text_halign = text.align_right, text_size = size.normal)

    table.cell(dash, 0, 4, "Adaptive", text_color = MUTED, bgcolor = PANEL, text_halign = text.align_left, text_size = size.normal)
    table.cell(dash, 1, 4, str.tostring(adaptiveOsc, "0.0"), text_color = TEXT, bgcolor = PANEL, text_halign = text.align_right, text_size = size.normal)

    table.cell(dash, 0, 5, "Signal", text_color = MUTED, bgcolor = PANEL, text_halign = text.align_left, text_size = size.normal)
    table.cell(dash, 1, 5, str.tostring(signalLine, "0.0"), text_color = SOFT, bgcolor = PANEL, text_halign = text.align_right, text_size = size.normal)

    table.cell(dash, 0, 6, "Volume", text_color = MUTED, bgcolor = color.new(ACCENT, 94), text_halign = text.align_left, text_size = size.normal)
    table.cell(dash, 1, 6, str.tostring(volRatio, "0.00") + "x / gap " + str.tostring(volGap, "0.00"), text_color = volRatio >= 1.0 ? BULL : AMBER, bgcolor = color.new(ACCENT, 94), text_halign = text.align_right, text_size = size.normal)

    table.cell(dash, 0, 7, "Profile", text_color = MUTED, bgcolor = PANEL, text_halign = text.align_left, text_size = size.normal)
    table.cell(dash, 1, 7, "T " + f_pct(trendPct) + "  C " + f_pct(compressionPct) + "  E " + f_pct(expansionPct) + "  B " + f_pct(balancePct), text_color = TEXT, bgcolor = PANEL, text_halign = text.align_right, text_size = size.normal)

    string flipAge = na(barsSinceFlip) ? "n/a" : str.tostring(barsSinceFlip) + " bars"
    table.cell(dash, 0, 8, "Last Flip", text_color = MUTED, bgcolor = PANEL, text_halign = text.align_left, text_size = size.normal)
    table.cell(dash, 1, 8, lastFlipText + " / " + flipAge, text_color = TEXT, bgcolor = PANEL, text_halign = text.align_right, text_size = size.normal)

//--------------------------------------------------------------------------------------------------
// Notes
//--------------------------------------------------------------------------------------------------
// - The oscillator is centered at 50 and only uses historical, closed-bar calculations.
// - Regime classification is derived from efficiency, slope, and volatility expansion/contraction.
// - Confirmed cross tracking is gated by barstate.isconfirmed so the dashboard remains real-time safe.
````
