# CHoCH VWAP Smart Money| julzALGO

- url: https://www.tradingview.com/script/hFUWygT1-CHoCH-VWAP-Smart-Money-julzALGO/
- type: indicator
- pine_id: PUB;64b1369b25a74ba48fc90f6d53ef9e56
- version: 1.0

## Description

📊 CHoCH VWAP Smart Money| julzALGO


🔷 1. Overview

CHoCH VWAP Smart Money  is a structure-anchored smart money repricing framework that combines internal Change of Character (CHoCH), structural pivot detection, anchored VWAP, premium/discount band mapping, and integrated risk-to-reward execution into one unified overlay.

The script is designed to help traders evaluate not only when market structure shifts, but where price may reprice, retest, defend, or reject after that shift.

By combining internal structural flips with pivot-anchored VWAP recalculation, this framework can be used for:
• Initial structural reversal detection
• Smart money demand / supply repricing
• Pullback and retest planning
• Premium / discount zone analysis
• Institutional cost-basis visualization
• Risk-to-reward execution planning

🔷 2. Core Concept

Traditional VWAP often resets from fixed sessions, daily opens, or arbitrary anchors.
CHoCH Anchored VWAP expands this by integrating:
• Internal CHoCH structural flips
• Swing high / swing low pivots
• Structural break confirmation
• Pivot-based anchor reset
• CHoCH-anchored VWAP recalculation
• Premium / discount deviation bands
• Historical structural path preservation
• Dynamic RR projection

The core idea is simple:
Each confirmed internal CHoCH establishes a structural repricing event.
https://www.tradingview.com/x/ulTrlJVL/
From that event:
• Previous market structure is considered disrupted
• A new structural anchor pivot is selected
• VWAP resets from that anchor
• Institutional average price is recalculated from the structural origin
• Premium / discount bands evolve dynamically until the next opposite CHoCH occurs

Where VWAP and participation calculation starts:
https://www.tradingview.com/x/07eEMwdG/

VWAP, Standard Deviation / Percentage Bands, and RR zones begin calculating from the CHoCH anchor pivot marker and continue accumulating through each new bar until the next confirmed opposite structural CHoCH occurs.
Simple rule:
CHoCH Anchor Pivot → Present Active Bar
Bullish CHoCH:
When bullish CHoCH is confirmed, VWAP tracking begins from the prior structural swing low.
Bearish CHoCH:
When bearish CHoCH is confirmed, VWAP tracking begins from the prior structural swing high.
Reset rule:
When a new opposite CHoCH occurs:
• Previous VWAP path stops
• Previous path becomes historical dashed structure
• New anchor is selected
• New VWAP and bands reset
• New RR planning begins
Important:
VWAP and Bands are not session-based.
They represent cumulative structural repricing from the CHoCH origin to the current active bar.
This helps traders evaluate whether the active structure remains institutionally supported, discounted, or overextended—even during pullbacks, retests, or liquidity rebalances.

🔷 3. How It Works
The Internal CHoCH Engine continuously tracks rolling pivot highs and lows using the selected internal pivot length.
https://www.tradingview.com/x/d9qERX97/
This identifies:
• Bullish CHoCH
• Bearish CHoCH
• Internal structure breaks
• Structural anchor pivots
• Demand / supply shift zones
Break confirmation can be based on:
• Candle close
• Wick break
Once a valid CHoCH is confirmed:
The VWAP Engine resets and recalculates a new anchored VWAP path from the structural pivot.
Instead of anchoring to arbitrary time, this model anchors to structural intent.
This transforms VWAP into a dynamic smart money cost-basis path.

The Band Engine projects:
https://www.tradingview.com/x/k5KpiR6H/

• Band #1 = Primary premium / discount zone
• Band #2 = Extended premium / discount zone
• Band #3 = Exhaustion / expansion zone
Band modes:
• Standard Deviation = Statistical structural expansion
• Percentage = Fixed repricing percentage

The RR system can project:

• Entry
• Stop Loss
• Take Profit
This allows traders to combine structure, institutional repricing, and visual execution planning in one workflow.
Visual interpretation:
• Blue VWAP Path = Bullish structural demand repricing
• Purple VWAP Path = Bearish structural supply repricing
• Blue Diamond = Bullish CHoCH anchor where tracking begins
• Purple Diamond = Bearish CHoCH anchor where tracking begins
• Bands = Premium / Discount deviation zones
• Dashed Historical VWAP = Previous structural cycle
• Entry = Structural execution trigger
• SL = Volatility or pivot invalidation
• TP = RR objective

🔷 4. Smart Money Interpretation

This framework is especially useful for:

For  Bullish
https://www.tradingview.com/x/J8cI67DN/
For  Bearish
https://www.tradingview.com/x/32M8iOeX/

Demand Reclaim:
Bullish CHoCH → Pullback into VWAP / Lower Band → Demand hold → Continuation bias

Supply Rejection:
Bearish CHoCH → Pullback into VWAP / Upper Band → Supply reject → Continuation bias

Premium / Discount:
• Below bullish VWAP = Potential discount accumulation
• Above bearish VWAP = Potential premium distribution

Retest Logic:
CHoCH identifies WHEN structure changes
VWAP identifies WHERE smart money may defend that change
This makes the indicator useful for:
• Retests
• Pullbacks
• Demand / Supply zones
• Institutional repricing
• Liquidity rebalance

🔷 5. Settings

Internal Pivot Length
Controls structural sensitivity.
Suggested reference:
• 5–15 = Faster / scalping
• 20–40 = Balanced / intraday
• 50+ = Higher timeframe / smoother
Break Confirmation
Close: More conservative structural confirmation.
Wick: More aggressive / earlier detection.
Band Calculation Mode
Standard Deviation: Adaptive volatility-based premium / discount.
Percentage:Fixed expansion bands.
Stop Loss Type
ATR: Adaptive volatility stop.
Pivot: Structure invalidation stop.
ATR Multiplier
Suggested reference:
• 1.5 = Tight
• 2.0 = Balanced
• 3.0+ = Wider
Risk:Reward
Suggested reference:
• 1.5 = Conservative
• 2.0 = Balanced
• 3.0 = Extended
General preset:
• Internal Pivot Length: 10–20
• Confirmation: Close
• Band Mode: Standard Deviation
• Stop Loss Type: Pivot or ATR
• ATR Multiplier: 2.0–3.0
• RR: 2.0

🔷 IMPORTANT NOTES
• This indicator does not guarantee profits and should not be used in isolation
• Internal CHoCH may be more sensitive than external structure
• VWAP anchoring is structure-based, not session-based
• Premium / discount does not automatically imply reversal
• Market conditions vary; always apply proper risk management

🔷 DISCLAIMER
This script is for educational and informational purposes only.
It does not constitute financial advice. Always perform your own analysis before making trading decisions

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0
// Copyright julzALGO

//@version=6
indicator("CHoCH VWAP Smart Money| julzALGO", overlay=true, max_bars_back=5000, max_labels_count=500, max_lines_count=500, max_polylines_count=100)

//──────────────────────────────────────────────────────────────────────────────
// INPUTS
//──────────────────────────────────────────────────────────────────────────────
groupStructure = "Internal CHoCH Engine"
groupVWAP      = "Anchored VWAP"
groupBands     = "VWAP Bands"
groupRisk      = "RR System"
groupStyle     = "Style"

showInternalChoch = input.bool(true, "Internal CHoCH", group=groupStructure, inline="i")
internalPivotLen  = input.int(10, "", minval=2, group=groupStructure, inline="i")
confirmMode       = input.string("Close", "Break Confirmation", options=["Close", "Wick"], group=groupStructure)
showChochLines    = input.bool(true, "Show CHoCH Lines", group=groupStructure)
maxChochMarks     = input.int(50, "Max CHoCH Marks", minval=10, maxval=300, group=groupStructure)

vwapSource = input.source(hlc3, "VWAP Source", group=groupVWAP)

bandCalcMode = input.string("Standard Deviation", "Bands Calculation Mode", options=["Standard Deviation", "Percentage"], group=groupBands)
showBand1    = input.bool(true, "", group=groupBands, inline="b1")
bandMult1    = input.float(1.0, "Band #1", minval=0, step=0.5, group=groupBands, inline="b1")
showBand2    = input.bool(false, "", group=groupBands, inline="b2")
bandMult2    = input.float(2.0, "Band #2", minval=0, step=0.5, group=groupBands, inline="b2")
showBand3    = input.bool(false, "", group=groupBands, inline="b3")
bandMult3    = input.float(3.0, "Band #3", minval=0, step=0.5, group=groupBands, inline="b3")

showSignal         = input.bool(true, "Show VWAP Anchor Diamond", group=groupRisk)
sl_type            = input.string("ATR", "Stop Loss Type", options=["ATR", "Pivot"], group=groupRisk)
rr                 = input.float(2.0, "Risk:Reward", minval=0.1, step=0.1, group=groupRisk)
sl_mult            = input.float(3.0, "ATR Multiplier", minval=0.1, step=0.1, group=groupRisk)
slPivotBufferTicks = input.int(0, "Pivot SL Buffer (ticks)", minval=0, group=groupRisk)
labelOffset        = input.int(10, "RR Label Offset Bars", minval=1, group=groupRisk)

bullLineCol = input.color(color.rgb(0, 176, 230), "Bull Line", group=groupStyle, inline="ln")
bearLineCol = input.color(color.rgb(137, 82, 255, 15), "", group=groupStyle, inline="ln")
lineWidth   = input.int(2, "VWAP Line Width", minval=1, group=groupStyle)

bandLineWidth = input.int(1, "Band Line Width", minval=1, maxval=5, group=groupStyle)
bandCol1      = input.color(color.rgb(0, 176, 230, 55), "Band #1", group=groupStyle, inline="bc")
bandCol2      = input.color(color.rgb(137, 82, 255, 65), "Band #2", group=groupStyle, inline="bc")
bandCol3      = input.color(color.rgb(255, 196, 87, 65), "Band #3", group=groupStyle, inline="bc")

showDashedHist = input.bool(true, "Show Previous VWAP Dashed", group=groupStyle)
histLineWidth  = input.int(1, "Dashed Line Width", minval=1, maxval=5, group=groupStyle)

//──────────────────────────────────────────────────────────────────────────────
// HELPERS
//──────────────────────────────────────────────────────────────────────────────
copyPoints(array<chart.point> src) =>
    array<chart.point> dst = array.new<chart.point>()
    int sz = array.size(src)
    if sz > 0
        for i = 0 to sz - 1
            chart.point p = array.get(src, i)
            array.push(dst, chart.point.from_index(p.index, p.price))
    dst

//──────────────────────────────────────────────────────────────────────────────
// INTERNAL CHoCH ENGINE
//──────────────────────────────────────────────────────────────────────────────
int bi = bar_index

iH = ta.pivothigh(high, internalPivotLen, internalPivotLen)
iL = ta.pivotlow(low, internalPivotLen, internalPivotLen)

var float iLastHigh = na
var float iLastLow = na
var int iLastHighBar = na
var int iLastLowBar = na
var bool iHighTaken = false
var bool iLowTaken = false
var int iTrend = 0

if not na(iH)
    iLastHigh := iH
    iLastHighBar := bar_index - internalPivotLen
    iHighTaken := false

if not na(iL)
    iLastLow := iL
    iLastLowBar := bar_index - internalPivotLen
    iLowTaken := false

iBullCloseBreak = ta.crossover(close, nz(iLastHigh, close + 1e10))
iBearCloseBreak = ta.crossunder(close, nz(iLastLow, close - 1e10))

iBullWickBreak = not na(iLastHigh) and high > iLastHigh and high[1] <= iLastHigh
iBearWickBreak = not na(iLastLow) and low < iLastLow and low[1] >= iLastLow

iBullBreak = confirmMode == "Close" ? iBullCloseBreak : iBullWickBreak
iBearBreak = confirmMode == "Close" ? iBearCloseBreak : iBearWickBreak

iBullChoch = showInternalChoch and iBullBreak and not iHighTaken and iTrend == -1
iBearChoch = showInternalChoch and iBearBreak and not iLowTaken and iTrend == 1

var line[] chochLines = array.new<line>()
var label[] chochLabels = array.new<label>()

drawChoch(int x1, float y, bool isBull) =>
    color css = isBull ? bullLineCol : bearLineCol
    line ln = line.new(x1, y, bar_index, y, color=css, width=1, style=line.style_dashed)

    label lb = label.new(
         int(math.avg(x1, bar_index)),
         y,
         "Internal CHoCH",
         color=color.new(color.white, 100),
         textcolor=css,
         style=isBull ? label.style_label_down : label.style_label_up,
         size=size.small,
         text_font_family=font.family_monospace
    )

    array.push(chochLines, ln)
    array.push(chochLabels, lb)

    if array.size(chochLines) > maxChochMarks
        line.delete(array.shift(chochLines))

    if array.size(chochLabels) > maxChochMarks
        label.delete(array.shift(chochLabels))

bool vwapAnchor = iBullChoch or iBearChoch

var int vwapDir = 0

if iBullChoch
    vwapDir := 1

if iBearChoch
    vwapDir := -1

int chochAnchorBar =
     iBullChoch ? iLastLowBar :
     iBearChoch ? iLastHighBar :
     na

float chochAnchorPrice =
     iBullChoch ? iLastLow :
     iBearChoch ? iLastHigh :
     na

if iBullBreak and not iHighTaken
    if iBullChoch and not na(iLastHighBar) and showChochLines
        drawChoch(iLastHighBar, iLastHigh, true)
    iTrend := 1
    iHighTaken := true

if iBearBreak and not iLowTaken
    if iBearChoch and not na(iLastLowBar) and showChochLines
        drawChoch(iLastLowBar, iLastLow, false)
    iTrend := -1
    iLowTaken := true

//──────────────────────────────────────────────────────────────────────────────
// CHoCH-ANCHORED VWAP + BANDS
//──────────────────────────────────────────────────────────────────────────────
type lineState
    array<chart.point> pts
    polyline line

var vwapPath = lineState.new(array.new<chart.point>(), na)

var upperBand1 = lineState.new(array.new<chart.point>(), na)
var lowerBand1 = lineState.new(array.new<chart.point>(), na)
var upperBand2 = lineState.new(array.new<chart.point>(), na)
var lowerBand2 = lineState.new(array.new<chart.point>(), na)
var upperBand3 = lineState.new(array.new<chart.point>(), na)
var lowerBand3 = lineState.new(array.new<chart.point>(), na)

var array<chart.point> prevPts = array.new<chart.point>()
var polyline prevPathLine = na

var float cumPV = na
var float cumP2V = na
var float cumVol = na
var bool vwapStarted = false

var label[] anchorDiamonds = array.new<label>()

if vwapAnchor and not na(chochAnchorBar) and not na(chochAnchorPrice)
    if not na(prevPathLine)
        polyline.delete(prevPathLine)

    if showDashedHist and vwapStarted and array.size(vwapPath.pts) >= 2
        prevPts := copyPoints(vwapPath.pts)
        prevPathLine := polyline.new(
             prevPts,
             false,
             false,
             xloc=xloc.bar_index,
             line_color=vwapDir[1] > 0 ? bullLineCol : bearLineCol,
             line_style=line.style_dashed,
             line_width=histLineWidth
        )

    if not na(vwapPath.line)
        polyline.delete(vwapPath.line)
    if not na(upperBand1.line)
        polyline.delete(upperBand1.line)
    if not na(lowerBand1.line)
        polyline.delete(lowerBand1.line)
    if not na(upperBand2.line)
        polyline.delete(upperBand2.line)
    if not na(lowerBand2.line)
        polyline.delete(lowerBand2.line)
    if not na(upperBand3.line)
        polyline.delete(upperBand3.line)
    if not na(lowerBand3.line)
        polyline.delete(lowerBand3.line)

    array.clear(vwapPath.pts)
    array.clear(upperBand1.pts)
    array.clear(lowerBand1.pts)
    array.clear(upperBand2.pts)
    array.clear(lowerBand2.pts)
    array.clear(upperBand3.pts)
    array.clear(lowerBand3.pts)

    if showSignal
        label anchorDiamond = label.new(
             chochAnchorBar,
             chochAnchorPrice,
             "◆",
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_none,
             textcolor=vwapDir > 0 ? bullLineCol : bearLineCol,
             color=color.new(color.white, 100),
             size=size.normal
        )

        array.push(anchorDiamonds, anchorDiamond)

        if array.size(anchorDiamonds) > maxChochMarks
            label.delete(array.shift(anchorDiamonds))

    int barsBackRaw = bi - chochAnchorBar
    int barsBack = math.min(math.max(barsBackRaw, 0), 5000)

    cumPV := 0.0
    cumP2V := 0.0
    cumVol := 0.0

    for i = barsBack to 0 by 1
        float priceInput = nz(vwapSource[i], close[i])
        float volInput = nz(volume[i], 0)
        float massInput = volInput > 0 ? volInput : 1.0

        cumPV += priceInput * massInput
        cumP2V += priceInput * priceInput * massInput
        cumVol += massInput

        float anchorVWAP = cumVol > 0 ? cumPV / cumVol : na
        float variance = cumVol > 0 ? math.max(cumP2V / cumVol - anchorVWAP * anchorVWAP, 0) : 0
        float stdev = math.sqrt(variance)
        float bandBasis = bandCalcMode == "Standard Deviation" ? stdev : anchorVWAP * 0.01

        int pointBar = bi - i

        array.push(vwapPath.pts, chart.point.from_index(pointBar, anchorVWAP))

        if showBand1
            array.push(upperBand1.pts, chart.point.from_index(pointBar, anchorVWAP + bandBasis * bandMult1))
            array.push(lowerBand1.pts, chart.point.from_index(pointBar, anchorVWAP - bandBasis * bandMult1))

        if showBand2
            array.push(upperBand2.pts, chart.point.from_index(pointBar, anchorVWAP + bandBasis * bandMult2))
            array.push(lowerBand2.pts, chart.point.from_index(pointBar, anchorVWAP - bandBasis * bandMult2))

        if showBand3
            array.push(upperBand3.pts, chart.point.from_index(pointBar, anchorVWAP + bandBasis * bandMult3))
            array.push(lowerBand3.pts, chart.point.from_index(pointBar, anchorVWAP - bandBasis * bandMult3))

    if array.size(vwapPath.pts) >= 2
        vwapPath.line := polyline.new(vwapPath.pts, false, false, xloc=xloc.bar_index, line_color=vwapDir > 0 ? bullLineCol : bearLineCol, line_width=lineWidth)

    if showBand1 and array.size(upperBand1.pts) >= 2
        upperBand1.line := polyline.new(upperBand1.pts, false, false, xloc=xloc.bar_index, line_color=bandCol1, line_width=bandLineWidth)
        lowerBand1.line := polyline.new(lowerBand1.pts, false, false, xloc=xloc.bar_index, line_color=bandCol1, line_width=bandLineWidth)

    if showBand2 and array.size(upperBand2.pts) >= 2
        upperBand2.line := polyline.new(upperBand2.pts, false, false, xloc=xloc.bar_index, line_color=bandCol2, line_width=bandLineWidth)
        lowerBand2.line := polyline.new(lowerBand2.pts, false, false, xloc=xloc.bar_index, line_color=bandCol2, line_width=bandLineWidth)

    if showBand3 and array.size(upperBand3.pts) >= 2
        upperBand3.line := polyline.new(upperBand3.pts, false, false, xloc=xloc.bar_index, line_color=bandCol3, line_width=bandLineWidth)
        lowerBand3.line := polyline.new(lowerBand3.pts, false, false, xloc=xloc.bar_index, line_color=bandCol3, line_width=bandLineWidth)

    vwapStarted := true

else if vwapStarted
    float priceInput = nz(vwapSource, close)
    float volInput = nz(volume, 0)
    float massInput = volInput > 0 ? volInput : 1.0

    cumPV := nz(cumPV, 0) + priceInput * massInput
    cumP2V := nz(cumP2V, 0) + priceInput * priceInput * massInput
    cumVol := nz(cumVol, 0) + massInput

    float anchorVWAP = cumVol > 0 ? cumPV / cumVol : na
    float variance = cumVol > 0 ? math.max(cumP2V / cumVol - anchorVWAP * anchorVWAP, 0) : 0
    float stdev = math.sqrt(variance)
    float bandBasis = bandCalcMode == "Standard Deviation" ? stdev : anchorVWAP * 0.01

    array.push(vwapPath.pts, chart.point.from_index(bi, anchorVWAP))

    if showBand1
        array.push(upperBand1.pts, chart.point.from_index(bi, anchorVWAP + bandBasis * bandMult1))
        array.push(lowerBand1.pts, chart.point.from_index(bi, anchorVWAP - bandBasis * bandMult1))

    if showBand2
        array.push(upperBand2.pts, chart.point.from_index(bi, anchorVWAP + bandBasis * bandMult2))
        array.push(lowerBand2.pts, chart.point.from_index(bi, anchorVWAP - bandBasis * bandMult2))

    if showBand3
        array.push(upperBand3.pts, chart.point.from_index(bi, anchorVWAP + bandBasis * bandMult3))
        array.push(lowerBand3.pts, chart.point.from_index(bi, anchorVWAP - bandBasis * bandMult3))

    if not na(vwapPath.line)
        polyline.delete(vwapPath.line)
    if not na(upperBand1.line)
        polyline.delete(upperBand1.line)
    if not na(lowerBand1.line)
        polyline.delete(lowerBand1.line)
    if not na(upperBand2.line)
        polyline.delete(upperBand2.line)
    if not na(lowerBand2.line)
        polyline.delete(lowerBand2.line)
    if not na(upperBand3.line)
        polyline.delete(upperBand3.line)
    if not na(lowerBand3.line)
        polyline.delete(lowerBand3.line)

    if array.size(vwapPath.pts) >= 2
        vwapPath.line := polyline.new(vwapPath.pts, false, false, xloc=xloc.bar_index, line_color=vwapDir > 0 ? bullLineCol : bearLineCol, line_width=lineWidth)

    if showBand1 and array.size(upperBand1.pts) >= 2
        upperBand1.line := polyline.new(upperBand1.pts, false, false, xloc=xloc.bar_index, line_color=bandCol1, line_width=bandLineWidth)
        lowerBand1.line := polyline.new(lowerBand1.pts, false, false, xloc=xloc.bar_index, line_color=bandCol1, line_width=bandLineWidth)

    if showBand2 and array.size(upperBand2.pts) >= 2
        upperBand2.line := polyline.new(upperBand2.pts, false, false, xloc=xloc.bar_index, line_color=bandCol2, line_width=bandLineWidth)
        lowerBand2.line := polyline.new(lowerBand2.pts, false, false, xloc=xloc.bar_index, line_color=bandCol2, line_width=bandLineWidth)

    if showBand3 and array.size(upperBand3.pts) >= 2
        upperBand3.line := polyline.new(upperBand3.pts, false, false, xloc=xloc.bar_index, line_color=bandCol3, line_width=bandLineWidth)
        lowerBand3.line := polyline.new(lowerBand3.pts, false, false, xloc=xloc.bar_index, line_color=bandCol3, line_width=bandLineWidth)

//──────────────────────────────────────────────────────────────────────────────
// TRACKING PERIOD
//──────────────────────────────────────────────────────────────────────────────
atrLen = 50
atrNow = ta.atr(atrLen)

//──────────────────────────────────────────────────────────────────────────────
// RR SYSTEM
//──────────────────────────────────────────────────────────────────────────────
bool buy = vwapAnchor and vwapDir > 0
bool sell = vwapAnchor and vwapDir < 0

var float entryPrice = na
var float SL = na
var float TP = na

var line entry_line = na
var line sl_line = na
var box tp_box = na

var label entry_lbl = na
var label sl_lbl = na
var label tp_lbl = na

var linefill risk_fill = na

if buy or sell
    entryPrice := close

    float pivotBuffer = syminfo.mintick * slPivotBufferTicks

    if sl_type == "ATR"
        SL := buy ? entryPrice - atrNow * sl_mult : entryPrice + atrNow * sl_mult
    else
        SL := buy ? iLastLow - pivotBuffer : iLastHigh + pivotBuffer

    bool validSL = buy ? not na(SL) and SL < entryPrice : not na(SL) and SL > entryPrice

    if validSL
        float risk = math.abs(entryPrice - SL)
        TP := buy ? entryPrice + risk * rr : entryPrice - risk * rr

        if not na(entry_line)
            line.delete(entry_line)
        if not na(sl_line)
            line.delete(sl_line)
        if not na(tp_box)
            box.delete(tp_box)
        if not na(risk_fill)
            linefill.delete(risk_fill)

        if not na(entry_lbl)
            label.delete(entry_lbl)
            entry_lbl := na
        if not na(sl_lbl)
            label.delete(sl_lbl)
            sl_lbl := na
        if not na(tp_lbl)
            label.delete(tp_lbl)
            tp_lbl := na

        entry_line := line.new(bar_index, entryPrice, bar_index, entryPrice, color=buy ? bullLineCol : bearLineCol, width=1)
        sl_line := line.new(bar_index, SL, bar_index, SL, color=color.rgb(137, 82, 255, 15), width=1)

        tp_box := box.new(
             bar_index, TP + atrNow * 0.2,
             bar_index, TP - atrNow * 0.2,
             bgcolor=color.rgb(0, 176, 230, 55),
             border_color=color.rgb(0, 176, 230, 55)
        )

        risk_fill := linefill.new(entry_line, sl_line, color.rgb(137, 82, 255, 84))

if not na(entry_line)
    line.set_x2(entry_line, bar_index)

if not na(sl_line)
    line.set_x2(sl_line, bar_index)

if not na(tp_box)
    box.set_right(tp_box, bar_index)

if not na(entry_line) and not na(entryPrice)
    if na(entry_lbl)
        entry_lbl := label.new(
             bar_index + labelOffset,
             entryPrice,
             "Entry: " + str.tostring(entryPrice, format.mintick),
             style=label.style_label_left,
             color=color.rgb(0, 176, 230, 54),
             textcolor=color.white
        )
    else
        label.set_xy(entry_lbl, bar_index + labelOffset, entryPrice)

if not na(sl_line) and not na(SL)
    if na(sl_lbl)
        sl_lbl := label.new(
             bar_index + labelOffset,
             SL,
             "SL: " + str.tostring(SL, format.mintick),
             style=label.style_label_left,
             color=color.rgb(137, 82, 255, 54),
             textcolor=color.white
        )
    else
        label.set_xy(sl_lbl, bar_index + labelOffset, SL)

if not na(tp_box) and not na(TP)
    if na(tp_lbl)
        tp_lbl := label.new(
             bar_index + labelOffset,
             TP,
             "TP: " + str.tostring(TP, format.mintick),
             style=label.style_label_left,
             color=color.rgb(0, 176, 230, 54),
             textcolor=color.white
        )
    else
        label.set_xy(tp_lbl, bar_index + labelOffset, TP)

//──────────────────────────────────────────────────────────────────────────────
// ALERTS
//──────────────────────────────────────────────────────────────────────────────
alertcondition(buy, "Bull CHoCH VWAP RR", "Bullish internal CHoCH anchored VWAP with RR setup.")
alertcondition(sell, "Bear CHoCH VWAP RR", "Bearish internal CHoCH anchored VWAP with RR setup.")
````
