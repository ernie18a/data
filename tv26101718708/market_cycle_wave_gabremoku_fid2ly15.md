# Market Cycle Wave [Gabremoku]

- url: https://www.tradingview.com/script/fid2ly15-Market-Cycle-Wave-Gabremoku/
- type: indicator
- pine_id: PUB;d7a8a12b3fe7431e826ebb535fa49c9f
- version: 1.0

## Description

[b]Market Cycle Wave[/b] is a price-based cycle indicator built to map broad market phases into a readable oscillator and a price-anchored overlay.

Instead of relying on a single signal, the script combines trend, momentum, volatility, and range-position data into a composite cycle score. That score is normalized and smoothed to create an intermediate Cycle Wave, while a slower Secular line provides broader context.

The script has two main views:
- an oscillator pane with the score histogram, Cycle Wave, Secular baseline, and major Cycle Peak / Cycle Trough labels.
- a price overlay with a cycle line, gradient aura, and a thinner secular context line.

The regime model classifies market conditions into Debt Accumulation, Deleveraging, Reflation, and Transition. The goal is not to generate standalone buy/sell signals, but to help traders read where price may sit inside a broader market cycle structure.

[b]How to use it[/b]

This indicator works best on broad indices and diversified equity ETFs, where cycle behavior is usually cleaner than on highly erratic single names.

Typical use:
- Daily chart: monitor intermediate cycle shifts
- Weekly chart: study broader regime transitions

Practical reading:
- A rising blue cycle wave can suggest constructive expansion conditions
- A yellow rollover after a mature advance can suggest a weakening cycle structure
- Deep negative readings followed by green recovery can suggest reflation or post-stress repair
- The secular line helps show whether the shorter cycle is moving with or against the broader backdrop

The dashboard summarizes the current regime, state, direction, score, risk posture, and color legend directly on the chart.

How it works

The cycle model uses eight price-based factors:
- Fast EMA vs slow EMA relationship
- Fast EMA slope
- RSI momentum regime
- RSI extremes
- Position inside the rolling yearly range
- Distance from yearly extremes
- ATR volatility regime
- Price position vs the slow EMA

Each factor contributes to a composite score. That score is then normalized, smoothed, and accumulated over a rolling memory window to build a bounded cycle wave around a midpoint.

A second and slower baseline is built through longer smoothing to represent secular context. This creates two distinct layers:
- Cycle Wave: the intermediate cycle, more reactive to market swings
- Secular Baseline: the broader context, slower and less sensitive

Recent Cycle Peak and Cycle Trough labels are pivot-based, so the latest labels need confirmation from future bars.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Gabremoku

//@version=6
// Market Cycle Wave [Gabremoku]
//
// What this script does:
// - Builds a market-cycle model from price-based proxies inspired by classical cycle frameworks.
// - Converts trend, momentum, volatility and range-position data into a composite score.
// - Transforms that score into a smooth cyclical wave for a dedicated oscillator pane.
// - Projects the cycle wave onto the main price chart through a price-anchored overlay line.
// - Uses multi-layer gradient aura bands to visualize cycle magnitude around the overlay line.
// - Adds a secular overlay line on the main chart using a separate, slower price basis,
//   so it moves independently from the intermediate cycle line.
// - Uses a compact force-overlay dashboard instead of multiple chart labels.
//
// How it works:
// 1) A composite score is built from eight price-based factors.
// 2) The score is normalized, smoothed and accumulated over a rolling memory window.
// 3) The accumulated series is normalized into a bounded cycle oscillator (-1 to +1).
// 4) A secular baseline is derived from a longer EMA of the score and then extra-smoothed.
// 5) The cycle wave uses EMA(close, overlayBasisLen) as its price anchor.
//    The secular line uses EMA(close, secularBasisLen) — a much slower basis — as its
//    price anchor, ensuring the two lines diverge meaningfully over time.
//
// Intended use:
// - Best suited for broad equity indices and diversified equity ETFs (e.g. SPX, ACWI, VT).
// - Daily profile highlights intermediate cycle changes.
// - Weekly profile highlights broader regime transitions.

indicator("Market Cycle Wave [Gabremoku]", overlay=false, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════

grp0 = "⚙️ Core"
profileInput      = input.string("Daily", "Profile", options=["Daily", "Weekly", "Custom"], group=grp0)
emaFastLenInput   = input.int(50,  "Fast EMA Length", minval=10, group=grp0)
emaSlowLenInput   = input.int(200, "Slow EMA Length", minval=50, group=grp0)
rsiLenInput       = input.int(14,  "RSI Length", minval=5, group=grp0)
atrLenInput       = input.int(14,  "ATR Length", minval=5, group=grp0)
atrAvgLenInput    = input.int(100, "ATR Average Lookback", minval=20, group=grp0)
yearBarsInput     = input.int(252, "Bars in One Year", minval=12, group=grp0)
waveSmoothInput   = input.int(21,  "Cycle Wave Smoothing", minval=3, group=grp0)
cumLookbackInput  = input.int(160, "Cycle Memory Window", minval=30, group=grp0)
secularLenInput   = input.int(200, "Secular Score Length", minval=50, group=grp0)

grp1 = "🎨 Colors"
bullColor         = input.color(color.rgb(33, 150, 243),  "Accumulation Color", group=grp1)
bearColor         = input.color(color.rgb(241, 255, 48),  "Deleveraging Color", group=grp1)
reflColor         = input.color(color.rgb(0, 200, 140),   "Reflation Color", group=grp1)
neutralColor      = input.color(color.gray, "Neutral Color", group=grp1)

grp2 = "📊 Oscillator"
showHistogram     = input.bool(true,  "Show Score Histogram", group=grp2)
showWaveFill      = input.bool(true,  "Show Cycle Wave Fill", group=grp2)
showSecular       = input.bool(true,  "Show Secular Baseline", group=grp2)
showPivotLabels   = input.bool(true,  "Show Cycle Peak/Trough Labels", group=grp2)
pivotStrength     = input.int(6, "Pivot Strength", minval=2, maxval=20, group=grp2)

grp3 = "🫧 Price Overlay Cycle"
showPriceOverlay  = input.bool(true,  "Show Price Overlay Cycle", group=grp3)
overlayBasisLen   = input.int(55,  "Overlay Basis EMA (Cycle)", minval=5, group=grp3,
     tooltip="Price anchor for the intermediate cycle line. Keep shorter (40-80) for daily.")
overlayAtrLen     = input.int(21,  "Overlay ATR Length", minval=5, group=grp3)
overlayAtrSmooth  = input.int(8,   "Overlay ATR Smoothing", minval=1, group=grp3)
overlayMult       = input.float(1.35, "Cycle Amplitude Multiplier", minval=0.1, step=0.05, group=grp3)
showOverlayBasis  = input.bool(false, "Show Overlay Basis", group=grp3)
showOverlayLabel  = input.bool(true,  "Show Cycle Last Value Label", group=grp3)

grp4 = "🌈 Aura"
showAura          = input.bool(true, "Show Gradient Aura", group=grp4)
auraBaseMult      = input.float(0.55, "Aura Base Thickness", minval=0.1, step=0.05, group=grp4)
auraMiddleMult    = input.float(1.05, "Aura Middle Thickness", minval=0.1, step=0.05, group=grp4)
auraOuterMult     = input.float(1.45, "Aura Outer Thickness", minval=0.1, step=0.05, group=grp4)

grp7 = "🌐 Secular Overlay"
showSecularOverlay      = input.bool(true,  "Show Secular Overlay Line", group=grp7)
secularBasisLenInput    = input.int(300, "Secular Basis EMA (Price Anchor)", minval=50, group=grp7,
     tooltip="Separate, slower EMA of close used as price anchor for the secular line. Set higher than the cycle basis to ensure the two lines move independently.")
secularExtraSmooth      = input.int(55,  "Secular Extra Smoothing", minval=5, group=grp7,
     tooltip="Additional EMA smoothing applied to the secular oscillator value before projecting onto price. Higher values = slower, flatter secular line.")
secularOverlayMult      = input.float(0.65, "Secular Amplitude Multiplier", minval=0.1, step=0.05, group=grp7,
     tooltip="Controls secular line vertical range relative to price ATR. Lower than Cycle Amplitude to keep it subdued.")
showSecularOverlayLabel = input.bool(true,  "Show Secular Last Value Label", group=grp7)

grp5 = "🪧 Pane Dashboard"
showDashboard     = input.bool(false, "Show Pane Dashboard", group=grp5)
dashPosInput      = input.string("Bottom Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grp5)
dashTextSizeInput = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal"], group=grp5)

grp6 = "📌 Overlay Dashboard"
showOverlayDash          = input.bool(true,  "Show Overlay Dashboard", group=grp6)
overlayDashPosInput      = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grp6)
overlayDashTextSizeInput = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal"], group=grp6)

// ═══════════════════════════════════════════════════════════════
// PROFILE PRESETS
// ═══════════════════════════════════════════════════════════════

emaFastLen  = profileInput == "Daily"  ? 50  : profileInput == "Weekly" ? 20  : emaFastLenInput
emaSlowLen  = profileInput == "Daily"  ? 200 : profileInput == "Weekly" ? 65  : emaSlowLenInput
rsiLen      = profileInput == "Daily"  ? 14  : profileInput == "Weekly" ? 10  : rsiLenInput
atrLen      = profileInput == "Daily"  ? 14  : profileInput == "Weekly" ? 10  : atrLenInput
atrAvgLen   = profileInput == "Daily"  ? 100 : profileInput == "Weekly" ? 52  : atrAvgLenInput
yearBars    = profileInput == "Daily"  ? 252 : profileInput == "Weekly" ? 52  : yearBarsInput
waveSmooth  = profileInput == "Daily"  ? 21  : profileInput == "Weekly" ? 13  : waveSmoothInput
cumLookback = profileInput == "Daily"  ? 160 : profileInput == "Weekly" ? 90  : cumLookbackInput
secularLen  = profileInput == "Daily"  ? 200 : profileInput == "Weekly" ? 104 : secularLenInput
secularBasisLen = profileInput == "Custom" ? secularBasisLenInput :
                  profileInput == "Weekly" ? 150 : 300

dashTextSize = dashTextSizeInput == "Tiny" ? size.tiny : dashTextSizeInput == "Normal" ? size.normal : size.small
dashPos      = dashPosInput == "Top Right"   ? position.top_right   :
               dashPosInput == "Top Left"    ? position.top_left    :
               dashPosInput == "Bottom Left" ? position.bottom_left : position.bottom_right

overlayDashTextSize = overlayDashTextSizeInput == "Tiny" ? size.tiny : overlayDashTextSizeInput == "Normal" ? size.normal : size.small
overlayDashPos      = overlayDashPosInput == "Top Left"    ? position.top_left    :
                      overlayDashPosInput == "Bottom Right" ? position.bottom_right :
                      overlayDashPosInput == "Bottom Left"  ? position.bottom_left  : position.top_right

// ═══════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════

clamp(_x, _mn, _mx) => math.max(_mn, math.min(_mx, _x))
normalize(_x, _lo, _hi) => _hi != _lo ? (_x - _lo) / (_hi - _lo) : 0.5
arrow(_x, _prev, _thr) => _x - _prev > _thr ? "▲" : _x - _prev < -_thr ? "▼" : "•"

// ═══════════════════════════════════════════════════════════════
// CORE METRICS
// ═══════════════════════════════════════════════════════════════

emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
rsiVal  = ta.rsi(close, rsiLen)
atrVal  = ta.atr(atrLen)
atrAvg  = ta.sma(atrVal, atrAvgLen)
atrPct  = atrAvg != 0 ? atrVal / atrAvg : 1.0

highY    = ta.highest(high, yearBars)
lowY     = ta.lowest(low, yearBars)
rangeY   = highY - lowY
pricePos = rangeY != 0 ? (close - lowY) / rangeY : 0.5

emaSlopeRaw = emaFast - emaFast[5]
emaSlope    = ta.ema(emaSlopeRaw, 3)

// ═══════════════════════════════════════════════════════════════
// COMPOSITE SCORE
// ═══════════════════════════════════════════════════════════════

f1 = emaFast > emaSlow ? 1 : emaFast < emaSlow ? -1 : 0
f2 = emaSlope > 0 ? 1 : emaSlope < 0 ? -1 : 0
f3 = rsiVal > 60 ? 1 : rsiVal < 40 ? -1 : 0
f4 = rsiVal > 70 ? 1 : rsiVal < 30 ? -1 : 0
f5 = pricePos > 0.65 ? 1 : pricePos < 0.35 ? -1 : 0
f6 = pricePos > 0.90 ? 1 : pricePos < 0.10 ? -1 : 0
f7 = atrPct < 0.85 ? 1 : atrPct > 1.40 ? -1 : 0
f8 = close > emaSlow ? 1 : close < emaSlow ? -1 : 0

totalScore = f1 + f2 + f3 + f4 + f5 + f6 + f7 + f8
scoreNorm  = totalScore / 8.0
scoreBias  = ta.ema(scoreNorm, waveSmooth)

// ═══════════════════════════════════════════════════════════════
// CYCLE WAVE
// ═══════════════════════════════════════════════════════════════

rawWave  = math.sum(scoreBias, cumLookback)
waveMin  = ta.lowest(rawWave, cumLookback)
waveMax  = ta.highest(rawWave, cumLookback)
wave01   = normalize(rawWave, waveMin, waveMax)

cycleWave   = (wave01 * 2.0) - 1.0
cycleWaveSm = ta.ema(cycleWave, waveSmooth)
waveSlope   = cycleWaveSm - cycleWaveSm[1]

// ═══════════════════════════════════════════════════════════════
// SECULAR BASELINE
// The secular oscillator is derived from a much longer EMA of the score,
// then normalized and additionally smoothed by `secularExtraSmooth`.
// This double-smoothing ensures the secular line moves at a clearly
// different speed from cycleWaveSm.
// ═══════════════════════════════════════════════════════════════

secularRaw     = ta.ema(scoreNorm, secularLen)
secularMin     = ta.lowest(secularRaw, secularLen)
secularMax     = ta.highest(secularRaw, secularLen)
secular01      = normalize(secularRaw, secularMin, secularMax)
secularOsc     = ((secular01 * 2.0) - 1.0) * 0.65
secularLine    = ta.ema(secularOsc, secularExtraSmooth)   // <-- extra smoothing
secularSlope   = secularLine - secularLine[3]

// ═══════════════════════════════════════════════════════════════
// REGIME CLASSIFICATION
// ═══════════════════════════════════════════════════════════════

isDebtAccumulation = cycleWaveSm >= 0 and waveSlope >= 0
isDeleveraging     = (cycleWaveSm > -0.25 and waveSlope < 0) or (cycleWaveSm < 0 and waveSlope < 0)
isReflation        = cycleWaveSm < 0 and waveSlope > 0
isTransition       = not isDebtAccumulation and not isDeleveraging and not isReflation

regime      = isDebtAccumulation ? "Debt Accumulation" : isDeleveraging ? "Deleveraging" : isReflation ? "Reflation" : "Transition"
regimeColor = isDebtAccumulation ? bullColor : isDeleveraging ? bearColor : isReflation ? reflColor : neutralColor

// Secular regime uses only its own slope and level — fully independent.
isSecularBull  = secularLine > 0 and secularSlope >= 0
isSecularBear  = secularLine < 0 or (secularLine < 0.15 and secularSlope < 0)
secularRegime  = isSecularBull ? "Secular Bull" : isSecularBear ? "Secular Bear" : "Secular Neutral"
secularRegClr  = isSecularBull ? color.new(bullColor, 0) : isSecularBear ? color.new(bearColor, 0) : color.new(neutralColor, 0)

direction    = waveSlope > 0 ? "Rising" : waveSlope < 0 ? "Falling" : "Flat"
riskPosture  = isDebtAccumulation and cycleWaveSm > 0.65 ? "Late-Cycle Caution" :
               isDebtAccumulation ? "Constructive Risk-On" :
               isDeleveraging and cycleWaveSm < -0.5 ? "Defensive / Stress" :
               isDeleveraging ? "Reduce Risk" :
               isReflation ? "Recovery / Selective Add" : "Neutral / Wait"

state = cycleWaveSm > 0.75 ? "Peak Zone" : cycleWaveSm > 0.25 ? "Upper Cycle" : cycleWaveSm > -0.25 ? "Middle Cycle" :  cycleWaveSm > -0.75 ? "Lower Cycle" : "Trough Zone"

// ═══════════════════════════════════════════════════════════════
// COLORS
// ═══════════════════════════════════════════════════════════════

waveColor =
     isDebtAccumulation ? color.from_gradient(clamp(cycleWaveSm, 0.0, 1.0), 0.0, 1.0, color.new(bullColor, 25), bullColor)
     : isDeleveraging   ? color.from_gradient(clamp(math.abs(cycleWaveSm), 0.0, 1.0), 0.0, 1.0, color.new(bearColor, 25), bearColor)
     : isReflation      ? color.from_gradient(clamp(math.abs(cycleWaveSm), 0.0, 1.0), 0.0, 1.0, color.new(reflColor, 25), reflColor)
     : color.new(neutralColor, 10)

histColor =
     totalScore > 0 ? color.from_gradient(totalScore, 0, 8, color.new(bullColor, 82), color.new(bullColor, 20))
     : totalScore < 0 ? color.from_gradient(math.abs(totalScore), 0, 8, color.new(bearColor, 82), color.new(bearColor, 20))
     : color.new(neutralColor, 80)

overlayLineColor =
     isDebtAccumulation ? color.from_gradient(clamp(cycleWaveSm, 0.0, 1.0), 0.0, 1.0, color.new(bullColor, 30), bullColor)
     : isDeleveraging   ? color.from_gradient(clamp(math.abs(cycleWaveSm), 0.0, 1.0), 0.0, 1.0, color.new(bearColor, 30), bearColor)
     : isReflation      ? color.from_gradient(clamp(math.abs(cycleWaveSm), 0.0, 1.0), 0.0, 1.0, color.new(reflColor, 30), reflColor)
     : color.new(neutralColor, 10)

// Secular line: fixed semi-transparent white/gray regardless of cycle regime.
// This is the key fix — the secular color is ALWAYS neutral/white so it
// never visually "merges" with the cycle line color.
secularLineColor = color.new(color.white, 45)

// ═══════════════════════════════════════════════════════════════
// OSCILLATOR PLOTS
// ═══════════════════════════════════════════════════════════════

bgcolor(isDebtAccumulation ? color.new(bullColor, 95) : na, title="DA Background")
bgcolor(isDeleveraging     ? color.new(bearColor, 94) : na, title="DL Background")
bgcolor(isReflation        ? color.new(reflColor, 95) : na, title="RF Background")

hline(0.0,   "Midline",    color=color.new(chart.fg_color, 70))
hline(0.75,  "Peak Zone",  color=color.new(bullColor, 75), linestyle=hline.style_dotted)
hline(-0.75, "Trough Zone",color=color.new(reflColor, 75), linestyle=hline.style_dotted)

plot(showHistogram ? (totalScore / 8.0) : na, "Score Histogram", style=plot.style_histogram, color=histColor, linewidth=2)

wavePlot = plot(cycleWaveSm, "Cycle Wave", color=waveColor, linewidth=4)
zeroPlot = plot(0, "Zero Ref", color=color.new(color.black, 100))
fill(wavePlot, zeroPlot, color=showWaveFill ? color.new(regimeColor, 88) : na)

plot(showSecular ? secularLine : na, "Secular Baseline", color=color.new(chart.fg_color, 35), linewidth=2)

// ═══════════════════════════════════════════════════════════════
// PIVOT LABELS — only major peaks (>0.65) and troughs (<-0.65)
// ═══════════════════════════════════════════════════════════════

ph = ta.pivothigh(cycleWaveSm, pivotStrength, pivotStrength)
pl = ta.pivotlow(cycleWaveSm, pivotStrength, pivotStrength)

if showPivotLabels and not na(ph) and ph > 0.65
    label.new(bar_index - pivotStrength, ph, "Cycle Peak",
         style=label.style_label_down, color=color.new(bearColor, 0),
         textcolor=color.black, size=size.small)

if showPivotLabels and not na(pl) and pl < -0.65
    label.new(bar_index - pivotStrength, pl, "Cycle Trough",
         style=label.style_label_up, color=color.new(reflColor, 0),
         textcolor=color.white, size=size.small)

// ═══════════════════════════════════════════════════════════════
// SHARED OVERLAY ATR (used by both lines)
// ═══════════════════════════════════════════════════════════════

overlayAtr = ta.ema(ta.atr(overlayAtrLen), overlayAtrSmooth)

// ═══════════════════════════════════════════════════════════════
// CYCLE OVERLAY LINE + AURA
// Uses EMA(close, overlayBasisLen) as price anchor — responsive, intermediate.
// ═══════════════════════════════════════════════════════════════

cycleBasis     = ta.ema(close, overlayBasisLen)
overlayAmp     = overlayAtr * overlayMult
priceCycleLine = cycleBasis + (cycleWaveSm * overlayAmp)

waveMagnitude  = math.abs(cycleWaveSm)
auraBase       = overlayAtr * auraBaseMult   * (0.25 + waveMagnitude)
auraMiddle     = overlayAtr * auraMiddleMult * (0.25 + waveMagnitude)
auraOuter      = overlayAtr * auraOuterMult  * (0.25 + waveMagnitude)

upperAura1 = priceCycleLine + auraBase
lowerAura1 = priceCycleLine - auraBase
upperAura2 = priceCycleLine + auraMiddle
lowerAura2 = priceCycleLine - auraMiddle
upperAura3 = priceCycleLine + auraOuter
lowerAura3 = priceCycleLine - auraOuter

auraColor1 = isDebtAccumulation ? color.new(bullColor, 82) : isDeleveraging ? color.new(bearColor, 82) : isReflation ? color.new(reflColor, 82) : color.new(neutralColor, 88)
auraColor2 = isDebtAccumulation ? color.new(bullColor, 88) : isDeleveraging ? color.new(bearColor, 88) : isReflation ? color.new(reflColor, 88) : color.new(neutralColor, 92)
auraColor3 = isDebtAccumulation ? color.new(bullColor, 93) : isDeleveraging ? color.new(bearColor, 93) : isReflation ? color.new(reflColor, 93) : color.new(neutralColor, 95)

plot(showPriceOverlay and showOverlayBasis ? cycleBasis : na, "Cycle Basis", color=color.new(chart.fg_color, 72), linewidth=1, force_overlay=true)

ua1p = plot(showPriceOverlay and showAura ? upperAura1 : na, "Aura U1", color=color.new(overlayLineColor, 100), linewidth=1, force_overlay=true)
la1p = plot(showPriceOverlay and showAura ? lowerAura1 : na, "Aura L1", color=color.new(overlayLineColor, 100), linewidth=1, force_overlay=true)
ua2p = plot(showPriceOverlay and showAura ? upperAura2 : na, "Aura U2", color=color.new(overlayLineColor, 100), linewidth=1, force_overlay=true)
la2p = plot(showPriceOverlay and showAura ? lowerAura2 : na, "Aura L2", color=color.new(overlayLineColor, 100), linewidth=1, force_overlay=true)
ua3p = plot(showPriceOverlay and showAura ? upperAura3 : na, "Aura U3", color=color.new(overlayLineColor, 100), linewidth=1, force_overlay=true)
la3p = plot(showPriceOverlay and showAura ? lowerAura3 : na, "Aura L3", color=color.new(overlayLineColor, 100), linewidth=1, force_overlay=true)

fill(ua3p, la3p, color=showPriceOverlay and showAura ? auraColor3 : na, title="Outer Aura")
fill(ua2p, la2p, color=showPriceOverlay and showAura ? auraColor2 : na, title="Middle Aura")
fill(ua1p, la1p, color=showPriceOverlay and showAura ? auraColor1 : na, title="Inner Aura")

plot(showPriceOverlay ? priceCycleLine : na, "Price-Anchored Cycle", color=overlayLineColor, linewidth=3, force_overlay=true)

// Cycle label: on the right edge, offset slightly up to avoid secular label.
var label cycleLabel = na
if barstate.islast and showPriceOverlay and showOverlayLabel
    label.delete(cycleLabel)
    cycleLabel := label.new(
         bar_index, priceCycleLine + overlayAtr * 0.3,
         "◀ Cycle: " + str.tostring(priceCycleLine, format.mintick),
         color=color.new(color.black, 100),
         textcolor=overlayLineColor,
         style=label.style_label_left,
         force_overlay=true)

// ═══════════════════════════════════════════════════════════════
// SECULAR OVERLAY LINE
// Uses EMA(close, secularBasisLen) as price anchor — much slower than
// the cycle basis. secularLine is also extra-smoothed above.
// The combination of:
//   1) slower price anchor (EMA300 vs EMA55)
//   2) extra smoothing on the secular oscillator value
//   3) fixed neutral color (white/gray)
// ensures the secular line moves and looks completely distinct from the cycle line.
// ═══════════════════════════════════════════════════════════════

secularBasis      = ta.ema(close, secularBasisLen)
secularOverlayAmp = overlayAtr * secularOverlayMult
priceSecularLine  = secularBasis + (secularLine * secularOverlayAmp)

plot(showSecularOverlay ? priceSecularLine : na, "Secular Overlay",
     color=secularLineColor, linewidth=2,
     style=plot.style_line, force_overlay=true)

// Secular label: placed below the cycle label to avoid overlap.
var label secularLabel = na
if barstate.islast and showSecularOverlay and showSecularOverlayLabel
    label.delete(secularLabel)
    secularLabel := label.new(
         bar_index, priceSecularLine - overlayAtr * 0.3,
         "◀ Secular: " + str.tostring(priceSecularLine, format.mintick),
         color=color.new(color.black, 100),
         textcolor=secularLineColor,
         style=label.style_label_left,
         force_overlay=true)

// ═══════════════════════════════════════════════════════════════
// PANE DASHBOARD (optional, off by default)
// ═══════════════════════════════════════════════════════════════

var table dash = table.new(dashPos, 2, 7, border_width=1)

if barstate.isfirst
    dash := table.new(dashPos, 2, 7, border_width=1)

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "State",      text_color=chart.fg_color, text_halign=text.align_left,   text_size=dashTextSize)
    table.cell(dash, 1, 0, state,        text_color=regimeColor,    text_halign=text.align_center,  text_size=dashTextSize)
    table.cell(dash, 0, 1, "Regime",     text_color=chart.fg_color, text_halign=text.align_left,    text_size=dashTextSize)
    table.cell(dash, 1, 1, regime,       text_color=regimeColor,    text_halign=text.align_center,  text_size=dashTextSize)
    table.cell(dash, 0, 2, "Direction",  text_color=chart.fg_color, text_halign=text.align_left,    text_size=dashTextSize)
    table.cell(dash, 1, 2, direction + " " + arrow(waveSlope, waveSlope[1], 0.01), text_color=regimeColor, text_halign=text.align_center, text_size=dashTextSize)
    table.cell(dash, 0, 3, "Cycle Wave", text_color=chart.fg_color, text_halign=text.align_left,    text_size=dashTextSize)
    table.cell(dash, 1, 3, str.tostring(cycleWaveSm, "#.00"), text_color=waveColor, text_halign=text.align_center, text_size=dashTextSize)
    table.cell(dash, 0, 4, "Secular",    text_color=chart.fg_color, text_halign=text.align_left,    text_size=dashTextSize)
    table.cell(dash, 1, 4, secularRegime, text_color=secularRegClr, text_halign=text.align_center,  text_size=dashTextSize)
    table.cell(dash, 0, 5, "Score",      text_color=chart.fg_color, text_halign=text.align_left,    text_size=dashTextSize)
    table.cell(dash, 1, 5, str.tostring(totalScore), text_color=regimeColor, text_halign=text.align_center, text_size=dashTextSize)
    table.cell(dash, 0, 6, "Risk",       text_color=chart.fg_color, text_halign=text.align_left,    text_size=dashTextSize)
    table.cell(dash, 1, 6, riskPosture,  text_color=regimeColor,    text_halign=text.align_center,  text_size=dashTextSize)

if barstate.islast and not showDashboard
    table.clear(dash, 0, 0, 1, 6)

// ═══════════════════════════════════════════════════════════════
// OVERLAY DASHBOARD
// ═══════════════════════════════════════════════════════════════

var table overlayDash = table.new(overlayDashPos, 2, 13, border_width=1, force_overlay=true)

if barstate.isfirst
    overlayDash := table.new(overlayDashPos, 2, 13, border_width=1, force_overlay=true)

if barstate.islast and showOverlayDash
    table.cell(overlayDash, 0, 0,  "Market Cycle",      text_color=color.white,             text_halign=text.align_left,   text_size=overlayDashTextSize, bgcolor=color.new(regimeColor, 35))
    table.cell(overlayDash, 1, 0,  "Wave [G]",          text_color=color.white,             text_halign=text.align_center, text_size=overlayDashTextSize, bgcolor=color.new(regimeColor, 35))
    table.cell(overlayDash, 0, 1,  "Regime",            text_color=chart.fg_color,          text_halign=text.align_left,   text_size=overlayDashTextSize)
    table.cell(overlayDash, 1, 1,  regime,              text_color=regimeColor,             text_halign=text.align_center, text_size=overlayDashTextSize)
    table.cell(overlayDash, 0, 2,  "State",             text_color=chart.fg_color,          text_halign=text.align_left,   text_size=overlayDashTextSize)
    table.cell(overlayDash, 1, 2,  state,               text_color=regimeColor,             text_halign=text.align_center, text_size=overlayDashTextSize)
    table.cell(overlayDash, 0, 3,  "Direction",         text_color=chart.fg_color,          text_halign=text.align_left,   text_size=overlayDashTextSize)
    table.cell(overlayDash, 1, 3,  direction,           text_color=regimeColor,             text_halign=text.align_center, text_size=overlayDashTextSize)
    table.cell(overlayDash, 0, 4,  "Cycle Wave",        text_color=chart.fg_color,          text_halign=text.align_left,   text_size=overlayDashTextSize)
    table.cell(overlayDash, 1, 4,  str.tostring(cycleWaveSm, "#.00"), text_color=waveColor, text_halign=text.align_center, text_size=overlayDashTextSize)
    table.cell(overlayDash, 0, 5,  "Secular",           text_color=chart.fg_color,          text_halign=text.align_left,   text_size=overlayDashTextSize)
    table.cell(overlayDash, 1, 5,  secularRegime,       text_color=secularRegClr,           text_halign=text.align_center, text_size=overlayDashTextSize)
    table.cell(overlayDash, 0, 6,  "Score",             text_color=chart.fg_color,          text_halign=text.align_left,   text_size=overlayDashTextSize)
    table.cell(overlayDash, 1, 6,  str.tostring(totalScore), text_color=regimeColor,        text_halign=text.align_center, text_size=overlayDashTextSize)
    table.cell(overlayDash, 0, 7,  "Risk",              text_color=chart.fg_color,          text_halign=text.align_left,   text_size=overlayDashTextSize)
    table.cell(overlayDash, 1, 7,  riskPosture,         text_color=regimeColor,             text_halign=text.align_center, text_size=overlayDashTextSize)
    table.cell(overlayDash, 0, 8,  "Color Legend",      text_color=color.white,             text_halign=text.align_left,   text_size=overlayDashTextSize, bgcolor=color.new(chart.fg_color, 70))
    table.cell(overlayDash, 1, 8,  "Regimes",           text_color=color.white,             text_halign=text.align_center, text_size=overlayDashTextSize, bgcolor=color.new(chart.fg_color, 70))
    table.cell(overlayDash, 0, 9,  "Blue",              text_color=bullColor,               text_halign=text.align_left,   text_size=overlayDashTextSize)
    table.cell(overlayDash, 1, 9,  "Debt Accumulation", text_color=bullColor,               text_halign=text.align_center, text_size=overlayDashTextSize)
    table.cell(overlayDash, 0, 10, "Yellow",            text_color=bearColor,               text_halign=text.align_left,   text_size=overlayDashTextSize)
    table.cell(overlayDash, 1, 10, "Deleveraging",      text_color=bearColor,               text_halign=text.align_center, text_size=overlayDashTextSize)
    table.cell(overlayDash, 0, 11, "Green",             text_color=reflColor,               text_halign=text.align_left,   text_size=overlayDashTextSize)
    table.cell(overlayDash, 1, 11, "Reflation",         text_color=reflColor,               text_halign=text.align_center, text_size=overlayDashTextSize)
    table.cell(overlayDash, 0, 12, "White Thin",        text_color=color.new(color.white, 45), text_halign=text.align_left, text_size=overlayDashTextSize)
    table.cell(overlayDash, 1, 12, "Secular Context",   text_color=color.new(color.white, 45), text_halign=text.align_center, text_size=overlayDashTextSize)

if barstate.islast and not showOverlayDash
    table.clear(overlayDash, 0, 0, 1, 12)

// ═══════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════

alertcondition(isDebtAccumulation and not isDebtAccumulation[1], title="→ Debt Accumulation", message="Market Cycle Wave [Gabremoku]: Debt Accumulation on {{ticker}} {{interval}}")
alertcondition(isDeleveraging     and not isDeleveraging[1],     title="→ Deleveraging",      message="Market Cycle Wave [Gabremoku]: Deleveraging on {{ticker}} {{interval}}")
alertcondition(isReflation        and not isReflation[1],        title="→ Reflation",         message="Market Cycle Wave [Gabremoku]: Reflation on {{ticker}} {{interval}}")
alertcondition(not na(ph) and ph > 0.65,                         title="Cycle Peak",          message="Market Cycle Wave [Gabremoku]: Cycle Peak detected on {{ticker}} {{interval}}")
alertcondition(not na(pl) and pl < -0.65,                        title="Cycle Trough",        message="Market Cycle Wave [Gabremoku]: Cycle Trough detected on {{ticker}} {{interval}}")
````
