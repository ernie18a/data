# Covenant Regime Register [JOAT]

- url: https://www.tradingview.com/script/KvJGdrIe-Covenant-Regime-Register-JOAT/
- type: indicator
- pine_id: PUB;36882a6ac10a454e88f4d0492241eff9
- version: 1.0

## Description

[b]Covenant Regime Register [JOAT][/b]

[b]Introduction[/b]

Covenant Regime Register is an open-source market context indicator that classifies whether price is currently behaving like a directional auction or a rotational auction. Instead of treating trend detection as a single yes-or-no output, the script builds two competing probability streams and continuously updates which state has stronger evidence.

The problem this indicator solves is context drift. Many tools are applied the same way in every environment even though trending conditions and ranging conditions reward very different decisions. Covenant Regime Register separates those environments first, then exposes confidence, directional efficiency, and bias so the trader can decide whether to lean into continuation logic or step back into rotation logic.

[image]https://www.tradingview.com/x/k9jyDAtO/[/image]

[b]Core Concepts[/b]

[b]1. Multi-factor regime observations[/b]

The regime engine does not rely on one input. It blends normalized returns, normalized volatility, directional efficiency, and slope persistence into a two-state regime model:

[pine]
logReturn      = math.log(close / nz(close[1], close))
realizedVol    = ta.stdev(logReturn, volatilityLength)
efficiencyRatio = math.abs(close - close[efficiencyLength]) / math.sum(math.abs(ta.change(close)), efficiencyLength)
[/pine]

This keeps the classification grounded in both movement quality and volatility behavior.

[b]2. Probabilistic state competition[/b]

Directional and rotational states each receive an emission score. Those scores are then smoothed through a persistence-heavy probability engine so the output does not flip on every small fluctuation:

[pine]
posteriorTrend = emissionTrend * priorTrend
posteriorRange = emissionRange * priorRange
trendProb := trendProb + learningInput * (targetTrend - trendProb)
[/pine]

The result is a stable state register rather than a noisy binary switch.

[b]3. Confidence-aware classification[/b]

The script only considers a regime confirmed when the dominant state exceeds the user-defined confidence threshold on a confirmed bar. This helps reduce false transitions during temporary turbulence.

[b]4. Probability spread visualization[/b]

Trend probability and range probability are plotted together, while the spread between them is shaded as a separate area. This lets the user see whether the market is decisively one-sided or only marginally biased.

[b]5. Institutional dashboard[/b]

The top-right dashboard reports current state, confirmation status, trend probability, range probability, efficiency, and directional bias using a restrained dark palette designed to stay readable on a clean chart.

[b]Features[/b]

[list]
[*][b]Two-state regime model:[/b] Directional auction versus rotational auction
[*][b]Multi-factor classification:[/b] Uses returns, volatility, efficiency, and slope instead of a single oscillator threshold
[*][b]Probability outputs:[/b] Trend and range are shown as separate probability streams
[*][b]Confidence gate:[/b] Regimes are only considered confirmed above the user-defined threshold
[*][b]Spread visualization:[/b] Shows the separation between the two competing states
[*][b]Dark institutional dashboard:[/b] Compact top-right panel with current state and supporting metrics
[*][b]Confirmed-bar regime alerts:[/b] Alerts only fire when a new regime is confirmed on bar close
[*][b]Non-repainting design:[/b] Uses only current-timeframe information and confirmed-bar state transitions
[/list]

[b]Input Parameters[/b]

[b]Regime Engine:[/b]
[list]
[*]Return Lookback: Smoothing window for the return series
[*]Volatility Lookback: Window used to normalize realized volatility
[*]Efficiency Length: Measures directional travel versus rotational travel
[*]Probability Learning: Controls how quickly the posterior probabilities adapt
[*]Trend Confirmation Threshold: Minimum dominant probability required before a regime is treated as confirmed
[/list]

[b]Visual System:[/b]
[list]
[*]Show Regime Backdrop
[*]Show Probability Spread
[*]Show State Ribbon
[*]Show Dashboard
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the dominant state[/b]
If Trend Probability is above Range Probability and the confidence threshold is met, the market is behaving more directionally. If Range Probability dominates, the market is behaving more rotationally.

[b]Step 2: Check confirmation[/b]
Use the confirmation state before treating the output as actionable. Developing readings can still change as the current bar closes.

[b]Step 3: Use efficiency and bias together[/b]
High efficiency with strong directional bias supports continuation logic. Low efficiency with range dominance supports mean-reversion or lower-aggression decision making.

[b]Step 4: Apply it as a filter[/b]
This indicator is best used as a context layer for other tools. It is not intended to predict the next bar by itself.

[b]Indicator Limitations[/b]

[list]
[*]Regime models classify the present environment; they do not forecast future direction
[*]Extremely fast reversals can temporarily lower confidence before the new state stabilizes
[*]Range and trend can overlap during transition periods, so marginal readings should be treated cautiously
[/list]

[b]Originality Statement[/b]

Covenant Regime Register is original in how it combines normalized return behavior, normalized volatility, directional efficiency, and slope persistence into a compact two-state probability register with an explicit confidence gate. It is published because:

[list]
[*]The script produces competing regime probabilities rather than a single trend flag
[*]The classification emphasizes state persistence and bar-close confirmation instead of hyper-reactive regime flipping
[*]The dashboard surfaces regime context in a compact format suitable for use as a decision filter alongside other indicators
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice and does not guarantee future market behavior. All regime classifications are derived from historical and current price behavior and can produce false or delayed readings. Always use independent judgment and proper risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Covenant Regime Register [JOAT]", "CRR [JOAT]", overlay = false, max_bars_back = 1500)

//--------------------------------------------------------------------------------------------------
// Intent
//--------------------------------------------------------------------------------------------------
// Covenant Regime Register [JOAT]
// This pane indicator classifies the active market environment by blending:
// 1. persistence of returns,
// 2. normalized volatility,
// 3. directional efficiency,
// 4. a smooth probabilistic state engine.
//
// The design avoids repainting by using only confirmed current-timeframe information.
// It does not use future references or higher-timeframe lookahead.

//--------------------------------------------------------------------------------------------------
// Constants
//--------------------------------------------------------------------------------------------------
color BULL_CORE      = #0c9b7a
color BEAR_CORE      = #d14b5a
color RANGE_CORE     = #6f7d8c
color NEUTRAL_CORE   = #8b95a3
color ACCENT_GOLD    = #d5a021
color ACCENT_BLUE    = #4f7cff
color PANEL_BG       = #11161d
color PANEL_BORDER   = #2a3340
color PANEL_TEXT     = #d7dee8
color PANEL_HEADER   = #8d99a7
color PANEL_DIM      = #556070
color GLOW_BLUE      = #79a7ff
color GLOW_GREEN     = #3be0bb
color GLOW_RED       = #ff7283
color GLOW_GOLD      = #f3c86e

//--------------------------------------------------------------------------------------------------
// Helpers
//--------------------------------------------------------------------------------------------------
clampFloat(float value, float floorValue, float ceilingValue) =>
    math.max(floorValue, math.min(ceilingValue, value))

nzDiv(float numerator, float denominator) =>
    denominator == 0.0 ? 0.0 : numerator / denominator

mixColor(color a, color b, float weight) =>
    color.from_gradient(clampFloat(weight, 0.0, 1.0), 0.0, 1.0, a, b)

formatPct(float v) =>
    str.tostring(v, "0.0") + "%"

//--------------------------------------------------------------------------------------------------
// Inputs
//--------------------------------------------------------------------------------------------------
string ENGINE_GROUP       = "Regime Engine"
int returnLengthInput     = input.int(34, "Return Lookback", minval = 10, group = ENGINE_GROUP)
int volatilityLengthInput = input.int(55, "Volatility Lookback", minval = 20, group = ENGINE_GROUP)
int efficiencyLengthInput = input.int(21, "Efficiency Length", minval = 5, group = ENGINE_GROUP)
float learningInput       = input.float(0.22, "Probability Learning", minval = 0.05, maxval = 0.95, step = 0.01, group = ENGINE_GROUP)
float confidenceGateInput = input.float(60.0, "Trend Confirmation Threshold", minval = 50.0, maxval = 95.0, step = 0.5, group = ENGINE_GROUP)

string VISUAL_GROUP       = "Visual System"
bool showBackdropInput    = input.bool(true, "Show Regime Backdrop", group = VISUAL_GROUP)
bool showSpreadInput      = input.bool(true, "Show Probability Spread", group = VISUAL_GROUP)
bool showStateRibbonInput = input.bool(true, "Show State Ribbon", group = VISUAL_GROUP)
bool tintCandlesInput     = input.bool(true, "Tint Candles", group = VISUAL_GROUP)
bool showDashboardInput   = input.bool(true, "Show Dashboard", group = VISUAL_GROUP)

//--------------------------------------------------------------------------------------------------
// Observation Layer
//--------------------------------------------------------------------------------------------------
float logReturn           = math.log(close / nz(close[1], close))
float driftMean           = ta.ema(logReturn, returnLengthInput)
float realizedVol         = ta.stdev(logReturn, volatilityLengthInput)
float volBaseline         = ta.ema(realizedVol, volatilityLengthInput)
float normalizedReturn    = nzDiv(logReturn - driftMean, realizedVol + 1e-9)
float normalizedVol       = nzDiv(realizedVol, volBaseline + 1e-9)

float directionalTravel   = math.abs(close - close[efficiencyLengthInput])
float rotationalTravel    = math.sum(math.abs(ta.change(close)), efficiencyLengthInput)
float efficiencyRatio     = clampFloat(nzDiv(directionalTravel, rotationalTravel), 0.0, 1.0)

float trendSlopeFast      = ta.ema(close, 21) - ta.ema(close, 34)
float trendSlopeSlow      = ta.ema(close, 55) - ta.ema(close, 89)
float slopeBlend          = nzDiv(trendSlopeFast + trendSlopeSlow, close * 0.01)
float slopeScore          = clampFloat(math.abs(slopeBlend) * 35.0, 0.0, 1.0)

//--------------------------------------------------------------------------------------------------
// Emission Layer
//--------------------------------------------------------------------------------------------------
float trendEmissionReturn = math.exp(-math.pow(math.abs(normalizedReturn) - 0.90, 2.0) / 1.40)
float trendEmissionVol    = math.exp(-math.pow(normalizedVol - 1.15, 2.0) / 0.70)
float trendEmissionEff    = math.exp(-math.pow(efficiencyRatio - 0.72, 2.0) / 0.10)
float trendEmissionSlope  = clampFloat(0.35 + slopeScore, 0.0, 1.0)

float rangeEmissionReturn = math.exp(-math.pow(math.abs(normalizedReturn) - 0.15, 2.0) / 0.70)
float rangeEmissionVol    = math.exp(-math.pow(normalizedVol - 0.82, 2.0) / 0.40)
float rangeEmissionEff    = math.exp(-math.pow(efficiencyRatio - 0.22, 2.0) / 0.08)
float rangeEmissionSlope  = clampFloat(1.10 - slopeScore, 0.0, 1.0)

float emissionTrend       = math.max(1e-6, trendEmissionReturn * trendEmissionVol * trendEmissionEff * trendEmissionSlope)
float emissionRange       = math.max(1e-6, rangeEmissionReturn * rangeEmissionVol * rangeEmissionEff * rangeEmissionSlope)

//--------------------------------------------------------------------------------------------------
// Probability Engine
//--------------------------------------------------------------------------------------------------
var float trendProb       = 0.50
var float rangeProb       = 0.50

float persistenceTrend    = 0.92 + efficiencyRatio * 0.04
float persistenceRange    = 0.92 + (1.0 - efficiencyRatio) * 0.04
float transitionToTrend   = 1.0 - persistenceRange
float transitionToRange   = 1.0 - persistenceTrend

if not na(logReturn)
    float priorTrend      = trendProb * persistenceTrend + rangeProb * transitionToTrend
    float priorRange      = rangeProb * persistenceRange + trendProb * transitionToRange
    float posteriorTrend  = emissionTrend * priorTrend
    float posteriorRange  = emissionRange * priorRange
    float posteriorTotal  = posteriorTrend + posteriorRange

    if posteriorTotal > 0
        float targetTrend = posteriorTrend / posteriorTotal
        float targetRange = posteriorRange / posteriorTotal
        trendProb        := trendProb + learningInput * (targetTrend - trendProb)
        rangeProb        := rangeProb + learningInput * (targetRange - rangeProb)

float probabilityTotal    = trendProb + rangeProb
trendProb                 := probabilityTotal == 0 ? 0.5 : trendProb / probabilityTotal
rangeProb                 := probabilityTotal == 0 ? 0.5 : rangeProb / probabilityTotal

float trendPercent        = trendProb * 100.0
float rangePercent        = rangeProb * 100.0
float confidencePercent   = math.max(trendPercent, rangePercent)
float dominanceSpread     = trendPercent - rangePercent
bool trendDominant        = trendPercent > rangePercent
bool regimeConfirmed      = barstate.isconfirmed and confidencePercent >= confidenceGateInput

string stateText          = trendDominant ? "Directional Auction" : "Rotational Auction"
color stateColor          = trendDominant ? (dominanceSpread >= 0 ? BULL_CORE : BEAR_CORE) : RANGE_CORE

//--------------------------------------------------------------------------------------------------
// Secondary Metrics
//--------------------------------------------------------------------------------------------------
float momentumSignature   = clampFloat((normalizedReturn + 2.5) / 5.0, 0.0, 1.0) * 100.0
float efficiencyPercent   = efficiencyRatio * 100.0
float volatilityPercent   = clampFloat(normalizedVol / 2.0, 0.0, 1.0) * 100.0
float directionalBias     = clampFloat(50.0 + slopeBlend * 150.0, 0.0, 100.0)

//--------------------------------------------------------------------------------------------------
// Plots
//--------------------------------------------------------------------------------------------------
plotTrend = plot(trendPercent, "Trend Probability", color = ACCENT_BLUE, linewidth = 2)
plotRange = plot(rangePercent, "Range Probability", color = RANGE_CORE, linewidth = 2)
plotMid   = plot(50, "Neutral Threshold", color = color.new(PANEL_HEADER, 65), linewidth = 1)
plotZero  = plot(0, "Zero", color = color.new(PANEL_BG, 100), display = display.none)

fill(plotTrend, plotZero, trendPercent, 0, color.new(ACCENT_BLUE, 55), color.new(ACCENT_BLUE, 100), title = "Trend Confidence Fill")
fill(plotRange, plotZero, rangePercent, 0, color.new(RANGE_CORE, 60), color.new(RANGE_CORE, 100), title = "Range Confidence Fill")

plot(showSpreadInput ? dominanceSpread + 50.0 : na, "Probability Spread", color = color.new(trendDominant ? BULL_CORE : BEAR_CORE, 72), linewidth = 2, style = plot.style_area)
plot(showStateRibbonInput ? confidencePercent : na, "State Ribbon", color = mixColor(RANGE_CORE, trendDominant ? BULL_CORE : BEAR_CORE, confidencePercent / 100.0), linewidth = 4, style = plot.style_stepline)

hline(80, "High Conviction", color.new(ACCENT_GOLD, 40), hline.style_dotted)
hline(60, "Action Threshold", color.new(PANEL_HEADER, 65), hline.style_dashed)
hline(40, "Rotation Threshold", color.new(PANEL_HEADER, 80), hline.style_dashed)
hline(20, "Compression Floor", color.new(PANEL_HEADER, 88), hline.style_dotted)

bgcolor(showBackdropInput ? color.new(trendDominant ? BULL_CORE : RANGE_CORE, regimeConfirmed ? 92 : 96) : na, title = "Backdrop")
barcolor(tintCandlesInput ? color.new(trendDominant ? (dominanceSpread >= 0 ? GLOW_GREEN : GLOW_RED) : GLOW_BLUE, regimeConfirmed ? 0 : 50) : na)

//--------------------------------------------------------------------------------------------------
// State Signals
//--------------------------------------------------------------------------------------------------
bool confirmedTrendRegime = regimeConfirmed and trendDominant
bool confirmedRangeRegime = regimeConfirmed and not trendDominant
bool regimeTurnUp         = barstate.isconfirmed and confirmedTrendRegime and not confirmedTrendRegime[1]
bool regimeTurnRange      = barstate.isconfirmed and confirmedRangeRegime and not confirmedRangeRegime[1]

plotshape(regimeTurnUp ? 82 : na, "Trend Pulse", shape.circle, location.absolute, color.new(GLOW_GREEN, 0), size = size.tiny)
plotshape(regimeTurnRange ? 18 : na, "Range Pulse", shape.circle, location.absolute, color.new(GLOW_GOLD, 0), size = size.tiny)

alertcondition(regimeTurnUp, "Trend Regime Confirmed", "Covenant Regime Register [JOAT] confirmed a directional auction regime.")
alertcondition(regimeTurnRange, "Range Regime Confirmed", "Covenant Regime Register [JOAT] confirmed a rotational auction regime.")

//--------------------------------------------------------------------------------------------------
// Dashboard
//--------------------------------------------------------------------------------------------------
var table dash = table.new(position.top_right, 2, 8, bgcolor = PANEL_BG, frame_color = PANEL_BORDER, frame_width = 1, border_width = 0)

cellHeader(table panel, int row, string left, string right, color rightColor) =>
    panel.cell(0, row, left, text_color = PANEL_HEADER, text_size = size.normal, text_halign = text.align_left)
    panel.cell(1, row, right, text_color = rightColor, text_size = size.normal, text_halign = text.align_right)

divider(table panel, int row) =>
    panel.merge_cells(0, row, 1, row)
    panel.cell(0, row, "--------------", text_color = PANEL_BORDER, text_size = size.normal, text_halign = text.align_center)

if barstate.islast
    if showDashboardInput
        color headerGlow = color.new(trendDominant ? GLOW_GREEN : GLOW_BLUE, 84)
        table.cell(dash, 0, 0, "Covenant Register", text_color = PANEL_TEXT, bgcolor = headerGlow, text_size = size.normal, text_halign = text.align_left)
        table.cell(dash, 1, 0, regimeConfirmed ? "Confirmed" : "Developing", text_color = regimeConfirmed ? GLOW_GOLD : PANEL_DIM, bgcolor = headerGlow, text_size = size.normal, text_halign = text.align_right)

        divider(dash, 1)

        table.cell_set_bgcolor(dash, 0, 2, color.new(stateColor, 92))
        table.cell_set_bgcolor(dash, 1, 2, color.new(stateColor, 92))
        cellHeader(dash, 2, "State", stateText, stateColor)
        table.cell_set_bgcolor(dash, 0, 3, color.new(ACCENT_BLUE, 93))
        table.cell_set_bgcolor(dash, 1, 3, color.new(ACCENT_BLUE, 93))
        cellHeader(dash, 3, "Trend Prob", formatPct(trendPercent), GLOW_BLUE)
        table.cell_set_bgcolor(dash, 0, 4, color.new(RANGE_CORE, 93))
        table.cell_set_bgcolor(dash, 1, 4, color.new(RANGE_CORE, 93))
        cellHeader(dash, 4, "Range Prob", formatPct(rangePercent), RANGE_CORE)

        divider(dash, 5)

        table.cell_set_bgcolor(dash, 0, 6, color.new(GLOW_GREEN, 94))
        table.cell_set_bgcolor(dash, 1, 6, color.new(GLOW_GREEN, 94))
        cellHeader(dash, 6, "Efficiency", formatPct(efficiencyPercent), mixColor(PANEL_DIM, GLOW_GREEN, efficiencyRatio))
        table.cell_set_bgcolor(dash, 0, 7, color.new(trendDominant ? GLOW_GREEN : GLOW_RED, 94))
        table.cell_set_bgcolor(dash, 1, 7, color.new(trendDominant ? GLOW_GREEN : GLOW_RED, 94))
        cellHeader(dash, 7, "Bias", formatPct(directionalBias), trendDominant ? GLOW_GREEN : GLOW_RED)
    else
        table.clear(dash, 0, 0, 1, 7)
````
