# Price Rejection Readiness [AGPro Series]

- url: https://www.tradingview.com/script/HqPtkViQ-Price-Rejection-Readiness-AGPro-Series/
- type: indicator
- pine_id: PUB;77cf8e64b9064dbcadf442f2078a78d1
- version: 4.0

## Description

Price Rejection Readiness [AGPro Series]

🧠 Core Idea

Is the current price rejection strong enough to deserve attention now?


📌 Overview / What it does

Price Rejection Readiness [AGPro Series] is a chart-first rejection planning tool built to evaluate whether a wick-based rejection is only noise, a watch condition, a confirmed context, or a failed attempt.

The script produces a 0-100 Readiness Score, a rejection pocket, wick-quality label, confirmation rail, invalidation rail, target review rail, controlled chart labels, and a compact AG Pro decision panel.

It does not predict price direction, automate execution, or mark every wick as important. Its role is to organize rejection context into a cleaner planning workflow.


🎯 Purpose & Design Philosophy

Many rejection tools stop at candle recognition. They mark long wicks, pin bars, or local reactions without showing whether the context is ready, waiting, confirmed, or failing.

This script was built for traders who want a decision-support layer around rejection behavior. It helps users evaluate validity, quality, confirmation, risk boundary, target room, and the next action from one clean visual structure.

The design philosophy is planning first. A rejection candle should not be treated as a conclusion by itself. It should be evaluated through structure, participation, follow-through, and risk context.


⚡ Why This Script Is Different

Most tools focus on detecting a wick or highlighting a candle pattern.

This script does NOT clone Rejection Block Quality, Pin Bar Quality Filter, Reaction Efficiency Meter, order-block tools, or generic support/resistance maps.

Instead, it asks whether the current rejection is ready to be monitored as a structured plan. It scores wick dominance, close location, local reference pressure, volume response, and follow-through, then maps a practical confirmation rail, invalidation rail, and target review area.


⚙️ Methodology

1. Context Detection
The script measures the current candle body, wick dominance, wick share, close location, volume response, and local reference pressure.

2. Reference Mapping
When a valid rejection forms, the script draws a candle-native rejection pocket from the wick extreme to the rejection body area. This is not a broad support/resistance zone.

3. Reaction Evaluation
The engine converts wick quality, close strength, reference pressure, volume behavior, and follow-through into a 0-100 Readiness Score.

4. Visual Output
Accepted plans create a rejection pocket, confirmation rail, invalidation rail, target review rail, event labels, and a compact AG Pro panel.


🗺️ How to Read the Chart

Rejection Pocket = the candle-native area where the rejection originated.

Confirmation Rail = the price boundary that must be respected or exceeded according to the selected confirmation mode.

Invalidation Rail = the price boundary beyond the wick where the rejection plan is no longer valid.

Target Review Rail = a projected review area based on the distance from active price to invalidation.

Labels = compact event markers for Ready, Confirmed, Failed Rejection, and Target Review.

Colors = teal for bullish rejection context, pink for bearish rejection context, indigo for confirmation, gold for target review, and red for invalidation.

Panel = shows Rejection Side, Readiness, Wick Quality, Confirmation, Invalid / Target, and Action.


🚦 Signals & States

• Scan → no active rejection plan exists.

• Watch → rejection quality meets the minimum threshold but still needs confirmation.

• Ready → rejection quality is strong enough to review risk and confirmation context.

• Confirmed → the active rejection plan confirmed according to the selected confirmation mode.

• Failed → price closed beyond the invalidation rail.

• Target Review → price reached the projected target review rail.


🔔 Alerts Logic

Bullish Rejection Ready triggers when a bullish rejection reaches the configured readiness threshold.

Bearish Rejection Ready triggers when a bearish rejection reaches the configured readiness threshold.

Rejection Confirmed triggers when the active rejection plan confirms according to the selected confirmation mode.

Rejection Failed triggers when the active plan closes beyond its invalidation rail.

Target Review Reached triggers when price reaches the projected target review rail.

Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The readiness score becomes stronger when wick dominance, close location, local reference pressure, volume response, and directional follow-through align.

No single component is treated as absolute. A visually strong wick can still receive a weaker score if close location, participation, or follow-through are poor.


📊 When to Use

• Price-action review after a visible wick rejection

• Pullback or reaction environments where rejection quality matters

• Breakout failure, continuation delay, or reversal-watch contexts

• Charts where traders need risk and confirmation boundaries, not just a candle marker


⚠️ When NOT to Use

• Extremely low-liquidity symbols

• Very noisy micro timeframes with poor candle quality

• News spikes where wick structure can be unstable

• Markets where volume data is missing or unreliable


🎛️ Key Inputs

• Sensitivity → controls how strict the rejection engine is.

• Reference Lookback → defines the local edge used for context.

• Minimum Readiness Score → filters weak rejection plans.

• Confirmation Mode → controls how strict the confirmation rail behavior must be.

• Invalidation Buffer ATR → places the risk rail beyond normal candle noise.

• Target Review Multiple → projects the target review rail from risk distance.

• Visual settings → control pockets, rails, labels, object count, label size, panel visibility, panel location, theme, and panel font size.


🖥️ Interface & Visual Design

The interface is built around a compact AG Pro panel and a chart-first planning layer.

The pocket, rails, and labels are intentionally direct: they show where the rejection originated, where confirmation is evaluated, where the plan fails, and where review becomes relevant.

The design avoids crowded signal dumping and keeps the chart readable while still providing enough visible labels for publication-quality context.


🧪 Practical Usage Workflow

1. Read the panel to identify the active rejection side and readiness score.

2. Check the rejection pocket to see where the wick response originated.

3. Compare price behavior against the confirmation rail.

4. Use the invalidation rail and target review rail as planning context.

5. Interpret the next-action state instead of treating the label as a command.


🔍 Interpretation Guidelines

A high readiness score means the rejection has stronger structural qualities, not certainty.

A confirmed rejection means price respected the selected confirmation rule, not that future direction is guaranteed.

A failed rejection means the active plan lost its defined risk boundary and should be reviewed as invalidated context.

Target Review means the projected review area was reached and the context should be reassessed.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not auto trading

• Not guaranteed signals

• Not an order-block or rejection-block detector

• Not a generic support/resistance map


⚠️ Limitations & Transparency

Rejection quality can vary across symbols, timeframes, volatility regimes, and volume conditions.

The local reference component is designed for context, not complete market-structure mapping.

The target rail is a review boundary, not a promised destination.

The script is rule-based and reactive. It organizes information after conditions appear on the chart.


🧠 Market Context Notes

Wick rejection can be more meaningful when it appears near a local edge, forms with clear close behavior, and receives follow-through.

It can be weaker when the candle is isolated, the close location is poor, or the market is moving through unstable volatility.

Use the tool as a structured context layer inside a broader trading plan.


🧾 Use Case Examples

When price forms a lower-wick rejection near a recent local low and closes strongly above the body area, the planner may create a bullish readiness state with a visible pocket and confirmation rail.

When price forms an upper-wick rejection near a recent local high but later closes beyond the invalidation rail, the planner marks the setup as failed instead of keeping the rejection narrative active.


🧱 System Philosophy

AGPro tools are designed to turn raw chart events into structured interpretation.

This script follows that philosophy by transforming rejection candles into a readiness workflow: score, state, risk, confirmation, target review, and next action.


🔐 Non-Promise Statement

No script can remove uncertainty from markets.

This tool highlights rule-based rejection context and leaves final interpretation to the user.


📉 Risk Disclosure

Trading involves risk.

This script is for educational and analytical use only.

It does not provide financial advice, investment advice, or guaranteed trading outcomes.

Users are responsible for their own decisions, risk management, and market interpretation.


📚 Educational Note

Use Price Rejection Readiness as a structured reading layer for rejection behavior, not as a standalone decision system.

## Source Code

````pine
// -------------------------------------------------
// Price Rejection Readiness [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Price Rejection Readiness is a chart-first rejection planner for traders who
// want to evaluate wick rejection, close location, local reference pressure,
// volume response, confirmation behavior, invalidation, and target room in one
// clean decision workflow. It does not build rejection blocks, order blocks, or
// a generic support/resistance map. The goal is simple: measure whether the
// current rejection context is ready, waiting, confirmed, or failing. Version 1.5
// gives every live reference rail a filled owner badge and keeps rail objects only
// for the active plan, while historical pockets retain their centered state badge.
// -------------------------------------------------

//@version=6
indicator("Price Rejection Readiness [AGPro Series]",
     shorttitle = "AG Pro PRR",
     overlay = true,
     max_boxes_count = 80,
     max_lines_count = 120,
     max_labels_count = 120)

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
riskColor     = color.rgb(239, 68, 68)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupCore = "Core Engine"
sensitivity = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Aggressive"], group = groupCore, tooltip = "Controls how strict the rejection-readiness engine is. Conservative requires cleaner wick dominance and close location; Aggressive allows earlier watch states.")
lookback = input.int(34, "Reference Lookback", minval = 10, maxval = 200, group = groupCore, tooltip = "Defines the local reference window used to judge whether a rejection forms near an important recent edge.")
minScore = input.int(62, "Minimum Readiness Score", minval = 40, maxval = 90, group = groupCore, tooltip = "Minimum 0-100 score required before a rejection plan is drawn and labeled.")
confirmationMode = input.string("Balanced", "Confirmation Mode", options = ["Strict", "Balanced", "Fast"], group = groupCore, tooltip = "Strict requires a close through the confirmation rail. Balanced accepts a close beyond the rejection body with directional follow-through. Fast reacts earlier when price probes the rail and closes back on the rejection side.")
atrLen = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupCore, tooltip = "ATR length used for adaptive offsets, risk buffers, target room, and visual spacing.")
volumeLen = input.int(30, "Volume Baseline Length", minval = 5, maxval = 200, group = groupCore, tooltip = "Volume moving average length used to evaluate whether a rejection candle forms with stronger participation than recent activity.")

groupRisk = "Risk / Target"
riskBufferAtr = input.float(0.18, "Invalidation Buffer ATR", minval = 0.0, maxval = 2.0, step = 0.01, group = groupRisk, tooltip = "Adds an ATR-based buffer beyond the rejection wick to place the invalidation rail away from normal candle noise.")
targetR = input.float(1.50, "Target Review Multiple", minval = 0.50, maxval = 5.00, step = 0.25, group = groupRisk, tooltip = "Projects the target review rail as a multiple of the distance between the active close and invalidation rail.")
forwardBars = input.int(20, "Pocket Forward Bars", minval = 8, maxval = 120, group = groupRisk, tooltip = "Controls how far the active rejection pocket, confirmation rail, invalidation rail, and target guide extend to the right.")

groupVisual = "Visuals"
showPockets = input.bool(true, "Show Rejection Pockets", group = groupVisual, tooltip = "Shows the candle-native rejection pocket between the wick extreme and the rejection body area.")
showRails = input.bool(true, "Show Confirmation / Risk / Target Rails", group = groupVisual, tooltip = "Shows confirmation, invalidation, and target review rails for the active rejection plan.")
showLabels = input.bool(true, "Show Labels", group = groupVisual, tooltip = "Shows compact chart labels for readiness, confirmation, failure, and target review states.")
showPocketTag = input.bool(true, "Show Pocket Tags", group = groupVisual, tooltip = "Shows a contrast-safe centered badge inside each rejection pocket.")
showTargetLabels = input.bool(false, "Show Target Review Labels", group = groupVisual, tooltip = "Shows a target-review event label when price reaches the projected review rail. Disabled by default to reduce repeated event noise.")
labelTextMode = input.string("Compact", "Label Text Mode", options = ["Compact", "Full"], group = groupVisual, tooltip = "Compact keeps chart labels shorter for premium screenshots. Full uses longer descriptive event text.")
cooldownBars = input.int(18, "Label Cooldown Bars", minval = 1, maxval = 100, group = groupVisual, tooltip = "Minimum number of bars between new readiness labels. Higher values reduce repeated event printing and keep the chart cleaner.")
visiblePlanBundles = input.int(3, "Visible Plan Bundles", minval = 1, maxval = 6, group = groupVisual, tooltip = "Limits retained historical rejection pockets and their centered state badges. Confirmation, invalidation, and target rails belong only to the active plan.")
maxVisibleObjects = input.int(5, "Max Event Badges", minval = 3, maxval = 20, group = groupVisual, tooltip = "Limits separate confirmation, failure, and optional target-review badges. Pocket state badges are managed with their complete plan bundles.")
labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual, tooltip = "Controls the size of all chart labels created by this script. Normal is the default AGPro publishing preset.")

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = "Shows or hides the AGPro decision panel. The panel is enabled by default for publication clarity.")
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = groupPanel, tooltip = "Selects where the AGPro panel appears on the chart.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = "Switches the panel between the dark AGPro theme and a light chart-friendly theme.")
panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = "Controls the font size used inside the AGPro panel. Normal is the default AGPro publishing preset.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_size(txt) =>
    switch txt
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_pos(txt) =>
    switch txt
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right

f_clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))

f_text_on(_c) =>
    _lum = (color.r(_c) * 299 + color.g(_c) * 587 + color.b(_c) * 114) / 1000
    _lum >= 145 ? color.rgb(17, 24, 39) : headerText

f_readable(_c) =>
    _lum = (color.r(_c) * 299 + color.g(_c) * 587 + color.b(_c) * 114) / 1000
    panelTheme == "Light" and _lum > 140 ? color.rgb(15, 23, 42) : (panelTheme == "Dark" and _lum < 96 ? panelValueCol : _c)

// Vertical anti-collision for chart labels
var float[] lblBars = array.new_float()
var float[] lblYs = array.new_float()

f_reg(_x, _y, _bars, _ys) =>
    array.push(_bars, _x)
    array.push(_ys, _y)
    if array.size(_bars) > 20
        array.shift(_bars)
        array.shift(_ys)

f_resolve_y(_x, _yBase, _dir, _sep, _bars, _ys) =>
    float _y = _yBase
    bool _clash = true
    int _g = 0
    while _clash and _g < 14
        _clash := false
        if array.size(_bars) > 0
            for _i = 0 to array.size(_bars) - 1
                if math.abs(_x - array.get(_bars, _i)) <= 26 and math.abs(_y - array.get(_ys, _i)) < _sep
                    _y := _y + _dir * _sep
                    _clash := true
        _g += 1
    f_reg(_x, _y, _bars, _ys)
    _y

f_score(v) =>
    int(math.round(f_clamp(v, 0.0, 100.0)))

f_price(v) =>
    na(v) ? "n/a" : str.tostring(v, format.mintick)

f_side_name(side) =>
    side == 1 ? "Bullish Rejection" : side == -1 ? "Bearish Rejection" : "No Active Plan"

f_ready_text(side, score) =>
    labelTextMode == "Compact" ? (side == 1 ? "BULL READY | Q " : "BEAR READY | Q ") + str.tostring(score) : (side == 1 ? "BULL REJECTION READY | Q " : "BEAR REJECTION READY | Q ") + str.tostring(score)

f_confirm_text(score) =>
    labelTextMode == "Compact" ? "CONFIRMED | Q " + str.tostring(score) : "REJECTION CONFIRMED | Q " + str.tostring(score)

f_fail_text() =>
    labelTextMode == "Compact" ? "FAILED" : "REJECTION FAILED"

f_target_text() =>
    labelTextMode == "Compact" ? "TARGET REVIEW" : "TARGET REVIEW REACHED"

f_pocket_text(side, state, score) =>
    _side = side == 1 ? (labelTextMode == "Compact" ? "BULL POCKET" : "BULL REJECTION POCKET") : (labelTextMode == "Compact" ? "BEAR POCKET" : "BEAR REJECTION POCKET")
    _side + "\n" + state + " | Q " + str.tostring(score)

f_rail_text(kind, price) =>
    kind + " " + f_price(price)

f_state_color(side, failed, confirmed, score) =>
    failed ? riskColor : confirmed ? accentColor : side == 1 ? bullColor : side == -1 ? bearColor : score >= minScore ? neutralColor : panelValueCol

f_panel_bg() =>
    panelTheme == "Light" ? color.rgb(248, 250, 252) : panelBg

f_panel_label() =>
    panelTheme == "Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value() =>
    panelTheme == "Light" ? color.rgb(15, 23, 42) : panelValueCol

var array<box> planBoxes = array.new_box()
var array<label> planBadges = array.new_label()
var array<label> eventBadges = array.new_label()

f_keep_event(item) =>
    array.push(eventBadges, item)
    if array.size(eventBadges) > maxVisibleObjects
        old = array.shift(eventBadges)
        label.delete(old)

f_keep_plan(pocket, badge) =>
    array.push(planBoxes, pocket)
    array.push(planBadges, badge)
    if array.size(planBoxes) > visiblePlanBundles
        oldPocket = array.shift(planBoxes)
        oldBadge = array.shift(planBadges)
        if not na(oldPocket)
            box.delete(oldPocket)
        if not na(oldBadge)
            label.delete(oldBadge)

f_set_plan_badge(badge, side, state, score, badgeColor) =>
    if not na(badge)
        label.set_text(badge, f_pocket_text(side, state, score))
        label.set_color(badge, badgeColor)
        label.set_textcolor(badge, f_text_on(badgeColor))

// -------------------------------------------------
// Rejection Readiness Engine
// -------------------------------------------------
atrRaw = ta.atr(atrLen)
atr = math.max(nz(atrRaw, high - low), syminfo.mintick)
barRange = math.max(high - low, syminfo.mintick)
body = math.abs(close - open)
bodySafe = math.max(body, syminfo.mintick)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
upperRatio = upperWick / bodySafe
lowerRatio = lowerWick / bodySafe
upperShare = upperWick / barRange
lowerShare = lowerWick / barRange
closeLocation = (close - low) / barRange

volNow = nz(volume, 0.0)
volBase = math.max(nz(ta.sma(volume, volumeLen), volNow), 1.0)
volRatio = volNow / volBase

refHigh = ta.highest(high[1], lookback)
refLow = ta.lowest(low[1], lookback)
nearRefHigh = high >= refHigh - atr * 0.35
nearRefLow = low <= refLow + atr * 0.35
shortLookback = math.max(5, int(lookback / 3))

minWickRatio = sensitivity == "Conservative" ? 2.35 : sensitivity == "Balanced" ? 1.85 : 1.45
minWickShare = sensitivity == "Conservative" ? 0.48 : sensitivity == "Balanced" ? 0.42 : 0.34
minCloseLoc = sensitivity == "Conservative" ? 0.64 : sensitivity == "Balanced" ? 0.57 : 0.50

bullRaw = lowerRatio >= minWickRatio and lowerShare >= minWickShare and closeLocation >= minCloseLoc and lowerWick > upperWick
bearRaw = upperRatio >= minWickRatio and upperShare >= minWickShare and closeLocation <= 1.0 - minCloseLoc and upperWick > lowerWick

bullWickScore = f_clamp((lowerRatio / (minWickRatio * 2.20)) * 30.0, 0.0, 30.0)
bearWickScore = f_clamp((upperRatio / (minWickRatio * 2.20)) * 30.0, 0.0, 30.0)
bullCloseScore = f_clamp((closeLocation - 0.45) / 0.55 * 20.0, 0.0, 20.0)
bearCloseScore = f_clamp((0.55 - closeLocation) / 0.55 * 20.0, 0.0, 20.0)
bullLevelScore = nearRefLow ? 18.0 : low < ta.lowest(low[1], shortLookback) + atr * 0.30 ? 10.0 : 4.0
bearLevelScore = nearRefHigh ? 18.0 : high > ta.highest(high[1], shortLookback) - atr * 0.30 ? 10.0 : 4.0
volumeScore = f_clamp((volRatio - 0.80) / 1.20 * 15.0, 0.0, 15.0)
bullFollowScore = close > open ? 17.0 : close > close[1] ? 10.0 : 4.0
bearFollowScore = close < open ? 17.0 : close < close[1] ? 10.0 : 4.0

bullScore = f_score(bullWickScore + bullCloseScore + bullLevelScore + volumeScore + bullFollowScore)
bearScore = f_score(bearWickScore + bearCloseScore + bearLevelScore + volumeScore + bearFollowScore)

newBull = bullRaw and bullScore >= minScore
newBear = bearRaw and bearScore >= minScore

// -------------------------------------------------
// Active plan state
// -------------------------------------------------
var int activeSide = 0
var int activeBar = na
var float activeScore = na
var float activeWickRatio = na
var float activePocketTop = na
var float activePocketBottom = na
var float activeRail = na
var float activeInvalidation = na
var float activeTarget = na
var bool activeConfirmed = false
var bool activeFailed = false
var bool activeTargetHit = false
var int lastReadinessLabelBar = na
var label activePocketBadge = na
var line activeConfirmRail = na
var line activeInvalidRail = na
var line activeTargetRail = na
var label activeConfirmRailBadge = na
var label activeInvalidRailBadge = na
var label activeTargetRailBadge = na

canPrintReadiness = na(lastReadinessLabelBar) or bar_index - lastReadinessLabelBar >= cooldownBars
createPlan = barstate.isconfirmed and (newBull or newBear) and canPrintReadiness

if createPlan
    if not na(activeConfirmRail)
        line.delete(activeConfirmRail)
    if not na(activeInvalidRail)
        line.delete(activeInvalidRail)
    if not na(activeTargetRail)
        line.delete(activeTargetRail)
    if not na(activeConfirmRailBadge)
        label.delete(activeConfirmRailBadge)
    if not na(activeInvalidRailBadge)
        label.delete(activeInvalidRailBadge)
    if not na(activeTargetRailBadge)
        label.delete(activeTargetRailBadge)
    activeConfirmRail := na
    activeInvalidRail := na
    activeTargetRail := na
    activeConfirmRailBadge := na
    activeInvalidRailBadge := na
    activeTargetRailBadge := na

    activeSide := newBull ? 1 : -1
    activeBar := bar_index
    activeScore := newBull ? bullScore : bearScore
    activeWickRatio := newBull ? lowerRatio : upperRatio
    activePocketTop := newBull ? math.min(open, close) : high
    activePocketBottom := newBull ? low : math.max(open, close)
    activeRail := newBull ? high + atr * 0.05 : low - atr * 0.05
    activeInvalidation := newBull ? low - atr * riskBufferAtr : high + atr * riskBufferAtr
    planRisk = math.abs(close - activeInvalidation)
    activeTarget := newBull ? close + planRisk * targetR : close - planRisk * targetR
    activeConfirmed := false
    activeFailed := false
    activeTargetHit := false
    lastReadinessLabelBar := bar_index

    planColor = activeSide == 1 ? bullColor : bearColor
    planBg = color.new(planColor, 86)
    planBorder = color.new(planColor, 20)
    labelY = activeSide == 1 ? low - atr * 0.95 : high + atr * 0.95
    labelStyle = activeSide == 1 ? label.style_label_up : label.style_label_down
    labelText = f_ready_text(activeSide, int(activeScore))
    box pocket = na
    label pocketBadge = na

    if showPockets
        pocket := box.new(bar_index, activePocketTop, bar_index + forwardBars, activePocketBottom, xloc = xloc.bar_index, bgcolor = planBg, border_color = planBorder, border_width = 1)
        if showLabels and showPocketTag
            centerLabelX = bar_index + int(math.round(forwardBars * 0.50))
            centerLabelY = (activePocketTop + activePocketBottom) * 0.50
            pocketBadge := label.new(centerLabelX, centerLabelY, f_pocket_text(activeSide, "WATCH", int(activeScore)), xloc = xloc.bar_index, style = label.style_label_center, textcolor = f_text_on(planColor), color = color.new(planColor, 0), size = f_size(labelFontSize), textalign = text.align_center)
            f_reg(centerLabelX, centerLabelY, lblBars, lblYs)

    if showRails
        railRight = bar_index + forwardBars
        activeConfirmRail := line.new(bar_index, activeRail, railRight, activeRail, xloc = xloc.bar_index, color = color.new(accentColor, 0), width = 2, style = line.style_solid)
        activeInvalidRail := line.new(bar_index, activeInvalidation, railRight, activeInvalidation, xloc = xloc.bar_index, color = color.new(riskColor, 0), width = 2, style = line.style_dashed)
        activeTargetRail := line.new(bar_index, activeTarget, railRight, activeTarget, xloc = xloc.bar_index, color = color.new(neutralColor, 0), width = 1, style = line.style_dotted)
        if showLabels
            activeConfirmRailBadge := label.new(railRight, activeRail, f_rail_text("CONFIRM", activeRail), xloc = xloc.bar_index, style = label.style_label_left, textcolor = f_text_on(accentColor), color = color.new(accentColor, 0), size = f_size(labelFontSize))
            activeInvalidRailBadge := label.new(railRight, activeInvalidation, f_rail_text("INVALID", activeInvalidation), xloc = xloc.bar_index, style = label.style_label_left, textcolor = f_text_on(riskColor), color = color.new(riskColor, 0), size = f_size(labelFontSize))
            activeTargetRailBadge := label.new(railRight, activeTarget, f_rail_text("TARGET", activeTarget), xloc = xloc.bar_index, style = label.style_label_left, textcolor = f_text_on(neutralColor), color = color.new(neutralColor, 0), size = f_size(labelFontSize))

    f_keep_plan(pocket, pocketBadge)
    activePocketBadge := pocketBadge

    if showLabels and na(pocketBadge)
        float readyY = f_resolve_y(bar_index, labelY, activeSide == 1 ? -1.0 : 1.0, atr * 1.30, lblBars, lblYs)
        readyLabel = label.new(bar_index, readyY, labelText, xloc = xloc.bar_index, style = labelStyle, textcolor = f_text_on(planColor), color = color.new(planColor, 0), size = f_size(labelFontSize))
        f_keep_event(readyLabel)

bullStrictConfirm = activeSide == 1 and close > activeRail
bearStrictConfirm = activeSide == -1 and close < activeRail
bullBalancedConfirm = activeSide == 1 and close > activePocketTop and close > open
bearBalancedConfirm = activeSide == -1 and close < activePocketBottom and close < open
bullFastConfirm = activeSide == 1 and high >= activeRail and close > activePocketTop
bearFastConfirm = activeSide == -1 and low <= activeRail and close < activePocketBottom

failedNow = barstate.isconfirmed and not activeFailed and activeSide != 0 and bar_index > activeBar and (activeSide == 1 ? close < activeInvalidation : close > activeInvalidation)
confirmedNow = barstate.isconfirmed and not failedNow and not activeConfirmed and not activeFailed and activeSide != 0 and bar_index > activeBar and (
     confirmationMode == "Strict" ? (bullStrictConfirm or bearStrictConfirm) :
     confirmationMode == "Fast" ? (bullFastConfirm or bearFastConfirm) :
     (bullBalancedConfirm or bearBalancedConfirm))

targetNow = barstate.isconfirmed and not failedNow and not activeTargetHit and not activeFailed and activeSide != 0 and bar_index > activeBar and (activeSide == 1 ? high >= activeTarget : low <= activeTarget)

if confirmedNow
    activeConfirmed := true
    f_set_plan_badge(activePocketBadge, activeSide, "CONFIRMED", int(activeScore), accentColor)
    if not na(activeConfirmRailBadge)
        label.set_text(activeConfirmRailBadge, f_rail_text("CONFIRMED", activeRail))
    if showLabels
        confirmY = activeSide == 1 ? high + atr * 0.85 : low - atr * 0.85
        confirmStyle = activeSide == 1 ? label.style_label_down : label.style_label_up
        float confirmYr = f_resolve_y(bar_index, confirmY, activeSide == 1 ? 1.0 : -1.0, atr * 1.30, lblBars, lblYs)
        confirmLabel = label.new(bar_index, confirmYr, f_confirm_text(int(activeScore)), xloc = xloc.bar_index, style = confirmStyle, textcolor = f_text_on(accentColor), color = color.new(accentColor, 0), size = f_size(labelFontSize))
        f_keep_event(confirmLabel)

if failedNow
    activeFailed := true
    f_set_plan_badge(activePocketBadge, activeSide, "FAILED", int(activeScore), riskColor)
    if showLabels
        failY = activeSide == 1 ? low - atr * 1.10 : high + atr * 1.10
        failStyle = activeSide == 1 ? label.style_label_up : label.style_label_down
        float failYr = f_resolve_y(bar_index, failY, activeSide == 1 ? -1.0 : 1.0, atr * 1.30, lblBars, lblYs)
        failLabel = label.new(bar_index, failYr, f_fail_text(), xloc = xloc.bar_index, style = failStyle, textcolor = f_text_on(riskColor), color = color.new(riskColor, 0), size = f_size(labelFontSize))
        f_keep_event(failLabel)

if targetNow
    activeTargetHit := true
    f_set_plan_badge(activePocketBadge, activeSide, "TARGET REVIEW", int(activeScore), neutralColor)
    if showLabels and showTargetLabels
        targetY = activeSide == 1 ? high + atr * 1.05 : low - atr * 1.05
        targetStyle = activeSide == 1 ? label.style_label_down : label.style_label_up
        float targetYr = f_resolve_y(bar_index, targetY, activeSide == 1 ? 1.0 : -1.0, atr * 1.30, lblBars, lblYs)
        targetLabel = label.new(bar_index, targetYr, f_target_text(), xloc = xloc.bar_index, style = targetStyle, textcolor = f_text_on(neutralColor), color = color.new(neutralColor, 0), size = f_size(labelFontSize))
        f_keep_event(targetLabel)

if failedNow or targetNow
    if not na(activeConfirmRail)
        line.delete(activeConfirmRail)
    if not na(activeInvalidRail)
        line.delete(activeInvalidRail)
    if not na(activeTargetRail)
        line.delete(activeTargetRail)
    if not na(activeConfirmRailBadge)
        label.delete(activeConfirmRailBadge)
    if not na(activeInvalidRailBadge)
        label.delete(activeInvalidRailBadge)
    if not na(activeTargetRailBadge)
        label.delete(activeTargetRailBadge)
    activeConfirmRail := na
    activeInvalidRail := na
    activeTargetRail := na
    activeConfirmRailBadge := na
    activeInvalidRailBadge := na
    activeTargetRailBadge := na

// -------------------------------------------------
// Target-reach proof (stop-aware)
// -------------------------------------------------
// From each new rejection plan, did price reach the target review rail before
// closing through the invalidation rail? Win = target first, Loss = invalidation
// first, neither inside the window = uncounted.
var int   pfTotal  = 0
var int   pfWins   = 0
var bool  pfOpen   = false
var int   pfDir    = 0
var float pfTarget = na
var float pfStop   = na
var int   pfBar    = na
int pfWindow = forwardBars * 2

if barstate.isconfirmed
    if pfOpen
        bool pfWin  = pfDir == 1 ? high >= pfTarget : low <= pfTarget
        bool pfLoss = pfDir == 1 ? close < pfStop : close > pfStop
        if pfLoss
            pfTotal += 1
            pfOpen  := false
        else if pfWin
            pfTotal += 1
            pfWins  += 1
            pfOpen  := false
        else if not na(pfBar) and bar_index - pfBar > pfWindow
            pfOpen := false
    if createPlan
        pfOpen   := true
        pfDir    := activeSide
        pfTarget := activeTarget
        pfStop   := activeInvalidation
        pfBar    := bar_index

float pfRate = pfTotal > 0 ? pfWins / pfTotal * 100.0 : na

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table panel = table.new(f_pos(panelLocation), 2, 8, bgcolor = f_panel_bg(), border_width = 1, border_color = panelBorder)
if barstate.isfirst
    table.merge_cells(panel, 0, 0, 1, 0)

stateText = activeSide == 0 ? "Scan" : activeFailed ? "Failed" : activeTargetHit ? "Target Review" : activeConfirmed ? "Confirmed" : activeScore >= minScore + 15 ? "Ready" : "Watch"
actionText = activeSide == 0 ? "Scan for clean rejection" : activeFailed ? "Stop monitoring" : activeTargetHit ? "Review target room" : activeConfirmed ? "Manage confirmation" : activeScore >= minScore + 15 ? "Review risk and rail" : "Wait for confirmation"
confirmText = activeSide == 0 ? "No active rail" : activeFailed ? "Invalidated" : activeTargetHit ? "Target reached" : activeConfirmed ? "Confirmed" : "Waiting at " + f_price(activeRail)
riskTargetText = activeSide == 0 ? "n/a" : "Invalid " + f_price(activeInvalidation) + " | Target " + f_price(activeTarget)
wickText = activeSide == 0 ? "n/a" : str.tostring(activeWickRatio, "#.##") + "x wick/body"
scoreText = activeSide == 0 ? "0 / 100" : str.tostring(int(activeScore)) + " / 100"
targetRateText = pfTotal >= 6 ? str.tostring(math.round(pfRate)) + "%  (" + str.tostring(pfTotal) + ")" : "Building (" + str.tostring(pfTotal) + ")"
targetRateColBase = pfTotal >= 6 ? (pfRate >= 55.0 ? bullColor : pfRate >= 45.0 ? neutralColor : bearColor) : f_panel_value()
targetRateCol = f_readable(targetRateColBase)
panelStateColor = f_readable(f_state_color(activeSide, activeFailed, activeConfirmed, nz(activeScore, 0)))

if showPanel
    table.cell(panel, 0, 0, "AG Pro Price Rejection Readiness", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSize), text_halign = text.align_center)
    table.cell(panel, 0, 1, "Rejection Side", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = f_size(panelFontSize), text_halign = text.align_left)
    table.cell(panel, 1, 1, f_side_name(activeSide), text_color = panelStateColor, bgcolor = f_panel_bg(), text_size = f_size(panelFontSize), text_halign = text.align_right)
    table.cell(panel, 0, 2, "Readiness", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = f_size(panelFontSize), text_halign = text.align_left)
    table.cell(panel, 1, 2, scoreText + " | " + stateText, text_color = panelStateColor, bgcolor = f_panel_bg(), text_size = f_size(panelFontSize), text_halign = text.align_right)
    table.cell(panel, 0, 3, "Wick Quality", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = f_size(panelFontSize), text_halign = text.align_left)
    table.cell(panel, 1, 3, wickText, text_color = f_panel_value(), bgcolor = f_panel_bg(), text_size = f_size(panelFontSize), text_halign = text.align_right)
    table.cell(panel, 0, 4, "Confirmation", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = f_size(panelFontSize), text_halign = text.align_left)
    table.cell(panel, 1, 4, confirmText, text_color = f_panel_value(), bgcolor = f_panel_bg(), text_size = f_size(panelFontSize), text_halign = text.align_right)
    table.cell(panel, 0, 5, "Invalid / Target", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = f_size(panelFontSize), text_halign = text.align_left)
    table.cell(panel, 1, 5, riskTargetText, text_color = f_panel_value(), bgcolor = f_panel_bg(), text_size = f_size(panelFontSize), text_halign = text.align_right)
    table.cell(panel, 0, 6, "Target Rate", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = f_size(panelFontSize), text_halign = text.align_left)
    table.cell(panel, 1, 6, targetRateText, text_color = targetRateCol, bgcolor = f_panel_bg(), text_size = f_size(panelFontSize), text_halign = text.align_right)
    table.cell(panel, 0, 7, "Action", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = f_size(panelFontSize), text_halign = text.align_left)
    table.cell(panel, 1, 7, actionText, text_color = panelStateColor, bgcolor = f_panel_bg(), text_size = f_size(panelFontSize), text_halign = text.align_right)
else
    table.cell(panel, 0, 0, "", text_color = color.new(headerText, 100), bgcolor = color.new(headerBg, 100), text_size = f_size(panelFontSize))
    for row = 1 to 7
        table.cell(panel, 0, row, "", text_color = color.new(headerText, 100), bgcolor = color.new(panelBg, 100), text_size = f_size(panelFontSize))
        table.cell(panel, 1, row, "", text_color = color.new(headerText, 100), bgcolor = color.new(panelBg, 100), text_size = f_size(panelFontSize))

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(createPlan and activeSide == 1, "Bullish Rejection Ready", "Bullish rejection readiness reached the configured threshold. Review the pocket, confirmation rail, invalidation, and target context.")
alertcondition(createPlan and activeSide == -1, "Bearish Rejection Ready", "Bearish rejection readiness reached the configured threshold. Review the pocket, confirmation rail, invalidation, and target context.")
alertcondition(confirmedNow, "Rejection Confirmed", "The active rejection plan has confirmed according to the selected confirmation mode.")
alertcondition(failedNow, "Rejection Failed", "The active rejection plan closed beyond its invalidation rail.")
alertcondition(targetNow, "Target Review Reached", "The active rejection plan reached its projected target review rail.")
````
