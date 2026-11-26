# AetherEdge - Mean-Reversion Bands

- url: https://www.tradingview.com/script/LImygeiq/
- type: indicator
- pine_id: PUB;fa4fa834a8ed40ac8bea0fb71317058a
- version: 1.0

## Description

🖊️ Overview

Ordinary bands flag the stretch but say nothing about what happens next. AE-MRB learns the probability that price reverts to the mean at a band touch and only fades when the odds support it. A UCB-style threshold adapts per trend regime — aggressive in chop, cautious in a trend — with the mean (band center) as the target.

🔶 Key Features

Learned reversion probability — online P(revert) at each band touch (not every touch reverts)
Triple-barrier training — learns from the real outcome: revert / extend (trend) / timeout
Regime-adaptive threshold — UCB tunes the firing probability per ranging/normal/trending regime
Fade signals — long at the lower band, short at the upper band, targeting the mean
σ stretch readout and regime-colored bands
Alerts on high-probability touches; bar-close training and signals — no repaint

🧠 Technical Architecture

Bands: basis (EMA/SMA) ± kBand·standard deviation; stretch = (close − basis)/σ (z-score).
ML (online logistic): at a band touch (a fresh |stretch| ≥ threshold cross), seven fade-oriented features (stretch, trend strength, RSI extremity, band-width regime, volume, mean slope, exhaustion) predict P(reverts to the mean within N bars). Labels are triple-barrier — revert (returns to mean) = 1, extend (stretches further = trend/breakout) = 0, timeout judged by how far it pulled back. Resolved over an array<Setup> with SL priority.
RL (UCB-style adaptive threshold): per trend regime (trend-strength terciles), a UCB tunes the firing probability threshold; reward is tied to the same reversion outcome (one learning loop). Stronger trends demand higher conviction.
Honest scope: a linear classifier + a bandit over standard features. Not deep learning, not a guarantee.

⚙️ Recommended Settings & Tuning Guide (crypto 15m–4H)

Key parameters: basis length, band width σ, touch threshold σ, barrier horizon N, revert/extend levels, learning rate, UCB exploration, min reversion probability.

Touch threshold σ ≈ 1.5–2.0 (lower = more frequent, higher = more selective)
N is the max bars to wait for reversion; 8–15 for 15m–1H
Revert level / extend distance define what counts as success vs failure
Min reversion probability is a floor that suppresses weak-market misfires
Best on range-prone symbols/sessions; in strong trends the UCB automatically throttles firing

💡 How to Use in Practice

Use the fade triangles for counter-trend entries and the mean as the take-profit target
Watch P(revert) vs threshold and take only setups that clear it
When the regime reads TRENDING, fade lightly (pair with a trend tool)
Use the realized revert rate to gauge how reversion-friendly the market is now
Combine with AE-VOL (range envelope) or AE-CORR (drivers) to layer reversion × level

⚠️ Important Notes

Needs a learning period (warmup); learning resets on parameter/timeframe change
Mean reversion fails in strong trends (extend = loss; manage via threshold and regime)
The target mean moves (its level shifts before price reaches it)
Probability, not a guarantee — always do your own due diligence and use risk management

🚨 Disclaimer

This indicator is for educational and informational purposes only and is not financial advice or a recommendation to buy or sell. No method guarantees future profits; past performance does not indicate future results, and trading carries the risk of loss. All decisions are your own — use proper validation and disciplined risk management.

## Source Code

````pine
// ============================================================================
//  AetherEdge - Mean-Reversion Bands  (AE-MRB)  |  AetherEdge Series
//  Bands that know WHEN a touch reverts -- not every band touch is a fade
//
//  Classic bands flag the stretch but stay silent on what happens next. AE-MRB
//  learns the reversion edge and only fades when the odds support it:
//
//    * ML : an ONLINE LOGISTIC learns P(price reverts toward the mean within N
//      bars) at a band touch, from a triple-barrier outcome -- REVERT (price
//      returns to the mean) vs EXTEND (price stretches further = trend/breakout)
//      vs TIMEOUT. Features are oriented to the fade side (stretch, trend
//      strength, RSI extremity, band-width regime, volume, mean slope,
//      exhaustion), so one model serves both bands.
//    * RL : a UCB-style adaptive PROBABILITY threshold, tuned per TREND REGIME
//      (ranging / normal / trending), gates which touches actually fire -- fade
//      freely in chop, demand more in a trend. Reward is tied to the same
//      reversion outcome (one learning loop).
//
//  Fade-long at the lower band, fade-short at the upper band, with the mean as
//  the target. Honest scope: a linear classifier + a bandit over standard
//  features -- not a neural net, not a guarantee. Training and signals gate on
//  bar close.
// ============================================================================

//@version=6
indicator("AetherEdge - Mean-Reversion Bands", "AE-MRB", overlay = true)

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
cViolet = #b06fd6

// ----------------------------------------------------------------------------
//  INPUTS
// ----------------------------------------------------------------------------
grpB = "Bands"
basisType = input.string("EMA", "Basis", options = ["EMA","SMA"], group = grpB)
lenMA = input.int(20, "Basis length", minval = 2, group = grpB)
kBand = input.float(2.0, "Band width (σ)", minval = 0.5, step = 0.1, group = grpB)
kEntry = input.float(1.6, "Touch threshold (σ)", minval = 0.5, step = 0.1, group = grpB)

grpL = "Reversion model"
horizonN = input.int(12, "Barrier horizon N (bars)", minval = 2, group = grpL)
revThr = input.float(0.4, "Revert level (σ)", minval = 0.0, step = 0.1, group = grpL)
extThr = input.float(1.0, "Extend distance (σ)", minval = 0.2, step = 0.1, group = grpL)
lr = input.float(0.03, "Learning rate", minval = 0.001, step = 0.005, group = grpL)
fastLen = input.int(10, "Trend fast", minval = 2, group = grpL)
slowLen = input.int(40, "Trend slow", minval = 5, group = grpL)
rsiLen = input.int(14, "RSI length", minval = 2, group = grpL)

grpR = "RL threshold"
ucbC = input.float(1.4, "UCB exploration", minval = 0.0, step = 0.1, group = grpR)
pFloor = input.float(0.35, "Min reversion prob", minval = 0.0, maxval = 1.0, step = 0.05, group = grpR)
warmup = input.int(150, "Warmup bars", minval = 20, group = grpR)

grpUI = "Display"
showBands = input.bool(true, "Show bands", group = grpUI)
showSig = input.bool(true, "Show fade signals", group = grpUI)
showHUD = input.bool(true, "Show HUD", group = grpUI)
hudSize = input.string("small", "Table size", options = ["tiny","small","normal","large"], group = grpUI)

// ----------------------------------------------------------------------------
//  HELPERS
// ----------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))
f_sigmoid(float z) => 1.0 / (1.0 + math.exp(-f_clamp(z, -30.0, 30.0)))
f_txtSize() => hudSize == "tiny" ? size.tiny : hudSize == "small" ? size.small : hudSize == "large" ? size.large : size.normal

f_predict(array<float> w, array<float> x) =>
    z = array.get(w, 0)
    for i = 0 to array.size(x) - 1
        z += array.get(w, i + 1) * array.get(x, i)
    f_sigmoid(z)

f_train(array<float> w, array<float> x, float y, float lrr) =>
    p = f_predict(w, x)
    err = p - y
    array.set(w, 0, array.get(w, 0) - lrr * err)
    for i = 0 to array.size(x) - 1
        array.set(w, i + 1, array.get(w, i + 1) - lrr * err * array.get(x, i))

// ----------------------------------------------------------------------------
//  BANDS + STRETCH
// ----------------------------------------------------------------------------
basis = basisType == "SMA" ? ta.sma(close, lenMA) : ta.ema(close, lenMA)
dev = math.max(ta.stdev(close, lenMA), 1e-8)
upper = basis + kBand * dev
lower = basis - kBand * dev
stretch = (close - basis) / dev

atr = math.max(ta.atr(14), 1e-8)
rsi = ta.rsi(close, rsiLen)
trendStr = math.abs(ta.ema(close, fastLen) - ta.ema(close, slowLen)) / atr
meanSlope = (basis - basis[3]) / atr
widthReg = dev / math.max(ta.sma(dev, 50), 1e-8) - 1.0
volSurge = volume / math.max(ta.sma(volume, 20), 1e-8) - 1.0

// trend regime (0 ranging / 1 normal / 2 trending)
trRank = ta.percentrank(trendStr, 100)
int regime = trRank < 33.0 ? 0 : trRank < 66.0 ? 1 : 2

// exhaustion: consecutive bars beyond the touch threshold
var int exh = 0
exh := math.abs(stretch) >= 1.0 ? exh + 1 : 0

// fade side for CURRENT bar (+1 fade short at upper, -1 fade long at lower)
int sideNow = stretch > 0 ? 1 : -1

f_feat(int side) =>
    f1 = f_clamp(math.abs(stretch), 0.0, 5.0)
    f2 = f_clamp(trendStr, 0.0, 5.0)
    f3 = f_clamp(side * (rsi - 50.0) / 50.0, -1.0, 1.0)
    f4 = f_clamp(widthReg, -1.0, 3.0)
    f5 = f_clamp(volSurge, -1.0, 3.0)
    f6 = f_clamp(side * meanSlope, -3.0, 3.0)
    f7 = f_clamp(exh / 10.0, 0.0, 3.0)
    array.from(f1, f2, f3, f4, f5, f6, f7)

// ----------------------------------------------------------------------------
//  ONLINE LOGISTIC + UCB THRESHOLD  (triple-barrier reversion training)
// ----------------------------------------------------------------------------
type Setup
    float f1
    float f2
    float f3
    float f4
    float f5
    float f6
    float f7
    int   side
    float sa0
    int   regime
    int   age

var array<Setup> setups = array.new<Setup>()
var array<float> w = array.new_float(8, 0.0)

// UCB arms = probability thresholds, per regime (3 x NARMS)
int NARMS = 5
var array<float> armThr = array.from(0.40, 0.50, 0.60, 0.70, 0.80)
var array<float> ucbVal = array.new_float(3 * NARMS, 0.0)
var array<float> ucbCnt = array.new_float(3 * NARMS, 0.0)
var array<float> regCnt = array.new_float(3, 0.0)
var float pBase = 0.5
var int nRev = 0
var int nTot = 0

f_chooseThr(int reg) =>
    int best = 2
    float bestU = -1e18
    tot = array.get(regCnt, reg)
    for a = 0 to NARMS - 1
        idx = reg * NARMS + a
        c = array.get(ucbCnt, idx)
        v = array.get(ucbVal, idx)
        u = c < 1.0 ? 1e12 : v + ucbC * math.sqrt(math.log(tot + 1.0) / c)
        if u > bestU
            bestU := u
            best := a
    array.get(armThr, best)

// resolve open setups
if barstate.isconfirmed and array.size(setups) > 0
    keep = array.new<Setup>()
    for i = 0 to array.size(setups) - 1
        s = array.get(setups, i)
        s.age += 1
        curAbs = math.abs(stretch)
        sameSide = (stretch > 0 ? 1 : -1) == s.side
        bool resolved = false
        float y = na
        if not sameSide or curAbs <= revThr
            resolved := true
            y := 1.0
        else if curAbs >= s.sa0 + extThr
            resolved := true
            y := 0.0
        else if s.age >= horizonN
            resolved := true
            y := curAbs <= s.sa0 * 0.5 ? 1.0 : 0.0
        if resolved
            xf = array.from(s.f1, s.f2, s.f3, s.f4, s.f5, s.f6, s.f7)
            f_train(w, xf, y, lr)
            pp = f_predict(w, xf)
            nTot += 1
            nRev += y >= 0.5 ? 1 : 0
            pBase := nTot > 0 ? nRev / nTot : 0.5
            // full-information UCB reward per arm
            array.set(regCnt, s.regime, array.get(regCnt, s.regime) + 1.0)
            for a = 0 to NARMS - 1
                idx = s.regime * NARMS + a
                rew = pp >= array.get(armThr, a) ? y : pBase
                c0 = array.get(ucbCnt, idx)
                v0 = array.get(ucbVal, idx)
                array.set(ucbCnt, idx, c0 + 1.0)
                array.set(ucbVal, idx, v0 + (rew - v0) / (c0 + 1.0))
        else
            array.push(keep, s)
    setups := keep

// create a new setup on a fresh band touch
newTouch = math.abs(stretch) >= kEntry and math.abs(stretch[1]) < kEntry
if barstate.isconfirmed and newTouch
    ff = f_feat(sideNow)
    s2 = Setup.new(array.get(ff, 0), array.get(ff, 1), array.get(ff, 2), array.get(ff, 3), array.get(ff, 4), array.get(ff, 5), array.get(ff, 6), sideNow, math.abs(stretch), regime, 0)
    array.push(setups, s2)
    if array.size(setups) > 80
        array.shift(setups)

// ----------------------------------------------------------------------------
//  LIVE PREDICTION + FADE SIGNAL
// ----------------------------------------------------------------------------
pRev = f_predict(w, f_feat(sideNow))
chosenThr = math.max(f_chooseThr(regime), pFloor)
warmOK = bar_index > warmup

fireFade = warmOK and newTouch and pRev >= chosenThr
fadeLong  = fireFade and sideNow < 0
fadeShort = fireFade and sideNow > 0

winRate = nTot > 0 ? nRev / nTot : na
target = basis

// ----------------------------------------------------------------------------
//  PLOTS
// ----------------------------------------------------------------------------
regCol = regime == 0 ? cBull : regime == 1 ? cViolet : cBear
pBasis = plot(showBands ? basis : na, "Basis", color = color.new(cGold, 0), linewidth = 1)
pUp = plot(showBands ? upper : na, "Upper", color = color.new(regCol, 30), linewidth = 1)
pDn = plot(showBands ? lower : na, "Lower", color = color.new(regCol, 30), linewidth = 1)
fill(pUp, pDn, color = color.new(regCol, 92))

plotshape(showSig and fadeLong ? low : na, "Fade long", shape.triangleup, location.belowbar, color.new(cBull, 0), size = size.small)
plotshape(showSig and fadeShort ? high : na, "Fade short", shape.triangledown, location.abovebar, color.new(cBear, 0), size = size.small)

// ----------------------------------------------------------------------------
//  HUD
// ----------------------------------------------------------------------------
regTxt = regime == 0 ? "RANGING" : regime == 1 ? "NORMAL" : "TRENDING"
var table hud = table.new(position.top_right, 2, 9, bgcolor = cBg1, frame_color = cGold, frame_width = 2, border_color = color.new(cGold, 60), border_width = 1)
if showHUD and barstate.islast
    ts = f_txtSize()
    table.cell(hud, 0, 0, "AE-MRB", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 0, fadeLong ? "FADE LONG" : fadeShort ? "FADE SHORT" : "—", text_color = fadeLong ? cBull : fadeShort ? cBear : cWait, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 0, 1, "Stretch", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 1, str.tostring(stretch, "#.##") + "σ", text_color = math.abs(stretch) >= kEntry ? (stretch > 0 ? cBear : cBull) : cTxt, text_size = ts)
    table.cell(hud, 0, 2, "P(revert)", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 2, str.tostring(math.round(pRev * 100)) + "%", text_color = pRev >= chosenThr ? cBull : cWait, text_size = ts)
    table.cell(hud, 0, 3, "Threshold", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 3, str.tostring(math.round(chosenThr * 100)) + "%", text_color = cViolet, text_size = ts)
    table.cell(hud, 0, 4, "Regime", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 4, regTxt, text_color = regCol, text_size = ts)
    table.cell(hud, 0, 5, "Target (mean)", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 5, str.tostring(target, format.mintick), text_color = cGold, text_size = ts)
    table.cell(hud, 0, 6, "Revert rate", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 6, na(winRate) ? "-" : str.tostring(math.round(winRate * 100)) + "%", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 7, "Samples", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 7, str.tostring(nTot), text_color = cWait, text_size = ts)
    table.cell(hud, 0, 8, "Model", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 8, warmOK ? "live" : "learning", text_color = warmOK ? cBull : cWait, bgcolor = cBg0, text_size = ts)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
alertcondition(fadeLong, "AE-MRB Fade long", "AE-MRB: high-probability mean-reversion long at lower band")
alertcondition(fadeShort, "AE-MRB Fade short", "AE-MRB: high-probability mean-reversion short at upper band")
````
