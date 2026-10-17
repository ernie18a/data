# AetherEdge - Wavelet Multi-Resolution

- url: https://www.tradingview.com/script/tpwjfK1P/
- type: indicator
- pine_id: PUB;889309213931472fb32ff1ae638eb1ba
- version: 1.0

## Description

🖊️ Overview

AE-WAVE decomposes price into multiple frequency scales using the à trous ("with holes") wavelet transform and reconstructs a clean "true price" by removing high-frequency noise. The scales are drawn as stacked translucent ribbons — a "frequency strata" of the market — revealing its hierarchical structure from raw chatter (top layer) to macro trend (bottom). Thanks to perfect reconstruction, denoise strength 0 means zero lag; higher values mean smoother. An adaptive layer learns each band's predictive power online.

🔶 Key Features

à trous wavelet decomposition: causal decomposition into 5 frequency scales
Soft-threshold denoising: removes high-frequency noise while preserving structure
Perfect reconstruction: denoise 0 = raw price (zero lag), strength tunes smoothness
3 scaling filters: B3 Spline (smoothest) / Linear / Haar (sharpest)
Adaptive scale reliability: learns online which bands predict
Frequency strata rendering: high freq thin/light, low freq thick/deep stacked ribbons
High-frequency bias: extra denoising on noise-heavy high-freq bands
BUY/SELL on denoised slope flip + macro trend filter
HUD showing band energy, reliability, dominant band
Per-event alerts

🧠 Technical Architecture

This implements the à trous (starlet) wavelet transform. From c0 = price, each scale c_{j+1} smooths c_j with a scaling filter (B3 spline [1,4,6,4,1]/16, etc.), spacing the filter taps by 2^j bars (causal, past only). Detail w_j = c_{j-1} − c_j is the band component. The telescoping identity c0 = c_J + Σ w_j means reconstruction equals raw price exactly with no thresholding (zero lag). Each detail is soft-thresholded w' = sign(w)·max(|w|−λ,0) (λ = estimated noise σ × strength × high-freq bias), reconstructed as denoised = c_J + Σ(thresholded w_j). The adaptive layer scores each scale's detail sign against forward returns, learning reliability via EWMA. Confidence blends reliability, trend agreement, and low noise. Signals fire on denoised slope flip + macro trend direction, or on a macro trend cross.

⚙️ Recommended Settings & Tuning Guide

Wavelet Levels (J) 5 is a starting point — higher for a smoother macro trend. B3 Spline filter is smoothest and common; Haar for faster response in ranges; Linear in between. Denoise Strength 1.0 baseline; 0 gives raw price (no denoise), higher is smoother but adds lag. Noise Estimation Window 50 estimates noise σ. High-Freq Denoise Bias 1.5 adds denoising to high-freq bands; raise for noisy instruments. Signal Mode "slope + trend filter" is robust; "macro trend cross" gives clearer signals. Adaptive Scale Reliability ON is recommended.

💡 How to Use in Practice

Apply to chart and 5 frequency-strata ribbons appear with the denoised main line in directional color. The ribbon "thickness" shows each band's activity; the HUD's FREQUENCY BANDS shows each band's energy and learned reliability. A dominant "S5 macro" band means macro-trend-driven; "S1 chatter" means noise-dominant ranging — read the market's character. When high-reliability bands align with the trend, signal conviction rises. Divergence/convergence of denoised price from the macro trend line gauges trend strength. Higher denoise strength gives smooth swing signals; lower gives sensitive ones.

⚠️ Important Notes

This is a causal, undecimated wavelet (B3 spline / Linear / Haar), not a full Daubechies decimated DWT. The adaptive scale reliability is online EWMA, not deep learning. The transform math, however, is genuine à trous. Due to the scaling filter's group delay, the macro scale (c_J) represents a lagged macro trend. The denoised price has minimal lag thanks to perfect reconstruction, but higher denoise strength introduces smoothing lag. It uses past data only, so it does not repaint. All signals are probabilistic decisions based on historical data and do not guarantee future profits.

🚨 Disclaimer

This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. No signal guarantees future profit, and past performance does not indicate future results. All trading decisions are made at your own risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © AetherEdge — Wavelet Multi-Resolution
//@version=6

// ┌──────────────────────────────────────────────────────────────────────────┐
// │  AetherEdge - Wavelet Multi-Resolution  ·  AE-WAVE                          │
// │                                                                            │
// │  Decomposes price into multiple frequency scales using the à trous         │
// │  ("with holes" / starlet) wavelet transform, soft-thresholds the noisy     │
// │  high-frequency detail, and reconstructs a clean "true price". The scales  │
// │  are drawn as stacked translucent ribbons — a "frequency strata" view of   │
// │  the market, from raw chatter (top layer) down to the macro trend.         │
// │                                                                            │
// │  HOW IT WORKS                                                              │
// │  • à trous: c0 = price; each scale c_{j+1} is a B3-spline smoothing of c_j  │
// │    with the filter spaced by 2^j bars (causal — past data only).           │
// │  • Detail w_j = c_{j-1} − c_j is the energy in frequency band j.            │
// │  • Telescoping identity: c0 = c_J + Σ w_j  →  with NO thresholding the      │
// │    reconstruction equals the raw price exactly (zero lag). Thresholding     │
// │    the detail is what denoises.                                            │
// │  • Soft threshold: w' = sign(w)·max(|w|−λ, 0), λ scaled by each band's     │
// │    estimated noise σ. High-frequency chatter is removed; structure stays.  │
// │                                                                            │
// │  ADAPTIVE LAYER (the learning part): each scale's detail sign is scored    │
// │  online against the realized forward return — the indicator learns WHICH   │
// │  frequency bands actually predict this instrument, shown as reliability%.   │
// │                                                                            │
// │  SIGNAL: the denoised price turning (slope flip) in the direction of the   │
// │  macro approximation (c_J) prints BUY/SELL.                                 │
// │                                                                            │
// │  HONEST SCOPE: a causal, undecimated wavelet (B3-spline / Haar / linear),  │
// │  not a full Daubechies decimated DWT. The adaptive reliability is online   │
// │  EWMA, not deep learning. The transform math, however, is genuine à trous. │
// └──────────────────────────────────────────────────────────────────────────┘

indicator("AetherEdge - Wavelet Multi-Resolution", "AE-WAVE", overlay = true,
     max_bars_back = 200, max_labels_count = 100)


// ============================================================================
//  ░░ INPUTS — wavelet ░░
// ============================================================================
gW = "▓ WAVELET ▓"
wv_srcInp   = input.source(close, "Source", group = gW)
wv_levelsInp= input.int(5, "Wavelet Levels (J)", minval = 3, maxval = 5, group = gW,
     tooltip = "Depth of decomposition used for reconstruction. Higher = smoother macro approximation c_J. All 5 scales are always drawn as strata.")
wv_filterInp= input.string("B3 Spline", "Scaling Filter",
     options = ["B3 Spline", "Linear", "Haar"], group = gW,
     tooltip = "B3 Spline [1,4,6,4,1] = smoothest. Linear [1,2,1] = lighter. Haar [1,1] = sharpest, most responsive.")

gD = "▓ DENOISING ▓"
dn_strengthInp= input.float(1.0, "Denoise Strength", minval = 0.0, maxval = 4.0, step = 0.1, group = gD,
     tooltip = "Soft-threshold multiplier on detail noise σ. 0 = no denoise (reconstruction = raw price, zero lag). Higher = smoother denoised line.")
dn_noiseWinInp= input.int(50, "Noise Estimation Window", minval = 10, maxval = 300, group = gD,
     tooltip = "Bars used to estimate each band's noise level (σ).")
dn_hfBiasInp  = input.float(1.5, "High-Freq Denoise Bias", minval = 1.0, maxval = 3.0, step = 0.1, group = gD,
     tooltip = "Extra denoising applied to the highest-frequency bands (where noise concentrates). 1 = uniform.")

gS = "▓ SIGNAL ▓"
sig_modeInput = input.string("Denoised slope + trend filter", "Signal Mode",
     options = ["Denoised slope + trend filter", "Denoised crosses macro trend"], group = gS)

gAI = "▓ ADAPTIVE LEARNING ▓"
ai_enableInput= input.bool(true, "Adaptive Scale Reliability", group = gAI,
     tooltip = "Each scale's detail sign is scored online against realized forward returns — learns which frequency bands predict this instrument.")
ai_horizonInp = input.int(8, "Outcome Horizon (bars)", minval = 3, maxval = 50, group = gAI)
ai_rateInput  = input.float(0.1, "Learning Rate", minval = 0.01, maxval = 0.5, step = 0.01, group = gAI)

gVI = "▓ VISUALS ▓"
vi_themeInput = input.string("Aurora", "Palette",
     options = ["Aurora", "Spectral", "Ocean Depth"], group = gVI)
vi_strata     = input.bool(true, "Show Frequency Strata (ribbons)", group = gVI)
vi_denoised   = input.bool(true, "Show Denoised Line", group = gVI)
vi_trend      = input.bool(true, "Show Macro Trend Line (c_J)", group = gVI)
vi_marks      = input.bool(true, "BUY/SELL Markers", group = gVI)
vi_barColor   = input.bool(false, "Color Candles by Denoised Slope", group = gVI)

gH = "▓ HUD ▓"
hud_showInp   = input.bool(true, "Show HUD", group = gH)


// ============================================================================
//  ░░ PALETTE — 5 scale colors + buy/sell/trend/accent ░░
// ============================================================================
var color cS1 = na
var color cS2 = na
var color cS3 = na
var color cS4 = na
var color cS5 = na
var color cBuy = na
var color cSell = na
var color cTrend = na
var color cAcc = na
var color cTxt = #eef2f0
var color cTxtD = #6b7d76
var color cPanel = #080b0a
var color cPanelHd = #0f1614

setPalette() =>
    [s1, s2, s3, s4, s5, b, s, tr, a] = switch vi_themeInput
        "Spectral"    => [#f43f5e, #fb923c, #facc15, #4ade80, #22d3ee, #10e0a0, #ff3860, #a78bfa, #e879f9]
        "Ocean Depth" => [#7dd3fc, #38bdf8, #0ea5e9, #3b82f6, #1e3a8a, #34d399, #fb7185, #93c5fd, #67e8f9]
        => [#5eead4, #2dd4bf, #22d3ee, #818cf8, #7c3aed, #10e0a0, #ff3860, #c4b5fd, #d4af37]   // Aurora
    [s1, s2, s3, s4, s5, b, s, tr, a]
[psS1, psS2, psS3, psS4, psS5, psB, psS, psTr, psA] = setPalette()
cS1 := psS1
cS2 := psS2
cS3 := psS3
cS4 := psS4
cS5 := psS5
cBuy := psB
cSell := psS
cTrend := psTr
cAcc := psA


// ============================================================================
//  ░░ HELPERS ░░
// ============================================================================
sdiv(a, b) =>
    b != 0 ? a / b : 0.0
clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))
softThresh(w, lam) =>
    aw = math.abs(w)
    diff = aw - lam
    diff > 0.0 ? (w >= 0.0 ? diff : -diff) : 0.0


// ============================================================================
//  ░░ À TROUS DECOMPOSITION ░░
//  c_{j+1}(t) = Σ h(k)·c_j(t − k·2^j), causal (past only). Filter taps depend
//  on the chosen scaling filter. Telescoping: c0 = c_J + Σ (c_{j-1}−c_j).
// ============================================================================
c0 = wv_srcInp

// Filter application as a causal weighted sum at spacing s.
// B3 spline   : [1,4,6,4,1]/16  over taps {0,s,2s,3s,4s}
// Linear      : [1,2,1]/4       over taps {0,s,2s}
// Haar        : [1,1]/2         over taps {0,s}
atrousStep(series, s) =>
    out = switch wv_filterInp
        "Haar"   => (series + series[s]) / 2.0
        "Linear" => (series + 2.0 * series[s] + series[2 * s]) / 4.0
        => (series + 4.0 * series[s] + 6.0 * series[2 * s] + 4.0 * series[3 * s] + series[4 * s]) / 16.0
    out

c1 = atrousStep(c0, 1)
c2 = atrousStep(c1, 2)
c3 = atrousStep(c2, 4)
c4 = atrousStep(c3, 8)
c5 = atrousStep(c4, 16)

// Detail (wavelet) coefficients per band.
w1 = c0 - c1
w2 = c1 - c2
w3 = c2 - c3
w4 = c3 - c4
w5 = c4 - c5


// ============================================================================
//  ░░ NOISE ESTIMATION + SOFT THRESHOLDING ░░
//  Higher-frequency bands get extra denoising via the HF bias exponent.
// ============================================================================
sigma1 = ta.stdev(w1, dn_noiseWinInp)
sigma2 = ta.stdev(w2, dn_noiseWinInp)
sigma3 = ta.stdev(w3, dn_noiseWinInp)
sigma4 = ta.stdev(w4, dn_noiseWinInp)
sigma5 = ta.stdev(w5, dn_noiseWinInp)

// HF bias: band 1 gets the most extra denoising, decaying toward low frequency.
biasFor(bandIdx) =>
    // bandIdx 1..5; weight = hfBias^((5-bandIdx)/4) so band1=hfBias, band5=1
    math.pow(dn_hfBiasInp, (5.0 - bandIdx) / 4.0)

lam1 = dn_strengthInp * sigma1 * biasFor(1)
lam2 = dn_strengthInp * sigma2 * biasFor(2)
lam3 = dn_strengthInp * sigma3 * biasFor(3)
lam4 = dn_strengthInp * sigma4 * biasFor(4)
lam5 = dn_strengthInp * sigma5 * biasFor(5)

w1d = softThresh(w1, lam1)
w2d = softThresh(w2, lam2)
w3d = softThresh(w3, lam3)
w4d = softThresh(w4, lam4)
w5d = softThresh(w5, lam5)


// ============================================================================
//  ░░ RECONSTRUCTION ░░
//  Macro approximation = c_J (J = levels). Denoised = c_J + Σ_{1..J} w_jd.
// ============================================================================
J = wv_levelsInp
baseApprox = J >= 5 ? c5 : J == 4 ? c4 : c3
detailSum = w1d + w2d + w3d + (J >= 4 ? w4d : 0.0) + (J >= 5 ? w5d : 0.0)
denoised = baseApprox + detailSum

trendLine = baseApprox


// ============================================================================
//  ░░ SCALE ENERGY (band activity) ░░
// ============================================================================
e1 = ta.sma(math.abs(w1), dn_noiseWinInp)
e2 = ta.sma(math.abs(w2), dn_noiseWinInp)
e3 = ta.sma(math.abs(w3), dn_noiseWinInp)
e4 = ta.sma(math.abs(w4), dn_noiseWinInp)
e5 = ta.sma(math.abs(w5), dn_noiseWinInp)
eTotal = e1 + e2 + e3 + e4 + e5
e1p = sdiv(e1, eTotal)
e2p = sdiv(e2, eTotal)
e3p = sdiv(e3, eTotal)
e4p = sdiv(e4, eTotal)
e5p = sdiv(e5, eTotal)


// ============================================================================
//  ░░ ADAPTIVE SCALE RELIABILITY (online EWMA) ░░
//  Score each band's detail sign (lagged by horizon) against realized return.
// ============================================================================
NL = 5
var float[] scaleRel = array.new<float>(NL, 0.5)

if ai_enableInput and barstate.isconfirmed and bar_index > ai_horizonInp
    hz = ai_horizonInp
    rh = close - close[hz]
    a = ai_rateInput
    m1 = (w1[hz] > 0 and rh > 0) or (w1[hz] < 0 and rh < 0) ? 1.0 : 0.0
    m2 = (w2[hz] > 0 and rh > 0) or (w2[hz] < 0 and rh < 0) ? 1.0 : 0.0
    m3 = (w3[hz] > 0 and rh > 0) or (w3[hz] < 0 and rh < 0) ? 1.0 : 0.0
    m4 = (w4[hz] > 0 and rh > 0) or (w4[hz] < 0 and rh < 0) ? 1.0 : 0.0
    m5 = (w5[hz] > 0 and rh > 0) or (w5[hz] < 0 and rh < 0) ? 1.0 : 0.0
    array.set(scaleRel, 0, clamp(array.get(scaleRel, 0) + a * (m1 - array.get(scaleRel, 0)), 0.0, 1.0))
    array.set(scaleRel, 1, clamp(array.get(scaleRel, 1) + a * (m2 - array.get(scaleRel, 1)), 0.0, 1.0))
    array.set(scaleRel, 2, clamp(array.get(scaleRel, 2) + a * (m3 - array.get(scaleRel, 2)), 0.0, 1.0))
    array.set(scaleRel, 3, clamp(array.get(scaleRel, 3) + a * (m4 - array.get(scaleRel, 3)), 0.0, 1.0))
    array.set(scaleRel, 4, clamp(array.get(scaleRel, 4) + a * (m5 - array.get(scaleRel, 4)), 0.0, 1.0))

// Energy-weighted average reliability (used for confidence).
avgRel = sdiv(array.get(scaleRel, 0) * e1 + array.get(scaleRel, 1) * e2 + array.get(scaleRel, 2) * e3 + array.get(scaleRel, 3) * e4 + array.get(scaleRel, 4) * e5, eTotal)


// ============================================================================
//  ░░ SIGNAL ░░
// ============================================================================
dslope = denoised - denoised[1]
trendUp = trendLine > trendLine[1]
trendDn = trendLine < trendLine[1]

buyRaw = sig_modeInput == "Denoised crosses macro trend" ? ta.crossover(denoised, trendLine) : (ta.crossover(dslope, 0.0) and trendUp)
sellRaw = sig_modeInput == "Denoised crosses macro trend" ? ta.crossunder(denoised, trendLine) : (ta.crossunder(dslope, 0.0) and trendDn)

var int lastSig = 0
fireBuy = buyRaw and lastSig != 1
fireSell = sellRaw and lastSig != -1
if barstate.isconfirmed
    if fireBuy
        lastSig := 1
    if fireSell
        lastSig := -1

// Confidence: blend learned reliability with trend agreement and low HF noise.
trendAgree = (dslope > 0 and trendUp) or (dslope < 0 and trendDn)
lowNoise = e1p < 0.4   // high-freq band not dominating
confidencePct = clamp(avgRel * 100.0 * 0.6 + (trendAgree ? 25.0 : 0.0) + (lowNoise ? 15.0 : 0.0), 0.0, 100.0)


// ============================================================================
//  ░░ VISUALS — frequency strata (stacked ribbons) ░░
//  Draw c1..c5 with fills between adjacent scales. High freq = light/thin,
//  low freq (macro) = deep/thick.
// ============================================================================
pc1 = plot(vi_strata ? c1 : na, "Scale 1 (HF)", color = color.new(cS1, 35), linewidth = 1)
pc2 = plot(vi_strata ? c2 : na, "Scale 2",      color = color.new(cS2, 40), linewidth = 1)
pc3 = plot(vi_strata ? c3 : na, "Scale 3",      color = color.new(cS3, 45), linewidth = 1)
pc4 = plot(vi_strata ? c4 : na, "Scale 4",      color = color.new(cS4, 50), linewidth = 2)
pc5 = plot(vi_strata ? c5 : na, "Scale 5 (LF)", color = color.new(cS5, 30), linewidth = 2)

fill(pc1, pc2, color = vi_strata ? color.new(cS1, 88) : na, title = "Strata 1-2")
fill(pc2, pc3, color = vi_strata ? color.new(cS2, 88) : na, title = "Strata 2-3")
fill(pc3, pc4, color = vi_strata ? color.new(cS3, 88) : na, title = "Strata 3-4")
fill(pc4, pc5, color = vi_strata ? color.new(cS4, 88) : na, title = "Strata 4-5")

// Macro trend line (c_J).
plot(vi_trend ? trendLine : na, "Macro Trend", color = color.new(cTrend, 10), linewidth = 2)

// Denoised main line, colored by slope.
denCol = dslope > 0 ? cBuy : dslope < 0 ? cSell : cTxtD
plot(vi_denoised ? denoised : na, "Denoised", color = denCol, linewidth = 3)

// BUY/SELL markers.
plotshape(vi_marks and fireBuy  and barstate.isconfirmed, title = "BUY",  style = shape.labelup,   location = location.belowbar, color = cBuy,  textcolor = #04140f, text = "WAVE▲", size = size.small)
plotshape(vi_marks and fireSell and barstate.isconfirmed, title = "SELL", style = shape.labeldown, location = location.abovebar, color = cSell, textcolor = #1a0509, text = "WAVE▼", size = size.small)

barcolor(vi_barColor ? denCol : na, editable = false)


// ============================================================================
//  ░░ HUD ░░
// ============================================================================
bar10(p) =>
    int filled = math.round(clamp(p, 0.0, 1.0) * 10)
    string s = ""
    for i = 1 to 10
        s += i <= filled ? "█" : "░"
    s

scaleColorFor(idx) =>
    idx == 0 ? cS1 : idx == 1 ? cS2 : idx == 2 ? cS3 : idx == 3 ? cS4 : cS5

var table hud = na
if hud_showInp and na(hud)
    hud := table.new(position.top_right, 2, 13, bgcolor = cPanel,
         border_color = color.new(cAcc, 60), border_width = 1, frame_color = color.new(cAcc, 40), frame_width = 1)

if hud_showInp and barstate.islast
    sz = size.normal
    // Dominant scale = max energy band.
    domIdx = 0
    domE = e1p
    if e2p > domE
        domE := e2p
        domIdx := 1
    if e3p > domE
        domE := e3p
        domIdx := 2
    if e4p > domE
        domE := e4p
        domIdx := 3
    if e5p > domE
        domE := e5p
        domIdx := 4
    domName = domIdx == 0 ? "S1 chatter" : domIdx == 1 ? "S2 short" : domIdx == 2 ? "S3 swing" : domIdx == 3 ? "S4 trend" : "S5 macro"

    denDir = dslope > 0 ? "▲ rising" : dslope < 0 ? "▼ falling" : "· flat"
    denDirCol = dslope > 0 ? cBuy : dslope < 0 ? cSell : cTxtD
    trDir = trendUp ? "▲ up" : trendDn ? "▼ down" : "· flat"
    trDirCol = trendUp ? cBuy : trendDn ? cSell : cTxtD

    table.cell(hud, 0, 0, "WAVELET MULTI-RES", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 0, wv_filterInp + " ×" + str.tostring(J), text_color = cTxtD, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_right)

    table.cell(hud, 0, 1, "denoised", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 1, denDir, text_color = denDirCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 2, "macro trend", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 2, trDir, text_color = trDirCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 3, "confidence", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 3, bar10(confidencePct / 100.0) + " " + str.tostring(math.round(confidencePct)) + "%", text_color = confidencePct >= 65 ? cBuy : confidencePct >= 40 ? cTxt : cTxtD, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 4, "▔ FREQUENCY BANDS ▔", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 4, "energy · rel%", text_color = cTxtD, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_right)

    table.cell(hud, 0, 5, "S1 chatter (HF)", text_color = scaleColorFor(0), text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 5, bar10(e1p) + " " + str.tostring(math.round(array.get(scaleRel, 0) * 100)) + "%", text_color = cTxt, text_size = sz, text_halign = text.align_right)
    table.cell(hud, 0, 6, "S2 short", text_color = scaleColorFor(1), text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 6, bar10(e2p) + " " + str.tostring(math.round(array.get(scaleRel, 1) * 100)) + "%", text_color = cTxt, text_size = sz, text_halign = text.align_right)
    table.cell(hud, 0, 7, "S3 swing", text_color = scaleColorFor(2), text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 7, bar10(e3p) + " " + str.tostring(math.round(array.get(scaleRel, 2) * 100)) + "%", text_color = cTxt, text_size = sz, text_halign = text.align_right)
    table.cell(hud, 0, 8, "S4 trend", text_color = scaleColorFor(3), text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 8, bar10(e4p) + " " + str.tostring(math.round(array.get(scaleRel, 3) * 100)) + "%", text_color = cTxt, text_size = sz, text_halign = text.align_right)
    table.cell(hud, 0, 9, "S5 macro (LF)", text_color = scaleColorFor(4), text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 9, bar10(e5p) + " " + str.tostring(math.round(array.get(scaleRel, 4) * 100)) + "%", text_color = cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 10, "dominant band", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 10, domName, text_color = scaleColorFor(domIdx), text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 11, "denoise σ×", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 11, str.tostring(dn_strengthInp, "#.1") + (dn_strengthInp == 0 ? " (raw)" : ""), text_color = cTxt, text_size = sz, text_halign = text.align_right)

    sigState = lastSig == 1 ? "▲ long bias" : lastSig == -1 ? "▼ short bias" : "· neutral"
    sigCol = lastSig == 1 ? cBuy : lastSig == -1 ? cSell : cTxtD
    table.cell(hud, 0, 12, "signal state", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 12, sigState, text_color = sigCol, text_size = sz, text_halign = text.align_right)


// ============================================================================
//  ░░ ALERTS ░░
// ============================================================================
alertcondition(fireBuy,  "Wavelet BUY",  "AE-WAVE: denoised price turned up")
alertcondition(fireSell, "Wavelet SELL", "AE-WAVE: denoised price turned down")
````
