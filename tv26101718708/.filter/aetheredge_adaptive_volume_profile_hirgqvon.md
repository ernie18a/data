# AetherEdge - Adaptive Volume Profile

- url: https://www.tradingview.com/script/HiRgqVon/
- type: indicator
- pine_id: PUB;24d5517b5084490e9c027450c794cf1d
- version: 1.0

## Description

🖊️ Overview

AE-AVP pairs an auction-theory volume profile (POC and value area) with an engine that learns whether a value-area-edge break gets accepted (a real breakout) or rejected (faded back into value). It shows where volume concentrated and puts a probability on the most tradeable moment — the fight at the value-area edge.

🔶 Key Features

A real volume profile — POC, value area (VAH/VAL), and node strength drawn as a right-side histogram
ML: acceptance/rejection — online-learns whether an edge break continues or reverts; low probability flags a fade to the POC
RL self-tuning threshold — a UCB bandit tunes the acceptance threshold per volatility regime
Signals — distinguishes accepted breakouts (follow) from edge rejections (fade to POC)
POC/VAH/VAL are usable horizontal levels
Learning/signals on bar close — no repaint

🧠 Technical Architecture

Volume profile: the recent lookback bars' price range is split into rows bins; each bar's volume is distributed across the bins its [low, high] spans. POC = highest-volume bin; value area = expand from the POC toward the heavier neighbour until vaPct% (default 70%) of volume is enclosed → VAH/VAL; node strength = bin volume / max.
ML (online logistic regression): when price breaks above VAH or below VAL, seven features (edge node strength, approach momentum, volume surge, stretch from POC, trend, volatility regime, VA width — oriented to the break direction) feed a model of P(acceptance). Events are held in an internal array and labeled by a triple barrier (accept = beyond the edge by k·ATR; reject = back inside; time-out discarded) — no future data.
RL (UCB contextual bandit): tunes the acceptance threshold per volatility regime (ATR-percentile terciles); the reward is tied to the same edge resolution, so ML and RL share one judgment loop.
Signals: acceptance (P ≥ threshold) → follow the break direction; rejection (P ≤ 1 − threshold) → fade toward the POC.
Honest scope: a linear classifier + a UCB bandit over standard profile/price features. Not deep learning, not a guarantee.

⚙️ Recommended Settings & Tuning Guide (crypto 15m–4H)

Key parameters: profile lookback, bins (rows), value-area %, acceptance/rejection distance (ATR), horizon M, threshold search range.
Larger lookback → big-picture POC (stable, slower); smaller → sensitive to recent volume
More bins → higher resolution (finer, heavier to draw)
Higher value-area % → a wider VA and stricter break conditions
Guide: BTC/ETH (15m–1H) defaults (lookback 150, rows 24, VA 70%); 4H/daily a longer lookback; high-vol alts slightly wider acceptance/rejection distances
P(acceptance), threshold, and accuracy are coarse until warmup plus enough edge events accumulate

💡 How to Use in Practice

The POC is a magnet price; VAH/VAL are the battle lines — range inside value, direction on an edge break
Acceptance signals (BRK) mean follow the break; rejection signals (REJ) mean fade the edge toward the POC
Use P(acceptance) and node strength to judge whether a break is real (breaking a weak node with high acceptance)
Leave the auto threshold to the learner by default
Combine with a higher-timeframe value area or a trend tool for added precision

⚠️ Important Notes

Needs a learning period (warmup); weights and the Q-table re-learn on input/symbol/timeframe change
The profile is computed from closed bars; the histogram shows the current window
An edge break does not guarantee acceptance (which is exactly why it's shown as a probability)
Probability, not a guarantee — always use stops and position sizing

🚨 Disclaimer

This indicator is for educational and informational purposes only and is not financial advice or a recommendation to buy or sell. No method guarantees future profits; past performance does not indicate future results, and trading carries the risk of loss. All trading decisions are your own — use proper backtesting and disciplined risk management.

## Source Code

````pine
// ============================================================================
//  AetherEdge - Adaptive Volume Profile  (AE-AVP)  |  AetherEdge Series
//  A volume profile that LEARNS whether value-area edges break or hold
//
//  Auction theory: price spends most time inside the value area around the
//  point of control (POC); the tradeable moment is when it attempts to leave -
//  a value-area-edge BREAK that either gets ACCEPTED (a real breakout) or
//  REJECTED (faded back into value). AE-AVP builds the profile from public
//  auction concepts and learns that resolution:
//
//    * ML : an ONLINE LOGISTIC REGRESSION learns P(acceptance) at a VAH/VAL
//      break from node strength, momentum, volume surge, stretch-from-POC, trend
//      and regime. The label is a TRIPLE BARRIER on realized price (accept =
//      continues beyond by k*ATR; reject = falls back inside; within M bars) -
//      no lookahead. Low P(acceptance) flags a likely fade back to the POC.
//
//    * RL : a CONTEXTUAL BANDIT (UCB) auto-tunes the acceptance-confidence
//      threshold per volatility regime; its reward is tied to the same edge
//      resolution, so it is one coherent learning loop. Deterministic -> no
//      repaint.
//
//  Honest scope: a linear classifier + a UCB bandit over standard profile /
//  price features - not a neural net, not a guarantee. Training and signals gate
//  on bar close.
// ============================================================================

//@version=6
indicator("AetherEdge - Adaptive Volume Profile", "AE-AVP", overlay = true, max_boxes_count = 120, max_labels_count = 300, max_lines_count = 50)

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
grpP = "Volume profile"
lookback = input.int(150, "Profile lookback (bars)", minval = 20, maxval = 1200, group = grpP)
rows     = input.int(24, "Price bins (rows)", minval = 6, maxval = 60, group = grpP)
vaPct    = input.float(0.70, "Value area %", minval = 0.3, maxval = 0.95, step = 0.01, group = grpP)
atrLen   = input.int(14, "ATR length", minval = 1, group = grpP)

grpE = "Edge-break model"
acceptMult = input.float(0.5, "Acceptance distance (ATR)", minval = 0.1, step = 0.1, group = grpE)
rejectMult = input.float(0.5, "Rejection distance (ATR)", minval = 0.1, step = 0.1, group = grpE)
barM   = input.int(15, "Resolution horizon M (bars)", minval = 2, group = grpE)
lr     = input.float(0.03, "Learning rate", minval = 0.0001, step = 0.005, group = grpE)
l2     = input.float(0.0005, "L2 regularization", minval = 0.0, step = 0.0005, group = grpE)
warmup = input.int(150, "Warmup bars", minval = 20, group = grpE)

grpRL = "Adaptive threshold (UCB)"
thrBase = input.float(0.55, "Lowest threshold", minval = 0.3, maxval = 0.9, step = 0.01, group = grpRL)
thrStep = input.float(0.04, "Threshold step", minval = 0.01, step = 0.01, group = grpRL)
thrArms = input.int(5, "Threshold options", minval = 2, maxval = 8, group = grpRL)
ucbC    = input.float(1.0, "Exploration constant", minval = 0.0, step = 0.1, group = grpRL)
faPen   = input.float(0.7, "Wrong-call penalty", minval = 0.0, step = 0.1, group = grpRL)

grpV = "Visual"
showProfile = input.bool(true, "Draw profile histogram", group = grpV)
maxW = input.int(30, "Histogram width (bars)", minval = 5, maxval = 100, group = grpV)

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

// ----------------------------------------------------------------------------
//  VOLUME PROFILE  (rolling; POC / value area / node strength)
// ----------------------------------------------------------------------------
int NF = 7
atr     = ta.atr(atrLen)
atrSafe = math.max(nz(atr, nz(ta.tr, close * 0.001)), 1e-8)

var array<float> bins = array.new_float(rows, 0.0)

float loP = ta.lowest(low, lookback)
float hiP = ta.highest(high, lookback)
float binSize = math.max((hiP - loP) / rows, 1e-8)

array.fill(bins, 0.0)
for k = 0 to lookback - 1
    int bl = math.max(0, math.min(rows - 1, int(math.floor((low[k] - loP) / binSize))))
    int bh = math.max(0, math.min(rows - 1, int(math.floor((high[k] - loP) / binSize))))
    int span = bh - bl + 1
    float vshare = nz(volume[k], 0.0) / math.max(span, 1)
    for b = bl to bh
        array.set(bins, b, array.get(bins, b) + vshare)

int poc = 0
float maxV = -1.0
float total = 0.0
for b = 0 to rows - 1
    v = array.get(bins, b)
    total += v
    if v > maxV
        maxV := v
        poc := b

// value area: expand from POC to the heavier neighbour until vaPct of volume
float vaVol = total * vaPct
float accV = array.get(bins, poc)
int up = poc + 1
int dn = poc - 1
int loB = poc
int hiB = poc
for _i = 0 to rows - 1
    if accV >= vaVol
        break
    float vUp = up <= rows - 1 ? array.get(bins, up) : -1.0
    float vDn = dn >= 0 ? array.get(bins, dn) : -1.0
    if vUp < 0 and vDn < 0
        break
    if vUp >= vDn
        accV += vUp
        hiB := up
        up += 1
    else
        accV += vDn
        loB := dn
        dn -= 1

float pocPrice = loP + (poc + 0.5) * binSize
float vah = loP + (hiB + 1) * binSize
float val = loP + loB * binSize
int curBin = math.max(0, math.min(rows - 1, int(math.floor((close - loP) / binSize))))
float nodeNow = maxV > 0 ? array.get(bins, curBin) / maxV : 0.0

// ----------------------------------------------------------------------------
//  REGIME + ADAPTIVE THRESHOLD (RL)
// ----------------------------------------------------------------------------
atrPct = ta.percentrank(atrSafe, 100)
int regime = atrPct < 33.0 ? 0 : atrPct < 66.0 ? 1 : 2
var array<float> qTab = array.new_float(3 * thrArms, 0.0)
var array<int>   cTab = array.new_int(3 * thrArms, 0)
arm = f_ucb(qTab, cTab, regime, thrArms, ucbC)
thr = thrBase + arm * thrStep

// ----------------------------------------------------------------------------
//  EDGE-BREAK MODEL (ML) -- acceptance vs rejection
// ----------------------------------------------------------------------------
type Edge
    bool         up
    float        level
    int          bornBar
    array<float> feat
    int          regimeT
    int          armT
    float        pAcc
    bool         firedBrk
    bool         firedRej
    bool         resolved

var array<float> wAcc = array.new_float(NF + 1, 0.0)
var array<Edge>  pend = array.new<Edge>()
var int firedTotal = 0
var int firedCorrect = 0
var float lastPAcc = na

eF = ta.ema(close, 21)
eS = ta.ema(close, 50)
rsiV = ta.rsi(close, 14)

f_edgeFeat(int dir, float level) =>
    int eb = math.max(0, math.min(rows - 1, int(math.floor((level - loP) / binSize))))
    f1 = maxV > 0 ? array.get(bins, eb) / maxV : 0.0
    f2 = f_clamp(f_tanh((close - close[3]) / atrSafe) * dir, -1.0, 1.0)
    f3 = f_clamp(volume / math.max(ta.sma(volume, 20), 1e-8) - 1.0, -1.0, 3.0)
    f4 = f_clamp((close - pocPrice) / atrSafe * dir, -1.0, 5.0)
    f5 = f_clamp(f_tanh((eF - eS) / atrSafe) * dir, -1.0, 1.0)
    f6 = f_clamp(atrSafe / math.max(ta.sma(atrSafe, 50), 1e-8) - 1.0, -1.0, 2.0)
    f7 = f_clamp((vah - val) / atrSafe, 0.0, 10.0)
    array.from(f1, f2, f3, f4, f5, f6, f7)

upBreak = ta.crossover(close, vah)
dnBreak = ta.crossunder(close, val)
warmOK = bar_index > warmup

float pAccNow = na
if upBreak
    pAccNow := f_predict(wAcc, f_edgeFeat(1, vah))
if dnBreak
    pAccNow := f_predict(wAcc, f_edgeFeat(-1, val))
if not na(pAccNow)
    lastPAcc := pAccNow

// register edge event
if barstate.isconfirmed and (upBreak or dnBreak)
    dir = upBreak ? 1 : -1
    lvl = upBreak ? vah : val
    ft  = f_edgeFeat(dir, lvl)
    pa  = f_predict(wAcc, ft)
    fb  = pa >= thr
    fr  = pa <= (1.0 - thr)
    array.push(pend, Edge.new(upBreak, lvl, bar_index, ft, regime, arm, pa, fb, fr, false))

// resolve: accepted (continues) vs rejected (back inside) -> trains ML + bandit
if barstate.isconfirmed and array.size(pend) > 0
    for i = array.size(pend) - 1 to 0
        e = array.get(pend, i)
        if not e.resolved
            age = bar_index - e.bornBar
            int acc = -1
            if e.up
                if close >= e.level + acceptMult * atrSafe
                    acc := 1
                else if close <= e.level - rejectMult * atrSafe
                    acc := 0
            else
                if close <= e.level - acceptMult * atrSafe
                    acc := 1
                else if close >= e.level + rejectMult * atrSafe
                    acc := 0
            if acc == -1 and age >= barM
                acc := -2
            if acc >= 0
                accepted = acc == 1
                f_train(wAcc, e.feat, accepted ? 1.0 : 0.0, lr, l2)
                correct = (e.firedBrk and accepted) or (e.firedRej and not accepted)
                wrong   = (e.firedBrk and not accepted) or (e.firedRej and accepted)
                reward = correct ? 1.0 : wrong ? -faPen : 0.1
                idx = e.regimeT * thrArms + e.armT
                nC = array.get(cTab, idx) + 1
                array.set(cTab, idx, nC)
                array.set(qTab, idx, array.get(qTab, idx) + (reward - array.get(qTab, idx)) / nC)
                if e.firedBrk or e.firedRej
                    firedTotal += 1
                    firedCorrect += correct ? 1 : 0
                e.resolved := true
                array.remove(pend, i)
            else if acc == -2
                e.resolved := true
                array.remove(pend, i)

biasAcc = firedTotal > 0 ? firedCorrect / firedTotal : na

// ----------------------------------------------------------------------------
//  SIGNALS  (follow accepted breaks; fade rejected breaks toward POC)
// ----------------------------------------------------------------------------
brkLong  = barstate.isconfirmed and warmOK and upBreak and pAccNow >= thr
rejShort = barstate.isconfirmed and warmOK and upBreak and pAccNow <= (1.0 - thr)
brkShort = barstate.isconfirmed and warmOK and dnBreak and pAccNow >= thr
rejLong  = barstate.isconfirmed and warmOK and dnBreak and pAccNow <= (1.0 - thr)

// ----------------------------------------------------------------------------
//  DRAW PROFILE + LEVELS
// ----------------------------------------------------------------------------
plot(pocPrice, "POC", color = color.new(cGold, 0), style = plot.style_stepline, linewidth = 2)
plot(vah, "VAH", color = color.new(cBull, 30), style = plot.style_stepline)
plot(val, "VAL", color = color.new(cBear, 30), style = plot.style_stepline)

var array<box> pb = array.new<box>()
if showProfile and barstate.islast
    if array.size(pb) == 0
        for b = 0 to rows - 1
            array.push(pb, box.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, bgcolor = na, border_color = na))
    int baseX = bar_index + 2
    for b = 0 to rows - 1
        v = array.get(bins, b)
        vN = maxV > 0 ? v / maxV : 0.0
        int w = int(vN * maxW)
        float bt = loP + (b + 1) * binSize
        float bb = loP + b * binSize
        col = b == poc ? cGold : (b >= loB and b <= hiB ? color.new(cBull, 55) : color.new(cWait, 72))
        bx = array.get(pb, b)
        box.set_lefttop(bx, baseX, bt)
        box.set_rightbottom(bx, baseX + w + 1, bb)
        box.set_bgcolor(bx, col)
        box.set_border_color(bx, color.new(col, 35))

plotshape(brkLong,  title = "Breakout Long",  style = shape.triangleup,   location = location.belowbar, color = cBull, size = size.small, text = "BRK", textcolor = cBull)
plotshape(brkShort, title = "Breakout Short", style = shape.triangledown, location = location.abovebar, color = cBear, size = size.small, text = "BRK", textcolor = cBear)
plotshape(rejLong,  title = "Rejection Long", style = shape.diamond, location = location.belowbar, color = color.new(cBull, 20), size = size.tiny, text = "REJ", textcolor = cBull)
plotshape(rejShort, title = "Rejection Short", style = shape.diamond, location = location.abovebar, color = color.new(cBear, 20), size = size.tiny, text = "REJ", textcolor = cBear)

// ----------------------------------------------------------------------------
//  HUD
// ----------------------------------------------------------------------------
zoneTxt = close > vah ? "ABOVE VA" : close < val ? "BELOW VA" : "IN VALUE"
zoneCol = close > vah ? cBull : close < val ? cBear : cWait

var table hud = table.new(position.top_right, 2, 11, bgcolor = cBg1, frame_color = cGold, frame_width = 2, border_color = color.new(cGold, 60), border_width = 1)
if showHUD and barstate.islast
    ts = f_txtSize()
    table.cell(hud, 0, 0, "AE-AVP", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 0, "VOLUME PROFILE", text_color = cWait, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 0, 1, "POC", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 1, str.tostring(pocPrice, format.mintick), text_color = cGold, text_size = ts)
    table.cell(hud, 0, 2, "VAH", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 2, str.tostring(vah, format.mintick), text_color = cBull, text_size = ts)
    table.cell(hud, 0, 3, "VAL", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 3, str.tostring(val, format.mintick), text_color = cBear, text_size = ts)
    table.cell(hud, 0, 4, "Zone", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 4, zoneTxt, text_color = zoneCol, text_size = ts)
    table.cell(hud, 0, 5, "Node @ price", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 5, str.tostring(math.round(nodeNow * 100)) + "%", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 6, "P(accept)", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 6, na(lastPAcc) ? "-" : str.tostring(math.round(lastPAcc * 100)) + "%", text_color = not na(lastPAcc) and lastPAcc >= thr ? cBull : not na(lastPAcc) and lastPAcc <= (1.0 - thr) ? cBear : cTxt, text_size = ts)
    table.cell(hud, 0, 7, "Threshold", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 7, str.tostring(math.round(thr * 100)) + "% auto", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 8, "Call acc", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 8, na(biasAcc) ? "-" : str.tostring(math.round(biasAcc * 100)) + "% (" + str.tostring(firedTotal) + ")", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 9, "Regime", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 9, regime == 0 ? "TIGHT" : regime == 1 ? "MID" : "WIDE", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 10, "Model", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 10, warmOK ? "live" : "learning", text_color = warmOK ? cBull : cWait, bgcolor = cBg0, text_size = ts)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
alertcondition(brkLong or brkShort, "AE-AVP Breakout", "AE-AVP: accepted value-area breakout")
alertcondition(rejLong or rejShort, "AE-AVP Rejection", "AE-AVP: value-area edge rejection (fade to POC)")

if brkLong
    alert("AE-AVP BREAKOUT LONG | VAH accept " + str.tostring(math.round(nz(lastPAcc) * 100)) + "%", alert.freq_once_per_bar_close)
if brkShort
    alert("AE-AVP BREAKOUT SHORT | VAL accept " + str.tostring(math.round(nz(lastPAcc) * 100)) + "%", alert.freq_once_per_bar_close)
if rejShort
    alert("AE-AVP REJECTION at VAH | fade to POC " + str.tostring(pocPrice, format.mintick), alert.freq_once_per_bar_close)
if rejLong
    alert("AE-AVP REJECTION at VAL | fade to POC " + str.tostring(pocPrice, format.mintick), alert.freq_once_per_bar_close)
````
