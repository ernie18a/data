# AetherEdge - Flow Anomaly Markov

- url: https://www.tradingview.com/script/cEvBEkmc/
- type: indicator
- pine_id: PUB;6f20c5419021436bb8e5d69cac41de45
- version: 1.0

## Description

🖊️ Overview

AE-FAM detects abnormal large-participant activity statistically and forecasts what follows (continuation or reversal) with a learned Markov chain. Abnormal large activity can't be captured by a fixed volume threshold — what is abnormal depends on the joint distribution of volume and price movement, and that drifts over time. AE-FAM detects it adaptively with a 2D Mahalanobis distance and answers, via a conditional Markov chain, "after this kind of event, what has the market actually done?"

🔶 Key Features

2D Mahalanobis-distance anomaly detection — judges joint volume/movement anomalies against the recent covariance (not a fixed threshold)
Conditional Markov chain — learns 5-state transition probabilities online, modeled separately for anomaly vs normal bars
Post-event continuation / reversal probabilities and an expected-direction score
The same event reads as continuation or trap depending on the learned transitions
Anomaly-bar background highlight, bull/bear anomaly markers, and BUY/SELL signals from the expected direction
A gold HUD with Mahalanobis D², event type, current state, continuation/reversal %, expected score, and predicted next state
Stats and transitions update on closed bars — no repaint

🧠 Technical Architecture

Anomaly (Mahalanobis): the mean vector and 2×2 covariance of features [log(volume), |range|/ATR] are estimated online by EWMA, and each bar's Mahalanobis distance D² is computed with a closed-form 2×2 inverse (no matrix library). When D² exceeds a threshold and volume is above average, it is an "anomaly event"; direction is the return sign (bull/bear).
States (5 buckets): the return z-score is discretized into strong-down / down / flat / up / strong-up.
Markov chain (ML): a first-order Markov chain's transition counts (2×5×5 = [anomaly?][from][to]) are tallied online with a Laplace prior and aged by a decay factor for adaptation. The current state's transition row (conditioned on the current anomaly status) is normalized into a next-state distribution; the expected-direction score = Σ (state value) × probability, with continuation/reversal probabilities from the same row.
Honest scope: Mahalanobis anomaly detection plus a count-based first-order Markov chain. Not deep learning, and not a guarantee of the future.

⚙️ Recommended Settings & Tuning Guide

Key parameters: anomaly threshold (D²), covariance EWMA, transition memory (decay), expected-score threshold (thrScore), warmup.
Raise the D² threshold → only rarer, more extreme events (~9 is a strong 2-DoF outlier)
Raise the covariance EWMA → faster-adapting distribution estimate; lower → steadier
Lower decay → adapts faster to recent transition behavior; 1.0 → never forgets
Crypto starting points (tune on your chart):
BTC / ETH (15m–1H): defaults are the baseline (D² 9, decay 0.999)
SOL / XRP and high-vol alts: raise the D² threshold to ~11 to exclude noisy spikes
Scalping (1–5m): raise covariance EWMA (0.05) for fast adaptation, decay 0.995
Swing (4H–daily): longer warmup to fill the transition statistics, decay 1.0 to learn long-run tendencies
Raising thrScore narrows signals to events where the Markov expected direction is clear

💡 How to Use in Practice

Read intent: bull anomaly + high continuation = accumulation (follow), bull anomaly + high reversal = possible trap / liquidity grab (consider fading)
Expected-direction score: sign is the bias, magnitude the confidence; signals fire when this score and an anomaly event agree
Continuation/reversal %: quantifies the post-event tone — trend-follow when continuation dominates, stay cautious when reversal does
Mode display: post-event (just after an anomaly) vs normal switches which transition model is being read
Combinations: pair with AE-AMF's big-picture momentum or AE-IRM's mean-reversion probability, and use FAM's anomaly + transition forecast to judge entry quality

⚠️ Important Notes

Learning period: no signals until warmup bars; the covariance and transition matrix need time to spin up
Learning reset: changing inputs, symbol, or timeframe re-learns the internal state (covariance and transition counts)
Probability, not a guarantee: the Markov model is first-order (depends only on the latest state) and simple — it cannot capture complex dependencies
Depends on rare events: anomalies are rare, so a given state×anomaly transition statistic can be coarse until it accumulates

🚨 Disclaimer

This indicator is for educational and informational purposes only and is not financial advice or a recommendation to buy or sell. No method guarantees future profits; past performance does not indicate future results, and trading carries the risk of loss. All trading decisions are your own — use proper backtesting and disciplined risk management.

## Source Code

````pine
// ============================================================================
//  AetherEdge - Flow Anomaly Markov  (AE-FAM)  |  AetherEdge Series
//  Statistical large-participant anomaly detection + a learned Markov forecast
//
//  Large-participant activity is not a fixed volume threshold -- what
//  is abnormal depends on the joint distribution of volume and price movement,
//  which drifts over time. AE-FAM detects it statistically and then tells you
//  what tends to happen next:
//
//    * Anomaly : an online 2D MAHALANOBIS-DISTANCE detector over
//      (log-volume, move size) flags bars that are jointly abnormal given the
//      recent covariance -- adapting as the regime changes (closed-form 2x2
//      inverse, no linear-algebra library).
//
//    * Markov : an online first-order MARKOV CHAIN over 5 momentum states
//      learns the transition probabilities, conditioned on whether the prior
//      bar was an anomaly. After an event it forecasts the next-state
//      distribution, so the SAME large print reads as continuation or trap
//      depending on what the data has actually done.
//
//  An expected-direction score from the forecast drives signals. Honest scope:
//  Mahalanobis anomaly + a count-based Markov chain -- not a neural net, not a
//  guarantee. No-repaint: stats/transitions use closed bars, signals gate on
//  barstate.isconfirmed.
// ============================================================================

//@version=6
indicator("AetherEdge - Flow Anomaly Markov", "AE-FAM", overlay = true, max_labels_count = 200)

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
grpA = "Anomaly detection"
atrLen   = input.int(14, "ATR length", minval = 1, group = grpA)
covA     = input.float(0.02, "Covariance EWMA", minval = 0.001, maxval = 0.5, step = 0.005, group = grpA, tooltip = "Adaptation speed of the volume/movement distribution used for the Mahalanobis score.")
thrD     = input.float(9.0, "Anomaly threshold (Mahalanobis D-squared)", minval = 2.0, step = 0.5, group = grpA, tooltip = "Higher = rarer, more extreme events. ~9 is a strong 2-DoF outlier.")

grpS = "Market states"
rLen     = input.int(14, "Return z-score length", minval = 2, group = grpS)

grpMk = "Markov forecast"
decay    = input.float(0.999, "Transition memory (decay)", minval = 0.95, maxval = 1.0, step = 0.001, group = grpMk, tooltip = "Lower = adapts faster to recent transition behavior. 1.0 = never forgets.")
warmup   = input.int(150, "Warmup bars", minval = 20, group = grpMk)

grpSig = "Signals"
thrScore = input.float(0.5, "Min expected-direction score", minval = 0.0, maxval = 2.0, step = 0.1, group = grpSig)

grpV = "Visual"
showAnom = input.bool(true, "Mark anomaly events", group = grpV)
tintBars  = input.bool(true, "Tint anomaly bars", group = grpV)

grpUI = "Dashboard"
showHUD = input.bool(true, "Show HUD", group = grpUI)
hudSize = input.string("normal", "HUD size", options = ["tiny","small","normal","large"], group = grpUI)

// ----------------------------------------------------------------------------
//  HELPERS
// ----------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))
f_stateTxt(int s) => s == 0 ? "STRONG DN" : s == 1 ? "DOWN" : s == 2 ? "FLAT" : s == 3 ? "UP" : "STRONG UP"
f_idx(int w, int f, int t) => w * 25 + f * 5 + t

// ----------------------------------------------------------------------------
//  ANOMALY DETECTION  (online 2D Mahalanobis on log-volume & move size)
// ----------------------------------------------------------------------------
atr     = ta.atr(atrLen)
atrSafe = math.max(nz(atr, nz(ta.tr, close * 0.001)), 1e-8)

a1 = math.log(volume + 1.0)                         // participation
a2 = nz(math.abs(close - close[1]) / atrSafe)       // move size (ATR units)

var float m1 = na
var float m2 = na
var float vx = 1.0
var float vy = 1.0
var float cxy = 0.0
if na(m1)
    m1 := a1
    m2 := a2

// Mahalanobis D^2 using stats from prior bars (closed-form 2x2 inverse).
d1  = a1 - m1
d2  = a2 - m2
det = math.max(vx * vy - cxy * cxy, 1e-8)
Dsq = (d1 * d1 * vy - 2.0 * d1 * d2 * cxy + d2 * d2 * vx) / det

// Online EWMA update of mean vector and covariance.
if barstate.isconfirmed
    m1n = m1 + covA * (a1 - m1)
    m2n = m2 + covA * (a2 - m2)
    e1 = a1 - m1n
    e2 = a2 - m2n
    vx  := (1.0 - covA) * (vx + covA * e1 * e1)
    vy  := (1.0 - covA) * (vy + covA * e2 * e2)
    cxy := (1.0 - covA) * (cxy + covA * e1 * e2)
    m1  := m1n
    m2  := m2n

ret      = nz(close - close[1])
anomEvt = Dsq > thrD and d1 > 0                    // jointly abnormal AND high participation
anomBull = anomEvt and ret > 0
anomBear = anomEvt and ret < 0

// ----------------------------------------------------------------------------
//  MARKET STATE  (5 momentum buckets)
// ----------------------------------------------------------------------------
r1   = nz(close - close[1])
retMu = ta.sma(r1, rLen)
retSd = math.max(ta.stdev(r1, rLen), 1e-10)
retZ  = (r1 - retMu) / retSd
int state = retZ < -1.5 ? 0 : retZ < -0.5 ? 1 : retZ <= 0.5 ? 2 : retZ <= 1.5 ? 3 : 4

// ----------------------------------------------------------------------------
//  MARKOV CHAIN  (2 x 5 x 5 transition counts: [anomaly?][from][to])
// ----------------------------------------------------------------------------
var array<float> tr = array.new_float(2 * 5 * 5, 1.0)   // Laplace prior
var int  prevState = na
var bool prevAnom = false

if barstate.isconfirmed
    for k = 0 to 49
        array.set(tr, k, array.get(tr, k) * decay)
    if not na(prevState)
        w = prevAnom ? 1 : 0
        id = f_idx(w, prevState, state)
        array.set(tr, id, array.get(tr, id) + 1.0)
    prevState := state
    prevAnom := anomEvt

// Forecast next-state distribution from the current state, conditioned on now.
int wNow = anomEvt ? 1 : 0
float rowSum = 0.0
for t = 0 to 4
    rowSum += array.get(tr, f_idx(wNow, state, t))
rowSum := math.max(rowSum, 1e-8)

float expScore = 0.0
float pUp = 0.0
float pDn = 0.0
int   nextState = 2
float nextP = -1.0
for t = 0 to 4
    p = array.get(tr, f_idx(wNow, state, t)) / rowSum
    expScore += (t - 2) * p
    if t > 2
        pUp += p
    if t < 2
        pDn += p
    if p > nextP
        nextP := p
        nextState := t

// Continuation vs reversal relative to current momentum side.
curSide = state - 2
contProb = curSide > 0 ? pUp : curSide < 0 ? pDn : math.max(pUp, pDn)
revProb  = curSide > 0 ? pDn : curSide < 0 ? pUp : 0.0

// ----------------------------------------------------------------------------
//  SIGNALS  (no-repaint)
// ----------------------------------------------------------------------------
warmOK   = bar_index > warmup
longSig  = barstate.isconfirmed and warmOK and anomEvt and expScore > thrScore
shortSig = barstate.isconfirmed and warmOK and anomEvt and expScore < -thrScore

// ----------------------------------------------------------------------------
//  VISUALS  (overlay)
// ----------------------------------------------------------------------------
bgcolor(tintBars and anomEvt ? color.new(cGold, 88) : na, title = "Anomaly tint")

plotshape(showAnom and anomBull, title = "Bull anomaly", style = shape.circle, location = location.belowbar, color = color.new(cBull, 20), size = size.tiny)
plotshape(showAnom and anomBear, title = "Bear anomaly", style = shape.circle, location = location.abovebar, color = color.new(cBear, 20), size = size.tiny)

plotshape(longSig,  title = "Long",  style = shape.triangleup,   location = location.belowbar, color = cBull, size = size.small, text = "BUY",  textcolor = cBull)
plotshape(shortSig, title = "Short", style = shape.triangledown, location = location.abovebar, color = cBear, size = size.small, text = "SELL", textcolor = cBear)

// ----------------------------------------------------------------------------
//  HUD DASHBOARD  (gold frame)
// ----------------------------------------------------------------------------
f_txtSize() => hudSize == "tiny" ? size.tiny : hudSize == "small" ? size.small : hudSize == "large" ? size.large : size.normal

anomTxt = anomBull ? "BULL" : anomBear ? "BEAR" : "none"
anomCol = anomBull ? cBull : anomBear ? cBear : cWait
scoreCol = expScore > 0 ? cBull : expScore < 0 ? cBear : cWait

var table hud = table.new(position.top_right, 2, 10, bgcolor = cBg1, frame_color = cGold, frame_width = 2, border_color = color.new(cGold, 60), border_width = 1)

if showHUD and barstate.islast
    ts = f_txtSize()
    table.cell(hud, 0, 0, "AE-FAM", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 0, "ANOMALY + MARKOV", text_color = cWait, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 0, 1, "Anomaly",   text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 1, str.tostring(Dsq, "#.#"), text_color = anomEvt ? cGold : cTxt, text_size = ts)
    table.cell(hud, 0, 2, "Event",     text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 2, anomTxt,    text_color = anomCol, text_size = ts)
    table.cell(hud, 0, 3, "State",     text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 3, f_stateTxt(state), text_color = curSide > 0 ? cBull : curSide < 0 ? cBear : cWait, text_size = ts)
    table.cell(hud, 0, 4, "Continue",  text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 4, str.tostring(math.round(contProb * 100)) + "%", text_color = cBull, text_size = ts)
    table.cell(hud, 0, 5, "Reverse",   text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 5, str.tostring(math.round(revProb * 100)) + "%", text_color = cBear, text_size = ts)
    table.cell(hud, 0, 6, "Exp dir",   text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 6, str.tostring(expScore, "#.##"), text_color = scoreCol, text_size = ts)
    table.cell(hud, 0, 7, "Next state",text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 7, f_stateTxt(nextState) + " " + str.tostring(math.round(nextP * 100)) + "%", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 8, "Mode",      text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 8, anomEvt ? "post-event" : "normal", text_color = anomEvt ? cGold : cWait, text_size = ts)
    table.cell(hud, 0, 9, "Model",     text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 9, warmOK ? "live" : "learning", text_color = warmOK ? cBull : cWait, bgcolor = cBg0, text_size = ts)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
alertcondition(anomEvt, "AE-FAM Anomaly", "AE-FAM large-participant anomaly detected")
alertcondition(longSig,  "AE-FAM Long",    "AE-FAM anomaly with up forecast")
alertcondition(shortSig, "AE-FAM Short",   "AE-FAM anomaly with down forecast")

if longSig
    alert("AE-FAM BUY | D2 " + str.tostring(Dsq, "#.#") + " | exp " + str.tostring(expScore, "#.##"), alert.freq_once_per_bar_close)
if shortSig
    alert("AE-FAM SELL | D2 " + str.tostring(Dsq, "#.#") + " | exp " + str.tostring(expScore, "#.##"), alert.freq_once_per_bar_close)
````
