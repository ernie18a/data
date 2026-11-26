# AetherEdge - Adaptive MTF Fusion

- url: https://www.tradingview.com/script/AJmXcJOe/
- type: indicator
- pine_id: PUB;a6d07af3a966435abf190a897cd9139c
- version: 1.0

## Description

🖊️ Overview

AE-AMF fuses momentum from several timeframes into one oscillator — but instead of mixing them equally, it learns online how well each timeframe has predicted forward returns and weights it accordingly. Timeframes that have been accurate gain influence automatically, a timeframe that leads the wrong way is sign-flipped, and an unhelpful timeframe's weight converges to near zero. The weights follow the reality that different timeframes lead in different regimes.

🔶 Key Features

A consensus oscillator fusing four timeframes (default: chart / 60 / 240 / D)
Per-timeframe weights learned online — allocated by predictive power (inverse TFs flipped, uncorrelated ≈ 0)
Reliability-weighted, so the fused value stays bounded in [−1, +1] and easy to read
BUY/SELL signals on threshold crosses of the fused value, with a TF agreement count (agree/4)
A gold HUD showing fused value, bias, each TF's learned weight %, agreement, and predicted move
Non-repainting MTF — each higher timeframe reads only its last closed bar (expr[1] + lookahead_off); signals gate on bar close

🧠 Technical Architecture

Multi-TF momentum: on each timeframe, ROC is z-scored and passed through tanh to a bounded [−1, 1] momentum. Higher timeframes are pulled via request.security, but adding [1] to the expression with lookahead_off reads only the last closed HTF bar — so it does not repaint.
Weight learning (ML): the K = 4 timeframe momenta are features and the realized forward return (ATR units) is the target for an online linear regression (SGD squared loss + L2). The learned coefficients θ_i are each timeframe's weight: accurate TFs get large |θ_i|, an inversely-leading TF gets negative θ_i (flipped in the fusion), and an uncorrelated TF gets θ_i ≈ 0. Labels are H-bar lagged — no lookahead.
Fusion: a reliability-weighted consensus, fused = Σ p_i · sign(θ_i) · mom_i with p_i = |θ_i| / Σ|θ|. Since the weights sum to one, the fused value is bounded. The regression's point estimate Σ θ_i · mom_i serves as the predicted move (ATR units) for confidence.
Honest scope: a linear model over timeframe momenta. Not deep learning, and not a guarantee of the future.

⚙️ Recommended Settings & Tuning Guide

Key parameters: the four timeframes, momentum length, learning horizon (H), learning rate (lr), fusion signal threshold (thr), warmup.
Set timeframes equal to or higher than the chart (lower TFs just hold their last value and add little)
Larger H → slower weight learning, swing-oriented; smaller → faster adaptation, short-term
Raise thr → only strong consensus signals; lower → more responsive
Crypto starting points (tune on your chart):
BTC / ETH: on a 15m–1H chart, TF = current / 1H / 4H / D pairs well
SOL / XRP and high-vol alts: thr ≈ 0.2 to suppress noisy flips
Scalping (1–5m): TF = current / 15m / 1H / 4H, H ≈ 5 for fast adaptation
Swing (4H–daily): TF = 4H / D / W / M, longer H to learn higher-timeframe leadership
Warmup suppresses signals until the regression spins up; weights move early on

💡 How to Use in Practice

Momentum alignment: the fused sign is the bias; enter on threshold crosses. See multi-TF agreement in one indicator
Reading the weight panel: the % shows which timeframe is currently leading — generally follow the trend of the heaviest-weighted TF
Agreement (agree/4): 3/4 or 4/4 is a strong trend-following environment; a split read suggests caution
Predicted move: the regression's point estimate, consistent with the fused sign, gauges move size
Combinations: pair with AE-VECTOR's target band or AE-IRM's mean-reversion probability, and use AMF to confirm the big-picture momentum direction

⚠️ Important Notes

Learning period: no signals until warmup bars; weights need time to settle
Learning reset: changing inputs, symbol, timeframe, or the TF set re-learns the weights
One-HTF-bar lag: for no-repaint, each timeframe reads a closed bar, so even the fastest TF lags ~1 bar (the trade-off for avoiding fakeouts)
Momentum's nature: in strong ranges the fused value can oscillate around zero — use the agreement count and position sizing together

🚨 Disclaimer

This indicator is for educational and informational purposes only and is not financial advice or a recommendation to buy or sell. No method guarantees future profits; past performance does not indicate future results, and trading carries the risk of loss. All trading decisions are your own — use proper backtesting and disciplined risk management.

## Source Code

````pine
// ============================================================================
//  AetherEdge - Adaptive MTF Fusion  (AE-AMF)  |  AetherEdge Series
//  Multi-timeframe momentum fusion with ONLINE-LEARNED per-timeframe weights
//
//  Fusing several timeframes with equal weights is naive -- different
//  timeframes lead in different regimes. AE-AMF learns how much to trust each
//  one:
//
//    * ML : an ONLINE LINEAR REGRESSION (SGD + L2) treats the K timeframe
//      momenta as features and the realized forward return as the target. The
//      learned coefficients ARE each timeframe's weight -- a timeframe whose
//      momentum has actually predicted forward moves earns more influence (and
//      a timeframe that has led price the wrong way is automatically flipped).
//
//    * Fusion : the composite oscillator is a reliability-weighted momentum
//      consensus  sum_i p_i * sign(theta_i) * mom_i , with p_i = |theta_i| /
//      sum|theta|, so it stays bounded in [-1, 1] and emphasizes the
//      timeframes that have earned trust.
//
//  MTF is NON-REPAINTING: each higher timeframe is read from its last CLOSED
//  bar (expr[1] + lookahead_off). Labels are H-bar lagged; signals gate on
//  barstate.isconfirmed. Honest scope: a linear model over timeframe momenta --
//  not a neural net, not a guarantee.
// ============================================================================

//@version=6
indicator("AetherEdge - Adaptive MTF Fusion", "AE-AMF", overlay = false, max_labels_count = 200)

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
grpTF = "Timeframes (set equal or higher than the chart)"
tf1 = input.timeframe("",    "Timeframe 1", group = grpTF)
tf2 = input.timeframe("60",  "Timeframe 2", group = grpTF)
tf3 = input.timeframe("240", "Timeframe 3", group = grpTF)
tf4 = input.timeframe("D",   "Timeframe 4", group = grpTF)

grpM = "Momentum"
momLen = input.int(14, "Momentum length", minval = 1, group = grpM)
zLen   = input.int(50, "Normalization length", minval = 2, group = grpM)
scale  = input.float(1.0, "Momentum scale", minval = 0.1, step = 0.1, group = grpM)

grpL = "Learning"
hzn    = input.int(10, "Forecast horizon H (bars)", minval = 1, group = grpL, tooltip = "Weights are learned from the realized return over the next H bars (label is H-bar lagged, no lookahead).")
atrLen = input.int(14, "ATR length", minval = 1, group = grpL)
lr     = input.float(0.01,  "Learning rate", minval = 0.0001, step = 0.002, group = grpL)
l2     = input.float(0.0005, "L2 regularization", minval = 0.0, step = 0.0005, group = grpL)
warmup = input.int(150, "Warmup bars", minval = 20, group = grpL)

grpS = "Signals"
thr = input.float(0.15, "Fusion signal threshold", minval = 0.0, maxval = 0.9, step = 0.05, group = grpS)

grpV = "Visual"
showTFs = input.bool(true, "Show individual timeframes", group = grpV)

grpUI = "Dashboard"
showHUD = input.bool(true, "Show HUD", group = grpUI)
hudSize = input.string("normal", "HUD size", options = ["tiny","small","normal","large"], group = grpUI)

// ----------------------------------------------------------------------------
//  HELPERS
// ----------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))
f_tanh(float x) => 2.0 / (1.0 + math.exp(-2.0 * f_clamp(x, -10.0, 10.0))) - 1.0

// Bounded momentum on whatever timeframe this is evaluated in.
f_mom() =>
    m = ta.roc(close, momLen)
    z = (m - ta.sma(m, zLen)) / math.max(ta.stdev(m, zLen), 1e-8)
    f_tanh(z * scale * 0.5)

f_predLin(array<float> w, array<float> x) =>
    z = array.get(w, 0)
    for i = 0 to array.size(x) - 1
        z += array.get(w, i + 1) * array.get(x, i)
    z

f_trainLin(array<float> w, array<float> x, float y, float lrr, float l2r) =>
    err = f_predLin(w, x) - y
    array.set(w, 0, array.get(w, 0) - lrr * err)
    for i = 0 to array.size(x) - 1
        g = err * array.get(x, i) + l2r * array.get(w, i + 1)
        array.set(w, i + 1, array.get(w, i + 1) - lrr * g)

f_tfName(string tf) => tf == "" ? "chart" : tf

// ----------------------------------------------------------------------------
//  MULTI-TIMEFRAME MOMENTA  (non-repainting: last closed HTF bar)
// ----------------------------------------------------------------------------
int K = 4
mom1 = nz(request.security(syminfo.tickerid, tf1, f_mom()[1], lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off))
mom2 = nz(request.security(syminfo.tickerid, tf2, f_mom()[1], lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off))
mom3 = nz(request.security(syminfo.tickerid, tf3, f_mom()[1], lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off))
mom4 = nz(request.security(syminfo.tickerid, tf4, f_mom()[1], lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off))

moms    = array.from(mom1, mom2, mom3, mom4)
momsLag = array.from(mom1[hzn], mom2[hzn], mom3[hzn], mom4[hzn])

atr     = ta.atr(atrLen)
atrSafe = math.max(nz(atr, nz(ta.tr, close * 0.001)), 1e-8)

// ----------------------------------------------------------------------------
//  ONLINE REGRESSION  (learns per-timeframe weights)
// ----------------------------------------------------------------------------
var array<float> th = array.new_float(K + 1, 0.0)

predMove = f_predLin(th, moms)                      // forecast forward move (ATR units)

if barstate.isconfirmed and bar_index > hzn and not na(close[hzn])
    label = (close - close[hzn]) / atrSafe          // realized H-bar move (ATR units)
    f_trainLin(th, momsLag, label, lr, l2)

// Reliability weights (normalized magnitudes) and the fused consensus.
float wsum = 0.0
for i = 0 to K - 1
    wsum += math.abs(array.get(th, i + 1))
wsum := math.max(wsum, 1e-8)

float fused = 0.0
for i = 0 to K - 1
    p = math.abs(array.get(th, i + 1)) / wsum
    fused += p * math.sign(array.get(th, i + 1)) * array.get(moms, i)
fused := f_clamp(fused, -1.0, 1.0)

// How many timeframes agree (sign-wise, after their learned orientation) with the fused bias.
int agree = 0
for i = 0 to K - 1
    if math.sign(array.get(th, i + 1)) * array.get(moms, i) * math.sign(fused) > 0
        agree += 1

// ----------------------------------------------------------------------------
//  SIGNALS  (no-repaint)
// ----------------------------------------------------------------------------
warmOK   = bar_index > warmup
longSig  = barstate.isconfirmed and warmOK and ta.crossover(fused, thr)
shortSig = barstate.isconfirmed and warmOK and ta.crossunder(fused, -thr)

// ----------------------------------------------------------------------------
//  PLOTS  (oscillator pane)
// ----------------------------------------------------------------------------
fCol = fused >= 0 ? cBull : cBear
plot(fused, "Fused momentum", color = fCol, linewidth = 2)
fz = plot(fused, "", color = na, display = display.none)
zr = plot(0, "", color = na, display = display.none)
fill(fz, zr, color = color.new(fCol, 80), title = "Fusion fill")

plot(showTFs ? mom1 : na, "TF1", color = color.new(cTxt, 70))
plot(showTFs ? mom2 : na, "TF2", color = color.new(cGold, 70))
plot(showTFs ? mom3 : na, "TF3", color = color.new(cWait, 60))
plot(showTFs ? mom4 : na, "TF4", color = color.new(#8e7cc3, 60))

hline(0, "Mid", color = color.new(cWait, 50))
hline(thr,  "Upper", color = color.new(cBull, 60), linestyle = hline.style_dotted)
hline(-thr, "Lower", color = color.new(cBear, 60), linestyle = hline.style_dotted)

plotshape(longSig,  title = "Long",  style = shape.triangleup,   location = location.bottom, color = cBull, size = size.small, text = "BUY",  textcolor = cBull)
plotshape(shortSig, title = "Short", style = shape.triangledown, location = location.top,    color = cBear, size = size.small, text = "SELL", textcolor = cBear)

// ----------------------------------------------------------------------------
//  HUD DASHBOARD  (gold frame)
// ----------------------------------------------------------------------------
f_txtSize() => hudSize == "tiny" ? size.tiny : hudSize == "small" ? size.small : hudSize == "large" ? size.large : size.normal
f_wcell(int i) => str.tostring(math.round(math.abs(array.get(th, i + 1)) / wsum * 100)) + "%"
f_wcol(int i)  => array.get(th, i + 1) >= 0 ? cBull : cBear

biasTxt = fused > 0 ? "UP" : fused < 0 ? "DOWN" : "flat"

var table hud = table.new(position.top_right, 2, 10, bgcolor = cBg1, frame_color = cGold, frame_width = 2, border_color = color.new(cGold, 60), border_width = 1)

if showHUD and barstate.islast
    ts = f_txtSize()
    table.cell(hud, 0, 0, "AE-AMF", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 0, "MTF FUSION", text_color = cWait, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 0, 1, "Fused",  text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 1, str.tostring(fused, "#.##"), text_color = fCol, text_size = ts)
    table.cell(hud, 0, 2, "Bias",   text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 2, biasTxt,  text_color = fCol, text_size = ts)
    table.cell(hud, 0, 3, "Wt " + f_tfName(tf1), text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 3, f_wcell(0), text_color = f_wcol(0), text_size = ts)
    table.cell(hud, 0, 4, "Wt " + f_tfName(tf2), text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 4, f_wcell(1), text_color = f_wcol(1), text_size = ts)
    table.cell(hud, 0, 5, "Wt " + f_tfName(tf3), text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 5, f_wcell(2), text_color = f_wcol(2), text_size = ts)
    table.cell(hud, 0, 6, "Wt " + f_tfName(tf4), text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 6, f_wcell(3), text_color = f_wcol(3), text_size = ts)
    table.cell(hud, 0, 7, "Agreement", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 7, str.tostring(agree) + "/" + str.tostring(K), text_color = agree >= 3 ? cBull : cWait, text_size = ts)
    table.cell(hud, 0, 8, "Pred move", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 8, str.tostring(predMove, "#.##") + " ATR", text_color = predMove >= 0 ? cBull : cBear, text_size = ts)
    table.cell(hud, 0, 9, "Model",  text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 9, warmOK ? "live" : "learning", text_color = warmOK ? cBull : cWait, bgcolor = cBg0, text_size = ts)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
alertcondition(longSig,  "AE-AMF Long",  "AE-AMF fused momentum turned up")
alertcondition(shortSig, "AE-AMF Short", "AE-AMF fused momentum turned down")

if longSig
    alert("AE-AMF BUY | fused " + str.tostring(fused, "#.##") + " | agree " + str.tostring(agree) + "/" + str.tostring(K), alert.freq_once_per_bar_close)
if shortSig
    alert("AE-AMF SELL | fused " + str.tostring(fused, "#.##") + " | agree " + str.tostring(agree) + "/" + str.tostring(K), alert.freq_once_per_bar_close)
````
