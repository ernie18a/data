# Voids Finder By Engel Futures

- url: https://www.tradingview.com/script/GXSMLJnz-Voids-Finder-By-Engel-Futures/
- type: indicator
- pine_id: PUB;de7cd8945144402884d69a2e505c22dc
- version: 1.0

## Description

Voids Finder By Engel Futures

A clean liquidity void indicator built to detect and mark real market voids, not standard FVGs.

This tool identifies body-to-body price gaps where price leaves a clean imbalance between two candles. It separates voids into different categories so traders can quickly distinguish between cleaner voids and lower-probability wick-based voids.

## Source Code

````pine
//@version=6
indicator("Voids Finder By Engel Futures", overlay=true, max_boxes_count=500)

// -----------------------------------------------------------------------------
// Settings
// -----------------------------------------------------------------------------
const string G_GENERAL = "General"
const string G_PURE = "Pure Voids"
const string G_WICK = "Low-Prob / Wick Voids"
const string G_HTF = "NWOG / NDOG"
const string G_TABLE = "Counter Table"

lookbackDays = input.int(7, "Lookback Days", minval=1, maxval=60, group=G_GENERAL)
maxActive = input.int(240, "Max Active Voids", minval=10, maxval=500, group=G_GENERAL)
noWickTicks = input.int(1, "No-Wick Tolerance (Ticks)", minval=0, maxval=10, group=G_GENERAL)

showPure = input.bool(true, "Show Pure Voids", group=G_PURE)
pureFill = input.color(color.new(color.gray, 82), "Fill", group=G_PURE)
pureBorder = input.color(color.new(color.gray, 0), "Border", group=G_PURE)
pureStyle = input.string("Solid", "Border Style", options=["Solid", "Dashed", "Dotted"], group=G_PURE)
pureWidth = input.int(1, "Border Width", minval=1, maxval=4, group=G_PURE)
pureLabels = input.bool(false, "Show Label", group=G_PURE)
pureTextColor = input.color(color.new(color.white, 0), "Label Color", group=G_PURE)

showWick = input.bool(true, "Show Low-Prob / Wick Voids", group=G_WICK)
wickFill = input.color(color.new(color.yellow, 82), "Fill", group=G_WICK)
wickBorder = input.color(color.new(color.yellow, 0), "Border", group=G_WICK)
wickStyle = input.string("Dashed", "Border Style", options=["Solid", "Dashed", "Dotted"], group=G_WICK)
wickWidth = input.int(1, "Border Width", minval=1, maxval=4, group=G_WICK)
wickLabels = input.bool(false, "Show Label", group=G_WICK)
wickTextColor = input.color(color.new(color.yellow, 0), "Label Color", group=G_WICK)

showHTF = input.bool(true, "Show NWOG / NDOG", group=G_HTF)
showNWOG = input.bool(true, "Show NWOG", group=G_HTF)
showNDOG = input.bool(true, "Show NDOG", group=G_HTF)
htfFill = input.color(color.new(color.aqua, 82), "Fill", group=G_HTF)
htfBorder = input.color(color.new(color.aqua, 0), "Border", group=G_HTF)
htfStyle = input.string("Dotted", "Border Style", options=["Solid", "Dashed", "Dotted"], group=G_HTF)
htfWidth = input.int(1, "Border Width", minval=1, maxval=4, group=G_HTF)
htfLabels = input.bool(true, "Show Label", group=G_HTF)
htfTextColor = input.color(color.new(color.aqua, 0), "Label Color", group=G_HTF)

showTable = input.bool(true, "Show Counter Table", group=G_TABLE)
tablePos = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=G_TABLE)

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------
f_style(string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

f_pos(string s) =>
    s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : position.top_right

f_tol() =>
    syminfo.mintick * noWickTicks

f_noWick(float wickEdge, float bodyEdge) =>
    math.abs(wickEdge - bodyEdge) <= f_tol()

f_hasUpperWick(float highVal, float bodyTop) =>
    highVal > bodyTop + f_tol()

f_hasLowerWick(float lowVal, float bodyBot) =>
    lowVal < bodyBot - f_tol()

chartTfMs() =>
    int(timeframe.in_seconds(timeframe.period) * 1000)

f_draw(box[] boxes, bool[] closeAboveArr, int[] bornTimeArr, int bornTime, float top, float bot, bool closeAbove, color fillColor, color borderColor, string borderStyle, int borderWidth, bool showLabel, string labelText, color textColor) =>
    bool made = false

    if top > bot
        box b = box.new(
             left=bornTime,
             top=top,
             right=bornTime + chartTfMs(),
             bottom=bot,
             xloc=xloc.bar_time,
             extend=extend.right,
             bgcolor=fillColor,
             border_color=borderColor,
             border_style=f_style(borderStyle),
             border_width=borderWidth)

        if showLabel
            box.set_text(b, labelText)
            box.set_text_color(b, textColor)
            box.set_text_size(b, size.tiny)
            box.set_text_halign(b, text.align_left)
            box.set_text_valign(b, text.align_center)

        array.push(boxes, b)
        array.push(closeAboveArr, closeAbove)
        array.push(bornTimeArr, bornTime)
        made := true

    made

f_clear(box[] boxes, bool[] closeAboveArr, int[] bornTimeArr) =>
    int i = array.size(boxes) - 1

    while i >= 0
        box b = array.get(boxes, i)
        box.delete(b)

        array.remove(boxes, i)
        array.remove(closeAboveArr, i)
        array.remove(bornTimeArr, i)

        i -= 1

    true

f_sweep(box[] boxes, bool[] closeAboveArr, int[] bornTimeArr, int cutoffTime) =>
    int i = array.size(boxes) - 1

    while i >= 0
        box b = array.get(boxes, i)
        bool closeAbove = array.get(closeAboveArr, i)
        int bornTime = array.get(bornTimeArr, i)

        float top = box.get_top(b)
        float bot = box.get_bottom(b)

        bool expired = bornTime < cutoffTime

        // Internal mitigation logic:
        // closeAbove true  = remove after tap + close above the void.
        // closeAbove false = remove after tap + close below the void.
        bool mitigated = closeAbove ? (high >= bot and close > top) : (low <= top and close < bot)

        if expired or mitigated
            box.delete(b)
            array.remove(boxes, i)
            array.remove(closeAboveArr, i)
            array.remove(bornTimeArr, i)

        i -= 1

    true

f_limit(box[] boxes, bool[] closeAboveArr, int[] bornTimeArr, int maxCount) =>
    while array.size(boxes) > maxCount
        box b = array.shift(boxes)
        box.delete(b)

        array.shift(closeAboveArr)
        array.shift(bornTimeArr)

    true

// -----------------------------------------------------------------------------
// Storage
// -----------------------------------------------------------------------------
var box[] pureBoxes = array.new<box>()
var bool[] pureCloseAbove = array.new<bool>()
var int[] pureBornTime = array.new<int>()

var box[] wickBoxes = array.new<box>()
var bool[] wickCloseAbove = array.new<bool>()
var int[] wickBornTime = array.new<int>()

var box[] htfBoxes = array.new<box>()
var bool[] htfCloseAbove = array.new<bool>()
var int[] htfBornTime = array.new<int>()

var int totalPure = 0
var int totalWick = 0
var int totalHTF = 0

var table stats = na

// -----------------------------------------------------------------------------
// Runtime values
// -----------------------------------------------------------------------------
bool supportedTf = timeframe.isseconds or timeframe.isminutes

int cutoffTime = timenow - lookbackDays * 24 * 60 * 60 * 1000

bool inLookback = time >= cutoffTime
bool hasPrev = bar_index > 0

bool newWeek = supportedTf and hasPrev and time("W") != time("W")[1]
bool newDay = supportedTf and hasPrev and time("D") != time("D")[1] and not newWeek

// -----------------------------------------------------------------------------
// Main
// -----------------------------------------------------------------------------
if not supportedTf
    f_clear(pureBoxes, pureCloseAbove, pureBornTime)
    f_clear(wickBoxes, wickCloseAbove, wickBornTime)
    f_clear(htfBoxes, htfCloseAbove, htfBornTime)

if supportedTf and barstate.isconfirmed
    f_sweep(pureBoxes, pureCloseAbove, pureBornTime, cutoffTime)
    f_sweep(wickBoxes, wickCloseAbove, wickBornTime, cutoffTime)
    f_sweep(htfBoxes, htfCloseAbove, htfBornTime, cutoffTime)

    bool madeHTF = false

    // -------------------------------------------------------------------------
    // NWOG / NDOG
    // -------------------------------------------------------------------------
    if inLookback and showHTF and hasPrev
        if showNWOG and newWeek and open > close[1]
            if f_draw(htfBoxes, htfCloseAbove, htfBornTime, time, open, close[1], false, htfFill, htfBorder, htfStyle, htfWidth, htfLabels, "NWOG", htfTextColor)
                totalHTF += 1
                madeHTF := true

        if showNWOG and newWeek and open < close[1]
            if f_draw(htfBoxes, htfCloseAbove, htfBornTime, time, close[1], open, true, htfFill, htfBorder, htfStyle, htfWidth, htfLabels, "NWOG", htfTextColor)
                totalHTF += 1
                madeHTF := true

        if showNDOG and newDay and open > close[1]
            if f_draw(htfBoxes, htfCloseAbove, htfBornTime, time, open, close[1], false, htfFill, htfBorder, htfStyle, htfWidth, htfLabels, "NDOG", htfTextColor)
                totalHTF += 1
                madeHTF := true

        if showNDOG and newDay and open < close[1]
            if f_draw(htfBoxes, htfCloseAbove, htfBornTime, time, close[1], open, true, htfFill, htfBorder, htfStyle, htfWidth, htfLabels, "NDOG", htfTextColor)
                totalHTF += 1
                madeHTF := true

    // -------------------------------------------------------------------------
    // LTF LIQUIDITY VOIDS - CLEAN BODY-GAP LOGIC
    // -------------------------------------------------------------------------
    if inLookback and hasPrev and not madeHTF
        // Candle 1 = previous candle
        float c1High = high[1]
        float c1Low = low[1]
        float c1BodyTop = math.max(open[1], close[1])
        float c1BodyBot = math.min(open[1], close[1])

        // Candle 2 = current candle
        float c2High = high
        float c2Low = low
        float c2BodyTop = math.max(open, close)
        float c2BodyBot = math.min(open, close)

        // Candle 1 wick state
        bool c1NoUpper = f_noWick(c1High, c1BodyTop)
        bool c1NoLower = f_noWick(c1Low, c1BodyBot)
        bool c1HasUpperWick = f_hasUpperWick(c1High, c1BodyTop)
        bool c1HasLowerWick = f_hasLowerWick(c1Low, c1BodyBot)

        // Candle 2 must have no wick on the void side
        bool c2NoLower = f_noWick(c2Low, c2BodyBot)
        bool c2NoUpper = f_noWick(c2High, c2BodyTop)

        // ---------------------------------------------------------------------
        // BULLISH VOID
        //
        // Candle 1 = lower / older candle.
        // Candle 2 = higher / displacement candle.
        // Box = candle 1 body top -> candle 2 body bottom.
        //
        // Pure:
        // Candle 1 has no upper wick.
        //
        // Low-prob:
        // Candle 1 has upper wick.
        // The wick is allowed to pass through or beyond the gap.
        // ---------------------------------------------------------------------
        float bullVoidTop = c2BodyBot
        float bullVoidBot = c1BodyTop

        bool bullishBodyGap = bullVoidTop > bullVoidBot

        if bullishBodyGap and c2NoLower
            if showPure and c1NoUpper
                if f_draw(pureBoxes, pureCloseAbove, pureBornTime, time[1], bullVoidTop, bullVoidBot, false, pureFill, pureBorder, pureStyle, pureWidth, pureLabels, "VOID", pureTextColor)
                    totalPure += 1

            if showWick and c1HasUpperWick
                if f_draw(wickBoxes, wickCloseAbove, wickBornTime, time[1], bullVoidTop, bullVoidBot, false, wickFill, wickBorder, wickStyle, wickWidth, wickLabels, "LOW-PROB VOID", wickTextColor)
                    totalWick += 1

        // ---------------------------------------------------------------------
        // BEARISH VOID
        //
        // Candle 1 = higher / older candle.
        // Candle 2 = lower / displacement candle.
        // Box = candle 2 body top -> candle 1 body bottom.
        //
        // Pure:
        // Candle 1 has no lower wick.
        //
        // Low-prob:
        // Candle 1 has lower wick.
        // The wick is allowed to pass through or beyond the gap.
        // ---------------------------------------------------------------------
        float bearVoidTop = c1BodyBot
        float bearVoidBot = c2BodyTop

        bool bearishBodyGap = bearVoidTop > bearVoidBot

        if bearishBodyGap and c2NoUpper
            if showPure and c1NoLower
                if f_draw(pureBoxes, pureCloseAbove, pureBornTime, time[1], bearVoidTop, bearVoidBot, true, pureFill, pureBorder, pureStyle, pureWidth, pureLabels, "VOID", pureTextColor)
                    totalPure += 1

            if showWick and c1HasLowerWick
                if f_draw(wickBoxes, wickCloseAbove, wickBornTime, time[1], bearVoidTop, bearVoidBot, true, wickFill, wickBorder, wickStyle, wickWidth, wickLabels, "LOW-PROB VOID", wickTextColor)
                    totalWick += 1

    f_limit(pureBoxes, pureCloseAbove, pureBornTime, maxActive)
    f_limit(wickBoxes, wickCloseAbove, wickBornTime, maxActive)
    f_limit(htfBoxes, htfCloseAbove, htfBornTime, maxActive)

if not showPure
    f_clear(pureBoxes, pureCloseAbove, pureBornTime)

if not showWick
    f_clear(wickBoxes, wickCloseAbove, wickBornTime)

if not showHTF
    f_clear(htfBoxes, htfCloseAbove, htfBornTime)

// -----------------------------------------------------------------------------
// Counter table
// -----------------------------------------------------------------------------
if barstate.islast
    if not showTable
        if not na(stats)
            table.delete(stats)
            stats := na
    else
        if na(stats)
            stats := table.new(
                 f_pos(tablePos),
                 3,
                 5,
                 bgcolor=color.new(color.black, 55),
                 border_color=color.new(color.gray, 50),
                 border_width=1,
                 frame_color=color.new(color.gray, 30),
                 frame_width=1)

        table.set_position(stats, f_pos(tablePos))

        int activePure = array.size(pureBoxes)
        int activeWick = array.size(wickBoxes)
        int activeHTF = array.size(htfBoxes)

        int activeAll = activePure + activeWick + activeHTF
        int totalAll = totalPure + totalWick + totalHTF

        table.cell(stats, 0, 0, "Category", text_color=color.gray, text_size=size.small, bgcolor=color.new(color.black, 30))
        table.cell(stats, 1, 0, "Active", text_color=color.gray, text_size=size.small, bgcolor=color.new(color.black, 30))
        table.cell(stats, 2, 0, "Found", text_color=color.gray, text_size=size.small, bgcolor=color.new(color.black, 30))

        table.cell(stats, 0, 1, "Pure", text_color=pureBorder, text_size=size.small)
        table.cell(stats, 1, 1, str.tostring(activePure), text_color=pureBorder, text_size=size.small)
        table.cell(stats, 2, 1, str.tostring(totalPure), text_color=pureBorder, text_size=size.small)

        table.cell(stats, 0, 2, "Low-Prob", text_color=wickBorder, text_size=size.small)
        table.cell(stats, 1, 2, str.tostring(activeWick), text_color=wickBorder, text_size=size.small)
        table.cell(stats, 2, 2, str.tostring(totalWick), text_color=wickBorder, text_size=size.small)

        table.cell(stats, 0, 3, "NWOG / NDOG", text_color=htfBorder, text_size=size.small)
        table.cell(stats, 1, 3, str.tostring(activeHTF), text_color=htfBorder, text_size=size.small)
        table.cell(stats, 2, 3, str.tostring(totalHTF), text_color=htfBorder, text_size=size.small)

        table.cell(stats, 0, 4, "ALL", text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 70))
        table.cell(stats, 1, 4, str.tostring(activeAll), text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 70))
        table.cell(stats, 2, 4, str.tostring(totalAll), text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 70))
````
