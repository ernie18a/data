# Key Gate Levels

- url: https://www.tradingview.com/script/VbSwmiWK-Key-Gate-Levels/
- type: indicator
- pine_id: PUB;ee319354982e4988b9072b1ed7785ba1
- version: 1.0

## Description

Key Gate Levels (KGL)

OVERVIEW
Key Gate Levels finds the price levels where crossing them historically produced outsized directional moves — far beyond what normal volatility (ATR) would suggest. These "gates" are not fixed pivots or manual S/R lines; they are statistically significant levels derived from the chart's own behavior.

The indicator scans recent history, measures the actual move that followed each closing price, compares that move to the ATR-expected range, clusters nearby significant prices into single levels, and ranks them by cumulative force. The strongest and most frequently confirmed levels are drawn as extending zones with directional labels.

HOW IT WORKS

1. Scan every bar in the lookback
For each closing price, the script looks ahead a configurable number of bars and records:
- the highest high reached (bullish potential)
- the lowest low reached (bearish potential)

2. Compare the move to normal volatility
The forward move is divided by the ATR at that bar. If the move exceeds the Acceleration Threshold (default 3 × ATR), the closing price is recorded as a candidate gate level, tagged bullish or bearish.

3. Cluster nearby prices
Candidate prices that lie within Cluster Width × ATR of an existing level are merged. The merged level becomes a running average of its clustered prices, weighted by how many candidates joined it. Each cluster tracks total force, directional bias, and number of hits.

4. Rank and filter
Levels are sorted by cumulative force. Levels with fewer than the minimum required hits are skipped. The hit requirement is auto-adjusted by timeframe:
- Below 3H: more hits required
- 4H to 12H: fewer hits
- Daily and above: fewer hits

5. Draw zones and labels
Each selected level is drawn as an extending horizontal zone whose transparency reflects how often it was confirmed. A label shows:
- direction arrow (bullish, bearish, or neutral)
- average force in ATR multiples
- number of historical hits
- calculation timeframe

6. Proximity highlight
When price approaches any stored gate level within Proximity Distance × ATR, the background is highlighted so you can see which level is currently in play.

INPUTS
Use Custom Timeframe: choose to calculate gates from the chart timeframe or a higher/lower custom timeframe.
Calculation Timeframe: the timeframe used for gate detection when custom mode is on.
Lookback Bars: how many bars to scan (100 to 5000).
Forward Measure Window: how many bars ahead to measure the resulting move (3 to 30).
ATR Period: period for ATR normalization.
Acceleration Threshold (ATR x): a move must exceed this × ATR to count.
Cluster Width (ATR x): merge gate prices within this distance.
Threshold: bias threshold for classifying a level as bullish or bearish vs neutral.
Max Levels: maximum zones to draw.
Zone Height (ATR x): half-height of each drawn zone box.
Min Hits per timeframe group: auto-scaled minimum confirmations.
Highlight Near Level: toggle the proximity background alert.
Proximity Distance (ATR x): how close price must be to trigger the background highlight.

HOW TO USE
- Watch the strongest levels as dynamic support/resistance.
- A bullish gate level below price can act as support.
- A bearish gate level above price can act as resistance.
- Neutral levels still matter but show mixed directional acceleration.
- The proximity highlight tells you when price is testing a key level in real time.
- Combine with your own entry rules; this indicator identifies the levels, not the entry.

ALERTS
"Near Gate Level" fires when price moves within the configured ATR distance of any active gate level.

## Source Code

````pine
//@version=6
indicator("Key Gate Levels", "KGL", overlay=true, max_boxes_count=500, max_labels_count=500)

// ─── CONCEPT ────────────────────────────────────────────────────────────────────
// STATISTICAL ACCELERATION GATES
//
// Scans recent history and finds price levels where crossing them produced
// outsized directional moves (far beyond normal volatility).
// These "gate levels" are where price accelerates — above = bullish, below = bearish.
//
// Method:
// 1. For each bar in the lookback, measure the actual move in the next N bars.
// 2. Compare to ATR-expected move. If actual >> expected → that price was a gate.
// 3. Cluster nearby gate prices into single levels.
// 4. Rank by cumulative force (how many times × how strong the acceleration was).
// 5. Display top levels as horizontal lines with direction arrows.
//
// This is purely statistical — no candle patterns, no pivots, no fixed formulas.
// It simply asks: "At which price levels did outsized moves historically begin?"

// ─── Inputs ─────────────────────────────────────────────────────────────────────
grpTf = "Timeframe"
useCustomTf = input.bool(true, "Use Custom Timeframe", group=grpTf,
             tooltip="OFF = use the chart timeframe. ON = calculate gate levels from the selected timeframe and project them onto the chart.")
calcTf      = input.timeframe("120", "Calculation Timeframe", group=grpTf)

// ─── Inputs ─────────────────────────────────────────────────────────────────────
grp1 = "Detection"
scanBack   = input.int(5000,  "Lookback Bars",                 minval=100, maxval=5000,           group=grp1,
             tooltip="How far back to scan for acceleration events")
fwdBars    = input.int(15,   "Forward Measure Window",        minval=3,   maxval=30,            group=grp1,
             tooltip="Bars ahead to measure the resulting move")
atrLen     = input.int(14,   "ATR Period",                    minval=5,   maxval=50,            group=grp1,
             tooltip="ATR period used to normalize move sizes")
movThresh  = input.float(3.0,"Acceleration Threshold (ATR x)",minval=1.0, maxval=5.0, step=0.25,group=grp1,
             tooltip="Forward move must exceed this × ATR to count as acceleration")
clusterW   = input.float(1,"Cluster Width (ATR x)",         minval=0.1, maxval=2.0, step=0.1, group=grp1,
             tooltip="Merge gate levels that are this close together")
threshold   = input.float(0.3," threshold",         minval=0.1, maxval=2.0, step=0.1, group=grp1,
             tooltip="Threshold to decide if bull/bear or neutral")

grp2 = "Display"
maxLevels  = input.int(500,    "Max Levels",                    minval=1,   maxval=1200,            group=grp2)
zoneHeight = input.float(0.3, "Zone Height (ATR x)",           minval=0.05, maxval=2.0, step=0.05, group=grp2,
             tooltip="Half-height of each zone box in ATR units")
minHitsLow = input.int(50,    "Min Hits (< 3H)",               minval=1,   maxval=200,             group=grp2,
             tooltip="Min hits for timeframes below 3 hours")
minHitsMid = input.int(10,    "Min Hits (4H–12H)",             minval=1,   maxval=200,             group=grp2,
             tooltip="Min hits for timeframes between 4 and 12 hours")
minHitsHi  = input.int(10,    "Min Hits (Daily+)",             minval=1,   maxval=200,             group=grp2,
             tooltip="Min hits for daily timeframe and above")

// Auto-select minHits based on calculation timeframe
tfToUse    = useCustomTf ? calcTf : timeframe.period
tfSeconds  = timeframe.in_seconds(tfToUse)
tfMinutes  = tfSeconds / 60
minHits    = tfMinutes < 181 ? minHitsLow : tfMinutes <= 721 ? minHitsMid : minHitsHi
showProx   = input.bool(true,"Highlight Near Level",                                            group=grp2)
proxDist   = input.float(0.3,"Proximity Distance (ATR x)",    minval=0.1, maxval=1.0, step=0.1, group=grp2)

grp3 = "Colors"
bullCol    = input.color(color.rgb(0, 230, 119, 69), "Bullish Level",   group=grp3)
bearCol    = input.color(color.rgb(255, 82, 82, 55), "Bearish Level",   group=grp3)
neutCol    = input.color(color.rgb(255, 235, 59, 40), "Neutral Level",   group=grp3)
proxCol    = input.color(#f0eee2, "Proximity Alert", group=grp3)

// ─── Pre-computed Series ────────────────────────────────────────────────────────
[tfTime, tfClose, tfHigh, tfLow, atrSeries] = request.security(syminfo.tickerid, tfToUse,
     [time, close, high, low, ta.atr(atrLen)],
     barmerge.gaps_off, barmerge.lookahead_off)

var int[]   tfTimes  = array.new_int()
var float[] tfCloses = array.new_float()
var float[] tfHighs  = array.new_float()
var float[] tfLows   = array.new_float()
var float[] tfAtrs   = array.new_float()

int tfTimesSize = array.size(tfTimes)
bool newTfBar = true
if tfTimesSize > 0
    newTfBar := tfTime != array.get(tfTimes, tfTimesSize - 1)
if newTfBar
    array.push(tfTimes, tfTime)
    array.push(tfCloses, tfClose)
    array.push(tfHighs, tfHigh)
    array.push(tfLows, tfLow)
    array.push(tfAtrs, atrSeries)
else
    int lastTfIdx = array.size(tfTimes) - 1
    array.set(tfCloses, lastTfIdx, tfClose)
    array.set(tfHighs, lastTfIdx, tfHigh)
    array.set(tfLows, lastTfIdx, tfLow)
    array.set(tfAtrs, lastTfIdx, atrSeries)

while array.size(tfTimes) > scanBack + fwdBars + 50
    array.shift(tfTimes)
    array.shift(tfCloses)
    array.shift(tfHighs)
    array.shift(tfLows)
    array.shift(tfAtrs)

// ─── Persistent Drawing Storage ─────────────────────────────────────────────────
var box[]   lvlBoxes  = array.new_box()
var label[] lvlLabels = array.new_label()

// ─── Store final level prices for proximity check ───────────────────────────────
var float[] finalLevels = array.new_float()

// ─── Proximity Detection (uses levels from previous bar's computation) ──────────
bool nearLevel = false
if showProx and array.size(finalLevels) > 0
    float curATR = nz(atrSeries, 0.0001)
    for i = 0 to array.size(finalLevels) - 1
        if math.abs(close - array.get(finalLevels, i)) <= proxDist * curATR
            nearLevel := true
            break

bgcolor(nearLevel ? color.new(proxCol, 88) : na, title="Near Gate Level")

// ─── Main Logic (recalculate on last bar) ───────────────────────────────────────
if barstate.islast
    // Clean previous drawings
    while array.size(lvlBoxes) > 0
        box.delete(array.pop(lvlBoxes))
    while array.size(lvlLabels) > 0
        label.delete(array.pop(lvlLabels))

    // Clear stored levels
    array.clear(finalLevels)

    // ─── Step 1: Collect candidate gate events ──────────────────────────────────
    float[] candPrice = array.new_float()
    float[] candForce = array.new_float()
    int[]   candDir   = array.new_int()

    int tfSize = array.size(tfCloses)
    int scanLimit = math.min(scanBack, tfSize - fwdBars - 1)
    if scanLimit >= 1
        for j = 1 to scanLimit
            int idx = tfSize - 1 - fwdBars - j
            float aJ = nz(array.get(tfAtrs, idx), 0.0001)
            float futHH = array.get(tfHighs, idx + 1)
            float futLL = array.get(tfLows, idx + 1)
            for fwd = 2 to fwdBars
                futHH := math.max(futHH, array.get(tfHighs, idx + fwd))
                futLL := math.min(futLL, array.get(tfLows, idx + fwd))
            float baseClose = array.get(tfCloses, idx)
            float bullMove = futHH - baseClose
            float bearMove = baseClose - futLL

            if bullMove > movThresh * aJ
                array.push(candPrice, baseClose)
                array.push(candForce, bullMove / aJ)
                array.push(candDir, 1)

            if bearMove > movThresh * aJ
                array.push(candPrice, baseClose)
                array.push(candForce, bearMove / aJ)
                array.push(candDir, -1)

    // ─── Step 2: Cluster nearby candidates into levels ──────────────────────────
    float[] clPrice  = array.new_float()
    float[] clHi     = array.new_float()
    float[] clLo     = array.new_float()
    float[] clForce  = array.new_float()
    float[] clBias   = array.new_float()
    int[]   clCount  = array.new_int()

    float curATR = array.size(tfAtrs) > 0 ? nz(array.get(tfAtrs, array.size(tfAtrs) - 1), 0.0001) : 0.0001
    float mergeD = clusterW * curATR
    int leftTime = array.size(tfTimes) > 0 ? array.get(tfTimes, math.max(0, array.size(tfTimes) - 1 - scanBack)) : time
    int rightTime = time + int(tfSeconds * 1000 * 25)

    if array.size(candPrice) > 0
        for i = 0 to array.size(candPrice) - 1
            float p = array.get(candPrice, i)
            float f = array.get(candForce, i)
            int   d = array.get(candDir, i)

            bool merged = false
            if array.size(clPrice) > 0
                for k = 0 to array.size(clPrice) - 1
                    if math.abs(p - array.get(clPrice, k)) <= mergeD
                        int cnt = array.get(clCount, k)
                        float avgP = (array.get(clPrice, k) * cnt + p) / (cnt + 1)
                        array.set(clPrice, k, avgP)
                        array.set(clHi,    k, math.max(array.get(clHi, k), p))
                        array.set(clLo,    k, math.min(array.get(clLo, k), p))
                        array.set(clForce, k, array.get(clForce, k) + f)
                        array.set(clBias,  k, array.get(clBias, k) + d * f)
                        array.set(clCount, k, cnt + 1)
                        merged := true
                        break

            if not merged
                array.push(clPrice, p)
                array.push(clHi,    p)
                array.push(clLo,    p)
                array.push(clForce, f)
                array.push(clBias,  d * f)
                array.push(clCount, 1)

    // ─── Step 3: Pick top N by force, draw them ─────────────────────────────────
    int showN = math.min(maxLevels, array.size(clPrice))

    if showN > 0
        for s = 0 to showN - 1
            // Find strongest remaining
            float maxF = -1.0
            int   maxIdx = -1
            for k = 0 to array.size(clForce) - 1
                if array.get(clForce, k) > maxF
                    maxF   := array.get(clForce, k)
                    maxIdx := k

            if maxIdx >= 0
                float lvlP  = array.get(clPrice, maxIdx)
                float bias  = array.get(clBias,  maxIdx)
                float force = array.get(clForce, maxIdx)
                int   cnt   = array.get(clCount, maxIdx)

                // Mark as used
                array.set(clForce, maxIdx, -1.0)

                // Skip levels below min hits threshold
                if cnt < minHits
                    continue

                // Store for proximity detection on next bars
                array.push(finalLevels, lvlP)

                // Direction and color
                float normBias = bias / force
                color lCol = normBias > threshold ? bullCol : normBias < -threshold ? bearCol : neutCol
                string dir = normBias > threshold ? "▲" : normBias < -threshold ? "▼" : "◆"
                float avgF = force / math.max(cnt, 1)

                // Zone box boundaries
                float halfH = curATR * zoneHeight
                float boxHi = lvlP + halfH
                float boxLo = lvlP - halfH
                int   alpha = math.max(95 - cnt * 2, 70)
                color fillC = color.new(lCol, alpha)
                color bordC = color.new(lCol, math.max(alpha, 70))
                int   bw    = cnt >= 10 ? 2 : 1

                // Draw box
                newBox = box.new(leftTime, boxHi, rightTime, boxLo,
                     xloc = xloc.bar_time,
                     border_color = bordC, border_width = bw,
                     bgcolor = fillC, extend = extend.right)
                array.push(lvlBoxes, newBox)

                // Draw label
                string txt = dir + " " + str.tostring(avgF, "#.#") + "x | " + str.tostring(cnt) + " hits | " + tfToUse
                newLbl = label.new(rightTime, lvlP, txt,
                     xloc      = xloc.bar_time,
                     style     = label.style_label_left,
                     color     = color.new(color.white, 100),
                     textcolor = lCol,
                     size      = size.small)
                array.push(lvlLabels, newLbl)

// ─── Alerts ───────────────────────────────────────────────────────────────────
alertcondition(nearLevel, "Near Gate Level", "Price approaching a key acceleration level")
````
