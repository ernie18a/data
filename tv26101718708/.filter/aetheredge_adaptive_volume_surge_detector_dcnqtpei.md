# AetherEdge - Adaptive Volume Surge Detector

- url: https://www.tradingview.com/script/dcNqtPeI/
- type: indicator
- pine_id: PUB;b632fb46a4884343aa0984665bfc3400
- version: 1.0

## Description

🖊️ Overview

AE-AVSD detects volume surges and uses a learning classifier to judge whether each surge is REAL or NOISE, printing a large BUY/SELL label only when a real surge aligns with a decisive candle direction. Unlike classical volume alerts, the AI filter structurally suppresses false signals — the chart never clutters with arrows.

🔶 Key Features

Auto-detects volume surges via statistical z-score significance
Candle-direction confirmation via body/range ratio — only directional spikes count
[AI Layer] Real/noise classification via online logistic regression learning follow-through
Fires only when three conditions align: volume surprise, direction, AI confidence
Big arrows on real surges only — everything else stays silent
Bar coloring visually emphasizes confirmed real surges
Integrated HUD showing verdict, features, AI probability, model accuracy
Per-direction alerts (BUY/SELL)

🧠 Technical Architecture

Surge detection uses the standard z-score method: bars where (volume − volMean) / volStd exceeds the threshold become candidates. The AI classification layer is a genuine online logistic regression: five features (bias, volume z, body magnitude in ATRs, body/range ratio, log return) feed a sigmoid that outputs P(real). Learning is delayed-label: surge contexts are buffered, and after the horizon a label is generated from whether an ATR-scaled continuation actually occurred, with weights updated by stochastic gradient descent. Signals fire only when all three — volume z, candle direction, and AI probability — pass their thresholds simultaneously, structurally excluding noise.

⚙️ Recommended Settings & Tuning Guide

Tuned with crypto in mind. The scalping-focused defaults (Surge Threshold 2σ, Follow-Through Horizon 5 bars, Required Follow-Through 0.7 ATR) are a starting point. If too many signals, raise Surge Threshold to 2.5–3.0σ and Real-Probability Threshold to 0.65–0.7. For day trading, raise Follow-Through Horizon to 10–15 bars and Required Follow-Through to 1.0–1.5 ATR, classifying only larger moves as "real." Min Body/Range Ratio excludes doji-like wick spikes; 0.5 is the standard default.

💡 How to Use in Practice

A BUY/SELL label appearing is a strong signal — volume confirmation + AI confidence all aligned. Scalpers can ride the next candle's direction; day traders can wait for the first pullback before entering. Pair with support/resistance and trend tools, and favor signals coinciding with key-level breaks or rejections. Consistently high P(real) on an instrument means volume signals work well there; consistently low values point to noisy instruments where other tools should be preferred.

⚠️ Important Notes

The AI layer requires accumulated data, so on new instruments or short windows P(real) stays near the initial 0.5 and the filter is weak. Static or near-50% model accuracy in the HUD indicates insufficient learning samples — meaningful classification needs roughly 30–50 surges. Volume signals tend to be more accurate in strong trends than in ranges, where fakeouts increase. Designed for scalping, intended for lower timeframes.

🚨 Disclaimer

This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. No signal guarantees future profit, and past performance does not indicate future results. All trading decisions are made at your own risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © AetherEdge — Adaptive Volume Surge Detector
//@version=6

// ┌──────────────────────────────────────────────────────────────────────────┐
// │  AetherEdge - Adaptive Volume Surge Detector  ·  AE-AVSD                    │
// │                                                                            │
// │  Detects volume SURGES (volume far above its rolling baseline) and an      │
// │  online classifier judges whether the surge is REAL — followed through     │
// │  with directional continuation — or NOISE that fades. Only real surges     │
// │  aligned with a decisive candle direction print a big BUY/SELL arrow.      │
// │                                                                            │
// │  AI: an honest online LOGISTIC REGRESSION over four standardized features  │
// │  (volume z-score, body magnitude, body/range ratio, return strength). It   │
// │  learns from delayed labels — did the surge actually lead to follow-       │
// │  through within the horizon? — so the classifier adapts to the instrument. │
// │                                                                            │
// │  Designed for scalping / day-trading: responsive surge detection, strict   │
// │  AI filtering, minimal-arrow output.                                       │
// └──────────────────────────────────────────────────────────────────────────┘

indicator("AetherEdge - Adaptive Volume Surge Detector", "AE-AVSD", overlay = true,
     max_labels_count = 200)


// ============================================================================
//  ░░ INPUTS ░░
// ============================================================================
gS = "▓ SURGE DETECTION ▓"
sv_baseWinInp = input.int(20, "Volume Baseline Window", minval = 5, maxval = 200, group = gS,
     tooltip = "Bars used to estimate the rolling average volume (the baseline a surge is measured against).")
sv_zThrInput  = input.float(2.0, "Surge Threshold (z-score)", minval = 0.5, maxval = 6.0, step = 0.1, group = gS,
     tooltip = "Volume z-score above this counts as a surge. Lower = more surges, higher = only extreme spikes.")
sv_bodyThrInp = input.float(0.5, "Min Body/Range Ratio", minval = 0.1, maxval = 0.95, step = 0.05, group = gS,
     tooltip = "Required ratio of candle body to total range — ensures the surge has a CLEAR direction, not a doji wick spike.")

gA = "▓ AI CLASSIFIER ▓"
ai_enableInput= input.bool(true, "Enable AI Real/Noise Classifier", group = gA,
     tooltip = "Filter surges through an online-learned probability of follow-through.")
ai_horizonInp = input.int(5, "Follow-Through Horizon (bars)", minval = 2, maxval = 30, group = gA,
     tooltip = "Bars ahead used to judge whether the surge produced continuation in its direction.")
ai_movInput   = input.float(0.7, "Required Follow-Through (ATR)", minval = 0.1, maxval = 3.0, step = 0.1, group = gA,
     tooltip = "Move in the surge direction within the horizon, in ATRs, that counts as a 'real' surge.")
ai_rateInput  = input.float(0.05, "Learning Rate", minval = 0.005, maxval = 0.3, step = 0.005, group = gA)
ai_thrInput   = input.float(0.55, "Real-Probability Threshold", minval = 0.3, maxval = 0.9, step = 0.05, group = gA,
     tooltip = "Minimum 'real' probability for the surge to fire a signal arrow.")

gV = "▓ VISUALS ▓"
vi_themeInput = input.string("Emerald / Ruby", "Palette",
     options = ["Emerald / Ruby", "Spectral", "Mint / Coral"], group = gV)
vi_colorBars  = input.bool(true, "Color Bars on Real Surges", group = gV,
     tooltip = "Tint the bar bright on confirmed real surges.")

gH = "▓ HUD ▓"
hud_showInput = input.bool(true, "Show HUD", group = gH)


// ============================================================================
//  ░░ PALETTE ░░
// ============================================================================
var color cBuy  = na
var color cSell = na
var color cAcc  = na
var color cTxt  = #eef2f0
var color cTxtD = #6b7d76
var color cPanel= #080b0a
var color cPanelHd = #0f1614

setPalette() =>
    [b, s, a] = switch vi_themeInput
        "Emerald / Ruby" => [#10e0a0, #ff3860, #d4af37]
        "Mint / Coral"   => [#4ef0c0, #ff6b6b, #d4af37]
        => [#22d3ee, #f43f5e, #e879f9]   // Spectral
    [b, s, a]
[pb, ps, pa] = setPalette()
cBuy  := pb
cSell := ps
cAcc  := pa


// ============================================================================
//  ░░ HELPERS ░░
// ============================================================================
sdiv(a, b) =>
    b != 0 ? a / b : 0.0
clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))


// ============================================================================
//  ░░ SURGE DETECTION + FEATURES ░░
// ============================================================================
atr = ta.atr(14)
volMean = ta.sma(volume, sv_baseWinInp)
volStd  = ta.stdev(volume, sv_baseWinInp)
volZ    = sdiv(volume - volMean, volStd)

candleRange = high - low
candleBody  = math.abs(close - open)
bodyRatio   = sdiv(candleBody, candleRange)
candleDir   = close > open ? 1 : close < open ? -1 : 0

// Raw surge: volume z above threshold AND directional candle.
surgeRaw    = volZ >= sv_zThrInput and bodyRatio >= sv_bodyThrInp and candleDir != 0


// ============================================================================
//  ░░ AI CLASSIFIER — online logistic regression over 4 standardized features ░░
//  Features: volume z, body magnitude (ATR-scaled), body/range ratio, return.
//  Learn whether the surge was followed by continuation within the horizon.
// ============================================================================
NF = 5   // bias + 4 features
var float[] aiW = array.new<float>(NF, 0.0)

sigmoid(z) =>
    z > 0 ? 1.0 / (1.0 + math.exp(-z)) : math.exp(z) / (1.0 + math.exp(z))

// Standardize features. Z-scores against a window so they live on similar scales.
fWin = 50
zf0 = 1.0
zf1 = clamp(nz(volZ), -4, 4)
zf2 = clamp(sdiv(candleBody, atr), -4, 4)
zf3 = clamp(bodyRatio * 2.0 - 1.0, -1, 1)
zf4 = clamp(sdiv(close - close[1], atr), -4, 4)

// Forward probability that the CURRENT context corresponds to a "real" surge.
// (Direction-agnostic: same features whether buy or sell side; the realized
// move's direction matches the candle direction at training time.)
dotW() =>
    array.get(aiW,0)*zf0 + array.get(aiW,1)*zf1 + array.get(aiW,2)*zf2 + array.get(aiW,3)*zf3 + array.get(aiW,4)*zf4
pReal = sigmoid(dotW())

// Pending samples per surge.
var float[] tFeat = array.new<float>(0)
var int[]   tDir  = array.new<int>(0)
var float[] tPx   = array.new<float>(0)
var int[]   tAge  = array.new<int>(0)
var float[] tHit  = array.new<float>(0)

if surgeRaw and ai_enableInput and barstate.isconfirmed
    array.push(tFeat, zf0)
    array.push(tFeat, zf1)
    array.push(tFeat, zf2)
    array.push(tFeat, zf3)
    array.push(tFeat, zf4)
    array.push(tDir, candleDir)
    array.push(tPx, close)
    array.push(tAge, 0)

if ai_enableInput and barstate.isconfirmed and array.size(tDir) > 0
    i = array.size(tDir) - 1
    while i >= 0
        age = array.get(tAge, i) + 1
        array.set(tAge, i, age)
        if age >= ai_horizonInp
            dir = array.get(tDir, i)
            px0 = array.get(tPx, i)
            moveDir = dir > 0 ? (close - px0) : (px0 - close)
            real = moveDir >= ai_movInput * atr ? 1.0 : 0.0
            base = i * NF
            g0 = array.get(tFeat, base)
            g1 = array.get(tFeat, base + 1)
            g2 = array.get(tFeat, base + 2)
            g3 = array.get(tFeat, base + 3)
            g4 = array.get(tFeat, base + 4)
            pOld = sigmoid(array.get(aiW,0)*g0 + array.get(aiW,1)*g1 + array.get(aiW,2)*g2 + array.get(aiW,3)*g3 + array.get(aiW,4)*g4)
            err = pOld - real
            array.set(aiW, 0, array.get(aiW,0) - ai_rateInput * err * g0)
            array.set(aiW, 1, array.get(aiW,1) - ai_rateInput * err * g1)
            array.set(aiW, 2, array.get(aiW,2) - ai_rateInput * err * g2)
            array.set(aiW, 3, array.get(aiW,3) - ai_rateInput * err * g3)
            array.set(aiW, 4, array.get(aiW,4) - ai_rateInput * err * g4)
            predReal = pOld > 0.5 ? 1.0 : 0.0
            array.push(tHit, predReal == real ? 1.0 : 0.0)
            if array.size(tHit) > 100
                array.shift(tHit)
            array.remove(tFeat, base + 4)
            array.remove(tFeat, base + 3)
            array.remove(tFeat, base + 2)
            array.remove(tFeat, base + 1)
            array.remove(tFeat, base)
            array.remove(tDir, i)
            array.remove(tPx, i)
            array.remove(tAge, i)
        i -= 1

aiAcc = array.size(tHit) > 0 ? array.avg(tHit) * 100.0 : 50.0


// ============================================================================
//  ░░ FINAL SIGNAL ░░
//  Surge + direction + AI confidence above threshold = real signal.
// ============================================================================
passAI = not ai_enableInput or pReal >= ai_thrInput
realBuy  = surgeRaw and candleDir > 0 and passAI
realSell = surgeRaw and candleDir < 0 and passAI


// ============================================================================
//  ░░ VISUALS ░░
// ============================================================================
// Big arrows on real surges (the only signals shown).
plotshape(realBuy,  title = "BUY surge",  style = shape.labelup,   location = location.belowbar,
     color = cBuy,  textcolor = #04140f, text = "BUY",  size = size.normal)
plotshape(realSell, title = "SELL surge", style = shape.labeldown, location = location.abovebar,
     color = cSell, textcolor = #1a0509, text = "SELL", size = size.normal)

// Bar coloring on confirmed surges.
barColor = vi_colorBars ? (realBuy ? cBuy : realSell ? cSell : na) : na
barcolor(barColor, editable = false)


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
if hud_showInput and na(hud)
    hud := table.new(position.top_right, 2, 7, bgcolor = cPanel,
         border_color = color.new(cAcc, 60), border_width = 1, frame_color = color.new(cAcc, 40), frame_width = 1)

if hud_showInput and barstate.islast
    surgeNow = surgeRaw
    dirNow = candleDir > 0 ? "▲ up" : candleDir < 0 ? "▼ dn" : "—"
    dirCol = candleDir > 0 ? cBuy : candleDir < 0 ? cSell : cTxtD
    verdict = realBuy ? "★ REAL BUY" : realSell ? "★ REAL SELL" : surgeNow ? "· surge (filtered)" : "· quiet"
    verdictCol = realBuy ? cBuy : realSell ? cSell : surgeNow ? cTxtD : cTxtD
    pRealPct = pReal * 100.0

    table.cell(hud, 0, 0, "VOLUME SURGE DETECTOR", text_color = cAcc, text_size = size.normal, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 0, ai_enableInput ? "AI on" : "AI off", text_color = cTxtD, text_size = size.normal, bgcolor = cPanelHd, text_halign = text.align_right)

    table.cell(hud, 0, 1, "verdict", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 1, verdict, text_color = verdictCol, text_size = size.normal, text_halign = text.align_right)

    table.cell(hud, 0, 2, "volume z", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 2, str.tostring(volZ, "#.0") + "σ", text_color = volZ >= sv_zThrInput ? cAcc : cTxt, text_size = size.normal, text_halign = text.align_right)

    table.cell(hud, 0, 3, "candle dir", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 3, dirNow, text_color = dirCol, text_size = size.normal, text_halign = text.align_right)

    table.cell(hud, 0, 4, "body/range", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 4, str.tostring(bodyRatio * 100, "#") + "%", text_color = bodyRatio >= sv_bodyThrInp ? cAcc : cTxt, text_size = size.normal, text_halign = text.align_right)

    table.cell(hud, 0, 5, "P(real)", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 5, bar10(pReal) + "  " + str.tostring(pRealPct, "#") + "%", text_color = pReal >= ai_thrInput ? cBuy : cTxtD, text_size = size.normal, text_halign = text.align_right)

    table.cell(hud, 0, 6, "model acc", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 6, str.tostring(aiAcc, "#") + "%  (" + str.tostring(array.size(tHit)) + ")", text_color = aiAcc > 55 ? cBuy : aiAcc < 45 ? cSell : cTxt, text_size = size.normal, text_halign = text.align_right)


// ============================================================================
//  ░░ ALERTS ░░
// ============================================================================
alertcondition(realBuy,  "Real BUY surge",  "AE-AVSD: real volume surge upward (BUY)")
alertcondition(realSell, "Real SELL surge", "AE-AVSD: real volume surge downward (SELL)")
````
