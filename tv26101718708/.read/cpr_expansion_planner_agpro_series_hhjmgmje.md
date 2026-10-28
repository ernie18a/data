# CPR Expansion Planner [AGPro Series]

- url: https://www.tradingview.com/script/hHJMgMje-CPR-Expansion-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;921f45aa48434ea9af03cbd397a36e87
- version: 4.0

## Description

CPR Expansion Planner [AGPro Series]

🧠 Core Idea

Is CPR width and price acceptance setting up a structured expansion day, or is price still inside a weak pivot context?


📌 Overview / What it does

CPR Expansion Planner [AGPro Series] is a chart-first Central Pivot Range planning tool built to evaluate whether the current session is developing enough structure for an expansion-day read.

The script studies CPR width, the current anchor open, accepted closes beyond CPR, developing range expansion, target room, and the active invalidation shelf. These components are converted into a 0-100 Expansion Score and a clear next-action state.

It produces a CPR band, projected expansion room, target rail, invalidation shelf, state labels, alerts, and a clean AGPro planning panel. It does not predict future price movement, automate trades, or guarantee continuation.


🎯 Purpose & Design Philosophy

This script was built for traders who already watch CPR but want a more practical planning layer than a static pivot display.

Many CPR tools show the Central Pivot Range and leave the user to decide whether the day is balanced, expanding, failing, or already extended. This script fills that gap by translating CPR context into readiness, room, invalidation, and action language.

The design supports a planning mindset: identify the CPR base, check whether price is accepting beyond it, measure whether expansion has room, and keep the invalidation shelf visible.


⚡ Why This Script Is Different

Most tools focus on plotting CPR lines, daily pivots, or support/resistance reactions.

This script does NOT clone a Pivot Points Reaction Map, does not plot a full pivot ladder, and does not treat every pivot touch as a reaction signal.

Instead, it focuses on one question: is the CPR context preparing an expansion day with enough acceptance, range development, and target room to deserve attention?


⚙️ Methodology

1. Context Detection
The script builds CPR from the selected anchor and reads whether price is working above, below, or inside the CPR structure.

2. Reference Mapping
It maps the CPR band, accepted expansion side, invalidation shelf, projected target rail, and active expansion room.

3. Reaction Evaluation
The model scores CPR width, open location, accepted closes beyond CPR, current range expansion, and target room.

4. Visual Output
The result is shown through CPR zones, state labels, planner rails, deterministic alerts, and a premium AGPro panel.


🗺️ How to Read the Chart

Zones = the CPR band shows the active expansion base. The expansion room box shows the distance between the accepted CPR edge and the target rail.

Labels = READY, WATCH, ROOM, SHIFT, FOLLOW, and INVALID labels describe the current planning state.

Colors = green highlights bullish expansion context, pink highlights bearish expansion context, amber highlights room or follow-through review, indigo highlights watch states, and red highlights invalidation risk.

Panel = the panel summarizes CPR Width, Accepted Side, Expansion Score, Invalidation, and Action.


🚦 Signals & States

• READY → CPR acceptance, score, room, and confirmation are aligned.

• WATCH → price is beyond CPR but still needs cleaner confirmation or score improvement.

• ROOM BLOCKED → CPR acceptance exists, but the target rail is too close or already reached.

• EXTENDED → price has moved beyond the planned target room and late-chase risk is elevated.

• INVALID RISK → price has reached the active invalidation shelf.

• SHIFT → the accepted expansion side changed after a previous READY state.


🔔 Alerts Logic

Alerts trigger when the script detects a READY CPR expansion state, accepted side shift, invalidation risk, major follow-through, or blocked target room.

Alerts are attention markers. They are not trade instructions, automated entries, or exit commands.


🧩 Confluence Logic

The strongest context appears when narrow CPR width, a balanced anchor open, accepted closes beyond CPR, range expansion, and clean target room align.

When only one or two components are present, the script usually stays in WATCH, ROOM BLOCKED, or WAIT rather than forcing a strong state.


📊 When to Use

• Intraday markets where Daily CPR is a visible reference.

• Swing contexts where Weekly CPR is more relevant.

• Potential expansion days after narrow CPR conditions.

• Sessions where price begins accepting clearly beyond the CPR band.

• Traders who want risk and target context around CPR instead of only static lines.


⚠️ When NOT to Use

• Very low-liquidity symbols with unreliable volume and wide spreads.

• Extremely noisy sessions where price repeatedly crosses CPR without acceptance.

• News-driven volatility where normal CPR structure can be overwhelmed.

• Markets where the selected CPR anchor is not meaningful for the user's timeframe.


🎛️ Key Inputs

• CPR Anchor → switches between Daily and Weekly CPR.

• Sensitivity → adjusts how quickly the planner recognizes CPR expansion conditions.

• Confirmation Mode → controls whether acceptance requires close confirmation, volume support, or stricter alignment.

• READY Threshold → sets the minimum Expansion Score for READY states.

• Clean Target Room ATR → defines how much space is needed before the target rail is considered clean.

• Event Label Cooldown → controls label density and keeps the chart readable.

• Panel and Label Font Size → controls visual readability.


🖥️ Interface & Visual Design

The interface is chart-first.

The CPR band anchors the setup, the expansion room gives directional context, and the invalidation shelf keeps risk visible. The panel is intentionally compact, with one merged blue AGPro title row and five decision rows.

The goal is a premium TradingView visual: informative enough to avoid an empty chart, but restrained enough to stay clean.


🧪 Practical Usage Workflow

1. Read the panel and check the Expansion Score.

2. Identify whether price is accepting above or below CPR.

3. Review the expansion room and target rail.

4. Check the invalidation shelf.

5. Interpret READY, WATCH, ROOM, FOLLOW, or INVALID as planning context.


🔍 Interpretation Guidelines

Think in terms of structure, not prediction.

A narrow CPR can create expansion potential, but it still needs acceptance. Acceptance can be useful only if there is enough target room. A strong score with limited room may be less attractive than a moderate score with cleaner structure.

The script helps organize the CPR read; it does not replace broader market context.


🚫 What This Script Is NOT

• Not a prediction engine.

• Not financial advice.

• Not an auto trading system.

• Not a guaranteed signal generator.

• Not a full pivot ladder or generic support/resistance reaction map.


⚠️ Limitations & Transparency

• CPR behavior can vary across assets and sessions.

• Timeframe selection changes how the CPR anchor should be interpreted.

• High-impact news can distort normal expansion behavior.

• Thin liquidity can create false acceptance beyond CPR.

• The score is rule-based and should be interpreted within broader market context.


🧠 Market Context Notes

CPR can help frame session balance and directional acceptance. A narrow CPR often attracts expansion-day attention, but the useful question is not only whether CPR is narrow. The useful question is whether price accepts away from it with room, structure, and a clear invalidation reference.


🧾 Use Case Examples

When price opens near CPR, accepts above the top of the range, and develops range expansion with clean target room, the script may shift toward READY.

When price moves beyond CPR but immediately reaches the target rail, the script can mark ROOM BLOCKED or EXTENDED.

When price fails back through the opposite CPR edge, the planner can show INVALID RISK.


🧱 System Philosophy

AGPro Series tools are designed to turn visible market structure into practical decision context.

This script follows that philosophy by converting CPR from a passive reference into a structured expansion planner with score, state, risk, and target logic.


🔐 Non-Promise Statement

No guarantees.

No certainty.

No script can remove market risk or replace user responsibility.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions, risk management, and interpretation of market conditions.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

Use the script to study how CPR width, acceptance, range expansion, and target room interact over time. The best value comes from reviewing repeated examples across different symbols, sessions, and timeframes.

## Source Code

````pine
// -------------------------------------------------
// CPR Expansion Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// CPR Expansion Planner converts Central Pivot Range width, session open
// location, price acceptance, range expansion, target room, and invalidation
// distance into a decision-focused expansion day planner. It helps traders
// evaluate whether CPR context is ready, under watch, extended, or exposed
// to invalidation without cloning a generic pivot reaction map. Version 1.2
// adds an expansion follow-through proof and contrast-safe badge text.
// -------------------------------------------------

//@version=6
indicator("CPR Expansion Planner [AGPro Series]",
     shorttitle = "AG Pro CPR",
     overlay = true,
     max_boxes_count = 80,
     max_labels_count = 72,
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
color darkText      = color.rgb(15, 23, 42)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
const string TT_ANCHOR = "Selects the CPR anchor used by the planner. Daily CPR is the standard intraday expansion reference; Weekly CPR can be used for broader swing context."
const string TT_SIDE = "Selects which expansion side is evaluated. Auto follows the active CPR acceptance side, while directional modes restrict the model to one side."
const string TT_SENS = "Controls how strict the CPR expansion planner is. Responsive prints context sooner, Balanced is the public default, and Strict requires cleaner acceptance."
const string TT_ATR = "ATR normalizes CPR width, target rails, invalidation shelves, and label offsets across symbols and timeframes."
const string TT_VOL = "Volume baseline used to judge participation behind CPR acceptance. Volume is context, not a standalone instruction."
const string TT_LOOKBACK = "Lookback used to compare the current anchor range with recent behavior and avoid scoring weak expansion as a strong day."
const string TT_CONFIRM = "Defines how CPR acceptance is confirmed before READY state or alerts can trigger."
const string TT_READY = "Minimum 0-100 Expansion Score required for Ready labels and ready-state alerts."
const string TT_WATCH = "Minimum 0-100 Expansion Score required for lighter Watch and room-review labels."
const string TT_TARGET = "ATR distance used to define clean target room beyond the active CPR edge."
const string TT_TARGET_RANGE = "Prior range multiplier used to build the target rail. This keeps the rail tied to the active CPR expansion context instead of classic pivot R/S levels."
const string TT_INVALID = "ATR buffer placed beyond the opposite CPR edge to define the active invalidation shelf."
const string TT_ACCEPT = "Number of consecutive accepted closes beyond CPR required by the Balanced confirmation path."
const string TT_RANGE = "Current anchor range expansion threshold used for major follow-through alerts."
const string TT_EXPWINDOW = "Number of bars a Ready expansion has to follow through within, for the Expansion Rate proof. It only measures historical follow-through and is not a forecast."
const string TT_CPR = "Shows the active Central Pivot Range band with a centered badge."
const string TT_ROOM = "Shows the projected expansion room between the accepted CPR edge and the active target rail."
const string TT_RAILS = "Shows target and invalidation rails that frame the active CPR expansion plan."
const string TT_BADGES = "Shows separate centered badges for the CPR band and expansion room. Badges keep important text readable without embedding it directly into transparent boxes."
const string TT_BADGE_ANCHOR = "Controls where centered zone badges sit between the left and right edge of the projected zone. Higher values place badges closer to the right side."
const string TT_EVENTS = "Shows Ready, Watch, Room, Shift, Follow, and Invalid labels on the chart."
const string TT_SCORE_LABEL = "Adds the 0-100 Expansion Score to chart labels."
const string TT_COOLDOWN = "Minimum number of bars between major event labels. Higher values reduce clustering."
const string TT_CONTEXT = "Minimum spacing between lighter Watch labels. This keeps the chart informative without crowding candles."
const string TT_MAX_OBJECTS = "Maximum number of visible event labels retained by the script. Older labels are deleted first for performance."
const string TT_PROJECTION = "Number of bars projected to the right for the CPR band, expansion room, and planner rails."
const string TT_LABEL_OFFSET = "ATR-based vertical offset that keeps state labels away from candle bodies and wicks."
const string TT_LABEL_SIZE = "Controls all chart label sizes, including centered zone badges. Normal is the recommended publication default."
const string TT_PANEL_SHOW = "Shows or hides the AG Pro planning panel. It is shown by default for public-release readability."
const string TT_PANEL_LOCATION = "Moves the AG Pro panel to the preferred chart location."
const string TT_PANEL_THEME = "Switches the panel between the premium AGPro dark theme, a slate variant, and a clean light theme."
const string TT_PANEL_SIZE = "Controls the font size used inside the AG Pro panel. Normal is the recommended publication default."
const string TT_ALERT = "Minimum Expansion Score required before alert conditions can trigger."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "CPR Expansion Engine"
string cprAnchor = input.string("Daily", "CPR Anchor", options = ["Daily", "Weekly"], group = groupEngine, tooltip = TT_ANCHOR)
string sideMode = input.string("Auto", "Expansion Side", options = ["Auto", "Bullish Only", "Bearish Only"], group = groupEngine, tooltip = TT_SIDE)
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Responsive", "Balanced", "Strict"], group = groupEngine, tooltip = TT_SENS)
int atrLength = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine, tooltip = TT_ATR)
int volumeLength = input.int(34, "Volume Baseline Length", minval = 5, maxval = 200, group = groupEngine, tooltip = TT_VOL)
int rangeLookback = input.int(20, "Range Context Lookback", minval = 5, maxval = 120, group = groupEngine, tooltip = TT_LOOKBACK)

string groupPlanner = "Planner Model"
string confirmationMode = input.string("Close Acceptance", "Confirmation Mode", options = ["Realtime Allowed", "Close Acceptance", "Close + Volume", "Strict"], group = groupPlanner, tooltip = TT_CONFIRM)
int readyThreshold = input.int(66, "READY Threshold", minval = 40, maxval = 95, group = groupPlanner, tooltip = TT_READY)
int watchThreshold = input.int(52, "WATCH Threshold", minval = 20, maxval = 90, group = groupPlanner, tooltip = TT_WATCH)
float cleanTargetRoomAtr = input.float(2.00, "Clean Target Room ATR", minval = 0.50, maxval = 8.00, step = 0.05, group = groupPlanner, tooltip = TT_TARGET)
float targetRangeMult = input.float(0.72, "Target Rail Prior Range Mult", minval = 0.20, maxval = 2.00, step = 0.02, group = groupPlanner, tooltip = TT_TARGET_RANGE)
float invalidationBufferAtr = input.float(0.22, "Invalidation Buffer ATR", minval = 0.00, maxval = 2.00, step = 0.01, group = groupPlanner, tooltip = TT_INVALID)
int baseAcceptedCloses = input.int(2, "Accepted Closes Needed", minval = 1, maxval = 8, group = groupPlanner, tooltip = TT_ACCEPT)
float followThroughRange = input.float(1.05, "Major Follow-Through Range Ratio", minval = 0.35, maxval = 3.00, step = 0.05, group = groupPlanner, tooltip = TT_RANGE)
int expansionWindow = input.int(20, "Expansion Proof Window (bars)", minval = 4, maxval = 200, group = groupPlanner, tooltip = TT_EXPWINDOW)

string groupVisual = "Chart Visuals"
bool showCprBand = input.bool(true, "Show CPR Band", group = groupVisual, tooltip = TT_CPR)
bool showExpansionRoom = input.bool(true, "Show Expansion Room", group = groupVisual, tooltip = TT_ROOM)
bool showPlannerRails = input.bool(true, "Show Invalidation / Target Rails", group = groupVisual, tooltip = TT_RAILS)
bool showCenteredZoneBadges = input.bool(true, "Show Centered Zone Badges", group = groupVisual, tooltip = TT_BADGES)
float zoneBadgeAnchor = input.float(0.62, "Zone Badge Anchor", minval = 0.20, maxval = 0.86, step = 0.02, group = groupVisual, tooltip = TT_BADGE_ANCHOR)
bool showEventLabels = input.bool(true, "Show State Labels", group = groupVisual, tooltip = TT_EVENTS)
bool showLabelScore = input.bool(true, "Show Label Score", group = groupVisual, tooltip = TT_SCORE_LABEL)
int labelCooldownBars = input.int(50, "Event Label Cooldown", minval = 1, maxval = 120, group = groupVisual, tooltip = TT_COOLDOWN)
int contextSpacingBars = input.int(40, "Watch Label Spacing", minval = 5, maxval = 180, group = groupVisual, tooltip = TT_CONTEXT)
int maxVisibleObjects = input.int(8, "Max Visible Labels", minval = 4, maxval = 80, group = groupVisual, tooltip = TT_MAX_OBJECTS)
int projectionBars = input.int(44, "Forward Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = TT_PROJECTION)
float labelOffsetAtr = input.float(1.00, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupVisual, tooltip = TT_LABEL_OFFSET)
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisual, tooltip = TT_LABEL_SIZE)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = TT_PANEL_SHOW)
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = TT_PANEL_LOCATION)
string panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Slate", "Light"], group = groupPanel, tooltip = TT_PANEL_THEME)
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel, tooltip = TT_PANEL_SIZE)

string groupAlerts = "Alerts"
int alertScoreThreshold = input.int(66, "Minimum Alert Score", minval = 40, maxval = 95, group = groupAlerts, tooltip = TT_ALERT)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_anchor_tf(string anchorInput) =>
    anchorInput == "Weekly" ? "W" : "D"

f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_norm_high_good(float value, float weakValue, float strongValue) =>
    float span = math.max(strongValue - weakValue, 0.000001)
    f_clamp((value - weakValue) / span * 100.0, 0.0, 100.0)

f_norm_low_good(float value, float strongValue, float weakValue) =>
    float span = math.max(weakValue - strongValue, 0.000001)
    f_clamp((weakValue - value) / span * 100.0, 0.0, 100.0)

f_text_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_text_on(color bgColor) =>
    float yiq = (color.r(bgColor) * 299.0 + color.g(bgColor) * 587.0 + color.b(bgColor) * 114.0) / 1000.0
    yiq >= 150.0 ? darkText : headerText

f_panel_pos(string locationInput) =>
    switch locationInput
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_fmt(float value) =>
    na(value) ? "-" : str.tostring(value, "#.##")

f_fmt_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_score_grade(float scoreValue) =>
    string grade = "D"
    if scoreValue >= 86
        grade := "A+"
    else if scoreValue >= 76
        grade := "A"
    else if scoreValue >= 66
        grade := "B"
    else if scoreValue >= 52
        grade := "C"
    grade

f_score_color(float scoreValue) =>
    color result = dangerColor
    if scoreValue >= 76
        result := bullColor
    else if scoreValue >= 66
        result := accentColor
    else if scoreValue >= 52
        result := neutralColor
    result

f_side_color(int dir) =>
    dir == 1 ? bullColor : dir == -1 ? bearColor : neutralColor

f_panel_bg() =>
    panelTheme == "Light" ? color.rgb(245, 247, 250) : panelTheme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_border() =>
    panelTheme == "Light" ? color.rgb(203, 213, 225) : panelBorder

f_panel_label_color() =>
    panelTheme == "Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value_color() =>
    panelTheme == "Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(bool evenRow) =>
    if panelTheme == "Light"
        evenRow ? color.rgb(241, 245, 249) : color.rgb(248, 250, 252)
    else if panelTheme == "Slate"
        evenRow ? color.rgb(51, 65, 85) : color.rgb(30, 41, 59)
    else
        evenRow ? color.rgb(20, 31, 52) : panelBg

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, string fontInput) =>
    color rowBg = f_row_bg(row % 2 == 0)
    table.cell(target, 0, row, leftText, text_color = f_panel_label_color(), bgcolor = rowBg, text_size = f_text_size(fontInput), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(fontInput), text_halign = text.align_right)

f_trim_labels(label[] labels, int maxCount) =>
    while array.size(labels) > maxCount
        label oldLabel = array.shift(labels)
        label.delete(oldLabel)

f_delete_label(label target) =>
    if not na(target)
        label.delete(target)

// -------------------------------------------------
// CPR Data
// -------------------------------------------------
string anchorTf = f_anchor_tf(cprAnchor)
float atr = ta.atr(atrLength)
float safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
float volBase = ta.sma(volume, volumeLength)
float relVolume = volBase > 0 ? volume / volBase : 1.0

float prevHigh = request.security(syminfo.tickerid, anchorTf, high[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
float prevLow = request.security(syminfo.tickerid, anchorTf, low[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
float prevClose = request.security(syminfo.tickerid, anchorTf, close[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
float anchorRangeAvg = request.security(syminfo.tickerid, anchorTf, ta.sma(high - low, rangeLookback)[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

bool newAnchor = timeframe.change(anchorTf)
var float anchorOpen = na
var float anchorHigh = na
var float anchorLow = na
var int anchorStartBar = na

if newAnchor or na(anchorOpen)
    anchorOpen := open
    anchorHigh := high
    anchorLow := low
    anchorStartBar := bar_index
else
    anchorHigh := math.max(anchorHigh, high)
    anchorLow := math.min(anchorLow, low)

bool validCpr = not na(prevHigh) and not na(prevLow) and not na(prevClose)
float pivot = validCpr ? (prevHigh + prevLow + prevClose) / 3.0 : na
float bc = validCpr ? (prevHigh + prevLow) / 2.0 : na
float tc = validCpr ? pivot * 2.0 - bc : na
float cprTop = validCpr ? math.max(tc, bc) : na
float cprBottom = validCpr ? math.min(tc, bc) : na
float cprMid = validCpr ? (cprTop + cprBottom) / 2.0 : na
float cprWidth = validCpr ? cprTop - cprBottom : na
float priorRange = validCpr ? math.max(prevHigh - prevLow, syminfo.mintick) : na
float currentRange = validCpr ? math.max(anchorHigh - anchorLow, syminfo.mintick) : na
float cprWidthAtr = validCpr ? cprWidth / safeAtr : na
float rangeExpansionRatio = validCpr ? currentRange / math.max(priorRange, safeAtr) : na
float safeAvgRange = validCpr ? math.max(na(anchorRangeAvg) ? priorRange : anchorRangeAvg, syminfo.mintick) : safeAtr

// -------------------------------------------------
// Direction, Score, and State
// -------------------------------------------------
int forcedDir = sideMode == "Bullish Only" ? 1 : sideMode == "Bearish Only" ? -1 : 0
int autoDir = 0
if validCpr
    if close > cprTop
        autoDir := 1
    else if close < cprBottom
        autoDir := -1
    else if anchorOpen > cprMid
        autoDir := 1
    else if anchorOpen < cprMid
        autoDir := -1
    else
        autoDir := close >= cprMid ? 1 : -1
int activeDir = validCpr ? (forcedDir != 0 ? forcedDir : autoDir) : 0
color sideColor = f_side_color(activeDir)

float widthWeak = sensitivity == "Strict" ? 0.74 : sensitivity == "Responsive" ? 1.10 : 0.92
float widthStrong = sensitivity == "Strict" ? 0.10 : sensitivity == "Responsive" ? 0.20 : 0.16
float widthScore = validCpr ? f_norm_low_good(cprWidthAtr, widthStrong, widthWeak) : 0.0

bool openInsideCpr = validCpr and anchorOpen <= cprTop and anchorOpen >= cprBottom
float openDistanceAtr = validCpr ? anchorOpen > cprTop ? (anchorOpen - cprTop) / safeAtr : anchorOpen < cprBottom ? (cprBottom - anchorOpen) / safeAtr : 0.0 : na
float openScore = validCpr ? openInsideCpr ? 100.0 : f_norm_low_good(openDistanceAtr, 0.0, sensitivity == "Strict" ? 0.72 : 1.10) : 0.0

bool beyondCpr = validCpr and (activeDir == 1 ? close > cprTop : activeDir == -1 ? close < cprBottom : false)
float beyondDistanceAtr = validCpr and activeDir == 1 ? (close - cprTop) / safeAtr : validCpr and activeDir == -1 ? (cprBottom - close) / safeAtr : 0.0
int acceptedClosesNeeded = sensitivity == "Responsive" ? math.max(baseAcceptedCloses - 1, 1) : sensitivity == "Strict" ? baseAcceptedCloses + 1 : baseAcceptedCloses
int acceptedBars = 0
acceptedBars := beyondCpr and activeDir == nz(activeDir[1]) ? nz(acceptedBars[1]) + 1 : beyondCpr ? 1 : 0
float acceptanceBarsScore = f_norm_high_good(acceptedBars, 0.0, acceptedClosesNeeded)
float distanceScore = f_norm_high_good(beyondDistanceAtr, 0.0, sensitivity == "Strict" ? 0.72 : 0.54)
float acceptanceScore = beyondCpr ? acceptanceBarsScore * 0.62 + distanceScore * 0.38 : 0.0

float rangeWeak = sensitivity == "Strict" ? 0.48 : sensitivity == "Responsive" ? 0.28 : 0.36
float rangeStrong = sensitivity == "Strict" ? 1.18 : sensitivity == "Responsive" ? 0.92 : 1.04
float rangeScore = validCpr ? f_norm_high_good(rangeExpansionRatio, rangeWeak, rangeStrong) : 0.0
float rangeContextScore = validCpr ? f_norm_high_good(currentRange, safeAvgRange * 0.70, safeAvgRange * 1.35) : 0.0
rangeScore := rangeScore * 0.72 + rangeContextScore * 0.28

float targetProjection = validCpr ? math.max(cleanTargetRoomAtr * safeAtr, math.max(priorRange * targetRangeMult, cprWidth * 5.0)) : na
float targetRail = validCpr and activeDir == 1 ? cprTop + targetProjection : validCpr and activeDir == -1 ? cprBottom - targetProjection : na
float invalidationRail = validCpr and activeDir == 1 ? cprBottom - safeAtr * invalidationBufferAtr : validCpr and activeDir == -1 ? cprTop + safeAtr * invalidationBufferAtr : na
float targetRoomAtr = validCpr and activeDir == 1 ? (targetRail - close) / safeAtr : validCpr and activeDir == -1 ? (close - targetRail) / safeAtr : na
float targetScore = validCpr ? f_norm_high_good(targetRoomAtr, 0.20, cleanTargetRoomAtr) : 0.0
bool targetBlocked = validCpr and targetRoomAtr < 0.35
bool targetExtended = validCpr and targetRoomAtr <= 0.0

bool closeGate = confirmationMode == "Realtime Allowed" ? true : barstate.isconfirmed
bool volumeGate = confirmationMode == "Close + Volume" or confirmationMode == "Strict" ? relVolume >= (sensitivity == "Strict" ? 1.10 : 0.92) : true
bool strictGate = confirmationMode == "Strict" ? rangeExpansionRatio >= 0.72 and targetRoomAtr >= 0.50 and widthScore >= 35 : true
bool acceptedConfirmed = beyondCpr and acceptedBars >= acceptedClosesNeeded and closeGate and volumeGate and strictGate

float rawScore = widthScore * 0.24 + openScore * 0.16 + acceptanceScore * 0.25 + rangeScore * 0.18 + targetScore * 0.17
float expansionScore = math.round(f_clamp(rawScore, 0.0, 100.0))

bool invalidationRisk = validCpr and (activeDir == 1 ? close < invalidationRail : activeDir == -1 ? close > invalidationRail : false)
bool readyState = validCpr and acceptedConfirmed and expansionScore >= readyThreshold and not invalidationRisk and not targetBlocked
bool watchState = validCpr and not readyState and not invalidationRisk and beyondCpr and expansionScore >= watchThreshold
bool roomBlockedState = validCpr and not invalidationRisk and beyondCpr and targetBlocked and not targetExtended and expansionScore >= watchThreshold
bool majorFollowThrough = validCpr and acceptedConfirmed and rangeExpansionRatio >= followThroughRange and expansionScore >= alertScoreThreshold

var int lastReadyDir = 0
bool confirmedShift = readyState and lastReadyDir != 0 and lastReadyDir != activeDir
if readyState
    lastReadyDir := activeDir

string stateText = "Wait"
if invalidationRisk
    stateText := "Invalid Risk"
else if readyState
    stateText := "Ready"
else if targetExtended
    stateText := "Extended"
else if roomBlockedState
    stateText := "Room Blocked"
else if watchState
    stateText := "Watch"

color stateColor = stateText == "Ready" ? sideColor : stateText == "Watch" ? accentColor : stateText == "Room Blocked" or stateText == "Extended" ? neutralColor : stateText == "Invalid Risk" ? dangerColor : f_panel_value_color()
string sideText = activeDir == 1 ? "Bull" : activeDir == -1 ? "Bear" : "-"
string widthText = validCpr ? (cprWidthAtr <= 0.28 ? "Narrow" : cprWidthAtr <= 0.72 ? "Balanced" : "Wide") + " " + f_fmt(cprWidthAtr) + " ATR" : "-"
string scoreText = validCpr ? str.tostring(expansionScore, "#") + "/100 " + f_score_grade(expansionScore) : "-"
string actionText = "Wait for CPR acceptance"
if invalidationRisk
    actionText := "Review invalidation"
else if readyState
    actionText := activeDir == 1 ? "Plan bull expansion" : "Plan bear expansion"
else if targetExtended
    actionText := "Manage extension"
else if roomBlockedState
    actionText := "Avoid late chase"
else if watchState
    actionText := "Monitor acceptance"

// -------------------------------------------------
// Expansion follow-through proof (Confirm Rate)
// -------------------------------------------------
// When a Ready expansion fires, does price follow through 0.75 ATR in the
// accepted direction before reaching the invalidation shelf or the window
// expires? Counted once per Ready. An invalidation first, or a window expiry
// with no follow-through, is treated as not-followed (conservative).
var int   exTotal = 0
var int   exWon    = 0
var bool  exPend    = false
var int   exDir      = 0
var float exAnchor    = na
var float exInval      = na
var float exMargin     = na
var int   exLeft        = 0
bool readyFire = barstate.isconfirmed and readyState and not readyState[1]
bool invalidFire = barstate.isconfirmed and invalidationRisk and not invalidationRisk[1]
bool followFire = barstate.isconfirmed and majorFollowThrough and not majorFollowThrough[1]
bool roomFire = barstate.isconfirmed and roomBlockedState and not roomBlockedState[1]
bool shiftFire = barstate.isconfirmed and confirmedShift

if barstate.isconfirmed
    if exPend and not na(exAnchor) and not na(exInval)
        bool exFailed = exDir > 0 ? close < exInval : close > exInval
        bool exFollowed = exDir > 0 ? close >= exAnchor + exMargin : close <= exAnchor - exMargin
        if exFailed
            exTotal += 1
            exPend := false
        else if exFollowed
            exTotal += 1
            exWon += 1
            exPend := false
        else
            exLeft -= 1
            if exLeft <= 0
                exTotal += 1
                exPend := false
    if readyFire and activeDir != 0 and not na(invalidationRail) and not exPend
        exDir := activeDir
        exAnchor := close
        exInval := invalidationRail
        exMargin := math.max(nz(safeAtr), syminfo.mintick) * 0.75
        exLeft := expansionWindow
        exPend := true

float exRate = exTotal > 0 ? exWon / exTotal * 100.0 : na
string expansionRateRead = exTotal > 0 ? str.tostring(math.round(exRate)) + "% (" + str.tostring(exTotal) + ")" : "Building"

// -------------------------------------------------
// Visual Objects
// -------------------------------------------------
var box cprBox = na
var label cprBadge = na
var box roomBox = na
var label roomBadge = na
var line invalidLine = na
var line targetLine = na
var label invalidRailLabel = na
var label targetRailLabel = na
var label[] stateLabels = array.new_label()
var int lastEventLabelBar = na
var int lastWatchLabelBar = na

int visualLeft = math.max(nz(anchorStartBar, bar_index), 0)
int visualRight = bar_index + projectionBars
int visualBadgeX = visualLeft + int(math.round((visualRight - visualLeft) * zoneBadgeAnchor))

if showCprBand and validCpr and barstate.islast
    color cprFill = color.new(stateColor, stateText == "Ready" ? 84 : 89)
    color cprBorder = color.new(stateColor, stateText == "Wait" ? 45 : 20)
    string cprText = "CPR | " + str.upper(stateText) + " | W " + f_fmt(cprWidthAtr) + " ATR"
    if stateText == "Ready"
        cprText := "CPR | ACCEPTED | W " + f_fmt(cprWidthAtr) + " ATR"
    else if stateText == "Watch"
        cprText := "CPR | WATCH | W " + f_fmt(cprWidthAtr) + " ATR"
    else if stateText == "Invalid Risk"
        cprText := "CPR | FAILED | W " + f_fmt(cprWidthAtr) + " ATR"
    if na(cprBox)
        cprBox := box.new(visualLeft, cprTop, visualRight, cprBottom, xloc = xloc.bar_index, bgcolor = cprFill, border_color = cprBorder, border_width = 1)
    else
        box.set_lefttop(cprBox, visualLeft, cprTop)
        box.set_rightbottom(cprBox, visualRight, cprBottom)
        box.set_bgcolor(cprBox, cprFill)
        box.set_border_color(cprBox, cprBorder)
    if showCenteredZoneBadges
        if na(cprBadge)
            cprBadge := label.new(visualBadgeX, cprMid, cprText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(stateColor, 10), textcolor = f_text_on(stateColor), size = f_text_size(labelFontSize), textalign = text.align_center)
        else
            label.set_xy(cprBadge, visualBadgeX, cprMid)
            label.set_text(cprBadge, cprText)
            label.set_color(cprBadge, color.new(stateColor, 10))
            label.set_textcolor(cprBadge, f_text_on(stateColor))
            label.set_size(cprBadge, f_text_size(labelFontSize))
    else
        f_delete_label(cprBadge)
        cprBadge := na
else
    if not na(cprBox)
        box.delete(cprBox)
        cprBox := na
    f_delete_label(cprBadge)
    cprBadge := na

if showExpansionRoom and validCpr and activeDir != 0 and barstate.islast
    float roomTop = activeDir == 1 ? targetRail : cprBottom
    float roomBottom = activeDir == 1 ? cprTop : targetRail
    float roomMid = (roomTop + roomBottom) / 2.0
    color roomFill = color.new(sideColor, stateText == "Ready" ? 88 : 92)
    color roomBorder = color.new(sideColor, targetBlocked ? 65 : 35)
    string roomText = (activeDir == 1 ? "BULL" : "BEAR") + " | " + str.upper(stateText) + " | Q " + str.tostring(expansionScore, "#") + " | ROOM " + f_fmt(targetRoomAtr) + " ATR"
    if targetExtended
        roomText := (activeDir == 1 ? "BULL" : "BEAR") + " | EXTENDED | Q " + str.tostring(expansionScore, "#")
    if na(roomBox)
        roomBox := box.new(visualLeft, roomTop, visualRight, roomBottom, xloc = xloc.bar_index, bgcolor = roomFill, border_color = roomBorder, border_width = 1)
    else
        box.set_lefttop(roomBox, visualLeft, roomTop)
        box.set_rightbottom(roomBox, visualRight, roomBottom)
        box.set_bgcolor(roomBox, roomFill)
        box.set_border_color(roomBox, roomBorder)
    if showCenteredZoneBadges
        if na(roomBadge)
            roomBadge := label.new(visualBadgeX, roomMid, roomText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(sideColor, 14), textcolor = f_text_on(sideColor), size = f_text_size(labelFontSize), textalign = text.align_center)
        else
            label.set_xy(roomBadge, visualBadgeX, roomMid)
            label.set_text(roomBadge, roomText)
            label.set_color(roomBadge, color.new(sideColor, 14))
            label.set_textcolor(roomBadge, f_text_on(sideColor))
            label.set_size(roomBadge, f_text_size(labelFontSize))
    else
        f_delete_label(roomBadge)
        roomBadge := na
else
    if not na(roomBox)
        box.delete(roomBox)
        roomBox := na
    f_delete_label(roomBadge)
    roomBadge := na

if showPlannerRails and validCpr and activeDir != 0 and barstate.islast
    color railColor = invalidationRisk ? dangerColor : color.new(sideColor, 0)
    if na(invalidLine)
        invalidLine := line.new(visualLeft, invalidationRail, visualRight, invalidationRail, xloc = xloc.bar_index, extend = extend.none, color = railColor, style = line.style_dashed, width = 2)
    else
        line.set_xy1(invalidLine, visualLeft, invalidationRail)
        line.set_xy2(invalidLine, visualRight, invalidationRail)
        line.set_color(invalidLine, railColor)
    if na(targetLine)
        targetLine := line.new(visualLeft, targetRail, visualRight, targetRail, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 0), style = line.style_dotted, width = 2)
    else
        line.set_xy1(targetLine, visualLeft, targetRail)
        line.set_xy2(targetLine, visualRight, targetRail)
        line.set_color(targetLine, color.new(accentColor, 0))
    color invalRailBg = color.new(railColor, 0)
    if na(invalidRailLabel)
        invalidRailLabel := label.new(visualRight + 2, invalidationRail, "INVALID " + f_fmt_price(invalidationRail), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = invalRailBg, textcolor = f_text_on(railColor), size = f_text_size(labelFontSize))
    else
        label.set_xy(invalidRailLabel, visualRight + 2, invalidationRail)
        label.set_text(invalidRailLabel, "INVALID " + f_fmt_price(invalidationRail))
        label.set_color(invalidRailLabel, invalRailBg)
        label.set_textcolor(invalidRailLabel, f_text_on(railColor))
        label.set_size(invalidRailLabel, f_text_size(labelFontSize))
    if na(targetRailLabel)
        targetRailLabel := label.new(visualRight + 14, targetRail, "TARGET " + f_fmt_price(targetRail), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 0), textcolor = f_text_on(accentColor), size = f_text_size(labelFontSize))
    else
        label.set_xy(targetRailLabel, visualRight + 14, targetRail)
        label.set_text(targetRailLabel, "TARGET " + f_fmt_price(targetRail))
        label.set_color(targetRailLabel, color.new(accentColor, 0))
        label.set_textcolor(targetRailLabel, f_text_on(accentColor))
        label.set_size(targetRailLabel, f_text_size(labelFontSize))
else
    if not na(invalidLine)
        line.delete(invalidLine)
        invalidLine := na
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na
    f_delete_label(invalidRailLabel)
    invalidRailLabel := na
    f_delete_label(targetRailLabel)
    targetRailLabel := na

// -------------------------------------------------
// Historical State Labels
// -------------------------------------------------
bool eventCooldownReady = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
bool watchCooldownReady = (na(lastWatchLabelBar) or bar_index - lastWatchLabelBar >= contextSpacingBars) and (na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars)
bool readyEvent = showEventLabels and readyFire and eventCooldownReady
bool shiftEvent = showEventLabels and shiftFire and eventCooldownReady
bool invalidEvent = showEventLabels and invalidFire and activeDir != 0 and eventCooldownReady
bool followEvent = showEventLabels and followFire and eventCooldownReady
bool roomEvent = showEventLabels and roomFire and eventCooldownReady
bool watchEvent = showEventLabels and watchState and watchCooldownReady and not readyEvent and not shiftEvent and not invalidEvent and not followEvent and not roomEvent

if readyEvent or shiftEvent or invalidEvent or followEvent or roomEvent or watchEvent
    string labelState = invalidEvent ? "Invalid" : shiftEvent ? "Shift" : followEvent ? "Follow" : roomEvent ? "Room" : readyEvent ? "Ready" : "Watch"
    string labelScore = showLabelScore ? " | " + str.tostring(expansionScore, "#") + "/100" : ""
    string labelText = str.upper(labelState) + labelScore
    color labelColor = invalidEvent ? dangerColor : roomEvent or followEvent ? neutralColor : readyEvent or shiftEvent ? sideColor : accentColor
    float labelY = activeDir == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    labelStyle = activeDir == 1 ? label.style_label_up : label.style_label_down
    label newLabel = label.new(bar_index, labelY, labelText, xloc = xloc.bar_index, yloc = yloc.price, style = labelStyle, color = color.new(labelColor, 0), textcolor = f_text_on(labelColor), size = f_text_size(labelFontSize), textalign = text.align_center)
    array.push(stateLabels, newLabel)
    f_trim_labels(stateLabels, maxVisibleObjects)
    if watchEvent
        lastWatchLabelBar := bar_index
    else
        lastEventLabelBar := bar_index

// -------------------------------------------------
// Data Window
// -------------------------------------------------
plot(expansionScore, title = "Expansion Score", color = f_score_color(expansionScore), display = display.data_window)
plot(exRate, title = "Expansion Follow Rate", color = bullColor, display = display.data_window)

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table infoPanel = table.new(position.top_right, 2, 7, bgcolor = panelBg, frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)

if barstate.islast
    table.set_position(infoPanel, f_panel_pos(panelLocation))
    table.clear(infoPanel, 0, 0, 1, 6)
    if showPanel
        color panelBorderActive = f_panel_border()
        color expansionRateCol = na(exRate) ? f_panel_value_color() : exRate >= 60.0 ? bullColor : exRate >= 45.0 ? neutralColor : bearColor
        table.set_frame_color(infoPanel, panelBorderActive)
        table.set_border_color(infoPanel, panelBorderActive)
        table.cell(infoPanel, 0, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize))
        table.cell(infoPanel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize))
        table.merge_cells(infoPanel, 0, 0, 1, 0)
        table.cell(infoPanel, 0, 0, "AG Pro CPR Expansion Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        string sidePanelText = validCpr ? sideText + " " + stateText : "-"
        string invalidPanelText = validCpr ? invalidationRisk ? "Hit " + f_fmt_price(invalidationRail) : f_fmt_price(invalidationRail) : "-"
        f_panel_row(infoPanel, 1, "CPR Width", widthText, widthScore >= 68 ? bullColor : widthScore >= 45 ? neutralColor : dangerColor, panelFontSize)
        f_panel_row(infoPanel, 2, "Accepted Side", sidePanelText, stateColor, panelFontSize)
        f_panel_row(infoPanel, 3, "Expansion Score", scoreText, f_score_color(expansionScore), panelFontSize)
        f_panel_row(infoPanel, 4, "Expansion Rate", expansionRateRead, expansionRateCol, panelFontSize)
        f_panel_row(infoPanel, 5, "Invalidation", invalidPanelText, invalidationRisk ? dangerColor : f_panel_value_color(), panelFontSize)
        f_panel_row(infoPanel, 6, "Action", actionText, stateColor, panelFontSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
bool alertReady = readyFire and expansionScore >= alertScoreThreshold
bool alertShift = shiftFire and expansionScore >= alertScoreThreshold
bool alertInvalid = invalidFire and activeDir != 0
bool alertFollow = followFire
bool alertRoomBlocked = roomFire and expansionScore >= watchThreshold

alertcondition(alertReady and activeDir == 1, "Bullish CPR Expansion Ready", "CPR Expansion Planner: bullish CPR expansion is in Ready state. This is an attention marker, not a trade instruction.")
alertcondition(alertReady and activeDir == -1, "Bearish CPR Expansion Ready", "CPR Expansion Planner: bearish CPR expansion is in Ready state. This is an attention marker, not a trade instruction.")
alertcondition(alertShift, "CPR Accepted Side Shift", "CPR Expansion Planner: accepted side shifted after a prior ready state. This is an attention marker, not a trade instruction.")
alertcondition(alertInvalid, "CPR Invalidation Risk", "CPR Expansion Planner: price reached the active CPR invalidation shelf. This is an attention marker, not a trade instruction.")
alertcondition(alertFollow, "CPR Major Follow-Through", "CPR Expansion Planner: range expansion and CPR acceptance reached major follow-through conditions. This is an attention marker, not a trade instruction.")
alertcondition(alertRoomBlocked, "CPR Target Room Blocked", "CPR Expansion Planner: CPR acceptance exists but target room is limited or already extended. This is an attention marker, not a trade instruction.")
````
