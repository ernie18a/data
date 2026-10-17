# Entry Execution Readiness [AGPro Series]

- url: https://www.tradingview.com/script/iLB4ddiA-Entry-Execution-Readiness-AGPro-Series/
- type: indicator
- pine_id: PUB;54ba89b8a5924075a25ae655e5d61ef0
- version: 4.0

## Description

Entry Execution Readiness [AGPro Series]

🧠 Core Idea

Is this setup ready for execution attention now, or should it remain on watch?


📌 Overview / What it does

Entry Execution Readiness [AGPro Series] is a chart-first decision engine built to evaluate whether an active setup has enough structure, risk quality, and target room to deserve execution attention.

The script produces a 0-100 Readiness Score, a clear entry state, an entry pocket, an invalidation rail, a target-room band, premium state labels, and a compact AGPro panel. It is designed to organize setup quality, not to predict price or automate execution.

It does not publish buy or sell commands. It does not replace a trader's own execution model. Its purpose is to turn observable setup conditions into a cleaner readiness map.


🎯 Purpose & Design Philosophy

This script was built for traders who already see a potential setup but need a disciplined way to decide whether the setup is clean enough to keep under execution review.

The gap it fills is practical: many tools identify signals, levels, or zones, but they do not answer whether the setup has acceptable risk distance, enough target room, suitable volatility, and directional confirmation at the same time.

The design philosophy is simple: execution should be reviewed through readiness, not excitement.


⚡ Why This Script Is Different

Most tools focus on printing a signal or highlighting a level.

This script does NOT act as a full Position Planner, position sizing model, signal service, or trade automation system.

Instead, it evaluates execution readiness through a compact decision layer: trend alignment, candle efficiency, distance to invalidation, target-room quality, and volatility fit are compressed into one transparent score and one clear next-action state.


⚙️ Methodology

1. Context Detection
The script detects the active setup side automatically, or lets the user force a long-bias or short-bias readiness view.

2. Reference Mapping
It maps an entry pocket around the active trend reference, builds an invalidation rail from recent structure, and projects target room from nearby structure or ATR-adjusted continuation space.

3. Reaction Evaluation
It scores trend alignment, candle efficiency, risk distance, reward room, and volatility fit from 0 to 100.

4. Visual Output
The chart displays the readiness state through zones, labels, alerts, and a premium AGPro panel with the key decision fields.


🗺️ How to Read the Chart

Zones = the active entry pocket and target-room band.

Invalidation rail = the structural level that would weaken or reset the current setup context.

Labels = the current readiness state, score tier, and risk context.

Colors = teal for stronger long-readiness contexts, pink for bearish or invalidation contexts, amber for waiting states, and indigo for monitoring/transition states.

Panel = the fastest summary of score, state, risk distance, target room, and next action.


🚦 Signals & States

• READY → the setup meets the score threshold and confirmation filter.

• MONITOR → the setup is improving but still needs cleaner confirmation or score strength.

• WAIT → the setup exists, but risk, target room, or confirmation is not yet strong enough.

• BLOCKED → the current context does not offer a clean execution-readiness profile.

• INVALIDATED → price closed beyond the active invalidation rail.


🔔 Alerts Logic

READY alerts trigger when the state upgrades into READY.

Downgrade alerts trigger when the active setup weakens from a stronger state.

Invalidation alerts trigger when price closes beyond the current invalidation rail.

Confirmation alerts trigger when score and confirmation improve together near the READY threshold.

Alerts are attention markers. They are not trade instructions.


🧩 Confluence Logic

The setup becomes stronger when directional trend alignment, candle quality, controlled invalidation distance, acceptable volatility, and clean target room improve at the same time.

The score is intentionally multi-factor so a single strong candle or a single clean level cannot dominate the full readiness view.


📊 When to Use

• Trend continuation setups

• Pullback-to-reference execution reviews

• Breakout continuation contexts with enough target room

• Active trade-planning workflows where the trader already has a directional thesis

• Intraday or swing charts where risk and target room need to be evaluated quickly

• 4-hour swing/execution review charts where the active pocket, invalidation rail, and target room can be read without excessive label compression


⚠️ When NOT to Use

• Very low liquidity markets

• Extremely noisy sideways conditions

• News-driven volatility spikes

• Charts where the user has no independent setup thesis

• Markets with poor execution conditions, wide spreads, or unreliable fills


🎛️ Key Inputs

• Setup Direction → Auto, Long Bias, or Short Bias readiness mode.

• Sensitivity → controls how selective the model is.

• Structure Lookback → affects structure, risk rail, target room, and volatility context.

• Minimum READY Score → defines the threshold required for READY state.

• Confirmation Mode → controls how much candle and trend confirmation is required.

• Label Cooldown / Max Visible Labels → controls label density.

• Panel Location / Panel Theme / Font Sizes → controls visual presentation.


🖥️ Interface & Visual Design

The interface is built around a clean premium overlay.

The panel uses the AGPro standard single merged blue header row and summarizes only the most decision-relevant fields.

The chart visuals are deliberately limited to the current entry pocket, invalidation rail, target room, and moderate state labels so the script remains readable in publication screenshots.


🧪 Practical Usage Workflow

1. Read the panel state and Readiness Score.

2. Check whether price is interacting cleanly with the entry pocket.

3. Review the invalidation rail and risk distance.

4. Compare the target-room band against the current risk.

5. Treat READY as a review state, not as an automatic execution command.


🔍 Interpretation Guidelines

Think of the output as a readiness filter.

A high score means the modeled conditions are aligned more cleanly than usual. It does not mean the setup will work.

A WAIT or MONITOR state can still be useful because it shows what part of the setup is not yet ready.

An INVALIDATED state means the current setup context should be reset or reviewed again from a fresh structure.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not auto trading

• Not guaranteed signals

• Not a full position-sizing planner

• Not a buy/sell command system


⚠️ Limitations & Transparency

Timeframe differences can change how structure, volatility, and target room appear.

Volatility expansion or contraction can make the readiness state change quickly.

Market conditions can shift faster than any rule-based chart tool can summarize.

The model is transparent and deterministic, but it cannot know future price behavior.


🧠 Market Context Notes

Entry readiness is most useful when it is read together with liquidity, structure, session context, and broader volatility conditions.

The script is strongest when the trader already has a setup thesis and needs a cleaner way to review whether execution conditions are improving or weakening.


🧾 Use Case Examples

When price pulls back toward the entry pocket, trend alignment remains intact, risk distance stays controlled, and target room remains clean, the setup may upgrade into MONITOR or READY.

When price stretches too far from the pocket or target room becomes too thin relative to invalidation distance, the score can weaken even if direction still looks attractive.

When price closes beyond the invalidation rail, the active setup context is marked as INVALIDATED.


🧱 System Philosophy

AGPro tools are designed to support structured chart reading, decision clarity, and rule-based interpretation.

This script follows that philosophy by focusing on execution readiness instead of generic signals.


🔐 Non-Promise Statement

No script can provide certainty.

No score can guarantee a future outcome.

This tool organizes visible chart conditions so the user can make a more structured review.


📉 Risk Disclosure

Trading involves risk. Market movement can be unpredictable, and any setup can fail.

Users are responsible for their own analysis, execution, risk management, and decisions.

This script does not provide financial advice, investment advice, or guaranteed trading outcomes.


📚 Educational Note

Use the script as a structured decision-support layer. The strongest benefit comes from reviewing why the state is READY, WAIT, MONITOR, BLOCKED, or INVALIDATED rather than treating any single label as a standalone answer.

## Source Code

````pine
// -------------------------------------------------
// Entry Execution Readiness [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Entry Execution Readiness is a trade decision engine for evaluating whether
// an active setup has enough trend alignment, candle efficiency, controlled
// invalidation distance, target room, and volatility fit to deserve execution
// attention. It draws an entry pocket, invalidation rail, and target-room band,
// tracks confirmed readiness events with a stop-aware proof pass, and keeps
// the output neutral, rule-based, and publication-ready.
// -------------------------------------------------

//@version=6
indicator("Entry Execution Readiness [AGPro Series]",
     shorttitle = "AG Pro EER",
     overlay = true,
     max_labels_count = 200,
     max_lines_count = 50,
     max_boxes_count = 50)

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
targetBlue    = color.rgb(59, 130, 246)
darkText      = color.rgb(17, 24, 39)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupCore   = "Core Readiness Engine"
groupVisual = "Visual Design"
groupPanel  = "AGPro Panel"
groupAlerts = "Alerts"

setupDirection = input.string("Auto", "Setup Direction", options = ["Auto", "Long Bias", "Short Bias"], group = groupCore, tooltip = "Select Auto to infer the active setup side from trend and price location, or force a long/short readiness view for your own directional thesis.")
sensitivity = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Aggressive"], group = groupCore, tooltip = "Controls how selective the readiness model is. Conservative requires cleaner structure; Aggressive reacts earlier with wider tolerance.")
lookback = input.int(55, "Structure Lookback", minval = 20, maxval = 200, group = groupCore, tooltip = "Bars used to evaluate recent structure, target room, volatility context, and invalidation distance.")
minimumScore = input.int(72, "Minimum READY Score", minval = 50, maxval = 95, group = groupCore, tooltip = "Minimum 0-100 readiness score required before the state can become READY.")
confirmationMode = input.string("Balanced", "Confirmation Mode", options = ["Early", "Balanced", "Strict"], group = groupCore, tooltip = "Defines how much candle and trend confirmation must align before the model can classify a setup as READY.")
cooldownBars = input.int(20, "Label Cooldown Bars", minval = 1, maxval = 80, group = groupCore, tooltip = "Minimum spacing between repeated state labels. Lower values create a denser chart; higher values keep labels more selective.")
maxVisibleObjects = input.int(5, "Max Visible Labels", minval = 3, maxval = 30, group = groupCore, tooltip = "Maximum number of historical state labels kept on the chart.")
proofWindowBars = input.int(10, "Readiness Proof Window", minval = 2, maxval = 60, group = groupCore, tooltip = "After a READY upgrade, the engine waits this many bars (or until the invalidation rail is touched) and checks whether price moved in the setup direction. Feeds the Readiness Hit Rate as a directional follow-through measure, consistent with the attention-marker design.")
proofMoveAtr = input.float(0.35, "Minimum Proof Move (ATR)", minval = 0.05, maxval = 2.00, step = 0.05, group = groupCore, tooltip = "Minimum favorable excursion required during the proof window for a READY event to count as directional follow-through. The threshold is frozen from the READY close.")

showZones = input.bool(true, "Show Entry / Risk / Target Zones", group = groupVisual, tooltip = "Displays the current entry pocket, invalidation rail, and target-room band.")
showZoneBadges = input.bool(true, "Show Centered Zone Badges", group = groupVisual, tooltip = "Shows separate centered badges for the entry pocket and target room instead of embedding text inside zones.")
showLabels = input.bool(true, "Show State Labels", group = groupVisual, tooltip = "Displays controlled on-chart readiness labels with score, risk, and room context.")
showQualityTag = input.bool(false, "Show Right-Side Quality Tag", group = groupVisual, tooltip = "Shows an optional right-side score tag near the entry pocket. Disabled by default because the score is already visible in the panel and labels.")
projectionBars = input.int(20, "Zone Projection Bars", minval = 10, maxval = 80, group = groupVisual, tooltip = "How far the active readiness zones project to the right side of the chart.")
adaptiveProjection = input.bool(true, "Adaptive HTF Projection", group = groupVisual, tooltip = "Automatically widens the visual projection on higher timeframes so zones remain readable on weekly and monthly charts.")
labelOffsetAtr = input.float(1.05, "Label Offset (ATR)", minval = 0.2, maxval = 3.0, step = 0.05, group = groupVisual, tooltip = "Distance used to place labels above or below candles so they remain readable.")
labelLaneSpreadAtr = input.float(0.85, "Label Lane Spread (ATR)", minval = 0.20, maxval = 2.50, step = 0.05, group = groupVisual, tooltip = "Adds vertical spacing between nearby state-label lanes without reducing the number of visible labels.")
labelDetail = input.string("Balanced", "Label Detail", options = ["Balanced", "Full"], group = groupVisual, tooltip = "Controls how much information each state label shows. Balanced keeps labels compact with risk and room context; Full shows directional readiness context as well.")
labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisual, tooltip = "Controls all on-chart labels, zone badges, rails, and right-side tags.")

showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = "Shows or hides the AG Pro decision panel. The panel is enabled by default for publication-ready chart presentation.")
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = "Selects the on-chart position of the AG Pro readiness panel.")
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = groupPanel, tooltip = "Controls the panel color theme while keeping the standard AG Pro blue header row.")
panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel, tooltip = "Controls panel text size. Normal is the default publication setting.")

enableReadyAlert = input.bool(true, "Enable READY Alert", group = groupAlerts, tooltip = "Allows alert conditions when the script upgrades into READY state. Alerts are attention markers, not trade instructions.")
enableDowngradeAlert = input.bool(true, "Enable Downgrade Alert", group = groupAlerts, tooltip = "Allows alert conditions when the active setup state weakens from a stronger state.")
enableInvalidAlert = input.bool(true, "Enable Invalidation Alert", group = groupAlerts, tooltip = "Allows alert conditions when price closes beyond the current invalidation rail.")
enableConfirmAlert = input.bool(true, "Enable Confirmation Alert", group = groupAlerts, tooltip = "Allows alert conditions when score and confirmation improve together in the active setup direction.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_text_on(color bgColor) =>
    float bright = (color.r(bgColor) * 299.0 + color.g(bgColor) * 587.0 + color.b(bgColor) * 114.0) / 1000.0
    bright >= 145.0 ? darkText : headerText

f_size(string value) =>
    switch value
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_panel_pos(string value) =>
    switch value
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_panel_bg() =>
    panelTheme == "Clean Light" ? color.rgb(245, 247, 250) : panelTheme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_alt_bg() =>
    panelTheme == "Clean Light" ? color.rgb(226, 232, 240) : panelTheme == "Slate" ? color.rgb(37, 49, 70) : color.rgb(20, 31, 52)

f_panel_border() =>
    panelTheme == "Clean Light" ? color.rgb(148, 163, 184) : panelTheme == "Slate" ? color.rgb(71, 85, 105) : panelBorder

f_panel_label() =>
    panelTheme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value() =>
    panelTheme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_state_rank(string stateValue) =>
    switch stateValue
        "READY" => 4
        "MONITOR" => 3
        "WAIT" => 2
        "BLOCKED" => 1
        "INVALIDATED" => 0
        => 1

f_price(float value) =>
    str.tostring(value, format.mintick)

f_score_text(float value) =>
    str.tostring(math.round(value), "#")

f_panel_cell(table panelRef, int col, int row, string textValue, color textColor, color bgColor, string sizeInput, string alignInput) =>
    table.cell(panelRef, col, row, textValue, text_color = textColor, bgcolor = bgColor, text_size = f_size(sizeInput), text_halign = alignInput == "left" ? text.align_left : alignInput == "right" ? text.align_right : text.align_center)

// -------------------------------------------------
// Core Engine
// -------------------------------------------------
fastLen = sensitivity == "Conservative" ? 34 : sensitivity == "Aggressive" ? 13 : 21
slowLen = sensitivity == "Conservative" ? 89 : sensitivity == "Aggressive" ? 34 : 55
pocketAtr = sensitivity == "Conservative" ? 0.48 : sensitivity == "Aggressive" ? 0.86 : 0.64
riskBufferAtr = sensitivity == "Conservative" ? 0.22 : sensitivity == "Aggressive" ? 0.10 : 0.16
targetAtrFallback = sensitivity == "Conservative" ? 2.35 : sensitivity == "Aggressive" ? 1.55 : 1.95

atrRaw = ta.atr(14)
safeAtrBase = nz(atrRaw, ta.tr(true))
safeAtr = math.max(safeAtrBase, syminfo.mintick)
atrAverage = ta.sma(atrRaw, lookback)
atrRatio = safeAtr / math.max(nz(atrAverage, safeAtr), syminfo.mintick)

emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
emaSlope = emaFast - nz(emaFast[5], emaFast)

autoBiasRaw = close >= emaFast and emaFast >= emaSlow ? 1 : close <= emaFast and emaFast <= emaSlow ? -1 : 0
var int heldAutoBias = 0
heldAutoBias := autoBiasRaw != 0 ? autoBiasRaw : nz(heldAutoBias[1], close >= emaSlow ? 1 : -1)
setupBias = setupDirection == "Long Bias" ? 1 : setupDirection == "Short Bias" ? -1 : heldAutoBias
isLongSetup = setupBias == 1

riskLookback = math.max(8, int(math.round(lookback * 0.55)))
recentLow = nz(ta.lowest(low[1], riskLookback), low)
recentHigh = nz(ta.highest(high[1], riskLookback), high)
obstacleHigh = nz(ta.highest(high[1], lookback), high)
obstacleLow = nz(ta.lowest(low[1], lookback), low)
labelClearTopSeries = ta.highest(high, 5)
labelClearBottomSeries = ta.lowest(low, 5)

invalidation = isLongSetup ? recentLow - safeAtr * riskBufferAtr : recentHigh + safeAtr * riskBufferAtr
targetCandidate = isLongSetup ? obstacleHigh : obstacleLow
targetFallback = isLongSetup ? close + safeAtr * targetAtrFallback : close - safeAtr * targetAtrFallback
targetPrice = isLongSetup ? math.max(targetCandidate, targetFallback) : math.min(targetCandidate, targetFallback)

riskDistance = math.max(math.abs(close - invalidation), syminfo.mintick)
targetRoom = math.max(math.abs(targetPrice - close), syminfo.mintick)
riskAtr = riskDistance / safeAtr
rewardR = targetRoom / riskDistance

barRange = math.max(high - low, syminfo.mintick)
bodySize = math.abs(close - open)
bodyEfficiency = f_clamp(bodySize / barRange, 0.0, 1.0)
closeLocation = f_clamp((close - low) / barRange, 0.0, 1.0)
directionalClose = isLongSetup ? closeLocation : 1.0 - closeLocation
candleAgrees = isLongSetup ? close >= open : close <= open

trendAligned = isLongSetup ? emaFast > emaSlow and close > emaSlow : emaFast < emaSlow and close < emaSlow
trendPartial = isLongSetup ? close > emaFast or emaFast > emaSlow : close < emaFast or emaFast < emaSlow
trendSlopeAligned = isLongSetup ? emaSlope > 0 : emaSlope < 0

idealRiskAtr = sensitivity == "Conservative" ? 1.15 : sensitivity == "Aggressive" ? 1.75 : 1.40
trendScore = (trendAligned ? 18.0 : trendPartial ? 8.0 : 0.0) + (trendSlopeAligned ? 7.0 : 0.0)
candleScore = bodyEfficiency * 10.0 + directionalClose * 7.0 + (candleAgrees ? 3.0 : 0.0)
riskScore = f_clamp(20.0 - math.abs(riskAtr - idealRiskAtr) * 7.0, 0.0, 20.0)
rewardScore = f_clamp((rewardR - 0.55) / 1.75 * 20.0, 0.0, 20.0)
volScore = f_clamp(15.0 - math.abs(atrRatio - 1.0) * 18.0, 0.0, 15.0)

readinessRaw = trendScore + candleScore + riskScore + rewardScore + volScore
readinessScore = f_clamp(readinessRaw, 0.0, 100.0)

strictConfirm = trendAligned and trendSlopeAligned and candleAgrees and directionalClose >= 0.62 and rewardR >= 1.20
balancedConfirm = trendAligned and directionalClose >= 0.55 and rewardR >= 1.00
earlyConfirm = (trendAligned or trendSlopeAligned) and directionalClose >= 0.48 and rewardR >= 0.85
isConfirmed = confirmationMode == "Strict" ? strictConfirm : confirmationMode == "Early" ? earlyConfirm : balancedConfirm

isInvalidated = isLongSetup ? close < invalidation : close > invalidation
entryState = isInvalidated ? "INVALIDATED" : readinessScore >= minimumScore and isConfirmed ? "READY" : readinessScore >= minimumScore - 8 ? "MONITOR" : readinessScore >= minimumScore - 22 ? "WAIT" : "BLOCKED"
nextAction = entryState == "READY" ? "Review checklist" : entryState == "MONITOR" ? "Monitor confirmation" : entryState == "WAIT" ? "Wait for cleaner risk" : entryState == "INVALIDATED" ? "Reset setup" : "No clean context"

stateColor = entryState == "READY" ? (isLongSetup ? bullColor : bearColor) : entryState == "MONITOR" ? accentColor : entryState == "WAIT" ? neutralColor : entryState == "INVALIDATED" ? bearColor : panelLabelCol
setupText = isLongSetup ? "Long Readiness" : "Short Readiness"
riskText = str.tostring(riskAtr, "#.##") + " ATR"
riskShortText = str.tostring(riskAtr, "#.##") + "A"
targetText = str.tostring(rewardR, "#.##") + "R"

pocketTop = emaFast + safeAtr * pocketAtr
pocketBottom = emaFast - safeAtr * pocketAtr

// -------------------------------------------------
// Alerts
// -------------------------------------------------
var string previousState = "WAIT"
var bool previousConfirmationQualified = false
readyStateEvent = barstate.isconfirmed and entryState == "READY" and previousState != "READY"
downgradeStateEvent = barstate.isconfirmed and f_state_rank(entryState) < f_state_rank(previousState)
invalidStateEvent = barstate.isconfirmed and entryState == "INVALIDATED" and previousState != "INVALIDATED"
confirmationQualified = entryState != "INVALIDATED" and isConfirmed and readinessScore >= minimumScore - 4 and readinessScore > nz(readinessScore[1], readinessScore)
readyEvent = enableReadyAlert and readyStateEvent
downgradeEvent = enableDowngradeAlert and downgradeStateEvent
invalidEvent = enableInvalidAlert and invalidStateEvent
confirmationEvent = enableConfirmAlert and barstate.isconfirmed and confirmationQualified and not previousConfirmationQualified

alertcondition(readyEvent, "Entry Execution Readiness READY", "Entry Execution Readiness: setup state upgraded to READY. This is an attention marker, not a trade instruction.")
alertcondition(downgradeEvent, "Entry Execution Readiness Downgrade", "Entry Execution Readiness: setup state weakened from the previous bar.")
alertcondition(invalidEvent, "Entry Execution Readiness Invalidated", "Entry Execution Readiness: price closed beyond the current invalidation rail.")
alertcondition(confirmationEvent, "Entry Execution Readiness Confirmation", "Entry Execution Readiness: score and confirmation improved in the active setup direction.")

// -------------------------------------------------
// Readiness Hit Rate (Proof Pass)
// -------------------------------------------------
// On each READY upgrade, capture the entry, direction, and invalidation rail.
// The setup resolves as a miss if the invalidation rail is touched first;
// otherwise, after the proof window, it is a hit when favorable excursion has
// reached the user-defined ATR threshold. This measures directional
// follow-through (stop-aware),
// consistent with the script's attention-marker design rather than a full
// trade-outcome backtest.
var int rdyProofHits = 0
var int rdyProofTotal = 0
var bool rdyProofPending = false
var int rdyProofStart = na
var int rdyProofDir = 0
var float rdyProofEntry = na
var float rdyProofInval = na
var float rdyProofAtr = na
var float rdyProofBestMove = 0.0

if barstate.isconfirmed
    if readyStateEvent and not rdyProofPending
        rdyProofPending := true
        rdyProofStart := bar_index
        rdyProofDir := isLongSetup ? 1 : -1
        rdyProofEntry := close
        rdyProofInval := invalidation
        rdyProofAtr := safeAtr
        rdyProofBestMove := 0.0
    if rdyProofPending and not na(rdyProofStart) and bar_index > rdyProofStart
        bool stopHit = rdyProofDir > 0 ? low <= rdyProofInval : high >= rdyProofInval
        float favorableMove = rdyProofDir > 0 ? high - rdyProofEntry : rdyProofEntry - low
        rdyProofBestMove := math.max(rdyProofBestMove, favorableMove)
        if stopHit
            rdyProofTotal += 1
            rdyProofPending := false
        else if bar_index - rdyProofStart >= proofWindowBars
            bool favorable = rdyProofBestMove >= rdyProofAtr * proofMoveAtr
            rdyProofTotal += 1
            if favorable
                rdyProofHits += 1
            rdyProofPending := false

float rdyProofRate = rdyProofTotal > 0 ? rdyProofHits / rdyProofTotal * 100.0 : na
string rdyRateText = rdyProofTotal > 0 ? str.tostring(int(math.round(rdyProofRate))) + "% (" + str.tostring(rdyProofHits) + "/" + str.tostring(rdyProofTotal) + ")" : "Building"
color rdyRateColor = rdyProofTotal == 0 ? neutralColor : rdyProofRate >= 60.0 ? bullColor : rdyProofRate >= 45.0 ? neutralColor : bearColor

// -------------------------------------------------
// Active Zones
// -------------------------------------------------
var box entryPocketBox = na
var box targetRoomBox = na
var line invalidationRail = na
var label invalidationTag = na
var label qualityTag = na
var label entryBadge = na
var label targetBadge = na

if barstate.islast
    projectionBoost = adaptiveProjection ? timeframe.isweekly ? 3 : timeframe.ismonthly ? 4 : timeframe.isdaily ? 2 : 1 : 1
    zoneLeft = math.max(bar_index - 3, 0)
    zoneRight = bar_index + projectionBars * projectionBoost
    zoneMidX = bar_index + int(math.round(projectionBars * projectionBoost * 0.50))
    entryBadgeX = bar_index + int(math.round(projectionBars * projectionBoost * 0.34))
    targetBadgeX = bar_index + int(math.round(projectionBars * projectionBoost * 0.60))
    pocketMid = (pocketTop + pocketBottom) * 0.5
    targetNearEdge = isLongSetup ? math.max(close, pocketTop) : math.min(close, pocketBottom)
    displayTargetTop = math.max(targetNearEdge, targetPrice)
    displayTargetBottom = math.min(targetNearEdge, targetPrice)
    targetMid = (displayTargetTop + displayTargetBottom) * 0.5
    entryBadgeY = pocketMid
    targetBadgeY = targetMid
    railText = "INVALIDATION"
    activeStateText = entryState == "INVALIDATED" ? "INV" : entryState == "MONITOR" ? "MON" : entryState == "BLOCKED" ? "BLK" : entryState == "READY" ? "RDY" : "WAIT"
    qualityText = activeStateText + " " + f_score_text(readinessScore)
    if showZones
        if na(entryPocketBox)
            entryPocketBox := box.new(left = zoneLeft, top = pocketTop, right = zoneRight, bottom = pocketBottom, xloc = xloc.bar_index, border_color = color.new(accentColor, 20), bgcolor = color.new(accentColor, 88))
        else
            box.set_left(entryPocketBox, zoneLeft)
            box.set_right(entryPocketBox, zoneRight)
            box.set_top(entryPocketBox, pocketTop)
            box.set_bottom(entryPocketBox, pocketBottom)
            box.set_bgcolor(entryPocketBox, color.new(accentColor, 88))
            box.set_border_color(entryPocketBox, color.new(accentColor, 20))

        if na(targetRoomBox)
            targetRoomBox := box.new(left = zoneLeft, top = displayTargetTop, right = zoneRight, bottom = displayTargetBottom, xloc = xloc.bar_index, border_color = color.new(targetBlue, 18), bgcolor = color.new(stateColor, 92))
        else
            box.set_left(targetRoomBox, zoneLeft)
            box.set_right(targetRoomBox, zoneRight)
            box.set_top(targetRoomBox, displayTargetTop)
            box.set_bottom(targetRoomBox, displayTargetBottom)
            box.set_bgcolor(targetRoomBox, color.new(stateColor, 92))
            box.set_border_color(targetRoomBox, color.new(targetBlue, 18))

        if showZoneBadges
            if na(entryBadge)
                entryBadge := label.new(entryBadgeX, entryBadgeY, "ENTRY POCKET\n" + activeStateText + " " + f_score_text(readinessScore), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(accentColor, 6), textcolor = f_text_on(accentColor), size = f_size(labelFontSize), textalign = text.align_center)
            else
                label.set_xy(entryBadge, entryBadgeX, entryBadgeY)
                label.set_text(entryBadge, "ENTRY POCKET\n" + activeStateText + " " + f_score_text(readinessScore))
                label.set_color(entryBadge, color.new(accentColor, 6))
                label.set_textcolor(entryBadge, f_text_on(accentColor))
                label.set_size(entryBadge, f_size(labelFontSize))
                label.set_style(entryBadge, label.style_label_center)
            if na(targetBadge)
                targetBadge := label.new(targetBadgeX, targetBadgeY, "TARGET ROOM\n" + targetText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(targetBlue, 2), textcolor = f_text_on(targetBlue), size = f_size(labelFontSize), textalign = text.align_center)
            else
                label.set_xy(targetBadge, targetBadgeX, targetBadgeY)
                label.set_text(targetBadge, "TARGET ROOM\n" + targetText)
                label.set_color(targetBadge, color.new(targetBlue, 2))
                label.set_textcolor(targetBadge, f_text_on(targetBlue))
                label.set_size(targetBadge, f_size(labelFontSize))
                label.set_style(targetBadge, label.style_label_center)
        else
            if not na(entryBadge)
                label.delete(entryBadge)
                entryBadge := na
            if not na(targetBadge)
                label.delete(targetBadge)
                targetBadge := na

        if na(invalidationRail)
            invalidationRail := line.new(x1 = zoneLeft, y1 = invalidation, x2 = zoneRight, y2 = invalidation, xloc = xloc.bar_index, extend = extend.none, color = color.new(bearColor, 0), style = line.style_dashed, width = 2)
        else
            line.set_xy1(invalidationRail, zoneLeft, invalidation)
            line.set_xy2(invalidationRail, zoneRight, invalidation)
            line.set_color(invalidationRail, color.new(bearColor, 0))
            line.set_width(invalidationRail, 2)

        if na(invalidationTag)
            invalidationTag := label.new(zoneRight + 1, invalidation, railText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bearColor, 8), textcolor = f_text_on(bearColor), size = f_size(labelFontSize))
        else
            label.set_xy(invalidationTag, zoneRight + 1, invalidation)
            label.set_text(invalidationTag, railText)
            label.set_color(invalidationTag, color.new(bearColor, 8))
            label.set_textcolor(invalidationTag, f_text_on(bearColor))
            label.set_size(invalidationTag, f_size(labelFontSize))

        if showQualityTag
            qualityX = zoneRight + 2
            qualityY = isLongSetup ? pocketTop + safeAtr * 0.38 : pocketBottom - safeAtr * 0.38
            if na(qualityTag)
                qualityTag := label.new(qualityX, qualityY, qualityText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(stateColor, 8), textcolor = f_text_on(stateColor), size = f_size(labelFontSize))
            else
                label.set_xy(qualityTag, qualityX, qualityY)
                label.set_text(qualityTag, qualityText)
                label.set_color(qualityTag, color.new(stateColor, 8))
                label.set_textcolor(qualityTag, f_text_on(stateColor))
                label.set_size(qualityTag, f_size(labelFontSize))
        else
            if not na(qualityTag)
                label.delete(qualityTag)
                qualityTag := na
    else
        if not na(entryPocketBox)
            box.delete(entryPocketBox)
            entryPocketBox := na
        if not na(targetRoomBox)
            box.delete(targetRoomBox)
            targetRoomBox := na
        if not na(invalidationRail)
            line.delete(invalidationRail)
            invalidationRail := na
        if not na(invalidationTag)
            label.delete(invalidationTag)
            invalidationTag := na
        if not na(qualityTag)
            label.delete(qualityTag)
            qualityTag := na
        if not na(entryBadge)
            label.delete(entryBadge)
            entryBadge := na
        if not na(targetBadge)
            label.delete(targetBadge)
            targetBadge := na

// -------------------------------------------------
// State Labels
// -------------------------------------------------
var array<label> stateLabels = array.new<label>()
var int lastLabelBar = na
var int labelSlotCounter = 0
var string lastVisualState = ""
var float lastVisualScore = na
var int lastVisualBias = 0
var bool lastLabelWasMajor = false

majorStateEvent = readyStateEvent or invalidStateEvent
regularLabelDue = entryState != "BLOCKED" and (na(lastLabelBar) or bar_index - lastLabelBar >= cooldownBars)
sameVisualContext = entryState == lastVisualState and setupBias == lastVisualBias
scoreMovedEnough = na(lastVisualScore) or math.abs(readinessScore - lastVisualScore) >= 10.0
sameStateSpacedEnough = na(lastLabelBar) or bar_index - lastLabelBar >= cooldownBars * 3
smartLabelAllowed = not sameVisualContext or scoreMovedEnough or sameStateSpacedEnough

if showLabels and barstate.isconfirmed and (majorStateEvent or regularLabelDue) and (majorStateEvent or smartLabelAllowed)
    nearbyLabel = not na(lastLabelBar) and bar_index - lastLabelBar <= int(math.round(cooldownBars * 1.35))
    if nearbyLabel and not lastLabelWasMajor and array.size(stateLabels) > 0
        replacedLabel = array.pop(stateLabels)
        label.delete(replacedLabel)
    labelLane = labelSlotCounter % 3
    laneOffset = labelOffsetAtr + labelLane * labelLaneSpreadAtr
    labelX = bar_index
    labelClearTop = labelClearTopSeries
    labelClearBottom = labelClearBottomSeries
    labelY = isLongSetup ? labelClearBottom - safeAtr * laneOffset : labelClearTop + safeAtr * laneOffset
    labelStyle = isLongSetup ? label.style_label_up : label.style_label_down
    compactState = entryState == "INVALIDATED" ? "INV" : entryState == "MONITOR" ? "MON" : entryState == "BLOCKED" ? "BLK" : entryState == "READY" ? "RDY" : "WAIT"
    fullStateText = entryState == "INVALIDATED" ? "INVALID" : entryState
    labelText = labelDetail == "Full" ? fullStateText + " " + f_score_text(readinessScore) + "\n" + setupText + "\nRisk " + riskText + " | Room " + targetText : compactState + " " + f_score_text(readinessScore) + "\nR " + riskShortText + " | T " + targetText
    newLabel = label.new(labelX, labelY, labelText, xloc = xloc.bar_index, yloc = yloc.price, style = labelStyle, color = color.new(stateColor, 6), textcolor = f_text_on(stateColor), size = f_size(labelFontSize))
    array.push(stateLabels, newLabel)
    labelSlotCounter += 1
    lastLabelBar := bar_index
    lastVisualState := entryState
    lastVisualScore := readinessScore
    lastVisualBias := setupBias
    lastLabelWasMajor := majorStateEvent
    while array.size(stateLabels) > maxVisibleObjects
        oldLabel = array.shift(stateLabels)
        label.delete(oldLabel)

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table infoPanel = table.new(f_panel_pos(panelLocation), 2, 7, border_width = 1, border_color = f_panel_border(), frame_width = 1, frame_color = f_panel_border())

if barstate.islast
    table.set_position(infoPanel, f_panel_pos(panelLocation))
    table.clear(infoPanel, 0, 0, 1, 6)
    if showPanel
        table.merge_cells(infoPanel, 0, 0, 1, 0)
        f_panel_cell(infoPanel, 0, 0, "AG Pro Entry Execution Readiness", headerText, headerBg, panelFontSize, "center")
        f_panel_cell(infoPanel, 0, 1, "Readiness Score", f_panel_label(), f_panel_bg(), panelFontSize, "left")
        f_panel_cell(infoPanel, 1, 1, f_score_text(readinessScore) + "/100", stateColor, f_panel_bg(), panelFontSize, "right")
        f_panel_cell(infoPanel, 0, 2, "Entry State", f_panel_label(), f_panel_alt_bg(), panelFontSize, "left")
        f_panel_cell(infoPanel, 1, 2, entryState + " | " + setupText, stateColor, f_panel_alt_bg(), panelFontSize, "right")
        f_panel_cell(infoPanel, 0, 3, "Risk Distance", f_panel_label(), f_panel_bg(), panelFontSize, "left")
        f_panel_cell(infoPanel, 1, 3, riskText + " | Rail " + f_price(invalidation), f_panel_value(), f_panel_bg(), panelFontSize, "right")
        f_panel_cell(infoPanel, 0, 4, "Target Room", f_panel_label(), f_panel_alt_bg(), panelFontSize, "left")
        f_panel_cell(infoPanel, 1, 4, targetText + " | Target " + f_price(targetPrice), f_panel_value(), f_panel_alt_bg(), panelFontSize, "right")
        f_panel_cell(infoPanel, 0, 5, "Readiness Hit Rate", f_panel_label(), f_panel_bg(), panelFontSize, "left")
        f_panel_cell(infoPanel, 1, 5, rdyRateText, rdyRateColor, f_panel_bg(), panelFontSize, "right")
        f_panel_cell(infoPanel, 0, 6, "Next Action", f_panel_label(), f_panel_alt_bg(), panelFontSize, "left")
        f_panel_cell(infoPanel, 1, 6, nextAction, f_panel_value(), f_panel_alt_bg(), panelFontSize, "right")

if barstate.isconfirmed
    previousState := entryState
    previousConfirmationQualified := confirmationQualified
````
