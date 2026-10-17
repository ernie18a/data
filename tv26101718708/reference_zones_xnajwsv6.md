# Reference Zones

- url: https://www.tradingview.com/script/XNAjWSV6-Reference-Zones/
- type: indicator
- pine_id: PUB;0db493407b0843288039c37db1143822
- version: 1.0

## Description

Reference Range Zones maps an anchor period's trading range into colored horizontal zones, so you can read at a glance where current price sits relative to the prior session's premium, value, and discount areas.
What it does

It takes the high and low of a chosen anchor timeframe (the previous day by default), divides that range into equal horizontal zones, and draws each zone as a band of dotted lines. The top zones are colored as premium (potential resistance / distribution), the middle zones as value, and the bottom zones as discount (potential support / accumulation). A configurable number of past periods stay on the chart as history.
How it works

On each new anchor period the script captures the just-completed period's high and low, then splits that range into N equal slices. For each slice it renders a band of evenly spaced lines, where the "fill %" input controls how much of the slice height the band occupies — lower values leave visible gaps between bands. Zone color is assigned by position: a settable number of top slices use the premium color, a settable number of bottom slices use the discount color, and everything between uses the value color. Optional price labels mark each zone boundary at the right edge. Completed periods are frozen in place and the oldest are pruned once the kept-history limit is reached. A built-in line budget automatically reduces how many history periods are drawn if your zone and density settings would exceed the platform's drawing limit, so the script stays within limits without manual tuning.
How to use it

Treat the discount band as an area where longs are at a relative range low and the premium band as an area where shorts are at a relative range high; the value band in the middle is where price is closer to equilibrium. The zones are reference context, not signals — combine them with your own structure, trend, or volume read. Use "Previous period" mode for fixed levels you can plan around at the open, or "Current (developing)" mode to watch zones expand with the live session.
Inputs

Anchor timeframe and range source (previous vs developing); number of history periods to keep; number of zones, and how many top/bottom zones are premium/discount; line style, width, density, and band fill %; right-edge projection toggle; edge price labels; and full color and transparency control.
Notes

No zones appear until at least one anchor period has completed (in "Previous period" mode). This is a visual range-context tool and makes no claim about future price direction or performance.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════
//  Reference Zones [Replica] — IRZ / "by MTJ" style banded range map
//  ----------------------------------------------------------------------
//  Splits an anchor period's range (default: the previous day) into N
//  horizontal zones and paints each as a band of dotted lines:
//      • top zones    -> Premium  (red)
//      • middle zones -> Value    (blue)
//      • bottom zones -> Discount (green)
//  Zones rebuild each new anchor period and a few periods are kept as history.
//  This is a faithful look-alike of the proprietary MTJ zone map, not a
//  reverse-engineer of it. Tune zones / fill % / colors to taste.
// ════════════════════════════════════════════════════════════════════════
indicator("Reference Zones [Replica] — IRZ/MTJ style", "RefZones",
     overlay = true, max_lines_count = 500, max_labels_count = 100)

// ───────────────────────── Inputs ─────────────────────────
gR = "Range / Anchor"
anchorTF    = input.timeframe("D", "Anchor timeframe", group = gR,
     tooltip = "Zones recalculate when this timeframe rolls over (e.g. each new day).")
modeStr     = input.string("Previous period", "Range source",
     options = ["Previous period", "Current (developing)"], group = gR,
     tooltip = "Previous period: today's zones use the prior period high/low (static for the day). Developing: zones grow with the current period live.")
keepPeriods = input.int(3, "History (periods kept)", minval = 1, maxval = 20, group = gR)

gZ = "Zones"
zoneCount  = input.int(6, "Zones (range divisions)",            minval = 3, maxval = 12, group = gZ)
redZones   = input.int(1, "Premium zones from top (red)",       minval = 0, maxval = 6,  group = gZ)
greenZones = input.int(1, "Discount zones from bottom (green)", minval = 0, maxval = 6,  group = gZ)

gS = "Style"
linesPerZone = input.int(6, "Dotted lines per zone", minval = 2, maxval = 16, group = gS,
     tooltip = "Band density. Keep zones × lines × history under ~480 total drawings.")
fillPct      = input.float(70, "Band fill % of zone", minval = 20, maxval = 100, step = 5, group = gS,
     tooltip = "Lower = bigger gaps between bands (closer to the reference image).")
styleStr     = input.string("Dotted", "Line style", options = ["Dotted", "Dashed", "Solid"], group = gS)
lineWidth    = input.int(1, "Line width", minval = 1, maxval = 3, group = gS)
extendRight  = input.bool(false, "Project live zones into the future (extend right)", group = gS)
showEdges    = input.bool(true, "Price labels at zone edges", group = gS)

gC = "Colors"
premiumCol  = input.color(#ef5350, "Premium (top)",    group = gC)
valueCol    = input.color(#42a5f5, "Value (middle)",   group = gC)
discountCol = input.color(#26a69a, "Discount (bottom)",group = gC)
bandTransp  = input.int(0, "Line transparency", minval = 0, maxval = 90, group = gC)

// ───────────────────────── Derived ─────────────────────────
lstyle   = styleStr == "Dotted" ? line.style_dotted : styleStr == "Dashed" ? line.style_dashed : line.style_solid
perSet   = zoneCount * linesPerZone
effKeep  = math.max(1, math.min(keepPeriods, int(math.floor(480.0 / perSet))))
pcol     = color.new(premiumCol,  bandTransp)
vcol     = color.new(valueCol,    bandTransp)
dcol     = color.new(discountCol, bandTransp)
effGreen = math.min(greenZones, zoneCount)
effRed   = math.min(redZones,   zoneCount - effGreen)

// ───────────────────────── State ─────────────────────────
var array<line>  liveLn  = array.new<line>()
var array<line>  histLn  = array.new<line>()
var array<int>   histPid = array.new<int>()
var array<label> edgeLb  = array.new<label>()
var float prevH  = na
var float prevL  = na
var float runH   = na
var float runL   = na
var int   pid    = 0
var int   pStart = 0

// ───────────────────────── Helpers ─────────────────────────
zcol(int z) =>
    z < effGreen ? dcol : z >= zoneCount - effRed ? pcol : vcol

fillZones(array<line> dest, float hi, float lo, int xL, int xR, bool ext) =>
    if not na(hi) and not na(lo) and hi > lo
        rng = hi - lo
        zh  = rng / zoneCount
        pad = zh * (1.0 - fillPct / 100.0) / 2.0
        for z = 0 to zoneCount - 1
            zLo = lo + z * zh + pad
            zHi = lo + (z + 1) * zh - pad
            col = zcol(z)
            denom = linesPerZone > 1 ? linesPerZone - 1 : 1
            for i = 0 to linesPerZone - 1
                py = linesPerZone > 1 ? zLo + (zHi - zLo) * i / denom : (zLo + zHi) / 2.0
                array.push(dest, line.new(xL, py, xR, py, xloc = xloc.bar_index,
                     color = col, style = lstyle, width = lineWidth,
                     extend = ext ? extend.right : extend.none))

clearLines(array<line> a) =>
    if array.size(a) > 0
        for i = 0 to array.size(a) - 1
            line.delete(array.get(a, i))
        array.clear(a)

clearLabels(array<label> a) =>
    if array.size(a) > 0
        for i = 0 to array.size(a) - 1
            label.delete(array.get(a, i))
        array.clear(a)

buildEdges(float hi, float lo, int x) =>
    clearLabels(edgeLb)
    if showEdges and not na(hi) and not na(lo) and hi > lo
        rng = hi - lo
        for z = 0 to zoneCount
            py  = lo + z * rng / zoneCount
            col = z == zoneCount ? pcol : z == 0 ? dcol : vcol
            array.push(edgeLb, label.new(x, py, str.tostring(py, format.mintick),
                 xloc = xloc.bar_index, style = label.style_label_left,
                 color = color.new(col, 82), textcolor = col, size = size.small))

// ───────────────────────── Period engine ─────────────────────────
t     = time(anchorTF)
isNew = na(t[1]) ? false : t != t[1]

if barstate.isfirst
    pStart := bar_index
    runH   := high
    runL   := low

if isNew
    prevH := runH
    prevL := runL
    // finalize the just-completed live set -> history
    if array.size(liveLn) > 0
        for i = 0 to array.size(liveLn) - 1
            ln = array.get(liveLn, i)
            line.set_extend(ln, extend.none)
            line.set_x2(ln, bar_index)
            array.push(histLn, ln)
            array.push(histPid, pid)
        array.clear(liveLn)
    pid    += 1
    pStart := bar_index
    runH   := high
    runL   := low
    // prune history beyond effKeep periods
    keepFrom = pid - effKeep + 1
    while array.size(histPid) > 0 and array.get(histPid, 0) < keepFrom
        line.delete(array.shift(histLn))
        array.shift(histPid)
else
    runH := math.max(nz(runH, high), high)
    runL := math.min(nz(runL, low), low)

// ───────────────────────── Draw / update live ─────────────────────────
isPrev = modeStr == "Previous period"

if isPrev
    if isNew and not na(prevH) and not na(prevL)
        clearLines(liveLn)
        fillZones(liveLn, prevH, prevL, pStart, bar_index, extendRight)
        buildEdges(prevH, prevL, bar_index)
    // keep static zones reaching the current bar, and edges riding the edge
    if not isNew and not extendRight and array.size(liveLn) > 0
        for i = 0 to array.size(liveLn) - 1
            line.set_x2(array.get(liveLn, i), bar_index)
    if showEdges and array.size(edgeLb) > 0
        for i = 0 to array.size(edgeLb) - 1
            label.set_x(array.get(edgeLb, i), bar_index)
else
    // developing: rebuild the live set every bar from period start to now
    clearLines(liveLn)
    fillZones(liveLn, runH, runL, pStart, bar_index, extendRight)
    buildEdges(runH, runL, bar_index)
````
