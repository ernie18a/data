<!-- tradingview-pine-id: PUB;84b6b2d8f892488baa1094db31307c17 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MSnR Double Breakout Level

Source: https://www.tradingview.com/script/0jssxZUC-MSnR-Double-Breakout-Level/

## Description

MSnR Double Breakout Level

A staircase of turning points, and the level that matters once price finally runs out the top or
the bottom of it.

Support and resistance tools usually mark a level the moment it forms, which is why a chart ends up carrying dozens of lines that never meant anything. This one marks nothing when a level appears. It holds two of them, waits to see whether price runs past the pair, and only then draws the one that was left behind.

The result is that a level is never drawn on hope. By the time it is on the chart, price has
already proved it was willing to go through everything above or below it.

THE TWO BUILDING BLOCKS

A candle is green when close is above open, red when close is below. A doji, where they are
equal, is neither and takes no part.

A Level a green candle followed immediately by a red one.
The GREEN candle's CLOSE is the level.
Buyers pushed, sellers took it straight back.

V Level    a red candle followed immediately by a green one.
The RED candle's CLOSE is the level.
Sellers pushed, buyers took it straight back.

These are not the output. They are the raw material.

DOUBLE BREAKOUT

Two same-side levels are held as a rolling pair. On the A side that is a descending pair - A1
above, A2 below:

A1 a close above this confirms it
A2 this is the level that gets marked

When a candle CLOSES above A1, the staircase has been run out, and A2 - the innermost step, the last place sellers stepped in before price left - is marked as the level.

The V side is the exact mirror. An ascending pair, V1 below and V2 above, a candle closing below V1, and V2 is marked.

It is always a DOUBLE. However long the staircase runs, only the latest two steps are ever held.
When a new same-side level appears while the pair is still waiting, one question decides what
happens to it:

the new level did NOT break the inner step   ->   the pair SLIDES one along
(old inner becomes the new outer)

the new level DID break the inner step       ->   the pair RESTARTS from that level

That single question is the whole bookkeeping, and it is the part most easily got wrong. Throwing the pair away every time another step appears loses the long staircases, which are exactly the ones worth waiting for. Never throwing it away means the pair drifts away from price and stops describing anything. Sliding keeps it anchored to the two most recent steps for as long as the move keeps going the same way, and restarts it the moment the move stops.

The breakout is always checked before any new level is. Reaching the outer step IS the breakout, so a level beyond it can only ever belong to the next search, never interrupt the current one.

DOUBLE BREAKOUT TO DOUBLE BREAKOUT

A completed Double Breakout can itself be taken out - by a completed Double Breakout running the other way.

a Double A Breakout confirms, marking A2
a Double V Breakout then confirms, marking V2
a candle CLOSES below that old A2
->  V2 becomes a DBO to DBO V level

The bullish case is the mirror: a Double V, then a Double A, then a close above the old V2, and
A2 becomes a DBO to DBO A level.

The cross break may land on the very same candle that confirmed the second Double Breakout, or on any candle after it. What it says is that the level which had just been established as the place price wanted to leave from has now been given up in the other direction, by a move built the same strict way.

The level is UPGRADED, not duplicated. A DBO to DBO A sits at exactly the price its Double A
Breakout already marked - it is the same level with more behind it - so the line already on the
chart changes its name and thickens rather than a second line being drawn on top of the first.

WHAT MAKES THIS DIFFERENT

1. Nothing is marked when it forms.

An A Level or a V Level on its own is never drawn. Two of them together are never drawn either.
Only the breakout puts something on the chart, which is why a whole session can pass with nothing new on it.

2. The pair rolls instead of resetting.

This is the piece that separates it from a plain two-level check. A staircase that keeps stepping
the same way keeps its pair alive, sliding one step at a time. A staircase that turns back on
itself starts again. Both cases are handled by the same rule.

3. The inner step is the level, not the outer one.

The outer step is what price had to close through to prove anything, so it has already been
consumed by the time the pattern completes. The inner step is the last one price never came back to, and that is what is drawn.

4. Breakout has priority over everything else.

Because reaching the outer step is itself the breakout, the order in which the two checks run
changes the result. Checking for new levels first would let a level that is really the start of
the next search interrupt the current one. Here the breakout is always resolved first.

5. The chain is a real state, not a coincidence.

A DBO to DBO level requires a full Double Breakout, then a full opposite Double Breakout, then
the first one's level being closed through. All three are tracked as one sequence, and any part
of it ageing out of the window cancels it.

6. The search itself can be watched.

The pair currently waiting for its breakout can be drawn, so the staircase can be seen sliding
before anything confirms. It is the working state, not a signal, and it is off by default.

READING THE CHART

Green line, "DBO A" Double A Breakout, label below
Red line, "DBO V" Double V Breakout, label above
Thick green, "DBO to DBO A" the bullish chain completed
Thick red, "DBO to DBO V" the bearish chain completed

Every line starts at the candle the level was read from and runs to the right, so the distance
from its origin to price shows how long it has been standing.

Labels are parked clear of that origin candle rather than on the level itself - under its low on a
bullish level, over its high on a bearish one. The level price is a candle CLOSE, so it sits
inside the candle, and a label placed there would be buried in the price action.

A chain level is always drawn one step thicker than a plain one. That is the only styling
difference, because it is the same kind of level, reached by a longer road.

With the working pair switched on, dotted lines labelled A1, A2, V1 and V2 show what is currently being tracked. A1 and A2 are the descending pair waiting for a close above A1; V1 and V2 are the ascending pair waiting for a close below V1. Watch A2 slide down as the staircase extends. If only A1 or only V1 is drawn, the search has one step and is waiting for its second.

Only the most recent few levels are drawn, so the chart stays readable. Older ones are still
counted in the corner table, which reports Double Breakout and DBO to DBO levels split into bull and bear. If the table reads higher than what you can see, the display limit is doing its job.

SETTINGS

Double Breakout
- Scan Length: how far back the search reaches. A pair that has been waiting longer than this is
abandoned, and a confirmed level is dropped once the candle it came from is older than this. It
also bounds how long a chain can stay open.
- Max Levels Shown: how many of the most recent levels are drawn. Switching a type off frees its slots for the others.

Level Types
- A switch for each of the four: Double A Breakout, Double V Breakout, DBO to DBO A, DBO to DBO V.
- Show Working Pair: draws the pair currently waiting for its breakout.

Level Style
- Bullish, bearish and working pair colours, line width, and whether levels extend to the right
edge. With extending off, a level stops at the candle that confirmed it.

Labels
- Show Labels, Label Size, and Label Distance from Candle as a percentage of ATR(14), so the gap scales with whatever instrument and timeframe you are on. The distance is measured from the origin candle's high or low, not from the level.

Summary Table

- Show, position and size of the corner table.

ALERTS

Four alert conditions:

Double A Breakout a descending pair was run out to the upside
Double V Breakout an ascending pair was run out to the downside
DBO to DBO A  a bullish chain completed
DBO to DBO V a bearish chain completed

Each message carries the event, the symbol, the timeframe and the closing price. The same
messages are also sent through the alert function, so the "Any alert() function call" alert type
can deliver all four through a single alert.

Every alert is evaluated only after a candle has fully closed.

REPAINTING

This script does not repaint.

- The whole engine runs once per closed candle. Price moving inside an open candle cannot create, change or remove a level, and cannot make a signal appear and then disappear.
- Both building blocks need a candle AFTER them to exist at all. An A Level is only an A Level
once the red candle behind it has closed, so nothing is ever read from a candle still forming.
- Levels are built forward, one candle at a time, in the same order they would have been built live. A line that has been drawn never moves. The only thing that can change about it is its
name and thickness, when a later chain upgrades it, and that is a record of what price did
afterwards rather than a revision of what it did before.
- Nothing is read from a higher timeframe, so there is no higher timeframe lookahead to get
wrong.

When you create an alert, TradingView may show a caution banner saying the indicator can repaint. That banner appears automatically for any script that uses the built in bar state variables, no matter how they are used, because the platform cannot check the intent behind them. This script uses one of them for the opposite purpose: it is what restricts the entire engine to bar close.Choosing "Once Per Bar Close" when creating the alert is still recommended.

NOTES AND LIMITATIONS

- Levels are deliberately infrequent. Two same-side reversals have to line up and then be run
through by a close, and a DBO to DBO level needs that to happen twice in opposite directions.
Long stretches with nothing new are normal.
- Scan Length is not only cosmetic here. It decides when a waiting pair is abandoned and when a chain expires, so changing it changes what is found, not just what is drawn. Max Levels Shown
is the cosmetic one.
- A doji takes no part. An A Level or V Level needs one candle of each colour, so a pair
containing a doji is not one.
- DBO to DBO upgrades the existing level in place. The count of plain Double Breakouts therefore goes down by one each time a chain completes, because that level has become
something else.
- An internal cap of 120 stored levels keeps the drawing count inside TradingView's limits. On a
very long history the oldest are dropped.
- Detection is purely structural. It reports where these sequences occurred and nothing more. It
does not rank levels by quality, measure what happened next, or produce entries, targets or
stops.

HOW TO USE IT

A Double Breakout level marks the last place the other side stepped in before price left the
area. Traders commonly watch these for:

- A reaction on the first return, since price has not been back to that step since the breakout
- Direction from the side, where a bullish level below price and a bearish level above it frame
the range price is currently working in
- Confirmation against a higher timeframe read, where a level that agrees with the larger picture carries more weight than one that fights it

A DBO to DBO level is the same level after the market has argued about it twice. The road to it
was longer, and it sits where a completed move in one direction was undone by a completed move in the other.

The working pair is worth turning on while learning the tool. Watching A2 slide down step by step makes it obvious what the breakout is waiting for, and where it would have to close for anything to be drawn.

These are reference areas, not entry signals on their own. Use them alongside your own support
and resistance mapping, your own entry method and proper risk management.

DISCLAIMER

This indicator is a pattern detection tool. It is not financial advice and it makes no claim
about profitability. Trading involves risk. Always apply your own analysis and risk management.

---

## Source Code

````pine
//@version=6
indicator(
     title            = "MSnR Double Breakout Level",
     overlay          = true,
     max_lines_count  = 500,
     max_labels_count = 500,
     max_bars_back    = 500
     )

// ==========================================================
// MSnR Double Breakout Level
//
// A staircase of turning points, and the level that matters once price finally
// runs out the top or the bottom of it.
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
// staircase has been run out and A2, the innermost step, is marked.
//
//   -- A1 ---------------------  <- close above this confirms
//        -- A2 ----------------  <- this is the level that gets marked
//
// The V side is the exact mirror: an ascending pair, a close below V1, and V2
// is marked.
//
// It is always a DOUBLE. However long the staircase runs, only the latest two
// steps are held. When a new same-side level appears while the pair is waiting:
//
//   it did NOT break the inner step   -> the pair SLIDES one along
//   it DID break the inner step       -> the pair RESTARTS from that level
//
// That single question - did the new level break the inner one - is the whole
// bookkeeping, and it is what keeps a long staircase alive instead of throwing
// it away every time another step appears.
//
// DOUBLE BREAKOUT TO DOUBLE BREAKOUT
//
// A completed Double Breakout can be taken out by a completed Double Breakout
// running the other way. When that happens the level is upgraded rather than
// duplicated, because it is the same price with more behind it.
//
//   Double A Breakout confirmed, marking A2
//   Double V Breakout confirmed, marking V2
//   a candle CLOSES below that old A2
//   -> V2 becomes a DBO to DBO V level
//
// The bullish case is the mirror. The cross-break may land on the same candle
// that confirmed the second Double Breakout, or on any candle after it.
//
// All detection reads closed candles only. The running candle is never used.
// ==========================================================

// ============================ INPUTS ============================
gScan  = "Double Breakout"
gType  = "Level Types"
gStyle = "Level Style"
gLabel = "Labels"
gTable = "Summary Table"

candleLen = input.int(200, "Scan Length (closed candles)", minval = 20, maxval = 2000, group = gScan,
     tooltip = "How far back the search reaches. A pair that has been waiting longer than this is abandoned, and a confirmed level is dropped once the candle it came from is older than this. The running candle is always excluded.")
maxLevels = input.int(6, "Max Levels Shown", minval = 1, maxval = 50, group = gScan,
     tooltip = "Only this many of the most recent levels are drawn. Older ones are still counted in the table, they are just not on the chart.")

showDA  = input.bool(true, "Double A Breakout",         group = gType)
showDV  = input.bool(true, "Double V Breakout",         group = gType)
showDDA = input.bool(true, "DBO to DBO A",              group = gType)
showDDV = input.bool(true, "DBO to DBO V",              group = gType)
showPair = input.bool(false, "Show Working Pair",       group = gType,
     tooltip = "Draws the pair that is currently waiting for its breakout, so you can watch the staircase slide before anything confirms. Nothing here is a signal - it is the search in progress.")

bullColor = input.color(#22c55e, "Bullish Level Color", group = gStyle)
bearColor = input.color(#ef4444, "Bearish Level Color", group = gStyle)
pairColor = input.color(#9598a1, "Working Pair Color",  group = gStyle)
lineWidth = input.int(1, "Level Line Width", minval = 1, maxval = 4, group = gStyle,
     tooltip = "A DBO to DBO level is always drawn one step thicker than this.")
extendRight = input.bool(true, "Extend Levels Right", group = gStyle,
     tooltip = "Runs each level to the right edge. With this off a level stops at the candle that confirmed it.")

showLabels     = input.bool(true, "Show Labels", group = gLabel)
labelSizeStr   = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gLabel)
labelOffsetPct = input.int(25, "Label Distance from Candle (%)", minval = 0, maxval = 300, group = gLabel,
     tooltip = "Gap between the label and the candle the level came from, as a percentage of ATR(14). A bullish label sits under that candle's low and a bearish one over its high, so the text always clears the price action. Increase it on noisy charts.")

showTable    = input.bool(true, "Show Summary Table", group = gTable)
tablePosStr  = input.string("Top Right", "Table Position", options = ["Top Right", "Middle Right", "Bottom Right", "Top Left", "Bottom Left"], group = gTable)
tableSizeStr = input.string("Small", "Table Size", options = ["Tiny", "Small", "Normal"], group = gTable)

// ============================ STYLE CONSTANTS ============================
labelBull = #107a34
labelBear = #b22222
labelPair = #5d606b
tableHead = #000000
tableBg   = #1e222d
tableEdge = #363a45

labelSize = labelSizeStr == "Tiny" ? size.tiny : labelSizeStr == "Small" ? size.small : labelSizeStr == "Large" ? size.large : size.normal
tableSize = tableSizeStr == "Tiny" ? size.tiny : tableSizeStr == "Normal" ? size.normal : size.small
tablePos  = tablePosStr == "Top Right" ? position.top_right : tablePosStr == "Middle Right" ? position.middle_right : tablePosStr == "Bottom Right" ? position.bottom_right : tablePosStr == "Top Left" ? position.top_left : position.bottom_left

// Level types
TYPE_DA  = 1   // Double A Breakout          - bullish
TYPE_DV  = 2   // Double V Breakout          - bearish
TYPE_DDA = 3   // DBO to DBO A               - bullish
TYPE_DDV = 4   // DBO to DBO V               - bearish

MAX_STORED = 120

// ============================ LEVEL MODEL ============================
type Level
    float price
    int   originBar     // the A2 / V2 candle the level was read from
    float originHigh    // that candle's high and low, so a label can be parked
    float originLow     // clear of it instead of sitting on top of the candle
    int   confirmBar    // the candle whose close confirmed the breakout
    int   ltype
    int   drawnType     // last type actually painted
    line  ln
    label lb

var array<Level> levels = array.new<Level>()

// ============================ ROLLING PAIR STATE ============================
// Each step carries the high and low of the candle it came from, so that when
// the pair finally confirms, the level knows which candle to park its label
// clear of.
var float a1 = na
var int   a1Bar = na
var float a1Hi = na
var float a1Lo = na
var float a2 = na
var int   a2Bar = na
var float a2Hi = na
var float a2Lo = na
var bool  aWait = false

var float v1 = na
var int   v1Bar = na
var float v1Hi = na
var float v1Lo = na
var float v2 = na
var int   v2Bar = na
var float v2Hi = na
var float v2Lo = na
var bool  vWait = false

// ============================ CHAIN STATE ============================
// The marked level of the most recent completed Double Breakout on each side.
// It is what the opposite side has to take out to build a DBO to DBO level.
var float pendA2 = na
var int   pendA2Bar = na
var float pendV2 = na
var int   pendV2Bar = na

// A chain becomes active when the SECOND Double Breakout confirms. It is then
// waiting for the first one's level to be closed through.
var bool  chainABusy = false   // waiting to close ABOVE an old V2
var float chainATgt  = na
var int   chainABar  = na      // originBar of the A2 that will be upgraded

var bool  chainVBusy = false   // waiting to close BELOW an old A2
var float chainVTgt  = na
var int   chainVBar  = na

// ============================ WORKING PAIR DRAWINGS ============================
var array<line>  pairLines  = array.new<line>()
var array<label> pairLabels = array.new<label>()

// ============================ SIGNALS ============================
bool sigDA  = false
bool sigDV  = false
bool sigDDA = false
bool sigDDV = false

// ============================ HELPERS ============================
isGreen(int i) => close[i] > open[i]
isRed(int i)   => close[i] < open[i]

isBullType(int t) => t == TYPE_DA or t == TYPE_DDA
isChainType(int t) => t == TYPE_DDA or t == TYPE_DDV

typeVisible(int t) =>
    bool v = false
    if t == TYPE_DA
        v := showDA
    else if t == TYPE_DV
        v := showDV
    else if t == TYPE_DDA
        v := showDDA
    else if t == TYPE_DDV
        v := showDDV
    v

typeText(int t) =>
    string s = ""
    if t == TYPE_DA
        s := "DBO A"
    else if t == TYPE_DV
        s := "DBO V"
    else if t == TYPE_DDA
        s := "DBO to DBO A"
    else if t == TYPE_DDV
        s := "DBO to DBO V"
    s

killLevel(Level lv) =>
    if not na(lv.ln)
        line.delete(lv.ln)
        lv.ln := na
    if not na(lv.lb)
        label.delete(lv.lb)
        lv.lb := na
    lv.drawnType := 0

pushLevel(float px, int oBar, float oHigh, float oLow, int cBar, int t) =>
    Level lv = Level.new(
         price      = px,
         originBar  = oBar,
         originHigh = oHigh,
         originLow  = oLow,
         confirmBar = cBar,
         ltype      = t,
         drawnType  = 0)
    array.push(levels, lv)
    if array.size(levels) > MAX_STORED
        Level oldest = array.shift(levels)
        killLevel(oldest)

// Turns an already stored Double Breakout level into its DBO to DBO form. The
// price does not move - only what the level means changes - so the level is
// upgraded in place instead of a second line being drawn on top of the first.
upgradeLevel(int originBar, int fromType, int toType) =>
    bool done = false
    if array.size(levels) > 0
        for i = array.size(levels) - 1 to 0
            Level lv = array.get(levels, i)
            if not done and lv.originBar == originBar and lv.ltype == fromType
                lv.ltype := toType
                done := true
    done

clearPairDrawings() =>
    int nl = array.size(pairLines)
    if nl > 0
        for i = 0 to nl - 1
            line ln = array.get(pairLines, i)
            if not na(ln)
                line.delete(ln)
        array.clear(pairLines)
    int nb = array.size(pairLabels)
    if nb > 0
        for i = 0 to nb - 1
            label lb = array.get(pairLabels, i)
            if not na(lb)
                label.delete(lb)
        array.clear(pairLabels)

drawPairLeg(float price, int fromBar, string tag) =>
    if not na(price) and not na(fromBar)
        line ln = line.new(fromBar, price, bar_index, price,
             xloc  = xloc.bar_index,
             color = pairColor,
             width = 1,
             style = line.style_dotted)
        array.push(pairLines, ln)
        label lb = label.new(bar_index, price, tag,
             xloc      = xloc.bar_index,
             yloc      = yloc.price,
             style     = label.style_label_left,
             color     = labelPair,
             textcolor = color.white,
             size      = size.tiny)
        array.push(pairLabels, lb)

// ============================ SUMMARY TABLE ============================
var table sumTable = table.new(tablePos, 3, 3, border_width = 1, border_color = tableEdge)

// ============================ ATR FOR LABEL SPACING ============================
float atrVal = ta.atr(14)

// ============================ MAIN ENGINE (BAR CLOSE ONLY) ============================
int cDA  = 0
int cDV  = 0
int cDDA = 0
int cDDV = 0

if barstate.isconfirmed and bar_index >= 2

    // ---------- 1. Housekeeping ----------
    // A waiting pair is abandoned once its outer step is older than the window.
    if not na(a1Bar) and bar_index - a1Bar > candleLen
        a1 := na
        a1Bar := na
        a1Hi := na
        a1Lo := na
        a2 := na
        a2Bar := na
        a2Hi := na
        a2Lo := na
        aWait := false

    if not na(v1Bar) and bar_index - v1Bar > candleLen
        v1 := na
        v1Bar := na
        v1Hi := na
        v1Lo := na
        v2 := na
        v2Bar := na
        v2Hi := na
        v2Lo := na
        vWait := false

    // A completed Double Breakout stops being chainable once it ages out.
    if not na(pendA2Bar) and bar_index - pendA2Bar > candleLen
        pendA2 := na
        pendA2Bar := na
    if not na(pendV2Bar) and bar_index - pendV2Bar > candleLen
        pendV2 := na
        pendV2Bar := na
    if chainABusy and (na(chainABar) or bar_index - chainABar > candleLen)
        chainABusy := false
    if chainVBusy and (na(chainVBar) or bar_index - chainVBar > candleLen)
        chainVBusy := false

    // Drop confirmed levels that have aged out of the window.
    if array.size(levels) > 0
        for i = array.size(levels) - 1 to 0
            Level lv = array.get(levels, i)
            if bar_index - lv.originBar > candleLen
                killLevel(lv)
                array.remove(levels, i)

    // ---------- 2. New A / V Levels on the candle that just closed ----------
    // [1] is the level candle, [0] is the candle that reversed it.
    bool  aNew   = isGreen(1) and isRed(0)
    bool  vNew   = isRed(1) and isGreen(0)
    float lvlPx  = close[1]
    float lvlHi  = high[1]
    float lvlLo  = low[1]
    int   lvlBar = bar_index - 1

    // ---------- 3. A side: breakout first, then slide / restart / build ----------
    float doneA    = na
    int   doneABar = na
    float doneAHi  = na
    float doneALo  = na

    if aWait and not na(a1) and not na(a2) and close > a1
        // The staircase has been run out. A2 is the level.
        doneA    := a2
        doneABar := a2Bar
        doneAHi  := a2Hi
        doneALo  := a2Lo
        a1 := na
        a1Bar := na
        a1Hi := na
        a1Lo := na
        a2 := na
        a2Bar := na
        a2Hi := na
        a2Lo := na
        aWait := false
        // A level printing on this same candle can only belong to the next
        // search, so it opens it rather than being lost.
        if aNew
            a1 := lvlPx
            a1Bar := lvlBar
            a1Hi := lvlHi
            a1Lo := lvlLo
    else if aNew
        if aWait
            if lvlPx < a2
                // Inner step not broken - the pair slides one along.
                a1 := a2
                a1Bar := a2Bar
                a1Hi := a2Hi
                a1Lo := a2Lo
                a2 := lvlPx
                a2Bar := lvlBar
                a2Hi := lvlHi
                a2Lo := lvlLo
            else
                // Inner step broken but the outer one held - restart here.
                a1 := lvlPx
                a1Bar := lvlBar
                a1Hi := lvlHi
                a1Lo := lvlLo
                a2 := na
                a2Bar := na
                a2Hi := na
                a2Lo := na
                aWait := false
        else if na(a1)
            a1 := lvlPx
            a1Bar := lvlBar
            a1Hi := lvlHi
            a1Lo := lvlLo
        else if na(a2)
            if lvlPx < a1
                a2 := lvlPx
                a2Bar := lvlBar
                a2Hi := lvlHi
                a2Lo := lvlLo
                aWait := true
            else
                a1 := lvlPx
                a1Bar := lvlBar
                a1Hi := lvlHi
                a1Lo := lvlLo

    // ---------- 4. V side: exact mirror ----------
    float doneV    = na
    int   doneVBar = na
    float doneVHi  = na
    float doneVLo  = na

    if vWait and not na(v1) and not na(v2) and close < v1
        doneV    := v2
        doneVBar := v2Bar
        doneVHi  := v2Hi
        doneVLo  := v2Lo
        v1 := na
        v1Bar := na
        v1Hi := na
        v1Lo := na
        v2 := na
        v2Bar := na
        v2Hi := na
        v2Lo := na
        vWait := false
        if vNew
            v1 := lvlPx
            v1Bar := lvlBar
            v1Hi := lvlHi
            v1Lo := lvlLo
    else if vNew
        if vWait
            if lvlPx > v2
                v1 := v2
                v1Bar := v2Bar
                v1Hi := v2Hi
                v1Lo := v2Lo
                v2 := lvlPx
                v2Bar := lvlBar
                v2Hi := lvlHi
                v2Lo := lvlLo
            else
                v1 := lvlPx
                v1Bar := lvlBar
                v1Hi := lvlHi
                v1Lo := lvlLo
                v2 := na
                v2Bar := na
                v2Hi := na
                v2Lo := na
                vWait := false
        else if na(v1)
            v1 := lvlPx
            v1Bar := lvlBar
            v1Hi := lvlHi
            v1Lo := lvlLo
        else if na(v2)
            if lvlPx > v1
                v2 := lvlPx
                v2Bar := lvlBar
                v2Hi := lvlHi
                v2Lo := lvlLo
                vWait := true
            else
                v1 := lvlPx
                v1Bar := lvlBar
                v1Hi := lvlHi
                v1Lo := lvlLo

    // ---------- 5. Record the confirmations and open any chain ----------
    if not na(doneA)
        pushLevel(doneA, doneABar, doneAHi, doneALo, bar_index, TYPE_DA)
        sigDA := true
        pendA2 := doneA
        pendA2Bar := doneABar
        // A Double V already stands. This Double A can now go after its level.
        if not na(pendV2)
            chainABusy := true
            chainATgt  := pendV2
            chainABar  := doneABar

    if not na(doneV)
        pushLevel(doneV, doneVBar, doneVHi, doneVLo, bar_index, TYPE_DV)
        sigDV := true
        pendV2 := doneV
        pendV2Bar := doneVBar
        if not na(pendA2)
            chainVBusy := true
            chainVTgt  := pendA2
            chainVBar  := doneVBar

    // ---------- 6. Cross break - may land on the very same candle ----------
    if chainABusy and not na(chainATgt) and close > chainATgt
        if upgradeLevel(chainABar, TYPE_DA, TYPE_DDA)
            sigDDA := true
        chainABusy := false
        pendV2 := na
        pendV2Bar := na

    if chainVBusy and not na(chainVTgt) and close < chainVTgt
        if upgradeLevel(chainVBar, TYPE_DV, TYPE_DDV)
            sigDDV := true
        chainVBusy := false
        pendA2 := na
        pendA2Bar := na

    // ---------- 7. Draw and count ----------
    int shown = 0

    if array.size(levels) > 0
        for i = array.size(levels) - 1 to 0
            Level lv = array.get(levels, i)

            // A type that is switched off does not use up a display slot, so
            // hiding one kind simply lets more of the others through.
            bool allowed = false
            if typeVisible(lv.ltype)
                shown += 1
                allowed := shown <= maxLevels

            if not allowed
                killLevel(lv)
            else
                bool  bull  = isBullType(lv.ltype)
                bool  chain = isChainType(lv.ltype)
                color col   = bull ? bullColor : bearColor
                int   wid   = chain ? lineWidth + 1 : lineWidth
                int   x2    = extendRight ? bar_index : lv.confirmBar
                bool  redo  = lv.drawnType != lv.ltype

                if na(lv.ln)
                    lv.ln := line.new(lv.originBar, lv.price, x2, lv.price,
                         xloc   = xloc.bar_index,
                         extend = extendRight ? extend.right : extend.none,
                         color  = col,
                         width  = wid,
                         style  = line.style_solid)
                else
                    line.set_x2(lv.ln, x2)
                    if redo
                        line.set_color(lv.ln, col)
                        line.set_width(lv.ln, wid)

                if showLabels
                    // The label is parked clear of the candle the level came
                    // from - under its LOW on a bullish level, over its HIGH on
                    // a bearish one - rather than on the level price itself,
                    // which sits inside that candle and buries the text.
                    // ATR is not ready on the first candles of a chart.
                    float off    = na(atrVal) ? 0.0 : atrVal * labelOffsetPct * 0.01
                    float anchor = bull ? lv.originLow : lv.originHigh
                    if na(anchor)
                        anchor := lv.price
                    float y = bull ? anchor - off : anchor + off
                    if na(lv.lb)
                        lv.lb := label.new(lv.originBar, y, typeText(lv.ltype),
                             xloc      = xloc.bar_index,
                             yloc      = yloc.price,
                             style     = bull ? label.style_label_up : label.style_label_down,
                             color     = bull ? labelBull : labelBear,
                             textcolor = color.white,
                             size      = labelSize)
                    else if redo
                        label.set_y(lv.lb, y)
                        label.set_text(lv.lb, typeText(lv.ltype))
                        label.set_style(lv.lb, bull ? label.style_label_up : label.style_label_down)
                        label.set_color(lv.lb, bull ? labelBull : labelBear)
                else
                    if not na(lv.lb)
                        label.delete(lv.lb)
                        lv.lb := na

                lv.drawnType := lv.ltype

            if lv.ltype == TYPE_DA
                cDA += 1
            else if lv.ltype == TYPE_DV
                cDV += 1
            else if lv.ltype == TYPE_DDA
                cDDA += 1
            else if lv.ltype == TYPE_DDV
                cDDV += 1

    // ---------- 8. The pair still being worked on ----------
    clearPairDrawings()
    if showPair
        if aWait
            drawPairLeg(a1, a1Bar, "A1")
            drawPairLeg(a2, a2Bar, "A2")
        else if not na(a1)
            drawPairLeg(a1, a1Bar, "A1")

        if vWait
            drawPairLeg(v1, v1Bar, "V1")
            drawPairLeg(v2, v2Bar, "V2")
        else if not na(v1)
            drawPairLeg(v1, v1Bar, "V1")

    // ---------- 9. Summary table ----------
    if showTable
        table.cell(sumTable, 0, 0, "Level", bgcolor = tableHead, text_color = color.white, text_size = tableSize, text_halign = text.align_left)
        table.cell(sumTable, 1, 0, "Bull",  bgcolor = tableHead, text_color = color.white, text_size = tableSize)
        table.cell(sumTable, 2, 0, "Bear",  bgcolor = tableHead, text_color = color.white, text_size = tableSize)

        table.cell(sumTable, 0, 1, "Double Breakout", bgcolor = tableBg, text_color = color.white, text_size = tableSize, text_halign = text.align_left)
        table.cell(sumTable, 1, 1, str.tostring(cDA), bgcolor = tableBg, text_color = bullColor, text_size = tableSize)
        table.cell(sumTable, 2, 1, str.tostring(cDV), bgcolor = tableBg, text_color = bearColor, text_size = tableSize)

        table.cell(sumTable, 0, 2, "DBO to DBO", bgcolor = tableBg, text_color = color.white, text_size = tableSize, text_halign = text.align_left)
        table.cell(sumTable, 1, 2, str.tostring(cDDA), bgcolor = tableBg, text_color = bullColor, text_size = tableSize)
        table.cell(sumTable, 2, 2, str.tostring(cDDV), bgcolor = tableBg, text_color = bearColor, text_size = tableSize)
    else
        table.clear(sumTable, 0, 0, 2, 2)

// ============================ ALERTS ============================
alertcondition(sigDA,  title = "Double A Breakout", message = "Double A Breakout | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigDV,  title = "Double V Breakout", message = "Double V Breakout | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigDDA, title = "DBO to DBO A",      message = "DBO to DBO A Level | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigDDV, title = "DBO to DBO V",      message = "DBO to DBO V Level | {{ticker}} {{interval}} | Close {{close}}")

// Dynamic message for the "Any alert() function call" alert type.
alertMsg(string tag) =>
    tag + " | " + syminfo.ticker + " " + timeframe.period + " | Close " + str.tostring(close, format.mintick)

if barstate.isconfirmed
    if sigDA
        alert(alertMsg("Double A Breakout"), alert.freq_once_per_bar_close)
    if sigDV
        alert(alertMsg("Double V Breakout"), alert.freq_once_per_bar_close)
    if sigDDA
        alert(alertMsg("DBO to DBO A Level"), alert.freq_once_per_bar_close)
    if sigDDV
        alert(alertMsg("DBO to DBO V Level"), alert.freq_once_per_bar_close)
````
