# AetherEdge - Particle Swarm Filter

- url: https://www.tradingview.com/script/fBAL7mVM/
- type: indicator
- pine_id: PUB;263905241892434d826c2bf376c30419
- version: 1.0

## Description

🖊️ Overview

AE-SWARM tracks the market's hidden trend with a particle filter (sequential Monte Carlo). A swarm of hypotheses (particles) predicts, gets weighted by how well it explains the new price, and resamples — fit survive, unfit die. The swarm is drawn as a translucent point cloud on the latest bar, condensing into a tight band when confident and scattering into fog when uncertain — like fireflies. The swarm mean is the estimated trend, its spread the uncertainty, its mean velocity the momentum.

🔶 Key Features

Particle filter (sequential Monte Carlo): tracks hidden trend state with a swarm
Damped constant-velocity model: [level, velocity] state space
Systematic resampling: resamples particles when ESS collapses
Volatility-adaptive noise: process/observation noise scaled by ATR
Firefly particle cloud: swarm drawn as points on the latest bar
Uncertainty band: swarm spread as a ±spread band
BUY/SELL on swarm convergence + velocity flip
HUD showing effective sample size (ESS) and convergence state
No repaint: randomness seeded by bar
Per-event alerts

🧠 Technical Architecture

This implements a particle filter (sequential Monte Carlo). Each particle holds a damped constant-velocity state [level, velocity] (level += velocity; velocity = φ·velocity + ε), running each confirmed bar: PREDICT — propagate each particle with Gaussian process noise. WEIGHT — score each by observation likelihood w_i ∝ N(price | level_i, σ_obs²), normalize. RESAMPLE — when effective sample size ESS = 1/Σw_i² drops below threshold, systematic resampling duplicates high-weight particles and prunes low-weight ones. ESTIMATE — weighted mean is the trend, weighted stdev the uncertainty, mean velocity the momentum. Process/observation noise scale with ATR. Randomness is Box-Muller, seeded by bar index so it does not repaint. Signals fire when swarm velocity flips sign while the swarm is converging (spread shrinking). Particle updates run on confirmed bars only.

⚙️ Recommended Settings & Tuning Guide

Particle Count 40 is a starting point — more gives a smoother estimate but is heavier (max 80). Velocity Persistence (φ) 0.92 damps the velocity state — near 1 is random-walk velocity, lower is mean-reverting momentum. Process Noise: Velocity 0.15×ATR is how much velocity hypotheses jitter — higher is reactive and noisier. Observation Noise 0.6×ATR is the assumed price measurement noise — higher gives looser weighting and a broader swarm, lower is sharper but can degenerate. Resample when ESS < 0.5×N is the resample threshold. Require Swarm Convergence ON fires only when the swarm is converging (rising confidence) at the velocity flip.

💡 How to Use in Practice

Apply to chart and the swarm scatters like fireflies on the latest bar. A tight, condensed band means the swarm has converged (high confidence); a scattered fog means uncertainty. The swarm mean line is the estimated trend, colored by velocity sign. The uncertainty band (±spread) width shows the swarm's scatter. Check "eff. sample size" in the HUD for particle diversity; low ESS is the resampling moment. When swarm velocity flips while converging (HUD shows "converging"), a signal fires as a confident change of heading. Higher process noise is more reactive; lower is smoother.

⚠️ Important Notes

This is a genuine particle filter, but with a modest particle count for Pine's compute budget, systematic resampling, and ATR-scaled (not learned) noise. Randomness is seeded by bar index so it does not repaint, but real-time bars show the last confirmed state. As a stochastic simulation, details can vary with the particles' initial scatter even at the same settings. The swarm estimate is a guide to the trend, not a certain prediction. Particle updates run on confirmed bars only. All signals are probabilistic decisions based on historical data and do not guarantee future profits.

🚨 Disclaimer

This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. No signal guarantees future profit, and past performance does not indicate future results. All trading decisions are made at your own risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © AetherEdge — Particle Swarm Filter
//@version=6

// ┌──────────────────────────────────────────────────────────────────────────┐
// │  AetherEdge - Particle Swarm Filter  ·  AE-SWARM                            │
// │                                                                            │
// │  Tracks the market's hidden trend with a PARTICLE FILTER — a swarm of      │
// │  hypotheses (particles) that predict, get weighted by how well they        │
// │  explain the new price, and resample (fit survive, unfit die). The swarm   │
// │  is drawn as a translucent cloud of points on the latest bar — fireflies   │
// │  that condense into a tight band when the filter is confident and scatter  │
// │  into fog when it isn't.                                                   │
// │                                                                            │
// │  HOW IT WORKS (genuine sequential Monte Carlo)                            │
// │  • Each particle holds a state [level, velocity] of a damped              │
// │    constant-velocity model: level += velocity; velocity = φ·velocity + ε.  │
// │  • PREDICT: propagate every particle with Gaussian process noise.          │
// │  • WEIGHT: w_i ∝ N(price | level_i, σ_obs²) — Gaussian observation         │
// │    likelihood; normalize.                                                  │
// │  • RESAMPLE: systematic resampling when the effective sample size (ESS)    │
// │    collapses — duplicates high-weight particles, prunes low-weight ones.   │
// │  • ESTIMATE: weighted mean = trend; weighted spread = uncertainty;         │
// │    mean velocity = momentum.                                              │
// │  • Process / observation noise scale with ATR so the swarm breathes.       │
// │                                                                            │
// │  SIGNAL: swarm velocity flips sign WHILE the swarm is converging (spread   │
// │  shrinking) → BUY/SELL — a confident change of heading.                    │
// │                                                                            │
// │  HONEST SCOPE: a genuine particle filter, but with a modest particle count │
// │  for Pine's budget, systematic resampling, and ATR-scaled (not learned)    │
// │  noise. Randomness is seeded by bar so it does NOT repaint. Not deep RL.   │
// └──────────────────────────────────────────────────────────────────────────┘

indicator("AetherEdge - Particle Swarm Filter", "AE-SWARM", overlay = true,
     max_bars_back = 100, max_labels_count = 500, max_lines_count = 100)


// ============================================================================
//  ░░ INPUTS — particle filter ░░
// ============================================================================
gP = "▓ PARTICLE FILTER ▓"
pf_srcInp   = input.source(close, "Source", group = gP)
pf_npInp    = input.int(40, "Particle Count", minval = 10, maxval = 80, group = gP,
     tooltip = "Number of particles in the swarm. More = smoother estimate but heavier. 40 is a good balance.")
pf_phiInp   = input.float(0.92, "Velocity Persistence (φ)", minval = 0.50, maxval = 1.0, step = 0.01, group = gP,
     tooltip = "Damping of the velocity state. 1 = pure random walk in velocity; lower = mean-reverting momentum.")
pf_procVInp = input.float(0.15, "Process Noise: Velocity (× ATR)", minval = 0.01, maxval = 1.0, step = 0.01, group = gP,
     tooltip = "How much the velocity hypotheses jitter each bar. Higher = more responsive, noisier swarm.")
pf_procLInp = input.float(0.10, "Process Noise: Level (× ATR)", minval = 0.01, maxval = 1.0, step = 0.01, group = gP)
pf_obsInp   = input.float(0.6, "Observation Noise (× ATR)", minval = 0.1, maxval = 3.0, step = 0.1, group = gP,
     tooltip = "Assumed price measurement noise. Higher = looser weighting, broader swarm; lower = sharper, can degenerate.")
pf_essInp   = input.float(0.5, "Resample when ESS <  (× N)", minval = 0.2, maxval = 1.0, step = 0.05, group = gP,
     tooltip = "Resample threshold as a fraction of particle count. 0.5 = resample when effective sample size drops below half.")

gS = "▓ SIGNAL ▓"
sig_needConv  = input.bool(true, "Require Swarm Convergence", group = gS,
     tooltip = "Only fire when the swarm spread is shrinking (rising confidence) at the velocity flip.")

gVI = "▓ VISUALS ▓"
vi_themeInput = input.string("Firefly", "Palette",
     options = ["Firefly", "Plasma Swarm", "Aurora Swarm"], group = gVI)
vi_particles  = input.bool(true, "Show Particle Cloud (latest bar)", group = gVI)
vi_meanLine   = input.bool(true, "Show Swarm Mean (trend)", group = gVI)
vi_spreadBand = input.bool(true, "Show Uncertainty Band (±spread)", group = gVI)
vi_marks      = input.bool(true, "BUY/SELL Markers", group = gVI)

gH = "▓ HUD ▓"
hud_showInp   = input.bool(true, "Show HUD", group = gH)


// ============================================================================
//  ░░ PALETTE ░░
// ============================================================================
var color cBull = na
var color cBear = na
var color cMean = na
var color cAcc = na
var color cTxt = #eef2f0
var color cTxtD = #6b7d76
var color cPanel = #080b0a
var color cPanelHd = #0f1614

setPalette() =>
    [bu, be, me, a] = switch vi_themeInput
        "Plasma Swarm" => [#00e5ff, #ff4081, #b388ff, #fbbf24]
        "Aurora Swarm" => [#10e0a0, #ff3860, #a5b4fc, #d4af37]
        => [#aaff00, #ff1493, #ffd166, #d4af37]   // Firefly
    [bu, be, me, a]
[pBu, pBe, pMe, pA] = setPalette()
cBull := pBu
cBear := pBe
cMean := pMe
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
// Deterministic Gaussian noise via Box-Muller; seed makes it repaint-free.
gaussNoise(seed) =>
    u1 = math.max(math.random(0.0, 1.0, seed), 1e-9)
    u2 = math.random(0.0, 1.0, seed + 524287)
    math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2)


// ============================================================================
//  ░░ COMMON ░░
// ============================================================================
atr = ta.atr(14)
NP = pf_npInp


// ============================================================================
//  ░░ PARTICLE STATE ░░
// ============================================================================
var float[] pLevel  = array.new<float>(NP, 0.0)
var float[] pVel    = array.new<float>(NP, 0.0)
var float[] pWeight = array.new<float>(NP, 0.0)
var bool pfInit = false

if not pfInit and bar_index > 1 and not na(atr) and atr > 0
    for i = 0 to NP - 1
        array.set(pLevel, i, pf_srcInp + gaussNoise(i * 13 + 1) * atr)
        array.set(pVel, i, 0.0)
        array.set(pWeight, i, 1.0 / NP)
    pfInit := true


// ============================================================================
//  ░░ PARTICLE FILTER UPDATE (confirmed bars only — no repaint) ░░
// ============================================================================
phi = pf_phiInp
procV = atr * pf_procVInp
procL = atr * pf_procLInp
obsVar = (atr * pf_obsInp) * (atr * pf_obsInp)

if pfInit and barstate.isconfirmed and not na(atr)
    // 1) PREDICT — propagate each particle through the dynamics + process noise.
    for i = 0 to NP - 1
        sB = bar_index * (NP * 8) + i * 8
        vOld = array.get(pVel, i)
        lOld = array.get(pLevel, i)
        vNew = phi * vOld + gaussNoise(sB) * procV
        lNew = lOld + vNew + gaussNoise(sB + 2) * procL
        array.set(pVel, i, vNew)
        array.set(pLevel, i, lNew)

    // 2) WEIGHT — Gaussian observation likelihood, then normalize.
    totalW = 0.0
    for i = 0 to NP - 1
        w = gaussPdf(pf_srcInp, array.get(pLevel, i), obsVar)
        array.set(pWeight, i, w)
        totalW += w
    if totalW > 1e-300
        for i = 0 to NP - 1
            array.set(pWeight, i, array.get(pWeight, i) / totalW)
    else
        for i = 0 to NP - 1
            array.set(pWeight, i, 1.0 / NP)

    // 3) RESAMPLE — systematic resampling when ESS collapses.
    sumW2 = 0.0
    for i = 0 to NP - 1
        w = array.get(pWeight, i)
        sumW2 += w * w
    essNow = sumW2 > 0.0 ? 1.0 / sumW2 : NP
    if essNow < pf_essInp * NP
        cdf = array.new<float>(NP, 0.0)
        c = 0.0
        for i = 0 to NP - 1
            c += array.get(pWeight, i)
            array.set(cdf, i, c)
        newL = array.new<float>(NP, 0.0)
        newV = array.new<float>(NP, 0.0)
        u0 = math.random(0.0, 1.0, bar_index * 7 + 3) / NP
        j = 0
        for k = 0 to NP - 1
            uk = u0 + k / NP
            while j < NP - 1 and array.get(cdf, j) < uk
                j += 1
            array.set(newL, k, array.get(pLevel, j))
            array.set(newV, k, array.get(pVel, j))
        for i = 0 to NP - 1
            array.set(pLevel, i, array.get(newL, i))
            array.set(pVel, i, array.get(newV, i))
            array.set(pWeight, i, 1.0 / NP)


// ============================================================================
//  ░░ ESTIMATES (every bar from current particle state) ░░
// ============================================================================
estL = 0.0
estV = 0.0
sW2 = 0.0
for i = 0 to NP - 1
    w = array.get(pWeight, i)
    estL += w * array.get(pLevel, i)
    estV += w * array.get(pVel, i)
    sW2 += w * w
spreadV = 0.0
for i = 0 to NP - 1
    w = array.get(pWeight, i)
    d = array.get(pLevel, i) - estL
    spreadV += w * d * d
spreadV := math.sqrt(math.max(spreadV, 0.0))
ess = sW2 > 0.0 ? 1.0 / sW2 : NP

estLevel = pfInit ? estL : pf_srcInp
estVel = pfInit ? estV : 0.0


// ============================================================================
//  ░░ SIGNAL ░░
// ============================================================================
converging = spreadV < spreadV[1]
velUp = estVel > 0.0 and estVel[1] <= 0.0
velDn = estVel < 0.0 and estVel[1] >= 0.0

buyRaw = velUp and (not sig_needConv or converging)
sellRaw = velDn and (not sig_needConv or converging)

var int lastSig = 0
fireBuy = pfInit and buyRaw and lastSig != 1
fireSell = pfInit and sellRaw and lastSig != -1
if barstate.isconfirmed
    if fireBuy
        lastSig := 1
    if fireSell
        lastSig := -1
    if estVel > 0 and estVel[1] > 0 and estVel < estVel[1] and lastSig == 1 and estVel < 0.05 * atr
        lastSig := 0
    if estVel < 0 and estVel[1] < 0 and estVel > estVel[1] and lastSig == -1 and estVel > -0.05 * atr
        lastSig := 0


// Confidence: swarm convergence + velocity strength.
convScore = atr > 0 ? clamp(1.0 - spreadV / (atr * 2.0), 0.0, 1.0) : 0.0
velScore = atr > 0 ? clamp(math.abs(estVel) / (atr * 0.5), 0.0, 1.0) : 0.0
confidencePct = clamp(convScore * 55.0 + velScore * 45.0, 0.0, 100.0)


// ============================================================================
//  ░░ VISUALS — swarm mean + uncertainty band ░░
// ============================================================================
velCol = estVel > 0.0 ? cBull : estVel < 0.0 ? cBear : cMean
plot(vi_meanLine and pfInit ? estLevel : na, "Swarm Mean", color = color.new(velCol, 0), linewidth = 2)

upB = estLevel + spreadV
dnB = estLevel - spreadV
pUp = plot(vi_spreadBand and pfInit ? upB : na, "Spread+", color = na, editable = false)
pDn = plot(vi_spreadBand and pfInit ? dnB : na, "Spread−", color = na, editable = false)
fill(pUp, pDn, color = vi_spreadBand and pfInit ? color.new(velCol, 84) : na, title = "Uncertainty")

// Particle cloud on the latest bar — fireflies. Redrawn each bar.
var label[] pLabels = array.new<label>(0)
if vi_particles and barstate.islast and pfInit
    if array.size(pLabels) > 0
        for i = 0 to array.size(pLabels) - 1
            label.delete(array.get(pLabels, i))
        array.clear(pLabels)
    for i = 0 to NP - 1
        lvl = array.get(pLevel, i)
        vel = array.get(pVel, i)
        w = array.get(pWeight, i)
        wNorm = clamp(w * NP, 0.0, 2.0)
        transp = int(clamp(85.0 - wNorm * 30.0, 25.0, 88.0))
        pcol = vel > 0.0 ? color.new(cBull, transp) : color.new(cBear, transp)
        lb = label.new(bar_index, lvl, "•", style = label.style_none, textcolor = pcol, size = size.tiny)
        array.push(pLabels, lb)

// BUY/SELL markers.
plotshape(vi_marks and fireBuy  and barstate.isconfirmed, title = "BUY",  style = shape.labelup,   location = location.belowbar, color = cBull, textcolor = #04140f, text = "SWRM▲", size = size.small)
plotshape(vi_marks and fireSell and barstate.isconfirmed, title = "SELL", style = shape.labeldown, location = location.abovebar, color = cBear, textcolor = #1a0509, text = "SWRM▼", size = size.small)


// ============================================================================
//  ░░ HUD ░░
// ============================================================================
bar10(p) =>
    int filled = math.round(clamp(p, 0.0, 1.0) * 10)
    string s = ""
    for i = 1 to 10
        s += i <= filled ? "█" : "░"
    s

var table hud = na
if hud_showInp and na(hud)
    hud := table.new(position.top_right, 2, 11, bgcolor = cPanel,
         border_color = color.new(cAcc, 60), border_width = 1, frame_color = color.new(cAcc, 40), frame_width = 1)

if hud_showInp and barstate.islast
    sz = size.normal
    velDir = estVel > 0.0 ? "▲ rising" : estVel < 0.0 ? "▼ falling" : "· flat"
    velDCol = estVel > 0.0 ? cBull : estVel < 0.0 ? cBear : cTxtD
    convState = spreadV < spreadV[1] ? "converging" : "diverging"
    convCol = spreadV < spreadV[1] ? cBull : cTxtD

    table.cell(hud, 0, 0, "PARTICLE SWARM", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 0, str.tostring(NP) + " particles", text_color = cTxtD, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_right)

    table.cell(hud, 0, 1, "swarm mean", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 1, str.tostring(estLevel, format.mintick), text_color = velDCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 2, "velocity", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 2, velDir + "  " + str.tostring(atr > 0 ? estVel / atr : 0.0, "#.000") + " ATR", text_color = velDCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 3, "uncertainty", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 3, str.tostring(atr > 0 ? spreadV / atr : 0.0, "#.00") + " ATR  " + convState, text_color = convCol, text_size = sz, text_halign = text.align_right)

    essFrac = ess / NP
    essCol = essFrac > 0.7 ? cBull : essFrac > 0.4 ? cTxt : cBear
    table.cell(hud, 0, 4, "eff. sample size", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 4, bar10(essFrac) + " " + str.tostring(ess, "#.0") + "/" + str.tostring(NP), text_color = essCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 5, "confidence", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 5, bar10(confidencePct / 100.0) + " " + str.tostring(math.round(confidencePct)) + "%", text_color = confidencePct >= 60 ? cBull : confidencePct >= 40 ? cTxt : cTxtD, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 6, "▔ MODEL ▔", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 6, "", bgcolor = cPanelHd)

    table.cell(hud, 0, 7, "velocity φ", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 7, str.tostring(phi, "#.00"), text_color = cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 8, "proc noise v/l", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 8, str.tostring(pf_procVInp, "#.00") + " / " + str.tostring(pf_procLInp, "#.00"), text_color = cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 9, "obs noise", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 9, str.tostring(pf_obsInp, "#.0") + " ATR", text_color = cTxt, text_size = sz, text_halign = text.align_right)

    sigState = lastSig == 1 ? "▲ long bias" : lastSig == -1 ? "▼ short bias" : "· neutral"
    sigCol = lastSig == 1 ? cBull : lastSig == -1 ? cBear : cTxtD
    table.cell(hud, 0, 10, "signal state", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 10, sigState, text_color = sigCol, text_size = sz, text_halign = text.align_right)


// ============================================================================
//  ░░ ALERTS ░░
// ============================================================================
alertcondition(fireBuy,  "Swarm BUY",  "AE-SWARM: swarm velocity flipped up (converging)")
alertcondition(fireSell, "Swarm SELL", "AE-SWARM: swarm velocity flipped down (converging)")
````
