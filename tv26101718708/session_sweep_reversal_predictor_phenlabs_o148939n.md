# Session Sweep Reversal Predictor - PhenLabs

- url: https://www.tradingview.com/script/O148939n-Session-Sweep-Reversal-Predictor-PhenLabs/
- type: indicator
- pine_id: PUB;bc3c3ac2662748d4a25bbd3184dce89f
- version: 2.0

## Description

[b]🚀 #67 Session Sweep Reversal Predictor - PhenLabs[/b]

https://www.tradingview.com/x/fpkRgi3p/

[b]📌 Overview[/b]
Session Sweep Reversal Predictor helps traders evaluate whether a confirmed session liquidity sweep is more likely to reverse or continue. It tracks Asian, London, and New York session ranges, detects qualified sweeps of prior session highs or lows, then uses a rolling Bayesian model to estimate reversal and continuation probability from previous sweep outcomes.

Instead of showing every wick through a level, SSRP filters for displacement using candle size versus ATR and body-to-range quality. The goal is to highlight cleaner sweep events where price actually shows intent after taking session liquidity.

[b]📊 Core Idea[/b]
Markets often build liquidity around session highs and lows. When a later session sweeps a prior session range, the key question is not just “was liquidity taken?” but “did this sweep behave like prior sweeps that reversed, or like prior sweeps that continued?”

SSRP answers that question with a rolling event model. Each qualified sweep is classified by candle structure, displacement, and close location, then compared against historical outcomes inside the selected lookback window.

[b]🚀 Key Features[/b]
✅ Tracks Asian, London, and New York session ranges
✅ Detects wick sweeps with rejection closes
✅ Optional failed-close sweep detection
✅ Session-aware sweep logic: London can sweep Asian, New York can sweep London or Asian
✅ Displacement filters using ATR expansion and body/range quality
✅ Rolling Naive Bayes probability model
✅ Reversal and continuation probability labels
✅ Session range boxes, session background tint, swept-level lines, and dashboard table
✅ Alerts for high reversal-probability and high continuation-probability sweeps

[b]🔧 Settings[/b]
[b]Session Timezone[/b]
Default: America/New_York
Options: America/New_York, Europe/London, Asia/Tokyo, UTC, exchange
Description: Timezone used for hour-based session classification.

[b]Asian / London / New York Session[/b]
Default: Asian 18:00–03:00, London 03:00–07:59, New York 08:00–16:00
Description: Reference session windows for the model’s intended session structure. The script evaluates sessions by hour in the selected timezone.

[b]Detect Wick Sweeps[/b]
Default: On
Description: Detects sweeps where price straddles a locked session level and closes back through it.

[b]Detect Failed-Close Sweeps[/b]
Default: Off
Description: Detects sweeps where one bar closes beyond the level and the next bar reclaims it.

[b]London may sweep Asian range[/b]
Default: On
Description: Allows London-session sweeps of the completed Asian range.

[b]New York may sweep Asian range[/b]
Default: On
Description: Allows New York-session sweeps of the completed Asian range.

[b]New York may sweep London range[/b]
Default: On
Description: Allows New York-session sweeps of the completed London range. New York gives London levels priority before falling back to Asian levels.

[b]ATR Length[/b]
Default: 14
Description: ATR period used for displacement qualification and outcome measurement.

[b]Min Candle Size × ATR[/b]
Default: 1.5
Description: Minimum candle range relative to ATR required for a sweep to qualify.

[b]Min Body/Range Ratio[/b]
Default: 0.5
Description: Minimum body quality required to reduce weak wick-only signals.

[b]Rolling Lookback[/b]
Default: 100 sweep events
Description: Number of prior sweep events retained in the probability model.

[b]Laplace Smoothing α[/b]
Default: 4.3
Description: Smoothing factor used by the Bayesian model so early samples do not become overconfident.

[b]Outcome Forward Bars[/b]
Default: 10
Description: Number of bars after a sweep used to classify whether the event reversed or continued.

[b]Reversal Threshold %[/b]
Default: 60
Description: Probability level required to trigger high-reversal visual emphasis and alerts.

[b]Continuation Threshold %[/b]
Default: 60
Description: Probability level required to trigger high-continuation visual emphasis and alerts.

[b]🔥 How It Works[/b]
1. Build session ranges
   • Asian, London, and New York highs/lows are tracked independently.
   • When a session ends, its range is locked for later sweep detection.
   • New Asian session starts reset prior London and New York levels for the new day.

2. Detect qualified sweeps
   • London can sweep the completed Asian range.
   • New York can sweep the completed London range first, then Asian range.
   • A high sweep requires price to trade above the level and close back below it.
   • A low sweep requires price to trade below the level and close back above it.

3. Filter for displacement
   • Candle range must be large enough versus ATR.
   • Candle body must represent enough of the full candle range.
   • This helps reduce weak, noisy liquidity taps.

4. Score the sweep
   • The model bins body quality, candle size, and close location.
   • It estimates reversal versus continuation odds using a rolling Naive Bayes model.
   • Laplace smoothing keeps the model from becoming too extreme on small samples.

5. Label the outcome
   • After the selected forward-bar window, the script checks whether price moved at least one event ATR back through the swept level.
   • If it did, the event is labeled as a reversal.
   • If it did not, the event is labeled as continuation.

[b]🎨 Visual Guide[/b]
• Blue box: Asian session range
• Orange box: London session range
• Background tint: active session
• Yellow dashed line: swept level
• Green label: reversal probability above threshold
• Red label: continuation probability above threshold
• Gray label: no high-confidence edge
• Dashboard: most recent sweep events, session, source range, direction, probabilities, and outcome status

[b]📖 How to Interpret Signals[/b]
[b]High Sweep[/b]
A prior session high was taken. A high reversal probability suggests the model favors downside reaction from the sweep. A high continuation probability suggests the model favors upside continuation after the liquidity take.

[b]Low Sweep[/b]
A prior session low was taken. A high reversal probability suggests the model favors upside reaction from the sweep. A high continuation probability suggests the model favors downside continuation after the liquidity take.

[b]REV %[/b]
Estimated probability that the sweep reverses by at least one event ATR within the forward-bar window.

[b]CONT %[/b]
Estimated probability that the sweep does not meet the reversal condition within the forward-bar window.

[b]✅ Best Used For[/b]
SSRP is designed for intraday traders who watch session liquidity, especially London and New York open behavior. It is most useful on liquid markets with clean session structure, such as major FX pairs, index futures, crypto majors, and high-volume equities.

[quote][b]⚠️ Important Notes[/b]
This is a statistical context tool, not a guaranteed prediction engine. The Bayesian probabilities are based only on the script’s rolling sample of prior qualified sweep events. Early chart history, low-liquidity symbols, unusual sessions, and small lookback samples can make the probabilities less stable.[/quote]

## Source Code

````pine
//@version=6
indicator("Session Sweep Reversal Predictor - PhenLabs", "SSRP - Phen", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 100)

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════
grpSess = "Sessions (evaluated in selected timezone)"
sessTZ = input.string("America/New_York", "Session Timezone",
     options = ["America/New_York","Europe/London","Asia/Tokyo","UTC","exchange"], group = grpSess)

asianSess  = input.session("1800-0300", "Asian Session (ET, reference only)", group = grpSess)
londonSess = input.session("0300-0759", "London Session (ET, reference only)", group = grpSess)
nySess     = input.session("0800-1600", "New York Session (ET, reference only)", group = grpSess)

grpSweep = "Sweep Detection"
useWickSweep   = input.bool(true,  "Detect Wick Sweeps (straddle + rejection close)", group = grpSweep)
useFailedClose = input.bool(false, "Detect Failed-Close Sweeps (close beyond + next-bar reclaim)", group = grpSweep)
sweepAsianInLDN = input.bool(true, "London may sweep Asian range",      group = grpSweep)
sweepAsianInNY  = input.bool(true, "New York may sweep Asian range",    group = grpSweep)
sweepLondonInNY = input.bool(true, "New York may sweep London range",   group = grpSweep)

grpDisp = "Displacement Filters"
atrLen        = input.int(14,  "ATR Length",                 minval = 1,  group = grpDisp)
atrMult       = input.float(1.5, "Min Candle Size (× ATR)",  minval = 0.1, step = 0.1, group = grpDisp)
bodyRatioMin  = input.float(0.5, "Min Body/Range Ratio",     minval = 0.0, maxval = 1.0, step = 0.05, group = grpDisp)

grpBayes = "Bayesian Model"
lookback      = input.int(100, "Rolling Lookback (sweep events)", minval = 20, group = grpBayes)
laplaceAlpha  = input.float(4.3, "Laplace Smoothing α", minval = 0.01, step = 0.1, group = grpBayes)
forwardBars   = input.int(10, "Outcome Forward Bars",   minval = 1, group = grpBayes)
revThreshold  = input.float(60, "Reversal Threshold %",     minval = 50, maxval = 95, group = grpBayes)
contThreshold = input.float(60, "Continuation Threshold %", minval = 50, maxval = 95, group = grpBayes)

grpVis = "Visualization"
showAsianBox     = input.bool(true,  "Show Asian Range",            group = grpVis)
showLondonBox    = input.bool(true,  "Show London Range",           group = grpVis)
showSweepLine    = input.bool(true,  "Draw Swept Level Line",       group = grpVis)
showSessionBG    = input.bool(true,  "Tint Background by Session",  group = grpVis)
showSessionBadge = input.bool(true,  "Show Session Status Badge",   group = grpVis)
showDash         = input.bool(true,  "Show Dashboard",              group = grpVis)
dashLoc          = input.string("Top Right", "Dashboard Location",
     options = ["Top Right","Top Left","Bottom Right","Bottom Left"], group = grpVis)

grpColor = "Session Colors"
asianColor   = input.color(color.new(color.blue,   92), "Asian Tint",   group = grpColor)
londonColor  = input.color(color.new(color.orange, 92), "London Tint",  group = grpColor)
nyColor      = input.color(color.new(color.purple, 92), "New York Tint",group = grpColor)

// ═══════════════════════════════════════════════════════════════
// SESSION DETECTION (hour-of-day, midnight-wrap safe)
// ═══════════════════════════════════════════════════════════════
hourTZ = hour(time, sessTZ)
minTZ  = minute(time, sessTZ)
mins   = hourTZ * 60 + minTZ

rawAsian  = (mins >= 18*60) or (mins < 3*60)
rawLondon = (mins >= 3*60)  and (mins < 8*60)
rawNY     = (mins >= 8*60)  and (mins < 16*60)

inNY     = rawNY
inLondon = rawLondon and not rawNY
inAsian  = rawAsian  and not rawLondon and not rawNY

sessionName()  => inNY ? "New York" : inLondon ? "London" : inAsian ? "Asian" : "Off-Session"
sessionShort() => inNY ? "NY" : inLondon ? "LDN" : inAsian ? "ASN" : "—"
sessionColor() => inNY ? nyColor : inLondon ? londonColor : inAsian ? asianColor : color.new(color.gray, 100)

bgcolor(showSessionBG ? sessionColor() : na, title = "Session BG")

// ═══════════════════════════════════════════════════════════════
// PER-SESSION RANGE TRACKING (FIXED: independent state per session)
// ═══════════════════════════════════════════════════════════════
// Live (in-progress) range high/low for each session
var float aH = na, var float aL = na
var float lH = na, var float lL = na
var float nH = na, var float nL = na

// Locked (completed) range high/low for each session
var float lockAH = na, var float lockAL = na
var float lockLH = na, var float lockLL = na
var float lockNH = na, var float lockNL = na

// Swept flags per locked level
var bool aHSwept = false, var bool aLSwept = false
var bool lHSwept = false, var bool lLSwept = false
var bool nHSwept = false, var bool nLSwept = false

// Bar counters → start/end edges
var int aBars = 0, var int lBars = 0, var int nBars = 0
aBars := inAsian  ? nz(aBars[1]) + 1 : 0
lBars := inLondon ? nz(lBars[1]) + 1 : 0
nBars := inNY     ? nz(nBars[1]) + 1 : 0

aStart = aBars == 1
lStart = lBars == 1
nStart = nBars == 1

aEnd = (not inAsian)  and nz(aBars[1], 0) > 0
lEnd = (not inLondon) and nz(lBars[1], 0) > 0
nEnd = (not inNY)     and nz(nBars[1], 0) > 0

// Build live ranges
if aStart
    aH := high
    aL := low
else if inAsian
    aH := math.max(nz(aH, high), high)
    aL := math.min(nz(aL, low),  low)

if lStart
    lH := high
    lL := low
else if inLondon
    lH := math.max(nz(lH, high), high)
    lL := math.min(nz(lL, low),  low)

if nStart
    nH := high
    nL := low
else if inNY
    nH := math.max(nz(nH, high), high)
    nL := math.min(nz(nL, low),  low)

// Lock ranges + reset their swept flags ONLY at end-of-session
if aEnd
    lockAH := aH
    lockAL := aL
    aHSwept := false
    aLSwept := false

if lEnd
    lockLH := lH
    lockLL := lL
    lHSwept := false
    lLSwept := false

if nEnd
    lockNH := nH
    lockNL := nL
    nHSwept := false
    nLSwept := false

// New Asian session start invalidates prior London + NY locked levels (new day)
if aStart
    lockLH := na
    lockLL := na
    lockNH := na
    lockNL := na
    lHSwept := false
    lLSwept := false
    nHSwept := false
    nLSwept := false

// ═══════════════════════════════════════════════════════════════
// FEATURES
// ═══════════════════════════════════════════════════════════════
atr = ta.atr(atrLen)
candleRange = high - low
candleBody  = math.abs(close - open)
bodyRatio   = candleRange > 0 ? candleBody / candleRange : 0.0
sizeVsAtr   = (not na(atr) and atr > 0) ? candleRange / atr : 0.0
closePos    = candleRange > 0 ? (close - low) / candleRange : 0.5

// ═══════════════════════════════════════════════════════════════
// SWEEP PRIMITIVES (FIXED: require straddle, not just breach)
// ═══════════════════════════════════════════════════════════════
wickHigh(float lvl) =>
    not na(lvl) and high > lvl and low <= lvl and close < lvl

wickLow(float lvl) =>
    not na(lvl) and low < lvl and high >= lvl and close > lvl

failHigh(float lvlPrev) =>
    not na(lvlPrev) and close[1] > lvlPrev and close < lvlPrev

failLow(float lvlPrev) =>
    not na(lvlPrev) and close[1] < lvlPrev and close > lvlPrev

// ═══════════════════════════════════════════════════════════════
// CANDIDATE SWEEPS BY SESSION
// Determine which level (if any) was swept this bar, with priority:
//   NY session: London range > Asian range
//   London session: Asian range
//   Asian session: no sweep (range still being built)
// ═══════════════════════════════════════════════════════════════
var string  swSrc = na     // "ASN" / "LDN" / "NY" - origin of swept level
var int     swDir = 0      // 1 high, -1 low
var float   swLvl = na

swSrc := na
swDir := 0
swLvl := na

// Helper booleans
wAH = useWickSweep and wickHigh(lockAH)
wAL = useWickSweep and wickLow(lockAL)
wLH = useWickSweep and wickHigh(lockLH)
wLL = useWickSweep and wickLow(lockLL)

fAH = useFailedClose and failHigh(lockAH[1])
fAL = useFailedClose and failLow(lockAL[1])
fLH = useFailedClose and failHigh(lockLH[1])
fLL = useFailedClose and failLow(lockLL[1])

// London session — can sweep Asian
if inLondon and sweepAsianInLDN
    if not aHSwept and (wAH or fAH)
        swSrc := "ASN"
        swDir := 1
        swLvl := lockAH
    else if not aLSwept and (wAL or fAL)
        swSrc := "ASN"
        swDir := -1
        swLvl := lockAL

// NY session — prefer London range, fall back to Asian
if inNY
    if sweepLondonInNY and not lHSwept and (wLH or fLH)
        swSrc := "LDN"
        swDir := 1
        swLvl := lockLH
    else if sweepLondonInNY and not lLSwept and (wLL or fLL)
        swSrc := "LDN"
        swDir := -1
        swLvl := lockLL
    else if sweepAsianInNY and not aHSwept and (wAH or fAH)
        swSrc := "ASN"
        swDir := 1
        swLvl := lockAH
    else if sweepAsianInNY and not aLSwept and (wAL or fAL)
        swSrc := "ASN"
        swDir := -1
        swLvl := lockAL

sweepCandidate = swDir != 0
qualifies      = sizeVsAtr >= atrMult and bodyRatio >= bodyRatioMin

// ═══════════════════════════════════════════════════════════════
// FEATURE BIN DISCRETIZATION
// ═══════════════════════════════════════════════════════════════
binBody(float r) =>
    float rr = nz(r, 0.0)
    rr < 0.4 ? 0 : rr < 0.7 ? 1 : 2

binSize(float s) =>
    float ss = nz(s, 0.0)
    ss < 1.0 ? 0 : ss < 2.0 ? 1 : 2

binClose(float cp, int dir) =>
    float c   = nz(cp, 0.5)
    float adj = dir == 1 ? 1.0 - c : c
    adj < 0.33 ? 0 : adj < 0.66 ? 1 : 2

clampBin(int b) => b < 0 ? 0 : b > 2 ? 2 : b

// ═══════════════════════════════════════════════════════════════
// EVENT STORAGE
// ═══════════════════════════════════════════════════════════════
var array<int>    evBody    = array.new<int>()
var array<int>    evSize    = array.new<int>()
var array<int>    evClose   = array.new<int>()
var array<int>    evOut     = array.new<int>()
var array<int>    evBar     = array.new<int>()
var array<int>    evDir     = array.new<int>()
var array<float>  evLevel   = array.new<float>()
var array<float>  evATR     = array.new<float>()
var array<float>  evRevP    = array.new<float>()
var array<float>  evContP   = array.new<float>()
var array<string> evSession = array.new<string>()   // active session at sweep
var array<string> evSource  = array.new<string>()   // origin of swept level

// ═══════════════════════════════════════════════════════════════
// NAIVE BAYES
// ═══════════════════════════════════════════════════════════════
naiveBayes(int bBinIn, int sBinIn, int cBinIn) =>
    int bBin = clampBin(bBinIn)
    int sBin = clampBin(sBinIn)
    int cBin = clampBin(cBinIn)

    array<int> bRev  = array.new<int>(3, 0)
    array<int> bCont = array.new<int>(3, 0)
    array<int> sRev  = array.new<int>(3, 0)
    array<int> sCont = array.new<int>(3, 0)
    array<int> cRev  = array.new<int>(3, 0)
    array<int> cCont = array.new<int>(3, 0)

    int countRev  = 0
    int countCont = 0
    int n = array.size(evOut)

    if n > 0
        for i = 0 to n - 1
            int o = array.get(evOut, i)
            if o != -1
                int bb = clampBin(array.get(evBody,  i))
                int ss = clampBin(array.get(evSize,  i))
                int cc = clampBin(array.get(evClose, i))
                if o == 1
                    countRev += 1
                    array.set(bRev, bb, array.get(bRev, bb) + 1)
                    array.set(sRev, ss, array.get(sRev, ss) + 1)
                    array.set(cRev, cc, array.get(cRev, cc) + 1)
                else
                    countCont += 1
                    array.set(bCont, bb, array.get(bCont, bb) + 1)
                    array.set(sCont, ss, array.get(sCont, ss) + 1)
                    array.set(cCont, cc, array.get(cCont, cc) + 1)

    int total = countRev + countCont
    float priorRev  = (countRev  + laplaceAlpha) / (total + 2.0 * laplaceAlpha)
    float priorCont = (countCont + laplaceAlpha) / (total + 2.0 * laplaceAlpha)

    float K = 3.0
    float lb_R = (array.get(bRev,  bBin) + laplaceAlpha) / (countRev  + K * laplaceAlpha)
    float ls_R = (array.get(sRev,  sBin) + laplaceAlpha) / (countRev  + K * laplaceAlpha)
    float lc_R = (array.get(cRev,  cBin) + laplaceAlpha) / (countRev  + K * laplaceAlpha)
    float lb_C = (array.get(bCont, bBin) + laplaceAlpha) / (countCont + K * laplaceAlpha)
    float ls_C = (array.get(sCont, sBin) + laplaceAlpha) / (countCont + K * laplaceAlpha)
    float lc_C = (array.get(cCont, cBin) + laplaceAlpha) / (countCont + K * laplaceAlpha)

    float postR = priorRev  * lb_R * ls_R * lc_R
    float postC = priorCont * lb_C * ls_C * lc_C
    float Z = postR + postC
    float pR = Z > 0 ? postR / Z : 0.5
    float pC = Z > 0 ? postC / Z : 0.5
    [pR, pC]

// ═══════════════════════════════════════════════════════════════
// EVENT REGISTRATION
// ═══════════════════════════════════════════════════════════════
sweepDetected = sweepCandidate and qualifies and barstate.isconfirmed and not na(atr)

float pRev  = 0.5
float pCont = 0.5

if sweepDetected
    int bBin = binBody(bodyRatio)
    int sBin = binSize(sizeVsAtr)
    int cBin = binClose(closePos, swDir)
    [pR_, pC_] = naiveBayes(bBin, sBin, cBin)
    pRev  := pR_
    pCont := pC_

    string sessTag = sessionName()
    string sessSh  = sessionShort()

    array.push(evBody,    bBin)
    array.push(evSize,    sBin)
    array.push(evClose,   cBin)
    array.push(evOut,     -1)
    array.push(evBar,     bar_index)
    array.push(evDir,     swDir)
    array.push(evLevel,   swLvl)
    array.push(evATR,     atr)
    array.push(evRevP,    pRev)
    array.push(evContP,   pCont)
    array.push(evSession, sessTag)
    array.push(evSource,  swSrc)

    while array.size(evOut) > lookback
        array.shift(evBody)
        array.shift(evSize)
        array.shift(evClose)
        array.shift(evOut)
        array.shift(evBar)
        array.shift(evDir)
        array.shift(evLevel)
        array.shift(evATR)
        array.shift(evRevP)
        array.shift(evContP)
        array.shift(evSession)
        array.shift(evSource)

    // Mark the appropriate level as swept
    if swSrc == "ASN" and swDir ==  1
        aHSwept := true
    if swSrc == "ASN" and swDir == -1
        aLSwept := true
    if swSrc == "LDN" and swDir ==  1
        lHSwept := true
    if swSrc == "LDN" and swDir == -1
        lLSwept := true

    string sweepStr = swDir == 1 ? "High Sweep" : "Low Sweep"
    color labelCol = pRev * 100 > revThreshold ? color.new(color.green, 0)
                   : pCont * 100 > contThreshold ? color.new(color.red, 0)
                   : color.new(color.gray, 20)
    string txt = "[" + sessSh + "→" + swSrc + "] " + sweepStr +
                 "\nRev: "  + str.tostring(pRev  * 100, "#.0") + "%" +
                 "\nCont: " + str.tostring(pCont * 100, "#.0") + "%"
    label.new(bar_index, swDir == 1 ? high : low, txt,
         style = swDir == 1 ? label.style_label_down : label.style_label_up,
         color = labelCol, textcolor = color.white, size = size.small)

    if showSweepLine and not na(swLvl)
        line.new(bar_index - 1, swLvl, bar_index + forwardBars, swLvl,
             color = color.new(color.yellow, 30), style = line.style_dashed, width = 1)

// ═══════════════════════════════════════════════════════════════
// OUTCOME LABELING (uses per-event ATR, exact elapsed window)
// ═══════════════════════════════════════════════════════════════
if array.size(evOut) > 0
    for i = 0 to array.size(evOut) - 1
        if array.get(evOut, i) == -1
            int b0 = array.get(evBar, i)
            int elapsed = bar_index - b0
            if elapsed == forwardBars
                int dir   = array.get(evDir, i)
                float lvl = array.get(evLevel, i)
                float aE  = array.get(evATR, i)
                float maxMove = 0.0
                for k = 0 to forwardBars - 1
                    int off = k
                    if off >= 0 and off <= 5000
                        float lo_k = low[off]
                        float hi_k = high[off]
                        if not na(lo_k) and not na(hi_k) and not na(lvl)
                            float p = dir == 1 ? lvl - lo_k : hi_k - lvl
                            maxMove := math.max(maxMove, p)
                bool reversed = not na(aE) and aE > 0 and maxMove >= aE
                array.set(evOut, i, reversed ? 1 : 0)

// ═══════════════════════════════════════════════════════════════
// RANGE BOXES
// ═══════════════════════════════════════════════════════════════
var box asianBox = na
if showAsianBox
    if aStart
        asianBox := box.new(bar_index, high, bar_index, low,
             border_color = color.new(color.blue, 50), bgcolor = color.new(color.blue, 90))
    if inAsian and not na(asianBox)
        box.set_right(asianBox, bar_index)
        box.set_top(asianBox, aH)
        box.set_bottom(asianBox, aL)

var box londonBox = na
if showLondonBox
    if lStart
        londonBox := box.new(bar_index, high, bar_index, low,
             border_color = color.new(color.orange, 50), bgcolor = color.new(color.orange, 90))
    if inLondon and not na(londonBox)
        box.set_right(londonBox, bar_index)
        box.set_top(londonBox, lH)
        box.set_bottom(londonBox, lL)

// ═══════════════════════════════════════════════════════════════
// SESSION STATUS BADGE
// ═══════════════════════════════════════════════════════════════
var table sessBadge = na
if showSessionBadge and barstate.islast
    if na(sessBadge)
        sessBadge := table.new(position.top_center, 1, 1, border_width = 1)
    color textCol = inNY ? color.purple : inLondon ? color.orange : inAsian ? color.blue : color.gray
    table.cell(sessBadge, 0, 0,
         "Active Session: " + sessionName() + "  (" + sessTZ + ")",
         bgcolor = color.new(color.black, 70), text_color = textCol, text_size = size.normal)

// ═══════════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════════
var table dash = na
if showDash and barstate.islast
    pos = dashLoc == "Top Right"    ? position.top_right
         : dashLoc == "Top Left"     ? position.top_left
         : dashLoc == "Bottom Right" ? position.bottom_right
         :                             position.bottom_left
    if na(dash)
        dash := table.new(pos, 7, 7, border_width = 1)
    table.clear(dash, 0, 0, 6, 6)
    table.cell(dash, 0, 0, "#",       bgcolor = color.new(color.gray, 70), text_color = color.white)
    table.cell(dash, 1, 0, "Session", bgcolor = color.new(color.gray, 70), text_color = color.white)
    table.cell(dash, 2, 0, "Src",     bgcolor = color.new(color.gray, 70), text_color = color.white)
    table.cell(dash, 3, 0, "Dir",     bgcolor = color.new(color.gray, 70), text_color = color.white)
    table.cell(dash, 4, 0, "Rev %",   bgcolor = color.new(color.gray, 70), text_color = color.white)
    table.cell(dash, 5, 0, "Cont %",  bgcolor = color.new(color.gray, 70), text_color = color.white)
    table.cell(dash, 6, 0, "Outcome", bgcolor = color.new(color.gray, 70), text_color = color.white)

    int n = array.size(evOut)
    int rows = math.min(5, n)
    if rows > 0
        for r = 0 to rows - 1
            int idx = n - 1 - r
            int dirRow   = array.get(evDir, idx)
            float pRRow  = array.get(evRevP, idx)
            float pCRow  = array.get(evContP, idx)
            int oRow     = array.get(evOut, idx)
            string sess  = array.get(evSession, idx)
            string src   = array.get(evSource, idx)
            string outStr = oRow == 1 ? "REV ✓" : oRow == 0 ? "CONT" : "..."
            color outCol  = oRow == 1 ? color.new(color.green, 60)
                          : oRow == 0 ? color.new(color.red, 60)
                          : color.new(color.gray, 70)
            color sessCol = sess == "New York" ? color.new(color.purple, 70)
                          : sess == "London"   ? color.new(color.orange, 70)
                          : sess == "Asian"    ? color.new(color.blue, 70)
                          :                      color.new(color.gray, 70)
            table.cell(dash, 0, r + 1, str.tostring(idx + 1))
            table.cell(dash, 1, r + 1, sess, bgcolor = sessCol, text_color = color.white)
            table.cell(dash, 2, r + 1, src)
            table.cell(dash, 3, r + 1, dirRow == 1 ? "High" : "Low",
                 text_color = dirRow == 1 ? color.red : color.green)
            table.cell(dash, 4, r + 1, str.tostring(pRRow * 100, "#.0"))
            table.cell(dash, 5, r + 1, str.tostring(pCRow * 100, "#.0"))
            table.cell(dash, 6, r + 1, outStr, bgcolor = outCol, text_color = color.white)

// ═══════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(sweepDetected and pRev  * 100 > revThreshold,
     "High Reversal Probability",     "Sweep with reversal probability above threshold")
alertcondition(sweepDetected and pCont * 100 > contThreshold,
     "High Continuation Probability", "Sweep with continuation probability above threshold")
````
