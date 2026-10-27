# Asterion Regime Lattice [JOAT]

- url: https://www.tradingview.com/script/CaOrfK0r-Asterion-Regime-Lattice-JOAT/
- type: indicator
- pine_id: PUB;c166cce0e32b4ba39f8993d02f4347e9
- version: 1.0

## Description

[b]Asterion Regime Lattice [JOAT][/b]

[b]Introduction[/b]

Asterion Regime Lattice is an open-source market regime oscillator designed to classify whether conditions are directional, transitional, or balanced by combining multiple independent measurements into one continuous score. Instead of relying on a single trend indicator, it evaluates trend displacement, momentum, volatility behavior, directional movement, efficiency, choppiness, entropy, and higher-timeframe confirmation.

The problem this script solves is regime ambiguity. Many entries fail because traders apply trend logic in rotational conditions or mean-reversion logic in expanding directional phases. Asterion Regime Lattice provides a higher-level state model first, so any downstream tool can be interpreted in the proper context. The pane output uses layered lattice bands, a smoothed score curve, regime shading, and a compact dashboard to make the current state readable at a glance without covering price.

[image]https://www.tradingview.com/x/sduFTTfv/[/image]

[b]Core Concepts[/b]

[b]1. Composite Regime Scoring[/b]

The script builds a regime score from several independent components rather than one oscillator. It measures fast/slow trend displacement, momentum direction, volatility expansion, directional movement, efficiency ratio, choppiness, Shannon entropy, fractal dimension, RSI state, and ADX-derived trend strength. Each component is normalized, weighted, and added into a single signed score where positive values indicate bullish expansion and negative values indicate bearish expansion.

[b]2. Higher-Timeframe Confirmation[/b]

Two higher timeframes are requested with `request.security()` using `lookahead = barmerge.lookahead_off`. This keeps the script non-repainting while allowing the current timeframe to compare itself against broader directional conditions. The higher-timeframe pack contributes trend bias, momentum bias, volatility bias, directional movement bias, slope, ROC, and ADX strength.

[pine]
[h1TrendBias, h1MomBias, h1VolBias, h1DmiBias, h1AdxBias, h1Slope, h1Roc, h1Adx] =
    request.security(syminfo.tickerid, htfOne, f_htfPack(), lookahead = barmerge.lookahead_off)
[/pine]

[b]3. Structure Quality and Noise Separation[/b]

The script uses efficiency, choppiness, entropy, and fractal-dimension style measurements to separate clean directional movement from noisy rotation. That matters because two markets can have similar momentum but very different trade quality. Asterion does not only ask "is price moving?" It also asks whether the move is organized enough to treat as a real regime.

[b]4. Lattice Bands and Regime Zones[/b]

The oscillator uses inner and outer bands around the smoothed score curve to display soft and strong regime zones. When the score pushes beyond soft thresholds the state becomes directional. When it pushes through stronger thresholds with quality and higher-timeframe agreement, the state becomes more decisive. This layered presentation makes the transition from balance to expansion visible before and during the full move.

[b]5. Confirmed State Transitions[/b]

Alerts and state changes are only confirmed on closed bars. This keeps the script suitable for live use and avoids intrabar state flips being treated as final.

[b]Features[/b]

[list]
[*][b]Composite regime score:[/b] Blends trend, momentum, volatility, efficiency, entropy, fractal behavior, RSI, and DMI/ADX context
[*][b]Dual higher-timeframe confirmation:[/b] Uses two configurable timeframes with `lookahead_off`
[*][b]Trend quality layer:[/b] Separates clean directional movement from noisy or choppy conditions
[*][b]Inner and outer lattice bands:[/b] Visualize soft and strong directional zones
[*][b]Pane regime shading:[/b] Background tint shifts with the current market state
[*][b]Optional bar tinting:[/b] Can color price bars by current regime while keeping the oscillator in a separate pane
[*][b]Dashboard summary:[/b] Reports regime, quality, HTF alignment, volatility, momentum, efficiency, entropy, and directional state
[*][b]Confirmed-bar alerts:[/b] Bull, bear, soft bull, soft bear, and transition events trigger only after bar confirmation
[/list]

[b]Input Parameters[/b]

[b]Core:[/b]
[list]
[*]Fast Length and Slow Length: Trend displacement backbone
[*]Momentum Length and Trend Slope Length: Speed and directional persistence measurements
[*]Structure Length, Volume Length, Volatility Length: Core normalization windows
[*]Efficiency Length, Choppiness Length, Entropy Length, Entropy Bins, Fractal Length: Noise and organization diagnostics
[*]RSI Length and ADX Length: Directional strength and internal pressure inputs
[/list]

[b]Higher-Timeframe Confirmation:[/b]
[list]
[*]Primary HTF and Secondary HTF
[*]Strong ADX and Weak ADX thresholds
[/list]

[b]Visuals:[/b]
[list]
[*]Pane shading toggle
[*]Lattice band toggle
[*]Score curve toggle
[*]Bar tint toggle
[*]Curve smoothing and band multipliers
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Regime Row[/b]
Start with the Regime row in the dashboard and the position of the score relative to the soft and hard thresholds. This tells you whether the market is directional, balanced, or in transition.

[b]Step 2: Check Quality Before Acting[/b]
A high-magnitude regime score with weak quality is less reliable than a slightly smaller score with strong quality. Use the Quality row to decide whether the move is organized enough to trust.

[b]Step 3: Compare With Higher Timeframes[/b]
The HTF row helps determine whether the current timeframe is aligned with the broader backdrop or fighting it. Stronger follow-through usually appears when local and higher-timeframe states agree.

[b]Step 4: Use It as a Context Filter[/b]
Asterion is best used as a regime filter. Trend systems generally perform better when the oscillator is directional and quality is strong. Mean-reversion logic is generally more appropriate when the score is near balance and noise metrics dominate.

[b]Indicator Limitations[/b]

[list]
[*]The script is a classifier, not a predictive model. It describes current conditions; it does not forecast future direction
[*]Higher-timeframe confirmation can lag turning points because those bars must close before their state is final
[*]In low-range grinding markets, the oscillator can remain transitional for extended periods
[*]Any weighted composite reflects design choices; different markets may require threshold adjustments
[/list]

[b]Originality Statement[/b]

Asterion Regime Lattice is original in the way it combines directional scoring, higher-timeframe agreement, and multiple noise-quality measurements into one structured regime model. It is not a simple trend oscillator with a new color scheme. The script is built around the idea that regime is a blend of direction, organization, and alignment across timeframes, and its lattice presentation is designed to make those layers visible rather than hiding them behind a single line.

[b]Disclaimer[/b]

This script is provided for educational and informational purposes only. It is not financial advice and does not guarantee any outcome. Regime measurements are based on historical price and volume behavior and can produce false or delayed readings, especially during sudden event-driven changes in market conditions. Always use independent judgment and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Asterion Regime Lattice [JOAT]", shorttitle="ARL [JOAT]", overlay=false, precision=1, max_bars_back=5000, max_lines_count=50, max_labels_count=20, max_boxes_count=20)

// =====================================================================
// Core Inputs
// =====================================================================

string grpCore = "Core"
string grpHTF = "HTF Confirmation"
string grpViz = "Visuals"
string grpDash = "Dashboard"
string grpAlerts = "Alerts"

source = input.source(close, "Source", group=grpCore)

fastLen = input.int(21, "Fast Length", minval=2, maxval=200, group=grpCore)
slowLen = input.int(55, "Slow Length", minval=5, maxval=400, group=grpCore)
momentumLen = input.int(14, "Momentum Length", minval=2, maxval=100, group=grpCore)
trendLen = input.int(34, "Trend Slope Length", minval=5, maxval=200, group=grpCore)
structureLen = input.int(50, "Structure Length", minval=10, maxval=300, group=grpCore)
volumeLen = input.int(20, "Volume Length", minval=5, maxval=200, group=grpCore)
volatilityLen = input.int(14, "Volatility Length", minval=5, maxval=100, group=grpCore)
erLen = input.int(20, "Efficiency Length", minval=5, maxval=100, group=grpCore)
chopLen = input.int(14, "Choppiness Length", minval=5, maxval=100, group=grpCore)
entropyLen = input.int(20, "Entropy Length", minval=5, maxval=100, group=grpCore)
entropyBins = input.int(8, "Entropy Bins", minval=4, maxval=20, group=grpCore)
fractalLen = input.int(20, "Fractal Length", minval=6, maxval=100, group=grpCore)
rsiLen = input.int(14, "RSI Length", minval=2, maxval=100, group=grpCore)
adxLen = input.int(14, "ADX Length", minval=2, maxval=100, group=grpCore)

htfOne = input.timeframe("240", "Primary HTF", group=grpHTF)
htfTwo = input.timeframe("D", "Secondary HTF", group=grpHTF)
adxStrong = input.float(25.0, "Strong ADX", minval=5, maxval=60, step=0.5, group=grpHTF)
adxWeak = input.float(15.0, "Weak ADX", minval=1, maxval=40, step=0.5, group=grpHTF)

showPaneShade = input.bool(true, "Show Pane Shade", group=grpViz)
showLatticeBands = input.bool(true, "Show Lattice Bands", group=grpViz)
showScoreCurve = input.bool(true, "Show Score Curve", group=grpViz)
showBarTint = input.bool(true, "Tint Price Bars", group=grpViz)
curveLen = input.int(9, "Curve Smoothing", minval=2, maxval=50, group=grpViz)
outerBandMult = input.float(0.95, "Outer Band Mult", minval=0.2, maxval=3.0, step=0.05, group=grpViz)
innerBandMult = input.float(0.52, "Inner Band Mult", minval=0.1, maxval=2.0, step=0.01, group=grpViz)
cloudAlpha = input.int(90, "Cloud Transparency", minval=0, maxval=100, group=grpViz)
barAlpha = input.int(65, "Bar Tint Transparency", minval=0, maxval=100, group=grpViz)

showDashboard = input.bool(true, "Show Dashboard", group=grpDash)
dashTextSize = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal"], group=grpDash)

bullTone = input.color(color.rgb(56, 207, 146), "Bull Tone", group=grpViz)
bearTone = input.color(color.rgb(221, 82, 109), "Bear Tone", group=grpViz)
neutralTone = input.color(color.rgb(146, 158, 179), "Neutral Tone", group=grpViz)
accentTone = input.color(color.rgb(106, 145, 255), "Accent Tone", group=grpViz)
backTone = input.color(color.rgb(10, 14, 24), "Pane Tone", group=grpViz)
gridTone = input.color(color.rgb(39, 47, 64), "Grid Tone", group=grpViz)

bullTrigger = input.float(60.0, "Bull Trigger", minval=10, maxval=95, step=0.5, group=grpAlerts)
bearTrigger = input.float(-60.0, "Bear Trigger", minval=-95, maxval=-10, step=0.5, group=grpAlerts)
softBull = input.float(20.0, "Soft Bull", minval=0, maxval=60, step=0.5, group=grpAlerts)
softBear = input.float(-20.0, "Soft Bear", minval=-60, maxval=0, step=0.5, group=grpAlerts)

// =====================================================================
// Utility Functions
// =====================================================================

f_safeDiv(float num, float den, float fallback) =>
    math.abs(den) > 0.000001 ? num / den : fallback

f_clamp(float value, float lo, float hi) =>
    math.min(math.max(value, lo), hi)

f_signBias(bool bull, bool bear) =>
    bull ? 1.0 : bear ? -1.0 : 0.0

f_slope(float src, int len) =>
    ta.linreg(src, len, 0) - ta.linreg(src, len, 1)

f_efficiency(float src, int len) =>
    float moveSum = 0.0
    for i = 0 to len - 1
        moveSum += math.abs(src[i] - src[i + 1])
    float netMove = math.abs(src - src[len])
    f_safeDiv(netMove, moveSum, 0.0)

f_choppiness(int len) =>
    float atrSum = 0.0
    for i = 0 to len - 1
        atrSum += ta.atr(1)[i]
    float rangeWidth = ta.highest(high, len) - ta.lowest(low, len)
    float ratio = f_safeDiv(atrSum, rangeWidth, 1.0)
    f_safeDiv(100.0 * math.log(ratio), math.log(len), 50.0)

f_fractalDimension(float src, int len) =>
    int halfLen = math.max(1, int(len / 2))
    float fullPath = 0.0
    float halfPath = 0.0
    for i = 0 to len - 2
        fullPath += math.abs(src[i] - src[i + 1])
    for i = 0 to halfLen - 2
        halfPath += math.abs(src[i] - src[i + 1])
    float fd = fullPath > 0 ? math.log(f_safeDiv(halfPath, f_safeDiv(fullPath, 2.0, fullPath), 1.0)) / math.log(2.0) + 1.0 : 1.5
    f_clamp(fd, 1.0, 2.0)

f_shannonEntropy(float src, int len, int bins) =>
    float minValue = ta.lowest(src, len)
    float maxValue = ta.highest(src, len)
    float span = maxValue - minValue
    float entropy = 0.0
    if span > 0
        float[] histogram = array.new_float(bins, 0.0)
        for i = 0 to len - 1
            float norm = (src[i] - minValue) / span
            int idx = int(math.floor(norm * (bins - 1)))
            idx := math.max(0, math.min(bins - 1, idx))
            array.set(histogram, idx, array.get(histogram, idx) + 1.0)
        for i = 0 to bins - 1
            float p = array.get(histogram, i) / len
            entropy -= p > 0 ? p * math.log(p) : 0.0
    f_safeDiv(entropy, math.log(bins), 0.0)

f_gkVol(int len) =>
    float safeO = math.max(open, syminfo.mintick)
    float safeH = math.max(high, syminfo.mintick)
    float safeL = math.max(low, syminfo.mintick)
    float safeC = math.max(close, syminfo.mintick)
    float co = math.log(safeC / safeO)
    float hl = math.log(safeH / safeL)
    float raw = math.max(0.5 * hl * hl - (2.0 * math.log(2.0) - 1.0) * co * co, 0.0)
    float smooth = ta.sma(raw, len)
    math.sqrt(math.max(smooth, 0.0))

f_rangePosition(float src, int len) =>
    float top = ta.highest(high, len)
    float bot = ta.lowest(low, len)
    f_safeDiv(src - bot, top - bot, 0.5)

f_obvSeries() =>
    ta.cum(close > close[1] ? volume : close < close[1] ? -volume : 0.0)

f_labelFromScore(float score) =>
    score >= bullTrigger ? "Strong Bull" :
     score >= softBull ? "Constructive Bull" :
     score <= bearTrigger ? "Strong Bear" :
     score <= softBear ? "Constructive Bear" :
     "Balanced"

f_labelFromQuality(float quality) =>
    quality >= 75 ? "Strong" :
     quality >= 55 ? "Constructive" :
     quality >= 35 ? "Mixed" :
     "Fragile"

f_labelFromVol(float volScore) =>
    volScore > 0.4 ? "Expansion" :
     volScore < -0.4 ? "Compression" :
     "Balanced"

f_labelFromHtf(float htfScore) =>
    htfScore > 0.4 ? "Aligned" :
     htfScore < -0.4 ? "Divergent" :
     "Partial"

f_laneColor(float value) =>
    color.from_gradient(value, -100.0, 100.0, bearTone, bullTone)

f_softFillColor(float value) =>
    color.new(f_laneColor(value), 88)

// HTF snapshot pack returns multiple regime inputs from each higher timeframe.
f_htfPack() =>
    float hFast = ta.ema(close, fastLen)
    float hSlow = ta.ema(close, slowLen)
    float hSlope = f_slope(close, trendLen)
    float hMom = ta.roc(close, momentumLen)
    float hAtr = ta.atr(volatilityLen)
    float hAtrBase = ta.sma(hAtr, volatilityLen)
    [plusDI, minusDI, adxValue] = ta.dmi(adxLen, adxLen)
    float trendBias = close > hFast and hFast > hSlow and hSlope > 0 ? 1.0 : close < hFast and hFast < hSlow and hSlope < 0 ? -1.0 : 0.0
    float momBias = hMom > 0 ? 1.0 : hMom < 0 ? -1.0 : 0.0
    float volRatio = f_safeDiv(hAtr, hAtrBase, 1.0)
    float volBias = volRatio > 1.08 ? 1.0 : volRatio < 0.92 ? -1.0 : 0.0
    float dmiBias = plusDI > minusDI ? 1.0 : plusDI < minusDI ? -1.0 : 0.0
    float adxBias = adxValue > adxStrong ? 1.0 : adxValue < adxWeak ? -1.0 : 0.0
    [trendBias, momBias, volBias, dmiBias, adxBias, hSlope, hMom, adxValue]

// =====================================================================
// Base Market State
// =====================================================================

fastEma = ta.ema(source, fastLen)
slowEma = ta.ema(source, slowLen)
trendSlope = f_slope(source, trendLen)
momentumRoc = ta.roc(source, momentumLen)
rsiValue = ta.rsi(source, rsiLen)
efficiencyRatio = f_efficiency(source, erLen)
chopValue = f_choppiness(chopLen)
fractalValue = f_fractalDimension(source, fractalLen)
entropyValue = f_shannonEntropy(source, entropyLen, entropyBins)

atrValue = ta.atr(volatilityLen)
atrBase = ta.sma(atrValue, volatilityLen)
atrRatio = f_safeDiv(atrValue, atrBase, 1.0)
realizedVol = f_gkVol(volatilityLen)
realizedBase = ta.sma(realizedVol, volatilityLen)
realizedRatio = f_safeDiv(realizedVol, realizedBase, 1.0)
volComposite = (atrRatio + realizedRatio) / 2.0

obvValue = f_obvSeries()
obvSlope = f_slope(obvValue, volumeLen)
volumeZ = ta.stdev(volume, volumeLen) > 0 ? (volume - ta.sma(volume, volumeLen)) / ta.stdev(volume, volumeLen) : 0.0
volumeImpulse = f_clamp(volumeZ / 3.0, -1.0, 1.0)

rangePos = f_rangePosition(source, structureLen)
rangeMid = 0.5
structureDist = rangePos - rangeMid

[h1TrendBias, h1MomBias, h1VolBias, h1DmiBias, h1AdxBias, h1Slope, h1Roc, h1Adx] = request.security(syminfo.tickerid, htfOne, f_htfPack(), lookahead=barmerge.lookahead_off)
[h2TrendBias, h2MomBias, h2VolBias, h2DmiBias, h2AdxBias, h2Slope, h2Roc, h2Adx] = request.security(syminfo.tickerid, htfTwo, f_htfPack(), lookahead=barmerge.lookahead_off)

htfBias = (h1TrendBias + h1MomBias + h1VolBias + h1DmiBias + h1AdxBias + h2TrendBias + h2MomBias + h2VolBias + h2DmiBias + h2AdxBias) / 10.0
htfScore = f_clamp(htfBias, -1.0, 1.0)
htfConfidence = math.abs(htfScore) * 100.0

// =====================================================================
// Layered Regime Lattice
// =====================================================================

trendLayer = f_signBias(source > fastEma and fastEma > slowEma and trendSlope > 0, source < fastEma and fastEma < slowEma and trendSlope < 0)
momentumLayer = f_signBias(momentumRoc > 0 and rsiValue > 52 and efficiencyRatio > 0.35, momentumRoc < 0 and rsiValue < 48 and efficiencyRatio > 0.35)
structureLayer = f_signBias(rangePos > 0.62, rangePos < 0.38)
volumeLayer = f_signBias(volumeImpulse > 0.25 and obvSlope > 0, volumeImpulse < -0.25 and obvSlope < 0)
baseDirection = (trendLayer + momentumLayer + structureLayer + volumeLayer + htfScore) >= 0 ? 1.0 : -1.0
volatilityLayer = volComposite > 1.08 ? baseDirection * 0.40 : volComposite < 0.92 ? -baseDirection * 0.25 : 0.0
volatilityStateCode = volComposite > 1.08 ? 1 : volComposite < 0.92 ? -1 : 0

regimeScore = 100.0 * (
     trendLayer * 0.24 +
     momentumLayer * 0.18 +
     structureLayer * 0.14 +
     volumeLayer * 0.12 +
     volatilityLayer * 0.12 +
     htfScore * 0.20
)
regimeScore := f_clamp(regimeScore, -100.0, 100.0)

regimeCurve = ta.hma(regimeScore, curveLen)
regimeVelocity = regimeCurve - regimeCurve[1]
regimeAccel = regimeVelocity - regimeVelocity[1]
regimeSpread = math.abs(regimeScore - regimeCurve)

alignmentVotes = 0.0
alignmentVotes += trendLayer != 0 ? 1.0 : 0.0
alignmentVotes += momentumLayer != 0 ? 1.0 : 0.0
alignmentVotes += structureLayer != 0 ? 1.0 : 0.0
alignmentVotes += volumeLayer != 0 ? 1.0 : 0.0
alignmentVotes += htfScore != 0 ? 1.0 : 0.0
alignmentVotes += efficiencyRatio > 0.35 ? 1.0 : 0.0
alignmentVotes += chopValue < 55.0 ? 1.0 : 0.0
alignmentVotes += entropyValue < 0.72 ? 1.0 : 0.0

trendQuality = (alignmentVotes / 8.0) * 100.0
trendQuality -= math.max(0.0, chopValue - 55.0) * 0.6
trendQuality -= math.max(0.0, entropyValue - 0.72) * 25.0
trendQuality := f_clamp(trendQuality, 0.0, 100.0)

trendStateText = regimeScore >= bullTrigger ? "Bullish" : regimeScore <= bearTrigger ? "Bearish" : "Neutral"
trendQualityText = f_labelFromQuality(trendQuality)
volatilityStateText = f_labelFromVol(volatilityStateCode)
htfStateText = f_labelFromHtf(htfScore)
regimeStateText = f_labelFromScore(regimeScore)
structureStateText = rangePos > 0.62 ? "Upper Range" : rangePos < 0.38 ? "Lower Range" : "Mid Range"
momentumStateText = momentumRoc > 0 ? "Positive" : momentumRoc < 0 ? "Negative" : "Flat"

dominantTheme = regimeScore >= 0 ? bullTone : bearTone
regimeColor = f_laneColor(regimeScore)
curveColor = color.new(regimeColor, 20)

zoneColor =
     regimeScore >= bullTrigger ? color.new(bullTone, 88) :
     regimeScore >= softBull ? color.new(bullTone, 93) :
     regimeScore <= bearTrigger ? color.new(bearTone, 88) :
     regimeScore <= softBear ? color.new(bearTone, 93) :
     color.new(neutralTone, 95)

qualityColor = color.from_gradient(trendQuality, 0.0, 100.0, bearTone, bullTone)
htfColor = color.from_gradient(htfConfidence, 0.0, 100.0, bearTone, bullTone)
volColor = volatilityStateCode == 1 ? color.new(accentTone, 0) : volatilityStateCode == -1 ? color.new(neutralTone, 0) : color.new(neutralTone, 20)

dominantDirection = regimeScore >= 0 ? 1.0 : -1.0
latticeSpan = 12.0 + (100.0 - trendQuality) * 0.09 + math.abs(regimeVelocity) * 0.8 + math.abs(regimeAccel) * 0.5
latticeSpan := f_clamp(latticeSpan, 10.0, 40.0)

outerUpper = regimeCurve + latticeSpan * outerBandMult
outerLower = regimeCurve - latticeSpan * outerBandMult
innerUpper = regimeCurve + latticeSpan * innerBandMult
innerLower = regimeCurve - latticeSpan * innerBandMult

strongBull = regimeScore >= bullTrigger and trendQuality >= 55 and htfScore > 0
strongBear = regimeScore <= bearTrigger and trendQuality >= 55 and htfScore < 0
softBullState = regimeScore >= softBull and not strongBull
softBearState = regimeScore <= softBear and not strongBear
neutralState = not strongBull and not strongBear and not softBullState and not softBearState

// Confirmed-bar transition flags for alerts and dashboard context.
bullRegimeShift = barstate.isconfirmed and regimeScore > bullTrigger and regimeScore[1] <= bullTrigger
bearRegimeShift = barstate.isconfirmed and regimeScore < bearTrigger and regimeScore[1] >= bearTrigger
bullSoftShift = barstate.isconfirmed and regimeScore > softBull and regimeScore[1] <= softBull
bearSoftShift = barstate.isconfirmed and regimeScore < softBear and regimeScore[1] >= softBear
volCompressionShift = barstate.isconfirmed and volatilityStateCode == -1 and volatilityStateCode[1] != -1
volExpansionShift = barstate.isconfirmed and volatilityStateCode == 1 and volatilityStateCode[1] != 1
htfAlignmentShift = barstate.isconfirmed and htfConfidence > 70.0 and htfConfidence[1] <= 70.0

// =====================================================================
// Visualization
// =====================================================================

bgcolor(showPaneShade ? zoneColor : na, title="Regime Shade")

plot(0.0, "Zero", color=color.new(gridTone, 45), linewidth=1, style=plot.style_line)
plot(softBull, "Soft Bull", color=color.new(gridTone, 65), linewidth=1, style=plot.style_line)
plot(bullTrigger, "Bull Trigger", color=color.new(gridTone, 35), linewidth=1, style=plot.style_line)
plot(softBear, "Soft Bear", color=color.new(gridTone, 65), linewidth=1, style=plot.style_line)
plot(bearTrigger, "Bear Trigger", color=color.new(gridTone, 35), linewidth=1, style=plot.style_line)

pScore = plot(showScoreCurve ? regimeScore : na, "Regime Score", color=regimeColor, linewidth=2)
pCurve = plot(showScoreCurve ? regimeCurve : na, "Regime Curve", color=curveColor, linewidth=2)

pOuterUpper = plot(showLatticeBands ? outerUpper : na, "Outer Upper", color=color.new(regimeColor, 76), linewidth=1)
pOuterLower = plot(showLatticeBands ? outerLower : na, "Outer Lower", color=color.new(regimeColor, 76), linewidth=1)
pInnerUpper = plot(showLatticeBands ? innerUpper : na, "Inner Upper", color=color.new(regimeColor, 86), linewidth=1)
pInnerLower = plot(showLatticeBands ? innerLower : na, "Inner Lower", color=color.new(regimeColor, 86), linewidth=1)

fill(pOuterUpper, pOuterLower, color=showLatticeBands ? color.new(regimeColor, cloudAlpha) : na, title="Outer Cloud")
fill(pInnerUpper, pInnerLower, color=showLatticeBands ? color.new(regimeColor, cloudAlpha - 8) : na, title="Inner Cloud")
fill(pScore, pCurve, color=color.new(regimeColor, 84), title="Score Cloud")

barTint =
     regimeScore >= bullTrigger ? color.new(bullTone, barAlpha) :
     regimeScore >= softBull ? color.new(bullTone, math.min(barAlpha + 12, 95)) :
     regimeScore <= bearTrigger ? color.new(bearTone, barAlpha) :
     regimeScore <= softBear ? color.new(bearTone, math.min(barAlpha + 12, 95)) :
     color.new(neutralTone, 88)

barcolor(showBarTint ? barTint : na, title="Regime Bar Tint")

// =====================================================================
// Dashboard
// =====================================================================

if showDashboard and barstate.islast
    tablePos = position.top_right
    textSize = size.normal
    var table dash = table.new(tablePos, 2, 8, bgcolor=color.new(backTone, 6), border_color=color.new(gridTone, 15), border_width=1, frame_color=color.new(accentTone, 30), frame_width=1)

    table.cell(dash, 0, 0, "Regime Summary", text_color=color.white, text_size=textSize, bgcolor=color.new(accentTone, 72), text_halign=text.align_left)
    table.cell(dash, 1, 0, timeframe.period, text_color=color.new(neutralTone, 5), text_size=textSize, bgcolor=color.new(accentTone, 72), text_halign=text.align_right)
    table.merge_cells(dash, 0, 0, 1, 0)

    table.cell(dash, 0, 1, "Regime", text_color=neutralTone, text_size=textSize, bgcolor=color.new(backTone, 0), text_halign=text.align_left)
    table.cell(dash, 1, 1, regimeStateText + " " + str.tostring(regimeScore, "#.0"), text_color=regimeColor, text_size=textSize, bgcolor=color.new(backTone, 0), text_halign=text.align_right)

    table.cell(dash, 0, 2, "Quality", text_color=neutralTone, text_size=textSize, bgcolor=color.new(backTone, 0), text_halign=text.align_left)
    table.cell(dash, 1, 2, trendQualityText + " " + str.tostring(trendQuality, "#.0"), text_color=qualityColor, text_size=textSize, bgcolor=color.new(backTone, 0), text_halign=text.align_right)

    table.cell(dash, 0, 3, "HTF", text_color=neutralTone, text_size=textSize, bgcolor=color.new(backTone, 0), text_halign=text.align_left)
    table.cell(dash, 1, 3, htfStateText + " " + str.tostring(htfConfidence, "#.0"), text_color=htfColor, text_size=textSize, bgcolor=color.new(backTone, 0), text_halign=text.align_right)

    table.cell(dash, 0, 4, "Volatility", text_color=neutralTone, text_size=textSize, bgcolor=color.new(backTone, 0), text_halign=text.align_left)
    table.cell(dash, 1, 4, volatilityStateText + " " + str.tostring(volComposite, "#.00"), text_color=volColor, text_size=textSize, bgcolor=color.new(backTone, 0), text_halign=text.align_right)

    table.cell(dash, 0, 5, "Structure", text_color=neutralTone, text_size=textSize, bgcolor=color.new(backTone, 0), text_halign=text.align_left)
    table.cell(dash, 1, 5, structureStateText + " " + str.tostring(rangePos * 100.0, "#.0") + "%", text_color=structureDist > 0 ? bullTone : structureDist < 0 ? bearTone : neutralTone, text_size=textSize, bgcolor=color.new(backTone, 0), text_halign=text.align_right)

    table.cell(dash, 0, 6, "Momentum", text_color=neutralTone, text_size=textSize, bgcolor=color.new(backTone, 0), text_halign=text.align_left)
    table.cell(dash, 1, 6, momentumStateText + " " + str.tostring(momentumRoc, "#.00"), text_color=momentumLayer > 0 ? bullTone : momentumLayer < 0 ? bearTone : neutralTone, text_size=textSize, bgcolor=color.new(backTone, 0), text_halign=text.align_right)

    table.cell(dash, 0, 7, "State", text_color=neutralTone, text_size=textSize, bgcolor=color.new(backTone, 0), text_halign=text.align_left)
    table.cell(dash, 1, 7, trendStateText, text_color=dominantTheme, text_size=textSize, bgcolor=color.new(backTone, 0), text_halign=text.align_right)

// =====================================================================
// Hidden Data Outputs
// =====================================================================

plot(regimeScore, "Regime Score Data", display=display.none)
plot(trendQuality, "Trend Quality Data", display=display.none)
plot(volComposite, "Volatility Data", display=display.none)
plot(htfConfidence, "HTF Confidence Data", display=display.none)

// =====================================================================
// Alerts
// =====================================================================

alertcondition(bullRegimeShift, "Bull Regime Shift", "Asterion Regime Lattice: Bullish regime confirmed on {{ticker}}")
alertcondition(bearRegimeShift, "Bear Regime Shift", "Asterion Regime Lattice: Bearish regime confirmed on {{ticker}}")
alertcondition(bullSoftShift, "Soft Bull Shift", "Asterion Regime Lattice: Regime moved into constructive bullish territory on {{ticker}}")
alertcondition(bearSoftShift, "Soft Bear Shift", "Asterion Regime Lattice: Regime moved into constructive bearish territory on {{ticker}}")
alertcondition(volCompressionShift, "Volatility Compression", "Asterion Regime Lattice: Volatility compressed on {{ticker}}")
alertcondition(volExpansionShift, "Volatility Expansion", "Asterion Regime Lattice: Volatility expanded on {{ticker}}")
alertcondition(htfAlignmentShift, "HTF Alignment", "Asterion Regime Lattice: Higher timeframe alignment strengthened on {{ticker}}")

// =====================================================================
// End of Script
// =====================================================================
````
