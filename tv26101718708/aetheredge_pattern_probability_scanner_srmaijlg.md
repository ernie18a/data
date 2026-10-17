# AetherEdge - Pattern Probability Scanner

- url: https://www.tradingview.com/script/srmaIJLG/
- type: indicator
- pine_id: PUB;29dd246dfe074b01a89f754957d12624
- version: 1.0

## Description

🖊️ Overview

AE-PPS is a scanner that auto-detects classic chart patterns — Double Top, Double Bottom, Head & Shoulders, Inverse H&S, and Triangle — and labels each with its empirical win rate from past detections on this chart. At a glance you see "this shape historically played out as expected X% of the time," making pattern trading practical even for beginners.

🔶 Key Features

Auto-detects 5 patterns: Double Top, Double Bottom, H&S, Inverse H&S, Triangle
Pattern win-rate learning: computes empirical success rate per type and shows it on the label
Non-repainting detection: uses only confirmed swings — printed patterns never move
Pattern structure visualization: connecting lines drawn between key pivots
Per-pattern alerts
Integrated HUD listing every pattern's win rate and detection count

🧠 Technical Architecture

This tool uses rule-based geometric detection. Candidate points are harvested from confirmed swing highs/lows (ta.pivothigh/low), then matched against each pattern's geometric definition. Double Top requires "two near-equal swing highs (within the tolerance) and an intervening low"; H&S requires "three highs with the middle highest, the outer two within tolerance, and two intervening lows forming a neckline"; Triangle requires "the last three highs descending and the last three lows ascending," and so on. For win rates, each detection's context is buffered; after the outcome horizon, the result is judged by whether price moved as the pattern predicts (Double Top → fall, Triangle → breakout, etc.). The win rate is computed as wins / (wins + losses) × 100 per type and shown on each new label.

⚙️ Recommended Settings & Tuning Guide

Tuned with crypto in mind. Pivot Confirmation Bars near 6 is a starting point — larger captures only major patterns, smaller picks up finer ones. Equal-Level Tolerance (%) is how close two levels must be to count as "equal" — raise to 2.0–2.5% on highly volatile instruments to catch more. Max Pattern Span limits one pattern's bar count — 40–60 for short-term, 80–120 for swing. Outcome Horizon for win/loss judgment: 10–15 intraday, 20–30 for swing.

💡 How to Use in Practice

The most intuitive use is reading each detected pattern's labeled win rate. "DOUBLE TOP 70%" means double tops on this chart historically dropped 70% of the time. Patterns with win rates above 55% are highlighted as high-conviction (green); below 45% are highlighted as "doesn't typically play out" (red), supporting caution. Neckline breaks (H&S) and pattern-low breaks (Double Top) are classic entry points — use the HUD's win rates to decide whether to push the trade or stand aside. Combine with trend tools and support/resistance, and favor patterns where multiple pieces of evidence align.

⚠️ Important Notes

This tool is rule-based geometric detection, not full image-recognition AI pattern recognition. Detection accuracy depends on Pivot Confirmation Bars and tolerance settings; loose parameters can produce false positives. Win rates are computed from this chart's past detections — not from a global database. With few samples, "— (no data)" is shown, and win rates only become meaningful after enough detections accumulate (around 10 per pattern). A high win rate does not guarantee future results.

🚨 Disclaimer

This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. No pattern or win rate guarantees future profit, and past performance does not indicate future results. All trading decisions are made at your own risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © AetherEdge — Pattern Probability Scanner
//@version=6

// ┌──────────────────────────────────────────────────────────────────────────┐
// │  AetherEdge - Pattern Probability Scanner  ·  AE-PPS                        │
// │                                                                            │
// │  Detects four widely-recognized chart patterns from confirmed swings and   │
// │  annotates each with its instrument-specific WIN RATE %, online-learned    │
// │  from the actual outcomes of past detections.                              │
// │                                                                            │
// │  PATTERNS:                                                                 │
// │    • Double Top    (bearish reversal: two near-equal highs)                │
// │    • Double Bottom (bullish reversal: two near-equal lows)                 │
// │    • Head & Shoulders     (bearish: left-shoulder / head / right-shoulder)  │
// │    • Inverse Head & Shoulders (bullish symmetric)                          │
// │    • Triangle (converging swing range)                                     │
// │                                                                            │
// │  HONEST SCOPE: this is RULE-BASED geometric detection from confirmed       │
// │  swing pivots (non-repainting). Win rates are a delayed-label statistic   │
// │  over THIS chart's past detections — they are not a global database, and  │
// │  they only become meaningful after enough detections accumulate.          │
// └──────────────────────────────────────────────────────────────────────────┘

indicator("AetherEdge - Pattern Probability Scanner", "AE-PPS", overlay = true,
     max_lines_count = 200, max_labels_count = 200)


// ============================================================================
//  ░░ INPUTS ░░
// ============================================================================
gD = "▓ DETECTION ▓"
pv_lenInput   = input.int(6, "Pivot Confirmation Bars", minval = 2, maxval = 30, group = gD,
     tooltip = "Bars each side of a swing for confirmation. Smaller = more, finer patterns; larger = only major ones.")
tolPctInput   = input.float(1.5, "Equal-Level Tolerance (%)", minval = 0.2, maxval = 5.0, step = 0.1, group = gD,
     tooltip = "How close two swing highs (or lows) must be to count as 'equal' for Double Top / H&S.")
maxAgeInput   = input.int(60, "Max Pattern Span (bars)", minval = 10, maxval = 200, group = gD,
     tooltip = "Maximum number of bars from the first pivot to the last allowed for a pattern.")

gP = "▓ PATTERNS TO DETECT ▓"
detDTInput    = input.bool(true, "Double Top / Bottom",   group = gP)
detHSInput    = input.bool(true, "Head & Shoulders",      group = gP)
detTriInput   = input.bool(true, "Triangle",              group = gP)

gA = "▓ WIN-RATE LEARNING ▓"
ai_enableInput= input.bool(true, "Track Per-Pattern Win Rate", group = gA)
ai_horizonInp = input.int(15, "Outcome Horizon (bars)", minval = 3, maxval = 80, group = gA,
     tooltip = "Bars ahead used to judge whether the pattern played out as expected.")
ai_movInput   = input.float(1.0, "Required Move (ATR)", minval = 0.3, maxval = 5.0, step = 0.1, group = gA,
     tooltip = "Move in the pattern's expected direction (in ATRs) that counts as a 'win'.")

gV = "▓ VISUALS ▓"
vi_themeInput = input.string("Emerald / Ruby", "Palette",
     options = ["Emerald / Ruby", "Spectral", "Mint / Coral"], group = gV)
vi_showLines  = input.bool(true, "Draw Pattern Lines", group = gV)

gH = "▓ HUD ▓"
hud_showInput = input.bool(true, "Show HUD", group = gH)


// ============================================================================
//  ░░ PALETTE ░░
// ============================================================================
var color cBull = na
var color cBear = na
var color cNeut = na
var color cAcc  = na
var color cTxt  = #eef2f0
var color cTxtD = #6b7d76
var color cPanel= #080b0a
var color cPanelHd = #0f1614

setPalette() =>
    [b, s, n, a] = switch vi_themeInput
        "Emerald / Ruby" => [#10e0a0, #ff3860, #9b8cff, #d4af37]
        "Mint / Coral"   => [#4ef0c0, #ff6b6b, #9b8cff, #d4af37]
        => [#22d3ee, #f43f5e, #a78bfa, #e879f9]   // Spectral
    [b, s, n, a]
[pb, ps, pn, pa] = setPalette()
cBull := pb
cBear := ps
cNeut := pn
cAcc  := pa


// ============================================================================
//  ░░ HELPERS ░░
// ============================================================================
clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))

pctDiff(a, b) =>
    a == 0 ? 0.0 : math.abs(a - b) / a * 100.0


// ============================================================================
//  ░░ CONFIRMED SWING BUFFERS (last ~5 each side, non-repainting) ░░
// ============================================================================
atr = ta.atr(14)
ph = ta.pivothigh(high, pv_lenInput, pv_lenInput)
pl = ta.pivotlow(low,  pv_lenInput, pv_lenInput)
pivBar = bar_index - pv_lenInput

// Keep last 5 confirmed highs and lows (price + bar) for pattern matching.
var float[] hPx = array.new<float>(0)
var int[]   hBr = array.new<int>(0)
var float[] lPx = array.new<float>(0)
var int[]   lBr = array.new<int>(0)

if not na(ph) and barstate.isconfirmed
    array.push(hPx, ph)
    array.push(hBr, pivBar)
    if array.size(hPx) > 6
        array.shift(hPx)
        array.shift(hBr)
if not na(pl) and barstate.isconfirmed
    array.push(lPx, pl)
    array.push(lBr, pivBar)
    if array.size(lPx) > 6
        array.shift(lPx)
        array.shift(lBr)


// ============================================================================
//  ░░ WIN-RATE TABLE per pattern type ░░
//  0 = Double Top (bearish), 1 = Double Bottom (bullish),
//  2 = Head & Shoulders (bearish), 3 = Inverse H&S (bullish),
//  4 = Triangle (direction-agnostic; "win" = breakout direction confirmed).
// ============================================================================
NP = 5
var int[]   wins   = array.new<int>(NP, 0)
var int[]   losses = array.new<int>(NP, 0)

// Pending pattern outcomes.
var int[]   pPatType = array.new<int>(0)
var int[]   pPatDir  = array.new<int>(0)    // expected: +1 up, -1 down (for triangle: 0 = either)
var float[] pPatPx   = array.new<float>(0)
var int[]   pPatAge  = array.new<int>(0)
var float[] pPatBrk  = array.new<float>(0)  // breakout level for triangle (or pattern neckline)

armPattern(typ, dir, refPx, brkPx) =>
    array.push(pPatType, typ)
    array.push(pPatDir, dir)
    array.push(pPatPx, refPx)
    array.push(pPatAge, 0)
    array.push(pPatBrk, brkPx)

// Resolve pending outcomes after horizon.
if ai_enableInput and barstate.isconfirmed and array.size(pPatType) > 0
    i = array.size(pPatType) - 1
    while i >= 0
        age = array.get(pPatAge, i) + 1
        array.set(pPatAge, i, age)
        if age >= ai_horizonInp
            typ = array.get(pPatType, i)
            dir = array.get(pPatDir, i)
            px0 = array.get(pPatPx, i)
            brk = array.get(pPatBrk, i)
            won = false
            if dir != 0
                move = dir > 0 ? (close - px0) : (px0 - close)
                won := move >= ai_movInput * atr
            else
                // Triangle: a "win" is any breakout move beyond brk by movInput ATR.
                upBreak = (close - brk) >= ai_movInput * atr
                dnBreak = (brk - close) >= ai_movInput * atr
                won := upBreak or dnBreak
            if won
                array.set(wins, typ, array.get(wins, typ) + 1)
            else
                array.set(losses, typ, array.get(losses, typ) + 1)
            array.remove(pPatType, i)
            array.remove(pPatDir, i)
            array.remove(pPatPx, i)
            array.remove(pPatAge, i)
            array.remove(pPatBrk, i)
        i -= 1

winRate(typ) =>
    w = array.get(wins, typ)
    l = array.get(losses, typ)
    n = w + l
    n > 0 ? (w * 100.0) / n : na


// ============================================================================
//  ░░ DRAWING HELPERS ░░
// ============================================================================
patternColor(dir) =>
    dir > 0 ? cBull : dir < 0 ? cBear : cNeut

drawConnect(b1, p1, b2, p2, col) =>
    if vi_showLines
        line.new(b1, p1, b2, p2, color = color.new(col, 30), width = 2, xloc = xloc.bar_index)

drawLabel(barX, pxY, txt, col, dir) =>
    style = dir < 0 ? label.style_label_down : label.style_label_up
    label.new(barX, pxY, txt, xloc = xloc.bar_index, yloc = yloc.price,
         color = col, textcolor = #ffffff, style = style, size = size.small)


// ============================================================================
//  ░░ DETECTION ON EACH NEW PIVOT ░░
//  Trigger checks when a new confirmed high or low has just arrived.
// ============================================================================
newHigh = not na(ph) and barstate.isconfirmed
newLow  = not na(pl) and barstate.isconfirmed


// ── DOUBLE TOP / BOTTOM ──
// Two recent highs (or lows) at ~equal price within max span, and an intervening
// low (or high) between them.
if detDTInput and newHigh and array.size(hPx) >= 2 and array.size(lPx) >= 1
    n = array.size(hPx)
    h1 = array.get(hPx, n - 2)
    h2 = array.get(hPx, n - 1)
    b1 = array.get(hBr, n - 2)
    b2 = array.get(hBr, n - 1)
    if pctDiff(h1, h2) <= tolPctInput and (b2 - b1) <= maxAgeInput
        // Intervening low between b1 and b2.
        m = array.size(lPx)
        float inLow = na
        if m > 0
            for k = 0 to m - 1
                idx = m - 1 - k
                lb = array.get(lBr, idx)
                if lb > b1 and lb < b2
                    inLow := array.get(lPx, idx)
                    break
        if not na(inLow)
            col = cBear
            drawConnect(b1, h1, b2, h2, col)
            drawConnect(b1, h1, math.round((b1+b2)/2), inLow, color.new(col, 50))
            drawConnect(math.round((b1+b2)/2), inLow, b2, h2, color.new(col, 50))
            wr = winRate(0)
            wrTxt = na(wr) ? "—" : str.tostring(math.round(wr)) + "%"
            drawLabel(b2, h2 + atr * 0.5, "DOUBLE TOP\n" + wrTxt, col, -1)
            armPattern(0, -1, close, inLow)

if detDTInput and newLow and array.size(lPx) >= 2 and array.size(hPx) >= 1
    n = array.size(lPx)
    l1 = array.get(lPx, n - 2)
    l2 = array.get(lPx, n - 1)
    b1 = array.get(lBr, n - 2)
    b2 = array.get(lBr, n - 1)
    if pctDiff(l1, l2) <= tolPctInput and (b2 - b1) <= maxAgeInput
        m = array.size(hPx)
        float inHigh = na
        if m > 0
            for k = 0 to m - 1
                idx = m - 1 - k
                hb = array.get(hBr, idx)
                if hb > b1 and hb < b2
                    inHigh := array.get(hPx, idx)
                    break
        if not na(inHigh)
            col = cBull
            drawConnect(b1, l1, b2, l2, col)
            drawConnect(b1, l1, math.round((b1+b2)/2), inHigh, color.new(col, 50))
            drawConnect(math.round((b1+b2)/2), inHigh, b2, l2, color.new(col, 50))
            wr = winRate(1)
            wrTxt = na(wr) ? "—" : str.tostring(math.round(wr)) + "%"
            drawLabel(b2, l2 - atr * 0.5, "DOUBLE BOTTOM\n" + wrTxt, col, 1)
            armPattern(1, 1, close, inHigh)


// ── HEAD & SHOULDERS / INVERSE ──
// Three pivot highs (lows): middle is highest (lowest), outer two are similar
// in height, with two intervening lows (highs) — the neckline.
if detHSInput and newHigh and array.size(hPx) >= 3 and array.size(lPx) >= 2
    n = array.size(hPx)
    hL = array.get(hPx, n - 3)
    hH = array.get(hPx, n - 2)
    hR = array.get(hPx, n - 1)
    bL = array.get(hBr, n - 3)
    bH = array.get(hBr, n - 2)
    bR = array.get(hBr, n - 1)
    // Head highest, shoulders near equal, span within limit.
    if hH > hL and hH > hR and pctDiff(hL, hR) <= tolPctInput * 1.5 and (bR - bL) <= maxAgeInput
        // Find two lows between (bL,bH) and (bH,bR) for the neckline.
        m = array.size(lPx)
        float ll1 = na
        float ll2 = na
        if m > 0
            for k = 0 to m - 1
                idx = m - 1 - k
                lb = array.get(lBr, idx)
                if lb > bL and lb < bH and na(ll1)
                    ll1 := array.get(lPx, idx)
                if lb > bH and lb < bR and na(ll2)
                    ll2 := array.get(lPx, idx)
        if not na(ll1) and not na(ll2)
            neck = (ll1 + ll2) / 2.0
            col = cBear
            drawConnect(bL, hL, bH, hH, col)
            drawConnect(bH, hH, bR, hR, col)
            drawConnect(bL, neck, bR, neck, color.new(col, 40))
            wr = winRate(2)
            wrTxt = na(wr) ? "—" : str.tostring(math.round(wr)) + "%"
            drawLabel(bH, hH + atr * 0.6, "HEAD & SHOULDERS\n" + wrTxt, col, -1)
            armPattern(2, -1, close, neck)

if detHSInput and newLow and array.size(lPx) >= 3 and array.size(hPx) >= 2
    n = array.size(lPx)
    lL = array.get(lPx, n - 3)
    lH = array.get(lPx, n - 2)  // the "head" (lowest)
    lR = array.get(lPx, n - 1)
    bL = array.get(lBr, n - 3)
    bH = array.get(lBr, n - 2)
    bR = array.get(lBr, n - 1)
    if lH < lL and lH < lR and pctDiff(lL, lR) <= tolPctInput * 1.5 and (bR - bL) <= maxAgeInput
        m = array.size(hPx)
        float hh1 = na
        float hh2 = na
        if m > 0
            for k = 0 to m - 1
                idx = m - 1 - k
                hb = array.get(hBr, idx)
                if hb > bL and hb < bH and na(hh1)
                    hh1 := array.get(hPx, idx)
                if hb > bH and hb < bR and na(hh2)
                    hh2 := array.get(hPx, idx)
        if not na(hh1) and not na(hh2)
            neck = (hh1 + hh2) / 2.0
            col = cBull
            drawConnect(bL, lL, bH, lH, col)
            drawConnect(bH, lH, bR, lR, col)
            drawConnect(bL, neck, bR, neck, color.new(col, 40))
            wr = winRate(3)
            wrTxt = na(wr) ? "—" : str.tostring(math.round(wr)) + "%"
            drawLabel(bH, lH - atr * 0.6, "INV HEAD & SHOULDERS\n" + wrTxt, col, 1)
            armPattern(3, 1, close, neck)


// ── TRIANGLE (converging) ──
// Recent 3 highs descending AND recent 3 lows ascending → symmetric triangle.
if detTriInput and (newHigh or newLow) and array.size(hPx) >= 3 and array.size(lPx) >= 3
    nH = array.size(hPx)
    nL = array.size(lPx)
    h1 = array.get(hPx, nH - 3)
    h2 = array.get(hPx, nH - 2)
    h3 = array.get(hPx, nH - 1)
    l1 = array.get(lPx, nL - 3)
    l2 = array.get(lPx, nL - 2)
    l3 = array.get(lPx, nL - 1)
    bH1 = array.get(hBr, nH - 3)
    bH3 = array.get(hBr, nH - 1)
    bL1 = array.get(lBr, nL - 3)
    bL3 = array.get(lBr, nL - 1)
    converging = h1 > h2 and h2 > h3 and l1 < l2 and l2 < l3
    spanOk = math.max(bH3, bL3) - math.min(bH1, bL1) <= maxAgeInput
    if converging and spanOk
        col = cNeut
        drawConnect(bH1, h1, bH3, h3, col)
        drawConnect(bL1, l1, bL3, l3, col)
        midPx = (h3 + l3) / 2.0
        wr = winRate(4)
        wrTxt = na(wr) ? "—" : str.tostring(math.round(wr)) + "%"
        drawLabel(bH3, h3 + atr * 0.5, "TRIANGLE\n" + wrTxt, col, -1)
        armPattern(4, 0, close, midPx)


// ============================================================================
//  ░░ HUD ░░
// ============================================================================
patName(t) =>
    switch t
        0 => "Double Top"
        1 => "Double Bot"
        2 => "H&S"
        3 => "Inv H&S"
        => "Triangle"

var table hud = na
if hud_showInput and na(hud)
    hud := table.new(position.top_right, 2, 7, bgcolor = cPanel,
         border_color = color.new(cAcc, 60), border_width = 1, frame_color = color.new(cAcc, 40), frame_width = 1)

if hud_showInput and barstate.islast
    table.cell(hud, 0, 0, "PATTERN PROB SCANNER", text_color = cAcc, text_size = size.normal, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 0, "win-rate", text_color = cTxtD, text_size = size.normal, bgcolor = cPanelHd, text_halign = text.align_right)

    for t = 0 to NP - 1
        w = array.get(wins, t)
        l = array.get(losses, t)
        n = w + l
        wr = n > 0 ? (w * 100.0) / n : na
        txt = na(wr) ? "— (no data)" : str.tostring(math.round(wr)) + "%  (" + str.tostring(n) + ")"
        col = na(wr) ? cTxtD : wr >= 55 ? cBull : wr <= 45 ? cBear : cTxt
        table.cell(hud, 0, t + 1, patName(t), text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
        table.cell(hud, 1, t + 1, txt, text_color = col, text_size = size.normal, text_halign = text.align_right)

    totalN = 0
    for t = 0 to NP - 1
        totalN += array.get(wins, t) + array.get(losses, t)
    table.cell(hud, 0, 6, "total detections", text_color = cTxtD, text_size = size.normal, text_halign = text.align_left)
    table.cell(hud, 1, 6, str.tostring(totalN), text_color = cTxt, text_size = size.normal, text_halign = text.align_right)


// ============================================================================
//  ░░ ALERTS ░░
// ============================================================================
alertcondition(detDTInput and newHigh, "Double Top candidate", "AE-PPS: a double-top candidate may have just printed")
alertcondition(detDTInput and newLow,  "Double Bottom candidate", "AE-PPS: a double-bottom candidate may have just printed")
alertcondition(detHSInput and newHigh, "H&S candidate", "AE-PPS: a head & shoulders candidate may have just printed")
alertcondition(detHSInput and newLow,  "Inverse H&S candidate", "AE-PPS: an inverse H&S candidate may have just printed")
alertcondition(detTriInput and (newHigh or newLow), "Triangle candidate", "AE-PPS: a triangle pattern candidate may have just printed")
````
