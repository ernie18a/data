# Order Flow Imbalance Recovery Planner [AGPro Series]

- url: https://www.tradingview.com/script/Uiqtw1vf-Order-Flow-Imbalance-Recovery-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;45c911e20dae49a1b4935c67591d6196
- version: 4.0

## Description

Order Flow Imbalance Recovery Planner [AGPro Series]

🧠 Core Idea

Can a high-volume displacement pocket recover with enough absorption and follow-through to become actionable chart context?


📌 Overview / What it does

Order Flow Imbalance Recovery Planner [AGPro Series] maps high-volume displacement candles, converts them into practical imbalance recovery pockets, and evaluates whether price can recover that pocket with measurable response.

The script produces imbalance pockets, recovery rails, continuation corridors, invalidation shelves, target reference rails, event labels, and a compact AG Pro dashboard with a 0-100 recovery score.

This script does not read live order book data, footprint data, bid/ask tape, or true exchange-level order flow. It uses chart-available volume, relative volume, candle displacement, wick response, and recovery behavior as a practical visual proxy.


🎯 Purpose & Design Philosophy

The script was built for traders who want a structured way to study volume imbalance recovery instead of reacting to every large candle.

Many displacement candles look important at first, but the useful question is whether price can return to the pocket, absorb pressure, and recover the key rail.

The design supports a context-first workflow: identify the imbalance, observe the test, evaluate the recovery quality, and then read the current state.


⚡ Why This Script Is Different

Most tools mark volume spikes or wide candles as isolated events.

This script does NOT treat every high-volume candle as a signal.

Instead, it builds a recovery pocket, scores the reaction around that pocket, separates test conditions from READY conditions, and keeps invalidation visible.


⚙️ Methodology

1. Context Detection

The script searches for directional displacement candles with elevated relative volume, meaningful candle range, and sufficient body commitment.

2. Reference Mapping

When a valid imbalance is found, the script maps a recovery pocket and a recovery rail around the displacement body.

3. Reaction Evaluation

Price interaction with the pocket is evaluated through retest behavior, close location, wick response, relative volume, freshness, and failure distance.

4. Visual Output

The script displays the active pocket, recovery rail, target rails, invalidation shelf, event labels, bar state color, and dashboard state.


🗺️ How to Read the Chart

Zones represent the active imbalance recovery pocket.

The recovery rail marks the key level price needs to reclaim or lose before the context improves.

Labels highlight new imbalance pockets, pocket tests, ready recovery events, invalidations, and expirations.

Colors:
• Teal = bullish recovery context
• Pink = bearish recovery context or failed context
• Gold = neutral or wait state
• Indigo = monitor or reference state

The panel summarizes imbalance state, recovery score, flow response, risk, and action.


🚦 Signals & States

• Bull Imbalance → a bullish high-volume displacement pocket has been mapped

• Bear Imbalance → a bearish high-volume displacement pocket has been mapped

• Pocket Test → price is interacting with the active imbalance pocket

• Ready Recovery → the recovery score has reached the required threshold

• Invalidated → price has moved beyond the active failure edge

• Expired → the imbalance pocket is too old to remain active


🔔 Alerts Logic

Alerts can trigger when a new imbalance pocket is locked, when price tests the active pocket, when recovery reaches READY status, or when the context is invalidated.

Alerts are attention markers only. They are not trade instructions and do not guarantee future price behavior.


🧩 Confluence Logic

The context becomes stronger when high relative volume, large displacement, clean pocket retest, wick absorption, and recovery close align around the same pocket.


📊 When to Use

• After high-volume displacement candles

• During pullback and recovery phases

• Around breakout continuation attempts

• When studying absorption after aggressive movement

• On liquid symbols with reliable volume data


⚠️ When NOT to Use

• Very low-liquidity markets

• Symbols with unreliable volume data

• Extremely noisy sideways sessions

• News-driven spikes with unstable spreads

• Markets where chart volume does not represent meaningful participation


🎛️ Key Inputs

• Minimum Displacement Range → controls how large a candle must be relative to ATR

• Minimum Body Ratio → filters weak candles with too much wick noise

• Minimum Relative Volume → controls how much volume confirmation is required

• Minimum Ready Score → controls how strict the READY state is

• Projection Bars → controls how far active pockets and rails extend

• Visual Settings → control labels, zones, right-side tags, panel, font size, and bar colors


🖥️ Interface & Visual Design

The dashboard is designed as a quick decision-support panel, not a separate oscillator.

The chart uses a clear hierarchy: pocket first, recovery rail second, labels third, and targets only after recovery context becomes relevant.

The goal is to keep the chart premium, readable, and useful at first glance.


🧪 Practical Usage Workflow

1. Read the panel state

2. Locate the active imbalance pocket

3. Check whether price is testing or recovering the pocket

4. Review the recovery score and risk

5. Compare the output with broader market structure


🔍 Interpretation Guidelines

A READY state means the script has detected enough recovery behavior around the imbalance pocket to mark the context as worth attention.

It does not mean price must continue.

Use the output as structured context together with trend, liquidity, volatility, and higher-timeframe conditions.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not a true order book, footprint, or bid/ask delta tool.

It is not an automated trading system.

It does not provide guaranteed signals.

It is not financial advice.


⚠️ Limitations & Transparency

The script uses chart-available data only.

Volume quality differs between markets, brokers, exchanges, and asset classes.

Timeframe changes may alter the appearance and timing of imbalance pockets.

Extreme volatility may produce rapid invalidation or repeated displacement events.


🧠 Market Context Notes

Order-flow style interpretation should always consider liquidity, volatility, structure, and session context.

A strong recovery pocket in a clean trend may carry more practical meaning than the same pocket inside a noisy range.


🧾 Use Case Examples

When price creates a high-volume bullish displacement candle and later retests the pocket, the script evaluates whether the retest shows enough absorption and recovery strength to become a READY context.

When price loses the recovery edge, the script marks invalidation rather than keeping the setup visually alive.


🧱 System Philosophy

AGPro Series tools are designed as decision-support engines.

The goal is not to simplify markets into blind signals, but to organize complex price behavior into readable structure, state, and risk context.


🔐 Non-Promise Statement

No script can provide certainty.

No signal guarantees continuation, reversal, or profit.

Outputs should be interpreted as analytical context only.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions, risk management, and trade execution.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

Use this tool to study how volume displacement, imbalance pockets, absorption, and recovery behavior interact across different markets and timeframes.

## Source Code

````pine
// -------------------------------------------------
// Order Flow Imbalance Recovery Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Order Flow Imbalance Recovery Planner detects high-volume displacement
// candles, maps a practical imbalance pocket, and evaluates whether price can
// recover that pocket with absorption, volume response, and directional
// follow-through. It acts as a chart-based order-flow proxy for volume
// imbalance, recovery zones, absorption context, and next-action readiness.
// Version 1.3 consolidates active workflow identity, limits historical READY
// events to fresh transitions, and keeps every displaced badge price-owned.
// -------------------------------------------------

//@version=6
indicator("Order Flow Imbalance Recovery Planner [AGPro Series]",
     shorttitle = "AG Pro OFR",
     overlay = true,
     max_boxes_count = 90,
     max_lines_count = 160,
     max_labels_count = 240)

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
color targetBlue    = color.rgb(59, 130, 246)
color mutedBadge    = color.rgb(51, 65, 85)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupCore = "Core Detection"
atrLength = input.int(14, "ATR Length", minval = 1, group = groupCore, tooltip = "ATR length used to normalize displacement size, pocket depth, invalidation distance, and label offsets.")
volumeLength = input.int(30, "Relative Volume Length", minval = 5, group = groupCore, tooltip = "Average volume length used to compare the current volume bar against recent participation.")
minRangeAtr = input.float(1.05, "Minimum Displacement Range", minval = 0.20, step = 0.05, group = groupCore, tooltip = "Minimum candle range, measured in ATR, required to qualify as a volume displacement event.")
minBodyRatio = input.float(0.48, "Minimum Body Ratio", minval = 0.10, maxval = 0.95, step = 0.01, group = groupCore, tooltip = "Minimum body-to-range ratio required for the candle to represent directional displacement instead of random wick noise.")
minRelativeVolume = input.float(1.25, "Minimum Relative Volume", minval = 0.10, step = 0.05, group = groupCore, tooltip = "Minimum relative volume required for a displacement candle to be treated as an imbalance candidate.")
maxImbalanceAgeBars = input.int(110, "Maximum Imbalance Age", minval = 10, maxval = 500, group = groupCore, tooltip = "Maximum number of bars an imbalance pocket can remain active before it expires.")

string groupRecovery = "Recovery Logic"
minReadyScore = input.int(65, "Minimum Ready Score", minval = 1, maxval = 100, group = groupRecovery, tooltip = "Minimum 0-100 recovery score required for the script to mark a READY recovery state.")
testWindowBars = input.int(8, "Pocket Test Window", minval = 1, maxval = 50, group = groupRecovery, tooltip = "Number of bars after a pocket test where a recovery close may still be treated as relevant.")
recoveryBufferAtr = input.float(0.03, "Recovery Buffer ATR", minval = 0.0, step = 0.01, group = groupRecovery, tooltip = "Small ATR buffer applied around the recovery rail to reduce borderline reclaim or loss events.")
invalidationAtr = input.float(0.22, "Invalidation Buffer ATR", minval = 0.0, step = 0.01, group = groupRecovery, tooltip = "ATR buffer beyond the pocket edge used to invalidate the active recovery context.")
targetOneAtr = input.float(0.75, "Target Rail 1 ATR", minval = 0.10, step = 0.05, group = groupRecovery, tooltip = "First reference rail projected from the recovery rail after a ready recovery state.")
targetTwoAtr = input.float(1.25, "Target Rail 2 ATR", minval = 0.10, step = 0.05, group = groupRecovery, tooltip = "Second reference rail projected from the recovery rail after a ready recovery state.")

string groupVisual = "Visual Design"
showPocket = input.bool(true, "Show Imbalance Pocket", group = groupVisual, tooltip = "Shows the active imbalance recovery pocket on the chart.")
showZoneBadge = input.bool(true, "Show Centered Zone Badge", group = groupVisual, tooltip = "Shows separate centered badge text for the active imbalance pocket without embedding text into the box.")
showRecoveryRail = input.bool(true, "Show Recovery Rail", group = groupVisual, tooltip = "Shows the midline that price needs to reclaim or lose for recovery confirmation.")
showContinuationCorridor = input.bool(true, "Show Continuation Corridor", group = groupVisual, tooltip = "Shows the projected continuation area after a READY recovery state.")
showInvalidationShelf = input.bool(true, "Show Invalidation Shelf", group = groupVisual, tooltip = "Shows the failure shelf beyond the active pocket edge.")
showTargetRails = input.bool(true, "Show Target Rails", group = groupVisual, tooltip = "Shows T1 and T2 reference rails after a READY recovery state.")
showEventLabels = input.bool(true, "Show Event Labels", group = groupVisual, tooltip = "Shows premium event labels for imbalance, pocket test, recovery, invalidation, and expiry states.")
showImbalanceLabels = input.bool(true, "Show Imbalance Labels", group = groupVisual, tooltip = "Shows labels when a new high-volume imbalance pocket is locked.")
showPocketTestLabels = input.bool(false, "Show Pocket Test Labels", group = groupVisual, tooltip = "Shows labels when price tests the active imbalance pocket without full recovery confirmation. Disabled by default to reduce label clusters.")
showInvalidationLabels = input.bool(true, "Show Invalidation Labels", group = groupVisual, tooltip = "Shows labels when the active imbalance context is invalidated.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = groupVisual, tooltip = "Shows compact right-side price tags for the recovery rail and projected target rails.")
adaptiveProjection = input.bool(true, "Adaptive HTF Projection", group = groupVisual, tooltip = "Shortens projection on higher timeframes so pockets and rails do not dominate the chart.")
projectionBars = input.int(58, "Projection Bars", minval = 10, maxval = 300, group = groupVisual, tooltip = "Number of bars used to project active pockets, rails, corridors, and target references.")
maxEventLabels = input.int(5, "Maximum Event Labels", minval = 2, maxval = 20, group = groupVisual, tooltip = "Maximum historical event badges and their owned connector lines kept on the chart.")
labelCooldownBars = input.int(30, "Label Cooldown Bars", minval = 1, maxval = 100, group = groupVisual, tooltip = "Minimum spacing between historical event badges. READY prints only on a fresh state transition.")
labelOffsetAtr = input.float(0.80, "Label Offset ATR", minval = 0.05, step = 0.05, group = groupVisual, tooltip = "Vertical badge offset measured in ATR. An owned connector preserves the exact source candle.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisual, tooltip = "Controls the font size of chart labels and right-side tags.")
showBarColors = input.bool(false, "Color Bars By State", group = groupVisual, tooltip = "Colors bars according to the current recovery state.")

string groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = "Shows or hides the AG Pro dashboard panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = "Controls where the dashboard panel is displayed.")
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = groupPanel, tooltip = "Controls the dashboard color theme.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel, tooltip = "Controls dashboard font size.")

string groupAlerts = "Alerts"
alertNewImbalance = input.bool(true, "Alert: New Imbalance Locked", group = groupAlerts, tooltip = "Enables alert conditions when a new imbalance pocket is locked.")
alertPocketTest = input.bool(true, "Alert: Pocket Test", group = groupAlerts, tooltip = "Enables alert conditions when price tests the active imbalance pocket.")
alertReady = input.bool(true, "Alert: Ready Recovery", group = groupAlerts, tooltip = "Enables alert conditions when recovery score reaches the READY threshold.")
alertInvalidated = input.bool(true, "Alert: Invalidated", group = groupAlerts, tooltip = "Enables alert conditions when the active imbalance context is invalidated.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_score(float value) =>
    int(math.round(f_clamp(value, 0.0, 100.0)))

f_grade(int score) =>
    score >= 85 ? "A+" : score >= 75 ? "A" : score >= 65 ? "B" : score >= 50 ? "C" : "D"

f_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_panel_position(string posInput) =>
    switch posInput
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_text_on(color bgColor) =>
    float bright = (color.r(bgColor) * 299 + color.g(bgColor) * 587 + color.b(bgColor) * 114) / 1000
    bright >= 145 ? color.rgb(17, 24, 39) : headerText

f_panel_bg(string theme) =>
    theme == "Clean Light" ? color.rgb(241, 245, 249) : theme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_border(string theme) =>
    theme == "Clean Light" ? color.rgb(148, 163, 184) : theme == "Slate" ? color.rgb(71, 85, 105) : panelBorder

f_panel_label(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string theme, int row) =>
    bool evenRow = row % 2 == 0
    theme == "Clean Light" ? (evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)) : theme == "Slate" ? (evenRow ? color.rgb(37, 49, 70) : color.rgb(30, 41, 59)) : (evenRow ? color.rgb(20, 31, 52) : panelBg)

f_price(float value) =>
    str.tostring(value, format.mintick)

f_label_y(bool isBull, float offset) =>
    isBull ? low - offset : high + offset

f_panel_row(table panelRef, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(panelRef, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_size(fontSize), text_halign = text.align_left)
    table.cell(panelRef, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_size(fontSize), text_halign = text.align_right)

f_push_event(array<label> badges, array<line> guides, label newBadge, line newGuide, int maxCount) =>
    array.push(badges, newBadge)
    array.push(guides, newGuide)
    if array.size(badges) > maxCount
        label.delete(array.shift(badges))
        line.delete(array.shift(guides))

f_set_badge(label badge, int xValue, float yValue, string textValue, color bgColor, string sizeInput) =>
    label.set_xy(badge, xValue, yValue)
    label.set_text(badge, textValue)
    label.set_color(badge, bgColor)
    label.set_textcolor(badge, f_text_on(bgColor))
    label.set_style(badge, label.style_label_center)
    label.set_size(badge, f_size(sizeInput))

// -------------------------------------------------
// Core calculations
// -------------------------------------------------
atr = ta.atr(atrLength)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
avgVolume = ta.sma(volume, volumeLength)
relativeVolume = avgVolume > 0.0 ? volume / avgVolume : 1.0
rangeSize = math.max(high - low, syminfo.mintick)
bodySize = math.abs(close - open)
bodyRatio = bodySize / rangeSize
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

isBullDisplacement = close > open and rangeSize >= safeAtr * minRangeAtr and bodyRatio >= minBodyRatio and relativeVolume >= minRelativeVolume
isBearDisplacement = close < open and rangeSize >= safeAtr * minRangeAtr and bodyRatio >= minBodyRatio and relativeVolume >= minRelativeVolume
newImbalance = isBullDisplacement or isBearDisplacement

// -------------------------------------------------
// Persistent state
// -------------------------------------------------
var bool hasImbalance = false
var int activeDir = 0
var int imbalanceBar = na
var float pocketTop = na
var float pocketBottom = na
var float recoveryRail = na
var int seedScore = na
var int lastTestBar = na
var int lastReadyBar = na
var int lastLabelBar = na
var bool resetAfterRender = false

var box pocketBox = na
var box corridorBox = na
var box invalidationBox = na
var line recoveryLine = na
var line targetLine1 = na
var line targetLine2 = na
var label zoneBadge = na
var label railTag = na
var label targetTag1 = na
var label targetTag2 = na
var array<label> eventLabels = array.new<label>()
var array<line> eventGuides = array.new<line>()

if newImbalance
    float rawTop = math.max(open, close)
    float rawBottom = math.min(open, close)
    float minPocket = safeAtr * 0.18
    float pocketMid = (rawTop + rawBottom) * 0.5
    float halfPocket = math.max((rawTop - rawBottom) * 0.5, minPocket * 0.5)
    pocketTop := pocketMid + halfPocket
    pocketBottom := pocketMid - halfPocket
    recoveryRail := pocketMid
    activeDir := isBullDisplacement ? 1 : -1
    imbalanceBar := bar_index
    seedScore := f_score(35.0 + f_clamp((rangeSize / safeAtr - minRangeAtr) * 22.0, 0.0, 22.0) + f_clamp((relativeVolume - minRelativeVolume) * 16.0, 0.0, 24.0) + bodyRatio * 24.0)
    lastTestBar := na
    lastReadyBar := na
    hasImbalance := true
    resetAfterRender := false

ageBars = hasImbalance ? bar_index - imbalanceBar : na
expired = hasImbalance and ageBars > maxImbalanceAgeBars
insidePocket = hasImbalance and high >= pocketBottom and low <= pocketTop

if insidePocket
    lastTestBar := bar_index

testRecent = hasImbalance and not na(lastTestBar) and bar_index - lastTestBar <= testWindowBars
buffer = safeAtr * recoveryBufferAtr
bullRecoveryClose = hasImbalance and activeDir == 1 and testRecent and close > recoveryRail + buffer
bearRecoveryClose = hasImbalance and activeDir == -1 and testRecent and close < recoveryRail - buffer
recoveryClose = bullRecoveryClose or bearRecoveryClose

depthRaw = hasImbalance ? activeDir == 1 ? (close - recoveryRail) / math.max(pocketTop - pocketBottom, syminfo.mintick) : (recoveryRail - close) / math.max(pocketTop - pocketBottom, syminfo.mintick) : 0.0
rejectionWick = activeDir == 1 ? lowerWick / rangeSize : upperWick / rangeSize
freshnessScore = hasImbalance ? f_clamp(100.0 - (float(ageBars) / math.max(float(maxImbalanceAgeBars), 1.0)) * 55.0, 0.0, 100.0) : 0.0
volumeScore = f_clamp(relativeVolume * 28.0, 0.0, 28.0)
recoveryScoreRaw = hasImbalance ? seedScore * 0.30 + f_clamp(depthRaw * 38.0, 0.0, 26.0) + f_clamp(rejectionWick * 40.0, 0.0, 18.0) + volumeScore + freshnessScore * 0.18 : na
recoveryScore = hasImbalance and recoveryClose ? f_score(recoveryScoreRaw) : na
readyRecovery = hasImbalance and recoveryClose and recoveryScore >= minReadyScore

if readyRecovery
    lastReadyBar := bar_index

recoveryActive = hasImbalance and not na(lastReadyBar) and bar_index - lastReadyBar <= testWindowBars * 3
invalidated = hasImbalance and activeDir == 1 ? close < pocketBottom - safeAtr * invalidationAtr : hasImbalance and activeDir == -1 ? close > pocketTop + safeAtr * invalidationAtr : false

if expired or invalidated
    resetAfterRender := true

riskRaw = hasImbalance ? activeDir == 1 ? (recoveryRail - close) / math.max(safeAtr, syminfo.mintick) : (close - recoveryRail) / math.max(safeAtr, syminfo.mintick) : na
riskScore = hasImbalance ? f_score(35.0 + f_clamp(riskRaw * 45.0, 0.0, 65.0)) : na
flowResponse = readyRecovery ? activeDir == 1 ? "Bullish" : "Bearish" : insidePocket ? "Testing" : recoveryActive ? activeDir == 1 ? "Bullish" : "Bearish" : "Neutral"
actionState = invalidated ? "INVALIDATED" : expired ? "EXPIRED" : readyRecovery or recoveryActive ? "READY" : insidePocket ? "MONITOR" : hasImbalance ? "WAIT" : "WAIT"
imbalanceState = hasImbalance ? activeDir == 1 ? "Bull Imbalance" : "Bear Imbalance" : "No Active Imbalance"
scoreText = not na(recoveryScore) ? str.tostring(recoveryScore) + "/100  " + f_grade(recoveryScore) : recoveryActive and not na(lastReadyBar) ? "Active" : "n/a"
riskText = hasImbalance ? str.tostring(riskScore) + "/100" : "n/a"

targetOne = hasImbalance ? activeDir == 1 ? recoveryRail + safeAtr * targetOneAtr : recoveryRail - safeAtr * targetOneAtr : na
targetTwo = hasImbalance ? activeDir == 1 ? recoveryRail + safeAtr * targetTwoAtr : recoveryRail - safeAtr * targetTwoAtr : na
failureEdge = hasImbalance ? activeDir == 1 ? pocketBottom - safeAtr * invalidationAtr : pocketTop + safeAtr * invalidationAtr : na

// -------------------------------------------------
// Recovery follow-through proof (stop-aware)
// -------------------------------------------------
// After each fresh READY recovery, did price reach the first target rail before
// the invalidation edge was crossed? Win = T1 first, Loss = invalidation edge
// first, neither inside the imbalance window = uncounted.
var int   pfTotal  = 0
var int   pfWins   = 0
var bool  pfOpen   = false
var int   pfDir    = 0
var float pfTarget = na
var float pfFail   = na
var int   pfBar    = na
freshReady = readyRecovery and not readyRecovery[1]

if barstate.isconfirmed
    if pfOpen
        bool pfHitFail   = pfDir == 1 ? close < pfFail : close > pfFail
        bool pfHitTarget = pfDir == 1 ? high >= pfTarget : low <= pfTarget
        if pfHitFail
            pfTotal += 1
            pfOpen  := false
        else if pfHitTarget
            pfTotal += 1
            pfWins  += 1
            pfOpen  := false
        else if not na(pfBar) and bar_index - pfBar > maxImbalanceAgeBars
            pfOpen := false
    if freshReady and not na(targetOne) and not na(failureEdge)
        pfOpen   := true
        pfDir    := activeDir
        pfTarget := targetOne
        pfFail   := failureEdge
        pfBar    := bar_index

float pfRate = pfTotal > 0 ? pfWins / pfTotal * 100.0 : na
recoveryRateText = pfTotal >= 6 ? str.tostring(math.round(pfRate)) + "%  (" + str.tostring(pfTotal) + ")" : "Building (" + str.tostring(pfTotal) + ")"

// -------------------------------------------------
// Event labels
// -------------------------------------------------
labelSize = f_size(labelSizeInput)
labelOffset = safeAtr * labelOffsetAtr
canPrintLabel = na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars

if showEventLabels and canPrintLabel and showImbalanceLabels and newImbalance
    bool bullEvent = isBullDisplacement
    color imbCol = color.new(bullEvent ? bullColor : bearColor, 4)
    float badgeY = f_label_y(bullEvent, labelOffset)
    float anchorY = bullEvent ? low : high
    label newLabel = label.new(bar_index, badgeY, bullEvent ? "BULL IMBALANCE | LOCKED" : "BEAR IMBALANCE | LOCKED", xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_up : label.style_label_down, color = imbCol, textcolor = f_text_on(imbCol), size = labelSize)
    line newGuide = line.new(bar_index, anchorY, bar_index, badgeY, xloc = xloc.bar_index, color = color.new(imbCol, 45), width = 1)
    f_push_event(eventLabels, eventGuides, newLabel, newGuide, maxEventLabels)
    lastLabelBar := bar_index

if showEventLabels and canPrintLabel and showPocketTestLabels and insidePocket and not readyRecovery and not newImbalance
    bool bullEvent = activeDir == 1
    float badgeY = f_label_y(bullEvent, labelOffset * 0.85)
    float anchorY = bullEvent ? low : high
    label newLabel = label.new(bar_index, badgeY, bullEvent ? "BULL POCKET | TEST" : "BEAR POCKET | TEST", xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_up : label.style_label_down, color = neutralColor, textcolor = f_text_on(neutralColor), size = labelSize)
    line newGuide = line.new(bar_index, anchorY, bar_index, badgeY, xloc = xloc.bar_index, color = color.new(neutralColor, 45), width = 1)
    f_push_event(eventLabels, eventGuides, newLabel, newGuide, maxEventLabels)
    lastLabelBar := bar_index

if showEventLabels and canPrintLabel and freshReady
    bool bullEvent = activeDir == 1
    color readyCol = color.new(bullEvent ? bullColor : bearColor, 4)
    float badgeY = f_label_y(bullEvent, labelOffset)
    float anchorY = bullEvent ? low : high
    label newLabel = label.new(bar_index, badgeY, (bullEvent ? "BULL READY | " : "BEAR READY | ") + str.tostring(recoveryScore), xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_up : label.style_label_down, color = readyCol, textcolor = f_text_on(readyCol), size = labelSize)
    line newGuide = line.new(bar_index, anchorY, bar_index, badgeY, xloc = xloc.bar_index, color = color.new(readyCol, 45), width = 1)
    f_push_event(eventLabels, eventGuides, newLabel, newGuide, maxEventLabels)
    lastLabelBar := bar_index

if showEventLabels and canPrintLabel and showInvalidationLabels and invalidated
    bool bullEvent = activeDir == 1
    float badgeY = f_label_y(not bullEvent, labelOffset)
    float anchorY = bullEvent ? high : low
    label newLabel = label.new(bar_index, badgeY, bullEvent ? "BULL FLOW | INVALID" : "BEAR FLOW | INVALID", xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_down : label.style_label_up, color = bearColor, textcolor = f_text_on(bearColor), size = labelSize)
    line newGuide = line.new(bar_index, anchorY, bar_index, badgeY, xloc = xloc.bar_index, color = color.new(bearColor, 45), width = 1)
    f_push_event(eventLabels, eventGuides, newLabel, newGuide, maxEventLabels)
    lastLabelBar := bar_index

if showEventLabels and canPrintLabel and expired and not invalidated
    float badgeY = high + labelOffset
    label newLabel = label.new(bar_index, badgeY, "IMBALANCE | EXPIRED", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = accentColor, textcolor = f_text_on(accentColor), size = labelSize)
    line newGuide = line.new(bar_index, high, bar_index, badgeY, xloc = xloc.bar_index, color = color.new(accentColor, 45), width = 1)
    f_push_event(eventLabels, eventGuides, newLabel, newGuide, maxEventLabels)
    lastLabelBar := bar_index

// -------------------------------------------------
// Active drawings
// -------------------------------------------------
zoneColor = activeDir == 1 ? bullColor : bearColor
rightEdge = bar_index + (adaptiveProjection and not timeframe.isintraday ? math.max(18, int(math.round(projectionBars * 0.72))) : projectionBars)
badgeX = hasImbalance ? imbalanceBar + int(math.round((rightEdge - imbalanceBar) * 0.50)) : bar_index

if hasImbalance and showPocket
    if na(pocketBox)
        pocketBox := box.new(imbalanceBar, pocketTop, rightEdge, pocketBottom, xloc = xloc.bar_index, bgcolor = color.new(zoneColor, 89), border_color = color.new(zoneColor, 24), border_width = 1)
    else
        box.set_lefttop(pocketBox, imbalanceBar, pocketTop)
        box.set_rightbottom(pocketBox, rightEdge, pocketBottom)
        box.set_bgcolor(pocketBox, color.new(zoneColor, 89))
        box.set_border_color(pocketBox, color.new(zoneColor, 24))
    if showZoneBadge
        string pocketSideText = activeDir == 1 ? "BULL POCKET" : "BEAR POCKET"
        string pocketStateText = actionState == "READY" ? "READY" : actionState == "MONITOR" ? "TEST" : actionState == "INVALIDATED" ? "INVALID" : actionState == "EXPIRED" ? "EXPIRED" : "WAIT"
        string pocketScoreText = not na(recoveryScore) ? " | " + str.tostring(recoveryScore) : ""
        string badgeText = pocketSideText + " | " + pocketStateText + pocketScoreText
        color zoneBadgeCol = color.new(zoneColor, 8)
        if na(zoneBadge)
            zoneBadge := label.new(badgeX, (pocketTop + pocketBottom) * 0.5, badgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = zoneBadgeCol, textcolor = f_text_on(zoneBadgeCol), size = labelSize, textalign = text.align_center)
        else
            f_set_badge(zoneBadge, badgeX, (pocketTop + pocketBottom) * 0.5, badgeText, zoneBadgeCol, labelSizeInput)
    else if not na(zoneBadge)
        label.delete(zoneBadge)
        zoneBadge := na
else
    if not na(pocketBox)
        box.delete(pocketBox)
        pocketBox := na
    if not na(zoneBadge)
        label.delete(zoneBadge)
        zoneBadge := na

if hasImbalance and showRecoveryRail
    if na(recoveryLine)
        recoveryLine := line.new(imbalanceBar, recoveryRail, rightEdge, recoveryRail, xloc = xloc.bar_index, color = color.new(accentColor, 12), width = 1, style = line.style_dotted)
    else
        line.set_xy1(recoveryLine, imbalanceBar, recoveryRail)
        line.set_xy2(recoveryLine, rightEdge, recoveryRail)
        line.set_color(recoveryLine, color.new(accentColor, 12))
else if not na(recoveryLine)
    line.delete(recoveryLine)
    recoveryLine := na

if hasImbalance and showContinuationCorridor and recoveryActive
    float corridorTop = activeDir == 1 ? targetOne : recoveryRail
    float corridorBottom = activeDir == 1 ? recoveryRail : targetOne
    if na(corridorBox)
        corridorBox := box.new(bar_index, corridorTop, rightEdge, corridorBottom, xloc = xloc.bar_index, bgcolor = color.new(zoneColor, 92), border_color = color.new(zoneColor, 35), border_width = 1)
    else
        box.set_lefttop(corridorBox, bar_index, corridorTop)
        box.set_rightbottom(corridorBox, rightEdge, corridorBottom)
        box.set_bgcolor(corridorBox, color.new(zoneColor, 92))
        box.set_border_color(corridorBox, color.new(zoneColor, 35))
else
    if not na(corridorBox)
        box.delete(corridorBox)
        corridorBox := na

if hasImbalance and showInvalidationShelf
    float shelfTop = activeDir == 1 ? pocketBottom : failureEdge
    float shelfBottom = activeDir == 1 ? failureEdge : pocketTop
    if na(invalidationBox)
        invalidationBox := box.new(bar_index, shelfTop, rightEdge, shelfBottom, xloc = xloc.bar_index, bgcolor = color.new(bearColor, 94), border_color = color.new(bearColor, 45), border_width = 1)
    else
        box.set_lefttop(invalidationBox, bar_index, shelfTop)
        box.set_rightbottom(invalidationBox, rightEdge, shelfBottom)
        box.set_bgcolor(invalidationBox, color.new(bearColor, 94))
        box.set_border_color(invalidationBox, color.new(bearColor, 45))
else if not na(invalidationBox)
    box.delete(invalidationBox)
    invalidationBox := na

if hasImbalance and showTargetRails and recoveryActive
    if na(targetLine1)
        targetLine1 := line.new(bar_index, targetOne, rightEdge, targetOne, xloc = xloc.bar_index, color = color.new(neutralColor, 8), width = 1, style = line.style_dashed)
    else
        line.set_xy1(targetLine1, bar_index, targetOne)
        line.set_xy2(targetLine1, rightEdge, targetOne)
    if na(targetLine2)
        targetLine2 := line.new(bar_index, targetTwo, rightEdge, targetTwo, xloc = xloc.bar_index, color = color.new(targetBlue, 8), width = 1, style = line.style_dashed)
    else
        line.set_xy1(targetLine2, bar_index, targetTwo)
        line.set_xy2(targetLine2, rightEdge, targetTwo)
else
    if not na(targetLine1)
        line.delete(targetLine1)
        targetLine1 := na
    if not na(targetLine2)
        line.delete(targetLine2)
        targetLine2 := na

// -------------------------------------------------
// Right-side tags
// -------------------------------------------------
f_update_tag(label tag, float y, string txt, color bg) =>
    label result = tag
    if na(result)
        result := label.new(rightEdge, y, txt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = bg, textcolor = f_text_on(bg), size = labelSize)
    else
        label.set_x(result, rightEdge)
        label.set_y(result, y)
        label.set_text(result, txt)
        label.set_color(result, bg)
        label.set_textcolor(result, f_text_on(bg))
        label.set_size(result, labelSize)
    result

if hasImbalance and showRightTags
    railTag := f_update_tag(railTag, recoveryRail, (activeDir == 1 ? "Bull Pocket" : "Bear Pocket") + " | R " + f_price(recoveryRail), zoneColor)
    if recoveryActive and showTargetRails
        targetTag1 := f_update_tag(targetTag1, targetOne, "T1 " + f_price(targetOne), neutralColor)
        targetTag2 := f_update_tag(targetTag2, targetTwo, "T2 " + f_price(targetTwo), targetBlue)
    else
        if not na(targetTag1)
            label.delete(targetTag1)
            targetTag1 := na
        if not na(targetTag2)
            label.delete(targetTag2)
            targetTag2 := na
else
    if not na(railTag)
        label.delete(railTag)
        railTag := na
    if not na(targetTag1)
        label.delete(targetTag1)
        targetTag1 := na
    if not na(targetTag2)
        label.delete(targetTag2)
        targetTag2 := na

// -------------------------------------------------
// Panel
// -------------------------------------------------
stateColor = actionState == "READY" ? bullColor : actionState == "MONITOR" ? accentColor : actionState == "INVALIDATED" ? bearColor : actionState == "EXPIRED" ? accentColor : neutralColor
responseColor = flowResponse == "Bullish" ? bullColor : flowResponse == "Bearish" ? bearColor : flowResponse == "Testing" ? accentColor : neutralColor
recoveryRateCol = pfTotal >= 6 ? (pfRate >= 55.0 ? bullColor : pfRate >= 45.0 ? neutralColor : bearColor) : f_panel_value(panelTheme)
var table panel = table.new(f_panel_position(panelPositionInput), 2, 7, bgcolor = f_panel_bg(panelTheme), frame_color = f_panel_border(panelTheme), frame_width = 1, border_color = f_panel_border(panelTheme), border_width = 1)

if barstate.islast
    table.set_position(panel, f_panel_position(panelPositionInput))
    table.clear(panel, 0, 0, 1, 6)
    if showPanel
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Order Flow Imbalance Recovery Planner", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSizeInput), text_halign = text.align_center)
        f_panel_row(panel, 1, "Imbalance", imbalanceState, hasImbalance ? zoneColor : f_panel_value(panelTheme), panelTheme, panelFontSizeInput)
        f_panel_row(panel, 2, "Recovery Score", scoreText, actionState == "READY" ? stateColor : f_panel_value(panelTheme), panelTheme, panelFontSizeInput)
        f_panel_row(panel, 3, "Flow Response", flowResponse, responseColor, panelTheme, panelFontSizeInput)
        f_panel_row(panel, 4, "Risk", riskText, not na(riskScore) and riskScore >= 70 ? bearColor : f_panel_value(panelTheme), panelTheme, panelFontSizeInput)
        f_panel_row(panel, 5, "Recovery Rate", recoveryRateText, recoveryRateCol, panelTheme, panelFontSizeInput)
        f_panel_row(panel, 6, "Action", actionState, stateColor, panelTheme, panelFontSizeInput)

// -------------------------------------------------
// Bar color and alerts
// -------------------------------------------------
barStateColor = actionState == "READY" ? color.new(zoneColor, 70) : actionState == "MONITOR" ? color.new(accentColor, 75) : actionState == "INVALIDATED" ? color.new(bearColor, 65) : na
barcolor(showBarColors ? barStateColor : na)

alertcondition(alertNewImbalance and newImbalance and activeDir == 1, "OFR Bull Imbalance Locked", "Order Flow Imbalance Recovery Planner: a bullish volume imbalance pocket has been locked.")
alertcondition(alertNewImbalance and newImbalance and activeDir == -1, "OFR Bear Imbalance Locked", "Order Flow Imbalance Recovery Planner: a bearish volume imbalance pocket has been locked.")
alertcondition(alertPocketTest and insidePocket and not readyRecovery, "OFR Pocket Test", "Order Flow Imbalance Recovery Planner: price is testing the active imbalance pocket.")
alertcondition(alertReady and readyRecovery and activeDir == 1, "OFR Bull Recovery Ready", "Order Flow Imbalance Recovery Planner: bullish imbalance recovery reached READY conditions.")
alertcondition(alertReady and readyRecovery and activeDir == -1, "OFR Bear Recovery Ready", "Order Flow Imbalance Recovery Planner: bearish imbalance recovery reached READY conditions.")
alertcondition(alertInvalidated and invalidated, "OFR Imbalance Invalidated", "Order Flow Imbalance Recovery Planner: the active imbalance recovery context has been invalidated.")

if resetAfterRender
    hasImbalance := false
    activeDir := 0
    imbalanceBar := na
    pocketTop := na
    pocketBottom := na
    recoveryRail := na
    seedScore := na
    lastTestBar := na
    lastReadyBar := na
    resetAfterRender := false
````
