# Reversal Confirmation Planner [AGPro Series]

- url: https://www.tradingview.com/script/TXJIhe5N-Reversal-Confirmation-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;a3d7985bf1c14695b48061c193e3cda9
- version: 4.0

## Description

Reversal Confirmation Planner [AGPro Series]


🧠 Core Idea

Is a reversal actually confirming, or is it still only an early reaction?


📌 Overview / What it does

Reversal Confirmation Planner [AGPro Series] is a chart-first planning tool built to separate early reversal reactions from structured confirmation context.

The script detects sweep or wick-rejection reactions around recent swing references, then evaluates whether the reaction develops into a cleaner confirmation plan. It maps a confirmation pocket, invalidation edge, target-room band, compact event labels, alerts, and a clean AG Pro decision panel.

It does not predict reversals, automate entries, or scan every classical reversal pattern. The goal is to help traders organize the confirmation phase: reaction quality, confirmation close, momentum turn, volume support, room, invalidation, and next action.


🎯 Purpose & Design Philosophy

This script was built for traders who do not want to treat every wick, sweep, or counter-move as a valid reversal.

Many reversal tools mark the first reaction. This planner waits for structure. It asks whether price has moved from reaction into confirmation, whether momentum is turning, whether volume supports the shift, and whether the active plan has enough room before the next projected guide.

The design supports a decision-making workflow. It does not ask the user to chase every signal. It helps the user decide whether the reversal context is still early, building, confirming, confirmed, failed, expired, or already testing its room.


⚡ Why This Script Is Different

Most reversal tools focus on detecting a pattern, labeling a wick, or marking every possible counter-trend reaction.

This script does NOT behave like a broad reversal-pattern scanner, double-top/double-bottom detector, head-and-shoulders module, 1-2-3 map, wedge detector, Turtle Soup map, liquidity sweep tool, or generic support/resistance zone script.

Instead, it works as a confirmation planner. The core workflow is reaction → confirmation pocket → invalidation edge → target-room context → next-action state. This keeps the public concept narrow, useful, and clearly separate from other AGPro reversal tools.


⚙️ Methodology

1. Context Detection
The script watches for bullish or bearish reversal reactions using sweep behavior, wick rejection, candle close location, and prior directional context.

2. Reference Mapping
Once a reaction qualifies, the planner creates a confirmation line, confirmation pocket, invalidation edge, and target-room guide.

3. Reaction Evaluation
The model scores sweep or rejection quality, confirmation progress, momentum turn, volume support, and available room.

4. Visual Output
The chart shows the active confirmation pocket, centered target-room band, risk/target guide lines, compact labels, alert conditions, and an AG Pro panel with the current decision state.


🗺️ How to Read the Chart

Confirmation Pocket = the area between the reaction reference and the confirmation close line.

Invalidation Edge = the level beyond the reaction extreme where the active confirmation plan is considered failed by the script rules.

Target-Room Band = a projected planning zone that shows whether the reversal has enough forward room relative to the active risk distance.

Labels = compact state markers such as REACTION, CONFIRMING, CONFIRMED, FAILED, EXPIRED, ROOM TESTED, or PLAN.

Colors = teal supports bullish reversal planning, pink supports bearish reversal planning, amber marks developing context, indigo marks target-room context, and red marks invalidation or failed confirmation.

Panel = summarizes Reversal Stage, Confirmation Score, Invalidation, Room, and Action.


🚦 Signals & States

• REACTION → an early sweep or rejection is active, but confirmation is not complete.

• BUILDING → the context is improving, but the confirmation close is not fully qualified.

• CONFIRMING → price is testing or closing through the confirmation line with sufficient structure to review.

• CONFIRMED → the confirmation score and close behavior meet the script threshold.

• ROOM TESTED → the projected target-room guide has been reached after confirmation.

• FAILED → the active plan violated its invalidation edge.

• EXPIRED → the reaction did not confirm within the selected confirmation window.


🔔 Alerts Logic

The script includes alerts for bullish reaction, bearish reaction, bullish confirmation, bearish confirmation, failed confirmation, and high-quality confirmation.

Alerts trigger when the internal rule conditions are met. They are attention markers for chart review, not trade instructions, automated entries, or guaranteed reversal signals.


🧩 Confluence Logic

The strongest confirmation context appears when multiple layers align:

• A clear sweep or rejection reaction forms.
• Price progresses through the confirmation pocket.
• Momentum begins to turn in the reaction direction.
• Volume support is not weak.
• The target-room band offers enough room relative to invalidation distance.

When these layers align, the confirmation score becomes stronger. When one or more layers are weak, the state usually remains reaction, building, expired, or failed.


📊 When to Use

• After visible sweep or rejection behavior.
• During possible reversal transitions after directional extension.
• Around swing references where confirmation matters more than the first wick.
• 4H swing-review charts, where the default label spacing and confirmation pockets usually have the cleanest visual balance.
• Daily charts when the user wants fewer but more selective reversal confirmation states.
• In markets where traders want to compare reaction quality, invalidation, and room before acting.
• For discretionary review of crypto, forex, indices, equities, and commodities on liquid charts.


⚠️ When NOT to Use

• Extremely low-liquidity symbols with unreliable wicks or volume.
• Very noisy micro-timeframes where reaction candles are unstable.
• News spikes or extreme volatility events where confirmation levels can be crossed erratically.
• Charts where the user expects a complete reversal-pattern scanner.
• Situations where the user wants automated trade execution.


🎛️ Key Inputs

• Confirmation Mode → controls whether labels and alerts wait for bar close or update live.

• Swing Reference Length → defines the recent swing references used for sweep-based reactions.

• Sensitivity → adjusts how selective the reaction model is.

• Confirmation Window Bars → limits how long a reaction can wait for confirmation.

• Minimum Reaction Score → controls the quality required before tracking a candidate.

• CONFIRMED Threshold → controls the minimum 0-100 score required for confirmed state.

• Preferred Room / Risk → adjusts how much forward room is preferred relative to invalidation distance.

• Visual settings → control pockets, bands, guide lines, labels, panel position, panel theme, and font sizes.


🖥️ Interface & Visual Design

The interface is built around a premium chart-first workflow.

The confirmation pocket and target-room band are concept-native visuals, not generic support/resistance zones. Their labels are centered inside the boxes for cleaner chart reading.

The default visual preset is tuned for 4H-style swing review: enough labels to keep the chart informative, but enough spacing to avoid a crowded reversal scanner look.

The AG Pro panel uses a compact structure with one merged blue title row and five decision rows. It is designed to show only the current planning context without turning the chart into a dashboard-heavy script.


🧪 Practical Usage Workflow

1. Read the panel state.
2. Check whether the chart is showing REACTION, BUILDING, CONFIRMING, CONFIRMED, FAILED, or EXPIRED.
3. Review the confirmation pocket and invalidation edge.
4. Compare target-room context against the room/risk readout.
5. Use alerts as review prompts, not as trade instructions.


🔍 Interpretation Guidelines

Treat the first reaction as incomplete information.

A higher score means the reaction has developed more confirmation structure according to the script rules. It does not mean the reversal must continue.

A failed or expired state is also useful information. It tells the user that the reaction did not confirm cleanly under the selected rules.


🚫 What This Script Is NOT

• Not a prediction engine.
• Not financial advice.
• Not auto trading.
• Not guaranteed signals.
• Not a broad reversal-pattern scanner.
• Not a full liquidity sweep system.
• Not a generic support/resistance zone tool.


⚠️ Limitations & Transparency

All outputs are rule-based and depend on the selected inputs, timeframe, and symbol behavior.

Swing references confirm with natural delay. Wick structure can be noisy on low-liquidity symbols. Volume quality varies across markets. Fast volatility can cause reactions to confirm and fail quickly.

The confirmation score is an internal comparison model. It is useful for reading this script's framework, but it is not an objective probability model.


🧠 Market Context Notes

Reversal confirmation is strongest when price reacts from a meaningful extension, then follows through with cleaner close behavior and improving participation.

The script is intentionally focused on the confirmation phase. It does not attempt to map every higher-timeframe structure, order block, fair value gap, harmonic pattern, or reversal formation.


🧾 Use Case Examples

When price sweeps below a recent swing low, closes back above it, then starts progressing through the confirmation pocket, the planner may shift from REACTION to BUILDING or CONFIRMING.

When price confirms but the room/risk readout is weak, the user can see that the reversal may be structurally less attractive inside this framework.

When price violates the invalidation edge before confirmation, the planner marks the context as FAILED instead of leaving the reaction visually ambiguous.


🧱 System Philosophy

The AGPro approach is to build decision engines, not decorative signal boards.

This script focuses on one clear question: did the reversal reaction earn confirmation, or is it still only a reaction?


🔐 Non-Promise Statement

No script can confirm future price movement with certainty.

This tool provides structured context, not guarantees.


📉 Risk Disclosure

Trading involves risk.

This script is for educational, analytical, and chart-review purposes only. It does not provide financial advice, investment advice, or guaranteed trading outcomes.

Users remain responsible for their own decisions, risk management, position sizing, and broader market analysis.


📚 Educational Note

Use the planner to study how reactions mature, fail, expire, or confirm under consistent rules. The value is in disciplined interpretation, not in treating any single label as a complete trading system.

## Source Code

````pine
// -------------------------------------------------
// Reversal Confirmation Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.4
//
// Reversal Confirmation Planner is a chart-first reversal planning engine that
// separates early reactions from confirmed, delayed, or invalidated reversal
// context. It evaluates sweep or rejection quality, confirmation close,
// momentum turn, volume support, invalidation distance, and forward room to
// produce a 0-100 confirmation score with a clear next-action state and a
// stop-aware Room Hit Rate built from the script's own target and invalidation.
// -------------------------------------------------

//@version=6
indicator("Reversal Confirmation Planner [AGPro Series]",
     shorttitle = "AG Pro RCP",
     overlay = true,
     max_boxes_count = 30,
     max_labels_count = 160,
     max_lines_count = 60)

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
color inkDark       = color.rgb(15, 23, 42)
color inkLight      = color.rgb(245, 247, 250)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
string ttConfirm = "Close Confirmed prints state changes, labels, and alerts only after the bar closes. Live Updating allows the active bar to update the planner in real time."
string ttSwing = "Confirmed swing length used to locate the prior high or low that price is reacting around. This is a reference for reversal confirmation, not a broad pattern scanner."
string ttAtr = "ATR length used for sweep depth, invalidation buffers, confirmation pockets, label spacing, and target-room projection."
string ttVolume = "Volume baseline used to evaluate whether the reaction and confirmation attempt have participation. If volume is unavailable, the model falls back toward neutral behavior."
string ttMomentum = "Number of bars used to measure whether short-term momentum is turning after the reaction."
string ttWindow = "Maximum number of bars allowed between the initial reaction and the confirmation close before the setup is treated as delayed context."
string ttSensitivity = "Controls how selective the reaction model is. Conservative requires stronger sweep or wick evidence, while Aggressive accepts earlier reactions."
string ttReject = "Allows strong wick rejection events even when price did not fully sweep a confirmed swing level. This keeps the tool useful without turning it into a pattern scanner."
string ttSweep = "Minimum ATR-normalized penetration beyond a prior swing high or low required for sweep-based reactions."
string ttWick = "Minimum wick-to-range ratio required for rejection-only reactions. Higher values reduce labels and require more obvious rejection candles."
string ttBuffer = "ATR buffer beyond the reaction candle used to define the confirmation close line."
string ttInv = "ATR buffer beyond the reaction extreme used to define the invalidation edge. This is a planning reference, not a stop recommendation."
string ttTarget = "Target-room projection multiple based on the distance from confirmation line to invalidation edge. It is a planning reference, not a price forecast."
string ttMinReaction = "Minimum reaction quality required before the planner starts tracking a reversal candidate."
string ttWatch = "Minimum 0-100 score required for BUILDING or CONFIRMING states."
string ttConfirmScore = "Minimum 0-100 score required before a confirmed close becomes a CONFIRMED planning state."
string ttRoom = "Preferred minimum room-to-risk ratio for cleaner reversal confirmation context."
string ttHighAlert = "Minimum confirmation score required for the high-quality confirmation alert."
string ttFollow = "Bars allowed for a CONFIRMED reversal to reach its target room (counts) or return to invalidation (counts as a miss) before the sample times out uncounted. Used by the Room Hit Rate."
string ttPocket = "Shows the confirmation pocket between the reaction reference and confirmation line. The pocket label is centered inside the box."
string ttRoomBand = "Shows the projected target-room band from the confirmation line toward the measured room guide. The band label is centered inside the box."
string ttGuides = "Shows confirmation, invalidation, and target-room guide lines for the active reversal plan. The invalidation rail carries a filled owner badge."
string ttLabels = "Shows side-qualified REACTION, CONFIRMING, CONFIRMED, FAILED, DELAYED, and ROOM TESTED badges with controlled density and owned connectors."
string ttMarkers = "Shows small raw event markers in addition to labels. Disabled by default because the label system already carries the publication-ready visual story."
string ttContext = "Adds sparse context labels while a plan is active. Disabled by default because event labels, pockets, and room bands already provide the primary public visual story."
string ttCooldown = "Minimum bars between recurring event labels. Higher values reduce chart density."
string ttContextSpacing = "Minimum bars between sparse context labels during ongoing reversal planning states."
string ttMaxLabels = "Maximum number of recent labels retained on the chart. Older labels are removed first for performance."
string ttProjection = "Number of bars projected to the right for pockets, room bands, and guide lines."
string ttTerminalHold = "Number of bars a completed, failed, or expired plan remains visible before the planner resets and waits for a fresh reaction. This prevents stale historical plans from staying on the current chart."
string ttRoomVisual = "Compact Band draws a slim target-room zone around the projected guide. Full Room fills the whole distance from confirmation line to target guide."
string ttOpacity = "Transparency for confirmation pocket and target-room boxes. Higher values make the boxes lighter."
string ttLabelOffset = "ATR-based offset that keeps labels away from candles."
string ttShowScore = "Adds the 0-100 confirmation score to chart labels."
string ttLabelSize = "Controls all chart labels and centered box text. Normal is the recommended publication default."
string ttShowPanel = "Shows or hides the AG Pro planning panel. It is shown by default for public-release readability."
string ttPanelLocation = "Moves the AG Pro planning panel to the preferred chart location."
string ttPanelTheme = "Switches the panel between the premium dark AGPro theme and a clean light theme."
string ttPanelFont = "Controls panel text size. Normal is the recommended publication default."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Reversal Engine"
string confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = ttConfirm)
int swingLength = input.int(5, "Swing Reference Length", minval = 2, maxval = 30, group = groupEngine, tooltip = ttSwing)
int atrLength = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine, tooltip = ttAtr)
int volumeLength = input.int(34, "Volume Support Length", minval = 5, maxval = 200, group = groupEngine, tooltip = ttVolume)
int momentumLength = input.int(6, "Momentum Turn Length", minval = 2, maxval = 40, group = groupEngine, tooltip = ttMomentum)
int confirmationWindow = input.int(12, "Confirmation Window Bars", minval = 3, maxval = 60, group = groupEngine, tooltip = ttWindow)
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Aggressive"], group = groupEngine, tooltip = ttSensitivity)
bool allowRejectionOnly = input.bool(true, "Allow Rejection-Only Reactions", group = groupEngine, tooltip = ttReject)
int followWindow = input.int(40, "Room Hit Window", minval = 8, maxval = 400, group = groupEngine, tooltip = ttFollow)

string groupScoring = "Confirmation Scoring"
float minimumSweepAtr = input.float(0.06, "Minimum Sweep Depth ATR", minval = 0.00, maxval = 1.50, step = 0.01, group = groupScoring, tooltip = ttSweep)
float minimumWickRatio = input.float(0.42, "Minimum Rejection Wick Ratio", minval = 0.20, maxval = 0.85, step = 0.01, group = groupScoring, tooltip = ttWick)
float confirmationBufferAtr = input.float(0.08, "Confirmation Close Buffer ATR", minval = 0.00, maxval = 1.00, step = 0.01, group = groupScoring, tooltip = ttBuffer)
float invalidationBufferAtr = input.float(0.16, "Invalidation Edge Buffer ATR", minval = 0.00, maxval = 2.00, step = 0.01, group = groupScoring, tooltip = ttInv)
float targetRoomMultiple = input.float(1.35, "Target Room Multiple", minval = 0.40, maxval = 4.00, step = 0.05, group = groupScoring, tooltip = ttTarget)
int minimumReactionScore = input.int(48, "Minimum Reaction Score", minval = 20, maxval = 90, group = groupScoring, tooltip = ttMinReaction)
int watchThreshold = input.int(55, "BUILDING Threshold", minval = 30, maxval = 90, group = groupScoring, tooltip = ttWatch)
int confirmationThreshold = input.int(70, "CONFIRMED Threshold", minval = 40, maxval = 95, group = groupScoring, tooltip = ttConfirmScore)
float preferredRoomR = input.float(1.15, "Preferred Room / Risk", minval = 0.30, maxval = 4.00, step = 0.05, group = groupScoring, tooltip = ttRoom)
int highQualityAlertScore = input.int(78, "High Quality Alert Score", minval = 50, maxval = 98, group = groupScoring, tooltip = ttHighAlert)

string groupVisual = "Chart Visuals"
bool showConfirmationPocket = input.bool(true, "Show Confirmation Pocket", group = groupVisual, tooltip = ttPocket)
bool showTargetRoomBand = input.bool(true, "Show Target-Room Band", group = groupVisual, tooltip = ttRoomBand)
bool showRiskTargetGuides = input.bool(true, "Show Risk / Target Guides", group = groupVisual, tooltip = ttGuides)
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupVisual, tooltip = ttLabels)
bool showMicroMarkers = input.bool(false, "Show Micro Markers", group = groupVisual, tooltip = ttMarkers)
bool showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupVisual, tooltip = ttContext)
int labelCooldownBars = input.int(30, "Label Cooldown Bars", minval = 1, maxval = 100, group = groupVisual, tooltip = ttCooldown)
int contextSpacingBars = input.int(44, "Context Label Spacing", minval = 6, maxval = 160, group = groupVisual, tooltip = ttContextSpacing)
int maxVisibleLabels = input.int(5, "Max Visible Labels", minval = 4, maxval = 80, group = groupVisual, tooltip = ttMaxLabels)
int projectionBars = input.int(34, "Forward Projection Bars", minval = 8, maxval = 160, group = groupVisual, tooltip = ttProjection)
int terminalHoldBars = input.int(10, "Completed Plan Hold Bars", minval = 1, maxval = 80, group = groupVisual, tooltip = ttTerminalHold)
string targetRoomVisual = input.string("Compact Band", "Target-Room Visual", options = ["Compact Band", "Full Room"], group = groupVisual, tooltip = ttRoomVisual)
int boxTransparency = input.int(88, "Zone Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = ttOpacity)
float labelOffsetAtr = input.float(0.92, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupVisual, tooltip = ttLabelOffset)
bool showLabelScore = input.bool(true, "Show Label Score", group = groupVisual, tooltip = ttShowScore)
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual, tooltip = ttLabelSize)

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

// Luminance-aware text color: dark ink on light fills, light ink on dark fills.
f_text_on(color bg) =>
    float r = color.r(bg)
    float g = color.g(bg)
    float b = color.b(bg)
    float lum = 0.299 * r + 0.587 * g + 0.114 * b
    lum > 145 ? inkDark : inkLight

f_norm_high_good(float value, float weak, float strong) =>
    float span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low_good(float value, float good, float bad) =>
    float span = bad - good
    span == 0.0 ? 0.0 : f_clamp((bad - value) / span * 100.0, 0.0, 100.0)

f_label_size(string sizeText) =>
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

f_score_grade(float score) =>
    string result = "E"
    if score >= 86.0
        result := "A+"
    else if score >= 78.0
        result := "A"
    else if score >= 70.0
        result := "B+"
    else if score >= 62.0
        result := "B"
    else if score >= 54.0
        result := "C"
    else if score >= 42.0
        result := "D"
    result

f_stage_color(string stageText) =>
    switch stageText
        "CONFIRMED" => bullColor
        "CONFIRMING" => accentColor
        "BUILDING" => neutralColor
        "REACTION" => neutralColor
        "ROOM TESTED" => bullColor
        "FAILED" => dangerColor
        "DELAYED" => neutralColor
        => panelLabelCol

f_format_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_trim_events(array<label> labels, array<line> connectors, int maxCount) =>
    int labelCount = array.size(labels)
    if labelCount > maxCount
        int removeCount = labelCount - maxCount
        for idx = 0 to removeCount - 1
            label oldLabel = array.shift(labels)
            line oldConnector = array.shift(connectors)
            label.delete(oldLabel)
            line.delete(oldConnector)

f_set_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_label_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_label_size(fontSize), text_halign = text.align_right)

// -------------------------------------------------
// Core Measurements
// -------------------------------------------------
bool processBar = confirmationMode == "Live Updating" or barstate.isconfirmed
float atrRaw = ta.atr(atrLength)
float safeAtr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
float barRange = math.max(high - low, syminfo.mintick)
float body = math.abs(close - open)
float lowerWick = math.max(math.min(open, close) - low, 0.0)
float upperWick = math.max(high - math.max(open, close), 0.0)
float lowerWickRatio = lowerWick / barRange
float upperWickRatio = upperWick / barRange
float closeLocation = f_clamp((close - low) / barRange, 0.0, 1.0)
float bodyEfficiency = body / barRange

float fastEma = ta.ema(close, 13)
float slowEma = ta.ema(close, 34)
float momentumTurn = (fastEma - nz(fastEma[momentumLength], fastEma)) / safeAtr
float bullMomentumScore = f_clamp(50.0 + momentumTurn * 80.0 + (close > fastEma ? 12.0 : -8.0), 0.0, 100.0)
float bearMomentumScore = f_clamp(50.0 - momentumTurn * 80.0 + (close < fastEma ? 12.0 : -8.0), 0.0, 100.0)
bool priorDownContext = close < nz(close[momentumLength], close) or close < slowEma
bool priorUpContext = close > nz(close[momentumLength], close) or close > slowEma

float volumeValue = nz(volume, 0.0)
float volumeBase = nz(ta.sma(volumeValue, volumeLength), volumeValue)
float volumeRatio = volumeBase > 0.0 ? volumeValue / volumeBase : 1.0
float volumeSlope = volumeRatio - nz(volumeRatio[3], volumeRatio)
float volumeScore = f_clamp((volumeRatio - 0.65) / 0.85 * 75.0 + 15.0 + volumeSlope * 35.0, 0.0, 100.0)

float pivotHigh = ta.pivothigh(high, swingLength, swingLength)
float pivotLow = ta.pivotlow(low, swingLength, swingLength)
var float lastSwingHigh = na
var float lastSwingLow = na
var int lastSwingHighBar = na
var int lastSwingLowBar = na

if not na(pivotHigh)
    lastSwingHigh := pivotHigh
    lastSwingHighBar := bar_index - swingLength

if not na(pivotLow)
    lastSwingLow := pivotLow
    lastSwingLowBar := bar_index - swingLength

float sweepIdeal = sensitivity == "Conservative" ? 0.55 : sensitivity == "Aggressive" ? 0.26 : 0.38
float wickNeed = sensitivity == "Conservative" ? minimumWickRatio + 0.08 : sensitivity == "Aggressive" ? math.max(minimumWickRatio - 0.06, 0.20) : minimumWickRatio
float closeNeed = sensitivity == "Conservative" ? 0.68 : sensitivity == "Aggressive" ? 0.56 : 0.62

bool hasLowReference = not na(lastSwingLow)
bool hasHighReference = not na(lastSwingHigh)
float lowSweepDepthAtr = hasLowReference ? (lastSwingLow - low) / safeAtr : 0.0
float highSweepDepthAtr = hasHighReference ? (high - lastSwingHigh) / safeAtr : 0.0

bool bullSweep = hasLowReference and low < lastSwingLow - safeAtr * minimumSweepAtr and close > lastSwingLow and closeLocation >= closeNeed
bool bearSweep = hasHighReference and high > lastSwingHigh + safeAtr * minimumSweepAtr and close < lastSwingHigh and closeLocation <= 1.0 - closeNeed
bool bullRejectOnly = allowRejectionOnly and priorDownContext and lowerWickRatio >= wickNeed and closeLocation >= closeNeed and close > open
bool bearRejectOnly = allowRejectionOnly and priorUpContext and upperWickRatio >= wickNeed and closeLocation <= 1.0 - closeNeed and close < open

float bullSweepScore = f_clamp(f_norm_high_good(lowSweepDepthAtr, minimumSweepAtr, sweepIdeal) * 0.55 + closeLocation * 45.0, 0.0, 100.0)
float bearSweepScore = f_clamp(f_norm_high_good(highSweepDepthAtr, minimumSweepAtr, sweepIdeal) * 0.55 + (1.0 - closeLocation) * 45.0, 0.0, 100.0)
float bullRejectScore = f_clamp(lowerWickRatio * 95.0 + closeLocation * 30.0 + (close > open ? bodyEfficiency * 18.0 : 0.0), 0.0, 100.0)
float bearRejectScore = f_clamp(upperWickRatio * 95.0 + (1.0 - closeLocation) * 30.0 + (close < open ? bodyEfficiency * 18.0 : 0.0), 0.0, 100.0)
float downExtensionScore = f_clamp((slowEma - low) / safeAtr / 1.75 * 100.0, 0.0, 100.0)
float upExtensionScore = f_clamp((high - slowEma) / safeAtr / 1.75 * 100.0, 0.0, 100.0)
float bullReactionScore = f_clamp(math.max(bullSweep ? bullSweepScore : 0.0, bullRejectOnly ? bullRejectScore : 0.0) * 0.68 + downExtensionScore * 0.20 + volumeScore * 0.12, 0.0, 100.0)
float bearReactionScore = f_clamp(math.max(bearSweep ? bearSweepScore : 0.0, bearRejectOnly ? bearRejectScore : 0.0) * 0.68 + upExtensionScore * 0.20 + volumeScore * 0.12, 0.0, 100.0)
bool bullReaction = bullSweep or bullRejectOnly
bool bearReaction = bearSweep or bearRejectOnly

// -------------------------------------------------
// Active Planner State
// -------------------------------------------------
var bool setupActive = false
var bool setupEverConfirmed = false
var bool setupFailed = false
var bool setupExpired = false
var int setupSide = 0
var int setupBar = na
var float setupReference = na
var float setupReactionHigh = na
var float setupReactionLow = na
var float setupConfirmLine = na
var float setupInvalidation = na
var float setupTarget = na
var float setupReactionScore = na
var float setupConfirmedScore = na
var float setupConfirmedRoomR = na
var int setupTargetTouchedBar = na
var int setupTerminalBar = na

int candidateSide = 0
float candidateScore = na
if bullReaction and (not bearReaction or bullReactionScore >= bearReactionScore)
    candidateSide := 1
    candidateScore := bullReactionScore
else if bearReaction
    candidateSide := -1
    candidateScore := bearReactionScore

bool candidateQualified = processBar and candidateSide != 0 and candidateScore >= minimumReactionScore
bool canReplaceSetup = not setupActive or setupFailed or setupExpired or (candidateSide != setupSide and candidateScore >= nz(setupReactionScore, 0.0) + 6.0) or (not setupEverConfirmed and candidateScore >= nz(setupReactionScore, 0.0) + 10.0 and bar_index - nz(setupBar, bar_index) > 1)
bool startCandidate = candidateQualified and canReplaceSetup

if startCandidate
    float candidateReference = candidateSide == 1 ? (bullSweep ? lastSwingLow : low + lowerWick * 0.55) : (bearSweep ? lastSwingHigh : high - upperWick * 0.55)
    float candidateConfirm = candidateSide == 1 ? high + safeAtr * confirmationBufferAtr : low - safeAtr * confirmationBufferAtr
    float candidateInvalidation = candidateSide == 1 ? low - safeAtr * invalidationBufferAtr : high + safeAtr * invalidationBufferAtr
    float candidateRisk = math.max(math.abs(candidateConfirm - candidateInvalidation), syminfo.mintick)
    float candidateTarget = candidateSide == 1 ? candidateConfirm + candidateRisk * targetRoomMultiple : candidateConfirm - candidateRisk * targetRoomMultiple
    setupActive := true
    setupEverConfirmed := false
    setupFailed := false
    setupExpired := false
    setupSide := candidateSide
    setupBar := bar_index
    setupReference := candidateReference
    setupReactionHigh := high
    setupReactionLow := low
    setupConfirmLine := candidateConfirm
    setupInvalidation := candidateInvalidation
    setupTarget := candidateTarget
    setupReactionScore := candidateScore
    setupConfirmedScore := na
    setupConfirmedRoomR := na
    setupTargetTouchedBar := na
    setupTerminalBar := na

bool activeSetup = setupActive and setupSide != 0 and not na(setupConfirmLine) and not na(setupInvalidation) and not na(setupTarget)
int barsActive = activeSetup ? bar_index - setupBar : 0
float confirmSpan = activeSetup ? math.max(math.abs(setupConfirmLine - setupReference), syminfo.mintick) : na
float confirmProgress = 0.0
if activeSetup
    if setupSide == 1
        confirmProgress := f_clamp((close - setupReference) / confirmSpan * 100.0, 0.0, 100.0)
    else
        confirmProgress := f_clamp((setupReference - close) / confirmSpan * 100.0, 0.0, 100.0)

float riskDistance = activeSetup ? math.max(math.abs(setupConfirmLine - setupInvalidation), syminfo.mintick) : na
float measuredRoom = activeSetup ? math.abs(setupTarget - close) : na
float structuralRoom = na
if activeSetup
    if setupSide == 1 and not na(lastSwingHigh) and lastSwingHigh > close
        structuralRoom := lastSwingHigh - close
    else if setupSide == -1 and not na(lastSwingLow) and lastSwingLow < close
        structuralRoom := close - lastSwingLow

float activeRoom = not na(structuralRoom) and structuralRoom > 0.0 ? math.min(structuralRoom, measuredRoom) : measuredRoom
float roomR = activeSetup and riskDistance > 0.0 ? activeRoom / riskDistance : na
float roomScore = activeSetup ? f_clamp((nz(roomR, 0.0) - 0.25) / math.max(preferredRoomR - 0.25, 0.10) * 100.0, 0.0, 100.0) : 0.0
float momentumScore = activeSetup ? (setupSide == 1 ? bullMomentumScore : bearMomentumScore) : 0.0
bool confirmationClose = activeSetup and processBar and (setupSide == 1 ? close > setupConfirmLine : close < setupConfirmLine)
float confirmationScore = activeSetup ? f_clamp(setupReactionScore * 0.30 + confirmProgress * 0.25 + momentumScore * 0.20 + volumeScore * 0.12 + roomScore * 0.13, 0.0, 100.0) : 0.0

bool invalidatedNow = activeSetup and processBar and not setupFailed and (setupSide == 1 ? close < setupInvalidation : close > setupInvalidation)
bool expiredNow = activeSetup and processBar and not setupEverConfirmed and not setupFailed and barsActive > confirmationWindow
bool confirmedNow = activeSetup and processBar and not setupEverConfirmed and not setupFailed and not setupExpired and confirmationClose and confirmationScore >= confirmationThreshold

if invalidatedNow
    setupFailed := true
    setupTerminalBar := na(setupTerminalBar) ? bar_index : setupTerminalBar

if expiredNow
    setupExpired := true
    setupTerminalBar := na(setupTerminalBar) ? bar_index : setupTerminalBar

if confirmedNow
    setupEverConfirmed := true
    setupConfirmedScore := confirmationScore
    setupConfirmedRoomR := roomR

bool targetTouchedNow = activeSetup and setupEverConfirmed and not setupFailed and na(setupTargetTouchedBar) and (setupSide == 1 ? high >= setupTarget : low <= setupTarget)
if targetTouchedNow
    setupTargetTouchedBar := bar_index
    setupTerminalBar := bar_index

bool terminalStale = activeSetup and not na(setupTerminalBar) and bar_index - setupTerminalBar > terminalHoldBars
if terminalStale
    setupActive := false
    setupEverConfirmed := false
    setupFailed := false
    setupExpired := false
    setupSide := 0
    setupBar := na
    setupReference := na
    setupReactionHigh := na
    setupReactionLow := na
    setupConfirmLine := na
    setupInvalidation := na
    setupTarget := na
    setupReactionScore := na
    setupConfirmedScore := na
    setupConfirmedRoomR := na
    setupTargetTouchedBar := na
    setupTerminalBar := na

activeSetup := setupActive and setupSide != 0 and not na(setupConfirmLine) and not na(setupInvalidation) and not na(setupTarget)
bool targetTouched = activeSetup and not na(setupTargetTouchedBar) and bar_index - setupTargetTouchedBar <= terminalHoldBars

// -------------------------------------------------
// Room Hit Rate (stop-aware, confirmed-bar gated, resolve-then-open)
// Of past CONFIRMED reversals, how many reached the target room before returning
// to the script's own invalidation. Levels frozen at the confirm bar. Times out
// uncounted if neither side is reached inside the window.
// -------------------------------------------------
var int roomWins = 0
var int roomTotal = 0
var bool roomPending = false
var int roomDir = 0
var float roomTargetLvl = na
var float roomStopLvl = na
var int roomStartBar = na

if barstate.isconfirmed
    if roomPending
        bool reachedTarget = roomDir == 1 ? high >= roomTargetLvl : low <= roomTargetLvl
        bool reachedStop = roomDir == 1 ? low <= roomStopLvl : high >= roomStopLvl
        if reachedTarget
            roomWins += 1
            roomTotal += 1
            roomPending := false
        else if reachedStop
            roomTotal += 1
            roomPending := false
        else if not na(roomStartBar) and bar_index - roomStartBar >= followWindow
            roomPending := false
    if not roomPending and confirmedNow and not na(setupTarget) and not na(setupInvalidation)
        roomDir := setupSide
        roomTargetLvl := setupTarget
        roomStopLvl := setupInvalidation
        roomStartBar := bar_index
        roomPending := true

int roomPct = roomTotal > 0 ? int(math.round(roomWins / roomTotal * 100.0)) : na
bool roomBuilding = roomTotal < 6
string roomHitText = roomBuilding ? "Building (" + str.tostring(roomTotal) + ")" : str.tostring(roomPct) + "% (" + str.tostring(roomTotal) + ")"
color roomHitColor = roomBuilding ? neutralColor : roomPct >= 52 ? bullColor : roomPct >= 44 ? neutralColor : bearColor

string stageNow = "IDLE"
if activeSetup
    if setupFailed
        stageNow := "FAILED"
    else if setupExpired
        stageNow := "DELAYED"
    else if targetTouched
        stageNow := "ROOM TESTED"
    else if setupEverConfirmed
        stageNow := "CONFIRMED"
    else if confirmationClose and confirmationScore >= watchThreshold
        stageNow := "CONFIRMING"
    else if confirmationScore >= watchThreshold
        stageNow := "BUILDING"
    else
        stageNow := "REACTION"

string sideText = setupSide == 1 ? "Bullish" : setupSide == -1 ? "Bearish" : "Neutral"
string actionText = "Wait for reaction"
if stageNow == "REACTION"
    actionText := "Wait for close confirm"
else if stageNow == "BUILDING"
    actionText := "Monitor turn"
else if stageNow == "CONFIRMING"
    actionText := "Review risk / room"
else if stageNow == "CONFIRMED"
    actionText := "Plan review"
else if stageNow == "ROOM TESTED"
    actionText := "Reassess follow-through"
else if stageNow == "FAILED"
    actionText := "Reset context"
else if stageNow == "DELAYED"
    actionText := "Review delay"

color sideColor = setupSide == 1 ? bullColor : setupSide == -1 ? bearColor : neutralColor
color stageColor = f_stage_color(stageNow)
if setupSide != 0 and (stageNow == "CONFIRMING" or stageNow == "CONFIRMED" or stageNow == "ROOM TESTED")
    stageColor := sideColor

bool useLockedScore = setupEverConfirmed and not setupFailed and not setupExpired
float displayScore = activeSetup ? (useLockedScore ? nz(setupConfirmedScore, confirmationScore) : confirmationScore) : 0.0
float displayRoomR = activeSetup ? (useLockedScore ? nz(setupConfirmedRoomR, roomR) : roomR) : na

// -------------------------------------------------
// Visual Objects
// -------------------------------------------------
var box confirmationPocket = na
var box targetRoomBand = na
var label pocketBadge = na
var label roomBadge = na
var label invalidationBadge = na
var line confirmationLine = na
var line invalidationLine = na
var line targetLine = na

int drawBackLimit = 9000
int leftEdge = activeSetup ? math.max(setupBar, bar_index - drawBackLimit) : bar_index
int rightEdge = bar_index + projectionBars

if activeSetup and showConfirmationPocket
    float pocketTop = math.max(setupReference, setupConfirmLine)
    float pocketBottom = math.min(setupReference, setupConfirmLine)
    string pocketText = setupSide == 1 ? "Bull Confirm Pocket" : "Bear Confirm Pocket"
    color pocketColor = setupEverConfirmed ? color.new(sideColor, boxTransparency - 8) : color.new(sideColor, boxTransparency)
    int pocketBadgeX = int(math.round((leftEdge + rightEdge) / 2.0))
    float pocketBadgeY = (pocketTop + pocketBottom) * 0.5
    if na(confirmationPocket)
        confirmationPocket := box.new(left = leftEdge, top = pocketTop, right = rightEdge, bottom = pocketBottom, xloc = xloc.bar_index, bgcolor = pocketColor, border_color = color.new(sideColor, 34), border_width = 1)
    else
        box.set_left(confirmationPocket, leftEdge)
        box.set_right(confirmationPocket, rightEdge)
        box.set_top(confirmationPocket, pocketTop)
        box.set_bottom(confirmationPocket, pocketBottom)
        box.set_bgcolor(confirmationPocket, pocketColor)
        box.set_border_color(confirmationPocket, color.new(sideColor, 34))
    if na(pocketBadge)
        pocketBadge := label.new(pocketBadgeX, pocketBadgeY, pocketText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(sideColor, 0), textcolor = f_text_on(sideColor), size = f_label_size(labelFontSize), textalign = text.align_center)
    else
        label.set_xy(pocketBadge, pocketBadgeX, pocketBadgeY)
        label.set_text(pocketBadge, pocketText)
        label.set_color(pocketBadge, color.new(sideColor, 0))
        label.set_textcolor(pocketBadge, f_text_on(sideColor))
        label.set_size(pocketBadge, f_label_size(labelFontSize))
else
    if not na(confirmationPocket)
        box.delete(confirmationPocket)
        confirmationPocket := na
    if not na(pocketBadge)
        label.delete(pocketBadge)
        pocketBadge := na

if activeSetup and showTargetRoomBand
    float compactHalfHeight = math.max(safeAtr * 0.32, riskDistance * 0.08)
    compactHalfHeight := math.min(compactHalfHeight, riskDistance * 0.24)
    float bandTop = targetRoomVisual == "Full Room" ? math.max(setupConfirmLine, setupTarget) : setupTarget + compactHalfHeight
    float bandBottom = targetRoomVisual == "Full Room" ? math.min(setupConfirmLine, setupTarget) : setupTarget - compactHalfHeight
    string bandText = "Target Room"
    color bandColor = color.new(accentColor, boxTransparency)
    int bandLeft = math.max(leftEdge, bar_index - 1)
    int roomBadgeX = int(math.round((bandLeft + rightEdge) / 2.0))
    float roomBadgeY = (bandTop + bandBottom) * 0.5
    if na(targetRoomBand)
        targetRoomBand := box.new(left = bandLeft, top = bandTop, right = rightEdge, bottom = bandBottom, xloc = xloc.bar_index, bgcolor = bandColor, border_color = color.new(accentColor, 42), border_width = 1)
    else
        box.set_left(targetRoomBand, bandLeft)
        box.set_right(targetRoomBand, rightEdge)
        box.set_top(targetRoomBand, bandTop)
        box.set_bottom(targetRoomBand, bandBottom)
        box.set_bgcolor(targetRoomBand, bandColor)
        box.set_border_color(targetRoomBand, color.new(accentColor, 42))
    if na(roomBadge)
        roomBadge := label.new(roomBadgeX, roomBadgeY, bandText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(accentColor, 0), textcolor = f_text_on(accentColor), size = f_label_size(labelFontSize), textalign = text.align_center)
    else
        label.set_xy(roomBadge, roomBadgeX, roomBadgeY)
        label.set_text(roomBadge, bandText)
        label.set_color(roomBadge, color.new(accentColor, 0))
        label.set_textcolor(roomBadge, f_text_on(accentColor))
        label.set_size(roomBadge, f_label_size(labelFontSize))
else
    if not na(targetRoomBand)
        box.delete(targetRoomBand)
        targetRoomBand := na
    if not na(roomBadge)
        label.delete(roomBadge)
        roomBadge := na

if activeSetup and showRiskTargetGuides
    if na(confirmationLine)
        confirmationLine := line.new(leftEdge, setupConfirmLine, rightEdge, setupConfirmLine, xloc = xloc.bar_index, extend = extend.none, color = color.new(sideColor, 0), width = 2)
    else
        line.set_xy1(confirmationLine, leftEdge, setupConfirmLine)
        line.set_xy2(confirmationLine, rightEdge, setupConfirmLine)
        line.set_color(confirmationLine, color.new(sideColor, 0))
    if na(invalidationLine)
        invalidationLine := line.new(leftEdge, setupInvalidation, rightEdge, setupInvalidation, xloc = xloc.bar_index, extend = extend.none, color = color.new(dangerColor, 0), width = 2, style = line.style_dashed)
    else
        line.set_xy1(invalidationLine, leftEdge, setupInvalidation)
        line.set_xy2(invalidationLine, rightEdge, setupInvalidation)
        line.set_color(invalidationLine, color.new(dangerColor, 0))
    int invalidationLeadBars = labelFontSize == "Tiny" ? 6 : labelFontSize == "Small" ? 7 : labelFontSize == "Large" ? 11 : 9
    int invalidationBadgeX = math.min(rightEdge - 2, bar_index + invalidationLeadBars)
    if na(invalidationBadge)
        invalidationBadge := label.new(invalidationBadgeX, setupInvalidation, "INVALIDATION", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(dangerColor, 0), textcolor = f_text_on(dangerColor), size = f_label_size(labelFontSize), textalign = text.align_center)
    else
        label.set_xy(invalidationBadge, invalidationBadgeX, setupInvalidation)
        label.set_text(invalidationBadge, "INVALIDATION")
        label.set_color(invalidationBadge, color.new(dangerColor, 0))
        label.set_textcolor(invalidationBadge, f_text_on(dangerColor))
        label.set_size(invalidationBadge, f_label_size(labelFontSize))
    if na(targetLine)
        targetLine := line.new(bar_index, setupTarget, rightEdge, setupTarget, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 0), width = 1, style = line.style_dotted)
    else
        line.set_xy1(targetLine, bar_index, setupTarget)
        line.set_xy2(targetLine, rightEdge, setupTarget)
        line.set_color(targetLine, color.new(accentColor, 0))
else
    if not na(confirmationLine)
        line.delete(confirmationLine)
        confirmationLine := na
    if not na(invalidationLine)
        line.delete(invalidationLine)
        invalidationLine := na
    if not na(invalidationBadge)
        label.delete(invalidationBadge)
        invalidationBadge := na
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na

// -------------------------------------------------
// Labels and Markers
// -------------------------------------------------
var int lastLabelBar = na
var string lastStage = "IDLE"
var array<label> eventLabels = array.new_label()
var array<line> eventConnectors = array.new_line()

bool stageChanged = processBar and stageNow != lastStage
bool labelCooldownReady = na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars
bool contextReady = na(lastLabelBar) or bar_index - lastLabelBar >= contextSpacingBars
bool importantStage = stageNow == "CONFIRMING" or stageNow == "CONFIRMED" or stageNow == "ROOM TESTED" or stageNow == "FAILED" or stageNow == "DELAYED"
bool drawStageLabel = showEventLabels and labelCooldownReady and stageChanged and importantStage
bool drawContextLabel = showContextLabels and contextReady and activeSetup and (stageNow == "BUILDING" or stageNow == "CONFIRMING" or stageNow == "CONFIRMED")

bool drawReactionLabel = showEventLabels and startCandidate and labelCooldownReady

if drawReactionLabel
    string labelText = setupSide == 1 ? "BULL REACTION" : "BEAR REACTION"
    if showLabelScore
        labelText += " | Q" + str.tostring(displayScore, "#")
    int labelLane = bar_index % 3
    float fontLaneFactor = labelFontSize == "Tiny" ? 0.16 : labelFontSize == "Small" ? 0.20 : labelFontSize == "Large" ? 0.32 : 0.25
    float laneOffset = safeAtr * (labelOffsetAtr + labelLane * fontLaneFactor)
    float anchorY = setupSide == 1 ? low : high
    float labelY = setupSide == 1 ? anchorY - laneOffset : anchorY + laneOffset
    color reactBg = color.new(sideColor, 8)
    line eventConnector = line.new(bar_index, anchorY, bar_index, labelY, xloc = xloc.bar_index, extend = extend.none, color = color.new(sideColor, 28), width = 1)
    label eventLabel = label.new(x = bar_index, y = labelY, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = setupSide == 1 ? label.style_label_up : label.style_label_down, color = reactBg, textcolor = f_text_on(reactBg), size = f_label_size(labelFontSize))
    array.push(eventLabels, eventLabel)
    array.push(eventConnectors, eventConnector)
    f_trim_events(eventLabels, eventConnectors, maxVisibleLabels)
    lastLabelBar := bar_index
else if drawStageLabel or drawContextLabel
    string labelState = drawContextLabel and not drawStageLabel ? "PLAN" : stageNow
    string labelText = (setupSide == 1 ? "BULL " : "BEAR ") + labelState
    if showLabelScore and activeSetup
        labelText += " | Q" + str.tostring(displayScore, "#")
    int labelLane = bar_index % 3
    float fontLaneFactor = labelFontSize == "Tiny" ? 0.16 : labelFontSize == "Small" ? 0.20 : labelFontSize == "Large" ? 0.32 : 0.25
    float laneOffset = safeAtr * (labelOffsetAtr + labelLane * fontLaneFactor)
    float anchorY = setupSide == 1 ? low : high
    float labelY = setupSide == 1 ? anchorY - laneOffset : anchorY + laneOffset
    color stageBg = color.new(drawStageLabel ? stageColor : sideColor, 8)
    line eventConnector = line.new(bar_index, anchorY, bar_index, labelY, xloc = xloc.bar_index, extend = extend.none, color = color.new(drawStageLabel ? stageColor : sideColor, 28), width = 1)
    label eventLabel = label.new(x = bar_index, y = labelY, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = setupSide == 1 ? label.style_label_up : label.style_label_down, color = stageBg, textcolor = f_text_on(stageBg), size = f_label_size(labelFontSize))
    array.push(eventLabels, eventLabel)
    array.push(eventConnectors, eventConnector)
    f_trim_events(eventLabels, eventConnectors, maxVisibleLabels)
    lastLabelBar := bar_index

bool bullReactionEvent = startCandidate and setupSide == 1
bool bearReactionEvent = startCandidate and setupSide == -1
bool bullConfirmedEvent = confirmedNow and setupSide == 1
bool bearConfirmedEvent = confirmedNow and setupSide == -1
bool failedEvent = invalidatedNow
bool delayedEvent = expiredNow
bool highQualityEvent = (confirmedNow or (stageChanged and stageNow == "CONFIRMING")) and confirmationScore >= highQualityAlertScore

plotshape(showMicroMarkers and bullReactionEvent, title = "Bullish Reaction Marker", style = shape.circle, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(showMicroMarkers and bearReactionEvent, title = "Bearish Reaction Marker", style = shape.circle, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny)
plotshape(showMicroMarkers and bullConfirmedEvent, title = "Bullish Confirmation Marker", style = shape.diamond, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(showMicroMarkers and bearConfirmedEvent, title = "Bearish Confirmation Marker", style = shape.diamond, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny)
plotshape(showMicroMarkers and failedEvent, title = "Failed Confirmation Marker", style = shape.xcross, location = location.abovebar, color = color.new(dangerColor, 0), size = size.tiny)

// -------------------------------------------------
// Data Window
// -------------------------------------------------
plot(displayScore, title = "Displayed Confirmation Score", color = stageColor, display = display.data_window)
plot(confirmationScore, title = "Live Confirmation Score", color = accentColor, display = display.data_window)
plot(setupReactionScore, title = "Reaction Score", color = neutralColor, display = display.data_window)
plot(confirmProgress, title = "Confirmation Progress", color = accentColor, display = display.data_window)
plot(momentumScore, title = "Momentum Turn Score", color = bullColor, display = display.data_window)
plot(volumeScore, title = "Volume Support Score", color = bearColor, display = display.data_window)
plot(roomScore, title = "Room Score", color = panelLabelCol, display = display.data_window)

// -------------------------------------------------
// Panel
// -------------------------------------------------
string activeTheme = panelTheme
color dashBg = f_panel_bg(activeTheme)
color frameColor = f_panel_border(activeTheme)
var table panel = table.new(f_panel_position(panelLocation), 2, 7, bgcolor = dashBg, frame_color = frameColor, frame_width = 1, border_color = frameColor, border_width = 1)

string scoreRead = activeSetup ? str.tostring(displayScore, "#") + " / " + f_score_grade(displayScore) : "-"
string invalidationRead = activeSetup ? f_format_price(setupInvalidation) : "-"
string roomRead = activeSetup ? f_format_price(setupTarget) + " / " + str.tostring(displayRoomR, "#.00") + "R" : "-"
string stageRead = activeSetup ? stageNow + " / " + sideText : "IDLE"

if barstate.islast
    table.clear(panel, 0, 0, 1, 6)
    if showPanel
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Reversal Confirmation Planner", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelFontSize), text_halign = text.align_center)
        f_set_row(panel, 1, "Reversal Stage", stageRead, stageColor, activeTheme, panelFontSize)
        f_set_row(panel, 2, "Confirmation Score", scoreRead, stageColor, activeTheme, panelFontSize)
        f_set_row(panel, 3, "Invalidation", invalidationRead, dangerColor, activeTheme, panelFontSize)
        f_set_row(panel, 4, "Room", roomRead, roomScore >= 70.0 ? bullColor : roomScore >= 45.0 ? neutralColor : bearColor, activeTheme, panelFontSize)
        f_set_row(panel, 5, "Room Hit Rate", roomHitText, roomHitColor, activeTheme, panelFontSize)
        f_set_row(panel, 6, "Action", actionText, stageColor, activeTheme, panelFontSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(bullReactionEvent, title = "Bullish Reaction", message = "Reversal Confirmation Planner: bullish reaction context is active. Wait for confirmation; this is not a trade instruction.")
alertcondition(bearReactionEvent, title = "Bearish Reaction", message = "Reversal Confirmation Planner: bearish reaction context is active. Wait for confirmation; this is not a trade instruction.")
alertcondition(bullConfirmedEvent, title = "Bullish Confirmation", message = "Reversal Confirmation Planner: bullish confirmation state is active. Review invalidation and room context.")
alertcondition(bearConfirmedEvent, title = "Bearish Confirmation", message = "Reversal Confirmation Planner: bearish confirmation state is active. Review invalidation and room context.")
alertcondition(failedEvent, title = "Failed Confirmation", message = "Reversal Confirmation Planner: the active reversal confirmation plan failed or violated its invalidation edge.")
alertcondition(delayedEvent, title = "Delayed Confirmation", message = "Reversal Confirmation Planner: the active reaction did not confirm within the selected review window. Review delay context, not a trade instruction.")
alertcondition(highQualityEvent, title = "High Quality Confirmation", message = "Reversal Confirmation Planner: confirmation score reached the high-quality alert threshold. This is an attention marker only.")

if processBar
    lastStage := stageNow
````
