# AetherEdge - Smart Money Flow

- url: https://www.tradingview.com/script/jkgBMcNr/
- type: indicator
- pine_id: PUB;c22c6f1f81014a33a2d0f88a2fd48520
- version: 1.0

## Description

🖊️ Overview

AE-SMF focuses on what smart-money price action is really about — liquidity. It maps the stop pools resting above swing highs (buyside) and below swing lows (sellside) and learns which liquidity price reaches for next (draw on liquidity). The liquidity, sweep, displacement/FVG and premium/discount concepts are re-implemented from public material, with a genuine learning core on top.

🔶 Key Features

Liquidity pool map — buyside/sellside pools, auto-removed once taken
Sweep detection — a grab of one side's liquidity followed by reclaim
ML: draw on liquidity — learns P(the buyside pool is reached before the sellside pool), turning the pull of price into a probability
RL: self-tuning bias threshold — a UCB bandit auto-tunes the firing threshold per structure regime
Sweep-origin signals — TP set to the targeted liquidity pool, SL beyond the swept extreme
Displacement/FVG and premium/discount included
Structure uses confirmed pivots; training and signals gate on bar close — no repaint

🧠 Technical Architecture

Liquidity engine: buyside/sellside pools from confirmed pivots are held in arrays; pools price trades through (taken liquidity) are removed; the nearest pools are drawn as lines.
Sweeps: piercing sellside then reclaiming up = bullish sweep; piercing buyside then closing down = bearish sweep.
ML (online logistic regression): eight features (trend, displacement tendency, premium/discount position, recent bullish/bearish sweep, distance to the buyside/sellside pools, structure direction) feed a model of the draw = P(buyside pool reached before sellside, within N bars). Each confirmed bar labels a pool-to-pool barrier — which of the nearest buyside target (above) and sellside target (below) is touched first — so the prediction uses no future data. If neither is reached in time, the sample is discarded (only clean draws train it).
RL (UCB contextual bandit): auto-tunes the bias firing threshold per structure regime (trend-strength terciles). Its reward is tied to the same draw resolution (a confident bias that proves correct = +1, wrong = −penalty, abstaining when neutral = a small reward) — so the ML training and the RL reward share one judgment loop.
Signals: long = bullish sweep + buyside draw ≥ threshold + discount; short = the mirror. TP is the targeted liquidity pool; SL is beyond the swept extreme.
Honest scope: a linear classifier + a UCB bandit over standard liquidity/structure features. Not deep learning, not a guarantee.

⚙️ Recommended Settings & Tuning Guide

Key parameters: swing lookback (pivots), pools per side, displacement multiple, barrier horizon N, learning rate, threshold search range, stop buffer.
Larger swing lookback → focus on major-structure pools; smaller → more detections
N is the window for deciding which liquidity is reached first (smaller for short-term, larger for swing)
Crypto starting points (tune on your chart):
BTC / ETH (15m–4H): defaults are the baseline (pivLen 10, N 20)
SOL / XRP and high-vol alts: a slightly longer swing lookback and a wider stop buffer to avoid wick-hunts
Scalping (1–15m): smaller pivot length and N
Swing (4H–daily): larger pivot length, N, and warmup
Bias, accuracy, and threshold are coarse until warmup plus enough draws accumulate

💡 How to Use in Practice

Read the draw bias for the liquidity price is likely to target next (buyside = up, sellside = down)
Enter on a sweep + agreeing-draw signal and use the drawn SL/TP (TP = the targeted pool)
Use premium/discount to favor advantageous pullbacks/rallies (buy discount, sell premium)
Leave the auto threshold to the learner by default
Combine with a higher-timeframe liquidity view or a precision-entry tool (AE-ACE)

⚠️ Important Notes

Needs a learning period (warmup); weights and the Q-table re-learn on input/symbol/timeframe change
Pools come from confirmed pivots, so the latest extreme confirms a few bars late (the trade-off for avoiding repaint)
A sweep does not guarantee a reversal (it can continue)
Probability, not a guarantee — always use stops and position sizing

🚨 Disclaimer

This indicator is for educational and informational purposes only and is not financial advice or a recommendation to buy or sell. No method guarantees future profits; past performance does not indicate future results, and trading carries the risk of loss. All trading decisions are your own — use proper backtesting and disciplined risk management.

## Source Code

````pine
// ============================================================================
//  AetherEdge - Smart Money Flow  (AE-SMF)  |  AetherEdge Series
//  Liquidity-draw engine: learns which liquidity price reaches for next
//
//  Smart-money price action revolves around liquidity: pools of stops resting
//  above swing highs (buyside) and below swing lows (sellside). Price is "drawn"
//  to that liquidity, often grabbing one side before reversing toward the other.
//  AE-SMF maps that liquidity from public structure concepts and adds a genuine
//  learning core:
//
//    * ML : an ONLINE LOGISTIC REGRESSION learns DRAW ON LIQUIDITY -- P(the
//      nearest buyside pool is reached before the nearest sellside pool, within
//      N bars) from structure, displacement, premium/discount and distance
//      features. The label is a pool-to-pool BARRIER resolved on realized price
//      (no lookahead). The learned coefficients show what truly pulls price.
//
//    * RL : a CONTEXTUAL BANDIT (UCB) AUTO-TUNES the bias confidence threshold
//      per structure regime; its reward is tied to the SAME draw resolution, so
//      the model is one coherent learning loop, not bolted-on heuristics.
//      Deterministic -> no repaint.
//
//  Sweep-origin signals target the opposite liquidity pool (take-profit) with a
//  stop beyond the swept extreme. Honest scope: a linear classifier + a UCB
//  bandit over standard liquidity/structure features -- not a neural net, not a
//  guarantee. Structure uses confirmed pivots; training/signals gate on
//  barstate.isconfirmed.
// ============================================================================

//@version=6
indicator("AetherEdge - Smart Money Flow", "AE-SMF", overlay = true, max_boxes_count = 500, max_labels_count = 300, max_lines_count = 100)

// ----------------------------------------------------------------------------
//  THEME
// ----------------------------------------------------------------------------
cGold = #d4af37
cBg0  = #080b0a
cBg1  = #0f1614
cTxt  = #eef2f0
cBull = #26a69a
cBear = #ef5350
cWait = #8d99a6

// ----------------------------------------------------------------------------
//  INPUTS
// ----------------------------------------------------------------------------
grpS = "Structure & liquidity"
pivLen   = input.int(10, "Swing lookback (pivots)", minval = 2, group = grpS)
maxPools = input.int(8, "Liquidity pools per side", minval = 2, maxval = 20, group = grpS)
atrLen   = input.int(14, "ATR length", minval = 1, group = grpS)

grpD = "Displacement / FVG"
dispMult = input.float(1.5, "Displacement (ATR)", minval = 0.3, step = 0.1, group = grpD)
showFVG  = input.bool(true, "Draw fair value gaps", group = grpD)

grpM = "Draw-on-liquidity model"
barN   = input.int(20, "Barrier horizon N (bars)", minval = 2, group = grpM, tooltip = "Which pool is reached first within N bars labels the model.")
lr     = input.float(0.03, "Learning rate", minval = 0.0001, step = 0.005, group = grpM)
l2     = input.float(0.0005, "L2 regularization", minval = 0.0, step = 0.0005, group = grpM)
warmup = input.int(150, "Warmup bars", minval = 20, group = grpM)

grpRL = "Adaptive bias threshold (UCB)"
thrBase = input.float(0.55, "Lowest threshold", minval = 0.3, maxval = 0.9, step = 0.01, group = grpRL)
thrStep = input.float(0.04, "Threshold step", minval = 0.01, step = 0.01, group = grpRL)
thrArms = input.int(5, "Threshold options", minval = 2, maxval = 8, group = grpRL)
ucbC    = input.float(1.0, "Exploration constant", minval = 0.0, step = 0.1, group = grpRL)
faPen   = input.float(0.7, "Wrong-call penalty", minval = 0.0, step = 0.1, group = grpRL)

grpR = "Signals"
slBuf = input.float(0.3, "Stop buffer beyond sweep (ATR)", minval = 0.0, step = 0.1, group = grpR)

grpV = "Visual"
showZones = input.bool(true, "Draw signal SL / TP zones", group = grpV)

grpUI = "Dashboard"
showHUD = input.bool(true, "Show HUD", group = grpUI)
hudSize = input.string("small", "Table size", options = ["tiny","small","normal","large"], group = grpUI)

// ----------------------------------------------------------------------------
//  HELPERS
// ----------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))
f_sigmoid(float z) => 1.0 / (1.0 + math.exp(-f_clamp(z, -30.0, 30.0)))
f_tanh(float x) => 2.0 / (1.0 + math.exp(-2.0 * f_clamp(x, -10.0, 10.0))) - 1.0
f_txtSize() => hudSize == "tiny" ? size.tiny : hudSize == "small" ? size.small : hudSize == "large" ? size.large : size.normal

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

f_ucb(array<float> q, array<int> cnt, int c, int n, float cst) =>
    int total = 0
    for a = 0 to n - 1
        total += array.get(cnt, c * n + a)
    int best = 0
    float bestV = -1e18
    for a = 0 to n - 1
        idx = c * n + a
        cn  = array.get(cnt, idx)
        v   = cn < 1 ? 1e12 : array.get(q, idx) + cst * math.sqrt(math.log(total + 1) / cn)
        if v > bestV
            bestV := v
            best := a
    best

f_nearestAbove(array<float> arr, float px) =>
    float best = na
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            v = array.get(arr, i)
            if v > px and (na(best) or v < best)
                best := v
    best

f_nearestBelow(array<float> arr, float px) =>
    float best = na
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            v = array.get(arr, i)
            if v < px and (na(best) or v > best)
                best := v
    best

// ----------------------------------------------------------------------------
//  ATR, STRUCTURE, DEALING RANGE
// ----------------------------------------------------------------------------
int NF = 8
atr     = ta.atr(atrLen)
atrSafe = math.max(nz(atr, nz(ta.tr, close * 0.001)), 1e-8)

ph = ta.pivothigh(pivLen, pivLen)
pl = ta.pivotlow(pivLen, pivLen)
var float lastPH = na
var float lastPL = na
if not na(ph)
    lastPH := ph
if not na(pl)
    lastPL := pl
eqHigh = nz(lastPH, ta.highest(high, pivLen * 5))
eqLow  = nz(lastPL, ta.lowest(low, pivLen * 5))
pdPos  = f_clamp((close - eqLow) / math.max(eqHigh - eqLow, 1e-8), 0.0, 1.0)

// structure bias from break of last pivot
var int structDir = 0
if not na(lastPH) and close > lastPH
    structDir := 1
if not na(lastPL) and close < lastPL
    structDir := -1

// displacement
disp = close - open
dispBig = math.abs(disp) > dispMult * atrSafe
var float dispEwma = 0.0
dispEwma := 0.85 * dispEwma + 0.15 * (dispBig ? math.sign(disp) : 0.0)

// ----------------------------------------------------------------------------
//  LIQUIDITY POOLS
// ----------------------------------------------------------------------------
var array<float> buyPools  = array.new_float(0)
var array<float> sellPools = array.new_float(0)

if not na(ph)
    array.push(buyPools, ph)
    if array.size(buyPools) > maxPools
        array.shift(buyPools)
if not na(pl)
    array.push(sellPools, pl)
    if array.size(sellPools) > maxPools
        array.shift(sellPools)

// sweep detection (grab + reclaim) on the nearest pools, BEFORE removing taken pools
nearBuyPre  = f_nearestAbove(buyPools, close)
nearSellPre = f_nearestBelow(sellPools, close)
bullSweep = not na(nearSellPre) and low < nearSellPre and close > nearSellPre   // sellside grabbed, reclaimed up
bearSweep = not na(nearBuyPre) and high > nearBuyPre and close < nearBuyPre     // buyside grabbed, reclaimed down

var float swBullDecay = 0.0
var float swBearDecay = 0.0
swBullDecay := 0.9 * swBullDecay
swBearDecay := 0.9 * swBearDecay
if barstate.isconfirmed and bullSweep
    swBullDecay := 1.0
if barstate.isconfirmed and bearSweep
    swBearDecay := 1.0

// remove taken liquidity (price traded through the pool)
if barstate.isconfirmed and array.size(buyPools) > 0
    for i = array.size(buyPools) - 1 to 0
        if high >= array.get(buyPools, i)
            array.remove(buyPools, i)
if barstate.isconfirmed and array.size(sellPools) > 0
    for i = array.size(sellPools) - 1 to 0
        if low <= array.get(sellPools, i)
            array.remove(sellPools, i)

nearBuy  = f_nearestAbove(buyPools, close)
nearSell = f_nearestBelow(sellPools, close)
hasBuy  = not na(nearBuy)
hasSell = not na(nearSell)

// ----------------------------------------------------------------------------
//  FAIR VALUE GAPS  (displacement footprint)
// ----------------------------------------------------------------------------
bullFVG = dispBig and disp > 0 and low > high[2]
bearFVG = dispBig and disp < 0 and high < low[2]
if showFVG and barstate.isconfirmed and bullFVG
    box.new(bar_index - 2, low, bar_index + 3, high[2], xloc = xloc.bar_index, border_color = color.new(cBull, 70), bgcolor = color.new(cBull, 88))
if showFVG and barstate.isconfirmed and bearFVG
    box.new(bar_index - 2, low[2], bar_index + 3, high, xloc = xloc.bar_index, border_color = color.new(cBear, 70), bgcolor = color.new(cBear, 88))

// ----------------------------------------------------------------------------
//  DRAW-ON-LIQUIDITY MODEL (ML) + ADAPTIVE THRESHOLD (RL)
// ----------------------------------------------------------------------------
type Draw
    float        upTgt
    float        dnTgt
    int          bornBar
    array<float> feat
    int          regimeT
    int          armT
    bool         firedBull
    bool         firedBear
    bool         resolved

var array<float> wD   = array.new_float(NF + 1, 0.0)
var array<Draw>  pend = array.new<Draw>()
var array<float> qTab = array.new_float(3 * thrArms, 0.0)
var array<int>   cTab = array.new_int(3 * thrArms, 0)
var int firedTotal = 0
var int firedCorrect = 0

// structure regime (trend strength terciles) for the bandit context
tStr = math.abs(f_tanh((ta.ema(close, 50) - ta.ema(close, 200)) / atrSafe))
int regime = tStr < 0.33 ? 0 : tStr < 0.66 ? 1 : 2
arm = f_ucb(qTab, cTab, regime, thrArms, ucbC)
thr = thrBase + arm * thrStep

f_drawFeat() =>
    f1 = f_clamp(f_tanh((ta.ema(close, 21) - ta.ema(close, 50)) / atrSafe), -1.0, 1.0)
    f2 = f_clamp(dispEwma, -1.0, 1.0)
    f3 = pdPos - 0.5
    f4 = swBullDecay
    f5 = swBearDecay
    f6 = f_clamp((hasBuy ? (nearBuy - close) : high - close) / atrSafe, 0.0, 10.0)
    f7 = f_clamp((hasSell ? (close - nearSell) : close - low) / atrSafe, 0.0, 10.0)
    f8 = structDir
    array.from(f1, f2, f3, f4, f5, f6, f7, f8)

dfeat = f_drawFeat()
pBuy = f_predict(wD, dfeat)
warmOK = bar_index > warmup

// register one draw context per confirmed bar (pools both sides present)
if barstate.isconfirmed and hasBuy and hasSell and bar_index > pivLen + 2
    fb = pBuy >= thr
    fbear = pBuy <= (1.0 - thr)
    array.push(pend, Draw.new(nearBuy, nearSell, bar_index, array.copy(dfeat), regime, arm, fb, fbear, false))
    if array.size(pend) > 300
        array.shift(pend)

// resolve: which pool was reached first -> trains ML and the bandit, tracks accuracy
if barstate.isconfirmed and array.size(pend) > 0
    for i = array.size(pend) - 1 to 0
        d = array.get(pend, i)
        if not d.resolved
            age = bar_index - d.bornBar
            int hit = -1                              // -1 pending, 1 buyside first, 0 sellside first
            if low <= d.dnTgt
                hit := 0
            else if high >= d.upTgt
                hit := 1
            if hit == -1 and age >= barN
                hit := -2                             // timed out -> discard (no clean draw)
            if hit >= 0
                buyFirst = hit == 1
                f_train(wD, d.feat, buyFirst ? 1.0 : 0.0, lr, l2)
                correct = (d.firedBull and buyFirst) or (d.firedBear and not buyFirst)
                wrong   = (d.firedBull and not buyFirst) or (d.firedBear and buyFirst)
                reward = correct ? 1.0 : wrong ? -faPen : 0.1
                idx = d.regimeT * thrArms + d.armT
                nC = array.get(cTab, idx) + 1
                array.set(cTab, idx, nC)
                array.set(qTab, idx, array.get(qTab, idx) + (reward - array.get(qTab, idx)) / nC)
                if d.firedBull or d.firedBear
                    firedTotal += 1
                    firedCorrect += correct ? 1 : 0
                d.resolved := true
                array.remove(pend, i)
            else if hit == -2
                d.resolved := true
                array.remove(pend, i)

biasAcc = firedTotal > 0 ? firedCorrect / firedTotal : na

// ----------------------------------------------------------------------------
//  SIGNALS  (sweep-origin, biased by the learned draw, targeting opposite pool)
// ----------------------------------------------------------------------------
bool longSig = false
bool shortSig = false
if barstate.isconfirmed and warmOK
    longSig  := bullSweep and pBuy >= thr and pdPos < 0.5 and hasBuy
    shortSig := bearSweep and pBuy <= (1.0 - thr) and pdPos > 0.5 and hasSell

if showZones and longSig
    slL = low - slBuf * atrSafe
    box.new(bar_index, close, bar_index + barN, nearBuy, xloc = xloc.bar_index, border_color = color.new(cBull, 50), bgcolor = color.new(cBull, 85))
    box.new(bar_index, close, bar_index + barN, slL, xloc = xloc.bar_index, border_color = color.new(cBear, 50), bgcolor = color.new(cBear, 85))
    label.new(bar_index, slL, "AE-SMF LONG  draw " + str.tostring(math.round(pBuy * 100)) + "%", xloc = xloc.bar_index, style = label.style_label_up, color = color.new(cBull, 15), textcolor = cBg0, size = size.small)
if showZones and shortSig
    slS = high + slBuf * atrSafe
    box.new(bar_index, close, bar_index + barN, nearSell, xloc = xloc.bar_index, border_color = color.new(cBull, 50), bgcolor = color.new(cBull, 85))
    box.new(bar_index, close, bar_index + barN, slS, xloc = xloc.bar_index, border_color = color.new(cBear, 50), bgcolor = color.new(cBear, 85))
    label.new(bar_index, slS, "AE-SMF SHORT  draw " + str.tostring(math.round((1.0 - pBuy) * 100)) + "%", xloc = xloc.bar_index, style = label.style_label_down, color = color.new(cBear, 15), textcolor = cBg0, size = size.small)

// ----------------------------------------------------------------------------
//  PLOTS
// ----------------------------------------------------------------------------
plot(hasBuy ? nearBuy : na, "Buyside liquidity", color = color.new(cBull, 25), style = plot.style_stepline, linewidth = 1)
plot(hasSell ? nearSell : na, "Sellside liquidity", color = color.new(cBear, 25), style = plot.style_stepline, linewidth = 1)
plot(eqHigh, "Range high", color = color.new(cWait, 60), style = plot.style_stepline)
plot(eqLow, "Range low", color = color.new(cWait, 60), style = plot.style_stepline)

plotshape(bullSweep, title = "Bull sweep", style = shape.triangleup, location = location.belowbar, color = color.new(cBull, 40), size = size.tiny)
plotshape(bearSweep, title = "Bear sweep", style = shape.triangledown, location = location.abovebar, color = color.new(cBear, 40), size = size.tiny)
plotshape(longSig,  title = "Long",  style = shape.diamond, location = location.belowbar, color = cBull, size = size.small, text = "SMF", textcolor = cBull)
plotshape(shortSig, title = "Short", style = shape.diamond, location = location.abovebar, color = cBear, size = size.small, text = "SMF", textcolor = cBear)

// ----------------------------------------------------------------------------
//  HUD
// ----------------------------------------------------------------------------
drawTxt = pBuy >= thr ? "BUYSIDE" : pBuy <= (1.0 - thr) ? "SELLSIDE" : "neutral"
drawCol = pBuy >= thr ? cBull : pBuy <= (1.0 - thr) ? cBear : cWait
pdTxt = pdPos > 0.66 ? "PREMIUM" : pdPos < 0.34 ? "DISCOUNT" : "equilibrium"
regTxt = regime == 0 ? "RANGE" : regime == 1 ? "MID" : "TREND"

var table hud = table.new(position.top_right, 2, 11, bgcolor = cBg1, frame_color = cGold, frame_width = 2, border_color = color.new(cGold, 60), border_width = 1)
if showHUD and barstate.islast
    ts = f_txtSize()
    table.cell(hud, 0, 0, "AE-SMF", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 0, "SMART MONEY FLOW", text_color = cWait, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 0, 1, "Draw bias", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 1, drawTxt + " " + str.tostring(math.round(pBuy * 100)) + "%", text_color = drawCol, text_size = ts)
    table.cell(hud, 0, 2, "Buyside", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 2, hasBuy ? str.tostring(nearBuy, format.mintick) : "-", text_color = cBull, text_size = ts)
    table.cell(hud, 0, 3, "Sellside", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 3, hasSell ? str.tostring(nearSell, format.mintick) : "-", text_color = cBear, text_size = ts)
    table.cell(hud, 0, 4, "Zone", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 4, pdTxt, text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 5, "Last sweep", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 5, swBullDecay > swBearDecay and swBullDecay > 0.3 ? "bullish" : swBearDecay > 0.3 ? "bearish" : "-", text_color = swBullDecay > swBearDecay ? cBull : cBear, text_size = ts)
    table.cell(hud, 0, 6, "Threshold", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 6, str.tostring(math.round(thr * 100)) + "% auto", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 7, "Bias acc", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 7, na(biasAcc) ? "-" : str.tostring(math.round(biasAcc * 100)) + "% (" + str.tostring(firedTotal) + ")", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 8, "Regime", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 8, regTxt, text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 9, "Pools", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 9, str.tostring(array.size(buyPools)) + " / " + str.tostring(array.size(sellPools)), text_color = cWait, text_size = ts)
    table.cell(hud, 0, 10, "Model", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 10, warmOK ? "live" : "learning", text_color = warmOK ? cBull : cWait, bgcolor = cBg0, text_size = ts)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
alertcondition(longSig,  "AE-SMF Long",  "AE-SMF long: bullish sweep with buyside draw")
alertcondition(shortSig, "AE-SMF Short", "AE-SMF short: bearish sweep with sellside draw")

if longSig
    alert("AE-SMF LONG | draw to buyside " + str.tostring(math.round(pBuy * 100)) + "% | target " + str.tostring(nearBuy, format.mintick), alert.freq_once_per_bar_close)
if shortSig
    alert("AE-SMF SHORT | draw to sellside " + str.tostring(math.round((1.0 - pBuy) * 100)) + "% | target " + str.tostring(nearSell, format.mintick), alert.freq_once_per_bar_close)
````
