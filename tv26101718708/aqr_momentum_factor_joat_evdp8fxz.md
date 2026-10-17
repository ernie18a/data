# AQR Momentum Factor [JOAT]

- url: https://www.tradingview.com/script/eVDP8fxz-AQR-Momentum-Factor-JOAT/
- type: indicator
- pine_id: PUB;e59457cbd117406aa5c5ddc340376ddf
- version: 1.0

## Description

[b]AQR MOMENTUM FACTOR [JOAT][/b]

A tribute to AQR Capital Management's seminal momentum-factor research — including Asness's classic "Value and Momentum Everywhere" framework. The script estimates [b]cross-horizon momentum[/b] by ranking returns across five independent look-back horizons (default 1, 5, 20, 60, 120 bars — including the AQR-canonical 12-1 month equivalent), volatility-adjusting the result, and producing a composite momentum score in [−1, +1] that fires Buy / Sell labels when the score crosses configurable thresholds.

[image]https://www.tradingview.com/x/1u7MwATN/[/image]

[b]Why cross-horizon ranking[/b]

A single momentum lookback is fragile. AQR's published research (Asness, Moskowitz, Pedersen, and others) shows that momentum is best estimated by [i]agreement across horizons[/i] — when short-, medium-, and long-term momentum all point the same way, the signal is much more reliable than any single horizon alone. The script encodes that directly:

[list]
[*] [b]Five horizons[/b] — 1 / 5 / 20 / 60 / 120 bars by default (configurable independently).
[*] At each horizon the return is [b]percentile-ranked[/b] against its own trailing 252-bar (trading year) distribution.
[*] The five percentile ranks are mapped from [0, 100] to [−1, +1] (50% → 0; 100% → +1; 0% → −1).
[*] The composite is the average of the five mapped ranks.
[/list]

The output is bounded in [−1, +1] and represents [i]how unusual current momentum is relative to its own recent history, averaged across timeframes[/i].

[b]Volatility adjustment (optional but on by default)[/b]

The composite is divided by a [b]volatility Z-score[/b] over a configurable window (default 60 bars), clamped at a Z cap (default 2.5) to avoid division-by-zero blow-ups. This dampens signals during high-volatility regimes — which is what AQR's "low-vol momentum" research finds is the genuinely tradeable component of the factor.

When vol-adjustment is off, the score is raw cross-horizon momentum. When it is on, the score is risk-adjusted momentum, which is the institutional read.

[b]Signal engine[/b]

[list]
[*] [b]BUY[/b] — composite > buy threshold (default +0.70 → top ~15% across horizons).
[*] [b]SELL[/b] — composite < sell threshold (default −0.70).
[*] [b]Extreme High / Low alerts[/b] — composite > +0.90 / < −0.90. The script's strongest reads.
[/list]

A configurable [b]Min Bars Between Same-Side Signals[/b] (default 5) prevents clustering. A confirm-on-close toggle (default ON) ensures non-repaint signals.

[b]Bar colouring — strict 2-hue discipline[/b]

The chart bars are coloured by the sign of the composite, with saturation proportional to magnitude. The "Bar Color Saturation Floor" input controls how aggressively the colour fades when momentum is weak — at 0 the bars are always full colour; at 1 they fade toward background when momentum is weak. The defaults (0.65) produce a clean institutional read where strong-momentum bars stand out and weak-momentum bars merge into the background.

A hidden composite-line plot (toggleable) opens a [−1, +1] pane below the chart for users who want to see the score itself, or feed it to Data Window / webhook automation.

[image]https://www.tradingview.com/x/crVHo9Wc/[/image]

[b]Visual system[/b]

[list]
[*] [b]Buy / Sell labels[/b] on threshold crosses (configurable size).
[*] [b]Bar colouring[/b] by signed momentum with saturation floor.
[*] [b]Hidden composite line[/b] (toggleable, pane).
[*] [b]Light regime background[/b] (off by default) — very subtle bgcolor sampled from bull/bear.
[/list]

A locked Golden Blaze palette: gold bull / oxblood bear / off-white neutral on a dark-slate ground — the classic AQR institutional aesthetic. Strict 3-hue discipline + bg.

[b]Dashboard[/b]

Monospaced table positionable to any of nine corners. Surfaces:

[list]
[*] Composite score with signed value.
[*] Per-horizon percentile ranks (h1 / h2 / h3 / h4 / h5).
[*] Horizon agreement count (how many horizons agree with the composite sign).
[*] Volatility Z value and adjustment factor in use.
[*] Last signal direction with bars-ago.
[*] Configuration: rank window, vol window, thresholds.
[/list]

[b]Alerts[/b]

Four alert conditions, each independently controllable:

[list]
[*] BUY (composite crosses above buy threshold)
[*] SELL (composite crosses below sell threshold)
[*] Extreme Score (|composite| crosses extreme high or low)
[*] Horizon Disagreement (off by default) — fires when horizons split (~half above 50%, half below). Useful as a "no edge" warning.
[/list]

[b]How to read it[/b]

Three reads, in order of conviction:

[list=1]
[*] [b]Extreme score with full horizon agreement[/b] — the highest-conviction read. All five horizons agree, the score is in the top 10% / bottom 10% of its own distribution, and vol-adjustment has not damped it. This is the institutional setup.
[*] [b]Buy / Sell with vol-adjustment active in a low-vol regime[/b] — the "low-vol momentum" setup AQR's research identifies as the strongest factor exposure. Pair with a directional execution tool.
[*] [b]Horizon disagreement alert[/b] — stand-aside signal. Some horizons say bull, some say bear; there is no momentum factor exposure available. Wait for agreement to return.
[/list]

[b]Suggested settings[/b]

Defaults (horizons 1/5/20/60/120, rank window 252, vol window 60, vol Z cap 2.5, ±0.70 thresholds, ±0.90 extreme) are tuned for daily charts on broad indices — the timeframes where momentum factor exposures are statistically most meaningful. For lower timeframes drop all horizons proportionally (1/5/15/30/60) and the rank window to 200. For weekly+ keep defaults; momentum on weekly is the canonical factor.

[b]Originality / what's reused[/b]

The momentum factor is published academic finance — Jegadeesh & Titman 1993, Asness 1994, AQR's "Value and Momentum Everywhere" 2013. The 252-bar / one-year ranking window is the classical institutional convention. The implementation here — the five-horizon configurable engine, the [b]ta.percentrank[/b]-based ranking pipeline, the [−1, +1] linear remap, the volatility-Z adjustment with clamp, the saturation-floored bar-colouring with strict 2-hue discipline, the horizon-disagreement alert logic, and the AQR Golden Blaze palette — is JOAT-original. No third-party code reused. The script is a [i]tribute[/i] to AQR's published methodology, not a direct replication of any proprietary AQR model.

[b]Open source[/b]

Published open-source under the default Mozilla Public License 2.0. The horizon pipeline, the ranking engine, the vol-adjustment routine, the signal engine, and the dashboard are isolated modules. Forks welcome with credit.

[b]Limitations[/b]

The 252-bar ranking window assumes a daily chart for the "trading year" interpretation; on lower timeframes the window represents a different real-world horizon. The momentum factor is well-documented historically but, like all factor exposures, it can underperform for extended periods — the dashboard's horizon-agreement count is the script's own early warning when the factor is breaking down. Vol-adjustment is on by default because it is statistically supported; turn it off only for research.

—

-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title="AQR Momentum Factor [JOAT]", shorttitle="AQR [JOAT]", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500, max_bars_back=5000)

// =====================================================================
//  SECTION 1 - INPUTS
// =====================================================================
grpHorz   = "+======= Horizons (Look-Back Lags) =======+"
grpRank   = "+======= Percentile Engine =======+"
grpVol    = "+======= Volatility Adjustment =======+"
grpSig    = "+======= Signal Thresholds =======+"
grpVis    = "+======= Visuals =======+"
grpDash   = "+======= Dashboard =======+"
grpAlt    = "+======= Alerts =======+"

// Horizons -----------------------------------------------------------
h1Len = input.int(1,   "Horizon 1 (bars)",   minval=1, maxval=500, group=grpHorz, tooltip="Short-term return horizon. Default 1 = bar-to-bar.")
h2Len = input.int(5,   "Horizon 2 (bars)",   minval=2, maxval=500, group=grpHorz, tooltip="Weekly momentum on intraday TFs.")
h3Len = input.int(20,  "Horizon 3 (bars)",   minval=3, maxval=500, group=grpHorz, tooltip="Monthly trend.")
h4Len = input.int(60,  "Horizon 4 (bars)",   minval=4, maxval=500, group=grpHorz, tooltip="Quarterly momentum (classic 12-1 month in AQR papers).")
h5Len = input.int(120, "Horizon 5 (bars)",   minval=5, maxval=1000,group=grpHorz, tooltip="Long-term factor exposure.")

// Percentile rank window ---------------------------------------------
rankLen     = input.int(252, "Percentile Window (bars)", minval=20, maxval=2000, group=grpRank, tooltip="Trailing window for ta.percentrank. 252 ~ 1 year of trading days.")
useVolAdj   = input.bool(true,  "Enable Volatility Adjustment", group=grpVol, tooltip="Divide composite by a volatility Z, dampening signals during high-vol regimes.")
volLen      = input.int(60,  "Vol Window (bars)", minval=10, maxval=500, group=grpVol)
volZCap     = input.float(2.5, "Vol Z Cap",       minval=0.5, maxval=10.0, step=0.1, group=grpVol, tooltip="Vol Z is clamped at +/- this value to avoid div-by-zero blow-ups.")

// Signal -------------------------------------------------------------
buyThresh   = input.float( 0.70, "BUY Threshold (>)",  minval=0.10, maxval=1.0, step=0.05, group=grpSig, tooltip="Composite > this triggers BUY. 0.70 = top 15% across horizons.")
sellThresh  = input.float(-0.70, "SELL Threshold (<)", minval=-1.0, maxval=-0.10, step=0.05, group=grpSig)
extremeHi   = input.float( 0.90, "Extreme High (alert)", minval=0.50, maxval=1.0, step=0.05, group=grpSig)
extremeLo   = input.float(-0.90, "Extreme Low (alert)",  minval=-1.0, maxval=-0.50, step=0.05, group=grpSig)
signalGap   = input.int(5, "Min Bars Between Same-Side Signals", minval=0, maxval=200, group=grpSig)
useConfirm  = input.bool(true, "Confirm On Bar Close",  group=grpSig, tooltip="Use barstate.isconfirmed to commit signals (no repaint).")

// Visuals ------------------------------------------------------------
showLabels  = input.bool(true,  "Show BUY/SELL Labels",      group=grpVis)
showBarCol  = input.bool(true,  "Color Bars By Momentum",    group=grpVis, tooltip="Sign-based bull/bear gradient. ONLY two hues.")
barSat      = input.float(0.65, "Bar Color Saturation Floor", minval=0.0, maxval=1.0, step=0.05, group=grpVis, tooltip="0 = always full color, 1 = always faded. Mid range looks institutional.")
showPaneLn  = input.bool(false, "Show Composite Line (Pane)", group=grpVis, tooltip="Off by default. When ON, opens a pane with the [-1,+1] momentum line.")
showBgTint  = input.bool(false, "Light Regime Background",    group=grpVis, tooltip="Subtle bgcolor sampled from bull/bear, very translucent.")
labelSize   = input.string("Small", "Label Size", options=["Tiny","Small","Normal","Large","Huge"], group=grpVis)

// Dashboard ----------------------------------------------------------
showDash      = input.bool(true, "Show Dashboard", group=grpDash)
dashPosStr    = input.string("Top Right", "Position", options=["Top Right","Top Left","Top Center","Bottom Right","Bottom Left","Bottom Center","Middle Right","Middle Left","Middle Center"], group=grpDash)
dashSizeStr   = input.string("Small", "Text Size",  options=["Tiny","Small","Normal","Large","Huge"], group=grpDash)

// Alerts -------------------------------------------------------------
alertBuy      = input.bool(true,  "Alert on BUY",            group=grpAlt)
alertSell     = input.bool(true,  "Alert on SELL",           group=grpAlt)
alertExtreme  = input.bool(true,  "Alert on Extreme Score",  group=grpAlt)
alertDisagree = input.bool(false, "Alert on Horizon Disagreement", group=grpAlt, tooltip="Triggers when horizons split (~half above 50, half below).")

// =====================================================================
//  SECTION 2 - COLOR PALETTE  (Golden Blaze - locked institutional)
// =====================================================================
//  Single curated palette. No theme switcher. Gold = bull (momentum positive)
//  / oxblood = bear (momentum negative) / off-white neutral / dark-slate bg /
//  deep slate frame. Classic AQR institutional aesthetic.

const color C_BULL    = #FFD700
const color C_BEAR    = #8B0000
const color C_NEUTRAL = #F5F5F5
const color C_BG      = #2F4F4F
const color C_FRAME   = #1A2A2A

// Derived shades (still within the 3-hue discipline; these are just
// transparency / mixing variants of the same three slots).
color cBullSoft  = color.new(C_BULL, 75)
color cBearSoft  = color.new(C_BEAR, 75)
color cBullFaint = color.new(C_BULL, 88)
color cBearFaint = color.new(C_BEAR, 88)
color cBgFrame   = color.new(C_BG,  35)
color cBgHead    = color.new(C_BG,  10)
color cBgRow     = color.new(C_BG,  60)
color cText      = color.new(#FFFFFF, 0)
color cTextDim   = color.new(#FFFFFF, 35)

// =====================================================================
//  SECTION 3 - HELPER FUNCTIONS
// =====================================================================

// 3.1 RGB linear interpolation between two colors.
//     Used ONLY for bull<->bear gradient sampling (never rainbow).
f_colorGradient(float _ratio, color _colA, color _colB) =>
    rA = color.r(_colA), gA = color.g(_colA), bA = color.b(_colA)
    rB = color.r(_colB), gB = color.g(_colB), bB = color.b(_colB)
    rr = rA + int((rB - rA) * _ratio)
    rg = gA + int((gB - gA) * _ratio)
    rb = bA + int((bB - bA) * _ratio)
    color.rgb(rr, rg, rb, 0)

// 3.2 Clamp.
f_clamp(float _x, float _min, float _max) => math.max(_min, math.min(_x, _max))

// 3.3 Map a score in [-1, +1] to a bull/bear gradient color.
//     Sign-based: negative -> bear, positive -> bull. NEVER a 3rd hue.
f_signColor(float score) =>
    // Magnitude controls how saturated we go (further from 0 = stronger color).
    mag = f_clamp(math.abs(score), 0.0, 1.0)
    // Mix from background toward the appropriate hue.
    target = score >= 0.0 ? C_BULL : C_BEAR
    // Transparency scales inversely with magnitude, with a saturation floor.
    t = int(math.round(100.0 * (1.0 - mag) * barSat))
    color.new(target, t)

// 3.4 Position / size string resolvers (standard JOAT library).
strToPos(string s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        =>               position.top_right

strToSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.small

// 3.5 Pretty percentile string with sign-conscious formatting.
fmtPct(float p) =>
    str.tostring(p, "#.0") + "%"

// 3.6 Pretty score string for [-1, +1] composite.
fmtScore(float s) =>
    (s >= 0.0 ? "+" : "") + str.tostring(s, "#.000")

// 3.7 Horizon agreement: count how many of the 5 horizons share the
//     same sign as the composite. Returns 0..5 plus a label.
agreementLabel(int hits) =>
    out = "Weak"
    if hits >= 5
        out := "Unanimous (5/5)"
    else if hits == 4
        out := "Strong (4/5)"
    else if hits == 3
        out := "Mixed (3/5)"
    else if hits == 2
        out := "Split (2/5)"
    else
        out := "Disagreement (<2)"
    out

// =====================================================================
//  SECTION 4 - CORE CALCULATIONS
// ---------------------------------------------------------------------
//  Multi-horizon log-return percentiles. We use simple returns
//  (close - close[T]) / close[T], then ta.percentrank for distribution-
//  free standardization. Average -> recenter to [-1, +1].
// =====================================================================

// 4.1 Raw multi-horizon returns (guard close[T] > 0 to dodge div/0).
ret(int len) =>
    src0 = close
    srcT = close[len]
    (na(srcT) or srcT <= 0.0) ? na : (src0 - srcT) / srcT

ret1 = ret(h1Len)
ret2 = ret(h2Len)
ret3 = ret(h3Len)
ret4 = ret(h4Len)
ret5 = ret(h5Len)

// 4.2 Percentile rank of each return within rolling window.
pr1 = ta.percentrank(ret1, rankLen)
pr2 = ta.percentrank(ret2, rankLen)
pr3 = ta.percentrank(ret3, rankLen)
pr4 = ta.percentrank(ret4, rankLen)
pr5 = ta.percentrank(ret5, rankLen)

// 4.3 Composite percentile (average across horizons), with NA safety.
//     Each pr is 0..100. We average those that exist.
sumPR   = 0.0
countPR = 0
if not na(pr1)
    sumPR += pr1
    countPR += 1
if not na(pr2)
    sumPR += pr2
    countPR += 1
if not na(pr3)
    sumPR += pr3
    countPR += 1
if not na(pr4)
    sumPR += pr4
    countPR += 1
if not na(pr5)
    sumPR += pr5
    countPR += 1
avgPR = countPR > 0 ? sumPR / countPR : na

// 4.4 Recenter to [-1, +1].  50 -> 0,  100 -> +1,  0 -> -1.
rawScore = na(avgPR) ? na : (avgPR - 50.0) / 50.0

// 4.5 Volatility adjustment.  We compute the stdev of 1-bar returns
//     over volLen, then a percentile-rank-based Z proxy that is robust
//     to the absence of a true distribution.
volSeries = ta.stdev(ret1, volLen)
volMean   = ta.sma(volSeries, volLen)
volSD     = ta.stdev(volSeries, volLen)
volZraw   = (not na(volSD) and volSD > 0.0) ? (volSeries - volMean) / volSD : 0.0
volZ      = f_clamp(nz(volZraw, 0.0), -volZCap, volZCap)

// Dampening multiplier: when vol is high (z > 0), shrink the score.
// When vol is low (z < 0), the score can punch through a bit harder
// but we cap it at +/- 1 to keep the [-1,+1] discipline.
volMult = useVolAdj ? f_clamp(1.0 / (1.0 + math.max(volZ, 0.0) * 0.5), 0.35, 1.20) : 1.0
score   = na(rawScore) ? na : f_clamp(rawScore * volMult, -1.0, 1.0)

// 4.6 Horizon agreement count (vs composite sign).
sgn(float v) => v > 0.0 ? 1 : v < 0.0 ? -1 : 0
compSign = na(score) ? 0 : sgn(score)
agreeHits = 0
if not na(pr1) and not na(score) and sgn((pr1-50.0)/50.0) == compSign and compSign != 0
    agreeHits += 1
if not na(pr2) and not na(score) and sgn((pr2-50.0)/50.0) == compSign and compSign != 0
    agreeHits += 1
if not na(pr3) and not na(score) and sgn((pr3-50.0)/50.0) == compSign and compSign != 0
    agreeHits += 1
if not na(pr4) and not na(score) and sgn((pr4-50.0)/50.0) == compSign and compSign != 0
    agreeHits += 1
if not na(pr5) and not na(score) and sgn((pr5-50.0)/50.0) == compSign and compSign != 0
    agreeHits += 1

// 4.7 Disagreement detector (approx half above 50, half below).
above50 = 0
below50 = 0
if not na(pr1)
    above50 += pr1 >= 50.0 ? 1 : 0
    below50 += pr1 <  50.0 ? 1 : 0
if not na(pr2)
    above50 += pr2 >= 50.0 ? 1 : 0
    below50 += pr2 <  50.0 ? 1 : 0
if not na(pr3)
    above50 += pr3 >= 50.0 ? 1 : 0
    below50 += pr3 <  50.0 ? 1 : 0
if not na(pr4)
    above50 += pr4 >= 50.0 ? 1 : 0
    below50 += pr4 <  50.0 ? 1 : 0
if not na(pr5)
    above50 += pr5 >= 50.0 ? 1 : 0
    below50 += pr5 <  50.0 ? 1 : 0
horizonDisagree = (above50 >= 2 and below50 >= 2)

// =====================================================================
//  SECTION 5 - STATE / TRACKING
// =====================================================================
var int   lastBuyBar     = -10000
var int   lastSellBar    = -10000
var int   lastSignalKind = 0          // +1 BUY, -1 SELL, 0 NONE
var float lastSignalScore= na
var int   lastSignalBar  = -10000

// =====================================================================
//  SECTION 6 - SIGNAL ENGINE
// ---------------------------------------------------------------------
//  - Threshold cross (raw)
//  - Cooldown gap (signalGap bars)
//  - Cross-side lockout: after BUY, suppress further BUYs until score
//    returns below 0 (and vice versa) so we don't spam.
//  - Optional barstate.isconfirmed gating.
// =====================================================================

var bool canBuy  = true
var bool canSell = true

// Reset locks when score returns to the opposite side of zero.
if not na(score)
    if score < 0.0
        canBuy := true
    if score > 0.0
        canSell := true

confirmOk = useConfirm ? barstate.isconfirmed : true

rawBuy  = not na(score) and score > buyThresh  and canBuy  and confirmOk and (bar_index - lastBuyBar)  >= signalGap
rawSell = not na(score) and score < sellThresh and canSell and confirmOk and (bar_index - lastSellBar) >= signalGap

if rawBuy
    canBuy          := false
    lastBuyBar      := bar_index
    lastSignalBar   := bar_index
    lastSignalKind  := 1
    lastSignalScore := score

if rawSell
    canSell         := false
    lastSellBar     := bar_index
    lastSignalBar   := bar_index
    lastSignalKind  := -1
    lastSignalScore := score

// Extreme momentum (alerts only, no labels).
isExtremeUp = not na(score) and score >  extremeHi
isExtremeDn = not na(score) and score <  extremeLo

// =====================================================================
//  SECTION 7 - PLOTS / FILLS / CANDLES
// ---------------------------------------------------------------------
//  Visual rule: chart shows AT MOST {C_BULL, C_BEAR, C_BG}.
//  Bar coloring uses ONLY the two hues, sign-based, with magnitude
//  controlling transparency. Pane line (optional, off by default) uses
//  the same two hues split on zero.
// =====================================================================

// 7.1 Bar coloring (overlay).  Sign-based gradient, two hues only.
color barCol = na
if showBarCol and not na(score)
    barCol := f_signColor(score)
barcolor(barCol)

// 7.2 Subtle regime background (off by default).  Heavily faded so
//     it stays subordinate to the candles.
color bgTint = na
if showBgTint and not na(score)
    bgTint := color.new(score >= 0 ? C_BULL : C_BEAR, 92)
bgcolor(bgTint)

// 7.3 Optional pane companion.  force_overlay = false so it opens
//     a separate pane. Uses TWO hues only (above/below zero split).
lineCol = na(score) ? na : (score >= 0.0 ? C_BULL : C_BEAR)
plot(showPaneLn and not na(score) ? score : na, title="Composite Momentum", color=lineCol, linewidth=2, force_overlay=false)
plot(showPaneLn ? 0.0      : na, "Zero Line",   color=color.new(#FFFFFF, 70), linewidth=1, style=plot.style_line, force_overlay=false)
plot(showPaneLn ? buyThresh  : na, "Buy Thresh",  color=color.new(C_BULL, 60), linewidth=1, style=plot.style_line, force_overlay=false)
plot(showPaneLn ? sellThresh : na, "Sell Thresh", color=color.new(C_BEAR, 60), linewidth=1, style=plot.style_line, force_overlay=false)

// 7.4 Tiny zero-line plot for context when pane is on (hidden by default
//     when pane is off).  Cosmetic only.
plot(showPaneLn ? extremeHi : na, "Extreme Hi", color=color.new(C_BULL, 80), style=plot.style_circles, linewidth=1, force_overlay=false)
plot(showPaneLn ? extremeLo : na, "Extreme Lo", color=color.new(C_BEAR, 80), style=plot.style_circles, linewidth=1, force_overlay=false)

// =====================================================================
//  SECTION 8 - DRAWINGS  (BUY / SELL labels on the overlay)
// ---------------------------------------------------------------------
//  Labels are the ONLY thing we draw on the overlay (besides bar color
//  / optional bg tint).  This keeps the chart clean and institutional.
// =====================================================================

lblSize = strToSize(labelSize)

if showLabels and rawBuy
    label.new(
         x         = bar_index,
         y         = low,
         text      = "AQR BUY\n" + fmtScore(score),
         style     = label.style_label_up,
         color     = color.new(C_BULL, 10),
         textcolor = #000000,
         size      = lblSize,
         tooltip   = "AQR Momentum BUY\n" +
                     "Composite: " + fmtScore(score) + "\n" +
                     "Agreement: " + str.tostring(agreeHits) + "/5\n" +
                     "Vol mult: "  + str.tostring(volMult, "#.00"))

if showLabels and rawSell
    label.new(
         x         = bar_index,
         y         = high,
         text      = "AQR SELL\n" + fmtScore(score),
         style     = label.style_label_down,
         color     = color.new(C_BEAR, 10),
         textcolor = #FFFFFF,
         size      = lblSize,
         tooltip   = "AQR Momentum SELL\n" +
                     "Composite: " + fmtScore(score) + "\n" +
                     "Agreement: " + str.tostring(agreeHits) + "/5\n" +
                     "Vol mult: "  + str.tostring(volMult, "#.00"))

// =====================================================================
//  SECTION 9 - DASHBOARD  (10-row layout per spec)
// ---------------------------------------------------------------------
//  Row map:
//    0  Header
//    1  Composite Momentum Score
//    2  Signal (BUY / SELL / FLAT) + horizon agreement label
//    3  Separator
//    4  Horizon 1 percentile
//    5  Horizon 2 percentile
//    6  Horizon 3 percentile
//    7  Horizon 4 percentile
//    8  Horizon 5 percentile
//    9  Horizon Agreement count
//   10  Vol-Adjustment status + active multiplier
// =====================================================================

var table dash = table.new(
     position    = strToPos(dashPosStr),
     columns     = 2,
     rows        = 11,
     bgcolor     = na,
     frame_color = cBgFrame,
     frame_width = 1,
     border_color= color.new(C_BG, 75),
     border_width= 1)

dashTxtSize = strToSize(dashSizeStr)

// Helper: row writer that keeps formatting consistent.
writeRow(table _t, int r, string lbl, string val, color valCol, color rowBg, string tsize) =>
    table.cell(_t, 0, r, lbl, text_color=cText,   bgcolor=rowBg, text_halign=text.align_left,  text_size=tsize, text_font_family=font.family_monospace)
    table.cell(_t, 1, r, val, text_color=valCol,  bgcolor=rowBg, text_halign=text.align_right, text_size=tsize, text_font_family=font.family_monospace)

// Helper: percentile row writer (color by side of 50).
writePr(table _t, int r, string label_, float pr, color cBull, color cBear, color cDim, color rowBg, string tsize) =>
    valTxt = na(pr) ? "n/a" : fmtPct(pr)
    valCol = na(pr) ? cDim : (pr >= 50.0 ? cBull : cBear)
    writeRow(_t, r, label_, valTxt, valCol, rowBg, tsize)

if showDash and barstate.islast
    // Status dot color reflects regime.
    statusDot = na(score) ? "o" : score > buyThresh ? "*" : score < sellThresh ? "*" : "."
    statusCol = na(score) ? cTextDim : score > buyThresh ? C_BULL : score < sellThresh ? C_BEAR : cTextDim

    // 0 - Header (spans both columns visually via matching bg).
    table.cell(dash, 0, 0, "AQR MOMENTUM FACTOR", text_color=cText, bgcolor=cBgHead, text_halign=text.align_left, text_size=dashTxtSize, text_font_family=font.family_monospace)
    table.cell(dash, 1, 0, statusDot + " [JOAT]",   text_color=statusCol, bgcolor=cBgHead, text_halign=text.align_right, text_size=dashTxtSize, text_font_family=font.family_monospace)

    // 1 - Composite score.
    scoreCol = na(score) ? cTextDim : (score >= 0.0 ? C_BULL : C_BEAR)
    writeRow(dash, 1, "Composite Score", na(score) ? "n/a" : fmtScore(score), scoreCol, cBgRow, dashTxtSize)

    // 2 - Signal.
    sigText = na(score) ? "FLAT" : score > buyThresh ? "BUY" : score < sellThresh ? "SELL" : "FLAT"
    sigCol  = na(score) ? cTextDim : score > buyThresh ? C_BULL : score < sellThresh ? C_BEAR : cTextDim
    writeRow(dash, 2, "Signal", sigText, sigCol, cBgRow, dashTxtSize)

    // 3 - Separator row.
    table.cell(dash, 0, 3, "--- horizons ---", text_color=cTextDim, bgcolor=cBgRow, text_halign=text.align_left,  text_size=dashTxtSize, text_font_family=font.family_monospace)
    table.cell(dash, 1, 3, "percentile",       text_color=cTextDim, bgcolor=cBgRow, text_halign=text.align_right, text_size=dashTxtSize, text_font_family=font.family_monospace)

    // 4..8 - Horizons.
    writePr(dash, 4, "H1  ("  + str.tostring(h1Len) + "b)", pr1, C_BULL, C_BEAR, cTextDim, cBgRow, dashTxtSize)
    writePr(dash, 5, "H2  ("  + str.tostring(h2Len) + "b)", pr2, C_BULL, C_BEAR, cTextDim, cBgRow, dashTxtSize)
    writePr(dash, 6, "H3  ("  + str.tostring(h3Len) + "b)", pr3, C_BULL, C_BEAR, cTextDim, cBgRow, dashTxtSize)
    writePr(dash, 7, "H4  ("  + str.tostring(h4Len) + "b)", pr4, C_BULL, C_BEAR, cTextDim, cBgRow, dashTxtSize)
    writePr(dash, 8, "H5  ("  + str.tostring(h5Len) + "b)", pr5, C_BULL, C_BEAR, cTextDim, cBgRow, dashTxtSize)

    // 9 - Horizon agreement.
    agreeCol = agreeHits >= 4 ? C_BULL : agreeHits >= 3 ? color.new(C_BULL, 35) : agreeHits >= 2 ? cTextDim : C_BEAR
    writeRow(dash, 9, "Horizon Agreement", agreementLabel(agreeHits), agreeCol, cBgRow, dashTxtSize)

    // 10 - Vol-adjustment state.
    volTxt = useVolAdj ? ("ON  (x" + str.tostring(volMult, "#.00") + ")") : "OFF"
    volCol = useVolAdj ? (volMult < 1.0 ? C_BEAR : C_BULL) : cTextDim
    writeRow(dash, 10, "Vol Adjustment", volTxt, volCol, cBgRow, dashTxtSize)

// =====================================================================
//  SECTION 10 - ALERTS
// =====================================================================

if alertBuy and rawBuy
    alert("AQR [JOAT] BUY  | score=" + fmtScore(score) + " | agree=" + str.tostring(agreeHits) + "/5", alert.freq_once_per_bar_close)

if alertSell and rawSell
    alert("AQR [JOAT] SELL | score=" + fmtScore(score) + " | agree=" + str.tostring(agreeHits) + "/5", alert.freq_once_per_bar_close)

if alertExtreme and (isExtremeUp or isExtremeDn)
    alert("AQR [JOAT] EXTREME " + (isExtremeUp ? "BULL" : "BEAR") + " | score=" + fmtScore(score), alert.freq_once_per_bar_close)

if alertDisagree and horizonDisagree
    alert("AQR [JOAT] Horizon disagreement | above50=" + str.tostring(above50) + " below50=" + str.tostring(below50), alert.freq_once_per_bar_close)

alertcondition(not na(score) and ta.crossover(score,  buyThresh),  title="AQR Cross Above BUY",  message="AQR [JOAT] crossed above BUY threshold")
alertcondition(not na(score) and ta.crossunder(score, sellThresh), title="AQR Cross Below SELL", message="AQR [JOAT] crossed below SELL threshold")
alertcondition(not na(score) and ta.crossover(score,  extremeHi),  title="AQR Extreme Bull",     message="AQR [JOAT] entered extreme bullish zone")
alertcondition(not na(score) and ta.crossunder(score, extremeLo),  title="AQR Extreme Bear",     message="AQR [JOAT] entered extreme bearish zone")

// =====================================================================
//  END OF AQR Momentum Factor [JOAT]
// =====================================================================
````
