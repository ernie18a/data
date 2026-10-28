# Moving Average Retest Planner [AGPro Series]

- url: https://www.tradingview.com/script/gVKFDLAj-Moving-Average-Retest-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;734e8596a044407f965720027648d2de
- version: 3.0

## Description

Moving Average Retest Planner [AGPro Series]

🧠 Core Idea

Is a moving average retest clean enough to act as trend support or resistance, or is the reaction too weak to plan around?


📌 Overview / What it does

Moving Average Retest Planner is a chart-first planning tool built around one practical workflow: price moves away from an active moving average, returns into a controlled retest pocket, and the script evaluates whether that reaction has enough quality to deserve attention.

The script produces a moving average reference, a retest distance band, concept-native retest pockets, hold / watch / fail labels, invalidation rails, target rails, continuation markers, and a compact AGPro decision panel. It converts moving average slope, retest depth, wick response, close quality, relative volume, and target room into a normalized 0-100 Reaction Score.

It does not predict future price movement, automate trading, or claim that a moving average touch is automatically meaningful. Its role is to organize the current retest context into a clearer decision-support workflow.


🎯 Purpose & Design Philosophy

This script was built because many moving average tools stop at the most basic question: is price above or below the average?

That is rarely enough for real chart planning. A retest can be too early, too deep, too weak, or too close to nearby obstruction. The purpose of this script is to help traders evaluate whether the retest itself is clean, controlled, and supported by the surrounding structure.

The design supports traders who use moving averages as contextual references but want a more structured way to assess reaction quality, risk edge, and next action.


⚡ Why This Script Is Different

Most moving average tools focus on crossovers, ribbon direction, fixed EMA reclaim events, or simple above / below filters.

This script does NOT clone a 200 EMA reclaim map, a moving average ribbon stress model, a Hull MA zone tool, or a KAMA efficiency framework.

Instead, it focuses on one narrower decision layer: after price has moved away from an active configurable moving average, is the return into that average being defended or rejected with enough quality to become a valid planning area?


⚙️ Methodology

1. Context Detection
The script calculates the active moving average and checks whether the average has a meaningful slope. It separates bullish, bearish, and neutral contexts.

2. Reference Mapping
An ATR-normalized retest band is built around the active moving average. This band is used as the planning pocket rather than as a generic support / resistance zone.

3. Reaction Evaluation
When price returns into the band after moving away from it, the script evaluates slope quality, retest depth, wick response, close location, relative volume, and target room.

4. Visual Output
Qualified reactions can create retest pockets, hold / watch / fail labels, invalidation rails, target rails, continuation markers, alerts, and panel updates.


🗺️ How to Read the Chart

Zones = the active moving average retest pocket where price is being evaluated.

Labels = compact event markers for watch, hold, failure, and follow-through states.

Colors = bullish states use teal, bearish states use pink, neutral / waiting states use amber, and projected target context uses indigo.

Panel = summarizes MA Retest, Trend Side, Reaction Score, Risk Edge, and Action.


🚦 Signals & States

• WATCH → price is reacting near the moving average, but quality is below the READY threshold.

• READY → the retest score meets the required quality threshold.

• WAIT RETEST → trend context exists, but no clean retest is active yet.

• INVALIDATED → the active retest lost its invalidation edge.

• FOLLOW-THROUGH → price moved far enough from the trigger close to mark continuation after the retest.

• NO PLAN → the current chart does not contain a usable MA retest context.


🔔 Alerts Logic

Alerts can trigger when a READY retest appears, when an active retest invalidates, when follow-through is detected, or when the planner state changes.

These alerts are attention markers. They are not trade instructions, entry signals, or automated recommendations.


🧩 Confluence Logic

The strongest context appears when MA slope, controlled retest depth, clean wick response, strong close quality, relative volume support, and target room align at the same time.

When those components improve together, the Reaction Score rises. When the retest becomes too deep, too weak, or too close to obstruction, the score remains lower.


📊 When to Use

• Trending markets where price repeatedly returns to an active moving average

• Pullback continuation contexts

• Trend support or trend resistance evaluation

• Markets with enough liquidity for moving average reactions to be readable

• Multi-timeframe review where one average acts as a workflow reference


⚠️ When NOT to Use

• Very low-liquidity symbols

• Flat, noisy, low-range conditions

• Extreme news-driven volatility

• Charts where the selected moving average has no meaningful slope

• Situations where price is chopping through the average without clean reaction behavior


🎛️ Key Inputs

• MA Type and MA Length → define the active retest reference.

• Sensitivity → controls retest pocket width and required prior distance.

• Confirmation Mode → controls how strict the close-side hold must be.

• Minimum READY Score → sets the threshold for a high-quality retest state.

• Target R → defines the projected target rail from the invalidation edge.

• Label Cooldown and Max Visible Event Sets → manage label density and chart cleanliness.

• Panel Location, Panel Theme, Panel Font Size, and Label Font Size → control publication-ready presentation.


🖥️ Interface & Visual Design

The interface is built around a clean chart-first hierarchy.

The moving average and distance band show the active reference. Retest pockets highlight only qualified reaction areas. Labels sit above or below candles using ATR offsets so they remain readable. The panel gives the current planning answer without turning the script into a crowded dashboard.


🧪 Practical Usage Workflow

1. Read the panel to identify the current Action.

2. Check whether the moving average has a clear bullish or bearish trend side.

3. Look for a retest pocket and review the Reaction Score.

4. Compare the invalidation rail and target rail to judge the risk edge.

5. Treat alerts as prompts for review, not standalone decisions.


🔍 Interpretation Guidelines

The script should be read as a structured context model.

A high score means the detected retest has stronger alignment across the script's rules. A low score means the reaction is weaker, late, noisy, or poorly positioned. A failed retest means the active planning edge was lost according to the selected inputs.

The output is most useful when combined with broader structure, timeframe context, liquidity, and the trader's own risk process.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not an auto trading system

• Not a guaranteed signal tool

• Not a replacement for risk management

• Not a generic moving average crossover indicator


⚠️ Limitations & Transparency

Moving averages are lagging references. The selected length, asset, timeframe, volatility profile, and liquidity conditions can all affect how clean or noisy the retest behavior appears.

In strong trends, price may continue without giving a clean retest. In choppy markets, price may touch the average many times without creating meaningful structure. The score should be interpreted as a rule-based quality read, not certainty.


🧠 Market Context Notes

Moving average retests are most useful when the average represents an active path of value or trend behavior. The cleaner the slope and the more controlled the return into the average, the more useful the retest context usually becomes.

Liquidity, volatility, and nearby structural levels still matter. A strong-looking retest with poor target room may be less useful than a moderate retest with cleaner space.


🧾 Use Case Examples

When price trends above the selected average, pulls back into the retest band, rejects lower prices with a clear wick, closes back above the average, and has enough target room, the panel may move into READY.

When price returns to the average but closes weakly through the band or later crosses the invalidation rail, the retest can move into INVALIDATED.


🧱 System Philosophy

Moving Average Retest Planner follows the AGPro decision-engine approach: show the setup context, score its quality, define the risk edge, map the target area, and state the next action.

The goal is not to add another signal to the chart. The goal is to help traders read whether the current retest is organized enough to deserve attention.


🔐 Non-Promise Statement

No certainty.

No guaranteed continuation.

No guaranteed reversal.

No automated decision.


📉 Risk Disclosure

Trading involves risk. Market conditions can change quickly, and any indicator can produce false or incomplete readings.

This script is for educational and analytical purposes only. It does not provide financial advice, investment advice, or guaranteed trading outcomes.

Users are responsible for their own decisions, testing, position sizing, and risk management.


📚 Educational Note

Use this tool to study how price behaves when it returns to an active moving average. The most important output is not a label by itself, but the relationship between retest quality, invalidation, target room, and broader market context.

## Source Code

````pine
// -------------------------------------------------
// Moving Average Retest Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.7
//
// A public-free moving average retest planner for TradingView that evaluates
// whether price is reacting cleanly around an active trend average. The script
// combines MA slope, controlled retest depth, wick response, close quality,
// volume support, risk edge, target room, a stop-aware Hold Rate, and next-action
// state into a compact decision-engine workflow instead of another generic
// moving average signal.
// -------------------------------------------------

//@version=6
indicator("Moving Average Retest Planner [AGPro Series]",
     shorttitle = "AGP MART",
     overlay = true,
     max_labels_count = 160,
     max_boxes_count = 80,
     max_lines_count = 120)

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
inkDark       = color.rgb(15, 23, 42)
inkLight      = color.rgb(245, 247, 250)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Engine"
srcInput = input.source(close, "Source", group = groupEngine, tooltip = "Price source used to calculate the active moving average reference.")
maType = input.string("EMA", "MA Type", options = ["EMA", "SMA", "WMA", "RMA", "VWMA"], group = groupEngine, tooltip = "Selects the moving average used as the retest reference.")
maLength = input.int(50, "MA Length", minval = 5, maxval = 500, group = groupEngine, tooltip = "Length of the active moving average used for retest planning.")
slopeLookback = input.int(8, "Slope Lookback", minval = 2, maxval = 50, group = groupEngine, tooltip = "Bars used to evaluate whether the moving average has a meaningful trend slope.")
retestLookback = input.int(36, "Retest Lookback", minval = 10, maxval = 150, group = groupEngine, tooltip = "Window used to confirm that price moved away from the average before returning for a retest.")
sensitivity = input.string("Balanced", "Sensitivity", options = ["Tight", "Balanced", "Loose"], group = groupEngine, tooltip = "Controls how wide the retest pocket is and how much prior distance is required before a retest can qualify.")
confirmationMode = input.string("Close Hold", "Confirmation Mode", options = ["Early Watch", "Close Hold", "Strict Hold"], group = groupEngine, tooltip = "Defines how much close-side confirmation is required before a retest is promoted from watch context to planner context.")
minScore = input.int(64, "Minimum READY Score", minval = 1, maxval = 100, group = groupEngine, tooltip = "Minimum 0-100 reaction score required for a READY retest state.")

groupRisk = "Risk / Target"
atrLength = input.int(14, "ATR Length", minval = 1, maxval = 100, group = groupRisk, tooltip = "ATR length used to normalize the retest pocket, risk edge, label offsets, and target room.")
volumeLength = input.int(30, "Relative Volume Length", minval = 5, maxval = 200, group = groupRisk, tooltip = "Lookback used to compare current volume against typical volume for the score model.")
targetLookback = input.int(34, "Target Room Lookback", minval = 10, maxval = 200, group = groupRisk, tooltip = "Window used to estimate nearby swing room before the projected target area.")
targetRR = input.float(1.6, "Projected Target R", minval = 0.5, maxval = 5.0, step = 0.1, group = groupRisk, tooltip = "Risk multiple used to project the target rail from the retest invalidation edge.")
followThroughATR = input.float(0.75, "Follow-Through ATR", minval = 0.1, maxval = 3.0, step = 0.05, group = groupRisk, tooltip = "ATR distance from the trigger close required to mark a meaningful continuation event.")
holdWindow = input.int(40, "Hold Rate Window", minval = 8, maxval = 400, group = groupRisk, tooltip = "Bars allowed for a READY retest to reach its projected target (counts) or return to invalidation (counts as a miss) before the sample times out uncounted. Used by the Hold Rate.")

groupVisual = "Visuals"
showMA = input.bool(true, "Show Moving Average", group = groupVisual, tooltip = "Shows the active moving average line used by the planner.")
showPocket = input.bool(true, "Show Retest Pocket", group = groupVisual, tooltip = "Draws a centered retest pocket around qualifying moving average reactions.")
showPocketBadges = input.bool(true, "Show Centered Pocket Badges", group = groupVisual, tooltip = "Shows separate centered badges for retest pockets so zones always have clear ownership.")
showRiskRails = input.bool(true, "Show Risk / Target Rails", group = groupVisual, tooltip = "Shows invalidation and projected target rails for qualified retest events.")
showRailTags = input.bool(true, "Show Rail Tags", group = groupVisual, tooltip = "Shows compact target and invalidation tags at the right edge of each active rail pair.")
showLabels = input.bool(true, "Show Event Labels", group = groupVisual, tooltip = "Shows chart labels for hold, fail, and follow-through events.")
showSecondaryEventLabels = input.bool(false, "Show Secondary Event Labels", group = groupVisual, tooltip = "Shows extra WATCH and FLOW labels. Disabled by default to keep the publication view cleaner.")
showContinuationMarkers = input.bool(true, "Show Continuation Markers", group = groupVisual, tooltip = "Marks major follow-through after a qualified moving average retest.")
showPocketScore = input.bool(true, "Show Pocket Score", group = groupVisual, tooltip = "Adds the numeric retest score to centered pocket badges.")
showWatchPockets = input.bool(false, "Show Watch Pockets", group = groupVisual, tooltip = "When enabled, also draws pockets and centered badges for lower-quality WATCH retests. Disabled by default so only READY hold zones stay on the chart for a cleaner premium view. Fail labels are always kept.")
cooldownBars = input.int(12, "Label Cooldown Bars", minval = 0, maxval = 100, group = groupVisual, tooltip = "Minimum spacing between new planner labels to keep the chart readable.")
clusterReplaceBars = input.int(14, "Cluster Replace Bars", minval = 2, maxval = 40, group = groupVisual, tooltip = "When a fresh event appears near the previous one, the older label or zone is replaced so the chart stays clean.")
eventMemoryBars = input.int(220, "Event Memory Bars", minval = 20, maxval = 1000, group = groupVisual, tooltip = "Deletes older labels, pockets, and rails after the chosen bar count so stale events do not dominate the default view.")
maxVisibleObjects = input.int(5, "Max Visible Event Sets", minval = 2, maxval = 30, group = groupVisual, tooltip = "Limits visible labels, retest pockets, and rails so the chart stays premium and responsive.")
pocketExtendBars = input.int(14, "Pocket Extension Bars", minval = 5, maxval = 80, group = groupVisual, tooltip = "How far each retest pocket and risk rail extends into the future.")
labelOffsetATR = input.float(0.95, "Label Offset ATR", minval = 0.1, maxval = 3.5, step = 0.05, group = groupVisual, tooltip = "Vertical offset used to keep labels above or below candles instead of inside the candle body.")
labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisual, tooltip = "Controls the size of planner labels, rail tags, and centered pocket badges.")

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = "Shows or hides the AG Pro decision panel. It is enabled by default for publication clarity.")
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = "Selects where the planner panel appears on the chart.")
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = groupPanel, tooltip = "Switches the panel between AGPro dark and clean light themes.")
panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel, tooltip = "Controls panel text size while keeping the first row as one merged blue title row.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

// Luminance-aware text color: dark ink on light fills, light ink on dark fills.
f_text_on(color bg) =>
    float r = color.r(bg)
    float g = color.g(bg)
    float b = color.b(bg)
    float lum = 0.299 * r + 0.587 * g + 0.114 * b
    lum > 145 ? inkDark : inkLight

f_ma(series float source, int length, string kind) =>
    switch kind
        "SMA" => ta.sma(source, length)
        "WMA" => ta.wma(source, length)
        "RMA" => ta.rma(source, length)
        "VWMA" => ta.vwma(source, length)
        => ta.ema(source, length)

f_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_panel_position(string locationInput) =>
    switch locationInput
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_tier(float scoreValue) =>
    scoreValue >= 82 ? "A" : scoreValue >= 68 ? "B" : scoreValue >= 52 ? "C" : "D"

f_panel_bg() =>
    panelTheme == "Clean Light" ? color.rgb(248, 250, 252) : panelTheme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_border() =>
    panelTheme == "Clean Light" ? color.rgb(203, 213, 225) : panelBorder

f_panel_label() =>
    panelTheme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value() =>
    panelTheme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(int row) =>
    if panelTheme == "Clean Light"
        row % 2 == 0 ? color.rgb(241, 245, 249) : color.rgb(226, 232, 240)
    else
        row % 2 == 0 ? color.rgb(20, 31, 52) : f_panel_bg()

f_price(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_clear_labels(array<label> labels) =>
    while array.size(labels) > 0
        label oldLabel = array.shift(labels)
        if not na(oldLabel)
            label.delete(oldLabel)

f_trim_labels(array<label> labels, int maxKeep) =>
    while array.size(labels) > maxKeep
        label oldLabel = array.shift(labels)
        if not na(oldLabel)
            label.delete(oldLabel)

f_trim_label_pairs(array<label> labels, array<int> bars, int maxKeep) =>
    while array.size(labels) > maxKeep
        label oldLabel = array.shift(labels)
        if not na(oldLabel)
            label.delete(oldLabel)
        if array.size(bars) > 0
            array.shift(bars)

f_trim_boxes(array<box> boxes, int maxKeep) =>
    while array.size(boxes) > maxKeep
        box oldBox = array.shift(boxes)
        if not na(oldBox)
            box.delete(oldBox)

f_trim_box_pairs(array<box> boxes, array<int> bars, int maxKeep) =>
    while array.size(boxes) > maxKeep
        box oldBox = array.shift(boxes)
        if not na(oldBox)
            box.delete(oldBox)
        if array.size(bars) > 0
            array.shift(bars)

f_trim_lines(array<line> lines, int maxKeep) =>
    while array.size(lines) > maxKeep
        line oldLine = array.shift(lines)
        if not na(oldLine)
            line.delete(oldLine)

f_trim_line_pairs(array<line> lines, array<int> bars, int maxKeep) =>
    while array.size(lines) > maxKeep
        line oldLine = array.shift(lines)
        if not na(oldLine)
            line.delete(oldLine)
        if array.size(bars) > 0
            array.shift(bars)

f_badge_x(int leftX, int rightX) =>
    int(math.round(leftX + math.max(rightX - leftX, 1) * 0.15))

f_panel_cell(table panelRef, int col, int row, string txt, color txtColor, color bgColor, string alignInput) =>
    table.cell(panelRef, col, row, txt, text_color = txtColor, bgcolor = bgColor, text_size = f_size(panelFontSize), text_halign = alignInput == "left" ? text.align_left : alignInput == "right" ? text.align_right : text.align_center)

// -------------------------------------------------
// Core Engine
// -------------------------------------------------
ma = f_ma(srcInput, maLength, maType)
atrRaw = ta.atr(atrLength)
atr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)

bandMult = sensitivity == "Tight" ? 0.38 : sensitivity == "Loose" ? 0.72 : 0.52
awayMult = sensitivity == "Tight" ? 0.78 : sensitivity == "Loose" ? 0.46 : 0.60
closePad = confirmationMode == "Early Watch" ? -0.45 : confirmationMode == "Strict Hold" ? 0.12 : 0.0

band = atr * bandMult
upperBand = ma + band
lowerBand = ma - band

maSlope = ma - ma[slopeLookback]
slopeNorm = maSlope / atr
maReady = not na(ma) and not na(ma[slopeLookback]) and not na(atrRaw)

trendBull = maReady and close > ma and maSlope > atr * 0.015
trendBear = maReady and close < ma and maSlope < -atr * 0.015
trendSide = trendBull ? 1 : trendBear ? -1 : 0

bullAway = maReady and ta.highest(close - ma, retestLookback) > atr * awayMult
bearAway = maReady and ta.highest(ma - close, retestLookback) > atr * awayMult

bullNear = trendBull and bullAway and low <= upperBand and close >= lowerBand
bearNear = trendBear and bearAway and high >= lowerBand and close <= upperBand

bullConfirmed = bullNear and close >= ma + band * closePad
bearConfirmed = bearNear and close <= ma - band * closePad
retestSide = bullConfirmed ? 1 : bearConfirmed ? -1 : 0

barRange = math.max(high - low, syminfo.mintick)
closeLocation = f_clamp((close - low) / barRange, 0.0, 1.0)
lowerWick = math.max(math.min(open, close) - low, 0.0)
upperWick = math.max(high - math.max(open, close), 0.0)

slopeScore = f_clamp(math.abs(slopeNorm) * 85.0, 0.0, 100.0)
depthRef = retestSide == 1 ? low : retestSide == -1 ? high : ma
depthDist = math.abs(depthRef - ma)
penetration = retestSide == 1 ? math.max(ma - low, 0.0) : retestSide == -1 ? math.max(high - ma, 0.0) : 0.0
depthScore = f_clamp(100.0 - depthDist / band * 42.0 - penetration / band * 18.0, 0.0, 100.0)
wickScore = retestSide == 1 ? f_clamp(lowerWick / barRange * 160.0, 0.0, 100.0) : retestSide == -1 ? f_clamp(upperWick / barRange * 160.0, 0.0, 100.0) : 0.0
closeScore = retestSide == 1 ? f_clamp(closeLocation * 100.0 + (close > ma ? 10.0 : -25.0), 0.0, 100.0) : retestSide == -1 ? f_clamp((1.0 - closeLocation) * 100.0 + (close < ma ? 10.0 : -25.0), 0.0, 100.0) : 0.0

volBase = ta.sma(volume, volumeLength)
rvol = not na(volume) and not na(volBase) and volBase > 0 ? volume / volBase : 1.0
volumeScore = f_clamp((rvol - 0.65) / 1.05 * 100.0, 0.0, 100.0)

reactionScore = retestSide != 0 ? f_clamp(slopeScore * 0.22 + depthScore * 0.24 + wickScore * 0.18 + closeScore * 0.20 + volumeScore * 0.16, 0.0, 100.0) : 0.0
trendContextScore = f_clamp(slopeScore * 0.58 + volumeScore * 0.17 + (trendSide != 0 ? 25.0 : 0.0), 0.0, 100.0)

bullInvalid = ma - band * 1.25
bearInvalid = ma + band * 1.25
invalidation = retestSide == 1 ? bullInvalid : retestSide == -1 ? bearInvalid : na
riskDist = retestSide != 0 ? math.max(math.abs(close - invalidation), syminfo.mintick) : na

priorHigh = ta.highest(high, targetLookback)[1]
priorLow = ta.lowest(low, targetLookback)[1]
bullRoomRatio = not na(riskDist) and priorHigh > close ? (priorHigh - close) / riskDist : targetRR
bearRoomRatio = not na(riskDist) and priorLow < close ? (close - priorLow) / riskDist : targetRR
roomRatio = retestSide == 1 ? bullRoomRatio : retestSide == -1 ? bearRoomRatio : na
projectedTarget = retestSide == 1 ? close + riskDist * targetRR : retestSide == -1 ? close - riskDist * targetRR : na

strongRetest = retestSide != 0 and reactionScore >= minScore
watchRetest = retestSide != 0 and reactionScore >= math.max(minScore - 14, 1) and reactionScore < minScore

// -------------------------------------------------
// Planner State
// -------------------------------------------------
var int activeSide = 0
var int activeStart = na
var float activeInvalidation = na
var float activeTarget = na
var float activeTrigger = na
var float activeScore = na
var float activeRoomRatio = na
var string activePlanQuality = "None"
var int lastEventBar = na

cooldownReady = na(lastEventBar) or bar_index - lastEventBar >= cooldownBars
readySignalRaw = strongRetest and cooldownReady
watchSignalRaw = watchRetest and cooldownReady
newPlanSignal = readySignalRaw or watchSignalRaw

if newPlanSignal
    activeSide := retestSide
    activeStart := bar_index
    activeInvalidation := invalidation
    activeTarget := projectedTarget
    activeTrigger := close
    activeScore := reactionScore
    activeRoomRatio := roomRatio
    activePlanQuality := readySignalRaw ? "READY" : "WATCH"
    lastEventBar := bar_index

planAlive = activeSide != 0 and not na(activeStart) and bar_index - activeStart <= retestLookback
failSignalRaw = planAlive and ((activeSide == 1 and close < activeInvalidation) or (activeSide == -1 and close > activeInvalidation))
followSignalRaw = planAlive and not failSignalRaw and ((activeSide == 1 and close - activeTrigger >= atr * followThroughATR) or (activeSide == -1 and activeTrigger - close >= atr * followThroughATR))
expiredPlan = activeSide != 0 and not na(activeStart) and bar_index - activeStart > retestLookback

panelSide = newPlanSignal ? retestSide : planAlive ? activeSide : trendSide
panelScore = newPlanSignal ? reactionScore : planAlive ? nz(activeScore, trendContextScore) : trendContextScore
panelRoom = newPlanSignal ? roomRatio : planAlive ? activeRoomRatio : na

actionState = failSignalRaw ? "INVALIDATED" : followSignalRaw ? "FOLLOW-THROUGH" : readySignalRaw ? "READY" : watchSignalRaw ? "WATCH" : planAlive ? activePlanQuality : trendSide != 0 ? "WAIT RETEST" : "NO PLAN"
maRetestText = failSignalRaw ? "Failed retest" : followSignalRaw ? "Follow-through" : readySignalRaw ? "Clean hold" : watchSignalRaw ? "Watch zone" : planAlive ? activePlanQuality : bullNear ? "Bull watch" : bearNear ? "Bear watch" : "No active retest"
trendText = trendSide == 1 ? "Bullish MA slope" : trendSide == -1 ? "Bearish MA slope" : "Neutral / mixed"
riskText = not na(panelRoom) ? str.tostring(panelRoom, "#.0") + "R room" : "No active edge"
scoreText = str.tostring(panelScore, "#") + " / 100  " + f_tier(panelScore)

stateColor = actionState == "READY" or actionState == "FOLLOW-THROUGH" ? (panelSide == -1 ? bearColor : bullColor) : actionState == "WATCH" or actionState == "WAIT RETEST" ? neutralColor : actionState == "INVALIDATED" ? bearColor : accentColor

readySignal = readySignalRaw and barstate.isconfirmed
watchSignal = watchSignalRaw and barstate.isconfirmed
failSignal = failSignalRaw and barstate.isconfirmed
followSignal = followSignalRaw and barstate.isconfirmed
stateShiftSignal = bar_index > 0 and actionState != actionState[1] and barstate.isconfirmed

// -------------------------------------------------
// Hold Rate (stop-aware, confirmed-bar gated, resolve-then-open)
// Of past READY retests, how many reached the projected target before returning
// to the script's own invalidation. Levels frozen at the trigger bar. Times out
// uncounted if neither side is reached inside the window.
// -------------------------------------------------
var int holdWins = 0
var int holdTotal = 0
var bool holdPending = false
var int holdDir = 0
var float holdTarget = na
var float holdStop = na
var int holdStartBar = na

if barstate.isconfirmed
    if holdPending
        bool reachedTarget = holdDir == 1 ? high >= holdTarget : low <= holdTarget
        bool reachedStop = holdDir == 1 ? low <= holdStop : high >= holdStop
        if reachedTarget
            holdWins += 1
            holdTotal += 1
            holdPending := false
        else if reachedStop
            holdTotal += 1
            holdPending := false
        else if not na(holdStartBar) and bar_index - holdStartBar >= holdWindow
            holdPending := false
    if not holdPending and readySignalRaw and retestSide != 0 and not na(projectedTarget) and not na(invalidation)
        holdDir := retestSide
        holdTarget := projectedTarget
        holdStop := invalidation
        holdStartBar := bar_index
        holdPending := true

int holdPct = holdTotal > 0 ? int(math.round(holdWins / holdTotal * 100.0)) : na
bool holdBuilding = holdTotal < 6
string holdText = holdBuilding ? "Building (" + str.tostring(holdTotal) + ")" : str.tostring(holdPct) + "% (" + str.tostring(holdTotal) + ")"
color holdColor = holdBuilding ? neutralColor : holdPct >= 52 ? bullColor : holdPct >= 44 ? neutralColor : bearColor

// -------------------------------------------------
// Plots
// -------------------------------------------------
maPlotColor = trendSide == 1 ? bullColor : trendSide == -1 ? bearColor : accentColor
plot(showMA ? ma : na, "Active MA", color = maPlotColor, linewidth = 2)
pUpper = plot(showMA ? upperBand : na, "Retest Band Upper", color = color.new(maPlotColor, 82), linewidth = 1)
pLower = plot(showMA ? lowerBand : na, "Retest Band Lower", color = color.new(maPlotColor, 82), linewidth = 1)
fill(pUpper, pLower, color = showMA ? color.new(maPlotColor, 92) : na, title = "MA Retest Distance Band")

followBull = followSignal and activeSide == 1
followBear = followSignal and activeSide == -1
plotshape(showContinuationMarkers and followBull, title = "Bullish Follow-Through", style = shape.triangleup, location = location.belowbar, color = bullColor, size = size.tiny)
plotshape(showContinuationMarkers and followBear, title = "Bearish Follow-Through", style = shape.triangledown, location = location.abovebar, color = bearColor, size = size.tiny)

// -------------------------------------------------
// Objects
// -------------------------------------------------
var label[] eventLabels = array.new_label()
var int[] eventLabelBars = array.new_int()
var box[] retestBoxes = array.new_box()
var int[] retestBoxBars = array.new_int()
var label[] pocketBadges = array.new_label()
var int[] pocketBadgeBars = array.new_int()
var line[] riskLines = array.new_line()
var int[] riskLineBars = array.new_int()
var label[] railTags = array.new_label()
var int[] railTagBars = array.new_int()

eventSide = newPlanSignal ? retestSide : activeSide
eventColor = eventSide == 1 ? bullColor : eventSide == -1 ? bearColor : neutralColor
labelSize = f_size(labelFontSize)
memoryCutoffBar = bar_index - eventMemoryBars

while array.size(eventLabels) > 0 and array.get(eventLabelBars, 0) < memoryCutoffBar
    label.delete(array.shift(eventLabels))
    array.shift(eventLabelBars)

while array.size(retestBoxes) > 0 and array.get(retestBoxBars, 0) < memoryCutoffBar
    box.delete(array.shift(retestBoxes))
    array.shift(retestBoxBars)

while array.size(pocketBadges) > 0 and array.get(pocketBadgeBars, 0) < memoryCutoffBar
    label.delete(array.shift(pocketBadges))
    array.shift(pocketBadgeBars)

while array.size(riskLines) > 0 and array.get(riskLineBars, 0) < memoryCutoffBar
    line.delete(array.shift(riskLines))
    array.shift(riskLineBars)

while array.size(railTags) > 0 and array.get(railTagBars, 0) < memoryCutoffBar
    label.delete(array.shift(railTags))
    array.shift(railTagBars)

if showPocket and newPlanSignal and barstate.isconfirmed and (readySignalRaw or showWatchPockets)
    if array.size(retestBoxes) > 0
        box lastPocket = array.get(retestBoxes, array.size(retestBoxes) - 1)
        int lastPocketLeft = box.get_left(lastPocket)
        if not na(lastPocketLeft) and bar_index - lastPocketLeft <= clusterReplaceBars
            box.delete(array.pop(retestBoxes))
            array.pop(retestBoxBars)
            if array.size(pocketBadges) > 0
                label.delete(array.pop(pocketBadges))
                array.pop(pocketBadgeBars)
    box pocketBox = box.new(left = bar_index, top = upperBand, right = bar_index + pocketExtendBars, bottom = lowerBand, xloc = xloc.bar_index, bgcolor = color.new(eventColor, 89), border_color = color.new(eventColor, 28), border_width = 1)
    array.push(retestBoxes, pocketBox)
    array.push(retestBoxBars, bar_index)
    if showPocketBadges
        string pocketTitle = readySignalRaw ? (retestSide == 1 ? "BULL HOLD" : "BEAR HOLD") : (retestSide == 1 ? "BULL WATCH" : "BEAR WATCH")
        string pocketText = showPocketScore ? pocketTitle + "\nScore " + str.tostring(reactionScore, "#") : pocketTitle
        label pocketBadge = label.new(f_badge_x(bar_index, bar_index + pocketExtendBars), (upperBand + lowerBand) * 0.5, pocketText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(eventColor, 0), textcolor = f_text_on(eventColor), size = labelSize, textalign = text.align_center)
        array.push(pocketBadges, pocketBadge)
        array.push(pocketBadgeBars, bar_index)
    f_trim_box_pairs(retestBoxes, retestBoxBars, maxVisibleObjects)
    f_trim_label_pairs(pocketBadges, pocketBadgeBars, maxVisibleObjects)

if showRiskRails and readySignal and barstate.isconfirmed
    if array.size(riskLines) >= 2
        line lastRiskLine = array.get(riskLines, array.size(riskLines) - 1)
        int lastRiskBar = line.get_x1(lastRiskLine)
        if not na(lastRiskBar) and bar_index - lastRiskBar <= clusterReplaceBars
            line.delete(array.pop(riskLines))
            line.delete(array.pop(riskLines))
            array.pop(riskLineBars)
            array.pop(riskLineBars)
            if array.size(railTags) >= 2
                label.delete(array.pop(railTags))
                label.delete(array.pop(railTags))
                array.pop(railTagBars)
                array.pop(railTagBars)
    line invalidLine = line.new(x1 = bar_index, y1 = invalidation, x2 = bar_index + pocketExtendBars, y2 = invalidation, xloc = xloc.bar_index, color = color.new(bearColor, 0), style = line.style_dashed, width = 1)
    line targetLine = line.new(x1 = bar_index, y1 = projectedTarget, x2 = bar_index + pocketExtendBars, y2 = projectedTarget, xloc = xloc.bar_index, color = color.new(accentColor, 0), style = line.style_dotted, width = 1)
    array.push(riskLines, invalidLine)
    array.push(riskLines, targetLine)
    array.push(riskLineBars, bar_index)
    array.push(riskLineBars, bar_index)
    if showRailTags
        int tagX = bar_index + pocketExtendBars
        label targetTag = label.new(tagX, projectedTarget, "Target " + f_price(projectedTarget), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 0), textcolor = f_text_on(accentColor), size = labelSize)
        label invalidTag = label.new(tagX, invalidation, "Invalid " + f_price(invalidation), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bearColor, 0), textcolor = f_text_on(bearColor), size = labelSize)
        array.push(railTags, targetTag)
        array.push(railTags, invalidTag)
        array.push(railTagBars, bar_index)
        array.push(railTagBars, bar_index)
    f_trim_line_pairs(riskLines, riskLineBars, maxVisibleObjects * 2)
    f_trim_label_pairs(railTags, railTagBars, maxVisibleObjects * 2)

showPrimaryLabel = failSignal or (not showPocket and (readySignal or watchSignal))
showSecondaryLabel = showSecondaryEventLabels and (watchSignal or followSignal)

if showLabels and (showPrimaryLabel or showSecondaryLabel)
    if array.size(eventLabels) > 0
        label lastLabel = array.get(eventLabels, array.size(eventLabels) - 1)
        int lastLabelBar = label.get_x(lastLabel)
        if not na(lastLabelBar) and bar_index - lastLabelBar <= clusterReplaceBars
            label.delete(array.pop(eventLabels))
            array.pop(eventLabelBars)
    labelEventSide = readySignal or watchSignal ? retestSide : activeSide
    labelEventColor = failSignal ? bearColor : watchSignal ? neutralColor : labelEventSide == 1 ? bullColor : labelEventSide == -1 ? bearColor : neutralColor
    labelY = labelEventSide == 1 ? low - atr * labelOffsetATR : high + atr * labelOffsetATR
    labelStyle = labelEventSide == 1 ? label.style_label_up : label.style_label_down
    labelScore = readySignal or watchSignal ? reactionScore : nz(activeScore, panelScore)
    labelTitle = readySignal ? "HOLD" : watchSignal ? "WATCH" : failSignal ? "FAIL" : "FLOW"
    labelText = labelTitle + "\n" + str.tostring(labelScore, "#")
    color labelBg = color.new(labelEventColor, 4)
    label newLabel = label.new(x = bar_index, y = labelY, xloc = xloc.bar_index, text = labelText, style = labelStyle, color = labelBg, textcolor = f_text_on(labelBg), size = labelSize)
    array.push(eventLabels, newLabel)
    array.push(eventLabelBars, bar_index)
    f_trim_label_pairs(eventLabels, eventLabelBars, maxVisibleObjects)

// Rail-tag de-collision (last bar): separate Target/Invalid tags that crowd at the same x.
if barstate.islast and array.size(railTags) > 1
    int tn = array.size(railTags)
    array<label> tl = array.new_label()
    array<int> tx = array.new_int()
    array<float> ty = array.new_float()
    for ti = 0 to tn - 1
        label lb = array.get(railTags, ti)
        array.push(tl, lb)
        array.push(tx, label.get_x(lb))
        array.push(ty, label.get_y(lb))
    for a = 0 to tn - 2
        int mi = a
        for b = a + 1 to tn - 1
            if array.get(ty, b) < array.get(ty, mi)
                mi := b
        if mi != a
            float tyy = array.get(ty, a)
            array.set(ty, a, array.get(ty, mi))
            array.set(ty, mi, tyy)
            int txx = array.get(tx, a)
            array.set(tx, a, array.get(tx, mi))
            array.set(tx, mi, txx)
            label tll = array.get(tl, a)
            array.set(tl, a, array.get(tl, mi))
            array.set(tl, mi, tll)
    float tGap = math.max(atr * 0.55, syminfo.mintick * 20.0)
    for a = 1 to tn - 1
        float py = array.get(ty, a - 1)
        float cy = array.get(ty, a)
        int px = array.get(tx, a - 1)
        int cx = array.get(tx, a)
        if math.abs(cx - px) <= 3 and cy - py < tGap
            float ny = py + tGap
            array.set(ty, a, ny)
            label.set_y(array.get(tl, a), ny)

if failSignalRaw or followSignalRaw or expiredPlan
    activeSide := 0
    activeStart := na
    activeInvalidation := na
    activeTarget := na
    activeTrigger := na
    activeScore := na
    activeRoomRatio := na
    activePlanQuality := "None"

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table plannerPanel = table.new(f_panel_position(panelLocation), 2, 7, bgcolor = f_panel_bg(), frame_color = f_panel_border(), frame_width = 1, border_color = f_panel_border(), border_width = 1)

if barstate.islast
    table.set_position(plannerPanel, f_panel_position(panelLocation))
    table.clear(plannerPanel, 0, 0, 1, 6)
    if showPanel
        table.merge_cells(plannerPanel, 0, 0, 1, 0)
        f_panel_cell(plannerPanel, 0, 0, "AG Pro Moving Average Retest Planner", headerText, headerBg, "center")
        f_panel_cell(plannerPanel, 0, 1, "MA Retest", f_panel_label(), f_row_bg(1), "left")
        f_panel_cell(plannerPanel, 1, 1, maRetestText, stateColor, f_row_bg(1), "right")
        f_panel_cell(plannerPanel, 0, 2, "Trend Side", f_panel_label(), f_row_bg(2), "left")
        f_panel_cell(plannerPanel, 1, 2, trendText, f_panel_value(), f_row_bg(2), "right")
        f_panel_cell(plannerPanel, 0, 3, "Reaction Score", f_panel_label(), f_row_bg(3), "left")
        f_panel_cell(plannerPanel, 1, 3, scoreText, stateColor, f_row_bg(3), "right")
        f_panel_cell(plannerPanel, 0, 4, "Risk Edge", f_panel_label(), f_row_bg(4), "left")
        f_panel_cell(plannerPanel, 1, 4, riskText, f_panel_value(), f_row_bg(4), "right")
        f_panel_cell(plannerPanel, 0, 5, "Hold Rate", f_panel_label(), f_row_bg(5), "left")
        f_panel_cell(plannerPanel, 1, 5, holdText, holdColor, f_row_bg(5), "right")
        f_panel_cell(plannerPanel, 0, 6, "Action", f_panel_label(), f_row_bg(6), "left")
        f_panel_cell(plannerPanel, 1, 6, actionState, stateColor, f_row_bg(6), "right")

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(readySignal, title = "MA Retest READY", message = "Moving Average Retest Planner: READY retest context detected. Review the score, risk edge, and invalidation.")
alertcondition(failSignal, title = "MA Retest Invalidated", message = "Moving Average Retest Planner: active retest invalidation was crossed. This is an attention marker, not a trade instruction.")
alertcondition(followSignal, title = "MA Retest Follow-Through", message = "Moving Average Retest Planner: follow-through after an active retest was detected. This is an attention marker, not a trade instruction.")
alertcondition(stateShiftSignal, title = "MA Retest State Shift", message = "Moving Average Retest Planner: planner state changed. Review chart context before making any decision.")
````
