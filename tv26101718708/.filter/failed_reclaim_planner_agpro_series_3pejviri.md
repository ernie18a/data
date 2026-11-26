# Failed Reclaim Planner [AGPro Series]

- url: https://www.tradingview.com/script/3PeJvIRI-Failed-Reclaim-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;d5dfeac97af048b4b1656fd0981d7e5e
- version: 5.0

## Description

Failed Reclaim Planner [AGPro Series]

🧠 Core Idea

Did price lose a visible swing shelf, retest it, and fail to reclaim that level with enough rejection quality, risk clarity, and continuation room to matter?


📌 Overview / What it does

Failed Reclaim Planner [AGPro Series] is a chart-first failed reclaim decision engine built around visible swing shelves.

The script identifies when price breaks a confirmed swing high or swing low shelf, watches the retest of that broken level, and evaluates whether the reclaim attempt fails with enough rejection quality to become meaningful context.

It produces visible shelf zones, failed reclaim pockets, BULL / BEAR quality labels, planning room bands, risk / target guides, and a compact AGPro panel with a 0-100 failure score, rejection quality, room, and next-action state.

This script does not predict price direction or automate execution. It is designed to organize reclaim-failure context so traders can review structure, risk, and room more clearly.


🎯 Purpose & Design Philosophy

The script was built for traders who want more than another signal marker.

Most reclaim tools show whether price crossed a level. Failed Reclaim Planner focuses on the decision process after a visible shelf breaks: was the retest valid, did the reclaim fail, how strong was the rejection, where is invalidation, and is there enough room for the idea to matter?

The design supports a planning mindset: identify the broken shelf, wait for the retest, evaluate the failed reclaim, check room, and then decide whether the context deserves attention.


⚡ Why This Script Is Different

Most tools focus on fixed references such as VWAP, moving averages, prior-day levels, or broad support/resistance zones.

This script does NOT act as a generic S/R scanner, VWAP reclaim indicator, EMA reclaim map, previous-day sweep tool, or liquidity sweep engine.

Instead, it focuses on one narrow workflow: failed reclaim planning after a visible swing shelf breaks. The reference level is visible on the chart, the failure pocket is mapped, the rejection is scored, and the panel summarizes the next action.


⚙️ Methodology

1. Swing Shelf Detection
The script confirms visible swing highs and swing lows using left/right pivot structure.

2. Shelf Break Activation
When price closes beyond a confirmed shelf with enough ATR-adjusted separation, that shelf becomes an active reclaim reference.

3. Retest and Failure Evaluation
During the retest window, the script checks whether price returns into the shelf area and then rejects the reclaim. The failure score evaluates retest depth, close rejection, wick quality, volume participation, follow-through, and continuation room.

4. Planning Output
Qualified events create a scored BULL / BEAR label, a failed reclaim pocket, planning room band, invalidation guide, target-room guide, and panel state.


🗺️ How to Read the Chart

Shelf Zones = visible broken swing shelves that price may attempt to reclaim.

Failure Pockets = highlighted reclaim-failure areas where the retest rejected the broken shelf.

Planning Room Bands = projected continuation room after a qualified failed reclaim. These are planning references, not targets or promises.

Score Labels = compact BULL / BEAR labels showing the failure quality score.

Risk / Target Guides = dashed and dotted reference lines that help locate invalidation and continuation room.

Panel = the decision layer showing Reclaim State, Failure Score, Rejection Quality, Room, and Action.


🚦 Signals & States

• UP SHELF → a visible swing high was broken and is now monitored as a reclaim shelf.

• DN SHELF → a visible swing low was broken and is now monitored as a reclaim shelf.

• Bear Failure Active → bearish failed reclaim context is active after a broken shelf retest.

• Bull Failure Active → bullish failed reclaim context is active after a broken shelf retest.

• Failure Score → 0-100 quality score for the reclaim failure.

• Rejection Quality → how cleanly price rejected the reclaim attempt.

• Room → ATR-based continuation space available from the failure context.

• Action → the current planning state shown in plain language.


🔔 Alerts Logic

Alerts are available for:

• Bearish Failed Reclaim
• Bullish Failed Reclaim
• New Broken Shelf
• Shelf Recovered

Alerts are attention markers. They are not trade instructions, automation signals, or guaranteed outcomes.


🧩 Confluence Logic

The context becomes stronger when several conditions align:

• A visible swing shelf has already broken
• Price retests the broken shelf
• The reclaim attempt fails with wick and close rejection
• Participation is not weak
• There is still continuation room beyond the failed reclaim

When these elements align, the script treats the event as a stronger planning context.


📊 When to Use

• After clear swing highs or swing lows have broken

• During retests of broken structure

• In trending or transitioning markets where reclaim failure can matter

• When you want risk, invalidation, and room mapped visually

• When you prefer decision support over raw signal spam


⚠️ When NOT to Use

• Very low-liquidity charts

• Extremely noisy sideways chop

• News-driven spikes where ATR behavior becomes distorted

• Markets with poor swing structure

• Situations where you specifically need VWAP, session, or moving-average reclaim logic


🎛️ Key Inputs

• Sensitivity → adjusts how quickly the script reacts to shelf breaks and failures.

• Swing Left Bars / Swing Right Bars → define how visible swing shelves are confirmed.

• Retest Window Bars → controls how long a broken shelf remains active for reclaim evaluation.

• Minimum Failure Score → sets the quality threshold for confirmed failed reclaim events.

• Shelf Buffer ATR → controls the thickness of the reclaim shelf zone.

• Target Room ATR Multiple → controls fallback room projection when nearby structure is limited.

• Show Planning Room Band → displays the continuation room corridor after qualified failed reclaim events.

• Visual Memory Bars → controls how long historical zones, labels, and guide objects remain visible.

• Panel / Label Settings → control panel location, theme, visibility, and font size.


🖥️ Interface & Visual Design

The interface is designed to look like a planning tool, not a crowded signal overlay.

The chart carries the core story: shelf break, retest, failed reclaim pocket, score label, planning room, and risk / target references.

The panel uses the AGPro public-release standard: one merged blue header row containing only the script name. The rest of the panel summarizes the current decision state without covering the chart.


🧪 Practical Usage Workflow

1. Read the panel state.

2. Check whether a visible shelf is active or already failed.

3. Review the failed reclaim pocket and BULL / BEAR score label.

4. Compare the rejection quality with the planning room band.

5. Use risk / target guides as context references.

6. Interpret the output within broader market structure.


🔍 Interpretation Guidelines

A higher Failure Score means the reclaim failure is cleaner under the script's rules. It does not guarantee continuation.

Rejection Quality helps distinguish weak shelf touches from stronger failed reclaim behavior.

Room shows whether there is enough practical continuation space for the context to matter.

The Action row is the main planning summary. It is designed to guide review, not replace trader judgment.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not auto trading

• Not guaranteed signals

• Not a VWAP reclaim tool

• Not an EMA reclaim map

• Not a previous-day sweep reclaim script

• Not a generic support/resistance scanner


⚠️ Limitations & Transparency

Different timeframes can produce different shelves because swing structure changes with timeframe.

Volatility changes can affect shelf width, label spacing, and room projections.

Low-volume conditions may weaken the reliability of wick and participation components.

Sideways markets may create repeated shelf tests that require extra discretion.


🧠 Market Context Notes

Failed reclaim behavior often becomes important when price loses a visible structural shelf and cannot regain that area on the retest.

This is different from a successful reclaim, liquidity sweep, VWAP reclaim, or moving-average retest. The script is intentionally narrow so the chart remains focused on one decision workflow.


🧾 Use Case Examples

Example 1:
Price breaks below a confirmed swing low, retests that shelf from underneath, leaves rejection, and fails to reclaim. A BEAR score label appears with a failure pocket and planning room.

Example 2:
Price breaks above a confirmed swing high, retests the broken shelf, holds above it, and rejects back upward. A BULL score label appears with risk and room context.


🧱 System Philosophy

Failed Reclaim Planner follows the AGPro decision-engine approach:

Do not just show another signal.

Show the reference.
Score the failure.
Map the risk.
Map the room.
Summarize the next action.


🔐 Non-Promise Statement

No script provides certainty.

No failed reclaim guarantees continuation.

Outputs should be interpreted as structured analytical context, not as a promise of future price behavior.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions, position sizing, execution, and risk management.

This script does not provide financial advice, investment advice, or guaranteed trading outcomes.


📚 Educational Note

Use this script to study how broken swing shelves behave when price attempts to reclaim them. The strongest value comes from comparing the shelf zone, failure pocket, score label, planning room, and panel state with broader market structure and your own rules.

## Source Code

````pine
// -------------------------------------------------
// Failed Reclaim Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.9
//
// Failed Reclaim Planner is a chart-first reclaim failure engine built around
// visible swing shelves. It tracks when price loses a clear swing level,
// returns to retest that shelf, and then rejects the reclaim with a scored
// failure context, risk level, target room, owned guide tags, and a selective
// duplicate-label-safe publication visual preset. Version 2.7 adds a confirmation-
// anchored proof layer (Follow, Hold, React, Flip rates) that shows how often
// confirmed failed reclaims continued away from the shelf before it was reclaimed.
// -------------------------------------------------

//@version=6
indicator("Failed Reclaim Planner [AGPro Series]",
     shorttitle = "AG Pro FRP",
     overlay = true,
     max_labels_count = 180,
     max_boxes_count = 120,
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
// Inputs
// -------------------------------------------------
string groupCore = "Shelf Failure Engine"
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Aggressive", "Balanced", "Conservative"], group = groupCore,
     tooltip = "Controls how quickly the script treats a broken swing shelf as active. Aggressive reacts earlier, while Conservative requires a cleaner shelf break.")
int swingLeftBars = input.int(3, "Swing Left Bars", minval = 1, maxval = 12, group = groupCore,
     tooltip = "Left-side bars used to confirm visible swing highs and swing lows. Lower values create more frequent shelf references.")
int swingRightBars = input.int(3, "Swing Right Bars", minval = 1, maxval = 12, group = groupCore,
     tooltip = "Right-side confirmation bars for swing shelves. Lower values react faster but can be noisier.")
int atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupCore,
     tooltip = "ATR length used for shelf buffers, label spacing, risk distance, and score normalization.")
int retestWindowBars = input.int(24, "Retest Window Bars", minval = 6, maxval = 140, group = groupCore,
     tooltip = "Number of bars after a shelf break where reclaim failure remains actively evaluated. Older shelf breaks expire to prevent stale context.")
string confirmationMode = input.string("Balanced", "Confirmation Mode", options = ["Fast", "Balanced", "Strict"], group = groupCore,
     tooltip = "Controls how cleanly price must reject the broken shelf to qualify as a failed reclaim.")
int volumeLength = input.int(24, "Volume Baseline Length", minval = 5, maxval = 160, group = groupCore,
     tooltip = "Volume baseline used to judge whether the reclaim rejection has enough participation.")
int minFailureScore = input.int(68, "Minimum Failure Score", minval = 35, maxval = 95, group = groupCore,
     tooltip = "Minimum 0-100 score required before a reclaim failure is treated as a qualified event.")
int cooldownBars = input.int(12, "Visual Cooldown Bars", minval = 3, maxval = 120, group = groupCore,
     tooltip = "Minimum bars between repeated same-side event labels so the chart stays premium and readable.")
int maxVisibleObjects = input.int(3, "Max Visible Event Sets", minval = 1, maxval = 24, group = groupCore,
     tooltip = "Caps visible shelf zones, failure labels, and guide objects so the chart does not become crowded.")
bool confirmOnClose = input.bool(true, "Confirm On Bar Close", group = groupCore,
     tooltip = "When enabled, shelf breaks and failed reclaims are confirmed only after the bar closes for stable public chart behavior.")

string groupRisk = "Risk / Target Logic"
float shelfBufferAtr = input.float(0.22, "Shelf Buffer ATR", minval = 0.04, maxval = 1.20, step = 0.02, group = groupRisk,
     tooltip = "ATR-based half-width around the broken swing shelf used to draw the reclaim zone and invalidation edge.")
float targetRoomAtr = input.float(1.60, "Target Room ATR Multiple", minval = 0.50, maxval = 6.00, step = 0.05, group = groupRisk,
     tooltip = "Fallback target-room projection when nearby structure does not provide enough clean room.")
int roomLookback = input.int(55, "Room Reference Lookback", minval = 10, maxval = 240, group = groupRisk,
     tooltip = "Lookback used to estimate continuation room after a reclaim failure. It is a planning reference, not a price promise.")
bool showGuides = input.bool(true, "Show Active Risk / Target Guides", group = groupRisk,
     tooltip = "Shows the active invalidation line and continuation target guide after a qualified reclaim failure.")
bool showGuideTags = input.bool(true, "Show Guide Tags", group = groupRisk,
     tooltip = "Shows compact right-side tags for risk and target guide levels so each projected line has a visible owner.")
int guideTagOffsetBars = input.int(4, "Guide Tag Offset Bars", minval = 1, maxval = 30, group = groupRisk,
     tooltip = "Bars between the guide-line endpoint and its right-side level tag.")

string groupVisual = "Visual Settings"
bool showZones = input.bool(true, "Show Shelf Zones", group = groupVisual,
     tooltip = "Draws visible broken-shelf reclaim zones so the reference level is obvious on-chart.")
bool showPlanBand = input.bool(true, "Show Planning Room Band", group = groupVisual,
     tooltip = "Draws the projected continuation room corridor after a qualified reclaim failure so the chart carries a clearer planning footprint by default.")
string visualMemoryMode = input.string("Latest Event", "Visual Memory Mode", options = ["Latest Event", "Recent History"], group = groupVisual,
     tooltip = "Latest Event keeps only the current reclaim-failure visual set. Recent History preserves older event sets up to the memory and object limits.")
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupVisual,
     tooltip = "Shows scored Bull / Bear failure labels for qualified reclaim failures.")
bool showFailureZoneBadges = input.bool(false, "Show Failure Zone Badges", group = groupVisual,
     tooltip = "Shows a centered Bull Fail or Bear Fail badge inside the confirmation zone. Disabled by default because the scored event label already names the failure.")
bool showShelfLabels = input.bool(true, "Show Shelf Labels", group = groupVisual,
     tooltip = "Shows compact Up Shelf and Dn Shelf labels when a visible swing shelf breaks. Disabled by default for cleaner publication screenshots.")
bool showWatchLabels = input.bool(false, "Show Optional Watch Labels", group = groupVisual,
     tooltip = "Adds sparse Reclaim Watch labels while price retests an active shelf. Disabled by default for a cleaner publication preset.")
string labelMode = input.string("Compact", "Label Detail", options = ["Compact", "Balanced", "Detailed"], group = groupVisual,
     tooltip = "Controls how much text appears in failure labels. Compact is the default publication preset.")
float labelOffsetAtr = input.float(0.78, "Label Offset ATR", minval = 0.20, maxval = 3.00, step = 0.05, group = groupVisual,
     tooltip = "ATR-based offset that keeps labels above or below candles instead of buried inside them.")
string labelFontSize = input.string("Large", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual,
     tooltip = "Controls all chart label sizes, including shelf labels. Large is the default public-release setting for the sparse Latest Event layout.")
int visualMemoryBars = input.int(80, "Visual Memory Bars", minval = 24, maxval = 520, group = groupVisual,
     tooltip = "Limits how long historical labels, shelf zones, and guide objects remain visible.")

string groupPanel = "Panel Settings"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel,
     tooltip = "Shows or hides the AG Pro decision panel. The default is visible for publication-ready context.")
int panelMemoryBars = input.int(160, "Panel Memory Bars", minval = 20, maxval = 520, group = groupPanel,
     tooltip = "Controls how long the panel keeps the latest confirmed failure context before returning to standby.")
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel,
     tooltip = "Moves the AG Pro summary panel to the preferred chart location.")
string panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel,
     tooltip = "Switches the panel between the premium AGPro dark theme and a light chart-friendly theme while preserving the merged blue header row.")
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel,
     tooltip = "Controls panel text size. Normal is the default AGPro publication setting.")

string groupProof = "Proof"
bool showProof = input.bool(true, "Show Proof Layer", group = groupProof,
     tooltip = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across confirmed failed reclaims on the current symbol and timeframe. Follow means continuation advanced one risk unit (1R) away from the shelf, or reached a nearer target, before the shelf was reclaimed. These are historical outcome rates, not predictions.")
int proofHorizonBars = input.int(30, "Proof Horizon Bars", minval = 5, maxval = 240, group = groupProof,
     tooltip = "Maximum number of bars each confirmed failed reclaim is tracked for the proof measurement before it resolves at its current outcome.")
int reactBars = input.int(4, "Reaction Window Bars", minval = 1, maxval = 60, group = groupProof,
     tooltip = "Number of bars after a failed reclaim is confirmed used to detect an immediate favorable continuation reaction.")
float reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = groupProof,
     tooltip = "Minimum favorable continuation progress toward the target, within the reaction window, required to count as an early React.")

string groupAlerts = "Alerts"
int alertScore = input.int(72, "Minimum Alert Score", minval = 40, maxval = 95, group = groupAlerts,
     tooltip = "Minimum Failure Score required for reclaim-failure alerts. Alerts are attention markers, not trade instructions.")

// -------------------------------------------------
// Utility functions
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_size(string selected) =>
    switch selected
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_pos(string selected) =>
    switch selected
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_score_text(float value) =>
    na(value) ? "-" : str.tostring(math.round(f_clamp(value, 0.0, 100.0))) + "/100"

f_room_text(float value) =>
    na(value) ? "-" : str.tostring(value, "#.#") + " ATR"

f_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(float value) =>
    value >= 55 ? bullColor : value >= 40 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30 ? bullColor : value <= 55 ? neutralColor : bearColor

f_tier(float score) =>
    score >= 84 ? "A+" : score >= 76 ? "A" : score >= 66 ? "B" : score >= 55 ? "C" : "D"

f_score_color(float score) =>
    color result = dangerColor
    if score >= 76
        result := bullColor
    else if score >= minFailureScore
        result := neutralColor
    else if score >= 50
        result := accentColor
    result

f_panel_row(table panel, int row, string labelText, string valueText, color valueColor, color rowBg, color labelColor, string textSize) =>
    table.cell(panel, 0, row, labelText, text_color = labelColor, bgcolor = rowBg, text_size = f_size(textSize), text_halign = text.align_left)
    table.cell(panel, 1, row, valueText, text_color = valueColor, bgcolor = rowBg, text_size = f_size(textSize), text_halign = text.align_right)

f_keep_box(box[] items, box id, int maxCount) =>
    array.push(items, id)
    while array.size(items) > maxCount
        box old = array.shift(items)
        box.delete(old)

f_keep_line(line[] items, line id, int maxCount) =>
    array.push(items, id)
    while array.size(items) > maxCount
        line old = array.shift(items)
        line.delete(old)

f_keep_label(label[] items, label id, int maxCount) =>
    array.push(items, id)
    while array.size(items) > maxCount
        label old = array.shift(items)
        label.delete(old)

f_clear_boxes(box[] items) =>
    while array.size(items) > 0
        box old = array.pop(items)
        box.delete(old)

f_clear_lines(line[] items) =>
    while array.size(items) > 0
        line old = array.pop(items)
        line.delete(old)

f_clear_labels(label[] items) =>
    while array.size(items) > 0
        label old = array.pop(items)
        label.delete(old)

f_badge_set(label id, int xValue, float yValue, string textValue, color bgColor, color textColorValue, string sizeText, string styleValue) =>
    label result = id
    if na(result)
        result := label.new(xValue, yValue, textValue,
             xloc = xloc.bar_index,
             style = styleValue,
             color = color.new(bgColor, 0),
             textcolor = textColorValue,
             size = f_size(sizeText),
             textalign = text.align_center)
    else
        label.set_x(result, xValue)
        label.set_y(result, yValue)
        label.set_text(result, textValue)
        label.set_color(result, color.new(bgColor, 0))
        label.set_textcolor(result, textColorValue)
        label.set_size(result, f_size(sizeText))
        label.set_style(result, styleValue)
    result

f_prune_boxes(box[] items, int maxAgeBars) =>
    int idx = array.size(items) - 1
    while idx >= 0
        box item = array.get(items, idx)
        int left = box.get_left(item)
        if not na(left) and bar_index - left > maxAgeBars
            box.delete(item)
            array.remove(items, idx)
        idx -= 1

f_prune_lines(line[] items, int maxAgeBars) =>
    int idx = array.size(items) - 1
    while idx >= 0
        line item = array.get(items, idx)
        int x1 = line.get_x1(item)
        if not na(x1) and bar_index - x1 > maxAgeBars
            line.delete(item)
            array.remove(items, idx)
        idx -= 1

f_prune_labels(label[] items, int maxAgeBars) =>
    int idx = array.size(items) - 1
    while idx >= 0
        label item = array.get(items, idx)
        int x = label.get_x(item)
        if not na(x) and bar_index - x > maxAgeBars
            label.delete(item)
            array.remove(items, idx)
        idx -= 1

// -------------------------------------------------
// Core calculations
// -------------------------------------------------
bool confirmedBar = not confirmOnClose or barstate.isconfirmed
float atrRaw = ta.atr(atrLength)
float atr = math.max(nz(atrRaw, high - low), syminfo.mintick)

float pivotLow = ta.pivotlow(low, swingLeftBars, swingRightBars)
float pivotHigh = ta.pivothigh(high, swingLeftBars, swingRightBars)

var float lastSwingLow = na
var int lastSwingLowBar = na
var float lastSwingHigh = na
var int lastSwingHighBar = na

if not na(pivotLow)
    lastSwingLow := pivotLow
    lastSwingLowBar := bar_index - swingRightBars

if not na(pivotHigh)
    lastSwingHigh := pivotHigh
    lastSwingHighBar := bar_index - swingRightBars

float candleRange = math.max(high - low, syminfo.mintick)
float body = math.abs(close - open)
float bodyShare = body / candleRange
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float upperWickShare = upperWick / candleRange
float lowerWickShare = lowerWick / candleRange
float closeLocation = (close - low) / candleRange

float volBaseRaw = ta.sma(volume, volumeLength)
float volBase = math.max(nz(volBaseRaw, volume), 1.0)
float volRatio = volume > 0 ? volume / volBase : 1.0
float volumeScore = f_clamp(45.0 + (volRatio - 1.0) * 42.0, 0.0, 100.0)

float breakPadMult = sensitivity == "Aggressive" ? 0.03 : sensitivity == "Conservative" ? 0.10 : 0.06
float wickMin = sensitivity == "Aggressive" ? 0.22 : sensitivity == "Conservative" ? 0.38 : 0.30
float breakPad = atr * breakPadMult
float shelfHalf = math.max(atr * shelfBufferAtr, syminfo.mintick)
float failPad = confirmationMode == "Fast" ? -0.02 * atr : confirmationMode == "Strict" ? 0.07 * atr : 0.02 * atr

var int activeDir = 0
var float shelfLevel = na
var int shelfBreakBar = na
var int shelfPivotBar = na
var string lastStatus = "Standby"
var int lastFailureBar = na
var int lastFailureDir = 0
var float lastFailureScore = na
var float lastRejectionQuality = na
var float lastRoomAtr = na
var string lastAction = "Wait for visible shelf"
var int lastWatchLabelBar = na
var int lastShelfLabelBar = na
var int lastEventVisualBar = na
var int lastEventVisualDir = 0
var float lastFailureShelf = na
var float lastFailureRisk = na
var float lastFailureTarget = na
var float lastFailureClose = na
var float lastFailureShelfHalf = na

int barsSinceShelf = activeDir != 0 and not na(shelfBreakBar) ? bar_index - shelfBreakBar : 0
bool shelfExpiredNow = activeDir != 0 and barsSinceShelf > retestWindowBars
bool shelfRecoveredNow = (activeDir == -1 and not na(shelfLevel) and close > shelfLevel + shelfHalf) or (activeDir == 1 and not na(shelfLevel) and close < shelfLevel - shelfHalf)

if confirmedBar and (shelfRecoveredNow or shelfExpiredNow)
    lastStatus := shelfRecoveredNow ? "Shelf Recovered" : "Window Expired"
    activeDir := 0
    shelfLevel := na
    shelfBreakBar := na
    shelfPivotBar := na

bool rawBearShelf = confirmedBar and not na(lastSwingLow) and not na(lastSwingLowBar) and bar_index > lastSwingLowBar and close < lastSwingLow - breakPad and closeLocation <= 0.48
bool rawBullShelf = confirmedBar and not na(lastSwingHigh) and not na(lastSwingHighBar) and bar_index > lastSwingHighBar and close > lastSwingHigh + breakPad and closeLocation >= 0.52
bool newBearShelf = rawBearShelf and activeDir != -1
bool newBullShelf = rawBullShelf and activeDir != 1
bool newShelfEvent = newBearShelf or newBullShelf

if newShelfEvent
    activeDir := newBearShelf ? -1 : 1
    shelfLevel := newBearShelf ? lastSwingLow : lastSwingHigh
    shelfBreakBar := bar_index
    shelfPivotBar := newBearShelf ? lastSwingLowBar : lastSwingHighBar
    lastStatus := newBearShelf ? "Bear Shelf Watch" : "Bull Shelf Watch"
    lastAction := "Wait for failed reclaim"

barsSinceShelf := activeDir != 0 and not na(shelfBreakBar) ? bar_index - shelfBreakBar : 0
bool shelfAlive = activeDir != 0 and not na(shelfLevel) and not na(shelfPivotBar) and barsSinceShelf > 0 and barsSinceShelf <= retestWindowBars

bool bearRetestTouch = shelfAlive and activeDir == -1 and high >= shelfLevel - shelfHalf
bool bullRetestTouch = shelfAlive and activeDir == 1 and low <= shelfLevel + shelfHalf
bool retestTouch = bearRetestTouch or bullRetestTouch

bool bearCloseReject = bearRetestTouch and close < shelfLevel - failPad and closeLocation <= 0.48
bool bullCloseReject = bullRetestTouch and close > shelfLevel + failPad and closeLocation >= 0.52
bool bearWickReject = bearRetestTouch and upperWickShare >= wickMin
bool bullWickReject = bullRetestTouch and lowerWickShare >= wickMin

float bearDepthScore = bearRetestTouch ? f_clamp((high - (shelfLevel - shelfHalf)) / math.max(shelfHalf * 2.0, syminfo.mintick) * 100.0, 0.0, 100.0) : 0.0
float bullDepthScore = bullRetestTouch ? f_clamp(((shelfLevel + shelfHalf) - low) / math.max(shelfHalf * 2.0, syminfo.mintick) * 100.0, 0.0, 100.0) : 0.0
float bearCloseScore = bearRetestTouch ? f_clamp(45.0 + ((shelfLevel - close) / atr) * 82.0 + (closeLocation <= 0.36 ? 12.0 : 0.0), 0.0, 100.0) : 0.0
float bullCloseScore = bullRetestTouch ? f_clamp(45.0 + ((close - shelfLevel) / atr) * 82.0 + (closeLocation >= 0.64 ? 12.0 : 0.0), 0.0, 100.0) : 0.0
float bearWickScore = f_clamp(upperWickShare * 180.0, 0.0, 100.0)
float bullWickScore = f_clamp(lowerWickShare * 180.0, 0.0, 100.0)
float bearFollowScore = f_clamp((1.0 - closeLocation) * 70.0 + bodyShare * 32.0 + (close < close[1] ? 12.0 : 0.0), 0.0, 100.0)
float bullFollowScore = f_clamp(closeLocation * 70.0 + bodyShare * 32.0 + (close > close[1] ? 12.0 : 0.0), 0.0, 100.0)

float bearishTarget = ta.lowest(low[1], roomLookback)
float bullishTarget = ta.highest(high[1], roomLookback)
float activeTarget = activeDir == -1 ? (bearishTarget < close ? bearishTarget : close - atr * targetRoomAtr) : activeDir == 1 ? (bullishTarget > close ? bullishTarget : close + atr * targetRoomAtr) : na
float activeRoomAtr = not na(activeTarget) ? math.abs(activeTarget - close) / atr : na
float roomScore = not na(activeRoomAtr) ? f_clamp(activeRoomAtr / targetRoomAtr * 100.0, 0.0, 100.0) : 0.0
float riskLevel = activeDir == -1 ? shelfLevel + shelfHalf : activeDir == 1 ? shelfLevel - shelfHalf : na

float candidateDepthScore = activeDir == -1 ? bearDepthScore : activeDir == 1 ? bullDepthScore : 0.0
float candidateCloseScore = activeDir == -1 ? bearCloseScore : activeDir == 1 ? bullCloseScore : 0.0
float candidateWickScore = activeDir == -1 ? bearWickScore : activeDir == 1 ? bullWickScore : 0.0
float candidateFollowScore = activeDir == -1 ? bearFollowScore : activeDir == 1 ? bullFollowScore : 0.0
float candidateFailureScore = f_clamp(candidateDepthScore * 0.18 + candidateCloseScore * 0.28 + candidateWickScore * 0.20 + volumeScore * 0.14 + roomScore * 0.10 + candidateFollowScore * 0.10, 0.0, 100.0)
float candidateRejectionQuality = f_clamp(candidateCloseScore * 0.40 + candidateWickScore * 0.35 + candidateDepthScore * 0.25, 0.0, 100.0)

bool bearFailedReclaim = confirmedBar and bearCloseReject and bearWickReject and candidateFailureScore >= minFailureScore
bool bullFailedReclaim = confirmedBar and bullCloseReject and bullWickReject and candidateFailureScore >= minFailureScore
bool failedReclaim = bearFailedReclaim or bullFailedReclaim
int eventDir = failedReclaim ? activeDir : 0

if failedReclaim
    lastFailureBar := bar_index
    lastFailureDir := eventDir
    lastFailureScore := candidateFailureScore
    lastRejectionQuality := candidateRejectionQuality
    lastRoomAtr := activeRoomAtr
    lastAction := candidateFailureScore >= 78 and activeRoomAtr >= targetRoomAtr * 0.65 ? "Failure Plan Active" : "Review Failure"
    lastStatus := eventDir == -1 ? "Bear Failure Active" : "Bull Failure Active"
    lastFailureShelf := shelfLevel
    lastFailureRisk := riskLevel
    lastFailureTarget := activeTarget
    lastFailureClose := close
    lastFailureShelfHalf := shelfHalf

// -------------------------------------------------
// Confirmation-anchored proof (failed reclaims, Follow = continued 1R away from shelf before reclaim)
// -------------------------------------------------
var int proofTotal = 0
var int proofFollow = 0
var int proofHold = 0
var int proofReact = 0
var int proofFlip = 0
var bool pEvalActive = false
var int pEvalDir = 0
var int pEvalStart = na
var float pEvalEntry = na
var float pEvalStop = na
var float pEvalTarget = na
var bool pReacted = false
var bool pFollowed = false
var bool pFlipped = false

int proofWarmup = roomLookback + atrLength + swingRightBars + 5
if confirmedBar and bar_index > proofWarmup
    if pEvalActive
        int heldBars = bar_index - pEvalStart
        float followDist = math.max(math.abs(pEvalTarget - pEvalEntry), syminfo.mintick)
        float favExc = pEvalDir * (close - pEvalEntry)
        if heldBars >= 1 and heldBars <= reactBars and favExc >= followDist * reactProgressPct / 100.0
            pReacted := true
        bool stopBreached = pEvalDir == 1 ? close < pEvalStop : close > pEvalStop
        bool hitTarget = heldBars >= 1 and favExc >= followDist
        if stopBreached
            pFlipped := true
        bool followNow = hitTarget and not pFlipped
        if followNow
            pFollowed := true
        bool naturalResolve = pFlipped or followNow or heldBars >= proofHorizonBars
        if naturalResolve or failedReclaim
            proofTotal := proofTotal + 1
            if pFollowed
                proofFollow := proofFollow + 1
            if not pFlipped
                proofHold := proofHold + 1
            if pReacted
                proofReact := proofReact + 1
            if pFlipped
                proofFlip := proofFlip + 1
            pEvalActive := false
    if failedReclaim and not pEvalActive and not na(riskLevel) and not na(activeTarget)
        pEvalActive := true
        pEvalDir := eventDir
        pEvalEntry := close
        pEvalStop := riskLevel
        float pStopDist = math.max(math.abs(close - riskLevel), syminfo.mintick)
        float pRoomDist = math.max(math.abs(activeTarget - close), syminfo.mintick)
        float pFollowDist = math.max(math.min(pStopDist, pRoomDist), syminfo.mintick)
        pEvalTarget := close + eventDir * pFollowDist
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false
        pFlipped := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

int effectivePanelMemoryBars = timeframe.isweekly ? math.min(panelMemoryBars, 40) : timeframe.isdaily ? math.min(panelMemoryBars, 120) : panelMemoryBars
int visualProjectionBars = timeframe.isweekly ? math.max(14, int(math.round(retestWindowBars * 0.80))) : timeframe.isdaily ? math.max(10, int(math.round(retestWindowBars * 0.65))) : math.max(8, int(math.round(retestWindowBars * 0.50)))
int zoneProjectionBars = timeframe.isweekly ? math.max(18, int(math.round(visualProjectionBars * 1.28))) : timeframe.isdaily ? math.max(14, int(math.round(visualProjectionBars * 1.22))) : math.max(10, int(math.round(visualProjectionBars * 1.16)))
int eventZoneProjectionBars = math.max(8, int(math.round(zoneProjectionBars * 0.62)))
int effectiveZoneMemoryBars = timeframe.isweekly ? math.min(visualMemoryBars, 96) : timeframe.isdaily ? math.min(visualMemoryBars, 156) : visualMemoryBars
int effectiveGuideMemoryBars = timeframe.isweekly ? math.min(visualMemoryBars, 88) : timeframe.isdaily ? math.min(visualMemoryBars, 144) : visualMemoryBars
int effectiveEventMemoryBars = timeframe.isweekly ? math.min(visualMemoryBars, 76) : timeframe.isdaily ? math.min(visualMemoryBars, 136) : visualMemoryBars
int effectiveZoneObjectCap = timeframe.isweekly ? math.min(maxVisibleObjects + 2, 8) : timeframe.isdaily ? math.min(maxVisibleObjects + 1, 8) : maxVisibleObjects
int effectiveGuideObjectCap = timeframe.isweekly ? math.min(maxVisibleObjects + 1, 7) : timeframe.isdaily ? math.min(maxVisibleObjects + 1, 8) : maxVisibleObjects
int effectiveEventObjectCap = timeframe.isweekly ? math.min(maxVisibleObjects, 6) : timeframe.isdaily ? math.min(maxVisibleObjects, 7) : maxVisibleObjects
int contextLabelCap = math.max(2, int(math.round(effectiveEventObjectCap * 0.60)))

bool recentFailure = not na(lastFailureBar) and bar_index - lastFailureBar <= effectivePanelMemoryBars
bool showCandidatePanel = shelfAlive and retestTouch
float displayScore = recentFailure ? lastFailureScore : showCandidatePanel ? candidateFailureScore : na
float displayRejection = recentFailure ? lastRejectionQuality : showCandidatePanel ? candidateRejectionQuality : na
float displayRoom = recentFailure ? lastRoomAtr : shelfAlive ? activeRoomAtr : na
string displayState = recentFailure ? (lastFailureDir == -1 ? "Bear Failure Active" : "Bull Failure Active") : shelfAlive ? (activeDir == -1 ? "Bear Shelf Watch" : "Bull Shelf Watch") : lastStatus
string displayAction = recentFailure ? lastAction : shelfAlive ? "Wait for failed reclaim" : lastStatus == "Window Expired" ? "Wait for visible shelf" : "Wait for visible shelf"
color displayColor = recentFailure ? f_score_color(nz(lastFailureScore, 0.0)) : shelfAlive ? neutralColor : panelValueCol

// -------------------------------------------------
// Visual rendering
// -------------------------------------------------
var box[] zoneBoxes = array.new_box()
var box[] roomBoxes = array.new_box()
var line[] guideLines = array.new_line()
var label[] guideLabels = array.new_label()
var label[] eventLabels = array.new_label()
var label[] contextLabels = array.new_label()

f_prune_boxes(zoneBoxes, effectiveZoneMemoryBars)
f_prune_boxes(roomBoxes, effectiveZoneMemoryBars)
f_prune_lines(guideLines, effectiveGuideMemoryBars)
f_prune_labels(guideLabels, effectiveGuideMemoryBars)
f_prune_labels(eventLabels, effectiveEventMemoryBars)
f_prune_labels(contextLabels, effectiveEventMemoryBars)

bool latestVisualMode = visualMemoryMode == "Latest Event"

if newShelfEvent and showZones and not na(shelfLevel) and not na(shelfPivotBar)
    if latestVisualMode
        f_clear_boxes(zoneBoxes)
        f_clear_boxes(roomBoxes)
        f_clear_lines(guideLines)
        f_clear_labels(guideLabels)
        f_clear_labels(eventLabels)
        f_clear_labels(contextLabels)
    color shelfColor = newBearShelf ? bearColor : bullColor
    string shelfZoneText = newBearShelf ? "Dn Shelf" : "Up Shelf"
    box shelfZone = box.new(shelfPivotBar, shelfLevel + shelfHalf, bar_index + zoneProjectionBars, shelfLevel - shelfHalf,
         xloc = xloc.bar_index,
         bgcolor = color.new(shelfColor, 90),
         border_color = color.new(shelfColor, 58))
    f_keep_box(zoneBoxes, shelfZone, effectiveZoneObjectCap)
    if showShelfLabels
        int shelfBadgeX = int(math.round((shelfPivotBar + bar_index + zoneProjectionBars) * 0.5))
        label shelfZoneBadge = label.new(shelfBadgeX, shelfLevel, shelfZoneText,
             xloc = xloc.bar_index,
             style = label.style_label_center,
             color = color.new(shelfColor, 0),
             textcolor = headerText,
             size = f_size(labelFontSize))
        f_keep_label(contextLabels, shelfZoneBadge, contextLabelCap)

string labelText = ""
if failedReclaim
    if labelMode == "Detailed"
        labelText := eventDir == -1 ? "Bear Fail | Q " + str.tostring(math.round(candidateFailureScore)) + " | Risk " + f_price(riskLevel) : "Bull Fail | Q " + str.tostring(math.round(candidateFailureScore)) + " | Risk " + f_price(riskLevel)
    else if labelMode == "Balanced"
        labelText := eventDir == -1 ? "Bear Fail | Q " + str.tostring(math.round(candidateFailureScore)) + " | Room " + f_room_text(activeRoomAtr) : "Bull Fail | Q " + str.tostring(math.round(candidateFailureScore)) + " | Room " + f_room_text(activeRoomAtr)
    else
        labelText := eventDir == -1 ? "Bear Fail | Q " + str.tostring(math.round(candidateFailureScore)) : "Bull Fail | Q " + str.tostring(math.round(candidateFailureScore))

color eventColor = eventDir == -1 ? bearColor : eventDir == 1 ? bullColor : neutralColor
float zoneTop = not na(shelfLevel) ? shelfLevel + shelfHalf : na
float zoneBottom = not na(shelfLevel) ? shelfLevel - shelfHalf : na
bool canEventVisual = failedReclaim and not latestVisualMode and (na(lastEventVisualBar) or bar_index - lastEventVisualBar >= cooldownBars or eventDir != lastEventVisualDir)

if canEventVisual and latestVisualMode
    f_clear_boxes(zoneBoxes)
    f_clear_boxes(roomBoxes)
    f_clear_lines(guideLines)
    f_clear_labels(guideLabels)
    f_clear_labels(eventLabels)
    f_clear_labels(contextLabels)

if canEventVisual and showZones and not na(zoneTop) and not na(zoneBottom)
    string confirmText = eventDir == -1 ? "Bear Fail" : "Bull Fail"
    box confirmZone = box.new(bar_index, zoneTop, bar_index + eventZoneProjectionBars, zoneBottom,
         xloc = xloc.bar_index,
         bgcolor = color.new(eventColor, 82),
         border_color = color.new(eventColor, 18))
    f_keep_box(zoneBoxes, confirmZone, effectiveZoneObjectCap)
    if showFailureZoneBadges
        int confirmBadgeX = int(math.round((bar_index + bar_index + eventZoneProjectionBars) * 0.5))
        float confirmBadgeY = (zoneTop + zoneBottom) * 0.5
        label confirmBadge = label.new(confirmBadgeX, confirmBadgeY, confirmText,
             xloc = xloc.bar_index,
             style = label.style_label_center,
             color = color.new(eventColor, 0),
             textcolor = headerText,
             size = f_size(labelFontSize))
        f_keep_label(contextLabels, confirmBadge, effectiveZoneObjectCap)

if canEventVisual and showPlanBand and not na(activeTarget)
    float roomTop = eventDir == -1 ? close : activeTarget
    float roomBottom = eventDir == -1 ? activeTarget : close
    string roomText = "Room " + f_room_text(activeRoomAtr)
    box roomBox = box.new(bar_index, roomTop, bar_index + zoneProjectionBars, roomBottom,
         xloc = xloc.bar_index,
         bgcolor = color.new(accentColor, 91),
         border_color = color.new(accentColor, 58))
    int roomBadgeX = int(math.round((bar_index + bar_index + zoneProjectionBars) * 0.5))
    float roomBadgeY = (roomTop + roomBottom) * 0.5
    label roomBadge = label.new(roomBadgeX, roomBadgeY, roomText,
         xloc = xloc.bar_index,
         style = label.style_label_center,
         color = color.new(accentColor, 0),
         textcolor = headerText,
         size = f_size(labelFontSize))
    f_keep_box(roomBoxes, roomBox, effectiveZoneObjectCap)
    f_keep_label(contextLabels, roomBadge, effectiveZoneObjectCap * 2)

if canEventVisual and showGuides and not na(riskLevel) and not na(activeTarget)
    int guideRightX = bar_index + visualProjectionBars + (showGuideTags ? guideTagOffsetBars : 0)
    line riskGuide = line.new(bar_index, riskLevel, guideRightX, riskLevel,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = color.new(eventColor, 8),
         style = line.style_dashed,
         width = 2)
    line targetGuide = line.new(bar_index, activeTarget, guideRightX, activeTarget,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = color.new(accentColor, 12),
         style = line.style_dotted,
         width = 1)
    f_keep_line(guideLines, riskGuide, effectiveGuideObjectCap * 2)
    f_keep_line(guideLines, targetGuide, effectiveGuideObjectCap * 2)
    if showGuideTags
        label riskTag = f_badge_set(na, guideRightX, riskLevel, "Risk " + f_price(riskLevel), eventColor, headerText, labelFontSize, label.style_label_left)
        label targetTag = f_badge_set(na, guideRightX, activeTarget, "Target " + f_price(activeTarget), accentColor, headerText, labelFontSize, label.style_label_left)
        f_keep_label(guideLabels, riskTag, effectiveGuideObjectCap * 2)
        f_keep_label(guideLabels, targetTag, effectiveGuideObjectCap * 2)

if canEventVisual and showEventLabels
    float eventY = eventDir == -1 ? high + atr * labelOffsetAtr * 1.25 : low - atr * labelOffsetAtr * 1.25
    string eventStyle = eventDir == -1 ? label.style_label_down : label.style_label_up
    label eventLabel = label.new(bar_index, eventY, labelText,
         xloc = xloc.bar_index,
         style = eventStyle,
         color = color.new(eventColor, 0),
         textcolor = headerText,
         size = f_size(labelFontSize))
    f_keep_label(eventLabels, eventLabel, effectiveEventObjectCap)

if canEventVisual
    lastEventVisualBar := bar_index
    lastEventVisualDir := eventDir

// Persistent active-failure visual: while the panel reads Failure Active, keep the last
// confirmed failed-reclaim set (zone, label, risk / target guides, room band) drawn and
// extended to the right edge so the chart never shows an active state with no drawings.
var box persistZone = na
var label persistZoneBadge = na
var box persistRoom = na
var label persistRoomBadge = na
var line persistRiskLine = na
var line persistTargetLine = na
var label persistRiskTag = na
var label persistTargetTag = na
var label persistEventLabel = na

bool showPersist = barstate.islast and latestVisualMode and recentFailure and not na(lastFailureBar) and not na(lastFailureShelf) and not na(lastFailureShelfHalf)
if showPersist
    int pDir = lastFailureDir
    color pColor = pDir == -1 ? bearColor : bullColor
    float pZoneTop = lastFailureShelf + lastFailureShelfHalf
    float pZoneBottom = lastFailureShelf - lastFailureShelfHalf
    int pRightZone = bar_index + eventZoneProjectionBars
    int pRightGuide = bar_index + visualProjectionBars + (showGuideTags ? guideTagOffsetBars : 0)

    if showZones
        if na(persistZone)
            persistZone := box.new(lastFailureBar, pZoneTop, pRightZone, pZoneBottom, xloc = xloc.bar_index, bgcolor = color.new(pColor, 82), border_color = color.new(pColor, 18))
        else
            box.set_lefttop(persistZone, lastFailureBar, pZoneTop)
            box.set_rightbottom(persistZone, pRightZone, pZoneBottom)
            box.set_bgcolor(persistZone, color.new(pColor, 82))
            box.set_border_color(persistZone, color.new(pColor, 18))
        if showFailureZoneBadges
            int pBadgeX = int(math.round((lastFailureBar + pRightZone) * 0.5))
            float pBadgeY = (pZoneTop + pZoneBottom) * 0.5
            string pBadgeText = pDir == -1 ? "Bear Fail" : "Bull Fail"
            persistZoneBadge := f_badge_set(persistZoneBadge, pBadgeX, pBadgeY, pBadgeText, pColor, headerText, labelFontSize, label.style_label_center)
        else if not na(persistZoneBadge)
            label.delete(persistZoneBadge)
            persistZoneBadge := na
    else if not na(persistZone)
        box.delete(persistZone)
        persistZone := na

    if showPlanBand and not na(lastFailureTarget) and not na(lastFailureClose)
        float pRoomTop = pDir == -1 ? lastFailureClose : lastFailureTarget
        float pRoomBottom = pDir == -1 ? lastFailureTarget : lastFailureClose
        int pRightRoom = bar_index + zoneProjectionBars
        if na(persistRoom)
            persistRoom := box.new(lastFailureBar, pRoomTop, pRightRoom, pRoomBottom, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 91), border_color = color.new(accentColor, 58))
        else
            box.set_lefttop(persistRoom, lastFailureBar, pRoomTop)
            box.set_rightbottom(persistRoom, pRightRoom, pRoomBottom)
        int pRoomBadgeX = int(math.round((lastFailureBar + pRightRoom) * 0.5))
        float pRoomBadgeY = (pRoomTop + pRoomBottom) * 0.5
        persistRoomBadge := f_badge_set(persistRoomBadge, pRoomBadgeX, pRoomBadgeY, "Room " + f_room_text(lastRoomAtr), accentColor, headerText, labelFontSize, label.style_label_center)
    else
        if not na(persistRoom)
            box.delete(persistRoom)
            persistRoom := na
        if not na(persistRoomBadge)
            label.delete(persistRoomBadge)
            persistRoomBadge := na

    if showGuides and not na(lastFailureRisk) and not na(lastFailureTarget)
        if na(persistRiskLine)
            persistRiskLine := line.new(lastFailureBar, lastFailureRisk, pRightGuide, lastFailureRisk, xloc = xloc.bar_index, extend = extend.none, color = color.new(pColor, 8), style = line.style_dashed, width = 2)
        else
            line.set_xy1(persistRiskLine, lastFailureBar, lastFailureRisk)
            line.set_xy2(persistRiskLine, pRightGuide, lastFailureRisk)
            line.set_color(persistRiskLine, color.new(pColor, 8))
        if na(persistTargetLine)
            persistTargetLine := line.new(lastFailureBar, lastFailureTarget, pRightGuide, lastFailureTarget, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 12), style = line.style_dotted, width = 1)
        else
            line.set_xy1(persistTargetLine, lastFailureBar, lastFailureTarget)
            line.set_xy2(persistTargetLine, pRightGuide, lastFailureTarget)
        if showGuideTags
            persistRiskTag := f_badge_set(persistRiskTag, pRightGuide, lastFailureRisk, "Risk " + f_price(lastFailureRisk), pColor, headerText, labelFontSize, label.style_label_left)
            persistTargetTag := f_badge_set(persistTargetTag, pRightGuide, lastFailureTarget, "Target " + f_price(lastFailureTarget), accentColor, headerText, labelFontSize, label.style_label_left)
        else
            if not na(persistRiskTag)
                label.delete(persistRiskTag)
                persistRiskTag := na
            if not na(persistTargetTag)
                label.delete(persistTargetTag)
                persistTargetTag := na
    else
        if not na(persistRiskLine)
            line.delete(persistRiskLine)
            persistRiskLine := na
        if not na(persistTargetLine)
            line.delete(persistTargetLine)
            persistTargetLine := na

    if showEventLabels and not na(lastFailureScore)
        float pEventY = pDir == -1 ? (lastFailureShelf + lastFailureShelfHalf) + atr * labelOffsetAtr * 1.25 : (lastFailureShelf - lastFailureShelfHalf) - atr * labelOffsetAtr * 1.25
        string pEventStyle = pDir == -1 ? label.style_label_down : label.style_label_up
        string pEventText = (pDir == -1 ? "Bear Fail | Q " : "Bull Fail | Q ") + str.tostring(math.round(lastFailureScore))
        persistEventLabel := f_badge_set(persistEventLabel, lastFailureBar, pEventY, pEventText, pColor, headerText, labelFontSize, pEventStyle)
    else if not na(persistEventLabel)
        label.delete(persistEventLabel)
        persistEventLabel := na
else if barstate.islast
    if not na(persistZone)
        box.delete(persistZone)
        persistZone := na
    if not na(persistZoneBadge)
        label.delete(persistZoneBadge)
        persistZoneBadge := na
    if not na(persistRoom)
        box.delete(persistRoom)
        persistRoom := na
    if not na(persistRoomBadge)
        label.delete(persistRoomBadge)
        persistRoomBadge := na
    if not na(persistRiskLine)
        line.delete(persistRiskLine)
        persistRiskLine := na
    if not na(persistTargetLine)
        line.delete(persistTargetLine)
        persistTargetLine := na
    if not na(persistRiskTag)
        label.delete(persistRiskTag)
        persistRiskTag := na
    if not na(persistTargetTag)
        label.delete(persistTargetTag)
        persistTargetTag := na
    if not na(persistEventLabel)
        label.delete(persistEventLabel)
        persistEventLabel := na

bool canShelfLabel = newShelfEvent and showShelfLabels and showEventLabels and not showZones and (na(lastShelfLabelBar) or bar_index - lastShelfLabelBar >= cooldownBars)

if canShelfLabel
    lastShelfLabelBar := bar_index
    string shelfText = newBearShelf ? "Dn Shelf" : "Up Shelf"
    float shelfY = newBearShelf ? high + atr * labelOffsetAtr : low - atr * labelOffsetAtr
    string shelfStyle = newBearShelf ? label.style_label_down : label.style_label_up
    color shelfLabelColor = newBearShelf ? color.new(bearColor, 6) : color.new(bullColor, 6)
    label shelfLabel = label.new(bar_index, shelfY, shelfText,
         xloc = xloc.bar_index,
         style = shelfStyle,
         color = shelfLabelColor,
         textcolor = headerText,
         size = f_size(labelFontSize))
    f_keep_label(contextLabels, shelfLabel, contextLabelCap)

bool canWatchLabel = shelfAlive and retestTouch and showWatchLabels and showEventLabels and not failedReclaim and (na(lastWatchLabelBar) or bar_index - lastWatchLabelBar >= cooldownBars)

if canWatchLabel
    lastWatchLabelBar := bar_index
    float watchY = activeDir == -1 ? high + atr * labelOffsetAtr : low - atr * labelOffsetAtr
    string watchStyle = activeDir == -1 ? label.style_label_down : label.style_label_up
    label watchLabel = label.new(bar_index, watchY, "Reclaim Watch",
         xloc = xloc.bar_index,
         style = watchStyle,
         color = color.new(neutralColor, 0),
         textcolor = color.rgb(15, 23, 42),
         size = f_size(labelFontSize))
    f_keep_label(contextLabels, watchLabel, contextLabelCap)

// -------------------------------------------------
// Panel
// -------------------------------------------------
color panelBgNow = panelTheme == "Dark" ? panelBg : color.rgb(248, 250, 252)
color panelBorderNow = panelTheme == "Dark" ? panelBorder : color.rgb(203, 213, 225)
color panelLabelNow = panelTheme == "Dark" ? panelLabelCol : color.rgb(71, 85, 105)
color panelValueNow = panelTheme == "Dark" ? panelValueCol : color.rgb(15, 23, 42)
color panelAltBg = panelTheme == "Dark" ? color.rgb(20, 31, 51) : color.rgb(241, 245, 249)
color roomValueColor = panelValueNow
if not na(displayRoom)
    if displayRoom >= targetRoomAtr * 0.70
        roomValueColor := bullColor
    else if displayRoom >= targetRoomAtr * 0.35
        roomValueColor := neutralColor
    else
        roomValueColor := dangerColor

color scoreValueColor = na(displayScore) ? panelValueNow : f_score_color(displayScore)
color rejectionValueColor = na(displayRejection) ? panelValueNow : f_score_color(displayRejection)

string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) : "building"
string followText = proofTotal > 0 ? f_pct(followRate) : "-"
string holdText = proofTotal > 0 ? f_pct(holdRate) : "-"
string reactText = proofTotal > 0 ? f_pct(reactRate) : "-"
string flipText = proofTotal > 0 ? f_pct(flipRate) : "-"
color followCol = proofTotal > 0 ? f_rate_color(followRate) : panelValueNow
color holdCol = proofTotal > 0 ? f_rate_color(holdRate) : panelValueNow
color reactCol = proofTotal > 0 ? f_rate_color(reactRate) : panelValueNow
color flipCol = proofTotal > 0 ? f_flip_color(flipRate) : panelValueNow

int panelRowCount = showProof ? 11 : 6
var table plannerPanel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""
var string lastPanelFontSize = ""
var bool lastPanelVisible = false
var bool lastProofMode = false

bool panelNeedsReset = na(plannerPanel) or panelLocation != lastPanelLocation or panelTheme != lastPanelTheme or panelFontSize != lastPanelFontSize or showPanel != lastPanelVisible or showProof != lastProofMode
if panelNeedsReset
    if not na(plannerPanel)
        table.delete(plannerPanel)
    if showPanel
        plannerPanel := table.new(f_panel_pos(panelLocation), 2, panelRowCount, bgcolor = panelBgNow, border_color = panelBorderNow, border_width = 1)
    else
        plannerPanel := na
    lastPanelLocation := panelLocation
    lastPanelTheme := panelTheme
    lastPanelFontSize := panelFontSize
    lastPanelVisible := showPanel
    lastProofMode := showProof

if barstate.islast and showPanel and not na(plannerPanel)
    table.clear(plannerPanel, 0, 0, 1, panelRowCount - 1)
    table.merge_cells(plannerPanel, 0, 0, 1, 0)
    table.cell(plannerPanel, 0, 0, "AG Pro Failed Reclaim Planner", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSize), text_halign = text.align_center)
    f_panel_row(plannerPanel, 1, "Reclaim State", displayState, displayColor, panelBgNow, panelLabelNow, panelFontSize)
    f_panel_row(plannerPanel, 2, "Failure Score", na(displayScore) ? "-" : f_score_text(displayScore) + " " + f_tier(displayScore), scoreValueColor, panelAltBg, panelLabelNow, panelFontSize)
    f_panel_row(plannerPanel, 3, "Rejection Quality", f_score_text(displayRejection), rejectionValueColor, panelBgNow, panelLabelNow, panelFontSize)
    f_panel_row(plannerPanel, 4, "Room", f_room_text(displayRoom), roomValueColor, panelAltBg, panelLabelNow, panelFontSize)
    f_panel_row(plannerPanel, 5, "Action", displayAction, panelValueNow, panelBgNow, panelLabelNow, panelFontSize)
    if showProof
        table.cell(plannerPanel, 0, 6, "Proof @ Confirm", text_color = accentColor, bgcolor = panelAltBg, text_size = f_size(panelFontSize), text_halign = text.align_left)
        table.cell(plannerPanel, 1, 6, proofSampleText, text_color = panelLabelNow, bgcolor = panelAltBg, text_size = f_size(panelFontSize), text_halign = text.align_right)
        f_panel_row(plannerPanel, 7, "Follow Rate", followText, followCol, panelBgNow, panelLabelNow, panelFontSize)
        f_panel_row(plannerPanel, 8, "Hold Rate", holdText, holdCol, panelAltBg, panelLabelNow, panelFontSize)
        f_panel_row(plannerPanel, 9, "React Rate", reactText, reactCol, panelBgNow, panelLabelNow, panelFontSize)
        f_panel_row(plannerPanel, 10, "Flip Rate", flipText, flipCol, panelAltBg, panelLabelNow, panelFontSize)

// -------------------------------------------------
// Hidden Exports
// -------------------------------------------------
plot(followRate, "FRP Follow Rate", display = display.none)
plot(holdRate, "FRP Hold Rate", display = display.none)
plot(reactRate, "FRP React Rate", display = display.none)
plot(flipRate, "FRP Flip Rate", display = display.none)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
bool bearAlert = bearFailedReclaim and candidateFailureScore >= alertScore
bool bullAlert = bullFailedReclaim and candidateFailureScore >= alertScore
bool shelfWatchAlert = newShelfEvent
bool recoveryAlert = confirmedBar and shelfRecoveredNow

alertcondition(bearAlert, "Bearish Failed Reclaim", "Bearish failed reclaim detected on a visible broken swing shelf. This is an attention marker, not a trade instruction.")
alertcondition(bullAlert, "Bullish Failed Reclaim", "Bullish failed reclaim detected on a visible broken swing shelf. This is an attention marker, not a trade instruction.")
alertcondition(shelfWatchAlert, "New Broken Shelf", "A visible swing shelf has broken and entered reclaim-watch mode. This is an attention marker, not a trade instruction.")
alertcondition(recoveryAlert, "Shelf Recovered", "The active reclaim shelf has been recovered, reducing the failed-reclaim context. This is an attention marker, not a trade instruction.")
````
