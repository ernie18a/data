<!-- tradingview-pine-id: PUB;fc5d6680d4c34c47bb8b0950507c66d3 -->
<!-- tradingviewscripts-format: 1 -->
# Entry Point X500

Source: https://www.tradingview.com/script/1MhM9vaj-entry-point-x500/

## Description

Entry Point X500 is an overlay envelope built on Nadaraya–Watson kernel regression with a Gaussian kernel. It smooths price into a local estimate of the underlying trend, draws volatility bands around that estimate using mean absolute deviation (MAD), and marks mean-reversion events when price interacts with those bands.

What makes it useful
Standard moving averages weight bars with fixed linear or exponential schemes. This script estimates price with a Gaussian kernel: bars closer to the estimation point receive higher weight, which helps reduce noise while still reacting to genuine structure changes.

Two calculation modes are included:

Fixed mode (default, non-repainting) — endpoint-anchored regression using past bars only. Historical bands and signals stay fixed after a bar closes. Use this mode for chart review, backtesting logic, and alerts.
Live mode (repainting) — full-window Nadaraya–Watson smoothing recalculated on every update of the last bar. The envelope can use a symmetrical neighborhood of bars around each point inside the lookback window. This can look smoother and more “responsive” on the current chart, but historical lines and signals may appear, move, or disappear as new data arrives.
How it works
Smoothing — a Gaussian kernel weight is applied across the lookback window to produce a regression estimate of price.
Bands — an envelope is built around the estimate using the mean absolute deviation of price from that estimate, scaled by the Deviation Multiplier. MAD reacts less aggressively to extreme outliers than a standard-deviation band.
Signals
Fixed mode: ▲ when close crosses under the lower band; ▼ when close crosses over the upper band. These mark breakouts into potential oversold/overbought extremes for mean-reversion context.
Live mode: ▲ when price returns inside the envelope from below the lower band; ▼ when price returns inside from above the upper band. These mark the start of a local move back toward the regression estimate.
A status label shows whether Live or Fixed mode is active.

Inputs
Kernel bandwidth — controls smoothness. Lower values follow price more closely; higher values create a slower, smoother filter.
Deviation multiplier — controls envelope width.
Price source — series used for the regression (default: close).
Live mode (repaints) — switches between Live and Fixed calculation. Default is OFF.
Live alert: last N bars — in Live mode, alerts fire only for newly appeared signals within the last N bars, to reduce noise while history is recalculated.
How to use
Use the envelope as a contextual overbought/oversold framework for mean-reversion analysis:

Price outside the bands = stretched relative to the local kernel estimate.
Signals highlight interactions with the bands; they are not standalone trade instructions.
Prefer Fixed mode when validating behavior historically or attaching alerts.
Treat Live mode as a real-time visual aid only, and always assume past signals can change.
Confirm with market structure, levels, volume, or other independent context. Do not trade the triangles alone.
Limitations (important)
Live mode repaints. Historical envelopes and triangles are redrawn on each last-bar update and must not be judged as stable historical signals.
Fixed and Live modes use different estimation methods and different signal rules; results will not match 1:1.
Like any smoothing tool, the script can lag or produce frequent signals in choppy markets, and fewer/later signals when bandwidth or deviation is high.
Non-standard chart types (Heikin Ashi, Renko, etc.) can distort signal interpretation; use standard candlesticks/bars for signal analysis.
Disclaimer
This script is for educational and analytical purposes only and does not constitute financial advice. Past visual behavior does not guarantee future results. Test settings carefully on historical data in Fixed mode before considering any real-money use.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © X500
//
// Nadaraya-Watson Gaussian kernel regression envelope with optional live (repainting) mode.
// IMPORTANT: When Live mode is enabled, historical envelopes and signals are recalculated on every
// update of the last bar and may appear, move, or disappear. Use Fixed mode for non-repainting analysis.

//@version=6
indicator(
     title          = "Entry Point X500",
     shorttitle     = "Entry Point X500",
     overlay        = true,
     max_lines_count  = 500,
     max_labels_count = 500,
     max_bars_back    = 500)

//=================== CONSTANTS ===================
int   MAX_LOOKBACK     = 499
color DEFAULT_UP_COLOR = color.teal
color DEFAULT_DN_COLOR = color.red
color STATUS_BG        = #1e222d
color STATUS_BORDER    = #373a46

//=================== INPUTS ===================
float bandwidthInput = input.float(
     defval  = 8.0,
     title   = "Kernel bandwidth",
     minval  = 0.01,
     tooltip = "Higher values produce a smoother regression curve.")

float devMultInput = input.float(
     defval = 3.0,
     title  = "Deviation multiplier",
     minval = 0.0,
     tooltip = "Scales the absolute-deviation envelope around the regression estimate.")

srcInput = input.source(
     defval = close,
     title  = "Price source")

bool liveModeInput = input.bool(
     defval  = false,
     title   = "Live mode (repaints)",
     tooltip = "ON: recalculates the full lookback curve on every last-bar update (repaints history). OFF: fixed endpoint calculation that does not redraw past bars. Default is OFF for safer public use.")

color colorUpInput = input.color(
     defval  = DEFAULT_UP_COLOR,
     title   = "Upper band color",
     inline  = "col",
     group   = "Style")

color colorDnInput = input.color(
     defval  = DEFAULT_DN_COLOR,
     title   = "Lower band color",
     inline  = "col",
     group   = "Style")

int alertNearBarsInput = input.int(
     defval  = 15,
     title   = "Live alert: last N bars",
     minval  = 1,
     maxval  = 100,
     group   = "Alerts",
     tooltip = "In Live mode, fire an alert only when a new triangle appears within the last N bars. Reduces spam while the full history is recalculated.")

//=================== FUNCTIONS ===================
//@function Gaussian kernel weight for Nadaraya–Watson regression.
//@param distance (float) Distance in bars between the estimation point and the sample.
//@param h (float) Kernel bandwidth.
//@returns Kernel weight.
kernelWeight(float distance, float h) =>
    math.exp(-(distance * distance) / (2.0 * h * h))

//@function Returns true when `val` is already present in `arr`.
arrayHas(array<int> arr, int val) =>
    bool found = false
    if arr.size() > 0
        for k = 0 to arr.size() - 1
            if arr.get(k) == val
                found := true
    found

//=================== FIXED ENDPOINT MODE ===================
// Non-repainting mode: one endpoint-anchored estimate per bar using precomputed kernel weights.
var float[] fixedWeights = array.new_float(0)
var float   weightSum    = 0.0

if barstate.isfirst and not liveModeInput
    for i = 0 to MAX_LOOKBACK
        fixedWeights.push(kernelWeight(i, bandwidthInput))
    weightSum := fixedWeights.sum()

float fixedEstimate = 0.0
if not liveModeInput
    for i = 0 to MAX_LOOKBACK
        fixedEstimate += srcInput[i] * fixedWeights.get(i)
    fixedEstimate /= weightSum

float fixedDeviation = ta.sma(math.abs(srcInput - fixedEstimate), MAX_LOOKBACK) * devMultInput
float fixedUpper     = fixedEstimate + fixedDeviation
float fixedLower     = fixedEstimate - fixedDeviation

plot(liveModeInput ? na : fixedUpper, "Upper band (fixed)", colorUpInput)
plot(liveModeInput ? na : fixedLower, "Lower band (fixed)", colorDnInput)

//=================== LIVE MODE (REPAINTS) ===================
// Recalculates the entire lookback window on the last bar. Historical lines/labels/signals can change.
var line[]  drawnLines       = array.new_line(0)
var label[] drawnLabels      = array.new_label(0)
var float[] smoothed         = array.new_float(0)
var int[]   prevUpBars       = array.new_int(0)
var int[]   prevDnBars       = array.new_int(0)
var bool    liveAlertsPrimed = false

if barstate.islast and liveModeInput
    if drawnLines.size() > 0
        for k = 0 to drawnLines.size() - 1
            line.delete(drawnLines.get(k))
        drawnLines.clear()

    if drawnLabels.size() > 0
        for k = 0 to drawnLabels.size() - 1
            label.delete(drawnLabels.get(k))
        drawnLabels.clear()

    smoothed.clear()
    int   lookback  = math.min(MAX_LOOKBACK, bar_index - 1)
    int   sampleCnt = lookback + 1
    float cumAbsDev = 0.0

    array<int> currUpBars = array.new_int(0)
    array<int> currDnBars = array.new_int(0)

    for i = 0 to lookback
        float num   = 0.0
        float denom = 0.0
        for j = 0 to lookback
            float w = kernelWeight(i - j, bandwidthInput)
            num   += srcInput[j] * w
            denom += w
        float estAtI = num / denom
        cumAbsDev += math.abs(srcInput[i] - estAtI)
        smoothed.push(estAtI)

    float avgDev = cumAbsDev / sampleCnt * devMultInput

    float prevPoint = float(na)
    for i = 0 to lookback
        float currPoint = smoothed.get(i)

        // Draw every other segment to stay within line limits while keeping the envelope readable.
        if i % 2 == 1 and not na(prevPoint)
            drawnLines.push(line.new(bar_index - i + 1, prevPoint + avgDev, bar_index - i, currPoint + avgDev, color = colorUpInput))
            drawnLines.push(line.new(bar_index - i + 1, prevPoint - avgDev, bar_index - i, currPoint - avgDev, color = colorDnInput))

        if i < lookback
            // Mean-reversion crosses against the estimate at bar i.
            bool isDn   = srcInput[i] > currPoint + avgDev and srcInput[i + 1] < currPoint + avgDev
            bool isUp   = srcInput[i] < currPoint - avgDev and srcInput[i + 1] > currPoint - avgDev
            int  sigBar = bar_index - i

            if isDn
                drawnLabels.push(label.new(sigBar, srcInput[i], "▼", color = color(na), style = label.style_label_down, textcolor = colorDnInput, textalign = text.align_center))
                currDnBars.push(sigBar)

            if isUp
                drawnLabels.push(label.new(sigBar, srcInput[i], "▲", color = color(na), style = label.style_label_up, textcolor = colorUpInput, textalign = text.align_center))
                currUpBars.push(sigBar)

            // Alert only after the first live pass, and only for newly appeared nearby signals.
            if liveAlertsPrimed and i < alertNearBarsInput
                if isUp and not arrayHas(prevUpBars, sigBar)
                    alert("Entry Point X500: ▲ long signal (Live / may repaint)", alert.freq_all)
                if isDn and not arrayHas(prevDnBars, sigBar)
                    alert("Entry Point X500: ▼ short signal (Live / may repaint)", alert.freq_all)

        prevPoint := currPoint

    prevUpBars.clear()
    prevDnBars.clear()
    if currUpBars.size() > 0
        for k = 0 to currUpBars.size() - 1
            prevUpBars.push(currUpBars.get(k))
    if currDnBars.size() > 0
        for k = 0 to currDnBars.size() - 1
            prevDnBars.push(currDnBars.get(k))
    liveAlertsPrimed := true

//=================== STATUS PANEL ===================
var table statusTable = table.new(
     position.top_right,
     1,
     1,
     bgcolor      = STATUS_BG,
     border_color = STATUS_BORDER,
     border_width = 1,
     frame_color  = STATUS_BORDER,
     frame_width  = 1)

if barstate.islast
    string statusText = liveModeInput ? "Live mode ON (repaints)" : "Fixed mode (no repaint)"
    color  statusCol  = liveModeInput ? color.orange : color.lime
    statusTable.cell(0, 0, statusText, text_color = statusCol, text_size = size.small)

//=================== FIXED-MODE SIGNALS & ALERTS ===================
bool fixedSignalUp = ta.crossunder(close, fixedLower)
bool fixedSignalDn = ta.crossover(close, fixedUpper)

plotshape(
     not liveModeInput and fixedSignalUp ? low : na,
     title     = "Cross under lower band",
     style     = shape.labelup,
     location  = location.absolute,
     color     = color(na),
     text      = "▲",
     textcolor = colorUpInput,
     size      = size.tiny)

plotshape(
     not liveModeInput and fixedSignalDn ? high : na,
     title     = "Cross over upper band",
     style     = shape.labeldown,
     location  = location.absolute,
     color     = color(na),
     text      = "▼",
     textcolor = colorDnInput,
     size      = size.tiny)

if not liveModeInput and fixedSignalUp
    alert("Entry Point X500: ▲ long signal", alert.freq_once_per_bar_close)
if not liveModeInput and fixedSignalDn
    alert("Entry Point X500: ▼ short signal", alert.freq_once_per_bar_close)

alertcondition(not liveModeInput and fixedSignalUp, "▲ Long signal (fixed)", "Entry Point X500: ▲ long signal")
alertcondition(not liveModeInput and fixedSignalDn, "▼ Short signal (fixed)", "Entry Point X500: ▼ short signal")
````
