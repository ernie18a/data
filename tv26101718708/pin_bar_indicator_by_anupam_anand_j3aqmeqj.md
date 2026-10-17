# Pin Bar Indicator By Anupam Anand

- url: https://www.tradingview.com/script/J3AQMEQj-Pin-Bar-Indicator-By-Anupam-Anand/
- type: indicator
- pine_id: PUB;4807c33ef6404960bc5162c106f4d2c3
- version: 1.0

## Description

Here's what the indicator does and how to use it:
Detection logic — a candle qualifies as a pin bar when: the primary wick ≥ 66% of the total range, the body ≤ 30%, and the opposite (nose) wick ≤ 25%. All three ratios are adjustable in Settings.
Location quality scoring — every pin bar gets scored from −2 to +3:
Good locations add +1 each: forming at a recent swing pivot, within a support/resistance zone, or after a pullback across the trend EMA. Bad locations subtract −1 each: inside a tight consolidation range, or forming against strong one-sided momentum candles. The score drives the star rating and label color (green for ★★★, orange for ★★☆/★☆☆, gray/hidden for weak).
What plots on the chart:

Triangle arrows below/above the candle body
Star-rated labels (★★★ / ★★☆ / ★☆☆ / ⚠)
Highlighted candle background in the signal colour
A thin EMA line for pullback context

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © anupam_anand1001
// ══════════════════════════════════════════════════════════════════════════════
//  PIN BAR INDICATOR · Pine Script v5 [Error-Free Version]
//  Detects Bullish & Bearish Pin Bars with Location Quality Scoring
//  Best Locations : Swing Points · Key S/R Levels · Pullback Retests
//  Worst Locations: Consolidation Zones · Against Momentum · Counter-Trend
// ══════════════════════════════════════════════════════════════════════════════

//@version=5
indicator("Pin Bar Indicator [Location Quality]", overlay=true, max_bars_back=500, max_labels_count=500)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

grpPB = "📌 Pin Bar Detection"

i_wickRatio = input.float(
     0.66,
     "Min Wick Ratio (of total range)",
     minval = 0.50,
     maxval = 0.90,
     step = 0.01,
     group = grpPB)

i_bodyRatio = input.float(
     0.30,
     "Max Body Ratio (of total range)",
     minval = 0.10,
     maxval = 0.50,
     step = 0.01,
     group = grpPB)

i_noseRatio = input.float(
     0.25,
     "Max Nose Ratio (opposite wick)",
     minval = 0.05,
     maxval = 0.40,
     step = 0.01,
     group = grpPB)

grpSW = "🔵 Swing-Point Filter (Best Location #1)"

i_useSwing = input.bool(true, "Enable Swing-Point Filter", group=grpSW)

i_swingLen = input.int(
     10,
     "Pivot Lookback Length",
     minval = 3,
     maxval = 50,
     group = grpSW)

i_swingProx = input.int(
     30,
     "Max Bars from Pivot",
     minval = 5,
     maxval = 100,
     group = grpSW)

grpSR = "🟢 Support / Resistance Filter (Best Location #3)"

i_useSR = input.bool(true, "Enable S/R Filter", group=grpSR)

i_srLen = input.int(
     50,
     "S/R Level Lookback",
     minval = 10,
     maxval = 200,
     group = grpSR)

i_srZonePct = input.float(
     0.30,
     "S/R Zone Width (%)",
     minval = 0.05,
     maxval = 2.0,
     step = 0.05,
     group = grpSR)

grpPB2 = "🟡 Pullback / Retest Filter (Best Location #2)"

i_usePullback = input.bool(true, "Enable Pullback-Retest Filter", group=grpPB2)

i_pbLen = input.int(
     14,
     "EMA for Trend Direction",
     minval = 5,
     maxval = 200,
     group = grpPB2)

grpCons = "🔴 Consolidation Filter (Worst Location #1)"

i_useCons = input.bool(true, "Avoid Consolidation Zones", group=grpCons)

i_consLen = input.int(
     20,
     "Consolidation Lookback",
     minval = 5,
     maxval = 100,
     group = grpCons)

i_consPct = input.float(
     1.50,
     "Max Range % (Consolidation Threshold)",
     minval = 0.30,
     maxval = 8.0,
     step = 0.10,
     group = grpCons)

grpMom = "🔴 Momentum Filter (Worst Location #3)"

i_useMom = input.bool(true, "Avoid Strong-Momentum Bars", group=grpMom)

i_momLen = input.int(
     5,
     "Momentum Lookback Bars",
     minval = 2,
     maxval = 20,
     group = grpMom)

i_momMult = input.float(
     2.0,
     "Momentum Size Multiplier",
     minval = 1.0,
     maxval = 5.0,
     step = 0.1,
     group = grpMom)

grpDisp = "🎨 Display"

i_showAll = input.bool(false, "Show All Pin Bars", group=grpDisp)
i_showQual = input.bool(true, "Show Quality Stars in Label", group=grpDisp)
i_hlBar = input.bool(true, "Highlight Pin Bar Candle", group=grpDisp)

i_bullCol = input.color(color.new(#00C896, 0), "Bullish Color", group=grpDisp)
i_bearCol = input.color(color.new(#FF4560, 0), "Bearish Color", group=grpDisp)
i_warnCol = input.color(color.new(#FFB800, 0), "Warning Color", group=grpDisp)

// ─────────────────────────────────────────────────────────────────────────────
// CANDLE GEOMETRY
// ─────────────────────────────────────────────────────────────────────────────

range_ = high - low
body_ = math.abs(close - open)

topBody = math.max(open, close)
botBody = math.min(open, close)

upWick = high - topBody
dnWick = botBody - low

isValidCandle = range_ > 0

// ── Bullish Pin Bar ──────────────────────────────────────────────────────────

bullWR = isValidCandle ? dnWick / range_ : 0.0
bullBR = isValidCandle ? body_ / range_ : 0.0
bullNR = isValidCandle ? upWick / range_ : 0.0

isBullPin =
     isValidCandle and
     bullWR >= i_wickRatio and
     bullBR <= i_bodyRatio and
     bullNR <= i_noseRatio

// ── Bearish Pin Bar ──────────────────────────────────────────────────────────

bearWR = isValidCandle ? upWick / range_ : 0.0
bearBR = isValidCandle ? body_ / range_ : 0.0
bearNR = isValidCandle ? dnWick / range_ : 0.0

isBearPin =
     isValidCandle and
     bearWR >= i_wickRatio and
     bearBR <= i_bodyRatio and
     bearNR <= i_noseRatio

// ─────────────────────────────────────────────────────────────────────────────
// LOCATION QUALITY EVALUATION
// ─────────────────────────────────────────────────────────────────────────────

// ── 1. Swing-Point Proximity ─────────────────────────────────────────────────

pH = ta.pivothigh(high, i_swingLen, i_swingLen)
pL = ta.pivotlow(low, i_swingLen, i_swingLen)

nearSwingHigh = false
nearSwingLow = false

if i_useSwing
    for idx = i_swingLen to (i_swingLen + i_swingProx)
        if not na(pH[idx])
            nearSwingHigh := true

        if not na(pL[idx])
            nearSwingLow := true

// ── 2. Support / Resistance ──────────────────────────────────────────────────

var float[] srArr = array.new_float()

if not na(pH)
    array.unshift(srArr, pH)

    if array.size(srArr) > 30
        array.pop(srArr)

if not na(pL)
    array.unshift(srArr, pL)

    if array.size(srArr) > 30
        array.pop(srArr)

nearSR = false

if i_useSR and array.size(srArr) > 0
    float zone = close * i_srZonePct / 100

    for k = 0 to array.size(srArr) - 1
        float lvl = array.get(srArr, k)

        if math.abs(close - lvl) <= zone
            nearSR := true
            break

srHigh = ta.highest(high, i_srLen)[1]
srLow = ta.lowest(low, i_srLen)[1]

float srZone = close * i_srZonePct / 100

nearSRHigh = math.abs(high - srHigh) <= srZone
nearSRLow = math.abs(low - srLow) <= srZone

nearSR := nearSR or nearSRHigh or nearSRLow

// ── 3. Pullback / Retest Context ─────────────────────────────────────────────

ema_ = ta.ema(close, i_pbLen)

bullPullback =
     i_usePullback and
     (low < ema_ or low[1] < ema_[1]) and
     close > open

bearPullback =
     i_usePullback and
     (high > ema_ or high[1] > ema_[1]) and
     close < open

// ── 4. Consolidation Detection ───────────────────────────────────────────────

consHigh = ta.highest(high, i_consLen)
consLow = ta.lowest(low, i_consLen)

consPct = consLow != 0 ? ((consHigh - consLow) / consLow) * 100 : 0.0

inConsolidation =
     i_useCons and
     consPct < i_consPct

// ── 5. Strong Momentum Detection ─────────────────────────────────────────────

avgRange20 = ta.sma(range_, 20)

strongMomUp = false
strongMomDown = false

if i_useMom
    allBullish = true
    allBearish = true

    float avgMomRange = 0.0

    for j = 1 to i_momLen
        avgMomRange += (high[j] - low[j])

        if close[j] <= open[j]
            allBullish := false

        if close[j] >= open[j]
            allBearish := false

    avgMomRange := avgMomRange / i_momLen

    isBigCandles = avgMomRange > avgRange20 * i_momMult

    strongMomUp := allBullish and isBigCandles
    strongMomDown := allBearish and isBigCandles

// ─────────────────────────────────────────────────────────────────────────────
// QUALITY SCORING
// ─────────────────────────────────────────────────────────────────────────────

int bullScore = 0

if isBullPin
    if i_useSwing and nearSwingLow
        bullScore += 1

    if i_useSR and nearSR
        bullScore += 1

    if i_usePullback and bullPullback
        bullScore += 1

    if inConsolidation
        bullScore -= 1

    if i_useMom and strongMomDown
        bullScore -= 1

int bearScore = 0

if isBearPin
    if i_useSwing and nearSwingHigh
        bearScore += 1

    if i_useSR and nearSR
        bearScore += 1

    if i_usePullback and bearPullback
        bearScore += 1

    if inConsolidation
        bearScore -= 1

    if i_useMom and strongMomUp
        bearScore -= 1

// ─────────────────────────────────────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────────────────────────────────────

bullCol =
     bullScore >= 2 ? i_bullCol :
     bullScore >= 0 ? i_warnCol :
     color.new(color.gray, 40)

bearCol =
     bearScore >= 2 ? i_bearCol :
     bearScore >= 0 ? i_warnCol :
     color.new(color.gray, 40)

// ─────────────────────────────────────────────────────────────────────────────
// FINAL SIGNALS
// ─────────────────────────────────────────────────────────────────────────────

bullSignal = isBullPin and (i_showAll or bullScore >= 0)
bearSignal = isBearPin and (i_showAll or bearScore >= 0)

// ─────────────────────────────────────────────────────────────────────────────
// STAR LABEL HELPER
// ─────────────────────────────────────────────────────────────────────────────

f_stars(score) =>
    score >= 2 ? "★★★" :
     score == 1 ? "★★☆" :
     score == 0 ? "★☆☆" :
     "⚠ Weak"

// ─────────────────────────────────────────────────────────────────────────────
// PLOTTING
// ─────────────────────────────────────────────────────────────────────────────

// ── Triangle Arrows ──────────────────────────────────────────────────────────

plotshape(
     bullSignal,
     title = "▲ Bullish Pin Bar",
     style = shape.triangleup,
     location = location.belowbar,
     color = bullCol,
     size = size.small)

plotshape(
     bearSignal,
     title = "▼ Bearish Pin Bar",
     style = shape.triangledown,
     location = location.abovebar,
     color = bearCol,
     size = size.small)

// ── Candle Highlight ─────────────────────────────────────────────────────────

barcolor(
     i_hlBar and bullSignal ? color.new(bullCol, 75) :
     i_hlBar and bearSignal ? color.new(bearCol, 75) :
     na)

// ── Quality Labels ───────────────────────────────────────────────────────────

if bullSignal
    label.new(
         bar_index,
         low - range_ * 0.6,
         text = "● BULL PB" + (i_showQual ? "\n" + f_stars(bullScore) : ""),
         style = label.style_label_up,
         color = bullCol,
         textcolor = color.white,
         size = size.small)

if bearSignal
    label.new(
         bar_index,
         high + range_ * 0.6,
         text = "● BEAR PB" + (i_showQual ? "\n" + f_stars(bearScore) : ""),
         style = label.style_label_down,
         color = bearCol,
         textcolor = color.white,
         size = size.small)

// ── EMA Reference Line ───────────────────────────────────────────────────────

plot(
     i_usePullback ? ema_ : na,
     title = "Trend EMA",
     color = color.new(color.blue, 50),
     linewidth = 1)

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────

alertcondition(
     bullSignal and bullScore >= 2,
     title = "⭐⭐⭐ High-Quality Bullish Pin Bar",
     message = "HIGH QUALITY Bullish Pin Bar: 3-star setup at {{ticker}} {{interval}} — Price: {{close}}")

alertcondition(
     bearSignal and bearScore >= 2,
     title = "⭐⭐⭐ High-Quality Bearish Pin Bar",
     message = "HIGH QUALITY Bearish Pin Bar: 3-star setup at {{ticker}} {{interval}} — Price: {{close}}")

alertcondition(
     bullSignal and bullScore == 1,
     title = "⭐⭐ Good Bullish Pin Bar",
     message = "GOOD Bullish Pin Bar at {{ticker}} {{interval}} — Price: {{close}}")

alertcondition(
     bearSignal and bearScore == 1,
     title = "⭐⭐ Good Bearish Pin Bar",
     message = "GOOD Bearish Pin Bar at {{ticker}} {{interval}} — Price: {{close}}")

alertcondition(
     bullSignal,
     title = "Any Bullish Pin Bar",
     message = "Bullish Pin Bar detected at {{ticker}} {{interval}} — Price: {{close}}")

alertcondition(
     bearSignal,
     title = "Any Bearish Pin Bar",
     message = "Bearish Pin Bar detected at {{ticker}} {{interval}} — Price: {{close}}")
````
