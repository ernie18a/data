# Strong Geometric Patterns Engine | ProjectSyndicate

- url: https://www.tradingview.com/script/EeujO8x8-Strong-Geometric-Patterns-Engine-ProjectSyndicate/
- type: indicator
- pine_id: PUB;5516eebc4a254d4ea27618ecb2795889
- version: 1.0

## Description

Strong Geometric Patterns Engine automatically detects, validates, and grades nine classic chart patterns using an objective, non-repainting geometry engine. It confirms every signal on a breakout close, projects adaptive measured-move take-profit and structural stop-loss levels scaled to Average Daily Range (ADR), scores each setup 0–10 for quality, and presents a full statistical breakdown on a non-intrusive dashboard to provide a quantifiable edge.

🧠 9-Pattern Geometric Detection — identifies Head & Shoulders, Inverse Head & Shoulders, Double Top, Double Bottom, Ascending / Descending / Symmetrical Triangles, and Rising / Falling Wedges from a non-repainting confirmed-pivot engine, so signals are stable and never redraawn after the fact.
🔒 Breakout-Confirmed, Non-Repainting — a valid shape only sets a pending setup; the signal fires exclusively when price closes through the pattern's trigger level, eliminating the subjective, repainting behaviour of standard ZigZag and pattern tools.
🎯 ADR-Adaptive Measured-Move TP/SL — TP1, TP2, and SL are derived from the pattern's own projected height (a true measured move), bounded by a percentage of the 10-day ADR, so risk and targets adapt automatically to any asset's volatility instead of using fixed points.
⭐ 0–10 Quality Scoring — every setup is graded on symmetry, convergence, and a volume confirmation bump, displayed as a star rating next to each signal so you can instantly gauge setup strength and filter for the best ones.

🎨 Direction-Matched Visuals — clean upward/downward entry markers, green bullish and red bearish labels, and crisp horizontal SL / TP1 / TP2 levels give instant visual confirmation of trade direction with no chart clutter.
📊 Full Performance Dashboard — a complete statistical overview including the real-time ADR10 value, the active/pending setup with its targets, total signals, TP1/TP2 win rates, a per-pattern breakdown across all nine pattern types, and a log of the most recent trade outcomes.
✅ Advanced Quality-Control Filters — user-configurable Pivot Length, equality/slope/convergence tolerances, min & max pattern span, measured-move bounds, and minimum bars between signals eliminate low-quality or oversized patterns and prevent over-signaling.
🔔 Comprehensive Alerts — get alerted the moment a new pattern is detected (pending), when price is approaching the trigger, when a setup confirms on the breakout, or only on strong high-score patterns. Available as a single rich alert() message (symbol, timeframe, trigger, invalidation, entry, SL, TP1, TP2, quality) for automation, plus six individually selectable named alert conditions.

🔧 Fully Customizable — control everything from pivot length and pattern-quality tolerances to colors, level extension, persistent historic levels & labels, adjustable signal label size, and dashboard text size.
🎯 Why this algo is unique: Standard pattern indicators repaint and offer subjective signals with no statistical backing. This is an objective, fully-gated, non-repainting engine that doesn't just draw a pattern — it recognizes nine of them from raw geometry, confirms them on a breakout, builds a complete adaptive risk framework (measured-move, ADR-bounded zones) around each one, grades its quality, and proves its historical performance on the very chart you're trading.

🚀 Apply to Gold (XAUUSD), Forex, Crypto, and Indices on any M5/M10/M15/M30/H1. The ADR-based, self-scaling geometry and extensive quality filters let it adapt to anything from M5 scalping to H4 swing trading.
🎯 How to use this? Use the dashboard to understand how each pattern type has recently performed on the current asset and timeframe. Favour higher-quality (higher-star) setups and those aligned with the higher-timeframe trend. Tune the pattern tolerances and measured-move multipliers to match your own risk tolerance and the asset's character.

⚠️ IMPORTANT NOTICE: This indicator is designed to identify statistically-backed pattern signals. It should NOT be used as a standalone signal for entering trades. Always use it in conjunction with your own trading strategy, price action analysis, and other technical indicators to confirm setups and manage risk.

## Source Code

````pine
//@version=6
// =====================================================================================
//  GEOMETRIC PATTERN ENGINE  —  9 classic chart patterns via trendline + symmetry
//  geometry with a pending-setup -> breakout-confirmation state machine and
//  measured-move targets (entry / SL / TP1 / TP2). Single-active state machine.
//
//  Patterns: Head & Shoulders, Inverse H&S, Double Top, Double Bottom,
//  Ascending / Descending / Symmetrical Triangle, Rising Wedge, Falling Wedge.
// =====================================================================================
indicator("Strong Geometric Patterns Engine", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ------------------------------- INPUTS ----------------------------------------------
pivot_length   = input.int(8,    "Pivot Length",                 minval=2,  maxval=50,   group="Detection")
eqTolPct       = input.float(13.0,"Equal-Level Tolerance % ADR",  minval=1.0,maxval=60.0, step=0.5, group="Detection")
slopeTolPct    = input.float(9.0, "Swing-Slope Threshold % ADR",  minval=1.0,maxval=60.0, step=0.5, group="Detection")
minSpan        = input.int(25,   "Min Pattern Width (bars)",      minval=5,  maxval=600,  group="Detection")
maxSpan        = input.int(400,  "Max Pattern Width (bars)",      minval=20, maxval=2000, group="Detection")
convergeFrac   = input.float(0.80,"Triangle/Wedge Converge Frac", minval=0.3,maxval=0.99, step=0.01, group="Detection")
dblDepthMult   = input.float(2.0, "Double Min-Depth (x tol)",     minval=0.5,maxval=6.0,  step=0.1, group="Detection")
minSigSpacing  = input.int(60,   "Min Bars Between Signals",      minval=5,  maxval=600,  group="Detection")
pendingExpiry  = input.int(120,  "Pending Setup Expiry (bars)",   minval=10, maxval=1000, group="Detection")

tp1Mult        = input.float(0.50,"TP1 = x * Measured Move",       minval=0.1,maxval=1.5, step=0.05, group="Targets")
tp2Mult        = input.float(0.85,"TP2 = x * Measured Move",       minval=0.1,maxval=2.0, step=0.05, group="Targets")
minHadr        = input.float(0.12,"Measured-Move Floor (x ADR)",   minval=0.02,maxval=1.0,step=0.02, group="Targets")
maxHadr        = input.float(1.00,"Measured-Move Cap (x ADR)",     minval=0.2,maxval=3.0, step=0.1, group="Targets")
slBufAdr       = input.float(0.12,"SL Buffer (x ADR)",             minval=0.02,maxval=1.0,step=0.02, group="Targets")
zoneHPct       = input.float(1.0, "Zone Height % ADR",             minval=0.1, step=0.1, group="Targets")
zone_ext       = input.int(60,   "Zone Extension (bars)",          minval=10, maxval=500, group="Targets")

showHS         = input.bool(true, "Head & Shoulders",     inline="p1", group="Patterns")
showDbl        = input.bool(true, "Double Top/Bottom",     inline="p1", group="Patterns")
showTri        = input.bool(true, "Triangles",             inline="p2", group="Patterns")
showWedge      = input.bool(true, "Wedges",                inline="p2", group="Patterns")
showLines      = input.bool(false,"Draw Pattern Trendlines", group="Display")
histLevels     = input.bool(true, "Show Historic Levels & Labels", group="Display")
lblSize        = input.string("Normal","Signal Label Size", options=["Tiny","Small","Normal","Large","Huge"], group="Display")
showPivots     = input.bool(false,"Show Pivot Dots",         group="Display")

bullCol   = input.color(color.new(#26a69a,0), "Bullish", inline="c1", group="Colors")
bearCol   = input.color(color.new(#ef5350,0), "Bearish", inline="c1", group="Colors")
colTP1    = input.color(color.new(#26a69a,0), "TP1", inline="c2", group="Colors")
colTP2    = input.color(color.new(#00897b,0), "TP2", inline="c2", group="Colors")
colSL     = input.color(color.new(#b71c1c,0), "SL",  inline="c2", group="Colors")
boxAlpha  = input.int(85, "Zone Transparency", minval=0, maxval=100, group="Colors")
dashSz    = input.string("Normal","Dashboard Text Size", options=["Tiny","Small","Normal","Large"], group="Dashboard")

gAl          = "═══ Alerts ═══"
alertsOn     = input.bool(true,  "Enable Alerts",                    group=gAl)
alDetect     = input.bool(true,  "New Pattern Detected (pending)",   group=gAl, tooltip="Fire as soon as a new pattern is detected and a setup goes pending, before the breakout confirms.")
alConfirm    = input.bool(true,  "Pattern Confirmed (breakout)",     group=gAl, tooltip="Fire when price breaks the trigger and the trade opens.")
alApproach   = input.bool(false, "Price Approaching Trigger",        group=gAl)
alStrongOnly = input.bool(false, "Detect Alerts: Strong Only",       group=gAl)
alStrongThr  = input.float(6.0,  "Strong-Pattern Score",             minval=0, maxval=10, step=0.5, group=gAl)
alProxPct    = input.float(0.10, "Approach Proximity (% of price)",  minval=0.0, step=0.01, group=gAl)

// ------------------------------- ADR10 -----------------------------------------------
float adr10 = request.security(syminfo.tickerid, "D",
     (math.sum(high[1] - low[1], 10)) / 10, lookahead=barmerge.lookahead_off)
float adrSafe = nz(adr10) > 0.0 ? adr10 : close * 0.005
float zh = adrSafe * (zoneHPct / 100.0) / 2.0
float volAvg = ta.sma(volume, 50)

// ------------------------------- PIVOT STORE -----------------------------------------
int MAX_PIV = 60
var array<float> phP = array.new<float>()
var array<int>   phB = array.new<int>()
var array<float> plP = array.new<float>()
var array<int>   plB = array.new<int>()

float rawPH = ta.pivothigh(pivot_length, pivot_length)
float rawPL = ta.pivotlow(pivot_length,  pivot_length)

var bool newPivot = false
newPivot := false
if barstate.isconfirmed
    if not na(rawPH)
        array.push(phP, rawPH)
        array.push(phB, bar_index - pivot_length)
        if array.size(phP) > MAX_PIV
            array.shift(phP)
            array.shift(phB)
        newPivot := true
    if not na(rawPL)
        array.push(plP, rawPL)
        array.push(plB, bar_index - pivot_length)
        if array.size(plP) > MAX_PIV
            array.shift(plP)
            array.shift(plB)
        newPivot := true

if showPivots and not na(rawPH)
    label.new(bar_index - pivot_length, rawPH, "", style=label.style_circle, color=color.new(bearCol,40), size=size.tiny)
if showPivots and not na(rawPL)
    label.new(bar_index - pivot_length, rawPL, "", style=label.style_circle, color=color.new(bullCol,40), size=size.tiny)

// ------------------------------- STATE -----------------------------------------------
// pending setup (single)
var int    pendDir   = 0
var float  pendTrig  = na
var float  pendInval = na
var float  pendH     = na
var int    pendExp   = 0
var int    pendIdx   = -1
var float  pendScore = 0.0
// anchors for drawing (3 highs, 3 lows) snapshotted at scan time
var int    aHb1=0
var int    aHb2=0
var int    aHb3=0
var int    aLb1=0
var int    aLb2=0
var int    aLb3=0
var float  aHp1=na
var float  aHp2=na
var float  aHp3=na
var float  aLp1=na
var float  aLp2=na
var float  aLp3=na

// active trade
var int    actDir   = 0
var int    actIdx   = -1
var float  actEntry = na
var float  actSL    = na
var float  actTP1   = na
var float  actTP2   = na
var float  actScore = 0.0
var int    actBar   = 0
var int    lastSigBar = -100000

// stats
var int totalSigs=0
var int closedTrades=0
var int tp1Wins=0
var int tp2Wins=0
var int slLosses=0
var array<int> patSig = array.new<int>(9, 0)
var array<int> patT1  = array.new<int>(9, 0)
var array<int> patT2  = array.new<int>(9, 0)
var array<int> patSL  = array.new<int>(9, 0)
var array<string> tradeLog = array.new<string>()

idxName(int i) =>
    switch i
        0 => "Head & Shoulders"
        1 => "Inverse H&S"
        2 => "Double Top"
        3 => "Double Bottom"
        4 => "Ascending Triangle"
        5 => "Descending Triangle"
        6 => "Symmetrical Triangle"
        7 => "Rising Wedge"
        8 => "Falling Wedge"
        => "—"

scoreSym(float diff, float tol, float h, float adr) =>
    float sym = math.max(0.0, 1.0 - diff/(tol+1e-12))
    float hh  = math.min(1.0, h/(adr*0.6))
    math.round((0.65*sym + 0.35*hh)*10.0*10)/10.0
scoreTri(float h, float adr, bool conv) =>
    float hh = math.min(1.0, h/(adr*0.7))
    float cv = conv ? 1.0 : 0.4
    math.round((0.55*cv + 0.45*hh)*10.0*10)/10.0

// ------------------------------- PATTERN SCAN ----------------------------------------
// returns best candidate: [found, idx, dir, trigger, inval, height, score]
scanPatterns(float adr) =>
    float tol  = adr * eqTolPct/100.0
    float stol = adr * slopeTolPct/100.0
    int nh = array.size(phP)
    int nl = array.size(plP)

    bool   bFound = false
    int    bPri   = 99
    int    bIdx   = -1
    int    bDir   = 0
    float  bTrig  = na
    float  bInval = na
    float  bH     = na
    float  bScore = 0.0

    if nh >= 3 and nl >= 3
        float hp1 = array.get(phP, nh-3)
        float hp2 = array.get(phP, nh-2)
        float hp3 = array.get(phP, nh-1)
        int   hb1 = array.get(phB, nh-3)
        int   hb3 = array.get(phB, nh-1)
        float lp1 = array.get(plP, nl-3)
        float lp2 = array.get(plP, nl-2)
        float lp3 = array.get(plP, nl-1)
        int   lb1 = array.get(plB, nl-3)
        int   lb3 = array.get(plB, nl-1)

        int span = math.max(hb3, lb3) - math.min(hb1, lb1)
        if span >= minSpan and span <= maxSpan
            // --- 0 Head & Shoulders (bear) ---
            if showHS and hp2 > hp1+tol and hp2 > hp3+tol and math.abs(hp1-hp3) <= tol*1.6
                float neck = (lp2+lp3)/2.0
                float h = hp2 - neck
                float sc = scoreSym(math.abs(hp1-hp3), tol, h, adr)
                if 0 < bPri or (0 == bPri and sc > bScore)
                    bFound := true
                    bPri   := 0
                    bIdx   := 0
                    bDir   := -1
                    bTrig  := neck
                    bInval := hp3
                    bH     := h
                    bScore := sc
            // --- 1 Inverse H&S (bull) ---
            if showHS and lp2 < lp1-tol and lp2 < lp3-tol and math.abs(lp1-lp3) <= tol*1.6
                float neck = (hp2+hp3)/2.0
                float h = neck - lp2
                float sc = scoreSym(math.abs(lp1-lp3), tol, h, adr)
                if 0 < bPri or (0 == bPri and sc > bScore)
                    bFound := true
                    bPri   := 0
                    bIdx   := 1
                    bDir   := 1
                    bTrig  := neck
                    bInval := lp3
                    bH     := h
                    bScore := sc
            // --- 2 Double Top (bear) ---
            if showDbl and math.abs(hp2-hp3) <= tol and hp2 > lp3+tol
                float h = ((hp2+hp3)/2.0) - lp3
                if h >= tol*dblDepthMult
                    float sc = scoreSym(math.abs(hp2-hp3), tol, h, adr)
                    if 1 < bPri or (1 == bPri and sc > bScore)
                        bFound := true
                        bPri   := 1
                        bIdx   := 2
                        bDir   := -1
                        bTrig  := lp3
                        bInval := math.max(hp2,hp3)
                        bH     := h
                        bScore := sc
            // --- 3 Double Bottom (bull) ---
            if showDbl and math.abs(lp2-lp3) <= tol and hp3 > lp2+tol
                float h = hp3 - ((lp2+lp3)/2.0)
                if h >= tol*dblDepthMult
                    float sc = scoreSym(math.abs(lp2-lp3), tol, h, adr)
                    if 1 < bPri or (1 == bPri and sc > bScore)
                        bFound := true
                        bPri   := 1
                        bIdx   := 3
                        bDir   := 1
                        bTrig  := hp3
                        bInval := math.min(lp2,lp3)
                        bH     := h
                        bScore := sc
            // --- slopes ---
            int hDir = hp3 > hp1+stol ? 1 : (hp3 < hp1-stol ? -1 : 0)
            int lDir = lp3 > lp1+stol ? 1 : (lp3 < lp1-stol ? -1 : 0)
            float rngNow = hp3 - lp3
            float rngOld = hp1 - lp1
            bool  conv = rngOld > 0 and rngNow <= rngOld*convergeFrac
            float resist = math.max(hp1, math.max(hp2, hp3))
            float support = math.min(lp1, math.min(lp2, lp3))
            float htri = resist - support
            // --- 4 Ascending Triangle (bull) ---
            if showTri and hDir == 0 and lDir == 1
                float sc = scoreTri(htri, adr, conv)
                if 2 < bPri or (2 == bPri and sc > bScore)
                    bFound := true
                    bPri   := 2
                    bIdx   := 4
                    bDir   := 1
                    bTrig  := resist
                    bInval := lp3
                    bH     := htri
                    bScore := sc
            // --- 5 Descending Triangle (bear) ---
            if showTri and lDir == 0 and hDir == -1
                float sc = scoreTri(htri, adr, conv)
                if 2 < bPri or (2 == bPri and sc > bScore)
                    bFound := true
                    bPri   := 2
                    bIdx   := 5
                    bDir   := -1
                    bTrig  := support
                    bInval := hp3
                    bH     := htri
                    bScore := sc
            // --- 6 Symmetrical Triangle ---
            if showTri and hDir == -1 and lDir == 1 and conv
                int prior = (hp1+lp1) < (hp3+lp3) ? 1 : -1
                float sc = scoreTri(htri, adr, true)
                if 3 < bPri or (3 == bPri and sc > bScore)
                    bFound := true
                    bPri   := 3
                    bIdx   := 6
                    bDir   := prior
                    bTrig  := prior == 1 ? resist : support
                    bInval := prior == 1 ? support : resist
                    bH     := htri
                    bScore := sc
            // --- 7 Rising Wedge (bear) ---
            if showWedge and hDir == 1 and lDir == 1 and conv
                float sc = scoreTri(htri, adr, true)
                if 4 < bPri or (4 == bPri and sc > bScore)
                    bFound := true
                    bPri   := 4
                    bIdx   := 7
                    bDir   := -1
                    bTrig  := lp3
                    bInval := hp3
                    bH     := htri
                    bScore := sc
            // --- 8 Falling Wedge (bull) ---
            if showWedge and hDir == -1 and lDir == -1 and conv
                float sc = scoreTri(htri, adr, true)
                if 4 < bPri or (4 == bPri and sc > bScore)
                    bFound := true
                    bPri   := 4
                    bIdx   := 8
                    bDir   := 1
                    bTrig  := hp3
                    bInval := lp3
                    bH     := htri
                    bScore := sc

    [bFound, bIdx, bDir, bTrig, bInval, bH, bScore]

// ------------------------------- TRADE MGMT ------------------------------------------
logTrade(string s) =>
    array.unshift(tradeLog, s)
    if array.size(tradeLog) > 12
        array.pop(tradeLog)

// manage open trade (intrabar, optimistic TP-first like the reference)
string closeRes = ""
if actDir == 1 and not na(actTP2)
    if high >= actTP2
        closeRes := "TP2"
    else if high >= actTP1
        closeRes := "TP1"
    else if low <= actSL
        closeRes := "SL"
if actDir == -1 and not na(actTP2)
    if low <= actTP2
        closeRes := "TP2"
    else if low <= actTP1
        closeRes := "TP1"
    else if high >= actSL
        closeRes := "SL"

if closeRes != ""
    closedTrades += 1
    if closeRes == "TP2"
        tp2Wins += 1
        tp1Wins += 1
        array.set(patT2, actIdx, array.get(patT2, actIdx) + 1)
        array.set(patT1, actIdx, array.get(patT1, actIdx) + 1)
    else if closeRes == "TP1"
        tp1Wins += 1
        array.set(patT1, actIdx, array.get(patT1, actIdx) + 1)
    else
        slLosses += 1
        array.set(patSL, actIdx, array.get(patSL, actIdx) + 1)
    logTrade(idxName(actIdx) + " | " + closeRes)
    actDir := 0

// ------------------------------- PENDING -> FIRE -------------------------------------
var bool justFired = false
justFired := false
var bool justDetected = false
justDetected := false

if pendDir != 0 and actDir == 0
    bool fired = (pendDir == 1 and close > pendTrig) or (pendDir == -1 and close < pendTrig)
    if fired and (bar_index - lastSigBar) >= minSigSpacing
        // open trade with measured-move targets
        float h = math.max(pendH, adrSafe*minHadr)
        h := math.min(h, adrSafe*maxHadr)
        float entry = close
        float sl  = na
        float tp1 = na
        float tp2 = na
        if pendDir == 1
            sl  := pendInval - adrSafe*slBufAdr
            if sl >= entry
                sl := entry - adrSafe*slBufAdr*2
            tp1 := entry + h*tp1Mult
            tp2 := entry + h*tp2Mult
        else
            sl  := pendInval + adrSafe*slBufAdr
            if sl <= entry
                sl := entry + adrSafe*slBufAdr*2
            tp1 := entry - h*tp1Mult
            tp2 := entry - h*tp2Mult
        actDir   := pendDir
        actIdx   := pendIdx
        actEntry := entry
        actSL    := sl
        actTP1   := tp1
        actTP2   := tp2
        actScore := volume > volAvg ? math.min(10.0, pendScore + 0.8) : pendScore
        actBar   := bar_index
        lastSigBar := bar_index
        totalSigs += 1
        array.set(patSig, pendIdx, array.get(patSig, pendIdx) + 1)
        justFired := true
        // clear pending
        pendDir := 0
    else
        // invalidation / expiry
        if pendDir == 1 and low < pendInval
            pendDir := 0
        else if pendDir == -1 and high > pendInval
            pendDir := 0
        else if bar_index > pendExp
            pendDir := 0

// ------------------------------- SCAN (set pending) ----------------------------------
if newPivot and actDir == 0 and pendDir == 0 and (bar_index - lastSigBar) >= minSigSpacing
    [found, fIdx, fDir, fTrig, fInval, fH, fScore] = scanPatterns(adrSafe)
    if found
        pendDir   := fDir
        pendIdx   := fIdx
        pendTrig  := fTrig
        pendInval := fInval
        pendH     := fH
        pendScore := fScore
        pendExp   := bar_index + pendingExpiry
        justDetected := true
        int nh = array.size(phP)
        int nl = array.size(plP)
        aHp1 := array.get(phP, nh-3)
        aHp2 := array.get(phP, nh-2)
        aHp3 := array.get(phP, nh-1)
        aHb1 := array.get(phB, nh-3)
        aHb2 := array.get(phB, nh-2)
        aHb3 := array.get(phB, nh-1)
        aLp1 := array.get(plP, nl-3)
        aLp2 := array.get(plP, nl-2)
        aLp3 := array.get(plP, nl-1)
        aLb1 := array.get(plB, nl-3)
        aLb2 := array.get(plB, nl-2)
        aLb3 := array.get(plB, nl-1)

// ------------------------------- DRAW ON FIRE ----------------------------------------
starStr(float sc) =>
    int filled = math.round(sc/2.0)
    filled := math.max(0, math.min(5, filled))
    string s = ""
    for i = 0 to 4
        s := s + (i < filled ? "★" : "☆")
    s

// persistent handles — only the latest setup is drawn, so the chart stays clean
var line  slLn = na
var line  t1Ln = na
var line  t2Ln = na
var label slLb = na
var label t1Lb = na
var label t2Lb = na
var label nmLb = na
var line  cl1  = na
var line  cl2  = na
var line  cl3  = na
var line  cl4  = na

// sharp, lightweight entry markers (these are the only thing that persists as history)
plotshape(justFired and actDir == 1,  title="Long Entry",  style=shape.triangleup,   location=location.belowbar, color=bullCol, size=size.small)
plotshape(justFired and actDir == -1, title="Short Entry", style=shape.triangledown, location=location.abovebar, color=bearCol, size=size.small)

// map the label-size setting to size constants (level value-labels one notch smaller)
string sigSz = lblSize == "Tiny" ? size.tiny : lblSize == "Small" ? size.small : lblSize == "Normal" ? size.normal : lblSize == "Large" ? size.large : size.huge
string lvlSz = lblSize == "Tiny" ? size.tiny : lblSize == "Small" ? size.tiny  : lblSize == "Normal" ? size.small  : lblSize == "Large" ? size.normal : size.large

if justFired
    color dc   = actDir == 1 ? bullCol : bearCol
    int   sigB = bar_index
    int   extB = sigB + zone_ext
    // when historic display is OFF, clear the previous setup; otherwise keep all
    if not histLevels
        line.delete(slLn)
        line.delete(t1Ln)
        line.delete(t2Ln)
        line.delete(cl1)
        line.delete(cl2)
        line.delete(cl3)
        line.delete(cl4)
        label.delete(slLb)
        label.delete(t1Lb)
        label.delete(t2Lb)
        label.delete(nmLb)
    // compact name + quality tag at the entry
    nmLb := label.new(sigB, actEntry, idxName(actIdx) + "  " + starStr(actScore),
              color=color.new(dc, 25), textcolor=color.white,
              style=(actDir == 1 ? label.style_label_up : label.style_label_down), size=sigSz)
    // clean horizontal SL / TP1 / TP2 levels for the active setup
    t1Ln := line.new(sigB, actTP1, extB, actTP1, color=colTP1, width=2)
    t2Ln := line.new(sigB, actTP2, extB, actTP2, color=color.new(colTP2,15), width=1, style=line.style_dashed)
    slLn := line.new(sigB, actSL,  extB, actSL,  color=colSL,  width=2)
    t1Lb := label.new(extB, actTP1, "TP1 " + str.tostring(actTP1, format.mintick), style=label.style_label_left, color=color.new(colTP1,10), textcolor=color.white, size=lvlSz)
    t2Lb := label.new(extB, actTP2, "TP2 " + str.tostring(actTP2, format.mintick), style=label.style_label_left, color=color.new(colTP2,10), textcolor=color.white, size=lvlSz)
    slLb := label.new(extB, actSL,  "SL "  + str.tostring(actSL,  format.mintick), style=label.style_label_left, color=color.new(colSL,10),  textcolor=color.white, size=lvlSz)
    // optional, subtle pattern geometry (OFF by default)
    if showLines
        cl1 := line.new(aHb1, aHp1, aHb2, aHp2, color=color.new(bearCol,55), width=1)
        cl2 := line.new(aHb2, aHp2, aHb3, aHp3, color=color.new(bearCol,55), width=1)
        cl3 := line.new(aLb1, aLp1, aLb2, aLp2, color=color.new(bullCol,55), width=1)
        cl4 := line.new(aLb2, aLp2, aLb3, aLp3, color=color.new(bullCol,55), width=1)

// ------------------------------- DASHBOARD -------------------------------------------
if barstate.islast
    string szT = dashSz == "Tiny" ? size.tiny : dashSz == "Small" ? size.small : dashSz == "Normal" ? size.normal : size.large
    string szB = dashSz == "Tiny" ? size.tiny : dashSz == "Small" ? size.small : dashSz == "Normal" ? size.small  : size.normal

    float wr1 = closedTrades > 0 ? (tp1Wins/closedTrades)*100.0 : 0.0
    float wr2 = closedTrades > 0 ? (tp2Wins/closedTrades)*100.0 : 0.0

    string statusTxt = actDir != 0 ? "IN TRADE" : (pendDir != 0 ? "PENDING" : "FLAT")
    color  statusCol = actDir != 0 ? color.new(#2962ff,0) : (pendDir != 0 ? color.new(color.orange,0) : color.new(color.gray,0))

    string curName = actDir != 0 ? idxName(actIdx) : (pendDir != 0 ? idxName(pendIdx) : "—")
    int    curDir  = actDir != 0 ? actDir : pendDir
    string dirTxt  = curDir == 1 ? "LONG ▲" : curDir == -1 ? "SHORT ▼" : "—"
    color  dirCol  = curDir == 1 ? bullCol : curDir == -1 ? bearCol : color.gray
    int    barsIn  = actDir != 0 ? (bar_index - actBar) : 0

    var table t = table.new(position.top_right, 2, 33,
                        bgcolor=color.new(#161a25, 8),
                        frame_color=color.new(#363a45, 40), frame_width=2,
                        border_color=color.new(#2a2e39, 60), border_width=1)

    table.cell(t, 0, 0, "◆ GEOMETRIC PATTERN ENGINE", text_color=color.white, text_size=szT, bgcolor=color.new(#2962ff, 10))
    table.merge_cells(t, 0, 0, 1, 0)

    table.cell(t, 0, 1, "ADR10", text_color=color.new(color.yellow,0), text_size=szB)
    table.cell(t, 1, 1, str.tostring(adrSafe, format.mintick) + "  (" + str.tostring(adrSafe/syminfo.mintick/10.0, "#") + "p)", text_color=color.new(color.yellow,0), text_size=szB)

    table.cell(t, 0, 2, "ACTIVE SETUP", text_color=color.new(color.white,20), text_size=szB, bgcolor=color.new(#363a45, 70))
    table.merge_cells(t, 0, 2, 1, 2)
    table.cell(t, 0, 3, "Pattern", text_color=color.white, text_size=szB)
    table.cell(t, 1, 3, curName, text_color=color.white, text_size=szB)
    table.cell(t, 0, 4, "Direction", text_color=color.white, text_size=szB)
    table.cell(t, 1, 4, dirTxt, text_color=dirCol, text_size=szB)
    table.cell(t, 0, 5, "Quality", text_color=color.white, text_size=szB)
    table.cell(t, 1, 5, actDir != 0 ? (starStr(actScore) + " " + str.tostring(actScore,"#.#")) : (pendDir != 0 ? (starStr(pendScore)+" "+str.tostring(pendScore,"#.#")) : "—"), text_color=color.new(#ffd54f,0), text_size=szB)
    table.cell(t, 0, 6, "Status", text_color=color.white, text_size=szB)
    table.cell(t, 1, 6, statusTxt, text_color=statusCol, text_size=szB)
    table.cell(t, 0, 7, "Entry", text_color=color.white, text_size=szB)
    table.cell(t, 1, 7, actDir != 0 ? str.tostring(actEntry, format.mintick) : "—", text_color=color.white, text_size=szB)
    table.cell(t, 0, 8, "TP1", text_color=color.white, text_size=szB)
    table.cell(t, 1, 8, actDir != 0 ? str.tostring(actTP1, format.mintick) : "—", text_color=color.new(colTP1,0), text_size=szB)
    table.cell(t, 0, 9, "TP2", text_color=color.white, text_size=szB)
    table.cell(t, 1, 9, actDir != 0 ? str.tostring(actTP2, format.mintick) : "—", text_color=color.new(colTP2,0), text_size=szB)
    table.cell(t, 0, 10, "SL", text_color=color.white, text_size=szB)
    table.cell(t, 1, 10, actDir != 0 ? str.tostring(actSL, format.mintick) : "—", text_color=color.new(colSL,0), text_size=szB)
    table.cell(t, 0, 11, "Bars In Trade", text_color=color.white, text_size=szB)
    table.cell(t, 1, 11, actDir != 0 ? str.tostring(barsIn) : "—", text_color=color.white, text_size=szB)

    table.cell(t, 0, 12, "PERFORMANCE", text_color=color.new(color.white,20), text_size=szB, bgcolor=color.new(#363a45, 70))
    table.merge_cells(t, 0, 12, 1, 12)
    table.cell(t, 0, 13, "Total Signals", text_color=color.white, text_size=szB)
    table.cell(t, 1, 13, str.tostring(totalSigs), text_color=color.new(bullCol,0), text_size=szB)
    table.cell(t, 0, 14, "Closed Trades", text_color=color.white, text_size=szB)
    table.cell(t, 1, 14, str.tostring(closedTrades), text_color=color.white, text_size=szB)
    table.cell(t, 0, 15, "TP1 Wins", text_color=color.white, text_size=szB)
    table.cell(t, 1, 15, str.tostring(tp1Wins), text_color=color.new(colTP1,0), text_size=szB)
    table.cell(t, 0, 16, "TP2 Wins", text_color=color.white, text_size=szB)
    table.cell(t, 1, 16, str.tostring(tp2Wins), text_color=color.new(colTP2,0), text_size=szB)
    table.cell(t, 0, 17, "SL Losses", text_color=color.white, text_size=szB)
    table.cell(t, 1, 17, str.tostring(slLosses), text_color=color.new(colSL,0), text_size=szB)
    table.cell(t, 0, 18, "TP1 Win Rate", text_color=color.white, text_size=szB)
    color wrC = wr1 >= 50.0 ? color.new(bullCol,0) : color.new(bearCol,0)
    table.cell(t, 1, 18, str.tostring(wr1, "#.#") + "%", text_color=wrC, text_size=szB)
    table.cell(t, 0, 19, "TP2 Win Rate", text_color=color.white, text_size=szB)
    table.cell(t, 1, 19, str.tostring(wr2, "#.#") + "%", text_color=color.new(colTP2,0), text_size=szB)

    table.cell(t, 0, 20, "BY PATTERN  (sig · WR)", text_color=color.new(color.white,20), text_size=szB, bgcolor=color.new(#363a45, 70))
    table.merge_cells(t, 0, 20, 1, 20)
    for i = 0 to 8
        int s  = array.get(patSig, i)
        int t1 = array.get(patT1, i)
        int sl = array.get(patSL, i)
        int cl = t1 + sl
        float w = cl > 0 ? (t1/cl)*100.0 : 0.0
        table.cell(t, 0, 21+i, idxName(i), text_color=color.new(color.white, s>0?0:55), text_size=szB)
        table.cell(t, 1, 21+i, s > 0 ? (str.tostring(s) + " · " + str.tostring(w,"#") + "%") : "—",
                   text_color=s>0 ? (w>=50.0?color.new(bullCol,0):color.new(bearCol,0)) : color.new(color.gray,40), text_size=szB)

    table.cell(t, 0, 30, "LAST TRADES", text_color=color.new(color.white,20), text_size=szB, bgcolor=color.new(#363a45, 70))
    table.merge_cells(t, 0, 30, 1, 30)
    int hist = array.size(tradeLog)
    if hist > 0
        int shown = math.min(hist, 2)
        for i = 0 to shown-1
            string e = array.get(tradeLog, i)
            color rc = str.contains(e, "TP2") ? color.new(colTP2,0) : str.contains(e, "TP1") ? color.new(colTP1,0) : color.new(colSL,0)
            table.cell(t, 0, 31+i, e, text_color=rc, text_size=szB)
            table.merge_cells(t, 0, 31+i, 1, 31+i)
    else
        table.cell(t, 0, 31, "No trades yet", text_color=color.new(color.white,50), text_size=szB)
        table.merge_cells(t, 0, 31, 1, 31)

// ------------------------------- ALERTS ----------------------------------------------
// event series (also used by alertcondition so they are selectable in the alert dialog)
bool  newBull  = justDetected and pendDir == 1
bool  newBear  = justDetected and pendDir == -1
bool  strongDet= justDetected and pendScore >= alStrongThr
bool  detPass  = not alStrongOnly or pendScore >= alStrongThr
float alProx   = close * alProxPct / 100.0
bool  apprBull = pendDir == 1  and not na(pendTrig) and math.abs(close - pendTrig) <= alProx
bool  apprBear = pendDir == -1 and not na(pendTrig) and math.abs(close - pendTrig) <= alProx
bool  cfmBull  = justFired and actDir == 1
bool  cfmBear  = justFired and actDir == -1

// dynamic alert() calls (for a single "Any alert() function call" alert) — respect settings
if alertsOn and alDetect and detPass and (newBull or newBear)
    alert((newBull ? "NEW BULLISH PATTERN DETECTED  " : "NEW BEARISH PATTERN DETECTED  ") + idxName(pendIdx) +
          "\nSymbol: " + syminfo.tickerid + "  TF: " + timeframe.period +
          "\nTrigger: " + str.tostring(pendTrig, format.mintick) + " (break to confirm)" +
          "\nInvalidation: " + str.tostring(pendInval, format.mintick) +
          "\nQuality: " + str.tostring(pendScore,"#.#") + "/10", alert.freq_once_per_bar_close)

if alertsOn and alConfirm and cfmBull
    alert("BULLISH " + idxName(actIdx) + " CONFIRMED" +
          "\nSymbol: " + syminfo.tickerid + "  TF: " + timeframe.period +
          "\nEntry: " + str.tostring(actEntry, format.mintick) +
          "\nSL: "  + str.tostring(actSL,  format.mintick) +
          "\nTP1: " + str.tostring(actTP1, format.mintick) +
          "\nTP2: " + str.tostring(actTP2, format.mintick) +
          "\nQuality: " + str.tostring(actScore,"#.#") + "/10", alert.freq_once_per_bar_close)
if alertsOn and alConfirm and cfmBear
    alert("BEARISH " + idxName(actIdx) + " CONFIRMED" +
          "\nSymbol: " + syminfo.tickerid + "  TF: " + timeframe.period +
          "\nEntry: " + str.tostring(actEntry, format.mintick) +
          "\nSL: "  + str.tostring(actSL,  format.mintick) +
          "\nTP1: " + str.tostring(actTP1, format.mintick) +
          "\nTP2: " + str.tostring(actTP2, format.mintick) +
          "\nQuality: " + str.tostring(actScore,"#.#") + "/10", alert.freq_once_per_bar_close)

if alertsOn and alApproach and (apprBull or apprBear)
    alert((apprBull ? "Price approaching BULLISH trigger  " : "Price approaching BEARISH trigger  ") + idxName(pendIdx) +
          "\nSymbol: " + syminfo.tickerid + "  TF: " + timeframe.period +
          "\nTrigger: " + str.tostring(pendTrig, format.mintick) +
          "\nPrice: " + str.tostring(close, format.mintick), alert.freq_once_per_bar)

// named conditions (selectable individually in TradingView's alert dialog)
alertcondition(newBull,                "New Bullish Pattern",    "New bullish geometric pattern detected (pending)")
alertcondition(newBear,                "New Bearish Pattern",    "New bearish geometric pattern detected (pending)")
alertcondition(strongDet,              "Strong Pattern Detected","Strong geometric pattern detected (high quality)")
alertcondition(apprBull or apprBear,   "Approaching Trigger",    "Price approaching a pending pattern trigger")
alertcondition(cfmBull,                "Bullish Pattern Confirmed","Bullish geometric pattern confirmed (breakout)")
alertcondition(cfmBear,                "Bearish Pattern Confirmed","Bearish geometric pattern confirmed (breakout)")
````
