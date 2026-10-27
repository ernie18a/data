# Strong KNN Classifier | ProjectSyndicate

- url: https://www.tradingview.com/script/VKQOG86C-Strong-KNN-Classifier-ProjectSyndicate/
- type: indicator
- pine_id: PUB;852c26b11d034d2e8543d11dbd780337
- version: 1.0

## Description

Strong KNN Classifier reads the order flow underneath each bar and asks one question: is the current move more likely to CONTINUE or to REVERSE? Instead of guessing, it learns from the market's own history. Every bar is turned into a five-part order-flow fingerprint, stored with the outcome it actually produced, and the live bar is matched against the closest past situations using Lorentzian distance — the outlier-robust metric built for noisy market data. The nearest neighbours vote, that vote is calibrated into an honest probability, and only genuinely confident reads near structural zones are printed as signals. Every prediction that resolves is scored on a live hit-rate panel — winners and misses alike — so you see exactly how the logic behaves on the symbol and timeframe you trade, not a number typed into a description.

🧠 Lorentzian Core — the core idea, expressed as a lifecycle: OBSERVE ▸ LABEL ▸ LEARN ▸ CLASSIFY ▸ CALIBRATE. Each bar is reduced to five order-flow features and z-scored so they share one scale. A rolling library of past feature vectors is kept, and each one is labelled only after its outcome is fully known — a vector formed H bars ago is tagged CONTINUATION or REVERSAL using bars that have already printed, never future ones. The live bar is then compared to that resolved library with Lorentzian-distance k-nearest-neighbours, the closest matches vote, and the result is turned into a probability. Because every label is resolved from past bars and every signal confirms on the bar's close, the classifier does not repaint.

🔋 Feature Anatomy — the fingerprint is not one number; it is five breakout-native ingredients fused into a single distance. Net delta (reconstructed buy-minus-sell pressure), bid/ask imbalance (which side dominated the bar), absorption (heavy volume that produces little price progress — a stalled push), CVD slope (the direction and steepness of cumulative delta), and price location versus VWAP in ATR units (where the bar sits inside its structural range). Each feature is independently z-scored over a rolling window, so no single raw scale can dominate the match. Order-flow components are reconstructed from lower-timeframe intrabar data and are labelled as estimates, not exchange tick prints.

🎯 Calibrated Probability Engine — this is the part most "AI" scripts get wrong. A raw k-vote can only land on a handful of fractions, so it slams to 88% or 100% and lies about its own confidence. Strong KNN Classifier instead weights each neighbour by distance, collapses the vote into a signed margin, shrinks that margin toward a neutral 0.5 prior by how much trustworthy neighbour mass actually agreed, and passes it through a logistic curve. The output is a smooth, continuous Reversal Probability and a 0–100 Confidence read that reflect genuine neighbour agreement — high only when many close matches concur, honestly near the middle when they don't.

🧲 Structural-Zone Context — a classification matters most where decisions are made: at the levels where price interacts with resting structure. The engine only promotes a read to a signal when price is inside a structural zone — within an ATR band of VWAP or of the most recent confirmed swing pivot. Away from structure the model still reports its read on the dashboard, but it holds its fire, keeping orbs anchored to the moments that carry context rather than scattering them mid-range.

🎚️ Conviction Controls — a compact set of dials sets how serious a read must be before it prints: the Minimum Confidence to signal, the number of Neighbours (k) that vote, the Prior Strength that shrinks weak agreement toward neutral, the Probability Sharpness that scales the confidence spread, the Distance Temperature that softens or sharpens neighbour weighting, the minimum sample count before any signal is allowed, and a cooldown. Tighten them for fewer, cleaner classifications; loosen them for more activity. Together with the zone gate, this is your main control over conviction versus frequency.

🧭 No-Lookahead Discipline — a read is not allowed to cheat. Training labels are resolved purely from bars that have already closed, the live bar is only ever compared against fully-resolved neighbours, and signals confirm on the closed candle. Until the library holds enough resolved samples the panel shows TRAINING and stays silent, and a cooldown stops a single chaotic session from stacking overlapping orbs. The hit-rate tracker is held to the same standard — every prediction whose horizon resolves is counted, correct or not, with nothing dropped to flatter the number.

⭐ 0–100 Confidence Read — every classification carries a numeric Reversal Probability, a Confidence score, and the count of neighbours that actually contributed. Treat Confidence as a relative cleanliness and agreement read for ranking and thinning signals — it describes how textbook the current situation is versus the model's memory, not a guaranteed outcome. The confidence threshold restricts what is displayed and alerted, while the dashboard keeps reporting the live read in the background even when no signal fires.

📊 Live Statistics Dashboard — a non-intrusive panel tracks, in real time on your chart: model status (TRAINING or LIVE) with the current training-pool size, the order-flow source in use, each of the five features as a live z-score, the current Prediction (continuation / reversal / neutral), the Reversal Probability, the Confidence, the number of neighbours used, whether price is currently inside a structural zone, and a rolling Hit-Rate computed over every resolved prediction. The hit-rate counts winners and misses in full, so the number is built live from the real signals on your current symbol and timeframe — not printed here in advance.

🎨 Clean Themed Visuals — four coherent palettes (Aurora default, plus Neon, Plasma, and Solar) shade the probability ribbon, the class-tinted candles, the signal orbs and their chips, and the dashboard to one look, so direction and quality read at a glance on a dark chart. A background ribbon graduates between the continuation and reversal colours by probability; confirmed signals print a sized circular orb with a clean, non-overlapping chip showing direction, probability, and the neighbour/confidence read. Signal dot size is adjustable, and the chip offset scales with it so labels never collide with the orb.

🔔 Detailed Alerts — fires on a continuation signal, on a reversal signal, and on any high-confidence classification, formatted for manual or automated use. The confidence threshold and the in-zone gate restrict alerts to higher-conviction reads.

🔧 Fully Customizable — every component is exposed: the number of neighbours, the outcome horizon, the trend-reference length, the outcome threshold in ATR, and the maximum and minimum training-pool sizes; the distance temperature, prior strength, and probability sharpness that govern calibration; the normalisation window, CVD slope length, and absorption reference of the feature engine; the intrabar resolution and volume weighting of the order-flow reconstruction; the VWAP and swing-pivot zones, pivot length, and zone width; the confidence threshold, in-zone requirement, and cooldown; all four themes and every ribbon, candle-tint, orb, dot-size, neighbour-chip, and dashboard toggle, plus dashboard position and size.

🎯 Why this is different — most "machine learning" indicators are black boxes that restyle an oscillator and claim to call the top, and most kNN scripts publish a confidence that is really just a vote fraction in disguise. This one engineers inspectable order-flow features, matches them with an outlier-robust Lorentzian metric, and then does the part that is usually skipped: it calibrates the probability so confidence reflects real, distance-weighted neighbour agreement instead of a coarse vote artefact. It resolves every training label with no lookahead, gates signals to structural context, and reports a live, honest hit-rate that counts misses in full — so you judge it on your own current data rather than on a marketing figure.

🚀 Where to use it — the engine is symbol-agnostic and built on universal order-flow behaviour, so it can be applied to FX majors and crosses, metals, indices, and crypto on intraday timeframes. It is strongest where lower-timeframe order-flow reconstruction carries information — liquid intraday futures and crypto — and the normalisation and ATR scaling adapt to each instrument automatically. One practical check: if the five features all read 0σ, your chart's symbol is not exposing intrabar data and the model is running on the coarse bar-level fallback — set the Intrabar Resolution explicitly and confirm the features come alive before relying on signals. Because the classifier is symmetric, let the dashboard's hit-rate tell you whether the logic genuinely suits the pair and timeframe before you commit.

🎯 How to trade it

1 Apply it to a liquid symbol on an intraday timeframe and let the panel move from TRAINING to LIVE as the library fills. Read the live Hit-Rate for your symbol and timeframe first — if the logic doesn't suit that market, you'll see it.

2 Wait for an orb — it marks a confirmed close, above your confidence threshold, inside a structural zone, with the direction, probability, and neighbour/confidence read already labelled.

3 Read the dashboard alongside it: the Prediction, the Reversal Probability, the Confidence, and how many of the k neighbours actually agreed.

4 Use the confidence threshold, neighbour count, prior strength, and sharpness to set your tempo — stricter for fewer, cleaner reads; looser for more activity.

5 Combine the classification with your own structure and risk management — it is a read on the next move's character, not an entry-and-exit system on its own.

⚠️ Important — this is a decision-support tool, not a standalone buy/sell system, and it makes no performance guarantees. The probability is calibrated to reflect genuine neighbour agreement, but the underlying edge varies by market, session, and configuration, and on some symbols and timeframes it will be close to neutral — the displayed probability and the dashboard hit-rate are historical and descriptive, not a forecast. Order-flow features are reconstructed from lower-timeframe data and are estimates, not true tick prints; where intrabar data is unavailable the model falls back to a coarser delta. Signals confirm on the closed bar, so always wait for the orb on a closed candle. Because the classifier is symmetric and contrarian-capable, a strong one-way trend or a regime shift can run straight through a high-confidence read — combine it with your own analysis, and test it on your market before trading it live.

## Source Code

````pine
//@version=6
indicator("Strong KNN Classifier", overlay=true, max_labels_count=500, max_lines_count=100, max_boxes_count=100, max_bars_back=5000)
var string G_ML   = "◈ Classifier"
var string G_FEAT = "◈ Feature Engine"
var string G_LTF  = "◈ Order-Flow (Lower-TF)"
var string G_ZONE = "◈ Structural Zones"
var string G_SIG  = "◈ Signals & Alerts"
var string G_VIS  = "◈ Visuals"
var string G_DASH = "◈ Dashboard"
int    kNeighbors   = input.int(16,  "Neighbours (k)",            minval=3, maxval=48,  group=G_ML)
int    horizon      = input.int(12,  "Outcome Horizon (bars)",    minval=3, maxval=100, group=G_ML)
int    maxPool      = input.int(600, "Max Training Samples",      minval=50, maxval=2000, group=G_ML)
int    minPool      = input.int(60,  "Min Samples Before Signals",minval=20, maxval=1000, group=G_ML)
float  outcomeThr   = input.float(0.5, "Outcome Threshold (×ATR)", minval=0.05, maxval=2.0, step=0.05, group=G_ML)
int    momLen       = input.int(3,   "Trend Reference Length",    minval=2, maxval=50,  group=G_ML)
float  temperature  = input.float(1.0, "Distance Temperature",    minval=0.2, maxval=5.0, step=0.1, group=G_ML)
float  priorK       = input.float(4.0, "Prior Strength (shrinkage)", minval=0.0, maxval=30.0, step=0.5, group=G_ML)
float  sharpness    = input.float(2.5, "Probability Sharpness",   minval=0.2, maxval=8.0, step=0.1, group=G_ML)
int    normWin      = input.int(250, "Normalisation Window",      minval=50, maxval=1000, group=G_FEAT)
int    cvdSlopeLen  = input.int(14,  "CVD Slope Length",          minval=3, maxval=100, group=G_FEAT)
float  absorpVolMlt = input.float(1.5,"Absorption Volume ×Avg",   minval=1.0, maxval=5.0, step=0.1, group=G_FEAT)
string ltfMode      = input.string("Auto", "Intrabar Resolution", options=["Auto","1m","5m","15m","Chart/12"], group=G_LTF)
bool   useLtfVolume = input.bool(true, "Weight Delta by Volume",  group=G_LTF)
bool   useVWAP      = input.bool(true, "VWAP Zone",               group=G_ZONE)
bool   usePivots    = input.bool(true, "Swing-Pivot Zone",        group=G_ZONE)
int    pivLen       = input.int(10,  "Pivot Lookback",            minval=3, maxval=50,  group=G_ZONE)
float  zoneAtr      = input.float(0.8, "Zone Width (×ATR)",       minval=0.1, maxval=4.0, step=0.1, group=G_ZONE)
float  confThr      = input.float(0.30, "Min Confidence to Signal", minval=0.10, maxval=0.95, step=0.01, group=G_SIG)
bool   requireZone  = input.bool(true, "Only Signal Inside Zones", group=G_SIG)
int    sigCooldown  = input.int(5,   "Signal Cooldown (bars)",    minval=0, maxval=50,  group=G_SIG)
string themeInput   = input.string("Aurora", "Theme",            options=["Aurora","Neon","Plasma","Solar"], group=G_VIS)
bool   showRibbon   = input.bool(true, "Probability Ribbon (bg)", group=G_VIS)
bool   showCandles  = input.bool(true, "Tint Candles by Class",  group=G_VIS)
bool   showOrbs     = input.bool(true, "Signal Orbs",            group=G_VIS)
string orbSizeIn    = input.string("Small", "Signal Dot Size",   options=["Tiny","Small","Normal","Large","Huge"], group=G_VIS)
bool   showNeighbor = input.bool(true, "Neighbour Tags on Signal",group=G_VIS)
bool   showDash     = input.bool(true, "Show Dashboard",         group=G_DASH)
string dashPos      = input.string("Top Right", "Position",      options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group=G_DASH)
string dashSize     = input.string("Normal", "Size",            options=["Tiny","Small","Normal"], group=G_DASH)
var color cCont  = na
var color cRev   = na
var color cAcc   = na
var color cNeut  = na
if themeInput == "Aurora"
    cCont := #00E5C0
    cRev  := #FF2D78
    cAcc  := #B388FF
    cNeut := #8B949E
else if themeInput == "Neon"
    cCont := #00F5D4
    cRev  := #FF4466
    cAcc  := #6C63FF
    cNeut := #FFD700
else if themeInput == "Plasma"
    cCont := #00FFAA
    cRev  := #FF006E
    cAcc  := #00D4FF
    cNeut := #8B949E
else
    cCont := #FFB300
    cRev  := #42A5F5
    cAcc  := #FFEB3B
    cNeut := #9E9E9E
color cBgPanel = color.new(#161B22, 0)
color cBgDark  = color.new(#0D1117, 10)
color cBgHdr   = color.new(#0D1117, 0)
color cTxtMut  = color.new(#8B949E, 0)
color cTxtWht  = color.new(#E6EDF3, 0)
atr     = ta.atr(14)
avgVol  = ta.sma(volume, 20)
vwapVal = ta.vwap(hlc3)
f_z(float x, simple int win) =>
    float m = ta.sma(x, win)
    float s = ta.stdev(x, win)
    s > 0 ? (x - m) / s : 0.0
ltfPeriod = switch ltfMode
    "1m"       => "1"
    "5m"       => "5"
    "15m"      => "15"
    "Chart/12" => timeframe.multiplier > 0 ? str.tostring(math.max(1, math.floor(timeframe.in_seconds() / 60 / 12))) : "1"
    => timeframe.in_seconds() >= 3600 ? "5" : timeframe.in_seconds() >= 900 ? "1" : "1"
intraClose  = request.security_lower_tf(syminfo.tickerid, ltfPeriod, close)
intraVolume = request.security_lower_tf(syminfo.tickerid, ltfPeriod, volume)
f_flow() =>
    float dlt  = 0.0
    float buy  = 0.0
    float sell = 0.0
    int   n    = array.size(intraClose)
    if n > 0 and n == array.size(intraVolume)
        float prev = na
        for i = 0 to n - 1
            float c = array.get(intraClose, i)
            float v = nz(array.get(intraVolume, i), 0.0)
            float w = useLtfVolume ? v : 1.0
            if na(prev)
                prev := c
            else
                if c > prev
                    dlt  += w
                    buy  += w
                else if c < prev
                    dlt  -= w
                    sell += w
                else
                    buy  += w * 0.5
                    sell += w * 0.5
                prev := c
    else
        if not na(close[1])
            float w = nz(volume, 0.0)
            if close > close[1]
                dlt  := w
                buy  := w
            else if close < close[1]
                dlt  := -w
                sell := w
            else
                buy  := w * 0.5
                sell := w * 0.5
    [dlt, buy, sell]
[barDelta, barBuy, barSell] = f_flow()
ltfAvailable = array.size(intraClose) > 0
cvd = ta.cum(barDelta)
rawDelta  = barDelta / (nz(volume, 0.0) + 1.0)
f1 = f_z(rawDelta, normWin)
totV      = barBuy + barSell
rawImb    = totV > 0 ? (barBuy - barSell) / totV : 0.0
f2 = f_z(rawImb, normWin)
bodyProg  = atr > 0 ? math.abs(close - open) / atr : 0.0
volZ      = f_z(volume, normWin)
rawAbsorp = (volume > avgVol * absorpVolMlt ? volZ : 0.0) * (1.0 / (1.0 + bodyProg))
f3 = f_z(rawAbsorp, normWin)
rawCvdSlope = atr > 0 ? (cvd - cvd[cvdSlopeLen]) / (cvdSlopeLen * (avgVol + 1.0)) : 0.0
f4 = f_z(rawCvdSlope, normWin)
rawLoc    = atr > 0 ? (close - vwapVal) / atr : 0.0
f5 = f_z(rawLoc, normWin)
featReady = bar_index > normWin + horizon + 2
const int CONT = 1
const int REV  = -1
var array<float> p1 = array.new_float()
var array<float> p2 = array.new_float()
var array<float> p3 = array.new_float()
var array<float> p4 = array.new_float()
var array<float> p5 = array.new_float()
var array<int>   pL = array.new_int()
pastDir   = math.sign(close[horizon] - close[horizon + momLen])
futMove   = close - close[horizon]
signedMv  = futMove * pastDir
atrPast   = atr[horizon]
decisive  = atrPast > 0 and math.abs(signedMv) > outcomeThr * atrPast
resLabel  = signedMv > 0 ? CONT : REV
if featReady and decisive and pastDir != 0 and barstate.isconfirmed
    array.push(p1, f1[horizon])
    array.push(p2, f2[horizon])
    array.push(p3, f3[horizon])
    array.push(p4, f4[horizon])
    array.push(p5, f5[horizon])
    array.push(pL, resLabel)
    if array.size(pL) > maxPool
        array.shift(p1)
        array.shift(p2)
        array.shift(p3)
        array.shift(p4)
        array.shift(p5)
        array.shift(pL)
poolSize  = array.size(pL)
poolReady = poolSize >= minPool
var array<float> nnDist  = array.new_float(kNeighbors, 1e18)
var array<int>   nnLabel = array.new_int(kNeighbors, 0)
float pReversal  = 0.5
float confidence = 0.0
int   nContrib   = 0
if poolReady and featReady
    for i = 0 to kNeighbors - 1
        array.set(nnDist, i, 1e18)
        array.set(nnLabel, i, 0)
    for j = 0 to poolSize - 1
        float d = math.log(1.0 + math.abs(f1 - array.get(p1, j))) + math.log(1.0 + math.abs(f2 - array.get(p2, j))) + math.log(1.0 + math.abs(f3 - array.get(p3, j))) + math.log(1.0 + math.abs(f4 - array.get(p4, j))) + math.log(1.0 + math.abs(f5 - array.get(p5, j)))
        float worst = -1.0
        int   wIdx  = 0
        for s = 0 to kNeighbors - 1
            float ds = array.get(nnDist, s)
            if ds > worst
                worst := ds
                wIdx  := s
        if d < worst
            array.set(nnDist, wIdx, d)
            array.set(nnLabel, wIdx, array.get(pL, j))
    float wRev  = 0.0
    float wCont = 0.0
    for s = 0 to kNeighbors - 1
        int   lb = array.get(nnLabel, s)
        float ds = array.get(nnDist, s)
        if lb != 0 and ds < 1e17
            float w = math.exp(-ds / temperature)
            if lb == REV
                wRev += w
            else
                wCont += w
            nContrib += 1
    float wTot = wRev + wCont
    float sMargin = wTot > 0 ? (wRev - wCont) / wTot : 0.0
    float eff = sMargin * (wTot / (wTot + priorK))
    float z = sharpness * eff
    pReversal := 1.0 / (1.0 + math.exp(-z))
    confidence := math.abs(pReversal - 0.5) * 2.0
predClass = not poolReady ? 0 : confidence < confThr ? 0 : pReversal > 0.5 ? REV : CONT
var int correctN = 0
var int totalN   = 0
predThen = predClass[horizon]
if featReady and decisive and pastDir != 0 and predThen != 0 and barstate.isconfirmed
    totalN += 1
    if predThen == resLabel
        correctN += 1
liveAcc = totalN > 0 ? correctN / totalN * 100.0 : na
var float lastPH = na
var float lastPL = na
ph = ta.pivothigh(pivLen, pivLen)
pl = ta.pivotlow(pivLen, pivLen)
if not na(ph)
    lastPH := ph
if not na(pl)
    lastPL := pl
nearVWAP  = useVWAP and atr > 0 and math.abs(close - vwapVal) <= zoneAtr * atr
nearPivot = usePivots and atr > 0 and ((not na(lastPH) and math.abs(close - lastPH) <= zoneAtr * atr) or (not na(lastPL) and math.abs(close - lastPL) <= zoneAtr * atr))
inZone    = nearVWAP or nearPivot
var int lastSigBar = -100000
zoneOk    = not requireZone or inZone
canSignal = poolReady and confidence >= confThr and zoneOk and barstate.isconfirmed and (bar_index - lastSigBar > sigCooldown)
isRevSig  = canSignal and predClass == REV
isContSig = canSignal and predClass == CONT
if isRevSig or isContSig
    lastSigBar := bar_index
ribbonCol = color.from_gradient(pReversal, 0.0, 1.0, color.new(cCont, 78), color.new(cRev, 78))
bgcolor(showRibbon and poolReady ? (confidence >= confThr ? ribbonCol : color.new(ribbonCol, 90)) : na)
candTint = predClass == REV ? color.new(cRev, math.round(70 - confidence * 50)) : predClass == CONT ? color.new(cCont, math.round(70 - confidence * 50)) : na
barcolor(showCandles and poolReady ? candTint : na)
orbGap = switch orbSizeIn
    "Tiny"   => 0.6
    "Normal" => 1.2
    "Large"  => 1.7
    "Huge"   => 2.3
    => 0.9
cOrb = showOrbs and isContSig
rOrb = showOrbs and isRevSig
plotshape(cOrb and orbSizeIn == "Tiny",   "Continuation Orb Tiny",   shape.circle, location.belowbar, cCont, size=size.tiny)
plotshape(cOrb and orbSizeIn == "Small",  "Continuation Orb Small",  shape.circle, location.belowbar, cCont, size=size.small)
plotshape(cOrb and orbSizeIn == "Normal", "Continuation Orb Normal", shape.circle, location.belowbar, cCont, size=size.normal)
plotshape(cOrb and orbSizeIn == "Large",  "Continuation Orb Large",  shape.circle, location.belowbar, cCont, size=size.large)
plotshape(cOrb and orbSizeIn == "Huge",   "Continuation Orb Huge",   shape.circle, location.belowbar, cCont, size=size.huge)
plotshape(rOrb and orbSizeIn == "Tiny",   "Reversal Orb Tiny",   shape.circle, location.abovebar, cRev, size=size.tiny)
plotshape(rOrb and orbSizeIn == "Small",  "Reversal Orb Small",  shape.circle, location.abovebar, cRev, size=size.small)
plotshape(rOrb and orbSizeIn == "Normal", "Reversal Orb Normal", shape.circle, location.abovebar, cRev, size=size.normal)
plotshape(rOrb and orbSizeIn == "Large",  "Reversal Orb Large",  shape.circle, location.abovebar, cRev, size=size.large)
plotshape(rOrb and orbSizeIn == "Huge",   "Reversal Orb Huge",   shape.circle, location.abovebar, cRev, size=size.huge)
if (isContSig or isRevSig) and showOrbs
    bool isRev = isRevSig
    color c    = isRev ? cRev : cCont
    float yPos = isRev ? high + atr * orbGap : low - atr * orbGap
    string chip = (isRev ? "▼ REVERSAL " : "▲ CONTINUATION ") + str.tostring(math.round((isRev ? pReversal : 1 - pReversal) * 100)) + "%" + (showNeighbor ? "\nk " + str.tostring(nContrib) + " · conf " + str.tostring(math.round(confidence * 100)) + "%" : "")
    label.new(bar_index, yPos, chip, style=isRev ? label.style_label_down : label.style_label_up, color=color.new(c, 10), textcolor=#0D1117, size=size.small)
alertcondition(isContSig, "Continuation Signal", "Strong KNN: high-confidence CONTINUATION near structure")
alertcondition(isRevSig,  "Reversal Signal",     "Strong KNN: high-confidence REVERSAL near structure")
alertcondition(isContSig or isRevSig, "Any Signal", "Strong KNN: new high-confidence classification")
dPos = switch dashPos
    "Top Left"      => position.top_left
    "Bottom Right"  => position.bottom_right
    "Bottom Left"   => position.bottom_left
    "Middle Right"  => position.middle_right
    => position.top_right
dSz = switch dashSize
    "Tiny"   => size.tiny
    "Small"  => size.small
    => size.normal
var table dash = table.new(dPos, 2, 16, bgcolor=cBgDark, border_color=color.new(#30363D, 20), border_width=1, frame_color=color.new(#30363D, 40), frame_width=1)
f_cell(int col, int row, string txt, color tc, color bg) =>
    table.cell(dash, col, row, txt, text_color=tc, text_size=dSz, bgcolor=bg, text_halign=col == 0 ? text.align_left : text.align_right)
f_featRow(int row, string name, float zval) =>
    color fc = zval > 0.25 ? cCont : zval < -0.25 ? cRev : cNeut
    f_cell(0, row, name, cTxtMut, cBgPanel)
    f_cell(1, row, str.tostring(zval, "#.##") + "σ", fc, cBgDark)
if showDash and barstate.islast
    f_cell(0, 0, "Strong KNN Classifier", cAcc, cBgHdr)
    f_cell(1, 0, timeframe.period + " · [Atlas]", cTxtMut, cBgHdr)
    string statusTxt = not poolReady ? "TRAINING…" : "LIVE"
    color  statusCol = not poolReady ? cNeut : cCont
    f_cell(0, 1, "Status", cTxtMut, cBgPanel)
    f_cell(1, 1, statusTxt + "  " + str.tostring(poolSize) + "/" + str.tostring(maxPool), statusCol, cBgDark)
    f_cell(0, 2, "OF Source", cTxtMut, cBgPanel)
    f_cell(1, 2, (ltfAvailable ? "Reconstructed " : "Bar-fallback ") + ltfPeriod + "m", ltfAvailable ? cTxtWht : cNeut, cBgDark)
    f_cell(0, 3, "── Features (z) ──", cTxtMut, cBgPanel)
    f_cell(1, 3, "", cTxtMut, cBgDark)
    f_featRow(4, "Net Delta",    f1)
    f_featRow(5, "Imbalance",    f2)
    f_featRow(6, "Absorption",   f3)
    f_featRow(7, "CVD Slope",    f4)
    f_featRow(8, "Loc vs VWAP",  f5)
    f_cell(0, 9, "── Classification ──", cTxtMut, cBgPanel)
    f_cell(1, 9, "", cTxtMut, cBgDark)
    string clsTxt = not poolReady ? "—" : predClass == REV ? "▼ REVERSAL" : predClass == CONT ? "▲ CONTINUATION" : "— NEUTRAL"
    color  clsCol = predClass == REV ? cRev : predClass == CONT ? cCont : cNeut
    f_cell(0, 10, "Prediction", cTxtMut, cBgPanel)
    f_cell(1, 10, clsTxt, clsCol, cBgDark)
    f_cell(0, 11, "Reversal Prob", cTxtMut, cBgPanel)
    f_cell(1, 11, poolReady ? str.tostring(math.round(pReversal * 100)) + "%" : "—", pReversal > 0.5 ? cRev : cCont, cBgDark)
    color cfCol = confidence >= confThr ? cCont : confidence >= confThr * 0.6 ? cNeut : cRev
    f_cell(0, 12, "Confidence", cTxtMut, cBgPanel)
    f_cell(1, 12, poolReady ? str.tostring(math.round(confidence * 100)) + "%" : "—", cfCol, cBgDark)
    f_cell(0, 13, "Neighbours", cTxtMut, cBgPanel)
    f_cell(1, 13, poolReady ? str.tostring(nContrib) + "/" + str.tostring(kNeighbors) : "—", cTxtWht, cBgDark)
    f_cell(0, 14, "In Zone", cTxtMut, cBgPanel)
    f_cell(1, 14, inZone ? (nearVWAP ? "VWAP" : "Pivot") : "—", inZone ? cAcc : cNeut, cBgDark)
    color accCol = na(liveAcc) ? cNeut : liveAcc >= 55 ? cCont : liveAcc >= 45 ? cNeut : cRev
    f_cell(0, 15, "Hit-Rate (" + str.tostring(totalN) + ")", cTxtMut, cBgPanel)
    f_cell(1, 15, na(liveAcc) ? "—" : str.tostring(liveAcc, "#.#") + "%", accCol, cBgDark)
````
