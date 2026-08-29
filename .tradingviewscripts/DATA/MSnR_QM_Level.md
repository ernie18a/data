<!-- tradingview-pine-id: PUB;6581b6aac28d4f63b7cf01f5fa81f7ac -->
<!-- tradingviewscripts-format: 1 -->
# MSnR QM Level

Source: https://www.tradingview.com/script/PdpbKEfY-MSnR-QM-Level/

## Description

MSnR QM Level

This script detects Quasimodo (QM) levels from the close prices of consecutive candles and draws
them as horizontal support and resistance lines.

A QM Level forms when price creates a turning point, breaks it, builds a second turning point on
the other side, and then breaks that too. What is left behind is the price of the original turning
point, which is where liquidity was trapped and where the market often reacts again.

The result is a structural map of QM levels across the scan window, drawn as horizontal lines that
extend to the right from the candle that set the price.

WHAT MAKES THIS DIFFERENT

1. Strict four step detection.

Most QM tools look for swing highs and swing lows relative to some lookback period. This script
uses a precise four step sequence built entirely from consecutive candle pairs. Every step must
complete before a QM Level is confirmed, which eliminates the vague heuristics that plague swing
based detection.

2. The level price is the CLOSE, not the wick.

Every level sits at the close of the candle that set it. Closes are where the market actually
agreed on a price, which is why a close through a level counts as a break here while a wick through
it does not.

3. Every level is checked for uniqueness.

Duplicate prices within a small tolerance are not drawn twice. If two QM Levels land on the same
price, only one line appears. This keeps the chart clean without losing any information.

4. Detection reads confirmed candles only.

The running candle is never used. Every detection step requires a fully closed candle, and the scan
starts one bar behind the latest bar. Nothing on the chart changes while a candle is still open.

THE TWO QM TYPES

A candle is Green when close is greater than open and Red when close is less than open. A Doji,
where close equals open, is neither and forms no level. Only fully closed candles are read.

Buy QM (support)

Step 1. Find a V Level: a Red candle followed by a Green candle. The V Level price is the close of
the Red candle.

Step 2. Find the earliest Red candle after the V Level that closes below the V Level price. This is
the V Breakdown.

Step 3. Between the V Level and the V Breakdown, find an A Level: a Green candle followed by a Red
candle. Use the one nearest the V Breakdown if several exist. The A Level price is the close of the
Green candle.

Step 4. After the V Breakdown, find any Green candle that closes above the A Level price. The A
Level is now broken upward.

If all four steps confirm, the V Level price becomes the Buy QM Level. The line is drawn at that
price and extends to the right.

Sell QM (resistance)

Step 1. Find an A Level: a Green candle followed by a Red candle. The A Level price is the close of
the Green candle.

Step 2. Find the earliest Green candle after the A Level that closes above the A Level price. This
is the A Breakout.

Step 3. Between the A Level and the A Breakout, find a V Level: a Red candle followed by a Green
candle. Use the one nearest the A Breakout if several exist. The V Level price is the close of the
Red candle.

Step 4. After the A Breakout, find any Red candle that closes below the V Level price. The V Level
is now broken downward.

If all four steps confirm, the A Level price becomes the Sell QM Level. The line is drawn at that
price and extends to the right.

In both cases the QM Level marks the price of the ORIGINAL turning point: the one that was broken,
rebuilt from the other side, and then had its counterpart broken as well. That is the price where
liquidity was trapped, and it is the price the script watches.

READING THE CHART

Color tells you the side:

- Green line and green label: Buy QM. This level sits below price as support.
- Red line and red label: Sell QM. This level sits above price as resistance.

Each line starts at the candle that set its price and extends to the right, so you can see how
price has behaved around it since. The label sits at that same candle, below the line for a Buy QM
and above it for a Sell QM, so it never covers the line itself.

A summary table in the corner counts how many Buy QM and Sell QM levels were found in the current
scan window, including those that are hidden by a toggle. The table always reflects what the market
actually printed rather than what is currently switched on.

SETTINGS

Scan
- Scan Length: how many closed candles are scanned backwards from the latest bar. Every QM Level
  inside that window is drawn. The running candle is always excluded.

Level Types
- An individual switch for Buy QM and Sell QM. Hiding one side is useful when you only want to
  see levels in one direction.

Style
- Sell QM Color and Buy QM Color.

Labels
- Show Labels, Label Offset in ticks, and Label Size. The offset is measured in ticks, so a value
  that looks right on one symbol may need adjusting on another.

Summary Table
- Show, position and size of the corner table.

ALERTS

Two alert conditions are available: Buy QM and Sell QM.

Each message carries the level type, the symbol, the timeframe and the closing price. The same
messages are also sent through the alert function, so the "Any alert() function call" alert type
can deliver both through a single alert.

All alerts are evaluated only after a candle has fully closed.

An alert fires when the four step QM sequence completes on the latest closed candle. Because
completion requires a breakout of the inner level, these alerts do not fire on every bar; they fire
only when price actually confirms a new QM structure.

REPAINTING

This script does not repaint.

- Detection reads confirmed candles only. The scan starts one bar behind the latest bar, so the
  candle that is still forming is never part of any calculation.
- Alert signals can only become true once a candle has finished. Price moving inside an open candle
  cannot make a signal appear and then disappear.
- Levels are rebuilt on the last bar from confirmed history. A level's price never moves. Once
  drawn, nothing shifts backwards.

When you create an alert, TradingView may show a caution banner saying the indicator can repaint.
That banner appears automatically for any script that uses the built in bar state variables, no
matter how they are used, because the platform cannot check the intent behind them. This script
uses them for the opposite purpose: one of them is what restricts every signal to bar close, and
the other is what redraws the levels efficiently on the final bar. Choosing "Once Per Bar Close"
when creating the alert is still recommended.

NOTES AND LIMITATIONS

- A QM Level requires a specific four step sequence to complete. That makes them less common than
  plain A and V Levels, so stretches with few or no QM Levels are normal and expected.
- TradingView caps drawings at 500 lines and 500 labels. A very long Scan Length will hit that
  ceiling and the oldest drawings will be dropped. The default is chosen to stay well inside it.
- The label offset is measured in ticks, and a tick is worth a very different amount on a crypto
  pair than on a forex pair. Expect to adjust it when you move between symbols.
- Level prices come from closes, so a level can sit in the middle of a long wick. That is
  deliberate, not a bug.
- Duplicate prices within a tolerance of two ticks are drawn only once. If two QM Levels land on
  nearly the same price, you see one line instead of two stacked on top of each other.
- Detection is purely structural. It reports where QM Levels are and which side they sit on. It
  does not rank them by strength, measure what happened afterwards, or produce entries, targets or
  stops.

HOW TO USE IT

A QM Level marks a price where price created a turning point, broke it, built the opposite turning
point, and then broke that too. The original turning point is where one side was trapped, and price
returning to that price often produces a reaction.

Buy QM Levels below price act as support. Sell QM Levels above price act as resistance. When
several levels cluster near the same price, the area is often more significant than any single
level, since separate structures agreeing on one price is what a real zone looks like.

These are reference levels, not entry signals. Use them alongside higher timeframe structure, and
apply your own confirmation and risk management.

DISCLAIMER

This indicator is a level detection tool. It is not financial advice and it makes no claim about
profitability. Trading involves risk. Always apply your own analysis and risk management.

---

## Source Code

````pine
//@version=6
indicator(
     title            = "MSnR QM Level",
     overlay          = true,
     max_lines_count  = 500,
     max_labels_count = 500,
     max_bars_back    = 5000
     )

// ============================ INPUTS ============================
gScan  = "Scan"
gType  = "Level Types"
gStyle = "Style"
gLabel = "Labels"
gTable = "Summary Table"

candleLen = input.int(50, "Scan Length (closed candles)", minval = 3, maxval = 500, group = gScan,
     tooltip = "How many closed candles are scanned backwards from the latest bar. Every QM Level found inside this window is drawn. The running candle is always excluded.")

showBuyQM  = input.bool(true, "Buy QM",  group = gType)
showSellQM = input.bool(true, "Sell QM", group = gType)

resColor = input.color(#ef4444, "Sell QM Color", group = gStyle,
     tooltip = "Color for Sell QM levels - these sit above price as resistance.")
supColor = input.color(#22c55e, "Buy QM Color",  group = gStyle,
     tooltip = "Color for Buy QM levels - these sit below price as support.")

showLabels       = input.bool(true, "Show Labels", group = gLabel)
labelOffsetTicks = input.int(60, "Label Offset (ticks)", minval = 1, group = gLabel,
     tooltip = "How far the label sits from its own line. Buy QM labels go below the line, Sell QM labels above it.")
labelSizeStr     = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gLabel)

showTable    = input.bool(true, "Show Summary Table", group = gTable)
tablePosStr  = input.string("Top Right", "Table Position", options = ["Top Right", "Middle Right", "Bottom Right", "Top Left", "Bottom Left"], group = gTable)
tableSizeStr = input.string("Small", "Table Size", options = ["Tiny", "Small", "Normal"], group = gTable)

// ============================ STYLE CONSTANTS ============================
labelBuy  = #107a34
labelSell = #b22222

tableHead = #000000
tableBg   = #1e222d
tableEdge = #363a45

labelSize = labelSizeStr == "Tiny" ? size.tiny : labelSizeStr == "Normal" ? size.normal : labelSizeStr == "Large" ? size.large : size.small
tableSize = tableSizeStr == "Tiny" ? size.tiny : tableSizeStr == "Normal" ? size.normal : size.small
tablePos  = tablePosStr == "Top Right" ? position.top_right : tablePosStr == "Middle Right" ? position.middle_right : tablePosStr == "Bottom Right" ? position.bottom_right : tablePosStr == "Top Left" ? position.top_left : position.bottom_left

// ============================ HELPERS ============================
isGreen(int i) => close[i] > open[i]
isRed(int i)   => close[i] < open[i]

// A Level: Green -> Red (level = close of the Green candle)
isALevel(int firstOff, int secondOff) =>
    isGreen(firstOff) and isRed(secondOff)

// V Level: Red -> Green (level = close of the Red candle)
isVLevel(int firstOff, int secondOff) =>
    isRed(firstOff) and isGreen(secondOff)

// ============================ DRAWING STORAGE ============================
var line[]  gLines  = array.new_line()
var label[] gLabels = array.new_label()
var float[] gPrices = array.new_float()

clearAll() =>
    int nl = array.size(gLines)
    if nl > 0
        for j = 0 to nl - 1
            line ln = array.get(gLines, j)
            if not na(ln)
                line.delete(ln)
        array.clear(gLines)

    int nb = array.size(gLabels)
    if nb > 0
        for j = 0 to nb - 1
            label lb = array.get(gLabels, j)
            if not na(lb)
                label.delete(lb)
        array.clear(gLabels)

    array.clear(gPrices)

// De-dup by price (small tolerance)
priceExists(float p) =>
    bool ex = false
    int n = array.size(gPrices)
    float tol = syminfo.mintick * 2.0
    if n > 0
        for i = 0 to n - 1
            float q = array.get(gPrices, i)
            if math.abs(q - p) <= tol
                ex := true
                break
    ex

drawQM(float levelPrice, int levelOffset, bool isBuy) =>
    int x1 = bar_index - levelOffset

    color lineCol = isBuy ? supColor : resColor

    line ln = line.new(
         x1     = x1,
         y1     = levelPrice,
         x2     = bar_index,
         y2     = levelPrice,
         xloc   = xloc.bar_index,
         extend = extend.right,
         color  = lineCol,
         width  = 1
         )
    array.push(gLines, ln)
    array.push(gPrices, levelPrice)

    if showLabels
        float off = syminfo.mintick * labelOffsetTicks
        float y   = isBuy ? (levelPrice - off) : (levelPrice + off)
        color bg  = isBuy ? labelBuy : labelSell
        string txt = isBuy ? "Buy QM" : "Sell QM"

        label lb = label.new(
             x         = x1,
             y         = y,
             xloc      = xloc.bar_index,
             yloc      = yloc.price,
             style     = label.style_label_center,
             text      = txt,
             textcolor = color.white,
             size      = labelSize,
             color     = bg
             )
        array.push(gLabels, lb)

// ============================ STRICT DETECTION FUNCTIONS ============================

findEarliestBreakdownBelow(float levelPrice, int maxK) =>
    int br = na
    if maxK >= 1
        for k = maxK to 1
            if isRed(k) and close[k] < levelPrice
                br := k
                break
    br

findEarliestBreakoutAbove(float levelPrice, int maxK) =>
    int br = na
    if maxK >= 1
        for k = maxK to 1
            if isGreen(k) and close[k] > levelPrice
                br := k
                break
    br

// ============================ ALERT SIGNALS ============================
var bool buyQMNow  = false
var bool sellQMNow = false
buyQMNow  := false
sellQMNow := false

// ============================ ALERT LOGIC (BAR-CLOSE ONLY) ============================
if barstate.isconfirmed
    int scanMax = math.min(candleLen, bar_index)

    // ---------------- BUY QM (STRICT) ----------------
    // V detected -> earliest V breakdown -> recent A BEFORE breakdown -> A breakout AFTER breakdown -> mark V
    if showBuyQM and scanMax >= 3
        for vOff = 2 to scanMax
            int vFirst  = vOff
            int vSecond = vOff - 1
            if not isVLevel(vFirst, vSecond)
                continue

            float vPrice = close[vFirst]
            int maxK = vSecond - 1
            int brV = findEarliestBreakdownBelow(vPrice, maxK)
            if na(brV)
                continue

            // recent A between V and breakdown: [brV+1 .. vSecond]
            int aOff = na
            int aStart = brV + 1
            int aEnd   = vSecond
            if aStart <= aEnd
                for j = aStart to aEnd
                    if j >= 2 and isALevel(j, j - 1)
                        aOff := j
                        break
            if na(aOff)
                continue

            float aPrice = close[aOff]

            // Check that no candle BEFORE the current bar already broke A
            bool alreadyBroken = false
            if brV >= 2
                for kk = 1 to brV - 1
                    if isGreen(kk) and close[kk] > aPrice
                        alreadyBroken := true
                        break

            // Alert fires only if current bar is the FIRST to break A
            bool aBrokenAfter = (not alreadyBroken) and isGreen(0) and close[0] > aPrice

            if aBrokenAfter
                buyQMNow := true
                break

    // ---------------- SELL QM (STRICT) ----------------
    // A detected -> earliest A breakout -> recent V BEFORE breakout -> V breakdown AFTER breakout -> mark A
    if showSellQM and scanMax >= 3
        for aOff2 = 2 to scanMax
            int aFirst2  = aOff2
            int aSecond2 = aOff2 - 1
            if not isALevel(aFirst2, aSecond2)
                continue

            float aPrice2 = close[aFirst2]
            int maxK2 = aSecond2 - 1
            int brA = findEarliestBreakoutAbove(aPrice2, maxK2)
            if na(brA)
                continue

            // recent V between A and breakout: [brA+1 .. aSecond2]
            int vOff2 = na
            int vStart2 = brA + 1
            int vEnd2   = aSecond2
            if vStart2 <= vEnd2
                for j2 = vStart2 to vEnd2
                    if j2 >= 2 and isVLevel(j2, j2 - 1)
                        vOff2 := j2
                        break
            if na(vOff2)
                continue

            float vPrice2 = close[vOff2]

            // Check that no candle BEFORE the current bar already broke V
            bool alreadyBroken2 = false
            if brA >= 2
                for kk2 = 1 to brA - 1
                    if isRed(kk2) and close[kk2] < vPrice2
                        alreadyBroken2 := true
                        break

            // Alert fires only if current bar is the FIRST to break V
            bool vBrokenAfter = (not alreadyBroken2) and isRed(0) and close[0] < vPrice2

            if vBrokenAfter
                sellQMNow := true
                break

// ============================ ALERTS ============================
alertcondition(buyQMNow,  title = "Buy QM",  message = "Buy QM | {{ticker}} {{interval}} | {{close}}")
alertcondition(sellQMNow, title = "Sell QM", message = "Sell QM | {{ticker}} {{interval}} | {{close}}")

alertMsg(string tag) =>
    tag + " | " + syminfo.ticker + " " + timeframe.period + " | Close " + str.tostring(close, format.mintick)

if barstate.isconfirmed
    if buyQMNow
        alert(alertMsg("Buy QM"), alert.freq_once_per_bar_close)
    if sellQMNow
        alert(alertMsg("Sell QM"), alert.freq_once_per_bar_close)

// ============================ DRAWING (LAST-BAR REDRAW) ============================
if barstate.islast
    clearAll()
    int scanMax = math.min(candleLen, bar_index)

    // Counters for summary table
    int cBuy  = 0
    int cSell = 0

    // -------- Draw BUY QM --------
    if scanMax >= 3
        for vOff = 2 to scanMax
            int vFirst  = vOff
            int vSecond = vOff - 1
            if not isVLevel(vFirst, vSecond)
                continue

            float vPrice = close[vFirst]
            int maxK = vSecond - 1
            int brV = findEarliestBreakdownBelow(vPrice, maxK)
            if na(brV)
                continue

            int aOff = na
            int aStart = brV + 1
            int aEnd   = vSecond
            if aStart <= aEnd
                for j = aStart to aEnd
                    if j >= 2 and isALevel(j, j - 1)
                        aOff := j
                        break
            if na(aOff)
                continue

            float aPrice = close[aOff]

            bool aBrokenAfter = false
            if brV - 1 >= 1
                for kk = 1 to brV - 1
                    if isGreen(kk) and close[kk] > aPrice
                        aBrokenAfter := true
                        break
            if not aBrokenAfter
                continue

            cBuy += 1
            if showBuyQM and not priceExists(vPrice)
                drawQM(vPrice, vFirst, true)

    // -------- Draw SELL QM --------
    if scanMax >= 3
        for aOff2 = 2 to scanMax
            int aFirst2  = aOff2
            int aSecond2 = aOff2 - 1
            if not isALevel(aFirst2, aSecond2)
                continue

            float aPrice2 = close[aFirst2]
            int maxK2 = aSecond2 - 1
            int brA = findEarliestBreakoutAbove(aPrice2, maxK2)
            if na(brA)
                continue

            int vOff2 = na
            int vStart2 = brA + 1
            int vEnd2   = aSecond2
            if vStart2 <= vEnd2
                for j2 = vStart2 to vEnd2
                    if j2 >= 2 and isVLevel(j2, j2 - 1)
                        vOff2 := j2
                        break
            if na(vOff2)
                continue

            float vPrice2 = close[vOff2]

            bool vBrokenAfter = false
            if brA - 1 >= 1
                for kk2 = 1 to brA - 1
                    if isRed(kk2) and close[kk2] < vPrice2
                        vBrokenAfter := true
                        break
            if not vBrokenAfter
                continue

            cSell += 1
            if showSellQM and not priceExists(aPrice2)
                drawQM(aPrice2, aFirst2, false)

    // -------- Summary Table --------
    if showTable
        table sumTable = table.new(tablePos, 2, 3, border_width = 1, border_color = tableEdge)
        table.cell(sumTable, 0, 0, "Level",    bgcolor = tableHead, text_color = color.white, text_size = tableSize, text_halign = text.align_left)
        table.cell(sumTable, 1, 0, "Count",    bgcolor = tableHead, text_color = color.white, text_size = tableSize)
        table.cell(sumTable, 0, 1, "Buy QM",   bgcolor = tableBg,   text_color = supColor,    text_size = tableSize, text_halign = text.align_left)
        table.cell(sumTable, 1, 1, str.tostring(cBuy),  bgcolor = tableBg, text_color = color.white, text_size = tableSize)
        table.cell(sumTable, 0, 2, "Sell QM",  bgcolor = tableBg,   text_color = resColor,    text_size = tableSize, text_halign = text.align_left)
        table.cell(sumTable, 1, 2, str.tostring(cSell), bgcolor = tableBg, text_color = color.white, text_size = tableSize)
````
