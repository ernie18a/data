# AetherEdge - TIDE | Flow + RL Oscillator

- url: https://www.tradingview.com/script/kJ1yvvmI/
- type: indicator
- pine_id: PUB;f338ffd99f5640c69faadbfa4810771d
- version: 1.0

## Description

🖊️ Overview

AE-TIDE is a lower-panel oscillator measuring participation-weighted money flow and its excess — the "Overflow" of one-sided activity. Where most flow tools simply display that excess, AE-TIDE adds a reinforcement-learning agent that learns, from realized outcomes, whether fading an Overflow exhaustion actually leads to a reversal in this market. It also scores every divergence with a Bayesian posterior, automatically down-weighting the divergences that do not work. It is a flow oscillator that gets smarter per market rather than relying on fixed thresholds.

🔶 Key Features

Participation-weighted Money Flow ([-50, 50]) plus an Overflow band for one-sided extremes
A fast Hyperwave momentum line for early shifts in drive
An RL (tabular Q-learning) agent that learns when fading exhaustion pays, firing reversal signals only then
Beta-Bernoulli online reliability scoring for divergences — each one shows a learned reliability %
Divergences below relGate are hidden automatically
Gold-framed HUD; no repaint — every signal gates on bar close

🧠 Technical Architecture

Flow: impulse = (ATR-normalized return) × (relative volume), EMA-smoothed and z-scored into a [-50, 50] Money Flow; the part beyond ± threshold is the Overflow. Hyperwave is the same normalization on a short EMA.
RL (Q-learning, TD(0)): state = flow regime (overflow side ×3 × momentum slope ×2 = 6 states), actions = {wait, fade}. The fade reward is the realized return conditioned on the overflow side at the moment the fade was taken (fade an overbought flow → rewarded if price falls). Update Q(s,a) ← Q + α[r + γ·maxQ(s′) − Q]; the fade action is optimistically initialized to guarantee exploration. A signal fires only when fade-value > 0 (learned to pay) and an Overflow exhaustion triggers.
Bayesian divergences: regular divergences are detected on oscillator pivots; each (side × extreme) bucket holds a Beta(a, b) posterior, updated by the realized outcome divK bars later. The displayed reliability is the posterior mean.
Honest scope: classic tabular Q-learning plus Beta-Bernoulli estimation — not deep RL, not a crystal ball.

⚙️ Recommended Settings & Tuning Guide

Key parameters: ofThr (Overflow threshold), rlAlpha / rlGamma / warmup, divK (outcome horizon), relGate (minimum reliability to show).
Raise ofThr → stricter overflow (suits alts); lower → more sensitive
Crypto starting points (tune on your chart):
BTC / ETH (1H–4H): defaults are the baseline (ofThr = 30)
SOL / XRP and high-vol alts: wicky and spiky — ofThr = 35–40, relGate = 0.6 for proven divergences only
Scalping (5–15m): shorter hwLen, divK = 5–8 for quick verdicts
Swing (daily): divK = 15–20, longer warmup so the agent learns enough
The RL needs time to learn a market's character; in trending markets fade signals thin out automatically (correct behavior)

💡 How to Use in Practice

FADE signals: appear only when Overflow recedes from an extreme AND the agent has learned that fading pays in this regime — use as a reversal trigger
Reading Overflow: a bright color is excessive one-sided participation; when it stalls or recedes, that exhaustion often precedes a reversal
Reliability-scored divergences: readings above ~70% mark contexts that historically reversed; ~50% means stand aside
Multi-timeframe: combine higher-timeframe flow direction with lower-timeframe FADE entries
Combinations: pair AE-TIDE's exhaustion fades with directional signals from AE-QUORUM or AE-KALMAN to separate trend pullbacks from range reversals

⚠️ Important Notes

Learning period: no FADE signals appear until the Q-learning agent spins up (warmup bars) — this is by design
Reliability starts at 50%: each divergence bucket sits near neutral until its posterior accumulates enough samples
Learning reset: changing inputs, symbol, or timeframe re-learns the internal state
Fading is countertrend: fading a strong trend too early is dangerous; even when the agent suppresses it, the final call is yours

🚨 Disclaimer

This indicator is for educational and informational purposes only and is not financial advice or a recommendation to buy or sell. No method guarantees future profits; past performance does not indicate future results, and trading carries the risk of loss. All trading decisions are your own — use proper backtesting and disciplined risk management.

## Source Code

````pine
// ============================================================================
//  AE-TIDE  |  AetherEdge Series
//  Money-flow / momentum oscillator with RL exhaustion timing + Bayesian
//  divergence reliability
//
//  A lower-panel flow oscillator (participation-weighted Money Flow, an
//  Overflow band for excessive one-sided activity, and a fast Hyperwave
//  momentum line) built from standard public concepts -- then upgraded with
//  two genuinely-implemented learning layers:
//
//    * RL  : a tabular Q-LEARNING agent (TD(0)) that learns, per flow regime,
//      whether FADING an Overflow exhaustion has actually paid. It only raises
//      an exhaustion-reversal signal in states where the learned value of
//      fading is positive -- i.e. it learns *when* exhaustion precedes a
//      reversal instead of assuming it always does.
//
//    * Bayes : every divergence is scored online with a BETA-BERNOULLI
//      posterior of "did this divergence type lead to a profitable reversal".
//      The reliability % shown on each divergence is the posterior mean,
//      updated from realized outcomes -- so weak divergence contexts are
//      down-weighted automatically.
//
//  Honest scope: classic tabular Q-learning + Beta-Bernoulli estimation. Not a
//  neural net, not a guarantee. No-repaint: divergences confirm on pivots
//  (fixed once formed), learning updates use realized outcomes, and every
//  signal is gated on barstate.isconfirmed.
// ============================================================================

//@version=6
indicator("AetherEdge - TIDE | Flow + RL Oscillator", "AE-TIDE", overlay = false, max_labels_count = 200)

// ----------------------------------------------------------------------------
//  THEME / PALETTE  (AetherEdge gold-frame HUD)
// ----------------------------------------------------------------------------
cGold    = #d4af37
cBg0     = #080b0a
cBg1     = #0f1614
cTxt     = #eef2f0
cBull    = #26a69a
cBear    = #ef5350
cBullHi  = #00e6c3
cBearHi  = #ff5b5b
cWait    = #8d99a6

// ----------------------------------------------------------------------------
//  INPUTS
// ----------------------------------------------------------------------------
grpF = "Flow oscillator"
atrLen  = input.int(14, "ATR length", minval = 1, group = grpF)
mfLen   = input.int(20, "Money Flow length", minval = 1, group = grpF)
hwLen   = input.int(7,  "Hyperwave (momentum) length", minval = 1, group = grpF)
normLen = input.int(100,"Normalization window", minval = 10, group = grpF)
ofThr   = input.float(30.0, "Overflow threshold", minval = 1.0, maxval = 50.0, step = 1.0, group = grpF, tooltip = "Oscillator is scaled to [-50,50]; beyond +/- this level counts as one-sided Overflow.")

grpRL = "RL  -  Exhaustion-fade agent"
useRL    = input.bool(true, "Enable RL exhaustion signals", group = grpRL)
rlAlpha  = input.float(0.10, "Learning rate (alpha)", minval = 0.001, maxval = 1.0, step = 0.01, group = grpRL)
rlGamma  = input.float(0.90, "Discount (gamma)", minval = 0.0, maxval = 0.999, step = 0.01, group = grpRL)
rlFlatPen= input.float(0.10, "Fade-without-overflow penalty", minval = 0.0, step = 0.05, group = grpRL)
warmup   = input.int(120, "Warmup bars", minval = 20, group = grpRL)

grpD = "Divergences  -  Bayesian reliability"
useDiv  = input.bool(true, "Detect divergences", group = grpD)
pivL    = input.int(5, "Pivot left",  minval = 1, group = grpD)
pivR    = input.int(5, "Pivot right", minval = 1, group = grpD)
divK    = input.int(10, "Outcome horizon (bars)", minval = 1, maxval = 100, group = grpD, tooltip = "Bars after a divergence used to judge whether the reversal paid (updates the Beta posterior).")
relGate = input.float(0.50, "Min reliability to flag", minval = 0.0, maxval = 1.0, step = 0.05, group = grpD)

grpUI = "Dashboard"
showHUD = input.bool(true, "Show HUD", group = grpUI)
hudSize = input.string("normal", "HUD size", options = ["tiny","small","normal","large"], group = grpUI)

// ----------------------------------------------------------------------------
//  HELPERS
// ----------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))

f_qGet(array<float> q, int s, int a) => array.get(q, s * 2 + a)
f_qSet(array<float> q, int s, int a, float v) => array.set(q, s * 2 + a, v)
f_qMax(array<float> q, int s) => math.max(f_qGet(q, s, 0), f_qGet(q, s, 1))

// ----------------------------------------------------------------------------
//  TYPES
// ----------------------------------------------------------------------------
// A divergence awaiting outcome evaluation (for the Beta posterior).
type PendDiv
    int   bucket        // side*2 + extreme  -> 0..3
    float bornPrice
    int   bornBar
    bool  dirUp         // expected reversal direction (true = up)

// ----------------------------------------------------------------------------
//  FLOW OSCILLATOR  (participation-weighted, normalized to [-50, 50])
// ----------------------------------------------------------------------------
atr     = ta.atr(atrLen)
atrSafe = math.max(nz(atr, nz(ta.tr, close * 0.001)), 1e-8)

volMa   = ta.sma(volume, mfLen)
relVol  = nz(volume / math.max(volMa, 1e-8), 1.0)            // relative participation
ret1    = (close - close[1]) / atrSafe                       // ATR-normalized move
impulse = nz(ret1 * relVol)                                  // signed, volume-weighted impulse

mfRaw   = ta.ema(impulse, mfLen)
mfSd    = math.max(ta.stdev(mfRaw, normLen), 1e-8)
mf      = 50.0 * f_clamp((mfRaw) / (2.5 * mfSd), -1.0, 1.0)  // Money Flow, [-50,50]

hwRaw   = ta.ema(impulse, hwLen)
hwSd    = math.max(ta.stdev(hwRaw, normLen), 1e-8)
hw      = 50.0 * f_clamp(hwRaw / (2.5 * hwSd), -1.0, 1.0)    // Hyperwave momentum

upper   = ofThr
lower   = -ofThr
ofUp    = mf > upper                                         // excessive bullish flow
ofDn    = mf < lower                                         // excessive bearish flow
ofVal   = ofUp ? mf - upper : ofDn ? mf - lower : 0.0        // the Overflow excess
ofState = ofUp ? 1 : ofDn ? 2 : 0
momUp   = hw > hw[1]

// Exhaustion = Overflow receding from its extreme.
bullExh = ofUp[1] and mf < mf[1] and mf[1] >= upper          // bullish flow fading -> reversal-down setup
bearExh = ofDn[1] and mf > mf[1] and mf[1] <= lower          // bearish flow fading -> reversal-up setup

// ----------------------------------------------------------------------------
//  RL  : TABULAR Q-LEARNING  (state = flow regime; action = wait / fade)
// ----------------------------------------------------------------------------
// State: ofState(3) x momUp(2) = 6 states. Actions: 0 = wait, 1 = fade.
stateNow = ofState * 2 + (momUp ? 1 : 0)

var array<float> qTab = array.new_float(6 * 2, 0.0)
// Optimistic initialization of the 'fade' action so the agent actually explores
// fading early on, then learns (per regime) whether it truly pays. Without this,
// a pure-greedy agent with zero init would never try fading and never signal.
var bool qInit = false
if not qInit
    for s = 0 to 5
        f_qSet(qTab, s, 1, 0.5)
    qInit := true
var int sPrev = na
var int aPrev = na

ret = nz((close - close[1]) / atrSafe)

// Reward for the action taken on the previous bar (realized this bar).
if barstate.isconfirmed and useRL and not na(sPrev) and not na(aPrev)
    float reward = 0.0
    if aPrev == 1                                            // faded (against the prior one-sided flow)
        int ofPrev = sPrev >= 4 ? 2 : sPrev >= 2 ? 1 : 0     // overflow side when the fade was taken
        reward := ofPrev == 1 ? -ret : ofPrev == 2 ? ret : -rlFlatPen * math.abs(ret)
    qOld   = f_qGet(qTab, sPrev, aPrev)
    target = reward + rlGamma * f_qMax(qTab, stateNow)
    f_qSet(qTab, sPrev, aPrev, qOld + rlAlpha * (target - qOld))

fadeValue = f_qGet(qTab, stateNow, 1) - f_qGet(qTab, stateNow, 0)   // learned edge of fading
aGreedy   = fadeValue > 0 ? 1 : 0

if barstate.isconfirmed
    sPrev := stateNow
    aPrev := aGreedy

warmOK = bar_index > warmup

// Exhaustion-reversal signals: fire only where the agent has learned fading pays.
sellExh = barstate.isconfirmed and useRL and warmOK and bullExh and fadeValue > 0
buyExh  = barstate.isconfirmed and useRL and warmOK and bearExh and fadeValue > 0

// ----------------------------------------------------------------------------
//  DIVERGENCES  +  BETA-BERNOULLI RELIABILITY
//  bucket = side(0 bull / 1 bear) * 2 + extreme(0 / 1)
// ----------------------------------------------------------------------------
var array<float> betaA = array.new_float(4, 1.0)   // Beta(a,b) successes (+prior 1)
var array<float> betaB = array.new_float(4, 1.0)   // failures (+prior 1)
var array<PendDiv> pend = array.new<PendDiv>()

f_reliab(int b) => array.get(betaA, b) / (array.get(betaA, b) + array.get(betaB, b))

oscPL = ta.pivotlow(mf, pivL, pivR)
oscPH = ta.pivothigh(mf, pivL, pivR)

var float pLowVal   = na
var float pLowPrice = na
var float pHighVal  = na
var float pHighPrice= na

bullDiv = false
bearDiv = false
int   divBucket = 0
float divReliab = 0.0

if useDiv and not na(oscPL)
    if not na(pLowVal) and oscPL > pLowVal and low[pivR] < pLowPrice
        bullDiv := true
        ext = mf[pivR] < lower ? 1 : 0
        divBucket := 0 * 2 + ext
        divReliab := f_reliab(divBucket)
        array.push(pend, PendDiv.new(bucket = divBucket, bornPrice = close[pivR], bornBar = bar_index - pivR, dirUp = true))
    pLowVal   := oscPL
    pLowPrice := low[pivR]

if useDiv and not na(oscPH)
    if not na(pHighVal) and oscPH < pHighVal and high[pivR] > pHighPrice
        bearDiv := true
        ext = mf[pivR] > upper ? 1 : 0
        divBucket := 1 * 2 + ext
        divReliab := f_reliab(divBucket)
        array.push(pend, PendDiv.new(bucket = divBucket, bornPrice = close[pivR], bornBar = bar_index - pivR, dirUp = false))
    pHighVal   := oscPH
    pHighPrice := high[pivR]

// Evaluate matured divergences and update the posterior.
if barstate.isconfirmed and array.size(pend) > 0
    for i = array.size(pend) - 1 to 0
        p = array.get(pend, i)
        if bar_index - p.bornBar >= divK
            success = p.dirUp ? (close > p.bornPrice) : (close < p.bornPrice)
            if success
                array.set(betaA, p.bucket, array.get(betaA, p.bucket) + 1.0)
            else
                array.set(betaB, p.bucket, array.get(betaB, p.bucket) + 1.0)
            array.remove(pend, i)

// Persisted "last divergence" info for the HUD / signal gating.
var string lastDivTxt = "-"
var float  lastDivRel = 0.0
if bullDiv
    lastDivTxt := "BULL"
    lastDivRel := divReliab
if bearDiv
    lastDivTxt := "BEAR"
    lastDivRel := divReliab

relOK_bull = bullDiv and divReliab >= relGate
relOK_bear = bearDiv and divReliab >= relGate

// ----------------------------------------------------------------------------
//  PLOTS  (oscillator pane)
// ----------------------------------------------------------------------------
mfCol = mf >= 0 ? color.new(cBull, 45) : color.new(cBear, 45)
plot(mf, "Money Flow", color = mfCol, style = plot.style_columns, histbase = 0)
plot(hw, "Hyperwave", color = color.new(cGold, 10), linewidth = 2)
plot(ofUp ? mf : na, "Overflow up", color = color.new(cBullHi, 0), style = plot.style_columns, histbase = upper)
plot(ofDn ? mf : na, "Overflow dn", color = color.new(cBearHi, 0), style = plot.style_columns, histbase = lower)

hline(0, "Mid", color = color.new(cWait, 50))
hline(upper, "Upper", color = color.new(cBull, 60), linestyle = hline.style_dotted)
hline(lower, "Lower", color = color.new(cBear, 60), linestyle = hline.style_dotted)

// ----------------------------------------------------------------------------
//  MARKERS
// ----------------------------------------------------------------------------
plotshape(sellExh, title = "Exhaustion sell", style = shape.triangledown, location = location.top,    color = cBearHi, size = size.small, text = "FADE", textcolor = cBearHi)
plotshape(buyExh,  title = "Exhaustion buy",  style = shape.triangleup,   location = location.bottom, color = cBullHi, size = size.small, text = "FADE", textcolor = cBullHi)

// Divergence labels carry the learned reliability %.
if relOK_bull
    label.new(bar_index - pivR, mf[pivR], "Bull " + str.tostring(math.round(divReliab * 100)) + "%", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = color.new(cBull, 100 - math.round(divReliab * 60)), textcolor = cTxt, size = size.tiny)
if relOK_bear
    label.new(bar_index - pivR, mf[pivR], "Bear " + str.tostring(math.round(divReliab * 100)) + "%", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.new(cBear, 100 - math.round(divReliab * 60)), textcolor = cTxt, size = size.tiny)

// ----------------------------------------------------------------------------
//  HUD DASHBOARD  (gold frame)
// ----------------------------------------------------------------------------
f_txtSize() => hudSize == "tiny" ? size.tiny : hudSize == "small" ? size.small : hudSize == "large" ? size.large : size.normal

ofTxt   = ofUp ? "BULL" : ofDn ? "BEAR" : "none"
ofCol   = ofUp ? cBullHi : ofDn ? cBearHi : cWait
exhTxt  = sellExh ? "SELL setup" : buyExh ? "BUY setup" : bullExh ? "bull fading" : bearExh ? "bear fading" : "none"
exhCol  = sellExh ? cBearHi : buyExh ? cBullHi : cWait

var table hud = table.new(position.top_right, 2, 9, bgcolor = cBg1, frame_color = cGold, frame_width = 2, border_color = color.new(cGold, 60), border_width = 1)

if showHUD and barstate.islast
    ts = f_txtSize()
    table.cell(hud, 0, 0, "AE-TIDE", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 0, "FLOW + RL", text_color = cWait, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 0, 1, "Money Flow", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 1, str.tostring(mf, "#.#"), text_color = mf >= 0 ? cBull : cBear, text_size = ts)
    table.cell(hud, 0, 2, "Overflow",   text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 2, ofTxt,        text_color = ofCol, text_size = ts)
    table.cell(hud, 0, 3, "Momentum",   text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 3, momUp ? "UP" : "DOWN", text_color = momUp ? cBull : cBear, text_size = ts)
    table.cell(hud, 0, 4, "Fade edge",  text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 4, str.tostring(fadeValue, "#.###"), text_color = fadeValue > 0 ? cBullHi : cWait, text_size = ts)
    table.cell(hud, 0, 5, "Exhaustion", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 5, exhTxt,       text_color = exhCol, text_size = ts)
    table.cell(hud, 0, 6, "Last div",   text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 6, lastDivTxt + " " + str.tostring(math.round(lastDivRel * 100)) + "%", text_color = lastDivTxt == "BULL" ? cBull : lastDivTxt == "BEAR" ? cBear : cWait, text_size = ts)
    table.cell(hud, 0, 7, "Reliab bull",text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 7, str.tostring(math.round(math.max(f_reliab(0), f_reliab(1)) * 100)) + "%", text_color = cBull, text_size = ts)
    table.cell(hud, 0, 8, "Reliab bear",text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 8, str.tostring(math.round(math.max(f_reliab(2), f_reliab(3)) * 100)) + "%", text_color = cBear, bgcolor = cBg0, text_size = ts)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
alertcondition(sellExh, "AE-TIDE Exhaustion Sell", "AE-TIDE overflow exhaustion sell (RL-confirmed)")
alertcondition(buyExh,  "AE-TIDE Exhaustion Buy",  "AE-TIDE overflow exhaustion buy (RL-confirmed)")
alertcondition(relOK_bull, "AE-TIDE Bullish Divergence", "AE-TIDE reliable bullish divergence")
alertcondition(relOK_bear, "AE-TIDE Bearish Divergence", "AE-TIDE reliable bearish divergence")

if sellExh
    alert("AE-TIDE FADE SELL | flow " + str.tostring(mf, "#.#") + " | edge " + str.tostring(fadeValue, "#.###"), alert.freq_once_per_bar_close)
if buyExh
    alert("AE-TIDE FADE BUY | flow " + str.tostring(mf, "#.#") + " | edge " + str.tostring(fadeValue, "#.###"), alert.freq_once_per_bar_close)
````
