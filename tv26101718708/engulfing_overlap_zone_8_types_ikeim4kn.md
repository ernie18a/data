# Engulfing Overlap Zone [8 Types]

- url: https://www.tradingview.com/script/iKEIM4KN-Engulfing-Overlap-Zone-8-Types/
- type: indicator
- pine_id: PUB;e04f28055c90440b82699d578505c56b
- version: 1.0

## Description

[b]Engulfing Overlap Zone [8 Types][/b]

This script looks for the moment control changes hands.

An engulfing pattern forms and commits one side of the market. Later that pattern breaks. On or
around the same candle, an engulfing pattern in the OPPOSITE direction confirms. When the two
structures occupy the same price area, that shared area is where one side was trapped and the
other took over. This script finds those moments and draws only that area.

Nothing else is plotted. Ordinary engulfing patterns, and engulfing patterns that simply failed,
are used internally but never drawn, because on their own they are not what this tool is about.


[b]WHAT MAKES THIS DIFFERENT[/b]

[b]1. It reports a transfer of control, not a pattern.[/b]

Most pattern tools mark every occurrence they find. This one requires a three step sequence to
complete before anything appears: a pattern forms, that pattern breaks, and an opposing pattern
confirms in the same price area. Any of the three missing means nothing is drawn.

[b]2. The zone is measured, not just marked.[/b]

Two zones can touch by a hair or sit almost perfectly on top of each other. Those are very
different situations, so the script measures how much of the zone is actually shared and states
it as a percentage. You can then hide everything below a threshold you choose.

[b]3. Everything is sorted into eight types.[/b]

The zone carries the identity of the engulfing pattern that took over, including whether that
pattern grabbed liquidity before it confirmed. Each of the eight can be shown or hidden
independently and has its own alert.

[b]4. The hard part is the pairing.[/b]

When a pattern breaks there is often more than one opposing pattern nearby that could be its
counterpart. Picking the right one, and rejecting the ones that only look related, is what this
script is really about. The rule used is simple to state and is described below, but it is the
piece that decides whether the output is meaningful or noise.


[b]THE PATTERNS INVOLVED[/b]

A candle is Green when close is greater than open, Red when close is less than open, and a Doji
when close equals open. A Doji is neither. Only fully closed candles are read, and the running
candle is never used.

[b]Regular engulfing, two candles[/b]

R Buy EG: Red Base candle, and the very next candle is Green and closes above the Base High.
R Sell EG: Green Base candle, and the very next candle is Red and closes below the Base Low.

[b]E-Regular engulfing, three or more candles[/b]

[b]ER Buy EG:[/b] Red Base candle followed by a run of consecutive Green candles. The run must contain
at least 2 Green candles, and confirmation happens when one of them closes above the Base High.
A single Red candle before confirmation cancels the run. Doji candles are skipped: they neither
count toward the run nor break it.

[b]ER Sell EG: [/b]the mirror image, with a Green Base and a run of at least 2 Red candles, one of
which closes below the Base Low.

If the very first candle after the Base already closes through it, that is by definition a
Regular pattern, so E-Regular requires the second candle or later to break the level. One Base
candle can never produce both.

[b]Type 1, the same four patterns plus a liquidity sweep[/b]

Type 1 adds one requirement: before the close breaks through one side of the Base candle, price
must have traded through the opposite side.

[b]T1 R Buy EG:[/b] the Confirm candle's Low reaches at or below the Base Low.
[b]T1 R Sell EG:[/b] the Confirm candle's High reaches at or above the Base High.
[b]T1 ER Buy EG:[/b] at least one Green candle of the run reaches at or below the Base Low.
[b]T1 ER Sell EG:[/b] at least one Red candle of the run reaches at or above the Base High.

Any candle of the run can satisfy the sweep, including the Confirm candle itself. The sweep is
always measured against the Base candle, never against another candle in the run.


[b]HOW AN OVERLAP ZONE IS BUILT[/b]

Step 1. A pattern confirms and is tracked from then on.

Step 2. The pattern breaks. A Buy Engulfing breaks when a Red candle CLOSES below its Base Low.
A Sell Engulfing breaks when a Green candle CLOSES above its Base High. A wick through the level
is not enough; the close has to settle beyond it.

Step 3. The script looks for an engulfing pattern in the opposite direction whose confirmation
lands on the breaking candle, or as close before it as possible, and whose zone shares both time
and price with the broken one. Where several candidates exist, the one closest to the break is
taken, because that is the one that actually represents the handover.

When all three steps line up, one zone is drawn: the price range of the Base candle of the
pattern that took over, running from that Base candle to its Confirm candle.

The eight resulting types are R Buy EG Overlap, R Sell EG Overlap, ER Buy EG Overlap, ER Sell EG
Overlap and the four Type 1 versions of the same. The type always describes the pattern that
took over, because that is the zone on your chart.


[b]OVERLAP STRENGTH[/b]

Strength is the share of the drawn zone that sits inside the price range of the broken zone.

100 percent means the whole zone is shared, which is the tightest possible confluence. A small
number means the two structures barely reach each other. The figure is appended to each label,
and Minimum Overlap Strength lets you discard anything below a level you set. That threshold
applies to the chart, the summary table and the alerts together, so what you see and what you
are notified about never disagree.


[b]READING THE CHART[/b]

Each zone is filled in two tones, and the split is the whole point:

- The part that shares price with the broken zone is drawn in the direction colour, green for a
  Buy Overlap and red for a Sell Overlap, with a solid border. This is the confluence.
- Whatever is left over is drawn in neutral yellow with no border.

So the colour split you see is the strength figure, shown rather than stated. A zone that is
almost entirely green is strong. A zone with a thin green sliver and a large yellow body is
weak, and the percentage will say so.

Each zone carries a label with its type and strength, placed below a Buy Overlap and above a
Sell Overlap so it points at its own zone.

A summary table in the corner counts what was found in the current scan window, split by Buy and
Sell. Types you have switched off are still counted, so the table always reflects what the market
printed rather than what is currently on screen. Zones rejected by the strength threshold are not
counted, because that threshold decides what qualifies as a zone at all.


[b]SETTINGS[/b]

[b]Scan[/b]
- Scan Length: how many closed candles are scanned backwards. The running candle is always
  excluded.
- Minimum Overlap Strength: the percentage a zone must reach to qualify.

[b]Pattern Types[/b]
- An individual switch for each of the eight types.

[b]Zone Style[/b]
- Separate colours for the shared area and the remaining area, on both the Buy and Sell side.

[b]Labels[/b]
- Show Labels, Show Strength in Label, Label Size, and Label Distance from Zone as a percentage
  of the zone height. Increase the distance on noisy charts so labels clear the candles.

[b]Summary Table[/b]
- Show, position and size of the corner table.


[b]ALERTS[/b]

Eight alert conditions are available, one per type:

R Buy EG Overlap, R Sell EG Overlap, T1 R Buy EG Overlap, T1 R Sell EG Overlap, ER Buy EG
Overlap, ER Sell EG Overlap, T1 ER Buy EG Overlap, T1 ER Sell EG Overlap.

An alert fires on the candle that completes the handover. Each message carries the type, the
symbol, the timeframe and the closing price. The same messages are also sent through the alert
function, so the "Any alert() function call" alert type can deliver every zone through a single
alert.

All alerts are evaluated only after a candle has fully closed.

If you read the source, note that the chart and the alerts are two separate paths. The chart is
rebuilt by scanning history backwards on the last bar, while the alerts keep a running list of
confirmed patterns and test each closed candle against it. Two paths are used because rescanning
the whole history on every bar would be far too slow, and a running list cannot redraw the past.
Both apply exactly the same rules and the same strength threshold, so they always agree.


[b]REPAINTING[/b]

This script does not repaint.

- Detection reads confirmed candles only. The scan starts one bar behind the latest bar, so the
  candle that is still forming is never part of any calculation.
- Every alert signal is written so that it can only become true once a candle has finished. Price
  moving inside an open candle cannot make a signal appear and then disappear.
- Zones are rebuilt on the last bar from confirmed history. A drawn zone does not move, change
  colour, change type or change its strength figure afterwards. It only leaves the chart when it
  falls outside the Scan Length window.

When you create an alert, TradingView may show a caution banner saying the indicator can repaint.
That banner appears automatically for any script that uses the built in bar state variables, no
matter how they are used, because the platform cannot check the intent behind them. This script
uses them for the opposite purpose: one of them is what restricts every signal to bar close, and
the other is what redraws the zones efficiently on the final bar. Choosing "Once Per Bar Close"
when creating the alert is still recommended.


[b]NOTES AND LIMITATIONS[/b]

- These zones are rare by design. Three separate conditions have to line up, so long stretches
  with nothing on the chart are normal and expected. If you want to see more, lower the strength
  threshold before raising the scan length.
- Scan Length is capped lower than in a plain pattern scanner. Every candidate pattern has to be
  followed forward for a break and then matched against opposing patterns, which is far heavier
  than simply detecting a pattern. The cap keeps the script responsive on slower machines.
- A zone whose Base candle falls outside the scan window will not appear even if the handover
  itself was recent. If zones seem to be missing, raise the Scan Length before changing anything
  else.
- For alerts the number of patterns tracked at once is capped and the oldest are released first.
  In practice patterns break or age out long before this matters.
- Detection is purely structural. It reports where control changed hands and how much the two
  structures shared. It does not rank zones beyond that, measure what happened afterwards, or
  produce entries, targets or stops.
- Doji candles are treated as neutral by design. They never act as a Base candle and never break
  an E-Regular run. On symbols and timeframes that print many Doji candles this makes runs
  slightly more tolerant than a strict same colour rule would be.


[b]HOW TO USE IT[/b]

A zone marks an area where one side committed, was proven wrong, and was immediately replaced by
the other side. Traders commonly watch these areas for reactions when price returns to them,
particularly the shared portion, since that is the part both structures agreed on.

The strength figure is there to let you be selective. Starting at zero shows everything so you
can see how the tool behaves on your symbol and timeframe, and raising it narrows the output to
the tighter confluences.

Type 1 zones are worth separating out. There the pattern that took over first grabbed liquidity
and only then confirmed, which is a different sequence from a clean takeover.

These are reference areas, not entry signals. Use them alongside higher timeframe structure, your
own support and resistance mapping, and proper risk management.


[b]DISCLAIMER[/b]

This indicator is a pattern detection tool. It is not financial advice and it makes no claim
about profitability. Trading involves risk. Always apply your own analysis and risk management.

## Source Code

````pine
//@version=6
indicator(
     title            = "Engulfing Overlap Zone [8 Types]",
     overlay          = true,
     max_boxes_count  = 500,
     max_labels_count = 500,
     max_bars_back    = 5000
     )

// ============================ INPUTS ============================
gScan  = "Scan"
gType  = "Pattern Types"
gStyle = "Zone Style"
gLabel = "Labels"
gTable = "Summary Table"

candleLen = input.int(50, "Scan Length (closed candles)", minval = 5, maxval = 200, group = gScan,
     tooltip = "How many closed candles are scanned backwards from the latest bar. The running candle is always excluded. This scan is heavier than a plain pattern scan, so the range is kept deliberately short.")

minStrength = input.int(0, "Minimum Overlap Strength (%)", minval = 0, maxval = 100, group = gScan,
     tooltip = "How much of the Overlap zone has to share price with the failed zone before it counts as a zone at all. 0 accepts every overlap. Raising it keeps only the tighter confluences, and it applies to the chart, the summary table and the alerts alike.")

showRegBuy    = input.bool(true, "Regular Buy Overlap",           group = gType)
showRegSell   = input.bool(true, "Regular Sell Overlap",          group = gType)
showErBuy     = input.bool(true, "E-Regular Buy Overlap",         group = gType)
showErSell    = input.bool(true, "E-Regular Sell Overlap",        group = gType)
showT1RegBuy  = input.bool(true, "Type 1 Regular Buy Overlap",    group = gType)
showT1RegSell = input.bool(true, "Type 1 Regular Sell Overlap",   group = gType)
showT1ErBuy   = input.bool(true, "Type 1 E-Regular Buy Overlap",  group = gType)
showT1ErSell  = input.bool(true, "Type 1 E-Regular Sell Overlap", group = gType)

// The zone drawn is the Overlap Engulfing candle range. It is split in two:
// the part that shares price with the failed zone, and the part that does not.
// The shared slice carries the direction colour, the leftover is neutral yellow.
buySharedColor = input.color(color.new(#22c55e, 45), "Buy Overlap - Shared Area",    group = gStyle,
     tooltip = "The slice of the Buy Overlap zone that shares price with the failed Sell zone.")
buyRestColor   = input.color(color.new(#eab308, 75), "Buy Overlap - Remaining Area", group = gStyle,
     tooltip = "The rest of the Buy Overlap zone, outside the shared slice.")
sellSharedColor = input.color(color.new(#ef4444, 45), "Sell Overlap - Shared Area",    group = gStyle,
     tooltip = "The slice of the Sell Overlap zone that shares price with the failed Buy zone.")
sellRestColor   = input.color(color.new(#eab308, 75), "Sell Overlap - Remaining Area", group = gStyle,
     tooltip = "The rest of the Sell Overlap zone, outside the shared slice.")

showLabels     = input.bool(true, "Show Labels",              group = gLabel)
showStrength   = input.bool(true, "Show Strength % in Label", group = gLabel,
     tooltip = "Appends the shared-area percentage to each label.")
labelSizeStr   = input.string("Normal", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gLabel)
labelOffsetPct = input.int(40, "Label Distance from Zone (%)", minval = 0, group = gLabel,
     tooltip = "Gap between the zone edge and the label, as a percentage of the zone height.")

showTable    = input.bool(true, "Show Summary Table", group = gTable)
tablePosStr  = input.string("Top Right", "Table Position", options = ["Top Right", "Middle Right", "Bottom Right", "Top Left", "Bottom Left"], group = gTable)
tableSizeStr = input.string("Small", "Table Size", options = ["Tiny", "Small", "Normal"], group = gTable)

// ============================ STYLE CONSTANTS ============================
labelBull = #107a34
labelBear = #b22222
tableHead = #000000
tableBg   = #1e222d
tableEdge = #363a45

maxPats = 120                       // cap on engulfing patterns tracked for live alerts

labelSize = labelSizeStr == "Tiny" ? size.tiny : labelSizeStr == "Small" ? size.small : labelSizeStr == "Large" ? size.large : size.normal
tableSize = tableSizeStr == "Tiny" ? size.tiny : tableSizeStr == "Normal" ? size.normal : size.small
tablePos  = tablePosStr == "Top Right" ? position.top_right : tablePosStr == "Middle Right" ? position.middle_right : tablePosStr == "Bottom Right" ? position.bottom_right : tablePosStr == "Top Left" ? position.top_left : position.bottom_left

// ============================ TYPES ============================
// One confirmed engulfing pattern, kept so that live alerts can match a failure
// against an opposite pattern without rescanning history.
type EgPat
    int   baseBar
    int   confBar
    float baseHigh
    float baseLow
    bool  isBuy
    bool  isExt
    bool  swept
    bool  failed

// ============================ CANDLE COLOUR HELPERS ============================
// A Doji (close == open) is neither Green nor Red. It never acts as a Base and
// never breaks an E-Regular run - it is simply skipped.
isGreen(int i) => close[i] > open[i]
isRed(int i)   => close[i] < open[i]
isDoji(int i)  => close[i] == open[i]

// ============================ ENGULFING SCANNERS ============================
// Regular scan. The Confirm candle always sits exactly one bar after the Base.
// Returns [dir, swept]
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
eRegularScan(int baseOff) =>
    int  dir   = 0
    int  dist  = 0
    bool swept = false
    if baseOff >= 3
        float baseHigh = high[baseOff]
        float baseLow  = low[baseOff]

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
                    if greens >= 2
                        dir   := 1
                        dist  := m
                        swept := sw
                    break

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

// Combined scan. Regular is tested first; E-Regular is only considered when no
// Regular formed on the same Base, so one Base yields at most one pattern.
// Returns [dir, dist, isExt, swept]
egScan(int baseOff) =>
    [rDir, rSwept] = regularScan(baseOff)
    int  dir   = rDir
    int  dist  = 1
    bool ext   = false
    bool swept = rSwept
    if dir == 0
        [eDir, eDist, eSwept] = eRegularScan(baseOff)
        dir   := eDir
        dist  := eDist
        swept := eSwept
        ext   := true
    [dir, dist, ext, swept]

// ============================ FAILURE SCANNER ============================
// Scans forward from the bar after the Confirm candle and returns the offset of
// the FIRST candle that invalidates the pattern, or na while it is still intact.
//   Buy  Engulfing fails when a Red candle CLOSES below the Base candle Low
//   Sell Engulfing fails when a Green candle CLOSES above the Base candle High
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
// The tag describes the OVERLAP pattern, because that is the zone being drawn.
overlapTag(bool isBuy, bool isExt, bool isT1) =>
    (isT1 ? "T1 " : "") + (isExt ? "ER " : "R ") + (isBuy ? "Buy" : "Sell") + " EG Overlap"

// How much of the Overlap zone sits inside the failed zone's price range. This
// is exactly the shared-to-total ratio that the two tones show on the chart:
// 100 means the whole zone is shared, a small number means they barely touch.
overlapStrength(float zTop, float zBot, float failTop, float failBot) =>
    float h     = zTop - zBot
    float shTop = math.min(zTop, failTop)
    float shBot = math.max(zBot, failBot)
    float sh    = math.max(0.0, shTop - shBot)
    h > 0 ? sh / h * 100.0 : 0.0

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

pushBox(int xL, float yT, int xR, float yB, color fill, bool solidEdge) =>
    box b = box.new(xL, yT, xR, yB,
         xloc         = xloc.bar_index,
         border_color = solidEdge ? color.new(fill, 0) : color.new(fill, 100),
         border_width = 1,
         bgcolor      = fill)
    array.push(gBoxes, b)

// Draws the Overlap zone only: the Overlap Engulfing Base candle range, running
// from that Base candle to its Confirm candle. The zone is filled in two tones -
// the price slice it shares with the failed zone, and whatever is left over.
drawOverlapZone(int oppBase, int oppConf, float failTop, float failBot, bool isBuy, bool isExt, bool isT1, float strength) =>
    int   xL   = bar_index - oppBase
    int   xR   = bar_index - oppConf
    float zTop = high[oppBase]
    float zBot = low[oppBase]

    // Price slice shared with the failed zone, clipped to this zone.
    float shTop = math.min(zTop, failTop)
    float shBot = math.max(zBot, failBot)

    color shColor = isBuy ? buySharedColor : sellSharedColor
    color rsColor = isBuy ? buyRestColor   : sellRestColor

    // Whatever sits above the shared slice.
    if zTop > shTop
        pushBox(xL, zTop, xR, shTop, rsColor, false)
    // The shared slice itself. Its solid border is what marks the boundary
    // between the two tones.
    pushBox(xL, shTop, xR, shBot, shColor, true)
    // Whatever sits below the shared slice.
    if shBot > zBot
        pushBox(xL, shBot, xR, zBot, rsColor, false)

    if showLabels
        float h   = math.abs(zTop - zBot)
        float off = h * labelOffsetPct * 0.01
        float y   = isBuy ? zBot - off : zTop + off
        int   x   = xL + int(math.round((xR - xL) / 2.0))
        string txt = overlapTag(isBuy, isExt, isT1) + (showStrength ? " " + str.tostring(math.round(strength)) + "%" : "")
        label lb = label.new(x, y,
             text      = txt,
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
    table.cell(sumTable, 1, row, str.tostring(buyN),  bgcolor = tableBg, text_color = color.new(buySharedColor, 0),  text_size = tableSize)
    table.cell(sumTable, 2, row, str.tostring(sellN), bgcolor = tableBg, text_color = color.new(sellSharedColor, 0), text_size = tableSize)

// ============================ MAIN SCAN AND REDRAW ============================
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
        [egDir, egDist, egExt, egSwept] = egScan(i)

        if egDir != 0
            bool failIsBuy = egDir > 0
            int  confOff   = i - egDist
            int  failOff   = findFailure(i, confOff, failIsBuy)

            if not na(failOff)
                // Look for an opposite pattern whose confirmation lands on the
                // failure candle, or as close before it as possible. That is the
                // moment control changes hands.
                int  oppBase  = na
                int  oppConf  = na
                bool oppExt   = false
                bool oppSwept = false
                int  bestD    = 1000000

                for j = failOff to maxScan
                    [o2Dir, o2Dist, o2Ext, o2Swept] = egScan(j)
                    bool wanted = failIsBuy ? (o2Dir < 0) : (o2Dir > 0)
                    if wanted
                        int k = j - o2Dist
                        if k >= failOff
                            int d = k - failOff
                            if d < bestD
                                bestD    := d
                                oppBase  := j
                                oppConf  := k
                                oppExt   := o2Ext
                                oppSwept := o2Swept

                if not na(oppBase)
                    // Both zones have to touch in time and in price.
                    int   xL1 = bar_index - i
                    int   xR1 = bar_index - failOff
                    float yT1 = high[i]
                    float yB1 = low[i]
                    int   xL2 = bar_index - oppBase
                    int   xR2 = bar_index - oppConf
                    float yT2 = high[oppBase]
                    float yB2 = low[oppBase]

                    bool  xTouch   = (xL1 <= xR2) and (xL2 <= xR1)
                    bool  yTouch   = (yB1 <= yT2) and (yB2 <= yT1)
                    float strength = overlapStrength(yT2, yB2, yT1, yB1)

                    if xTouch and yTouch and strength >= minStrength
                        bool oppIsBuy = not failIsBuy

                        if oppExt and oppSwept and oppIsBuy
                            cT1ErBuy += 1
                        else if oppExt and oppSwept
                            cT1ErSell += 1
                        else if oppExt and oppIsBuy
                            cErBuy += 1
                        else if oppExt
                            cErSell += 1
                        else if oppSwept and oppIsBuy
                            cT1RegBuy += 1
                        else if oppSwept
                            cT1RegSell += 1
                        else if oppIsBuy
                            cRegBuy += 1
                        else
                            cRegSell += 1

                        if zoneVisible(oppIsBuy, oppExt, oppSwept)
                            drawOverlapZone(oppBase, oppConf, yT1, yB1, oppIsBuy, oppExt, oppSwept, strength)

    if showTable
        table.cell(sumTable, 0, 0, "Overlap Zone", bgcolor = tableHead, text_color = color.white, text_size = tableSize, text_halign = text.align_left)
        table.cell(sumTable, 1, 0, "Buy",          bgcolor = tableHead, text_color = color.white, text_size = tableSize)
        table.cell(sumTable, 2, 0, "Sell",         bgcolor = tableHead, text_color = color.white, text_size = tableSize)
        tableRow(1, "Regular",      cRegBuy,   cRegSell)
        tableRow(2, "E-Regular",    cErBuy,    cErSell)
        tableRow(3, "T1 Regular",   cT1RegBuy, cT1RegSell)
        tableRow(4, "T1 E-Regular", cT1ErBuy,  cT1ErSell)
    else
        table.clear(sumTable, 0, 0, 2, 4)

// ============================ LIVE PATTERN STATE (BAR CLOSE ONLY) ============================
// ---- Regular: Base is offset 1, Confirm is the candle that just closed ----
regBuyRaw    = isRed(1)   and isGreen(0) and close > high[1]
regSellRaw   = isGreen(1) and isRed(0)   and close < low[1]
regBuySwept  = regBuyRaw  and low  <= low[1]
regSellSwept = regSellRaw and high >= high[1]

// ---- E-Regular: rolling state machine over closed candles ----
var int   erBuyBar    = na
var float erBuyHigh   = na
var float erBuyLow    = na
var int   erBuyGreens = 0
var bool  erBuySwept  = false
var bool  erBuyDone   = false

var int   erSellBar    = na
var float erSellHigh   = na
var float erSellLow    = na
var int   erSellReds   = 0
var bool  erSellSwept  = false
var bool  erSellDone   = false

if barstate.isconfirmed
    if isRed(0)
        erBuyBar    := bar_index
        erBuyHigh   := high
        erBuyLow    := low
        erBuyGreens := 0
        erBuySwept  := false
        erBuyDone   := false
    else if isGreen(0) and not na(erBuyHigh)
        erBuyGreens += 1
        erBuySwept  := erBuySwept or low <= erBuyLow

    if isGreen(0)
        erSellBar   := bar_index
        erSellHigh  := high
        erSellLow   := low
        erSellReds  := 0
        erSellSwept := false
        erSellDone  := false
    else if isRed(0) and not na(erSellLow)
        erSellReds  += 1
        erSellSwept := erSellSwept or high >= erSellHigh

erBuyHit  = barstate.isconfirmed and not na(erBuyHigh) and not erBuyDone  and isGreen(0) and erBuyGreens >= 2 and close > erBuyHigh
erSellHit = barstate.isconfirmed and not na(erSellLow) and not erSellDone and isRed(0)   and erSellReds  >= 2 and close < erSellLow

// A Regular pattern also consumes its Base candle, otherwise the same Base could
// confirm as Regular first and then again as E-Regular a few candles later.
if barstate.isconfirmed and (erBuyHit or regBuyRaw)
    erBuyDone := true
if barstate.isconfirmed and (erSellHit or regSellRaw)
    erSellDone := true

erBuyCond  = erBuyHit  and not regBuyRaw
erSellCond = erSellHit and not regSellRaw

// ============================ LIVE OVERLAP DETECTION ============================
var EgPat[] pats = array.new<EgPat>()

// Finds the opposite pattern that completed on this candle, or as close before it
// as possible, and that shares both time and price with the zone that just broke.
findOpposite(EgPat p) =>
    EgPat best  = na
    int   bestD = 1000000
    int   n     = array.size(pats)
    if n > 0
        for b = 0 to n - 1
            EgPat q = array.get(pats, b)
            if q.isBuy != p.isBuy and q.confBar <= bar_index
                bool xTouch = (p.baseBar <= q.confBar) and (q.baseBar <= bar_index)
                bool yTouch = (p.baseLow <= q.baseHigh) and (q.baseLow <= p.baseHigh)
                int  d      = bar_index - q.confBar
                if xTouch and yTouch and d < bestD
                    bestD := d
                    best  := q
    best

var bool olRBuy     = false
var bool olRSell    = false
var bool olErBuy    = false
var bool olErSell   = false
var bool olT1RBuy   = false
var bool olT1RSell  = false
var bool olT1ErBuy  = false
var bool olT1ErSell = false

if barstate.isconfirmed
    olRBuy     := false
    olRSell    := false
    olErBuy    := false
    olErSell   := false
    olT1RBuy   := false
    olT1RSell  := false
    olT1ErBuy  := false
    olT1ErSell := false

    // Step 1: record patterns that confirmed on this candle. This happens first
    // because the candle that breaks one pattern is usually the same candle that
    // confirms the opposite one.
    if regBuyRaw
        array.push(pats, EgPat.new(bar_index - 1, bar_index, high[1], low[1], true,  false, regBuySwept,  false))
    if regSellRaw
        array.push(pats, EgPat.new(bar_index - 1, bar_index, high[1], low[1], false, false, regSellSwept, false))
    if erBuyCond
        array.push(pats, EgPat.new(erBuyBar,  bar_index, erBuyHigh,  erBuyLow,  true,  true, erBuySwept,  false))
    if erSellCond
        array.push(pats, EgPat.new(erSellBar, bar_index, erSellHigh, erSellLow, false, true, erSellSwept, false))

    while array.size(pats) > maxPats
        array.shift(pats)

    // Step 2: test every intact pattern against this candle. A pattern cannot
    // break on its own Confirm candle, because the breaking candle would have to
    // be the opposite colour to the one that confirmed it.
    int np = array.size(pats)
    if np > 0
        for a = 0 to np - 1
            EgPat p     = array.get(pats, a)
            bool  broke = (not p.failed) and (p.isBuy ? (isRed(0) and close < p.baseLow) : (isGreen(0) and close > p.baseHigh))
            if broke
                p.failed := true
                EgPat best = findOpposite(p)
                if not na(best)
                    // Step 3: the same strength rule the chart uses, so an alert
                    // can never fire for a zone the chart is not drawing.
                    float st = overlapStrength(best.baseHigh, best.baseLow, p.baseHigh, p.baseLow)
                    if st >= minStrength
                        if best.isExt and best.swept and best.isBuy
                            olT1ErBuy := true
                        else if best.isExt and best.swept
                            olT1ErSell := true
                        else if best.isExt and best.isBuy
                            olErBuy := true
                        else if best.isExt
                            olErSell := true
                        else if best.swept and best.isBuy
                            olT1RBuy := true
                        else if best.swept
                            olT1RSell := true
                        else if best.isBuy
                            olRBuy := true
                        else
                            olRSell := true

// ============================ ALERTS ============================
alertcondition(olRBuy,     title = "R Buy EG Overlap",     message = "R Buy EG Overlap | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(olRSell,    title = "R Sell EG Overlap",    message = "R Sell EG Overlap | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(olT1RBuy,   title = "T1 R Buy EG Overlap",  message = "T1 R Buy EG Overlap | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(olT1RSell,  title = "T1 R Sell EG Overlap", message = "T1 R Sell EG Overlap | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(olErBuy,    title = "ER Buy EG Overlap",    message = "ER Buy EG Overlap | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(olErSell,   title = "ER Sell EG Overlap",   message = "ER Sell EG Overlap | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(olT1ErBuy,  title = "T1 ER Buy EG Overlap", message = "T1 ER Buy EG Overlap | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(olT1ErSell, title = "T1 ER Sell EG Overlap", message = "T1 ER Sell EG Overlap | {{ticker}} {{interval}} | Close {{close}}")

alertMsg(string tag) =>
    tag + " | " + syminfo.ticker + " " + timeframe.period + " | Close " + str.tostring(close, format.mintick)

if barstate.isconfirmed
    if olRBuy
        alert(alertMsg("R Buy EG Overlap"), alert.freq_once_per_bar_close)
    if olRSell
        alert(alertMsg("R Sell EG Overlap"), alert.freq_once_per_bar_close)
    if olT1RBuy
        alert(alertMsg("T1 R Buy EG Overlap"), alert.freq_once_per_bar_close)
    if olT1RSell
        alert(alertMsg("T1 R Sell EG Overlap"), alert.freq_once_per_bar_close)
    if olErBuy
        alert(alertMsg("ER Buy EG Overlap"), alert.freq_once_per_bar_close)
    if olErSell
        alert(alertMsg("ER Sell EG Overlap"), alert.freq_once_per_bar_close)
    if olT1ErBuy
        alert(alertMsg("T1 ER Buy EG Overlap"), alert.freq_once_per_bar_close)
    if olT1ErSell
        alert(alertMsg("T1 ER Sell EG Overlap"), alert.freq_once_per_bar_close)
````
