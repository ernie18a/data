# Pythagorean Time Price Geometry  Ver 1.0

- url: https://www.tradingview.com/script/beNtBrn6-Pythagorean-Time-Price-Geometry-Ver-1-0/
- type: indicator
- pine_id: PUB;fa0e5f6880e94a75ba36a8345dbc8d66
- version: 1.0

## Description

Pythagorean Time Price Geometry — Ver 1.0
By Timepricedecoder

Overview
This indicator applies W.D. Gann's Time = Price principle using Pythagorean geometry to project natural time cycles and price grid levels directly on the chart.
Gann believed that financial markets move in geometric harmony — that price and time are not independent variables, but two sides of the same equation. When they balance, the market reaches a natural turning point.
This script operationalises that idea using the Pythagorean theorem — the ancient mathematical relationship where in a right-angled triangle, the square of the hypotenuse equals the sum of squares of the other two sides (a² + b² = c²). In market terms:

Side A (time) — the number of bars in the anchor swing
Side B (price) — the range of the anchor swing (High − Low)
Side C (hypotenuse) — the natural cycle projection derived from both

By selecting a Pythagorean Triple (sets of whole numbers satisfying a² + b² = c², such as 3-4-5, 5-12-13, 8-15-17), the script scales the time-price relationship into a precise geometric ratio. This ratio then defines the grid cell size, the cycle length, and the angle of the diagonal — all derived from a single anchor swing.
The result is a self-organising grid that maps where price should find support or resistance, and when time cycles are due to complete — giving the trader a structured, geometry-based framework rather than arbitrary indicator levels.
When time and price arrive at the same Pythagorean node simultaneously — the market is squaring — and that is where the highest-probability signals are generated.

Core Concepts
Time = Price Squaring
Price range and time duration are treated as the two legs of a right triangle. When they balance — the market is at a Square — reversals or accelerations are most likely.
Pythagorean Nodes
From the anchor swing (High → Low or Low → High), the script calculates:

Sq — Square of the swing (time leg = price leg). Highest grade signal
Hyp — Hypotenuse projection. Major cycle marker
½Hyp — Half Hypotenuse. Minor cycle node
½Sq — Early warning zone

These project forward as repeating time cycles across the chart.
Harmonic Grid
Price is divided into cells derived from the Pythagorean triple ratio (B/A × Range). The grid repeats both in time (columns) and price (rows), creating a natural map of support, resistance, and time confluence.
Signal Tiers

🟨 BUY/SELL-Sq — Time node + Price grid level align. Strongest signal
🟩 BUY/SELL-T — Time node only. Moderate signal
⬜ BUY/SELL-P — Price grid level only. Weakest, disabled by default

Confluence Zones ⚡

⚡ — Quarter cycle node
⚡⚡ — Half cycle node
⚡⚡⚡ — Full cycle node (highest confluence)


Recommended Settings
StyleGann NumberDivisorTripleSwing WidthScalping221/44-3-5NarrowShort Term441/24-3-5NormalMedium Term881/23-4-5NormalLong Term176Full3-4-5Wide
InstrumentType SettingNotesOptionsOptionsGrid origin auto-adjustedIndicesIndicesUse 88, 1/2 divisorStocksStocksUse Adaptive stabilityFuturesFuturesUse 44 or 88
Grid Stability

Strict — Anchors rarely shift. Best for trending markets
Adaptive — Default. Balances stability and responsiveness
Relaxed — Reanchors more freely. Best for ranging markets


How To Use

Let the script auto-detect the swing anchor (or set manually)
Watch for Sq labels on vertical cycle lines — these are key dates
Enter on BUY-Sq / SELL-Sq signals with candle confirmation
Use ⚡⚡⚡ confluence zones as high-alert turning point windows
The active zone box shows current grid cell position (Upper = bullish bias, Lower = bearish bias)


Disclaimer

This script is published for educational purposes only. It does not constitute financial advice. Past signal accuracy does not guarantee future results. The swing detection uses Daily OHLC data with lookahead enabled — results may differ slightly on live bars versus historical bars. Always use proper risk management. Trade at your own risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Timepricedecoder — Ver 1.0 — Pythagorean Time Price Geometry
//@version=6
indicator("Pythagorean Time Price Geometry — Ver 1.0", overlay=true,
     max_lines_count=500, max_boxes_count=500, max_labels_count=500, max_bars_back=2000)

// ══════════════════════════════════════════════════════════════════════════════
// ① INSTRUMENT
// ══════════════════════════════════════════════════════════════════════════════
instrType = input.string("Options", "Instrument Type",
     options=["Options","Indices","Stocks","Futures"],
     group="① Instrument")

// ══════════════════════════════════════════════════════════════════════════════
// ② STRUCTURE
// ══════════════════════════════════════════════════════════════════════════════
gannNumber      = input.int(88, "Gann Number (Base Period)",
     options=[11,22,44,88,176], group="② Structure")
periodDivisor   = input.string("1/2", "Period Divisor",
     options=["Full","1/2","3/4","1/4"], group="② Structure")
minSwingATRMult = input.float(1.5, "Min Swing (ATR ×)",
     minval=0.5, maxval=5.0, step=0.25, group="② Structure")
tfScalar        = input.float(1.0, "Square Scale",
     minval=0.1, maxval=3.0, step=0.1, group="② Structure")
gridStability   = input.string("Adaptive", "Grid Stability",
     options=["Adaptive","Strict","Relaxed"], group="② Structure")
swingWidth      = input.string("Normal  1/8", "Swing Search Width",
     options=["Narrow  1/16","Normal  1/8","Wide    1/4","Widest  1/2"],
     group="② Structure")

// ══════════════════════════════════════════════════════════════════════════════
// ③ MANUAL ANCHOR
// ══════════════════════════════════════════════════════════════════════════════
anchorMode     = input.string("Auto", "Anchor Mode",
     options=["Auto","Manual"], group="③ Manual Anchor")
anchorHighBack = input.int(0, "High — bars back", minval=0, maxval=500, group="③ Manual Anchor")
anchorLowBack  = input.int(0, "Low  — bars back", minval=0, maxval=500, group="③ Manual Anchor")

// ══════════════════════════════════════════════════════════════════════════════
// ④ PYTHAGOREAN TRIPLE
// ══════════════════════════════════════════════════════════════════════════════
pythTripleStr = input.string("4-3-5   (36.9°)", "Pythagorean Triple",
     options=["24-7-25 (16.3°)","12-5-13 (22.6°)","15-8-17 (28.1°)",
              "4-3-5   (36.9°)","1-1-Sq2 (45.0°)","3-4-5   (53.1°)",
              "8-15-17 (61.9°)","5-12-13 (67.4°)","7-24-25 (73.7°)"],
     group="④ Pythagorean Triple")

ptA = pythTripleStr == "3-4-5   (53.1°)" ? 3.0  :
      pythTripleStr == "4-3-5   (36.9°)" ? 4.0  :
      pythTripleStr == "5-12-13 (67.4°)" ? 5.0  :
      pythTripleStr == "12-5-13 (22.6°)" ? 12.0 :
      pythTripleStr == "8-15-17 (61.9°)" ? 8.0  :
      pythTripleStr == "15-8-17 (28.1°)" ? 15.0 :
      pythTripleStr == "7-24-25 (73.7°)" ? 7.0  :
      pythTripleStr == "24-7-25 (16.3°)" ? 24.0 : 1.0

ptB = pythTripleStr == "3-4-5   (53.1°)" ? 4.0  :
      pythTripleStr == "4-3-5   (36.9°)" ? 3.0  :
      pythTripleStr == "5-12-13 (67.4°)" ? 12.0 :
      pythTripleStr == "12-5-13 (22.6°)" ? 5.0  :
      pythTripleStr == "8-15-17 (61.9°)" ? 15.0 :
      pythTripleStr == "15-8-17 (28.1°)" ? 8.0  :
      pythTripleStr == "7-24-25 (73.7°)" ? 24.0 :
      pythTripleStr == "24-7-25 (16.3°)" ? 7.0  : 1.0

// ══════════════════════════════════════════════════════════════════════════════
// ⑤ HARMONIC GRIDS
// ══════════════════════════════════════════════════════════════════════════════
showGrid1x  = input.bool(false,  "Show 1× Base Grid",     group="⑤ Harmonic Grids")
showGrid2x  = input.bool(true,  "Show 2× Harmonic Grid", group="⑤ Harmonic Grids")
colGrid1    = input.color(color.blue,   "1× Grid",     group="⑤ Harmonic Grids", inline="g1")
colDiag1    = input.color(color.green,  "1× Diagonal", group="⑤ Harmonic Grids", inline="g1")
colGrid2    = input.color(color.black,  "2× Grid",     group="⑤ Harmonic Grids", inline="g2")
colDiag2    = input.color(color.red,    "2× Diagonal", group="⑤ Harmonic Grids", inline="g2")
showDiag1x  = input.bool(true, "1× Diagonals", group="⑤ Harmonic Grids", inline="g1")
showDiag2x  = input.bool(true, "2× Diagonals", group="⑤ Harmonic Grids", inline="g2")
gridOpacity = input.int(20, "Grid Opacity",     minval=0, maxval=90, step=5, group="⑤ Harmonic Grids")
diagOpacity = input.int(20, "Diagonal Opacity", minval=0, maxval=90, step=5, group="⑤ Harmonic Grids")
gridLW      = input.int(1,  "Grid Line Width",  minval=1, maxval=3,  group="⑤ Harmonic Grids")
showCentreH = input.bool(true, "Show Horizontal Centre Line", group="⑤ Harmonic Grids")
showCentreV = input.bool(true, "Show Vertical Centre Line",   group="⑤ Harmonic Grids")
colCentre   = input.color(color.orange, "Centre Line Color",  group="⑤ Harmonic Grids")

// ══════════════════════════════════════════════════════════════════════════════
// ⑥ DISPLAY
// ══════════════════════════════════════════════════════════════════════════════
showGridLines   = input.bool(true,  "Grid Lines (H + V)",         group="⑥ Display")
showDiagonals   = input.bool(true,  "X Diagonals",                group="⑥ Display")
showBoundary    = input.bool(true,  "Outer Grid Boundary",        group="⑥ Display")
showHLLabels    = input.bool(true,  "H / L Anchor Labels",        group="⑥ Display")
showCycleLabels = input.bool(true,  "Future Cycle Labels",        group="⑥ Display")
showConfluence  = input.bool(true,  "Time Confluence Zones (⚡)", group="⑥ Display")
showSignals     = input.bool(true,  "Buy / Sell Signals",         group="⑥ Display")
showTier1 = input.bool(true, "Tier 1 — Master Cycle (Sq)",        group="⑥ Display")
showTier2 = input.bool(true, "Tier 2 — Major Cycles (Sq + Hyp)",  group="⑥ Display")
showTier3 = input.bool(true, "Tier 3 — Minor Cycles (½Hyp)",      group="⑥ Display")
showTierC = input.bool(true, "Confluence Highlight",               group="⑥ Display")
pastCycles      = input.int(3,  "Past Cycles",                minval=1, maxval=15, group="⑥ Display")
futureCycles    = input.int(4,  "Future Cycles",              minval=1, maxval=8,  group="⑥ Display")
confluenceWin   = input.int(3,  "Confluence Window (bars)",   minval=1, maxval=10, group="⑥ Display")

// ══════════════════════════════════════════════════════════════════════════════
// ⑦ SIGNALS
// ══════════════════════════════════════════════════════════════════════════════
sigSLMode    = input.string("Grid Cell", "Stop Loss Method",
     options=["ATR","Grid Cell","Fixed %"], group="⑦ Signals")
sigSLATRMult = input.float(1.0, "SL ATR Multiplier", minval=0.25, maxval=5.0,  step=0.25, group="⑦ Signals")
sigSLPct     = input.float(1.5, "SL Fixed %",        minval=0.25, maxval=10.0, step=0.25, group="⑦ Signals")
sigRR        = input.float(2.0, "Risk : Reward",     minval=0.5,  maxval=10.0, step=0.25, group="⑦ Signals")
sigPctTol    = input.float(3.0, "Signal Tolerance %", minval=0.1, maxval=5.0, step=0.1, group="⑦ Signals")
showTierP = input.bool(false, "Tier 3 — Price Level Signals (P)", group="⑦ Signals")
colBuy       = input.color(#00C853, "Buy Colour",  group="⑦ Signals", inline="sc")
colSell      = input.color(#D50000, "Sell Colour", group="⑦ Signals", inline="sc")

// ══════════════════════════════════════════════════════════════════════════════
// PERSISTENT STATE
// ══════════════════════════════════════════════════════════════════════════════
var float swingHigh        = na
var float swingLow         = na
var int   swHBar           = na
var int   swLBar           = na
var int   swingLockedUntil = 0
var float swingDurMins     = na   // swing duration stored in MINUTES for TF independence

var line[]  drawnLines  = array.new<line>()
var label[] drawnLabels = array.new<label>()

var int[]   phBars = array.new<int>()
var float[] phVals = array.new<float>()
var int[]   plBars = array.new<int>()
var float[] plVals = array.new<float>()

var int   lastSigBar  = -999
var bool  lastSigBuy  = false
var bool  lastSigSell = false
var box   activeZoneBox = na

// ══════════════════════════════════════════════════════════════════════════════
// DERIVED CONSTANTS
// ══════════════════════════════════════════════════════════════════════════════
swDiv        = swingWidth == "Narrow  1/16" ? 16 : swingWidth == "Wide    1/4" ? 4 : swingWidth == "Widest  1/2" ? 2 : 8
swMul        = swingWidth == "Narrow  1/16" ?  2 : swingWidth == "Wide    1/4" ? 6 : swingWidth == "Widest  1/2" ? 8 : 4
pivotLB      = math.max(2, int(gannNumber / swDiv))
searchRadius = math.max(4, int(gannNumber / swDiv) * 2)
maxHistory   = gannNumber * swMul
expectedDur  = periodDivisor == "Full" ? gannNumber :
               periodDivisor == "3/4"  ? int(gannNumber * 3 / 4) :
               periodDivisor == "1/4"  ? int(gannNumber / 4) :
               int(gannNumber / 2)

atrVal       = ta.atr(gannNumber)
minRange     = atrVal * minSwingATRMult
idealRatio   = minRange / float(expectedDur)

maxSwingRatio = gridStability == "Relaxed" ? 15.0 : gridStability == "Adaptive" ? 8.0 : 5.0
stabilityThr  = gridStability == "Strict"  ? 0.750 : gridStability == "Relaxed" ? 0.500 : 0.625
boundaryThr   = gridStability == "Strict"  ? 0.375 : gridStability == "Relaxed" ? 0.125 : 0.250

FC        = bar_index + 499
pdHigh  = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_on)
pdLow   = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_on)
pdOpen  = request.security(syminfo.tickerid, "D", open[1],  lookahead=barmerge.lookahead_on)
pdClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
pdMid   = (pdHigh + pdLow) / 2.0
vwapVal = ta.vwap(hlc3)
chartLow  = ta.lowest(low, 500)

// ══════════════════════════════════════════════════════════════════════════════
// MANUAL ANCHOR
// ══════════════════════════════════════════════════════════════════════════════
isManual    = anchorMode == "Manual"
aHP         = isManual and anchorHighBack > 0 ? high[anchorHighBack] : na
aLP         = isManual and anchorLowBack  > 0 ? low[anchorLowBack]  : na
anchorValid = isManual and not na(aHP) and not na(aLP) and aHP > aLP

// ══════════════════════════════════════════════════════════════════════════════
// AUTO SWING DETECTION
// ══════════════════════════════════════════════════════════════════════════════
ph = ta.pivothigh(high, pivotLB, pivotLB)
pl = ta.pivotlow (low,  pivotLB, pivotLB)

if not isManual and bar_index >= pivotLB * 2 + 1
    if not na(ph)
        array.push(phBars, bar_index - pivotLB)
        array.push(phVals, high[pivotLB])
        while array.size(phBars) > 0 and (bar_index - array.get(phBars, 0)) > maxHistory
            array.shift(phBars)
            array.shift(phVals)
    if not na(pl)
        array.push(plBars, bar_index - pivotLB)
        array.push(plVals, low[pivotLB])
        while array.size(plBars) > 0 and (bar_index - array.get(plBars, 0)) > maxHistory
            array.shift(plBars)
            array.shift(plVals)

// ══════════════════════════════════════════════════════════════════════════════
// SWING QUALITY CHECK
// ══════════════════════════════════════════════════════════════════════════════
newSwingOK(nH, nL) =>
    na(swingHigh) or na(swingLow) ? true :
     (nH - nL) >= (swingHigh - swingLow) * stabilityThr or
     nH > swingHigh + (swingHigh - swingLow) * boundaryThr or
     nL < swingLow  - (swingHigh - swingLow) * boundaryThr

// ══════════════════════════════════════════════════════════════════════════════
// VECTOR CIRCLE SEARCH
// ══════════════════════════════════════════════════════════════════════════════
float bestScore = -1.0
float bestH     = swingHigh
float bestL     = swingLow
int   bestHBar  = swHBar
int   bestLBar  = swLBar

if not isManual and array.size(phBars) > 0 and array.size(plBars) > 0
    for hi = 0 to array.size(phBars) - 1
        hBar = array.get(phBars, hi)
        hVal = array.get(phVals, hi)
        for li = 0 to array.size(plBars) - 1
            lBar = array.get(plBars, li)
            lVal = array.get(plVals, li)
            if hBar == lBar
                continue
            dur = math.abs(hBar - lBar)
            nr  = hVal - lVal
            if nr <= 0 or nr < minRange
                continue
            if math.abs(dur - expectedDur) > searchRadius
                continue
            ratio = nr / float(dur)
            if ratio > idealRatio * maxSwingRatio
                continue
            if not newSwingOK(hVal, lVal)
                continue
            if not na(swHBar) and not na(swLBar)
                if math.abs(hBar - swHBar) < gannNumber and math.abs(lBar - swLBar) < gannNumber
                    continue
            score = 1.0/(math.abs(ratio-idealRatio)/(idealRatio*0.1+0.0001)+0.1) + 1.0/(math.abs(dur-expectedDur)/float(searchRadius)+0.1) + nr/(minRange+0.0001)
            if score > bestScore * 1.75
                if na(swingHigh) or na(swingLow) or (score > bestScore * 2.5 and math.abs(hBar - swHBar) > gannNumber * 2 and math.abs(lBar - swLBar) > gannNumber * 2)
                    bestScore := score
                    bestH     := hVal
                    bestL     := lVal
                    bestHBar  := hBar
                    bestLBar  := lBar

// ══════════════════════════════════════════════════════════════════════════════
// SWING ASSIGNMENT
// ══════════════════════════════════════════════════════════════════════════════
if isManual and anchorValid
    swingHigh     := aHP
    swingLow      := aLP
    swHBar        := bar_index - anchorHighBack
    swLBar        := bar_index - anchorLowBack
      
else if not isManual and bestScore > 0.0 and not na(bestH) and not na(bestL)
    if bar_index >= swingLockedUntil
        swingHigh        := bestH
        swingLow         := bestL
        swHBar           := bestHBar
        swLBar           := bestLBar
        swingDurMins     := math.abs(bestHBar - bestLBar) * timeframe.multiplier
        swingLockedUntil := bar_index + expectedDur

validSwing = not na(swingHigh) and not na(swingLow) and not na(swHBar) and not na(swLBar)

// ══════════════════════════════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════════════════════════════
safeLine(x0, y0, x1, y1, col, w, sty) =>
    ix0 = math.min(int(x0), FC)
    ix1 = math.min(int(x1), FC)
    ls  = sty == 1 ? line.style_dashed : sty == 2 ? line.style_dotted : line.style_solid
    array.push(drawnLines, line.new(ix0, y0, ix1, y1, color=col, width=w, style=ls))

safeLabel(x, y, txt, sty, bgCol, txtCol, sz) =>
    ix = math.min(int(x), FC)
    array.push(drawnLabels, label.new(ix, y, txt, style=sty, color=bgCol, textcolor=txtCol, size=sz))

// ══════════════════════════════════════════════════════════════════════════════
// PYTHAGOREAN TIME NODES
// ══════════════════════════════════════════════════════════════════════════════
pythNodes(swEndBar, swDur, fullR, hMult) =>
    scaledG        = float(swDur * hMult)
    priceTimeRatio = swDur / fullR
    priceSide      = fullR * float(hMult) * priceTimeRatio
    legABars       = scaledG
    legBBars       = priceSide
    hypBars    = math.sqrt(legABars * legABars + legBBars * legBBars)
    halfSqBars = math.sqrt(legABars * legABars + (legBBars / 2.0) * (legBBars / 2.0))

    t_LegB    = swEndBar + math.round(legBBars)
    t_HalfSq  = swEndBar + math.round(halfSqBars)
    t_HalfHyp = swEndBar + math.round(hypBars / 2.0)
    t_FullHyp = swEndBar + math.round(hypBars)
    t_FullSq  = swEndBar + int(scaledG)
    t_TwoSq   = swEndBar + int(scaledG) * 2

    [int(t_LegB), int(t_HalfSq), int(t_HalfHyp), int(t_FullHyp), int(t_FullSq), int(t_TwoSq),
     math.round(legBBars), math.round(halfSqBars), math.round(legABars), math.round(hypBars)]

isAtPythNode(swEndBar, swDur, fullR, hMult) =>
    [t1, t2, t3, t4, t5, t6, lb, hs, lh, fh] = pythNodes(swEndBar, swDur, fullR, hMult)
    periodLen = int(math.round(fh))
    if periodLen <= 0
        false
    else
        bFromEnd = bar_index - swEndBar
        cyclePos = bFromEnd % periodLen
        n2 = int(math.round(hs)) % periodLen
        n3 = int(math.round(lh)) % periodLen
        n4 = periodLen
        n5 = int(float(swDur * hMult)) % periodLen
        cyclePos == n2 or cyclePos == n3 or cyclePos == n4 or cyclePos == n5

// ══════════════════════════════════════════════════════════════════════════════
// CORE GRID DRAW
// ══════════════════════════════════════════════════════════════════════════════
drawGrid(swEndBar, swH, swL, fullR, swDur, hMult, gCol, dCol, gOp, dOp, lw) =>
    pLen      = swDur * hMult
    cellH     = (ptB / ptA) * fullR * tfScalar * float(hMult)
    cellH1x   = (ptB / ptA) * fullR * tfScalar * 1.0
    yOrigin   = instrType == "Options" ? -cellH1x : math.max(math.min(swL, chartLow) - cellH * 2.0, 0)
    totalRows = math.ceil((math.max(swH, close) - yOrigin) / cellH) + math.ceil(fullR / cellH) + 4
    startCol  = -pastCycles
    minEndCol = math.ceil(float(bar_index - swEndBar) / float(pLen)) + 1
    endCol    = math.max(futureCycles, minEndCol)
    xLeft     = math.max(swEndBar + startCol * pLen, 0)
    xRight    = math.min(swEndBar + endCol   * pLen, FC)

    for col = startCol to endCol
        x0     = swEndBar + col * pLen
        x1     = x0 + pLen
        if x1 < bar_index - (pastCycles * pLen + 100)
            continue
        if x0 > FC
            break
        x0c    = math.max(x0, 0)
        x1c    = math.min(x1, FC)
        dist   = math.abs(col)
        gOpAdj = math.min(90, gOp + dist * 6)
        dOpAdj = math.min(90, dOp + dist * 6)

        if showGridLines or showBoundary
            vw = col == 0 ? lw + 1 : lw
            safeLine(x0c, yOrigin, x0c, yOrigin + totalRows * cellH, color.new(gCol, gOpAdj), vw, 0)
        if showCentreV
            if x0c + int(pLen / 2) <= FC
                safeLine(x0c + int(pLen / 2), yOrigin, x0c + int(pLen / 2), yOrigin + totalRows * cellH, color.new(colCentre, gOpAdj), 1, 1)

        [t1, t2, t3, t4, t5, t6, lb, hs, lh, fh] = pythNodes(x0, swDur, fullR, hMult)
        isPast = col < 0

        if showTier1 and hMult == 1
            nb = t5
            if nb > 0 and nb <= FC
                safeLine(nb, yOrigin, nb, yOrigin + totalRows * cellH, color.new(#FFD700, 0), lw + 2, 0)
                if isPast
                    safeLabel(nb, yOrigin + (totalRows + 0.4) * cellH, "Sq", label.style_label_down, color.new(#FFD700, 60), color.white, size.tiny)
                else
                    bAway = nb - bar_index
                    safeLabel(nb, yOrigin + (totalRows + 0.4) * cellH, "Sq +" + str.tostring(bAway), label.style_label_down, color.new(#FFD700, 0), color.black, size.small)

        if showTier2 and hMult == 1
            nb = t4
            if nb > 0 and nb <= FC
                safeLine(nb, yOrigin, nb, yOrigin + totalRows * cellH, color.new(#C62828, 20), lw + 1, 0)
                if isPast
                    safeLabel(nb, yOrigin + (totalRows + 0.4) * cellH, "Hyp", label.style_label_down, color.new(#C62828, 70), color.white, size.tiny)
                else
                    bAway = nb - bar_index
                    safeLabel(nb, yOrigin + (totalRows + 0.4) * cellH, "Hyp +" + str.tostring(bAway), label.style_label_down, color.new(#C62828, 0), color.white, size.tiny)

        if showTier3 and hMult == 1
            nb = t3
            if nb > 0 and nb <= FC
                safeLine(nb, yOrigin, nb, yOrigin + totalRows * cellH, color.new(#1565C0, 60), 1, 1)

        for row = 0 to totalRows - 1
            yBot = yOrigin + float(row) * cellH
            yTop = yBot + cellH
            yCentre = yBot + cellH * 0.5
            if showGridLines
                safeLine(x0c, yBot, x1c, yBot, color.new(gCol, gOpAdj), lw, 0)
            if showCentreH
                safeLine(x0c, yBot + cellH * 0.5, x1c, yBot + cellH * 0.5, color.new(colCentre, gOpAdj), 1, 1)
            showThisDiag = hMult == 1 ? showDiag1x : showDiag2x
            if showDiagonals and showThisDiag and col > startCol
                safeLine(x0c, yBot, x1c, yTop, color.new(dCol, dOpAdj), 1, 0)
                safeLine(x0c, yTop, x1c, yBot, color.new(dCol, dOpAdj), 1, 0)

    for row = 0 to totalRows
        yRow = yOrigin + float(row) * cellH
        if showGridLines
            safeLine(xLeft, yRow, xRight, yRow, color.new(gCol, gOp), lw, 0)

    if showBoundary
        xEnd = math.min(swEndBar + endCol * pLen, FC)
        safeLine(xEnd, yOrigin, xEnd, yOrigin + totalRows * cellH, color.new(gCol, gOp), lw + 1, 0)

// ══════════════════════════════════════════════════════════════════════════════
// CONFLUENCE DETECTION
// ══════════════════════════════════════════════════════════════════════════════
markConfluence(swEndBar, swH, swL, fullR, swDur) =>
    if showTierC
        qLen = swDur          // quarter cycle = 1 swing duration
        hLen = swDur * 2      // half cycle
        fLen = swDur * 4      // full cycle

        for col = 0 to futureCycles * 4
            nb = swEndBar + col * qLen
            if nb <= bar_index or nb > FC
                continue

            isHalf = col % 2 == 0
            isFull = col % 4 == 0

            cellH      = (ptB / ptA) * fullR * tfScalar
            cellH1x    = (ptB / ptA) * fullR * tfScalar * 1.0
            yOrig      = instrType == "Options" ? -cellH1x : math.max(math.min(swL, chartLow) - cellH * 2.0, 0)
            rowIdx     = int((close - yOrig) / cellH)
            yBot       = yOrig + float(rowIdx) * cellH
            yTop       = yBot + cellH
            yCentre = yBot + cellH * 0.5 
            nearBot    = math.abs(close - yBot)                  < cellH * 0.15
            nearTop    = math.abs(close - yTop)                  < cellH * 0.15
            nearCentre = math.abs(close - (yBot + cellH * 0.5)) < cellH * 0.15
            atGridLevel = nearBot or nearTop or nearCentre
            
            if atGridLevel
                if isFull
                    bAway = nb - bar_index
                    safeLabel(nb, swH + (swH - swL) * 0.15, "⚡⚡⚡ +" + str.tostring(bAway), label.style_label_down, color.new(#FFD700, 0), color.black, size.normal)
                else if isHalf
                    bAway = nb - bar_index
                    safeLabel(nb, swH + (swH - swL) * 0.15, "⚡⚡ +" + str.tostring(bAway), label.style_label_down, color.new(#FF6F00, 0), color.white, size.small)
                else
                    bAway = nb - bar_index
                    safeLabel(nb, swH + (swH - swL) * 0.15, "⚡ +" + str.tostring(bAway), label.style_label_down, color.new(#C62828, 60), color.white, size.tiny)

// ══════════════════════════════════════════════════════════════════════════════
// ACTIVE ZONE HIGHLIGHT
// ══════════════════════════════════════════════════════════════════════════════
markActiveZone(swEndBar, swH, swL, fullR, swDur) =>
    cellH   = (ptB / ptA) * fullR * tfScalar
    cellH1x = (ptB / ptA) * fullR * tfScalar * 1.0
    yOrig   = instrType == "Options" ? -cellH1x : math.max(math.min(swL, chartLow) - cellH * 2.0, 0)
    pLen    = swDur * 1
    rowIdx  = int((close - yOrig) / cellH)
    yBot    = yOrig + float(rowIdx) * cellH
    yTop    = yBot + cellH
    yCentre = yBot + cellH * 0.5 
    colIdx2 = int((bar_index - swEndBar) / pLen)
    xLeft   = swEndBar + colIdx2 * pLen
    xRight  = math.min(xLeft + pLen, FC)
    isUpper = close > yBot + cellH * 0.5
    boxCol  = isUpper ? color.new(#00C853, 88) : color.new(#D50000, 88)

    [t1, t2, t3, t4, t5, t6, lb, hs, lh, fh] = pythNodes(swEndBar, swDur, fullR, 1)
    seg    = bar_index < t2 ? "Pre-½Sq" : bar_index < t3 ? "½Sq→½Hyp" : bar_index < t4 ? "½Hyp→Hyp" : bar_index < t5 ? "Hyp→Sq" : "Post-Sq"
    posLbl = isUpper ? "▲ Upper" : "▼ Lower"
    array.push(drawnLabels, label.new(bar_index + 2, close, seg + " | " + posLbl, style=label.style_label_left, color=color.new(color.black, 70), textcolor=color.white, size=size.small))
    [yBot, yTop, xLeft, xRight, boxCol]

// ══════════════════════════════════════════════════════════════════════════════
// SIGNAL LOGIC
// ══════════════════════════════════════════════════════════════════════════════
nearPDLevel(src) =>
    tol     = src * sigPctTol / 100.0
    atPDH   = math.abs(src - pdHigh)  <= tol
    atPDL   = math.abs(src - pdLow)   <= tol
    atPDO   = math.abs(src - pdOpen)  <= tol
    atPDC   = math.abs(src - pdClose) <= tol
    atPDM   = math.abs(src - pdMid)   <= tol
    atVWAP  = math.abs(src - vwapVal) <= tol
    atPDH or atPDL or atPDO or atPDC or atPDM or atVWAP
evalSignal(swingEndBar, swH, swL, fullR, swDur) =>
    cellH   = (ptB / ptA) * fullR * tfScalar
    cellH1x = (ptB / ptA) * fullR * tfScalar * 1.0
    yOrig   = instrType == "Options" ? -cellH1x : math.max(math.min(swL, chartLow) - cellH * 2.0, 0)
    pLen    = swDur * 1
    rowIdx  = int((close - yOrig) / cellH)
    yBot    = yOrig + float(rowIdx) * cellH
    yTop    = yBot + cellH
    yCentre = yBot + cellH * 0.5
    bodySize    = math.abs(close - open)
    minBody     = atrVal * 0.3
    strongCandle = bodySize >= minBody
    slAmt   = sigSLMode == "ATR"       ? atrVal * sigSLATRMult :
              sigSLMode == "Grid Cell" ? cellH * 0.5           :
              close * sigSLPct / 100.0

    [t1, t2, t3, t4, t5, t6, lb, hs, lh, fh] = pythNodes(swingEndBar, swDur, fullR, 1)
    atNode1x   = isAtPythNode(swingEndBar, swDur, fullR, 1)
    atNode2x   = isAtPythNode(swingEndBar, swDur, fullR, 2)
    atPythNode = atNode1x or atNode2x

    halfHypPeriod = math.max(int(math.round(lh)), pLen / 2)

    // ── Price grid levels ─────────────────────────────────────────────────────
    nearBot    = math.abs(close - yBot)     < cellH * 0.15
    nearTop    = math.abs(close - yTop)     < cellH * 0.15
    nearCentre = math.abs(close - yCentre)  < cellH * 0.15
    atGridLevel = nearBot or nearTop or nearCentre

    // Tier 1 — Time = Price Square
    squareBuy  = atPythNode and atGridLevel and close > open and strongCandle
    squareSell = atPythNode and atGridLevel and close < open and strongCandle

    // Tier 2 — Time node only
    timeSignalBuy  = atPythNode and not atGridLevel and close > open and strongCandle
    timeSignalSell = atPythNode and not atGridLevel and close < open and strongCandle

    // Tier 3 — Price level only (gated by toggle)
    priceSignalBuy  = showTierP and atGridLevel and not atPythNode and nearBot and close > open and strongCandle
    priceSignalSell = showTierP and atGridLevel and not atPythNode and nearTop and close < open and strongCandle

    // — Combine —
    doBuy  = squareBuy  or timeSignalBuy  or priceSignalBuy
    doSell = squareSell or timeSignalSell or priceSignalSell

    // ── Signal grade ──────────────────────────────────────────────────────────
    sigCode = squareBuy  or squareSell  ? "Sq" :
              timeSignalBuy or timeSignalSell   ? "T"  : "P"

    slBuy  = close - slAmt
    slSell = close + slAmt
    tpBuy  = close + slAmt * sigRR
    tpSell = close - slAmt * sigRR
    [doBuy, doSell, slBuy, slSell, tpBuy, tpSell, halfHypPeriod, sigCode]
// ══════════════════════════════════════════════════════════════════════════════
// MAIN EXECUTION
// ══════════════════════════════════════════════════════════════════════════════
var bool plotBuy   = false
var bool plotSell  = false
var bool atNodeNow = false

if validSwing
    fullR       = math.abs(swingHigh - swingLow)
    swingEndBar = swHBar < swLBar ? swHBar : swLBar
    swingDur = math.abs(swHBar - swLBar)

    if barstate.islast
        while array.size(drawnLines)  > 0
            line.delete(array.pop(drawnLines))
        while array.size(drawnLabels) > 0
            label.delete(array.pop(drawnLabels))

        if showHLLabels
            array.push(drawnLines, line.new(swHBar, swingHigh, swLBar, swingLow, color=#FFD700, width=2))
            swInfoTxt = "H: " + str.tostring(swingHigh, format.mintick) + "  L: " + str.tostring(swingLow, format.mintick) + "  R: " + str.tostring(math.abs(swingHigh - swingLow), format.mintick) + "  Bars: " + str.tostring(swingDur)
            midBar    = int((swHBar + swLBar) / 2)
            midPrice  = (swingHigh + swingLow) / 2.0
            array.push(drawnLabels, label.new(swHBar, swingHigh, "H " + str.tostring(swingHigh, format.mintick), style=label.style_label_down, color=#C0392B, textcolor=color.white, size=size.normal))
            array.push(drawnLabels, label.new(swLBar, swingLow,  "L " + str.tostring(swingLow, format.mintick),  style=label.style_label_up,   color=#27AE60, textcolor=color.white, size=size.normal))
            array.push(drawnLabels, label.new(midBar, midPrice, swInfoTxt, style=label.style_label_up, color=color.new(#FFD700, 20), textcolor=color.black, size=size.normal))

        if showGrid1x
            drawGrid(swingEndBar, swingHigh, swingLow, fullR, swingDur, 1, colGrid1, colDiag1, gridOpacity, diagOpacity, 1)
        if showGrid2x
            drawGrid(swingEndBar, swingHigh, swingLow, fullR, swingDur, 2, colGrid2, colDiag2, gridOpacity, diagOpacity, 2)

        markConfluence(swingEndBar, swingHigh, swingLow, fullR, swingDur)

    if barstate.isconfirmed
        [zBot, zTop, zLeft, zRight, zCol] = markActiveZone(swingEndBar, swingHigh, swingLow, fullR, swingDur)
        if not na(activeZoneBox)
            box.delete(activeZoneBox)
        activeZoneBox := box.new(zLeft, zTop, zRight, zBot, border_color=zCol, border_width=1, bgcolor=zCol)
        atNodeNow     := isAtPythNode(swingEndBar, swingDur, fullR, 1) or isAtPythNode(swingEndBar, swingDur, fullR, 2)
        [db, ds, slB, slS, tB, tS, halfHyp, sigType] = evalSignal(swingEndBar, swingHigh, swingLow, fullR, swingDur)
        if showSignals
            plotBuy  := db
            plotSell := ds

        if db
            label.new(bar_index, low,  "BUY-" + sigType,  style=label.style_label_up,   color=color.new(colBuy,  10), textcolor=color.white, size=size.small)
            lastSigBar  := bar_index
            lastSigBuy  := true
            lastSigSell := false

        if ds
            label.new(bar_index, high, "SELL-" + sigType, style=label.style_label_down, color=color.new(colSell, 10), textcolor=color.white, size=size.small)
            lastSigBar  := bar_index
            lastSigSell := true
            lastSigBuy  := false

        if not db and not ds and bar_index - lastSigBar > halfHyp
            lastSigBuy  := false
            lastSigSell := false

// ══════════════════════════════════════════════════════════════════════════════
// PLOTSHAPE
// ══════════════════════════════════════════════════════════════════════════════

plotshape(plotBuy  and showSignals, title="Buy",  style=shape.triangleup,   location=location.belowbar, color=colBuy,  size=size.small)
plotshape(plotSell and showSignals, title="Sell", style=shape.triangledown, location=location.abovebar, color=colSell, size=size.small)
````
