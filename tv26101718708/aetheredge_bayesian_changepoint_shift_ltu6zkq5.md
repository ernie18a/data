# AetherEdge - Bayesian Changepoint Shift

- url: https://www.tradingview.com/script/LTu6zkQ5/
- type: indicator
- pine_id: PUB;38ce45322a0a4e719c37d4c03b7a6f8e
- version: 1.0

## Description

🖊️ Overview

AE-SHIFT detects trend reversals as a probability using Bayesian Online Changepoint Detection (BOCPD, Adams & MacKay 2007). Rather than "did a moving average cross?", it asks "what is the probability that the current price regime just ended?" — computing a full posterior distribution over how long the current trend has lasted (run-length). An adaptive layer learns the hazard (reversal frequency) online from the spacing between changepoints, auto-adapting to each instrument's rhythm.

🔶 Key Features

Faithful BOCPD: sequential Bayesian update of the run-length posterior
Gaussian predictive likelihood + Welford online statistics: probabilistic evaluation of each regime hypothesis
Adaptive hazard learning: auto-estimates expected run-length λ from changepoint intervals
Quantifies changepoint probability 0-100%: clear reversal signal
Multi-layer glow rendering: luminous vertical lines at changepoints
Run-length distribution mini-heatmap: visualizes the distribution shape in the HUD
Probability-linked background pulse and segment trend line
BUY/SELL markers + per-event alerts

🧠 Technical Architecture

This implements the core BOCPD algorithm. Each bar maintains P(run-length = r | data) for r = 0..Rmax, with each hypothesis carrying Welford online statistics (mean/variance) of returns inside the segment. For each new observation, a Gaussian predictive likelihood π(x|r) is computed, weighted by the hazard function H = 1/λ, propagated forward (growth: r→r+1), with changepoint mass collapsed to r=0 and normalized. P(r=0) is the changepoint probability. Observations are ATR-normalized returns for scale stability. Adaptive hazard re-estimates λ from a moving average of detected changepoint intervals, dynamically adjusting the hazard. Signals fire when changepoint probability exceeds threshold + peaks + new segment direction. State updates occur on confirmed bars only to avoid repainting.

⚙️ Recommended Settings & Tuning Guide

Expected Run Length (λ) 50 is a starting point — larger for rare-reversal instruments and higher timeframes, smaller for frequently-flipping ones. Adaptive Hazard Learning ON is recommended to auto-learn the instrument's rhythm. Max Run Length Tracked 60 is a compute trade-off; raise to track longer regimes at higher cost. Changepoint Probability Threshold 0.25 baseline; 0.15 more sensitive, 0.4 stricter. Prior Variance / Observation Noise Variance tune the predictive distribution; raise Observation Noise for noisy instruments. Direction Confirmation 3 sets reversal-direction sensitivity.

💡 How to Use in Practice

Apply to chart and changepoints print luminous vertical lines with BUY/SELL labels. The glowing sub-band below price shows changepoint probability in real time — the hotter it glows, the nearer a reversal. The HUD's RUN-LENGTH DIST section is most important: high r=0 (reset) probability means a reversal is imminent, while dense r=21+ means a stable trend continues — read market state from the distribution shape. A sudden drop in expected run-length is a reversal precursor. The adaptive λ value tells you how many bars, on average, this instrument runs between reversals. Combining with other trend indicators and entering only when changepoint probability is high is effective.

⚠️ Important Notes

This is a truncated approximation of BOCPD (run-length truncated at Max) using a Gaussian predictive likelihood (a simplification of the full Student-t conjugate). The adaptive hazard is a heuristic estimate. It is classical sequential Bayesian inference — not deep Bayesian methods or machine learning — but the core BOCPD recursion is faithful to the original paper. Changepoint probability indicates the "possibility" of a reversal, not a certain prediction. Estimates become unstable in extreme volatility or with little initial data. Compute scales with the run-length limit; lower Max Run Length Tracked if it's heavy.

🚨 Disclaimer

This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. No signal guarantees future profit, and past performance does not indicate future results. All trading decisions are made at your own risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © AetherEdge — Bayesian Changepoint Shift
//@version=6

// ┌──────────────────────────────────────────────────────────────────────────┐
// │  AetherEdge - Bayesian Changepoint Shift  ·  AE-SHIFT                       │
// │                                                                            │
// │  Detects trend reversals as a PROBABILITY using Bayesian Online            │
// │  Changepoint Detection (BOCPD, Adams & MacKay 2007). Instead of asking     │
// │  "did a moving average cross?", it asks "what is the probability that the  │
// │  current price regime just ended?" — and answers with a full posterior     │
// │  distribution over how long the current run has lasted.                    │
// │                                                                            │
// │  HOW IT WORKS                                                              │
// │  • At each bar it maintains P(run-length = r | data) for r = 0..Rmax —     │
// │    "how many bars has the current regime persisted?"                       │
// │  • Each candidate run-length carries online sufficient statistics (Welford │
// │    mean/variance) of the returns inside that hypothesized segment.         │
// │  • A Gaussian predictive likelihood scores how well the new return fits    │
// │    each segment; a hazard function sets the prior probability of a reset.  │
// │  • The posterior is propagated forward (grow) and collapsed to r=0         │
// │    (changepoint). P(r=0) is the live changepoint probability.              │
// │                                                                            │
// │  ADAPTIVE HAZARD (the learning layer): the expected run length λ (which    │
// │  sets the hazard 1/λ) is re-estimated online from the spacing between      │
// │  detected changepoints — the model learns how often THIS instrument flips. │
// │                                                                            │
// │  SIGNAL: when changepoint probability peaks above a threshold, the         │
// │  direction of the fresh segment (short-horizon momentum) gives BUY/SELL.   │
// │                                                                            │
// │  HONEST SCOPE: this is a truncated approximation of BOCPD with a Gaussian  │
// │  predictive (not the full Student-t conjugate), and the adaptive hazard is │
// │  a heuristic. It is classical sequential Bayesian inference — not a deep   │
// │  net. The math core, however, is the genuine BOCPD recursion.             │
// └──────────────────────────────────────────────────────────────────────────┘

indicator("AetherEdge - Bayesian Changepoint Shift", "AE-SHIFT", overlay = true,
     max_labels_count = 300, max_lines_count = 500)


// ============================================================================
//  ░░ INPUTS — Bayesian model ░░
// ============================================================================
gB = "▓ BAYESIAN MODEL ▓"
bo_srcInp     = input.source(close, "Source", group = gB)
bo_lambdaInp  = input.float(50.0, "Expected Run Length (λ)", minval = 5.0, maxval = 500.0, step = 1.0, group = gB,
     tooltip = "Base hazard = 1/λ. Larger λ = changepoints are rarer (longer expected regimes). This is the prior; adaptive learning refines it.")
bo_adaptInp   = input.bool(true, "Adaptive Hazard Learning", group = gB,
     tooltip = "Re-estimate λ online from the spacing between detected changepoints — learns how often this instrument flips.")
bo_rmaxInp    = input.int(60, "Max Run Length Tracked", minval = 10, maxval = 150, group = gB,
     tooltip = "Truncation of the run-length posterior. Higher = more memory of long regimes but heavier compute (O(Rmax) per bar).")
bo_priorVarInp= input.float(1.0, "Prior Variance", minval = 0.1, maxval = 5.0, step = 0.1, group = gB,
     tooltip = "Variance assumed for a brand-new segment before data accumulates (in ATR-normalized return units).")
bo_obsVarInp  = input.float(0.5, "Observation Noise Variance", minval = 0.05, maxval = 3.0, step = 0.05, group = gB,
     tooltip = "Extra variance added to the predictive distribution (measurement noise).")
bo_minVarInp  = input.float(0.05, "Min Variance Floor", minval = 0.01, maxval = 1.0, step = 0.01, group = gB)

gS = "▓ SIGNAL ▓"
sig_thrInp    = input.float(0.25, "Changepoint Probability Threshold", minval = 0.05, maxval = 0.9, step = 0.05, group = gS,
     tooltip = "Min P(changepoint) to fire a signal. Lower = more sensitive, more signals.")
sig_momInp    = input.int(3, "Direction Confirmation (bars)", minval = 1, maxval = 20, group = gS,
     tooltip = "Lookback for the momentum that decides BUY vs SELL of the fresh segment.")

gVI = "▓ VISUALS ▓"
vi_themeInput = input.string("Neural Cyan", "Palette",
     options = ["Neural Cyan", "Emerald / Ruby", "Plasma Flow"], group = gVI)
vi_showGlow   = input.bool(true, "Changepoint Glow Lines", group = gVI)
vi_showMarks  = input.bool(true, "BUY/SELL Markers", group = gVI)
vi_showProb   = input.bool(true, "Changepoint Probability Plot", group = gVI,
     tooltip = "Plots P(changepoint) as a faint sub-band scaled onto price (right axis).")
vi_bgPulse    = input.bool(true, "Background Pulse by Probability", group = gVI)
vi_showTrend  = input.bool(true, "Segment Trend Line", group = gVI)

gH = "▓ HUD ▓"
hud_showInp   = input.bool(true, "Show HUD", group = gH)
hud_posInp    = input.string("Top Right", "Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gH)


// ============================================================================
//  ░░ PALETTE ░░
// ============================================================================
var color cBuy   = na
var color cSell  = na
var color cMid   = na
var color cAcc   = na
var color cHeat1 = na   // low probability
var color cHeat2 = na   // mid
var color cHeat3 = na   // high (hot)
var color cTxt   = #eef2f0
var color cTxtD  = #6b7d76
var color cPanel = #080b0a
var color cPanelHd = #0f1614

setPalette() =>
    [b, s, m, a, h1, h2, h3] = switch vi_themeInput
        "Emerald / Ruby" => [#10e0a0, #ff3860, #5f7186, #d4af37, #1b4d3e, #d9a441, #ff3860]
        "Plasma Flow"    => [#f0f921, #6a00f4, #5f7186, #fb9e3a, #0d0887, #cc4778, #f0f921]
        => [#22d3ee, #fb7185, #5f7186, #67e8f9, #0e3a4d, #d4af37, #fb7185]   // Neural Cyan
    [b, s, m, a, h1, h2, h3]
[pb, ps, pm, pa, ph1, ph2, ph3] = setPalette()
cBuy   := pb
cSell  := ps
cMid   := pm
cAcc   := pa
cHeat1 := ph1
cHeat2 := ph2
cHeat3 := ph3


// ============================================================================
//  ░░ HELPERS ░░
// ============================================================================
sdiv(a, b) =>
    b != 0 ? a / b : 0.0
clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))


// ============================================================================
//  ░░ OBSERVATION ░░
//  ATR-normalized return keeps the model scale-stable across instruments.
// ============================================================================
atr = ta.atr(14)
ret = bo_srcInp - bo_srcInp[1]
x = sdiv(ret, atr)


// ============================================================================
//  ░░ STATE — run-length posterior + per-run sufficient statistics ░░
// ============================================================================
Rmax = bo_rmaxInp
var float[] rlProb   = array.new<float>(Rmax + 1, 0.0)
var float[] segCount = array.new<float>(Rmax + 1, 0.0)
var float[] segMean  = array.new<float>(Rmax + 1, 0.0)
var float[] segM2    = array.new<float>(Rmax + 1, 0.0)

// Adaptive hazard state.
var float adaptLambda = bo_lambdaInp
var int   lastCpBar   = 0
var float[] cpIntervals = array.new<float>(0)

// Segment anchor for the trend line.
var float segAnchorPrice = na
var int   segAnchorTime   = na

if barstate.isfirst
    array.set(rlProb, 0, 1.0)
    segAnchorPrice := bo_srcInp
    segAnchorTime := time


// ============================================================================
//  ░░ BOCPD RECURSION (confirmed bars only — no repaint) ░░
// ============================================================================
hazard = bo_adaptInp ? 1.0 / math.max(adaptLambda, 2.0) : 1.0 / math.max(bo_lambdaInp, 2.0)

if barstate.isconfirmed and not na(x) and bar_index > 1
    // Fresh distribution buffers (rebuilt each bar from the prior).
    newProb  = array.new<float>(Rmax + 1, 0.0)
    newCount = array.new<float>(Rmax + 1, 0.0)
    newMean  = array.new<float>(Rmax + 1, 0.0)
    newM2    = array.new<float>(Rmax + 1, 0.0)

    cpMass = 0.0
    // Propagate each run-length hypothesis forward.
    for r = 0 to Rmax
        p = array.get(rlProb, r)
        if p > 1e-12
            cnt = array.get(segCount, r)
            mu  = array.get(segMean, r)
            m2  = array.get(segM2, r)
            variance = cnt > 1.0 ? m2 / (cnt - 1.0) : bo_priorVarInp
            variance := math.max(variance, bo_minVarInp)
            predVar = variance + bo_obsVarInp
            // Gaussian predictive likelihood of the new observation.
            pred = predVar > 0.0 ? math.exp(-0.5 * (x - mu) * (x - mu) / predVar) / math.sqrt(2.0 * math.pi * predVar) : 0.0

            // Growth: regime persists, run-length r -> r+1.
            if r < Rmax
                grow = p * pred * (1.0 - hazard)
                array.set(newProb, r + 1, array.get(newProb, r + 1) + grow)
                // Welford update: add x to segment (cnt, mu, m2).
                nc = cnt + 1.0
                delta = x - mu
                nm = mu + delta / nc
                delta2 = x - nm
                nm2 = m2 + delta * delta2
                array.set(newCount, r + 1, nc)
                array.set(newMean, r + 1, nm)
                array.set(newM2, r + 1, nm2)

            // Changepoint mass: regime resets, contributes to r=0.
            cpMass += p * pred * hazard

    // Collapse changepoint mass into r=0 with a fresh single-observation segment.
    array.set(newProb, 0, cpMass)
    array.set(newCount, 0, 1.0)
    array.set(newMean, 0, x)
    array.set(newM2, 0, 0.0)

    // Normalize the posterior.
    total = 0.0
    for r = 0 to Rmax
        total += array.get(newProb, r)
    if total > 1e-12
        for r = 0 to Rmax
            array.set(rlProb,   r, array.get(newProb, r) / total)
            array.set(segCount, r, array.get(newCount, r))
            array.set(segMean,  r, array.get(newMean, r))
            array.set(segM2,    r, array.get(newM2, r))


// ============================================================================
//  ░░ POSTERIOR SUMMARIES (for display + signal) ░░
// ============================================================================
cpProb = array.get(rlProb, 0)

expRL = 0.0
mlRL = 0
mlProb = 0.0
for r = 0 to Rmax
    pr = array.get(rlProb, r)
    expRL += r * pr
    if pr > mlProb
        mlProb := pr
        mlRL := r

// Bucketed distribution for the HUD mini-heatmap.
pNow = array.get(rlProb, 0)
pShort = 0.0
pMid = 0.0
pLong = 0.0
for r = 1 to Rmax
    pr = array.get(rlProb, r)
    if r <= 5
        pShort += pr
    else if r <= 20
        pMid += pr
    else
        pLong += pr


// ============================================================================
//  ░░ SIGNAL ░░
// ============================================================================
mom = bo_srcInp - bo_srcInp[sig_momInp]
dir = mom > 0 ? 1 : mom < 0 ? -1 : 0

cpDetected = cpProb >= sig_thrInp
cpPeak = cpDetected and cpProb >= cpProb[1]   // probability rising to a local peak

var int lastSig = 0
fireBuy  = cpPeak and dir > 0 and lastSig != 1
fireSell = cpPeak and dir < 0 and lastSig != -1
if barstate.isconfirmed
    if fireBuy
        lastSig := 1
    if fireSell
        lastSig := -1
    if cpProb < sig_thrInp * 0.5
        lastSig := 0


// ============================================================================
//  ░░ ADAPTIVE HAZARD UPDATE + SEGMENT ANCHOR ░░
// ============================================================================
if barstate.isconfirmed and (fireBuy or fireSell)
    interval = bar_index - lastCpBar
    lastCpBar := bar_index
    // Re-anchor the trend line at the new segment.
    segAnchorPrice := bo_srcInp
    segAnchorTime := time
    if bo_adaptInp and interval > 1 and interval < 2000
        array.push(cpIntervals, interval)
        if array.size(cpIntervals) > 20
            array.shift(cpIntervals)
        if array.size(cpIntervals) > 0
            sumI = 0.0
            for i = 0 to array.size(cpIntervals) - 1
                sumI += array.get(cpIntervals, i)
            adaptLambda := sumI / array.size(cpIntervals)


// ============================================================================
//  ░░ VISUALS — glow lines + markers ░░
// ============================================================================
// Changepoint glow: stacked semi-transparent vertical lines for a soft glow.
if vi_showGlow and barstate.isconfirmed and (fireBuy or fireSell)
    gcol = fireBuy ? cBuy : cSell
    yTop = high + atr * 4.0
    yBot = low - atr * 4.0
    line.new(bar_index, yBot, bar_index, yTop, color = color.new(gcol, 75), width = 5)
    line.new(bar_index, yBot, bar_index, yTop, color = color.new(gcol, 55), width = 3)
    line.new(bar_index, yBot, bar_index, yTop, color = color.new(gcol, 30), width = 1)

// BUY/SELL markers.
plotshape(vi_showMarks and fireBuy  and barstate.isconfirmed, title = "BUY",  style = shape.labelup,   location = location.belowbar, color = cBuy,  textcolor = #04140f, text = "SHIFT▲", size = size.small)
plotshape(vi_showMarks and fireSell and barstate.isconfirmed, title = "SELL", style = shape.labeldown, location = location.abovebar, color = cSell, textcolor = #1a0509, text = "SHIFT▼", size = size.small)

// Changepoint probability as a price-scaled sub-band (sits near the low).
probScaled = vi_showProb ? low - atr * 2.0 - cpProb * atr * 3.0 : na
probCol = cpProb >= 0.5 ? cHeat3 : cpProb >= 0.25 ? cHeat2 : cHeat1
plotProbTop = plot(vi_showProb ? low - atr * 2.0 : na, "ProbTop", color = na, editable = false)
plotProbVal = plot(probScaled, "P(changepoint)", color = color.new(probCol, 20), linewidth = 1)
fill(plotProbTop, plotProbVal, color = vi_showProb ? color.new(probCol, 80) : na, title = "Prob Fill")

// Segment trend line: anchor to last changepoint, follow with current price.
var line segLine = na
if vi_showTrend and barstate.isconfirmed and not na(segAnchorTime)
    if not na(segLine)
        line.delete(segLine)
    tcol = dir > 0 ? cBuy : dir < 0 ? cSell : cMid
    segLine := line.new(segAnchorTime, segAnchorPrice, time, bo_srcInp, xloc = xloc.bar_time, color = color.new(tcol, 30), width = 2, style = line.style_solid)

// Background pulse by changepoint probability.
bgPulse = vi_bgPulse and cpProb > 0.05 ? color.new(dir > 0 ? cBuy : dir < 0 ? cSell : cMid, 100 - int(clamp(cpProb * 55.0, 0.0, 45.0))) : na
bgcolor(bgPulse, editable = false)


// ============================================================================
//  ░░ HUD ░░
// ============================================================================
hudPos(p) =>
    switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right

bar10(p) =>
    int filled = math.round(clamp(p, 0.0, 1.0) * 10)
    string s = ""
    for i = 1 to 10
        s += i <= filled ? "█" : "░"
    s

heatCell(p) =>
    // returns a color from cHeat1..cHeat3 based on probability mass
    p >= 0.5 ? cHeat3 : p >= 0.2 ? cHeat2 : cHeat1

var table hud = na
if hud_showInp and na(hud)
    hud := table.new(hudPos(hud_posInp), 2, 11, bgcolor = cPanel,
         border_color = color.new(cAcc, 60), border_width = 1, frame_color = color.new(cAcc, 40), frame_width = 1)

if hud_showInp and barstate.islast
    sz = size.normal
    regimeDir = dir > 0 ? "▲ rising" : dir < 0 ? "▼ falling" : "· flat"
    regimeCol = dir > 0 ? cBuy : dir < 0 ? cSell : cMid
    barsSince = bar_index - lastCpBar

    table.cell(hud, 0, 0, "BAYESIAN SHIFT", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 0, "BOCPD", text_color = cTxtD, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_right)

    cpCol = cpProb >= 0.5 ? cSell : cpProb >= sig_thrInp ? cAcc : cTxt
    table.cell(hud, 0, 1, "P(changepoint)", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 1, bar10(cpProb) + " " + str.tostring(math.round(cpProb * 100)) + "%", text_color = cpCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 2, "expected run len", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 2, str.tostring(expRL, "#.0") + " bars", text_color = cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 3, "most likely run", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 3, str.tostring(mlRL) + " (" + str.tostring(math.round(mlProb * 100)) + "%)", text_color = cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 4, "▔ RUN-LENGTH DIST ▔", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 4, "", bgcolor = cPanelHd)

    table.cell(hud, 0, 5, "r = 0 (reset)", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 5, bar10(pNow) + " " + str.tostring(math.round(pNow * 100)) + "%", text_color = heatCell(pNow), text_size = sz, text_halign = text.align_right)
    table.cell(hud, 0, 6, "r = 1-5", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 6, bar10(pShort) + " " + str.tostring(math.round(pShort * 100)) + "%", text_color = heatCell(pShort), text_size = sz, text_halign = text.align_right)
    table.cell(hud, 0, 7, "r = 6-20", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 7, bar10(pMid) + " " + str.tostring(math.round(pMid * 100)) + "%", text_color = heatCell(pMid), text_size = sz, text_halign = text.align_right)
    table.cell(hud, 0, 8, "r = 21+", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 8, bar10(pLong) + " " + str.tostring(math.round(pLong * 100)) + "%", text_color = heatCell(pLong), text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 9, "regime", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 9, regimeDir + "  " + str.tostring(barsSince) + "b", text_color = regimeCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 10, bo_adaptInp ? "adaptive λ" : "fixed λ", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 10, str.tostring(bo_adaptInp ? adaptLambda : bo_lambdaInp, "#.0"), text_color = cAcc, text_size = sz, text_halign = text.align_right)


// ============================================================================
//  ░░ ALERTS ░░
// ============================================================================
alertcondition(fireBuy,  "Bullish Changepoint",  "AE-SHIFT: bullish changepoint detected")
alertcondition(fireSell, "Bearish Changepoint",  "AE-SHIFT: bearish changepoint detected")
alertcondition(cpProb >= 0.5 and cpProb[1] < 0.5, "High Changepoint Probability", "AE-SHIFT: changepoint probability exceeded 50%")
````
