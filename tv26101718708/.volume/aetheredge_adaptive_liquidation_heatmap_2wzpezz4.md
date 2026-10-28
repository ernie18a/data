# AetherEdge - Adaptive Liquidation Heatmap

- url: https://www.tradingview.com/script/2WzPEzZ4/
- type: indicator
- pine_id: PUB;a05ad90078db4bcf9100341e141b401f
- version: 2.0

## Description

🖊️ Overview

AE-LIQ is a liquidation-level estimation engine in the spirit of CoinGlass-style liquidation heatmaps. It estimates the price levels where leveraged liquidation orders cluster and renders them as bright horizontal bands — the "magnets" price tends to be drawn toward. Real liquidation maps use exchange position data, but since Pine can only access price and volume, this tool estimates from those by back-solving liquidation prices for several leverage tiers, emphasizing the bands that work via adaptive learning.

🔶 Key Features

Liquidation-band estimation: back-solves liquidation prices for 5×/10×/25×/50×/100× leverage
Volume weighting: each bar's volume serves as a position-size proxy for band intensity
Swept decay: bands price has already traded through are decayed, emphasizing un-swept bands (remaining liquidity)
Long/short selection: long liquidations (below) and short liquidations (above) can be shown separately
[AI Layer] Adaptive tier reliability: online-learns whether price reaching each tier's bands actually reacted, emphasizing the effective ones
Viridis palette (purple→teal→green→yellow) reproducing the CoinGlass aesthetic
Integrated HUD showing the strongest leverage tier and each tier's reliability

🧠 Technical Architecture

Liquidation distance is approximated by the inverse of leverage (≈10% for 10×, ≈4% for 25×). From each bar's price, liquidation prices are back-solved for every enabled leverage tier, and a volume-based weight is added to the row (price bin) that price occupies. Higher leverage produces tighter, more crowded bands weighted more heavily. The accumulated row energy is normalized, bands price recently swept are decayed by the configured amount ("liquidated"), and un-swept bands remain bright. The AI layer checks whether, historically, price reaching each tier's liquidation distance actually produced an ATR-scaled reaction, updating per-tier reliability via an exponentially-weighted average. More reliable tiers gain band weight and visual emphasis. Rendering uses per-row horizontal box transparency grading, with Viridis-spectrum brightness encoding energy magnitude.⚙️ Recommended Settings & Tuning Guide
Tuned with crypto in mind. Price Resolution 60 and Accumulation Lookback ~250 are a starting point. On high-volatility instruments, raise Vertical Range to cover a wider price span. Swept-Band Decay controls how much traded-through bands are erased — higher leaves only the un-swept bands vivid, like CoinGlass. If cluttered, turn off unneeded tiers or restrict to one side (long/short).

💡 How to Use in Practice

Bright yellow bands read as price levels where heavy liquidations sleep — magnets that attract price. Price often moves toward such bands, and reaching them tends to trigger large volatility (liquidation cascades). The brightest bands above and below current price offer references for short-term targets and risk management. The HUD's strongest tier shows which leverage layer actually functions as a magnet on this instrument, guiding which bands to prioritize. Pairing with other structure analysis and favoring levels where liquidation bands align with support/resistance is effective.

⚠️ Important Notes

This tool is Estimated and differs from a real CoinGlass liquidation map. Exchange open-interest and leverage-distribution data cannot be accessed in Pine, so this is an approximation back-solved from price and volume, and may diverge from the actual distribution of liquidation orders. Liquidation bands are probabilistic estimates, not certain price targets. The heatmap rebuilds only on the last bar and does not repaint confirmed history. The AI reliability learning requires accumulated data.

🚨 Disclaimer

This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. No output guarantees future prices, and past performance does not indicate future results. All trading decisions are made at your own risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © AetherEdge — Adaptive Liquidation Heatmap (Estimated)
//@version=6

// ┌──────────────────────────────────────────────────────────────────────────┐
// │  AetherEdge - Adaptive Liquidation Heatmap (Persistent Lines)  ·  AE-LIQ    │
// │                                                                            │
// │  An ESTIMATED liquidation-level map where each liquidation band is drawn    │
// │  from the moment it forms and EXTENDS RIGHT until price reaches it          │
// │  (CoinGlass-style): bright horizontal lines mark un-swept liquidation       │
// │  liquidity; once price sweeps through a line it dims/decays as "liquidated".│
// │                                                                            │
// │  HONEST SCOPE: real liquidation maps use exchange leverage/open-interest    │
// │  data Pine CANNOT access (only OHLCV). This estimates: at each bar,         │
// │  positions opened there are projected to liquidation prices for several     │
// │  leverage tiers (5×,10×,25×,50×,100×), weighted by that bar's volume. Each  │
// │  resulting band becomes a horizontal line extended forward until swept.     │
// │                                                                            │
// │  AI LAYER: online-learned reliability per leverage tier (does price         │
// │  reaching that tier actually react?), brightening the tiers that act as    │
// │  genuine magnets.                                                          │
// └──────────────────────────────────────────────────────────────────────────┘

indicator("AetherEdge - Adaptive Liquidation Heatmap", "AE-LIQ", overlay = true,
     max_boxes_count = 500, max_lines_count = 200, max_labels_count = 100)


// ============================================================================
//  ░░ INPUTS ░░
// ============================================================================

// ─── LIQUIDATION BANDS ───────────────────────────────────────────────────────
gH = "▓ LIQUIDATION BANDS ▓"
hm_maxLinesInp= input.int(120, "Max Live Bands", minval = 20, maxval = 450, group = gH,
     tooltip = "Maximum number of un-swept liquidation lines kept on the chart at once. Older/weaker ones are pruned. Stay well under 500 (the drawing limit).")
hm_minVolInput= input.float(1.2, "Min Volume to Spawn (× avg)", minval = 0.5, maxval = 5.0, step = 0.1, group = gH,
     tooltip = "Only bars with volume above this multiple of average spawn new liquidation bands, so lines mark meaningful position build-ups.")
hm_mergeInput = input.float(0.15, "Band Merge Distance (%)", minval = 0.0, maxval = 1.0, step = 0.05, group = gH,
     tooltip = "New bands within this % of an existing live band reinforce it (brighter) instead of adding a duplicate line.")
hm_sweepInput = input.string("Wick", "Sweep Detection",
     options = ["Wick", "Close"], group = gH,
     tooltip = "Wick: a band is swept when a wick touches it. Close: only when price closes through it.")
hm_decayInput = input.float(0.6, "Swept Decay", minval = 0.0, maxval = 1.0, step = 0.05, group = gH,
     tooltip = "How much a band dims once swept. 1 = removed immediately, lower = lingers faintly as a 'used' level.")

// ─── LEVERAGE TIERS ──────────────────────────────────────────────────────────
gL = "▓ LEVERAGE TIERS ▓"
lv_use5Input  = input.bool(true,  "5×  (±~20%)",  group = gL)
lv_use10Input = input.bool(true,  "10× (±~10%)",  group = gL)
lv_use25Input = input.bool(true,  "25× (±~4%)",   group = gL)
lv_use50Input = input.bool(true,  "50× (±~2%)",   group = gL)
lv_use100Input= input.bool(true,  "100× (±~1%)",  group = gL)
lv_sideInput  = input.string("Both", "Liquidation Side",
     options = ["Both", "Longs (below)", "Shorts (above)"], group = gL,
     tooltip = "Longs liquidate BELOW entry, shorts ABOVE. 'Both' shows the full magnet field.")

// ─── AI ADAPTIVE ─────────────────────────────────────────────────────────────
gA = "▓ AI · ADAPTIVE TIERS ▓"
ai_enableInput= input.bool(true, "Adaptive Tier Reliability", group = gA,
     tooltip = "Online-learn which leverage tiers actually act as magnets (price reacts on contact) and emphasize them.")
ai_rateInput  = input.float(0.08, "Learning Rate", minval = 0.01, maxval = 0.5, step = 0.01, group = gA)
ai_reactInput = input.float(0.5, "Reaction Threshold (ATR)", minval = 0.1, maxval = 3.0, step = 0.1, group = gA,
     tooltip = "How large a bounce (in ATR) counts as a 'reaction' when price touches a liquidation band, for learning.")

// ─── VISUALS ─────────────────────────────────────────────────────────────────
gV = "▓ VISUALS ▓"
vi_paletteInp = input.string("Viridis", "Palette",
     options = ["Viridis", "Inferno", "Spectral Energy"], group = gV,
     tooltip = "Viridis = purple→teal→green→yellow (CoinGlass-like).")
vi_intensityInp= input.float(1.0, "Intensity", minval = 0.3, maxval = 2.0, step = 0.1, group = gV)
vi_glowInput  = input.bool(true, "Glow on Brightest Bands", group = gV)
vi_thickInput= input.float(0.08, "Band Thickness (ATR)", minval = 0.02, maxval = 0.5, step = 0.02, group = gV,
     tooltip = "Half-thickness of each liquidation line, in ATRs. Smaller = crisp thin lines, larger = chunky bands.")

// ─── HUD ─────────────────────────────────────────────────────────────────────
gHud = "▓ HUD ▓"
hud_showInput = input.bool(true, "Show HUD", group = gHud)
hud_posInput  = input.string("Top Right", "Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gHud)
hud_sizeInput = input.string("Normal", "Text Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = gHud)


// ============================================================================
//  ░░ HELPERS ░░
// ============================================================================
sdiv(a, b) =>
    b != 0 ? a / b : 0.0
clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))

// Viridis-like ramp from normalized intensity x in [0,1].
heatColor(x) =>
    v = clamp(x, 0.0, 1.0)
    out = switch vi_paletteInp
        "Inferno"         => v < 0.5 ? color.from_gradient(v, 0.0, 0.5, #000004, #bb3754) : color.from_gradient(v, 0.5, 1.0, #bb3754, #fcffa4)
        "Spectral Energy" => v < 0.5 ? color.from_gradient(v, 0.0, 0.5, #4c1d95, #10b981) : color.from_gradient(v, 0.5, 1.0, #10b981, #ef4444)
        => v < 0.33 ? color.from_gradient(v, 0.0, 0.33, #440154, #31688e) : v < 0.66 ? color.from_gradient(v, 0.33, 0.66, #31688e, #35b779) : color.from_gradient(v, 0.66, 1.0, #35b779, #fde725)
    out


// ============================================================================
//  ░░ LEVERAGE TIER TABLE ░░
//  Liquidation distance ≈ 1/leverage (minus fees/maint margin, simplified).
//  We store enabled tiers and their AI reliability weights.
// ============================================================================
atr = ta.atr(14)

// Tier leverage values and their liquidation fraction (1/lev).
var float[] tierLev  = array.from(5.0, 10.0, 25.0, 50.0, 100.0)
var float[] tierRel  = array.new<float>(5, 0.5)   // AI reliability per tier
var bool[]  tierOn   = array.new<bool>(5, true)
array.set(tierOn, 0, lv_use5Input)
array.set(tierOn, 1, lv_use10Input)
array.set(tierOn, 2, lv_use25Input)
array.set(tierOn, 3, lv_use50Input)
array.set(tierOn, 4, lv_use100Input)


// ============================================================================
//  ░░ LIQUIDATION BAND STATE (persistent, parallel arrays) ░░
//  Each live band: price level, tier index, weight (intensity), live flag,
//  left bar (origin), and its box (line) drawing handle.
// ============================================================================
var float[] bandPx    = array.new<float>(0)
var int[]   bandTier  = array.new<int>(0)
var float[] bandW     = array.new<float>(0)
var int[]   bandLive  = array.new<int>(0)    // 1 live (un-swept), 0 swept
var int[]   bandLeft  = array.new<int>(0)
var box[]   bandBox   = array.new<box>(0)

showLongs  = lv_sideInput == "Both" or lv_sideInput == "Longs (below)"
showShorts = lv_sideInput == "Both" or lv_sideInput == "Shorts (above)"

volAvg = ta.sma(volume, 20)

// ── AI reliability learning (cheap, every bar) ──
// Arm: when price approaches a tier's typical band distance, check reaction.
// Simplified: track whether a move of ~1/lev from `lookback` ago saw a reaction.
if ai_enableInput and barstate.isconfirmed
    for t = 0 to 4
        lev = array.get(tierLev, t)
        liqFrac = 1.0 / lev
        // A position opened `H` bars ago liquidates ~liqFrac away. Did price
        // reach that level and react? Use a horizon proportional to leverage.
        hb = math.min(50, int(lev))
        if bar_index > hb + 2
            entry = close[hb]
            longLiq = entry * (1.0 - liqFrac)
            shortLiq = entry * (1.0 + liqFrac)
            // Did price touch either liq level within the horizon?
            ll = ta.lowest(low, hb)
            hh = ta.highest(high, hb)
            touchedLong = ll <= longLiq
            touchedShort = hh >= shortLiq
            reactedUp = (close - ll) >= ai_reactInput * atr
            reactedDn = (hh - close) >= ai_reactInput * atr
            outcome = ((touchedLong and reactedUp) or (touchedShort and reactedDn)) ? 1.0 : ((touchedLong or touchedShort) ? 0.0 : na)
            if not na(outcome)
                old = array.get(tierRel, t)
                array.set(tierRel, t, clamp(old + ai_rateInput * (outcome - old), 0.05, 1.0))


// ============================================================================
//  ░░ BAND LIFECYCLE (every bar) ░░
//  1) SPAWN — on high-volume bars, project this bar's positions to each tier's
//     liquidation price and create a new band (or reinforce a nearby one).
//  2) EXTEND — live bands extend their right edge to the current bar.
//  3) SWEEP  — when price reaches a band, mark it swept and decay it.
//  4) PRUNE  — cap live bands; remove the weakest/oldest beyond the limit.
//  Bands are thin boxes (a fraction of ATR tall) acting as glowing lines.
// ============================================================================
bandHalf = atr * vi_thickInput   // half-thickness of a band "line"

// ── 1) SPAWN / REINFORCE ──
spawnOK = volume > volAvg * hm_minVolInput
if spawnOK and barstate.isconfirmed
    for t = 0 to 4
        if array.get(tierOn, t)
            lev = array.get(tierLev, t)
            liqFrac = 1.0 / lev
            rel = ai_enableInput ? array.get(tierRel, t) : 1.0
            wgt = (volume / (volAvg + 1e-9)) * rel * (lev / 20.0)
            // Candidate liquidation prices for this bar's positions.
            for sideI = 0 to 1
                doSide = sideI == 0 ? showLongs : showShorts
                if doSide
                    lp = sideI == 0 ? close * (1.0 - liqFrac) : close * (1.0 + liqFrac)
                    // Merge with an existing nearby live band of same tier?
                    merged = false
                    if array.size(bandPx) > 0
                        for b = 0 to array.size(bandPx) - 1
                            if array.get(bandLive, b) == 1 and array.get(bandTier, b) == t
                                near = math.abs(array.get(bandPx, b) - lp) / lp * 100.0 <= hm_mergeInput
                                if near and not merged
                                    array.set(bandW, b, array.get(bandW, b) + wgt)
                                    merged := true
                    if not merged
                        array.push(bandPx, lp)
                        array.push(bandTier, t)
                        array.push(bandW, wgt)
                        array.push(bandLive, 1)
                        array.push(bandLeft, bar_index)
                        // Create the drawing; styled later each bar.
                        bx = box.new(bar_index, lp + bandHalf, bar_index, lp - bandHalf, border_width = 0, bgcolor = color.new(heatColor(0.5), 70), xloc = xloc.bar_index)
                        array.push(bandBox, bx)

// ── normalization reference: max live weight ──
maxW = 1e-9
if array.size(bandW) > 0
    for b = 0 to array.size(bandW) - 1
        if array.get(bandLive, b) == 1
            maxW := math.max(maxW, array.get(bandW, b))

// ── 2/3) EXTEND + SWEEP + restyle ──
sweepWick = hm_sweepInput == "Wick"
if array.size(bandPx) > 0
    for b = 0 to array.size(bandPx) - 1
        px = array.get(bandPx, b)
        live = array.get(bandLive, b)
        bx = array.get(bandBox, b)
        // Sweep test.
        touched = sweepWick ? (high >= px - bandHalf and low <= px + bandHalf) : (math.abs(close - px) <= bandHalf)
        if live == 1 and touched
            array.set(bandLive, b, 0)
            // Learn: a touch that reacts reinforces the tier (handled in AI block).
        live := array.get(bandLive, b)
        // Intensity (normalized weight).
        e = clamp(array.get(bandW, b) / maxW, 0.0, 1.0)
        eAdj = clamp(e * vi_intensityInp, 0.0, 1.0)
        col = heatColor(eAdj)
        if live == 1
            // Live: extend right edge, bright.
            box.set_right(bx, bar_index)
            box.set_top(bx, px + bandHalf)
            box.set_bottom(bx, px - bandHalf)
            transp = int(clamp(90 - eAdj * 64, 16, 94))
            box.set_bgcolor(bx, color.new(col, transp))
        else
            // Swept: stop extending, decay opacity.
            faded = int(clamp(94 - eAdj * 40 + hm_decayInput * 40, 40, 99))
            box.set_bgcolor(bx, color.new(col, faded))

// ── 4) PRUNE: keep only the strongest live bands up to the cap; delete swept
//     bands fully when decay is maxed, and trim oldest/weakest live overflow ──
// Remove fully-decayed swept bands first.
if hm_decayInput >= 0.99 and array.size(bandPx) > 0
    b = array.size(bandPx) - 1
    while b >= 0
        if array.get(bandLive, b) == 0
            box.delete(array.get(bandBox, b))
            array.remove(bandPx, b), array.remove(bandTier, b), array.remove(bandW, b)
            array.remove(bandLive, b), array.remove(bandLeft, b), array.remove(bandBox, b)
        b -= 1

// Count live; if over cap, remove the weakest live band repeatedly.
liveCount = 0
if array.size(bandLive) > 0
    for b = 0 to array.size(bandLive) - 1
        liveCount += array.get(bandLive, b) == 1 ? 1 : 0

while liveCount > hm_maxLinesInp and array.size(bandPx) > 0
    // Find weakest live band.
    wIdx = -1
    wMin = 1e18
    for b = 0 to array.size(bandPx) - 1
        if array.get(bandLive, b) == 1 and array.get(bandW, b) < wMin
            wMin := array.get(bandW, b)
            wIdx := b
    if wIdx < 0
        break
    box.delete(array.get(bandBox, wIdx))
    array.remove(bandPx, wIdx), array.remove(bandTier, wIdx), array.remove(bandW, wIdx)
    array.remove(bandLive, wIdx), array.remove(bandLeft, wIdx), array.remove(bandBox, wIdx)
    liveCount -= 1

// Also cap total boxes (live + swept) hard at ~480 to respect the limit.
while array.size(bandPx) > 480
    box.delete(array.get(bandBox, 0))
    array.remove(bandPx, 0), array.remove(bandTier, 0), array.remove(bandW, 0)
    array.remove(bandLive, 0), array.remove(bandLeft, 0), array.remove(bandBox, 0)


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

var color cAcc  = #fde725
var color cTxt  = #dfe7f2
var color cTxtD = #5f7186
var color cPanel= #0a0c12
var color cPanelHd = #131826

var table hud = na
if hud_showInput and na(hud)
    hud := table.new(hudPos(hud_posInput), 2, 9, bgcolor = cPanel,
         border_color = color.new(cAcc, 65), border_width = 1, frame_color = color.new(cAcc, 45), frame_width = 1)

tierName(t) =>
    switch t
        0 => "5×"
        1 => "10×"
        2 => "25×"
        3 => "50×"
        => "100×"

if hud_showInput and barstate.islast
    sz = hudSize(hud_sizeInput)

    table.cell(hud, 0, 0, "LIQUIDATION MAP", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 0, "estimated", text_color = cTxtD, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_right)

    // Most reliable tier (AI).
    bestT = 0
    bestR = array.get(tierRel, 0)
    for t = 1 to 4
        if array.get(tierRel, t) > bestR
            bestR := array.get(tierRel, t)
            bestT := t
    table.cell(hud, 0, 1, "strongest tier", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 1, tierName(bestT), text_color = cAcc, text_size = sz, text_halign = text.align_right)

    // Per-tier reliability rows.
    for t = 0 to 4
        rel = array.get(tierRel, t)
        on = array.get(tierOn, t)
        table.cell(hud, 0, t + 2, tierName(t) + (on ? "" : " (off)"), text_color = t == bestT ? cAcc : cTxt, text_size = sz, text_halign = text.align_left)
        table.cell(hud, 1, t + 2, bar10(rel) + " " + str.tostring(rel*100, "#") + "%", text_color = on ? (t == bestT ? cAcc : cTxtD) : cTxtD, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 7, "side", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 7, lv_sideInput, text_color = cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 8, "live bands", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 8, str.tostring(liveCount), text_color = cTxt, text_size = sz, text_halign = text.align_right)
````
