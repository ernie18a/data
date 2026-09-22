<!-- tradingview-pine-id: PUB;7e3e4f05443b49e4964def74bdbba1d4 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Green & Red Triple Overlap Candle

Source: https://www.tradingview.com/script/A8Q7PFCg-Green-Red-Triple-Overlap-Candle/

## Description

Green & Red Triple Overlap Candle

Three candles of the same colour that go nowhere.

One side spends three candles in a row pushing, and at the end of it price is still sitting in the
same band it started in. The candles do not step away from each other, they fold back over each other. That is the whole pattern, and it is the opposite of what three same-coloured candles are usually assumed to mean.

The middle candle is the reference. The first and the third clamp its body from opposite ends, and the band they clamp is what gets drawn.

THE TWO PATTERNS

A candle is Green when close is greater than open, and Red when close is less than open. A Doji,
where close equals open, is neither and takes no part. Only fully closed candles are read; the
candle still forming is never used.

Green Triple Overlap

Candle 1, Candle 2 and Candle 3 are all Green
Candle 1 HIGH is at or above Candle 2 CLOSE it already reached the top of the middle body
Candle 3 LOW  is at or below Candle 2 OPEN it came back down to the bottom of it

Red Triple Overlap

Candle 1, Candle 2 and Candle 3 are all Red
Candle 1 LOW  is at or below Candle 2 CLOSE it already reached the bottom of the middle body
Candle 3 HIGH is at or above Candle 2 OPEN it came back up to the top of it

That is the whole definition. Three colours and two reaches, all on the same group of candles.

WHAT IT ACTUALLY SAYS

Three green candles in a row is normally read as strength. Here it is not, and the two reaches are what change the reading.

Candle 1's high already being at Candle 2's close means the second candle finished the whole of
its work inside ground the first one had already covered. It closed where the previous candle had merely traded. No new territory.

Candle 3's low coming back to Candle 2's open means the third candle handed back the entire middle body before doing whatever it did. Everything the second candle gained was given up and bought again.

Put together: three candles of buying pressure, and the group is still standing on the same band. Buyers keep arriving and something keeps meeting them. The pattern marks absorption, not thrust.

The red side is the same story with the roles swapped.

WHAT MAKES THIS DIFFERENT

1. It is not Three White Soldiers, and reading it as such inverts the meaning.

Three White Soldiers is a staircase: each candle opens inside the previous body and closes beyond it, so the group walks upward. This is the opposite construction. Each candle folds back over the middle one, so the group stands still. Both are three same-coloured candles, and that is where the similarity ends.

2. The comparison is against the BODY, not the range.

Both reaches are measured against Candle 2's open and close, not its high and low. Wicks on the
middle candle change nothing. That keeps the test on where price actually settled rather than on how far it briefly poked, which is what makes the pattern uncommon instead of everywhere.

3. The middle candle is a fixed reference, not just the one in between.

Candle 1 is checked against one edge of it and Candle 3 against the other. The two conditions
point in opposite directions on purpose - that opposition is what clamps the band.

4. Two candles doing this is not the pattern.

Any two adjacent candles overlap to some degree. It takes a third, reaching back the other way, before the group can be said to have gone nowhere. Nothing is reported until all three are closed and all three conditions hold.

5. Same colour throughout is mandatory.

A mixed group is a reversal story and is already well covered by engulfing and pin bar tools. Here every candle belongs to the same side, which is what makes the lack of progress worth noticing at all.

READING THE CHART

Each detected pattern draws a solid box over the MIDDLE candle's body - the band that was clamped - stretched across all three candles.

Green Triple Overlap drawn in the bullish colour, label below the group
Red Triple Overlap drawn in the bearish colour, label above the group

Labels are parked outside the whole three-candle group rather than on the box, so the text always clears the price action. The box itself is often thin, because the middle body is the thing being measured, and a thin box is information: it means the three candles were argued out in a very narrow band.

An optional outline draws the full high-to-low range of the three candles around that band. Turn it on to see how much room the group used in total against how little it kept. It is off by default so the clamped band stays the focus, but on a chart zoomed far out it is also the easiest way to spot where the patterns are, because the band on its own is only as tall as one candle body.

The band can also be run out to the right edge, which turns it from a marker of what happened into a level you can watch price return to. That is off by default as well. The range outline is never extended - it describes three particular candles, not a price that is still live.

A summary table in the corner counts how many of each type were found inside the current scan window. It counts every pattern found, including a type that is currently switched off, so the table always reflects what the market actually printed rather than what is on screen.

SETTINGS

Scan
- Scan Length: how many closed candles are scanned backwards from the latest bar. The running candle is always excluded.

Pattern Types
- A switch for Green Triple Overlap and one for Red Triple Overlap.
- Show Full Candle Range: outlines the whole height of the three candles around the clamped band.

Zone Style
- Bullish and Bearish colours, and the fill transparency of the band. The full range outline is
always drawn lighter than the band it surrounds.
- Extend Zones Right: runs the clamped band out to the right edge so you can see where price sits against it now. Only the band is extended, never the range outline.

Labels
- Show Labels, Label Size, and Label Distance from Candles as a percentage of the group's full
height. Increase the distance on noisy charts so labels clear the candles.

Summary Table
- Show, position and size of the corner table.

ALERTS

Two alert conditions: Green Triple Overlap and Red Triple Overlap.

Each message carries the pattern name, the symbol, the timeframe and the closing price. The same messages are also sent through the alert function, so the "Any alert() function call" alert type can deliver both through a single alert.

All alerts are evaluated only after a candle has fully closed.

REPAINTING

This script does not repaint.

- Detection reads confirmed candles only. The scan starts far enough behind the latest bar that
the candle still forming is never part of any group.
- Every alert signal is written so that it can only become true once a candle has finished. Price
moving inside an open candle cannot make a signal appear and then disappear.
- Boxes are rebuilt on the last bar using confirmed history. A box that has been drawn does not
move or change afterwards. It only leaves the chart when it falls outside the Scan Length
window.

When you create an alert, TradingView may show a caution banner saying the indicator can repaint. That banner appears automatically for any script that uses the built in bar state variables, no matter how they are used, because the platform cannot check the intent behind them. This script uses them for the opposite purpose: one of them is what restricts every signal to bar close, and the other is what redraws the boxes efficiently on the final bar. Choosing "Once Per Bar Close" when creating the alert is still recommended.

NOTES AND LIMITATIONS

- The pattern is uncommon by design. Three candles have to share a colour and then reach back
across each other in opposite directions. Stretches with nothing on the chart are normal. If you
want to see more of them, look at a faster timeframe rather than loosening anything.
- Doji candles take no part. A group containing one is never reported, because a Doji has no
direction to share.
- Increasing Scan Length raises the number of drawing objects, and switching the full range outline on doubles the boxes. TradingView caps these at 500 boxes and 500 labels, and the oldest are dropped once a cap is reached. The default is chosen to stay well inside those limits.
- Overlapping groups are possible. Three candles can belong to one pattern while the next three, shifted by one, form another, so boxes may sit next to or inside each other.
- Detection is purely structural. It reports where the shape occurred and nothing more. It does not rank patterns by quality, measure follow through, or produce entries, targets or stops.

HOW TO USE IT

The box marks a band that one side defended for three candles running. Traders commonly watch these areas for:

- A reaction when price returns to the band later, since it was contested once already
- Continuation once price finally leaves the band, because the side that was absorbed has spent
three candles worth of effort with nothing to show for it
- Context alongside higher timeframe structure, where absorption against the larger trend reads differently from absorption with it

The edges of the box - the middle candle's open and close - are the two prices the group kept
returning to, and they are usually the more interesting part of it.

These are reference areas, not entry signals on their own. Use them alongside your own support and resistance mapping, your own entry method and proper risk management.

DISCLAIMER

This indicator is a pattern detection tool. It is not financial advice and it makes no claim about
profitability. Trading involves risk. Always apply your own analysis and risk management.

---

## Source Code

````pine
//@version=6
indicator(
     title            = "Green & Red Triple Overlap Candle",
     overlay          = true,
     max_boxes_count  = 500,
     max_labels_count = 500,
     max_lines_count  = 500,
     max_bars_back    = 5000
     )

// ==========================================================
// Green & Red Triple Overlap Candle
//
// Three candles of the same colour that go nowhere.
//
// The middle candle is the reference. Candle 1 and Candle 3 clamp its BODY
// from opposite ends, which is what stops the three of them from stepping
// away from each other:
//
//   Green Triple Overlap   all three GREEN
//                          Candle 1 HIGH is at or above Candle 2 CLOSE
//                          Candle 3 LOW  is at or below Candle 2 OPEN
//
//   Red Triple Overlap     all three RED
//                          Candle 1 LOW  is at or below Candle 2 CLOSE
//                          Candle 3 HIGH is at or above Candle 2 OPEN
//
//   Green case:
//
//        c2 CLOSE  =========  <- Candle 1 already reached up to here
//                  |     |
//                  | c2  |
//                  |     |
//        c2 OPEN   =========  <- Candle 3 came back down to here
//
// The body of the middle candle is the band that got clamped, and that band is
// what gets drawn.
//
// WHAT IT SAYS
//
// Three candles all pushing the same way, and none of them getting anywhere.
// On the green side Candle 2 never cleared Candle 1's high, and Candle 3 handed
// back everything down to Candle 2's open. The group is folding over itself
// instead of building a leg. One side keeps pushing, the other keeps absorbing.
//
// This is NOT Three White Soldiers or Three Black Crows. Those are a staircase,
// where every candle steps beyond the one before it. Here every candle folds
// back over the middle one, which is the opposite behaviour, so the two should
// never be read the same way.
//
// All detection reads closed candles only. The running candle is never used.
// ==========================================================

// ============================ INPUTS ============================
gScan  = "Scan"
gType  = "Pattern Types"
gStyle = "Zone Style"
gLabel = "Labels"
gTable = "Summary Table"

candleLen = input.int(200, "Scan Length (closed candles)", minval = 4, maxval = 2000, group = gScan,
     tooltip = "How many closed candles are scanned backwards from the latest bar. The running candle is always excluded.")

showGreen = input.bool(true, "Green Triple Overlap", group = gType)
showRed   = input.bool(true, "Red Triple Overlap",   group = gType)
showRange = input.bool(false, "Show Full Candle Range", group = gType,
     tooltip = "Outlines the whole high-to-low range of the three candles around the clamped band, so you can see how tightly they are stacked.")

bullColor  = input.color(#22c55e, "Bullish Zone",  group = gStyle)
bearColor  = input.color(#ef4444, "Bearish Zone",  group = gStyle)
zoneTransp = input.int(70, "Zone Transparency", minval = 0, maxval = 95, group = gStyle,
     tooltip = "Fill transparency of the clamped band. The full range outline is always drawn lighter than this.")
extendZones = input.bool(false, "Extend Zones Right", group = gStyle,
     tooltip = "Runs the clamped band out to the right edge so you can see where price sits against it now. Only the band is extended - the full range outline stays over its own three candles, because it marks what happened rather than a level.")

showLabels     = input.bool(true, "Show Labels", group = gLabel)
labelSizeStr   = input.string("Normal", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gLabel)
labelOffsetPct = input.int(30, "Label Distance from Candles (%)", minval = 0, group = gLabel,
     tooltip = "Gap between the label and the three candles, as a percentage of their full height. The label is always parked outside the group, never on top of it.")

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

// The full range outline sits a step lighter than the band it surrounds.
rangeTransp = zoneTransp + 20 > 95 ? 95 : zoneTransp + 20

// ============================ CANDLE COLOUR HELPERS ============================
// A Doji (close == open) is neither Green nor Red, so a group containing one is
// never a Triple Overlap.
isGreen(int i) => close[i] > open[i]
isRed(int i)   => close[i] < open[i]

// ============================ PATTERN SCANNER ============================
// Offsets, oldest to newest: c1 = off, c2 = off - 1, c3 = off - 2.
// off starts at 3 so c3 is never the running candle.
//
// Returns: 1 = Green Triple Overlap, -1 = Red Triple Overlap, 0 = no pattern
tripleOverlapScan(int off) =>
    int dir = 0
    if off >= 3
        int c1 = off
        int c2 = off - 1
        int c3 = off - 2

        // Green: three green, Candle 1 reaches the top of Candle 2's body,
        // Candle 3 reaches the bottom of it.
        if isGreen(c1) and isGreen(c2) and isGreen(c3) and high[c1] >= close[c2] and low[c3] <= open[c2]
            dir := 1

        // Red: three red, mirrored.
        if isRed(c1) and isRed(c2) and isRed(c3) and low[c1] <= close[c2] and high[c3] >= open[c2]
            dir := -1
    dir

// ============================ DRAWING ============================
var box[]   gBoxes  = array.new_box()
var label[] gLabels = array.new_label()

clearAll() =>
    int nb = array.size(gBoxes)
    if nb > 0
        for j = 0 to nb - 1
            box bx = array.get(gBoxes, j)
            if not na(bx)
                box.delete(bx)
        array.clear(gBoxes)

    int nl = array.size(gLabels)
    if nl > 0
        for j = 0 to nl - 1
            label lb = array.get(gLabels, j)
            if not na(lb)
                label.delete(lb)
        array.clear(gLabels)

// The drawn band is the MIDDLE candle's body - the part Candle 1 and Candle 3
// clamped - stretched across all three candles. The optional outline is the
// full high-to-low of the group, which shows how little room they used.
drawZone(int off, bool greenSide) =>
    int c1Off = off
    int c2Off = off - 1
    int c3Off = off - 2

    int xLeft  = bar_index - c1Off
    int xRight = bar_index - c3Off
    // The clamped band may be run out to the right edge as a level. The full
    // range outline never is - it marks what the three candles did, not a price
    // that is still live.
    int xBand  = extendZones ? bar_index + 10 : xRight

    // Candle 2 is green on the green side and red on the red side, so its body
    // edges are known without comparing.
    float yTop = greenSide ? close[c2Off] : open[c2Off]
    float yBot = greenSide ? open[c2Off]  : close[c2Off]

    // Full height of the three candles, used for the outline and for parking
    // the label clear of all of them.
    float rTop = high[c1Off]
    rTop := high[c2Off] > rTop ? high[c2Off] : rTop
    rTop := high[c3Off] > rTop ? high[c3Off] : rTop
    float rBot = low[c1Off]
    rBot := low[c2Off] < rBot ? low[c2Off] : rBot
    rBot := low[c3Off] < rBot ? low[c3Off] : rBot

    color baseCol = greenSide ? bullColor : bearColor

    if showRange
        box r = box.new(xLeft, rTop, xRight, rBot,
             xloc         = xloc.bar_index,
             border_color = color.new(baseCol, 40),
             border_width = 1,
             border_style = line.style_dotted,
             bgcolor      = color.new(baseCol, rangeTransp))
        array.push(gBoxes, r)

    box b = box.new(xLeft, yTop, xBand, yBot,
         xloc         = xloc.bar_index,
         border_color = color.new(baseCol, 0),
         border_width = 2,
         border_style = line.style_solid,
         bgcolor      = color.new(baseCol, zoneTransp))
    array.push(gBoxes, b)

    if showLabels
        string tag = greenSide ? "Green Triple Overlap" : "Red Triple Overlap"
        float  h   = math.abs(rTop - rBot)
        float  off2 = h * labelOffsetPct * 0.01
        // Parked outside the whole group, so the text never lands on a candle.
        float  y   = greenSide ? rBot - off2 : rTop + off2
        int    x   = xLeft + 1
        label lb = label.new(x, y,
             text      = tag,
             xloc      = xloc.bar_index,
             yloc      = yloc.price,
             style     = greenSide ? label.style_label_up : label.style_label_down,
             color     = greenSide ? labelBull : labelBear,
             textcolor = color.white,
             size      = labelSize)
        array.push(gLabels, lb)

// ============================ SUMMARY TABLE ============================
var table sumTable = table.new(tablePos, 3, 2, border_width = 1, border_color = tableEdge)

// ============================ MAIN SCAN AND REDRAW ============================
if barstate.islast
    clearAll()

    int cGreen = 0
    int cRed   = 0

    int maxScan = math.min(candleLen, bar_index)

    for i = 1 to maxScan
        int dir = tripleOverlapScan(i)

        if dir == 1
            cGreen += 1
            if showGreen
                drawZone(i, true)

        if dir == -1
            cRed += 1
            if showRed
                drawZone(i, false)

    if showTable
        table.cell(sumTable, 0, 0, "Pattern",              bgcolor = tableHead, text_color = color.white, text_size = tableSize, text_halign = text.align_left)
        table.cell(sumTable, 1, 0, "Green",                bgcolor = tableHead, text_color = color.white, text_size = tableSize)
        table.cell(sumTable, 2, 0, "Red",                  bgcolor = tableHead, text_color = color.white, text_size = tableSize)
        table.cell(sumTable, 0, 1, "Triple Overlap",       bgcolor = tableBg,   text_color = color.white, text_size = tableSize, text_halign = text.align_left)
        table.cell(sumTable, 1, 1, str.tostring(cGreen),   bgcolor = tableBg,   text_color = bullColor,   text_size = tableSize)
        table.cell(sumTable, 2, 1, str.tostring(cRed),     bgcolor = tableBg,   text_color = bearColor,   text_size = tableSize)
    else
        table.clear(sumTable, 0, 0, 2, 1)

// ============================ LIVE PATTERN STATE (BAR CLOSE ONLY) ============================
// The same three rules, read on the candle that has just closed.
// [2] = Candle 1, [1] = Candle 2, [0] = Candle 3.
confirmed = barstate.isconfirmed

sigGreen = confirmed and isGreen(2) and isGreen(1) and isGreen(0) and high[2] >= close[1] and low[0]  <= open[1]
sigRed   = confirmed and isRed(2)   and isRed(1)   and isRed(0)   and low[2]  <= close[1] and high[0] >= open[1]

// ============================ ALERTS ============================
alertcondition(sigGreen, title = "Green Triple Overlap", message = "Green Triple Overlap | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigRed,   title = "Red Triple Overlap",   message = "Red Triple Overlap | {{ticker}} {{interval}} | Close {{close}}")

alertMsg(string tag) =>
    tag + " | " + syminfo.ticker + " " + timeframe.period + " | Close " + str.tostring(close, format.mintick)

if confirmed
    if sigGreen
        alert(alertMsg("Green Triple Overlap"), alert.freq_once_per_bar_close)
    if sigRed
        alert(alertMsg("Red Triple Overlap"), alert.freq_once_per_bar_close)
````
