# EMA Trend Dash Board by [Itto Ryu]

- url: https://www.tradingview.com/script/FvCmBVYO-EMA-Trend-Dash-Board-by-Itto-Ryu/
- type: indicator
- pine_id: PUB;bb249b9cd9684370a8be1bd8b98519ee
- version: 3.0

## Description

# EMA Trend Dash Board — Trend stage classifier on a 5-EMA stack

A pure-EMA trend dashboard. Five exponential moving averages (10/20/50/100/200)
plus three derived signals — stack alignment, EMA50 slope, and the fast-vs-trend
gap — classify the market into one of four trend stages: ACCEL → MATURE → DECEL
→ REVERSAL. A 0-to-100 Bull/Bear score and a state-machine VERDICT row summarise
all of it in a single glance.

## What's different from a generic EMA ribbon

Most EMA-ribbon scripts only colour the EMAs. This one adds:

1. **Stage classification** — instead of "trending vs ranging", the script tells
   you *where in the trend you are*. Stage 1 (ACCEL) is for adds; Stage 3 (DECEL)
   warns to trim; Stage 4 (REVERSAL) tells you the stack has lost alignment.
2. **Bull/Bear score (0–100)** — composed of:
   - Price-above-EMA: 8 pts each (max 40)
   - Stack-pair ordering: 10 pts each (max 40)
   - Trend-EMA slope direction: 10 pts
   - Gap expansion (only when stack aligned): 10 pts
3. **Verdict state machine** — combines stage + score into one action label
   (STRONG SETUP, SIGNAL CLEAR, TREND ACCEL, EASE, WATCH, EXIT, ...).

## Defaults (and why)

| Input | Default | Reasoning |
|---|---|---|
| EMA lengths | 10 / 20 / 50 / 100 / 200 | Classic Stan Weinstein / Mark Minervini ladder |
| Slope/Gap lookback | 5 bars | Catches turns without over-smoothing on intraday |
| Slope flat threshold | 0.1% | Below this magnitude the trend EMA is treated as flat — avoids false up/down on chop |
| Gap expansion threshold | 0.05% | Min change in |gap| to count as expanding/compressing |
| Dashboard | top_right, normal | Standard placement; tiny/small for low-res screens |

## Visual elements

| Element | Meaning |
|---|---|
| 5 EMA lines | EMA 1 (fast, yellow) → EMA 5 (long, slate). EMA 3 (Trend, pink) drawn thicker as the slope reference |
| Fast-Trend fill | Green when EMA1 > EMA3, red otherwise. Quick visual on momentum direction |
| Right-edge labels | EMA name tags at the latest bar |
| Dashboard | Trend / EMA Stack / Trend Dynamics / Scoring / Signal / Verdict sections |

## Who this is for

- Trend-following swing traders who already use EMA stacks but want a state read-out
- Discretionary traders who want a "what stage am I in?" check without staring at the chart
- Anyone replacing 3-4 separate EMA indicators with one consolidated dashboard

## Who this is NOT for

- Pure mean-reversion / range traders — EMAs are the wrong tool
- Tick scalpers — the stage/gap thresholds are tuned for swing+intraday, not sub-minute
- Anyone needing entry/exit signals automated — this is a *read-out*, not a strategy

## How to use

1. Apply on standard candle chart, any timeframe (works best 15m → Daily)
2. Read the **Stage** row first — that's your context
3. Cross-check with **Verdict** row — that's your action
4. The Bull/Bear bars give a confidence reading; the SIGNAL row gives the discrete label
5. Configure alerts on STRONG Long/Short or Stack Broken for hands-off monitoring

## Common mistakes

- **Entering on Stage 4 just because Verdict says STRONG SETUP** — Stage 4 = stack lost alignment, by design it forces a re-check. Wait for re-alignment.
- **Reading dashboard on Heikin Ashi** — EMAs are calculated on HA close (a smoothed value), not real close. Numbers will not match a standard-chart EMA. Use standard candles for the dashboard.
- **Tuning EMA lengths for one symbol and assuming portability** — re-test on each instrument; trend EMAs are regime-dependent.

## Disclosure

- **Pine version**: v6
- **Repaint**: NO — all calculations use confirmed-bar data. Dashboard and right-edge labels refresh on the last bar (cosmetic only) and do not modify historical bars.
- **Lookahead**: NONE — no `request.security` calls.
- **Chart type**: Designed for standard candle charts. On Heikin Ashi / Renko / Range / PnF / Kagi the EMA values are calculated against the chart's synthetic close and will not match a standard-chart EMA.
- **Originality**: Generic 5-EMA inputs; novel additions are the Stage classifier, Bull/Bear scoring weights, and Verdict state machine.
- **Predecessor**: Extracted from the author's earlier "Ichimoku Trend Dash Board" (Ichimoku + EMA combined). This EMA-only variant strips Ichimoku, ADX, RSI, MACD, and SL/TP logic for a focused trend-stage read.

## Disclaimer
For educational purposes only. Not financial advice. Trading involves
substantial risk of loss — past performance does not guarantee future results.
You are solely responsible for your own trading decisions. Script provided
"as is" with no warranty; author is not liable for any losses.

## Source Code

````pine
//@version=6
// EMA Trend Dash Board //@version=6
// EMA Trend Dash Board by [Itto Ryu] — v2
// Pure EMA-based trend analysis. 5 EMAs + slope/gap dynamics + stage classification.
// v2 adds: multi-timeframe trend rows, pullback-to-EMA detection, ATR extension warning,
// EMA cross tracking + next-bar cross price projection, ribbon compression percentile,
// trend age, slope acceleration, score delta, on-chart signal markers, stage bar coloring,
// and reworked Stage 4 (4a WATCH / 4b EXIT / 4c BUILD / 4 IDLE) so every verdict state is reachable.
indicator("EMA Trend Dash Board v2 by [Itto Ryu] ", "EMA TDB v2", overlay=true, max_labels_count=20)

// ============================================================================
// INPUTS
// ============================================================================

grpEma = "EMA Lengths"
len1 = input.int(10, "EMA 1 (Fast)", minval=1, group=grpEma)
len2 = input.int(20, "EMA 2", minval=1, group=grpEma)
len3 = input.int(50, "EMA 3 (Trend)", minval=1, group=grpEma, tooltip="Reference EMA for slope, extension and pullback logic")
len4 = input.int(100, "EMA 4", minval=1, group=grpEma)
len5 = input.int(200, "EMA 5 (Long)", minval=1, group=grpEma)

grpDyn = "Trend Dynamics"
slopeLen = input.int(5, "Slope/Gap Lookback (bars)", minval=1, group=grpDyn)
slopeFlatThresh = input.float(0.1, "Slope Flat Threshold (%)", minval=0.01, step=0.01, group=grpDyn, tooltip="Below this magnitude → EMA Trend slope is treated as flat")
slopeFlatThreshLong = input.float(0.05, "Long EMA Slope Flat Threshold (%)", minval=0.01, step=0.01, group=grpDyn, tooltip="Flat threshold for the Long EMA slope — slower EMA, smaller threshold")
accelThresh = input.float(0.05, "Slope Accel Threshold (%)", minval=0.01, step=0.01, group=grpDyn, tooltip="Min slope change vs lookback to count as strengthening/weakening")
gapExpandThresh = input.float(0.05, "Gap Momentum Threshold (%)", minval=0.01, step=0.01, group=grpDyn, tooltip="Min |gap| change to count as expanding/compressing")

grpMtf = "Multi-Timeframe"
htfConfirm = input.bool(true, "Use closed HTF bars only", group=grpMtf, tooltip="ON: HTF values update only when the higher-TF bar closes (no intrabar repaint). OFF: live HTF values")
htfEn1 = input.bool(true, "", inline="htf1", group=grpMtf)
htfTf1 = input.timeframe("60", "HTF 1", inline="htf1", group=grpMtf)
htfEn2 = input.bool(true, "", inline="htf2", group=grpMtf)
htfTf2 = input.timeframe("240", "HTF 2", inline="htf2", group=grpMtf)
htfEn3 = input.bool(true, "", inline="htf3", group=grpMtf)
htfTf3 = input.timeframe("D", "HTF 3", inline="htf3", group=grpMtf)

grpTim = "Entry Timing"
pbLookback = input.int(5, "Pullback: max bars from EMA2 touch to trigger", minval=1, group=grpTim, tooltip="Touch = low/high reaches EMA2 while stack aligned. Trigger = close reclaims EMA1 within this many bars, or a same-bar wick rejection")
atrLen = input.int(14, "ATR Length", minval=1, group=grpTim)
extThresh = input.float(2.0, "Extension Warning (ATR from Trend EMA)", minval=0.1, step=0.1, group=grpTim, tooltip="Warn when |close − EMA3| exceeds this many ATRs — late to chase")

grpStruct = "Structure"
compLookback = input.int(100, "Ribbon Width Percentile Lookback", minval=10, group=grpStruct, tooltip="Lookback for ranking current ribbon width — low percentile = squeeze, watch for breakout")

grpVis = "Visuals"
showEmas = input.bool(true, "Show EMA Lines", group=grpVis)
col1 = input.color(#f7c948, "EMA 1 Color", group=grpVis)
col2 = input.color(#fb923c, "EMA 2 Color", group=grpVis)
col3 = input.color(#f43f5e, "EMA 3 Color (Trend)", group=grpVis)
col4 = input.color(#3b82f6, "EMA 4 Color", group=grpVis)
col5 = input.color(#94a3b8, "EMA 5 Color", group=grpVis)
showFastFill = input.bool(true, "Fill between Fast and Trend EMA", group=grpVis)
showLabels = input.bool(true, "Show EMA labels at right edge", group=grpVis)
showSigMarks = input.bool(true, "Signal markers (strong long/short, stack break)", group=grpVis)
showPbMarks = input.bool(true, "Pullback markers", group=grpVis)
showCrossMarks = input.bool(true, "Golden/Death cross markers (EMA3 × EMA5)", group=grpVis)
barColorOn = input.bool(false, "Color bars by stage", group=grpVis)

grpDash = "Dashboard"
showDash = input.bool(true, "Show Dashboard", group=grpDash)
dashPos = input.string("top_right", "Position", options=["top_right", "top_left", "middle_right", "middle_left", "bottom_right", "bottom_left"], group=grpDash)
dashSize = input.string("normal", "Size", options=["tiny", "small", "normal", "large"], group=grpDash)
secMtf = input.bool(true, "Show MTF section", group=grpDash)
secStack = input.bool(true, "Show EMA Stack section", group=grpDash)
secTiming = input.bool(true, "Show Entry Timing section", group=grpDash)

// ============================================================================
// CALCULATIONS — CORE (v1)
// ============================================================================

ema1 = ta.ema(close, len1)
ema2 = ta.ema(close, len2)
ema3 = ta.ema(close, len3)
ema4 = ta.ema(close, len4)
ema5 = ta.ema(close, len5)

ema3Slope = ema3[slopeLen] == 0 ? 0.0 : (ema3 - ema3[slopeLen]) / ema3[slopeLen] * 100
slopeFlat = math.abs(ema3Slope) < slopeFlatThresh
slopeUp = ema3Slope > 0 and not slopeFlat
slopeDown = ema3Slope < 0 and not slopeFlat

gapPct = ema3 == 0 ? 0.0 : (ema1 - ema3) / ema3 * 100
gapAbsNow = math.abs(gapPct)
gapAbsPrev = math.abs(gapPct[slopeLen])
gapMomentum = gapAbsNow - gapAbsPrev
gapExpanding = gapMomentum > gapExpandThresh
gapCompressing = gapMomentum < -gapExpandThresh
gapStable = not gapExpanding and not gapCompressing

bullPairs = (ema1 > ema2 ? 1 : 0) + (ema2 > ema3 ? 1 : 0) + (ema3 > ema4 ? 1 : 0) + (ema4 > ema5 ? 1 : 0)
bearPairs = (ema1 < ema2 ? 1 : 0) + (ema2 < ema3 ? 1 : 0) + (ema3 < ema4 ? 1 : 0) + (ema4 < ema5 ? 1 : 0)
stackBullAligned = bullPairs >= 3
stackBearAligned = bearPairs >= 3
stackAligned = stackBullAligned or stackBearAligned

stageNum = stackAligned and gapExpanding ? 1 : stackAligned and gapStable ? 2 : stackAligned and gapCompressing ? 3 : 4

above1 = close > ema1
above2 = close > ema2
above3 = close > ema3
above4 = close > ema4
above5 = close > ema5
abovePairs = (above1 ? 1 : 0) + (above2 ? 1 : 0) + (above3 ? 1 : 0) + (above4 ? 1 : 0) + (above5 ? 1 : 0)
belowPairs = 5 - abovePairs

// Scoring (max 100): abovePairs×8 (40) + stackPairs×10 (40) + slope (10) + gap expansion (10)
bullScore = abovePairs * 8 + bullPairs * 10 + (slopeUp ? 10 : 0) + (gapExpanding and stackBullAligned ? 10 : 0)
bearScore = belowPairs * 8 + bearPairs * 10 + (slopeDown ? 10 : 0) + (gapExpanding and stackBearAligned ? 10 : 0)

isLongBias = bullScore >= bearScore
biasTag = isLongBias ? "LONG" : "SHORT"
biasScore = isLongBias ? bullScore : bearScore

trendText = stackBullAligned and abovePairs >= 4 and slopeUp ? "BULL" : stackBearAligned and belowPairs >= 4 and slopeDown ? "BEAR" : "NEUTRAL"

strongLong = bullScore >= 80 and stackBullAligned
strongShort = bearScore >= 80 and stackBearAligned
longSig = bullScore >= 60 and abovePairs >= 4 and not strongLong
shortSig = bearScore >= 60 and belowPairs >= 4 and not strongShort
weakBull = bullScore > bearScore and bullScore >= 40 and not strongLong and not longSig
weakBear = bearScore > bullScore and bearScore >= 40 and not strongShort and not shortSig

signalText = strongLong ? "STRONG LONG" : longSig ? "LONG" : strongShort ? "STRONG SHORT" : shortSig ? "SHORT" : weakBull ? "WEAK BULL" : weakBear ? "WEAK BEAR" : "WAIT"

// ============================================================================
// CALCULATIONS — v2 ADDITIONS
// ============================================================================

// --- ATR extension from Trend EMA ---
atrVal = ta.atr(atrLen)
extAtr = atrVal == 0 ? 0.0 : (close - ema3) / atrVal
extended = math.abs(extAtr) >= extThresh

// --- Long EMA slope + slope acceleration ---
ema5Slope = ema5[slopeLen] == 0 ? 0.0 : (ema5 - ema5[slopeLen]) / ema5[slopeLen] * 100
ema5Flat = math.abs(ema5Slope) < slopeFlatThreshLong
ema5Up = ema5Slope > 0 and not ema5Flat
ema5Down = ema5Slope < 0 and not ema5Flat
slopeAccel = ema3Slope - nz(ema3Slope[slopeLen])
slopeStrengthening = (ema3Slope > 0 and slopeAccel > accelThresh) or (ema3Slope < 0 and slopeAccel < -accelThresh)
slopeWeakening = (ema3Slope > 0 and slopeAccel < -accelThresh) or (ema3Slope < 0 and slopeAccel > accelThresh)

// --- Ribbon compression (width of all 5 EMAs, ATR-normalized, percentile-ranked) ---
ribHi = math.max(ema1, ema2, ema3, ema4, ema5)
ribLo = math.min(ema1, ema2, ema3, ema4, ema5)
ribWidthAtr = atrVal == 0 ? 0.0 : (ribHi - ribLo) / atrVal
ribPct = ta.percentrank(ribWidthAtr, compLookback)
ribSqueeze = ribPct <= 20
ribWide = ribPct >= 80

// --- Trend age + last aligned direction (used by Stage 4 rework) ---
alignDir = stackBullAligned ? 1 : stackBearAligned ? -1 : 0
var int trendAge = 0
trendAge := alignDir == 0 ? 0 : alignDir == nz(alignDir[1]) ? trendAge + 1 : 1
var int lastAlignedDir = 0
if alignDir != 0
    lastAlignedDir := alignDir

// --- EMA crosses + next-bar cross price projection (pure EMA math, no repaint) ---
goldenCross = ta.crossover(ema3, ema5)
deathCross = ta.crossunder(ema3, ema5)
fastCrossUp = ta.crossover(ema1, ema2)
fastCrossDn = ta.crossunder(ema1, ema2)
barsFastCross = ta.barssince(fastCrossUp or fastCrossDn)
barsSlowCross = ta.barssince(goldenCross or deathCross)
alpha1 = 2.0 / (len1 + 1)
alpha2 = 2.0 / (len2 + 1)
xPrice = alpha1 == alpha2 ? na : ((1 - alpha2) * ema2 - (1 - alpha1) * ema1) / (alpha1 - alpha2)
xPct = na(xPrice) or close == 0 ? na : (xPrice - close) / close * 100

// --- Pullback detection: dip to EMA2 zone in an aligned stack, then reclaim EMA1 ---
pbTouchBull = stackBullAligned and low <= ema2
pbTouchBear = stackBearAligned and high >= ema2
pbSinceBull = ta.barssince(pbTouchBull)
pbSinceBear = ta.barssince(pbTouchBear)
pbReclaimBull = ta.crossover(close, ema1)
pbReclaimBear = ta.crossunder(close, ema1)
pbRawLong = stackBullAligned and ((pbReclaimBull and not na(pbSinceBull) and pbSinceBull <= pbLookback) or (pbTouchBull and close > ema1 and close >= open))
pbRawShort = stackBearAligned and ((pbReclaimBear and not na(pbSinceBear) and pbSinceBear <= pbLookback) or (pbTouchBear and close < ema1 and close <= open))
pullbackLong = pbRawLong and not pbRawLong[1]
pullbackShort = pbRawShort and not pbRawShort[1]

// --- Score delta (net score momentum, relative to current bias) ---
netScore = bullScore - bearScore
netDelta = netScore - nz(netScore[slopeLen])
biasDelta = isLongBias ? netDelta : -netDelta

// --- Stage 4 rework: old-trend breakdown vs new-trend build ---
enterStrong = (strongLong and isLongBias) or (strongShort and not isLongBias)
enterNormal = (longSig and isLongBias) or (shortSig and not isLongBias)
biasDir = isLongBias ? 1 : -1
sameDir4 = stageNum == 4 and lastAlignedDir != 0 and biasDir == lastAlignedDir
stage4Watch = sameDir4 and biasScore >= 60
stage4Exit = sameDir4 and biasScore >= 40 and biasScore < 60
stage4Dead = sameDir4 and biasScore < 40
stage4Early = stageNum == 4 and not sameDir4 and (enterStrong or enterNormal)
stage4Build = stageNum == 4 and not sameDir4 and not stage4Early and biasScore >= 40
stage4Idle = stageNum == 4 and not sameDir4 and not stage4Early and biasScore < 40
noSetup = stage4Dead or stage4Idle
lastTag = lastAlignedDir == 1 ? "LONG" : lastAlignedDir == -1 ? "SHORT" : biasTag

// --- Multi-timeframe trend (one security call per TF, tuple result) ---
htfOff = htfConfirm ? 1 : 0
f_tdb() =>
    e1 = ta.ema(close, len1)
    e2 = ta.ema(close, len2)
    e3 = ta.ema(close, len3)
    e4 = ta.ema(close, len4)
    e5 = ta.ema(close, len5)
    bp = (e1 > e2 ? 1 : 0) + (e2 > e3 ? 1 : 0) + (e3 > e4 ? 1 : 0) + (e4 > e5 ? 1 : 0)
    np = (e1 < e2 ? 1 : 0) + (e2 < e3 ? 1 : 0) + (e3 < e4 ? 1 : 0) + (e4 < e5 ? 1 : 0)
    sb = bp >= 3
    ss = np >= 3
    ab = (close > e1 ? 1 : 0) + (close > e2 ? 1 : 0) + (close > e3 ? 1 : 0) + (close > e4 ? 1 : 0) + (close > e5 ? 1 : 0)
    sl = e3[slopeLen] == 0 ? 0.0 : (e3 - e3[slopeLen]) / e3[slopeLen] * 100
    slFlat = math.abs(sl) < slopeFlatThresh
    slUp = sl > 0 and not slFlat
    slDn = sl < 0 and not slFlat
    gp = e3 == 0 ? 0.0 : (e1 - e3) / e3 * 100
    gm = math.abs(gp) - math.abs(gp[slopeLen])
    gx = gm > gapExpandThresh
    gcm = gm < -gapExpandThresh
    alg = sb or ss
    stg = alg and gx ? 1 : alg and not gx and not gcm ? 2 : alg and gcm ? 3 : 4
    bl = ab * 8 + bp * 10 + (slUp ? 10 : 0) + (gx and sb ? 10 : 0)
    br = (5 - ab) * 8 + np * 10 + (slDn ? 10 : 0) + (gx and ss ? 10 : 0)
    nt = bl - br
    cd = sb and ab >= 4 and slUp ? 1 : ss and (5 - ab) >= 4 and slDn ? -1 : 0
    [cd[htfOff], stg[htfOff], nt[htfOff]]

[htfCd1, htfStg1, htfNet1] = request.security(syminfo.tickerid, htfTf1, f_tdb())
[htfCd2, htfStg2, htfNet2] = request.security(syminfo.tickerid, htfTf2, f_tdb())
[htfCd3, htfStg3, htfNet3] = request.security(syminfo.tickerid, htfTf3, f_tdb())
chartSec = timeframe.in_seconds(timeframe.period)
htfValid1 = timeframe.in_seconds(htfTf1) > chartSec
htfValid2 = timeframe.in_seconds(htfTf2) > chartSec
htfValid3 = timeframe.in_seconds(htfTf3) > chartSec
mtfBullCnt = (htfEn1 and htfValid1 and nz(htfCd1) == 1 ? 1 : 0) + (htfEn2 and htfValid2 and nz(htfCd2) == 1 ? 1 : 0) + (htfEn3 and htfValid3 and nz(htfCd3) == 1 ? 1 : 0)
mtfBearCnt = (htfEn1 and htfValid1 and nz(htfCd1) == -1 ? 1 : 0) + (htfEn2 and htfValid2 and nz(htfCd2) == -1 ? 1 : 0) + (htfEn3 and htfValid3 and nz(htfCd3) == -1 ? 1 : 0)
mtfTotal = (htfEn1 and htfValid1 ? 1 : 0) + (htfEn2 and htfValid2 ? 1 : 0) + (htfEn3 and htfValid3 ? 1 : 0)

// ============================================================================
// PLOTS
// ============================================================================

p1 = plot(showEmas ? ema1 : na, "EMA 1", color=col1, linewidth=1)
p2 = plot(showEmas ? ema2 : na, "EMA 2", color=col2, linewidth=1)
p3 = plot(showEmas ? ema3 : na, "EMA 3 (Trend)", color=col3, linewidth=2)
p4 = plot(showEmas ? ema4 : na, "EMA 4", color=col4, linewidth=1)
p5 = plot(showEmas ? ema5 : na, "EMA 5 (Long)", color=col5, linewidth=2)

fill(p1, p3, color=showFastFill ? (ema1 > ema3 ? color.new(#26a69a, 88) : color.new(#ef5350, 88)) : na, title="Fast-Trend Fill")

plotshape(showSigMarks and strongLong and not strongLong[1], "Strong Long marker", style=shape.triangleup, location=location.belowbar, color=#3fb950, size=size.tiny)
plotshape(showSigMarks and strongShort and not strongShort[1], "Strong Short marker", style=shape.triangledown, location=location.abovebar, color=#f85149, size=size.tiny)
plotshape(showSigMarks and stageNum == 4 and stageNum[1] != 4, "Stack break marker", style=shape.xcross, location=location.abovebar, color=#8b949e, size=size.tiny)
plotshape(showPbMarks and pullbackLong, "Pullback Long marker", style=shape.diamond, location=location.belowbar, color=#26a69a, size=size.tiny)
plotshape(showPbMarks and pullbackShort, "Pullback Short marker", style=shape.diamond, location=location.abovebar, color=#ef5350, size=size.tiny)
plotshape(showCrossMarks and goldenCross, "Golden Cross marker", style=shape.labelup, location=location.belowbar, color=#e3b341, text="GC", textcolor=#0d1117, size=size.tiny)
plotshape(showCrossMarks and deathCross, "Death Cross marker", style=shape.labeldown, location=location.abovebar, color=#e3b341, text="DC", textcolor=#0d1117, size=size.tiny)

barcolor(barColorOn ? (stageNum == 4 ? color.new(#8b949e, 0) : stageNum == 3 ? color.new(#f0883e, 0) : isLongBias ? (stageNum == 1 ? color.new(#26a69a, 0) : color.new(#26a69a, 45)) : (stageNum == 1 ? color.new(#ef5350, 0) : color.new(#ef5350, 45))) : na, title="Stage bar color")

var label lbl1 = na
var label lbl2 = na
var label lbl3 = na
var label lbl4 = na
var label lbl5 = na

if showLabels and barstate.islast
    label.delete(lbl1)
    label.delete(lbl2)
    label.delete(lbl3)
    label.delete(lbl4)
    label.delete(lbl5)
    rightBar = bar_index + 5
    lbl1 := label.new(rightBar, ema1, "EMA " + str.tostring(len1), color=color.new(col1, 70), textcolor=col1, style=label.style_label_left, size=size.tiny)
    lbl2 := label.new(rightBar, ema2, "EMA " + str.tostring(len2), color=color.new(col2, 70), textcolor=col2, style=label.style_label_left, size=size.tiny)
    lbl3 := label.new(rightBar, ema3, "EMA " + str.tostring(len3), color=color.new(col3, 70), textcolor=col3, style=label.style_label_left, size=size.tiny)
    lbl4 := label.new(rightBar, ema4, "EMA " + str.tostring(len4), color=color.new(col4, 70), textcolor=col4, style=label.style_label_left, size=size.tiny)
    lbl5 := label.new(rightBar, ema5, "EMA " + str.tostring(len5), color=color.new(col5, 70), textcolor=col5, style=label.style_label_left, size=size.tiny)

// ============================================================================
// DASHBOARD
// ============================================================================

getPos(p) =>
    switch p
        "top_right" => position.top_right
        "top_left" => position.top_left
        "bottom_right" => position.bottom_right
        "bottom_left" => position.bottom_left
        "middle_right" => position.middle_right
        "middle_left" => position.middle_left
        => position.top_right

getSize(s) =>
    switch s
        "tiny" => size.tiny
        "small" => size.small
        "normal" => size.normal
        "large" => size.large
        => size.normal

var table dash = table.new(getPos(dashPos), 3, 40, bgcolor=color.new(#0d1117, 8), border_color=color.new(#30363d, 30), border_width=1)

if showDash and barstate.islast
    txtSz = getSize(dashSize)
    cHeader = color.new(#161b22, 0)
    cSection = color.new(#21262d, 10)
    cPri = #f0f6fc
    cSec = #8b949e
    cMute = #6e7681
    cAccent = #e3b341
    cBull = #3fb950
    cBear = #f85149
    cNeutral = #f0883e

    int r = 0

    // Header
    table.cell(dash, 0, r, "EMA TDB v2", text_color=cAccent, bgcolor=cHeader, text_size=txtSz)
    table.cell(dash, 1, r, syminfo.ticker, text_color=cPri, bgcolor=cHeader, text_size=txtSz)
    table.cell(dash, 2, r, timeframe.period, text_color=cPri, bgcolor=cHeader, text_size=txtSz)

    // Trend
    r := r + 1
    table.cell(dash, 0, r, "── TREND ──", text_color=cAccent, bgcolor=cSection, text_size=txtSz)
    table.cell(dash, 1, r, "", bgcolor=cSection)
    table.cell(dash, 2, r, "", bgcolor=cSection)

    r := r + 1
    trendColor = trendText == "BULL" ? cBull : trendText == "BEAR" ? cBear : cNeutral
    table.cell(dash, 0, r, "Trend", text_color=cSec, text_size=txtSz)
    table.cell(dash, 1, r, trendText, text_color=trendColor, text_size=txtSz)
    table.cell(dash, 2, r, str.tostring(abovePairs) + " / 5 above", text_color=cMute, text_size=txtSz)

    // MTF
    if secMtf
        r := r + 1
        table.cell(dash, 0, r, "── MTF ──", text_color=cAccent, bgcolor=cSection, text_size=txtSz)
        table.cell(dash, 1, r, "", bgcolor=cSection)
        table.cell(dash, 2, r, "", bgcolor=cSection)

        r := r + 1
        m1Off = not htfEn1 or not htfValid1
        m1Txt = not htfEn1 ? "off" : not htfValid1 ? "n/a" : nz(htfCd1) == 1 ? "BULL" : nz(htfCd1) == -1 ? "BEAR" : "NEUT"
        m1Col = nz(htfCd1) == 1 ? cBull : nz(htfCd1) == -1 ? cBear : cNeutral
        m1Sub = m1Off ? "—" : "S" + str.tostring(nz(htfStg1, 4)) + " · net " + (nz(htfNet1) >= 0 ? "+" : "") + str.tostring(nz(htfNet1))
        table.cell(dash, 0, r, "TF " + htfTf1, text_color=cSec, text_size=txtSz)
        table.cell(dash, 1, r, m1Txt, text_color=m1Off ? cMute : m1Col, text_size=txtSz)
        table.cell(dash, 2, r, m1Sub, text_color=cMute, text_size=txtSz)

        r := r + 1
        m2Off = not htfEn2 or not htfValid2
        m2Txt = not htfEn2 ? "off" : not htfValid2 ? "n/a" : nz(htfCd2) == 1 ? "BULL" : nz(htfCd2) == -1 ? "BEAR" : "NEUT"
        m2Col = nz(htfCd2) == 1 ? cBull : nz(htfCd2) == -1 ? cBear : cNeutral
        m2Sub = m2Off ? "—" : "S" + str.tostring(nz(htfStg2, 4)) + " · net " + (nz(htfNet2) >= 0 ? "+" : "") + str.tostring(nz(htfNet2))
        table.cell(dash, 0, r, "TF " + htfTf2, text_color=cSec, text_size=txtSz)
        table.cell(dash, 1, r, m2Txt, text_color=m2Off ? cMute : m2Col, text_size=txtSz)
        table.cell(dash, 2, r, m2Sub, text_color=cMute, text_size=txtSz)

        r := r + 1
        m3Off = not htfEn3 or not htfValid3
        m3Txt = not htfEn3 ? "off" : not htfValid3 ? "n/a" : nz(htfCd3) == 1 ? "BULL" : nz(htfCd3) == -1 ? "BEAR" : "NEUT"
        m3Col = nz(htfCd3) == 1 ? cBull : nz(htfCd3) == -1 ? cBear : cNeutral
        m3Sub = m3Off ? "—" : "S" + str.tostring(nz(htfStg3, 4)) + " · net " + (nz(htfNet3) >= 0 ? "+" : "") + str.tostring(nz(htfNet3))
        table.cell(dash, 0, r, "TF " + htfTf3, text_color=cSec, text_size=txtSz)
        table.cell(dash, 1, r, m3Txt, text_color=m3Off ? cMute : m3Col, text_size=txtSz)
        table.cell(dash, 2, r, m3Sub, text_color=cMute, text_size=txtSz)

        r := r + 1
        mtfColor = mtfBullCnt > mtfBearCnt ? cBull : mtfBearCnt > mtfBullCnt ? cBear : cNeutral
        table.cell(dash, 0, r, "MTF Align", text_color=cSec, text_size=txtSz)
        table.cell(dash, 1, r, str.tostring(mtfBullCnt) + "↑ / " + str.tostring(mtfBearCnt) + "↓", text_color=mtfColor, text_size=txtSz)
        table.cell(dash, 2, r, "of " + str.tostring(mtfTotal) + " TF", text_color=cMute, text_size=txtSz)

    // EMA Stack
    if secStack
        r := r + 1
        table.cell(dash, 0, r, "── EMA STACK ──", text_color=cAccent, bgcolor=cSection, text_size=txtSz)
        table.cell(dash, 1, r, "", bgcolor=cSection)
        table.cell(dash, 2, r, "", bgcolor=cSection)

        r := r + 1
        table.cell(dash, 0, r, "EMA " + str.tostring(len1), text_color=cSec, text_size=txtSz)
        table.cell(dash, 1, r, above1 ? "Above ↑" : "Below ↓", text_color=above1 ? cBull : cBear, text_size=txtSz)
        table.cell(dash, 2, r, str.tostring(ema1, format.mintick), text_color=cMute, text_size=txtSz)

        r := r + 1
        table.cell(dash, 0, r, "EMA " + str.tostring(len2), text_color=cSec, text_size=txtSz)
        table.cell(dash, 1, r, above2 ? "Above ↑" : "Below ↓", text_color=above2 ? cBull : cBear, text_size=txtSz)
        table.cell(dash, 2, r, str.tostring(ema2, format.mintick), text_color=cMute, text_size=txtSz)

        r := r + 1
        table.cell(dash, 0, r, "EMA " + str.tostring(len3), text_color=cSec, text_size=txtSz)
        table.cell(dash, 1, r, above3 ? "Above ↑" : "Below ↓", text_color=above3 ? cBull : cBear, text_size=txtSz)
        table.cell(dash, 2, r, str.tostring(ema3, format.mintick), text_color=cMute, text_size=txtSz)

        r := r + 1
        table.cell(dash, 0, r, "EMA " + str.tostring(len4), text_color=cSec, text_size=txtSz)
        table.cell(dash, 1, r, above4 ? "Above ↑" : "Below ↓", text_color=above4 ? cBull : cBear, text_size=txtSz)
        table.cell(dash, 2, r, str.tostring(ema4, format.mintick), text_color=cMute, text_size=txtSz)

        r := r + 1
        table.cell(dash, 0, r, "EMA " + str.tostring(len5), text_color=cSec, text_size=txtSz)
        table.cell(dash, 1, r, above5 ? "Above ↑" : "Below ↓", text_color=above5 ? cBull : cBear, text_size=txtSz)
        table.cell(dash, 2, r, str.tostring(ema5, format.mintick), text_color=cMute, text_size=txtSz)

        r := r + 1
        stackTxt = stackBullAligned ? "Bull " + str.tostring(bullPairs) + "/4 ↑" : stackBearAligned ? "Bear " + str.tostring(bearPairs) + "/4 ↓" : "Mixed (" + str.tostring(bullPairs) + "↑/" + str.tostring(bearPairs) + "↓)"
        stackColor = stackBullAligned ? cBull : stackBearAligned ? cBear : cNeutral
        table.cell(dash, 0, r, "Stack", text_color=cSec, text_size=txtSz)
        table.cell(dash, 1, r, stackTxt, text_color=stackColor, text_size=txtSz)
        table.cell(dash, 2, r, stackAligned ? "Aligned" : "Mixed", text_color=cMute, text_size=txtSz)

    // Trend Dynamics
    r := r + 1
    table.cell(dash, 0, r, "── TREND DYNAMICS ──", text_color=cAccent, bgcolor=cSection, text_size=txtSz)
    table.cell(dash, 1, r, "", bgcolor=cSection)
    table.cell(dash, 2, r, "", bgcolor=cSection)

    r := r + 1
    slopeTxt = slopeUp ? "Up ↗" : slopeDown ? "Down ↘" : "Flat →"
    slopeAligned = (slopeUp and isLongBias) or (slopeDown and not isLongBias)
    slopeColor = slopeFlat ? cNeutral : slopeAligned ? cBull : cBear
    table.cell(dash, 0, r, "EMA" + str.tostring(len3) + " Slope", text_color=cSec, text_size=txtSz)
    table.cell(dash, 1, r, slopeTxt, text_color=slopeColor, text_size=txtSz)
    table.cell(dash, 2, r, str.tostring(ema3Slope, "+#.##;-#.##") + "%", text_color=cMute, text_size=txtSz)

    r := r + 1
    slope5Txt = ema5Up ? "Up ↗" : ema5Down ? "Down ↘" : "Flat →"
    slope5Aligned = (ema5Up and isLongBias) or (ema5Down and not isLongBias)
    slope5Color = ema5Flat ? cNeutral : slope5Aligned ? cBull : cBear
    table.cell(dash, 0, r, "EMA" + str.tostring(len5) + " Slope", text_color=cSec, text_size=txtSz)
    table.cell(dash, 1, r, slope5Txt, text_color=slope5Color, text_size=txtSz)
    table.cell(dash, 2, r, str.tostring(ema5Slope, "+#.##;-#.##") + "%", text_color=cMute, text_size=txtSz)

    r := r + 1
    accelTxt = slopeStrengthening ? "Strengthening ↑" : slopeWeakening ? "Weakening ↓" : "Steady →"
    accelColor = slopeStrengthening ? cBull : slopeWeakening ? cBear : cNeutral
    table.cell(dash, 0, r, "Slope Accel", text_color=cSec, text_size=txtSz)
    table.cell(dash, 1, r, accelTxt, text_color=accelColor, text_size=txtSz)
    table.cell(dash, 2, r, str.tostring(slopeAccel, "+#.##;-#.##") + "%", text_color=cMute, text_size=txtSz)

    r := r + 1
    gapTxt = gapExpanding ? "Expanding ↑" : gapCompressing ? "Compressing ↓" : "Stable →"
    gapColor = gapExpanding ? cBull : gapCompressing ? cBear : cNeutral
    table.cell(dash, 0, r, "Gap (" + str.tostring(len1) + "-" + str.tostring(len3) + ")", text_color=cSec, text_size=txtSz)
    table.cell(dash, 1, r, gapTxt, text_color=gapColor, text_size=txtSz)
    table.cell(dash, 2, r, str.tostring(gapPct, "+#.##;-#.##") + "%", text_color=cMute, text_size=txtSz)

    r := r + 1
    ribTxt = ribSqueeze ? "SQUEEZE ◆" : ribWide ? "Wide" : "Normal"
    ribColor = ribSqueeze ? cAccent : ribWide ? cNeutral : cSec
    table.cell(dash, 0, r, "Ribbon Width", text_color=cSec, text_size=txtSz)
    table.cell(dash, 1, r, ribTxt, text_color=ribColor, text_size=txtSz)
    table.cell(dash, 2, r, str.tostring(ribWidthAtr, "#.##") + " ATR · P" + str.tostring(math.round(nz(ribPct))), text_color=cMute, text_size=txtSz)

    r := r + 1
    ageTxt = alignDir == 1 ? str.tostring(trendAge) + " bars (Bull)" : alignDir == -1 ? str.tostring(trendAge) + " bars (Bear)" : "—"
    ageColor = alignDir == 1 ? cBull : alignDir == -1 ? cBear : cMute
    table.cell(dash, 0, r, "Trend Age", text_color=cSec, text_size=txtSz)
    table.cell(dash, 1, r, ageTxt, text_color=ageColor, text_size=txtSz)
    table.cell(dash, 2, r, "since stack aligned", text_color=cMute, text_size=txtSz)

    r := r + 1
    extTxt = extended ? "EXTENDED ⚠" : "OK"
    extColor = extended ? cNeutral : cSec
    table.cell(dash, 0, r, "Extension", text_color=cSec, text_size=txtSz)
    table.cell(dash, 1, r, extTxt, text_color=extColor, text_size=txtSz)
    table.cell(dash, 2, r, str.tostring(extAtr, "+#.##;-#.##") + " ATR from EMA" + str.tostring(len3), text_color=cMute, text_size=txtSz)

    r := r + 1
    stageTextDisp = stageNum == 1 ? "1 ACCEL" : stageNum == 2 ? "2 MATURE" : stageNum == 3 ? "3 DECEL" : stage4Watch ? "4a WATCH" : stage4Exit ? "4b EXIT" : stage4Early or stage4Build ? "4c BUILD" : "4 IDLE"
    stageBg = stageNum <= 3 ? color.new(isLongBias ? #238636 : #da3633, 30) : stage4Watch or stage4Exit ? color.new(lastAlignedDir == 1 ? #238636 : #da3633, 30) : stage4Early or stage4Build ? color.new(isLongBias ? #238636 : #da3633, 50) : color.new(#30363d, 0)
    stageHint = stageNum == 1 ? "RIDE " + biasTag + " ↑" : stageNum == 2 ? "HOLD " + biasTag : stageNum == 3 ? "TRIM " + biasTag + " ⚠" : stage4Watch ? "WATCH " + lastTag + " ⚠" : stage4Exit ? "EXIT " + lastTag + " ✕" : stage4Early or stage4Build ? "BUILD " + biasTag + " 👀" : "WAIT"
    hintColor = stage4Exit ? cBear : stage4Watch ? cNeutral : stage4Dead or stage4Idle ? cMute : isLongBias ? cBull : cBear
    table.cell(dash, 0, r, "Stage", text_color=cSec, text_size=txtSz)
    table.cell(dash, 1, r, stageTextDisp, text_color=cPri, bgcolor=stageBg, text_size=txtSz)
    table.cell(dash, 2, r, stageHint, text_color=hintColor, text_size=txtSz)

    // Entry Timing
    if secTiming
        r := r + 1
        table.cell(dash, 0, r, "── ENTRY TIMING ──", text_color=cAccent, bgcolor=cSection, text_size=txtSz)
        table.cell(dash, 1, r, "", bgcolor=cSection)
        table.cell(dash, 2, r, "", bgcolor=cSection)

        r := r + 1
        pbStatus = pullbackLong ? "TRIGGER ↑" : pullbackShort ? "TRIGGER ↓" : pbTouchBull ? "In zone (bull)" : pbTouchBear ? "In zone (bear)" : stackBullAligned and not na(pbSinceBull) and pbSinceBull <= pbLookback ? "Touched " + str.tostring(pbSinceBull) + "b ago" : stackBearAligned and not na(pbSinceBear) and pbSinceBear <= pbLookback ? "Touched " + str.tostring(pbSinceBear) + "b ago" : "—"
        pbColor = pullbackLong or pbTouchBull ? cBull : pullbackShort or pbTouchBear ? cBear : cMute
        table.cell(dash, 0, r, "Pullback", text_color=cSec, text_size=txtSz)
        table.cell(dash, 1, r, pbStatus, text_color=pbColor, text_size=txtSz)
        table.cell(dash, 2, r, "dip EMA" + str.tostring(len2) + " → reclaim EMA" + str.tostring(len1), text_color=cMute, text_size=txtSz)

        r := r + 1
        fastCrossTxt = na(barsFastCross) ? "—" : (ema1 > ema2 ? "Bull ↑ " : "Bear ↓ ") + str.tostring(barsFastCross) + "b ago"
        table.cell(dash, 0, r, "Cross " + str.tostring(len1) + "×" + str.tostring(len2), text_color=cSec, text_size=txtSz)
        table.cell(dash, 1, r, fastCrossTxt, text_color=ema1 > ema2 ? cBull : cBear, text_size=txtSz)
        table.cell(dash, 2, r, str.tostring(ema1 - ema2, format.mintick) + " apart", text_color=cMute, text_size=txtSz)

        r := r + 1
        slowCrossTxt = na(barsSlowCross) ? "—" : (ema3 > ema5 ? "Golden ↑ " : "Death ↓ ") + str.tostring(barsSlowCross) + "b ago"
        table.cell(dash, 0, r, "Cross " + str.tostring(len3) + "×" + str.tostring(len5), text_color=cSec, text_size=txtSz)
        table.cell(dash, 1, r, slowCrossTxt, text_color=ema3 > ema5 ? cBull : cBear, text_size=txtSz)
        table.cell(dash, 2, r, str.tostring(ema3 - ema5, format.mintick) + " apart", text_color=cMute, text_size=txtSz)

        r := r + 1
        xTxt = na(xPrice) ? "—" : str.tostring(xPrice, format.mintick)
        xSub = na(xPct) ? "—" : str.tostring(xPct, "+#.##;-#.##") + "% from close"
        table.cell(dash, 0, r, "X-Price " + str.tostring(len1) + "×" + str.tostring(len2), text_color=cSec, text_size=txtSz)
        table.cell(dash, 1, r, xTxt, text_color=cPri, text_size=txtSz)
        table.cell(dash, 2, r, xSub, text_color=cMute, text_size=txtSz)

    // Scoring
    r := r + 1
    table.cell(dash, 0, r, "── SCORING ──", text_color=cAccent, bgcolor=cSection, text_size=txtSz)
    table.cell(dash, 1, r, "", bgcolor=cSection)
    table.cell(dash, 2, r, "", bgcolor=cSection)

    r := r + 1
    bullBar = str.repeat("█", math.max(0, math.round(bullScore / 10)))
    table.cell(dash, 0, r, "Bull Score", text_color=cSec, text_size=txtSz)
    table.cell(dash, 1, r, str.tostring(bullScore) + "/100", text_color=cBull, text_size=txtSz)
    table.cell(dash, 2, r, bullBar, text_color=cBull, text_size=txtSz)

    r := r + 1
    bearBar = str.repeat("█", math.max(0, math.round(bearScore / 10)))
    table.cell(dash, 0, r, "Bear Score", text_color=cSec, text_size=txtSz)
    table.cell(dash, 1, r, str.tostring(bearScore) + "/100", text_color=cBear, text_size=txtSz)
    table.cell(dash, 2, r, bearBar, text_color=cBear, text_size=txtSz)

    r := r + 1
    deltaTxt = biasDelta > 5 ? "Improving ↑" : biasDelta < -5 ? "Fading ↓" : "Flat →"
    deltaColor = biasDelta > 5 ? cBull : biasDelta < -5 ? cBear : cNeutral
    table.cell(dash, 0, r, "Δ Score (" + str.tostring(slopeLen) + "b)", text_color=cSec, text_size=txtSz)
    table.cell(dash, 1, r, deltaTxt, text_color=deltaColor, text_size=txtSz)
    table.cell(dash, 2, r, (netDelta >= 0 ? "+" : "") + str.tostring(netDelta) + " net", text_color=cMute, text_size=txtSz)

    // Signal row
    r := r + 1
    isLongSig = signalText == "STRONG LONG" or signalText == "LONG" or signalText == "WEAK BULL"
    isShortSig = signalText == "STRONG SHORT" or signalText == "SHORT" or signalText == "WEAK BEAR"
    sigBg = isLongSig ? color.new(#238636, 10) : isShortSig ? color.new(#da3633, 10) : color.new(#30363d, 0)
    biasArrow = isLongBias ? "▲ LONG" : "▼ SHORT"
    biasColor = isLongBias ? cBull : cBear
    table.cell(dash, 0, r, "SIGNAL", text_color=cPri, bgcolor=color.new(#010409, 0), text_size=txtSz)
    table.cell(dash, 1, r, signalText, text_color=cPri, bgcolor=sigBg, text_size=txtSz)
    table.cell(dash, 2, r, biasArrow, text_color=biasColor, text_size=txtSz)

    // Verdict
    r := r + 1
    biasBgStrong = isLongBias ? #238636 : #da3633
    lastBgBroken = lastAlignedDir == 1 ? #da3633 : #238636
    verdictAction = noSetup ? "💤 NO SETUP" : stage4Exit ? "💥 TREND BROKEN " + lastTag : stage4Watch ? "⚠ STRUCTURE WEAK " + lastTag : stage4Early ? "✅ EARLY SIGNAL " + biasTag : stage4Build ? "👀 SIGNAL BUILDING " + biasTag : stageNum == 3 ? "📉 EASE " + biasTag + " ⚠" : enterStrong ? "🚀 STRONG SETUP " + biasTag : enterNormal ? "✅ SIGNAL CLEAR " + biasTag : stageNum == 1 ? "🔥 TREND ACCEL " + biasTag : "⏸ TREND MATURE " + biasTag
    verdictSize = noSetup ? "—" : str.tostring(biasScore) + "/100 " + biasTag
    verdictBg = noSetup ? color.new(#30363d, 0) : stage4Exit ? color.new(lastBgBroken, 30) : stage4Watch ? color.new(#f0883e, 20) : stage4Early ? color.new(biasBgStrong, 30) : stage4Build ? color.new(biasBgStrong, 70) : stageNum == 3 ? color.new(#f0883e, 30) : enterStrong ? color.new(biasBgStrong, 0) : enterNormal ? color.new(biasBgStrong, 30) : stageNum == 1 ? color.new(biasBgStrong, 40) : color.new(biasBgStrong, 60)
    table.cell(dash, 0, r, "VERDICT", text_color=cAccent, bgcolor=color.new(#010409, 0), text_size=txtSz)
    table.cell(dash, 1, r, verdictAction, text_color=cPri, bgcolor=verdictBg, text_size=txtSz)
    table.cell(dash, 2, r, verdictSize, text_color=cPri, bgcolor=verdictBg, text_size=txtSz)

// ============================================================================
// ALERTS
// ============================================================================

alertcondition(strongLong and not strongLong[1], "EMA TDB — STRONG Long", "EMA Trend Dashboard STRONG LONG (score 80+, stack bull aligned)")
alertcondition(strongShort and not strongShort[1], "EMA TDB — STRONG Short", "EMA Trend Dashboard STRONG SHORT (score 80+, stack bear aligned)")
alertcondition(longSig and not longSig[1], "EMA TDB — Long", "EMA Trend Dashboard LONG signal")
alertcondition(shortSig and not shortSig[1], "EMA TDB — Short", "EMA Trend Dashboard SHORT signal")
alertcondition(stageNum == 4 and stageNum[1] != 4, "EMA TDB — Stack Broken", "EMA stack alignment lost — possible trend reversal")
alertcondition(stageNum == 1 and stageNum[1] != 1, "EMA TDB — Stage 1 ACCEL", "Trend just entered Stage 1 (acceleration)")
alertcondition(stageNum == 3 and stageNum[1] != 3, "EMA TDB — Stage 3 DECEL", "Trend entered Stage 3 (deceleration) — gap compressing, consider trimming")
alertcondition(pullbackLong, "EMA TDB — Pullback Long", "Pullback long: dip to EMA2 zone reclaimed in bull stack")
alertcondition(pullbackShort, "EMA TDB — Pullback Short", "Pullback short: rally to EMA2 zone rejected in bear stack")
alertcondition(goldenCross, "EMA TDB — Golden Cross", "Trend EMA crossed above Long EMA (golden cross)")
alertcondition(deathCross, "EMA TDB — Death Cross", "Trend EMA crossed below Long EMA (death cross)")
````
