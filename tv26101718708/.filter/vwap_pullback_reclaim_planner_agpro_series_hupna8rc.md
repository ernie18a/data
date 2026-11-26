# VWAP Pullback Reclaim Planner [AGPro Series]

- url: https://www.tradingview.com/script/huPnA8Rc-VWAP-Pullback-Reclaim-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;687ac09774e446869f75894abd10f5c3
- version: 6.0

## Description

VWAP Pullback Reclaim Planner [AGPro Series]

🧠 Core Idea

Has price pulled back into VWAP and reclaimed it with enough quality to deserve attention?


📌 Overview / What it does

VWAP Pullback Reclaim Planner is a volume-weighted price action tool designed to evaluate pullbacks around VWAP and highlight reclaim conditions with a structured readiness score.

The script maps VWAP, a pullback pocket, reclaim corridors, invalidation shelves, target rails, labels, and a compact AG Pro dashboard. It focuses on whether price has moved away from VWAP, reacted, and returned through the reference with enough quality.

It does not predict future price movement, automate trading, or provide buy/sell commands. It is a visual decision-support framework for reading VWAP reclaim context.


🎯 Purpose & Design Philosophy

This script was built for traders who use VWAP as a live market reference but need more structure than a single line on the chart.

Many VWAP tools show the average price only. This planner adds context: pullback depth, reclaim quality, reaction strength, room, invalidation, and next-action state.

The design philosophy is simple: make VWAP reclaim situations easier to read without turning them into mechanical signals.


⚡ Why This Script Is Different

Most tools focus on plotting VWAP as a static benchmark.

This script does NOT treat every VWAP touch as meaningful.

Instead, it waits for a pullback, checks reclaim behavior, scores the reaction, and then presents the result through zones, labels, target rails, and a clear READY / MONITOR / WAIT / INVALIDATED state.


⚙️ Methodology

1. Context Detection

The script builds an anchored VWAP from the selected anchor mode and monitors price distance from that volume-weighted reference.

2. Reference Mapping

It creates a VWAP pullback pocket using ATR depth so the zone adapts to current volatility.

3. Reaction Evaluation

When price reclaims VWAP after a pullback, the script evaluates close distance, wick response, body quality, relative volume, VWAP slope alignment, and freshness.

4. Visual Output

Qualified events are shown with reclaim labels, a reclaim corridor, invalidation shelf, target rails, right-side tags, and a panel summary.


🗺️ How to Read the Chart

VWAP line shows the active volume-weighted reference.

The shaded pocket around VWAP marks the pullback area where reaction quality is evaluated.

READY RECLAIM labels highlight reclaim events that pass the selected score threshold.

The reclaim corridor shows the active continuation area after a valid reclaim.

The invalidation shelf marks where the reclaim context weakens.

The AG Pro panel summarizes VWAP State, Reclaim Score, Pullback Quality, Room, and Action.


🚦 Signals & States

• READY RECLAIM → price reclaimed VWAP after a pullback with enough quality.

• VWAP PULLBACK → price is inside or beyond the pullback pocket and may deserve monitoring.

• INVALIDATED → an active reclaim context lost its invalidation shelf.

• READY → a qualified reclaim event is active.

• MONITOR → a reclaim or pullback context is active but not a fresh ready event.

• WAIT → no actionable VWAP reclaim context is active.

• BLOCKED → VWAP or volatility context is not valid enough for evaluation.


🔔 Alerts Logic

Bullish VWAP Reclaim Ready triggers when price reclaims VWAP upward after a valid pullback and score threshold is met.

Bearish VWAP Reclaim Ready triggers when price reclaims VWAP downward after a valid pullback and score threshold is met.

VWAP Pullback Watch triggers when price enters the pullback evaluation area.

VWAP Reclaim Invalidated triggers when an active reclaim loses its invalidation shelf.

Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The strongest contexts appear when pullback freshness, VWAP reclaim, wick response, close strength, relative volume, and VWAP slope alignment support the same direction.

When these factors align, the score improves and the panel shifts toward a clearer action state.


📊 When to Use

• Intraday sessions where VWAP is actively watched

• Trend pullbacks around a volume-weighted mean

• Post-move reclaim attempts after sharp reactions

• Markets with enough liquidity for VWAP to be meaningful

• Breakout continuation and mean-reclaim review


⚠️ When NOT to Use

• Very low liquidity markets

• Extremely noisy symbols with unreliable volume

• Markets with wide spread or thin candles

• News-driven spikes where VWAP context can change too quickly

• Symbols where volume data is missing or distorted


🎛️ Key Inputs

• Anchor Mode → controls whether VWAP resets by session, week, or month.

• Pullback Pocket Depth → changes how wide the VWAP pullback area becomes.

• Reclaim Buffer → requires price to reclaim beyond VWAP by a volatility-adjusted amount.

• Invalidation Shelf → controls the risk shelf after reclaim.

• Minimum Ready Score → sets how strict READY labels should be.

• Target Rails → control the projected T1 and T2 reference levels.

• Label Settings → control density, size, spacing, and visual clarity.

• Panel Settings → control panel visibility, location, theme, and font size.


🖥️ Interface & Visual Design

The interface is designed to keep the chart readable while still feeling premium and informative.

The panel provides the current state at a glance. Labels mark important reclaim events. Zones and rails show context without overwhelming the candles.

The visual hierarchy is built around VWAP first, reclaim quality second, and action state third.


🧪 Practical Usage Workflow

1. Read the panel state.

2. Check whether price is near the VWAP pullback pocket.

3. Look for READY RECLAIM labels and score quality.

4. Compare price with the reclaim corridor, invalidation shelf, and target rails.

5. Confirm the broader market structure before making any decision.


🔍 Interpretation Guidelines

A high score means the reclaim structure is cleaner according to the script's rules.

A low or missing score means the reclaim context is incomplete, weak, or not currently active.

The script is best interpreted with trend, liquidity, volatility, and higher-timeframe structure.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not a financial advisor.

It is not an automated trading system.

It does not guarantee entries, exits, profits, or outcomes.


⚠️ Limitations & Transparency

VWAP behavior can differ across symbols, sessions, and timeframes.

Volume quality matters. If volume data is unreliable, VWAP interpretation may weaken.

Fast volatility expansion can invalidate reclaim context quickly.

No rule-based tool can fully account for market news, liquidity shocks, or sudden structural changes.


🧠 Market Context Notes

VWAP often acts as a live reference for institutional positioning, intraday fairness, and reaction quality.

However, VWAP should not be read alone. The best use comes from combining VWAP reclaim structure with liquidity, trend, volatility, and support/resistance context.


🧾 Use Case Examples

When price pulls below VWAP, rejects lower prices, and reclaims VWAP with strong close quality, the script may mark a bullish reclaim context.

When price pushes above VWAP, fails to hold, and reclaims downward with strong reaction quality, the script may mark a bearish reclaim context.


🧱 System Philosophy

VWAP Pullback Reclaim Planner follows the AG Pro Series approach: convert a market concept into a structured decision map with context, score, risk reference, and visual clarity.

The goal is not to replace judgment. The goal is to make judgment easier.


🔐 Non-Promise Statement

No script can provide certainty.

No signal should be treated as guaranteed.

Outputs should always be interpreted with independent analysis and risk control.


📉 Risk Disclosure

Trading involves risk.

Market conditions can change quickly.

Users are responsible for their own decisions, risk management, and trade execution.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

This script is designed to help traders study how VWAP pullbacks, reclaim attempts, and reaction quality behave across different market conditions.

## Source Code

````pine
// -------------------------------------------------
// VWAP Pullback Reclaim Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.4
//
// VWAP Pullback Reclaim Planner is a volume-weighted mean-reclaim decision
// engine for VWAP pullbacks, reclaim acceptance, execution readiness, and
// invalidation context. It maps anchored VWAP, live pullback pockets,
// reclaim corridors, target rails, compact state labels, and a 0-100
// readiness score without becoming an automated signal system.
// V2.4 adds confirmed lifecycle control, explicit T1/T2 progress states,
// compact zone badges, and a tighter publication-ready projection footprint.
// -------------------------------------------------

//@version=6
indicator("VWAP Pullback Reclaim Planner [AGPro Series]",
     shorttitle       = "AG Pro VPR",
     overlay          = true,
     max_boxes_count  = 4,
     max_labels_count = 40,
     max_lines_count  = 12)

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
dangerColor   = color.rgb(239, 68, 68)
darkText      = color.rgb(17, 24, 39)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
string ttAnchor = "Controls when VWAP resets. Session is classic intraday VWAP, while Week and Month provide broader anchored context."
string ttSource = "Price source used in the volume-weighted average calculation."
string ttAtr = "ATR normalizes pullback pocket depth, reclaim buffers, target rails, shelf height, and label spacing."
string ttMinVol = "Optional minimum bar volume filter. Keep at 0 to disable."
string ttConfirm = "Fast reacts earlier, Balanced requires cleaner reclaim quality, and Strict demands stronger acceptance."
string ttConfirmClose = "When enabled, READY, target, invalidation, label, and alert events are committed only after the bar closes."
string ttReady = "Minimum 0-100 reclaim score required before READY appears."
string ttWatch = "Minimum 0-100 score used for pullback watch labels while reclaim quality is still developing."
string ttLookback = "How far back the script looks for a valid pullback away from VWAP."
string ttPocket = "ATR-based pocket around VWAP where pullback quality is measured."
string ttReclaim = "ATR-based close distance beyond VWAP required to confirm reclaim."
string ttInvalid = "ATR-based shelf beyond VWAP where the reclaim context weakens or fails."
string ttWindow = "Maximum number of bars after reclaim during which the context remains active."
string ttTargetOne = "First projected target from VWAP after a qualified reclaim."
string ttTargetTwo = "Second projected target from VWAP after a qualified reclaim."
string ttVolScore = "Adds relative volume participation to reclaim score."
string ttVolLen = "Lookback used to compare current volume against recent average participation."
string ttShowVwap = "Shows the active VWAP rail."
string ttShowPocket = "Shows the live VWAP pullback pocket."
string ttShowCorridor = "Shows the projected continuation corridor after reclaim with a contrast-safe centered badge."
string ttShowShelf = "Shows the area where reclaim quality weakens with a centered risk-shelf badge so the zone remains self-explanatory."
string ttShowTargets = "Shows T1 and T2 target rails after reclaim."
string ttLabels = "Shows compact READY reclaim labels."
string ttWatchLabels = "Shows sparse pullback watch labels so the chart does not look empty during VWAP tests."
string ttInvalidLabels = "Shows failed reclaim labels. Enabled by default with controlled cooldown so important failures remain visible without clutter."
string ttTags = "Shows compact right-side tags for VWAP or active targets. Main VWAP tag is suppressed during active corridors to avoid overlap."
string ttBars = "Colors bars lightly when a VWAP reclaim state is active."
string ttProjection = "How far pockets, corridors, and target rails project to the right."
string ttLabelSize = "Controls chart label, right-side tag, and centered zone text size. Normal is the recommended publication default."
string ttOffset = "ATR-based vertical spacing used to keep labels away from candles."
string ttMaxLabels = "Maximum number of event labels retained on chart."
string ttCooldown = "Minimum bars between major event labels. Higher values reduce clustering."
string ttWatchSpacing = "Minimum bars between sparse pullback watch labels."
string ttMinLabelScore = "Minimum quality required for retained historical READY and pullback-watch labels. The active reclaim badge remains visible independently."
string ttPanel = "Displays the AG Pro decision panel. Enabled by default."
string ttPanelLoc = "Controls where the AG Pro panel appears on chart."
string ttPanelTheme = "Switches the panel between the premium AGPro dark theme and a clean light theme."
string ttPanelSize = "Controls text size inside the decision panel. Normal is the recommended publication default."
string ttAlertReady = "Creates an alert condition when a VWAP reclaim becomes READY."
string ttAlertWatch = "Creates an alert condition when price enters a pullback pocket around VWAP."
string ttAlertInvalid = "Creates an alert condition when a reclaim loses VWAP acceptance."

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(value, maxValue))

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
    theme == "Clean Light" ? color.rgb(241, 245, 249) : panelBg

f_panel_border(string theme) =>
    theme == "Clean Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string theme, int row) =>
    bool evenRow = row % 2 == 0
    theme == "Clean Light" ? (evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)) : (evenRow ? color.rgb(20, 31, 52) : panelBg)

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_right)

f_grade(float score) =>
    score >= 86 ? "A+" : score >= 76 ? "A" : score >= 66 ? "B" : score >= 54 ? "C" : "D"

f_score_text(float score) =>
    na(score) ? "-" : str.tostring(math.round(score)) + " / " + f_grade(score)

f_score_compact(float score) =>
    na(score) ? "-" : str.tostring(math.round(score)) + " " + f_grade(score)

f_rate_pct(value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(value) =>
    value >= 55.0 ? bullColor : value >= 40.0 ? neutralColor : bearColor

f_flip_color(value) =>
    value <= 30.0 ? bullColor : value <= 55.0 ? neutralColor : bearColor

f_text_on(color bgColor) =>
    float r = color.r(bgColor)
    float g = color.g(bgColor)
    float b = color.b(bgColor)
    float yiq = (r * 299.0 + g * 587.0 + b * 114.0) / 1000.0
    yiq >= 150.0 ? darkText : headerText

f_score_color(float score, int readyScore, int watchScore) =>
    na(score) ? panelValueCol : score >= readyScore ? bullColor : score >= watchScore ? accentColor : score >= 40 ? neutralColor : bearColor

f_action_color(string actionText, int dir) =>
    switch actionText
        "READY" => dir == 1 ? bullColor : dir == -1 ? bearColor : bullColor
        "MONITOR" => accentColor
        "TARGET 1" => neutralColor
        "TARGET 2" => dir == 1 ? bullColor : bearColor
        "WAIT" => neutralColor
        "INVALIDATED" => dangerColor
        "BLOCKED" => panelValueCol
        => panelValueCol

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        label oldLabel = array.shift(labels)
        label.delete(oldLabel)

f_atr_text(float value) =>
    na(value) ? "-" : str.tostring(value, "#.##") + " ATR"

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupVwap = "VWAP Engine"
string anchorMode = input.string("Session", "VWAP Anchor", options = ["Session", "Week", "Month"], group = groupVwap, tooltip = ttAnchor)
src = input.source(hlc3, "VWAP Source", group = groupVwap, tooltip = ttSource)
int atrLength = input.int(14, "ATR Length", minval = 2, maxval = 200, group = groupVwap, tooltip = ttAtr)
float minVolume = input.float(0.0, "Minimum Volume Filter", minval = 0.0, maxval = 1000000000.0, step = 1.0, group = groupVwap, tooltip = ttMinVol)
bool confirmOnClose = input.bool(true, "Confirm On Bar Close", group = groupVwap, tooltip = ttConfirmClose)

string groupScore = "Reclaim Engine"
string confirmationMode = input.string("Balanced", "Confirmation Mode", options = ["Fast", "Balanced", "Strict"], group = groupScore, tooltip = ttConfirm)
int minReadyScore = input.int(62, "Minimum Ready Score", minval = 1, maxval = 100, group = groupScore, tooltip = ttReady)
int watchScore = input.int(48, "Pullback Watch Score", minval = 1, maxval = 100, group = groupScore, tooltip = ttWatch)
int pullbackLookback = input.int(48, "Pullback Lookback Bars", minval = 5, maxval = 500, group = groupScore, tooltip = ttLookback)
float pullbackDepthAtr = input.float(0.28, "Pullback Pocket ATR", minval = 0.03, maxval = 5.00, step = 0.01, group = groupScore, tooltip = ttPocket)
float reclaimBufferAtr = input.float(0.03, "Reclaim Buffer ATR", minval = 0.00, maxval = 3.00, step = 0.01, group = groupScore, tooltip = ttReclaim)
float invalidationAtr = input.float(0.26, "Invalidation Shelf ATR", minval = 0.03, maxval = 5.00, step = 0.01, group = groupScore, tooltip = ttInvalid)
int reclaimWindowBars = input.int(90, "Reclaim Window Bars", minval = 5, maxval = 600, group = groupScore, tooltip = ttWindow)
float targetOneAtr = input.float(0.90, "Target 1 ATR", minval = 0.10, maxval = 20.0, step = 0.05, group = groupScore, tooltip = ttTargetOne)
float targetTwoAtr = input.float(1.60, "Target 2 ATR", minval = 0.10, maxval = 30.0, step = 0.05, group = groupScore, tooltip = ttTargetTwo)
bool useVolumeScore = input.bool(true, "Use Relative Volume In Score", group = groupScore, tooltip = ttVolScore)
int volumeLength = input.int(20, "Relative Volume Length", minval = 2, maxval = 200, group = groupScore, tooltip = ttVolLen)

string groupVisual = "Chart Visuals"
bool showVWAP = input.bool(true, "Show VWAP", group = groupVisual, tooltip = ttShowVwap)
bool showPullbackPocket = input.bool(true, "Show Pullback Pocket", group = groupVisual, tooltip = ttShowPocket)
bool showReclaimCorridor = input.bool(true, "Show Reclaim Corridor", group = groupVisual, tooltip = ttShowCorridor)
bool showInvalidationShelf = input.bool(true, "Show Invalidation Shelf", group = groupVisual, tooltip = ttShowShelf)
bool showTargetRails = input.bool(true, "Show Target Rails", group = groupVisual, tooltip = ttShowTargets)
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupVisual, tooltip = ttLabels)
bool showPullbackLabels = input.bool(true, "Show Pullback Watch Labels", group = groupVisual, tooltip = ttWatchLabels)
bool showInvalidLabels = input.bool(true, "Show Invalidation Labels", group = groupVisual, tooltip = ttInvalidLabels)
bool showRightTags = input.bool(true, "Show Right-Side Tags", group = groupVisual, tooltip = ttTags)
bool showBarColors = input.bool(false, "Color Bars By State", group = groupVisual, tooltip = ttBars)
int projectionBars = input.int(42, "Projection Bars", minval = 10, maxval = 180, group = groupVisual, tooltip = ttProjection)
string labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual, tooltip = ttLabelSize)
float labelOffsetAtr = input.float(1.10, "Label Offset ATR", minval = 0.05, maxval = 5.00, step = 0.05, group = groupVisual, tooltip = ttOffset)
int minimumLabelScore = input.int(70, "Minimum Historical Label Score", minval = 1, maxval = 100, group = groupVisual, tooltip = ttMinLabelScore)
int maxEventLabels = input.int(8, "Max Visible Labels", minval = 2, maxval = 80, group = groupVisual, tooltip = ttMaxLabels)
int labelCooldownBars = input.int(50, "Event Label Cooldown", minval = 1, maxval = 120, group = groupVisual, tooltip = ttCooldown)
int watchSpacingBars = input.int(55, "Watch Label Spacing", minval = 4, maxval = 160, group = groupVisual, tooltip = ttWatchSpacing)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttPanel)
string panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLoc)
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
string panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelSize)

string groupAlerts = "Alerts"
bool alertReady = input.bool(true, "Alert: VWAP Reclaim Ready", group = groupAlerts, tooltip = ttAlertReady)
bool alertWatch = input.bool(false, "Alert: VWAP Pullback Watch", group = groupAlerts, tooltip = ttAlertWatch)
bool alertInvalidated = input.bool(true, "Alert: VWAP Reclaim Invalidated", group = groupAlerts, tooltip = ttAlertInvalid)

string groupProof = "Proof"
bool showProof = input.bool(true, "Show Proof Layer", group = groupProof, tooltip = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across READY reclaims on the current symbol and timeframe. Follow means price reached the first target rail before the invalidation shelf. These are historical outcome rates, not predictions.")
int proofReactBars = input.int(3, "Reaction Window Bars", minval = 1, maxval = 40, group = groupProof, tooltip = "Number of bars after a READY reclaim used to detect an immediate favorable reaction toward the first target rail.")
float proofReactProgressPct = input.float(40.0, "Reaction Progress %", minval = 5.0, maxval = 90.0, step = 1.0, group = groupProof, tooltip = "Minimum favorable progress toward the first target rail, within the reaction window, required to count as an early React.")

// -------------------------------------------------
// VWAP calculations
// -------------------------------------------------
float atrRaw = ta.atr(atrLength)
float atr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
float volumeNow = nz(volume, 0.0)
float volAvg = ta.sma(volumeNow, volumeLength)
float rvol = volAvg > 0.0 ? volumeNow / volAvg : 1.0
bool volumeOk = minVolume <= 0.0 or volumeNow >= minVolume

bool anchorReset = anchorMode == "Session" ? ta.change(time("D")) != 0 : anchorMode == "Week" ? ta.change(time("W")) != 0 : ta.change(time("M")) != 0

var float cumPV = na
var float cumV = na
if barstate.isfirst or anchorReset or na(cumPV) or na(cumV)
    cumPV := src * volumeNow
    cumV := volumeNow
else
    cumPV += src * volumeNow
    cumV += volumeNow

float vwap = cumV > 0.0 ? cumPV / cumV : na
bool vwapValid = not na(vwap) and atr > 0.0 and cumV > 0.0
bool confirmedBar = not confirmOnClose or barstate.isconfirmed
float vwapSlope = vwapValid and not na(vwap[3]) ? vwap - vwap[3] : 0.0
float pocketDepth = atr * pullbackDepthAtr
float reclaimBuffer = atr * reclaimBufferAtr

vwapPlot = plot(showVWAP and vwapValid ? vwap : na, title = "VWAP", color = color.new(accentColor, 0), linewidth = 2)
upperPocketPlot = plot(showVWAP and vwapValid ? vwap + pocketDepth : na, title = "VWAP Upper Pocket", color = color.new(bullColor, 70), linewidth = 1)
lowerPocketPlot = plot(showVWAP and vwapValid ? vwap - pocketDepth : na, title = "VWAP Lower Pocket", color = color.new(bearColor, 70), linewidth = 1)
fill(upperPocketPlot, lowerPocketPlot, title = "VWAP Pullback Pocket Fill", color = showVWAP and showPullbackPocket and vwapValid ? color.new(accentColor, 94) : na)

bool bullPullback = vwapValid and low <= vwap - pocketDepth
bool bearPullback = vwapValid and high >= vwap + pocketDepth
int barsSinceBullPullback = ta.barssince(bullPullback)
int barsSinceBearPullback = ta.barssince(bearPullback)
bool bullPullbackRecent = not na(barsSinceBullPullback) and barsSinceBullPullback <= pullbackLookback
bool bearPullbackRecent = not na(barsSinceBearPullback) and barsSinceBearPullback <= pullbackLookback
bool pullbackWatch = vwapValid and (bullPullback or bearPullback)
bool pullbackWatchEvent = confirmedBar and pullbackWatch and not pullbackWatch[1]

bool bullReclaim = vwapValid and volumeOk and bullPullbackRecent and close > vwap + reclaimBuffer and close[1] <= vwap
bool bearReclaim = vwapValid and volumeOk and bearPullbackRecent and close < vwap - reclaimBuffer and close[1] >= vwap
int reclaimDirNow = bullReclaim ? 1 : bearReclaim ? -1 : 0
bool reclaimEvent = reclaimDirNow != 0

// -------------------------------------------------
// Reclaim scoring
// -------------------------------------------------
float rangeSize = math.max(high - low, syminfo.mintick)
int dirForScore = reclaimDirNow != 0 ? reclaimDirNow : close >= vwap ? 1 : -1
float closeDistanceAtr = vwapValid ? (dirForScore == 1 ? (close - vwap) / atr : (vwap - close) / atr) : 0.0
int pullbackBars = dirForScore == 1 ? barsSinceBullPullback : barsSinceBearPullback
float pullbackFresh = na(pullbackBars) ? 0.0 : f_clamp(1.0 - pullbackBars / math.max(pullbackLookback, 1), 0.0, 1.0)
float wickResponse = dirForScore == 1 ? (math.min(open, close) - low) / rangeSize : (high - math.max(open, close)) / rangeSize
float bodyRatio = math.abs(close - open) / rangeSize
bool slopeAlign = dirForScore == 1 ? vwapSlope >= 0.0 : vwapSlope <= 0.0

float closeScore = f_clamp(closeDistanceAtr / 0.70, 0.0, 1.0) * 24.0
float pullbackScore = pullbackFresh * 18.0
float wickScore = f_clamp(wickResponse / 0.55, 0.0, 1.0) * 18.0
float bodyScore = f_clamp(bodyRatio / 0.65, 0.0, 1.0) * 12.0
float volumeScore = useVolumeScore ? f_clamp(rvol / 1.6, 0.0, 1.0) * 12.0 : 8.0
float slopeScore = (slopeAlign ? 1.0 : 0.35) * 8.0
float distanceScore = f_clamp(math.abs(close - vwap) / math.max(atr * 1.2, syminfo.mintick), 0.0, 1.0) * 8.0
float candidateScore = vwapValid ? f_clamp(closeScore + pullbackScore + wickScore + bodyScore + volumeScore + slopeScore + distanceScore, 0.0, 100.0) : na
float confirmAdjust = confirmationMode == "Fast" ? -5.0 : confirmationMode == "Strict" ? 8.0 : 0.0
int requiredScore = int(math.round(f_clamp(minReadyScore + confirmAdjust, 1.0, 100.0)))
bool readyEvent = confirmedBar and reclaimEvent and candidateScore >= requiredScore
float pullbackQuality = f_clamp((pullbackScore + wickScore + closeScore) / 60.0 * 100.0, 0.0, 100.0)
bool watchScoreReady = pullbackWatch and pullbackQuality >= watchScore

// -------------------------------------------------
// Active reclaim state
// -------------------------------------------------
var int activeDir = 0
var int reclaimBar = na
var float reclaimVwap = na
var float reclaimAtr = na
var float activeScore = na
var bool activeReclaim = false
var bool t1Reached = false
var bool t2Reached = false
var int lastReadyLabelBar = na
var int lastWatchLabelBar = na
var int lastInvalidLabelBar = na

if readyEvent
    activeDir := reclaimDirNow
    reclaimBar := bar_index
    reclaimVwap := vwap
    reclaimAtr := atr
    activeScore := candidateScore
    activeReclaim := true
    t1Reached := false
    t2Reached := false

int barsFromReclaim = activeReclaim and not na(reclaimBar) ? bar_index - reclaimBar : na
bool withinWindow = activeReclaim and not na(barsFromReclaim) and barsFromReclaim <= reclaimWindowBars
float invalidLine = activeDir == 1 ? reclaimVwap - reclaimAtr * invalidationAtr : activeDir == -1 ? reclaimVwap + reclaimAtr * invalidationAtr : na
bool invalidatedEvent = confirmedBar and withinWindow and not t2Reached and ((activeDir == 1 and close < invalidLine) or (activeDir == -1 and close > invalidLine))
bool expired = activeReclaim and not withinWindow

float t1 = activeDir == 1 ? reclaimVwap + reclaimAtr * targetOneAtr : activeDir == -1 ? reclaimVwap - reclaimAtr * targetOneAtr : na
float t2 = activeDir == 1 ? reclaimVwap + reclaimAtr * targetTwoAtr : activeDir == -1 ? reclaimVwap - reclaimAtr * targetTwoAtr : na
bool t1ReachedEvent = confirmedBar and withinWindow and not t1Reached and (activeDir == 1 ? close >= t1 : close <= t1)
bool t2ReachedEvent = confirmedBar and withinWindow and not t2Reached and (activeDir == 1 ? close >= t2 : close <= t2)
if t1ReachedEvent
    t1Reached := true
if t2ReachedEvent
    t1Reached := true
    t2Reached := true
float roomToT1Atr = withinWindow and not na(t1) ? activeDir == 1 ? math.max((t1 - close) / atr, 0.0) : math.max((close - t1) / atr, 0.0) : na
float roomToT2Atr = withinWindow and not na(t2) ? activeDir == 1 ? math.max((t2 - close) / atr, 0.0) : math.max((close - t2) / atr, 0.0) : na

string actionState = "WAIT"
string vwapState = "VWAP Ready"
string reclaimBias = "Neutral"
string roomText = "-"
float panelScore = na
float panelPullback = na

if not vwapValid
    actionState := "BLOCKED"
    vwapState := "VWAP Blocked"
    reclaimBias := "Neutral"
    roomText := "-"
    panelScore := na
    panelPullback := na
else if readyEvent
    actionState := "READY"
    vwapState := activeDir == 1 ? "Bull Reclaim" : "Bear Reclaim"
    reclaimBias := activeDir == 1 ? "Bullish" : "Bearish"
    roomText := "Fresh"
    panelScore := candidateScore
    panelPullback := pullbackQuality
else if invalidatedEvent
    actionState := "INVALIDATED"
    vwapState := "Reclaim Failed"
    reclaimBias := activeDir == 1 ? "Bull Failed" : "Bear Failed"
    roomText := "-"
    panelScore := activeScore
    panelPullback := pullbackQuality
else if withinWindow and t2Reached
    actionState := "TARGET 2"
    vwapState := activeDir == 1 ? "Bull T2 Reached" : "Bear T2 Reached"
    reclaimBias := activeDir == 1 ? "Bullish" : "Bearish"
    roomText := "Complete"
    panelScore := activeScore
    panelPullback := pullbackQuality
else if withinWindow and t1Reached
    actionState := "TARGET 1"
    vwapState := activeDir == 1 ? "Bull T1 Reached" : "Bear T1 Reached"
    reclaimBias := activeDir == 1 ? "Bullish" : "Bearish"
    roomText := "T2 " + f_atr_text(roomToT2Atr)
    panelScore := activeScore
    panelPullback := pullbackQuality
else if withinWindow
    actionState := "MONITOR"
    vwapState := "Reclaim Active"
    reclaimBias := activeDir == 1 ? "Bullish" : activeDir == -1 ? "Bearish" : "Neutral"
    roomText := f_atr_text(roomToT1Atr)
    panelScore := activeScore
    panelPullback := pullbackQuality
else if watchScoreReady
    actionState := "MONITOR"
    vwapState := "Pullback Watch"
    reclaimBias := bullPullback ? "Bull Watch" : "Bear Watch"
    roomText := "-"
    panelScore := na
    panelPullback := pullbackQuality
else
    actionState := "WAIT"
    vwapState := "VWAP Ready"
    reclaimBias := "Neutral"
    roomText := "-"
    panelScore := na
    panelPullback := na

if invalidatedEvent or expired
    activeReclaim := false

// -------------------------------------------------
// Confirmation-anchored proof (READY reclaims: Follow = first target rail reached before invalidation shelf)
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

int proofWarmup = atrLength + volumeLength + 5
bool proofTargetAhead = reclaimDirNow == 1 ? close < t1 : reclaimDirNow == -1 ? close > t1 : false
bool reclaimReadyAnchor = barstate.isconfirmed and readyEvent and reclaimDirNow != 0 and not na(t1) and not na(invalidLine) and proofTargetAhead
if barstate.isconfirmed and bar_index > proofWarmup
    if pEvalActive
        int heldBars = bar_index - pEvalStart
        float followDist = math.max(math.abs(pEvalTarget - pEvalEntry), syminfo.mintick)
        float favExc = pEvalDir * (close - pEvalEntry)
        if heldBars >= 1 and heldBars <= proofReactBars and favExc >= followDist * proofReactProgressPct / 100.0
            pReacted := true
        bool stopBreached = pEvalDir == 1 ? close < pEvalStop : close > pEvalStop
        bool hitTarget = heldBars >= 1 and favExc >= followDist
        if stopBreached
            pFlipped := true
        bool followNow = hitTarget and not pFlipped
        if followNow
            pFollowed := true
        bool naturalResolve = pFlipped or followNow or heldBars >= reclaimWindowBars
        if naturalResolve or reclaimReadyAnchor
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
    if reclaimReadyAnchor and not pEvalActive
        pEvalActive := true
        pEvalDir := reclaimDirNow
        pEvalEntry := close
        pEvalStop := invalidLine
        pEvalTarget := t1
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false
        pFlipped := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float proofFlipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0
string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) : "building"

// -------------------------------------------------
// Visuals
// -------------------------------------------------
var box corridorBox = na
var label corridorLabel = na
var box invalidBox = na
var label invalidShelfBadge = na
var line t1Line = na
var line t2Line = na
var label tagVwap = na
var label tagT1 = na
var label tagT2 = na
var array<label> eventLabels = array.new_label()

int safeProjectionBars = math.min(projectionBars, 180)
int rightX = bar_index + safeProjectionBars
color visualColor = activeDir == 1 ? bullColor : activeDir == -1 ? bearColor : accentColor
float corridorTop = activeDir == 1 ? t1 : reclaimVwap
float corridorBottom = activeDir == 1 ? reclaimVwap : t1
string corridorStage = t2Reached ? "T2 REACHED" : t1Reached ? "T1 REACHED" : "RECLAIM ACTIVE"
string corridorText = withinWindow ? (activeDir == 1 ? "BULL | " : "BEAR | ") + corridorStage + " | Q " + str.tostring(math.round(nz(activeScore, candidateScore))) + " | A " + str.tostring(barsFromReclaim) : ""
int corridorMidX = not na(reclaimBar) ? int(math.round((reclaimBar + rightX) * 0.50)) : bar_index
float corridorMidY = not na(corridorTop) and not na(corridorBottom) ? (corridorTop + corridorBottom) * 0.50 : vwap

if showReclaimCorridor and withinWindow and not na(corridorTop) and not na(corridorBottom)
    if na(corridorBox)
        corridorBox := box.new(left = reclaimBar, top = corridorTop, right = rightX, bottom = corridorBottom, xloc = xloc.bar_index, bgcolor = color.new(visualColor, 91), border_color = color.new(visualColor, 36), border_width = 1)
    else
        box.set_lefttop(corridorBox, reclaimBar, corridorTop)
        box.set_rightbottom(corridorBox, rightX, corridorBottom)
        box.set_bgcolor(corridorBox, color.new(visualColor, 91))
        box.set_border_color(corridorBox, color.new(visualColor, 36))
    if na(corridorLabel)
        corridorLabel := label.new(corridorMidX, corridorMidY, corridorText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = headerText, color = color.new(visualColor, 0), size = f_text_size(labelSizeInput), textalign = text.align_center)
    else
        label.set_x(corridorLabel, corridorMidX)
        label.set_y(corridorLabel, corridorMidY)
        label.set_text(corridorLabel, corridorText)
        label.set_textcolor(corridorLabel, headerText)
        label.set_color(corridorLabel, color.new(visualColor, 0))
        label.set_size(corridorLabel, f_text_size(labelSizeInput))
else
    if not na(corridorBox)
        box.delete(corridorBox)
        corridorBox := na
    if not na(corridorLabel)
        label.delete(corridorLabel)
        corridorLabel := na

float invalidTop = activeDir == 1 ? reclaimVwap : invalidLine
float invalidBottom = activeDir == 1 ? invalidLine : reclaimVwap
float invalidMidY = not na(invalidTop) and not na(invalidBottom) ? (invalidTop + invalidBottom) * 0.50 : na
int invalidMidX = not na(reclaimBar) ? int(math.round((reclaimBar + rightX) * 0.50)) : bar_index
string invalidShelfText = activeDir == 1 ? "BULL FAIL < " + str.tostring(invalidLine, format.mintick) : activeDir == -1 ? "BEAR FAIL > " + str.tostring(invalidLine, format.mintick) : "RISK SHELF"
if showInvalidationShelf and withinWindow and not t2Reached and not na(invalidTop) and not na(invalidBottom)
    if na(invalidBox)
        invalidBox := box.new(left = reclaimBar, top = invalidTop, right = rightX, bottom = invalidBottom, xloc = xloc.bar_index, bgcolor = color.new(dangerColor, 93), border_color = color.new(dangerColor, 42), border_width = 1)
    else
        box.set_lefttop(invalidBox, reclaimBar, invalidTop)
        box.set_rightbottom(invalidBox, rightX, invalidBottom)
        box.set_bgcolor(invalidBox, color.new(dangerColor, 93))
        box.set_border_color(invalidBox, color.new(dangerColor, 42))
    if na(invalidShelfBadge)
        invalidShelfBadge := label.new(invalidMidX, invalidMidY, invalidShelfText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = headerText, color = color.new(dangerColor, 0), size = f_text_size(labelSizeInput), textalign = text.align_center)
    else
        label.set_x(invalidShelfBadge, invalidMidX)
        label.set_y(invalidShelfBadge, invalidMidY)
        label.set_text(invalidShelfBadge, invalidShelfText)
        label.set_textcolor(invalidShelfBadge, headerText)
        label.set_color(invalidShelfBadge, color.new(dangerColor, 0))
        label.set_size(invalidShelfBadge, f_text_size(labelSizeInput))
else
    if not na(invalidBox)
        box.delete(invalidBox)
        invalidBox := na
    if not na(invalidShelfBadge)
        label.delete(invalidShelfBadge)
        invalidShelfBadge := na

if showTargetRails and withinWindow and not na(t1) and not na(t2)
    if na(t1Line)
        t1Line := line.new(x1 = reclaimBar, y1 = t1, x2 = rightX, y2 = t1, xloc = xloc.bar_index, color = color.new(neutralColor, 10), width = 1, style = line.style_dashed)
    else
        line.set_xy1(t1Line, reclaimBar, t1)
        line.set_xy2(t1Line, rightX, t1)
    if na(t2Line)
        t2Line := line.new(x1 = reclaimBar, y1 = t2, x2 = rightX, y2 = t2, xloc = xloc.bar_index, color = color.new(accentColor, 12), width = 1, style = line.style_dashed)
    else
        line.set_xy1(t2Line, reclaimBar, t2)
        line.set_xy2(t2Line, rightX, t2)
else
    if not na(t1Line)
        line.delete(t1Line)
        t1Line := na
    if not na(t2Line)
        line.delete(t2Line)
        t2Line := na

bool canReadyLabel = na(lastReadyLabelBar) or bar_index - lastReadyLabelBar >= labelCooldownBars
bool canWatchLabel = na(lastWatchLabelBar) or bar_index - lastWatchLabelBar >= watchSpacingBars
bool canInvalidLabel = na(lastInvalidLabelBar) or bar_index - lastInvalidLabelBar >= labelCooldownBars
float labelLowAnchor = ta.lowest(low, 4)
float labelHighAnchor = ta.highest(high, 4)
float labelBelowY = labelLowAnchor - atr * labelOffsetAtr
float labelAboveY = labelHighAnchor + atr * labelOffsetAtr

if showEventLabels and readyEvent and candidateScore >= minimumLabelScore and canReadyLabel
    label readyLabel = label.new(bar_index, activeDir == 1 ? labelBelowY : labelAboveY, (activeDir == 1 ? "BULL READY | Q " : "BEAR READY | Q ") + str.tostring(math.round(candidateScore)), xloc = xloc.bar_index, yloc = yloc.price, style = activeDir == 1 ? label.style_label_up : label.style_label_down, textcolor = headerText, color = color.new(activeDir == 1 ? bullColor : bearColor, 0), size = f_text_size(labelSizeInput), textalign = text.align_center)
    lastReadyLabelBar := bar_index
    array.push(eventLabels, readyLabel)
    f_trim_labels(eventLabels, maxEventLabels)

if showEventLabels and showPullbackLabels and confirmedBar and watchScoreReady and pullbackQuality >= minimumLabelScore and not readyEvent and canWatchLabel
    bool watchBelow = bullPullback
    label watchLabel = label.new(bar_index, watchBelow ? labelBelowY : labelAboveY, "PB WATCH | Q " + str.tostring(math.round(pullbackQuality)), xloc = xloc.bar_index, yloc = yloc.price, style = watchBelow ? label.style_label_up : label.style_label_down, textcolor = headerText, color = color.new(neutralColor, 0), size = f_text_size(labelSizeInput), textalign = text.align_center)
    lastWatchLabelBar := bar_index
    array.push(eventLabels, watchLabel)
    f_trim_labels(eventLabels, maxEventLabels)

if showEventLabels and showInvalidLabels and invalidatedEvent and canInvalidLabel
    label invalidLabel = label.new(bar_index, activeDir == 1 ? labelAboveY : labelBelowY, "VWAP FAILED", xloc = xloc.bar_index, yloc = yloc.price, style = activeDir == 1 ? label.style_label_down : label.style_label_up, textcolor = headerText, color = color.new(dangerColor, 0), size = f_text_size(labelSizeInput), textalign = text.align_center)
    lastInvalidLabelBar := bar_index
    array.push(eventLabels, invalidLabel)
    f_trim_labels(eventLabels, maxEventLabels)

if barstate.islast and showRightTags and vwapValid
    int tagX = withinWindow ? math.min(rightX + 2, bar_index + 190) : bar_index + 4
    int tagT1X = math.min(tagX + 2, bar_index + 194)
    int tagT2X = math.min(tagX + 5, bar_index + 197)
    if not na(tagVwap)
        label.delete(tagVwap)
    if not na(tagT1)
        label.delete(tagT1)
    if not na(tagT2)
        label.delete(tagT2)
    bool showMainVwapTag = not withinWindow
    if showMainVwapTag
        tagVwap := label.new(tagX, vwap, "VWAP " + str.tostring(vwap, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = headerText, color = color.new(accentColor, 12), size = f_text_size(labelSizeInput))
    if withinWindow and not na(t1) and not na(t2)
        string t1TagText = "T1" + (t1Reached ? " HIT " : " ") + str.tostring(t1, format.mintick)
        string t2TagText = "T2" + (t2Reached ? " HIT " : " ") + str.tostring(t2, format.mintick)
        tagT1 := label.new(tagT1X, t1, t1TagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = f_text_on(t1Reached ? visualColor : neutralColor), color = color.new(t1Reached ? visualColor : neutralColor, 4), size = f_text_size(labelSizeInput))
        tagT2 := label.new(tagT2X, t2, t2TagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = f_text_on(visualColor), color = color.new(visualColor, 4), size = f_text_size(labelSizeInput))
else if barstate.islast
    if not na(tagVwap)
        label.delete(tagVwap)
        tagVwap := na
    if not na(tagT1)
        label.delete(tagT1)
        tagT1 := na
    if not na(tagT2)
        label.delete(tagT2)
        tagT2 := na

// -------------------------------------------------
// Data Window
// -------------------------------------------------
plot(candidateScore, title = "VWAP Reclaim Score", color = f_score_color(candidateScore, requiredScore, watchScore), display = display.data_window)
plot(pullbackQuality, title = "Pullback Quality", color = neutralColor, display = display.data_window)
plot(rvol, title = "Relative Volume", color = panelValueCol, display = display.data_window)
plot(closeDistanceAtr, title = "Close Distance From VWAP ATR", color = accentColor, display = display.data_window)
plot(roomToT1Atr, title = "Room To T1 ATR", color = bullColor, display = display.data_window)

// -------------------------------------------------
// Panel
// -------------------------------------------------
string scoreText = f_score_text(panelScore)
string pullbackText = na(panelPullback) ? "-" : f_score_text(panelPullback)
string qualityText = scoreText + " | PB " + pullbackText
string ageText = withinWindow ? roomText + " | " + str.tostring(barsFromReclaim) + "/" + str.tostring(reclaimWindowBars) : "-"
string workflowText = actionState + " | " + reclaimBias
string followHoldText = proofTotal > 0 ? f_rate_pct(followRate) + " / " + f_rate_pct(holdRate) : "-"
string reactFlipText = proofTotal > 0 ? f_rate_pct(reactRate) + " / " + f_rate_pct(proofFlipRate) : "-"
color scoreColor = f_score_color(panelScore, requiredScore, watchScore)
color pullbackColor = na(panelPullback) ? f_panel_value(panelTheme) : panelPullback >= watchScore ? neutralColor : f_panel_value(panelTheme)
color actionColor = f_action_color(actionState, activeDir)

var table panel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""
var bool lastProofMode = false
int panelRowCount = showProof ? 8 : 5

if barstate.islast
    if showPanel
        if na(panel) or panelLocationInput != lastPanelLocation or panelTheme != lastPanelTheme or showProof != lastProofMode
            if not na(panel)
                table.delete(panel)
            panel := table.new(f_panel_position(panelLocationInput), 2, panelRowCount, bgcolor = f_panel_bg(panelTheme), frame_color = f_panel_border(panelTheme), frame_width = 1, border_color = f_panel_border(panelTheme), border_width = 1)
            lastPanelLocation := panelLocationInput
            lastPanelTheme := panelTheme
            lastProofMode := showProof
        table.clear(panel, 0, 0, 1, panelRowCount - 1)
        table.cell(panel, 0, 0, "", bgcolor = headerBg)
        table.cell(panel, 1, 0, "", bgcolor = headerBg)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro VWAP Pullback Reclaim Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSizeInput), text_halign = text.align_center)
        f_panel_row(panel, 1, "State", vwapState, actionColor, panelTheme, panelFontSizeInput)
        f_panel_row(panel, 2, "Quality / Pullback", qualityText, scoreColor, panelTheme, panelFontSizeInput)
        f_panel_row(panel, 3, "Room / Age", ageText, withinWindow ? visualColor : f_panel_value(panelTheme), panelTheme, panelFontSizeInput)
        f_panel_row(panel, 4, "Workflow", workflowText, actionColor, panelTheme, panelFontSizeInput)
        if showProof
            f_panel_row(panel, 5, "Proof Sample", proofSampleText, accentColor, panelTheme, panelFontSizeInput)
            f_panel_row(panel, 6, "Follow / Hold", followHoldText, proofTotal > 0 ? f_rate_color(followRate) : f_panel_value(panelTheme), panelTheme, panelFontSizeInput)
            f_panel_row(panel, 7, "React / Flip", reactFlipText, proofTotal > 0 ? f_flip_color(proofFlipRate) : f_panel_value(panelTheme), panelTheme, panelFontSizeInput)
    else if not na(panel)
        table.delete(panel)
        panel := na
        lastPanelLocation := ""
        lastPanelTheme := ""

// -------------------------------------------------
// Bar color and alerts
// -------------------------------------------------
int visualStateDir = withinWindow ? activeDir : close >= vwap ? 1 : -1
color barStateColor = actionState == "READY" ? color.new(activeDir == 1 ? bullColor : bearColor, 76) : actionState == "MONITOR" ? color.new(visualStateDir == 1 ? bullColor : bearColor, 84) : actionState == "INVALIDATED" ? color.new(dangerColor, 80) : na
barcolor(showBarColors ? barStateColor : na)

alertcondition(alertReady and readyEvent and activeDir == 1, "Bullish VWAP Reclaim Ready", "VWAP Pullback Reclaim Planner: bullish VWAP reclaim reached READY context. This is an attention marker, not a trade instruction.")
alertcondition(alertReady and readyEvent and activeDir == -1, "Bearish VWAP Reclaim Ready", "VWAP Pullback Reclaim Planner: bearish VWAP reclaim reached READY context. This is an attention marker, not a trade instruction.")
alertcondition(alertWatch and pullbackWatchEvent, "VWAP Pullback Watch", "VWAP Pullback Reclaim Planner: price entered the VWAP pullback pocket on a confirmed event.")
alertcondition(alertInvalidated and invalidatedEvent, "VWAP Reclaim Invalidated", "VWAP Pullback Reclaim Planner: reclaim lost VWAP acceptance after an active reclaim context.")

// -------------------------------------------------
// Hidden Proof Exports
// -------------------------------------------------
plot(followRate, title = "VPR Follow Rate", display = display.none)
plot(holdRate, title = "VPR Hold Rate", display = display.none)
plot(reactRate, title = "VPR React Rate", display = display.none)
plot(proofFlipRate, title = "VPR Flip Rate", display = display.none)
````
