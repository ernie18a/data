# MSnR Double Breakout Failed Level

- url: https://www.tradingview.com/script/cMDkJBEy-MSnR-Double-Breakout-Failed-Level/
- type: indicator
- pine_id: PUB;3284d5ef56a047aea7472d37a6674158
- version: 1.0

## Description

OVERVIEW

A Double Breakout level is where a staircase of turning points was run out. This script shows the ones that did not hold.

When a staircase of same-side reversals is finally broken, the innermost step is left behind as a level - support below price on the bullish side, resistance above it on the bearish side. Many of those levels hold. Some do not: price comes back, closes straight through, and the level that was support has become resistance, or the other way round.

This script finds every Double Breakout level, watches it, and draws it only on the candle it fails. A clean chart shows nothing until the market has given a level up. What it does show is a list of levels that changed sides, each one marked at the candle that broke it.

THE TWO BUILDING BLOCKS

A candle is green when close is above open, red when close is below. A doji, where they are equal, is neither and takes no part.

A Level    a green candle followed immediately by a red one. The GREEN candle's CLOSE is the level.

V Level    a red candle followed immediately by a green one. The RED candle's CLOSE is the level.

DOUBLE BREAKOUT

Two same-side levels are held as a rolling pair. On the A side that is a descending pair - A1 above, A2 below. When a candle CLOSES above A1, the staircase has been run out and A2, the innermost step, becomes a DBO A level - a bullish level, sitting below price.

The V side is the exact mirror: an ascending pair, V1 below and V2 above, a candle closing below V1, and V2 becomes a DBO V level - a bearish level, sitting above price.

It is always a DOUBLE. When a new same-side level appears while the pair is still waiting:

the new level did NOT break the inner step   ->   the pair SLIDES one along the new level DID break the inner step       ->   the pair RESTARTS from that level

The breakout is always checked before any new level is. This part of the script is the same detection as the Double Breakout logic it is built on, unchanged.

DOUBLE BREAKOUT FAILED

A DBO A level is below price at the moment it is confirmed: the confirming candle closed above A1, and A1 is above A2. For the level to be broken, price has to come back down through it, and the candle that does that is a red one.

DBO A Failed   a RED candle CLOSES below the DBO A level DBO V Failed   a GREEN candle CLOSES above the DBO V level

------ A2 ----------------------      DBO A level, support red candle closes below it ------ A2 ----------------------      DBO A Failed, now resistance

The test starts on the candle after the one that confirmed the Double Breakout, so a level can never be failed by the candle that created it. A wick through the level does not count. A doji does not count. A green candle that closes below a DBO A level does not count either - the failure has to be made by a candle moving in the direction of the break.

A level fails once. After that it stays a failed level whatever price does next; it is never switched back.

WHAT MAKES THIS DIFFERENT

1. It shows the levels that gave way, not the ones that formed.

A Double Breakout level on its own is not drawn at all. Only the failure puts something on the chart, so every line here is a level that price has already closed through.

2. The failure is a strict event.

It needs a closed candle, on the far side of the level, of the colour of the move. Wicks, dojis and closes by a candle pointing the other way are all ignored, so a quick spike through a level does not mark it as failed.

3. Why this is a separate script.

This is built on the same Double Breakout detection as the free "MSnR Double Breakout Level" script, but it answers a different question. That script draws Double Breakout levels and the DBO to DBO chains between them. This one draws none of those: it watches every Double Breakout level and shows only the ones a single candle has closed through, with that candle marked. The original stays as it is for anyone who uses it to see the levels themselves; this one is for anyone who wants only the levels that changed sides.

4. Each side is judged on its own.

A failed DBO A and a failed DBO V are tracked and counted separately, and either kind can be switched off without affecting the other.

READING THE CHART

Red line, "DBO A Failed"     a bullish level that was closed through to the downside, label above the candle that broke it Green line, "DBO V Failed"   a bearish level that was closed through to the upside, label below the candle that broke it

Every line starts at the candle the level was read from - the A2 or V2 candle - and runs to the right, so it shows how long the level stood before it failed and where it sits now. The label is placed on the candle that broke the level, so both ends of the story are on the chart.

Only the most recent failures are drawn, so the chart stays readable. The corner table counts every Double Breakout level currently inside the scan window:

DBO Found       every DBO A and DBO V level in the window Failed          the ones that have failed - the only ones drawn Still Holding   the ones that have not failed yet - not drawn

Found is always Failed plus Still Holding. If the Failed count is higher than the lines you can see, the display limit is doing its job.

SETTINGS

Double Breakout
- Scan Length: how far back the search reaches. A pair that has been waiting longer than this is abandoned. A Double Breakout level is watched for a failure only while the candle it came from is inside this window, and a failed level is dropped once that candle is older than this.
- Max Levels Shown: how many of the most recent failures are drawn. Switching a type off frees its places for the other.

Failed Level Types
- DBO A Failed and DBO V Failed, one switch each.

Level Style
- A colour for each type, line width, and whether failed levels extend to the right edge. With extending off, a level stops on the candle that broke it.

Labels
- Show Labels, Label Size, and Label Distance from Candle as a percentage of ATR(14), measured from the high or low of the candle that broke the level.

Summary Table
- Show, position and size of the corner table.

ALERTS

Two alert conditions:

DBO A Failed   a red candle closed below a DBO A level DBO V Failed   a green candle closed above a DBO V level

Each message carries the event, the symbol, the timeframe and the closing price. The same events are also sent through the alert function, where the message also carries the price of the level that failed, so the "Any alert() function call" alert type can deliver both through one alert.

Every alert is evaluated only after a candle has fully closed.

REPAINTING

- The whole engine runs once per closed candle. Price moving inside an open candle cannot create, fail or remove a level, and cannot make an alert appear and then disappear.
- Both building blocks need a candle after them to exist, and a failure needs a closed candle beyond the level, so nothing is ever read from a candle still forming.
- A failed level, once drawn, does not move. What changes over time is which levels are on the chart: a newer failure can push the oldest one past Max Levels Shown, and a level is removed once the candle it came from leaves the scan window.
- Nothing is read from a higher timeframe.

When you create an alert, TradingView may show a caution that the indicator can repaint. Choosing "Once Per Bar Close" when creating the alert is recommended.

NOTES AND LIMITATIONS

- Failed levels are infrequent by design. A Double Breakout has to complete first, and then a candle of the right colour has to close through its level inside the scan window. Long stretches with nothing new are normal.
- Scan Length decides which levels are watched at all, so changing it changes what is found, not only what is drawn. A level whose candle is near the edge of the window has little time left to fail before it stops being watched. Max Levels Shown only changes what is drawn.
- The DBO to DBO chains of the original Double Breakout logic are not used here.
- An internal cap of 120 stored levels keeps the drawing count inside TradingView's limits. On a very long history the oldest are dropped.
- Use a standard candle chart. Heikin Ashi, Renko and other synthetic chart types change the candle colours and closes the detection relies on.
- Detection is purely structural. It reports where these levels formed and where they were broken, and nothing more. It does not rank levels by quality or produce entries, targets or stops.

HOW TO USE IT

A failed Double Breakout level marks a place where the market first left in one direction and then came back through. Traders commonly watch these for:

- A reaction on a return to the level from the other side, since the former support is now overhead resistance, or the former resistance is now support underneath
- Context about the move that broke it: a level given up soon after it formed tells a different story from one that held for a long time before failing
- Confirmation against their own wider read of the market, where a failure in the direction of the larger move carries more weight than one against it

These are reference areas, not entry signals on their own. Use them alongside your own support and resistance mapping, your own entry method and proper risk management.

DISCLAIMER

This indicator is a pattern detection tool. It is not financial advice and it makes no claim about profitability. Trading involves risk. Always apply your own analysis and risk management.

## Source Code

````pine
//@version=6
indicator(
     title            = "MSnR Double Breakout Failed Level",
     overlay          = true,
     max_lines_count  = 500,
     max_labels_count = 500,
     max_bars_back    = 500
     )

// ==========================================================
// MSnR Double Breakout Failed Level
//
// A Double Breakout level is where a staircase of turning points was run out.
// This script shows the ones that did NOT hold: the level price came back
// through, and what was support is now resistance - or the other way round.
//
// THE TWO BUILDING BLOCKS
//
//   A Level   a green candle followed by a red one. The green candle's CLOSE is
//             the level. Buyers pushed, sellers took it straight back.
//   V Level   a red candle followed by a green one. The red candle's CLOSE is
//             the level. Sellers pushed, buyers took it straight back.
//
// DOUBLE BREAKOUT
//
// Two same-side levels are held as a rolling pair. On the A side that is a
// descending pair - A1 above, A2 below. When a candle CLOSES above A1, the
// staircase has been run out and A2, the innermost step, is the DBO A level.
// The V side is the exact mirror: an ascending pair, a close below V1, and V2
// is the DBO V level. When a new same-side level appears while the pair is
// waiting: it did NOT break the inner step -> the pair SLIDES one along; it
// DID break the inner step -> the pair RESTARTS from that level.
//
// DOUBLE BREAKOUT FAILED
//
// A DBO A level sits below price when it is confirmed - the confirming candle
// closed above A1, and A1 is above A2. It FAILS when a RED candle later CLOSES
// below it. A DBO V level fails when a GREEN candle later CLOSES above it.
//
//   -- A2 ---------------------  DBO A level, support
//                  |  red candle closes below
//   -- A2 ---------------------  DBO A Failed, now resistance
//
// A wick through the level does not count, and neither does a doji. A level
// fails once; it never flips back. Only failed levels are drawn.
//
// All detection reads closed candles only. The running candle is never used.
// ==========================================================

// ============================ INPUTS ============================
gScan  = "Double Breakout"
gType  = "Failed Level Types"
gStyle = "Level Style"
gLabel = "Labels"
gTable = "Summary Table"

candleLen = input.int(200, "Scan Length (closed candles)", minval = 20, maxval = 2000, group = gScan,
     tooltip = "How far back the search reaches. A pair that has been waiting longer than this is abandoned. A Double Breakout level is watched for a failure only while the candle it came from is inside this window, and a failed level is dropped once that candle is older than this. The running candle is always excluded.")
maxLevels = input.int(6, "Max Levels Shown", minval = 1, maxval = 50, group = gScan,
     tooltip = "Only this many of the most recent failures are drawn. Older ones are still counted in the table, they are just not on the chart.")

showAF = input.bool(true, "DBO A Failed", group = gType,
     tooltip = "A DBO A level that a red candle has closed below.")
showVF = input.bool(true, "DBO V Failed", group = gType,
     tooltip = "A DBO V level that a green candle has closed above.")

bearColor   = input.color(#ef4444, "DBO A Failed Color", group = gStyle)
bullColor   = input.color(#22c55e, "DBO V Failed Color", group = gStyle)
lineWidth   = input.int(1, "Level Line Width", minval = 1, maxval = 4, group = gStyle)
extendRight = input.bool(true, "Extend Levels Right", group = gStyle,
     tooltip = "On: a failed level runs from its candle to the right edge of the chart. Off: it stops on the candle that broke it.")

showLabels     = input.bool(true, "Show Labels", group = gLabel)
labelSizeStr   = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gLabel)
labelOffsetPct = input.int(25, "Label Distance from Candle (%)", minval = 0, maxval = 300, group = gLabel,
     tooltip = "How far the label sits from the candle that broke the level, as a percentage of the 14-candle average true range.")

showTable    = input.bool(true, "Show Summary Table", group = gTable)
tablePosStr  = input.string("Top Right", "Table Position", options = ["Top Right", "Middle Right", "Bottom Right", "Top Left", "Bottom Left"], group = gTable)
tableSizeStr = input.string("Small", "Table Size", options = ["Tiny", "Small", "Normal"], group = gTable)

// ============================ STYLE CONSTANTS ============================
labelBull = #107a34
labelBear = #b22222
tableHead = #000000
tableBg   = #1e222d
tableEdge = #363a45

labelSize = labelSizeStr == "Tiny" ? size.tiny : labelSizeStr == "Small" ? size.small : labelSizeStr == "Large" ? size.large : size.normal
tableSize = tableSizeStr == "Tiny" ? size.tiny : tableSizeStr == "Normal" ? size.normal : size.small
tablePos  = tablePosStr == "Top Right" ? position.top_right : tablePosStr == "Middle Right" ? position.middle_right : tablePosStr == "Bottom Right" ? position.bottom_right : tablePosStr == "Top Left" ? position.top_left : position.bottom_left

MAX_STORED = 120

// ============================ LEVEL MODEL ============================
// Every confirmed Double Breakout level is kept and watched. Only a failed one
// is ever drawn.
type Level
    float price
    int   originBar     // the A2 / V2 candle the level was read from
    int   confirmBar    // the candle whose close confirmed the Double Breakout
    bool  isA           // true = DBO A (fails downward), false = DBO V
    bool  failed
    int   failBar       // the candle whose close broke the level
    float failHigh      // that candle's high and low, so its label can be
    float failLow       // parked clear of it
    int   failSeq       // order of failure, newest = highest
    line  ln
    label lb

var array<Level> levels = array.new<Level>()
var int failCount = 0

// ============================ ROLLING PAIR STATE ============================
var float a1 = na
var int   a1Bar = na
var float a2 = na
var int   a2Bar = na
var bool  aWait = false

var float v1 = na
var int   v1Bar = na
var float v2 = na
var int   v2Bar = na
var bool  vWait = false

// ============================ SIGNALS ============================
bool  sigAF = false
bool  sigVF = false
float pxAF  = na
float pxVF  = na

// ============================ HELPERS ============================
isGreen(int i) => close[i] > open[i]
isRed(int i)   => close[i] < open[i]

killDrawing(Level lv) =>
    if not na(lv.ln)
        line.delete(lv.ln)
        lv.ln := na
    if not na(lv.lb)
        label.delete(lv.lb)
        lv.lb := na

pushLevel(float px, int oBar, int cBar, bool isA) =>
    Level lv = Level.new(
         price      = px,
         originBar  = oBar,
         confirmBar = cBar,
         isA        = isA,
         failed     = false)
    array.push(levels, lv)
    if array.size(levels) > MAX_STORED
        Level oldest = array.shift(levels)
        killDrawing(oldest)

// ============================ SUMMARY TABLE ============================
var table sumTable = table.new(tablePos, 3, 4, border_width = 1, border_color = tableEdge)

// ============================ ATR FOR LABEL SPACING ============================
float atrVal = ta.atr(14)

// The colour of the candle that just closed, read once per candle for the failure test.
bool redNow   = close < open
bool greenNow = close > open

// ============================ MAIN ENGINE (BAR CLOSE ONLY) ============================
if barstate.isconfirmed and bar_index >= 2

    // ---------- 1. Housekeeping ----------
    // A waiting pair is abandoned once its outer step is older than the window.
    if not na(a1Bar) and bar_index - a1Bar > candleLen
        a1 := na
        a1Bar := na
        a2 := na
        a2Bar := na
        aWait := false

    if not na(v1Bar) and bar_index - v1Bar > candleLen
        v1 := na
        v1Bar := na
        v2 := na
        v2Bar := na
        vWait := false

    // A level leaves the watch, and the chart, once its candle is older than the window.
    if array.size(levels) > 0
        for i = array.size(levels) - 1 to 0
            Level lv = array.get(levels, i)
            if bar_index - lv.originBar > candleLen
                killDrawing(lv)
                array.remove(levels, i)

    // ---------- 2. Failures on the candle that just closed ----------
    // Run before this candle's own confirmations, so a level can never be
    // failed by the candle that confirmed it.
    if array.size(levels) > 0
        for i = 0 to array.size(levels) - 1
            Level lv = array.get(levels, i)
            if not lv.failed and bar_index > lv.confirmBar
                bool broke = lv.isA ? (redNow and close < lv.price) : (greenNow and close > lv.price)
                if broke
                    lv.failed   := true
                    lv.failBar  := bar_index
                    lv.failHigh := high
                    lv.failLow  := low
                    failCount   += 1
                    lv.failSeq  := failCount
                    if lv.isA
                        sigAF := true
                        pxAF  := lv.price
                    else
                        sigVF := true
                        pxVF  := lv.price

    // ---------- 3. New A / V Levels on the candle that just closed ----------
    // [1] is the level candle, [0] is the candle that reversed it.
    bool  aNew   = isGreen(1) and isRed(0)
    bool  vNew   = isRed(1) and isGreen(0)
    float lvlPx  = close[1]
    int   lvlBar = bar_index - 1

    // ---------- 4. A side: breakout first, then slide / restart / build ----------
    float doneA    = na
    int   doneABar = na

    if aWait and not na(a1) and not na(a2) and close > a1
        // The staircase has been run out. A2 is the level.
        doneA    := a2
        doneABar := a2Bar
        a1 := na
        a1Bar := na
        a2 := na
        a2Bar := na
        aWait := false
        // A level printing on this same candle can only belong to the next
        // search, so it opens it rather than being lost.
        if aNew
            a1 := lvlPx
            a1Bar := lvlBar
    else if aNew
        if aWait
            if lvlPx < a2
                // Inner step not broken - the pair slides one along.
                a1 := a2
                a1Bar := a2Bar
                a2 := lvlPx
                a2Bar := lvlBar
            else
                // Inner step broken but the outer one held - restart here.
                a1 := lvlPx
                a1Bar := lvlBar
                a2 := na
                a2Bar := na
                aWait := false
        else if na(a1)
            a1 := lvlPx
            a1Bar := lvlBar
        else if na(a2)
            if lvlPx < a1
                a2 := lvlPx
                a2Bar := lvlBar
                aWait := true
            else
                a1 := lvlPx
                a1Bar := lvlBar

    // ---------- 5. V side: exact mirror ----------
    float doneV    = na
    int   doneVBar = na

    if vWait and not na(v1) and not na(v2) and close < v1
        doneV    := v2
        doneVBar := v2Bar
        v1 := na
        v1Bar := na
        v2 := na
        v2Bar := na
        vWait := false
        if vNew
            v1 := lvlPx
            v1Bar := lvlBar
    else if vNew
        if vWait
            if lvlPx > v2
                v1 := v2
                v1Bar := v2Bar
                v2 := lvlPx
                v2Bar := lvlBar
            else
                v1 := lvlPx
                v1Bar := lvlBar
                v2 := na
                v2Bar := na
                vWait := false
        else if na(v1)
            v1 := lvlPx
            v1Bar := lvlBar
        else if na(v2)
            if lvlPx > v1
                v2 := lvlPx
                v2Bar := lvlBar
                vWait := true
            else
                v1 := lvlPx
                v1Bar := lvlBar

    // ---------- 6. Record the confirmations - watched from the next candle on ----------
    if not na(doneA)
        pushLevel(doneA, doneABar, bar_index, true)
    if not na(doneV)
        pushLevel(doneV, doneVBar, bar_index, false)

    // ---------- 7. Draw the newest failures and count ----------
    // The newest Max Levels Shown failures of the switched-on types are drawn,
    // worked out again from the whole list on every candle. A type that is
    // switched off does not use up a place.
    array<int> seqs = array.new<int>()
    int cA  = 0
    int cV  = 0
    int cAF = 0
    int cVF = 0
    if array.size(levels) > 0
        for i = 0 to array.size(levels) - 1
            Level lv = array.get(levels, i)
            if lv.isA
                cA += 1
            else
                cV += 1
            if lv.failed
                if lv.isA
                    cAF += 1
                else
                    cVF += 1
                if (lv.isA and showAF) or (not lv.isA and showVF)
                    array.push(seqs, lv.failSeq)

    int cutSeq = 0
    if array.size(seqs) > maxLevels
        array.sort(seqs, order.descending)
        cutSeq := array.get(seqs, maxLevels - 1)

    if array.size(levels) > 0
        for i = 0 to array.size(levels) - 1
            Level lv = array.get(levels, i)
            bool typeOn  = lv.isA ? showAF : showVF
            bool allowed = lv.failed and typeOn and lv.failSeq >= cutSeq
            if not allowed
                killDrawing(lv)
            else
                color col = lv.isA ? bearColor : bullColor
                int   x2  = extendRight ? bar_index : lv.failBar
                if na(lv.ln)
                    // One bar past the start at least, so the line has a slope to extend.
                    lv.ln := line.new(lv.originBar, lv.price, math.max(x2, lv.originBar + 1), lv.price,
                         xloc   = xloc.bar_index,
                         extend = extendRight ? extend.right : extend.none,
                         color  = col,
                         width  = lineWidth,
                         style  = line.style_solid)
                else
                    line.set_x2(lv.ln, math.max(x2, lv.originBar + 1))
                    line.set_extend(lv.ln, extendRight ? extend.right : extend.none)
                    line.set_color(lv.ln, col)
                    line.set_width(lv.ln, lineWidth)

                if showLabels
                    // The label marks the candle that broke the level - over its
                    // high on a failed DBO A (now resistance), under its low on a
                    // failed DBO V (now support). ATR is not ready on the first
                    // candles of a chart.
                    float off = na(atrVal) ? 0.0 : atrVal * labelOffsetPct * 0.01
                    float y   = lv.isA ? lv.failHigh + off : lv.failLow - off
                    if na(lv.lb)
                        lv.lb := label.new(lv.failBar, y, lv.isA ? "DBO A Failed" : "DBO V Failed",
                             xloc      = xloc.bar_index,
                             yloc      = yloc.price,
                             style     = lv.isA ? label.style_label_down : label.style_label_up,
                             color     = lv.isA ? labelBear : labelBull,
                             textcolor = color.white,
                             size      = labelSize)
                    else
                        label.set_size(lv.lb, labelSize)
                else
                    if not na(lv.lb)
                        label.delete(lv.lb)
                        lv.lb := na

    // ---------- 8. Summary table ----------
    if showTable
        table.cell(sumTable, 0, 0, "Level",  bgcolor = tableHead, text_color = color.white, text_size = tableSize, text_halign = text.align_left)
        table.cell(sumTable, 1, 0, "DBO A",  bgcolor = tableHead, text_color = color.white, text_size = tableSize)
        table.cell(sumTable, 2, 0, "DBO V",  bgcolor = tableHead, text_color = color.white, text_size = tableSize)

        // Found = every Double Breakout level inside the scan window; it splits
        // into the Failed ones, which are the only ones drawn, and the ones
        // still holding, which are not drawn.
        table.cell(sumTable, 0, 1, "DBO Found", bgcolor = tableBg, text_color = color.white, text_size = tableSize, text_halign = text.align_left)
        table.cell(sumTable, 1, 1, str.tostring(cA), bgcolor = tableBg, text_color = color.white, text_size = tableSize)
        table.cell(sumTable, 2, 1, str.tostring(cV), bgcolor = tableBg, text_color = color.white, text_size = tableSize)

        table.cell(sumTable, 0, 2, "Failed", bgcolor = tableBg, text_color = color.white, text_size = tableSize, text_halign = text.align_left)
        table.cell(sumTable, 1, 2, str.tostring(cAF), bgcolor = tableBg, text_color = bearColor, text_size = tableSize)
        table.cell(sumTable, 2, 2, str.tostring(cVF), bgcolor = tableBg, text_color = bullColor, text_size = tableSize)

        table.cell(sumTable, 0, 3, "Still Holding", bgcolor = tableBg, text_color = color.white, text_size = tableSize, text_halign = text.align_left)
        table.cell(sumTable, 1, 3, str.tostring(cA - cAF), bgcolor = tableBg, text_color = color.white, text_size = tableSize)
        table.cell(sumTable, 2, 3, str.tostring(cV - cVF), bgcolor = tableBg, text_color = color.white, text_size = tableSize)
    else
        table.clear(sumTable, 0, 0, 2, 3)

// ============================ ALERTS ============================
alertcondition(sigAF, title = "DBO A Failed", message = "DBO A Failed | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigVF, title = "DBO V Failed", message = "DBO V Failed | {{ticker}} {{interval}} | Close {{close}}")

// Dynamic message for the "Any alert() function call" alert type.
alertMsg(string tag, float px) =>
    tag + " | " + syminfo.ticker + " " + timeframe.period + " | Level " + str.tostring(px, format.mintick) + " | Close " + str.tostring(close, format.mintick)

if barstate.isconfirmed
    if sigAF
        alert(alertMsg("DBO A Failed", pxAF), alert.freq_once_per_bar_close)
    if sigVF
        alert(alertMsg("DBO V Failed", pxVF), alert.freq_once_per_bar_close)
````
