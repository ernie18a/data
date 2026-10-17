# AetherEdge - RL Momentum Filter

- url: https://www.tradingview.com/script/Ri3VZ3lS/
- type: indicator
- pine_id: PUB;9c85a858bd1c44419739e1df02f7d7ec
- version: 1.0

## Description

🖊️ Overview

AE-RLMF wraps two classical signal sources — MACD and Momentum — in an adaptive filter built on the reward concept from reinforcement learning. It online-learns which source is "recently effective" and automatically suppresses false signals from a source going through a bad patch. Arrows are minimal, and only agreement signals — where both indicators align — stand out.

🔶 Key Features

Two signal sources: MACD histogram cross and Momentum (ROC) zero-cross
RL-style adaptive filter: learns each source's "value" from outcomes and excludes signals from low-value sources
Recency-weighted: exponential averaging makes recent performance dominate
Agreement emphasis: BUY/SELL labels appear only when MACD and Momentum agree
Minimal arrows: solo signals are subtle triangles; only agreement signals print bubbles
Integrated HUD showing each source's current value, recent accuracy, and the strongest source
Per-channel alerts (agreement/solo × buy/sell)

🧠 Technical Architecture

This tool is not a full reinforcement-learning agent but reproduces its core idea — learn action values from outcomes, prefer high-value actions — as an online value table over the two signal sources. MACD histogram and Momentum zero-crosses are the raw signals; on each, the context is buffered. After the outcome horizon, a reward (0 or 1) is generated from whether price moved in the signal direction beyond the ATR-scaled win threshold, and the value Q is updated via Q ← Q + α(reward − Q). Higher Learning Rate weights recent performance more, strengthening the "recent winners" behavior. Signals from sources below Pass Threshold are filtered out, and the strongest "agreement signal" arises when both sources pass simultaneously in the same direction.

⚙️ Recommended Settings & Tuning Guide

Tuned with crypto in mind. Classical MACD 12/26/9 and Momentum 10 are a starting point. Outcome Horizon for reaction evaluation: 5–10 intraday, 15–25 for swing. Pass Threshold sets strictness — too many signals, raise to 0.55; too few, lower to 0.30. Higher Learning Rate (0.3–0.5) makes the filter more reactive to recent streaks; lower (0.1) stabilizes over the long run.

💡 How to Use in Practice

Highest-conviction are agreement signals (BUY/SELL bubbles): both MACD and Momentum are currently classified as "effective sources" and both flipped in the same direction. The smaller solo triangles are supporting cues, best used when they align with other evidence. Read the HUD's two source values (Q) and recent accuracies to see which is working in the current market and whether the filter is doing its job. Being trend-following, accuracy degrades in ranges; pairing with trend tools is effective.

⚠️ Important Notes

This tool is RL-inspired, not a true reinforcement-learning agent; within Pine's constraints it reproduces the core idea as experience-based value learning. The value learning requires accumulated data, so on new instruments or short windows Q-values stay near the initial 0.5 and the filter has little effect. Empty recent accuracy in the HUD signals insufficient learning samples. Setting Pass Threshold too high (0.6+) may suppress signals almost entirely.

🚨 Disclaimer

This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. No signal guarantees future profit, and past performance does not indicate future results. All trading decisions are made at your own risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © AetherEdge — RL Momentum Filter
//@version=6

// ┌──────────────────────────────────────────────────────────────────────────┐
// │  AetherEdge - RL Momentum Filter  ·  AE-RLMF                                │
// │                                                                            │
// │  MACD and Momentum signals filtered by a lightweight reinforcement-        │
// │  learning-inspired reward tracker. Each signal source keeps an online      │
// │  "performance value" (its Q-value) — recent winning signals lift it,       │
// │  recent losers cut it. Only signals from sources whose value is currently  │
// │  HIGH pass the filter, so false signals from a source going through a bad  │
// │  patch are suppressed automatically.                                       │
// │                                                                            │
// │  HONEST SCOPE: a full RL agent is too heavy for Pine; this reproduces the  │
// │  CORE idea — learn from outcomes, prefer recently-effective actions — as   │
// │  an online exponentially-weighted value table over each signal source.    │
// │                                                                            │
// │  ARROWS ARE MINIMAL: only filtered, high-conviction signals print arrows,  │
// │  and the strongest (both indicators agree + high value) get a slightly     │
// │  larger marker. Everything else stays clean.                              │
// └──────────────────────────────────────────────────────────────────────────┘

indicator("AetherEdge - RL Momentum Filter", "AE-RLMF", overlay = true,
     max_labels_count = 200)


// ============================================================================
//  ░░ INPUTS ░░
// ============================================================================
gM = "▓ MOMENTUM SOURCES ▓"
mc_fastInput  = input.int(12, "MACD Fast", minval = 2, maxval = 100, group = gM)
mc_slowInput  = input.int(26, "MACD Slow", minval = 2, maxval = 200, group = gM)
mc_sigInput   = input.int(9,  "MACD Signal", minval = 1, maxval = 50, group = gM)
mo_lenInput   = input.int(10, "Momentum Length", minval = 2, maxval = 100, group = gM)

gR = "▓ RL REWARD FILTER ▓"
rl_enableInput= input.bool(true, "Enable RL Filter", group = gR,
     tooltip = "Suppress signals from a source while its recent performance is poor.")
rl_horizonInp = input.int(8, "Outcome Horizon (bars)", minval = 2, maxval = 50, group = gR,
     tooltip = "Bars ahead used to score whether a signal actually paid off.")
rl_rewardInp  = input.float(1.0, "Win Reward Threshold (ATR)", minval = 0.2, maxval = 5.0, step = 0.1, group = gR,
     tooltip = "Move in the signal direction within the horizon, in ATRs, that counts as a win.")
rl_rateInput  = input.float(0.2, "Learning Rate (recency)", minval = 0.05, maxval = 0.8, step = 0.05, group = gR,
     tooltip = "How heavily recent outcomes outweigh older ones. Higher = more responsive to current streaks.")
rl_thrInput   = input.float(0.45, "Pass Threshold", minval = 0.0, maxval = 1.0, step = 0.05, group = gR,
     tooltip = "A source must have a value above this for its signals to print. Higher = stricter filter, fewer signals.")

gV = "▓ VISUALS ▓"
vi_themeInput = input.string("Emerald / Ruby", "Palette",
     options = ["Emerald / Ruby", "Spectral", "Mint / Coral"], group = gV)
vi_showAgree  = input.bool(true, "Highlight Agreement (both indicators)", group = gV)


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
clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))


// ============================================================================
//  ░░ SIGNAL SOURCES ░░
// ============================================================================
atr = ta.atr(14)

// MACD signal: histogram zero-cross direction (classic).
[macdLine, sigLine, hist] = ta.macd(close, mc_fastInput, mc_slowInput, mc_sigInput)
macdBuyRaw  = ta.crossover(hist, 0)
macdSellRaw = ta.crossunder(hist, 0)

// Momentum signal: rate-of-change zero-cross direction.
mom = close - close[mo_lenInput]
momBuyRaw  = ta.crossover(mom, 0)
momSellRaw = ta.crossunder(mom, 0)


// ============================================================================
//  ░░ RL VALUE TABLE — exponential reward tracking per source ░░
//  qMacd / qMom in [0,1], starting neutral 0.5. Updated after horizon resolves
//  whether the signal actually moved price in its direction by reward threshold.
// ============================================================================
var float qMacd = 0.5
var float qMom  = 0.5

// Pending samples per source: feature snapshot (dir + price + age).
var int[]   pmDir = array.new<int>(0)     // +1 buy, -1 sell
var float[] pmPx  = array.new<float>(0)
var int[]   pmAge = array.new<int>(0)
var int[]   pmSrc = array.new<int>(0)     // 0 = MACD, 1 = Momentum

// Recent hit buffers (last 50) for displayable streak accuracy.
var float[] hitMacd = array.new<float>(0)
var float[] hitMom  = array.new<float>(0)

// Arm pending samples when a RAW signal fires.
if barstate.isconfirmed
    if macdBuyRaw
        array.push(pmDir, 1)
        array.push(pmPx, close)
        array.push(pmAge, 0)
        array.push(pmSrc, 0)
    if macdSellRaw
        array.push(pmDir, -1)
        array.push(pmPx, close)
        array.push(pmAge, 0)
        array.push(pmSrc, 0)
    if momBuyRaw
        array.push(pmDir, 1)
        array.push(pmPx, close)
        array.push(pmAge, 0)
        array.push(pmSrc, 1)
    if momSellRaw
        array.push(pmDir, -1)
        array.push(pmPx, close)
        array.push(pmAge, 0)
        array.push(pmSrc, 1)

// Age & resolve pending samples after the horizon.
if barstate.isconfirmed and array.size(pmDir) > 0
    i = array.size(pmDir) - 1
    while i >= 0
        age = array.get(pmAge, i) + 1
        array.set(pmAge, i, age)
        if age >= rl_horizonInp
            dir = array.get(pmDir, i)
            px0 = array.get(pmPx, i)
            src = array.get(pmSrc, i)
            // Did price move enough in the signal direction over horizon?
            moveDir = dir > 0 ? (close - px0) : (px0 - close)
            won = moveDir >= rl_rewardInp * atr ? 1.0 : 0.0
            if src == 0
                qMacd := clamp(qMacd + rl_rateInput * (won - qMacd), 0.0, 1.0)
                array.push(hitMacd, won)
                if array.size(hitMacd) > 50
                    array.shift(hitMacd)
            else
                qMom  := clamp(qMom  + rl_rateInput * (won - qMom),  0.0, 1.0)
                array.push(hitMom,  won)
                if array.size(hitMom) > 50
                    array.shift(hitMom)
            array.remove(pmDir, i)
            array.remove(pmPx, i)
            array.remove(pmAge, i)
            array.remove(pmSrc, i)
        i -= 1


// ============================================================================
//  ░░ FILTERED SIGNALS ░░
//  A source's raw signal only passes if its Q-value is above the threshold.
//  Agreement = both pass on the same bar in the same direction.
// ============================================================================
passMacd = not rl_enableInput or qMacd >= rl_thrInput
passMom  = not rl_enableInput or qMom  >= rl_thrInput

macdBuy  = macdBuyRaw  and passMacd
macdSell = macdSellRaw and passMacd
momBuy   = momBuyRaw   and passMom
momSell  = momSellRaw  and passMom

agreeBuy  = vi_showAgree and macdBuy  and momBuy
agreeSell = vi_showAgree and macdSell and momSell

// Single-source filtered signals (only printed if NOT also an agreement).
soloBuy   = (macdBuy  or momBuy ) and not agreeBuy
soloSell  = (macdSell or momSell) and not agreeSell


// ============================================================================
//  ░░ MINIMAL ARROW MARKERS ░░
//  Solo filtered = tiny triangle. Agreement = small labeled bubble.
// ============================================================================
plotshape(soloBuy,   title = "BUY (filtered)",  style = shape.triangleup,   location = location.belowbar, color = color.new(cBuy,  20), size = size.tiny)
plotshape(soloSell,  title = "SELL (filtered)", style = shape.triangledown, location = location.abovebar, color = color.new(cSell, 20), size = size.tiny)
plotshape(agreeBuy,  title = "BUY (agreement)",  style = shape.labelup,   location = location.belowbar, color = cBuy,  textcolor = #04140f, text = "BUY",  size = size.small)
plotshape(agreeSell, title = "SELL (agreement)", style = shape.labeldown, location = location.abovebar, color = cSell, textcolor = #1a0509, text = "SELL", size = size.small)


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
if na(hud)
    hud := table.new(position.top_right, 2, 7, bgcolor = cPanel,
         border_color = color.new(cAcc, 60), border_width = 1, frame_color = color.new(cAcc, 40), frame_width = 1)

if barstate.islast
    macdAcc = array.size(hitMacd) > 0 ? array.avg(hitMacd) * 100.0 : 50.0
    momAcc  = array.size(hitMom)  > 0 ? array.avg(hitMom)  * 100.0 : 50.0
    bestSrc = qMacd > qMom ? "MACD" : qMom > qMacd ? "Momentum" : "tied"

    table.cell(hud, 0, 0, "RL MOMENTUM FILTER", text_color = cAcc, text_size = size.normal, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 0, rl_enableInput ? "filter on" : "filter OFF", text_color = cTxtD, text_size = size.normal, bgcolor = cPanelHd, text_halign = text.align_right)

    table.cell(hud, 0, 1, "MACD value", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 1, bar10(qMacd) + "  " + str.tostring(qMacd * 100, "#") + "%", text_color = passMacd ? cBuy : cSell, text_size = size.normal, text_halign = text.align_right)

    table.cell(hud, 0, 2, "MACD recent acc", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 2, str.tostring(macdAcc, "#") + "%  (" + str.tostring(array.size(hitMacd)) + ")", text_color = macdAcc > 55 ? cBuy : macdAcc < 45 ? cSell : cTxt, text_size = size.normal, text_halign = text.align_right)

    table.cell(hud, 0, 3, "Momentum value", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 3, bar10(qMom) + "  " + str.tostring(qMom * 100, "#") + "%", text_color = passMom ? cBuy : cSell, text_size = size.normal, text_halign = text.align_right)

    table.cell(hud, 0, 4, "Mom recent acc", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 4, str.tostring(momAcc, "#") + "%  (" + str.tostring(array.size(hitMom)) + ")", text_color = momAcc > 55 ? cBuy : momAcc < 45 ? cSell : cTxt, text_size = size.normal, text_halign = text.align_right)

    table.cell(hud, 0, 5, "best source", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 5, bestSrc, text_color = cAcc, text_size = size.normal, text_halign = text.align_right)

    table.cell(hud, 0, 6, "pass threshold", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 6, str.tostring(rl_thrInput, "#.00"), text_color = cTxt, text_size = size.normal, text_halign = text.align_right)


// ============================================================================
//  ░░ ALERTS ░░
// ============================================================================
alertcondition(agreeBuy,  "Agreement BUY",  "AE-RLMF: MACD & Momentum agree (BUY)")
alertcondition(agreeSell, "Agreement SELL", "AE-RLMF: MACD & Momentum agree (SELL)")
alertcondition(soloBuy,   "Filtered BUY",   "AE-RLMF: filtered BUY signal")
alertcondition(soloSell,  "Filtered SELL",  "AE-RLMF: filtered SELL signal")
````
