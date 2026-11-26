# Hybrid Forecast

- url: https://www.tradingview.com/script/gBMDZNCG-Hybrid-Forecast/
- type: indicator
- pine_id: PUB;baafc36f670745808bc264482de9b129
- version: 1.0

## Description

Hybrid Forecast is a chart-overlay indicator built to organize short-term directional ideas into something more useful than a simple buy or sell marker. Instead of only printing a signal, it projects a target zone, shows the expected path, and marks an invalidation level so the setup is easier to read as a complete trade idea rather than a standalone arrow. The purpose of the script is not to predict every move. The purpose is to make short-horizon market structure easier to interpret by combining signal direction, projected destination, and visible failure points in one clean layout.

The reason this script exists is simple: many indicators either do too little or show too much. Some only mark entries and leave the rest to the trader. Others cover the chart in so many objects and statistics that the decision actually gets harder. Hybrid Forecast was built to sit in the middle. It tries to keep the chart readable while still giving enough context to understand where price may be headed, where the idea breaks down, and how the current settings are behaving over time. That is also the style used in many of the stronger TradingView descriptions: explain the problem, explain the tool’s role, and explain the workflow in practical terms rather than hype.

At a high level, the script blends a live directional engine with a memory-based forecast layer. The live side evaluates current price behavior, slope, persistence, trend quality, volatility, and expansion. The memory side compares the current setup to prior stored conditions and contributes forecast information when the match quality is good enough. The result is a hybrid forecast process that is meant to be more adaptive than a fixed signal model while still staying compact and readable on the chart. In the current script, that hybrid structure is visible through the live-versus-memory blending controls, stored setup memory, neighbor search logic, and forecast projection workflow.

What you see on the chart is intentionally limited to the parts that help with decision-making. The script can show entry triggers, a projected forecast zone, a projection arrow, a stop-loss or invalidation line, optional target labels, and optional high-quality badges for the strongest setups. The idea is to present a forecast as a small package: direction, projected zone, and a clear line where the trade idea is likely wrong. That is why the forecast zone and the invalidation line matter just as much as the trigger marker itself.

The dashboard is intentionally small. It is not meant to be a developer console. It is there to answer a few practical questions quickly. “Samples” shows how many completed forecasts have already been graded. “Right Direction” shows how often price moved the expected way. “Reached Target” shows how often price got into the projected zone. “Strong Setups” shows how the highest-quality setups are performing. “Main Blocker” tells you the biggest reason the script is not printing more signals right now. “Profile Mode” simply reflects the current signal frequency profile. Those are the only stats most traders need during live use, and the rest is deliberately kept out of the public HUD.

The main public control is Signal Frequency. Conservative is more selective and tends to wait for cleaner structure. Balanced is the best starting point for most users and is the intended default. Active is more responsive and will generally produce more opportunities, but naturally it also asks the trader to tolerate more noise. The other important public controls are Forecast Horizon, which changes how far the projection extends, Forecast Zone Multiplier, which changes the size of the target area, and the visual toggles, which let you simplify the chart if you only want the most important objects displayed. The current defaults are built around a short forecast horizon, so the script is most naturally suited to intraday use rather than very slow swing-style forecasting.

The best way to use Hybrid Forecast is to treat it as a structured decision-support tool, not as a promise engine. Start with the Balanced profile. Keep the chart clean. Watch how the trigger, projection zone, and stop-loss line relate to each other. If the script is quiet, check the Main Blocker row before loosening settings. If the chart feels too busy, reduce the number of visible setups or disable labels and badges. Bar Replay is the best place to get familiar with how the forecast behaves because it lets you judge the sequence of signal, projected zone, and invalidation the way it would have appeared in real time.

In practical use, this script is best for traders who want a compact overlay for short-term direction, projected destination, and invalidation without stacking multiple separate tools on the chart. It is especially suitable for intraday traders who think in terms of continuation, reversal, target reach, and failed structure rather than just raw entry markers. Since the current default forecast horizon is short, lower intraday timeframes are the most natural fit, while slower charts may require some adjustment to horizon and signal density.

Like any indicator, Hybrid Forecast has limitations. Forecast zones can miss. Strong-looking setups can still fail. Lower timeframes naturally contain more noise. The dashboard percentages only become meaningful after enough samples build up. And because this is an indicator, not a full strategy or execution system, it should be used with your own trade management, risk controls, and judgment.

## Source Code

````pine
//@version=6
indicator("Hybrid Forecast", overlay=true, max_boxes_count=64, max_lines_count=128, max_labels_count=96)

//==================================================================================================
// PUBLIC INPUTS (Trader-Facing)
//==================================================================================================

signalFreq        = input.string("Balanced", "Signal Frequency", options=["Conservative", "Balanced", "Active"], group="Signals")
strictRegime      = input.bool(true,  "Strict Market Filter", tooltip="Trend state: Continuations only. Chop state: Reversals & Reclaims only. Transition: Blocked.", group="Signals")
allowReversals    = input.bool(true,  "Enable Reversal Setups", group="Signals")
allowContinuations= input.bool(true,  "Enable Continuation Setups", group="Signals")
allowReclaims     = input.bool(true,  "Enable Failed Breakout Signals", group="Signals")
setupCooldown     = input.int(5, "Min Bars Between Signals", minval=1, maxval=100, group="Signals")

horizonBars       = input.int(10,   "Forecast Horizon (Bars)", minval=1, group="Forecast")
zoneBaseSize      = input.float(0.9, "Forecast Zone Size", step=0.1, group="Forecast")
maxPending        = input.int(25,   "Max Active Forecasts", minval=1, maxval=100, group="Forecast")
maxPendingPerDir  = input.int(2,    "Max Active Per Direction", minval=1, maxval=10, group="Forecast")

showBaseline      = input.bool(true,  "Show State Baseline", group="Visuals")
showZone          = input.bool(true,  "Show Forecast Zone", group="Visuals")
showProjLine      = input.bool(true,  "Show Projection Arrow", group="Visuals")
showInval         = input.bool(true,  "Show Stop Loss Line", group="Visuals")
showLabels        = input.bool(true,  "Show Target Labels", group="Visuals")
showTriggers      = input.bool(true,  "Show Entry Triggers", group="Visuals")
showBadges        = input.bool(true,  "Show High-Quality Badges", group="Visuals")
showDashboard     = input.bool(true,  "Show Dashboard HUD", group="Visuals")
activeVisuals     = input.int(3,      "Max Visible Setups on Chart", minval=1, maxval=8, group="Visuals")

c_bull            = input.color(#00E676, "Bullish Theme", group="Colors")
c_bear            = input.color(#FF5252, "Bearish Theme", group="Colors")
c_chop            = input.color(#FFB300, "Chop Theme", group="Colors")
c_neut            = input.color(#787B86, "Neutral Theme", group="Colors")
c_dash            = input.color(color.new(#131722, 15), "Dashboard Background", group="Colors")

//==================================================================================================
// INTERNAL / TESTING INPUTS (Developer-Facing)
//==================================================================================================

compMode          = input.string("Hybrid current", "Comparison Mode", options=["Live only", "Hybrid current", "Hybrid relaxed"], group="Internal / Testing - Blending")
adaptiveBlend     = input.bool(true, "Enable Adaptive Blend", group="Internal / Testing - Blending")
baseLiveWeight    = input.float(0.75, "Base Live Weight", step=0.05, minval=0.0, maxval=1.0, group="Internal / Testing - Blending")
memoryWeightCap   = input.float(0.32, "Memory Weight Cap", step=0.05, minval=0.0, maxval=1.0, group="Internal / Testing - Blending")

M                 = input.int(420,  "Memory Size (M)", minval=50, group="Internal / Testing - Engine")
K                 = input.int(7,    "Top Neighbors (K)", minval=1, maxval=12, group="Internal / Testing - Engine")
memoryMinSamples  = input.int(60,   "Memory Min Samples", minval=1, group="Internal / Testing - Engine")
diagAlpha         = input.float(0.02, "Diag EWMA Alpha", step=0.01, minval=0.001, maxval=0.20, group="Internal / Testing - Engine")
recencyLambda     = input.float(0.004, "Recency Penalty", step=0.0005, minval=0.0, group="Internal / Testing - Engine")

gateThreshold      = 0.38
gateMaxStretchATR  = 1.8
gateMinER          = 0.24
contMinR2          = 0.60
thrustMult         = 0.35
rangeExpMult       = 1.10
volExpMult         = 1.20
dispVetoRatio      = 2.5
neighborAgreeMin   = 0.55
setupMinConf       = 0.28
qualityBadgeThresh = 0.80
zoneMin            = 0.01
zoneMax            = 0.50

//==================================================================================================
// TYPES & ARCHITECTURE (Pine v6 UDTs)
//==================================================================================================

type MemoryRecord
    float v1
    float v2
    float v3
    float v4
    float v5
    float term
    float mae
    int dir
    int birth

type PendingSetup
    float entryPrice
    int dir
    int dueIndex
    float f1
    float f2
    float f3
    float f4
    float f5
    float currentMae

type EvalRecord
    float entryPrice
    int dir
    int due
    float zoneTop
    float zoneBot
    float inval
    float conf
    float predMae
    float seenMae
    bool touched
    bool invalid
    int mode
    bool isQuality

type VisualSlot
    box zoneBox
    line projLine
    line invalLine
    label tagLabel
    label badgeLabel
    label invalTagLabel

type StatsState
    int total = 0
    int dirHit = 0
    int zoneTouch = 0
    int qualTotal = 0
    int qualHit = 0

type RejectionStats
    int state = 0
    int gate = 0
    int persist = 0
    int cooldown = 0
    int atr = 0
    int thrust = 0
    int rng = 0
    int vol = 0
    int disp = 0
    int agree = 0
    int conf = 0
    int limit = 0

//==================================================================================================
// STATE VARIABLES
//==================================================================================================

var array<MemoryRecord> memoryArray = array.new<MemoryRecord>()
var array<PendingSetup> pendingSetups = array.new<PendingSetup>()
var array<EvalRecord> evalSetups = array.new<EvalRecord>()
var array<VisualSlot> visuals = array.new<VisualSlot>()
var int visHead = 0

var StatsState stats = StatsState.new()
var RejectionStats rejStats = RejectionStats.new()

var float featStd1 = 0.20
var float featStd2 = 0.20
var float featStd3 = 0.20
var float featStd4 = 0.20
var float featStd5 = 0.20
var float realizedMaeFloor = 0.005

if barstate.isfirst
    for i = 1 to activeVisuals
        visuals.push(VisualSlot.new(na, na, na, na, na, na))

//==================================================================================================
// HELPERS & METHODS
//==================================================================================================

eps = 1e-10
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))
f_safe_log(float a, float b) => math.log(math.max(a, eps) / math.max(b, eps))
f_tanh(float x) =>
    ax = math.abs(x)
    t  = math.exp(-2.0 * ax)
    math.sign(x) * ((1.0 - t) / (1.0 + t))

f_fmt_pct(int n, int d) =>
    d <= 0 ? "—" : str.tostring(100.0 * n / d, "#.0") + "% (" + str.tostring(n) + "/" + str.tostring(d) + ")"

f_dyn_color(int n, int d) =>
    pct = d <= 0 ? 0.0 : (n * 1.0 / d)
    pct >= 0.55 ? color.lime : pct <= 0.45 ? color.red : color.white

method updateStd(float val, float currentStd) =>
    math.max(0.02, currentStd * (1.0 - diagAlpha) + diagAlpha * math.abs(val - 0.5))

method recordDistance(MemoryRecord this, float lv1, float lv2, float lv3, float lv4, float lv5, bool mirrored) =>
    s1 = mirrored ? (1.0 - this.v1) : this.v1
    s4 = mirrored ? (1.0 - this.v4) : this.v4
    s5 = mirrored ? (1.0 - this.v5) : this.v5
    d1 = lv1 - s1, d2 = lv2 - this.v2, d3 = lv3 - this.v3, d4 = lv4 - s4, d5 = lv5 - s5
    sc1 = 1.0 / math.max(featStd1, 0.02)
    sc2 = 1.0 / math.max(featStd2, 0.02)
    sc3 = 1.0 / math.max(featStd3, 0.02)
    sc4 = 1.0 / math.max(featStd4, 0.02)
    sc5 = 1.0 / math.max(featStd5, 0.02)
    (d1*d1*sc1*sc1) + (d2*d2*sc2*sc2) + (d3*d3*sc3*sc3) + (d4*d4*sc4*sc4) + (d5*d5*sc5*sc5)

method getTopBlocker(RejectionStats r) =>
    best = r.state
    txt = "Market in transition"
    if r.gate > best
        best := r.gate
        txt := "Waiting for trend"
    if r.persist > best
        best := r.persist
        txt := "Trend too new"
    if r.cooldown > best
        best := r.cooldown
        txt := "Cooling down"
    if r.atr > best
        best := r.atr
        txt := "Low momentum"
    if r.thrust > best
        best := r.thrust
        txt := "Weak price action"
    if r.rng > best
        best := r.rng
        txt := "Tight range"
    if r.vol > best
        best := r.vol
        txt := "Weak volume"
    if r.disp > best
        best := r.disp
        txt := "Conflicting data"
    if r.agree > best
        best := r.agree
        txt := "Low agreement"
    if r.conf > best
        best := r.conf
        txt := "Low confidence"
    if r.limit > best
        best := r.limit
        txt := "Too many active setups"
    txt

//==================================================================================================
// CORE REGIME & FEATURE EXTRACTION
//==================================================================================================

alma = ta.alma(close, 9, 0.85, 6)
atr  = ta.atr(14)

rawVolMu  = ta.sma(nz(volume, 0), 20)
hasVolume = not na(volume) and volume > 0
volMu     = hasVolume ? rawVolMu : 1.0

nw_baseline = 0.0
num = 0.0
den = 0.0
for i = 0 to 24 - 1
    w = math.exp(-(i * i) / (2.0 * 6.0 * 6.0))
    v = nz(close[i], close)
    num += v * w
    den += w
nw_baseline := den == 0.0 ? close : num / den
nw_slope = nw_baseline - nz(nw_baseline[1], nw_baseline)

var float kalman_state = na
var float kalman_vel = 0.0
if barstate.isfirst or na(kalman_state)
    kalman_state := close
    kalman_vel   := 0.0
else
    pred = kalman_state + kalman_vel
    resid = close - pred
    kalman_state := pred + 0.34 * resid
    kalman_vel   := kalman_vel + 0.09 * resid

fitLine = ta.linreg(close, 20, 0)
priceSd = ta.stdev(close, 20)
residSd = ta.stdev(close - fitLine, 20)
r2Trend = (na(priceSd) or priceSd == 0.0) ? 0.5 : f_clamp(1.0 - residSd / priceSd, 0.0, 1.0)

chg = ta.change(close)
abs_chg = math.abs(chg)
erFast = ta.change(close, 10) / math.max(math.sum(abs_chg, 10), eps)
erSlow = ta.change(close, 20) / math.max(math.sum(abs_chg, 20), eps)
r2Blend = f_clamp(0.60 * r2Trend + 0.40 * math.abs(erSlow), 0.0, 1.0)

atrMu   = ta.sma(atr, 50)
atrRel  = atrMu == 0.0 ? 1.0 : atr / atrMu
stretch = atr == 0.0 ? 0.0 : math.abs(close - nw_baseline) / atr

barRange = high - low
rangeMu  = ta.sma(barRange, 10)
rangeExp = rangeMu == 0.0 ? 1.0 : barRange / rangeMu
volExp   = (hasVolume and volMu > 0) ? volume / volMu : 1.0
thrust   = math.abs(close - nz(close[1], close)) / math.max(atr, eps)

velCap = atr * 0.75
fv1 = 0.5 * (f_tanh(velCap == 0.0 ? 0.0 : kalman_vel / velCap) + 1.0)
atr_sd = ta.stdev(atr, 50)
fv2 = f_clamp((atr_sd == 0.0 ? 0.0 : (atr - atrMu) / (atr_sd * 3.0)) * 0.5 + 0.5, 0.0, 1.0)
fv3 = f_clamp(f_clamp(r2Blend, 0.0, 1.0) - 0.5 * (fv2 - 0.5), 0.0, 1.0)
fv4 = f_clamp((atr == 0.0 ? 0.0 : (close - nw_baseline) / (atr * 2.5)) * 0.5 + 0.5, 0.0, 1.0)
fv5 = f_clamp((atr == 0.0 ? 0.0 : (close - alma) / (atr * 2.5)) * 0.5 + 0.5, 0.0, 1.0)

//==================================================================================================
// DENSITY, FREQUENCY & MARKET STATE CLASSIFIER
//==================================================================================================

isCons = signalFreq == "Conservative"
isActv = signalFreq == "Active"

effGateThresh = isCons ? gateThreshold + 0.10 : isActv ? math.max(0.05, gateThreshold - 0.15) : gateThreshold
effMaxStretch = isCons ? math.max(0.50, gateMaxStretchATR - 0.30) : isActv ? gateMaxStretchATR + 0.80 : gateMaxStretchATR
effMinER      = isCons ? math.min(1.0, gateMinER + 0.10) : isActv ? math.max(0.0, gateMinER - 0.15) : gateMinER
effContR2     = isCons ? math.min(1.0, contMinR2 + 0.10) : isActv ? math.max(0.0, contMinR2 - 0.20) : contMinR2
effCooldown   = isCons ? setupCooldown + 3 : isActv ? math.max(1, setupCooldown - 3) : setupCooldown

effRegPersist = isCons ? 5 : isActv ? 1 : 3
effThrust     = isCons ? thrustMult * 1.20 : isActv ? thrustMult * 0.40 : thrustMult
effRange      = isCons ? rangeExpMult * 1.15 : isActv ? math.max(0.5, rangeExpMult * 0.60) : rangeExpMult
effVolExp     = isCons ? volExpMult * 1.30 : isActv ? 0.80 : volExpMult
effDispVeto   = isCons ? dispVetoRatio * 0.80 : isActv ? dispVetoRatio * 1.60 : dispVetoRatio
effAgreeMin   = isCons ? math.min(1.0, neighborAgreeMin + 0.15) : isActv ? math.max(0.0, neighborAgreeMin - 0.20) : neighborAgreeMin
effMinConf    = isCons ? math.min(1.0, setupMinConf + 0.15) : isActv ? math.max(0.0, setupMinConf - 0.20) : setupMinConf

trendStrength = (0.45 * math.abs(kalman_vel) / math.max(atr, eps)) + (0.20 * math.abs(nw_slope) / math.max(atr, eps)) + (0.35 * r2Blend)
volSuppressed = atrRel < 0.70 or atrRel > 1.90
gateOpen      = trendStrength > effGateThresh and stretch <= effMaxStretch and math.abs(erFast) >= effMinER

dirScore  = (0.65 * kalman_vel / math.max(atr, eps)) + (0.35 * nw_slope / math.max(atr, eps))
regimeDir = dirScore > 0.02 ? 1 : dirScore < -0.02 ? -1 : 0

var int regimeHoldBars = 0
if barstate.isconfirmed
    if regimeDir != 0 and regimeDir == nz(regimeDir[1], 0)
        regimeHoldBars += 1
    else
        regimeHoldBars := regimeDir == 0 ? 0 : 1

regimePersistOk = regimeHoldBars >= effRegPersist
gateReady       = barstate.isconfirmed and gateOpen and regimeDir != 0 and not volSuppressed and regimePersistOk

rawIsTrend = r2Blend >= effContR2 and stretch <= effMaxStretch
rawIsChop  = r2Blend < 0.40 or stretch > effMaxStretch
rawState   = rawIsTrend ? 1 : rawIsChop ? -1 : 0

var int marketState = 0
var int stateHoldBars = 0
if barstate.isconfirmed
    if rawState == nz(rawState[1], 0)
        stateHoldBars += 1
    else
        stateHoldBars := 0

    if stateHoldBars >= 2
        marketState := rawState

//==================================================================================================
// MEMORY BUFFER & SCHEDULING
//==================================================================================================

if barstate.isconfirmed and pendingSetups.size() > 0
    for i = pendingSetups.size() - 1 to 0
        PendingSetup p = pendingSetups.get(i)
        adv = p.dir > 0 ? f_safe_log(p.entryPrice, low) : f_safe_log(high, p.entryPrice)
        p.currentMae := math.max(p.currentMae, math.max(0.0, adv))

        if bar_index >= p.dueIndex
            termLog = f_safe_log(close, p.entryPrice)
            memoryArray.push(MemoryRecord.new(p.f1, p.f2, p.f3, p.f4, p.f5, termLog, p.currentMae, p.dir, bar_index))
            if memoryArray.size() > M
                memoryArray.shift()

            realizedMaeFloor := realizedMaeFloor * (1.0 - diagAlpha) + diagAlpha * math.max(p.currentMae, 0.0)
            featStd1 := updateStd(p.f1, featStd1)
            featStd2 := updateStd(p.f2, featStd2)
            featStd3 := updateStd(p.f3, featStd3)
            featStd4 := updateStd(p.f4, featStd4)
            featStd5 := updateStd(p.f5, featStd5)
            pendingSetups.remove(i)

//==================================================================================================
// KNN SEARCH
//==================================================================================================

var array<float> bestD2 = array.new<float>(K, 1e18)
var array<int>   bestIdx = array.new<int>(K, -1)
var array<int>   bestAge = array.new<int>(K, -1)

for j = 0 to K - 1
    bestD2.set(j, 1e18)
    bestIdx.set(j, -1)

worstV = 1e18
worstI = 0

if memoryArray.size() > 0
    for i = 0 to memoryArray.size() - 1
        MemoryRecord mr = memoryArray.get(i)
        if mr.dir == regimeDir
            d2 = mr.recordDistance(fv1, fv2, fv3, fv4, fv5, false)
            age = bar_index - mr.birth
            if d2 < worstV or (d2 == worstV and age > bestAge.get(worstI))
                bestD2.set(worstI, d2)
                bestIdx.set(worstI, i)
                bestAge.set(worstI, age)
                worstV := bestD2.get(0)
                worstI := 0
                for z = 1 to K - 1
                    if bestD2.get(z) > worstV
                        worstV := bestD2.get(z)
                        worstI := z

sumW = 0.0
sumWT = 0.0
sumWM = 0.0
sumWT2 = 0.0
sumDist = 0.0
cnt = 0
posCount = 0
negCount = 0

for j = 0 to K - 1
    id = bestIdx.get(j)
    if id != -1
        MemoryRecord mr = memoryArray.get(id)
        d = math.sqrt(bestD2.get(j))
        w = math.exp(-recencyLambda * bestAge.get(j)) / (d + 0.02)
        t = mr.term
        sumW += w
        sumWT += w * t
        sumWM += w * mr.mae
        sumWT2 += w * t * t
        sumDist += d
        cnt += 1
        if t > 0.0
            posCount += 1
        else if t < 0.0
            negCount += 1

meanT = cnt > 0 ? sumWT / sumW : 0.0
meanM = cnt > 0 ? sumWM / sumW : 0.0
tStd = cnt > 1 ? math.sqrt(math.max(0.0, sumWT2 / sumW - meanT * meanT)) : 0.0
avgDist = cnt > 0 ? sumDist / cnt : na
agreement = cnt > 0 ? (meanT > 0 ? posCount : meanT < 0 ? negCount : math.max(posCount, negCount)) / cnt : 0.0

//==================================================================================================
// BLENDING & CONFIDENCE
//==================================================================================================

useMemoryReady = memoryArray.size() >= memoryMinSamples and cnt >= 4
liveLog = math.log(math.max(close, eps)) + (((0.70 * kalman_vel) + (0.30 * nw_slope)) / math.max(close, eps)) * horizonBars
liveZone = math.max(zoneMin, math.min(zoneMax, ((atr / math.max(close, eps)) * math.sqrt(horizonBars)) * 0.85))
memoryLog = math.log(math.max(close, eps)) + meanT

var float stdRef = 0.05
var float distRef = 0.50
stdRef := na(tStd) or tStd <= 0 ? stdRef : stdRef * (1.0 - diagAlpha) + tStd * diagAlpha
distRef := na(avgDist) ? distRef : distRef * (1.0 - diagAlpha) + avgDist * diagAlpha

sConf = f_clamp(cnt / 8.0, 0.0, 1.0)
mConf = f_clamp(memoryArray.size() / math.max(1.0, memoryMinSamples * 3.0), 0.0, 1.0)
dConf = na(tStd) ? 0.0 : (1.0 - f_clamp(tStd / math.max(stdRef, eps), 0.0, 1.0))
aConf = na(avgDist) ? 0.0 : (1.0 - f_clamp(avgDist / math.max(distRef, eps), 0.0, 1.0))
confNow = f_clamp(math.pow(math.max(sConf, eps) * math.max(mConf, eps) * math.max(dConf, eps) * math.max(aConf, eps) * math.max(agreement, eps), 0.2), 0.0, 1.0)

trendConf = f_clamp((trendStrength - effGateThresh * 0.50) / math.max(effGateThresh * 1.50, eps), 0.0, 1.0)
stretchConf = 1.0 - f_clamp(stretch / math.max(effMaxStretch, eps), 0.0, 1.0)
erConf = f_clamp((math.abs(erFast) - effMinER * 0.50) / math.max(1.0 - effMinER * 0.50, eps), 0.0, 1.0)
liveSetupConfNow = f_clamp(0.35 * trendConf + 0.20 * stretchConf + 0.20 * erConf + 0.25 * f_clamp(0.55 * r2Blend + 0.45 * math.abs(erFast), 0.0, 1.0), 0.0, 1.0)

memFill = f_clamp(memoryArray.size() / math.max(1.0, memoryMinSamples * 2.0), 0.0, 1.0)
setupConfBase = compMode == "Live only" ? liveSetupConfNow : (useMemoryReady ? (0.5 * confNow + 0.5 * liveSetupConfNow) : ((1.0 - memFill) * liveSetupConfNow + memFill * confNow))

isUsSessionOpen = syminfo.type == "stock" and timeframe.isintraday and not na(time(timeframe.period, "0930-1600:12345")) and (hour * 60 + minute) >= 570 and (hour * 60 + minute) < 585
setupConfNow = f_clamp(setupConfBase - (isUsSessionOpen ? 0.15 : 0.0), 0.0, 1.0)

effDisp = compMode == "Hybrid relaxed" ? effDispVeto * 1.2 : effDispVeto
effAgr  = compMode == "Hybrid relaxed" ? math.max(0.0, effAgreeMin - 0.12) : effAgreeMin

dispTooHigh = useMemoryReady and math.abs(meanT) > eps and (tStd / math.max(math.abs(meanT), eps)) > effDisp
agreeTooLow = useMemoryReady and agreement < effAgr

useMemoryNow = compMode != "Live only" and useMemoryReady and (not adaptiveBlend or confNow >= 0.50) and not volSuppressed and not dispTooHigh and not agreeTooLow

memWeight = useMemoryNow ? math.min(adaptiveBlend ? (confNow - 0.50) / 0.50 : 1.0 - baseLiveWeight, compMode == "Hybrid relaxed" ? math.min(1.0, memoryWeightCap + 0.12) : memoryWeightCap) : 0.0
memWeight := math.min(memWeight, 0.35)
blendedLog_now = useMemoryNow ? (1.0 - memWeight) * liveLog + memWeight * memoryLog : liveLog
zoneHalf_now = f_clamp((useMemoryNow ? math.max(liveZone, f_clamp(tStd * zoneBaseSize, zoneMin, zoneMax)) : liveZone) * (useMemoryNow ? (agreement >= 0.8 ? 0.85 : agreement <= 0.5 ? 1.15 : 1.0) : 1.0), zoneMin, zoneMax)

float inval_mae = useMemoryNow ? math.max(meanM, realizedMaeFloor * 0.5) : math.max(liveZone * 0.75, math.max(realizedMaeFloor, zoneMin))
invalidation_now = close > 0 ? (regimeDir > 0 ? close * math.exp(-inval_mae) : close * math.exp(inval_mae)) : close

//==================================================================================================
// GLOBAL HISTORY EXTRACTIONS
//==================================================================================================

hhBreak = ta.highest(high, 4)[1]
llBreak = ta.lowest(low, 4)[1]

co_base = ta.crossover(close, nw_baseline)
cu_base = ta.crossunder(close, nw_baseline)
co_ll   = ta.crossover(close, llBreak)
cu_ll   = ta.crossunder(close, llBreak)
co_hh   = ta.crossover(close, hhBreak)
cu_hh   = ta.crossunder(close, hhBreak)

bs_cu_base = ta.barssince(cu_base)
bs_cu_ll   = ta.barssince(cu_ll)
bs_co_base = ta.barssince(co_base)
bs_co_hh   = ta.barssince(co_hh)

bullCloseStr = (close - low) / math.max(high - low, eps) > 0.6
bearCloseStr = (high - close) / math.max(high - low, eps) > 0.6

//==================================================================================================
// TRIGGER ENGINE & SIGNAL FAMILIES
//==================================================================================================

failBreakDownBase = co_base and nz(bs_cu_base, 999) <= 4 and bullCloseStr
failBreakDownLow  = co_ll and nz(bs_cu_ll, 999) <= 4 and bullCloseStr
reclaimL = allowReclaims and (failBreakDownBase or failBreakDownLow)

failBreakUpBase = cu_base and nz(bs_co_base, 999) <= 4 and bearCloseStr
failBreakUpHigh = cu_hh and nz(bs_co_hh, 999) <= 4 and bearCloseStr
reclaimS = allowReclaims and (failBreakUpBase or failBreakUpHigh)

revL  = allowReversals and regimeDir > 0 and nz(regimeDir[1], 0) <= 0 and close > nw_baseline and close > alma
revS  = allowReversals and regimeDir < 0 and nz(regimeDir[1], 0) >= 0 and close < nw_baseline and close < alma
contL = allowContinuations and regimeDir > 0 and nz(regimeDir[1], 0) > 0 and close > hhBreak and close > nw_baseline
contS = allowContinuations and regimeDir < 0 and nz(regimeDir[1], 0) < 0 and close < llBreak and close < nw_baseline

validContL = strictRegime ? (marketState == 1 and contL) : contL
validContS = strictRegime ? (marketState == 1 and contS) : contS

validRevL = strictRegime ? (marketState == -1 and (revL or (reclaimL and regimeDir > 0))) : (revL or (reclaimL and regimeDir > 0))
validRevS = strictRegime ? (marketState == -1 and (revS or (reclaimS and regimeDir < 0))) : (revS or (reclaimS and regimeDir < 0))

setupDir = (validContL or validRevL) ? 1 : (validContS or validRevS) ? -1 : 0
setupMode = (validRevL or validRevS) ? 1 : (validContL or validContS) ? 2 : 0

var int lastSetupBar = na
activeDirCount = 0
if pendingSetups.size() > 0
    for i = 0 to pendingSetups.size() - 1
        if pendingSetups.get(i).dir == setupDir
            activeDirCount += 1

c_state = strictRegime ? (marketState != 0) : true
c_cool  = na(lastSetupBar) or (bar_index - lastSetupBar >= effCooldown)
c_atr   = math.abs(kalman_vel) > atr * 0.08
c_thr   = thrust >= effThrust
c_rng   = rangeExp >= effRange
c_vol   = hasVolume ? volExp >= effVolExp : true
c_conf  = setupConfNow >= (compMode == "Hybrid relaxed" ? math.max(0.0, effMinConf - 0.08) : effMinConf)
c_dir   = setupDir == 0 or activeDirCount < maxPendingPerDir
c_max   = pendingSetups.size() < maxPending

if setupDir != 0 and barstate.isconfirmed
    if not c_state
        rejStats.state += 1
    else if not gateReady
        rejStats.gate += 1
    else if not regimePersistOk
        rejStats.persist += 1
    else if not c_cool
        rejStats.cooldown += 1
    else if not c_atr
        rejStats.atr += 1
    else
        if not c_thr
            rejStats.thrust += 1
        if not c_rng
            rejStats.rng += 1
        if not c_vol
            rejStats.vol += 1
        if dispTooHigh
            rejStats.disp += 1
        if agreeTooLow
            rejStats.agree += 1
        if not c_conf
            rejStats.conf += 1
        if not c_dir or not c_max
            rejStats.limit += 1

newSetup = setupDir != 0 and c_state and gateReady and c_cool and c_atr and c_thr and c_rng and c_vol and not dispTooHigh and not agreeTooLow and c_conf and c_dir and c_max
isQualitySetup = setupConfNow >= qualityBadgeThresh and agreement >= 0.75 and useMemoryNow

if newSetup
    lastSetupBar := bar_index
    pendingSetups.push(PendingSetup.new(close, setupDir, bar_index + horizonBars, fv1, fv2, fv3, fv4, fv5, 0.0))

    topP = math.exp(blendedLog_now + math.max(zoneHalf_now * 0.60, zoneMin * 0.50))
    botP = math.exp(blendedLog_now - math.max(zoneHalf_now * 0.60, zoneMin * 0.50))
    midP = math.exp(blendedLog_now)

    evalSetups.push(EvalRecord.new(close, setupDir, bar_index + horizonBars, topP, botP, invalidation_now, setupConfNow, setupDir > 0 ? f_safe_log(close, invalidation_now) : f_safe_log(invalidation_now, close), 0.0, false, false, setupMode, isQualitySetup))

    VisualSlot vs = visuals.get(visHead)
    visHead := (visHead + 1) % activeVisuals
    theme = setupDir > 0 ? c_bull : c_bear
    zFill = color.new(theme, 90)
    zBord = color.new(theme, 50)
    pCol  = color.new(theme, 30)
    iCol  = color.new(#FF9800, 40)

    if showZone
        if na(vs.zoneBox)
            vs.zoneBox := box.new(bar_index, topP, bar_index + horizonBars, botP, bgcolor=zFill, border_color=zBord, border_width=1)
        else
            box.set_lefttop(vs.zoneBox, bar_index, topP)
            box.set_rightbottom(vs.zoneBox, bar_index + horizonBars, botP)
            box.set_bgcolor(vs.zoneBox, zFill)
            box.set_border_color(vs.zoneBox, zBord)

    if showProjLine
        if na(vs.projLine)
            vs.projLine := line.new(bar_index, close, bar_index + horizonBars, midP, color=pCol, width=2, style=line.style_arrow_right)
        else
            line.set_xy1(vs.projLine, bar_index, close)
            line.set_xy2(vs.projLine, bar_index + horizonBars, midP)
            line.set_color(vs.projLine, pCol)

    if showInval
        if na(vs.invalLine)
            vs.invalLine := line.new(bar_index, invalidation_now, bar_index + horizonBars, invalidation_now, color=iCol, width=1, style=line.style_dashed)
            vs.invalTagLabel := label.new(bar_index + horizonBars, invalidation_now, "SL", style=label.style_label_left, textcolor=iCol, color=color.new(color.black, 100), size=size.tiny)
        else
            line.set_xy1(vs.invalLine, bar_index, invalidation_now)
            line.set_xy2(vs.invalLine, bar_index + horizonBars, invalidation_now)
            label.set_xy(vs.invalTagLabel, bar_index + horizonBars, invalidation_now)

    if showLabels
        txt = str.tostring(midP, format.mintick)
        if na(vs.tagLabel)
            vs.tagLabel := label.new(bar_index + horizonBars, midP, txt, style=label.style_label_left, textcolor=color.white, color=color.new(theme, 40), size=size.small)
        else
            label.set_xy(vs.tagLabel, bar_index + horizonBars, midP)
            label.set_text(vs.tagLabel, txt)
            label.set_color(vs.tagLabel, color.new(theme, 40))

    if showBadges and isQualitySetup
        if na(vs.badgeLabel)
            vs.badgeLabel := label.new(bar_index, close, "⭐", style=label.style_label_up, textcolor=color.white, color=color.new(#FFD700, 20), size=size.tiny)
        else
            label.set_xy(vs.badgeLabel, bar_index, close)

//==================================================================================================
// CHART OUTPUTS
//==================================================================================================

baseColor = marketState == 1 ? (regimeDir > 0 ? c_bull : c_bear) : marketState == -1 ? c_chop : c_neut
plot(showBaseline ? nw_baseline : na, title="State Baseline", color=baseColor, linewidth=2)

plotshape(showTriggers and newSetup and setupDir > 0, "Bull Signal", shape.triangleup, location.belowbar, c_bull, size=size.small)
plotshape(showTriggers and newSetup and setupDir < 0, "Bear Signal", shape.triangledown, location.abovebar, c_bear, size=size.small)

if newSetup
    alertMsg = "{\"action\":\"ENTRY\", \"direction\":\"" + (setupDir > 0 ? "LONG" : "SHORT") + "\", \"price\":" + str.tostring(close) + "}"
    alert(alertMsg, alert.freq_once_per_bar)

//==================================================================================================
// EVAL UPDATE & DASHBOARD
//==================================================================================================

if barstate.isconfirmed and evalSetups.size() > 0
    for i = evalSetups.size() - 1 to 0
        EvalRecord ev = evalSetups.get(i)

        if not ev.touched and ((high >= ev.zoneBot and low <= ev.zoneTop) or (ev.dir > 0 ? high >= ev.zoneBot : low <= ev.zoneTop))
            ev.touched := true

        if not ev.invalid and (ev.dir > 0 ? low <= ev.inval : high >= ev.inval)
            ev.invalid := true

        if bar_index >= ev.due
            hit = ev.dir > 0 ? close > ev.entryPrice : close < ev.entryPrice
            stats.total += 1
            if hit
                stats.dirHit += 1
            if ev.touched
                stats.zoneTouch += 1
            if ev.isQuality
                stats.qualTotal += 1
                if hit
                    stats.qualHit += 1
            evalSetups.remove(i)

var table dash = table.new(position.top_right, 2, 6, bgcolor=c_dash, border_width=1, border_color=color.new(c_neut, 85))

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "FORECAST HUD", text_color=color.white, text_halign=text.align_left, bgcolor=color.new(color.black, 40))
    table.cell(dash, 1, 0, "Samples: " + str.tostring(stats.total), text_color=c_neut, text_halign=text.align_right, bgcolor=color.new(color.black, 40))

    table.cell(dash, 0, 1, "Right Direction", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 1, f_fmt_pct(stats.dirHit, stats.total), text_color=f_dyn_color(stats.dirHit, stats.total), text_halign=text.align_right)

    table.cell(dash, 0, 2, "Reached Target", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 2, f_fmt_pct(stats.zoneTouch, stats.total), text_color=f_dyn_color(stats.zoneTouch, stats.total), text_halign=text.align_right)

    table.cell(dash, 0, 3, "Strong Setups", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 3, f_fmt_pct(stats.qualHit, stats.qualTotal), text_color=f_dyn_color(stats.qualHit, stats.qualTotal), text_halign=text.align_right)

    table.cell(dash, 0, 4, "Main Blocker", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 4, rejStats.getTopBlocker(), text_color=color.orange, text_halign=text.align_right)

    table.cell(dash, 0, 5, "Profile", text_color=c_neut, text_halign=text.align_left)
    table.cell(dash, 1, 5, signalFreq, text_color=color.white, text_halign=text.align_right)
````
