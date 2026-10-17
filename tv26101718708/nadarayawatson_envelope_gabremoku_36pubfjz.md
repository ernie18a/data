# Nadaraya-Watson Envelope [Gabremoku]

- url: https://www.tradingview.com/script/36PUbfjz-Nadaraya-Watson-Envelope-Gabremoku/
- type: indicator
- pine_id: PUB;7de60d64068a40a7bc7deb91514499ab
- version: 1.0

## Description

Nadaraya-Watson Envelope [Gabremoku]

This indicator builds a non-repainting Nadaraya-Watson envelope using a one-sided Gaussian kernel, so every value is computed from the current bar and past bars only. The goal is to provide a smoother adaptive baseline than a standard moving average while keeping the script operationally honest and suitable for live use.

What makes this script different:
- The central basis is a kernel-weighted Nadaraya-Watson estimate, not a classic SMA/EMA baseline.
- The main envelope is not built from standard deviation by default. It uses kernel-weighted mean absolute deviation (MAD), which is generally less sensitive to single-bar outliers and often produces a more stable channel.
- Standard deviation bands can still be enabled as an optional overlay, so users can compare MAD-based and Stdev-based dispersion around the same kernel basis.
- Signal logic is configurable. Breakout labels can be triggered by close crossing the band, wick piercing the band, or full body breakout, which makes the visual behavior easier to align with the trader’s interpretation.

How it works:
The script applies Gaussian weights to past bars inside the selected window. More recent bars receive the highest weight, while older bars progressively contribute less. The Bandwidth input controls how fast those weights decay. In practice, the effective lookback is usually much shorter than the full Window setting when Bandwidth is low. A practical rule of thumb is that the effective lookback is about 3 × Bandwidth bars, capped by the Window value.

The indicator computes:
1. A kernel-weighted mean, used as the Nadaraya-Watson basis.
2. A kernel-weighted MAD, used as the primary envelope width.
3. An optional kernel-weighted standard deviation, displayed only when the comparison bands are enabled.

The upper and lower MAD bands are then filled with a gradient that increases in strength as price moves away from the basis toward the envelope edges. This makes the visual intensity reflect displacement magnitude, not just bullish or bearish direction.

Compression logic:
The compression zone is based on min-max normalization of envelope width over a lookback period. This is not a statistical percentile rank. A threshold of 0.15 means the current envelope width is near the lower end of the observed width range over the selected compression lookback.

Signal modes:
- Close Cross: triggers only when the close crosses a band.
- Wick Pierce: triggers when the candle’s high or low exceeds a band.
- Body Breakout: triggers when the candle body exceeds a band.

Use Wick Pierce if you want signal labels to match the visible moment where candles extend outside the envelope.

How to use it:
- Use the basis as an adaptive trend reference.
- Use the MAD envelope to judge whether price is stretched relative to recent kernel-weighted behavior.
- Watch compression zones for narrow-range conditions that may precede expansion.
- Compare MAD and Stdev bands when you want to evaluate whether recent volatility is dominated by isolated spikes or by broader dispersion.

Practical notes:
- This script is non-repainting by construction because it does not use centered calculations or future bars.
- Low Bandwidth values create a more reactive basis and shorter effective memory.
- High Bandwidth values create a smoother basis and wider historical influence.
- Increasing Window far beyond roughly 3 × Bandwidth usually has little additional effect.
- Signal labels are state-machine filtered, so they are designed to mark sequence transitions rather than every repeated touch outside the bands.

This indicator is intended as a visual decision-support tool, not as a standalone trading system. It helps traders study adaptive trend, envelope displacement, compression, and breakout structure in a cleaner way than a standard volatility channel.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Gabremoku

//@version=6
// Nadaraya-Watson Envelope Gradient [Gabremoku] — v2.0

// What it does / what it's for:
// - Plots a one-sided non-repainting Nadaraya-Watson basis.
// - Builds a coherent dynamic envelope using the same kernel-weighted local dispersion (MAD).
// - Fills Upper/Basis and Basis/Lower with a magnitude-based gradient.
// - Adds optional bar coloring, breakout signals, dashboard, and last-value labels.
// - Optionally overlays kernel-weighted Stdev bands for comparison with MAD bands.
//
// Important calculation note:
// - This script uses only current and past bars (one-sided kernel). Non-repainting guaranteed.
// - It prioritizes operational correctness over centered visual smoothing.
//
// Parameter interaction note:
// - "Kernel Window" sets the maximum lookback in bars.
// - "Kernel Bandwidth" controls how fast Gaussian weights decay with lag distance.
//   Weight at lag i = exp(-i² / 2h²). With low bandwidth relative to window,
//   far bars contribute near-zero weight and the effective lookback is much shorter
//   than the Window setting. Effective lookback ≈ 3 × bandwidth bars.
//   Increasing Window beyond ~3×bandwidth has negligible effect.
//
// Signal note:
// - Signal triggers can be based on Close Cross, Wick Pierce, or Body Breakout.
// - Use Wick Pierce if you want labels to appear where candles visibly exceed the bands.
//
// Compression note:
// - Compression zone uses min-max linear normalization over the lookback window,
//   NOT a statistical percentile. Threshold 0.15 = bottom 15% of the observed range.

indicator("Nadaraya-Watson Envelope [Gabremoku]", overlay=true, max_labels_count=500)


// ═══════════════════════════════════════════════════════════════
//  Nadaraya-Watson Envelope Gradient [Gabremoku] v2.0
//  Non-repainting kernel basis + coherent local dispersion
//  Bull = Blue | Bear = Yellow
// ═══════════════════════════════════════════════════════════════


// ── INPUTS ─────────────────────────────────────────────────────
grp6 = "🧭 Strategy Mode"
strategySide = input.string("Long", "Strategy Side", options=["Long", "Short"], group=grp6)
signalMode   = input.string("Wick Pierce", "Signal Trigger",
     options=["Close Cross", "Wick Pierce", "Body Breakout"], group=grp6)

grp0 = "⚙️ Core"
src       = input.source(close, "Source", group=grp0)
window    = input.int(60, "Kernel Window (max bars)", group=grp0, minval=3, maxval=500,
     tooltip="Maximum lookback in bars. With low Bandwidth, far bars have near-zero weight and the effective lookback is shorter than this value. Values beyond ~3×Bandwidth have negligible effect.")
bandwidth = input.float(10.0, "Kernel Bandwidth", group=grp0, minval=0.5, step=0.5,
     tooltip="Controls Gaussian weight decay: weight at lag i = exp(-i²/2h²). Low bandwidth = sharp local focus, high bandwidth = wider smoothing. Effective lookback ≈ 3×bandwidth bars.")
envMult     = input.float(2.0, "Envelope Multiplier", group=grp0, minval=0.1, step=0.1)
minBarsMode = input.bool(true, "Allow Early Bars Calculation", group=grp0)
showStdev   = input.bool(false, "Show Stdev Bands", group=grp0,
     tooltip="Overlays additional bands using kernel-weighted standard deviation instead of MAD. Useful to compare the two dispersion measures side by side.")

grp1 = "🎨 Colors"
bullColor     = input.color(color.rgb(33, 150, 243),  "Bullish Color (Blue)",   group=grp1)
bearColor     = input.color(color.rgb(241, 255, 48),  "Bearish Color (Yellow)", group=grp1)
compressColor = input.color(color.rgb(156, 39, 176),  "Compression Color",      group=grp1)
neutralColor  = input.color(color.gray,               "Neutral Basis Color",    group=grp1)

grp2 = "📐 Style"
showBasis     = input.bool(true,  "Show Basis",               group=grp2)
showBandLines = input.bool(true,  "Show Upper/Lower Bands",   group=grp2)
showBarColors = input.bool(true,  "Color Bars",               group=grp2)
showSignals   = input.bool(true,  "Show Signals",             group=grp2)
showLabels    = input.bool(true,  "Show Last Value Labels",   group=grp2)
basisWidth    = input.int(2,      "Basis Width",              group=grp2, minval=1, maxval=5)
bandsWidth    = input.int(1,      "Band Width",               group=grp2, minval=1, maxval=5)

grp3 = "🌈 Gradient Logic"
neutralZonePct = input.float(0.10, "Neutral Zone %",           group=grp3, minval=0.0, maxval=1.0,  step=0.01)
fillAggressive = input.float(1.60, "Fill Aggressiveness",      group=grp3, minval=0.5, maxval=4.0,  step=0.1)
fillTransNear  = input.int(92,     "Fill Transp. Near Basis",  group=grp3, minval=0,   maxval=100,
     tooltip="Transparency of the fill close to the basis (0=opaque, 100=invisible). High value = subtle fill near center.")
fillTransFar   = input.int(20,     "Fill Transp. Far Basis",   group=grp3, minval=0,   maxval=100,
     tooltip="Transparency of the fill near the bands (0=opaque, 100=invisible). Low value = strong fill near the edges.")

grp4 = "🗜️ Compression"
cmpLookback    = input.int(100,  "Compression Lookback",              group=grp4, minval=10)
cmpThreshold   = input.float(0.15, "Compression Zone Threshold (0–1)", group=grp4,
     minval=0.01, maxval=0.50, step=0.01,
     tooltip="Min-max normalized envelope width over the lookback. 0 = narrowest ever seen, 1 = widest. This is NOT a statistical percentile — it uses linear rescaling between historical min and max width.")
highlightCmpBg = input.bool(false, "Highlight Compression Background", group=grp4)

grp5 = "🪧 Dashboard"
showDashboard = input.bool(true, "Show Dashboard", group=grp5)


// ── FUNCTIONS ──────────────────────────────────────────────────
clamp(_x, _min, _max) =>
    math.max(_min, math.min(_max, _x))

gaussWeight(_i, _h) =>
    math.exp(-(_i * _i) / (2.0 * _h * _h))

// Returns: [basis, MAD, stdev, effectiveBars]
// - basis : kernel-weighted mean
// - MAD   : kernel-weighted mean absolute deviation (robust, used for envelope)
// - stdev : kernel-weighted standard deviation (optional, for comparison)
// - effectiveBars: actual bars included in computation
nwStats(_src, _window, _h, _allowEarlyBars) =>
    // Early exit if not enough bars and early calculation is disabled
    // barsBack is intentionally NOT computed here to avoid wasted work
    if not _allowEarlyBars and bar_index < _window - 1
        [na, na, na, 0]
    else
        // Computed only when we actually enter the calculation
        int barsBack = _allowEarlyBars ? math.min(_window - 1, bar_index) : _window - 1

        float sumW  = 0.0
        float sumWX = 0.0

        for i = 0 to barsBack
            float w  = gaussWeight(i, _h)
            sumW  += w
            sumWX += _src[i] * w

        float basis_ = sumW != 0.0 ? sumWX / sumW : na

        float sumAbs = 0.0
        float sumVar = 0.0

        for i = 0 to barsBack
            float w = gaussWeight(i, _h)
            float d = _src[i] - basis_
            sumAbs += math.abs(d) * w
            sumVar += d * d * w

        float mad_   = sumW != 0.0 ? sumAbs / sumW : na
        float stdev_ = sumW != 0.0 ? math.sqrt(math.max(sumVar / sumW, 0.0)) : na

        [basis_, mad_, stdev_, barsBack + 1]

crossAbove(_mode, _upper) =>
    _mode == "Close Cross"   ? ta.crossover(close, _upper)   :    _mode == "Wick Pierce"   ? (high > _upper and high[1] <= _upper[1])                                          :
                               (math.max(open, close) > _upper and math.max(open[1], close[1]) <= _upper[1])

crossBelow(_mode, _lower) =>
    _mode == "Close Cross"   ? ta.crossunder(close, _lower)         :  _mode == "Wick Pierce"   ? (low < _lower and low[1] >= _lower[1])                                            :
                               (math.min(open, close) < _lower and math.min(open[1], close[1]) >= _lower[1])


// ── NADARAYA-WATSON CORE ───────────────────────────────────────
[basis, localMAD, localStdev, effBars] = nwStats(src, window, bandwidth, minBarsMode)

// MAD-based envelope (primary — robust to outliers)
envHalfWidth = localMAD * envMult
upper        = basis + envHalfWidth
lower        = basis - envHalfWidth

// Stdev-based envelope (optional — for comparison)
stdevUpper = basis + localStdev * envMult
stdevLower = basis - localStdev * envMult

envWidthAbs  = upper - lower
envWidthPct  = basis != 0.0 ? (envWidthAbs / basis) * 100.0 : 0.0

nwPos        = envHalfWidth != 0.0 ? (src - basis) / envHalfWidth : 0.0
nwPosClamped = clamp(nwPos, -2.0, 2.0)

// Effective lookback driven by bandwidth (rule of thumb: 3×bandwidth)
effLookback  = math.min(math.round(3.0 * bandwidth), window)


// ── COMPRESSION LOGIC ──────────────────────────────────────────
// widthNorm: linear min-max rescaling in [0..1] over cmpLookback bars.
// 0 = narrowest envelope ever observed in the window; 1 = widest.
// NOT a statistical percentile distribution.
widthMin      = ta.lowest(envWidthAbs, cmpLookback)
widthMax      = ta.highest(envWidthAbs, cmpLookback)
widthNorm     = widthMax != widthMin ? (envWidthAbs - widthMin) / (widthMax - widthMin) : 0.0
isCompression = widthNorm <= cmpThreshold


// ── STATE ──────────────────────────────────────────────────────
state =
     na(basis)      ? "Waiting Data"  :
     close > upper  ? "Bull Breakout" :
     close < lower  ? "Bear Breakout" :
     close > basis  ? "Bullish"       :
     close < basis  ? "Bearish"       : "Neutral"

stateCol =
     na(basis)      ? chart.fg_color              :
     close > upper  ? bullColor                   :
     close < lower  ? bearColor                   :
     close > basis  ? color.new(bullColor,  0)    :
     close < basis  ? color.new(bearColor,  0)    : neutralColor


// ── BASIS COLOR GRADIENT ───────────────────────────────────────
neutralHi = neutralZonePct
neutralLo = -neutralZonePct

basisColorRaw =
     nwPosClamped >= 0
     ? color.from_gradient(nwPosClamped,  neutralHi, 1.0,  neutralColor, bullColor)
     : color.from_gradient(nwPosClamped, -1.0, neutralLo,  bearColor, neutralColor)

basisColor =
     na(basis)                                        ? chart.fg_color  :
     isCompression                                    ? compressColor   :
     math.abs(nwPosClamped) <= neutralZonePct         ? neutralColor    :
     basisColorRaw


// ── BAND COLORS ────────────────────────────────────────────────
upperColor =
     na(upper)      ? chart.fg_color :
     isCompression  ? color.new(compressColor, 5) :
     color.from_gradient(clamp(widthNorm, 0.0, 1.0), 0.0, 1.0,
         color.new(bullColor, 75), color.new(bullColor, 0))

lowerColor =
     na(lower)      ? chart.fg_color :
     isCompression  ? color.new(compressColor, 5) :
     color.from_gradient(clamp(widthNorm, 0.0, 1.0), 0.0, 1.0,
         color.new(bearColor, 75), color.new(bearColor, 0))


// ── FILL GRADIENT BY DISTANCE FROM BASIS ───────────────────────
distRaw  = math.abs(nwPosClamped)
distNorm = clamp(math.pow(clamp(distRaw, 0.0, 1.5) / 1.5, fillAggressive), 0.0, 1.0)

bullFillTop    = color.from_gradient(distNorm, 0.0, 1.0,
     color.new(bullColor, fillTransNear), color.new(bullColor, fillTransFar))
bullFillBottom = color.new(color.black, 100)

bearFillTop    = color.new(color.black, 100)
bearFillBottom = color.from_gradient(distNorm, 0.0, 1.0,
     color.new(bearColor, fillTransNear), color.new(bearColor, fillTransFar))


// ── RAW SIGNAL CONDITIONS ──────────────────────────────────────
rawLongEntry  = not na(upper) and crossAbove(signalMode, upper)
rawLongExit   = not na(lower) and crossBelow(signalMode, lower)

rawShortEntry = not na(lower) and crossBelow(signalMode, lower)
rawShortExit  = not na(upper) and crossAbove(signalMode, upper)


// ── SIGNAL STATE MACHINE ───────────────────────────────────────
var bool inLongSequence  = false
var bool inShortSequence = false

longEntrySignal  = false
longExitSignal   = false
shortEntrySignal = false
shortExitSignal  = false

if strategySide == "Long"
    longEntrySignal := rawLongEntry and not inLongSequence
    longExitSignal  := rawLongExit  and inLongSequence

    if longEntrySignal
        inLongSequence := true
    if longExitSignal
        inLongSequence := false

    inShortSequence := false

if strategySide == "Short"
    shortEntrySignal := rawShortEntry and not inShortSequence
    shortExitSignal  := rawShortExit  and inShortSequence

    if shortEntrySignal
        inShortSequence := true
    if shortExitSignal
        inShortSequence := false

    inLongSequence := false


// ── PLOTS ──────────────────────────────────────────────────────
basisPlot = plot(showBasis     ? basis : na, "NW Basis",              color=basisColor, linewidth=basisWidth)
upperPlot = plot(showBandLines ? upper : na, "Upper Envelope (MAD)",  color=upperColor, linewidth=bandsWidth)
lowerPlot = plot(showBandLines ? lower : na, "Lower Envelope (MAD)",  color=lowerColor, linewidth=bandsWidth)

// Optional Stdev bands — dashed circles to visually distinguish from MAD bands
plot(showStdev and not na(basis) ? stdevUpper : na, "Upper Stdev Band",
     color=color.new(bullColor, 55), linewidth=1, style=plot.style_circles)
plot(showStdev and not na(basis) ? stdevLower : na, "Lower Stdev Band",
     color=color.new(bearColor, 55), linewidth=1, style=plot.style_circles)

fill(upperPlot, basisPlot, color=bullFillTop,    title="Bull Fill")
fill(basisPlot, lowerPlot, color=bearFillBottom, title="Bear Fill")

bgcolor(highlightCmpBg and isCompression ? color.new(compressColor, 90) : na,
     title="Compression Background")

barcolor(
     showBarColors ?
         na(basis)      ? na :
         isCompression  ? color.new(compressColor, 40) :
         close > upper  ? color.new(bullColor, 0)      :
         close < lower  ? color.new(bearColor, 0)      :
         close > basis  ? color.new(bullColor, 65)     :
         close < basis  ? color.new(bearColor, 65)     : na
     : na)


// ── SIGNALS ────────────────────────────────────────────────────
plotshape(showSignals and longEntrySignal,  title="BUY",   text="BUY",
     style=shape.labelup,   location=location.belowbar, color=bullColor, textcolor=color.white, size=size.small)

plotshape(showSignals and longExitSignal,   title="SELL",  text="SELL",
     style=shape.labeldown, location=location.abovebar, color=bearColor, textcolor=color.black, size=size.small)

plotshape(showSignals and shortEntrySignal, title="SHORT", text="SHORT",
     style=shape.labeldown, location=location.abovebar, color=bearColor, textcolor=color.black, size=size.small)

plotshape(showSignals and shortExitSignal,  title="CLOSE", text="CLOSE",
     style=shape.labelup,   location=location.belowbar, color=bullColor, textcolor=color.white, size=size.small)


// ── ALERTS ─────────────────────────────────────────────────────
alertcondition(longEntrySignal,  "BUY Signal",   "NW Envelope: BUY — price broke above upper band")
alertcondition(longExitSignal,   "SELL Signal",  "NW Envelope: SELL — price broke below lower band")
alertcondition(shortEntrySignal, "SHORT Signal", "NW Envelope: SHORT — price broke below lower band")
alertcondition(shortExitSignal,  "CLOSE Signal", "NW Envelope: CLOSE — price broke above upper band")


// ── DASHBOARD ──────────────────────────────────────────────────
rangePos = envWidthAbs != 0.0 ? (close - lower) / envWidthAbs : 0.5
pressure = distNorm
cmpState = isCompression ? "ON" : "OFF"

seqState = strategySide == "Long"
     ? (inLongSequence  ? "Long Active"       : "Flat / Ready BUY")
     : (inShortSequence ? "Short Active"      : "Flat / Ready SHORT")

var table dash = table.new(position.bottom_right, 2, 11, border_width=1)

if barstate.islast and showDashboard
    table.cell(dash, 0, 0,  "State",        text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 0,  state,          text_color=stateCol,       text_halign=text.align_center)

    table.cell(dash, 0, 1,  "Mode",         text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 1,  strategySide,   text_color=chart.fg_color, text_halign=text.align_center)

    table.cell(dash, 0, 2,  "Trigger",      text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 2,  signalMode,     text_color=chart.fg_color, text_halign=text.align_center)

    table.cell(dash, 0, 3,  "Sequence",     text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 3,  seqState,       text_color=chart.fg_color, text_halign=text.align_center)

    table.cell(dash, 0, 4,  "Env Width",    text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 4,  str.tostring(envWidthPct, "#.##") + "%", text_color=chart.fg_color, text_halign=text.align_center)

    table.cell(dash, 0, 5,  "Range Pos",    text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 5,  str.tostring(rangePos * 100, "#") + "%", text_color=chart.fg_color, text_halign=text.align_center)

    table.cell(dash, 0, 6,  "Pressure",     text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 6,  str.tostring(pressure * 100, "#") + "%", text_color=chart.fg_color, text_halign=text.align_center)

    table.cell(dash, 0, 7,  "Compression",  text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 7,  cmpState,       text_color=isCompression ? compressColor : chart.fg_color, text_halign=text.align_center)

    table.cell(dash, 0, 8,  "Eff Bars",     text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 8,  str.tostring(effBars), text_color=chart.fg_color, text_halign=text.align_center)

    // New: shows the bandwidth-driven effective lookback (≈3×bandwidth, capped to window)
    table.cell(dash, 0, 9,  "Eff Lookback", text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 9,  "≈" + str.tostring(effLookback) + " bars", text_color=chart.fg_color, text_halign=text.align_center)

    // New: shows whether Stdev bands are active
    table.cell(dash, 0, 10, "Stdev Bands",  text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 10, showStdev ? "ON" : "OFF",
         text_color=showStdev ? color.new(bullColor, 30) : chart.fg_color, text_halign=text.align_center)


// ── LAST VALUE LABELS ──────────────────────────────────────────
var label lbUpper = na
var label lbBasis = na
var label lbLower = na

if barstate.islast and showLabels and not na(basis)
    label.delete(lbUpper)
    label.delete(lbBasis)
    label.delete(lbLower)

    lbUpper := label.new(
         bar_index, upper,
         "◀ Upper: " + str.tostring(upper, format.mintick),
         color=color.new(color.black, 100), textcolor=upperColor,
         force_overlay=true, style=label.style_label_left)

    lbBasis := label.new(
         bar_index, basis,
         "◀ Basis: " + str.tostring(basis, format.mintick),
         color=color.new(color.black, 100), textcolor=basisColor,
         force_overlay=true, style=label.style_label_left)

    lbLower := label.new(
         bar_index, lower,
         "◀ Lower: " + str.tostring(lower, format.mintick),
         color=color.new(color.black, 100), textcolor=lowerColor,
         force_overlay=true, style=label.style_label_left)
````
