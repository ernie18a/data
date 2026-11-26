# SMC + Wyckoff Probability Engine v1.1

- url: https://www.tradingview.com/script/CCeny2c1-SMC-Wyckoff-Probability-Engine-v1-1/
- type: indicator
- pine_id: PUB;17d9ab06d7cb447e97da130e4635700e
- version: 1.0

## Description

Trade when set up score is A/A+

Set timeframe to D, HTF to Week

## Source Code

````pine
//@version=6
// =============================================================================
//  SMC + WYCKOFF PROBABILITY ENGINE  v1.1
//  Built for Desmond — Crypto-tuned, evidence-weighted, non-repainting on close
// -----------------------------------------------------------------------------
//  v1.1 CHANGES vs v1.0:
//   [BUG FIX] A1  FVG fill-rate now tracks ALL detected FVGs (up to cap),
//                 not just the ones still on display. Removes pruning bias.
//   [BUG FIX] A2  Liquidity sweeps now tracked as arrays — no overwrite when
//                 multiple sweeps occur inside the evaluation window.
//                 Each sweep stores its own ATR-based threshold at sweep time.
//   [NEW]     A3  FVG fill-rate stats and sweep reversal stats now FEED INTO
//                 the probability dashboard (scaled by observed historical edge).
//   [NEW]     B1  HTF (Higher Timeframe) bias gate via request.security.
//                 EMA + slope on HTF → bullish / bearish / neutral.
//                 Non-repainting via close[1] + lookahead_on pattern.
//   [NEW]     B2  Premium / Discount zones (50% line between last swing hi/lo).
//                 Plot midline + tag current bar as Premium or Discount.
//   [NEW]     ★   SETUP SCORE  (A+ / B / C / Skip) — single confluence read.
//                 Combines HTF alignment, P/D zone, phase, sweep state,
//                 probability strength, and statistical edge into one grade.
//
//  PROBABILITY, NOT GUARANTEE — outputs are evidence-weighted estimates.
// =============================================================================

indicator("SMC + Wyckoff Probability Engine v1.1", "SMC+W v1.1", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// =================== INPUTS ==================================================

// ---- 1 · Structure ----
grpS         = "1 · Market Structure"
swingLen     = input.int(10, "Swing Length", minval = 2, group = grpS,
     tooltip = "Bars on each side required to confirm a swing pivot.")
bosDispATR   = input.float(0.0, "BOS Min Displacement (× ATR)", minval = 0.0, step = 0.1, group = grpS,
     tooltip = "0 = any close beyond pivot. >0 = require an impulsive break.")
showBOS      = input.bool(true,  "Show BOS",   group = grpS)
showCHoCH    = input.bool(true,  "Show CHoCH", group = grpS)

// ---- 2 · HTF Bias Gate ----
grpHTF       = "2 · HTF Bias Gate"
useHTF       = input.bool(true,  "Use HTF Bias Gate", group = grpHTF)
htfTF        = input.timeframe("240", "HTF Timeframe", group = grpHTF,
     tooltip = "Pick one step higher than your trading TF. E.g., 1H chart → 4H HTF.")
htfEmaLen    = input.int(50, "HTF EMA Length", minval = 5, group = grpHTF)

// ---- 3 · Order Blocks ----
grpOB        = "3 · Order Blocks"
showOB       = input.bool(true,  "Show Order Blocks", group = grpOB)
obLookback   = input.int(20, "OB Lookback (bars)", group = grpOB)
maxOBs       = input.int(5,  "Max OBs displayed (each side)", group = grpOB)

// ---- 4 · Fair Value Gaps ----
grpFVG       = "4 · Fair Value Gaps"
showFVG      = input.bool(true,  "Show FVGs", group = grpFVG)
fvgMinSize   = input.float(0.25, "Min FVG Size (× ATR)", step = 0.05, group = grpFVG)
maxFVGsDisp  = input.int(8,   "Max FVGs displayed (each side)", group = grpFVG)
fvgTrackCap  = input.int(500, "Internal FVG history cap (stats)", minval = 50, group = grpFVG,
     tooltip = "How many FVGs to remember for fill-rate stats. Larger = more accurate, slower.")

// ---- 5 · Liquidity Sweeps ----
grpLiq       = "5 · Liquidity Sweeps"
showSweeps   = input.bool(true,  "Show Sweep Markers", group = grpLiq)
sweepLB      = input.int(30, "Sweep Lookback (bars)", group = grpLiq)
sweepEvalBars= input.int(10, "Sweep Evaluation Window (bars)", group = grpLiq)
sweepRevATR  = input.float(1.0, "Sweep Reversal Magnitude (× ATR)", step = 0.1, group = grpLiq,
     tooltip = "Price must move this many ATR opposite the sweep to be 'reversed'.")

// ---- 6 · Wyckoff Regime ----
grpW         = "6 · Wyckoff Regime"
showRegime   = input.bool(true,  "Show Regime Label", group = grpW)
adxLen       = input.int(14, "ADX Length", group = grpW)
bbLen        = input.int(20, "BB Length",  group = grpW)
rangeLen     = input.int(100, "Range Position Lookback", group = grpW)

// ---- 7 · Premium / Discount ----
grpPD        = "7 · Premium / Discount Zones"
showPD       = input.bool(true,  "Show P/D Midline", group = grpPD)
pdSrc        = input.string("swing", "P/D Anchor",
     options = ["swing", "range"], group = grpPD,
     tooltip = "swing: last confirmed swing hi/lo. range: lookback hi/lo.")
pdRangeLen   = input.int(50, "Range lookback (if 'range')", group = grpPD)

// ---- 8 · Dashboard ----
grpD         = "8 · Dashboard"
showDash     = input.bool(true,  "Show Dashboard", group = grpD)
dashPos      = input.string("top_right", "Position",
     options = ["top_right", "top_left", "bottom_right", "bottom_left", "middle_right"],
     group = grpD)
dashSize     = input.string("normal", "Text Size",
     options = ["tiny", "small", "normal", "large"], group = grpD)

// =================== HELPERS =================================================

atrVal = ta.atr(14)

f_pos(s) =>
    s == "top_left"     ? position.top_left     :
     s == "bottom_right" ? position.bottom_right :
     s == "bottom_left"  ? position.bottom_left  :
     s == "middle_right" ? position.middle_right :
     position.top_right

f_size(s) =>
    s == "tiny"  ? size.tiny  :
     s == "small" ? size.small :
     s == "large" ? size.large :
     size.normal

// =================== HTF BIAS (B1) ===========================================
// Non-repainting HTF EMA + slope. Uses [1] offset + lookahead_on to lock in
// only confirmed prior-bar values from the higher timeframe.

[htfClose, htfEma, htfEmaPrev] = request.security(
     syminfo.tickerid, htfTF,
     [close[1], ta.ema(close, htfEmaLen)[1], ta.ema(close, htfEmaLen)[2]],
     lookahead = barmerge.lookahead_on)

int htfBias = 0
if not (na(htfEma) or na(htfEmaPrev))
    if htfClose > htfEma and htfEma > htfEmaPrev
        htfBias := 1
    else if htfClose < htfEma and htfEma < htfEmaPrev
        htfBias := -1

// =================== 1 · MARKET STRUCTURE ====================================

ph = ta.pivothigh(swingLen, swingLen)
pl = ta.pivotlow (swingLen, swingLen)

var float lastPH    = na
var float lastPL    = na
var int   lastPHbar = na
var int   lastPLbar = na
var int   bias      = 0
var int   prevBias  = 0

if not na(ph)
    lastPH    := ph
    lastPHbar := bar_index - swingLen
if not na(pl)
    lastPL    := pl
    lastPLbar := bar_index - swingLen

// Optional displacement filter for BOS (impulsive break vs grind)
dispOK_up = bosDispATR == 0 ? true : not na(atrVal) and (close - lastPH) >= atrVal * bosDispATR
dispOK_dn = bosDispATR == 0 ? true : not na(atrVal) and (lastPL - close) >= atrVal * bosDispATR

bosUp   = not na(lastPH) and close > lastPH and close[1] <= lastPH and dispOK_up
bosDn   = not na(lastPL) and close < lastPL and close[1] >= lastPL and dispOK_dn
chochUp = bosUp and prevBias == -1
chochDn = bosDn and prevBias ==  1

if bosUp
    bias := 1
if bosDn
    bias := -1
if bosUp or bosDn
    prevBias := bias

if showBOS and bosUp and not chochUp
    line.new(lastPHbar, lastPH, bar_index, lastPH,
         color = color.new(color.green, 0), style = line.style_dashed, width = 1)
    label.new(bar_index, lastPH, "BOS",
         style = label.style_label_down, color = color.new(color.green, 75),
         textcolor = color.green, size = size.small)
if showBOS and bosDn and not chochDn
    line.new(lastPLbar, lastPL, bar_index, lastPL,
         color = color.new(color.red, 0), style = line.style_dashed, width = 1)
    label.new(bar_index, lastPL, "BOS",
         style = label.style_label_up, color = color.new(color.red, 75),
         textcolor = color.red, size = size.small)
if showCHoCH and chochUp
    line.new(lastPHbar, lastPH, bar_index, lastPH,
         color = color.aqua, style = line.style_solid, width = 2)
    label.new(bar_index, lastPH, "CHoCH",
         style = label.style_label_down, color = color.new(color.aqua, 50),
         textcolor = color.white, size = size.small)
if showCHoCH and chochDn
    line.new(lastPLbar, lastPL, bar_index, lastPL,
         color = color.orange, style = line.style_solid, width = 2)
    label.new(bar_index, lastPL, "CHoCH",
         style = label.style_label_up, color = color.new(color.orange, 50),
         textcolor = color.white, size = size.small)

// =================== 2 · ORDER BLOCKS ========================================

var array<box>  bullOBs   = array.new<box>()
var array<box>  bearOBs   = array.new<box>()
var array<bool> bullOBmit = array.new<bool>()
var array<bool> bearOBmit = array.new<bool>()

if showOB and bosUp
    bool found = false
    for i = 1 to math.min(obLookback, bar_index - 1)
        if not found and close[i] < open[i]
            b = box.new(bar_index - i, high[i], bar_index + 20, low[i],
                 bgcolor = color.new(color.green, 80),
                 border_color = color.new(color.green, 40),
                 extend = extend.right)
            array.push(bullOBs, b)
            array.push(bullOBmit, false)
            found := true

if showOB and bosDn
    bool found = false
    for i = 1 to math.min(obLookback, bar_index - 1)
        if not found and close[i] > open[i]
            b = box.new(bar_index - i, high[i], bar_index + 20, low[i],
                 bgcolor = color.new(color.red, 80),
                 border_color = color.new(color.red, 40),
                 extend = extend.right)
            array.push(bearOBs, b)
            array.push(bearOBmit, false)
            found := true

while array.size(bullOBs) > maxOBs
    box.delete(array.shift(bullOBs))
    array.shift(bullOBmit)
while array.size(bearOBs) > maxOBs
    box.delete(array.shift(bearOBs))
    array.shift(bearOBmit)

if array.size(bullOBs) > 0
    for i = 0 to array.size(bullOBs) - 1
        b = array.get(bullOBs, i)
        if not array.get(bullOBmit, i) and low <= box.get_top(b)
            array.set(bullOBmit, i, true)
            box.set_bgcolor(b, color.new(color.gray, 88))
            box.set_border_color(b, color.new(color.gray, 60))
if array.size(bearOBs) > 0
    for i = 0 to array.size(bearOBs) - 1
        b = array.get(bearOBs, i)
        if not array.get(bearOBmit, i) and high >= box.get_bottom(b)
            array.set(bearOBmit, i, true)
            box.set_bgcolor(b, color.new(color.gray, 88))
            box.set_border_color(b, color.new(color.gray, 60))

// =================== 3 · FAIR VALUE GAPS  (A1 fixed) =========================
// Tracking is now decoupled from display. ALL FVGs (up to fvgTrackCap) are
// remembered for fill-rate stats, regardless of how many boxes we draw.

bullFVG = not na(atrVal) and low  > high[2] and (low - high[2]) > atrVal * fvgMinSize
bearFVG = not na(atrVal) and high < low[2]  and (low[2] - high) > atrVal * fvgMinSize

// --- Bull FVG tracking ---
var array<float> bullFVG_edge    = array.new<float>()  // upper edge of gap (fill target)
var array<bool>  bullFVG_filled  = array.new<bool>()
var array<box>   bullFVG_box     = array.new<box>()    // na if not displayed
var int bullFVG_visible          = 0
var int bullFVG_filledCount      = 0

if bullFVG
    array.push(bullFVG_edge, high[2])
    array.push(bullFVG_filled, false)
    box drawnBox = na
    if showFVG
        drawnBox := box.new(bar_index - 2, low, bar_index + 15, high[2],
             bgcolor = color.new(color.lime, 85),
             border_color = color.new(color.lime, 50),
             extend = extend.right)
        bullFVG_visible += 1
    array.push(bullFVG_box, drawnBox)

if array.size(bullFVG_edge) > 0
    for i = 0 to array.size(bullFVG_edge) - 1
        if not array.get(bullFVG_filled, i) and low <= array.get(bullFVG_edge, i)
            array.set(bullFVG_filled, i, true)
            bullFVG_filledCount += 1
            b = array.get(bullFVG_box, i)
            if not na(b)
                box.set_bgcolor(b, color.new(color.gray, 90))
                box.set_border_color(b, color.new(color.gray, 70))

// Prune visible (keep only most recent maxFVGsDisp displayed)
while bullFVG_visible > maxFVGsDisp
    bool removed = false
    for j = 0 to array.size(bullFVG_box) - 1
        if not removed
            b = array.get(bullFVG_box, j)
            if not na(b)
                box.delete(b)
                array.set(bullFVG_box, j, na)
                bullFVG_visible -= 1
                removed := true
    if not removed
        bullFVG_visible := 0

// Cap tracking history
while array.size(bullFVG_edge) > fvgTrackCap
    array.shift(bullFVG_edge)
    wasFilled = array.shift(bullFVG_filled)
    if wasFilled
        bullFVG_filledCount -= 1
    oldBox = array.shift(bullFVG_box)
    if not na(oldBox)
        box.delete(oldBox)
        bullFVG_visible -= 1

bullFVG_total = array.size(bullFVG_edge)
bullFVGrate   = bullFVG_total > 0 ? bullFVG_filledCount / bullFVG_total * 100.0 : 0.0

// --- Bear FVG tracking ---
var array<float> bearFVG_edge    = array.new<float>()  // lower edge of gap (fill target)
var array<bool>  bearFVG_filled  = array.new<bool>()
var array<box>   bearFVG_box     = array.new<box>()
var int bearFVG_visible          = 0
var int bearFVG_filledCount      = 0

if bearFVG
    array.push(bearFVG_edge, low[2])
    array.push(bearFVG_filled, false)
    box drawnBox = na
    if showFVG
        drawnBox := box.new(bar_index - 2, low[2], bar_index + 15, high,
             bgcolor = color.new(color.fuchsia, 85),
             border_color = color.new(color.fuchsia, 50),
             extend = extend.right)
        bearFVG_visible += 1
    array.push(bearFVG_box, drawnBox)

if array.size(bearFVG_edge) > 0
    for i = 0 to array.size(bearFVG_edge) - 1
        if not array.get(bearFVG_filled, i) and high >= array.get(bearFVG_edge, i)
            array.set(bearFVG_filled, i, true)
            bearFVG_filledCount += 1
            b = array.get(bearFVG_box, i)
            if not na(b)
                box.set_bgcolor(b, color.new(color.gray, 90))
                box.set_border_color(b, color.new(color.gray, 70))

while bearFVG_visible > maxFVGsDisp
    bool removed = false
    for j = 0 to array.size(bearFVG_box) - 1
        if not removed
            b = array.get(bearFVG_box, j)
            if not na(b)
                box.delete(b)
                array.set(bearFVG_box, j, na)
                bearFVG_visible -= 1
                removed := true
    if not removed
        bearFVG_visible := 0

while array.size(bearFVG_edge) > fvgTrackCap
    array.shift(bearFVG_edge)
    wasFilled = array.shift(bearFVG_filled)
    if wasFilled
        bearFVG_filledCount -= 1
    oldBox = array.shift(bearFVG_box)
    if not na(oldBox)
        box.delete(oldBox)
        bearFVG_visible -= 1

bearFVG_total = array.size(bearFVG_edge)
bearFVGrate   = bearFVG_total > 0 ? bearFVG_filledCount / bearFVG_total * 100.0 : 0.0

// =================== 4 · LIQUIDITY SWEEPS  (A2 fixed) ========================
// Each sweep is tracked independently with its own ATR-based reversal threshold
// recorded at the time of sweep. No more overwriting when sweeps cluster.

prevHi = ta.highest(high, sweepLB)[1]
prevLo = ta.lowest (low,  sweepLB)[1]

sweepHi = high > prevHi and close < prevHi
sweepLo = low  < prevLo and close > prevLo

// --- Sweep High tracking ---
var array<int>   sweepHi_bar       = array.new<int>()
var array<float> sweepHi_threshold = array.new<float>()  // price level that confirms reversal
var int totSweepHi = 0
var int revSweepHi = 0
var int lastSweepHiBar = na   // for "recent sweep" probability adjustment

if sweepHi
    totSweepHi += 1
    array.push(sweepHi_bar, bar_index)
    array.push(sweepHi_threshold, high - atrVal * sweepRevATR)
    lastSweepHiBar := bar_index
    if showSweeps
        label.new(bar_index, high, "Sweep↑",
             style = label.style_label_down, color = color.new(color.red, 30),
             textcolor = color.white, size = size.small)

// Evaluate pending high-sweeps (iterate backwards so we can safely remove)
if array.size(sweepHi_bar) > 0
    int i = array.size(sweepHi_bar) - 1
    while i >= 0
        barAge = bar_index - array.get(sweepHi_bar, i)
        threshold = array.get(sweepHi_threshold, i)
        if low <= threshold
            revSweepHi += 1
            array.remove(sweepHi_bar, i)
            array.remove(sweepHi_threshold, i)
        else if barAge >= sweepEvalBars
            array.remove(sweepHi_bar, i)
            array.remove(sweepHi_threshold, i)
        i -= 1

// --- Sweep Low tracking ---
var array<int>   sweepLo_bar       = array.new<int>()
var array<float> sweepLo_threshold = array.new<float>()
var int totSweepLo = 0
var int revSweepLo = 0
var int lastSweepLoBar = na

if sweepLo
    totSweepLo += 1
    array.push(sweepLo_bar, bar_index)
    array.push(sweepLo_threshold, low + atrVal * sweepRevATR)
    lastSweepLoBar := bar_index
    if showSweeps
        label.new(bar_index, low, "Sweep↓",
             style = label.style_label_up, color = color.new(color.green, 30),
             textcolor = color.white, size = size.small)

if array.size(sweepLo_bar) > 0
    int i = array.size(sweepLo_bar) - 1
    while i >= 0
        barAge = bar_index - array.get(sweepLo_bar, i)
        threshold = array.get(sweepLo_threshold, i)
        if high >= threshold
            revSweepLo += 1
            array.remove(sweepLo_bar, i)
            array.remove(sweepLo_threshold, i)
        else if barAge >= sweepEvalBars
            array.remove(sweepLo_bar, i)
            array.remove(sweepLo_threshold, i)
        i -= 1

sweepHiRevRate = totSweepHi > 0 ? revSweepHi / totSweepHi * 100.0 : 50.0
sweepLoRevRate = totSweepLo > 0 ? revSweepLo / totSweepLo * 100.0 : 50.0

// =================== 5 · WYCKOFF REGIME ======================================

[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxLen)
basis    = ta.sma(close, bbLen)
dev      = ta.stdev(close, bbLen)
bbWidth  = (dev * 2) / basis * 100.0
bbWidthA = ta.sma(bbWidth, 50)

rgHi  = ta.highest(high, rangeLen)
rgLo  = ta.lowest (low,  rangeLen)
rgPos = (close - rgLo) / (rgHi - rgLo) * 100.0

isRange = adxVal < 20 and bbWidth < bbWidthA
isTrend = adxVal >= 25

string phase    = "Transition"
color  phaseClr = color.new(color.gray, 30)

if isRange and rgPos < 40
    phase    := "Accumulation"
    phaseClr := color.new(color.green, 30)
else if isRange and rgPos > 60
    phase    := "Distribution"
    phaseClr := color.new(color.red, 30)
else if isTrend and diPlus > diMinus
    phase    := "Markup"
    phaseClr := color.new(color.lime, 30)
else if isTrend and diMinus > diPlus
    phase    := "Markdown"
    phaseClr := color.new(color.fuchsia, 30)

// =================== 6 · PREMIUM / DISCOUNT  (B2) ============================

var float swingHiAnchor = na
var float swingLoAnchor = na

if not na(ph)
    swingHiAnchor := ph
if not na(pl)
    swingLoAnchor := pl

float pdMid = na
if pdSrc == "swing"
    if not na(swingHiAnchor) and not na(swingLoAnchor)
        pdMid := (swingHiAnchor + swingLoAnchor) / 2
else
    pdMid := (ta.highest(high, pdRangeLen) + ta.lowest(low, pdRangeLen)) / 2

string pdZone = na(pdMid) ? "—" : close > pdMid ? "Premium" : "Discount"

plot(showPD ? pdMid : na, "P/D Midline (50%)",
     color = color.new(color.yellow, 30), style = plot.style_circles, linewidth = 1)

// =================== 7 · PROBABILITY DASHBOARD  (A3) =========================
// Composite read — now incorporates HTF bias, P/D zone, and SCALES sweep
// contributions by observed historical reversal rates, and applies an FVG
// magnetic-pull factor when unfilled gaps lie in the path of price.

float pUp   = 33.0
float pDn   = 33.0
float pChop = 34.0

// --- Structure bias ---
if bias ==  1
    pUp   += 12
    pDn   -= 8
    pChop -= 4
if bias == -1
    pDn   += 12
    pUp   -= 8
    pChop -= 4

// --- HTF bias gate ---
if useHTF and htfBias ==  1
    pUp   += 10
    pDn   -= 5
    pChop -= 5
if useHTF and htfBias == -1
    pDn   += 10
    pUp   -= 5
    pChop -= 5

// --- Wyckoff phase ---
if phase == "Markup"
    pUp   += 12
    pDn   -= 8
    pChop -= 4
else if phase == "Markdown"
    pDn   += 12
    pUp   -= 8
    pChop -= 4
else if phase == "Accumulation"
    pUp   += 6
    pChop -= 6
else if phase == "Distribution"
    pDn   += 6
    pChop -= 6
else if phase == "Transition"
    pChop += 8
    pUp   -= 4
    pDn   -= 4

// --- Premium / Discount ---
if pdZone == "Discount"
    pUp   += 6
    pDn   -= 3
    pChop -= 3
else if pdZone == "Premium"
    pDn   += 6
    pUp   -= 3
    pChop -= 3

// --- Recent sweep (scaled by historical reversal rate of this symbol/TF) ---
sweepHiRecent = not na(lastSweepHiBar) and bar_index - lastSweepHiBar < 5
sweepLoRecent = not na(lastSweepLoBar) and bar_index - lastSweepLoBar < 5

if sweepHiRecent
    scl = sweepHiRevRate / 100.0
    pDn   += 10 * scl
    pUp   -= 5  * scl
    pChop -= 5  * scl
if sweepLoRecent
    scl = sweepLoRevRate / 100.0
    pUp   += 10 * scl
    pDn   -= 5  * scl
    pChop -= 5  * scl

// --- FVG magnetic pull (only if symbol historically respects FVGs > 60%) ---
bool unfilledBullBelow = false
bool unfilledBearAbove = false
if array.size(bullFVG_edge) > 0
    for i = 0 to array.size(bullFVG_edge) - 1
        if not array.get(bullFVG_filled, i) and array.get(bullFVG_edge, i) < close and not unfilledBullBelow
            unfilledBullBelow := true
if array.size(bearFVG_edge) > 0
    for i = 0 to array.size(bearFVG_edge) - 1
        if not array.get(bearFVG_filled, i) and array.get(bearFVG_edge, i) > close and not unfilledBearAbove
            unfilledBearAbove := true

if unfilledBullBelow and bullFVGrate > 60
    factor = math.min((bullFVGrate - 60) / 40, 1.0)
    pDn   += 5 * factor
    pUp   -= 2 * factor
    pChop -= 3 * factor
if unfilledBearAbove and bearFVGrate > 60
    factor = math.min((bearFVGrate - 60) / 40, 1.0)
    pUp   += 5 * factor
    pDn   -= 2 * factor
    pChop -= 3 * factor

// Clamp & normalize
pUp   := math.max(0.0, math.min(100.0, pUp))
pDn   := math.max(0.0, math.min(100.0, pDn))
pChop := math.max(0.0, math.min(100.0, pChop))
total  = pUp + pDn + pChop
pUp   := pUp   / total * 100.0
pDn   := pDn   / total * 100.0
pChop := pChop / total * 100.0

// =================== 8 · SETUP SCORE (★) =====================================
// One unified read combining all confluence into A+ / B / C / Skip.

string setupDir = pUp > pDn + 5 ? "Long" : pDn > pUp + 5 ? "Short" : "—"
int setupScore  = 0

if setupDir == "Long"
    if useHTF and htfBias == 1
        setupScore += 2
    if bias == 1
        setupScore += 1
    if phase == "Markup" or phase == "Accumulation"
        setupScore += 2
    if pdZone == "Discount"
        setupScore += 2
    if sweepLoRecent
        setupScore += 1
    if pUp >= 55
        setupScore += 1
    if sweepLoRevRate > 50 or bearFVGrate > 70
        setupScore += 1
else if setupDir == "Short"
    if useHTF and htfBias == -1
        setupScore += 2
    if bias == -1
        setupScore += 1
    if phase == "Markdown" or phase == "Distribution"
        setupScore += 2
    if pdZone == "Premium"
        setupScore += 2
    if sweepHiRecent
        setupScore += 1
    if pDn >= 55
        setupScore += 1
    if sweepHiRevRate > 50 or bullFVGrate > 70
        setupScore += 1

string setupGrade   = "Skip"
color  setupGradeBg = color.new(color.red, 30)

if setupScore >= 8
    setupGrade   := "A+"
    setupGradeBg := color.new(color.lime, 10)
else if setupScore >= 6
    setupGrade   := "B"
    setupGradeBg := color.new(color.green, 30)
else if setupScore >= 4
    setupGrade   := "C"
    setupGradeBg := color.new(color.orange, 30)

// =================== 9 · DASHBOARD ===========================================

var table dash = table.new(f_pos(dashPos), 2, 14,
     bgcolor = color.new(color.black, 75),
     border_width = 1, border_color = color.new(color.gray, 50))

if showDash and barstate.islast
    txt = f_size(dashSize)

    // Title row
    table.cell(dash, 0, 0, "SMC + WYCKOFF v1.1",
         bgcolor = color.new(color.navy, 20), text_color = color.white, text_size = txt)
    table.cell(dash, 1, 0, "READING",
         bgcolor = color.new(color.navy, 20), text_color = color.white, text_size = txt)

    // Setup Score (headline)
    table.cell(dash, 0, 1, "★ SETUP SCORE",
         bgcolor = color.new(color.purple, 20), text_color = color.white, text_size = txt)
    scoreText = setupGrade + "  (" + str.tostring(setupScore) + "/10)"
    table.cell(dash, 1, 1, scoreText,
         bgcolor = setupGradeBg, text_color = color.white, text_size = txt)

    // Setup direction
    dirClr = setupDir == "Long" ? color.green : setupDir == "Short" ? color.red : color.gray
    table.cell(dash, 0, 2, "Direction", text_color = color.silver, text_size = txt)
    table.cell(dash, 1, 2, setupDir, text_color = dirClr, text_size = txt)

    // Structure
    biasStr = bias ==  1 ? "Bullish ↑" : bias == -1 ? "Bearish ↓" : "Neutral —"
    biasClr = bias ==  1 ? color.green : bias == -1 ? color.red   : color.gray
    table.cell(dash, 0, 3, "Structure (TF)", text_color = color.silver, text_size = txt)
    table.cell(dash, 1, 3, biasStr, text_color = biasClr, text_size = txt)

    // HTF
    string htfStr = "Neutral — (" + htfTF + ")"
    color  htfClr = color.gray
    if not useHTF
        htfStr := "off"
        htfClr := color.gray
    else if htfBias == 1
        htfStr := "Bullish ↑ (" + htfTF + ")"
        htfClr := color.green
    else if htfBias == -1
        htfStr := "Bearish ↓ (" + htfTF + ")"
        htfClr := color.red
    table.cell(dash, 0, 4, "Structure (HTF)", text_color = color.silver, text_size = txt)
    table.cell(dash, 1, 4, htfStr, text_color = htfClr, text_size = txt)

    // Phase
    table.cell(dash, 0, 5, "Wyckoff Phase", text_color = color.silver, text_size = txt)
    table.cell(dash, 1, 5, phase, bgcolor = phaseClr, text_color = color.white, text_size = txt)

    // P/D zone
    pdClr = pdZone == "Discount" ? color.aqua : pdZone == "Premium" ? color.orange : color.gray
    table.cell(dash, 0, 6, "P/D Zone", text_color = color.silver, text_size = txt)
    table.cell(dash, 1, 6, pdZone, text_color = pdClr, text_size = txt)

    // Probabilities
    table.cell(dash, 0, 7, "↑ Probability", text_color = color.green, text_size = txt)
    table.cell(dash, 1, 7, str.tostring(pUp,   "#.0") + "%", text_color = color.green, text_size = txt)
    table.cell(dash, 0, 8, "↓ Probability", text_color = color.red, text_size = txt)
    table.cell(dash, 1, 8, str.tostring(pDn,   "#.0") + "%", text_color = color.red, text_size = txt)
    table.cell(dash, 0, 9, "Chop / Range",  text_color = color.gray, text_size = txt)
    table.cell(dash, 1, 9, str.tostring(pChop, "#.0") + "%", text_color = color.gray, text_size = txt)

    // FVG stats
    table.cell(dash, 0, 10, "Bull FVG fill %", text_color = color.lime, text_size = txt)
    table.cell(dash, 1, 10,
         str.tostring(bullFVGrate, "#.0") + "% (" + str.tostring(bullFVG_filledCount) + "/" + str.tostring(bullFVG_total) + ")",
         text_color = color.lime, text_size = txt)
    table.cell(dash, 0, 11, "Bear FVG fill %", text_color = color.fuchsia, text_size = txt)
    table.cell(dash, 1, 11,
         str.tostring(bearFVGrate, "#.0") + "% (" + str.tostring(bearFVG_filledCount) + "/" + str.tostring(bearFVG_total) + ")",
         text_color = color.fuchsia, text_size = txt)

    // Sweep stats
    table.cell(dash, 0, 12, "Sweep Hi rev %", text_color = color.yellow, text_size = txt)
    table.cell(dash, 1, 12,
         str.tostring(sweepHiRevRate, "#.0") + "% (" + str.tostring(revSweepHi) + "/" + str.tostring(totSweepHi) + ")",
         text_color = color.yellow, text_size = txt)
    table.cell(dash, 0, 13, "Sweep Lo rev %", text_color = color.yellow, text_size = txt)
    table.cell(dash, 1, 13,
         str.tostring(sweepLoRevRate, "#.0") + "% (" + str.tostring(revSweepLo) + "/" + str.tostring(totSweepLo) + ")",
         text_color = color.yellow, text_size = txt)

// =================== ALERTS ==================================================

alertcondition(bosUp,             "BOS Up",            "Bullish BOS on {{ticker}} {{interval}}")
alertcondition(bosDn,             "BOS Down",          "Bearish BOS on {{ticker}} {{interval}}")
alertcondition(chochUp,           "CHoCH Up",          "Bullish CHoCH on {{ticker}} {{interval}}")
alertcondition(chochDn,           "CHoCH Down",        "Bearish CHoCH on {{ticker}} {{interval}}")
alertcondition(sweepHi,           "Liquidity Sweep ↑", "Highs swept on {{ticker}} {{interval}}")
alertcondition(sweepLo,           "Liquidity Sweep ↓", "Lows swept on {{ticker}} {{interval}}")
alertcondition(bullFVG,           "Bullish FVG",       "Bullish FVG formed on {{ticker}} {{interval}}")
alertcondition(bearFVG,           "Bearish FVG",       "Bearish FVG formed on {{ticker}} {{interval}}")

// Setup-grade alerts (fire on bar close when grade is reached)
aplusLong  = setupGrade == "A+" and setupDir == "Long"
aplusShort = setupGrade == "A+" and setupDir == "Short"
bLong      = setupGrade == "B"  and setupDir == "Long"
bShort     = setupGrade == "B"  and setupDir == "Short"

alertcondition(aplusLong,  "Setup A+ Long",  "A+ Long setup on {{ticker}} {{interval}}")
alertcondition(aplusShort, "Setup A+ Short", "A+ Short setup on {{ticker}} {{interval}}")
alertcondition(bLong,      "Setup B Long",   "B-grade Long setup on {{ticker}} {{interval}}")
alertcondition(bShort,     "Setup B Short",  "B-grade Short setup on {{ticker}} {{interval}}")
````
