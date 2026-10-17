# Impulse Correction Balance Map [AGPro Series]

- url: https://www.tradingview.com/script/S3XZveqH-Impulse-Correction-Balance-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;7ecc78467ff8458eae18cbaad0e8b926
- version: 4.0

## Description

Impulse Correction Balance Map [AGPro Series]

🧠 Core Idea

Is the current correction still healthy compared with the prior impulse, or is the impulse losing structural balance?


📌 Overview / What it does

Impulse Correction Balance Map is a rule-based impulse and correction visualization tool designed to compare the current pullback with the prior directional swing leg.

The script identifies a valid bullish or bearish impulse, measures correction depth, maps the healthy-to-balanced correction pocket, and highlights whether price is still respecting the impulse structure or moving into failure risk.

It does not predict price direction, automate trades, or guarantee continuation after a pullback. It is a structured market-structure and wave-analysis tool for reading impulse strength, correction depth, balance, continuation, and failure context.


🎯 Purpose & Design Philosophy

Many pullback tools mark a retracement or draw generic Fibonacci levels.

This script was built to answer a more practical question:

Is the correction proportionate to the impulse that created it?

The design goal is to help traders evaluate pullbacks as part of a complete impulse-correction relationship instead of treating every retracement as equal.


⚡ Why This Script Is Different

Most tools focus on static retracement levels, generic trend strength, or simple pullback labels.

This script does NOT mark every pullback as a clean opportunity.

Instead, it builds the impulse leg first, measures the correction against that leg, separates healthy correction, balanced pullback, deep correction, continuation, and failure risk, then displays the story through premium chart visuals and a compact AG Pro panel.


⚙️ Methodology

1. Swing Detection

The script uses confirmed swing pivots to identify meaningful bullish or bearish impulse legs.

2. Impulse Validation

An impulse must meet a minimum ATR-normalized size before it becomes the active reference leg.

3. Correction Mapping

After the impulse forms, the script tracks the deepest correction point and calculates retracement depth as a percentage of the impulse.

4. Balance Evaluation

Correction depth is classified into healthy, balanced, deep, continuation, or failure states.

5. Visual Output

The chart displays the impulse box, correction pocket, depth ladder, centered pocket label, right-side tags, event labels, alerts, and a compact AG Pro decision panel.


🗺️ How to Read the Chart

Impulse Box = the prior validated directional swing leg.

Correction Pocket = the projected healthy-to-balanced retracement area.

Depth Ladder = reference rails for shallow, balanced, and deep correction zones.

Centered Pocket Label = the main visual anchor for the active balance pocket and quality score.

Right-Side Tags = current correction depth, balance state, and continuation reference.

Event Labels = key moments such as healthy correction, deep correction, continuation, or correction failure.

Panel = summarizes balance state, impulse direction, correction depth, impulse size, quality score, next context, and timeframe.


🚦 Signals & States

• HEALTHY CORRECTION → correction depth remains shallow relative to the impulse.

• BALANCED PULLBACK → correction is deeper but still inside the normal balance area.

• DEEP CORRECTION → correction is pressing into a riskier retracement zone.

• HIGH FAILURE RISK → correction is beyond the preferred balance area.

• CONTINUATION → price extends beyond the impulse end in the impulse direction.

• CORRECTION FAIL → price invalidates the impulse start area.

• WAIT IMPULSE → no valid impulse reference is active yet.


🔔 Alerts Logic

Alerts trigger when a major impulse-correction state appears.

• Healthy Correction → correction remains inside the healthy retracement area.

• Deep Correction Risk → correction depth moves into the deep-correction risk area.

• Continuation Trigger → price breaks beyond the impulse end in the impulse direction.

• Correction Failure → correction invalidates the impulse start area.

Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The context becomes stronger when:

• The impulse leg is large enough relative to ATR
• Correction depth remains proportionate
• Price respects the balance pocket
• Continuation appears after a controlled correction
• The panel state agrees with the event label
• Broader trend structure supports the impulse direction

If these elements do not align, the script avoids forcing a continuation interpretation.


📊 When to Use

• Trend continuation analysis
• Pullback evaluation
• Swing structure review
• Crypto, forex, stocks, and index markets
• Wave-style impulse and correction studies
• 1H, 4H, and daily charts
• Markets with clear directional legs and retracement behavior


⚠️ When NOT to Use

• Very low-liquidity symbols
• Extremely choppy markets with no clear swing structure
• News-driven candles where pivots may be distorted
• Ultra-low timeframes with excessive noise
• Markets where every pullback is immediately invalidated by volatility
• Situations where a single retracement should not be treated as a standalone decision


🎛️ Key Inputs

• Swing Pivot Length → controls how swing highs and lows are confirmed.

• Minimum Impulse ATR → defines how large the impulse must be before it becomes active.

• ATR Length → normalizes impulse size, label spacing, and correction context.

• Healthy Correction Max % → defines the upper boundary of the shallow correction zone.

• Balance Correction Max % → defines the upper boundary of the balanced correction zone.

• Deep Correction Max % → defines the deep-correction risk boundary.

• Projection Bars → controls how far correction pockets, rails, and tags project.

• Label Font Size → controls chart label and tag text size.

• Panel Font Size → controls panel text size.


🖥️ Interface & Visual Design

The visual hierarchy is built around the impulse-correction relationship.

The impulse box shows the directional leg.

The correction pocket shows where a controlled retracement can remain balanced.

The depth ladder shows where the correction becomes shallow, balanced, deep, or risky.

The centered badge makes the pocket readable at first glance.

The AG Pro panel summarizes the current state without forcing the user to inspect every level manually.


🧪 Practical Usage Workflow

1. Wait for a valid impulse leg to appear.

2. Check the correction pocket and depth ladder.

3. Read the current balance state in the panel.

4. Watch whether the correction stays healthy, becomes deep, or fails.

5. Look for continuation only after the correction context remains controlled.

6. Interpret the result inside broader trend, liquidity, and volatility context.


🔍 Interpretation Guidelines

A healthy correction does not guarantee continuation. It means the retracement is still proportionate to the prior impulse.

A deep correction does not guarantee reversal. It means the pullback is approaching an area where the original impulse is less structurally clean.

A continuation trigger does not guarantee follow-through. It means price extended beyond the impulse end according to the script's rule set.

A correction failure is a structural warning, not a trading command.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not provide guaranteed entry or exit signals.

It is not a standard Fibonacci retracement tool.

It is not a full Elliott Wave counter.


⚠️ Limitations & Transparency

Swing detection depends on pivot confirmation, so signals can appear after pivots are confirmed.

Timeframe differences can change impulse and correction structure.

High volatility may cause correction depth to expand quickly.

Low-liquidity markets may produce unreliable swing pivots.

The script is designed for structured interpretation, not certainty.


🧠 Market Context Notes

Impulse-correction behavior is strongest when the market has a clear directional leg, a readable retracement, and enough liquidity for swing structure to matter.

The same correction depth can mean different things in a strong trend, a range, or a volatility shock.

The script should be read together with broader structure, volume, volatility, and market regime.


🧾 Use Case Examples

• If a bullish impulse forms and the correction remains shallow, the map may show healthy correction context.

• If a bearish impulse forms and price retraces deeply against it, the map may show deep correction or failure risk.

• If price breaks beyond the impulse end after a controlled correction, the map may show continuation.


🧱 System Philosophy

Impulse Correction Balance Map is part of the AGPro Series approach to decision-support tools:

clear structure, premium chart readability, honest interpretation, and no promise of certainty.

The goal is to help traders understand the relationship between impulse strength and correction depth without turning analysis into signal spam.


🔐 Non-Promise Statement

No script can know the future.

No correction depth guarantees continuation or reversal.

No signal should be interpreted without broader market context.


📉 Risk Disclosure

Trading involves risk.

Markets can move unpredictably.

This script is for educational and analytical purposes only.

It does not provide financial advice or guaranteed trading outcomes.

Users remain responsible for their own decisions.


📚 Educational Note

Use this script to study how impulses and corrections relate to each other.

The value is not only in the label. The value is in learning whether a pullback is proportionate, stretched, balanced, or structurally weak compared with the impulse that came before it.

## Source Code

````pine
// --------------------------------------------------
// Impulse Correction Balance Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Impulse Correction Balance Map compares the current correction with the
// prior directional impulse. It highlights the impulse leg, maps the healthy
// correction pocket, measures retracement depth, marks continuation or failure
// behavior, tracks a self-tested continuation rate, and summarizes the context
// in an AG Pro panel.
// --------------------------------------------------

//@version=6
indicator("Impulse Correction Balance Map [AGPro Series]",
     shorttitle = "AGP ICBM",
     overlay = true,
     max_labels_count = 48,
     max_lines_count = 12,
     max_boxes_count = 6)

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
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
darkText      = color.rgb(17, 24, 39)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
G_ENGINE = "Impulse Engine"
G_VISUAL = "Visual Design"
G_PANEL  = "Panel"
G_ALERTS = "Alerts"

pivotLen = input.int(5, "Swing Pivot Length", minval = 2, maxval = 30, group = G_ENGINE,
     tooltip = "Defines how many bars confirm swing highs and lows used to build the impulse leg.")
minImpulseAtr = input.float(1.8, "Minimum Impulse ATR", minval = 0.3, maxval = 8.0, step = 0.1, group = G_ENGINE,
     tooltip = "Minimum impulse size, normalized by ATR, required before a swing leg becomes the active impulse.")
atrLen = input.int(14, "ATR Length", minval = 5, maxval = 100, group = G_ENGINE,
     tooltip = "ATR is used to normalize impulse quality, label spacing, and correction depth context.")
healthyMax = input.float(38.2, "Healthy Correction Max %", minval = 10.0, maxval = 60.0, step = 0.1, group = G_ENGINE,
     tooltip = "Maximum retracement depth treated as a shallow or healthy correction.")
balanceMax = input.float(61.8, "Balance Correction Max %", minval = 30.0, maxval = 85.0, step = 0.1, group = G_ENGINE,
     tooltip = "Maximum retracement depth treated as a balanced correction before deep-correction risk increases.")
failureMax = input.float(78.6, "Deep Correction Max %", minval = 50.0, maxval = 95.0, step = 0.1, group = G_ENGINE,
     tooltip = "Retracement depth above this area is treated as high failure risk before full impulse invalidation.")
proofWindowBars = input.int(6, "Continuation Proof Window", minval = 2, maxval = 60, group = G_ENGINE,
     tooltip = "After a continuation trigger, the map waits this many bars and checks whether price is still beyond the impulse end in the impulse direction. Feeds the Continuation Hit Rate readout in the panel.")

showImpulseBox = input.bool(true, "Show Impulse Leg", group = G_VISUAL,
     tooltip = "Displays the active impulse leg as a clean directional box.")
showCorrectionPocket = input.bool(true, "Show Correction Pocket", group = G_VISUAL,
     tooltip = "Displays the projected healthy-to-balanced correction pocket after the active impulse.")
showDepthLadder = input.bool(true, "Show Depth Ladder", group = G_VISUAL,
     tooltip = "Displays 38.2%, 61.8%, and deep-correction reference rails for the active impulse.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Prints compact event labels for healthy corrections, deep corrections, continuations, and failures.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Displays compact right-side tags for correction depth, balance state, and continuation level.")
showCenteredText = input.bool(true, "Show Centered Pocket Badge", group = G_VISUAL,
     tooltip = "Places a centered badge inside the correction pocket for premium first-glance readability.")
pocketBadgeAnchor = input.float(0.50, "Pocket Badge Anchor", minval = 0.25, maxval = 0.80, step = 0.05, group = G_VISUAL,
     tooltip = "Controls where the centered balance-pocket badge sits between the impulse end and the projected right edge.")
showBarColors = input.bool(false, "Color Bars by Balance State", group = G_VISUAL,
     tooltip = "Optionally colors bars by the current impulse-correction balance state.")
projectionBars = input.int(44, "Projection Bars", minval = 10, maxval = 180, group = G_VISUAL,
     tooltip = "Controls how far the correction pocket, rails, and right-side tags project to the right.")
labelCooldownBars = input.int(50, "Event Label Cooldown", minval = 1, maxval = 100, group = G_VISUAL,
     tooltip = "Minimum spacing between event labels so the chart remains readable.")
maxEventLabels = input.int(8, "Maximum Event Labels", minval = 4, maxval = 80, group = G_VISUAL,
     tooltip = "Caps the number of historical event labels for performance and visual clarity.")
labelOffsetAtr = input.float(1.05, "Label Offset ATR", minval = 0.15, maxval = 4.0, step = 0.05, group = G_VISUAL,
     tooltip = "Moves labels away from candles so they remain readable and do not feel buried in price.")
minEventDepth = input.float(12.0, "Minimum Depth for Healthy Label %", minval = 0.0, maxval = 50.0, step = 0.5, group = G_VISUAL,
     tooltip = "Prevents tiny early corrections from printing repeated healthy-correction labels that add clutter.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_VISUAL,
     tooltip = "Controls the font size used by event labels, centered pocket labels, and right-side tags.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro impulse-correction panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = G_PANEL,
     tooltip = "Controls where the panel appears on the chart.")
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Slate", "Light"], group = G_PANEL,
     tooltip = "Switches the panel between a dark AGPro surface, a slate variant, and a clean light surface.")
panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_PANEL,
     tooltip = "Controls text size inside the panel.")

alertHealthyCorrection = input.bool(true, "Alert: Healthy Correction", group = G_ALERTS,
     tooltip = "Triggers when the active correction stays inside the healthy correction area.")
alertDeepCorrection = input.bool(true, "Alert: Deep Correction Risk", group = G_ALERTS,
     tooltip = "Triggers when correction depth moves into the deep-correction risk area.")
alertContinuation = input.bool(true, "Alert: Continuation Trigger", group = G_ALERTS,
     tooltip = "Triggers when price breaks beyond the impulse end in the impulse direction.")
alertFailure = input.bool(true, "Alert: Correction Failure", group = G_ALERTS,
     tooltip = "Triggers when correction invalidates the impulse start area.")

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_clamp(value, minValue, maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_text_on(color bgColor) =>
    float bright = (color.r(bgColor) * 299.0 + color.g(bgColor) * 587.0 + color.b(bgColor) * 114.0) / 1000.0
    bright >= 145.0 ? darkText : headerText

f_size(value) =>
    result = size.normal
    if value == "Tiny"
        result := size.tiny
    else if value == "Small"
        result := size.small
    else if value == "Large"
        result := size.large
    else if value == "Huge"
        result := size.huge
    result

f_panel_pos(value) =>
    result = position.top_right
    if value == "Top Left"
        result := position.top_left
    else if value == "Top Center"
        result := position.top_center
    else if value == "Middle Right"
        result := position.middle_right
    else if value == "Middle Left"
        result := position.middle_left
    else if value == "Middle Center"
        result := position.middle_center
    else if value == "Bottom Right"
        result := position.bottom_right
    else if value == "Bottom Left"
        result := position.bottom_left
    else if value == "Bottom Center"
        result := position.bottom_center
    result

f_fmt(value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_score(value) =>
    na(value) ? "n/a" : str.tostring(int(math.round(value)))

f_pct(value) =>
    na(value) ? "n/a" : str.tostring(value, "#.0") + "%"

f_price(value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_dir_text(direction) =>
    direction > 0 ? "BULLISH" : direction < 0 ? "BEARISH" : "WAITING"

f_keep_label(store, newLabel, limit) =>
    array.push(store, newLabel)
    if array.size(store) > limit
        oldLabel = array.shift(store)
        label.delete(oldLabel)

f_set_box(bx, leftX, rightX, topY, bottomY, bg, border) =>
    box.set_lefttop(bx, leftX, topY)
    box.set_rightbottom(bx, rightX, bottomY)
    box.set_bgcolor(bx, bg)
    box.set_border_color(bx, border)
    box.set_border_width(bx, 1)

f_set_line(ln, leftX, rightX, yValue, lineColor, lineStyle) =>
    line.set_xy1(ln, leftX, yValue)
    line.set_xy2(ln, rightX, yValue)
    line.set_color(ln, lineColor)
    line.set_width(ln, 2)
    line.set_style(ln, lineStyle)

f_set_tag(tag, x, y, labelText, bg, styleValue, textSize) =>
    label.set_xy(tag, x, y)
    label.set_text(tag, labelText)
    label.set_color(tag, bg)
    label.set_textcolor(tag, f_text_on(bg))
    label.set_style(tag, styleValue)
    label.set_size(tag, textSize)

f_panel_cell(panelRef, col, row, txt, bg, txtColor, txtSize, alignValue) =>
    table.cell(panelRef, col, row, txt, bgcolor = bg, text_color = txtColor, text_size = txtSize, text_halign = alignValue)

// --------------------------------------------------
// Swing Impulse Engine
// --------------------------------------------------
atr = math.max(nz(ta.atr(atrLen), ta.tr(true)), syminfo.mintick)
labelOffset = atr * labelOffsetAtr
labelSize = f_size(labelSizeInput)
panelSize = f_size(panelSizeInput)

pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow = ta.pivotlow(low, pivotLen, pivotLen)
pivotHighBar = bar_index - pivotLen
pivotLowBar = bar_index - pivotLen

var int lastPivotType = 0
var float lastPivotPrice = na
var int lastPivotBar = na

var int impulseDir = 0
var float impulseStart = na
var float impulseEnd = na
var int impulseStartBar = na
var int impulseEndBar = na
var float correctionExtreme = na
var float impulseAtrRef = na
var bool newImpulse = false

newImpulse := false

if not na(pivotHigh)
    if lastPivotType == -1 and not na(lastPivotPrice)
        legSize = pivotHigh - lastPivotPrice
        if legSize >= atr * minImpulseAtr
            impulseDir := 1
            impulseStart := lastPivotPrice
            impulseEnd := pivotHigh
            impulseStartBar := lastPivotBar
            impulseEndBar := pivotHighBar
            correctionExtreme := pivotHigh
            impulseAtrRef := atr
            newImpulse := true
    lastPivotType := 1
    lastPivotPrice := pivotHigh
    lastPivotBar := pivotHighBar

if not na(pivotLow)
    if lastPivotType == 1 and not na(lastPivotPrice)
        legSize = lastPivotPrice - pivotLow
        if legSize >= atr * minImpulseAtr
            impulseDir := -1
            impulseStart := lastPivotPrice
            impulseEnd := pivotLow
            impulseStartBar := lastPivotBar
            impulseEndBar := pivotLowBar
            correctionExtreme := pivotLow
            impulseAtrRef := atr
            newImpulse := true
    lastPivotType := -1
    lastPivotPrice := pivotLow
    lastPivotBar := pivotLowBar

hasImpulse = impulseDir != 0 and not na(impulseStart) and not na(impulseEnd) and impulseStart != impulseEnd

if hasImpulse and not newImpulse
    correctionExtreme := impulseDir > 0 ? math.min(nz(correctionExtreme, low), low) : math.max(nz(correctionExtreme, high), high)

impulseRange = hasImpulse ? math.abs(impulseEnd - impulseStart) : na
depthRaw = hasImpulse and impulseRange > 0.0 ? impulseDir > 0 ? (impulseEnd - correctionExtreme) / impulseRange * 100.0 : (correctionExtreme - impulseEnd) / impulseRange * 100.0 : na
correctionDepth = hasImpulse ? f_clamp(depthRaw, 0.0, 150.0) : na
impulseAtrSize = hasImpulse ? impulseRange / math.max(nz(impulseAtrRef, atr), syminfo.mintick) : na

healthyLevel = hasImpulse ? impulseDir > 0 ? impulseEnd - impulseRange * healthyMax / 100.0 : impulseEnd + impulseRange * healthyMax / 100.0 : na
balanceLevel = hasImpulse ? impulseDir > 0 ? impulseEnd - impulseRange * balanceMax / 100.0 : impulseEnd + impulseRange * balanceMax / 100.0 : na
failureLevel = hasImpulse ? impulseDir > 0 ? impulseEnd - impulseRange * failureMax / 100.0 : impulseEnd + impulseRange * failureMax / 100.0 : na
continuationLevel = impulseEnd

continuationTrigger = hasImpulse and (impulseDir > 0 ? close > impulseEnd : close < impulseEnd)
correctionFailure = hasImpulse and (impulseDir > 0 ? low <= impulseStart : high >= impulseStart)
healthyCorrection = hasImpulse and not continuationTrigger and not correctionFailure and correctionDepth <= healthyMax
balancedCorrection = hasImpulse and not continuationTrigger and not correctionFailure and correctionDepth > healthyMax and correctionDepth <= balanceMax
deepCorrection = hasImpulse and not continuationTrigger and not correctionFailure and correctionDepth > balanceMax and correctionDepth <= failureMax

stateText = not hasImpulse ? "WAIT IMPULSE" : continuationTrigger ? "CONTINUATION" : correctionFailure ? "CORRECTION FAIL" : healthyCorrection ? "HEALTHY CORRECTION" : balancedCorrection ? "BALANCED PULLBACK" : deepCorrection ? "DEEP CORRECTION" : "HIGH FAILURE RISK"
stateColor = continuationTrigger ? bullColor : correctionFailure ? bearColor : healthyCorrection ? bullColor : balancedCorrection ? accentColor : deepCorrection ? neutralColor : hasImpulse ? bearColor : neutralColor
depthState = not hasImpulse ? "n/a" : f_pct(correctionDepth)
nextContext = not hasImpulse ? "Wait for swing leg" : continuationTrigger ? "Impulse extended" : correctionFailure ? "Start invalidated" : healthyCorrection ? "Watch continuation" : balancedCorrection ? "Balance zone" : deepCorrection ? "Defend impulse" : "Failure risk"
qualityScore = hasImpulse ? f_clamp(impulseAtrSize * 12.0 + (100.0 - math.min(correctionDepth, 100.0)) * 0.55, 0.0, 100.0) : na

// --------------------------------------------------
// Visual Objects
// --------------------------------------------------
var box impulseBox = box.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 90), border_color = accentColor)
var box correctionBox = box.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, bgcolor = color.new(neutralColor, 88), border_color = neutralColor)
var line healthyLine = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = bullColor, style = line.style_dotted, width = 2)
var line balanceLine = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = accentColor, style = line.style_dotted, width = 2)
var line failureLine = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = bearColor, style = line.style_dotted, width = 2)
var label pocketLabel = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_center, color = accentColor, textcolor = headerText, size = size.normal)
var label continuationTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = bullColor, textcolor = headerText, size = size.normal)
var label healthyTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = bullColor, textcolor = headerText, size = size.normal)
var label balanceTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = headerText, size = size.normal)
var label deepTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = neutralColor, textcolor = darkText, size = size.normal)

rightX = bar_index + projectionBars
visualLeft = hasImpulse ? impulseStartBar : bar_index
impulseTop = hasImpulse ? math.max(impulseStart, impulseEnd) : close
impulseBottom = hasImpulse ? math.min(impulseStart, impulseEnd) : close
pocketTop = hasImpulse ? math.max(healthyLevel, balanceLevel) : close
pocketBottom = hasImpulse ? math.min(healthyLevel, balanceLevel) : close
pocketMid = hasImpulse ? (pocketTop + pocketBottom) * 0.5 : close
pocketMidX = hasImpulse ? impulseEndBar + int(math.round((rightX - impulseEndBar) * pocketBadgeAnchor)) : bar_index

if barstate.islast and hasImpulse and showImpulseBox
    impulseColor = impulseDir > 0 ? bullColor : bearColor
    f_set_box(impulseBox, impulseStartBar, impulseEndBar, impulseTop, impulseBottom, color.new(impulseColor, 90), color.new(impulseColor, 20))
else if barstate.islast
    f_set_box(impulseBox, bar_index, bar_index + 1, close, close, color.new(accentColor, 100), color.new(accentColor, 100))

if barstate.islast and hasImpulse and showCorrectionPocket
    f_set_box(correctionBox, impulseEndBar, rightX, pocketTop, pocketBottom, color.new(accentColor, 86), color.new(accentColor, 10))
    if showCenteredText
        string pocketTxt = stateText + " | D " + depthState + " | Q " + f_score(qualityScore)
        f_set_tag(pocketLabel, pocketMidX, pocketMid, pocketTxt, stateColor, label.style_label_center, labelSize)
else if barstate.islast
    f_set_box(correctionBox, bar_index, bar_index + 1, close, close, color.new(accentColor, 100), color.new(accentColor, 100))
    label.set_text(pocketLabel, "")

if barstate.islast and hasImpulse and showDepthLadder
    f_set_line(healthyLine, impulseEndBar, rightX, healthyLevel, color.new(bullColor, 5), line.style_dotted)
    f_set_line(balanceLine, impulseEndBar, rightX, balanceLevel, color.new(accentColor, 5), line.style_dotted)
    f_set_line(failureLine, impulseEndBar, rightX, failureLevel, color.new(bearColor, 5), line.style_dotted)
else if barstate.islast
    f_set_line(healthyLine, bar_index, bar_index + 1, close, color.new(bullColor, 100), line.style_dotted)
    f_set_line(balanceLine, bar_index, bar_index + 1, close, color.new(accentColor, 100), line.style_dotted)
    f_set_line(failureLine, bar_index, bar_index + 1, close, color.new(bearColor, 100), line.style_dotted)

if barstate.islast and hasImpulse and showRightTags
    f_set_tag(continuationTag, rightX + 2, continuationLevel, "CONT " + f_price(continuationLevel), impulseDir > 0 ? bullColor : bearColor, label.style_label_left, labelSize)
    f_set_tag(healthyTag, rightX + 10, healthyLevel, "HEALTHY " + f_price(healthyLevel), bullColor, label.style_label_left, labelSize)
    f_set_tag(balanceTag, rightX + 18, balanceLevel, "BALANCE " + f_price(balanceLevel), accentColor, label.style_label_left, labelSize)
    f_set_tag(deepTag, rightX + 26, failureLevel, "DEEP " + f_price(failureLevel), neutralColor, label.style_label_left, labelSize)
else if barstate.islast
    label.set_text(continuationTag, "")
    label.set_text(healthyTag, "")
    label.set_text(balanceTag, "")
    label.set_text(deepTag, "")

// --------------------------------------------------
// Event Labels
// --------------------------------------------------
var array<label> eventLabels = array.new<label>()
var int lastEventBar = na
canPrintEvent = na(lastEventBar) or bar_index - lastEventBar >= labelCooldownBars
healthyEvent = barstate.isconfirmed and healthyCorrection and correctionDepth >= minEventDepth and not healthyCorrection[1]
deepEvent = barstate.isconfirmed and deepCorrection and not deepCorrection[1]
continuationEvent = barstate.isconfirmed and continuationTrigger and not continuationTrigger[1]
failureEvent = barstate.isconfirmed and correctionFailure and not correctionFailure[1]
eventCandidate = healthyEvent or deepEvent or continuationEvent or failureEvent
eventText = continuationEvent ? "CONT | Q " + f_score(qualityScore) : failureEvent ? "FAIL | Q " + f_score(qualityScore) : deepEvent ? "DEEP | " + depthState : "HEALTHY | " + depthState
eventColor = continuationEvent or healthyEvent ? bullColor : failureEvent ? bearColor : neutralColor
eventY = impulseDir > 0 ? low - labelOffset : high + labelOffset
eventStyle = impulseDir > 0 ? label.style_label_up : label.style_label_down

if showEventLabels and eventCandidate and canPrintEvent
    newEventLabel = label.new(bar_index, eventY, eventText, xloc = xloc.bar_index, style = eventStyle, textcolor = f_text_on(eventColor), color = eventColor, size = labelSize)
    f_keep_label(eventLabels, newEventLabel, maxEventLabels)
    lastEventBar := bar_index

barCol = continuationTrigger ? color.new(bullColor, 58) : correctionFailure ? color.new(bearColor, 58) : healthyCorrection ? color.new(bullColor, 72) : deepCorrection ? color.new(neutralColor, 68) : na
barcolor(showBarColors ? barCol : na)

// --------------------------------------------------
// Continuation Hit Rate (Proof Pass)
// --------------------------------------------------
// After a continuation trigger, wait proofWindowBars and check whether price is
// still beyond the impulse end in the impulse direction. Builds an honest,
// self-measured continuation rate.
var int contProofHits = 0
var int contProofTotal = 0
var bool contProofPending = false
var int contProofStart = na
var float contProofLevel = na
var int contProofDir = 0

if barstate.isconfirmed
    if continuationEvent and not contProofPending and not na(impulseEnd)
        contProofPending := true
        contProofStart := bar_index
        contProofLevel := impulseEnd
        contProofDir := impulseDir
    if contProofPending and not na(contProofStart) and bar_index - contProofStart >= proofWindowBars
        bool contHit = contProofDir > 0 ? close > contProofLevel : close < contProofLevel
        contProofTotal += 1
        if contHit
            contProofHits += 1
        contProofPending := false

float contProofRate = contProofTotal > 0 ? contProofHits / contProofTotal * 100.0 : na
string contRateText = contProofTotal > 0 ? str.tostring(int(math.round(contProofRate))) + "% (" + str.tostring(contProofHits) + "/" + str.tostring(contProofTotal) + ")" : "Building"
color contRateColor = contProofTotal == 0 ? neutralColor : contProofRate >= 60.0 ? bullColor : contProofRate >= 45.0 ? neutralColor : bearColor

// --------------------------------------------------
// Panel
// --------------------------------------------------
panelBgActive = panelThemeInput == "Light" ? color.rgb(248, 250, 252) : panelThemeInput == "Slate" ? color.rgb(30, 41, 59) : panelBg
panelBorderActive = panelThemeInput == "Light" ? color.rgb(203, 213, 225) : panelBorder
panelLabelActive = panelThemeInput == "Light" ? color.rgb(71, 85, 105) : panelLabelCol
panelValueActive = panelThemeInput == "Light" ? color.rgb(15, 23, 42) : panelValueCol

var table panel = na
var string panelPosMemory = ""
var string panelThemeMemory = ""

if showPanel and (na(panel) or panelPosMemory != panelPositionInput or panelThemeMemory != panelThemeInput)
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_pos(panelPositionInput), 2, 9, bgcolor = panelBgActive, border_color = panelBorderActive, border_width = 1)
    f_panel_cell(panel, 0, 0, "", headerBg, headerText, panelSize, text.align_center)
    f_panel_cell(panel, 1, 0, "", headerBg, headerText, panelSize, text.align_center)
    table.merge_cells(panel, 0, 0, 1, 0)
    panelPosMemory := panelPositionInput
    panelThemeMemory := panelThemeInput

if showPanel and not na(panel)
    f_panel_cell(panel, 0, 0, "AG Pro Impulse Correction Balance Map", headerBg, headerText, panelSize, text.align_center)
    f_panel_cell(panel, 0, 1, "Balance State", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 1, stateText, panelBgActive, stateColor, panelSize, text.align_center)
    f_panel_cell(panel, 0, 2, "Impulse Direction", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 2, f_dir_text(impulseDir), panelBgActive, impulseDir > 0 ? bullColor : impulseDir < 0 ? bearColor : panelValueActive, panelSize, text.align_center)
    f_panel_cell(panel, 0, 3, "Correction Depth", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 3, depthState, panelBgActive, stateColor, panelSize, text.align_center)
    f_panel_cell(panel, 0, 4, "Impulse Size", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 4, f_score(impulseAtrSize) + " ATR", panelBgActive, panelValueActive, panelSize, text.align_center)
    f_panel_cell(panel, 0, 5, "Quality Score", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 5, f_score(qualityScore), panelBgActive, panelValueActive, panelSize, text.align_center)
    f_panel_cell(panel, 0, 6, "Continuation Hit Rate", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 6, contRateText, panelBgActive, contRateColor, panelSize, text.align_center)
    f_panel_cell(panel, 0, 7, "Next Context", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 7, nextContext, panelBgActive, panelValueActive, panelSize, text.align_center)
    f_panel_cell(panel, 0, 8, "Timeframe", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 8, timeframe.period, panelBgActive, panelValueActive, panelSize, text.align_center)

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    panelPosMemory := ""
    panelThemeMemory := ""

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(alertHealthyCorrection and healthyEvent, "Healthy Correction", "Impulse Correction Balance Map: correction remains inside the healthy retracement area.")
alertcondition(alertDeepCorrection and deepEvent, "Deep Correction Risk", "Impulse Correction Balance Map: correction depth moved into the deep-correction risk area.")
alertcondition(alertContinuation and continuationEvent, "Continuation Trigger", "Impulse Correction Balance Map: price broke beyond the impulse end in the impulse direction.")
alertcondition(alertFailure and failureEvent, "Correction Failure", "Impulse Correction Balance Map: correction invalidated the impulse start area.")
````
