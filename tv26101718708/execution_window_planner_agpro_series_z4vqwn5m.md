# Execution Window Planner [AGPro Series]

- url: https://www.tradingview.com/script/z4VqWn5m-Execution-Window-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;c5b758abd980449086f9dba6399f521a
- version: 4.0

## Description

Execution Window Planner [AGPro Series]

🧠 Core Idea

Where is the cleanest active price window for evaluating execution context?


📌 Overview / What it does

Execution Window Planner [AGPro Series] is a chart-first execution-readiness tool built to answer one practical question: is price currently sitting inside a clean review window, or is the context too early, too late, too stretched, or already invalidated?

The script maps an active execution window box, a risk edge, a target edge, compact state labels, and a premium AGPro panel. It converts window width, structure alignment, volatility fit, trend support, candle confirmation, and room-to-risk context into a transparent 0-100 Quality Score.

It does not predict price movement, automate orders, or issue buy/sell commands. The output is designed as an analytical planning layer for traders who want cleaner context before making their own execution decisions.


🎯 Purpose & Design Philosophy

This script was built for traders who already have a directional thesis but need a disciplined way to judge whether the current price area is actually usable for execution review.

Many tools show trend, signals, support/resistance, or zones. The missing piece is often the active decision window: the price area where risk is still definable, target room still exists, volatility is not distorted, and confirmation is not too weak.

The design philosophy is simple: execution quality should be evaluated through a defined window, not through excitement around a single candle.


⚡ Why This Script Is Different

Most tools focus on printing a signal, marking a generic support/resistance area, or showing a large multi-feature trading dashboard.

This script does NOT act as a full trading suite, signal service, position sizing tool, ICT/FVG map, order block map, or generic zone scanner.

Instead, it keeps one narrow purpose: identify and score the current execution window using risk edge, target edge, structure, volatility, trend support, and candle confirmation. The result is a focused decision layer rather than another broad indicator.


⚙️ Methodology

1. Context Detection
The script detects the active planning side automatically from trend structure, or lets the user force a long-bias or short-bias view.

2. Reference Mapping
It builds a risk edge from recent structure and a target edge from broader structure or ATR-adjusted room.

3. Window Construction
It creates an active execution window around the current trend reference, then limits that window between the risk edge and target edge.

4. Reaction Evaluation
It scores window width, structure alignment, volatility fit, trend support, and candle confirmation into a 0-100 Quality Score.

5. Visual Output
The chart displays the execution window box, risk/target edges, state labels, alerts, and a premium AGPro panel with the key decision fields.


🗺️ How to Read the Chart

Execution Window = the current price area where the script is evaluating execution context.

Risk Edge = the structure-based invalidation edge for the active window.

Target Edge = the nearest meaningful target-side reference or ATR-adjusted room marker.

Labels = the current window state, score tier, risk distance, and room-to-risk context.

Colors = teal for stronger bullish execution windows, pink for bearish or invalidation contexts, amber for forming/waiting states, and indigo for target-edge or transition states.

Panel = the fastest summary of window state, quality score, risk edge, target edge, and next action.


🚦 Signals & States

• ACTIVE → the execution window meets the quality threshold and confirmation filter.

• FORMING → the window is improving but still needs cleaner confirmation.

• WAIT → the context exists, but structure, volatility, room, or confirmation is not strong enough yet.

• BLOCKED → there is no clean execution window in the current context.

• TARGET EDGE → price has reached the mapped target-side reference and reaction quality should be evaluated.

• INVALIDATED → price closed beyond the active risk edge.


🔔 Alerts Logic

ACTIVE Window alerts trigger when the state upgrades into ACTIVE.

Downgrade alerts trigger when the active window weakens from a stronger previous state.

Risk Edge alerts trigger when price closes beyond the current risk edge.

Target Edge alerts trigger when price reaches the current target edge.

Alerts are attention markers only. They are not trading instructions.


🧩 Confluence Logic

The strongest execution-window context appears when several conditions align:

• Price remains inside the mapped execution window
• The risk edge is still structurally valid
• The target edge leaves enough room relative to risk
• Trend support agrees with the active side
• Candle structure confirms the same direction
• Volatility is close to its recent baseline

When these elements align, the Quality Score improves and the panel state becomes easier to interpret.


📊 When to Use

• When you already have a directional thesis and want to evaluate execution context

• During trend continuation setups where risk and target references remain clear

• Around pullback or reset areas where timing and risk quality matter

• Before reacting to a potential continuation candle

• When you want a cleaner planning layer instead of another simple signal indicator


⚠️ When NOT to Use

• During very low-liquidity conditions where candles print irregularly

• During high-noise chop where risk and target edges change too quickly

• During extreme volatility spikes where ATR context becomes distorted

• On symbols with poor price continuity or unreliable session behavior

• As a standalone reason to enter or exit a trade


🎛️ Key Inputs

• Setup Direction → Auto detects the active planning side, or the user can force Long Bias / Short Bias.

• Sensitivity → controls how selective the model is.

• Structure Lookback → controls how risk edge, target edge, and structure context are mapped.

• Minimum ACTIVE Score → defines the score threshold required for ACTIVE state.

• Confirmation Mode → controls how much trend and candle confirmation must align.

• Label Cooldown Bars → controls historical label density.

• Max Visible Labels → limits older state labels to keep the chart readable.

• Label Detail → Compact is the default clean publication view; Balanced and Full can show more risk/room context.

• Label Offset Strength / Lane Strength → smart placement controls that keep labels near price without burying them inside candles or pushing them too far away on higher timeframes.

• Panel Location / Theme / Font Size → controls the AGPro panel presentation.

• Label Font Size → controls all on-chart labels.


🖥️ Interface & Visual Design

The panel is designed as a compact decision dashboard, not a large command center. The first row uses the standard AGPro merged blue header row, and the remaining rows focus only on the information needed to evaluate the current execution window.

The chart visuals stay restrained: one active execution window, one risk edge, one target edge, a current quality tag, and moderate historical state labels. The goal is a premium, readable chart that does not feel empty but also avoids clutter.


🧪 Practical Usage Workflow

1. Read the panel state first.

2. Check whether price is inside or near the execution window.

3. Compare the risk edge and target edge.

4. Review the Quality Score and confirmation state.

5. Interpret labels as context markers, not as trade commands.

6. Confirm the broader market context with your own process.


🔍 Interpretation Guidelines

ACTIVE does not mean guaranteed continuation. It means the current window has passed the script's rule-based quality model.

FORMING means the setup may be developing, but the script does not yet see enough confirmation.

WAIT means the context may exist, but the window quality is not clean enough.

BLOCKED means the current chart does not offer a useful execution window under the selected settings.

TARGET EDGE means the chart has reached the mapped target-side reference, so reaction quality becomes more important than chasing the move.

INVALIDATED means the risk edge has been broken and the active window should be reset.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not an auto-trading system

• Not a guaranteed signal tool

• Not a full trading suite

• Not an ICT/FVG or order block map

• Not a generic support/resistance zone scanner


⚠️ Limitations & Transparency

Execution-window quality is rule-based and depends on the selected inputs, timeframe, symbol behavior, and available chart data.

Different timeframes can produce different risk and target edges because market structure changes with resolution.

Fast volatility expansion can make the current edge distances less stable.

Low-volume markets may produce weaker confirmation quality.

The script should be interpreted inside broader market context, not in isolation.


🧠 Market Context Notes

Execution quality is usually strongest when structure, volatility, and trend behavior are aligned.

If volatility expands too quickly, the window can become stretched even if direction looks strong.

If the target edge is too close, the setup may have limited room even when the trend looks clean.

If the risk edge is too far away, the setup may require too much tolerance relative to the available room.


🧾 Use Case Examples

When price pulls back toward the active trend reference, remains inside the execution window, and the risk edge is still structurally protected, the Quality Score may improve.

When price reaches the target edge after an ACTIVE window, the script can shift into TARGET EDGE state so the user can evaluate reaction behavior instead of treating the move as fresh.

When price closes beyond the risk edge, the window becomes INVALIDATED and the panel shifts to a reset-oriented state.


🧱 System Philosophy

Execution Window Planner follows the AGPro Series approach: build scripts that help traders make a decision, not just see another signal.

The script is intentionally narrow. It focuses on one practical question and keeps the chart output centered around that question.


🔐 Non-Promise Statement

No script can provide certainty.

No score guarantees future movement.

No alert should be treated as an instruction to trade.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own analysis, execution choices, risk management, and trading outcomes.

This script is for educational and analytical use only and does not provide financial advice.


📚 Educational Note

The best use of this script is to study how execution context changes as price moves between risk edge, execution window, and target edge.

Use it as a structured planning aid, not as a replacement for your own market analysis.

## Source Code

````pine
// -------------------------------------------------
// Execution Window Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Execution Window Planner is a chart-first trade decision engine that maps
// the cleanest active price window for execution review. It evaluates window
// width, structure alignment, volatility fit, trend support, candle
// confirmation, risk edge and target edge into a 0-100 quality score, a clear
// next-action state and a persistent hold-rate proof layer, while keeping the
// output neutral, focused and public-release ready.
// -------------------------------------------------

//@version=6
indicator("Execution Window Planner [AGPro Series]",
     shorttitle = "AG Pro EWP",
     overlay = true,
     max_labels_count = 220,
     max_lines_count = 70,
     max_boxes_count = 40)

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
monitorColor  = color.rgb(71, 85, 105)

groupCore   = "Execution Window Engine"
groupProof  = "Confirm-Rate Proof"
groupVisual = "Visual Design"
groupPanel  = "AGPro Panel"
groupAlerts = "Alerts"

setupDirection = input.string("Auto", "Setup Direction", options = ["Auto", "Long Bias", "Short Bias"], group = groupCore, tooltip = "Select Auto to let the script infer the active execution side from trend structure, or force a long/short planning view for your own directional thesis.")
sensitivity = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Aggressive"], group = groupCore, tooltip = "Controls how selective the window model is. Conservative requires tighter structure and cleaner confirmation; Aggressive reacts earlier with wider tolerance.")
lookback = input.int(64, "Structure Lookback", minval = 25, maxval = 240, group = groupCore, tooltip = "Bars used to map the active risk edge, target edge, structure alignment, and window quality.")
minimumScore = input.int(70, "Minimum Active Score", minval = 50, maxval = 95, group = groupCore, tooltip = "Minimum 0-100 quality score required before the window can become Active.")
confirmationMode = input.string("Balanced", "Confirmation Mode", options = ["Early", "Balanced", "Strict"], group = groupCore, tooltip = "Defines how much trend, candle, and close-location confirmation must align before the model can classify the execution window as Active.")
cooldownBars = input.int(50, "Label Cooldown Bars", minval = 10, maxval = 100, group = groupCore, tooltip = "Minimum spacing between repeated state labels. The publication default preserves meaningful history without crowding the active execution plan.")
maxVisibleLabels = input.int(5, "Max Visible Labels", minval = 4, maxval = 12, group = groupCore, tooltip = "Maximum number of historical state labels kept on the chart.")

proofWindowInput = input.int(20, "Proof Hold Window Bars", minval = 3, maxval = 120, group = groupProof, tooltip = "Bars an Active execution window must defend its risk edge to be counted as a held window in the Hold Rate proof statistic.")

showWindow = input.bool(true, "Show Execution Window", group = groupVisual, tooltip = "Displays the active execution window box, risk edge, target edge, and window-quality badge.")
showLabels = input.bool(true, "Show State Labels", group = groupVisual, tooltip = "Displays moderate on-chart window-state labels with score and risk context.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = groupVisual, tooltip = "Displays compact right-side tags for risk edge, target edge, and window quality.")
projectionBars = input.int(28, "Window Projection Bars", minval = 10, maxval = 120, group = groupVisual, tooltip = "How far the active execution window projects to the right side of the chart.")
labelOffsetAtr = input.float(1.05, "Label Offset Strength", minval = 0.20, maxval = 2.00, step = 0.05, group = groupVisual, tooltip = "Controls the smart vertical distance between labels and candles.")
labelLaneSpreadAtr = input.float(0.40, "Label Lane Strength", minval = 0.05, maxval = 1.00, step = 0.05, group = groupVisual, tooltip = "Controls spacing between nearby label lanes.")
labelShiftBars = input.int(4, "Label Stagger Bars", minval = 0, maxval = 8, group = groupVisual, tooltip = "Applies a small horizontal stagger to nearby labels.")
labelDetail = input.string("Compact", "Label Detail", options = ["Compact", "Balanced", "Full"], group = groupVisual, tooltip = "Controls how much information each state label shows. Compact keeps publication defaults clean; Balanced adds risk and room; Full also adds directional context.")
labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual, tooltip = "Controls on-chart label text size. Normal is the default publication setting.")

showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = "Shows or hides the AGPro decision panel. The panel is enabled by default for publication-ready chart presentation.")
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = "Selects the on-chart position of the AGPro panel.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = "Controls the panel color theme while keeping the standard AGPro blue header row.")
panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = "Controls panel text size. Normal is the default publication setting.")

enableActiveAlert = input.bool(true, "Enable Active Window Alert", group = groupAlerts, tooltip = "Allows alert conditions when the execution window upgrades into Active state. Alerts are attention markers, not trade instructions.")
enableDowngradeAlert = input.bool(true, "Enable Downgrade Alert", group = groupAlerts, tooltip = "Allows alert conditions when the active window state weakens from a stronger state.")
enableInvalidAlert = input.bool(true, "Enable Risk Edge Alert", group = groupAlerts, tooltip = "Allows alert conditions when price closes beyond the current risk edge.")
enableTargetAlert = input.bool(true, "Enable Target Edge Alert", group = groupAlerts, tooltip = "Allows alert conditions when price reaches the current target edge.")

f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_size(string value) =>
    switch value
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_pos(string value) =>
    switch value
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_state_rank(string stateValue) =>
    switch stateValue
        "Target Edge" => 5
        "Active" => 4
        "Forming" => 3
        "Wait" => 2
        "Blocked" => 1
        "Invalidated" => 0
        => 1

f_price(float value) =>
    str.tostring(value, format.mintick)

f_score_text(float value) =>
    str.tostring(math.round(value), "#")

f_state_short(string stateValue) =>
    switch stateValue
        "Target Edge" => "Target Review"
        "Active" => "Active Window"
        "Forming" => "Window Forming"
        "Invalidated" => "Invalidated"
        "Blocked" => "Blocked"
        => "Waiting"

f_state_color(string stateValue, bool isLong) =>
    switch stateValue
        "Active" => isLong ? bullColor : bearColor
        "Target Edge" => accentColor
        "Forming" => neutralColor
        "Wait" => monitorColor
        "Invalidated" => dangerColor
        "Blocked" => monitorColor
        => panelLabelCol

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

f_text_on(color bg) =>
    float luminance = color.r(bg) * 0.299 + color.g(bg) * 0.587 + color.b(bg) * 0.114
    luminance > 150.0 ? color.rgb(15, 23, 42) : headerText

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_size(fontSize), text_halign = text.align_right)

f_set_tag(label tag, int x, float y, string textValue, color bgColor, string sizeText) =>
    label.set_xy(tag, x, y)
    label.set_text(tag, textValue)
    label.set_color(tag, color.new(bgColor, 4))
    label.set_textcolor(tag, f_text_on(bgColor))
    label.set_size(tag, f_size(sizeText))
    label.set_style(tag, label.style_label_left)

fastLen = sensitivity == "Conservative" ? 34 : sensitivity == "Aggressive" ? 13 : 21
slowLen = sensitivity == "Conservative" ? 89 : sensitivity == "Aggressive" ? 34 : 55
riskBufferAtr = sensitivity == "Conservative" ? 0.26 : sensitivity == "Aggressive" ? 0.12 : 0.18
targetAtrFallback = sensitivity == "Conservative" ? 2.55 : sensitivity == "Aggressive" ? 1.65 : 2.05
windowAtr = sensitivity == "Conservative" ? 0.70 : sensitivity == "Aggressive" ? 1.10 : 0.88
idealWindowAtr = sensitivity == "Conservative" ? 1.20 : sensitivity == "Aggressive" ? 1.90 : 1.55

atrRaw = ta.atr(14)
safeAtrBase = nz(atrRaw, high - low)
safeAtr = math.max(safeAtrBase, syminfo.mintick)
atrAverage = ta.sma(atrRaw, lookback)
atrRatio = safeAtr / math.max(nz(atrAverage, safeAtr), syminfo.mintick)
visualRangeLen = math.min(lookback, 80)
visualHigh = ta.highest(high, visualRangeLen)
visualLow = ta.lowest(low, visualRangeLen)
visualRange = math.max(nz(visualHigh - visualLow, safeAtr), safeAtr)
localLabelHigh = ta.highest(high, 3)
localLabelLow = ta.lowest(low, 3)

emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
emaSlope = emaFast - nz(emaFast[5], emaFast)

autoBiasRaw = close >= emaFast and emaFast >= emaSlow ? 1 : close <= emaFast and emaFast <= emaSlow ? -1 : 0
var int heldAutoBias = 0
heldAutoBias := autoBiasRaw != 0 ? autoBiasRaw : nz(heldAutoBias[1], close >= emaSlow ? 1 : -1)
setupBias = setupDirection == "Long Bias" ? 1 : setupDirection == "Short Bias" ? -1 : heldAutoBias
isLongSetup = setupBias == 1

riskLookback = math.max(10, int(math.round(lookback * 0.55)))
structureLow = nz(ta.lowest(low[1], riskLookback), low)
structureHigh = nz(ta.highest(high[1], riskLookback), high)
rangeLow = nz(ta.lowest(low[1], lookback), low)
rangeHigh = nz(ta.highest(high[1], lookback), high)
rangeMid = (rangeHigh + rangeLow) * 0.50

riskEdge = isLongSetup ? structureLow - safeAtr * riskBufferAtr : structureHigh + safeAtr * riskBufferAtr
targetCandidate = isLongSetup ? rangeHigh : rangeLow
targetFallback = isLongSetup ? close + safeAtr * targetAtrFallback : close - safeAtr * targetAtrFallback
targetEdge = isLongSetup ? math.max(targetCandidate, targetFallback) : math.min(targetCandidate, targetFallback)

riskDistance = math.max(math.abs(close - riskEdge), syminfo.mintick)
targetRoom = math.max(math.abs(targetEdge - close), syminfo.mintick)
riskAtr = riskDistance / safeAtr
roomR = targetRoom / riskDistance

windowCenter = emaFast
rawWindowTop = windowCenter + safeAtr * windowAtr
rawWindowBottom = windowCenter - safeAtr * windowAtr
upperLimit = math.max(riskEdge, targetEdge)
lowerLimit = math.min(riskEdge, targetEdge)
windowTopLimited = math.min(rawWindowTop, upperLimit)
windowBottomLimited = math.max(rawWindowBottom, lowerLimit)
windowTop = windowTopLimited <= windowBottomLimited ? close + safeAtr * windowAtr * 0.55 : windowTopLimited
windowBottom = windowTopLimited <= windowBottomLimited ? close - safeAtr * windowAtr * 0.55 : windowBottomLimited
windowWidthAtr = math.max((windowTop - windowBottom) / safeAtr, 0.0)
inWindow = close <= windowTop and close >= windowBottom

barRange = math.max(high - low, syminfo.mintick)
bodySize = math.abs(close - open)
bodyEfficiency = f_clamp(bodySize / barRange, 0.0, 1.0)
closeLocation = f_clamp((close - low) / barRange, 0.0, 1.0)
directionalClose = isLongSetup ? closeLocation : 1.0 - closeLocation
candleAgrees = isLongSetup ? close >= open : close <= open

trendAligned = isLongSetup ? emaFast > emaSlow and close > emaSlow : emaFast < emaSlow and close < emaSlow
trendPartial = isLongSetup ? close > emaFast or emaFast > emaSlow : close < emaFast or emaFast < emaSlow
trendSlopeAligned = isLongSetup ? emaSlope > 0 : emaSlope < 0
structureAligned = isLongSetup ? close > rangeMid and riskEdge < close and targetEdge > close : close < rangeMid and riskEdge > close and targetEdge < close

windowWidthScore = f_clamp(22.0 - math.abs(windowWidthAtr - idealWindowAtr) * 9.0, 0.0, 22.0)
structureScore = (structureAligned ? 16.0 : 6.0) + (roomR >= 1.20 ? 8.0 : roomR >= 0.90 ? 4.0 : 0.0)
volatilityScore = f_clamp(16.0 - math.abs(atrRatio - 1.0) * 18.0, 0.0, 16.0)
trendScore = (trendAligned ? 16.0 : trendPartial ? 8.0 : 0.0) + (trendSlopeAligned ? 6.0 : 0.0)
candleScore = bodyEfficiency * 7.0 + directionalClose * 6.0 + (candleAgrees ? 3.0 : 0.0)
windowScore = f_clamp(windowWidthScore + structureScore + volatilityScore + trendScore + candleScore, 0.0, 100.0)

strictConfirm = trendAligned and trendSlopeAligned and candleAgrees and directionalClose >= 0.64 and roomR >= 1.25 and inWindow
balancedConfirm = trendAligned and directionalClose >= 0.55 and roomR >= 1.00 and inWindow
earlyConfirm = (trendAligned or trendSlopeAligned) and directionalClose >= 0.48 and roomR >= 0.85
isConfirmed = confirmationMode == "Strict" ? strictConfirm : confirmationMode == "Early" ? earlyConfirm : balancedConfirm

isInvalidated = isLongSetup ? close < riskEdge : close > riskEdge
targetEdgeTouched = isLongSetup ? high >= targetEdge : low <= targetEdge
activeQuality = windowScore >= minimumScore and isConfirmed and not isInvalidated
windowState = isInvalidated ? "Invalidated" : targetEdgeTouched and windowScore >= minimumScore - 8 ? "Target Edge" : activeQuality ? "Active" : windowScore >= minimumScore - 10 ? "Forming" : windowScore >= minimumScore - 25 ? "Wait" : "Blocked"
nextAction = windowState == "Active" ? "Review active window" : windowState == "Forming" ? "Wait for confirmation" : windowState == "Target Edge" ? "Evaluate target-edge reaction" : windowState == "Invalidated" ? "Reset the window" : windowState == "Wait" ? "Wait for cleaner structure" : "No clean execution window"

stateColor = f_state_color(windowState, isLongSetup)
directionText = isLongSetup ? "Long Window" : "Short Window"
riskText = f_price(riskEdge) + " | " + str.tostring(riskAtr, "#.##") + " ATR"
targetText = f_price(targetEdge) + " | " + str.tostring(roomR, "#.##") + "R"
labelRiskText = str.tostring(riskAtr, "#.##") + "A"
labelRoomText = str.tostring(roomR, "#.##") + "R"

var string previousState = "Wait"
activeStateEvent = barstate.isconfirmed and windowState == "Active" and previousState != "Active"
downgradeStateEvent = barstate.isconfirmed and f_state_rank(windowState) < f_state_rank(previousState)
invalidStateEvent = barstate.isconfirmed and windowState == "Invalidated" and previousState != "Invalidated"
targetStateEvent = barstate.isconfirmed and windowState == "Target Edge" and previousState != "Target Edge"

// -------------------------------------------------
// Hold-rate proof
// On an Active upgrade, a win is recorded when the window defends its risk edge
// through the proof window; closing beyond the risk edge first is a non-hold.
// -------------------------------------------------
var bool proofPending = false
var int proofDir = 0
var float proofRisk = na
var int proofStartBar = na
var int proofTotal = 0
var int proofWin = 0

if activeStateEvent and not proofPending
    proofPending := true
    proofDir := isLongSetup ? 1 : -1
    proofRisk := riskEdge
    proofStartBar := bar_index

if proofPending and barstate.isconfirmed and bar_index > proofStartBar
    bool pRisk = proofDir == 1 ? close < proofRisk : close > proofRisk
    bool pHeld = bar_index - proofStartBar >= proofWindowInput
    if pRisk
        proofTotal += 1
        proofPending := false
    else if pHeld
        proofTotal += 1
        proofWin += 1
        proofPending := false

float holdRate = proofTotal > 0 ? 100.0 * proofWin / proofTotal : na
string panelHoldText = na(holdRate) ? "Building" : str.tostring(math.round(holdRate)) + "% (" + str.tostring(proofTotal) + ")"
color panelHoldColor = na(holdRate) ? f_panel_value(panelTheme) : holdRate >= 55.0 ? bullColor : holdRate >= 40.0 ? neutralColor : bearColor

activeEvent = enableActiveAlert and activeStateEvent
downgradeEvent = enableDowngradeAlert and downgradeStateEvent
invalidEvent = enableInvalidAlert and invalidStateEvent
targetEvent = enableTargetAlert and targetStateEvent

alertcondition(activeEvent, "Execution Window Planner Active", "Execution Window Planner: the active window upgraded to Active. This is an attention marker, not a trade instruction.")
alertcondition(downgradeEvent, "Execution Window Planner Downgrade", "Execution Window Planner: the active window state weakened from the previous bar.")
alertcondition(invalidEvent, "Execution Window Planner Risk Edge", "Execution Window Planner: price closed beyond the current risk edge.")
alertcondition(targetEvent, "Execution Window Planner Target Edge", "Execution Window Planner: price reached the current target edge.")

var box windowBox = na
var line riskLine = na
var line targetLine = na
var label riskTag = na
var label targetTag = na
var label windowBadge = na

if barstate.islast
    zoneLeft = math.max(bar_index - 4, 0)
    zoneRight = bar_index + projectionBars
    badgeX = int(math.round((zoneLeft + zoneRight) * 0.5))
    badgeY = (windowTop + windowBottom) * 0.5
    badgeText = (isLongSetup ? "LONG" : "SHORT") + " WINDOW | " + str.upper(windowState) + " " + f_score_text(windowScore)
    if showWindow
        if na(windowBox)
            windowBox := box.new(left = zoneLeft, top = windowTop, right = zoneRight, bottom = windowBottom, xloc = xloc.bar_index, border_color = color.new(stateColor, 18), bgcolor = color.new(stateColor, 88))
        else
            box.set_left(windowBox, zoneLeft)
            box.set_right(windowBox, zoneRight)
            box.set_top(windowBox, windowTop)
            box.set_bottom(windowBox, windowBottom)
            box.set_bgcolor(windowBox, color.new(stateColor, 88))
            box.set_border_color(windowBox, color.new(stateColor, 18))
        if na(windowBadge)
            windowBadge := label.new(badgeX, badgeY, badgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(stateColor, 4), textcolor = f_text_on(stateColor), size = f_size(labelFontSize), textalign = text.align_center)
        else
            label.set_xy(windowBadge, badgeX, badgeY)
            label.set_text(windowBadge, badgeText)
            label.set_color(windowBadge, color.new(stateColor, 4))
            label.set_textcolor(windowBadge, f_text_on(stateColor))
            label.set_size(windowBadge, f_size(labelFontSize))

        if na(riskLine)
            riskLine := line.new(x1 = zoneLeft, y1 = riskEdge, x2 = zoneRight, y2 = riskEdge, xloc = xloc.bar_index, extend = extend.none, color = color.new(dangerColor, 0), style = line.style_dashed, width = 2)
        else
            line.set_xy1(riskLine, zoneLeft, riskEdge)
            line.set_xy2(riskLine, zoneRight, riskEdge)
            line.set_color(riskLine, color.new(dangerColor, 0))
            line.set_style(riskLine, line.style_dashed)
            line.set_width(riskLine, 2)

        if na(targetLine)
            targetLine := line.new(x1 = zoneLeft, y1 = targetEdge, x2 = zoneRight, y2 = targetEdge, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 0), style = line.style_solid, width = 2)
        else
            line.set_xy1(targetLine, zoneLeft, targetEdge)
            line.set_xy2(targetLine, zoneRight, targetEdge)
            line.set_color(targetLine, color.new(accentColor, 0))
            line.set_style(targetLine, line.style_solid)
            line.set_width(targetLine, 2)

        if showRightTags
            if na(riskTag)
                riskTag := label.new(zoneRight, riskEdge, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left)
            if na(targetTag)
                targetTag := label.new(zoneRight, targetEdge, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left)
            f_set_tag(riskTag, zoneRight, riskEdge, "RISK " + str.tostring(riskEdge, format.mintick), dangerColor, labelFontSize)
            f_set_tag(targetTag, zoneRight, targetEdge, "TARGET " + str.tostring(targetEdge, format.mintick), accentColor, labelFontSize)
        else
            if not na(riskTag)
                label.delete(riskTag)
                riskTag := na
            if not na(targetTag)
                label.delete(targetTag)
                targetTag := na
    else
        if not na(windowBox)
            box.delete(windowBox)
            windowBox := na
        if not na(windowBadge)
            label.delete(windowBadge)
            windowBadge := na
        if not na(riskLine)
            line.delete(riskLine)
            riskLine := na
        if not na(targetLine)
            line.delete(targetLine)
            targetLine := na
        if not na(riskTag)
            label.delete(riskTag)
            riskTag := na
        if not na(targetTag)
            label.delete(targetTag)
            targetTag := na

var array<label> stateLabels = array.new_label()
var int lastLabelBar = na
var int labelSlotCounter = 0
var string lastVisualState = ""
var float lastVisualScore = na
var int lastVisualBias = 0

majorStateEvent = activeStateEvent or invalidStateEvent or targetStateEvent
regularLabelDue = windowState != "Blocked" and (na(lastLabelBar) or bar_index - lastLabelBar >= cooldownBars)
sameVisualContext = windowState == lastVisualState and setupBias == lastVisualBias
scoreMovedEnough = na(lastVisualScore) or math.abs(windowScore - lastVisualScore) >= 18.0
sameStateSpacedEnough = na(lastLabelBar) or bar_index - lastLabelBar >= cooldownBars * 5
smartLabelAllowed = not sameVisualContext or scoreMovedEnough or sameStateSpacedEnough

if showLabels and barstate.isconfirmed and (majorStateEvent or regularLabelDue) and smartLabelAllowed
    labelLane = labelSlotCounter % 6
    clusteredLabel = not na(lastLabelBar) and bar_index - lastLabelBar <= math.max(4, int(math.round(cooldownBars * 0.60)))
    clusterBoost = clusteredLabel ? 0.50 : 0.0
    minLabelClearance = math.max(math.min(barRange * 0.16, safeAtr * 0.28), safeAtr * 0.05)
    baseLabelDistance = f_clamp(safeAtr * labelOffsetAtr, minLabelClearance, visualRange * 0.07)
    laneLabelDistance = f_clamp(safeAtr * labelLaneSpreadAtr, safeAtr * 0.03, visualRange * 0.025)
    rawLabelDistance = baseLabelDistance + labelLane * laneLabelDistance + clusterBoost * laneLabelDistance
    labelDistance = math.max(minLabelClearance, math.min(rawLabelDistance, visualRange * 0.12))
    labelXShift = labelShiftBars == 0 ? 0 : labelLane == 0 ? -labelShiftBars * 2 : labelLane == 1 ? -labelShiftBars : labelLane == 2 ? 0 : labelLane == 3 ? labelShiftBars : labelLane == 4 ? labelShiftBars * 2 : labelShiftBars * 3
    labelX = math.max(bar_index + labelXShift, 0)
    labelAnchorLow = math.min(localLabelLow, low)
    labelAnchorHigh = math.max(localLabelHigh, high)
    labelY = isLongSetup ? labelAnchorLow - labelDistance : labelAnchorHigh + labelDistance
    labelStyle = isLongSetup ? label.style_label_up : label.style_label_down
    compactState = f_state_short(windowState)
    labelText = labelDetail == "Full" ? windowState + " " + f_score_text(windowScore) + "\n" + directionText + "\nRisk " + labelRiskText + " | Room " + labelRoomText : labelDetail == "Balanced" ? compactState + "\nScore " + f_score_text(windowScore) + "\nRisk " + labelRiskText + " | Room " + labelRoomText : compactState + " " + f_score_text(windowScore)
    newLabel = label.new(labelX, labelY, labelText, xloc = xloc.bar_index, yloc = yloc.price, style = labelStyle, color = color.new(stateColor, 6), textcolor = f_text_on(stateColor), size = f_size(labelFontSize), textalign = text.align_center)
    array.push(stateLabels, newLabel)
    labelSlotCounter += 1
    lastLabelBar := bar_index
    lastVisualState := windowState
    lastVisualScore := windowScore
    lastVisualBias := setupBias
    while array.size(stateLabels) > maxVisibleLabels
        oldLabel = array.shift(stateLabels)
        label.delete(oldLabel)

panelValueText = f_panel_value(panelTheme)
panelStateColor = windowState == "Wait" or windowState == "Blocked" ? panelValueText : stateColor

var table infoPanel = na
var string panelLocationCache = ""
var string panelThemeCache = ""

if showPanel and (na(infoPanel) or panelLocationCache != panelLocation or panelThemeCache != panelTheme)
    if not na(infoPanel)
        table.delete(infoPanel)
    infoPanel := table.new(f_panel_pos(panelLocation), 2, 7, border_width = 1, border_color = f_panel_border(panelTheme), frame_width = 1, frame_color = f_panel_border(panelTheme), bgcolor = f_panel_bg(panelTheme))
    panelLocationCache := panelLocation
    panelThemeCache := panelTheme

if barstate.islast
    if showPanel and not na(infoPanel)
        table.clear(infoPanel, 0, 0, 1, 6)
        table.cell(infoPanel, 0, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSize))
        table.cell(infoPanel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSize))
        table.merge_cells(infoPanel, 0, 0, 1, 0)
        table.cell(infoPanel, 0, 0, "AG Pro Execution Window Planner", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSize), text_halign = text.align_center)
        f_panel_row(infoPanel, 1, "Window State", windowState + " | " + directionText, panelStateColor, panelTheme, panelFontSize)
        f_panel_row(infoPanel, 2, "Quality Score", f_score_text(windowScore) + " / 100", panelStateColor, panelTheme, panelFontSize)
        f_panel_row(infoPanel, 3, "Risk Edge", riskText, panelValueText, panelTheme, panelFontSize)
        f_panel_row(infoPanel, 4, "Target Edge", targetText, panelValueText, panelTheme, panelFontSize)
        f_panel_row(infoPanel, 5, "Action", nextAction, panelStateColor, panelTheme, panelFontSize)
        f_panel_row(infoPanel, 6, "Hold Rate", panelHoldText, panelHoldColor, panelTheme, panelFontSize)

if not showPanel and not na(infoPanel)
    table.delete(infoPanel)
    infoPanel := na
    panelLocationCache := ""
    panelThemeCache := ""

previousState := windowState
````
