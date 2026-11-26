# Event Horizon

- url: https://www.tradingview.com/script/dRMAuuQw-Event-Horizon/
- type: indicator
- pine_id: PUB;3a600d1ca18e42e78c2bc1ab378e9755
- version: 1.0

## Description

Event Horizon is a historical analog projection fan designed to answer one practical question:

What has price tended to do after market conditions similar to the current one?

Instead of using a fixed crossover, oscillator threshold, or trend flip, this indicator builds a market fingerprint from the current chart, searches historical bars for similar conditions, and projects how those past analogs moved forward. The result is a visual forward fan showing possible path behavior, consensus direction, dispersion, confidence, and the closest historical analog path.

The goal is not to predict the future with certainty. The goal is to give traders a structured way to compare the current setup against similar historical environments and quickly see whether the analogs are aligned, scattered, bullish, bearish, or not useful.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
What makes this script different
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Most projection tools draw a channel, regression, moving average extension, or volatility cone from a fixed formula.

Event Horizon uses a historical analog engine. Each bar is converted into a multi-factor feature profile, then compared against prior market states using weighted Euclidean similarity. The closest historical analogs are used to create a forward projection fan.

The script combines:

• Historical analog matching
• Weighted Euclidean distance
• Regime-aware scoring
• Volatility and trend-state filtering
• Consensus projection logic
• Closest historical path overlay
• Agreement and confidence scoring
• Directional historical event dots
• A visual fan that shows uncertainty instead of one hard prediction

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
How it works
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Market fingerprint

The script measures the current market using multiple dimensions, including:

• Recent price movement
• Trend slope
• ATR expansion and compression
• Candle range and body behavior
• Wick imbalance
• Position relative to recent structure
• Breakout distance
• Volume ratio and volume trend
• ATR percentile
• ADX / trend strength
• Historical shape samples

This creates a multi-dimensional profile of the current setup.

2. Historical analog search

The current profile is compared to historical profiles on the same chart. Similarity is calculated with weighted Euclidean distance, so higher-value features such as trend, volatility regime, and price-shape behavior can matter more than smaller candle details.

Closer historical examples receive stronger match scores.

3. Regime awareness

The script also classifies the current environment into regimes such as trend, compression, volatility expansion, volume shock, or range/chop. Historical examples from incompatible regimes are penalized, helping reduce weak comparisons.

4. Forward projection

Once the best analogs are selected, the script looks at what actually happened after those historical setups. Those forward moves are normalized and projected from the current anchor point.

5. Consensus and confidence

The indicator summarizes the analog group with:

• Directional bias
• Agreement percentage
• Dispersion
• Confidence score
• Edge state: TRADEABLE, CAUTION, or NO EDGE
• Historical self-test statistics

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
How to read the fan
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The colored fan shows the projected analog field.

The colored median shows the consensus path of the analog set.

The white line shows the closest visible historical analog path. It is not a guaranteed target. It is the path taken by the most similar past setup selected by the engine.

The wider the fan, the more disagreement there is between analogs.

The tighter the fan, the more historically aligned the analogs are.

The confidence and edge label are important. A bullish-looking fan with low confidence or high dispersion should be treated differently than a bullish fan with strong agreement and cleaner regime structure.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Historical dots
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Historical event dots help visually review where prior projection events occurred.

• Bullish projection dots appear below price
• Bearish projection dots appear above price
• Mixed or neutral readings are visually separated

This makes it easier to inspect whether the indicator has been identifying useful directional conditions on the current symbol and timeframe.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
How to use it
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

For newer traders:

1. Start on the Daily or 4H chart.
2. Look at the colored median.
3. Check whether the white analog path agrees with the median.
4. Check confidence and agreement.
5. Avoid forcing trades when the label says NO EDGE or when dispersion is high.

A stronger bullish read usually has:

• Median path rising
• White analog path also rising
• Agreement above roughly 65%
• Confidence above roughly 70
• Low or medium dispersion
• Edge state showing TRADEABLE or CAUTION, not NO EDGE

A weaker or avoidable read usually has:

• Median and white path disagreeing
• Agreement near 50%
• High dispersion
• Low confidence
• Range/chop regime
• NO EDGE label

For experienced traders:

Use the fan as an analog-based context layer. It is most useful when combined with your own structure, liquidity, trend, support/resistance, volume, or macro view. The script is designed to show whether historical analog behavior supports or conflicts with the trade idea you already see on the chart.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Suggested settings
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Balanced stocks / ETFs:

• Mode: Current Bar Projection
• Visual Mode: Cinematic
• Fan Style: Hybrid Swarm + Contours
• Horizon: 30
• Memory Lookback: 1800
• Max Analogs: 30
• Minimum Analogs: 6
• Pre-Event Window: 20
• Shape Samples: 6
• Path Scale: 1.0

Crypto:

• Horizon: 24
• Memory Lookback: 2000 to 2500
• Path Scale: 0.75 to 0.90
• Flexible direction matching

Intraday:

• Horizon: 20 to 24
• Minimum Analogs: 8
• Path Scale: 0.75 to 1.0
• Use liquid symbols only

Trend continuation:

• Direction Matching: Strict
• Mirror Opposite Direction: Off
• Path Scale: 1.0

Reversal / exhaustion:

• Direction Matching: Flexible
• Mirror Opposite Direction: On
• Path Scale: 0.75
• Shorter horizon preferred

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Best use cases
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Event Horizon is best suited for:

• Liquid stocks
• Major ETFs
• Index products
• Major crypto pairs
• Trend continuation setups
• Post-compression expansion
• Structure breaks
• Swing-trade context
• Daily and 4H analysis

It is less suitable for:

• Illiquid symbols
• Very new tickers with limited history
• Low-volume penny stocks
• Earnings gaps
• Binary news events
• Extremely short scalping timeframes
• Markets with sudden one-off catalysts

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Important notes
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This is an analog projection tool, not a standalone buy/sell system.

Historical similarity does not guarantee future behavior. Market structure, liquidity, volatility, news, and macro conditions can change quickly. The fan should be used as a decision-support layer, not as a guaranteed forecast.

The strongest readings occur when the median, white analog path, agreement, confidence, and regime state all point in the same direction.

The weakest readings occur when analogs are scattered, confidence is low, dispersion is high, or the script identifies a no-edge environment.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Event Horizon turns historical market behavior into a forward analog projection fan.

It helps traders see:

• What similar past setups did next
• Whether those analogs agree or disagree
• Whether the current regime supports the projection
• Whether the projected path is tight or scattered
• Whether the setup has enough confidence to matter

Use it to add historical context, probability awareness, and regime-based discipline to your chart analysis.

## Source Code

````pine
//@version=6
indicator("Event Horizon — Event Analog Projection Fan [95+ Engine]", shorttitle="Event Horizon 95+", overlay=true, max_polylines_count=100, max_lines_count=40, max_labels_count=60, max_bars_back=3000)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ① APPROVED VISUAL RENDERER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
gUX = "① Approved Visual Renderer"

visMode = input.string("Cinematic", "Visual Mode", options=["Minimal", "Standard", "Cinematic"], group=gUX)
fanStyle = input.string("Hybrid Swarm + Contours", "Fan Style", options=["Hybrid Swarm + Contours", "Clean Scientific", "Swarm Only", "Ribbon Core"], group=gUX)
curvedLines = input.bool(true, "Curved Polylines", group=gUX)
showAnalogPaths = input.bool(true, "Show Faint Analog Paths", group=gUX)
showContourRails = input.bool(true, "Show Percentile Contours", group=gUX)
showRibbonCore = input.bool(true, "Show Soft Median Core", group=gUX)
showStats = input.bool(true, "Show Stats Label", group=gUX)
showEventLabel = input.bool(true, "Show Event Anchor", group=gUX)
showForwardTag = input.bool(true, "Show Forward Fan Tag", group=gUX)
showHistoricalEvents = input.bool(false, "Show Historical Event Dots", group=gUX)

showWhiteHistoricalPath = input.bool(true, "Show White Historical Projection", group=gUX)
whiteHistoricalWidth = input.int(2, "White Historical Projection Width", minval=1, maxval=5, group=gUX)
whiteHistoricalTransparency = input.int(0, "White Historical Projection Transparency", minval=0, maxval=100, group=gUX)
whitePathSource = input.string("Best Visible Analog", "White Path Source", options=["Best Match", "Best Visible Analog"], group=gUX, tooltip="Best Match uses row 0. Best Visible Analog scans the top matches and picks the first real analog path that separates from the colored consensus so the white path does not visually disappear.")
whiteMinSeparationATR = input.float(0.08, "White Path Min Separation ATR", minval=0.0, maxval=0.50, step=0.01, group=gUX)
consensusMode = input.string("Weighted Average", "Consensus Path Mode", options=["Weighted Average", "Percentile Median"], group=gUX, tooltip="Weighted Average uses match scores to build a smarter consensus path. Percentile Median uses the raw p50 path.")

showRawAnalogOverlay = input.bool(false, "Show Raw White Analog Overlay", group=gUX, tooltip="Optional. Shows the matched raw historical analogs. Off by default so the visual swarm stays clean.")
rawAnalogTransparency = input.int(78, "Raw Analog Overlay Transparency", minval=0, maxval=100, group=gUX)
rawAnalogWidth = input.int(1, "Raw Analog Overlay Width", minval=1, maxval=3, group=gUX)
maxRawOverlayPaths = input.int(6, "Max Raw Overlay Paths", minval=1, maxval=20, group=gUX)

anchorMode = input.string("Current Bar Projection", "Fan Anchor Mode", options=["Current Bar Projection", "Latest Real Event"], group=gUX)
keepPrev = input.bool(false, "Keep Previous Fan", group=gUX)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ①B ORIGINAL SHAPE CONTROLS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
gShape = "①B Original Shape Controls"

driftStrength = input.float(0.42, "Directional Drift", minval=0.0, maxval=1.2, step=0.05, group=gShape)
dispersion = input.float(0.75, "Fan Dispersion", minval=0.2, maxval=2.0, step=0.05, group=gShape)
curveEnergy = input.float(0.65, "Curve Energy", minval=0.0, maxval=2.0, step=0.05, group=gShape)
fanLift = input.float(0.0, "Vertical Lift / Offset", minval=-3.0, maxval=3.0, step=0.1, group=gShape)
visualPathCount = input.int(30, "Visual Swarm Path Count", minval=10, maxval=40, group=gShape)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ② EVENT ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
gEV = "② Event Engine"

eventType = input.string("Composite Event", "Event Type", options=["Volatility Breakout", "Structure Break", "Volume Shock", "Absorption Reversal", "Regime Shift", "Composite Event"], group=gEV)
sens = input.string("Exploratory", "Trigger Sensitivity", options=["Conservative", "Balanced", "Exploratory"], group=gEV)
atrLen = input.int(14, "ATR Length", minval=5, group=gEV)
volLen = input.int(20, "Volume Length", minval=5, group=gEV)
structLb = input.int(20, "Structure Lookback", minval=5, group=gEV)
reqVol = input.bool(false, "Require Volume Confirmation", group=gEV)
minGap = input.int(8, "Minimum Bars Between Events", minval=3, group=gEV)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ③ REAL ANALOG MATCHING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
gAN = "③ Real Analog Matching"

memLb = input.int(1800, "Memory Lookback Bars", minval=300, maxval=2500, group=gAN)
horizon = input.int(30, "Projection Horizon", minval=10, maxval=60, group=gAN)
maxA = input.int(30, "Max Real Analog Paths", minval=5, maxval=30, group=gAN)
minA = input.int(6, "Minimum Analogs Required For Normal Confidence", minval=3, maxval=15, group=gAN)
simThr = input.int(0, "Minimum Match Quality", minval=0, maxval=95, group=gAN)
dirMatch = input.string("Flexible", "Event Direction Matching", options=["Strict", "Flexible"], group=gAN)
typMatch = input.string("Flexible", "Event Type Matching", options=["Strict", "Flexible"], group=gAN)
fallbackClosest = input.bool(true, "Fallback To Closest Real Analogs", group=gAN)
barFallback = input.bool(true, "Fallback To Historical Bar Windows", group=gAN)
mirrorOpp = input.bool(false, "Mirror Opposite Direction Analogs", group=gAN)
shapeN = input.int(6, "Shape Sample Count", options=[4, 6, 8], group=gAN)
preWin = input.int(20, "Pre-Event Shape Window", minval=10, maxval=60, group=gAN)
pathScale = input.float(1.0, "Real Path Move Scale", minval=0.25, maxval=2.0, step=0.05, group=gAN)
engineDrivesBias = input.bool(true, "Engine Drives Fan Bias / Color", group=gAN)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ④ ANALOG QUALITY ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
gALG = "④ Analog Quality Engine"

algoPreset = input.string("Balanced", "Algorithm Preset", options=["Balanced", "Trend", "Volatility", "Reversal", "Crypto"], group=gALG)
regimePenaltyStrength = input.float(0.18, "Regime Mismatch Penalty", minval=0.0, maxval=0.60, step=0.01, group=gALG)
recencyBoost = input.float(0.10, "Recent Analog Boost", minval=0.0, maxval=0.30, step=0.01, group=gALG)
showQualityStats = input.bool(true, "Show Confidence / Agreement Stats", group=gALG)
showSelfTest = input.bool(true, "Show Compact Rolling Self-Test", group=gALG)
selfTestSamples = input.int(18, "Self-Test Samples", minval=0, maxval=40, group=gALG)
selfTestLookback = input.int(720, "Self-Test Lookback Bars", minval=250, maxval=1800, group=gALG)
selfTestAnalogs = input.int(8, "Self-Test Analogs", minval=3, maxval=15, group=gALG)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
color colUp = #22D3EE
color colDn = #EC4899
color colMix = #A78BFA
color colInk = #0B1020
color colText = #E2E8F0
color colWarn = #F59E0B

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_tanh(float x) =>
    e = math.exp(2.0 * math.max(math.min(x, 20.0), -20.0))
    (e - 1.0) / (e + 1.0)

f_dispText(float d) =>
    d < 0.90 ? "Low" : d < 1.80 ? "Med" : "High"

f_biasText(float upFr) =>
    upFr >= 0.60 ? "Up" : upFr <= 0.40 ? "Down" : "Mixed"

f_biasColor(string b) =>
    b == "Up" ? colUp : b == "Down" ? colDn : colMix

f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_featWeight(int idx) =>
    float w = 1.0
    if idx == 0
        w := algoPreset == "Trend" ? 2.00 : 1.60
    else if idx == 1
        w := algoPreset == "Trend" ? 2.20 : 1.70
    else if idx == 2
        w := algoPreset == "Volatility" or algoPreset == "Crypto" ? 2.20 : 1.50
    else if idx == 3
        w := algoPreset == "Volatility" or algoPreset == "Crypto" ? 2.00 : 1.35
    else if idx >= 4 and idx <= 6
        w := algoPreset == "Reversal" ? 1.55 : 1.00
    else if idx == 7 or idx == 8
        w := 1.35
    else if idx == 9
        w := algoPreset == "Trend" ? 1.75 : 1.35
    else if idx == 10 or idx == 11
        w := algoPreset == "Volatility" ? 1.55 : 1.20
    else if idx == 12 or idx == 13
        w := algoPreset == "Crypto" or algoPreset == "Volatility" ? 1.85 : 1.45
    else if idx == 14
        w := algoPreset == "Trend" ? 1.65 : 1.20
    else
        w := algoPreset == "Reversal" ? 1.70 : 1.85
    w

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FEATURE SERIES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
atr = ta.atr(atrLen)
atrFast = ta.atr(5)
atrSlow = ta.atr(50)
tr_ = ta.tr(true)

volAvg = ta.sma(volume, volLen)
volR = volume / math.max(volAvg, 1e-10)
volTr = ta.sma(volume, 5) / math.max(ta.sma(volume, 20), 1e-10)

rng = math.max(high - low, syminfo.mintick)
clv = (close - low) / rng
bodyR = math.abs(close - open) / rng
upWick = high - math.max(close, open)
dnWick = math.min(close, open) - low
wickImb = (upWick - dnWick) / rng

hh = ta.highest(high, structLb)
ll = ta.lowest(low, structLb)

atrPct = ta.percentrank(atr, 100) / 100.0
atrExp = atr / math.max(atr[10], 1e-10)
compr = atrFast / math.max(atrSlow, 1e-10)

[diP, diM, adx] = ta.dmi(14, 14)
slope = ta.linreg(close, preWin, 0) - ta.linreg(close, preWin, 1)

f_regimeCode(int base) =>
    bool trendUp = nz(adx[base], 0) > 20 and nz(diP[base], 0) > nz(diM[base], 0) and nz(slope[base], 0) > 0
    bool trendDn = nz(adx[base], 0) > 20 and nz(diM[base], 0) > nz(diP[base], 0) and nz(slope[base], 0) < 0
    bool compressionReg = nz(compr[base], 1.0) < 0.85
    bool expansionReg = nz(atrExp[base], 1.0) > 1.25 or nz(compr[base], 1.0) > 1.18
    bool shockReg = nz(volR[base], 1.0) > 1.65 and nz(tr_[base], 0) > nz(atr[base], atr) * 0.85
    int out = 0
    out := shockReg ? 5 : expansionReg ? 4 : compressionReg ? 3 : trendUp ? 1 : trendDn ? 2 : 0
    out

f_regimeName(int r) =>
    r == 1 ? "Trend Up" : r == 2 ? "Trend Down" : r == 3 ? "Compression" : r == 4 ? "Vol Expansion" : r == 5 ? "Volume Shock" : "Range/Chop"

f_regimePenalty(int curReg, int histReg) =>
    same = curReg == histReg
    bothTrend = (curReg == 1 or curReg == 2) and (histReg == 1 or histReg == 2)
    same ? 0.0 : bothTrend ? regimePenaltyStrength * 0.55 : regimePenaltyStrength

f_confidenceScore(float avgMatch, float upFr, float dispN, int n, int reg) =>
    agreeScore = math.abs(upFr - 0.5) * 200.0
    dispScore = f_clamp(100.0 - dispN * 36.0, 0.0, 100.0)
    sampleScore = f_clamp(n / math.max(minA * 1.0, 1.0) * 100.0, 0.0, 100.0)
    regimeScore = reg == 0 ? 62.0 : reg == 3 ? 78.0 : reg == 4 or reg == 5 ? 74.0 : 82.0
    f_clamp(avgMatch * 0.30 + agreeScore * 0.25 + dispScore * 0.20 + sampleScore * 0.15 + regimeScore * 0.10, 0.0, 100.0)

f_confLabel(float conf) =>
    conf >= 80 ? "HIGH" : conf >= 62 ? "MED" : "LOW"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRIGGER ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
atrMult = sens == "Conservative" ? 1.80 : sens == "Balanced" ? 1.50 : 1.20
volMult = sens == "Conservative" ? 2.20 : sens == "Balanced" ? 1.80 : 1.35
volOk = not reqVol or volR > 1.15

fVolBO = tr_ > atr * atrMult and (clv > 0.68 or clv < 0.32) and volOk
dVolBO = fVolBO ? clv > 0.68 ? 1 : -1 : 0

brkUp = close > hh[1]
brkDn = close < ll[1]
brkDist = brkUp ? (close - hh[1]) / math.max(atr, syminfo.mintick) : brkDn ? (ll[1] - close) / math.max(atr, syminfo.mintick) : 0.0

fStruct = (brkUp or brkDn) and brkDist > 0.10 and volOk
dStruct = fStruct ? brkUp ? 1 : -1 : 0

fShock = volR > volMult and (tr_ > atr * 0.85 or bodyR > 0.55)
dShock = fShock ? close > open ? 1 : close < open ? -1 : 0 : 0

fAbsorb = volR > volMult * 0.85 and bodyR < 0.38 and (upWick > rng * 0.42 or dnWick > rng * 0.42)
dAbsorb = fAbsorb ? dnWick > upWick ? 1 : -1 : 0

fRegime = (atrExp > 1.35 and compr[3] < 0.90) or (adx - adx[5] > 6 and tr_ > atr * 0.90)
dRegime = fRegime ? close > close[5] ? 1 : -1 : 0

famCnt = (fVolBO ? 1 : 0) + (fStruct ? 1 : 0) + (fShock ? 1 : 0) + (fAbsorb ? 1 : 0) + (fRegime ? 1 : 0)

evtRaw = switch eventType
    "Volatility Breakout" => fVolBO
    "Structure Break" => fStruct
    "Volume Shock" => fShock
    "Absorption Reversal" => fAbsorb
    "Regime Shift" => fRegime
    => famCnt >= 2

domCode = fStruct ? 2 : fVolBO ? 1 : fShock ? 3 : fAbsorb ? 4 : fRegime ? 5 : 0
dirSum = dVolBO + dStruct + dShock + dAbsorb + dRegime
curDir = dirSum > 0 ? 1 : dirSum < 0 ? -1 : 0

var int lastEvBar = na
ready = bar_index > preWin + horizon + 150
gapOk = na(lastEvBar) or bar_index - lastEvBar >= minGap
eventFire = evtRaw and barstate.isconfirmed and ready and gapOk

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EVENT MEMORY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int COLS = 15 + shapeN

var int[] evBars = array.new<int>()
var int[] evDirs = array.new<int>()
var int[] evTypes = array.new<int>()
var float[] evCloses = array.new<float>()
var float[] evATRs = array.new<float>()
var float[] evHighs = array.new<float>()
var float[] evLows = array.new<float>()
var matrix<float> featM = matrix.new<float>(0, COLS)

f_featVec() =>
    arr = array.new<float>()
    denom = math.max(atr * math.sqrt(preWin), syminfo.mintick)
    array.push(arr, f_tanh((close - close[preWin]) / denom))
    array.push(arr, f_tanh(slope / math.max(atr, syminfo.mintick) * 5.0))
    array.push(arr, f_tanh(compr - 1.0))
    array.push(arr, f_tanh(tr_ / math.max(atr, syminfo.mintick) - 1.0))
    array.push(arr, clv * 2.0 - 1.0)
    array.push(arr, bodyR * 2.0 - 1.0)
    array.push(arr, f_tanh(wickImb * 2.0))
    array.push(arr, f_tanh((hh - close) / math.max(atr, syminfo.mintick) * 0.5))
    array.push(arr, f_tanh((close - ll) / math.max(atr, syminfo.mintick) * 0.5))
    array.push(arr, f_tanh(brkDist))
    array.push(arr, f_tanh(volR - 1.0))
    array.push(arr, f_tanh(volTr - 1.0))
    array.push(arr, atrPct * 2.0 - 1.0)
    array.push(arr, f_tanh(atrExp - 1.0))
    array.push(arr, f_tanh(adx / 25.0 - 1.0))
    for k = 1 to shapeN
        idx = int(math.round(preWin * (shapeN - k) / shapeN))
        array.push(arr, f_tanh((close[idx] - close[preWin]) / denom))
    arr

f_barDist(int base, array<float> cur) =>
    sumSq = 0.0
    denom = math.max(nz(atr[base], atr) * math.sqrt(preWin), syminfo.mintick)
    atrDen = math.max(nz(atr[base], atr), syminfo.mintick)

    v0 = f_tanh((nz(close[base], close) - nz(close[base + preWin], close)) / denom)
    sumSq += math.pow(v0 - array.get(cur, 0), 2)
    v1 = f_tanh(nz(slope[base], slope) / atrDen * 5.0)
    sumSq += math.pow(v1 - array.get(cur, 1), 2)
    v2 = f_tanh(nz(compr[base], compr) - 1.0)
    sumSq += math.pow(v2 - array.get(cur, 2), 2)
    v3 = f_tanh(nz(tr_[base], tr_) / atrDen - 1.0)
    sumSq += math.pow(v3 - array.get(cur, 3), 2)
    v4 = nz(clv[base], clv) * 2.0 - 1.0
    sumSq += math.pow(v4 - array.get(cur, 4), 2)
    v5 = nz(bodyR[base], bodyR) * 2.0 - 1.0
    sumSq += math.pow(v5 - array.get(cur, 5), 2)
    v6 = f_tanh(nz(wickImb[base], wickImb) * 2.0)
    sumSq += math.pow(v6 - array.get(cur, 6), 2)
    v7 = f_tanh((nz(hh[base], hh) - nz(close[base], close)) / atrDen * 0.5)
    sumSq += math.pow(v7 - array.get(cur, 7), 2)
    v8 = f_tanh((nz(close[base], close) - nz(ll[base], ll)) / atrDen * 0.5)
    sumSq += math.pow(v8 - array.get(cur, 8), 2)
    v9 = f_tanh(nz(brkDist[base], brkDist))
    sumSq += math.pow(v9 - array.get(cur, 9), 2)
    v10 = f_tanh(nz(volR[base], volR) - 1.0)
    sumSq += math.pow(v10 - array.get(cur, 10), 2)
    v11 = f_tanh(nz(volTr[base], volTr) - 1.0)
    sumSq += math.pow(v11 - array.get(cur, 11), 2)
    v12 = nz(atrPct[base], atrPct) * 2.0 - 1.0
    sumSq += math.pow(v12 - array.get(cur, 12), 2)
    v13 = f_tanh(nz(atrExp[base], atrExp) - 1.0)
    sumSq += math.pow(v13 - array.get(cur, 13), 2)
    v14 = f_tanh(nz(adx[base], adx) / 25.0 - 1.0)
    sumSq += math.pow(v14 - array.get(cur, 14), 2)

    for k = 1 to shapeN
        c = 14 + k
        idx = int(math.round(preWin * (shapeN - k) / shapeN))
        v = f_tanh((nz(close[base + idx], close) - nz(close[base + preWin], close)) / denom)
        sumSq += math.pow(v - array.get(cur, c), 2)

    math.sqrt(sumSq / math.max(COLS * 1.0, 1.0))

f_featAt(int base) =>
    arr = array.new<float>()
    if na(close[base]) or na(close[base + preWin]) or na(atr[base])
        arr
    else
        atrVal = math.max(nz(atr[base], atr), syminfo.mintick)
        denom = math.max(atrVal * math.sqrt(preWin), syminfo.mintick)
        array.push(arr, f_tanh((nz(close[base], close) - nz(close[base + preWin], close)) / denom))
        array.push(arr, f_tanh(nz(slope[base], slope) / atrVal * 5.0))
        array.push(arr, f_tanh(nz(compr[base], compr) - 1.0))
        array.push(arr, f_tanh(nz(tr_[base], tr_) / atrVal - 1.0))
        array.push(arr, nz(clv[base], clv) * 2.0 - 1.0)
        array.push(arr, nz(bodyR[base], bodyR) * 2.0 - 1.0)
        array.push(arr, f_tanh(nz(wickImb[base], wickImb) * 2.0))
        array.push(arr, f_tanh((nz(hh[base], hh) - nz(close[base], close)) / atrVal * 0.5))
        array.push(arr, f_tanh((nz(close[base], close) - nz(ll[base], ll)) / atrVal * 0.5))
        array.push(arr, f_tanh(nz(brkDist[base], brkDist)))
        array.push(arr, f_tanh(nz(volR[base], volR) - 1.0))
        array.push(arr, f_tanh(nz(volTr[base], volTr) - 1.0))
        array.push(arr, nz(atrPct[base], atrPct) * 2.0 - 1.0)
        array.push(arr, f_tanh(nz(atrExp[base], atrExp) - 1.0))
        array.push(arr, f_tanh(nz(adx[base], adx) / 25.0 - 1.0))
        for k = 1 to shapeN
            idx = int(math.round(preWin * (shapeN - k) / shapeN))
            array.push(arr, f_tanh((nz(close[base + idx], close) - nz(close[base + preWin], close)) / denom))
        arr

f_barDistWeighted(int base, array<float> cur, int curRegime) =>
    hist = f_featAt(base)
    if array.size(hist) != array.size(cur) or array.size(hist) == 0
        999.0
    else
        sumSqW = 0.0
        totalW = 0.0
        for c = 0 to array.size(cur) - 1
            w = f_featWeight(c)
            d = array.get(hist, c) - array.get(cur, c)
            sumSqW += w * d * d
            totalW += w
        baseDist = math.sqrt(sumSqW / math.max(totalW, 1e-10))
        baseDist + f_regimePenalty(curRegime, f_regimeCode(base))

f_matrixDistWeighted(int row, array<float> cur, int curRegime, int histBase) =>
    if array.size(cur) == 0
        999.0
    else
        sumSqW = 0.0
        totalW = 0.0
        for c = 0 to COLS - 1
            w = f_featWeight(c)
            d = matrix.get(featM, row, c) - array.get(cur, c)
            sumSqW += w * d * d
            totalW += w
        math.sqrt(sumSqW / math.max(totalW, 1e-10)) + f_regimePenalty(curRegime, f_regimeCode(histBase))

if barstate.isconfirmed
    while array.size(evBars) > 0 and (bar_index - array.get(evBars, 0) > memLb or array.size(evBars) > 500)
        array.shift(evBars)
        array.shift(evDirs)
        array.shift(evTypes)
        array.shift(evCloses)
        array.shift(evATRs)
        array.shift(evHighs)
        array.shift(evLows)
        matrix.remove_row(featM, 0)

if eventFire
    array.push(evBars, bar_index)
    array.push(evDirs, curDir)
    array.push(evTypes, domCode)
    array.push(evCloses, close)
    array.push(evATRs, atr)
    array.push(evHighs, high)
    array.push(evLows, low)
    matrix.add_row(featM, matrix.rows(featM), f_featVec())
    lastEvBar := bar_index

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OBJECT MANAGEMENT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var polyline[] curP = array.new<polyline>()
var polyline[] prevP = array.new<polyline>()
var line[] curL = array.new<line>()
var line[] prevL = array.new<line>()
var label[] curLb = array.new<label>()
var label[] prevLb = array.new<label>()

f_clear(polyline[] ps, line[] ls, label[] lbs) =>
    for p in ps
        polyline.delete(p)
    for l in ls
        line.delete(l)
    for lb in lbs
        label.delete(lb)
    array.clear(ps)
    array.clear(ls)
    array.clear(lbs)

f_rotate() =>
    f_clear(prevP, prevL, prevLb)
    if keepPrev
        for p in curP
            array.push(prevP, p)
        for l in curL
            array.push(prevL, l)
        for lb in curLb
            array.push(prevLb, lb)
        array.clear(curP)
        array.clear(curL)
        array.clear(curLb)
    else
        f_clear(curP, curL, curLb)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISUAL HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_rail(int evX, float y0, array<float> vals, int h, color col, int w) =>
    pts = array.new<chart.point>()
    array.push(pts, chart.point.from_index(evX, y0))
    for j = 1 to h
        array.push(pts, chart.point.from_index(evX + j, array.get(vals, j - 1)))
    array.push(curP, polyline.new(pts, curved=curvedLines, closed=false, xloc=xloc.bar_index, line_color=col, line_width=w))

f_path(int evX, float y0, matrix<float> pm, int row, int h, color col, int w) =>
    vals = matrix.row(pm, row)
    f_rail(evX, y0, vals, h, col, w)

f_rand(float seed) =>
    v = math.sin(seed * 12.9898 + 78.233) * 43758.5453
    v - math.floor(v)

f_paths(int n, int h, float anchor, float a, float bDir) =>
    pm = matrix.new<float>(n, h)
    for i = 0 to n - 1
        rankBias = 1.0 - i / math.max(n - 1.0, 1.0)
        seed = i + 1.0
        localDrift = bDir * driftStrength * (0.55 + f_rand(seed + 5) * 0.9)
        localDisp = dispersion * (0.45 + f_rand(seed + 11) * 1.35) * (1.15 - rankBias * 0.25)
        freq1 = 0.14 + f_rand(seed + 17) * 0.22
        freq2 = 0.33 + f_rand(seed + 29) * 0.36
        ph1 = f_rand(seed + 37) * math.pi * 2.0
        ph2 = f_rand(seed + 43) * math.pi * 2.0
        bow = (f_rand(seed + 53) - 0.5) * curveEnergy
        for j = 1 to h
            t = j / h
            sqrtT = math.sqrt(j)
            drift = localDrift * j * 0.34
            wave1 = math.sin(j * freq1 + ph1) * localDisp * sqrtT * 0.34
            wave2 = math.sin(j * freq2 + ph2) * localDisp * sqrtT * 0.16
            arc = bow * (t - 0.5) * (t - 0.5) * j * 0.20
            mixedPull = bDir == 0.0 ? (f_rand(seed + 71) - 0.5) * j * 0.10 : 0.0
            y = anchor + a * (fanLift + drift + wave1 + wave2 + arc + mixedPull)
            matrix.set(pm, i, j - 1, y)
    pm

f_pct(matrix<float> pm, int q, int h) =>
    out = array.new<float>()
    for j = 0 to h - 1
        c = matrix.col(pm, j)
        array.push(out, array.percentile_nearest_rank(c, q))
    out

f_avgAbsGap(array<float> a, array<float> b, int h) =>
    gapSum = 0.0
    for j = 0 to h - 1
        gapSum += math.abs(array.get(a, j) - array.get(b, j))
    gapSum / math.max(h * 1.0, 1.0)

f_weightedMeanPath(matrix<float> pm, array<float> scores, int h) =>
    out = array.new<float>()
    rows = matrix.rows(pm)
    for j = 0 to h - 1
        num = 0.0
        den = 0.0
        for r = 0 to rows - 1
            score = r < array.size(scores) ? array.get(scores, r) : 50.0
            wt = math.pow(math.max(score, 1.0) / 100.0, 2.0)
            num += matrix.get(pm, r, j) * wt
            den += wt
        array.push(out, den > 0 ? num / den : matrix.get(pm, 0, j))
    out

f_edgeState(float conf, float agreementPct, string dispTxt, string regTxt) =>
    agreeEdge = math.abs(agreementPct - 50.0)
    chopRisk = regTxt == "Range/Chop"
    conf >= 80 and agreeEdge >= 20 and dispTxt != "High" and not chopRisk ? "TRADEABLE" : conf >= 65 and agreeEdge >= 12 and dispTxt != "High" ? "CAUTION" : "NO EDGE"

f_selfTest(int samples, int lookbackBars, int h, int maxSelfAnalogs) =>
    float hitPct = na
    float containPct = na
    float avgErr = na
    if samples > 0 and lookbackBars > h + preWin + minGap + 30
        int tests = 0
        int hits = 0
        int contains = 0
        float errSum = 0.0
        int step = math.max(1, int(math.floor(lookbackBars / math.max(samples, 1))))
        for t = h + preWin + minGap to lookbackBars by step
            if t + preWin > 2999 or t - h < 0
                continue
            anchorVec = f_featAt(t)
            if array.size(anchorVec) != COLS
                continue
            anchorReg = f_regimeCode(t)
            candBases = array.new<int>()
            candScores = array.new<float>()
            maxOlder = math.min(memLb, 2999 - t - preWin)
            if maxOlder < h + minGap
                continue
            for older = h + minGap to maxOlder
                cb = t + older
                if cb + preWin > 2999 or cb - h < 0
                    continue
                dist = f_barDistWeighted(cb, anchorVec, anchorReg)
                if dist < 999.0
                    score = 100.0 * math.exp(-dist)
                    array.push(candBases, cb)
                    array.push(candScores, score)
            pickN = math.min(maxSelfAnalogs, array.size(candBases))
            if pickN < 3
                continue
            float wSum = 0.0
            float predMove = 0.0
            float minMove = 1e10
            float maxMove = -1e10
            for k = 1 to pickN
                best = -1.0
                bi = -1
                for i = 0 to array.size(candScores) - 1
                    v = array.get(candScores, i)
                    if v > best
                        best := v
                        bi := i
                if bi >= 0
                    cb = array.get(candBases, bi)
                    scl = math.max(0.5, math.min(2.0, nz(atr[t], atr) / math.max(nz(atr[cb], atr), syminfo.mintick)))
                    mv = (close[cb - h] - close[cb]) * scl
                    wt = math.max(best, 1e-6)
                    predMove += mv * wt
                    wSum += wt
                    minMove := math.min(minMove, mv)
                    maxMove := math.max(maxMove, mv)
                    array.set(candScores, bi, -1.0)
            if wSum <= 0
                continue
            predMove := predMove / wSum
            actualMove = close[t - h] - close[t]
            if predMove * actualMove > 0
                hits += 1
            if actualMove >= minMove and actualMove <= maxMove
                contains += 1
            errSum += math.abs(predMove - actualMove) / math.max(nz(atr[t], atr), syminfo.mintick)
            tests += 1
        if tests > 0
            hitPct := hits / tests * 100.0
            containPct := contains / tests * 100.0
            avgErr := errSum / tests
    [hitPct, containPct, avgErr]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RENDERER — VISUAL-FIRST, REAL OVERLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_renderOriginalFan(int evX, float anchor, float anchorATR, float evHi, float evLo, matrix<float> pm, matrix<float> realPm, int drawN, int statN, float avgM, string dispTxt, string biasTxt, color biasCol, int H, float agreementPct, float confidenceScore, string regimeTxt, float selfHitPct, float selfContainPct, float selfErrATR, array<float> consensusOverride) =>
    p10 = f_pct(pm, 10, H)
    p20 = f_pct(pm, 20, H)
    p25 = f_pct(pm, 25, H)
    p30 = f_pct(pm, 30, H)
    p40 = f_pct(pm, 40, H)
    p45 = f_pct(pm, 45, H)
    med = f_pct(pm, 50, H)
    p55 = f_pct(pm, 55, H)
    p60 = f_pct(pm, 60, H)
    p70 = f_pct(pm, 70, H)
    p75 = f_pct(pm, 75, H)
    p80 = f_pct(pm, 80, H)
    p90 = f_pct(pm, 90, H)

    isMinLocal = visMode == "Minimal"
    isCinLocal = visMode == "Cinematic"

    array.push(curL, line.new(evX, evLo - anchorATR * 0.65, evX, evHi + anchorATR * 0.65, color=color.new(biasCol, 25), style=line.style_dotted, width=1))

    if showEventLabel
        array.push(curLb, label.new(evX, evLo - anchorATR * 0.9, "EVENT", style=label.style_label_up, color=color.new(biasCol, 20), textcolor=colInk, size=size.tiny))

    useSwarm = showAnalogPaths and not isMinLocal and fanStyle != "Ribbon Core"
    if useSwarm
        int showN = fanStyle == "Swarm Only" ? drawN : isCinLocal ? math.min(drawN, 30) : math.min(drawN, 14)
        for i = 0 to showN - 1
            transp = isCinLocal ? 68 + int(23.0 * i / math.max(showN - 1, 1)) : 78 + int(15.0 * i / math.max(showN - 1, 1))
            widthP = isCinLocal and i < 3 ? 2 : 1
            f_path(evX, anchor, pm, i, H, color.new(biasCol, transp), widthP)

    realRows = matrix.rows(realPm)

    useRibbon = showRibbonCore and (isCinLocal or fanStyle == "Ribbon Core" or fanStyle == "Hybrid Swarm + Contours")
    if useRibbon and not isMinLocal
        f_rail(evX, anchor, p45, H, color.new(biasCol, 90), isCinLocal ? 9 : 6)
        f_rail(evX, anchor, p55, H, color.new(biasCol, 90), isCinLocal ? 9 : 6)
        f_rail(evX, anchor, p40, H, color.new(biasCol, 92), isCinLocal ? 6 : 4)
        f_rail(evX, anchor, p60, H, color.new(biasCol, 92), isCinLocal ? 6 : 4)

    if showContourRails and fanStyle != "Swarm Only"
        if isMinLocal
            f_rail(evX, anchor, p25, H, color.new(biasCol, 70), 1)
            f_rail(evX, anchor, p75, H, color.new(biasCol, 70), 1)
        else
            f_rail(evX, anchor, p10, H, color.new(biasCol, 88), 1)
            f_rail(evX, anchor, p90, H, color.new(biasCol, 88), 1)
            if isCinLocal or fanStyle == "Clean Scientific"
                f_rail(evX, anchor, p20, H, color.new(biasCol, 82), 1)
                f_rail(evX, anchor, p80, H, color.new(biasCol, 82), 1)
            f_rail(evX, anchor, p25, H, color.new(biasCol, 72), 1)
            f_rail(evX, anchor, p75, H, color.new(biasCol, 72), 1)
            if isCinLocal or fanStyle == "Clean Scientific"
                f_rail(evX, anchor, p30, H, color.new(biasCol, 64), 1)
                f_rail(evX, anchor, p70, H, color.new(biasCol, 64), 1)
            f_rail(evX, anchor, p40, H, color.new(biasCol, 48), 1)
            f_rail(evX, anchor, p60, H, color.new(biasCol, 48), 1)

    if fanStyle == "Swarm Only" and not isMinLocal
        f_rail(evX, anchor, p25, H, color.new(biasCol, 70), 1)
        f_rail(evX, anchor, p75, H, color.new(biasCol, 70), 1)
        f_rail(evX, anchor, p10, H, color.new(biasCol, 88), 1)
        f_rail(evX, anchor, p90, H, color.new(biasCol, 88), 1)

    if showRawAnalogOverlay and realRows > 0
        realDrawN = math.min(realRows, maxRawOverlayPaths)
        for r = 0 to realDrawN - 1
            realVals = matrix.row(realPm, r)
            f_rail(evX, anchor, realVals, H, color.new(color.white, rawAnalogTransparency), rawAnalogWidth)

    array<float> consensusMed = med
    if realRows > 0
        realMedian = f_pct(realPm, 50, H)
        consensusMed := consensusMode == "Weighted Average" and array.size(consensusOverride) == H ? consensusOverride : realMedian
    string consensusLabel = realRows > 0 ? (consensusMode == "Weighted Average" ? "WEIGHTED CONSENSUS" : "CONSENSUS") : "VISUAL MEDIAN"

    if isCinLocal
        f_rail(evX, anchor, consensusMed, H, color.new(biasCol, 88), 10)
        f_rail(evX, anchor, consensusMed, H, color.new(biasCol, 75), 5)
    f_rail(evX, anchor, consensusMed, H, color.new(biasCol, 0), 3)

    if showWhiteHistoricalPath and realRows > 0
        array<float> bestVals = matrix.row(realPm, 0)
        if whitePathSource == "Best Visible Analog"
            minGap = anchorATR * whiteMinSeparationATR
            scanN = math.min(realRows, 8)
            foundVisible = false
            for r = 0 to scanN - 1
                vals = matrix.row(realPm, r)
                gap = f_avgAbsGap(vals, consensusMed, H)
                if not foundVisible and gap >= minGap
                    bestVals := vals
                    foundVisible := true
        f_rail(evX, anchor, bestVals, H, color.new(color.white, whiteHistoricalTransparency), whiteHistoricalWidth)

    finalMed = array.get(consensusMed, H - 1)
    finalP75 = array.get(p75, H - 1)

    array.push(curLb, label.new(evX + H, finalMed, consensusLabel, style=label.style_label_left, color=color.new(biasCol, 15), textcolor=colInk, size=size.tiny))

    if showStats
        edgeTxt = f_edgeState(confidenceScore, agreementPct, dispTxt, regimeTxt)
        qualityTxt = showQualityStats and statN > 0 ? "\nAgree " + str.tostring(agreementPct, "#") + "%" + "\nConf " + str.tostring(confidenceScore, "#") + " " + f_confLabel(confidenceScore) + "\nEdge " + edgeTxt + "\nReg " + regimeTxt : ""
        testTxt = showSelfTest and not na(selfHitPct) ? "\nHit " + str.tostring(selfHitPct, "#") + "%" + " / InFan " + str.tostring(selfContainPct, "#") + "%" + "\nErr " + str.tostring(selfErrATR, "#.##") + " ATR" : ""
        statTxt = statN > 0 ? "N=" + str.tostring(statN) + "\nMatch " + str.tostring(avgM, "#") + "\nDisp " + dispTxt + "\nBias " + biasTxt + qualityTxt + testTxt + "\n" + str.tostring(H) + " bars" : "N=0\nMatch n/a\nDisp visual\nBias " + biasTxt + "\nVisual Only" + testTxt + "\n" + str.tostring(H) + " bars"
        array.push(curLb, label.new(evX + H + 2, finalP75, statTxt, style=label.style_label_left, color=color.new(colInk, 12), textcolor=colText, size=size.small))

    if showForwardTag
        array.push(curLb, label.new(evX + 2, evHi + anchorATR * 1.0, "FORWARD ANALOG FAN", style=label.style_label_left, color=color.new(biasCol, 88), textcolor=color.new(colText, 15), size=size.tiny))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LAST-BAR RENDER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool projAvailable = false
bool notEnough = false
bool highAgree = false
bool wideDisp = false

if barstate.islast
    f_rotate()

    nEvAll = array.size(evBars)
    useLatestMode = anchorMode == "Latest Real Event" and nEvAll > 0

    int evX = bar_index
    float anchor = close
    float anchorATR = math.max(atr, syminfo.mintick)
    float evHi = high
    float evLo = low

    if useLatestMode
        latestIdx = nEvAll - 1
        evX := array.get(evBars, latestIdx)
        anchor := array.get(evCloses, latestIdx)
        anchorATR := math.max(array.get(evATRs, latestIdx), syminfo.mintick)
        evHi := array.get(evHighs, latestIdx)
        evLo := array.get(evLows, latestIdx)

    targetBack = bar_index - evX
    int latestDir = useLatestMode ? array.get(evDirs, nEvAll - 1) : close > close[preWin] ? 1 : close < close[preWin] ? -1 : 0
    int latestTyp = useLatestMode ? array.get(evTypes, nEvAll - 1) : 0
    array<float> curFeat = f_featVec()
    if useLatestMode
        curFeat := matrix.row(featM, nEvAll - 1)

    anchorRegime = f_regimeCode(targetBack)
    string regimeTxt = f_regimeName(anchorRegime)
    float agreementPct = na
    float confidenceScore = 0.0
    [selfHitPct, selfContainPct, selfErrATR] = f_selfTest(showSelfTest ? selfTestSamples : 0, selfTestLookback, horizon, selfTestAnalogs)

    visualBiasDir = latestDir > 0 ? 1.0 : latestDir < 0 ? -1.0 : 0.0
    visualBiasCol = latestDir > 0 ? colUp : latestDir < 0 ? colDn : colMix
    biasTxt = latestDir > 0 ? "Up" : latestDir < 0 ? "Down" : "Mixed"
    avgM = 0.0
    dispTxt = dispersion < 0.6 ? "Low" : dispersion < 1.2 ? "Med" : "High"
    statN = 0
    matrix<float> drawRealPm = matrix.new<float>(0, horizon)
    array<float> consensusPath = array.new<float>()

    // 1) Event-memory search when anchoring to latest event.
    if useLatestMode and nEvAll > 1
        candIdx = array.new<int>()
        candM = array.new<float>()
        allIdx = array.new<int>()
        allM = array.new<float>()
        latestIdx = nEvAll - 1

        for i = 0 to latestIdx - 1
            aBar = array.get(evBars, i)
            ageFromAnchor = evX - aBar
            if ageFromAnchor < horizon + minGap or ageFromAnchor > memLb
                continue
            aDir = array.get(evDirs, i)
            aTyp = array.get(evTypes, i)
            if dirMatch == "Strict" and latestDir != 0 and aDir != latestDir
                continue
            if typMatch == "Strict" and aTyp != latestTyp
                continue

            histBase = bar_index - aBar
            dist = f_matrixDistWeighted(i, curFeat, anchorRegime, histBase)
            dirPen = aDir != latestDir ? 0.35 : 0.0
            typPen = aTyp != latestTyp ? 0.15 : 0.0
            recencyFactor = 1.0 + recencyBoost * (1.0 - math.min(ageFromAnchor / math.max(memLb * 1.0, 1.0), 1.0))
            match = math.min(100.0, 100.0 * math.exp(-(dist + dirPen + typPen)) * recencyFactor)
            array.push(allIdx, i)
            array.push(allM, match)
            if match >= simThr
                array.push(candIdx, i)
                array.push(candM, match)

        useIdx = array.copy(candIdx)
        useM = array.copy(candM)
        if fallbackClosest and array.size(useIdx) < minA and array.size(allIdx) > 0
            useIdx := array.copy(allIdx)
            useM := array.copy(allM)

        K = math.min(maxA, array.size(useIdx))
        pickIdx = array.new<int>()
        pickM = array.new<float>()
        if K > 0
            for k = 1 to K
                best = -1.0
                bi = -1
                for i = 0 to array.size(useM) - 1
                    v = array.get(useM, i)
                    if v > best
                        best := v
                        bi := i
                if bi >= 0
                    array.push(pickIdx, array.get(useIdx, bi))
                    array.push(pickM, best)
                    array.set(useM, bi, -1.0)

        realN = array.size(pickIdx)
        if realN > 0
            projAvailable := true
            statN := realN
            realPm = matrix.new<float>(realN, horizon)
            drawRealPm := realPm
            upFinal = 0
            for a = 0 to realN - 1
                i = array.get(pickIdx, a)
                aBar = array.get(evBars, i)
                aClose = array.get(evCloses, i)
                aATR = math.max(array.get(evATRs, i), syminfo.mintick)
                aDir = array.get(evDirs, i)
                flip = mirrorOpp and latestDir != 0 and aDir == -latestDir ? -1.0 : 1.0
                scl = math.max(0.5, math.min(2.0, anchorATR / aATR))
                base = bar_index - aBar
                for j = 1 to horizon
                    histForward = close[base - j] - aClose
                    projected = anchor + flip * histForward * scl * pathScale
                    matrix.set(realPm, a, j - 1, projected)
                if matrix.get(realPm, a, horizon - 1) > anchor
                    upFinal += 1
            avgM := array.avg(pickM)
            consensusPath := f_weightedMeanPath(realPm, pickM, horizon)
            realP10 = f_pct(realPm, 10, horizon)
            realP90 = f_pct(realPm, 90, horizon)
            dispN = (array.get(realP90, horizon - 1) - array.get(realP10, horizon - 1)) / math.max(anchorATR * math.sqrt(horizon), syminfo.mintick)
            dispTxt := f_dispText(dispN)
            upFr = upFinal / math.max(realN * 1.0, 1.0)
            agreementPct := upFr * 100.0
            confidenceScore := f_confidenceScore(avgM, upFr, dispN, realN, anchorRegime)
            engineBiasTxt = f_biasText(upFr)
            if engineDrivesBias
                biasTxt := engineBiasTxt
                visualBiasDir := engineBiasTxt == "Up" ? 1.0 : engineBiasTxt == "Down" ? -1.0 : 0.0
                visualBiasCol := f_biasColor(engineBiasTxt)
            highAgree := dispTxt == "Low" and avgM >= 75
            wideDisp := dispTxt == "High"

    // 2) Bar-window fallback. This runs in current-bar mode and also when event-memory has no real rows.
    if matrix.rows(drawRealPm) == 0 and barFallback
        fbBars = array.new<int>()
        fbM = array.new<float>()
        anchorBack = targetBack
        maxAgeRaw = math.min(memLb, evX - preWin - 1)
        maxAgeByBarsBack = 2999 - anchorBack - preWin
        maxAge = math.min(maxAgeRaw, maxAgeByBarsBack)

        if maxAge >= horizon + minGap
            for age = horizon + minGap to maxAge
                aBar = evX - age
                base = bar_index - aBar
                if base < horizon or base + preWin > 2999
                    continue
                dist = f_barDistWeighted(base, curFeat, anchorRegime)
                recencyFactor = 1.0 + recencyBoost * (1.0 - math.min(age / math.max(maxAge * 1.0, 1.0), 1.0))
                match = math.min(100.0, 100.0 * math.exp(-dist) * recencyFactor)
                if match >= simThr or fallbackClosest
                    array.push(fbBars, aBar)
                    array.push(fbM, match)

        fbK = math.min(maxA, array.size(fbBars))
        pickBars = array.new<int>()
        pickFbM = array.new<float>()
        if fbK > 0
            for k = 1 to fbK
                best = -1.0
                bi = -1
                for i = 0 to array.size(fbM) - 1
                    v = array.get(fbM, i)
                    if v > best
                        best := v
                        bi := i
                if bi >= 0
                    array.push(pickBars, array.get(fbBars, bi))
                    array.push(pickFbM, best)
                    array.set(fbM, bi, -1.0)

        fbN = array.size(pickBars)
        if fbN > 0
            projAvailable := true
            statN := fbN
            realPm = matrix.new<float>(fbN, horizon)
            drawRealPm := realPm
            upFinal = 0
            for a = 0 to fbN - 1
                aBar = array.get(pickBars, a)
                base = bar_index - aBar
                aClose = close[base]
                aATR = math.max(atr[base], syminfo.mintick)
                aDir = close[base] > close[base + preWin] ? 1 : close[base] < close[base + preWin] ? -1 : 0
                flip = mirrorOpp and latestDir != 0 and aDir == -latestDir ? -1.0 : 1.0
                scl = math.max(0.5, math.min(2.0, anchorATR / aATR))
                for j = 1 to horizon
                    histForward = close[base - j] - aClose
                    projected = anchor + flip * histForward * scl * pathScale
                    matrix.set(realPm, a, j - 1, projected)
                if matrix.get(realPm, a, horizon - 1) > anchor
                    upFinal += 1
            avgM := array.avg(pickFbM)
            consensusPath := f_weightedMeanPath(realPm, pickFbM, horizon)
            realP10 = f_pct(realPm, 10, horizon)
            realP90 = f_pct(realPm, 90, horizon)
            dispN = (array.get(realP90, horizon - 1) - array.get(realP10, horizon - 1)) / math.max(anchorATR * math.sqrt(horizon), syminfo.mintick)
            dispTxt := f_dispText(dispN)
            upFr = upFinal / math.max(fbN * 1.0, 1.0)
            agreementPct := upFr * 100.0
            confidenceScore := f_confidenceScore(avgM, upFr, dispN, fbN, anchorRegime)
            engineBiasTxt = f_biasText(upFr)
            if engineDrivesBias
                biasTxt := engineBiasTxt
                visualBiasDir := engineBiasTxt == "Up" ? 1.0 : engineBiasTxt == "Down" ? -1.0 : 0.0
                visualBiasCol := f_biasColor(engineBiasTxt)
            highAgree := dispTxt == "Low" and avgM >= 75
            wideDisp := dispTxt == "High"
        else
            notEnough := true

    nPaths = visMode == "Minimal" ? 10 : visMode == "Standard" ? math.min(visualPathCount, 18) : visualPathCount
    pm = f_paths(nPaths, horizon, anchor, anchorATR, visualBiasDir)
    f_renderOriginalFan(evX, anchor, anchorATR, evHi, evLo, pm, drawRealPm, nPaths, statN, avgM, dispTxt, biasTxt, visualBiasCol, horizon, nz(agreementPct, 0), confidenceScore, regimeTxt, selfHitPct, selfContainPct, selfErrATR, consensusPath)

histDotDir = curDir != 0 ? curDir : close > close[preWin] ? 1 : close < close[preWin] ? -1 : 0
plotshape(showHistoricalEvents and eventFire and histDotDir > 0, "Bullish Historical Projection Dot", style=shape.circle, location=location.belowbar, color=color.new(colUp, 0), size=size.tiny)
plotshape(showHistoricalEvents and eventFire and histDotDir < 0, "Bearish Historical Projection Dot", style=shape.circle, location=location.abovebar, color=color.new(colDn, 0), size=size.tiny)
plotshape(showHistoricalEvents and eventFire and histDotDir == 0, "Mixed Historical Projection Dot", style=shape.circle, location=location.belowbar, color=color.new(colMix, 0), size=size.tiny)

alertcondition(barstate.isconfirmed and eventFire, "New Event Detected", "Zen Horizon: new confirmed event detected on {{ticker}}.")
alertcondition(barstate.islast and projAvailable, "Projection Available", "Zen Horizon: real-guided analog fan available on {{ticker}}.")
alertcondition(barstate.islast and notEnough, "Not Enough Real Analogs", "Zen Horizon: not enough real historical analogs on {{ticker}}.")
alertcondition(barstate.islast and highAgree, "High Agreement Projection", "Zen Horizon: high-agreement real-guided fan on {{ticker}}.")
alertcondition(barstate.islast and wideDisp, "Wide Dispersion / Low Confidence", "Zen Horizon: wide dispersion after latest event on {{ticker}}.")
````
