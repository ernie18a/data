# [CT] Adaptive ATR Volatility Targets

- url: https://www.tradingview.com/script/fTGDFIFP-CT-Adaptive-ATR-Volatility-Targets/
- type: indicator
- pine_id: PUB;451d1d56798246f58e6a1796fb0dce8b
- version: 1.0

## Description

[b][CT] Adaptive ATR Volatility Targets[/b] is a volatility-based target tool designed to help traders identify projected expansion levels above and below a chosen anchor price. The indicator uses either ADR, Average Daily Range based on high minus low, or ATR, Average True Range, to calculate dynamic price targets from the selected volatility timeframe. This allows traders to see where price may reasonably expand during the current session, day, week, or chosen higher-timeframe period.

The center anchor can be based on the current open, the previous close, or HLC3, giving traders flexibility in how they want to frame the active volatility range. From that anchor, the indicator plots target levels in quarter-volatility increments, including 0.25, 0.50, 0.75, 1.00, and beyond. These levels can help traders identify early expansion zones, major target zones, possible profit-taking areas, and locations where price may begin to slow, reject, or become extended.

A key feature of this indicator is the Golden Target level at 0.618. This level is included because markets often react around proportional expansion areas before reaching full volatility targets. The 0.618 level can be useful for partial profits, trend continuation confirmation, or watching for rejection when price has not yet reached the full 1.0 volatility target.

The indicator also includes visual zone fills between the major levels. These zones help traders quickly read whether price is still near the anchor, beginning to expand, approaching a major volatility target, or trading in an extended area. The upper zones represent bullish expansion targets, while the lower zones represent bearish expansion targets. The center line acts as the reference point for the active volatility range.

The added history feature allows traders to keep previous volatility target sets on the chart. This is useful for studying how price reacted to prior ATR or ADR levels, identifying repeated respect or rejection zones, and reviewing whether previous targets acted as support, resistance, liquidity areas, or exhaustion points. Historical target sets can be faded so the current target levels remain the primary focus while still giving context from prior periods.
This tool is best used as a target and context indicator, not as a standalone buy or sell signal. A trader may use it to plan profit targets after a confirmed trend entry, measure how far price has already expanded from the session anchor, identify when price is becoming stretched, or determine whether there is still room for continuation. In a strong bullish move, upper volatility targets can act as upside objectives. In a strong bearish move, lower volatility targets can act as downside objectives. In a range-bound market, rejection around the 0.50, 0.618, or 1.0 levels may warn that price is losing momentum.

For best results, this indicator should be combined with trend direction, volume, market structure, VWAP, opening range levels, or momentum confirmation. When price is expanding toward a volatility target with strong trend confirmation, the level can be used as a logical profit objective. When price reaches a target with weakening momentum, divergence, rejection candles, or heavy opposing volume, the level may become a warning area for profit-taking or reversal risk.

[b][CT] Adaptive ATR Volatility Targets[/b] is designed to give traders a clean volatility roadmap. It helps answer three important questions: where is price starting from, how far has price expanded, and where are the next reasonable upside or downside targets based on current volatility.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("[CT] Adaptive ATR Volatility Targets", shorttitle="[CT] ATR Targets", overlay=true, max_labels_count=500, max_lines_count=500)

// --- Constants ---
color NEUTRAL_GRAY = #787b86

// --- Types ---
type HtfData
    float atr
    float adr
    float open
    float prevClose

// --- Inputs ---
groupAtr = "Volatility Engine"
volType  = input.string("ADR (High-Low)", "Volatility Type", options=["ADR (High-Low)", "ATR (True Range)"], group=groupAtr)
atrLen   = input.int(14, "Average Length", minval=1, group=groupAtr)
atrTfm   = input.timeframe("D", "Volatility Timeframe", group=groupAtr)

groupLevels = "Target Configuration"
anchor    = input.string("Open", "Center Anchor", options=["Open", "Previous Close", "HLC3"], group=groupLevels)
numGrids  = 8
showFib   = input.bool(true, "Show Golden Target (0.618)", group=groupLevels)

groupHistory = "History Settings"
showHistory       = input.bool(false, "Show Historical Target Sets", group=groupHistory)
historyPeriods    = input.int(5, "Historical Periods to Keep", minval=0, maxval=20, group=groupHistory)
showHistoryLabels = input.bool(false, "Show Historical Labels", group=groupHistory)
historyTransp     = input.int(65, "Historical Line Transparency", minval=0, maxval=100, group=groupHistory)

groupStyle = "Visual Settings"
centerCol  = input.color(color.new(color.white, 20), "Center Line Color", group=groupStyle)
upperCol   = input.color(color.new(#f23645, 20), "Upper Target Color", group=groupStyle)
lowerCol   = input.color(color.new(#089981, 20), "Lower Target Color", group=groupStyle)
fibCol     = input.color(color.new(color.orange, 20), "Golden Target Color", group=groupStyle)

majorWidth = input.int(2, "Major Line Width (0.5 steps)", minval=1, group=groupStyle)
minorWidth = input.int(1, "Minor Line Width (0.25 steps)", minval=1, group=groupStyle)

showLabels = input.bool(true, "Show Current Price Labels", group=groupStyle)
useFills   = input.bool(true, "Show Major Zones (Fills)", group=groupStyle)
lblOffset  = input.int(5, "Label Offset", minval=0, group=groupStyle)
lblSizeInp = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=groupStyle)

// --- Label Size Mapping ---
labelSize =
     lblSizeInp == "Tiny"   ? size.tiny  :
     lblSizeInp == "Small"  ? size.small :
     lblSizeInp == "Normal" ? size.normal:
     lblSizeInp == "Large"  ? size.large :
                              size.huge

// --- Calculations ---
getHtf() =>
    tr_val  = ta.tr
    dr_val  = high - low
    atr_out = ta.sma(tr_val, atrLen)
    adr_out = ta.sma(dr_val, atrLen)
    HtfData.new(atr_out, adr_out, open, close[1])

htf = request.security(syminfo.tickerid, atrTfm, getHtf(), lookahead=barmerge.lookahead_on)

volValue = volType == "ADR (High-Low)" ? htf.adr : htf.atr
center   = anchor == "Open" ? htf.open : anchor == "Previous Close" ? htf.prevClose : (high[1] + low[1] + close[1]) / 3

// --- Persistence ---
var line[]  currentLines  = array.new_line()
var label[] currentLabels = array.new_label()
var color[] currentColors = array.new_color()

var line[]  historyLines  = array.new_line()
var label[] historyLabels = array.new_label()

// --- Drawing Level Logic ---
addLevel(mult, txt, col, width, isMajor) =>
    price = center + (volValue * mult)
    ln = line.new(
         bar_index,
         price,
         bar_index + lblOffset,
         price,
         color=col,
         style=isMajor ? line.style_solid : line.style_dashed,
         width=width)

    array.push(currentLines, ln)
    array.push(currentColors, col)

    if showLabels
        lb = label.new(
             bar_index + lblOffset,
             price,
             txt + " (" + str.tostring(math.round_to_mintick(price)) + ")",
             color=col,
             style=label.style_label_left,
             textcolor=color.white,
             size=labelSize)
        array.push(currentLabels, lb)

// --- Helper: delete current set ---
deleteCurrentSet() =>
    if array.size(currentLines) > 0
        for i = 0 to array.size(currentLines) - 1
            line.delete(array.get(currentLines, i))

    if array.size(currentLabels) > 0
        for i = 0 to array.size(currentLabels) - 1
            label.delete(array.get(currentLabels, i))

    array.clear(currentLines)
    array.clear(currentLabels)
    array.clear(currentColors)

// --- Helper: delete historical set ---
deleteHistorySet() =>
    if array.size(historyLines) > 0
        for i = 0 to array.size(historyLines) - 1
            line.delete(array.get(historyLines, i))

    if array.size(historyLabels) > 0
        for i = 0 to array.size(historyLabels) - 1
            label.delete(array.get(historyLabels, i))

    array.clear(historyLines)
    array.clear(historyLabels)

// --- Helper: freeze current lines into history ---
freezeCurrentSet() =>
    if array.size(currentLines) > 0
        for i = 0 to array.size(currentLines) - 1
            ln = array.get(currentLines, i)
            col = array.get(currentColors, i)
            line.set_x2(ln, bar_index - 1)
            line.set_color(ln, color.new(col, historyTransp))
            array.push(historyLines, ln)

    if array.size(currentLabels) > 0
        for i = 0 to array.size(currentLabels) - 1
            lb = array.get(currentLabels, i)
            if showHistoryLabels
                label.set_x(lb, bar_index - 1)
                array.push(historyLabels, lb)
            else
                label.delete(lb)

    array.clear(currentLines)
    array.clear(currentLabels)
    array.clear(currentColors)

// --- Helper: prune old history ---
pruneHistory() =>
    linesPerSet = 1 + numGrids * 2 + (showFib ? 2 : 0)
    maxHistoryLines = historyPeriods * linesPerSet

    while array.size(historyLines) > maxHistoryLines
        oldLine = array.shift(historyLines)
        line.delete(oldLine)

    while array.size(historyLabels) > maxHistoryLines
        oldLabel = array.shift(historyLabels)
        label.delete(oldLabel)

// --- Refresh on HTF bar ---
newPeriod = timeframe.change(atrTfm) or barstate.isfirst

if newPeriod
    if not barstate.isfirst
        if showHistory and historyPeriods > 0
            freezeCurrentSet()
            pruneHistory()
        else
            deleteCurrentSet()
            deleteHistorySet()

    if barstate.isfirst
        deleteCurrentSet()
        if not showHistory
            deleteHistorySet()

    // Center Level
    addLevel(0.0, "0.0 Vol (" + anchor + ")", centerCol, majorWidth, true)

    // Grid at 0.25 intervals, 8 levels per side
    for i = 1 to numGrids
        m = i * 0.25
        isMajor = m % 0.5 == 0
        width   = isMajor ? majorWidth : minorWidth
        addLevel(m, str.tostring(m) + " Vol", upperCol, width, isMajor)
        addLevel(-m, str.tostring(m) + " Vol", lowerCol, width, isMajor)

    if showFib
        addLevel(0.618, "0.618 Golden", fibCol, minorWidth, false)
        addLevel(-0.618, "0.618 Golden", fibCol, minorWidth, false)

// --- If history is turned off, remove old history ---
if not showHistory and array.size(historyLines) > 0
    deleteHistorySet()

// --- Update current endpoint only ---
if array.size(currentLines) > 0
    for i = 0 to array.size(currentLines) - 1
        ln = array.get(currentLines, i)
        line.set_x2(ln, bar_index + lblOffset)

if array.size(currentLabels) > 0
    for i = 0 to array.size(currentLabels) - 1
        lb = array.get(currentLabels, i)
        label.set_x(lb, bar_index + lblOffset)

// --- Visual Zones, current active period ---
p_top = plot(useFills ? center + volValue : na, "Top (1.0)", color.new(upperCol, 100))
p_mid = plot(useFills ? center + volValue * 0.5 : na, "Mid Top (0.5)", color.new(upperCol, 100))
p_cnt = plot(useFills ? center : na, "Center (0.0)", color.new(centerCol, 100))
p_low = plot(useFills ? center - volValue * 0.5 : na, "Mid Bot (0.5)", color.new(lowerCol, 100))
p_bot = plot(useFills ? center - volValue : na, "Bottom (1.0)", color.new(lowerCol, 100))

fill(p_top, p_mid, color.new(upperCol, 90), "Major Upper Target Zone")
fill(p_low, p_bot, color.new(lowerCol, 90), "Major Lower Target Zone")
fill(p_mid, p_cnt, color.new(upperCol, 95), "Upper Initial Expansion")
fill(p_low, p_cnt, color.new(lowerCol, 95), "Lower Initial Expansion")

plot(center, "Anchor Price", color.new(centerCol, 50), 1, plot.style_linebr)
````
