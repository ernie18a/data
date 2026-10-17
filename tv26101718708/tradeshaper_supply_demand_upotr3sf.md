# TradeShaper Supply & Demand

- url: https://www.tradingview.com/script/uPoTR3sF-TradeShaper-Supply-Demand/
- type: indicator
- pine_id: PUB;ab2ef6c27d424dd68e8c4c3aceef558a
- version: 1.0

## Description

TradeShaper Supply & Demand

An inside-bar zone indicator that marks the supply and demand areas created when
price coils and then breaks — the inside candle's range becomes the zone, and the
zone stays live only until price returns to touch it.

The inside-candle formation this script keys off of is based on the supply and
demand methodology taught by Tr3ndy Jon (Jonathan McKeever). This is an
independent implementation of the concept, not affiliated with or endorsed by him.

HOW A ZONE IS BUILT

Three candles define the setup:

1. INITIAL — the candle that establishes the range.
2. INSIDE — the first candle whose close lands inside the initial candle's body.
   Price may keep coiling for several bars, but the zone always anchors to this
   first inside candle.
3. CONFIRMATION — a candle that closes beyond the initial candle. Close above the
   initial high creates a DEMAND zone; close below the initial low creates a
   SUPPLY zone. The confirming candle does not have to be the very next one; the
   setup stays armed for a configurable number of bars.

The zone itself is the inside candle's full high-to-low range, wicks included.

READING THE ZONE

The EDGE is the side price approaches from — the low of a supply zone, the high of
a demand zone. Internal levels are drawn as a percentage of zone depth measured
inward from that edge, so 25% is always a shallow tag and 75% always deep,
regardless of which side you're on.

A zone is consumed the moment any later candle's wick enters it. Only untouched
zones stay on the chart. Zones project forward a fixed number of bars and stop
extending once a newer zone forms.

SETTINGS

Formation — inside-candle definition (close-inside-body or full inside bar), what
the confirming candle must close beyond, and how long a coiling setup stays armed.

Zone — forward projection, what happens when a wick enters a zone (delete or gray
out), and how many zones to keep per side.

Internal levels — any percentages you want (25/50/75 by default, or 38.2/50/61.8
for Fibonacci ratios), each with its own color.

Debug — marks the initial and inside candles and draws the exact levels a candle
must close beyond to confirm. Useful for verifying the logic against your own
reading of the chart.

Alerts fire when price tags a virgin supply or demand edge.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────
//  Inside-Bar Supply & Demand "Edges"
//
//  FORMATION (pending state machine):
//    1. INITIAL candle  — establishes the range.
//    2. INSIDE candle   — the FIRST candle whose CLOSE lands inside the
//                         INITIAL candle's BODY (between its open and close).
//                         Price may coil for several bars, but the inside
//                         candle is always the 1st one.
//    3. CONFIRMATION    — a candle CLOSES BEYOND THE INITIAL CANDLE:
//                           close > initial high  ->  DEMAND (inside & up)
//                           close < initial low   ->  SUPPLY (inside & down)
//                         It need NOT be the very next candle.
//
//  ZONE GEOMETRY:
//    The INSIDE candle's FULL range — high to low, wicks included.
//      SUPPLY : edge = the zone's LOW   (price approaches from below)
//      DEMAND : edge = the zone's HIGH  (price approaches from above)
//
//  INTERNAL LEVELS:
//    % of zone depth measured FROM THE PROXIMAL EDGE inward, so 25% is always
//    a shallow tag and 75% always deep, on both supply and demand.
//
//  LIFECYCLE:
//    * Projects 10 bars past the current bar.
//    * Stops extending once another zone is created.
//    * Consumed the moment a later candle's wick enters it.
// ─────────────────────────────────────────────────────────────
indicator("TradeShaper Supply & Demand", "TradeShaper S&D", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ─── Formation ───────────────────────────────────────────────
gF = "Formation"
insideMode = input.string("Close inside body", "Inside-candle definition",
     options = ["Close inside body", "Full inside (high & low)"], group = gF,
     tooltip = "Close inside body: the candle's CLOSE sits between the initial candle's OPEN and CLOSE.\nFull inside: the entire candle sits within the initial candle's high/low.")
confirmRef = input.string("Initial candle's high/low", "Confirmation measured against",
     options = ["Initial candle's high/low", "Initial candle's body"], group = gF,
     tooltip = "What the confirming candle must close beyond.")
maxWait = input.int(15, "Max bars to wait for confirmation", minval = 1, maxval = 100, group = gF,
     tooltip = "How long a coiling setup stays armed before it's abandoned. Counted in BARS, not days.")

// ─── Zone lifecycle ──────────────────────────────────────────
gZ = "Zone"
extendBars  = input.int(10, "Project past current bar (bars)", minval = 0, maxval = 100, group = gZ)
supersede   = input.string("Any zone", "Stop extending when a new zone forms",
     options = ["Any zone", "Same side only", "Never"], group = gZ)
touchAction = input.string("Delete", "When a wick enters the zone",
     options = ["Delete", "Gray out"], group = gZ)
maxZones    = input.int(10, "Max zones kept per side", minval = 1, maxval = 50, group = gZ)

// ─── Internal levels ─────────────────────────────────────────
gI = "Internal levels"
showLevels  = input.bool(true, "Draw internal levels", group = gI)
levelsInput = input.string("25, 50, 75", "Levels — % of depth from the proximal edge",
     group = gI, tooltip = "Comma-separated, e.g. '25, 50, 75' or '38.2, 50, 61.8'.")
// NOTE: Pine takes TRANSPARENCY, not opacity. 50% opacity = 50 transparency.
levelCol1   = input.color(color.new(color.yellow, 50), "1st level color  (25%)", group = gI)
levelCol2   = input.color(color.new(color.orange, 50), "2nd level color  (50%)", group = gI)
levelCol3   = input.color(color.new(color.aqua,   50), "3rd level color  (75%)", group = gI)
levelColX   = input.color(color.new(color.gray,   50), "4th+ level color",       group = gI)
levelWidth  = input.int(1, "Level width", minval = 1, maxval = 4, group = gI)
levelStyle  = input.string("Solid", "Level style", options = ["Solid", "Dashed", "Dotted"], group = gI)
showLevelLabels = input.bool(true, "Label the levels", group = gI)
levelLabelSize  = input.string("Normal", "Level label size",
     options = ["Tiny", "Small", "Normal", "Large"], group = gI)
levelLabelInset = input.int(4, "Level label inset from right edge (bars)",
     minval = 0, maxval = 50, group = gI,
     tooltip = "Pulls the 25/50/75 text back inside the zone instead of sitting on its right edge.")

// ─── Labels ──────────────────────────────────────────────────
gL = "Labels"
showLabels = input.bool(true, "Show centered SUPPLY / DEMAND labels", group = gL)
showTF     = input.bool(true, "Append chart timeframe to the label",  group = gL)
labelSize  = input.string("Small", "Label size",
     options = ["Tiny", "Small", "Normal", "Large"], group = gL)

// ─── Style ───────────────────────────────────────────────────
gS = "Style"
// 55% opacity = 45 transparency.
supplyCol = input.color(color.new(color.red,   45), "Supply fill",  group = gS)
demandCol = input.color(color.new(color.green, 45), "Demand fill",  group = gS)
supplyTxt = input.color(color.red,   "Supply label text", group = gS)
demandTxt = input.color(color.green, "Demand label text", group = gS)
deadCol   = input.color(color.new(color.gray, 45), "Consumed fill", group = gS)
deadTxt   = input.color(color.new(color.gray, 40), "Consumed text", group = gS)
edgeCol   = input.color(#2962ff, "Edge line", group = gS)
edgeWidth = input.int(2, "Edge line width", minval = 1, maxval = 5, group = gS)
showBox   = input.bool(true, "Show zone box", group = gS)

// ─── Debug ───────────────────────────────────────────────────
gD = "Debug"
showDebug = input.bool(false, "Show state machine internals", group = gD,
     tooltip = "Marks the INSIDE candle and draws the two levels a candle must CLOSE beyond to confirm. Use this to see what the script thinks the initial candle is.")
dbgCol = input.color(color.new(color.white, 30), "Debug color", group = gD)

// ─── Helpers ─────────────────────────────────────────────────
tfString() =>
    int    m   = timeframe.multiplier
    string out = timeframe.period
    if timeframe.isseconds
        out := str.tostring(m) + "s"
    else if timeframe.isintraday
        out := (m >= 60 and m % 60 == 0) ? str.tostring(m / 60) + "h" : str.tostring(m) + "m"
    else if timeframe.isdaily
        out := str.tostring(m) + "D"
    else if timeframe.isweekly
        out := str.tostring(m) + "W"
    else if timeframe.ismonthly
        out := str.tostring(m) + "M"
    out
var string TF = tfString()

sizeOf(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : size.large

lvStyle = levelStyle == "Dashed" ? line.style_dashed :
     levelStyle == "Dotted" ? line.style_dotted : line.style_solid

// colors bind BY POSITION in the levels list
levelColorAt(int i) =>
    i == 0 ? levelCol1 : i == 1 ? levelCol2 : i == 2 ? levelCol3 : levelColX

// where the 25/50/75 text sits: inset from the right edge, but never
// pushed left of the zone's own left edge on a short zone
levelLabelX(int left, int right) =>
    math.max(left, right - levelLabelInset)

// parse "25, 50, 75" -> [0.25, 0.50, 0.75]   (once, on the first bar)
var array<float> LEVELS = array.new<float>()
if barstate.isfirst and showLevels
    array<string> parts = str.split(str.replace_all(levelsInput, " ", ""), ",")
    if array.size(parts) > 0
        for i = 0 to array.size(parts) - 1
            float v = str.tonumber(array.get(parts, i))
            if not na(v) and v > 0 and v < 100
                array.push(LEVELS, v / 100.0)

// ─────────────────────────────────────────────────────────────
type Zone
    box          bx
    line         edge
    label        lb
    array<line>  lv       // internal level lines
    array<label> lvlb     // internal level labels
    float        top
    float        bot
    bool         supply
    bool         dead
    bool         frozen
    int          born
    int          left

var array<Zone> zones = array.new<Zone>()

// ─── Zone drawing helpers (all loops guarded against empty arrays) ──
// Pine's `for i = 0 to -1` counts DOWN and calls array.get(arr, -1),
// which throws. Every level loop below must be size-guarded.
killZone(Zone z) =>
    box.delete(z.bx)
    line.delete(z.edge)
    label.delete(z.lb)
    if array.size(z.lv) > 0
        for j = 0 to array.size(z.lv) - 1
            line.delete(array.get(z.lv, j))
    if array.size(z.lvlb) > 0
        for j = 0 to array.size(z.lvlb) - 1
            label.delete(array.get(z.lvlb, j))

grayZone(Zone z) =>
    if not na(z.bx)
        box.set_bgcolor(z.bx, deadCol)
        box.set_border_color(z.bx, deadCol)
    line.set_color(z.edge, color.new(deadCol, 40))
    if not na(z.lb)
        label.set_textcolor(z.lb, deadTxt)
    if array.size(z.lv) > 0
        for j = 0 to array.size(z.lv) - 1
            line.set_color(array.get(z.lv, j), color.new(deadCol, 40))
    if array.size(z.lvlb) > 0
        for j = 0 to array.size(z.lvlb) - 1
            label.set_textcolor(array.get(z.lvlb, j), deadTxt)

stretchZone(Zone z, int right) =>
    if not na(z.bx)
        box.set_right(z.bx, right)
    line.set_x2(z.edge, right)
    if not na(z.lb)
        label.set_x(z.lb, math.round(math.avg(z.left, right)))
    if array.size(z.lv) > 0
        for j = 0 to array.size(z.lv) - 1
            line.set_x2(array.get(z.lv, j), right)
    if array.size(z.lvlb) > 0
        for j = 0 to array.size(z.lvlb) - 1
            label.set_x(array.get(z.lvlb, j), levelLabelX(z.left, right))

// ─── Pending setup state ─────────────────────────────────────
var bool  pending = false
var float initHi  = na
var float initLo  = na
var int   initIdx = na
var float insHi   = na
var float insLo   = na
var int   insIdx  = na

// ─────────────────────────────────────────────────────────────
if barstate.isconfirmed and bar_index > 1

    bool confirmed = false
    bool isSupply  = false

    // ── 1. Is a live setup confirming on this candle? ──
    if pending
        if close > initHi
            confirmed := true
            isSupply  := false          // closed above the initial -> DEMAND
        else if close < initLo
            confirmed := true
            isSupply  := true           // closed below the initial -> SUPPLY
        else if bar_index - initIdx > maxWait
            pending := false            // still coiling, but it went stale

    // ── 2. Build the zone from the stored INSIDE candle ──
    if confirmed
        pending := false

        if showDebug
            label.new(bar_index, high, text = isSupply ? "conf↓" : "conf↑",
                 xloc = xloc.bar_index, yloc = yloc.abovebar,
                 style = label.style_none, textcolor = dbgCol, size = size.tiny)

        float zTop = insHi
        float zBot = insLo
        if zTop - zBot < syminfo.mintick
            zTop := zBot + syminfo.mintick

        float depth = zTop - zBot
        float prox  = isSupply ? zBot : zTop     // side price approaches from
        int   dir   = isSupply ? 1 : -1          // direction "into" the zone

        color fill  = isSupply ? supplyCol : demandCol
        color txt   = isSupply ? supplyTxt : demandTxt
        int   left  = insIdx
        int   right = bar_index + extendBars

        string txtStr = (isSupply ? "SUPPLY" : "DEMAND") + (showTF ? " " + TF : "")

        // freeze older zones per the supersede rule
        if supersede != "Never" and array.size(zones) > 0
            for i = 0 to array.size(zones) - 1
                Zone old = array.get(zones, i)
                bool applies = supersede == "Any zone" or old.supply == isSupply
                if applies and not old.dead and not old.frozen
                    old.frozen := true

        box b = showBox
             ? box.new(left, zTop, right, zBot,
                  border_color = color.new(fill, 15), bgcolor = fill)
             : na
        line e = line.new(left, prox, right, prox, color = edgeCol, width = edgeWidth)
        label l = showLabels
             ? label.new(math.round(math.avg(left, right)), math.avg(zTop, zBot),
                  text = txtStr, xloc = xloc.bar_index, yloc = yloc.price,
                  style = label.style_none, textcolor = txt,
                  size = sizeOf(labelSize), textalign = text.align_center)
             : na

        // ── internal levels ──
        array<line>  lvls    = array.new<line>()
        array<label> lvlLbls = array.new<label>()

        if showLevels and array.size(LEVELS) > 0
            for i = 0 to array.size(LEVELS) - 1
                float pct = array.get(LEVELS, i)
                float y   = prox + dir * pct * depth
                color lc  = levelColorAt(i)
                array.push(lvls, line.new(left, y, right, y,
                     color = lc, width = levelWidth, style = lvStyle))
                if showLevelLabels
                    array.push(lvlLbls, label.new(levelLabelX(left, right), y,
                         text = str.tostring(pct * 100, "#.##"),
                         xloc = xloc.bar_index, yloc = yloc.price,
                         style = label.style_none, textcolor = lc,
                         size = sizeOf(levelLabelSize), textalign = text.align_center))

        array.push(zones, Zone.new(b, e, l, lvls, lvlLbls,
             zTop, zBot, isSupply, false, false, bar_index, left))

        // cap stored zones per side, dropping the oldest
        int cnt = 0
        for i = array.size(zones) - 1 to 0
            Zone z = array.get(zones, i)
            if z.supply == isSupply
                cnt += 1
                if cnt > maxZones
                    killZone(z)
                    array.remove(zones, i)

    // ── 3. Does this candle open a NEW setup? ──
    if not pending
        // INSIDE = this candle's CLOSE sits within the previous candle's BODY.
        float pBodyHi = math.max(open[1], close[1])
        float pBodyLo = math.min(open[1], close[1])

        bool insideOk = insideMode == "Close inside body"
             ? (close <= pBodyHi and close >= pBodyLo)
             : (high  <= high[1]  and low   >= low[1])

        if insideOk
            pending := true
            // levels the confirming candle must close beyond
            initHi  := confirmRef == "Initial candle's body" ? pBodyHi : high[1]
            initLo  := confirmRef == "Initial candle's body" ? pBodyLo : low[1]
            initIdx := bar_index - 1
            insHi   := high             // the INSIDE candle
            insLo   := low
            insIdx  := bar_index

            if showDebug
                // the two levels a candle must CLOSE beyond to confirm
                line.new(initIdx, initHi, bar_index + maxWait, initHi,
                     color = dbgCol, style = line.style_dotted, width = 1)
                line.new(initIdx, initLo, bar_index + maxWait, initLo,
                     color = dbgCol, style = line.style_dotted, width = 1)
                // which candle the script called INSIDE
                label.new(bar_index, low, text = "in", xloc = xloc.bar_index,
                     yloc = yloc.belowbar, style = label.style_none,
                     textcolor = dbgCol, size = size.tiny)
                // which candle the script called INITIAL
                label.new(initIdx, high[1], text = "init", xloc = xloc.bar_index,
                     yloc = yloc.abovebar, style = label.style_none,
                     textcolor = dbgCol, size = size.tiny)

// ─── Maintain: project right, enforce the "no wick" rule ─────
if array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        Zone z = array.get(zones, i)

        if z.dead or bar_index <= z.born
            continue

        bool touched = z.supply ? high >= z.bot : low <= z.top

        if touched
            if touchAction == "Delete"
                killZone(z)
                array.remove(zones, i)
                continue
            else
                z.dead := true
                grayZone(z)
        else if not z.frozen
            stretchZone(z, bar_index + extendBars)

// ─── Alerts ──────────────────────────────────────────────────
var bool hitSupply = false
var bool hitDemand = false
hitSupply := false
hitDemand := false

if array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        Zone z = array.get(zones, i)
        if not z.dead and bar_index > z.born
            if z.supply and high >= z.bot
                hitSupply := true
            if not z.supply and low <= z.top
                hitDemand := true

alertcondition(hitSupply, "Supply edge tagged", "Price tagged a virgin SUPPLY edge")
alertcondition(hitDemand, "Demand edge tagged", "Price tagged a virgin DEMAND edge")
````
