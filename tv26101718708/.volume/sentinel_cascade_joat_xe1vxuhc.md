# Sentinel Cascade [JOAT]

- url: https://www.tradingview.com/script/XE1vXUHc-Sentinel-Cascade-JOAT/
- type: indicator
- pine_id: PUB;b8a4b0047bbe47aea4b1f11deb61d577
- version: 1.0

## Description

[b]Sentinel Cascade [JOAT][/b]

Sentinel Cascade is a three-stage adaptive Supertrend overlay. Where a classic Supertrend uses one fixed-ATR band, this script chains three Supertrend stages on top of each other and modulates each stage's width with a different regime signal. Bands tighten when the market is trending cleanly and widen when volatility expands or behavior turns mean-reverting.

[image]https://www.tradingview.com/x/tC5i8Js9/[/image]

[b]What makes it different[/b]
[list]
[*] A standard Supertrend gives one binary direction state. Sentinel Cascade gives three nested direction states that act like a confluence stack. Alignment of all three is the highest-conviction read.
[*] The ATR feeding the Supertrend is smoothed through a Kaufman Efficiency Ratio. Trend-efficient periods get a faster ATR response. Choppy periods get a slower response.
[*] Stage 2's width scales with a volume Z-score. High-volume bars widen the band so transient noise is less likely to flip the stage.
[*] Stage 3's width scales with a lightweight two-point Hurst estimator (R/S over short and long windows). Trending Hurst above 0.5 widens. Mean-reverting Hurst below 0.5 tightens.
[*] A Sentinel pulse fires only when Stage 3 flips AND Stage 2 confirms the new direction within three bars. A coincidence filter for higher-quality regime shifts.
[/list]

[b]How it works[/b]
[list=1]
[*] Compute a basis price as the midpoint of the recent highest high and lowest low.
[*] Compute a KAMA-smoothed ATR from the basis.
[*] Build Stage 1 as a Supertrend on the basis using the KAMA-ATR and the Stage 1 factor.
[*] Build Stage 2 as a Supertrend on Stage 1's output, with its factor multiplied by a clamped volume-Z modulator.
[*] Build Stage 3 as a Supertrend on Stage 2's output, with its factor multiplied by a clamped Hurst modulator.
[*] Track the Sentinel pulse, the ATR-percentile regime (squeeze / normal / expansion), and a running count of intraday Stage 3 flips.
[/list]

[b]Reading the chart[/b]
[list]
[*] Three stacked trend lines. Stage 1 thickest, Stage 3 thinnest. Colors flip between bull and bear on direction changes.
[*] A gradient ribbon between Stage 1 (or Stage 2 by user choice) and Stage 3 brightens when the stack is spread, fades when it converges.
[*] An optional iridescent candle recolor scales tint with distance from Stage 3.
[*] A horizontal sight-line projects Stage 3's current level back into history so past respect or rejection at that level is visible.
[*] Persistent flip markers record each Stage 3 flip and retroactively append an [i]OK[/i] or [i]FAIL[/i] tag after a user-defined persistence window.
[*] A right-edge state block summarizes alignment of all three stages plus the ATR squeeze and expansion read.
[/list]

[b]Signals[/b]
[list]
[*] Stage 3 bull / bear shift (any flip)
[*] Cascade alignment (all three stages agree)
[*] Stage 2 retest / bounce inside an active trend
[*] ATR squeeze and expansion entry (percentile-based)
[/list]
All signals are gated on barstate.isconfirmed or barstate.ishistory. No future-bar referencing. No lookahead_on.

[b]Inputs[/b]
[list]
[*] [b]Cascade[/b]: range basis length, ATR period, KAMA efficiency length, Stage 1 / 2 / 3 factors.
[*] [b]Regime[/b]: volume-Z lookback, Hurst short / long windows.
[*] [b]Visual[/b]: bullish color, bearish color, toggles for ribbon, sentinel pulse, iridescent candles, bounce markers, ribbon anchor.
[*] [b]On-chart[/b]: stage value labels, flip timeline labels, squeeze background tint, Stage 3 cloud, sight-line, state block, daily flip counter.
[*] [b]Dashboard[/b]: position, size, watermark row.
[/list]

[b]How traders use this[/b]
[list]
[*] [b]Trend continuation[/b]: take in the direction of Stage 3 when price retests Stage 2 from the trending side.
[*] [b]High-conviction entries[/b]: wait for cascade alignment (all three stages agree) before sizing up.
[*] [b]Mean-reversion fades[/b]: when Hurst is clearly below 0.5 and a Stage 3 flip prints near recent extremes, the new trend is statistically less likely to persist.
[*] [b]Volatility context[/b]: ATR percentile regime tells you whether the move is happening in a compressed, normal, or extended volatility environment. Sizing should account for that.
[/list]

[b]Limitations[/b]
[list]
[*] The two-point Hurst estimator is a fast approximation, not the full rescaled-range statistic. It is monotonically meaningful but is not a precise persistence coefficient.
[*] Like every Supertrend variant, this is a trend-following construct. It is best on instruments with clear directional regimes and worst in extended choppy ranges.
[*] Pivots and percentile-based regime classifications need warm-up bars before their values stabilize.
[*] Past behavior is not a guarantee of future behavior. No indicator can remove market uncertainty.
[/list]

[b]Compatibility[/b]
Pine Script v6, single-file open-source indicator. Works on any symbol and any timeframe. Uses no request.security calls. Non-repainting beyond the normal Supertrend right-bar reactivity inherent to band ratchet logic.

[b]Defaults[/b]
Mint bullish color, red bearish color, top-right medium dashboard, all on-chart visualizations on. Open the inputs panel to tune for your instrument or to declutter for screenshots.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
// ════════════════════════════════════════════════════════════════════
//   JOAT — Sentinel Cascade [JOAT]   |   3-stage cascading Supertrend
//   Stage 1: KAMA-ATR on N-bar basis | Stage 2: volZ-weighted on S1
//   Stage 3: Hurst-weighted on S2    | Sentinel pulse on confirmed flip
// ════════════════════════════════════════════════════════════════════
indicator("Sentinel Cascade [JOAT]", "SCD [JOAT]", overlay=true, explicit_plot_zorder=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, behind_chart=false)

// ════════════════════════════════════════════════════════════════════
// INPUTS
// ════════════════════════════════════════════════════════════════════
g_cascade   = "Cascade"
g_regime    = "Regime"
g_visual    = "Visual"
g_onchart   = "On-Chart Density"
g_dash      = "Dashboard"

rangeLen      = input.int(20,   "Range Basis Length",      minval=2,             group=g_cascade, tooltip="Lookback for highest/lowest used to compute the Stage 1 basis price.")
atrPeriod     = input.int(14,   "ATR Period",              minval=2,             group=g_cascade, tooltip="Period for the raw ATR fed into KAMA smoothing.")
erLen         = input.int(14,   "KAMA Efficiency Length",  minval=2,             group=g_cascade, tooltip="Lookback for the Kaufman Efficiency Ratio that adapts ATR smoothing speed.")
stage1Factor  = input.float(1.0,"Stage 1 Factor",          minval=0.1, step=0.1, group=g_cascade, tooltip="Base ATR multiplier for the inner Supertrend.")
stage2Factor  = input.float(1.5,"Stage 2 Factor",          minval=0.1, step=0.1, group=g_cascade, tooltip="Base ATR multiplier for the second Supertrend (modulated by volume Z).")
stage3Factor  = input.float(2.0,"Stage 3 Factor",          minval=0.1, step=0.1, group=g_cascade, tooltip="Base ATR multiplier for the outer Supertrend (modulated by Hurst regime).")

volZLen       = input.int(20,   "Volume Z Length",         minval=2,             group=g_regime,  tooltip="Lookback for normalizing volume into a Z-score; modulates Stage 2 width.")
hurstShort    = input.int(8,    "Hurst Short Lookback",    minval=4,             group=g_regime,  tooltip="Short window for the two-point Hurst estimate.")
hurstLong     = input.int(32,   "Hurst Long Lookback",     minval=8,             group=g_regime,  tooltip="Long window for the two-point Hurst estimate.")

bullColor     = input.color(#00ffbb, "Bullish", inline="cBull",                  group=g_visual,  tooltip="Primary bullish color — JOAT brand mint.")
bearColor     = input.color(#ff1100, "Bearish", inline="cBull",                  group=g_visual,  tooltip="Primary bearish color — JOAT brand red.")
showRibbon    = input.bool(true, "Show Stage Ribbon",                            group=g_visual,  tooltip="Toggle the gradient ribbon between two stages.")
ribbonAnchor  = input.string("Stage 1 to 3", "Ribbon Anchor",
     options=["Stage 1 to 3","Stage 2 to 3"],
     group=g_visual, tooltip="Inner edge of the cascade ribbon.")
showS2Cloud   = input.bool(true, "Stage 2 Cloud",                                group=g_visual,  tooltip="Subtle Stage 2 confirmation cloud between Stage 2 and Stage 3.")
showPulse     = input.bool(true, "Show Sentinel Pulse",                          group=g_visual,  tooltip="Toggle the background pulse on cascade regime shifts.")
showCandles   = input.bool(true, "Iridescent Candles",                           group=g_visual,  tooltip="Recolor chart candles by Stage 3 distance.")
showBounce    = input.bool(true, "Bounce Markers",                               group=g_visual,  tooltip="Subtle dot markers when price retests Stage 2 inside an active trend.")

showStageLabels  = input.bool(true,  "Right-Edge Stage Labels",                  group=g_onchart, tooltip="Persistent labels at the right edge showing each stage's current price and direction.")
showFlipLabels   = input.bool(true,  "Trend-Start Flip Labels",                  group=g_onchart, tooltip="Drop a label at each Stage 3 flip showing the start price, with retroactive OK/FAIL outcome tag.")
maxFlipLabels    = input.int(15,     "Max Flip Labels",       minval=3, maxval=50, group=g_onchart, tooltip="FIFO cap on stored flip labels — oldest are removed first.")
flipPersistBars  = input.int(10,     "Flip Persistence Bars", minval=2, maxval=100, group=g_onchart, tooltip="Bars the new trend must persist for the prior flip to be tagged OK.")
showSqueezeBg    = input.bool(true,  "Squeeze / Expansion BG",                   group=g_onchart, tooltip="Soft sustained background tint across the whole duration of ATR squeeze and expansion regimes.")
showStage3Cloud  = input.bool(true,  "Stage 3 Trend Cloud",                      group=g_onchart, tooltip="Gradient fill between Stage 3 and price — opacity modulated by trend strength.")
showSightLine    = input.bool(true,  "Stage 3 Sight Line",                       group=g_onchart, tooltip="A dotted horizontal projection of the current Stage 3 level into recent history and future.")
showStateBlock   = input.bool(true,  "State Alignment Block",                    group=g_onchart, tooltip="Right-edge segmented block showing Stage 1/2/3 alignment plus a STATE text label.")
showCascadeBg    = input.bool(true,  "Cascade Alignment BG",                     group=g_onchart, tooltip="Background tint for high-conviction zones where all 3 stages agree.")
showFlipsCounter = input.bool(true,  "Flips-Today Counter",                      group=g_onchart, tooltip="Right-edge counter of Stage 3 flips since the last daily rollover.")
showSentinelLbl  = input.bool(true,  "Sentinel Pulse Labels",                    group=g_onchart, tooltip="Persistent label at each sentinel pulse bar, in addition to the bgcolor pulse.")
showFlipVlines   = input.bool(true,  "Flip Vertical Anchors",                    group=g_onchart, tooltip="Persistent dotted vertical timeline anchors at each Stage 3 flip bar; capped FIFO.")
showAtrGauge     = input.bool(true,  "ATR Percentile Gauge",                     group=g_onchart, tooltip="Mini 5-bar percentile gauge at the right edge showing where kamaATR sits in its 100-bar window.")
showStageSpread  = input.bool(true,  "Stage Spread Telemetry",                   group=g_onchart, tooltip="Right-edge label showing the ATR-normalized spread between Stage 1 and Stage 3.")
showHurstGauge   = input.bool(true,  "Hurst Regime Gauge",                       group=g_onchart, tooltip="Right-edge color-coded gauge segment showing the Hurst regime position.")

showDash      = input.bool(true, "Show Dashboard",                               group=g_dash,    tooltip="Toggle the institutional dashboard panel.")
dashPos       = input.string("top_right", "Dashboard Position",
     options=["top_right","top_center","top_left","middle_right","middle_center","middle_left","bottom_right","bottom_center","bottom_left"],
     group=g_dash, tooltip="Anchor the dashboard to any of the 9 chart positions.")
dashSize      = input.string("Medium", "Dashboard Size",
     options=["Tiny","Small","Medium","Large"],
     group=g_dash, tooltip="Cell text size for the dashboard.")

// ════════════════════════════════════════════════════════════════════
// HELPERS
// ════════════════════════════════════════════════════════════════════

// Map dashboard position string to native enum
posFromString(string s) =>
    s == "top_left"      ? position.top_left      :
     s == "top_center"   ? position.top_center    :
     s == "top_right"    ? position.top_right     :
     s == "middle_left"  ? position.middle_left   :
     s == "middle_center"? position.middle_center :
     s == "middle_right" ? position.middle_right  :
     s == "bottom_left"  ? position.bottom_left   :
     s == "bottom_center"? position.bottom_center :
     position.bottom_right

// Map dashboard size string to native enum
sizeFromString(string s) =>
    s == "Tiny"   ? size.tiny    :
     s == "Small" ? size.small   :
     s == "Large" ? size.large   :
     size.normal

// Manual Supertrend with NA-safe history handling (Pine v6 canonical pattern)
f_supertrend(float factor, float atrSeries, float src) =>
    upperBand = src + factor * atrSeries
    lowerBand = src - factor * atrSeries
    prevUpper = nz(upperBand[1])
    prevLower = nz(lowerBand[1])
    lowerBand := lowerBand > prevLower or src[1] < prevLower ? lowerBand : prevLower
    upperBand := upperBand < prevUpper or src[1] > prevUpper ? upperBand : prevUpper
    int   dir = na
    float st  = na
    prevST    = nz(st[1])
    if na(atrSeries[1])
        dir := 1
    else if prevST == prevUpper
        dir := src > upperBand ? -1 : 1
    else
        dir := src < lowerBand ? 1 : -1
    st := dir == -1 ? lowerBand : upperBand
    [st, dir]

// Rolling R/S estimator: range of in-window cumulative deviations divided by stdev
f_rs(float r, int n) =>
    mean_r = ta.sma(r, n)
    s_     = ta.stdev(r, n)
    float runSum = 0.0
    float hi     = -1e20
    float lo     =  1e20
    for i = 0 to n - 1
        runSum += nz(r[i]) - nz(mean_r)
        hi := math.max(hi, runSum)
        lo := math.min(lo, runSum)
    s_ > 0 and bar_index >= n ? (hi - lo) / s_ : na

// Stage direction to short text
f_dirShort(int d) =>
    na(d) ? "flat" : d == -1 ? "bull" : "bear"

// Stage direction to color
f_dirColor(int d) =>
    na(d) ? color.new(chart.fg_color, 40) : d == -1 ? bullColor : bearColor

// Format float to ticker-aware string
f_fmt(float v) =>
    str.tostring(v, format.mintick)

// ════════════════════════════════════════════════════════════════════
// CORE CALCULATIONS
// ════════════════════════════════════════════════════════════════════
confirmedBar = barstate.isconfirmed or barstate.ishistory

// Stage 1 basis: midpoint of N-bar range
basis = math.avg(ta.highest(high, rangeLen), ta.lowest(low, rangeLen))

// KAMA-smoothed ATR (Kaufman Efficiency Ratio adapts smoothing speed)
change_     = math.abs(close - close[erLen])
volatility_ = math.sum(math.abs(close - close[1]), erLen)
ER          = volatility_ != 0 ? change_ / volatility_ : 0.0
SC          = math.pow(ER * (2.0 / 3.0 - 2.0 / 31.0) + 2.0 / 31.0, 2)
atrRaw      = ta.atr(atrPeriod)
var float kamaATR = na
kamaATR := na(kamaATR[1]) ? atrRaw : kamaATR[1] + SC * (atrRaw - kamaATR[1])

// Volume Z-score — gates Stage 2 width
volMean = ta.sma(volume, volZLen)
volStd  = ta.stdev(volume, volZLen)
volZ    = (volume - volMean) / math.max(volStd, 1e-8)

// Hurst exponent via two-point rolling R/S ratio
logRet  = math.log(close / nz(close[1], close))
rsShort = f_rs(logRet, hurstShort)
rsLong  = f_rs(logRet, hurstLong)
float hurstRaw = na
if not na(rsShort) and not na(rsLong) and rsShort > 0 and rsLong > 0
    hurstRaw := math.log(rsLong / rsShort) / math.log(hurstLong / hurstShort)
hurst = na(hurstRaw) ? 0.5 : math.max(0.3, math.min(0.7, hurstRaw))

// Stage 1 — Supertrend on range basis with KAMA-ATR
[st1, dir1] = f_supertrend(stage1Factor, kamaATR, basis)

// Stage 2 — Supertrend on Stage 1, factor scaled by volume regime
volMult = math.max(0.5, math.min(2.5, 1.0 + 0.4 * volZ))
[st2, dir2] = f_supertrend(stage2Factor * volMult, kamaATR, st1)

// Stage 3 — Supertrend on Stage 2, factor scaled by Hurst regime
hurstMult = math.max(0.5, math.min(1.8, 1.0 + 1.0 * (hurst - 0.5)))
[st3, dir3] = f_supertrend(stage3Factor * hurstMult, kamaATR, st2)

// Sentinel pulse: decay counter, set to 3 on Stage 3 flip confirmed by Stage 2 within 3 bars
var int sentinel_pulse = 0
sentinel_pulse := math.max(0, sentinel_pulse - 1)
stage3Flip = not na(dir3[1]) and dir3 != dir3[1]
sentinelFire = false
if stage3Flip
    confirmed2 = dir2 == dir3 or dir2[1] == dir3 or dir2[2] == dir3
    if confirmed2
        sentinel_pulse := 3
        sentinelFire := true

// Bars since last Stage 3 flip
var int barsSinceFlip = 0
barsSinceFlip := not na(dir3[1]) and dir3 != dir3[1] ? 0 : barsSinceFlip + 1

// KAMA-ATR volatility regime: 100-bar percentile of the smoothed ATR
atrPct        = ta.percentrank(kamaATR, 100)
atrSqueeze    = atrPct < 15 and confirmedBar
atrExpansion  = atrPct > 85 and confirmedBar
atrSqueezeFire   = atrSqueeze   and not atrSqueeze[1]
atrExpansionFire = atrExpansion and not atrExpansion[1]

// ════════════════════════════════════════════════════════════════════
// SIGNAL ENGINE
// ════════════════════════════════════════════════════════════════════
bullState = dir3 == -1
bearState = dir3 == 1

longShift  = bullState and not bullState[1] and confirmedBar
shortShift = bearState and not bearState[1] and confirmedBar

// Bounce: Stage 2 retest reclaim, edge-gated so a single bar fires once
bullBounceRaw = bullState and open < st2 and close > st2
bearBounceRaw = bearState and open > st2 and close < st2
bullBounce    = bullBounceRaw and not bullBounceRaw[1] and confirmedBar
bearBounce    = bearBounceRaw and not bearBounceRaw[1] and confirmedBar

// Cascade alignment: all three stage directions agree (high-conviction regime)
cascadeBull = dir1 == -1 and dir2 == -1 and dir3 == -1
cascadeBear = dir1 ==  1 and dir2 ==  1 and dir3 ==  1
bullAlignFire = cascadeBull and not cascadeBull[1] and confirmedBar
bearAlignFire = cascadeBear and not cascadeBear[1] and confirmedBar

// Daily flip counter — resets on each new daily bar
var int flipsToday = 0
isNewDay = ta.change(time("D")) != 0
if isNewDay
    flipsToday := 0
if (longShift or shortShift)
    flipsToday += 1

// ════════════════════════════════════════════════════════════════════
// VISUALS — CORE PLOTS
// ════════════════════════════════════════════════════════════════════
stateColor = bullState ? bullColor : bearColor

// Tri-line cascade stack (Stage 1 thickest, Stage 3 thinnest)
plotStage1 = plot(st1, "Stage 1", color=color.new(stateColor, 40), linewidth=3)
plotStage2 = plot(st2, "Stage 2", color=color.new(stateColor, 50), linewidth=2)
plotStage3 = plot(st3, "Stage 3", color=color.new(stateColor, 60), linewidth=1)

// Cascade ribbon: gradient between selected anchor and Stage 3. Two fills, one per anchor option (Pine v6 forbids dynamic plot refs).
ribbonDistS1 = math.abs(st1 - st3) / math.max(kamaATR, syminfo.mintick)
ribbonDistS2 = math.abs(st2 - st3) / math.max(kamaATR, syminfo.mintick)
ribbonColorS1 = showRibbon and ribbonAnchor == "Stage 1 to 3" ? color.from_gradient(ribbonDistS1, 0.0, 3.0, chart.bg_color, color.new(stateColor, 50)) : na
ribbonColorS2 = showRibbon and ribbonAnchor == "Stage 2 to 3" ? color.from_gradient(ribbonDistS2, 0.0, 3.0, chart.bg_color, color.new(stateColor, 50)) : na
fill(plotStage1, plotStage3, color=ribbonColorS1, title="Cascade Ribbon S1-S3")
fill(plotStage2, plotStage3, color=ribbonColorS2, title="Cascade Ribbon S2-S3")

// Stage 2 confirmation cloud — subtle fill between S2 and S3, tinted by Stage 2 agreement
s2AgreeColor = showS2Cloud and dir2 == dir3 ? color.new(stateColor, 86) : na
fill(plotStage2, plotStage3, color=s2AgreeColor, title="Stage 2 Cloud")

// (D) Stage 3 trend cloud — gradient fill between Stage 3 and a synthetic close-plot.
// Opacity modulates with |close - st3| / kamaATR; stronger trend = more opaque.
plotPrice  = plot(close, "Price Anchor", color=na, display=display.none)
trendAmp   = math.min(3.0, math.abs(close - st3) / math.max(kamaATR, syminfo.mintick))
cloudAlpha = math.max(70, 92 - math.round(trendAmp * 7))
stage3CloudColor = showStage3Cloud ? color.new(stateColor, cloudAlpha) : na
fill(plotStage3, plotPrice, color=stage3CloudColor, title="Stage 3 Trend Cloud")

// Sentinel pulse background — escalating opacity as pulse decays
pulseColor = sentinel_pulse > 0 and showPulse ? color.new(stateColor, 60 + (3 - sentinel_pulse) * 12) : na
bgcolor(pulseColor, title="Sentinel Pulse")

// (C) ATR squeeze / expansion sustained background tint
squeezeBg = atrSqueeze   and showSqueezeBg ? color.new(bearColor, 92) : na
expandBg  = atrExpansion and showSqueezeBg ? color.new(bullColor, 92) : na
bgcolor(squeezeBg, title="ATR Squeeze Zone")
bgcolor(expandBg,  title="ATR Expansion Zone")

// (H) Cascade-alignment zone — different tint from squeeze (neutral mint/red blend)
alignBullBg = cascadeBull and showCascadeBg ? color.new(bullColor, 94) : na
alignBearBg = cascadeBear and showCascadeBg ? color.new(bearColor, 94) : na
bgcolor(alignBullBg, title="Cascade Bull Alignment")
bgcolor(alignBearBg, title="Cascade Bear Alignment")

// Iridescent candle recolor — fades from chart bg to state color by Stage 3 distance
candleDist  = math.abs(close - st3) / math.max(kamaATR, syminfo.mintick)
candleColor = color.from_gradient(candleDist, 0.0, 3.0, chart.bg_color, stateColor)
plotcandle(open, high, low, close, "Cascade Candles",
     color       = showCandles ? candleColor : na,
     wickcolor   = showCandles ? candleColor : na,
     bordercolor = showCandles ? candleColor : na,
     force_overlay = true)

// Bounce markers — quiet dots on Stage 2 retest within active trend
plotchar(bullBounce and showBounce ? low  - kamaATR * 0.2 : na, "Bull Bounce", char=".", location=location.absolute, color=bullColor, size=size.tiny)
plotchar(bearBounce and showBounce ? high + kamaATR * 0.2 : na, "Bear Bounce", char=".", location=location.absolute, color=bearColor, size=size.tiny)

// ════════════════════════════════════════════════════════════════════
// ON-CHART DENSITY LAYER
// ════════════════════════════════════════════════════════════════════

// (A) Right-edge persistent Stage 1/2/3 value labels
var label s1Label = na
var label s2Label = na
var label s3Label = na
if barstate.islast and showStageLabels
    if na(s1Label)
        s1Label := label.new(bar_index + 30, st1, "", style=label.style_label_left, textcolor=color.white, size=size.small)
        s2Label := label.new(bar_index + 30, st2, "", style=label.style_label_left, textcolor=color.white, size=size.small)
        s3Label := label.new(bar_index + 30, st3, "", style=label.style_label_left, textcolor=color.white, size=size.small)
    label.set_xy(s1Label, bar_index + 30, st1)
    label.set_xy(s2Label, bar_index + 30, st2)
    label.set_xy(s3Label, bar_index + 30, st3)
    label.set_text(s1Label, "S1 " + f_fmt(st1) + "  " + f_dirShort(dir1))
    label.set_text(s2Label, "S2 " + f_fmt(st2) + "  " + f_dirShort(dir2))
    label.set_text(s3Label, "S3 " + f_fmt(st3) + "  " + f_dirShort(dir3))
    label.set_color(s1Label, color.new(f_dirColor(dir1), 30))
    label.set_color(s2Label, color.new(f_dirColor(dir2), 30))
    label.set_color(s3Label, color.new(f_dirColor(dir3), 30))

// (B) (E) (J) Flip labels — parallel arrays for label refs + creation-bar + direction + outcome status
var array<label> flipLabels   = array.new<label>()
var array<int>   flipBars     = array.new<int>()
var array<int>   flipDirs     = array.new<int>()
var array<bool>  flipResolved = array.new<bool>()
var array<float> flipPrices   = array.new<float>()
var array<bool>  flipIsSent   = array.new<bool>()

// Resolve outcome of prior flip on each new flip
f_resolveFlips(int newDir) =>
    n = array.size(flipLabels)
    if n > 0
        for i = 0 to n - 1
            isResolved = array.get(flipResolved, i)
            if not isResolved
                createdBar = array.get(flipBars, i)
                createdDir = array.get(flipDirs, i)
                if bar_index - createdBar >= flipPersistBars
                    lbl     = array.get(flipLabels, i)
                    price   = array.get(flipPrices, i)
                    isSent  = array.get(flipIsSent, i)
                    persisted = createdDir == dir3
                    suffix    = persisted ? "  OK" : "  FAIL"
                    prefixCore = createdDir == -1 ? "BULL start " : "BEAR start "
                    prefixSent = createdDir == -1 ? "SENTINEL bull " : "SENTINEL bear "
                    prefix = isSent ? prefixSent : prefixCore
                    label.set_text(lbl, prefix + f_fmt(price) + suffix)
                    array.set(flipResolved, i, true)

f_pushFlip(int dirNow, bool isSent) =>
    yPos     = dirNow == -1 ? low  - kamaATR * 0.6 : high + kamaATR * 0.6
    style    = dirNow == -1 ? label.style_label_up : label.style_label_down
    col      = dirNow == -1 ? bullColor : bearColor
    prefix   = isSent ? (dirNow == -1 ? "SENTINEL bull " : "SENTINEL bear ") : (dirNow == -1 ? "BULL start " : "BEAR start ")
    newLbl = label.new(bar_index, yPos, prefix + f_fmt(close), style=style, color=color.new(col, 25), textcolor=color.white, size=size.small)
    array.push(flipLabels,   newLbl)
    array.push(flipBars,     bar_index)
    array.push(flipDirs,     dirNow)
    array.push(flipResolved, false)
    array.push(flipPrices,   close)
    array.push(flipIsSent,   isSent)
    // FIFO overflow trim — remove from index 0
    while array.size(flipLabels) > maxFlipLabels
        oldLbl = array.shift(flipLabels)
        label.delete(oldLbl)
        array.shift(flipBars)
        array.shift(flipDirs)
        array.shift(flipResolved)
        array.shift(flipPrices)
        array.shift(flipIsSent)

if showFlipLabels and (longShift or shortShift)
    f_resolveFlips(dir3)
    f_pushFlip(dir3, false)

// (J) Sentinel pulse label — separate flag, gated on confirmedBar inside sentinelFire path
if showSentinelLbl and sentinelFire and confirmedBar
    f_resolveFlips(dir3)
    f_pushFlip(dir3, true)

// On every bar, retroactively resolve any unresolved flip whose persistence window has expired
if barstate.isconfirmed
    n_ = array.size(flipLabels)
    if n_ > 0
        for i = 0 to n_ - 1
            isResolved2 = array.get(flipResolved, i)
            if not isResolved2
                createdBar2 = array.get(flipBars, i)
                createdDir2 = array.get(flipDirs, i)
                if bar_index - createdBar2 >= flipPersistBars
                    lbl2     = array.get(flipLabels, i)
                    price2   = array.get(flipPrices, i)
                    isSent2  = array.get(flipIsSent, i)
                    persisted2 = createdDir2 == dir3
                    suffix2    = persisted2 ? "  OK" : "  FAIL"
                    prefixCore2 = createdDir2 == -1 ? "BULL start " : "BEAR start "
                    prefixSent2 = createdDir2 == -1 ? "SENTINEL bull " : "SENTINEL bear "
                    prefix2 = isSent2 ? prefixSent2 : prefixCore2
                    label.set_text(lbl2, prefix2 + f_fmt(price2) + suffix2)
                    array.set(flipResolved, i, true)

// (F) Right-edge sight line — dotted horizontal at Stage 3 level, projecting bar_index-20..bar_index+4
var line sightLine = na
if barstate.islast and showSightLine
    if na(sightLine)
        sightLine := line.new(bar_index - 20, st3, bar_index + 4, st3, xloc=xloc.bar_index, style=line.style_dotted, color=color.new(stateColor, 35), width=1)
    line.set_xy1(sightLine, bar_index - 20, st3)
    line.set_xy2(sightLine, bar_index + 4,  st3)
    line.set_color(sightLine, color.new(stateColor, 35))

// (G) State alignment block — 3 stacked segments at bar_index + 6..10 at Stage 3 level
// Implementation: 3 small persistent lines vertically separated by 0.5 * kamaATR, color-coded per dir1/2/3.
var line blockL1 = na
var line blockL2 = na
var line blockL3 = na
var label stateBlockLbl = na
if barstate.islast and showStateBlock
    step = kamaATR * 0.35
    yTop = st3 + step
    yMid = st3
    yBot = st3 - step
    if na(blockL1)
        blockL1 := line.new(bar_index + 6, yTop, bar_index + 10, yTop, xloc=xloc.bar_index, style=line.style_solid, width=3, color=f_dirColor(dir1))
        blockL2 := line.new(bar_index + 6, yMid, bar_index + 10, yMid, xloc=xloc.bar_index, style=line.style_solid, width=3, color=f_dirColor(dir2))
        blockL3 := line.new(bar_index + 6, yBot, bar_index + 10, yBot, xloc=xloc.bar_index, style=line.style_solid, width=3, color=f_dirColor(dir3))
        stateBlockLbl := label.new(bar_index + 12, st3, "", style=label.style_label_left, textcolor=color.white, size=size.small)
    line.set_xy1(blockL1, bar_index + 6,  yTop)
    line.set_xy2(blockL1, bar_index + 10, yTop)
    line.set_color(blockL1, f_dirColor(dir1))
    line.set_xy1(blockL2, bar_index + 6,  yMid)
    line.set_xy2(blockL2, bar_index + 10, yMid)
    line.set_color(blockL2, f_dirColor(dir2))
    line.set_xy1(blockL3, bar_index + 6,  yBot)
    line.set_xy2(blockL3, bar_index + 10, yBot)
    line.set_color(blockL3, f_dirColor(dir3))
    label.set_xy(stateBlockLbl, bar_index + 12, st3)
    blockText = "STATE  " + f_dirShort(dir1) + " / " + f_dirShort(dir2) + " / " + f_dirShort(dir3)
    label.set_text(stateBlockLbl, blockText)
    label.set_color(stateBlockLbl, color.new(stateColor, 25))

// (I) Right-edge flip counter label
var label flipsCounterLbl = na
if barstate.islast and showFlipsCounter
    // place above stage labels and well clear of state block to avoid collision
    yPosFC = high + kamaATR * 3.5
    if na(flipsCounterLbl)
        flipsCounterLbl := label.new(bar_index + 30, yPosFC, "", style=label.style_label_left, textcolor=color.white, size=size.small)
    label.set_xy(flipsCounterLbl, bar_index + 30, yPosFC)
    label.set_text(flipsCounterLbl, "Flips today: " + str.tostring(flipsToday))
    label.set_color(flipsCounterLbl, color.new(stateColor, 40))

// ────────────────────────────────────────────────────────────────────
// Flip vertical anchors — dotted vlines at each Stage 3 flip bar.
// Parallel array, FIFO trimmed to maxFlipLabels to keep visual budget aligned.
// ────────────────────────────────────────────────────────────────────
var array<line> flipVlines = array.new<line>()
if showFlipVlines and (longShift or shortShift) and confirmedBar
    vCol  = dir3 == -1 ? bullColor : bearColor
    yLo   = low  - kamaATR * 1.5
    yHi   = high + kamaATR * 1.5
    newV  = line.new(bar_index, yLo, bar_index, yHi, xloc=xloc.bar_index, extend=extend.none, style=line.style_dotted, color=color.new(vCol, 60), width=1)
    array.push(flipVlines, newV)
    while array.size(flipVlines) > maxFlipLabels
        oldV = array.shift(flipVlines)
        line.delete(oldV)

// ────────────────────────────────────────────────────────────────────
// ATR percentile gauge — 5 stacked dots / micro-segments at right edge.
// Visualizes where the current kamaATR sits in its 100-bar percentile.
// Lit segments scale with atrPct (0..100 mapped to 0..5 lit).
// ────────────────────────────────────────────────────────────────────
var line atrGaugeSeg1 = na
var line atrGaugeSeg2 = na
var line atrGaugeSeg3 = na
var line atrGaugeSeg4 = na
var line atrGaugeSeg5 = na
var label atrGaugeLbl = na
f_segColor(int idx, float pct) =>
    threshold = idx * 20.0
    isLit     = pct >= threshold
    if not isLit
        color.new(chart.fg_color, 75)
    else
        // gradient: low maps to bear, high maps to bull
        if pct < 30
            color.new(bearColor, 30)
        else if pct > 70
            color.new(bullColor, 30)
        else
            color.new(chart.fg_color, 30)
if barstate.islast and showAtrGauge
    pct     = nz(atrPct, 0.0)
    yBase   = low - kamaATR * 1.8
    stepG   = kamaATR * 0.18
    x1g     = bar_index + 14
    x2g     = bar_index + 18
    if na(atrGaugeSeg1)
        atrGaugeSeg1 := line.new(x1g, yBase + stepG * 0, x2g, yBase + stepG * 0, xloc=xloc.bar_index, style=line.style_solid, width=4, color=f_segColor(1, pct))
        atrGaugeSeg2 := line.new(x1g, yBase + stepG * 1, x2g, yBase + stepG * 1, xloc=xloc.bar_index, style=line.style_solid, width=4, color=f_segColor(2, pct))
        atrGaugeSeg3 := line.new(x1g, yBase + stepG * 2, x2g, yBase + stepG * 2, xloc=xloc.bar_index, style=line.style_solid, width=4, color=f_segColor(3, pct))
        atrGaugeSeg4 := line.new(x1g, yBase + stepG * 3, x2g, yBase + stepG * 3, xloc=xloc.bar_index, style=line.style_solid, width=4, color=f_segColor(4, pct))
        atrGaugeSeg5 := line.new(x1g, yBase + stepG * 4, x2g, yBase + stepG * 4, xloc=xloc.bar_index, style=line.style_solid, width=4, color=f_segColor(5, pct))
        atrGaugeLbl  := label.new(bar_index + 20, yBase + stepG * 2, "", style=label.style_label_left, textcolor=color.white, size=size.small)
    line.set_xy1(atrGaugeSeg1, x1g, yBase + stepG * 0)
    line.set_xy2(atrGaugeSeg1, x2g, yBase + stepG * 0)
    line.set_color(atrGaugeSeg1, f_segColor(1, pct))
    line.set_xy1(atrGaugeSeg2, x1g, yBase + stepG * 1)
    line.set_xy2(atrGaugeSeg2, x2g, yBase + stepG * 1)
    line.set_color(atrGaugeSeg2, f_segColor(2, pct))
    line.set_xy1(atrGaugeSeg3, x1g, yBase + stepG * 2)
    line.set_xy2(atrGaugeSeg3, x2g, yBase + stepG * 2)
    line.set_color(atrGaugeSeg3, f_segColor(3, pct))
    line.set_xy1(atrGaugeSeg4, x1g, yBase + stepG * 3)
    line.set_xy2(atrGaugeSeg4, x2g, yBase + stepG * 3)
    line.set_color(atrGaugeSeg4, f_segColor(4, pct))
    line.set_xy1(atrGaugeSeg5, x1g, yBase + stepG * 4)
    line.set_xy2(atrGaugeSeg5, x2g, yBase + stepG * 4)
    line.set_color(atrGaugeSeg5, f_segColor(5, pct))
    label.set_xy(atrGaugeLbl, bar_index + 20, yBase + stepG * 2)
    regimeTxt = atrSqueeze ? "squeeze" : atrExpansion ? "expand" : "normal"
    label.set_text(atrGaugeLbl, "ATR " + str.tostring(pct, "#") + "  " + regimeTxt)
    label.set_color(atrGaugeLbl, color.new(stateColor, 45))

// ────────────────────────────────────────────────────────────────────
// Stage Spread telemetry — ATR-normalized |st1 - st3| (cascade fan width).
// Positioned at the right edge above the Stage 1 label to avoid collision.
// ────────────────────────────────────────────────────────────────────
var label spreadLbl = na
if barstate.islast and showStageSpread
    yPosSp = high + kamaATR * 2.3
    if na(spreadLbl)
        spreadLbl := label.new(bar_index + 30, yPosSp, "", style=label.style_label_left, textcolor=color.white, size=size.small)
    label.set_xy(spreadLbl, bar_index + 30, yPosSp)
    spreadAtr = math.abs(st1 - st3) / math.max(kamaATR, syminfo.mintick)
    label.set_text(spreadLbl, "Spread " + str.tostring(spreadAtr, "0.00") + " ATR")
    label.set_color(spreadLbl, color.new(stateColor, 50))

// ────────────────────────────────────────────────────────────────────
// Hurst regime gauge — single colored segment at right edge encoding regime.
// Below the Stage 3 label to avoid stacking collision with state block.
// ────────────────────────────────────────────────────────────────────
var line hurstSeg = na
var label hurstLbl = na
if barstate.islast and showHurstGauge
    yPosH = low - kamaATR * 0.8
    hCol  = hurst > 0.55 ? bullColor : hurst < 0.45 ? bearColor : color.new(chart.fg_color, 30)
    hTxt  = hurst > 0.55 ? "trending" : hurst < 0.45 ? "mean-rev" : "neutral"
    if na(hurstSeg)
        hurstSeg := line.new(bar_index + 14, yPosH, bar_index + 22, yPosH, xloc=xloc.bar_index, style=line.style_solid, width=5, color=hCol)
        hurstLbl := label.new(bar_index + 24, yPosH, "", style=label.style_label_left, textcolor=color.white, size=size.small)
    line.set_xy1(hurstSeg, bar_index + 14, yPosH)
    line.set_xy2(hurstSeg, bar_index + 22, yPosH)
    line.set_color(hurstSeg, hCol)
    label.set_xy(hurstLbl, bar_index + 24, yPosH)
    label.set_text(hurstLbl, "H " + str.tostring(hurst, "0.00") + "  " + hTxt)
    label.set_color(hurstLbl, color.new(hCol, 40))

// ════════════════════════════════════════════════════════════════════
// DASHBOARD
// ════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 9,
     bgcolor      = #111118,
     border_color = #252535,
     border_width = 1,
     frame_color  = #252535,
     frame_width  = 1)

f_stageText(int d) =>
    na(d) ? "—" : d == -1 ? "Bull" : "Bear"

f_stageBg(int d) =>
    na(d) ? color.new(chart.fg_color, 80) : color.new(d == -1 ? bullColor : bearColor, 70)

f_volRegime(float z) =>
    z >  1.5  ? "HIGH" : z >  0.5  ? "MID"  : z < -0.5 ? "LOW" : "MID"

f_volRegimeBg(float z) =>
    z >  1.5  ? color.new(bullColor, 60) : z < -0.5 ? color.new(bearColor, 60) : color.new(chart.fg_color, 80)

f_hurstRegime(float h) =>
    h > 0.55 ? "TRENDING" : h < 0.45 ? "MEAN-REV" : "NEUTRAL"

f_hurstBg(float h) =>
    h > 0.55 ? color.new(bullColor, 60) : h < 0.45 ? color.new(bearColor, 60) : color.new(chart.fg_color, 80)

f_squeezeText(bool sq, bool ex) =>
    sq ? "SQUEEZE" : ex ? "EXPAND" : "NORMAL"

f_squeezeBg(bool sq, bool ex) =>
    sq ? color.new(bearColor, 60) : ex ? color.new(bullColor, 60) : color.new(chart.fg_color, 80)

if barstate.islast and showDash
    dash := table.new(posFromString(dashPos), 2, 9,
         bgcolor      = #111118,
         border_color = #252535,
         border_width = 1,
         frame_color  = #252535,
         frame_width  = 1)
    txtSize = sizeFromString(dashSize)

    headerBg = color.new(stateColor, 30)
    table.cell(dash, 0, 0, "Sentinel Cascade [JOAT]", text_color=color.white, bgcolor=headerBg, text_size=txtSize, text_halign=text.align_center)
    table.cell(dash, 1, 0, "",                         text_color=color.white, bgcolor=headerBg, text_size=txtSize, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 1, 0)

    table.cell(dash, 0, 1, "Stage 1",         text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 1, f_stageText(dir1), text_color=color.white,    bgcolor=f_stageBg(dir1), text_size=txtSize, text_halign=text.align_center)

    table.cell(dash, 0, 2, "Stage 2",         text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 2, f_stageText(dir2), text_color=color.white,    bgcolor=f_stageBg(dir2), text_size=txtSize, text_halign=text.align_center)

    table.cell(dash, 0, 3, "Stage 3",         text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 3, f_stageText(dir3), text_color=color.white,    bgcolor=f_stageBg(dir3), text_size=txtSize, text_halign=text.align_center)

    table.cell(dash, 0, 4, "Vol Regime",      text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 4, f_volRegime(volZ), text_color=color.white,    bgcolor=f_volRegimeBg(volZ), text_size=txtSize, text_halign=text.align_center)

    table.cell(dash, 0, 5, "Hurst",             text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 5, f_hurstRegime(hurst),text_color=color.white,   bgcolor=f_hurstBg(hurst), text_size=txtSize, text_halign=text.align_center)

    table.cell(dash, 0, 6, "ATR Regime",      text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 6, f_squeezeText(atrSqueeze, atrExpansion), text_color=color.white, bgcolor=f_squeezeBg(atrSqueeze, atrExpansion), text_size=txtSize, text_halign=text.align_center)

    table.cell(dash, 0, 7, "Bars Since Flip",          text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(barsSinceFlip),text_color=color.white,   bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_center)

    table.cell(dash, 0, 8, "@JackOfAllTrades", text_color=color.new(#9090b0, 60), bgcolor=#111118, text_size=txtSize, text_halign=text.align_center)
    table.cell(dash, 1, 8, "",                 text_color=color.new(#9090b0, 60), bgcolor=#111118, text_size=txtSize, text_halign=text.align_center)
    table.merge_cells(dash, 0, 8, 1, 8)

// ════════════════════════════════════════════════════════════════════
// ALERTS
// ════════════════════════════════════════════════════════════════════
alertcondition(longShift,        title="SCD Bull Shift",    message="Sentinel Cascade [JOAT] — Bull cascade shift")
alertcondition(shortShift,       title="SCD Bear Shift",    message="Sentinel Cascade [JOAT] — Bear cascade shift")
alertcondition(bullBounce,       title="SCD Bull Bounce",   message="Sentinel Cascade [JOAT] — Bull bounce confirmed")
alertcondition(bearBounce,       title="SCD Bear Bounce",   message="Sentinel Cascade [JOAT] — Bear bounce confirmed")
alertcondition(bullAlignFire,    title="SCD Bull Aligned",  message="Sentinel Cascade [JOAT] — All stages aligned bullish")
alertcondition(bearAlignFire,    title="SCD Bear Aligned",  message="Sentinel Cascade [JOAT] — All stages aligned bearish")
alertcondition(atrSqueezeFire,   title="SCD ATR Squeeze",   message="Sentinel Cascade [JOAT] — KAMA-ATR squeeze")
alertcondition(atrExpansionFire, title="SCD ATR Expansion", message="Sentinel Cascade [JOAT] — KAMA-ATR expansion")
````
