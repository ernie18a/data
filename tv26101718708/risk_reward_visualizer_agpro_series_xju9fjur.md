# Risk Reward Visualizer [AGPro Series]

- url: https://www.tradingview.com/script/Xju9FjuR-Risk-Reward-Visualizer-AGPro-Series/
- type: indicator
- pine_id: PUB;dd33acb6bb994f5bbe99459a8f264b2b
- version: 6.0

## Description

Risk Reward Visualizer [AGPro Series]

🔹 Overview

Risk Reward Visualizer is a professional trade-planning indicator that transforms every setup into a clean visual framework: entry, stop-loss, and up to three take-profit targets displayed as long rectangular R-multiple zones. Beyond basic visualization, it adds three features rarely found together in one tool — a breakeven probability calculator, live MFE/MAE excursion tracking, and an automatic trail-to-breakeven workflow.

The indicator is built for traders who think in R-multiples: swing traders, prop-firm candidates, day traders, and anyone who wants to answer the question "does this setup actually make mathematical sense?" before committing capital.

🔹 What Makes It Different

Most risk/reward scripts stop at drawing levels and a position-size table. This one goes further:

• Breakeven Probability Math — For every R target, the panel displays the minimum win rate required to break even, adjusted for round-trip fees. A 3R target needs only 25% wins; a 1R target needs 50%. Seeing this side-by-side reframes how you evaluate setups.

• Live MFE / MAE Tracking — Maximum Favorable Excursion and Maximum Adverse Excursion are tracked in real time from the moment the setup becomes valid. Labels mark the exact bar of each peak in R-multiples, with leader lines connecting the label to the wick, so you can grade trade quality after the fact.

• Trail-to-Breakeven Visualization — When TP1 is hit, the original stop fades and a new breakeven line is drawn at entry, making the risk management discipline visible on the chart.

• Hybrid Auto-Detect — Leave Entry and Stop at zero and the script fills them using the current close and the most recent swing pivot plus an ATR buffer. Provide one manually and the other auto-completes. Everything can be overridden.

🔹 Methodology

Levels are calculated from the standard R-multiple framework:

• Risk per unit = |Entry − Stop|
• Take-profit N = Entry ± (N × Risk per unit), signed by trade direction
• Breakeven win rate = (1 + fees_R) / (1 + R target)

Direction is auto-inferred from the relationship between Entry and Stop (Long when Stop is below Entry, Short otherwise), and can be forced. Auto-detect uses a pivot lookback to locate the most recent swing high or low, then offsets the stop by a user-defined ATR multiple to reduce wick-out risk.

MFE and MAE reset whenever Entry or Stop changes, so editing inputs restarts tracking cleanly. Hit detection uses bar high or low against each level and fires alerts only on the rising edge of each event.

🔹 Visuals & Signals

• Risk zone rendered as a pink rectangle between Entry and Stop
• TP1, TP2 and TP3 zones rendered as stacked teal rectangles with graded opacity
• Entry line in indigo, stop in pink, take-profits in teal
• Labels anchor to the right edge of the zone so they never hide candles
• MFE label on the favorable excursion peak, MAE on the adverse peak, each offset 1.5 ATR with a dotted leader line
• Alerts: TP1 hit, TP2 hit, TP3 hit, Stop Loss hit, Breakeven reached

🔹 Key Inputs

• Setup Mode — Manual, Auto-Detect, or Hybrid
• Trade Side — Auto, Long, or Short
• Entry and Stop — leave at zero to auto-detect
• Swing Lookback and ATR Buffer — for auto-detected stops
• TP1, TP2, TP3 multipliers with individual show/hide toggles
• Trail Stop to Breakeven After TP1 — toggle
• Round-Trip Fees (%) — folded into breakeven math
• Enable Position Size Calculator — optional; account size and risk percentage
• Panel location, panel font size, label font size, zone length, zone transparency

🔹 How To Use

Step 1 — Add the script to any symbol and timeframe. By default, Hybrid mode uses the current close as entry and the most recent swing plus an ATR buffer as stop.

Step 2 — Override Entry or Stop with your planned levels if you have a specific setup in mind.

Step 3 — Check the Breakeven Analysis section of the panel. Confirm the minimum win rate required for your chosen R target is realistic for your strategy.

Step 4 — Set alerts for the targets you want to be notified on. If Trail-to-Breakeven is enabled, you will also receive a notification when TP1 hits so you can move your stop in your broker.

Step 5 — After the trade, review MFE and MAE to grade execution. Did price reach favorable excursion that you missed? Did it dip deep into risk before resolving?

🔹 Limitations & Transparency

• This is a planning and visualization tool. It does not place orders and does not produce buy or sell signals.
• The breakeven calculation treats fees as a percentage of entry price converted into R-units. It is a useful approximation, not a tax or slippage model.
• Auto-detected stops depend on recent swing structure. On very low-liquidity symbols or during strong trends without pullbacks, recent swings may be stale. Verify visually before using.
• MFE and MAE tracking uses bar high or low and resets when inputs change.
• Position sizing assumes a linear contract value and does not account for margin, leverage, or instrument-specific tick rules. Always cross-check with your broker.

🔹 Risk Disclosure

Trading carries risk of loss. This indicator is provided for educational and analytical purposes only and is not financial advice. Past behavior of any tool does not guarantee future performance. Use proper position sizing and never risk more than you can afford to lose.

## Source Code

````pine
// -----------------------------------------------------
// Risk Reward Visualizer [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.4
//
// Risk Reward Visualizer is a premium trade planning and risk management
// overlay built for R-multiple review, stop-loss context, breakeven planning,
// target room evaluation, and active setup quality scoring. It maps entry,
// invalidation, risk box structure, R ladder targets, live R progress, a
// stop-aware follow-through proof rate, and a clear next-action state without
// becoming a full position planner or automated trading system. Version 2.4
// preserves the successful visual identity while adding close-safe event
// gating, honest rolling-plan R terminology, and a stable panel lifecycle.
// -----------------------------------------------------

//@version=6
indicator("Risk Reward Visualizer [AGPro Series]",
     shorttitle = "AG Pro RRV",
     overlay = true,
     max_lines_count = 120,
     max_labels_count = 120,
     max_boxes_count = 80)

// -----------------------------------------------------
// Tooltips
// -----------------------------------------------------
const string TT_SETUP_MODE = "Manual uses the exact entry and stop values you provide. Auto-Detect uses the current close and recent structure. Hybrid fills only the missing side of the setup."
const string TT_SIDE = "Auto infers direction from the entry and stop relationship, or from trend context when both values are auto-detected."
const string TT_ENTRY = "Manual entry price. Leave at zero in Auto-Detect or Hybrid mode to use the current close as a rolling planning reference. Rolling auto entry displays PLAN R near zero; use a fixed manual entry when live R tracking is required."
const string TT_STOP = "Manual stop-loss or invalidation price. Leave at zero in Auto-Detect or Hybrid mode to use recent structure with an ATR buffer."
const string TT_ANCHOR = "When enabled, R progress, MFE, MAE, and target states begin tracking from the selected anchor time."
const string TT_SENS = "Controls how strict the quality model is when grading stop distance, volatility fit, and action readiness."
const string TT_LOOKBACK = "Primary lookback used for recent structure, trend context, volatility fit, target-room evaluation, and the proof window."
const string TT_MIN_SCORE = "Minimum 0-100 Risk Box Quality score required before the panel can classify the setup as READY."
const string TT_CONFIRM = "Intrabar Touch reacts to high/low touches. Close Confirmation requires the bar to close through the level. Strict Close also requires stronger score context before READY states."
const string TT_COOLDOWN = "Minimum bars between event labels. Higher values keep the chart cleaner during fast-moving conditions."
const string TT_MAX_EVENTS = "Maximum number of historical event labels kept on the chart. Old labels are deleted first."
const string TT_EVENT_MEMORY = "Maximum age of historical event labels. Older labels are removed so stale READY states do not dominate the current chart."
const string TT_TARGET = "R-multiple target measured from entry using the current risk unit between entry and stop."
const string TT_BE = "R level where breakeven review becomes active. This is an attention marker, not an instruction."
const string TT_ZONE = "How far the risk and reward boxes extend into the future."
const string TT_PANEL = "Shows or hides the compact AGPro planning panel. Default is enabled for publication readability."
const string TT_PANEL_LOC = "Location of the compact AGPro planning panel."
const string TT_PANEL_THEME = "Selects a dark or light panel theme while preserving the standard AGPro blue header row."
const string TT_FONT = "Controls table or label text size. Normal is the publication default."

// -----------------------------------------------------
// Inputs
// -----------------------------------------------------
grpSetup = "Trade Setup"
inpMode = input.string("Hybrid", "Setup Mode", options = ["Manual", "Auto-Detect", "Hybrid"], group = grpSetup, tooltip = TT_SETUP_MODE)
inpSide = input.string("Auto", "Trade Side", options = ["Auto", "Long", "Short"], group = grpSetup, tooltip = TT_SIDE)
inpEntry = input.float(0.0, "Entry Price", minval = 0.0, group = grpSetup, tooltip = TT_ENTRY)
inpStop = input.float(0.0, "Stop Loss / Invalidation", minval = 0.0, group = grpSetup, tooltip = TT_STOP)
inpUseAnchor = input.bool(false, "Use Custom Anchor Time", group = grpSetup, tooltip = TT_ANCHOR)
inpAnchorBar = input.time(timestamp("2025-01-01 00:00"), "Anchor Time", group = grpSetup, tooltip = TT_ANCHOR)

grpEngine = "Decision Engine"
inpSensitivity = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Aggressive"], group = grpEngine, tooltip = TT_SENS)
inpLookback = input.int(34, "Lookback", minval = 10, maxval = 200, group = grpEngine, tooltip = TT_LOOKBACK)
inpMinScore = input.int(68, "Minimum Ready Score", minval = 0, maxval = 100, group = grpEngine, tooltip = TT_MIN_SCORE)
inpConfirmMode = input.string("Close Confirmation", "Confirmation Mode", options = ["Intrabar Touch", "Close Confirmation", "Strict Close"], group = grpEngine, tooltip = TT_CONFIRM)
inpCooldown = input.int(18, "Event Label Cooldown", minval = 0, maxval = 100, group = grpEngine, tooltip = TT_COOLDOWN)
inpMaxEventLabels = input.int(4, "Max Visible Event Labels", minval = 0, maxval = 30, group = grpEngine, tooltip = TT_MAX_EVENTS)
inpEventMemoryBars = input.int(72, "Event Label Memory Bars", minval = 10, maxval = 500, group = grpEngine, tooltip = TT_EVENT_MEMORY)

grpAuto = "Auto-Detect"
inpAtrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = grpAuto, tooltip = "ATR length used for stop buffers, label offsets, and volatility fit.")
inpAtrBuf = input.float(0.50, "ATR Buffer", minval = 0.0, maxval = 5.0, step = 0.05, group = grpAuto, tooltip = "Extra ATR cushion added beyond recent structure when the stop is auto-detected.")

grpTargets = "R Ladder"
inpTp1R = input.float(1.0, "Target 1", minval = 0.1, maxval = 20.0, step = 0.1, group = grpTargets, tooltip = TT_TARGET)
inpTp2R = input.float(2.0, "Target 2", minval = 0.1, maxval = 20.0, step = 0.1, group = grpTargets, tooltip = TT_TARGET)
inpTp3R = input.float(3.0, "Target 3", minval = 0.1, maxval = 20.0, step = 0.1, group = grpTargets, tooltip = TT_TARGET)
inpShowTp2 = input.bool(true, "Show Target 2", group = grpTargets, tooltip = "Displays the second R-multiple target zone and right-edge label.")
inpShowTp3 = input.bool(true, "Show Target 3", group = grpTargets, tooltip = "Displays the third R-multiple target zone and right-edge label.")
inpShowPartial = input.bool(true, "Show Partial Review Markers", group = grpTargets, tooltip = "Displays compact 0.5R and 1.5R review reference lines inside the R ladder.")
inpBETriggerR = input.float(1.0, "Breakeven Trigger R", minval = 0.1, maxval = 10.0, step = 0.1, group = grpTargets, tooltip = TT_BE)

grpVisual = "Visuals"
inpZoneExt = input.int(36, "Zone Length", minval = 8, maxval = 250, group = grpVisual, tooltip = TT_ZONE)
inpZoneOpacity = input.int(84, "Zone Transparency", minval = 55, maxval = 96, group = grpVisual, tooltip = "Transparency for risk and reward boxes. Lower values create stronger fills.")
inpShowProgress = input.bool(true, "Show Live R Progress Fill", group = grpVisual, tooltip = "Displays a live fill from entry to current price so the active R progress is visible at a glance.")
inpShowEventLabels = input.bool(true, "Show Event Labels", group = grpVisual, tooltip = "Shows compact READY, BE REVIEW, TARGET, and INVALIDATED labels with cooldown control.")
inpShowExcursionLabels = input.bool(false, "Show MFE/MAE Labels", group = grpVisual, tooltip = "Shows maximum favorable and adverse excursion labels. Disabled by default to keep publication screenshots focused on the active R ladder.")
inpMinExcursionR = input.float(0.35, "Minimum MFE/MAE Label R", minval = 0.0, maxval = 2.0, step = 0.05, group = grpVisual, tooltip = "Minimum R excursion required before MFE or MAE labels are shown. Higher values keep tiny fluctuation labels away from the main risk box.")
inpLabelSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpVisual, tooltip = TT_FONT)

grpPanel = "Panel"
inpShowPanel = input.bool(true, "Show Panel", group = grpPanel, tooltip = TT_PANEL)
inpPanelLoc = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = grpPanel, tooltip = TT_PANEL_LOC)
inpPanelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = grpPanel, tooltip = TT_PANEL_THEME)
inpPanelSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpPanel, tooltip = TT_FONT)

// -----------------------------------------------------
// AGPro Color Palette
// -----------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBg = color.rgb(15, 23, 42)
panelBorder = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)
darkInk = color.rgb(17, 24, 39)

// -----------------------------------------------------
// Helpers
// -----------------------------------------------------
f_size(s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        => size.normal

f_panel_pos(s) =>
    switch s
        "Top Right" => position.top_right
        "Top Left" => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_clamp(v, lo, hi) =>
    math.min(math.max(v, lo), hi)

// Luminance-145 contrast: bright fills get dark ink, dark fills get the header text.
f_text_on(_bg) =>
    lum = math.round(0.299 * color.r(_bg) + 0.587 * color.g(_bg) + 0.114 * color.b(_bg))
    lum >= 145 ? darkInk : headerText

f_fmt_price(v) =>
    na(v) ? "-" : str.tostring(v, format.mintick)

f_fmt_r(v) =>
    na(v) ? "-" : (v >= 0.0 ? "+" : "") + str.tostring(v, "0.00") + "R"

f_fmt_pct(v) =>
    na(v) ? "-" : str.tostring(v, "0.00") + "%"

f_score_txt(v) =>
    na(v) ? "-" : str.tostring(v, "0") + "/100"

f_target_hit(level, longSide, closeOnly) =>
    closeOnly ? (longSide ? close >= level : close <= level) : (longSide ? high >= level : low <= level)

f_stop_hit(level, longSide, closeOnly) =>
    closeOnly ? (longSide ? close <= level : close >= level) : (longSide ? low <= level : high >= level)

f_row(tbl, row, leftText, rightText, rightCol, bg, labelCol, txtSize) =>
    table.cell(tbl, 0, row, leftText, bgcolor = bg, text_color = labelCol, text_size = txtSize)
    table.cell(tbl, 1, row, rightText, bgcolor = bg, text_color = rightCol, text_size = txtSize)

// -----------------------------------------------------
// Context and setup resolution
// -----------------------------------------------------
atrVal = ta.atr(inpAtrLen)
atrSafe = math.max(nz(atrVal), ta.tr(true), syminfo.mintick)
atrBase = ta.sma(atrSafe, inpLookback)
emaFast = ta.ema(close, math.max(5, int(math.round(inpLookback * 0.50))))
emaSlow = ta.ema(close, inpLookback)

recentLow = ta.lowest(low, inpLookback)
recentHigh = ta.highest(high, inpLookback)

useAutoEntry = inpMode == "Auto-Detect" or (inpMode == "Hybrid" and inpEntry <= 0.0)
useAutoStop = inpMode == "Auto-Detect" or (inpMode == "Hybrid" and inpStop <= 0.0)

resolvedEntry = useAutoEntry ? close : inpEntry

forceLong = inpSide == "Long"
forceShort = inpSide == "Short"
autoTrendLong = emaFast >= emaSlow
prelimStopKnown = not useAutoStop and inpStop > 0.0

bool isLong = forceLong ? true : forceShort ? false : prelimStopKnown ? inpStop < resolvedEntry : autoTrendLong

autoStopLong = recentLow - inpAtrBuf * atrSafe
autoStopShort = recentHigh + inpAtrBuf * atrSafe
resolvedStop = useAutoStop ? (isLong ? autoStopLong : autoStopShort) : inpStop

if inpSide == "Auto" and not na(resolvedStop) and resolvedStop != resolvedEntry
    isLong := resolvedStop < resolvedEntry

setupValid = not na(resolvedEntry) and not na(resolvedStop) and resolvedEntry > 0.0 and resolvedStop > 0.0 and resolvedEntry != resolvedStop
riskUnit = setupValid ? math.abs(resolvedEntry - resolvedStop) : na
dir = isLong ? 1.0 : -1.0

tp1 = setupValid ? resolvedEntry + dir * inpTp1R * riskUnit : na
tp2 = setupValid ? resolvedEntry + dir * inpTp2R * riskUnit : na
tp3 = setupValid ? resolvedEntry + dir * inpTp3R * riskUnit : na
beLevel = setupValid ? resolvedEntry + dir * inpBETriggerR * riskUnit : na
partial1 = setupValid ? resolvedEntry + dir * 0.50 * riskUnit : na
partial2 = setupValid ? resolvedEntry + dir * 1.50 * riskUnit : na

currentR = setupValid and riskUnit > 0.0 ? dir * (close - resolvedEntry) / riskUnit : na
riskPctOfEntry = setupValid ? riskUnit / resolvedEntry * 100.0 : na
fixedEntryTracking = setupValid and not useAutoEntry

// -----------------------------------------------------
// Anchor and progress tracking
// -----------------------------------------------------
var int anchorSetBar = na
var float prevEntry = na
var float prevStop = na
var float mfePrice = na
var float maePrice = na
var int mfeBar = na
var int maeBar = na
var bool tp1Hit = false
var bool tp2Hit = false
var bool tp3Hit = false
var bool slHit = false
var bool beReached = false

setupChanged = setupValid and (na(prevEntry) or na(prevStop) or prevEntry != resolvedEntry or prevStop != resolvedStop)
if setupChanged
    anchorSetBar := inpUseAnchor ? na : bar_index
    prevEntry := resolvedEntry
    prevStop := resolvedStop
    mfePrice := resolvedEntry
    maePrice := resolvedEntry
    mfeBar := bar_index
    maeBar := bar_index
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    slHit := false
    beReached := false

if setupValid and inpUseAnchor and na(anchorSetBar) and time >= inpAnchorBar
    anchorSetBar := bar_index

afterAnchor = setupValid and not na(anchorSetBar) and bar_index >= anchorSetBar
closeConfirm = inpConfirmMode != "Intrabar Touch"
strictConfirm = inpConfirmMode == "Strict Close"
confirmedEventBar = inpConfirmMode == "Intrabar Touch" ? true : barstate.isconfirmed

if setupValid and afterAnchor and not slHit
    if isLong
        if na(mfePrice) or high > mfePrice
            mfePrice := high
            mfeBar := bar_index
        if na(maePrice) or low < maePrice
            maePrice := low
            maeBar := bar_index
    else
        if na(mfePrice) or low < mfePrice
            mfePrice := low
            mfeBar := bar_index
        if na(maePrice) or high > maePrice
            maePrice := high
            maeBar := bar_index

target1Now = setupValid and afterAnchor and confirmedEventBar and f_target_hit(tp1, isLong, closeConfirm)
target2Now = setupValid and afterAnchor and confirmedEventBar and inpShowTp2 and f_target_hit(tp2, isLong, closeConfirm)
target3Now = setupValid and afterAnchor and confirmedEventBar and inpShowTp3 and f_target_hit(tp3, isLong, closeConfirm)
stopNow = setupValid and afterAnchor and confirmedEventBar and f_stop_hit(resolvedStop, isLong, closeConfirm)
beNow = setupValid and afterAnchor and confirmedEventBar and currentR >= inpBETriggerR

if target1Now
    tp1Hit := true
if target2Now
    tp2Hit := true
if target3Now
    tp3Hit := true
if stopNow
    slHit := true
if beNow
    beReached := true

bestR = setupValid and not na(mfePrice) and riskUnit > 0.0 ? math.abs(mfePrice - resolvedEntry) / riskUnit : na
adverseR = setupValid and not na(maePrice) and riskUnit > 0.0 ? math.abs(maePrice - resolvedEntry) / riskUnit : na

// -----------------------------------------------------
// 0-100 Risk Box Quality model
// -----------------------------------------------------
idealRiskAtr = inpSensitivity == "Conservative" ? 1.20 : inpSensitivity == "Aggressive" ? 2.20 : 1.60
volTolerance = inpSensitivity == "Conservative" ? 0.55 : inpSensitivity == "Aggressive" ? 1.05 : 0.80

riskAtr = setupValid and atrSafe > 0.0 ? riskUnit / atrSafe : na
atrRatio = atrBase > 0.0 ? atrSafe / atrBase : 1.0

progressScore = setupValid ? f_clamp((currentR + 0.25) / (inpTp1R + 0.25) * 25.0, 0.0, 25.0) : na
distanceScore = setupValid and not na(riskAtr) ? f_clamp((1.0 - math.abs(riskAtr - idealRiskAtr) / idealRiskAtr) * 20.0, 0.0, 20.0) : na

nearestTargetLevel = not tp1Hit ? tp1 : inpShowTp2 and not tp2Hit ? tp2 : inpShowTp3 and not tp3Hit ? tp3 : na
nearestTargetR = not tp1Hit ? inpTp1R : inpShowTp2 and not tp2Hit ? inpTp2R : inpShowTp3 and not tp3Hit ? inpTp3R : na
targetRoomR = setupValid and not na(nearestTargetLevel) ? dir * (nearestTargetLevel - close) / riskUnit : 0.0
targetRoomScore = setupValid ? f_clamp(targetRoomR / 1.25 * 20.0, 0.0, 20.0) : na

trendAligned = setupValid ? (isLong ? emaFast >= emaSlow : emaFast <= emaSlow) : false
priceAligned = setupValid ? (isLong ? close >= emaFast : close <= emaFast) : false
trendScore = setupValid ? (trendAligned and priceAligned ? 20.0 : trendAligned or priceAligned ? 10.0 : 0.0) : na

volScore = setupValid ? f_clamp((1.0 - math.abs(atrRatio - 1.0) / volTolerance) * 15.0, 0.0, 15.0) : na
strictPenalty = strictConfirm and setupValid and currentR < 0.0 ? 5.0 : 0.0
qualityScoreRaw = setupValid ? progressScore + distanceScore + targetRoomScore + trendScore + volScore - strictPenalty : na
qualityScore = setupValid ? math.round(f_clamp(qualityScoreRaw, 0.0, 100.0)) : na

scoreTier = not setupValid ? "NO SETUP" : qualityScore >= 85 ? "A+ QUALITY" : qualityScore >= 75 ? "A QUALITY" : qualityScore >= inpMinScore ? "READY" : qualityScore >= 50 ? "REVIEW" : "LOW QUALITY"
riskBoxState = not setupValid ? "WAIT SETUP" : slHit or currentR <= -1.0 ? "INVALIDATED" : qualityScore >= inpMinScore ? "VALID RISK BOX" : "WEAK RISK BOX"

beState = not setupValid ? "BE WAIT" : slHit or currentR <= -1.0 ? "BE INVALID" : beReached and currentR <= 0.15 ? "BE DEFENSE" : beReached ? "BE ACTIVE" : currentR >= inpBETriggerR * 0.75 ? "BE REVIEW" : "BE WAIT"

nearestTargetText = not setupValid ? "-" : na(nearestTargetLevel) ? "Ladder complete" : nearestTargetLevel <= 0.0 ? "Beyond range" : "T" + (not tp1Hit ? "1" : inpShowTp2 and not tp2Hit ? "2" : "3") + " @ " + f_fmt_price(nearestTargetLevel) + " (" + str.tostring(nearestTargetR, "0.##") + "R)"

action = "WAIT SETUP"
if setupValid
    if slHit or currentR <= -1.0
        action := "INVALIDATED"
    else if targetRoomR <= 0.20 and not na(nearestTargetLevel)
        action := "BLOCKED ROOM"
    else if qualityScore < inpMinScore
        action := "WAIT - SCORE"
    else if beReached and currentR <= 0.15
        action := "BE DEFENSE"
    else if not beReached and currentR >= inpBETriggerR * 0.75
        action := "BE REVIEW"
    else if currentR >= inpTp2R
        action := "TARGET REVIEW"
    else if qualityScore >= inpMinScore
        action := "READY"
    else
        action := "MONITOR"

scoreColor = not setupValid ? panelValueCol : qualityScore >= 75 ? bullColor : qualityScore >= inpMinScore ? accentColor : qualityScore >= 50 ? neutralColor : bearColor
actionColor = action == "READY" or action == "TARGET REVIEW" ? bullColor : action == "INVALIDATED" or action == "BLOCKED ROOM" ? bearColor : action == "BE REVIEW" or action == "BE DEFENSE" ? neutralColor : accentColor
stateColor = setupValid and (slHit or currentR <= -1.0) ? bearColor : setupValid and qualityScore >= inpMinScore ? bullColor : setupValid ? neutralColor : panelValueCol

// -----------------------------------------------------
// Events and alerts
// -----------------------------------------------------
tp1Prev = bar_index > 0 ? tp1Hit[1] : false
tp2Prev = bar_index > 0 ? tp2Hit[1] : false
tp3Prev = bar_index > 0 ? tp3Hit[1] : false
slPrev = bar_index > 0 ? slHit[1] : false
bePrev = bar_index > 0 ? beReached[1] : false
readyNow = setupValid and action == "READY"
readyPrev = bar_index > 0 ? readyNow[1] : false
prevAction = bar_index > 0 ? action[1] : ""
prevCurrentR = bar_index > 0 ? currentR[1] : na

tp1Edge = tp1Hit and not tp1Prev
tp2Edge = tp2Hit and not tp2Prev
tp3Edge = tp3Hit and not tp3Prev
slEdge = slHit and not slPrev
beEdge = beReached and not bePrev

readyEdge = confirmedEventBar and readyNow and not readyPrev
beReviewEdge = confirmedEventBar and setupValid and action == "BE REVIEW" and prevAction != "BE REVIEW"
followThroughEdge = confirmedEventBar and (tp1Edge or tp2Edge or tp3Edge)
invalidEdge = confirmedEventBar and (slEdge or (setupValid and not na(prevCurrentR) and currentR <= -1.0 and prevCurrentR > -1.0))
stateShiftEdge = confirmedEventBar and setupValid and prevAction != "" and action != prevAction

alertcondition(readyEdge, title = "Risk Reward Visualizer Ready", message = "Risk Reward Visualizer: risk box is READY on {{ticker}} ({{interval}}).")
alertcondition(stateShiftEdge, title = "Risk Reward Visualizer State Shift", message = "Risk Reward Visualizer: action state changed on {{ticker}} ({{interval}}).")
alertcondition(invalidEdge, title = "Risk Reward Visualizer Invalidated", message = "Risk Reward Visualizer: risk box invalidated on {{ticker}} ({{interval}}).")
alertcondition(followThroughEdge, title = "Risk Reward Visualizer Follow-Through", message = "Risk Reward Visualizer: major R target reached on {{ticker}} ({{interval}}).")
alertcondition(beEdge or beReviewEdge, title = "Risk Reward Visualizer Breakeven Review", message = "Risk Reward Visualizer: breakeven review condition active on {{ticker}} ({{interval}}).")

// -----------------------------------------------------
// Stop-aware proof engine (1R follow-through)
// Of recent READY signals, how many reached +1R before -1R.
// barstate.isconfirmed gated, resolve-then-open, timeout uncounted.
// -----------------------------------------------------
var bool proofPending = false
var float proofEntry = na
var float proofRisk = na
var bool proofLong = false
var int proofStart = na
var int proofWins = 0
var int proofCount = 0

proofTargetR = inpTp1R
proofWindow = math.max(20, inpLookback)

if barstate.isconfirmed and setupValid
    if proofPending and not na(proofEntry) and not na(proofRisk) and proofRisk > 0.0
        winLvl = proofLong ? proofEntry + proofRisk * proofTargetR : proofEntry - proofRisk * proofTargetR
        lossLvl = proofLong ? proofEntry - proofRisk : proofEntry + proofRisk
        hitWin = proofLong ? high >= winLvl : low <= winLvl
        hitLoss = proofLong ? low <= lossLvl : high >= lossLvl
        if hitLoss
            proofCount += 1
            proofPending := false
        else if hitWin
            proofWins += 1
            proofCount += 1
            proofPending := false
        else if not na(proofStart) and bar_index - proofStart >= proofWindow
            proofPending := false
    if not proofPending and readyEdge and riskUnit > 0.0
        proofPending := true
        proofEntry := resolvedEntry
        proofRisk := riskUnit
        proofLong := isLong
        proofStart := bar_index

proofRate = proofCount > 0 ? proofWins / proofCount * 100.0 : na
proofReady = proofCount >= 6
proofTierCol = not proofReady ? panelLabelCol : proofRate >= 55.0 ? bullColor : proofRate >= 45.0 ? neutralColor : bearColor
proofValue = not proofReady ? "Building (" + str.tostring(proofCount) + ")" : str.tostring(math.round(proofRate), "0") + "% (" + str.tostring(proofCount) + ")"

// -----------------------------------------------------
// Historical event labels
// -----------------------------------------------------
var label[] eventLabels = array.new_label()
var int lastEventBar = na

if array.size(eventLabels) > 0
    for i = 0 to array.size(eventLabels) - 1
        label.set_size(array.get(eventLabels, i), f_size(inpLabelSize))

if array.size(eventLabels) > 0
    cleanupIdx = array.size(eventLabels) - 1
    while cleanupIdx >= 0
        oldLabel = array.get(eventLabels, cleanupIdx)
        oldX = label.get_x(oldLabel)
        if bar_index - oldX > inpEventMemoryBars
            label.delete(oldLabel)
            array.remove(eventLabels, cleanupIdx)
        cleanupIdx -= 1

eventAllowed = na(lastEventBar) ? true : bar_index - lastEventBar >= inpCooldown
eventText = ""
eventColor = accentColor
eventAbove = true

if invalidEdge
    eventText := "INVALIDATED\n" + f_fmt_r(currentR)
    eventColor := bearColor
    eventAbove := not isLong
else if followThroughEdge
    hitName = tp3Edge ? "TP3 HIT" : tp2Edge ? "TP2 HIT" : "TP1 HIT"
    eventText := hitName + "\n" + f_score_txt(qualityScore)
    eventColor := bullColor
    eventAbove := isLong
else if beEdge or beReviewEdge
    eventText := "BE REVIEW\n" + f_fmt_r(currentR)
    eventColor := neutralColor
    eventAbove := isLong
else if readyEdge
    eventText := "READY\n" + f_score_txt(qualityScore)
    eventColor := accentColor
    eventAbove := isLong

if inpShowEventLabels and eventAllowed and eventText != "" and inpMaxEventLabels > 0
    eventOffset = atrSafe * 1.55
    eventY = eventAbove ? high + eventOffset : low - eventOffset
    eventStyle = eventAbove ? label.style_label_down : label.style_label_up
    newEventLabel = label.new(bar_index, eventY, eventText, xloc = xloc.bar_index, style = eventStyle, color = color.new(eventColor, 6), textcolor = f_text_on(eventColor), size = f_size(inpLabelSize))
    array.push(eventLabels, newEventLabel)
    lastEventBar := bar_index
    while array.size(eventLabels) > inpMaxEventLabels
        label.delete(array.shift(eventLabels))

// -----------------------------------------------------
// Drawings
// -----------------------------------------------------
var line lineEntry = na
var line lineStop = na
var line lineTp1 = na
var line lineTp2 = na
var line lineTp3 = na
var line lineBE = na
var line linePartial1 = na
var line linePartial2 = na
var line lineCurrent = na
var line leaderMfe = na
var line leaderMae = na
var box boxRisk = na
var box boxTp1 = na
var box boxTp2 = na
var box boxTp3 = na
var box boxProgress = na
var label tagEntry = na
var label tagStop = na
var label tagTp1 = na
var label tagTp2 = na
var label tagTp3 = na
var label badgeRisk = na
var label badgeTp1 = na
var label badgeTp2 = na
var label badgeTp3 = na
var label lblCurrent = na
var label lblMfe = na
var label lblMae = na

if barstate.islast
    line.delete(lineEntry)
    line.delete(lineStop)
    line.delete(lineTp1)
    line.delete(lineTp2)
    line.delete(lineTp3)
    line.delete(lineBE)
    line.delete(linePartial1)
    line.delete(linePartial2)
    line.delete(lineCurrent)
    line.delete(leaderMfe)
    line.delete(leaderMae)
    box.delete(boxRisk)
    box.delete(boxTp1)
    box.delete(boxTp2)
    box.delete(boxTp3)
    box.delete(boxProgress)
    label.delete(tagEntry)
    label.delete(tagStop)
    label.delete(tagTp1)
    label.delete(tagTp2)
    label.delete(tagTp3)
    label.delete(badgeRisk)
    label.delete(badgeTp1)
    label.delete(badgeTp2)
    label.delete(badgeTp3)
    label.delete(lblCurrent)
    label.delete(lblMfe)
    label.delete(lblMae)

    if setupValid
        leftBack = math.max(2, int(math.round(inpZoneExt * 0.35)))
        leftIdx = math.max(bar_index - leftBack, 0)
        rightIdx = bar_index + inpZoneExt
        badgeIdx = int(math.round(leftIdx + (rightIdx - leftIdx) * 0.52))
        tSize = f_size(inpLabelSize)

        // Only draw targets at sensible (positive) prices; extreme auto-detect
        // setups on high timeframes can project R targets below zero.
        tp1Vis = tp1 > 0.0
        tp2Vis = inpShowTp2 and tp2 > 0.0
        tp3Vis = inpShowTp3 and tp3 > 0.0

        riskTop = math.max(resolvedEntry, resolvedStop)
        riskBottom = math.min(resolvedEntry, resolvedStop)
        tp1Top = math.max(resolvedEntry, tp1)
        tp1Bottom = math.min(resolvedEntry, tp1)
        tp2Top = math.max(tp1, tp2)
        tp2Bottom = math.min(tp1, tp2)
        tp3Base = inpShowTp2 ? tp2 : tp1
        tp3Top = math.max(tp3Base, tp3)
        tp3Bottom = math.min(tp3Base, tp3)
        progressTop = math.max(resolvedEntry, close)
        progressBottom = math.min(resolvedEntry, close)

        // Box fills (text moved to opaque centered badges)
        boxRisk := box.new(left = leftIdx, top = riskTop, right = rightIdx, bottom = riskBottom, xloc = xloc.bar_index, bgcolor = color.new(bearColor, inpZoneOpacity), border_color = color.new(bearColor, 42), border_width = 1)
        if tp1Vis
            boxTp1 := box.new(left = leftIdx, top = tp1Top, right = rightIdx, bottom = tp1Bottom, xloc = xloc.bar_index, bgcolor = color.new(bullColor, inpZoneOpacity), border_color = color.new(bullColor, 45), border_width = 1)
        if tp2Vis
            boxTp2 := box.new(left = leftIdx, top = tp2Top, right = rightIdx, bottom = tp2Bottom, xloc = xloc.bar_index, bgcolor = color.new(bullColor, math.min(inpZoneOpacity + 5, 96)), border_color = color.new(bullColor, 58), border_width = 1)
        if tp3Vis
            boxTp3 := box.new(left = leftIdx, top = tp3Top, right = rightIdx, bottom = tp3Bottom, xloc = xloc.bar_index, bgcolor = color.new(bullColor, math.min(inpZoneOpacity + 8, 97)), border_color = color.new(bullColor, 68), border_width = 1)

        if inpShowProgress and math.abs(close - resolvedEntry) > syminfo.mintick
            progressCol = currentR >= 0.0 ? bullColor : bearColor
            boxProgress := box.new(left = leftIdx, top = progressTop, right = rightIdx, bottom = progressBottom, xloc = xloc.bar_index, bgcolor = color.new(progressCol, 72), border_color = color.new(progressCol, 30), border_width = 1)

        // Reference lines stay at the true price levels (truth layer)
        lineEntry := line.new(leftIdx, resolvedEntry, rightIdx, resolvedEntry, xloc = xloc.bar_index, color = accentColor, width = 2, style = line.style_solid)
        lineStop := line.new(leftIdx, resolvedStop, rightIdx, resolvedStop, xloc = xloc.bar_index, color = bearColor, width = beReached ? 1 : 2, style = beReached ? line.style_dashed : line.style_solid)
        if tp1Vis
            lineTp1 := line.new(leftIdx, tp1, rightIdx, tp1, xloc = xloc.bar_index, color = bullColor, width = 2, style = line.style_solid)
        if tp2Vis
            lineTp2 := line.new(leftIdx, tp2, rightIdx, tp2, xloc = xloc.bar_index, color = bullColor, width = 1, style = line.style_dashed)
        if tp3Vis
            lineTp3 := line.new(leftIdx, tp3, rightIdx, tp3, xloc = xloc.bar_index, color = bullColor, width = 1, style = line.style_dashed)

        if beLevel > 0.0
            lineBE := line.new(leftIdx, beLevel, rightIdx, beLevel, xloc = xloc.bar_index, color = neutralColor, width = 1, style = beReached ? line.style_solid : line.style_dotted)

        if inpShowPartial
            if partial1 > 0.0
                linePartial1 := line.new(leftIdx, partial1, rightIdx, partial1, xloc = xloc.bar_index, color = color.new(neutralColor, 35), width = 1, style = line.style_dotted)
            if partial2 > 0.0
                linePartial2 := line.new(leftIdx, partial2, rightIdx, partial2, xloc = xloc.bar_index, color = color.new(neutralColor, 48), width = 1, style = line.style_dotted)

        // Opaque centered zone badges (pushed right of the live readout) with vertical anti-collision
        priceRange = math.max(recentHigh - recentLow, atrSafe * 4.0)
        badgeGap = math.max(priceRange * 0.045, atrSafe * 1.10)
        riskC = (resolvedEntry + resolvedStop) / 2.0
        t1C0 = (resolvedEntry + tp1) / 2.0
        t2C0 = (tp1 + tp2) / 2.0
        t3C0 = (tp3Base + tp3) / 2.0
        t1C = isLong ? math.max(t1C0, riskC + badgeGap) : math.min(t1C0, riskC - badgeGap)
        t2C = isLong ? math.max(t2C0, t1C + badgeGap) : math.min(t2C0, t1C - badgeGap)
        t3C = isLong ? math.max(t3C0, t2C + badgeGap) : math.min(t3C0, t2C - badgeGap)

        badgeRisk := label.new(badgeIdx, riskC, "RISK BOX · " + f_score_txt(qualityScore), xloc = xloc.bar_index, style = label.style_label_center, color = scoreColor, textcolor = f_text_on(scoreColor), size = tSize)
        if tp1Vis
            badgeTp1 := label.new(badgeIdx, t1C, "TP1 · " + str.tostring(inpTp1R, "0.##") + "R" + (tp1Hit ? " HIT" : ""), xloc = xloc.bar_index, style = label.style_label_center, color = bullColor, textcolor = f_text_on(bullColor), size = tSize)
        if tp2Vis
            badgeTp2 := label.new(badgeIdx, t2C, "TP2 · " + str.tostring(inpTp2R, "0.##") + "R" + (tp2Hit ? " HIT" : ""), xloc = xloc.bar_index, style = label.style_label_center, color = bullColor, textcolor = f_text_on(bullColor), size = tSize)
        if tp3Vis
            badgeTp3 := label.new(badgeIdx, t3C, "TP3 · " + str.tostring(inpTp3R, "0.##") + "R" + (tp3Hit ? " HIT" : ""), xloc = xloc.bar_index, style = label.style_label_center, color = bullColor, textcolor = f_text_on(bullColor), size = tSize)

        // Right-edge level tags (rightIdx column) with bidirectional anti-collision fan
        tagGap = math.max(priceRange * 0.04, atrSafe * 0.85)
        entryTagY = resolvedEntry
        stopTagY = isLong ? math.min(resolvedStop, entryTagY - tagGap) : math.max(resolvedStop, entryTagY + tagGap)
        t1TagY = isLong ? math.max(tp1, entryTagY + tagGap) : math.min(tp1, entryTagY - tagGap)
        t2TagY = isLong ? math.max(tp2, t1TagY + tagGap) : math.min(tp2, t1TagY - tagGap)
        t3TagY = isLong ? math.max(tp3, t2TagY + tagGap) : math.min(tp3, t2TagY - tagGap)

        entryText = (isLong ? "ENTRY LONG " : "ENTRY SHORT ") + f_fmt_price(resolvedEntry)
        stopText = "STOP -1R " + f_fmt_price(resolvedStop)
        tp1Text = "TP1 " + str.tostring(inpTp1R, "0.##") + "R " + f_fmt_price(tp1) + (tp1Hit ? " HIT" : "")
        tp2Text = "TP2 " + str.tostring(inpTp2R, "0.##") + "R " + f_fmt_price(tp2) + (tp2Hit ? " HIT" : "")
        tp3Text = "TP3 " + str.tostring(inpTp3R, "0.##") + "R " + f_fmt_price(tp3) + (tp3Hit ? " HIT" : "")

        tagEntry := label.new(rightIdx, entryTagY, entryText, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(accentColor, 6), textcolor = f_text_on(accentColor), size = tSize)
        tagStop := label.new(rightIdx, stopTagY, stopText, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(bearColor, beReached ? 42 : 6), textcolor = f_text_on(bearColor), size = tSize)
        if tp1Vis
            tagTp1 := label.new(rightIdx, t1TagY, tp1Text, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(bullColor, 6), textcolor = f_text_on(bullColor), size = tSize)
        if tp2Vis
            tagTp2 := label.new(rightIdx, t2TagY, tp2Text, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(bullColor, 16), textcolor = f_text_on(bullColor), size = tSize)
        if tp3Vis
            tagTp3 := label.new(rightIdx, t3TagY, tp3Text, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(bullColor, 26), textcolor = f_text_on(bullColor), size = tSize)

        // R cockpit readout pinned to the current candle, single line and body.
        // The prefix distinguishes fixed-entry tracking from a rolling auto plan.
        // extending strictly left (style_label_right) so it clears both the badge
        // column and the entry/price lines at any zoom.
        liveOffset = atrSafe * 1.10
        liveY = isLong ? close + liveOffset : close - liveOffset
        rReadoutPrefix = fixedEntryTracking ? "LIVE R " : "PLAN R "
        lblCurrent := label.new(bar_index, liveY, rReadoutPrefix + f_fmt_r(currentR) + "  ·  " + action, xloc = xloc.bar_index, style = label.style_label_right, color = color.new(stateColor, 6), textcolor = f_text_on(stateColor), size = tSize)

        labelOffset = atrSafe * 1.55
        if inpShowExcursionLabels and fixedEntryTracking and not na(mfePrice) and not na(mfeBar) and not na(bestR) and bestR >= inpMinExcursionR
            mfeLabelY = isLong ? mfePrice + labelOffset : mfePrice - labelOffset
            leaderMfe := line.new(mfeBar, mfePrice, mfeBar, mfeLabelY, xloc = xloc.bar_index, color = color.new(bullColor, 40), width = 1, style = line.style_dotted)
            lblMfe := label.new(mfeBar, mfeLabelY, "MFE +" + str.tostring(bestR, "0.00") + "R", xloc = xloc.bar_index, style = isLong ? label.style_label_down : label.style_label_up, color = color.new(bullColor, 10), textcolor = f_text_on(bullColor), size = tSize)

        if inpShowExcursionLabels and fixedEntryTracking and not na(maePrice) and not na(maeBar) and not na(adverseR) and adverseR >= inpMinExcursionR
            maeLabelY = isLong ? maePrice - labelOffset : maePrice + labelOffset
            leaderMae := line.new(maeBar, maePrice, maeBar, maeLabelY, xloc = xloc.bar_index, color = color.new(bearColor, 40), width = 1, style = line.style_dotted)
            lblMae := label.new(maeBar, maeLabelY, "MAE -" + str.tostring(adverseR, "0.00") + "R", xloc = xloc.bar_index, style = isLong ? label.style_label_up : label.style_label_down, color = color.new(bearColor, 10), textcolor = f_text_on(bearColor), size = tSize)

// -----------------------------------------------------
// Panel
// -----------------------------------------------------
darkTheme = inpPanelTheme == "Dark"
panelBgDyn = darkTheme ? panelBg : color.rgb(248, 250, 252)
panelLabelDyn = darkTheme ? panelLabelCol : color.rgb(71, 85, 105)
panelValueDyn = darkTheme ? panelValueCol : color.rgb(15, 23, 42)
panelBorderDyn = darkTheme ? panelBorder : color.rgb(203, 213, 225)
var table panel = table.new(f_panel_pos(inpPanelLoc), 2, 7, border_width = 1, frame_color = panelBorderDyn, frame_width = 1, border_color = panelBorderDyn)

if barstate.islast
    table.set_position(panel, f_panel_pos(inpPanelLoc))
    table.clear(panel, 0, 0, 1, 6)
    if inpShowPanel
        panelSize = f_size(inpPanelSize)

        table.cell(panel, 0, 0, "AG Pro Risk Reward Visualizer", bgcolor = headerBg, text_color = headerText, text_size = panelSize)
        table.cell(panel, 1, 0, "", bgcolor = headerBg, text_color = headerText, text_size = panelSize)
        table.merge_cells(panel, 0, 0, 1, 0)

        riskBoxValue = setupValid ? f_score_txt(qualityScore) + " - " + scoreTier : "WAIT SETUP"
        currentRValue = setupValid ? f_fmt_r(currentR) : "-"
        currentRLabel = useAutoEntry ? "Planning R" : "Current R"

        f_row(panel, 1, "Risk Box", riskBoxValue, scoreColor, panelBgDyn, panelLabelDyn, panelSize)

        currentRBg = setupValid ? color.new(stateColor, 18) : panelBgDyn
        table.cell(panel, 0, 2, currentRLabel, bgcolor = panelBgDyn, text_color = panelLabelDyn, text_size = panelSize)
        table.cell(panel, 1, 2, currentRValue, bgcolor = currentRBg, text_color = setupValid ? f_text_on(stateColor) : panelValueDyn, text_size = panelSize)

        proofBg = proofReady ? color.new(proofTierCol, 14) : panelBgDyn
        proofTxtCol = proofReady ? f_text_on(proofTierCol) : panelLabelDyn
        table.cell(panel, 0, 3, "1R Proof", bgcolor = panelBgDyn, text_color = panelLabelDyn, text_size = panelSize)
        table.cell(panel, 1, 3, proofValue, bgcolor = proofBg, text_color = proofTxtCol, text_size = panelSize)

        f_row(panel, 4, "BE State", beState, beState == "BE ACTIVE" ? bullColor : beState == "BE DEFENSE" ? neutralColor : beState == "BE INVALID" ? bearColor : beState == "BE REVIEW" ? neutralColor : panelValueDyn, panelBgDyn, panelLabelDyn, panelSize)
        f_row(panel, 5, "Nearest Target", nearestTargetText, panelValueDyn, panelBgDyn, panelLabelDyn, panelSize)
        f_row(panel, 6, "Action", action, actionColor, panelBgDyn, panelLabelDyn, panelSize)

// -----------------------------------------------------
// Data window
// -----------------------------------------------------
plot(setupValid ? qualityScore : na, title = "Risk Box Quality Score", color = scoreColor, display = display.data_window)
plot(setupValid ? currentR : na, title = "R Progress", color = stateColor, display = display.data_window)
plot(setupValid ? targetRoomR : na, title = "Target Room R", color = accentColor, display = display.data_window)
plot(proofReady ? proofRate : na, title = "1R Proof Rate", color = proofTierCol, display = display.data_window)
````
