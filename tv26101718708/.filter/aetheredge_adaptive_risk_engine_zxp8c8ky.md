# AetherEdge - Adaptive Risk Engine

- url: https://www.tradingview.com/script/Zxp8c8KY/
- type: indicator
- pine_id: PUB;21974091236a4c548932748148ce4482
- version: 1.0

## Description

🖊️ Overview

Most sizing is a static "1% every time." AE-RISK sizes to a learned edge and volatility, and pulls risk back automatically when you're cold. It learns the trigger's win-probability online, sizes via fractional Kelly, and lays out the full per-trade risk package — ATR stop/target, $ risk and reward, and position size in units.

🔶 Key Features

Edge-linked sizing — fractional Kelly from the learned win-rate (size up only when the odds justify it)
Loss-streak throttle — scales risk down/up with realized losing/winning runs (drawdown-aware)
Adaptive stop/target — ATR stop distance, R target
Per-regime optimal R — a UCB learns the best-expectancy R per volatility regime (information, decoupled from sizing)
Full risk package — units / % equity / $ risk-reward / R:R / win-rate / Kelly f*
Level lines + trigger triangles; bar-close training — no repaint

🧠 Technical Architecture

Trigger: EMA cross (default) or Donchian breakout; used for both learning and display.
ML (online logistic): at each trigger, six features (trend alignment, momentum, RSI, vol regime, volume, breakout position) predict P(win) = P(reach the R-target before the stop within N bars) via a triple barrier over an array<Setup>, resolved conservatively with SL priority (max-favorable-excursion counted only up to the stop).
Sizing (fractional Kelly): f* = max((p(b+1)−1)/b, 0) with b = target R; risk % = Kelly fraction × f* (capped); units = equity × risk % ÷ stop distance. A vol-target size is shown for reference.
RL (UCB / per-regime optimal R): per volatility regime, a UCB learns the best-expectancy R from the realized MFE distribution, shown as "opt R" (decoupled — information, not an override).
Throttle: a realized win/loss streak scales the multiplier (down through losing runs).
Honest scope: a linear classifier + Kelly + a bandit. Not deep learning, and not financial advice.

⚙️ Recommended Settings & Tuning Guide (crypto 15m–4H)

Key parameters: equity, base/max risk %, Kelly fraction, ATR stop, target R, trigger, barrier horizon N, throttle factor.
Kelly fraction ≈ 0.2–0.3 (full Kelly overbets; stay conservative)
Always set max risk % (caps large Kelly outputs)
Design payoff with stop (ATR) / target R; consult the per-regime "opt R"
A higher throttle factor cuts risk harder on losing runs
Start from defaults for crypto 15m–1H (slMult 1.5, R 2.0, N 20); enter your real equity

💡 How to Use in Practice

Use the trigger's risk package (size / SL / TP / $ risk) as your order template
Stand aside when P(win) and Kelly f* are low (thin edge)
A throttle multiple below 1 signals poor fit with the market — go smaller
If opt R diverges from your target R, reconsider the target
Combine with AE-ACE or AE-MRB signals, using this tool to manage size and stops

⚠️ Important Notes

Needs a learning period (warmup); learning resets on parameter/timeframe change
Intrabar order is unknown, so MFE/SL resolution is a conservative approximation (it can differ from real fills)
Kelly is sensitive to the estimated win-rate — keep the fraction small and always cap risk
This is not financial advice. The displayed size is only a starting point; final decisions and orders are your own

🚨 Disclaimer

This indicator is for educational and informational purposes only and is not financial advice, a trading recommendation, or money-management advice. Displayed position sizes and risk amounts are mechanical example calculations; no method guarantees future profits. Past performance does not indicate future results, and trading carries the risk of loss. All decisions and capital allocation are your own — use proper validation and disciplined risk management.

## Source Code

````pine
// ============================================================================
//  AetherEdge - Adaptive Risk Engine  (AE-RISK)  |  AetherEdge Series
//  Size the trade to the EDGE and the VOLATILITY -- not a fixed lot
//
//  Most sizing is a static "1% per trade." AE-RISK sizes to a learned edge and
//  pulls risk back when you're cold:
//
//    * ML : an ONLINE LOGISTIC learns P(win) = P(price reaches the R-target
//      before the ATR stop within N bars) for the trigger, from a triple-
//      barrier outcome over an array<Setup>. That edge drives FRACTIONAL KELLY
//      sizing (capped), so size scales up only when the odds justify it.
//    * RISK THROTTLE : a realized win/loss STREAK scales risk down through
//      losing runs and back up through winning runs (bounded) -- drawdown-aware
//      by construction.
//    * RL : a UCB per VOLATILITY REGIME learns the best-expectancy R-target
//      from the realized max-favorable-excursion distribution, shown as an
//      "optimal R" suggestion (decoupled from sizing -- information, not an
//      override).
//
//  Outputs a full risk package: size (units / % equity), $ risk and reward,
//  ATR stop and target, R:R, learned win-rate and Kelly fraction. Honest scope:
//  a linear classifier + Kelly + a bandit over standard features -- not a neural
//  net, not financial advice. Training gates on bar close; MFE/SL are tracked
//  conservatively (intrabar order is unknown).
// ============================================================================

//@version=6
indicator("AetherEdge - Adaptive Risk Engine", "AE-RISK", overlay = true, max_lines_count = 20, max_labels_count = 20)

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
grpA = "Account"
equity = input.float(10000, "Account equity", minval = 1, group = grpA)
baseRiskPct = input.float(1.0, "Base risk per trade (%)", minval = 0.0, step = 0.1, group = grpA)
maxRiskPct = input.float(2.5, "Max risk per trade (%)", minval = 0.1, step = 0.1, group = grpA)
useKelly = input.bool(true, "Size by learned edge (Kelly)", group = grpA)
kellyFrac = input.float(0.30, "Kelly fraction", minval = 0.05, maxval = 1.0, step = 0.05, group = grpA)
targetVolPct = input.float(1.0, "Vol-target ref (% per bar)", minval = 0.05, step = 0.05, group = grpA)

grpS = "Stop / target"
atrLen = input.int(14, "ATR length", minval = 2, group = grpS)
slMult = input.float(1.5, "Stop (ATR)", minval = 0.2, step = 0.1, group = grpS)
rrTarget = input.float(2.0, "Target (R)", minval = 0.5, step = 0.1, group = grpS)

grpT = "Trigger + model"
trigType = input.string("EMA cross", "Trigger", options = ["EMA cross","Donchian"], group = grpT)
fastLen = input.int(10, "EMA fast / Donchian len", minval = 2, group = grpT)
slowLen = input.int(30, "EMA slow", minval = 3, group = grpT)
rsiLen = input.int(14, "RSI length", minval = 2, group = grpT)
horizonN = input.int(20, "Barrier horizon N (bars)", minval = 3, group = grpT)
lr = input.float(0.03, "Learning rate", minval = 0.001, step = 0.005, group = grpT)

grpR = "RL optimal-R + throttle"
ucbC = input.float(1.4, "UCB exploration", minval = 0.0, step = 0.1, group = grpR)
throttleK = input.float(0.15, "Throttle per streak", minval = 0.0, step = 0.05, group = grpR)
minMult = input.float(0.3, "Min risk multiple", minval = 0.05, step = 0.05, group = grpR)
maxMult = input.float(1.8, "Max risk multiple", minval = 1.0, step = 0.1, group = grpR)
warmup = input.int(150, "Warmup bars", minval = 20, group = grpR)

grpUI = "Display"
showLevels = input.bool(true, "Show stop/target lines", group = grpUI)
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
//  INDICATORS + FEATURES + TRIGGER
// ----------------------------------------------------------------------------
atr = math.max(ta.atr(atrLen), 1e-8)
emaF = ta.ema(close, fastLen)
emaS = ta.ema(close, slowLen)
rsi = ta.rsi(close, rsiLen)
donHi = ta.highest(high, fastLen)
donLo = ta.lowest(low, fastLen)
donMid = (donHi + donLo) / 2.0

volRank = ta.percentrank(atr, 100)
int regime = volRank < 33.0 ? 0 : volRank < 66.0 ? 1 : 2

f_feat(int side) =>
    f1 = f_clamp(side * (emaF - emaS) / atr, -3.0, 3.0)
    f2 = f_clamp(side * (close - close[3]) / atr, -3.0, 3.0)
    f3 = f_clamp(side * (rsi - 50.0) / 50.0, -1.0, 1.0)
    f4 = f_clamp(atr / math.max(ta.sma(atr, 50), 1e-8) - 1.0, -1.0, 2.0)
    f5 = f_clamp(volume / math.max(ta.sma(volume, 20), 1e-8) - 1.0, -1.0, 3.0)
    f6 = f_clamp(side * (close - donMid) / atr, -3.0, 3.0)
    array.from(f1, f2, f3, f4, f5, f6)

longTrig = trigType == "Donchian" ? (high > donHi[1]) : ta.crossover(emaF, emaS)
shortTrig = trigType == "Donchian" ? (low < donLo[1]) : ta.crossunder(emaF, emaS)

// ----------------------------------------------------------------------------
//  LEARNING: triple-barrier P(win) + UCB optimal-R + streak
// ----------------------------------------------------------------------------
type Setup
    float f1
    float f2
    float f3
    float f4
    float f5
    float f6
    int   side
    float entry
    float slDist
    int   regime
    int   age
    float mfeR

var array<Setup> setups = array.new<Setup>()
var array<float> w = array.new_float(7, 0.0)

int NARMS = 5
var array<float> armR = array.from(1.0, 1.5, 2.0, 2.5, 3.0)
var array<float> ucbVal = array.new_float(3 * NARMS, 0.0)
var array<float> ucbCnt = array.new_float(3 * NARMS, 0.0)
var array<float> regCnt = array.new_float(3, 0.0)
var int streak = 0
var int nWin = 0
var int nTot = 0

f_optR(int reg) =>
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
    best

// resolve open setups
if barstate.isconfirmed and array.size(setups) > 0
    keep = array.new<Setup>()
    for i = 0 to array.size(setups) - 1
        s = array.get(setups, i)
        s.age += 1
        favExc = s.side > 0 ? (high - s.entry) : (s.entry - low)
        advExc = s.side > 0 ? (s.entry - low) : (high - s.entry)
        bool resolved = false
        float mfeRes = na
        if advExc >= s.slDist
            resolved := true
            mfeRes := s.mfeR                      // conservative: exclude SL bar upside
        else
            s.mfeR := math.max(s.mfeR, favExc / s.slDist)
            if s.age >= horizonN
                resolved := true
                mfeRes := s.mfeR
        if resolved
            won = mfeRes >= rrTarget ? 1.0 : 0.0
            xf = array.from(s.f1, s.f2, s.f3, s.f4, s.f5, s.f6)
            f_train(w, xf, won, lr)
            nTot += 1
            nWin += won >= 0.5 ? 1 : 0
            streak := won >= 0.5 ? (streak > 0 ? streak + 1 : 1) : (streak < 0 ? streak - 1 : -1)
            array.set(regCnt, s.regime, array.get(regCnt, s.regime) + 1.0)
            for a = 0 to NARMS - 1
                idx = s.regime * NARMS + a
                rew = mfeRes >= array.get(armR, a) ? array.get(armR, a) : -1.0
                c0 = array.get(ucbCnt, idx)
                v0 = array.get(ucbVal, idx)
                array.set(ucbCnt, idx, c0 + 1.0)
                array.set(ucbVal, idx, v0 + (rew - v0) / (c0 + 1.0))
        else
            array.push(keep, s)
    setups := keep

// create setup on a fresh trigger
int sideTrig = longTrig ? 1 : shortTrig ? -1 : 0
if barstate.isconfirmed and sideTrig != 0
    ff = f_feat(sideTrig)
    s2 = Setup.new(array.get(ff, 0), array.get(ff, 1), array.get(ff, 2), array.get(ff, 3), array.get(ff, 4), array.get(ff, 5), sideTrig, close, slMult * atr, regime, 0, 0.0)
    array.push(setups, s2)
    if array.size(setups) > 60
        array.shift(setups)

// ----------------------------------------------------------------------------
//  LIVE RISK PACKAGE  (computed/stored at each fresh trigger)
// ----------------------------------------------------------------------------
warmOK = bar_index > warmup
winRate = nTot > 0 ? nWin / nTot : na
throttleMult = f_clamp(1.0 + throttleK * streak, minMult, maxMult)
optRidx = f_optR(regime)
optR = array.get(armR, optRidx)

var int pkSide = 0
var float pkEntry = na
var float pkStop = na
var float pkTarget = na
var float pkP = na
var float pkKelly = na
var float pkRisk = na
var float pkQty = na
var float pkVolQty = na

if barstate.isconfirmed and sideTrig != 0
    pWin = f_predict(w, f_feat(sideTrig))
    b = rrTarget
    fstar = math.max((pWin * (b + 1.0) - 1.0) / b, 0.0)
    appliedRisk = useKelly ? f_clamp(kellyFrac * fstar * 100.0, 0.0, maxRiskPct) : baseRiskPct
    finalRisk = f_clamp(appliedRisk * throttleMult, 0.0, maxRiskPct)
    slDist = slMult * atr
    pkSide := sideTrig
    pkEntry := close
    pkStop := sideTrig > 0 ? close - slDist : close + slDist
    pkTarget := sideTrig > 0 ? close + rrTarget * slDist : close - rrTarget * slDist
    pkP := pWin
    pkKelly := fstar
    pkRisk := finalRisk
    pkQty := slDist > 0 ? equity * finalRisk / 100.0 / slDist : na
    pkVolQty := equity * targetVolPct / 100.0 / atr

dollarRisk = na(pkRisk) ? na : equity * pkRisk / 100.0
dollarReward = na(dollarRisk) ? na : rrTarget * dollarRisk

// ----------------------------------------------------------------------------
//  LEVEL LINES
// ----------------------------------------------------------------------------
var line lnE = na
var line lnS = na
var line lnT = na
if showLevels and barstate.isconfirmed and sideTrig != 0
    if not na(lnE)
        line.delete(lnE)
    if not na(lnS)
        line.delete(lnS)
    if not na(lnT)
        line.delete(lnT)
    lnE := line.new(bar_index, pkEntry, bar_index + 1, pkEntry, xloc = xloc.bar_index, extend = extend.right, color = color.new(cGold, 0), width = 1)
    lnS := line.new(bar_index, pkStop, bar_index + 1, pkStop, xloc = xloc.bar_index, extend = extend.right, color = color.new(cBear, 20), width = 1, style = line.style_dashed)
    lnT := line.new(bar_index, pkTarget, bar_index + 1, pkTarget, xloc = xloc.bar_index, extend = extend.right, color = color.new(cBull, 20), width = 1, style = line.style_dashed)

plotshape(longTrig ? low : na, "Long trigger", shape.triangleup, location.belowbar, color.new(cBull, 0), size = size.tiny)
plotshape(shortTrig ? high : na, "Short trigger", shape.triangledown, location.abovebar, color.new(cBear, 0), size = size.tiny)

// ----------------------------------------------------------------------------
//  HUD
// ----------------------------------------------------------------------------
regTxt = regime == 0 ? "LOW" : regime == 1 ? "NORMAL" : "HIGH"
sideTxt = pkSide > 0 ? "LONG" : pkSide < 0 ? "SHORT" : "—"
sideCol = pkSide > 0 ? cBull : pkSide < 0 ? cBear : cWait

var table hud = table.new(position.top_right, 2, 14, bgcolor = cBg1, frame_color = cGold, frame_width = 2, border_color = color.new(cGold, 60), border_width = 1)
if showHUD and barstate.islast
    ts = f_txtSize()
    table.cell(hud, 0, 0, "AE-RISK", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 0, sideTxt, text_color = sideCol, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 0, 1, "Entry", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 1, na(pkEntry) ? "-" : str.tostring(pkEntry, format.mintick), text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 2, "Stop", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 2, na(pkStop) ? "-" : str.tostring(pkStop, format.mintick), text_color = cBear, text_size = ts)
    table.cell(hud, 0, 3, "Target", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 3, na(pkTarget) ? "-" : str.tostring(pkTarget, format.mintick), text_color = cBull, text_size = ts)
    table.cell(hud, 0, 4, "R:R", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 4, str.tostring(rrTarget, "#.#") + " : 1", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 5, "P(win)", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 5, na(pkP) ? "-" : str.tostring(math.round(pkP * 100)) + "%", text_color = na(pkP) ? cWait : pkP >= 0.5 ? cBull : cBear, text_size = ts)
    table.cell(hud, 0, 6, "Kelly f*", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 6, na(pkKelly) ? "-" : str.tostring(pkKelly, "#.##"), text_color = cViolet, text_size = ts)
    table.cell(hud, 0, 7, "Risk %", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 7, na(pkRisk) ? "-" : str.tostring(pkRisk, "#.##") + "%", text_color = na(pkRisk) ? cWait : pkRisk > 0.0 ? cGold : cWait, text_size = ts)
    table.cell(hud, 0, 8, "Throttle (streak)", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 8, str.tostring(throttleMult, "#.##") + "x (" + str.tostring(streak) + ")", text_color = throttleMult >= 1.0 ? cBull : cBear, text_size = ts)
    table.cell(hud, 0, 9, "Size (units)", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 9, na(pkQty) ? "-" : str.tostring(pkQty, "#.####"), text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 10, "Risk / Reward $", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 10, na(dollarRisk) ? "-" : str.tostring(dollarRisk, "#.#") + " / " + str.tostring(dollarReward, "#.#"), text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 11, "Vol-target size", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 11, na(pkVolQty) ? "-" : str.tostring(pkVolQty, "#.####"), text_color = cWait, text_size = ts)
    table.cell(hud, 0, 12, "Regime / opt R", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 12, regTxt + " / " + str.tostring(optR, "#.#") + "R", text_color = cViolet, text_size = ts)
    table.cell(hud, 0, 13, na(winRate) ? "Model" : "Win " + str.tostring(math.round(winRate * 100)) + "% (" + str.tostring(nTot) + ")", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 13, warmOK ? "live" : "learning", text_color = warmOK ? cBull : cWait, bgcolor = cBg0, text_size = ts)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
alertcondition(longTrig, "AE-RISK Long setup", "AE-RISK: long trigger - see sized risk package")
alertcondition(shortTrig, "AE-RISK Short setup", "AE-RISK: short trigger - see sized risk package")
````
