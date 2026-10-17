# Tectonic Ribbon Oscillator [JOAT]

- url: https://www.tradingview.com/script/lokgy72N-Tectonic-Ribbon-Oscillator-JOAT/
- type: indicator
- pine_id: PUB;6f6e2f41b64e4bacad8629601d13bea6
- version: 1.0

## Description

[b]Tectonic Ribbon Oscillator [JOAT][/b]

[b]Introduction[/b]

Tectonic Ribbon Oscillator is an open-source lower-pane momentum field built from twenty lag-reduced strands. The script classifies whether momentum is in bullish expansion, bearish expansion, or twist compression by comparing the ribbon's fast, mid, and slow structure instead of relying on a single oscillator line.

The problem Tectonic solves is momentum depth. A single oscillator can show direction, but it usually hides how broad or fragile the move actually is. Tectonic exposes ribbon breadth, spread, slope, and divergence in one framework so the user can distinguish acceleration from compression.

[image]https://www.tradingview.com/x/iDA55P4O/[/image]

[b]Core Concepts[/b]

[b]1. Multi-Strand Ribbon Construction[/b]

Each strand uses a progressively larger lookback and lag-reduced smoothing. This creates a depth field rather than a single-value oscillator.

[b]2. Fast-Mid-Slow Spread Logic[/b]

The oscillator compares grouped ribbon averages and uses the spread to determine whether momentum is directional or twisted into compression.

[b]3. Regime Classification[/b]

Bull, bear, and twist states are identified from the spread and held as confirmed regime transitions.

[b]4. Divergence Validation[/b]

Price pivots and ribbon pivots are compared to identify confirmed bullish and bearish divergence without using future leaks.

[b]5. Momentum Support Layers[/b]

Histogram and slope components add a second view of how the ribbon is accelerating or decelerating internally.

[b]Features[/b]

[list]
[*][b]Twenty-strand momentum ribbon:[/b] Progressive lookbacks create a true depth profile
[*][b]Lag-reduced smoothing:[/b] Ribbon strands are stabilized without reverting to a slow classic oscillator
[*][b]Twist regime detection:[/b] Compression is explicitly separated from directional impulse
[*][b]Confirmed divergence logic:[/b] Bullish and bearish divergence are tracked from confirmed pivot relationships
[*][b]Histogram and slope overlays:[/b] Secondary layers help gauge acceleration quality
[*][b]Top-right dashboard:[/b] State, spread, slope, histogram, depth, divergence, last shift, confirmation, and breadth are reported continuously
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the regime[/b]
Bull and bear states indicate directional momentum dominance. Twist indicates compression or unstable breadth.

[b]Step 2: Compare spread and slope[/b]
A large spread with weakening slope often indicates mature momentum. A fresh spread expansion with improving slope usually indicates earlier-cycle momentum.

[b]Step 3: Respect divergence in context[/b]
Confirmed divergence is most useful when it appears against an already stretched ribbon state.

[b]Indicator Limitations[/b]

[list]
[*]Divergence is not a reversal guarantee
[*]Twist states can persist for long periods in balanced markets
[*]Shorter settings will react faster but can become noisy
[*]The oscillator is a momentum context tool and should be combined with market structure or regime logic
[/list]

[b]Originality Statement[/b]

Tectonic Ribbon Oscillator is original in the way it assembles a twenty-strand lag-reduced ribbon, grouped spread classification, divergence validation, and dashboard reporting into one momentum framework rather than publishing a lightly modified RSI derivative.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Momentum and divergence signals can fail, especially during high-volatility structural breaks. Use independent analysis and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Tectonic Ribbon Oscillator [JOAT]", shorttitle="TRO [JOAT]", overlay=false, precision=2, max_bars_back=2000, max_labels_count=50, max_lines_count=50)
//==============================================================================
// INPUTS
//==============================================================================

groupGeometry = "Ribbon Geometry"
src           = input.source(close, "Source", group=groupGeometry)
baseLen       = input.int(8, "Base Strand Length", minval=2, maxval=100, group=groupGeometry)
stepLen       = input.int(2, "Strand Length Step", minval=1, maxval=20, group=groupGeometry)
zSmoothLen    = input.int(5, "Lag-Reduced Smooth", minval=2, maxval=20, group=groupGeometry)
twistThresh   = input.float(1.5, "Twist Threshold", minval=0.1, step=0.1, group=groupGeometry)
slopeLookback = input.int(3, "Slope Lookback", minval=1, maxval=20, group=groupGeometry)
divLeft       = input.int(3, "Divergence Pivot Left", minval=1, maxval=10, group=groupGeometry)
divRight      = input.int(3, "Divergence Pivot Right", minval=1, maxval=10, group=groupGeometry)
histLen       = input.int(8, "Histogram Cycle", minval=2, maxval=50, group=groupGeometry)
divHoldBars   = input.int(12, "Divergence Hold Bars", minval=1, maxval=50, group=groupGeometry)

groupVisual = "Visual Design"
showBackdrop   = input.bool(true, "Show Regime Backdrop", group=groupVisual)
showRibbonFill = input.bool(true, "Show Ribbon Fill", group=groupVisual)
showHistogram  = input.bool(true, "Show Histogram", group=groupVisual)
showSlope      = input.bool(true, "Show Slope Line", group=groupVisual)
showGuides     = input.bool(true, "Show Twist Guides", group=groupVisual)
showDash       = input.bool(true, "Show Dashboard", group=groupVisual)

groupTheme = "Palette"
bullColorIn   = input.color(#00e5ff, "Bull Core", group=groupTheme)
bearColorIn   = input.color(#ff4d6d, "Bear Core", group=groupTheme)
neutralColorIn = input.color(#76839b, "Neutral Core", group=groupTheme)
accentColorIn  = input.color(#ffd166, "Accent Core", group=groupTheme)
panelColorIn   = input.color(#0b1220, "Panel Base", group=groupTheme)
gridColorIn    = input.color(#1a2538, "Grid Base", group=groupTheme)

//==============================================================================
// THEME CONSTANTS
//==============================================================================

bullCore    = bullColorIn
bearCore    = bearColorIn
neutralCore = neutralColorIn
accentCore  = accentColorIn
panelCore   = panelColorIn
gridCore    = gridColorIn
textCore    = color.new(color.white, 0)
softText    = color.new(color.white, 25)
softGrid    = color.new(gridCore, 55)

//==============================================================================
// HELPER FUNCTIONS
//==============================================================================

f_clamp(float value, float lo, float hi) =>
    math.max(lo, math.min(hi, value))

f_safe_div(float num, float den) =>
    den == 0.0 ? 0.0 : num / den

f_intensity_alpha(float strength, int baseAlpha, int depth) =>
    int alpha = int(math.round(baseAlpha - strength * 35.0 + depth * 2.0))
    math.max(0, math.min(95, alpha))

f_zlema(float value, int len) =>
    int lag = math.max(1, int(math.floor((len - 1) / 2.0)))
    float lagged = nz(value[lag], value)
    ta.ema(value + (value - lagged), len)

f_strand_value(float priceSrc, int len, int smoothLen) =>
    float rawRsi = ta.rsi(priceSrc, len)
    float centered = rawRsi - 50.0
    f_zlema(centered, smoothLen)

f_bi_gradient_color(float value, int depth, color bullCol, color bearCol, color neutralCol) =>
    float clipped = f_clamp(value, -50.0, 50.0)
    color core = clipped >= 0.0 ?
         color.from_gradient(clipped, 0.0, 50.0, neutralCol, bullCol) :
         color.from_gradient(math.abs(clipped), 0.0, 50.0, neutralCol, bearCol)
    int alpha = f_intensity_alpha(math.abs(clipped) / 50.0, 18 + depth * 2, depth)
    color.new(core, alpha)

f_regime_text(int regime) =>
    regime == 1 ? "BULL" : regime == -1 ? "BEAR" : "TWIST"

f_regime_color(int regime) =>
    regime == 1 ? bullCore : regime == -1 ? bearCore : neutralCore

f_state_blend(int regime, float intensity) =>
    color base = f_regime_color(regime)
    int alpha = int(math.round(90.0 - f_clamp(intensity, 0.0, 1.0) * 40.0))
    color.new(base, math.max(8, math.min(95, alpha)))

f_recent_text(bool bullDiv, bool bearDiv) =>
    bullDiv ? "BULL DIV" : bearDiv ? "BEAR DIV" : "NONE"

f_recent_color(bool bullDiv, bool bearDiv) =>
    bullDiv ? bullCore : bearDiv ? bearCore : neutralCore

//==============================================================================
// RIBBON STRANDS
//------------------------------------------------------------------------------
// Twenty strands provide the breadth structure. The strand values are centered
// around zero so that the oscillator reads like a true momentum field instead of
// a retail RSI copy.
//==============================================================================

len01 = baseLen + stepLen * 0
len02 = baseLen + stepLen * 1
len03 = baseLen + stepLen * 2
len04 = baseLen + stepLen * 3
len05 = baseLen + stepLen * 4
len06 = baseLen + stepLen * 5
len07 = baseLen + stepLen * 6
len08 = baseLen + stepLen * 7
len09 = baseLen + stepLen * 8
len10 = baseLen + stepLen * 9
len11 = baseLen + stepLen * 10
len12 = baseLen + stepLen * 11
len13 = baseLen + stepLen * 12
len14 = baseLen + stepLen * 13
len15 = baseLen + stepLen * 14
len16 = baseLen + stepLen * 15
len17 = baseLen + stepLen * 16
len18 = baseLen + stepLen * 17
len19 = baseLen + stepLen * 18
len20 = baseLen + stepLen * 19

s01 = f_strand_value(src, len01, zSmoothLen)
s02 = f_strand_value(src, len02, zSmoothLen)
s03 = f_strand_value(src, len03, zSmoothLen)
s04 = f_strand_value(src, len04, zSmoothLen)
s05 = f_strand_value(src, len05, zSmoothLen)
s06 = f_strand_value(src, len06, zSmoothLen)
s07 = f_strand_value(src, len07, zSmoothLen)
s08 = f_strand_value(src, len08, zSmoothLen)
s09 = f_strand_value(src, len09, zSmoothLen)
s10 = f_strand_value(src, len10, zSmoothLen)
s11 = f_strand_value(src, len11, zSmoothLen)
s12 = f_strand_value(src, len12, zSmoothLen)
s13 = f_strand_value(src, len13, zSmoothLen)
s14 = f_strand_value(src, len14, zSmoothLen)
s15 = f_strand_value(src, len15, zSmoothLen)
s16 = f_strand_value(src, len16, zSmoothLen)
s17 = f_strand_value(src, len17, zSmoothLen)
s18 = f_strand_value(src, len18, zSmoothLen)
s19 = f_strand_value(src, len19, zSmoothLen)
s20 = f_strand_value(src, len20, zSmoothLen)

//==============================================================================
// CORE RIBBON AVERAGES
//==============================================================================

fastAvg = (s01 + s02 + s03 + s04 + s05) / 5.0
midAvg  = (s06 + s07 + s08 + s09 + s10) / 5.0
slowAvg = (s11 + s12 + s13 + s14 + s15 + s16 + s17 + s18 + s19 + s20) / 10.0

ribbonCore = (fastAvg * 0.50) + (midAvg * 0.30) + (slowAvg * 0.20)
ribbonSpread = fastAvg - slowAvg
ribbonMidSpread = fastAvg - midAvg
ribbonDepthRaw = math.max(math.abs(ribbonSpread), math.max(math.abs(ribbonMidSpread), math.abs(midAvg - slowAvg)))
ribbonDepth = f_clamp(ribbonDepthRaw / (twistThresh * 6.0), 0.0, 1.0)

fastSlope = fastAvg - nz(fastAvg[slopeLookback], fastAvg)
coreSlope = ribbonCore - nz(ribbonCore[slopeLookback], ribbonCore)
slowSlope = slowAvg - nz(slowAvg[slopeLookback], slowAvg)

fastSlopeDev = ta.stdev(fastSlope, math.max(5, slopeLookback * 4))
coreSlopeDev = ta.stdev(coreSlope, math.max(5, slopeLookback * 4))
slowSlopeDev = ta.stdev(slowSlope, math.max(5, slopeLookback * 4))

fastSlopeZ = f_safe_div(fastSlope, fastSlopeDev + 0.0001)
coreSlopeZ = f_safe_div(coreSlope, coreSlopeDev + 0.0001)
slowSlopeZ = f_safe_div(slowSlope, slowSlopeDev + 0.0001)

fastImpulse = ta.ema(ribbonSpread, histLen)
slowImpulse = ribbonSpread - ta.ema(ribbonSpread, histLen * 2)
histogramRaw = fastImpulse + slowImpulse
histDev = ta.stdev(histogramRaw, math.max(8, histLen * 3))
histogramZ = f_safe_div(histogramRaw, histDev + 0.0001)

pressureRaw = (ribbonSpread * 0.55) + (coreSlope * 0.30) + (histogramRaw * 0.15)
pressureDev = ta.stdev(pressureRaw, math.max(10, histLen * 3))
pressureZ = f_safe_div(pressureRaw, pressureDev + 0.0001)
pressureScore = f_clamp(pressureZ * 20.0, -100.0, 100.0)

//==============================================================================
// REGIME ENGINE
//------------------------------------------------------------------------------
// Regime logic is intentionally simple and bar-safe:
// - Bull: fast ribbon is above the slower ribbon stack and spread exceeds twist
// - Bear: fast ribbon is below the slower ribbon stack and spread is negative
// - Twist: compression / indecision around the center field
//==============================================================================

bullStructure = fastAvg > midAvg and midAvg > slowAvg
bearStructure = fastAvg < midAvg and midAvg < slowAvg
twistState    = math.abs(ribbonSpread) <= twistThresh

bullMomentum = ribbonSpread > twistThresh and coreSlopeZ > 0.20 and pressureScore > 10.0
bearMomentum = ribbonSpread < -twistThresh and coreSlopeZ < -0.20 and pressureScore < -10.0

liveRegime = bullMomentum and bullStructure ? 1 :
     bearMomentum and bearStructure ? -1 :
     twistState ? 0 :
     pressureScore > 0 ? 1 : -1

regimeIntensity = f_clamp(math.abs(pressureScore) / 100.0, 0.0, 1.0)
regimeColor = f_state_blend(liveRegime, regimeIntensity)

confirmedBullShift = barstate.isconfirmed and liveRegime == 1 and nz(liveRegime[1], 0) != 1
confirmedBearShift = barstate.isconfirmed and liveRegime == -1 and nz(liveRegime[1], 0) != -1
confirmedTwistShift = barstate.isconfirmed and liveRegime == 0 and nz(liveRegime[1], 0) != 0

//==============================================================================
// DIVERGENCE ENGINE
//------------------------------------------------------------------------------
// Divergence is evaluated against the ribbon core, not raw RSI. That keeps the
// detection tied to the actual JOAT momentum field.
//==============================================================================

pricePivotLow  = ta.pivotlow(low, divLeft, divRight)
pricePivotHigh = ta.pivothigh(high, divLeft, divRight)
corePivotLow   = ta.pivotlow(ribbonCore, divLeft, divRight)
corePivotHigh  = ta.pivothigh(ribbonCore, divLeft, divRight)

var float prevPriceLow = na
var float prevCoreLow = na
var float prevPriceHigh = na
var float prevCoreHigh = na
var int bullDivBar = na
var int bearDivBar = na

bullDivRaw = false
bearDivRaw = false

if not na(pricePivotLow) and not na(corePivotLow)
    bullDivRaw := not na(prevPriceLow) and pricePivotLow < prevPriceLow and corePivotLow > prevCoreLow
    if bullDivRaw
        bullDivBar := bar_index - divRight
    prevPriceLow := pricePivotLow
    prevCoreLow := corePivotLow

if not na(pricePivotHigh) and not na(corePivotHigh)
    bearDivRaw := not na(prevPriceHigh) and pricePivotHigh > prevPriceHigh and corePivotHigh < prevCoreHigh
    if bearDivRaw
        bearDivBar := bar_index - divRight
    prevPriceHigh := pricePivotHigh
    prevCoreHigh := corePivotHigh

bullDivRecent = not na(bullDivBar) and (bar_index - bullDivBar) <= divHoldBars
bearDivRecent = not na(bearDivBar) and (bar_index - bearDivBar) <= divHoldBars

confirmedBullDiv = barstate.isconfirmed and bullDivRaw
confirmedBearDiv = barstate.isconfirmed and bearDivRaw

//==============================================================================
// DERIVED VISUAL METRICS
//==============================================================================

spreadNorm = f_clamp(ribbonSpread / (twistThresh * 4.0), -1.0, 1.0)
slopeNorm  = f_clamp(coreSlopeZ / 3.0, -1.0, 1.0)
histNorm   = f_clamp(histogramZ / 3.0, -1.0, 1.0)

histPlot = histogramRaw * 1.5
slopePlot = coreSlope * 6.0

histColor = histogramRaw >= 0.0 ?
     color.new(color.from_gradient(f_clamp(histNorm, 0.0, 1.0), 0.0, 1.0, color.new(neutralCore, 0), bullCore), 35) :
     color.new(color.from_gradient(f_clamp(math.abs(histNorm), 0.0, 1.0), 0.0, 1.0, color.new(neutralCore, 0), bearCore), 35)

slopeColor = coreSlope >= 0.0 ?
     color.new(color.from_gradient(f_clamp(slopeNorm, 0.0, 1.0), 0.0, 1.0, neutralCore, bullCore), 15) :
     color.new(color.from_gradient(f_clamp(math.abs(slopeNorm), 0.0, 1.0), 0.0, 1.0, neutralCore, bearCore), 15)

fillColor = liveRegime == 1 ?
     color.new(color.from_gradient(ribbonDepth, 0.0, 1.0, color.new(bullCore, 90), bullCore), 84) :
     liveRegime == -1 ?
     color.new(color.from_gradient(ribbonDepth, 0.0, 1.0, color.new(bearCore, 90), bearCore), 84) :
     color.new(neutralCore, 90)

color backdropColor = na
if showBackdrop
    backdropColor := liveRegime == 1 ? color.new(bullCore, 93) :
         liveRegime == -1 ? color.new(bearCore, 93) :
         color.new(neutralCore, 94)
    if bullDivRecent or bearDivRecent
        backdropColor := color.new(accentCore, 93)

//==============================================================================
// RENDERING
//==============================================================================

plot(0, "Zero", color=color.new(softText, 72), linewidth=1)
upperGuide = plot(showGuides ? twistThresh : na, "Upper Twist", color=color.new(accentCore, 82), linewidth=1)
lowerGuide = plot(showGuides ? -twistThresh : na, "Lower Twist", color=color.new(accentCore, 82), linewidth=1)
fill(upperGuide, lowerGuide, color=color.new(accentCore, 95), title="Twist Band")

plot(s01, "Stratum 01", color=f_bi_gradient_color(s01, 1, bullCore, bearCore, neutralCore), linewidth=1)
plot(s02, "Stratum 02", color=f_bi_gradient_color(s02, 2, bullCore, bearCore, neutralCore), linewidth=1)
plot(s03, "Stratum 03", color=f_bi_gradient_color(s03, 3, bullCore, bearCore, neutralCore), linewidth=1)
plot(s04, "Stratum 04", color=f_bi_gradient_color(s04, 4, bullCore, bearCore, neutralCore), linewidth=1)
plot(s05, "Stratum 05", color=f_bi_gradient_color(s05, 5, bullCore, bearCore, neutralCore), linewidth=1)
plot(s06, "Stratum 06", color=f_bi_gradient_color(s06, 6, bullCore, bearCore, neutralCore), linewidth=1)
plot(s07, "Stratum 07", color=f_bi_gradient_color(s07, 7, bullCore, bearCore, neutralCore), linewidth=1)
plot(s08, "Stratum 08", color=f_bi_gradient_color(s08, 8, bullCore, bearCore, neutralCore), linewidth=1)
plot(s09, "Stratum 09", color=f_bi_gradient_color(s09, 9, bullCore, bearCore, neutralCore), linewidth=1)
plot(s10, "Stratum 10", color=f_bi_gradient_color(s10, 10, bullCore, bearCore, neutralCore), linewidth=1)
plot(s11, "Stratum 11", color=f_bi_gradient_color(s11, 11, bullCore, bearCore, neutralCore), linewidth=1)
plot(s12, "Stratum 12", color=f_bi_gradient_color(s12, 12, bullCore, bearCore, neutralCore), linewidth=1)
plot(s13, "Stratum 13", color=f_bi_gradient_color(s13, 13, bullCore, bearCore, neutralCore), linewidth=1)
plot(s14, "Stratum 14", color=f_bi_gradient_color(s14, 14, bullCore, bearCore, neutralCore), linewidth=1)
plot(s15, "Stratum 15", color=f_bi_gradient_color(s15, 15, bullCore, bearCore, neutralCore), linewidth=1)
plot(s16, "Stratum 16", color=f_bi_gradient_color(s16, 16, bullCore, bearCore, neutralCore), linewidth=1)
plot(s17, "Stratum 17", color=f_bi_gradient_color(s17, 17, bullCore, bearCore, neutralCore), linewidth=1)
plot(s18, "Stratum 18", color=f_bi_gradient_color(s18, 18, bullCore, bearCore, neutralCore), linewidth=1)
plot(s19, "Stratum 19", color=f_bi_gradient_color(s19, 19, bullCore, bearCore, neutralCore), linewidth=1)
plot(s20, "Stratum 20", color=f_bi_gradient_color(s20, 20, bullCore, bearCore, neutralCore), linewidth=1)

pFast = plot(fastAvg, "Fast Core", color=color.new(bullCore, 0), linewidth=2)
pMid  = plot(midAvg, "Mid Core", color=color.new(accentCore, 25), linewidth=2)
pSlow = plot(slowAvg, "Slow Core", color=color.new(bearCore, 0), linewidth=2)

fill(pFast, pSlow, color=showRibbonFill ? fillColor : na, title="Ribbon Envelope")
fill(pFast, pMid, color=showRibbonFill ? color.new(liveRegime == 1 ? bullCore : liveRegime == -1 ? bearCore : neutralCore, 88) : na, title="Fast-Mid Blend")

plot(showHistogram ? histPlot : na, "Momentum Histogram", color=histColor, style=plot.style_columns, linewidth=2)
plot(showSlope ? slopePlot : na, "Slope Pressure", color=slopeColor, style=plot.style_line, linewidth=2)

bgcolor(backdropColor, title="Tectonic Backdrop")

//==============================================================================
// STATE MESSAGES
//------------------------------------------------------------------------------
// Confirmed state changes only. No retail arrows, no clutter markers.
//==============================================================================

var string lastShiftText = "NONE"
var int lastShiftBar = na
var color lastShiftColor = neutralCore

if barstate.isconfirmed
    if confirmedBullShift
        lastShiftText := "BULL SHIFT"
        lastShiftBar := bar_index
        lastShiftColor := bullCore
    else if confirmedBearShift
        lastShiftText := "BEAR SHIFT"
        lastShiftBar := bar_index
        lastShiftColor := bearCore
    else if confirmedTwistShift
        lastShiftText := "TWIST RESET"
        lastShiftBar := bar_index
        lastShiftColor := accentCore

barsSinceShift = na(lastShiftBar) ? na : bar_index - lastShiftBar

//==============================================================================
// DASHBOARD
//------------------------------------------------------------------------------
// Medium-sized top-right summary for at-a-glance regime reading.
//==============================================================================

var table troDash = table.new(position.top_right, 2, 10, bgcolor=color.new(panelCore, 6), border_width=1, border_color=color.new(gridCore, 25), frame_width=1, frame_color=color.new(gridCore, 35))

if showDash and barstate.islast
    table.merge_cells(troDash, 0, 0, 1, 0)
    table.cell(troDash, 0, 0, "TECTONIC RIBBON | JOAT", bgcolor=color.new(gridCore, 20), text_color=textCore, text_size=size.small, text_halign=text.align_center)

    table.cell(troDash, 0, 1, "STATE", bgcolor=color.new(panelCore, 0), text_color=softText, text_size=size.small)
    table.cell(troDash, 1, 1, f_regime_text(liveRegime) + "  |  " + str.tostring(pressureScore, "#.0"), bgcolor=color.new(f_regime_color(liveRegime), 82), text_color=f_regime_color(liveRegime), text_size=size.small, text_halign=text.align_center)

    table.cell(troDash, 0, 2, "SPREAD", bgcolor=color.new(panelCore, 0), text_color=softText, text_size=size.small)
    table.cell(troDash, 1, 2, str.tostring(ribbonSpread, "#.00"), bgcolor=color.new(regimeColor, 90), text_color=textCore, text_size=size.small, text_halign=text.align_center)

    table.cell(troDash, 0, 3, "SLOPE", bgcolor=color.new(panelCore, 0), text_color=softText, text_size=size.small)
    table.cell(troDash, 1, 3, str.tostring(coreSlope, "#.00") + "  |  " + str.tostring(coreSlopeZ, "#.00") + "z", bgcolor=color.new(slopeColor, 85), text_color=textCore, text_size=size.small, text_halign=text.align_center)

    table.cell(troDash, 0, 4, "HISTOGRAM", bgcolor=color.new(panelCore, 0), text_color=softText, text_size=size.small)
    table.cell(troDash, 1, 4, str.tostring(histogramRaw, "#.00") + "  |  " + str.tostring(histogramZ, "#.00") + "z", bgcolor=color.new(histColor, 85), text_color=textCore, text_size=size.small, text_halign=text.align_center)

    table.cell(troDash, 0, 5, "DEPTH", bgcolor=color.new(panelCore, 0), text_color=softText, text_size=size.small)
    table.cell(troDash, 1, 5, str.tostring(ribbonDepth * 100.0, "#.0") + "%", bgcolor=color.new(accentCore, 90), text_color=accentCore, text_size=size.small, text_halign=text.align_center)

    table.cell(troDash, 0, 6, "DIVERGENCE", bgcolor=color.new(panelCore, 0), text_color=softText, text_size=size.small)
    table.cell(troDash, 1, 6, f_recent_text(bullDivRecent, bearDivRecent), bgcolor=color.new(f_recent_color(bullDivRecent, bearDivRecent), 88), text_color=f_recent_color(bullDivRecent, bearDivRecent), text_size=size.small, text_halign=text.align_center)

    table.cell(troDash, 0, 7, "LAST SHIFT", bgcolor=color.new(panelCore, 0), text_color=softText, text_size=size.small)
    table.cell(troDash, 1, 7, lastShiftText + (na(barsSinceShift) ? "" : "  |  " + str.tostring(barsSinceShift)), bgcolor=color.new(lastShiftColor, 86), text_color=lastShiftColor, text_size=size.small, text_halign=text.align_center)

    table.cell(troDash, 0, 8, "CONFIRMED", bgcolor=color.new(panelCore, 0), text_color=softText, text_size=size.small)
    table.cell(troDash, 1, 8, barstate.isconfirmed ? "YES" : "LIVE", bgcolor=color.new(barstate.isconfirmed ? bullCore : accentCore, 90), text_color=barstate.isconfirmed ? bullCore : accentCore, text_size=size.small, text_halign=text.align_center)

    table.cell(troDash, 0, 9, "BREADTH", bgcolor=color.new(panelCore, 0), text_color=softText, text_size=size.small)
    table.cell(troDash, 1, 9, str.tostring(fastAvg, "#.00") + " / " + str.tostring(midAvg, "#.00") + " / " + str.tostring(slowAvg, "#.00"), bgcolor=color.new(neutralCore, 90), text_color=textCore, text_size=size.small, text_halign=text.align_center)

//==============================================================================
// ALERTS
//------------------------------------------------------------------------------
// Alerts only fire on confirmed bars when the regime actually changes.
//==============================================================================

alertcondition(confirmedBullShift, title="Bullish Regime Shift", message="Tectonic Ribbon Oscillator: bullish regime confirmed on {{ticker}} {{interval}}")
alertcondition(confirmedBearShift, title="Bearish Regime Shift", message="Tectonic Ribbon Oscillator: bearish regime confirmed on {{ticker}} {{interval}}")
alertcondition(confirmedTwistShift, title="Twist Regime Shift", message="Tectonic Ribbon Oscillator: twist regime confirmed on {{ticker}} {{interval}}")
alertcondition(confirmedBullDiv, title="Bullish Divergence", message="Tectonic Ribbon Oscillator: bullish divergence confirmed on {{ticker}} {{interval}}")
alertcondition(confirmedBearDiv, title="Bearish Divergence", message="Tectonic Ribbon Oscillator: bearish divergence confirmed on {{ticker}} {{interval}}")

//==============================================================================
// END
//==============================================================================
````
