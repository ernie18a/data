# AetherEdge - HELM | Regime + RL Manager

- url: https://www.tradingview.com/script/P07r06gT/
- type: indicator
- pine_id: PUB;46d1e20d2acd405893ffacdc4abcce31
- version: 1.0

## Description

🖊️ Overview

AE-HELM is a regime-aware signal and trade manager that learns not just when to enter but how to hold. An online classifier labels the market as trending or ranging to shape the signal style, and on top of it a policy-gradient (REINFORCE) agent learns a target exposure — full, half, flat, or short — from realized P&L. Where most tools only emit entry signals, AE-HELM optimizes the trade management itself: sizing in, letting winners run, trimming, and exiting.

🔶 Key Features

Online logistic trend/range classification (P(trend)) that switches the signal's character automatically
A REINFORCE policy-gradient agent learning target exposure {-1, -0.5, 0, +0.5, +1} — automated trade management
Management markers for LONG / SHORT / ADD / TRIM / EXIT
An adaptive cloud colored by regime (distinct in trend vs range)
A gold-framed HUD showing regime, stance, exposure, conviction, and average reward (learning health)
Deterministic exploration (identical across reloads) → no repaint; labels use the K-bar-lagged realized efficiency ratio

🧠 Technical Architecture

Regime classifier: a meta logistic model P(trend) trained by SGD on efficiency ratio (Kaufman ER), ADX, Bollinger bandwidth ratio, and ATR regime. The label is "realized ER over the next K bars > threshold" — the current read uses no future data.
REINFORCE manager: for a state s = [held exposure, momentum, regime, range position, short return, volatility], a linear-softmax policy π(a|s) = softmax(θ·s/τ) assigns probabilities to five target exposures. Each bar samples an action and observes reward r = (held exposure × realized return − turnover cost). The policy updates by θ ← θ + lr·(r − baseline)·(1{a} − π)·s, with an EWMA baseline for variance reduction. Exploration is sampled from a deterministic bar-index hash, so it is reproducible.
Honest scope: a linear classifier plus a linear policy-gradient (REINFORCE) agent — not deep RL, not auto-trading, not a crystal ball. The displayed exposure is the learned manager's recommendation.

⚙️ Recommended Settings & Tuning Guide

Key parameters: erThr / regLabK (regime sensitivity), polLR (policy learning rate), tau (exploration temperature), turnCost (overtrading penalty), warmup.
Raise turnCost → fewer trades, more patient holding; lower → more agile exposure changes
Raise tau → more exploration; lower → more deterministic (lower is steadier once converged)
Crypto starting points (tune on your chart):
BTC / ETH (1H–4H): defaults are the baseline; shorten regLabK to 15 for faster regime reads
SOL / XRP and high-vol alts: turnCost ≈ 0.08 to curb churn on fakeouts; erThr = 0.45 to admit only genuine trends
Scalping (5–15m): polLR = 0.02 for fast adaptation; keep a proportionate warmup
Swing (daily): regLabK = 25–40, higher turnCost for steadier management
Warmup is the time the agent needs to learn — longer is steadier but delays activation

💡 How to Use in Practice

As a position map: use the stance (FULL/HALF/FLAT) and exposure value as an objective reference for your own sizing
ADD/TRIM: cues for sizing up in strong trends and trimming as momentum fades
Reading the regime: TREND favors trend-following; RANGE favors fading or patience — the cloud color shows the character
Average-reward panel: positive = the agent's policy is working in this market; near zero = thin edge, stay cautious
Multi-timeframe: stance from a higher-timeframe HELM, timing on a lower one
Combinations: use AE-QUORUM's ensemble probability or AE-KALMAN's velocity for the entry case, and let AE-HELM manage how you hold afterward

⚠️ Important Notes

Learning period: until the policy spins up (warmup bars) the stance is unsettled and the HUD shows "learning"; no signals fire meanwhile
Learning reset: changing inputs, symbol, or timeframe re-learns the policy and regime weights
It is management guidance, not auto-trading: the displayed exposure is the learned manager's suggestion; execution, sizing, and stops are your responsibility
It explores: the agent intentionally samples actions to learn, so it will sometimes deviate from the apparent optimal action

🚨 Disclaimer

This indicator is for educational and informational purposes only and is not financial advice or a recommendation to buy or sell. No method guarantees future profits; past performance does not indicate future results, and trading carries the risk of loss. All trading decisions are your own — use proper backtesting and disciplined risk management.

## Source Code

````pine
// ============================================================================
//  AE-HELM  |  AetherEdge Series
//  Regime-aware signal engine + self-learning trade manager (policy gradient)
//
//  Most signal toolkits only tell you when to ENTER. AE-HELM also learns how to
//  MANAGE the position. It couples two genuinely-implemented learning layers:
//
//    * ML (regime) : an online LOGISTIC REGRESSION that classifies the market
//      as trending vs ranging from efficiency / directional-strength / volatility
//      features. Labels are the realized Kaufman efficiency ratio over the next
//      K bars (no lookahead). Output = P(trend), which shapes the policy's state.
//
//    * RL (manager): a linear-softmax policy trained by REINFORCE (policy
//      gradient with an EWMA baseline) over a target-exposure action set
//      {-1, -0.5, 0, +0.5, +1}. It learns to size in, hold, trim, and exit from
//      realized, turnover-penalized reward -- i.e. it learns trade MANAGEMENT,
//      not just entries. Function-approximation policy, a step beyond tabular RL.
//
//  Exploration uses a deterministic hash (reproducible across reloads), so
//  closed bars never change. Honest scope: a linear classifier + linear
//  policy-gradient agent. Not deep RL, not a guarantee. Signals gate on
//  barstate.isconfirmed; labels are K-bar lagged.
// ============================================================================

//@version=6
indicator("AetherEdge - HELM | Regime + RL Manager", "AE-HELM", overlay = true, max_labels_count = 200)

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
grpR = "Regime classifier (trend vs range)"
atrLen  = input.int(14, "ATR length", minval = 1, group = grpR)
erLen   = input.int(20, "Efficiency-ratio length", minval = 2, group = grpR)
regLabK = input.int(20, "Regime label horizon", minval = 2, group = grpR, tooltip = "Bars ahead used to label trend vs range via the realized efficiency ratio (no lookahead for the current read).")
erThr   = input.float(0.40, "Trend efficiency threshold", minval = 0.05, maxval = 0.95, step = 0.05, group = grpR)
diLen   = input.int(14, "DMI length", minval = 1, group = grpR)
adxLen  = input.int(14, "ADX smoothing", minval = 1, group = grpR)
bbLen   = input.int(20, "Bandwidth length", minval = 2, group = grpR)
regLR   = input.float(0.02, "Regime learning rate", minval = 0.0001, step = 0.005, group = grpR)

grpP = "RL trade manager (REINFORCE)"
polLR   = input.float(0.01, "Policy learning rate", minval = 0.0001, step = 0.002, group = grpP)
tau     = input.float(1.0,  "Exploration temperature", minval = 0.1, step = 0.1, group = grpP, tooltip = "Higher = more exploration in the softmax policy.")
turnCost= input.float(0.05, "Turnover cost (ATR x)", minval = 0.0, step = 0.01, group = grpP, tooltip = "Penalty per unit of exposure change, so the agent learns not to over-trade.")
baseAlpha=input.float(0.05, "Reward baseline EWMA", minval = 0.001, maxval = 0.5, step = 0.005, group = grpP)
warmup  = input.int(200, "Warmup bars", minval = 20, group = grpP)

grpV = "Visual"
showCloud  = input.bool(true, "Show regime cloud", group = grpV)
clLen      = input.int(20, "Cloud basis length", minval = 1, group = grpV)
clMult     = input.float(1.5, "Cloud width (ATR x)", minval = 0.1, step = 0.1, group = grpV)
showMarkers= input.bool(true, "Show management markers", group = grpV)

grpUI = "Dashboard"
showHUD = input.bool(true, "Show HUD", group = grpUI)
hudSize = input.string("normal", "HUD size", options = ["tiny","small","normal","large"], group = grpUI)

// ----------------------------------------------------------------------------
//  HELPERS
// ----------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))
f_sigmoid(float z) => 1.0 / (1.0 + math.exp(-f_clamp(z, -30.0, 30.0)))

// Logistic regression (shared by the regime classifier). w[0] = bias.
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

// Softmax policy probabilities over 5 actions for a feature vector s (size F+1).
f_policy(array<float> th, array<float> s, int F, float temp) =>
    scores = array.new_float(5, 0.0)
    for k = 0 to 4
        z = 0.0
        for j = 0 to F
            z += array.get(th, k * (F + 1) + j) * array.get(s, j)
        array.set(scores, k, f_clamp(z / temp, -30.0, 30.0))
    mx = array.max(scores)
    den = 0.0
    for k = 0 to 4
        den += math.exp(array.get(scores, k) - mx)
    probs = array.new_float(5, 0.0)
    for k = 0 to 4
        array.set(probs, k, math.exp(array.get(scores, k) - mx) / den)
    probs

// Deterministic pseudo-uniform in [0,1) from the bar index (reproducible).
f_hashU(int n) =>
    x = math.sin(n * 12.9898 + 78.233) * 43758.5453
    x - math.floor(x)

// Sample a categorical action from probs given u in [0,1).
f_sample(array<float> probs, float u) =>
    cum = 0.0
    int res = 4
    for k = 0 to 4
        cum += array.get(probs, k)
        if u <= cum
            res := k
            break
    res

// ----------------------------------------------------------------------------
//  REGIME CLASSIFIER  (online logistic; trend vs range)
// ----------------------------------------------------------------------------
atr     = ta.atr(atrLen)
atrSafe = math.max(nz(atr, nz(ta.tr, close * 0.001)), 1e-8)

// Features: efficiency ratio, ADX, Bollinger bandwidth ratio, ATR regime.
pathLen = math.max(math.sum(math.abs(close - close[1]), erLen), 1e-8)
erEff   = f_clamp(math.abs(close - close[erLen]) / pathLen, 0.0, 1.0)
[_dip, _dim, adx] = ta.dmi(diLen, adxLen)
adxN    = f_clamp(nz(adx) / 100.0, 0.0, 1.0)
bbBasis = ta.sma(close, bbLen)
bbDev   = ta.stdev(close, bbLen)
bw      = (2.0 * bbDev) / math.max(bbBasis, 1e-8)
bwRatio = f_clamp(bw / math.max(ta.sma(bw, 50), 1e-8), 0.0, 3.0)
atrReg  = f_clamp(atrSafe / math.max(ta.sma(atrSafe, 50), 1e-8), 0.0, 3.0)

var array<float> wReg = array.new_float(4 + 1, 0.0)
regFeat = array.from(erEff, adxN, bwRatio, atrReg)

// Realized regime label over the next K bars (efficiency ratio of the path).
pathLenK   = math.max(math.sum(math.abs(close - close[1]), regLabK), 1e-8)
realizedER = math.abs(close - close[regLabK]) / pathLenK

if barstate.isconfirmed and bar_index > regLabK
    labTrend = realizedER > erThr ? 1.0 : 0.0
    regFeatLag = array.from(erEff[regLabK], adxN[regLabK], bwRatio[regLabK], atrReg[regLabK])
    f_train(wReg, regFeatLag, labTrend, regLR, 0.0005)

pTrend = f_predict(wReg, regFeat)

// ----------------------------------------------------------------------------
//  RL TRADE MANAGER  (REINFORCE policy over target exposure)
//  Actions 0..4 -> exposure {-1, -0.5, 0, +0.5, +1};  exposure = (a - 2) * 0.5
// ----------------------------------------------------------------------------
int FP = 6                                   // policy feature count (excl. bias)
var array<float> thW = array.new_float(5 * (FP + 1), 0.0)
var float baseR = 0.0

// State features (all series, so [1] history reconstructs the previous state).
emaSlope = (ta.ema(close, 10) - ta.ema(close, 30)) / atrSafe
hh = ta.highest(high, 50)
ll = ta.lowest(low, 50)
rngPos = f_clamp((close - math.avg(hh, ll)) / math.max((hh - ll) / 2.0, 1e-8), -1.0, 1.0)
retZ   = f_clamp((close - close[5]) / (atrSafe * math.sqrt(5)), -1.0, 1.0)
volZ   = f_clamp((atrSafe - ta.sma(atrSafe, 50)) / math.max(ta.stdev(atrSafe, 50), 1e-8), -1.0, 1.0)

// Current-held exposure is the previous bar's chosen exposure. We mirror eCur
// into a var so its [1] history cleanly reconstructs the prior state.
var float eCurState = 0.0
sExp = nz(eCurState[1])                       // exposure carried into this decision

sF1 = sExp
sF2 = f_clamp(emaSlope, -1.0, 1.0)
sF3 = pTrend * 2.0 - 1.0
sF4 = rngPos
sF5 = retZ
sF6 = volZ
sFull = array.from(1.0, sF1, sF2, sF3, sF4, sF5, sF6)

probs = f_policy(thW, sFull, FP, tau)
p0 = array.get(probs, 0)
p1 = array.get(probs, 1)
p2 = array.get(probs, 2)
p3 = array.get(probs, 3)
p4 = array.get(probs, 4)

u = f_hashU(bar_index)
act = f_sample(probs, u)
eCur = (act - 2) * 0.5
eCurState := eCur

// REINFORCE update for the action taken on the previous bar (reward realized now).
ret = nz((close - close[1]) / atrSafe)
eP  = nz(eCur[1])
eP2 = nz(eCur[2])

if barstate.isconfirmed and bar_index > 2 and not na(act[1])
    r = eP * ret - turnCost * math.abs(eP - eP2)
    baseR := (1.0 - baseAlpha) * baseR + baseAlpha * r
    adv = r - baseR
    aPrev = act[1]
    sPrev = array.from(1.0, nz(sF1[1]), nz(sF2[1]), nz(sF3[1]), nz(sF4[1]), nz(sF5[1]), nz(sF6[1]))
    pPrev = array.from(nz(p0[1]), nz(p1[1]), nz(p2[1]), nz(p3[1]), nz(p4[1]))
    for k = 0 to 4
        coef = adv * (((k == aPrev) ? 1.0 : 0.0) - array.get(pPrev, k))
        for j = 0 to FP
            idx = k * (FP + 1) + j
            nv  = array.get(thW, idx) + polLR * coef * array.get(sPrev, j)
            array.set(thW, idx, f_clamp(nv, -8.0, 8.0))

warmOK   = bar_index > warmup
expChosen = warmOK ? eCur : 0.0
chosenP   = act == 0 ? p0 : act == 1 ? p1 : act == 2 ? p2 : act == 3 ? p3 : p4

// ----------------------------------------------------------------------------
//  MANAGEMENT EVENTS  (from exposure transitions; no-repaint on confirmed bars)
// ----------------------------------------------------------------------------
ePrevD = nz(eCur[1])
goLong  = barstate.isconfirmed and warmOK and ePrevD <= 0 and eCur > 0
goShort = barstate.isconfirmed and warmOK and ePrevD >= 0 and eCur < 0
goFlat  = barstate.isconfirmed and warmOK and eCur == 0 and ePrevD != 0
addPos  = barstate.isconfirmed and warmOK and eCur * ePrevD > 0 and math.abs(eCur) > math.abs(ePrevD)
trimPos = barstate.isconfirmed and warmOK and eCur * ePrevD > 0 and math.abs(eCur) < math.abs(ePrevD) and eCur != 0

// ----------------------------------------------------------------------------
//  VISUAL  -  REGIME CLOUD
// ----------------------------------------------------------------------------
basis = ta.ema(close, clLen)
cloudCol = not showCloud ? na : pTrend > 0.5 ? (eCur > 0 ? color.new(cBull, 80) : eCur < 0 ? color.new(cBear, 80) : color.new(cGold, 85)) : color.new(cWait, 88)
uBand = plot(showCloud ? basis + atrSafe * clMult : na, "Cloud upper", color = na)
lBand = plot(showCloud ? basis - atrSafe * clMult : na, "Cloud lower", color = na)
fill(uBand, lBand, color = cloudCol, title = "Regime cloud")
plot(showCloud ? basis : na, "Basis", color = pTrend > 0.5 ? (eCur >= 0 ? cBull : cBear) : color.new(cWait, 30), linewidth = 2)

// ----------------------------------------------------------------------------
//  MARKERS
// ----------------------------------------------------------------------------
plotshape(showMarkers and goLong,  title = "Long",  style = shape.triangleup,   location = location.belowbar, color = cBull, size = size.small, text = "LONG",  textcolor = cBull)
plotshape(showMarkers and goShort, title = "Short", style = shape.triangledown, location = location.abovebar, color = cBear, size = size.small, text = "SHORT", textcolor = cBear)
plotshape(showMarkers and goFlat,  title = "Exit",  style = shape.xcross,       location = location.abovebar, color = cWait, size = size.tiny,  text = "EXIT",  textcolor = cWait)
plotshape(showMarkers and addPos,  title = "Add",   style = shape.circle,       location = location.belowbar, color = color.new(cBull, 30), size = size.tiny)
plotshape(showMarkers and trimPos, title = "Trim",  style = shape.circle,       location = location.abovebar, color = color.new(cBear, 30), size = size.tiny)

// ----------------------------------------------------------------------------
//  HUD DASHBOARD  (gold frame)
// ----------------------------------------------------------------------------
f_txtSize() => hudSize == "tiny" ? size.tiny : hudSize == "small" ? size.small : hudSize == "large" ? size.large : size.normal

regTxt   = pTrend > 0.5 ? "TREND" : "RANGE"
stanceTxt= expChosen >= 1.0 ? "FULL LONG" : expChosen >= 0.5 ? "HALF LONG" : expChosen <= -1.0 ? "FULL SHORT" : expChosen <= -0.5 ? "HALF SHORT" : "FLAT"
stanceCol= expChosen > 0 ? cBull : expChosen < 0 ? cBear : cWait

var table hud = table.new(position.top_right, 2, 9, bgcolor = cBg1, frame_color = cGold, frame_width = 2, border_color = color.new(cGold, 60), border_width = 1)

if showHUD and barstate.islast
    ts = f_txtSize()
    table.cell(hud, 0, 0, "AE-HELM", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 0, "RL MANAGER", text_color = cWait, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 0, 1, "Regime",   text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 1, regTxt + " " + str.tostring(math.round(pTrend * 100)) + "%", text_color = pTrend > 0.5 ? cGold : cWait, text_size = ts)
    table.cell(hud, 0, 2, "Stance",   text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 2, stanceTxt,  text_color = stanceCol, text_size = ts)
    table.cell(hud, 0, 3, "Exposure", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 3, str.tostring(expChosen, "#.#"), text_color = stanceCol, text_size = ts)
    table.cell(hud, 0, 4, "Conviction", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 4, str.tostring(math.round(chosenP * 100)) + "%", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 5, "Momentum", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 5, emaSlope >= 0 ? "UP" : "DOWN", text_color = emaSlope >= 0 ? cBull : cBear, text_size = ts)
    table.cell(hud, 0, 6, "Range pos", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 6, rngPos > 0.33 ? "PREMIUM" : rngPos < -0.33 ? "DISCOUNT" : "EQUILIBRIUM", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 7, "Avg reward", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 7, str.tostring(baseR, "#.###"), text_color = baseR >= 0 ? cBull : cBear, text_size = ts)
    table.cell(hud, 0, 8, "Policy", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 8, warmOK ? "live" : "learning", text_color = warmOK ? cBull : cWait, bgcolor = cBg0, text_size = ts)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
alertcondition(goLong,  "AE-HELM Long",  "AE-HELM manager went long")
alertcondition(goShort, "AE-HELM Short", "AE-HELM manager went short")
alertcondition(goFlat,  "AE-HELM Exit",  "AE-HELM manager exited to flat")

if goLong
    alert("AE-HELM LONG | regime " + str.tostring(math.round(pTrend * 100)) + "% | exposure " + str.tostring(eCur, "#.#"), alert.freq_once_per_bar_close)
if goShort
    alert("AE-HELM SHORT | regime " + str.tostring(math.round(pTrend * 100)) + "% | exposure " + str.tostring(eCur, "#.#"), alert.freq_once_per_bar_close)
````
