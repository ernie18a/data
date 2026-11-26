# Smart Money Displacement Ladder [AGPro Series]

- url: https://www.tradingview.com/script/dILbxJEI-Smart-Money-Displacement-Ladder-AGPro-Series/
- type: indicator
- pine_id: PUB;bfd7712b3f3f4c91bd2fb491bb606106
- version: 4.0

## Description

Smart Money Displacement Ladder [AGPro Series]

🧠 Core Idea

Is displacement strong, clean, and sustained enough to shift market context?


📌 Overview / What it does

Smart Money Displacement Ladder is a rule-based market-structure and price-action visualization tool designed to study strong directional displacement candles.

The script identifies clean bullish or bearish displacement, maps the imbalance shelf created by the candle, tracks ladder-style follow-through, and highlights whether the displacement is being sustained or failing.

It does not predict price direction, automate trades, or guarantee that displacement will continue. It is a structured decision-support map for displacement quality, imbalance shelf behavior, ladder continuation, and failure context.


🎯 Purpose & Design Philosophy

Many smart-money or imbalance tools mark a gap, a candle, or a generic continuation zone.

This script was built to answer a more complete question:

Did displacement actually change context, and is the market defending that displacement?

The design goal is to help traders read displacement as a progression: clean candle, shelf defense, ladder step, sustained pressure, or failure.


⚡ Why This Script Is Different

Most tools focus on single displacement candles, fair value gaps, or basic momentum signals.

This script does NOT treat every large candle as meaningful displacement.

Instead, it checks candle body, range, close location, optional volume participation, shelf defense, and ladder continuation. The focus is displacement quality and progression rather than simple candle marking.


⚙️ Methodology

1. Candle Quality Detection

The script evaluates candle body size, full range, and close strength relative to ATR.

2. Displacement Validation

A candle must satisfy directional and quality thresholds before it becomes the active displacement anchor.

3. Imbalance Shelf Mapping

After displacement forms, the script projects an imbalance shelf from the displacement candle.

4. Ladder Evaluation

Price extension beyond the active ladder level increases the ladder step count and strengthens the continuation context.

5. Visual Output

The chart displays the displacement box, imbalance shelf, ladder rails, centered shelf label, event labels, right-side tags, alerts, and a compact AG Pro decision panel.


🗺️ How to Read the Chart

Displacement Box = the active candle range that created the displacement anchor.

Imbalance Shelf = the projected shelf that should ideally remain defended after displacement.

Ladder Rail = the active extension level used to track follow-through.

Centered Shelf Label = the main visual anchor inside the active imbalance shelf.

Right-Side Tags = current displacement state, quality score, and shelf reference.

Event Labels = clean displacement, ladder continuation, or displacement failure labels.

Panel = summarizes displacement state, direction, quality score, ladder steps, shelf range, next context, and timeframe.


🚦 Signals & States

• CLEAN DISPLACEMENT → a directional candle meets displacement quality rules.

• FOLLOW-THROUGH → price extends beyond the active ladder level after displacement.

• LADDER STEP → a new continuation step is formed.

• SUSTAINED DISPLACEMENT → multiple ladder steps are active after the displacement anchor.

• DISPLACEMENT FAIL → price loses the imbalance shelf during the failure window.

• WAIT DISPLACEMENT → no valid displacement anchor is active yet.


🔔 Alerts Logic

Alerts trigger when a major displacement state appears.

• Clean Displacement → a clean directional displacement candle has formed.

• Displacement Ladder Continuation → price extended the active displacement ladder.

• Displacement Failure → price lost the active imbalance shelf after displacement.

Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The context becomes stronger when:

• Candle body is large relative to ATR
• Candle range expands cleanly
• Close location is strong in the displacement direction
• Relative volume supports participation
• The imbalance shelf remains defended
• Price forms additional ladder steps
• The panel state agrees with chart labels

If these elements do not align, the script avoids forcing a displacement continuation interpretation.


📊 When to Use

• Smart-money displacement studies
• Market-structure shift review
• Momentum expansion analysis
• Imbalance shelf tracking
• Trend continuation context
• Crypto, forex, stocks, and index markets
• 1H, 4H, and daily charts


⚠️ When NOT to Use

• Very low-liquidity symbols
• Extremely noisy markets with unreliable candle structure
• News spikes where displacement quality may be distorted
• Ultra-low timeframes with excessive wick noise
• Markets where large candles repeatedly fail without structure
• Situations where displacement should not be interpreted without broader context


🎛️ Key Inputs

• ATR Length → normalizes displacement size, shelf depth, and label spacing.

• Minimum Body ATR → controls how large the candle body must be before displacement qualifies.

• Minimum Range ATR → controls how much total candle expansion is required.

• Close Strength Threshold → controls how strong the candle close must be inside the range.

• Use Volume Confirmation → adds relative volume to quality scoring.

• Shelf Failure Window → controls how long shelf failure remains relevant after displacement.

• Imbalance Shelf ATR → controls shelf thickness.

• Projection Bars → controls how far shelves, rails, and tags project.

• Label Font Size → controls chart label and tag text size.

• Panel Font Size → controls panel text size.


🖥️ Interface & Visual Design

The visual hierarchy is built around the displacement progression.

The displacement box marks the anchor candle.

The shelf shows where displacement should ideally remain defended.

The ladder rail shows whether price is extending.

The centered badge keeps the active shelf readable at first glance.

The AG Pro panel summarizes the current displacement state without requiring the user to inspect every candle manually.


🧪 Practical Usage Workflow

1. Wait for a clean displacement candle.

2. Check the imbalance shelf created by that candle.

3. Watch whether price defends or loses the shelf.

4. Look for ladder steps after shelf defense.

5. Use the panel to confirm direction, quality, ladder count, and next context.

6. Interpret the output inside broader trend, liquidity, volatility, and structure context.


🔍 Interpretation Guidelines

Clean displacement does not guarantee continuation. It means the candle met the script's displacement quality rules.

A defended shelf does not guarantee trend expansion. It means price has not invalidated the displacement shelf during the active window.

A ladder step does not guarantee follow-through. It means price extended the active ladder reference.

A displacement failure is a structural warning, not a trading command.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not provide guaranteed entry or exit signals.

It is not a simple fair value gap marker.

It is not a full smart-money concept trading system.


⚠️ Limitations & Transparency

Displacement quality depends on ATR and candle structure.

Timeframe differences can change displacement visibility.

High volatility can create large candles that fail quickly.

Low-liquidity markets may create misleading candle expansion.

Shelf behavior should be interpreted within broader market structure.

The script is designed for structured interpretation, not certainty.


🧠 Market Context Notes

Displacement often matters most when it appears near important structure, after liquidity events, or during momentum expansion.

The same displacement candle can mean different things in a strong trend, a range, a liquidity sweep, or a news shock.

The script should be read together with volume, volatility, liquidity, and higher-timeframe context.


🧾 Use Case Examples

• If a bullish displacement candle forms and the shelf remains defended, the ladder may show follow-through context.

• If a bearish displacement candle forms and price quickly reclaims the shelf, the map may show displacement failure.

• If multiple ladder steps form after displacement, the script may classify the move as sustained displacement.


🧱 System Philosophy

Smart Money Displacement Ladder is part of the AGPro Series approach to decision-support tools:

clear structure, premium chart readability, honest interpretation, and no promise of certainty.

The goal is to help traders see whether displacement is being defended and extended, without turning every strong candle into a forced signal.


🔐 Non-Promise Statement

No script can know the future.

No displacement candle guarantees continuation.

No signal should be interpreted without broader market context.


📉 Risk Disclosure

Trading involves risk.

Markets can move unpredictably.

This script is for educational and analytical purposes only.

It does not provide financial advice or guaranteed trading outcomes.

Users remain responsible for their own decisions.


📚 Educational Note

Use this script to study how displacement develops after a strong candle.

The value is not only in the displacement label. The value is in learning whether the market defends the shelf, extends through ladder steps, or rejects the displacement context.

## Source Code

````pine
// --------------------------------------------------
// Smart Money Displacement Ladder [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Smart Money Displacement Ladder studies whether displacement is strong,
// clean, and sustained enough to shift market context. It maps displacement
// candles, ladder steps, imbalance shelves, continuation or failure labels,
// a 0-100 quality score, a persistent hold-rate proof layer, alerts, and an
// AG Pro panel for structure and momentum interpretation.
// --------------------------------------------------

//@version=6
indicator("Smart Money Displacement Ladder [AGPro Series]",
     shorttitle = "AGP SMDL",
     overlay = true,
     max_labels_count = 240,
     max_lines_count = 80,
     max_boxes_count = 60)

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
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
darkText = color.rgb(17, 24, 39)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
G_ENGINE = "Displacement Engine"
G_PROOF = "Confirm-Rate Proof"
G_VISUAL = "Visual Design"
G_PANEL = "Panel"
G_ALERTS = "Alerts"

atrLen = input.int(14, "ATR Length", minval = 5, maxval = 100, group = G_ENGINE,
     tooltip = "ATR normalizes displacement size, imbalance shelf depth, and label spacing across symbols.")
bodyAtrMin = input.float(0.85, "Minimum Body ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = G_ENGINE,
     tooltip = "Minimum candle body size, normalized by ATR, required before a candle can qualify as displacement.")
rangeAtrMin = input.float(1.20, "Minimum Range ATR", minval = 0.20, maxval = 6.00, step = 0.05, group = G_ENGINE,
     tooltip = "Minimum full candle range, normalized by ATR, required for displacement evaluation.")
closeStrengthMin = input.int(68, "Close Strength Threshold", minval = 50, maxval = 95, group = G_ENGINE,
     tooltip = "Minimum close location inside the candle range required to treat the candle as directional displacement.")
volumeConfirm = input.bool(true, "Use Volume Confirmation", group = G_ENGINE,
     tooltip = "Adds relative volume to displacement quality scoring when volume data is available.")
volumeLen = input.int(20, "Relative Volume Length", minval = 2, maxval = 200, group = G_ENGINE,
     tooltip = "Lookback used to compare current volume with recent activity.")
failureBars = input.int(12, "Shelf Failure Window", minval = 2, maxval = 80, group = G_ENGINE,
     tooltip = "Number of bars after displacement where losing the imbalance shelf is treated as displacement failure.")
shelfAtr = input.float(0.25, "Imbalance Shelf ATR", minval = 0.05, maxval = 1.50, step = 0.05, group = G_ENGINE,
     tooltip = "Thickness of the imbalance shelf projected from the displacement candle.")

proofWindow = input.int(12, "Proof Hold Window Bars", minval = 3, maxval = 120, group = G_PROOF,
     tooltip = "Bars a fresh displacement must hold its imbalance shelf, without losing it, to be counted as a held displacement in the Hold Rate proof statistic.")

showDisplacementBox = input.bool(true, "Show Displacement Box", group = G_VISUAL,
     tooltip = "Displays the active displacement candle range as the first ladder anchor.")
showImbalanceShelf = input.bool(true, "Show Imbalance Shelf", group = G_VISUAL,
     tooltip = "Displays the projected imbalance shelf created by the active displacement candle.")
showLadderSteps = input.bool(true, "Show Ladder Steps", group = G_VISUAL,
     tooltip = "Displays step rails showing whether displacement is extending or failing.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Prints compact labels for clean displacement, ladder continuation, and displacement failure.")
showCleanLabels = input.bool(false, "Show Clean Displacement Labels", group = G_VISUAL,
     tooltip = "Optionally prints clean-displacement labels. Disabled by default so shelf, ladder, and failure context remain visually dominant.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Displays compact right-side tags for displacement state, quality, and shelf level.")
showShelfTag = input.bool(false, "Show Right-Side Shelf Tag", group = G_VISUAL,
     tooltip = "Optionally shows a separate right-side shelf tag. Disabled by default because the centered shelf badge already names the shelf.")
showCenteredText = input.bool(true, "Show Centered Shelf Label", group = G_VISUAL,
     tooltip = "Places a centered badge inside the imbalance shelf for premium first-glance readability.")
showBarColors = input.bool(false, "Color Bars by Displacement State", group = G_VISUAL,
     tooltip = "Optionally colors bars by the current displacement ladder state.")
projectionBars = input.int(50, "Projection Bars", minval = 10, maxval = 180, group = G_VISUAL,
     tooltip = "Controls how far shelves, ladder rails, and right-side tags project to the right.")
adaptiveProjection = input.bool(true, "Adaptive HTF Projection", group = G_VISUAL,
     tooltip = "Shortens shelf, rail, and tag projection on daily, weekly, and monthly charts so screenshots remain balanced.")
shelfBadgeAnchor = input.float(0.50, "Shelf Badge Anchor", minval = 0.35, maxval = 0.85, step = 0.05, group = G_VISUAL,
     tooltip = "Controls the horizontal placement of the imbalance shelf badge. The default 0.50 keeps it centered inside the zone.")
labelCooldownBars = input.int(48, "Event Label Cooldown", minval = 1, maxval = 100, group = G_VISUAL,
     tooltip = "Minimum spacing between event labels so the chart remains readable.")
maxEventLabels = input.int(7, "Maximum Event Labels", minval = 4, maxval = 80, group = G_VISUAL,
     tooltip = "Caps historical event labels for performance and visual clarity.")
labelOffsetAtr = input.float(0.95, "Label Offset ATR", minval = 0.15, maxval = 4.0, step = 0.05, group = G_VISUAL,
     tooltip = "Moves labels away from candles so they remain readable and do not feel buried in price.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_VISUAL,
     tooltip = "Controls the font size used by event labels, shelf badges, and right-side tags.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro displacement ladder panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group = G_PANEL,
     tooltip = "Controls where the panel appears on the chart.")
panelThemeInput = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = G_PANEL,
     tooltip = "Switches the panel between premium AGPro surfaces and a clean light surface.")
panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_PANEL,
     tooltip = "Controls text size inside the panel.")

alertCleanDisplacement = input.bool(true, "Alert: Clean Displacement", group = G_ALERTS,
     tooltip = "Triggers when a candle qualifies as clean directional displacement.")
alertLadderStep = input.bool(true, "Alert: Ladder Continuation", group = G_ALERTS,
     tooltip = "Triggers when price extends beyond the active displacement ladder in the displacement direction.")
alertFailure = input.bool(true, "Alert: Displacement Failure", group = G_ALERTS,
     tooltip = "Triggers when price loses the active imbalance shelf after displacement.")

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_text_on(color bg) =>
    float bright = (color.r(bg) * 299 + color.g(bg) * 587 + color.b(bg) * 114) / 1000
    bright >= 145 ? darkText : headerText

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
        "Middle Right" => position.middle_right
        "Middle Center" => position.middle_center
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Center" => position.bottom_center
        "Bottom Left" => position.bottom_left
        => position.top_right

f_panel_bg(string theme) =>
    theme == "Clean Light" ? color.rgb(248, 250, 252) : theme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_border(string theme) =>
    theme == "Clean Light" ? color.rgb(203, 213, 225) : panelBorder

f_panel_label(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_fmt(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_score(float value) =>
    na(value) ? "n/a" : str.tostring(int(math.round(value)))

f_dir_text(int direction) =>
    direction > 0 ? "BULLISH" : direction < 0 ? "BEARISH" : "WAITING"

f_keep_label(array<label> store, label newLabel, int limit) =>
    array.push(store, newLabel)
    if array.size(store) > limit
        label oldLabel = array.shift(store)
        label.delete(oldLabel)

f_set_box(box bx, int leftX, int rightX, float topY, float bottomY, color bg, color border) =>
    box.set_lefttop(bx, leftX, topY)
    box.set_rightbottom(bx, rightX, bottomY)
    box.set_bgcolor(bx, bg)
    box.set_border_color(bx, border)
    box.set_border_width(bx, 1)

f_set_line(line ln, int leftX, int rightX, float yValue, color lineColor, lineStyle) =>
    line.set_xy1(ln, leftX, yValue)
    line.set_xy2(ln, rightX, yValue)
    line.set_color(ln, lineColor)
    line.set_width(ln, 2)
    line.set_style(ln, lineStyle)

f_set_tag(label tag, int x, float y, string labelText, color bg, styleValue, textSize) =>
    label.set_xy(tag, x, y)
    label.set_text(tag, labelText)
    label.set_color(tag, bg)
    label.set_textcolor(tag, f_text_on(bg))
    label.set_style(tag, styleValue)
    label.set_size(tag, textSize)

f_panel_cell(table panelRef, int col, int row, string txt, color bg, color txtColor, txtSize, alignValue) =>
    table.cell(panelRef, col, row, txt, bgcolor = bg, text_color = txtColor, text_size = txtSize, text_halign = alignValue)

// --------------------------------------------------
// Displacement Engine
// --------------------------------------------------
atr = math.max(nz(ta.atr(atrLen), high - low), syminfo.mintick)
labelOffset = atr * labelOffsetAtr
labelSize = f_size(labelSizeInput)
panelSize = f_size(panelSizeInput)
visualProjectionBars = adaptiveProjection ? timeframe.ismonthly ? math.min(projectionBars, 10) : timeframe.isweekly ? math.min(projectionBars, 18) : timeframe.isdaily ? math.min(projectionBars, 32) : projectionBars : projectionBars
volBase = ta.sma(volume, volumeLen)
relVol = not na(volBase) and volBase > 0.0 ? volume / volBase : 1.0
volBoost = volumeConfirm ? f_clamp(relVol, 0.6, 2.2) : 1.0

barRange = math.max(high - low, syminfo.mintick)
bodySize = math.abs(close - open)
bodyAtr = bodySize / atr
rangeAtr = barRange / atr
closeLocation = (close - low) / barRange * 100.0
bullCloseStrength = closeLocation
bearCloseStrength = 100.0 - closeLocation

bullDisplacement = close > open and bodyAtr >= bodyAtrMin and rangeAtr >= rangeAtrMin and bullCloseStrength >= closeStrengthMin
bearDisplacement = close < open and bodyAtr >= bodyAtrMin and rangeAtr >= rangeAtrMin and bearCloseStrength >= closeStrengthMin
newDisplacement = barstate.isconfirmed and (bullDisplacement or bearDisplacement)

var int dispDir = 0
var float dispHigh = na
var float dispLow = na
var float shelfTop = na
var float shelfBottom = na
var float ladderLevel = na
var int dispBar = na
var bool shelfFailedMemory = false
var int ladderCount = 0
var float displacementBaseQuality = na

if newDisplacement
    dispDir := bullDisplacement ? 1 : -1
    dispHigh := high
    dispLow := low
    dispBar := bar_index
    shelfFailedMemory := false
    ladderCount := 1
    displacementBaseQuality := f_clamp(bodyAtr * 18.0 + rangeAtr * 10.0 + (dispDir > 0 ? bullCloseStrength : bearCloseStrength) * 0.35 + volBoost * 8.0, 0.0, 100.0)
    if dispDir > 0
        shelfTop := math.min(close, high - atr * shelfAtr)
        shelfBottom := math.max(open, low + atr * shelfAtr)
        ladderLevel := high
    else
        shelfTop := math.min(open, high - atr * shelfAtr)
        shelfBottom := math.max(close, low + atr * shelfAtr)
        ladderLevel := low

hasDisplacement = dispDir != 0 and not na(dispBar) and not na(shelfTop) and not na(shelfBottom)
barsSinceDisp = hasDisplacement ? bar_index - dispBar : na
shelfMid = hasDisplacement ? (shelfTop + shelfBottom) * 0.5 : na
shelfLost = hasDisplacement and barsSinceDisp <= failureBars and (dispDir > 0 ? close < shelfBottom : close > shelfTop)
ladderStep = hasDisplacement and not shelfFailedMemory and (dispDir > 0 ? close > ladderLevel : close < ladderLevel)
failEvent = barstate.isconfirmed and shelfLost and not shelfFailedMemory

if shelfLost
    shelfFailedMemory := true

if ladderStep
    ladderLevel := close
    ladderCount += 1

qualityScore = hasDisplacement and not na(displacementBaseQuality) ? f_clamp(displacementBaseQuality + ladderCount * 4.0 - (shelfFailedMemory ? 25.0 : 0.0), 0.0, 100.0) : na

stateText = not hasDisplacement ? "WAIT DISPLACEMENT" : shelfFailedMemory ? "DISPLACEMENT FAIL" : ladderStep ? "LADDER STEP" : ladderCount >= 3 ? "SUSTAINED DISPLACEMENT" : ladderCount == 2 ? "FOLLOW-THROUGH" : "CLEAN DISPLACEMENT"
stateColor = shelfFailedMemory ? bearColor : dispDir > 0 ? bullColor : dispDir < 0 ? bearColor : neutralColor
nextContext = not hasDisplacement ? "Wait clean candle" : shelfFailedMemory ? "Shelf lost" : ladderCount >= 3 ? "Trend pressure active" : ladderCount == 2 ? "Watch next step" : "Defend shelf"
shelfText = hasDisplacement ? f_fmt(shelfBottom) + " / " + f_fmt(shelfTop) : "n/a"

// --------------------------------------------------
// Hold-Rate Proof
// On a fresh displacement, a win is recorded when the imbalance shelf is held
// through the proof window; losing the shelf inside the window is a non-hold.
// --------------------------------------------------
var bool proofPending = false
var int proofDir = 0
var float proofShelfTop = na
var float proofShelfBottom = na
var int proofStartBar = na
var int proofTotal = 0
var int proofWin = 0

if newDisplacement
    proofPending := true
    proofDir := dispDir
    proofShelfTop := shelfTop
    proofShelfBottom := shelfBottom
    proofStartBar := bar_index

if proofPending and barstate.isconfirmed and bar_index > proofStartBar
    bool pLost = proofDir > 0 ? close < proofShelfBottom : close > proofShelfTop
    bool pHeld = bar_index - proofStartBar >= proofWindow
    if pLost
        proofTotal += 1
        proofPending := false
    else if pHeld
        proofTotal += 1
        proofWin += 1
        proofPending := false

float holdRate = proofTotal > 0 ? 100.0 * proofWin / proofTotal : na
holdRateText = na(holdRate) ? "Building" : str.tostring(math.round(holdRate)) + "% (" + str.tostring(proofTotal) + ")"
holdRateColor = na(holdRate) ? f_panel_value(panelThemeInput) : holdRate >= 55.0 ? bullColor : holdRate >= 40.0 ? neutralColor : bearColor

// --------------------------------------------------
// Visual Objects
// --------------------------------------------------
var box dispBox = box.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 90), border_color = accentColor)
var box shelfBox = box.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 88), border_color = accentColor)
var line ladderRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = accentColor, style = line.style_dotted, width = 2)
var line shelfMidRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = neutralColor, style = line.style_dotted, width = 2)
var label shelfCenter = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_center, color = accentColor, textcolor = headerText, size = size.normal)
var label stateTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = headerText, size = size.normal)
var label qualityTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = headerText, size = size.normal)
var label shelfTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = neutralColor, textcolor = headerText, size = size.normal)

rightX = bar_index + visualProjectionBars
leftX = hasDisplacement ? dispBar : bar_index
shelfLabelX = hasDisplacement ? int(math.round(leftX + (rightX - leftX) * shelfBadgeAnchor)) : bar_index
dispTop = hasDisplacement ? math.max(dispHigh, dispLow) : close
dispBottom = hasDisplacement ? math.min(dispHigh, dispLow) : close

if barstate.islast and hasDisplacement and showDisplacementBox
    f_set_box(dispBox, dispBar, dispBar + 1, dispTop, dispBottom, color.new(stateColor, 88), color.new(stateColor, 18))
else if barstate.islast
    f_set_box(dispBox, bar_index, bar_index + 1, close, close, color.new(accentColor, 100), color.new(accentColor, 100))

if barstate.islast and hasDisplacement and showImbalanceShelf
    shelfColor = shelfFailedMemory ? bearColor : accentColor
    f_set_box(shelfBox, dispBar, rightX, shelfTop, shelfBottom, color.new(shelfColor, 86), color.new(shelfColor, 10))
    if showCenteredText
        f_set_tag(shelfCenter, shelfLabelX, shelfMid, "SHELF | Q " + f_score(qualityScore), color.new(shelfColor, 0), label.style_label_center, labelSize)
    else
        label.set_text(shelfCenter, "")
else if barstate.islast
    f_set_box(shelfBox, bar_index, bar_index + 1, close, close, color.new(accentColor, 100), color.new(accentColor, 100))
    label.set_text(shelfCenter, "")

if barstate.islast and hasDisplacement and showLadderSteps
    f_set_line(ladderRail, dispBar, rightX, ladderLevel, color.new(stateColor, 0), line.style_dotted)
    f_set_line(shelfMidRail, dispBar, rightX, shelfMid, color.new(neutralColor, 10), line.style_dotted)
else if barstate.islast
    f_set_line(ladderRail, bar_index, bar_index + 1, close, color.new(accentColor, 100), line.style_dotted)
    f_set_line(shelfMidRail, bar_index, bar_index + 1, close, color.new(neutralColor, 100), line.style_dotted)

if barstate.islast and hasDisplacement and showRightTags
    tagOffset = atr * 0.80
    stateTagX = rightX + 6
    qualityTagX = rightX + 6
    shelfTagX = rightX - 4
    f_set_tag(stateTag, stateTagX, close, stateText, stateColor, label.style_label_left, labelSize)
    f_set_tag(qualityTag, qualityTagX, ladderLevel + (dispDir > 0 ? tagOffset : -tagOffset), "QUALITY " + f_score(qualityScore), accentColor, label.style_label_left, labelSize)
    if showShelfTag
        f_set_tag(shelfTag, shelfTagX, shelfMid, "SHELF", accentColor, label.style_label_left, labelSize)
    else
        label.set_text(shelfTag, "")
else if barstate.islast
    label.set_text(stateTag, "")
    label.set_text(qualityTag, "")
    label.set_text(shelfTag, "")

// --------------------------------------------------
// Event Labels
// --------------------------------------------------
var array<label> eventLabels = array.new<label>()
var int lastEventBar = na
canPrintEvent = na(lastEventBar) or bar_index - lastEventBar >= labelCooldownBars
cleanEvent = showCleanLabels and newDisplacement
stepEvent = barstate.isconfirmed and ladderStep and not newDisplacement
eventCandidate = cleanEvent or stepEvent or failEvent
eventPrefix = failEvent ? (dispDir > 0 ? "BULL FAIL" : "BEAR FAIL") : stepEvent ? (dispDir > 0 ? "BULL STEP" : "BEAR STEP") : (dispDir > 0 ? "BULL DISP" : "BEAR DISP")
eventText = eventPrefix + " | Q " + f_score(qualityScore)
eventColor = failEvent ? bearColor : stateColor
eventY = dispDir > 0 ? high + labelOffset : low - labelOffset
eventStyle = dispDir > 0 ? label.style_label_down : label.style_label_up

if showEventLabels and eventCandidate and canPrintEvent
    newEventLabel = label.new(bar_index, eventY, eventText, xloc = xloc.bar_index, style = eventStyle, textcolor = f_text_on(eventColor), color = eventColor, size = labelSize)
    f_keep_label(eventLabels, newEventLabel, maxEventLabels)
    lastEventBar := bar_index

barCol = shelfFailedMemory ? color.new(bearColor, 58) : hasDisplacement ? color.new(stateColor, 72) : na
barcolor(showBarColors ? barCol : na)

// --------------------------------------------------
// Panel
// --------------------------------------------------
panelBgActive = f_panel_bg(panelThemeInput)
panelBorderActive = f_panel_border(panelThemeInput)
panelLabelActive = f_panel_label(panelThemeInput)
panelValueActive = f_panel_value(panelThemeInput)
qualityColor = na(qualityScore) ? panelValueActive : qualityScore >= 75.0 ? bullColor : qualityScore >= 50.0 ? neutralColor : bearColor

var table panel = na
var string panelThemeMemory = ""

if showPanel and (na(panel) or panelThemeMemory != panelThemeInput)
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_pos(panelPositionInput), 2, 8, bgcolor = panelBgActive, border_color = panelBorderActive, border_width = 1)
    panelThemeMemory := panelThemeInput

if showPanel and not na(panel)
    table.set_position(panel, f_panel_pos(panelPositionInput))
    table.clear(panel, 0, 0, 1, 7)
    f_panel_cell(panel, 0, 0, "AG Pro Smart Money Displacement Ladder", headerBg, headerText, panelSize, text.align_center)
    f_panel_cell(panel, 1, 0, "", headerBg, headerText, panelSize, text.align_center)
    table.merge_cells(panel, 0, 0, 1, 0)
    f_panel_cell(panel, 0, 1, "Displacement State", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 1, stateText, panelBgActive, stateColor, panelSize, text.align_center)
    f_panel_cell(panel, 0, 2, "Direction", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 2, f_dir_text(dispDir), panelBgActive, stateColor, panelSize, text.align_center)
    f_panel_cell(panel, 0, 3, "Quality Score", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 3, f_score(qualityScore), panelBgActive, qualityColor, panelSize, text.align_center)
    f_panel_cell(panel, 0, 4, "Ladder Steps", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 4, str.tostring(ladderCount), panelBgActive, panelValueActive, panelSize, text.align_center)
    f_panel_cell(panel, 0, 5, "Shelf Range", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 5, shelfText, panelBgActive, panelValueActive, panelSize, text.align_center)
    f_panel_cell(panel, 0, 6, "Next Context", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 6, nextContext, panelBgActive, panelValueActive, panelSize, text.align_center)
    f_panel_cell(panel, 0, 7, "Hold Rate", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 7, holdRateText, panelBgActive, holdRateColor, panelSize, text.align_center)

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    panelThemeMemory := ""

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(alertCleanDisplacement and cleanEvent, "Clean Displacement", "Smart Money Displacement Ladder: a clean directional displacement candle has formed.")
alertcondition(alertLadderStep and stepEvent, "Displacement Ladder Continuation", "Smart Money Displacement Ladder: price extended the active displacement ladder.")
alertcondition(alertFailure and failEvent, "Displacement Failure", "Smart Money Displacement Ladder: price lost the active imbalance shelf after displacement.")
````
