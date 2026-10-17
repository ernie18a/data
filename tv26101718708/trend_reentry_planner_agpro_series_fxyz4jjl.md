# Trend Re-Entry Planner [AGPro Series]

- url: https://www.tradingview.com/script/FXYZ4JJl-Trend-Re-Entry-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;5ded84fc5e2946c7abdb85fd5d09510d
- version: 4.0

## Description

Trend Re-Entry Planner [AGPro Series]

🧠 Core Idea

Is an active trend pullback creating a clean re-entry planning context, or is the reset becoming too risky?


📌 Overview / What it does

Trend Re-Entry Planner [AGPro Series] is a chart-first trend continuation planning tool designed to evaluate pullbacks inside an active trend structure. The default profile is tuned for 1H charts, where re-entry pockets, trigger candles, invalidation edges, and target-room context usually remain more readable.

The script builds a re-entry pocket from the current impulse range, scores the quality of the pullback, maps a trend defense line, shows an invalidation edge, and estimates target-room context. The goal is to help users judge whether a pullback is becoming organized enough for review or whether the trend context should be rebuilt.

It does not predict price, automate entries, or turn every pullback into a signal. It is a rule-based planning framework for evaluating trend re-entry structure.


🎯 Purpose & Design Philosophy

This script was built for traders who already track trend continuation but want a cleaner way to decide whether a pullback is worth attention.

Many trend tools show direction. Many pullback tools mark a reaction. This script focuses on the planning layer between those two ideas: trend side, pullback depth, reset quality, trigger behavior, target room, risk edge, and next action.

The design supports a disciplined workflow: evaluate context first, then decide whether the setup is ready, confirmed, invalidated, or still waiting.


⚡ Why This Script Is Different

Most tools focus on trend direction, moving average crosses, or broad pullback labels.

This script does NOT clone SuperTrend pullback grading, generic trend continuation signals, or low-volume pullback zones.

Instead, it uses an EMA trend stack and impulse-based re-entry pocket to build a planning view around the current pullback. The output is not just a marker. It is a decision panel with a 0-100 re-entry score, pullback depth, risk edge, target-room context, and next-action state.


⚙️ Methodology

1. Context Detection
The script identifies active bullish or bearish trend structure using an EMA stack and directional slope.

2. Reference Mapping
It maps the current impulse range and builds a concept-native re-entry pocket from that range.

3. Reaction Evaluation
The engine scores trend slope, pullback depth, reset quality near the mid EMA, trigger candle behavior, and target-room availability.

4. Visual Output
The script displays the re-entry pocket, invalidation edge, target-room guide, event labels, sparse context labels, and a premium AG Pro planning panel.


🗺️ How to Read the Chart

Zones = the re-entry pocket and target-room area used for planning context.

Labels = READY, CONFIRMED, INVALIDATED, FOLLOW-THROUGH, and sparse context states.

Colors = teal for bullish continuation context, pink for bearish or invalidation context, yellow for watch/review states, and indigo for target-room or follow-through emphasis.

Panel = the compact decision dashboard showing trend side, re-entry score, pullback depth, risk edge, and action.


🚦 Signals & States

• WATCH → the pullback is developing but still needs confirmation or cleaner structure.

• READY → the re-entry context has enough quality for closer review.

• CONFIRMED → a qualifying trigger candle appears after the pullback context improves.

• FOLLOW-THROUGH → the confirmed context produces a stronger continuation marker.

• INVALIDATED → price crosses the active invalidation edge and the plan should be rebuilt.


🔔 Alerts Logic

Alerts trigger when the script detects READY, CONFIRMED, INVALIDATED, or FOLLOW-THROUGH states.

Each alert is an attention marker tied to the rule-based state engine. Alerts are not trade instructions and do not guarantee that continuation will occur.


🧩 Confluence Logic

The context becomes stronger when trend slope, pullback depth, mid-EMA reset quality, trigger candle behavior, and target-room availability align.

The script intentionally requires multiple conditions instead of labeling every trend pullback as meaningful.


📊 When to Use

• 1H charts with active directional structure

• Directional markets with clear trend structure

• Pullbacks after a visible impulse move

• Continuation review workflows

• Trend-following plans where risk edge and target room matter


⚠️ When NOT to Use

• Low-liquidity symbols with unreliable price movement

• Extremely choppy markets with frequent trend-stack flips

• News-driven volatility where pullback structure changes too quickly

• Markets where the active impulse range is stale or unclear


🎛️ Key Inputs

• Sensitivity → adjusts how selective the re-entry score model is.

• Planning Profile → keeps the default behavior tuned for hourly re-entry planning or allows manual/higher-timeframe adjustment.

• Impulse Lookback → controls the range used to build the re-entry pocket.

• Re-Entry Depth settings → define the shallow, ideal, and deep areas of the pocket.

• Thresholds → control WATCH, READY, and CONFIRMED state requirements.

• Visual settings → control zones, EMA stack, labels, panel theme, panel location, and font sizes.


🖥️ Interface & Visual Design

The interface is built around a clean AG Pro panel and chart-first planning visuals.

The re-entry pocket and target-room guide are intentionally restrained so price remains readable. Labels are limited and spaced to keep the chart informative without becoming crowded.

The first panel row uses the standard AGPro merged blue header format.


🧪 Practical Usage Workflow

1. Read the panel to identify trend side and current action.

2. Check whether price is interacting with the re-entry pocket.

3. Evaluate the score, pullback depth, and risk edge.

4. Wait for READY or CONFIRMED state before treating the context as review-worthy.

5. Rebuild the plan if the invalidation edge is crossed.


🔍 Interpretation Guidelines

Think in terms of planning quality, not certainty.

A higher score means the current pullback has more constructive re-entry characteristics according to the script's rule set. A lower score means the pullback is less organized, has poor target room, lacks a clear trigger, or has moved too close to invalidation.

Use the script as a structure-reading tool within broader market context.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not an auto-trading system

• Not guaranteed signals

• Not a SuperTrend pullback clone

• Not a generic support/resistance zone map


⚠️ Limitations & Transparency

The script is rule-based and depends on visible chart data.

Timeframe differences, volatility shifts, low liquidity, and sudden news events can change how re-entry structure appears.

The score reflects the internal model only. It does not know future order flow, future liquidity, or future market intent.


🧠 Market Context Notes

Trend re-entry quality is usually clearer when a market has directional structure, a readable impulse, and enough room before nearby obstacles.

When a trend is mature, overly extended, or choppy, the same pullback behavior may carry less useful information.


🧾 Use Case Examples

When price pulls into the re-entry pocket during a bullish EMA stack and then prints a constructive trigger candle, the script may shift from WATCH to READY or CONFIRMED.

When price crosses the invalidation edge, the script marks the context as INVALIDATED so the user can rebuild the plan instead of forcing the old structure.


🧱 System Philosophy

AGPro planning tools are designed to turn chart structure into a clearer decision workflow.

This script follows that philosophy by focusing on context, readiness, risk edge, and next action rather than simple signal output.


🔐 Non-Promise Statement

No script can guarantee continuation, reversal, profit, or accuracy.

This tool provides structured context only. Users should combine it with their own analysis, timeframe review, and risk management process.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions, position sizing, trade management, and risk control.

This script does not provide financial advice and does not guarantee trading outcomes.


📚 Educational Note

Trend Re-Entry Planner [AGPro Series] is intended to help users study how pullbacks behave inside active trend structure and how planning context can be organized more clearly.

## Source Code

````pine
// -------------------------------------------------
// Trend Re-Entry Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Trend Re-Entry Planner is a chart-first trend continuation planning tool
// that evaluates whether an active trend pullback is creating a clean
// re-entry context. It maps a re-entry pocket, trend defense line,
// invalidation edge, target-room guide, 0-100 readiness score, and next-action
// state without becoming a SuperTrend pullback clone or a generic signal map.
// Version 1.3 sharpens the decision map with exact zone-center badges,
// a compact target-guide band, explicit risk ownership, state-aligned actions,
// and independent visual-event and alert controls. The trend re-entry engine
// and continuation-rate proof remain unchanged.
// -------------------------------------------------

//@version=6
indicator("Trend Re-Entry Planner [AGPro Series]",
     shorttitle = "AG Pro TRE",
     overlay = true,
     max_boxes_count = 60,
     max_labels_count = 220,
     max_lines_count = 100)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
G_ENGINE = "Trend Re-Entry Engine"
G_SCORE = "Readiness Model"
G_VISUAL = "Chart Visuals"
G_LABELS = "Labels"
G_PANEL = "Panel"
G_ALERTS = "Alerts"

planningProfile = input.string("Hourly Focus", "Planning Profile", options = ["Hourly Focus", "Manual Inputs", "Higher-Timeframe"], group = G_ENGINE,
     tooltip = "Selects the planning profile. Hourly Focus is tuned for active 1H/4H re-entry planning. Manual Inputs uses the lengths and windows below.")
fastLength = input.int(21, "Fast EMA Length", minval = 3, maxval = 200, group = G_ENGINE,
     tooltip = "Fast EMA used to detect near-term trend engagement. It is part of the trend stack, not a standalone entry signal.")
midLength = input.int(50, "Mid EMA Length", minval = 5, maxval = 300, group = G_ENGINE,
     tooltip = "Mid EMA used as the main re-entry reset reference. Pullbacks that reset near this line are scored more favorably.")
slowLength = input.int(100, "Slow EMA Length", minval = 10, maxval = 500, group = G_ENGINE,
     tooltip = "Slow EMA used to define broader trend structure and trend defense.")
slopeLookback = input.int(12, "Trend Slope Lookback", minval = 2, maxval = 80, group = G_ENGINE,
     tooltip = "Number of bars used to measure EMA slope. Higher values create a slower trend filter; lower values react faster.")
impulseLookback = input.int(64, "Impulse Lookback", minval = 20, maxval = 300, group = G_ENGINE,
     tooltip = "Lookback window used to map the current impulse range. The re-entry pocket is built from this range rather than from SuperTrend.")
maxImpulseAge = input.int(90, "Max Impulse Age", minval = 10, maxval = 260, group = G_ENGINE,
     tooltip = "Maximum bars after the impulse extreme where the re-entry plan remains active.")
atrLength = input.int(14, "ATR Length", minval = 3, maxval = 100, group = G_ENGINE,
     tooltip = "ATR period used for normalization, defense buffers, label spacing, and target-room measurement.")
sensitivity = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Aggressive"], group = G_ENGINE,
     tooltip = "Controls how selective the score model is. Conservative requires a stronger reset and trigger; Aggressive allows broader planning contexts.")
confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = G_ENGINE,
     tooltip = "Controls whether event labels and alerts wait for bar close. Close Confirmed is the recommended publication setting.")

shallowDepth = input.float(0.24, "Shallow Re-Entry Depth", minval = 0.05, maxval = 0.70, step = 0.01, group = G_SCORE,
     tooltip = "Shallow side of the re-entry pocket as a percentage of the active impulse range.")
deepDepth = input.float(0.58, "Deep Re-Entry Depth", minval = 0.15, maxval = 0.90, step = 0.01, group = G_SCORE,
     tooltip = "Deep side of the re-entry pocket as a percentage of the active impulse range. Pullbacks beyond this area are treated as higher risk.")
idealDepth = input.float(0.38, "Ideal Re-Entry Depth", minval = 0.10, maxval = 0.80, step = 0.01, group = G_SCORE,
     tooltip = "Preferred pullback depth inside the re-entry pocket.")
responseWindow = input.int(5, "Trigger Window Bars", minval = 1, maxval = 30, group = G_SCORE,
     tooltip = "Number of bars after a pocket touch where trigger behavior can still qualify as part of the same re-entry plan.")
defenseBufferAtr = input.float(0.22, "Invalidation Buffer ATR", minval = 0.00, maxval = 2.00, step = 0.01, group = G_SCORE,
     tooltip = "ATR buffer beyond the deep pocket used to draw the invalidation edge. It is a planning reference, not a stop instruction.")
targetExtension = input.float(0.18, "Target-Room Extension", minval = 0.00, maxval = 0.90, step = 0.01, group = G_SCORE,
     tooltip = "Extension beyond the impulse extreme used to estimate target-room context.")
readyThreshold = input.int(68, "READY Threshold", minval = 40, maxval = 95, group = G_SCORE,
     tooltip = "Minimum 0-100 score required for READY state.")
confirmedThreshold = input.int(78, "CONFIRMED Threshold", minval = 50, maxval = 98, group = G_SCORE,
     tooltip = "Minimum 0-100 score required for CONFIRMED state after a qualifying trigger candle.")
watchThreshold = input.int(54, "WATCH Threshold", minval = 25, maxval = 90, group = G_SCORE,
     tooltip = "Minimum 0-100 score required for WATCH state.")
minTargetRoomAtr = input.float(1.10, "Minimum Target Room ATR", minval = 0.10, maxval = 8.00, step = 0.05, group = G_SCORE,
     tooltip = "Minimum ATR-normalized room preferred between current price and the target-room guide.")
continuationWindow = input.int(20, "Continuation Proof Window (bars)", minval = 5, maxval = 200, group = G_SCORE,
     tooltip = "Number of bars a ready re-entry context has to continue in the trend direction within, for the Continuation Rate proof. It only measures historical follow-through and is not a forecast.")

showReEntryPocket = input.bool(true, "Show Re-Entry Pocket", group = G_VISUAL,
     tooltip = "Shows the active re-entry pocket with a separate centered badge.")
showTargetRoom = input.bool(true, "Show Target-Room Guide", group = G_VISUAL,
     tooltip = "Shows the forward target-room guide from the current re-entry context toward the impulse extension.")
showDefenseLine = input.bool(true, "Show Invalidation Edge", group = G_VISUAL,
     tooltip = "Shows the invalidation edge behind the re-entry pocket.")
showTrendMAs = input.bool(true, "Show Trend EMA Stack", group = G_VISUAL,
     tooltip = "Shows the trend EMA stack used by the planner.")
showCenteredBadges = input.bool(true, "Show Centered Zone Badges", group = G_VISUAL,
     tooltip = "Shows contrast-safe centered badges for the re-entry pocket and target-room structure.")
targetBandAtr = input.float(0.35, "Target Guide Band (ATR)", minval = 0.10, maxval = 1.50, step = 0.05, group = G_VISUAL,
     tooltip = "Controls the visual thickness of the target-guide band. The exact target price and target-room calculation remain unchanged.")
projectionBars = input.int(44, "Forward Render Bars", minval = 8, maxval = 180, group = G_VISUAL,
     tooltip = "Controls how far the re-entry pocket, target-room guide, and planning lines extend to the right.")
zoneTransparency = input.int(88, "Zone Transparency", minval = 75, maxval = 96, group = G_VISUAL,
     tooltip = "Controls the opacity of the re-entry pocket and target-room guide.")

showEventLabels = input.bool(true, "Show Event Labels", group = G_LABELS,
     tooltip = "Shows Ready, Confirmed, Invalidated, and Follow-Through labels with controlled spacing.")
showContextLabels = input.bool(true, "Show Sparse Context Labels", group = G_LABELS,
     tooltip = "Adds sparse context labels during active re-entry planning so the chart stays readable without clutter.")
showLabelScore = input.bool(true, "Show Label Score", group = G_LABELS,
     tooltip = "Adds the 0-100 readiness score to chart labels.")
labelCooldownBars = input.int(18, "Label Cooldown Bars", minval = 1, maxval = 120, group = G_LABELS,
     tooltip = "Minimum bars between event labels. Higher values reduce label density.")
contextSpacingBars = input.int(56, "Context Label Spacing", minval = 8, maxval = 240, group = G_LABELS,
     tooltip = "Minimum bars between sparse context labels during ongoing watch or ready states.")
maxVisibleLabels = input.int(9, "Max Visible Labels", minval = 4, maxval = 80, group = G_LABELS,
     tooltip = "Maximum number of recent labels retained on the chart.")
labelOffsetAtr = input.float(1.20, "Label Offset ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = G_LABELS,
     tooltip = "ATR-based label offset that keeps labels above or below candles.")
labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_LABELS,
     tooltip = "Controls all chart labels, centered badges, and right-side tags.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro planning panel.")
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = G_PANEL,
     tooltip = "Moves the AG Pro panel to the preferred chart location.")
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = G_PANEL,
     tooltip = "Switches the panel between premium dark, slate, and clean light themes.")
panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL,
     tooltip = "Controls panel text size.")

alertReady = input.bool(true, "Alert: Ready", group = G_ALERTS,
     tooltip = "Enables alerts when a pullback reaches READY state.")
alertConfirmed = input.bool(true, "Alert: Confirmed", group = G_ALERTS,
     tooltip = "Enables alerts when a re-entry context shifts to CONFIRMED after a qualifying trigger candle.")
alertInvalidated = input.bool(true, "Alert: Invalidated", group = G_ALERTS,
     tooltip = "Enables alerts when the active re-entry plan crosses its invalidation edge.")
alertFollowThrough = input.bool(false, "Alert: Follow-Through", group = G_ALERTS,
     tooltip = "Enables alerts when the confirmed re-entry context produces a follow-through marker.")

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBg = color.rgb(15, 23, 42)
panelBgSlate = color.rgb(30, 41, 59)
panelBgLight = color.rgb(248, 250, 252)
panelBorder = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
panelLabelLight = color.rgb(71, 85, 105)
panelValueLight = color.rgb(15, 23, 42)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)
dangerColor = color.rgb(239, 68, 68)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(nz(value, minValue), minValue), maxValue)

f_norm_high_good(float value, float weak, float strong) =>
    float span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low_good(float value, float good, float bad) =>
    float span = bad - good
    span == 0.0 ? 0.0 : f_clamp((bad - value) / span * 100.0, 0.0, 100.0)

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    value <= idealValue ? f_norm_high_good(value, lowValue, idealValue) : f_norm_low_good(value, idealValue, highValue)

f_size(string sizeText) =>
    sizeText == "Tiny" ? size.tiny :
     sizeText == "Small" ? size.small :
     sizeText == "Large" ? size.large : size.normal

f_panel_position(string posText) =>
    posText == "Top Left" ? position.top_left :
     posText == "Top Center" ? position.top_center :
     posText == "Top Right" ? position.top_right :
     posText == "Middle Left" ? position.middle_left :
     posText == "Middle Center" ? position.middle_center :
     posText == "Middle Right" ? position.middle_right :
     posText == "Bottom Left" ? position.bottom_left :
     posText == "Bottom Center" ? position.bottom_center : position.bottom_right

f_panel_bg(string theme) =>
    theme == "Clean Light" ? panelBgLight : theme == "Slate" ? panelBgSlate : panelBg

f_panel_label(string theme) =>
    theme == "Clean Light" ? panelLabelLight : panelLabelCol

f_panel_value(string theme) =>
    theme == "Clean Light" ? panelValueLight : panelValueCol

f_grade(float score) =>
    score >= 82.0 ? "A" : score >= 70.0 ? "B" : score >= 56.0 ? "C" : "D"

f_fmt(float value) =>
    na(value) ? "-" : str.tostring(value, "#.##")

f_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_panel_cell(table panelRef, int col, int row, string txt, color txtColor, color bgColor, string sizeInput) =>
    table.cell(panelRef, col, row, txt, text_color = txtColor, bgcolor = bgColor, text_size = f_size(sizeInput))

f_set_badge(label badge, int x, float y, string txt, color bg, color tx, string sizeInput) =>
    label.set_x(badge, x)
    label.set_y(badge, y)
    label.set_text(badge, txt)
    label.set_color(badge, bg)
    label.set_textcolor(badge, tx)
    label.set_size(badge, f_size(sizeInput))
    label.set_style(badge, label.style_label_center)

f_set_edge_badge(label badge, int x, float y, string txt, color bg, color tx, string sizeInput) =>
    label.set_x(badge, x)
    label.set_y(badge, y)
    label.set_text(badge, txt)
    label.set_color(badge, bg)
    label.set_textcolor(badge, tx)
    label.set_size(badge, f_size(sizeInput))
    label.set_style(badge, label.style_label_left)

f_hide_badge(label badge) =>
    label.set_text(badge, "")
    label.set_color(badge, color.new(color.white, 100))
    label.set_textcolor(badge, color.new(color.white, 100))
    label.set_x(badge, bar_index)
    label.set_y(badge, close)

f_push_label(array<label> labels, label newLabel, int maxCount) =>
    array.push(labels, newLabel)
    if array.size(labels) > maxCount
        label.delete(array.shift(labels))

// -------------------------------------------------
// Core Trend Context
// -------------------------------------------------
confirmReady = confirmationMode == "Live Updating" or barstate.isconfirmed
hourlyFocus = planningProfile == "Hourly Focus"
higherTimeframe = planningProfile == "Higher-Timeframe"
fastLen = hourlyFocus ? 21 : higherTimeframe ? 34 : fastLength
midLen = hourlyFocus ? 50 : higherTimeframe ? 89 : midLength
slowLen = hourlyFocus ? 100 : higherTimeframe ? 200 : slowLength
slopeBars = hourlyFocus ? 10 : higherTimeframe ? 16 : slopeLookback
impulseBars = hourlyFocus ? 72 : higherTimeframe ? 52 : impulseLookback
maxImpulseBars = hourlyFocus ? 110 : higherTimeframe ? 80 : maxImpulseAge
triggerBars = hourlyFocus ? 5 : higherTimeframe ? 4 : responseWindow

atrValue = ta.atr(atrLength)
safeAtr = math.max(nz(atrValue, ta.tr(true)), syminfo.mintick)
emaFast = ta.ema(close, fastLen)
emaMid = ta.ema(close, midLen)
emaSlow = ta.ema(close, slowLen)
slopeRaw = (emaMid - nz(emaMid[slopeBars], emaMid)) / safeAtr
bullStack = emaFast > emaMid and emaMid > emaSlow and slopeRaw > 0.0
bearStack = emaFast < emaMid and emaMid < emaSlow and slopeRaw < 0.0
trendSide = bullStack ? 1 : bearStack ? -1 : 0
activeTrend = trendSide != 0

highRef = ta.highest(high, impulseBars)
lowRef = ta.lowest(low, impulseBars)
highAgeRaw = ta.highestbars(high, impulseBars)
lowAgeRaw = ta.lowestbars(low, impulseBars)
highAge = highAgeRaw < 0 ? -highAgeRaw : highAgeRaw
lowAge = lowAgeRaw < 0 ? -lowAgeRaw : lowAgeRaw
impulseAge = trendSide == 1 ? highAge : trendSide == -1 ? lowAge : 999999
impulseFresh = impulseAge > 0 and impulseAge <= maxImpulseBars
impulseRange = math.max(math.abs(highRef - lowRef), safeAtr * 1.20)

float pocketTop = na
float pocketBottom = na
float targetGuide = na
float invalidationEdge = na

if trendSide == 1
    pocketTop := highRef - impulseRange * shallowDepth
    pocketBottom := highRef - impulseRange * deepDepth
    targetGuide := highRef + impulseRange * targetExtension
    invalidationEdge := pocketBottom - safeAtr * defenseBufferAtr
else if trendSide == -1
    pocketTop := lowRef + impulseRange * deepDepth
    pocketBottom := lowRef + impulseRange * shallowDepth
    targetGuide := lowRef - impulseRange * targetExtension
    invalidationEdge := pocketTop + safeAtr * defenseBufferAtr

validPocket = activeTrend and impulseFresh and not na(pocketTop) and not na(pocketBottom) and pocketTop > pocketBottom
priceTouchesPocket = validPocket and high >= pocketBottom and low <= pocketTop
barsSinceTouch = ta.barssince(priceTouchesPocket)
touchedRecently = not na(barsSinceTouch) and barsSinceTouch <= triggerBars
closeInsidePocket = validPocket and close <= pocketTop and close >= pocketBottom
pullbackDepth = trendSide == 1 ? (highRef - low) / impulseRange : trendSide == -1 ? (high - lowRef) / impulseRange : na
beyondDeepPocket = validPocket and (trendSide == 1 ? close < pocketBottom : trendSide == -1 ? close > pocketTop : false)
invalidated = validPocket and (trendSide == 1 ? close < invalidationEdge : trendSide == -1 ? close > invalidationEdge : false)

// -------------------------------------------------
// Readiness Scoring
// -------------------------------------------------
sensitivityBias = sensitivity == "Conservative" ? -6.0 : sensitivity == "Aggressive" ? 5.0 : 0.0
slopeDirectional = trendSide == 1 ? slopeRaw : trendSide == -1 ? -slopeRaw : 0.0
trendSlopeScore = activeTrend ? f_norm_high_good(slopeDirectional, 0.02, 0.55) : 0.0
depthScore = validPocket and not na(pullbackDepth) ? f_peak_score(pullbackDepth, shallowDepth, idealDepth, deepDepth) : 0.0
resetDistance = math.abs(close - emaMid) / safeAtr
trendSideHeld = trendSide == 1 ? close > emaSlow : trendSide == -1 ? close < emaSlow : false
resetLocationScore = f_norm_low_good(resetDistance, 0.10, 2.20)
resetScore = activeTrend and trendSideHeld ? resetLocationScore : resetLocationScore * 0.35

barRange = math.max(high - low, syminfo.mintick)
closeLocation = (close - low) / barRange
directionalClose = trendSide == 1 ? closeLocation : trendSide == -1 ? 1.0 - closeLocation : 0.5
bodyAtr = math.abs(close - open) / safeAtr
directionCandle = trendSide == 1 ? close > open : trendSide == -1 ? close < open : false
fastReclaim = trendSide == 1 ? close > emaFast : trendSide == -1 ? close < emaFast : false
triggerScoreRaw = activeTrend ? (directionCandle ? 35.0 : 5.0) + f_norm_high_good(directionalClose, 0.45, 0.85) * 0.40 + f_norm_high_good(bodyAtr, 0.08, 0.85) * 0.25 : 0.0
triggerScore = f_clamp(fastReclaim ? triggerScoreRaw : triggerScoreRaw * 0.72, 0.0, 100.0)

targetRoomAtr = trendSide == 1 ? (targetGuide - close) / safeAtr : trendSide == -1 ? (close - targetGuide) / safeAtr : na
targetRoomScore = activeTrend and not na(targetRoomAtr) ? f_norm_high_good(targetRoomAtr, minTargetRoomAtr * 0.55, minTargetRoomAtr + 2.20) : 0.0
readinessScore = f_clamp(trendSlopeScore * 0.22 + depthScore * 0.21 + resetScore * 0.19 + triggerScore * 0.22 + targetRoomScore * 0.16 + sensitivityBias, 0.0, 100.0)

triggerReady = activeTrend and touchedRecently and directionCandle and fastReclaim and confirmReady
roomClean = not na(targetRoomAtr) and targetRoomAtr >= minTargetRoomAtr
readyState = validPocket and not invalidated and readinessScore >= readyThreshold and roomClean and (closeInsidePocket or touchedRecently)
confirmedState = validPocket and not invalidated and triggerReady and readinessScore >= confirmedThreshold and roomClean
watchState = validPocket and not invalidated and readinessScore >= watchThreshold and (closeInsidePocket or touchedRecently)
followThroughState = confirmedState and (trendSide == 1 ? close > nz(highRef[1], highRef) : trendSide == -1 ? close < nz(lowRef[1], lowRef) : false)

trendText = trendSide == 1 ? "Bull Trend" : trendSide == -1 ? "Bear Trend" : "No Trend"
stateText = not activeTrend ? "No Trend" :
     not impulseFresh ? "Stale Impulse" :
     invalidated ? "Invalidated" :
     followThroughState ? "Follow-Through" :
     confirmedState ? "Confirmed" :
     readyState ? "Ready" :
     beyondDeepPocket ? "Deep Pullback" :
     watchState ? "Watch" : "Wait Reset"
actionText = not activeTrend ? "Wait For Stack" :
     not impulseFresh ? "Rebuild Plan" :
     invalidated ? "Reset Plan" :
     followThroughState ? "Monitor Extension" :
     confirmedState ? "Plan Active" :
     readyState ? "Review Trigger" :
     beyondDeepPocket ? "Review Risk" :
     watchState ? "Track Response" : "Wait For Reset"
trendColor = trendSide == 1 ? bullColor : trendSide == -1 ? bearColor : neutralColor
stateColor = stateText == "Ready" or stateText == "Confirmed" ? trendColor :
     stateText == "Invalidated" ? bearColor :
     stateText == "Follow-Through" ? accentColor : neutralColor
stateTextColor = stateText == "Watch" or stateText == "Deep Pullback" or stateText == "Wait Reset" ? color.rgb(17, 24, 39) : headerText

scoreText = activeTrend ? str.tostring(math.round(readinessScore)) + "/100  " + f_grade(readinessScore) : "n/a"
scoreLabel = showLabelScore ? "\nScore " + str.tostring(math.round(readinessScore)) : ""
depthText = validPocket and not na(pullbackDepth) ? str.tostring(math.round(pullbackDepth * 100.0)) + "%" : "n/a"
riskDistanceAtr = trendSide == 1 ? (close - invalidationEdge) / safeAtr : trendSide == -1 ? (invalidationEdge - close) / safeAtr : na
riskText = validPocket and not na(riskDistanceAtr) ? f_fmt(riskDistanceAtr) + " ATR" : "n/a"
roomText = activeTrend and not na(targetRoomAtr) ? f_fmt(targetRoomAtr) + " ATR" : "n/a"

// -------------------------------------------------
// Continuation-rate proof (Confirm Rate)
// -------------------------------------------------
var int   contTotal  = 0
var int   contWon     = 0
var bool  contPend     = false
var int   contDir      = 0
var float contAnchor   = na
var float contInv      = na
var int   contLeft     = 0
float contMargin = safeAtr * 0.75

bool readyFired = readyState and not readyState[1]

if barstate.isconfirmed
    if contPend and not na(contAnchor)
        bool favHit = contDir == 1 ? close >= contAnchor + contMargin : close <= contAnchor - contMargin
        bool invHit = not na(contInv) and (contDir == 1 ? close < contInv : close > contInv)
        bool advMove = contDir == 1 ? close <= contAnchor - contMargin : close >= contAnchor + contMargin
        bool advHit = invHit or advMove
        if favHit
            contTotal += 1
            contWon += 1
            contPend := false
        else if advHit
            contTotal += 1
            contPend := false
        else
            contLeft -= 1
            if contLeft <= 0
                contTotal += 1
                contPend := false
    if readyFired and trendSide != 0 and not contPend
        contPend := true
        contDir := trendSide
        contAnchor := close
        contInv := invalidationEdge
        contLeft := continuationWindow

float contRate = contTotal > 0 ? contWon / contTotal * 100.0 : na
string contText = contTotal > 0 ? str.tostring(math.round(contRate)) + "% (" + str.tostring(contTotal) + ")" : "Building"
color contColor = na(contRate) ? f_panel_value(panelTheme) : contRate >= 60.0 ? bullColor : contRate >= 45.0 ? neutralColor : bearColor

// -------------------------------------------------
// Visual Zones and Lines
// -------------------------------------------------
var box reEntryBox = na
var box targetRoomBox = na
var line defenseLine = na
var line targetLine = na
var label pocketBadge = label.new(bar_index, close, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = accentColor, textcolor = headerText, size = f_size(labelFontSize), textalign = text.align_center)
var label targetBadge = label.new(bar_index, close, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = accentColor, textcolor = headerText, size = f_size(labelFontSize), textalign = text.align_center)
var label invalidationBadge = label.new(bar_index, close, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = bearColor, textcolor = headerText, size = f_size(labelFontSize), textalign = text.align_center)

leftEdge = validPocket ? math.max(bar_index - math.max(impulseAge, 1), bar_index - impulseBars) : bar_index
rightEdge = bar_index + projectionBars
badgeX = int(math.round((leftEdge + rightEdge) * 0.50))
pocketColor = trendSide == 1 ? bullColor : trendSide == -1 ? bearColor : neutralColor

if showReEntryPocket and validPocket
    if na(reEntryBox)
        reEntryBox := box.new(leftEdge, pocketTop, rightEdge, pocketBottom, xloc = xloc.bar_index, bgcolor = color.new(pocketColor, zoneTransparency), border_color = color.new(pocketColor, 35), border_width = 1)
    else
        box.set_lefttop(reEntryBox, leftEdge, pocketTop)
        box.set_rightbottom(reEntryBox, rightEdge, pocketBottom)
        box.set_bgcolor(reEntryBox, color.new(pocketColor, zoneTransparency))
        box.set_border_color(reEntryBox, color.new(pocketColor, 35))
    if showCenteredBadges
        pocketSide = trendSide == 1 ? "BULL" : "BEAR"
        pocketText = pocketSide + " RE-ENTRY POCKET\nQ " + str.tostring(math.round(readinessScore)) + " " + f_grade(readinessScore) + " | Depth " + depthText
        f_set_badge(pocketBadge, badgeX, (pocketTop + pocketBottom) * 0.50, pocketText, color.new(pocketColor, 0), headerText, labelFontSize)
    else
        f_hide_badge(pocketBadge)
else
    if not na(reEntryBox)
        box.delete(reEntryBox)
        reEntryBox := na
    f_hide_badge(pocketBadge)

targetTop = trendSide == 1 ? targetGuide : targetGuide + safeAtr * targetBandAtr
targetBottom = trendSide == 1 ? targetGuide - safeAtr * targetBandAtr : targetGuide
targetValid = showTargetRoom and validPocket and not invalidated and not na(targetRoomAtr) and targetRoomAtr > 0.0 and targetTop > targetBottom
if targetValid
    if na(targetRoomBox)
        targetRoomBox := box.new(bar_index, targetTop, rightEdge, targetBottom, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 91), border_color = color.new(accentColor, 45), border_width = 1)
    else
        box.set_lefttop(targetRoomBox, bar_index, targetTop)
        box.set_rightbottom(targetRoomBox, rightEdge, targetBottom)
        box.set_bgcolor(targetRoomBox, color.new(accentColor, 91))
        box.set_border_color(targetRoomBox, color.new(accentColor, 55))
    if showCenteredBadges
        targetBadgeX = int(math.round((bar_index + rightEdge) * 0.50))
        f_set_badge(targetBadge, targetBadgeX, (targetTop + targetBottom) * 0.50, "TARGET GUIDE\nRoom " + roomText, color.new(accentColor, 0), headerText, labelFontSize)
    else
        f_hide_badge(targetBadge)
else
    if not na(targetRoomBox)
        box.delete(targetRoomBox)
        targetRoomBox := na
    f_hide_badge(targetBadge)

if showDefenseLine and validPocket
    if na(defenseLine)
        defenseLine := line.new(leftEdge, invalidationEdge, rightEdge, invalidationEdge, xloc = xloc.bar_index, extend = extend.none, color = color.new(bearColor, 0), style = line.style_dashed, width = 2)
    else
        line.set_xy1(defenseLine, leftEdge, invalidationEdge)
        line.set_xy2(defenseLine, rightEdge, invalidationEdge)
        line.set_color(defenseLine, invalidated ? bearColor : color.new(trendColor, 10))
        line.set_width(defenseLine, invalidated ? 3 : 2)
    f_set_edge_badge(invalidationBadge, rightEdge, invalidationEdge, "INVALIDATION | " + f_price(invalidationEdge), color.new(bearColor, 0), headerText, labelFontSize)
else
    if not na(defenseLine)
        line.delete(defenseLine)
        defenseLine := na
    f_hide_badge(invalidationBadge)

if showTargetRoom and validPocket and not invalidated and not na(targetRoomAtr) and targetRoomAtr > 0.0
    if na(targetLine)
        targetLine := line.new(bar_index, targetGuide, rightEdge, targetGuide, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 0), style = line.style_solid, width = 1)
    else
        line.set_xy1(targetLine, bar_index, targetGuide)
        line.set_xy2(targetLine, rightEdge, targetGuide)
else
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na

plot(showTrendMAs ? emaFast : na, "Fast EMA", color = color.new(trendColor, 5), linewidth = 1)
plot(showTrendMAs ? emaMid : na, "Mid EMA", color = color.new(accentColor, 10), linewidth = 2)
plot(showTrendMAs ? emaSlow : na, "Slow EMA", color = color.new(panelLabelCol, 15), linewidth = 2)

// -------------------------------------------------
// Labels
// -------------------------------------------------
var array<label> chartLabels = array.new<label>()
var int lastEventLabelBar = na
var int lastContextLabelBar = na

readyEvent = readyState and not readyState[1] and confirmReady
confirmedEvent = confirmedState and not confirmedState[1] and confirmReady
invalidatedEvent = invalidated and not invalidated[1] and confirmReady
followThroughEvent = followThroughState and not followThroughState[1] and confirmReady
eventSpacingOk = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
eventNow = showEventLabels and eventSpacingOk and (followThroughEvent or confirmedEvent or readyEvent or invalidatedEvent)

if eventNow
    upStyle = trendSide == 1 and not invalidatedEvent
    eventY = upStyle ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    eventSide = trendSide == 1 ? "BULL" : trendSide == -1 ? "BEAR" : "PLAN"
    eventText = invalidatedEvent ? eventSide + " INVALIDATED\nRisk " + riskText :
         followThroughEvent ? eventSide + " FOLLOW-THROUGH" + scoreLabel :
         confirmedEvent ? eventSide + " CONFIRMED" + scoreLabel : eventSide + " READY" + scoreLabel
    eventColor = invalidatedEvent ? bearColor : followThroughEvent ? accentColor : trendColor
    newEventLabel = label.new(bar_index, eventY, eventText, xloc = xloc.bar_index, yloc = yloc.price, style = upStyle ? label.style_label_up : label.style_label_down, color = color.new(eventColor, 3), textcolor = headerText, size = f_size(labelFontSize))
    f_push_label(chartLabels, newEventLabel, maxVisibleLabels)
    lastEventLabelBar := bar_index

contextEligible = showContextLabels and confirmReady and validPocket and not invalidated and (watchState or readyState or confirmedState) and not eventNow
contextSpacingOk = na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars
if contextEligible and contextSpacingOk
    contextUp = trendSide == 1
    contextY = contextUp ? low - safeAtr * (labelOffsetAtr + 0.55) : high + safeAtr * (labelOffsetAtr + 0.55)
    contextSide = trendSide == 1 ? "BULL" : "BEAR"
    contextText = contextSide + " " + str.upper(stateText)
    contextEvidence = showLabelScore ? "\nQ " + str.tostring(math.round(readinessScore)) + " | Depth " + depthText : ""
    newContextLabel = label.new(bar_index, contextY, contextText + contextEvidence, xloc = xloc.bar_index, yloc = yloc.price, style = contextUp ? label.style_label_up : label.style_label_down, color = color.new(stateColor, 5), textcolor = stateTextColor, size = f_size(labelFontSize))
    f_push_label(chartLabels, newContextLabel, maxVisibleLabels)
    lastContextLabelBar := bar_index

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelBodyBg = f_panel_bg(panelTheme)
panelLeftBg = panelTheme == "Clean Light" ? color.rgb(226, 232, 240) : panelBorder
panelLabel = f_panel_label(panelTheme)
panelValue = f_panel_value(panelTheme)
scoreRead = activeTrend ? scoreText + " | " + stateText : "n/a"
riskRead = validPocket ? riskText + " | Room " + roomText : "n/a"

var table panel = table.new(f_panel_position(panelLocation), 2, 7, bgcolor = panelBodyBg, frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)

if barstate.islast
    table.set_position(panel, f_panel_position(panelLocation))
    if showPanel
        table.clear(panel, 0, 0, 1, 6)
        table.merge_cells(panel, 0, 0, 1, 0)
        f_panel_cell(panel, 0, 0, "AG Pro Trend Re-Entry Planner", headerText, headerBg, panelFontSize)
        f_panel_cell(panel, 0, 1, "Trend Side", panelLabel, panelLeftBg, panelFontSize)
        f_panel_cell(panel, 1, 1, trendText, trendColor, panelBodyBg, panelFontSize)
        f_panel_cell(panel, 0, 2, "Re-Entry Score", panelLabel, panelLeftBg, panelFontSize)
        f_panel_cell(panel, 1, 2, scoreRead, stateColor, panelBodyBg, panelFontSize)
        f_panel_cell(panel, 0, 3, "Continuation Rate", panelLabel, panelLeftBg, panelFontSize)
        f_panel_cell(panel, 1, 3, contText, contColor, panelBodyBg, panelFontSize)
        f_panel_cell(panel, 0, 4, "Pullback Depth", panelLabel, panelLeftBg, panelFontSize)
        f_panel_cell(panel, 1, 4, depthText, depthScore >= 65.0 ? trendColor : neutralColor, panelBodyBg, panelFontSize)
        f_panel_cell(panel, 0, 5, "Risk Edge", panelLabel, panelLeftBg, panelFontSize)
        f_panel_cell(panel, 1, 5, riskRead, roomClean ? accentColor : neutralColor, panelBodyBg, panelFontSize)
        f_panel_cell(panel, 0, 6, "Action", panelLabel, panelLeftBg, panelFontSize)
        f_panel_cell(panel, 1, 6, actionText, stateColor, panelBodyBg, panelFontSize)
    else
        table.clear(panel, 0, 0, 1, 6)

// -------------------------------------------------
// Data window
// -------------------------------------------------
plot(activeTrend ? readinessScore : na, "Readiness Score", color = stateColor, display = display.data_window)
plot(contRate, "Continuation Rate", color = bullColor, display = display.data_window)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertReady and readyEvent, "Trend Re-Entry Ready", "Trend Re-Entry Planner: a pullback has reached READY state with sufficient re-entry context on {{ticker}}.")
alertcondition(alertConfirmed and confirmedEvent, "Trend Re-Entry Confirmed", "Trend Re-Entry Planner: re-entry context shifted to CONFIRMED after a qualifying trigger candle on {{ticker}}.")
alertcondition(alertInvalidated and invalidatedEvent, "Trend Re-Entry Invalidated", "Trend Re-Entry Planner: the active re-entry plan crossed its invalidation edge on {{ticker}}.")
alertcondition(alertFollowThrough and followThroughEvent, "Trend Re-Entry Follow-Through", "Trend Re-Entry Planner: the confirmed re-entry context produced a follow-through marker on {{ticker}}.")
````
