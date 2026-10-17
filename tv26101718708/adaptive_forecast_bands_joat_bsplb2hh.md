# Adaptive Forecast Bands [JOAT]

- url: https://www.tradingview.com/script/bSplb2hH-Adaptive-Forecast-Bands-JOAT/
- type: indicator
- pine_id: PUB;5f542a24b3ac4fcd8e53d1b500237934
- version: 1.0

## Description

[b]Adaptive Forecast Bands [JOAT][/b]

[b]Introduction[/b]

Adaptive Forecast Bands is an open-source adaptive regression and mean-reversion framework. It estimates a live fair-value path from price, wraps that path in volatility-aware bands, and marks confirmed re-entry conditions only after the bar closes.

The problem this indicator solves is context around stretched price. A static moving average band can lag badly when volatility changes. Adaptive Forecast Bands uses a recursive regression engine, a live model error estimate, and an ATR blend so the envelope expands and contracts with current market behavior.

[image]https://www.tradingview.com/x/bwQKF5CZ/[/image]

[b]Core Concepts[/b]

[b]1. Adaptive Regression Mean[/b]

The centerline is built from a persistent two-parameter regression state. The script uses normalized local time so the model does not depend on raw bar index growth over long histories.

[pine]
forecastMean = beta0 + beta1 * xNorm
forecastErr  = source - forecastMean
[/pine]

[b]2. Error-Based Confidence Bands[/b]

Band width is derived from the model's exponentially weighted error plus an ATR component. This keeps the band reactive to both forecast error and realized volatility.

[b]3. Confirmed Re-Entry Signals[/b]

The script arms a long or short setup when price reaches an outer band. A signal only prints when price confirms a re-entry back through the relevant band on `barstate.isconfirmed`.

[b]4. Forecast Guide Lines[/b]

The right-edge guide projects the current regression slope forward for visual context. It is a guide, not a prediction, and is redrawn on the last bar to avoid object clutter.

[b]Features[/b]

[list]
[*][b]Adaptive fair-value line:[/b] Recursive regression centerline based on current price behavior
[*][b]Volatility-aware envelope:[/b] Error variance and ATR combine to form dynamic upper/lower bands
[*][b]Confirmed long/short labels:[/b] Re-entry signals use closed-bar logic
[*][b]Right-edge forecast guide:[/b] Dashed and dotted guide lines show current slope context
[*][b]Top-right dashboard:[/b] Bias, confidence, band width, slope, guide state, and signal state
[*][b]Alert conditions:[/b] Long and short confirmed re-entry events
[/list]

[b]Input Parameters[/b]

[b]Model:[/b]
[list]
[*]Source: Price source used by the model
[*]Forgetting Factor: How quickly the model adapts to new price information
[*]Regression Horizon: Normalization horizon for the regression slope
[*]Band Multiplier: Multiplier applied to model error
[*]ATR Blend: Extra realized-volatility padding in the band width
[*]Rebase Interval: Periodic reset to keep the adaptive model stable
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Use the centerline as an adaptive fair-value reference.
[b]Step 2:[/b] Treat outer-band touches as stretched conditions, not immediate entries.
[b]Step 3:[/b] Wait for confirmed re-entry labels when enabled.
[b]Step 4:[/b] Read the dashboard confidence and slope before interpreting the signal.

[b]Indicator Limitations[/b]

[list]
[*]The right-edge guide is a visualization of current model slope, not a forecast guarantee
[*]Mean-reversion signals can underperform during strong directional trends
[*]The model periodically rebases by design to reduce long-history numerical drift
[*]Signals are confirmed on closed bars and can appear after the intrabar extreme occurred
[/list]

[b]Originality Statement[/b]

Adaptive Forecast Bands is an original JOAT implementation combining normalized recursive regression, error-based confidence bands, ATR blending, confirmed re-entry logic, and a compact interpretive dashboard. It does not copy third-party source code.

[b]Disclaimer[/b]

This open-source indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves risk, and historical behavior does not ensure future results. Always use proper risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Adaptive Forecast Bands [JOAT]", "AFB [JOAT]", overlay = true, max_labels_count = 200, max_lines_count = 50)

//------------------------------------------------------------------------------
// Constants
//------------------------------------------------------------------------------
color JOAT_BULL   = #089981
color JOAT_BEAR   = #f23645
color JOAT_TEXT   = #DBDBDB
color JOAT_MID    = #787b86
color JOAT_PANEL  = #161616
color JOAT_BORDER = #2E2E2E

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
groupModel = "Model"
srcInput = input.source(close, "Source", group = groupModel)
lambdaInput = input.float(0.975, "Forgetting Factor", minval = 0.80, maxval = 1.0, step = 0.005, group = groupModel)
regLenInput = input.int(80, "Regression Horizon", minval = 10, group = groupModel)
bandMultInput = input.float(1.8, "Band Multiplier", minval = 0.1, step = 0.1, group = groupModel)
atrMixInput = input.float(0.35, "ATR Blend", minval = 0.0, maxval = 2.0, step = 0.05, group = groupModel)
rebaseInput = input.int(200, "Rebase Interval", minval = 25, group = groupModel)

groupVisual = "Visuals"
showGuideInput = input.bool(true, "Show Forecast Guide", group = groupVisual)
guideBarsInput = input.int(24, "Guide Bars", minval = 5, maxval = 100, group = groupVisual)
showSignalsInput = input.bool(true, "Show Confirmed Signals", group = groupVisual)
showBandTintInput = input.bool(true, "Tint Candles By Band Bias", group = groupVisual)
showDashInput = input.bool(true, "Show Dashboard", group = groupVisual)
dashPosInput = input.string("Top Right", "Position", options = ["Top Right", "Bottom Right", "Bottom Left"], group = groupVisual)
dashSizeInput = input.string("Normal", "Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisual)
bullBandInput = input.color(color.new(JOAT_BULL, 0), "Bull Band", group = groupVisual)
bearBandInput = input.color(color.new(JOAT_BEAR, 0), "Bear Band", group = groupVisual)
meanInput = input.color(color.new(JOAT_MID, 30), "Mean", group = groupVisual)
guideInput = input.color(color.new(#7f8c98, 35), "Guide", group = groupVisual)

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
parsePos(string choice) =>
    switch choice
        "Top Right" => position.top_right
        "Bottom Right" => position.bottom_right
        => position.bottom_left

parseSize(string choice) =>
    switch choice
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        => size.huge

var parsedDashSize = parseSize(dashSizeInput)

cell(table t, int c, int r, string txt, color txtColor, color bg, align) =>
    t.cell(c, r, txt, text_color = txtColor, bgcolor = bg, text_size = parsedDashSize, text_halign = align)

tanhFast(float x) =>
    float ex = math.exp(2.0 * x)
    (ex - 1.0) / (ex + 1.0)

//------------------------------------------------------------------------------
// Persistent State
//------------------------------------------------------------------------------
var float beta0 = srcInput
var float beta1 = 0.0
var float p00 = 1000.0
var float p01 = 0.0
var float p11 = 1000.0
var float errEwma = 0.0
var int baseBar = bar_index
var bool upperArmed = false
var bool lowerArmed = false

if bar_index == 0
    beta0 := srcInput
    beta1 := 0.0
    baseBar := 0

if barstate.isconfirmed and bar_index > 0 and rebaseInput > 0 and bar_index % rebaseInput == 0
    baseBar := bar_index
    beta0 := srcInput
    beta1 := 0.0
    p00 := 1000.0
    p01 := 0.0
    p11 := 1000.0
    errEwma := 0.0

//------------------------------------------------------------------------------
// Adaptive Regression
//------------------------------------------------------------------------------
float xNorm = math.max(0.0, (bar_index - baseBar) / math.max(1.0, float(regLenInput)))
float forecastMean = beta0 + beta1 * xNorm
float forecastErr = srcInput - forecastMean

errEwma := lambdaInput * errEwma + (1.0 - lambdaInput) * math.pow(forecastErr, 2)

float px0 = p00 + p01 * xNorm
float px1 = p01 + p11 * xNorm
float denom = lambdaInput + px0 + xNorm * px1

if denom != 0
    float k0 = px0 / denom
    float k1 = px1 / denom
    beta0 += k0 * forecastErr
    beta1 += k1 * forecastErr
    p00 := (p00 - k0 * px0) / lambdaInput
    p01 := (p01 - k0 * px1) / lambdaInput
    p11 := (p11 - k1 * px1) / lambdaInput

float atrValue = ta.atr(14)
float bandSpread = math.max(syminfo.mintick, math.sqrt(math.max(errEwma, 0.0)) * bandMultInput + atrValue * atrMixInput)
float upperBand = forecastMean + bandSpread
float lowerBand = forecastMean - bandSpread

float biasScore = bandSpread > 0 ? (srcInput - forecastMean) / bandSpread : 0.0
float confidenceScore = math.max(0.0, 100.0 - math.min(100.0, math.abs(biasScore) * 35.0))
color biasTint = color.from_gradient(biasScore, -1.50, 1.50, bearBandInput, bullBandInput)

//------------------------------------------------------------------------------
// Signal State
//------------------------------------------------------------------------------
bool touchedUpper = high >= upperBand
bool touchedLower = low <= lowerBand

if touchedUpper
    upperArmed := true
if touchedLower
    lowerArmed := true

bool longSignal = barstate.isconfirmed and lowerArmed and ta.crossover(close, lowerBand) and close > forecastMean and close > open
bool shortSignal = barstate.isconfirmed and upperArmed and ta.crossunder(close, upperBand) and close < forecastMean and close < open

if longSignal
    lowerArmed := false
if shortSignal
    upperArmed := false

//------------------------------------------------------------------------------
// Visuals
//------------------------------------------------------------------------------
pMean = plot(forecastMean, "Adaptive Mean", color = meanInput, linewidth = 2)
pUpper = plot(upperBand, "Upper Band", color = bearBandInput, linewidth = 1)
pLower = plot(lowerBand, "Lower Band", color = bullBandInput, linewidth = 1)
fill(pUpper, pMean, color.new(bearBandInput, 86), title = "Upper Zone")
fill(pMean, pLower, color.new(bullBandInput, 86), title = "Lower Zone")
barcolor(showBandTintInput ? color.new(biasTint, 76) : na, title = "Band Bias Candle Tint")

var line guideMean = na
var line guideUpper = na
var line guideLower = na

if barstate.islast
    if showGuideInput
        if not na(guideMean)
            line.delete(guideMean)
        if not na(guideUpper)
            line.delete(guideUpper)
        if not na(guideLower)
            line.delete(guideLower)

        float futureStep = float(guideBarsInput) / math.max(1.0, float(regLenInput))
        float futureMean = beta0 + beta1 * (xNorm + futureStep)
        float futureUpper = futureMean + bandSpread
        float futureLower = futureMean - bandSpread

        guideMean := line.new(bar_index, forecastMean, bar_index + guideBarsInput, futureMean, color = guideInput, style = line.style_dashed, width = 2)
        guideUpper := line.new(bar_index, upperBand, bar_index + guideBarsInput, futureUpper, color = color.new(bearBandInput, 35), style = line.style_dotted, width = 1)
        guideLower := line.new(bar_index, lowerBand, bar_index + guideBarsInput, futureLower, color = color.new(bullBandInput, 35), style = line.style_dotted, width = 1)
    else
        if not na(guideMean)
            line.delete(guideMean)
            guideMean := na
        if not na(guideUpper)
            line.delete(guideUpper)
            guideUpper := na
        if not na(guideLower)
            line.delete(guideLower)
            guideLower := na

if showSignalsInput and longSignal
    label.new(bar_index, low, "LONG", color = #00000000, textcolor = JOAT_BULL, style = label.style_label_up, size = size.small)
if showSignalsInput and shortSignal
    label.new(bar_index, high, "SHORT", color = #00000000, textcolor = JOAT_BEAR, style = label.style_label_down, size = size.small)

alertcondition(longSignal, "Adaptive Long", "Adaptive Forecast Bands long signal on {{ticker}}")
alertcondition(shortSignal, "Adaptive Short", "Adaptive Forecast Bands short signal on {{ticker}}")

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------
var parsedDashPos = parsePos(dashPosInput)
var table dash = table.new(parsedDashPos, 2, 8, bgcolor = JOAT_PANEL, border_width = 0, frame_color = JOAT_BORDER, frame_width = 1)

if showDashInput and barstate.islast
    dash.merge_cells(0, 0, 1, 0)
    cell(dash, 0, 0, "Adaptive Forecast Bands [JOAT]", JOAT_TEXT, JOAT_PANEL, text.align_center)

    cell(dash, 0, 1, "Bias", JOAT_MID, na, text.align_left)
    cell(dash, 1, 1, str.tostring(biasScore, "#.##"), biasScore >= 0 ? JOAT_BULL : JOAT_BEAR, na, text.align_right)

    cell(dash, 0, 2, "Confidence", JOAT_MID, na, text.align_left)
    cell(dash, 1, 2, str.tostring(confidenceScore, "#.##") + "%", JOAT_TEXT, na, text.align_right)

    cell(dash, 0, 3, "Band Width", JOAT_MID, na, text.align_left)
    cell(dash, 1, 3, str.tostring(bandSpread, format.mintick), JOAT_TEXT, na, text.align_right)

    cell(dash, 0, 4, "Slope", JOAT_MID, na, text.align_left)
    cell(dash, 1, 4, str.tostring(beta1, "#.####"), beta1 >= 0 ? JOAT_BULL : JOAT_BEAR, na, text.align_right)

    cell(dash, 0, 5, "Guide", JOAT_MID, na, text.align_left)
    cell(dash, 1, 5, showGuideInput ? "On" : "Off", showGuideInput ? JOAT_BULL : JOAT_MID, na, text.align_right)

    cell(dash, 0, 6, "Signal State", JOAT_MID, na, text.align_left)
    cell(dash, 1, 6, longSignal ? "Long" : shortSignal ? "Short" : "Idle", longSignal ? JOAT_BULL : shortSignal ? JOAT_BEAR : JOAT_TEXT, na, text.align_right)

    cell(dash, 0, 7, "Rebase", JOAT_MID, na, text.align_left)
    cell(dash, 1, 7, str.tostring(rebaseInput), JOAT_TEXT, na, text.align_right)
````
