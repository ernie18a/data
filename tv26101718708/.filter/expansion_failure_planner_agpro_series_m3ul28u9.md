# Expansion Failure Planner [AGPro Series]

- url: https://www.tradingview.com/script/M3UL28u9-Expansion-Failure-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;0a84d621669743bc934ee6cc0dab7c2e
- version: 5.0

## Description

Expansion Failure Planner [AGPro Series]

🧠 Core Idea

Did volatility expansion create real travel, or did it fail back inside the prior structure?

📌 Overview / What it does

Expansion Failure Planner is a public-free TradingView indicator built to evaluate failed volatility expansion attempts. It detects when price expands beyond a recent range edge, then tracks whether the move produces meaningful travel or quickly loses the edge.

The script produces a failed expansion corridor, expansion-edge guide, risk shelf, return-to-range target guide, compact state labels, alerts, and a clean AG Pro planning panel. It does not predict future price direction or automate trade decisions.

🎯 Purpose & Design Philosophy

This script was built for traders who do not only want to see that volatility expanded. They want to know whether the expansion still has quality, whether failure risk is rising, and what context should be reviewed next.

The design supports a decision-first workflow: identify the expansion attempt, measure failure risk, review target room, and decide whether the context deserves attention.

⚡ Why This Script Is Different

Most volatility tools focus on expansion, squeeze release, or breakout continuation.

This script does NOT act as a generic breakout signal, generic S/R zone, or continuation-only volatility map.

Instead, it focuses on one narrow question: did the expansion fail before producing real travel?

⚙️ Methodology

1. Context Detection
The script defines a prior range and watches for a volatility expansion attempt beyond that range edge.

2. Reference Mapping
It stores the expansion edge, expansion extreme, prior range midpoint, and return-to-range target area.

3. Reaction Evaluation
The planner scores failed travel using ATR expansion, close-back-inside behavior, missing follow-through, volume response, and range re-entry quality.

4. Visual Output
It draws the failed expansion corridor, expansion edge, risk shelf, return target, compact labels, and a premium AG Pro panel.

🗺️ How to Read the Chart

Zones = the failed expansion corridor between the original edge and the expansion extreme.

Labels = expansion attempts, failure-ready states, watch states, hold states, and reset context.

Colors = teal for upside expansion attempts, pink for downside expansion attempts, yellow for watch context, and indigo for edge/hold review.

Panel = the preferred viewing timeframe, current expansion state, 0-100 failure risk, reclaim status, target room, and next action.

🚦 Signals & States

• UP EXP / DN EXP → a volatility expansion attempt has been detected.

• UP FAIL / DN FAIL → the expansion failed back inside the prior structure with enough score.

• WATCH → failure risk is developing but confirmation is incomplete.

• HOLD → expansion is still holding beyond the edge.

• RESET / NO FAIL → the active failure window expired or real travel invalidated the failure context.

🔔 Alerts Logic

Alerts trigger when expansion failure reaches ready status, when watch context develops, when expansion holds beyond the edge, or when the failure window resets.

Alerts are attention markers only. They are not trade instructions.

🧩 Confluence Logic

The strongest context appears when ATR expansion, edge loss, missing follow-through, range re-entry, and participation align. When these components agree, the failure risk score increases.

📊 When to Use

• After volatility expansion attempts
• Around range-edge probes
• During breakout failure review
• When a move expands but does not travel
• When price quickly returns inside prior structure

⚠️ When NOT to Use

• Extremely low-liquidity symbols
• Very noisy micro ranges
• News-driven candles with abnormal gaps
• Markets where volume data is unreliable
• Charts where the prior range is not structurally meaningful

🎛️ Key Inputs

• Sensitivity → changes how strict the failure model is.
• Prior Range Lookback → defines the structure used for expansion reference.
• Expansion Bar ATR → controls how large a candle must be to qualify.
• Required Real Travel ATR → defines how much progress the expansion should produce.
• Confirmation Mode → controls close/volume/strict confirmation.
• Visual Settings → control corridor, guides, labels, projection, and label size.
• Panel Settings → control panel visibility, location, theme, font size, and best-viewed timeframe guidance.

🖥️ Interface & Visual Design

The panel is designed as a compact planning cockpit. The first row uses the AGPro merged blue header standard, while the remaining rows show best-viewed timeframe guidance, state, score, reclaim status, target room, and action.

The visual hierarchy keeps the chart readable: one active corridor, clear guide lines, and controlled labels.

🧪 Practical Usage Workflow

1. Read the panel state.
2. Check whether price is above or below the expansion edge.
3. Review the failed expansion corridor.
4. Compare failure risk with target room.
5. Use alerts as attention markers, not decisions.

🔍 Interpretation Guidelines

Think in terms of failed travel, not prediction. A high score means the script detected stronger failure characteristics. A low score means expansion may still be holding, or failure evidence is not strong enough.

🚫 What This Script Is NOT

• Not a prediction engine
• Not financial advice
• Not auto trading
• Not guaranteed signals
• Not a generic breakout indicator
• Not a generic support/resistance zone map

⚠️ Limitations & Transparency

• Timeframe differences can change expansion and failure structure.
• Volatility spikes can distort ATR-based scoring.
• Volume quality varies by market.
• Fast markets can move beyond the corridor before confirmation.
• Outputs should be interpreted within broader market context.

🧠 Market Context Notes

Expansion failure often matters when volatility appears strong but cannot create distance. This script focuses on that transition point between momentum attempt and failed travel.

🧾 Use Case Examples

When price expands above a range, stalls quickly, closes back inside the edge, and fails to build distance, the planner can mark an upside expansion failure.

When price expands below a range, loses downside follow-through, and re-enters the structure, the planner can mark a downside expansion failure.

🧱 System Philosophy

AGPro tools are built to reduce chart ambiguity by turning raw market events into structured decision context.

🔐 Non-Promise Statement

No indicator can provide certainty. This script provides rule-based context only.

📉 Risk Disclosure

Trading involves risk. Users are responsible for their own decisions. This script does not provide financial advice or guaranteed trading outcomes.

📚 Educational Note

Use the script as a structured learning and review tool for expansion failure behavior, failed travel, and volatility response.

## Source Code

````pine
// -------------------------------------------------
// Expansion Failure Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Expansion Failure Planner is a chart-first volatility failure map. It
// detects strong range expansion attempts, then evaluates whether the move
// created real travel or failed back inside the prior structure. The script
// maps the failed expansion corridor, risk shelf, return target, 0-100
// failure score, and next-action context without becoming a generic breakout
// signal or a continuation-only volatility tool. Version 1.4 adds a confirmation-
// anchored proof layer (Follow, Hold, React, Flip rates) that shows how often
// flagged expansion attempts returned inside before the risk shelf was breached.
// -------------------------------------------------

//@version=6
indicator("Expansion Failure Planner [AGPro Series]",
     shorttitle = "AG Pro EFP",
     overlay = true,
     max_labels_count = 220,
     max_boxes_count = 80,
     max_lines_count = 90)

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
const string TT_SIDE = "Selects which expansion attempts can be evaluated. Auto allows both sides, while manual modes restrict the planner to failed upside or failed downside expansion."
const string TT_SENS = "Controls how strict the expansion-failure model is. Responsive finds earlier failures, Balanced is the publication default, and Strict requires cleaner range re-entry."
const string TT_LOOKBACK = "Lookback used to define the prior structure that price attempts to expand beyond. The current bar is excluded from this reference."
const string TT_ATR = "ATR normalizes expansion size, failure distance, risk shelf spacing, target room, and label offsets across symbols."
const string TT_ATR_BASE = "Longer ATR baseline used to judge whether volatility is expanding relative to recent conditions."
const string TT_VOLUME = "Volume baseline used to judge whether the failure response has participation. On symbols with unreliable volume this component should be interpreted as context."
const string TT_EMA = "EMA used only for directional context after expansion. It does not create standalone entry or exit signals."
const string TT_BAR_EXP = "Minimum candle range, measured in ATR, required before a bar can be treated as an expansion attempt."
const string TT_EDGE_BREAK = "Minimum probe beyond the prior range edge, measured in ATR, required before the planner can track an expansion attempt."
const string TT_REAL_TRAVEL = "Minimum travel beyond the expansion edge expected before the move is considered productive. Failure risk rises when travel stays below this level."
const string TT_REENTRY = "ATR buffer back inside the prior edge required for stronger range re-entry evidence."
const string TT_WINDOW = "Number of bars after an expansion attempt where failed travel, re-entry, and reclaim behavior are evaluated."
const string TT_CONFIRM = "Defines how strict labels and alerts are. Realtime Allowed can update intrabar, Close Failure waits for closed bars, Close + Volume requires participation, and Strict adds stronger travel-loss checks."
const string TT_READY = "Minimum 0-100 Failure Risk score required before the planner can mark an expansion-failure review context."
const string TT_WATCH = "Minimum 0-100 Failure Risk score required before the planner can mark a return-watch context."
const string TT_VOL_LEVEL = "Relative volume level used by Close + Volume and Strict confirmation modes."
const string TT_CORRIDOR = "Shows the failed expansion corridor with a centered contrast-safe inner zone tag. The zone name stays inside the corridor and remains readable on light and dark charts."
const string TT_EDGE = "Shows the original expansion edge from the prior range. This is the key reference for failure or continuation review."
const string TT_RISK = "Shows the risk shelf beyond the expansion extreme. It is a planning reference for invalidation review, not a trade instruction."
const string TT_TARGET = "Shows the return-to-range target guide used to evaluate target room after failure."
const string TT_GUIDE_TAGS = "Shows compact right-side tags attached to the expansion edge, risk shelf, and return target guide lines."
const string TT_RIGHT_OFFSET = "Moves guide tags to the right while extending their reference lines to the same x-position so tags clearly point to real levels."
const string TT_LABELS = "Shows compact expansion failure, watch, and hold labels on the chart."
const string TT_ATTEMPT_LABELS = "Shows the first UP EXP or DN EXP label for a fresh expansion attempt. Enabled by default so the chart keeps enough event context between active corridors."
const string TT_RESET_LABELS = "Shows RESET and NO FAIL labels when an expansion-failure window expires or real travel invalidates the failure idea. Disabled by default for a cleaner publication preset."
const string TT_CONTEXT = "Adds sparse context labels while an expansion attempt remains active so the chart has useful information without becoming crowded."
const string TT_SCORE_LABEL = "Adds the 0-100 Failure Risk score to chart labels."
const string TT_COOLDOWN = "Minimum number of bars between event labels. Higher values reduce clustering."
const string TT_CONTEXT_SPACING = "Minimum spacing between lighter context labels during active expansion windows."
const string TT_MAX_OBJECTS = "Maximum number of visible chart labels retained by the script. Older labels are deleted first for performance."
const string TT_PROJECTION = "Number of bars projected to the right for the corridor, expansion edge, risk shelf, and target guide."
const string TT_ZONE_MEMORY = "Number of completed expansion corridors kept as visible memory zones. This preserves chart story after the active evaluation window closes."
const string TT_OFFSET = "ATR-based label offset that keeps labels away from candle bodies and wicks."
const string TT_LABEL_SIZE = "Controls all chart label sizes and the centered inner corridor tag. Normal is the recommended public-release default."
const string TT_PANEL_SHOW = "Shows or hides the AG Pro planning panel. It is enabled by default for public-release readability."
const string TT_PANEL_LOCATION = "Moves the AG Pro panel to the preferred chart location."
const string TT_PANEL_THEME = "Switches the panel between the premium AGPro dark theme and a clean light theme."
const string TT_PANEL_SIZE = "Controls the font size used inside the AG Pro panel. Normal is the recommended publication default."
const string TT_BEST_VIEWED = "Adds a compact timeframe guidance row to the AG Pro panel. It is informational only and does not change the script logic."
const string TT_ALERT = "Minimum Failure Risk score required before alert conditions can trigger."
const string TT_SHOWPROOF = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across flagged expansion attempts on the current symbol and timeframe. Follow means the failure fade advanced one risk unit (1R) inside, or reached the range mid if it was closer, before the risk shelf was breached. These are historical outcome rates, not predictions."
const string TT_PROOF_HORIZON = "Maximum number of bars each flagged expansion attempt is tracked for the proof measurement before it resolves at its current outcome."
const string TT_REACT_BARS = "Number of bars after an attempt is flagged used to detect an immediate favorable return reaction."
const string TT_REACT_PROGRESS = "Minimum favorable return progress toward the range mid, within the reaction window, required to count as an early React."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Expansion Failure Engine"
string sideMode = input.string("Auto", "Expansion Side", options = ["Auto", "Failed Upside", "Failed Downside"], group = groupEngine, tooltip = TT_SIDE)
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Responsive", "Balanced", "Strict"], group = groupEngine, tooltip = TT_SENS)
int rangeLookback = input.int(34, "Prior Range Lookback", minval = 10, maxval = 240, group = groupEngine, tooltip = TT_LOOKBACK)
int atrLength = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine, tooltip = TT_ATR)
int atrBaselineLength = input.int(55, "ATR Expansion Baseline", minval = 10, maxval = 300, group = groupEngine, tooltip = TT_ATR_BASE)
int volumeLength = input.int(34, "Volume Baseline Length", minval = 5, maxval = 200, group = groupEngine, tooltip = TT_VOLUME)
int contextEmaLength = input.int(34, "Context EMA Length", minval = 3, maxval = 240, group = groupEngine, tooltip = TT_EMA)

string groupModel = "Failure Score Model"
float expansionBarAtr = input.float(1.35, "Expansion Bar ATR", minval = 0.40, maxval = 5.00, step = 0.05, group = groupModel, tooltip = TT_BAR_EXP)
float edgeBreakAtr = input.float(0.18, "Edge Probe ATR", minval = 0.01, maxval = 2.00, step = 0.01, group = groupModel, tooltip = TT_EDGE_BREAK)
float realTravelAtr = input.float(0.85, "Required Real Travel ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupModel, tooltip = TT_REAL_TRAVEL)
float reentryBufferAtr = input.float(0.10, "Range Re-entry Buffer ATR", minval = 0.00, maxval = 1.50, step = 0.01, group = groupModel, tooltip = TT_REENTRY)
int failureWindowBars = input.int(18, "Failure Evaluation Window", minval = 3, maxval = 90, group = groupModel, tooltip = TT_WINDOW)
string confirmationMode = input.string("Close Failure", "Confirmation Mode", options = ["Realtime Allowed", "Close Failure", "Close + Volume", "Strict"], group = groupModel, tooltip = TT_CONFIRM)
int readyThreshold = input.int(68, "Review Failure Threshold", minval = 40, maxval = 95, group = groupModel, tooltip = TT_READY)
int watchThreshold = input.int(52, "Return Watch Threshold", minval = 20, maxval = 90, group = groupModel, tooltip = TT_WATCH)
float volumeSupportLevel = input.float(1.05, "Failure Volume Support", minval = 0.40, maxval = 3.00, step = 0.05, group = groupModel, tooltip = TT_VOL_LEVEL)

string groupVisual = "Chart Visuals"
bool showFailureCorridor = input.bool(true, "Show Failed Expansion Corridor", group = groupVisual, tooltip = TT_CORRIDOR)
bool showExpansionEdge = input.bool(true, "Show Expansion Edge", group = groupVisual, tooltip = TT_EDGE)
bool showRiskShelf = input.bool(true, "Show Risk Shelf", group = groupVisual, tooltip = TT_RISK)
bool showReturnTarget = input.bool(true, "Show Return Target", group = groupVisual, tooltip = TT_TARGET)
bool showGuideTags = input.bool(true, "Show Guide Tags", group = groupVisual, tooltip = TT_GUIDE_TAGS)
int rightTagOffsetBars = input.int(8, "Guide Tag Offset Bars", minval = 0, maxval = 80, group = groupVisual, tooltip = TT_RIGHT_OFFSET)
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupVisual, tooltip = TT_LABELS)
bool showAttemptLabels = input.bool(true, "Show Attempt Labels", group = groupVisual, tooltip = TT_ATTEMPT_LABELS)
bool showResetLabels = input.bool(false, "Show Reset Labels", group = groupVisual, tooltip = TT_RESET_LABELS)
bool showContextLabels = input.bool(true, "Show Sparse Context Labels", group = groupVisual, tooltip = TT_CONTEXT)
bool showLabelScore = input.bool(true, "Show Label Score", group = groupVisual, tooltip = TT_SCORE_LABEL)
int labelCooldownBars = input.int(24, "Event Label Cooldown", minval = 1, maxval = 120, group = groupVisual, tooltip = TT_COOLDOWN)
int contextSpacingBars = input.int(46, "Context Label Spacing", minval = 5, maxval = 180, group = groupVisual, tooltip = TT_CONTEXT_SPACING)
int maxVisibleLabels = input.int(8, "Max Visible Labels", minval = 4, maxval = 80, group = groupVisual, tooltip = TT_MAX_OBJECTS)
int projectionBars = input.int(30, "Forward Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = TT_PROJECTION)
int maxVisibleZones = input.int(2, "Max Visible Zones", minval = 1, maxval = 12, group = groupVisual, tooltip = TT_ZONE_MEMORY)
float labelOffsetAtr = input.float(0.95, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupVisual, tooltip = TT_OFFSET)
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual, tooltip = TT_LABEL_SIZE)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = TT_PANEL_SHOW)
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = TT_PANEL_LOCATION)
string panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = TT_PANEL_THEME)
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = TT_PANEL_SIZE)
string bestViewed = input.string("4H", "Best Viewed", options = ["1H", "4H", "4H - 1D", "1D", "Any"], group = groupPanel, tooltip = TT_BEST_VIEWED)

string groupProof = "Proof"
bool showProof = input.bool(true, "Show Proof Layer", group = groupProof, tooltip = TT_SHOWPROOF)
int proofHorizonBars = input.int(30, "Proof Horizon Bars", minval = 5, maxval = 240, group = groupProof, tooltip = TT_PROOF_HORIZON)
int reactBars = input.int(4, "Reaction Window Bars", minval = 1, maxval = 60, group = groupProof, tooltip = TT_REACT_BARS)
float reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = groupProof, tooltip = TT_REACT_PROGRESS)

string groupAlerts = "Alerts"
int alertScoreThreshold = input.int(68, "Minimum Alert Score", minval = 40, maxval = 95, group = groupAlerts, tooltip = TT_ALERT)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
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
        => size.normal

f_zone_tag_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

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

f_fmt_int(float value) =>
    na(value) ? "-" : str.tostring(math.round(value))

f_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(float value) =>
    value >= 55 ? bullColor : value >= 40 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30 ? bullColor : value <= 55 ? neutralColor : bearColor

f_grade(float scoreValue) =>
    string result = "D"
    if scoreValue >= 86
        result := "A+"
    else if scoreValue >= 76
        result := "A"
    else if scoreValue >= 64
        result := "B"
    else if scoreValue >= 52
        result := "C"
    result

f_score_color(float scoreValue) =>
    color result = dangerColor
    if scoreValue >= readyThreshold
        result := bullColor
    else if scoreValue >= watchThreshold
        result := neutralColor
    else if scoreValue >= 40
        result := accentColor
    result

f_workflow_text(bool hasEvent, bool ready, bool watch, bool holds) =>
    string result = "WAIT EXPANSION"
    if hasEvent
        if ready
            result := "REVIEW FAILURE"
        else if watch
            result := "CHECK RETURN"
        else if holds
            result := "AVOID FADE"
        else
            result := "TRACK EDGE"
    result

f_state_text(bool hasEvent, bool ready, bool watch, bool holds, int dir) =>
    string result = "NO ACTIVE ATTEMPT"
    if hasEvent
        if ready
            result := "FAILURE REVIEW"
        else if watch
            result := "RETURN WATCH"
        else if holds
            result := "EXPANSION HOLD"
        else
            result := dir == 1 ? "UPSIDE TEST" : "DOWNSIDE TEST"
    result

f_reclaim_text(bool hasEvent, bool backInside, bool closeFailure, bool holds) =>
    string result = "NONE"
    if hasEvent
        if backInside
            result := "RANGE RETURN"
        else if closeFailure
            result := "EDGE LOST"
        else if holds
            result := "EDGE HOLDING"
        else
            result := "TESTING EDGE"
    result

f_side_color(int dir) =>
    dir == 1 ? bullColor : dir == -1 ? bearColor : neutralColor

f_zone_tag_bg(int dir, bool ready, bool watch, bool holds) =>
    ready ? bullColor : watch ? neutralColor : holds ? color.rgb(165, 180, 252) : f_side_color(dir)

f_zone_tag_text() =>
    color.rgb(15, 23, 42)

f_panel_border() =>
    panelTheme == "Light" ? color.rgb(203, 213, 225) : panelBorder

f_panel_label_color() =>
    panelTheme == "Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value_color() =>
    panelTheme == "Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(int row) =>
    bool evenRow = row % 2 == 0
    if panelTheme == "Light"
        evenRow ? color.rgb(241, 245, 249) : color.rgb(248, 250, 252)
    else
        evenRow ? color.rgb(20, 31, 52) : panelBg

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, string fontInput) =>
    color rowBg = f_row_bg(row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label_color(), bgcolor = rowBg, text_size = f_text_size(fontInput), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(fontInput), text_halign = text.align_right)

f_trim_labels(label[] ids, int limit) =>
    while array.size(ids) > limit
        label oldLabel = array.shift(ids)
        label.delete(oldLabel)

f_trim_boxes(box[] ids, int limit) =>
    while array.size(ids) > limit
        box oldBox = array.shift(ids)
        box.delete(oldBox)

f_trim_lines(line[] ids, int limit) =>
    while array.size(ids) > limit
        line oldLine = array.shift(ids)
        line.delete(oldLine)

// -------------------------------------------------
// Core Measurements
// -------------------------------------------------
bool closedEnough = confirmationMode == "Realtime Allowed" ? true : barstate.isconfirmed
float atrRaw = ta.atr(atrLength)
float safeAtr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
float atrBase = ta.sma(atrRaw, atrBaselineLength)
float atrRatio = not na(atrBase) and atrBase > 0.0 ? atrRaw / atrBase : 1.0
float volumeAverage = ta.sma(volume, volumeLength)
float volumeRatio = not na(volumeAverage) and volumeAverage > 0.0 ? volume / volumeAverage : 1.0
float contextEma = ta.ema(close, contextEmaLength)

float rangeHighRaw = ta.highest(high[1], rangeLookback)
float rangeLowRaw = ta.lowest(low[1], rangeLookback)
bool validRange = not na(rangeHighRaw) and not na(rangeLowRaw) and rangeHighRaw > rangeLowRaw
float rangeHigh = validRange ? rangeHighRaw : high
float rangeLow = validRange ? rangeLowRaw : low
float rangeMid = (rangeHigh + rangeLow) * 0.5
float candleRangeAtr = (high - low) / safeAtr
float closeLocation = (close - low) / math.max(high - low, syminfo.mintick)

float sensExpansion = sensitivity == "Strict" ? expansionBarAtr * 1.12 : sensitivity == "Responsive" ? expansionBarAtr * 0.88 : expansionBarAtr
float sensEdgeBreak = sensitivity == "Strict" ? edgeBreakAtr * 1.25 : sensitivity == "Responsive" ? edgeBreakAtr * 0.75 : edgeBreakAtr
float sensReentry = sensitivity == "Strict" ? reentryBufferAtr * 1.35 : sensitivity == "Responsive" ? reentryBufferAtr * 0.70 : reentryBufferAtr
float closeNeed = sensitivity == "Strict" ? 0.68 : sensitivity == "Responsive" ? 0.56 : 0.61

bool allowUpside = sideMode != "Failed Downside"
bool allowDownside = sideMode != "Failed Upside"
bool expansionSizeOk = candleRangeAtr >= sensExpansion or atrRatio >= 1.18
bool upsideAttempt = closedEnough and allowUpside and validRange and expansionSizeOk and high > rangeHigh + safeAtr * sensEdgeBreak and closeLocation >= closeNeed
bool downsideAttempt = closedEnough and allowDownside and validRange and expansionSizeOk and low < rangeLow - safeAtr * sensEdgeBreak and closeLocation <= 1.0 - closeNeed
bool bothAttempts = upsideAttempt and downsideAttempt
bool newUpsideAttempt = upsideAttempt and (not bothAttempts or close >= rangeMid)
bool newDownsideAttempt = downsideAttempt and (not bothAttempts or close < rangeMid)
bool newAttempt = newUpsideAttempt or newDownsideAttempt

// -------------------------------------------------
// Expansion Attempt State
// -------------------------------------------------
var int activeDir = 0
var int eventBar = na
var float eventEdge = na
var float eventExtreme = na
var float eventAtr = na
var float eventRangeMid = na
var float eventExpansionAtr = na
var float eventVolumeRatio = na
var float bestExtreme = na

if newAttempt
    activeDir := newUpsideAttempt ? 1 : -1
    eventBar := bar_index
    eventEdge := newUpsideAttempt ? rangeHigh : rangeLow
    eventExtreme := newUpsideAttempt ? high : low
    eventAtr := safeAtr
    eventRangeMid := rangeMid
    eventExpansionAtr := candleRangeAtr
    eventVolumeRatio := volumeRatio
    bestExtreme := eventExtreme
else if activeDir != 0
    bestExtreme := activeDir == 1 ? math.max(nz(bestExtreme, high), high) : math.min(nz(bestExtreme, low), low)

// -------------------------------------------------
// Confirmation-anchored proof (flagged attempts, Follow = returned to range mid before risk shelf)
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

int proofWarmup = rangeLookback + atrLength + 5
if closedEnough and bar_index > proofWarmup
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
        if naturalResolve or newAttempt
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
    if newAttempt and not pEvalActive
        pEvalActive := true
        pEvalDir := newUpsideAttempt ? -1 : 1
        pEvalEntry := eventEdge
        float pShelfBuf = math.max(nz(eventAtr, safeAtr), syminfo.mintick) * 0.50
        pEvalStop := newUpsideAttempt ? eventExtreme + pShelfBuf : eventExtreme - pShelfBuf
        float pStopDist = math.abs(eventEdge - pEvalStop)
        float pMidDist = math.abs(eventRangeMid - eventEdge)
        float pFollowDist = math.max(math.min(pStopDist, pMidDist), syminfo.mintick)
        pEvalTarget := eventEdge + (newUpsideAttempt ? -1 : 1) * pFollowDist
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false
        pFlipped := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

bool activeEvent = activeDir != 0 and not na(eventBar) and not na(eventEdge)
int eventAge = activeEvent ? bar_index - eventBar : 0
float baseAtr = math.max(nz(eventAtr, safeAtr), syminfo.mintick)
float progressAtr = activeEvent ? (activeDir == 1 ? (nz(bestExtreme, eventExtreme) - eventEdge) / baseAtr : (eventEdge - nz(bestExtreme, eventExtreme)) / baseAtr) : 0.0
float insideDepthAtr = activeEvent ? (activeDir == 1 ? (eventEdge - close) / baseAtr : (close - eventEdge) / baseAtr) : 0.0
float edgeDistanceAtr = activeEvent ? (activeDir == 1 ? (close - eventEdge) / baseAtr : (eventEdge - close) / baseAtr) : 0.0
bool closeBackInside = activeEvent and insideDepthAtr >= sensReentry
bool simpleCloseFailure = activeEvent and (activeDir == 1 ? close < eventEdge : close > eventEdge)
bool windowActive = activeEvent and eventAge <= failureWindowBars
bool windowExpired = activeEvent and eventAge > failureWindowBars
bool realTravelMissing = activeEvent and progressAtr < realTravelAtr
bool failureVolumeOk = volumeRatio >= volumeSupportLevel or nz(eventVolumeRatio, 1.0) >= volumeSupportLevel
bool trendAgainstAttempt = activeEvent and (activeDir == 1 ? close < contextEma : close > contextEma)

float expansionComponent = activeEvent ? f_norm_high_good(nz(eventExpansionAtr, candleRangeAtr), sensExpansion * 0.85, sensExpansion * 1.65) : 0.0
float closeFailureComponent = activeEvent ? f_norm_high_good(math.max(insideDepthAtr, 0.0), 0.0, math.max(realTravelAtr * 0.70, 0.20)) : 0.0
float travelLossComponent = activeEvent ? f_norm_low_good(progressAtr, realTravelAtr * 0.15, realTravelAtr) : 0.0
float volumeComponent = activeEvent ? f_norm_high_good(math.max(volumeRatio, nz(eventVolumeRatio, 1.0)), 0.75, volumeSupportLevel * 1.35) : 0.0
float reentryComponent = activeEvent ? f_norm_high_good(math.max(insideDepthAtr, 0.0), sensReentry, math.max(realTravelAtr, sensReentry + 0.35)) : 0.0
float failureScoreRaw = expansionComponent * 0.18 + closeFailureComponent * 0.29 + travelLossComponent * 0.22 + volumeComponent * 0.13 + reentryComponent * 0.18
float failureScore = activeEvent ? f_clamp(failureScoreRaw, 0.0, 100.0) : 0.0

bool confirmationOk = true
if confirmationMode == "Close + Volume"
    confirmationOk := barstate.isconfirmed and failureVolumeOk
else if confirmationMode == "Strict"
    confirmationOk := barstate.isconfirmed and failureVolumeOk and realTravelMissing and closeBackInside and trendAgainstAttempt
else if confirmationMode == "Close Failure"
    confirmationOk := barstate.isconfirmed

bool failureReady = activeEvent and windowActive and confirmationOk and closeBackInside and realTravelMissing and failureScore >= readyThreshold
bool failureWatch = activeEvent and windowActive and simpleCloseFailure and realTravelMissing and failureScore >= watchThreshold and not failureReady
bool expansionHolds = activeEvent and windowActive and progressAtr >= realTravelAtr and edgeDistanceAtr > 0.0
bool resetContext = windowExpired or (activeEvent and progressAtr >= realTravelAtr * 1.70 and edgeDistanceAtr > 0.35)
bool newResetContext = resetContext and not (resetContext[1] == true)
bool displayEvent = activeEvent and not resetContext

string expansionState = f_state_text(displayEvent, failureReady, failureWatch, expansionHolds, activeDir)
string reclaimState = f_reclaim_text(displayEvent, closeBackInside, simpleCloseFailure, expansionHolds)

float returnTarget = displayEvent ? eventRangeMid : na
float targetRoomAtr = displayEvent ? math.max(activeDir == 1 ? (close - returnTarget) / baseAtr : (returnTarget - close) / baseAtr, 0.0) : na
float riskShelf = displayEvent ? (activeDir == 1 ? nz(bestExtreme, eventExtreme) + baseAtr * 0.18 : nz(bestExtreme, eventExtreme) - baseAtr * 0.18) : na
string targetRoomText = displayEvent ? (targetRoomAtr >= 1.4 ? f_fmt(targetRoomAtr) + " ATR / OPEN" : targetRoomAtr >= 0.6 ? f_fmt(targetRoomAtr) + " ATR / MODERATE" : f_fmt(targetRoomAtr) + " ATR / TIGHT") : "-"
string actionText = f_workflow_text(displayEvent, failureReady, failureWatch, expansionHolds)
string reviewViewText = bestViewed == "Any" ? "CHART / 4H / 1D" : bestViewed

// -------------------------------------------------
// Visual Objects
// -------------------------------------------------
var box corridorBox = na
var box corridorBadge = na
var label corridorBadgeLabel = na
var box[] memoryCorridorBoxes = array.new_box()
var label[] memoryCorridorBadgeLabels = array.new_label()
var line[] memoryEdgeLines = array.new_line()
var line[] memoryRiskLines = array.new_line()
var line[] memoryTargetLines = array.new_line()
var line edgeLine = na
var line riskLine = na
var line targetLine = na
var label edgeGuideTag = na
var label riskGuideTag = na
var label targetGuideTag = na
var label[] eventLabels = array.new_label()
var int lastEventLabelBar = na
var int lastContextLabelBar = na

color activeColor = f_side_color(activeDir)
color corridorBg = color.new(activeColor, failureReady ? 84 : failureWatch ? 88 : 91)
color zoneTagBg = f_zone_tag_bg(activeDir, failureReady, failureWatch, expansionHolds)
color zoneTagTextColor = f_zone_tag_text()
float corridorTop = na
float corridorBottom = na
float corridorVisualTop = na
float corridorVisualBottom = na
if displayEvent
    float topCandidate = activeDir == 1 ? nz(bestExtreme, eventExtreme) : eventEdge
    float bottomCandidate = activeDir == 1 ? eventEdge : nz(bestExtreme, eventExtreme)
    corridorTop := math.max(topCandidate, bottomCandidate)
    corridorBottom := math.min(topCandidate, bottomCandidate)
    float corridorMid = (corridorTop + corridorBottom) * 0.5
    float corridorVisualHeight = math.max(corridorTop - corridorBottom, baseAtr * 0.70)
    corridorVisualTop := corridorMid + corridorVisualHeight * 0.5
    corridorVisualBottom := corridorMid - corridorVisualHeight * 0.5

string corridorKind = failureReady ? "FAIL" : failureWatch ? "WATCH" : expansionHolds ? "HOLD" : simpleCloseFailure ? "REVIEW" : "EDGE"
string corridorScoreText = showLabelScore ? " " + f_fmt_int(failureScore) : ""
string corridorText = displayEvent ? corridorKind + corridorScoreText : ""
int corridorRightEdge = bar_index + projectionBars
int guideRightEdge = corridorRightEdge + (showGuideTags ? rightTagOffsetBars : 0)
int corridorSpan = displayEvent ? math.max(corridorRightEdge - eventBar, 1) : 1
int zoneTagPadding = displayEvent and corridorSpan > 24 ? 3 : displayEvent and corridorSpan > 10 ? 2 : 1
int zoneTagMinWidth = 14
int zoneTagAvailableWidth = displayEvent ? math.max(corridorSpan - zoneTagPadding * 2, 1) : zoneTagMinWidth
int zoneTagTargetWidth = displayEvent ? int(math.round(corridorSpan * 0.50)) : zoneTagMinWidth
int zoneTagWidthBase = displayEvent ? math.max(zoneTagMinWidth, zoneTagTargetWidth) : zoneTagMinWidth
int zoneTagWidth = displayEvent ? math.min(zoneTagWidthBase, zoneTagAvailableWidth) : zoneTagMinWidth
int zoneTagMinLeft = displayEvent ? eventBar + zoneTagPadding : bar_index
int zoneTagMaxLeft = displayEvent ? math.max(zoneTagMinLeft, corridorRightEdge - zoneTagPadding - zoneTagWidth) : bar_index
int zoneTagCenterLeft = displayEvent ? eventBar + zoneTagPadding + math.max(0, int(math.floor((zoneTagAvailableWidth - zoneTagWidth) * 0.5))) : bar_index
int zoneTagLeft = displayEvent ? math.max(zoneTagMinLeft, math.min(zoneTagCenterLeft, zoneTagMaxLeft)) : bar_index
int zoneTagRight = displayEvent ? zoneTagLeft + zoneTagWidth : bar_index + zoneTagMinWidth
int zoneTagX = displayEvent ? int(math.round((zoneTagLeft + zoneTagRight) * 0.5)) : bar_index
float zoneTagMid = displayEvent ? (corridorVisualTop + corridorVisualBottom) * 0.5 : na
float zoneTagHeight = displayEvent ? math.max(corridorVisualTop - corridorVisualBottom, syminfo.mintick * 10.0) : na
float zoneTagHalfHeight = displayEvent ? math.min(math.max(zoneTagHeight * 0.18, baseAtr * 0.14), zoneTagHeight * 0.24) : na
float zoneTagTop = displayEvent ? zoneTagMid + zoneTagHalfHeight : na
float zoneTagBottom = displayEvent ? zoneTagMid - zoneTagHalfHeight : na

bool meaningfulArchiveState = failureReady[1] or failureWatch[1] or expansionHolds[1] or (displayEvent[1] and failureScore[1] >= watchThreshold - 8)
bool archiveCurrentCorridor = showFailureCorridor and meaningfulArchiveState and not na(corridorBox) and not na(corridorBadge) and not na(corridorBadgeLabel) and newResetContext
if archiveCurrentCorridor
    color archiveColor = f_side_color(nz(activeDir[1], activeDir))
    color archiveTagBg = f_zone_tag_bg(nz(activeDir[1], activeDir), failureReady[1], failureWatch[1], expansionHolds[1])
    box memoryCorridor = box.copy(corridorBox)
    box.set_bgcolor(memoryCorridor, color.new(archiveColor, 93))
    box.set_border_color(memoryCorridor, color.new(archiveColor, 64))
    array.push(memoryCorridorBoxes, memoryCorridor)
    f_trim_boxes(memoryCorridorBoxes, maxVisibleZones)
    label memoryCorridorBadgeLabel = label.copy(corridorBadgeLabel)
    label.set_color(memoryCorridorBadgeLabel, color.new(archiveTagBg, 8))
    label.set_textcolor(memoryCorridorBadgeLabel, f_zone_tag_text())
    label.set_size(memoryCorridorBadgeLabel, f_text_size(labelFontSize))
    label.set_style(memoryCorridorBadgeLabel, label.style_label_center)
    array.push(memoryCorridorBadgeLabels, memoryCorridorBadgeLabel)
    f_trim_labels(memoryCorridorBadgeLabels, maxVisibleZones)
    if showExpansionEdge and not na(edgeLine)
        line memoryEdge = line.copy(edgeLine)
        line.set_color(memoryEdge, color.new(accentColor, 58))
        line.set_width(memoryEdge, 1)
        array.push(memoryEdgeLines, memoryEdge)
        f_trim_lines(memoryEdgeLines, maxVisibleZones)
    if showRiskShelf and not na(riskLine)
        line memoryRisk = line.copy(riskLine)
        line.set_color(memoryRisk, color.new(dangerColor, 64))
        line.set_width(memoryRisk, 1)
        array.push(memoryRiskLines, memoryRisk)
        f_trim_lines(memoryRiskLines, maxVisibleZones)
    if showReturnTarget and not na(targetLine)
        line memoryTarget = line.copy(targetLine)
        line.set_color(memoryTarget, color.new(neutralColor, 62))
        line.set_width(memoryTarget, 1)
        array.push(memoryTargetLines, memoryTarget)
        f_trim_lines(memoryTargetLines, maxVisibleZones)

if displayEvent and showFailureCorridor
    if na(corridorBox)
        corridorBox := box.new(eventBar, corridorVisualTop, corridorRightEdge, corridorVisualBottom,
             bgcolor = corridorBg,
             border_color = color.new(activeColor, 20))
    else
        box.set_lefttop(corridorBox, eventBar, corridorVisualTop)
        box.set_rightbottom(corridorBox, corridorRightEdge, corridorVisualBottom)
        box.set_bgcolor(corridorBox, corridorBg)
        box.set_border_color(corridorBox, color.new(activeColor, 20))
    if na(corridorBadge)
        corridorBadge := box.new(zoneTagLeft, zoneTagTop, zoneTagRight, zoneTagBottom,
             bgcolor = color.new(zoneTagBg, 70),
             border_color = color.new(zoneTagBg, 25))
    else
        box.set_lefttop(corridorBadge, zoneTagLeft, zoneTagTop)
        box.set_rightbottom(corridorBadge, zoneTagRight, zoneTagBottom)
        box.set_bgcolor(corridorBadge, color.new(zoneTagBg, 70))
        box.set_border_color(corridorBadge, color.new(zoneTagBg, 25))
    if na(corridorBadgeLabel)
        corridorBadgeLabel := label.new(zoneTagX, zoneTagMid, corridorText,
             textcolor = zoneTagTextColor,
             color = color.new(zoneTagBg, 0),
             style = label.style_label_center,
             size = f_text_size(labelFontSize))
    else
        label.set_xy(corridorBadgeLabel, zoneTagX, zoneTagMid)
        label.set_text(corridorBadgeLabel, corridorText)
        label.set_color(corridorBadgeLabel, color.new(zoneTagBg, 0))
        label.set_textcolor(corridorBadgeLabel, zoneTagTextColor)
        label.set_size(corridorBadgeLabel, f_text_size(labelFontSize))
        label.set_style(corridorBadgeLabel, label.style_label_center)
else
    if not na(corridorBox)
        box.delete(corridorBox)
        corridorBox := na
    if not na(corridorBadge)
        box.delete(corridorBadge)
        corridorBadge := na
    if not na(corridorBadgeLabel)
        label.delete(corridorBadgeLabel)
        corridorBadgeLabel := na

if not showFailureCorridor
    while array.size(memoryCorridorBoxes) > 0
        box oldCorridor = array.pop(memoryCorridorBoxes)
        box.delete(oldCorridor)
    while array.size(memoryCorridorBadgeLabels) > 0
        label oldCorridorBadgeLabel = array.pop(memoryCorridorBadgeLabels)
        label.delete(oldCorridorBadgeLabel)
    while array.size(memoryEdgeLines) > 0
        line oldEdge = array.pop(memoryEdgeLines)
        line.delete(oldEdge)
    while array.size(memoryRiskLines) > 0
        line oldRisk = array.pop(memoryRiskLines)
        line.delete(oldRisk)
    while array.size(memoryTargetLines) > 0
        line oldTarget = array.pop(memoryTargetLines)
        line.delete(oldTarget)

if displayEvent and showExpansionEdge
    if na(edgeLine)
        edgeLine := line.new(eventBar, eventEdge, guideRightEdge, eventEdge, color = color.new(accentColor, 15), style = line.style_solid, width = 2)
    else
        line.set_xy1(edgeLine, eventBar, eventEdge)
        line.set_xy2(edgeLine, guideRightEdge, eventEdge)
        line.set_color(edgeLine, color.new(accentColor, 15))
    if showGuideTags
        if na(edgeGuideTag)
            edgeGuideTag := label.new(guideRightEdge, eventEdge, "EDGE\n" + f_price(eventEdge), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = headerText, color = color.new(accentColor, 0), size = f_text_size(labelFontSize), textalign = text.align_center)
        else
            label.set_xy(edgeGuideTag, guideRightEdge, eventEdge)
            label.set_text(edgeGuideTag, "EDGE\n" + f_price(eventEdge))
            label.set_style(edgeGuideTag, label.style_label_left)
            label.set_color(edgeGuideTag, color.new(accentColor, 0))
            label.set_textcolor(edgeGuideTag, headerText)
            label.set_size(edgeGuideTag, f_text_size(labelFontSize))
    else if not na(edgeGuideTag)
        label.delete(edgeGuideTag)
        edgeGuideTag := na
else if not na(edgeLine)
    line.delete(edgeLine)
    edgeLine := na
    if not na(edgeGuideTag)
        label.delete(edgeGuideTag)
        edgeGuideTag := na

if displayEvent and showRiskShelf
    if na(riskLine)
        riskLine := line.new(eventBar, riskShelf, guideRightEdge, riskShelf, color = color.new(dangerColor, 10), style = line.style_dashed, width = 2)
    else
        line.set_xy1(riskLine, eventBar, riskShelf)
        line.set_xy2(riskLine, guideRightEdge, riskShelf)
        line.set_color(riskLine, color.new(dangerColor, 10))
    if showGuideTags
        if na(riskGuideTag)
            riskGuideTag := label.new(guideRightEdge, riskShelf, "RISK\n" + f_price(riskShelf), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = headerText, color = color.new(dangerColor, 0), size = f_text_size(labelFontSize), textalign = text.align_center)
        else
            label.set_xy(riskGuideTag, guideRightEdge, riskShelf)
            label.set_text(riskGuideTag, "RISK\n" + f_price(riskShelf))
            label.set_style(riskGuideTag, label.style_label_left)
            label.set_color(riskGuideTag, color.new(dangerColor, 0))
            label.set_textcolor(riskGuideTag, headerText)
            label.set_size(riskGuideTag, f_text_size(labelFontSize))
    else if not na(riskGuideTag)
        label.delete(riskGuideTag)
        riskGuideTag := na
else if not na(riskLine)
    line.delete(riskLine)
    riskLine := na
    if not na(riskGuideTag)
        label.delete(riskGuideTag)
        riskGuideTag := na

if displayEvent and showReturnTarget
    if na(targetLine)
        targetLine := line.new(eventBar, returnTarget, guideRightEdge, returnTarget, color = color.new(neutralColor, 10), style = line.style_dotted, width = 2)
    else
        line.set_xy1(targetLine, eventBar, returnTarget)
        line.set_xy2(targetLine, guideRightEdge, returnTarget)
        line.set_color(targetLine, color.new(neutralColor, 10))
    if showGuideTags
        if na(targetGuideTag)
            targetGuideTag := label.new(guideRightEdge, returnTarget, "RETURN\n" + f_price(returnTarget), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = color.rgb(15, 23, 42), color = color.new(neutralColor, 0), size = f_text_size(labelFontSize), textalign = text.align_center)
        else
            label.set_xy(targetGuideTag, guideRightEdge, returnTarget)
            label.set_text(targetGuideTag, "RETURN\n" + f_price(returnTarget))
            label.set_style(targetGuideTag, label.style_label_left)
            label.set_color(targetGuideTag, color.new(neutralColor, 0))
            label.set_textcolor(targetGuideTag, color.rgb(15, 23, 42))
            label.set_size(targetGuideTag, f_text_size(labelFontSize))
    else if not na(targetGuideTag)
        label.delete(targetGuideTag)
        targetGuideTag := na
else if not na(targetLine)
    line.delete(targetLine)
    targetLine := na
    if not na(targetGuideTag)
        label.delete(targetGuideTag)
        targetGuideTag := na

bool eventCooldownOk = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
bool contextCooldownOk = na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars
float attemptLabelOffset = labelOffsetAtr + 0.34
float stateLabelOffset = labelOffsetAtr + 0.74
float contextLabelOffset = labelOffsetAtr + 1.12
int contextEventGap = int(math.round(labelCooldownBars * 0.75))
bool contextClearOfEvent = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= contextEventGap
bool allowExternalContextLabel = not showFailureCorridor

bool qualifiedAttemptLabel = newAttempt
if showEventLabels and showAttemptLabels and qualifiedAttemptLabel and eventCooldownOk
    string textValue = activeDir == 1 ? "UP EXP" : "DN EXP"
    float yValue = activeDir == 1 ? high + safeAtr * attemptLabelOffset : low - safeAtr * attemptLabelOffset
    string styleValue = activeDir == 1 ? label.style_label_down : label.style_label_up
    label id = label.new(bar_index, yValue, textValue, textcolor = headerText, color = color.new(activeColor, 4), style = styleValue, size = f_text_size(labelFontSize))
    array.push(eventLabels, id)
    lastEventLabelBar := bar_index

if showEventLabels and displayEvent and failureReady and eventCooldownOk
    string textValue = "REVIEW FAIL"
    float yValue = activeDir == 1 ? high + safeAtr * stateLabelOffset : low - safeAtr * stateLabelOffset
    string styleValue = activeDir == 1 ? label.style_label_down : label.style_label_up
    label id = label.new(bar_index, yValue, textValue, textcolor = headerText, color = color.new(activeColor, 0), style = styleValue, size = f_text_size(labelFontSize))
    array.push(eventLabels, id)
    lastEventLabelBar := bar_index
else if showEventLabels and displayEvent and failureWatch and eventCooldownOk
    string textValue = "CHECK RETURN"
    float yValue = activeDir == 1 ? high + safeAtr * stateLabelOffset : low - safeAtr * stateLabelOffset
    string styleValue = activeDir == 1 ? label.style_label_down : label.style_label_up
    label id = label.new(bar_index, yValue, textValue, textcolor = color.rgb(15, 23, 42), color = color.new(neutralColor, 0), style = styleValue, size = f_text_size(labelFontSize))
    array.push(eventLabels, id)
    lastEventLabelBar := bar_index
else if showEventLabels and displayEvent and expansionHolds and eventCooldownOk
    string textValue = "AVOID FADE"
    float yValue = activeDir == 1 ? high + safeAtr * stateLabelOffset : low - safeAtr * stateLabelOffset
    string styleValue = activeDir == 1 ? label.style_label_down : label.style_label_up
    label id = label.new(bar_index, yValue, textValue, textcolor = headerText, color = color.new(accentColor, 5), style = styleValue, size = f_text_size(labelFontSize))
    array.push(eventLabels, id)
    lastEventLabelBar := bar_index

if showContextLabels and allowExternalContextLabel and displayEvent and windowActive and contextCooldownOk and contextClearOfEvent and not failureReady and not expansionHolds
    string textValue = failureWatch ? "EDGE LOST" : "EDGE"
    float yValue = activeDir == 1 ? high + safeAtr * contextLabelOffset : low - safeAtr * contextLabelOffset
    string styleValue = activeDir == 1 ? label.style_label_down : label.style_label_up
    label id = label.new(bar_index, yValue, textValue, textcolor = headerText, color = color.new(accentColor, 8), style = styleValue, size = f_text_size(labelFontSize))
    array.push(eventLabels, id)
    lastContextLabelBar := bar_index

if showEventLabels and showResetLabels and newResetContext and eventCooldownOk
    string textValue = windowExpired ? "RESET PLAN" : "NO FAIL"
    float yValue = activeDir == 1 ? high + safeAtr * stateLabelOffset : low - safeAtr * stateLabelOffset
    string styleValue = activeDir == 1 ? label.style_label_down : label.style_label_up
    label id = label.new(bar_index, yValue, textValue, textcolor = headerText, color = color.new(accentColor, 0), style = styleValue, size = f_text_size(labelFontSize))
    array.push(eventLabels, id)
    lastEventLabelBar := bar_index

f_trim_labels(eventLabels, maxVisibleLabels)

// -------------------------------------------------
// Panel
// -------------------------------------------------
int panelRowCount = showProof ? 13 : 8
var table plannerPanel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""
var string lastPanelFontSize = ""
var bool lastPanelVisible = false
var bool lastProofMode = false

string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) : "building"
string followText = proofTotal > 0 ? f_pct(followRate) : "-"
string holdText = proofTotal > 0 ? f_pct(holdRate) : "-"
string reactText = proofTotal > 0 ? f_pct(reactRate) : "-"
string flipText = proofTotal > 0 ? f_pct(flipRate) : "-"
color followCol = proofTotal > 0 ? f_rate_color(followRate) : f_panel_value_color()
color holdCol = proofTotal > 0 ? f_rate_color(holdRate) : f_panel_value_color()
color reactCol = proofTotal > 0 ? f_rate_color(reactRate) : f_panel_value_color()
color flipCol = proofTotal > 0 ? f_flip_color(flipRate) : f_panel_value_color()

bool panelNeedsReset = na(plannerPanel) or panelLocation != lastPanelLocation or panelTheme != lastPanelTheme or panelFontSize != lastPanelFontSize or showPanel != lastPanelVisible or showProof != lastProofMode
if panelNeedsReset
    if not na(plannerPanel)
        table.delete(plannerPanel)
    if showPanel
        plannerPanel := table.new(f_panel_pos(panelLocation), 2, panelRowCount, frame_color = f_panel_border(), frame_width = 1, border_color = f_panel_border(), border_width = 1)
        table.cell(plannerPanel, 0, 0, "AG Pro Expansion Failure Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        table.cell(plannerPanel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize))
        table.merge_cells(plannerPanel, 0, 0, 1, 0)
    else
        plannerPanel := na
    lastPanelLocation := panelLocation
    lastPanelTheme := panelTheme
    lastPanelFontSize := panelFontSize
    lastPanelVisible := showPanel
    lastProofMode := showProof

if barstate.islast
    if showPanel and not na(plannerPanel)
        table.clear(plannerPanel, 0, 1, 1, panelRowCount - 1)
        table.cell(plannerPanel, 0, 0, "AG Pro Expansion Failure Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        f_panel_row(plannerPanel, 1, "Workflow", actionText, displayEvent ? (failureReady ? bullColor : failureWatch ? neutralColor : expansionHolds ? accentColor : accentColor) : f_panel_value_color(), panelFontSize)
        f_panel_row(plannerPanel, 2, "Expansion State", expansionState, displayEvent ? (failureReady ? bullColor : failureWatch ? neutralColor : expansionHolds ? accentColor : f_panel_value_color()) : f_panel_value_color(), panelFontSize)
        f_panel_row(plannerPanel, 3, "Failure Risk", displayEvent ? f_fmt_int(failureScore) + " / 100 " + f_grade(failureScore) : "-", displayEvent ? f_score_color(failureScore) : f_panel_value_color(), panelFontSize)
        f_panel_row(plannerPanel, 4, "Return", reclaimState, displayEvent and closeBackInside ? bullColor : displayEvent and simpleCloseFailure ? neutralColor : f_panel_value_color(), panelFontSize)
        f_panel_row(plannerPanel, 5, "Risk Shelf", displayEvent ? f_price(riskShelf) : "-", displayEvent ? dangerColor : f_panel_value_color(), panelFontSize)
        f_panel_row(plannerPanel, 6, "Target Room", targetRoomText, displayEvent and targetRoomAtr >= 1.4 ? bullColor : displayEvent and targetRoomAtr >= 0.6 ? neutralColor : f_panel_value_color(), panelFontSize)
        f_panel_row(plannerPanel, 7, "Review View", reviewViewText, accentColor, panelFontSize)
        if showProof
            color proofHeadBg = f_row_bg(8)
            table.cell(plannerPanel, 0, 8, "Proof @ Confirm", text_color = accentColor, bgcolor = proofHeadBg, text_size = f_text_size(panelFontSize), text_halign = text.align_left)
            table.cell(plannerPanel, 1, 8, proofSampleText, text_color = f_panel_label_color(), bgcolor = proofHeadBg, text_size = f_text_size(panelFontSize), text_halign = text.align_right)
            f_panel_row(plannerPanel, 9, "Follow Rate", followText, followCol, panelFontSize)
            f_panel_row(plannerPanel, 10, "Hold Rate", holdText, holdCol, panelFontSize)
            f_panel_row(plannerPanel, 11, "React Rate", reactText, reactCol, panelFontSize)
            f_panel_row(plannerPanel, 12, "Flip Rate", flipText, flipCol, panelFontSize)

// -------------------------------------------------
// Hidden Exports
// -------------------------------------------------
plot(followRate, "EFP Follow Rate", display = display.none)
plot(holdRate, "EFP Hold Rate", display = display.none)
plot(reactRate, "EFP React Rate", display = display.none)
plot(flipRate, "EFP Flip Rate", display = display.none)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
bool alertReady = failureReady and failureScore >= alertScoreThreshold
bool alertWatch = failureWatch and failureScore >= alertScoreThreshold
bool alertHold = expansionHolds and failureScore < watchThreshold
bool alertReset = newResetContext

alertcondition(alertReady, "Review Expansion Failure", "Expansion Failure Planner: a failed expansion context reached the review threshold. This is an analytical attention marker.")
alertcondition(alertWatch, "Check Expansion Return", "Expansion Failure Planner: failed travel is developing while confirmation remains incomplete. This is an analytical attention marker.")
alertcondition(alertHold, "Expansion Holding Edge", "Expansion Failure Planner: expansion is holding beyond the prior edge, so failure context is not confirmed.")
alertcondition(alertReset, "Expansion Failure Reset", "Expansion Failure Planner: the active expansion failure window expired or was invalidated by real travel.")
````
