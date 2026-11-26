# MJQ.Confluence Zones

- url: https://www.tradingview.com/script/1BQLfeL0-MJQ-Confluence-Zones/
- type: indicator
- pine_id: PUB;a7723ead7c9e4a64a126f9fb895c63ea
- version: 1.0

## Description

Changed name from RBD Confluence Zones

 New input group "Style v2" (appended last, existing inputs untouched):

  1. "Zone placement" — Rail / Span, default Rail. Zones no longer stretch back across the lookback window covering
  price action; they start a few bars right of the live candle and extend into the right margin as a level ladder.
  "Span" = legacy behavior.
  2. "Color by side of price" — bool, default on. Clusters above price draw in the supply color (pink #e91e63), below
  price in the demand color (cyan #00bcd4), straddling price gray — same palette as the SMC zone engine. Level count
  (x2/x3/x4+) is now shown by fill intensity and border width instead of aqua/fuchsia/yellow hues. Off = legacy colors.
  3. "Rail offset" — int, default 8. How many bars right of the live candle the rail begins.
  4. "Anchor zones near price to candles" — float ×ATR, default 1.0. A zone whose nearest edge is within this distance
  of the live close is in play: it extends back 12 bars over the candles with a solid border so you can watch price
  trade into it. Distant zones stay parked in the rail. 0 = pure rail.

## Source Code

````pine
//@version=6
indicator("MJQ.Confluence Zones", "MJQ.Confluence", overlay=true, max_boxes_count=100, max_lines_count=250, max_labels_count=200, max_bars_back=5000)

// =====================================================================
// CONFLUENCE ZONES
// Detects areas where 2+ important price levels cluster together.
// Levels: Weekly/Monthly/Quarterly/Yearly pivots, prev W/M/Q/Y/D highs/lows,
//         previous Weekly Market Profile VAH/VAL (TPO method).
// Historical: snapshots zones from past periods using levels active then.
// =====================================================================

// === INPUTS ===
g1 = "Levels to Include"
useW    = input.bool(true,  "Weekly Pivots (P, R1-R2, S1-S2)", group=g1)
useM    = input.bool(true,  "Monthly Pivots (P, R1-R2, S1-S2)", group=g1)
useQ    = input.bool(false, "Quarterly Pivots (P, R1-R2, S1-S2)", group=g1, tooltip="Quarterly classic-floor pivots — heavier S/R for swing/position trading on weekly+ charts")
useY    = input.bool(false, "Yearly Pivots (P, R1-R2, S1-S2)",    group=g1, tooltip="Yearly classic-floor pivots — heaviest S/R, primarily for monthly+ charts")
usePWH  = input.bool(true,  "Previous Week High/Low",  group=g1)
usePMH  = input.bool(true,  "Previous Month High/Low", group=g1)
usePQH  = input.bool(false, "Previous Quarter High/Low", group=g1, tooltip="Major swing-trade levels — recommended for monthly chart confluence")
usePYH  = input.bool(false, "Previous Year High/Low",   group=g1, tooltip="Yearly opening-range references — recommended for monthly chart confluence")
usePDH  = input.bool(false, "Previous Day High/Low",   group=g1)
useR3   = input.bool(false, "Include R3/S3 pivots",    group=g1)
useWkVA = input.bool(true,  "Previous Weekly MP VAH/VAL", group=g1, tooltip="Adds Weekly Market Profile Value Area High/Low to the confluence set (TPO, 20 bins, % below)")
vaPct   = input.float(0.70, "Weekly MP Value Area %", minval=0.50, maxval=0.95, step=0.05, group=g1)

g2 = "Confluence Detection"
mode    = input.string("ATR", "Proximity Mode", options=["ATR","Percent","Ticks"], group=g2, tooltip="How 'close together' is defined")
atrTF   = input.timeframe("D", "ATR Timeframe", group=g2, tooltip="Compute ATR on this timeframe (Daily by default). Higher TF makes zones consistent across chart timeframes.")
atrMult = input.float(0.15, "ATR Multiplier",  minval=0.05, step=0.05, group=g2, tooltip="MAX total width of a zone, in ATRs. All levels in a zone must fit within (ATR Multiplier x ATR). 0.15 x Daily ATR ~= the old 1.0 x 60-min ATR tuning, but works on every chart timeframe.")
atrLen  = input.int(14,     "ATR Length",      minval=1,    group=g2)
pctTh   = input.float(0.25, "Percent of Price (%)", minval=0.01, step=0.05, group=g2)
tickTh  = input.int(20,     "Ticks",           minval=1,    group=g2)
minLv   = input.int(2,      "Min Levels per Zone", minval=2, maxval=10, group=g2)

g3 = "Display"
showLines    = input.bool(false, "Show Individual Level Lines (debug)", group=g3, tooltip="Off by default. Turn on to see every pivot/level as a dotted full-width line.")
showLabels   = input.bool(true,  "Show Zone Labels",            group=g3)
extendR      = input.bool(true,  "Extend Zones to the Right",   group=g3)
lookbackDays = input.int(14,     "Zone Lookback (days)", minval=1, group=g3, tooltip="How far back current zones are drawn, in calendar days. Timeframe-independent. Only used in Span placement.")
borderWidth  = input.int(2,      "Zone Border Width",  minval=1, maxval=4, group=g3)
labelSize    = input.string("small", "Label Size", options=["small","normal","large"], group=g3)

zoneCol2   = input.color(color.new(color.aqua,    60), "Zone Fill (2 levels)",  group=g3)
borderCol2 = input.color(color.new(color.aqua,    20), "Zone Border (2 levels)",group=g3)
zoneCol3   = input.color(color.new(color.fuchsia, 50), "Zone Fill (3 levels)",  group=g3)
borderCol3 = input.color(color.new(color.fuchsia, 10), "Zone Border (3 levels)",group=g3)
zoneCol4   = input.color(color.new(color.yellow,  40), "Zone Fill (4+ levels)", group=g3)
borderCol4 = input.color(color.new(color.yellow,   0), "Zone Border (4+ levels)",group=g3)
lineCol    = input.color(color.new(color.gray,    55), "Level Line",            group=g3)

g4 = "Historical Zones"
showHist     = input.bool(false, "Show Historical Confluence Zones", group=g4, tooltip="Snapshots and locks confluence zones from past periods. Each period's zones use the levels that were active at the start of that period.")
histPeriods  = input.int(3, "Number of Past Periods to Show", minval=1, maxval=12, group=g4)
histPeriodTF = input.string("Auto", "History Period Length", options=["Auto","Weekly","Monthly","Quarterly"], group=g4, tooltip="Auto: D-or-smaller chart uses Weekly snapshots, larger charts use Monthly. Override to force a specific period length.")
histOpacity  = input.int(70, "Historical Zone Transparency %", minval=50, maxval=95, group=g4, tooltip="Higher = more transparent. Keeps history visually distinct from current zones.")
showHistLbls = input.bool(true, "Show Historical Zone Labels", group=g4)
histMinLv    = input.int(2,   "Historical Min Levels per Zone", minval=2, maxval=10, group=g4, tooltip="Independent threshold. Set higher than current to declutter (only strongest zones from past).")

// ── Style v2 (declared LAST so existing input indices stay stable across a re-add) ──
g5 = "Style v2"
zStyle   = input.string("Rail", "Zone placement", options=["Rail","Span"], group=g5,
     tooltip="Rail = zones hug the right edge: boxes start just right of the live candle and extend into the margin, leaving candles and SMC zones readable. Span = old behavior, boxes stretch back across the lookback window.")
sideCols = input.bool(true, "Color by side of price (S/D palette)", group=g5,
     tooltip="Confluence zones ARE supply/demand: zones above price use the supply color (pink), below price the demand color (cyan), straddling price neutral gray — same language as the SMC zone engine. Level count shows as fill intensity + border instead of different hues. Off = legacy aqua/fuchsia/yellow.")
railBars = input.int(8, "Rail offset (bars right of live candle)", minval=0, maxval=40, group=g5,
     tooltip="Rail placement: how many bars to the right of the live candle the zone boxes begin.")
hotATR   = input.float(1.0, "Anchor zones near price to candles (× ATR, 0 = off)", minval=0.0, step=0.25, group=g5,
     tooltip="Rail placement: a zone whose nearest edge is within this × ATR of the live close is IN PLAY — it extends back over the recent candles (and gets a solid border) so you can watch price trade into it. Distant zones stay parked in the rail. 0 = every zone stays in the rail.")

// Side-aware palette (matches RBD Smart Money + Auction Map)
COL_SUP = #e91e63
COL_DEM = #00bcd4
COL_NEU = #787b86

// === HTF DATA (previous period H/L/C) ===
[wH, wL, wC] = request.security(syminfo.tickerid, "W",   [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[mH, mL, mC] = request.security(syminfo.tickerid, "M",   [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[qH, qL, qC] = request.security(syminfo.tickerid, "3M",  [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[yH, yL, yC] = request.security(syminfo.tickerid, "12M", [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[dH, dL]     = request.security(syminfo.tickerid, "D",   [high[1], low[1]],           lookahead=barmerge.lookahead_on)

// =====================================================================
// WEEKLY MARKET PROFILE: VAH / VAL (TPO method, 20 bins)
// =====================================================================
isNewWeek = ta.change(time("W")) != 0

var int   wkBars = 0
var float wkH    = high
var float wkL    = low

if isNewWeek
    wkBars := 0
    wkH    := high
    wkL    := low
else
    wkBars := wkBars + 1
    if high > wkH
        wkH := high
    if low < wkL
        wkL := low

wkRange = wkH - wkL
tpoSec  = wkRange / 20.0

f_freq(_src, _up, _lo, _len) =>
    f = 0
    if _len >= 1
        for i = 0 to _len - 1
            if _src[i] >= _lo and _src[i] < _up
                f := f + 1
    f

var array<float> tpos = array.new<float>(0)
array.clear(tpos)
for i = 0 to 20
    upBound = wkH - tpoSec * i
    loBound = wkH - tpoSec * (i + 1)
    array.push(tpos, f_freq(close, upBound, loBound, wkBars))

tpoSum = array.sum(tpos)
pocVal = 0.0
pocPos = 0
for i = 0 to array.size(tpos) - 1
    v = array.get(tpos, i)
    if v >= pocVal
        pocVal := v
        pocPos := i

vahPos = pocPos
valPos = pocPos
curSum = pocVal
for i = 0 to 20
    if curSum < tpoSum * vaPct
        vahPos := math.max(0, vahPos - 1)
        curSum := curSum + array.get(tpos, vahPos)
    if curSum < tpoSum * vaPct
        valPos := math.min(20, valPos + 1)
        curSum := curSum + array.get(tpos, valPos)

wkVAH = wkH - tpoSec * vahPos
wkVAL = wkH - tpoSec * (valPos + 1)

var float prevWkVAH = na
var float prevWkVAL = na
if isNewWeek
    prevWkVAH := wkVAH[1]
    prevWkVAL := wkVAL[1]

// === PROXIMITY THRESHOLD ===
atrVal    = request.security(syminfo.tickerid, atrTF, ta.atr(atrLen), lookahead=barmerge.lookahead_on)
threshold = mode == "ATR"     ? atrVal * atrMult
          : mode == "Percent" ? close * pctTh / 100.0
          :                     tickTh * syminfo.mintick

// === LABEL SIZE ===
lblSize = labelSize == "small" ? size.small : labelSize == "large" ? size.large : size.normal

// === TIMEFRAME-AWARE LOOKBACK ===
secsPerBar    = timeframe.in_seconds(timeframe.period)
barsPerDay    = secsPerBar > 0 ? math.max(1, math.round(86400.0 / secsPerBar)) : 1
lookbackBars  = lookbackDays * barsPerDay

// =====================================================================
// HELPER FUNCTIONS
// =====================================================================

// Classic floor pivots from H/L/C
f_pivots(h, l, c) =>
    p   = (h + l + c) / 3.0
    r1  = 2 * p - l
    s1  = 2 * p - h
    r2  = p + (h - l)
    s2  = p - (h - l)
    r3  = h + 2 * (p - l)
    s3  = l - 2 * (h - p)
    [p, r1, s1, r2, s2, r3, s3]

// Build levels into vals/nms based on input toggles (used for both current & historical)
f_buildLevels(_wH, _wL, _wC, _mH, _mL, _mC, _qH, _qL, _qC, _yH, _yL, _yC, _dH, _dL, _vah, _val, vals, nms) =>
    if useW
        [p, r1, s1, r2, s2, r3, s3] = f_pivots(_wH, _wL, _wC)
        array.push(vals, p)
        array.push(nms,  "WP")
        array.push(vals, r1)
        array.push(nms,  "WR1")
        array.push(vals, s1)
        array.push(nms,  "WS1")
        array.push(vals, r2)
        array.push(nms,  "WR2")
        array.push(vals, s2)
        array.push(nms,  "WS2")
        if useR3
            array.push(vals, r3)
            array.push(nms,  "WR3")
            array.push(vals, s3)
            array.push(nms,  "WS3")
    if useM
        [p, r1, s1, r2, s2, r3, s3] = f_pivots(_mH, _mL, _mC)
        array.push(vals, p)
        array.push(nms,  "MP")
        array.push(vals, r1)
        array.push(nms,  "MR1")
        array.push(vals, s1)
        array.push(nms,  "MS1")
        array.push(vals, r2)
        array.push(nms,  "MR2")
        array.push(vals, s2)
        array.push(nms,  "MS2")
        if useR3
            array.push(vals, r3)
            array.push(nms,  "MR3")
            array.push(vals, s3)
            array.push(nms,  "MS3")
    if useQ
        [p, r1, s1, r2, s2, r3, s3] = f_pivots(_qH, _qL, _qC)
        array.push(vals, p)
        array.push(nms,  "QP")
        array.push(vals, r1)
        array.push(nms,  "QR1")
        array.push(vals, s1)
        array.push(nms,  "QS1")
        array.push(vals, r2)
        array.push(nms,  "QR2")
        array.push(vals, s2)
        array.push(nms,  "QS2")
        if useR3
            array.push(vals, r3)
            array.push(nms,  "QR3")
            array.push(vals, s3)
            array.push(nms,  "QS3")
    if useY
        [p, r1, s1, r2, s2, r3, s3] = f_pivots(_yH, _yL, _yC)
        array.push(vals, p)
        array.push(nms,  "YP")
        array.push(vals, r1)
        array.push(nms,  "YR1")
        array.push(vals, s1)
        array.push(nms,  "YS1")
        array.push(vals, r2)
        array.push(nms,  "YR2")
        array.push(vals, s2)
        array.push(nms,  "YS2")
        if useR3
            array.push(vals, r3)
            array.push(nms,  "YR3")
            array.push(vals, s3)
            array.push(nms,  "YS3")
    if usePWH
        array.push(vals, _wH)
        array.push(nms,  "PWH")
        array.push(vals, _wL)
        array.push(nms,  "PWL")
    if usePMH
        array.push(vals, _mH)
        array.push(nms,  "PMH")
        array.push(vals, _mL)
        array.push(nms,  "PML")
    if usePQH
        array.push(vals, _qH)
        array.push(nms,  "PQH")
        array.push(vals, _qL)
        array.push(nms,  "PQL")
    if usePYH
        array.push(vals, _yH)
        array.push(nms,  "PYH")
        array.push(vals, _yL)
        array.push(nms,  "PYL")
    if usePDH
        array.push(vals, _dH)
        array.push(nms,  "PDH")
        array.push(vals, _dL)
        array.push(nms,  "PDL")
    if useWkVA and not na(_vah) and not na(_val)
        array.push(vals, _vah)
        array.push(nms,  "WVAH")
        array.push(vals, _val)
        array.push(nms,  "WVAL")

// Sort + cluster levels into zone arrays. Total-span constraint: a level joins
// a zone only if within `_thresh` of the zone's LOWEST member.
f_cluster(vals, nms, _thresh, _minLv, zLo, zHi, zNm, zCt) =>
    n = array.size(vals)
    if n > 1
        for i = 0 to n - 2
            for j = 0 to n - i - 2
                if array.get(vals, j) > array.get(vals, j + 1)
                    tv = array.get(vals, j)
                    tn = array.get(nms,  j)
                    array.set(vals, j,     array.get(vals, j + 1))
                    array.set(nms,  j,     array.get(nms,  j + 1))
                    array.set(vals, j + 1, tv)
                    array.set(nms,  j + 1, tn)
    if n > 0
        gLow   = array.get(vals, 0)
        gHigh  = array.get(vals, 0)
        gNames = array.get(nms,  0)
        gCount = 1
        if n > 1
            for i = 1 to n - 1
                cur = array.get(vals, i)
                if cur - gLow <= _thresh
                    gHigh  := cur
                    gNames := gNames + " + " + array.get(nms, i)
                    gCount := gCount + 1
                else
                    if gCount >= _minLv
                        array.push(zLo, gLow)
                        array.push(zHi, gHigh)
                        array.push(zNm, gNames)
                        array.push(zCt, gCount)
                    gLow   := cur
                    gHigh  := cur
                    gNames := array.get(nms, i)
                    gCount := 1
        if gCount >= _minLv
            array.push(zLo, gLow)
            array.push(zHi, gHigh)
            array.push(zNm, gNames)
            array.push(zCt, gCount)

// === STATE ARRAYS (current zones) ===
var array<float>  vals  = array.new<float>()
var array<string> nms   = array.new<string>()
var array<line>   lines = array.new<line>()
var array<box>    boxes = array.new<box>()
var array<label>  lbls  = array.new<label>()
var array<float>  zLo   = array.new<float>()
var array<float>  zHi   = array.new<float>()
var array<string> zNm   = array.new<string>()
var array<int>    zCt   = array.new<int>()

// === HISTORICAL ZONE STATE ===
// Levels captured at the START of the current in-progress period. When the next
// period starts, these become the "active levels" for the just-ended period and
// are used to draw the historical zone box spanning that period.
var float storedWH    = na
var float storedWL    = na
var float storedWC    = na
var float storedMH    = na
var float storedML    = na
var float storedMC    = na
var float storedQH    = na
var float storedQL    = na
var float storedQC    = na
var float storedYH    = na
var float storedYL    = na
var float storedYC    = na
var float storedDH    = na
var float storedDL    = na
var float storedVAH   = na
var float storedVAL   = na
var float storedATR   = na
var float storedClose = na
var int   storedStart = na

var array<box>   histBoxes     = array.new<box>()
var array<label> histLabels    = array.new<label>()
var array<int>   histBoxPeriod = array.new<int>()
var array<int>   histLblPeriod = array.new<int>()
var int          histPeriodCt  = 0

// === DETERMINE HISTORY PERIOD ===
isNewMonthChk   = ta.change(time("M"))  != 0
isNewQuarterChk = ta.change(time("3M")) != 0
chartSec        = timeframe.in_seconds(timeframe.period)
autoUseWeekly   = histPeriodTF == "Auto" and chartSec <= 86400
isNewHistPeriod = (histPeriodTF == "Weekly" or autoUseWeekly) ? isNewWeek : histPeriodTF == "Quarterly" ? isNewQuarterChk : isNewMonthChk

// === SNAPSHOT JUST-ENDED PERIOD AS HISTORICAL ===
if isNewHistPeriod and barstate.isconfirmed
    // Draw zones for the period that just ended, using levels captured at its start
    if showHist and not na(storedWH) and not na(storedStart)
        sVals = array.new<float>()
        sNms  = array.new<string>()
        f_buildLevels(storedWH, storedWL, storedWC, storedMH, storedML, storedMC, storedQH, storedQL, storedQC, storedYH, storedYL, storedYC, storedDH, storedDL, storedVAH, storedVAL, sVals, sNms)

        sThresh = mode == "ATR" ? storedATR * atrMult : mode == "Percent" ? storedClose * pctTh / 100.0 : tickTh * syminfo.mintick

        sLo = array.new<float>()
        sHi = array.new<float>()
        sNm = array.new<string>()
        sCt = array.new<int>()
        f_cluster(sVals, sNms, sThresh, histMinLv, sLo, sHi, sNm, sCt)

        if array.size(sLo) > 0
            histLeft  = storedStart
            histRight = bar_index - 1
            for k = 0 to array.size(sLo) - 1
                lo = array.get(sLo, k)
                hi = array.get(sHi, k)
                nm = array.get(sNm, k)
                ct = array.get(sCt, k)
                baseBg = ct >= 4 ? color.yellow : ct >= 3 ? color.fuchsia : color.aqua
                bgC  = color.new(baseBg, histOpacity)
                brdC = color.new(baseBg, math.max(0, histOpacity - 25))
                b = box.new(histLeft, hi, histRight, lo, border_color=brdC, border_width=1, bgcolor=bgC, border_style=line.style_dashed)
                array.push(histBoxes, b)
                array.push(histBoxPeriod, histPeriodCt)
                if showHistLbls
                    lblBg = color.new(baseBg, math.max(0, histOpacity - 15))
                    lblTx = ct >= 4 ? color.black : color.white
                    lb = label.new(histRight, (hi + lo) / 2.0, nm + " x" + str.tostring(ct), style=label.style_label_left, color=lblBg, textcolor=lblTx, size=size.small)
                    array.push(histLabels, lb)
                    array.push(histLblPeriod, histPeriodCt)

        histPeriodCt := histPeriodCt + 1

        // Prune: drop boxes/labels from periods older than histPeriods back
        oldestKept = histPeriodCt - histPeriods
        while array.size(histBoxes) > 0 and array.get(histBoxPeriod, 0) < oldestKept
            box.delete(array.shift(histBoxes))
            array.shift(histBoxPeriod)
        while array.size(histLabels) > 0 and array.get(histLblPeriod, 0) < oldestKept
            label.delete(array.shift(histLabels))
            array.shift(histLblPeriod)

    // Capture levels for the just-started period (used when IT ends)
    storedWH    := wH
    storedWL    := wL
    storedWC    := wC
    storedMH    := mH
    storedML    := mL
    storedMC    := mC
    storedQH    := qH
    storedQL    := qL
    storedQC    := qC
    storedYH    := yH
    storedYL    := yL
    storedYC    := yC
    storedDH    := dH
    storedDL    := dL
    storedVAH   := prevWkVAH
    storedVAL   := prevWkVAL
    storedATR   := atrVal
    storedClose := close
    storedStart := bar_index

// === CLEAR HISTORICAL DRAWINGS IF TOGGLED OFF ===
if not showHist and (array.size(histBoxes) > 0 or array.size(histLabels) > 0)
    if array.size(histBoxes) > 0
        for i = 0 to array.size(histBoxes) - 1
            box.delete(array.get(histBoxes, i))
        array.clear(histBoxes)
        array.clear(histBoxPeriod)
    if array.size(histLabels) > 0
        for i = 0 to array.size(histLabels) - 1
            label.delete(array.get(histLabels, i))
        array.clear(histLabels)
        array.clear(histLblPeriod)

// === CURRENT ZONES (drawn fresh on last bar) ===
if barstate.islast
    array.clear(vals)
    array.clear(nms)
    array.clear(zLo)
    array.clear(zHi)
    array.clear(zNm)
    array.clear(zCt)
    if array.size(lines) > 0
        for i = 0 to array.size(lines) - 1
            line.delete(array.get(lines, i))
        array.clear(lines)
    if array.size(boxes) > 0
        for i = 0 to array.size(boxes) - 1
            box.delete(array.get(boxes, i))
        array.clear(boxes)
    if array.size(lbls) > 0
        for i = 0 to array.size(lbls) - 1
            label.delete(array.get(lbls, i))
        array.clear(lbls)

    f_buildLevels(wH, wL, wC, mH, mL, mC, qH, qL, qC, yH, yL, yC, dH, dL, prevWkVAH, prevWkVAL, vals, nms)

    n = array.size(vals)
    // Rail placement: zones live in the right margin, clear of candles and SMC boxes.
    // Span placement: legacy lookback stretch.
    leftX  = zStyle == "Rail" ? bar_index + railBars : bar_index - lookbackBars
    rightX = zStyle == "Rail" ? bar_index + railBars + 24 : extendR ? bar_index + 20 : bar_index

    if showLines and n > 0
        for i = 0 to n - 1
            v  = array.get(vals, i)
            ln = line.new(bar_index, v, bar_index + 1, v, color=lineCol, style=line.style_dotted, extend=extend.both)
            array.push(lines, ln)

    f_cluster(vals, nms, threshold, minLv, zLo, zHi, zNm, zCt)

    if array.size(zLo) > 0
        for i = 0 to array.size(zLo) - 1
            lo = array.get(zLo, i)
            hi = array.get(zHi, i)
            nm = array.get(zNm, i)
            ct = array.get(zCt, i)
            // Side-aware palette: above price = supply, below = demand, straddling = neutral.
            // Strength (level count) maps to fill intensity + border, not hue.
            color sideC = lo > close ? COL_SUP : hi < close ? COL_DEM : COL_NEU
            // In-play zones (within hotATR x ATR of the live close) leave the rail and
            // anchor back over the recent candles so the live touch is visible.
            float distToZone = close > hi ? close - hi : lo > close ? lo - close : 0.0
            bool  hot = zStyle == "Rail" and hotATR > 0 and distToZone <= hotATR * atrVal
            int   leftXz = hot ? bar_index - 12 : leftX
            bgC  = sideCols ? color.new(sideC, ct >= 4 ? 72 : ct >= 3 ? 82 : 92) : ct >= 4 ? zoneCol4   : ct >= 3 ? zoneCol3   : zoneCol2
            brdC = sideCols ? color.new(sideC, hot ? 0 : ct >= 4 ? 0  : ct >= 3 ? 25 : 50) : ct >= 4 ? borderCol4 : ct >= 3 ? borderCol3 : borderCol2
            b = box.new(leftXz, hi, rightX, lo, border_color=brdC, border_width=ct >= 4 ? borderWidth + 1 : borderWidth, bgcolor=bgC, extend=extendR ? extend.right : extend.none)
            array.push(boxes, b)
            if showLabels
                lblBg = sideCols ? color.new(sideC, 25) : ct >= 4 ? color.new(color.yellow, 0) : ct >= 3 ? color.new(color.fuchsia, 0) : color.new(color.aqua, 0)
                lblTx = sideCols ? color.white : ct >= 4 ? color.black : color.white
                lb = label.new(rightX, (hi + lo) / 2.0, nm + "  x" + str.tostring(ct), style=label.style_label_left, color=lblBg, textcolor=lblTx, size=lblSize)
                array.push(lbls, lb)
````
