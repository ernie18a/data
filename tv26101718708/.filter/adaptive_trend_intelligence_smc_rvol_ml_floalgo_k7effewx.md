# Adaptive Trend Intelligence + SMC + RVOL + ML - FloAlgo

- url: https://www.tradingview.com/script/K7EfFEWx-Adaptive-Trend-Intelligence-SMC-RVOL-ML-FloAlgo/
- type: indicator
- pine_id: PUB;2aff6cab17ee4ae3b4eb9b18aa521d74
- version: 1.0

## Description

This indicator combines an Adaptive SuperTrend with Smart Money Concepts (SMC) market structure, Relative Volume (RVOL) filtering, and an online Machine Learning model to produce high-confidence trend-following signals.

[b]How It Works[/b]

Adaptive SuperTrend — A SuperTrend band whose ATR multiplier scales automatically based on the short/long volatility ratio. In quiet markets the band tightens; in expansions it widens. An optional noise filter requires price to hold on the new side for N bars before a flip is accepted, eliminating whipsaws.

SMC Market Structure Engine — Uses a Stochastic Momentum Oscillator to detect overbought/oversold pivots and build an alternating High/Low swing chain. From those swings it tracks Dow-Theory labels (HH, HL, LH, LL), draws a zigzag, plots S/R zones, and detects BOS (Break of Structure) when price closes beyond the previous major swing confirming trend continuation, and CHoCH (Change of Character) when price closes beyond the prior opposing major swing signaling a trend flip. Both events require an established trend direction and fire only against the correct structural level, preventing false signals on internal corrections.

RVOL Filter — Computes directional buy/sell volume from candle structure and ranks it against a rolling percentile. Signals are suppressed unless the directional volume percentile clears a configurable threshold, keeping entries to high-participation moves only.

Online ML Model — A logistic regression model with L2 regularisation trained incrementally on every confirmed SuperTrend flip. It learns 17 features per signal including candle shape, volume, momentum, ATR slope, RSI, Bollinger position, RVOL, and SMC bias, then resolves each trade when the next flip occurs. Probability is displayed in the info table and can gate signals via a minimum confidence threshold.

[b]Visual Elements[/b]

[list]
[*]SuperTrend line with bull/bear fill
[*]▲ / ▼ signal arrows and labels
[*]BOS / CHoCH labels at structure breaks
[*]HH / HL / LH / LL Dow labels at each pivot
[*]Zigzag lines connecting momentum pivots
[*]S/R zone boxes, colour-coded and fading on break
[*]Info table showing Signal, Trend, ML Confidence, RVOL, Momentum, Volatility, Quality, MS Bias, and last Structure event
[/list]

[b]Key Settings[/b]

[list]
[*]ATR Length — lookback for ATR calculation
[*]ATR Multiplier — base band width
[*]Adaptive Multiplier — auto-scales multiplier with volatility ratio
[*]Noise Filter (bars) — bars price must hold before flip is confirmed
[*]RVOL Lookback — rolling window for volume percentile ranking
[*]RVOL Min Percentile % — minimum directional volume percentile to allow a signal
[*]Min ML Probability % — minimum ML model confidence to allow a signal
[*]Stochastic Length — sensitivity of the momentum pivot oscillator
[*]Overbought / Oversold — stochastic zone thresholds for pivot detection
[*]Filter Signals by MS — gate signals to align with SMC trend direction
[*]Max S/R Zones per Side — maximum supply/demand boxes kept on chart
[/list]

## Source Code

````pine
// © FloAlgo
//@version=6
indicator("Adaptive SuperTrend + SMC + RVOL + ML [FloAlgo]", "FLO-AST-ML", overlay=true,
          max_labels_count=200, max_lines_count=100, max_boxes_count=30)

// ══════════════════════════════════════════════════════
// constants
// ══════════════════════════════════════════════════════
featureLookback = 20
trainWindow     = 100
decayFactor     = 0.97
learningRate    = 0.05
epochs          = 15
minSamples      = 15
LAMBDA          = 0.01
CLIP            = 10.0
MAX_HISTORY     = 250

// ══════════════════════════════════════════════════════
// inputs
// ══════════════════════════════════════════════════════
atrLen      = input.int(10,    "ATR Length",            minval=1,             group="SuperTrend")
atrMult     = input.float(3.0, "ATR Multiplier",        minval=0.5, step=0.1, group="SuperTrend")
useAdaptive = input.bool(true,  "Adaptive Multiplier",  group="SuperTrend",
              tooltip="Scales ATR multiplier by short/long vol ratio. Tightens in quiet markets, widens in expansions.")
noiseLen    = input.int(2,     "Noise Filter (bars)",   minval=0, maxval=5,   group="SuperTrend",
              tooltip="Require price to stay on new side for N bars before flip accepted. 0 = off.")

rvolLen     = input.int(20,    "RVOL Lookback",         minval=5,             group="Volume Filter")
rvolThresh  = input.float(55,  "RVOL Min Percentile %", minval=0, maxval=100, step=5, group="Volume Filter",
              tooltip="Signal fires only if directional volume percentile >= this. 0 = always fire.")
filterOn    = input.bool(true,  "Enable RVOL Filter",   group="Volume Filter")

minProb     = input.float(0.0, "Min ML Probability %",  minval=0, maxval=100, step=5, group="ML Filter",
              tooltip="Only show signal if ML model probability >= this. 0 = show all (including before training starts).")

msStochLen  = input.int(14,   "Stochastic Length",      minval=5,  maxval=50, group="Market Structure")
msOB        = input.int(80,   "Overbought Level",        minval=60, maxval=95, group="Market Structure")
msOS        = input.int(20,   "Oversold Level",          minval=5,  maxval=40, group="Market Structure")
showBOS     = input.bool(true,  "Show BOS / CHoCH",      group="Market Structure")
showDow     = input.bool(true,  "Show HH/HL/LH/LL",     group="Market Structure")
showZigzag  = input.bool(true,  "Show Zigzag",           group="Market Structure")
showSR      = input.bool(true,  "Show S/R Zones",        group="Market Structure")
msFilter    = input.bool(true,  "Filter Signals by MS Bias", group="Market Structure",
              tooltip="Only allow bull signals in bullish MS bias and bear signals in bearish MS bias.")
srMaxZones  = input.int(5,    "Max S/R Zones per Side", minval=2,  maxval=15, group="Market Structure")
srZoneAtr   = input.float(0.5, "Zone Height (× ATR)",   minval=0.1, maxval=2.0, step=0.1, group="Market Structure")

showTable   = input.bool(true,  "Show Info Table",       group="Visuals")
showBar     = input.bool(false, "Color Bars",            group="Visuals")
cBull       = input.color(#00c176, "Bull", inline="col", group="Visuals")
cBear       = input.color(#ff3d3d, "Bear", inline="col", group="Visuals")

alertPrice  = input.bool(true,  "Include Price in Alert",   group="Alerts")
alertRvol   = input.bool(true,  "Include RVOL in Alert",    group="Alerts")
alertProb   = input.bool(true,  "Include ML Prob in Alert", group="Alerts")

// ══════════════════════════════════════════════════════
// types
// ══════════════════════════════════════════════════════
type Signal
    float entryPrice
    int   barIdx
    float bodyRatio
    float upperWick
    float lowerWick
    float rangeRatio
    float volumeRatio
    float momentum
    float deltaVolume
    float trendMom
    float atrSlope
    float volTrend
    float stDistance
    float trendDuration
    float rsiFeat
    float bbPosFeat
    float rvolFeat
    float structBias
    int   result = -1
    float probability = na

// ══════════════════════════════════════════════════════
// helpers
// ══════════════════════════════════════════════════════
sigmoid(float z) =>
    float c = math.max(math.min(z, 15.0), -15.0)
    1.0 / (1.0 + math.exp(-c))

normalizeCentered(float val, float avg) =>
    avg > 0 ? math.max(-1.0, math.min(1.0, (val / avg) - 1.0)) : 0.0

calcDeltaVolume() =>
    float rng = math.max(high - low, syminfo.mintick)
    float bv  = volume * (close - low)  / rng
    float sv  = volume * (high - close) / rng
    [bv, sv]

dotProduct(float[] wt, Signal sig) =>
    (wt.get(0)  * sig.bodyRatio     +
     wt.get(1)  * sig.upperWick     +
     wt.get(2)  * sig.lowerWick     +
     wt.get(3)  * sig.rangeRatio    +
     wt.get(4)  * sig.volumeRatio   +
     wt.get(5)  * sig.momentum      +
     wt.get(6)  * sig.deltaVolume   +
     wt.get(7)  * sig.trendMom      +
     wt.get(8)  * sig.atrSlope      +
     wt.get(9)  * sig.volTrend      +
     wt.get(10) * sig.stDistance    +
     wt.get(11) * sig.trendDuration +
     wt.get(12) * sig.rsiFeat       +
     wt.get(13) * sig.bbPosFeat     +
     wt.get(14) * sig.rvolFeat      +
     wt.get(15) * sig.structBias    +
     wt.get(16))

trainModel(float[] wt, Signal[] data, int window, float decay, float lr, int ep) =>
    int total = data.size()
    if total >= 2
        int[] resolved = array.new<int>()
        for i = 0 to total - 1
            if data.get(i).result != -1
                resolved.push(i)
        int numResolved = resolved.size()
        if numResolved >= 2
            float[] sw = array.new<float>(numResolved)
            float peak = 0.0
            for k = 0 to numResolved - 1
                float w = math.pow(decay, float(total - 1 - resolved.get(k)))
                sw.set(k, w)
                peak := math.max(peak, w)
            if peak > 0
                for k = 0 to numResolved - 1
                    sw.set(k, sw.get(k) / peak)

            float tw0  = wt.get(0)
            float tw1  = wt.get(1)
            float tw2  = wt.get(2)
            float tw3  = wt.get(3)
            float tw4  = wt.get(4)
            float tw5  = wt.get(5)
            float tw6  = wt.get(6)
            float tw7  = wt.get(7)
            float tw8  = wt.get(8)
            float tw9  = wt.get(9)
            float tw10 = wt.get(10)
            float tw11 = wt.get(11)
            float tw12 = wt.get(12)
            float tw13 = wt.get(13)
            float tw14 = wt.get(14)
            float tw15 = wt.get(15)
            float twB  = wt.get(16)

            for e = 0 to ep - 1
                float g0  = 0.0
                float g1  = 0.0
                float g2  = 0.0
                float g3  = 0.0
                float g4  = 0.0
                float g5  = 0.0
                float g6  = 0.0
                float g7  = 0.0
                float g8  = 0.0
                float g9  = 0.0
                float g10 = 0.0
                float g11 = 0.0
                float g12 = 0.0
                float g13 = 0.0
                float g14 = 0.0
                float g15 = 0.0
                float gB  = 0.0
                float wS  = 0.0
                int startAt = math.max(0, numResolved - window)
                for k = startAt to numResolved - 1
                    Signal s = data.get(resolved.get(k))
                    float  w = sw.get(k)
                    float pred = sigmoid(
                         tw0*s.bodyRatio+tw1*s.upperWick+tw2*s.lowerWick+tw3*s.rangeRatio+
                         tw4*s.volumeRatio+tw5*s.momentum+tw6*s.deltaVolume+tw7*s.trendMom+
                         tw8*s.atrSlope+tw9*s.volTrend+tw10*s.stDistance+tw11*s.trendDuration+
                         tw12*s.rsiFeat+tw13*s.bbPosFeat+tw14*s.rvolFeat+tw15*s.structBias+twB)
                    float err = (pred - float(s.result)) * w
                    g0  += err * s.bodyRatio
                    g1  += err * s.upperWick
                    g2  += err * s.lowerWick
                    g3  += err * s.rangeRatio
                    g4  += err * s.volumeRatio
                    g5  += err * s.momentum
                    g6  += err * s.deltaVolume
                    g7  += err * s.trendMom
                    g8  += err * s.atrSlope
                    g9  += err * s.volTrend
                    g10 += err * s.stDistance
                    g11 += err * s.trendDuration
                    g12 += err * s.rsiFeat
                    g13 += err * s.bbPosFeat
                    g14 += err * s.rvolFeat
                    g15 += err * s.structBias
                    gB  += err
                    wS  += w
                if wS > 0
                    float step = lr / wS
                    tw0  -= step * (g0  + LAMBDA * tw0)
                    tw1  -= step * (g1  + LAMBDA * tw1)
                    tw2  -= step * (g2  + LAMBDA * tw2)
                    tw3  -= step * (g3  + LAMBDA * tw3)
                    tw4  -= step * (g4  + LAMBDA * tw4)
                    tw5  -= step * (g5  + LAMBDA * tw5)
                    tw6  -= step * (g6  + LAMBDA * tw6)
                    tw7  -= step * (g7  + LAMBDA * tw7)
                    tw8  -= step * (g8  + LAMBDA * tw8)
                    tw9  -= step * (g9  + LAMBDA * tw9)
                    tw10 -= step * (g10 + LAMBDA * tw10)
                    tw11 -= step * (g11 + LAMBDA * tw11)
                    tw12 -= step * (g12 + LAMBDA * tw12)
                    tw13 -= step * (g13 + LAMBDA * tw13)
                    tw14 -= step * (g14 + LAMBDA * tw14)
                    tw15 -= step * (g15 + LAMBDA * tw15)
                    twB  -= step * gB

            float[] clipped = array.from(tw0,tw1,tw2,tw3,tw4,tw5,tw6,tw7,tw8,tw9,tw10,tw11,tw12,tw13,tw14,tw15,twB)
            for i = 0 to 16
                wt.set(i, math.max(-CLIP, math.min(CLIP, clipped.get(i))))

predictProbability(float[] wt, Signal sig) =>
    sigmoid(dotProduct(wt, sig))

countResolved(Signal[] data) =>
    int n = 0
    for i = 0 to data.size() - 1
        if data.get(i).result != -1
            n += 1
    n

// ══════════════════════════════════════════════════════
// adaptive supertrend
// ══════════════════════════════════════════════════════
float rawAtr = ta.atr(atrLen)
float atrS   = ta.atr(math.max(atrLen / 2, 2))
float aRatio = rawAtr > 0.0 ? atrS / rawAtr : 1.0
float aMult  = useAdaptive ? math.max(math.min(atrMult * aRatio, atrMult * 1.5), atrMult * 0.5) : atrMult

float rawUpper = hl2 + aMult * rawAtr
float rawLower = hl2 - aMult * rawAtr

var float bandU = na
var float bandL = na
bandU := (na(bandU[1]) or rawUpper < bandU[1] or close[1] > bandU[1]) ? rawUpper : bandU[1]
bandL := (na(bandL[1]) or rawLower > bandL[1] or close[1] < bandL[1]) ? rawLower : bandL[1]

var int tDir = 1
tDir := (tDir[1] == -1 and close > bandU ?  1 :
         tDir[1] ==  1 and close < bandL ? -1 : nz(tDir[1], 1))

float stLine = tDir == 1 ? bandL : bandU

// ══════════════════════════════════════════════════════
// noise filter
// ══════════════════════════════════════════════════════
var int flipCount    = 0
bool    rawFlip      = tDir != tDir[1]

if rawFlip
    flipCount := 1
else if flipCount > 0 and flipCount < noiseLen
    flipCount += 1

var int confirmedDir = tDir
bool    cleanFlip    = false

if noiseLen == 0
    confirmedDir := tDir
    cleanFlip    := rawFlip
else if flipCount == noiseLen
    confirmedDir := tDir
    cleanFlip    := true

bool bullFlip = cleanFlip and confirmedDir ==  1
bool bearFlip = cleanFlip and confirmedDir == -1

// ══════════════════════════════════════════════════════
// rvol
// ══════════════════════════════════════════════════════
float hlRange  = math.max(high - low, syminfo.mintick)
bool  hasVol   = not na(volume) and volume > 0
float bvRaw    = hasVol ? volume * (close - low)  / hlRange : 0.0
float svRaw    = hasVol ? volume * (high - close) / hlRange : 0.0

float bvMedian = ta.percentile_linear_interpolation(bvRaw, rvolLen, 50)
float svMedian = ta.percentile_linear_interpolation(svRaw, rvolLen, 50)
float bPct     = bvMedian > 0 ? math.min(100.0, bvRaw / bvMedian * 50.0) : 50.0
float sPct     = svMedian > 0 ? math.min(100.0, svRaw / svMedian * 50.0) : 50.0
float rvolPct  = confirmedDir == 1 ? bPct : sPct
bool  rvolOk   = hasVol and bar_index >= rvolLen
bool  rvolPass = not filterOn or (rvolOk and rvolPct >= rvolThresh)
float rvolFeat = rvolOk ? math.max(-1.0, math.min(1.0, (rvolPct - 50.0) / 50.0)) : 0.0

// ══════════════════════════════════════════════════════
// ml features
// ══════════════════════════════════════════════════════
float bodySize      = math.abs(close - open)
float upperWickSize = high - math.max(close, open)
float lowerWickSize = math.min(close, open) - low

float avgBody      = ta.sma(math.abs(close - open), featureLookback)
float avgUpperWick = ta.sma(high - math.max(close, open), featureLookback)
float avgLowerWick = ta.sma(math.min(close, open) - low, featureLookback)
float avgRange     = ta.sma(high - low, featureLookback)
float avgVol       = ta.sma(volume, featureLookback)

float bodyFeat      = normalizeCentered(bodySize, avgBody)
float upperWickFeat = normalizeCentered(upperWickSize, avgUpperWick)
float lowerWickFeat = normalizeCentered(lowerWickSize, avgLowerWick)
float rangeFeat     = normalizeCentered(high - low, avgRange)
float volumeFeat    = normalizeCentered(volume, avgVol)

var int consecDir = 0
if close > open
    consecDir := consecDir > 0 ? consecDir + 1 : 1
else if close < open
    consecDir := consecDir < 0 ? consecDir - 1 : -1
else
    consecDir := 0
float momentumFeat = math.max(-1.0, math.min(1.0, consecDir / 10.0))

[deltaBullVol, deltaBearVol] = calcDeltaVolume()
float totalDeltaVol = deltaBullVol + deltaBearVol
float deltaFeat     = totalDeltaVol > 0 ? (deltaBullVol / totalDeltaVol) * 2.0 - 1.0 : 0.0

float avgSignedBody = ta.sma(close - open, featureLookback)
float trendMomFeat  = avgRange > 0 ? math.max(-1.0, math.min(1.0, avgSignedBody / avgRange)) : 0.0

float atrPrev      = rawAtr[featureLookback]
float atrSlopeFeat = atrPrev > 0 ? math.max(-1.0, math.min(1.0, (rawAtr / atrPrev) - 1.0)) : 0.0

float volPrev      = ta.sma(volume[featureLookback], featureLookback)
float volTrendFeat = volPrev > 0 ? math.max(-1.0, math.min(1.0, (avgVol / volPrev) - 1.0)) : 0.0

float stDistFeat   = rawAtr > 0 ? math.max(-1.0, math.min(1.0, ((close - stLine) / rawAtr) / 3.0)) : 0.0

var int lastFlipBar = 0
float trendLenFeat  = math.max(-1.0, math.min(1.0, (float(bar_index - lastFlipBar) / 50.0) - 1.0))

float rsiRaw    = ta.rsi(close, featureLookback)
float rsiFeat   = math.max(-1.0, math.min(1.0, (nz(rsiRaw, 50) - 50.0) / 50.0))

float bbBasis   = ta.sma(close, featureLookback)
float bbDev     = ta.stdev(close, featureLookback)
float bbPosFeat = bbDev > 0 ? math.max(-1.0, math.min(1.0, (close - bbBasis) / (2.0 * bbDev))) : 0.0

// ══════════════════════════════════════════════════════
// market structure engine
// ══════════════════════════════════════════════════════
float stochK = ta.sma(ta.stoch(close, high, low, msStochLen), 3)

var float obHigh = na
var float osLow  = na
var int   obHBar = na
var int   osLBar = na

if stochK >= msOB
    if na(obHigh) or high > obHigh
        obHigh := high
        obHBar := bar_index
else
    obHigh := na
    obHBar := na

if stochK <= msOS
    if na(osLow) or low < osLow
        osLow  := low
        osLBar := bar_index
else
    osLow  := na
    osLBar := na

bool msPivH = barstate.isconfirmed and stochK < msOB and stochK[1] >= msOB and not na(obHigh[1])
bool msPivL = barstate.isconfirmed and stochK > msOS and stochK[1] <= msOS and not na(osLow[1])

float msPriceH = msPivH ? obHigh[1] : na
float msPriceL = msPivL ? osLow[1]  : na
int   msBarH   = msPivH ? nz(obHBar[1], bar_index) : na
int   msBarL   = msPivL ? nz(osLBar[1], bar_index) : na

var bool  msLastWasH      = false
var bool  msHasFirstPivot = false
var float msLastH    = na
var float msLastL    = na
var int   msLastHBar = na
var int   msLastLBar = na
var float msPrevH    = na
var float msPrevL    = na
var string msLastHDow = ""
var string msLastLDow = ""

bool msAcceptH = msPivH and (not msHasFirstPivot or not msLastWasH)
bool msAcceptL = msPivL and (not msHasFirstPivot or msLastWasH)
bool msUpdateH = msPivH and msHasFirstPivot and msLastWasH and not na(msPriceH) and msPriceH > msLastH
bool msUpdateL = msPivL and msHasFirstPivot and not msLastWasH and not na(msPriceL) and msPriceL < msLastL

if msAcceptH or msUpdateH
    msPrevH         := msLastH
    msLastH         := nz(msPriceH, msLastH)
    msLastHBar      := nz(msBarH, msLastHBar)
    msLastHDow      := not na(msPrevH) ? (msLastH > msPrevH ? "HH" : "LH") : "HH"
    msLastWasH      := true
    msHasFirstPivot := true

if msAcceptL or msUpdateL
    msPrevL         := msLastL
    msLastL         := nz(msPriceL, msLastL)
    msLastLBar      := nz(msBarL, msLastLBar)
    msLastLDow      := not na(msPrevL) ? (msLastL > msPrevL ? "HL" : "LL") : "HL"
    msLastWasH      := false
    msHasFirstPivot := true

var int msDir = 0
if msHasFirstPivot and not na(msLastH) and not na(msLastL)
    bool isBull = msLastHDow == "HH" and msLastLDow == "HL"
    bool isBear = msLastHDow == "LH" and msLastLDow == "LL"
    msDir := isBull ? 1 : isBear ? -1 : msDir

// bos = close beyond previous swing (continuation)
// choch = close beyond most recent opposing swing (reversal), flips msDir
// neither fires until msDir is established
var float msBOSLevel   = na
var float msCHoCHLevel = na
var int   msBOSBar     = na
var int   msCHoCHBar   = na
var bool  msBOSBull    = false
var bool  msBOSBear    = false
var bool  msCHoCHBull  = false
var bool  msCHoCHBear  = false

if msAcceptH or msUpdateH
    if msDir == 1 and not na(msPrevH)
        msBOSLevel   := msPrevH
        msCHoCHLevel := na
    else if msDir == -1 and not na(msPrevH)
        msCHoCHLevel := msPrevH   // bull CHoCH: must break the prior LH (major structure)
        msBOSLevel   := na

if msAcceptL or msUpdateL
    if msDir == -1 and not na(msPrevL)
        msBOSLevel   := msPrevL
        msCHoCHLevel := na
    else if msDir == 1 and not na(msPrevL)
        msCHoCHLevel := msPrevL   // bear CHoCH: must break the prior HL (major structure)
        msBOSLevel   := na

msBOSBull   := false
msBOSBear   := false
msCHoCHBull := false
msCHoCHBear := false

if barstate.isconfirmed and not na(msBOSLevel)
    if msDir == 1 and close > msBOSLevel
        msBOSBull  := true
        msBOSBar   := bar_index
        msBOSLevel := na
    else if msDir == -1 and close < msBOSLevel
        msBOSBear  := true
        msBOSBar   := bar_index
        msBOSLevel := na

if barstate.isconfirmed and not na(msCHoCHLevel)
    if msDir == 1 and close < msCHoCHLevel
        msCHoCHBear  := true
        msCHoCHBar   := bar_index
        msDir        := -1
        msCHoCHLevel := na
        msBOSLevel   := na
    else if msDir == -1 and close > msCHoCHLevel
        msCHoCHBull  := true
        msCHoCHBar   := bar_index
        msDir        := 1
        msCHoCHLevel := na
        msBOSLevel   := na

float structBiasFeat = msDir == 1 ? 1.0 : msDir == -1 ? -1.0 : 0.0

var string msLastEvtTxt = "—"
if msBOSBull
    msLastEvtTxt := "BOS ▲"
if msBOSBear
    msLastEvtTxt := "BOS ▼"
if msCHoCHBull
    msLastEvtTxt := "CHoCH ▲"
if msCHoCHBear
    msLastEvtTxt := "CHoCH ▼"

// ══════════════════════════════════════════════════════
// market structure visuals
// ══════════════════════════════════════════════════════
if showBOS
    if msBOSBull
        label.new(bar_index, low - rawAtr * 0.3, "BOS",
                  color=color.new(cBull, 20), style=label.style_label_up,
                  textcolor=color.white, size=size.small, force_overlay=true)
    if msBOSBear
        label.new(bar_index, high + rawAtr * 0.3, "BOS",
                  color=color.new(cBear, 20), style=label.style_label_down,
                  textcolor=color.white, size=size.small, force_overlay=true)
    if msCHoCHBull
        label.new(bar_index, low - rawAtr * 0.3, "CHoCH",
                  color=color.new(cBull, 0), style=label.style_label_up,
                  textcolor=color.white, size=size.small, force_overlay=true)
    if msCHoCHBear
        label.new(bar_index, high + rawAtr * 0.3, "CHoCH",
                  color=color.new(cBear, 0), style=label.style_label_down,
                  textcolor=color.white, size=size.small, force_overlay=true)

if showDow and barstate.isconfirmed
    if msAcceptH
        color dowCol = msLastHDow == "HH" ? cBull : color.new(cBear, 30)
        label.new(msLastHBar, msLastH + rawAtr * 0.2, msLastHDow,
                  yloc=yloc.price, color=color.new(color.black, 100),
                  textcolor=dowCol, style=label.style_label_down, size=size.tiny, force_overlay=true)
    if msAcceptL
        color dowCol = msLastLDow == "HL" ? cBull : color.new(cBear, 30)
        label.new(msLastLBar, msLastL - rawAtr * 0.2, msLastLDow,
                  yloc=yloc.price, color=color.new(color.black, 100),
                  textcolor=dowCol, style=label.style_label_up, size=size.tiny, force_overlay=true)

if showZigzag and barstate.isconfirmed
    if msAcceptH and not na(msLastLBar)
        line.new(msLastLBar, msLastL, msLastHBar, msLastH,
                 color=color.new(cBull, 20), width=2, force_overlay=true)
    if msAcceptL and not na(msLastHBar)
        line.new(msLastHBar, msLastH, msLastLBar, msLastL,
                 color=color.new(cBear, 20), width=2, force_overlay=true)

var box[]  srSupBoxes  = array.new<box>()
var box[]  srResBoxes  = array.new<box>()
var bool[] srSupBroken = array.new<bool>()
var bool[] srResBroken = array.new<bool>()

float zoneH = rawAtr * srZoneAtr * 0.5

if showSR and barstate.isconfirmed and msAcceptL and not na(msLastL)
    float zTop = msLastL + zoneH
    float zBot = msLastL - zoneH * 0.3
    bool supOverlap = false
    if srSupBoxes.size() > 0
        for i = 0 to srSupBoxes.size() - 1
            box b = srSupBoxes.get(i)
            if zTop >= box.get_bottom(b) and zBot <= box.get_top(b)
                supOverlap := true
    if not supOverlap
        box nb = box.new(msLastLBar, zTop, bar_index + 1, zBot,
                         border_color=color.new(cBull, 30),
                         bgcolor=color.new(cBull, 82), force_overlay=true)
        srSupBoxes.push(nb)
        srSupBroken.push(false)
        if srSupBoxes.size() > srMaxZones
            box.delete(srSupBoxes.shift())
            srSupBroken.shift()

if showSR and barstate.isconfirmed and msAcceptH and not na(msLastH)
    float zTop = msLastH + zoneH * 0.3
    float zBot = msLastH - zoneH
    bool resOverlap = false
    if srResBoxes.size() > 0
        for i = 0 to srResBoxes.size() - 1
            box b = srResBoxes.get(i)
            if zTop >= box.get_bottom(b) and zBot <= box.get_top(b)
                resOverlap := true
    if not resOverlap
        box nb = box.new(msLastHBar, zTop, bar_index + 1, zBot,
                         border_color=color.new(cBear, 30),
                         bgcolor=color.new(cBear, 82), force_overlay=true)
        srResBoxes.push(nb)
        srResBroken.push(false)
        if srResBoxes.size() > srMaxZones
            box.delete(srResBoxes.shift())
            srResBroken.shift()

if showSR and barstate.isconfirmed
    int supSz = srSupBoxes.size()
    if supSz > 0
        for i = 0 to supSz - 1
            if not srSupBroken.get(i)
                box b = srSupBoxes.get(i)
                if close < box.get_bottom(b)
                    srSupBroken.set(i, true)
                    box.set_bgcolor(b, color.new(cBull, 94))
                    box.set_border_color(b, color.new(cBull, 70))
                else
                    box.set_right(b, bar_index + 1)
    int resSz = srResBoxes.size()
    if resSz > 0
        for i = 0 to resSz - 1
            if not srResBroken.get(i)
                box b = srResBoxes.get(i)
                if close > box.get_top(b)
                    srResBroken.set(i, true)
                    box.set_bgcolor(b, color.new(cBear, 94))
                    box.set_border_color(b, color.new(cBear, 70))
                else
                    box.set_right(b, bar_index + 1)

// ══════════════════════════════════════════════════════
// ml model
// ══════════════════════════════════════════════════════
var Signal[] bullSignals = array.new<Signal>()
var Signal[] bearSignals = array.new<Signal>()
var float[]  bullWeights = array.from(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
var float[]  bearWeights = array.from(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

if cleanFlip and bullSignals.size() > 0
    Signal last = bullSignals.last()
    if last.result == -1
        last.result := close > last.entryPrice ? 1 : 0
if cleanFlip and bearSignals.size() > 0
    Signal last = bearSignals.last()
    if last.result == -1
        last.result := close < last.entryPrice ? 1 : 0

// ══════════════════════════════════════════════════════
// signal gate
// ══════════════════════════════════════════════════════
var float mlProbBull = na
var float mlProbBear = na
var bool  alertBull  = false
var bool  alertBear  = false
alertBull := false
alertBear := false

bool msAlignBull = not msFilter or msDir >= 0
bool msAlignBear = not msFilter or msDir <= 0

if cleanFlip
    lastFlipBar := bar_index
    mlProbBull  := na
    mlProbBear  := na

    Signal newSig = Signal.new(
         entryPrice    = close,
         barIdx        = bar_index,
         bodyRatio     = bodyFeat,
         upperWick     = upperWickFeat,
         lowerWick     = lowerWickFeat,
         rangeRatio    = rangeFeat,
         volumeRatio   = volumeFeat,
         momentum      = momentumFeat,
         deltaVolume   = deltaFeat,
         trendMom      = trendMomFeat,
         atrSlope      = atrSlopeFeat,
         volTrend      = volTrendFeat,
         stDistance    = stDistFeat,
         trendDuration = trendLenFeat,
         rsiFeat       = rsiFeat,
         bbPosFeat     = bbPosFeat,
         rvolFeat      = rvolFeat,
         structBias    = structBiasFeat)

    if bullFlip
        bullSignals.push(newSig)
        if bullSignals.size() > MAX_HISTORY
            bullSignals.shift()
        trainModel(bullWeights, bullSignals, trainWindow, decayFactor, learningRate, epochs)
        if countResolved(bullSignals) >= minSamples
            float p = predictProbability(bullWeights, newSig) * 100.0
            newSig.probability := p
            mlProbBull := p

    if bearFlip
        bearSignals.push(newSig)
        if bearSignals.size() > MAX_HISTORY
            bearSignals.shift()
        trainModel(bearWeights, bearSignals, trainWindow, decayFactor, learningRate, epochs)
        if countResolved(bearSignals) >= minSamples
            float p = predictProbability(bearWeights, newSig) * 100.0
            newSig.probability := p
            mlProbBear := p

float curProb  = bullFlip ? mlProbBull : bearFlip ? mlProbBear : na
bool  probPass = na(curProb) or curProb >= minProb
bool  signalOk = rvolPass and probPass

if barstate.isconfirmed
    if bullFlip and signalOk and msAlignBull
        alertBull := true
        string _msg = "FloAlgo ▲ Bull ST"
        if alertRvol and rvolOk
            _msg += " | RVOL " + str.tostring(rvolPct, "#.0") + "%"
        if alertProb and not na(curProb)
            _msg += " | ML " + str.tostring(curProb, "#.0") + "%"
        if alertPrice
            _msg += " | " + str.tostring(close, format.mintick)
        alert(_msg, alert.freq_once_per_bar_close)
    if bearFlip and signalOk and msAlignBear
        alertBear := true
        string _msg = "FloAlgo ▼ Bear ST"
        if alertRvol and rvolOk
            _msg += " | RVOL " + str.tostring(rvolPct, "#.0") + "%"
        if alertProb and not na(curProb)
            _msg += " | ML " + str.tostring(curProb, "#.0") + "%"
        if alertPrice
            _msg += " | " + str.tostring(close, format.mintick)
        alert(_msg, alert.freq_once_per_bar_close)

// ══════════════════════════════════════════════════════
// trend duration
// ══════════════════════════════════════════════════════
var int trendBars = 0
if barstate.isconfirmed
    trendBars := confirmedDir == confirmedDir[1] ? trendBars + 1 : 1

// ══════════════════════════════════════════════════════
// visuals
// ══════════════════════════════════════════════════════
bool visBull = bullFlip and signalOk and msAlignBull
bool visBear = bearFlip and signalOk and msAlignBear

barcolor(showBar ? color.new(tDir == 1 ? cBull : cBear, 60) : na)

// ══════════════════════════════════════════════════════
// info table
// ══════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 9,
     bgcolor=color.new(color.black, 0),
     border_color=color.new(chart.fg_color, 85), border_width=1,
     frame_color=color.new(chart.fg_color, 70), frame_width=1)

tcell(int r, string k, string v, color vc) =>
    table.cell(dash, 0, r, k, text_color=#c8c8c8, text_size=size.normal)
    table.cell(dash, 1, r, v, text_color=vc,      text_size=size.normal, text_halign=text.align_right)

if barstate.islast and showTable
    bool hasBullSig = visBull and signalOk
    bool hasBearSig = visBear and signalOk
    string sigTxt = hasBullSig ? "✓ LONG" : (hasBearSig ? "✓ SHORT" : "— WAIT")
    color  sigCol = hasBullSig ? cBull : (hasBearSig ? cBear : color.gray)

    color  trendCol = confirmedDir == 1 ? cBull : cBear
    string durTxt   = (confirmedDir == 1 ? "▲ BULL" : "▼ BEAR") + "  " + str.tostring(trendBars) + " bars"

    float  lastProb = confirmedDir == 1 ? nz(mlProbBull, -1.0) : nz(mlProbBear, -1.0)
    string probTxt  = lastProb < 0 ? "Training…" : str.tostring(lastProb, "#.0") + "%"
    color  probCol  = lastProb < 0 ? color.gray : (lastProb >= 60 ? cBull : (lastProb >= 40 ? color.white : cBear))

    string rvolQual = not rvolOk ? "" : (rvolPct >= 75 ? "  Strong" : (rvolPct >= 50 ? "  Ok" : "  Weak"))
    string rvolTxt  = rvolOk ? str.tostring(rvolPct, "#.0") + "%" + rvolQual : "No Vol"
    color  rvolCol  = not rvolOk ? color.gray : (rvolPct >= rvolThresh ? cBull : #888888)

    string momTxt = momentumFeat > 0.3 ? "Bullish ↑" : (momentumFeat < -0.3 ? "Bearish ↓" : "Neutral —")
    color  momCol = momentumFeat > 0.3 ? cBull : (momentumFeat < -0.3 ? cBear : color.white)

    string volTxt = aRatio > 1.15 ? "Expanding ↑" : (aRatio < 0.85 ? "Contracting ↓" : "Normal")
    color  volCol = aRatio > 1.15 ? color.orange : (aRatio < 0.85 ? #888888 : color.white)

    float qualScore = (
         (rvolOk and rvolPct >= rvolThresh ? 1.0 : 0.0) +
         (lastProb >= 60 ? 1.0 : (lastProb >= 40 ? 0.5 : 0.0)) +
         ((confirmedDir == 1 and momentumFeat > 0) or (confirmedDir == -1 and momentumFeat < 0) ? 1.0 : 0.0))
    string qualTxt = qualScore >= 2.5 ? "★★★ Strong" : (qualScore >= 1.5 ? "★★ Moderate" : "★ Weak")
    color  qualCol = qualScore >= 2.5 ? cBull : (qualScore >= 1.5 ? color.white : cBear)

    string msBiasTxt = msDir == 1 ? "▲ Bullish" : msDir == -1 ? "▼ Bearish" : "◆ Ranging"
    color  msBiasCol = msDir == 1 ? cBull : msDir == -1 ? cBear : color.gray

    bool isEvtBull = msLastEvtTxt == "BOS ▲" or msLastEvtTxt == "CHoCH ▲"
    bool isEvtBear = msLastEvtTxt == "BOS ▼" or msLastEvtTxt == "CHoCH ▼"
    color msEvtCol = isEvtBull ? cBull : isEvtBear ? cBear : color.gray

    tcell(0, "Signal",     sigTxt,       sigCol)
    tcell(1, "Trend",      durTxt,       trendCol)
    tcell(2, "ML Conf",    probTxt,      probCol)
    tcell(3, "RVOL",       rvolTxt,      rvolCol)
    tcell(4, "Momentum",   momTxt,       momCol)
    tcell(5, "Volatility", volTxt,       volCol)
    tcell(6, "Quality",    qualTxt,      qualCol)
    tcell(7, "MS Bias",    msBiasTxt,    msBiasCol)
    tcell(8, "Structure",  msLastEvtTxt, msEvtCol)

// ══════════════════════════════════════════════════════
// alerts
// ══════════════════════════════════════════════════════
alertcondition(alertBull,   "FloAlgo — Bull ST",    message="FloAlgo Bull SuperTrend Signal")
alertcondition(alertBear,   "FloAlgo — Bear ST",    message="FloAlgo Bear SuperTrend Signal")
alertcondition(msBOSBull,   "FloAlgo — Bull BOS",   message="FloAlgo Bullish Break of Structure")
alertcondition(msBOSBear,   "FloAlgo — Bear BOS",   message="FloAlgo Bearish Break of Structure")
alertcondition(msCHoCHBull, "FloAlgo — Bull CHoCH", message="FloAlgo Bullish Change of Character")
alertcondition(msCHoCHBear, "FloAlgo — Bear CHoCH", message="FloAlgo Bearish Change of Character")
````
