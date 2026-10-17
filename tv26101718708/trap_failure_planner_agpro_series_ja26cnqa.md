# Trap Failure Planner [AGPro Series]

- url: https://www.tradingview.com/script/ja26CNqA-Trap-Failure-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;bd1a5b4a82de43b5ab5a105681de3a5f
- version: 6.0

## Description

Trap Failure Planner [AGPro Series]

🧠 Core Idea

Is the trap thesis itself failing and handing control back through the edge?


📌 Overview / What it does

Trap Failure Planner is a chart-first control-return planner for traders who study trap behavior, failed participation, false break recovery, and post-trap execution readiness.

Instead of only marking the first trap or false break, the script watches the second step: after a trap thesis appears, does that thesis keep control, or does price return through the trap edge with enough quality to matter? It produces a 0-100 Failure Score, trap thesis zones, control-return labels, risk-edge guides, target-guide references, alerts, and a compact AG Pro planning panel.

It does not predict future price, automate entries, or claim that a control return must continue. Its role is to organize one specific decision question with clean visual structure.


🎯 Purpose & Design Philosophy

This script was built to fill the gap between first-touch trap markers and practical trade review.

Many tools stop when price runs a level and closes back inside. That can be useful, but traders still need to know whether the trap thesis survives after the first reaction. Trap Failure Planner focuses on that later decision point: is the trap still in control, or did the other side reclaim the edge?

The design supports a planner mindset. It helps traders evaluate state, score, risk edge, target context, and next action without turning the chart into a crowded signal board.


⚡ Why This Script Is Different

Most tools focus on the first false break, sweep, trap label, or reclaim back inside a range.

This script does NOT try to become another false-break trap detector, inducement scanner, liquidity grab detector, stop-hunt map, order block map, or generic support / resistance zone tool.

Instead, it focuses on the failure of the trap thesis itself. The workflow begins only after a trap thesis exists, then waits for control to return through the edge with persistence, follow-through, volume response, and acceptance quality.

That makes it a second-stage trap failure planner, not a first-stage trap detector.


⚙️ Methodology

1. Context Detection
The script builds recent upper and lower trap-thesis rails from prior price action and normalizes behavior with ATR.

2. Reference Mapping
When price probes beyond a rail and closes back inside, the script maps a trap thesis zone between the rail and the probe extreme.

3. Reaction Evaluation
The planner tracks whether price returns through the trap edge within the failure window. The 0-100 model evaluates false break behavior, close recovery, follow-through, volume spike, control-return persistence, and level acceptance.

4. Visual Output
Qualified events print Trap Failed labels, retain the centered trap zone, and project risk-edge and target-guide references.


🗺️ How to Read the Chart

Zones = the active trap thesis area between the control edge and the probe extreme.

Labels = trap thesis states, sparse testing states, and confirmed Trap Failed events.

Colors = teal for bullish control-return context, pink for bearish control-return context, yellow for testing states, indigo for target guides, and red for risk edges.

Panel = the AG Pro summary showing Trap State, Failure Score, Control Shift, Risk Edge, and Action.


🚦 Signals & States

• Upper Trap Thesis → price probed above the upper rail and closed back inside; the planner watches whether that trap thesis survives.

• Lower Trap Thesis → price probed below the lower rail and closed back inside; the planner watches whether that trap thesis survives.

• Return Test → price is challenging the trap edge, but the score or close-count requirement is not complete yet.

• Bull Control Return → an upper trap thesis failed and control returned back above the edge.

• Bear Control Return → a lower trap thesis failed and control returned back below the edge.


🔔 Alerts Logic

Alerts trigger when upper or lower trap thesis states appear and when qualified bull or bear control-return events are confirmed.

High-score alerts require the event score to meet the selected alert threshold.

Alerts are attention markers only. They are not trade instructions, entry commands, or outcome guarantees.


🧩 Confluence Logic

The score becomes stronger when the trap thesis probe is clean, price returns through the trap edge, the return holds for the required close count, follow-through expands, volume rises relative to baseline, and the close location supports the control-return side.

When these components align, the trap failure context becomes cleaner. When they do not align, the script stays in watch, return-test, or reset mode.


📊 When to Use

• Markets with visible trap and failed-participation behavior

• False break structures where the first trap thesis may fail

• Breakout or breakdown attempts that get rejected, then reclaim control again

• Range-edge reviews where traders need a second-stage decision layer


⚠️ When NOT to Use

• Extremely low-liquidity symbols

• Very noisy micro timeframes with erratic wicks

• News spikes where structure changes too quickly

• Charts where recent rails are not meaningful planning references


🎛️ Key Inputs

• Planner Side → choose Auto, Bull Return Only, or Bear Return Only.

• Trap Thesis Lookback → controls the rolling reference rails used for trap thesis detection.

• Failure Window Bars → defines how long a trap thesis remains active before reset.

• Control Return Closes → defines how many closes beyond the edge are required for confirmation.

• Minimum Failure Score → controls how selective confirmed Trap Failed labels are.

• Control Return Buffer ATR → controls how much acceptance beyond the edge is required.

• Risk / Target Settings → control planning guide placement.

• Visual Settings → control zones, guides, labels, panel location, theme, and font sizes.


🖥️ Interface & Visual Design

The panel is built for fast review: state first, score second, control shift third, then risk and action.

The trap thesis zone includes centered text so the chart remains readable without extra floating explanations.

Labels are compact, offset away from candles, and controlled by cooldown and maximum-visible settings.


🧪 Practical Usage Workflow

1. Read the panel to identify whether a trap thesis is active or already failed.
2. Check the trap thesis zone and the edge being tested.
3. Review the Failure Score and Control Shift rows.
4. Use the Risk Edge and target guide as planning references.
5. Confirm the event inside broader market context.


🔍 Interpretation Guidelines

Think in terms of control, not prediction.

A trap thesis label means price created a possible trap context. A Trap Failed label means that thesis lost control according to the script rules. A higher score means the failure was cleaner across the model components, not that the next move is guaranteed.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not auto trading

• Not guaranteed signals

• Not a false-break trap detector clone

• Not an inducement scanner

• Not a liquidity grab detector

• Not a support / resistance zone scanner

• Not an order block or fair value gap map


⚠️ Limitations & Transparency

Trap behavior depends on timeframe, liquidity, spread, volatility, and market context.

The script uses a deterministic ruleset. It cannot know news context, hidden order flow, participant intent, or whether a control return will continue.

More aggressive settings may show more events but also more noise. More conservative settings may improve selectivity while reducing frequency.


🧠 Market Context Notes

Trap thesis failure often becomes more meaningful when it aligns with broader structure, volatility expansion, session context, or liquidity behavior.

The script is designed to organize that review, not replace it.


🧾 Use Case Examples

When price probes above a recent upper rail, closes back inside, and later returns above that edge with persistence and follow-through, the planner can mark Bull Control Return if the score is strong enough.

When price probes below a recent lower rail, closes back inside, and later returns below that edge with acceptance, the planner can mark Bear Control Return.


🧱 System Philosophy

AGPro decision tools are built to reduce chart ambiguity by turning raw price events into structured review states.

Trap Failure Planner follows that philosophy by separating the first trap thesis from the later question of whether that thesis actually survives.


🔐 Non-Promise Statement

No indicator can remove uncertainty.

No script can guarantee direction, continuation, reversal, or profit.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions, risk management, position sizing, and interpretation.

This script is for educational and analytical use only and does not provide financial advice.


📚 Educational Note

Use this script to study what happens after a trap thesis forms. The key question is not only whether price created a trap, but whether that trap can continue to defend control.

## Source Code

````pine
// -------------------------------------------------
// Trap Failure Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.10
//
// Trap Failure Planner is a chart-first trap thesis failure planner for price
// action, false break recovery, control return, and execution readiness review.
// It tracks whether a trap thesis loses control, scores the failure from
// 0-100, maps risk and target guides, and turns the next review step into a
// clean planning state without becoming a generic false-break signal printer.
// V1.9 adds a confirmation-anchored proof layer (Follow, Hold, React, Flip
// rates) measuring how often qualified control-return reviews advanced one risk
// unit before reaching the planner risk edge, and removes the redundant review row.
// -------------------------------------------------

//@version=6
indicator("Trap Failure Planner [AGPro Series]",
     shorttitle       = "AG Pro TFP",
     overlay          = true,
     max_boxes_count  = 70,
     max_labels_count = 220,
     max_lines_count  = 90)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBg       = color.rgb(15, 23, 42)
panelBorder   = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)
darkText      = color.rgb(15, 23, 42)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
string ttSide = "Selects which trap-thesis failure direction the planner can evaluate. Auto allows both bull control-return and bear control-return events."
string ttConfirm = "Close Confirmed prints state changes, labels, and alerts only after bar close. Live Updating lets the planner update during the active bar."
string ttLookback = "Lookback used to define the active upper and lower trap-thesis rails. These are rolling planning references, not generic support or resistance zones."
string ttAtr = "ATR length used to normalize trap depth, control-return buffers, risk edges, target guides, and label spacing."
string ttVol = "Volume baseline used in the failure score. If a market has weak or unavailable volume data, this component naturally stays closer to neutral."
string ttWindow = "Maximum number of bars allowed for a trap thesis to fail back through its control edge before the planner resets the active thesis."
string ttHold = "Number of closes required beyond the trap edge before the planner treats control return as confirmed. Higher values make the tool more selective."
string ttSensitivity = "Controls how deep the initial trap thesis probe must be. Conservative requires a cleaner probe, while Aggressive accepts smaller probes."
string ttMinScore = "Minimum 0-100 failure score required before a confirmed trap-failure review event is printed on the chart."
string ttWatchScore = "Score level used for active review states while a trap thesis is being challenged but not fully confirmed."
string ttReclaim = "ATR buffer beyond the trap edge required before the planner treats control return as meaningful."
string ttRisk = "ATR buffer used to place the risk edge on the wrong side of the returned control edge. It is a planning reference, not a stop recommendation."
string ttTarget = "Range multiple used to project the target guide after a qualified control-return event. It is a planning reference only."
string ttZone = "Shows the active trap thesis zone between the control edge and the probe extreme. The zone uses a separate centered badge for contrast-safe readability."
string ttGuides = "Shows risk-edge and target-guide lines after a qualified trap-thesis failure."
string ttRightTags = "Shows right-edge guide tags for the latest qualified trap-failure review. These tags make risk and target references readable in screenshots without changing the engine."
string ttGuideTagMemory = "Controls whether right-edge guide tags are kept only for the latest qualified review or retained for recent historical reviews. Latest Only is the cleaner publication preset."
string ttScoreGuideTag = "Shows an optional right-edge score badge. Disabled by default because score is an event-quality value, not a price level; the panel and event labels already show it cleanly."
string ttRightTagOffset = "Horizontal offset used to place right-edge guide tags beyond the projected guide lines."
string ttRightTagSpacing = "ATR-based vertical spacing used by the right-edge guide tags when the chart is compressed."
string ttZoneOpacity = "Transparency of trap thesis zones. Higher values make zones lighter."
string ttProjection = "Number of bars projected to the right for trap zones, risk edges, and target guides."
string ttLabels = "Shows trap-thesis, trap-failure, and control-return review labels with controlled spacing."
string ttContext = "Adds sparse active-state labels while a trap thesis is being tested. Disabled by default for a cleaner publication preset."
string ttLabelCooldown = "Minimum bars between full event labels. Higher values reduce repeated labels during active conditions."
string ttContextSpacing = "Minimum bars between sparse context labels during active trap-thesis monitoring."
string ttMaxLabels = "Maximum number of chart labels retained. Older labels are removed first to preserve performance."
string ttMaxObjects = "Maximum number of completed trap zones retained on the chart."
string ttOffset = "ATR-based label offset. Larger values keep labels farther from candles."
string ttScoreText = "Adds the 0-100 failure score to confirmed chart labels."
string ttLabelSize = "Controls all chart labels and centered zone badges. Normal is the recommended publication default."
string ttShowPanel = "Shows or hides the AG Pro planning panel. The default is visible for publication-ready chart context."
string ttPanelLoc = "Moves the AG Pro panel to the preferred chart location."
string ttPanelTheme = "Switches the panel between the AGPro dark theme and a clean light theme."
string ttPanelSize = "Controls panel text size. Normal is the recommended publication default."
string ttAlertScore = "Minimum score required for high-quality control-return alerts."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Trap Failure Engine"
string sideMode = input.string("Auto", "Planner Side", options = ["Auto", "Bull Return Only", "Bear Return Only"], group = groupEngine, tooltip = ttSide)
string confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = ttConfirm)
int trapLookback = input.int(34, "Trap Thesis Lookback", minval = 10, maxval = 220, group = groupEngine, tooltip = ttLookback)
int atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupEngine, tooltip = ttAtr)
int volumeLength = input.int(20, "Volume Baseline Length", minval = 5, maxval = 150, group = groupEngine, tooltip = ttVol)
int failureWindowBars = input.int(10, "Failure Window Bars", minval = 2, maxval = 50, group = groupEngine, tooltip = ttWindow)
int controlReturnCloses = input.int(2, "Control Return Closes", minval = 1, maxval = 4, group = groupEngine, tooltip = ttHold)
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Aggressive"], group = groupEngine, tooltip = ttSensitivity)

string groupScore = "Failure Score"
int minFailureScore = input.int(68, "Minimum Failure Score", minval = 40, maxval = 95, group = groupScore, tooltip = ttMinScore)
int watchScore = input.int(54, "Review Score", minval = 25, maxval = 90, group = groupScore, tooltip = ttWatchScore)
float returnBufferAtr = input.float(0.10, "Control Return Buffer ATR", minval = 0.00, maxval = 1.50, step = 0.01, group = groupScore, tooltip = ttReclaim)
float riskBufferAtr = input.float(0.18, "Risk Edge Buffer ATR", minval = 0.00, maxval = 2.50, step = 0.01, group = groupScore, tooltip = ttRisk)
float targetRangeMultiple = input.float(0.85, "Target Guide Range Multiple", minval = 0.20, maxval = 3.50, step = 0.05, group = groupScore, tooltip = ttTarget)

string groupVisual = "Chart Visuals"
bool showTrapZone = input.bool(true, "Show Trap Thesis Zone", group = groupVisual, tooltip = ttZone)
bool showRiskTargetGuides = input.bool(true, "Show Risk / Target Guides", group = groupVisual, tooltip = ttGuides)
bool showRightEdgeTags = input.bool(true, "Show Right Edge Guide Tags", group = groupVisual, tooltip = ttRightTags)
string guideTagMemory = input.string("Latest Only", "Guide Tag Memory", options = ["Latest Only", "Recent Reviews"], group = groupVisual, tooltip = ttGuideTagMemory)
bool showScoreGuideTag = input.bool(false, "Show Score Guide Tag", group = groupVisual, tooltip = ttScoreGuideTag)
int rightTagOffsetBars = input.int(3, "Right Tag Offset Bars", minval = 1, maxval = 24, group = groupVisual, tooltip = ttRightTagOffset)
float rightTagSpacingAtr = input.float(0.34, "Right Tag Spacing ATR", minval = 0.10, maxval = 2.00, step = 0.01, group = groupVisual, tooltip = ttRightTagSpacing)
int zoneTransparency = input.int(90, "Zone Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = ttZoneOpacity)
int projectionBars = input.int(42, "Forward Projection Bars", minval = 8, maxval = 140, group = groupVisual, tooltip = ttProjection)

string groupLabels = "Labels"
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
bool showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContext)
int labelCooldownBars = input.int(28, "Label Cooldown Bars", minval = 2, maxval = 120, group = groupLabels, tooltip = ttLabelCooldown)
int contextSpacingBars = input.int(64, "Context Label Spacing", minval = 6, maxval = 180, group = groupLabels, tooltip = ttContextSpacing)
int maxVisibleLabels = input.int(5, "Max Visible Labels", minval = 4, maxval = 80, group = groupLabels, tooltip = ttMaxLabels)
int maxVisibleObjects = input.int(2, "Max Visible Trap Zones", minval = 2, maxval = 30, group = groupLabels, tooltip = ttMaxObjects)
float labelOffsetAtr = input.float(1.00, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttOffset)
bool showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttScoreText)
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLoc)
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelSize)

string groupAlerts = "Alerts"
int alertScore = input.int(74, "Minimum Alert Score", minval = 40, maxval = 95, group = groupAlerts, tooltip = ttAlertScore)

string groupProof = "Proof"
bool showProof = input.bool(true, "Show Proof Layer", group = groupProof, tooltip = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across qualified control-return reviews on the current symbol and timeframe. Follow means price advanced one risk unit in the return direction before reaching the planner risk edge. These are historical outcome rates, not predictions.")
int proofHorizonBars = input.int(40, "Proof Horizon Bars", minval = 4, maxval = 300, group = groupProof, tooltip = "Maximum number of bars each qualified review is tracked for the proof measurement before it resolves at its current outcome.")
int reactBars = input.int(3, "Reaction Window Bars", minval = 1, maxval = 40, group = groupProof, tooltip = "Number of bars after a qualified review used to detect an immediate favorable follow-through reaction.")
float reactProgressPct = input.float(40.0, "Reaction Progress %", minval = 5.0, maxval = 90.0, step = 1.0, group = groupProof, tooltip = "Minimum favorable progress toward the risk-unit target, within the reaction window, required to count as an early React.")

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
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_panel_bg(string theme) =>
    theme == "Clean Light" ? color.rgb(241, 245, 249) : panelBg

f_panel_border(string theme) =>
    theme == "Clean Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string theme, int row) =>
    bool evenRow = row % 2 == 0
    if theme == "Clean Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)
    else
        evenRow ? color.rgb(20, 31, 52) : panelBg

f_fmt_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_score_grade(float score) =>
    string result = "D"
    if score >= 86
        result := "A+"
    else if score >= 78
        result := "A"
    else if score >= 68
        result := "B"
    else if score >= 55
        result := "C"
    result

f_score_color(float score) =>
    color result = panelLabelCol
    if score >= 78
        result := bullColor
    else if score >= minFailureScore
        result := accentColor
    else if score >= watchScore
        result := neutralColor
    else
        result := bearColor
    result

f_rate_pct(value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(value) =>
    value >= 55.0 ? bullColor : value >= 40.0 ? neutralColor : bearColor

f_flip_color(value) =>
    value <= 30.0 ? bullColor : value <= 55.0 ? neutralColor : bearColor

f_state_color(string stateText, string theme) =>
    switch stateText
        "Review Bull Return" => bullColor
        "Review Bear Return" => bearColor
        "Upper Trap Thesis" => bearColor
        "Lower Trap Thesis" => bullColor
        "Return Test" => accentColor
        "Expired" => neutralColor
        => f_panel_value(theme)

f_zone_badge_text(int side, float score, bool failed) =>
    failed ? "FAIL " + str.tostring(math.round(score)) : side == 1 ? "UPPER TRAP" : "LOWER TRAP"

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_right)

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        label oldLabel = array.shift(labels)
        label.delete(oldLabel)

f_trim_boxes(array<box> boxes, int maxCount) =>
    while array.size(boxes) > maxCount
        box oldBox = array.shift(boxes)
        box.delete(oldBox)

f_trim_lines(array<line> lines, int maxCount) =>
    while array.size(lines) > maxCount
        line oldLine = array.shift(lines)
        line.delete(oldLine)

f_clear_labels(array<label> labels) =>
    while array.size(labels) > 0
        label oldLabel = array.shift(labels)
        label.delete(oldLabel)

f_clear_lines(array<line> lines) =>
    while array.size(lines) > 0
        line oldLine = array.shift(lines)
        line.delete(oldLine)

// -------------------------------------------------
// Core Measurements
// -------------------------------------------------
bool confirmedBar = confirmationMode == "Live Updating" ? true : barstate.isconfirmed
float atrRaw = ta.atr(atrLength)
float atr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
float labelOffset = atr * labelOffsetAtr

float upperRailRaw = ta.highest(high[1], trapLookback)
float lowerRailRaw = ta.lowest(low[1], trapLookback)
bool validRails = not na(upperRailRaw) and not na(lowerRailRaw) and upperRailRaw > lowerRailRaw
float upperRail = validRails ? upperRailRaw : high
float lowerRail = validRails ? lowerRailRaw : low
float railRange = math.max(upperRail - lowerRail, syminfo.mintick)
float rangeMid = (upperRail + lowerRail) * 0.5

float volumeNow = nz(volume, 0.0)
float volumeBase = nz(ta.sma(volume, volumeLength), volumeNow)
float rvol = volumeBase > 0.0 ? volumeNow / volumeBase : 1.0

float minProbeAtr = sensitivity == "Conservative" ? 0.34 : sensitivity == "Aggressive" ? 0.16 : 0.24
float idealProbeAtr = sensitivity == "Conservative" ? 0.75 : sensitivity == "Aggressive" ? 0.50 : 0.62
float largeProbeAtr = sensitivity == "Conservative" ? 1.65 : sensitivity == "Aggressive" ? 1.25 : 1.45

float upProbeAtr = validRails ? math.max((high - upperRail) / atr, 0.0) : 0.0
float downProbeAtr = validRails ? math.max((lowerRail - low) / atr, 0.0) : 0.0
bool upperTrapThesis = validRails and high > upperRail + atr * minProbeAtr and close < upperRail and close > rangeMid
bool lowerTrapThesis = validRails and low < lowerRail - atr * minProbeAtr and close > lowerRail and close < rangeMid
bool allowBullReturn = sideMode == "Auto" or sideMode == "Bull Return Only"
bool allowBearReturn = sideMode == "Auto" or sideMode == "Bear Return Only"

int candidateSide = 0
if upperTrapThesis and lowerTrapThesis
    candidateSide := upProbeAtr >= downProbeAtr ? 1 : -1
else if upperTrapThesis
    candidateSide := 1
else if lowerTrapThesis
    candidateSide := -1

bool candidateAllowed = (candidateSide == 1 and allowBullReturn) or (candidateSide == -1 and allowBearReturn)

// -------------------------------------------------
// State Storage
// -------------------------------------------------
var bool trapActive = false
var int activeTrapSide = 0
var int activeStartBar = na
var int activeReturnCloses = 0
var float activeEdge = na
var float activeZoneTop = na
var float activeZoneBottom = na
var float activeRange = na
var float activeProbe = na
var box activeTrapBox = na
var label activeTrapBadge = na

var float lastFailureScore = na
var string lastTrapState = "Scanning"
var string lastControlShift = "None"
var float lastRiskEdge = na
var float lastTargetGuide = na
var string lastAction = "Scan Setup"
var int lastEventDir = 0
var int lastFullLabelBar = na
var int lastContextLabelBar = na

var array<label> eventLabels = array.new_label()
var array<box> completedBoxes = array.new_box()
var array<label> completedBadges = array.new_label()
var array<line> guideLines = array.new_line()
var array<label> guideTags = array.new_label()

// -------------------------------------------------
// Active Trap Lifecycle
// -------------------------------------------------
int barsActive = trapActive and not na(activeStartBar) ? bar_index - activeStartBar : 0
bool trapExpired = trapActive and barsActive > failureWindowBars
if trapExpired
    if not na(activeTrapBox)
        box.delete(activeTrapBox)
    if not na(activeTrapBadge)
        label.delete(activeTrapBadge)
    trapActive := false
    activeTrapSide := 0
    activeStartBar := na
    activeReturnCloses := 0
    activeEdge := na
    activeZoneTop := na
    activeZoneBottom := na
    activeRange := na
    activeProbe := na
    activeTrapBox := na
    activeTrapBadge := na
    lastTrapState := "Expired"
    lastControlShift := "None"
    lastFailureScore := na
    lastRiskEdge := na
    lastTargetGuide := na
    lastAction := "Scan Setup"

bool newTrap = confirmedBar and not trapActive and candidateAllowed and candidateSide != 0
if newTrap
    trapActive := true
    activeTrapSide := candidateSide
    activeStartBar := bar_index
    activeReturnCloses := 0
    activeEdge := candidateSide == 1 ? upperRail : lowerRail
    activeZoneTop := candidateSide == 1 ? high : lowerRail
    activeZoneBottom := candidateSide == 1 ? upperRail : low
    activeRange := railRange
    activeProbe := candidateSide == 1 ? upProbeAtr : downProbeAtr
    lastTrapState := candidateSide == 1 ? "Upper Trap Thesis" : "Lower Trap Thesis"
    lastControlShift := "Testing"
    lastRiskEdge := activeEdge
    lastTargetGuide := na
    lastAction := "Watch Edge"
    color trapColor = candidateSide == 1 ? bearColor : bullColor
    if showTrapZone
        activeTrapBox := box.new(left = bar_index, top = activeZoneTop, right = bar_index + projectionBars, bottom = activeZoneBottom, xloc = xloc.bar_index, bgcolor = color.new(trapColor, zoneTransparency), border_color = color.new(trapColor, 25), border_width = 1, text = "")
        activeTrapBadge := label.new(int(math.round((bar_index + bar_index + projectionBars) * 0.5)), (activeZoneTop + activeZoneBottom) * 0.5, f_zone_badge_text(candidateSide, 0.0, false), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(trapColor, 0), textcolor = headerText, size = f_text_size(labelFontSize), textalign = text.align_center)
    bool canPrintTrapLabel = showEventLabels and (na(lastFullLabelBar) or bar_index - lastFullLabelBar >= labelCooldownBars)
    if canPrintTrapLabel
        float labelY = candidateSide == 1 ? high + labelOffset : low - labelOffset
        string trapText = candidateSide == 1 ? "UPPER TRAP" : "LOWER TRAP"
        label trapLabel = label.new(bar_index, labelY, trapText, xloc = xloc.bar_index, yloc = yloc.price, style = candidateSide == 1 ? label.style_label_down : label.style_label_up, color = color.new(trapColor, 0), textcolor = headerText, size = f_text_size(labelFontSize), tooltip = "A trap thesis is active. The planner watches whether that thesis keeps control or fails through its edge.", textalign = text.align_center)
        array.push(eventLabels, trapLabel)
        f_trim_labels(eventLabels, maxVisibleLabels)
        lastFullLabelBar := bar_index

if trapActive and not na(activeTrapBox)
    int rightEdge = bar_index + projectionBars
    color trapColor = activeTrapSide == 1 ? bearColor : bullColor
    box.set_right(activeTrapBox, rightEdge)
    if not na(activeTrapBadge)
        label.set_xy(activeTrapBadge, int(math.round((activeStartBar + rightEdge) * 0.5)), (activeZoneTop + activeZoneBottom) * 0.5)
        label.set_text(activeTrapBadge, f_zone_badge_text(activeTrapSide, 0.0, false))
        label.set_color(activeTrapBadge, color.new(trapColor, 0))
        label.set_textcolor(activeTrapBadge, headerText)
        label.set_size(activeTrapBadge, f_text_size(labelFontSize))

// -------------------------------------------------
// Failure Scoring
// -------------------------------------------------
int failureDir = activeTrapSide == 1 ? 1 : activeTrapSide == -1 ? -1 : 0
bool proofArmRequested = false
int proofArmDir = 0
float proofArmEntry = na
float proofArmStop = na
float returnBuffer = atr * returnBufferAtr
bool returnedThroughEdge = trapActive and ((failureDir == 1 and close > activeEdge + returnBuffer) or (failureDir == -1 and close < activeEdge - returnBuffer))
if trapActive and confirmedBar
    activeReturnCloses := returnedThroughEdge ? activeReturnCloses + 1 : 0

float zoneHeight = trapActive ? math.max(activeZoneTop - activeZoneBottom, syminfo.mintick) : syminfo.mintick
float moveThroughEdge = trapActive ? (failureDir == 1 ? close - activeEdge : activeEdge - close) : 0.0
float closeRecoveryScore = trapActive ? f_norm_high_good(moveThroughEdge / zoneHeight, 0.05, 1.10) : 0.0
float followThroughScore = trapActive ? f_norm_high_good(moveThroughEdge / atr, 0.05, 0.80) : 0.0
float falseBreakScore = trapActive ? f_peak_score(activeProbe, minProbeAtr, idealProbeAtr, largeProbeAtr) : 0.0
float volumeSpikeScore = f_norm_high_good(rvol, 0.80, 1.75)
float barRange = math.max(high - low, syminfo.mintick)
float barCloseLocation = f_clamp((close - low) / barRange, 0.0, 1.0)
float closeLocationScore = failureDir == 1 ? barCloseLocation * 100.0 : (1.0 - barCloseLocation) * 100.0
float persistenceScore = trapActive ? f_norm_high_good(activeReturnCloses * 1.0, 0.0, math.max(controlReturnCloses * 1.0, 1.0)) : 0.0
float levelAcceptanceScore = returnedThroughEdge ? f_clamp(closeLocationScore * 0.45 + persistenceScore * 0.35 + followThroughScore * 0.20, 0.0, 100.0) : 0.0
float failureScore = trapActive ? f_clamp(falseBreakScore * 0.18 + closeRecoveryScore * 0.22 + followThroughScore * 0.18 + volumeSpikeScore * 0.14 + levelAcceptanceScore * 0.18 + persistenceScore * 0.10, 0.0, 100.0) : 0.0
bool qualifiedFailure = confirmedBar and returnedThroughEdge and activeReturnCloses >= controlReturnCloses and failureScore >= minFailureScore
bool reviewFailure = trapActive and returnedThroughEdge and failureScore >= watchScore and not qualifiedFailure

if trapActive and showContextLabels and (returnedThroughEdge or reviewFailure) and not qualifiedFailure and (na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars)
    string contextText = returnedThroughEdge ? "RETURN\nTEST" : "TESTING"
    color contextColor = returnedThroughEdge ? accentColor : neutralColor
    float contextY = failureDir == 1 ? low - labelOffset : high + labelOffset
    label contextLabel = label.new(bar_index, contextY, contextText, xloc = xloc.bar_index, yloc = yloc.price, style = failureDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(contextColor, 0), textcolor = contextColor == neutralColor ? darkText : headerText, size = f_text_size(labelFontSize), tooltip = "Active trap-thesis monitoring context. This is a planning state, not a trade instruction.", textalign = text.align_center)
    array.push(eventLabels, contextLabel)
    f_trim_labels(eventLabels, maxVisibleLabels)
    lastContextLabelBar := bar_index

bool bullReturnEvent = qualifiedFailure and failureDir == 1
bool bearReturnEvent = qualifiedFailure and failureDir == -1

if qualifiedFailure
    color shiftColor = failureDir == 1 ? bullColor : bearColor
    string shiftTextBase = failureDir == 1 ? "Review Bull Return" : "Review Bear Return"
    string shiftText = showLabelScore ? "REVIEW\n" + str.tostring(math.round(failureScore)) : "REVIEW"
    float riskEdge = failureDir == 1 ? activeEdge - atr * riskBufferAtr : activeEdge + atr * riskBufferAtr
    proofArmRequested := true
    proofArmDir := failureDir
    proofArmEntry := close
    proofArmStop := riskEdge
    float guideRange = math.max(activeRange, zoneHeight)
    float targetGuide = failureDir == 1 ? close + guideRange * targetRangeMultiple : close - guideRange * targetRangeMultiple
    float labelY = failureDir == 1 ? low - labelOffset : high + labelOffset
    label shiftLabel = label.new(bar_index, labelY, shiftText, xloc = xloc.bar_index, yloc = yloc.price, style = failureDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(shiftColor, 0), textcolor = headerText, size = f_text_size(labelFontSize), tooltip = "Qualified trap-thesis failure with control-return context. Risk and target guides are planning references, not trade instructions.", textalign = text.align_center)
    array.push(eventLabels, shiftLabel)
    f_trim_labels(eventLabels, maxVisibleLabels)
    if not na(activeTrapBox)
        box.set_right(activeTrapBox, bar_index + projectionBars)
        box.set_bgcolor(activeTrapBox, color.new(shiftColor, zoneTransparency))
        box.set_border_color(activeTrapBox, color.new(shiftColor, 18))
        array.push(completedBoxes, activeTrapBox)
        f_trim_boxes(completedBoxes, maxVisibleObjects)
    if not na(activeTrapBadge)
        label.set_xy(activeTrapBadge, int(math.round((activeStartBar + bar_index + projectionBars) * 0.5)), (activeZoneTop + activeZoneBottom) * 0.5)
        label.set_text(activeTrapBadge, f_zone_badge_text(failureDir, failureScore, true))
        label.set_color(activeTrapBadge, color.new(shiftColor, 0))
        label.set_textcolor(activeTrapBadge, headerText)
        label.set_size(activeTrapBadge, f_text_size(labelFontSize))
        array.push(completedBadges, activeTrapBadge)
        f_trim_labels(completedBadges, maxVisibleObjects)
    if showRiskTargetGuides
        int guideRightX = bar_index + projectionBars
        int tagX = guideRightX + rightTagOffsetBars
        int lineRightX = showRightEdgeTags ? tagX : guideRightX
        if showRightEdgeTags and guideTagMemory == "Latest Only"
            f_clear_lines(guideLines)
        line riskLine = line.new(bar_index, riskEdge, lineRightX, riskEdge, xloc = xloc.bar_index, extend = extend.none, color = color.new(bearColor, 10), style = line.style_dashed, width = 1)
        line targetLine = line.new(bar_index, targetGuide, lineRightX, targetGuide, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 5), style = line.style_dotted, width = 1)
        array.push(guideLines, riskLine)
        array.push(guideLines, targetLine)
        f_trim_lines(guideLines, maxVisibleObjects * 2)
        if showRightEdgeTags
            if guideTagMemory == "Latest Only"
                f_clear_labels(guideTags)
            float tagSpacing = atr * rightTagSpacingAtr
            float scoreY = (riskEdge + targetGuide) * 0.5
            float riskY = failureDir == 1 ? riskEdge - tagSpacing * 0.25 : riskEdge + tagSpacing * 0.25
            float targetY = failureDir == 1 ? targetGuide + tagSpacing * 0.25 : targetGuide - tagSpacing * 0.25
            label riskTag = label.new(tagX, riskY, "RISK " + f_fmt_price(riskEdge), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bearColor, 0), textcolor = headerText, size = f_text_size(labelFontSize), tooltip = "Risk-edge planning reference. This is not a stop recommendation.", textalign = text.align_left)
            label targetTag = label.new(tagX, targetY, "TARGET " + f_fmt_price(targetGuide), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 0), textcolor = headerText, size = f_text_size(labelFontSize), tooltip = "Target-guide planning reference. This is not a profit guarantee.", textalign = text.align_left)
            array.push(guideTags, riskTag)
            array.push(guideTags, targetTag)
            if showScoreGuideTag
                label scoreTag = label.new(tagX, scoreY, "SCORE " + str.tostring(math.round(failureScore)), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(shiftColor, 0), textcolor = headerText, size = f_text_size(labelFontSize), tooltip = "Qualified trap-failure score for review prioritization. This is an event-quality badge, not a price-level tag.", textalign = text.align_center)
                array.push(guideTags, scoreTag)
            f_trim_labels(guideTags, maxVisibleObjects * 3)
    lastFailureScore := failureScore
    lastTrapState := shiftTextBase
    lastControlShift := failureDir == 1 ? "Bull Returned" : "Bear Returned"
    lastRiskEdge := riskEdge
    lastTargetGuide := targetGuide
    lastAction := failureScore >= 78 ? "Review Retest" : "Validate Return"
    lastEventDir := failureDir
    lastFullLabelBar := bar_index
    trapActive := false
    activeTrapSide := 0
    activeStartBar := na
    activeReturnCloses := 0
    activeEdge := na
    activeZoneTop := na
    activeZoneBottom := na
    activeRange := na
    activeProbe := na
    activeTrapBox := na
    activeTrapBadge := na

if trapActive and reviewFailure
    lastTrapState := "Return Test"
    lastControlShift := failureDir == 1 ? "Bull Testing" : "Bear Testing"
    lastFailureScore := failureScore
    lastRiskEdge := activeEdge
    lastAction := "Wait Close"

// -------------------------------------------------
// Confirmation-anchored proof (qualified reviews: Follow = one risk unit in the return direction before the risk edge, 1R-capped)
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

int proofWarmup = trapLookback + atrLength + 5
if barstate.isconfirmed and bar_index > proofWarmup
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
        if naturalResolve or proofArmRequested
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
    if proofArmRequested and not pEvalActive and proofArmDir != 0 and not na(proofArmStop)
        float pRisk = math.max(math.abs(proofArmEntry - proofArmStop), syminfo.mintick)
        pEvalActive := true
        pEvalDir := proofArmDir
        pEvalEntry := proofArmEntry
        pEvalStop := proofArmStop
        pEvalTarget := proofArmEntry + proofArmDir * pRisk
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false
        pFlipped := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0
string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) : "building"

// -------------------------------------------------
// Data Window
// -------------------------------------------------
plot(failureScore, title = "Trap Failure Score", color = f_score_color(failureScore), display = display.data_window)
plot(falseBreakScore, title = "Trap Probe Quality", color = neutralColor, display = display.data_window)
plot(closeRecoveryScore, title = "Control Return Quality", color = accentColor, display = display.data_window)
plot(followThroughScore, title = "Follow-Through Quality", color = bullColor, display = display.data_window)
plot(rvol, title = "Relative Volume", color = panelValueCol, display = display.data_window)

plot(followRate, "TFP Follow Rate", display = display.none)
plot(holdRate, "TFP Hold Rate", display = display.none)
plot(reactRate, "TFP React Rate", display = display.none)
plot(flipRate, "TFP Flip Rate", display = display.none)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(newTrap and candidateSide == 1, "Upper Trap Thesis", "Trap Failure Planner detected an upper trap thesis watch state. This is an attention marker, not a trade instruction.")
alertcondition(newTrap and candidateSide == -1, "Lower Trap Thesis", "Trap Failure Planner detected a lower trap thesis watch state. This is an attention marker, not a trade instruction.")
alertcondition(bullReturnEvent, "Review Bull Return", "Trap Failure Planner marked bullish control-return context after a failed trap thesis. This is an attention marker, not a trade instruction.")
alertcondition(bearReturnEvent, "Review Bear Return", "Trap Failure Planner marked bearish control-return context after a failed trap thesis. This is an attention marker, not a trade instruction.")
alertcondition(bullReturnEvent and failureScore >= alertScore, "High Score Bull Review", "Trap Failure Planner marked high-score bullish control-return context. This is an attention marker, not a trade instruction.")
alertcondition(bearReturnEvent and failureScore >= alertScore, "High Score Bear Review", "Trap Failure Planner marked high-score bearish control-return context. This is an attention marker, not a trade instruction.")

// -------------------------------------------------
// Panel
// -------------------------------------------------
string panelState = trapActive ? (activeTrapSide == 1 ? "Upper Trap Thesis" : "Lower Trap Thesis") : lastTrapState
float panelScoreValue = trapActive ? failureScore : lastFailureScore
string panelScore = na(panelScoreValue) ? "-" : str.tostring(math.round(panelScoreValue)) + " / " + f_score_grade(panelScoreValue)
string panelControl = trapActive ? (activeTrapSide == 1 ? "Bull Return Watch" : "Bear Return Watch") : lastControlShift
float panelRisk = trapActive ? activeEdge : lastRiskEdge
string panelAction = panelState == "Expired" ? "Scan Setup" : trapActive ? (reviewFailure ? "Wait Close" : "Watch Edge") : lastAction
color panelStateColor = f_state_color(panelState, panelTheme)
color panelScoreColor = na(panelScoreValue) ? f_panel_value(panelTheme) : f_score_color(panelScoreValue)
color panelControlColor = str.contains(panelControl, "Bull") ? bullColor : str.contains(panelControl, "Bear") ? bearColor : f_panel_value(panelTheme)
color panelRiskColor = na(panelRisk) ? f_panel_value(panelTheme) : bearColor

var table statusPanel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""
var string lastPanelFont = ""
var bool lastPanelVisible = false
var bool lastProofMode = false
int panelRowCount = showProof ? 11 : 6

bool panelNeedsReset = na(statusPanel) or panelLocation != lastPanelLocation or panelTheme != lastPanelTheme or panelFontSize != lastPanelFont or showPanel != lastPanelVisible or showProof != lastProofMode
if panelNeedsReset
    if not na(statusPanel)
        table.delete(statusPanel)
    if showPanel
        statusPanel := table.new(f_panel_position(panelLocation), 2, panelRowCount, bgcolor = f_panel_bg(panelTheme), frame_color = f_panel_border(panelTheme), frame_width = 1, border_color = f_panel_border(panelTheme), border_width = 1)
        table.cell(statusPanel, 0, 0, "AG Pro Trap Failure Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        table.cell(statusPanel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize))
        table.merge_cells(statusPanel, 0, 0, 1, 0)
    else
        statusPanel := na
    lastPanelLocation := panelLocation
    lastPanelTheme := panelTheme
    lastPanelFont := panelFontSize
    lastPanelVisible := showPanel
    lastProofMode := showProof

if barstate.islast and showPanel and not na(statusPanel)
    table.clear(statusPanel, 0, 0, 1, panelRowCount - 1)
    table.merge_cells(statusPanel, 0, 0, 1, 0)
    table.cell(statusPanel, 0, 0, "AG Pro Trap Failure Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
    f_panel_row(statusPanel, 1, "Workflow", panelAction, f_panel_value(panelTheme), panelTheme, panelFontSize)
    f_panel_row(statusPanel, 2, "Trap Context", panelState, panelStateColor, panelTheme, panelFontSize)
    f_panel_row(statusPanel, 3, "Failure Score", panelScore, panelScoreColor, panelTheme, panelFontSize)
    f_panel_row(statusPanel, 4, "Control Shift", panelControl, panelControlColor, panelTheme, panelFontSize)
    f_panel_row(statusPanel, 5, "Risk Edge", f_fmt_price(panelRisk), panelRiskColor, panelTheme, panelFontSize)
    if showProof
        color proofHeadBg = f_row_bg(panelTheme, 6)
        table.cell(statusPanel, 0, 6, "Proof @ Confirm", text_color = accentColor, bgcolor = proofHeadBg, text_size = f_text_size(panelFontSize), text_halign = text.align_left)
        table.cell(statusPanel, 1, 6, proofSampleText, text_color = f_panel_label(panelTheme), bgcolor = proofHeadBg, text_size = f_text_size(panelFontSize), text_halign = text.align_right)
        f_panel_row(statusPanel, 7, "Follow Rate", proofTotal > 0 ? f_rate_pct(followRate) : "-", proofTotal > 0 ? f_rate_color(followRate) : f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_panel_row(statusPanel, 8, "Hold Rate", proofTotal > 0 ? f_rate_pct(holdRate) : "-", proofTotal > 0 ? f_rate_color(holdRate) : f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_panel_row(statusPanel, 9, "React Rate", proofTotal > 0 ? f_rate_pct(reactRate) : "-", proofTotal > 0 ? f_rate_color(reactRate) : f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_panel_row(statusPanel, 10, "Flip Rate", proofTotal > 0 ? f_rate_pct(flipRate) : "-", proofTotal > 0 ? f_flip_color(flipRate) : f_panel_value(panelTheme), panelTheme, panelFontSize)
````
