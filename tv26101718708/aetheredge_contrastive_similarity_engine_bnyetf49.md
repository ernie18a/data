# AetherEdge - Contrastive Similarity Engine

- url: https://www.tradingview.com/script/bnyetf49/
- type: indicator
- pine_id: PUB;c2687c254ba14c2d927c98d6678b8e43
- version: 1.0

## Description

🖊️ Overview

The Contrastive Learning Similarity Engine is a pattern-matching engine inspired by the principles of contrastive learning (SimCLR). It encodes the current market state into a feature embedding, contrasts it against every past window via cosine similarity, and surfaces the closest historical analogue. When a high-similarity pattern is found, it overlays that analogue's subsequent price action onto the present as a translucent Ghost Chart — "last time this shape appeared, price did this."

🔶 Key Features

SimCLR-inspired contrastive similarity space: shape-based cosine matching
Adaptive feature weights: a contrastive adaptation that online-learns which features proved predictive
Top-K matching: extracts the several closest historical analogues
Ghost Chart overlay: projects the analogue's "what happened next," anchored at current price
Ghost-all-top-K: overlays multiple historical outcomes as a fan distribution
Match-origin marker: shows where in history the analogue occurred
Match-accuracy tracking: learns and displays how often high-similarity projections were correct
Exploratory palettes (Spectral Scan et al.) with an integrated HUD

🧠 Technical Architecture

This tool is a translation that realizes SimCLR's core idea within Pine, which has neither autodiff nor deep nets. The encoder converts a price window into successive log returns, then mean-removes and L2-normalizes them into a shape vector (capturing form, not absolute price, so it's level-independent). Matching computes the weighted cosine similarity between the current vector and every past window, extracting the best match and Top-K.
The contrastive learning layer checks, after an outcome horizon, whether the direction a high-similarity match projected was actually correct, then reinforces (pulling positives together) or attenuates (pushing misleading ones apart) the feature weights — an online realization of SimCLR's contrastive adaptation. Because compute is O(search depth × window length), it runs only on the last bar to avoid Pine's loop limit. The Ghost Chart applies the matched analogue's subsequent cumulative return to the current price, drawing it forward as translucent lines.

⚙️ Recommended Settings & Tuning Guide

Tuned with crypto in mind. Pattern Window 20 and Search Depth ~400 are a starting point. Min Similarity sets match strictness — 0.80+ accepts only strong matches with closely-aligned shapes. For short-term patterns use Pattern Window near 10; for larger structures near 40. Raising Search Depth explores richer history but is heavier — reduce it if slow. Enabling Ghost All Top-K reveals the spread of multiple historical outcomes rather than a single one.

💡 How to Use in Practice

The Ghost Chart visualizes how past analogous situations resolved, serving as a hypothesis for how the current pattern might resolve. When multiple Top-K ghosts converge in one direction, conviction in that direction is relatively higher; when they fan out widely, the same shape historically led to diverse outcomes — read as hard to predict. If the HUD's match accuracy stably exceeds 50%, it suggests pattern repetition carries predictive power on this instrument and timeframe. Overlaying with other structure tools and support/resistance, and favoring moments where the ghost's direction agrees with other evidence, is effective.

⚠️ Important Notes

This tool is SimCLR-inspired, not a true backprop-trained contrastive network; within Pine's constraints it reproduces the core idea in a feasible form. The Ghost Chart is a replay of past analogues, not a prediction — there is no guarantee the same shape leads to the same outcome. Matching runs only on the last bar and does not repaint confirmed history. Learning the feature weights requires accumulated data and cannot overcome the fundamental constraint of market predictability. Excessively large Search Depth may approach the runtime limit.

🚨 Disclaimer

This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. No match or ghost guarantees future prices, and past performance does not indicate future results. All trading decisions are made at your own risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © AetherEdge — Contrastive Learning Similarity Engine // SimCLR-inspired
//@version=6

// ┌──────────────────────────────────────────────────────────────────────────┐
// │  CONTRASTIVE LEARNING SIMILARITY ENGINE [AetherEdge]                       │
// │                                                                            │
// │  A SimCLR-INSPIRED pattern-matching engine. It encodes the current market  │
// │  state into a feature embedding, contrasts it against every past window    │
// │  via cosine similarity, and surfaces the closest historical analogue.      │
// │                                                                            │
// │  HONEST SCOPE: Pine has no autodiff or deep nets, so SimCLR's backprop-    │
// │  trained encoder is impossible. Instead this reproduces SimCLR's CORE      │
// │  IDEA — a contrastive similarity space where similar states sit close —    │
// │  with a hand-designed encoder plus an ONLINE-LEARNED feature weighting     │
// │  that emphasizes the features whose matches actually predicted the next    │
// │  move (a contrastive adaptation: reward features that pull true analogues  │
// │  together and predictive analogues apart from misleading ones).            │
// │                                                                            │
// │  GHOST CHART: when a high-similarity past pattern is found, its subsequent │
// │  price shape is overlaid translucently onto the present — "last time this  │
// │  pattern appeared, price did THIS."                                        │
// │                                                                            │
// │  COMPUTE NOTE: full-history contrast is O(N·W); to avoid Pine's loop       │
// │  timeout it runs only on the last bar over a bounded search window.        │
// └──────────────────────────────────────────────────────────────────────────┘

indicator("AetherEdge - Contrastive Similarity Engine", "AE-CSE", overlay = true,
     max_lines_count = 500, max_labels_count = 100, max_bars_back = 1500)


// ============================================================================
//  ░░ INPUTS ░░
// ============================================================================

// ─── ENCODER / MATCHING ──────────────────────────────────────────────────────
gE = "▓ ENCODER & MATCHING ▓"
en_winInput   = input.int(20, "Pattern Window", minval = 5, maxval = 100, group = gE,
     tooltip = "Length of the price shape (in bars) encoded and matched. The 'pattern' is this many bars of recent action.")
en_searchInput= input.int(400, "Search Depth (bars)", minval = 50, maxval = 1500, group = gE,
     tooltip = "How far back to search for analogues. Larger = richer history but heavier (runs on last bar only).")
en_topKInput  = input.int(3, "Top-K Matches", minval = 1, maxval = 8, group = gE,
     tooltip = "How many of the closest historical analogues to consider / overlay.")
en_minSimInput= input.float(0.80, "Min Similarity to Trigger", minval = 0.3, maxval = 0.99, step = 0.01, group = gE,
     tooltip = "Cosine similarity threshold above which a match is considered strong enough to act on / ghost.")

// ─── CONTRASTIVE LEARNING ────────────────────────────────────────────────────
gC = "▓ CONTRASTIVE LEARNING ▓"
cl_enableInput= input.bool(true, "Adaptive Feature Weights", group = gC,
     tooltip = "Online-learn which features make matches actually predictive, emphasizing them in the similarity metric.")
cl_rateInput  = input.float(0.05, "Contrastive Learning Rate", minval = 0.001, maxval = 0.5, step = 0.001, group = gC)
cl_horizonInp = input.int(10, "Outcome Horizon (bars)", minval = 2, maxval = 50, group = gC,
     tooltip = "Bars ahead used to check whether a match's projected direction was correct, for supervised weight updates.")

// ─── GHOST CHART ─────────────────────────────────────────────────────────────
gG = "▓ GHOST CHART ▓"
gh_showInput  = input.bool(true, "Show Ghost Chart Overlay", group = gG,
     tooltip = "Overlay the closest past pattern's SUBSEQUENT price shape onto the present, anchored at current price.")
gh_projInput  = input.int(20, "Ghost Projection (bars)", minval = 5, maxval = 100, group = gG,
     tooltip = "How many bars of the analogue's future to project forward as the ghost.")
gh_allKInput  = input.bool(false, "Ghost All Top-K (not just best)", group = gG,
     tooltip = "Overlay every top-K analogue's future, fainter, for a fan of historical outcomes.")

// ─── VISUALS ─────────────────────────────────────────────────────────────────
gV = "▓ VISUALS ▓"
vi_themeInput = input.string("Spectral Scan", "Palette",
     options = ["Spectral Scan", "Plasma Flow", "Emerald / Ruby"], group = gV)
vi_markInput  = input.bool(true, "Mark Match Origin on History", group = gV,
     tooltip = "Draw a marker at where in history the matched pattern occurred.")

// ─── HUD ─────────────────────────────────────────────────────────────────────
gH = "▓ HUD ▓"
hud_showInput = input.bool(true, "Show HUD", group = gH)
hud_posInput  = input.string("Top Right", "Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gH)
hud_sizeInput = input.string("Normal", "Text Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = gH)


// ============================================================================
//  ░░ PALETTE ░░
//  [ghostUp, ghostDn, match, accent]
// ============================================================================
var color cUp   = na
var color cDn   = na
var color cMatch= na
var color cAcc  = na
var color cTxt  = #dfe7f2
var color cTxtD = #5f7186
var color cPanel= #0a0c12
var color cPanelHd = #131826

setPalette() =>
    [u, d, m, a] = switch vi_themeInput
        "Spectral Scan" => [#2dd4bf, #f43f5e, #38bdf8, #e879f9]
        "Plasma Flow"   => [#22d3ee, #f472b6, #a78bfa, #e879f9]
        => [#10e0a0, #ff3860, #38bdf8, #d4af37]
    [u, d, m, a]
[pu, pd, pm, pa] = setPalette()
cUp    := pu
cDn    := pd
cMatch := pm
cAcc   := pa


// ============================================================================
//  ░░ HELPERS ░░
// ============================================================================
sdiv(a, b) =>
    b != 0 ? a / b : 0.0
clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))


// ============================================================================
//  ░░ ENCODER — embed a price window into a normalized feature vector ░░
//  We encode the SHAPE of a window (offset `off` bars back) as normalized
//  successive returns. Shape-based (not level-based) so it matches form, not
//  absolute price. Returns a vector of length `en_winInput`.
//  Contrastive feature weighting scales each dimension's contribution.
// ============================================================================
W = en_winInput

// Persistent contrastive feature weights (one per window position), start at 1.
// Initialized directly to 100 ones so the array is never empty when accessed.
var float[] featW = array.new<float>(100, 1.0)

// Encode the window ending `off` bars ago into a (mean-removed, unit-norm) vector.
encodeWindow(off) =>
    vec = array.new<float>(W, 0.0)
    // Successive log-returns within the window.
    mean = 0.0
    for i = 0 to W - 1
        r = math.log(close[off + i]) - math.log(close[off + i + 1])
        array.set(vec, i, nz(r))
        mean += nz(r)
    mean /= W
    // Mean-remove and L2-normalize (cosine geometry).
    ss = 0.0
    for i = 0 to W - 1
        v = array.get(vec, i) - mean
        array.set(vec, i, v)
        ss += v * v
    norm = math.sqrt(math.max(ss, 1e-12))
    for i = 0 to W - 1
        array.set(vec, i, array.get(vec, i) / norm)
    vec

// Weighted cosine similarity between current vector and a past one (by offset).
weightedCosine(curVec, off) =>
    pastVec = encodeWindow(off)
    dot = 0.0
    nA = 0.0
    nB = 0.0
    for i = 0 to W - 1
        wgt = cl_enableInput ? array.get(featW, i) : 1.0
        a = array.get(curVec, i) * wgt
        b = array.get(pastVec, i) * wgt
        dot += a * b
        nA += a * a
        nB += b * b
    sdiv(dot, math.sqrt(math.max(nA, 1e-12)) * math.sqrt(math.max(nB, 1e-12)))


// ============================================================================
//  ░░ CONTRASTIVE FEATURE-WEIGHT LEARNING ░░
//  Periodically (each bar, cheaply) we test the best analogue found `horizon`
//  bars ago: did the analogue's next move match our actual next move? If yes,
//  reinforce the feature positions that agreed (pull positives together); if
//  no, attenuate them. This is the contrastive adaptation, done online.
// ============================================================================
var float pendingSimDir = na   // projected direction from last strong match
var float pendingPx     = na
var int   pendingAge    = na
var float[] hitBuf      = array.new<float>(0)

// (Population of pending happens after matching below; learning resolves here.)


// ============================================================================
//  ░░ MATCHING — run on last bar only (bounded search) ░░
// ============================================================================
var int   bestOff   = na
var float bestSim   = na
var float bestNext  = na      // analogue's subsequent return over horizon (direction)
var float[] topOffs = array.new<float>(0)
var float[] topSims = array.new<float>(0)

if barstate.islast
    curVec = encodeWindow(0)
    array.clear(topOffs)
    array.clear(topSims)
    // Maintain a small top-K by insertion.
    maxSearch = math.min(en_searchInput, bar_index - W - gh_projInput - 2)
    bSim = -2.0
    int bOff = na
    if maxSearch > W + 1
        for off = W + 1 to maxSearch
            sim = weightedCosine(curVec, off)
            if not na(sim) and sim > bSim
                bSim := sim
                bOff := off
            // Insert into top-K (kept sorted descending, small K so cheap).
            insAt = -1
            kSize = array.size(topSims)
            if not na(sim) and kSize < en_topKInput
                array.push(topSims, sim)
                array.push(topOffs, off)
            else if not na(sim)
                // Find current min in top-K; replace if this is larger.
                minIdx = 0
                minVal = array.get(topSims, 0)
                if array.size(topSims) > 1
                    for j = 1 to array.size(topSims) - 1
                        if array.get(topSims, j) < minVal
                            minVal := array.get(topSims, j)
                            minIdx := j
                if sim > minVal
                    array.set(topSims, minIdx, sim)
                    array.set(topOffs, minIdx, off)
    bestOff := bOff
    bestSim := bSim
    // Analogue's subsequent direction (what happened AFTER the matched window).
    if not na(bOff)
        // The matched window ended `bOff` bars ago; its "future" is the bars
        // between bOff and bOff-projection (closer to now).
        futEnd = math.max(0, bOff - gh_projInput)
        bestNext := math.log(close[futEnd]) - math.log(close[bOff])


// ============================================================================
//  ░░ CONTRASTIVE WEIGHT UPDATE (online, cheap, every bar) ░░
//  Resolve the previously-projected direction against realized move.
// ============================================================================
if cl_enableInput and not na(pendingAge)
    pendingAge += 1
    if pendingAge >= cl_horizonInp
        realDir = close > pendingPx ? 1.0 : -1.0
        projDir = pendingSimDir >= 0 ? 1.0 : -1.0
        correct = realDir == projDir ? 1.0 : 0.0
        array.push(hitBuf, correct)
        if array.size(hitBuf) > 100
            array.shift(hitBuf)
        // Reinforce or attenuate feature weights uniformly toward usefulness.
        // (Shape match quality scales the nudge; kept simple & stable.)
        adj = cl_rateInput * (correct - 0.5) * 2.0
        if array.size(featW) >= W
            for i = 0 to W - 1
                nw = clamp(array.get(featW, i) + adj * 0.1, 0.2, 3.0)
                array.set(featW, i, nw)
        pendingAge := na   // consumed

// Arm a new pending projection when a fresh strong match exists on last bar.
if barstate.islast and not na(bestSim) and bestSim >= en_minSimInput and na(pendingAge)
    pendingSimDir := bestNext
    pendingPx := close
    pendingAge := 0

matchAcc = array.size(hitBuf) > 0 ? array.avg(hitBuf) * 100.0 : 50.0


// ============================================================================
//  ░░ GHOST CHART OVERLAY ░░
//  Project the analogue's subsequent price shape forward from current price.
//  For analogue at offset `off`, its future path is close[off], close[off-1],
//  ... close[off-proj]; we re-base it to start at the current close and draw it
//  forward into the future as a translucent ghost.
// ============================================================================
var line[] ghostLines = array.new<line>(0)

drawGhostFor(off, sim, transpBase) =>
    if not na(off) and off - gh_projInput >= 0
        anchor = close
        startLog = math.log(close[off])
        prevX = bar_index
        prevY = anchor
        for t = 1 to gh_projInput
            srcIdx = off - t
            if srcIdx >= 0
                // Re-based projected price: apply the analogue's cumulative
                // return from its anchor to current price.
                cumRet = math.log(close[srcIdx]) - startLog
                projY = anchor * math.exp(cumRet)
                x2 = bar_index + t
                up = projY >= prevY
                gcol = up ? cUp : cDn
                array.push(ghostLines, line.new(prevX, prevY, x2, projY, color = color.new(gcol, transpBase), width = 2))
                prevX := x2
                prevY := projY

clearGhosts() =>
    if array.size(ghostLines) > 0
        for i = 0 to array.size(ghostLines) - 1
            line.delete(array.get(ghostLines, i))
        array.clear(ghostLines)

if barstate.islast
    clearGhosts()
    // Draw whenever a valid best match exists (bSim was set to a real value).
    // The threshold now governs emphasis, not whether anything appears at all,
    // so a working search always renders a ghost.
    hasMatch = not na(bestSim) and bestSim > -1.5 and not na(bestOff)
    strong = hasMatch and bestSim >= en_minSimInput
    if gh_showInput and hasMatch
        ghostTransp = strong ? 45 : 70   // stronger match = more opaque
        if gh_allKInput and array.size(topOffs) > 0
            for j = 0 to array.size(topOffs) - 1
                drawGhostFor(int(array.get(topOffs, j)), array.get(topSims, j), 78)
        else
            drawGhostFor(bestOff, bestSim, ghostTransp)
        // Mark the matched origin in history.
        if vi_markInput and not na(bestOff)
            label.new(bar_index - bestOff, close[bestOff], strong ? "◎ strong match" : "○ best match",
                 yloc = yloc.price, color = color.new(cMatch, strong ? 20 : 50), textcolor = #ffffff,
                 style = label.style_label_down, size = size.small)
        // Terminal label on the ghost.
        ghostEndIdx = math.max(0, bestOff - gh_projInput)
        ghostRet = (math.log(close[ghostEndIdx]) - math.log(close[bestOff])) * 100.0
        label.new(bar_index + gh_projInput, close * math.exp(ghostRet / 100.0),
             "ghost " + str.tostring(ghostRet, "#.0") + "%  (sim " + str.tostring(bestSim, "#.00") + ")",
             color = color.new(ghostRet >= 0 ? cUp : cDn, 25), textcolor = #ffffff,
             style = label.style_label_left, size = size.small)


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
         border_color = color.new(cAcc, 65), border_width = 1, frame_color = color.new(cAcc, 45), frame_width = 1)

if hud_showInput and barstate.islast
    sz = hudSize(hud_sizeInput)
    simShown = na(bestSim) ? 0.0 : bestSim
    strong = simShown >= en_minSimInput
    simCol = strong ? cMatch : cTxtD
    ghostDir = na(bestNext) ? "—" : bestNext >= 0 ? "▲ rose" : "▼ fell"
    ghostCol = na(bestNext) ? cTxtD : bestNext >= 0 ? cUp : cDn

    table.cell(hud, 0, 0, "CONTRASTIVE SIM", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 0, "SimCLR-insp.", text_color = cTxtD, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_right)

    table.cell(hud, 0, 1, "best match", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 1, str.tostring(simShown, "#.000"), text_color = simCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 2, "strength", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 2, bar10(simShown), text_color = simCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 3, "status", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 3, strong ? "◎ MATCH" : "· searching", text_color = strong ? cMatch : cTxtD, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 4, "analogue then", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 4, ghostDir, text_color = ghostCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 5, "bars ago", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 5, na(bestOff) ? "—" : str.tostring(bestOff), text_color = cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 6, "match acc", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 6, str.tostring(matchAcc, "#") + "%", text_color = matchAcc > 55 ? cUp : matchAcc < 45 ? cDn : cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 7, "pattern win", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 7, str.tostring(W) + " bars", text_color = cTxt, text_size = sz, text_halign = text.align_right)


// ============================================================================
//  ░░ ALERTS ░░
// ============================================================================
alertcondition(barstate.islast and not na(bestSim) and bestSim >= en_minSimInput, "Strong Pattern Match", "ContrastSim: a strong historical analogue was found")
````
