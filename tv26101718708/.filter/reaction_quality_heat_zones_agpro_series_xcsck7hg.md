# Reaction Quality Heat Zones [AGPro Series]

- url: https://www.tradingview.com/script/xcsck7hG-Reaction-Quality-Heat-Zones-AGPro-Series/
- type: indicator
- pine_id: PUB;3764c2d266f043d1aaf5124977e95415
- version: 4.0

## Description

Reaction Quality Heat Zones [AGPro Series]

🧠 Core Idea

Is price reacting with clean quality, or is the zone only producing weak noise and failure pressure?


📌 Overview / What it does

Reaction Quality Heat Zones [AGPro Series] is a premium TradingView overlay that evaluates the quality of price reactions around a live reference zone. It studies wick rejection, close location, participation, follow-through, and failed-reaction pressure to determine whether the current reaction area deserves attention.

The script produces a forward-projected heat zone, centered zone label, compact event labels, right-side state tags, and an AGPro-style panel. It is designed to show whether a reaction is clean, weak, absorbing pressure, failing, or producing follow-through.

It does not predict price direction, automate trading, or provide guaranteed entries. It is a visual context tool for reading reaction quality.


🎯 Purpose & Design Philosophy

This script was built because many traders can see a reaction after it happens, but struggle to judge the quality of that reaction in real time.

Reaction Quality Heat Zones helps traders evaluate whether a level, area, or market response is actually meaningful, or whether price is only producing low-quality movement around noise.

The mindset is quality-first: not every bounce, rejection, or reaction deserves the same weight.


⚡ Why This Script Is Different

Most tools mark support, resistance, or candle reactions as isolated events.

This script does NOT treat every wick or bounce as equally important.

Instead, it evaluates reaction quality as a combined structure: wick quality, close behavior, participation, follow-through, and failure pressure are all interpreted together.


⚙️ Methodology

1. Context Detection

The script identifies the dominant reaction side by comparing bullish and bearish reaction quality.

2. Reference Mapping

It builds a heat zone around the most relevant recent reaction boundary.

3. Reaction Evaluation

It scores the zone using wick rejection, close quality, participation, follow-through, and distance from the reaction boundary.

4. Visual Output

It displays a projected heat zone, event labels, state tags, and a structured panel.


🗺️ How to Read the Chart

Zones represent areas where reaction quality is being evaluated.

The centered zone label shows the active reaction heat score.

Labels mark clean reactions, weak reactions, absorption risk, failed reactions, and follow-through events.

Colors represent state context:

• Green = clean or follow-through reaction
• Pink = failed reaction pressure
• Yellow = absorption risk
• Indigo = weak or building reaction

The panel summarizes reaction state, direction, heat score, failure pressure, wick quality, follow-through, and next context.


🚦 Signals & States

• CLEAN REACTION → reaction quality is strong and failure pressure is controlled

• FOLLOW-THROUGH → reaction quality is strong and continuation is visible

• WEAK REACTION → reaction quality is not strong enough yet

• ABSORPTION RISK → quality exists, but failure pressure is also elevated

• FAILED REACTION → failure pressure dominates the reaction area

• REACTION BUILD → no decisive reaction state is confirmed


🔔 Alerts Logic

Alerts trigger when a new clean reaction, follow-through reaction, failed reaction, absorption risk, or weak reaction is detected.

Alerts are attention markers only. They are not trade instructions.


🧩 Confluence Logic

The strongest reaction context appears when wick rejection, close quality, participation, and follow-through align.

The weakest reaction context appears when reaction quality is low and failure pressure increases.


📊 When to Use

• Support and resistance reactions

• Breakout retests

• Range boundary reactions

• Pullback reaction checks

• Intraday and swing market-structure review


⚠️ When NOT to Use

• Very low-liquidity symbols

• Random chop without clear reaction areas

• News-driven spikes

• Charts where spreads or data quality distort candles


🎛️ Key Inputs

• Reaction Lookback → controls the recent window used to build the heat zone

• Follow-Through Length → controls continuation evaluation after reaction

• Heat Threshold → defines how strong a reaction must be to qualify

• Failure Threshold → defines when failure pressure becomes important

• Zone Projection Bars → keeps all zone edges visible for publication screenshots

• Panel and label settings → control readability and layout


🖥️ Interface & Visual Design

The interface is built for fast visual interpretation.

The heat zone carries the main story, while the panel provides structured confirmation. Right-side tags keep the current state readable without burying the candles.

The visual design is intentionally premium, compact, and publication-ready.


🧪 Practical Usage Workflow

1. Read the panel state.

2. Check the active heat zone.

3. Compare heat score with failure pressure.

4. Look for clean reaction or follow-through confirmation.

5. Interpret the result within broader market structure.


🔍 Interpretation Guidelines

High heat with controlled failure pressure suggests a cleaner reaction.

High heat with high failure pressure suggests absorption risk.

Low heat suggests the reaction may not be meaningful yet.

Failed reaction pressure does not guarantee reversal. It shows that the reaction area is losing quality.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an automated trading system.

It does not provide guaranteed buy or sell signals.

It does not replace risk management.


⚠️ Limitations & Transparency

Reaction quality can change quickly.

Different timeframes may show different reaction behavior.

Volatility, liquidity, market sessions, and sudden news can affect how zones behave.

Outputs should always be interpreted with broader market context.


🧠 Market Context Notes

A good reaction is not only a wick.

It also needs close quality, participation, and follow-through. This script is designed to make that difference visible.


🧾 Use Case Examples

When price reacts from a zone with strong wick quality, strong close behavior, and follow-through, the heat score can confirm a cleaner reaction.

When price reacts but failure pressure rises, the zone may be vulnerable.

When price stays inside the zone without quality, the script may show weak reaction or reaction build context.


🧱 System Philosophy

AGPro Series scripts are designed to make complex market context easier to read without reducing the market to simplistic signals.

This script follows that philosophy by focusing on reaction quality instead of generic support or resistance marks.


🔐 Non-Promise Statement

No script can guarantee future price movement.

This tool provides structured context, not certainty.


📉 Risk Disclosure

Trading involves risk.

Users remain responsible for their own decisions, position sizing, and risk management.

This script does not provide financial advice or guaranteed trading outcomes.


📚 Educational Note

Use this script to study how price reacts around important areas and to compare clean reactions with weak or failed reactions across different market conditions.

## Source Code

````pine
// ─────────────────────────────────────────────────
// Reaction Quality Heat Zones [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4.0
//
// Reaction Quality Heat Zones maps how strong, clean, and tradable a price
// reaction is around a reference area. It combines wick rejection, close quality,
// participation, follow-through, and failed-reaction pressure into a premium
// TradingView heat-zone decision overlay. A zone-owned evidence map keeps the
// active state, proof context, and historical reactions visually distinct.
// ─────────────────────────────────────────────────

//@version=6
indicator("Reaction Quality Heat Zones [AGPro Series]",
     shorttitle = "AG Pro RQZ",
     overlay = true,
     max_labels_count = 60,
     max_boxes_count = 6,
     max_lines_count = 8)

// ─────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────
grpCore = "Core Logic"
reactionLookback = input.int(28, "Reaction Lookback", minval = 8, maxval = 120, group = grpCore,
     tooltip = "Defines the recent window used to evaluate reaction strength and build the heat zone.")
followLength = input.int(8, "Follow-Through Length", minval = 3, maxval = 40, group = grpCore,
     tooltip = "Controls how many bars are used to evaluate whether a reaction produced continuation.")
heatThreshold = input.float(62.0, "Heat Threshold", minval = 40.0, maxval = 90.0, step = 1.0, group = grpCore,
     tooltip = "Higher values require stronger wick quality, close quality, participation, and follow-through before a zone is considered high quality.")
failureThreshold = input.float(58.0, "Failure Threshold", minval = 35.0, maxval = 85.0, step = 1.0, group = grpCore,
     tooltip = "Defines how much failed-reaction pressure is required before the script marks a weak or failed reaction state.")
eventCooldown = input.int(20, "Event Cooldown", minval = 3, maxval = 80, group = grpCore,
     tooltip = "Minimum bar spacing between historical reaction labels.")
proofWindow = input.int(8, "Follow-Through Proof Window", minval = 3, maxval = 40, group = grpCore,
     tooltip = "Bars observed after a clean reaction to measure real directional follow-through. Unresolved cases inside the window are left uncounted, never scored as a failure. Keep at or below Event Cooldown.")
proofGoalAtr = input.float(0.8, "Proof Goal (ATR)", minval = 0.2, maxval = 3.0, step = 0.1, group = grpCore,
     tooltip = "Directional distance from the reaction close that counts as confirmed follow-through.")
proofStopAtr = input.float(0.7, "Proof Invalidation (ATR)", minval = 0.2, maxval = 3.0, step = 0.1, group = grpCore,
     tooltip = "Adverse distance from the reaction close that invalidates follow-through before the goal is reached.")
proofMinSamples = input.int(6, "Proof Minimum Samples", minval = 3, maxval = 50, group = grpCore,
     tooltip = "Resolved clean reactions required before the follow-through rate is reported instead of a building state.")

grpVisual = "Visual Design"
showPanel = input.bool(true, "Show Panel", group = grpVisual,
     tooltip = "Shows or hides the AG Pro status panel. Enabled by default for publication screenshots.")
showZone = input.bool(true, "Show Heat Zone", group = grpVisual,
     tooltip = "Displays the active reaction-quality heat zone with a centered label.")
showZoneHalo = input.bool(true, "Show Zone Halo", group = grpVisual,
     tooltip = "Adds a subtle outer heat frame so the active reaction area remains visible without covering candles.")
showMidline = input.bool(true, "Show Zone Midline", group = grpVisual,
     tooltip = "Displays a dotted centerline inside the heat zone to make the reaction reference easier to read.")
showEventLabels = input.bool(true, "Show Event Labels", group = grpVisual,
     tooltip = "Shows confirmed historical reaction badges outside the active heat zone so current evidence remains unobstructed.")
showRightTags = input.bool(true, "Show Right Evidence", group = grpVisual,
     tooltip = "Shows the current heat, wick, and failure evidence stack projected to the right side of the chart.")
showBoundaryLines = input.bool(true, "Show Heat Boundaries", group = grpVisual,
     tooltip = "Displays the upper and lower heat-zone boundaries.")
zoneProjection = input.int(44, "Zone Projection Bars", minval = 12, maxval = 130, group = grpVisual,
     tooltip = "Projects the heat zone forward so all zone edges remain visible in publication screenshots.")
rightTagOffset = input.int(5, "Right Tag Offset", minval = 2, maxval = 40, group = grpVisual,
     tooltip = "Controls how far current state tags are placed to the right of the active heat zone.")
visibleBars = input.int(90, "Visible Zone Width", minval = 30, maxval = 260, group = grpVisual,
     tooltip = "Controls how much recent chart history the active heat zone covers.")
labelLimit = input.int(7, "Historical Label Limit", minval = 4, maxval = 24, group = grpVisual,
     tooltip = "Caps historical labels to maintain a premium, readable chart.")
panelPosition = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = grpVisual,
     tooltip = "Controls where the AG Pro panel is placed.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = grpVisual,
     tooltip = "Controls the panel color theme.")
labelFontInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpVisual,
     tooltip = "Controls the font size of chart labels and right-side tags.")
panelFontInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpVisual,
     tooltip = "Controls the font size of the information panel.")

// ─────────────────────────────────────────────────
// AGPro Color Palette
// ─────────────────────────────────────────────────
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBgDark   = color.rgb(15, 23, 42)
panelBorderDark = color.rgb(51, 65, 85)
panelLabelDark = color.rgb(148, 163, 184)
panelValueDark = color.rgb(226, 232, 240)
panelBgLight  = color.rgb(241, 245, 249)
panelBorderLight = color.rgb(148, 163, 184)
panelLabelLight = color.rgb(71, 85, 105)
panelValueLight = color.rgb(15, 23, 42)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)
heatBaseColor = color.rgb(116, 125, 255)
darkText      = color.rgb(17, 24, 39)

// ─────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────
f_size(sizeName) =>
    sizeName == "Tiny" ? size.tiny : sizeName == "Small" ? size.small : sizeName == "Large" ? size.large : sizeName == "Huge" ? size.huge : size.normal

f_panel_pos(posName) =>
    posName == "Top Left" ? position.top_left :
     posName == "Top Center" ? position.top_center :
     posName == "Middle Right" ? position.middle_right :
     posName == "Middle Left" ? position.middle_left :
     posName == "Middle Center" ? position.middle_center :
     posName == "Bottom Right" ? position.bottom_right :
     posName == "Bottom Left" ? position.bottom_left :
     posName == "Bottom Center" ? position.bottom_center : position.top_right

f_clamp(value, minValue, maxValue) =>
    math.max(minValue, math.min(value, maxValue))

f_round(value) =>
    int(math.round(value))

f_fmt(value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_dir_text(direction) =>
    direction > 0 ? "BULLISH" : direction < 0 ? "BEARISH" : "NEUTRAL"

// Luminance-aware contrast: dark text on light/amber/pink/indigo, light text on teal
f_text_on(bgColor) =>
    float r = color.r(bgColor)
    float g = color.g(bgColor)
    float b = color.b(bgColor)
    float brightness = r * 0.299 + g * 0.587 + b * 0.114
    brightness > 145.0 ? darkText : headerText

// Anti-collision registry for event labels
var int[] rqzLblBars = array.new_int()
var float[] rqzLblYs = array.new_float()

f_register(int b, float y) =>
    array.push(rqzLblBars, b)
    array.push(rqzLblYs, y)
    if array.size(rqzLblBars) > 30
        array.shift(rqzLblBars)
        array.shift(rqzLblYs)

f_resolve(int b, float y, int dirSign, float atrv) =>
    float sep = atrv * 1.10
    int barWin = 14
    float adj = y
    int guard = 0
    bool collide = true
    while collide and guard < 10
        collide := false
        int n = array.size(rqzLblBars)
        if n > 0
            for i = 0 to n - 1
                if math.abs(b - array.get(rqzLblBars, i)) <= barWin and math.abs(adj - array.get(rqzLblYs, i)) < sep
                    collide := true
        if collide
            adj := adj + dirSign * sep
        guard := guard + 1
    adj

f_set_box(boxRef, leftValue, rightValue, topValue, bottomValue, bg, border, borderWidth) =>
    box.set_left(boxRef, leftValue)
    box.set_right(boxRef, rightValue)
    box.set_top(boxRef, topValue)
    box.set_bottom(boxRef, bottomValue)
    box.set_bgcolor(boxRef, bg)
    box.set_border_color(boxRef, border)
    box.set_border_width(boxRef, borderWidth)

f_set_line(lineRef, x1, y1, x2, y2, col, styleValue, widthValue) =>
    line.set_xy1(lineRef, x1, y1)
    line.set_xy2(lineRef, x2, y2)
    line.set_color(lineRef, col)
    line.set_style(lineRef, styleValue)
    line.set_width(lineRef, widthValue)

f_set_tag(tag, x, y, labelText, bg, txtCol, styleValue, textSize) =>
    label.set_x(tag, x)
    label.set_y(tag, y)
    label.set_text(tag, labelText)
    label.set_color(tag, bg)
    label.set_textcolor(tag, txtCol)
    label.set_style(tag, styleValue)
    label.set_size(tag, textSize)

f_keep_label(store, newLabel, limit) =>
    array.push(store, newLabel)
    if array.size(store) > limit
        oldLabel = array.shift(store)
        label.delete(oldLabel)

f_panel_cell(panelRef, col, row, txt, bg, txtColor, txtSize) =>
    table.cell(panelRef, col, row, txt, bgcolor = bg, text_color = txtColor, text_size = txtSize, text_halign = text.align_center)

// ─────────────────────────────────────────────────
// Core Logic
// ─────────────────────────────────────────────────
labelSize = f_size(labelFontInput)
panelSize = f_size(panelFontInput)
panelPos = f_panel_pos(panelPosition)
panelBg = panelTheme == "Dark" ? panelBgDark : panelBgLight
panelBorder = panelTheme == "Dark" ? panelBorderDark : panelBorderLight
panelLabelCol = panelTheme == "Dark" ? panelLabelDark : panelLabelLight
panelValueCol = panelTheme == "Dark" ? panelValueDark : panelValueLight

atr = ta.atr(14)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
barRange = math.max(high - low, syminfo.mintick)
body = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
closeLocation = f_clamp((close - low) / barRange * 100.0, 0.0, 100.0)
bearCloseLocation = f_clamp((high - close) / barRange * 100.0, 0.0, 100.0)
bodyQuality = f_clamp(body / barRange * 100.0, 0.0, 100.0)

volBase = math.max(ta.sma(nz(volume, 1.0), reactionLookback), 1.0)
participation = f_clamp(nz(volume, 1.0) / volBase * 50.0, 0.0, 100.0)

bullReject = f_clamp(lowerWick / barRange * 100.0, 0.0, 100.0)
bearReject = f_clamp(upperWick / barRange * 100.0, 0.0, 100.0)
bullRawQuality = f_clamp(bullReject * 0.34 + closeLocation * 0.34 + participation * 0.16 + bodyQuality * 0.16, 0.0, 100.0)
bearRawQuality = f_clamp(bearReject * 0.34 + bearCloseLocation * 0.34 + participation * 0.16 + bodyQuality * 0.16, 0.0, 100.0)
dominantDir = bullRawQuality > bearRawQuality ? 1 : bearRawQuality > bullRawQuality ? -1 : 0
reactionQuality = math.max(bullRawQuality, bearRawQuality)

recentHigh = ta.highest(high, reactionLookback)
recentLow = ta.lowest(low, reactionLookback)
recentRange = math.max(recentHigh - recentLow, syminfo.mintick)
reactionBoundary = dominantDir > 0 ? recentLow : dominantDir < 0 ? recentHigh : (recentHigh + recentLow) * 0.5
distanceFromBoundary = math.abs(close - reactionBoundary)
boundaryDistanceScore = f_clamp(100.0 - distanceFromBoundary / safeAtr * 24.0, 0.0, 100.0)

followMove = close - close[followLength]
followDir = followMove > safeAtr * 0.30 ? 1 : followMove < -safeAtr * 0.30 ? -1 : 0
followQuality = dominantDir == 0 ? 0.0 : dominantDir == followDir ? f_clamp(math.abs(followMove) / safeAtr * 18.0 + 38.0, 0.0, 100.0) : f_clamp(42.0 - math.abs(followMove) / safeAtr * 10.0, 0.0, 100.0)
absorptionPressure = dominantDir > 0 ? f_clamp(bearReject * 0.55 + (100.0 - closeLocation) * 0.45, 0.0, 100.0) : dominantDir < 0 ? f_clamp(bullReject * 0.55 + (100.0 - bearCloseLocation) * 0.45, 0.0, 100.0) : 50.0
failurePressure = f_clamp(absorptionPressure * 0.40 + (100.0 - followQuality) * 0.34 + (100.0 - reactionQuality) * 0.26, 0.0, 100.0)
heatScore = f_clamp(reactionQuality * 0.42 + followQuality * 0.25 + participation * 0.18 + boundaryDistanceScore * 0.15, 0.0, 100.0)

cleanReaction = heatScore >= heatThreshold and failurePressure < failureThreshold
followThrough = heatScore >= heatThreshold and followQuality >= 62.0 and failurePressure < failureThreshold
weakReaction = heatScore < heatThreshold and failurePressure < failureThreshold
failedReaction = failurePressure >= failureThreshold and heatScore < heatThreshold
absorptionState = failurePressure >= failureThreshold and heatScore >= heatThreshold

reactionState = followThrough ? "FOLLOW-THROUGH" : cleanReaction ? "CLEAN REACTION" : absorptionState ? "ABSORPTION RISK" : failedReaction ? "FAILED REACTION" : weakReaction ? "WEAK REACTION" : "REACTION BUILD"
stateColor = followThrough ? bullColor : cleanReaction ? bullColor : absorptionState ? neutralColor : failedReaction ? bearColor : weakReaction ? accentColor : heatBaseColor
nextContext = followThrough ? "Track follow-through" : cleanReaction ? "Reaction clean" : absorptionState ? "Watch absorption" : failedReaction ? "Failure pressure" : weakReaction ? "Wait quality" : "Build reaction"

// ─────────────────────────────────────────────────
// Visual Objects
// ─────────────────────────────────────────────────
var box heatHalo = box.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, bgcolor = color.new(heatBaseColor, 100), border_color = heatBaseColor)
var box heatBox = box.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, bgcolor = color.new(heatBaseColor, 88), border_color = heatBaseColor)
var line upperLine = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = heatBaseColor, style = line.style_dotted, width = 2)
var line lowerLine = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = heatBaseColor, style = line.style_dotted, width = 2)
var line midLine = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = heatBaseColor, style = line.style_dotted, width = 1)
var label zoneTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_center, color = heatBaseColor, textcolor = color.white, size = size.normal)
var label stateTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = heatBaseColor, textcolor = color.white, size = size.normal)
var label heatTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = heatBaseColor, textcolor = color.white, size = size.normal)
var label failureTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = heatBaseColor, textcolor = color.white, size = size.normal)
var array<label> eventStore = array.new<label>()

leftX = math.max(bar_index - visibleBars, 0)
rightX = bar_index + zoneProjection
zoneHalf = math.max(safeAtr * 0.95, recentRange * 0.055)
zoneCenter = dominantDir > 0 ? reactionBoundary + zoneHalf * 0.75 : dominantDir < 0 ? reactionBoundary - zoneHalf * 0.75 : (recentHigh + recentLow) * 0.5
zoneTopRaw = zoneCenter + zoneHalf
zoneBottomRaw = zoneCenter - zoneHalf
zoneTop = math.max(zoneTopRaw, zoneBottomRaw + syminfo.mintick)
zoneBottom = math.min(zoneBottomRaw, zoneTopRaw - syminfo.mintick)
zoneMid = (zoneTop + zoneBottom) * 0.5
zoneLabelX = int(math.round((leftX + rightX) * 0.5))
rightTagX = rightX + rightTagOffset
tagGap = safeAtr * 1.15
wickQuality = dominantDir > 0 ? bullReject : bearReject
zoneText = reactionState + " | Q " + str.tostring(f_round(heatScore)) + "\n" + f_dir_text(dominantDir) + " REACTION ZONE"

if showZone
    if showZoneHalo
        f_set_box(heatHalo, leftX, rightX, zoneTop + safeAtr * 0.18, zoneBottom - safeAtr * 0.18, color.new(stateColor, 93), color.new(stateColor, 55), 1)
    else
        f_set_box(heatHalo, bar_index, bar_index + 1, close, close, color.new(color.black, 100), color.new(color.black, 100), 1)
    f_set_box(heatBox, leftX, rightX, zoneTop, zoneBottom, color.new(stateColor, 86), color.new(stateColor, 0), 2)
    f_set_tag(zoneTag, zoneLabelX, zoneMid, zoneText, stateColor, f_text_on(stateColor), label.style_label_center, labelSize)
else
    f_set_box(heatHalo, bar_index, bar_index + 1, close, close, color.new(color.black, 100), color.new(color.black, 100), 1)
    f_set_box(heatBox, bar_index, bar_index + 1, close, close, color.new(color.black, 100), color.new(color.black, 100), 1)
    label.set_text(zoneTag, "")

if showZone and showBoundaryLines
    f_set_line(upperLine, leftX, zoneTop, rightX, zoneTop, color.new(stateColor, 8), line.style_dotted, 2)
    f_set_line(lowerLine, leftX, zoneBottom, rightX, zoneBottom, color.new(stateColor, 8), line.style_dotted, 2)
else
    line.set_color(upperLine, color.new(color.black, 100))
    line.set_color(lowerLine, color.new(color.black, 100))

if showZone and showMidline
    f_set_line(midLine, leftX, zoneMid, rightX, zoneMid, color.new(stateColor, 18), line.style_dotted, 1)
else
    line.set_color(midLine, color.new(color.black, 100))

if showRightTags
    heatTagColor = heatScore >= heatThreshold ? bullColor : accentColor
    failTagColor = failurePressure >= failureThreshold ? bearColor : neutralColor
    f_set_tag(stateTag, rightTagX, zoneMid, "Wick Q " + str.tostring(f_round(wickQuality)), stateColor, f_text_on(stateColor), label.style_label_left, labelSize)
    f_set_tag(heatTag, rightTagX, zoneMid + tagGap, "Heat Q " + str.tostring(f_round(heatScore)), heatTagColor, f_text_on(heatTagColor), label.style_label_left, labelSize)
    f_set_tag(failureTag, rightTagX, zoneMid - tagGap, "Fail Q " + str.tostring(f_round(failurePressure)), failTagColor, f_text_on(failTagColor), label.style_label_left, labelSize)
else
    label.set_text(stateTag, "")
    label.set_text(heatTag, "")
    label.set_text(failureTag, "")

// ─────────────────────────────────────────────────
// Event Labels
// ─────────────────────────────────────────────────
newClean = barstate.isconfirmed and cleanReaction and not (cleanReaction[1] == true)
newFollow = barstate.isconfirmed and followThrough and not (followThrough[1] == true)
newFailed = barstate.isconfirmed and failedReaction and not (failedReaction[1] == true)
newAbsorption = barstate.isconfirmed and absorptionState and not (absorptionState[1] == true)
newWeak = barstate.isconfirmed and weakReaction and not (weakReaction[1] == true)
eventCandidate = newClean or newFollow or newFailed or newAbsorption or newWeak

var int lastEventBar = na
canPrintEvent = na(lastEventBar) or bar_index - lastEventBar >= eventCooldown
eventOutsideActiveZone = bar_index < last_bar_index - visibleBars
if showEventLabels and eventCandidate and canPrintEvent and eventOutsideActiveZone
    eventText = newFollow ? "Follow-Through" : newClean ? "Clean Reaction" : newFailed ? "Failed Reaction" : newAbsorption ? "Absorption Risk" : "Weak Reaction"
    eventCol = newFollow ? bullColor : newClean ? bullColor : newFailed ? bearColor : newAbsorption ? neutralColor : accentColor
    eventStyle = dominantDir >= 0 ? label.style_label_up : label.style_label_down
    eventBaseY = dominantDir >= 0 ? low - safeAtr * 0.95 : high + safeAtr * 0.95
    eventY = f_resolve(bar_index, eventBaseY, dominantDir >= 0 ? -1 : 1, safeAtr)
    eventScore = newFailed or newAbsorption ? failurePressure : heatScore
    eventLabel = label.new(bar_index, eventY, eventText + " | Q " + str.tostring(f_round(eventScore)), xloc = xloc.bar_index, style = eventStyle, color = eventCol, textcolor = f_text_on(eventCol), size = labelSize)
    f_register(bar_index, eventY)
    f_keep_label(eventStore, eventLabel, labelLimit)
    lastEventBar := bar_index

// ─────────────────────────────────────────────────
// Follow-Through Proof (stop-aware directional follow-through after a clean reaction)
// ─────────────────────────────────────────────────
var bool rqzPending = false
var int rqzDir = 0
var float rqzGoal = na
var float rqzStop = na
var int rqzExpiry = na
var int rqzStart = na
var int rqzWins = 0
var int rqzTotal = 0

if newClean and not rqzPending and dominantDir != 0
    rqzPending := true
    rqzDir := dominantDir
    rqzGoal := dominantDir > 0 ? close + safeAtr * proofGoalAtr : close - safeAtr * proofGoalAtr
    rqzStop := dominantDir > 0 ? close - safeAtr * proofStopAtr : close + safeAtr * proofStopAtr
    rqzExpiry := bar_index + proofWindow
    rqzStart := bar_index

if rqzPending and barstate.isconfirmed and not na(rqzStart) and bar_index > rqzStart
    bool rqWin = rqzDir > 0 ? high >= rqzGoal : low <= rqzGoal
    bool rqLoss = rqzDir > 0 ? low <= rqzStop : high >= rqzStop
    if rqWin
        rqzTotal += 1
        rqzWins += 1
        rqzPending := false
    else if rqLoss
        rqzTotal += 1
        rqzPending := false
    else if bar_index >= rqzExpiry
        rqzPending := false

float ftRate = rqzTotal > 0 ? rqzWins / rqzTotal * 100.0 : na
bool ftReady = rqzTotal >= proofMinSamples
string ftText = ftReady ? str.tostring(f_round(ftRate)) + "% (" + str.tostring(rqzTotal) + ")" : "Building (" + str.tostring(rqzTotal) + "/" + str.tostring(proofMinSamples) + ")"

// ─────────────────────────────────────────────────
// Panel
// ─────────────────────────────────────────────────
var table panel = na
var string panelPosMemory = ""
var string panelThemeMemory = ""

if showPanel and (na(panel) or panelPosMemory != panelPosition or panelThemeMemory != panelTheme)
    if not na(panel)
        table.delete(panel)
    panel := table.new(panelPos, 2, 8, border_color = panelBorder, frame_color = panelBorder, frame_width = 1, border_width = 1)
    panelPosMemory := panelPosition
    panelThemeMemory := panelTheme

if showPanel and not na(panel) and barstate.islast
    table.clear(panel, 0, 0, 1, 7)
    table.merge_cells(panel, 0, 0, 1, 0)

    color ftTierCol = not ftReady ? panelValueCol : ftRate >= 55.0 ? bullColor : ftRate >= 45.0 ? neutralColor : bearColor

    f_panel_cell(panel, 0, 0, "AG Pro Reaction Quality Heat Zones", headerBg, headerText, panelSize)
    f_panel_cell(panel, 0, 1, "Reaction State", panelBg, panelLabelCol, panelSize)
    f_panel_cell(panel, 1, 1, reactionState, panelBg, stateColor, panelSize)
    f_panel_cell(panel, 0, 2, "Direction", panelBg, panelLabelCol, panelSize)
    f_panel_cell(panel, 1, 2, f_dir_text(dominantDir), panelBg, dominantDir > 0 ? bullColor : dominantDir < 0 ? bearColor : neutralColor, panelSize)
    f_panel_cell(panel, 0, 3, "Heat Score", panelBg, panelLabelCol, panelSize)
    f_panel_cell(panel, 1, 3, str.tostring(f_round(heatScore)) + " / 100", panelBg, panelValueCol, panelSize)
    f_panel_cell(panel, 0, 4, "Failure Pressure", panelBg, panelLabelCol, panelSize)
    f_panel_cell(panel, 1, 4, str.tostring(f_round(failurePressure)), panelBg, failurePressure >= failureThreshold ? bearColor : panelValueCol, panelSize)
    f_panel_cell(panel, 0, 5, "Follow-Through", panelBg, panelLabelCol, panelSize)
    f_panel_cell(panel, 1, 5, ftText, panelBg, ftTierCol, panelSize)
    f_panel_cell(panel, 0, 6, "Wick Quality", panelBg, panelLabelCol, panelSize)
    f_panel_cell(panel, 1, 6, str.tostring(f_round(dominantDir > 0 ? bullReject : bearReject)), panelBg, panelValueCol, panelSize)
    f_panel_cell(panel, 0, 7, "Next Action", panelBg, panelLabelCol, panelSize)
    f_panel_cell(panel, 1, 7, nextContext, panelBg, panelValueCol, panelSize)

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    panelPosMemory := ""
    panelThemeMemory := ""

// ─────────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────────
alertcondition(newClean, "Clean Reaction", "Reaction Quality Heat Zones: clean reaction detected.")
alertcondition(newFollow, "Follow-Through", "Reaction Quality Heat Zones: follow-through reaction detected.")
alertcondition(newFailed, "Failed Reaction", "Reaction Quality Heat Zones: failed reaction pressure detected.")
alertcondition(newAbsorption, "Absorption Risk", "Reaction Quality Heat Zones: absorption risk detected.")
alertcondition(newWeak, "Weak Reaction", "Reaction Quality Heat Zones: weak reaction detected.")
````
