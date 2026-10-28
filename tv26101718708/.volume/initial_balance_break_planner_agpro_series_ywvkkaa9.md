# Initial Balance Break Planner [AGPro Series]

- url: https://www.tradingview.com/script/yWvkKAA9-Initial-Balance-Break-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;08843b9f0893486782367a0c24c4b7a3
- version: 4.0

## Description

Initial Balance Break Planner [AGPro Series]


🧠 Core Idea

Is the Initial Balance break being accepted, or is it becoming vulnerable to failure back inside the balance?


📌 Overview / What it does

Initial Balance Break Planner [AGPro Series] is an intraday session planning tool built around the first major balance of the trading session. It maps a configurable Initial Balance window, tracks the first break beyond that balance, and evaluates whether that break has enough quality to deserve structured review. The default showcase workflow is designed for intraday charts up to 60 minutes.

The script produces a locked Initial Balance box, break review labels, acceptance labels, failure-risk labels, failed-IB markers, target rails, and an invalidation reference. The panel summarizes the active state through IB State, Break Side, Acceptance Score, Failure Risk, and Action.

It does not predict future price movement, automate trades, or tell the user what to buy or sell. It is a rule-based decision-support overlay for reading Initial Balance behavior with more structure.


🎯 Purpose & Design Philosophy

This script was built to solve a common intraday problem: many traders can see that price broke the first balance, but they still need a cleaner way to judge whether that break is accepted, stretched, weak, or vulnerable.

The tool is designed for traders who use session structure, Initial Balance concepts, intraday breakouts, and structured risk review. Its purpose is not to create another simple breakout signal. Its purpose is to turn the Initial Balance break into a practical planning framework.

The design philosophy is simple: map the balance, evaluate the break, show the risk, project the planning rails, and keep the next action readable.


⚡ Why This Script Is Different

Most opening-range tools focus on basic breakout direction, raw high/low levels, or target projections.

This script does NOT clone ORB Quality or Opening Range Failure Zones. ORB Quality is focused on opening range breakout quality and drive continuation. Opening Range Failure Zones is focused on failed opening range probes and reclaim zones.

Instead, Initial Balance Break Planner focuses on the post-IB decision layer: is the first Initial Balance break accepted, does the retest response support the break, where is the invalidation reference, where are the target rails, and what should the trader review next?


⚙️ Methodology

1. Context Detection

The script builds the Initial Balance from a configurable session window. The default uses the first 60 minutes of the New York regular session.

2. Reference Mapping

Once the IB window ends, the script locks the IB high, IB low, and midpoint. The box remains centered with an internal state label so the chart stays visually clear.

3. Reaction Evaluation

After the first break, the planner scores the setup using:

• IB width
• Break close quality
• Retest response
• Relative volume support
• Volatility fit

4. Visual Output

The chart displays break labels, acceptance labels, risk-review labels, failed-IB markers, target rails, and an invalidation rail. The panel converts the model into a compact next-action state.


🗺️ How to Read the Chart

The Initial Balance box represents the first session balance selected by the user.

Break labels show when price closes beyond the IB edge with enough buffer to start review.

Acceptance labels appear when the break has enough score, enough confirmation time, and controlled failure risk.

Failure-risk labels warn that the break is weakening or returning back inside the balance.

Target rails show measured planning references from the broken IB edge.

The invalidation rail marks the area where the break begins losing acceptance quality.

Panel colors summarize the current state:

• Teal → stronger acceptance or constructive long-side context
• Pink → bearish break side or failed context
• Amber → watch, risk review, or unresolved state
• Indigo / blue → active planning context


🚦 Signals & States

• IB READY → the Initial Balance has locked and the planner is ready to track the first break

• BREAK UP REVIEW → price closed beyond the upper IB edge and long-side review has started

• BREAK DOWN REVIEW → price closed beyond the lower IB edge and short-side review has started

• RETEST HOLD → price retested the broken IB edge without clearly losing it

• ACCEPTED → the break met the acceptance threshold with controlled failure risk

• RISK REVIEW → the break is not yet accepted and failure vulnerability is rising

• FAILED IB → price failed back inside the Initial Balance with elevated weakness context


🔔 Alerts Logic

Alerts trigger when the script detects:

• A bullish IB break review
• A bearish IB break review
• Bullish IB acceptance
• Bearish IB acceptance
• Failure-risk review
• Failed return back inside the IB

Alerts are attention markers only. They are not trade instructions.


🧩 Confluence Logic

The strongest context appears when the break close is clean, the IB width is balanced, volume is supportive, volatility is not overheated, and the retest response holds the broken edge.

When these elements align, the Acceptance Score improves and the panel can move from Observe Retest into Review Long or Review Short.


📊 When to Use

• Intraday markets with clear session structure
• 1-minute to 60-minute charts
• Index, futures, FX, and liquid crypto sessions
• Initial Balance breakout review
• Session expansion planning
• Post-break retest evaluation
• Risk and target planning after the first session balance breaks


⚠️ When NOT to Use

• Very low-liquidity symbols
• Extremely noisy micro timeframes
• Markets with poor session definition
• Events with abnormal volatility spikes
• Symbols where volume data is unreliable and should not be weighted heavily
• Higher timeframes where the selected IB session has little practical meaning
• 4H, daily, weekly, or monthly charts where a one-session Initial Balance cannot be mapped cleanly


🎛️ Key Inputs

• Initial Balance Window → defines the balance-building period

• Tracking Session → defines when break review can update

• Sensitivity → adjusts how selective the planner is

• Acceptance Lookback → controls the review window after the first break

• Minimum Acceptance Score → sets the threshold for accepted-break states

• Confirmation Mode → chooses confirmed-bar behavior or live updating

• Break Buffer ATR → controls how far price must close beyond the IB edge

• Retest Response Buffer ATR → controls retest tolerance around the broken edge

• Failure Buffer ATR → controls how quickly returning inside the IB raises risk

• Target Rail Multiples → control measured target references

• Max Visible IB Boxes → controls how many recent balance boxes stay on the chart

• Max Visible Labels → controls how many recent event labels stay on the chart

• Show IB Ready Labels → optionally displays a readiness label when the Initial Balance locks

• Visual Settings → control labels, box count, rail projection, and spacing

• Panel Settings → control panel visibility, location, theme, and font size


🖥️ Interface & Visual Design

The script uses a chart-first design. The Initial Balance box is the main anchor, and the centered box label keeps the active state visible without requiring a large dashboard.

Event labels are deliberately compact and offset away from candles. Target rails and invalidation rails are projected only after a break, so the chart remains clean during the balance-building phase.

The AG Pro panel uses a single merged blue header row and five compact rows so the user can quickly scan state, side, score, risk, and action.


🧪 Practical Usage Workflow

1. Read the panel after the Initial Balance locks.

2. Wait for price to break one IB edge.

3. Check whether the break receives a clean score or moves into risk review.

4. Watch the broken edge for retest behavior.

5. Use the target rails and invalidation rail as planning references.

6. Interpret the result within broader market context.


🔍 Interpretation Guidelines

The Acceptance Score is a quality score, not a prediction. Higher scores mean the break has better internal structure according to the script's rules.

Failure Risk is a warning layer. It rises when price loses acceptance quality, moves back inside the IB, shows weak close behavior, or lacks participation.

The Action row is the most practical summary. It helps the user decide whether the environment is still building, waiting, reviewing, accepted, vulnerable, or better left alone.


🚫 What This Script Is NOT

• Not a prediction engine
• Not financial advice
• Not auto trading
• Not guaranteed signals
• Not a generic ORB breakout system
• Not Opening Range Failure Zones
• Not a broad support/resistance or order-block map


⚠️ Limitations & Transparency

Initial Balance behavior changes across symbols, sessions, and timeframes. A 60-minute IB on one market may behave differently from the same window on another market.

Relative volume can be less useful on symbols where reported volume is incomplete or inconsistent.

Fast news events, thin liquidity, and unusual volatility can reduce the usefulness of any session-break model.

The script evaluates rule-based context only. It cannot know future order flow or guarantee what price will do next.


🧠 Market Context Notes

Initial Balance analysis is most useful when the session has a meaningful opening phase and a clear expansion phase.

A clean break usually needs more than a line cross. The break should show location, acceptance, participation, and controlled risk.

A weak break can still travel further, and a strong break can still fail. The script is designed to help structure the review, not remove uncertainty.


🧾 Use Case Examples

When price breaks above the IB high, receives a strong acceptance score, holds the broken edge on retest, and keeps failure risk low, the panel may move into Review Long.

When price breaks below the IB low but quickly returns back inside the balance with weak close quality, the panel may move into Failure Watch or Failed Back In.

When the IB is too wide, volatility is unstable, and the break lacks volume support, the planner can remain cautious even if price has crossed the edge.


🧱 System Philosophy

The AGPro Series approach is built around decision structure, not raw signal output.

Initial Balance Break Planner follows that philosophy by combining a visible session reference with a score, risk layer, target references, and a next-action panel.

The goal is to make the chart easier to interpret without making the chart crowded.


🔐 Non-Promise Statement

This script does not provide certainty.

It does not guarantee that an accepted break will continue or that a vulnerable break will reverse.

All outputs should be interpreted as structured analytical context.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own analysis, execution, and risk management.

This script is not financial advice and does not provide guaranteed trading outcomes.


📚 Educational Note

Initial Balance analysis can help traders study how a session moves from balance into expansion, but it should always be combined with broader market structure, liquidity, volatility, and personal execution rules.

## Source Code

````pine
// -------------------------------------------------
// Initial Balance Break Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Initial Balance Break Planner maps the first session balance, then evaluates
// whether the first break beyond that balance is being accepted or becoming
// vulnerable to reversal. It combines IB width, break close quality, retest
// behavior, relative volume, volatility fit, target rails, invalidation context,
// a clear next-action state and a persistent follow-through proof layer for
// intraday session planning. Version 1.3 adds bounded session ownership,
// collision-safe rail badges, and a stable accepted-break lifecycle.
// -------------------------------------------------

//@version=6
indicator("Initial Balance Break Planner [AGPro Series]",
     shorttitle = "AG Pro IBP",
     overlay = true,
     max_boxes_count = 20,
     max_labels_count = 120,
     max_lines_count = 20)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
color headerBg = color.rgb(37, 99, 235)
color headerText = color.rgb(245, 247, 250)
color panelBg = color.rgb(15, 23, 42)
color panelBorder = color.rgb(51, 65, 85)
color panelLabelCol = color.rgb(148, 163, 184)
color panelValueCol = color.rgb(226, 232, 240)
color bullColor = color.rgb(34, 197, 166)
color bearColor = color.rgb(244, 114, 182)
color neutralColor = color.rgb(245, 189, 92)
color accentColor = color.rgb(129, 140, 248)
color dangerColor = color.rgb(239, 68, 68)
color darkText = color.rgb(17, 24, 39)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupSession = "Initial Balance"
string ibSession = input.session("0930-1030", "Initial Balance Window", group = groupSession, tooltip = "Defines the time window used to build the Initial Balance. The default uses the first 60 minutes of the New York regular session.")
string trackingSession = input.session("0930-1600", "Tracking Session", group = groupSession, tooltip = "Defines the session window during which Initial Balance breaks, acceptance, failure risk, target rails, and alerts can update.")
string sessionTimezone = input.string("America/New_York", "Session Timezone", options = ["America/New_York", "Etc/UTC", "Europe/London", "Europe/Istanbul", "Asia/Tokyo", "Asia/Hong_Kong"], group = groupSession, tooltip = "Timezone applied to the Initial Balance and tracking sessions.")

string groupEngine = "Planner Engine"
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Aggressive"], group = groupEngine, tooltip = "Controls how selective the Initial Balance break model is. Conservative prefers cleaner width and acceptance conditions, while Aggressive allows more developing breaks to qualify.")
int acceptanceLookback = input.int(24, "Acceptance Lookback", minval = 4, maxval = 160, group = groupEngine, tooltip = "Maximum number of bars after the first Initial Balance break used to evaluate acceptance, retest response, and failure vulnerability.")
int minimumScore = input.int(68, "Minimum Acceptance Score", minval = 35, maxval = 95, group = groupEngine, tooltip = "Minimum 0-100 score required before the planner marks the Initial Balance break as accepted enough for structured review.")
string confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = "Close Confirmed updates break states, labels, and alerts only after bar close. Live Updating allows intrabar state changes.")
int confirmationBars = input.int(2, "Acceptance Confirmation Bars", minval = 1, maxval = 12, group = groupEngine, tooltip = "Minimum number of bars after the first break before acceptance can be confirmed. This helps avoid treating a single extension candle as durable acceptance.")
int atrLength = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine, tooltip = "ATR length used to normalize IB width, break buffer, retest tolerance, label offsets, invalidation rails, and volatility fit.")
int volumeLength = input.int(20, "Relative Volume Length", minval = 2, maxval = 200, group = groupEngine, tooltip = "Lookback used to compare current participation against recent average volume. On symbols with limited volume quality, this component remains only one part of the score.")
float breakBufferAtr = input.float(0.08, "Break Buffer ATR", minval = 0.0, maxval = 1.5, step = 0.01, group = groupEngine, tooltip = "Minimum ATR-scaled close beyond the Initial Balance edge required to start break review.")
float retestBufferAtr = input.float(0.16, "Retest Response Buffer ATR", minval = 0.0, maxval = 2.0, step = 0.01, group = groupEngine, tooltip = "ATR-scaled tolerance around the broken Initial Balance edge used to judge whether a retest is holding or weakening.")
float failureBufferAtr = input.float(0.10, "Failure Buffer ATR", minval = 0.0, maxval = 2.0, step = 0.01, group = groupEngine, tooltip = "ATR-scaled distance back inside the Initial Balance that raises failure risk after a break.")

string groupProof = "Confirm-Rate Proof"
int proofWindowBars = input.int(24, "Proof Window Bars", minval = 4, maxval = 160, group = groupProof, tooltip = "Bars after an Accepted break used to resolve the follow-through proof. A win is recorded if Target Rail 1 is reached before the break invalidates within this window.")
int minimumProofSamples = input.int(8, "Minimum Proof Samples", minval = 3, maxval = 100, group = groupProof, tooltip = "Minimum resolved Accepted-break episodes required before the panel displays the historical follow-through rate.")

string groupVisual = "Chart Visuals"
bool showIbBox = input.bool(true, "Show Initial Balance Box", group = groupVisual, tooltip = "Displays the active Initial Balance as a centered session box with a compact state badge.")
bool showTargetRails = input.bool(true, "Show Target / Invalidation Rails", group = groupVisual, tooltip = "Displays target rails and an invalidation rail after the first Initial Balance break. These are planning references, not trade instructions.")
float targetOneMultiple = input.float(1.00, "Target Rail 1 x IB", minval = 0.25, maxval = 4.00, step = 0.05, group = groupVisual, tooltip = "First target rail distance measured from the broken Initial Balance edge in multiples of the IB range.")
float targetTwoMultiple = input.float(1.50, "Target Rail 2 x IB", minval = 0.25, maxval = 6.00, step = 0.05, group = groupVisual, tooltip = "Second target rail distance measured from the broken Initial Balance edge in multiples of the IB range.")
int forwardBars = input.int(28, "Forward Render Bars", minval = 8, maxval = 240, group = groupVisual, tooltip = "Controls how far the Initial Balance box and planning rails extend to the right.")
int railTagOffsetBars = input.int(9, "Rail Badge Offset Bars", minval = 2, maxval = 40, group = groupVisual, tooltip = "Moves the owned T1, T2, and Invalidation badges beyond the active IB box. Connector segments preserve their exact price ownership.")
bool useSmartRailLanes = input.bool(true, "Use Smart Rail Lanes", group = groupVisual, tooltip = "Automatically separates nearby T1, T2, and Invalidation badges using font-aware ATR spacing while connector segments keep each badge tied to its exact rail price.")
bool adaptiveProjection = input.bool(true, "Adaptive HTF Projection", group = groupVisual, tooltip = "Shortens forward rendering on daily, weekly, and monthly charts so screenshots remain balanced.")
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupVisual, tooltip = "Displays compact IB READY, BREAK REVIEW, ACCEPTED, RETEST HOLD, RISK REVIEW, and FAILED IB labels with controlled spacing.")
bool showReadyLabels = input.bool(false, "Show IB Ready Labels", group = groupVisual, tooltip = "Displays an IB READY label when the Initial Balance locks. Disabled by default because the box and panel already communicate readiness.")
bool showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupVisual, tooltip = "Adds occasional context labels during an unresolved break. Disabled by default for a cleaner publication preset.")
int labelCooldownBars = input.int(20, "Label Cooldown Bars", minval = 0, maxval = 120, group = groupVisual, tooltip = "Minimum spacing between event labels. Higher values reduce label density.")
int contextSpacingBars = input.int(56, "Context Label Spacing", minval = 8, maxval = 240, group = groupVisual, tooltip = "Minimum spacing between sparse context labels during active Initial Balance break review.")
int maxVisibleBoxes = input.int(2, "Max Visible IB Boxes", minval = 1, maxval = 12, group = groupVisual, tooltip = "Caps recent Initial Balance boxes retained on the chart. Lower values keep the default publication view cleaner.")
int maxVisibleLabels = input.int(5, "Max Visible Labels", minval = 4, maxval = 40, group = groupVisual, tooltip = "Caps recent event labels retained on the chart. The default keeps the chart active without creating a label cluster.")
int labelHistoryBars = input.int(220, "Label History Bars", minval = 40, maxval = 2000, group = groupVisual, tooltip = "Maximum age in bars for historical event badges. Active IB objects and the panel are not affected.")
float labelOffsetAtr = input.float(0.85, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupVisual, tooltip = "Offsets labels away from candles using ATR so they remain readable above or below price.")
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisual, tooltip = "Controls all chart label sizes, including the centered Initial Balance box badge. Normal is the publication default.")

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = "Shows or hides the AG Pro planning panel. The default is visible for publication-ready chart context.")
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = "Moves the AG Pro panel to the preferred chart location.")
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = groupPanel, tooltip = "Switches the panel between premium AGPro surfaces and a clean light theme while preserving the blue header row.")
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel, tooltip = "Controls panel text size. Normal is the default AGPro publication setting.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_text_on(color bg) =>
    float bright = (color.r(bg) * 299 + color.g(bg) * 587 + color.b(bg) * 114) / 1000
    bright >= 145 ? darkText : headerText

f_norm_high_good(float value, float weak, float strong) =>
    float span = strong - weak
    span == 0.0 or na(value) ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low_good(float value, float good, float bad) =>
    float span = bad - good
    span == 0.0 or na(value) ? 0.0 : f_clamp((bad - value) / span * 100.0, 0.0, 100.0)

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    float result = 0.0
    if not na(value)
        result := value <= idealValue ? f_norm_high_good(value, lowValue, idealValue) : f_norm_low_good(value, idealValue, highValue)
    result

f_size(string sizeName) =>
    switch sizeName
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_panel_position(string positionName) =>
    switch positionName
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
    theme == "Clean Light" ? color.rgb(241, 245, 249) : theme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_border(string theme) =>
    theme == "Clean Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_panel_semantic(color semanticColor, string theme) =>
    color result = semanticColor
    if theme == "Clean Light"
        if semanticColor == bullColor
            result := color.rgb(4, 120, 87)
        else if semanticColor == bearColor
            result := color.rgb(190, 24, 93)
        else if semanticColor == neutralColor
            result := color.rgb(180, 83, 9)
        else if semanticColor == accentColor
            result := color.rgb(79, 70, 229)
        else if semanticColor == dangerColor
            result := color.rgb(185, 28, 28)
        else if semanticColor == panelLabelCol
            result := color.rgb(71, 85, 105)
        else if semanticColor == panelValueCol
            result := color.rgb(15, 23, 42)
    result

f_row_bg(string theme, int row) =>
    bool evenRow = row % 2 == 0
    theme == "Clean Light" ? (evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)) : theme == "Slate" ? (evenRow ? color.rgb(37, 49, 70) : color.rgb(30, 41, 59)) : (evenRow ? color.rgb(20, 31, 52) : panelBg)

f_grade(float score) =>
    string result = "D"
    if score >= 88.0
        result := "A+"
    else if score >= 78.0
        result := "A"
    else if score >= 68.0
        result := "B"
    else if score >= 55.0
        result := "C"
    result

f_score_text(float score) =>
    string result = "-"
    if not na(score)
        result := str.tostring(math.round(score)) + " / " + f_grade(score)
    result

f_risk_text(float risk) =>
    string result = "-"
    if not na(risk)
        string tier = risk >= 72.0 ? "High" : risk >= 48.0 ? "Moderate" : "Low"
        result := tier + " " + str.tostring(math.round(risk))
    result

f_score_color(float score) =>
    color result = panelValueCol
    if not na(score)
        result := score >= minimumScore ? bullColor : score >= 55.0 ? neutralColor : panelLabelCol
    result

f_risk_color(float risk) =>
    color result = panelValueCol
    if not na(risk)
        result := risk >= 72.0 ? bearColor : risk >= 48.0 ? neutralColor : bullColor
    result

f_state_color(string stateText) =>
    switch stateText
        "Use <= 60m" => neutralColor
        "Building" => accentColor
        "Locked" => neutralColor
        "Break Review" => accentColor
        "Accepted" => bullColor
        "Failed Back In" => bearColor
        "Closed" => panelLabelCol
        => panelValueCol

f_delete_label(label id) =>
    if not na(id)
        label.delete(id)
    true

f_trim_labels(array<label> labels, int maxCount, int maxAge, int currentBar) =>
    while array.size(labels) > maxCount
        label oldLabel = array.shift(labels)
        f_delete_label(oldLabel)
    bool checkingAge = true
    while checkingAge and array.size(labels) > 0
        label oldestLabel = array.get(labels, 0)
        bool tooOld = na(oldestLabel)
        if not tooOld
            tooOld := currentBar - label.get_x(oldestLabel) > maxAge
        if tooOld
            label expiredLabel = array.shift(labels)
            f_delete_label(expiredLabel)
        else
            checkingAge := false
    true

f_trim_boxes(array<box> boxes, int maxCount) =>
    while array.size(boxes) > maxCount
        box oldBox = array.shift(boxes)
        box.delete(oldBox)

f_box_text(string stateText) =>
    switch stateText
        "Building" => "IB BUILD"
        "Locked" => "IB READY"
        "Break Review" => "IB REVIEW"
        "Accepted" => "IB ACCEPT"
        "Failed Back In" => "IB FAIL"
        "Closed" => "IB CLOSED"
        => "IB WAIT"

f_event_label(array<label> labels, string labelText, float y, color labelColor, bool belowPrice, string sizeName, int maxCount) =>
    label newLabel = label.new(x = bar_index, y = y, xloc = xloc.bar_index, text = labelText, style = belowPrice ? label.style_label_up : label.style_label_down, color = color.new(labelColor, 0), textcolor = f_text_on(labelColor), size = f_size(sizeName))
    array.push(labels, newLabel)
    f_trim_labels(labels, maxCount, labelHistoryBars, bar_index)

f_rail_badge_gap(float atrInput, string sizeName) =>
    float fontFactor = sizeName == "Tiny" ? 2.40 : sizeName == "Small" ? 2.80 : sizeName == "Large" ? 4.00 : sizeName == "Huge" ? 4.80 : 3.40
    math.max(math.max(atrInput, syminfo.mintick) * fontFactor, syminfo.mintick * 30.0)

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = f_panel_semantic(rightColor, theme), bgcolor = rowBg, text_size = f_size(fontSize), text_halign = text.align_right)

// -------------------------------------------------
// Persistent State
// -------------------------------------------------
var float ibHigh = na
var float ibLow = na
var int ibStartBar = na
var int ibEndBar = na
var int trackingEndBar = na
var bool ibDone = false
var int breakDir = 0
var int breakBar = na
var float breakEdge = na
var float breakCloseQuality = na
var bool retestHeld = false
var bool acceptedPrinted = false
var bool failurePrinted = false
var bool riskPrinted = false
var int lastEventLabelBar = na
var int lastContextLabelBar = na

var box activeIbBox = na
var label activeIbBadge = na
var array<box> ibBoxes = array.new<box>()
var array<label> ibBadges = array.new<label>()
var array<label> eventLabels = array.new<label>()

var line targetOneLine = na
var line targetTwoLine = na
var line invalidationLine = na
var line targetOneConnector = na
var line targetTwoConnector = na
var line invalidationConnector = na
var label targetOneTag = na
var label targetTwoTag = na
var label invalidationTag = na

// Follow-through proof layer
var bool ibProofPending = false
var int ibProofDir = 0
var float ibProofTarget = na
var float ibProofInvalid = na
var int ibProofStartBar = na
var int ibProofTotal = 0
var int ibProofWin = 0
var bool proofArmedThisSession = false

// -------------------------------------------------
// Core Measurements
// -------------------------------------------------
int timeframeSeconds = timeframe.in_seconds(timeframe.period)
bool timeframeAllowed = timeframe.isintraday and timeframeSeconds <= 3600
float atrRaw = ta.atr(atrLength)
float safeAtr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
int visualForwardBars = adaptiveProjection ? timeframe.ismonthly ? math.min(forwardBars, 8) : timeframe.isweekly ? math.min(forwardBars, 12) : timeframe.isdaily ? math.min(forwardBars, 18) : forwardBars : forwardBars
float volumeBase = ta.sma(volume, volumeLength)
float rvol = not na(volume) and not na(volumeBase) and volumeBase > 0.0 ? volume / volumeBase : 1.0
float volumeScore = f_norm_high_good(rvol, 0.70, 1.35)
float atrBase = ta.sma(atrRaw, math.max(atrLength * 3, acceptanceLookback))
float atrRatio = not na(atrBase) and atrBase > 0.0 ? safeAtr / atrBase : 1.0
float volatilityFit = f_peak_score(atrRatio, 0.55, 1.05, 2.10)

bool inIbWindow = timeframeAllowed and not na(time(timeframe.period, ibSession, sessionTimezone))
bool inTrackWindow = timeframeAllowed and not na(time(timeframe.period, trackingSession, sessionTimezone))
bool newIb = inIbWindow and not inIbWindow[1]
bool finishIb = not inIbWindow and inIbWindow[1]
bool finishTrack = not inTrackWindow and inTrackWindow[1]
bool confirmedBar = confirmationMode == "Live Updating" or barstate.isconfirmed

if newIb
    if ibProofPending
        ibProofTotal += 1
        ibProofPending := false
    if not na(activeIbBox)
        int completedBoxRight = not na(trackingEndBar) ? trackingEndBar : math.max(ibStartBar, bar_index - 1)
        box.set_right(activeIbBox, completedBoxRight)
        box.set_bgcolor(activeIbBox, color.new(panelLabelCol, 96))
        box.set_border_color(activeIbBox, color.new(panelLabelCol, 72))
    if not na(activeIbBadge)
        int completedBadgeRight = not na(trackingEndBar) ? trackingEndBar : math.max(ibStartBar, bar_index - 1)
        int completedBadgeX = int(math.round((ibStartBar + completedBadgeRight) / 2.0))
        label.set_x(activeIbBadge, completedBadgeX)
        label.set_y(activeIbBadge, (ibHigh + ibLow) * 0.5)
        label.set_color(activeIbBadge, color.new(panelLabelCol, 35))
    ibHigh := high
    ibLow := low
    ibStartBar := bar_index
    ibEndBar := na
    trackingEndBar := na
    ibDone := false
    breakDir := 0
    breakBar := na
    breakEdge := na
    breakCloseQuality := na
    retestHeld := false
    acceptedPrinted := false
    failurePrinted := false
    riskPrinted := false
    proofArmedThisSession := false
    lastContextLabelBar := na
    if not na(targetOneLine)
        line.delete(targetOneLine)
        targetOneLine := na
    if not na(targetTwoLine)
        line.delete(targetTwoLine)
        targetTwoLine := na
    if not na(invalidationLine)
        line.delete(invalidationLine)
        invalidationLine := na
    if not na(targetOneConnector)
        line.delete(targetOneConnector)
        targetOneConnector := na
    if not na(targetTwoConnector)
        line.delete(targetTwoConnector)
        targetTwoConnector := na
    if not na(invalidationConnector)
        line.delete(invalidationConnector)
        invalidationConnector := na
    if not na(targetOneTag)
        label.delete(targetOneTag)
        targetOneTag := na
    if not na(targetTwoTag)
        label.delete(targetTwoTag)
        targetTwoTag := na
    if not na(invalidationTag)
        label.delete(invalidationTag)
        invalidationTag := na
    if showIbBox
        activeIbBox := box.new(left = ibStartBar, top = ibHigh, right = bar_index + visualForwardBars, bottom = ibLow, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 90), border_color = color.new(accentColor, 32), border_width = 1)
        array.push(ibBoxes, activeIbBox)
        f_trim_boxes(ibBoxes, maxVisibleBoxes)
        int badgeX = ibStartBar + int(math.floor(visualForwardBars * 0.50))
        activeIbBadge := label.new(x = badgeX, y = (ibHigh + ibLow) * 0.5, xloc = xloc.bar_index, text = "IB BUILD", style = label.style_label_center, color = color.new(accentColor, 10), textcolor = f_text_on(accentColor), size = f_size(labelFontSize))
        array.push(ibBadges, activeIbBadge)
        f_trim_labels(ibBadges, maxVisibleBoxes, 100000, bar_index)

if inIbWindow
    ibHigh := math.max(nz(ibHigh, high), high)
    ibLow := math.min(nz(ibLow, low), low)

if finishIb and not na(ibHigh) and not na(ibLow)
    ibDone := true
    ibEndBar := bar_index - 1

if finishTrack and ibDone
    trackingEndBar := bar_index - 1

float ibRange = not na(ibHigh) and not na(ibLow) ? math.max(ibHigh - ibLow, syminfo.mintick) : na
float ibMid = not na(ibRange) ? (ibHigh + ibLow) * 0.5 : na
float ibWidthAtr = not na(ibRange) ? ibRange / safeAtr : na

float idealWidth = sensitivity == "Conservative" ? 1.10 : sensitivity == "Aggressive" ? 1.65 : 1.35
float highWidth = sensitivity == "Conservative" ? 2.35 : sensitivity == "Aggressive" ? 3.45 : 2.85
float widthScore = f_peak_score(ibWidthAtr, 0.35, idealWidth, highWidth)

float breakBuffer = safeAtr * breakBufferAtr
float retestBuffer = safeAtr * retestBufferAtr
float failureBuffer = safeAtr * failureBufferAtr
float barSpan = math.max(high - low, syminfo.mintick)
float closeLocation = f_clamp((close - low) / barSpan, 0.0, 1.0)

bool longBreakEvent = confirmedBar and ibDone and inTrackWindow and breakDir == 0 and close > ibHigh + breakBuffer
bool shortBreakEvent = confirmedBar and ibDone and inTrackWindow and breakDir == 0 and close < ibLow - breakBuffer

if longBreakEvent
    breakDir := 1
    breakBar := bar_index
    breakEdge := ibHigh
    float distanceScore = f_norm_high_good(close - ibHigh, breakBuffer, safeAtr * 0.72)
    float closeScore = closeLocation * 100.0
    breakCloseQuality := f_clamp(distanceScore * 0.54 + closeScore * 0.46, 0.0, 100.0)

if shortBreakEvent
    breakDir := -1
    breakBar := bar_index
    breakEdge := ibLow
    float distanceScore = f_norm_high_good(ibLow - close, breakBuffer, safeAtr * 0.72)
    float closeScore = (1.0 - closeLocation) * 100.0
    breakCloseQuality := f_clamp(distanceScore * 0.54 + closeScore * 0.46, 0.0, 100.0)

int barsSinceBreak = breakDir != 0 and not na(breakBar) ? bar_index - breakBar : na
bool afterBreak = breakDir != 0 and not na(barsSinceBreak)
bool outsideAccepted = afterBreak and (breakDir == 1 ? close > breakEdge : close < breakEdge)
bool backInside = afterBreak and (breakDir == 1 ? close < breakEdge - failureBuffer : close > breakEdge + failureBuffer)
bool deepFailure = afterBreak and (breakDir == 1 ? close < ibMid : close > ibMid)
bool retestTouch = afterBreak and barsSinceBreak > 0 and (breakDir == 1 ? low <= breakEdge + retestBuffer and close >= breakEdge - failureBuffer : high >= breakEdge - retestBuffer and close <= breakEdge + failureBuffer)
bool retestHoldEvent = confirmedBar and retestTouch and not retestHeld and not backInside

if retestHoldEvent
    retestHeld := true

float retestScore = na
if afterBreak
    retestScore := retestHeld ? 100.0 : backInside ? 18.0 : outsideAccepted ? 72.0 : 46.0

float currentCloseSideScore = na
if afterBreak
    currentCloseSideScore := breakDir == 1 ? closeLocation * 100.0 : (1.0 - closeLocation) * 100.0

float acceptanceScore = na
if afterBreak
    acceptanceScore := f_clamp(widthScore * 0.18 + breakCloseQuality * 0.30 + retestScore * 0.20 + volumeScore * 0.17 + volatilityFit * 0.15, 0.0, 100.0)

float failureRisk = na
if afterBreak
    float insidePenalty = backInside ? 34.0 : 0.0
    float deepPenalty = deepFailure ? 26.0 : 0.0
    float timePenalty = barsSinceBreak > acceptanceLookback ? 12.0 : 0.0
    float closeWeakness = 100.0 - nz(currentCloseSideScore, 50.0)
    float participationWeakness = 100.0 - volumeScore
    float widthWeakness = 100.0 - widthScore
    failureRisk := f_clamp(insidePenalty + deepPenalty + timePenalty + closeWeakness * 0.22 + participationWeakness * 0.18 + widthWeakness * 0.12, 0.0, 100.0)

bool acceptedActive = afterBreak and not failurePrinted and outsideAccepted and not na(acceptanceScore) and acceptanceScore >= minimumScore and nz(failureRisk, 100.0) <= 52.0 and barsSinceBreak >= confirmationBars
bool acceptedEvent = confirmedBar and acceptedActive and not acceptedPrinted
bool failureEvent = confirmedBar and afterBreak and not failurePrinted and (deepFailure or (backInside and nz(failureRisk, 0.0) >= 58.0))
bool riskReviewEvent = confirmedBar and afterBreak and not failurePrinted and not acceptedPrinted and not acceptedActive and not riskPrinted and nz(failureRisk, 0.0) >= 64.0

if acceptedEvent
    acceptedPrinted := true

if failureEvent
    failurePrinted := true

if riskReviewEvent
    riskPrinted := true

// -------------------------------------------------
// Labels
// -------------------------------------------------
bool canPrintEventLabel = showEventLabels and (na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars)

if finishIb and showEventLabels and showReadyLabels
    f_event_label(eventLabels, "IB READY", ibHigh + safeAtr * labelOffsetAtr, accentColor, false, labelFontSize, maxVisibleLabels)
    lastEventLabelBar := bar_index

if (longBreakEvent or shortBreakEvent) and showEventLabels
    color breakColor = longBreakEvent ? bullColor : bearColor
    string breakText = longBreakEvent ? "IB BREAK UP" : "IB BREAK DN"
    float labelY = longBreakEvent ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
    f_event_label(eventLabels, breakText, labelY, breakColor, not longBreakEvent, labelFontSize, maxVisibleLabels)
    lastEventLabelBar := bar_index

if retestHoldEvent and canPrintEventLabel
    color retestColor = breakDir == 1 ? bullColor : bearColor
    float labelY = breakDir == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    f_event_label(eventLabels, "RETEST HOLD", labelY, retestColor, breakDir == 1, labelFontSize, maxVisibleLabels)
    lastEventLabelBar := bar_index

if acceptedEvent and canPrintEventLabel
    color acceptedColor = breakDir == 1 ? bullColor : bearColor
    string acceptedText = "ACCEPT " + str.tostring(math.round(acceptanceScore))
    float labelY = breakDir == 1 ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
    f_event_label(eventLabels, acceptedText, labelY, acceptedColor, breakDir == -1, labelFontSize, maxVisibleLabels)
    lastEventLabelBar := bar_index

if riskReviewEvent and canPrintEventLabel
    float labelY = breakDir == 1 ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
    f_event_label(eventLabels, "RISK REVIEW", labelY, neutralColor, breakDir == -1, labelFontSize, maxVisibleLabels)
    lastEventLabelBar := bar_index

if failureEvent and canPrintEventLabel
    float labelY = breakDir == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    f_event_label(eventLabels, "IB FAIL", labelY, dangerColor, breakDir == 1, labelFontSize, maxVisibleLabels)
    lastEventLabelBar := bar_index

bool contextDue = showEventLabels and showContextLabels and afterBreak and inTrackWindow and not failurePrinted and not acceptedPrinted and not acceptedActive and barsSinceBreak > 0 and (na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars)
if contextDue
    string contextText = "IB WATCH " + str.tostring(math.round(acceptanceScore))
    float labelY = breakDir == 1 ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
    f_event_label(eventLabels, contextText, labelY, accentColor, breakDir == -1, labelFontSize, maxVisibleLabels)
    lastContextLabelBar := bar_index

f_trim_labels(eventLabels, maxVisibleLabels, labelHistoryBars, bar_index)

// -------------------------------------------------
// Visual Objects
// -------------------------------------------------
string ibStateText = timeframeAllowed ? "Waiting" : "Use <= 60m"
if inIbWindow
    ibStateText := "Building"
else if ibDone and not inTrackWindow
    ibStateText := "Closed"
else if ibDone and failurePrinted
    ibStateText := "Failed Back In"
else if ibDone and acceptedPrinted
    ibStateText := "Accepted"
else if ibDone and afterBreak
    ibStateText := "Break Review"
else if ibDone and inTrackWindow
    ibStateText := "Locked"

string breakSideText = breakDir == 1 ? "Bull Break" : breakDir == -1 ? "Bear Break" : "No Break"
string actionText = timeframeAllowed ? "Wait For IB" : "Switch TF"
if inIbWindow
    actionText := "Build IB"
else if ibDone and not inTrackWindow
    actionText := "Session Closed"
else if ibDone and breakDir == 0
    actionText := "Wait Break"
else if failurePrinted
    actionText := "Stand Aside"
else if acceptedPrinted and breakDir == 1
    actionText := "Review Long"
else if acceptedPrinted and breakDir == -1
    actionText := "Review Short"
else if riskPrinted or nz(failureRisk, 0.0) >= 64.0
    actionText := "Failure Watch"
else if afterBreak and retestHeld
    actionText := "Retest Review"
else if afterBreak
    actionText := "Observe Retest"

color activeColor = f_state_color(ibStateText)
int rightEdge = bar_index + visualForwardBars
int boxRightEdge = not na(trackingEndBar) ? trackingEndBar : rightEdge
if showIbBox and not na(activeIbBox) and not na(ibRange)
    box.set_left(activeIbBox, ibStartBar)
    box.set_right(activeIbBox, boxRightEdge)
    box.set_top(activeIbBox, ibHigh)
    box.set_bottom(activeIbBox, ibLow)
    box.set_bgcolor(activeIbBox, color.new(activeColor, ibStateText == "Building" ? 90 : 92))
    box.set_border_color(activeIbBox, color.new(activeColor, 28))
    if not na(activeIbBadge)
        int badgeX = int(math.round((ibStartBar + boxRightEdge) / 2.0))
        string activeBoxText = f_box_text(ibStateText) + (afterBreak and not na(acceptanceScore) ? " | " + str.tostring(math.round(acceptanceScore)) : "")
        label.set_x(activeIbBadge, badgeX)
        label.set_y(activeIbBadge, (ibHigh + ibLow) * 0.5)
        label.set_text(activeIbBadge, activeBoxText)
        label.set_color(activeIbBadge, color.new(activeColor, 10))
        label.set_textcolor(activeIbBadge, f_text_on(activeColor))
        label.set_size(activeIbBadge, f_size(labelFontSize))

float targetOne = na
float targetTwo = na
float invalidation = na
if afterBreak and not na(ibRange)
    targetOne := breakDir == 1 ? breakEdge + ibRange * targetOneMultiple : breakEdge - ibRange * targetOneMultiple
    targetTwo := breakDir == 1 ? breakEdge + ibRange * targetTwoMultiple : breakEdge - ibRange * targetTwoMultiple
    invalidation := breakDir == 1 ? breakEdge - failureBuffer : breakEdge + failureBuffer

int railTagX = rightEdge + railTagOffsetBars
float railBadgeGap = f_rail_badge_gap(safeAtr, labelFontSize)
float targetOneTagY = targetOne
float targetTwoTagY = not useSmartRailLanes or not afterBreak ? targetTwo : breakDir == 1 ? math.max(targetTwo, targetOneTagY + railBadgeGap) : math.min(targetTwo, targetOneTagY - railBadgeGap)
float invalidationTagY = not useSmartRailLanes or not afterBreak ? invalidation : breakDir == 1 ? math.min(invalidation, breakEdge - railBadgeGap) : math.max(invalidation, breakEdge + railBadgeGap)

// -------------------------------------------------
// Follow-Through Proof
// A win is recorded when Target Rail 1 is reached before the break invalidates.
// -------------------------------------------------
if acceptedPrinted and inTrackWindow and not failurePrinted and not proofArmedThisSession and not ibProofPending and barstate.isconfirmed and not na(targetOne) and not na(invalidation)
    ibProofPending := true
    proofArmedThisSession := true
    ibProofDir := breakDir
    ibProofTarget := targetOne
    ibProofInvalid := invalidation
    ibProofStartBar := bar_index

if ibProofPending and finishTrack and barstate.isconfirmed
    ibProofTotal += 1
    ibProofPending := false

if ibProofPending and barstate.isconfirmed and bar_index > ibProofStartBar
    bool favHit = ibProofDir == 1 ? high >= ibProofTarget : low <= ibProofTarget
    bool invHit = ibProofDir == 1 ? low <= ibProofInvalid : high >= ibProofInvalid
    bool expired = bar_index - ibProofStartBar >= proofWindowBars
    if favHit and invHit
        ibProofTotal += 1
        ibProofPending := false
    else if favHit
        ibProofTotal += 1
        ibProofWin += 1
        ibProofPending := false
    else if invHit
        ibProofTotal += 1
        ibProofPending := false
    else if expired
        ibProofTotal += 1
        ibProofPending := false

if showTargetRails and afterBreak and inTrackWindow and not failurePrinted and not na(targetOne)
    color railColor = breakDir == 1 ? bullColor : bearColor
    if na(targetOneLine)
        targetOneLine := line.new(x1 = breakBar, y1 = targetOne, x2 = rightEdge, y2 = targetOne, xloc = xloc.bar_index, color = color.new(railColor, 18), width = 1, style = line.style_dashed)
    else
        line.set_xy1(targetOneLine, breakBar, targetOne)
        line.set_xy2(targetOneLine, rightEdge, targetOne)
        line.set_color(targetOneLine, color.new(railColor, 18))
    if na(targetTwoLine)
        targetTwoLine := line.new(x1 = breakBar, y1 = targetTwo, x2 = rightEdge, y2 = targetTwo, xloc = xloc.bar_index, color = color.new(railColor, 32), width = 1, style = line.style_dotted)
    else
        line.set_xy1(targetTwoLine, breakBar, targetTwo)
        line.set_xy2(targetTwoLine, rightEdge, targetTwo)
        line.set_color(targetTwoLine, color.new(railColor, 32))
    if na(invalidationLine)
        invalidationLine := line.new(x1 = breakBar, y1 = invalidation, x2 = rightEdge, y2 = invalidation, xloc = xloc.bar_index, color = color.new(dangerColor, 12), width = 1, style = line.style_solid)
    else
        line.set_xy1(invalidationLine, breakBar, invalidation)
        line.set_xy2(invalidationLine, rightEdge, invalidation)
        line.set_color(invalidationLine, color.new(dangerColor, 12))
    if na(targetOneConnector)
        targetOneConnector := line.new(x1 = rightEdge, y1 = targetOne, x2 = railTagX, y2 = targetOneTagY, xloc = xloc.bar_index, color = color.new(railColor, 18), width = 1, style = line.style_dashed)
    else
        line.set_xy1(targetOneConnector, rightEdge, targetOne)
        line.set_xy2(targetOneConnector, railTagX, targetOneTagY)
        line.set_color(targetOneConnector, color.new(railColor, 18))
    if na(targetTwoConnector)
        targetTwoConnector := line.new(x1 = rightEdge, y1 = targetTwo, x2 = railTagX, y2 = targetTwoTagY, xloc = xloc.bar_index, color = color.new(railColor, 32), width = 1, style = line.style_dotted)
    else
        line.set_xy1(targetTwoConnector, rightEdge, targetTwo)
        line.set_xy2(targetTwoConnector, railTagX, targetTwoTagY)
        line.set_color(targetTwoConnector, color.new(railColor, 32))
    if na(invalidationConnector)
        invalidationConnector := line.new(x1 = rightEdge, y1 = invalidation, x2 = railTagX, y2 = invalidationTagY, xloc = xloc.bar_index, color = color.new(dangerColor, 12), width = 1, style = line.style_solid)
    else
        line.set_xy1(invalidationConnector, rightEdge, invalidation)
        line.set_xy2(invalidationConnector, railTagX, invalidationTagY)
        line.set_color(invalidationConnector, color.new(dangerColor, 12))
    if na(targetOneTag)
        targetOneTag := label.new(x = railTagX, y = targetOneTagY, xloc = xloc.bar_index, text = "T1 " + str.tostring(targetOne, format.mintick), style = label.style_label_left, color = color.new(railColor, 8), textcolor = f_text_on(railColor), size = f_size(labelFontSize))
    else
        label.set_x(targetOneTag, railTagX)
        label.set_y(targetOneTag, targetOneTagY)
        label.set_text(targetOneTag, "T1 " + str.tostring(targetOne, format.mintick))
        label.set_color(targetOneTag, color.new(railColor, 8))
        label.set_textcolor(targetOneTag, f_text_on(railColor))
        label.set_size(targetOneTag, f_size(labelFontSize))
    if na(targetTwoTag)
        targetTwoTag := label.new(x = railTagX, y = targetTwoTagY, xloc = xloc.bar_index, text = "T2 " + str.tostring(targetTwo, format.mintick), style = label.style_label_left, color = color.new(railColor, 18), textcolor = f_text_on(railColor), size = f_size(labelFontSize))
    else
        label.set_x(targetTwoTag, railTagX)
        label.set_y(targetTwoTag, targetTwoTagY)
        label.set_text(targetTwoTag, "T2 " + str.tostring(targetTwo, format.mintick))
        label.set_color(targetTwoTag, color.new(railColor, 18))
        label.set_textcolor(targetTwoTag, f_text_on(railColor))
        label.set_size(targetTwoTag, f_size(labelFontSize))
    if na(invalidationTag)
        invalidationTag := label.new(x = railTagX, y = invalidationTagY, xloc = xloc.bar_index, text = "Invalid " + str.tostring(invalidation, format.mintick), style = label.style_label_left, color = color.new(dangerColor, 8), textcolor = f_text_on(dangerColor), size = f_size(labelFontSize))
    else
        label.set_x(invalidationTag, railTagX)
        label.set_y(invalidationTag, invalidationTagY)
        label.set_text(invalidationTag, "Invalid " + str.tostring(invalidation, format.mintick))
        label.set_color(invalidationTag, color.new(dangerColor, 8))
        label.set_textcolor(invalidationTag, f_text_on(dangerColor))
        label.set_size(invalidationTag, f_size(labelFontSize))
else
    if not na(targetOneLine)
        line.delete(targetOneLine)
        targetOneLine := na
    if not na(targetTwoLine)
        line.delete(targetTwoLine)
        targetTwoLine := na
    if not na(invalidationLine)
        line.delete(invalidationLine)
        invalidationLine := na
    if not na(targetOneConnector)
        line.delete(targetOneConnector)
        targetOneConnector := na
    if not na(targetTwoConnector)
        line.delete(targetTwoConnector)
        targetTwoConnector := na
    if not na(invalidationConnector)
        line.delete(invalidationConnector)
        invalidationConnector := na
    if not na(targetOneTag)
        label.delete(targetOneTag)
        targetOneTag := na
    if not na(targetTwoTag)
        label.delete(targetTwoTag)
        targetTwoTag := na
    if not na(invalidationTag)
        label.delete(invalidationTag)
        invalidationTag := na

// -------------------------------------------------
// Panel
// -------------------------------------------------
color dashBg = f_panel_bg(panelTheme)
color dashBorder = f_panel_border(panelTheme)
float ftRate = ibProofTotal > 0 ? 100.0 * ibProofWin / ibProofTotal : na
string ftText = ibProofTotal >= minimumProofSamples ? str.tostring(math.round(ftRate)) + "% | " + str.tostring(ibProofWin) + "/" + str.tostring(ibProofTotal) : "Building " + str.tostring(ibProofTotal) + "/" + str.tostring(minimumProofSamples)
color ftColor = ibProofTotal < minimumProofSamples ? f_panel_value(panelTheme) : ftRate >= 55.0 ? bullColor : ftRate >= 40.0 ? neutralColor : bearColor
plot(ibProofTotal >= minimumProofSamples ? ftRate : na, title = "Historical Follow-Through Rate", color = bullColor, display = display.data_window)

var table infoPanel = na
var string panelLocationCache = ""
var string panelThemeCache = ""

if not showPanel and not na(infoPanel)
    table.delete(infoPanel)
    infoPanel := na
    panelLocationCache := ""
    panelThemeCache := ""

if showPanel and (na(infoPanel) or panelLocationCache != panelLocation or panelThemeCache != panelTheme)
    if not na(infoPanel)
        table.delete(infoPanel)
    infoPanel := table.new(f_panel_position(panelLocation), 2, 7, bgcolor = dashBg, frame_color = dashBorder, frame_width = 1, border_color = dashBorder, border_width = 1)
    table.cell(infoPanel, 0, 0, "AG Pro Initial Balance Break Planner", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSize), text_halign = text.align_center)
    table.cell(infoPanel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSize))
    table.merge_cells(infoPanel, 0, 0, 1, 0)
    panelLocationCache := panelLocation
    panelThemeCache := panelTheme

if showPanel and barstate.islast and not na(infoPanel)
    table.clear(infoPanel, 0, 1, 1, 6)
    table.cell(infoPanel, 0, 0, "AG Pro Initial Balance Break Planner", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSize), text_halign = text.align_center)
    f_panel_row(infoPanel, 1, "IB State", ibStateText, f_state_color(ibStateText), panelTheme, panelFontSize)
    f_panel_row(infoPanel, 2, "Break Side", breakSideText, breakDir == 1 ? bullColor : breakDir == -1 ? bearColor : f_panel_value(panelTheme), panelTheme, panelFontSize)
    f_panel_row(infoPanel, 3, "Acceptance Score", f_score_text(acceptanceScore), f_score_color(acceptanceScore), panelTheme, panelFontSize)
    f_panel_row(infoPanel, 4, "Failure Risk", f_risk_text(failureRisk), f_risk_color(failureRisk), panelTheme, panelFontSize)
    f_panel_row(infoPanel, 5, "Action", actionText, actionText == "Review Long" ? bullColor : actionText == "Review Short" ? bearColor : actionText == "Failure Watch" or actionText == "Stand Aside" ? neutralColor : f_panel_value(panelTheme), panelTheme, panelFontSize)
    f_panel_row(infoPanel, 6, "Historical FT", ftText, ftColor, panelTheme, panelFontSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(longBreakEvent, "IB Bull Break Review", "Initial Balance bullish break review detected. This is an attention marker, not a trade instruction.")
alertcondition(shortBreakEvent, "IB Bear Break Review", "Initial Balance bearish break review detected. This is an attention marker, not a trade instruction.")
alertcondition(acceptedEvent and breakDir == 1, "IB Bull Acceptance", "Initial Balance bullish break acceptance met the planner threshold. Review risk and context independently.")
alertcondition(acceptedEvent and breakDir == -1, "IB Bear Acceptance", "Initial Balance bearish break acceptance met the planner threshold. Review risk and context independently.")
alertcondition(riskReviewEvent, "IB Failure Risk Review", "Initial Balance break failure risk moved into review territory. This is an attention marker, not a trade instruction.")
alertcondition(failureEvent, "IB Failed Back Inside", "Initial Balance break failed back inside the balance area. This is an attention marker, not a trade instruction.")
````
