# Adaptive Anchored VWAP - Event Anchors and Empirical Bands

- url: https://www.tradingview.com/script/r0JIfwkD/
- type: indicator
- pine_id: PUB;8ac447e166c04105b1e356513f55a407
- version: 1.0

## Description

Adaptive Anchored VWAP - Event Anchors and Empirical Bands


OVERVIEW
Adaptive Anchored VWAP (AVWAP X) is an anchored volume-weighted average price that decides WHERE to anchor and HOW WIDE its bands should be from the data itself, instead of relying on fixed calendar periods and normal-distribution assumptions. It combines three components that work together toward one task: measuring how far price has travelled from the average price paid by participants since a meaningful market event, and classifying the current state of that relationship.

WHAT MAKES IT DIFFERENT
1. Structural and event-driven anchors. Besides the standard calendar anchors, the AVWAP can anchor automatically on confirmed swing pivots, on the highest-volume bar of the last N bars, on statistically unusual volume (z-score of log volume), or on price gaps.
2. Empirical percentile bands. Standard VWAP bands assume price deviations are normally distributed. In practice they often are not (fat tails, skew, low-liquidity jumps). This script records every percentage deviation of price from the AVWAP since the anchor, keeps them in a sorted array, and draws the bands at the actual percentiles of that distribution.
3. Regime engine. Price is classified into six states relative to the AVWAP and its bands, and six discrete events (Reclaim, Lose, Hold, Reject, Exhaustion Up/Down) are detected with optional volume confirmation and alerts.

HOW IT WORKS
Anchors
- Calendar: Session, Week, Month, Quarter, Year (reset on each new period).
- Corporate events: Earnings, Dividends, Splits (when data is available for the symbol).
- Custom Date: accumulation starts at the first bar on or after the chosen date/time.
- Pivot Low / Pivot High / Latest Pivot: uses ta.pivotlow / ta.pivothigh. A pivot is accepted only after "Pivot Right Bars" confirm it. At that moment the AVWAP sums are back-calculated from the pivot bar, so the value is mathematically anchored at the pivot.
- Volume High (N): anchors on a bar whose volume is the highest of the last N bars.
- Volume Spike (Z): anchors when the z-score of log(volume) versus the previous N bars exceeds the threshold. Log scale is used because raw volume is strongly right-skewed.
- Gap: anchors when the open gaps beyond the previous bar's range by at least the minimum percentage.

AVWAP engine
The AVWAP is computed with its own running sums of price*volume, volume and price^2*volume. This allows anchoring on a past bar (pivots), which the built-in ta.vwap() cannot do.

Bands
- Empirical Percentile (default): bands are placed at the chosen percentiles of past deviations since the anchor. The default 84.1 / 97.7 percentiles correspond to +/-1 and +/-2 standard deviations under a normal distribution, so you can compare both modes directly: when they differ a lot, the deviation distribution is not normal. The current bar is excluded from the percentile calculation. Until "Min Samples" deviations exist, standard deviation bands are used as a fallback and the dashboard shows this in yellow.
- Standard Deviation and Percentage modes are also available.

States: Extended Up (above outer band), Strong Up (above inner band), Above AVWAP, Below AVWAP, Strong Down, Extended Down.

Events
- Reclaim: close crosses above the AVWAP (optionally with volume above its average times a multiplier).
- Lose: close crosses below the AVWAP (same volume option).
- Hold: previous close above the AVWAP, current low touches it, close stays above.
- Reject: previous close below the AVWAP, current high touches it, close stays below.
- Exhaustion Up / Down: close returns inside the outer band after closing outside it.
Signals are suppressed on the anchor bar and for "Min Bars After Anchor".

Dashboard: anchor mode and time, bars since anchor, AVWAP value, distance %, the percentile rank of the current deviation within its own history, band mode in use, current state, and a data warning.

HOW TO USE
- Use Pivot Low in uptrends and Pivot High in downtrends to track the average cost of participants since the last structural turn.
- Use Volume Spike or Volume High to follow the average price since a probable large-participant event.
- The Percentile Rank tells you how unusual the current distance from the AVWAP is for this specific anchor (for example, 97 means the current deviation is larger than about 97% of deviations observed since the anchor).
- Treat Hold / Reject / Reclaim / Lose as context events, not standalone trade signals. They are most informative when aligned with the broader trend.

ALERTS
Six alertcondition() entries are available (one per event), plus one alert() call that sends a dynamic message with ticker, event, close, AVWAP and state. Use "Once per bar close".

LIMITATIONS
- Pivot modes: the new AVWAP line appears on the chart only from the confirmation bar onward (pivot bar + Pivot Right Bars). The values between the pivot and confirmation are included in the calculation but are not redrawn in the past. This is deliberate to avoid repainting.
- Custom Date: if the chosen date is earlier than the first loaded bar, accumulation starts at the first available bar. The dashboard shows a red warning in that case.
- Empirical bands need enough samples. With few samples, extreme percentiles are determined by very few observations; raise "Min Samples" on illiquid symbols.
- The script requires volume data. Intraday volume quality varies by exchange and data vendor.
- Earnings / Dividends / Splits anchors depend on the availability of that data for the symbol.
- Do not use this script on non-standard chart types (Heikin Ashi, Renko, etc.): the signals would be based on synthetic prices.
- No signal of this script predicts future prices. Past behavior does not guarantee future results.

CREDITS
The calendar, earnings, dividends and splits anchor logic is adapted from TradingView's built-in VWAP indicator. All other components (event anchors, back-filled pivot anchoring, sorted-array empirical percentile bands with percentile rank, regime engine and dashboard) are original to this script.


ملخص بالعربية
مؤشر VWAP مرتكز يحدد نقطة الارتكاز تلقائياً من البيانات: قمم وقيعان مؤكدة، أو أحداث فوليوم غير اعتيادية، أو فجوات سعرية، إلى جانب الارتكاز الزمني والتاريخ المخصص. النطاقات تُبنى من التوزيع الفعلي لانحرافات السعر عن الـ AVWAP منذ نقطة الارتكاز (Percentiles)، وليس من افتراض التوزيع الطبيعي. يصنّف المؤشر حالة السعر في ست حالات، ويرصد ست أحداث مع تنبيهات. الإشارات سياقية وليست توصيات تداول.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AhmedAminTC

// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Author: Ahmed Amin, CFTe®, CETA®
// Calendar / Earnings / Dividends / Splits anchor logic adapted from TradingView's built-in VWAP (public domain).

//@version=6
indicator("Adaptive Anchored VWAP - Event Anchors and Empirical Bands", shorttitle = "AVWAP X", overlay = true, max_labels_count = 500, max_bars_back = 500)

// ═══════════════════════════ INPUTS - ANCHOR ═══════════════════════════
G_A = "Anchor"
anchorMode  = input.string("Pivot Low", "Anchor Mode", group = G_A,
 options = ["Session", "Week", "Month", "Quarter", "Year", "Earnings", "Dividends", "Splits", "Custom Date",
            "Pivot Low", "Pivot High", "Latest Pivot", "Volume High (N)", "Volume Spike (Z)", "Gap"],
 tooltip = "Calendar modes reset on each new period. Pivot modes anchor on confirmed swing points. Event modes anchor on volume or gap events.")
isPivotMode = anchorMode == "Pivot Low" or anchorMode == "Pivot High" or anchorMode == "Latest Pivot"
isVolMode   = anchorMode == "Volume High (N)" or anchorMode == "Volume Spike (Z)"
isCalendar  = anchorMode == "Session" or anchorMode == "Week" or anchorMode == "Month" or anchorMode == "Quarter" or anchorMode == "Year"

anchorDate  = input.time(timestamp("01 Jan 2026 00:00"), "Custom Anchor Date", group = G_A, active = anchorMode == "Custom Date",
 tooltip = "Accumulation starts from the first bar at or after this date/time.")
pivLeft     = input.int(10, "Pivot Left Bars", minval = 1, maxval = 200, group = G_A, active = isPivotMode)
pivRight    = input.int(5, "Pivot Right Bars (confirmation lag)", minval = 1, maxval = 100, group = G_A, active = isPivotMode,
 tooltip = "A pivot is used only after this many bars confirm it. The AVWAP is then back-calculated from the pivot bar, but the plotted line starts at the confirmation bar (no repainting).")
volLen      = input.int(50, "Volume Lookback (N)", minval = 5, maxval = 1000, group = G_A, active = isVolMode)
volZThr     = input.float(2.5, "Volume Spike Z (log-volume)", minval = 0.5, step = 0.1, group = G_A, active = anchorMode == "Volume Spike (Z)",
 tooltip = "Z-score of log(volume) versus the previous N bars. Log scale reduces the skew of raw volume.")
gapMin      = input.float(1.0, "Min Gap %", minval = 0.0, step = 0.1, group = G_A, active = anchorMode == "Gap")
src         = input.source(hlc3, "Source", group = G_A)
showAnchorLbl = input.bool(true, "Show Anchor Labels (non-calendar modes)", group = G_A)

// ═══════════════════════════ INPUTS - BANDS ═══════════════════════════
G_B = "Bands"
bandMode   = input.string("Empirical Percentile", "Band Mode", options = ["Empirical Percentile", "Standard Deviation", "Percentage"], group = G_B,
 tooltip = "Empirical Percentile builds bands from the actual distribution of price deviations from the AVWAP since the anchor, instead of assuming a normal distribution.")
isEmpMode  = bandMode == "Empirical Percentile"
pInner     = input.float(84.1, "Inner Percentile (~1 sigma equiv.)", minval = 50.5, maxval = 99.9, step = 0.1, group = G_B, active = isEmpMode)
pOuter     = input.float(97.7, "Outer Percentile (~2 sigma equiv.)", minval = 50.5, maxval = 99.9, step = 0.1, group = G_B, active = isEmpMode)
multIn     = input.float(1.0, "Inner Multiplier (sigma or %)", minval = 0, step = 0.5, group = G_B, active = not isEmpMode)
multOut    = input.float(2.0, "Outer Multiplier (sigma or %)", minval = 0, step = 0.5, group = G_B, active = not isEmpMode)
minSamples = input.int(60, "Min Samples for Empirical", minval = 10, group = G_B, active = isEmpMode,
 tooltip = "Until this many deviations are collected since the anchor, standard deviation bands are used as a fallback (shown in yellow on the dashboard).")
maxSamples = input.int(1000, "Max Samples (rolling cap)", minval = 50, maxval = 5000, group = G_B, active = isEmpMode)
showInner  = input.bool(true, "Show Inner Bands", group = G_B)
showOuter  = input.bool(true, "Show Outer Bands", group = G_B)

// ═══════════════════════════ INPUTS - REGIME ═══════════════════════════
G_R = "Regime and Signals"
minSigBars  = input.int(5, "Min Bars After Anchor for Signals", minval = 0, group = G_R)
useVolConf  = input.bool(true, "Volume Confirmation for Reclaim / Lose", group = G_R)
volConfLen  = input.int(20, "Volume Conf. MA Length", minval = 2, group = G_R, active = useVolConf)
volConfMult = input.float(1.2, "Volume Conf. Multiplier", minval = 0.1, step = 0.1, group = G_R, active = useVolConf)
showSignals = input.bool(true, "Show Signal Markers", group = G_R)
showTable   = input.bool(true, "Show Dashboard", group = G_R)

if isEmpMode and pOuter <= pInner
    runtime.error("Outer percentile must be greater than inner percentile.")
if barstate.islast and ta.cum(nz(volume)) == 0
    runtime.error("No volume is provided by the data vendor.")

// ═══════════════════════════ HELPERS ═══════════════════════════
// Binary search: first index where a[idx] >= x (a sorted ascending)
lowerBound(array<float> a, float x) =>
    int lo = 0
    int hi = array.size(a)
    while lo < hi
        int mid = math.floor((lo + hi) / 2)
        if array.get(a, mid) < x
            lo := mid + 1
        else
            hi := mid
    lo

// Linear-interpolated percentile from a pre-sorted array, O(1)
pctFromSorted(array<float> a, float p) =>
    int n = array.size(a)
    float r = na
    if n > 0
        float pos  = (p / 100.0) * (n - 1)
        int   i0   = math.floor(pos)
        int   i1   = math.min(i0 + 1, n - 1)
        float frac = pos - i0
        r := array.get(a, i0) + (array.get(a, i1) - array.get(a, i0)) * frac
    r

// Insert into sorted array + FIFO; evict oldest when over cap
pushDev(array<float> srt, array<float> fifo, float x, int cap) =>
    array.insert(srt, lowerBound(srt, x), x)
    array.push(fifo, x)
    if array.size(fifo) > cap
        float old = array.shift(fifo)
        array.remove(srt, lowerBound(srt, old))

stateTxt(int s) =>
    switch s
        3  => "Extended Up"
        2  => "Strong Up"
        1  => "Above AVWAP"
        -1 => "Below AVWAP"
        -2 => "Strong Down"
        -3 => "Extended Down"
        => "-"

stateCol(int s) =>
    s >= 2 ? color.new(color.green, 0) : s == 1 ? color.new(color.teal, 0) : s == -1 ? color.new(color.orange, 0) : s <= -2 ? color.new(color.red, 0) : color.gray

// ═══════════════════════════ ANCHOR DETECTION ═══════════════════════════
pl = ta.pivotlow(low, pivLeft, pivRight)
ph = ta.pivothigh(high, pivLeft, pivRight)

logVol    = math.log(math.max(nz(volume), 1))
vMean     = ta.sma(logVol, volLen)
vStd      = ta.stdev(logVol, volLen)
volZScore = nz(vStd[1]) > 0 ? (logVol - vMean[1]) / vStd[1] : 0.0
isVolHigh = nz(volume) > 0 and volume == ta.highest(volume, volLen)

gapUp = open > high[1] * (1 + gapMin / 100)
gapDn = open < low[1]  * (1 - gapMin / 100)

customStart = time >= anchorDate and (na(time[1]) or time[1] < anchorDate)

bool anchorNow    = false
int  anchorOffset = 0
int  anchorDir    = 0

switch anchorMode
    "Session" => anchorNow := timeframe.change("D")
    "Week"    => anchorNow := timeframe.change("W")
    "Month"   => anchorNow := timeframe.change("M")
    "Quarter" => anchorNow := timeframe.change("3M")
    "Year"    => anchorNow := timeframe.change("12M")
    "Earnings" =>
        e1 = request.earnings(syminfo.tickerid, earnings.actual, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol = true)
        e2 = request.earnings(syminfo.tickerid, earnings.standardized, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol = true)
        anchorNow := not na(e1) or not na(e2)
    "Dividends" =>
        d1 = request.dividends(syminfo.tickerid, dividends.gross, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol = true)
        anchorNow := not na(d1)
    "Splits" =>
        s1 = request.splits(syminfo.tickerid, splits.denominator, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol = true)
        anchorNow := not na(s1)
    "Custom Date" => anchorNow := customStart
    "Pivot Low" =>
        if not na(pl)
            anchorNow    := true
            anchorOffset := pivRight
            anchorDir    := 1
    "Pivot High" =>
        if not na(ph)
            anchorNow    := true
            anchorOffset := pivRight
            anchorDir    := -1
    "Latest Pivot" =>
        if not na(pl)
            anchorNow    := true
            anchorOffset := pivRight
            anchorDir    := 1
        else if not na(ph)
            anchorNow    := true
            anchorOffset := pivRight
            anchorDir    := -1
    "Volume High (N)" =>
        anchorNow := isVolHigh
        anchorDir := close >= open ? 1 : -1
    "Volume Spike (Z)" =>
        anchorNow := volZScore >= volZThr
        anchorDir := close >= open ? 1 : -1
    "Gap" =>
        anchorNow := gapUp or gapDn
        anchorDir := gapUp ? 1 : -1

if barstate.isfirst and isCalendar
    anchorNow := true

// ═══════════════════════════ AVWAP ENGINE ═══════════════════════════
var float sPV  = na
var float sV   = na
var float sPV2 = na
var int   anchorBar  = na
var int   anchorTime = na
var array<float> sortedDevs = array.new<float>()
var array<float> fifoDevs   = array.new<float>()
var int firstBarTime = time

if anchorNow
    sPV  := 0.0
    sV   := 0.0
    sPV2 := 0.0
    array.clear(sortedDevs)
    array.clear(fifoDevs)
    anchorBar  := bar_index - anchorOffset
    anchorTime := time[anchorOffset]
    if anchorOffset > 0
        for i = anchorOffset to 1
            float p = src[i]
            float v = nz(volume[i])
            sPV  += p * v
            sV   += v
            sPV2 += p * p * v
            if sV > 0
                float vw = sPV / sV
                pushDev(sortedDevs, fifoDevs, (p - vw) / vw * 100, maxSamples)
    if showAnchorLbl and not isCalendar
        label.new(bar_index - anchorOffset, close, anchorMode,
         yloc = anchorDir == -1 ? yloc.abovebar : yloc.belowbar,
         style = anchorDir == -1 ? label.style_label_down : label.style_label_up,
         color = anchorDir == -1 ? color.new(color.red, 30) : anchorDir == 1 ? color.new(color.green, 30) : color.new(#2962FF, 30),
         textcolor = color.white, size = size.tiny)

if not na(sV)
    float v0 = nz(volume)
    sPV  += src * v0
    sV   += v0
    sPV2 += src * src * v0

float avwap = sV > 0 ? sPV / sV : na
float sd    = sV > 0 ? math.sqrt(math.max(sPV2 / sV - avwap * avwap, 0)) : na

// ═══════════════════════════ BANDS ═══════════════════════════
int   nSamples = array.size(sortedDevs)
bool  useEmp   = isEmpMode and nSamples >= minSamples
float uIn  = na
float lIn  = na
float uOut = na
float lOut = na

if not na(avwap)
    if useEmp
        // Percentiles from past deviations only (current bar excluded)
        uIn  := avwap * (1 + pctFromSorted(sortedDevs, pInner) / 100)
        lIn  := avwap * (1 + pctFromSorted(sortedDevs, 100 - pInner) / 100)
        uOut := avwap * (1 + pctFromSorted(sortedDevs, pOuter) / 100)
        lOut := avwap * (1 + pctFromSorted(sortedDevs, 100 - pOuter) / 100)
    else if bandMode == "Percentage"
        uIn  := avwap * (1 + multIn / 100)
        lIn  := avwap * (1 - multIn / 100)
        uOut := avwap * (1 + multOut / 100)
        lOut := avwap * (1 - multOut / 100)
    else
        uIn  := avwap + sd * multIn
        lIn  := avwap - sd * multIn
        uOut := avwap + sd * multOut
        lOut := avwap - sd * multOut

float curDev  = not na(avwap) and avwap != 0 ? (src - avwap) / avwap * 100 : na
float curRank = nSamples > 0 and not na(curDev) ? float(lowerBound(sortedDevs, curDev)) / nSamples * 100 : na

if not na(curDev)
    pushDev(sortedDevs, fifoDevs, curDev, maxSamples)

// ═══════════════════════════ REGIME STATE MACHINE ═══════════════════════════
int state = 0
if not na(avwap)
    state := close > avwap ? 1 : -1
    if not na(uIn) and close > uIn
        state := 2
    if not na(uOut) and close > uOut
        state := 3
    if not na(lIn) and close < lIn
        state := -2
    if not na(lOut) and close < lOut
        state := -3

volOK = not useVolConf or nz(volume) > ta.sma(nz(volume), volConfLen) * volConfMult
sigOK = not na(avwap) and not na(avwap[1]) and not anchorNow and (bar_index - anchorBar) >= minSigBars

reclaimSig = sigOK and close > avwap and close[1] <= avwap[1] and volOK
loseSig    = sigOK and close < avwap and close[1] >= avwap[1] and volOK
holdSig    = sigOK and close[1] > avwap[1] and low <= avwap and close > avwap
rejectSig  = sigOK and close[1] < avwap[1] and high >= avwap and close < avwap
exhUpSig   = sigOK and not na(uOut[1]) and close[1] > uOut[1] and close <= uOut
exhDnSig   = sigOK and not na(lOut[1]) and close[1] < lOut[1] and close >= lOut

// ═══════════════════════════ PLOTS ═══════════════════════════
avwapCol = avwap >= nz(avwap[1], avwap) ? #2962FF : #9C27B0
plot(avwap, "AVWAP", color = avwapCol, linewidth = 2)

pUIn  = plot(showInner ? uIn  : na, "Upper Inner", color = color.new(color.green, 40))
pLIn  = plot(showInner ? lIn  : na, "Lower Inner", color = color.new(color.green, 40))
pUOut = plot(showOuter ? uOut : na, "Upper Outer", color = color.new(color.red, 40))
pLOut = plot(showOuter ? lOut : na, "Lower Outer", color = color.new(color.red, 40))
fill(pUIn, pLIn,   color = color.new(color.green, 94), title = "Inner Fill")
fill(pUOut, pUIn,  color = color.new(color.red, 95),   title = "Upper Extreme Fill")
fill(pLIn, pLOut,  color = color.new(color.red, 95),   title = "Lower Extreme Fill")

plotshape(showSignals and reclaimSig, "Reclaim", shape.triangleup,   location.belowbar, color.green,  text = "Reclaim", size = size.tiny)
plotshape(showSignals and loseSig,    "Lose",    shape.triangledown, location.abovebar, color.red,    text = "Lose",    size = size.tiny)
plotshape(showSignals and holdSig,    "Hold",    shape.circle,       location.belowbar, color.teal,   text = "Hold",    size = size.tiny)
plotshape(showSignals and rejectSig,  "Reject",  shape.circle,       location.abovebar, color.orange, text = "Reject",  size = size.tiny)
plotshape(showSignals and exhUpSig,   "Exhaustion Up",   shape.xcross, location.abovebar, color.fuchsia, text = "Exh", size = size.tiny)
plotshape(showSignals and exhDnSig,   "Exhaustion Down", shape.xcross, location.belowbar, color.fuchsia, text = "Exh", size = size.tiny)

// ═══════════════════════════ ALERTS ═══════════════════════════
alertcondition(reclaimSig, "AVWAP Reclaim",         "{{ticker}} reclaimed Anchored VWAP @ {{close}}")
alertcondition(loseSig,    "AVWAP Lose",            "{{ticker}} lost Anchored VWAP @ {{close}}")
alertcondition(holdSig,    "AVWAP Hold (Test OK)",  "{{ticker}} tested and held Anchored VWAP @ {{close}}")
alertcondition(rejectSig,  "AVWAP Reject",          "{{ticker}} rejected at Anchored VWAP @ {{close}}")
alertcondition(exhUpSig,   "AVWAP Exhaustion Up",   "{{ticker}} fell back inside upper extreme band @ {{close}}")
alertcondition(exhDnSig,   "AVWAP Exhaustion Down", "{{ticker}} recovered inside lower extreme band @ {{close}}")

if reclaimSig or loseSig or holdSig or rejectSig or exhUpSig or exhDnSig
    string ev = reclaimSig ? "RECLAIM" : loseSig ? "LOSE" : holdSig ? "HOLD" : rejectSig ? "REJECT" : exhUpSig ? "EXHAUSTION UP" : "EXHAUSTION DOWN"
    alert(syminfo.ticker + " | AVWAP " + ev + " | Close " + str.tostring(close, format.mintick) + " | AVWAP " + str.tostring(avwap, format.mintick) + " | State " + stateTxt(state), alert.freq_once_per_bar_close)

// ═══════════════════════════ DASHBOARD ═══════════════════════════
var table dash = table.new(position.top_right, 2, 9, bgcolor = color.new(color.black, 20), border_width = 1, border_color = color.new(color.gray, 60))
if showTable and barstate.islast
    string anchorTxt = na(anchorTime) ? "-" : str.format_time(anchorTime, "yyyy-MM-dd HH:mm", syminfo.timezone)
    string bandTxt   = useEmp ? "Empirical (n=" + str.tostring(nSamples) + ")" : isEmpMode ? "Sigma fallback (n<" + str.tostring(minSamples) + ")" : bandMode
    bool   histWarn  = anchorMode == "Custom Date" and firstBarTime > anchorDate
    table.cell(dash, 0, 0, "Anchor Mode", text_color = color.silver, text_size = size.small)
    table.cell(dash, 1, 0, anchorMode, text_color = color.white, text_size = size.small)
    table.cell(dash, 0, 1, "Anchor Time", text_color = color.silver, text_size = size.small)
    table.cell(dash, 1, 1, anchorTxt, text_color = histWarn ? color.red : color.white, text_size = size.small)
    table.cell(dash, 0, 2, "Bars Since", text_color = color.silver, text_size = size.small)
    table.cell(dash, 1, 2, na(anchorBar) ? "-" : str.tostring(bar_index - anchorBar), text_color = color.white, text_size = size.small)
    table.cell(dash, 0, 3, "AVWAP", text_color = color.silver, text_size = size.small)
    table.cell(dash, 1, 3, str.tostring(avwap, format.mintick), text_color = color.white, text_size = size.small)
    table.cell(dash, 0, 4, "Distance %", text_color = color.silver, text_size = size.small)
    table.cell(dash, 1, 4, na(curDev) ? "-" : str.tostring(curDev, "#.##") + "%", text_color = nz(curDev) >= 0 ? color.green : color.red, text_size = size.small)
    table.cell(dash, 0, 5, "Percentile Rank", text_color = color.silver, text_size = size.small)
    table.cell(dash, 1, 5, na(curRank) ? "-" : str.tostring(curRank, "#.#"), text_color = color.white, text_size = size.small)
    table.cell(dash, 0, 6, "Bands", text_color = color.silver, text_size = size.small)
    table.cell(dash, 1, 6, bandTxt, text_color = useEmp ? color.white : color.yellow, text_size = size.small)
    table.cell(dash, 0, 7, "State", text_color = color.silver, text_size = size.small)
    table.cell(dash, 1, 7, stateTxt(state), text_color = color.white, bgcolor = stateCol(state), text_size = size.small)
    table.cell(dash, 0, 8, "Warning", text_color = color.silver, text_size = size.small)
    table.cell(dash, 1, 8, histWarn ? "Anchor before loaded history" : "None", text_color = histWarn ? color.red : color.gray, text_size = size.small)
````
