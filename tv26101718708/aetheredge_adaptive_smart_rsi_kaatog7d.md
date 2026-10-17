# AetherEdge - Adaptive Smart RSI

- url: https://www.tradingview.com/script/KAaTOG7D/
- type: indicator
- pine_id: PUB;babde655eda24f7cacc7c9a98f0760ea
- version: 1.0

## Description

🖊️ Overview

AE-ASRSI is a next-generation RSI that online-learns each instrument's truly effective overbought/oversold levels, rather than judging by fixed 70/30 lines. It transplants the core idea of Q-learning — learning action values from experience — to dynamically select the highest-performing line from a set of candidate thresholds. With its color changing the instant BUY/SELL signals are emitted, it is intuitive even for beginners.

🔶 Key Features

Dynamic OB/OS: Q-learning chooses the optimal level from candidate thresholds (60–80 / 40–20)
Color-flip signals: RSI turns red/green the moment it enters a zone, with BUY/SELL bubbles
Intuitive visuals: zone entry also tints the background — "color changed = signal" at a glance
Adaptive lines: OB/OS levels move automatically based on instrument and market regime
ε-greedy exploration: occasionally samples weaker thresholds to avoid lock-in to local optima
Neon-glow RSI plot with a refined red/green palette
Integrated HUD showing learned levels and each zone's success rate
Built-in BUY/SELL alerts

🧠 Technical Architecture

A full Q-learning implementation is too heavy for Pine, but its core idea — learn action values from experience, prefer high-value actions — is reproduced online. Five candidate thresholds each are kept for OB (60/65/70/75/80) and OS (40/35/30/25/20), with a Q-value (0–1) per candidate. When RSI crosses a candidate, its context is buffered; after the outcome horizon, a reward is generated from whether a real reaction (an ATR-scaled move against the cross direction) actually occurred, and Q is updated via Q ← Q + α(r − Q). The displayed threshold is the argmax candidate, while ε-greedy occasionally samples others to maintain exploration. Plot color flips instantly on zone detection, serving as the visual signal.

⚙️ Recommended Settings & Tuning Guide

Tuned with crypto in mind. RSI Length 14 and Smoothing ~2 are a starting point. Outcome Horizon is the bar count for evaluating reactions — 5–10 for intraday, 15–25 for swing. Reaction Threshold (ATR) sets how large a reaction counts as success; for strictness, raise to 1.5–2.0. Exploration (ε) defaults to 0.1 — higher increases exploration, lower stabilizes.

💡 How to Use in Practice

The simplest use is "trade the color flip." When RSI turns green with a BUY bubble, consider a long fading oversold; turning red with a SELL bubble, consider a short fading overbought. The HUD's learned OB/OS levels indicate the bounds actually working on this instrument — more precise than judging by fixed 70/30. If the zone success rate stably exceeds 50%, the learning is functioning. Counter-trend accuracy degrades in trending markets, so pair with trend tools and rely on this most in ranging conditions.

⚠️ Important Notes

This tool is Q-learning-inspired, not a full reinforcement-learning agent; within Pine's constraints it reproduces the core idea as online threshold selection. Learning requires accumulated data, so on new instruments or short windows the Q-values remain near initial values and behavior approaches the default thresholds. Static success rates in the HUD signal insufficient learning data. RSI is fundamentally a counter-trend tool that excels in ranges; in strong trends, signals can fire repeatedly without working well.

🚨 Disclaimer

This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. No signal guarantees future profit, and past performance does not indicate future results. All trading decisions are made at your own risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © AetherEdge — Adaptive Smart RSI
//@version=6

// ┌──────────────────────────────────────────────────────────────────────────┐
// │  AetherEdge - Adaptive Smart RSI  ·  AE-ASRSI                               │
// │                                                                            │
// │  A classical RSI where the overbought / oversold lines ADAPT to what       │
// │  actually works on this instrument. Instead of hard-coded 70/30 levels,    │
// │  the engine maintains a Q-learning-inspired score over a set of candidate  │
// │  thresholds (60..80 / 40..20) and continuously promotes the levels whose   │
// │  crossings have historically been followed by genuine reversals.           │
// │                                                                            │
// │  HONEST SCOPE: a full RL agent is too heavy for Pine, but the CORE IDEA —  │
// │  learn from outcomes, prefer actions (thresholds) that paid off — is       │
// │  reproduced via an online value table updated by a delayed-label reward.   │
// │                                                                            │
// │  USE: when the RSI line turns red it has crossed the LEARNED overbought    │
// │  line — a contrarian SELL cue. Turns green crossing the LEARNED oversold   │
// │  line — a contrarian BUY cue. Plain "color flip = signal."                 │
// └──────────────────────────────────────────────────────────────────────────┘

indicator("AetherEdge - Adaptive Smart RSI", "AE-ASRSI", overlay = false,
     max_labels_count = 200, max_lines_count = 50)


// ============================================================================
//  ░░ INPUTS ░░
// ============================================================================

// ─── RSI CORE ────────────────────────────────────────────────────────────────
gR = "▓ RSI CORE ▓"
rs_lenInput   = input.int(14, "RSI Length", minval = 2, maxval = 100, group = gR)
rs_srcInput   = input.source(close, "Source", group = gR)
rs_smoothInp  = input.int(2, "RSI Smoothing", minval = 1, maxval = 10, group = gR,
     tooltip = "EMA smoothing applied to the RSI for cleaner color transitions.")

// ─── ADAPTIVE LEARNING ───────────────────────────────────────────────────────
gA = "▓ AI · ADAPTIVE THRESHOLDS ▓"
ai_enableInput= input.bool(true, "Enable Adaptive Levels", group = gA,
     tooltip = "Q-learning-style learning: candidate OB/OS thresholds are scored by past success and the best are chosen as the active lines.")
ai_horizonInp = input.int(10, "Outcome Horizon (bars)", minval = 2, maxval = 50, group = gA,
     tooltip = "Bars ahead to evaluate whether a crossing actually led to a reversal.")
ai_reactInput = input.float(1.0, "Reaction Threshold (ATR)", minval = 0.2, maxval = 5.0, step = 0.1, group = gA,
     tooltip = "How large a reversal counts as 'success'. 1.0 = require an ATR-scale move against the cross direction.")
ai_rateInput  = input.float(0.1, "Learning Rate", minval = 0.01, maxval = 0.5, step = 0.01, group = gA)
ai_explInput  = input.float(0.1, "Exploration (ε)", minval = 0.0, maxval = 0.5, step = 0.02, group = gA,
     tooltip = "Q-learning ε-greedy: with this probability, give weaker thresholds a chance to be sampled, avoiding locked-in choices.")

// ─── VISUALS ─────────────────────────────────────────────────────────────────
gV = "▓ VISUALS ▓"
vi_themeInput = input.string("Emerald / Ruby", "Palette",
     options = ["Emerald / Ruby", "Mint / Coral", "Spectral"], group = gV)
vi_glowInput  = input.bool(true, "Neon Glow on RSI", group = gV)
vi_fillInput  = input.bool(true, "Fill OB/OS Zones", group = gV)
vi_signalInput= input.bool(true, "Show BUY/SELL Signal Markers", group = gV)

// ─── HUD ─────────────────────────────────────────────────────────────────────
gH = "▓ HUD ▓"
hud_showInput = input.bool(true, "Show HUD", group = gH)
hud_posInput  = input.string("Top Right", "Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gH)
hud_sizeInput = input.string("Normal", "Text Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = gH)


// ============================================================================
//  ░░ PALETTE ░░
// ============================================================================
var color cBull  = na   // BUY / oversold reversal
var color cBear  = na   // SELL / overbought reversal
var color cNeut  = na
var color cAcc   = na
var color cTxt   = #eef2f0
var color cTxtD  = #6b7d76
var color cPanel = #080b0a
var color cPanelHd = #0f1614

setPalette() =>
    [b, s, n, a] = switch vi_themeInput
        "Emerald / Ruby" => [#10e0a0, #ff3860, #6b7d76, #d4af37]
        "Mint / Coral"   => [#4ef0c0, #ff6b6b, #6b7d76, #d4af37]
        => [#22d3ee, #f43f5e, #a78bfa, #e879f9]   // Spectral
    [b, s, n, a]
[pb, ps, pn, pa] = setPalette()
cBull  := pb
cBear  := ps
cNeut  := pn
cAcc   := pa


// ============================================================================
//  ░░ HELPERS ░░
// ============================================================================
clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))


// ============================================================================
//  ░░ RSI CORE ░░
// ============================================================================
atr = ta.atr(14)
rsiRaw = ta.rsi(rs_srcInput, rs_lenInput)
rsi = ta.ema(rsiRaw, rs_smoothInp)


// ============================================================================
//  ░░ Q-LEARNING-INSPIRED THRESHOLD VALUES ░░
//  Five candidate overbought levels (60..80) and five oversold (40..20). Each
//  has a Q-value scored from outcomes after RSI crossed it: did price actually
//  reverse against the cross direction by a reaction threshold within horizon?
// ============================================================================
NC = 5
// Candidate OB and OS levels.
obCand = array.from(60.0, 65.0, 70.0, 75.0, 80.0)
osCand = array.from(40.0, 35.0, 30.0, 25.0, 20.0)
// Q-values (persistent across bars), start neutral 0.5.
var float[] qOB = array.new<float>(NC, 0.5)
var float[] qOS = array.new<float>(NC, 0.5)

// Choose active threshold = argmax Q (with ε-greedy exploration).
// To stabilize the LINE drawing, we re-select only on each new bar (confirmed).
chooseIdx(qArr, eps) =>
    bestI = 0
    bestQ = array.get(qArr, 0)
    for k = 1 to NC - 1
        if array.get(qArr, k) > bestQ
            bestQ := array.get(qArr, k)
            bestI := k
    // ε-greedy: with prob eps pick a random index instead.
    u = math.sin(bar_index * 0.9173 + 1.27) * 43758.5453
    u := u - math.floor(u)
    out = u < eps ? int(math.floor(u * NC * 10) % NC) : bestI
    out

var int obIdx = 2   // default 70
var int osIdx = 2   // default 30
if barstate.isconfirmed
    obIdx := chooseIdx(qOB, ai_enableInput ? ai_explInput : 0.0)
    osIdx := chooseIdx(qOS, ai_enableInput ? ai_explInput : 0.0)

obLevel = array.get(obCand, obIdx)
osLevel = array.get(osCand, osIdx)


// ============================================================================
//  ░░ DELAYED-LABEL Q-VALUE UPDATES ░░
//  When RSI crosses an OB candidate, buffer (idx, price, age). After horizon,
//  reward = 1 if price fell by ≥ reactThr*ATR (a real reversal), else 0.
//  Update Q via Q ← Q + α (r - Q). Symmetric for OS (reward on a rise).
// ============================================================================
var int[]   obBufIdx = array.new<int>(0)
var float[] obBufPx  = array.new<float>(0)
var int[]   obBufAge = array.new<int>(0)
var int[]   osBufIdx = array.new<int>(0)
var float[] osBufPx  = array.new<float>(0)
var int[]   osBufAge = array.new<int>(0)
var float[] hitOB    = array.new<float>(0)
var float[] hitOS    = array.new<float>(0)

// Detect candidate crossings (cross UP for OB, cross DOWN for OS) on each bar.
if ai_enableInput and barstate.isconfirmed
    for k = 0 to NC - 1
        // OB cross up (RSI breaking above candidate).
        lvOB = array.get(obCand, k)
        if ta.crossover(rsi, lvOB)
            array.push(obBufIdx, k)
            array.push(obBufPx, close)
            array.push(obBufAge, 0)
        // OS cross down.
        lvOS = array.get(osCand, k)
        if ta.crossunder(rsi, lvOS)
            array.push(osBufIdx, k)
            array.push(osBufPx, close)
            array.push(osBufAge, 0)

// Age & resolve OB outcomes.
if ai_enableInput and barstate.isconfirmed and array.size(obBufIdx) > 0
    i = array.size(obBufIdx) - 1
    while i >= 0
        age = array.get(obBufAge, i) + 1
        array.set(obBufAge, i, age)
        if age >= ai_horizonInp
            k = array.get(obBufIdx, i)
            px0 = array.get(obBufPx, i)
            // Did price actually fall (overbought reversal)? min over horizon.
            minPx = ta.lowest(low, ai_horizonInp)
            reward = (px0 - minPx) >= ai_reactInput * atr ? 1.0 : 0.0
            oldQ = array.get(qOB, k)
            array.set(qOB, k, clamp(oldQ + ai_rateInput * (reward - oldQ), 0.0, 1.0))
            array.push(hitOB, reward)
            if array.size(hitOB) > 100
                array.shift(hitOB)
            array.remove(obBufIdx, i)
            array.remove(obBufPx, i)
            array.remove(obBufAge, i)
        i -= 1

// Age & resolve OS outcomes.
if ai_enableInput and barstate.isconfirmed and array.size(osBufIdx) > 0
    i = array.size(osBufIdx) - 1
    while i >= 0
        age = array.get(osBufAge, i) + 1
        array.set(osBufAge, i, age)
        if age >= ai_horizonInp
            k = array.get(osBufIdx, i)
            px0 = array.get(osBufPx, i)
            maxPx = ta.highest(high, ai_horizonInp)
            reward = (maxPx - px0) >= ai_reactInput * atr ? 1.0 : 0.0
            oldQ = array.get(qOS, k)
            array.set(qOS, k, clamp(oldQ + ai_rateInput * (reward - oldQ), 0.0, 1.0))
            array.push(hitOS, reward)
            if array.size(hitOS) > 100
                array.shift(hitOS)
            array.remove(osBufIdx, i)
            array.remove(osBufPx, i)
            array.remove(osBufAge, i)
        i -= 1


// ============================================================================
//  ░░ SIGNALS — color flip & entry markers ░░
//  RSI enters the LEARNED OB band → SELL (contrarian). Enters OS → BUY.
// ============================================================================
inOB  = rsi >= obLevel
inOS  = rsi <= osLevel
crossUp_OB   = ta.crossover(rsi, obLevel)
crossDn_OS   = ta.crossunder(rsi, osLevel)
crossDn_back = ta.crossunder(rsi, obLevel)   // RSI falling back from OB (confirm SELL)
crossUp_back = ta.crossover(rsi, osLevel)     // RSI rising back from OS (confirm BUY)

// Beginner-friendly: signal when RSI ENTERS the learned zone (color flips).
sellSignal = crossUp_OB
buySignal  = crossDn_OS

// RSI color by zone.
rsiCol = inOB ? cBear : inOS ? cBull : cNeut


// ============================================================================
//  ░░ PLOTS ░░
// ============================================================================
// Glow layer (wider, fainter) under the main RSI for neon emission.
plot(vi_glowInput ? rsi : na, "RSI glow",  color = color.new(rsiCol, 70), linewidth = 5, editable = false)
plot(rsi, "RSI", color = rsiCol, linewidth = 2)

// Adaptive OB / OS lines.
obLine = plot(obLevel, "Adaptive OB", color = color.new(cBear, 30), linewidth = 1, style = plot.style_line)
osLine = plot(osLevel, "Adaptive OS", color = color.new(cBull, 30), linewidth = 1, style = plot.style_line)
midLine = plot(50.0, "Midline", color = color.new(cNeut, 65), linewidth = 1, style = plot.style_line)

// Zone fills.
upBand = plot(100, "100 cap", color = na, editable = false, display = display.none)
lwBand = plot(0,   "0 cap",   color = na, editable = false, display = display.none)
fill(obLine, upBand, color = vi_fillInput ? color.new(cBear, 87) : na, title = "OB fill")
fill(osLine, lwBand, color = vi_fillInput ? color.new(cBull, 87) : na, title = "OS fill")

// Signal markers — drawn on the MAIN CHART CANDLES via force_overlay so they
// appear under/over the candle, not on the RSI line itself.
plotshape(vi_signalInput and buySignal,  title = "BUY (oversold)",   style = shape.labelup,   location = location.belowbar, color = cBull, textcolor = #04140f, text = "BUY",  size = size.small, force_overlay = true)
plotshape(vi_signalInput and sellSignal, title = "SELL (overbought)", style = shape.labeldown, location = location.abovebar, color = cBear, textcolor = #1a0509, text = "SELL", size = size.small, force_overlay = true)
// Subtle triangle echo on the RSI line itself, so the signal is visible on both panes.
plotshape(vi_signalInput and buySignal  ? rsi : na, title = "BUY echo",  style = shape.triangleup,   location = location.absolute, color = cBull, size = size.tiny)
plotshape(vi_signalInput and sellSignal ? rsi : na, title = "SELL echo", style = shape.triangledown, location = location.absolute, color = cBear, size = size.tiny)

// Background tint inside zones for instant visual recognition.
bgcolor(inOB ? color.new(cBear, 93) : inOS ? color.new(cBull, 93) : na, editable = false)


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
bar10(p) =>
    int filled = math.round(clamp(p, 0.0, 1.0) * 10)
    string s = ""
    for i = 1 to 10
        s += i <= filled ? "█" : "░"
    s

var table hud = na
if hud_showInput and na(hud)
    hud := table.new(hudPos(hud_posInput), 2, 8, bgcolor = cPanel,
         border_color = color.new(cAcc, 60), border_width = 1, frame_color = color.new(cAcc, 40), frame_width = 1)

if hud_showInput and barstate.islast
    sz = hudSize(hud_sizeInput)
    zoneTxt = inOB ? "▼ OVERBOUGHT" : inOS ? "▲ OVERSOLD" : "· neutral"
    zoneCol = inOB ? cBear : inOS ? cBull : cTxtD
    accOB = array.size(hitOB) > 0 ? array.avg(hitOB) * 100.0 : 50.0
    accOS = array.size(hitOS) > 0 ? array.avg(hitOS) * 100.0 : 50.0

    table.cell(hud, 0, 0, "ADAPTIVE SMART RSI", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 0, "Q-learn", text_color = cTxtD, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_right)

    table.cell(hud, 0, 1, "RSI", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 1, str.tostring(rsi, "#.0"), text_color = rsiCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 2, "zone", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 2, zoneTxt, text_color = zoneCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 3, "learned OB", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 3, str.tostring(obLevel, "#.0"), text_color = cBear, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 4, "learned OS", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 4, str.tostring(osLevel, "#.0"), text_color = cBull, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 5, "OB success", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 5, bar10(accOB / 100.0) + " " + str.tostring(accOB, "#") + "%", text_color = accOB > 55 ? cBull : accOB < 45 ? cBear : cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 6, "OS success", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 6, bar10(accOS / 100.0) + " " + str.tostring(accOS, "#") + "%", text_color = accOS > 55 ? cBull : accOS < 45 ? cBear : cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 7, "horizon", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 7, str.tostring(ai_horizonInp) + " bars", text_color = cTxt, text_size = sz, text_halign = text.align_right)


// ============================================================================
//  ░░ ALERTS ░░
// ============================================================================
alertcondition(buySignal,  "Adaptive BUY",  "AE-ASRSI: RSI entered the learned OVERSOLD zone (BUY)")
alertcondition(sellSignal, "Adaptive SELL", "AE-ASRSI: RSI entered the learned OVERBOUGHT zone (SELL)")
````
