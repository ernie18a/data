# Haar Wavelet RSI [Jamallo]

- url: https://www.tradingview.com/script/0uI42WV2-Haar-Wavelet-RSI-Jamallo/
- type: indicator
- pine_id: PUB;2edd7922f3e24205afc7fdf8a723662b
- version: 1.0

## Description

[b]Author's Note[/b]
This is the oscillator companion to the Haar Wavelet Range Filter. Both indicators share the same MODWT Haar wavelet foundation, creating a synergistic effect when used together — trend and momentum derived from the same mathematical decomposition of price.

[b]Introduction[/b]

The Haar Wavelet RSI is a momentum oscillator that replaces the standard price-difference input of a traditional RSI with wavelet detail coefficients derived from a Maximal Overlap Discrete Wavelet Transform (MODWT) with a Haar basis. Instead of measuring bar-to-bar price change, it measures momentum at a specific frequency scale — filtering out the noise above and below that scale before the RSI calculation even begins.

[b]How It Works[/b]

[b]MODWT Haar Wavelet Decomposition[/b]

The script decomposes hl2 through up to 5 wavelet levels using a shift-invariant Haar transform. At each level, the detail coefficients capture the local price delta at that specific scale — Level 1 is 2-bar momentum, Level 3 is 8-bar momentum, Level 5 is 32-bar momentum. These detail coefficients become the input to the RSI in place of raw price change, meaning the oscillator is measuring directional energy at a single isolated frequency rather than the full noisy price series.

[b]Wavelet RSI Calculation[/b]

The selected detail coefficient is split into its upward and downward components, smoothed with Wilder's RMA, and fed into the standard RSI formula. The math is identical to a conventional RSI — the only difference is what it is measuring. Because the detail coefficients are already frequency-isolated, the resulting RSI is inherently cleaner than applying RSI to raw price.

[b]Adaptive Deadband Step-Hold[/b]

The wavelet RSI output is then passed through an adaptive deadband filter. The threshold is self-derived from the RSI's own recent volatility — a short rolling average of absolute RSI changes — scaled by the deadband multiplier. The RSI only updates when it departs from its held value by more than this threshold. Below the threshold it holds flat. This eliminates the continuous micro-oscillation that makes standard RSI difficult to read on noisy bars, producing a stepped line that moves with conviction or not at all.

[b]Closing[/b]

This is not a standard RSI with cosmetic changes. The wavelet decomposition fundamentally changes what the oscillator is measuring — momentum at a defined frequency scale rather than raw bar-to-bar noise. The decomposition level is the most important setting: lower levels suit faster timeframes and shorter momentum cycles, higher levels filter more aggressively and are better suited to swing-level momentum reads.

## Source Code

````pine
// This Pine Script™ source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=5
indicator("Haar Wavelet RSI [Jamallo]", shorttitle="Wavelet RSI [Jamallo]", overlay=false)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════
group_wave = "MODWT Haar Wavelet"
wLevel     = input.int(3, "Decomposition Level", minval=1, maxval=5,
     tooltip = "Wavelet scale for delta.\n1 = 2-bar\n2 = 4-bar\n3 = 8-bar (default)\n4 = 16-bar\n5 = 32-bar",
     group = group_wave)
rsiLength  = input.int(14, "RSI Length", minval=1, group=group_wave)
dbMult     = input.float(2.0, "Deadband Multiplier", minval=0.1, maxval=10.0, step=0.1,
     tooltip = "Scales the adaptive deadband threshold for the RSI.\nHigher = fewer, larger blocks.",
     group = group_wave)
energyLen  = input.int(5, "Energy Lookback", minval=1, maxval=200,
     tooltip = "Period for smoothing RSI change energy\n(used for adaptive deadband threshold).",
     group = group_wave)

group_stop = "Trailing Stop"
showTrail  = input.bool(true, "Show Trailing Stop", group=group_stop)
trailLen   = input.int(100, "Trailing Stop ATR Length", minval=1, group=group_stop)
trailMult  = input.float(5.0, "Trailing Stop Multiplier", minval=0.1, step=0.1, group=group_stop)

group_disp = "Display"
bullColor  = input.color(color.new(#05ff9b, 0), "Bullish Color", group=group_disp)
bearColor  = input.color(color.new(#ff0583, 0), "Bearish Color", group=group_disp)
showRaw    = input.bool(false, "Show Raw RSI (Background)", group=group_disp)

// ══════════════════════════════════════════════════════════════════════════════
// MODWT HAAR WAVELET DECOMPOSITION
// ──────────────────────────────────────────────────────────────────────────────
// Maximal Overlap DWT with Haar basis.
// Detail coefficients (D) represent the local price 'delta' at each scale.
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

// Select decomposition level's delta
float detailMid = wLevel == 1 ? d1 : wLevel == 2 ? d2 :
     wLevel == 3 ? d3 : wLevel == 4 ? d4 : d5

// ══════════════════════════════════════════════════════════════════════════════
// WAVELET RSI CALCULATION
// ──────────────────────────────────────────────────────────────────────────────
float upDiff   = math.max(detailMid, 0)
float downDiff = -math.min(detailMid, 0)

float smoothedUp   = ta.rma(upDiff, rsiLength)
float smoothedDown = ta.rma(downDiff, rsiLength)

float wRSI = smoothedDown == 0 ? 100 : smoothedUp == 0 ? 0 : 100 - (100 / (1 + smoothedUp / smoothedDown))

// ══════════════════════════════════════════════════════════════════════════════
// STEP-HOLD (DEADBAND) FILTER ON RSI
// ──────────────────────────────────────────────────────────────────────────────
// Threshold is self-derived from RSI volatility energy.
// RSI holds flat until the raw unsmoothed calculation departs by > threshold.
// ══════════════════════════════════════════════════════════════════════════════
float rsiEnergy = ta.sma(math.abs(ta.change(wRSI)), energyLen)
float rsiThresh = rsiEnergy * dbMult

var float heldRSI = na
heldRSI := na(heldRSI) ? wRSI :
     math.abs(wRSI - heldRSI) > rsiThresh ? wRSI : heldRSI

// ══════════════════════════════════════════════════════════════════════════════
// RSI TRAILING STOP
// ──────────────────────────────────────────────────────────────────────────────
float rsiTrueRange = math.abs(ta.change(heldRSI))
float rsiATR       = ta.rma(rsiTrueRange, trailLen)
float rsiTrailDist = rsiATR * trailMult

var int rsiTrend = 1
var float rsiTrailStop = heldRSI

if rsiTrend == 1
    rsiTrailStop := math.max(nz(rsiTrailStop, heldRSI - rsiTrailDist), heldRSI - rsiTrailDist)
    if heldRSI < rsiTrailStop
        rsiTrend := -1
        rsiTrailStop := heldRSI + rsiTrailDist
else
    rsiTrailStop := math.min(nz(rsiTrailStop, heldRSI + rsiTrailDist), heldRSI + rsiTrailDist)
    if heldRSI > rsiTrailStop
        rsiTrend := 1
        rsiTrailStop := heldRSI - rsiTrailDist

// ══════════════════════════════════════════════════════════════════════════════
// PLOTS
// ══════════════════════════════════════════════════════════════════════════════
color rsiColor = heldRSI > 50 ? bullColor : bearColor
color stopColor = rsiTrend == 1 ? color.new(bullColor, 40) : color.new(bearColor, 40)

hline(70, "Overbought", color=color.new(color.gray, 50), linestyle=hline.style_solid, linewidth=1)
hline(50, "Midline",    color=color.new(color.gray, 50), linestyle=hline.style_solid, linewidth=1)
hline(30, "Oversold",   color=color.new(color.gray, 50), linestyle=hline.style_solid, linewidth=1)

plot(showRaw ? wRSI : na, "Raw RSI", color=color.new(color.gray, 70), linewidth=1, style=plot.style_line)
plot(heldRSI, "Stepped Wavelet RSI", color=rsiColor, linewidth=1, style=plot.style_line)
plot(showTrail ? rsiTrailStop : na, "RSI Trailing Stop", color=stopColor, linewidth=1, style=plot.style_line)
````
