# Compression Breakout Readiness [AGPro Series]

- url: https://www.tradingview.com/script/SNI3RJ1D-Compression-Breakout-Readiness-AGPro-Series/
- type: indicator
- pine_id: PUB;8822aa0bb6dc4792b8ac4986d777d0e4
- version: 4.0

## Description

Compression Breakout Readiness [AGPro Series]

🧠 Core Idea

Is compression mature enough for a breakout watch state, or is the range still early, noisy, or structurally weak?


📌 Overview / What it does

Compression Breakout Readiness [AGPro Series] is a chart-first breakout planning tool designed to evaluate whether a compressed range has developed enough maturity to deserve active attention.

Instead of printing a generic breakout signal, the script studies range contraction, ATR compression, pivot tightening, volume dry-up, directional side bias, invalidation-edge distance, and projected breakout room. These components are converted into a 0-100 Readiness Score and a clear next-action state.

The script produces an active compression box, breakout watch corridor, invalidation edge, target guide, compact state labels, alerts, and a clean AGPro planning panel. It does not predict direction, automate execution, or guarantee that a breakout will follow through.


🎯 Purpose & Design Philosophy

This script was built for traders who want to evaluate the quality of compression before reacting to a breakout attempt.

Many breakout tools only mark the moment price crosses a level. The more useful planning question often comes earlier: is the range actually tight, mature, quiet, and biased enough to watch, or is the structure still too loose?

The design supports a decision-first workflow: identify compression, measure readiness, check risk edge, review the watch side, then decide whether the chart deserves attention.


⚡ Why This Script Is Different

Most tools focus on squeeze dots, breakout arrows, generic consolidation boxes, or simple high/low range breaks.

This script does NOT act as a generic squeeze indicator, a choppiness filter, a support/resistance mapper, or a direct buy/sell signal generator.

Instead, it evaluates compression maturity before and around the breakout edge. The main output is not a trade command. It is a readiness state that helps the user separate READY WATCH conditions from early, neutral, overheated, or invalidated compression contexts.


⚙️ Methodology

1. Context Detection
The script maps the active compression range and evaluates whether current volatility and range width are contracting relative to their baselines.

2. Reference Mapping
It builds the compression box, active breakout watch corridor, invalidation edge, and target guide from the current structure.

3. Reaction Evaluation
The model scores range contraction, ATR compression, pivot tightening, volume dry-up, side bias, and compression age. It also checks whether the invalidation edge is too tight, too wide, or balanced.

4. Visual Output
The result is shown through centered zone text, compact chart labels, clean edge lines, deterministic alerts, and a premium AGPro panel.


🗺️ How to Read the Chart

Compression Box = the active range being evaluated for breakout readiness.

Breakout Watch Corridor = the planning area beyond the active compression edge.

Invalidation Edge = the opposite-side reference used to judge risk context.

Labels = compact state markers such as READY WATCH, WATCH, EDGE REVIEW, PREMATURE, HOT RISK, and INVALID EDGE.

Colors = teal for bullish watch context, pink for bearish or invalid context, amber for caution, and indigo for watch/neutral emphasis.

Panel = the panel summarizes Compression Age, Readiness Score, Expansion Side, Risk Edge, and Action.


🚦 Signals & States

• READY WATCH → compression is mature, biased, and risk edge distance is balanced enough for active review.

• WATCH → compression is developing, but at least one readiness component remains incomplete.

• EDGE REVIEW → price has moved beyond the compression edge and the user should verify the close and broader context.

• PREMATURE → compression has not lasted long enough to build strong maturity.

• HOT RISK → volatility has expanded too aggressively for clean readiness interpretation.

• NO BIAS → compression exists, but the directional side is not clear enough in Auto mode.

• INVALID EDGE → price crossed the active invalidation edge and the prior context may need reset.


🔔 Alerts Logic

Alerts trigger when the planner enters READY WATCH, WATCH, EDGE REVIEW, HOT RISK, or INVALID EDGE state.

These alerts are attention markers. They are not trade instructions, entry signals, broker actions, or automated strategy commands.


🧩 Confluence Logic

The strongest readiness state appears when multiple components align:

Range contraction + ATR compression + pivot tightening + volume dry-up + directional side bias + balanced risk edge.

When those components improve together, the score can rise toward READY WATCH. If volatility becomes too hot, risk becomes distorted, or the active edge fails, the state downgrades.


📊 When to Use

• Before evaluating a possible breakout setup

• During narrow ranges where volatility is compressing

• Around coiling structures that need maturity review

• When comparing whether one compression range is cleaner than another

• On liquid symbols where range, ATR, and volume behavior are meaningful


⚠️ When NOT to Use

• Extremely low-liquidity markets

• Highly noisy micro-timeframes

• News-driven volatility spikes

• Symbols with unreliable or missing volume data

• Situations where the user wants a simple breakout arrow or automated trade signal


🎛️ Key Inputs

• Breakout Watch Side → selects Auto, Bullish Watch, or Bearish Watch evaluation.

• Compression Lookback → defines the active range used for readiness scoring.

• ATR Baseline → controls volatility compression comparison.

• Volume Dry-Up Length → evaluates whether participation is contracting inside compression.

• Minimum Compression Age → controls how mature a range must be before stronger readiness states appear.

• READY / WATCH Thresholds → adjust how selective the planner is.

• Visual settings → control compression box, breakout corridor, range edges, invalidation edge, projection length, labels, and candle tint.

• Panel settings → control panel visibility, location, theme, and font size.


🖥️ Interface & Visual Design

The interface is intentionally chart-first.

The compression box uses centered text so the user can read score and age directly inside the structure. The breakout corridor provides a clean forward planning reference without filling the chart with many competing levels.

The AGPro panel uses a single merged blue header row and a compact five-row decision layout. Label and panel font sizes are adjustable, with Normal as the default.


🧪 Practical Usage Workflow

1. Read the panel Readiness Score and Action.

2. Check whether the compression box is mature or premature.

3. Review the Expansion Side and breakout watch corridor.

4. Compare the Risk Edge with the visible structure.

5. Treat labels and alerts as review prompts, not trade commands.


🔍 Interpretation Guidelines

A higher score means the script sees stronger compression maturity according to its rule set.

READY WATCH does not mean price must break out. It means the compression context is organized enough to deserve attention.

WATCH means the structure may be developing but is not fully mature.

HOT RISK and INVALID EDGE are caution states. They warn that the range may no longer be clean enough for the same readiness read.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not provide guaranteed signals.

It is not a generic squeeze indicator.

It is not a choppiness dashboard.

It is not a support/resistance scanner.

It is not a direct breakout entry tool.


⚠️ Limitations & Transparency

Compression quality depends on the selected lookback, timeframe, volatility baseline, and market condition.

Volume dry-up may be less reliable on symbols with inconsistent exchange volume.

Fast volatility expansion can quickly change the readiness state.

Different timeframes can show different compression ranges and side-bias context.

The script is rule-based and should be interpreted as an analytical planning layer, not as certainty.


🧠 Market Context Notes

Compression by itself is not enough.

A useful breakout watch context also needs maturity, reduced noise, a readable side, and a practical invalidation edge.

This script keeps those elements visible so users can review breakout readiness before reacting emotionally to a candle crossing a range edge.


🧾 Use Case Examples

When a range contracts, ATR falls below baseline, volume dries up, and side bias becomes clear, the planner may move toward WATCH or READY WATCH.

When price pushes beyond the edge while readiness is acceptable, the script can mark EDGE REVIEW so the user can verify the close and broader context.

When ATR expands too aggressively before structure is mature, the planner can show HOT RISK instead of treating every move as a clean breakout context.


🧱 System Philosophy

Compression Breakout Readiness follows the AGPro Series decision-engine approach:

Context first.
Readiness before reaction.
Risk edge before target guide.
Attention markers instead of promises.


🔐 Non-Promise Statement

No script can remove uncertainty.

No state, score, label, alert, box, corridor, or line should be interpreted as guaranteed market direction.


📉 Risk Disclosure

Trading involves risk.

All decisions remain the responsibility of the user.

This script is for educational and analytical chart review only and does not provide financial advice.


📚 Educational Note

Use the script to study how compression matures, weakens, breaks, or invalidates around range edges. The strongest reading comes from combining the panel state with the visible chart structure and broader market context.

## Source Code

````pine
// -------------------------------------------------
// Compression Breakout Readiness [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Compression Breakout Readiness is a chart-first breakout planning tool that
// evaluates whether a compressed range is mature enough for a breakout watch
// state. It studies range contraction, ATR compression, pivot tightening,
// volume dry-up, directional side bias, risk edge distance, and target room to
// produce a 0-100 readiness score with a clear next-action state. Version 1.3
// centers zone ownership and adds price-aware target and invalidation rails.
// -------------------------------------------------

//@version=6
indicator("Compression Breakout Readiness [AGPro Series]",
     shorttitle = "AG Pro CBR",
     overlay = true,
     max_labels_count = 220,
     max_boxes_count = 30,
     max_lines_count = 80)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBg       = color.rgb(15, 23, 42)
panelBorder   = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)
targetBlue    = color.rgb(59, 130, 246)
darkInk       = color.rgb(17, 24, 39)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Readiness Engine"
sideMode = input.string("Auto", "Breakout Watch Side", options = ["Auto", "Bullish Watch", "Bearish Watch"], group = groupEngine, tooltip = "Selects the breakout watch side. Auto reads range position, EMA context, candle pressure, and tightening direction.")
confirmOnClose = input.bool(true, "Confirm On Bar Close", group = groupEngine, tooltip = "When enabled, labels and alerts are confirmed only after the bar closes.")
atrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine, tooltip = "ATR length used for compression, label offsets, corridor sizing, invalidation edge distance, and risk normalization.")
atrBaseLen = input.int(55, "ATR Baseline", minval = 10, maxval = 300, group = groupEngine, tooltip = "Longer ATR baseline used to decide whether current volatility is compressed, normal, or too hot.")
compressionLookback = input.int(34, "Compression Lookback", minval = 12, maxval = 220, group = groupEngine, tooltip = "Lookback used to map the active compression range.")
rangeBaseLen = input.int(89, "Range Width Baseline", minval = 20, maxval = 400, group = groupEngine, tooltip = "Baseline used to compare current range width against normal structural width.")
volumeLen = input.int(34, "Volume Dry-Up Length", minval = 5, maxval = 200, group = groupEngine, tooltip = "Volume baseline used to evaluate volume dry-up. On symbols without reliable volume, the volume component becomes neutral.")
fastEmaLen = input.int(21, "Fast Context EMA", minval = 1, maxval = 200, group = groupEngine, tooltip = "Fast EMA used for side-bias context. It does not create buy or sell signals.")
slowEmaLen = input.int(55, "Slow Context EMA", minval = 2, maxval = 300, group = groupEngine, tooltip = "Slow EMA used for side-bias context.")
slopeBars = input.int(5, "Trend Slope Bars", minval = 1, maxval = 30, group = groupEngine, tooltip = "Bars used to check whether the slow EMA supports the active watch side.")

groupScoring = "Readiness Scoring"
maxRangeRatio = input.float(0.78, "Compression Range Ratio", minval = 0.20, maxval = 1.20, step = 0.01, group = groupScoring, tooltip = "Maximum current-range-to-baseline ratio that can count as compression.")
maxAtrRatio = input.float(0.92, "Compression ATR Ratio", minval = 0.30, maxval = 1.40, step = 0.01, group = groupScoring, tooltip = "Maximum ATR-to-baseline ratio that can count as volatility compression.")
volumeDryRatio = input.float(0.82, "Volume Dry-Up Ratio", minval = 0.20, maxval = 1.40, step = 0.01, group = groupScoring, tooltip = "Volume ratio that represents meaningful dry-up.")
minimumCompressionAge = input.int(5, "Minimum Compression Age", minval = 1, maxval = 80, group = groupScoring, tooltip = "Minimum number of compressed bars preferred before breakout watch becomes mature.")
matureCompressionAge = input.int(18, "Mature Compression Age", minval = 3, maxval = 160, group = groupScoring, tooltip = "Compression age that receives a full age score.")
neutralBiasThreshold = input.float(0.18, "Auto Side Bias Threshold", minval = 0.02, maxval = 0.70, step = 0.01, group = groupScoring, tooltip = "Minimum directional bias required before Auto mode chooses a bullish or bearish expansion side.")
edgeBreakAtr = input.float(0.12, "Edge Review Buffer ATR", minval = 0.01, maxval = 1.50, step = 0.01, group = groupScoring, tooltip = "ATR buffer beyond the compression edge used for edge-review attention markers.")
hotAtrRatio = input.float(1.85, "Hot Volatility Risk", minval = 1.05, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = "ATR ratio above this level is treated as hot volatility risk.")
minimumRiskAtr = input.float(0.55, "Minimum Risk Edge ATR", minval = 0.05, maxval = 4.00, step = 0.05, group = groupScoring, tooltip = "Minimum ATR-normalized distance from price to the invalidation edge.")
maximumRiskAtr = input.float(3.30, "Maximum Risk Edge ATR", minval = 0.30, maxval = 12.00, step = 0.05, group = groupScoring, tooltip = "Maximum ATR-normalized distance from price to the invalidation edge.")
readyThreshold = input.int(72, "READY WATCH Threshold", minval = 40, maxval = 95, group = groupScoring, tooltip = "Minimum 0-100 score required for READY WATCH.")
watchThreshold = input.int(55, "WATCH Threshold", minval = 20, maxval = 90, group = groupScoring, tooltip = "Minimum 0-100 score required for WATCH.")

groupVisual = "Chart Visuals"
showCompressionBox = input.bool(true, "Show Compression Box", group = groupVisual, tooltip = "Shows the active compression box.")
showBreakoutCorridor = input.bool(true, "Show Breakout Corridor", group = groupVisual, tooltip = "Shows the breakout watch corridor in the active side.")
showCenteredBadges = input.bool(true, "Show Centered Zone Badges", group = groupVisual, tooltip = "Shows separate centered labels for compression and breakout corridor context.")
showRangeEdges = input.bool(true, "Show Range Edges", group = groupVisual, tooltip = "Shows the compression range edges as part of the owned compression-box visual set.")
showInvalidationEdge = input.bool(true, "Show Invalidation Edge", group = groupVisual, tooltip = "Shows the invalidation edge behind the active watch side.")
targetRangeMultiple = input.float(1.10, "Corridor Range Multiple", minval = 0.25, maxval = 4.00, step = 0.05, group = groupVisual, tooltip = "Projection multiple applied to the compression range width for the breakout watch corridor.")
projectionBars = input.int(42, "Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = "Bars projected to the right for boxes, guides, badges, and rails.")
adaptiveProjection = input.bool(true, "Adaptive HTF Projection", group = groupVisual, tooltip = "Automatically widens projections on higher timeframes so zones remain readable.")
zoneTransparency = input.int(90, "Zone Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = "Transparency for the compression box and breakout corridor.")
showCandleTint = input.bool(false, "Subtle Candle Tint", group = groupVisual, tooltip = "Applies a subtle candle tint when a meaningful readiness state appears.")

groupLabels = "Labels"
showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = "Shows compact READY, WATCH, EDGE REVIEW, PREMATURE, HOT RISK, and INVALID EDGE labels.")
showContextLabels = input.bool(true, "Show Sparse Context Labels", group = groupLabels, tooltip = "Adds sparse context labels during ongoing readiness states.")
labelCooldownBars = input.int(24, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = "Minimum bars between event labels. The publication default keeps state transitions selective around the active compression structure.")
contextSpacingBars = input.int(44, "Context Label Spacing", minval = 8, maxval = 240, group = groupLabels, tooltip = "Minimum bars between sparse context labels.")
maxVisibleLabels = input.int(7, "Max Visible Labels", minval = 4, maxval = 30, group = groupLabels, tooltip = "Maximum number of historical event and context badges retained so the active zones remain visually dominant.")
labelOffsetAtr = input.float(1.15, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = "ATR-based vertical offset that keeps labels above or below candles.")
showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = "Adds the 0-100 readiness score to chart labels.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupLabels, tooltip = "Font size for all chart labels, zone badges, and right-side tags.")

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = "Shows or hides the AG Pro planning panel.")
panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = "Moves the panel to the preferred chart location.")
panelThemeInput = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = groupPanel, tooltip = "Switches the panel theme while preserving the standard blue header row.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel, tooltip = "Font size for the AG Pro panel.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_norm_high_good(float value, float weak, float strong) =>
    float span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low_good(float value, float good, float bad) =>
    float span = bad - good
    span == 0.0 ? 0.0 : f_clamp((bad - value) / span * 100.0, 0.0, 100.0)

f_text_on(color bgColor) =>
    float bright = (color.r(bgColor) * 299 + color.g(bgColor) * 587 + color.b(bgColor) * 114) / 1000
    bright >= 145 ? darkInk : headerText

f_label_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_panel_position(string posText) =>
    switch posText
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_panel_bg(string theme) =>
    theme == "Clean Light" ? color.rgb(241, 245, 249) : theme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_border(string theme) =>
    theme == "Clean Light" ? color.rgb(148, 163, 184) : theme == "Slate" ? color.rgb(71, 85, 105) : panelBorder

f_panel_label(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string theme, int row) =>
    bool evenRow = row % 2 == 0
    theme == "Clean Light" ? (evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)) : theme == "Slate" ? (evenRow ? color.rgb(37, 49, 70) : color.rgb(30, 41, 59)) : (evenRow ? color.rgb(20, 31, 52) : panelBg)

f_state_color(string stateText) =>
    switch stateText
        "READY WATCH" => bullColor
        "WATCH" => accentColor
        "EDGE REVIEW" => neutralColor
        "HOT RISK" => bearColor
        "INVALID EDGE" => bearColor
        "PREMATURE" => neutralColor
        "NO BIAS" => panelLabelCol
        => panelLabelCol

f_grade(float score) =>
    score >= 80.0 ? "A" : score >= 70.0 ? "B" : score >= 60.0 ? "C" : score >= 45.0 ? "D" : "E"

f_short_state(string state) =>
    switch state
        "READY WATCH" => "READY"
        "EDGE REVIEW" => "EDGE"
        "HOT RISK" => "HOT"
        "INVALID EDGE" => "RESET"
        "PREMATURE" => "EARLY"
        "NO BIAS" => "NO BIAS"
        => state

f_short_side(string side) =>
    switch side
        "Bull Watch" => "BULL"
        "Bear Watch" => "BEAR"
        "Two-Sided" => "2-SIDED"
        => side

f_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_set_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_label_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_label_size(fontSize), text_halign = text.align_right)

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        label oldLabel = array.shift(labels)
        label.delete(oldLabel)

// -------------------------------------------------
// Core measurements
// -------------------------------------------------
float atr = ta.atr(atrLen)
float safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
float atrBase = ta.sma(atr, atrBaseLen)
float atrRatio = not na(atrBase) and atrBase > 0.0 ? atr / atrBase : 1.0

float rangeHigh = ta.highest(high, compressionLookback)
float rangeLow = ta.lowest(low, compressionLookback)
float rangeWidth = math.max(rangeHigh - rangeLow, syminfo.mintick)
float rangeBase = ta.sma(rangeWidth, rangeBaseLen)
float rangeRatio = not na(rangeBase) and rangeBase > 0.0 ? rangeWidth / rangeBase : 1.0

int halfLookback = math.max(4, int(math.round(compressionLookback / 2.0)))
float recentHigh = ta.highest(high, halfLookback)
float recentLow = ta.lowest(low, halfLookback)
float olderHigh = ta.highest(high[halfLookback], halfLookback)
float olderLow = ta.lowest(low[halfLookback], halfLookback)
float recentWidth = math.max(recentHigh - recentLow, syminfo.mintick)
float olderWidth = math.max(olderHigh - olderLow, syminfo.mintick)
float tighteningRatio = olderWidth > 0.0 ? recentWidth / olderWidth : 1.0
float recentMid = (recentHigh + recentLow) * 0.5
float olderMid = (olderHigh + olderLow) * 0.5

float fastEma = ta.ema(close, fastEmaLen)
float slowEma = ta.ema(close, slowEmaLen)
float trendSlope = slowEma - nz(slowEma[slopeBars], slowEma)
float candleRange = math.max(high - low, syminfo.mintick)
float candlePressure = ((close - low) / candleRange - 0.5) * 2.0
float closeLocation = f_clamp((close - rangeLow) / rangeWidth, 0.0, 1.0)
float rangePressure = (closeLocation - 0.5) * 2.0
float emaBias = fastEma > slowEma and trendSlope > 0.0 ? 1.0 : fastEma < slowEma and trendSlope < 0.0 ? -1.0 : 0.0
float midpointBias = f_clamp((recentMid - olderMid) / safeAtr, -1.0, 1.0)
float biasRaw = f_clamp(rangePressure * 0.38 + emaBias * 0.27 + candlePressure * 0.20 + midpointBias * 0.15, -1.0, 1.0)

bool forcedBull = sideMode == "Bullish Watch"
bool forcedBear = sideMode == "Bearish Watch"
bool autoBull = sideMode == "Auto" and biasRaw >= neutralBiasThreshold
bool autoBear = sideMode == "Auto" and biasRaw <= -neutralBiasThreshold
bool bullWatchSide = forcedBull or autoBull
bool bearWatchSide = forcedBear or autoBear
bool twoSided = not bullWatchSide and not bearWatchSide
string expansionSide = bullWatchSide ? "Bull Watch" : bearWatchSide ? "Bear Watch" : "Two-Sided"

float volumeAvg = ta.sma(volume, volumeLen)
bool hasVolume = not na(volume) and not na(volumeAvg) and volumeAvg > 0.0
float volumeRatio = hasVolume ? volume / volumeAvg : 1.0

bool compressionCore = rangeRatio <= maxRangeRatio and atrRatio <= maxAtrRatio
var int compressionAge = 0
compressionAge := compressionCore ? compressionAge + 1 : 0

float rangeScore = f_norm_low_good(rangeRatio, maxRangeRatio, 1.22)
float atrCompressionScore = f_norm_low_good(atrRatio, maxAtrRatio, 1.28)
float tighteningScore = f_norm_low_good(tighteningRatio, 0.58, 1.20)
float volumeDryScore = hasVolume ? f_norm_low_good(volumeRatio, volumeDryRatio, 1.22) : 50.0
float sideBiasScore = twoSided ? 35.0 : f_norm_high_good(math.abs(biasRaw), neutralBiasThreshold, 0.92)
float ageScore = f_norm_high_good(compressionAge, 1.0, matureCompressionAge)
float readinessScore = rangeScore * 0.23 + atrCompressionScore * 0.18 + tighteningScore * 0.17 + volumeDryScore * 0.15 + sideBiasScore * 0.17 + ageScore * 0.10
readinessScore := f_clamp(readinessScore, 0.0, 100.0)

float riskBuffer = safeAtr * edgeBreakAtr
float invalidationEdge = bullWatchSide ? rangeLow - riskBuffer : bearWatchSide ? rangeHigh + riskBuffer : na
float riskEdgeDistanceAtr = not na(invalidationEdge) ? math.abs(close - invalidationEdge) / safeAtr : na
bool riskTooTight = not na(riskEdgeDistanceAtr) and riskEdgeDistanceAtr < minimumRiskAtr
bool riskTooWide = not na(riskEdgeDistanceAtr) and riskEdgeDistanceAtr > maximumRiskAtr
bool riskBalanced = not na(riskEdgeDistanceAtr) and not riskTooTight and not riskTooWide
string riskText = riskTooTight ? "Tight" : riskTooWide ? "Wide" : riskBalanced ? "Balanced" : "Neutral"

float targetGuide = bullWatchSide ? rangeHigh + rangeWidth * targetRangeMultiple : bearWatchSide ? rangeLow - rangeWidth * targetRangeMultiple : na
float corridorTop = bullWatchSide ? targetGuide : bearWatchSide ? rangeLow : na
float corridorBottom = bullWatchSide ? rangeHigh : bearWatchSide ? targetGuide : na

bool signalBar = not confirmOnClose or barstate.isconfirmed
bool hotVolatility = atrRatio > hotAtrRatio
bool matureEnough = compressionAge >= minimumCompressionAge
bool edgeReviewBull = bullWatchSide and close > rangeHigh + safeAtr * edgeBreakAtr
bool edgeReviewBear = bearWatchSide and close < rangeLow - safeAtr * edgeBreakAtr
bool edgeReview = edgeReviewBull or edgeReviewBear
bool invalidEdge = bullWatchSide and close < invalidationEdge or bearWatchSide and close > invalidationEdge

string stateText = "BUILDING"
if invalidEdge
    stateText := "INVALID EDGE"
else if hotVolatility
    stateText := "HOT RISK"
else if edgeReview and readinessScore >= watchThreshold
    stateText := "EDGE REVIEW"
else if not matureEnough
    stateText := "PREMATURE"
else if twoSided
    stateText := "NO BIAS"
else if readinessScore >= readyThreshold and riskBalanced
    stateText := "READY WATCH"
else if readinessScore >= watchThreshold
    stateText := "WATCH"

color stateColor = f_state_color(stateText)
color activeSideColor = bullWatchSide ? bullColor : bearWatchSide ? bearColor : accentColor
string actionText = switch stateText
    "READY WATCH" => "Review edge"
    "WATCH" => "Let mature"
    "EDGE REVIEW" => "Verify close"
    "HOT RISK" => "Reduce trust"
    "INVALID EDGE" => "Reset context"
    "PREMATURE" => "Wait age"
    "NO BIAS" => "Wait side"
    => "Monitor"

// -------------------------------------------------
// Target-room reach proof (stop-aware)
// -------------------------------------------------
// When a watch-grade state first appears, did price reach the target-room guide
// before crossing the invalidation edge? Win = target room first, Loss =
// invalidation edge first, neither inside the window = uncounted.
var int   pfTotal  = 0
var int   pfWins   = 0
var bool  pfOpen   = false
var int   pfDir    = 0
var float pfTarget = na
var float pfStop   = na
var int   pfBar    = na
int pfWindow = 60

if signalBar
    if pfOpen
        bool pfHitStop   = pfDir == 1 ? close < pfStop : close > pfStop
        bool pfHitTarget = pfDir == 1 ? high >= pfTarget : low <= pfTarget
        if pfHitStop
            pfTotal += 1
            pfOpen  := false
        else if pfHitTarget
            pfTotal += 1
            pfWins  += 1
            pfOpen  := false
        else if not na(pfBar) and bar_index - pfBar > pfWindow
            pfOpen := false
    bool enteredWatch = (stateText == "READY WATCH" or stateText == "WATCH") and not (stateText[1] == "READY WATCH" or stateText[1] == "WATCH")
    if enteredWatch and not pfOpen and not twoSided and not na(targetGuide) and not na(invalidationEdge)
        pfOpen   := true
        pfDir    := bullWatchSide ? 1 : -1
        pfTarget := targetGuide
        pfStop   := invalidationEdge
        pfBar    := bar_index

float pfRate = pfTotal > 0 ? pfWins / pfTotal * 100.0 : na
reachRateTxt = pfTotal >= 6 ? str.tostring(math.round(pfRate)) + "%  (" + str.tostring(pfTotal) + ")" : "Building (" + str.tostring(pfTotal) + ")"
reachRateCol = pfTotal >= 6 ? (pfRate >= 55.0 ? bullColor : pfRate >= 45.0 ? neutralColor : bearColor) : f_panel_value(panelThemeInput)

// -------------------------------------------------
// Chart objects
// -------------------------------------------------
var box compressionBox = na
var box breakoutCorridor = na
var line rangeHighLine = na
var line rangeLowLine = na
var line invalidLine = na
var line targetLine = na
var label compressionBadge = na
var label corridorBadge = na
var label invalidTag = na
var label targetTag = na
var array<label> eventLabels = array.new<label>()
var int lastEventLabelBar = na
var int lastContextLabelBar = na
var int lastTopLabelBar = na
var int lastBottomLabelBar = na
var string previousState = ""

int projectionBoost = adaptiveProjection ? timeframe.isweekly ? 2 : timeframe.ismonthly ? 3 : 1 : 1
int leftEdge = math.max(0, bar_index - compressionLookback + 1)
int rightEdge = bar_index + projectionBars * projectionBoost
int boxCenterX = leftEdge + int(math.round((rightEdge - leftEdge) * 0.50))
int corridorCenterX = bar_index + int(math.round((rightEdge - bar_index) * 0.50))
float compressionMid = (rangeHigh + rangeLow) * 0.5
float corridorMid = not na(corridorTop) and not na(corridorBottom) ? (corridorTop + corridorBottom) * 0.5 : na
string scoreText = str.tostring(int(math.round(readinessScore)))
string boxText = "COMPRESSION | Q" + scoreText + " " + f_grade(readinessScore) + "\n" + str.tostring(compressionAge) + " Bars"
string corridorText = str.upper(expansionSide) + " | Q" + scoreText + " " + f_grade(readinessScore) + "\nRISK " + str.upper(riskText)

if showCompressionBox
    if na(compressionBox)
        compressionBox := box.new(left = leftEdge, top = rangeHigh, right = rightEdge, bottom = rangeLow, xloc = xloc.bar_index, bgcolor = color.new(activeSideColor, zoneTransparency), border_color = color.new(activeSideColor, 28), border_width = 1)
    else
        box.set_left(compressionBox, leftEdge)
        box.set_right(compressionBox, rightEdge)
        box.set_top(compressionBox, rangeHigh)
        box.set_bottom(compressionBox, rangeLow)
        box.set_bgcolor(compressionBox, color.new(activeSideColor, zoneTransparency))
        box.set_border_color(compressionBox, color.new(activeSideColor, 28))
    if showCenteredBadges
        if na(compressionBadge)
            compressionBadge := label.new(boxCenterX, compressionMid, boxText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(activeSideColor, 8), textcolor = f_text_on(activeSideColor), size = f_label_size(labelSizeInput), textalign = text.align_center)
        else
            label.set_xy(compressionBadge, boxCenterX, compressionMid)
            label.set_text(compressionBadge, boxText)
            label.set_color(compressionBadge, color.new(activeSideColor, 8))
            label.set_textcolor(compressionBadge, f_text_on(activeSideColor))
            label.set_size(compressionBadge, f_label_size(labelSizeInput))
            label.set_style(compressionBadge, label.style_label_center)
    else
        if not na(compressionBadge)
            label.delete(compressionBadge)
            compressionBadge := na
else
    if not na(compressionBox)
        box.delete(compressionBox)
        compressionBox := na
    if not na(compressionBadge)
        label.delete(compressionBadge)
        compressionBadge := na

if showBreakoutCorridor and not twoSided and not na(targetGuide)
    if na(breakoutCorridor)
        breakoutCorridor := box.new(left = bar_index, top = corridorTop, right = rightEdge, bottom = corridorBottom, xloc = xloc.bar_index, bgcolor = color.new(activeSideColor, zoneTransparency), border_color = color.new(activeSideColor, 35), border_width = 1)
    else
        box.set_left(breakoutCorridor, bar_index)
        box.set_right(breakoutCorridor, rightEdge)
        box.set_top(breakoutCorridor, corridorTop)
        box.set_bottom(breakoutCorridor, corridorBottom)
        box.set_bgcolor(breakoutCorridor, color.new(activeSideColor, zoneTransparency))
        box.set_border_color(breakoutCorridor, color.new(activeSideColor, 35))
    if showCenteredBadges
        float finalCorridorMid = corridorMid
        if na(corridorBadge)
            corridorBadge := label.new(corridorCenterX, finalCorridorMid, corridorText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(targetBlue, 5), textcolor = f_text_on(targetBlue), size = f_label_size(labelSizeInput), textalign = text.align_center)
        else
            label.set_xy(corridorBadge, corridorCenterX, finalCorridorMid)
            label.set_text(corridorBadge, corridorText)
            label.set_color(corridorBadge, color.new(targetBlue, 5))
            label.set_textcolor(corridorBadge, f_text_on(targetBlue))
            label.set_size(corridorBadge, f_label_size(labelSizeInput))
            label.set_style(corridorBadge, label.style_label_center)
else
    if not na(breakoutCorridor)
        box.delete(breakoutCorridor)
        breakoutCorridor := na
    if not na(corridorBadge)
        label.delete(corridorBadge)
        corridorBadge := na

if showRangeEdges and showCompressionBox
    if na(rangeHighLine)
        rangeHighLine := line.new(leftEdge, rangeHigh, rightEdge, rangeHigh, xloc = xloc.bar_index, color = color.new(accentColor, 25), width = 1)
        rangeLowLine := line.new(leftEdge, rangeLow, rightEdge, rangeLow, xloc = xloc.bar_index, color = color.new(accentColor, 25), width = 1)
    else
        line.set_xy1(rangeHighLine, leftEdge, rangeHigh)
        line.set_xy2(rangeHighLine, rightEdge, rangeHigh)
        line.set_xy1(rangeLowLine, leftEdge, rangeLow)
        line.set_xy2(rangeLowLine, rightEdge, rangeLow)
else
    if not na(rangeHighLine)
        line.delete(rangeHighLine)
        line.delete(rangeLowLine)
        rangeHighLine := na
        rangeLowLine := na

if showInvalidationEdge and not twoSided and not na(invalidationEdge)
    if na(invalidLine)
        invalidLine := line.new(bar_index, invalidationEdge, rightEdge, invalidationEdge, xloc = xloc.bar_index, color = color.new(bearColor, 8), width = 1, style = line.style_dotted)
    else
        line.set_xy1(invalidLine, bar_index, invalidationEdge)
        line.set_xy2(invalidLine, rightEdge, invalidationEdge)
    if na(invalidTag)
        invalidTag := label.new(rightEdge + 1, invalidationEdge, "INVALID " + f_price(invalidationEdge), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bearColor, 8), textcolor = f_text_on(bearColor), size = f_label_size(labelSizeInput))
    else
        label.set_xy(invalidTag, rightEdge + 1, invalidationEdge)
        label.set_text(invalidTag, "INVALID " + f_price(invalidationEdge))
        label.set_color(invalidTag, color.new(bearColor, 8))
        label.set_textcolor(invalidTag, f_text_on(bearColor))
        label.set_size(invalidTag, f_label_size(labelSizeInput))
else
    if not na(invalidLine)
        line.delete(invalidLine)
        invalidLine := na
    if not na(invalidTag)
        label.delete(invalidTag)
        invalidTag := na

if showBreakoutCorridor and not twoSided and not na(targetGuide)
    if na(targetLine)
        targetLine := line.new(bar_index, targetGuide, rightEdge, targetGuide, xloc = xloc.bar_index, color = color.new(activeSideColor, 10), width = 1, style = line.style_dashed)
    else
        line.set_xy1(targetLine, bar_index, targetGuide)
        line.set_xy2(targetLine, rightEdge, targetGuide)
    if na(targetTag)
        targetTag := label.new(rightEdge + 1, targetGuide, "TARGET " + f_price(targetGuide), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(activeSideColor, 5), textcolor = f_text_on(activeSideColor), size = f_label_size(labelSizeInput))
    else
        label.set_xy(targetTag, rightEdge + 1, targetGuide)
        label.set_text(targetTag, "TARGET " + f_price(targetGuide))
        label.set_color(targetTag, color.new(activeSideColor, 5))
        label.set_textcolor(targetTag, f_text_on(activeSideColor))
        label.set_size(targetTag, f_label_size(labelSizeInput))
else
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na
    if not na(targetTag)
        label.delete(targetTag)
        targetTag := na

barcolor(showCandleTint and (stateText == "READY WATCH" or stateText == "EDGE REVIEW") ? color.new(stateColor, 78) : na)

// -------------------------------------------------
// Labels
// -------------------------------------------------
bool stateChanged = stateText != previousState
bool canEventLabel = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
bool canContextLabel = na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars
bool showPriorityEvent = stateChanged and (stateText == "READY WATCH" or stateText == "WATCH" or stateText == "EDGE REVIEW" or stateText == "HOT RISK" or stateText == "INVALID EDGE" or stateText == "PREMATURE")

if signalBar and showEventLabels and showPriorityEvent and canEventLabel
    bool labelBelow = bullWatchSide and stateText != "HOT RISK" and stateText != "INVALID EDGE"
    bool recentSameLane = labelBelow ? not na(lastBottomLabelBar) and bar_index - lastBottomLabelBar <= labelCooldownBars : not na(lastTopLabelBar) and bar_index - lastTopLabelBar <= labelCooldownBars
    float eventOffset = labelOffsetAtr * (recentSameLane ? 1.75 : 1.0)
    float labelY = labelBelow ? low - safeAtr * eventOffset : high + safeAtr * eventOffset
    string labelText = f_short_state(stateText)
    if showLabelScore
        labelText += " | Q" + scoreText
    label newLabel = label.new(bar_index, labelY, labelText, xloc = xloc.bar_index, style = labelBelow ? label.style_label_up : label.style_label_down, color = color.new(stateColor, 0), textcolor = f_text_on(stateColor), size = f_label_size(labelSizeInput))
    array.push(eventLabels, newLabel)
    lastEventLabelBar := bar_index
    if labelBelow
        lastBottomLabelBar := bar_index
    else
        lastTopLabelBar := bar_index
    f_trim_labels(eventLabels, maxVisibleLabels)

bool contextClearOfEvent = na(lastEventLabelBar) or bar_index - lastEventLabelBar > math.max(3, int(math.round(labelCooldownBars * 0.75)))
if signalBar and showContextLabels and canContextLabel and contextClearOfEvent and (stateText == "READY WATCH" or stateText == "WATCH" or stateText == "BUILDING")
    bool labelBelow = bullWatchSide
    bool recentSameLane = labelBelow ? not na(lastBottomLabelBar) and bar_index - lastBottomLabelBar <= labelCooldownBars : not na(lastTopLabelBar) and bar_index - lastTopLabelBar <= labelCooldownBars
    float contextOffset = labelOffsetAtr * (recentSameLane ? 1.85 : 1.0)
    float labelY = labelBelow ? low - safeAtr * contextOffset : high + safeAtr * contextOffset
    string contextText = stateText == "BUILDING" ? "BUILD | Q" + scoreText : f_short_side(expansionSide) + " | Q" + scoreText
    label contextLabel = label.new(bar_index, labelY, contextText, xloc = xloc.bar_index, style = labelBelow ? label.style_label_up : label.style_label_down, color = color.new(activeSideColor, 15), textcolor = f_text_on(activeSideColor), size = f_label_size(labelSizeInput))
    array.push(eventLabels, contextLabel)
    lastContextLabelBar := bar_index
    if labelBelow
        lastBottomLabelBar := bar_index
    else
        lastTopLabelBar := bar_index
    f_trim_labels(eventLabels, maxVisibleLabels)

previousState := stateText

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table panel = table.new(f_panel_position(panelLocationInput), 2, 7, bgcolor = f_panel_bg(panelThemeInput), frame_color = f_panel_border(panelThemeInput), frame_width = 1, border_color = f_panel_border(panelThemeInput), border_width = 1)

if barstate.islast
    table.set_position(panel, f_panel_position(panelLocationInput))
    table.clear(panel, 0, 0, 1, 6)
    if showPanel
        string theme = panelThemeInput
        string panelSize = panelFontSizeInput
        string readinessRead = scoreText + " / 100  " + f_grade(readinessScore)
        string ageRead = str.tostring(compressionAge) + " bars"
        string riskRead = not na(riskEdgeDistanceAtr) ? riskText + "  " + str.tostring(riskEdgeDistanceAtr, "#.##") + " ATR" : "Neutral"
        table.cell(panel, 0, 0, "AG Pro Compression Breakout Readiness", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelSize), text_halign = text.align_center)
        table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelSize))
        table.merge_cells(panel, 0, 0, 1, 0)
        f_set_row(panel, 1, "Compression Age", ageRead, compressionAge >= minimumCompressionAge ? accentColor : neutralColor, theme, panelSize)
        f_set_row(panel, 2, "Readiness Score", readinessRead, stateColor, theme, panelSize)
        f_set_row(panel, 3, "Expansion Side", expansionSide, twoSided ? neutralColor : activeSideColor, theme, panelSize)
        f_set_row(panel, 4, "Risk Edge", riskRead, riskBalanced ? bullColor : neutralColor, theme, panelSize)
        f_set_row(panel, 5, "Reach Rate", reachRateTxt, reachRateCol, theme, panelSize)
        f_set_row(panel, 6, "Action", actionText, stateColor, theme, panelSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
bool readyWatch = signalBar and stateText == "READY WATCH"
bool watchState = signalBar and stateText == "WATCH"
bool edgeReviewState = signalBar and stateText == "EDGE REVIEW"
bool hotRiskState = signalBar and stateText == "HOT RISK"
bool invalidEdgeState = signalBar and stateText == "INVALID EDGE"

alertcondition(readyWatch and not readyWatch[1], "Compression Ready Watch", "Compression Breakout Readiness: READY WATCH state appeared. Review the compression edge, risk edge, and broader context.")
alertcondition(watchState and not watchState[1], "Compression Watch", "Compression Breakout Readiness: WATCH state appeared. Compression is developing but does not yet meet full readiness.")
alertcondition(edgeReviewState and not edgeReviewState[1], "Compression Edge Review", "Compression Breakout Readiness: price moved beyond the compression edge. Treat this as an attention marker, not a trade instruction.")
alertcondition(hotRiskState and not hotRiskState[1], "Hot Volatility Risk", "Compression Breakout Readiness: volatility expanded beyond the hot-risk threshold. Review quality before trusting the range.")
alertcondition(invalidEdgeState and not invalidEdgeState[1], "Compression Invalid Edge", "Compression Breakout Readiness: price crossed the active invalidation edge. The prior readiness context may need reset.")
````
