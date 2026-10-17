# AetherEdge - Generative Flow Synthesizer

- url: https://www.tradingview.com/script/vb4Mne7r/
- type: indicator
- pine_id: PUB;8e15aba2663a40a283797174f819a94e
- version: 1.0

## Description

🖊️ Overview

The Generative Flow Synthesizer is a path-synthesis engine inspired by the principles of a Variational Autoencoder (VAE), learning the market's "generative distribution." It compresses past price action into a low-dimensional latent distribution, samples latent variables via the reparameterization trick, and synthesizes multiple future price paths from them. Unlike conventional tools that draw a single forecast line, it renders the very spread of plausible futures as a stream of generated samples flowing forward like particles.

🔶 Key Features

VAE-inspired generative model: encode (latent compression) → sample (reparameterization) → decode (path expansion)
Reparameterization trick: latent sampling via z = μ + σ·ε (identical math to a real VAE)
Central predicted flow: a deterministic mean path generated from the latent mean
Multiple generated sample paths: stochastic draws from the latent distribution stream forward like particles
Generative confidence band: a ±σ uncertainty envelope widening each step
Online-learned latent distribution: drift, volatility, and autocorrelation adapt via EWMA
Sampling temperature: control future spread from conservative to bold
Mean-reversion strength: tune from pure random walk to convergent paths
Generative/fluid palettes (Plasma Flow et al.) with particle fade toward the horizon

🧠 Technical Architecture

This tool is a translation that realizes the VAE's mathematical core within Pine, which lacks autodiff. The encoder extracts sufficient statistics from log returns — drift (mean), volatility (standard deviation), and autocorrelation (persistence) — and online-learns the latent distribution parameters (μ, logσ²) via EWMA, a Pine realization of the posterior an encoder network would learn.
The sampling stage is identical to a real VAE, drawing latent variables through the reparameterization trick z = μ + σ·ε (ε a standard normal via Box–Muller). The decoder expands each latent sample into a forward price path through a mean-reverting stochastic process r_t = z + φ·(r_{t-1} − z) + σ·temp·ε_t. Because each path uses its own random sequence, they diversify like particles. The central predicted flow is the deterministic mean path with the noise term removed; the confidence band is the ±σ envelope built from accumulated step variance.

⚙️ Recommended Settings & Tuning Guide

Tuned with crypto in mind. On BTC and ETH, Encoder Window 60 and Generation Horizon ~24 are a starting point. Sampling Temperature is the generative core — below 1 yields narrow, conservative futures; above 1, wide, bold exploration. In trends, lower Mean-Reversion Strength for freer paths; in ranges, raise it for convergent paths, matching the possibility distribution to market character. Number of Sample Paths trades visual richness against compute; ~12 is a good balance.

💡 How to Use in Practice

The central predicted flow serves as the model's most average future trajectory for reading trend bias. The spread of the sample paths (particle scatter) expresses uncertainty itself — tight scatter signals clear direction, wide scatter a hard-to-predict regime. The confidence band width offers an objective reference for stop placement and target setting. For multi-timeframe trading, pair a higher-timeframe generative flow with a lower timeframe for timing.

⚠️ Important Notes

This tool is VAE-inspired, not a true backprop-trained neural-network VAE; within Pine's constraints it reproduces the VAE's core principles in a feasible form. Generated paths are samples from a learned distribution, not predictions of the future — purely a visualization of the spread of possibilities. Generation occurs only on the last bar and does not repaint confirmed history. Learning the latent distribution requires accumulated data and cannot overcome the fundamental constraint of market predictability.

🚨 Disclaimer

This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. No generated path guarantees future prices, and past performance does not indicate future results. All trading decisions are made at your own risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © AetherEdge — Generative Flow Synthesizer // VAE-inspired Path Generation
//@version=6

// ┌──────────────────────────────────────────────────────────────────────────┐
// │  GENERATIVE FLOW SYNTHESIZER [AetherEdge]                                  │
// │                                                                            │
// │  A VARIATIONAL-AUTOENCODER-INSPIRED generative model of market motion.     │
// │                                                                            │
// │  HONEST SCOPE: Pine has no autodiff, so a true backprop-trained VAE is     │
// │  impossible — and no external library (incl. "NeuraLib") can be imported.  │
// │  Instead this faithfully reproduces the VAE's MATHEMATICAL CORE in a       │
// │  Pine-feasible form:                                                       │
// │    1. ENCODE  — compress recent price dynamics into a low-dim latent       │
// │                 description (online-learned mean μ and variance σ²).       │
// │    2. SAMPLE  — draw latent variables via the REPARAMETERIZATION TRICK     │
// │                 z = μ + σ·ε,  ε ~ N(0,1)  (identical to a real VAE).       │
// │    3. DECODE  — expand each sampled latent into a full forward price path  │
// │                 using the learned drift/vol/mean-reversion dynamics.       │
// │                                                                            │
// │  RENDER: a central PREDICTED FLOW (the generative mean path) plus several  │
// │  faint GENERATED SAMPLE PATHS that stream forward like particles, drawing  │
// │  the cone of plausible futures the model has learned.                      │
// └──────────────────────────────────────────────────────────────────────────┘

indicator("AetherEdge - Generative Flow Synthesizer", "AE-GFS", overlay = true,
     max_lines_count = 500, max_labels_count = 100)


// ============================================================================
//  ░░ INPUTS ░░
// ============================================================================

// ─── GENERATIVE MODEL ────────────────────────────────────────────────────────
gG = "▓ GENERATIVE MODEL ▓"
gm_encWinInput = input.int(60, "Encoder Window", minval = 20, maxval = 300, group = gG,
     tooltip = "How much recent price history the encoder compresses into the latent description. Larger = smoother, slower-adapting distribution.")
gm_horizonInp  = input.int(24, "Generation Horizon (bars)", minval = 4, maxval = 100, group = gG,
     tooltip = "How many bars forward each generated price path extends.")
gm_learnInput  = input.float(0.05, "Latent Learning Rate", minval = 0.005, maxval = 0.5, step = 0.005, group = gG,
     tooltip = "How fast the latent distribution (μ, σ) adapts to new market dynamics.")
gm_revertInput = input.float(0.10, "Mean-Reversion Strength", minval = 0.0, maxval = 1.0, step = 0.02, group = gG,
     tooltip = "Pull of generated paths back toward the drift. 0 = pure random walk, higher = tighter, more reverting paths.")
gm_tempInput   = input.float(1.0, "Sampling Temperature", minval = 0.1, maxval = 3.0, step = 0.1, group = gG,
     tooltip = "Scales latent noise σ during sampling. <1 = conservative/narrow futures, >1 = wild/wide exploration.")

// ─── SAMPLE PATHS ────────────────────────────────────────────────────────────
gS = "▓ SAMPLE PATHS ▓"
sp_countInput  = input.int(12, "Number of Sample Paths", minval = 1, maxval = 30, group = gS,
     tooltip = "How many stochastic generated paths to stream forward. More = richer particle flow but heavier.")
sp_stepInput   = input.int(1, "Path Point Spacing (bars)", minval = 1, maxval = 5, group = gS,
     tooltip = "Draw a path segment every N bars. Higher = lighter rendering.")
sp_showMeanInp = input.bool(true, "Show Central Predicted Flow", group = gS)
sp_showBandInp = input.bool(true, "Show Generative Confidence Band", group = gS,
     tooltip = "Shade the ±σ envelope of the generated distribution at each future step.")

// ─── VISUALS ─────────────────────────────────────────────────────────────────
gV = "▓ VISUALS ▓"
vi_themeInput  = input.string("Plasma Flow", "Palette",
     options = ["Plasma Flow", "Aurora Stream", "Emerald / Ruby"], group = gV,
     tooltip = "Generative/fluid aesthetics. Plasma Flow = violet→cyan particle stream.")
vi_glowInput   = input.bool(true, "Glow on Central Flow", group = gV)
vi_fadeInput   = input.bool(true, "Fade Sample Paths Toward Horizon", group = gV,
     tooltip = "Sample lines grow more transparent further into the future, like dissipating particles.")

// ─── HUD ─────────────────────────────────────────────────────────────────────
gH = "▓ HUD ▓"
hud_showInput  = input.bool(true, "Show HUD", group = gH)
hud_posInput   = input.string("Top Right", "Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gH)
hud_sizeInput  = input.string("Normal", "Text Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = gH)


// ============================================================================
//  ░░ PALETTE ░░
//  Each = [flowUp, flowDn, particle, accent]
// ============================================================================
var color cUp   = na
var color cDn   = na
var color cPart = na
var color cAcc  = na
var color cTxt  = #dfe7f2
var color cTxtD = #5f7186
var color cPanel= #0a0c12
var color cPanelHd = #131826

setPalette() =>
    [u, d, p, a] = switch vi_themeInput
        "Plasma Flow"   => [#22d3ee, #f472b6, #a78bfa, #e879f9]
        "Aurora Stream" => [#34d399, #38bdf8, #818cf8, #2dd4bf]
        => [#10e0a0, #ff3860, #9b8cff, #d4af37]   // Emerald / Ruby
    [u, d, p, a]
[pu, pd, pp, pa] = setPalette()
cUp   := pu
cDn   := pd
cPart := pp
cAcc  := pa


// ============================================================================
//  ░░ HELPERS ░░
// ============================================================================
sdiv(a, b) =>
    b != 0 ? a / b : 0.0
clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))

// Deterministic pseudo-random uniform in [0,1) from a salt (bar-stable per salt).
prng(salt) =>
    x = math.sin(salt * 12.9898 + 78.233) * 43758.5453
    x - math.floor(x)

// Standard normal via Box–Muller from a salt (two derived uniforms).
randn(salt) =>
    u1 = math.max(1e-9, prng(salt))
    u2 = prng(salt + 7.17)
    math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2)


// ============================================================================
//  ░░ ENCODER — compress recent dynamics into a latent description ░░
//  The "encoder" distills the price series into the sufficient statistics a
//  generative model needs: drift (mean log-return), volatility (σ of returns),
//  and an autocorrelation proxy (momentum persistence). These parameterize the
//  latent distribution that we will sample from and decode.
// ============================================================================
logRet = math.log(close) - math.log(close[1])

encDrift = ta.sma(logRet, gm_encWinInput)                 // latent mean (drift)
encVol   = ta.stdev(logRet, gm_encWinInput)               // latent scale (vol)
// Autocorrelation proxy: correlation of returns with their own lag.
encAuto  = ta.correlation(logRet, logRet[1], gm_encWinInput)
encAuto  := na(encAuto) ? 0.0 : clamp(encAuto, -0.95, 0.95)

// Online-learned latent parameters (μ, logσ²) adapt smoothly via EWMA — the
// Pine-feasible stand-in for the encoder network's learned posterior.
var float zMu     = 0.0
var float zLogVar = -6.0
if not na(encDrift) and not na(encVol)
    zMu     := zMu + gm_learnInput * (encDrift - zMu)
    targetLV = math.log(math.max(encVol * encVol, 1e-10))
    zLogVar := zLogVar + gm_learnInput * (targetLV - zLogVar)

zSigma = math.sqrt(math.exp(zLogVar))


// ============================================================================
//  ░░ DECODER — expand a sampled latent into a forward price path ░░
//  Given a latent draw z (a drift sample) and the learned vol/autocorrelation,
//  generate a path via a mean-reverting stochastic step:
//     r_t = z + φ·(r_{t-1} − z) + σ·temp·ε_t
//     price_t = price_{t-1} · exp(r_t)
//  Mean-reversion strength pulls steps back toward the latent drift z.
//  Each path uses its own RNG salt so paths differ like particles.
// ============================================================================
basePx = close
phi    = encAuto * (1.0 - gm_revertInput)   // effective persistence after reversion pull


// ============================================================================
//  ░░ GENERATION — redraw all paths each bar on the last bar only ░░
//  We keep arrays of line objects so we can delete & redraw each update.
// ============================================================================
var line[] meanLines = array.new<line>(0)
var line[] bandUpLn  = array.new<line>(0)
var line[] bandDnLn  = array.new<line>(0)
var line[] sampleLns = array.new<line>(0)

// Clear previously drawn lines.
clearLines(arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            line.delete(array.get(arr, i))
        array.clear(arr)

H = gm_horizonInp
step = sp_stepInput

if barstate.islast
    clearLines(meanLines)
    clearLines(bandUpLn)
    clearLines(bandDnLn)
    clearLines(sampleLns)

    // ── Central predicted flow: the deterministic mean path (z = μ, no noise) ──
    // Also accumulate per-step distribution σ for the confidence band.
    var float[] meanPath = array.new<float>(0)
    array.clear(meanPath)
    pxM = basePx
    rPrev = zMu
    array.push(meanPath, pxM)
    for t = 1 to H
        r = zMu + phi * (rPrev - zMu)         // mean dynamics, no stochastic term
        pxM := pxM * math.exp(r)
        rPrev := r
        array.push(meanPath, pxM)

    // Draw the central flow as connected segments with glow.
    if sp_showMeanInp
        meanColUp = cUp
        for t = 0 to H - step
            if t % step == 0
                x1 = bar_index + t
                x2 = bar_index + math.min(t + step, H)
                y1 = array.get(meanPath, t)
                y2 = array.get(meanPath, math.min(t + step, H))
                segCol = y2 >= y1 ? cUp : cDn
                if vi_glowInput
                    array.push(meanLines, line.new(x1, y1, x2, y2, color = color.new(segCol, 70), width = 4))
                array.push(meanLines, line.new(x1, y1, x2, y2, color = segCol, width = 2))

    // ── Confidence band: ±σ envelope grown by the decoder's step variance ──
    // Variance accumulates ~ σ²·t (random-walk-like), tempered by reversion.
    if sp_showBandInp
        pxU = basePx
        pxD = basePx
        accVar = 0.0
        for t = 1 to H
            // Step variance shrinks with reversion; accumulate.
            stepVar = (zSigma * gm_tempInput) * (zSigma * gm_tempInput) * math.pow(math.max(0.0, 1.0 - gm_revertInput * 0.5), t - 1)
            accVar += stepVar
            sd = math.sqrt(accVar)
            mp = array.get(meanPath, t)
            up = mp * math.exp(1.0 * sd)
            dn = mp * math.exp(-1.0 * sd)
            if (t - 1) % step == 0
                x1 = bar_index + (t - 1)
                x2 = bar_index + t
                mpPrev = array.get(meanPath, t - 1)
                sdPrev = math.sqrt(math.max(accVar - stepVar, 0.0))
                upPrev = mpPrev * math.exp(sdPrev)
                dnPrev = mpPrev * math.exp(-sdPrev)
                array.push(bandUpLn, line.new(x1, upPrev, x2, up, color = color.new(cAcc, 82), width = 1, style = line.style_dotted))
                array.push(bandDnLn, line.new(x1, dnPrev, x2, dn, color = color.new(cAcc, 82), width = 1, style = line.style_dotted))

    // ── Stochastic sample paths: reparameterization trick z = μ + σ·ε ──
    // Each path draws its own latent and a fresh ε per step, streaming forward.
    for p = 0 to sp_countInput - 1
        // Latent draw for this path (reparameterization on the drift).
        epsLatent = randn(bar_index * 0.001 + p * 3.137)
        zP = zMu + zSigma * gm_tempInput * epsLatent
        pxS = basePx
        rP = zP
        for t = 1 to H
            // Fresh standard-normal innovation per step (the decoder's noise).
            eps = randn(bar_index * 0.0001 + p * 17.0 + t * 0.613)
            r = zP + phi * (rP - zP) + zSigma * gm_tempInput * eps
            pxNext = pxS * math.exp(r)
            rP := r
            if (t - 1) % step == 0
                x1 = bar_index + (t - 1)
                x2 = bar_index + t
                // Fade toward the horizon for a dissipating-particle look.
                baseTransp = 62
                fade = vi_fadeInput ? math.round(baseTransp + (t / H) * 30) : baseTransp
                array.push(sampleLns, line.new(x1, pxS, x2, pxNext, color = color.new(cPart, math.min(95, fade)), width = 1))
            pxS := pxNext

    // Terminal label on the central flow.
    if sp_showMeanInp and array.size(meanPath) > 0
        endPx = array.get(meanPath, H)
        endRet = (endPx / basePx - 1.0) * 100.0
        endCol = endPx >= basePx ? cUp : cDn
        label.new(bar_index + H, endPx, str.tostring(endPx, format.mintick) + "  " + str.tostring(endRet, "#.0") + "%",
             color = color.new(endCol, 20), textcolor = #ffffff, style = label.style_label_left, size = size.small)


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
hudSize(s) =>
    switch s
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

var table hud = na
if hud_showInput and na(hud)
    hud := table.new(hudPos(hud_posInput), 2, 8, bgcolor = cPanel,
         border_color = color.new(cAcc, 65), border_width = 1, frame_color = color.new(cAcc, 45), frame_width = 1)

if hud_showInput and barstate.islast
    sz = hudSize(hud_sizeInput)
    driftBias = zMu > 0 ? "▲ UPWARD" : zMu < 0 ? "▼ DOWNWARD" : "· FLAT"
    driftCol  = zMu > 0 ? cUp : zMu < 0 ? cDn : cTxtD
    // Annualized-ish drift per horizon for readability.
    horizonDrift = (math.exp(zMu * H) - 1.0) * 100.0

    table.cell(hud, 0, 0, "GENERATIVE FLOW", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 0, "VAE-inspired", text_color = cTxtD, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_right)

    table.cell(hud, 0, 1, "latent drift μ", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 1, driftBias, text_color = driftCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 2, "horizon move", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 2, str.tostring(horizonDrift, "#.00") + "%", text_color = driftCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 3, "latent σ", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 3, str.tostring(zSigma * 100, "#.000") + "%", text_color = cAcc, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 4, "persistence φ", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 4, str.tostring(phi, "#.00"), text_color = cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 5, "temperature", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 5, str.tostring(gm_tempInput, "#.0"), text_color = cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 6, "sample paths", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 6, str.tostring(sp_countInput), text_color = cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 7, "horizon", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 7, str.tostring(H) + " bars", text_color = cTxt, text_size = sz, text_halign = text.align_right)
````
