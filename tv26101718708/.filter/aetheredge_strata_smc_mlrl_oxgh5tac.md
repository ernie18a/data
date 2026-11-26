# AetherEdge - STRATA | SMC + ML/RL

- url: https://www.tradingview.com/script/oxGH5tac/
- type: indicator
- pine_id: PUB;796c931327c24eab8c8c3bc8bcb67f8e
- version: 1.0

## Description

🖊️ Overview

AE-STRATA is an overlay toolkit that brings the main Smart Money Concepts (SMC / ICT) elements together and layers a genuine learning engine — online machine learning plus reinforcement learning — on top. Beyond drawing "where" (order blocks, FVGs, liquidity, structure shifts), it learns from that context to show which way price is more likely to go next (ML probability) and what stance to take now (RL action). The SMC drawings are re-implemented from public, generic ICT methods, with an honest learning layer added on top.

🔶 Key Features

Structure analysis — BOS/CHoCH (break/change of character) + swing labels (HH/HL/LH/LL)
Two-layer order blocks — two tiers of zones that fade on mitigation (testing)
FVG (fair value gaps) — tracked from creation to fill
Liquidity — EQH/EQL, sweeps, and traps
Premium / discount — expensive/cheap zones within the range
Deviation oscillator (Pulse) — quantifies stretch from the mean
ML probability — learns P(up over the next H bars) from seven SMC features
RL action — reinforcement learning suggests flat / long / short
A Smart Money Score (0–100) + ML probability + RL action in a gold HUD, dark theme
Learning is based on realized outcomes and gated on bar close — no repaint

🧠 Technical Architecture

SMC engine: order blocks, FVGs, BOS/CHoCH, liquidity, and premium/discount, re-implemented as public, generic ICT concepts.
Preprocessing: features are standardized online via EWMA, keeping a stable scale as the market changes.
ML (online logistic regression): seven SMC features feed an SGD + L2 model that learns P(up over the next H bars). Labels are H-bar-lagged realized returns, so the current prediction uses no future data.
RL (tabular Q-learning, TD(0)): a Q-table over 27 regime-discretized states × (flat / long / short). The reward is ATR-scaled realized return, and updates gate on barstate.isconfirmed; with more data it converges to the stance that pays in each regime.
Honest scope: online logistic regression + tabular Q-learning. Not deep learning (no DQN), and not a guarantee of the future.

⚙️ Recommended Settings & Tuning Guide

Main levers: structure (swing) length, order-block/FVG sensitivity, ML horizon H, learning rate, RL reward scale, Smart Money Score threshold.
Larger structure length → focus on major OBs/structure; smaller → more detections (and noise)
Larger horizon H → slower learning, swing-oriented; smaller → short-term
Higher learning rate → faster adaptation to recent conditions; lower → steadier
Crypto starting points (tune on your chart):
BTC / ETH (15m–4H): defaults are the baseline
SOL / XRP and high-vol alts: slightly longer structure length and tighter OB/FVG sensitivity to suppress wick noise
Scalping (1–15m): shorter horizon, slightly higher learning rate
Swing (4H–daily): longer horizon, ample warmup to fill out learning
The clearest setups are when ML probability, RL action, and the Smart Money Score all point the same way

💡 How to Use in Practice

Trade reactions off zones: price returns to a discount bullish OB or FVG with ML probability rising and RL = long supports a dip-buy (mirror for bearish)
Confirm structure: read BOS/CHoCH for the regime shift and check it agrees with the ML/RL direction
Smart Money Score: a 0–100 composite for the current edge at a glance
Reading the ML probability: high favors upside, low favors downside; near 50% is neutral — stand aside
RL action: a flat/long/short stance suggestion — read alongside the probability and score
Combinations: pairing with a strength oscillator or a higher-timeframe view improves precision

⚠️ Important Notes

Learning period: ML probability and RL action are unsettled until the model spins up (warmup)
Learning reset: changing inputs, symbol, or timeframe re-learns the internal state (weights and Q-table)
SMC is probabilistic: OBs/FVGs/liquidity are levels likely to react, not certainties
Probability, not a guarantee: the ML probability and RL action can be wrong — always use stops and position sizing

🚨 Disclaimer

This indicator is for educational and informational purposes only and is not financial advice or a recommendation to buy or sell. No method guarantees future profits; past performance does not indicate future results, and trading carries the risk of loss. All trading decisions are your own — use proper backtesting and disciplined risk management.

## Source Code

````pine
// ============================================================================
//  AE-STRATA  |  AetherEdge Series
//  Smart Money Concepts toolkit + adaptive ML/RL core
//
//  An original overlay that maps institutional market structure using standard,
//  public ICT / SMC concepts (Order Blocks, Fair Value Gaps, BOS/CHoCH market
//  structure, liquidity sweeps/traps, premium/discount range, a deviation
//  oscillator, HUD dashboard) -- then layers two genuinely-implemented learning
//  components on top:
//
//    * ML  : online LOGISTIC REGRESSION trained by stochastic gradient
//            descent (SGD) on realized forward returns. Honest scope: a linear
//            probabilistic classifier, not a deep net. Output = "Smart Money
//            probability" P(up over the next H bars).
//
//    * RL  : tabular Q-LEARNING agent (temporal-difference TD(0) update with
//            the Bellman target) over a discretized market-regime state space.
//            Learns the value of {flat, long, short} per regime from realized
//            bar returns. Honest scope: classic tabular Q-learning, not DQN.
//
//  Pre-processing: EWMA online feature standardization (zero-mean / unit-var).
//
//  No-repaint design: every learning update and signal is gated on
//  barstate.isconfirmed and uses only past/closed data for the current call.
// ============================================================================

//@version=6
indicator("AetherEdge - STRATA | SMC + ML/RL", "AE-STRATA", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ----------------------------------------------------------------------------
//  THEME / PALETTE  (AetherEdge gold-frame HUD)
// ----------------------------------------------------------------------------
cGold   = #d4af37                       // HUD frame / CHoCH accent
cBg0    = #080b0a                       // HUD background (header)
cBg1    = #0f1614                       // HUD background (body)
cTxt    = #eef2f0                       // HUD primary text
cBull   = #26a69a                       // bullish / demand
cBear   = #ef5350                       // bearish / supply
cTrap   = #e040fb                       // trap (institutional manipulation)
cNeutral= #8d99a6

// ----------------------------------------------------------------------------
//  INPUTS  (crypto-friendly defaults)
// ----------------------------------------------------------------------------
grpS   = "Structure & Swings"
pivLeft   = input.int(8,  "Pivot left",  minval = 1, group = grpS)
pivRight  = input.int(8,  "Pivot right", minval = 1, group = grpS, tooltip = "Larger = fewer, more reliable swings. Pivots confirm 'right' bars back (no repaint once confirmed).")
showStruct= input.bool(true, "Show BOS / CHoCH", group = grpS)
showSwings= input.bool(true, "Show HH / HL / LH / LL labels", group = grpS)

grpOB  = "Order Blocks"
showOB    = input.bool(true, "Show order blocks", group = grpOB)
maxOB     = input.int(6, "Max active blocks", minval = 1, maxval = 30, group = grpOB)
obLookback= input.int(12, "Origin search window", minval = 2, maxval = 50, group = grpOB, tooltip = "How far back to find the last opposite candle that originated the breakout leg.")

grpFV  = "Fair Value Gaps"
showFVG   = input.bool(true, "Show fair value gaps", group = grpFV)
maxFVG    = input.int(6, "Max active FVGs", minval = 1, maxval = 30, group = grpFV)
fvgMinAtr = input.float(0.10, "Min gap size (ATR)", minval = 0.0, step = 0.05, group = grpFV)

grpLQ  = "Liquidity (EQH/EQL, Sweeps, Traps)"
showLiq   = input.bool(true, "Show liquidity & sweeps", group = grpLQ)
eqTolAtr  = input.float(0.10, "Equal-level tolerance (ATR)", minval = 0.0, step = 0.05, group = grpLQ)
sweepAtr  = input.float(0.25, "Sweep depth (ATR)", minval = 0.0, step = 0.05, group = grpLQ)
trapVolX  = input.float(1.8,  "Trap volume multiple", minval = 1.0, step = 0.1, group = grpLQ, tooltip = "A sweep with volume above (volume SMA x this) is flagged as a Smart-Money trap.")
maxLiq    = input.int(8, "Max tracked levels", minval = 1, maxval = 30, group = grpLQ)

grpRG  = "Premium / Discount"
showPD    = input.bool(true, "Show premium / discount zones", group = grpRG)
rangeLen  = input.int(80, "Range lookback", minval = 10, group = grpRG)

grpOS  = "Pulse Oscillator"
oscLen    = input.int(20, "Oscillator length", minval = 2, group = grpOS, tooltip = "MA-deviation momentum, normalized to a z-score. Feeds the ML feature vector and the regime state.")
oscTint   = input.bool(true, "Tint background on stretch", group = grpOS)

grpML  = "ML  -  Online Logistic Regression"
useML     = input.bool(true,  "Enable ML probability", group = grpML)
mlHorizon = input.int(8,  "Forecast horizon H (bars)", minval = 1, maxval = 100, group = grpML, tooltip = "Trains to predict P(close rises over the next H bars). Labels use only already-realized data.")
mlLR      = input.float(0.02, "Learning rate", minval = 0.0001, step = 0.005, group = grpML)
mlL2      = input.float(0.0005,"L2 regularization", minval = 0.0, step = 0.0005, group = grpML)
mlAlpha   = input.float(0.02, "Standardization EWMA", minval = 0.001, maxval = 0.5, step = 0.005, group = grpML)
mlWarmup  = input.int(150, "Warmup bars", minval = 20, group = grpML, tooltip = "Bars to learn before signals are allowed.")

grpRL  = "RL  -  Tabular Q-Learning"
useRL     = input.bool(true,  "Enable RL action gate", group = grpRL)
rlAlpha   = input.float(0.10, "RL learning rate (alpha)", minval = 0.001, maxval = 1.0, step = 0.01, group = grpRL)
rlGamma   = input.float(0.90, "RL discount (gamma)", minval = 0.0, maxval = 0.999, step = 0.01, group = grpRL)
rlFlatPen = input.float(0.10, "Flat opportunity penalty", minval = 0.0, step = 0.05, group = grpRL, tooltip = "Flat is rewarded -penalty*|return|, so idling through big moves is discouraged.")

grpSG  = "Signals"
probHi    = input.float(0.58, "Long prob threshold", minval = 0.5, maxval = 0.95, step = 0.01, group = grpSG)
probLo    = input.float(0.42, "Short prob threshold", minval = 0.05, maxval = 0.5, step = 0.01, group = grpSG)
requireConfluence = input.bool(true, "Require SMC confluence", group = grpSG, tooltip = "Gate signals on structure + (order block / FVG / sweep) agreement.")

grpUI  = "Dashboard"
showHUD   = input.bool(true, "Show HUD", group = grpUI)
hudSize   = input.string("normal", "HUD size", options = ["tiny","small","normal","large"], group = grpUI)

// ----------------------------------------------------------------------------
//  USER-DEFINED TYPES  (every structural element as a self-contained object)
// ----------------------------------------------------------------------------
type OrderBlock
    float top
    float bot
    bool  isBull
    bool  mitigated
    int   bornBar
    box   boxOuter
    box   boxInner

type FairGap
    float top
    float bot
    bool  isBull
    bool  filled
    int   bornBar
    box   bx

type LiqLevel
    float lvl
    bool  isHigh        // true = buy-side (equal highs), false = sell-side (equal lows)
    int   bornBar
    bool  swept
    line  ln

// ----------------------------------------------------------------------------
//  MATH / ML HELPERS
// ----------------------------------------------------------------------------
// Clamp a value to [lo, hi].
f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

// Numerically-stable logistic sigmoid.
f_sigmoid(float z) =>
    1.0 / (1.0 + math.exp(-f_clamp(z, -30.0, 30.0)))

// Update EWMA running mean & variance (West's incremental form) IN PLACE.
f_statsUpdate(array<float> mean, array<float> varr, array<float> x, float a) =>
    for i = 0 to array.size(x) - 1
        v  = array.get(x, i)
        m0 = array.get(mean, i)
        m1 = m0 + a * (v - m0)
        d  = v - m1
        vr = (1.0 - a) * (array.get(varr, i) + a * d * d)
        array.set(mean, i, m1)
        array.set(varr, i, vr)

// Standardize a raw feature vector with current stats (read-only). Returns a new array.
f_standardize(array<float> x, array<float> mean, array<float> varr) =>
    out = array.new_float(0)
    for i = 0 to array.size(x) - 1
        sd = math.sqrt(math.max(array.get(varr, i), 1e-10))
        array.push(out, f_clamp((array.get(x, i) - array.get(mean, i)) / sd, -6.0, 6.0))
    out

// Logistic-regression forward pass: returns P(label = 1). w[0] is the bias.
f_predict(array<float> w, array<float> x) =>
    z = array.get(w, 0)
    for i = 0 to array.size(x) - 1
        z += array.get(w, i + 1) * array.get(x, i)
    f_sigmoid(z)

// One SGD step on the log-loss with L2 penalty, updating w IN PLACE.
// Gradient of log-loss w.r.t. the logit z is simply (p - y).
f_train(array<float> w, array<float> x, float y, float lr, float l2) =>
    p   = f_predict(w, x)
    err = p - y
    array.set(w, 0, array.get(w, 0) - lr * err)                       // bias has no L2
    for i = 0 to array.size(x) - 1
        g = err * array.get(x, i) + l2 * array.get(w, i + 1)
        array.set(w, i + 1, array.get(w, i + 1) - lr * g)

// ----------------------------------------------------------------------------
//  RL HELPERS  (state index = bias*9 + vol*3 + osc ; 3 buckets each -> 27 states)
// ----------------------------------------------------------------------------
f_qGet(array<float> q, int s, int a) => array.get(q, s * 3 + a)
f_qSet(array<float> q, int s, int a, float v) => array.set(q, s * 3 + a, v)

// Max action-value at a state (Bellman bootstrap target).
f_qMax(array<float> q, int s) =>
    math.max(f_qGet(q, s, 0), math.max(f_qGet(q, s, 1), f_qGet(q, s, 2)))

// Greedy action at a state: 0 = flat, 1 = long, 2 = short.
f_qArgmax(array<float> q, int s) =>
    q0 = f_qGet(q, s, 0)
    q1 = f_qGet(q, s, 1)
    q2 = f_qGet(q, s, 2)
    int best = 0
    float bv = q0
    if q1 > bv
        best := 1
        bv := q1
    if q2 > bv
        best := 2
        bv := q2
    best

// Confidence in the greedy action: how far the best value sits above the mean,
// squashed to [0,1]. Used only for the cosmetic Smart-Money Score.
f_qConfidence(array<float> q, int s) =>
    q0 = f_qGet(q, s, 0)
    q1 = f_qGet(q, s, 1)
    q2 = f_qGet(q, s, 2)
    mx = math.max(q0, math.max(q1, q2))
    mean = (q0 + q1 + q2) / 3.0
    f_sigmoid((mx - mean) * 4.0)

// ----------------------------------------------------------------------------
//  PHASE 1  -  VOLATILITY, PIVOTS, OSCILLATOR
// ----------------------------------------------------------------------------
atr   = ta.atr(14)
atrSafe = math.max(atr, 1e-10)

// Pivots confirm 'pivRight' bars back -> the returned value is fixed (no repaint).
ph = ta.pivothigh(pivLeft, pivRight)
pl = ta.pivotlow(pivLeft, pivRight)

// Pulse Oscillator: deviation of price from its mean, normalized to a z-score.
oscMa  = ta.sma(close, oscLen)
oscSd  = math.max(ta.stdev(close, oscLen), 1e-10)
oscZ   = (close - oscMa) / oscSd

// Volatility regime z-score (for the RL state).
volMa  = ta.sma(atr, 50)
volSd  = math.max(ta.stdev(atr, 50), 1e-10)
volZ   = (atr - volMa) / volSd

// ----------------------------------------------------------------------------
//  PHASE 2  -  MARKET STRUCTURE  (BOS / CHoCH, swing labels)
// ----------------------------------------------------------------------------
var float lastSwingH   = na          // most recent confirmed swing-high price
var float lastSwingL   = na          // most recent confirmed swing-low  price
var float prevSwingH   = na
var float prevSwingL   = na
var int   trendDir     = 0           // +1 up, -1 down, 0 undefined
var bool  brokeHigh    = false       // armed: a new swing high is available to break
var bool  brokeLow     = false
var string lastSwingLbl = "-"        // persisted swing type, for the HUD

// Capture confirmed swings and tag HH/HL/LH/LL.
if not na(ph)
    prevSwingH := lastSwingH
    lastSwingH := ph
    brokeHigh  := true
    isHH = not na(prevSwingH) and ph > prevSwingH
    lastSwingLbl := isHH ? "HH" : "LH"
    if showSwings
        label.new(bar_index - pivRight, ph, isHH ? "HH" : "LH", xloc = xloc.bar_index, yloc = yloc.abovebar, style = label.style_none, textcolor = isHH ? cBull : cBear, size = size.tiny)

if not na(pl)
    prevSwingL := lastSwingL
    lastSwingL := pl
    brokeLow   := true
    isHL = not na(prevSwingL) and pl > prevSwingL
    lastSwingLbl := isHL ? "HL" : "LL"
    if showSwings
        label.new(bar_index - pivRight, pl, isHL ? "HL" : "LL", xloc = xloc.bar_index, yloc = yloc.belowbar, style = label.style_none, textcolor = isHL ? cBull : cBear, size = size.tiny)

// Break-of-structure / change-of-character detection on confirmed closes.
bosUp    = false
bosDn    = false
chochUp  = false
chochDn  = false

if barstate.isconfirmed and not na(lastSwingH) and brokeHigh and close > lastSwingH
    if trendDir == 1
        bosUp := true
    else
        chochUp := true
    trendDir  := 1
    brokeHigh := false

if barstate.isconfirmed and not na(lastSwingL) and brokeLow and close < lastSwingL
    if trendDir == -1
        bosDn := true
    else
        chochDn := true
    trendDir  := -1
    brokeLow  := false

// Draw structure breaks (bar_time avoids the line x-distance limit on far swings).
if showStruct and (bosUp or chochUp)
    line.new(time[1], close, time, close, xloc = xloc.bar_time, color = chochUp ? cGold : cBull, width = 2, style = chochUp ? line.style_dashed : line.style_solid)
    label.new(bar_index, high, chochUp ? "CHoCH" : "BOS", xloc = xloc.bar_index, yloc = yloc.abovebar, style = label.style_label_down, color = color.new(chochUp ? cGold : cBull, 20), textcolor = cBg0, size = size.small)
if showStruct and (bosDn or chochDn)
    line.new(time[1], close, time, close, xloc = xloc.bar_time, color = chochDn ? cGold : cBear, width = 2, style = chochDn ? line.style_dashed : line.style_solid)
    label.new(bar_index, low, chochDn ? "CHoCH" : "BOS", xloc = xloc.bar_index, yloc = yloc.belowbar, style = label.style_label_up, color = color.new(chochDn ? cGold : cBear, 20), textcolor = cBg0, size = size.small)

newBullStruct = bosUp or chochUp
newBearStruct = bosDn or chochDn

// ----------------------------------------------------------------------------
//  PHASE 3  -  ORDER BLOCKS  (two-layer boxes, auto-mitigation)
// ----------------------------------------------------------------------------
var array<OrderBlock> obs = array.new<OrderBlock>()

// On a fresh bullish break, the demand block is the last DOWN candle that
// originated the up-leg (classic ICT). Mirror for bearish.
f_makeOB(bool bull) =>
    int found = -1
    for i = 1 to obLookback
        // bullish OB <- last bearish candle ; bearish OB <- last bullish candle
        cond = bull ? (close[i] < open[i]) : (close[i] > open[i])
        if cond and found == -1
            found := i
    if found >= 0 and showOB
        t = high[found]
        b = low[found]
        oc = bull ? cBull : cBear
        bx0 = box.new(bar_index - found, t, bar_index, b, border_color = color.new(oc, 40), bgcolor = color.new(oc, 88), border_width = 1)        // soft outer band
        mid = math.avg(t, b)
        inT = bull ? mid : t                                  // tighter inner zone
        inB = bull ? b   : mid
        bx1 = box.new(bar_index - found, inT, bar_index, inB, border_color = color.new(oc, 10), bgcolor = color.new(oc, 70), border_width = 1)
        ob = OrderBlock.new(top = t, bot = b, isBull = bull, mitigated = false, bornBar = bar_index, boxOuter = bx0, boxInner = bx1)
        array.push(obs, ob)
        if array.size(obs) > maxOB
            old = array.shift(obs)
            box.delete(old.boxOuter)
            box.delete(old.boxInner)

if newBullStruct
    f_makeOB(true)
if newBearStruct
    f_makeOB(false)

// Maintain blocks: extend right, fade on mitigation, expose proximity signals.
float obPressure = 0.0
if array.size(obs) > 0
    for i = array.size(obs) - 1 to 0
        ob = array.get(obs, i)
        if not ob.mitigated
            box.set_right(ob.boxOuter, bar_index)
            box.set_right(ob.boxInner, bar_index)
            // Mitigation: a close back through the block's far edge.
            mit = ob.isBull ? (close < ob.bot) : (close > ob.top)
            if mit
                ob.mitigated := true
                fadeC = color.new(color.gray, 80)
                box.set_bgcolor(ob.boxOuter, fadeC)
                box.set_bgcolor(ob.boxInner, fadeC)
                box.set_border_color(ob.boxOuter, color.new(color.gray, 60))
                box.set_border_color(ob.boxInner, color.new(color.gray, 60))
            else
                // Proximity pressure for the ML feature vector.
                near = (close <= ob.top + atr) and (close >= ob.bot - atr)
                if near
                    obPressure += ob.isBull ? 1.0 : -1.0
        array.set(obs, i, ob)
obPressure := f_clamp(obPressure, -1.0, 1.0)

// ----------------------------------------------------------------------------
//  PHASE 4  -  FAIR VALUE GAPS  (3-candle imbalance, removed on fill)
// ----------------------------------------------------------------------------
var array<FairGap> fvgs = array.new<FairGap>()

// Bullish FVG: low[0] > high[2] (gap up). Bearish FVG: high[0] < low[2] (gap down).
bullFVG = low > high[2]
bearFVG = high < low[2]

if barstate.isconfirmed and showFVG and bullFVG
    t = low
    b = high[2]
    if (t - b) >= fvgMinAtr * atr
        bx = box.new(bar_index - 2, t, bar_index, b, border_color = color.new(cBull, 60), bgcolor = color.new(cBull, 82), border_width = 1)
        array.push(fvgs, FairGap.new(top = t, bot = b, isBull = true, filled = false, bornBar = bar_index, bx = bx))
if barstate.isconfirmed and showFVG and bearFVG
    t = low[2]
    b = high
    if (t - b) >= fvgMinAtr * atr
        bx = box.new(bar_index - 2, t, bar_index, b, border_color = color.new(cBear, 60), bgcolor = color.new(cBear, 82), border_width = 1)
        array.push(fvgs, FairGap.new(top = t, bot = b, isBull = false, filled = false, bornBar = bar_index, bx = bx))

// Maintain FVGs: extend, remove on fill, expose proximity signal. Cap count.
float fvgPressure = 0.0
if array.size(fvgs) > 0
    for i = array.size(fvgs) - 1 to 0
        fg = array.get(fvgs, i)
        box.set_right(fg.bx, bar_index)
        filled = (low <= fg.top) and (high >= fg.bot)     // price traded back into the gap
        if filled
            box.delete(fg.bx)
            array.remove(fvgs, i)
        else
            near = (close <= fg.top + atr) and (close >= fg.bot - atr)
            if near
                fvgPressure += fg.isBull ? 1.0 : -1.0
// Trim oldest if over budget.
while array.size(fvgs) > maxFVG
    old = array.shift(fvgs)
    box.delete(old.bx)
fvgPressure := f_clamp(fvgPressure, -1.0, 1.0)

// ----------------------------------------------------------------------------
//  PHASE 5  -  LIQUIDITY  (equal highs/lows, sweeps, traps)
// ----------------------------------------------------------------------------
var array<LiqLevel> liqs = array.new<LiqLevel>()
volMaL = ta.sma(volume, 20)

// Register equal highs / equal lows when consecutive pivots match within tolerance.
if showLiq and not na(ph) and not na(prevSwingH) and math.abs(ph - prevSwingH) <= eqTolAtr * atr
    ln = line.new(time[pivRight], ph, time, ph, xloc = xloc.bar_time, color = color.new(cBear, 30), width = 1, style = line.style_dotted)
    array.push(liqs, LiqLevel.new(lvl = ph, isHigh = true, bornBar = bar_index, swept = false, ln = ln))
if showLiq and not na(pl) and not na(prevSwingL) and math.abs(pl - prevSwingL) <= eqTolAtr * atr
    ln = line.new(time[pivRight], pl, time, pl, xloc = xloc.bar_time, color = color.new(cBull, 30), width = 1, style = line.style_dotted)
    array.push(liqs, LiqLevel.new(lvl = pl, isHigh = false, bornBar = bar_index, swept = false, ln = ln))

// Sweep / trap detection + decaying liquidity pressure feature.
var float sweepScore = 0.0
sweepScore := sweepScore * 0.9                                 // decay each bar
if array.size(liqs) > 0
    for i = array.size(liqs) - 1 to 0
        lq = array.get(liqs, i)
        line.set_x2(lq.ln, time)
        if not lq.swept
            // Buy-side sweep: wick pierces an equal-high then the bar closes back below.
            if lq.isHigh and high > lq.lvl + sweepAtr * atr and close < lq.lvl
                lq.swept := true
                isTrap = volume > volMaL * trapVolX
                label.new(bar_index, high, isTrap ? "TRAP" : "SWEEP", xloc = xloc.bar_index, yloc = yloc.abovebar, style = label.style_label_down, color = color.new(isTrap ? cTrap : cGold, 10), textcolor = cBg0, size = size.tiny)
                sweepScore := -1.0                              // bearish liquidity grab above
            // Sell-side sweep: wick pierces an equal-low then the bar closes back above.
            if not lq.isHigh and low < lq.lvl - sweepAtr * atr and close > lq.lvl
                lq.swept := true
                isTrap = volume > volMaL * trapVolX
                label.new(bar_index, low, isTrap ? "TRAP" : "SWEEP", xloc = xloc.bar_index, yloc = yloc.belowbar, style = label.style_label_up, color = color.new(isTrap ? cTrap : cGold, 10), textcolor = cBg0, size = size.tiny)
                sweepScore := 1.0                               // bullish liquidity grab below
        array.set(liqs, i, lq)
while array.size(liqs) > maxLiq
    old = array.shift(liqs)
    line.delete(old.ln)
sweepScore := f_clamp(sweepScore, -1.0, 1.0)

// ----------------------------------------------------------------------------
//  PHASE 6  -  PREMIUM / DISCOUNT RANGE
// ----------------------------------------------------------------------------
rHi = ta.highest(high, rangeLen)
rLo = ta.lowest(low, rangeLen)
eq  = math.avg(rHi, rLo)
rangePos = f_clamp((close - eq) / math.max((rHi - rLo) / 2.0, 1e-10), -1.0, 1.0)   // -1 deep discount .. +1 deep premium

var box pdPrem = na
var box pdDisc = na
if showPD
    if na(pdPrem)
        pdPrem := box.new(bar_index, rHi, bar_index, eq, border_color = na, bgcolor = color.new(cBear, 92))
        pdDisc := box.new(bar_index, eq, bar_index, rLo, border_color = na, bgcolor = color.new(cBull, 92))
    box.set_lefttop(pdPrem, bar_index - rangeLen, rHi)
    box.set_rightbottom(pdPrem, bar_index, eq)
    box.set_lefttop(pdDisc, bar_index - rangeLen, eq)
    box.set_rightbottom(pdDisc, bar_index, rLo)

// ----------------------------------------------------------------------------
//  PHASE 7  -  FEATURE VECTOR  (raw, then EWMA-standardized)
// ----------------------------------------------------------------------------
int NFEAT = 7

// Raw features (all are series, computable at the current close -> no lookahead).
// nz() guards the warmup window so na never poisons the running statistics.
sx1 = nz(f_clamp((ta.ema(close, 8) - ta.ema(close, 21)) / atrSafe, -6.0, 6.0))   // trend/structure slope
sx2 = nz(obPressure)                                                              // order-block proximity (signed)
sx3 = nz(fvgPressure)                                                             // FVG proximity (signed)
sx4 = nz(sweepScore)                                                              // liquidity-sweep pressure (signed, decaying)
sx5 = nz(rangePos)                                                                // premium(+) / discount(-)
sx6 = nz(f_clamp(oscZ, -6.0, 6.0))                                                // pulse oscillator z
sx7 = nz(f_clamp((close - close[5]) / (atrSafe * math.sqrt(5)), -6.0, 6.0))       // short momentum z

// Persistent ML state.
var array<float> w     = array.new_float(NFEAT + 1, 0.0)   // logistic weights (+bias at index 0)
var array<float> fMean = array.new_float(NFEAT, 0.0)       // EWMA feature means
var array<float> fVar  = array.new_float(NFEAT, 1.0)       // EWMA feature variances

// Build current raw vector.
xRaw = array.from(sx1, sx2, sx3, sx4, sx5, sx6, sx7)

// Update running stats on the current vector, then standardize for prediction.
if barstate.isconfirmed and useML
    f_statsUpdate(fMean, fVar, xRaw, mlAlpha)
xStd = f_standardize(xRaw, fMean, fVar)

// ----------------------------------------------------------------------------
//  PHASE 8  -  ML  : ONLINE LOGISTIC REGRESSION (SGD)
// ----------------------------------------------------------------------------
// Train on the lagged vector whose forward outcome is now fully realized:
//   features captured H bars ago, label = did price rise over those H bars.
// This uses only data up to the current bar -> strictly no lookahead.
xLagRaw = array.from(sx1[mlHorizon], sx2[mlHorizon], sx3[mlHorizon], sx4[mlHorizon], sx5[mlHorizon], sx6[mlHorizon], sx7[mlHorizon])

if barstate.isconfirmed and useML and bar_index > mlHorizon and not na(close[mlHorizon])
    label1 = close > close[mlHorizon] ? 1.0 : 0.0
    xLagStd = f_standardize(xLagRaw, fMean, fVar)
    f_train(w, xLagStd, label1, mlLR, mlL2)

// Current probability that price rises over the next H bars.
mlProb = useML ? f_predict(w, xStd) : 0.5

// ----------------------------------------------------------------------------
//  PHASE 9  -  RL  : TABULAR Q-LEARNING (TD(0))
// ----------------------------------------------------------------------------
// Discretize the regime into 3 x 3 x 3 = 27 states.
biasB = sx1 < -0.10 ? 0 : (sx1 > 0.10 ? 2 : 1)
volB  = volZ < -0.50 ? 0 : (volZ > 0.50 ? 2 : 1)
oscB  = oscZ < -1.00 ? 0 : (oscZ > 1.00 ? 2 : 1)
stateNow = biasB * 9 + volB * 3 + oscB

var array<float> qTab = array.new_float(27 * 3, 0.0)   // Q(state, action)
var int   sPrev = na
var int   aPrev = na

// Realized reward for the action taken on the PREVIOUS bar, sized by ATR.
ret = nz((close - close[1]) / atrSafe)

if barstate.isconfirmed and useRL and not na(sPrev) and not na(aPrev)
    float reward = aPrev == 1 ? ret : (aPrev == 2 ? -ret : -rlFlatPen * math.abs(ret))
    // TD(0) update:  Q(s,a) <- Q(s,a) + alpha * [ r + gamma * max_a' Q(s',a') - Q(s,a) ]
    qOld   = f_qGet(qTab, sPrev, aPrev)
    target = reward + rlGamma * f_qMax(qTab, stateNow)
    f_qSet(qTab, sPrev, aPrev, qOld + rlAlpha * (target - qOld))

// Greedy action for the current state, and confidence for the score.
rlAction = useRL ? f_qArgmax(qTab, stateNow) : 0
rlConf   = useRL ? f_qConfidence(qTab, stateNow) : 0.0

// Carry state/action forward for the next bar's credit assignment.
if barstate.isconfirmed
    sPrev := stateNow
    aPrev := rlAction

// ----------------------------------------------------------------------------
//  PHASE 10  -  SIGNAL FUSION  (ML prob + RL action + SMC confluence)
// ----------------------------------------------------------------------------
// Composite "Smart Money Score" 0..100 (probability-weighted, RL-confirmed).
sms = math.round(100.0 * f_clamp(0.65 * mlProb + 0.35 * (rlAction == 1 ? rlConf : rlAction == 2 ? 1.0 - rlConf : 0.5), 0.0, 1.0))

warmOK = bar_index > mlWarmup

// SMC confluence: structure agrees AND an order-block / FVG / sweep supports it.
bullConfluence = (trendDir == 1 or chochUp) and (obPressure > 0 or fvgPressure > 0 or sweepScore > 0) and rangePos < 0.5
bearConfluence = (trendDir == -1 or chochDn) and (obPressure < 0 or fvgPressure < 0 or sweepScore < 0) and rangePos > -0.5

// A fresh trigger (avoids signal spam): probability cross, new structure, or sweep reversal.
bullTrigger = ta.crossover(mlProb, probHi) or newBullStruct or sweepScore > 0.8
bearTrigger = ta.crossunder(mlProb, probLo) or newBearStruct or sweepScore < -0.8

longSig  = barstate.isconfirmed and warmOK and mlProb > probHi and (not useRL or rlAction == 1) and bullTrigger and (not requireConfluence or bullConfluence)
shortSig = barstate.isconfirmed and warmOK and mlProb < probLo and (not useRL or rlAction == 2) and bearTrigger and (not requireConfluence or bearConfluence)

plotshape(longSig,  title = "Long",  style = shape.triangleup,   location = location.belowbar, color = cBull, size = size.small, text = "BUY",  textcolor = cBull)
plotshape(shortSig, title = "Short", style = shape.triangledown, location = location.abovebar, color = cBear, size = size.small, text = "SELL", textcolor = cBear)

// Optional momentum-stretch background tint.
bgcolor(oscTint and oscZ > 2.0 ? color.new(cBear, 92) : oscTint and oscZ < -2.0 ? color.new(cBull, 92) : na, title = "Stretch tint")

// ----------------------------------------------------------------------------
//  PHASE 11  -  HUD DASHBOARD  (gold frame)
// ----------------------------------------------------------------------------
f_txtSize() => hudSize == "tiny" ? size.tiny : hudSize == "small" ? size.small : hudSize == "large" ? size.large : size.normal

biasTxt = trendDir == 1 ? "BULL" : trendDir == -1 ? "BEAR" : "NEUTRAL"
biasCol = trendDir == 1 ? cBull : trendDir == -1 ? cBear : cNeutral

// Count active (unmitigated) order blocks.
int obActive = 0
if array.size(obs) > 0
    for i = 0 to array.size(obs) - 1
        if not array.get(obs, i).mitigated
            obActive += 1
fvgActive = array.size(fvgs)

lastSwingTxt = lastSwingLbl
actTxt = rlAction == 1 ? "LONG" : rlAction == 2 ? "SHORT" : "FLAT"
actCol = rlAction == 1 ? cBull : rlAction == 2 ? cBear : cNeutral
sweepTxt = sweepScore > 0.5 ? "SELL-SIDE" : sweepScore < -0.5 ? "BUY-SIDE" : "none"

var table hud = table.new(position.top_right, 2, 10, bgcolor = cBg1, frame_color = cGold, frame_width = 2, border_color = color.new(cGold, 60), border_width = 1)

if showHUD and barstate.islast
    ts = f_txtSize()
    table.cell(hud, 0, 0, "AE-STRATA", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 0, "SMC + ML/RL", text_color = cNeutral, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 0, 1, "Bias",        text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 1, biasTxt,       text_color = biasCol, text_size = ts)
    table.cell(hud, 0, 2, "Last swing",  text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 2, lastSwingTxt,  text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 3, "Active OB",   text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 3, str.tostring(obActive), text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 4, "Open FVG",    text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 4, str.tostring(fvgActive), text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 5, "Sweep",       text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 5, sweepTxt,      text_color = sweepScore > 0.5 ? cBull : sweepScore < -0.5 ? cBear : cNeutral, text_size = ts)
    table.cell(hud, 0, 6, "Range",       text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 6, rangePos > 0.33 ? "PREMIUM" : rangePos < -0.33 ? "DISCOUNT" : "EQUILIBRIUM", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 7, "ML prob (up)",text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 7, str.tostring(math.round(mlProb * 100)) + "%", text_color = mlProb > 0.5 ? cBull : cBear, text_size = ts)
    table.cell(hud, 0, 8, "RL action",   text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 8, actTxt + " (" + str.tostring(math.round(rlConf * 100)) + "%)", text_color = actCol, text_size = ts)
    table.cell(hud, 0, 9, "SMART MONEY", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 9, str.tostring(sms) + " / 100", text_color = sms >= 50 ? cBull : cBear, bgcolor = cBg0, text_size = ts)

// ----------------------------------------------------------------------------
//  PHASE 12  -  ALERTS
// ----------------------------------------------------------------------------
alertcondition(longSig,  "AE-STRATA Long",  "AE-STRATA long signal")
alertcondition(shortSig, "AE-STRATA Short", "AE-STRATA short signal")
alertcondition(bosUp or bosDn,     "AE-STRATA BOS",   "AE-STRATA break of structure")
alertcondition(chochUp or chochDn, "AE-STRATA CHoCH", "AE-STRATA change of character")

if longSig
    alert("AE-STRATA BUY | prob " + str.tostring(math.round(mlProb * 100)) + "% | score " + str.tostring(sms), alert.freq_once_per_bar_close)
if shortSig
    alert("AE-STRATA SELL | prob " + str.tostring(math.round(mlProb * 100)) + "% | score " + str.tostring(sms), alert.freq_once_per_bar_close)
````
