# AetherEdge KNN Breakout Fortress

- url: https://www.tradingview.com/script/14PzySpq/
- type: indicator
- pine_id: PUB;996159d8b6eb49b8a3af52c245089fcb
- version: 1.0

## Description

🖊️ Overview
AetherEdge KNN Breakout Fortress is a revolutionary fortress-style indicator that automatically detects price congestion zones (walls) via K-Means clustering and uses a KNN classifier to distinguish "real breakouts" from "fake breakouts" in real time. Every breakout becomes labeled training data after a confirmation window, allowing the system to evolve and adapt to your specific market's wall patterns. End the era of being trapped by fake-outs — this is the next-generation tool built exclusively for breakout strategy.

🔶 Key Features

K-Means Zone Detection: Lloyd's algorithm auto-clusters key price levels
Volume-Weighted Seeding: Volume-weighted price-point clustering
7D KNN Classifier: Density, distance, volatility, RSI, BB-width, age, touches
Real vs Fake Classification: Probability-based wall strength color coding
Pending Learning: Labels assigned N bars after break, then memory updates
Volume Confirmation: Breakouts validated only above volMult threshold
ATR Buffer: Filters out noise-level breaks
Dynamic Zone Extension: Post-break zone projection
Stats Dashboard: Real/fake counts visualization

🧠 Technical Architecture

This indicator is an AI-driven decision system designed to "see through the true nature of every wall."

K-Means Zone Detection: Collects high/low/close price points within lookback, applies volume weighting, then iterates Lloyd's algorithm (kIters passes) to optimize kClusters centroids. Only clusters above minDensity become zones.
Quantile Seeding: Initial centroids placed via quantiles for deterministic, well-spread initialization (more stable than random).
Zone Construction: Each centroid is bounded by ±zoneWidth × ATR and rendered as a box. Resistance/support classification dynamically based on relative position to current price.
7D Feature Extraction: ①Normalized density, ②distance from price (ATR units), ③volatility regime, ④RSI at formation, ⑤BB width, ⑥age, ⑦approach count.
KNN Fortress Classifier: Stores up to maxMemory labeled past samples ("held = 1.0" / "broken = 0.0"). New zones queried via Top-K neighbor search to compute probability scores.
Pending Learning: At break events, features and direction stored in pending arrays. After confirmBars, real outcomes (rejected or continued) determine the label, then added to memory.
Real vs Fake Threshold: Score ≥ realThresh = strong wall (green); ≤ fakeThresh = weak wall (orange); middle = neutral (gray).
Break Detection: Validated when price exceeds breakBuf × ATR with volume above volMult, triggering zone extension display.
⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (4H): lookback=150, kClusters=6, refreshN=15, realThresh=0.60
ETH (1H): lookback=120, kClusters=5, refreshN=10, fakeThresh=0.40
SOL/XRP (15M): lookback=100, kClusters=5, refreshN=8, breakBuf=0.15
Long-Term (1D): lookback=300, kClusters=8, refreshN=20, minDensity=6
Parameter Tuning:

Too many zones: Reduce kClusters to 4, raise minDensity to 6
Too few zones: Expand lookback to 200, lower minDensity to 3
Choppy markets: Raise fakeThresh to 0.45 and breakBuf to 0.20
Strong trends: Lower realThresh to 0.50 for early genuine break capture
Faster learning: Shorten confirmBars to 3 (higher mislabel risk)
Conservative learning: Set confirmBars=10 for high-confidence labels only

💡 How to Use in Practice

Strong Wall Reversal: Counter-trade tags on green strong walls
True Breakout Follow: Break of a strong wall = high-conviction trend start
Weak Wall Trap Avoidance: Skip breaks on orange walls, prepare reversal entries
Double Wall Strategy: Consecutive strong walls form a fortress S/R cluster
Multi-Timeframe: Use 1D strong walls as precision entry zones on 1H
AetherEdge Combinations: Overlap with AI Trendline Architect's top-scored lines = elite zone

⚠️ Important Notes

KNN memory requires 30–50 initial samples for reliable scores
Memory and stats reset on indicator reload
Too-small refreshN causes flickering zone updates
Flash crashes or gaps can distort density measurements
K-Means operates on 1D price space — extreme outliers may bias clustering

🚨 Disclaimer

This indicator is provided for educational and research purposes only and does not constitute financial advice. AI classifications and probability scores are based on historical data and do not guarantee future performance. All trading decisions are made at your own risk and should be accompanied by proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge KNN Breakout Fortress", shorttitle="AE-KBF", overlay=true, max_boxes_count=200, max_lines_count=100, max_labels_count=300)

// ============================================================
// ▼ INPUTS
// ============================================================
grpClus = "🎯 K-Means Zone Detection"
lookback   = input.int(150, "Lookback Window",        minval=50,  maxval=500, group=grpClus)
kClusters  = input.int(6,   "K (zones)",              minval=3,   maxval=10,  group=grpClus)
kIters     = input.int(8,   "K-means Iterations",     minval=3,   maxval=20,  group=grpClus, tooltip="Lloyd's algorithm passes per refresh")
refreshN   = input.int(15,  "Refresh Every N Bars",   minval=5,   maxval=50,  group=grpClus)
minDensity = input.int(4,   "Min Cluster Density",    minval=2,   maxval=20,  group=grpClus, tooltip="クラスタ採用に必要な最小タッチ数")
zoneWidth  = input.float(0.6,"Zone Width (× ATR)",    minval=0.2, maxval=2.0, step=0.1, group=grpClus)

grpKNN = "🧠 KNN Fortress Classifier"
knnK         = input.int(7,    "K Neighbors",          minval=3,   maxval=21,  group=grpKNN)
maxMemory    = input.int(150,  "Memory Capacity",       minval=50,  maxval=400, group=grpKNN)
realThresh   = input.float(0.60, "Real Breakout Score", minval=0.40, maxval=0.95, step=0.01, group=grpKNN)
fakeThresh   = input.float(0.40, "Fake Breakout Score", minval=0.05, maxval=0.60, step=0.01, group=grpKNN)
confirmBars  = input.int(5,    "Confirmation Window",   minval=2,   maxval=20,  group=grpKNN, tooltip="ブレイク後この期間で結果を判定し学習")

grpBreak = "💥 Break Detection"
breakBuf  = input.float(0.10, "Break Buffer (× ATR)", minval=0.0, maxval=1.0, step=0.05, group=grpBreak)
volMult   = input.float(1.2,  "Vol Confirm Multiplier", minval=0.5, maxval=3.0, step=0.1, group=grpBreak)
extendBars = input.int(50,   "Zone Extend on Break",  minval=10, maxval=200, group=grpBreak)

grpVis = "🎨 Visuals"
strongCol  = input.color(color.rgb(40,  200, 160), "Strong Wall (Real)",        group=grpVis)
weakCol    = input.color(color.rgb(255, 170,  60), "Weak Wall (Fake-prone)",    group=grpVis)
neutralCol = input.color(color.rgb(140, 150, 180), "Neutral Wall",              group=grpVis)
brkUpCol   = input.color(color.rgb(60,  220, 130), "Bullish Break Arrow",       group=grpVis)
brkDnCol   = input.color(color.rgb(240, 80,  120), "Bearish Break Arrow",       group=grpVis)
showScore  = input.bool(true, "Show Probability Labels", group=grpVis)
showStats  = input.bool(true, "Show Stats Dashboard",    group=grpVis)

// ============================================================
// ▼ CONTEXT
// ============================================================
atrV   = ta.atr(14)
atrV50 = ta.atr(50)
volMA  = ta.sma(volume, 20)
rsiV   = ta.rsi(close, 14)
bbW    = (ta.sma(close, 20) + 2*ta.stdev(close, 20)) - (ta.sma(close, 20) - 2*ta.stdev(close, 20))
bbWN   = bbW / math.max(close, 1e-10)

// ============================================================
// ▼ TYPES
// ============================================================
type Zone
    box   bx
    label lbl
    float center
    float upper
    float lower
    int   density
    float score        // KNN probability of being a "real wall"
    bool  isResistance
    int   created
    bool  broken
    int   breakBar
    box   extBox

type Sample
    float f1   // density normalized
    float f2   // distance from current price (ATR)
    float f3   // volatility regime
    float f4   // RSI context at zone formation
    float f5   // BB width
    float f6   // age (bars since formation)
    float f7   // approach count
    float label   // 1.0 = held / true wall; 0.0 = faked / broken cleanly

// ============================================================
// ▼ STORAGE
// ============================================================
var array<Zone>   zones    = array.new<Zone>()
var array<Sample> memory   = array.new<Sample>()

// Pending break tracking for delayed labeling
var array<int>   pendBar    = array.new<int>()
var array<float> pendF1     = array.new<float>()
var array<float> pendF2     = array.new<float>()
var array<float> pendF3     = array.new<float>()
var array<float> pendF4     = array.new<float>()
var array<float> pendF5     = array.new<float>()
var array<float> pendF6     = array.new<float>()
var array<float> pendF7     = array.new<float>()
var array<float> pendLevel  = array.new<float>()
var array<int>   pendDir    = array.new<int>()  // 1=up break, -1=down break

// Stats
var int  totalRealBreaks = 0
var int  totalFakeBreaks = 0

// ============================================================
// ▼ K-MEANS CLUSTERING (Lloyd's algorithm, 1D on price points)
// ============================================================
runKMeans() =>
    // Build dataset: highs, lows, closes from the lookback window with weights
    pricesArr = array.new<float>()
    weightsArr = array.new<float>()
    n = math.min(lookback, bar_index)
    for i = 0 to n - 1
        // weight by relative volume — higher vol = more important price action
        w = volume[i] > 0 and volMA[i] > 0 ? math.min(volume[i] / volMA[i], 3.0) : 1.0
        array.push(pricesArr, high[i])
        array.push(weightsArr, w)
        array.push(pricesArr, low[i])
        array.push(weightsArr, w)
        array.push(pricesArr, close[i])
        array.push(weightsArr, w * 1.2)   // closes weighted slightly more
    
    // Initialize centroids — quantile-based seeding (deterministic, well-spread)
    sorted = array.copy(pricesArr)
    array.sort(sorted, order.ascending)
    nP = array.size(sorted)
    centroids = array.new<float>()
    for k = 0 to kClusters - 1
        idx = math.round((k + 0.5) / kClusters * (nP - 1))
        array.push(centroids, array.get(sorted, idx))
    
    // Lloyd's iterations
    assign = array.new<int>(nP, 0)
    for it = 0 to kIters - 1
        // Assignment step
        for p = 0 to nP - 1
            pv = array.get(pricesArr, p)
            bestK = 0
            bestD = math.abs(pv - array.get(centroids, 0))
            for k = 1 to kClusters - 1
                d = math.abs(pv - array.get(centroids, k))
                if d < bestD
                    bestD := d
                    bestK := k
            array.set(assign, p, bestK)
        // Update step (weighted mean)
        for k = 0 to kClusters - 1
            sumW = 0.0
            sumPW = 0.0
            for p = 0 to nP - 1
                if array.get(assign, p) == k
                    w = array.get(weightsArr, p)
                    sumPW += array.get(pricesArr, p) * w
                    sumW  += w
            if sumW > 0
                array.set(centroids, k, sumPW / sumW)
    
    // Compute density (count of points assigned per cluster)
    densities = array.new<int>(kClusters, 0)
    for p = 0 to nP - 1
        k = array.get(assign, p)
        array.set(densities, k, array.get(densities, k) + 1)
    
    [centroids, densities]

// ============================================================
// ▼ FEATURE EXTRACTION
// ============================================================
buildFeatures(float center, int density, bool isRes, int age) =>
    f1 = math.min(density / 30.0, 2.0)
    f2 = (close - center) / math.max(atrV, 1e-10)
    f3 = (atrV / math.max(atrV50, 1e-10)) - 1.0
    f4 = (rsiV - 50.0) / 50.0
    f5 = math.min(bbWN * 50.0, 2.0)
    f6 = math.min(age / 100.0, 2.0)
    // approach count: how many times price came within ATR of this zone
    appr = 0
    look = math.min(age, 80)
    if look > 1
        for i = 0 to look - 1
            if math.abs(close[i] - center) < atrV * 0.8
                appr += 1
    f7 = math.min(appr / 15.0, 2.0)
    [f1, f2, f3, f4, f5, f6, f7]

// ============================================================
// ▼ KNN CLASSIFIER — weighted voting across memory
// ============================================================
knnPredict(float f1, float f2, float f3, float f4, float f5, float f6, float f7) =>
    nMem = array.size(memory)
    float prob = 0.5
    if nMem >= knnK
        dists  = array.new<float>()
        labels = array.new<float>()
        for i = 0 to nMem - 1
            s = array.get(memory, i)
            d = math.sqrt(
                 math.pow(s.f1 - f1, 2) +
                 math.pow(s.f2 - f2, 2) +
                 math.pow(s.f3 - f3, 2) +
                 math.pow(s.f4 - f4, 2) +
                 math.pow(s.f5 - f5, 2) +
                 math.pow(s.f6 - f6, 2) +
                 math.pow(s.f7 - f7, 2))
            array.push(dists, d)
            array.push(labels, s.label)
        sumW = 0.0
        sumL = 0.0
        for k = 0 to knnK - 1
            minIdx = 0
            minD   = array.get(dists, 0)
            nD     = array.size(dists)
            for j = 1 to nD - 1
                v = array.get(dists, j)
                if v < minD
                    minD := v
                    minIdx := j
            w = 1.0 / (1.0 + minD * minD)   // gaussian-like weighting
            sumL += array.get(labels, minIdx) * w
            sumW += w
            array.set(dists, minIdx, 1e9)
        prob := sumW > 0 ? sumL / sumW : 0.5
    prob

// ============================================================
// ▼ ZONE COLOR PICKER
// ============================================================
zoneColor(float score) =>
    score >= realThresh ? strongCol : score <= fakeThresh ? weakCol : neutralCol

// ============================================================
// ▼ DUPLICATE / OVERLAP CHECK
// ============================================================
isDuplicateZone(float center) =>
    dup = false
    n = array.size(zones)
    if n > 0
        for i = 0 to n - 1
            z = array.get(zones, i)
            if not z.broken and math.abs(z.center - center) < atrV * 0.7
                dup := true
                break
    dup

// ============================================================
// ▼ ZONE REFRESH — runs every refreshN bars
// ============================================================
doRefresh = (bar_index % refreshN == 0) and bar_index > lookback

if doRefresh
    [centroids, densities] = runKMeans()
    
    // Clear non-broken zones to rebuild current map (broken zones persist as history)
    if array.size(zones) > 0
        i = array.size(zones) - 1
        while i >= 0
            z = array.get(zones, i)
            if not z.broken
                box.delete(z.bx)
                if not na(z.lbl)
                    label.delete(z.lbl)
                array.remove(zones, i)
            i := i - 1
    
    // Build new zones from clusters
    for k = 0 to kClusters - 1
        cen = array.get(centroids, k)
        den = array.get(densities, k)
        if den >= minDensity and not isDuplicateZone(cen)
            isRes = cen > close
            half  = atrV * zoneWidth * 0.5
            up    = cen + half
            lo    = cen - half
            
            [f1, f2, f3, f4, f5, f6, f7] = buildFeatures(cen, den, isRes, refreshN)
            score = knnPredict(f1, f2, f3, f4, f5, f6, f7)
            zCol  = zoneColor(score)
            transFill = math.round(70 + (1.0 - math.abs(score - 0.5) * 2.0) * 15)
            
            bx = box.new(bar_index - refreshN, up, bar_index + 5, lo,
                  border_color=color.new(zCol, 50),
                  bgcolor=color.new(zCol, transFill),
                  border_width=1, extend=extend.right)
            
            lbl = label(na)
            if showScore
                txt = (isRes ? "R " : "S ") + str.tostring(score, "0.00") + " | d=" + str.tostring(den)
                lbl := label.new(bar_index + 5, cen, txt,
                      color=color.new(zCol, 25), textcolor=color.white,
                      style=label.style_label_left, size=size.tiny)
            
            z = Zone.new(bx, lbl, cen, up, lo, den, score, isRes, bar_index, false, 0, na)
            array.push(zones, z)

// ============================================================
// ▼ BREAK DETECTION
// ============================================================
volSurge = volume > volMA * volMult

var bool fireUp = false
var bool fireDn = false
fireUp := false
fireDn := false

if array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        z = array.get(zones, i)
        if not z.broken
            // Resistance break upward
            brokeUp = not z.isResistance ? false : close > z.upper + atrV * breakBuf and volSurge
            // Support break downward
            brokeDn = z.isResistance ? false : close < z.lower - atrV * breakBuf and volSurge
            
            if brokeUp or brokeDn
                z.broken := true
                z.breakBar := bar_index
                
                // Stop extending the original box
                box.set_extend(z.bx, extend.none)
                box.set_right(z.bx, bar_index)
                
                // Draw extension box (history of broken wall)
                histCol = brokeUp ? brkUpCol : brkDnCol
                z.extBox := box.new(bar_index, z.upper, bar_index + extendBars, z.lower,
                      border_color=color.new(histCol, 70),
                      bgcolor=color.new(histCol, 88),
                      border_width=1, border_style=line.style_dashed)
                
                // Draw arrow
                if brokeUp
                    label.new(bar_index, z.lower - atrV * 0.5, "▲",
                          color=color.new(brkUpCol, 0), textcolor=color.white,
                          style=label.style_label_up, size=size.normal)
                    fireUp := true
                else
                    label.new(bar_index, z.upper + atrV * 0.5, "▼",
                          color=color.new(brkDnCol, 0), textcolor=color.white,
                          style=label.style_label_down, size=size.normal)
                    fireDn := true
                
                // Score-tagged break label
                if showScore
                    tag = z.score >= realThresh ? "REAL" : z.score <= fakeThresh ? "FAKE?" : "BREAK"
                    tagCol = z.score >= realThresh ? strongCol : z.score <= fakeThresh ? weakCol : neutralCol
                    label.new(bar_index, brokeUp ? z.upper + atrV * 1.2 : z.lower - atrV * 1.2,
                          tag + " " + str.tostring(z.score, "0.00"),
                          color=color.new(tagCol, 30), textcolor=color.white,
                          style=brokeUp ? label.style_label_down : label.style_label_up, size=size.small)
                
                // Stage for delayed learning
                age = bar_index - z.created
                [f1, f2, f3, f4, f5, f6, f7] = buildFeatures(z.center, z.density, z.isResistance, age)
                array.push(pendBar, bar_index)
                array.push(pendF1, f1)
                array.push(pendF2, f2)
                array.push(pendF3, f3)
                array.push(pendF4, f4)
                array.push(pendF5, f5)
                array.push(pendF6, f6)
                array.push(pendF7, f7)
                array.push(pendLevel, z.center)
                array.push(pendDir, brokeUp ? 1 : -1)
                
                array.set(zones, i, z)

// ============================================================
// ▼ DELAYED LABELING — confirm if break was REAL or FAKE
// ============================================================
if array.size(pendBar) > 0
    i = array.size(pendBar) - 1
    while i >= 0
        b   = array.get(pendBar, i)
        if bar_index - b >= confirmBars
            lvl = array.get(pendLevel, i)
            dir = array.get(pendDir, i)
            // REAL = price stayed beyond level; FAKE = price returned through it
            label_y = 0.0
            if dir == 1
                // Up break — real if close still above level
                label_y := close > lvl ? 1.0 : 0.0
            else
                // Down break — real if close still below level
                label_y := close < lvl ? 1.0 : 0.0
            
            if label_y > 0.5
                totalRealBreaks += 1
            else
                totalFakeBreaks += 1
            
            // Label semantics for the FORTRESS classifier:
            //   1.0 = real wall (held until decisive break = quality wall)
            //   0.0 = fake-prone wall (broke and immediately reversed)
            wallLabel = label_y  // real break => wall was strong = 1
            
            s = Sample.new(
                  array.get(pendF1, i),
                  array.get(pendF2, i),
                  array.get(pendF3, i),
                  array.get(pendF4, i),
                  array.get(pendF5, i),
                  array.get(pendF6, i),
                  array.get(pendF7, i),
                  wallLabel)
            array.push(memory, s)
            if array.size(memory) > maxMemory
                array.shift(memory)
            
            // Pop pending entry
            array.remove(pendBar, i)
            array.remove(pendF1, i)
            array.remove(pendF2, i)
            array.remove(pendF3, i)
            array.remove(pendF4, i)
            array.remove(pendF5, i)
            array.remove(pendF6, i)
            array.remove(pendF7, i)
            array.remove(pendLevel, i)
            array.remove(pendDir, i)
        i := i - 1

// ============================================================
// ▼ STATS DASHBOARD
// ============================================================
var table dash = table.new(position.top_right, 2, 6, border_width=1)
if showStats and barstate.islast
    activeCount = 0
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            z = array.get(zones, i)
            if not z.broken
                activeCount += 1
    totalBrk  = totalRealBreaks + totalFakeBreaks
    realRate  = totalBrk > 0 ? (totalRealBreaks * 100.0 / totalBrk) : 0.0
    bgC       = color.new(color.black, 75)
    txC       = color.white
    
    table.cell(dash, 0, 0, "🏰 KBF FORTRESS",  bgcolor=color.new(strongCol, 50), text_color=color.white, text_size=size.normal)
    table.cell(dash, 1, 0, "v1.0",             bgcolor=color.new(strongCol, 50), text_color=color.white, text_size=size.small)
    
    table.cell(dash, 0, 1, "Active Walls",     bgcolor=bgC, text_color=txC, text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(activeCount), bgcolor=bgC, text_color=txC, text_size=size.small)
    
    table.cell(dash, 0, 2, "Memory",           bgcolor=bgC, text_color=txC, text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(array.size(memory)) + "/" + str.tostring(maxMemory), bgcolor=bgC, text_color=txC, text_size=size.small)
    
    table.cell(dash, 0, 3, "Real Breaks",      bgcolor=bgC, text_color=color.new(strongCol, 0), text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(totalRealBreaks), bgcolor=bgC, text_color=color.new(strongCol, 0), text_size=size.small)
    
    table.cell(dash, 0, 4, "Fake Breaks",      bgcolor=bgC, text_color=color.new(weakCol, 0), text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(totalFakeBreaks), bgcolor=bgC, text_color=color.new(weakCol, 0), text_size=size.small)
    
    table.cell(dash, 0, 5, "Real %",           bgcolor=bgC, text_color=txC, text_size=size.small)
    table.cell(dash, 1, 5, str.tostring(realRate, "0.0") + "%", bgcolor=bgC, text_color=txC, text_size=size.small)

// ============================================================
// ▼ ALERTS
// ============================================================
alertcondition(fireUp, title="AE-KBF → Wall Break UP",   message="AE-KBF: Resistance wall broken upward")
alertcondition(fireDn, title="AE-KBF → Wall Break DOWN", message="AE-KBF: Support wall broken downward")

plot(array.size(zones),  title="Total Zones",  display=display.data_window)
plot(array.size(memory), title="Memory Size",  display=display.data_window)
````
