# Prior Close Reclaim Planner [AGPro Series]

- url: https://www.tradingview.com/script/fyiYpKaP-Prior-Close-Reclaim-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;740437364b474ea49d9d52fc5434156e
- version: 5.0

## Description

Prior Close Reclaim Planner [AGPro Series]

🧠 Core Idea

Is the prior close being reclaimed, rejected, or treated as a live magnet by the current market?


📌 Overview / What it does

Prior Close Reclaim Planner [AGPro Series] maps the completed prior close as a live support/resistance reference and evaluates how price reacts around that level.

The script displays a prior-close rail, an ATR-based reclaim pocket, reclaim labels, rejection labels, magnet-zone labels, right-side reference tags, and a compact AG Pro dashboard with a 0-100 reclaim score.

It does not predict where price will go next. It helps organize the reaction around the previous close: reclaim quality, rejection pressure, magnet risk, rail state, and action context.


🎯 Purpose & Design Philosophy

The previous close is one of the simplest reference levels on a chart, but it is often read too casually.

This script was built to turn that reference into a structured planning map. It helps traders see whether the prior close is acting as support, resistance, a magnet, or a failed reclaim zone.

The design supports a patient decision-support mindset: read the rail, evaluate the reaction, check the score, and place the output inside broader market context.


⚡ Why This Script Is Different

Most tools draw a prior close line and stop there.

This script does NOT treat the prior close as a passive horizontal level.

Instead, it builds an active reclaim planner with a pocket, reaction labels, magnet context, relative-volume support, volatility fit, a readiness score, and a clear action state.


⚙️ Methodology

1. Prior Close Detection

The script sources the completed prior close from the selected reference timeframe. Daily is the default setting for previous-session analysis.

2. Reclaim Pocket Mapping

An ATR-based pocket is created above and below the prior close. This pocket is used to avoid overreacting to tiny ticks around the rail.

3. Reaction Evaluation

The script evaluates close location, wick response, relative volume, distance from the rail, and volatility fit.

4. Visual Output

The chart receives the rail, pocket, labels, right-side tags, bar coloring if enabled, and a dashboard panel summarizing the current state.


🗺️ How to Read the Chart

The central rail shows the completed prior close.

The pocket around the rail shows where reclaim and rejection behavior is evaluated.

Labels highlight bullish reclaim, bearish reclaim, rail defense, rail rejection, magnet-zone entries, and failed reclaim behavior.

Colors represent context:

• Teal → bullish reclaim or defense

• Pink → bearish reclaim or rejection

• Gold → neutral or waiting context

• Indigo → magnet or monitoring context

The panel summarizes:

• Prior Close

• Reclaim Score

• Magnet Risk

• Rail State

• Action


🚦 Signals & States

• Bull Prior Close Reclaim → price closed above the reclaim pocket

• Bear Prior Close Reclaim → price closed below the reclaim pocket

• Rail Defense → price tested the pocket and closed back above it

• Rail Rejection → price tested the pocket and closed back below it

• Magnet Zone → price is close enough to the prior close to treat the rail as active

• Invalidated → a reclaim attempt failed back through the prior-close rail

• READY → reclaim/rejection quality is strong enough to monitor

• MONITOR → price is near the rail, but conditions are not fully ready

• WAIT → no strong prior-close reaction is active


🔔 Alerts Logic

Alerts can trigger when price reclaims the prior close pocket, rejects the pocket, enters the magnet zone, reaches READY conditions, or invalidates a reclaim attempt.

Alerts are attention markers only. They are not trade instructions.


🧩 Confluence Logic

The prior-close context becomes stronger when close location, wick response, relative volume, volatility fit, and distance from the rail align.

For example, a reclaim with strong close quality, acceptable volume, and controlled distance from the rail is more structured than a weak close far from the reference.


📊 When to Use

• Intraday trading around the previous session close

• Session reclaim or rejection analysis

• Support/resistance reaction planning

• Trending markets that retest the prior close

• Range conditions where the prior close acts as a magnet

• Liquid symbols with readable candles and stable spreads


⚠️ When NOT to Use

• Very low-liquidity markets

• Symbols with unreliable session structure

• Extremely noisy chop around the rail

• News candles with unstable spreads

• Markets where the selected reference timeframe is not meaningful


🎛️ Key Inputs

• Reference Timeframe → controls where the completed prior close comes from

• Reclaim Pocket ATR → controls the width of the reaction pocket around the rail

• Magnet Distance ATR → controls when price is treated as close enough to the rail

• Minimum Ready Score → controls the score required for READY state

• Relative Volume Length → controls participation comparison

• Confirmation Mode → controls how strict reclaim/rejection evaluation should be

• Visual settings → control rails, pockets, labels, tags, bar colors, and dashboard behavior


🖥️ Interface & Visual Design

The interface is built for fast chart reading.

The prior close rail creates the main reference, the pocket defines the active reaction area, labels mark important events, and the panel compresses the state into a clean decision-support dashboard.

The goal is a premium, readable chart without turning the prior close into a cluttered signal board.


🧪 Practical Usage Workflow

1. Read the panel action state

2. Check whether price is above, below, or inside the prior-close pocket

3. Evaluate reclaim or rejection labels

4. Compare score quality with magnet risk

5. Confirm the context with broader structure, volume, and timeframe alignment


🔍 Interpretation Guidelines

A READY state means the prior-close reaction has enough structure to monitor.

Magnet risk means price is still close enough to the rail for the prior close to matter.

A reclaim label means the market crossed beyond the pocket, not that continuation is guaranteed.

A rejection or defense label means price reacted at the rail, but the broader trend and volatility context still matter.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not a guaranteed prior-close trading system.

It is not an automated trading tool.

It does not provide financial advice.

It does not guarantee continuation, reversal, profit, or a specific target.


⚠️ Limitations & Transparency

Prior-close behavior depends on market structure, volatility, liquidity, session design, and timeframe.

Different symbols may treat the previous close differently.

Very noisy markets can trigger frequent pocket interactions.

The score is a rule-based context score, not a certainty model.


🧠 Market Context Notes

The prior close often acts as a memory level.

When price reclaims it with participation, the rail may become a useful support/resistance reference.

When price repeatedly returns to it without follow-through, the rail may behave more like a magnet than a directional level.


🧾 Use Case Examples

When price opens below the prior close and later reclaims the pocket, the script marks the reclaim and scores the quality of the reaction.

When price tests the prior close from above and closes back above the pocket, the script can mark rail defense.

When price stays close to the rail without clean displacement, the panel can shift toward MONITOR instead of forcing a directional read.


🧱 System Philosophy

This script follows the AGPro Series approach: turn a familiar chart reference into a structured decision-support map.

The focus is not prediction. The focus is context, quality, invalidation awareness, and visual clarity.


🔐 Non-Promise Statement

No script can remove uncertainty from markets.

This tool does not promise accuracy, profitability, or future price movement.

Its purpose is to organize prior-close context so the user can interpret the chart more clearly.


📉 Risk Disclosure

Trading involves risk.

Market conditions can change quickly, and any analytical output can fail.

Users are responsible for their own decisions, risk management, and trade execution.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

Use the prior close as a reference, not as an automatic decision.

The best reads usually come when the rail reaction aligns with structure, liquidity, volume, and the broader market environment.

## Source Code

````pine
// -------------------------------------------------
// Prior Close Reclaim Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.3
//
// Prior Close Reclaim Planner maps the completed prior close as a live
// market-structure rail for reclaim, rejection, magnet behavior, and failure
// review. It scores reaction quality from 0-100, projects a clean prior-close
// pocket, prints compact context labels, and keeps the next review step inside
// a publication-ready AG Pro panel. Version 2.3 stabilizes the completed
// reference pocket, makes score and READY context distance-aware, and confirms
// lifecycle events on closed bars.
// -------------------------------------------------

//@version=6
indicator("Prior Close Reclaim Planner [AGPro Series]",
     shorttitle       = "AG Pro PCR",
     overlay          = true,
     max_boxes_count  = 40,
     max_lines_count  = 90,
     max_labels_count = 200)

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

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
string ttReference = "Timeframe used to source the completed prior close. Daily is the standard setting for previous-session close analysis."
string ttAtr = "ATR normalizes reclaim tolerance, distance, label spacing, and volatility context. The active pocket uses the completed ATR from the selected reference timeframe."
string ttPocket = "ATR distance above and below the prior close that forms the reclaim/rejection pocket."
string ttMagnet = "Maximum ATR distance from the prior close where price is treated as still being influenced by the rail."
string ttAge = "Maximum number of bars the current prior-close context can remain active before the panel marks it as old."
string ttReady = "Minimum 0-100 score required before a reclaim or rejection context becomes READY."
string ttWatch = "Minimum 0-100 score required before sparse magnet context labels can print."
string ttVolumeLength = "Lookback used to compare current volume against recent average volume."
string ttMinRvol = "Minimum relative volume used to avoid over-scoring very thin reclaim attempts."
string ttConfirm = "Close requires a close beyond the pocket. Wick + Close also rewards rails that were tested intrabar and then defended."
string ttRail = "Shows the completed prior close as the central reference rail."
string ttShowPocket = "Shows the ATR-based pocket around the prior close where reclaim and rejection behavior is evaluated."
string ttPocketText = "Shows compact centered text inside the prior-close pocket. Text stays single-line for cleaner publication screenshots."
string ttLabels = "Shows reclaim, rejection, magnet, and invalidation labels on the chart."
string ttReclaimLabels = "Shows labels when price reclaims the prior close pocket."
string ttRejectionLabels = "Shows labels when price rejects the prior close pocket."
string ttMagnetLabels = "Shows sparse magnet context labels so the chart does not look empty near the prior close."
string ttInvalidLabels = "Shows failed reclaim labels when an active reclaim loses the pocket."
string ttTags = "Shows compact right-side tags for the prior close and optional pocket edges."
string ttEdgeTags = "Shows separate right-side tags for upper and lower pocket edges. Disabled by default to avoid stacked tags when the pocket is narrow."
string ttBars = "Colors bars lightly according to the active prior-close state."
string ttProjection = "Number of bars used for pocket projection and right-side tag placement."
string ttCooldown = "Minimum spacing between repeated major event labels."
string ttContextSpacing = "Minimum spacing between sparse magnet context labels."
string ttMaxLabels = "Maximum historical event labels retained on the chart."
string ttOffset = "ATR-based label offset so labels remain readable above or below candles."
string ttLabelSize = "Controls chart label, centered pocket text, and right-side tag font size. Normal is the recommended publication default."
string ttPanel = "Shows or hides the AG Pro planning panel. Enabled by default for publication context."
string ttPanelLoc = "Controls panel location."
string ttPanelTheme = "Switches the panel between the premium AGPro dark theme and a clean light theme."
string ttPanelSize = "Controls panel font size. Normal is the recommended publication default."
string ttAlertReclaim = "Enables alerts when price reclaims the prior close pocket."
string ttAlertRejection = "Enables alerts when price rejects or defends the prior close pocket."
string ttAlertReady = "Enables alerts when the prior-close reaction reaches READY conditions."
string ttAlertMagnet = "Enables alerts when price enters the prior-close magnet zone."
string ttAlertInvalid = "Enables alerts when a reclaim attempt fails back through the pocket."

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(value, maxValue))

f_score(float value) =>
    int(math.round(f_clamp(value, 0.0, 100.0)))

f_grade(int score) =>
    score >= 86 ? "A+" : score >= 76 ? "A" : score >= 66 ? "B" : score >= 54 ? "C" : "D"

f_text_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_position(string posInput) =>
    switch posInput
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_text_on(color bgColor) =>
    float bright = (color.r(bgColor) * 299 + color.g(bgColor) * 587 + color.b(bgColor) * 114) / 1000
    bright >= 145 ? color.rgb(17, 24, 39) : headerText

f_reg(float x, float y, float[] bars, float[] ys) =>
    array.push(bars, x)
    array.push(ys, y)
    if array.size(bars) > 16
        array.shift(bars)
        array.shift(ys)

f_resolve_y(float x, float yBase, float dir, float sep, float[] bars, float[] ys) =>
    float y = yBase
    bool clash = true
    int g = 0
    while clash and g < 14
        clash := false
        if array.size(bars) > 0
            for i = 0 to array.size(bars) - 1
                if math.abs(x - array.get(bars, i)) <= 36 and math.abs(y - array.get(ys, i)) < sep
                    y := y + dir * sep
                    clash := true
        g += 1
    f_reg(x, y, bars, ys)
    y

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

f_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_atr_text(float value) =>
    na(value) ? "-" : str.tostring(value, "#.##") + " ATR"

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        label oldLabel = array.shift(labels)
        label.delete(oldLabel)

f_score_color(int score, int readyScore, int watchScore) =>
    score >= readyScore ? bullColor : score >= watchScore ? accentColor : score >= 40 ? neutralColor : bearColor

f_action_color(string actionText, int dir) =>
    switch actionText
        "READY" => dir == 1 ? bullColor : dir == -1 ? bearColor : bullColor
        "MONITOR" => accentColor
        "INVALIDATED" => dangerColor
        "EXPIRED" => panelBorder
        "WAIT" => neutralColor
        => panelValueCol

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupRef = "Prior Close Reference"
string referenceTf = input.timeframe("D", "Reference Timeframe", group = groupRef, tooltip = ttReference)
int atrLength = input.int(14, "ATR Length", minval = 1, maxval = 300, group = groupRef, tooltip = ttAtr)
float pocketAtr = input.float(0.18, "Reclaim Pocket ATR", minval = 0.02, maxval = 3.00, step = 0.01, group = groupRef, tooltip = ttPocket)
float magnetAtr = input.float(0.65, "Magnet Distance ATR", minval = 0.05, maxval = 6.00, step = 0.05, group = groupRef, tooltip = ttMagnet)
int maxReferenceAge = input.int(260, "Maximum Reference Age", minval = 20, maxval = 2000, group = groupRef, tooltip = ttAge)

string groupScore = "Reclaim Score"
int minReadyScore = input.int(64, "Minimum Ready Score", minval = 1, maxval = 100, group = groupScore, tooltip = ttReady)
int watchScore = input.int(48, "Magnet Watch Score", minval = 1, maxval = 100, group = groupScore, tooltip = ttWatch)
int volumeLength = input.int(24, "Relative Volume Length", minval = 5, maxval = 300, group = groupScore, tooltip = ttVolumeLength)
float minRelativeVolume = input.float(0.70, "Minimum Relative Volume", minval = 0.10, maxval = 5.00, step = 0.05, group = groupScore, tooltip = ttMinRvol)
string confirmationMode = input.string("Close", "Confirmation Mode", options = ["Close", "Wick + Close"], group = groupScore, tooltip = ttConfirm)

string groupVisual = "Chart Visuals"
bool showPriorClose = input.bool(true, "Show Prior Close Rail", group = groupVisual, tooltip = ttRail)
bool showPocket = input.bool(true, "Show Reclaim Pocket", group = groupVisual, tooltip = ttShowPocket)
bool showPocketText = input.bool(true, "Show Centered Pocket Text", group = groupVisual, tooltip = ttPocketText)
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupVisual, tooltip = ttLabels)
bool showReclaimLabels = input.bool(true, "Show Reclaim Labels", group = groupVisual, tooltip = ttReclaimLabels)
bool showRejectionLabels = input.bool(true, "Show Rejection Labels", group = groupVisual, tooltip = ttRejectionLabels)
bool showMagnetLabels = input.bool(true, "Show Magnet Labels", group = groupVisual, tooltip = ttMagnetLabels)
bool showInvalidLabels = input.bool(false, "Show Invalidation Labels", group = groupVisual, tooltip = ttInvalidLabels)
bool showRightTags = input.bool(true, "Show Right-Side Tags", group = groupVisual, tooltip = ttTags)
bool showPocketEdgeTags = input.bool(false, "Show Pocket Edge Tags", group = groupVisual, tooltip = ttEdgeTags)
bool showBarColors = input.bool(false, "Color Bars By State", group = groupVisual, tooltip = ttBars)
int projectionBars = input.int(72, "Projection Bars", minval = 5, maxval = 300, group = groupVisual, tooltip = ttProjection)
int labelCooldownBars = input.int(20, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupVisual, tooltip = ttCooldown)
int contextSpacingBars = input.int(34, "Context Label Spacing", minval = 4, maxval = 180, group = groupVisual, tooltip = ttContextSpacing)
int maxEventLabels = input.int(10, "Max Visible Labels", minval = 4, maxval = 80, group = groupVisual, tooltip = ttMaxLabels)
float labelOffsetAtr = input.float(0.72, "Label Offset ATR", minval = 0.05, maxval = 5.00, step = 0.05, group = groupVisual, tooltip = ttOffset)
string labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual, tooltip = ttLabelSize)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttPanel)
string panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLoc)
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
string panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelSize)

string groupAlerts = "Alerts"
bool alertReclaim = input.bool(true, "Alert: Reclaim", group = groupAlerts, tooltip = ttAlertReclaim)
bool alertRejection = input.bool(true, "Alert: Rejection", group = groupAlerts, tooltip = ttAlertRejection)
bool alertReady = input.bool(true, "Alert: Ready State", group = groupAlerts, tooltip = ttAlertReady)
bool alertMagnet = input.bool(false, "Alert: Magnet Zone", group = groupAlerts, tooltip = ttAlertMagnet)
bool alertInvalidation = input.bool(true, "Alert: Invalidation", group = groupAlerts, tooltip = ttAlertInvalid)

// -------------------------------------------------
// Core calculations
// -------------------------------------------------
float priorClose = request.security(syminfo.tickerid, referenceTf, close[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
float completedReferenceAtr = request.security(syminfo.tickerid, referenceTf, ta.atr(atrLength)[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
bool newReference = ta.change(time(referenceTf)) != 0
bool hasReference = not na(priorClose)

float atrRaw = ta.atr(atrLength)
float atr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
float volumeNow = nz(volume, 0.0)
float volAvg = ta.sma(volumeNow, volumeLength)
float rvol = volAvg > 0.0 ? volumeNow / volAvg : 1.0
float atrAvg = ta.sma(atr, volumeLength)
float volatilityRatio = atrAvg > 0.0 ? atr / atrAvg : 1.0
float referenceAtr = math.max(nz(completedReferenceAtr, atr), syminfo.mintick)

float pocket = referenceAtr * pocketAtr
float upperPocket = priorClose + pocket
float lowerPocket = priorClose - pocket
float magnetDistance = referenceAtr * magnetAtr
float barRange = math.max(high - low, syminfo.mintick)
float body = math.abs(close - open)
float bodyRatio = body / barRange
float distanceAtr = hasReference ? math.abs(close - priorClose) / referenceAtr : na

bool abovePocket = hasReference and close > upperPocket
bool belowPocket = hasReference and close < lowerPocket
bool insidePocket = hasReference and close <= upperPocket and close >= lowerPocket
bool nearRail = hasReference and math.abs(close - priorClose) <= magnetDistance

bool bullReclaim = hasReference and ta.crossover(close, upperPocket)
bool bearReclaim = hasReference and ta.crossunder(close, lowerPocket)
bool bullReject = hasReference and low <= upperPocket and close > upperPocket and close > open
bool bearReject = hasReference and high >= lowerPocket and close < lowerPocket and close < open
bool wasNearRail = bar_index > 0 ? nearRail[1] : false
bool magnetTouch = nearRail and not wasNearRail
bool confirmedBar = barstate.isconfirmed

float confirmationBonus = confirmationMode == "Wick + Close" and (bullReject or bearReject) ? 10.0 : 0.0
float closeQuality = abovePocket ? f_clamp((close - upperPocket) / atr * 50.0, 0.0, 24.0) : belowPocket ? f_clamp((lowerPocket - close) / atr * 50.0, 0.0, 24.0) : 8.0
float wickQuality = abovePocket ? f_clamp((close - low) / barRange * 20.0, 0.0, 20.0) : belowPocket ? f_clamp((high - close) / barRange * 20.0, 0.0, 20.0) : f_clamp(bodyRatio * 12.0, 0.0, 12.0)
float volumeQuality = f_clamp(rvol * 14.0, 0.0, 18.0)
float magnetQuality = hasReference ? f_clamp((magnetAtr - nz(distanceAtr, magnetAtr)) / math.max(magnetAtr, 0.01) * 16.0, 0.0, 16.0) : 0.0
float volatilityFit = f_clamp(16.0 - math.abs(volatilityRatio - 1.0) * 18.0, 0.0, 16.0)
float distancePenalty = hasReference and nz(distanceAtr, 0.0) > magnetAtr ? f_clamp((nz(distanceAtr, magnetAtr) - magnetAtr) * 12.0, 0.0, 42.0) : 0.0
int reclaimScore = hasReference ? f_score(18.0 + closeQuality + wickQuality + volumeQuality + magnetQuality + volatilityFit + confirmationBonus - distancePenalty) : 0

var int referenceStartBar = na
if newReference or na(referenceStartBar)
    referenceStartBar := bar_index
int referenceAge = hasReference and not na(referenceStartBar) ? bar_index - referenceStartBar : na
bool referenceOld = hasReference and referenceAge > maxReferenceAge

bool volumeReady = rvol >= minRelativeVolume
bool readyDistanceOk = hasReference and nz(distanceAtr, magnetAtr * 2.0) <= magnetAtr * 1.25
bool readyBull = confirmedBar and hasReference and abovePocket and readyDistanceOk and reclaimScore >= minReadyScore and volumeReady and not referenceOld
bool readyBear = confirmedBar and hasReference and belowPocket and readyDistanceOk and reclaimScore >= minReadyScore and volumeReady and not referenceOld
bool readyState = readyBull or readyBear
bool readyEvent = confirmedBar and readyState and not readyState[1]
bool reclaimEvent = confirmedBar and (bullReclaim or bearReclaim) and reclaimScore >= minReadyScore and volumeReady and not referenceOld
bool rejectionEvent = confirmedBar and (bullReject or bearReject) and reclaimScore >= minReadyScore and volumeReady and not referenceOld
bool magnetEvent = confirmedBar and showMagnetLabels and nearRail and reclaimScore >= watchScore and not reclaimEvent and not rejectionEvent and not referenceOld

var int activeReclaimDir = 0
var int activeReclaimBar = na
bool rawInvalidated = confirmedBar and ((activeReclaimDir == 1 and close < lowerPocket and bar_index > nz(activeReclaimBar, bar_index)) or (activeReclaimDir == -1 and close > upperPocket and bar_index > nz(activeReclaimBar, bar_index)))
bool invalidated = rawInvalidated

if reclaimEvent
    activeReclaimDir := bullReclaim ? 1 : -1
    activeReclaimBar := bar_index
else if rawInvalidated
    activeReclaimDir := 0
    activeReclaimBar := na

string railState = not hasReference ? "No Reference" : referenceOld ? "Old Reference" : abovePocket ? "Bull Reclaim" : belowPocket ? "Bear Reclaim" : insidePocket ? "Magnet Pocket" : "Neutral"
string actionState = not hasReference ? "WAIT" : referenceOld ? "EXPIRED" : invalidated ? "INVALIDATED" : readyState ? "READY" : insidePocket or nearRail ? "MONITOR" : "WAIT"
int stateDir = readyBull or abovePocket ? 1 : readyBear or belowPocket ? -1 : activeReclaimDir
string actionText = not hasReference ? "Wait for reference" : referenceOld ? "Refresh reference" : invalidated ? "Stand down from reclaim" : readyBull ? "Review bull reclaim" : readyBear ? "Review bear reclaim" : insidePocket or nearRail ? "Track rail reaction" : abovePocket or belowPocket ? "Wait for rail return" : "Wait for setup"
string directionText = abovePocket ? "Above Rail" : belowPocket ? "Below Rail" : "Inside Pocket"
string scoreText = hasReference ? str.tostring(reclaimScore) + "/100 " + f_grade(reclaimScore) : "-"
string distanceText = f_atr_text(distanceAtr)
string magnetText = nearRail ? "Active" : "Away"
color stateColor = readyBull ? bullColor : readyBear ? bearColor : actionState == "MONITOR" ? accentColor : actionState == "INVALIDATED" ? dangerColor : actionState == "EXPIRED" ? panelBorder : neutralColor
int rightEdge = bar_index + projectionBars

// -------------------------------------------------
// Reclaim follow-through proof (stop-aware)
// -------------------------------------------------
// After each qualified reclaim, did price travel one ATR in the reclaim
// direction before closing back through the opposite pocket edge? Win = one ATR
// first, Loss = pocket lost first, neither inside the window = uncounted.
var int   pfTotal = 0
var int   pfWins  = 0
var bool  pfOpen  = false
var int   pfDir   = 0
var float pfWin   = na
var float pfStop  = na
var int   pfBar   = na
int pfWindow = 40

if barstate.isconfirmed
    if pfOpen
        bool pfHitStop = pfDir == 1 ? close < pfStop : close > pfStop
        bool pfHitWin  = pfDir == 1 ? high >= pfWin : low <= pfWin
        if pfHitStop
            pfTotal += 1
            pfOpen  := false
        else if pfHitWin
            pfTotal += 1
            pfWins  += 1
            pfOpen  := false
        else if not na(pfBar) and bar_index - pfBar > pfWindow
            pfOpen := false
    if reclaimEvent
        pfOpen := true
        pfDir  := bullReclaim ? 1 : -1
        pfWin  := bullReclaim ? close + atr : close - atr
        pfStop := bullReclaim ? lowerPocket : upperPocket
        pfBar  := bar_index

float pfRate = pfTotal > 0 ? pfWins / pfTotal * 100.0 : na
reclaimRateText = pfTotal >= 6 ? str.tostring(math.round(pfRate)) + "%  (" + str.tostring(pfTotal) + ")" : "Building (" + str.tostring(pfTotal) + ")"
color reclaimRateCol = pfTotal >= 6 ? (pfRate >= 55.0 ? bullColor : pfRate >= 45.0 ? neutralColor : bearColor) : f_panel_value(panelTheme)

// -------------------------------------------------
// Plots and pocket
// -------------------------------------------------
railPlot = plot(showPriorClose and hasReference ? priorClose : na, title = "Prior Close", color = color.new(accentColor, 0), linewidth = 2, style = plot.style_linebr)
upperPlot = plot(showPocket and hasReference ? upperPocket : na, title = "Upper Reclaim Pocket", color = color.new(bullColor, 35), linewidth = 1, style = plot.style_linebr)
lowerPlot = plot(showPocket and hasReference ? lowerPocket : na, title = "Lower Reclaim Pocket", color = color.new(bearColor, 35), linewidth = 1, style = plot.style_linebr)
fill(upperPlot, lowerPlot, color = showPocket and hasReference ? color.new(accentColor, 90) : na, title = "Prior Close Pocket")

var box pocketBox = na
var label pocketBadge = na
int pocketLeft = bar_index
string pocketText = actionState == "READY" ? (stateDir == 1 ? "BULL RECLAIM | Q " : "BEAR RECLAIM | Q ") + str.tostring(reclaimScore) : actionState == "INVALIDATED" ? "FAILED POCKET" : actionState == "MONITOR" ? "PRIOR CLOSE MONITOR" : "PRIOR CLOSE"
color pocketColor = readyBull ? bullColor : readyBear ? bearColor : actionState == "INVALIDATED" ? dangerColor : accentColor
int pocketBadgeX = bar_index + int(math.round(projectionBars * 0.5))
float pocketMid = (upperPocket + lowerPocket) * 0.5
color pocketBadgeCol = color.new(pocketColor, 8)

if showPocket and hasReference and barstate.islast
    if na(pocketBox)
        pocketBox := box.new(left = pocketLeft, top = upperPocket, right = rightEdge, bottom = lowerPocket, xloc = xloc.bar_index, bgcolor = color.new(pocketColor, 92), border_color = color.new(pocketColor, 40), border_width = 1)
    else
        box.set_lefttop(pocketBox, pocketLeft, upperPocket)
        box.set_rightbottom(pocketBox, rightEdge, lowerPocket)
        box.set_bgcolor(pocketBox, color.new(pocketColor, 92))
        box.set_border_color(pocketBox, color.new(pocketColor, 40))
    if showPocketText
        if na(pocketBadge)
            pocketBadge := label.new(pocketBadgeX, pocketMid, pocketText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = pocketBadgeCol, textcolor = f_text_on(pocketBadgeCol), size = f_text_size(labelSizeInput), textalign = text.align_center)
        else
            label.set_xy(pocketBadge, pocketBadgeX, pocketMid)
            label.set_text(pocketBadge, pocketText)
            label.set_color(pocketBadge, pocketBadgeCol)
            label.set_textcolor(pocketBadge, f_text_on(pocketBadgeCol))
            label.set_size(pocketBadge, f_text_size(labelSizeInput))
    else if not na(pocketBadge)
        label.delete(pocketBadge)
        pocketBadge := na
else
    if not na(pocketBox)
        box.delete(pocketBox)
        pocketBox := na
    if not na(pocketBadge)
        label.delete(pocketBadge)
        pocketBadge := na

// -------------------------------------------------
// Labels
// -------------------------------------------------
float labelOffset = atr * labelOffsetAtr
var int lastEventLabelBar = na
var int lastContextLabelBar = na
var array<label> eventLabels = array.new<label>()
var float[] lblBars = array.new_float()
var float[] lblYs = array.new_float()

bool eventCooldownReady = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
bool contextCooldownReady = na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars

if showEventLabels and showReclaimLabels and reclaimEvent and eventCooldownReady
    bool bullEvent = bullReclaim
    color reclaimCol = color.new(bullEvent ? bullColor : bearColor, 0)
    float reclaimY = f_resolve_y(bar_index, bullEvent ? low - labelOffset : high + labelOffset, bullEvent ? -1.0 : 1.0, atr * 1.45, lblBars, lblYs)
    label newLabel = label.new(bar_index, reclaimY, "RECLAIM | Q " + str.tostring(reclaimScore), xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_up : label.style_label_down, color = reclaimCol, textcolor = f_text_on(reclaimCol), size = f_text_size(labelSizeInput), textalign = text.align_center)
    array.push(eventLabels, newLabel)
    f_trim_labels(eventLabels, maxEventLabels)
    lastEventLabelBar := bar_index

if showEventLabels and showRejectionLabels and rejectionEvent and not reclaimEvent and eventCooldownReady
    bool bullEvent = bullReject
    float rejectY = f_resolve_y(bar_index, bullEvent ? low - labelOffset : high + labelOffset, bullEvent ? -1.0 : 1.0, atr * 1.45, lblBars, lblYs)
    label newLabel = label.new(bar_index, rejectY, (bullEvent ? "DEFEND | Q " : "REJECT | Q ") + str.tostring(reclaimScore), xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_up : label.style_label_down, color = color.new(neutralColor, 0), textcolor = f_text_on(neutralColor), size = f_text_size(labelSizeInput), textalign = text.align_center)
    array.push(eventLabels, newLabel)
    f_trim_labels(eventLabels, maxEventLabels)
    lastEventLabelBar := bar_index

if showEventLabels and magnetEvent and contextCooldownReady and not reclaimEvent and not rejectionEvent
    bool labelBelow = close < priorClose
    color magnetCol = color.new(accentColor, 6)
    float magnetY = f_resolve_y(bar_index, labelBelow ? low - labelOffset : high + labelOffset, labelBelow ? -1.0 : 1.0, atr * 1.45, lblBars, lblYs)
    label newLabel = label.new(bar_index, magnetY, "MAGNET | " + f_atr_text(distanceAtr), xloc = xloc.bar_index, yloc = yloc.price, style = labelBelow ? label.style_label_up : label.style_label_down, color = magnetCol, textcolor = f_text_on(magnetCol), size = f_text_size(labelSizeInput), textalign = text.align_center)
    array.push(eventLabels, newLabel)
    f_trim_labels(eventLabels, maxEventLabels)
    lastContextLabelBar := bar_index

if showEventLabels and showInvalidLabels and invalidated and eventCooldownReady
    bool labelAbove = close >= priorClose
    float invalidY = f_resolve_y(bar_index, labelAbove ? high + labelOffset : low - labelOffset, labelAbove ? 1.0 : -1.0, atr * 1.45, lblBars, lblYs)
    label newLabel = label.new(bar_index, invalidY, "FAILED RAIL", xloc = xloc.bar_index, yloc = yloc.price, style = labelAbove ? label.style_label_down : label.style_label_up, color = color.new(dangerColor, 0), textcolor = f_text_on(dangerColor), size = f_text_size(labelSizeInput), textalign = text.align_center)
    array.push(eventLabels, newLabel)
    f_trim_labels(eventLabels, maxEventLabels)
    lastEventLabelBar := bar_index

// -------------------------------------------------
// Right-side tags
// -------------------------------------------------
var label railTag = na
var label upperTag = na
var label lowerTag = na

if barstate.islast and showRightTags and hasReference
    if not na(railTag)
        label.delete(railTag)
    if not na(upperTag)
        label.delete(upperTag)
    if not na(lowerTag)
        label.delete(lowerTag)
    bool showMainRailTag = not showPocketText
    if showMainRailTag
        railTag := label.new(rightEdge, priorClose, "Prior " + f_price(priorClose), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 12), textcolor = f_text_on(accentColor), size = f_text_size(labelSizeInput))
    if showPocketEdgeTags
        upperTag := label.new(rightEdge, upperPocket, "Upper " + f_price(upperPocket), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bullColor, 18), textcolor = f_text_on(bullColor), size = f_text_size(labelSizeInput))
        lowerTag := label.new(rightEdge, lowerPocket, "Lower " + f_price(lowerPocket), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bearColor, 18), textcolor = f_text_on(bearColor), size = f_text_size(labelSizeInput))
else if barstate.islast
    if not na(railTag)
        label.delete(railTag)
        railTag := na
    if not na(upperTag)
        label.delete(upperTag)
        upperTag := na
    if not na(lowerTag)
        label.delete(lowerTag)
        lowerTag := na

// -------------------------------------------------
// Data Window
// -------------------------------------------------
plot(reclaimScore, title = "Prior Close Reclaim Score", color = f_score_color(reclaimScore, minReadyScore, watchScore), display = display.data_window)
plot(distanceAtr, title = "Distance From Prior Close ATR", color = accentColor, display = display.data_window)
plot(rvol, title = "Relative Volume", color = panelValueCol, display = display.data_window)
plot(referenceAge, title = "Reference Age", color = neutralColor, display = display.data_window)
plot(volatilityRatio, title = "Volatility Ratio", color = panelValueCol, display = display.data_window)

// -------------------------------------------------
// Panel
// -------------------------------------------------
color actionColor = f_action_color(actionState, stateDir)
color scoreColor = hasReference ? f_score_color(reclaimScore, minReadyScore, watchScore) : f_panel_value(panelTheme)
color distanceColor = nearRail ? accentColor : f_panel_value(panelTheme)

var table panel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""

if barstate.islast
    if showPanel
        if na(panel) or panelLocationInput != lastPanelLocation or panelTheme != lastPanelTheme
            if not na(panel)
                table.delete(panel)
            panel := table.new(f_panel_position(panelLocationInput), 2, 7, bgcolor = f_panel_bg(panelTheme), frame_color = f_panel_border(panelTheme), frame_width = 1, border_color = f_panel_border(panelTheme), border_width = 1)
            lastPanelLocation := panelLocationInput
            lastPanelTheme := panelTheme
        table.clear(panel, 0, 0, 1, 6)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Prior Close Reclaim Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSizeInput), text_halign = text.align_center)
        f_panel_row(panel, 1, "Prior Close", hasReference ? f_price(priorClose) : "-", f_panel_value(panelTheme), panelTheme, panelFontSizeInput)
        f_panel_row(panel, 2, "Reclaim Score", scoreText, scoreColor, panelTheme, panelFontSizeInput)
        f_panel_row(panel, 3, "Distance", magnetText + " / " + distanceText, distanceColor, panelTheme, panelFontSizeInput)
        f_panel_row(panel, 4, "Rail State", railState, stateColor, panelTheme, panelFontSizeInput)
        f_panel_row(panel, 5, "Reclaim Rate", reclaimRateText, reclaimRateCol, panelTheme, panelFontSizeInput)
        f_panel_row(panel, 6, "Action", actionText, actionColor, panelTheme, panelFontSizeInput)
    else if not na(panel)
        table.delete(panel)
        panel := na
        lastPanelLocation := ""
        lastPanelTheme := ""

// -------------------------------------------------
// Bar color and alerts
// -------------------------------------------------
color barStateColor = actionState == "READY" ? color.new(stateColor, 72) : actionState == "MONITOR" ? color.new(accentColor, 78) : actionState == "INVALIDATED" ? color.new(dangerColor, 72) : na
barcolor(showBarColors ? barStateColor : na)

alertcondition(alertReclaim and reclaimEvent and bullReclaim, "Bull Prior Close Reclaim", "Prior Close Reclaim Planner: price reclaimed the prior close pocket to the upside. This is an attention marker, not a trade instruction.")
alertcondition(alertReclaim and reclaimEvent and bearReclaim, "Bear Prior Close Reclaim", "Prior Close Reclaim Planner: price reclaimed the prior close pocket to the downside. This is an attention marker, not a trade instruction.")
alertcondition(alertRejection and rejectionEvent and bullReject, "Prior Close Bull Defense", "Prior Close Reclaim Planner: price defended the prior close pocket and closed back above it.")
alertcondition(alertRejection and rejectionEvent and bearReject, "Prior Close Bear Rejection", "Prior Close Reclaim Planner: price rejected the prior close pocket and closed back below it.")
alertcondition(alertReady and readyEvent and readyBull, "Bull Prior Close Ready", "Prior Close Reclaim Planner: bullish prior-close reclaim context reached READY state.")
alertcondition(alertReady and readyEvent and readyBear, "Bear Prior Close Ready", "Prior Close Reclaim Planner: bearish prior-close reclaim context reached READY state.")
alertcondition(alertMagnet and confirmedBar and magnetTouch, "Prior Close Magnet Zone", "Prior Close Reclaim Planner: price entered the prior-close magnet zone.")
alertcondition(alertInvalidation and invalidated, "Prior Close Reclaim Invalidated", "Prior Close Reclaim Planner: a prior-close reclaim attempt failed back through the rail.")
````
