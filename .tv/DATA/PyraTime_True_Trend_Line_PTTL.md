<!-- tradingview-pine-id: PUB;0e13ba9111004fd393c06eeb80529f50 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# PyraTime True Trend Line (PTTL)

Source: https://www.tradingview.com/script/YWx1Txi5-PyraTime-True-Trend-Line-PTTL/

## Description

PTTL builds a dynamic, vector-based geometric framework utilizing two extreme market pivots (A and B) and projects their mathematical structure forward in price and time. Because it processes its own internal OHLCV data array, it bypasses native TradingView history constraints, allowing historical vectors to act on live price action without breaking down.

Why This Works
Standard trend lines are notoriously subjective, often skewed by the user pulling lines to fit a narrative. PTTL removes user bias by hard-locking purely to mathematical extremes.

Furthermore, instead of relying on a generalized Volume Profile across the entire screen, PTTL isolates its Vector POC strictly within the A-B impulse leg. This explicitly traps the liquidity nodes associated only with the trend currently being analyzed, rather than mixing it with unrelated historical chop.

How This Works
The Core Buffer: The indicator continuously records high, low, close, and volume data into a 5,000-bar rolling array. This isolates the calculations from TradingView's visual history and prevents data from dropping out when zooming or scrolling.

Dynamic Geometry: In Auto mode, PTTL perpetually hunts for the most significant A and B pivots. Because this window is dynamic, historical structure migrates as stronger dominant highs/lows appear.

Harmonic Divisions: By treating the maximum price deviation from the true A-B line as a 100% boundary, the tool mathematically slices the resulting channel into exact geometric fractions (1/8, 1/3, 1/2, etc.) to highlight internal support/resistance nodes.

Time & Price Squaring (AB=CD): PTTL measures the span of the A-B impulse and demands that the Point C retracement validates within a strict time window. Once validated, it targets an identical price/time expansion (Target D), actively grading the setup as Pending, Success, or Failed based on real-time price intersection.

Settings Guide
Mode Selection: Choose between Auto (dynamically scanning) and Manual (locking Point A to a user-defined timestamp).

Manual — One-Click Anchor: Anchor Point A to a specific timestamp and price. Pivot B Search Window dictates how many bars forward the tool should scan before permanently locking Point B into place.

Auto Mode Settings: Adjust the Scan Window to define how many bars back the tool searches for major swings, and set a Minimum AB Span to ensure it doesn't anchor to microscopic, noisy swings.

Features & Visibility: Toggle overlays like the True Trend Line, Vector POC, Parallel Channel, and Reflection angle.

AB=CD Settings: Configure the time allowance for Point C to form. If Hide Failed Patterns is on, invalidated geometries clear immediately to keep the chart clean.

Projection Settings: Decide whether Time Cycles scale against the duration of the A-B leg (× AB duration) or project forward uniformly (Fixed bars).

Alert Triggers: Fire native TradingView alerts the moment price crosses the True Trend Line, the maximum-deviation Channel rail, or the isolated Vector POC.

---

## Source Code

````pine
//@version=6
// -----------------------------------------------------------------------------
// PyraTime True Trend Line (PTTL) — v1.0
// -----------------------------------------------------------------------------
// Market-geometry toolkit utilizing an internal OHLCV buffer to bypass native 
// history limits. Features include:
//   • True Trend Line (TTL) between two extreme pivots (Manual/Auto)
//   • Parallel channel anchored to maximum deviation, with harmonic divisions
//   • Vector POC — volume profile isolated specifically to the A-B leg
//   • AB=CD measured move with SUCCESS / FAILED resolution
//   • Time-cycle projections (wall-clock or bar-count basis)
//   • Reflection angle on confirmed TTL breaks
// -----------------------------------------------------------------------------

indicator("PyraTime True Trend Line (PTTL)", shorttitle = "PTTL", overlay = true, max_lines_count = 500, max_labels_count = 50, max_boxes_count = 10)

MAXFWD  = 500   // TradingView caps bar_index drawings at 500 bars ahead
MAXBUF  = 5001  // Internal buffer depth
NUMBINS = 24    // Volume profile resolution

// --- Internal memory arrays (bypasses the TV history buffer) ---
var float[] a_high  = array.new<float>()
var float[] a_low   = array.new<float>()
var float[] a_close = array.new<float>()
var float[] a_vol   = array.new<float>()
var float[] a_atr   = array.new<float>()
var int[]   a_time  = array.new<int>()
var int[]   a_bar   = array.new<int>()

float currentAtr = nz(ta.atr(14), 0.0)

// Arrays are reference types and do not roll back on realtime ticks.
// We push once per bar and overwrite the tail on realtime updates.
if barstate.isnew or array.size(a_bar) == 0
    array.push(a_high,  high)
    array.push(a_low,   low)
    array.push(a_close, close)
    array.push(a_vol,   nz(volume, 0))
    array.push(a_atr,   currentAtr)
    array.push(a_time,  time)
    array.push(a_bar,   bar_index)

    if array.size(a_bar) > MAXBUF
        array.shift(a_high)
        array.shift(a_low)
        array.shift(a_close)
        array.shift(a_vol)
        array.shift(a_atr)
        array.shift(a_time)
        array.shift(a_bar)
else
    li = array.size(a_bar) - 1
    array.set(a_high,  li, high)
    array.set(a_low,   li, low)
    array.set(a_close, li, close)
    array.set(a_vol,   li, nz(volume, 0))
    array.set(a_atr,   li, currentAtr)
    array.set(a_time,  li, time)
    array.set(a_bar,   li, bar_index)

// Scan boundary excludes the forming bar until confirmed. 
int stableIndex = barstate.isconfirmed ? bar_index : math.max(0, bar_index - 1)

// --- Inputs ---
grpMode = "Pivot Selection"
pivotMode = input.string("Auto", "Selection Mode", options = ["Manual", "Auto"], group = grpMode, tooltip = "Auto scans a rolling window for the dominant swing pair. Manual anchors Point A to a fixed date and time and locks permanently.")

grpManual = "Manual — One-Click Anchor"
anchorTime  = input.time(timestamp("2026-01-01 00:00 +0000"), "Anchor", group = grpManual, confirm = true, tooltip = "Date and time for Point A.")
anchorPrice = input.price(0.0, "Anchor Price", group = grpManual, confirm = true, tooltip = "Approximate price level. Script snaps to the exact high or low within the snap radius.")
snapRadius  = input.int(10, "Snap Radius (bars ±)", minval = 3, maxval = 100, group = grpManual)
bSearchBars = input.int(200, "Pivot B Search Window", minval = 20, maxval = 2000, group = grpManual, tooltip = "Max bars forward to search for Point B. Once elapsed, A and B are locked permanently.")

grpAuto = "Auto Mode Settings"
autoScanBars = input.int(300, "Scan Window (bars back)", minval = 50, maxval = 4990, group = grpAuto)
autoMinSpan  = input.int(10, "Minimum AB Span (bars)", minval = 2, maxval = 500, group = grpAuto, tooltip = "Minimum separation between A and B.")

grpFeat = "Features & Visibility"
showTTL        = input.bool(true,  "True Trend Line", group = grpFeat)
showChannel    = input.bool(true,  "Parallel Channel", group = grpFeat, tooltip = "Parallel rail placed at the maximum deviation of price from the A-B line.")
fillChannel    = input.bool(true,  "Fill Channel Background", group = grpFeat)
showHarmonics  = input.bool(true,  "Harmonic Divisions", group = grpFeat)
showPOC        = input.bool(true,  "Vector POC (Volume)", group = grpFeat, tooltip = "Highest-volume price node within the A-B leg.")
showABCD       = input.bool(true,  "AB=CD Measured Move", group = grpFeat)
showTimeProj   = input.bool(true,  "Time Cycle Projections", group = grpFeat)
showReflection = input.bool(true,  "Reflection Angle", group = grpFeat, tooltip = "Inverse-slope ray from the first confirmed close beyond the trend line.")
showDiagnostic = input.bool(true,  "Show HUD", group = grpFeat)

channelConvention = input.string("Auto (widest)", "Channel anchored to", options = ["Auto (widest)", "Upper rail", "Lower rail"], group = grpFeat)

grpABCD = "AB=CD Settings"
abcdCWindow    = input.float(2.0, "C window (× AB duration)", minval = 0.25, step = 0.25, group = grpABCD, tooltip = "Point C must form within this multiple of the A-B duration.")
abcdHideFailed = input.bool(false, "Hide failed patterns", group = grpABCD)

grpHarm = "Harmonic Divisions"
showH_1_8 = input.bool(false, "1/8",  group = grpHarm, inline = "row1")
showH_1_4 = input.bool(true,  "1/4",  group = grpHarm, inline = "row1")
showH_1_3 = input.bool(true,  "1/3",  group = grpHarm, inline = "row1")
showH_1_2 = input.bool(true,  "1/2",  group = grpHarm, inline = "row2")
showH_2_3 = input.bool(true,  "2/3",  group = grpHarm, inline = "row2")
showH_3_4 = input.bool(true,  "3/4",  group = grpHarm, inline = "row2")

grpProj = "Projection Settings"
projMode       = input.string("× AB duration", "Projection length", options = ["× AB duration", "Fixed bars"], group = grpProj)
projMult       = input.float(3.0, "Main lines (× AB duration)", minval = 0.25, step = 0.25, group = grpProj)
reflMult       = input.float(1.0, "Reflection (× AB duration)", minval = 0.25, step = 0.25, group = grpProj)
projectionBars = input.int(250, "Fixed length (bars)", minval = 1, maxval = 500, group = grpProj)
cycleBasis     = input.string("Time", "Time cycle basis", options = ["Time", "Bars"], group = grpProj)
timeProjCount  = input.int(4, "Time Cycle Count", minval = 1, maxval = 20, group = grpProj)

grpRefl = "Reflection Settings"
reflPen = input.float(0.5, "Minimum break (ATR)", minval = 0.0, step = 0.1, group = grpRefl)

grpAlerts = "Alert Triggers"
alertTTL     = input.bool(false, "Price crosses TTL", group = grpAlerts)
alertChannel = input.bool(false, "Price crosses Channel", group = grpAlerts)
alertPOC     = input.bool(false, "Price crosses Vector POC", group = grpAlerts)

grpStyle = "Aesthetics & Colors"
colTTL        = input.color(#F0B90D, "TTL", group = grpStyle, inline = "c1")
colChannel    = input.color(#00E6C3, "Channel", group = grpStyle, inline = "c1")
colPOC        = input.color(#E040FB, "Vector POC", group = grpStyle, inline = "c2")
colABCD       = input.color(#2962FF, "AB=CD", group = grpStyle, inline = "c2")
colABCDok     = input.color(#26A69A, "AB=CD Success", group = grpStyle, inline = "c3")
colABCDfail   = input.color(color.new(color.gray, 35), "AB=CD Failed", group = grpStyle, inline = "c3")
colTimeProj   = input.color(color.new(#00E6C3, 50), "Time Cycles", group = grpStyle, inline = "c4")
colReflection = input.color(#FF5252, "Reflection", group = grpStyle, inline = "c4")
colHarmonic   = input.color(color.new(color.gray, 60), "Harmonics", group = grpStyle, inline = "c5")
colFill       = input.color(color.new(#00E6C3, 93), "Channel Fill", group = grpStyle, inline = "c5")
colPivot      = input.color(color.white, "Pivot Labels", group = grpStyle)
ttlWidth      = input.int(1, "TTL Width", minval = 1, maxval = 5, group = grpStyle, inline = "w1")
auxWidth      = input.int(1, "Aux Width", minval = 1, maxval = 5, group = grpStyle, inline = "w1")

grpHUD = "HUD"
hudPos = input.string("Top right", "HUD position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = grpHUD)
hudTag = input.string("", "HUD tag (optional)", group = grpHUD)

// --- Anchor resolution (Manual) ---
var int  anchorBar        = na
var bool anchorPreHistory = false

if pivotMode == "Manual" and na(anchorBar) and time >= anchorTime
    if not na(time[1]) and time[1] < anchorTime
        anchorBar := bar_index
    else if barstate.isfirst
        anchorBar := bar_index
        anchorPreHistory := true

// --- Pivot & pattern state ---
var int    barA        = na
var float  prcA        = na
var int    barB        = na
var float  prcB        = na
var string pivotStatus = "Init"
var string abcdStatus  = "—"
var string lockStatus  = "—"

// AB=CD latch - held tightly to prevent repainting once formed
var int    abcdKeyA = na
var int    abcdKeyB = na
var int    barC     = na
var float  prcC     = na

// --- Core Engines ---
f_findExtreme(int fromBar, int toBar, bool wantHigh) =>
    float ext    = na
    int   extBar = na

    startIdx = array.size(a_bar) - 1 - (bar_index - fromBar)
    endIdx   = array.size(a_bar) - 1 - (bar_index - toBar)

    safeStart = math.max(0, math.min(startIdx, endIdx))
    safeEnd   = math.min(array.size(a_bar) - 1, math.max(startIdx, endIdx))

    if safeStart <= safeEnd and safeEnd >= 0
        ext := wantHigh ? -1e20 : 1e20
        for i = safeStart to safeEnd
            val = wantHigh ? array.get(a_high, i) : array.get(a_low, i)
            b   = array.get(a_bar, i)
            if (wantHigh and val > ext) or (not wantHigh and val < ext)
                ext    := val
                extBar := b
        if ext == -1e20 or ext == 1e20
            ext    := na
            extBar := na
    [ext, extBar]

var float[] bins = array.new<float>(NUMBINS, 0.0)

f_getPOC(int startBar, int endBar) =>
    float pocPrice  = na
    bool  fromVol   = false
    startIdx  = array.size(a_bar) - 1 - (bar_index - startBar)
    endIdx    = array.size(a_bar) - 1 - (bar_index - endBar)
    safeStart = math.max(0, math.min(startIdx, endIdx))
    safeEnd   = math.min(array.size(a_bar) - 1, math.max(startIdx, endIdx))

    if safeStart <= safeEnd and safeEnd >= 0
        float rHigh = -1e20
        float rLow  = 1e20
        for i = safeStart to safeEnd
            h = array.get(a_high, i)
            l = array.get(a_low, i)
            if h > rHigh
                rHigh := h
            if l < rLow
                rLow := l

        if rHigh <= -1e19 or rLow >= 1e19 or na(rHigh) or na(rLow)
            pocPrice := na
        else if rHigh - rLow <= 0
            pocPrice := (rHigh + rLow) / 2.0
        else
            float binSize = (rHigh - rLow) / NUMBINS
            array.fill(bins, 0.0)

            for i = safeStart to safeEnd
                typ = (array.get(a_high, i) + array.get(a_low, i) + array.get(a_close, i)) / 3.0
                vol = array.get(a_vol, i)
                int binIdx = math.floor((typ - rLow) / binSize)
                binIdx := math.max(0, math.min(NUMBINS - 1, binIdx))
                array.set(bins, binIdx, array.get(bins, binIdx) + vol)

            float maxVol = -1.0
            int   pocIdx = 0
            for i = 0 to NUMBINS - 1
                if array.get(bins, i) > maxVol
                    maxVol := array.get(bins, i)
                    pocIdx := i

            if maxVol <= 0
                pocPrice := (rHigh + rLow) / 2.0
            else
                pocPrice := rLow + (pocIdx * binSize) + (binSize / 2.0)
                fromVol  := true
    [pocPrice, fromVol]

f_barTime(int b) =>
    int t = na
    idx = array.size(a_bar) - 1 - (bar_index - b)
    if idx >= 0 and idx < array.size(a_time)
        t := array.get(a_time, idx)
    t

// --- Persistent Drawing Handles ---
var line     lnTTL        = na
var line     lnChannel    = na
var linefill lfChannel    = na
var line     lnPOC        = na
var line     lnReflection = na
var line     lnCD         = na
var box      boxD         = na
var label    lblA         = na
var label    lblB         = na
var label    lblC         = na
var label    lblD         = na
var label    lblSlope     = na
var line[]   lnHarmonics  = array.new<line>()
var line[]   lnTimeProj   = array.new<line>()

hudPosition = switch hudPos
    "Top left"     => position.top_left
    "Bottom right" => position.bottom_right
    "Bottom left"  => position.bottom_left
    => position.top_right

var table diagHUD = table.new(hudPosition, 2, 9, bgcolor = color.new(color.black, 40), border_color = color.new(color.gray, 90), border_width = 1, frame_color = color.new(color.gray, 90), frame_width = 1)

f_updateLine(line prev, int x1, float y1, int x2, float y2, color col, int w, string style, string ext) =>
    line out = prev
    if na(out)
        out := line.new(x1, y1, x2, y2, xloc = xloc.bar_index, extend = ext, color = col, width = w, style = style)
    else
        line.set_xy1(out, x1, y1)
        line.set_xy2(out, x2, y2)
        line.set_extend(out, ext)
        line.set_color(out, col)
        line.set_width(out, w)
        line.set_style(out, style)
    out

f_deleteLine(line prev) =>
    if not na(prev)
        line.delete(prev)
    line(na)

f_clearLineArray(line[] arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            line.delete(array.get(arr, i))
        array.clear(arr)

// --- Pivot Resolution ---
if barstate.islast
    if pivotMode == "Manual"
        lockStatus := "—"
        int oldestBar  = array.size(a_bar) > 0 ? array.get(a_bar, 0) : bar_index
        int rangeStart = math.max(anchorBar - snapRadius, 0)
        int rangeEnd   = math.min(anchorBar + snapRadius, stableIndex)

        if na(anchorBar)
            barA := na
            prcA := na
            barB := na
            prcB := na
            pivotStatus := "Anchor not resolved"
        else if anchorPreHistory
            barA := na
            prcA := na
            barB := na
            prcB := na
            pivotStatus := "Anchor precedes chart history"
        else if rangeStart < oldestBar
            barA := na
            prcA := na
            barB := na
            prcB := na
            pivotStatus := "Anchor outside memory buffer"
        else
            [hiPrice, hiBar] = f_findExtreme(rangeStart, rangeEnd, true)
            [loPrice, loBar] = f_findExtreme(rangeStart, rangeEnd, false)

            if na(hiBar) or na(loBar)
                barA := na
                prcA := na
                barB := na
                prcB := na
                pivotStatus := "Anchor extremes unavailable"
            else
                hiDistance = math.abs(hiPrice - anchorPrice)
                loDistance = math.abs(loPrice - anchorPrice)
                bool aIsHigh = hiDistance < loDistance
                barA := aIsHigh ? hiBar   : loBar
                prcA := aIsHigh ? hiPrice : loPrice
                searchEnd = math.min(barA + bSearchBars, stableIndex)

                int lockBar = barA + bSearchBars
                lockStatus := stableIndex >= lockBar ? "LOCKED" : "LIVE (" + str.tostring(lockBar - stableIndex) + " left)"

                if searchEnd > barA + 1
                    [oppPrice, oppBar] = f_findExtreme(barA + 1, searchEnd, not aIsHigh)
                    if not na(oppBar)
                        barB := oppBar
                        prcB := oppPrice
                        pivotStatus := "Manual OK (A=" + (aIsHigh ? "high" : "low") + ")"
                    else
                        barA := na
                        prcA := na
                        barB := na
                        prcB := na
                        pivotStatus := "Manual: opposite extreme unavailable"
                else
                    barA := na
                    prcA := na
                    barB := na
                    prcB := na
                    pivotStatus := "No bars after anchor"
    else
        lockStatus := "Rolling (Dynamic)"
        scanStart = math.max(0, stableIndex - autoScanBars)
        [autoHiPrice, autoHiBar] = f_findExtreme(scanStart, stableIndex, true)
        [autoLoPrice, autoLoBar] = f_findExtreme(scanStart, stableIndex, false)

        if na(autoHiBar) or na(autoLoBar)
            barA := na
            prcA := na
            barB := na
            prcB := na
            pivotStatus := "Auto: initial scan failed"
        else if math.abs(autoHiBar - autoLoBar) >= autoMinSpan
            if autoHiBar < autoLoBar
                barA := autoHiBar
                prcA := autoHiPrice
                barB := autoLoBar
                prcB := autoLoPrice
            else
                barA := autoLoBar
                prcA := autoLoPrice
                barB := autoHiBar
                prcB := autoHiPrice
            pivotStatus := "Auto OK"
        else
            bool  firstIsHigh = autoHiBar <= autoLoBar
            int   keepBar     = firstIsHigh ? autoHiBar   : autoLoBar
            float keepPrice   = firstIsHigh ? autoHiPrice : autoLoPrice
            int   altStart    = keepBar + autoMinSpan

            if altStart > stableIndex
                barA := na
                prcA := na
                barB := na
                prcB := na
                pivotStatus := "Auto: span recovery failed"
            else
                [altPrice, altBar] = f_findExtreme(altStart, stableIndex, not firstIsHigh)
                if na(altBar)
                    barA := na
                    prcA := na
                    barB := na
                    prcB := na
                    pivotStatus := "Auto: span recovery failed"
                else
                    barA := keepBar
                    prcA := keepPrice
                    barB := altBar
                    prcB := altPrice
                    pivotStatus := "Auto OK (alt span)"

pivotsReady = not na(barA) and not na(barB) and barA != barB
ttlSlope    = pivotsReady ? (prcB - prcA) / (barB - barA) : 0.0

float vectorPOC     = na
bool  pocFromVolume = false
if pivotsReady
    [pocVal, pocSrc] = f_getPOC(barA, barB)
    vectorPOC     := pocVal
    pocFromVolume := pocSrc

ttlY(int targetBar) =>
    prcA + ttlSlope * (targetBar - barA)

f_maxDeviation(int fromBar, int toBar, bool wantAbove) =>
    float bestOff = na
    startIdx  = array.size(a_bar) - 1 - (bar_index - fromBar)
    endIdx    = array.size(a_bar) - 1 - (bar_index - toBar)
    safeStart = math.max(0, math.min(startIdx, endIdx))
    safeEnd   = math.min(array.size(a_bar) - 1, math.max(startIdx, endIdx))
    if safeStart <= safeEnd and safeEnd >= 0
        for i = safeStart to safeEnd
            b   = array.get(a_bar, i)
            off = (wantAbove ? array.get(a_high, i) : array.get(a_low, i)) - ttlY(b)
            if na(bestOff) or (wantAbove ? off > bestOff : off < bestOff)
                bestOff := off
    bestOff

f_channelOffset(int fromBar, int toBar) =>
    float up     = nz(f_maxDeviation(fromBar, toBar, true),  0.0)
    float dn     = nz(f_maxDeviation(fromBar, toBar, false), 0.0)
    float widest = math.abs(up) >= math.abs(dn) ? up : dn
    float off = switch channelConvention
        "Upper rail" => up
        "Lower rail" => dn
        => widest
    math.abs(off) < syminfo.mintick ? widest : off

// --- Alerts ---
float lvlNow  = pivotsReady ? ttlY(bar_index)     : na
float lvlPrev = pivotsReady ? ttlY(bar_index - 1) : na

bool crossedTTL = not na(lvlNow) and not na(lvlPrev) and ((close > lvlNow and close[1] <= lvlPrev) or (close < lvlNow and close[1] >= lvlPrev))

float channelOffsetGlobal = 0.0
if pivotsReady
    channelOffsetGlobal := f_channelOffset(barA, barB)

float chanNow  = not na(lvlNow)  ? lvlNow  + channelOffsetGlobal : na
float chanPrev = not na(lvlPrev) ? lvlPrev + channelOffsetGlobal : na
bool crossedChan = not na(chanNow) and not na(chanPrev) and ((close > chanNow and close[1] <= chanPrev) or (close < chanNow and close[1] >= chanPrev))

bool crossedPOC = not na(vectorPOC) and ((close > vectorPOC and close[1] <= vectorPOC) or (close < vectorPOC and close[1] >= vectorPOC))

if barstate.isrealtime and pivotsReady
    if alertTTL and crossedTTL
        alert("PTTL: price crossed the True Trend Line", alert.freq_once_per_bar_close)
    if alertChannel and crossedChan
        alert("PTTL: price crossed the Parallel Channel", alert.freq_once_per_bar_close)
    if alertPOC and crossedPOC
        alert("PTTL: price crossed the Vector POC", alert.freq_once_per_bar_close)

// --- Rendering ---
if barstate.islast
    if pivotsReady
        int   abSpan     = barB - barA
        int   projLen    = projMode == "Fixed bars" ? projectionBars : math.max(1, math.round(abSpan * projMult))
        int   reflLen    = projMode == "Fixed bars" ? projectionBars : math.max(1, math.round(abSpan * reflMult))
        int   safeEndBar = math.min(barB + projLen, bar_index + MAXFWD)
        float ttlEndY    = ttlY(safeEndBar)

        // TTL
        if showTTL
            lnTTL := f_updateLine(lnTTL, barA, prcA, safeEndBar, ttlEndY, colTTL, ttlWidth, line.style_solid, extend.none)
        else
            lnTTL := f_deleteLine(lnTTL)

        // Vector POC
        if showPOC and not na(vectorPOC)
            lnPOC := f_updateLine(lnPOC, barA, vectorPOC, safeEndBar, vectorPOC, colPOC, 2, line.style_solid, extend.right)
        else
            lnPOC := f_deleteLine(lnPOC)

        // Parallel Channel
        float channelOffset = channelOffsetGlobal

        if showChannel
            lnChannel := f_updateLine(lnChannel, barA, prcA + channelOffset, safeEndBar, ttlEndY + channelOffset, colChannel, auxWidth, line.style_solid, extend.none)
            if fillChannel and showTTL and not na(lnTTL) and not na(lnChannel)
                if na(lfChannel)
                    lfChannel := linefill.new(lnTTL, lnChannel, color = colFill)
                else
                    linefill.set_color(lfChannel, colFill)
            else if not na(lfChannel)
                linefill.delete(lfChannel)
                lfChannel := na
        else
            lnChannel := f_deleteLine(lnChannel)
            if not na(lfChannel)
                linefill.delete(lfChannel)
                lfChannel := na

        // AB=CD
        if showABCD and stableIndex > barB
            bool wantHighC = ttlSlope < 0 

            if na(abcdKeyA) or na(abcdKeyB) or abcdKeyA != barA or abcdKeyB != barB
                abcdKeyA := barA
                abcdKeyB := barB
                barC     := na
                prcC     := na

            int cWindowEnd = barB + math.max(1, math.round(abSpan * abcdCWindow))
            int cSearchEnd = math.min(cWindowEnd, stableIndex)

            if cSearchEnd > barB
                [extC, extBarC] = f_findExtreme(barB + 1, cSearchEnd, wantHighC)
                if not na(extBarC)
                    bool candidateValid = wantHighC ? (extC > prcB and extC < prcA) : (extC < prcB and extC > prcA)
                    if candidateValid
                        if na(barC) or (wantHighC ? extC > prcC : extC < prcC)
                            barC := extBarC
                            prcC := extC

            if not na(barC)
                float deltaP    = prcB - prcA
                float prcD      = prcC + deltaP
                int   barD      = barC + abSpan
                int   boxHWidth = math.max(1, math.round(abSpan * 0.05))

                string outcome = "Pending"
                if stableIndex > barC
                    for i = 1 to math.min(stableIndex - barC, MAXBUF - 1)
                        b   = barC + i
                        idx = array.size(a_bar) - 1 - (bar_index - b)
                        if idx >= 0 and idx < array.size(a_bar)
                            h = array.get(a_high, idx)
                            l = array.get(a_low, idx)
                            if (wantHighC ? l <= prcD : h >= prcD)
                                outcome := "Success"
                                break
                            if (wantHighC ? h >= prcA : l <= prcA)
                                outcome := "Failed"
                                break

                color  colCD = outcome == "Failed" ? colABCDfail : outcome == "Success" ? colABCDok : colABCD
                string txtD  = outcome == "Failed" ? "D — FAILED" : outcome == "Success" ? "D — SUCCESS" : "Target D"

                if outcome == "Failed" and abcdHideFailed
                    abcdStatus := "Failed (hidden)"
                    lnCD := f_deleteLine(lnCD)
                    box.delete(boxD)
                    boxD := na
                    label.delete(lblC)
                    lblC := na
                    label.delete(lblD)
                    lblD := na
                else if barD + boxHWidth <= bar_index + MAXFWD
                    abcdStatus := outcome == "Pending" ? "Active" : outcome
                    lnCD := f_updateLine(lnCD, barC, prcC, barD, prcD, colCD, auxWidth, line.style_dashed, extend.none)

                    if na(lblC)
                        lblC := label.new(barC, prcC, "C", xloc = xloc.bar_index, style = wantHighC ? label.style_label_up : label.style_label_down, color = color.new(color.black, 20), textcolor = colPivot, size = size.small)
                    else
                        label.set_xy(lblC, barC, prcC)
                        label.set_style(lblC, wantHighC ? label.style_label_up : label.style_label_down)
                    label.set_textcolor(lblC, outcome == "Failed" ? colABCDfail : colPivot)

                    float boxHHeight = math.max(math.abs(deltaP * 0.02), syminfo.mintick * 4)

                    if na(boxD)
                        boxD := box.new(barD - boxHWidth, prcD + boxHHeight, barD + boxHWidth, prcD - boxHHeight, border_color = colCD, bgcolor = color.new(colCD, 80))
                    else
                        box.set_lefttop(boxD, barD - boxHWidth, prcD + boxHHeight)
                        box.set_rightbottom(boxD, barD + boxHWidth, prcD - boxHHeight)
                        box.set_border_color(boxD, colCD)
                        box.set_bgcolor(boxD, color.new(colCD, 80))

                    if na(lblD)
                        lblD := label.new(barD, prcD, txtD, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 90), textcolor = colCD, size = size.small)
                    else
                        label.set_xy(lblD, barD, prcD)
                        label.set_text(lblD, txtD)
                        label.set_textcolor(lblD, colCD)
                else
                    abcdStatus := "D beyond draw horizon"
                    lnCD := f_deleteLine(lnCD)
                    box.delete(boxD)
                    boxD := na
                    label.delete(lblC)
                    lblC := na
                    label.delete(lblD)
                    lblD := na
            else
                abcdStatus := stableIndex >= cWindowEnd ? "Expired (no C)" : "Waiting for C"
                lnCD := f_deleteLine(lnCD)
                box.delete(boxD)
                boxD := na
                label.delete(lblC)
                lblC := na
                label.delete(lblD)
                lblD := na
        else
            abcdStatus := showABCD ? "Waiting for C" : "—"
            lnCD := f_deleteLine(lnCD)
            box.delete(boxD)
            boxD := na
            label.delete(lblC)
            lblC := na
            label.delete(lblD)
            lblD := na

        // Harmonics
        f_clearLineArray(lnHarmonics)
        if showHarmonics
            fractions = array.new<float>()
            if showH_1_8
                array.push(fractions, 1.0/8.0)
            if showH_1_4
                array.push(fractions, 1.0/4.0)
            if showH_1_3
                array.push(fractions, 1.0/3.0)
            if showH_1_2
                array.push(fractions, 1.0/2.0)
            if showH_2_3
                array.push(fractions, 2.0/3.0)
            if showH_3_4
                array.push(fractions, 3.0/4.0)
            if array.size(fractions) > 0
                for i = 0 to array.size(fractions) - 1
                    f   = array.get(fractions, i)
                    off = channelOffset * f
                    array.push(lnHarmonics, line.new(barA, prcA + off, safeEndBar, ttlEndY + off, xloc = xloc.bar_index, color = colHarmonic, width = auxWidth, style = line.style_dashed))

        // Time Cycle Projections
        f_clearLineArray(lnTimeProj)
        if showTimeProj
            if cycleBasis == "Bars"
                for n = 1 to timeProjCount
                    int xBar = barB + n * abSpan
                    if xBar <= bar_index + MAXFWD
                        array.push(lnTimeProj, line.new(xBar, prcA, xBar, prcA + 1, xloc = xloc.bar_index, extend = extend.both, color = colTimeProj, width = auxWidth, style = line.style_dotted))
            else
                int tA = f_barTime(barA)
                int tB = f_barTime(barB)
                if not na(tA) and not na(tB) and tB > tA
                    int tSpan   = tB - tA
                    int horizon = time + MAXFWD * timeframe.in_seconds() * 1000
                    for n = 1 to timeProjCount
                        int xt = tB + n * tSpan
                        if xt <= horizon
                            array.push(lnTimeProj, line.new(xt, prcA, xt, prcA + 1, xloc = xloc.bar_time, extend = extend.both, color = colTimeProj, width = auxWidth, style = line.style_dotted))

        // Reflection Angle
        if showReflection
            int   breakBar   = na
            float breakPrice = na
            bool  bullishTTL = ttlSlope > 0
            if stableIndex > barB
                maxWalk = math.min(stableIndex - barB, MAXBUF - 1)
                for i = 1 to maxWalk
                    b = barB + i
                    idx = array.size(a_bar) - 1 - (bar_index - b)
                    if idx >= 0 and idx < array.size(a_bar)
                        tY_here  = ttlY(b)
                        c_here   = array.get(a_close, idx)
                        atr_here = array.get(a_atr, idx)
                        pen      = atr_here * reflPen

                        brokeBullish = bullishTTL and c_here < (tY_here - pen)
                        brokeBearish = not bullishTTL and c_here > (tY_here + pen)
                        if brokeBullish or brokeBearish
                            breakBar   := b
                            breakPrice := c_here
                            break

            if not na(breakBar)
                int   safeReflEnd = math.min(breakBar + reflLen, bar_index + MAXFWD)
                float reflEndY    = breakPrice + (-ttlSlope) * (safeReflEnd - breakBar)
                lnReflection := f_updateLine(lnReflection, breakBar, breakPrice, safeReflEnd, reflEndY, colReflection, ttlWidth, line.style_solid, extend.none)
            else
                lnReflection := f_deleteLine(lnReflection)
        else
            lnReflection := f_deleteLine(lnReflection)

        // Pivot Labels
        slopeTxt = "Slope: " + str.tostring(ttlSlope, format.mintick) + " /bar"
        if na(lblA)
            lblA := label.new(barA, prcA, "A", xloc = xloc.bar_index, style = label.style_label_up, color = color.new(color.black, 20), textcolor = colPivot, size = size.small)
        else
            label.set_xy(lblA, barA, prcA)
        if na(lblB)
            lblB := label.new(barB, prcB, "B", xloc = xloc.bar_index, style = label.style_label_down, color = color.new(color.black, 20), textcolor = colPivot, size = size.small)
        else
            label.set_xy(lblB, barB, prcB)
        int slopeX = math.min(barB + 5, bar_index + MAXFWD)
        if na(lblSlope)
            lblSlope := label.new(slopeX, prcB, slopeTxt, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 40), textcolor = colTTL, size = size.small)
        else
            label.set_xy(lblSlope, slopeX, prcB)
            label.set_text(lblSlope, slopeTxt)

    else
        abcdStatus := "—"
        barC := na
        prcC := na
        lnTTL        := f_deleteLine(lnTTL)
        lnChannel    := f_deleteLine(lnChannel)
        lnPOC        := f_deleteLine(lnPOC)
        lnReflection := f_deleteLine(lnReflection)
        lnCD         := f_deleteLine(lnCD)
        if not na(lfChannel)
            linefill.delete(lfChannel)
            lfChannel := na
        f_clearLineArray(lnHarmonics)
        f_clearLineArray(lnTimeProj)
        label.delete(lblA)
        lblA := na
        label.delete(lblB)
        lblB := na
        label.delete(lblC)
        lblC := na
        label.delete(lblD)
        lblD := na
        label.delete(lblSlope)
        lblSlope := na
        box.delete(boxD)
        boxD := na

// --- HUD Interface ---
if barstate.islast
    if showDiagnostic
        headTxt = hudTag

        table.cell(diagHUD, 0, 0, "PTTL", text_color = color.white, text_halign = text.align_left, text_size = size.small, bgcolor = color.new(color.black, 20))
        table.cell(diagHUD, 1, 0, headTxt, text_color = colTTL, text_halign = text.align_right, text_size = size.small, bgcolor = color.new(color.black, 20))

        table.cell(diagHUD, 0, 1, "Mode", text_color = color.gray, text_halign = text.align_left, text_size = size.small)
        table.cell(diagHUD, 1, 1, pivotMode, text_color = color.white, text_halign = text.align_right, text_size = size.small)

        table.cell(diagHUD, 0, 2, "Pivot State", text_color = color.gray, text_halign = text.align_left, text_size = size.small)
        table.cell(diagHUD, 1, 2, lockStatus, text_color = lockStatus == "LOCKED" ? color.lime : color.orange, text_halign = text.align_right, text_size = size.small)

        table.cell(diagHUD, 0, 3, "Status", text_color = color.gray, text_halign = text.align_left, text_size = size.small)
        table.cell(diagHUD, 1, 3, pivotStatus, text_color = color.white, text_halign = text.align_right, text_size = size.small)

        strA = na(barA) ? "—" : str.tostring(barA) + " @ " + str.tostring(prcA, format.mintick)
        table.cell(diagHUD, 0, 4, "Point A", text_color = color.gray, text_halign = text.align_left, text_size = size.small)
        table.cell(diagHUD, 1, 4, strA, text_color = color.white, text_halign = text.align_right, text_size = size.small)

        strB = na(barB) ? "—" : str.tostring(barB) + " @ " + str.tostring(prcB, format.mintick)
        table.cell(diagHUD, 0, 5, "Point B", text_color = color.gray, text_halign = text.align_left, text_size = size.small)
        table.cell(diagHUD, 1, 5, strB, text_color = color.white, text_halign = text.align_right, text_size = size.small)

        strSlope = pivotsReady ? str.tostring(ttlSlope, format.mintick) : "—"
        table.cell(diagHUD, 0, 6, "Slope / bar", text_color = color.gray, text_halign = text.align_left, text_size = size.small)
        table.cell(diagHUD, 1, 6, strSlope, text_color = colChannel, text_halign = text.align_right, text_size = size.small)

        pocLabel = pocFromVolume ? "Vector POC" : "Vector POC (mid)"
        strPOC   = na(vectorPOC) ? "—" : str.tostring(vectorPOC, format.mintick)
        table.cell(diagHUD, 0, 7, pocLabel, text_color = color.gray, text_halign = text.align_left, text_size = size.small)
        table.cell(diagHUD, 1, 7, strPOC, text_color = pocFromVolume ? colPOC : color.gray, text_halign = text.align_right, text_size = size.small)

        colAbcdStat = abcdStatus == "Success" ? colABCDok : abcdStatus == "Failed" ? color.gray : abcdStatus == "Active" ? colABCD : color.white
        table.cell(diagHUD, 0, 8, "AB=CD", text_color = color.gray, text_halign = text.align_left, text_size = size.small)
        table.cell(diagHUD, 1, 8, abcdStatus, text_color = colAbcdStat, text_halign = text.align_right, text_size = size.small)
    else
        table.clear(diagHUD, 0, 0, 1, 8)
````
