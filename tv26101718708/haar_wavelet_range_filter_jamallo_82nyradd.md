# Haar Wavelet Range Filter [Jamallo]

- url: https://www.tradingview.com/script/82NYRAdD-Haar-Wavelet-Range-Filter-Jamallo/
- type: indicator
- pine_id: PUB;665a3a9bcb3245d7a28dbfe0d67c3950
- version: 1.0

## Description

[b]Intro[/b]

[b]Haar Wavelet Range Filter [Jamallo][/b]

Standard moving averages often struggle with a fundamental trade-off: they are either too fast (reacting to every bit of market noise) or too slow (lagging behind actual trend shifts). This indicator solves that problem by moving away from time-based averaging and into the [b]frequency domain[/b].

By utilizing a [b] Maximal Overlap Discrete Wavelet Transform (MODWT)[/b] with a Haar basis, this filter decomposes price action into specific "energy levels." It isolates the core trend from the high-frequency "chatter" (wicks and micro-jitters). The result is a highly responsive, shift-invariant trend line that stays flat during consolidation and moves decisively when a true volatility-backed shift occurs.

[b]How It Works[/b]
The indicator processes price through a multi-stage signal processing pipeline:

[b]Stage 1 — MODWT Haar Decomposition[/b]

Instead of a simple windowed average, the engine performs a wavelet decomposition. It splits the price into Scaling coefficients (the smooth trend) and Detail coefficients (the noise/volatility).

[list]
[*]Unlike standard DWT, this uses [b]MODWT[/b], making it shift-invariant. This means the filter doesn't "jump" or repaint when new bars arrive; the relationship between price and the wavelet remains constant over time.

[*][b]The Decomposition Level [/b](1–5) dictates the scale of the trend, ranging from ultra-fast 2-bar captures to macro 32-bar structural cycles.
[/list]

[b]Stage 2 — Adaptive Detail-Energy Deadband[/b]

The "step-like" nature of the filter is driven by an automated threshold. The indicator measures the Detail Energy—essentially the absolute volatility of the noise at your chosen scale.

[b]Stage 3 — Non-Parametric Percentile Bands[/b]

Rather than using standard deviation (which assumes price follows a normal "Bell Curve" distribution), this indicator uses [b]Linear Interpolation Percentiles.[/b]

## Source Code

````pine
// This Pine Script™ source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=5
indicator("Haar wavelet range filter [Jamallo]", shorttitle = "Wavelet RF [Jamallo]", overlay=true)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════
group_wave = "MODWT Haar Wavelet"
wLevel     = input.int(3, "Decomposition Level", minval=1, maxval=5,
     tooltip = "Wavelet scale for center line.\n1 = 2-bar\n2 = 4-bar\n3 = 8-bar (default)\n4 = 16-bar\n5 = 32-bar",
     group = group_wave)
dbMult     = input.float(4.0, "Deadband Multiplier", minval=0.1, maxval=10.0, step=0.1,
     tooltip = "Scales the adaptive deadband threshold.\nHigher = fewer, larger blocks.",
     group = group_wave)
energyLen  = input.int(20, "Detail Energy Lookback", minval=5, maxval=200,
     tooltip = "Period for smoothing wavelet detail energy\n(used for adaptive deadband threshold).",
     group = group_wave)

group_bands     = "Channel Bands"
bandLookback    = input.int(100,  "Band Lookback Period",   minval=10,   group=group_bands)
innerPercentile = input.float(68.0, "Inner Band Percentile", minval=50.0, maxval=99.0, step=0.5,
     tooltip = "Percentile of |price − center| for inner band.\n68 ≈ 1σ equivalent.", group=group_bands)
bandDbMult      = input.float(1.0, "Band Deadband Sensitivity", minval=0.1, maxval=5.0, step=0.1,
     tooltip = "Controls band width blockiness.\nHigher = blockier band widths.", group=group_bands)

group_disp     = "Display"
showCenter     = input.bool(true,  "Show Center Line",   group=group_disp)
showInnerBands = input.bool(true,  "Show Inner Bands",   group=group_disp)
showFill       = input.bool(true,  "Show Band Fill",     group=group_disp)
showSignals    = input.bool(true,  "Show Signals",       group=group_disp)
bullColor      = input.color(color.new(#05ff9b, 0), "Bullish Color", group=group_disp)
bearColor      = input.color(color.new(#ff0583, 0), "Bearish Color", group=group_disp)

// ══════════════════════════════════════════════════════════════════════════════
// MODWT HAAR WAVELET DECOMPOSITION
// ──────────────────────────────────────────────────────────────────────────────
// Maximal Overlap DWT with Haar basis — shift-invariant, no downsampling.
// Scaling coefficients (V): recursive averages at doubling lags.
// Detail coefficients (D): noise captured at each scale.
// ══════════════════════════════════════════════════════════════════════════════
float src = hl2

// ——— Level 1 ———
float v1 = (src + nz(src[1], src)) / 2.0
float d1 = (src - nz(src[1], src)) / 2.0
// ——— Level 2 ———
float v2 = (v1  + nz(v1[2],  v1))  / 2.0
float d2 = (v1  - nz(v1[2],  v1))  / 2.0
// ——— Level 3 ———
float v3 = (v2  + nz(v2[4],  v2))  / 2.0
float d3 = (v2  - nz(v2[4],  v2))  / 2.0
// ——— Level 4 ———
float v4 = (v3  + nz(v3[8],  v3))  / 2.0
float d4 = (v3  - nz(v3[8],  v3))  / 2.0
// ——— Level 5 ———
float v5 = (v4  + nz(v4[16], v4))  / 2.0
float d5 = (v4  - nz(v4[16], v4))  / 2.0

// Select decomposition level
float smoothMid = wLevel == 1 ? v1 : wLevel == 2 ? v2 :
     wLevel == 3 ? v3 : wLevel == 4 ? v4 : v5
float detailMid = wLevel == 1 ? d1 : wLevel == 2 ? d2 :
     wLevel == 3 ? d3 : wLevel == 4 ? d4 : d5

// ══════════════════════════════════════════════════════════════════════════════
// CENTER LINE — wavelet smooth + adaptive deadband step-hold
// ──────────────────────────────────────────────────────────────────────────────
// Threshold is self-derived from wavelet detail energy (noise at selected
// scale). Center holds flat until smoothed value departs by > threshold.
// ══════════════════════════════════════════════════════════════════════════════
float detailEnergy = ta.sma(math.abs(detailMid), energyLen)
float threshMid    = detailEnergy * dbMult

var float heldMid = na
heldMid := na(heldMid) ? smoothMid :
     math.abs(smoothMid - heldMid) > threshMid ? smoothMid : heldMid

// ══════════════════════════════════════════════════════════════════════════════
// PERCENTILE BANDS — deviation from center, step-held for blockiness
// ──────────────────────────────────────────────────────────────────────────────
// Inner band ≈ 1σ (68th percentile of |price − center|)
// Band widths are also step-held for blocky channel edges.
// ══════════════════════════════════════════════════════════════════════════════
float deviation = math.abs(src - heldMid)
float innerRaw  = ta.percentile_linear_interpolation(deviation, bandLookback, innerPercentile)

// Step-hold band widths (threshold = 15% of current width × sensitivity)
var float heldInner = na
float threshInner = math.max(nz(heldInner, nz(innerRaw)) * 0.15 * bandDbMult, syminfo.mintick)

heldInner := na(heldInner) ? nz(innerRaw, syminfo.mintick) :
     math.abs(nz(innerRaw) - heldInner) > threshInner ? innerRaw : heldInner

// Channel levels
float innerUpper = heldMid + heldInner
float innerLower = heldMid - heldInner

// ══════════════════════════════════════════════════════════════════════════════
// DIRECTION & SIGNALS
// ══════════════════════════════════════════════════════════════════════════════
var bool upward = true
if heldMid > nz(heldMid[1])
    upward := true
else if heldMid < nz(heldMid[1])
    upward := false

bool buySignal  = upward and not upward[1]
bool sellSignal = not upward and upward[1]

// ══════════════════════════════════════════════════════════════════════════════
// COLORS
// ══════════════════════════════════════════════════════════════════════════════
color trendColor     = upward ? color.new(bullColor, 30) : color.new(bearColor, 30)
color innerBandUpper = color.new(#00b36b, 75)
color innerBandLower = color.new(#b8005d, 75)

// ══════════════════════════════════════════════════════════════════════════════
// PLOTS
// ══════════════════════════════════════════════════════════════════════════════
// Center line — visible, trend-colored
centerPlot = plot(showCenter ? heldMid : na, "Center Line",
     color=trendColor, linewidth=1, style=plot.style_line)

// Always-on fill reference for center
centerRef = plot(heldMid, "Center Ref",
     color=na, display=display.none, style=plot.style_line)

// Inner bands — visible, fixed bull/bear coloring
iUpPlot = plot(showInnerBands ? innerUpper : na, "Inner Upper",
     color=innerBandUpper, linewidth=1, style=plot.style_line)
iDnPlot = plot(showInnerBands ? innerLower : na, "Inner Lower",
     color=innerBandLower, linewidth=1, style=plot.style_line)

// Always-on fill references for inner bands
iUpRef = plot(innerUpper, "Inner Upper Ref",
     color=na, display=display.none, style=plot.style_line)
iDnRef = plot(innerLower, "Inner Lower Ref",
     color=na, display=display.none, style=plot.style_line)

// FILLS — bull/bear colored (upper = teal, lower = maroon)
// ══════════════════════════════════════════════════════════════════════════════
fill(iUpRef, centerRef,
     color = showFill ? color.new(color.teal,  88) : na,
     title = "Upper Inner Fill")
fill(iDnRef, centerRef,
     color = showFill ? color.new(color.maroon, 88) : na,
     title = "Lower Inner Fill")

// ══════════════════════════════════════════════════════════════════════════════
// SIGNALS & ALERTS
// ══════════════════════════════════════════════════════════════════════════════
plotshape(showSignals ? buySignal  : na, title="Buy Signal",
     style=shape.triangleup,   location=location.belowbar,
     color=color.new(bullColor, 0), size=size.small)
plotshape(showSignals ? sellSignal : na, title="Sell Signal",
     style=shape.triangledown, location=location.abovebar,
     color=color.new(bearColor, 0), size=size.small)

alertcondition(buySignal,  title="Bullish Flip",
     message="Haar wavelet range filter: Center turned Bullish")
alertcondition(sellSignal, title="Bearish Flip",
     message="Haar wavelet range filter: Center turned Bearish")
````
