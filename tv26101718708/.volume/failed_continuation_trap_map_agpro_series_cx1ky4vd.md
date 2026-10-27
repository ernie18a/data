# Failed Continuation Trap Map [AGPro Series]

- url: https://www.tradingview.com/script/Cx1kY4VD-Failed-Continuation-Trap-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;f9eac08d91064a33884a946e0e8a5c8e
- version: 3.0

## Description

Failed Continuation Trap Map [AGPro Series]

🧠 Core Idea

Did a continuation attempt fail strongly enough to trap traders and create pressure in the opposite direction?


📌 Overview / What it does

Failed Continuation Trap Map is a rule-based price-action and market-structure visualization tool designed to study failed continuation attempts.

The script identifies trend-aligned continuation attempts, maps the attempted breakout zone, evaluates whether the move fails back through that zone, and highlights when trapped longs or trapped shorts may create opposite pressure.

It does not predict reversals, automate trades, or guarantee that a failed continuation will produce follow-through. It is a structured decision-support map for continuation failure, trap behavior, and opposite-pressure context.


🎯 Purpose & Design Philosophy

Many breakout and continuation tools focus on whether price moved beyond a level.

This script was built to answer a more selective question:

Did the continuation attempt fail in a way that changes the market narrative?

The design goal is to help traders read failed continuation as a trap context instead of treating every rejection as a reversal signal.


⚡ Why This Script Is Different

Most tools focus on breakouts, pullbacks, continuation signals, or reversal labels.

This script does NOT label every failed move as a trap.

Instead, it waits for a trend-aligned continuation attempt, tracks the attempt zone, evaluates failure quality, maps the trap pocket, and checks whether opposite pressure confirms after trapped participants are created.


⚙️ Methodology

1. Continuation Bias Detection

The script uses fast and slow EMAs to define the active continuation bias.

2. Attempt Mapping

When price attempts continuation beyond recent structure, the script records the attempt level and builds an attempt zone.

3. Failure Evaluation

After the attempt, the script watches a defined failure window to detect rejection back through the attempt level.

4. Trap and Pressure Scoring

Trap quality uses rejection wick behavior, relative volume, and failure timing.

5. Visual Output

The chart displays the attempt zone, trap pocket, opposite-pressure rail, centered trap label, event labels, right-side tags, alerts, and a compact AG Pro decision panel.


🗺️ How to Read the Chart

Attempt Zone = the area around the continuation level where breakout or continuation participants may enter.

Trap Pocket = the area where failed continuation can create trapped participants.

Opposite-Pressure Rail = the level used to read whether the failed continuation is turning into stronger pressure against the attempt.

Centered Trap Label = the main visual anchor inside the active trap pocket.

Event Labels = compact labels for attempts, long traps, short traps, and pressure confirmation.

Right-Side Tags = current trap state, attempt level, and pressure quality.

Panel = summarizes trap state, attempt type, trapped side, trap quality, pressure quality, next context, and timeframe.


🚦 Signals & States

• ATTEMPT ACTIVE → price attempted continuation and is still inside the failure evaluation window.

• TRAP ACTIVE → the continuation attempt failed back through the attempt level.

• OPPOSITE PRESSURE → price confirmed pressure away from the failed continuation attempt.

• CONTINUATION HOLD → the attempt is holding beyond the continuation zone.

• ATTEMPT EXPIRED → the attempt did not create a timely failure or pressure signal.

• WAIT ATTEMPT → no valid continuation attempt is active.


🔔 Alerts Logic

Alerts trigger when a major continuation-failure state appears.

• Continuation Attempt → price attempted continuation beyond recent structure.

• Failed Continuation Trap → continuation attempt failed back through the attempt zone with trap quality.

• Opposite Pressure Confirmed → opposite pressure confirmed after a failed continuation attempt.

Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The context becomes stronger when:

• Continuation bias is clear
• Price attempts continuation beyond recent structure
• The attempt fails back through the zone quickly
• Rejection wick quality is strong
• Relative volume supports participation
• Opposite-pressure rail confirms after the trap
• The panel state agrees with the chart labels

If these elements do not align, the script avoids forcing a trap interpretation.


📊 When to Use

• Breakout failure analysis
• Failed continuation review
• Trend continuation trap studies
• Intraday and swing market-structure analysis
• Crypto, forex, stocks, and index markets
• 1H, 4H, and daily charts
• Markets where continuation attempts are common and readable


⚠️ When NOT to Use

• Very low-liquidity symbols
• Extremely sideways markets with no continuation bias
• News-driven candles that distort rejection quality
• Ultra-low timeframes with excessive noise
• Markets where recent structure is too compressed to define a clean attempt zone
• Situations where a single failed attempt should not be treated as a standalone decision


🎛️ Key Inputs

• Fast EMA Length → defines the faster continuation-bias component.

• Slow EMA Length → confirms the broader continuation direction.

• ATR Length → normalizes attempt zones, trap pockets, labels, and failure levels.

• Continuation Breakout Lookback → defines recent structure used to identify continuation attempts.

• Failure Evaluation Window → controls how long after an attempt the script can classify failure.

• Attempt Zone ATR → controls the thickness of the continuation attempt zone.

• Trap Wick Threshold → defines how much rejection quality is needed before a failure becomes trap context.

• Use Volume Confirmation → adds relative volume to trap-quality scoring.

• Projection Bars → controls how far zones, rails, and right-side tags project.

• Label Font Size → controls chart label and tag text size.

• Panel Font Size → controls panel text size.


🖥️ Interface & Visual Design

The visual hierarchy is built around the failed-continuation story.

The attempt zone shows where continuation was attempted.

The trap pocket shows where trapped participants may become part of the next narrative.

The opposite-pressure rail gives a clean reference for pressure confirmation.

The centered badge keeps the active trap context readable at first glance.

The AG Pro panel summarizes the current trap state without forcing the user to decode every element manually.


🧪 Practical Usage Workflow

1. Let the script identify the active continuation bias.

2. Watch for an attempt beyond recent structure.

3. Check whether the attempt holds or fails back through the zone.

4. If trap context appears, watch the opposite-pressure rail.

5. Use the panel to confirm trap state, trapped side, and quality scores.

6. Interpret the output inside broader trend, liquidity, volatility, and support/resistance context.


🔍 Interpretation Guidelines

A continuation attempt does not guarantee follow-through. It means price attempted to move beyond recent structure in the trend direction.

A trap active state does not guarantee reversal. It means the continuation attempt failed back through the attempt zone with enough quality to deserve attention.

Opposite pressure does not guarantee trend change. It means trapped participants may be adding pressure against the attempted continuation.

The strongest readings occur when trap state, pressure rail, and broader market context align.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not provide guaranteed entry or exit signals.

It is not a generic breakout indicator.

It is not a simple reversal marker.


⚠️ Limitations & Transparency

EMA bias can lag during fast reversals.

Failure windows may miss slow-developing traps.

Low-liquidity markets can produce misleading wick behavior.

High volatility can make attempt zones wider or less stable.

Timeframe differences can change how continuation attempts appear.

The script is designed for structured interpretation, not certainty.


🧠 Market Context Notes

Failed continuation traps often matter most when traders are leaning heavily in one direction and price fails to reward that pressure.

The same failed attempt can have different meaning in a strong trend, range, liquidity sweep, or volatility shock.

The script should be read together with broader structure, volume, liquidity, and trend context.


🧾 Use Case Examples

• If price attempts upside continuation and then closes back below the attempt level with a strong upper wick, the script may show long-trap context.

• If price attempts downside continuation and then rejects back above the attempt level, the script may show short-trap context.

• If price continues beyond the pressure rail after a trap, the script may show opposite-pressure confirmation.


🧱 System Philosophy

Failed Continuation Trap Map is part of the AGPro Series approach to decision-support tools:

clear structure, premium chart readability, honest interpretation, and no promise of certainty.

The goal is to help traders see when continuation logic breaks, without turning every failure into a forced reversal signal.


🔐 Non-Promise Statement

No script can know the future.

No failed continuation guarantees reversal.

No signal should be interpreted without broader market context.


📉 Risk Disclosure

Trading involves risk.

Markets can move unpredictably.

This script is for educational and analytical purposes only.

It does not provide financial advice or guaranteed trading outcomes.

Users remain responsible for their own decisions.


📚 Educational Note

Use this script to study how continuation attempts fail and how trapped participants can affect the next phase of market behavior.

The value is not only in the trap label. The value is in learning when a continuation narrative is accepted, rejected, or converted into opposite pressure.

## Source Code

````pine
// --------------------------------------------------
// Failed Continuation Trap Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.2
//
// Failed Continuation Trap Map studies whether a continuation attempt failed
// strongly enough to trap breakout or pullback-continuation participants. It
// maps the attempt zone, failure pocket, opposite-pressure rail, trap labels,
// alerts, and an AG Pro panel for continuation-failure context. A trap
// follow-rate layer reports how often confirmed traps on this chart actually
// reached the opposite-pressure rail before the attempt extreme was reclaimed.
// --------------------------------------------------

//@version=6
indicator("Failed Continuation Trap Map [AGPro Series]",
     shorttitle = "AGP FCTM",
     overlay = true,
     max_labels_count = 220,
     max_lines_count = 70,
     max_boxes_count = 50)

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
G_ENGINE = "Trap Engine"
G_VISUAL = "Visual Design"
G_PANEL  = "Panel"
G_ALERTS = "Alerts"

emaFastLen = input.int(21, "Fast EMA Length", minval = 2, maxval = 100, group = G_ENGINE,
     tooltip = "Fast moving average used to define the active continuation bias.")
emaSlowLen = input.int(55, "Slow EMA Length", minval = 5, maxval = 200, group = G_ENGINE,
     tooltip = "Slow moving average used to confirm the broader continuation direction.")
atrLen = input.int(14, "ATR Length", minval = 5, maxval = 100, group = G_ENGINE,
     tooltip = "ATR normalizes attempt zones, trap pockets, label spacing, and failure thresholds.")
breakoutLookback = input.int(22, "Continuation Breakout Lookback", minval = 5, maxval = 120, group = G_ENGINE,
     tooltip = "Lookback used to identify continuation attempts above or below recent structure.")
failureWindow = input.int(12, "Failure Evaluation Window", minval = 2, maxval = 60, group = G_ENGINE,
     tooltip = "Number of bars after a continuation attempt where failure can become a trap.")
zoneAtr = input.float(0.40, "Attempt Zone ATR", minval = 0.05, maxval = 2.0, step = 0.05, group = G_ENGINE,
     tooltip = "Thickness of the continuation attempt zone around the attempted breakout level.")
trapWickThreshold = input.int(38, "Trap Wick Threshold", minval = 5, maxval = 90, group = G_ENGINE,
     tooltip = "Minimum rejection-wick quality required before a failed continuation receives trap context.")
volumeConfirm = input.bool(true, "Use Volume Confirmation", group = G_ENGINE,
     tooltip = "Adds relative volume to trap-quality scoring when volume data is available.")
volumeLen = input.int(20, "Relative Volume Length", minval = 2, maxval = 200, group = G_ENGINE,
     tooltip = "Lookback used to compare current volume with recent activity.")

showAttemptZone = input.bool(true, "Show Attempt Zone", group = G_VISUAL,
     tooltip = "Displays the active continuation attempt zone.")
showTrapPocket = input.bool(true, "Show Trap Pocket", group = G_VISUAL,
     tooltip = "Displays the opposite-pressure pocket after a failed continuation attempt.")
showPressureRail = input.bool(true, "Show Opposite-Pressure Rail", group = G_VISUAL,
     tooltip = "Displays the rail used to read whether trapped participants are creating pressure in the opposite direction.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Prints compact event labels for continuation attempts, trap failures, and opposite-pressure confirmations.")
showAttemptLabels = input.bool(false, "Show Attempt Labels", group = G_VISUAL,
     tooltip = "Optionally prints continuation-attempt labels. Disabled by default so trap and pressure labels stay visually dominant.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Displays compact right-side tags for trap state, attempt level, and pressure rail.")
showCenteredText = input.bool(true, "Show Centered Trap Label", group = G_VISUAL,
     tooltip = "Places a centered badge inside the active trap pocket for premium first-glance readability.")
showBarColors = input.bool(false, "Color Bars by Trap State", group = G_VISUAL,
     tooltip = "Optionally colors bars by the current failed-continuation trap state.")
projectionBars = input.int(42, "Projection Bars", minval = 10, maxval = 180, group = G_VISUAL,
     tooltip = "Controls how far trap zones, rails, and right-side tags project to the right.")
labelCooldownBars = input.int(34, "Event Label Cooldown", minval = 1, maxval = 100, group = G_VISUAL,
     tooltip = "Minimum spacing between event labels so the chart remains readable.")
maxEventLabels = input.int(9, "Maximum Event Labels", minval = 4, maxval = 80, group = G_VISUAL,
     tooltip = "Caps historical event labels for performance and visual clarity.")
labelOffsetAtr = input.float(0.95, "Label Offset ATR", minval = 0.15, maxval = 4.0, step = 0.05, group = G_VISUAL,
     tooltip = "Moves labels away from candles so they remain readable and do not feel buried in price.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL,
     tooltip = "Controls the font size used by event labels, trap badges, and right-side tags.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro failed-continuation trap panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = G_PANEL,
     tooltip = "Controls where the panel appears on the chart.")
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = G_PANEL,
     tooltip = "Switches the panel between a dark AGPro surface and a clean light surface.")
panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL,
     tooltip = "Controls text size inside the panel.")

alertAttempt = input.bool(true, "Alert: Continuation Attempt", group = G_ALERTS,
     tooltip = "Triggers when price attempts continuation beyond recent structure in the trend direction.")
alertTrap = input.bool(true, "Alert: Failed Continuation Trap", group = G_ALERTS,
     tooltip = "Triggers when a continuation attempt fails back through the attempt zone with trap quality.")
alertPressure = input.bool(true, "Alert: Opposite Pressure", group = G_ALERTS,
     tooltip = "Triggers when price confirms pressure in the opposite direction after a failed continuation.")

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_clamp(value, minValue, maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_size(value) =>
    result = size.normal
    if value == "Tiny"
        result := size.tiny
    else if value == "Small"
        result := size.small
    else if value == "Large"
        result := size.large
    result

f_panel_pos(value) =>
    result = position.top_right
    if value == "Top Left"
        result := position.top_left
    else if value == "Middle Right"
        result := position.middle_right
    else if value == "Middle Left"
        result := position.middle_left
    else if value == "Bottom Right"
        result := position.bottom_right
    else if value == "Bottom Left"
        result := position.bottom_left
    result

f_fmt(value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_text_on(bg) =>
    brightness = color.r(bg) + color.g(bg) + color.b(bg)
    brightness >= 360 ? darkText : color.white

f_score(value) =>
    na(value) ? "n/a" : str.tostring(int(math.round(value)))

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
// Trap Engine
// --------------------------------------------------
atr = nz(ta.atr(atrLen), high - low)
labelOffset = atr * labelOffsetAtr
labelSize = f_size(labelSizeInput)
panelSize = f_size(panelSizeInput)
fastEma = ta.ema(close, emaFastLen)
slowEma = ta.ema(close, emaSlowLen)
volBase = ta.sma(volume, volumeLen)
relVol = not na(volBase) and volBase > 0.0 and not na(volume) ? volume / volBase : 1.0
volBoost = volumeConfirm ? f_clamp(relVol, 0.6, 2.0) : 1.0

biasDir = fastEma > slowEma ? 1 : fastEma < slowEma ? -1 : 0
priorHigh = ta.highest(high[1], breakoutLookback)
priorLow = ta.lowest(low[1], breakoutLookback)

bullAttempt = biasDir > 0 and high > priorHigh and close > priorHigh
bearAttempt = biasDir < 0 and low < priorLow and close < priorLow

var int attemptDir = 0
var float attemptLevel = na
var float attemptTop = na
var float attemptBottom = na
var int attemptBar = na
var bool trapMemory = false

if bullAttempt
    attemptDir := 1
    attemptLevel := priorHigh
    attemptTop := priorHigh + atr * zoneAtr
    attemptBottom := priorHigh - atr * zoneAtr
    attemptBar := bar_index
    trapMemory := false

if bearAttempt
    attemptDir := -1
    attemptLevel := priorLow
    attemptTop := priorLow + atr * zoneAtr
    attemptBottom := priorLow - atr * zoneAtr
    attemptBar := bar_index
    trapMemory := false

hasAttempt = attemptDir != 0 and not na(attemptLevel) and not na(attemptBar)
barsSinceAttempt = hasAttempt ? bar_index - attemptBar : na
attemptActive = hasAttempt and barsSinceAttempt <= failureWindow

barRange = math.max(high - low, syminfo.mintick)
upperWickQuality = f_clamp((high - math.max(open, close)) / barRange * 100.0, 0.0, 100.0)
lowerWickQuality = f_clamp((math.min(open, close) - low) / barRange * 100.0, 0.0, 100.0)

bullFail = attemptActive and attemptDir > 0 and close < attemptLevel and upperWickQuality >= trapWickThreshold
bearFail = attemptActive and attemptDir < 0 and close > attemptLevel and lowerWickQuality >= trapWickThreshold
trapEventRaw = bullFail or bearFail

if trapEventRaw
    trapMemory := true

pressureLevel = hasAttempt ? attemptDir > 0 ? attemptBottom - atr * zoneAtr : attemptTop + atr * zoneAtr : na
oppositePressure = hasAttempt and trapMemory and (attemptDir > 0 ? close < pressureLevel : close > pressureLevel)
attemptCleared = hasAttempt and not trapMemory and (attemptDir > 0 ? close > attemptTop : close < attemptBottom)

trapQualityLive = hasAttempt ? f_clamp((attemptDir > 0 ? upperWickQuality : lowerWickQuality) * 0.55 + volBoost * 12.0 + math.max(0, failureWindow - nz(barsSinceAttempt, failureWindow)) * 2.0, 0.0, 100.0) : na

// Confirmed trap event: the bar on which trap memory first turns on.
trapConfirmedNew = barstate.isconfirmed and trapEventRaw and not trapMemory[1]

// The trap quality shown on the panel and pocket badge is frozen at the
// confirmed trap event, so it describes the trap itself instead of drifting
// with every new candle's wick afterwards.
var float trapQualityLock = na
if bullAttempt or bearAttempt
    trapQualityLock := na
if trapConfirmedNew
    trapQualityLock := trapQualityLive
trapQuality = trapMemory and not na(trapQualityLock) ? trapQualityLock : trapQualityLive
pressureQuality = hasAttempt ? f_clamp(trapQuality + (oppositePressure ? 15.0 : 0.0), 0.0, 100.0) : na

// Trap follow-rate layer: each confirmed trap on this chart is tracked
// once. It counts as followed when price reaches the opposite-pressure
// rail before the attempt extreme is reclaimed, and as failed when the
// attempt extreme is reclaimed first (continuation resumed) or when the
// tracking window times out. Resolution runs before registration, so
// same-bar conflicts resolve conservatively.
var bool trapTrkOn = false
var int trapTrkDir = 0
var float trapTrkTgt = na
var float trapTrkInv = na
var int trapTrkStart = na
var int trapFollowW = 0
var int trapFollowN = 0
if trapTrkOn
    trkFollowed = trapTrkDir == 1 ? high >= trapTrkTgt : low <= trapTrkTgt
    trkFailed = trapTrkDir == 1 ? close < trapTrkInv : close > trapTrkInv
    trkTimeout = not na(trapTrkStart) and bar_index - trapTrkStart >= breakoutLookback * 2
    if trkFailed or trkTimeout
        trapFollowN += 1
        trapTrkOn := false
    else if trkFollowed
        trapFollowN += 1
        trapFollowW += 1
        trapTrkOn := false
if trapConfirmedNew and not trapTrkOn
    trapTrkOn := true
    trapTrkDir := attemptDir > 0 ? -1 : 1
    trapTrkTgt := pressureLevel
    trapTrkInv := attemptDir > 0 ? attemptTop : attemptBottom
    trapTrkStart := bar_index
trapFollowRate = trapFollowN > 0 ? 100.0 * trapFollowW / trapFollowN : na
trapFollowReady = trapFollowN >= 8

stateText = not hasAttempt ? "WAIT ATTEMPT" : oppositePressure ? "OPPOSITE PRESSURE" : trapMemory ? "TRAP ACTIVE" : attemptCleared ? "CONTINUATION HOLD" : attemptActive ? "ATTEMPT ACTIVE" : "ATTEMPT EXPIRED"
stateColor = oppositePressure ? attemptDir > 0 ? bearColor : bullColor : trapMemory ? bearColor : attemptCleared ? bullColor : attemptActive ? accentColor : neutralColor
attemptText = attemptDir > 0 ? "UPSIDE ATTEMPT" : attemptDir < 0 ? "DOWNSIDE ATTEMPT" : "n/a"
trappedSide = trapMemory ? (attemptDir > 0 ? "Trapped longs" : "Trapped shorts") : "-"
nextContext = not hasAttempt ? "Wait continuation" : oppositePressure ? "Opposite side active" : trapMemory ? "Watch pressure rail" : attemptCleared ? "Trend accepted" : attemptActive ? "Wait fail/hold" : "Attempt stale"

// --------------------------------------------------
// Visual Objects
// --------------------------------------------------
var box attemptBox = box.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 90), border_color = accentColor)
var box trapBox = box.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, bgcolor = color.new(bearColor, 90), border_color = bearColor)
var line pressureRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = neutralColor, style = line.style_dotted, width = 2)
var label trapCenter = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_center, color = bearColor, textcolor = color.white, size = size.normal)
var label stateTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = neutralColor, textcolor = color.white, size = size.normal)
var label levelTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = color.white, size = size.normal)
var label pressureTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = neutralColor, textcolor = color.white, size = size.normal)
var line attemptConnector = na
var line pressureConnector = na

rightX = bar_index + projectionBars
leftX = hasAttempt ? attemptBar : bar_index
midX = hasAttempt ? int(math.round((leftX + rightX) * 0.5)) : bar_index
trapTop = hasAttempt ? attemptDir > 0 ? attemptLevel : pressureLevel : close
trapBottom = hasAttempt ? attemptDir > 0 ? pressureLevel : attemptLevel : close
trapMid = hasAttempt ? (math.max(trapTop, trapBottom) + math.min(trapTop, trapBottom)) * 0.5 : close

if barstate.islast and hasAttempt and showAttemptZone
    attemptColor = attemptDir > 0 ? bullColor : bearColor
    f_set_box(attemptBox, leftX, rightX, attemptTop, attemptBottom, color.new(attemptColor, 88), color.new(attemptColor, 18))
else if barstate.islast
    f_set_box(attemptBox, bar_index, bar_index + 1, close, close, color.new(accentColor, 100), color.new(accentColor, 100))

if barstate.islast and hasAttempt and trapMemory and showTrapPocket
    trapColor = attemptDir > 0 ? bearColor : bullColor
    f_set_box(trapBox, attemptBar, rightX, math.max(trapTop, trapBottom), math.min(trapTop, trapBottom), color.new(trapColor, 88), color.new(trapColor, 18))
    if showCenteredText
        trappedPocketSide = attemptDir > 0 ? "LONG" : "SHORT"
        f_set_tag(trapCenter, midX, trapMid, trappedPocketSide + " TRAP POCKET | Q " + f_score(trapQuality), color.new(trapColor, 0), label.style_label_center, labelSize)
    else
        label.set_text(trapCenter, "")
else if barstate.islast
    f_set_box(trapBox, bar_index, bar_index + 1, close, close, color.new(bearColor, 100), color.new(bearColor, 100))
    label.set_text(trapCenter, "")

if barstate.islast and hasAttempt and showPressureRail
    railColor = trapMemory ? stateColor : neutralColor
    f_set_line(pressureRail, leftX, rightX, pressureLevel, color.new(railColor, 0), line.style_dotted)
else if barstate.islast
    f_set_line(pressureRail, bar_index, bar_index + 1, close, color.new(neutralColor, 100), line.style_dotted)

if barstate.islast and hasAttempt and showRightTags
    tagX = rightX + 8
    laneStep = atr * (labelSizeInput == "Large" ? 1.10 : labelSizeInput == "Normal" ? 0.90 : labelSizeInput == "Small" ? 0.74 : 0.62)
    railSide = attemptDir > 0 ? -1.0 : 1.0
    levelsTight = math.abs(pressureLevel - attemptLevel) < laneStep * 2.20
    pressureBaseY = levelsTight ? pressureLevel + railSide * laneStep : pressureLevel
    attemptBaseY = levelsTight ? attemptLevel - railSide * laneStep : attemptLevel
    pressureTagY = math.abs(pressureBaseY - close) < laneStep * 1.60 ? pressureBaseY + railSide * laneStep : pressureBaseY
    attemptTagY = math.abs(attemptBaseY - close) < laneStep * 1.60 ? attemptBaseY - railSide * laneStep : attemptBaseY
    f_set_tag(stateTag, tagX, close, "LIVE " + stateText + " | " + f_fmt(close), stateColor, label.style_label_left, labelSize)
    if showAttemptZone
        f_set_tag(levelTag, tagX, attemptTagY, "ATTEMPT " + f_fmt(attemptLevel), accentColor, label.style_label_left, labelSize)
        if na(attemptConnector)
            attemptConnector := line.new(rightX, attemptLevel, tagX - 1, attemptTagY, xloc = xloc.bar_index, color = color.new(accentColor, 4), width = 2)
        else
            line.set_xy1(attemptConnector, rightX, attemptLevel)
            line.set_xy2(attemptConnector, tagX - 1, attemptTagY)
            line.set_color(attemptConnector, color.new(accentColor, 4))
            line.set_width(attemptConnector, 2)
    else
        label.set_text(levelTag, "")
        if not na(attemptConnector)
            line.delete(attemptConnector)
            attemptConnector := na
    if showPressureRail
        f_set_tag(pressureTag, tagX, pressureTagY, "PRESSURE " + f_fmt(pressureLevel) + " | Q " + f_score(pressureQuality), stateColor, label.style_label_left, labelSize)
        if na(pressureConnector)
            pressureConnector := line.new(rightX, pressureLevel, tagX - 1, pressureTagY, xloc = xloc.bar_index, color = color.new(stateColor, 4), width = 2)
        else
            line.set_xy1(pressureConnector, rightX, pressureLevel)
            line.set_xy2(pressureConnector, tagX - 1, pressureTagY)
            line.set_color(pressureConnector, color.new(stateColor, 4))
            line.set_width(pressureConnector, 2)
    else
        label.set_text(pressureTag, "")
        if not na(pressureConnector)
            line.delete(pressureConnector)
            pressureConnector := na
else if barstate.islast
    label.set_text(stateTag, "")
    label.set_text(levelTag, "")
    label.set_text(pressureTag, "")
    if not na(attemptConnector)
        line.delete(attemptConnector)
        attemptConnector := na
    if not na(pressureConnector)
        line.delete(pressureConnector)
        pressureConnector := na

// --------------------------------------------------
// Event Labels
// --------------------------------------------------
var array<label> eventLabels = array.new<label>()
var int lastEventBar = na
canPrintEvent = na(lastEventBar) or bar_index - lastEventBar >= labelCooldownBars
attemptConfirmed = barstate.isconfirmed and (bullAttempt or bearAttempt)
attemptEvent = showAttemptLabels and attemptConfirmed
trapEvent = trapConfirmedNew
pressureEvent = barstate.isconfirmed and oppositePressure and not oppositePressure[1]
eventCandidate = attemptEvent or trapEvent or pressureEvent
eventText = pressureEvent ? "PRESSURE EVENT | Q " + f_score(pressureQuality) : trapEvent ? (attemptDir > 0 ? "LONG TRAP | Q " : "SHORT TRAP | Q ") + f_score(trapQuality) : "ATTEMPT EVENT | Q " + f_score(trapQuality)
eventColor = pressureEvent ? stateColor : trapEvent ? attemptDir > 0 ? bearColor : bullColor : accentColor
eventY = attemptDir > 0 ? high + labelOffset : low - labelOffset
eventStyle = attemptDir > 0 ? label.style_label_down : label.style_label_up

if showEventLabels and eventCandidate and canPrintEvent
    newEventLabel = label.new(bar_index, eventY, eventText, xloc = xloc.bar_index, style = eventStyle, textcolor = f_text_on(eventColor), color = color.new(eventColor, 10), size = labelSize)
    f_keep_label(eventLabels, newEventLabel, maxEventLabels)
    lastEventBar := bar_index

barCol = oppositePressure ? color.new(stateColor, 55) : trapMemory ? color.new(stateColor, 68) : na
barcolor(showBarColors ? barCol : na)

// --------------------------------------------------
// Panel
// --------------------------------------------------
panelBgActive = panelThemeInput == "Dark" ? panelBg : color.rgb(248, 250, 252)
panelBorderActive = panelThemeInput == "Dark" ? panelBorder : color.rgb(203, 213, 225)
panelLabelActive = panelThemeInput == "Dark" ? panelLabelCol : color.rgb(71, 85, 105)
panelValueActive = panelThemeInput == "Dark" ? panelValueCol : color.rgb(15, 23, 42)

var table panel = na
var string panelPosMemory = ""
var string panelThemeMemory = ""

if showPanel and (na(panel) or panelPosMemory != panelPositionInput or panelThemeMemory != panelThemeInput)
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_pos(panelPositionInput), 2, 9, bgcolor = panelBgActive, border_color = panelBorderActive, border_width = 1)
    panelPosMemory := panelPositionInput
    panelThemeMemory := panelThemeInput

if showPanel and not na(panel)
    f_panel_cell(panel, 0, 0, "AG Pro Failed Continuation Trap Map", headerBg, headerText, panelSize, text.align_center)
    f_panel_cell(panel, 1, 0, "", headerBg, headerText, panelSize, text.align_center)
    table.merge_cells(panel, 0, 0, 1, 0)
    f_panel_cell(panel, 0, 1, "Trap State", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 1, stateText, panelBgActive, stateColor, panelSize, text.align_center)
    f_panel_cell(panel, 0, 2, "Attempt Type", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 2, attemptText, panelBgActive, panelValueActive, panelSize, text.align_center)
    f_panel_cell(panel, 0, 3, "Trapped Side", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 3, trappedSide, panelBgActive, panelValueActive, panelSize, text.align_center)
    f_panel_cell(panel, 0, 4, "Trap Quality", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 4, f_score(trapQuality), panelBgActive, panelValueActive, panelSize, text.align_center)
    f_panel_cell(panel, 0, 5, "Pressure Quality", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 5, f_score(pressureQuality), panelBgActive, panelValueActive, panelSize, text.align_center)
    f_panel_cell(panel, 0, 6, "Next Context", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 6, nextContext, panelBgActive, panelValueActive, panelSize, text.align_center)
    trapFollowText = trapFollowN == 0 ? "-" : str.tostring(int(math.round(trapFollowRate))) + "%  n=" + str.tostring(trapFollowN)
    trapFollowColor = trapFollowReady ? (trapFollowRate >= 55.0 ? bullColor : trapFollowRate >= 40.0 ? neutralColor : bearColor) : panelLabelActive
    f_panel_cell(panel, 0, 7, "Trap Follow", panelBgActive, panelLabelActive, panelSize, text.align_center)
    f_panel_cell(panel, 1, 7, trapFollowText, panelBgActive, trapFollowColor, panelSize, text.align_center)
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
alertcondition(alertAttempt and attemptConfirmed, "Continuation Attempt", "Failed Continuation Trap Map: price attempted continuation beyond recent structure.")
alertcondition(alertTrap and trapEvent, "Failed Continuation Trap", "Failed Continuation Trap Map: continuation attempt failed back through the attempt zone with trap quality.")
alertcondition(alertPressure and pressureEvent, "Opposite Pressure Confirmed", "Failed Continuation Trap Map: opposite pressure confirmed after a failed continuation attempt.")
````
