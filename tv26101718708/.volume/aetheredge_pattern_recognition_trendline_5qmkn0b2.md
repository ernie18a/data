# AetherEdge Pattern Recognition Trendline

- url: https://www.tradingview.com/script/5QmKn0b2/
- type: indicator
- pine_id: PUB;c18e6892f80a45d69d25e325f9d25f78
- version: 1.0

## Description

🖊️ Overview
AetherEdge Pattern Recognition Trendline is a next-generation automated pattern recognition indicator that fuses classical chart pattern theory with an AI scoring engine. It detects major patterns such as Head & Shoulders, Double Top/Bottom, Triangle, Wedge, Flag/Pennant, and Rectangle in real time, while quantifying their reliability through a 5-dimensional AI score covering shape fit, symmetry, volume profile, time profile, and trend context. It is the ultimate platform for fully automating the artisanal art of chart analysis.

🔶 Key Features

8 Major Pattern Detections: H&S, IH&S, DT, DB, Triangle, Wedge, Flag/Pennant, Rectangle
5-Dimensional AI Scoring: Shape / Symmetry / Volume / Time / Trend Context
Dynamic Pivot Analysis: Up to 60-pivot historical buffer
Target Zone Projection: Measured-Move-based price targets
Automatic Neckline Drawing: Visualizes breakout reference levels
ATR-Based Tolerance: Allows natural fluctuation in peak/trough heights
Trend Context Evaluation: Incorporates EMA21/55 bias for pattern validity
Break Confirmation Logic: ATR-coefficient-based false-signal filter
Pattern Lifecycle Management: Tracks Detected / Completed / Failed states
Stats Panel: Cumulative count of detections, completions, and failures

🧠 Technical Architecture

This indicator is an advanced system that redefines classical technical theory through AI scoring.

Pivot Detection: Detects pivot highs/lows over pivotLR bars and stores price, bar index, and type (high=1, low=-1) in a structured buffer.
Pattern Library: Each pattern requires at least minPivots pivots and is geometrically validated against shape rules (e.g., H&S: center peak highest, shoulders at similar levels).
Shape Fit Score: Normalizes the deviation from the theoretical ideal using ATR × atrTol.
Symmetry Score: Quantifies time/price symmetry between left and right halves; misshaped patterns score low.
Volume Profile Score: Compares average volume in the early and late halves of the pattern; healthy patterns typically decay in volume during the late phase.
Time Profile Score: Patterns under 15 bars are penalized (0.3), peak around 30 bars (1.0), decay above 80 bars, and become stale beyond 150.
Trend Context Score: Bullish patterns (IH&S, DB, etc.) score higher in uptrends; bearish patterns score higher in downtrends; neutral patterns gain bonus when a clear directional bias exists.
AI Composite Score: Weighted average of all five components, evaluated against the minScore threshold.
Pattern UDT: A type-safe structure holding name, startBar, endBar, neckline, target, stop, score, col, bullish, completed, failed, and line references.
Lifecycle Tracking: Maintains Detected / Completed / Failed counters via the stats array.

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (4H): pivotLR=5, minScore=0.55, atrTol=0.5, zoneFactor=1.0
ETH (1H): pivotLR=4, minScore=0.50, atrTol=0.6, projBars=30
SOL/XRP (15M): pivotLR=3, minScore=0.45, atrTol=0.7, breakConfirm=0.3
Long-Term (1D): pivotLR=8, minScore=0.65, maxLookback=300, zoneFactor=1.5
Tuning Guide:

Strict Mode: minScore=0.70, wShape=0.40 to capture only premium patterns
Relaxed Mode: minScore=0.40, atrTol=0.8 to detect a wider range
Trend-Focused: wTrend=0.30, wShape=0.20 to prioritize trend alignment
Volume-Focused: wVol=0.35 to surface only volume-backed patterns
Symmetry-Focused: wSym=0.30 for clean structures (great for H&S, DT/DB)
Short-Term Scalping: projBars=20, breakConfirm=0.1 for early entries
Long-Term Investing: zoneFactor=1.5–2.0 for larger targets

💡 How to Use in Practice

H&S/DT detected + neckline break: Bearish entry; use target zone as profit objective
IH&S/DB detected + neckline break: Bullish entry; hold until Measured Move target
Triangle detected: Wait for breakout; trade in the direction once breakConfirm is exceeded
Wedge detected: Rising wedge = bearish reversal; falling wedge = bullish reversal
Flag/Pennant: Trend-continuation pattern, ideal for pullback/retest entries
Rectangle: Range trades at extremes; breakouts confirm directionality
Multi-Timeframe: Higher-TF pattern + lower-TF break = high-confidence setup
AetherEdge Synergy: Combine with Quantum-Inspired Breakout Scanner for probability × shape double confirmation
Failed Pattern Edge: A "Failed" verdict often acts as a strong reverse signal

⚠️ Important Notes

Pivot confirmation introduces a pivotLR-bar lag
Patterns are drawn upon completion; exercise caution for real-time entries
Excessively low minScore increases false detections
Patterns longer than maxLookback are excluded
Multiple overlapping patterns may be drawn simultaneously
Volume Score accuracy degrades on instruments with unreliable volume data

🚨 Disclaimer

This indicator is a technical analysis tool provided for educational and research purposes only and does not constitute financial advice. AI scores are evaluations based on historical shape rules and statistical properties and do not guarantee future performance. All trading decisions are made at your own risk and should be accompanied by proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge Pattern Recognition Trendline", shorttitle="AE-PRT", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=300)

// ============================================================
// ▼ INPUTS
// ============================================================
grpDet = "🔍 Pattern Detection"
pivotLR    = input.int(5,    "Pivot Lookback/Forward",  minval=2, maxval=20, group=grpDet)
maxLookback= input.int(150,  "Max Pattern Bars",        minval=30, maxval=500, group=grpDet)
minPivots  = input.int(5,    "Min Pivots Required",     minval=4, maxval=10, group=grpDet)
minScore   = input.float(0.55,"Min AI Confidence Score",minval=0.30, maxval=0.95, step=0.05, group=grpDet, tooltip="0.55=中庸 / 0.70=厳格 / 0.40=緩和")
atrTol     = input.float(0.5,"Tolerance × ATR",         minval=0.1,  maxval=2.0,  step=0.1, group=grpDet, tooltip="ピーク／ボトム高さ等の許容差")

grpPat = "📐 Patterns to Detect"
detHS    = input.bool(true, "Head & Shoulders",       group=grpPat)
detIHS   = input.bool(true, "Inverse H&S",            group=grpPat)
detDT    = input.bool(true, "Double Top",             group=grpPat)
detDB    = input.bool(true, "Double Bottom",          group=grpPat)
detTri   = input.bool(true, "Triangle (Sym/Asc/Desc)",group=grpPat)
detWedge = input.bool(true, "Wedge (Rising/Falling)", group=grpPat)
detFlag  = input.bool(true, "Flag / Pennant",         group=grpPat)
detRect  = input.bool(true, "Rectangle (Range)",      group=grpPat)

grpAI = "🧠 AI Scoring Weights"
wShape  = input.float(0.30,"Shape Fit Weight",      minval=0, maxval=1, step=0.05, group=grpAI)
wSym    = input.float(0.20,"Symmetry Weight",       minval=0, maxval=1, step=0.05, group=grpAI)
wVol    = input.float(0.20,"Volume Profile Weight", minval=0, maxval=1, step=0.05, group=grpAI)
wTime   = input.float(0.15,"Time Profile Weight",   minval=0, maxval=1, step=0.05, group=grpAI)
wTrend  = input.float(0.15,"Trend Context Weight",  minval=0, maxval=1, step=0.05, group=grpAI)

grpProj = "🎯 Projection"
showZone   = input.bool(true,  "Show Target Zone",       group=grpProj)
zoneFactor = input.float(1.0,  "Measured Move × Factor", minval=0.5, maxval=3.0, step=0.1, group=grpProj)
projBars   = input.int(40,    "Target Projection Bars", minval=10, maxval=200, group=grpProj)
showSR     = input.bool(true,  "Show Support/Resistance",group=grpProj)
breakConfirm= input.float(0.2,"Breakout Confirm × ATR", minval=0.0, maxval=1.0, step=0.05, group=grpProj)

grpVis = "🎨 Visual"
colHS    = input.color(color.rgb(255,120,140),"H&S / DT Color",       group=grpVis)
colIHS   = input.color(color.rgb(120,230,180),"IH&S / DB Color",      group=grpVis)
colTri   = input.color(color.rgb(160,180,255),"Triangle Color",       group=grpVis)
colWedge = input.color(color.rgb(255,180,120),"Wedge Color",          group=grpVis)
colFlag  = input.color(color.rgb(220,160,255),"Flag/Pennant Color",   group=grpVis)
colRect  = input.color(color.rgb(180,200,180),"Rectangle Color",      group=grpVis)
colSR    = input.color(color.rgb(255,220,120),"Support/Resistance",   group=grpVis)
colTarget= input.color(color.rgb(100,220,255),"Target Zone",          group=grpVis)
colBroken= input.color(color.rgb(255,80,80),  "Broken / Failed",      group=grpVis)
showPanel= input.bool(true, "Show Stats Panel",                       group=grpVis)
panelPos = input.string("Top Right","Panel Position",options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grpVis)

// ============================================================
// ▼ HELPERS
// ============================================================
atrV   = ta.atr(14)
volSma = ta.sma(volume, 20)
rsiV   = ta.rsi(close, 14)
emaFast= ta.ema(close, 21)
emaSlow= ta.ema(close, 55)
trendBias = emaFast > emaSlow ? 1 : emaFast < emaSlow ? -1 : 0

ph = ta.pivothigh(high, pivotLR, pivotLR)
pl = ta.pivotlow(low,  pivotLR, pivotLR)

var array<float> piH_p = array.new<float>()
var array<int>   piH_b = array.new<int>()
var array<int>   piH_t = array.new<int>()

if not na(ph)
    array.push(piH_p, ph)
    array.push(piH_b, bar_index - pivotLR)
    array.push(piH_t, 1)
if not na(pl)
    array.push(piH_p, pl)
    array.push(piH_b, bar_index - pivotLR)
    array.push(piH_t, -1)

while array.size(piH_p) > 60
    array.shift(piH_p)
    array.shift(piH_b)
    array.shift(piH_t)

// ============================================================
// ▼ STATS COUNTER (array to allow modification inside functions)
// ============================================================
// stats[0] = totalDetected, [1] = totalCompleted, [2] = totalFailed
var array<int> stats = array.new<int>(3, 0)

incStat(int idx) =>
    array.set(stats, idx, array.get(stats, idx) + 1)

// ============================================================
// ▼ AI SCORING SUBROUTINES
// ============================================================
volumeProfileScore(int startBar, int endBar) =>
    int n = endBar - startBar
    float result = 0.5
    if n >= 5
        float earlyVol = 0.0
        float lateVol  = 0.0
        int half = n / 2
        if half > 0
            for i = 0 to half - 1
                int offs = bar_index - (startBar + i)
                if offs >= 0
                    earlyVol += nz(volume[offs])
        if n - half > 0
            for i = half to n - 1
                int offs = bar_index - (startBar + i)
                if offs >= 0
                    lateVol += nz(volume[offs])
        float avgEarly = earlyVol / math.max(half, 1)
        float avgLate  = lateVol  / math.max(n - half, 1)
        float ratio = avgLate / math.max(avgEarly, 1e-10)
        result := math.max(0.0, math.min(1.0, 1.2 - ratio * 0.6))
    result

timeProfileScore(int barsLength) =>
    float r = 0.3
    if barsLength < 15
        r := 0.3
    else if barsLength <= 30
        r := 0.7 + (barsLength - 15) / 15.0 * 0.3
    else if barsLength <= 80
        r := 1.0 - (barsLength - 30) / 50.0 * 0.2
    else
        r := math.max(0.3, 0.8 - (barsLength - 80) / 70.0 * 0.5)
    r

trendContextScore(int patternType) =>
    float r = 0.5
    if patternType == 1
        r := trendBias > 0 ? 1.0 : trendBias == 0 ? 0.6 : 0.3
    else if patternType == -1
        r := trendBias < 0 ? 1.0 : trendBias == 0 ? 0.6 : 0.3
    else
        r := trendBias != 0 ? 0.9 : 0.5
    r

aiScore(float shape, float sym, float vol, float tm, float trend) =>
    float raw  = wShape*shape + wSym*sym + wVol*vol + wTime*tm + wTrend*trend
    float sumW = wShape + wSym + wVol + wTime + wTrend
    raw / math.max(sumW, 1e-10)

// ============================================================
// ▼ PATTERN STORAGE
// ============================================================
type Pattern
    string name
    int    startBar
    int    endBar
    float  neckline
    float  target
    float  stop
    float  score
    color  col
    bool   bullish
    bool   completed
    bool   failed
    line   l1
    line   l2
    line   neck
    line   targetLine
    box    targetBox
    label  lb
    line   srHigh
    line   srLow

var array<Pattern> pats = array.new<Pattern>()
var int lastDetectBar = -1000

// ============================================================
// ▼ DRAW PATTERN HELPER
// ============================================================
drawPattern(string name, int sBar, int eBar, float p1, float p2, float p3, float p4, float p5, float neckline, float target, float stop, float score, color baseCol, bool bullish) =>
    Pattern pat = Pattern.new()
    pat.name      := name
    pat.startBar  := sBar
    pat.endBar    := eBar
    pat.neckline  := neckline
    pat.target    := target
    pat.stop      := stop
    pat.score     := score
    pat.col       := baseCol
    pat.bullish   := bullish
    pat.completed := false
    pat.failed    := false

    int lw = score > 0.75 ? 3 : score > 0.6 ? 2 : 1

    pat.l1 := line.new(sBar, p1, eBar, p5, color=color.new(baseCol, 30), width=lw, style=line.style_solid)
    pat.neck := line.new(sBar, neckline, eBar + projBars, neckline, color=color.new(baseCol, 0), width=lw, style=line.style_dashed, extend=extend.right)

    if showZone
        float zoneTop = bullish ? target + atrV * 0.5 : target - atrV * 0.5
        float zoneBot = bullish ? target - atrV * 0.5 : target + atrV * 0.5
        pat.targetBox  := box.new(eBar, math.max(zoneTop, zoneBot), eBar + projBars, math.min(zoneTop, zoneBot), bgcolor=color.new(colTarget, 80), border_color=color.new(colTarget, 30), border_width=1, border_style=line.style_dotted)
        pat.targetLine := line.new(eBar, target, eBar + projBars, target, color=color.new(colTarget, 0), width=1, style=line.style_dotted)

    if showSR
        float maxP = math.max(p1, math.max(p2, math.max(p3, math.max(p4, p5))))
        float minP = math.min(p1, math.min(p2, math.min(p3, math.min(p4, p5))))
        pat.srHigh := line.new(sBar, maxP, eBar + projBars, maxP, color=color.new(colSR, 30), width=1, style=line.style_dotted, extend=extend.right)
        pat.srLow  := line.new(sBar, minP, eBar + projBars, minP, color=color.new(colSR, 30), width=1, style=line.style_dotted, extend=extend.right)

    string emoji = bullish ? "🟢" : "🔴"
    string confLabel = score >= 0.75 ? "★★★" : score >= 0.60 ? "★★" : "★"
    pat.lb := label.new(eBar, bullish ? p5 + atrV * 1.5 : p5 - atrV * 1.5, emoji + " " + name + "\n" + confLabel + " " + str.tostring(math.round(score * 100)) + "%", color=color.new(baseCol, 20), textcolor=color.white, style=bullish ? label.style_label_down : label.style_label_up, size=size.small)

    array.push(pats, pat)
    incStat(0)  // totalDetected += 1

// ============================================================
// ▼ PATTERN DETECTORS
// ============================================================

// ----- Head & Shoulders -----
detectHS() =>
    bool found = false
    int sz = array.size(piH_p)
    if sz >= 5
        float p1 = array.get(piH_p, sz-5)
        int   b1 = array.get(piH_b, sz-5)
        int   t1 = array.get(piH_t, sz-5)
        float p2 = array.get(piH_p, sz-4)
        int   b2 = array.get(piH_b, sz-4)
        int   t2 = array.get(piH_t, sz-4)
        float p3 = array.get(piH_p, sz-3)
        int   b3 = array.get(piH_b, sz-3)
        int   t3 = array.get(piH_t, sz-3)
        float p4 = array.get(piH_p, sz-2)
        int   b4 = array.get(piH_b, sz-2)
        int   t4 = array.get(piH_t, sz-2)
        float p5 = array.get(piH_p, sz-1)
        int   b5 = array.get(piH_b, sz-1)
        int   t5 = array.get(piH_t, sz-1)

        if t1 == 1 and t2 == -1 and t3 == 1 and t4 == -1 and t5 == 1
            float tol = atrV * atrTol
            if p3 > p1 + tol * 0.5 and p3 > p5 + tol * 0.5
                float shoulderDiff = math.abs(p1 - p5) / atrV
                if shoulderDiff < atrTol * 2
                    float necklineDiff = math.abs(p2 - p4) / atrV
                    if necklineDiff < atrTol * 2
                        float shapeScore = math.max(0.0, 1.0 - shoulderDiff / (atrTol * 2))
                        float symScore   = math.max(0.0, 1.0 - necklineDiff / (atrTol * 2))
                        float volScore   = volumeProfileScore(b1, b5)
                        float timeScore  = timeProfileScore(b5 - b1)
                        float trendScore = trendContextScore(1)
                        float score = aiScore(shapeScore, symScore, volScore, timeScore, trendScore)

                        if score >= minScore and detHS
                            float neckline = (p2 + p4) / 2.0
                            float headHeight = p3 - neckline
                            float target = neckline - headHeight * zoneFactor
                            float stop   = p3 + atrV * 0.5
                            drawPattern("Head & Shoulders", b1, b5, p1, p2, p3, p4, p5, neckline, target, stop, score, colHS, false)
                            found := true
    found

// ----- Inverse Head & Shoulders -----
detectIHS() =>
    bool found = false
    int sz = array.size(piH_p)
    if sz >= 5
        float p1 = array.get(piH_p, sz-5)
        int   b1 = array.get(piH_b, sz-5)
        int   t1 = array.get(piH_t, sz-5)
        float p2 = array.get(piH_p, sz-4)
        int   b2 = array.get(piH_b, sz-4)
        int   t2 = array.get(piH_t, sz-4)
        float p3 = array.get(piH_p, sz-3)
        int   b3 = array.get(piH_b, sz-3)
        int   t3 = array.get(piH_t, sz-3)
        float p4 = array.get(piH_p, sz-2)
        int   b4 = array.get(piH_b, sz-2)
        int   t4 = array.get(piH_t, sz-2)
        float p5 = array.get(piH_p, sz-1)
        int   b5 = array.get(piH_b, sz-1)
        int   t5 = array.get(piH_t, sz-1)

        if t1 == -1 and t2 == 1 and t3 == -1 and t4 == 1 and t5 == -1
            float tol = atrV * atrTol
            if p3 < p1 - tol * 0.5 and p3 < p5 - tol * 0.5
                float shoulderDiff = math.abs(p1 - p5) / atrV
                if shoulderDiff < atrTol * 2
                    float necklineDiff = math.abs(p2 - p4) / atrV
                    if necklineDiff < atrTol * 2
                        float shapeScore = math.max(0.0, 1.0 - shoulderDiff / (atrTol * 2))
                        float symScore   = math.max(0.0, 1.0 - necklineDiff / (atrTol * 2))
                        float volScore   = volumeProfileScore(b1, b5)
                        float timeScore  = timeProfileScore(b5 - b1)
                        float trendScore = trendContextScore(-1)
                        float score = aiScore(shapeScore, symScore, volScore, timeScore, trendScore)

                        if score >= minScore and detIHS
                            float neckline = (p2 + p4) / 2.0
                            float headDepth = neckline - p3
                            float target = neckline + headDepth * zoneFactor
                            float stop   = p3 - atrV * 0.5
                            drawPattern("Inv. H&S", b1, b5, p1, p2, p3, p4, p5, neckline, target, stop, score, colIHS, true)
                            found := true
    found

// ----- Double Top -----
detectDT() =>
    bool found = false
    int sz = array.size(piH_p)
    if sz >= 3
        float p1 = array.get(piH_p, sz-3)
        int   b1 = array.get(piH_b, sz-3)
        int   t1 = array.get(piH_t, sz-3)
        float p2 = array.get(piH_p, sz-2)
        int   b2 = array.get(piH_b, sz-2)
        int   t2 = array.get(piH_t, sz-2)
        float p3 = array.get(piH_p, sz-1)
        int   b3 = array.get(piH_b, sz-1)
        int   t3 = array.get(piH_t, sz-1)

        if t1 == 1 and t2 == -1 and t3 == 1
            float topDiff = math.abs(p1 - p3) / atrV
            if topDiff < atrTol * 1.5 and (b3 - b1) >= 15
                float shapeScore = math.max(0.0, 1.0 - topDiff / (atrTol * 1.5))
                float symScore   = 0.7
                float volScore   = volumeProfileScore(b1, b3)
                float timeScore  = timeProfileScore(b3 - b1)
                float trendScore = trendContextScore(1)
                float score = aiScore(shapeScore, symScore, volScore, timeScore, trendScore)

                if score >= minScore and detDT
                    float neckline = p2
                    float height   = math.max(p1, p3) - neckline
                    float target   = neckline - height * zoneFactor
                    float stop     = math.max(p1, p3) + atrV * 0.5
                    drawPattern("Double Top", b1, b3, p1, p2, p3, p2, p3, neckline, target, stop, score, colHS, false)
                    found := true
    found

// ----- Double Bottom -----
detectDB() =>
    bool found = false
    int sz = array.size(piH_p)
    if sz >= 3
        float p1 = array.get(piH_p, sz-3)
        int   b1 = array.get(piH_b, sz-3)
        int   t1 = array.get(piH_t, sz-3)
        float p2 = array.get(piH_p, sz-2)
        int   b2 = array.get(piH_b, sz-2)
        int   t2 = array.get(piH_t, sz-2)
        float p3 = array.get(piH_p, sz-1)
        int   b3 = array.get(piH_b, sz-1)
        int   t3 = array.get(piH_t, sz-1)

        if t1 == -1 and t2 == 1 and t3 == -1
            float botDiff = math.abs(p1 - p3) / atrV
            if botDiff < atrTol * 1.5 and (b3 - b1) >= 15
                float shapeScore = math.max(0.0, 1.0 - botDiff / (atrTol * 1.5))
                float symScore   = 0.7
                float volScore   = volumeProfileScore(b1, b3)
                float timeScore  = timeProfileScore(b3 - b1)
                float trendScore = trendContextScore(-1)
                float score = aiScore(shapeScore, symScore, volScore, timeScore, trendScore)

                if score >= minScore and detDB
                    float neckline = p2
                    float depth    = neckline - math.min(p1, p3)
                    float target   = neckline + depth * zoneFactor
                    float stop     = math.min(p1, p3) - atrV * 0.5
                    drawPattern("Double Bottom", b1, b3, p1, p2, p3, p2, p3, neckline, target, stop, score, colIHS, true)
                    found := true
    found

// ----- Triangle / Wedge / Rectangle -----
detectTriWedge() =>
    bool found = false
    int sz = array.size(piH_p)
    if sz >= 4
        float p1 = array.get(piH_p, sz-4)
        int   b1 = array.get(piH_b, sz-4)
        int   t1 = array.get(piH_t, sz-4)
        float p2 = array.get(piH_p, sz-3)
        int   b2 = array.get(piH_b, sz-3)
        int   t2 = array.get(piH_t, sz-3)
        float p3 = array.get(piH_p, sz-2)
        int   b3 = array.get(piH_b, sz-2)
        int   t3 = array.get(piH_t, sz-2)
        float p4 = array.get(piH_p, sz-1)
        int   b4 = array.get(piH_b, sz-1)
        int   t4 = array.get(piH_t, sz-1)

        bool isHLHL = (t1 == 1 and t2 == -1 and t3 == 1 and t4 == -1)
        bool isLHLH = (t1 == -1 and t2 == 1 and t3 == -1 and t4 == 1)

        if isHLHL or isLHLH
            float upHigh1 = isHLHL ? p1 : p2
            float upHigh2 = isHLHL ? p3 : p4
            int   upBar1  = isHLHL ? b1 : b2
            int   upBar2  = isHLHL ? b3 : b4
            float dnLow1  = isHLHL ? p2 : p1
            float dnLow2  = isHLHL ? p4 : p3
            int   dnBar1  = isHLHL ? b2 : b1
            int   dnBar2  = isHLHL ? b4 : b3

            float upSlope = (upHigh2 - upHigh1) / math.max(upBar2 - upBar1, 1)
            float dnSlope = (dnLow2 - dnLow1)  / math.max(dnBar2 - dnBar1, 1)
            float upSlopeATR = upSlope / atrV
            float dnSlopeATR = dnSlope / atrV

            string patType = ""
            color  patCol  = colTri
            bool   bullish = trendBias >= 0
            float  tolFlat = 0.05

            if upSlopeATR < -tolFlat and dnSlopeATR > tolFlat
                patType := "Sym. Triangle"
                patCol := colTri
            else if math.abs(upSlopeATR) < tolFlat and dnSlopeATR > tolFlat
                patType := "Asc. Triangle"
                patCol := colTri
                bullish := true
            else if upSlopeATR < -tolFlat and math.abs(dnSlopeATR) < tolFlat
                patType := "Desc. Triangle"
                patCol := colTri
                bullish := false
            else if upSlopeATR > tolFlat and dnSlopeATR > tolFlat and dnSlopeATR > upSlopeATR * 1.2 and detWedge
                patType := "Rising Wedge"
                patCol := colWedge
                bullish := false
            else if upSlopeATR < -tolFlat and dnSlopeATR < -tolFlat and upSlopeATR < dnSlopeATR * 1.2 and detWedge
                patType := "Falling Wedge"
                patCol := colWedge
                bullish := true
            else if math.abs(upSlopeATR) < tolFlat and math.abs(dnSlopeATR) < tolFlat and detRect
                patType := "Rectangle"
                patCol := colRect
                bullish := trendBias >= 0

            bool isTriangle = str.contains(patType, "Triangle")
            bool typeAllowed = patType != "" and (isTriangle ? detTri : true)

            if typeAllowed
                int curBar = bar_index
                float upLineNow = upHigh2 + upSlope * (curBar - upBar2)
                float dnLineNow = dnLow2  + dnSlope * (curBar - dnBar2)

                float rangeNow  = upLineNow - dnLineNow
                float maxAll    = math.max(p1, math.max(p2, math.max(p3, p4)))
                float minAll    = math.min(p1, math.min(p2, math.min(p3, p4)))
                float initRange = maxAll - minAll
                float convergence = 1.0 - rangeNow / math.max(initRange, 1e-10)

                float shapeScore = patType == "Rectangle" ? 0.7 : math.max(0.3, math.min(1.0, convergence + 0.3))
                float symBase = 0.7
                if math.abs(upSlopeATR) > 0 and math.abs(dnSlopeATR) > 0
                    symBase := 1.0 - math.abs(math.abs(upSlopeATR) - math.abs(dnSlopeATR))
                float symScore   = math.min(1.0, math.max(0.0, symBase))
                float volScore   = volumeProfileScore(b1, b4)
                float timeScore  = timeProfileScore(b4 - b1)
                float trendScore = trendContextScore(0)
                float score = aiScore(shapeScore, symScore, volScore, timeScore, trendScore)

                if score >= minScore
                    float neckline = bullish ? upLineNow : dnLineNow
                    float height   = upLineNow - dnLineNow
                    float target   = bullish ? neckline + height * zoneFactor : neckline - height * zoneFactor
                    float stop     = bullish ? dnLineNow - atrV * 0.5 : upLineNow + atrV * 0.5
                    drawPattern(patType, b1, b4, p1, p2, p3, p4, p4, neckline, target, stop, score, patCol, bullish)
                    found := true
    found

// ----- Flag / Pennant -----
detectFlag() =>
    bool found = false
    int sz = array.size(piH_p)
    if sz >= 4
        int b1 = array.get(piH_b, sz-4)
        int b4 = array.get(piH_b, sz-1)

        int poleStart = math.max(0, b1 - 20)
        int poleOffs  = bar_index - poleStart

        if poleOffs >= 0
            float poleStartPrice = nz(close[poleOffs])
            float poleEndPrice = (array.get(piH_p, sz-4) + array.get(piH_p, sz-3)) / 2
            float poleSize = math.abs(poleEndPrice - poleStartPrice) / atrV

            if poleSize > 5.0
                bool poleBull = poleEndPrice > poleStartPrice

                float p1 = array.get(piH_p, sz-4)
                float p2 = array.get(piH_p, sz-3)
                float p3 = array.get(piH_p, sz-2)
                float p4 = array.get(piH_p, sz-1)
                float maxAll = math.max(p1, math.max(p2, math.max(p3, p4)))
                float minAll = math.min(p1, math.min(p2, math.min(p3, p4)))
                float consRange = maxAll - minAll
                float consATR = consRange / atrV

                if consATR < poleSize * 0.4 and (b4 - b1) <= 30
                    float shapeScore = math.max(0.4, math.min(1.0, 1.0 - consATR / (poleSize * 0.4)))
                    float symScore   = 0.75
                    float volScore   = volumeProfileScore(b1, b4)
                    float timeScore  = timeProfileScore(b4 - b1)
                    float trendScore = trendContextScore(0)
                    float score = aiScore(shapeScore, symScore, volScore, timeScore, trendScore)

                    if score >= minScore and detFlag
                        bool bullish = poleBull
                        float neckline = bullish ? maxAll : minAll
                        float poleLength = math.abs(poleEndPrice - poleStartPrice)
                        float target = bullish ? neckline + poleLength * zoneFactor : neckline - poleLength * zoneFactor
                        float stop   = bullish ? minAll - atrV * 0.3 : maxAll + atrV * 0.3
                        drawPattern(bullish ? "Bull Flag" : "Bear Flag", b1, b4, p1, p2, p3, p4, p4, neckline, target, stop, score, colFlag, bullish)
                        found := true
    found

// ============================================================
// ▼ DETECTION TRIGGER
// ============================================================
bool newPivot = not na(ph) or not na(pl)
bool canDetect = barstate.isconfirmed and newPivot and (bar_index - lastDetectBar > 3)

if canDetect
    bool any = false
    if not any and detHS
        any := detectHS()
    if not any and detIHS
        any := detectIHS()
    if not any and detDT
        any := detectDT()
    if not any and detDB
        any := detectDB()
    if not any and (detTri or detWedge or detRect)
        any := detectTriWedge()
    if not any and detFlag
        any := detectFlag()
    if any
        lastDetectBar := bar_index

// ============================================================
// ▼ MAINTAIN PATTERNS
// ============================================================
if barstate.isconfirmed and array.size(pats) > 0
    for i = 0 to array.size(pats) - 1
        Pattern p = array.get(pats, i)
        if not p.completed and not p.failed
            if p.bullish
                if close > p.neckline + atrV * breakConfirm
                    p.completed := true
                    incStat(1)
                    line.set_color(p.neck, color.new(p.col, 0))
                    line.set_width(p.neck, 3)
                    label.new(bar_index, close, "🚀 BREAKOUT", color=color.new(p.col, 20), textcolor=color.white, style=label.style_label_down, size=size.small)
                else if close < p.stop
                    p.failed := true
                    incStat(2)
                    line.set_color(p.l1, color.new(colBroken, 50))
                    line.set_color(p.neck, color.new(colBroken, 50))
                    line.set_style(p.neck, line.style_dotted)
                    label.set_text(p.lb, label.get_text(p.lb) + "\n❌ FAILED")
                    label.set_color(p.lb, color.new(colBroken, 30))
            else
                if close < p.neckline - atrV * breakConfirm
                    p.completed := true
                    incStat(1)
                    line.set_color(p.neck, color.new(p.col, 0))
                    line.set_width(p.neck, 3)
                    label.new(bar_index, close, "💥 BREAKDOWN", color=color.new(p.col, 20), textcolor=color.white, style=label.style_label_up, size=size.small)
                else if close > p.stop
                    p.failed := true
                    incStat(2)
                    line.set_color(p.l1, color.new(colBroken, 50))
                    line.set_color(p.neck, color.new(colBroken, 50))
                    line.set_style(p.neck, line.style_dotted)
                    label.set_text(p.lb, label.get_text(p.lb) + "\n❌ FAILED")
                    label.set_color(p.lb, color.new(colBroken, 30))

            array.set(pats, i, p)

    while array.size(pats) > 15
        Pattern old = array.shift(pats)
        line.delete(old.l1)
        line.delete(old.neck)
        if not na(old.targetLine)
            line.delete(old.targetLine)
        if not na(old.targetBox)
            box.delete(old.targetBox)
        if not na(old.srHigh)
            line.delete(old.srHigh)
        if not na(old.srLow)
            line.delete(old.srLow)
        label.delete(old.lb)

// ============================================================
// ▼ STATS PANEL
// ============================================================
panelPosition() =>
    string r = position.top_right
    if panelPos == "Top Right"
        r := position.top_right
    else if panelPos == "Top Left"
        r := position.top_left
    else if panelPos == "Bottom Right"
        r := position.bottom_right
    else if panelPos == "Bottom Left"
        r := position.bottom_left
    r

var table dash = table.new(panelPosition(), 2, 12, border_width=1)

if showPanel and barstate.islast
    int activeP    = 0
    int completedP = 0
    int failedP    = 0
    string activeList = ""
    if array.size(pats) > 0
        for i = 0 to array.size(pats) - 1
            Pattern p = array.get(pats, i)
            if p.completed
                completedP += 1
            else if p.failed
                failedP += 1
            else
                activeP += 1
                if str.length(activeList) < 40
                    activeList := activeList + (str.length(activeList) > 0 ? ", " : "") + p.name

    int totalDetectedV  = array.get(stats, 0)
    int totalCompletedV = array.get(stats, 1)
    int totalFailedV    = array.get(stats, 2)

    int totalRes  = totalCompletedV + totalFailedV
    float winRate = totalRes > 0 ? totalCompletedV / float(totalRes) * 100 : 0.0

    color bg     = color.new(color.black, 75)
    color accent = color.rgb(180, 200, 255)
    color fg     = color.white

    table.cell(dash, 0, 0, "🔍 AE-PRT",        bgcolor=color.new(accent, 30), text_color=color.white, text_size=size.normal)
    table.cell(dash, 1, 0, "Pattern AI",       bgcolor=color.new(accent, 30), text_color=color.white, text_size=size.small)

    table.cell(dash, 0, 1, "Total Detected",   bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(totalDetectedV), bgcolor=bg, text_color=accent, text_size=size.normal)

    table.cell(dash, 0, 2, "Active",           bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(activeP),   bgcolor=bg, text_color=color.yellow, text_size=size.small)

    table.cell(dash, 0, 3, "Completed",        bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(totalCompletedV), bgcolor=bg, text_color=color.lime, text_size=size.small)

    table.cell(dash, 0, 4, "Failed",           bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(totalFailedV),    bgcolor=bg, text_color=colBroken, text_size=size.small)

    table.cell(dash, 0, 5, "Success Rate",     bgcolor=bg, text_color=fg, text_size=size.small)
    color wRateCol = winRate >= 60 ? color.lime : winRate >= 40 ? color.yellow : color.orange
    table.cell(dash, 1, 5, totalRes > 0 ? str.tostring(winRate, "0.0") + "%" : "—", bgcolor=bg, text_color=wRateCol, text_size=size.normal)

    table.cell(dash, 0, 6, "Trend Bias",       bgcolor=bg, text_color=fg, text_size=size.small)
    string biasStr = trendBias > 0 ? "▲ Up" : trendBias < 0 ? "▼ Down" : "↔ Neutral"
    color  biasCol = trendBias > 0 ? color.lime : trendBias < 0 ? colBroken : color.gray
    table.cell(dash, 1, 6, biasStr, bgcolor=bg, text_color=biasCol, text_size=size.small)

    table.cell(dash, 0, 7, "Min Confidence",   bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 7, str.tostring(math.round(minScore * 100)) + "%", bgcolor=bg, text_color=accent, text_size=size.small)

    table.cell(dash, 0, 8, "RSI(14)",          bgcolor=bg, text_color=fg, text_size=size.small)
    color rsiCol = rsiV >= 70 ? colBroken : rsiV <= 30 ? color.lime : fg
    table.cell(dash, 1, 8, str.tostring(rsiV, "0.0"), bgcolor=bg, text_color=rsiCol, text_size=size.small)

    table.cell(dash, 0, 9, "ATR(14)",          bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 9, str.tostring(atrV, "0.00000"), bgcolor=bg, text_color=fg, text_size=size.small)

    table.cell(dash, 0,10, "Pivots Tracked",   bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1,10, str.tostring(array.size(piH_p)), bgcolor=bg, text_color=fg, text_size=size.small)

    table.cell(dash, 0,11, "Active Patterns",  bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1,11, activeP > 0 ? activeList : "None", bgcolor=bg, text_color=color.yellow, text_size=size.small)

// ============================================================
// ▼ ALERTS
// ============================================================
bool newPatternAny = false
bool newBreakout   = false
bool newBreakdown  = false
bool newFailure    = false

if barstate.isconfirmed and array.size(pats) > 0
    for i = 0 to array.size(pats) - 1
        Pattern p = array.get(pats, i)
        if p.completed and p.endBar < bar_index and bar_index - p.endBar < 30
            if p.bullish
                newBreakout := true
            else
                newBreakdown := true
        if p.failed and bar_index - p.endBar < 30
            newFailure := true

newPatternAny := lastDetectBar == bar_index

alertcondition(newPatternAny, title="AE-PRT: New Pattern Detected", message="新しいチャートパターンが検出されました。")
alertcondition(newBreakout,   title="AE-PRT: Bullish Breakout",     message="強気パターンのブレイクアウトが確認されました。")
alertcondition(newBreakdown,  title="AE-PRT: Bearish Breakdown",    message="弱気パターンのブレイクダウンが確認されました。")
alertcondition(newFailure,    title="AE-PRT: Pattern Failed",       message="パターンがストップ突破により失敗しました。")

plotshape(newPatternAny, title="Pattern Detected", style=shape.diamond, location=location.belowbar, color=color.new(color.aqua, 30), size=size.tiny)
````
