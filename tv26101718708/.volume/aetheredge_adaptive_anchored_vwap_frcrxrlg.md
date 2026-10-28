# AetherEdge - Adaptive Anchored VWAP

- url: https://www.tradingview.com/script/fRCrxRLG/
- type: indicator
- pine_id: PUB;9a86f726aba94421bced3b4eb26504d5
- version: 1.0

## Description

🖊️ Overview

Anchored VWAP marks the volume-weighted cost basis from an event. AE-VWAP picks the anchor for you and learns whether reclaiming the VWAP actually means something. It auto-anchors at significant swings, conformally calibrates its volume-weighted σ-bands to a target containment, and learns the follow-through probability after price crosses the anchored VWAP.

🔶 Key Features

Auto-anchored VWAP — anchors at significant swings (Session / Manual also available)
Volume-weighted σ-bands — standard-deviation bands weighted by volume
Conformally calibrated bands — no normality assumption; band width k is set to hit a target containment
Learned reclaim edge — follow-through probability after a VWAP reclaim/loss (signal only when the odds back it)
Realized containment — shows how well the bands are calibrated
Reclaim signals + anchor markers + alerts; bar-close training — no repaint

🧠 Technical Architecture

VWAP: the source (hlc3/close/ohlc4) is volume-weighted: vwap = Σ(price·vol)/Σvol, σ = √(Σ vol·price²/Σvol − vwap²). Anchor modes: Auto (pivot confirmation) / Session (daily) / Manual (date).
Bands (conformal calibration): k is set to the (1−α) quantile of the standardized deviation |src−vwap|/σ, matching the target containment empirically. A fixed normal-assumption k tends to under-contain on fat tails — conformal fixes that.
ML (online logistic): at a VWAP reclaim (close × VWAP cross), six side-oriented features (momentum, trend alignment, RSI, σ-band-width regime, volume, anchor age) predict the follow-through probability = P(price continues tpK·ATR in the cross direction before recrossing, within N bars) via a triple barrier. No lookahead.
Honest scope: a volume-weighted mean + conformal calibration + a linear classifier (no RL). Not deep learning, not a guarantee.

⚙️ Recommended Settings & Tuning Guide (crypto 15m–4H)

Key parameters: anchor mode, pivot strength, band width k / conformal calibration, target outside fraction, follow-through (ATR), horizon N, min follow-through probability.
Anchor: "Auto (pivots)" to catch trend origins, "Session" for a daily basis, "Manual" for a specific event
Higher pivot strength anchors only on bigger swings (fewer re-anchors)
Turn on conformal calibration so bands match the real containment (check the containment %)
Follow-through (ATR) defines what counts as success
Best on liquid symbols with reliable volume (major crypto, futures)

💡 How to Use in Practice

Use the anchored VWAP as the institutional cost basis / fair value (above = buyers in control, below = sellers)
Use the σ-bands for overextension/containment; outside the band is statistically unusual
Use reclaim signals (with probability) to filter genuine VWAP-reclaim breaks
If containment drifts from target, reconsider calibration or σ validity
Combine with AE-CVD (flow) or AE-RISK (sizing)

⚠️ Important Notes

Auto-anchoring lags by the pivot confirmation, and the basis shifts on re-anchor
The follow-through forecast is a probability and will miss (reclaims can fail)
Needs a learning period (warmup); learning resets on anchor/timeframe/parameter change
Probability, not a guarantee — always do your own due diligence and use risk management

🚨 Disclaimer

This indicator is for educational and informational purposes only and is not financial advice or a recommendation to buy or sell. No method guarantees future profits; past performance does not indicate future results, and trading carries the risk of loss. All decisions are your own — use proper validation and disciplined risk management.

## Source Code

````pine
// ============================================================================
//  AetherEdge - Adaptive Anchored VWAP  (AE-VWAP)  |  AetherEdge Series
//  Anchored VWAP that re-anchors itself, with a LEARNED reclaim edge
//
//  Anchored VWAP marks the volume-weighted cost basis from an event. AE-VWAP
//  picks the anchor for you and learns whether reclaiming it actually means
//  something:
//
//    * VWAP : auto-anchors at confirmed swing pivots (or Session / Manual),
//      with VOLUME-WEIGHTED sigma bands. The band width k is CONFORMALLY
//      calibrated -- set to the quantile of standardized deviations so the
//      bands hit a target containment instead of assuming normality.
//    * ML : an ONLINE LOGISTIC learns the FOLLOW-THROUGH edge of a VWAP reclaim
//      (price crossing the anchored VWAP) = P(price continues tpK*ATR in the
//      cross direction before recrossing, within N bars), from a triple-barrier
//      outcome over an array<Setup>. Reclaims only signal when the odds back
//      them. Features are oriented to the cross side; no lookahead.
//
//  Outputs the anchored VWAP + calibrated bands, reclaim signals, realized
//  containment, and the current reclaim probability. Honest scope: a volume-
//  weighted mean + conformal calibration + a linear classifier -- not a neural
//  net, not a guarantee, no RL. Training gates on bar close.
// ============================================================================

//@version=6
indicator("AetherEdge - Adaptive Anchored VWAP", "AE-VWAP", overlay = true, max_labels_count = 100)

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
grpA = "Anchor"
anchorMode = input.string("Auto (pivots)", "Anchor mode", options = ["Auto (pivots)","Session (daily)","Manual"], group = grpA)
pivL = input.int(20, "Pivot strength", minval = 2, group = grpA)
manualTime = input.time(timestamp("2024-01-01 00:00"), "Manual anchor", group = grpA)
srcType = input.string("hlc3", "Source", options = ["hlc3","close","ohlc4"], group = grpA)

grpB = "Bands"
kBand = input.float(2.0, "Band width k (σ)", minval = 0.5, step = 0.1, group = grpB)
adaptiveBand = input.bool(true, "Conformal-calibrate k", group = grpB)
bandAlpha = input.float(0.10, "Target outside fraction", minval = 0.01, maxval = 0.5, step = 0.01, group = grpB)
calibN = input.int(250, "Calibration window", minval = 20, group = grpB)

grpM = "Reclaim model"
tpK = input.float(1.5, "Follow-through (ATR)", minval = 0.2, step = 0.1, group = grpM)
horizonN = input.int(15, "Barrier horizon N (bars)", minval = 3, group = grpM)
lr = input.float(0.03, "Learning rate", minval = 0.001, step = 0.005, group = grpM)
pThr = input.float(0.55, "Min follow-through prob", minval = 0.0, maxval = 1.0, step = 0.01, group = grpM)
fastLen = input.int(10, "Trend fast", minval = 2, group = grpM)
slowLen = input.int(30, "Trend slow", minval = 3, group = grpM)
rsiLen = input.int(14, "RSI length", minval = 2, group = grpM)
warmup = input.int(150, "Warmup bars", minval = 20, group = grpM)

grpUI = "Display"
showBands = input.bool(true, "Show σ-bands", group = grpUI)
showSig = input.bool(true, "Show reclaim signals", group = grpUI)
showHUD = input.bool(true, "Show HUD", group = grpUI)
hudSize = input.string("small", "Table size", options = ["tiny","small","normal","large"], group = grpUI)

// ----------------------------------------------------------------------------
//  HELPERS
// ----------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))
f_sigmoid(float z) => 1.0 / (1.0 + math.exp(-f_clamp(z, -30.0, 30.0)))
f_txtSize() => hudSize == "tiny" ? size.tiny : hudSize == "small" ? size.small : hudSize == "large" ? size.large : size.normal

f_quantile(array<float> arr, float a) =>
    float q = na
    int nn = array.size(arr)
    if nn > 0
        c = array.copy(arr)
        array.sort(c, order.ascending)
        int rank = int(math.ceil((1.0 - a) * (nn + 1)))
        rank := math.max(1, math.min(nn, rank))
        q := array.get(c, rank - 1)
    q

f_predict(array<float> w, array<float> x) =>
    z = array.get(w, 0)
    for i = 0 to array.size(x) - 1
        z += array.get(w, i + 1) * array.get(x, i)
    f_sigmoid(z)

f_train(array<float> w, array<float> x, float y, float lrr) =>
    p = f_predict(w, x)
    err = p - y
    array.set(w, 0, array.get(w, 0) - lrr * err)
    for i = 0 to array.size(x) - 1
        array.set(w, i + 1, array.get(w, i + 1) - lrr * err * array.get(x, i))

// ----------------------------------------------------------------------------
//  INDICATORS
// ----------------------------------------------------------------------------
src = srcType == "close" ? close : srcType == "ohlc4" ? ohlc4 : hlc3
atr = math.max(ta.atr(14), 1e-8)
emaF = ta.ema(close, fastLen)
emaS = ta.ema(close, slowLen)
rsi = ta.rsi(close, rsiLen)
volRank = ta.percentrank(atr, 100)
int regime = volRank < 33.0 ? 0 : volRank < 66.0 ? 1 : 2

// ----------------------------------------------------------------------------
//  ANCHOR + VOLUME-WEIGHTED VWAP & SIGMA
// ----------------------------------------------------------------------------
phc = ta.pivothigh(high, pivL, pivL)
plc = ta.pivotlow(low, pivL, pivL)
autoRe = not na(phc) or not na(plc)
sessRe = ta.change(time("D")) != 0
manRe = time >= manualTime and time[1] < manualTime
reAnchor = anchorMode == "Auto (pivots)" ? autoRe : anchorMode == "Session (daily)" ? sessRe : manRe

var float cpv = 0.0
var float cv = 0.0
var float cpv2 = 0.0
var int anchorBar = 0
if reAnchor or cv <= 0.0
    cpv := 0.0
    cv := 0.0
    cpv2 := 0.0
    anchorBar := bar_index
cpv += src * volume
cv += volume
cpv2 += src * src * volume
vwap = cv > 0.0 ? cpv / cv : src
vwVar = cv > 0.0 ? math.max(cpv2 / cv - vwap * vwap, 0.0) : 0.0
vwSig = math.max(math.sqrt(vwVar), 1e-8)

// conformal band-width calibration
var array<float> calib = array.new_float(0)
dev = math.abs(src - vwap) / vwSig
if barstate.isconfirmed
    array.push(calib, dev)
    if array.size(calib) > calibN
        array.shift(calib)
kAuto = nz(f_quantile(calib, bandAlpha), kBand)
kUsed = adaptiveBand ? kAuto : kBand
upper = vwap + kUsed * vwSig
lower = vwap - kUsed * vwSig

// realized containment
var int cIn = 0
var int cTot = 0
if barstate.isconfirmed and bar_index > warmup
    cTot += 1
    cIn += math.abs(src - vwap) <= kUsed * vwSig ? 1 : 0
containment = cTot > 0 ? cIn / cTot * 100.0 : na

// ----------------------------------------------------------------------------
//  FEATURES + RECLAIM MODEL (triple-barrier follow-through)
// ----------------------------------------------------------------------------
f_feat(int side) =>
    f1 = f_clamp(side * (close - close[3]) / atr, -3.0, 3.0)
    f2 = f_clamp(side * (emaF - emaS) / atr, -3.0, 3.0)
    f3 = f_clamp(side * (rsi - 50.0) / 50.0, -1.0, 1.0)
    f4 = f_clamp(vwSig / math.max(ta.sma(vwSig, 50), 1e-8) - 1.0, -1.0, 3.0)
    f5 = f_clamp(volume / math.max(ta.sma(volume, 20), 1e-8) - 1.0, -1.0, 3.0)
    f6 = f_clamp((bar_index - anchorBar) / 50.0, 0.0, 3.0)
    array.from(f1, f2, f3, f4, f5, f6)

type Setup
    float f1
    float f2
    float f3
    float f4
    float f5
    float f6
    int   side
    float entry
    float atr0
    int   age

var array<Setup> setups = array.new<Setup>()
var array<float> w = array.new_float(7, 0.0)

reclaimUp = ta.crossover(close, vwap)
reclaimDn = ta.crossunder(close, vwap)
int sideRe = reclaimUp ? 1 : reclaimDn ? -1 : 0

// resolve open reclaim setups
if barstate.isconfirmed and array.size(setups) > 0
    keep = array.new<Setup>()
    for i = 0 to array.size(setups) - 1
        s = array.get(setups, i)
        s.age += 1
        favExc = s.side > 0 ? (close - s.entry) : (s.entry - close)
        recrossed = (s.side > 0 and close < vwap) or (s.side < 0 and close > vwap)
        bool resolved = false
        float y = na
        if favExc >= tpK * s.atr0
            resolved := true
            y := 1.0
        else if recrossed
            resolved := true
            y := 0.0
        else if s.age >= horizonN
            resolved := true
            y := 0.0
        if resolved
            xf = array.from(s.f1, s.f2, s.f3, s.f4, s.f5, s.f6)
            f_train(w, xf, y, lr)
        else
            array.push(keep, s)
    setups := keep

// create setup on a reclaim
if barstate.isconfirmed and sideRe != 0
    ff = f_feat(sideRe)
    s2 = Setup.new(array.get(ff, 0), array.get(ff, 1), array.get(ff, 2), array.get(ff, 3), array.get(ff, 4), array.get(ff, 5), sideRe, close, atr, 0)
    array.push(setups, s2)
    if array.size(setups) > 60
        array.shift(setups)

// live follow-through probability for the current reclaim side
warmOK = bar_index > warmup
pFollow = sideRe != 0 ? f_predict(w, f_feat(sideRe)) : na
reclaimLong = showSig and warmOK and reclaimUp and not na(pFollow) and pFollow >= pThr
reclaimShort = showSig and warmOK and reclaimDn and not na(pFollow) and pFollow >= pThr

// ----------------------------------------------------------------------------
//  PLOTS
// ----------------------------------------------------------------------------
vwCol = close >= vwap ? cBull : cBear
pV = plot(vwap, "Anchored VWAP", color = color.new(cGold, 0), linewidth = 2)
pU = plot(showBands ? upper : na, "Upper band", color = color.new(cViolet, 40), linewidth = 1)
pL = plot(showBands ? lower : na, "Lower band", color = color.new(cViolet, 40), linewidth = 1)
fill(pU, pL, color = color.new(cViolet, 94))

plotshape(reAnchor ? vwap : na, "Anchor", shape.diamond, location.absolute, color.new(cGold, 0), size = size.tiny)
plotshape(reclaimLong ? low : na, "Reclaim long", shape.triangleup, location.belowbar, color.new(cBull, 0), size = size.small)
plotshape(reclaimShort ? high : na, "Reclaim short", shape.triangledown, location.abovebar, color.new(cBear, 0), size = size.small)

// ----------------------------------------------------------------------------
//  HUD
// ----------------------------------------------------------------------------
sigTxt = reclaimLong ? "RECLAIM LONG" : reclaimShort ? "RECLAIM SHORT" : "—"
sigCol = reclaimLong ? cBull : reclaimShort ? cBear : cWait
distSig = (src - vwap) / vwSig
regTxt = regime == 0 ? "LOW" : regime == 1 ? "NORMAL" : "HIGH"

var table hud = table.new(position.top_right, 2, 10, bgcolor = cBg1, frame_color = cGold, frame_width = 2, border_color = color.new(cGold, 60), border_width = 1)
if showHUD and barstate.islast
    ts = f_txtSize()
    table.cell(hud, 0, 0, "AE-VWAP", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 0, sigTxt, text_color = sigCol, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 0, 1, "VWAP", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 1, str.tostring(vwap, format.mintick), text_color = cGold, text_size = ts)
    table.cell(hud, 0, 2, "Price vs VWAP", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 2, (distSig >= 0 ? "+" : "") + str.tostring(distSig, "#.##") + "σ", text_color = distSig >= 0 ? cBull : cBear, text_size = ts)
    table.cell(hud, 0, 3, "Band k", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 3, str.tostring(kUsed, "#.##") + (adaptiveBand ? " (cal)" : ""), text_color = cViolet, text_size = ts)
    table.cell(hud, 0, 4, "Containment", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 4, na(containment) ? "-" : str.tostring(math.round(containment)) + "% / " + str.tostring(math.round((1 - bandAlpha) * 100)) + "%", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 5, "Reclaim P", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 5, na(pFollow) ? "-" : str.tostring(math.round(pFollow * 100)) + "%", text_color = na(pFollow) ? cWait : pFollow >= pThr ? cBull : cWait, text_size = ts)
    table.cell(hud, 0, 6, "Regime", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 6, regTxt, text_color = regime == 2 ? cBear : regime == 0 ? cBull : cViolet, text_size = ts)
    table.cell(hud, 0, 7, "Anchor age", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 7, str.tostring(bar_index - anchorBar) + " bars", text_color = cWait, text_size = ts)
    table.cell(hud, 0, 8, "Anchor mode", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 8, anchorMode == "Auto (pivots)" ? "Auto" : anchorMode == "Session (daily)" ? "Session" : "Manual", text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 9, "Model", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 9, warmOK ? "live" : "learning", text_color = warmOK ? cBull : cWait, bgcolor = cBg0, text_size = ts)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
alertcondition(reclaimLong, "AE-VWAP Reclaim long", "AE-VWAP: high-probability VWAP reclaim (long)")
alertcondition(reclaimShort, "AE-VWAP Reclaim short", "AE-VWAP: high-probability VWAP loss (short)")
alertcondition(reAnchor, "AE-VWAP Re-anchor", "AE-VWAP: VWAP re-anchored")
````
