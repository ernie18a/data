# MSnR Key Level [6 Types]

- url: https://www.tradingview.com/script/erb7xGg9-MSnR-Key-Level-6-Types/
- type: indicator
- pine_id: PUB;3393c02da0bd4b139f6c0981284b959e
- version: 1.0

## Description

[b]MSnR Key Level [6 Types][/b]

This script maps support and resistance the way market structure actually builds it: from the
close of one candle handing over to the next.

Every pair of consecutive candles leaves a level behind. Depending on the two candle colours
that level is an A Level, a V Level, a Bullish Gap or a Bearish Gap. From there the script
keeps watching. The moment price closes through a level, that level does not disappear, it
FLIPS: support that breaks downward becomes resistance (SBR), resistance that breaks upward
becomes support (RBS).

The result is a complete structural map of the scan window rather than a hand-picked list of
levels, with each of the six types drawn so it can be told apart at a glance.


[b]WHAT MAKES THIS DIFFERENT[/b]

[b]1. Complete coverage, not a filtered selection.[/b]

Most support and resistance tools try to guess which swing points matter and throw the rest
away. This one does the opposite: every candle pair inside the scan window produces a level,
and all of them are drawn. What separates the important levels from the ordinary ones is not
whether they are shown, but how they are drawn. A level that has already been broken and
flipped looks different from one that has never been touched.

[b]2. Levels keep flipping, and the chart shows the CURRENT state.[/b]

A level is not classified once and left alone. It is re-checked against every candle that came
after it, and every close through it flips it again. A level that broke upward, then back down,
then upward again is reported as RBS, because that is what it is today. A tool that stops at
the first break would still be calling it by its original name.

[b]3. Six types, six line signatures.[/b]

Line weight carries strength and line colour carries side, so a line still tells you what it is
even where labels crowd together.

[b]4. The level price is the CLOSE, not the wick.[/b]

Every level sits at the close of the first candle in the pair. Closes are where the market
actually agreed on a price, which is why a close through a level counts as a break here while a
wick through it does not.


[b]THE SIX LEVELS[/b]

A candle is Green when close is greater than open and Red when close is less than open. A Doji,
where close equals open, is neither and forms no level. Only fully closed candles are read; the
running candle is never used.

Created from a two candle pair, the level price being the close of the FIRST candle:

[b]A Level[/b]
Green candle followed by a Red candle. Sits above as resistance.

[b]V Level[/b]
Red candle followed by a Green candle. Sits below as support.

[b]Bullish Gap[/b]
Green candle followed by another Green candle. Sits below as support.

[b]Bearish Gap[/b]
Red candle followed by another Red candle. Sits above as resistance.

Created when an existing level is broken:

[b]RBS - Resistance Become Support[/b]
An A Level or a Bearish Gap that a Green candle later CLOSED above. The old ceiling is now a
floor.

[b]SBR - Support Become Resistance[/b]
A V Level or a Bullish Gap that a Red candle later CLOSED below. The old floor is now a ceiling.


[b]HOW A LEVEL FLIPS[/b]

Think of every level as living on one of two sides.

Resistance side: A Level, Bearish Gap, SBR. Price has to CLOSE above it to break it, and doing
so turns it into RBS, which moves it to the support side.

Support side: V Level, Bullish Gap, RBS. Price has to CLOSE below it to break it, and doing so
turns it into SBR, which moves it to the resistance side.

Because SBR and RBS are themselves on one of those sides, the flipping never stops. The script
walks forward from the bar a level was born on, all the way to the present, applying every
break in order. Whatever side the level ends on is what you see.


[b]READING THE CHART[/b]

[b]Color tells you the side:[/b]

- Red: resistance side, price has to close above to break it. A Level, Bearish Gap, SBR.
- Green: support side, price has to close below to break it. V Level, Bullish Gap, RBS.

[b]Line weight tells you the strength:[/b]

- Thick solid: SBR and RBS. These have already been broken once and changed hands, which makes
  them the levels most worth watching.
- Thin solid: A Level and V Level. A clean turning point between two opposite candles.
- Dotted: Bullish Gap and Bearish Gap. The most common and the weakest, formed by two candles
  of the same colour.

That gives all six types a unique signature. A thick red line is an SBR, a dotted green line is
a Bullish Gap, and so on, without reading a single label.

Each line starts at the candle that set its price and extends to the right, so you can see how
price has behaved around it since. Its label sits at that same candle, above the line for a
resistance level and below it for a support level, so the label never covers the line itself.

A summary table in the corner counts each of the six types inside the current scan window, with
the three resistance-side types grouped above the three support-side types.


[b]SETTINGS[/b]

[b]Scan[/b]
- Scan Length: how many closed candles are scanned backwards. Every level inside that window is
  drawn.

[b]Level Types[/b]
- An individual switch for each of the six types. Hiding Bullish and Bearish Gap is the quickest
  way to thin out a busy chart, since those are always the most numerous.

[b]Style[/b]
- Resistance Side Color and Support Side Color.

[b]Labels[/b]
- Show Labels, Label Offset in ticks, and Label Size. The offset is measured in ticks, so a
  value that looks right on one symbol may need adjusting on another.

[b]Summary Table[/b]
- Show, position and size of the corner table.


[b]ALERTS[/b]

Six alert conditions are available: A Level, V Level, Bullish Gap, Bearish Gap, SBR and RBS.

Each message carries the level type, the symbol, the timeframe and the closing price. The same
messages are also sent through the alert function, so the "Any alert() function call" alert type
can deliver everything through a single alert.

All alerts are evaluated only after a candle has fully closed.

One thing worth knowing before you set these up: A Level, V Level, Bullish Gap and Bearish Gap
are created by EVERY candle pair, so those four alerts will fire on almost every bar. They are
there for completeness and for anyone feeding the data somewhere else. SBR and RBS only fire
when a level is actually broken, which makes them the two selective alerts of the six.


[b]REPAINTING[/b]

This script does not repaint.

- Detection reads confirmed candles only. The scan starts one bar behind the latest bar, so the
  candle that is still forming is never part of any calculation.
- Alert signals can only become true once a candle has finished. Price moving inside an open
  candle cannot make a signal appear and then disappear.
- Levels are rebuilt on the last bar from confirmed history. A level's price never moves. Its
  type can change, but only forward and only when a candle CLOSES through it, which is the whole
  point of SBR and RBS. Once drawn, nothing shifts backwards.

When you create an alert, TradingView may show a caution banner saying the indicator can
repaint. That banner appears automatically for any script that uses the built in bar state
variables, no matter how they are used, because the platform cannot check the intent behind
them. This script uses them for the opposite purpose: one of them is what restricts every signal
to bar close, and the other is what redraws the levels efficiently on the final bar. Choosing
"Once Per Bar Close" when creating the alert is still recommended.


[b]NOTES AND LIMITATIONS[/b]

- This chart is dense by design. Since every candle pair forms a level, a window of 25 candles
  produces roughly 25 levels, and doubling the window doubles the lines. That is intentional,
  because the point is a complete map rather than a shortlist. If you want fewer lines, lower
  the Scan Length first, then switch off the Gap types.
- TradingView caps drawings at 500 lines and 500 labels. A very long Scan Length will hit that
  ceiling and the oldest drawings will be dropped. The default is chosen to stay well inside it.
- The label offset is measured in ticks, and a tick is worth a very different amount on a crypto
  pair than on a forex pair. Expect to adjust it when you move between symbols.
- Level prices come from closes, so a level can sit in the middle of a long wick. That is
  deliberate, not a bug.
- Detection is purely structural. It reports where levels are and which way they have flipped.
  It does not rank them by how many times price reacted, measure what happened afterwards, or
  produce entries, targets or stops.


[b]HOW TO USE IT[/b]

Read the chart in layers. The thick lines are the levels that have already proven they matter,
because price closed through them and the market treated them differently afterwards. The thin
lines are clean turning points. The dotted lines are background structure.

Levels that sit close together often matter more than any single one of them, since several
candle pairs agreeing on roughly one price is what a real zone looks like.

These are reference areas, not entry signals. Use them alongside higher timeframe structure, and
apply your own confirmation and risk management.


[b]DISCLAIMER[/b]

This indicator is a level detection tool. It is not financial advice and it makes no claim about
profitability. Trading involves risk. Always apply your own analysis and risk management.

## Source Code

````pine
//@version=6
indicator(
     title            = "MSnR Key Level [6 Types]",
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

candleLen = input.int(25, "Scan Length (closed candles)", minval = 3, maxval = 500, group = gScan,
     tooltip = "How many closed candles are scanned backwards from the latest bar. Every level found inside this window is drawn. The running candle is always excluded.")

showA       = input.bool(true, "A Level",      group = gType)
showV       = input.bool(true, "V Level",      group = gType)
showBullGap = input.bool(true, "Bullish Gap",  group = gType)
showBearGap = input.bool(true, "Bearish Gap",  group = gType)
showSBR     = input.bool(true, "SBR",          group = gType)
showRBS     = input.bool(true, "RBS",          group = gType)

resColor = input.color(#ef4444, "Resistance Side Color", group = gStyle,
     tooltip = "Used for A Level, Bearish Gap and SBR - the levels price has to close ABOVE to break.")
supColor = input.color(#22c55e, "Support Side Color",    group = gStyle,
     tooltip = "Used for V Level, Bullish Gap and RBS - the levels price has to close BELOW to break.")

showLabels       = input.bool(true, "Show Labels", group = gLabel)
labelOffsetTicks = input.int(140, "Label Offset (ticks)", minval = 1, group = gLabel,
     tooltip = "How far the label sits from its own line, so the text clears the line instead of sitting on it. Resistance labels go above the line, support labels below it.")
labelSizeStr     = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gLabel)

showTable    = input.bool(true, "Show Summary Table", group = gTable)
tablePosStr  = input.string("Top Right", "Table Position", options = ["Top Right", "Middle Right", "Bottom Right", "Top Left", "Bottom Left"], group = gTable)
tableSizeStr = input.string("Small", "Table Size", options = ["Tiny", "Small", "Normal"], group = gTable)

// ============================ STYLE CONSTANTS ============================
labelSup  = #107a34
labelRes  = #b22222
tableHead = #000000
tableBg   = #1e222d
tableEdge = #363a45

labelSize = labelSizeStr == "Tiny" ? size.tiny : labelSizeStr == "Normal" ? size.normal : labelSizeStr == "Large" ? size.large : size.small
tableSize = tableSizeStr == "Tiny" ? size.tiny : tableSizeStr == "Normal" ? size.normal : size.small
tablePos  = tablePosStr == "Top Right" ? position.top_right : tablePosStr == "Middle Right" ? position.middle_right : tablePosStr == "Bottom Right" ? position.bottom_right : tablePosStr == "Top Left" ? position.top_left : position.bottom_left

// ============================ LEVEL TYPES ============================
TYPE_A        = 0
TYPE_V        = 1
TYPE_BULL_GAP = 2
TYPE_BEAR_GAP = 3
TYPE_SBR      = 4
TYPE_RBS      = 5

// ============================ HELPERS ============================
isGreen(int i) => close[i] > open[i]
isRed(int i)   => close[i] < open[i]

// A level always sits on one of two sides. Resistance-side levels are the ones
// price has to close ABOVE to break; support-side levels have to be closed BELOW.
// Every break flips the side, which is why SBR and RBS appear in these lists too.
isResSide(int t) => t == TYPE_A or t == TYPE_BEAR_GAP or t == TYPE_SBR
isSupSide(int t) => t == TYPE_V or t == TYPE_BULL_GAP or t == TYPE_RBS

typeName(int t) =>
    switch t
        TYPE_A        => "A Level"
        TYPE_V        => "V Level"
        TYPE_BULL_GAP => "Bullish Gap"
        TYPE_BEAR_GAP => "Bearish Gap"
        TYPE_SBR      => "SBR"
        TYPE_RBS      => "RBS"
        => ""

typeVisible(int t) =>
    switch t
        TYPE_A        => showA
        TYPE_V        => showV
        TYPE_BULL_GAP => showBullGap
        TYPE_BEAR_GAP => showBearGap
        TYPE_SBR      => showSBR
        TYPE_RBS      => showRBS
        => false

// Each of the six types carries its own line signature, so a line stays readable
// even where labels crowd together:
//   thick  = SBR / RBS   already broken once and flipped, the strongest levels
//   thin   = A / V       a clean turning point
//   dotted = Gap         the most common and the weakest
//   red    = resistance side       green = support side
lineWidthFor(int t) => (t == TYPE_SBR or t == TYPE_RBS) ? 2 : 1
lineStyleFor(int t) => (t == TYPE_BULL_GAP or t == TYPE_BEAR_GAP) ? line.style_dotted : line.style_solid
colorFor(int t)     => isResSide(t) ? resColor : supColor
labelBgFor(int t)   => isResSide(t) ? labelRes : labelSup

// Walks forward in time from the bar after the level was created and flips the
// level every time price closes through it. The state left at the end is the
// level's type today, so a level that flipped RBS -> SBR -> RBS reads as RBS.
resolveType(int startKind, float price, int originOff) =>
    int t     = startKind
    int first = originOff - 2
    if first >= 1
        for k = first to 1
            if isResSide(t) and isGreen(k) and close[k] > price
                t := TYPE_RBS
            else if isSupSide(t) and isRed(k) and close[k] < price
                t := TYPE_SBR
    t

// ============================ DRAWING STORAGE ============================
var line[]  gLines  = array.new_line()
var label[] gLabels = array.new_label()

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

// Draws one level: a line from the candle that set the price, extended to the
// right, plus a label sitting just off the line at that same candle.
drawLevel(float price, int kind, int originOff, float offsetY) =>
    int x1 = bar_index - originOff

    line ln = line.new(
         x1     = x1,
         y1     = price,
         x2     = bar_index,
         y2     = price,
         xloc   = xloc.bar_index,
         extend = extend.right,
         color  = colorFor(kind),
         width  = lineWidthFor(kind),
         style  = lineStyleFor(kind))
    array.push(gLines, ln)

    if showLabels
        float y = isResSide(kind) ? price + offsetY : price - offsetY
        label lb = label.new(
             x         = x1,
             y         = y,
             text      = typeName(kind),
             xloc      = xloc.bar_index,
             yloc      = yloc.price,
             style     = label.style_label_center,
             color     = labelBgFor(kind),
             textcolor = color.white,
             size      = labelSize)
        array.push(gLabels, lb)

// ============================ SUMMARY TABLE ============================
var table sumTable = table.new(tablePos, 2, 7, border_width = 1, border_color = tableEdge)

tableRow(int row, string name, int n, color tint) =>
    table.cell(sumTable, 0, row, name, bgcolor = tableBg, text_color = tint, text_size = tableSize, text_halign = text.align_left)
    table.cell(sumTable, 1, row, str.tostring(n), bgcolor = tableBg, text_color = color.white, text_size = tableSize)

// ============================ MAIN SCAN AND REDRAW ============================
// Rebuilt on the last bar only, from confirmed candles, so nothing repaints.
if barstate.islast
    clearAll()

    int   maxScan = math.min(candleLen, bar_index)
    float offsetY = syminfo.mintick * labelOffsetTicks

    int cA    = 0
    int cV    = 0
    int cBull = 0
    int cBear = 0
    int cSBR  = 0
    int cRBS  = 0

    // Oldest first, so newer levels are drawn on top of older ones.
    for i = maxScan to 2
        int f = i
        int s = i - 1

        int kind = -1
        if isGreen(f) and isRed(s)
            kind := TYPE_A
        else if isRed(f) and isGreen(s)
            kind := TYPE_V
        else if isGreen(f) and isGreen(s)
            kind := TYPE_BULL_GAP
        else if isRed(f) and isRed(s)
            kind := TYPE_BEAR_GAP

        if kind >= 0
            float p   = close[f]
            int   fin = resolveType(kind, p, f)

            if fin == TYPE_A
                cA += 1
            else if fin == TYPE_V
                cV += 1
            else if fin == TYPE_BULL_GAP
                cBull += 1
            else if fin == TYPE_BEAR_GAP
                cBear += 1
            else if fin == TYPE_SBR
                cSBR += 1
            else
                cRBS += 1

            if typeVisible(fin)
                drawLevel(p, fin, f, offsetY)

    if showTable
        table.cell(sumTable, 0, 0, "Level", bgcolor = tableHead, text_color = color.white, text_size = tableSize, text_halign = text.align_left)
        table.cell(sumTable, 1, 0, "Count", bgcolor = tableHead, text_color = color.white, text_size = tableSize)
        tableRow(1, "A Level",     cA,    resColor)
        tableRow(2, "Bearish Gap", cBear, resColor)
        tableRow(3, "SBR",         cSBR,  resColor)
        tableRow(4, "V Level",     cV,    supColor)
        tableRow(5, "Bullish Gap", cBull, supColor)
        tableRow(6, "RBS",         cRBS,  supColor)
    else
        table.clear(sumTable, 0, 0, 1, 6)

// ============================ LIVE STATE (BAR CLOSE ONLY) ============================
// Alerts need levels tracked candle by candle rather than rescanned, so the same
// rules run here over a rolling list of levels.
var float[] aPrice = array.new_float()
var int[]   aKind  = array.new_int()

var bool newA    = false
var bool newV    = false
var bool newBull = false
var bool newBear = false
var bool newSBR  = false
var bool newRBS  = false

if barstate.isconfirmed and bar_index >= 2
    newA    := false
    newV    := false
    newBull := false
    newBear := false
    newSBR  := false
    newRBS  := false

    // Step 1: flip any tracked level that this candle closed through. Levels that
    // already flipped once stay eligible, so RBS can go back to SBR and onwards.
    int nA = array.size(aPrice)
    if nA > 0
        for idx = 0 to nA - 1
            float p = array.get(aPrice, idx)
            int   t = array.get(aKind,  idx)
            if isResSide(t) and isGreen(0) and close > p
                array.set(aKind, idx, TYPE_RBS)
                newRBS := true
            else if isSupSide(t) and isRed(0) and close < p
                array.set(aKind, idx, TYPE_SBR)
                newSBR := true

    // Step 2: the pair that completed on this candle creates a new level. Done
    // after the flips so a level is never tested against its own creation bar.
    int born = -1
    if isGreen(1) and isRed(0)
        born := TYPE_A
        newA := true
    else if isRed(1) and isGreen(0)
        born := TYPE_V
        newV := true
    else if isGreen(1) and isGreen(0)
        born := TYPE_BULL_GAP
        newBull := true
    else if isRed(1) and isRed(0)
        born := TYPE_BEAR_GAP
        newBear := true

    if born >= 0
        array.push(aPrice, close[1])
        array.push(aKind,  born)

    while array.size(aPrice) > candleLen
        array.shift(aPrice)
        array.shift(aKind)

// ============================ ALERTS ============================
alertcondition(newA,    title = "A Level",     message = "A Level | {{ticker}} {{interval}} | {{close}}")
alertcondition(newV,    title = "V Level",     message = "V Level | {{ticker}} {{interval}} | {{close}}")
alertcondition(newBull, title = "Bullish Gap", message = "Bullish Gap | {{ticker}} {{interval}} | {{close}}")
alertcondition(newBear, title = "Bearish Gap", message = "Bearish Gap | {{ticker}} {{interval}} | {{close}}")
alertcondition(newSBR,  title = "SBR",         message = "SBR | {{ticker}} {{interval}} | {{close}}")
alertcondition(newRBS,  title = "RBS",         message = "RBS | {{ticker}} {{interval}} | {{close}}")

alertMsg(string tag) =>
    tag + " | " + syminfo.ticker + " " + timeframe.period + " | Close " + str.tostring(close, format.mintick)

if barstate.isconfirmed
    if newA
        alert(alertMsg("A Level"), alert.freq_once_per_bar_close)
    if newV
        alert(alertMsg("V Level"), alert.freq_once_per_bar_close)
    if newBull
        alert(alertMsg("Bullish Gap"), alert.freq_once_per_bar_close)
    if newBear
        alert(alertMsg("Bearish Gap"), alert.freq_once_per_bar_close)
    if newSBR
        alert(alertMsg("SBR"), alert.freq_once_per_bar_close)
    if newRBS
        alert(alertMsg("RBS"), alert.freq_once_per_bar_close)
````
