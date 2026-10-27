# Price Acceptance Reversal Planner [AGPro Series]

- url: https://www.tradingview.com/script/8F5WUY0F-Price-Acceptance-Reversal-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;019503598c27407cbcf0f1281c11df05
- version: 4.0

## Description

Price Acceptance Reversal Planner [AGPro Series]

🧠 Core Idea

Is price failing acceptance and starting a structured reversal context with clear risk, room, and next-action guidance?


📌 Overview / What it does

Price Acceptance Reversal Planner [AGPro Series] is a chart-first reversal planning tool built around price acceptance failure.

The script studies whether price has spent enough time accepting above or below a dynamic fair-value band. When that acceptance starts to fail, it evaluates close-back behavior, reversal candle quality, volume response, invalidation distance, and target room, then converts the context into a 0-100 reversal readiness score.

It produces acceptance bands, failed-acceptance zones, reversal trigger rails, invalidation shelves, target-room guides, labels, alerts, and a clean AGPro planning panel. Optional shelf and room boxes are available for users who want a heavier map, while the default public view stays lighter. It does not predict price direction, automate trading, or claim that every acceptance failure must reverse.


🎯 Purpose & Design Philosophy

This script was built for traders who want a structured way to evaluate when accepted price behavior is starting to break down.

Many charts show price spending time above or below a perceived fair-value area before suddenly rotating back through that area. The useful question is not only where price traded, but whether that accepted behavior is now failing with enough quality to deserve review.

The design supports a planning mindset: identify the acceptance state, detect failure, score reversal quality, locate invalidation, review target room, and decide whether to wait, review, or stand aside.


⚡ Why This Script Is Different

Most acceptance tools focus on volume profile, value area, POC, or static market-profile references.

This script does NOT try to become a Price Acceptance Profile clone, Acceptance Breakout Planner clone, volume profile tool, POC tracker, generic support/resistance map, or broad reversal signal generator.

Instead, it focuses on the decision layer after acceptance starts failing. The core output is not a simple buy or sell marker. The output is a structured reversal plan with score, failure risk, invalidation shelf, target-room guide, and next-action state.


⚙️ Methodology

1. Context Detection
The script builds a dynamic price acceptance band around an adaptive fair-value anchor and tracks whether price is accepting above, below, or inside that band.

2. Reference Mapping
The failed acceptance edge becomes the reversal trigger. The recent failure extreme becomes the invalidation shelf. The opposite side of the band, or an ATR fallback, becomes the target-room guide.

3. Reaction Evaluation
The score model evaluates time in acceptance, close-back failure strength, reversal candle quality, relative volume response, target room, and risk efficiency.

4. Visual Output
Qualified events are displayed through failed-acceptance zones, trigger rails, invalidation shelves, target-room bands, compact labels, alerts, and the AGPro planning panel.


🗺️ How to Read the Chart

Zones = compact failed-acceptance areas where price accepted above or below the band and then rotated back through the relevant edge.

Labels = acceptance watch, reversal ready, invalidation, and target-room review markers.

Colors = teal marks bullish lower-acceptance failure, pink marks bearish upper-acceptance failure, amber marks watch states, and indigo marks target-room references.

Panel = the panel summarizes Acceptance State, Reversal Score, Failure Risk, Room, and Action.


🚦 Signals & States

• Upper Acceptance Watch → price has accepted above the band long enough to watch for failure evidence.

• Lower Acceptance Watch → price has accepted below the band long enough to watch for failure evidence.

• Bear Reversal Ready → upper acceptance failed with enough reversal quality, risk structure, and room.

• Bull Reversal Ready → lower acceptance failed with enough reversal quality, risk structure, and room.

• Acceptance Reversal Invalidated → price crossed the active invalidation shelf.

• Target Room Review → price reached the active target-room guide.


🔔 Alerts Logic

Alerts trigger when upper/lower acceptance watch states appear, when bull/bear reversal readiness is confirmed, when the active invalidation shelf is crossed, or when price reaches the target-room guide.

Alerts are attention markers. They are not trade instructions, entry signals, exit signals, or automated strategy commands.


🧩 Confluence Logic

The strongest planner states appear when multiple conditions align:

Time in acceptance + close-back failure + reversal candle quality + volume response + clean invalidation distance + usable target room.

When only partial evidence appears, the script remains in watch mode or stand-aside mode.


📊 When to Use

• After price spends time accepting above or below a dynamic fair-value band

• Around failed acceptance, failed continuation, or rotation-back contexts

• During reversal review workflows where risk and room need structure

• When a trader wants a decision engine rather than another generic signal marker


⚠️ When NOT to Use

• Extremely low-liquidity symbols

• Very noisy micro-timeframes

• News-driven gaps or abnormal candles

• Markets where price is violently trending and acceptance failure keeps failing

• Situations where the user expects automatic buy/sell instructions


🎛️ Key Inputs

• Acceptance Anchor Length → controls the dynamic fair-value anchor.

• Acceptance Band Width ATR → controls the band around the anchor.

• Minimum Acceptance Bars → defines how long price must accept above or below the band before failure can qualify.

• Failure Close Distance ATR → controls how cleanly price must close back through the failed edge.

• Minimum Reversal Score → sets the 0-100 threshold for READY events.

• Invalidation Shelf Buffer ATR → places the invalidation shelf beyond the failure extreme.

• Target Room ATR Fallback → builds a target-room guide when the opposite band side is too close.

• Visual settings → control zones, rails, labels, panel location, panel theme, and font sizes.


🖥️ Interface & Visual Design

The interface is built to stay chart-first.

The live acceptance band shows the current reference area. Compact event boxes show where acceptance failed. Trigger rails define the failed edge. Invalidation rails define where the active reversal context weakens. Target-room guides show the next review area without making a promise.

The panel keeps the decision summary compact, readable, and consistent with AGPro public-release formatting.


🧪 Practical Usage Workflow

1. Read the panel to identify the current Acceptance State.

2. Check whether price is accepting above, below, or inside the band.

3. Watch for failed-acceptance labels and reversal readiness score.

4. Review the invalidation shelf and target-room guide.

5. Interpret the context with broader structure, volatility, and personal risk rules.


🔍 Interpretation Guidelines

Acceptance watch means price has stayed outside the band long enough to deserve observation, but reversal is not confirmed.

Reversal ready means the script found stronger failure, candle, risk, and room evidence.

Invalidation means the active context weakened according to the script rules.

Target-room review means price reached a planned review area, not that price must stop or reverse there.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not an auto trading system

• Not a guaranteed signal tool

• Not a Price Acceptance Profile clone

• Not an Acceptance Breakout Planner clone

• Not a volume profile, value area, or POC tool

• Not a generic support/resistance map

• Not an order block or FVG map


⚠️ Limitations & Transparency

Price acceptance behavior changes across symbols, timeframes, sessions, and volatility regimes.

Some acceptance failures continue to fail again. Some reversal-ready states may invalidate quickly. Some symbols have weak volume data, which can reduce the usefulness of the volume component.

The script provides structured context, not certainty.


🧠 Market Context Notes

Acceptance failure often matters when price spends time outside a fair-value area and then rotates back through the acceptance edge.

The most useful contexts usually combine enough time in acceptance, a clean close-back failure, a strong reversal candle, usable target room, and a clear invalidation shelf.


🧾 Use Case Examples

When price accepts above the band for several bars, then closes back through the upper edge with bearish pressure and enough room below, the script may classify the context as a bearish acceptance reversal plan.

When price accepts below the band for several bars, then closes back through the lower edge with bullish pressure and enough room above, the script may classify the context as a bullish acceptance reversal plan.


🧱 System Philosophy

Price Acceptance Reversal Planner follows the AGPro decision-engine approach:

Context first.
Failure evidence before reaction.
Risk before target.
Room before excitement.
Attention markers instead of promises.


🔐 Non-Promise Statement

No script can guarantee a reversal, outcome, or market reaction.

No score, state, label, alert, rail, or zone should be interpreted as certainty.


📉 Risk Disclosure

Trading involves risk.

Users remain responsible for their own decisions, execution, risk management, and interpretation.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

Use the output as a structured review layer. The strongest readings usually come from combining the planner state with broader market structure, volatility, liquidity conditions, and personal risk rules.

## Source Code

````pine
// -------------------------------------------------
// Price Acceptance Reversal Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Price Acceptance Reversal Planner is a chart-first reversal decision engine.
// It studies whether price has accepted above or below a dynamic fair-value
// band, then evaluates when that acceptance fails with reversal pressure,
// invalidation context, target room, an empirical stop-aware reaction proof
// rate, and a 0-100 readiness score.
// -------------------------------------------------

//@version=6
indicator("Price Acceptance Reversal Planner [AGPro Series]",
     shorttitle = "AG Pro PAR",
     overlay = true,
     max_boxes_count = 90,
     max_labels_count = 220,
     max_lines_count = 140)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
color headerBg      = color.rgb(37, 99, 235)      // #2563EB
color headerText    = color.rgb(245, 247, 250)    // #F5F7FA
color panelBg       = color.rgb(15, 23, 42)       // #0F172A
color panelBorder   = color.rgb(51, 65, 85)       // #334155
color panelLabelCol = color.rgb(148, 163, 184)    // #94A3B8
color panelValueCol = color.rgb(226, 232, 240)    // #E2E8F0
color bullColor     = color.rgb(34, 197, 166)     // #22C5A6
color bearColor     = color.rgb(244, 114, 182)    // #F472B6
color neutralColor  = color.rgb(245, 189, 92)     // #F5BD5C
color accentColor   = color.rgb(129, 140, 248)    // #818CF8
color dangerColor   = color.rgb(239, 68, 68)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
const string TT_ANCHOR = "EMA length used to build the dynamic fair-value anchor. The planner does not create a volume profile or POC; it evaluates price acceptance around this adaptive band."
const string TT_ATR = "ATR length used to normalize acceptance-band width, failure distance, invalidation shelf distance, target room, and label offsets."
const string TT_VOL = "Volume baseline used to score participation behind the acceptance failure. On symbols with weaker volume data, this remains a supporting context input."
const string TT_LOOKBACK = "Lookback used to evaluate nearby target room and recent acceptance context. It does not draw generic support and resistance zones."
const string TT_SENS = "Controls how selective the acceptance-failure engine should be. Responsive shows more states, Balanced is the public default, and Strict requires cleaner failure evidence."
const string TT_CONFIRM = "Controls whether reversal states can update intrabar or must wait for confirmed closes, volume support, or stricter close behavior."
const string TT_BAND = "ATR width around the fair-value anchor used to define the price acceptance band."
const string TT_TIME = "Minimum consecutive closes above or below the band required before a later failure can qualify as an acceptance-failure context."
const string TT_FAIL = "Minimum close-back distance through the failed acceptance edge. Higher values require a cleaner failure back into the band."
const string TT_BUFFER = "ATR buffer beyond the failure extreme used to draw the invalidation shelf for an active reversal plan."
const string TT_TARGET = "ATR fallback used when the opposite side of the acceptance band does not provide enough target-room distance."
const string TT_ROOM = "ATR room considered clean enough for a reversal plan to receive a strong room score."
const string TT_MIN_SCORE = "Minimum 0-100 reversal score required before READY labels, reversal zones, rails, and alerts can appear."
const string TT_WATCH = "Minimum setup quality required before acceptance-watch labels can appear."
const string TT_BAND_SHOW = "Shows the live acceptance band. It is a planning band, not a prediction channel."
const string TT_ZONES = "Shows event-based acceptance-failure boxes with centered premium badge labels inside the zone."
const string TT_DETAIL_BOXES = "Shows optional invalidation-shelf and target-room boxes with centered badge labels. Keep this off for cleaner public screenshots; rails still show the same planning references."
const string TT_RAILS = "Shows one active reversal trigger, invalidation shelf, and target-room guide set. Every visible rail carries a filled price badge linked to Label Font Size."
const string TT_LABELS = "Shows acceptance watch, reversal ready, invalidated, and target review labels."
const string TT_REVIEW_LABELS = "Shows invalidation and target-room review labels after a plan is active. Keep this off for a cleaner default view on lower timeframes."
const string TT_SCORE_LABEL = "Adds the 0-100 score and grade to event labels."
const string TT_COOLDOWN = "Minimum bars between major event labels. Higher values reduce clustering."
const string TT_CONTEXT = "Minimum spacing between lighter acceptance-watch labels."
const string TT_MAX_OBJECTS = "Maximum number of visible event object sets retained by the script. Older objects are deleted first."
const string TT_FORWARD = "Number of bars projected to the right for event boxes, shelves, and target guides."
const string TT_LABEL_OFFSET = "ATR-based vertical offset that keeps labels away from candles."
const string TT_LABEL_SIZE = "Controls all chart labels and centered zone badges. Normal is the recommended public default."
const string TT_PANEL_SHOW = "Shows or hides the AG Pro planning panel. It is visible by default for public-release clarity."
const string TT_PANEL_LOCATION = "Moves the AG Pro panel to the preferred chart location."
const string TT_PANEL_THEME = "Switches the panel between the premium AGPro dark theme and a clean light theme."
const string TT_PANEL_SIZE = "Controls panel text size. Normal is the recommended public default."
const string TT_PROOF_WIN = "Maximum bars a reaction-proof window stays open before it is left uncounted in the proof rate."
const string TT_PROOF_TGT = "Symmetric reaction distance, in ATR, measured from the reversal-event close. A proof counts as a win if reversal-side follow-through reaches this distance before an equal adverse move occurs."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Acceptance Reversal Engine"
int anchorLength = input.int(34, "Acceptance Anchor Length", minval = 5, maxval = 240, group = groupEngine, tooltip = TT_ANCHOR)
int atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupEngine, tooltip = TT_ATR)
int volumeLength = input.int(34, "Volume Baseline Length", minval = 5, maxval = 220, group = groupEngine, tooltip = TT_VOL)
int targetLookback = input.int(72, "Target Room Lookback", minval = 20, maxval = 300, group = groupEngine, tooltip = TT_LOOKBACK)
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Responsive", "Balanced", "Strict"], group = groupEngine, tooltip = TT_SENS)
string confirmationMode = input.string("Close Acceptance", "Confirmation Mode", options = ["Realtime Allowed", "Close Acceptance", "Close + Volume", "Strict"], group = groupEngine, tooltip = TT_CONFIRM)

string groupPlanner = "Planner Model"
float bandWidthAtr = input.float(0.58, "Acceptance Band Width ATR", minval = 0.10, maxval = 2.50, step = 0.01, group = groupPlanner, tooltip = TT_BAND)
int minimumAcceptanceBars = input.int(4, "Minimum Acceptance Bars", minval = 2, maxval = 30, group = groupPlanner, tooltip = TT_TIME)
float failureDistanceAtr = input.float(0.10, "Failure Close Distance ATR", minval = 0.00, maxval = 1.50, step = 0.01, group = groupPlanner, tooltip = TT_FAIL)
float invalidationBufferAtr = input.float(0.24, "Invalidation Shelf Buffer ATR", minval = 0.00, maxval = 2.00, step = 0.01, group = groupPlanner, tooltip = TT_BUFFER)
float targetFallbackAtr = input.float(1.35, "Target Room ATR Fallback", minval = 0.30, maxval = 6.00, step = 0.05, group = groupPlanner, tooltip = TT_TARGET)
float cleanRoomAtr = input.float(1.85, "Clean Room Target ATR", minval = 0.40, maxval = 8.00, step = 0.05, group = groupPlanner, tooltip = TT_ROOM)
int minimumReversalScore = input.int(64, "Minimum Reversal Score", minval = 40, maxval = 95, group = groupPlanner, tooltip = TT_MIN_SCORE)
int watchScore = input.int(52, "Acceptance Watch Score", minval = 20, maxval = 90, group = groupPlanner, tooltip = TT_WATCH)
int proofWindowBars = input.int(60, "Proof Window Bars", minval = 10, maxval = 400, group = groupPlanner, tooltip = TT_PROOF_WIN)
float proofTargetAtr = input.float(1.0, "Proof Target (x ATR)", minval = 0.20, maxval = 5.00, step = 0.10, group = groupPlanner, tooltip = TT_PROOF_TGT)

string groupVisual = "Chart Visuals"
bool showAcceptanceBand = input.bool(true, "Show Live Acceptance Band", group = groupVisual, tooltip = TT_BAND_SHOW)
bool showFailureZones = input.bool(true, "Show Failure Zones", group = groupVisual, tooltip = TT_ZONES)
bool showDetailBoxes = input.bool(false, "Show Shelf / Room Boxes", group = groupVisual, tooltip = TT_DETAIL_BOXES)
bool showPlannerRails = input.bool(true, "Show Trigger / Risk / Target Rails", group = groupVisual, tooltip = TT_RAILS)
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupVisual, tooltip = TT_LABELS)
bool showReviewLabels = input.bool(false, "Show Review Labels", group = groupVisual, tooltip = TT_REVIEW_LABELS)
bool showLabelScore = input.bool(true, "Show Label Score", group = groupVisual, tooltip = TT_SCORE_LABEL)
int labelCooldownBars = input.int(18, "Event Label Cooldown", minval = 1, maxval = 120, group = groupVisual, tooltip = TT_COOLDOWN)
int contextSpacingBars = input.int(36, "Watch Label Spacing", minval = 5, maxval = 180, group = groupVisual, tooltip = TT_CONTEXT)
int maxVisibleObjects = input.int(6, "Max Visible Object Sets", minval = 4, maxval = 30, group = groupVisual, tooltip = TT_MAX_OBJECTS)
int forwardBars = input.int(30, "Forward Render Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = TT_FORWARD)
float labelOffsetAtr = input.float(0.95, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupVisual, tooltip = TT_LABEL_OFFSET)
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual, tooltip = TT_LABEL_SIZE)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = TT_PANEL_SHOW)
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = TT_PANEL_LOCATION)
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = TT_PANEL_THEME)
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = TT_PANEL_SIZE)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_text_on(color bg) =>
    float lum = 0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)
    lum > 145 ? color.rgb(17, 24, 39) : headerText

f_norm_high(float value, float weakValue, float strongValue) =>
    float span = math.max(strongValue - weakValue, 0.000001)
    f_clamp((value - weakValue) / span * 100.0, 0.0, 100.0)

f_norm_low(float value, float strongValue, float weakValue) =>
    float span = math.max(weakValue - strongValue, 0.000001)
    f_clamp((weakValue - value) / span * 100.0, 0.0, 100.0)

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    float result = 0.0
    if value <= idealValue
        result := f_norm_high(value, lowValue, idealValue)
    else
        result := f_norm_low(value, idealValue, highValue)
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
    else if score >= 64.0
        result := "B"
    else if score >= 52.0
        result := "C"
    result

f_score_color(float score) =>
    color result = panelValueCol
    if score >= minimumReversalScore
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

f_panel_row_fill(table target, int row, string labelText, string valueText, color fillColor, string themeText, string sizeText) =>
    table.cell(target, 0, row, labelText, text_color = f_panel_label(themeText), bgcolor = f_row_bg(themeText, row), text_size = f_text_size(sizeText), text_halign = text.align_left)
    table.cell(target, 1, row, valueText, text_color = f_text_on(fillColor), bgcolor = fillColor, text_size = f_text_size(sizeText), text_halign = text.align_right)

f_keep_label(array<label> items, label newItem, int maxCount) =>
    array.push(items, newItem)
    while array.size(items) > maxCount
        label oldItem = array.shift(items)
        label.delete(oldItem)

f_keep_box(array<box> items, box newItem, int maxCount) =>
    array.push(items, newItem)
    while array.size(items) > maxCount
        box oldItem = array.shift(items)
        box.delete(oldItem)

f_avoid_overlap(array<label> labels, float desiredY, bool placeAbove, float safe) =>
    float y = desiredY
    float minGap = safe * 1.15
    int n = array.size(labels)
    if n > 0
        bool moved = true
        int guard = 0
        while moved and guard < 16
            moved := false
            for i = 0 to n - 1
                label lb = array.get(labels, i)
                if math.abs(label.get_x(lb) - bar_index) <= 24
                    if math.abs(label.get_y(lb) - y) < minGap
                        y := placeAbove ? y + minGap : y - minGap
                        moved := true
            guard += 1
    y

f_zone_badge(string textValue, int x1, int x2, float topValue, float bottomValue, color badgeColor, array<label> store, int maxCount, string sizeText) =>
    int x = int(math.round((x1 + x2) * 0.5))
    float y = (topValue + bottomValue) * 0.5
    label item = label.new(x, y, textValue, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(badgeColor, 0), textcolor = f_text_on(badgeColor), size = f_text_size(sizeText), textalign = text.align_center)
    f_keep_label(store, item, maxCount)

f_rail_badge(int x, float y, string prefix, color badgeColor, string sizeText) =>
    label.new(x, y, prefix + " " + f_fmt_price(y), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(badgeColor, 0), textcolor = f_text_on(badgeColor), size = f_text_size(sizeText), textalign = text.align_center)

// -------------------------------------------------
// Core Model
// -------------------------------------------------
bool confirmedBar = confirmationMode == "Realtime Allowed" ? true : barstate.isconfirmed
float atrRaw = ta.atr(atrLength)
float atr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
float anchor = ta.ema(hlc3, anchorLength)
float bandHalf = atr * bandWidthAtr
float bandTop = anchor + bandHalf
float bandBottom = anchor - bandHalf
float bandMid = anchor
float candleRange = math.max(high - low, syminfo.mintick)
float body = math.abs(close - open)
float bodyShare = body / candleRange
float closeLocation = (close - low) / candleRange
float volumeBase = ta.sma(volume, volumeLength)
float volumeRatio = volumeBase > 0.0 ? volume / volumeBase : 1.0

bool aboveBand = close > bandTop
bool belowBand = close < bandBottom
bool insideBand = close <= bandTop and close >= bandBottom

int acceptNeed = minimumAcceptanceBars
float failNeed = failureDistanceAtr
float bodyNeed = 0.28
float closeNeed = 0.62
if sensitivity == "Responsive"
    acceptNeed := math.max(minimumAcceptanceBars - 1, 2)
    failNeed := math.max(failureDistanceAtr * 0.65, 0.0)
    bodyNeed := 0.20
    closeNeed := 0.56
else if sensitivity == "Strict"
    acceptNeed := minimumAcceptanceBars + 2
    failNeed := failureDistanceAtr * 1.35
    bodyNeed := 0.34
    closeNeed := 0.68

var int upperAcceptCount = 0
var int lowerAcceptCount = 0
upperAcceptCount := aboveBand ? nz(upperAcceptCount[1]) + 1 : 0
lowerAcceptCount := belowBand ? nz(lowerAcceptCount[1]) + 1 : 0

int upperAcceptPrior = nz(upperAcceptCount[1])
int lowerAcceptPrior = nz(lowerAcceptCount[1])
bool hadUpperAcceptance = upperAcceptPrior >= acceptNeed
bool hadLowerAcceptance = lowerAcceptPrior >= acceptNeed

float upperFailureDistance = (bandTop - close) / atr
float lowerFailureDistance = (close - bandBottom) / atr
float bearCloseFailureScore = f_norm_high(upperFailureDistance, failNeed, 0.95)
float bullCloseFailureScore = f_norm_high(lowerFailureDistance, failNeed, 0.95)
float bearCloseLocationScore = f_norm_high(1.0 - closeLocation, closeNeed - 0.14, 0.92)
float bullCloseLocationScore = f_norm_high(closeLocation, closeNeed - 0.14, 0.92)
float bodyScore = f_norm_high(bodyShare, bodyNeed * 0.65, 0.74)
float bearDirectionScore = close < open ? 88.0 : close < close[1] ? 58.0 : 28.0
float bullDirectionScore = close > open ? 88.0 : close > close[1] ? 58.0 : 28.0
float volumeScore = f_norm_high(volumeRatio, 0.85, 1.75)
float bearTimeScore = f_norm_high(upperAcceptPrior, acceptNeed, acceptNeed + 9)
float bullTimeScore = f_norm_high(lowerAcceptPrior, acceptNeed, acceptNeed + 9)

float bullTarget = bandTop > close ? bandTop : close + atr * targetFallbackAtr
float bearTarget = bandBottom < close ? bandBottom : close - atr * targetFallbackAtr
float bullRoomAtr = (bullTarget - close) / atr
float bearRoomAtr = (close - bearTarget) / atr
float bullRoomScore = f_norm_high(bullRoomAtr, 0.35, cleanRoomAtr)
float bearRoomScore = f_norm_high(bearRoomAtr, 0.35, cleanRoomAtr)
float bullInvalidation = low - atr * invalidationBufferAtr
float bearInvalidation = high + atr * invalidationBufferAtr
float bullRiskAtr = (close - bullInvalidation) / atr
float bearRiskAtr = (bearInvalidation - close) / atr
float bullRiskScore = f_peak_score(bullRiskAtr, 0.22, 0.95, 3.20)
float bearRiskScore = f_peak_score(bearRiskAtr, 0.22, 0.95, 3.20)

float bullFailureRisk = f_clamp(bullTimeScore * 0.34 + bullCloseFailureScore * 0.30 + bullCloseLocationScore * 0.20 + volumeScore * 0.16, 0.0, 100.0)
float bearFailureRisk = f_clamp(bearTimeScore * 0.34 + bearCloseFailureScore * 0.30 + bearCloseLocationScore * 0.20 + volumeScore * 0.16, 0.0, 100.0)
float bullReversalScore = f_clamp(bullTimeScore * 0.18 + bullCloseFailureScore * 0.22 + bodyScore * 0.13 + bullDirectionScore * 0.12 + volumeScore * 0.10 + bullRoomScore * 0.15 + bullRiskScore * 0.10, 0.0, 100.0)
float bearReversalScore = f_clamp(bearTimeScore * 0.18 + bearCloseFailureScore * 0.22 + bodyScore * 0.13 + bearDirectionScore * 0.12 + volumeScore * 0.10 + bearRoomScore * 0.15 + bearRiskScore * 0.10, 0.0, 100.0)

bool volumePass = confirmationMode == "Close + Volume" ? volumeRatio >= 1.0 : confirmationMode == "Strict" ? volumeRatio >= 1.10 : true
bool bullClosePass = confirmationMode == "Strict" ? close > bandMid : close > bandBottom + atr * failNeed
bool bearClosePass = confirmationMode == "Strict" ? close < bandMid : close < bandTop - atr * failNeed
bool bullReady = confirmedBar and hadLowerAcceptance and bullClosePass and closeLocation >= closeNeed and bodyShare >= bodyNeed * 0.70 and volumePass and bullReversalScore >= minimumReversalScore
bool bearReady = confirmedBar and hadUpperAcceptance and bearClosePass and closeLocation <= 1.0 - closeNeed and bodyShare >= bodyNeed * 0.70 and volumePass and bearReversalScore >= minimumReversalScore
bool newReversalEvent = bullReady or bearReady

float previewScore = math.max(bullReversalScore, bearReversalScore)
float previewFailureRisk = math.max(bullFailureRisk, bearFailureRisk)
int currentAcceptanceDir = aboveBand ? 1 : belowBand ? -1 : 0
string currentAcceptanceState = aboveBand ? "Upper Acceptance " + str.tostring(upperAcceptCount) : belowBand ? "Lower Acceptance " + str.tostring(lowerAcceptCount) : insideBand ? "Inside Band" : "Transition"

var int activeDir = 0
var int activeUntil = na
var float activeScore = na
var float activeFailureRisk = na
var float activeInvalidation = na
var float activeTarget = na
var float activeTrigger = na
var float activeRoomAtr = na
var string activeState = "No Setup"
var string activeAction = "Stand Aside"
var bool activeTargetHit = false
var int lastEventLabelBar = na
var int lastContextLabelBar = na
var array<label> labelStore = array.new<label>()
var array<label> zoneLabelStore = array.new<label>()
var array<box> boxStore = array.new<box>()
var box activeFailBox = na
var label activeFailBadge = na
var line activeTrigLine = na
var line activeInvLine = na
var line activeTgtLine = na
var label activeTrigBadge = na
var label activeInvBadge = na
var label activeTgtBadge = na
var int activeStart = na

// Stop-aware reaction proof: on each reversal event, measure whether reversal-side
// follow-through reaches the symmetric target before an equal adverse move.
var int parProofTotal = 0
var int parProofWins = 0
var bool parProofPending = false
var int parProofDir = 0
var float parProofTarget = na
var float parProofStop = na
var int parProofStart = na

if confirmedBar and parProofPending
    bool pLoss = parProofDir == 1 ? close <= parProofStop : close >= parProofStop
    bool pWin = parProofDir == 1 ? close >= parProofTarget : close <= parProofTarget
    bool pResolved = false
    if pLoss
        parProofTotal += 1
        pResolved := true
    else if pWin
        parProofWins += 1
        parProofTotal += 1
        pResolved := true
    if not pResolved and not na(parProofStart) and bar_index - parProofStart >= proofWindowBars
        pResolved := true
    if pResolved
        parProofPending := false

bool majorLabelReady = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
bool contextLabelReady = na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars
bool upperWatch = confirmedBar and upperAcceptCount == acceptNeed and f_clamp(bearTimeScore * 0.55 + volumeScore * 0.20 + f_norm_high(math.abs(close - bandTop) / atr, 0.0, 0.75) * 0.25, 0.0, 100.0) >= watchScore
bool lowerWatch = confirmedBar and lowerAcceptCount == acceptNeed and f_clamp(bullTimeScore * 0.55 + volumeScore * 0.20 + f_norm_high(math.abs(close - bandBottom) / atr, 0.0, 0.75) * 0.25, 0.0, 100.0) >= watchScore

if showEventLabels and contextLabelReady and (upperWatch or lowerWatch) and not newReversalEvent
    int watchDir = upperWatch ? -1 : 1
    string watchText = upperWatch ? "Upper Accept\nWatch" : "Lower Accept\nWatch"
    float watchBaseY = watchDir == 1 ? low - atr * labelOffsetAtr : high + atr * labelOffsetAtr
    float watchY = f_avoid_overlap(labelStore, watchBaseY, watchDir != 1, atr)
    label watchLabel = label.new(bar_index, watchY, watchText, xloc = xloc.bar_index, style = watchDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(neutralColor, 0), textcolor = f_text_on(neutralColor), size = f_text_size(labelFontSize))
    f_keep_label(labelStore, watchLabel, maxVisibleObjects * 2)
    lastContextLabelBar := bar_index

if newReversalEvent
    int eventDir = bullReady ? 1 : -1
    float eventScore = eventDir == 1 ? bullReversalScore : bearReversalScore
    float eventFailureRisk = eventDir == 1 ? bullFailureRisk : bearFailureRisk
    float eventTarget = eventDir == 1 ? bullTarget : bearTarget
    float eventInvalidation = eventDir == 1 ? bullInvalidation : bearInvalidation
    float eventTrigger = eventDir == 1 ? bandBottom : bandTop
    float eventRoomAtr = eventDir == 1 ? bullRoomAtr : bearRoomAtr
    float bandBoxTop = bandTop
    float bandBoxBottom = bandBottom
    int eventAcceptBars = eventDir == 1 ? lowerAcceptPrior : upperAcceptPrior
    int leftEdge = bar_index - math.min(eventAcceptBars, targetLookback)
    int rightEdge = bar_index + forwardBars
    color eventColor = f_side_color(eventDir)
    string gradeText = f_grade(eventScore)
    string zoneText = eventDir == 1 ? "LOWER FAIL | Q" + str.tostring(math.round(eventScore)) : "UPPER FAIL | Q" + str.tostring(math.round(eventScore))
    string actionText = eventScore >= 78.0 ? "Review Reversal" : "Wait Pullback"

    activeDir := eventDir
    activeUntil := rightEdge
    activeScore := eventScore
    activeFailureRisk := eventFailureRisk
    activeInvalidation := eventInvalidation
    activeTarget := eventTarget
    activeTrigger := eventTrigger
    activeRoomAtr := eventRoomAtr
    activeState := eventDir == 1 ? "Bull Reversal" : "Bear Reversal"
    activeAction := actionText
    activeTargetHit := false
    activeStart := bar_index

    if confirmedBar and not parProofPending
        parProofPending := true
        parProofDir := eventDir
        parProofTarget := close + eventDir * atr * proofTargetAtr
        parProofStop := close - eventDir * atr * proofTargetAtr
        parProofStart := bar_index

    // Render every qualified plan; label cooldown limits annotations only.
    if newReversalEvent
        if showFailureZones
            if not na(activeFailBox)
                box.delete(activeFailBox)
            if not na(activeFailBadge)
                label.delete(activeFailBadge)
            activeFailBox := box.new(left = leftEdge, top = bandBoxTop, right = rightEdge, bottom = bandBoxBottom, xloc = xloc.bar_index, bgcolor = color.new(eventColor, 91), border_color = color.new(eventColor, 30), border_width = 1)
            int failBadgeX = int(math.round((leftEdge + rightEdge) * 0.5))
            float failBadgeY = (bandBoxTop + bandBoxBottom) * 0.5
            activeFailBadge := label.new(failBadgeX, failBadgeY, zoneText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(eventColor, 0), textcolor = f_text_on(eventColor), size = f_text_size(labelFontSize), textalign = text.align_center)
        if showDetailBoxes
            float shelfTop = eventDir == 1 ? eventTrigger : eventInvalidation
            float shelfBottom = eventDir == 1 ? eventInvalidation : eventTrigger
            float shelfHigh = math.max(shelfTop, shelfBottom)
            float shelfLow = math.min(shelfTop, shelfBottom)
            box shelfBox = box.new(left = bar_index, top = shelfHigh, right = rightEdge, bottom = shelfLow, xloc = xloc.bar_index, bgcolor = color.new(dangerColor, 93), border_color = color.new(dangerColor, 48), border_width = 1)
            f_keep_box(boxStore, shelfBox, maxVisibleObjects)
            f_zone_badge("Risk\nShelf", bar_index, rightEdge, shelfHigh, shelfLow, dangerColor, zoneLabelStore, maxVisibleObjects * 3, labelFontSize)
            float targetHalf = atr * 0.18
            box targetBox = box.new(left = bar_index, top = eventTarget + targetHalf, right = rightEdge, bottom = eventTarget - targetHalf, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 94), border_color = color.new(accentColor, 45), border_width = 1)
            f_keep_box(boxStore, targetBox, maxVisibleObjects)
            f_zone_badge("Target\nRoom", bar_index, rightEdge, eventTarget + targetHalf, eventTarget - targetHalf, accentColor, zoneLabelStore, maxVisibleObjects * 3, labelFontSize)
        if showPlannerRails
            if not na(activeTrigLine)
                line.delete(activeTrigLine)
            if not na(activeInvLine)
                line.delete(activeInvLine)
            if not na(activeTgtLine)
                line.delete(activeTgtLine)
            if not na(activeTrigBadge)
                label.delete(activeTrigBadge)
            if not na(activeInvBadge)
                label.delete(activeInvBadge)
            if not na(activeTgtBadge)
                label.delete(activeTgtBadge)
            activeTrigLine := line.new(leftEdge, eventTrigger, rightEdge, eventTrigger, xloc = xloc.bar_index, color = color.new(eventColor, 0), style = line.style_dashed, width = 2)
            activeInvLine := line.new(bar_index, eventInvalidation, rightEdge, eventInvalidation, xloc = xloc.bar_index, color = color.new(dangerColor, 0), style = line.style_dotted, width = 1)
            activeTgtLine := line.new(bar_index, eventTarget, rightEdge, eventTarget, xloc = xloc.bar_index, color = color.new(accentColor, 0), style = line.style_solid, width = 1)
            activeTrigBadge := f_rail_badge(rightEdge, eventTrigger, "TRIGGER", eventColor, labelFontSize)
            activeInvBadge := f_rail_badge(rightEdge, eventInvalidation, "INVALID", dangerColor, labelFontSize)
            activeTgtBadge := f_rail_badge(rightEdge, eventTarget, "TARGET", accentColor, labelFontSize)
        if showEventLabels and majorLabelReady
            string labelSide = eventDir == 1 ? "Bull Reversal" : "Bear Reversal"
            string labelText = showLabelScore ? labelSide + "\n" + f_score_text(eventScore) + " " + gradeText : labelSide + "\nReady"
            float labelBaseY = eventDir == 1 ? low - atr * labelOffsetAtr : high + atr * labelOffsetAtr
            float labelY = f_avoid_overlap(labelStore, labelBaseY, eventDir != 1, atr)
            label eventLabel = label.new(bar_index, labelY, labelText, xloc = xloc.bar_index, style = eventDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(eventColor, 0), textcolor = f_text_on(eventColor), size = f_text_size(labelFontSize))
            f_keep_label(labelStore, eventLabel, maxVisibleObjects * 2)
            lastEventLabelBar := bar_index

bool activeValid = activeDir != 0 and not na(activeUntil) and bar_index <= activeUntil
bool activeInvalidated = (confirmedBar and activeValid and activeDir == 1 and close < activeInvalidation) or (confirmedBar and activeValid and activeDir == -1 and close > activeInvalidation)
bool targetTouched = not activeTargetHit and ((confirmedBar and activeValid and activeDir == 1 and high >= activeTarget) or (confirmedBar and activeValid and activeDir == -1 and low <= activeTarget))

if showEventLabels and showReviewLabels and activeInvalidated and majorLabelReady
    float invBaseY = activeDir == 1 ? low - atr * labelOffsetAtr : high + atr * labelOffsetAtr
    float invY = f_avoid_overlap(labelStore, invBaseY, activeDir != 1, atr)
    label invalidLabel = label.new(bar_index, invY, "Invalidated\nReset", xloc = xloc.bar_index, style = activeDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(dangerColor, 0), textcolor = f_text_on(dangerColor), size = f_text_size(labelFontSize))
    f_keep_label(labelStore, invalidLabel, maxVisibleObjects * 2)
    lastEventLabelBar := bar_index

if activeInvalidated
    activeAction := "Invalidated"
    activeState := "Invalidated"
    activeUntil := bar_index

if targetTouched and not activeInvalidated
    activeAction := "Target Review"
    activeTargetHit := true
    if showEventLabels and showReviewLabels and majorLabelReady
        float tgtBaseY = activeDir == 1 ? high + atr * labelOffsetAtr : low - atr * labelOffsetAtr
        float tgtY = f_avoid_overlap(labelStore, tgtBaseY, activeDir == 1, atr)
        label targetLabel = label.new(bar_index, tgtY, "Target Room\nReview", xloc = xloc.bar_index, style = activeDir == 1 ? label.style_label_down : label.style_label_up, color = color.new(accentColor, 0), textcolor = f_text_on(accentColor), size = f_text_size(labelFontSize))
        f_keep_label(labelStore, targetLabel, maxVisibleObjects * 2)
        lastEventLabelBar := bar_index

bool activeExpired = activeDir != 0 and not activeValid and not na(activeUntil) and bar_index > activeUntil
if activeExpired
    if not na(activeTrigLine)
        line.delete(activeTrigLine)
        activeTrigLine := na
    if not na(activeInvLine)
        line.delete(activeInvLine)
        activeInvLine := na
    if not na(activeTgtLine)
        line.delete(activeTgtLine)
        activeTgtLine := na
    if not na(activeTrigBadge)
        label.delete(activeTrigBadge)
        activeTrigBadge := na
    if not na(activeInvBadge)
        label.delete(activeInvBadge)
        activeInvBadge := na
    if not na(activeTgtBadge)
        label.delete(activeTgtBadge)
        activeTgtBadge := na

bool parProofReady = parProofTotal >= 6
int parProofRate = parProofReady ? int(math.round(f_clamp(parProofWins / parProofTotal * 100.0, 0.0, 100.0))) : na
string parProofRead = parProofReady ? str.tostring(parProofRate) + "%  (" + str.tostring(parProofTotal) + ")" : "Building (" + str.tostring(parProofTotal) + ")"
color parProofColor = not parProofReady ? neutralColor : parProofRate >= 55 ? bullColor : parProofRate >= 45 ? neutralColor : bearColor

plotUpper = plot(showAcceptanceBand ? bandTop : na, "Acceptance Band High", color = color.new(accentColor, 45), linewidth = 1)
plotLower = plot(showAcceptanceBand ? bandBottom : na, "Acceptance Band Low", color = color.new(accentColor, 45), linewidth = 1)
plotMid = plot(showAcceptanceBand ? bandMid : na, "Acceptance Anchor", color = color.new(panelValueCol, 65), linewidth = 1)
fill(plotUpper, plotLower, color = showAcceptanceBand ? color.new(accentColor, 92) : na, title = "Acceptance Band Fill")

// -------------------------------------------------
// Panel
// -------------------------------------------------
string panelWorkflow = activeValid ? (activeTargetHit ? "Review Target" : activeAction) : (hadUpperAcceptance or hadLowerAcceptance ? "Watch Acceptance Fail" : "Scan Acceptance")
string panelAcceptance = activeValid ? activeState : currentAcceptanceState
string panelScore = activeValid ? f_score_text(activeScore) + " " + f_grade(activeScore) : f_score_text(previewScore)
string panelFailureRisk = activeValid ? f_score_text(activeFailureRisk) : f_score_text(previewFailureRisk)
string panelRoom = activeValid ? f_fmt_price(activeTarget) + " / " + str.tostring(math.round(activeRoomAtr * 10.0) / 10.0) + " ATR" : "-"
string panelAction = activeValid ? activeAction : hadUpperAcceptance ? "Watch Upper Fail" : hadLowerAcceptance ? "Watch Lower Fail" : currentAcceptanceDir == 1 ? "Monitor Upper" : currentAcceptanceDir == -1 ? "Monitor Lower" : "Stand Aside"
string panelAge = activeValid and not na(activeStart) ? str.tostring(bar_index - activeStart + 1) + " / " + str.tostring(math.max(activeUntil - activeStart + 1, 1)) + " bars" : "-"
color panelStateColor = activeValid ? f_side_color(activeDir) : hadUpperAcceptance or hadLowerAcceptance ? neutralColor : f_panel_value(panelTheme)
color panelScoreColor = activeValid ? f_score_color(activeScore) : f_score_color(previewScore)

var table panel = table.new(f_panel_pos(panelLocation), 2, 9, bgcolor = f_panel_bg(panelTheme), frame_color = f_panel_border(panelTheme), frame_width = 1, border_color = f_panel_border(panelTheme), border_width = 1)

if barstate.islast
    table.clear(panel, 0, 0, 1, 8)
    if showPanel
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Price Acceptance Reversal Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        f_panel_row(panel, 1, "Workflow", panelWorkflow, activeValid ? accentColor : neutralColor, panelTheme, panelFontSize)
        f_panel_row(panel, 2, "Acceptance State", panelAcceptance, panelStateColor, panelTheme, panelFontSize)
        f_panel_row_fill(panel, 3, "Reversal Score", panelScore, panelScoreColor, panelTheme, panelFontSize)
        f_panel_row_fill(panel, 4, "Reaction Proof", parProofRead, parProofColor, panelTheme, panelFontSize)
        f_panel_row(panel, 5, "Failure Risk", panelFailureRisk, f_score_color(activeValid ? activeFailureRisk : previewFailureRisk), panelTheme, panelFontSize)
        f_panel_row(panel, 6, "Target Room", panelRoom, activeValid ? accentColor : f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_panel_row(panel, 7, "Plan Age", panelAge, f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_panel_row_fill(panel, 8, "Action", panelAction, panelStateColor, panelTheme, panelFontSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(upperWatch, title = "Upper Acceptance Watch", message = "Price Acceptance Reversal Planner: upper acceptance context is active. Watch for failure evidence; this is not a trade instruction.")
alertcondition(lowerWatch, title = "Lower Acceptance Watch", message = "Price Acceptance Reversal Planner: lower acceptance context is active. Watch for failure evidence; this is not a trade instruction.")
alertcondition(bullReady, title = "Bull Reversal Ready", message = "Price Acceptance Reversal Planner: lower acceptance failure created a bullish reversal review context. Review score, risk, and room.")
alertcondition(bearReady, title = "Bear Reversal Ready", message = "Price Acceptance Reversal Planner: upper acceptance failure created a bearish reversal review context. Review score, risk, and room.")
alertcondition(activeInvalidated, title = "Acceptance Reversal Invalidated", message = "Price Acceptance Reversal Planner: active reversal context crossed its invalidation shelf.")
alertcondition(targetTouched, title = "Acceptance Reversal Target Room Review", message = "Price Acceptance Reversal Planner: price reached the active target-room guide. Review context; this is not an exit instruction.")
````
