# Stop Run Continuation Planner [AGPro Series]

- url: https://www.tradingview.com/script/ElQso2WK-Stop-Run-Continuation-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;f3f90ed79fed42058e825f82277941c4
- version: 4.0

## Description

Stop Run Continuation Planner [AGPro Series]


🧠 Core Idea

Did the stop run fuel continuation instead of reversal?


📌 Overview / What it does

Stop Run Continuation Planner [AGPro Series] is a chart-first liquidity continuation tool built around a specific post-sweep question: after price runs stops beyond a recent high or low, is the market reclaiming back inside for reversal, or accepting beyond the swept edge for continuation?

The script maps stop-run zones, continuation references, invalidation edges, target corridors, compact state labels, alerts, a 0-100 Continuation Score, and a Reversal Risk reading. It is designed to organize observable stop-run behavior into a structured planning workflow.

It does not predict future price, automate execution, or issue buy and sell commands. It is an analytical and visualization tool built for structured review.


🎯 Purpose & Design Philosophy

This script was built for the cases where a stop run does not turn into a reversal. Many liquidity tools focus on the sweep itself. This script focuses on what happens after the sweep.

The design supports a planner mindset: identify the stop run, measure continuation acceptance, locate invalidation, estimate target room, judge reversal risk, and decide what deserves attention next.


⚡ Why This Script Is Different

Most stop-run tools focus on reversal reclaim behavior, generic liquidity grabs, or broad SMC-style mapping.

This script does NOT treat every sweep as a reversal event.

Instead, it evaluates whether price is accepting beyond the swept edge with enough quality, target room, and controlled reversal risk to justify a continuation review.


⚙ Methodology

1. Context Detection
Recent high and low references are defined with a configurable lookback.

2. Reference Mapping
When price sweeps beyond a reference, the script maps the swept edge, continuation side, invalidation edge, and forward target corridor.

3. Reaction Evaluation
Continuation Score blends sweep depth, close acceptance, volume participation, trend-side support, and target room. Reversal Risk tracks rejection, weak acceptance, and context conflict.

4. Visual Output
Qualified states produce stop-run boxes, target corridors, compact labels, alerts, and a clean AG Pro panel.


🗺 How to Read the Chart

Zones = the active stop-run area between the swept reference and the sweep extreme.

Corridors = the forward review area used for target room assessment.

Labels = watch or continuation state markers.

Colors = teal for bullish continuation context, pink for bearish continuation context, and red for invalidation pressure.

Panel = Stop Run, Continuation Score, Reversal Risk, Target Room, and Action.


🚦 Signals & States

• Upper Run Watch → price swept a recent high, but continuation acceptance still needs confirmation.

• Lower Run Watch → price swept a recent low, but continuation acceptance still needs confirmation.

• Bull Continuation Ready → bullish post-sweep continuation quality is strong enough for review.

• Bear Continuation Ready → bearish post-sweep continuation quality is strong enough for review.

• Invalidation Review → price has moved through the active invalidation edge.

• Target Review → price is testing the active target corridor.

• Reversal Risk Elevated → rejection risk is growing and continuation quality is weakening.


🔔 Alerts Logic

Alerts trigger when bullish or bearish continuation reaches ready state, when a watch condition appears, when invalidation review is triggered, when price tests the target corridor, or when reversal risk becomes elevated.

Important: alerts are attention markers, not trade instructions.


🧩 Confluence Logic

When sweep depth, close acceptance, volume participation, trend support, and clean target room align, the continuation context becomes stronger.

When price closes back inside the swept edge or rejection grows, Reversal Risk rises and the continuation plan weakens.


📊 When to Use

• After price runs above recent highs or below recent lows

• During breakout continuation attempts after a liquidity sweep

• In trending or expanding markets

• When traders need risk, target, and next-action context after a fast sweep event


⚠️ When NOT to Use

• Extremely low-liquidity markets

• Very noisy micro-timeframes

• News-driven candles with abnormal spread or slippage

• Markets where volume data is unreliable

• Situations where the user expects automated entries or guaranteed outcomes


🎛️ Key Inputs

• Continuation Side → evaluates bullish events, bearish events, or both

• Sensitivity → changes how strict the continuation requirements are

• Stop-Run Reference Lookback → defines the sweep reference levels

• Confirmation Mode → changes how much confirmation is required

• Minimum Continuation Score → sets the ready threshold

• Watch Score → controls earlier watch-state visibility

• Invalidation Edge Buffer → adjusts the wrong-side planning edge

• Target Corridor R Multiple → controls target-corridor projection

• Visual settings → control zones, labels, font size, panel location, and render limits


🖥️ Interface & Visual Design

The script is chart-first and decision-focused. The chart carries the zones, corridors, and labels. The panel provides a compact state summary without turning the script into a crowded dashboard.

The first panel row follows the AGPro standard: one merged blue header row containing only the script name.


🧪 Practical Usage Workflow

1. Read the panel state and Continuation Score.

2. Check whether price swept above a recent high or below a recent low.

3. Review whether price is accepting beyond the swept edge.

4. Compare Reversal Risk with the invalidation edge.

5. Review target room before treating continuation as stronger context.


🔍 Interpretation Guidelines

A high Continuation Score means the stop run is showing stronger continuation behavior under the script rules. It does not mean continuation must happen.

The invalidation edge and target corridor are planning references, not guaranteed levels.

The best use is to compare the planner state with broader market structure, liquidity, volatility, and personal risk process.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not auto trading

• Not guaranteed signals

• Not a generic support/resistance map

• Not an order-block or FVG scanner

• Not a stop-run reversal tool


⚠️ Limitations & Transparency

Stop-run behavior changes across symbols, sessions, and timeframes.

High volatility can widen risk and target references.

Low liquidity can distort sweep quality, volume response, and label timing.

No rule-based script can fully account for news, spread changes, slippage, or sudden liquidity shifts.


🧠 Market Context Notes

Stop runs often happen near visible highs, lows, session extremes, or recent structure.

A sweep becomes more useful for continuation planning when the market accepts beyond the swept edge instead of reclaiming back inside.


🧾 Use Case Examples

When price sweeps above a recent high, closes beyond the swept edge, and the Continuation Score improves, the planner may show bullish continuation readiness.

When price sweeps below a recent low and continues accepting below that edge, the planner may show bearish continuation readiness.

When price sweeps but closes back inside with stronger rejection, Reversal Risk can rise and the panel may shift to caution.


🧱 System Philosophy

AGProLabs tools are built around structured interpretation. The goal is not to add another raw signal. The goal is to turn market behavior into a cleaner review process with score, state, risk, target, and next action.


🔐 Non-Promise Statement

No indicator can remove uncertainty.

No score can guarantee continuation.

No zone, label, panel row, alert, or corridor should be interpreted as a guaranteed outcome.


📉 Risk Disclosure

Trading involves risk.

This script is provided for educational and analytical use only.

It does not provide financial advice or guaranteed trading outcomes.

Users remain responsible for their own analysis, risk management, and execution.

## Source Code

````pine
// -------------------------------------------------
// Stop Run Continuation Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.15
//
// Stop Run Continuation Planner is a chart-first liquidity continuation
// planning tool. It studies stop-run sweeps that do not reclaim back inside
// the prior range, then scores whether the sweep is fueling continuation with
// measurable close acceptance, trend support, target room, reversal risk, an
// episode-based target-reach rate, and a collision-safe owned-plan layout
// with direction-aware invalidation clearance.
// -------------------------------------------------

//@version=6
indicator("Stop Run Continuation Planner [AGPro Series]",
     shorttitle = "AG Pro SRC",
     overlay = true,
     max_boxes_count = 60,
     max_labels_count = 140,
     max_lines_count = 80)

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
const int MAX_STORED_READY_EVENTS = 64
const int MAX_STORED_WATCH_EVENTS = 96
const int MAX_STORED_REVIEW_EVENTS = 64

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
const string TT_SIDE = "Selects which continuation side the planner can evaluate. Auto allows both upper and lower stop-run continuation events."
const string TT_LOOKBACK = "Lookback used to define the recent high and low stop-run references. The current bar is excluded so sweeps are measured against prior structure."
const string TT_ATR = "ATR length used to normalize sweep depth, trigger buffers, invalidation edges, target corridors, and label spacing."
const string TT_VOL = "Volume baseline used to judge participation behind the continuation close. On symbols with limited volume data this component should be interpreted as context."
const string TT_SENS = "Controls how selective the sweep and close-continuation requirements are. Aggressive reacts earlier, while Conservative requires cleaner acceptance beyond the swept edge."
const string TT_CONFIRM = "Defines how much evidence is required after the stop run. Strict mode requires cleaner close location, volume support, and trend alignment."
const string TT_CLOSE = "When enabled, new state labels and alerts wait for bar close. This keeps public chart behavior stable."
const string TT_WINDOW = "Number of bars after a stop-run continuation event where the active risk, target, and invalidation context remains visible in the panel."
const string TT_MIN_SCORE = "Minimum 0-100 Continuation Score required before a READY state and full visual plan can print."
const string TT_WATCH_SCORE = "Minimum 0-100 score required before a lighter stop-run continuation watch label can appear."
const string TT_SWEEP = "Additional ATR-based depth required beyond the stop-run reference before the event qualifies as a meaningful sweep."
const string TT_TRIGGER = "ATR buffer beyond the swept edge used as the continuation trigger reference."
const string TT_RISK = "ATR buffer placed back inside the swept edge to define the invalidation edge. It is a planning reference, not an instruction."
const string TT_TARGET = "Fallback target-room distance in ATR when the risk multiple projection is too close to be useful."
const string TT_RMULT = "Risk multiple used to project the target corridor from the trigger and invalidation edge."
const string TT_CLEAN_ROOM = "ATR distance considered clean target room before the next major review area."
const string TT_PROOF_WINDOW = "Bars observed after a READY continuation. A target touch counts only when the invalidation edge was not touched first; same-bar ambiguity is resolved conservatively in favor of invalidation, and expiry counts as a non-reach."
const string TT_PROOF_SAMPLES = "Completed READY episodes required before the target-reach rate is reported instead of a building state."
const string TT_ZONES = "Shows the stop-run zone between the swept reference and the sweep extreme. Zone labels are rendered as separate centered badges."
const string TT_LINES = "Shows the latest active plan's trigger, invalidation, and target rails with filled price badges. Smart ATR- and font-aware lanes separate close badges, add extra outward clearance for Invalid, and preserve exact price references with owned connectors."
const string TT_CORRIDOR = "Shows the target corridor used by the planner to frame forward continuation review."
const string TT_LABELS = "Shows compact continuation, failed-reversal, watch, invalidation, and target review labels with controlled spacing."
const string TT_REVIEW_LABELS = "Shows invalidation and target-review labels on the chart. Disabled by default to keep publication screenshots cleaner while panel states and alerts remain active."
const string TT_CONTEXT = "Adds sparse watch labels without repeating them on every bar. WATCH labels treat nearby zone and corridor badges as obstacles and move to a clear volatility-aware lane."
const string TT_SCORE_LABEL = "Adds the 0-100 Continuation Score to chart labels."
const string TT_COOLDOWN = "Minimum bars between retained historical READY visual sets. A newer nearby READY plan replaces the prior visual slot so the active plan stays visible without stacked zones. Detection, alerts, and target-reach evidence are never suppressed."
const string TT_CONTEXT_SPACING = "Minimum bars between lighter watch labels during active stop-run continuation monitoring."
const string TT_MAX_OBJECTS = "Maximum visible event sets retained on the chart. Older zones, corridors, lines, and labels are removed first."
const string TT_RENDER = "Limits visual object creation to the most recent bars. Scores, panel states, and alerts still calculate normally, but older boxes and labels are not drawn. Lower values improve TradingView load speed."
const string TT_FORWARD = "Number of bars projected to the right. Wider defaults reserve separate horizontal ownership lanes for the centered RUN and ROOM badges."
const string TT_ADAPTIVE = "Shortens forward rendering on daily, weekly, and monthly charts so wider screenshots stay balanced."
const string TT_BADGE = "Controls the horizontal placement of centered RUN and ROOM identity badges inside their visual areas."
const string TT_ZONE_OPACITY = "Transparency of stop-run zones and target corridors. Higher values make the visual areas lighter."
const string TT_OFFSET = "ATR-based label offset that keeps labels above or below candles instead of buried inside the bars."
const string TT_LABEL_SIZE = "Controls all chart labels and centered zone badges. Normal is the default AGPro publication setting."
const string TT_PANEL_SHOW = "Shows or hides the AG Pro decision panel. The default is visible for publication-ready context."
const string TT_PANEL_LOCATION = "Moves the AG Pro panel to the preferred chart location."
const string TT_PANEL_THEME = "Switches the panel between premium AGPro surfaces and a clean light theme while preserving the blue merged header row."
const string TT_PANEL_SIZE = "Controls panel text size. Normal is the default AGPro publication setting."
const string TT_ALERT = "Minimum Continuation Score required for READY alerts. Alerts are attention markers, not trade instructions."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Stop-Run Continuation Engine"
string sideMode = input.string("Auto", "Continuation Side", options = ["Auto", "Bullish Only", "Bearish Only"], group = groupEngine, tooltip = TT_SIDE)
int referenceLookback = input.int(34, "Stop-Run Reference Lookback", minval = 10, maxval = 240, group = groupEngine, tooltip = TT_LOOKBACK)
int atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupEngine, tooltip = TT_ATR)
int volumeLength = input.int(34, "Volume Baseline Length", minval = 5, maxval = 200, group = groupEngine, tooltip = TT_VOL)
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Aggressive", "Balanced", "Conservative"], group = groupEngine, tooltip = TT_SENS)
string confirmationMode = input.string("Close Continuation", "Confirmation Mode", options = ["Close Continuation", "Close + Volume", "Strict"], group = groupEngine, tooltip = TT_CONFIRM)
bool confirmOnClose = input.bool(true, "Confirm On Bar Close", group = groupEngine, tooltip = TT_CLOSE)
int activeReviewBars = input.int(20, "Active Review Bars", minval = 6, maxval = 180, group = groupEngine, tooltip = TT_WINDOW)

string groupScore = "Continuation Score"
int minContinuationScore = input.int(70, "Minimum Continuation Score", minval = 40, maxval = 95, group = groupScore, tooltip = TT_MIN_SCORE)
int watchScore = input.int(58, "Watch Score", minval = 20, maxval = 90, group = groupScore, tooltip = TT_WATCH_SCORE)

string groupRisk = "Risk / Target Logic"
float sweepDepthAtr = input.float(0.10, "Sweep Depth ATR", minval = 0.00, maxval = 1.20, step = 0.01, group = groupRisk, tooltip = TT_SWEEP)
float triggerBufferAtr = input.float(0.06, "Continuation Trigger Buffer ATR", minval = 0.00, maxval = 1.50, step = 0.01, group = groupRisk, tooltip = TT_TRIGGER)
float invalidationBufferAtr = input.float(0.20, "Invalidation Edge Buffer ATR", minval = 0.00, maxval = 2.00, step = 0.01, group = groupRisk, tooltip = TT_RISK)
float targetAtrFallback = input.float(1.65, "Target Room ATR Fallback", minval = 0.40, maxval = 6.00, step = 0.05, group = groupRisk, tooltip = TT_TARGET)
float targetRiskMultiple = input.float(1.35, "Target Corridor R Multiple", minval = 0.50, maxval = 4.00, step = 0.05, group = groupRisk, tooltip = TT_RMULT)
float cleanRoomAtr = input.float(1.80, "Clean Target Room ATR", minval = 0.40, maxval = 8.00, step = 0.05, group = groupRisk, tooltip = TT_CLEAN_ROOM)
int proofWindow = input.int(14, "Target-Reach Proof Window", minval = 4, maxval = 80, group = groupRisk, tooltip = TT_PROOF_WINDOW)
int proofMinSamples = input.int(6, "Target-Reach Min Samples", minval = 3, maxval = 50, group = groupRisk, tooltip = TT_PROOF_SAMPLES)

string groupVisual = "Chart Visuals"
bool showStopRunZones = input.bool(true, "Show Stop-Run Zones", group = groupVisual, tooltip = TT_ZONES)
bool showGuideLines = input.bool(true, "Show Trigger / Risk / Target Guides", group = groupVisual, tooltip = TT_LINES)
bool showTargetCorridor = input.bool(true, "Show Target Corridor", group = groupVisual, tooltip = TT_CORRIDOR)
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupVisual, tooltip = TT_LABELS)
bool showReviewLabels = input.bool(false, "Show Review Labels", group = groupVisual, tooltip = TT_REVIEW_LABELS)
bool showContextLabels = input.bool(true, "Show Sparse Watch Labels", group = groupVisual, tooltip = TT_CONTEXT)
bool showLabelScore = input.bool(false, "Show Label Score", group = groupVisual, tooltip = TT_SCORE_LABEL)
int labelCooldownBars = input.int(40, "Event Label Cooldown", minval = 1, maxval = 120, group = groupVisual, tooltip = TT_COOLDOWN)
int contextSpacingBars = input.int(44, "Watch Label Spacing", minval = 4, maxval = 160, group = groupVisual, tooltip = TT_CONTEXT_SPACING)
int maxVisibleObjects = input.int(5, "Max Visible Event Sets", minval = 4, maxval = 30, group = groupVisual, tooltip = TT_MAX_OBJECTS)
int visualRenderBars = input.int(800, "Visual Render Lookback", minval = 100, maxval = 5000, group = groupVisual, tooltip = TT_RENDER)
int forwardBars = input.int(34, "Forward Render Bars", minval = 8, maxval = 160, group = groupVisual, tooltip = TT_FORWARD)
bool adaptiveProjection = input.bool(true, "Adaptive HTF Projection", group = groupVisual, tooltip = TT_ADAPTIVE)
float zoneBadgeAnchor = input.float(0.50, "Zone Badge Anchor", minval = 0.25, maxval = 0.75, step = 0.05, group = groupVisual, tooltip = TT_BADGE)
int zoneTransparency = input.int(90, "Zone Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = TT_ZONE_OPACITY)
float labelOffsetAtr = input.float(0.70, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupVisual, tooltip = TT_OFFSET)
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisual, tooltip = TT_LABEL_SIZE)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = TT_PANEL_SHOW)
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = TT_PANEL_LOCATION)
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = groupPanel, tooltip = TT_PANEL_THEME)
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel, tooltip = TT_PANEL_SIZE)

string groupAlerts = "Alerts"
int alertScore = input.int(74, "Minimum Alert Score", minval = 40, maxval = 95, group = groupAlerts, tooltip = TT_ALERT)

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

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    float result = 0.0
    if value <= idealValue
        result := f_norm_high_good(value, lowValue, idealValue)
    else
        result := f_norm_low_good(value, idealValue, highValue)
    result

// Luminance-aware contrast: dark text on light/amber/pink/indigo badges, light text on teal/red/slate
f_text_on(color bgColor) =>
    float brightness = color.r(bgColor) * 0.299 + color.g(bgColor) * 0.587 + color.b(bgColor) * 0.114
    brightness > 145.0 ? darkText : headerText

f_text_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_font_gap_mult(string sizeText) =>
    switch sizeText
        "Tiny" => 0.18
        "Small" => 0.22
        "Large" => 0.34
        "Huge" => 0.42
        => 0.28

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

f_panel_bg() =>
    panelTheme == "Clean Light" ? color.rgb(241, 245, 249) : panelTheme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_border() =>
    panelTheme == "Clean Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label() =>
    panelTheme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value() =>
    panelTheme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(int row) =>
    if panelTheme == "Clean Light"
        row % 2 == 0 ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)
    else if panelTheme == "Slate"
        row % 2 == 0 ? color.rgb(37, 49, 70) : color.rgb(30, 41, 59)
    else
        row % 2 == 0 ? color.rgb(15, 23, 42) : color.rgb(30, 41, 59)

f_fmt_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_score_text(float value) =>
    na(value) ? "-" : str.tostring(math.round(f_clamp(value, 0.0, 100.0))) + "/100"

f_pct_text(float value) =>
    na(value) ? "-" : str.tostring(math.round(f_clamp(value, 0.0, 100.0))) + "%"

f_room_text(float value) =>
    na(value) ? "-" : str.tostring(value, "#.#") + " ATR"

f_grade(float score) =>
    string grade = "D"
    if score >= 86.0
        grade := "A+"
    else if score >= 76.0
        grade := "A"
    else if score >= 66.0
        grade := "B"
    else if score >= 55.0
        grade := "C"
    grade

f_score_color(float score) =>
    color result = f_panel_value()
    if score >= minContinuationScore
        result := bullColor
    else if score >= watchScore
        result := neutralColor
    else if score >= 35.0
        result := accentColor
    result

f_risk_color(float risk) =>
    na(risk) ? f_panel_value() : risk >= 70.0 ? dangerColor : risk >= 48.0 ? neutralColor : bullColor

f_side_color(int dir) =>
    dir == 1 ? bullColor : dir == -1 ? bearColor : f_panel_value()

f_side_text(int dir) =>
    dir == 1 ? "Upper Sweep" : dir == -1 ? "Lower Sweep" : "Scanning"

f_risk_tier(float risk) =>
    risk >= 70.0 ? "High " + f_pct_text(risk) : risk >= 48.0 ? "Elevated " + f_pct_text(risk) : "Controlled " + f_pct_text(risk)

f_panel_row(table panel, int row, string labelText, string valueText, color valueColor, string textSize) =>
    table.cell(panel, 0, row, labelText, text_color = f_panel_label(), bgcolor = f_row_bg(row), text_size = f_text_size(textSize), text_halign = text.align_left)
    table.cell(panel, 1, row, valueText, text_color = valueColor, bgcolor = f_row_bg(row), text_size = f_text_size(textSize), text_halign = text.align_right)

f_clear_boxes(array<box> items) =>
    while array.size(items) > 0
        box.delete(array.pop(items))

f_clear_lines(array<line> items) =>
    while array.size(items) > 0
        line.delete(array.pop(items))

f_clear_labels(array<label> items) =>
    while array.size(items) > 0
        label.delete(array.pop(items))

// Vertical anti-collision for candle-edge labels (continue / watch / review)
f_resolve_edge(int b, float y, int dirSign, float atrValue, string sizeText, array<int> bars, array<float> ys) =>
    float sep = math.max(atrValue, syminfo.mintick) * (1.45 + f_font_gap_mult(sizeText) * 2.0)
    int barWin = 12 + int(math.round(f_font_gap_mult(sizeText) * 26.0))
    float adj = y
    int guard = 0
    bool collide = true
    while collide and guard < 10
        collide := false
        int n = array.size(bars)
        if n > 0
            for i = 0 to n - 1
                if math.abs(b - array.get(bars, i)) <= barWin and math.abs(adj - array.get(ys, i)) < sep
                    collide := true
        if collide
            adj := adj + dirSign * sep
        guard := guard + 1
    adj

// -------------------------------------------------
// Core Calculations
// -------------------------------------------------
float atr = math.max(nz(ta.atr(atrLength), ta.tr(true)), syminfo.mintick)
int visualForwardBars = adaptiveProjection ? timeframe.ismonthly ? math.min(forwardBars, 8) : timeframe.isweekly ? math.min(forwardBars, 14) : timeframe.isdaily ? math.min(forwardBars, 20) : forwardBars : forwardBars
float upperRef = ta.highest(high[1], referenceLookback)
float lowerRef = ta.lowest(low[1], referenceLookback)
float referenceRange = not na(upperRef) and not na(lowerRef) ? math.max(upperRef - lowerRef, atr) : atr
float fastEma = ta.ema(close, 21)
float slowEma = ta.ema(close, 55)
float volBase = ta.sma(volume, volumeLength)
float volumeRatio = na(volBase) or volBase == 0.0 ? 1.0 : volume / volBase
float candleRange = math.max(high - low, syminfo.mintick)
float bodyEfficiency = math.abs(close - open) / candleRange * 100.0

float sensSweepAdd = sensitivity == "Aggressive" ? -0.04 : sensitivity == "Conservative" ? 0.08 : 0.0
float sensCloseNeed = sensitivity == "Aggressive" ? 0.00 : sensitivity == "Conservative" ? 0.12 : 0.05
float sensCloseQuality = sensitivity == "Aggressive" ? 46.0 : sensitivity == "Conservative" ? 64.0 : 54.0
float minSweepDepth = math.max(0.0, sweepDepthAtr + sensSweepAdd)
float closeBuffer = triggerBufferAtr + sensCloseNeed

bool confirmedBar = not confirmOnClose or barstate.isconfirmed
bool allowBull = sideMode == "Auto" or sideMode == "Bullish Only"
bool allowBear = sideMode == "Auto" or sideMode == "Bearish Only"

bool bullSweep = allowBull and not na(upperRef) and high > upperRef + atr * minSweepDepth
bool bearSweep = allowBear and not na(lowerRef) and low < lowerRef - atr * minSweepDepth

float bullDepthAtr = bullSweep ? (high - upperRef) / atr : 0.0
float bearDepthAtr = bearSweep ? (lowerRef - low) / atr : 0.0
float bullCloseAtr = bullSweep ? (close - upperRef) / atr : 0.0
float bearCloseAtr = bearSweep ? (lowerRef - close) / atr : 0.0
float bullCloseLocation = (close - low) / candleRange * 100.0
float bearCloseLocation = (high - close) / candleRange * 100.0
float bullUpperRejection = (high - close) / candleRange * 100.0
float bearLowerRejection = (close - low) / candleRange * 100.0

bool bullCloseContinuation = bullSweep and close > upperRef + atr * closeBuffer
bool bearCloseContinuation = bearSweep and close < lowerRef - atr * closeBuffer
bool bullTrendSupport = close > slowEma and fastEma >= slowEma
bool bearTrendSupport = close < slowEma and fastEma <= slowEma
bool bullTrendNeutral = close > slowEma or fastEma >= slowEma
bool bearTrendNeutral = close < slowEma or fastEma <= slowEma

float bullTrigger = upperRef + atr * triggerBufferAtr
float bearTrigger = lowerRef - atr * triggerBufferAtr
float bullRiskEdge = upperRef - atr * invalidationBufferAtr
float bearRiskEdge = lowerRef + atr * invalidationBufferAtr
float bullRiskDistance = math.max(bullTrigger - bullRiskEdge, atr * 0.20)
float bearRiskDistance = math.max(bearRiskEdge - bearTrigger, atr * 0.20)
float bullTargetDistance = math.max(math.max(bullRiskDistance * targetRiskMultiple, atr * targetAtrFallback), referenceRange * 0.25)
float bearTargetDistance = math.max(math.max(bearRiskDistance * targetRiskMultiple, atr * targetAtrFallback), referenceRange * 0.25)
float bullTarget = bullTrigger + bullTargetDistance
float bearTarget = bearTrigger - bearTargetDistance
float bullTargetRoomAtr = math.max((bullTarget - close) / atr, 0.0)
float bearTargetRoomAtr = math.max((close - bearTarget) / atr, 0.0)

float bullSweepScore = f_peak_score(bullDepthAtr, minSweepDepth, 0.75, 2.80)
float bearSweepScore = f_peak_score(bearDepthAtr, minSweepDepth, 0.75, 2.80)
float bullCloseScore = (f_norm_high_good(bullCloseAtr, 0.0, 0.85) * 0.55) + (f_norm_high_good(bullCloseLocation, sensCloseQuality, 88.0) * 0.30) + (f_norm_high_good(bodyEfficiency, 32.0, 78.0) * 0.15)
float bearCloseScore = (f_norm_high_good(bearCloseAtr, 0.0, 0.85) * 0.55) + (f_norm_high_good(bearCloseLocation, sensCloseQuality, 88.0) * 0.30) + (f_norm_high_good(bodyEfficiency, 32.0, 78.0) * 0.15)
float volumeScore = f_norm_high_good(volumeRatio, 0.75, 1.80)
float bullTrendScore = bullTrendSupport ? 100.0 : bullTrendNeutral ? 62.0 : 25.0
float bearTrendScore = bearTrendSupport ? 100.0 : bearTrendNeutral ? 62.0 : 25.0
float bullRoomScore = f_norm_high_good(bullTargetRoomAtr, 0.40, cleanRoomAtr)
float bearRoomScore = f_norm_high_good(bearTargetRoomAtr, 0.40, cleanRoomAtr)

float bullReversalRisk = f_clamp((bullUpperRejection * 0.42) + ((100.0 - bullCloseScore) * 0.30) + (bullTrendSupport ? 0.0 : bullTrendNeutral ? 12.0 : 28.0) + (volumeRatio < 0.80 ? 12.0 : 0.0), 0.0, 100.0)
float bearReversalRisk = f_clamp((bearLowerRejection * 0.42) + ((100.0 - bearCloseScore) * 0.30) + (bearTrendSupport ? 0.0 : bearTrendNeutral ? 12.0 : 28.0) + (volumeRatio < 0.80 ? 12.0 : 0.0), 0.0, 100.0)

float bullContinuationScore = bullSweep ? f_clamp((bullSweepScore * 0.18) + (bullCloseScore * 0.28) + (volumeScore * 0.15) + (bullTrendScore * 0.18) + (bullRoomScore * 0.21) - (bullReversalRisk * 0.08), 0.0, 100.0) : 0.0
float bearContinuationScore = bearSweep ? f_clamp((bearSweepScore * 0.18) + (bearCloseScore * 0.28) + (volumeScore * 0.15) + (bearTrendScore * 0.18) + (bearRoomScore * 0.21) - (bearReversalRisk * 0.08), 0.0, 100.0) : 0.0

bool bullModeReady = confirmationMode == "Close Continuation" ? bullCloseContinuation : confirmationMode == "Close + Volume" ? bullCloseContinuation and volumeRatio >= 1.0 : bullCloseContinuation and volumeRatio >= 1.05 and bullCloseLocation >= sensCloseQuality and bullTrendNeutral
bool bearModeReady = confirmationMode == "Close Continuation" ? bearCloseContinuation : confirmationMode == "Close + Volume" ? bearCloseContinuation and volumeRatio >= 1.0 : bearCloseContinuation and volumeRatio >= 1.05 and bearCloseLocation >= sensCloseQuality and bearTrendNeutral

bool chooseBull = bullSweep and (not bearSweep or bullContinuationScore >= bearContinuationScore)
bool chooseBear = bearSweep and not chooseBull
int eventDir = chooseBull ? 1 : chooseBear ? -1 : 0
float eventScore = eventDir == 1 ? bullContinuationScore : eventDir == -1 ? bearContinuationScore : 0.0
float eventReversalRisk = eventDir == 1 ? bullReversalRisk : eventDir == -1 ? bearReversalRisk : na
float eventTargetRoom = eventDir == 1 ? bullTargetRoomAtr : eventDir == -1 ? bearTargetRoomAtr : na
float eventTrigger = eventDir == 1 ? bullTrigger : eventDir == -1 ? bearTrigger : na
float eventRiskEdge = eventDir == 1 ? bullRiskEdge : eventDir == -1 ? bearRiskEdge : na
float eventTarget = eventDir == 1 ? bullTarget : eventDir == -1 ? bearTarget : na
float eventZoneTop = eventDir == 1 ? high : eventDir == -1 ? lowerRef : na
float eventZoneBottom = eventDir == 1 ? upperRef : eventDir == -1 ? low : na
bool eventModeReady = eventDir == 1 ? bullModeReady : eventDir == -1 ? bearModeReady : false
bool rawReady = confirmedBar and eventDir != 0 and eventModeReady and eventScore >= minContinuationScore
bool rawWatch = confirmedBar and eventDir != 0 and eventScore >= watchScore and not rawReady

// -------------------------------------------------
// State Memory
// -------------------------------------------------
var int lastEventBar = na
var int lastEventDir = 0
var float lastScore = na
var float lastReversalRisk = na
var float lastTargetRoom = na
var float lastRiskEdge = na
var float lastTarget = na
var string lastState = "Scanning"
var string lastAction = "Wait for stop-run continuation"
var int lastFullLabelBar = na
var int lastContextLabelBar = na
var int lastInvalidationBar = na
var int lastTargetBar = na
var int[] readyBars = array.new_int()
var int[] readyDirs = array.new_int()
var float[] readyScores = array.new_float()
var float[] readyZoneTops = array.new_float()
var float[] readyZoneBottoms = array.new_float()
var float[] readyTriggers = array.new_float()
var float[] readyRiskEdges = array.new_float()
var float[] readyTargets = array.new_float()
var float[] readyAtrs = array.new_float()
var bool[] readyLabelFlags = array.new_bool()
var int[] watchBarsStore = array.new_int()
var int[] watchDirsStore = array.new_int()
var float[] watchAnchors = array.new_float()
var float[] watchAtrs = array.new_float()
var int[] reviewBarsStore = array.new_int()
var int[] reviewDirsStore = array.new_int()
var int[] reviewTypes = array.new_int()
var float[] reviewAnchors = array.new_float()
var float[] reviewAtrs = array.new_float()

bool canFullLabel = na(lastFullLabelBar) or bar_index - lastFullLabelBar >= labelCooldownBars
bool canContextLabel = na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars
bool readyEvent = rawReady and (not rawReady[1] or eventDir != eventDir[1])
bool watchEvent = rawWatch and (not rawWatch[1] or eventDir != eventDir[1])
bool readyLabelEvent = readyEvent and canFullLabel
bool watchLabelEvent = watchEvent and canContextLabel
bool priorPlanUnresolved = not na(lastEventBar) and bar_index - lastEventBar <= activeReviewBars and na(lastInvalidationBar) and na(lastTargetBar)
bool watchStateEvent = watchEvent and not priorPlanUnresolved
bool anyStateUpdate = readyEvent or watchStateEvent

if anyStateUpdate
    lastEventBar := bar_index
    lastEventDir := eventDir
    lastScore := eventScore
    lastReversalRisk := eventReversalRisk
    lastTargetRoom := eventTargetRoom
    lastRiskEdge := eventRiskEdge
    lastTarget := eventTarget
    lastState := readyEvent ? (eventDir == 1 ? "Bull Continuation Ready" : "Bear Continuation Ready") : (eventDir == 1 ? "Bull Continuation Watch" : "Bear Continuation Watch")
    lastAction := readyEvent ? "Review continuation plan" : "Wait for close follow-through"
    lastInvalidationBar := na
    lastTargetBar := na

if readyEvent
    bool openNewVisualSlot = readyLabelEvent or array.size(readyBars) == 0
    if openNewVisualSlot
        array.push(readyBars, bar_index)
        array.push(readyDirs, eventDir)
        array.push(readyScores, eventScore)
        array.push(readyZoneTops, eventZoneTop)
        array.push(readyZoneBottoms, eventZoneBottom)
        array.push(readyTriggers, eventTrigger)
        array.push(readyRiskEdges, eventRiskEdge)
        array.push(readyTargets, eventTarget)
        array.push(readyAtrs, atr)
        array.push(readyLabelFlags, true)
    else
        int latestVisual = array.size(readyBars) - 1
        array.set(readyBars, latestVisual, bar_index)
        array.set(readyDirs, latestVisual, eventDir)
        array.set(readyScores, latestVisual, eventScore)
        array.set(readyZoneTops, latestVisual, eventZoneTop)
        array.set(readyZoneBottoms, latestVisual, eventZoneBottom)
        array.set(readyTriggers, latestVisual, eventTrigger)
        array.set(readyRiskEdges, latestVisual, eventRiskEdge)
        array.set(readyTargets, latestVisual, eventTarget)
        array.set(readyAtrs, latestVisual, atr)
        array.set(readyLabelFlags, latestVisual, true)
    while array.size(readyBars) > MAX_STORED_READY_EVENTS
        array.shift(readyBars)
        array.shift(readyDirs)
        array.shift(readyScores)
        array.shift(readyZoneTops)
        array.shift(readyZoneBottoms)
        array.shift(readyTriggers)
        array.shift(readyRiskEdges)
        array.shift(readyTargets)
        array.shift(readyAtrs)
        array.shift(readyLabelFlags)

if watchLabelEvent
    array.push(watchBarsStore, bar_index)
    array.push(watchDirsStore, eventDir)
    array.push(watchAnchors, eventDir == 1 ? high : low)
    array.push(watchAtrs, atr)
    while array.size(watchBarsStore) > MAX_STORED_WATCH_EVENTS
        array.shift(watchBarsStore)
        array.shift(watchDirsStore)
        array.shift(watchAnchors)
        array.shift(watchAtrs)

bool activeContext = not na(lastEventBar) and bar_index - lastEventBar <= activeReviewBars
bool invalidationAlreadyMarked = activeContext and not na(lastInvalidationBar) and lastInvalidationBar >= lastEventBar
bool targetAlreadyMarked = activeContext and not na(lastTargetBar) and lastTargetBar >= lastEventBar
bool contextResolved = invalidationAlreadyMarked or targetAlreadyMarked
bool invalidationHit = not na(lastRiskEdge) and ((lastEventDir == 1 and low <= lastRiskEdge) or (lastEventDir == -1 and high >= lastRiskEdge))
bool targetHit = not na(lastTarget) and ((lastEventDir == 1 and high >= lastTarget) or (lastEventDir == -1 and low <= lastTarget))
bool invalidationSignal = confirmedBar and activeContext and bar_index > lastEventBar and not contextResolved and invalidationHit
bool targetSignal = confirmedBar and activeContext and bar_index > lastEventBar and not contextResolved and not invalidationSignal and targetHit

if invalidationSignal
    lastInvalidationBar := bar_index
    lastState := "Invalidation Review"
    lastAction := "Re-check continuation structure"
    array.push(reviewBarsStore, bar_index)
    array.push(reviewDirsStore, lastEventDir)
    array.push(reviewTypes, 1)
    array.push(reviewAnchors, lastEventDir == 1 ? low : high)
    array.push(reviewAtrs, atr)
    while array.size(reviewBarsStore) > MAX_STORED_REVIEW_EVENTS
        array.shift(reviewBarsStore)
        array.shift(reviewDirsStore)
        array.shift(reviewTypes)
        array.shift(reviewAnchors)
        array.shift(reviewAtrs)

if targetSignal
    lastTargetBar := bar_index
    lastState := "Target Review"
    lastAction := "Review target response"
    array.push(reviewBarsStore, bar_index)
    array.push(reviewDirsStore, lastEventDir)
    array.push(reviewTypes, 2)
    array.push(reviewAnchors, lastEventDir == 1 ? high : low)
    array.push(reviewAtrs, atr)
    while array.size(reviewBarsStore) > MAX_STORED_REVIEW_EVENTS
        array.shift(reviewBarsStore)
        array.shift(reviewDirsStore)
        array.shift(reviewTypes)
        array.shift(reviewAnchors)
        array.shift(reviewAtrs)

// -------------------------------------------------
// Target-Reach Proof (reach target corridor before invalidation edge)
// -------------------------------------------------
var bool rpPending = false
var int rpDir = 0
var float rpGoal = na
var float rpStop = na
var int rpExpiry = na
var int rpStart = na
var int rpWins = 0
var int rpTotal = 0

if readyEvent and not rpPending and eventDir != 0 and not na(eventTarget) and not na(eventRiskEdge)
    rpPending := true
    rpDir := eventDir
    rpGoal := eventTarget
    rpStop := eventRiskEdge
    rpExpiry := bar_index + proofWindow
    rpStart := bar_index

if rpPending and barstate.isconfirmed and not na(rpStart) and bar_index > rpStart
    bool rpWin = rpDir == 1 ? high >= rpGoal : low <= rpGoal
    bool rpLoss = rpDir == 1 ? low <= rpStop : high >= rpStop
    if rpLoss
        rpTotal += 1
        rpPending := false
    else if rpWin
        rpTotal += 1
        rpWins += 1
        rpPending := false
    else if bar_index >= rpExpiry
        rpTotal += 1
        rpPending := false

float rpRate = rpTotal > 0 ? rpWins / rpTotal * 100.0 : na
bool rpReady = rpTotal >= proofMinSamples
string rpText = rpReady ? str.tostring(math.round(rpRate)) + "% | " + str.tostring(rpWins) + "/" + str.tostring(rpTotal) : "Building | " + str.tostring(rpTotal) + "/" + str.tostring(proofMinSamples)

string displayStopRun = activeContext ? f_side_text(lastEventDir) : eventDir != 0 ? f_side_text(eventDir) : "Scanning"
float displayScore = activeContext ? lastScore : eventScore
float displayRisk = activeContext ? lastReversalRisk : eventReversalRisk
float displayRoom = activeContext ? lastTargetRoom : eventTargetRoom
string displayAction = activeContext ? lastAction : eventDir != 0 ? (rawReady ? "Review continuation plan" : "Wait for close follow-through") : "Wait for stop-run continuation"
string displayState = activeContext ? lastState : eventDir != 0 ? (rawReady ? "Continuation Ready" : rawWatch ? "Continuation Watch" : "Sweep Review") : "Scanning"
string displayStopRunPanel = displayStopRun == "Scanning" and displayState == "Scanning" ? "Scanning" : displayStopRun + " | " + displayState
color displayColor = displayState == "Invalidation Review" ? dangerColor : displayState == "Target Review" ? accentColor : activeContext ? f_side_color(lastEventDir) : f_side_color(eventDir)

// -------------------------------------------------
// Visual Objects
// -------------------------------------------------
var array<box> zoneBoxes = array.new<box>()
var array<box> corridorBoxes = array.new<box>()
var array<line> guideLines = array.new<line>()
var array<label> chartLabels = array.new<label>()

int maxLabels = maxVisibleObjects * 4
if readyLabelEvent
    lastFullLabelBar := bar_index

if watchLabelEvent
    lastContextLabelBar := bar_index

if barstate.islast
    int renderStartBar = math.max(0, last_bar_index - visualRenderBars)
    f_clear_boxes(zoneBoxes)
    f_clear_boxes(corridorBoxes)
    f_clear_lines(guideLines)
    f_clear_labels(chartLabels)

    // Local registry for candle-edge labels so continue / watch / review badges never stack
    array<int> edgeBars = array.new_int()
    array<float> edgeYs = array.new_float()

    if array.size(readyBars) > 0
        int readyStart = math.max(0, array.size(readyBars) - maxVisibleObjects)
        for i = readyStart to array.size(readyBars) - 1
            int readyBar = array.get(readyBars, i)
            if readyBar >= renderStartBar
                int readyDir = array.get(readyDirs, i)
                float readyScore = array.get(readyScores, i)
                float readyZoneTop = array.get(readyZoneTops, i)
                float readyZoneBottom = array.get(readyZoneBottoms, i)
                float readyTrigger = array.get(readyTriggers, i)
                float readyRiskEdge = array.get(readyRiskEdges, i)
                float readyTarget = array.get(readyTargets, i)
                float readyAtr = array.get(readyAtrs, i)
                color readyColor = f_side_color(readyDir)
                int visualRight = readyBar + visualForwardBars
                int desiredBadgeGap = labelFontSize == "Huge" ? 8 : labelFontSize == "Large" ? 7 : labelFontSize == "Normal" ? 5 : 4
                int badgeGapBars = math.min(desiredBadgeGap, math.max(2, int(math.floor(visualForwardBars * 0.22))))
                int usableProjection = math.max(6, visualForwardBars - badgeGapBars)
                int splitBars = math.min(math.max(3, int(math.round(usableProjection * 0.42))), visualForwardBars - badgeGapBars - 2)
                int zoneRight = readyBar + splitBars
                int corridorLeft = zoneRight + badgeGapBars
                float minZoneHeight = readyAtr * 0.12
                float zoneTop = math.max(readyZoneTop, readyZoneBottom + minZoneHeight)
                float zoneBottom = math.min(readyZoneBottom, readyZoneTop - minZoneHeight)
                // Boxes first (background)
                if showStopRunZones and not na(zoneTop) and not na(zoneBottom)
                    box stopRunBox = box.new(left = readyBar, top = zoneTop, right = zoneRight, bottom = zoneBottom, xloc = xloc.bar_index, bgcolor = color.new(readyColor, zoneTransparency), border_color = color.new(readyColor, 35), border_width = 1)
                    array.push(zoneBoxes, stopRunBox)
                if showTargetCorridor and not na(readyTarget) and not na(readyTrigger)
                    float corridorTop = readyDir == 1 ? readyTarget : readyTrigger
                    float corridorBottom = readyDir == 1 ? readyTrigger : readyTarget
                    box corridor = box.new(left = corridorLeft, top = corridorTop, right = visualRight, bottom = corridorBottom, xloc = xloc.bar_index, bgcolor = color.new(readyColor, 94), border_color = color.new(readyColor, 60), border_width = 1)
                    array.push(corridorBoxes, corridor)
                bool ownedGuideSet = readyBar == lastEventBar and activeContext and not contextResolved and not invalidationSignal and not targetSignal
                // Only the latest unresolved plan owns rails. Every rail ends in a filled price badge.
                if showGuideLines and ownedGuideSet and not na(readyTrigger) and not na(readyRiskEdge) and not na(readyTarget)
                    line triggerLine = line.new(readyBar, readyTrigger, visualRight, readyTrigger, xloc = xloc.bar_index, extend = extend.none, color = color.new(readyColor, 0), width = 2, style = line.style_solid)
                    line riskLine = line.new(readyBar, readyRiskEdge, visualRight, readyRiskEdge, xloc = xloc.bar_index, extend = extend.none, color = color.new(dangerColor, 0), width = 1, style = line.style_dashed)
                    line targetLine = line.new(readyBar, readyTarget, visualRight, readyTarget, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 0), width = 1, style = line.style_dotted)
                    array.push(guideLines, triggerLine)
                    array.push(guideLines, riskLine)
                    array.push(guideLines, targetLine)
                    float guideGap = math.max(readyAtr * (0.55 + f_font_gap_mult(labelFontSize)), syminfo.mintick * 24.0)
                    float invalidLaneExtra = math.max(readyAtr * 0.35, syminfo.mintick * 10.0)
                    float triggerTagY = readyDir == 1 ? readyTrigger - guideGap : readyTrigger + guideGap
                    float riskTagY = readyDir == 1 ? math.min(readyRiskEdge - invalidLaneExtra, triggerTagY - guideGap - invalidLaneExtra) : math.max(readyRiskEdge + invalidLaneExtra, triggerTagY + guideGap + invalidLaneExtra)
                    float targetTagY = readyDir == 1 ? math.max(readyTarget, readyTrigger + guideGap) : math.min(readyTarget, readyTrigger - guideGap)
                    int guideTagX = visualRight + badgeGapBars + 4
                    line triggerOwner = line.new(visualRight, readyTrigger, guideTagX, triggerTagY, xloc = xloc.bar_index, extend = extend.none, color = color.new(readyColor, 0), width = 2)
                    line riskOwner = line.new(visualRight, readyRiskEdge, guideTagX, riskTagY, xloc = xloc.bar_index, extend = extend.none, color = color.new(dangerColor, 0), width = 1, style = line.style_dashed)
                    line targetOwner = line.new(visualRight, readyTarget, guideTagX, targetTagY, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 0), width = 1, style = line.style_dotted)
                    array.push(guideLines, triggerOwner)
                    array.push(guideLines, riskOwner)
                    array.push(guideLines, targetOwner)
                    label triggerBadge = label.new(guideTagX, triggerTagY, "Trigger " + f_fmt_price(readyTrigger), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(readyColor, 0), textcolor = f_text_on(readyColor), size = f_text_size(labelFontSize), textalign = text.align_left)
                    label riskBadge = label.new(guideTagX, riskTagY, "Invalid " + f_fmt_price(readyRiskEdge), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(dangerColor, 0), textcolor = f_text_on(dangerColor), size = f_text_size(labelFontSize), textalign = text.align_left)
                    label targetBadge = label.new(guideTagX, targetTagY, "Target " + f_fmt_price(readyTarget), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 0), textcolor = f_text_on(accentColor), size = f_text_size(labelFontSize), textalign = text.align_left)
                    array.push(chartLabels, triggerBadge)
                    array.push(chartLabels, riskBadge)
                    array.push(chartLabels, targetBadge)
                // Centered badges last (on top of lines/boxes)
                if showStopRunZones and not na(zoneTop) and not na(zoneBottom)
                    int runX = readyBar + int(math.floor((zoneRight - readyBar) * zoneBadgeAnchor))
                    label runBadge = label.new(runX, (zoneTop + zoneBottom) * 0.5, "RUN " + str.tostring(math.round(readyScore)), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(readyColor, 0), textcolor = f_text_on(readyColor), size = f_text_size(labelFontSize), textalign = text.align_center)
                    array.push(chartLabels, runBadge)
                    array.push(edgeBars, runX)
                    array.push(edgeYs, (zoneTop + zoneBottom) * 0.5)
                if showTargetCorridor and not na(readyTarget) and not na(readyTrigger)
                    float corridorTop = readyDir == 1 ? readyTarget : readyTrigger
                    float corridorBottom = readyDir == 1 ? readyTrigger : readyTarget
                    int roomX = corridorLeft + int(math.floor((visualRight - corridorLeft) * zoneBadgeAnchor))
                    float corridorAtr = math.abs(readyTarget - readyTrigger) / math.max(readyAtr, syminfo.mintick)
                    label roomBadge = label.new(roomX, (corridorTop + corridorBottom) * 0.5, "ROOM " + str.tostring(corridorAtr, "#.#") + " ATR", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(panelBorder, 0), textcolor = f_text_on(panelBorder), size = f_text_size(labelFontSize), textalign = text.align_center)
                    array.push(chartLabels, roomBadge)
                    array.push(edgeBars, roomX)
                    array.push(edgeYs, (corridorTop + corridorBottom) * 0.5)
                // Event label on the candle edge, collision-resolved
                bool showThisReadyLabel = array.get(readyLabelFlags, i)
                if showEventLabels and showThisReadyLabel
                    string scorePart = showLabelScore ? " | " + str.tostring(math.round(readyScore)) + " " + f_grade(readyScore) : ""
                    float baseY = readyDir == 1 ? readyZoneTop + readyAtr * labelOffsetAtr : readyZoneBottom - readyAtr * labelOffsetAtr
                    float labelY = f_resolve_edge(readyBar, baseY, readyDir == 1 ? 1 : -1, readyAtr, labelFontSize, edgeBars, edgeYs)
                    array.push(edgeBars, readyBar)
                    array.push(edgeYs, labelY)
                    label eventLabel = label.new(readyBar, labelY, "CONTINUE" + scorePart, xloc = xloc.bar_index, yloc = yloc.price, style = readyDir == 1 ? label.style_label_down : label.style_label_up, color = color.new(readyColor, 0), textcolor = f_text_on(readyColor), size = f_text_size(labelFontSize), textalign = text.align_center)
                    array.push(chartLabels, eventLabel)

    if showEventLabels and showContextLabels and array.size(watchBarsStore) > 0
        int watchStart = math.max(0, array.size(watchBarsStore) - maxLabels)
        for i = watchStart to array.size(watchBarsStore) - 1
            int watchBar = array.get(watchBarsStore, i)
            if watchBar >= renderStartBar
                int watchDir = array.get(watchDirsStore, i)
                float watchAnchor = array.get(watchAnchors, i)
                float watchAtr = array.get(watchAtrs, i)
                float watchBase = watchDir == 1 ? watchAnchor + watchAtr * (labelOffsetAtr + 0.28) : watchAnchor - watchAtr * (labelOffsetAtr + 0.28)
                float watchY = f_resolve_edge(watchBar, watchBase, watchDir == 1 ? 1 : -1, watchAtr, labelFontSize, edgeBars, edgeYs)
                array.push(edgeBars, watchBar)
                array.push(edgeYs, watchY)
                color watchCol = f_side_color(watchDir)
                label watchLabel = label.new(watchBar, watchY, watchDir == 1 ? "UP RUN | WATCH" : "LOW RUN | WATCH", xloc = xloc.bar_index, yloc = yloc.price, style = watchDir == 1 ? label.style_label_down : label.style_label_up, color = color.new(watchCol, 0), textcolor = f_text_on(watchCol), size = f_text_size(labelFontSize), textalign = text.align_center)
                array.push(chartLabels, watchLabel)

    if showEventLabels and showReviewLabels and array.size(reviewBarsStore) > 0
        int reviewStart = math.max(0, array.size(reviewBarsStore) - maxLabels)
        for i = reviewStart to array.size(reviewBarsStore) - 1
            int reviewBar = array.get(reviewBarsStore, i)
            if reviewBar >= renderStartBar
                int reviewDir = array.get(reviewDirsStore, i)
                int reviewType = array.get(reviewTypes, i)
                float reviewAnchor = array.get(reviewAnchors, i)
                float reviewAtr = array.get(reviewAtrs, i)
                float reviewBase = reviewDir == 1 ? reviewAnchor + (reviewType == 1 ? -reviewAtr * labelOffsetAtr : reviewAtr * labelOffsetAtr) : reviewAnchor + (reviewType == 1 ? reviewAtr * labelOffsetAtr : -reviewAtr * labelOffsetAtr)
                bool reviewAbove = reviewDir == 1 ? reviewType == 2 : reviewType == 1
                float reviewY = f_resolve_edge(reviewBar, reviewBase, reviewAbove ? 1 : -1, reviewAtr, labelFontSize, edgeBars, edgeYs)
                array.push(edgeBars, reviewBar)
                array.push(edgeYs, reviewY)
                string reviewText = reviewType == 1 ? "INVALID | REVIEW" : "TARGET | REVIEW"
                color reviewCol = reviewType == 1 ? dangerColor : accentColor
                label reviewLabel = label.new(reviewBar, reviewY, reviewText, xloc = xloc.bar_index, yloc = yloc.price, style = reviewDir == 1 ? (reviewType == 1 ? label.style_label_up : label.style_label_down) : (reviewType == 1 ? label.style_label_down : label.style_label_up), color = color.new(reviewCol, 0), textcolor = f_text_on(reviewCol), size = f_text_size(labelFontSize), textalign = text.align_center)
                array.push(chartLabels, reviewLabel)

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table plannerPanel = na
var string lastPanelTheme = na

if barstate.islast and showPanel
    color activePanelBg = f_panel_bg()
    color activePanelBorder = f_panel_border()
    if na(plannerPanel) or lastPanelTheme != panelTheme
        if not na(plannerPanel)
            table.delete(plannerPanel)
        plannerPanel := table.new(f_panel_pos(panelLocation), 2, 7, bgcolor = activePanelBg, frame_color = activePanelBorder, frame_width = 1, border_color = activePanelBorder, border_width = 1)
        table.merge_cells(plannerPanel, 0, 0, 1, 0)
        lastPanelTheme := panelTheme
    table.set_position(plannerPanel, f_panel_pos(panelLocation))
    table.clear(plannerPanel, 0, 1, 1, 6)
    table.cell(plannerPanel, 0, 0, "AG Pro Stop Run Continuation Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
    string scorePanelText = displayScore > 0.0 ? f_score_text(displayScore) + " " + f_grade(displayScore) : "-"
    string riskPanelText = na(displayRisk) ? "-" : f_risk_tier(displayRisk)
    string roomPanelText = na(displayRoom) ? "-" : f_room_text(displayRoom)
    color rpTierCol = not rpReady ? f_panel_value() : rpRate >= 55.0 ? bullColor : rpRate >= 45.0 ? neutralColor : bearColor
    f_panel_row(plannerPanel, 1, "Stop Run", displayStopRunPanel, displayColor, panelFontSize)
    f_panel_row(plannerPanel, 2, "Continuation Score", scorePanelText, f_score_color(displayScore), panelFontSize)
    f_panel_row(plannerPanel, 3, "Reversal Risk", riskPanelText, f_risk_color(displayRisk), panelFontSize)
    f_panel_row(plannerPanel, 4, "Target Room", roomPanelText, not na(displayRoom) and displayRoom >= cleanRoomAtr ? bullColor : accentColor, panelFontSize)
    f_panel_row(plannerPanel, 5, "Target Reach", rpText, rpTierCol, panelFontSize)
    f_panel_row(plannerPanel, 6, "Action", displayAction, displayColor, panelFontSize)

if not showPanel and not na(plannerPanel)
    table.delete(plannerPanel)
    plannerPanel := na
    lastPanelTheme := na

// -------------------------------------------------
// Alerts
// -------------------------------------------------
bool bullishReadyAlert = readyEvent and eventDir == 1 and eventScore >= alertScore
bool bearishReadyAlert = readyEvent and eventDir == -1 and eventScore >= alertScore
bool watchAlert = watchEvent and eventScore >= alertScore
bool highReversalRiskAlert = watchEvent and eventReversalRisk >= 70.0

alertcondition(bullishReadyAlert, "Bullish Stop-Run Continuation Ready", "Stop Run Continuation Planner: bullish continuation context is READY after an upper stop-run acceptance. This is an attention marker, not a trade instruction.")
alertcondition(bearishReadyAlert, "Bearish Stop-Run Continuation Ready", "Stop Run Continuation Planner: bearish continuation context is READY after a lower stop-run acceptance. This is an attention marker, not a trade instruction.")
alertcondition(watchAlert, "Stop-Run Continuation Watch", "Stop Run Continuation Planner: a stop-run continuation watch state is active. This is an attention marker, not a trade instruction.")
alertcondition(invalidationSignal, "Stop-Run Continuation Invalidation Review", "Stop Run Continuation Planner: the active continuation context has moved through its invalidation edge. This is an attention marker, not a trade instruction.")
alertcondition(targetSignal, "Stop-Run Continuation Target Review", "Stop Run Continuation Planner: price is testing the active target corridor. This is an attention marker, not a trade instruction.")
alertcondition(highReversalRiskAlert, "Stop-Run Reversal Risk Elevated", "Stop Run Continuation Planner: reversal risk is elevated during a stop-run continuation watch state. This is an attention marker, not a trade instruction.")
````
