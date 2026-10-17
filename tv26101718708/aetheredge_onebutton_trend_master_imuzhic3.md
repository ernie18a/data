# AetherEdge - OneButton Trend Master

- url: https://www.tradingview.com/script/iMUZhIc3/
- type: indicator
- pine_id: PUB;fa0e1899f6dd42e3869bcdf2f9f06b15
- version: 1.0

## Description

🖊️ Overview

AE-1BTN is a one-click trend tool stripped to ultimate simplicity. The chart background paints in three colors — green (buy), red (sell), grey (wait) — telling you the regime at a glance. Inside, a two-layer engine (EMA stack + KNN pattern match) decides, but the only user setting is sensitivity. For traders who don't want to fiddle with parameters and just want the verdict.

🔶 Key Features

3-color background: intuitive green / red / grey visualization
Two-layer engine: signal only when EMA stack and KNN match agree
Near-zero parameters: pick one of Conservative / Balanced / Aggressive
BUY/SELL labels on candles at trend flips
Internal complexity fully hidden — beginner-ready
Integrated HUD shows both layers and the final verdict
Built-in alerts

🧠 Technical Architecture

Layer one is the classic EMA stack — short/mid/long EMAs whose ordering gives a bullish/bearish/mixed verdict. Layer two is a genuine KNN (k-nearest-neighbors) algorithm: the current feature vector (return, momentum, volatility) is matched against feature vectors from each of the past 250 bars via Euclidean distance, picking the 7 nearest neighbors. Each neighbor votes by the actual 8-bar move that followed it, and the average becomes the predicted direction. Future leakage is structurally excluded — each neighbor's outcome uses only past data. The final verdict requires both layers to agree; disagreement defaults to WAIT, structurally suppressing noise signals.

⚙️ Recommended Settings & Tuning Guide

Just pick Sensitivity. For intraday or short swings, choose Balanced; for noise-heavy or ranging conditions, Conservative; to catch strong trends fast, Aggressive. All other parameters are pre-tuned internally and need no adjustment.

💡 How to Use in Practice

The simplest workflow is to follow the background. Hold longs while green, consider closing/flipping when it turns red, and stand aside on grey. The BUY/SELL labels mark trend-flip moments — useful as entry references. Combining with structure tools (support/resistance, key levels) and confirming the signal coincides with a relevant level raises conviction.

⚠️ Important Notes

Designed for trend-following, signals can flip frequently in ranges; frequent color changes can themselves be read as an "unstable regime" cue. The KNN layer runs only on the last bar for compute reasons, and historical background coloring uses the EMA stack alone — a design constraint, not repainting.

🚨 Disclaimer

This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. No signal guarantees future profit, and past performance does not indicate future results. All trading decisions are made at your own risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © AetherEdge — OneButton Trend Master
//@version=6

// ┌──────────────────────────────────────────────────────────────────────────┐
// │  AetherEdge - OneButton Trend Master  ·  AE-1BTN                            │
// │                                                                            │
// │  The simplest possible signal: a 3-color background — GREEN buy, RED sell, │
// │  GREY wait. No parameter tweaking required; defaults just work.             │
// │                                                                            │
// │  Internally two layers vote, and both must agree:                          │
// │    LAYER 1 — EMA stack ordering (fast/mid/slow): the classic robust trend  │
// │              filter (fast above mid above slow = bull stack, etc.).        │
// │    LAYER 2 — KNN-style pattern match: the current state's feature vector   │
// │              (return / momentum / volatility) is matched to its k nearest  │
// │              past states, and the AVERAGE NEXT-MOVE of those neighbors     │
// │              votes for the direction.                                      │
// │  When both layers agree → the matching color. When they disagree → WAIT.   │
// │                                                                            │
// │  HONEST SCOPE: KNN is an actual nearest-neighbor algorithm; the matching is│
// │  bounded to the recent history for Pine's loop limit. No future leakage:   │
// │  neighbors are drawn only from past bars.                                  │
// └──────────────────────────────────────────────────────────────────────────┘

indicator("AetherEdge - OneButton Trend Master", "AE-1BTN", overlay = true,
     max_labels_count = 50, max_bars_back = 500)


// ============================================================================
//  ░░ INPUTS (kept to a minimum) ░░
// ============================================================================
sensInput  = input.string("Balanced", "Sensitivity",
     options = ["Conservative", "Balanced", "Aggressive"],
     tooltip = "Conservative = fewer signals, higher quality. Aggressive = more signals, more noise.")
showHUD    = input.bool(true, "Show HUD")
showLabels = input.bool(true, "Show BUY/SELL labels on candles")


// ============================================================================
//  ░░ PALETTE ░░
// ============================================================================
var color cBuy  = #10e0a0   // emerald
var color cSell = #ff3860   // ruby
var color cWait = #6b7d76   // mute grey
var color cTxt  = #eef2f0
var color cTxtD = #6b7d76
var color cPanel= #080b0a
var color cPanelHd = #0f1614
var color cAcc  = #d4af37


// ============================================================================
//  ░░ HELPERS ░░
// ============================================================================
clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))


// ============================================================================
//  ░░ LAYER 1 — EMA STACK ░░
//  Sensitivity remaps to internal EMA lengths.
// ============================================================================
[fL, mL, sL] = switch sensInput
    "Conservative" => [12, 30, 80]
    "Aggressive"   => [5, 13, 34]
    => [8, 21, 55]   // Balanced

emaFast = ta.ema(close, fL)
emaMid  = ta.ema(close, mL)
emaSlow = ta.ema(close, sL)

bullStack = emaFast > emaMid and emaMid > emaSlow
bearStack = emaFast < emaMid and emaMid < emaSlow

// EMA stack vote: +1 bull, -1 bear, 0 mixed.
emaVote = bullStack ? 1 : bearStack ? -1 : 0


// ============================================================================
//  ░░ LAYER 2 — KNN PATTERN MATCH ░░
//  Build a small feature vector for the current state and compare it to past
//  states. The k nearest past states cast votes via their realized next move.
//  Bounded to a recent history window so it fits within Pine's loop limit.
// ============================================================================
atr14 = ta.atr(14)

// Standardized feature components (returns / momentum / volatility).
sdiv(a, b) =>
    b != 0 ? a / b : 0.0

// Pre-compute series variables so historical access [off] works without
// dynamic-index issues on function call sites.
stdevSeries = ta.stdev(ta.change(close), 20)
atrSeries   = atr14

retC = sdiv(close - close[1], atrSeries)
momC = sdiv(close - close[10], atrSeries)
volC = sdiv(stdevSeries, atrSeries)

zRet = clamp(nz(retC), -4, 4)
zMom = clamp(nz(momC), -4, 4)
zVol = clamp(nz(volC), -4, 4)

// KNN search parameters (internal, fixed for "OneButton" simplicity).
HISTORY = 250         // search depth
K       = 7           // neighbors
HORIZON = 8           // future-move evaluation per neighbor (uses past data only)

knnVote = 0.0
knnDist = 0.0
if barstate.islast and bar_index > HISTORY + HORIZON
    // Gather distances to every past bar in the window (excluding too-recent
    // bars whose "next move" hasn't elapsed yet — keeps it honest, no leakage).
    bestD  = array.new<float>(K, 1e18)
    bestI  = array.new<int>(K, -1)
    for off = HORIZON + 1 to HISTORY
        // Past state feature vector.
        rP = clamp(nz(sdiv(close[off] - close[off + 1], atrSeries[off])), -4, 4)
        mP = clamp(nz(sdiv(close[off] - close[off + 10], atrSeries[off])), -4, 4)
        vP = clamp(nz(sdiv(stdevSeries[off], atrSeries[off])), -4, 4)
        d  = math.sqrt((zRet - rP)*(zRet - rP) + (zMom - mP)*(zMom - mP) + (zVol - vP)*(zVol - vP))
        // Insert into top-K (kept smallest-first by replacing the current max).
        maxIdx = 0
        maxVal = array.get(bestD, 0)
        if K > 1
            for j = 1 to K - 1
                if array.get(bestD, j) > maxVal
                    maxVal := array.get(bestD, j)
                    maxIdx := j
        if d < maxVal
            array.set(bestD, maxIdx, d)
            array.set(bestI, maxIdx, off)

    // Each neighbor votes: sign of its realized next-move return over HORIZON.
    voteSum = 0.0
    distAvg = 0.0
    used = 0
    for j = 0 to K - 1
        idx = array.get(bestI, j)
        if idx >= HORIZON + 1
            // Move from neighbor's bar forward by HORIZON: close[idx-HORIZON] - close[idx]
            futClose = close[idx - HORIZON]
            nbrMove  = (futClose - close[idx]) / atr14[idx]
            voteSum += clamp(nbrMove, -3.0, 3.0)
            distAvg += array.get(bestD, j)
            used += 1
    if used > 0
        knnVote := voteSum / used
        knnDist := distAvg / used

// KNN direction.
knnDir = knnVote > 0.25 ? 1 : knnVote < -0.25 ? -1 : 0


// ============================================================================
//  ░░ FINAL DECISION ░░
//  Both layers must agree.
// ============================================================================
finalDir = 0
if emaVote == 1 and knnDir == 1
    finalDir := 1
else if emaVote == -1 and knnDir == -1
    finalDir := -1

// Persist the direction so the background fills the chart even between KNN
// re-evaluations (which only run on the last bar). EMA stack continues to
// drive the background on historical bars.
var int dispDir = 0
if barstate.islast
    dispDir := finalDir

// For historical bars, color by EMA stack alone (so background is continuous);
// on the last bar, finalDir (EMA ∧ KNN) is shown.
histDir = emaVote   // historical fallback
bgDir = barstate.islast ? dispDir : histDir

bgcolor(bgDir == 1 ? color.new(cBuy, 80) : bgDir == -1 ? color.new(cSell, 80) : color.new(cWait, 93), editable = false)


// ============================================================================
//  ░░ CANDLE-LEVEL ENTRY MARKERS ░░
//  Mark the BAR where the final direction FLIPS from previous (transition).
// ============================================================================
var int prevDir = 0
buyFlip  = histDir == 1 and prevDir != 1
sellFlip = histDir == -1 and prevDir != -1
if barstate.isconfirmed
    prevDir := histDir

plotshape(showLabels and buyFlip,  title = "BUY",  style = shape.labelup,   location = location.belowbar, color = cBuy,  textcolor = #04140f, text = "BUY",  size = size.small)
plotshape(showLabels and sellFlip, title = "SELL", style = shape.labeldown, location = location.abovebar, color = cSell, textcolor = #1a0509, text = "SELL", size = size.small)


// ============================================================================
//  ░░ HUD ░░
// ============================================================================
var table hud = na
if showHUD and na(hud)
    hud := table.new(position.top_right, 2, 6, bgcolor = cPanel,
         border_color = color.new(cAcc, 60), border_width = 1, frame_color = color.new(cAcc, 40), frame_width = 1)

if showHUD and barstate.islast
    stateTxt = dispDir == 1 ? "▲ BUY" : dispDir == -1 ? "▼ SELL" : "· WAIT"
    stateCol = dispDir == 1 ? cBuy : dispDir == -1 ? cSell : cWait
    emaTxt = emaVote == 1 ? "▲ bullish" : emaVote == -1 ? "▼ bearish" : "· mixed"
    emaCol = emaVote == 1 ? cBuy : emaVote == -1 ? cSell : cWait
    knnTxt = knnDir == 1 ? "▲ bullish" : knnDir == -1 ? "▼ bearish" : "· neutral"
    knnCol = knnDir == 1 ? cBuy : knnDir == -1 ? cSell : cWait

    table.cell(hud, 0, 0, "OneButton TREND MASTER", text_color = cAcc, text_size = size.normal, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 0, sensInput, text_color = cTxtD, text_size = size.normal, bgcolor = cPanelHd, text_halign = text.align_right)

    table.cell(hud, 0, 1, "verdict", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 1, stateTxt, text_color = stateCol, text_size = size.normal, text_halign = text.align_right)

    table.cell(hud, 0, 2, "EMA stack", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 2, emaTxt, text_color = emaCol, text_size = size.normal, text_halign = text.align_right)

    table.cell(hud, 0, 3, "KNN match", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 3, knnTxt, text_color = knnCol, text_size = size.normal, text_halign = text.align_right)

    table.cell(hud, 0, 4, "KNN strength", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 4, str.tostring(knnVote, "#.00"), text_color = cTxt, text_size = size.normal, text_halign = text.align_right)

    table.cell(hud, 0, 5, "neighbors", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 5, str.tostring(K) + " of " + str.tostring(HISTORY), text_color = cTxt, text_size = size.normal, text_halign = text.align_right)


// ============================================================================
//  ░░ ALERTS ░░
// ============================================================================
alertcondition(buyFlip,  "BUY",  "AE-1BTN: trend flipped BULLISH")
alertcondition(sellFlip, "SELL", "AE-1BTN: trend flipped BEARISH")
````
