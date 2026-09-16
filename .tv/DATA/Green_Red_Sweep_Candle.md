<!-- tradingview-pine-id: PUB;cbb3ff2cd8654c20a7ad0c4658ad6924 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Green & Red Sweep Candle

Source: https://www.tradingview.com/script/MJiGR4lh-Green-Red-Sweep-Candle/

## Description

Green & Red Sweep Candle

A two candle pattern where one candle takes the stops on one side of the market and then closes
through the other.

Both candles are the same colour. The second one first trades BEYOND the far side of the first,
taking out the orders resting there, and only then CLOSES past the opposite side. By the time it
finishes it has covered the first candle's entire range, and it has done so in the direction it
was already moving.

The script scans closed candles for that sequence and draws the range it happened in.

THE TWO PATTERNS

A candle is Green when close is greater than open, and Red when close is less than open. A Doji,
where close equals open, is neither and takes no part. Only fully closed candles are read; the
candle still forming is never used.

Green Sweep Candle

  Candle 1 is Green
  Candle 2 is Green
  Candle 2 LOW is at or below Candle 1 LOW the sweep
  Candle 2 CLOSES above Candle 1 HIGH the close beyond

Red Sweep Candle

  Candle 1 is Red
  Candle 2 is Red
  Candle 2 HIGH is at or above Candle 1 HIGH the sweep
  Candle 2 CLOSES below Candle 1 LOW the close beyond

That is the whole definition. Two rules, and both have to be true on the same pair.

WHAT MAKES THIS DIFFERENT

1. The order matters, not just the shape.

Plenty of candles end up covering the one before them. What is being looked for here is a
sequence: price first goes the WRONG way far enough to clear the previous candle's extreme, and only after that commits the other way. A candle that simply opens beyond the previous range and runs is not the same event, and it is not reported.

2. The close decides, not the wick.

Reaching past the opposite side is not enough. The candle has to CLOSE beyond it. A long wick
that pokes through and pulls back means the move was rejected, so it does not count. This single rule removes most of what a shape based check would report.

3. Both candles must share a colour.

This is what separates the pattern from an ordinary large candle. The first candle already
committed to a direction. The second one dips against it, clears the level, and then closes even
further in the SAME direction. Sellers into a Green pair and buyers into a Red pair were taken
out, and the original direction carried on regardless.

4. It is deliberately rare.

A sweep on its own is common. A candle covering the previous one is common. Both of them together, in the same colour, with a close settling beyond, is not. Long stretches with nothing on the chart are normal and expected.

READING THE CHART

Each detected pattern draws a rectangle over Candle 1's full High to Low range, stretched from
Candle 1 across to Candle 2. That box is the range that was swept and then closed through.

Green Sweep  drawn in the bullish colour, label sits below the box
Red Sweep      drawn in the bearish colour, label sits above the box

The label points at its own box, so it is always clear which rectangle it belongs to.

A summary table in the corner counts how many of each type were found inside the current scan window. It counts every pattern found, including a type that is currently switched off, so the table always reflects what the market actually printed rather than what is on screen.

SETTINGS

Scan
- Scan Length: how many closed candles are scanned backwards from the latest bar. The running candle is always excluded.

Pattern Types
- A switch for Green Sweep Candle and one for Red Sweep Candle.

Zone Style
- Bullish Zone and Bearish Zone colours, and the fill transparency of the box.

Labels
- Show Labels, Label Size, and Label Distance from Zone as a percentage of the candle's height.
  Increase the distance on noisy charts so labels clear the candles.

Summary Table
- Show, position and size of the corner table.

ALERTS

Two alert conditions: Green Sweep Candle and Red Sweep Candle.

Each message carries the pattern name, the symbol, the timeframe and the closing price. The same messages are also sent through the alert function, so the "Any alert() function call" alert type can deliver both through a single alert.

All alerts are evaluated only after a candle has fully closed.

REPAINTING

This script does not repaint.

- Detection reads confirmed candles only. The scan starts one bar behind the latest bar, so the
  candle that is still forming is never part of any calculation.
- Every alert signal is written so that it can only become true once a candle has finished. Price
  moving inside an open candle cannot make a signal appear and then disappear.
- Boxes are rebuilt on the last bar using confirmed history. A box that has been drawn does not
  move or change afterwards. It only leaves the chart when it falls outside the Scan Length
  window.

When you create an alert, TradingView may show a caution banner saying the indicator can repaint.That banner appears automatically for any script that uses the built in bar state variables, no matter how they are used, because the platform cannot check the intent behind them. This script uses them for the opposite purpose: one of them is what restricts every signal to bar close, and the other is what redraws the boxes efficiently on the final bar. Choosing "Once Per Bar Close" when creating the alert is still recommended.

NOTES AND LIMITATIONS

- The pattern is rare by design. Two conditions have to line up on the same pair of candles, so
  an empty chart is normal. If you want to see more of them, look at a faster timeframe rather
  than loosening anything.
- Increasing Scan Length raises the number of drawing objects. TradingView caps these at 500
  boxes and 500 labels, and the oldest are dropped once a cap is reached. The default is chosen
  to stay well inside those limits on normal charts.
- Doji candles take no part. A pair containing one is never reported, because a Doji has no
  direction to share.
- Detection is purely structural. It reports where the sequence occurred and nothing more. It
  does not rank patterns by quality, measure follow through, or produce entries, targets or
  stops.

HOW TO USE IT

The box marks a range that was swept and then closed through. Traders commonly watch these areas
for:

- Continuation, since the move carried on after the opposing orders had been cleared
- Reaction when price returns to the box later, the swept edge in particular
- Confirmation alongside higher timeframe structure, where a sweep in the direction of the larger trend carries more weight than one against it

The swept edge - the Low of a Green Sweep, the High of a Red Sweep - is the level price reached before turning, and it is usually the more interesting side of the box.

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
     title            = "Green & Red Sweep Candle",
     overlay          = true,
     max_boxes_count  = 500,
     max_labels_count = 500,
     max_lines_count  = 500,
     max_bars_back    = 5000
     )

// ============================ INPUTS ============================
gScan  = "Scan"
gType  = "Pattern Types"
gStyle = "Zone Style"
gLabel = "Labels"
gTable = "Summary Table"

candleLen = input.int(200, "Scan Length (closed candles)", minval = 3, maxval = 2000, group = gScan,
     tooltip = "How many closed candles are scanned backwards from the latest bar. The running candle is always excluded.")

showGreenSweep = input.bool(true, "Green Sweep Candle", group = gType)
showRedSweep   = input.bool(true, "Red Sweep Candle",   group = gType)

bullColor  = input.color(#22c55e, "Bullish Zone",     group = gStyle)
bearColor  = input.color(#ef4444, "Bearish Zone",     group = gStyle)
zoneTransp = input.int(75, "Zone Transparency", minval = 0, maxval = 95, group = gStyle)

showLabels     = input.bool(true, "Show Labels", group = gLabel)
labelSizeStr   = input.string("Normal", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gLabel)
labelOffsetPct = input.int(40, "Label Distance from Zone (%)", minval = 0, group = gLabel,
     tooltip = "Gap between the zone edge and the label, as a percentage of the Base candle height.")

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

// ============================ CANDLE COLOUR HELPERS ============================
// A Doji (close == open) is neither Green nor Red.
isGreen(int i) => close[i] > open[i]
isRed(int i)   => close[i] < open[i]

// ============================ PATTERN SCANNER ============================
// Both candles share the same colour. The second one first SWEEPS the far side of
// the first - its low on a Green pair, its high on a Red pair - and only then CLOSES
// beyond the opposite side, so it ends up covering the first candle's whole range.
// Sweeping alone is not enough; the close has to settle past it.
//
// Green Sweep Candle:
//   Candle 1 = Green, Candle 2 = Green
//   Candle 2 Low  <= Candle 1 Low      (the sweep)
//   Candle 2 Close > Candle 1 High     (the close beyond)
//
// Red Sweep Candle:
//   Candle 1 = Red, Candle 2 = Red
//   Candle 2 High >= Candle 1 High     (the sweep)
//   Candle 2 Close < Candle 1 Low      (the close beyond)

// Returns: 1 = Green Sweep Candle, -1 = Red Sweep Candle, 0 = no pattern
sweepCandleScan(int candleOff) =>
    int dir = 0
    if candleOff >= 2
        int c1 = candleOff      // Candle 1 (older)
        int c2 = candleOff - 1  // Candle 2 (newer, the sweeping candle)

        // Green Sweep Candle
        if isGreen(c1) and isGreen(c2) and low[c2] <= low[c1] and close[c2] > high[c1]
            dir := 1

        // Red Sweep Candle
        if isRed(c1) and isRed(c2) and high[c2] >= high[c1] and close[c2] < low[c1]
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

// Draws the zone using Candle 1's full range (high-low), stretched from
// Candle 1 to Candle 2.
drawZone(int candleOff, bool isBuy) =>
    int   c1Off = candleOff
    int   c2Off = candleOff - 1
    int   xC1   = bar_index - c1Off
    int   xC2   = bar_index - c2Off
    float yTop  = high[c1Off]
    float yBot  = low[c1Off]

    color baseCol = isBuy ? bullColor : bearColor

    box b = box.new(xC1, yTop, xC2, yBot,
         xloc         = xloc.bar_index,
         border_color = color.new(baseCol, 0),
         border_width = 2,
         border_style = line.style_solid,
         bgcolor      = color.new(baseCol, zoneTransp))
    array.push(gBoxes, b)

    if showLabels
        string tag = isBuy ? "Green Sweep" : "Red Sweep"
        float  h   = math.abs(yTop - yBot)
        float  off = h * labelOffsetPct * 0.01
        float  y   = isBuy ? yBot - off : yTop + off
        int    x   = xC1 + int(math.round((xC2 - xC1) / 2.0))
        label lb = label.new(x, y,
             text      = tag,
             xloc      = xloc.bar_index,
             yloc      = yloc.price,
             style     = isBuy ? label.style_label_up : label.style_label_down,
             color     = isBuy ? labelBull : labelBear,
             textcolor = color.white,
             size      = labelSize)
        array.push(gLabels, lb)

// ============================ SUMMARY TABLE ============================
var table sumTable = table.new(tablePos, 3, 2, border_width = 1, border_color = tableEdge)

// ============================ MAIN SCAN AND REDRAW ============================
if barstate.islast
    clearAll()

    int cGreenSweep = 0
    int cRedSweep   = 0

    int maxScan = math.min(candleLen, bar_index)

    for i = 1 to maxScan
        int dir = sweepCandleScan(i)

        if dir == 1
            cGreenSweep += 1
            if showGreenSweep
                drawZone(i, true)

        if dir == -1
            cRedSweep += 1
            if showRedSweep
                drawZone(i, false)

    if showTable
        table.cell(sumTable, 0, 0, "Pattern",               bgcolor = tableHead, text_color = color.white, text_size = tableSize, text_halign = text.align_left)
        table.cell(sumTable, 1, 0, "Green",                  bgcolor = tableHead, text_color = color.white, text_size = tableSize)
        table.cell(sumTable, 2, 0, "Red",                    bgcolor = tableHead, text_color = color.white, text_size = tableSize)
        table.cell(sumTable, 0, 1, "Sweep Candle",             bgcolor = tableBg,   text_color = color.white, text_size = tableSize, text_halign = text.align_left)
        table.cell(sumTable, 1, 1, str.tostring(cGreenSweep), bgcolor = tableBg,   text_color = bullColor,   text_size = tableSize)
        table.cell(sumTable, 2, 1, str.tostring(cRedSweep),   bgcolor = tableBg,   text_color = bearColor,   text_size = tableSize)
    else
        table.clear(sumTable, 0, 0, 2, 1)

// ============================ LIVE PATTERN STATE (BAR CLOSE ONLY) ============================
confirmed = barstate.isconfirmed

// Green Sweep Candle on the candle that just closed
sigGreenSweep = confirmed and isGreen(1) and isGreen(0) and low <= low[1] and close > high[1]

// Red Sweep Candle on the candle that just closed
sigRedSweep   = confirmed and isRed(1) and isRed(0) and high >= high[1] and close < low[1]

// ============================ ALERTS ============================
alertcondition(sigGreenSweep, title = "Green Sweep Candle", message = "Green Sweep Candle | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigRedSweep,   title = "Red Sweep Candle",   message = "Red Sweep Candle | {{ticker}} {{interval}} | Close {{close}}")

alertMsg(string tag) =>
    tag + " | " + syminfo.ticker + " " + timeframe.period + " | Close " + str.tostring(close, format.mintick)

if confirmed
    if sigGreenSweep
        alert(alertMsg("Green Sweep Candle"), alert.freq_once_per_bar_close)
    if sigRedSweep
        alert(alertMsg("Red Sweep Candle"), alert.freq_once_per_bar_close)
````
