# Trend Maturity Ladder [AGPro Series]

- url: https://www.tradingview.com/script/woyHy0hJ-Trend-Maturity-Ladder-AGPro-Series/
- type: indicator
- pine_id: PUB;24b5cde1a9bd4798bf30cb7960f928b1
- version: 6.0

## Description

Trend Maturity Ladder [AGPro Series]

🧠 Core Idea

Is the trend still early, healthy, mature, stretched, or vulnerable to exhaustion?

[image]https://www.tradingview.com/x/ORQ58zs4/[/image]

📌 Overview / What it does

Trend Maturity Ladder is a trend lifecycle visualization tool built to classify the stage of an active trend.

The script builds a staged trend ladder, maps a healthy pullback shelf, marks an invalidation shelf, tracks maturity score, evaluates extension, identifies exhaustion risk, and summarizes the current lifecycle state in an AG Pro panel.

It does not predict price direction, automate trades, or claim that a mature trend must reverse. It is a structured decision-support tool for reading trend stage, pullback quality, and late-trend risk.


🎯 Purpose & Design Philosophy

Many trend tools answer only one question:

Is price trending?

This script was built to answer a more useful question:

Where is the trend in its lifecycle?

The design goal is to help traders separate early trend development, healthy continuation, mature structure, stretched extension, and invalidation pressure.


⚡ Why This Script Is Different

Most trend tools focus on moving average direction, ribbon color, or generic trend strength.

This script does NOT act as another trend-strength meter or moving-average ribbon.

Instead, it models the trend as a ladder with stages: early trend, active trend, mature trend, stretched trend, exhaustion watch, and invalidation pressure. It combines trend alignment, slope, ADX, distance from the slow trend reference, trend age, pullback depth, and momentum risk into one visual lifecycle map.


⚙️ Methodology

1. Context Detection

The script checks fast, slow, and anchor trend alignment to determine whether the market has a bullish trend, bearish trend, or mixed structure.

2. Maturity Scoring

It scores trend age, ATR-adjusted extension, slope, ADX, and moving-average alignment to estimate how mature the trend is.

3. Pullback Evaluation

It builds a healthy pullback shelf around the trend references and checks whether price is pulling back without breaking the broader ladder.

4. Exhaustion and Invalidation Review

It identifies late-trend extension risk and invalidation pressure when price closes through the trend shelf.

5. Visual Output

The chart displays maturity ladder zones, pullback shelves, invalidation shelves, trend rails, event labels, right-side tags, alerts, and a compact AG Pro panel.


🗺️ How to Read the Chart

Trend Maturity Ladder = the active lifecycle zone around the current trend.

Healthy Pullback Shelf = the area where pullbacks can remain structurally constructive.

Invalidation Shelf = the area where the trend ladder becomes vulnerable.

Trend Rails = fast, slow, and anchor trend references.

EARLY TREND = trend alignment is fresh.

ACTIVE TREND = trend structure is aligned and still developing.

MATURE TREND = trend has aged and expanded meaningfully.

STRETCHED TREND = the trend is extended relative to its slow reference.

EXHAUSTION WATCH = maturity, extension, and momentum conditions suggest late-trend risk.

INVALIDATION PRESSURE = price has closed through the invalidation shelf.

Panel = summarizes trend stage, maturity score, direction, pullback health, exhaustion risk, age, extension, and next context.


🚦 Signals & States

• EARLY TREND → trend alignment is fresh and still developing.

• ACTIVE TREND → trend is aligned and not yet deeply mature.

• MATURE TREND → trend has aged and expanded.

• STRETCHED TREND → price is extended from the slow trend reference.

• HEALTHY PULLBACK → price has pulled into the trend shelf without invalidating it.

• EXHAUSTION RISK → maturity, extension, and momentum risk are aligned.

• INVALIDATION PRESSURE → price has closed through the invalidation shelf.

• NO CLEAR TREND → fast, slow, and anchor references are not aligned.


🔔 Alerts Logic

Alerts trigger when a major trend lifecycle state appears.

• Trend Maturity Transition → the active trend stage changes.

• Healthy Trend Pullback → price pulls into the healthy trend shelf without invalidating the ladder.

• Trend Exhaustion Risk → maturity, extension, and momentum conditions align.

• Trend Invalidation Pressure → price closes through the invalidation shelf.

Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The context becomes stronger when:

• Fast, slow, and anchor trend references align
• The slow reference has directional slope
• ADX supports directional structure
• Pullbacks respect the healthy shelf
• Extension is not excessively stretched
• The panel state agrees with the chart label

Late-trend caution increases when maturity, extension, and RSI pressure align.


📊 When to Use

• Trend-following review
• Pullback continuation planning
• Late-trend risk monitoring
• Crypto, stocks, futures, forex, and liquid markets
• 30m, 1H, 4H, 1D, and 1W charts
• Markets where trend structure is visible


⚠️ When NOT to Use

• Very choppy, non-directional markets
• Low-liquidity assets
• Extremely noisy micro timeframes
• Markets with frequent gaps that distort trend references
• Situations where a single trend score should not be over-interpreted
• When the user wants guaranteed entries or exits


🎛️ Key Inputs

• Fast Trend Length → controls short-term trend pressure.

• Slow Trend Length → controls the main maturity reference.

• Anchor Trend Length → filters weak or mixed trend regimes.

• ATR Length → controls ladder spacing, extension scoring, and label offsets.

• Early Trend Max Age → defines how long a fresh trend can remain early.

• Mature Trend Age → defines when age contributes strongly to maturity.

• Stretched Distance ATR → defines when trend extension becomes stretched.

• Healthy Pullback Width ATR → controls the pullback shelf thickness.

• Invalidation Shelf ATR → controls the distance of the invalidation shelf.

• Exhaustion RSI Level → adds momentum pressure to exhaustion-risk logic.


🖥️ Interface & Visual Design

The visual hierarchy is built around the trend lifecycle:

The ladder shows the active maturity zone.

The pullback shelf shows where continuation can be evaluated.

The invalidation shelf shows where the trend becomes vulnerable.

Event labels mark lifecycle transitions and risk states.

Right-side tags keep the current trend stage visible.

The AG Pro panel compresses the current trend lifecycle into a fast, readable summary.


🧪 Practical Usage Workflow

1. Read the panel trend stage.

2. Check whether trend direction is aligned.

3. Locate the healthy pullback shelf.

4. Watch whether price respects or breaks the shelf.

5. Check maturity score and exhaustion risk.

6. Confirm with market structure, liquidity, volume, and risk planning.


🔍 Interpretation Guidelines

An early trend does not guarantee continuation.

A mature trend does not guarantee reversal.

Exhaustion risk does not mean price must immediately turn.

Invalidation pressure means the current ladder structure has weakened.

The script is best used to understand trend lifecycle context, not to replace independent analysis.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not provide guaranteed entry or exit signals.

It is not a moving-average ribbon or a simple trend-strength meter.


⚠️ Limitations & Transparency

Trend stages depend on timeframe.

Choppy markets can create frequent stage changes.

Strong news moves can stretch trend references quickly.

Low-liquidity markets may create unreliable trend readings.

Different assets may require different trend lengths.


🧠 Market Context Notes

Trends often move through recognizable phases:

alignment → expansion → maturity → extension → pullback or invalidation.

This script visualizes that sequence so the user can avoid treating every trend as equally fresh.


🧾 Use Case Examples

If trend references align shortly after a transition, the script may classify EARLY TREND.

If price pulls into the shelf while the ladder remains intact, the script may mark HEALTHY PULLBACK.

If the trend becomes aged and extended while RSI is stretched, the script may mark EXHAUSTION RISK.

If price closes through the invalidation shelf, the script may mark INVALIDATION PRESSURE.


🧱 System Philosophy

The goal is not to chase trend strength.

The goal is to understand trend timing.

This script treats trend as a lifecycle:

early → active → mature → stretched → vulnerable.


🔐 Non-Promise Statement

No trend stage guarantees future price direction.

No pullback shelf guarantees continuation.

No exhaustion label guarantees reversal.

All outputs should be interpreted as analytical context.


📉 Risk Disclosure

Trading involves risk.

This script is for educational and analytical purposes only.

It does not provide financial advice, investment advice, or guaranteed trading outcomes.

Users are fully responsible for their own decisions, risk management, and trade execution.


📚 Educational Note

Use the script to study where trends tend to age, stretch, reset, or fail.

The most important question is not only whether a market is trending.

The better question is whether the trend is still fresh enough to deserve attention.

## Source Code

````pine
// -------------------------------------------------
// Trend Maturity Ladder [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5.1
//
// Trend Maturity Ladder studies whether an active trend is early, healthy,
// mature, stretched, or vulnerable to invalidation pressure. It builds a
// staged trend lifecycle map with maturity bands, pullback shelves, trend
// rails, and a dashboard panel, and adds a confirmation-anchored proof layer
// (Follow, Hold, React, Flip rates) that shows how past trends on this symbol
// followed through, held, or failed after they were established.
// -------------------------------------------------

//@version=6
indicator("Trend Maturity Ladder [AGPro Series]",
     shorttitle       = "AG Pro TML",
     overlay          = true,
     max_labels_count = 100,
     max_lines_count  = 20,
     max_boxes_count  = 12,
     max_bars_back    = 1200)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
color headerBg      = color.rgb(37, 99, 235)
color headerText    = color.rgb(245, 247, 250)
color panelBg       = color.rgb(15, 23, 42)
color panelBorder   = color.rgb(51, 65, 85)
color panelLabelCol = color.rgb(148, 163, 184)
color panelValueCol = color.rgb(226, 232, 240)
color bullColor     = color.rgb(34, 197, 166)
color bearColor     = color.rgb(244, 114, 182)
color neutralColor  = color.rgb(245, 189, 92)
color accentColor   = color.rgb(129, 140, 248)
color darkText      = color.rgb(17, 24, 39)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string G_ENGINE = "Trend Maturity Engine"
string G_PULL   = "Pullback and Risk Logic"
string G_VISUAL = "Visuals"
string G_PANEL  = "Panel"
string G_PROOF  = "Proof"
string G_ALERTS = "Alerts"

int fastLen = input.int(21, "Fast Trend Length", minval = 2, maxval = 300, group = G_ENGINE, tooltip = "Fast trend average used to judge short-term trend pressure and pullback behavior.")
int slowLen = input.int(55, "Slow Trend Length", minval = 5, maxval = 500, group = G_ENGINE, tooltip = "Slow trend average used as the main maturity reference.")
int anchorLen = input.int(144, "Anchor Trend Length", minval = 20, maxval = 800, group = G_ENGINE, tooltip = "Longer trend average used to filter weak or mixed trend regimes.")
int atrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = G_ENGINE, tooltip = "ATR length used for ladder spacing, extension scoring, and label offsets.")
int slopeLen = input.int(8, "Slope Lookback", minval = 2, maxval = 100, group = G_ENGINE, tooltip = "Lookback used to measure whether the slow trend reference is rising or falling.")
int adxLen = input.int(14, "ADX Length", minval = 3, maxval = 100, group = G_ENGINE, tooltip = "DMI/ADX length used to estimate directional trend strength.")
int adxSmooth = input.int(14, "ADX Smoothing", minval = 3, maxval = 100, group = G_ENGINE, tooltip = "Smoothing length used by the ADX calculation.")
int earlyAgeBars = input.int(18, "Early Trend Max Age", minval = 3, maxval = 200, group = G_ENGINE, tooltip = "Maximum bars after a fresh trend transition where the trend can still be classified as early.")
int matureAgeBars = input.int(70, "Mature Trend Age", minval = 10, maxval = 500, group = G_ENGINE, tooltip = "Bars after trend transition where age starts contributing strongly to maturity.")
float stretchedAtr = input.float(2.25, "Stretched Distance ATR", minval = 0.30, maxval = 8.0, step = 0.05, group = G_ENGINE, tooltip = "Distance from the slow trend reference where the trend starts to look stretched.")

float pullbackAtr = input.float(0.65, "Healthy Pullback Width ATR", minval = 0.10, maxval = 4.0, step = 0.05, group = G_PULL, tooltip = "Thickness of the healthy pullback shelf around the fast and slow trend references.")
float invalidationAtr = input.float(0.85, "Invalidation Shelf ATR", minval = 0.10, maxval = 5.0, step = 0.05, group = G_PULL, tooltip = "Distance beyond the slow trend reference where the trend ladder becomes vulnerable to invalidation.")
int exhaustionRsi = input.int(72, "Exhaustion RSI Level", minval = 50, maxval = 95, group = G_PULL, tooltip = "RSI level used with extension and maturity to flag potential upside trend exhaustion. The inverse level is used for downside trends.")
int rsiLen = input.int(14, "RSI Length", minval = 2, maxval = 100, group = G_PULL, tooltip = "RSI length used only as one part of the exhaustion-risk filter.")

bool showLadder = input.bool(true, "Show Maturity Ladder", group = G_VISUAL, tooltip = "Displays the active trend maturity ladder as projected zones.")
bool showPullbackShelf = input.bool(true, "Show Pullback Shelf", group = G_VISUAL, tooltip = "Displays the healthy pullback shelf where trend continuation can be evaluated.")
bool showInvalidationShelf = input.bool(true, "Show Invalidation Shelf", group = G_VISUAL, tooltip = "Displays the trend invalidation shelf below bullish trends or above bearish trends.")
bool showTrendRails = input.bool(true, "Show Trend Rails", group = G_VISUAL, tooltip = "Draws fast, slow, and anchor trend rails for context.")
bool showEventLabels = input.bool(true, "Show Maturity Labels", group = G_VISUAL, tooltip = "Prints curated labels for stage transitions, healthy pullbacks, exhaustion risk, and invalidation pressure.")
string eventLabelMode = input.string("Premium", "Event Label Mode", options = ["Premium", "Detailed"], group = G_VISUAL, tooltip = "Premium mode focuses on meaningful stage changes. Detailed mode also labels lower-priority pullback states.")
bool showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL, tooltip = "Shows compact right-side tags for maturity ladder, pullback shelf, and invalidation shelf.")
int projectionBars = input.int(64, "Projection Bars", minval = 10, maxval = 500, group = G_VISUAL, tooltip = "How far the ladder zones and right-side tags project to the right.")
bool adaptiveProjection = input.bool(true, "Adaptive HTF Projection", group = G_VISUAL, tooltip = "Shortens projections on daily, weekly, and monthly charts so high-timeframe screenshots stay readable.")
int labelCooldownBars = input.int(30, "Event Label Cooldown", minval = 1, maxval = 120, group = G_VISUAL, tooltip = "Minimum spacing between event labels so the chart remains readable and premium.")
int minEventQuality = input.int(50, "Minimum Event Label Quality", minval = 1, maxval = 100, group = G_VISUAL, tooltip = "Minimum quality required before event labels are printed in Premium mode. Detailed mode remains more permissive.")
float eventLabelOffsetAtr = input.float(1.25, "Event Label Offset ATR", minval = 0.20, maxval = 5.0, step = 0.05, group = G_VISUAL, tooltip = "Moves event labels away from candles and ladder zones to reduce overlap.")
int maxVisibleLabels = input.int(7, "Max Visible Labels", minval = 4, maxval = 60, group = G_VISUAL, tooltip = "Maximum number of recent event labels retained on the chart.")
string labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL, tooltip = "Text size used by event labels, ladder labels, and right-side tags.")

bool showPanel = input.bool(true, "Show Panel", group = G_PANEL, tooltip = "Shows or hides the AG Pro trend maturity panel.")
string panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = G_PANEL, tooltip = "Controls where the panel appears on the chart.")
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = G_PANEL, tooltip = "Switches the panel between a dark AGPro surface and a clean light surface.")
string panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL, tooltip = "Text size used inside the panel.")

bool showProof = input.bool(true, "Show Proof Layer", group = G_PROOF, tooltip = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across past established trends on the current symbol and timeframe. These are historical outcome rates, not predictions.")
int proofHorizonBars = input.int(30, "Proof Horizon Bars", minval = 5, maxval = 200, group = G_PROOF, tooltip = "Number of bars each newly established trend is tracked forward to measure whether it held and followed through.")
float proofFollowAtr = input.float(1.50, "Proof Follow-Through ATR", minval = 0.30, maxval = 8.0, step = 0.05, group = G_PROOF, tooltip = "Favorable distance, in ATR from the trend-establishment close, that counts as a follow-through (Follow).")
int reactBars = input.int(4, "Reaction Window Bars", minval = 1, maxval = 40, group = G_PROOF, tooltip = "Number of bars after a trend is established used to detect an immediate favorable reaction.")
float reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = G_PROOF, tooltip = "Minimum favorable progress toward the follow-through distance, within the reaction window, required to count as an early React.")

bool alertStageTransition = input.bool(true, "Alert: Maturity Transition", group = G_ALERTS, tooltip = "Enables alerts when the active trend stage changes.")
bool alertHealthyPullback = input.bool(true, "Alert: Healthy Pullback", group = G_ALERTS, tooltip = "Enables alerts when price pulls back into the healthy trend shelf without invalidating the ladder.")
bool alertExhaustionRisk = input.bool(true, "Alert: Exhaustion Risk", group = G_ALERTS, tooltip = "Enables alerts when maturity, extension, and momentum conditions align as exhaustion risk.")
bool alertInvalidation = input.bool(true, "Alert: Invalidation Pressure", group = G_ALERTS, tooltip = "Enables alerts when price closes through the trend invalidation shelf.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_pct(float v) =>
    str.tostring(int(math.round(v))) + "%"

f_rate_color(float v) =>
    v >= 55 ? bullColor : v >= 40 ? neutralColor : bearColor

f_flip_color(float v) =>
    v <= 30 ? bullColor : v <= 55 ? neutralColor : bearColor

f_panel_pos(string posText) =>
    switch posText
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_panel_bg(string theme) =>
    theme == "Clean Light" ? color.rgb(248, 250, 252) : panelBg

f_panel_border(string theme) =>
    theme == "Clean Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string theme, int row) =>
    bool evenRow = row % 2 == 0
    if theme == "Clean Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(248, 250, 252)
    else
        evenRow ? color.rgb(20, 31, 52) : panelBg

f_score_text(float value) =>
    na(value) ? "-" : str.tostring(math.round(value))

f_badge_text_color(int stageValue, bool neutralBadge) =>
    stageValue == 3 or stageValue == 4 or neutralBadge ? darkText : headerText

f_keep_label(array<label> labels, label newLabel, int limit) =>
    array.push(labels, newLabel)
    while array.size(labels) > limit
        label oldLabel = array.shift(labels)
        label.delete(oldLabel)

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string sizeText) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_size(sizeText), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_size(sizeText), text_halign = text.align_right)

f_delete_label(label id) =>
    if not na(id)
        label.delete(id)

// -------------------------------------------------
// Trend Maturity Engine
// -------------------------------------------------
labelSize = f_size(labelSizeInput)
panelSize = f_size(panelFontSizeInput)

fast = ta.ema(close, fastLen)
slow = ta.ema(close, slowLen)
anchor = ta.ema(close, anchorLen)
atrRaw = ta.atr(atrLen)
atr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
rsi = nz(ta.rsi(close, rsiLen), 50.0)
[plusDi, minusDi, adxRaw] = ta.dmi(adxLen, adxSmooth)
adx = nz(adxRaw, 0.0)

engineWarmup = math.max(anchorLen, math.max(slowLen, math.max(fastLen, math.max(atrLen, math.max(rsiLen, adxLen + adxSmooth))))) + slopeLen + 5
engineReady = bar_index > engineWarmup

effectiveEarlyAgeBars = math.max(1, math.min(earlyAgeBars, matureAgeBars - 1))
effectiveMatureAgeBars = math.max(matureAgeBars, effectiveEarlyAgeBars + 1)
effectiveReactBars = math.min(reactBars, math.max(proofHorizonBars - 1, 1))

bullAligned = fast > slow and slow > anchor
bearAligned = fast < slow and slow < anchor
rawTrendDir = bullAligned ? 1 : bearAligned ? -1 : 0
trendDir = engineReady ? rawTrendDir : 0

previousTrendDir = bar_index == 0 ? 0 : nz(trendDir[1], 0)
transition = barstate.isconfirmed and trendDir != 0 and trendDir != previousTrendDir
trendAge = trendDir == 0 ? 0 : nz(ta.barssince(transition), 0)

slopeRaw = (slow - nz(slow[slopeLen], slow)) / atr
slopeScore = trendDir == 1 ? f_clamp(slopeRaw * 55.0, 0.0, 100.0) : trendDir == -1 ? f_clamp(-slopeRaw * 55.0, 0.0, 100.0) : 0.0
adxScore = f_clamp((adx - 12.0) / 25.0 * 100.0, 0.0, 100.0)
alignmentScore = trendDir == 0 ? 0.0 : f_clamp((math.abs(fast - slow) + math.abs(slow - anchor)) / atr * 28.0, 0.0, 100.0)
trendQuality = f_clamp(slopeScore * 0.36 + adxScore * 0.34 + alignmentScore * 0.30, 0.0, 100.0)

distanceAtr = trendDir == 1 ? (close - slow) / atr : trendDir == -1 ? (slow - close) / atr : 0.0
extensionScore = f_clamp(distanceAtr / math.max(stretchedAtr, 0.01) * 100.0, 0.0, 100.0)
ageScore = f_clamp(trendAge / math.max(effectiveMatureAgeBars, 1) * 100.0, 0.0, 100.0)
maturityScore = trendDir == 0 ? 0.0 : f_clamp(ageScore * 0.34 + extensionScore * 0.34 + trendQuality * 0.20 + adxScore * 0.12, 0.0, 100.0)

healthyPullback = trendDir == 1 ? low <= fast + atr * pullbackAtr and close >= slow - atr * 0.20 and close > slow : trendDir == -1 ? high >= fast - atr * pullbackAtr and close <= slow + atr * 0.20 and close < slow : false
pullbackDepth = trendDir == 1 ? f_clamp((fast - low) / atr * 45.0, 0.0, 100.0) : trendDir == -1 ? f_clamp((high - fast) / atr * 45.0, 0.0, 100.0) : 0.0
pullbackHealth = healthyPullback ? f_clamp(trendQuality * 0.55 + (100.0 - math.abs(pullbackDepth - 45.0)) * 0.45, 0.0, 100.0) : f_clamp(100.0 - math.abs(distanceAtr) * 20.0, 0.0, 100.0)

exhaustionRisk = trendDir == 1 ? maturityScore >= 72 and extensionScore >= 70 and rsi >= exhaustionRsi : trendDir == -1 ? maturityScore >= 72 and extensionScore >= 70 and rsi <= 100 - exhaustionRsi : false
invalidated = trendDir == 1 ? close < slow - atr * invalidationAtr : trendDir == -1 ? close > slow + atr * invalidationAtr : false

stage = trendDir == 0 ? 0 : invalidated ? 6 : exhaustionRisk ? 5 : trendAge <= effectiveEarlyAgeBars and trendQuality >= 35 ? 1 : maturityScore >= 78 ? 4 : maturityScore >= 55 ? 3 : 2
stageText = stage == 0 ? "No Clear Trend" : stage == 1 ? "Early Trend" : stage == 2 ? "Active Trend" : stage == 3 ? "Mature Trend" : stage == 4 ? "Stretched Trend" : stage == 5 ? "Exhaustion Watch" : "Invalidation Pressure"
stageShort = stage == 0 ? "No Trend" : stage == 1 ? "Early" : stage == 2 ? "Active" : stage == 3 ? "Mature" : stage == 4 ? "Stretch" : stage == 5 ? "Exh" : "Invalid"
stageColor = stage == 0 ? panelLabelCol : stage == 1 ? accentColor : stage == 2 ? (trendDir == 1 ? bullColor : bearColor) : stage == 3 ? neutralColor : stage == 4 ? neutralColor : stage == 5 ? bearColor : bearColor
directionText = trendDir == 1 ? "Bull Trend" : trendDir == -1 ? "Bear Trend" : "Mixed"
pullbackText = healthyPullback ? "Healthy Shelf" : invalidated ? "Broken Shelf" : trendDir == 0 ? "No Shelf" : "Outside Shelf"
pullbackPanelText = trendDir == 0 ? "-" : pullbackText + " / " + f_score_text(pullbackHealth)
invalidationText = trendDir == 0 ? "-" : invalidated ? "Pressure Active" : str.tostring(invalidationAtr, "#.##") + " ATR Shelf"
extensionText = trendDir == 0 ? "-" : str.tostring(distanceAtr, "#.##") + " ATR | " + f_score_text(extensionScore)
reviewScoreText = trendDir == 0 ? "-" : f_score_text(maturityScore) + " / 100"
workflowText = invalidated ? "Rebuild Map" : exhaustionRisk ? "Review Extension" : healthyPullback ? "Review Pullback" : stage == 1 ? "Let Mature" : stage == 2 ? "Track Pullbacks" : stage == 3 ? "Manage Maturity" : stage == 4 ? "Check Extension" : "Wait Alignment"
reviewText = invalidated ? "Rebuild Context" : exhaustionRisk ? "Late-Trend Review" : healthyPullback ? "Shelf Review" : stage == 1 ? "Early Trend" : stage == 2 ? "Trend Active" : stage == 3 ? "Maturity Review" : stage == 4 ? "Extension Review" : "Wait Trend"

// -------------------------------------------------
// Confirmation-anchored proof (trend follow-through)
// -------------------------------------------------
var int proofTotal = 0
var int proofFollow = 0
var int proofHold = 0
var int proofReact = 0
var int proofFlip = 0
var int proofAmbiguous = 0
var bool evalActive = false
var int evalDir = 0
var int evalStartBar = na
var float evalEntry = na
var float evalStop = na
var float evalTarget = na
var bool evalReacted = false
var bool evalFollowed = false

if barstate.isconfirmed and engineReady
    if evalActive
        int heldBars = bar_index - evalStartBar
        float followDist = math.max(math.abs(evalTarget - evalEntry), syminfo.mintick)
        float favorableExcursion = evalDir == 1 ? high - evalEntry : evalEntry - low
        bool targetTouched = heldBars >= 1 and favorableExcursion >= followDist
        bool stopTouched = evalDir == 1 ? low <= evalStop : high >= evalStop
        bool directionLost = trendDir != evalDir
        bool ambiguousNow = targetTouched and (stopTouched or directionLost)

        if heldBars >= 1 and heldBars <= effectiveReactBars and favorableExcursion >= followDist * reactProgressPct / 100.0
            evalReacted := true
        if targetTouched and not stopTouched and not directionLost
            evalFollowed := true

        bool horizonDone = heldBars >= proofHorizonBars
        bool resolveNow = ambiguousNow or targetTouched or stopTouched or directionLost or horizonDone

        if resolveNow
            if ambiguousNow
                proofAmbiguous := proofAmbiguous + 1
            else
                proofTotal := proofTotal + 1
                if evalFollowed
                    proofFollow := proofFollow + 1
                if not stopTouched and not directionLost
                    proofHold := proofHold + 1
                if evalReacted
                    proofReact := proofReact + 1
                if stopTouched or directionLost
                    proofFlip := proofFlip + 1
            evalActive := false

    // Each confirmed trend establishment opens one Proof evaluation.
    if transition and trendDir != 0 and not evalActive
        evalActive := true
        evalDir := trendDir
        evalEntry := close
        evalStop := trendDir == 1 ? slow - atr * invalidationAtr : slow + atr * invalidationAtr
        evalTarget := close + trendDir * atr * proofFollowAtr
        evalStartBar := bar_index
        evalReacted := false
        evalFollowed := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

// -------------------------------------------------
// Visual Structure
// -------------------------------------------------
var box ladderBox = na
var box pullbackBox = na
var box invalidationBox = na
var line fastRail = na
var line slowRail = na
var line anchorRail = na
var label ladderLabel = na
var label pullbackLabel = na
var label invalidationLabel = na
var label stageTag = na
var label maturityTag = na
var label invalidationTag = na
var array<label> eventLabels = array.new<label>()

adaptiveProjectionBars = adaptiveProjection ? timeframe.ismonthly ? math.min(projectionBars, 8) : timeframe.isweekly ? math.min(projectionBars, 22) : timeframe.isdaily ? math.min(projectionBars, 45) : projectionBars : projectionBars
visualLeft = math.max(bar_index - math.min(adaptiveProjectionBars, 120), 0)
visualRight = bar_index + adaptiveProjectionBars
centerX = int(math.round((visualLeft + visualRight) * 0.5))
leftBadgeX = visualLeft + int(math.round((visualRight - visualLeft) * 0.24))
rightBadgeX = visualLeft + int(math.round((visualRight - visualLeft) * 0.76))

ladderTop = trendDir == 1 ? slow + atr * stretchedAtr : trendDir == -1 ? slow + atr * invalidationAtr : slow + atr
ladderBottom = trendDir == 1 ? slow - atr * invalidationAtr : trendDir == -1 ? slow - atr * stretchedAtr : slow - atr
pullTop = trendDir == 1 ? fast + atr * pullbackAtr : trendDir == -1 ? slow + atr * pullbackAtr : fast + atr * 0.35
pullBottom = trendDir == 1 ? slow - atr * pullbackAtr : trendDir == -1 ? fast - atr * pullbackAtr : slow - atr * 0.35
invalidTop = trendDir == 1 ? slow - atr * invalidationAtr * 0.35 : trendDir == -1 ? slow + atr * invalidationAtr : slow + atr * 0.70
invalidBottom = trendDir == 1 ? slow - atr * invalidationAtr : trendDir == -1 ? slow + atr * invalidationAtr * 0.35 : slow - atr * 0.70
ladderCol = trendDir == 1 ? bullColor : trendDir == -1 ? bearColor : accentColor
zoneText = "Maturity\n" + f_score_text(maturityScore)

if barstate.islast and showLadder and trendDir != 0
    if na(ladderBox)
        ladderBox := box.new(visualLeft, ladderTop, visualRight, ladderBottom, xloc = xloc.bar_index, bgcolor = color.new(ladderCol, 93), border_color = color.new(ladderCol, 38))
    else
        box.set_lefttop(ladderBox, visualLeft, ladderTop)
        box.set_rightbottom(ladderBox, visualRight, ladderBottom)
        box.set_bgcolor(ladderBox, color.new(ladderCol, 93))
        box.set_border_color(ladderBox, color.new(ladderCol, 38))
    if na(ladderLabel)
        ladderLabel := label.new(centerX, (ladderTop + ladderBottom) * 0.5, zoneText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = f_badge_text_color(stage, false), color = color.new(stageColor, 0), size = labelSize, textalign = text.align_center)
    else
        label.set_x(ladderLabel, centerX)
        label.set_y(ladderLabel, (ladderTop + ladderBottom) * 0.5)
        label.set_text(ladderLabel, zoneText)
        label.set_color(ladderLabel, color.new(stageColor, 0))
        label.set_textcolor(ladderLabel, f_badge_text_color(stage, false))
        label.set_size(ladderLabel, labelSize)
        label.set_textalign(ladderLabel, text.align_center)
else if barstate.islast
    if not na(ladderBox)
        box.delete(ladderBox)
        ladderBox := na
    f_delete_label(ladderLabel)
    ladderLabel := na

if barstate.islast and showPullbackShelf and trendDir != 0
    pullText = "Pullback\n" + f_score_text(pullbackHealth)
    if na(pullbackBox)
        pullbackBox := box.new(visualLeft, pullTop, visualRight, pullBottom, xloc = xloc.bar_index, bgcolor = color.new(neutralColor, 89), border_color = color.new(neutralColor, 34))
    else
        box.set_lefttop(pullbackBox, visualLeft, pullTop)
        box.set_rightbottom(pullbackBox, visualRight, pullBottom)
        box.set_bgcolor(pullbackBox, color.new(neutralColor, 89))
        box.set_border_color(pullbackBox, color.new(neutralColor, 34))
    if na(pullbackLabel)
        pullbackLabel := label.new(leftBadgeX, (pullTop + pullBottom) * 0.5, pullText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = darkText, color = color.new(neutralColor, 0), size = labelSize, textalign = text.align_center)
    else
        label.set_x(pullbackLabel, leftBadgeX)
        label.set_y(pullbackLabel, (pullTop + pullBottom) * 0.5)
        label.set_text(pullbackLabel, pullText)
        label.set_color(pullbackLabel, color.new(neutralColor, 0))
        label.set_textcolor(pullbackLabel, darkText)
        label.set_size(pullbackLabel, labelSize)
        label.set_textalign(pullbackLabel, text.align_center)
else if barstate.islast
    if not na(pullbackBox)
        box.delete(pullbackBox)
        pullbackBox := na
    f_delete_label(pullbackLabel)
    pullbackLabel := na

if barstate.islast and showInvalidationShelf and trendDir != 0
    invalidText = "Risk"
    if na(invalidationBox)
        invalidationBox := box.new(visualLeft, invalidTop, visualRight, invalidBottom, xloc = xloc.bar_index, bgcolor = color.new(bearColor, 91), border_color = color.new(bearColor, 36))
    else
        box.set_lefttop(invalidationBox, visualLeft, invalidTop)
        box.set_rightbottom(invalidationBox, visualRight, invalidBottom)
        box.set_bgcolor(invalidationBox, color.new(bearColor, 91))
        box.set_border_color(invalidationBox, color.new(bearColor, 36))
    if na(invalidationLabel)
        invalidationLabel := label.new(rightBadgeX, (invalidTop + invalidBottom) * 0.5, invalidText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = headerText, color = color.new(bearColor, 0), size = labelSize, textalign = text.align_center)
    else
        label.set_x(invalidationLabel, rightBadgeX)
        label.set_y(invalidationLabel, (invalidTop + invalidBottom) * 0.5)
        label.set_text(invalidationLabel, invalidText)
        label.set_color(invalidationLabel, color.new(bearColor, 0))
        label.set_textcolor(invalidationLabel, headerText)
        label.set_size(invalidationLabel, labelSize)
        label.set_textalign(invalidationLabel, text.align_center)
else if barstate.islast
    if not na(invalidationBox)
        box.delete(invalidationBox)
        invalidationBox := na
    f_delete_label(invalidationLabel)
    invalidationLabel := na

if barstate.islast and showTrendRails
    if na(fastRail)
        fastRail := line.new(visualLeft, fast, visualRight, fast, xloc = xloc.bar_index, color = color.new(accentColor, 0), width = 1)
        slowRail := line.new(visualLeft, slow, visualRight, slow, xloc = xloc.bar_index, color = color.new(ladderCol, 0), width = 2)
        anchorRail := line.new(visualLeft, anchor, visualRight, anchor, xloc = xloc.bar_index, color = color.new(panelLabelCol, 15), width = 1, style = line.style_dotted)
    else
        line.set_xy1(fastRail, visualLeft, fast)
        line.set_xy2(fastRail, visualRight, fast)
        line.set_xy1(slowRail, visualLeft, slow)
        line.set_xy2(slowRail, visualRight, slow)
        line.set_color(slowRail, color.new(ladderCol, 0))
        line.set_xy1(anchorRail, visualLeft, anchor)
        line.set_xy2(anchorRail, visualRight, anchor)
else if barstate.islast
    if not na(fastRail)
        line.delete(fastRail)
        line.delete(slowRail)
        line.delete(anchorRail)
        fastRail := na
        slowRail := na
        anchorRail := na

// -------------------------------------------------
// Labels and Right Tags
// -------------------------------------------------
stageTransition = barstate.isconfirmed and stage != nz(stage[1], stage) and stage != 0
healthyPullbackEvent = barstate.isconfirmed and healthyPullback and not healthyPullback[1]
exhaustionEvent = barstate.isconfirmed and exhaustionRisk and not exhaustionRisk[1]
invalidationEvent = barstate.isconfirmed and invalidated and not invalidated[1]
eventCandidate = stageTransition or healthyPullbackEvent or exhaustionEvent or invalidationEvent
criticalEvent = stageTransition or exhaustionEvent or invalidationEvent
var int lastEventBar = na
canPrintEvent = criticalEvent or na(lastEventBar) or bar_index - lastEventBar >= labelCooldownBars
eventAbove = exhaustionEvent ? trendDir == 1 : trendDir == -1
eventY = eventAbove ? high + atr * eventLabelOffsetAtr : low - atr * eventLabelOffsetAtr
eventStyle = eventAbove ? label.style_label_down : label.style_label_up
eventText = exhaustionEvent ? "Exh " + f_score_text(maturityScore) : invalidationEvent ? "Risk " + f_score_text(maturityScore) : healthyPullbackEvent ? "PB " + f_score_text(pullbackHealth) : stageShort + " " + f_score_text(maturityScore)
eventCol = exhaustionEvent or invalidationEvent ? bearColor : healthyPullbackEvent ? neutralColor : stageColor
eventTextCol = healthyPullbackEvent or stage == 3 or stage == 4 ? darkText : headerText
eventQuality = healthyPullbackEvent ? pullbackHealth : maturityScore
allowEvent = criticalEvent or (eventLabelMode == "Detailed" ? eventQuality >= math.max(20, minEventQuality - 20) : eventQuality >= minEventQuality)

if showEventLabels and eventCandidate and allowEvent and canPrintEvent
    label newEventLabel = label.new(bar_index, eventY, eventText, xloc = xloc.bar_index, yloc = yloc.price, style = eventStyle, textcolor = eventTextCol, color = color.new(eventCol, 4), size = labelSize)
    f_keep_label(eventLabels, newEventLabel, maxVisibleLabels)
    lastEventBar := bar_index

if barstate.islast and showRightTags and trendDir != 0
    stageTagX = visualRight
    maturityTagX = visualRight + 2
    invalidationTagX = visualRight + 4
    compact = math.abs(ladderTop - ladderBottom) <= atr * 2.0
    tagGap = math.max(syminfo.mintick * 20.0, atr * 0.28)
    stageTagY = compact ? ladderTop + tagGap : ladderTop
    maturityTagY = (ladderTop + ladderBottom) * 0.5
    invalidTagY = compact ? ladderBottom - tagGap : ladderBottom

    if na(stageTag)
        stageTag := label.new(stageTagX, stageTagY, stageShort, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = f_badge_text_color(stage, false), color = color.new(stageColor, 0), size = labelSize)
    else
        label.set_xy(stageTag, stageTagX, stageTagY)
        label.set_text(stageTag, stageShort)
        label.set_textcolor(stageTag, f_badge_text_color(stage, false))
        label.set_color(stageTag, color.new(stageColor, 0))
        label.set_size(stageTag, labelSize)

    if na(maturityTag)
        maturityTag := label.new(maturityTagX, maturityTagY, "Mat " + f_score_text(maturityScore), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = headerText, color = color.new(ladderCol, 0), size = labelSize)
    else
        label.set_xy(maturityTag, maturityTagX, maturityTagY)
        label.set_text(maturityTag, "Mat " + f_score_text(maturityScore))
        label.set_textcolor(maturityTag, headerText)
        label.set_color(maturityTag, color.new(ladderCol, 0))
        label.set_size(maturityTag, labelSize)

    if na(invalidationTag)
        invalidationTag := label.new(invalidationTagX, invalidTagY, "Risk", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = headerText, color = color.new(bearColor, 0), size = labelSize)
    else
        label.set_xy(invalidationTag, invalidationTagX, invalidTagY)
        label.set_text(invalidationTag, "Risk")
        label.set_textcolor(invalidationTag, headerText)
        label.set_color(invalidationTag, color.new(bearColor, 0))
        label.set_size(invalidationTag, labelSize)
else if barstate.islast
    f_delete_label(stageTag)
    f_delete_label(maturityTag)
    f_delete_label(invalidationTag)
    stageTag := na
    maturityTag := na
    invalidationTag := na

// -------------------------------------------------
// Panel
// -------------------------------------------------
int panelRowCount = showProof ? 13 : 8
string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) + (proofAmbiguous > 0 ? " | x = " + str.tostring(proofAmbiguous) : "") : proofAmbiguous > 0 ? "x = " + str.tostring(proofAmbiguous) : "building"
string followText = proofTotal > 0 ? f_pct(followRate) : "-"
string holdText = proofTotal > 0 ? f_pct(holdRate) : "-"
string reactText = proofTotal > 0 ? f_pct(reactRate) : "-"
string flipText = proofTotal > 0 ? f_pct(flipRate) : "-"
color followCol = proofTotal > 0 ? f_rate_color(followRate) : f_panel_value(panelTheme)
color holdCol = proofTotal > 0 ? f_rate_color(holdRate) : f_panel_value(panelTheme)
color reactCol = proofTotal > 0 ? f_rate_color(reactRate) : f_panel_value(panelTheme)
color flipCol = proofTotal > 0 ? f_flip_color(flipRate) : f_panel_value(panelTheme)

var table panel = na
var string panelPosMemory = ""
var string panelThemeMemory = ""

if barstate.islast
    if showPanel
        if na(panel) or panelPosMemory != panelPositionInput or panelThemeMemory != panelTheme
            if not na(panel)
                table.delete(panel)
            panel := table.new(f_panel_pos(panelPositionInput), 2, panelRowCount, bgcolor = f_panel_bg(panelTheme), border_width = 1, border_color = f_panel_border(panelTheme), frame_color = f_panel_border(panelTheme), frame_width = 1)
            panelPosMemory := panelPositionInput
            panelThemeMemory := panelTheme
        table.clear(panel, 0, 0, 1, panelRowCount - 1)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Trend Maturity Ladder", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
        f_panel_row(panel, 1, "Workflow", workflowText, stageColor, panelTheme, panelFontSizeInput)
        f_panel_row(panel, 2, "Trend Context", directionText, trendDir == 1 ? bullColor : trendDir == -1 ? bearColor : neutralColor, panelTheme, panelFontSizeInput)
        f_panel_row(panel, 3, "Maturity", reviewScoreText + " | " + stageShort, stageColor, panelTheme, panelFontSizeInput)
        f_panel_row(panel, 4, "Pullback Shelf", pullbackPanelText, healthyPullback ? neutralColor : f_panel_value(panelTheme), panelTheme, panelFontSizeInput)
        f_panel_row(panel, 5, "Invalidation", invalidationText, invalidated ? bearColor : f_panel_value(panelTheme), panelTheme, panelFontSizeInput)
        f_panel_row(panel, 6, "Extension", extensionText, exhaustionRisk ? bearColor : neutralColor, panelTheme, panelFontSizeInput)
        f_panel_row(panel, 7, "Review", reviewText, stageColor, panelTheme, panelFontSizeInput)
        if showProof
            color subBg = f_row_bg(panelTheme, 8)
            table.cell(panel, 0, 8, "Proof @ Confirm", text_color = accentColor, bgcolor = subBg, text_size = panelSize, text_halign = text.align_left)
            table.cell(panel, 1, 8, proofSampleText, text_color = f_panel_label(panelTheme), bgcolor = subBg, text_size = panelSize, text_halign = text.align_right)
            f_panel_row(panel, 9, "Follow Rate", followText, followCol, panelTheme, panelFontSizeInput)
            f_panel_row(panel, 10, "Hold Rate", holdText, holdCol, panelTheme, panelFontSizeInput)
            f_panel_row(panel, 11, "React Rate", reactText, reactCol, panelTheme, panelFontSizeInput)
            f_panel_row(panel, 12, "Flip Rate", flipText, flipCol, panelTheme, panelFontSizeInput)
    else if not na(panel)
        table.delete(panel)
        panel := na
        panelPosMemory := ""
        panelThemeMemory := ""

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertStageTransition and stageTransition, "Trend Maturity Transition", "Trend Maturity Ladder: the active trend stage changed. This is an analytical attention marker, not a trade instruction.")
alertcondition(alertHealthyPullback and healthyPullbackEvent, "Healthy Trend Pullback", "Trend Maturity Ladder: price pulled into the healthy trend shelf without invalidating the ladder. This is context for review only.")
alertcondition(alertExhaustionRisk and exhaustionEvent, "Trend Exhaustion Risk", "Trend Maturity Ladder: maturity, extension, and momentum conditions aligned as exhaustion-risk context. This does not predict a reversal.")
alertcondition(alertInvalidation and invalidationEvent, "Trend Invalidation Pressure", "Trend Maturity Ladder: price closed through the trend invalidation shelf. Rebuild broader context before interpretation.")

// -------------------------------------------------
// Hidden Exports
// -------------------------------------------------
plot(maturityScore, "TML Maturity Score", display = display.none)
plot(trendQuality, "TML Trend Quality", display = display.none)
plot(followRate, "TML Follow Rate", display = display.none)
plot(holdRate, "TML Hold Rate", display = display.none)
plot(reactRate, "TML React Rate", display = display.none)
plot(flipRate, "TML Flip Rate", display = display.none)
plot(proofAmbiguous, "TML Ambiguous Proof Count", display = display.none)
plot(stage, "TML Stage ID", display = display.none)
plot(trendDir, "TML Trend Direction", display = display.none)
plot(trendAge, "TML Trend Age", display = display.none)
plot(extensionScore, "TML Extension Score", display = display.none)
plot(pullbackHealth, "TML Pullback Health", display = display.none)
````
