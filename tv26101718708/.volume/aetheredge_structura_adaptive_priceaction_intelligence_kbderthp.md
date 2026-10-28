# AetherEdge - STRUCTURA Adaptive Price-Action Intelligence

- url: https://www.tradingview.com/script/kbDertHP/
- type: indicator
- pine_id: PUB;18d0d0a93b0e41a7a1dc5436f8e158d3
- version: 1.0

## Description

🖊️ Overview

 STRUCTURA fuses the three pillars of price action — market structure, order blocks, and fair value gaps — with a self-learning AI layer. Built on a non-repainting foundation that reads structure only from confirmed swings, its online learning discovers from the market which zones actually work and attaches a probabilistic confidence to every reversal. Unlike conventional tools that merely draw price structure, STRUCTURA continuously updates its weights from experience — emphasizing what works, fading what doesn't — adapting to the market itself.

🔶 Key Features

Automatic market structure: real-time BOS (continuation) and CHoCH (reversal) detection from confirmed swings
Swing-point classification (HH/HL/LH/LL) for wave-structure visualization
Volumetric order blocks: the last opposite-color candle before a structure break, zoned with recorded volume
Mitigation tracking: detects when price returns into a zone and visually distinguishes consumed zones (Wick/Close methods)
Fair Value Gaps: detects 3-candle imbalances and tracks fills at the midpoint
[AI Layer 1] Adaptive zone reliability: online-learns each zone type's reaction success rate and emphasizes reliable types visually
[AI Layer 2] CHoCH confidence: an online logistic regression predicts each CHoCH's "hold probability," auto-dimming low-confidence signals
Refined red/green jewel-tone palettes (three options) with a gold-framed integrated HUD
Built-in BOS/CHoCH alert conditions

🧠 Technical Architecture 

STRUCTURA's foundation is confirmed-swing detection. Swing highs and lows confirm with a few bars of lag, and in exchange gain non-repainting permanence — their positions never change once printed. From these confirmed swings, a market-structure state machine is driven. When price closes above the last swing high, it is judged a CHoCH (character change) if the prevailing trend was bearish, or a BOS (continuation) if bullish, with symmetric handling on the low side.

Order blocks are identified by scanning back to the last opposite-color candle before a structure break, capturing its high, low, and volume as a zone. Each zone tracks its own mitigation state, transitioning to a dotted style once price returns and consumes it. Fair value gaps are detected as 3-candle imbalances where the current low exceeds the high two bars prior (or the symmetric decline), extended rightward until price reaches the midpoint.

Two AI layers sit atop this. The first, adaptive zone reliability, observes whether price reacts off or breaks through a zone upon entry, updating each zone type's reaction success rate via an exponentially-weighted moving average. This learns which zone types actually function in the current market and quantifies it as reliability. The second, CHoCH confidence, is an online logistic regression taking standardized momentum, body strength, and volume as features. When a CHoCH fires it predicts whether the change will continue in the new direction, then labels the outcome after a set horizon and updates its weights via stochastic gradient descent. The learned probability is shown on each CHoCH label, and low-confidence reversals are automatically dimmed, visually separating fakeouts from genuine turns.

⚙️ Recommended Settings & Tuning Guide 

STRUCTURA is tuned with crypto in mind. On majors like BTC and ETH, Swing Length near 10 balances structural granularity against lag. On higher-volatility names such as SOL and XRP, widening Swing Length to 12–15 suppresses noise structure and clarifies major BOS/CHoCH events.

Swing Length is the master sensitivity parameter — larger captures only major structure, smaller picks up short-term structure. For swing trading, 15–20 is a guide; for intraday, 8–12. In the AI layer, raising the Zone Learning Rate makes reliability track the current regime faster; lowering it stabilizes over the long run. The CHoCH Model Learning Rate and Outcome Horizon control the reversal probability's responsiveness and evaluation window. If order blocks or FVGs become too dense, adjust the Max display counts and Min Gap Size.

💡 How to Use in Practice 

The highest-conviction setups are confluences where multiple elements align. For example, a bullish CHoCH flipping structure, with a high-reliability bullish order block beneath it and an unfilled FVG nearby, forms a strong long-consideration point. Checking the HUD's zone reliability and prioritizing the zone types actually working in the current market helps avoid overtrusting zones that don't function.

The CHoCH confidence % is a unique gauge of reversal reliability. High-confidence CHoCHs are strong evidence of a trend turn, while low-confidence ones (auto-dimmed) suggest patience. For multi-timeframe trading, pair a higher-timeframe STRUCTURA to read the macro structure and order blocks with a lower timeframe for precise entry timing. Overlaying order blocks and FVGs with volume profile and key horizontal levels further deepens the interpretation of where liquidity concentrates.

⚠️ Important Notes 

Because this tool is based on confirmed swings, structure signals confirm with a few bars of lag in real time — a necessary property of an honest, non-repainting design. The AI layer requires accumulated data to learn, so near the chart's left edge or when CHoCH occurrences are few, reliability remains at its initial values (zones 50%, CHoCH accuracy 50%). Static HUD values are a sign that learning data is still insufficient. Whether CHoCH model accuracy stably exceeds 50% depends on the instrument, timeframe, and period, and cannot overcome the fundamental constraint of market predictability.

🚨 Disclaimer 

This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. No signal guarantees future profit, and past performance does not indicate future results. All trading decisions are made at your own risk; please use this tool with sound risk management and your own independent verification.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © AetherEdge — STRUCTURA // Adaptive Price-Action Intelligence
//@version=6

// ┌──────────────────────────────────────────────────────────────────────────┐
// │  STRUCTURA — STAGE 1 of 3                                                   │
// │  CORE: MARKET STRUCTURE (BOS / CHoCH) on confirmed swings                  │
// │                                                                            │
// │  An original, AetherEdge-flavored interpretation of price-action / Smart   │
// │  Money concepts — NOT a copy of any closed-source product. Built purely    │
// │  from confirmed swing highs/lows (non-repainting) and the structure they   │
// │  imply:                                                                    │
// │    • BOS  (Break of Structure)   — trend continuation: price breaks the    │
// │                                     last swing in the trend direction.     │
// │    • CHoCH(Change of Character)   — potential reversal: price breaks a      │
// │                                     swing against the prevailing trend.     │
// │                                                                            │
// │  Stage 2 will add Order Blocks + Fair Value Gaps. Stage 3 will add the     │
// │  AI/ML layer: adaptive zone-reliability scoring + a probabilistic          │
// │  confidence on each CHoCH (online logistic regression).                    │
// └──────────────────────────────────────────────────────────────────────────┘

indicator("AetherEdge - STRUCTURA Adaptive Price-Action Intelligence", "AE-SAPAI", overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)


// ============================================================================
//  ░░ INPUTS ░░
// ============================================================================

// ─── MARKET STRUCTURE ────────────────────────────────────────────────────────
gM = "▓ MARKET STRUCTURE ▓"
ms_swingLenInp = input.int(10, "Swing Length", minval = 2, maxval = 100, group = gM,
     tooltip = "Bars on each side of a swing pivot. Larger = only major structure; smaller = more granular, faster (but noisier).")
ms_showBOSInp  = input.bool(true, "Show BOS", group = gM,
     tooltip = "Break of Structure — trend continuation breaks.")
ms_showCHoCHInp= input.bool(true, "Show CHoCH", group = gM,
     tooltip = "Change of Character — counter-trend breaks signaling possible reversal.")
ms_showSwingInp= input.bool(true, "Show Swing Points (HH/HL/LH/LL)", group = gM)
ms_colorBarsInp= input.bool(false, "Color Candles by Structure", group = gM)

// ─── AI / ML LAYER ───────────────────────────────────────────────────────────
gAI = "▓ AI · ADAPTIVE INTELLIGENCE ▓"
ai_zoneScoreInp= input.bool(true, "Adaptive Zone Reliability", group = gAI,
     tooltip = "Learn online how often each zone TYPE (bull/bear OB & FVG) actually causes a reaction vs. gets broken, and emphasize reliable zone types visually.")
ai_zoneRateInp = input.float(0.08, "Zone Learning Rate", minval = 0.01, maxval = 0.5, step = 0.01, group = gAI,
     tooltip = "How fast zone reliability adapts to recent outcomes. Higher = tracks current regime faster.")
ai_chochProbInp= input.bool(true, "CHoCH Confidence (Logistic Regression)", group = gAI,
     tooltip = "Attach an online-learned probability to each CHoCH estimating whether the character change will hold.")
ai_lrRateInp   = input.float(0.05, "CHoCH Model Learning Rate", minval = 0.001, maxval = 0.5, step = 0.001, group = gAI)
ai_lrHorizonInp= input.int(10, "CHoCH Outcome Horizon (bars)", minval = 2, maxval = 50, group = gAI,
     tooltip = "Bars ahead used to judge whether a CHoCH 'held' (price continued in the new direction), for supervised learning.")
ai_dimInput    = input.bool(true, "Dim Low-Confidence CHoCH", group = gAI)

// ─── ORDER BLOCKS ────────────────────────────────────────────────────────────
gO = "▓ ORDER BLOCKS ▓"
ob_showInput   = input.bool(true, "Show Order Blocks", group = gO)
ob_maxInput    = input.int(5, "Max Order Blocks Shown", minval = 1, maxval = 20, group = gO,
     tooltip = "How many most-recent unmitigated order blocks to keep on the chart.")
ob_mitigInput  = input.string("Wick", "Mitigation Method",
     options = ["Wick", "Close"], group = gO,
     tooltip = "Wick: zone is mitigated when a wick enters it. Close: only when price closes through it (stricter).")
ob_showVolInp  = input.bool(true, "Show Volume in Order Blocks", group = gO)

// ─── FAIR VALUE GAPS ─────────────────────────────────────────────────────────
gF = "▓ FAIR VALUE GAPS ▓"
fvg_showInput  = input.bool(true, "Show Fair Value Gaps", group = gF)
fvg_maxInput   = input.int(6, "Max FVGs Shown", minval = 1, maxval = 20, group = gF)
fvg_threshInput= input.float(0.0, "Min Gap Size (ATR)", minval = 0.0, maxval = 5.0, step = 0.1, group = gF,
     tooltip = "Filter out small FVGs below this many ATRs. 0 = show all gaps.")
fvg_extendInput= input.int(20, "FVG Extend (bars)", minval = 1, maxval = 100, group = gF,
     tooltip = "How far right to extend an unfilled FVG box.")

// ─── VISUALS ─────────────────────────────────────────────────────────────────
gV = "▓ VISUALS ▓"
vi_themeInput  = input.string("Emerald / Ruby", "Palette",
     options = ["Emerald / Ruby", "Mint / Coral", "Forest / Crimson"], group = gV,
     tooltip = "Refined red/green palettes. Bullish = green family, bearish = red family.")
vi_glowInput   = input.bool(true, "Neon Glow on Structure Lines", group = gV)
vi_lineStyleInp= input.string("Solid Swing / Dashed Internal", "Line Style",
     options = ["Solid Swing / Dashed Internal", "All Solid", "All Dashed"], group = gV)
vi_labelSizeInp= input.string("Normal", "Label Size",
     options = ["Tiny", "Small", "Normal"], group = gV)

// ─── HUD ─────────────────────────────────────────────────────────────────────
gH = "▓ HUD ▓"
hud_showInput  = input.bool(true, "Show HUD", group = gH)
hud_posInput   = input.string("Top Right", "Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gH)
hud_sizeInput  = input.string("Normal", "Text Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = gH)


// ============================================================================
//  ░░ REFINED RED/GREEN PALETTE ░░
//  Luxury direction: deep near-black canvas, jewel-tone bull/bear with bright
//  neon highlights. Each palette = [bull, bear, bullDim, bearDim, accent].
// ============================================================================
var color cBull   = na
var color cBear   = na
var color cBullD  = na
var color cBearD  = na
var color cGold   = na   // shared accent (gold) for HUD frames & highlights
var color cTxt    = #eef2f0
var color cTxtD   = #6b7d76
var color cPanel  = #080b0a
var color cPanelHd= #0f1614

setPalette() =>
    [b, s, bd, sd] = switch vi_themeInput
        "Emerald / Ruby"   => [#10e0a0, #ff3860, #0a6b54, #8c2238]
        "Mint / Coral"     => [#4ef0c0, #ff6b6b, #1f7d68, #9c3d3d]
        => [#2ecc71, #e23c4e, #176638, #842029]   // Forest / Crimson
    [b, s, bd, sd]
[pb, ps, pbd, psd] = setPalette()
cBull  := pb
cBear  := ps
cBullD := pbd
cBearD := psd
cGold  := #d4af37   // refined gold accent


// ============================================================================
//  ░░ HELPERS ░░
// ============================================================================
sdiv(a, b) =>
    b != 0 ? a / b : 0.0
clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))

labelSize() =>
    switch vi_labelSizeInp
        "Tiny"  => size.tiny
        "Small" => size.small
        => size.normal

lineStyleSwing() =>
    switch vi_lineStyleInp
        "All Dashed" => line.style_dashed
        => line.style_solid
lineStyleInternal() =>
    switch vi_lineStyleInp
        "All Solid" => line.style_solid
        => line.style_dashed


// ============================================================================
//  ░░ CONFIRMED SWING DETECTION (non-repainting) ░░
//  ta.pivothigh/low confirm `swingLen` bars after the extreme and never move.
// ============================================================================
ph = ta.pivothigh(high, ms_swingLenInp, ms_swingLenInp)
pl = ta.pivotlow(low,  ms_swingLenInp, ms_swingLenInp)
pivBar = bar_index - ms_swingLenInp

// Persisted last confirmed swing levels and their bar indices.
var float lastSwingHigh = na
var float lastSwingLow  = na
var int   lastSHBar     = na
var int   lastSLBar     = na

// Previous swing levels for HH/HL/LH/LL classification.
var float prevSwingHigh = na
var float prevSwingLow  = na

// Swing point type classification.
swingHighType = 0   // +1 = HH, -1 = LH
swingLowType  = 0   // +1 = HL, -1 = LL

if not na(ph)
    prevSwingHigh := lastSwingHigh
    lastSwingHigh := ph
    lastSHBar := pivBar
    swingHighType := na(prevSwingHigh) ? 0 : (ph > prevSwingHigh ? 1 : -1)

if not na(pl)
    prevSwingLow := lastSwingLow
    lastSwingLow := pl
    lastSLBar := pivBar
    swingLowType := na(prevSwingLow) ? 0 : (pl > prevSwingLow ? 1 : -1)


// ============================================================================
//  ░░ MARKET STRUCTURE STATE MACHINE (BOS / CHoCH) ░░
//  trend: +1 bullish, -1 bearish, 0 undefined.
//  • Price closing above last swing high:
//      - if trend was bearish  → CHoCH (character change to bullish)
//      - if trend was bullish  → BOS   (continuation)
//  • Price closing below last swing low: symmetric.
//  Breaks are evaluated on CLOSE for confirmation (non-repainting on close).
// ============================================================================
var int   trend       = 0
var float brokenHigh  = na   // the swing high level most recently broken
var float brokenLow   = na
var int   bosCount    = 0
var int   chochCount  = 0

// Track whether the current swing levels have already been "used" for a break,
// so we don't fire repeatedly on the same level.
var bool  highActive  = false
var bool  lowActive   = false

// When a new swing high/low confirms, arm it as a breakable level.
if not na(ph)
    highActive := true
if not na(pl)
    lowActive := true

bullBreak = highActive and not na(lastSwingHigh) and close > lastSwingHigh
bearBreak = lowActive  and not na(lastSwingLow)  and close < lastSwingLow

isBOS_bull   = false
isCHoCH_bull = false
isBOS_bear   = false
isCHoCH_bear = false

if bullBreak
    if trend == -1
        isCHoCH_bull := true
        chochCount += 1
    else
        isBOS_bull := true
        bosCount += 1
    trend := 1
    brokenHigh := lastSwingHigh
    highActive := false   // consume this level

if bearBreak
    if trend == 1
        isCHoCH_bear := true
        chochCount += 1
    else
        isBOS_bear := true
        bosCount += 1
    trend := -1
    brokenLow := lastSwingLow
    lowActive := false


// ============================================================================
//  ░░ ORDER BLOCKS ░░
//  On a structure break, the order block is the last opposite-color candle
//  before the break. We scan back a short window to find it, capture its
//  high/low/volume, and store it in parallel arrays. Each bar we test the most
//  recent zones for mitigation (price returning into them).
//  Arrays: obTop, obBot, obVol, obBull(1/0), obBar(left), obBox(id), obState(1 live/0 mitigated)
// ============================================================================
atr = ta.atr(14)


// ============================================================================
//  ░░ AI LAYER · STATE ░░
//  (1) Zone reliability: EWMA success rate per zone type. A zone "succeeds"
//      when price reacts off it (rejection) and "fails" when it's blown through.
//      Index: 0 = bull OB, 1 = bear OB, 2 = bull FVG, 3 = bear FVG.
//  (2) CHoCH confidence: a tiny online logistic regression predicting whether a
//      CHoCH will hold (price continues in the new direction over a horizon).
// ============================================================================
var float[] zoneRel = array.new<float>(4, 0.5)   // start neutral 0.5

// --- CHoCH logistic regression: features standardized, delayed-label SGD ---
NF = 4   // bias + 3 features
var float[] chW = array.new<float>(NF, 0.0)

// CHoCH feature vector (built when a CHoCH fires): momentum, body strength, vol.
fWin = 50
rawMomC = sdiv(close - close[5], atr)
rawBody = sdiv(close - open, atr)
rawVolC = sdiv(volume - ta.sma(volume, fWin), ta.stdev(volume, fWin))
zc0 = 1.0
zc1 = clamp(sdiv(rawMomC - ta.sma(rawMomC, fWin), ta.stdev(rawMomC, fWin)), -4, 4)
zc2 = clamp(sdiv(rawBody - ta.sma(rawBody, fWin), ta.stdev(rawBody, fWin)), -4, 4)
zc3 = clamp(nz(rawVolC), -4, 4)

sigmoid(z) =>
    z > 0 ? 1.0 / (1.0 + math.exp(-z)) : math.exp(z) / (1.0 + math.exp(z))

dotW() =>
    array.get(chW,0)*zc0 + array.get(chW,1)*zc1 + array.get(chW,2)*zc2 + array.get(chW,3)*zc3

chochProbRaw = sigmoid(dotW())   // probability this CHoCH context "holds"

// Delayed-label training buffers for CHoCH outcomes.
var float[] chFeat = array.new<float>(0)   // flattened NF per row
var int[]   chDir  = array.new<int>(0)     // +1 bull choch, -1 bear choch
var float[] chPx   = array.new<float>(0)   // price at choch
var int[]   chAge  = array.new<int>(0)     // bars elapsed
var float[] chHit  = array.new<float>(0)   // rolling training accuracy

var float[] obTop   = array.new<float>(0)
var float[] obBot   = array.new<float>(0)
var float[] obVol   = array.new<float>(0)
var int[]   obBull  = array.new<int>(0)
var int[]   obBarA  = array.new<int>(0)
var box[]   obBox   = array.new<box>(0)
var label[] obLbl   = array.new<label>(0)
var int[]   obState = array.new<int>(0)

// Find the last opposite-color candle within a lookback before a bullish break.
// For a bullish break: order block = last DOWN candle (close<open) before the rally.
findBullOB() =>
    idx = -1
    for k = 1 to 30
        if close[k] < open[k]
            idx := k
            break
    idx
findBearOB() =>
    idx = -1
    for k = 1 to 30
        if close[k] > open[k]
            idx := k
            break
    idx

newBullOB = (isBOS_bull or isCHoCH_bull) and ob_showInput
newBearOB = (isBOS_bear or isCHoCH_bear) and ob_showInput

if newBullOB
    k = findBullOB()
    if k >= 0
        t = high[k]
        b = low[k]
        array.push(obTop, t)
        array.push(obBot, b)
        array.push(obVol, nz(volume[k]))
        array.push(obBull, 1)
        array.push(obBarA, bar_index - k)
        array.push(obState, 1)
        bx = box.new(bar_index - k, t, bar_index, b,
             border_color = color.new(cBull, 40), bgcolor = color.new(cBull, 85))
        array.push(obBox, bx)
        lb = label.new(bar_index - k, b, "", yloc = yloc.price, color = color.new(cBull, 100),
             textcolor = cBull, style = label.style_label_up, size = size.tiny)
        array.push(obLbl, lb)

if newBearOB
    k = findBearOB()
    if k >= 0
        t = high[k]
        b = low[k]
        array.push(obTop, t)
        array.push(obBot, b)
        array.push(obVol, nz(volume[k]))
        array.push(obBull, 0)
        array.push(obBarA, bar_index - k)
        array.push(obState, 1)
        bx = box.new(bar_index - k, t, bar_index, b,
             border_color = color.new(cBear, 40), bgcolor = color.new(cBear, 85))
        array.push(obBox, bx)
        lb = label.new(bar_index - k, t, "", yloc = yloc.price, color = color.new(cBear, 100),
             textcolor = cBear, style = label.style_label_down, size = size.tiny)
        array.push(obLbl, lb)

// Maintain order blocks: extend live boxes, detect mitigation, prune old/excess.
if array.size(obTop) > 0
    i = array.size(obTop) - 1
    while i >= 0
        st = array.get(obState, i)
        if st == 1
            t = array.get(obTop, i)
            b = array.get(obBot, i)
            bull = array.get(obBull, i) == 1
            // Mitigation test.
            mitiged = ob_mitigInput == "Close" ? (bull ? close < b : close > t) : (bull ? low < b : high > t)
            bx = array.get(obBox, i)
            // Extend the live box to current bar.
            box.set_right(bx, bar_index)
            // Zone-reliability learning: did price TOUCH this zone this bar?
            touched = bull ? (low <= t and low >= b) or (high >= b and low <= t) : (high >= b and high <= t) or (low <= t and high >= b)
            inZone = high >= b and low <= t
            if ai_zoneScoreInp and inZone
                // Reaction = price entered but did NOT fully break through (mitigated).
                reacted = mitiged ? 0.0 : 1.0
                zIdx = bull ? 0 : 1
                zOld = array.get(zoneRel, zIdx)
                array.set(zoneRel, zIdx, zOld + ai_zoneRateInp * (reacted - zOld))
            if mitiged
                array.set(obState, i, 0)
                box.set_bgcolor(bx, color.new(bull ? cBull : cBear, 94))
                box.set_border_style(bx, line.style_dotted)
            else
                // Update volume label text on the live box.
                if ob_showVolInp
                    lb = array.get(obLbl, i)
                    label.set_xy(lb, bar_index, bull ? b : t)
                    label.set_text(lb, str.tostring(array.get(obVol, i), format.volume))
        i -= 1

// Prune: keep only the most recent ob_maxInput live blocks; delete oldest excess.
liveCount = 0
if array.size(obState) > 0
    for j = 0 to array.size(obState) - 1
        liveCount += array.get(obState, j) == 1 ? 1 : 0
while liveCount > ob_maxInput and array.size(obState) > 0
    // Find oldest live and remove it (delete its drawings).
    removed = false
    for j = 0 to array.size(obState) - 1
        if array.get(obState, j) == 1
            box.delete(array.get(obBox, j))
            label.delete(array.get(obLbl, j))
            array.remove(obTop, j), array.remove(obBot, j), array.remove(obVol, j)
            array.remove(obBull, j), array.remove(obBarA, j), array.remove(obBox, j)
            array.remove(obLbl, j), array.remove(obState, j)
            removed := true
            break
    liveCount -= 1
    if not removed
        break


// ============================================================================
//  ░░ FAIR VALUE GAPS ░░
//  Bullish FVG: low[0] > high[2] (gap up). Bearish FVG: high[0] < low[2].
//  Tracked as boxes; filled when price trades back through the gap midpoint.
//  Arrays: fvgTop, fvgBot, fvgBull, fvgBox, fvgState.
// ============================================================================
var float[] fvgTop   = array.new<float>(0)
var float[] fvgBot   = array.new<float>(0)
var int[]   fvgBull  = array.new<int>(0)
var box[]   fvgBox   = array.new<box>(0)
var int[]   fvgState = array.new<int>(0)

bullFVG = low > high[2] and fvg_showInput
bearFVG = high < low[2] and fvg_showInput
gapSizeOk(t, b) =>
    fvg_threshInput <= 0 or (t - b) >= fvg_threshInput * atr

if bullFVG
    t = low        // top of the bull gap (current low)
    b = high[2]    // bottom (high two bars ago)
    if gapSizeOk(t, b)
        array.push(fvgTop, t)
        array.push(fvgBot, b)
        array.push(fvgBull, 1)
        array.push(fvgState, 1)
        bx = box.new(bar_index - 1, t, bar_index + fvg_extendInput, b,
             border_color = color.new(cBull, 55), bgcolor = color.new(cBull, 90))
        array.push(fvgBox, bx)

if bearFVG
    t = low[2]
    b = high
    if gapSizeOk(t, b)
        array.push(fvgTop, t)
        array.push(fvgBot, b)
        array.push(fvgBull, 0)
        array.push(fvgState, 1)
        bx = box.new(bar_index - 1, t, bar_index + fvg_extendInput, b,
             border_color = color.new(cBear, 55), bgcolor = color.new(cBear, 90))
        array.push(fvgBox, bx)

// Maintain FVGs: fill detection + extension + prune.
if array.size(fvgTop) > 0
    i = array.size(fvgTop) - 1
    while i >= 0
        if array.get(fvgState, i) == 1
            t = array.get(fvgTop, i)
            b = array.get(fvgBot, i)
            bull = array.get(fvgBull, i) == 1
            mid = (t + b) / 2.0
            bx = array.get(fvgBox, i)
            box.set_right(bx, bar_index + fvg_extendInput)
            // Filled when price trades to the midpoint.
            filled = bull ? low <= mid : high >= mid
            if filled
                array.set(fvgState, i, 0)
                box.set_bgcolor(bx, color.new(bull ? cBull : cBear, 96))
                box.set_border_style(bx, line.style_dotted)
        i -= 1

// Prune excess FVGs.
fvgLive = 0
if array.size(fvgState) > 0
    for j = 0 to array.size(fvgState) - 1
        fvgLive += array.get(fvgState, j) == 1 ? 1 : 0
while fvgLive > fvg_maxInput and array.size(fvgState) > 0
    rm = false
    for j = 0 to array.size(fvgState) - 1
        if array.get(fvgState, j) == 1
            box.delete(array.get(fvgBox, j))
            array.remove(fvgTop, j), array.remove(fvgBot, j), array.remove(fvgBull, j)
            array.remove(fvgBox, j), array.remove(fvgState, j)
            rm := true
            break
    fvgLive -= 1
    if not rm
        break


// ============================================================================
//  ░░ AI LAYER · CHoCH SUPERVISED LEARNING ░░
//  Capture features when a CHoCH fires; after the outcome horizon, label it as
//  HELD (1) if price continued in the CHoCH direction, else 0, then SGD-update.
// ============================================================================
chochNow = (isCHoCH_bull or isCHoCH_bear) and ai_chochProbInp
if chochNow
    array.push(chFeat, zc0)
    array.push(chFeat, zc1)
    array.push(chFeat, zc2)
    array.push(chFeat, zc3)
    array.push(chDir, isCHoCH_bull ? 1 : -1)
    array.push(chPx, close)
    array.push(chAge, 0)

// Age all pending CHoCH samples; train those that reached the horizon.
if array.size(chDir) > 0
    i = array.size(chDir) - 1
    while i >= 0
        age = array.get(chAge, i) + 1
        array.set(chAge, i, age)
        if age >= ai_lrHorizonInp
            dir = array.get(chDir, i)
            px0 = array.get(chPx, i)
            // Did the character change hold? price moved in CHoCH direction.
            held = (dir > 0 and close > px0) or (dir < 0 and close < px0) ? 1.0 : 0.0
            base = i * NF
            ff0 = array.get(chFeat, base)
            ff1 = array.get(chFeat, base + 1)
            ff2 = array.get(chFeat, base + 2)
            ff3 = array.get(chFeat, base + 3)
            pOld = sigmoid(array.get(chW,0)*ff0 + array.get(chW,1)*ff1 + array.get(chW,2)*ff2 + array.get(chW,3)*ff3)
            err = pOld - held
            array.set(chW, 0, array.get(chW,0) - ai_lrRateInp * err * ff0)
            array.set(chW, 1, array.get(chW,1) - ai_lrRateInp * err * ff1)
            array.set(chW, 2, array.get(chW,2) - ai_lrRateInp * err * ff2)
            array.set(chW, 3, array.get(chW,3) - ai_lrRateInp * err * ff3)
            // Track accuracy.
            predHeld = pOld > 0.5 ? 1.0 : 0.0
            array.push(chHit, predHeld == held ? 1.0 : 0.0)
            if array.size(chHit) > 100
                array.shift(chHit)
            // Remove the trained sample (4 feature slots + parallel entries).
            array.remove(chFeat, base + 3)
            array.remove(chFeat, base + 2)
            array.remove(chFeat, base + 1)
            array.remove(chFeat, base)
            array.remove(chDir, i)
            array.remove(chPx, i)
            array.remove(chAge, i)
        i -= 1

chochAcc = array.size(chHit) > 0 ? array.avg(chHit) * 100.0 : 50.0


// ============================================================================
//  ░░ VISUALS — STRUCTURE LINES & LABELS ░░
// ============================================================================
lsz = labelSize()

// Draw a horizontal break line from the broken swing to the current bar, plus
// a centered label. CHoCH labels carry an AI confidence %, and low-confidence
// CHoCHs are dimmed when enabled.
drawBreak(brokenBar, level, bull, isCHoCH, prob) =>
    col   = bull ? cBull : cBear
    // Confidence-driven transparency: high prob = vivid, low = faint.
    conf  = isCHoCH and ai_chochProbInp ? prob : 1.0
    dim   = isCHoCH and ai_dimInput ? math.round(15 + (1.0 - conf) * 55) : 15
    txt   = isCHoCH ? ("CHoCH " + (ai_chochProbInp ? str.tostring(math.round(prob * 100)) + "%" : "")) : "BOS"
    style = isCHoCH ? lineStyleInternal() : lineStyleSwing()
    if vi_glowInput
        line.new(brokenBar, level, bar_index, level, color = color.new(col, 75), width = 3, style = style)
    line.new(brokenBar, level, bar_index, level, color = col, width = 1, style = style)
    lblStyle = bull ? label.style_label_down : label.style_label_up
    label.new(math.round((brokenBar + bar_index) / 2), level, txt,
         color = color.new(col, dim), textcolor = bull ? #04140f : #1a0509,
         style = lblStyle, size = lsz)

if (isBOS_bull and ms_showBOSInp) or (isCHoCH_bull and ms_showCHoCHInp)
    bb = na(lastSHBar) ? bar_index : lastSHBar
    drawBreak(bb, lastSwingHigh, true, isCHoCH_bull, chochProbRaw)
if (isBOS_bear and ms_showBOSInp) or (isCHoCH_bear and ms_showCHoCHInp)
    bb = na(lastSLBar) ? bar_index : lastSLBar
    drawBreak(bb, lastSwingLow, false, isCHoCH_bear, 1.0 - chochProbRaw)

// Swing point markers (HH/HL/LH/LL).
if ms_showSwingInp and not na(ph)
    txt = swingHighType == 1 ? "HH" : swingHighType == -1 ? "LH" : "H"
    label.new(pivBar, ph, txt, yloc = yloc.price, color = color.new(cBear, 80),
         textcolor = cBear, style = label.style_label_down, size = size.tiny)
if ms_showSwingInp and not na(pl)
    txt = swingLowType == 1 ? "HL" : swingLowType == -1 ? "LL" : "L"
    label.new(pivBar, pl, txt, yloc = yloc.price, color = color.new(cBull, 80),
         textcolor = cBull, style = label.style_label_up, size = size.tiny)

// Candle coloring by structure trend.
barcolor(ms_colorBarsInp ? (trend == 1 ? color.new(cBull, 30) : trend == -1 ? color.new(cBear, 30) : na) : na, editable = false)


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
    hud := table.new(hudPos(hud_posInput), 2, 11, bgcolor = cPanel,
         border_color = color.new(cGold, 60), border_width = 1, frame_color = color.new(cGold, 40), frame_width = 1)

if hud_showInput and barstate.islast
    sz = hudSize(hud_sizeInput)
    trendTxt = trend == 1 ? "▲ BULLISH" : trend == -1 ? "▼ BEARISH" : "· UNDEFINED"
    trendCol = trend == 1 ? cBull : trend == -1 ? cBear : cTxtD

    table.cell(hud, 0, 0, "STRUCTURA", text_color = cGold, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 0, "core", text_color = cTxtD, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_right)

    table.cell(hud, 0, 1, "structure", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 1, trendTxt, text_color = trendCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 2, "last swing H", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 2, na(lastSwingHigh) ? "—" : str.tostring(lastSwingHigh, format.mintick), text_color = cBear, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 3, "last swing L", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 3, na(lastSwingLow) ? "—" : str.tostring(lastSwingLow, format.mintick), text_color = cBull, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 4, "BOS count", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 4, str.tostring(bosCount), text_color = cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 5, "CHoCH count", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 5, str.tostring(chochCount), text_color = cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 6, "swing len", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 6, str.tostring(ms_swingLenInp), text_color = cTxt, text_size = sz, text_halign = text.align_right)

    // ── AI layer ──
    table.cell(hud, 0, 7, "▔ ADAPTIVE AI ▔", text_color = cGold, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 7, "", bgcolor = cPanelHd)

    relBull = array.get(zoneRel, 0) * 100.0
    relBear = array.get(zoneRel, 1) * 100.0
    table.cell(hud, 0, 8, "bull OB reliab.", text_color = cBull, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 8, str.tostring(relBull, "#") + "%", text_color = relBull >= 50 ? cBull : cTxtD, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 9, "bear OB reliab.", text_color = cBear, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 9, str.tostring(relBear, "#") + "%", text_color = relBear >= 50 ? cBear : cTxtD, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 10, "CHoCH model acc", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 10, str.tostring(chochAcc, "#") + "%", text_color = chochAcc > 55 ? cBull : chochAcc < 45 ? cBear : cTxt, text_size = sz, text_halign = text.align_right)


// ============================================================================
//  ░░ ALERTS ░░
// ============================================================================
alertcondition(isBOS_bull,   "Bullish BOS",   "STRUCTURA: Bullish Break of Structure")
alertcondition(isBOS_bear,   "Bearish BOS",   "STRUCTURA: Bearish Break of Structure")
alertcondition(isCHoCH_bull, "Bullish CHoCH", "STRUCTURA: Bullish Change of Character")
alertcondition(isCHoCH_bear, "Bearish CHoCH", "STRUCTURA: Bearish Change of Character")
````
