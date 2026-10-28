# Technofunda 

- url: https://www.tradingview.com/script/tbs4qvVe-Technofunda/
- type: indicator
- pine_id: PUB;92c7ee8a0adc4006bb941e8a36f9e886
- version: 4.0

## Description

Here's what the **Technofunda Dashboard** indicator does, feature by feature:

**1. VStop (Volatility Stop) — feature 1**
ATR(20) × 2 trailing stop, plotted as dots that track price: green dots below the candles when the trend is positive (LONG), red dots above when negative (SHORT). It flips when price crosses the stop. Built with na-safe guards so it computes correctly from the start.

**2. Auto-switching moving averages — feature 5**
The indicator detects your timeframe automatically: on a daily chart it shows 21 / 50 / 200 **SMA**; on a weekly chart it switches to 10 / 20 / 40 **EMA**. Three lines — fast (aqua), medium (orange), trend (fuchsia).

**3. Distance from the MAs — feature 2**
A table (top-right) shows how far price is from each MA, measured down from price to the MA as a % of price — positive when above, negative when below, colour-coded green/red.

**4. Weinstein Stage — feature 3**
Classifies the stock into Stage 1 (Basing), 2 (Advancing), 3 (Topping) or 4 (Declining) using the long-term MA (200 DMA / 40W EMA) and its slope: price above + MA rising = Stage 2, etc. Shown in the table, colour-coded.

**5. 52-week high / low — feature 4**
Green triangle above a bar that makes a new 52-week high, red triangle below a bar that makes a new 52-week low (252 bars on daily, 52 on weekly). The table also shows current distance to the 52W high and low.

**6. Relative strength vs Nifty 500 — feature 6**
Compares the stock to a benchmark (default `NSE:CNX500`) over a lookback window. The chart background tints light green when outperforming, light red when underperforming, and the table shows OUTPERFORM / UNDERPERFORM.

**7. Per-candle letter states — feature 7**
Each candle is tagged with one letter based on its live condition:

- **A** — VStop positive (baseline / just flipped up)
- **B** — positive *and* beating Nifty 500 by ≥5%
- **C** — positive *and* beating Nifty 500 by ≥10%
- **X** — VStop negative (baseline)
- **Y** — negative *and* price below the medium MA (20W EMA / 50 DMA)
- **Z** — negative *and* price below the slow MA (40W EMA / 200 DMA)

Higher tiers win (a stock up 12% shows C, not A+B+C; one below the 40W EMA shows Z, not X+Y). The 5% / 10% thresholds are adjustable inputs.

**Extras**
A summary table consolidating MA distances, Stage, VStop status, RS status and 52W proximity; alerts for VStop flips and new 52-week highs/lows; and editable inputs for ATR length/multiplier, benchmark symbol, RS lookback, B/C thresholds, and MA slope length.

## Source Code

````pine
//@version=6
// =====================================================================
//  TECHNOFUNDA DASHBOARD
//  VStop + Auto MAs + Weinstein Stage + 52W Hi/Lo + Relative Strength
//  Designed for Indian small/mid-cap swing trading (daily & weekly)
// =====================================================================
indicator("Technofunda Dashboard v5.9 (One-Rule Dow)", overlay=true, max_labels_count=500)

// ----------------------------- INPUTS --------------------------------
grpV   = "VStop"
atrLen   = input.int(10,  "VStop ATR Length",     group=grpV, minval=1)
atrMult  = input.float(2.0,"VStop Multiplier",     group=grpV, minval=0.1, step=0.1)

grpRS  = "Relative Strength"
benchSym = input.symbol("NSE:CNX500", "Benchmark (Nifty 500)", group=grpRS)
rsLen    = input.int(26,  "RS Lookback (bars)",   group=grpRS, minval=1)
showLetters = input.bool(false, "Show A/B/C - X/Y/Z letters", group=grpRS)


grpST  = "Stage"
slopeLen = input.int(5,   "MA Slope Lookback",     group=grpST, minval=1)

grpSW  = "Swing Low (Investing Stop)"
swingMode    = input.string("Dow swing", "Swing-low rule", group=grpSW, options=["Dow swing","Most recent swing low"])
swingTF      = input.timeframe("W", "Swing timeframe (blank = chart TF)", group=grpSW, tooltip="Default W = swing low pinned to WEEKLY everywhere (incl. Pine Screener), regardless of chart timeframe. Set blank to compute on the chart's own timeframe (daily on daily, weekly on weekly), or D to pin daily.")
showSwing    = input.bool(true, "Show swing-low dots", group=grpSW)
swingDotCol  = input.color(color.purple, "Dot colour", group=grpSW)
swingDotSize = input.int(2, "Dot size (points)", group=grpSW, minval=1, maxval=40, tooltip="Numeric size: ~5-6 is just above Auto, ~12 is Tiny. Tune to taste.")
pivLW        = input.int(1, "Weekly Pivot Left bars",  group=grpSW, minval=1, tooltip="Structure definition on weekly. 1/1 marks every 1-week dip; 2/1 or 2/2 = only multi-week consolidation lows count. This is the engine's only dial.")
pivRW        = input.int(1, "Weekly Pivot Right bars", group=grpSW, minval=1)
pivLD        = input.int(5, "Daily Pivot Left bars",   group=grpSW, minval=1)
pivRD        = input.int(2, "Daily Pivot Right bars",  group=grpSW, minval=1)
// Resolve per computation context
pivL_chart   = timeframe.isweekly ? pivLW : pivLD
pivR_chart   = timeframe.isweekly ? pivRW : pivRD
swTFisW      = swingTF == "" ? timeframe.isweekly : timeframe.in_seconds(swingTF) >= timeframe.in_seconds("1W")
pivL_sw      = swTFisW ? pivLW : pivLD
pivR_sw      = swTFisW ? pivRW : pivRD

grpTbl = "Table"
showTable = input.bool(true, "Show table", group=grpTbl)
tblPosStr = input.string("Top Right", "Position", group=grpTbl, options=["Top Right","Top Left","Top Center","Middle Right","Middle Left","Bottom Right","Bottom Left","Bottom Center"])
tblSizeStr= input.string("Normal", "Text size", group=grpTbl, options=["Tiny","Small","Normal","Large","Huge"])
rowStage  = input.bool(true, "Row: Stage",       group=grpTbl)
rowFast   = input.bool(true, "Row: Fast MA",     group=grpTbl)
rowSwingD = input.bool(true, "Row: Swing Low D", group=grpTbl)
rowSwingW = input.bool(true, "Row: Swing Low W", group=grpTbl)
rowVStop  = input.bool(true, "Row: VStop",       group=grpTbl)
rowTrend  = input.bool(true, "Row: Trend MA",    group=grpTbl)
rowRS     = input.bool(true, "Row: RS vs N500",  group=grpTbl)

// ------------------- AUTO TIMEFRAME MA SELECTION ---------------------
// Daily  -> 21 / 50 / 200 SMA   |   Weekly -> 10 / 20 / 40 EMA
isWk   = timeframe.isweekly
len1   = isWk ? 10  : 21
len2   = isWk ? 20  : 50
len3   = isWk ? 40  : 200

ma1 = isWk ? ta.ema(close, len1) : ta.sma(close, len1)
ma2 = isWk ? ta.ema(close, len2) : ta.sma(close, len2)
ma3 = isWk ? ta.ema(close, len3) : ta.sma(close, len3)   // long-term trend filter

nm1 = (isWk ? "10W EMA"  : "21 DMA")
nm2 = (isWk ? "20W EMA"  : "50 DMA")
nm3 = (isWk ? "40W EMA"  : "200 DMA")

plot(ma1, "10W EMA",  color=color.blue,   linewidth=1)
plot(ma2, "20W EMA",  color=color.orange, linewidth=1, display=display.none)
plot(ma3, "40W EMA",  color=color.red,    linewidth=2)

// ----------------------- 1) VOLATILITY STOP --------------------------
volStop(src, length, factor) =>
    var bool  uptrend = true
    var float maxv    = src
    var float minv    = src
    var float stop    = na
    atrM = nz(ta.atr(length) * factor, ta.tr)                       // na-safe ATR band
    maxv := math.max(maxv, src)
    minv := math.min(minv, src)
    stop := nz(uptrend ? math.max(stop, maxv - atrM) : math.min(stop, minv + atrM), src)  // na-safe stop
    bool prevUp = uptrend   // var holds previous bar's value before reassignment
    uptrend := src - stop >= 0.0
    if uptrend != prevUp
        maxv := src
        minv := src
        stop := uptrend ? maxv - atrM : minv + atrM
    [stop, uptrend]

[vstop, upTrend] = volStop(close, atrLen, atrMult)

// Green + tracks price in uptrend (below candles), red + in downtrend (above)
plot(vstop, "VStop", color = upTrend ? color.new(color.green,0) : color.new(color.red,0), style=plot.style_cross, linewidth=2)

flipUp = upTrend and not upTrend[1]
flipDn = not upTrend and upTrend[1]
// Weeks since the VStop flipped: +N = N bars in the green flip (flip bar = 1),
// -N = N bars in the red flip. Hidden on chart; for Pine Screener / CSV.
flipAge = ta.barssince(flipUp or flipDn)
vstopFlipWks = na(flipAge) ? na : upTrend ? flipAge + 1 : -(flipAge + 1)
plot(vstopFlipWks, "VStop Flip Wks", color=color.teal, display=display.none, editable=false)

// ----------------- 6) RELATIVE STRENGTH vs NIFTY 500 -----------------
bench   = request.security(benchSym, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
ratio   = bench != 0 ? close / bench : na
rsPct   = (not na(ratio) and not na(ratio[rsLen]) and ratio[rsLen] != 0) ? (ratio / ratio[rsLen] - 1) * 100 : na   // % out/under-performance vs benchmark over lookback
beating = not na(rsPct) and rsPct > 0   // outperforming over lookback

bgcolor(beating ? color.new(color.green, 93) : color.new(color.red, 93), title="RS Background")

// --------- 7) PER-CANDLE LETTER STATE (A/B/C up, X/Y/Z down) ----------
// Thresholds (% out-performance vs Nifty 500 over RS lookback)
thrB = input.float(5.0,  "B threshold: beat N500 by %", group=grpRS, minval=0)
thrC = input.float(10.0, "C threshold: beat N500 by %", group=grpRS, minval=0)

// GREEN (VStop positive) - highest qualifying tier wins:
//   C = positive & beating N500 by >= thrC%
//   B = positive & beating N500 by >= thrB%
//   A = positive (baseline / just flipped up)
isC = upTrend and not na(rsPct) and rsPct >= thrC
isB = upTrend and not na(rsPct) and rsPct >= thrB and rsPct < thrC
isA = upTrend and not isB and not isC

// RED (VStop negative) - most bearish tier wins:
//   Z = negative & close below SLOW MA   (40W EMA / 200 DMA)
//   Y = negative & close below MEDIUM MA (20W EMA / 50 DMA)
//   X = negative (baseline / just flipped down)
isZ = (not upTrend) and close < ma3
isY = (not upTrend) and close < ma2 and not isZ
isX = (not upTrend) and not isY and not isZ

// Letters drawn as labels (not plots) so they do NOT appear as Pine
// Screener columns. Visible for the most recent ~500 bars.
if showLetters
    ltr = isA ? "A" : isB ? "B" : isC ? "C" : isX ? "X" : isY ? "Y" : isZ ? "Z" : ""
    if ltr != ""
        label.new(bar_index, na, ltr,
             yloc      = (isX or isY or isZ) ? yloc.abovebar : yloc.belowbar,
             style     = label.style_none,
             textcolor = isA ? color.new(color.blue, 0) : isB ? color.new(color.green, 0) : isC ? color.new(color.teal, 0) : isX ? color.new(color.orange, 0) : isY ? color.new(color.red, 0) : color.new(color.maroon, 0),
             size      = size.tiny)

// --------------------- 4) 52-WEEK HIGH / LOW -------------------------
// Daily ~ 252 bars, Weekly = 52 bars
len52 = isWk ? 52 : 252
hi52  = ta.highest(high, len52)
lo52  = ta.lowest(low,  len52)
newHi = high >= hi52
newLo = low  <= lo52

showHiLo = input.bool(true, "Show 52W High/Low triangles", group="52 Week High/Low")
plotshape(showHiLo and newHi, "New 52W High", style=shape.triangleup,   location=location.abovebar, color=color.new(color.blue,0), size=size.tiny)
plotshape(showHiLo and newLo, "New 52W Low",  style=shape.triangledown, location=location.belowbar, color=color.new(color.black,0),   size=size.tiny)

// ------------------ 3) WEINSTEIN STAGE (1-4) -------------------------
// Uses the long-term trend MA (200 DMA / 40W EMA) + its slope
maRising = ma3 > ma3[slopeLen]
above    = close > ma3
stageNum = above and maRising        ? 2 :   // Advancing
           above and not maRising     ? 1 :   // Basing
           not above and maRising      ? 3 :   // Topping
           4                                   // Declining
stageTxt = stageNum == 2 ? "Stage 2 - Advancing" :
           stageNum == 1 ? "Stage 1 - Basing"    :
           stageNum == 3 ? "Stage 3 - Topping"   :
                           "Stage 4 - Declining"
stageCol = stageNum == 2 ? color.green :
           stageNum == 1 ? color.gray  :
           stageNum == 3 ? color.orange : color.red

// --------- SWING LOW (investing stop) — ONE-RULE DOW STRUCTURE -------
// RULES (Imran's, v5.4):
//   A swing low is born when the structure above it breaks. Two ways:
//   (1) NEW LEG HIGH: price exceeds the leg's running high -> the lowest
//       unvalidated pivot low beneath becomes the swing low. This is the
//       trend path: any pivot dip + the next new high = registered.
//       Vertical trends can never starve the engine.
//   (2) BOUNCE-TOP BREAK: price breaks the most recent CONFIRMED pivot
//       high -> same validation, and the running high RESETS to this bar.
//       This is the recovery path: after a decline the old peak is
//       unreachable, so breaking a completed lower high validates the
//       base (the flip) and starts a fresh leg.
//   - Candidates accumulate as the LOWEST pivot low since the last
//     validation (the consolidation's true low; interior dips never win).
//   - In a decline neither trigger fires, so the broken level HOLDS and
//     reads NEGATIVE — price weakness is information. Lows validated by
//     dead-cat bounce-top breaks move the swing low DOWN, as they should.
//   - A rally candle's own low can never be selected (never a pivot).
//   - Pivot L/R (weekly / daily separately) is the only dial. No MAs.
// (MOST RECENT mode just sits on the latest pivot low.)
f_dowSwingLow(simple int l, simple int r, simple string mode) =>
    var float sl      = na
    var int   slT     = na   // time of the candle that MADE the swing low
    var float boxTop  = na   // most recent confirmed pivot high (bounce top)
    var float legHigh = na   // the leg's running high
    var pendV = array.new_float()  // PENDING pivot lows, ascending (oldest/lowest first)
    var pendT = array.new_int()    // each stays queued until VALIDATED or BROKEN
    ph  = ta.pivothigh(high, l, r)
    plv = ta.pivotlow(low,  l, r)
    if mode == "Most recent swing low"
        if not na(plv)
            sl  := plv
            slT := time[r]
    else
        if not na(ph)
            boxTop := ph
        // PRUNE: any pending low that price has traded below is dead structure
        while array.size(pendV) > 0 and low < array.get(pendV, array.size(pendV) - 1)
            array.pop(pendV)
            array.pop(pendT)
        // QUEUE the newly confirmed pivot low
        if not na(plv) and (array.size(pendV) == 0 or plv > array.get(pendV, array.size(pendV) - 1))
            array.push(pendV, plv)
            array.push(pendT, time[r])
        // VALIDATION: new leg high OR confirmed bounce-top break ->
        // the LOWEST pending low becomes the swing low; higher pendings
        // stay queued for the next trigger (nothing is ever skipped)
        trig = (not na(legHigh) and high > legHigh) or (not na(boxTop) and high > boxTop)
        if trig
            if array.size(pendV) > 0
                sl  := array.shift(pendV)
                slT := array.shift(pendT)
            boxTop  := na
            legHigh := high              // ratchet (trend) or RESET (recovery flip)
        else
            legHigh := na(legHigh) ? high : math.max(legHigh, high)
    [sl, slT]

// Blank swing TF = compute on the chart's own timeframe (daily on D, weekly on W)
useChartTF = swingTF == "" or swingTF == timeframe.period
[swingLowChart, swingLowTChart] = f_dowSwingLow(pivL_chart, pivR_chart, swingMode)
[swingLowReq,   swingLowTReq]   = request.security(syminfo.tickerid, swingTF == "" ? timeframe.period : swingTF, f_dowSwingLow(pivL_sw, pivR_sw, swingMode), lookahead=barmerge.lookahead_off)
swingLow  = useChartTF ? swingLowChart  : swingLowReq
swingLowT = useChartTF ? swingLowTChart : swingLowTReq

// Daily & Weekly swing lows for the table (engine unchanged, just computed on D and W)
[swingLowD, swingLowDT] = request.security(syminfo.tickerid, "D", f_dowSwingLow(pivLD, pivRD, swingMode), lookahead=barmerge.lookahead_off)
[swingLowW, swingLowWT] = request.security(syminfo.tickerid, "W", f_dowSwingLow(pivLW, pivRW, swingMode), lookahead=barmerge.lookahead_off)

// Invisible plot: exposes Swing Low to Pine Screener / alerts / CSV export
// (fully transparent on the chart; the dot below remains the visual)
plot(swingLow, "Swing Low", color=color.purple, display=display.none, editable=false)

// ONE dot, placed under the LOW of the candle that made the swing low.
newSwingLow = not na(swingLow) and (na(swingLow[1]) or swingLow != swingLow[1])
if showSwing and newSwingLow and not na(swingLowT)
    label.new(x=swingLowT, y=na, xloc=xloc.bar_time, yloc=yloc.belowbar, style=label.style_circle, color=swingDotCol, size=swingDotSize)

// ---------------- 2) INFO TABLE (fully customisable) ----------------
pct(p, m) => p != 0 ? (p - m) / p * 100 : na   // distance measured down from price to the MA, as % of price
f2(x) => str.tostring(x, "#.##") + "%"
fv(x) => str.tostring(x, format.mintick)        // price level at the symbol's tick size

// Map position / size inputs to constants
tblPos = tblPosStr == "Top Left"      ? position.top_left :
         tblPosStr == "Top Center"    ? position.top_center :
         tblPosStr == "Top Right"     ? position.top_right :
         tblPosStr == "Middle Left"   ? position.middle_left :
         tblPosStr == "Middle Right"  ? position.middle_right :
         tblPosStr == "Bottom Left"   ? position.bottom_left :
         tblPosStr == "Bottom Center" ? position.bottom_center : position.bottom_right
tblSize = tblSizeStr == "Tiny"  ? size.tiny  :
          tblSizeStr == "Small" ? size.small :
          tblSizeStr == "Large" ? size.large :
          tblSizeStr == "Huge"  ? size.huge  : size.normal

nrows = (rowStage?1:0) + (rowFast?1:0) + (rowSwingD?1:0) + (rowSwingW?1:0) + (rowVStop?1:0) + (rowTrend?1:0) + (rowRS?1:0)

if barstate.islast and showTable and nrows > 0
    table t = table.new(tblPos, 2, nrows, bgcolor=color.new(color.black,15), border_color=color.gray, border_width=1, frame_color=color.gray, frame_width=1)
    r = 0
    if rowStage
        table.cell(t, 0, r, "Stage", text_color=color.white, text_size=tblSize)
        table.cell(t, 1, r, stageTxt, text_color=stageCol, text_size=tblSize)
        r += 1
    if rowFast
        table.cell(t, 0, r, nm1, text_color=color.blue, text_size=tblSize)
        table.cell(t, 1, r, fv(ma1) + "  (" + f2(pct(close, ma1)) + ")", text_color = close>ma1 ? color.lime : color.red, text_size=tblSize)
        r += 1
    if rowSwingD
        table.cell(t, 0, r, "Swing Low D", text_color=color.white, text_size=tblSize)
        table.cell(t, 1, r, na(swingLowD) ? "n/a" : fv(swingLowD) + "  (" + f2(pct(close, swingLowD)) + ")" + (close < swingLowD ? " BROKEN" : ""), text_color = na(swingLowD) ? color.gray : (close >= swingLowD ? color.lime : color.red), text_size=tblSize)
        r += 1
    if rowSwingW
        table.cell(t, 0, r, "Swing Low W", text_color=color.white, text_size=tblSize)
        table.cell(t, 1, r, na(swingLowW) ? "n/a" : fv(swingLowW) + "  (" + f2(pct(close, swingLowW)) + ")" + (close < swingLowW ? " BROKEN" : ""), text_color = na(swingLowW) ? color.gray : (close >= swingLowW ? color.lime : color.red), text_size=tblSize)
        r += 1
    if rowVStop
        table.cell(t, 0, r, "VStop", text_color=color.white, text_size=tblSize)
        table.cell(t, 1, r, fv(vstop) + "  (" + f2(pct(close, vstop)) + ")", text_color = upTrend ? color.lime : color.red, text_size=tblSize)
        r += 1
    if rowTrend
        table.cell(t, 0, r, nm3, text_color=color.red, text_size=tblSize)
        table.cell(t, 1, r, fv(ma3) + "  (" + f2(pct(close, ma3)) + ")", text_color = close>ma3 ? color.lime : color.red, text_size=tblSize)
        r += 1
    if rowRS
        table.cell(t, 0, r, "RS vs N500", text_color=color.white, text_size=tblSize)
        table.cell(t, 1, r, beating ? "OUTPERFORM" : "UNDERPERFORM", text_color = beating ? color.lime : color.red, text_size=tblSize)
        r += 1

// ------------------------- ALERTS ------------------------------------
alertcondition(flipUp, "VStop -> Long",  "VStop flipped LONG")
alertcondition(flipDn, "VStop -> Short", "VStop flipped SHORT")
alertcondition(newSwingLow, "New Swing Low", "Dow swing low updated")
alertcondition(newHi,  "New 52W High",   "New 52-week high")
alertcondition(newLo,  "New 52W Low",    "New 52-week low")
````
