# Engulfing Zone [8 Types]

- url: https://www.tradingview.com/script/GJzk9T7E-Engulfing-Zone-8-Types/
- type: indicator
- pine_id: PUB;bf4b22351e434e4c901fb0b3402d645f
- version: 2.0

## Description

[b]Engulfing Zone [8 Types][/b]

A price action tool that scans closed candles for engulfing behavior and draws the exact zone
each pattern creates, from the candle that sets the level to the candle that breaks it.

Instead of treating "engulfing" as one generic signal, this script separates it into eight
distinct types and reports every pattern under exactly one of them, so what you see on the
chart is never double counted.


[b]WHAT MAKES THIS DIFFERENT FROM A STANDARD ENGULFING INDICATOR[/b]

[b]1. Engulfing is measured by the CLOSE, not by body overlap.[/b]

Most engulfing scripts check whether one candle's body covers the previous candle's body.
This script requires the Confirm candle to CLOSE beyond the Base candle's High or Low, wick
included. A candle that merely covers the body but closes back inside the Base range is not
accepted. This is a stricter definition and it filters out a large number of weak signals that
body based detection would report.

[b]2. Confirmation is allowed to be delayed.[/b]

A classic engulfing pattern is strictly two candles. In real markets the reaction is often
spread over several candles: a base forms, price pushes in the opposite direction for a few
bars, and only then does a close break the base level. This script detects those extended
setups as their own category rather than ignoring them.

[b]3. Liquidity sweeps are identified as a separate class.[/b]

Sometimes the candles that produce the engulf first trade through the far side of the Base
candle, taking out the stop orders resting there, and only then close through the opposite
side. That behavior is meaningfully different from a clean engulf, so it is detected and
labelled separately as Type 1.


[b]THE EIGHT PATTERNS[/b]

Throughout, a candle is Green when close is greater than open, Red when close is less than
open, and a Doji when close equals open. A Doji is neither Green nor Red, and is handled
explicitly. Only fully closed candles are read. The running candle is never used.

[b]Regular (2 candles)[/b]

[b]R Buy EG[/b]
[list]
[*]Base candle is Red
[*]The very next candle is Green
[*]That Green candle closes above the Base candle's High
[/list]

[b]R Sell EG[/b]
[list]
[*]Base candle is Green
[*]The very next candle is Red
[*]That Red candle closes below the Base candle's Low
[/list]

[b]E-Regular (3 or more candles)[/b]

[b]ER Buy EG[/b]
[list]
[*]Base candle is Red
[*]It is followed by a run of consecutive Green candles
[*]The run must contain at least 2 Green candles
[*]Confirmation happens when one of those Green candles closes above the Base candle's High
[*]A single Red candle appearing before confirmation cancels the run entirely
[*]Doji candles are skipped: they neither count toward the run nor break it
[/list]

[b]ER Sell EG[/b]
[list]
[*]Base candle is Green
[*]It is followed by a run of consecutive Red candles
[*]The run must contain at least 2 Red candles
[*]Confirmation happens when one of those Red candles closes below the Base candle's Low
[*]A single Green candle appearing before confirmation cancels the run entirely
[*]Doji candles are skipped
[/list]

If the very first candle after the Base already closes through it, that is by definition a
Regular pattern, so E-Regular requires the second candle or later to be the one that breaks
the level. Regular and E-Regular can therefore never both fire from the same Base candle.

[b]Type 1: the same four patterns plus a liquidity sweep[/b]

Type 1 adds one requirement on top of the rules above. Before the close breaks through one
side of the Base candle, price must have traded through the opposite side.

[b]T1 R Buy EG[/b]
An R Buy EG where the Confirm candle's Low is at or below the Base candle's Low.

[b]T1 R Sell EG[/b]
An R Sell EG where the Confirm candle's High is at or above the Base candle's High.

[b]T1 ER Buy EG[/b]
An ER Buy EG where at least one Green candle in the run has a Low at or below the Base
candle's Low. Any candle of the run qualifies, including the Confirm candle itself.

[b]T1 ER Sell EG[/b]
An ER Sell EG where at least one Red candle in the run has a High at or above the Base
candle's High. Any candle of the run qualifies, including the Confirm candle itself.

The sweep is always measured against the Base candle, never against another candle in the run.


[b]HOW A PATTERN IS CLASSIFIED[/b]

Every detected pattern is reported once, under its strongest matching type.

A Regular pattern that also swept is reported as T1 R and is not additionally reported as R.
An E-Regular pattern that also swept is reported as T1 ER and is not additionally reported as
ER. This means:

[list]
[*]One pattern produces exactly one zone on the chart, never two stacked on top of each other
[*]The summary table counts each pattern once
[*]Turning off a type hides only that type and never silently hides another
[/list]

Because Type 1 is a stricter version of its plain counterpart, hiding the plain types and
keeping the Type 1 types visible is a straightforward way to see only the sweep driven setups.


[b]READING THE CHART[/b]

Each detected pattern draws a rectangle covering the Base candle's full High to Low range,
stretched horizontally from the Base candle to the Confirm candle. The rectangle is styled so
that its type can be read without looking at the label:

[list]
[*]Solid border: Regular, confirmed by the very next candle
[*]Dashed border: E-Regular, confirmation was delayed over several candles
[*]Thin, softened border: a plain pattern, no sweep
[*]Thick, crisp border: Type 1, a liquidity sweep occurred
[/list]

Type 1 zones are also filled more solidly than plain zones, so stronger patterns stand out
when several zones sit close together.

On a Type 1 zone, a dotted line marks the exact Base level that was raided before the break:
the Base Low on the Buy side, the Base High on the Sell side. This makes the liquidity grab
visible instead of leaving it implied.

Each zone carries a label showing its pattern tag. Labels point at their own zone, below and
pointing up for Buy patterns, above and pointing down for Sell patterns, so it is always clear
which label belongs to which rectangle.

A summary table in the corner shows how many of each type were found inside the current scan
window, split into Buy and Sell columns. The table counts every detected pattern, including
types that are currently hidden, so it always reflects what the market actually printed rather
than what is currently switched on.


[b]SETTINGS[/b]

[b]Scan[/b]
Scan Length: how many closed candles are scanned backwards from the latest bar. 
The running candle is always excluded.

[b]Pattern Types[/b]
An individual on and off switch for each of the eight types.

[b]Zone Style[/b]
- Bullish Zone and Bearish Zone: the two base colors used for all Buy and all Sell zones.
- Zone Transparency: fill transparency of a plain Regular or E-Regular zone.
- Type 1 Extra Opacity: how much more solid Type 1 zones are filled compared to the value
  above.
- Mark Swept Level: draw the dotted line on the raided Base level of Type 1 zones.
- Swept Level Color: color of that line.

[b]Labels[/b]
- Show Labels, Label Size, and Label Distance from Zone as a percentage of the Base candle
  height. Increase the distance on noisy charts so labels clear the candles.

[b]Summary Table[/b]
- Show, position, and size of the corner table.


[b]ALERTS[/b]

Eight alert conditions are available, one per pattern type:

R Buy EG, R Sell EG, T1 R Buy EG, T1 R Sell EG, ER Buy EG, ER Sell EG, T1 ER Buy EG,
T1 ER Sell EG.

Each message carries the pattern tag, the symbol, the timeframe and the closing price. The
script also sends the same messages through the alert function, so the "Any alert() function
call" alert type can be used to receive every pattern through a single alert.

All alerts are evaluated only after a candle has fully closed.


[b]REPAINTING[/b]

This script does not repaint.

- Detection reads confirmed candles only. The zone scan starts one bar behind the latest bar,
  so the candle that is still forming is never part of any calculation.
- Every alert signal is written so that it can only become true once a candle has finished.
  Price moving inside an open candle cannot make a signal appear and then disappear.
- Zones are rebuilt on the last bar using confirmed history. A zone that has been drawn does
  not move or change type afterwards. It only leaves the chart when it falls outside the Scan
  Length window.

When you create an alert, TradingView may show a caution banner saying the indicator can
repaint. That banner appears automatically for any script that uses the built in bar state
variables, no matter how they are used, because the platform cannot check the intent behind
them. This script uses them for the opposite purpose: one of them is what restricts every
signal to bar close, and the other is what redraws the zones efficiently on the final bar.
Choosing "Once Per Bar Close" when creating the alert is still recommended.


[b]NOTES AND LIMITATIONS[/b]

- The script draws on the last bar only. Increasing Scan Length raises the number of drawing
  objects. TradingView caps these at 500 boxes, 500 labels and 500 lines, and the oldest
  objects are dropped once a cap is reached. The default value is chosen to stay well inside
  those limits on normal charts.
- Detection is purely structural. It reports where a pattern occurred and nothing more. It
  does not rank patterns by quality, measure follow through, or produce entries, targets or
  stops.
- Doji candles are treated as neutral by design. They never act as a Base candle and never
  break an E-Regular run. On symbols and timeframes that print many Doji candles this makes
  runs slightly more tolerant than a strict same color rule would be.


[b]HOW TO USE IT[/b]

The zones mark where one side of the market decisively lost control of a level. They are
reference areas, not entry signals on their own. Common approaches are to watch how price
behaves when it returns to a zone, or to use zone direction as context alongside higher
timeframe structure, support and resistance levels, or trend direction.

Type 1 zones deserve particular attention, because the sweep tells you the move happened after
liquidity was taken rather than before.


[b]DISCLAIMER[/b]

This indicator is a pattern detection tool. It is not financial advice and it makes no claim
about profitability. Trading involves risk. Always apply your own analysis and risk management.

## Source Code

````pine
//@version=6
indicator(
     title            = "Engulfing Zone [8 Types]",
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

showRegBuy    = input.bool(true, "Regular Buy",           group = gType)
showRegSell   = input.bool(true, "Regular Sell",          group = gType)
showErBuy     = input.bool(true, "E-Regular Buy",         group = gType)
showErSell    = input.bool(true, "E-Regular Sell",        group = gType)
showT1RegBuy  = input.bool(true, "Type 1 Regular Buy",    group = gType)
showT1RegSell = input.bool(true, "Type 1 Regular Sell",   group = gType)
showT1ErBuy   = input.bool(true, "Type 1 E-Regular Buy",  group = gType)
showT1ErSell  = input.bool(true, "Type 1 E-Regular Sell", group = gType)

bullColor  = input.color(#22c55e, "Bullish Zone",     group = gStyle)
bearColor  = input.color(#ef4444, "Bearish Zone",     group = gStyle)
zoneTransp = input.int(80, "Zone Transparency", minval = 0, maxval = 95, group = gStyle,
     tooltip = "Transparency of a plain Regular / E-Regular zone.")
t1Emphasis = input.int(20, "Type 1 Extra Opacity", minval = 0, maxval = 50, group = gStyle,
     tooltip = "Type 1 zones are filled this much more solid than the value above, so swept patterns stand out.")
showSweep  = input.bool(true,    "Mark Swept Level (Type 1)", group = gStyle)
sweepColor = input.color(#f59e0b, "Swept Level Color",        group = gStyle)

showLabels     = input.bool(true, "Show Labels", group = gLabel)
labelSizeStr   = input.string("Normal", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gLabel)
labelOffsetPct = input.int(40, "Label Distance from Zone (%)", minval = 0, group = gLabel,
     tooltip = "Gap between the zone edge and the label, as a percentage of the Base candle height.")

showTable    = input.bool(true, "Show Summary Table", group = gTable)
tablePosStr  = input.string("Top Right", "Table Position", options = ["Top Right", "Middle Right", "Bottom Right", "Top Left", "Bottom Left"], group = gTable)
tableSizeStr = input.string("Small", "Table Size", options = ["Tiny", "Small", "Normal"], group = gTable)

// ============================ STYLE CONSTANTS ============================
labelBull = #107a34                     // deep green label background
labelBear = #b22222                     // deep red label background
tableHead = #000000
tableBg   = #1e222d
tableEdge = #363a45

labelSize = labelSizeStr == "Tiny" ? size.tiny : labelSizeStr == "Small" ? size.small : labelSizeStr == "Large" ? size.large : size.normal
tableSize = tableSizeStr == "Tiny" ? size.tiny : tableSizeStr == "Normal" ? size.normal : size.small
tablePos  = tablePosStr == "Top Right" ? position.top_right : tablePosStr == "Middle Right" ? position.middle_right : tablePosStr == "Bottom Right" ? position.bottom_right : tablePosStr == "Top Left" ? position.top_left : position.bottom_left

// ============================ CANDLE COLOUR HELPERS ============================
// A Doji (close == open) is neither Green nor Red. It never acts as a Base and
// never breaks an E-Regular run - it is simply skipped.
isGreen(int i) => close[i] > open[i]
isRed(int i)   => close[i] < open[i]
isDoji(int i)  => close[i] == open[i]

// ============================ PATTERN SCANNERS ============================
// Both scanners take the offset of a candidate Base candle and look FORWARD in
// time (towards smaller offsets) for its Confirm candle.

// Regular scan. The Confirm candle always sits exactly one bar after the Base.
// Returns [dir, swept]
//   dir   :  1 = Buy pattern, -1 = Sell pattern, 0 = no pattern
//   swept : true when the Confirm candle also raided the far side of the Base,
//           which promotes the pattern to Type 1
regularScan(int baseOff) =>
    int  dir   = 0
    bool swept = false
    if baseOff >= 2
        int c = baseOff - 1
        if isRed(baseOff) and isGreen(c) and close[c] > high[baseOff]
            dir   := 1
            swept := low[c] <= low[baseOff]
        else if isGreen(baseOff) and isRed(c) and close[c] < low[baseOff]
            dir   := -1
            swept := high[c] >= high[baseOff]
    [dir, swept]

// E-Regular scan. Confirmation is delayed by a run of same-colour candles.
// Returns [dir, dist, swept]
//   dir   :  1 = Buy pattern, -1 = Sell pattern, 0 = no pattern
//   dist  : how many bars after the Base the Confirm candle sits
//   swept : true when ANY candle of the run raided the far side of the Base,
//           the Confirm candle itself included
eRegularScan(int baseOff) =>
    int  dir   = 0
    int  dist  = 0
    bool swept = false
    if baseOff >= 3
        float baseHigh = high[baseOff]
        float baseLow  = low[baseOff]

        // ---- Buy side: Red Base, run of Green candles ----
        if isRed(baseOff)
            int  greens = 0
            bool sw     = false
            for m = 1 to baseOff - 1
                int k = baseOff - m
                if isDoji(k)
                    continue
                if isRed(k)
                    break
                greens += 1
                sw := sw or low[k] <= baseLow
                if close[k] > baseHigh
                    // A break on the first Green candle is a Regular pattern,
                    // so E-Regular needs at least two Green candles.
                    if greens >= 2
                        dir   := 1
                        dist  := m
                        swept := sw
                    break

        // ---- Sell side: Green Base, run of Red candles ----
        else if isGreen(baseOff)
            int  reds = 0
            bool sw2  = false
            for m = 1 to baseOff - 1
                int k = baseOff - m
                if isDoji(k)
                    continue
                if isGreen(k)
                    break
                reds += 1
                sw2 := sw2 or high[k] >= baseHigh
                if close[k] < baseLow
                    if reds >= 2
                        dir   := -1
                        dist  := m
                        swept := sw2
                    break
    [dir, dist, swept]

// ============================ TYPE HELPERS ============================
// Builds the pattern tag from the three flags that fully describe a zone.
zoneTag(bool isBuy, bool isExt, bool isT1) =>
    (isT1 ? "T1 " : "") + (isExt ? "ER " : "R ") + (isBuy ? "Buy" : "Sell") + " EG"

zoneVisible(bool isBuy, bool isExt, bool isT1) =>
    bool v = false
    if isT1
        v := isExt ? (isBuy ? showT1ErBuy : showT1ErSell) : (isBuy ? showT1RegBuy : showT1RegSell)
    else
        v := isExt ? (isBuy ? showErBuy : showErSell) : (isBuy ? showRegBuy : showRegSell)
    v

// ============================ DRAWING ============================
var box[]   gBoxes  = array.new_box()
var label[] gLabels = array.new_label()
var line[]  gLines  = array.new_line()

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

    int nn = array.size(gLines)
    if nn > 0
        for j = 0 to nn - 1
            line ln = array.get(gLines, j)
            if not na(ln)
                line.delete(ln)
        array.clear(gLines)

// Draws one zone: the Base candle range stretched from the Base bar to the
// Confirm bar, styled so the pattern type is readable at a glance.
//   solid border  = Regular        dashed border = E-Regular
//   thin border   = plain          thick border  = Type 1 (swept)
drawZone(int baseOff, int dist, bool isBuy, bool isExt, bool isT1) =>
    int   confOff = baseOff - dist
    int   xBase   = bar_index - baseOff
    int   xConf   = bar_index - confOff
    float yTop    = high[baseOff]
    float yBot    = low[baseOff]

    color baseCol = isBuy ? bullColor : bearColor
    float fillT   = isT1 ? math.max(0, zoneTransp - t1Emphasis) : zoneTransp

    // Type 1 gets a crisp border, plain types a softer one, so the stronger
    // pattern reads first when zones sit close together.
    box b = box.new(xBase, yTop, xConf, yBot,
         xloc         = xloc.bar_index,
         border_color = color.new(baseCol, isT1 ? 0 : 35),
         border_width = isT1 ? 2 : 1,
         border_style = isExt ? line.style_dashed : line.style_solid,
         bgcolor      = color.new(baseCol, fillT))
    array.push(gBoxes, b)

    // Type 1 only: highlight the Base level that was raided before the break.
    if isT1 and showSweep
        float sweepY = isBuy ? yBot : yTop
        line sl = line.new(xBase, sweepY, xConf, sweepY,
             xloc  = xloc.bar_index,
             color = sweepColor,
             width = 2,
             style = line.style_dotted)
        array.push(gLines, sl)

    if showLabels
        float h   = math.abs(yTop - yBot)
        float off = h * labelOffsetPct * 0.01
        float y   = isBuy ? yBot - off : yTop + off
        int   x   = xBase + int(math.round((xConf - xBase) / 2.0))
        // The pointer style makes the label visually attach to its own zone.
        label lb = label.new(x, y,
             text      = zoneTag(isBuy, isExt, isT1),
             xloc      = xloc.bar_index,
             yloc      = yloc.price,
             style     = isBuy ? label.style_label_up : label.style_label_down,
             color     = isBuy ? labelBull : labelBear,
             textcolor = color.white,
             size      = labelSize)
        array.push(gLabels, lb)

// ============================ SUMMARY TABLE ============================
var table sumTable = table.new(tablePos, 3, 5, border_width = 1, border_color = tableEdge)

tableRow(int row, string name, int buyN, int sellN) =>
    table.cell(sumTable, 0, row, name, bgcolor = tableBg, text_color = color.white, text_size = tableSize, text_halign = text.align_left)
    table.cell(sumTable, 1, row, str.tostring(buyN),  bgcolor = tableBg, text_color = bullColor, text_size = tableSize)
    table.cell(sumTable, 2, row, str.tostring(sellN), bgcolor = tableBg, text_color = bearColor, text_size = tableSize)

// ============================ MAIN SCAN AND REDRAW ============================
// Everything is rebuilt on the last bar only, from confirmed candles, so the
// drawings never repaint intrabar.
if barstate.islast
    clearAll()

    int cRegBuy    = 0
    int cRegSell   = 0
    int cErBuy     = 0
    int cErSell    = 0
    int cT1RegBuy  = 0
    int cT1RegSell = 0
    int cT1ErBuy   = 0
    int cT1ErSell  = 0

    int maxScan = math.min(candleLen, bar_index)

    for i = 1 to maxScan
        [rDir, rSwept] = regularScan(i)

        int  dir   = rDir
        int  dist  = 1
        bool swept = rSwept
        bool isExt = false

        // E-Regular is only considered when no Regular formed on this Base.
        if dir == 0
            [eDir, eDist, eSwept] = eRegularScan(i)
            dir   := eDir
            dist  := eDist
            swept := eSwept
            isExt := true

        if dir != 0
            bool isBuy = dir > 0

            // Counted even when the type is hidden, so the table always shows
            // what the market actually printed.
            if isExt and swept and isBuy
                cT1ErBuy += 1
            else if isExt and swept
                cT1ErSell += 1
            else if isExt and isBuy
                cErBuy += 1
            else if isExt
                cErSell += 1
            else if swept and isBuy
                cT1RegBuy += 1
            else if swept
                cT1RegSell += 1
            else if isBuy
                cRegBuy += 1
            else
                cRegSell += 1

            if zoneVisible(isBuy, isExt, swept)
                drawZone(i, dist, isBuy, isExt, swept)

    if showTable
        table.cell(sumTable, 0, 0, "Pattern", bgcolor = tableHead, text_color = color.white, text_size = tableSize, text_halign = text.align_left)
        table.cell(sumTable, 1, 0, "Buy",     bgcolor = tableHead, text_color = color.white, text_size = tableSize)
        table.cell(sumTable, 2, 0, "Sell",    bgcolor = tableHead, text_color = color.white, text_size = tableSize)
        tableRow(1, "Regular",      cRegBuy,   cRegSell)
        tableRow(2, "E-Regular",    cErBuy,    cErSell)
        tableRow(3, "T1 Regular",   cT1RegBuy, cT1RegSell)
        tableRow(4, "T1 E-Regular", cT1ErBuy,  cT1ErSell)
    else
        table.clear(sumTable, 0, 0, 2, 4)

// ============================ LIVE PATTERN STATE (BAR CLOSE ONLY) ============================
// The drawing pass above works on history. Alerts need the pattern evaluated on
// the candle that has just closed, so that logic is mirrored here with offset 0
// as the Confirm candle.

// ---- Regular: Base is offset 1, Confirm is the candle that just closed ----
regBuyRaw    = isRed(1)   and isGreen(0) and close > high[1]
regSellRaw   = isGreen(1) and isRed(0)   and close < low[1]
regBuySwept  = regBuyRaw  and low  <= low[1]
regSellSwept = regSellRaw and high >= high[1]

// ---- E-Regular: rolling state machine over closed candles ----
var float erBuyHigh   = na
var float erBuyLow    = na
var int   erBuyGreens = 0
var bool  erBuySwept  = false
var bool  erBuyDone   = false

var float erSellHigh   = na
var float erSellLow    = na
var int   erSellReds   = 0
var bool  erSellSwept  = false
var bool  erSellDone   = false

if barstate.isconfirmed
    // Buy side: a Red candle starts a new Base, Green candles extend the run.
    if isRed(0)
        erBuyHigh   := high
        erBuyLow    := low
        erBuyGreens := 0
        erBuySwept  := false
        erBuyDone   := false
    else if isGreen(0) and not na(erBuyHigh)
        erBuyGreens += 1
        erBuySwept  := erBuySwept or low <= erBuyLow
    // A Doji falls through both branches: skipped, run preserved.

    // Sell side: a Green candle starts a new Base, Red candles extend the run.
    if isGreen(0)
        erSellHigh  := high
        erSellLow   := low
        erSellReds  := 0
        erSellSwept := false
        erSellDone  := false
    else if isRed(0) and not na(erSellLow)
        erSellReds  += 1
        erSellSwept := erSellSwept or high >= erSellHigh

// Only the FIRST candle that breaks the Base confirms the run, matching the
// historical scanner, so one Base can never fire twice.
erBuyHit  = barstate.isconfirmed and not na(erBuyHigh) and not erBuyDone  and isGreen(0) and erBuyGreens >= 2 and close > erBuyHigh
erSellHit = barstate.isconfirmed and not na(erSellLow) and not erSellDone and isRed(0)   and erSellReds  >= 2 and close < erSellLow

// A Regular pattern also consumes its Base candle, otherwise the same Base could
// confirm as Regular first and then again as E-Regular a few candles later.
if barstate.isconfirmed and (erBuyHit or regBuyRaw)
    erBuyDone := true
if barstate.isconfirmed and (erSellHit or regSellRaw)
    erSellDone := true

// Regular wins over E-Regular on the same candle.
erBuyCond  = erBuyHit  and not regBuyRaw
erSellCond = erSellHit and not regSellRaw

// ============================ SIGNALS (STRONGEST TYPE WINS) ============================
confirmed = barstate.isconfirmed

sigRBuy     = confirmed and regBuyRaw  and not regBuySwept
sigRSell    = confirmed and regSellRaw and not regSellSwept
sigT1RBuy   = confirmed and regBuySwept
sigT1RSell  = confirmed and regSellSwept
sigErBuy    = confirmed and erBuyCond  and not erBuySwept
sigErSell   = confirmed and erSellCond and not erSellSwept
sigT1ErBuy  = confirmed and erBuyCond  and erBuySwept
sigT1ErSell = confirmed and erSellCond and erSellSwept

// ============================ ALERTS ============================
alertcondition(sigRBuy,     title = "R Buy EG",     message = "R Buy EG | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigRSell,    title = "R Sell EG",    message = "R Sell EG | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigT1RBuy,   title = "T1 R Buy EG",  message = "T1 R Buy EG | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigT1RSell,  title = "T1 R Sell EG", message = "T1 R Sell EG | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigErBuy,    title = "ER Buy EG",    message = "ER Buy EG | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigErSell,   title = "ER Sell EG",   message = "ER Sell EG | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigT1ErBuy,  title = "T1 ER Buy EG", message = "T1 ER Buy EG | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigT1ErSell, title = "T1 ER Sell EG", message = "T1 ER Sell EG | {{ticker}} {{interval}} | Close {{close}}")

// Dynamic message for the "Any alert() function call" alert type.
alertMsg(string tag) =>
    tag + " | " + syminfo.ticker + " " + timeframe.period + " | Close " + str.tostring(close, format.mintick)

if confirmed
    if sigRBuy
        alert(alertMsg("R Buy EG"), alert.freq_once_per_bar_close)
    if sigRSell
        alert(alertMsg("R Sell EG"), alert.freq_once_per_bar_close)
    if sigT1RBuy
        alert(alertMsg("T1 R Buy EG"), alert.freq_once_per_bar_close)
    if sigT1RSell
        alert(alertMsg("T1 R Sell EG"), alert.freq_once_per_bar_close)
    if sigErBuy
        alert(alertMsg("ER Buy EG"), alert.freq_once_per_bar_close)
    if sigErSell
        alert(alertMsg("ER Sell EG"), alert.freq_once_per_bar_close)
    if sigT1ErBuy
        alert(alertMsg("T1 ER Buy EG"), alert.freq_once_per_bar_close)
    if sigT1ErSell
        alert(alertMsg("T1 ER Sell EG"), alert.freq_once_per_bar_close)
````
