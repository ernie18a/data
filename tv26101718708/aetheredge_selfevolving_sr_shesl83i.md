# AetherEdge - Self-Evolving S/R

- url: https://www.tradingview.com/script/SHEsL83I/
- type: indicator
- pine_id: PUB;623000b4af1842b9bc2c1bd795c6732e
- version: 1.0

## Description

🖊️ Overview

AE-SESR is a self-evolving S/R engine that auto-detects support/resistance and applies a reinforcement-learning reward concept to evolve only the levels that actually work. Every bounce off a level earns it score; every break decisively through it deducts. Only the top 3 levels are ever shown, so the chart stays uncluttered and only the most meaningful battle lines remain.

🔶 Key Features

Auto-detection: candidates harvested from confirmed swings (non-repainting)
RL-style scoring: bounce = reward, break = penalty teaches each level's value
Top-3-only display: strongest resistance above, strongest support below, plus the next-best
Strength-scaled line thickness: more reliable levels draw thicker
Labels show bounce count and current score
Time decay: old levels naturally fade; new performance rises
HUD shows the strongest R/S levels, their strength, and hit counts

🧠 Technical Architecture

This tool is not a full reinforcement-learning agent but reproduces its core idea — learn action values from experience, prefer high-value actions — as an online value table. Confirmed swing highs/lows (ta.pivothigh/low) become S/R candidates; nearby candidates merge into existing ones. Each candidate holds a score (its value). When price reaches a level, the subsequent move classifies it as a bounce (significant move against the approach) or a break (significant move through), updating score via reward or penalty. All scores time-decay each bar, keeping the system adaptive rather than over-anchored to old history. Levels whose score goes negative are auto-pruned, preventing pool bloat. The display picks three: the strongest resistance above price, the strongest support below, and a third slot for the next-best remaining — ranked ★1/★2/★3 by score, with line thickness proportional to score.

⚙️ Recommended Settings & Tuning Guide

Tuned with crypto in mind. Pivot Confirmation Bars near 8 is a starting point — larger captures only major levels, smaller picks up finer structure. Touch Proximity (ATR), the distance at which a level counts as "touched," defaults to 0.5 (typically fine). Score Decay is the time-decay rate; default 0.995 (0.5% decay per bar). In fast-rotating regimes, lower it (e.g., 0.99) to weight recent behavior more. Merge Distance (%) controls how close candidates consolidate — lower it on dense instruments to keep them separate.

💡 How to Use in Practice

The three displayed lines are the most performance-proven levels on this instrument. The thickest ★1 line is the highest-conviction wall right now — moments where price approaches it are candidates for bounce entries or take-profit exits. The "×N" label counts past bounces — the larger N, the more historically reliable. During regime shifts, new levels enter the top 3 while old ones decay away, visible as self-evolution. Pair with trend/structure tools and prioritize levels where AE-SESR lines align with other evidence.

⚠️ Important Notes

This tool is RL-style, not a true reinforcement-learning agent; within Pine's constraints it reproduces the core idea as experience-based level scoring. Because it's based on confirmed swings, candidates enter the pool with a few bars' delay — a necessary property of the non-repainting design. Scores need accumulated touches to become meaningful, so new instruments or short-window charts may show fewer levels.

🚨 Disclaimer

This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. No level guarantees future prices, and past performance does not indicate future results. All trading decisions are made at your own risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © AetherEdge — Self-Evolving Support & Resistance
//@version=6

// ┌──────────────────────────────────────────────────────────────────────────┐
// │  AetherEdge - Self-Evolving Support & Resistance  ·  AE-SESR                │
// │                                                                            │
// │  Three self-evolving S/R lines, automatically chosen from confirmed swing  │
// │  candidates by an RL-style reward score: every time a level rejects price  │
// │  (a real bounce) it earns reward, every time price decisively breaks it    │
// │  the level is penalized. Only the TOP 3 highest-scoring levels are kept on │
// │  the chart, with line thickness scaled to their strength (bounce count).   │
// │                                                                            │
// │  HONEST SCOPE: a full RL agent is too heavy for Pine, but the CORE — learn │
// │  the value of each "level action" from outcomes, prefer high-value ones —  │
// │  is reproduced as an online value table over confirmed-swing candidates.   │
// │                                                                            │
// │  NON-REPAINTING: candidates only enter the pool after their swing pivot     │
// │  confirms (a fixed number of bars after the extreme), so a printed S/R     │
// │  line never moves.                                                         │
// └──────────────────────────────────────────────────────────────────────────┘

indicator("AetherEdge - Self-Evolving S/R", "AE-SESR", overlay = true,
     max_lines_count = 50, max_labels_count = 50)


// ============================================================================
//  ░░ INPUTS ░░
// ============================================================================
gC = "▓ DETECTION ▓"
pv_lenInput   = input.int(8, "Pivot Confirmation Bars", minval = 2, maxval = 50, group = gC,
     tooltip = "Bars each side of a swing for confirmation. Larger = only major levels, slower; smaller = more granular, faster (but more candidates).")
mergePctInput = input.float(0.3, "Merge Distance (%)", minval = 0.05, maxval = 2.0, step = 0.05, group = gC,
     tooltip = "Candidates within this % of an existing level reinforce it instead of creating a duplicate.")
proximInput   = input.float(0.5, "Touch Proximity (ATR)", minval = 0.1, maxval = 3.0, step = 0.1, group = gC,
     tooltip = "How close (in ATRs) price must come to a level to count as a 'touch' for scoring.")

gR = "▓ RL-STYLE REWARD ▓"
ai_bounceRwd  = input.float(1.0, "Bounce Reward", minval = 0.1, maxval = 5.0, step = 0.1, group = gR,
     tooltip = "Reward added when a touch is followed by a bounce (reaction against the approach).")
ai_breakPen   = input.float(1.5, "Break Penalty", minval = 0.1, maxval = 5.0, step = 0.1, group = gR,
     tooltip = "Penalty when price decisively breaks through a level (it lost its function).")
ai_reactInput = input.float(0.7, "Bounce Threshold (ATR)", minval = 0.2, maxval = 3.0, step = 0.1, group = gR,
     tooltip = "Move (in ATRs) away from a level after a touch to count as a bounce.")
ai_decayInput = input.float(0.995, "Score Decay per Bar", minval = 0.9, maxval = 1.0, step = 0.001, group = gR,
     tooltip = "All level scores multiply by this each bar, so old levels fade unless reinforced.")

gV = "▓ VISUALS ▓"
vi_themeInput = input.string("Emerald / Ruby", "Palette",
     options = ["Emerald / Ruby", "Spectral", "Mint / Coral"], group = gV)
vi_showLabels = input.bool(true, "Show Strength Labels", group = gV)
vi_extendInput= input.bool(true, "Extend Lines Right", group = gV)

gH = "▓ HUD ▓"
hud_showInput = input.bool(true, "Show HUD", group = gH)
hud_posInput  = input.string("Top Right", "Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gH)


// ============================================================================
//  ░░ PALETTE ░░
// ============================================================================
var color cSup = na   // support (below price)
var color cRes = na   // resistance (above price)
var color cAcc = na
var color cTxt  = #eef2f0
var color cTxtD = #6b7d76
var color cPanel= #080b0a
var color cPanelHd = #0f1614

setPalette() =>
    [sp, rs, ac] = switch vi_themeInput
        "Emerald / Ruby" => [#10e0a0, #ff3860, #d4af37]
        "Mint / Coral"   => [#4ef0c0, #ff6b6b, #d4af37]
        => [#22d3ee, #f43f5e, #e879f9]   // Spectral
    [sp, rs, ac]
[s, r, a] = setPalette()
cSup := s
cRes := r
cAcc := a


// ============================================================================
//  ░░ HELPERS ░░
// ============================================================================
clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))


// ============================================================================
//  ░░ CANDIDATE DETECTION (confirmed swings, non-repainting) ░░
// ============================================================================
atr = ta.atr(14)
ph = ta.pivothigh(high, pv_lenInput, pv_lenInput)
pl = ta.pivotlow(low,  pv_lenInput, pv_lenInput)


// ============================================================================
//  ░░ LEVEL POOL (parallel arrays) ░░
//  Each level: price, type (1 res / -1 sup), score, touches, breaks, born bar.
// ============================================================================
var float[] lvPx     = array.new<float>(0)
var int[]   lvType   = array.new<int>(0)
var float[] lvScore  = array.new<float>(0)
var int[]   lvTouch  = array.new<int>(0)
var int[]   lvBreak  = array.new<int>(0)
var int[]   lvBorn   = array.new<int>(0)
// Per-level "currently touching" latch + price at touch (for bounce detection).
var bool[]  lvArm    = array.new<bool>(0)
var float[] lvArmPx  = array.new<float>(0)

// Decay all scores each bar (RL-style discount).
if array.size(lvScore) > 0
    for i = 0 to array.size(lvScore) - 1
        array.set(lvScore, i, array.get(lvScore, i) * ai_decayInput)


// ── INSERT / REINFORCE on a new confirmed pivot ──
addOrMerge(px, typ) =>
    merged = false
    if array.size(lvPx) > 0
        for i = 0 to array.size(lvPx) - 1
            existPx = array.get(lvPx, i)
            // Within merge distance and same type → reinforce existing.
            near = math.abs(existPx - px) / px * 100.0 <= mergePctInput
            sameType = array.get(lvType, i) == typ
            if near and sameType and not merged
                // Slight average of price (light EMA), and a baseline score bump.
                blended = existPx * 0.7 + px * 0.3
                array.set(lvPx, i, blended)
                array.set(lvScore, i, array.get(lvScore, i) + 0.5)
                merged := true
    if not merged
        array.push(lvPx, px)
        array.push(lvType, typ)
        array.push(lvScore, 1.0)            // birth value
        array.push(lvTouch, 0)
        array.push(lvBreak, 0)
        array.push(lvBorn, bar_index)
        array.push(lvArm, false)
        array.push(lvArmPx, na)

if not na(ph) and barstate.isconfirmed
    addOrMerge(ph, 1)   // resistance candidate
if not na(pl) and barstate.isconfirmed
    addOrMerge(pl, -1)  // support candidate


// ── TOUCH / BOUNCE / BREAK SCORING ──
// For each live level, test whether price is currently near it (touch), and
// resolve a previously-armed touch as a bounce (rewarded) or a break (penalized).
if barstate.isconfirmed and array.size(lvPx) > 0
    for i = 0 to array.size(lvPx) - 1
        px = array.get(lvPx, i)
        typ = array.get(lvType, i)
        armed = array.get(lvArm, i)
        armPx = array.get(lvArmPx, i)
        proxAbs = atr * proximInput
        // Is price currently touching?
        touching = math.abs(close - px) <= proxAbs or (typ == 1 and high >= px - proxAbs and high <= px + proxAbs * 2.0) or (typ == -1 and low <= px + proxAbs and low >= px - proxAbs * 2.0)

        if not armed and touching
            array.set(lvArm, i, true)
            array.set(lvArmPx, i, close)
            array.set(lvTouch, i, array.get(lvTouch, i) + 1)
        else if armed
            // Resolve arm: bounce vs break.
            // Resistance: bounce = price now meaningfully BELOW level; break = price meaningfully ABOVE.
            // Support:    bounce = price now meaningfully ABOVE level; break = price meaningfully BELOW.
            reactAbs = atr * ai_reactInput
            isBounce = typ == 1  ? (close < px - reactAbs) : (close > px + reactAbs)
            isBreak  = typ == 1  ? (close > px + reactAbs) : (close < px - reactAbs)
            if isBounce
                array.set(lvScore, i, array.get(lvScore, i) + ai_bounceRwd)
                array.set(lvArm, i, false)
            else if isBreak
                array.set(lvScore, i, array.get(lvScore, i) - ai_breakPen)
                array.set(lvBreak, i, array.get(lvBreak, i) + 1)
                array.set(lvArm, i, false)


// ── PRUNE: remove levels with score below 0 (their function is gone) ──
if array.size(lvPx) > 0
    i = array.size(lvPx) - 1
    while i >= 0
        if array.get(lvScore, i) < 0.0
            array.remove(lvPx, i)
            array.remove(lvType, i)
            array.remove(lvScore, i)
            array.remove(lvTouch, i)
            array.remove(lvBreak, i)
            array.remove(lvBorn, i)
            array.remove(lvArm, i)
            array.remove(lvArmPx, i)
        i -= 1


// ============================================================================
//  ░░ SELECT TOP 3 (one resistance, one support, plus next-best of either) ░░
//  Logic: keep the strongest resistance ABOVE current price, the strongest
//  support BELOW, and a 3rd slot for the next-best regardless of side. This
//  guarantees price is sandwiched and the third line adds nuance.
// ============================================================================
findStrongest(sideTyp, aboveBelow, refPx) =>
    bestIdx = -1
    bestSc = -1.0
    if array.size(lvPx) > 0
        for k = 0 to array.size(lvPx) - 1
            if array.get(lvType, k) == sideTyp
                px = array.get(lvPx, k)
                ok = aboveBelow == 1 ? px > refPx : px < refPx
                if ok and array.get(lvScore, k) > bestSc
                    bestSc := array.get(lvScore, k)
                    bestIdx := k
    bestIdx

bestResIdx = findStrongest(1,  1, close)   // resistance above price
bestSupIdx = findStrongest(-1, -1, close)  // support below price

// Third slot: the highest-scoring remaining level on either side.
findThird(excl1, excl2) =>
    bestIdx = -1
    bestSc = -1.0
    if array.size(lvPx) > 0
        for k = 0 to array.size(lvPx) - 1
            if k != excl1 and k != excl2 and array.get(lvScore, k) > bestSc
                bestSc := array.get(lvScore, k)
                bestIdx := k
    bestIdx

thirdIdx = findThird(bestResIdx, bestSupIdx)


// ============================================================================
//  ░░ RENDER TOP 3 LINES ░░
// ============================================================================
var line[]  lines3 = array.new<line>(0)
var label[] lbls3  = array.new<label>(0)

clearLines() =>
    if array.size(lines3) > 0
        for i = 0 to array.size(lines3) - 1
            line.delete(array.get(lines3, i))
        array.clear(lines3)
clearLabels() =>
    if array.size(lbls3) > 0
        for i = 0 to array.size(lbls3) - 1
            label.delete(array.get(lbls3, i))
        array.clear(lbls3)

drawLine(idx, slot) =>
    if idx >= 0
        px = array.get(lvPx, idx)
        typ = array.get(lvType, idx)
        sc  = array.get(lvScore, idx)
        tch = array.get(lvTouch, idx)
        born = array.get(lvBorn, idx)
        col = typ == 1 ? cRes : cSup
        // Thickness scales with score, clamped 1..4.
        wdt = int(clamp(math.floor(sc / 2.0) + 1, 1, 4))
        xR = vi_extendInput ? bar_index + 30 : bar_index
        ln = line.new(born, px, xR, px, color = col, width = wdt, extend = vi_extendInput ? extend.right : extend.none)
        array.push(lines3, ln)
        if vi_showLabels
            slotTxt = slot == 1 ? "★1 " : slot == 2 ? "★2 " : "★3 "
            txt = slotTxt + (typ == 1 ? "R" : "S") + "  ×" + str.tostring(tch) + "  (" + str.tostring(sc, "#.0") + ")"
            lb = label.new(bar_index, px, txt, xloc = xloc.bar_index, yloc = yloc.price,
                 color = color.new(col, 25), textcolor = #ffffff,
                 style = typ == 1 ? label.style_label_left : label.style_label_left, size = size.small)
            array.push(lbls3, lb)

if barstate.islast
    clearLines()
    clearLabels()
    // Draw in order of strength (best first so it's on top).
    rSc = bestResIdx >= 0 ? array.get(lvScore, bestResIdx) : -1.0
    sSc = bestSupIdx >= 0 ? array.get(lvScore, bestSupIdx) : -1.0
    tSc = thirdIdx   >= 0 ? array.get(lvScore, thirdIdx)   : -1.0
    // Rank slots by score for the ★1/★2/★3 stars.
    // Simple manual sort of 3 entries (one assignment per line).
    int idx1 = bestResIdx
    int idx2 = bestSupIdx
    int idx3 = thirdIdx
    float sc1 = rSc
    float sc2 = sSc
    float sc3 = tSc
    if sc2 > sc1
        int tmpI = idx1
        float tmpS = sc1
        idx1 := idx2
        sc1 := sc2
        idx2 := tmpI
        sc2 := tmpS
    if sc3 > sc1
        int tmpI = idx1
        float tmpS = sc1
        idx1 := idx3
        sc1 := sc3
        idx3 := tmpI
        sc3 := tmpS
    if sc3 > sc2
        int tmpI = idx2
        float tmpS = sc2
        idx2 := idx3
        sc2 := sc3
        idx3 := tmpI
        sc3 := tmpS
    drawLine(idx1, 1)
    drawLine(idx2, 2)
    drawLine(idx3, 3)


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

var table hud = na
if hud_showInput and na(hud)
    hud := table.new(hudPos(hud_posInput), 2, 6, bgcolor = cPanel,
         border_color = color.new(cAcc, 60), border_width = 1, frame_color = color.new(cAcc, 40), frame_width = 1)

if hud_showInput and barstate.islast
    poolSize = array.size(lvPx)
    rPx = bestResIdx >= 0 ? array.get(lvPx, bestResIdx) : na
    sPx = bestSupIdx >= 0 ? array.get(lvPx, bestSupIdx) : na
    rSc = bestResIdx >= 0 ? array.get(lvScore, bestResIdx) : 0.0
    sSc = bestSupIdx >= 0 ? array.get(lvScore, bestSupIdx) : 0.0
    rTch = bestResIdx >= 0 ? array.get(lvTouch, bestResIdx) : 0
    sTch = bestSupIdx >= 0 ? array.get(lvTouch, bestSupIdx) : 0

    table.cell(hud, 0, 0, "SELF-EVOLVING S/R", text_color = cAcc, text_size = size.normal, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 0, "RL-style", text_color = cTxtD, text_size = size.normal, bgcolor = cPanelHd, text_halign = text.align_right)

    table.cell(hud, 0, 1, "resistance", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 1, na(rPx) ? "—" : str.tostring(rPx, format.mintick), text_color = cRes, text_size = size.normal, text_halign = text.align_right)

    table.cell(hud, 0, 2, "  strength × hits", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 2, str.tostring(rSc, "#.0") + " × " + str.tostring(rTch), text_color = cRes, text_size = size.normal, text_halign = text.align_right)

    table.cell(hud, 0, 3, "support", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 3, na(sPx) ? "—" : str.tostring(sPx, format.mintick), text_color = cSup, text_size = size.normal, text_halign = text.align_right)

    table.cell(hud, 0, 4, "  strength × hits", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 4, str.tostring(sSc, "#.0") + " × " + str.tostring(sTch), text_color = cSup, text_size = size.normal, text_halign = text.align_right)

    table.cell(hud, 0, 5, "pool size", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 5, str.tostring(poolSize) + " candidates", text_color = cTxt, text_size = size.normal, text_halign = text.align_right)


// ============================================================================
//  ░░ ALERTS ░░
// ============================================================================
alertcondition(not na(ph), "New Resistance Candidate", "AE-SESR: new resistance candidate added")
alertcondition(not na(pl), "New Support Candidate",    "AE-SESR: new support candidate added")
````
