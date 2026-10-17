# Engulfing Failed Zone [8 Types]

- url: https://www.tradingview.com/script/dbeuZ8JK-Engulfing-Failed-Zone-8-Types/
- type: indicator
- pine_id: PUB;b230bcd0d42744c38d28488e6f6babbc
- version: 1.0

## Description

[b]Engulfing Failed Zone [8 Types][/b]

Most engulfing tools show you where a pattern formed. This one shows you where it broke.

The script finds confirmed engulfing patterns and then keeps watching them. When price later
closes back through the far side of the pattern's Base candle, the pattern is invalidated and
the area it occupied is drawn as a failed zone, from the Base candle to the exact candle that
broke it.

A failed pattern is not noise. It marks a level where one side committed, was proven wrong,
and left an area behind that price often reacts to again.


[b]WHAT MAKES THIS DIFFERENT[/b]

[b]1. It tracks invalidation, not formation.[/b]

A normal engulfing indicator stops working the moment the pattern prints. This script treats
the pattern as an open structure and follows it forward until something breaks it. Only the
broken ones are drawn, so the chart shows failures rather than signals.

[b]2. Failure is defined by the close, not by a wick.[/b]

A candle may spike through the Base candle and recover. That is not a failure here. The
breaking candle has to CLOSE beyond the level, and it has to be the correct color: a Red
candle closing below the Base Low breaks a Buy Engulfing, a Green candle closing above the
Base High breaks a Sell Engulfing.

[b]3. Failed zones are sorted into eight types, not two.[/b]

The failure inherits the identity of the pattern that failed. A liquidity sweep engulfing that
fails is a different event from a plain two candle engulfing that fails, and the script keeps
them separate so you can study or filter them independently.

[b]4. Only the first failure is drawn.[/b]

Once a pattern breaks, it is done. Later candles closing through the same level are not drawn
again, which keeps the chart readable instead of stacking boxes on one level.


[b]THE PATTERNS BEING TRACKED[/b]

A candle is Green when close is greater than open, Red when close is less than open, and a
Doji when close equals open. A Doji is neither. Only fully closed candles are read, and the
running candle is never used.

[b]Regular engulfing (2 candles)[/b]

[b]R Buy EG[/b]
Red Base candle, and the very next candle is Green and closes above the Base candle's High.

[b]R Sell EG[/b]
Green Base candle, and the very next candle is Red and closes below the Base candle's Low.

E-Regular engulfing (3 or more candles)

[b]ER Buy EG[/b]
Red Base candle followed by a run of consecutive Green candles. The run must contain at least
2 Green candles, and confirmation happens when one of them closes above the Base candle's
High. A single Red candle appearing before confirmation cancels the run. Doji candles are
skipped: they neither count toward the run nor break it.

[b]ER Sell EG[/b]
Green Base candle followed by a run of at least 2 consecutive Red candles, one of which closes
below the Base candle's Low. A single Green candle cancels the run. Doji candles are skipped.

If the very first candle after the Base already closes through it, that is by definition a
Regular pattern, so E-Regular requires the second candle or later to break the level. One Base
candle can therefore never produce both a Regular and an E-Regular pattern.

[b]Type 1: the same four patterns plus a liquidity sweep[/b]

Type 1 adds one requirement. Before the close breaks through one side of the Base candle,
price must have traded through the opposite side.

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


[b]WHAT COUNTS AS A FAILURE[/b]

After a pattern confirms, the script scans forward one candle at a time.

A Buy Engulfing fails when a Red candle closes strictly below the Base candle's Low.
A Sell Engulfing fails when a Green candle closes strictly above the Base candle's High.

The scan begins on the candle after the Confirm candle, so a pattern is never judged by its
own confirmation. The first candle that meets the condition becomes the Failure candle, and
the zone is drawn from the Base candle across to it. Nothing is drawn for patterns that are
still intact.

That gives eight failed zone types in total: R Buy EG Failed, R Sell EG Failed, ER Buy EG
Failed, ER Sell EG Failed, and the four Type 1 versions of the same.


[b]READING THE CHART[/b]

Each failed pattern draws a rectangle covering the Base candle's full High to Low range,
stretched horizontally from the Base candle to the candle that broke it.

Colors follow the OUTCOME, not the original direction. This is worth reading twice:

- A Buy Engulfing that failed is drawn in the bearish color. The buyers committed and lost, so
  the area above is now resistance, and its label sits above the zone.
- A Sell Engulfing that failed is drawn in the bullish color. The sellers committed and lost,
  so the area is now support, and its label sits below the zone.

In other words the zone is colored by who is in control after the failure, which is the
information you actually trade from.

The border tells you which pattern failed:

[list]
[*]Solid border: a Regular pattern, confirmed by the very next candle
[*]Dashed border: an E-Regular pattern, confirmation was delayed over several candles
[*]Thin, softened border: a plain pattern, no sweep
[*]Thick, crisp border: Type 1, a liquidity sweep occurred before confirmation
[/list]

Type 1 zones are also filled more solidly, so the stronger patterns stand out when several
zones sit close together.

A separate line marks the broken edge of the Base candle: the Low for a failed Buy Engulfing,
the High for a failed Sell Engulfing. This shows at a glance which side of the pattern gave
way, and it is the level price most often returns to.

Each zone carries a label with its pattern tag, pointing at its own zone, so it is always
clear which label belongs to which rectangle.

A summary table in the corner counts how many of each type were found in the current scan
window, split into Buy EG and Sell EG columns. The counts include types that are currently
hidden, so the table always reflects what the market actually printed rather than what is
switched on.


[b]SETTINGS[/b]

[b]Scan[/b]
- Scan Length: how many closed candles are scanned backwards from the latest bar. The running
  candle is always excluded.

[b]Pattern Types[/b]
- An individual on and off switch for each of the eight failed zone types.

[b]Zone Style[/b]
- Buy EG Failed Zone and Sell EG Failed Zone: the two zone colors. Defaults follow the outcome
  logic described above.
- Zone Transparency: fill transparency of a plain Regular or E-Regular failed zone.
- Type 1 Extra Opacity: how much more solid Type 1 zones are filled compared to the value
  above.
- Highlight Broken Edge, and its color: marks the side of the Base candle price closed
  through.

[b]Labels[/b]
- Show Labels, Label Size, and Label Distance from Zone as a percentage of the Base candle
  height. Increase the distance on noisy charts so labels clear the candles.

Summary Table
- Show, position, and size of the corner table.


[b]ALERTS[/b]

Eight alert conditions are available, one per failed zone type:

R Buy EG Failed, R Sell EG Failed, T1 R Buy EG Failed, T1 R Sell EG Failed, ER Buy EG Failed,
ER Sell EG Failed, T1 ER Buy EG Failed, T1 ER Sell EG Failed.

An alert fires on the candle that completes the failure. Each message carries the pattern tag,
the symbol, the timeframe and the closing price. The script also sends the same messages
through the alert function, so the "Any alert() function call" alert type can deliver every
failure through a single alert.

All alerts are evaluated only after a candle has fully closed.

Internally, every confirmed engulfing is held in a list and each closed candle is checked
against that list. This is what allows a failure to be reported the moment it happens, without
rescanning the whole history on every bar.


[b]REPAINTING[/b]

This script does not repaint.

- Detection reads confirmed candles only. The scan starts one bar behind the latest bar, so
  the candle that is still forming is never part of any calculation.
- Every alert signal is written so that it can only become true once a candle has finished.
  Price moving inside an open candle cannot make a signal appear and then disappear.
- Zones are rebuilt on the last bar using confirmed history. A drawn zone does not move,
  change color or change type afterwards. It only leaves the chart when it falls outside the
  Scan Length window.

When you create an alert, TradingView may show a caution banner saying the indicator can
repaint. That banner appears automatically for any script that uses the built in bar state
variables, no matter how they are used, because the platform cannot check the intent behind
them. This script uses them for the opposite purpose: one of them is what restricts every
signal to bar close, and the other is what redraws the zones efficiently on the final bar.
Choosing "Once Per Bar Close" when creating the alert is still recommended.


[b]NOTES AND LIMITATIONS[/b]

- Nothing is drawn for a pattern that has not failed. An empty chart means the engulfing
  patterns in that window are all still intact, which is information in itself.
- Increasing Scan Length raises the number of drawing objects. TradingView caps these at 500
  boxes, 500 labels and 500 lines, and the oldest objects are dropped once a cap is reached.
  The default value is chosen to stay well inside those limits on normal charts.
- A very short Scan Length can hide zones whose Base candle sits outside the window even
  though the failure is recent. If failures seem to be missing, raise the Scan Length.
- For alerts, the number of patterns tracked at once is capped, and the oldest are released
  first. In practice patterns fail or age out long before this matters.
- Detection is purely structural. It reports where a pattern broke and nothing more. It does
  not rank failures by quality, measure what happened afterwards, or produce entries, targets
  or stops.
- Doji candles are treated as neutral by design. They never act as a Base candle and never
  break an E-Regular run. On symbols and timeframes that print many Doji candles this makes
  runs slightly more tolerant than a strict same color rule would be.


[b]HOW TO USE IT[/b]

A failed engulfing zone marks a level where one side of the market committed and was proven
wrong. Traders commonly watch these areas for:

- Broken supply and demand zones that price returns to and respects from the other side
- Areas where a reversal attempt was flushed out before the move continued
- Momentum shifts, since a failed reversal often precedes a strong continuation

Type 1 failed zones are worth separating out. There the pattern first grabbed liquidity, then
confirmed, and then still failed, which is a different story from a clean pattern simply being
overrun.

These zones are reference areas, not entry signals on their own. Use them alongside higher
timeframe structure, your own support and resistance mapping, and proper risk management.


[b]DISCLAIMER[/b]

This indicator is a pattern detection tool. It is not financial advice and it makes no claim
about profitability. Trading involves risk. Always apply your own analysis and risk management.

## Source Code

````pine
//@version=6
indicator(
     title            = "Engulfing Failed Zone [8 Types]",
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

candleLen = input.int(100, "Scan Length (closed candles)", minval = 4, maxval = 1000, group = gScan,
     tooltip = "How many closed candles are scanned backwards from the latest bar. The running candle is always excluded.")

showRegBuy    = input.bool(true, "Regular Buy Failed",           group = gType)
showRegSell   = input.bool(true, "Regular Sell Failed",          group = gType)
showErBuy     = input.bool(true, "E-Regular Buy Failed",         group = gType)
showErSell    = input.bool(true, "E-Regular Sell Failed",        group = gType)
showT1RegBuy  = input.bool(true, "Type 1 Regular Buy Failed",    group = gType)
showT1RegSell = input.bool(true, "Type 1 Regular Sell Failed",   group = gType)
showT1ErBuy   = input.bool(true, "Type 1 E-Regular Buy Failed",  group = gType)
showT1ErSell  = input.bool(true, "Type 1 E-Regular Sell Failed", group = gType)

// A failed Buy Engulfing leaves resistance behind, a failed Sell Engulfing leaves
// support, so the zone is coloured by what it means AFTER the failure.
buyFailColor  = input.color(#ef4444, "Buy EG Failed Zone",  group = gStyle,
     tooltip = "A Buy Engulfing that failed. The zone now acts as resistance.")
sellFailColor = input.color(#22c55e, "Sell EG Failed Zone", group = gStyle,
     tooltip = "A Sell Engulfing that failed. The zone now acts as support.")
zoneTransp    = input.int(80, "Zone Transparency", minval = 0, maxval = 95, group = gStyle,
     tooltip = "Transparency of a plain Regular or E-Regular failed zone.")
t1Emphasis    = input.int(20, "Type 1 Extra Opacity", minval = 0, maxval = 50, group = gStyle,
     tooltip = "Type 1 zones are filled this much more solid than the value above, so swept patterns stand out.")
showBroken    = input.bool(true,    "Highlight Broken Edge", group = gStyle,
     tooltip = "Marks the side of the Base candle that price closed through when the pattern failed.")
brokenColor   = input.color(#f59e0b, "Broken Edge Color",    group = gStyle)

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

maxActive = 200                         // cap on engulfing zones tracked for live alerts

labelSize = labelSizeStr == "Tiny" ? size.tiny : labelSizeStr == "Small" ? size.small : labelSizeStr == "Large" ? size.large : size.normal
tableSize = tableSizeStr == "Tiny" ? size.tiny : tableSizeStr == "Normal" ? size.normal : size.small
tablePos  = tablePosStr == "Top Right" ? position.top_right : tablePosStr == "Middle Right" ? position.middle_right : tablePosStr == "Bottom Right" ? position.bottom_right : tablePosStr == "Top Left" ? position.top_left : position.bottom_left

// ============================ TYPES ============================
// One confirmed engulfing pattern, held until it either fails or ages out.
type EgZone
    float baseHigh
    float baseLow
    bool  isBuy
    bool  isExt
    bool  swept

// ============================ CANDLE COLOUR HELPERS ============================
// A Doji (close == open) is neither Green nor Red. It never acts as a Base and
// never breaks an E-Regular run - it is simply skipped.
isGreen(int i) => close[i] > open[i]
isRed(int i)   => close[i] < open[i]
isDoji(int i)  => close[i] == open[i]

// ============================ ENGULFING SCANNERS ============================
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
//   dist : how many bars after the Base the Confirm candle sits
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

// ============================ FAILURE SCANNER ============================
// Scans forward from the bar after the Confirm candle towards the most recent
// closed bar and returns the offset of the FIRST candle that invalidates the
// pattern. Returns na while the pattern is still intact.
//   Buy  Engulfing fails when a Red candle CLOSES below the Base candle Low
//   Sell Engulfing fails when a Green candle CLOSES above the Base candle High
// A wick through the level is not enough; the close has to settle beyond it.
findFailure(int baseOff, int confOff, bool isBuy) =>
    int fail = na
    if confOff > 1
        float baseHigh = high[baseOff]
        float baseLow  = low[baseOff]
        for s = 1 to confOff - 1
            int f = confOff - s
            if isBuy
                if isRed(f) and close[f] < baseLow
                    fail := f
                    break
            else
                if isGreen(f) and close[f] > baseHigh
                    fail := f
                    break
    fail

// ============================ TYPE HELPERS ============================
// Builds the pattern tag from the three flags that fully describe a failed zone.
failTag(bool isBuy, bool isExt, bool isT1) =>
    (isT1 ? "T1 " : "") + (isExt ? "ER " : "R ") + (isBuy ? "Buy" : "Sell") + " EG Failed"

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

// Draws one failed zone: the Base candle range stretched from the Base bar to the
// candle that broke it, styled so the pattern type is readable at a glance.
//   solid border = Regular        dashed border = E-Regular
//   thin border  = plain          thick border  = Type 1 (swept)
drawFailedZone(int baseOff, int failOff, bool isBuy, bool isExt, bool isT1) =>
    int   xBase = bar_index - baseOff
    int   xFail = bar_index - failOff
    float yTop  = high[baseOff]
    float yBot  = low[baseOff]

    // Coloured by the outcome: a failed Buy Engulfing leaves resistance behind.
    color zoneCol = isBuy ? buyFailColor : sellFailColor
    float fillT   = isT1 ? math.max(0, zoneTransp - t1Emphasis) : zoneTransp

    box b = box.new(xBase, yTop, xFail, yBot,
         xloc         = xloc.bar_index,
         border_color = color.new(zoneCol, isT1 ? 0 : 35),
         border_width = isT1 ? 2 : 1,
         border_style = isExt ? line.style_dashed : line.style_solid,
         bgcolor      = color.new(zoneCol, fillT))
    array.push(gBoxes, b)

    // Highlight the side of the Base candle that price closed through.
    if showBroken
        float brokenY = isBuy ? yBot : yTop
        line bl = line.new(xBase, brokenY, xFail, brokenY,
             xloc  = xloc.bar_index,
             color = brokenColor,
             width = 2,
             style = line.style_solid)
        array.push(gLines, bl)

    if showLabels
        float h   = math.abs(yTop - yBot)
        float off = h * labelOffsetPct * 0.01
        // A failed Buy sits above its zone because the zone is resistance now.
        float y   = isBuy ? yTop + off : yBot - off
        int   x   = xBase + int(math.round((xFail - xBase) / 2.0))
        label lb = label.new(x, y,
             text      = failTag(isBuy, isExt, isT1),
             xloc      = xloc.bar_index,
             yloc      = yloc.price,
             style     = isBuy ? label.style_label_down : label.style_label_up,
             color     = isBuy ? labelBear : labelBull,
             textcolor = color.white,
             size      = labelSize)
        array.push(gLabels, lb)

// ============================ SUMMARY TABLE ============================
var table sumTable = table.new(tablePos, 3, 5, border_width = 1, border_color = tableEdge)

tableRow(int row, string name, int buyN, int sellN) =>
    table.cell(sumTable, 0, row, name, bgcolor = tableBg, text_color = color.white, text_size = tableSize, text_halign = text.align_left)
    table.cell(sumTable, 1, row, str.tostring(buyN),  bgcolor = tableBg, text_color = buyFailColor,  text_size = tableSize)
    table.cell(sumTable, 2, row, str.tostring(sellN), bgcolor = tableBg, text_color = sellFailColor, text_size = tableSize)

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
            bool isBuy   = dir > 0
            int  confOff = i - dist
            int  failOff = findFailure(i, confOff, isBuy)

            if not na(failOff)
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
                    drawFailedZone(i, failOff, isBuy, isExt, swept)

    if showTable
        table.cell(sumTable, 0, 0, "Failed Zone", bgcolor = tableHead, text_color = color.white, text_size = tableSize, text_halign = text.align_left)
        table.cell(sumTable, 1, 0, "Buy EG",      bgcolor = tableHead, text_color = color.white, text_size = tableSize)
        table.cell(sumTable, 2, 0, "Sell EG",     bgcolor = tableHead, text_color = color.white, text_size = tableSize)
        tableRow(1, "Regular",      cRegBuy,   cRegSell)
        tableRow(2, "E-Regular",    cErBuy,    cErSell)
        tableRow(3, "T1 Regular",   cT1RegBuy, cT1RegSell)
        tableRow(4, "T1 E-Regular", cT1ErBuy,  cT1ErSell)
    else
        table.clear(sumTable, 0, 0, 2, 4)

// ============================ LIVE PATTERN STATE (BAR CLOSE ONLY) ============================
// The drawing pass above works on history. Alerts need the failure evaluated on
// the candle that has just closed, so confirmed engulfing patterns are kept in a
// list and every closed candle is checked against them.

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

// ============================ ACTIVE ZONE TRACKING ============================
// A confirmed engulfing stays in this list until it fails. Checking the list is
// cheap, which is why alerts do not have to rerun the full historical scan.
var EgZone[] activeZones = array.new<EgZone>()

var bool failRBuy     = false
var bool failRSell    = false
var bool failErBuy    = false
var bool failErSell   = false
var bool failT1RBuy   = false
var bool failT1RSell  = false
var bool failT1ErBuy  = false
var bool failT1ErSell = false

if barstate.isconfirmed
    failRBuy     := false
    failRSell    := false
    failErBuy    := false
    failErSell   := false
    failT1RBuy   := false
    failT1RSell  := false
    failT1ErBuy  := false
    failT1ErSell := false

    // Step 1: test every tracked pattern against the candle that just closed.
    // Done before new patterns are added, so a pattern is never tested against
    // its own Confirm candle.
    int nz = array.size(activeZones)
    if nz > 0
        for idx = nz - 1 to 0
            EgZone z = array.get(activeZones, idx)
            bool broke = z.isBuy ? (isRed(0) and close < z.baseLow) : (isGreen(0) and close > z.baseHigh)
            if broke
                if z.isExt and z.swept and z.isBuy
                    failT1ErBuy := true
                else if z.isExt and z.swept
                    failT1ErSell := true
                else if z.isExt and z.isBuy
                    failErBuy := true
                else if z.isExt
                    failErSell := true
                else if z.swept and z.isBuy
                    failT1RBuy := true
                else if z.swept
                    failT1RSell := true
                else if z.isBuy
                    failRBuy := true
                else
                    failRSell := true
                array.remove(activeZones, idx)

    // Step 2: add patterns that confirmed on this candle.
    if regBuyRaw
        array.push(activeZones, EgZone.new(high[1], low[1], true, false, regBuySwept))
    if regSellRaw
        array.push(activeZones, EgZone.new(high[1], low[1], false, false, regSellSwept))
    if erBuyCond
        array.push(activeZones, EgZone.new(erBuyHigh, erBuyLow, true, true, erBuySwept))
    if erSellCond
        array.push(activeZones, EgZone.new(erSellHigh, erSellLow, false, true, erSellSwept))

    while array.size(activeZones) > maxActive
        array.shift(activeZones)

// ============================ ALERTS ============================
alertcondition(failRBuy,     title = "R Buy EG Failed",     message = "R Buy EG Failed | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(failRSell,    title = "R Sell EG Failed",    message = "R Sell EG Failed | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(failT1RBuy,   title = "T1 R Buy EG Failed",  message = "T1 R Buy EG Failed | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(failT1RSell,  title = "T1 R Sell EG Failed", message = "T1 R Sell EG Failed | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(failErBuy,    title = "ER Buy EG Failed",    message = "ER Buy EG Failed | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(failErSell,   title = "ER Sell EG Failed",   message = "ER Sell EG Failed | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(failT1ErBuy,  title = "T1 ER Buy EG Failed", message = "T1 ER Buy EG Failed | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(failT1ErSell, title = "T1 ER Sell EG Failed", message = "T1 ER Sell EG Failed | {{ticker}} {{interval}} | Close {{close}}")

// Dynamic message for the "Any alert() function call" alert type.
alertMsg(string tag) =>
    tag + " | " + syminfo.ticker + " " + timeframe.period + " | Close " + str.tostring(close, format.mintick)

if barstate.isconfirmed
    if failRBuy
        alert(alertMsg("R Buy EG Failed"), alert.freq_once_per_bar_close)
    if failRSell
        alert(alertMsg("R Sell EG Failed"), alert.freq_once_per_bar_close)
    if failT1RBuy
        alert(alertMsg("T1 R Buy EG Failed"), alert.freq_once_per_bar_close)
    if failT1RSell
        alert(alertMsg("T1 R Sell EG Failed"), alert.freq_once_per_bar_close)
    if failErBuy
        alert(alertMsg("ER Buy EG Failed"), alert.freq_once_per_bar_close)
    if failErSell
        alert(alertMsg("ER Sell EG Failed"), alert.freq_once_per_bar_close)
    if failT1ErBuy
        alert(alertMsg("T1 ER Buy EG Failed"), alert.freq_once_per_bar_close)
    if failT1ErSell
        alert(alertMsg("T1 ER Sell EG Failed"), alert.freq_once_per_bar_close)
````
