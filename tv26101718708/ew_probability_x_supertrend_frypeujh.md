# EW Probability x SuperTrend

- url: https://www.tradingview.com/script/FrYPEuJh-EW-Probability-x-SuperTrend/
- type: indicator
- pine_id: PUB;b7a177d3823b462a8d16d631a60c3b79
- version: 5.0

## Description

[i][b]Elliott Wave Probability × SuperTrend [EWPS]
User Description & Guide[/b][/i]

￼
[b]1. What Is EWPS?[/b]
EWPS fuses classical Elliott Wave pattern recognition with a dynamic ATR trailing stop (SuperTrend). Unlike standard SuperTrend which flips indiscriminately on volatility breaks, EWPS calculates a real-time probability that the current market structure aligns with a valid 5-wave impulse sequence. It then uses this probability to filter, tint, and validate SuperTrend signals.
The result is a directional trend-follower that knows the difference between a healthy W3 extension (high probability long) and a noisy W4 chop (low probability, dimmed trail).

￼
[b]2. Core Architecture[/b]
[i]Base Layer: SuperTrend[/i]
 • Classic ATR-based trailing stop using hl2/close/ohlc4 source.
 • Maintains upper and lower bands; flips when price closes through the opposing band.
Pattern Layer: Elliott Wave Engine
 • Maintains a rolling buffer of the last 12 swing pivots (highs/lows).
 • Attempts to fit a 5-wave impulse (6 pivots: 0-1-2-3-4-5) to recent price action.
 • Validates waves using 4 hard rules (binary pass/fail) and 7 weighted guidelines (quality score 0.0–1.0).
Probability Layer: Live Wave Context
 • Determines which wave is currently developing (e.g., "developing W3").
 • Calculates base position scores (W3 and W5 development favored; W2/W4 corrections cautionary).
 • Measures Fibonacci fit of the developing leg against ideal extensions/retracements.
 • Quantifies invalidation risk (proximity to W0 or W1 overlap that would break the count).
 • Synthesizes into a 0.0–1.0 probability via logistic (sigmoid) regression with configurable weights.
Emission Layer: Filtered Signals
 • Raw SuperTrend flips are gated by probability thresholds.
 • Bullish flips require bullProb ≥ gate AND bearProb ≤ fade gate.
 • Trail color shifts from dim grey (low confidence) to bright green/red (high confidence) based on current probability.

￼
[b]3. Input Parameters[/b]
[i]SuperTrend Settings[/i]
 • ATR Length: Lookback for ATR calculation (default 10). Higher = slower trail, fewer whipsaws.
 • ATR Multiplier: Distance factor for bands (default 3.0). Higher = wider stops, fewer flips.
 • Source: Price input—hl2 (midpoint, default), close, ohlc4, or hlc3.
[i]Swing Detection[/i]
 • [b]Pivot Left/Right Bars[/b]: Defines swing sensitivity. Left=4, Right=1 means a high/low must be the highest/lowest of 4 bars left and 1 bar right to qualify. Right=0 is faster but repainting; Right=1 is standard confirmation.
 • Minimum Swing %: Filters noise by requiring pivots to be separated by at least 0.20% price movement.
[i]EW Engine[/i]
[b] • Fib Proximity Tolerance[/b]: Gaussian width for Fibonacci matching (default 0.08). Lower = stricter adherence to ideal ratios.
[b] • Min Impulse Quality:[/b] Minimum quality score (0.0–1.0) to trust a wave count (default 0.40). Below this, the engine treats the structure as "unknown."
[b] • Allow W4→W1 Overlap:[/b] Toggle for diagonal/triangle patterns where W4 may enter W1 territory (default false).
[b] • Allow Truncated W5:[/b] Whether to accept W5s that fail to exceed W3 (default true), applying only a quality penalty rather than invalidation.
Probability Weights
These feed the logistic regression that produces bullProb/bearProb. Adjust to emphasize what matters for your market:
[b] • Impulse Quality (default 2.0):[/b] Weight of the base pattern score (0–1 from guideline scoring).
[b] • Wave Position (default 2.5):[/b] Weight of "where are we in the sequence" (W3 development strongly bullish).
 • Current-Leg Fib Fit (default 1.2): Weight of how well the developing leg matches ideal Fibonacci extensions/retracements.
[b] • Invalidation Risk (default 1.5)[/b]: Penalty weight for proximity to structural breaks (W2 > 100% retrace, W4 into W1).
[b] • Directional Bias (default 0.0): [/b]Constant shift (+ bullish, − bearish) to skew probabilities without changing pattern logic. Use if backtests show consistent directional skew.
Emission & Gates
[b] • Min Bull/Bear Prob for Flip:[/b] Threshold to permit a SuperTrend flip in that direction (default 0.60). Flips only occur if probability supports the new direction.
[b] • Max Opposite Prob (Fade Gate): [/b]Safety check (default 0.35). Prevents flipping long if bearProb is still dangerously high, even if bullProb is decent.
[b] • Invert Long/Short Emission: [/b]Boolean toggle. If enabled, swaps bullProb/bearProb in the gating logic (useful if you discover via backtest that signals are more accurate when reversed—a known phenomenon in some Bayesian pattern engines).
Visuals
[b] • Dim Trail When Prob Low:[/b] Greys out the SuperTrend line when current probability is below tier thresholds.
[b] • Background Probability Tint: [/b]Fills background with low-opacity bull/bear color intensity scaling with probability strength.
[b] • Show State Table: [/b]Displays the debug/info panel (top-right) showing wave position, impulse quality, Fib fit, invalidation risk, and current probabilities.

￼
[b]4. Interpreting the Indicator[/b]
[i]The Trail Line[/i]
[b] • Bright Green/Red: [/b]High confidence (≥60%) alignment with impulse direction. Safe trend-following territory.
[b] • Muted Green/Red[/b]: Medium confidence (40–60%). Trend exists but structure is questionable or early.
[b] • Dim Grey:[/b] Low confidence (<40%) or "gated" state. The SuperTrend is technically long/short but the EW engine sees no valid pattern supporting it. Often coincides with W2/W4 corrections or unknown wave counts.

[i][b]Wave Position Readings (State Table)[/b][/i]
The indicator displays which wave is currently developing:
[b] • dev W2[/b]: Developing second wave (correction). Low base score; expect chop. Good for patience/waiting for W3 entry.
[b] • dev W3 ★[/b]: Developing third wave (strongest impulse). Highest base score; ideal for momentum entries.
[b] • dev W4[/b]: Developing fourth wave (correction). Moderate caution; prepare for W5 or failed W5 truncation.
[b] • dev W5 ★[/b]: Developing fifth wave. Good continuation score but watch for truncation and reversal into "A" wave.
[b] • post-W5:[/b] Structure complete; expecting ABC correction or new impulse. Lowest scores; trend exhaustion likely.
Signal Shapes
[b] • ▲ L (Large Green Triangle):[/b] Filtered Long—SuperTrend flipped up AND probability gates passed (bullProb ≥ 0.60, bearProb ≤ 0.35).
[b] • ▼ S (Large Red Triangle)[/b]: Filtered Short—SuperTrend flipped down AND probability gates passed.
[b] • Small X Cross:[/b] Raw flip that was gated (probability too low). Shows where SuperTrend wanted to flip but EWPS blocked it due to poor structural fit. Useful for seeing "avoided whipsaws."

[i]Background Tint[/i]
 • Intensity scales with current probability (currentQ).
 • Bright = strong structural alignment.
 • Absent or faint = weak alignment (even if SuperTrend direction persists).

[i]Key Metrics in State Table[/i]
 • Impulse Q: The 0.0–1.0 quality score from guideline validation. Green if ≥ minQ, orange if below.
 • Fib Fit: 0.0–1.0 score of current leg vs ideal Fibonacci zones. Higher = price is at "perfect" W3 extension or W2 retracement.
 • Inval Risk: 0.0–1.0 proximity to pattern invalidation. Red warning if >0.60 (price approaching W0 or overlapping W1).
 • Bull P / Bear P: Final probabilities after sigmoid transformation. Colored when above respective gates.

￼
[b]5. Practical Usage Guidelines[/b]
[i]Trend Entry Strategy[/i]
1. Wait for a Filtered Long (▲ L) or Filtered Short (▼ S) signal.
2. Confirm the State Table shows dev W3 or dev W5 (starred positions) for strongest momentum.
3. Check that Inval Risk is low (<0.30) and Fib Fit is high (>0.60).
4. Enter on close of signal bar; trail the SuperTrend line as stop-loss.
Avoiding False Breakouts
 • If SuperTrend flips but you see a small X (gated) instead of a triangle, do not enter. The EW engine has rejected the flip due to:
 ◦ Low impulse quality (choppy/ranging structure).
 ◦ High invalidation risk (price near critical support/resistance that would break the wave count).
 ◦ Wave position in correction (dev W2 or dev W4) suggesting the "trend" is actually a counter-trend chop.

[b]Wave Position Trading[/b]
 • W3 Entries: When state shows "dev W3" with rising Fib Fit, add to positions or pyramid. This is the "meat of the move."
 • W5 Cautions: When state shows "dev W5," tighten stops. Use the truncation allowance setting carefully—if disabled, W5 failures invalidate quickly; if enabled, you ride deeper but risk reversal.
 • W2 Accumulation: When state shows "dev W2" and Inval Risk is low (not near W0), prepare limit orders for the W3 breakout rather than chasing.
Probability Divergence
 • If price makes new highs but Bull P is declining while Bear P rises, the structure is weakening (W5 truncation or diagonal forming). Consider taking profits even if SuperTrend remains long.
Timeframe Adaptation
 • Lower Timeframes (M1-M15): Reduce Pivot Left Bars to 2-3 for faster swing detection; increase ATR Multiplier to 4.0+ to avoid noise; tighten Fib Tolerance to 0.05 for stricter pattern quality.
 • Higher Timeframes (H4-Daily): Increase Pivot Left Bars to 5-8 for significant swings; decrease ATR Multiplier to 2.0-2.5 for responsiveness; use longer SuperTrend ATR lengths (14-21).
Invert Toggle Usage
 • If after 50+ trades you notice the gated (X) signals were actually better entries than the filtered triangles, enable Invert Long/Short Emission. This indicates the market is exhibiting "Bayesian mismatch" where the pattern probabilities are inverted—common in mean-reversion heavy assets.

￼
[b]6. Alert Conditions[/b]
The script provides four alert types:
Filtered Long
 • Fires when a high-probability bullish SuperTrend flip occurs.
 • Use for: Live entry notifications on W3/W5 breakouts.
Filtered Short
 • Fires when a high-probability bearish SuperTrend flip occurs.
 • Use for: Short entry notifications on W3/W5 down-impulse breakouts.
Raw Flip Up / Raw Flip Down
 • Fires on all SuperTrend direction changes regardless of probability gating.
 • Use for: Monitoring all potential trend changes (including those the EW engine rejected) for manual discretion or alternate strategies.

## Source Code

````pine
// © Cmo22 — Elliott Wave Probability × SuperTrend v3.1
//@version=6
indicator("EW Probability × SuperTrend v3", "EWP·ST v3", overlay=true,
     max_lines_count=500, max_labels_count=500, max_bars_back=500)

// ══════════════════════════════════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════════════════════════════════

gST = "SuperTrend"
atrLen   = input.int(100,   "ATR length",     minval=1, group=gST)
atrMult  = input.float(3.618,"ATR multiplier", minval=0.1, step=0.1, group=gST)
srcMode  = input.string("ohlc4","Source", options=["hl2","close","ohlc4","hlc3"], group=gST)

gSW = "Dynamic Swing Engine"
basePivL = input.int(4,    "Base pivot left bars",  minval=1, maxval=20, group=gSW)
basePivR = input.int(2,    "Base pivot right bars", minval=0, maxval=10, group=gSW,
     tooltip="0=earliest (repainting), 2=standard, 4=conservative")
volAdjust= input.bool(true,"Volatility-adjusted swing threshold", group=gSW)
minSwingATR= input.float(1.6,"Min swing × ATR", minval=0.1, step=0.1, group=gSW)
maxSwingAge= input.int(300,"Max pivot age (bars)", minval=50, maxval=1000, group=gSW)

gEW = "EW Engine"
fibTol      = input.float(0.025,"Fib proximity tolerance", minval=0.005, step=0.005, group=gEW)
minQ        = input.float(0.92,"Min impulse quality to trust", minval=0.0, maxval=1.0, step=0.01, group=gEW)
allowDiag   = input.bool(false,"Allow W4→W1 overlap (diagonal)", group=gEW)
allowTrunc  = input.bool(false, "Allow truncated W5", group=gEW)
allowRun    = input.bool(false, "Allow running corrections (shallow W2)", group=gEW)

gP = "Probability"
probLongGate  = input.float(0.92,"Min bullProb for long flip", minval=0.0, maxval=1.0, step=0.01, group=gP)
probShortGate = input.float(0.92,"Min bearProb for short flip", minval=0.0, maxval=1.0, step=0.01, group=gP)
probFadeGate  = input.float(0.12,"Max opposite prob allowed", minval=0.0, maxval=1.0, step=0.01, group=gP)
wQual   = input.float(2.2, "Weight: impulse quality", minval=0.0, step=0.1, group=gP)
wContext= input.float(2.8, "Weight: wave position", minval=0.0, step=0.1, group=gP)
wFibFit = input.float(1.5, "Weight: current-leg Fib fit", minval=0.0, step=0.1, group=gP)
wInval  = input.float(1.8, "Weight: invalidation risk", minval=0.0, step=0.1, group=gP)
wTime   = input.float(1.3, "Weight: time alternation", minval=0.0, step=0.1, group=gP)
wMom    = input.float(1.0, "Weight: momentum profile", minval=0.0, step=0.1, group=gP)
wVol    = input.float(0.8, "Weight: volume confirmation", minval=0.0, step=0.1, group=gP)
probBias= input.float(0.0, "Logit bias", minval=-2.0, maxval=2.0, step=0.1, group=gP)

gE = "Emission"
invertEmit = input.bool(true,"Invert long/short emission", group=gE)
dimLowProb = input.bool(true, "Dim trail when prob is low", group=gE)
showBg     = input.bool(true, "Background probability tint", group=gE)

gV = "Visuals"
colBull = input.color(color.new(#00C853, 0), "Bull color", group=gV)
colBear = input.color(color.new(#D50000, 0), "Bear color", group=gV)
colDim  = input.color(color.new(#9E9E9E, 20),"Low-prob color", group=gV)
colW3   = input.color(color.new(#FF9800, 0), "W3 label", group=gV)

// ══════════════════════════════════════════════════════════════════════════
//  UTILITIES
// ══════════════════════════════════════════════════════════════════════════

f_sig(x)           => 1.0 / (1.0 + math.exp(-math.max(-10.0, math.min(10.0, x))))
f_clamp(x, lo, hi) => math.min(hi, math.max(lo, x))
f_safeDiv(a, b)    => b == 0 ? 0.0 : a / b
f_sq(x)            => x * x

f_fibNear(actual, target, tol, degree) =>
    adjTol = tol / math.max(1.0, math.sqrt(degree))
    diff = actual - target
    adjTol <= 0 ? 0.0 : math.exp(-f_sq(diff) / (2.0 * f_sq(adjTol)))

f_fibConfluence(ratio, tol, targets, degree) =>
    if na(ratio)
        0.0
    else
        maxScore = 0.0
        tSize = array.size(targets)
        if tSize > 0
            for i = 0 to tSize - 1
                sc = f_fibNear(ratio, array.get(targets, i), tol, degree)
                maxScore := math.max(maxScore, sc)
        maxScore

f_perpDist(px, py, x1, y1, x2, y2) =>
    dx = x2 - x1
    dy = y2 - y1
    lenSq = dx*dx + dy*dy
    if lenSq == 0
        math.sqrt(f_sq(px-x1) + f_sq(py-y1))
    else
        t = f_clamp(((px-x1)*dx + (py-y1)*dy) / lenSq, 0.0, 1.0)
        projX = x1 + t * dx
        projY = y1 + t * dy
        math.sqrt(f_sq(px-projX) + f_sq(py-projY))

src = srcMode == "close" ? close : srcMode == "ohlc4" ? ohlc4 : srcMode == "hlc3" ? hlc3 : hl2
atrNow = ta.atr(atrLen)

// ══════════════════════════════════════════════════════════════════════════
//  FIBONACCI LIBRARY
// ══════════════════════════════════════════════════════════════════════════

var float[] FIB_W2 = array.from(0.382, 0.500, 0.618, 0.786, 0.854)
var float[] FIB_W4 = array.from(0.236, 0.333, 0.382, 0.500, 0.618)
var float[] FIB_W3 = array.from(1.000, 1.272, 1.618, 2.000, 2.618, 4.236)
var float[] FIB_W5 = array.from(0.500, 0.618, 1.000, 1.272, 1.618, 2.000)
var float[] FIB_EXT= array.from(1.618, 2.618, 4.236)

// ══════════════════════════════════════════════════════════════════════════
//  DYNAMIC ZIGZAG
// ══════════════════════════════════════════════════════════════════════════

var float[] pvP = array.new_float()
var int[]   pvB = array.new_int()
var int[]   pvT = array.new_int()
int MAX_PV = 30

var float[] atrHist = array.new_float(100, 0.0)
array.push(atrHist, atrNow)
array.shift(atrHist)

atrP80 = array.size(atrHist) > 0 ? array.percentrank(atrHist, 80) : atrNow
dynMinSwing = volAdjust ? atrP80 * minSwingATR : atrNow * minSwingATR * 0.5

f_pushPivot(_price, _bar, _typ) =>
    sz = array.size(pvP)
    ok = true
    if sz > 0
        prev = array.get(pvP, sz - 1)
        swingSize = math.abs(_price - prev)
        ok := swingSize >= dynMinSwing
        if ok and sz >= 2
            timeGap = _bar - array.get(pvB, sz - 1)
            ok := timeGap >= basePivR + 1
    if ok
        if sz > 0 and array.get(pvT, sz - 1) == _typ
            prev = array.get(pvP, sz - 1)
            take = _typ > 0 ? _price > prev : _price < prev
            if take
                array.set(pvP, sz - 1, _price)
                array.set(pvB, sz - 1, _bar)
        else
            array.push(pvP, _price)
            array.push(pvB, _bar)
            array.push(pvT, _typ)
            while array.size(pvP) > 0 and array.size(pvB) > 0 and (bar_index - array.get(pvB, 0)) > maxSwingAge
                array.shift(pvP)
                array.shift(pvB)
                array.shift(pvT)
            while array.size(pvP) > MAX_PV
                array.shift(pvP)
                array.shift(pvB)
                array.shift(pvT)
    ok

ph = ta.pivothigh(high, basePivL, basePivR)
pl = ta.pivotlow (low,  basePivL, basePivR)
newPivot = false
if not na(ph)
    f_pushPivot(ph, bar_index[basePivR],  1)
    newPivot := true
if not na(pl)
    f_pushPivot(pl, bar_index[basePivR], -1)
    newPivot := true

f_getAmp(idx) =>
    pvSize = array.size(pvP)
    idx <= 0 or pvSize < 2 or idx >= pvSize ? 0.0 : math.abs(array.get(pvP, idx) - array.get(pvP, idx-1))

f_getVel(idx) =>
    pvSize = array.size(pvP)
    if idx <= 0 or pvSize < 2 or idx >= pvSize
        0.0
    else
        dt = math.max(array.get(pvB, idx) - array.get(pvB, idx-1), 1)
        math.abs(array.get(pvP, idx) - array.get(pvP, idx-1)) / dt

// ══════════════════════════════════════════════════════════════════════════
//  WAVE DEGREE CLASSIFICATION
// ══════════════════════════════════════════════════════════════════════════

f_waveDegree(idx) =>
    sz = array.size(pvP)
    if idx < 1 or idx >= sz
        1
    else
        amp = f_getAmp(idx)
        recent = array.new_float()
        start = math.max(1, sz - 8)
        for i = start to sz - 1
            a = f_getAmp(i)
            if a > 0
                array.push(recent, a)
        med = array.size(recent) > 0 ? array.median(recent) : amp
        med <= 0 ? 1 : (amp / med > 2.5 ? 3 : amp / med > 1.5 ? 2 : 1)

// ══════════════════════════════════════════════════════════════════════════
//  ADVANCED IMPULSE SCORER v3.1
// ══════════════════════════════════════════════════════════════════════════

f_scoreImpulse(i0, i1, i2, i3, i4, i5, isBull) =>
    pvSize = array.size(pvP)
    pbSize = array.size(pvB)
    if pvSize < 6 or pbSize < 6 or i0 < 0 or i5 >= pvSize
        [false, 0.0]
    else
        p0 = array.get(pvP, i0)
        p1 = array.get(pvP, i1)
        p2 = array.get(pvP, i2)
        p3 = array.get(pvP, i3)
        p4 = array.get(pvP, i4)
        p5 = array.get(pvP, i5)
        b0 = array.get(pvB, i0)
        b1 = array.get(pvB, i1)
        b2 = array.get(pvB, i2)
        b3 = array.get(pvB, i3)
        b4 = array.get(pvB, i4)
        b5 = array.get(pvB, i5)
        
        a1 = math.abs(p1-p0)
        a2 = math.abs(p2-p1)
        a3 = math.abs(p3-p2)
        a4 = math.abs(p4-p3)
        a5 = math.abs(p5-p4)
        t1 = math.max(b1-b0,1)
        t2 = math.max(b2-b1,1)
        t3 = math.max(b3-b2,1)
        t4 = math.max(b4-b3,1)
        t5 = math.max(b5-b4,1)
        v1 = a1/t1
        v2 = a2/t2
        v3 = a3/t3
        v4 = a4/t4
        v5 = a5/t5
        
        degree = f_waveDegree(i1)
        adjTol = fibTol * math.max(0.5, 1.0 / math.sqrt(degree))
        
        hr1 = isBull ? (p2 > p0) : (p2 < p0)
        hr2 = not (a3 < a1 and a3 < a5)
        hr3 = allowDiag ? true : (isBull ? p4 > p1 : p4 < p1)
        hr4 = isBull ? (p3 > p1) : (p3 < p1)
        hr5 = a1 > 0 and a2 > 0 and a3 > 0 and a4 > 0 and a5 > 0
        
        valid = hr1 and hr2 and hr3 and hr4 and hr5
        q = 0.0
        
        if valid
            v3Ratio = f_safeDiv(v3, math.max(v1, v5))
            g1 = f_clamp(v3Ratio, 0.0, 1.0)
            if v3 < v1 and v3 < v5
                g1 := 0.0
            
            ext3 = f_safeDiv(a3, a1)
            g2 = f_fibConfluence(ext3, adjTol * 2.0, FIB_W3, degree)
            if ext3 >= 1.5 and ext3 <= 1.8
                g2 := math.min(1.0, g2 + 0.15)
            
            r2 = f_safeDiv(a2, a1)
            g3 = f_fibConfluence(r2, adjTol, FIB_W2, degree)
            if allowRun and r2 < 0.382 and r2 > 0.15
                g3 := math.max(g3, 0.6)
            if r2 > 0.95
                g3 := g3 * 0.3
            
            r4 = f_safeDiv(a4, a3)
            g4 = f_fibConfluence(r4, adjTol, FIB_W4, degree)
            if not na(r2) and r4 > 0
                if math.abs(r4 - 0.382) < math.abs(r2 - 0.382)
                    g4 := math.min(1.0, g4 + 0.1)
                if math.abs(r4 - r2) < 0.1
                    g4 := g4 * 0.7
            
            tRatio = f_safeDiv(t4, t2)
            sharp2 = t2 < t4 and v2 > v4 * 1.5
            sharp4 = t4 < t2 and v4 > v2 * 1.5
            g5 = (sharp2 or sharp4) ? 1.0 : (math.abs(tRatio - 1.0) > 0.3 ? 0.6 : 0.3)
            
            dist4 = f_perpDist(b4, p4, b0, p0, b2, p2)
            dist5 = f_perpDist(b5, p5, b1, p1, b3, p3)
            normDist4 = f_safeDiv(dist4, a3)
            normDist5 = f_safeDiv(dist5, a1)
            g6 = f_clamp(1.0 - (normDist4 + normDist5) * 2.0, 0.0, 1.0)
            
            g7 = 0.0
            progressed5 = isBull ? p5 > p3 : p5 < p3
            if progressed5
                ext5 = f_safeDiv(a5, a1)
                g7 := f_fibConfluence(ext5, adjTol * 1.5, FIB_W5, degree)
                a5v3 = f_safeDiv(a5, a3)
                if a5v3 > 1.0
                    extBonus = f_fibConfluence(ext5, adjTol * 2.5, FIB_EXT, degree)
                    g7 := math.min(1.0, g7 * 0.5 + extBonus * 0.5)
            else
                g7 := allowTrunc ? 0.35 : 0.0
            
            ampEq = 1.0 - math.abs(a5 - a1) / math.max(a1 + a5, 1e-9) * 2.0
            timeEq = 1.0 - math.abs(t5 - t1) / math.max(t1 + t5, 1e-9) * 2.0
            g8 = f_clamp(ampEq * 0.6 + timeEq * 0.4, 0.0, 1.0)
            
            momDiv = v3 > v5 ? 1.0 : f_clamp(1.0 - (v5 - v3) / math.max(v3, 1e-9), 0.0, 1.0)
            a5v3_ = f_safeDiv(a5, a3)
            g9 = a5v3_ > 1.2 ? f_clamp(momDiv * 0.4 + 0.6, 0.0, 1.0) : momDiv
            
            total03 = math.abs(p3 - p0)
            r4tot = f_safeDiv(a4, total03)
            g10 = f_fibNear(r4tot, 0.382, adjTol * 2.0, degree)
            
            g11 = v1 < v3 ? 1.0 : f_clamp(1.0 - (v1 - v3) / v3, 0.0, 1.0)
            
            g12 = (v2 > v1 * 0.7 or r2 > 0.5) ? 1.0 : 0.4
            
            g13 = (v4 < v2 * 0.8 and r4 < r2) ? 1.0 : (v4 < v2 ? 0.6 : 0.3)
            
            q := 0.14*g1 + 0.13*g2 + 0.11*g3 + 0.11*g4 + 0.10*g5 + 0.09*g6 + 
                 0.09*g7 + 0.07*g8 + 0.07*g9 + 0.06*g10 + 0.05*g11 + 0.04*g12 + 0.04*g13
        
        [valid, f_clamp(q, 0.0, 1.0)]

f_partialW1(p0, p1, isBull) => isBull ? p1 > p0 : p1 < p0

f_partialW2(p0, p1, p2, isBull) => f_partialW1(p0,p1,isBull) and (isBull ? p2 > p0 : p2 < p0)

f_partialW3(p0, p1, p2, p3, isBull) => f_partialW2(p0,p1,p2,isBull) and (isBull ? p3 > p1 : p3 < p1)

f_partialW4(p0, p1, p2, p3, p4, isBull) =>
    f_partialW3(p0,p1,p2,p3,isBull) and (allowDiag ? true : (isBull ? p4 > p1 : p4 < p1))

f_partialQ_W2(p0, p1, p2, b0, b1, b2) =>
    a1 = math.abs(p1-p0)
    a2 = math.abs(p2-p1)
    r2 = f_safeDiv(a2, a1)
    deg = 1
    adjTol = fibTol * math.max(0.5, 1.0 / math.sqrt(deg))
    fibSc = f_fibConfluence(r2, adjTol, FIB_W2, deg)
    if allowRun and r2 < 0.382 and r2 > 0.15
        fibSc := math.max(fibSc, 0.6)
    timeR = f_safeDiv(math.max(b2-b1,1), math.max(b1-b0,1))
    timeTargets = array.from(0.618, 1.0, 1.618)
    timeSc = f_fibConfluence(timeR, 0.2, timeTargets, deg)
    f_clamp(fibSc * 0.6 + timeSc * 0.4, 0.0, 1.0) * 0.45

f_partialQ_W3(p0, p1, p2, p3, b0, b1, b2, b3) =>
    a1 = math.abs(p1-p0)
    a3 = math.abs(p3-p2)
    ext3 = f_safeDiv(a3, a1)
    deg = 1
    adjTol = fibTol * math.max(0.5, 1.0 / math.sqrt(deg))
    fibSc = f_fibConfluence(ext3, adjTol * 2.0, FIB_W3, deg)
    v3 = a3 / math.max(b3-b2,1)
    v1 = a1 / math.max(b1-b0,1)
    momSc = v3 > v1 ? 1.0 : f_clamp(v3/v1, 0.0, 1.0)
    f_clamp(fibSc * 0.6 + momSc * 0.4, 0.0, 1.0) * 0.55

f_partialQ_W4(p0, p1, p2, p3, p4, b0, b1, b2, b3, b4) =>
    a3 = math.abs(p3-p2)
    a4 = math.abs(p4-p3)
    r4 = f_safeDiv(a4, a3)
    deg = 1
    adjTol = fibTol * math.max(0.5, 1.0 / math.sqrt(deg))
    fibSc = f_fibConfluence(r4, adjTol, FIB_W4, deg)
    a2 = math.abs(p2-p1)
    a1 = math.abs(p1-p0)
    r2 = f_safeDiv(a2, a1)
    altSc = (not na(r2) and r4 < r2) ? 1.0 : 0.5
    dist4 = f_perpDist(b4, p4, b0, p0, b2, p2)
    norm4 = f_safeDiv(dist4, a3)
    chanSc = f_clamp(1.0 - norm4 * 3.0, 0.0, 1.0)
    f_clamp(fibSc * 0.5 + altSc * 0.25 + chanSc * 0.25, 0.0, 1.0) * 0.60

f_partialQ_W5(p0, p1, p2, p3, p4, p5, b0, b1, b2, b3, b4, b5, isBull) =>
    a1 = math.abs(p1-p0)
    a5 = math.abs(p5-p4)
    a3 = math.abs(p3-p2)
    ext5 = f_safeDiv(a5, a1)
    deg = 1
    adjTol = fibTol * math.max(0.5, 1.0 / math.sqrt(deg))
    fibSc = f_fibConfluence(ext5, adjTol * 1.5, FIB_W5, deg)
    progressed = isBull ? p5 > p3 : p5 < p3
    progSc = progressed ? 1.0 : (allowTrunc ? 0.4 : 0.0)
    v3 = a3 / math.max(b3-b2,1)
    v5 = a5 / math.max(b5-b4,1)
    divSc = v3 > v5 ? 1.0 : f_clamp(1.0 - (v5-v3)/math.max(v3,1e-9), 0.0, 1.0)
    dist5 = f_perpDist(b5, p5, b1, p1, b3, p3)
    norm5 = f_safeDiv(dist5, a1)
    chanSc = f_clamp(1.0 - norm5 * 3.0, 0.0, 1.0)
    f_clamp(fibSc * 0.35 + progSc * 0.25 + divSc * 0.2 + chanSc * 0.2, 0.0, 1.0) * 0.65

// ══════════════════════════════════════════════════════════════════════════
//  LIVE WAVE DETECTION v3.1
// ══════════════════════════════════════════════════════════════════════════

var int   curWavePos     = 0
var int   curDir         = 0
var float curQ           = 0.0
var float rW0            = na
var float rW1            = na
var float rW1Amp         = na
var float rW3Amp         = na
var float rW5Amp         = na
var float rLastPvPrice   = na
var int   rLastPvBar     = 0
var int   rWaveDegree    = 1

f_directionFromFirst(typA, typB) =>
    typA < 0 and typB > 0

if newPivot
    sz = array.size(pvP)
    bestQ = 0.0
    bestPos = 0
    bestDir = 0
    bestDeg = 1
    
    if sz >= 6
        maxOff = math.min(2, sz - 6)
        for offset = 0 to maxOff
            i0 = sz-6-offset
            i1 = sz-5-offset
            i2 = sz-4-offset
            i3 = sz-3-offset
            i4 = sz-2-offset
            i5 = sz-1-offset
            if array.size(pvT) > i5 and array.get(pvT, i0) != array.get(pvT, i1)
                isBull = f_directionFromFirst(array.get(pvT, i0), array.get(pvT, i1))
                [v, q] = f_scoreImpulse(i0, i1, i2, i3, i4, i5, isBull)
                if v and q > bestQ
                    bestQ := q
                    bestPos := 5
                    bestDir := isBull ? 1 : -1
                    bestDeg := f_waveDegree(i1)
                    curWavePos := 5
                    curDir := bestDir
                    curQ := q
                    rW0 := array.get(pvP, i0)
                    rW1 := array.get(pvP, i1)
                    rW1Amp := math.abs(array.get(pvP,i1) - array.get(pvP,i0))
                    rW3Amp := math.abs(array.get(pvP,i3) - array.get(pvP,i2))
                    rW5Amp := math.abs(array.get(pvP,i5) - array.get(pvP,i4))
                    rWaveDegree := bestDeg
                    rLastPvPrice := array.get(pvP, i5)
                    rLastPvBar := array.get(pvB, i5)
    
    if bestPos == 0 and sz >= 5
        i0 = sz-5
        i1 = sz-4
        i2 = sz-3
        i3 = sz-2
        i4 = sz-1
        if array.size(pvT) > i4 and array.get(pvT, i0) != array.get(pvT, i1)
            isBull = f_directionFromFirst(array.get(pvT, i0), array.get(pvT, i1))
            if f_partialW4(array.get(pvP,i0), array.get(pvP,i1), array.get(pvP,i2),
                          array.get(pvP,i3), array.get(pvP,i4), isBull)
                pq = f_partialQ_W5(array.get(pvP,i0), array.get(pvP,i1), array.get(pvP,i2),
                                  array.get(pvP,i3), array.get(pvP,i4), src,
                                  array.get(pvB,i0), array.get(pvB,i1), array.get(pvB,i2),
                                  array.get(pvB,i3), array.get(pvB,i4), bar_index, isBull)
                if pq > bestQ
                    bestQ := pq
                    bestPos := 4
                    bestDir := isBull ? 1 : -1
                    curWavePos := 4
                    curDir := bestDir
                    curQ := pq
                    rW0 := array.get(pvP,i0)
                    rW1 := array.get(pvP,i1)
                    rW1Amp := math.abs(array.get(pvP,i1)-array.get(pvP,i0))
                    rW3Amp := math.abs(array.get(pvP,i3)-array.get(pvP,i2))
                    rLastPvPrice := array.get(pvP,i4)
                    rLastPvBar := array.get(pvB,i4)
    
    if bestPos == 0 and sz >= 4
        i0 = sz-4
        i1 = sz-3
        i2 = sz-2
        i3 = sz-1
        if array.size(pvT) > i3 and array.get(pvT, i0) != array.get(pvT, i1)
            isBull = f_directionFromFirst(array.get(pvT, i0), array.get(pvT, i1))
            if f_partialW3(array.get(pvP,i0), array.get(pvP,i1), array.get(pvP,i2), array.get(pvP,i3), isBull)
                pq = f_partialQ_W4(array.get(pvP,i0), array.get(pvP,i1), array.get(pvP,i2), array.get(pvP,i3), src,
                                  array.get(pvB,i0), array.get(pvB,i1), array.get(pvB,i2), array.get(pvB,i3), bar_index)
                if pq > bestQ
                    bestQ := pq
                    bestPos := 3
                    bestDir := isBull ? 1 : -1
                    curWavePos := 3
                    curDir := bestDir
                    curQ := pq
                    rW0 := array.get(pvP,i0)
                    rW1 := array.get(pvP,i1)
                    rW1Amp := math.abs(array.get(pvP,i1)-array.get(pvP,i0))
                    rW3Amp := math.abs(array.get(pvP,i3)-array.get(pvP,i2))
                    rLastPvPrice := array.get(pvP,i3)
                    rLastPvBar := array.get(pvB,i3)
    
    if bestPos == 0 and sz >= 3
        i0 = sz-3
        i1 = sz-2
        i2 = sz-1
        if array.size(pvT) > i2 and array.get(pvT, i0) != array.get(pvT, i1)
            isBull = f_directionFromFirst(array.get(pvT, i0), array.get(pvT, i1))
            if f_partialW2(array.get(pvP,i0), array.get(pvP,i1), array.get(pvP,i2), isBull)
                pq = f_partialQ_W3(array.get(pvP,i0), array.get(pvP,i1), array.get(pvP,i2), src,
                                  array.get(pvB,i0), array.get(pvB,i1), array.get(pvB,i2), bar_index)
                if pq > bestQ
                    bestQ := pq
                    bestPos := 2
                    bestDir := isBull ? 1 : -1
                    curWavePos := 2
                    curDir := bestDir
                    curQ := pq
                    rW0 := array.get(pvP,i0)
                    rW1 := array.get(pvP,i1)
                    rW1Amp := math.abs(array.get(pvP,i1)-array.get(pvP,i0))
                    rLastPvPrice := array.get(pvP,i2)
                    rLastPvBar := array.get(pvB,i2)
    
    if bestPos == 0 and sz >= 2
        i0 = sz-2
        i1 = sz-1
        if array.size(pvT) > i1 and array.get(pvT, i0) != array.get(pvT, i1)
            isBull = f_directionFromFirst(array.get(pvT, i0), array.get(pvT, i1))
            if f_partialW1(array.get(pvP,i0), array.get(pvP,i1), isBull)
                pq = f_partialQ_W2(array.get(pvP,i0), array.get(pvP,i1), src,
                                  array.get(pvB,i0), array.get(pvB,i1), bar_index)
                if pq > bestQ
                    bestQ := pq
                    bestPos := 1
                    bestDir := isBull ? 1 : -1
                    curWavePos := 1
                    curDir := bestDir
                    curQ := pq
                    rW0 := array.get(pvP,i0)
                    rW1 := array.get(pvP,i1)
                    rW1Amp := math.abs(array.get(pvP,i1)-array.get(pvP,i0))
                    rLastPvPrice := array.get(pvP,i1)
                    rLastPvBar := array.get(pvB,i1)
    
    if array.size(pvP) > 0 and array.size(pvB) > 0
        rLastPvPrice := array.get(pvP, sz-1)
        rLastPvBar := array.get(pvB, sz-1)

// ══════════════════════════════════════════════════════════════════════════
//  VOLUME CONFIRMATION
// ══════════════════════════════════════════════════════════════════════════

f_volumeProfile(pos, isBull) =>
    if pos < 2 or na(volume)
        0.5
    else
        volMed = ta.sma(volume, 20)
        if pos == 2
            volume > volMed * 1.2 ? 1.0 : f_clamp(volume / volMed, 0.0, 1.0)
        else if pos == 4
            volume < volMed * 0.8 ? 1.0 : f_clamp(volMed * 0.8 / volume, 0.0, 1.0)
        else
            0.5

volScore = f_volumeProfile(curWavePos, curDir == 1)

// ══════════════════════════════════════════════════════════════════════════
//  LIVE PROBABILITY v3.1
// ══════════════════════════════════════════════════════════════════════════

f_baseWavePosScore(pos) =>
    pos == 1 ? 0.25 : pos == 2 ? 0.90 : pos == 3 ? 0.35 : pos == 4 ? 0.80 : pos == 5 ? 0.15 : 0.50

f_currentLegFibFit(pos, isBull, lastPv, w1Amp, w3Amp, w5Amp, degree) =>
    if na(lastPv) or na(w1Amp) or w1Amp <= 0
        0.5
    else
        adjTol = fibTol * math.max(0.5, 1.0 / math.sqrt(degree))
        dist = isBull ? close - lastPv : lastPv - close
        if pos == 1
            depth = math.abs(dist) / w1Amp
            sc = f_fibConfluence(depth, adjTol, FIB_W2, degree)
            if allowRun and depth < 0.382 and depth > 0.15
                sc := math.max(sc, 0.6)
            sc
        else if pos == 2
            prog = dist / w1Amp
            if prog < 0
                f_clamp(0.3 + prog * 0.5, 0.0, 0.5)
            else
                f_clamp(f_fibConfluence(prog, adjTol * 2.0, FIB_W3, degree) + (prog > 0.618 ? 0.1 : 0.0), 0.0, 1.0)
        else if pos == 3 and not na(w3Amp) and w3Amp > 0
            depth = math.abs(dist) / w3Amp
            f_fibConfluence(depth, adjTol, FIB_W4, degree)
        else if pos == 4
            prog = dist / w1Amp
            sc = f_fibConfluence(prog, adjTol * 1.5, FIB_W5, degree)
            if not na(w3Amp) and math.abs(dist) > w3Amp
                ext = f_fibConfluence(math.abs(dist)/w1Amp, adjTol * 2.5, FIB_EXT, degree)
                sc := math.max(sc, ext * 0.8)
            sc
        else if pos == 5
            0.3
        else
            0.5

f_invalRisk(pos, isBull, w0, w1, atrV, degree) =>
    if na(w0) or atrV <= 0
        0.0
    else
        anchor = pos == 3 and not allowDiag ? w1 : w0
        rawDist = isBull ? close - anchor : anchor - close
        buffer = atrV * (5.0 + degree * 3.0)
        if rawDist <= 0
            1.0
        else
            ratio = rawDist / buffer
            f_clamp(1.0 - ratio * ratio, 0.0, 1.0)

f_timeDecay(lastPvBar, degree) =>
    barsSince = bar_index - lastPvBar
    expected = 20 * degree
    f_clamp(barsSince / (expected * 3.0), 0.0, 1.0)

f_momentumProfile(pos, isBull, lastPv, lastBar) =>
    if na(lastPv) or bar_index <= lastBar
        0.5
    else
        bars = bar_index - lastBar
        change = close - lastPv
        normChg = isBull ? change : -change
        velocity = normChg / bars
        expV = atrNow / 2.0
        if pos == 2
            velocity > expV * 2.0 ? 1.0 : f_clamp(velocity / expV, 0.0, 1.0)
        else if pos == 4
            velocity < expV ? 1.0 : f_clamp(expV / velocity, 0.0, 1.0)
        else if pos == 1 or pos == 3
            velocity < expV * 0.5 ? 1.0 : f_clamp(expV * 0.5 / velocity, 0.0, 1.0)
        else
            0.5

wavePosScore = f_baseWavePosScore(curWavePos)
fibFit       = f_currentLegFibFit(curWavePos, curDir == 1, rLastPvPrice, rW1Amp, rW3Amp, rW5Amp, rWaveDegree)
invalRisk    = f_invalRisk(curWavePos, curDir == 1, rW0, rW1, atrNow, rWaveDegree)
timeDecay    = f_timeDecay(rLastPvBar, rWaveDegree)
momProfile   = f_momentumProfile(curWavePos, curDir == 1, rLastPvPrice, rLastPvBar)

logOdds = 
     (curQ - minQ)                 * wQual
     + (wavePosScore - 0.5)      * 2.0 * wContext
     + (fibFit       - 0.5)      * 2.0 * wFibFit
     -  invalRisk                  * wInval
     + (1.0 - timeDecay - 0.5)   * 2.0 * wTime * 0.5
     + (momProfile   - 0.5)      * 2.0 * wMom
     + (volScore     - 0.5)      * 2.0 * wVol
     +  probBias

probWithImpulse = f_sig(logOdds)
bullProb = curDir == 0 ? 0.5 : (curDir == 1 ? probWithImpulse : 1.0 - probWithImpulse)
bearProb = 1.0 - bullProb

// ══════════════════════════════════════════════════════════════════════════
//  SUPERTREND
// ══════════════════════════════════════════════════════════════════════════

var float st        = na
var int   stDir     = 1
var float upBand    = na
var float dnBand    = na

hbRaw = src + atrMult * atrNow
lbRaw = src - atrMult * atrNow

upBand := na(upBand[1]) ? hbRaw : (hbRaw < upBand[1] or close[1] > upBand[1] ? hbRaw : upBand[1])
dnBand := na(dnBand[1]) ? lbRaw : (lbRaw > dnBand[1] or close[1] < dnBand[1] ? lbRaw : dnBand[1])

if na(st[1])
    stDir := 1
    st    := dnBand
else
    if st[1] == upBand[1]
        stDir := close > upBand ? 1 : -1
    else
        stDir := close < dnBand ? -1 : 1
    st := stDir == 1 ? dnBand : upBand

rawFlipUp = stDir == 1  and stDir[1] == -1
rawFlipDn = stDir == -1 and stDir[1] == 1

// ══════════════════════════════════════════════════════════════════════════
//  EMISSION & VISUALS
// ══════════════════════════════════════════════════════════════════════════

effBull = invertEmit ? bearProb : bullProb
effBear = invertEmit ? bullProb : bearProb

filteredLong  = rawFlipUp and effBull >= probLongGate  and effBear <= probFadeGate
filteredShort = rawFlipDn and effBear >= probShortGate and effBull <= probFadeGate

currentQ = stDir == 1 ? effBull : effBear

tierHi = 0.60
tierMd = 0.40
trailCol = stDir == 1 ?
     (currentQ >= tierHi ? colBull : currentQ >= tierMd ? color.new(colBull, 40) : dimLowProb ? colDim : color.new(colBull, 70)) :
     (currentQ >= tierHi ? colBear : currentQ >= tierMd ? color.new(colBear, 40) : dimLowProb ? colDim : color.new(colBear, 70))

plot(st, "Trail", color=trailCol, linewidth=2, style=plot.style_linebr)

plotshape(filteredLong,  "Long (filtered)",  shape.triangleup,   location.belowbar, color=colBull, text="▲", textcolor=color.white, size=size.small)
plotshape(filteredShort, "Short (filtered)", shape.triangledown, location.abovebar, color=colBear, text="▼", textcolor=color.white, size=size.small)

plotshape(rawFlipUp and not filteredLong,  "Long (gated)",  shape.xcross, location.belowbar, color=color.new(colBull, 60), size=size.tiny)
plotshape(rawFlipDn and not filteredShort, "Short (gated)", shape.xcross, location.abovebar, color=color.new(colBear, 60), size=size.tiny)

bgIntensity = f_clamp((currentQ - 0.3) / 0.4, 0.0, 1.0)
bgTransp    = math.round(100 - bgIntensity * 20)
bgCol       = stDir == 1 ? color.new(colBull, bgTransp) : color.new(colBear, bgTransp)
bgcolor(showBg and currentQ >= tierMd ? bgCol : na)

// Wave labels
var label[] waveLabels = array.new_label()
if newPivot and array.size(pvP) >= 2
    while array.size(waveLabels) > 6
        label.delete(array.shift(waveLabels))
    sz = array.size(pvP)
    if curWavePos > 0 and sz >= curWavePos + 1
        lastIdx = sz - 1
        lastB = array.get(pvB, lastIdx)
        if bar_index - lastB < 50
            waveNum = curWavePos == 1 ? "②" : curWavePos == 2 ? "③" : curWavePos == 3 ? "④" : curWavePos == 4 ? "⑤" : "A"
            lbl = label.new(lastB, array.get(pvP, lastIdx), waveNum, 
                 style=array.get(pvT, lastIdx) > 0 ? label.style_label_down : label.style_label_up,
                 color=curWavePos == 2 ? colW3 : color.gray, textcolor=color.white, size=size.tiny)
            array.push(waveLabels, lbl)

// ══════════════════════════════════════════════════════════════════════════
//  ALERTS
// ══════════════════════════════════════════════════════════════════════════

alertcondition(filteredLong,  "Filtered Long",  "EWP·STv3 Long Signal")
alertcondition(filteredShort, "Filtered Short", "EWP·STv3 Short Signal")
alertcondition(rawFlipUp,     "Raw Flip Up",    "EWP·STv3 Raw Up (check prob)")
alertcondition(rawFlipDn,     "Raw Flip Down",  "EWP·STv3 Raw Down (check prob)")
````
