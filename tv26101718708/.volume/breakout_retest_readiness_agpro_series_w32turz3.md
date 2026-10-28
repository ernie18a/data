# Breakout Retest Readiness [AGPro Series]

- url: https://www.tradingview.com/script/W32TURZ3-Breakout-Retest-Readiness-AGPro-Series/
- type: indicator
- pine_id: PUB;966218bfc712402e896b4b58bb82772f
- version: 4.0

## Description

Breakout Retest Readiness [AGPro Series]


🧠 Core Idea

Is the post-breakout retest being accepted with structure, or is the breakout losing quality at the risk edge?


📌 Overview / What it does

Breakout Retest Readiness is a chart-first planning tool built to evaluate what happens after a confirmed breakout and after price starts interacting with the retest pocket.

The script maps the broken structure level, builds a retest pocket around it, places a risk-edge shelf beyond the pocket, and projects a target-room guide for context. It then scores the active retest environment with a 0-100 Acceptance Score and displays a clear next-action state in the AG Pro panel.

This script does not predict continuation. It does not automate entries. It is designed to organize post-breakout retest context so traders can review acceptance, rejection, risk edge, and plan quality in a cleaner way.


🎯 Purpose & Design Philosophy

Most breakout tools focus on the moment price crosses a level. In practice, many useful decisions happen after the break, when price returns toward the broken level and either accepts it or fails around it.

This script was built for traders who want a structured retest planning layer rather than another basic breakout marker. It supports a patient workflow: wait for structure, observe the pocket, evaluate acceptance, and review risk before reacting.

The design philosophy is simple: the chart should answer what state the retest is in, how strong the acceptance context is, where risk is being tested, and what the next review step should be.


⚡ Why This Script Is Different

Most tools focus on detecting a breakout or grading the first retest as a standalone signal.

This script does NOT try to clone a classic break-retest quality grader, and it does not print simple buy or sell commands.

Instead, it works as a post-breakout readiness planner. It arms a retest pocket after a confirmed breakout, waits for price to interact with that pocket, evaluates acceptance versus rejection, tracks the risk edge, and keeps the next-action state visible in the panel.

The difference is the decision layer. The script is less about saying "a retest happened" and more about answering whether the active retest environment is constructive enough to keep reviewing.


⚙️ Methodology

1. Context Detection

The script identifies a confirmed break beyond recent structure using a prior high or prior low reference. The breakout must clear the structure by an ATR-normalized buffer so minor pokes are filtered.

2. Reference Mapping

After a valid break, the script stores the breakout line, builds a retest pocket around it, places an invalidation shelf beyond the broken level, and projects a target-room guide from the prior structure range.

3. Reaction Evaluation

When price interacts with the retest pocket, the script evaluates breakout quality, retest depth, wick rejection, volume change, and trend agreement. These components combine into a 0-100 Acceptance Score.

4. Visual Output

The chart shows the active retest pocket, breakout line, risk edge, target guide, compact event labels, and the AG Pro panel. The panel summarizes retest state, acceptance score, breakout quality, risk edge, and action.


🗺️ How to Read the Chart

Retest Pocket = the zone around the broken structure level where price is being evaluated after the breakout.

Breakout Line = the structure level that was crossed and now anchors the retest plan.

Risk Edge = the invalidation shelf beyond the retest pocket. It is a planning reference, not a stop recommendation.

Target Guide = a target-room marker projected from the prior range. It is context only, not a forecast.

Labels = compact state markers such as ARMED, TEST, ACCEPT, REJECT, RISK EDGE, or EXPIRE.

Colors = bullish retest plans use the AGPro teal tone, bearish plans use the AGPro pink tone, watch states use indigo or amber, and risk conditions use red.

Panel = the main decision interface showing retest state, acceptance score, breakout quality, risk edge, and next action.


🚦 Signals & States

• Breakout Armed → a breakout retest plan has been created after price cleared structure.

• Testing Pocket → price is interacting with the active retest pocket and acceptance is being evaluated.

• Accepted Retest → the retest has held the pocket with enough acceptance quality to deserve review.

• Rejected Retest → the retest has failed around the pocket and quality has weakened.

• Risk Edge Hit → price has moved beyond the mapped risk shelf.

• Expired → the retest window aged out before a constructive interaction.


🔔 Alerts Logic

Alerts are available for breakout plan arming, retest pocket interaction, accepted retest readiness, rejected retest or risk-edge pressure, and expired retest plans.

Each alert is an attention marker. Alerts do not represent trade instructions, guaranteed outcomes, or automated strategy decisions.


🧩 Confluence Logic

The strongest acceptance context appears when the breakout quality, retest depth, wick rejection, volume behavior, and trend agreement support the same side.

When these components align, the retest score improves. When the pocket is too deep, volume behavior is poor, trend context disagrees, or the risk edge is pressured, the readiness state weakens.


📊 When to Use

• After clean breakouts from recent structure

• During trend continuation review

• When price returns toward a broken level

• When the trader wants to separate constructive retests from weak post-break reactions

• On liquid symbols where structure, volume, and candle behavior are readable


⚠️ When NOT to Use

• Extremely low-liquidity instruments

• Highly noisy lower timeframes

• News-driven volatility spikes

• Markets with no clear structure reference

• Situations where the breakout level is too close to major external obstruction


🎛️ Key Inputs

• Breakout Structure Lookback → controls the prior structure reference used for breakout detection.

• Maximum Bars To Retest → controls how long the script waits for the retest pocket to matter.

• Sensitivity → adjusts how strict the breakout and acceptance model should be.

• Minimum Acceptance Score → defines the score needed before accepted readiness can appear.

• Retest Pocket Width ATR → controls the width of the post-breakout pocket.

• Invalidation Shelf ATR → controls the mapped risk-edge distance beyond the broken level.

• Target Guide Range Multiple → controls the forward target-room guide.

• Visual Settings → control pockets, lines, labels, label density, label size, and forward rendering.

• Panel Settings → control panel visibility, location, theme, and font size.


🖥️ Interface & Visual Design

The interface is built around a clean AG Pro panel and one main chart object family: the retest pocket.

The pocket label is centered inside the zone so the active state is visible without needing extra clutter. The breakout line, invalidation shelf, and target guide create a simple visual hierarchy: level, risk, and room.

Labels are intentionally compact and controlled by cooldown and maximum-visible settings so the chart remains active without becoming crowded.


🧪 Practical Usage Workflow

1. Read the panel state.

2. Locate the active retest pocket.

3. Check whether price is testing, accepting, rejecting, or pressing the risk edge.

4. Compare the Acceptance Score with the breakout quality.

5. Use the action row as a review prompt, not as an instruction.


🔍 Interpretation Guidelines

The Acceptance Score should be read as context quality, not certainty.

A higher score means the current retest has cleaner structural behavior under the script's rules. A lower score means the retest is less constructive, too deep, poorly supported, or not aligned with trend context.

The Risk Edge matters because a retest can look acceptable for a few bars and still lose structure if price pushes beyond the invalidation shelf. The panel keeps that condition visible.


🚫 What This Script Is NOT

This script is not a prediction engine.

This script is not financial advice.

This script is not an auto-trading system.

This script does not provide guaranteed signals.

This script is not a generic support and resistance map.

This script is not a clone of a first-retest grading tool.


⚠️ Limitations & Transparency

The script is rule-based and depends on the selected lookback, timeframe, and market structure.

Different symbols can produce different retest behavior. Lower timeframes may show more noise. Higher timeframes may produce fewer but stronger events.

Volatility changes can affect pocket size, risk-edge distance, and event frequency. Users should interpret every output within broader market context.


🧠 Market Context Notes

Breakout retests are most useful when structure is clear, liquidity is sufficient, and price has enough room to continue without immediate obstruction.

Volume behavior can add context, but volume data quality varies across markets. When volume is unreliable, the script treats that component more neutrally.

The retest pocket is not a guaranteed support or resistance zone. It is a structured review area around the broken level.


🧾 Use Case Examples

When price breaks above recent structure and later returns to the pocket with a controlled pullback, the script can mark the retest as Testing Pocket or Accepted Retest depending on score quality.

When price breaks below structure but quickly pushes back above the pocket and pressures the mapped risk edge, the script can mark rejection or risk-edge pressure.

When a breakout never returns to the pocket within the selected time window, the script can expire the plan instead of keeping old context alive.


🧱 System Philosophy

AGPro tools are designed to support structured chart reading. The goal is not to add more random signals, but to turn market behavior into clearer states, cleaner context, and better review discipline.

Breakout Retest Readiness follows that philosophy by turning a common post-breakout question into a visible planning workflow.


🔐 Non-Promise Statement

No script can confirm future price direction with certainty.

This tool organizes retest context. It does not promise continuation, reversal, profit, or accuracy.


📉 Risk Disclosure

Trading involves risk.

All outputs from this script are educational and analytical in nature.

Users are responsible for their own decisions, risk management, position sizing, and market interpretation.

This script does not provide financial advice.


📚 Educational Note

Use the script to study how breakouts behave after price returns to the broken level. The most useful insight is often not the breakout itself, but how the market reacts when the level is tested again.

## Source Code

````pine
// -------------------------------------------------
// Breakout Retest Readiness [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Breakout Retest Readiness is a chart-first retest planning engine that
// evaluates whether price is accepting or rejecting the retest pocket after a
// confirmed breakout. It studies breakout strength, retest depth, wick
// rejection, volume change, trend agreement, breakout separation, remaining
// target room, and risk edge to produce a 0-100 acceptance score and a clear
// next-action state. A live Retest Win Rate logs how often an accepted retest
// reaches a balanced one-risk target before its own invalidation, creating a
// confirmed-bar evidence record for the setup.
// -------------------------------------------------

//@version=6
indicator("Breakout Retest Readiness [AGPro Series]",
     shorttitle = "BRR Plan",
     overlay = true,
     max_boxes_count = 60,
     max_labels_count = 180,
     max_lines_count = 90)

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
color dangerColor   = color.rgb(239, 68, 68)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Retest Engine"
int structureLookback = input.int(36, "Breakout Structure Lookback", minval = 10, maxval = 220, group = groupEngine, tooltip = "Defines the prior high and prior low used as breakout references. The current bar is tested against previous structure so the model avoids hindsight levels.")
int maxRetestBars = input.int(24, "Maximum Bars To Retest", minval = 4, maxval = 120, group = groupEngine, tooltip = "Maximum number of bars allowed after breakout for a constructive retest pocket interaction. Older retests are treated as stale context.")
int atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupEngine, tooltip = "ATR period used to normalize breakout distance, retest pocket width, invalidation shelf, target guide, and label spacing.")
int volumeLength = input.int(34, "Volume Baseline Length", minval = 5, maxval = 200, group = groupEngine, tooltip = "Volume moving average used to compare breakout participation and later retest volume behavior. Symbols without reliable volume receive a neutral component.")
int fastEmaLength = input.int(21, "Fast Context EMA", minval = 1, maxval = 200, group = groupEngine, tooltip = "Fast EMA used for trend agreement. It does not create directional commands.")
int slowEmaLength = input.int(55, "Slow Context EMA", minval = 2, maxval = 300, group = groupEngine, tooltip = "Slow EMA used for trend agreement and broader retest context.")
int trendSlopeBars = input.int(5, "Trend Slope Bars", minval = 1, maxval = 30, group = groupEngine, tooltip = "Number of bars used to evaluate whether the slow EMA slope supports the active breakout side.")
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Aggressive"], group = groupEngine, tooltip = "Controls selectivity. Conservative requires stronger break distance and acceptance, while Aggressive allows earlier readiness states.")
string confirmationMode = input.string("Close Confirmed", "Display Refresh", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = "Close Confirmed is the publication default. Live Updating previews developing scores and panel values during the active bar; durable plan transitions, event labels, proof samples, and alerts still require a confirmed close.")

string groupScoring = "Readiness Model"
int minimumAcceptanceScore = input.int(70, "Minimum Acceptance Score", minval = 40, maxval = 95, group = groupScoring, tooltip = "Minimum 0-100 score required before a retest is marked as accepted readiness context. This is not a trade instruction.")
int watchScore = input.int(54, "Watch Score", minval = 25, maxval = 90, group = groupScoring, tooltip = "Minimum 0-100 score used for developing retest watch states before acceptance is confirmed.")
float breakoutBufferAtr = input.float(0.16, "Breakout Buffer ATR", minval = 0.01, maxval = 1.50, step = 0.01, group = groupScoring, tooltip = "ATR-normalized close beyond structure required to arm a breakout retest plan.")
float pocketWidthAtr = input.float(0.42, "Retest Pocket Width ATR", minval = 0.05, maxval = 2.50, step = 0.01, group = groupScoring, tooltip = "ATR-based width around the broken level used to build the retest pocket.")
float invalidationShelfAtr = input.float(0.74, "Invalidation Shelf ATR", minval = 0.10, maxval = 4.00, step = 0.01, group = groupScoring, tooltip = "ATR distance beyond the broken level used to map the retest risk edge. It is a planning reference, not a stop recommendation.")
float maxRetestDepthAtr = input.float(1.35, "Maximum Clean Retest Depth ATR", minval = 0.20, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = "Retests deeper than this value lose acceptance quality because the broken level is being challenged too aggressively.")
float minimumSeparationAtr = input.float(0.34, "Minimum Breakout Separation ATR", minval = 0.05, maxval = 3.00, step = 0.01, group = groupScoring, tooltip = "Minimum ATR-normalized separation the breakout should create away from the broken level before the retest is treated as constructive.")
float minimumRemainingRoomAtr = input.float(0.80, "Minimum Remaining Target Room ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupScoring, tooltip = "Minimum remaining ATR room toward the target guide required before an accepted retest can stay constructive.")
float targetRangeMultiple = input.float(1.00, "Target Guide Range Multiple", minval = 0.25, maxval = 3.00, step = 0.05, group = groupScoring, tooltip = "Projects a target-room guide from the prior structure range. The projection is a context marker only.")
int proofWindowBars = input.int(30, "Retest Proof Window Bars", minval = 10, maxval = 200, group = groupScoring, tooltip = "Bars allowed for an accepted retest to reach its one-risk target or invalidation before the sample is left unresolved (uncounted) in the Retest Win Rate.")

string groupVisual = "Visual Settings"
bool showRetestPocket = input.bool(true, "Show Retest Pocket", group = groupVisual, tooltip = "Displays the active retest pocket with centered state and score text.")
bool showBreakoutLine = input.bool(true, "Show Breakout Line", group = groupVisual, tooltip = "Displays the broken structure level that anchors the active retest plan.")
bool showRiskTargetGuides = input.bool(true, "Show Risk / Target Guides", group = groupVisual, tooltip = "Displays the invalidation shelf and target-room guide for planning context.")
string guideBadgeDetail = input.string("Essential", "Guide Badge Detail", options = ["Essential", "Detailed"], group = groupVisual, tooltip = "Essential keeps each visible guide owned by a compact price badge. Detailed adds the guide role and target-room context without creating extra chart objects.")
bool showLabels = input.bool(true, "Show Event Labels", group = groupVisual, tooltip = "Displays compact ARMED, TEST, ACCEPT, REJECT, EXPIRE, and RISK labels with controlled spacing.")
bool showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupVisual, tooltip = "Adds sparse context labels during active retest planning so the chart remains informative without becoming crowded. Off by default for a cleaner publication view.")
string labelTextMode = input.string("Compact", "Label Text Mode", options = ["Compact", "Detailed"], group = groupVisual, tooltip = "Compact labels keep the chart premium and clean. Detailed labels add state and score context directly on the chart.")
int labelCooldown = input.int(14, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupVisual, tooltip = "Minimum spacing between event labels. Higher values reduce label density.")
int contextLabelSpacing = input.int(40, "Context Label Spacing", minval = 8, maxval = 240, group = groupVisual, tooltip = "Minimum spacing between sparse context labels while a retest plan is active.")
int maxVisibleLabels = input.int(6, "Max Visible Labels", minval = 4, maxval = 60, group = groupVisual, tooltip = "Maximum number of recent labels retained on the chart. Older labels are removed first for performance.")
int forwardBars = input.int(34, "Forward Render Bars", minval = 8, maxval = 160, group = groupVisual, tooltip = "Controls how far retest pockets and guide lines extend to the right.")
float labelOffsetAtr = input.float(1.05, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupVisual, tooltip = "Offsets labels away from candles with ATR so they remain readable above or below price.")
float labelStackAtr = input.float(0.45, "Label Stack Offset ATR", minval = 0.00, maxval = 2.00, step = 0.05, group = groupVisual, tooltip = "Adds extra vertical spacing when labels appear close together on opposite sides of price.")
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual, tooltip = "Controls all chart label sizes, including centered retest-pocket text. Normal is the publication default.")

string groupPanel = "Panel Settings"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = "Shows or hides the AG Pro readiness panel. The default is visible for public-release readability.")
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = "Moves the AGPro summary panel to the preferred chart location.")
string panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = "Switches the panel between the premium dark AGPro theme and a light chart-friendly theme.")
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = "Controls panel text size. Normal is the default AGPro publication setting.")

string groupAlerts = "Alerts"
int alertScore = input.int(72, "Minimum Alert Score", minval = 40, maxval = 95, group = groupAlerts, tooltip = "Minimum acceptance score required for accepted-retest alerts.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(_value, _min, _max) =>
    math.max(_min, math.min(_max, _value))

f_norm_high(_value, _weak, _strong) =>
    float span = math.max(_strong - _weak, 0.0001)
    f_clamp((_value - _weak) / span * 100.0, 0.0, 100.0)

f_norm_low(_value, _good, _bad) =>
    float span = math.max(_bad - _good, 0.0001)
    f_clamp((_bad - _value) / span * 100.0, 0.0, 100.0)

f_peak_score(_value, _low, _ideal, _high) =>
    float result = 0.0
    if _value <= _ideal
        result := f_norm_high(_value, _low, _ideal)
    else
        result := f_norm_low(_value, _ideal, _high)
    result

f_text_size(_size) =>
    switch _size
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_pos(_pos) =>
    switch _pos
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_fmt_price(_value) =>
    na(_value) ? "-" : str.tostring(_value, format.mintick)

f_fmt_score(_value) =>
    str.tostring(math.round(_value)) + "/100"

f_score_grade(_score) =>
    string result = "D"
    if _score >= 86
        result := "A+"
    else if _score >= 78
        result := "A"
    else if _score >= 68
        result := "B"
    else if _score >= 55
        result := "C"
    result

f_score_color(_score) =>
    color result = bearColor
    if _score >= 78
        result := bullColor
    else if _score >= minimumAcceptanceScore
        result := accentColor
    else if _score >= watchScore
        result := neutralColor
    result

f_panel_row(_panel, _row, _label, _value, _valueColor, _bg, _labelColor, _textSize) =>
    table.cell(_panel, 0, _row, _label, text_color = _labelColor, bgcolor = _bg, text_size = _textSize, text_halign = text.align_left)
    table.cell(_panel, 1, _row, _value, text_color = _valueColor, bgcolor = _bg, text_size = _textSize, text_halign = text.align_right)

f_state_compact(_state, _score) =>
    shortState = "WATCH"
    if _state == "Accepted Retest"
        shortState := "ACCEPT"
    else if _state == "Rejected Retest"
        shortState := "FAIL"
    else if _state == "Risk Edge Hit"
        shortState := "RISK"
    else if _state == "Expired"
        shortState := "EXPIRE"
    else if _state == "Testing Pocket"
        shortState := "TEST"
    else if _state == "Breakout Armed"
        shortState := "ARMED"
    "RETEST POCKET\n" + shortState + " " + str.tostring(math.round(_score))

f_badge_text_color(_bgColor) =>
    float brightness = color.r(_bgColor) * 0.299 + color.g(_bgColor) * 0.587 + color.b(_bgColor) * 0.114
    brightness >= 145 ? panelBg : headerText

// -------------------------------------------------
// Core Measurements
// -------------------------------------------------
// Live Updating may preview developing scores, but durable state changes and
// alerts remain close-confirmed so a temporary intrabar touch cannot own a
// published plan state.
bool confirmedBar = barstate.isconfirmed
float atrRaw = ta.atr(atrLength)
float atr = math.max(nz(atrRaw, high - low), syminfo.mintick)

float upperRef = ta.highest(high[1], structureLookback)
float lowerRef = ta.lowest(low[1], structureLookback)
bool validStructure = not na(upperRef) and not na(lowerRef) and upperRef > lowerRef
float structureRange = validStructure ? math.max(upperRef - lowerRef, syminfo.mintick) : atr
float structureAtr = structureRange / atr

float fastEma = ta.ema(close, fastEmaLength)
float slowEma = ta.ema(close, slowEmaLength)
float slowSlope = slowEma - nz(slowEma[trendSlopeBars], slowEma)

float rawVolume = na(volume) ? 1.0 : volume
float volumeBase = nz(ta.sma(rawVolume, volumeLength), rawVolume)
float rvol = volumeBase > 0.0 ? rawVolume / volumeBase : 1.0

float sensitivityFactor = sensitivity == "Conservative" ? 1.20 : sensitivity == "Aggressive" ? 0.82 : 1.00
float activeBreakoutBufferAtr = breakoutBufferAtr * sensitivityFactor
float activeMinimumScore = minimumAcceptanceScore + (sensitivity == "Conservative" ? 4.0 : sensitivity == "Aggressive" ? -4.0 : 0.0)
float breakBuffer = atr * activeBreakoutBufferAtr

bool bullBreakNow = validStructure and confirmedBar and close > upperRef + breakBuffer and nz(close[1], close) <= upperRef + breakBuffer * 0.25
bool bearBreakNow = validStructure and confirmedBar and close < lowerRef - breakBuffer and nz(close[1], close) >= lowerRef - breakBuffer * 0.25
int newBreakDir = bullBreakNow ? 1 : bearBreakNow ? -1 : 0

float barRange = math.max(high - low, syminfo.mintick)
float bodyShare = math.abs(close - open) / barRange
float closeLocationBull = f_clamp((close - low) / barRange, 0.0, 1.0)
float closeLocationBear = f_clamp((high - close) / barRange, 0.0, 1.0)
float upperWickShare = (high - math.max(open, close)) / barRange
float lowerWickShare = (math.min(open, close) - low) / barRange

float breakDistanceAtr = 0.0
if newBreakDir == 1
    breakDistanceAtr := math.max(close - upperRef, 0.0) / atr
else if newBreakDir == -1
    breakDistanceAtr := math.max(lowerRef - close, 0.0) / atr
float breakDistanceScore = f_norm_high(breakDistanceAtr, activeBreakoutBufferAtr, activeBreakoutBufferAtr + 0.80)
float breakCandleScore = 0.0
if newBreakDir == 1
    breakCandleScore := closeLocationBull * 48.0 + bodyShare * 38.0 + f_norm_low(upperWickShare, 0.05, 0.40) * 0.14
else if newBreakDir == -1
    breakCandleScore := closeLocationBear * 48.0 + bodyShare * 38.0 + f_norm_low(lowerWickShare, 0.05, 0.40) * 0.14
float breakoutVolumeScore = na(volume) ? 55.0 : f_norm_high(rvol, 0.80, 1.55)
float bullTrendScore = (close >= slowEma ? 35.0 : 10.0) + (fastEma >= slowEma ? 35.0 : 10.0) + (slowSlope >= 0.0 ? 30.0 : 12.0)
float bearTrendScore = (close <= slowEma ? 35.0 : 10.0) + (fastEma <= slowEma ? 35.0 : 10.0) + (slowSlope <= 0.0 ? 30.0 : 12.0)
float breakTrendScore = newBreakDir == 1 ? bullTrendScore : newBreakDir == -1 ? bearTrendScore : 50.0
float structureScore = f_peak_score(structureAtr, 0.55, 2.80, 7.00)
float breakoutQualityNow = f_clamp(breakDistanceScore * 0.30 + breakCandleScore * 0.26 + breakoutVolumeScore * 0.18 + breakTrendScore * 0.18 + structureScore * 0.08, 0.0, 100.0)

// -------------------------------------------------
// Active Retest Plan
// -------------------------------------------------
var int activeDir = 0
var int activeBreakBar = na
var float activeBreakLine = na
var float activePocketWidth = na
var float activeInvalidation = na
var float activeTarget = na
var float activeAtr = na
var float activeBreakoutQuality = na
var float activeBreakVolumeRatio = na
var float activeBestExtensionAtr = 0.0
var bool retestTouched = false
var float deepestRetestAtr = 0.0
var string lockedOutcome = ""

if newBreakDir != 0
    activeDir := newBreakDir
    activeBreakBar := bar_index
    activeBreakLine := newBreakDir == 1 ? upperRef : lowerRef
    activePocketWidth := atr * pocketWidthAtr
    activeInvalidation := newBreakDir == 1 ? activeBreakLine - atr * invalidationShelfAtr : activeBreakLine + atr * invalidationShelfAtr
    activeTarget := activeBreakLine + newBreakDir * structureRange * targetRangeMultiple
    activeAtr := atr
    activeBreakoutQuality := breakoutQualityNow
    activeBreakVolumeRatio := rvol
    activeBestExtensionAtr := breakDistanceAtr
    retestTouched := false
    deepestRetestAtr := 0.0
    lockedOutcome := ""

bool hasActivePlan = activeDir != 0 and not na(activeBreakLine) and not na(activeBreakBar)
int barsSinceBreak = hasActivePlan ? bar_index - activeBreakBar : 0
float safeActiveAtr = math.max(nz(activeAtr, atr), syminfo.mintick)
float pocketTop = hasActivePlan ? activeBreakLine + activePocketWidth : na
float pocketBottom = hasActivePlan ? activeBreakLine - activePocketWidth : na
bool insideRetestPocket = hasActivePlan and high >= pocketBottom and low <= pocketTop
bool retestEligible = hasActivePlan and barsSinceBreak > 0 and barsSinceBreak <= maxRetestBars and lockedOutcome == ""

float currentExtensionAtr = 0.0
if hasActivePlan
    currentExtensionAtr := activeDir == 1 ? math.max(high - activeBreakLine, 0.0) / safeActiveAtr : math.max(activeBreakLine - low, 0.0) / safeActiveAtr
    activeBestExtensionAtr := math.max(nz(activeBestExtensionAtr, 0.0), currentExtensionAtr)

bool newTouchEvent = false
if retestEligible and insideRetestPocket and not retestTouched and confirmedBar
    retestTouched := true
    newTouchEvent := true

float currentRetestDepthAtr = 0.0
if hasActivePlan
    currentRetestDepthAtr := activeDir == 1 ? math.max(activeBreakLine - low, 0.0) / safeActiveAtr : math.max(high - activeBreakLine, 0.0) / safeActiveAtr
if retestTouched
    deepestRetestAtr := math.max(deepestRetestAtr, currentRetestDepthAtr)

float retestDepthScore = retestTouched ? f_peak_score(deepestRetestAtr, 0.0, pocketWidthAtr * 0.72, maxRetestDepthAtr) : 50.0
float wickScore = 50.0
if retestTouched and activeDir == 1
    wickScore := f_norm_high(lowerWickShare, 0.10, 0.46)
else if retestTouched and activeDir == -1
    wickScore := f_norm_high(upperWickShare, 0.10, 0.46)
float retestVolumeRatio = not na(activeBreakVolumeRatio) and activeBreakVolumeRatio > 0.0 ? rvol / activeBreakVolumeRatio : 1.0
float volumeChangeScore = retestTouched ? f_peak_score(retestVolumeRatio, 0.20, 0.72, 1.55) : 50.0
float currentTrendScore = activeDir == 1 ? bullTrendScore : activeDir == -1 ? bearTrendScore : 50.0
float breakoutQualityActive = nz(activeBreakoutQuality, 0.0)
float remainingTargetAtr = hasActivePlan ? (activeDir == 1 ? math.max(activeTarget - close, 0.0) / safeActiveAtr : math.max(close - activeTarget, 0.0) / safeActiveAtr) : 0.0
float separationScore = hasActivePlan ? f_norm_high(activeBestExtensionAtr, minimumSeparationAtr, minimumSeparationAtr + 0.90) : 50.0
float targetRoomScore = hasActivePlan ? f_norm_high(remainingTargetAtr, minimumRemainingRoomAtr, minimumRemainingRoomAtr + 1.40) : 50.0
bool constructiveSeparation = hasActivePlan and activeBestExtensionAtr >= minimumSeparationAtr
bool constructiveRoom = hasActivePlan and remainingTargetAtr >= minimumRemainingRoomAtr
float acceptanceScore = hasActivePlan ? f_clamp(breakoutQualityActive * 0.26 + retestDepthScore * 0.20 + wickScore * 0.18 + volumeChangeScore * 0.10 + currentTrendScore * 0.14 + separationScore * 0.07 + targetRoomScore * 0.05, 0.0, 100.0) : 0.0

bool acceptedCondition = hasActivePlan and retestTouched and lockedOutcome == "" and constructiveSeparation and constructiveRoom and acceptanceScore >= activeMinimumScore and (activeDir == 1 ? close >= activeBreakLine + activePocketWidth * 0.10 : close <= activeBreakLine - activePocketWidth * 0.10)
bool rejectedCondition = hasActivePlan and retestTouched and lockedOutcome == "" and (activeDir == 1 ? close < activeBreakLine - activePocketWidth * 0.70 : close > activeBreakLine + activePocketWidth * 0.70)
bool riskEdgeCondition = hasActivePlan and lockedOutcome == "" and (activeDir == 1 ? close < activeInvalidation : close > activeInvalidation)
bool expiredCondition = hasActivePlan and lockedOutcome == "" and barsSinceBreak > maxRetestBars and not retestTouched

bool acceptedEvent = acceptedCondition and confirmedBar
bool rejectedEvent = (rejectedCondition or riskEdgeCondition) and confirmedBar
bool expiredEvent = expiredCondition and confirmedBar

if acceptedEvent
    lockedOutcome := "Accepted Retest"
else if rejectedEvent and riskEdgeCondition
    lockedOutcome := "Risk Edge Hit"
else if rejectedEvent
    lockedOutcome := "Rejected Retest"
else if expiredEvent
    lockedOutcome := "Expired"

// -------------------------------------------------
// Retest-Win-Rate Proof
// When a retest locks as accepted, a win is recorded if price reaches one
// risk-distance in the breakout direction (a balanced one-risk target) before
// closing beyond the invalidation shelf. Samples that resolve neither inside
// the proof window are left unresolved and uncounted. Updated only on confirmed
// bars so the statistic does not repaint.
// -------------------------------------------------
var int   proofWins    = 0
var int   proofTotal   = 0
var bool  proofPending = false
var int   proofDir     = 0
var float proofTarget  = na
var float proofStop    = na
var int   proofStartBar = na

bool acceptArm = lockedOutcome == "Accepted Retest" and lockedOutcome[1] != "Accepted Retest"

if barstate.isconfirmed
    if proofPending
        favHit  = proofDir == 1 ? high >= proofTarget : low <= proofTarget
        stopHit = proofDir == 1 ? close < proofStop : close > proofStop
        expired = bar_index - proofStartBar >= proofWindowBars
        if favHit and stopHit
            proofTotal += 1
            proofPending := false
        else if favHit
            proofWins += 1
            proofTotal += 1
            proofPending := false
        else if stopHit
            proofTotal += 1
            proofPending := false
        else if expired
            proofPending := false
    if acceptArm and not na(activeInvalidation)
        riskDist = math.max(math.abs(close - activeInvalidation), safeActiveAtr * 0.10)
        proofDir := activeDir
        proofTarget := close + activeDir * riskDist
        proofStop := activeInvalidation
        proofStartBar := bar_index
        proofPending := true

float proofRate = proofTotal > 0 ? proofWins / proofTotal * 100.0 : na
float displayAcceptanceScore = confirmationMode == "Live Updating" or barstate.isconfirmed ? acceptanceScore : nz(acceptanceScore[1], acceptanceScore)

string stateText = "No Active Retest"
if hasActivePlan
    if lockedOutcome != ""
        stateText := lockedOutcome
    else if retestTouched
        stateText := "Testing Pocket"
    else
        stateText := "Breakout Armed"

string sideText = activeDir == 1 ? "Bullish" : activeDir == -1 ? "Bearish" : "None"
string actionText = "Wait for confirmed breakout"
if stateText == "Breakout Armed"
    if not constructiveSeparation
        actionText := "Wait for cleaner separation"
    else if not constructiveRoom
        actionText := "Room is tight"
    else
        actionText := "Wait for retest pocket"
else if stateText == "Testing Pocket"
    if not constructiveSeparation
        actionText := "Breakout is too shallow"
    else if not constructiveRoom
        actionText := "Retest room is tight"
    else if acceptanceScore >= watchScore
        actionText := "Review acceptance"
    else
        actionText := "Let retest prove itself"
else if stateText == "Accepted Retest"
    if constructiveRoom
        actionText := "Plan from risk shelf"
    else
        actionText := "Manage tight room"
else if stateText == "Rejected Retest"
    actionText := "Stand down from retest"
else if stateText == "Risk Edge Hit"
    actionText := "Review invalidation"
else if stateText == "Expired"
    actionText := "Wait for fresh break"

color stateColor = panelLabelCol
if stateText == "Accepted Retest"
    stateColor := activeDir == 1 ? bullColor : bearColor
else if stateText == "Testing Pocket"
    stateColor := acceptanceScore >= watchScore ? accentColor : neutralColor
else if stateText == "Breakout Armed"
    stateColor := accentColor
else if stateText == "Rejected Retest" or stateText == "Risk Edge Hit"
    stateColor := dangerColor
else if stateText == "Expired"
    stateColor := neutralColor

string riskEdgeText = hasActivePlan ? (activeDir == 1 ? "Below " : "Above ") + f_fmt_price(activeInvalidation) : "-"
string breakoutQualityText = hasActivePlan ? f_fmt_score(breakoutQualityActive) + " " + f_score_grade(breakoutQualityActive) : "-"
string acceptanceText = hasActivePlan ? f_fmt_score(displayAcceptanceScore) + " " + f_score_grade(displayAcceptanceScore) : "-"
string separationText = hasActivePlan ? str.tostring(math.round(activeBestExtensionAtr * 100.0) / 100.0) + " ATR" : "-"
string targetRoomText = hasActivePlan ? str.tostring(math.round(remainingTargetAtr * 100.0) / 100.0) + " ATR" : "-"
string proofText = proofTotal > 0 ? str.tostring(math.round(nz(proofRate, 0.0))) + "% (" + str.tostring(proofTotal) + ")" : "Building"

// -------------------------------------------------
// Chart Objects
// -------------------------------------------------
int leftX = hasActivePlan ? activeBreakBar : bar_index
int rightX = bar_index + forwardBars
string pocketText = f_state_compact(stateText, displayAcceptanceScore)
color planColor = activeDir == 1 ? bullColor : activeDir == -1 ? bearColor : neutralColor
color pocketColor = stateText == "Accepted Retest" ? planColor : stateText == "Rejected Retest" or stateText == "Risk Edge Hit" ? dangerColor : stateText == "Expired" ? neutralColor : accentColor
color pocketBadgeColor = color.new(pocketColor, 0)
color pocketTextColor = f_badge_text_color(pocketBadgeColor)
int pocketTagCenterX = int(math.round((leftX + rightX) * 0.5))
float pocketTagCenterY = (pocketTop + pocketBottom) * 0.5

var box retestPocketBox = na
var label retestPocketTag = na
var line breakoutLine = na
var line invalidationLine = na
var line targetLine = na
var label breakoutGuideTag = na
var label invalidationGuideTag = na
var label targetGuideTag = na

string breakoutGuideText = guideBadgeDetail == "Detailed" ? "BREAK LEVEL\n" + f_fmt_price(activeBreakLine) : "BREAK " + f_fmt_price(activeBreakLine)
string invalidationGuideText = guideBadgeDetail == "Detailed" ? "RISK EDGE\n" + f_fmt_price(activeInvalidation) : "RISK " + f_fmt_price(activeInvalidation)
string targetGuideText = guideBadgeDetail == "Detailed" ? "TARGET ROOM\n" + f_fmt_price(activeTarget) + " | " + targetRoomText : "TARGET " + f_fmt_price(activeTarget)

if barstate.islast
    if showRetestPocket and hasActivePlan
        if na(retestPocketBox)
            retestPocketBox := box.new(left = leftX, top = pocketTop, right = rightX, bottom = pocketBottom, xloc = xloc.bar_index, bgcolor = color.new(pocketColor, 58), border_color = color.new(pocketColor, 8), border_width = 1, text = "", text_color = pocketTextColor, text_size = f_text_size(labelFontSize), text_halign = text.align_center, text_valign = text.align_center)
        else
            box.set_left(retestPocketBox, leftX)
            box.set_right(retestPocketBox, rightX)
            box.set_top(retestPocketBox, pocketTop)
            box.set_bottom(retestPocketBox, pocketBottom)
            box.set_bgcolor(retestPocketBox, color.new(pocketColor, 58))
            box.set_border_color(retestPocketBox, color.new(pocketColor, 8))
            box.set_text(retestPocketBox, "")
            box.set_text_size(retestPocketBox, f_text_size(labelFontSize))
        if na(retestPocketTag)
            retestPocketTag := label.new(pocketTagCenterX, pocketTagCenterY, pocketText, xloc = xloc.bar_index, style = label.style_label_center, color = pocketBadgeColor, textcolor = pocketTextColor, size = f_text_size(labelFontSize), textalign = text.align_center)
        else
            label.set_xy(retestPocketTag, pocketTagCenterX, pocketTagCenterY)
            label.set_text(retestPocketTag, pocketText)
            label.set_color(retestPocketTag, pocketBadgeColor)
            label.set_textcolor(retestPocketTag, pocketTextColor)
            label.set_size(retestPocketTag, f_text_size(labelFontSize))
    else
        if not na(retestPocketBox)
            box.delete(retestPocketBox)
            retestPocketBox := na
        if not na(retestPocketTag)
            label.delete(retestPocketTag)
            retestPocketTag := na

    if showBreakoutLine and hasActivePlan
        if na(breakoutLine)
            breakoutLine := line.new(leftX, activeBreakLine, rightX, activeBreakLine, xloc = xloc.bar_index, color = color.new(planColor, 5), width = 2)
        else
            line.set_xy1(breakoutLine, leftX, activeBreakLine)
            line.set_xy2(breakoutLine, rightX, activeBreakLine)
            line.set_color(breakoutLine, color.new(planColor, 5))
        if na(breakoutGuideTag)
            breakoutGuideTag := label.new(rightX, activeBreakLine, breakoutGuideText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(planColor, 0), textcolor = f_badge_text_color(planColor), size = f_text_size(labelFontSize), textalign = text.align_center, tooltip = "Broken structure level anchoring the active retest plan.")
        else
            label.set_xy(breakoutGuideTag, rightX, activeBreakLine)
            label.set_text(breakoutGuideTag, breakoutGuideText)
            label.set_color(breakoutGuideTag, color.new(planColor, 0))
            label.set_textcolor(breakoutGuideTag, f_badge_text_color(planColor))
            label.set_size(breakoutGuideTag, f_text_size(labelFontSize))
    else
        if not na(breakoutLine)
            line.delete(breakoutLine)
            breakoutLine := na
        if not na(breakoutGuideTag)
            label.delete(breakoutGuideTag)
            breakoutGuideTag := na

    if showRiskTargetGuides and hasActivePlan
        if na(invalidationLine)
            invalidationLine := line.new(leftX, activeInvalidation, rightX, activeInvalidation, xloc = xloc.bar_index, color = color.new(dangerColor, 10), style = line.style_dashed, width = 1)
        else
            line.set_xy1(invalidationLine, leftX, activeInvalidation)
            line.set_xy2(invalidationLine, rightX, activeInvalidation)
            line.set_color(invalidationLine, color.new(dangerColor, 10))
        if na(targetLine)
            targetLine := line.new(leftX, activeTarget, rightX, activeTarget, xloc = xloc.bar_index, color = color.new(accentColor, 12), style = line.style_dotted, width = 1)
        else
            line.set_xy1(targetLine, leftX, activeTarget)
            line.set_xy2(targetLine, rightX, activeTarget)
            line.set_color(targetLine, color.new(accentColor, 12))
        if na(invalidationGuideTag)
            invalidationGuideTag := label.new(rightX, activeInvalidation, invalidationGuideText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(dangerColor, 0), textcolor = f_badge_text_color(dangerColor), size = f_text_size(labelFontSize), textalign = text.align_center, tooltip = "Planning invalidation reference for the active retest. It is not a stop recommendation.")
        else
            label.set_xy(invalidationGuideTag, rightX, activeInvalidation)
            label.set_text(invalidationGuideTag, invalidationGuideText)
            label.set_color(invalidationGuideTag, color.new(dangerColor, 0))
            label.set_textcolor(invalidationGuideTag, f_badge_text_color(dangerColor))
            label.set_size(invalidationGuideTag, f_text_size(labelFontSize))
        if na(targetGuideTag)
            targetGuideTag := label.new(rightX, activeTarget, targetGuideText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 0), textcolor = f_badge_text_color(accentColor), size = f_text_size(labelFontSize), textalign = text.align_center, tooltip = "Projected target-room context for the active retest plan. It is not a price forecast.")
        else
            label.set_xy(targetGuideTag, rightX, activeTarget)
            label.set_text(targetGuideTag, targetGuideText)
            label.set_color(targetGuideTag, color.new(accentColor, 0))
            label.set_textcolor(targetGuideTag, f_badge_text_color(accentColor))
            label.set_size(targetGuideTag, f_text_size(labelFontSize))
    else
        if not na(invalidationLine)
            line.delete(invalidationLine)
            invalidationLine := na
        if not na(targetLine)
            line.delete(targetLine)
            targetLine := na
        if not na(invalidationGuideTag)
            label.delete(invalidationGuideTag)
            invalidationGuideTag := na
        if not na(targetGuideTag)
            label.delete(targetGuideTag)
            targetGuideTag := na

// -------------------------------------------------
// Event Labels
// -------------------------------------------------
var array<label> eventLabels = array.new<label>()
var int lastLabelBar = na
var int lastContextLabelBar = na
var int lastUpperLabelBar = na
var int lastLowerLabelBar = na

bool breakoutEvent = newBreakDir != 0
bool contextAllowed = showContextLabels and hasActivePlan and lockedOutcome == "" and (na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextLabelSpacing)
bool labelEvent = breakoutEvent or newTouchEvent or acceptedEvent or rejectedEvent or expiredEvent
bool labelReady = na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldown
bool shouldPrintLabel = showLabels and confirmedBar and hasActivePlan and ((labelEvent and labelReady) or (contextAllowed and labelReady))

if shouldPrintLabel
    bool labelLong = activeDir == 1
    float labelY = labelLong ? low - atr * labelOffsetAtr : high + atr * labelOffsetAtr
    bool stackLongLabel = labelLong and not na(lastLowerLabelBar) and bar_index - lastLowerLabelBar <= labelCooldown
    bool stackShortLabel = not labelLong and not na(lastUpperLabelBar) and bar_index - lastUpperLabelBar <= labelCooldown
    if stackLongLabel
        labelY -= atr * labelStackAtr
    if stackShortLabel
        labelY += atr * labelStackAtr
    string compactText = "ARMED\n" + str.tostring(math.round(breakoutQualityActive))
    if newTouchEvent
        compactText := "TEST\n" + str.tostring(math.round(acceptanceScore))
    else if acceptedEvent
        compactText := "ACCEPT\n" + str.tostring(math.round(acceptanceScore))
    else if rejectedEvent
        compactText := riskEdgeCondition ? "RISK\nEDGE" : "REJECT\n" + str.tostring(math.round(acceptanceScore))
    else if expiredEvent
        compactText := "EXPIRE"
    else if contextAllowed
        compactText := constructiveSeparation and constructiveRoom and acceptanceScore >= watchScore ? "READY\n" + str.tostring(math.round(acceptanceScore)) : "WATCH\n" + str.tostring(math.round(acceptanceScore))
    string detailedText = stateText + "\nScore " + str.tostring(math.round(acceptanceScore)) + "\n" + sideText
    string labelText = labelTextMode == "Compact" ? compactText : detailedText
    string tooltipText = "Breakout Retest Readiness\nRetest State: " + stateText + "\nAcceptance Score: " + acceptanceText + "\nBreakout Quality: " + breakoutQualityText + "\nBreakout Separation: " + separationText + "\nRemaining Target Room: " + targetRoomText + "\nRisk Edge: " + riskEdgeText + "\nAction: " + actionText
    color labelBg = color.new(stateColor, 8)
    label newLabel = label.new(bar_index, labelY, labelText, xloc = xloc.bar_index, style = labelLong ? label.style_label_up : label.style_label_down, color = labelBg, textcolor = f_badge_text_color(stateColor), size = f_text_size(labelFontSize), tooltip = tooltipText, textalign = text.align_center)
    array.push(eventLabels, newLabel)
    lastLabelBar := bar_index
    if contextAllowed and not labelEvent
        lastContextLabelBar := bar_index
    if labelLong
        lastLowerLabelBar := bar_index
    else
        lastUpperLabelBar := bar_index
    while array.size(eventLabels) > maxVisibleLabels
        label.delete(array.shift(eventLabels))

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table infoPanel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""

color panelBgActive = panelTheme == "Dark" ? panelBg : color.rgb(248, 250, 252)
color rowBgActive = panelTheme == "Dark" ? color.rgb(17, 24, 39) : color.rgb(241, 245, 249)
color panelLabelActive = panelTheme == "Dark" ? panelLabelCol : color.rgb(71, 85, 105)
color panelValueActive = panelTheme == "Dark" ? panelValueCol : color.rgb(15, 23, 42)
color panelBorderActive = panelTheme == "Dark" ? panelBorder : color.rgb(203, 213, 225)
color proofColor = na(proofRate) ? panelValueActive : proofRate >= 55 ? bullColor : proofRate >= 45 ? neutralColor : bearColor

if barstate.islast
    if showPanel
        if na(infoPanel) or panelLocation != lastPanelLocation or panelTheme != lastPanelTheme
            if not na(infoPanel)
                table.delete(infoPanel)
            infoPanel := table.new(f_panel_pos(panelLocation), 2, 8, bgcolor = panelBgActive, frame_color = panelBorderActive, frame_width = 1, border_color = panelBorderActive, border_width = 1)
            lastPanelLocation := panelLocation
            lastPanelTheme := panelTheme
        table.clear(infoPanel, 0, 0, 1, 7)
        table.merge_cells(infoPanel, 0, 0, 1, 0)
        table.cell(infoPanel, 0, 0, "AG Pro Breakout Retest Readiness", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        f_panel_row(infoPanel, 1, "Retest State", stateText, stateColor, rowBgActive, panelLabelActive, f_text_size(panelFontSize))
        f_panel_row(infoPanel, 2, "Acceptance Score", acceptanceText, f_score_color(displayAcceptanceScore), panelBgActive, panelLabelActive, f_text_size(panelFontSize))
        f_panel_row(infoPanel, 3, "Breakout Quality", breakoutQualityText, hasActivePlan ? f_score_color(breakoutQualityActive) : panelValueActive, rowBgActive, panelLabelActive, f_text_size(panelFontSize))
        f_panel_row(infoPanel, 4, "Risk Edge", riskEdgeText, stateText == "Risk Edge Hit" ? dangerColor : panelValueActive, panelBgActive, panelLabelActive, f_text_size(panelFontSize))
        f_panel_row(infoPanel, 5, "Target Room", targetRoomText, constructiveRoom ? bullColor : neutralColor, rowBgActive, panelLabelActive, f_text_size(panelFontSize))
        f_panel_row(infoPanel, 6, "Retest Win Rate", proofText, proofColor, panelBgActive, panelLabelActive, f_text_size(panelFontSize))
        f_panel_row(infoPanel, 7, "Action", actionText, stateColor, rowBgActive, panelLabelActive, f_text_size(panelFontSize))
    else
        if not na(infoPanel)
            table.delete(infoPanel)
            infoPanel := na
            lastPanelLocation := ""
            lastPanelTheme := ""

// -------------------------------------------------
// Alerts
// -------------------------------------------------
bool acceptedAlert = acceptedEvent and acceptanceScore >= alertScore
bool retestTouchAlert = newTouchEvent and acceptanceScore >= watchScore
bool breakoutAlert = breakoutEvent and breakoutQualityActive >= watchScore
bool rejectedAlert = rejectedEvent
bool expiredAlert = expiredEvent

alertcondition(breakoutAlert, "Breakout Retest Plan Armed", "Breakout Retest Readiness: a breakout retest plan is armed. This is an attention marker, not a trade instruction.")
alertcondition(retestTouchAlert, "Retest Pocket Touched", "Breakout Retest Readiness: price is interacting with the active retest pocket. Review acceptance context.")
alertcondition(acceptedAlert, "Accepted Retest Readiness", "Breakout Retest Readiness: retest acceptance quality is active. This is an attention marker, not a trade instruction.")
alertcondition(rejectedAlert, "Rejected Retest Or Risk Edge", "Breakout Retest Readiness: the active retest is rejected or the risk edge is under pressure.")
alertcondition(expiredAlert, "Retest Plan Expired", "Breakout Retest Readiness: the retest window expired before constructive interaction.")
````
