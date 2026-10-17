# AetherEdge - Self-Attention Focus

- url: https://www.tradingview.com/script/hAUvPolk/
- type: indicator
- pine_id: PUB;9fe460ebc7c947809e75ecd6410e962e
- version: 1.0

## Description

🖊️ Overview

AE-FOCUS uses the Transformer self-attention mechanism to compute "which past moments does NOW most resemble" and forecasts from the outcomes of those analogous states. Each bar is a feature vector; the current query is dotted against past keys, softmax-normalized into attention weights, and the "what happened after" of high-attention past bars is weight-averaged into a forecast. Glowing arcs sweep from NOW back to resonating past bars, brighter where attention is stronger — a visualization unprecedented in Pine.

🔶 Key Features

Self-attention mechanism: genuine query-key-value-softmax structure
4-D feature vector: standardized return, momentum, RSI-deviation, volatility-ratio
Attention-weighted forecast: weight-averages outcomes of analogous past states
Resonance arc rendering: curves from NOW to high-attention bars visualize resonance
Arc brightness/width scales with attention strength
Online forecast hit-rate tracking
Confidence from attention concentration (entropy-based)
Forecast-direction background + BUY/SELL markers
HUD showing resonance target and concentration
Per-event alerts

🧠 Technical Architecture

This implements the self-attention mechanism. Each bar's feature vector is standardized 4-D [return, momentum, RSI-deviation, volatility-ratio]. With query = current features and key_s = past bar s features, the attention score score(s) = (q · k_s)/√d is computed and normalized α(s) = softmax_s(score/τ) (τ = temperature). value(s) = the realized return in the h bars after bar s (known since s is far enough in the past). forecast = Σ α(s)·value(s) weight-averages the outcomes of analogous states into a predicted return. This is effectively attention-kernel regression over past states similar to the current one. The forecast's hit-rate is tracked online, combined with attention concentration (entropy) and forecast magnitude into confidence. Signals fire when the smoothed forecast crosses threshold.

⚙️ Recommended Settings & Tuning Guide

Attention Lookback (N) 60 is a starting point — the past bars the current query attends over. Outcome Horizon (h) 5 is the value horizon (outcome in the h bars after each past bar) and the forecast horizon. Softmax Temperature (τ) 1.0 is attention sharpness — lower focuses hard on the single closest analog (sharp), higher is more averaged (soft). Feature Normalization Window 100 is the standardization window. Forecast Threshold 0.15 is the firing threshold (normalized return). Arc Threshold 2.5 is how many times the average attention a bar must exceed to get an arc; Arc Height 2.0 is the arc height.

💡 How to Use in Practice

Apply to chart and glowing arcs sweep from NOW to high-attention past bars. The past moments where arcs cluster are those most "resonating" with now. Green arcs mean analogous states rose afterward (bullish forecast); red means they fell (bearish). The HUD's "resonates with" shows how many bars ago resonates most, and "concentration" shows attention concentration (whether a clear analog exists). When concentration is high and forecast hit-rate is high, signal reliability rises. Lowering τ reacts sharply to the single closest analog; raising it gives a smooth forecast averaged over many states.

⚠️ Important Notes

This is single-head attention with fixed (identity/statistical) projections — learned W_Q/W_K/W_V weights and multi-head are outside Pine's limits. It is effectively attention-kernel regression over analogous states, but the query-key-value-softmax structure is the genuine attention mechanism. The forecast is a probabilistic decision based on outcomes of analogous past states, not a certain prediction (past analogies are not guaranteed to repeat). Attention arcs show only the latest bar's resonance and update in real time. All signals are probabilistic decisions based on historical data and do not guarantee future profits.

🚨 Disclaimer

This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. No signal guarantees future profit, and past performance does not indicate future results. All trading decisions are made at your own risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © AetherEdge — Self-Attention Focus
//@version=6

// ┌──────────────────────────────────────────────────────────────────────────┐
// │  AetherEdge - Self-Attention Focus  ·  AE-FOCUS                             │
// │                                                                            │
// │  Asks the Transformer question: "which moments in the past does NOW most   │
// │  resemble?" — and answers with self-attention. Each bar is a feature       │
// │  vector; the current bar's query is dotted against past keys, softmax-     │
// │  normalized into attention weights, and the VALUE (what happened AFTER     │
// │  each past bar) is weight-averaged into a forecast. Glowing arcs sweep     │
// │  from NOW back to the bars it is resonating with — brighter where the      │
// │  attention is stronger.                                                    │
// │                                                                            │
// │  HOW IT WORKS (genuine attention)                                         │
// │  • Feature vector per bar: standardized [return, momentum, RSI-deviation,  │
// │    volatility-ratio].                                                      │
// │  • query = current features; key_s = features of past bar s.               │
// │  • score(s) = (q · k_s)/√d ; α(s) = softmax_s(score/τ).                    │
// │  • value(s) = the realized return in the h bars AFTER bar s (known,        │
// │    because s is far enough in the past).                                  │
// │  • forecast = Σ α(s)·value(s) — the weighted outcome of analogous past     │
// │    states. Sign + magnitude → BUY/SELL.                                   │
// │                                                                            │
// │  ADAPTIVE: the forecast's realized hit-rate is tracked online and feeds    │
// │  the confidence.                                                          │
// │                                                                            │
// │  HONEST SCOPE: single-head attention with FIXED (identity/statistical)     │
// │  projections — not learned W_Q/W_K/W_V, no multi-head. Effectively         │
// │  attention-kernel regression over analogous states. The query-key-value-   │
// │  softmax structure, however, is the genuine attention mechanism.          │
// └──────────────────────────────────────────────────────────────────────────┘

indicator("AetherEdge - Self-Attention Focus", "AE-FOCUS", overlay = true,
     max_bars_back = 300, max_labels_count = 100, max_lines_count = 100, max_polylines_count = 100)


// ============================================================================
//  ░░ INPUTS — attention ░░
// ============================================================================
gA = "▓ ATTENTION ▓"
at_lbInp    = input.int(60, "Attention Lookback (N keys)", minval = 10, maxval = 150, group = gA,
     tooltip = "How many past bars the current query attends over.")
at_hzInp    = input.int(5, "Outcome Horizon (h bars)", minval = 1, maxval = 30, group = gA,
     tooltip = "value(s) = realized return in the h bars after each past bar s. Also the forecast horizon.")
at_tempInp  = input.float(1.0, "Softmax Temperature (τ)", minval = 0.1, maxval = 5.0, step = 0.1, group = gA,
     tooltip = "Lower τ = sharper attention (focuses hard on the closest analog). Higher τ = softer, more averaged.")
at_normInp  = input.int(100, "Feature Normalization Window", minval = 20, maxval = 300, group = gA)
at_momInp   = input.int(10, "Momentum Feature Period", minval = 2, maxval = 50, group = gA)

gS = "▓ SIGNAL ▓"
sig_thrInp  = input.float(0.15, "Forecast Threshold (norm. return)", minval = 0.02, maxval = 1.0, step = 0.01, group = gS)
sig_smoothInp= input.int(2, "Forecast Smoothing (EMA)", minval = 1, maxval = 20, group = gS)

gVI = "▓ VISUALS ▓"
vi_themeInput = input.string("Resonance", "Palette",
     options = ["Resonance", "Neural Glow", "Synapse"], group = gVI)
vi_showArcs   = input.bool(true, "Show Resonance Arcs", group = gVI)
vi_arcThreshInp= input.float(2.5, "Arc Threshold (× avg attention)", minval = 1.0, maxval = 8.0, step = 0.5, group = gVI,
     tooltip = "Draw an arc to a past bar whose attention exceeds this multiple of the uniform weight (1/N).")
vi_arcHeightInp= input.float(2.0, "Arc Height (× ATR)", minval = 0.5, maxval = 8.0, step = 0.5, group = gVI)
vi_bgPred     = input.bool(true, "Background by Forecast", group = gVI)
vi_marks      = input.bool(true, "BUY/SELL Markers", group = gVI)

gH = "▓ HUD ▓"
hud_showInp   = input.bool(true, "Show HUD", group = gH)


// ============================================================================
//  ░░ PALETTE ░░
// ============================================================================
var color cBull = na
var color cBear = na
var color cAcc = na
var color cMid = na
var color cTxt = #eef2f0
var color cTxtD = #6b7d76
var color cPanel = #080b0a
var color cPanelHd = #0f1614

setPalette() =>
    [bu, be, a, m] = switch vi_themeInput
        "Neural Glow" => [#00e5ff, #ff3d71, #ffd166, #7c8aa0]
        "Synapse"     => [#10e0a0, #ff3860, #d4af37, #6b7d76]
        => [#00ffaa, #ff0066, #ffd700, #7c8aa0]   // Resonance
    [bu, be, a, m]
[pBu, pBe, pA, pM] = setPalette()
cBull := pBu
cBear := pBe
cAcc := pA
cMid := pM


// ============================================================================
//  ░░ HELPERS ░░
// ============================================================================
sdiv(a, b) =>
    b != 0 ? a / b : 0.0
clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))


// ============================================================================
//  ░░ FEATURE VECTORS (standardized, d = 4) ░░
// ============================================================================
atr = ta.atr(14)
atrAvg = ta.sma(atr, 50)
rsi = ta.rsi(close, 14)

f1raw = sdiv(close - close[1], atr)
f2raw = sdiv(close - close[at_momInp], atr)
f3raw = (rsi - 50.0) / 50.0
f4raw = sdiv(atr, atrAvg) - 1.0

zscore(x, win) =>
    s = ta.stdev(x, win)
    (x - ta.sma(x, win)) / (s + 1e-9)

f1z = zscore(f1raw, at_normInp)
f2z = zscore(f2raw, at_normInp)
f3z = zscore(f3raw, at_normInp)
f4z = zscore(f4raw, at_normInp)


// ============================================================================
//  ░░ SELF-ATTENTION ░░
//  query = current features; keys/values over past bars j = h .. h+N-1.
//  value(j) = realized return in the h bars after bar j = (close[j-h]-close[j]).
// ============================================================================
N = at_lbInp
h = at_hzInp
tau = at_tempInp

var float[] alpha = array.new<float>(N, 0.0)

predRaw = 0.0
maxAlpha = 0.0
maxAlphaIdx = 0
attnEntropy = 0.0

if bar_index > N + h + 2 and not na(atr) and atr > 0
    scores = array.new<float>(N, 0.0)
    maxS = -1e10
    for idx = 0 to N - 1
        j = idx + h
        sc = (f1z * f1z[j] + f2z * f2z[j] + f3z * f3z[j] + f4z * f4z[j]) / 2.0
        array.set(scores, idx, sc)
        maxS := math.max(maxS, sc)
    expSum = 0.0
    for idx = 0 to N - 1
        e = math.exp((array.get(scores, idx) - maxS) / tau)
        array.set(alpha, idx, e)
        expSum += e
    pr = 0.0
    mA = 0.0
    mAi = 0
    ent = 0.0
    for idx = 0 to N - 1
        a = expSum > 0.0 ? array.get(alpha, idx) / expSum : 1.0 / N
        array.set(alpha, idx, a)
        j = idx + h
        v = sdiv(close[j - h] - close[j], atr)
        pr += a * v
        if a > mA
            mA := a
            mAi := idx
        if a > 1e-12
            ent -= a * math.log(a)
    predRaw := pr
    maxAlpha := mA
    maxAlphaIdx := mAi
    attnEntropy := ent

predEMA = ta.ema(predRaw, sig_smoothInp)


// ============================================================================
//  ░░ FORECAST HIT-RATE (online) ░░
// ============================================================================
var float hitRate = 0.5
if barstate.isconfirmed and bar_index > h + 2
    pastPred = predRaw[h]
    realized = close - close[h]
    if pastPred != 0.0 and not na(pastPred)
        hit = (pastPred > 0.0 and realized > 0.0) or (pastPred < 0.0 and realized < 0.0) ? 1.0 : 0.0
        hitRate := hitRate * 0.95 + hit * 0.05


// ============================================================================
//  ░░ SIGNAL ░░
// ============================================================================
buyRaw = ta.crossover(predEMA, sig_thrInp)
sellRaw = ta.crossunder(predEMA, -sig_thrInp)

var int lastSig = 0
fireBuy = buyRaw and lastSig != 1
fireSell = sellRaw and lastSig != -1
if barstate.isconfirmed
    if fireBuy
        lastSig := 1
    if fireSell
        lastSig := -1
    if math.abs(predEMA) < sig_thrInp * 0.4
        lastSig := 0

// Confidence: attention concentration + forecast magnitude + hit-rate.
attnConc = maxAlpha * N
concScore = clamp((attnConc - 1.0) / 4.0, 0.0, 1.0)
predScore = clamp(math.abs(predEMA) / 0.3, 0.0, 1.0)
hitScore = clamp((hitRate - 0.4) / 0.4, 0.0, 1.0)
confidencePct = clamp(concScore * 35.0 + predScore * 35.0 + hitScore * 30.0, 0.0, 100.0)


// ============================================================================
//  ░░ VISUALS — resonance arcs (polylines from NOW to high-attention bars) ░░
// ============================================================================
var polyline[] arcs = array.new<polyline>(0)
if vi_showArcs and barstate.islast and bar_index > N + h + 2
    if array.size(arcs) > 0
        for i = 0 to array.size(arcs) - 1
            polyline.delete(array.get(arcs, i))
        array.clear(arcs)
    thr = (1.0 / N) * vi_arcThreshInp
    arcDir = predRaw >= 0.0 ? 1.0 : -1.0
    drawn = 0
    for idx = 0 to N - 1
        a = array.get(alpha, idx)
        if a > thr and drawn < 14
            j = idx + h
            aStr = clamp(a * N / 5.0, 0.1, 1.0)
            pts = array.new<chart.point>()
            steps = 8
            for s = 0 to steps
                tt = s / steps
                xx = (bar_index - j) + int(math.round(j * tt))
                ybase = close[j] + (close - close[j]) * tt
                bulge = math.sin(tt * math.pi) * atr * vi_arcHeightInp * arcDir * aStr
                yy = ybase + bulge
                array.push(pts, chart.point.from_index(xx, yy))
            acol = arcDir > 0.0 ? color.new(cBull, int(clamp(88.0 - aStr * 58.0, 25.0, 88.0))) : color.new(cBear, int(clamp(88.0 - aStr * 58.0, 25.0, 88.0)))
            pl = polyline.new(pts, curved = true, closed = false, line_color = acol, line_width = int(clamp(aStr * 3.0, 1.0, 3.0)))
            array.push(arcs, pl)
            drawn += 1

// Background by forecast.
bgCol = predEMA > sig_thrInp ? cBull : predEMA < -sig_thrInp ? cBear : na
bgTransp = 100 - int(clamp(math.abs(predEMA) / 0.4 * 35.0, 0.0, 35.0))
bgcolor(vi_bgPred and not na(bgCol) ? color.new(bgCol, bgTransp) : na, editable = false)

// BUY/SELL markers.
plotshape(vi_marks and fireBuy  and barstate.isconfirmed, title = "BUY",  style = shape.labelup,   location = location.belowbar, color = cBull, textcolor = #04140f, text = "ATTN▲", size = size.small)
plotshape(vi_marks and fireSell and barstate.isconfirmed, title = "SELL", style = shape.labeldown, location = location.abovebar, color = cBear, textcolor = #1a0509, text = "ATTN▼", size = size.small)

// Forecast strength plot (sub-line scaled near price low, optional via bg already).
plot(predEMA, "Forecast", color = na, editable = false, display = display.data_window)


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
    predDir = predEMA > 0.0 ? "▲ up" : predEMA < 0.0 ? "▼ down" : "· flat"
    predCol = predEMA > sig_thrInp ? cBull : predEMA < -sig_thrInp ? cBear : cTxtD
    resonBar = maxAlphaIdx + h
    maxEntropy = math.log(N)
    concPct = maxEntropy > 0 ? clamp(1.0 - attnEntropy / maxEntropy, 0.0, 1.0) : 0.0

    table.cell(hud, 0, 0, "SELF-ATTENTION", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 0, "N=" + str.tostring(N) + " h=" + str.tostring(h), text_color = cTxtD, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_right)

    table.cell(hud, 0, 1, "forecast", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 1, predDir + "  " + str.tostring(predEMA, "#.000"), text_color = predCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 2, "confidence", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 2, bar10(confidencePct / 100.0) + " " + str.tostring(math.round(confidencePct)) + "%", text_color = confidencePct >= 60 ? cBull : confidencePct >= 40 ? cTxt : cTxtD, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 3, "▔ ATTENTION ▔", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 3, "", bgcolor = cPanelHd)

    table.cell(hud, 0, 4, "resonates with", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 4, str.tostring(resonBar) + " bars ago", text_color = cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 5, "peak attention", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 5, str.tostring(math.round(maxAlpha * 100)) + "%", text_color = cAcc, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 6, "concentration", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 6, bar10(concPct) + " " + str.tostring(math.round(concPct * 100)) + "%", text_color = concPct > 0.5 ? cBull : cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 7, "▔ MODEL ▔", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 7, "", bgcolor = cPanelHd)

    hrCol = hitRate >= 0.55 ? cBull : hitRate >= 0.45 ? cTxt : cBear
    table.cell(hud, 0, 8, "forecast hit-rate", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 8, bar10(hitRate) + " " + str.tostring(math.round(hitRate * 100)) + "%", text_color = hrCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 9, "temperature τ", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 9, str.tostring(tau, "#.0"), text_color = cTxt, text_size = sz, text_halign = text.align_right)

    sigState = lastSig == 1 ? "▲ long bias" : lastSig == -1 ? "▼ short bias" : "· neutral"
    sigCol = lastSig == 1 ? cBull : lastSig == -1 ? cBear : cTxtD
    table.cell(hud, 0, 10, "signal state", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 10, sigState, text_color = sigCol, text_size = sz, text_halign = text.align_right)


// ============================================================================
//  ░░ ALERTS ░░
// ============================================================================
alertcondition(fireBuy,  "Attention BUY",  "AE-FOCUS: bullish forecast from analogous states")
alertcondition(fireSell, "Attention SELL", "AE-FOCUS: bearish forecast from analogous states")
````
