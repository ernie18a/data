# Range Escape Planner [AGPro Series]

- url: https://www.tradingview.com/script/PBnfYx2W-Range-Escape-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;29164f839f664816ae6ec3b21337fc68
- version: 4.0

## Description

Range Escape Planner [AGPro Series]

🧠 Core Idea

Is price escaping a mature range with enough quality to monitor, or is the move still vulnerable to failure?


📌 Overview / What it does

Range Escape Planner [AGPro Series] is a chart-first breakout quality and trade planning tool built around mature range escape behavior.

Instead of printing a generic breakout signal, the script maps the active range boundary, projected escape corridor, invalidation edge, target guide, obstruction room, follow-through quality, and retest behavior. These components are converted into a 0-100 Escape Score and a clear next-action state.

The script produces a range boundary box, escape corridor, risk/target guide lines, compact labels, alerts, and a clean AGPro planning panel. It does not predict future price movement, automate decisions, or guarantee that a range escape will continue.


🎯 Purpose & Design Philosophy

This script was built for traders who want to evaluate breakout quality after price leaves a mature range.

Many breakout tools identify the break itself but stop before answering the practical planning questions: is the range mature, is the close beyond the boundary strong enough, is volatility expanding constructively, is there clean room, and where is the failure reference?

The design philosophy is simple: a range escape is only useful when it has maturity, confirmation, room, and a readable invalidation edge.


⚡ Why This Script Is Different

Most tools focus on basic range breaks, box breakouts, session opening ranges, or simple breakout markers.

This script does NOT clone Darvas Box Breakout Quality, does NOT rebuild an ORB model, and does NOT act as a generic consolidation breakout signal.

Instead, it treats the move as a planning problem. The main output is not a buy or sell command. It is a structured state that helps users separate VALID ESCAPE, ESCAPE WATCH, RANGE READY, OBSTRUCTION, FAILED, and WAIT RANGE conditions.


⚙️ Methodology

1. Context Detection
The script maps the prior range from previous bars and checks whether price is still inside, near an edge, or closing beyond the boundary.

2. Reference Mapping
It draws the mature range, escape edge, invalidation edge, projected target guide, and older swing obstruction room.

3. Reaction Evaluation
The model scores range maturity, close beyond range, volatility expansion, follow-through, retest quality, and obstruction room.

4. Visual Output
The result is displayed through centered zone labels, compact event labels, guide lines, deterministic alerts, and a premium AGPro panel.


🗺️ How to Read the Chart

Zones = the range box shows the active mature range. The escape corridor shows the projected planning path from the broken boundary toward a target guide. Zone text is centered inside the boxes.

Labels = compact markers identify RANGE READY, ESCAPE WATCH, VALID ESCAPE, RETEST HOLD, OBSTRUCTION, and FAILED context.

Colors = green highlights cleaner long-side escape quality, pink highlights short-side or failure risk, amber highlights review conditions, and indigo highlights watch or mature-range context.

Panel = the panel summarizes Escape Score, Range Age, Confirmation, Obstruction, and Action.


🚦 Signals & States

• RANGE READY → the range is mature and price is near an escape edge.

• ESCAPE WATCH → price has escaped the range, but follow-through or retest confirmation is still incomplete.

• VALID ESCAPE → the escape has stronger score alignment, follow-through or retest support, and acceptable obstruction context.

• RETEST HOLD → price retested the escape edge and held outside the prior range.

• OBSTRUCTION → the escape is active, but older structure may limit clean room.

• FAILED → price returned through the escape edge and the escape context is no longer clean.

• WAIT RANGE → no mature range escape context is active.


🔔 Alerts Logic

Alerts trigger when the planner detects RANGE READY, New Range Escape, ESCAPE WATCH, VALID ESCAPE, RETEST HOLD, OBSTRUCTION REVIEW, or FAILED ESCAPE conditions.

These alerts are attention markers only. They are not trade instructions, entry signals, or automated strategy commands.


🧩 Confluence Logic

The strongest context appears when a range is mature, price closes beyond the range boundary, volatility expands constructively, candle follow-through improves, the broken edge holds on retest, and obstruction room remains acceptable.

When these components align, the Escape Score improves and the state can progress from RANGE READY to ESCAPE WATCH or VALID ESCAPE.


📊 When to Use

• During range breakout and range expansion review

• 4H and multi-hour swing charts where the range structure has enough space to breathe

• After price has spent time inside a defined range

• When evaluating whether a breakout has clean follow-through

• When a trader needs a visible invalidation edge and target-room reference

• On liquid markets where ATR, range, and swing structure are readable


⚠️ When NOT to Use

• Very low-liquidity symbols with unstable candles

• Extremely noisy micro-timeframes

• Very compressed intraday charts where labels and range boxes can crowd the price action

• News-driven spikes where price gaps far beyond the range

• Markets where older swing structure is too messy to define clean obstruction room

• Situations where the user expects a signal-only entry tool


🎛️ Key Inputs

• Planning Side → controls Auto, Long Escape, or Short Escape mode.

• Range Lookback → controls how the prior range boundary is mapped.

• Minimum Range Age → defines how mature the range should be before stronger scoring.

• Minimum Close Beyond Edge ATR → controls how far price must close beyond the boundary before an escape registers.

• Follow-Through ATR → defines stronger post-escape movement beyond the edge.

• Retest Tolerance ATR → controls how close price can revisit the broken boundary and still count as a hold.

• Obstruction Lookback → controls how older swing structure is checked for clean room.

• Label and Panel Font Size → controls chart labels, centered box text, and panel readability.


🖥️ Interface & Visual Design

The interface is designed to stay chart-first.

The range box defines the active decision area. The escape corridor shows the forward planning path. The invalidation, target, and obstruction lines add context without turning the chart into a crowded signal board.

The AGPro panel provides a compact decision summary with a merged blue title row and clear state hierarchy.


🧪 Practical Usage Workflow

1. Read the panel state and Escape Score.

2. Check whether the range is mature enough.

3. Review the escape corridor and edge line.

4. Check confirmation, retest behavior, and obstruction room.

5. Treat alerts as attention markers, then evaluate broader market context.


🔍 Interpretation Guidelines

Think in terms of escape quality, not prediction.

A stronger score means multiple structural conditions are aligned. A weaker score means the escape may be premature, poorly confirmed, obstructed, too noisy, or already failed.

OBSTRUCTION is especially important because a range can break cleanly while nearby older structure still limits practical room.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not an auto-trading system

• Not a guaranteed signal tool

• Not a Darvas Box clone

• Not an ORB model

• Not a generic support/resistance zone map


⚠️ Limitations & Transparency

The script is rule-based and depends on recent price, volatility, range, and older swing structure.

Timeframe differences can change how range maturity and escape quality appear. Volatility spikes can distort the score. Thin markets can create false escape or failure behavior.

Outputs should always be interpreted with broader market structure, liquidity, and risk context.


🧠 Market Context Notes

Range escape behavior is most useful when a readable balance area exists before expansion.

An escape with no follow-through may still be early. An escape with immediate obstruction may require extra caution. An escape that returns through the broken edge is treated as failed context, not as a new opposite prediction.


🧾 Use Case Examples

When price closes beyond a mature range, volatility expands from normal conditions, the candle holds beyond the edge, and older obstruction room is clean, the planner may classify the move as VALID ESCAPE.

When price breaks the boundary but quickly returns through the edge, the planner may classify the context as FAILED.

When price escapes but older swing structure is immediately ahead, the planner may show OBSTRUCTION even if the score is otherwise improving.


🧱 System Philosophy

AGPro planning tools are designed to help traders evaluate context before reacting.

This script follows that philosophy by turning a range breakout into a structured planning question: is the escape mature, confirmed, readable, and supported by clean room?


🔐 Non-Promise Statement

No indicator can guarantee continuation, reversal, or follow-through.

This tool provides structured visual context and rule-based attention markers. It does not provide certainty.


📉 Risk Disclosure

Trading involves risk. Market conditions can change quickly, and no script can remove uncertainty.

Users are responsible for their own analysis, risk management, and decisions.

This script is for educational and analytical use only and does not provide financial advice.


📚 Educational Note

Use the planner to study how mature ranges resolve, how escape quality changes after the first break, and how obstruction room affects the readability of breakout continuation.

## Source Code

````pine
// -------------------------------------------------
// Range Escape Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Range Escape Planner is a breakout-quality decision engine that evaluates
// whether price is escaping a mature range with enough structure to monitor.
// It maps the active range boundary, escape corridor, invalidation edge,
// obstruction room, retest quality, follow-through, and a 0-100 Escape Score
// so the chart answers what to watch next instead of printing generic signals.
// Version 1.5 clarifies range, escape-path, target, risk, and obstruction ownership.
// -------------------------------------------------

//@version=6
indicator("Range Escape Planner [AGPro Series]",
     shorttitle = "AG Pro REP",
     overlay = true,
     max_boxes_count = 40,
     max_labels_count = 220,
     max_lines_count = 90,
     max_bars_back = 800)

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
color monitorColor  = color.rgb(71, 85, 105)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
string ttSide = "Selects the planning side. Auto reads the active escape direction first, then uses range position and trend context while price is still inside the range."
string ttConfirm = "Close Confirmed is the publication default. Live Updating previews developing scores and visual context during the active bar; durable escape, failure, target, label, proof, and alert events still require a confirmed close."
string ttRange = "Lookback used to map the mature range boundary from previous bars. The current bar is tested against this reference instead of being included inside it."
string ttMinAge = "Minimum number of inside-range bars preferred before an escape can receive a stronger maturity score."
string ttAtr = "ATR length used for range normalization, escape distance, invalidation buffers, label offsets, and visual spacing."
string ttAtrBase = "ATR baseline used to classify whether volatility is expanding from normal or compressed conditions."
string ttWidth = "Maximum ATR-normalized range width that can still be treated as a mature planning range."
string ttIdeal = "Ideal ATR-normalized range width used by the maturity score. Very tiny and very wide ranges both receive weaker scores."
string ttEscape = "Minimum ATR-normalized close beyond the range boundary required before a new escape can be registered."
string ttFollow = "Minimum ATR-normalized progress beyond the escape edge that counts as stronger follow-through."
string ttRetest = "ATR-based tolerance around the broken boundary used to classify constructive retest holds."
string ttFailure = "ATR-based return back through the broken boundary used to classify failed escape context."
string ttTarget = "Range-height multiple used to project the forward target guide. It is a planning reference, not a forecast."
string ttObstruction = "Older swing window used to estimate whether price has clean room or an immediate obstruction in the escape path."
string ttReady = "Minimum 0-100 Escape Score required for Valid Escape state when confirmation and obstruction context also agree."
string ttWatch = "Minimum 0-100 Escape Score required for Escape Watch or Range Ready states."
string ttWindow = "Number of bars after an escape where follow-through, retest, failure, target-guide, and the Escape Rate proof remain actively evaluated."
string ttShowRange = "Shows the active mature range boundary box with a centered readable badge."
string ttShowCorridor = "Shows the projected escape corridor from the broken boundary toward the target guide with a centered readable badge."
string ttPreCorridor = "Allows a light pre-escape corridor while the range is mature. This helps the planner stay chart-first without waiting for the breakout bar."
string ttShowGuides = "Shows escape edge, invalidation, target guide, and obstruction reference lines when available."
string ttRightTags = "Shows filled right-side owner badges with prices for escape edge, invalidation, target, and obstruction references. Overlapping edge and invalidation references are merged into one badge."
string ttLabels = "Shows compact Range Ready, Escape Watch, Valid Escape, Retest Hold, Obstruction, and Failed labels with controlled spacing."
string ttContext = "Adds sparse context labels while a mature range or active escape is developing so the chart does not look empty."
string ttCooldown = "Minimum bars between event labels. Higher values reduce visual density."
string ttContextSpacing = "Minimum bars between sparse context labels."
string ttMaxLabels = "Maximum number of chart labels retained. Older labels are deleted first to preserve performance."
string ttLabelOffset = "ATR-based vertical offset that keeps labels away from candles."
string ttLabelScore = "Adds the 0-100 Escape Score to chart labels."
string ttLabelSize = "Controls all chart labels, right-side tags, and centered badges. Normal is the recommended publication default."
string ttShowPanel = "Shows or hides the AG Pro planning panel. It is visible by default for public-release readability."
string ttPanelLocation = "Moves the AG Pro panel to the preferred chart location."
string ttPanelTheme = "Switches the panel between the AGPro dark theme and a bright light theme."
string ttPanelFont = "Controls AG Pro panel text size. Normal is the recommended publication default."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Range Escape Engine"
string sideMode = input.string("Auto", "Planning Side", options = ["Auto", "Long Escape", "Short Escape"], group = groupEngine, tooltip = ttSide)
string confirmationMode = input.string("Close Confirmed", "Display Refresh", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = ttConfirm)
int rangeLookback = input.int(34, "Range Lookback", minval = 10, maxval = 220, group = groupEngine, tooltip = ttRange)
int minimumRangeAge = input.int(8, "Minimum Range Age", minval = 3, maxval = 80, group = groupEngine, tooltip = ttMinAge)
int atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupEngine, tooltip = ttAtr)
int atrBaselineLength = input.int(55, "ATR Baseline", minval = 10, maxval = 300, group = groupEngine, tooltip = ttAtrBase)
float maxMatureRangeAtr = input.float(5.20, "Maximum Mature Range ATR", minval = 1.00, maxval = 15.00, step = 0.10, group = groupEngine, tooltip = ttWidth)
float idealRangeAtr = input.float(2.30, "Ideal Range Width ATR", minval = 0.40, maxval = 8.00, step = 0.10, group = groupEngine, tooltip = ttIdeal)

string groupScoring = "Escape Score Model"
float minimumEscapeAtr = input.float(0.18, "Minimum Close Beyond Edge ATR", minval = 0.02, maxval = 2.00, step = 0.01, group = groupScoring, tooltip = ttEscape)
float followThroughAtr = input.float(0.65, "Follow-Through ATR", minval = 0.05, maxval = 3.00, step = 0.05, group = groupScoring, tooltip = ttFollow)
float retestToleranceAtr = input.float(0.24, "Retest Tolerance ATR", minval = 0.02, maxval = 1.50, step = 0.01, group = groupScoring, tooltip = ttRetest)
float failureBufferAtr = input.float(0.16, "Failed Escape Buffer ATR", minval = 0.00, maxval = 1.50, step = 0.01, group = groupScoring, tooltip = ttFailure)
float targetRangeMultiple = input.float(1.15, "Target Guide Range Multiple", minval = 0.25, maxval = 4.00, step = 0.05, group = groupScoring, tooltip = ttTarget)
int obstructionLookback = input.int(120, "Obstruction Lookback", minval = 30, maxval = 500, group = groupScoring, tooltip = ttObstruction)
int validEscapeThreshold = input.int(72, "Valid Escape Threshold", minval = 45, maxval = 95, group = groupScoring, tooltip = ttReady)
int watchThreshold = input.int(55, "Watch Threshold", minval = 25, maxval = 90, group = groupScoring, tooltip = ttWatch)
int escapeReviewWindow = input.int(28, "Escape Review Window", minval = 5, maxval = 160, group = groupScoring, tooltip = ttWindow)

string groupVisual = "Chart Visuals"
bool showRangeBox = input.bool(true, "Show Range Boundary Box", group = groupVisual, tooltip = ttShowRange)
bool showEscapeCorridor = input.bool(true, "Show Escape Corridor", group = groupVisual, tooltip = ttShowCorridor)
bool showPreEscapeCorridor = input.bool(false, "Show Pre-Escape Corridor", group = groupVisual, tooltip = ttPreCorridor)
bool showPlanningGuides = input.bool(true, "Show Risk / Target Guides", group = groupVisual, tooltip = ttShowGuides)
bool showRightTags = input.bool(true, "Show Right-Side Tags", group = groupVisual, tooltip = ttRightTags)
int projectionBars = input.int(42, "Forward Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = "Controls how far the range box, escape corridor, and guide lines extend to the right.")
int zoneTransparency = input.int(91, "Zone Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = "Transparency for range and escape zones. Higher values create lighter zones.")

string groupLabels = "Labels"
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
bool showContextLabels = input.bool(true, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContext)
int labelCooldownBars = input.int(18, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttCooldown)
int contextSpacingBars = input.int(72, "Context Label Spacing", minval = 8, maxval = 240, group = groupLabels, tooltip = ttContextSpacing)
int maxVisibleLabels = input.int(8, "Max Visible Labels", minval = 4, maxval = 80, group = groupLabels, tooltip = ttMaxLabels)
float labelOffsetAtr = input.float(0.90, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
bool showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttLabelScore)
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
string panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = ttPanelTheme)
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)

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

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    float result = 0.0
    if value <= idealValue
        result := f_norm_high_good(value, lowValue, idealValue)
    else
        result := f_norm_low_good(value, idealValue, highValue)
    result

f_text_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_position(string posText) =>
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
    theme == "Light" ? color.rgb(241, 245, 249) : panelBg

f_panel_border(string theme) =>
    theme == "Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string theme) =>
    theme == "Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string theme, int row) =>
    bool evenRow = row % 2 == 0
    if theme == "Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)
    else
        evenRow ? color.rgb(20, 31, 52) : panelBg

f_state_color(string stateText) =>
    switch stateText
        "Valid Escape" => bullColor
        "Escape Watch" => accentColor
        "Range Ready" => neutralColor
        "Mature Range" => accentColor
        "Retest Hold" => bullColor
        "Obstruction" => neutralColor
        "Failed" => bearColor
        "Target Reached" => bullColor
        "Wait Range" => monitorColor
        => panelLabelCol

f_text_on(color bg) =>
    float luminance = color.r(bg) * 0.299 + color.g(bg) * 0.587 + color.b(bg) * 0.114
    luminance > 150.0 ? color.rgb(15, 23, 42) : headerText

f_score_grade(int scoreValue) =>
    scoreValue >= 85 ? "A+" : scoreValue >= 76 ? "A" : scoreValue >= 66 ? "B" : scoreValue >= 55 ? "C" : scoreValue >= 42 ? "D" : "E"

f_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_short_action(string stateText) =>
    switch stateText
        "Valid Escape" => "Risk edge"
        "Retest Hold" => "Retest hold"
        "Escape Watch" => "Wait F/T"
        "Range Ready" => "Edge watch"
        "Mature Range" => "Prepare"
        "Obstruction" => "Room check"
        "Failed" => "Stand down"
        "Target Reached" => "Review extension"
        => "Wait"

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_right)

f_trim_labels(array<label> labels, int maxCount) =>
    int labelCount = array.size(labels)
    if labelCount > maxCount
        int removeCount = labelCount - maxCount
        for idx = 0 to removeCount - 1
            label oldLabel = array.shift(labels)
            label.delete(oldLabel)

f_set_tag(label tag, int x, float y, string textValue, color bgColor, string sizeText) =>
    label.set_xy(tag, x, y)
    label.set_text(tag, textValue)
    label.set_color(tag, color.new(bgColor, 4))
    label.set_textcolor(tag, f_text_on(bgColor))
    label.set_size(tag, f_text_size(sizeText))
    label.set_style(tag, label.style_label_left)

// -------------------------------------------------
// Core measurements
// -------------------------------------------------
bool confirmedBar = barstate.isconfirmed
bool livePreview = confirmationMode == "Live Updating"
float atrRaw = ta.atr(atrLength)
float safeAtr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
float atrBase = ta.sma(atrRaw, atrBaselineLength)
float atrRatio = not na(atrBase) and atrBase > 0.0 ? safeAtr / atrBase : 1.0
float atrSlope = not na(atrRaw[5]) and atrRaw[5] > 0.0 ? (safeAtr - atrRaw[5]) / atrRaw[5] : 0.0

float emaFast = ta.ema(close, 21)
float emaSlow = ta.ema(close, 55)
int trendDir = close >= emaSlow and emaFast >= emaSlow ? 1 : close <= emaSlow and emaFast <= emaSlow ? -1 : close >= emaSlow ? 1 : -1

float rangeHigh = ta.highest(high[1], rangeLookback)
float rangeLow = ta.lowest(low[1], rangeLookback)
bool validRange = not na(rangeHigh) and not na(rangeLow) and rangeHigh > rangeLow
float rangeHeight = validRange ? math.max(rangeHigh - rangeLow, syminfo.mintick) : safeAtr
float rangeMid = validRange ? (rangeHigh + rangeLow) * 0.5 : close
float rangeAtr = rangeHeight / safeAtr
float rangeWidthBase = ta.sma(rangeHeight, atrBaselineLength)
float rangeWidthRatio = not na(rangeWidthBase) and rangeWidthBase > 0.0 ? rangeHeight / rangeWidthBase : 1.0
float rangePosition = validRange ? f_clamp((close - rangeLow) / rangeHeight, 0.0, 1.0) : 0.5

bool insideRange = validRange and close <= rangeHigh and close >= rangeLow
bool rangeWidthAcceptable = rangeAtr <= maxMatureRangeAtr and rangeAtr >= 0.45
var int rangeAge = 0
rangeAge := insideRange and rangeWidthAcceptable ? nz(rangeAge[1]) + 1 : 0
int priorRangeAge = nz(rangeAge[1])
bool rangeMature = rangeAge >= minimumRangeAge and rangeWidthAcceptable
bool priorRangeMature = priorRangeAge >= minimumRangeAge and nz(rangeAtr[1], rangeAtr) <= maxMatureRangeAtr

float bullEscapeDistanceAtr = validRange ? math.max(close - rangeHigh, 0.0) / safeAtr : 0.0
float bearEscapeDistanceAtr = validRange ? math.max(rangeLow - close, 0.0) / safeAtr : 0.0
bool rawBullEscape = validRange and bullEscapeDistanceAtr >= minimumEscapeAtr
bool rawBearEscape = validRange and bearEscapeDistanceAtr >= minimumEscapeAtr
int detectedEscapeDir = rawBullEscape and not rawBearEscape ? 1 : rawBearEscape and not rawBullEscape ? -1 : 0

int autoPlanDir = detectedEscapeDir != 0 ? detectedEscapeDir : rangePosition >= 0.58 ? 1 : rangePosition <= 0.42 ? -1 : trendDir
int manualPlanDir = sideMode == "Long Escape" ? 1 : sideMode == "Short Escape" ? -1 : autoPlanDir

// -------------------------------------------------
// Active escape state
// -------------------------------------------------
var int activeDir = 0
var int activeStartBar = na
var int activeRangeAge = 0
var float activeTop = na
var float activeBottom = na
var float activeEdge = na
var float activeInvalidation = na
var float activeTarget = na
var float activeRangeHeight = na
var float activeRangeAtr = na
var bool activeFailed = false
var bool activeTargetReached = false
var int lastEscapeBar = na

int barsSinceEscape = activeDir != 0 and not na(activeStartBar) ? bar_index - activeStartBar : 100000
bool escapeExpired = activeDir != 0 and barsSinceEscape > escapeReviewWindow
bool canStartEscape = activeDir == 0 or activeFailed or escapeExpired or detectedEscapeDir != activeDir
bool newEscapeEvent = confirmedBar and detectedEscapeDir != 0 and priorRangeMature and canStartEscape and (na(lastEscapeBar) or bar_index - lastEscapeBar >= labelCooldownBars)

if newEscapeEvent
    activeDir := detectedEscapeDir
    activeStartBar := bar_index
    activeRangeAge := priorRangeAge
    activeTop := rangeHigh
    activeBottom := rangeLow
    activeRangeHeight := rangeHeight
    activeRangeAtr := rangeAtr
    activeEdge := detectedEscapeDir == 1 ? rangeHigh : rangeLow
    activeInvalidation := detectedEscapeDir == 1 ? rangeHigh - safeAtr * failureBufferAtr : rangeLow + safeAtr * failureBufferAtr
    activeTarget := activeEdge + detectedEscapeDir * rangeHeight * targetRangeMultiple
    activeFailed := false
    activeTargetReached := false
    lastEscapeBar := bar_index

bool hasActiveEscape = activeDir != 0 and not na(activeEdge)
int referenceDir = hasActiveEscape ? activeDir : manualPlanDir
float referenceTop = hasActiveEscape ? activeTop : rangeHigh
float referenceBottom = hasActiveEscape ? activeBottom : rangeLow
float referenceHeight = hasActiveEscape ? activeRangeHeight : rangeHeight
float referenceEdge = hasActiveEscape ? activeEdge : referenceDir == 1 ? rangeHigh : rangeLow
float referenceInvalidation = hasActiveEscape ? activeInvalidation : referenceDir == 1 ? rangeHigh - safeAtr * failureBufferAtr : rangeLow + safeAtr * failureBufferAtr
float referenceTarget = hasActiveEscape ? activeTarget : referenceEdge + referenceDir * referenceHeight * targetRangeMultiple
int scoreRangeAge = hasActiveEscape ? activeRangeAge : rangeAge
float scoreRangeAtr = hasActiveEscape ? activeRangeAtr : rangeAtr

bool failureReturn = hasActiveEscape and (activeDir == 1 ? close < activeEdge - safeAtr * failureBufferAtr : close > activeEdge + safeAtr * failureBufferAtr)
bool failedEscapeEvent = confirmedBar and hasActiveEscape and not activeFailed and failureReturn
if failedEscapeEvent
    activeFailed := true

bool targetGuideTouchedRaw = hasActiveEscape and (activeDir == 1 ? high >= activeTarget : low <= activeTarget)
if confirmedBar and targetGuideTouchedRaw
    activeTargetReached := true
bool targetGuideTouched = activeTargetReached or (livePreview and targetGuideTouchedRaw)
bool retestProbe = hasActiveEscape and barsSinceEscape > 0 and (activeDir == 1 ? low <= activeEdge + safeAtr * retestToleranceAtr : high >= activeEdge - safeAtr * retestToleranceAtr)
bool retestHold = hasActiveEscape and retestProbe and not activeFailed and (activeDir == 1 ? close > activeEdge : close < activeEdge)
bool retestHoldEvent = confirmedBar and retestHold and not (retestHold[1] == true)

// -------------------------------------------------
// Escape follow-rate proof (Confirm Rate)
// -------------------------------------------------
// When a new escape is registered beyond a mature range edge, does price follow
// through 0.75 ATR in the escape direction before returning through the
// invalidation edge or the review window expires? Counted once per registered
// escape. A return through the invalidation edge, or a window expiry with no
// follow-through, is treated as not-followed (conservative).
float efMargin = math.max(nz(safeAtr), syminfo.mintick) * 0.75
var int   efTotal = 0
var int   efWon    = 0
var bool  efPend    = false
var int   efDir      = 0
var float efAnchor    = na
var float efFail       = na
var int   efLeft        = 0

if barstate.isconfirmed
    if efPend and not na(efAnchor) and not na(efFail)
        bool efFailed = efDir > 0 ? close < efFail : close > efFail
        bool efFollowed = efDir > 0 ? close >= efAnchor + efMargin : close <= efAnchor - efMargin
        if efFailed
            efTotal += 1
            efPend := false
        else if efFollowed
            efTotal += 1
            efWon += 1
            efPend := false
        else
            efLeft -= 1
            if efLeft <= 0
                efTotal += 1
                efPend := false
    if newEscapeEvent and detectedEscapeDir != 0 and not efPend
        efDir := detectedEscapeDir
        efAnchor := close
        efFail := activeInvalidation
        efLeft := escapeReviewWindow
        efPend := true

float efRate = efTotal > 0 ? efWon / efTotal * 100.0 : na
string escapeRateRead = efTotal > 0 ? str.tostring(math.round(efRate)) + "% (" + str.tostring(efTotal) + ")" : "Building"

// -------------------------------------------------
// Score model
// -------------------------------------------------
float barRange = math.max(high - low, syminfo.mintick)
float bodyShare = math.abs(close - open) / barRange
float directionalCloseLocation = referenceDir == 1 ? (close - low) / barRange : (high - close) / barRange
float closeEfficiencyScore = f_clamp(directionalCloseLocation * 60.0 + bodyShare * 40.0, 0.0, 100.0)
float closeBeyondAtr = math.max(referenceDir == 1 ? close - referenceEdge : referenceEdge - close, 0.0) / safeAtr
float followProgressAtr = hasActiveEscape ? math.max(referenceDir == 1 ? close - activeEdge : activeEdge - close, 0.0) / safeAtr : closeBeyondAtr
float targetDistanceAtr = math.max(math.abs(referenceTarget - referenceEdge) / safeAtr, 0.10)

float ageScore = f_norm_high_good(scoreRangeAge, minimumRangeAge * 0.40, minimumRangeAge * 2.20)
float widthScore = f_peak_score(scoreRangeAtr, 0.55, idealRangeAtr, maxMatureRangeAtr + 1.20)
float stabilityScore = f_norm_low_good(rangeWidthRatio, 0.70, 1.45)
float maturityScore = f_clamp(ageScore * 0.55 + widthScore * 0.32 + stabilityScore * 0.13, 0.0, 100.0)
float closeBeyondScore = f_norm_high_good(closeBeyondAtr, minimumEscapeAtr * 0.35, minimumEscapeAtr + 0.95)
float volatilityScore = f_clamp(f_peak_score(atrRatio, 0.72, 1.34, 2.65) * 0.72 + f_norm_high_good(atrSlope, -0.02, 0.18) * 0.28, 0.0, 100.0)
float followThroughScore = f_clamp(f_norm_high_good(followProgressAtr, minimumEscapeAtr * 0.50, followThroughAtr) * 0.62 + closeEfficiencyScore * 0.38, 0.0, 100.0)
float retestScore = activeFailed ? 0.0 : retestHold ? 100.0 : retestProbe ? 38.0 : hasActiveEscape ? 58.0 : 52.0

float olderObstacleHigh = ta.highest(high[1], obstructionLookback)
float olderObstacleLow = ta.lowest(low[1], obstructionLookback)
float obstructionLevel = referenceDir == 1 ? olderObstacleHigh : olderObstacleLow
bool hasObstruction = not na(obstructionLevel) and (referenceDir == 1 ? obstructionLevel > close : obstructionLevel < close)
float obstructionAtr = hasObstruction ? math.abs(obstructionLevel - close) / safeAtr : targetDistanceAtr + 1.0
float requiredRoomAtr = math.max(targetDistanceAtr * 0.75, 0.85)
float obstructionScore = hasObstruction ? f_norm_high_good(obstructionAtr, 0.20, requiredRoomAtr) : 100.0
bool nearObstruction = hasObstruction and obstructionAtr < requiredRoomAtr * 0.55

float rawEscapeScore = maturityScore * 0.22 + closeBeyondScore * 0.22 + volatilityScore * 0.17 + followThroughScore * 0.17 + retestScore * 0.12 + obstructionScore * 0.10
bool tooHot = atrRatio > 2.65 and closeEfficiencyScore < 58.0
float cappedScore = rawEscapeScore
if not hasActiveEscape and not rangeMature
    cappedScore := math.min(cappedScore, 52.0)
if nearObstruction
    cappedScore := math.min(cappedScore, 82.0)
if tooHot
    cappedScore := math.min(cappedScore, 58.0)
if activeFailed
    cappedScore := math.min(cappedScore, 34.0)
int escapeScore = int(math.round(f_clamp(cappedScore, 0.0, 100.0)))

// -------------------------------------------------
// State and action
// -------------------------------------------------
string confirmationState = "Wait"
if activeFailed
    confirmationState := "Failed"
else if targetGuideTouched
    confirmationState := "Target Reached"
else if retestHold
    confirmationState := "Retest Hold"
else if hasActiveEscape and followProgressAtr >= followThroughAtr and closeEfficiencyScore >= 58.0
    confirmationState := "Follow-Through"
else if hasActiveEscape
    confirmationState := "Escaping"
else if rangeMature and (rangePosition >= 0.72 or rangePosition <= 0.28)
    confirmationState := "Edge Watch"
else if rangeMature
    confirmationState := "Building"

string plannerState = "Wait Range"
if activeFailed
    plannerState := "Failed"
else if targetGuideTouched
    plannerState := "Target Reached"
else if nearObstruction and hasActiveEscape
    plannerState := "Obstruction"
else if retestHold
    plannerState := "Retest Hold"
else if hasActiveEscape and escapeScore >= validEscapeThreshold and (confirmationState == "Follow-Through" or confirmationState == "Retest Hold") and not nearObstruction
    plannerState := "Valid Escape"
else if hasActiveEscape and escapeScore >= watchThreshold
    plannerState := "Escape Watch"
else if rangeMature and escapeScore >= watchThreshold and (rangePosition >= 0.68 or rangePosition <= 0.32)
    plannerState := "Range Ready"
else if rangeMature
    plannerState := "Mature Range"

string actionState = "Wait"
if plannerState == "Valid Escape"
    actionState := "Monitor risk edge"
else if plannerState == "Retest Hold"
    actionState := "Review continuation"
else if plannerState == "Escape Watch"
    actionState := "Wait follow-through"
else if plannerState == "Range Ready"
    actionState := "Watch escape edge"
else if plannerState == "Mature Range"
    actionState := "Prepare plan"
else if plannerState == "Obstruction"
    actionState := "Review room"
else if plannerState == "Failed"
    actionState := "Stand down"
else if plannerState == "Target Reached"
    actionState := "Review extension"

color stateColor = f_state_color(plannerState)
color sideColor = referenceDir == 1 ? bullColor : bearColor
string sideText = referenceDir == 1 ? "Long" : "Short"
string obstructionText = hasObstruction ? (nearObstruction ? "Near" : "Room") + " / " + str.tostring(obstructionAtr, "#.00") + " ATR" : "Clean / " + str.tostring(obstructionAtr, "#.00") + " ATR"

bool rangeReadyEvent = confirmedBar and plannerState == "Range Ready" and plannerState[1] != "Range Ready"
bool validEscapeEvent = confirmedBar and plannerState == "Valid Escape" and plannerState[1] != "Valid Escape"
bool escapeWatchEvent = confirmedBar and plannerState == "Escape Watch" and plannerState[1] != "Escape Watch"
bool obstructionEvent = confirmedBar and plannerState == "Obstruction" and plannerState[1] != "Obstruction"
bool targetReachedEvent = confirmedBar and plannerState == "Target Reached" and plannerState[1] != "Target Reached"

// -------------------------------------------------
// Visual zones and guides
// -------------------------------------------------
int leftEdge = math.max((hasActiveEscape ? activeStartBar - rangeLookback : bar_index - rangeLookback), 0)
int rightEdge = bar_index + projectionBars
float boxTop = referenceTop
float boxBottom = referenceBottom
string rangeBadgeText = (hasActiveEscape ? "RANGE BASE" : rangeMature ? "MATURE RANGE" : "RANGE BUILDING") + "\nAGE " + str.tostring(scoreRangeAge)
color rangeColor = activeFailed ? bearColor : hasActiveEscape ? sideColor : rangeMature ? accentColor : panelLabelCol
int rangeFillTransparency = activeFailed ? 97 : int(math.min(zoneTransparency + 4, 96))
int corridorFillTransparency = nearObstruction ? int(math.min(zoneTransparency + 2, 96)) : zoneTransparency

var box rangeBox = na
var box escapeCorridor = na
var label rangeBadge = na
var label corridorBadge = na
var line edgeLine = na
var line invalidationLine = na
var line targetLine = na
var line obstructionLine = na
var label edgeTag = na
var label invalidationTag = na
var label targetTag = na
var label obstructionTag = na

if showRangeBox and validRange
    if na(rangeBox)
        rangeBox := box.new(left = leftEdge, top = boxTop, right = rightEdge, bottom = boxBottom, xloc = xloc.bar_index, bgcolor = color.new(rangeColor, rangeFillTransparency), border_color = color.new(rangeColor, activeFailed ? 55 : 35), border_width = 1)
    else
        box.set_left(rangeBox, leftEdge)
        box.set_right(rangeBox, rightEdge)
        box.set_top(rangeBox, boxTop)
        box.set_bottom(rangeBox, boxBottom)
        box.set_bgcolor(rangeBox, color.new(rangeColor, rangeFillTransparency))
        box.set_border_color(rangeBox, color.new(rangeColor, activeFailed ? 55 : 35))
    int badgeX = int(math.round((leftEdge + rightEdge) * 0.5))
    float badgeY = (boxTop + boxBottom) * 0.5
    if na(rangeBadge)
        rangeBadge := label.new(badgeX, badgeY, rangeBadgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(monitorColor, 3), textcolor = f_text_on(monitorColor), size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        label.set_xy(rangeBadge, badgeX, badgeY)
        label.set_text(rangeBadge, rangeBadgeText)
        label.set_color(rangeBadge, color.new(monitorColor, 3))
        label.set_textcolor(rangeBadge, f_text_on(monitorColor))
        label.set_size(rangeBadge, f_text_size(labelFontSize))
else
    if not na(rangeBox)
        box.delete(rangeBox)
        rangeBox := na
    if not na(rangeBadge)
        label.delete(rangeBadge)
        rangeBadge := na

bool showCorridorNow = showEscapeCorridor and validRange and not activeFailed and (hasActiveEscape or (showPreEscapeCorridor and rangeMature))
float corridorTop = math.max(referenceEdge, referenceTarget)
float corridorBottom = math.min(referenceEdge, referenceTarget)
string corridorText = "ESCAPE PATH\nQ " + str.tostring(escapeScore)
color corridorColor = activeFailed ? bearColor : nearObstruction ? neutralColor : hasActiveEscape ? sideColor : accentColor

if showCorridorNow
    int corridorLeft = hasActiveEscape ? activeStartBar : bar_index
    if na(escapeCorridor)
        escapeCorridor := box.new(left = corridorLeft, top = corridorTop, right = rightEdge, bottom = corridorBottom, xloc = xloc.bar_index, bgcolor = color.new(corridorColor, corridorFillTransparency), border_color = color.new(corridorColor, 25), border_width = 1)
    else
        box.set_left(escapeCorridor, corridorLeft)
        box.set_right(escapeCorridor, rightEdge)
        box.set_top(escapeCorridor, corridorTop)
        box.set_bottom(escapeCorridor, corridorBottom)
        box.set_bgcolor(escapeCorridor, color.new(corridorColor, corridorFillTransparency))
        box.set_border_color(escapeCorridor, color.new(corridorColor, 25))
    int corridorBadgeX = int(math.round((corridorLeft + rightEdge) * 0.5))
    float corridorBadgeY = (corridorTop + corridorBottom) * 0.5
    if na(corridorBadge)
        corridorBadge := label.new(corridorBadgeX, corridorBadgeY, corridorText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(corridorColor, 4), textcolor = f_text_on(corridorColor), size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        label.set_xy(corridorBadge, corridorBadgeX, corridorBadgeY)
        label.set_text(corridorBadge, corridorText)
        label.set_color(corridorBadge, color.new(corridorColor, 4))
        label.set_textcolor(corridorBadge, f_text_on(corridorColor))
        label.set_size(corridorBadge, f_text_size(labelFontSize))
else
    if not na(escapeCorridor)
        box.delete(escapeCorridor)
        escapeCorridor := na
    if not na(corridorBadge)
        label.delete(corridorBadge)
        corridorBadge := na

if showPlanningGuides and validRange
    color edgeColor = hasActiveEscape ? color.new(sideColor, 0) : color.new(panelLabelCol, 25)
    if na(edgeLine)
        edgeLine := line.new(leftEdge, referenceEdge, rightEdge, referenceEdge, xloc = xloc.bar_index, extend = extend.none, color = edgeColor, width = 2)
    else
        line.set_xy1(edgeLine, leftEdge, referenceEdge)
        line.set_xy2(edgeLine, rightEdge, referenceEdge)
        line.set_color(edgeLine, edgeColor)
    color invalidationColor = activeFailed ? color.new(bearColor, 0) : color.new(neutralColor, 10)
    if na(invalidationLine)
        invalidationLine := line.new(leftEdge, referenceInvalidation, rightEdge, referenceInvalidation, xloc = xloc.bar_index, extend = extend.none, color = invalidationColor, width = 1, style = line.style_dashed)
    else
        line.set_xy1(invalidationLine, leftEdge, referenceInvalidation)
        line.set_xy2(invalidationLine, rightEdge, referenceInvalidation)
        line.set_color(invalidationLine, invalidationColor)
    if na(targetLine)
        targetLine := line.new(hasActiveEscape ? activeStartBar : bar_index, referenceTarget, rightEdge, referenceTarget, xloc = xloc.bar_index, extend = extend.none, color = color.new(sideColor, 15), width = 1, style = line.style_dotted)
    else
        line.set_xy1(targetLine, hasActiveEscape ? activeStartBar : bar_index, referenceTarget)
        line.set_xy2(targetLine, rightEdge, referenceTarget)
        line.set_color(targetLine, color.new(sideColor, 15))
    if hasObstruction
        color obstructionColor = nearObstruction ? neutralColor : color.new(panelLabelCol, 25)
        if na(obstructionLine)
            obstructionLine := line.new(bar_index - math.min(obstructionLookback, 160), obstructionLevel, rightEdge, obstructionLevel, xloc = xloc.bar_index, extend = extend.none, color = obstructionColor, width = 1, style = line.style_dashed)
        else
            line.set_xy1(obstructionLine, bar_index - math.min(obstructionLookback, 160), obstructionLevel)
            line.set_xy2(obstructionLine, rightEdge, obstructionLevel)
            line.set_color(obstructionLine, obstructionColor)
    else
        if not na(obstructionLine)
            line.delete(obstructionLine)
            obstructionLine := na
else
    if not na(edgeLine)
        line.delete(edgeLine)
        edgeLine := na
    if not na(invalidationLine)
        line.delete(invalidationLine)
        invalidationLine := na
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na
    if not na(obstructionLine)
        line.delete(obstructionLine)
        obstructionLine := na

if showRightTags and validRange
    if na(edgeTag)
        edgeTag := label.new(rightEdge, referenceEdge, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left)
    if na(invalidationTag)
        invalidationTag := label.new(rightEdge, referenceInvalidation, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left)
    if na(targetTag)
        targetTag := label.new(rightEdge, referenceTarget, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left)
    bool mergeEdgeTags = activeFailed or math.abs(referenceEdge - referenceInvalidation) <= safeAtr * 0.08
    if mergeEdgeTags
        label.set_text(edgeTag, "")
        label.set_xy(edgeTag, rightEdge, referenceEdge)
        label.set_color(edgeTag, color.new(monitorColor, 100))
    else
        f_set_tag(edgeTag, rightEdge, referenceEdge, "ESCAPE EDGE  " + f_price(referenceEdge), hasActiveEscape ? sideColor : monitorColor, labelFontSize)
    string invalidationTagText = activeFailed ? "FAILED EDGE  " + f_price(referenceInvalidation) : mergeEdgeTags ? "EDGE / INVALIDATION  " + f_price(referenceInvalidation) : "INVALIDATION  " + f_price(referenceInvalidation)
    f_set_tag(invalidationTag, rightEdge, referenceInvalidation, invalidationTagText, activeFailed ? bearColor : neutralColor, labelFontSize)
    f_set_tag(targetTag, rightEdge, referenceTarget, (targetGuideTouched ? "TARGET HIT  " : "TARGET  ") + f_price(referenceTarget), targetGuideTouched ? bullColor : accentColor, labelFontSize)
    if hasObstruction
        if na(obstructionTag)
            obstructionTag := label.new(rightEdge, obstructionLevel, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left)
        f_set_tag(obstructionTag, rightEdge, obstructionLevel, "OBSTRUCTION  " + f_price(obstructionLevel), nearObstruction ? neutralColor : monitorColor, labelFontSize)
    else if not na(obstructionTag)
        label.delete(obstructionTag)
        obstructionTag := na
else
    if not na(edgeTag)
        label.delete(edgeTag)
        edgeTag := na
    if not na(invalidationTag)
        label.delete(invalidationTag)
        invalidationTag := na
    if not na(targetTag)
        label.delete(targetTag)
        targetTag := na
    if not na(obstructionTag)
        label.delete(obstructionTag)
        obstructionTag := na

plot(emaFast, "Fast Context EMA", color = color.new(panelLabelCol, 88), linewidth = 1)
plot(emaSlow, "Slow Context EMA", color = color.new(panelLabelCol, 82), linewidth = 1)

// -------------------------------------------------
// Labels and markers
// -------------------------------------------------
var int lastLabelBar = na
var array<label> eventLabels = array.new_label()

bool labelReady = na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars
bool contextReady = na(lastLabelBar) or bar_index - lastLabelBar >= contextSpacingBars
bool contextState = plannerState == "Mature Range" or plannerState == "Range Ready" or plannerState == "Escape Watch" or plannerState == "Valid Escape"
bool drawContextLabel = showContextLabels and contextReady and contextState
bool eventTrigger = newEscapeEvent or rangeReadyEvent or escapeWatchEvent or validEscapeEvent or retestHoldEvent or obstructionEvent or targetReachedEvent or failedEscapeEvent
bool drawEventLabel = confirmedBar and labelReady and ((showEventLabels and eventTrigger) or drawContextLabel)

if drawEventLabel
    bool drawEventContent = showEventLabels and eventTrigger
    string labelState = drawEventContent ? (failedEscapeEvent ? "Failed" : retestHoldEvent ? "Retest Hold" : obstructionEvent ? "Obstruction" : newEscapeEvent ? "Escape Watch" : plannerState) : plannerState
    string labelDisplay = labelState
    string labelAction = newEscapeEvent ? "Edge break" : f_short_action(labelState)
    string labelText = labelDisplay
    if showLabelScore and labelState != "Failed"
        labelText += "\nScore " + str.tostring(escapeScore)
    labelText += "\n" + labelAction
    float labelY = referenceDir == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    color labelColor = f_state_color(labelState)
    label eventLabel = label.new(x = bar_index, y = labelY, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = referenceDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(labelColor, 7), textcolor = f_text_on(labelColor), size = f_text_size(labelFontSize), textalign = text.align_center)
    array.push(eventLabels, eventLabel)
    f_trim_labels(eventLabels, maxVisibleLabels)
    lastLabelBar := bar_index

plotshape(newEscapeEvent and detectedEscapeDir == 1, title = "Long Escape Marker", style = shape.diamond, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(newEscapeEvent and detectedEscapeDir == -1, title = "Short Escape Marker", style = shape.diamond, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny)
plotshape(validEscapeEvent or retestHoldEvent, title = "Validated Escape Marker", style = shape.circle, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(failedEscapeEvent or obstructionEvent, title = "Escape Risk Marker", style = shape.circle, location = location.abovebar, color = color.new(neutralColor, 0), size = size.tiny)

// -------------------------------------------------
// Data window
// -------------------------------------------------
plot(escapeScore, title = "Escape Score", color = stateColor, display = display.data_window)
plot(maturityScore, title = "Range Maturity Score", color = accentColor, display = display.data_window)
plot(closeBeyondScore, title = "Close Beyond Range Score", color = bullColor, display = display.data_window)
plot(volatilityScore, title = "Volatility Expansion Score", color = neutralColor, display = display.data_window)
plot(followThroughScore, title = "Follow-Through Score", color = bearColor, display = display.data_window)
plot(retestScore, title = "Retest Quality Score", color = panelLabelCol, display = display.data_window)
plot(obstructionScore, title = "Obstruction Score", color = panelValueCol, display = display.data_window)
plot(efRate, title = "Escape Follow Rate", color = bullColor, display = display.data_window)

// -------------------------------------------------
// Panel
// -------------------------------------------------
string scoreRead = str.tostring(escapeScore) + " / " + f_score_grade(escapeScore) + " / " + plannerState
string ageRead = str.tostring(scoreRangeAge) + " bars / " + str.tostring(scoreRangeAtr, "#.00") + " ATR"
string confirmRead = confirmationState + " / " + sideText
string actionRead = actionState + " | Inv " + f_price(referenceInvalidation)
color confirmationColor = confirmationState == "Failed" ? bearColor : (confirmationState == "Follow-Through" or confirmationState == "Retest Hold" ? bullColor : neutralColor)
color panelStateColor = plannerState == "Wait Range" or plannerState == "Mature Range" ? f_panel_value(panelTheme) : stateColor
color escapeRateColor = na(efRate) ? f_panel_value(panelTheme) : efRate >= 60.0 ? bullColor : efRate >= 45.0 ? neutralColor : bearColor

var table panel = na
var string panelLocationCache = ""
var string panelThemeCache = ""

if showPanel and (na(panel) or panelLocationCache != panelLocation or panelThemeCache != panelTheme)
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_position(panelLocation), 2, 7, bgcolor = f_panel_bg(panelTheme), frame_color = f_panel_border(panelTheme), frame_width = 1, border_color = f_panel_border(panelTheme), border_width = 1)
    panelLocationCache := panelLocation
    panelThemeCache := panelTheme

if barstate.islast
    if showPanel and not na(panel)
        table.clear(panel, 0, 0, 1, 6)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Range Escape Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        f_panel_row(panel, 1, "Escape Score", scoreRead, panelStateColor, panelTheme, panelFontSize)
        f_panel_row(panel, 2, "Escape Rate", escapeRateRead, escapeRateColor, panelTheme, panelFontSize)
        f_panel_row(panel, 3, "Range Age", ageRead, scoreRangeAge >= minimumRangeAge ? accentColor : neutralColor, panelTheme, panelFontSize)
        f_panel_row(panel, 4, "Confirmation", confirmRead, confirmationColor, panelTheme, panelFontSize)
        f_panel_row(panel, 5, "Obstruction", obstructionText, nearObstruction ? neutralColor : bullColor, panelTheme, panelFontSize)
        f_panel_row(panel, 6, "Action", actionRead, panelStateColor, panelTheme, panelFontSize)

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    panelLocationCache := ""
    panelThemeCache := ""

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(rangeReadyEvent, title = "Range Ready", message = "Range Escape Planner: a mature range is near an escape edge. This is an attention marker, not a trade instruction.")
alertcondition(newEscapeEvent, title = "New Range Escape", message = "Range Escape Planner: price closed beyond a mature range boundary. Review escape quality and risk context.")
alertcondition(escapeWatchEvent, title = "Escape Watch", message = "Range Escape Planner: escape context is active but still needs stronger follow-through or retest confirmation.")
alertcondition(validEscapeEvent, title = "Valid Escape", message = "Range Escape Planner: escape quality reached Valid Escape state. This is an attention marker, not a trade instruction.")
alertcondition(retestHoldEvent, title = "Retest Hold", message = "Range Escape Planner: price retested the escape edge and held outside the prior range.")
alertcondition(obstructionEvent, title = "Obstruction Review", message = "Range Escape Planner: escape quality is active but the path has nearby obstruction room to review.")
alertcondition(targetReachedEvent, title = "Target Reached", message = "Range Escape Planner: price reached the active target-room guide. Review extension and risk context.")
alertcondition(failedEscapeEvent, title = "Failed Escape", message = "Range Escape Planner: price returned through the escape edge and the escape context failed.")
````
