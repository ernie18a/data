# Stop Run Reversal Planner [AGPro Series]

- url: https://www.tradingview.com/script/e8AVlbrV-Stop-Run-Reversal-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;faa9e166bfea407fada8753a45faee78
- version: 3.0

## Description

Stop Run Reversal Planner [AGPro Series]

🧠 Core Idea

Did a stop run create a confirmed reversal context with clear risk, target room, and next-action guidance?


📌 Overview / What it does

Stop Run Reversal Planner [AGPro Series] is a chart-first stop-run reversal planning tool built to evaluate wick sweeps around recent range extremes.

The script detects when price runs beyond a prior high or low, checks whether price closes back through the swept reference, evaluates confirmation candle quality, scores volume response, measures target room, and converts the context into a 0-100 reversal readiness score.

It produces stop-run wick zones, confirmation labels, reclaim rails, invalidation guides, reversal target bands, alerts, and a clean AGPro planning panel. It does not predict price direction, automate execution, or claim that every stop run must reverse.


🎯 Purpose & Design Philosophy

This script was built for traders who want structure after a fast liquidity run instead of another simple sweep marker.

Stop-run candles can look dramatic, but not every sweep deserves the same attention. Some sweeps reclaim cleanly, confirm with stronger candle behavior, and leave usable target room. Others are only noise, continuation, or incomplete rejection.

The design supports a planning workflow: identify the stop run, wait for confirmation, read the readiness score, check invalidation, review target room, and decide whether the context deserves attention.


⚡ Why This Script Is Different

Most stop-hunt tools focus on mapping sweep zones or marking that liquidity was taken.

This script does NOT try to clone a stop-hunt map, liquidity grab detector, liquidity sweep engine, order block map, or broad SMC dashboard.

Instead, it focuses on the post-stop-run reversal decision. The key question is not only "was a stop run printed?" The key question is "did that stop run turn into a confirmed reversal plan with acceptable reclaim quality, invalidation logic, and target room?"


⚙️ Methodology

1. Context Detection
The script tracks recent range highs and lows, then checks whether price runs beyond one side with a meaningful wick sweep.

2. Reference Mapping
The swept reference becomes the reclaim rail. The sweep extreme becomes the invalidation guide. The opposite side of the reference range, or an ATR fallback, becomes the target-room guide.

3. Reaction Evaluation
The scoring model evaluates wick sweep quality, close-back-inside behavior, confirmation candle quality, relative volume response, trend-turn context, and available target room.

4. Visual Output
Qualified contexts are displayed through stop-run wick zones, confirmation labels, reclaim rails, invalidation lines, target bands, alerts, and a compact AGPro panel.


🗺️ How to Read the Chart

Zones = the stop-run wick zone between the swept reference and the sweep extreme.

Labels = stop-run watch, confirmed reversal, invalidation, and target-band review markers.

Colors = teal highlights bullish reversal contexts, pink highlights bearish reversal contexts, amber marks watch states, and indigo marks target-room areas.

Panel = the panel summarizes Stop Run, Confirmation, Reclaim Quality, Invalidation, and Action.


🚦 Signals & States

• Bull Stop Run Watch → price swept below the recent low and may need confirmation.

• Bear Stop Run Watch → price swept above the recent high and may need confirmation.

• Bull Reversal Confirmed → downside stop run reclaimed with enough confirmation quality and target room.

• Bear Reversal Confirmed → upside stop run rejected with enough confirmation quality and target room.

• Reversal Invalidated → price crossed the active invalidation guide.

• Target Band Review → price reached the active reversal target band.


🔔 Alerts Logic

Alerts trigger when a bull or bear stop-run watch appears, when a bull or bear reversal confirmation becomes active, when invalidation is crossed, or when the target band is reached.

Alerts are attention markers. They are not trade instructions, entry signals, exit signals, or automation commands.


🧩 Confluence Logic

The reversal context becomes stronger when multiple factors align:

Stop-run wick + close back inside + strong confirmation candle + supportive volume response + usable target room + cleaner trend-turn behavior.

When only one or two factors appear, the script keeps the context in watch mode or ignores it completely.


📊 When to Use

• After fast wick sweeps beyond recent highs or lows

• Around failed breakout or failed breakdown attempts

• In range-edge reversal review workflows

• When price reclaims a swept level and needs structured confirmation

• When a trader wants risk, target, and action context instead of only a sweep marker


⚠️ When NOT to Use

• Very low-liquidity symbols

• Extremely noisy micro-timeframes

• News candles with abnormal gaps

• Strong one-way trend conditions where stop runs may continue rather than reverse

• Situations where the user wants an automatic buy or sell signal


🎛️ Key Inputs

• Stop-Run Reference Lookback → controls the recent high / low range used for sweep detection.

• Sensitivity → changes how selective wick-sweep detection should be.

• Confirmation Mode → controls how strict the post-sweep confirmation candle must be.

• Minimum Reversal Score → sets the 0-100 score required before a confirmed plan is drawn.

• Confirmation Window Bars → defines how long a stop run can wait for confirmation.

• Target Room ATR Fallback → creates a practical target guide when the opposite range side is not useful.

• Invalidation Buffer ATR → places the invalidation guide beyond the sweep extreme.

• Visual settings → control zones, rails, target bands, labels, panel location, panel theme, and font sizes.


🖥️ Interface & Visual Design

The interface is built to stay chart-first.

The panel gives the decision summary. The stop-run zone shows where the sweep happened. The reclaim rail shows the level price had to recover. The invalidation line marks the level that would weaken the reversal context. The target band gives a structured review area without making a promise.

The layout is intentionally compact, readable, and publication-friendly.


🧪 Practical Usage Workflow

1. Read the panel to identify the current Stop Run and Confirmation state.

2. Check whether the chart shows a stop-run wick zone and reclaim rail.

3. Review the Reclaim Quality score and confirmation label.

4. Compare the current price with invalidation and target-band guides.

5. Interpret the context with broader market structure, liquidity, and volatility conditions.


🔍 Interpretation Guidelines

A stop-run watch means price has swept a recent edge, but the reversal plan is not yet confirmed.

A confirmed reversal state means the script found stronger reclaim, candle, volume, and target-room conditions.

An invalidation marker means the active context weakened according to the script rules.

A target-band review marker means price reached a planned review area, not that the move must stop there.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not an auto trading system

• Not a guaranteed signal tool

• Not a stop-hunt zone map

• Not a liquidity grab detector

• Not an order block or FVG map

• Not a generic SMC dashboard


⚠️ Limitations & Transparency

Stop-run behavior changes across symbols, sessions, and timeframes.

Some stop runs continue instead of reversing. Some reclaim attempts fail after confirmation. Some symbols have weak or unreliable volume data, which can affect the score model.

The script provides structured context, not certainty.


🧠 Market Context Notes

Stop-run reversal behavior often appears near visible range edges, prior swing highs, prior swing lows, and failed breakout areas.

The strongest contexts usually combine a meaningful sweep, clean reclaim, strong confirmation candle, usable room, and a clear invalidation guide.


🧾 Use Case Examples

When price runs below a recent low, leaves a strong lower wick, closes back above the swept reference, and confirms with stronger follow-through, the script may classify the context as a bullish stop-run reversal plan.

When price runs above a recent high, rejects the move, closes back below the swept reference, and confirms with stronger downside behavior, the script may classify the context as a bearish stop-run reversal plan.


🧱 System Philosophy

Stop Run Reversal Planner follows the AGPro decision-engine approach: the goal is not to add another signal to the chart, but to organize the decision around validity, score, risk, target room, and next action.


🔐 Non-Promise Statement

No script can guarantee a reversal, outcome, or market reaction.

This script provides rule-based analytical context only.


📉 Risk Disclosure

Trading involves risk.

Users remain responsible for their own decisions, execution, risk management, and interpretation.

This script does not provide financial advice.


📚 Educational Note

Use the output as a structured review layer. The best readings usually come from combining the planner state with broader market structure, timeframe context, liquidity conditions, and personal risk rules.

## Source Code

````pine
// -------------------------------------------------
// Stop Run Reversal Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Stop Run Reversal Planner is a chart-first stop-run reversal planning tool.
// It studies wick sweeps, close-back-inside behavior, confirmation candles,
// volume response, reclaim quality, invalidation distance, and target room to
// convert a possible stop run into a structured 0-100 reversal readiness score.
// -------------------------------------------------

//@version=6
indicator("Stop Run Reversal Planner [AGPro Series]",
     shorttitle = "AG Pro SRP",
     overlay = true,
     max_boxes_count = 90,
     max_labels_count = 180,
     max_lines_count = 120)

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
// Tooltips
// -------------------------------------------------
string ttLookback = "Defines the recent high / low range used as the stop-run reference. The current bar is excluded so sweeps are evaluated against prior structure."
string ttAtr = "ATR length used for sweep depth, wick-zone height, reclaim quality, invalidation buffers, target bands, and label spacing."
string ttVolume = "Volume baseline used to score participation during the stop run and confirmation. On symbols with weak volume data, this component becomes neutral."
string ttSensitivity = "Controls how selective stop-run detection should be. Conservative requires a cleaner wick sweep, while Aggressive reacts to smaller runs."
string ttConfirmMode = "Controls how strict the confirmation candle must be after a stop run. Strict mode requires stronger close location and body efficiency."
string ttConfirmClose = "When enabled, new labels and alerts wait for bar close. This keeps public chart behavior stable and easier to publish."
string ttWindow = "Number of bars after the stop run where reversal confirmation can still qualify. After this window the setup is treated as stale."
string ttPlanCooldown = "Minimum bars between confirmed reversal plans. This prevents repeated plans around the same swept reference while preserving selective historical context."
string ttMinScore = "Minimum 0-100 reversal readiness score required before a confirmed reversal plan is drawn on the chart."
string ttWatchScore = "Minimum 0-100 setup score required before a stop-run watch label can appear."
string ttCooldown = "Minimum bars between event labels. Higher values reduce repeated labels in fast markets."
string ttMaxObjects = "Caps historical boxes, rails, target bands, and labels to keep the script fast and visually controlled."
string ttTarget = "ATR fallback used when the opposite side of the reference range does not provide enough target room."
string ttInvalid = "ATR buffer placed beyond the stop-run extreme to define the invalidation guide."
string ttTargetBand = "ATR thickness around the target guide. The target band is a planning reference, not a forecast."
string ttZones = "Shows the stop-run wick zone between the swept reference and the sweep extreme. Zone labels are centered as contrast-safe badges."
string ttRails = "Shows reclaim, invalidation, and target guide rails for confirmed reversal plans."
string ttTargetBox = "Shows a forward target-room band with a centered premium badge for the active reversal plan."
string ttLabels = "Shows compact fallback event labels when the corresponding zone or target badge is hidden. Visible plan objects otherwise carry their own identity."
string ttLabelMode = "Compact keeps public screenshots clean. Detailed adds score, grade, and action context directly on chart labels."
string ttWatchLabels = "Shows early stop-run watch labels before confirmation. Disabled by default to keep public screenshots focused on confirmed planning states."
string ttResetLabels = "Shows reset labels when an unconfirmed stop-run watch becomes invalid. Disabled by default because these are workflow notes, not major chart events."
string ttLabelSize = "Controls all chart labels and centered zone badges. Normal is the default publication size."
string ttOffset = "ATR-based label offset that keeps labels away from candles."
string ttShowPanel = "Shows or hides the planning panel. The default is visible for public-release clarity."
string ttPanelLocation = "Moves the planning panel to the preferred chart location."
string ttPanelTheme = "Switches the panel between AGPro dark and clean light themes while preserving the merged blue header row."
string ttPanelFont = "Controls panel text size. Normal is the default publication size."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Stop-Run Reversal Engine"
int lookback = input.int(34, "Stop-Run Reference Lookback", minval = 10, maxval = 220, group = groupEngine, tooltip = ttLookback)
int atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupEngine, tooltip = ttAtr)
int volumeLength = input.int(34, "Volume Baseline Length", minval = 5, maxval = 200, group = groupEngine, tooltip = ttVolume)
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Aggressive", "Balanced", "Conservative"], group = groupEngine, tooltip = ttSensitivity)
string confirmationMode = input.string("Balanced", "Confirmation Mode", options = ["Fast", "Balanced", "Strict"], group = groupEngine, tooltip = ttConfirmMode)
bool confirmOnClose = input.bool(true, "Confirm On Bar Close", group = groupEngine, tooltip = ttConfirmClose)
int confirmationWindowBars = input.int(5, "Confirmation Window Bars", minval = 1, maxval = 20, group = groupEngine, tooltip = ttWindow)
int planCooldownBars = input.int(18, "Confirmed Plan Cooldown Bars", minval = 1, maxval = 120, group = groupEngine, tooltip = ttPlanCooldown)

string groupScore = "Readiness Score"
int minReadinessScore = input.int(66, "Minimum Reversal Score", minval = 40, maxval = 95, group = groupScore, tooltip = ttMinScore)
int watchScore = input.int(58, "Stop-Run Watch Score", minval = 20, maxval = 90, group = groupScore, tooltip = ttWatchScore)

string groupRisk = "Risk / Target Logic"
float targetAtrFallback = input.float(1.35, "Target Room ATR Fallback", minval = 0.40, maxval = 5.00, step = 0.05, group = groupRisk, tooltip = ttTarget)
float invalidationBufferAtr = input.float(0.18, "Invalidation Buffer ATR", minval = 0.00, maxval = 1.50, step = 0.01, group = groupRisk, tooltip = ttInvalid)
float targetBandAtr = input.float(0.22, "Target Band Thickness ATR", minval = 0.05, maxval = 1.50, step = 0.01, group = groupRisk, tooltip = ttTargetBand)

string groupVisual = "Chart Visuals"
bool showStopRunZones = input.bool(true, "Show Stop-Run Wick Zones", group = groupVisual, tooltip = ttZones)
bool showGuideRails = input.bool(true, "Show Reclaim / Risk Rails", group = groupVisual, tooltip = ttRails)
bool showTargetBands = input.bool(true, "Show Reversal Target Band", group = groupVisual, tooltip = ttTargetBox)
int forwardBars = input.int(34, "Forward Render Bars", minval = 8, maxval = 160, group = groupVisual)
int zoneTransparency = input.int(86, "Zone Transparency", minval = 70, maxval = 96, group = groupVisual)
float minZoneHeightAtr = input.float(0.12, "Minimum Zone Height ATR", minval = 0.02, maxval = 1.00, step = 0.01, group = groupVisual)

string groupLabels = "Labels"
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
string labelTextMode = input.string("Compact", "Label Text Mode", options = ["Compact", "Detailed"], group = groupLabels, tooltip = ttLabelMode)
bool showWatchLabels = input.bool(false, "Show Watch Labels", group = groupLabels, tooltip = ttWatchLabels)
bool showResetLabels = input.bool(false, "Show Reset Labels", group = groupLabels, tooltip = ttResetLabels)
int labelCooldownBars = input.int(12, "Label Cooldown Bars", minval = 1, maxval = 80, group = groupLabels, tooltip = ttCooldown)
int maxVisibleObjects = input.int(4, "Max Visible Object Sets", minval = 2, maxval = 20, group = groupLabels, tooltip = ttMaxObjects)
float labelOffsetAtr = input.float(0.90, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttOffset)
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_norm_high(float value, float weak, float strong) =>
    float span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_peak_score(float value, float weak, float ideal, float excessive) =>
    float result = 0.0
    if value <= ideal
        result := f_norm_high(value, weak, ideal)
    else
        result := f_clamp((excessive - value) / math.max(excessive - ideal, 0.0001) * 100.0, 0.0, 100.0)
    result

f_text_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

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

f_fmt_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_score_text(float value) =>
    na(value) ? "-" : str.tostring(math.round(f_clamp(value, 0.0, 100.0))) + "/100"

f_grade(float score) =>
    string result = "D"
    if score >= 86.0
        result := "A+"
    else if score >= 76.0
        result := "A"
    else if score >= 66.0
        result := "B"
    else if score >= 55.0
        result := "C"
    result

f_score_color(float score) =>
    color result = panelValueCol
    if score >= minReadinessScore
        result := bullColor
    else if score >= watchScore
        result := neutralColor
    else if score >= 35.0
        result := accentColor
    result

f_side_color(int dir) =>
    dir == 1 ? bullColor : dir == -1 ? bearColor : panelValueCol

f_panel_bg(string themeText) =>
    themeText == "Clean Light" ? color.rgb(241, 245, 249) : panelBg

f_panel_border(string themeText) =>
    themeText == "Clean Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string themeText) =>
    themeText == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string themeText) =>
    themeText == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string themeText, int row) =>
    bool evenRow = row % 2 == 0
    if themeText == "Clean Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)
    else
        evenRow ? color.rgb(20, 31, 52) : panelBg

f_panel_row(table target, int row, string labelText, string valueText, color valueColor, string themeText, string sizeText) =>
    color rowBg = f_row_bg(themeText, row)
    table.cell(target, 0, row, labelText, text_color = f_panel_label(themeText), bgcolor = rowBg, text_size = f_text_size(sizeText), text_halign = text.align_left)
    table.cell(target, 1, row, valueText, text_color = valueColor, bgcolor = rowBg, text_size = f_text_size(sizeText), text_halign = text.align_right)

f_trim_labels(array<label> items, int maxCount) =>
    while array.size(items) > maxCount
        label oldItem = array.shift(items)
        label.delete(oldItem)

f_keep_label(array<label> items, label newItem, int maxCount) =>
    array.push(items, newItem)
    f_trim_labels(items, maxCount)

f_keep_box(array<box> items, box newItem, int maxCount) =>
    array.push(items, newItem)
    while array.size(items) > maxCount
        box oldItem = array.shift(items)
        box.delete(oldItem)

f_keep_line(array<line> items, line newItem, int maxCount) =>
    array.push(items, newItem)
    while array.size(items) > maxCount
        line oldItem = array.shift(items)
        line.delete(oldItem)

f_zone_badge(string textValue, int x1, int x2, float topValue, float bottomValue, color badgeColor, array<label> store, int maxCount, string sizeText) =>
    int x = int(math.round((x1 + x2) * 0.5))
    float y = (topValue + bottomValue) * 0.5
    label item = label.new(x, y, textValue, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(badgeColor, 0), textcolor = headerText, size = f_text_size(sizeText), textalign = text.align_center)
    f_keep_label(store, item, maxCount)
    item

// -------------------------------------------------
// Core Model
// -------------------------------------------------
bool confirmedBar = confirmOnClose ? barstate.isconfirmed : true
float atrRaw = ta.atr(atrLength)
float atr = math.max(nz(atrRaw, high - low), syminfo.mintick)
float upperRefRaw = ta.highest(high[1], lookback)
float lowerRefRaw = ta.lowest(low[1], lookback)
bool rangeReady = not na(upperRefRaw) and not na(lowerRefRaw) and upperRefRaw > lowerRefRaw
float upperRef = rangeReady ? upperRefRaw : high
float lowerRef = rangeReady ? lowerRefRaw : low

float candleRange = math.max(high - low, syminfo.mintick)
float body = math.abs(close - open)
float bodyShare = body / candleRange
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float upperWickShare = upperWick / candleRange
float lowerWickShare = lowerWick / candleRange
float closeLocation = (close - low) / candleRange
float volumeBase = ta.sma(volume, volumeLength)
float volumeRatio = volumeBase > 0.0 ? volume / volumeBase : 1.0
float fastEma = ta.ema(close, 8)
float slowEma = ta.ema(close, 21)

float minPenAtr = 0.06
float wickNeed = 0.42
if sensitivity == "Aggressive"
    minPenAtr := 0.035
    wickNeed := 0.34
else if sensitivity == "Conservative"
    minPenAtr := 0.10
    wickNeed := 0.50

float closeNeed = 0.58
float bodyNeed = 0.24
float reclaimPadAtr = 0.00
if confirmationMode == "Fast"
    closeNeed := 0.52
    bodyNeed := 0.16
    reclaimPadAtr := -0.03
else if confirmationMode == "Strict"
    closeNeed := 0.66
    bodyNeed := 0.34
    reclaimPadAtr := 0.05

float bullPenAtr = rangeReady ? math.max((lowerRef - low) / atr, 0.0) : 0.0
float bearPenAtr = rangeReady ? math.max((high - upperRef) / atr, 0.0) : 0.0
bool bullSweepSeed = confirmedBar and rangeReady and bullPenAtr >= minPenAtr and lowerWickShare >= wickNeed
bool bearSweepSeed = confirmedBar and rangeReady and bearPenAtr >= minPenAtr and upperWickShare >= wickNeed

float bullWickScore = f_norm_high(lowerWickShare, wickNeed * 0.75, 0.78)
float bearWickScore = f_norm_high(upperWickShare, wickNeed * 0.75, 0.78)
float bullPenScore = f_peak_score(bullPenAtr, minPenAtr, 0.42, 1.50)
float bearPenScore = f_peak_score(bearPenAtr, minPenAtr, 0.42, 1.50)
float bullSeedScore = f_clamp(bullWickScore * 0.56 + bullPenScore * 0.34 + f_norm_high(volumeRatio, 0.85, 1.70) * 0.10, 0.0, 100.0)
float bearSeedScore = f_clamp(bearWickScore * 0.56 + bearPenScore * 0.34 + f_norm_high(volumeRatio, 0.85, 1.70) * 0.10, 0.0, 100.0)

var int pendingDir = 0
var int pendingBar = na
var float pendingRef = na
var float pendingExtreme = na
var float pendingOpposite = na
var float pendingSeedScore = na
var float pendingWickScore = na
var float pendingPenScore = na
var float pendingVolumeScore = na

var int activeDir = 0
var int activeUntil = na
var float activeScore = na
var float activeReclaimQuality = na
var float activeInvalidation = na
var float activeTarget = na
var float activeReclaim = na
var string activeAction = "Stand Aside"
var string activeState = "No Setup"
var bool activeTargetHit = false
var int activeOutcome = 0

var int lastLabelBar = na
var int lastConfirmedBar = na
var label activeStopBadge = na
var label activeTargetBadge = na
var array<label> labelStore = array.new<label>()
var array<label> zoneLabelStore = array.new<label>()
var array<box> boxStore = array.new<box>()
var array<line> lineStore = array.new<line>()

bool seedEvent = false
if bullSweepSeed and bullSeedScore >= math.max(20.0, watchScore - 12.0)
    bool replaceBullSeed = pendingDir != 1 or na(pendingExtreme) or low < pendingExtreme or (not na(pendingBar) and bar_index - pendingBar > confirmationWindowBars)
    if replaceBullSeed
        pendingDir := 1
        pendingBar := bar_index
        pendingRef := lowerRef
        pendingExtreme := low
        pendingOpposite := upperRef
        pendingSeedScore := bullSeedScore
        pendingWickScore := bullWickScore
        pendingPenScore := bullPenScore
        pendingVolumeScore := f_norm_high(volumeRatio, 0.85, 1.70)
        seedEvent := true
else if bearSweepSeed and bearSeedScore >= math.max(20.0, watchScore - 12.0)
    bool replaceBearSeed = pendingDir != -1 or na(pendingExtreme) or high > pendingExtreme or (not na(pendingBar) and bar_index - pendingBar > confirmationWindowBars)
    if replaceBearSeed
        pendingDir := -1
        pendingBar := bar_index
        pendingRef := upperRef
        pendingExtreme := high
        pendingOpposite := lowerRef
        pendingSeedScore := bearSeedScore
        pendingWickScore := bearWickScore
        pendingPenScore := bearPenScore
        pendingVolumeScore := f_norm_high(volumeRatio, 0.85, 1.70)
        seedEvent := true

int pendingAge = pendingDir != 0 and not na(pendingBar) ? bar_index - pendingBar : 9999
bool pendingValid = pendingDir != 0 and pendingAge <= confirmationWindowBars
float reclaimPad = atr * reclaimPadAtr
float bullReclaimDistance = pendingDir == 1 and not na(pendingRef) ? (close - pendingRef) / atr : 0.0
float bearReclaimDistance = pendingDir == -1 and not na(pendingRef) ? (pendingRef - close) / atr : 0.0
float closeBackScore = pendingDir == 1 ? f_norm_high(bullReclaimDistance, -0.04, 0.46) : pendingDir == -1 ? f_norm_high(bearReclaimDistance, -0.04, 0.46) : 0.0
float closeLocationScore = pendingDir == 1 ? f_norm_high(closeLocation, closeNeed - 0.12, 0.92) : pendingDir == -1 ? f_norm_high(1.0 - closeLocation, closeNeed - 0.12, 0.92) : 0.0
float bodyScore = f_norm_high(bodyShare, bodyNeed * 0.60, 0.72)
float followScore = pendingDir == 1 ? f_norm_high((close - high[1]) / atr, -0.20, 0.32) : pendingDir == -1 ? f_norm_high((low[1] - close) / atr, -0.20, 0.32) : 0.0
float directionalBodyScore = pendingDir == 1 ? (close > open ? 86.0 : 48.0) : pendingDir == -1 ? (close < open ? 86.0 : 48.0) : 0.0
float confirmationScore = f_clamp(bodyScore * 0.38 + followScore * 0.28 + directionalBodyScore * 0.22 + closeLocationScore * 0.12, 0.0, 100.0)
float reclaimQuality = f_clamp(closeBackScore * 0.46 + closeLocationScore * 0.34 + bodyScore * 0.20, 0.0, 100.0)
float targetLevel = pendingDir == 1 ? (pendingOpposite > close ? pendingOpposite : close + atr * targetAtrFallback) : pendingDir == -1 ? (pendingOpposite < close ? pendingOpposite : close - atr * targetAtrFallback) : na
float targetRoomAtr = pendingDir == 1 and not na(targetLevel) ? (targetLevel - close) / atr : pendingDir == -1 and not na(targetLevel) ? (close - targetLevel) / atr : 0.0
float targetRoomScore = f_norm_high(targetRoomAtr, 0.45, 2.35)
float trendTurnScore = pendingDir == 1 ? f_clamp((close > fastEma ? 48.0 : 28.0) + (fastEma > fastEma[1] ? 26.0 : 8.0) + (fastEma > slowEma ? 18.0 : 6.0), 0.0, 100.0) :
     pendingDir == -1 ? f_clamp((close < fastEma ? 48.0 : 28.0) + (fastEma < fastEma[1] ? 26.0 : 8.0) + (fastEma < slowEma ? 18.0 : 6.0), 0.0, 100.0) : 0.0
float sweepScore = f_clamp(nz(pendingWickScore) * 0.58 + nz(pendingPenScore) * 0.42, 0.0, 100.0)
float reversalScore = f_clamp(sweepScore * 0.22 + closeBackScore * 0.22 + confirmationScore * 0.22 + nz(pendingVolumeScore) * 0.12 + targetRoomScore * 0.14 + trendTurnScore * 0.08, 0.0, 100.0)

bool bullConfirmed = pendingValid and pendingDir == 1 and close >= pendingRef + reclaimPad and closeLocation >= closeNeed and bodyShare >= bodyNeed * 0.70
bool bearConfirmed = pendingValid and pendingDir == -1 and close <= pendingRef - reclaimPad and closeLocation <= 1.0 - closeNeed and bodyShare >= bodyNeed * 0.70
bool planReady = na(lastConfirmedBar) or bar_index - lastConfirmedBar >= planCooldownBars
bool newConfirmedEvent = confirmedBar and planReady and (bullConfirmed or bearConfirmed) and reversalScore >= minReadinessScore
float pendingInvalidation = pendingDir == 1 ? pendingExtreme - atr * invalidationBufferAtr : pendingDir == -1 ? pendingExtreme + atr * invalidationBufferAtr : na
bool pendingInvalidated = (confirmedBar and pendingValid and pendingDir == 1 and close < pendingInvalidation) or (confirmedBar and pendingValid and pendingDir == -1 and close > pendingInvalidation)
bool pendingExpired = pendingDir != 0 and pendingAge > confirmationWindowBars

bool canLabel = na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars
if showEventLabels and showWatchLabels and seedEvent and canLabel and pendingSeedScore >= watchScore and not newConfirmedEvent
    string seedSide = pendingDir == 1 ? "Bull Stop Run" : "Bear Stop Run"
    string seedText = labelTextMode == "Detailed" ? seedSide + "\nWait Confirm\n" + f_score_text(pendingSeedScore) : seedSide + "\nWait"
    float seedY = pendingDir == 1 ? low - atr * labelOffsetAtr : high + atr * labelOffsetAtr
    label seedLabel = label.new(bar_index, seedY, seedText, xloc = xloc.bar_index, style = pendingDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(f_side_color(pendingDir), 0), textcolor = headerText, size = f_text_size(labelFontSize))
    f_keep_label(labelStore, seedLabel, maxVisibleObjects * 2)
    lastLabelBar := bar_index

if newConfirmedEvent
    int eventDir = pendingDir
    color eventColor = f_side_color(eventDir)
    float invalidationLevel = pendingInvalidation
    float rawTop = math.max(pendingRef, pendingExtreme)
    float rawBottom = math.min(pendingRef, pendingExtreme)
    float zoneMid = (rawTop + rawBottom) * 0.5
    float zoneHalf = math.max((rawTop - rawBottom) * 0.5, atr * minZoneHeightAtr * 0.5)
    float zoneTop = zoneMid + zoneHalf
    float zoneBottom = zoneMid - zoneHalf
    float bandHalf = atr * targetBandAtr
    float targetTop = targetLevel + bandHalf
    float targetBottom = targetLevel - bandHalf
    int rightEdge = bar_index + forwardBars
    string gradeText = f_grade(reversalScore)
    string actionText = reversalScore >= 78.0 ? "Review Reversal" : "Plan Pullback"
    activeDir := eventDir
    activeUntil := rightEdge
    activeScore := reversalScore
    activeReclaimQuality := reclaimQuality
    activeInvalidation := invalidationLevel
    activeTarget := targetLevel
    activeReclaim := pendingRef
    activeAction := actionText
    activeState := eventDir == 1 ? "Bull Reversal" : "Bear Reversal"
    activeTargetHit := false
    activeOutcome := 0
    lastConfirmedBar := bar_index
    activeStopBadge := na
    activeTargetBadge := na
    if showStopRunZones
        box zoneBox = box.new(left = pendingBar, top = zoneTop, right = rightEdge, bottom = zoneBottom, xloc = xloc.bar_index, bgcolor = color.new(eventColor, zoneTransparency), border_color = color.new(eventColor, 18), border_width = 1)
        f_keep_box(boxStore, zoneBox, maxVisibleObjects * 2)
        string stopBadgeText = (eventDir == 1 ? "BULL" : "BEAR") + " STOP RUN\nQ" + f_score_text(reversalScore) + " | CONFIRMED"
        activeStopBadge := f_zone_badge(stopBadgeText, pendingBar, rightEdge, zoneTop, zoneBottom, eventColor, zoneLabelStore, maxVisibleObjects * 3, labelFontSize)
    if showTargetBands and not na(targetLevel)
        box targetBox = box.new(left = bar_index, top = targetTop, right = rightEdge, bottom = targetBottom, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 93), border_color = color.new(accentColor, 45), border_width = 1)
        f_keep_box(boxStore, targetBox, maxVisibleObjects * 2)
        activeTargetBadge := f_zone_badge("TARGET BAND\n" + f_fmt_price(targetLevel), bar_index, rightEdge, targetTop, targetBottom, accentColor, zoneLabelStore, maxVisibleObjects * 3, labelFontSize)
    if showGuideRails
        line reclaimLine = line.new(pendingBar, pendingRef, rightEdge, pendingRef, xloc = xloc.bar_index, color = color.new(eventColor, 0), style = line.style_dashed, width = 2)
        line invalidLine = line.new(pendingBar, invalidationLevel, rightEdge, invalidationLevel, xloc = xloc.bar_index, color = color.new(dangerColor, 0), style = line.style_dotted, width = 1)
        line targetLine = line.new(bar_index, targetLevel, rightEdge, targetLevel, xloc = xloc.bar_index, color = color.new(accentColor, 0), style = line.style_solid, width = 1)
        f_keep_line(lineStore, reclaimLine, maxVisibleObjects * 3)
        f_keep_line(lineStore, invalidLine, maxVisibleObjects * 3)
        f_keep_line(lineStore, targetLine, maxVisibleObjects * 3)
        label invalidBadge = label.new(rightEdge, invalidationLevel, "INVALID " + f_fmt_price(invalidationLevel), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(dangerColor, 0), textcolor = headerText, size = f_text_size(labelFontSize))
        f_keep_label(zoneLabelStore, invalidBadge, maxVisibleObjects * 3)
    if showEventLabels and not showStopRunZones
        string confirmSide = eventDir == 1 ? "Bull Confirm" : "Bear Confirm"
        string confirmText = labelTextMode == "Detailed" ? confirmSide + "\n" + f_score_text(reversalScore) + " " + gradeText + "\n" + actionText : confirmSide + "\n" + str.tostring(math.round(reversalScore))
        float confirmY = eventDir == 1 ? low - atr * labelOffsetAtr : high + atr * labelOffsetAtr
        label confirmLabel = label.new(bar_index, confirmY, confirmText, xloc = xloc.bar_index, style = eventDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(eventColor, 0), textcolor = headerText, size = f_text_size(labelFontSize))
        f_keep_label(labelStore, confirmLabel, maxVisibleObjects * 2)
        lastLabelBar := bar_index
    pendingDir := 0
    pendingBar := na
    pendingRef := na
    pendingExtreme := na
    pendingOpposite := na
    pendingSeedScore := na
    pendingWickScore := na
    pendingPenScore := na
    pendingVolumeScore := na

bool activeValid = activeDir != 0 and not na(activeUntil) and bar_index <= activeUntil
bool activeInvalidated = activeOutcome == 0 and ((confirmedBar and activeValid and activeDir == 1 and close < activeInvalidation) or (confirmedBar and activeValid and activeDir == -1 and close > activeInvalidation))
bool targetTouched = activeOutcome == 0 and not activeTargetHit and ((confirmedBar and activeValid and activeDir == 1 and high >= activeTarget) or (confirmedBar and activeValid and activeDir == -1 and low <= activeTarget))

if showEventLabels and showResetLabels and pendingInvalidated and canLabel
    label invalidPendingLabel = label.new(bar_index, pendingDir == 1 ? low - atr * labelOffsetAtr : high + atr * labelOffsetAtr, "Reset", xloc = xloc.bar_index, style = pendingDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(dangerColor, 0), textcolor = headerText, size = f_text_size(labelFontSize))
    f_keep_label(labelStore, invalidPendingLabel, maxVisibleObjects * 2)
    lastLabelBar := bar_index

if pendingInvalidated or pendingExpired
    pendingDir := 0
    pendingBar := na
    pendingRef := na
    pendingExtreme := na
    pendingOpposite := na
    pendingSeedScore := na
    pendingWickScore := na
    pendingPenScore := na
    pendingVolumeScore := na

if activeInvalidated
    activeOutcome := 2
    if not na(activeStopBadge)
        label.set_text(activeStopBadge, (activeDir == 1 ? "BULL" : "BEAR") + " STOP RUN\nQ" + f_score_text(activeScore) + " | INVALIDATED")
        label.set_color(activeStopBadge, dangerColor)
    if showEventLabels and not showStopRunZones
        label activeInvalidLabel = label.new(bar_index, activeDir == 1 ? low - atr * labelOffsetAtr : high + atr * labelOffsetAtr, "Invalidated", xloc = xloc.bar_index, style = activeDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(dangerColor, 0), textcolor = headerText, size = f_text_size(labelFontSize))
        f_keep_label(labelStore, activeInvalidLabel, maxVisibleObjects * 2)
    activeAction := "Invalidated"
    activeState := "Invalidated"

if targetTouched and not activeInvalidated
    activeOutcome := 1
    if not na(activeTargetBadge)
        label.set_text(activeTargetBadge, "TARGET REVIEW\n" + f_fmt_price(activeTarget))
        label.set_color(activeTargetBadge, f_side_color(activeDir))
    if showEventLabels and not showTargetBands
        label targetLabel = label.new(bar_index, activeDir == 1 ? high + atr * labelOffsetAtr : low - atr * labelOffsetAtr, "Target\nReview", xloc = xloc.bar_index, style = activeDir == 1 ? label.style_label_down : label.style_label_up, color = color.new(accentColor, 0), textcolor = headerText, size = f_text_size(labelFontSize))
        f_keep_label(labelStore, targetLabel, maxVisibleObjects * 2)
    activeAction := "Target Review"
    activeState := activeDir == 1 ? "Bull Target Review" : "Bear Target Review"
    activeTargetHit := true

// -------------------------------------------------
// Panel
// -------------------------------------------------
string panelStopRun = activeValid ? activeState + " " + f_score_text(activeScore) : pendingDir != 0 ? (pendingDir == 1 ? "Bull Watch " : "Bear Watch ") + f_score_text(pendingSeedScore) : pendingInvalidated ? "Invalidated" : "No Setup"
string panelConfirmation = activeValid ? "Confirmed / " + f_grade(activeScore) : pendingDir != 0 ? "Waiting " + str.tostring(math.max(confirmationWindowBars - pendingAge, 0)) + " bars" : pendingInvalidated ? "Failed" : "None"
string panelReclaimQuality = activeValid ? f_score_text(activeReclaimQuality) : pendingDir != 0 ? f_score_text(reclaimQuality) : "-"
string panelInvalidation = activeValid ? f_fmt_price(activeInvalidation) + " / T " + f_fmt_price(activeTarget) : pendingDir != 0 ? f_fmt_price(pendingInvalidation) + " / T after confirm" : "-"
string panelAction = activeValid ? activeAction : pendingDir != 0 ? "Wait Confirm" : pendingInvalidated ? "Reset Context" : "Stand Aside"
color panelStateColor = activeValid ? f_side_color(activeDir) : pendingDir != 0 ? f_score_color(pendingSeedScore) : pendingInvalidated ? dangerColor : panelValueCol

var table panel = table.new(f_panel_pos(panelLocation), 2, 6, bgcolor = f_panel_bg(panelTheme), frame_color = f_panel_border(panelTheme), frame_width = 1, border_color = f_panel_border(panelTheme), border_width = 1)

if barstate.islast
    table.clear(panel, 0, 0, 1, 5)
    if showPanel
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Stop Run Reversal Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        f_panel_row(panel, 1, "Stop Run", panelStopRun, panelStateColor, panelTheme, panelFontSize)
        f_panel_row(panel, 2, "Confirmation", panelConfirmation, activeValid ? f_side_color(activeDir) : pendingDir != 0 ? neutralColor : f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_panel_row(panel, 3, "Reclaim Quality", panelReclaimQuality, activeValid ? f_score_color(activeReclaimQuality) : f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_panel_row(panel, 4, "Invalidation", panelInvalidation, (activeValid or pendingDir != 0) ? dangerColor : f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_panel_row(panel, 5, "Action", panelAction, panelStateColor, panelTheme, panelFontSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(seedEvent and pendingDir == 1 and pendingSeedScore >= watchScore, title = "Bull Stop Run Watch", message = "Stop Run Reversal Planner: downside stop-run watch context detected. This is an attention marker, not a trade instruction.")
alertcondition(seedEvent and pendingDir == -1 and pendingSeedScore >= watchScore, title = "Bear Stop Run Watch", message = "Stop Run Reversal Planner: upside stop-run watch context detected. This is an attention marker, not a trade instruction.")
alertcondition(newConfirmedEvent and activeDir == 1, title = "Bull Reversal Confirmed", message = "Stop Run Reversal Planner: bullish stop-run reversal confirmation is active. Review context, risk, and target room.")
alertcondition(newConfirmedEvent and activeDir == -1, title = "Bear Reversal Confirmed", message = "Stop Run Reversal Planner: bearish stop-run reversal confirmation is active. Review context, risk, and target room.")
alertcondition(pendingInvalidated or activeInvalidated, title = "Reversal Invalidation", message = "Stop Run Reversal Planner: the active stop-run reversal context crossed its invalidation guide.")
alertcondition(targetTouched, title = "Target Band Review", message = "Stop Run Reversal Planner: price reached the active reversal target band. Review context; this is not an exit instruction.")
````
