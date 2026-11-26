# Liquidity Timeframe Stack Map [AGPro Series]

- url: https://www.tradingview.com/script/J9GugqUt-Liquidity-Timeframe-Stack-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;a1f32b97495648d98ea3c7fb94c5163c
- version: 3.0

## Description

Liquidity Timeframe Stack Map [AGPro Series]

🧠 Core Idea

Are lower-timeframe liquidity sweeps aligned with the higher-timeframe liquidity shelf, or are they fighting the broader structure?


📌 Overview / What it does

Liquidity Timeframe Stack Map is a multi-timeframe liquidity context tool built to compare current-chart sweep behavior with higher-timeframe liquidity shelves.

The script maps the latest confirmed higher-timeframe upper and lower liquidity shelves, detects local buy-side and sell-side sweeps, evaluates wick-based reaction quality, and converts the result into a readable stack state.

It does not predict price direction, automate trades, or claim that every sweep will create a reversal. It is designed as a structured market context and visualization tool.


🎯 Purpose & Design Philosophy

This script was built to solve a common liquidity-reading problem:

A lower-timeframe sweep can look important by itself, but its meaning changes when it happens near a higher-timeframe shelf.

The goal is to help traders separate aligned liquidity reactions from isolated local noise. The script supports a context-first mindset: read the shelf, read the sweep, then judge whether the reaction is aligned or conflicting.


⚡ Why This Script Is Different

Most liquidity tools focus on detecting a sweep, stop run, equal high, or equal low.

This script does NOT treat every sweep as equally important.

Instead, it compares the local sweep against a higher-timeframe liquidity framework and classifies whether the move is a stack alignment, a stack conflict, or a neutral shelf interaction.


⚙️ Methodology

1. Higher-Timeframe Shelf Detection

The script reads confirmed pivot structure from the selected higher timeframe and builds active upper and lower liquidity shelf zones.

2. Local Sweep Detection

The chart timeframe is used as the lower-timeframe layer. Local buy-side and sell-side sweeps are detected when price takes a recent pivot level and closes back through it.

3. Reaction Evaluation

The script evaluates wick reaction quality after the sweep. Stronger wick rejection or reclaim behavior produces a higher reaction quality score.

4. Stack Classification

The script checks whether the local sweep occurred near the relevant higher-timeframe shelf. If the sweep and shelf context align, the script marks an HTF Buy Stack or HTF Sell Stack. If the sweep fights the broader shelf context, it marks a Stack Conflict.

5. Visual Output

The result is displayed through HTF shelf zones, sweep markers, stack labels, right-side tags, alerts, and a compact AG Pro panel.


🗺️ How to Read the Chart

Upper HTF Liquidity Shelf = the active higher-timeframe upper liquidity reference.

Lower HTF Liquidity Shelf = the active higher-timeframe lower liquidity reference.

Buy-Side Sweep marker = price swept a local upper liquidity reference and closed back below it.

Sell-Side Sweep marker = price swept a local lower liquidity reference and closed back above it.

HTF Buy Stack label = a sell-side sweep reacted near the lower HTF shelf with enough reaction quality.

HTF Sell Stack label = a buy-side sweep reacted near the upper HTF shelf with enough reaction quality.

Stack Conflict label = the local sweep behavior is not cleanly aligned with the broader HTF shelf context.

Panel = summarizes stack state, stack score, HTF shelves, LTF sweep state, reaction quality, next context, and invalidation reference.


🚦 Signals & States

• HTF BUY STACK → sell-side liquidity was swept near the lower higher-timeframe shelf with a qualifying reaction.

• HTF SELL STACK → buy-side liquidity was swept near the upper higher-timeframe shelf with a qualifying reaction.

• STACK CONFLICT → local sweep behavior is fighting or confusing the broader shelf context.

• LOWER SHELF → price is interacting with the lower HTF shelf area, but no full stack event is active.

• UPPER SHELF → price is interacting with the upper HTF shelf area, but no full stack event is active.

• NEUTRAL → no active shelf alignment or conflict is detected.


🔔 Alerts Logic

Alerts trigger when a new major stack condition appears.

• HTF Buy Stack Alignment → a sell-side sweep aligns with the lower higher-timeframe liquidity shelf.

• HTF Sell Stack Alignment → a buy-side sweep aligns with the upper higher-timeframe liquidity shelf.

• Liquidity Stack Conflict → the local sweep direction conflicts with the broader higher-timeframe shelf context.

• HTF Liquidity Shelf Touch → price enters either active higher-timeframe shelf zone.

Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The context becomes stronger when these elements align:

• Price is near an active higher-timeframe shelf
• Local liquidity is swept
• The candle closes back through the swept level
• Wick reaction quality is strong
• The panel state and chart label agree

When these elements do not align, the script treats the context as neutral or conflicting instead of forcing a directional interpretation.


📊 When to Use

• Multi-timeframe liquidity analysis
• Swing and intraday market preparation
• Smart-money-style structure review
• Sweep and reclaim evaluation
• Context checks before interpreting local reactions
• Markets where higher-timeframe levels matter


⚠️ When NOT to Use

• Very low-liquidity symbols
• Extremely noisy lower timeframes
• Markets with unreliable wick structure
• Situations where the selected higher timeframe is not meaningful
• Assets with large gaps or inconsistent session data
• Moments when a single local candle should not be over-interpreted


🎛️ Key Inputs

• Higher Timeframe Shelf → selects the timeframe used to build the broad liquidity shelves.

• HTF Shelf Pivot Length → controls how strict the higher-timeframe shelf structure is.

• LTF Sweep Pivot Length → controls how local sweep references are detected.

• Shelf Zone Width ATR → adjusts the visual thickness of HTF shelf zones.

• Max Shelf Width % Range → caps shelf thickness relative to the distance between the upper and lower HTF shelves, keeping the visual structure clean on wide timeframes.

• Near Shelf Distance ATR → controls how close a sweep must be to a shelf to count as aligned.

• Reaction Quality Threshold → sets the minimum wick reaction required for a strong stack event.

• Stack Score Smoothing → smooths the panel score for cleaner interpretation.

• Visual settings → control shelves, equilibrium line, sweep markers, event labels, right-side tags, and font sizes.

• Show Sweep Marker Letters → adds optional BS / SS text to local sweep markers. The default publication view keeps this disabled for a cleaner chart.

• Event Label Mode → Premium labels only strong HTF stack alignments. Detailed also labels stack conflicts.

• Adaptive Label Layout → automatically shortens and separates shelf labels when higher timeframes compress the HTF shelf cluster.

• Event Label Offset ATR → moves stack event labels farther from candles and shelf-center labels. HTF Sell Stack labels are pushed above the upper shelf zone, while HTF Buy Stack labels are pushed below the lower shelf zone to reduce overlap on publication screenshots.

• Right-side tags use adaptive positioning so the STACK tag avoids crowding the HTF UPPER and HTF LOWER tags when price is near a shelf.


🖥️ Interface & Visual Design

The interface is built around a clear visual hierarchy:

HTF shelves show the broader liquidity map.

Sweep markers show local liquidity events.

Stack labels show important alignment or conflict moments.

The AG Pro panel compresses the current state into a fast, readable decision-support summary.


🧪 Practical Usage Workflow

1. Start with the panel state.

2. Check where price is relative to the HTF upper and lower shelves.

3. Look for a recent buy-side or sell-side sweep marker.

4. Read the event label only if the sweep happened near the relevant shelf.

5. Use Reaction Q and Stack Score to judge whether the context is clean or weak.

6. Interpret the result inside the broader market structure.


🔍 Interpretation Guidelines

HTF Buy Stack does not mean price must go up. It means a sell-side sweep reacted near a lower higher-timeframe shelf with enough quality to deserve attention.

HTF Sell Stack does not mean price must go down. It means a buy-side sweep reacted near an upper higher-timeframe shelf with enough quality to deserve attention.

Stack Conflict is often more useful as a warning than as a signal. It tells the trader that the local sweep and broader shelf context are not cleanly aligned.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not provide guaranteed entry or exit signals.

It does not claim that every liquidity sweep will reverse.


⚠️ Limitations & Transparency

Higher-timeframe pivot shelves are confirmed after structure develops, so they are not instant future levels.

Different chart timeframes may create different local sweep readings.

Very volatile markets may generate fast shelf touches without clean reactions.

Low-liquidity symbols may produce misleading wick behavior.

The selected higher timeframe should match the trader’s actual analysis horizon.


🧠 Market Context Notes

Liquidity analysis is strongest when local behavior is interpreted inside a broader structure.

A sweep near a meaningful higher-timeframe shelf can carry more information than a random sweep in the middle of a range.

This script is designed to make that distinction visible.


🧾 Use Case Examples

When price sweeps local sell-side liquidity near the lower HTF shelf and closes back above the swept level, the script may mark HTF BUY STACK if reaction quality is strong enough.

When price sweeps local buy-side liquidity near the upper HTF shelf and closes back below the swept level, the script may mark HTF SELL STACK if reaction quality is strong enough.

When a local sweep appears away from the relevant higher-timeframe shelf, the script may classify the move as neutral or conflicting.


🧱 System Philosophy

The script follows a context-first AGPro approach:

Structure first.
Liquidity second.
Reaction third.
Decision support last.

It is designed to reduce isolated signal thinking and encourage multi-timeframe interpretation.


🔐 Non-Promise Statement

No script can guarantee outcomes.

No shelf, sweep, score, or label should be treated as certainty.

The output should always be combined with broader market context and personal risk rules.


📉 Risk Disclosure

Trading involves risk.

Markets can move against any interpretation.

This script is for educational and analytical purposes only.

Users are fully responsible for their own decisions.


📚 Educational Note

Use this script to study how lower-timeframe liquidity behavior changes when it is read against higher-timeframe structure.

## Source Code

````pine
// --------------------------------------------------
// Liquidity Timeframe Stack Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.1
//
// Liquidity Timeframe Stack Map studies whether lower-timeframe liquidity
// sweeps are aligned with higher-timeframe liquidity shelves or fighting the
// broader structure. It maps upper and lower HTF shelves, LTF sweep reactions,
// stack agreement, conflict states, reaction quality, alerts, and an AG Pro
// panel for multi-timeframe liquidity context. A cumulative Stack Edge engine
// measures, on this chart and timeframe, how often confirmed stack-aligned
// sweeps actually produced a one-ATR reaction before the shelf gave way, and
// a clear next-action line turns the liquidity map into a decision tool.
// --------------------------------------------------

//@version=6
indicator("Liquidity Timeframe Stack Map [AGPro Series]",
     shorttitle = "AGP LTSM",
     overlay = true,
     max_labels_count = 180,
     max_lines_count = 90,
     max_boxes_count = 40)

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

// --------------------------------------------------
// Inputs
// --------------------------------------------------
G_STACK  = "Timeframe Stack Engine"
G_SWEEP  = "Liquidity Sweep Logic"
G_VISUAL = "Visuals"
G_PANEL  = "Panel"
G_ALERTS = "Alerts"

htfInput = input.timeframe("240", "Higher Timeframe Shelf", group = G_STACK,
     tooltip = "Higher timeframe used to build the upper and lower liquidity shelves. The script compares current-chart sweeps against this broader reference.")
htfPivotLen = input.int(5, "HTF Shelf Pivot Length", minval = 2, maxval = 30, group = G_STACK,
     tooltip = "Pivot length used to identify the latest confirmed higher-timeframe liquidity shelves.")
ltfPivotLen = input.int(5, "LTF Sweep Pivot Length", minval = 2, maxval = 30, group = G_SWEEP,
     tooltip = "Pivot length used on the chart timeframe to define the local liquidity levels that may be swept.")
atrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = G_STACK,
     tooltip = "ATR length used to size shelf zones, label offsets, and proximity scoring.")
shelfAtrWidth = input.float(0.35, "Shelf Zone Width ATR", minval = 0.05, maxval = 3.0, step = 0.05, group = G_STACK,
     tooltip = "Controls the visual thickness of the higher-timeframe liquidity shelf zones.")
maxShelfWidthPct = input.float(12.0, "Max Shelf Width % Range", minval = 2.0, maxval = 40.0, step = 0.5, group = G_STACK,
     tooltip = "Caps shelf zone thickness as a percentage of the distance between the upper and lower HTF shelves. This keeps wide timeframes from producing overlapping shelf zones.")
nearShelfAtr = input.float(1.15, "Near Shelf Distance ATR", minval = 0.10, maxval = 5.0, step = 0.05, group = G_STACK,
     tooltip = "Maximum distance from an HTF shelf where an LTF sweep can be treated as a stack-aligned event.")
qualityThreshold = input.int(58, "Reaction Quality Threshold", minval = 1, maxval = 100, group = G_SWEEP,
     tooltip = "Minimum wick reaction quality required before a sweep is treated as a strong stack reaction.")
scoreSmoothing = input.int(3, "Stack Score Smoothing", minval = 1, maxval = 30, group = G_STACK,
     tooltip = "EMA smoothing applied to the stack score so the panel reads as context instead of one-bar noise.")
edgeTargetAtr = input.float(1.0, "Edge Target ATR", minval = 0.25, maxval = 5.0, step = 0.25, group = G_SWEEP,
     tooltip = "Reaction distance, in ATR from the event close, that a confirmed stack event must reach for the Stack Edge statistic to count it as a hit.")
edgeWindow = input.int(30, "Edge Resolution Window", minval = 5, maxval = 200, group = G_SWEEP,
     tooltip = "Maximum number of bars a Stack Edge episode may stay open. If neither the target nor the invalidation is reached inside this window, the episode counts as a miss.")

showShelves = input.bool(true, "Show HTF Liquidity Shelves", group = G_VISUAL,
     tooltip = "Displays upper and lower higher-timeframe liquidity shelves as active zones on the chart.")
showMidline = input.bool(true, "Show HTF Equilibrium Line", group = G_VISUAL,
     tooltip = "Draws the midpoint between the active higher-timeframe liquidity shelves.")
showSweepBadges = input.bool(false, "Show Secondary LTF Sweep Badges", group = G_VISUAL,
     tooltip = "Shows optional filled badges for qualified local sweeps that are not already represented by a higher-timeframe stack event. Disabled by default to preserve the primary chart hierarchy.")
showEventLabels = input.bool(true, "Show Stack Event Labels", group = G_VISUAL,
     tooltip = "Prints curated labels when an LTF sweep aligns or conflicts with the higher-timeframe shelf structure.")
eventLabelMode = input.string("Premium", "Event Label Mode", options = ["Premium", "Detailed"], group = G_VISUAL,
     tooltip = "Premium mode labels only strong HTF stack alignments. Detailed mode also labels stack conflicts.")
minimumEventScore = input.int(75, "Minimum Event Score", minval = 1, maxval = 100, group = G_VISUAL,
     tooltip = "Minimum smoothed stack score required for a historical event badge. Active shelves and current right-side workflow badges remain visible regardless of this filter.")
adaptiveLabelLayout = input.bool(true, "Adaptive Label Layout", group = G_VISUAL,
     tooltip = "Automatically shortens and separates shelf labels when wide timeframes compress the HTF shelf cluster.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows compact right-side tags for upper shelf, lower shelf, and active stack score.")
labelCooldownBars = input.int(52, "Event Label Cooldown", minval = 1, maxval = 150, group = G_VISUAL,
     tooltip = "Minimum spacing between event labels so the chart remains readable and premium.")
eventLabelOffsetAtr = input.float(1.35, "Event Label Offset ATR", minval = 0.25, maxval = 5.0, step = 0.05, group = G_VISUAL,
     tooltip = "Moves stack event labels farther away from candles and shelf-center labels. Higher values reduce overlap on publication screenshots.")
rightTagOffset = input.int(7, "Right Tag Offset", minval = 1, maxval = 50, group = G_VISUAL,
     tooltip = "Horizontal distance used to place right-side tags away from the last bar.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL,
     tooltip = "Text size used by shelf labels, event labels, and right-side tags.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro liquidity timeframe stack panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = G_PANEL,
     tooltip = "Controls where the panel appears on the chart.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = G_PANEL,
     tooltip = "Switches the panel between a dark AGPro surface and a clean light surface.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL,
     tooltip = "Text size used inside the panel.")

alertBuyStack = input.bool(true, "Alert: HTF Buy Stack", group = G_ALERTS,
     tooltip = "Enables alerts when a sell-side sweep aligns with the lower higher-timeframe liquidity shelf.")
alertSellStack = input.bool(true, "Alert: HTF Sell Stack", group = G_ALERTS,
     tooltip = "Enables alerts when a buy-side sweep aligns with the upper higher-timeframe liquidity shelf.")
alertConflict = input.bool(true, "Alert: Stack Conflict", group = G_ALERTS,
     tooltip = "Enables alerts when the local sweep direction conflicts with the broader higher-timeframe shelf context.")
alertShelfTouch = input.bool(false, "Alert: HTF Shelf Touch", group = G_ALERTS,
     tooltip = "Enables alerts when price enters either higher-timeframe liquidity shelf zone.")

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_clamp(_value, _min, _max) =>
    math.max(_min, math.min(_max, _value))

f_size(_size) =>
    _result = size.normal
    if _size == "Tiny"
        _result := size.tiny
    else if _size == "Small"
        _result := size.small
    else if _size == "Large"
        _result := size.large
    _result

f_panel_pos(_pos) =>
    _result = position.top_right
    if _pos == "Top Left"
        _result := position.top_left
    else if _pos == "Middle Right"
        _result := position.middle_right
    else if _pos == "Middle Left"
        _result := position.middle_left
    else if _pos == "Bottom Right"
        _result := position.bottom_right
    else if _pos == "Bottom Left"
        _result := position.bottom_left
    _result

f_last_pivothigh(_len) =>
    _pivot = ta.pivothigh(high, _len, _len)
    ta.valuewhen(not na(_pivot), _pivot, 0)

f_last_pivotlow(_len) =>
    _pivot = ta.pivotlow(low, _len, _len)
    ta.valuewhen(not na(_pivot), _pivot, 0)

f_fmt(_value) =>
    na(_value) ? "n/a" : str.tostring(_value, format.mintick)

f_score_text(_value) =>
    na(_value) ? "n/a" : str.tostring(math.round(_value))

// Stack Edge display helpers. Color follows the same rounded rate shown
// in the panel text, and is applied only once the sample is sufficient
// (n >= 8); below that the value stays neutral so a small sample never
// implies confidence.
f_edgeText(int _w, int _n) =>
    _n > 0 ? str.tostring(math.round(100.0 * _w / _n)) + "%  (n=" + str.tostring(_n) + ")" : "-  (n=0)"

f_edgeColor(int _w, int _n, color _fb) =>
    _r = _n > 0 ? math.round(100.0 * _w / _n) : 0
    _n >= 8 ? (_r >= 55 ? bullColor : _r >= 40 ? neutralColor : bearColor) : _fb

// --------------------------------------------------
// Timeframe Stack Engine
// --------------------------------------------------
labelSize = f_size(labelSizeInput)
panelSize = f_size(panelFontSizeInput)
atr = ta.atr(atrLen)

htfUpperRaw = request.security(syminfo.tickerid, htfInput, f_last_pivothigh(htfPivotLen), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
htfLowerRaw = request.security(syminfo.tickerid, htfInput, f_last_pivotlow(htfPivotLen), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

fallbackUpper = ta.highest(high, math.max(20, htfPivotLen * 8))
fallbackLower = ta.lowest(low, math.max(20, htfPivotLen * 8))
validHtfShelves = not na(htfUpperRaw) and not na(htfLowerRaw) and htfUpperRaw > htfLowerRaw
htfUpper = validHtfShelves ? htfUpperRaw : fallbackUpper
htfLower = validHtfShelves ? htfLowerRaw : fallbackLower
validShelves = not na(htfUpper) and not na(htfLower) and htfUpper > htfLower

rangeSpan = validShelves ? math.max(htfUpper - htfLower, syminfo.mintick) : math.max(ta.highest(high, 50) - ta.lowest(low, 50), syminfo.mintick)
midShelf = validShelves ? (htfUpper + htfLower) * 0.5 : na
shelfWidth = math.max(syminfo.mintick, math.min(atr * shelfAtrWidth, rangeSpan * maxShelfWidthPct * 0.01))
nearDistance = atr * nearShelfAtr

upperTop = validShelves ? htfUpper + shelfWidth : na
upperBottom = validShelves ? htfUpper - shelfWidth : na
lowerTop = validShelves ? htfLower + shelfWidth : na
lowerBottom = validShelves ? htfLower - shelfWidth : na
compressedShelfLayout = adaptiveLabelLayout and validShelves and atr > rangeSpan * 0.95
shelfUpperLabelText = compressedShelfLayout ? "UPPER | " + f_fmt(htfUpper) : "HTF UPPER SHELF | " + f_fmt(htfUpper)
shelfLowerLabelText = compressedShelfLayout ? "LOWER | " + f_fmt(htfLower) : "HTF LOWER SHELF | " + f_fmt(htfLower)
shelfUpperLabelY = compressedShelfLayout ? upperTop : htfUpper
shelfLowerLabelY = compressedShelfLayout ? lowerBottom : htfLower

nearUpper = validShelves and math.abs(high - htfUpper) <= nearDistance
nearLower = validShelves and math.abs(low - htfLower) <= nearDistance
enteredUpperShelf = validShelves and high >= upperBottom and low <= upperTop
enteredLowerShelf = validShelves and low <= lowerTop and high >= lowerBottom

// --------------------------------------------------
// LTF Sweep Logic
// --------------------------------------------------
ltfPivotHigh = ta.pivothigh(high, ltfPivotLen, ltfPivotLen)
ltfPivotLow = ta.pivotlow(low, ltfPivotLen, ltfPivotLen)

var float ltfHighRef = na
var float ltfLowRef = na

if not na(ltfPivotHigh)
    ltfHighRef := ltfPivotHigh
if not na(ltfPivotLow)
    ltfLowRef := ltfPivotLow

buySideSweep = not na(ltfHighRef[1]) and high > ltfHighRef[1] and close < ltfHighRef[1]
sellSideSweep = not na(ltfLowRef[1]) and low < ltfLowRef[1] and close > ltfLowRef[1]

barRange = math.max(high - low, syminfo.mintick)
upperWickQuality = f_clamp((high - math.max(open, close)) / barRange * 100.0, 0.0, 100.0)
lowerWickQuality = f_clamp((math.min(open, close) - low) / barRange * 100.0, 0.0, 100.0)
reactionQuality = buySideSweep ? upperWickQuality : sellSideSweep ? lowerWickQuality : math.max(upperWickQuality, lowerWickQuality)

closePosition = validShelves ? f_clamp((close - htfLower) / rangeSpan * 100.0, 0.0, 100.0) : 50.0
upperProximity = validShelves ? f_clamp(100.0 - math.abs(close - htfUpper) / rangeSpan * 100.0, 0.0, 100.0) : 50.0
lowerProximity = validShelves ? f_clamp(100.0 - math.abs(close - htfLower) / rangeSpan * 100.0, 0.0, 100.0) : 50.0

buyStack = sellSideSweep and nearLower and reactionQuality >= qualityThreshold
sellStack = buySideSweep and nearUpper and reactionQuality >= qualityThreshold
stackConflict = (buySideSweep and lowerProximity > upperProximity) or (sellSideSweep and upperProximity > lowerProximity)

rawStackScore = 45.0
rawStackScore += validShelves ? 8.0 : -8.0
rawStackScore += (nearUpper or nearLower) ? 14.0 : 0.0
rawStackScore += reactionQuality * 0.24
rawStackScore += (buyStack or sellStack) ? 18.0 : 0.0
rawStackScore -= stackConflict ? 22.0 : 0.0
stackScore = ta.ema(f_clamp(rawStackScore, 0.0, 100.0), scoreSmoothing)

state = buyStack ? 1 : sellStack ? -1 : stackConflict ? 2 : nearLower ? 3 : nearUpper ? -3 : 0
stateText = state == 1 ? "HTF BUY STACK" : state == -1 ? "HTF SELL STACK" : state == 2 ? "STACK CONFLICT" : state == 3 ? "LOWER SHELF" : state == -3 ? "UPPER SHELF" : "NEUTRAL"
stateColor = state == 1 ? bullColor : state == -1 ? bearColor : state == 2 ? neutralColor : state == 3 ? color.rgb(45, 212, 191) : state == -3 ? color.rgb(251, 113, 133) : accentColor
sweepText = buySideSweep ? "Buy-side swept" : sellSideSweep ? "Sell-side swept" : "No active sweep"
biasText = state == 1 ? "Lower shelf reclaim" : state == -1 ? "Upper shelf rejection" : state == 2 ? "Sweep vs stack" : state == 3 ? "Lower shelf pressure" : state == -3 ? "Upper shelf pressure" : "Wait for alignment"
invalidationText = state == 1 ? "Below lower shelf" : state == -1 ? "Above upper shelf" : state == 2 ? "No clean stack" : "Use shelf bounds"

// --------------------------------------------------
// STACK EDGE ENGINE (cumulative, non-repaint)
// Every confirmed stack-aligned sweep opens one tracking episode with
// the entry close, ATR, shelf-based invalidation, and resolution window
// frozen at the event bar. The episode resolves as a HIT when price
// moves the Edge Target distance in the stack direction, and as a MISS
// when the frozen shelf invalidation is closed through first or the
// window expires without contact. Episodes open and resolve on
// confirmed bars only, so the statistic never repaints.
// --------------------------------------------------
buyStackEvent = barstate.isconfirmed and buyStack and not buyStack[1]
sellStackEvent = barstate.isconfirmed and sellStack and not sellStack[1]
conflictEvent = barstate.isconfirmed and stackConflict and not stackConflict[1]
shelfTouchEvent = barstate.isconfirmed and (enteredUpperShelf or enteredLowerShelf) and not (enteredUpperShelf[1] or enteredLowerShelf[1])

var bool  edgeOn = false
var int   edgeDir = 0
var float edgeEntry = na
var float edgeAtr = na
var float edgeInval = na
var int   edgeStart = na
var int   edgeWin = 0
var int   stackWins = 0
var int   stackN = 0

if edgeOn and barstate.isconfirmed
    bool edgeHit = edgeDir == 1 ? high >= edgeEntry + edgeAtr * edgeTargetAtr : low <= edgeEntry - edgeAtr * edgeTargetAtr
    bool edgeLoss = edgeDir == 1 ? close < edgeInval : close > edgeInval
    bool edgeTimeout = not na(edgeStart) and bar_index - edgeStart >= edgeWin
    if edgeHit
        stackN += 1
        stackWins += 1
        edgeOn := false
    else if edgeLoss or edgeTimeout
        stackN += 1
        edgeOn := false

if (buyStackEvent or sellStackEvent) and not na(atr) and atr > 0.0 and validShelves
    if edgeOn
        stackN += 1
        edgeOn := false
    edgeOn := true
    edgeDir := buyStackEvent ? 1 : -1
    edgeEntry := close
    edgeAtr := atr
    edgeInval := buyStackEvent ? lowerBottom - atr * 0.10 : upperTop + atr * 0.10
    edgeStart := bar_index
    edgeWin := edgeWindow

// Next-action line, always consistent with the stack state
actionTxt = "> wait - between shelves"
if state == 1
    actionTxt := "> buy stack live - manage vs lower shelf"
else if state == -1
    actionTxt := "> sell stack live - manage vs upper shelf"
else if state == 2
    actionTxt := "> conflict - stand aside"
else if state == 3
    actionTxt := "> at lower shelf - watch for sweep"
else if state == -3
    actionTxt := "> at upper shelf - watch for sweep"

// --------------------------------------------------
// Visual Structure
// --------------------------------------------------
var box upperBox = na
var box lowerBox = na
var label upperShelfLabel = na
var label lowerShelfLabel = na
var line midLine = na

boxLeft = math.max(bar_index - 180, 0)
boxRight = bar_index + rightTagOffset + 18
boxMidX = int(math.round((boxLeft + boxRight) * 0.5))

if barstate.islast and showShelves and validShelves
    if na(upperBox)
        upperBox := box.new(boxLeft, upperTop, boxRight, upperBottom, bgcolor = color.new(bearColor, 88), border_color = color.new(bearColor, 35))
    else
        box.set_lefttop(upperBox, boxLeft, upperTop)
        box.set_rightbottom(upperBox, boxRight, upperBottom)
        box.set_bgcolor(upperBox, color.new(bearColor, 88))
        box.set_border_color(upperBox, color.new(bearColor, 35))
    if na(lowerBox)
        lowerBox := box.new(boxLeft, lowerTop, boxRight, lowerBottom, bgcolor = color.new(bullColor, 88), border_color = color.new(bullColor, 35))
    else
        box.set_lefttop(lowerBox, boxLeft, lowerTop)
        box.set_rightbottom(lowerBox, boxRight, lowerBottom)
        box.set_bgcolor(lowerBox, color.new(bullColor, 88))
        box.set_border_color(lowerBox, color.new(bullColor, 35))
    if na(upperShelfLabel)
        upperShelfLabel := label.new(boxMidX, shelfUpperLabelY, shelfUpperLabelText, style = label.style_label_center, textcolor = color.white, color = color.new(bearColor, 0), size = labelSize)
    else
        label.set_xy(upperShelfLabel, boxMidX, shelfUpperLabelY)
        label.set_text(upperShelfLabel, shelfUpperLabelText)
        label.set_color(upperShelfLabel, color.new(bearColor, 0))
        label.set_textcolor(upperShelfLabel, color.white)
        label.set_size(upperShelfLabel, labelSize)
    if na(lowerShelfLabel)
        lowerShelfLabel := label.new(boxMidX, shelfLowerLabelY, shelfLowerLabelText, style = label.style_label_center, textcolor = color.white, color = color.new(bullColor, 0), size = labelSize)
    else
        label.set_xy(lowerShelfLabel, boxMidX, shelfLowerLabelY)
        label.set_text(lowerShelfLabel, shelfLowerLabelText)
        label.set_color(lowerShelfLabel, color.new(bullColor, 0))
        label.set_textcolor(lowerShelfLabel, color.white)
        label.set_size(lowerShelfLabel, labelSize)

if barstate.islast and (not showShelves or not validShelves)
    if not na(upperBox)
        box.delete(upperBox)
        upperBox := na
    if not na(lowerBox)
        box.delete(lowerBox)
        lowerBox := na
    if not na(upperShelfLabel)
        label.delete(upperShelfLabel)
        upperShelfLabel := na
    if not na(lowerShelfLabel)
        label.delete(lowerShelfLabel)
        lowerShelfLabel := na

if barstate.islast and showMidline and validShelves
    if na(midLine)
        midLine := line.new(boxLeft, midShelf, boxRight, midShelf, color = color.new(accentColor, 20), width = 2, style = line.style_dotted)
    else
        line.set_xy1(midLine, boxLeft, midShelf)
        line.set_xy2(midLine, boxRight, midShelf)
        line.set_color(midLine, color.new(accentColor, 20))

if barstate.islast and (not showMidline or not validShelves)
    if not na(midLine)
        line.delete(midLine)
        midLine := na

secondaryBuySweep = barstate.isconfirmed and showSweepBadges and buySideSweep and not sellStack and reactionQuality >= qualityThreshold
secondarySellSweep = barstate.isconfirmed and showSweepBadges and sellSideSweep and not buyStack and reactionQuality >= qualityThreshold

if secondaryBuySweep
    label.new(bar_index, high + atr * eventLabelOffsetAtr, "BUY-SIDE SWEEP | Q " + f_score_text(reactionQuality), style = label.style_label_down, textcolor = color.white, color = bearColor, size = labelSize)

if secondarySellSweep
    label.new(bar_index, low - atr * eventLabelOffsetAtr, "SELL-SIDE SWEEP | Q " + f_score_text(reactionQuality), style = label.style_label_up, textcolor = color.white, color = bullColor, size = labelSize)

// --------------------------------------------------
// Event Labels and Right Tags
// --------------------------------------------------
eventNow = barstate.isconfirmed and stackScore >= minimumEventScore and (buyStack or sellStack or (eventLabelMode == "Detailed" and stackConflict))
var int lastEventBar = na
canPrintEvent = na(lastEventBar) or bar_index - lastEventBar >= labelCooldownBars
buyEventY = validShelves ? math.min(low - atr * eventLabelOffsetAtr, lowerBottom - atr * 0.75) : low - atr * eventLabelOffsetAtr
sellEventY = validShelves ? math.max(high + atr * eventLabelOffsetAtr, upperTop + atr * 0.75) : high + atr * eventLabelOffsetAtr
eventY = buyStack ? buyEventY : sellStack ? sellEventY : close
eventText = buyStack ? "HTF BUY STACK | Q " + f_score_text(stackScore) + " | LOWER" : sellStack ? "HTF SELL STACK | Q " + f_score_text(stackScore) + " | UPPER" : "STACK CONFLICT | Q " + f_score_text(stackScore)
eventStyle = buyStack ? label.style_label_up : sellStack ? label.style_label_down : label.style_label_center

if showEventLabels and eventNow and canPrintEvent
    label.new(bar_index, eventY, eventText, style = eventStyle, textcolor = color.white, color = stateColor, size = labelSize)
    lastEventBar := bar_index

var label upperTag = na
var label lowerTag = na
var label stackTag = na

if barstate.islast and showRightTags and validShelves
    if not na(upperTag)
        label.delete(upperTag)
    if not na(lowerTag)
        label.delete(lowerTag)
    if not na(stackTag)
        label.delete(stackTag)
    stackNearShelf = math.abs(close - htfUpper) <= rangeSpan * 0.18 or math.abs(close - htfLower) <= rangeSpan * 0.18
    stackTagY = compressedShelfLayout ? (state == 3 ? lowerBottom - rangeSpan * 0.18 : state == -3 ? upperTop + rangeSpan * 0.18 : midShelf) : stackNearShelf ? midShelf : close
    upperTag := label.new(bar_index + rightTagOffset, htfUpper, "UPPER | " + f_fmt(htfUpper), style = label.style_label_left, textcolor = color.white, color = bearColor, size = labelSize)
    lowerTag := label.new(bar_index + rightTagOffset, htfLower, "LOWER | " + f_fmt(htfLower), style = label.style_label_left, textcolor = color.white, color = bullColor, size = labelSize)
    stackTag := label.new(bar_index + rightTagOffset, stackTagY, "STACK Q " + f_score_text(stackScore), style = label.style_label_left, textcolor = color.white, color = stateColor, size = labelSize)

if barstate.islast and (not showRightTags or not validShelves)
    if not na(upperTag)
        label.delete(upperTag)
        upperTag := na
    if not na(lowerTag)
        label.delete(lowerTag)
        lowerTag := na
    if not na(stackTag)
        label.delete(stackTag)
        stackTag := na

// --------------------------------------------------
// Panel
// --------------------------------------------------
panelBgActive = panelTheme == "Dark" ? panelBg : color.rgb(248, 250, 252)
panelBorderActive = panelTheme == "Dark" ? panelBorder : color.rgb(203, 213, 225)
panelLabelActive = panelTheme == "Dark" ? panelLabelCol : color.rgb(71, 85, 105)
panelValueActive = panelTheme == "Dark" ? panelValueCol : color.rgb(15, 23, 42)

var table panel = na
var string panelPosMemory = ""

if showPanel and (na(panel) or panelPosMemory != panelPositionInput)
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_pos(panelPositionInput), 2, 11, border_width = 1, border_color = panelBorderActive)
    table.cell(panel, 0, 0, "AG Pro Liquidity Timeframe Stack Map", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
    table.merge_cells(panel, 0, 0, 1, 0)
    table.merge_cells(panel, 0, 8, 1, 8)
    table.merge_cells(panel, 0, 10, 1, 10)
    panelPosMemory := panelPositionInput

if showPanel and not na(panel) and barstate.islast
    table.cell(panel, 0, 1, "Stack State", text_color = panelLabelActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 1, 1, stateText, text_color = stateColor, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 0, 2, "Stack Score", text_color = panelLabelActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 1, 2, f_score_text(stackScore), text_color = panelValueActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 0, 3, "HTF Shelves", text_color = panelLabelActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 1, 3, f_fmt(htfUpper) + " / " + f_fmt(htfLower), text_color = panelValueActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 0, 4, "LTF Sweep", text_color = panelLabelActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 1, 4, sweepText, text_color = panelValueActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 0, 5, "Reaction Q", text_color = panelLabelActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 1, 5, f_score_text(reactionQuality), text_color = panelValueActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 0, 6, "Workflow", text_color = panelLabelActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 1, 6, biasText, text_color = panelValueActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 0, 7, "Invalidation", text_color = panelLabelActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 1, 7, invalidationText, text_color = panelValueActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 0, 8, "-- STACK PROOF --", text_color = accentColor, bgcolor = panelBgActive, text_size = panelSize, text_halign = text.align_center)
    table.cell(panel, 0, 9, "Edge Hit Rate", text_color = panelLabelActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 1, 9, f_edgeText(stackWins, stackN), text_color = f_edgeColor(stackWins, stackN, panelLabelActive), bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 0, 10, actionTxt, text_color = accentColor, bgcolor = panelBgActive, text_size = panelSize, text_halign = text.align_left)

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    panelPosMemory := ""

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(alertBuyStack and buyStackEvent, "HTF Buy Stack Alignment", "Liquidity Timeframe Stack Map: sell-side sweep aligned with the lower higher-timeframe liquidity shelf.")
alertcondition(alertSellStack and sellStackEvent, "HTF Sell Stack Alignment", "Liquidity Timeframe Stack Map: buy-side sweep aligned with the upper higher-timeframe liquidity shelf.")
alertcondition(alertConflict and conflictEvent, "Liquidity Stack Conflict", "Liquidity Timeframe Stack Map: local sweep direction is conflicting with the broader higher-timeframe shelf context.")
alertcondition(alertShelfTouch and shelfTouchEvent, "HTF Liquidity Shelf Touch", "Liquidity Timeframe Stack Map: price entered an active higher-timeframe liquidity shelf zone.")
````
