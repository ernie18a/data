# AetherEdge - Pattern Edge Learner

- url: https://www.tradingview.com/script/Zc7zhbEn/
- type: indicator
- pine_id: PUB;3c29c3bd00f8494d9030e16a1fda939d
- version: 1.0

## Description

🖊️ Overview

Most pattern tools hard-code the textbook ("engulfing = bullish"). AE-PAT throws that out and measures each shape's forward edge from this market's own history. It encodes recent price action as a normalized signature and aggregates what past analogues did next via kernel regression — telling you which shapes actually work now, as an up-probability, expected move, and confidence (effective neighbors). It also shows learned win-rates for five classic candlestick patterns.

🔶 Key Features

Learned shape signatures — encodes the last L bars as an ATR-normalized shape and learns the forward edge from analogues
Non-parametric (kernel regression) — estimates "this shape did X" from data, no hard-coded lore
Up-probability + expected move + confidence — including how many analogues exist (effective neighbors)
Measured win-rates of classic patterns — bull/bear engulfing, hammer, shooting star, doji (the record, not the textbook)
Pattern signals — fire only when the learned edge is strong with enough analogues
Bar coloring for the edge; bar-close training and signals — no repaint

🧠 Technical Architecture

Shape signature: the last L bars encoded as four features each (body / upper wick / lower wick / return, normalized by each bar's ATR = scale-invariant), F = L×4 dims.
ML (Nadaraya-Watson kernel regression): a memory bank stores, each bar, the signature from N bars ago plus its realized outcome (up/down + forward return; no lookahead). The current signature is weighted against the whole memory by a Gaussian kernel exp(−dist²/2h²), yielding P(up), expected move, and effective neighbors (confidence). The estimate adapts as shapes change.
Stats (Beta-Bernoulli): online win-rates for five classic patterns, updated from the outcome N bars after each occurrence.
Honest scope: kernel regression + Bernoulli counting (no RL). Not deep learning, not a guarantee.

⚙️ Recommended Settings & Tuning Guide (crypto 15m–4H)

Key parameters: signature window L, outcome horizon N, up threshold (ATR), memory size, kernel bandwidth, bull/bear edge thresholds, min effective neighbors.
Window L ≈ 3–5 (larger captures complex shapes but yields fewer analogues)
N is the bars to measure the outcome; 8–15 for 15m–1H
Bandwidth controls match tolerance (smaller = stricter/fewer neighbors, larger = smoother)
Min effective neighbors ensures firing only with enough analogues
⚠️ It's a memory × dimension scan; if you hit a "script takes too long" error on long timeframes, lower the memory size

💡 How to Use in Practice

Use the pattern triangles for shape-backed entries
Read P(up) and expected move for direction/size, and stand aside when effective neighbors is low
Use the classic-pattern table to check "is the hammer working now / what's the engulfing win-rate" and drop assumptions
Combine with AE-MRB (mean reversion) or AE-CORR (drivers) to layer shape × context

⚠️ Important Notes

Needs a learning period (warmup) and memory to build; memory resets on timeframe/parameter change
Past analogues are not guaranteed to resolve the same now (regime shifts break it)
Rare shapes have few neighbors and lower confidence
Probability, not a guarantee — always do your own due diligence and use risk management

🚨 Disclaimer

This indicator is for educational and informational purposes only and is not financial advice or a recommendation to buy or sell. No method guarantees future profits; past performance does not indicate future results, and trading carries the risk of loss. All decisions are your own — use proper validation and disciplined risk management.

## Source Code

````pine
// ============================================================================
//  AetherEdge - Pattern Edge Learner  (AE-PAT)  |  AetherEdge Series
//  Which price patterns actually have an edge RIGHT NOW -- learned, not lore
//
//  Most pattern tools hard-code "engulfing = bullish." AE-PAT throws out the
//  lore and measures the edge from this market's own history:
//
//    * ML : the last L bars are encoded as an ATR-normalized SHAPE SIGNATURE
//      (body, upper wick, lower wick, return per bar). A NADARAYA-WATSON kernel
//      regression over a memory bank of past signatures and their realized
//      N-bar outcomes returns the current shape's edge -- P(up) and expected
//      move from its closest historical analogues, with an effective-neighbor
//      count for confidence. Non-parametric; it adapts as the market changes.
//    * STATS : five named candlestick patterns (bull/bear engulfing, hammer,
//      shooting star, doji) carry an ONLINE BETA-BERNOULLI win-rate, so you see
//      which classic patterns are actually working now -- not what a textbook
//      claims. No lookahead: every outcome is N-bar-lagged.
//
//  Signals fire only when the learned edge is strong with enough analogues.
//  Honest scope: kernel regression + Bernoulli counting over standard features
//  -- not a neural net, not a guarantee, no RL. Storage and signals gate on
//  bar close.
// ============================================================================

//@version=6
indicator("AetherEdge - Pattern Edge Learner", "AE-PAT", overlay = true, max_bars_back = 500)

// ----------------------------------------------------------------------------
//  THEME
// ----------------------------------------------------------------------------
cGold = #d4af37
cBg0  = #080b0a
cBg1  = #0f1614
cTxt  = #eef2f0
cBull = #26a69a
cBear = #ef5350
cWait = #8d99a6
cViolet = #b06fd6

// ----------------------------------------------------------------------------
//  INPUTS
// ----------------------------------------------------------------------------
grpM = "Pattern memory"
winL   = input.int(4, "Signature window L (bars)", minval = 2, maxval = 6, group = grpM)
horizonN = input.int(10, "Outcome horizon N (bars)", minval = 2, group = grpM)
moveK  = input.float(0.0, "Up threshold (ATR, 0=any up)", minval = 0.0, step = 0.1, group = grpM)
memCap = input.int(400, "Memory size", minval = 50, maxval = 800, group = grpM)
bandw  = input.float(3.0, "Kernel bandwidth", minval = 0.3, step = 0.1, group = grpM)
warmup = input.int(200, "Warmup bars", minval = 30, group = grpM)

grpS = "Signals"
pHi = input.float(0.58, "Bullish edge P(up) >=", minval = 0.5, maxval = 0.95, step = 0.01, group = grpS)
pLo = input.float(0.42, "Bearish edge P(up) <=", minval = 0.05, maxval = 0.5, step = 0.01, group = grpS)
minN = input.float(8.0, "Min effective neighbors", minval = 1.0, step = 1.0, group = grpS)
showSig = input.bool(true, "Show pattern signals", group = grpS)

grpUI = "Dashboard"
showHUD = input.bool(true, "Show HUD", group = grpUI)
hudSize = input.string("small", "Table size", options = ["tiny","small","normal","large"], group = grpUI)

// ----------------------------------------------------------------------------
//  HELPERS
// ----------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))
f_txtSize() => hudSize == "tiny" ? size.tiny : hudSize == "small" ? size.small : hudSize == "large" ? size.large : size.normal

atr = math.max(ta.atr(14), 1e-8)
int FB = 4                          // features per bar
F = winL * FB                       // signature length
stride = F + 2                      // + outcome + forward return

// signature ending at history offset b (b=0 current)
f_sig(int b) =>
    a = array.new_float(0)
    for j = 0 to winL - 1
        o = b + j
        at = math.max(atr[o], 1e-8)
        array.push(a, f_clamp((close[o] - open[o]) / at, -5.0, 5.0))
        array.push(a, f_clamp((high[o] - math.max(open[o], close[o])) / at, 0.0, 5.0))
        array.push(a, f_clamp((math.min(open[o], close[o]) - low[o]) / at, 0.0, 5.0))
        array.push(a, f_clamp((close[o] - close[o + 1]) / at, -5.0, 5.0))
    a

// ----------------------------------------------------------------------------
//  MEMORY BANK + KERNEL REGRESSION
// ----------------------------------------------------------------------------
var array<float> mem = array.new_float(0)

// store the signature from N bars ago (its outcome is now known)
if barstate.isconfirmed and bar_index > horizonN + winL + 1
    sigOld = f_sig(horizonN)
    upMove = (close - close[horizonN]) >= moveK * atr[horizonN]
    fwdRet = (close / close[horizonN] - 1.0) * 100.0
    for f = 0 to F - 1
        array.push(mem, array.get(sigOld, f))
    array.push(mem, upMove ? 1.0 : 0.0)
    array.push(mem, fwdRet)
    if array.size(mem) > memCap * stride
        for rmv = 0 to stride - 1
            array.shift(mem)

// query current signature
sigNow = f_sig(0)
int m = int(array.size(mem) / stride)
float sw = 0.0
float swO = 0.0
float swR = 0.0
float sw2 = 0.0
if m > 0
    h2 = 2.0 * bandw * bandw
    for s = 0 to m - 1
        base = s * stride
        d = 0.0
        for f = 0 to F - 1
            df = array.get(sigNow, f) - array.get(mem, base + f)
            d += df * df
        wj = math.exp(-d / h2)
        sw += wj
        swO += wj * array.get(mem, base + F)
        swR += wj * array.get(mem, base + F + 1)
        sw2 += wj * wj

float pUp = sw > 0.0 ? swO / sw : na
float expMove = sw > 0.0 ? swR / sw : na
float effN = sw > 0.0 ? sw * sw / math.max(sw2, 1e-12) : 0.0
warmOK = bar_index > warmup and m > 30

// ----------------------------------------------------------------------------
//  NAMED CANDLESTICK PATTERNS  (online Beta-Bernoulli win-rate)
// ----------------------------------------------------------------------------
body = close - open
rng = math.max(high - low, 1e-8)
upW = high - math.max(open, close)
loW = math.min(open, close) - low
ab = math.abs(body)

pBull = close > open and close[1] < open[1] and close >= open[1] and open <= close[1]
pBear = close < open and close[1] > open[1] and close <= open[1] and open >= close[1]
pHam  = loW > 2.0 * ab and upW < ab and (high - close) < 0.4 * rng
pSho  = upW > 2.0 * ab and loW < ab and (close - low) < 0.4 * rng
pDoj  = ab < 0.1 * rng

var float aBull = 1.0
var float bBull = 1.0
var float aBear = 1.0
var float bBear = 1.0
var float aHam = 1.0
var float bHam = 1.0
var float aSho = 1.0
var float bSho = 1.0
var float aDoj = 1.0
var float bDoj = 1.0

if barstate.isconfirmed and bar_index > horizonN
    up = close > close[horizonN] ? 1.0 : 0.0
    dn = 1.0 - up
    if pBull[horizonN]
        aBull += up
        bBull += dn
    if pBear[horizonN]
        aBear += up
        bBear += dn
    if pHam[horizonN]
        aHam += up
        bHam += dn
    if pSho[horizonN]
        aSho += up
        bSho += dn
    if pDoj[horizonN]
        aDoj += up
        bDoj += dn

f_wr(float a, float b) => a / (a + b)
f_n(float a, float b) => int(a + b - 2.0)

// ----------------------------------------------------------------------------
//  SIGNALS
// ----------------------------------------------------------------------------
bullEdge = warmOK and not na(pUp) and pUp >= pHi and effN >= minN
bearEdge = warmOK and not na(pUp) and pUp <= pLo and effN >= minN
bullSig = bullEdge and not bullEdge[1]
bearSig = bearEdge and not bearEdge[1]

plotshape(showSig and bullSig ? low : na, "Bull pattern", shape.triangleup, location.belowbar, color.new(cBull, 0), size = size.small)
plotshape(showSig and bearSig ? high : na, "Bear pattern", shape.triangledown, location.abovebar, color.new(cBear, 0), size = size.small)

bc = na(pUp) ? na : pUp >= pHi ? color.new(cBull, 40) : pUp <= pLo ? color.new(cBear, 40) : na
barcolor(warmOK ? bc : na)

// ----------------------------------------------------------------------------
//  HUD
// ----------------------------------------------------------------------------
edgeTxt = bullEdge ? "BULL EDGE" : bearEdge ? "BEAR EDGE" : "—"
edgeCol = bullEdge ? cBull : bearEdge ? cBear : cWait

var table hud = table.new(position.top_right, 3, 13, bgcolor = cBg1, frame_color = cGold, frame_width = 2, border_color = color.new(cGold, 60), border_width = 1)
if showHUD and barstate.islast
    ts = f_txtSize()
    table.cell(hud, 0, 0, "AE-PAT", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 0, edgeTxt, text_color = edgeCol, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 2, 0, "", bgcolor = cBg0, text_size = ts)
    table.cell(hud, 0, 1, "Pattern P(up)", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 1, na(pUp) ? "-" : str.tostring(math.round(pUp * 100)) + "%", text_color = na(pUp) ? cWait : pUp >= pHi ? cBull : pUp <= pLo ? cBear : cTxt, text_size = ts)
    table.cell(hud, 2, 1, "", text_size = ts)
    table.cell(hud, 0, 2, "Expected move", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 2, na(expMove) ? "-" : (expMove >= 0 ? "+" : "") + str.tostring(expMove, "#.##") + "%", text_color = na(expMove) ? cWait : expMove >= 0 ? cBull : cBear, text_size = ts)
    table.cell(hud, 2, 2, "", text_size = ts)
    table.cell(hud, 0, 3, "Confidence (eff. N)", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 3, str.tostring(effN, "#.#"), text_color = effN >= minN ? cBull : cWait, text_size = ts)
    table.cell(hud, 2, 3, "", text_size = ts)
    table.cell(hud, 0, 4, "Memory", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 4, str.tostring(m), text_color = cWait, text_size = ts)
    table.cell(hud, 2, 4, warmOK ? "live" : "learning", text_color = warmOK ? cBull : cWait, text_size = ts)
    // named patterns
    table.cell(hud, 0, 5, "Pattern", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 5, "Up%", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 2, 5, "n", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 0, 6, "Bull engulf", text_color = pBull ? cGold : cTxt, text_size = ts)
    table.cell(hud, 1, 6, str.tostring(math.round(f_wr(aBull, bBull) * 100)) + "%", text_color = f_wr(aBull, bBull) >= 0.5 ? cBull : cBear, text_size = ts)
    table.cell(hud, 2, 6, str.tostring(f_n(aBull, bBull)), text_color = cWait, text_size = ts)
    table.cell(hud, 0, 7, "Bear engulf", text_color = pBear ? cGold : cTxt, text_size = ts)
    table.cell(hud, 1, 7, str.tostring(math.round(f_wr(aBear, bBear) * 100)) + "%", text_color = f_wr(aBear, bBear) >= 0.5 ? cBull : cBear, text_size = ts)
    table.cell(hud, 2, 7, str.tostring(f_n(aBear, bBear)), text_color = cWait, text_size = ts)
    table.cell(hud, 0, 8, "Hammer", text_color = pHam ? cGold : cTxt, text_size = ts)
    table.cell(hud, 1, 8, str.tostring(math.round(f_wr(aHam, bHam) * 100)) + "%", text_color = f_wr(aHam, bHam) >= 0.5 ? cBull : cBear, text_size = ts)
    table.cell(hud, 2, 8, str.tostring(f_n(aHam, bHam)), text_color = cWait, text_size = ts)
    table.cell(hud, 0, 9, "Shooting star", text_color = pSho ? cGold : cTxt, text_size = ts)
    table.cell(hud, 1, 9, str.tostring(math.round(f_wr(aSho, bSho) * 100)) + "%", text_color = f_wr(aSho, bSho) >= 0.5 ? cBull : cBear, text_size = ts)
    table.cell(hud, 2, 9, str.tostring(f_n(aSho, bSho)), text_color = cWait, text_size = ts)
    table.cell(hud, 0, 10, "Doji", text_color = pDoj ? cGold : cTxt, text_size = ts)
    table.cell(hud, 1, 10, str.tostring(math.round(f_wr(aDoj, bDoj) * 100)) + "%", text_color = f_wr(aDoj, bDoj) >= 0.5 ? cBull : cBear, text_size = ts)
    table.cell(hud, 2, 10, str.tostring(f_n(aDoj, bDoj)), text_color = cWait, text_size = ts)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
alertcondition(bullSig, "AE-PAT Bullish pattern", "AE-PAT: current shape has a learned bullish edge")
alertcondition(bearSig, "AE-PAT Bearish pattern", "AE-PAT: current shape has a learned bearish edge")
````
