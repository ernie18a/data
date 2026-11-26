# Helix Trend Ensemble [JOAT]

- url: https://www.tradingview.com/script/dznPyAsh-Helix-Trend-Ensemble-JOAT/
- type: indicator
- pine_id: PUB;26b1363906494e5e8ccb586bbacb47dd
- version: 1.0

## Description

[b]Helix Trend Ensemble [JOAT][/b]

[b]Introduction[/b]

Helix Trend Ensemble is an open-source trend overlay built around a three-member weighted ensemble. Instead of relying on one moving average or one crossover, Helix evaluates multiple configurable members, normalizes slope behavior, and produces a consensus trend state only when enough internal agreement is present.

The problem Helix solves is false certainty. Single-line trend tools are easy to read but easy to break. Multi-line tools often create clutter without resolving disagreement. Helix is designed to preserve a clean chart while still exposing the quality of alignment between fast, intermediate, and structural trend engines.

[image]https://www.tradingview.com/x/u4FGMPCt/[/image]

[b]Core Concepts[/b]

[b]1. Multi-Member Trend Architecture[/b]

Three independent members can each use different MA types, smoothing methods, lengths, and weights. This allows the ensemble to mix responsiveness with structural stability.

[b]2. Weighted Consensus[/b]

The final state is not a simple majority vote. Each member contributes according to its configured weight, and the ensemble requires sufficient agreement before it promotes a directional state.

[b]3. Slope Normalization[/b]

Raw slope values are normalized so the dashboard can express trend energy in a stable way across different length combinations.

[b]4. Filter Layer[/b]

ATR and ADX filters help suppress weak trend states and reduce low-quality directional transitions.

[b]5. Confirmed Regime Transitions[/b]

Directional state changes are only recognized on confirmed bars, which keeps the ensemble consistent with real-time use.

[b]Features[/b]

[list]
[*][b]Three fully configurable members:[/b] Each member supports multiple MA and smoothing combinations
[*][b]Weighted consensus engine:[/b] Final state depends on internal agreement quality, not one crossover
[*][b]Normalized slope score:[/b] Slope behavior is translated into a stable strength readout
[*][b]Ribbon and cloud system:[/b] Trend geometry is expressed through layered fills instead of cluttered markers
[*][b]Optional candle coloring:[/b] Price bars can reflect the ensemble state without altering logic
[*][b]Top-right dashboard:[/b] Regime, consensus, strength, slope, agreement, filters, and last flip are summarized continuously
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read regime and consensus together[/b]
A bullish or bearish state is more meaningful when consensus is high and filters are passing.

[b]Step 2: Watch slope and strength[/b]
An aligned ensemble with weakening slope often signals late-trend conditions rather than fresh expansion.

[b]Step 3: Use Helix as a bias filter[/b]
Helix works well as a directional framework for execution models that need a clean trend gate.

[b]Indicator Limitations[/b]

[list]
[*]Longer member lengths will intentionally delay reversals
[*]High responsiveness settings can increase whipsaws
[*]Consensus does not eliminate all false trends; it only improves structural filtering
[*]The script is a trend-classification tool, not a full strategy
[/list]

[b]Originality Statement[/b]

Helix Trend Ensemble is original in the way it combines configurable member diversity, weighted consensus, slope normalization, and clean institutional visualization into one open-source trend framework.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Trend-state tools can fail during rapid reversals, compressed markets, or structurally irregular conditions. Use proper risk control at all times.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Helix Trend Ensemble [JOAT]", shorttitle="HTE [JOAT]", overlay=true, max_lines_count=200, max_labels_count=50)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------

string g_mode = "Operating Mode"
string g_theme = "Theme"
string g_member_a = "Helix Member A"
string g_member_b = "Helix Member B"
string g_member_c = "Helix Member C"
string g_filters = "Filters"
string g_visual = "Visuals"
string g_dash = "Dashboard"

string modeInput = input.string("Balanced", "Active Mode", options=["Recon", "Balanced", "Institutional"], group=g_mode,
     tooltip="Controls the strictness of consensus, the confirmation threshold, and how conservative the ensemble behaves.")

sourcePrice = input.source(close, "Source", group=g_mode)

bool showRibbon = input.bool(true, "Show Gradient Ribbon", group=g_visual)
bool showCloud = input.bool(true, "Show Trend Cloud", group=g_visual)
bool showBarColors = input.bool(true, "Color Candles", group=g_visual)
bool showCoreLine = input.bool(true, "Show Helix Spine", group=g_visual)
bool showMemberLines = input.bool(true, "Show Member Lines", group=g_visual)
bool showTransitionPulse = input.bool(true, "Show Transition Pulse", group=g_visual)

color bullBase = input.color(color.rgb(42, 220, 155), "Bull Core", group=g_theme)
color bearBase = input.color(color.rgb(255, 93, 116), "Bear Core", group=g_theme)
color neutralBase = input.color(color.rgb(111, 132, 170), "Neutral", group=g_theme)
color accentBase = input.color(color.rgb(81, 156, 255), "Accent", group=g_theme)
color backdropBase = input.color(color.rgb(10, 14, 24), "Backdrop", group=g_theme)

// Member A
string aType = input.string("EMA", "MA Type", options=["SMA", "EMA", "WMA", "VWMA", "RMA", "HMA", "DEMA", "TEMA", "ZLEMA", "ALMA", "LSMA"], group=g_member_a, inline="a1")
int aLen = input.int(21, "Length", minval=1, group=g_member_a, inline="a1")
string aSmooth = input.string("EMA", "Smoothing", options=["None", "EMA", "RMA", "HMA", "ZLEMA", "LSMA"], group=g_member_a, inline="a2")
int aSmoothLen = input.int(5, "Smooth Len", minval=1, group=g_member_a, inline="a2")
float aWeight = input.float(1.0, "Weight", minval=0.0, step=0.1, group=g_member_a)

// Member B
string bType = input.string("HMA", "MA Type", options=["SMA", "EMA", "WMA", "VWMA", "RMA", "HMA", "DEMA", "TEMA", "ZLEMA", "ALMA", "LSMA"], group=g_member_b, inline="b1")
int bLen = input.int(55, "Length", minval=1, group=g_member_b, inline="b1")
string bSmooth = input.string("RMA", "Smoothing", options=["None", "EMA", "RMA", "HMA", "ZLEMA", "LSMA"], group=g_member_b, inline="b2")
int bSmoothLen = input.int(5, "Smooth Len", minval=1, group=g_member_b, inline="b2")
float bWeight = input.float(1.25, "Weight", minval=0.0, step=0.1, group=g_member_b)

// Member C
string cType = input.string("RMA", "MA Type", options=["SMA", "EMA", "WMA", "VWMA", "RMA", "HMA", "DEMA", "TEMA", "ZLEMA", "ALMA", "LSMA"], group=g_member_c, inline="c1")
int cLen = input.int(144, "Length", minval=1, group=g_member_c, inline="c1")
string cSmooth = input.string("EMA", "Smoothing", options=["None", "EMA", "RMA", "HMA", "ZLEMA", "LSMA"], group=g_member_c, inline="c2")
int cSmoothLen = input.int(8, "Smooth Len", minval=1, group=g_member_c, inline="c2")
float cWeight = input.float(1.5, "Weight", minval=0.0, step=0.1, group=g_member_c)

// Filters and confirmation controls
int adxLen = input.int(14, "ADX Length", minval=2, group=g_filters, inline="f1")
int adxSmooth = input.int(14, "ADX Smooth", minval=2, group=g_filters, inline="f1")
int atrLen = input.int(21, "ATR Length", minval=2, group=g_filters, inline="f2")
int atrBaseLen = input.int(55, "ATR Base", minval=5, group=g_filters, inline="f2")
int slopeLookback = input.int(5, "Slope Lookback", minval=1, group=g_filters, inline="f3")
int minAgreement = input.int(2, "Minimum Agreement", minval=1, maxval=3, group=g_filters, inline="f3")
float atrFloor = input.float(0.90, "ATR Floor", minval=0.1, step=0.05, group=g_filters)

// Dashboard
bool showDashboard = input.bool(true, "Show Dashboard", group=g_dash)
string dashSizeInput = input.string("Normal", "Dashboard Size", options=["Compact", "Normal", "Medium"], group=g_dash)

//------------------------------------------------------------------------------
// Utility functions
//------------------------------------------------------------------------------

f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_safeDiv(float num, float den) =>
    den != 0.0 ? num / den : 0.0

f_zlema(float src, int len) =>
    int l = math.max(1, len)
    int lag = math.floor((l - 1) / 2)
    ta.ema(src + (src - src[lag]), l)

f_dema(float src, int len) =>
    int l = math.max(1, len)
    float ema1 = ta.ema(src, l)
    float ema2 = ta.ema(ema1, l)
    2.0 * ema1 - ema2

f_tema(float src, int len) =>
    int l = math.max(1, len)
    float ema1 = ta.ema(src, l)
    float ema2 = ta.ema(ema1, l)
    float ema3 = ta.ema(ema2, l)
    3.0 * ema1 - 3.0 * ema2 + ema3

f_ma(float src, int len, string maType) =>
    int l = math.max(1, len)
    float smaValue = ta.sma(src, l)
    float emaValue = ta.ema(src, l)
    float wmaValue = ta.wma(src, l)
    float vwmaValue = ta.vwma(src, l)
    float rmaValue = ta.rma(src, l)
    float hmaValue = ta.hma(src, l)
    float demaValue = f_dema(src, l)
    float temaValue = f_tema(src, l)
    float zlemaValue = f_zlema(src, l)
    float almaValue = ta.alma(src, l, 0.85, 6.0)
    float lsmaValue = ta.linreg(src, l, 0)
    float selected = emaValue
    switch maType
        "SMA"   => selected := smaValue
        "EMA"   => selected := emaValue
        "WMA"   => selected := wmaValue
        "VWMA"  => selected := vwmaValue
        "RMA"   => selected := rmaValue
        "HMA"   => selected := hmaValue
        "DEMA"  => selected := demaValue
        "TEMA"  => selected := temaValue
        "ZLEMA" => selected := zlemaValue
        "ALMA"  => selected := almaValue
        "LSMA"  => selected := lsmaValue
        => selected := emaValue
    selected

f_smoother(float src, int len, string smoothType) =>
    int l = math.max(1, len)
    float emaValue = ta.ema(src, l)
    float rmaValue = ta.rma(src, l)
    float hmaValue = ta.hma(src, l)
    float zlemaValue = f_zlema(src, l)
    float lsmaValue = ta.linreg(src, l, 0)
    float selected = src
    switch smoothType
        "None"  => selected := src
        "EMA"   => selected := emaValue
        "RMA"   => selected := rmaValue
        "HMA"   => selected := hmaValue
        "ZLEMA" => selected := zlemaValue
        "LSMA"  => selected := lsmaValue
        => selected := src
    selected

f_memberPack(float src, int len, string maType, string smoothType, int smoothLen) =>
    float raw = f_ma(src, len, maType)
    f_smoother(raw, smoothLen, smoothType)

f_normSlope(float value, int lookback, float atrRef) =>
    float slope = value - value[lookback]
    float scale = math.max(atrRef * 0.5, 0.0001)
    f_clamp(slope / scale, -1.0, 1.0)

f_biasColor(int bias, float strength, color bull, color bear, color neutral) =>
    if bias > 0
        color.from_gradient(strength, 0.0, 1.0, color.new(neutral, 70), bull)
    else if bias < 0
        color.from_gradient(strength, 0.0, 1.0, color.new(neutral, 70), bear)
    else
        color.new(neutral, 50)

f_strengthLabel(float score) =>
    string labelText = "Diffuse"
    if score >= 80
        labelText := "Dominant"
    else if score >= 65
        labelText := "Strong"
    else if score >= 45
        labelText := "Balanced"
    else if score >= 25
        labelText := "Soft"
    labelText

f_biasText(int bias) =>
    bias > 0 ? "Bullish" : bias < 0 ? "Bearish" : "Neutral"

f_modeEnterThreshold(string mode) =>
    switch mode
        "Recon"          => 0.26
        "Balanced"       => 0.34
        "Institutional"  => 0.46
        => 0.34

f_modeExitThreshold(string mode) =>
    switch mode
        "Recon"          => 0.16
        "Balanced"       => 0.22
        "Institutional"  => 0.30
        => 0.22

f_modeAdxThreshold(string mode) =>
    switch mode
        "Recon"          => 15.0
        "Balanced"       => 20.0
        "Institutional"  => 24.0
        => 20.0

f_modeAtrFloor(string mode, float floorInput) =>
    switch mode
        "Recon"          => math.max(0.75, floorInput - 0.10)
        "Balanced"       => floorInput
        "Institutional"  => math.min(1.20, floorInput + 0.08)
        => floorInput

//------------------------------------------------------------------------------
// Core calculations
//------------------------------------------------------------------------------

float helixA = f_memberPack(sourcePrice, aLen, aType, aSmooth, aSmoothLen)
float helixB = f_memberPack(sourcePrice, bLen, bType, bSmooth, bSmoothLen)
float helixC = f_memberPack(sourcePrice, cLen, cType, cSmooth, cSmoothLen)

// Core adaptive spine: weighted average of the three members.
float helixWeightTotal = math.max(aWeight + bWeight + cWeight, 0.0001)
float helixSpine = (helixA * aWeight + helixB * bWeight + helixC * cWeight) / helixWeightTotal

float atrValue = ta.atr(atrLen)
float atrBasis = ta.sma(atrValue, atrBaseLen)
float atrRatio = f_safeDiv(atrValue, atrBasis)

[diPlus, diMinus, adxValue] = ta.dmi(adxLen, adxSmooth)

// Per-member directional votes.
float slopeA = f_normSlope(helixA, slopeLookback, atrValue)
float slopeB = f_normSlope(helixB, slopeLookback, atrValue)
float slopeC = f_normSlope(helixC, slopeLookback, atrValue)

int dirA = slopeA > 0 ? 1 : slopeA < 0 ? -1 : 0
int dirB = slopeB > 0 ? 1 : slopeB < 0 ? -1 : 0
int dirC = slopeC > 0 ? 1 : slopeC < 0 ? -1 : 0

float confA = math.abs(slopeA)
float confB = math.abs(slopeB)
float confC = math.abs(slopeC)

float voteA = dirA * aWeight * (0.35 + 0.65 * confA)
float voteB = dirB * bWeight * (0.35 + 0.65 * confB)
float voteC = dirC * cWeight * (0.35 + 0.65 * confC)

float voteTotal = math.max(helixWeightTotal, 0.0001)
float consensusRaw = f_safeDiv(voteA + voteB + voteC, voteTotal)
float alignmentScore = f_clamp(math.abs((dirA + dirB + dirC) / 3.0), 0.0, 1.0)
int bullAgreement = (dirA > 0 ? 1 : 0) + (dirB > 0 ? 1 : 0) + (dirC > 0 ? 1 : 0)
int bearAgreement = (dirA < 0 ? 1 : 0) + (dirB < 0 ? 1 : 0) + (dirC < 0 ? 1 : 0)
int leadAgreement = math.max(bullAgreement, bearAgreement)

// Mode controls the entry and exit thresholds.
float enterThreshold = f_modeEnterThreshold(modeInput)
float exitThreshold = f_modeExitThreshold(modeInput)
float adxThreshold = f_modeAdxThreshold(modeInput)
float atrFloorMode = f_modeAtrFloor(modeInput, atrFloor)

// Filter stack: trend strength, volatility sufficiency, and agreement.
bool trendFilterPass = adxValue >= adxThreshold
bool volatilityFilterPass = atrRatio >= atrFloorMode
bool agreementFilterPass = leadAgreement >= minAgreement
bool filterPass = trendFilterPass and volatilityFilterPass and agreementFilterPass

// Envelope / trend cloud around the spine.
float helixStrengthRaw = f_clamp(math.abs(consensusRaw), 0.0, 1.0)
float helixStrengthPct = helixStrengthRaw * 100.0
float helixBandScale = 0.55 + (1.0 - helixStrengthRaw) * 1.25
float helixBandWidth = atrValue * helixBandScale

float helixUpper = helixSpine + helixBandWidth
float helixLower = helixSpine - helixBandWidth

// Consensus direction is a locked regime, changed only on confirmed bars.
var int helixDirection = 0
var float lastFlipPrice = na
var int lastFlipBar = na
var int barsInState = 0

bool strongBull = consensusRaw >= enterThreshold and bullAgreement >= minAgreement and filterPass
bool strongBear = consensusRaw <= -enterThreshold and bearAgreement >= minAgreement and filterPass
bool weakNeutral = math.abs(consensusRaw) <= exitThreshold

bool confirmedFlipBull = barstate.isconfirmed and strongBull and helixDirection != 1
bool confirmedFlipBear = barstate.isconfirmed and strongBear and helixDirection != -1
bool confirmedNeutralReset = barstate.isconfirmed and weakNeutral and helixDirection != 0 and not strongBull and not strongBear

if barstate.isconfirmed
    if confirmedFlipBull
        helixDirection := 1
        lastFlipPrice := close
        lastFlipBar := bar_index
        barsInState := 0
    else if confirmedFlipBear
        helixDirection := -1
        lastFlipPrice := close
        lastFlipBar := bar_index
        barsInState := 0
    else if confirmedNeutralReset
        helixDirection := 0
        barsInState := 0
    else
        barsInState += 1

// Secondary instant state used for coloring and informational context.
int instantBias = consensusRaw > enterThreshold ? 1 : consensusRaw < -enterThreshold ? -1 : 0

float slopeBlend = f_safeDiv(slopeA + slopeB + slopeC, 3.0)
float slopeScore = f_clamp(math.abs(slopeBlend), 0.0, 1.0)
float stateScore = f_clamp(helixStrengthRaw * 0.55 + alignmentScore * 0.25 + slopeScore * 0.20, 0.0, 1.0)
float strengthScore = stateScore * 100.0

// Build a single regime verdict used by the dashboard and alerts.
string regimeText = helixDirection == 1 ? "Bull Regime" : helixDirection == -1 ? "Bear Regime" : "Neutral Regime"
string filterText = filterPass ? "PASS" : "BLOCK"
string alignmentText = leadAgreement == 3 ? "Tight" : leadAgreement == 2 ? "Balanced" : "Loose"

// Color design system.
color regimeColor = f_biasColor(helixDirection != 0 ? helixDirection : instantBias, stateScore, bullBase, bearBase, neutralBase)
color ribbonCoreColor = color.from_gradient(helixStrengthPct, 0.0, 100.0, color.new(neutralBase, 80), regimeColor)
color spineColor = helixDirection == 1 ? color.new(bullBase, 0) : helixDirection == -1 ? color.new(bearBase, 0) : color.new(accentBase, 0)
color transitionColor = helixDirection == 1 ? color.new(bullBase, 88) : helixDirection == -1 ? color.new(bearBase, 88) : na

//------------------------------------------------------------------------------
// Visual layers
//------------------------------------------------------------------------------

float helixCorePlot = showCoreLine ? helixSpine : na
float helixUpperPlot = showCloud ? helixUpper : na
float helixLowerPlot = showCloud ? helixLower : na

float memberAPlot = showMemberLines ? helixA : na
float memberBPlot = showMemberLines ? helixB : na
float memberCPlot = showMemberLines ? helixC : na

plot(memberAPlot, "Helix A", color=f_biasColor(dirA, confA, bullBase, bearBase, neutralBase), linewidth=2)
plot(memberBPlot, "Helix B", color=f_biasColor(dirB, confB, bullBase, bearBase, neutralBase), linewidth=2)
plot(memberCPlot, "Helix C", color=f_biasColor(dirC, confC, bullBase, bearBase, neutralBase), linewidth=2)

plot(helixCorePlot, "Helix Spine", color=spineColor, linewidth=3)

upperAnchor = plot(helixUpperPlot, "Helix Upper", color=color.new(ribbonCoreColor, 100), display=display.none)
lowerAnchor = plot(helixLowerPlot, "Helix Lower", color=color.new(ribbonCoreColor, 100), display=display.none)
fill(upperAnchor, lowerAnchor, color=color.new(regimeColor, int(math.round(f_clamp(90.0 - strengthScore * 0.45, 10.0, 92.0)))), title="Helix Cloud")

// Gradient ribbon between the inner members.
aPlot = plot(showRibbon ? helixA : na, "Ribbon A", color=color.new(regimeColor, 100), display=display.none)
bPlot = plot(showRibbon ? helixB : na, "Ribbon B", color=color.new(regimeColor, 100), display=display.none)
cPlot = plot(showRibbon ? helixC : na, "Ribbon C", color=color.new(regimeColor, 100), display=display.none)

color ribbonAB = color.new(f_biasColor(helixDirection != 0 ? helixDirection : instantBias, stateScore, bullBase, bearBase, neutralBase), int(math.round(f_clamp(92.0 - strengthScore * 0.30, 15.0, 95.0))))
color ribbonBC = color.new(f_biasColor(helixDirection != 0 ? helixDirection : instantBias, stateScore * 0.95, bullBase, bearBase, neutralBase), int(math.round(f_clamp(94.0 - strengthScore * 0.25, 18.0, 96.0))))
color ribbonAC = color.new(color.from_gradient(helixStrengthPct, 0.0, 100.0, color.new(neutralBase, 88), regimeColor), int(math.round(f_clamp(95.0 - strengthScore * 0.20, 20.0, 97.0))))
color ribbonABFill = showRibbon ? ribbonAB : na
color ribbonBCFill = showRibbon ? ribbonBC : na
color ribbonACFill = showRibbon ? ribbonAC : na

fill(aPlot, bPlot, color=ribbonABFill, title="Ribbon A-B")
fill(bPlot, cPlot, color=ribbonBCFill, title="Ribbon B-C")
fill(aPlot, cPlot, color=ribbonACFill, title="Ribbon A-C")

// Optional candle coloring. Uses the locked regime when available, otherwise the instant bias.
int candleBias = helixDirection != 0 ? helixDirection : instantBias
color candleColor = f_biasColor(candleBias, stateScore, bullBase, bearBase, neutralBase)
barcolor(showBarColors ? candleColor : na)

// Subtle transition pulse when the locked state changes on a confirmed bar.
bgcolor(showTransitionPulse and (confirmedFlipBull or confirmedFlipBear) ? transitionColor : na, title="Transition Pulse")

//------------------------------------------------------------------------------
// Alerts and state events
//------------------------------------------------------------------------------

alertcondition(confirmedFlipBull, title="Helix Bull Transition", message="Helix Trend Ensemble: confirmed bullish regime shift on {{ticker}} {{interval}}")
alertcondition(confirmedFlipBear, title="Helix Bear Transition", message="Helix Trend Ensemble: confirmed bearish regime shift on {{ticker}} {{interval}}")
alertcondition(confirmedNeutralReset, title="Helix Neutral Reset", message="Helix Trend Ensemble: confirmed neutral reset on {{ticker}} {{interval}}")

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------

bool compactDash = dashSizeInput == "Compact"
var table helixDash = table.new(position.top_right, 2, 8, bgcolor=color.new(backdropBase, 8), border_color=color.new(neutralBase, 75), border_width=1, frame_color=color.new(neutralBase, 75), frame_width=1)

if showDashboard and barstate.islast
    color headerBg = color.new(accentBase, 72)
    color sectionBg = color.new(color.rgb(24, 31, 46), 18)
    color rowBg = color.new(color.rgb(16, 21, 32), 0)
    color scoreColor = helixDirection == 1 ? bullBase : helixDirection == -1 ? bearBase : neutralBase
    color filterColor = filterPass ? bullBase : bearBase

    table.cell(helixDash, 0, 0, "HELIX ENSEMBLE", bgcolor=headerBg, text_color=color.white, text_size=size.small, text_halign=text.align_center)
    table.cell(helixDash, 1, 0, modeInput, bgcolor=color.new(headerBg, 0), text_color=accentBase, text_size=size.small, text_halign=text.align_center)

    table.cell(helixDash, 0, 1, "Regime", bgcolor=sectionBg, text_color=color.new(neutralBase, 15), text_size=size.tiny)
    table.cell(helixDash, 1, 1, regimeText, bgcolor=color.new(scoreColor, 82), text_color=scoreColor, text_size=size.tiny, text_halign=text.align_center)

    table.cell(helixDash, 0, 2, "Consensus", bgcolor=sectionBg, text_color=color.new(neutralBase, 15), text_size=size.tiny)
    table.cell(helixDash, 1, 2, str.tostring(consensusRaw * 100.0, "#.0") + "%", bgcolor=rowBg, text_color=regimeColor, text_size=size.tiny, text_halign=text.align_center)

    table.cell(helixDash, 0, 3, "Strength", bgcolor=sectionBg, text_color=color.new(neutralBase, 15), text_size=size.tiny)
    table.cell(helixDash, 1, 3, f_strengthLabel(strengthScore) + " " + str.tostring(strengthScore, "#.0"), bgcolor=rowBg, text_color=regimeColor, text_size=size.tiny, text_halign=text.align_center)

    table.cell(helixDash, 0, 4, "Slope", bgcolor=sectionBg, text_color=color.new(neutralBase, 15), text_size=size.tiny)
    table.cell(helixDash, 1, 4, str.tostring(slopeBlend * 100.0, "#.0") + " / 100", bgcolor=rowBg, text_color=f_biasColor(candleBias, slopeScore, bullBase, bearBase, neutralBase), text_size=size.tiny, text_halign=text.align_center)

    table.cell(helixDash, 0, 5, "Agreement", bgcolor=sectionBg, text_color=color.new(neutralBase, 15), text_size=size.tiny)
    table.cell(helixDash, 1, 5, alignmentText + " " + str.tostring(leadAgreement) + "/3", bgcolor=rowBg, text_color=accentBase, text_size=size.tiny, text_halign=text.align_center)

    table.cell(helixDash, 0, 6, "Filters", bgcolor=sectionBg, text_color=color.new(neutralBase, 15), text_size=size.tiny)
    table.cell(helixDash, 1, 6, filterText + " | ADX " + str.tostring(adxValue, "#.0"), bgcolor=color.new(filterColor, 84), text_color=filterColor, text_size=size.tiny, text_halign=text.align_center)

    if not compactDash
        string flipText = na(lastFlipPrice) ? "None" : str.tostring(lastFlipPrice, format.mintick)
        string barsText = helixDirection == 0 ? "Idle" : str.tostring(barsInState)
        table.cell(helixDash, 0, 7, "Last Flip", bgcolor=sectionBg, text_color=color.new(neutralBase, 15), text_size=size.tiny)
        table.cell(helixDash, 1, 7, flipText + " | " + barsText, bgcolor=rowBg, text_color=accentBase, text_size=size.tiny, text_halign=text.align_center)

//------------------------------------------------------------------------------
// Diagnostic plots kept hidden for cleaner overlays and future extensibility.
//------------------------------------------------------------------------------

plot(na, title="Spacer", display=display.none)
````
