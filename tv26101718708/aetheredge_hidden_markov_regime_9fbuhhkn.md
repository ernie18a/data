# AetherEdge - Hidden Markov Regime

- url: https://www.tradingview.com/script/9fBuHHkN/
- type: indicator
- pine_id: PUB;0838aea0fb2a4636bfe8a5c93c875cb5
- version: 1.0

## Description

🖊️ Overview

AE-HMM treats the market regime as a hidden state you can't observe directly (Bull/Bear/Range) and infers each state's probability from observable returns using a Hidden Markov Model's forward algorithm. The background bleeds a continuous "mood gradient" — green when Bull dominates, red for Bear, neutral grey for Range — visualizing the market's current mood. Online EM learns each state's emission parameters, auto-adapting to what Bull/Bear/Range look like on this instrument.

🔶 Key Features

3-state Hidden Markov Model: probabilistic Bull/Bear/Range via forward algorithm
Gaussian emission likelihood: each state has a return distribution
Sticky transition matrix: tunable regime persistence
Online EM learning: auto-learns each state's mean/variance from data
Sign clamping: keeps Bull>0, Bear<0, preventing label switching
Mood gradient background: red→grey→green continuum visualizing sentiment
State-colored EMA: moving average color changes with the most-likely state
State probability stack (optional): probability mass of 3 states below price
BUY/SELL on most-likely-state transitions
HUD showing each state's probability and learned parameters
Per-event alerts

🧠 Technical Architecture

This implements an HMM forward algorithm. Three hidden states (Bull/Bear/Range) each carry a Gaussian emission b_j(o) over ATR-normalized returns, with a sticky transition matrix A[i→j] (diagonal = persistence). The scaled forward recursion γ_t(j) ∝ [Σ_i γ_{t-1}(i)·A[i][j]]·b_j(o_t) computes the filtered posterior of each state per bar, normalized for stability. Online EM updates emissions via μ_j ← μ_j + η·γ_j·(o−μ_j) and σ²_j ← σ²_j + η·γ_j·((o−μ_j)²−σ²_j), sign-clamping Bull mean positive and Bear mean negative to preserve label meaning. Most-likely state = argmax γ. The bull-bear score = γ_bull − γ_bear drives the background gradient. Signals fire when the most-likely state transitions into Bull/Bear and probability exceeds threshold. State updates occur on confirmed bars only — no repaint.

⚙️ Recommended Settings & Tuning Guide

Regime Persistence 0.90 is a starting point — the transition matrix diagonal (regime stickiness). Higher = smoother, slower state changes; lower = more sensitive. Return Smoothing 1 smooths the observed return; raise for noisy instruments. Learn Emission Parameters ON is recommended; Learning Rate 0.03 is standard speed. Initial |Bull/Bear Mean| 0.5 sets the initial separation of Bull(+)/Bear(−) emission means. Min State Probability to Signal 0.4 requires the new dominant state to reach this probability before signaling — higher means only high-conviction transitions. Min Variance Floor bounds the variance.

💡 How to Use in Practice

Apply to chart and the background colors continuously with the market mood. Deeper green means higher Bull-state conviction, deeper red means Bear, pale grey means Range (no direction). The state-colored EMA shows the most-likely regime at a glance. Check STATE POSTERIOR in the HUD for the three probabilities; a sharp rise in Bull probability overtaking Bear marks a turning point. LEARNED EMISSIONS shows the model-learned mean return and volatility of Bull/Bear/Range for this instrument. Standing aside while Range probability is high, and entering once Bull/Bear is clear, is effective. Combining with other trend tools and trading only when regimes agree is another approach.

⚠️ Important Notes

This uses an online-EM approximation (not full Baum-Welch EM), a filtered forward posterior (not the Viterbi algorithm), Gaussian emissions, and sign-clamped labels. The forward-algorithm math, however, is the genuine HMM recursion. With 1-D return observations, Bull/Bear are clear by sign, while Range is represented as a near-zero mean. Online learning needs convergence time per instrument; emissions are not optimized initially. All regime estimates are probabilistic decisions based on historical data and do not guarantee future profits.

🚨 Disclaimer

This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. No signal guarantees future profit, and past performance does not indicate future results. All trading decisions are made at your own risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © AetherEdge — Hidden Markov Regime
//@version=6

// ┌──────────────────────────────────────────────────────────────────────────┐
// │  AetherEdge - Hidden Markov Regime  ·  AE-HMM                               │
// │                                                                            │
// │  Treats the market regime as a HIDDEN state you can't observe directly     │
// │  (Bull / Bear / Range) and infers the probability of each from the         │
// │  observable returns, using a Hidden Markov Model's forward algorithm. The  │
// │  background bleeds a continuous "mood gradient" — green when the Bull       │
// │  state dominates the posterior, red for Bear, neutral grey for Range.      │
// │                                                                            │
// │  HOW IT WORKS                                                              │
// │  • 3 hidden states, each with a Gaussian emission over ATR-normalized      │
// │    returns: Bull (mean > 0), Bear (mean < 0), Range (mean ≈ 0).            │
// │  • A sticky transition matrix A[i→j] encodes regime persistence.           │
// │  • Forward recursion (scaled): γ_t(j) ∝ [Σ_i γ_{t-1}(i)·A[i][j]]·b_j(o_t)  │
// │    gives the filtered posterior probability of each state at each bar.     │
// │  • Online EM nudges each state's emission mean/variance toward the data    │
// │    it explains — the model LEARNS what Bull/Bear/Range look like here.     │
// │    Means are sign-clamped to prevent label switching.                     │
// │                                                                            │
// │  SIGNAL: when the most-likely state switches INTO Bull → BUY, into Bear →  │
// │  SELL. Range is treated as stand-aside.                                   │
// │                                                                            │
// │  HONEST SCOPE: online-EM approximation (not full Baum-Welch), filtered     │
// │  forward posterior (not Viterbi), Gaussian emissions, sign-clamped labels. │
// │  The forward-algorithm math, however, is the genuine HMM recursion.       │
// └──────────────────────────────────────────────────────────────────────────┘

indicator("AetherEdge - Hidden Markov Regime", "AE-HMM", overlay = true,
     max_labels_count = 100)


// ============================================================================
//  ░░ INPUTS — HMM ░░
// ============================================================================
gH = "▓ HMM MODEL ▓"
hm_srcInp     = input.source(close, "Source", group = gH)
hm_obsWinInp  = input.int(1, "Return Smoothing", minval = 1, maxval = 10, group = gH,
     tooltip = "EMA smoothing applied to the return observation. 1 = raw 1-bar return.")
hm_persistInp = input.float(0.90, "Regime Persistence", minval = 0.50, maxval = 0.99, step = 0.01, group = gH,
     tooltip = "Diagonal of the transition matrix — how sticky regimes are. Higher = smoother, slower state changes. Off-diagonals split the remainder.")

gL = "▓ ONLINE LEARNING (EM) ▓"
lr_enableInput= input.bool(true, "Learn Emission Parameters", group = gL,
     tooltip = "Online-EM nudges each state's mean/variance toward the returns it explains. Means are sign-clamped to keep Bull>0, Bear<0.")
lr_rateInput  = input.float(0.03, "Learning Rate", minval = 0.005, maxval = 0.2, step = 0.005, group = gL)
lr_minVarInp  = input.float(0.2, "Min Variance Floor", minval = 0.05, maxval = 2.0, step = 0.05, group = gL)
lr_initMuInp  = input.float(0.5, "Initial |Bull/Bear Mean|", minval = 0.1, maxval = 2.0, step = 0.1, group = gL,
     tooltip = "Starting separation of Bull (+) and Bear (−) emission means, in ATR-normalized return units.")

gS = "▓ SIGNAL ▓"
sig_minProbInp= input.float(0.4, "Min State Probability to Signal", minval = 0.34, maxval = 0.9, step = 0.02, group = gS,
     tooltip = "The new dominant state must reach at least this posterior probability before a signal fires.")

gVI = "▓ VISUALS ▓"
vi_themeInput = input.string("Emerald / Ruby", "Palette",
     options = ["Emerald / Ruby", "Forest / Crimson", "Mint / Rose"], group = gVI)
vi_bgMood     = input.bool(true, "Background Mood Gradient", group = gVI)
vi_stateEma   = input.bool(true, "State-Colored EMA", group = gVI)
vi_emaLenInp  = input.int(20, "EMA Length", minval = 2, maxval = 200, group = gVI)
vi_stackArea  = input.bool(false, "State Probability Stack (below price)", group = gVI)
vi_marks      = input.bool(true, "BUY/SELL Markers", group = gVI)

gHU = "▓ HUD ▓"
hud_showInp   = input.bool(true, "Show HUD", group = gHU)


// ============================================================================
//  ░░ PALETTE ░░
// ============================================================================
var color cBull = na
var color cBear = na
var color cRange = na
var color cAcc = na
var color cTxt = #eef2f0
var color cTxtD = #6b7d76
var color cPanel = #080b0a
var color cPanelHd = #0f1614

setPalette() =>
    [bu, be, rg, a] = switch vi_themeInput
        "Forest / Crimson" => [#22c55e, #dc2626, #71717a, #d4af37]
        "Mint / Rose"      => [#4ade80, #fb7185, #94a3b8, #e879f9]
        => [#10e0a0, #ff3860, #6b7d76, #d4af37]   // Emerald / Ruby
    [bu, be, rg, a]
[pBu, pBe, pRg, pA] = setPalette()
cBull := pBu
cBear := pBe
cRange := pRg
cAcc := pA


// ============================================================================
//  ░░ HELPERS ░░
// ============================================================================
sdiv(a, b) =>
    b != 0 ? a / b : 0.0
clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))
gaussPdf(x, mu, variance) =>
    variance > 0.0 ? math.exp(-0.5 * (x - mu) * (x - mu) / variance) / math.sqrt(2.0 * math.pi * variance) : 0.0


// ============================================================================
//  ░░ OBSERVATION ░░
// ============================================================================
atr = ta.atr(14)
rawRet = hm_srcInp - hm_srcInp[1]
o = ta.ema(sdiv(rawRet, atr), hm_obsWinInp)


// ============================================================================
//  ░░ HMM STATE ░░
//  States indexed: 0 = Bull, 1 = Bear, 2 = Range.
//  Arrays: gamma (posterior), mu, sigma2 (emissions), A (3x3 transition).
// ============================================================================
BULL = 0
BEAR = 1
RANGE = 2

var float[] gamma  = array.new<float>(3, 0.3333)
var float[] mu     = array.new<float>(3, 0.0)
var float[] sigma2 = array.new<float>(3, 1.0)
var float[] A      = array.new<float>(9, 0.0)

if barstate.isfirst
    array.set(mu, BULL,  lr_initMuInp)
    array.set(mu, BEAR, -lr_initMuInp)
    array.set(mu, RANGE, 0.0)
    array.set(sigma2, BULL, 1.0)
    array.set(sigma2, BEAR, 1.0)
    array.set(sigma2, RANGE, 0.5)


// Build transition matrix from persistence (row-major A[i*3+j]).
persist = hm_persistInp
offDiag = (1.0 - persist) / 2.0
for i = 0 to 2
    for j = 0 to 2
        array.set(A, i * 3 + j, i == j ? persist : offDiag)


// ============================================================================
//  ░░ FORWARD RECURSION + ONLINE EM (confirmed bars only) ░░
// ============================================================================
if barstate.isconfirmed and not na(o) and bar_index > 1
    // Forward (filtered) recursion with normalization.
    newGamma = array.new<float>(3, 0.0)
    total = 0.0
    for j = 0 to 2
        pred = 0.0
        for i = 0 to 2
            pred += array.get(gamma, i) * array.get(A, i * 3 + j)
        bj = gaussPdf(o, array.get(mu, j), array.get(sigma2, j))
        aj = pred * bj
        array.set(newGamma, j, aj)
        total += aj
    if total > 1e-12
        for j = 0 to 2
            array.set(gamma, j, array.get(newGamma, j) / total)

    // Online EM: nudge emissions toward the data each state explains.
    if lr_enableInput
        eta = lr_rateInput
        for j = 0 to 2
            g = array.get(gamma, j)
            muj = array.get(mu, j)
            newMu = muj + eta * g * (o - muj)
            resid = o - newMu
            newVar = array.get(sigma2, j) + eta * g * (resid * resid - array.get(sigma2, j))
            array.set(mu, j, newMu)
            array.set(sigma2, j, math.max(newVar, lr_minVarInp))
        // Sign-clamp means to prevent label switching.
        array.set(mu, BULL,  math.max(array.get(mu, BULL),  0.05))
        array.set(mu, BEAR,  math.min(array.get(mu, BEAR), -0.05))
        array.set(mu, RANGE, clamp(array.get(mu, RANGE), -0.15, 0.15))


// ============================================================================
//  ░░ POSTERIOR SUMMARIES ░░
// ============================================================================
gBull = array.get(gamma, BULL)
gBear = array.get(gamma, BEAR)
gRange = array.get(gamma, RANGE)

mlState = BULL
mlProb = gBull
if gBear > mlProb
    mlProb := gBear
    mlState := BEAR
if gRange > mlProb
    mlProb := gRange
    mlState := RANGE

bbScore = gBull - gBear   // [-1, +1]


// ============================================================================
//  ░░ SIGNAL ░░
// ============================================================================
var int prevMl = -1
enterBull = mlState == BULL and prevMl != BULL and mlProb >= sig_minProbInp
enterBear = mlState == BEAR and prevMl != BEAR and mlProb >= sig_minProbInp

fireBuy  = barstate.isconfirmed and enterBull and prevMl != -1
fireSell = barstate.isconfirmed and enterBear and prevMl != -1
if barstate.isconfirmed
    prevMl := mlState


// ============================================================================
//  ░░ VISUALS — mood gradient background ░░
//  Red → grey → green via a two-segment gradient through the Range color.
// ============================================================================
bgBase = bbScore >= 0.0 ? color.from_gradient(bbScore, 0.0, 1.0, cRange, cBull) : color.from_gradient(bbScore, -1.0, 0.0, cBear, cRange)
bgTransp = 100 - int(clamp(mlProb * 50.0, 8.0, 45.0))
bgcolor(vi_bgMood ? color.new(bgBase, bgTransp) : na, editable = false)

// State-colored EMA.
ema = ta.ema(close, vi_emaLenInp)
emaCol = mlState == BULL ? cBull : mlState == BEAR ? cBear : cRange
plot(vi_stateEma ? ema : na, "State EMA", color = emaCol, linewidth = 2)

// BUY/SELL markers.
plotshape(vi_marks and fireBuy,  title = "BUY",  style = shape.labelup,   location = location.belowbar, color = cBull, textcolor = #04140f, text = "BULL▲", size = size.small)
plotshape(vi_marks and fireSell, title = "SELL", style = shape.labeldown, location = location.abovebar, color = cBear, textcolor = #1a0509, text = "BEAR▼", size = size.small)

// State probability stack below price (optional).
baseY = ta.lowest(low, 100) - atr * 1.5
stackH = atr * 4.0
sBull = vi_stackArea ? baseY + gBull * stackH : na
sRange = vi_stackArea ? baseY + (gBull + gRange) * stackH : na
sTop = vi_stackArea ? baseY + stackH : na
pBaseStk = plot(vi_stackArea ? baseY : na, "stkBase", color = na, editable = false, display = display.none)
pBullStk = plot(sBull, "stkBull", color = na, editable = false)
pRangeStk = plot(sRange, "stkRange", color = na, editable = false)
pTopStk = plot(sTop, "stkTop", color = na, editable = false)
fill(pBaseStk, pBullStk, color = vi_stackArea ? color.new(cBull, 55) : na, title = "Bull mass")
fill(pBullStk, pRangeStk, color = vi_stackArea ? color.new(cRange, 65) : na, title = "Range mass")
fill(pRangeStk, pTopStk, color = vi_stackArea ? color.new(cBear, 55) : na, title = "Bear mass")


// ============================================================================
//  ░░ HUD ░░
// ============================================================================
bar10(p) =>
    int filled = math.round(clamp(p, 0.0, 1.0) * 10)
    string s = ""
    for i = 1 to 10
        s += i <= filled ? "█" : "░"
    s

stateName(st) =>
    st == BULL ? "● BULL" : st == BEAR ? "● BEAR" : "● RANGE"
stateColor(st) =>
    st == BULL ? cBull : st == BEAR ? cBear : cRange

var table hud = na
if hud_showInp and na(hud)
    hud := table.new(position.top_right, 2, 12, bgcolor = cPanel,
         border_color = color.new(cAcc, 60), border_width = 1, frame_color = color.new(cAcc, 40), frame_width = 1)

if hud_showInp and barstate.islast
    sz = size.normal

    table.cell(hud, 0, 0, "HIDDEN MARKOV REGIME", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 0, "3-state HMM", text_color = cTxtD, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_right)

    table.cell(hud, 0, 1, "regime", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 1, stateName(mlState) + "  " + str.tostring(math.round(mlProb * 100)) + "%", text_color = stateColor(mlState), text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 2, "▔ STATE POSTERIOR ▔", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 2, "", bgcolor = cPanelHd)

    table.cell(hud, 0, 3, "Bull", text_color = cBull, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 3, bar10(gBull) + " " + str.tostring(math.round(gBull * 100)) + "%", text_color = cTxt, text_size = sz, text_halign = text.align_right)
    table.cell(hud, 0, 4, "Range", text_color = cRange, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 4, bar10(gRange) + " " + str.tostring(math.round(gRange * 100)) + "%", text_color = cTxt, text_size = sz, text_halign = text.align_right)
    table.cell(hud, 0, 5, "Bear", text_color = cBear, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 5, bar10(gBear) + " " + str.tostring(math.round(gBear * 100)) + "%", text_color = cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 6, "▔ LEARNED EMISSIONS ▔", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 6, "μ (σ)", text_color = cTxtD, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_right)

    table.cell(hud, 0, 7, "Bull", text_color = cBull, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 7, str.tostring(array.get(mu, BULL), "#.00") + " (" + str.tostring(math.sqrt(array.get(sigma2, BULL)), "#.00") + ")", text_color = cTxt, text_size = sz, text_halign = text.align_right)
    table.cell(hud, 0, 8, "Bear", text_color = cBear, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 8, str.tostring(array.get(mu, BEAR), "#.00") + " (" + str.tostring(math.sqrt(array.get(sigma2, BEAR)), "#.00") + ")", text_color = cTxt, text_size = sz, text_halign = text.align_right)
    table.cell(hud, 0, 9, "Range", text_color = cRange, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 9, str.tostring(array.get(mu, RANGE), "#.00") + " (" + str.tostring(math.sqrt(array.get(sigma2, RANGE)), "#.00") + ")", text_color = cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 10, "persistence", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 10, str.tostring(persist, "#.00"), text_color = cTxt, text_size = sz, text_halign = text.align_right)

    sigState = prevMl == BULL ? "▲ bull bias" : prevMl == BEAR ? "▼ bear bias" : "· neutral"
    sigCol = prevMl == BULL ? cBull : prevMl == BEAR ? cBear : cTxtD
    table.cell(hud, 0, 11, "signal state", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 11, sigState, text_color = sigCol, text_size = sz, text_halign = text.align_right)


// ============================================================================
//  ░░ ALERTS ░░
// ============================================================================
alertcondition(fireBuy,  "Bull Regime Entry",  "AE-HMM: regime switched to Bull")
alertcondition(fireSell, "Bear Regime Entry",  "AE-HMM: regime switched to Bear")
````
