# Fair Value Gap Screener [ITA]

- url: https://www.tradingview.com/script/3zlKGoIR-Fair-Value-Gap-Screener-ITA/
- type: indicator
- pine_id: PUB;ded111287a8a4646bc1b99f74ed673c3
- version: 1.0

## Description

🟠 OVERVIEW

Fair Value Gap Screener marks imbalances on the chart, counts how many of them actually got filled, and at the same time watches up to ten other symbols for the same thing.

"Gaps always fill" is repeated everywhere as if it were a law. It is a claim, and it is measurable on the symbol in front of you. This counts it.

🟠 WHAT I MEASURED

QQQ daily: 93% of 1,694 gaps filled, taking 54.8 bars on average. 124 are still open.

The rate is not the interesting part. The wait is. A gap that fills two months after it formed is not a target you can hold a position against, and the average is published here so nobody has to take my word for it.

🟠 CONCEPTS

* Fair Value Gap - A three candle imbalance. The middle candle moves so hard that the wicks either side never overlap, leaving a range that traded in one direction only.
* Bar Gap - The plain gap between two neighbouring candles, which is what most people point at on a daily chart. It is a different zone from a fair value gap and it is selectable.
* Fill - Price trading back into the range. Either the first touch of the near edge, or a full pass all the way through.
* Still Open - A gap price has not come back to. It is not counted as a failure, it is simply not counted yet. Counting it would punish every recent gap for not having had time.
* Distance - How far price is from the near edge, as a percentage. This is the number that says whether a gap matters right now.

🟠 FEATURES

🔹 Fill rate, average bars to fill and open count, measured on the symbol and timeframe on screen

🔹 Ten configurable symbols scanned in parallel, with gap direction, the zone, distance and age

🔹 The distance figure turns gold when price is within one percent of the gap, so the symbol about to react stands out without reading the table

🔹 Three candle and two candle gaps, separately or together, because they are not the same zone

🔹 Zones stop extending after a set number of bars instead of crossing the whole chart as a stripe

🔹 Independent screener timeframe, so the daily can be scanned from an intraday chart

🟠 HOW TO USE

Set the ten symbols to whatever you actually trade. Read the DIST column first: a gap two percent away is context, a gold one is about to be tested.

Then read the fill rate at the bottom. If it is near one hundred percent, your Minimum Gap Size is too low and you are counting noise. A gap of a few cents fills almost immediately and tells you nothing.

The BARS column is how long a gap has been unfilled. Older gaps have had more chances to fill and did not, which is worth knowing before treating one as a target.

🟠 CONCLUSION

Gaps are easy to draw and easy to miss. The part worth knowing is not whether they fill, it is how long you would have had to wait.

## Source Code

````pine
//@version=6
// =============================================================================
// Fair Value Gap Screener [ITA]
//
// Drawing fair value gaps on one chart is the easy part, and there is no
// shortage of scripts that do it. The problem is that a gap you are not
// looking at is a gap you miss.
//
// This one draws the gaps on the chart AND watches up to ten other symbols at
// the same time, listing which of them currently have an unfilled gap, how far
// price is from it, and how long it has been sitting there.
//
// A fair value gap is a three-candle imbalance - the middle candle moves so
// hard that the wicks either side never overlap, leaving a price range that
// traded in one direction only. It stays on the chart until price comes back
// and trades through it.
// =============================================================================

indicator("Fair Value Gap Screener [ITA]", overlay = true,
     max_boxes_count = 500, max_labels_count = 100)

// ─── Inputs ──────────────────────────────────────────────────────────────────
grpFvg = "Gap Detection"
// Two different things get called a gap and they rarely sit in the same
// place. A fair value gap skips the middle candle and compares bar 2 against
// bar 0. A bar gap is the plain one between two neighbours, which is what a
// trader usually means when pointing at an overnight gap on a daily chart.
gapType = input.string("Fair value gap", "Gap Type", options = ["Fair value gap", "Bar gap", "Both"], group = grpFvg,
     tooltip = "Fair value gap: a three candle imbalance, bar 2 against bar 0, the middle candle ignored. Bar gap: two neighbouring candles with no overlap at all. Both: whichever occurs.")
minSize = input.float(0.25, "Minimum Gap Size %", minval = 0.0, maxval = 10, step = 0.05,
     group = grpFvg, tooltip = "Ignore gaps smaller than this share of price. Keeps the noise off intraday charts. 0 keeps every gap.")
fillMode = input.string("Full fill", "Treated As Filled On", options = ["Full fill", "First touch"],
     group = grpFvg, tooltip = "Full fill: the gap closes only once price crosses all the way through it. First touch: the moment price reaches the near edge.")
keepFilled = input.bool(false, "Keep Filled Gaps On Chart", group = grpFvg,
     tooltip = "Off removes a gap once it fills. On leaves it greyed out.")

grpChart = "On Chart"
showChart = input.bool(true, "Draw Gaps On This Chart", group = grpChart)
maxDraw = input.int(10, "Most Recent Gaps To Draw", minval = 1, maxval = 100, group = grpChart)
extendBars = input.int(10, "Extend Right (bars)", minval = 0, maxval = 500, group = grpChart)
// An unfilled gap used to keep extending to the current bar, so one from six
// weeks ago crossed the whole screen as a stripe and stopped reading as a
// zone at all. It still extends while it is live, it just stops somewhere.
maxLen     = input.int(40, "Longest A Zone Is Drawn (bars)", minval = 5, maxval = 500, group = grpChart, tooltip = "A zone stops extending after this many bars even if it is still unfilled. It is still counted, it is just no longer drawn across the chart.")

grpScan = "Screener"
showTable = input.bool(true, "Show Screener Table", group = grpScan)
scanTF = input.timeframe("", "Screener Timeframe", group = grpScan,
     tooltip = "Blank uses the chart timeframe.")
tblPos = input.string("Top right", "Table Position",
     options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], group = grpScan)
tblSize = input.string("Small", "Table Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpScan)
onlyOpen = input.bool(true, "List Symbols With An Open Gap Only", group = grpScan)

grpSym = "Screener Symbols"
s01 = input.symbol("AMEX:SPY",    "1",  group = grpSym)
s02 = input.symbol("NASDAQ:QQQ",  "2",  group = grpSym)
s03 = input.symbol("NASDAQ:AAPL", "3",  group = grpSym)
s04 = input.symbol("NASDAQ:MSFT", "4",  group = grpSym)
s05 = input.symbol("NASDAQ:NVDA", "5",  group = grpSym)
s06 = input.symbol("NASDAQ:TSLA", "6",  group = grpSym)
s07 = input.symbol("NASDAQ:AMZN", "7",  group = grpSym)
s08 = input.symbol("NASDAQ:META", "8",  group = grpSym)
s09 = input.symbol("NASDAQ:GOOGL","9",  group = grpSym)
s10 = input.symbol("NASDAQ:AMD",  "10", group = grpSym)

grpCol = "Colors"
bullCol = input.color(#089981, "Bullish Gap", group = grpCol)
bearCol = input.color(#F23645, "Bearish Gap", group = grpCol)
deadCol = input.color(#787E8C, "Filled Gap", group = grpCol)
gapAlpha = input.int(82, "Gap Transparency", minval = 50, maxval = 100, group = grpCol)

// ─── Gap detection, shared by the chart and the screener ────────────────────
// Bullish: this bar's low sits above the high two bars back - the move up left
// a range that never traded. Bearish is the mirror image.
fvgOn = gapType != "Bar gap"
barOn = gapType != "Fair value gap"

bullFvg = fvgOn and low > high[2]
bearFvg = fvgOn and high < low[2]
bullBar = barOn and low > high[1]
bearBar = barOn and high < low[1]

// When both are on and both fire, the fair value gap wins, since it is the
// wider of the two and already contains the bar gap.
bullNew = bullFvg or bullBar
bearNew = bearFvg or bearBar

// the edges depend on which kind actually fired
gapBotUp() => bullFvg ? high[2] : high[1]
gapTopDn() => bearFvg ? low[2]  : low[1]

sizeOK(float t, float b) =>
    (t - b) / b * 100 >= minSize

// State of the most recent unfilled gap on whatever symbol this runs against.
// Used through request.security for the screener.
fvgState() =>
    var float gTop = na
    var float gBot = na
    var int   gDir = 0          // 1 bullish, -1 bearish, 0 none open
    var int   gBar = na

    nb = (fvgOn and low > high[2]) or (barOn and low > high[1])
    nr = (fvgOn and high < low[2]) or (barOn and high < low[1])
    nbBot = (fvgOn and low > high[2]) ? high[2] : high[1]
    nrTop = (fvgOn and high < low[2]) ? low[2]  : low[1]

    if nb and (low - nbBot) / nbBot * 100 >= minSize
        gTop := low
        gBot := nbBot
        gDir := 1
        gBar := bar_index
    else if nr and (nrTop - high) / high * 100 >= minSize
        gTop := nrTop
        gBot := high
        gDir := -1
        gBar := bar_index
    else if gDir != 0
        // has price come back into it?
        touched = gDir == 1 ? low <= gTop : high >= gBot
        crossed = gDir == 1 ? low <= gBot : high >= gTop
        gone = fillMode == "First touch" ? touched : crossed
        if gone
            gDir := 0

    age = na(gBar) ? 0 : bar_index - gBar
    [gDir, gTop, gBot, close, age]

// request.security needs a simple string, so each symbol gets its own call.
scan(simple string sym) =>
    [d, t, b, c, a] = request.security(sym, scanTF, fvgState(),
         lookahead = barmerge.lookahead_off)
    [d, t, b, c, a]

[d1, t1, b1, c1, a1]  = scan(s01)
[d2, t2, b2, c2, a2]  = scan(s02)
[d3, t3, b3, c3, a3]  = scan(s03)
[d4, t4, b4, c4, a4]  = scan(s04)
[d5, t5, b5, c5, a5]  = scan(s05)
[d6, t6, b6, c6, a6]  = scan(s06)
[d7, t7, b7, c7, a7]  = scan(s07)
[d8, t8, b8, c8, a8]  = scan(s08)
[d9, t9, b9, c9, a9]  = scan(s09)
[d10,t10,b10,c10,a10] = scan(s10)

// ─── Gaps on this chart ─────────────────────────────────────────────────────
var box[]  gapBox = array.new_box()
var int[]  gapDir = array.new_int()
var float[] gapTop = array.new_float()
var float[] gapBot = array.new_float()

newBull = showChart and bullNew and sizeOK(low, gapBotUp())
newBear = showChart and bearNew and sizeOK(gapTopDn(), high)

if newBull
    array.push(gapBox, box.new(bar_index - (bullFvg ? 2 : 1), low, bar_index + extendBars, gapBotUp(),
         border_color = bullCol, border_width = 1,
         bgcolor = color.new(bullCol, gapAlpha)))
    array.push(gapDir, 1)
    array.push(gapTop, low)
    array.push(gapBot, gapBotUp())

if newBear
    array.push(gapBox, box.new(bar_index - (bearFvg ? 2 : 1), gapTopDn(), bar_index + extendBars, high,
         border_color = bearCol, border_width = 1,
         bgcolor = color.new(bearCol, gapAlpha)))
    array.push(gapDir, -1)
    array.push(gapTop, gapTopDn())
    array.push(gapBot, high)

// trim the oldest so the chart stays readable
while array.size(gapBox) > maxDraw
    box.delete(array.shift(gapBox))
    array.shift(gapDir)
    array.shift(gapTop)
    array.shift(gapBot)

// walk the live gaps and retire the ones price has traded back into
if array.size(gapBox) > 0
    for i = array.size(gapBox) - 1 to 0
        dir = array.get(gapDir, i)
        if dir != 0
            gt = array.get(gapTop, i)
            gb = array.get(gapBot, i)
            touched = dir == 1 ? low <= gt : high >= gb
            crossed = dir == 1 ? low <= gb : high >= gt
            gone = fillMode == "First touch" ? touched : crossed
            bx = array.get(gapBox, i)
            if gone
                array.set(gapDir, i, 0)
                if keepFilled
                    box.set_border_color(bx, deadCol)
                    box.set_bgcolor(bx, color.new(deadCol, 94))
                    box.set_right(bx, bar_index)
                else
                    box.delete(bx)
            else
                left  = box.get_left(bx)
                right = math.min(bar_index + extendBars, left + maxLen)
                box.set_right(bx, right)

// ─── Screener table ─────────────────────────────────────────────────────────
posOf(string p) =>
    out = position.top_right
    if p == "Top left"
        out := position.top_left
    else if p == "Bottom right"
        out := position.bottom_right
    else if p == "Bottom left"
        out := position.bottom_left
    else if p == "Middle right"
        out := position.middle_right
    out

sizeOf(string s) =>
    out = size.small
    if s == "Tiny"
        out := size.tiny
    else if s == "Normal"
        out := size.normal
    else if s == "Large"
        out := size.large
    else if s == "Huge"
        out := size.huge
    out

var table screen = na

// "NASDAQ:AAPL" -> "AAPL". syminfo.ticker is a variable, not a lookup, so the
// exchange prefix has to come off by hand.
tickerOf(simple string s) =>
    parts = str.split(s, ":")
    array.size(parts) > 1 ? array.get(parts, 1) : s

// One row per symbol that still has an unfilled gap.
addRow(table tb, int r, simple string sym, int dir, float gt, float gb, float px, int age) =>
    shown = 0
    if dir != 0 and not na(gt) and not na(gb)
        col  = dir == 1 ? bullCol : bearCol
        // distance from price to the near edge of the gap
        edge = dir == 1 ? gt : gb
        dist = (edge - px) / px * 100
        table.cell(tb, 0, r, tickerOf(sym), text_color = color.white,
             text_size = sizeOf(tblSize), text_halign = text.align_left)
        table.cell(tb, 1, r, dir == 1 ? "Bull" : "Bear", text_color = col,
             text_size = sizeOf(tblSize))
        table.cell(tb, 2, r, str.tostring(gb, format.mintick) + " - " + str.tostring(gt, format.mintick),
             text_color = color.new(color.white, 25), text_size = sizeOf(tblSize))
        table.cell(tb, 3, r, str.tostring(dist, "#.##") + "%",
             text_color = math.abs(dist) < 1 ? #E5C56B : color.new(color.white, 25),
             text_size = sizeOf(tblSize))
        table.cell(tb, 4, r, str.tostring(age), text_color = color.new(color.white, 45),
             text_size = sizeOf(tblSize))
        shown := 1
    shown

if barstate.islast and showTable
    if na(screen)
        screen := table.new(posOf(tblPos), 5, 12,
             bgcolor = color.new(#0D1117, 12), border_color = color.new(#787E8C, 70),
             border_width = 1, frame_color = color.new(#787E8C, 55), frame_width = 1)
    table.clear(screen, 0, 0, 4, 11)

    table.cell(screen, 0, 0, "SYMBOL", text_color = #E5C56B, text_size = sizeOf(tblSize))
    table.cell(screen, 1, 0, "GAP",    text_color = #E5C56B, text_size = sizeOf(tblSize))
    table.cell(screen, 2, 0, "ZONE",   text_color = #E5C56B, text_size = sizeOf(tblSize))
    table.cell(screen, 3, 0, "DIST",   text_color = #E5C56B, text_size = sizeOf(tblSize))
    table.cell(screen, 4, 0, "BARS",   text_color = #E5C56B, text_size = sizeOf(tblSize))

    r = 1
    r += addRow(screen, r, s01, d1,  t1,  b1,  c1,  a1)
    r += addRow(screen, r, s02, d2,  t2,  b2,  c2,  a2)
    r += addRow(screen, r, s03, d3,  t3,  b3,  c3,  a3)
    r += addRow(screen, r, s04, d4,  t4,  b4,  c4,  a4)
    r += addRow(screen, r, s05, d5,  t5,  b5,  c5,  a5)
    r += addRow(screen, r, s06, d6,  t6,  b6,  c6,  a6)
    r += addRow(screen, r, s07, d7,  t7,  b7,  c7,  a7)
    r += addRow(screen, r, s08, d8,  t8,  b8,  c8,  a8)
    r += addRow(screen, r, s09, d9,  t9,  b9,  c9,  a9)
    r += addRow(screen, r, s10, d10, t10, b10, c10, a10)

    if r == 1
        table.cell(screen, 0, 1, "No open gaps", text_color = color.new(color.white, 40),
             text_size = sizeOf(tblSize))

// ─── Alerts ─────────────────────────────────────────────────────────────────
alertcondition(newBull, "Bullish FVG", "A bullish fair value gap formed on this chart")
alertcondition(newBear, "Bearish FVG", "A bearish fair value gap formed on this chart")

// ─── Do gaps actually get filled ────────────────────────────────────────────
// "Gaps always fill" is repeated everywhere as if it were a law. It is a
// claim, and it is measurable on the symbol in front of you.
//
// This tracks every gap the chart has formed, not only the ones still drawn,
// so trimming the display does not change the count. A gap that is still open
// is not counted as a failure, it is simply not counted yet - counting it as
// unfilled would punish recent gaps that have not had time.
grpStat   = "Fill Rate"
showStat  = input.bool(true, "Show Fill Rate", group = grpStat)
statPos   = input.string("Bottom right", "Fill Rate Position",
     options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], group = grpStat)
statSize  = input.string("Normal", "Fill Rate Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpStat)

var int[]   trDir = array.new_int()
var float[] trTop = array.new_float()
var float[] trBot = array.new_float()
var int[]   trBar = array.new_int()

var int formedN  = 0
var int filledN  = 0
var int barsSum  = 0

if bullNew and sizeOK(low, gapBotUp())
    array.push(trDir, 1)
    array.push(trTop, low)
    array.push(trBot, gapBotUp())
    array.push(trBar, bar_index)
    formedN += 1

if bearNew and sizeOK(gapTopDn(), high)
    array.push(trDir, -1)
    array.push(trTop, gapTopDn())
    array.push(trBot, high)
    array.push(trBar, bar_index)
    formedN += 1

if array.size(trDir) > 0
    for i = array.size(trDir) - 1 to 0
        dir = array.get(trDir, i)
        if dir != 0
            gt = array.get(trTop, i)
            gb = array.get(trBot, i)
            tch = dir == 1 ? low <= gt : high >= gb
            crs = dir == 1 ? low <= gb : high >= gt
            if (fillMode == "First touch" ? tch : crs)
                filledN += 1
                barsSum += bar_index - array.get(trBar, i)
                // the row is retired rather than removed, so the arrays stay
                // aligned and an index never shifts under the loop
                array.set(trDir, i, 0)

var table statTbl = na

if showStat and barstate.islast
    openN = formedN - filledN
    if na(statTbl)
        statTbl := table.new(posOf(statPos), 2, 4, border_width = 1)
    table.cell(statTbl, 0, 0, gapType == "Bar gap" ? "BAR GAPS FILLED" : gapType == "Both" ? "GAPS FILLED (BOTH)" : "FVG FILLED", text_color = #d1a44a, text_size = sizeOf(statSize))
    table.cell(statTbl, 1, 0, syminfo.ticker + " " + timeframe.period, text_color = #d1a44a, text_size = sizeOf(statSize))
    table.cell(statTbl, 0, 1, "Fill rate", text_color = color.gray, text_size = sizeOf(statSize))
    table.cell(statTbl, 1, 1, formedN > 0 ? str.tostring(filledN / formedN * 100, "#") + "%  (" + str.tostring(filledN) + "/" + str.tostring(formedN) + ")" : "-", text_color = color.white, text_size = sizeOf(statSize))
    table.cell(statTbl, 0, 2, "Average bars to fill", text_color = color.gray, text_size = sizeOf(statSize))
    table.cell(statTbl, 1, 2, filledN > 0 ? str.tostring(barsSum / filledN, "#.#") : "-", text_color = color.white, text_size = sizeOf(statSize))
    table.cell(statTbl, 0, 3, "Still open", text_color = color.gray, text_size = sizeOf(statSize))
    table.cell(statTbl, 1, 3, str.tostring(openN), text_color = color.white, text_size = sizeOf(statSize))

// ─── Diagnostics ────────────────────────────────────────────────────────────
// Off by default. Comparing a drawn zone against one marked by hand on a
// screenshot is guesswork, and guessing at a drawing bug has already cost two
// rounds on another script. This prints the three bars a gap was built from
// and the edges that came out, so the numbers can be read instead of measured
// off the screen.
diag = input.bool(false, "Show Diagnostics", group = "Diagnostics")

var float dgTop = na
var float dgBot = na
var int   dgDir = 0
var int   dgBar = na
var float dgH2  = na
var float dgL2  = na
var float dgL0  = na
var float dgH0  = na

if bullNew and sizeOK(low, gapBotUp())
    dgDir := 1
    dgTop := low
    dgBot := gapBotUp()
    dgBar := bar_index
    dgH2  := high[2]
    dgL2  := low[2]
    dgL0  := low
    dgH0  := high

if bearNew and sizeOK(gapTopDn(), high)
    dgDir := -1
    dgTop := gapTopDn()
    dgBot := high
    dgBar := bar_index
    dgH2  := high[2]
    dgL2  := low[2]
    dgL0  := low
    dgH0  := high

var table dbg = na

// Pine will not let a function be defined inside an if block, so each row is
// written out rather than going through a helper.
dbgKey(int r, string k) =>
    table.cell(dbg, 0, r, k, text_color = color.gray, text_size = size.small, text_halign = text.align_left)

dbgVal(int r, string v) =>
    table.cell(dbg, 1, r, v, text_color = color.white, text_size = size.small, text_halign = text.align_right)

if diag and barstate.islast
    if na(dbg)
        dbg := table.new(position.middle_left, 2, 8, border_width = 1, bgcolor = color.new(#0D1117, 10))
    table.cell(dbg, 0, 0, "LAST GAP DRAWN", text_color = #d1a44a, text_size = size.small)
    table.cell(dbg, 1, 0, dgDir == 1 ? "Bull" : dgDir == -1 ? "Bear" : "none", text_color = #d1a44a, text_size = size.small)
    dbgKey(1, "formed at bar")
    dbgVal(1, str.tostring(dgBar))
    dbgKey(2, "bars ago")
    dbgVal(2, str.tostring(bar_index - dgBar))
    dbgKey(3, "zone top")
    dbgVal(3, str.tostring(dgTop, format.mintick))
    dbgKey(4, "zone bottom")
    dbgVal(4, str.tostring(dgBot, format.mintick))
    dbgKey(5, "high[2] / low[2]")
    dbgVal(5, str.tostring(dgH2, format.mintick) + " / " + str.tostring(dgL2, format.mintick))
    dbgKey(6, "low / high of bar 0")
    dbgVal(6, str.tostring(dgL0, format.mintick) + " / " + str.tostring(dgH0, format.mintick))
    dbgKey(7, "size %")
    dbgVal(7, str.tostring((dgTop - dgBot) / dgBot * 100, "#.###"))
````
