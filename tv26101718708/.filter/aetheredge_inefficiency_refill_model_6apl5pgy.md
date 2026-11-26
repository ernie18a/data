# AetherEdge - Inefficiency Refill Model

- url: https://www.tradingview.com/script/6ApL5pgy/
- type: indicator
- pine_id: PUB;4ee55762713d444ab89ef601569ea931
- version: 1.0

## Description

🖊️ Overview

AE-IRM detects inefficient price moves made on thin volume — "voids" — and learns the probability that they are refilled (mean-revert) along with how long that takes. Many tools merely flag voids; AE-IRM answers "will it refill, and when?" with two learning layers. Surges and drops without participation tend statistically to be retraced, and this quantifies that probability and timing.

🔶 Key Features

A void oscillator that emphasizes low-participation inefficient moves (amplifies below-average-volume moves)
A learned refill probability — online logistic learns P(refill within N bars) from realized outcomes
A survival model — estimates timing (median bars-to-fill, average fill latency) from hazards
Fade (mean-reversion) signals: buy-side void → SHORT, sell-side void → LONG
A gold HUD showing void side, refill probability, median/average fill bars, pending voids, regime
Voids resolve on realized price — no repaint, signals gate on bar close

🧠 Technical Architecture

Void detection: standardized log-return retZ is multiplied by 1 if volume is below average and by a fade factor otherwise, giving osc. When |osc| exceeds a threshold a "void event" fires. The refill target (origin) is the price a few bars before the move departed.
Refill probability (ML): six features — void magnitude, participation shortfall, move extremeness, efficiency ratio (range/trend), volatility regime, and distance to origin (ATR) — are standardized online (EWMA), and an online logistic regression learns P(refill). Each void is trained at resolution with its realized label (filled, or censored at N bars) — no lookahead.
Survival (hazard / Kaplan-Meier-style): each pending void is tracked; at resolution a life table over age buckets (reached/filled) is updated. Per-bucket hazard h = filled/reached builds a survival curve S = Π(1 − h), and the age at which cumulative fill probability reaches 50% is the median bars-to-fill. Censored voids (unfilled at N) are correctly counted in the risk set.
Honest scope: a linear logistic classifier plus a nonparametric survival estimate. Not deep learning, and not a guarantee of refill.

⚙️ Recommended Settings & Tuning Guide

Key parameters: void threshold (thr), fade factor, displacement lookback (vLook), age bucket width × count (= refill horizon N), minimum refill probability (probThr).
Raise thr → only strong inefficiencies (fewer, higher quality); lower → more detections
Lower the fade factor → stricter thin-volume condition (more strongly excludes moves on volume)
Set the refill horizon N (= bucket width × count) to the timeframe you expect reversion over
Crypto starting points (tune on your chart):
BTC / ETH (15m–1H): defaults are the baseline (thr 2.0, fade 0.3, N = 40 bars)
SOL / XRP and high-vol alts: thr 2.5 to filter noisy voids, fade 0.2 to tighten the thin-volume condition
Scalping (1–5m): bucket width ~3 for a shorter N, targeting immediate retraces
Swing (4H–daily): larger bucket width and longer N, raise warmup so the statistics fill out
Raising probThr narrows signals to voids the model finds more likely to refill

💡 How to Use in Practice

Fade (counter-trend): SHORT on a buy-side void (thin-volume surge), LONG on a sell-side void (thin-volume drop); higher refill probability = greater edge
Reading the probability: high refill probability = strong reversion expectation; low = the move may continue (trend continuation)
Timing: median/average fill bars are your take-profit guide — design exits around "fills in ~X bars"
Use the regime: in RANGE, refills work better; in TREND, voids may run without filling — read it alongside the HUD regime
Combinations: pair with AE-VECTOR's target band or AE-QUORUM's directional probability, and use IRM's probability and timing to judge whether to fade and how to size

⚠️ Important Notes

Learning period: no signals until warmup bars; the classifier and survival statistics need time to spin up
Learning reset: changing inputs, symbol, or timeframe re-learns the internal state (weights and hazards)
Probability, not a guarantee: in strong trends voids can stay unfilled (censored) for a long time — avoid fading low-probability voids
Oscillator only: it does not draw void zones on price — operate from the signals and the HUD's probability and timing

🚨 Disclaimer

This indicator is for educational and informational purposes only and is not financial advice or a recommendation to buy or sell. No method guarantees future profits; past performance does not indicate future results, and trading carries the risk of loss. All trading decisions are your own — use proper backtesting and disciplined risk management.

## Source Code

````pine
// ============================================================================
//  AetherEdge - Inefficiency Refill Model  (AE-IRM)  |  AetherEdge Series
//  Inefficiency "void" oscillator with a learned refill probability + survival
//  timing
//
//  A large price move on thin volume is an inefficient displacement -- a
//  liquidity "void" that statistically tends to be refilled (mean-revert).
//  Detecting the void is the easy part; AE-IRM adds two genuinely-implemented
//  learning layers that answer "will it refill, and when?":
//
//    * ML  : an ONLINE LOGISTIC REGRESSION learns P(the void is refilled within
//      N bars) from void magnitude, participation shortfall, regime, distance,
//      and volatility -- replacing a fixed "low-volume = revert" heuristic with
//      a probability trained on realized refills (no lookahead).
//
//    * Survival : an online discrete-time HAZARD / SURVIVAL model
//      (Kaplan-Meier-style life table over age buckets) estimates the refill
//      timing -- median bars-to-fill and a running survival curve, updated as
//      each void resolves or is censored.
//
//  Honest scope: a linear classifier + a nonparametric survival estimate. Not a
//  neural net, not a guarantee. No-repaint: voids resolve on realized price,
//  signals gate on barstate.isconfirmed.
// ============================================================================

//@version=6
indicator("AetherEdge - Inefficiency Refill Model", "AE-IRM", overlay = false, max_labels_count = 200)

// ----------------------------------------------------------------------------
//  THEME / PALETTE  (AetherEdge gold-frame HUD)
// ----------------------------------------------------------------------------
cGold    = #d4af37
cBg0     = #080b0a
cBg1     = #0f1614
cTxt     = #eef2f0
cBull    = #26a69a
cBear    = #ef5350
cWait    = #8d99a6

// ----------------------------------------------------------------------------
//  INPUTS
// ----------------------------------------------------------------------------
grpV = "Void detection"
atrLen  = input.int(14, "ATR length", minval = 1, group = grpV)
rLen    = input.int(20, "Return z-score length", minval = 2, group = grpV)
volLen  = input.int(20, "Volume baseline length", minval = 2, group = grpV)
fadeF   = input.float(0.30, "High-volume fade", minval = 0.0, maxval = 1.0, step = 0.05, group = grpV, tooltip = "Moves on above-average volume are de-emphasized by this factor (1 = no fade).")
thr     = input.float(2.0, "Void threshold", minval = 0.5, step = 0.1, group = grpV)
vLook   = input.int(3, "Displacement lookback", minval = 1, group = grpV, tooltip = "The void's origin (fill target) is the price this many bars before the move.")
erLen   = input.int(20, "Efficiency-ratio length", minval = 2, group = grpV)

grpM = "Refill classifier"
lr      = input.float(0.02, "Learning rate", minval = 0.0001, step = 0.005, group = grpM)
l2      = input.float(0.0005, "L2 regularization", minval = 0.0, step = 0.0005, group = grpM)
ewmaA   = input.float(0.02, "Standardization EWMA", minval = 0.001, maxval = 0.5, step = 0.005, group = grpM)
warmup  = input.int(150, "Warmup bars", minval = 20, group = grpM)

grpSv = "Survival timing"
bucketW  = input.int(5, "Age bucket width (bars)", minval = 1, group = grpSv)
nBuckets = input.int(8, "Number of buckets", minval = 2, maxval = 16, group = grpSv, tooltip = "Refill horizon N = bucket width x number of buckets. Beyond N a void is treated as censored (not refilled).")

grpS = "Signals"
probThr = input.float(0.55, "Min refill probability", minval = 0.5, maxval = 0.95, step = 0.01, group = grpS)

grpUI = "Dashboard"
showHUD = input.bool(true, "Show HUD", group = grpUI)
hudSize = input.string("normal", "HUD size", options = ["tiny","small","normal","large"], group = grpUI)

// ----------------------------------------------------------------------------
//  HELPERS
// ----------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))
f_sigmoid(float z) => 1.0 / (1.0 + math.exp(-f_clamp(z, -30.0, 30.0)))

f_statsUpdate(array<float> mean, array<float> varr, array<float> x, float a) =>
    for i = 0 to array.size(x) - 1
        v  = array.get(x, i)
        m0 = array.get(mean, i)
        m1 = m0 + a * (v - m0)
        d  = v - m1
        vr = (1.0 - a) * (array.get(varr, i) + a * d * d)
        array.set(mean, i, m1)
        array.set(varr, i, vr)

f_standardize(array<float> x, array<float> mean, array<float> varr) =>
    out = array.new_float(0)
    for i = 0 to array.size(x) - 1
        sd = math.sqrt(math.max(array.get(varr, i), 1e-10))
        array.push(out, f_clamp((array.get(x, i) - array.get(mean, i)) / sd, -6.0, 6.0))
    out

f_predict(array<float> w, array<float> x) =>
    z = array.get(w, 0)
    for i = 0 to array.size(x) - 1
        z += array.get(w, i + 1) * array.get(x, i)
    f_sigmoid(z)

f_train(array<float> w, array<float> x, float y, float lrr, float l2r) =>
    p   = f_predict(w, x)
    err = p - y
    array.set(w, 0, array.get(w, 0) - lrr * err)
    for i = 0 to array.size(x) - 1
        g = err * array.get(x, i) + l2r * array.get(w, i + 1)
        array.set(w, i + 1, array.get(w, i + 1) - lrr * g)

// ----------------------------------------------------------------------------
//  TYPES
// ----------------------------------------------------------------------------
type Void
    bool         dirUp        // true = up-move void (expect refill DOWN to origin)
    float        origin       // fill target (price before the displacement)
    int          bornBar
    array<float> feat         // standardized feature snapshot at the event

// ----------------------------------------------------------------------------
//  VOID OSCILLATOR
// ----------------------------------------------------------------------------
int NF = 6
int maxAge = bucketW * nBuckets

atr     = ta.atr(atrLen)
atrSafe = math.max(nz(atr, nz(ta.tr, close * 0.001)), 1e-8)

r1     = nz(math.log(close / math.max(close[1], 1e-10)))
retMu  = ta.sma(r1, rLen)
retSd  = math.max(ta.stdev(r1, rLen), 1e-10)
retZ   = (r1 - retMu) / retSd

volMa  = ta.sma(volume, volLen)
lowVol = volume < volMa
weight = lowVol ? 1.0 : fadeF
osc    = retZ * weight                              // void oscillator (signed)

pathLen = math.max(math.sum(math.abs(close - close[1]), erLen), 1e-8)
erEff   = f_clamp(math.abs(close - close[erLen]) / pathLen, 0.0, 1.0)

origin = close[vLook]                               // fill target
voidUp = ta.crossover(osc, thr)                     // up-displacement on low volume -> buy-side void
voidDn = ta.crossunder(osc, -thr)                   // down-displacement -> sell-side void
voidEvt = voidUp or voidDn

// ----------------------------------------------------------------------------
//  FEATURES  (raw -> EWMA-standardized)
// ----------------------------------------------------------------------------
rx1 = nz(math.abs(osc))                                                  // void magnitude
rx2 = nz(f_clamp(1.0 - volume / math.max(volMa, 1e-8), -1.0, 2.0))       // participation shortfall
rx3 = nz(math.abs(retZ))                                                 // move extremeness
rx4 = nz(erEff)                                                          // regime (low = range -> more refills)
rx5 = nz(f_clamp(atrSafe / math.max(ta.sma(atrSafe, 50), 1e-8), 0.0, 3.0))   // volatility regime
rx6 = nz(f_clamp(math.abs(close - origin) / atrSafe, 0.0, 10.0))         // distance to refill (ATR)

var array<float> wRef  = array.new_float(NF + 1, 0.0)
var array<float> fMean = array.new_float(NF, 0.0)
var array<float> fVar  = array.new_float(NF, 1.0)

xRaw = array.from(rx1, rx2, rx3, rx4, rx5, rx6)
if barstate.isconfirmed
    f_statsUpdate(fMean, fVar, xRaw, ewmaA)
xStd = f_standardize(xRaw, fMean, fVar)

pRefill = f_predict(wRef, xStd)                     // P(refill within N) for a void forming now

// ----------------------------------------------------------------------------
//  PENDING VOIDS  +  RESOLUTION  (trains the classifier and the survival model)
// ----------------------------------------------------------------------------
var array<Void> pend = array.new<Void>()
var array<int> reached = array.new_int(nBuckets, 0)
var array<int> filled  = array.new_int(nBuckets, 0)
var float ewmaFill = na                              // EWMA of realized fill latency (bars)

// Register a new void on the event bar.
if barstate.isconfirmed and voidEvt
    array.push(pend, Void.new(dirUp = voidUp, origin = origin, bornBar = bar_index, feat = array.copy(xStd)))

// Resolve pending voids: fill (label 1) or censor at maxAge (label 0).
if barstate.isconfirmed and array.size(pend) > 0
    for i = array.size(pend) - 1 to 0
        v = array.get(pend, i)
        age = bar_index - v.bornBar
        isFill = v.dirUp ? (low <= v.origin) : (high >= v.origin)
        if isFill
            bf = math.min(age / bucketW, nBuckets - 1)
            for b = 0 to bf
                array.set(reached, b, array.get(reached, b) + 1)
            array.set(filled, bf, array.get(filled, bf) + 1)
            ewmaFill := na(ewmaFill) ? age : ewmaFill + 0.1 * (age - ewmaFill)
            f_train(wRef, v.feat, 1.0, lr, l2)
            array.remove(pend, i)
        else if age >= maxAge
            for b = 0 to nBuckets - 1
                array.set(reached, b, array.get(reached, b) + 1)
            f_train(wRef, v.feat, 0.0, lr, l2)
            array.remove(pend, i)

// Survival curve -> median bars-to-fill.
float surv = 1.0
float medFill = na
for b = 0 to nBuckets - 1
    h = array.get(filled, b) / math.max(array.get(reached, b), 1)
    surv *= (1.0 - h)
    if na(medFill) and (1.0 - surv) >= 0.5
        medFill := (b + 1) * bucketW

// ----------------------------------------------------------------------------
//  SIGNALS  (fade the void toward its origin; no-repaint)
// ----------------------------------------------------------------------------
warmOK = bar_index > warmup
longSig  = barstate.isconfirmed and warmOK and voidDn and pRefill > probThr   // sell-side void -> expect refill UP
shortSig = barstate.isconfirmed and warmOK and voidUp and pRefill > probThr   // buy-side void -> expect refill DOWN

// Persisted "last void" for the HUD.
var string lastSide = "-"
var float  lastP    = 0.0
if voidUp
    lastSide := "BUY-SIDE"
    lastP := pRefill
if voidDn
    lastSide := "SELL-SIDE"
    lastP := pRefill

// ----------------------------------------------------------------------------
//  PLOTS  (oscillator pane)
// ----------------------------------------------------------------------------
oscCol = osc > 0 ? color.new(cBull, 30) : color.new(cBear, 30)
plot(osc, "Void oscillator", color = oscCol, style = plot.style_columns)
hline(0, "Mid", color = color.new(cWait, 50))
hline(thr,  "Upper", color = color.new(cBull, 60), linestyle = hline.style_dotted)
hline(-thr, "Lower", color = color.new(cBear, 60), linestyle = hline.style_dotted)

plotshape(longSig,  title = "Refill Long",  style = shape.triangleup,   location = location.bottom, color = cBull, size = size.small, text = "LONG",  textcolor = cBull)
plotshape(shortSig, title = "Refill Short", style = shape.triangledown, location = location.top,    color = cBear, size = size.small, text = "SHORT", textcolor = cBear)
plotshape(voidEvt and not longSig and not shortSig, title = "Void", style = shape.circle, location = location.top, color = color.new(cGold, 40), size = size.tiny)

// ----------------------------------------------------------------------------
//  HUD DASHBOARD  (gold frame)
// ----------------------------------------------------------------------------
f_txtSize() => hudSize == "tiny" ? size.tiny : hudSize == "small" ? size.small : hudSize == "large" ? size.large : size.normal

sideCol = lastSide == "BUY-SIDE" ? cBull : lastSide == "SELL-SIDE" ? cBear : cWait

var table hud = table.new(position.top_right, 2, 9, bgcolor = cBg1, frame_color = cGold, frame_width = 2, border_color = color.new(cGold, 60), border_width = 1)

if showHUD and barstate.islast
    ts = f_txtSize()
    table.cell(hud, 0, 0, "AE-IRM", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 0, "VOID + REFILL", text_color = cWait, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 0, 1, "Void osc",   text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 1, str.tostring(osc, "#.##"), text_color = osc >= 0 ? cBull : cBear, text_size = ts)
    table.cell(hud, 0, 2, "Last void",  text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 2, lastSide,     text_color = sideCol, text_size = ts)
    table.cell(hud, 0, 3, "Refill prob",text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 3, str.tostring(math.round(lastP * 100)) + "%", text_color = lastP >= probThr ? cBull : cTxt, text_size = ts)
    table.cell(hud, 0, 4, "Median fill",text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 4, na(medFill) ? ">" + str.tostring(maxAge) : str.tostring(medFill) + " bars", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 5, "Avg fill",   text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 5, na(ewmaFill) ? "-" : str.tostring(math.round(ewmaFill)) + " bars", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 6, "Pending",    text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 6, str.tostring(array.size(pend)), text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 7, "Regime",     text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 7, erEff < 0.3 ? "RANGE" : erEff > 0.6 ? "TREND" : "MIXED", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 8, "Model",      text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 8, warmOK ? "live" : "learning", text_color = warmOK ? cBull : cWait, bgcolor = cBg0, text_size = ts)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
alertcondition(longSig,  "AE-IRM Refill Long",  "AE-IRM sell-side void, refill up expected")
alertcondition(shortSig, "AE-IRM Refill Short", "AE-IRM buy-side void, refill down expected")
alertcondition(voidEvt,  "AE-IRM Void",         "AE-IRM inefficiency void detected")

if longSig
    alert("AE-IRM LONG | refill " + str.tostring(math.round(pRefill * 100)) + "% | ~" + (na(medFill) ? "?" : str.tostring(medFill)) + " bars", alert.freq_once_per_bar_close)
if shortSig
    alert("AE-IRM SHORT | refill " + str.tostring(math.round(pRefill * 100)) + "% | ~" + (na(medFill) ? "?" : str.tostring(medFill)) + " bars", alert.freq_once_per_bar_close)
````
