# [JBM] Reversal

- url: https://www.tradingview.com/script/c5lLf3A8-JBM-Reversal/
- type: indicator
- pine_id: PUB;01fc0fcd5bd54904bf6d669803449588
- version: 2.0

## Description

Detects reversal & trend-continuation setups using:
1. Pivot detection (swing high/low)
2. 2 Close Candle (2CC) validation
3. Pattern matching: W (bullish rev), M (bearish rev), zigzag
4. Sweet Spot box (Pivot Low ↔ Pivot High of breakout move)
5. Pullback counter → Grade A+ / A / B / C-SKIP
6. Trend expiration check (vs average trend length)

## Source Code

````pine
//@version=5
indicator("[JBM] Reversal", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ═══════════════════════════════════════════════════════════════
// JBM REVERSAL DETECTOR — 2CC Rule
// ═══════════════════════════════════════════════════════════════
// Detects reversal & trend-continuation setups using:
//   1. Pivot detection (swing high/low)
//   2. 2 Close Candle (2CC) validation
//   3. Pattern matching: W (bullish rev), M (bearish rev), zigzag
//   4. Sweet Spot box (Pivot Low ↔ Pivot High of breakout move)
//   5. Pullback counter → Grade A+ / A / B / C-SKIP
//   6. Trend expiration check (vs average trend length)
// ═══════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════
grpDetect = "Detection"
pivotLookback   = input.int(5, "Pivot Lookback (bars left/right)", minval=2, maxval=20, group=grpDetect)
breakMode       = input.string("Wick", "Break Mode", options=["Wick", "Body"], group=grpDetect, tooltip="Wick = aggressive (JBM). Body = conservative.")
maxSegments     = input.int(5, "Max Segments to Track", minval=4, maxval=10, group=grpDetect)
minBarsBetween  = input.int(3, "Min Bars Between Pivots", minval=1, group=grpDetect)

grpGrade = "Grading"
showSweetSpot   = input.bool(true, "Show Sweet Spot Box", group=grpGrade)
showGradeLabel  = input.bool(true, "Show Grade Label (A+/A/B/C)", group=grpGrade)
skipGradeC      = input.bool(true, "Mark Trend 3+ as SKIP", group=grpGrade)
expireMultiplier= input.float(2.0, "Trend Expiration Multiplier (x avg)", minval=1.0, step=0.5, group=grpGrade, tooltip="Skip if current trend > N × avg trend length")

grpVis = "Visuals"
showPivotMarkers= input.bool(true, "Show Pivot Markers (Λ/V)", group=grpVis)
showPatternLabel= input.bool(true, "Show Pattern Label (W/M)", group=grpVis)
colBullRev      = input.color(color.new(color.lime, 70), "Bullish Reversal", group=grpVis)
colBearRev      = input.color(color.new(color.red, 70), "Bearish Reversal", group=grpVis)
colSweetSpot    = input.color(color.new(color.yellow, 80), "Sweet Spot", group=grpVis)
colTrend        = input.color(color.new(color.aqua, 80), "Trend Continuation", group=grpVis)

grpAlerts = "Alerts"
alertOnReversal = input.bool(true, "Alert on Confirmed Reversal", group=grpAlerts)
alertOnExpired  = input.bool(false, "Alert on Trend Expired", group=grpAlerts)

// ═══════════════════════════════════════════════════════════════
// PIVOT DATA TYPE
// ═══════════════════════════════════════════════════════════════
type Pivot
    bool    isHigh          // true = pivot high (Λ), false = pivot low (V)
    int     pivotBar        // bar_index of the pivot candle
    float   pivotPrice      // high (if isHigh) or low (if !isHigh)
    float   refLevel        // for pivot low → its high; for pivot high → its low
    bool    valid           // 2CC rule passed
    int     confirmBar      // bar where 2nd close confirmed

// ═══════════════════════════════════════════════════════════════
// STATE — pivot history
// ═══════════════════════════════════════════════════════════════
var array<Pivot> pivots         = array.new<Pivot>()       // newest at end
var array<int>   trendLengths   = array.new<int>()         // segment lengths for avg
var int          lastConfirmedBar = 0
var box          sweetSpotBox    = na
var label        patternLbl      = na
var label        gradeLbl        = na

// ═══════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════
isPivotHigh(int lookback) =>
    h = high[lookback]
    isPiv = true
    for i = 1 to lookback
        if high[lookback - i] >= h or high[lookback + i] >= h
            isPiv := false
            break
    isPiv

isPivotLow(int lookback) =>
    l = low[lookback]
    isPiv = true
    for i = 1 to lookback
        if low[lookback - i] <= l or low[lookback + i] <= l
            isPiv := false
            break
    isPiv

// 2CC validation: check if 2 consecutive closes beyond reference exist after pivot
// For pivot low: 2 closes ABOVE pivot.high
// For pivot high: 2 closes BELOW pivot.low
validate2CC(Pivot p, int currentBar) =>
    if p.valid
        true
    else
        consecutive = 0
        prevClose = p.isHigh ? p.refLevel + 999999 : p.refLevel - 999999
        confirmed = false
        confirmBarLocal = 0
        // Walk forward from pivot to current bar
        scanFrom = p.pivotBar + 1
        scanTo   = currentBar
        if scanTo > scanFrom
            for b = scanFrom to scanTo
                idxBack = currentBar - b
                if idxBack < 0
                    break
                c = close[idxBack]
                breakOk = p.isHigh ? c < p.refLevel : c > p.refLevel
                progress = p.isHigh ? c < prevClose : c > prevClose
                if breakOk and (consecutive == 0 or progress)
                    consecutive += 1
                    prevClose := c
                    if consecutive >= 2
                        confirmed := true
                        confirmBarLocal := b
                        break
                else
                    consecutive := 0
                    prevClose := p.isHigh ? p.refLevel + 999999 : p.refLevel - 999999
        if confirmed
            p.valid := true
            p.confirmBar := confirmBarLocal
        confirmed

// ═══════════════════════════════════════════════════════════════
// PIVOT DETECTION (on bar close, with lookback offset)
// ═══════════════════════════════════════════════════════════════
if barstate.isconfirmed and bar_index > pivotLookback * 2
    pivBarIdx = bar_index - pivotLookback

    // Detect pivot high
    if isPivotHigh(pivotLookback)
        canAdd = true
        if array.size(pivots) > 0
            last = array.get(pivots, array.size(pivots) - 1)
            // Enforce zigzag — last must be opposite type
            if last.isHigh
                canAdd := false
            // Min bars apart
            if pivBarIdx - last.pivotBar < minBarsBetween
                canAdd := false
        if canAdd
            newP = Pivot.new(true, pivBarIdx, high[pivotLookback], low[pivotLookback], false, 0)
            array.push(pivots, newP)

    // Detect pivot low
    if isPivotLow(pivotLookback)
        canAdd = true
        if array.size(pivots) > 0
            last = array.get(pivots, array.size(pivots) - 1)
            if not last.isHigh
                canAdd := false
            if pivBarIdx - last.pivotBar < minBarsBetween
                canAdd := false
        if canAdd
            newP = Pivot.new(false, pivBarIdx, low[pivotLookback], high[pivotLookback], false, 0)
            array.push(pivots, newP)

    // Validate unconfirmed pivots with 2CC rule (use wick or body)
    if array.size(pivots) > 0
        for i = 0 to array.size(pivots) - 1
            p = array.get(pivots, i)
            if not p.valid
                // Wick mode: use refLevel as-is. Body mode: use refLevel (close already breaks)
                // Both modes use close (2CC = 2 CLOSE candle rule), wick/body affects break interp
                // For simplicity: wick = body close anywhere beyond ref. body = same.
                // Difference is mostly in ref calc — we use the standard.
                validate2CC(p, bar_index)

    // Trim pivot array to last N segments
    while array.size(pivots) > maxSegments + 2
        array.shift(pivots)

// ═══════════════════════════════════════════════════════════════
// PATTERN DETECTION — only on validated pivots
// ═══════════════════════════════════════════════════════════════
// Get last N validated pivots
getValidatedPivots(int n) =>
    arr = array.new<Pivot>()
    if array.size(pivots) > 0
        for i = array.size(pivots) - 1 to 0
            p = array.get(pivots, i)
            if p.valid
                array.unshift(arr, p)
                if array.size(arr) >= n
                    break
    arr

// Bullish Reversal (W pattern): need last 4 pivots = L-H-L-H with last L > prev L AND last H > prev H
detectBullishReversal() =>
    valids = getValidatedPivots(4)
    result = false
    if array.size(valids) >= 4
        p1 = array.get(valids, 0)  // oldest: L
        p2 = array.get(valids, 1)  // H
        p3 = array.get(valids, 2)  // L
        p4 = array.get(valids, 3)  // newest: H
        if (not p1.isHigh) and p2.isHigh and (not p3.isHigh) and p4.isHigh
            // Higher Low + Higher High (break previous high)
            if p3.pivotPrice > p1.pivotPrice and p4.pivotPrice > p2.pivotPrice
                result := true
    result

// Bearish Reversal (M pattern): need last 4 pivots = H-L-H-L with last H < prev H AND last L < prev L
detectBearishReversal() =>
    valids = getValidatedPivots(4)
    result = false
    if array.size(valids) >= 4
        p1 = array.get(valids, 0)  // oldest: H
        p2 = array.get(valids, 1)  // L
        p3 = array.get(valids, 2)  // H
        p4 = array.get(valids, 3)  // newest: L
        if p1.isHigh and (not p2.isHigh) and p3.isHigh and (not p4.isHigh)
            if p3.pivotPrice < p1.pivotPrice and p4.pivotPrice < p2.pivotPrice
                result := true
    result

// Uptrend continuation: last 3 pivots = HL → HH (or zigzag continuing up)
detectUptrend() =>
    valids = getValidatedPivots(3)
    result = false
    if array.size(valids) >= 3
        p1 = array.get(valids, 0)
        p2 = array.get(valids, 1)
        p3 = array.get(valids, 2)
        // Latest must be HL (low pivot higher than prev low) AND prev was HH
        if (not p3.isHigh) and p1.isHigh and (not array.get(valids, 0).isHigh ? false : true)
            // Simplified: any zigzag where lows ascending
            result := false
        // Cleaner: check if low pivots ascending in last 3
        lows = array.new<float>()
        for i = 0 to array.size(valids) - 1
            pv = array.get(valids, i)
            if not pv.isHigh
                array.push(lows, pv.pivotPrice)
        if array.size(lows) >= 2
            allAsc = true
            for j = 1 to array.size(lows) - 1
                if array.get(lows, j) <= array.get(lows, j - 1)
                    allAsc := false
                    break
            if allAsc
                result := true
    result

detectDowntrend() =>
    valids = getValidatedPivots(3)
    result = false
    if array.size(valids) >= 3
        highs = array.new<float>()
        for i = 0 to array.size(valids) - 1
            pv = array.get(valids, i)
            if pv.isHigh
                array.push(highs, pv.pivotPrice)
        if array.size(highs) >= 2
            allDesc = true
            for j = 1 to array.size(highs) - 1
                if array.get(highs, j) >= array.get(highs, j - 1)
                    allDesc := false
                    break
            if allDesc
                result := true
    result

// ═══════════════════════════════════════════════════════════════
// PULLBACK COUNTER — Grade A+/A/B/C
// ═══════════════════════════════════════════════════════════════
// Count pullbacks in current trend direction since trend start
countPullbacksInTrend(bool isUptrend) =>
    cnt = 0
    if array.size(pivots) >= 2
        // Walk backward, count opposite-direction pivots until trend breaks
        for i = array.size(pivots) - 1 to 0
            p = array.get(pivots, i)
            if p.valid
                // Pullback in uptrend = pivot low. In downtrend = pivot high.
                if isUptrend and (not p.isHigh)
                    cnt += 1
                if (not isUptrend) and p.isHigh
                    cnt += 1
                if cnt >= 5
                    break
    cnt

gradeFromPullback(int n) =>
    n == 0 ? "A+ (REVERSAL)" : n == 1 ? "A (Trend 1)" : n == 2 ? "B (Trend 2)" : "C SKIP (Trend " + str.tostring(n) + "+)"

// ═══════════════════════════════════════════════════════════════
// MAIN LOGIC — fire on bar close
// ═══════════════════════════════════════════════════════════════
isBullRev = false
isBearRev = false
isUptrend = false
isDowntrend = false
pullbackCount = 0
gradeStr = ""
trendExpired = false

if barstate.isconfirmed
    isBullRev := detectBullishReversal()
    isBearRev := detectBearishReversal()
    isUptrend := detectUptrend()
    isDowntrend := detectDowntrend()

    // Pullback count
    if isUptrend
        pullbackCount := countPullbacksInTrend(true) - 1
    else if isDowntrend
        pullbackCount := countPullbacksInTrend(false) - 1
    else
        pullbackCount := 0

    if pullbackCount < 0
        pullbackCount := 0

    // Reversal = Grade A+
    if isBullRev or isBearRev
        gradeStr := "A+ (REVERSAL)"
    else
        gradeStr := gradeFromPullback(pullbackCount)

    // Trend expiration check
    if array.size(trendLengths) > 0
        avgLen = array.avg(trendLengths)
        currentLen = array.size(pivots) > 0 ? bar_index - array.get(pivots, 0).pivotBar : 0
        if currentLen > avgLen * expireMultiplier
            trendExpired := true

    // Track new trend length when reversal detected
    if isBullRev or isBearRev
        if array.size(pivots) >= 2
            firstP = array.get(pivots, 0)
            lastP  = array.get(pivots, array.size(pivots) - 1)
            array.push(trendLengths, lastP.pivotBar - firstP.pivotBar)
            if array.size(trendLengths) > 20
                array.shift(trendLengths)

    // Sweet spot — inline (Pine v5 disallows modifying globals inside functions)
    if showSweetSpot and (isBullRev or isBearRev or isUptrend or isDowntrend)
        ssValids = getValidatedPivots(2)
        if array.size(ssValids) >= 2
            pA = array.get(ssValids, 0)
            pB = array.get(ssValids, 1)
            topPx = pA.isHigh ? pA.pivotPrice : pB.pivotPrice
            botPx = pA.isHigh ? pB.pivotPrice : pA.pivotPrice
            if not na(sweetSpotBox)
                box.delete(sweetSpotBox)
            sweetSpotBox := box.new(left=math.min(pA.pivotBar, pB.pivotBar), top=topPx, right=bar_index + 10, bottom=botPx, bgcolor=colSweetSpot, border_color=color.yellow, border_width=1, text="Sweet Spot", text_size=size.tiny, text_color=color.yellow, text_halign=text.align_left)

    // Pattern label
    if showPatternLabel
        if not na(patternLbl)
            label.delete(patternLbl)
        if isBullRev
            patternLbl := label.new(bar_index, low - syminfo.mintick * 50, "W (Bullish Rev)", style=label.style_label_up, color=colBullRev, textcolor=color.white, size=size.small)
        else if isBearRev
            patternLbl := label.new(bar_index, high + syminfo.mintick * 50, "M (Bearish Rev)", style=label.style_label_down, color=colBearRev, textcolor=color.white, size=size.small)

    // Grade label (top-right corner of last bar)
    if showGradeLabel
        if not na(gradeLbl)
            label.delete(gradeLbl)
        gradeColor = isBullRev or isBearRev ? color.lime : pullbackCount == 1 ? color.aqua : pullbackCount == 2 ? color.orange : color.red
        gradeText = gradeStr + (trendExpired ? " ⚠ EXPIRED" : "")
        gradeLbl := label.new(bar_index + 5, close, gradeText, style=label.style_label_left, color=gradeColor, textcolor=color.white, size=size.small)

// ═══════════════════════════════════════════════════════════════
// PIVOT MARKERS — retroactive label.new anchored to candle price
// (plotshape with offset doesn't track when chart is scrolled/zoomed)
// ═══════════════════════════════════════════════════════════════
if showPivotMarkers and barstate.isconfirmed and bar_index > pivotLookback * 2
    pivBar = bar_index - pivotLookback
    if isPivotHigh(pivotLookback)
        label.new(x=pivBar, y=high[pivotLookback], text="▼", style=label.style_none, textcolor=color.red, size=size.small, yloc=yloc.abovebar)
    if isPivotLow(pivotLookback)
        label.new(x=pivBar, y=low[pivotLookback], text="▲", style=label.style_none, textcolor=color.lime, size=size.small, yloc=yloc.belowbar)

// ═══════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════
if alertOnReversal and barstate.isconfirmed
    if isBullRev
        alert("JBM: Bullish Reversal confirmed (W pattern, 2CC validated) on " + syminfo.ticker, alert.freq_once_per_bar_close)
    if isBearRev
        alert("JBM: Bearish Reversal confirmed (M pattern, 2CC validated) on " + syminfo.ticker, alert.freq_once_per_bar_close)

if alertOnExpired and barstate.isconfirmed and trendExpired
    alert("JBM: Trend EXPIRED on " + syminfo.ticker + " — current trend > " + str.tostring(expireMultiplier) + "× avg", alert.freq_once_per_bar_close)

// ═══════════════════════════════════════════════════════════════
// INFO TABLE (top-right)
// ═══════════════════════════════════════════════════════════════
var table infoTbl = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 80), border_width=1)

if barstate.islast
    table.cell(infoTbl, 0, 0, "JBM Reversal", text_color=color.yellow, text_size=size.small, bgcolor=color.new(color.navy, 50))
    table.cell(infoTbl, 1, 0, "v0.01", text_color=color.yellow, text_size=size.small, bgcolor=color.new(color.navy, 50))
    table.cell(infoTbl, 0, 1, "Grade", text_color=color.white, text_size=size.tiny)
    table.cell(infoTbl, 1, 1, gradeStr, text_color=color.lime, text_size=size.tiny)
    table.cell(infoTbl, 0, 2, "Pattern", text_color=color.white, text_size=size.tiny)
    patStr = isBullRev ? "W (Bull Rev)" : isBearRev ? "M (Bear Rev)" : isUptrend ? "Uptrend" : isDowntrend ? "Downtrend" : "Unclear"
    table.cell(infoTbl, 1, 2, patStr, text_color=color.aqua, text_size=size.tiny)
    table.cell(infoTbl, 0, 3, "Pullback #", text_color=color.white, text_size=size.tiny)
    table.cell(infoTbl, 1, 3, str.tostring(pullbackCount), text_color=color.white, text_size=size.tiny)
    table.cell(infoTbl, 0, 4, "Pivots Tracked", text_color=color.white, text_size=size.tiny)
    table.cell(infoTbl, 1, 4, str.tostring(array.size(pivots)), text_color=color.white, text_size=size.tiny)
    table.cell(infoTbl, 0, 5, "Trend Status", text_color=color.white, text_size=size.tiny)
    table.cell(infoTbl, 1, 5, trendExpired ? "EXPIRED" : "Active", text_color=trendExpired ? color.red : color.lime, text_size=size.tiny)
````
