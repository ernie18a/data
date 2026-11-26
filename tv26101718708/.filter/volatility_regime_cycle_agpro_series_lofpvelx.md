# Volatility Regime Cycle [AGPro Series]

- url: https://www.tradingview.com/script/LOfpVelX-Volatility-Regime-Cycle-AGPro-Series/
- type: indicator
- pine_id: PUB;c0518552bed14e058c0ce63aa9a7f928
- version: 6.0

## Description

Volatility Regime Cycle [AGPro Series]

🌀 Overview

Volatility Regime Cycle classifies every bar on your chart into one of four distinct volatility phases: Contraction, Expansion, Climax, and Reset. Unlike traditional trend or regime indicators that focus on price direction, this tool maps the cyclical behavior of volatility itself — helping traders recognize whether the market is coiling, releasing, climaxing, or resetting. Each phase is detected through a multi-factor confluence engine and displayed with gradient background shading, transition markers, and S/R-style climax reaction zones. The framework is asset- and timeframe-agnostic: it adapts to crypto, forex, indices, stocks, and commodities on any timeframe.


💎 Unique Edge

Most volatility tools present a single metric (ATR, Bollinger Width, VIX proxy). Volatility Regime Cycle differs in structure and intent:

🔸 Phase-based classification, not just a reading — every bar is assigned to a named regime with a trader-actionable bias.
🔸 Multi-factor confluence scoring — five independent volatility inputs (ATR level, BB Width level, BB/KC squeeze, volume z-score, ATR rate-of-change) vote on the active phase. No single factor can dominate.
🔸 Winsorized normalization — outlier events (single extreme bars) do not compress the scale and hide current readings, a common flaw in simple percentile-based tools.
🔸 Climax Reaction Zones — each Climax event is preserved as an S/R-style rectangle with mid-pivot line, creating a memory of past volatility exhaustion levels that often act as future reaction areas.
🔸 Cycle-aware analytics — tracks historical phase durations and estimates current cycle progress based on rolling averages of past phases of the same type.
🔸 Phase-specific Trader Bias — panel translates the current regime into a plain-language bias (Breakout-watch, Momentum-favor, Reversal-risk, Cooldown).

This is not a Wyckoff phase tool, an Elliott counter, or a Dow-theory classifier. It is a pure volatility-cycle mapper, engineered from the ground up to stand apart from both classical cycle indicators and single-metric volatility meters.


🧠 Methodology

The engine runs three layers:

🔹 Factor Layer
• ATR Level — 14-period ATR, winsorized min-max normalized (5%-95% range) over a configurable lookback window.
• BB Width Level — Bollinger Band width as percent of basis, normalized identically.
• Squeeze State — true when Bollinger Bands are contained inside Keltner Channels (classic volatility compression).
• Volume Z-Score — standardized volume relative to its rolling mean and standard deviation.
• ATR Rate-of-Change — momentum of volatility itself.

🔹 Scoring Layer
Each of the four phases has its own scoring formula that weights the five factors differently. For each bar, all four phase scores are calculated in parallel, and the phase with the highest score is the candidate regime for that bar.

🔹 Confirmation Layer
To suppress whipsaw, the candidate phase must persist for a configurable number of bars (default 3) before replacing the active phase. A minimum phase duration lock additionally prevents rapid flips. Climax events include a de-duplication cooldown so that clustered climax bars produce a single marker rather than a cluster of overlapping labels.

Phase transitions are classified as major (Contraction→Expansion breakouts and Climax entries) or minor (all other routine changes). Only major transitions receive labels; minor changes are shown as subtle dotted lines to keep the chart clean.


🔔 Signals & Alerts

The script exposes alerts for every phase transition as well as two high-value composite events:

🔸 Any Phase Transition — fires whenever the active phase changes.
🔸 Entered Contraction / Expansion / Climax / Reset — fires for specific phase entries.
🔸 Contraction → Expansion (Breakout) — coil release event; of interest to breakout traders.
🔸 Climax Entry (Exhaustion Warning) — volatility peak event; of interest to mean-reversion and risk-management traders.

All alerts fire only on confirmed bar close to prevent intra-bar flip-flop.


⚙️ Key Inputs

🔹 Engine Settings — normalization lookback, ATR length, Bollinger/Keltner length and multipliers, volume z-score length, ATR rate-of-change length, confirmation bars, minimum phase duration.
🔹 Phase Thresholds — low volatility level, high volatility level, climax volatility gate, climax volume z-score threshold, climax de-dup cooldown.
🔹 Visuals — toggles for background shading, major transition labels, minor transition lines, volatility ribbon, current phase label.
🔹 S/R Zones — climax zones toggle, breakout zones toggle, maximum active zones, zone initial length, zone range lookback.
🔹 Panel — show/hide, location, Dark/Light theme, font size.
🔹 Label Sizing — font size for on-chart labels.
🔹 Alerts — per-event toggles.


📘 How to Use

🔸 Breakout traders: watch for Contraction phase on the panel with Trader Bias showing Breakout-watch. When the phase transitions to Expansion, a coil release is underway and a Breakout label is printed. Optional Breakout Zones can be enabled to preserve the breakout level as a retest reference.

🔸 Momentum / trend traders: ride the Expansion phase while Trader Bias reads Momentum-favor. Phase Duration and Cycle Progress on the panel give a sense of where the current momentum leg sits relative to historical averages.

🔸 Mean-reversion / exhaustion traders: a Climax label with Trader Bias Reversal-risk highlights volatility exhaustion. The Climax Reaction Zone drawn at each climax often behaves as a future reaction level and can be used as confluence with other reversal tools.

🔸 Risk managers: the Reset phase with Trader Bias Cooldown typically signals reduced market conviction and can be used to scale down position size until a new Contraction builds up.

🔸 Multi-timeframe reading: run the script on the higher timeframe for regime context and on the lower timeframe for entry timing.

Hover the panel header to see a statistics tooltip with average durations of each phase over the last completed cycles.


⚠️ Limitations & Transparency

🔹 The script does not predict future prices or issue buy/sell recommendations. It is a classification and context tool.
🔹 Phase detection is inherently lagging because it requires the confirmation window and minimum duration lock. This is a deliberate design choice to suppress whipsaw at the cost of some responsiveness.
🔹 Normalization uses a rolling lookback window; the first lookback bars after loading the script may show compressed or unstable readings while the window fills.
🔹 Cycle Progress is an estimate based on historical phase averages and may exceed 100% when the current phase runs longer than past cycles.
🔹 Climax and Reset scores rely partly on volume; on instruments with unreliable or missing volume feeds, volume-dependent factors will contribute less.
🔹 All visual elements are cosmetic and toggleable; they do not alter the underlying phase logic.


🛡️ Risk Disclosure

This indicator is a technical analysis tool. It is not a trading system, not a signal service, not financial advice, and not a guarantee of future results. Trading involves substantial risk of loss. Past market behavior does not predict future market behavior. Users are solely responsible for their own trading decisions, risk management, and position sizing. Always test any tool on your preferred instruments and timeframes with appropriate historical review before using it as part of a live decision-making process.

## Source Code

````pine
// -------------------------------------------------
// Volatility Regime Cycle [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.8
//
// Volatility Regime Cycle maps market volatility into a readable regime
// workflow: Contraction, Expansion, Climax, and Reset. It blends ATR
// percentile, Bollinger Band width percentile, squeeze state, volume z-score,
// and ATR rate of change into a confirmed phase engine with volatility state,
// ATR context, reaction zones, controlled labels, no-arrow context badges,
// and an AG Pro status panel. V1.8 confirms phase transitions at bar close,
// tightens reaction-zone geometry, and enriches the visual evidence shown in
// active cycle badges while preserving the Release Rate proof layer.
// This is an analytical visualization tool, not a prediction engine and not financial advice.
// -------------------------------------------------

//@version=6
indicator("Volatility Regime Cycle [AGPro Series]",
     shorttitle       = "AG VRC",
     overlay          = true,
     max_labels_count = 60,
     max_lines_count  = 10,
     max_boxes_count  = 10)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBg       = color.rgb(15, 23, 42)
panelBorder   = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
panelBgLight  = color.rgb(248, 250, 252)
panelAltLight = color.rgb(241, 245, 249)
panelBorderL  = color.rgb(203, 213, 225)
panelLabelL   = color.rgb(71, 85, 105)
panelValueL   = color.rgb(15, 23, 42)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)
darkText      = color.rgb(15, 23, 42)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
const string TT_LOOKBACK = "Bars used to normalize ATR and Bollinger Band width through percentile ranges. Higher values create slower regime context."
const string TT_ATR = "ATR length used for volatility normalization, label spacing, ribbon placement, and reaction-zone sizing."
const string TT_BB = "Length used for Bollinger Band and Keltner Channel calculations inside the regime model."
const string TT_BB_MULT = "Standard deviation multiplier used to calculate Bollinger Band width."
const string TT_KC = "ATR multiplier used for Keltner Channel squeeze detection."
const string TT_VOL = "Lookback used to normalize volume into a z-score. On symbols with weak volume data, this should be interpreted as context only."
const string TT_ROC = "Bars used to measure whether ATR is expanding or contracting."
const string TT_CONFIRM = "Bars required to confirm a phase change. Higher values reduce noisy phase flips."
const string TT_DURATION = "Minimum number of bars a confirmed phase must remain active before another phase can replace it."
const string TT_RELEASE_WINDOW = "Number of bars a confirmed coil release has to expand volatility within, for the Release Rate proof. It only measures historical follow-through and is not a forecast."
const string TT_LOW = "Below this normalized level, Contraction and Reset become more likely."
const string TT_HIGH = "Above this normalized level, Expansion and Climax become more likely."
const string TT_CLIMAX = "Minimum normalized volatility level required before the model can favor Climax context."
const string TT_CLIMAX_VOL = "Volume z-score threshold used as a participation filter for Climax context."
const string TT_RIBBON = "Shows a subtle phase-colored volatility ribbon above price. It keeps regime context visible without turning the chart into a separate oscillator."
const string TT_LABELS = "Shows controlled transition labels for Expansion, Climax, Reset, and Contraction events."
const string TT_DENSITY = "Controls label frequency. Balanced is the publication default with several meaningful labels without crowding."
const string TT_FONT = "Controls chart label, zone label, and right-edge badge text size. Normal is the recommended publication default."
const string TT_LABEL_GAP = "Minimum bars between transition labels. Higher values reduce repeated labels in the same area."
const string TT_RIGHT_TAG = "Shows the current volatility workflow and ATR context as a no-arrow badge near the right edge."
const string TT_ZONES = "Draws compact reaction zones around important volatility regime transitions. Each zone receives a centered label."
const string TT_ZONE_MODE = "Major Only draws zones for qualified Expansion and Climax events. All Transitions also maps Reset and Contraction."
const string TT_ZONE_LIMIT = "Maximum number of reaction zones retained on the chart."
const string TT_ZONE_EXTEND = "Horizontal length of each new reaction zone."
const string TT_ZONE_RANGE = "Bars used to capture the event range for reaction-zone construction."
const string TT_ZONE_HEIGHT = "Maximum reaction-zone height in ATR. Large event ranges are capped around their midpoint so one volatility spike cannot dominate the chart."
const string TT_PANEL = "Shows or hides the AG Pro volatility panel. Enabled by default for publication-ready context."
const string TT_PANEL_POS = "Moves the AG Pro panel to the preferred chart location."
const string TT_PANEL_THEME = "Switches the panel between AGPro dark and clean light themes."
const string TT_PANEL_FONT = "Controls panel text size. Normal is the recommended publication default."
const string TT_ALERTS = "Enables TradingView alert conditions for confirmed volatility phase transitions. Alerts are attention markers, not trade instructions."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Cycle Engine"
groupPhase  = "Phase Thresholds"
groupVisual = "Visuals"
groupZones  = "Reaction Zones"
groupPanel  = "Panel"
groupAlert  = "Alerts"
const string PANEL_TITLE = "AG Pro Volatility Regime Cycle"

lookback = input.int(100, "Normalization Lookback", minval = 50, maxval = 500, step = 10, group = groupEngine, tooltip = TT_LOOKBACK)
atrLen = input.int(14, "ATR Length", minval = 5, maxval = 80, group = groupEngine, tooltip = TT_ATR)
bbLen = input.int(20, "Band Length", minval = 10, maxval = 80, group = groupEngine, tooltip = TT_BB)
bbMult = input.float(2.0, "Bollinger Multiplier", minval = 1.0, maxval = 4.0, step = 0.1, group = groupEngine, tooltip = TT_BB_MULT)
kcMult = input.float(1.5, "Keltner Multiplier", minval = 1.0, maxval = 3.0, step = 0.1, group = groupEngine, tooltip = TT_KC)
volLen = input.int(20, "Volume Z-Score Length", minval = 5, maxval = 120, group = groupEngine, tooltip = TT_VOL)
rocLen = input.int(5, "ATR Rate-of-Change Length", minval = 2, maxval = 30, group = groupEngine, tooltip = TT_ROC)
confirmBars = input.int(3, "Phase Confirmation Bars", minval = 1, maxval = 10, group = groupEngine, tooltip = TT_CONFIRM)
minPhaseBars = input.int(3, "Minimum Phase Duration", minval = 1, maxval = 30, group = groupEngine, tooltip = TT_DURATION)
releaseWindow = input.int(20, "Release Proof Window (bars)", minval = 5, maxval = 120, group = groupEngine, tooltip = TT_RELEASE_WINDOW)

lowVolLevel = input.float(25.0, "Low Volatility Level", minval = 10.0, maxval = 45.0, step = 1.0, group = groupPhase, tooltip = TT_LOW)
highVolLevel = input.float(75.0, "High Volatility Level", minval = 55.0, maxval = 95.0, step = 1.0, group = groupPhase, tooltip = TT_HIGH)
climaxGate = input.float(65.0, "Climax Volatility Gate", minval = 45.0, maxval = 95.0, step = 1.0, group = groupPhase, tooltip = TT_CLIMAX)
climaxVolumeZ = input.float(1.2, "Climax Volume Z-Score", minval = 0.5, maxval = 4.0, step = 0.1, group = groupPhase, tooltip = TT_CLIMAX_VOL)

showRibbon = input.bool(true, "Show Volatility Ribbon", group = groupVisual, tooltip = TT_RIBBON)
showTransitionLabels = input.bool(true, "Show Transition Labels", group = groupVisual, tooltip = TT_LABELS)
labelDensity = input.string("Balanced", "Label Density", options = ["Minimal", "Balanced", "Detailed"], group = groupVisual, tooltip = TT_DENSITY)
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual, tooltip = TT_FONT)
minLabelGapBars = input.int(52, "Minimum Label Gap Bars", minval = 10, maxval = 140, group = groupVisual, tooltip = TT_LABEL_GAP)
labelOffsetAtr = input.float(1.22, "Label Offset ATR", minval = 0.25, maxval = 3.00, step = 0.05, group = groupVisual, tooltip = "ATR-based label offset used to keep labels clear of candles.")
showRightTag = input.bool(true, "Show Right-Edge Phase Badge", group = groupVisual, tooltip = TT_RIGHT_TAG)

showReactionZones = input.bool(true, "Show Reaction Zones", group = groupZones, tooltip = TT_ZONES)
zoneMode = input.string("Major Only", "Zone Mode", options = ["Major Only", "All Transitions"], group = groupZones, tooltip = TT_ZONE_MODE)
maxZones = input.int(2, "Max Active Zones", minval = 1, maxval = 8, group = groupZones, tooltip = TT_ZONE_LIMIT)
zoneExtendBars = input.int(24, "Zone Initial Length Bars", minval = 12, maxval = 100, group = groupZones, tooltip = TT_ZONE_EXTEND)
zoneRangeBars = input.int(3, "Zone Range Lookback", minval = 1, maxval = 10, group = groupZones, tooltip = TT_ZONE_RANGE)
zoneMaxHeightAtr = input.float(1.60, "Zone Maximum Height ATR", minval = 0.50, maxval = 4.00, step = 0.10, group = groupZones, tooltip = TT_ZONE_HEIGHT)

showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = TT_PANEL)
panelPosition = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = TT_PANEL_POS)
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = TT_PANEL_THEME)
panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = TT_PANEL_FONT)

enableAlerts = input.bool(true, "Enable Alert Conditions", group = groupAlert, tooltip = TT_ALERTS)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_size(string value) =>
    switch value
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_pos(string value) =>
    switch value
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_norm(float source, int length) =>
    p05 = ta.percentile_linear_interpolation(source, length, 5)
    p95 = ta.percentile_linear_interpolation(source, length, 95)
    rng = p95 - p05
    na(p05) or na(p95) or rng <= 0.0 ? 50.0 : (f_clamp(source, p05, p95) - p05) / rng * 100.0

f_phase_name(int phaseValue) =>
    switch phaseValue
        1 => "Contraction"
        2 => "Expansion"
        3 => "Climax"
        4 => "Reset"
        => "Unknown"

f_phase_short(int phaseValue) =>
    switch phaseValue
        1 => "Coil"
        2 => "Expand"
        3 => "Climax"
        4 => "Reset"
        => "Wait"

f_phase_color(int phaseValue) =>
    switch phaseValue
        1 => neutralColor
        2 => bullColor
        3 => bearColor
        4 => accentColor
        => panelLabelCol

f_atr_context(float atrPercentile, float lowLevel, float highLevel) =>
    atrPercentile < lowLevel ? "Quiet ATR" :
     atrPercentile >= highLevel ? "Hot ATR" :
     atrPercentile >= 55.0 ? "Active ATR" :
     "Balanced ATR"

f_activity_state(int phaseValue, float atrPercentile, float rocValue) =>
    phaseValue == 3 or atrPercentile >= 88.0 ? "Noisy" :
     phaseValue == 4 or rocValue < -0.05 ? "Cooldown" :
     phaseValue == 2 and rocValue > 0.0 ? "Active" :
     phaseValue == 1 ? "Setup" :
     "Scanning"

f_workflow_text(int phaseValue, string activityText) =>
    phaseValue == 1 ? "Build setup" :
     phaseValue == 2 ? "Track release" :
     phaseValue == 3 ? "Review noise" :
     phaseValue == 4 ? "Let cool" :
     activityText == "Active" ? "Track release" :
     "Map regime"

f_review_text(int phaseValue, string atrText, string activityText) =>
    f_phase_name(phaseValue) + " / " + activityText + " / " + atrText

f_meter(float value) =>
    value >= 85.0 ? "A+" :
     value >= 75.0 ? "A" :
     value >= 65.0 ? "B" :
     value >= 50.0 ? "C" :
     value >= 35.0 ? "D" :
     "E"

f_panel_bg(bool isLight, bool alt) =>
    isLight ? (alt ? panelAltLight : panelBgLight) : (alt ? color.rgb(24, 35, 55) : panelBg)

f_panel_label(bool isLight) =>
    isLight ? panelLabelL : panelLabelCol

f_panel_value(bool isLight) =>
    isLight ? panelValueL : panelValueCol

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, bool isLight, string fontSize) =>
    rowBg = f_panel_bg(isLight, row % 2 == 0)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(isLight), bgcolor = rowBg, text_size = f_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_size(fontSize), text_halign = text.align_right)

f_prune_zone_pairs(array<box> boxes, array<label> labels, int keep) =>
    while array.size(boxes) > keep
        oldBox = array.shift(boxes)
        if not na(oldBox)
            box.delete(oldBox)
        oldLabel = array.size(labels) > 0 ? array.shift(labels) : na
        if not na(oldLabel)
            label.delete(oldLabel)
    while array.size(labels) > array.size(boxes)
        extraLabel = array.shift(labels)
        if not na(extraLabel)
            label.delete(extraLabel)

// -------------------------------------------------
// Volatility Factors
// -------------------------------------------------
atrVal = ta.atr(atrLen)
safeAtr = math.max(nz(atrVal, ta.tr(true)), syminfo.mintick)
atrPct = f_norm(safeAtr, lookback)

basis = ta.sma(close, bbLen)
bbDev = bbMult * ta.stdev(close, bbLen)
bbUpper = basis + bbDev
bbLower = basis - bbDev
bbWidth = basis != 0.0 ? (bbUpper - bbLower) / basis * 100.0 : 0.0
bbWidthPct = f_norm(bbWidth, lookback)

kcRange = kcMult * safeAtr
kcUpper = basis + kcRange
kcLower = basis - kcRange
squeezeOn = bbUpper < kcUpper and bbLower > kcLower

rawVolume = na(volume) ? 1.0 : volume
volMean = ta.sma(rawVolume, volLen)
volStdev = ta.stdev(rawVolume, volLen)
volumeZ = volStdev > 0.0 ? (rawVolume - volMean) / volStdev : 0.0

atrRoc = safeAtr / nz(safeAtr[rocLen], safeAtr) - 1.0

// -------------------------------------------------
// Core Phase Scoring
// -------------------------------------------------
scoreContraction = 0.0
scoreContraction += atrPct < lowVolLevel ? 3.0 : 0.0
scoreContraction += bbWidthPct < lowVolLevel ? 3.0 : 0.0
scoreContraction += squeezeOn ? 2.0 : 0.0
scoreContraction += atrRoc < 0.0 ? 1.0 : 0.0
scoreContraction += math.abs(volumeZ) < 0.75 ? 1.0 : 0.0

scoreExpansion = 0.0
scoreExpansion += atrPct > 45.0 ? 2.0 : 0.0
scoreExpansion += atrPct < highVolLevel ? 2.0 : 0.0
scoreExpansion += bbWidthPct > 45.0 ? 2.0 : 0.0
scoreExpansion += atrRoc > 0.0 ? 2.0 : 0.0
scoreExpansion += volumeZ > 0.0 ? 1.0 : 0.0
scoreExpansion += not squeezeOn ? 1.0 : 0.0

scoreClimax = 0.0
scoreClimax += atrPct > climaxGate ? 3.0 : 0.0
scoreClimax += bbWidthPct > climaxGate ? 2.0 : 0.0
scoreClimax += volumeZ > climaxVolumeZ ? 3.0 : 0.0
scoreClimax += atrRoc > 0.10 ? 2.0 : 0.0
scoreClimax += atrPct > highVolLevel ? 1.0 : 0.0

scoreReset = 0.0
scoreReset += atrPct > lowVolLevel and atrPct < 55.0 ? 2.0 : 0.0
scoreReset += atrRoc < -0.05 ? 3.0 : 0.0
scoreReset += bbWidthPct < 55.0 ? 2.0 : 0.0
scoreReset += math.abs(volumeZ) < 1.0 ? 2.0 : 0.0
scoreReset += not squeezeOn ? 1.0 : 0.0

maxScore = math.max(math.max(scoreContraction, scoreExpansion), math.max(scoreClimax, scoreReset))
rawPhase = scoreClimax == maxScore ? 3 : scoreExpansion == maxScore ? 2 : scoreContraction == maxScore ? 1 : 4
phaseConfidence = f_clamp(maxScore / 10.0 * 100.0, 0.0, 100.0)

// -------------------------------------------------
// Confirmation Engine
// -------------------------------------------------
var int phase = 1
var int previousPhase = 1
var int pendingPhase = 1
var int pendingCount = 0
var int phaseStartBar = 0
bool phaseChanged = false

if barstate.isfirst
    phase := rawPhase
    previousPhase := rawPhase
    pendingPhase := rawPhase
    phaseStartBar := bar_index

canChange = bar_index - phaseStartBar >= minPhaseBars

if barstate.isconfirmed
    if rawPhase == phase
        pendingPhase := rawPhase
        pendingCount := 0
    else
        if rawPhase == pendingPhase
            pendingCount += 1
        else
            pendingPhase := rawPhase
            pendingCount := 1
        if pendingCount >= confirmBars and canChange
            previousPhase := phase
            phase := pendingPhase
            pendingCount := 0
            phaseStartBar := bar_index
            phaseChanged := true

phaseDuration = bar_index - phaseStartBar
phaseColor = f_phase_color(phase)
atrContext = f_atr_context(atrPct, lowVolLevel, highVolLevel)
activityState = f_activity_state(phase, atrPct, atrRoc)
workflowText = f_workflow_text(phase, activityState)
reviewText = f_review_text(phase, atrContext, activityState)

// -------------------------------------------------
// Cycle Progress
// -------------------------------------------------
var array<float> phaseDurations1 = array.new<float>()
var array<float> phaseDurations2 = array.new<float>()
var array<float> phaseDurations3 = array.new<float>()
var array<float> phaseDurations4 = array.new<float>()

if phaseChanged
    dur = float(math.max(1, phaseDuration[1]))
    if previousPhase == 1
        array.push(phaseDurations1, dur)
    else if previousPhase == 2
        array.push(phaseDurations2, dur)
    else if previousPhase == 3
        array.push(phaseDurations3, dur)
    else if previousPhase == 4
        array.push(phaseDurations4, dur)
    while array.size(phaseDurations1) > 20
        array.shift(phaseDurations1)
    while array.size(phaseDurations2) > 20
        array.shift(phaseDurations2)
    while array.size(phaseDurations3) > 20
        array.shift(phaseDurations3)
    while array.size(phaseDurations4) > 20
        array.shift(phaseDurations4)

f_avg(array<float> values) =>
    array.size(values) > 0 ? array.avg(values) : 0.0

avgDur = phase == 1 ? f_avg(phaseDurations1) :
     phase == 2 ? f_avg(phaseDurations2) :
     phase == 3 ? f_avg(phaseDurations3) :
     phase == 4 ? f_avg(phaseDurations4) :
     0.0

cycleProgress = avgDur > 0.0 ? f_clamp(phaseDuration / avgDur * 100.0, 0.0, 150.0) : 0.0

// -------------------------------------------------
// Events
// -------------------------------------------------
isBreakout = phaseChanged and previousPhase == 1 and phase == 2
isClimax = phaseChanged and phase == 3
isReset = phaseChanged and phase == 4
isContraction = phaseChanged and phase == 1
isMajorEvent = isBreakout or isClimax
qualifiedBreakout = isBreakout and phaseConfidence >= 65.0
qualifiedClimax = isClimax and phaseConfidence >= 65.0
qualifiedReset = isReset and phaseConfidence >= 60.0
qualifiedContraction = isContraction and phaseConfidence >= 60.0
qualifiedMajorEvent = qualifiedBreakout or qualifiedClimax

// -------------------------------------------------
// Release-rate proof (Confirm Rate)
// -------------------------------------------------
var int   expTotal     = 0
var int   expWon         = 0
var bool  expPend        = false
var float expAnchorAtr   = na
var int   expLeft        = 0
float expandMult = 1.15

if barstate.isconfirmed
    if expPend and not na(expAnchorAtr)
        bool favHit = safeAtr >= expAnchorAtr * expandMult
        bool advHit = phase == 1
        if favHit
            expTotal += 1
            expWon += 1
            expPend := false
        else if advHit
            expTotal += 1
            expPend := false
        else
            expLeft -= 1
            if expLeft <= 0
                expTotal += 1
                expPend := false
    if qualifiedBreakout and not expPend
        expPend := true
        expAnchorAtr := safeAtr
        expLeft := releaseWindow

float expRate = expTotal > 0 ? expWon / expTotal * 100.0 : na

// -------------------------------------------------
// Visual Context
// -------------------------------------------------
ribbonTop = high + safeAtr * 0.54
ribbonBottom = high + safeAtr * 0.42
pRibbonTop = plot(showRibbon ? ribbonTop : na, "Volatility Ribbon Top", color = color.new(phaseColor, 100), linewidth = 1)
pRibbonBottom = plot(showRibbon ? ribbonBottom : na, "Volatility Ribbon Bottom", color = color.new(phaseColor, 100), linewidth = 1)
fill(pRibbonTop, pRibbonBottom, color = showRibbon ? color.new(phaseColor, 84) : na, title = "Volatility Ribbon")

// -------------------------------------------------
// Labels
// -------------------------------------------------
labelSize = f_size(labelSizeInput)
var array<label> phaseLabels = array.new<label>()
var int lastLabelBar = na
var float lastLabelPrice = na
var label rightTag = na

f_keep_label(label item, int maxCount) =>
    array.push(phaseLabels, item)
    while array.size(phaseLabels) > maxCount
        old = array.shift(phaseLabels)
        if not na(old)
            label.delete(old)

maxLabels = labelDensity == "Detailed" ? 12 : labelDensity == "Balanced" ? 5 : 4
barsOk = na(lastLabelBar) or bar_index - lastLabelBar >= minLabelGapBars
priceOk = na(lastLabelPrice) or math.abs(close - lastLabelPrice) >= safeAtr * 1.65
importantCycleContext = (qualifiedReset and phaseConfidence >= 80.0 and cycleProgress >= 40.0) or (qualifiedContraction and phaseConfidence >= 75.0 and cycleProgress >= 60.0)
labelEventOk = labelDensity == "Minimal" ? (qualifiedMajorEvent and not showReactionZones) :
     labelDensity == "Balanced" ? ((qualifiedMajorEvent and not showReactionZones) or importantCycleContext) :
     phaseChanged

if showTransitionLabels and barsOk and priceOk and labelEventOk
    labelAbove = phase == 3 or phase == 4
    labelY = labelAbove ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
    labelStyle = labelAbove ? label.style_label_down : label.style_label_up
    labelTitle = isBreakout ? "Expansion" :
         isClimax ? "Climax" :
         isReset ? "Reset" :
         isContraction ? "Contraction" :
         f_phase_short(phase)
    labelDetail = labelDensity == "Detailed" ? "\n" + activityState + " / ATR " + str.tostring(atrPct, "#") + " / BBW " + str.tostring(bbWidthPct, "#") : "\n" + activityState + " " + str.tostring(phaseConfidence, "#")
    labelBg = color.new(phaseColor, phase == 1 ? 0 : 4)
    labelTextColor = phase == 1 ? darkText : headerText
    lbl = label.new(bar_index, labelY, labelTitle + labelDetail,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = labelStyle,
         color = labelBg,
         textcolor = labelTextColor,
         size = labelSize,
         textalign = text.align_center,
         tooltip = "Confirmed volatility regime transition. This is an attention marker, not a trade instruction.")
    f_keep_label(lbl, maxLabels)
    lastLabelBar := bar_index
    lastLabelPrice := close

rightTagY = ta.highest(high, 24) + safeAtr * 1.00

if showRightTag and barstate.islast
    if not na(rightTag)
        label.delete(rightTag)
    tagX = bar_index + 8
    tagY = rightTagY
    tagTxt = str.upper(f_phase_name(phase)) + " | Q " + str.tostring(phaseConfidence, "#") + "\n" + activityState + " | ATR " + str.tostring(atrPct, "#") + " | BBW " + str.tostring(bbWidthPct, "#")
    rightTag := label.new(tagX, tagY, tagTxt,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_label_center,
         color = color.new(phaseColor, 0),
         textcolor = phase == 1 ? darkText : headerText,
         size = labelSize,
         textalign = text.align_center)
else if not showRightTag and not na(rightTag)
    label.delete(rightTag)
    rightTag := na

// -------------------------------------------------
// Reaction Zones
// -------------------------------------------------
var array<box> reactionZones = array.new<box>()
var array<label> zoneLabels = array.new<label>()
var int lastZoneBar = na
var float lastZoneMid = na

zoneHighCalc = ta.highest(high, zoneRangeBars)
zoneLowCalc = ta.lowest(low, zoneRangeBars)
candidateZoneMid = (zoneHighCalc + zoneLowCalc) * 0.5
zoneBarsReady = na(lastZoneBar) or bar_index - lastZoneBar >= zoneExtendBars
zonePriceReady = na(lastZoneMid) or math.abs(candidateZoneMid - lastZoneMid) >= safeAtr * 1.80
zoneSpacingOk = zoneBarsReady and zonePriceReady
zoneEvent = showReactionZones and zoneSpacingOk and (zoneMode == "All Transitions" ? (phaseChanged and (phaseConfidence >= 65.0)) : qualifiedMajorEvent)

if zoneEvent and barstate.isconfirmed
    rawZoneMid = (zoneHighCalc + zoneLowCalc) * 0.5
    zoneHalfHeight = math.max(syminfo.mintick * 5.0, math.min((zoneHighCalc - zoneLowCalc) * 0.5, safeAtr * zoneMaxHeightAtr * 0.5))
    zoneHigh = rawZoneMid + zoneHalfHeight
    zoneLow = rawZoneMid - zoneHalfHeight
    zoneMid = rawZoneMid
    leftX = math.max(0, bar_index - zoneRangeBars + 1)
    rightX = bar_index + zoneExtendBars
    centerX = int(math.round((leftX + rightX) * 0.5))
    zoneBg = color.new(phaseColor, phase == 3 ? 84 : 88)
    zoneBorder = color.new(phaseColor, 24)
    zoneBox = box.new(leftX, zoneHigh, rightX, zoneLow,
         xloc = xloc.bar_index,
         bgcolor = zoneBg,
         border_color = zoneBorder,
         border_width = isMajorEvent ? 2 : 1)
    zoneText = str.upper(f_phase_name(phase)) + " | Q " + str.tostring(phaseConfidence, "#") + "\nATR " + str.tostring(atrPct, "#") + " | BBW " + str.tostring(bbWidthPct, "#")
    zoneLabel = label.new(centerX, zoneMid, zoneText,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_label_center,
         color = color.new(phaseColor, 0),
         textcolor = phase == 1 ? darkText : headerText,
         size = labelSize,
         textalign = text.align_center,
         tooltip = "Centered reaction-zone label for the confirmed volatility regime event.")
    array.push(reactionZones, zoneBox)
    array.push(zoneLabels, zoneLabel)
    lastZoneBar := bar_index
    lastZoneMid := zoneMid
    f_prune_zone_pairs(reactionZones, zoneLabels, maxZones)

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelSize = f_size(panelSizeInput)
isLightPanel = panelTheme == "Light"
panelFrame = isLightPanel ? panelBorderL : panelBorder
panelValueText = f_panel_value(isLightPanel)
stateColor = activityState == "Noisy" ? bearColor : activityState == "Active" ? bullColor : activityState == "Cooldown" ? accentColor : neutralColor
atrColor = atrContext == "Hot ATR" ? bearColor : atrContext == "Active ATR" ? bullColor : atrContext == "Quiet ATR" ? neutralColor : accentColor
progressText = avgDur > 0.0 ? str.tostring(cycleProgress, "#") + "% / " + str.tostring(phaseDuration) + "b" : str.tostring(phaseDuration) + "b"
metricText = str.tostring(atrPct, "#") + " ATR / " + str.tostring(bbWidthPct, "#") + " BBW"
confidenceText = str.tostring(math.round(phaseConfidence)) + " / 100"
confidenceColor = phaseConfidence >= 75.0 ? bullColor : phaseConfidence >= 55.0 ? accentColor : phaseConfidence >= 40.0 ? neutralColor : bearColor
releaseRateText = expTotal > 0 ? str.tostring(math.round(expRate)) + "% (" + str.tostring(expTotal) + ")" : "Building"
releaseRateColor = na(expRate) ? panelValueText : expRate >= 60.0 ? bullColor : expRate >= 45.0 ? neutralColor : bearColor

var table panelTable = na
var string lastPanelPosition = ""
var string lastPanelTheme = ""
var string lastPanelSize = ""
panelNeedsRebuild = showPanel and (na(panelTable) or lastPanelPosition != panelPosition or lastPanelTheme != panelTheme or lastPanelSize != panelSizeInput)

if panelNeedsRebuild
    if not na(panelTable)
        table.delete(panelTable)
    panelTable := table.new(f_panel_pos(panelPosition), 2, 9, bgcolor = f_panel_bg(isLightPanel, false), frame_color = panelFrame, frame_width = 1, border_color = panelFrame, border_width = 1)
    table.cell(panelTable, 0, 0, PANEL_TITLE, text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    table.cell(panelTable, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
    table.merge_cells(panelTable, 0, 0, 1, 0)
    lastPanelPosition := panelPosition
    lastPanelTheme := panelTheme
    lastPanelSize := panelSizeInput

if not showPanel and not na(panelTable)
    table.delete(panelTable)
    panelTable := na
    lastPanelPosition := ""
    lastPanelTheme := ""
    lastPanelSize := ""

if showPanel and not na(panelTable) and barstate.islast
    table.set_position(panelTable, f_panel_pos(panelPosition))
    table.set_frame_color(panelTable, panelFrame)
    table.set_border_color(panelTable, panelFrame)
    table.clear(panelTable, 0, 1, 1, 8)
    table.cell(panelTable, 0, 0, PANEL_TITLE, text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    f_panel_row(panelTable, 1, "Workflow", workflowText, stateColor, isLightPanel, panelSizeInput)
    f_panel_row(panelTable, 2, "Volatility State", activityState + " / " + atrContext, atrColor, isLightPanel, panelSizeInput)
    f_panel_row(panelTable, 3, "Cycle Phase", f_phase_name(phase), phaseColor, isLightPanel, panelSizeInput)
    f_panel_row(panelTable, 4, "Phase Confidence", confidenceText, confidenceColor, isLightPanel, panelSizeInput)
    f_panel_row(panelTable, 5, "Progress", progressText, panelValueText, isLightPanel, panelSizeInput)
    f_panel_row(panelTable, 6, "ATR / BBW", metricText, atrColor, isLightPanel, panelSizeInput)
    f_panel_row(panelTable, 7, "Release Rate", releaseRateText, releaseRateColor, isLightPanel, panelSizeInput)
    f_panel_row(panelTable, 8, "Review", reviewText, phaseColor, isLightPanel, panelSizeInput)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(enableAlerts and phaseChanged, "Volatility Phase Transition", "Volatility Regime Cycle: confirmed volatility phase transition. This is an attention marker, not a trade instruction.")
alertcondition(enableAlerts and isBreakout, "Contraction to Expansion", "Volatility Regime Cycle: contraction transitioned into expansion context.")
alertcondition(enableAlerts and isClimax, "Climax Phase", "Volatility Regime Cycle: climax volatility context is active.")
alertcondition(enableAlerts and isReset, "Reset Phase", "Volatility Regime Cycle: reset or cooldown context is active.")

plot(float(phase), "Confirmed Phase", display = display.none)
plot(atrPct, "ATR Percentile", display = display.none)
plot(bbWidthPct, "BB Width Percentile", display = display.none)
plot(phaseConfidence, "Phase Confidence", display = display.none)
plot(expRate, "Release Rate", display = display.none)
````
