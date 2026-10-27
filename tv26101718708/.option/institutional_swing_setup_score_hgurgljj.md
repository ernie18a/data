# Institutional Swing Setup Score

- url: https://www.tradingview.com/script/hgUrglJj-Institutional-Swing-Setup-Score/
- type: indicator
- pine_id: PUB;95e809395ae44bbc8fbd54107024cecf
- version: 1.0

## Description

Institutional Swing Setup Score — User Manual
1. What This Indicator Does
The Institutional Swing Setup Score (ISS Score) evaluates the quality of a potential long swing trading setup on US equities — the way an experienced institutional trader reads a chart: trend health, relative strength, price structure, volatility contraction, volume/accumulation behavior, and breakout readiness.
It does NOT:

Generate automated buy/sell signals
Recommend stop-loss or profit targets
Manage positions or calculate position sizing
Replace your own judgment

It's a screening and analysis tool — it tells you how good a setup looks, not what to do about it.

2. Adding It to Your Chart

Open the Pine Editor, paste the script, click Add to Chart
It creates two things:

A sub-pane below the price chart showing the Composite Score line (0–100) with reference bands
A dashboard table overlaid directly on the price chart (top-right by default)




3. Reading the Composite Score (0–100)
ScoreMeaningColor80–100Exceptional setupGreen60–79Good setupLime40–59Average / developingYellow20–39WeakOrange0–19Very weakRed
Watch the trajectory of this line as much as the absolute number — a rising score often matters more than a single day's reading.

4. Reading the Dashboard (on the price chart)
RowWhat It Tells YouInstitutional Setup ScoreThe overall composite scoreTrend QualityLong-term trend health (MA alignment, slope, position in 52-week range)Relative StrengthLeadership vs. the benchmark (default SPY)Price StructureBase tightness, compression near highs, higher lowsVolatility ContractionIs volatility squeezing (a pre-breakout signature)?Volume QualityVolume dry-up, demand/supply, accumulation, breakout thrustInstitutional AccumulationYes/No — is the Accumulation/Distribution line trending up?Breakout ReadinessComposite estimate of proximity to a high-quality breakoutHigher-Low CountConfirmed rising pivot lows in the current baseBreakout ConfirmedYes/No — fresh high + volume thrust + trend + RS all aligned

5. Setting Up Alerts
Click the clock/alarm icon → Condition → select "Institutional Swing Setup Score" → choose one:

Setup Score Above Threshold — composite crosses your chosen level
Significant Setup Improvement — score jumped meaningfully in 5 bars
New Institutional Accumulation Phase — A/D line turns up
Exceptional Volume Behaviour — volume score crosses a high threshold
Breakout Readiness High Confidence — breakout score crosses a high threshold
Breakout Confirmed With Volume — fresh high + real volume + trend + RS align

All alerts are informational ("worth a look") — none instruct you to trade.

6. Optional Testing/Calibration Markers
Under Testing / Calibration (NOT trade advice) in Settings:

Show Score-Based Test Markers (on by default) — plots triangles/labels directly on price:

🔺 Lime triangle = score crossed above your "entry" threshold
🔻 Red triangle = score crossed below your "exit" threshold
B = breakout confirmed


These exist purely to help you visually backtest the scoring engine against price history. They are not recommendations.


7. Key Settings You'll Likely Adjust
SettingWherePurposeBenchmark SymbolGeneral & BenchmarkChange from SPY to a sector ETF if preferredComposite Scoring WeightsComposite Scoring WeightsRebalance how much each engine counts (Volume is highest by default)Dashboard Position/SizeDashboardMove/resize the on-chart tableAlert thresholdsAlertsTune sensitivityTest marker thresholdsTesting/CalibrationLoosen/tighten for backtesting visibility

8. How to Use It in Practice

Scan watchlists for stocks with a rising composite score, not just a high one
Check Trend Quality and Relative Strength first — these often move early
Use Breakout Confirmed = Yes as a "this deserves a closer look" flag
Treat the score as one input into your own discretionary analysis — always combine with your own risk management, entries, and exits


9. Important Limitations

Built for clean, orderly bases (tight ranges, contracting volatility). Choppier or news-driven moves may score lower even when the eventual move is large — this is intentional selectivity ("quality over quantity"), not a bug.
Volatility/Structure scores will naturally dip during an active breakout, since range and volatility expand as price moves — that's expected behavior, not malfunction.

10. Symbols & Markers Reference
Add this section to the manual (fits after Section 6):
On the Price Chart (Main Pane)
Symbol  Appearance  Location Meaning Triggered By
🔺 Triangle UpLime/green, smallBelow the bar"Test Entry" — score crossed above your entry thresholdComposite Score crosses above Test Entry Score (default 60)
🔻 Triangle DownRed, smallAbove the bar"Test Exit" — score crossed below your exit thresholdComposite Score crosses below Test Exit Score (default 40)
B   Orange letter, smallBelow the barBreakout Confirmed — fresh high + volume thrust + trend + RS all aligned same day


Disclaimer: This indicator is for educational and analytical purposes only. It is not financial advice, and Claude/Anthropic is not a licensed financial advisor. Always do your own research and risk management.Add the details on the symbols generated by the indicator.Architected comprehensive reference guide documenting visual indicators and symbolsArchitected comprehensive reference guide documenting visual indicators and symbolsSymbols & Markers Referen

## Source Code

````pine
// © Institutional Swing Setup Score — Educational / analytical tool
// This script does NOT generate buy/sell signals, stops, targets, or position sizing.
// It scores the QUALITY of a potential long swing setup on US equities, the way an
// experienced institutional swing trader would read a chart: trend, relative strength,
// price structure, volatility contraction, volume/accumulation behaviour, and breakout
// readiness — combined into a single transparent, configurable composite score.
//@version=6
indicator("Institutional Swing Setup Score", shorttitle = "ISS Score", overlay = false, max_bars_back = 500)

// =====================================================================================
// SECTION 0 — GENERAL / BENCHMARK INPUTS
// =====================================================================================
grpGeneral = "General & Benchmark"
benchSymbol   = input.symbol("SPY", "Benchmark Symbol (Relative Strength)", group = grpGeneral)
tightnessRef  = input.float(1.0, "Global Tightness Sensitivity", minval = 0.1, maxval = 5.0, step = 0.1,
     tooltip = "Higher values make the tightness / compression scoring more sensitive (stricter).", group = grpGeneral)

// =====================================================================================
// SECTION 1 — TREND ENGINE INPUTS
// =====================================================================================
grpTrend = "Trend Engine"
smaFastLen   = input.int(50,  "Short-Term MA Length",  minval = 5,  group = grpTrend)
smaMidLen    = input.int(150, "Mid-Term MA Length",    minval = 20, group = grpTrend)
smaSlowLen   = input.int(200, "Long-Term MA Length",   minval = 50, group = grpTrend)
slopeLookback= input.int(20,  "Long-Term MA Slope Lookback (bars)", minval = 5, group = grpTrend)
yearLookback = input.int(252, "52-Week Lookback (bars)", minval = 50, group = grpTrend)

// =====================================================================================
// SECTION 2 — RELATIVE STRENGTH ENGINE INPUTS
// =====================================================================================
grpRS = "Relative Strength Engine"
rsSmaLen      = input.int(50,  "RS Line Smoothing Length", minval = 5, group = grpRS)
rsHighLookback= input.int(126, "RS New-High Lookback (bars)", minval = 20, group = grpRS)
rsPerfLookback= input.int(63,  "Relative Performance Lookback (bars, ~1 quarter)", minval = 10, group = grpRS)

// =====================================================================================
// SECTION 3 — PRICE STRUCTURE ENGINE INPUTS
// =====================================================================================
grpStruct = "Price Structure Engine"
structLookback   = input.int(50, "Base / Consolidation Lookback (bars)", minval = 10, group = grpStruct)
structPivotBars  = input.int(5,  "Pivot Low Left/Right Bars (Higher-Low Detection)", minval = 2, maxval = 15, group = grpStruct)
tightRangeRefPct = input.float(25.0, "Reference Range Width % (for scoring)", minval = 5, group = grpStruct,
     tooltip = "A base range (high-low)/high as a percent. Ranges at or below this are scored as 'tight'.")

// =====================================================================================
// SECTION 4 — VOLATILITY CONTRACTION ENGINE INPUTS
// =====================================================================================
grpVol = "Volatility Contraction Engine"
atrLen              = input.int(14, "ATR Length", minval = 2, group = grpVol)
volContractLookback = input.int(20, "Volatility Smoothing Lookback (bars)", minval = 5, group = grpVol)
volPercentileLookback = input.int(126, "Volatility Percentile Lookback (bars)", minval = 30, group = grpVol)
bbLen  = input.int(20, "Bollinger Band Length", minval = 5, group = grpVol)
bbMult = input.float(2.0, "Bollinger Band Multiplier", minval = 0.5, step = 0.1, group = grpVol)

// =====================================================================================
// SECTION 5 — VOLUME / ACCUMULATION ENGINE INPUTS
// =====================================================================================
grpVolu = "Volume & Accumulation Engine"
volShortLen   = input.int(10, "Short Volume MA Length", minval = 3, group = grpVolu)
volLongLen    = input.int(50, "Long Volume MA Length",  minval = 10, group = grpVolu)
volDryUpFactor= input.float(0.75, "Volume Dry-Up Threshold (Short MA / Long MA)", minval = 0.1, maxval = 1.5, step = 0.05, group = grpVolu)
volRatioLookback = input.int(20, "Up/Down Volume Ratio Lookback (bars)", minval = 5, maxval = 60, group = grpVolu)
volUDThreshold = input.float(1.3, "Strong Demand Up/Down Volume Ratio Threshold", minval = 1.0, step = 0.1, group = grpVolu)
adlSmoothLen  = input.int(21, "Accumulation/Distribution Line Smoothing Length", minval = 5, group = grpVolu)
volExpansionMult   = input.float(1.5, "Breakout Participation Volume Multiplier (x avg)", minval = 1.0, step = 0.1, group = grpVolu,
     tooltip = "An up day with volume at/above this multiple of the long volume average counts as breakout participation.")
participationLookback = input.int(5, "Breakout Participation Lookback (bars)", minval = 1, maxval = 20, group = grpVolu,
     tooltip = "How many bars a volume-thrust day stays 'active' for scoring purposes.")

// =====================================================================================
// SECTION 6 — BREAKOUT READINESS ENGINE INPUTS
// =====================================================================================
grpBrk = "Breakout Readiness Engine"
breakoutLookback     = input.int(50, "Resistance-Test Lookback (bars)", minval = 10, group = grpBrk)
breakoutProximityPct = input.float(8.0, "Near-High Proximity Threshold (%)", minval = 1, group = grpBrk)
breakoutMinTests     = input.int(2, "Minimum Resistance Tests Required", minval = 1, group = grpBrk)
breakoutConfirmBonus = input.float(20, "Breakout Confirmation Bonus (points)", minval = 0, maxval = 40, group = grpBrk,
     tooltip = "Extra points when a fresh N-bar high coincides with volume participation, trend alignment and rising RS — so an active breakout with real volume doesn't stay buried under a temporarily 'expanding' volatility/structure reading.")

// =====================================================================================
// SECTION 7 — SCORING WEIGHTS (module -> composite score)
// =====================================================================================
grpWeights = "Composite Scoring Weights"
wTrend    = input.float(15, "Trend Weight",              minval = 0, group = grpWeights)
wRS       = input.float(15, "Relative Strength Weight",  minval = 0, group = grpWeights)
wStruct   = input.float(10, "Price Structure Weight",    minval = 0, group = grpWeights)
wVolat    = input.float(10, "Volatility Contraction Weight", minval = 0, group = grpWeights)
wVolume   = input.float(30, "Volume / Accumulation Weight (highest by design)", minval = 0, group = grpWeights)
wBreakout = input.float(20, "Breakout Readiness Weight", minval = 0, group = grpWeights)

// =====================================================================================
// SECTION 8 — DASHBOARD & ALERT INPUTS
// =====================================================================================
grpDash = "Dashboard"
showDashboard = input.bool(true, "Show Dashboard", group = grpDash)
dashPosition  = input.string("Top Right", "Dashboard Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpDash)
dashSize      = input.string("Normal", "Dashboard Text Size", options = ["Small", "Normal", "Large"], group = grpDash)

grpAlert = "Alerts"
alertScoreThreshold      = input.float(80, "Setup Score Alert Threshold",         minval = 0, maxval = 100, group = grpAlert)
alertImprovementPts      = input.float(15, "Significant Improvement (points over 5 bars)", minval = 1, group = grpAlert)
alertVolumeExceptional   = input.float(90, "Exceptional Volume Score Threshold",  minval = 0, maxval = 100, group = grpAlert)
alertBreakoutHighConf    = input.float(85, "Breakout Readiness High-Confidence Threshold", minval = 0, maxval = 100, group = grpAlert)

grpTest = "Testing / Calibration (NOT trade advice)"
testMarkersOn   = input.bool(true, "Show Score-Based Test Markers", group = grpTest,
     tooltip = "For backtesting/calibrating the scoring engine only. These mark where the composite score crosses your chosen thresholds — they are not buy/sell recommendations, stops, or targets.")
testEntryScore  = input.float(60, "Test 'Entry' Marker: Score Crosses Above", minval = 0, maxval = 100, group = grpTest)
testExitScore   = input.float(40, "Test 'Exit' Marker: Score Crosses Below", minval = 0, maxval = 100, group = grpTest)

// =====================================================================================
// UTILITIES
// =====================================================================================
f_clamp(x) =>
    math.max(0.0, math.min(100.0, x))

f_scoreColor(score) =>
    color c = score >= 80 ? color.new(color.green, 0)  :
               score >= 60 ? color.new(color.lime, 0)   :
               score >= 40 ? color.new(color.yellow, 0) :
               score >= 20 ? color.new(color.orange, 0) :
               color.new(color.red, 0)
    c

// =====================================================================================
// ENGINE 1 — TREND ENGINE
// Evaluates long-term trend health via MA alignment, MA slope, and price position
// relative to the 52-week range (institutional "trend template" style check).
// =====================================================================================
f_trendEngine() =>
    smaFast = ta.sma(close, smaFastLen)
    smaMid  = ta.sma(close, smaMidLen)
    smaSlow = ta.sma(close, smaSlowLen)
    smaSlowPrev = smaSlow[slopeLookback]

    aligned      = close > smaFast and smaFast > smaMid and smaMid > smaSlow
    slowRising   = smaSlow > smaSlowPrev
    priceAboveSlow = close > smaSlow

    hi52 = ta.highest(high, yearLookback)
    lo52 = ta.lowest(low,  yearLookback)
    farFromLow  = close > lo52 * 1.30
    nearHigh52  = close > hi52 * 0.75

    score = 0.0
    score += aligned ? 30.0 : 0.0
    score += slowRising ? 25.0 : 0.0
    score += priceAboveSlow ? 15.0 : 0.0
    score += farFromLow ? 15.0 : 0.0
    score += nearHigh52 ? 15.0 : 0.0

    [f_clamp(score), aligned, slowRising, smaFast, smaMid, smaSlow]

[trendScore, trendAligned, trendSlowRising, smaFast, smaMid, smaSlow] = f_trendEngine()

// =====================================================================================
// ENGINE 2 — RELATIVE STRENGTH ENGINE
// Uses a benchmark request.security() call (current timeframe, no lookahead) to build
// a price-relative (RS) line and a simple weighted relative-performance measure.
// =====================================================================================
benchClose = request.security(benchSymbol, timeframe.period, close, lookahead = barmerge.lookahead_off)

f_rsEngine(bClose) =>
    rsLine   = close / bClose
    rsSmaVal = ta.sma(rsLine, rsSmaLen)
    rsRising = rsLine > rsSmaVal
    rsHiLB   = ta.highest(rsLine, rsHighLookback)
    rsNewHigh= rsLine >= rsHiLB * 0.999

    perfStock = close / close[rsPerfLookback] - 1
    perfBench = bClose / bClose[rsPerfLookback] - 1
    relPerf   = perfStock - perfBench

    score = 0.0
    score += rsRising ? 35.0 : 0.0
    score += rsNewHigh ? 35.0 : 0.0
    score += relPerf > 0 ? 30.0 * math.min(relPerf * 10.0, 1.0) : 0.0

    [f_clamp(score), rsRising, rsNewHigh, rsLine]

[rsScore, rsRising, rsNewHigh, rsLine] = f_rsEngine(benchClose)

// =====================================================================================
// ENGINE 3 — PRICE STRUCTURE ENGINE
// Evaluates base quality: range tightness, distance from base high (compression near
// highs), and a non-repainting higher-low counter using confirmed pivot lows.
// =====================================================================================
var float lastPivotLow = na
var float prevPivotLow = na
var int   higherLowCount = 0

pivLow = ta.pivotlow(low, structPivotBars, structPivotBars)
if not na(pivLow)
    prevPivotLow := lastPivotLow
    lastPivotLow := pivLow
    if not na(prevPivotLow)
        higherLowCount := lastPivotLow > prevPivotLow ? higherLowCount + 1 : 0

f_structureEngine() =>
    hh = ta.highest(high, structLookback)
    ll = ta.lowest(low,  structLookback)
    rangePct = hh != 0 ? (hh - ll) / hh * 100.0 : 0.0
    distFromHighPct = hh != 0 ? (hh - close) / hh * 100.0 : 0.0

    effTightRef = tightRangeRefPct / tightnessRef
    tightnessScore = f_clamp(100.0 - (rangePct / effTightRef) * 100.0)
    compressionScore = f_clamp(100.0 - (distFromHighPct / (effTightRef * 0.6)) * 100.0)
    higherLowScore = math.min(higherLowCount, 3) / 3.0 * 100.0

    score = tightnessScore * 0.40 + compressionScore * 0.30 + higherLowScore * 0.30
    [f_clamp(score), rangePct, distFromHighPct, hh, ll]

[structScore, structRangePct, structDistFromHighPct, baseHigh, baseLow] = f_structureEngine()

// =====================================================================================
// ENGINE 4 — VOLATILITY CONTRACTION ENGINE
// Combines ATR%-of-price contraction, its percentile rank versus history, and
// Bollinger Band width contraction (volatility squeeze).
// =====================================================================================
f_volatilityEngine() =>
    atrVal = ta.atr(atrLen)
    atrPct = close != 0 ? atrVal / close * 100.0 : 0.0
    atrPctSma = ta.sma(atrPct, volContractLookback)
    atrContracting = atrPct < atrPctSma

    atrPercentRank = ta.percentrank(atrPct, volPercentileLookback)  // 0 = most contracted vs history

    bbBasis = ta.sma(close, bbLen)
    bbDev   = ta.stdev(close, bbLen) * bbMult
    bbWidthPct = bbBasis != 0 ? (2 * bbDev) / bbBasis * 100.0 : 0.0
    bbWidthSma = ta.sma(bbWidthPct, volContractLookback)
    bbContracting = bbWidthPct < bbWidthSma

    score = 0.0
    score += atrContracting ? 30.0 : 0.0
    score += bbContracting ? 30.0 : 0.0
    score += (100.0 - atrPercentRank) * 0.40

    [f_clamp(score), atrContracting, bbContracting, atrPct]

[volatScore, atrContracting, bbContracting, atrPctVal] = f_volatilityEngine()

// =====================================================================================
// ENGINE 5 — VOLUME / ACCUMULATION ENGINE (highest weighted by design)
// Evaluates volume dry-up, up/down volume ratio (demand vs supply), and the slope of
// a smoothed Accumulation/Distribution line as a proxy for institutional participation.
// =====================================================================================
f_volumeEngine() =>
    volSmaShort = ta.sma(volume, volShortLen)
    volSmaLong  = ta.sma(volume, volLongLen)
    dryUp = volSmaShort < volSmaLong * volDryUpFactor

    float upVolSum = 0.0
    float downVolSum = 0.0
    for i = 0 to volRatioLookback - 1
        if close[i] > close[i + 1]
            upVolSum += volume[i]
        else if close[i] < close[i + 1]
            downVolSum += volume[i]
    udRatio = downVolSum > 0 ? upVolSum / downVolSum : (upVolSum > 0 ? volUDThreshold * 2.0 : 1.0)
    strongDemand = udRatio > volUDThreshold

    hlRange = (high - low)
    mfm = hlRange != 0 ? ((close - low) - (high - close)) / hlRange : 0.0
    adl = ta.cum(mfm * volume)
    adlSma = ta.sma(adl, adlSmoothLen)
    adlRising = adl > adlSma

    pullbackLight = close < close[1] and volume < volSmaLong

    // Breakout participation: an up day with volume meaningfully above its own average.
    // This is the "volume must expand on breakout day" institutional signal, and is kept
    // 'active' for a short lookback window so a genuine thrust day isn't scored for one
    // bar only and then instantly forgotten.
    relVol = volSmaLong > 0 ? volume / volSmaLong : 1.0
    breakoutParticipationToday = close > close[1] and relVol >= volExpansionMult
    breakoutParticipation = ta.highest(breakoutParticipationToday ? 1.0 : 0.0, participationLookback) == 1.0

    score = 0.0
    score += dryUp ? 20.0 : 0.0
    score += strongDemand ? 20.0 : 0.0
    score += adlRising ? 20.0 : 0.0
    score += pullbackLight ? 20.0 : 0.0
    score += breakoutParticipation ? 20.0 : 0.0

    [f_clamp(score), dryUp, strongDemand, adlRising, udRatio, breakoutParticipation]

[volumeScore, volDryUp, volStrongDemand, volAdlRising, volUdRatio, volBreakoutParticipation] = f_volumeEngine()

// =====================================================================================
// ENGINE 6 — BREAKOUT READINESS ENGINE
// Rather than reacting to a breakout after the fact, this estimates proximity to a
// high-quality breakout using base position, tightness, resistance tests, and a blend
// of the other engines (demand/supply, RS, trend alignment).
// =====================================================================================
f_breakoutEngine(structS, volS, trendS, rsS, volatS, distFromHighPct, rangePct, hh, volParticipation, trendOK, rsOK) =>
    nearHigh = distFromHighPct < breakoutProximityPct
    tight    = rangePct < tightRangeRefPct
    newBaseHigh = high >= hh * 0.999

    int testCount = 0
    for i = 0 to breakoutLookback - 1
        if high[i] >= hh * (1 - breakoutProximityPct / 100.0) and high[i] < hh
            testCount += 1
    testedResistance = testCount >= breakoutMinTests

    score = trendS * 0.20 + rsS * 0.20 + volS * 0.25 + structS * 0.15 + volatS * 0.10
    score += nearHigh ? 5.0 : 0.0
    score += (tight and testedResistance) ? 5.0 : 0.0

    // Breakout confirmation: a fresh high made together with real volume participation,
    // an aligned trend and rising relative strength. This is what stops a genuine,
    // volume-backed launch from being buried by the transient volatility/range expansion
    // that naturally accompanies the move itself.
    confirmedBreakout = newBaseHigh and volParticipation and trendOK and rsOK
    score += confirmedBreakout ? breakoutConfirmBonus : 0.0

    [f_clamp(score), nearHigh, tight, testedResistance, testCount, confirmedBreakout]

[breakoutScore, brkNearHigh, brkTight, brkTestedResistance, brkTestCount, brkConfirmed] =
     f_breakoutEngine(structScore, volumeScore, trendScore, rsScore, volatScore,
     structDistFromHighPct, structRangePct, baseHigh, volBreakoutParticipation, trendAligned, rsRising)

// =====================================================================================
// SCORING ENGINE — Composite Setup Score
// Aggregates all six module scores using configurable, transparent weights.
// =====================================================================================
weightSum = wTrend + wRS + wStruct + wVolat + wVolume + wBreakout
weightSumSafe = weightSum == 0 ? 1.0 : weightSum

compositeScore = f_clamp(
     (trendScore * wTrend + rsScore * wRS + structScore * wStruct +
      volatScore * wVolat + volumeScore * wVolume + breakoutScore * wBreakout) / weightSumSafe)

// =====================================================================================
// PLOTTING — composite score in its own pane with quality reference bands
// =====================================================================================
plot(compositeScore, "Composite Setup Score", color = f_scoreColor(compositeScore), linewidth = 2)
hline(80, "Exceptional (80)", color = color.new(color.green, 60), linestyle = hline.style_dashed)
hline(60, "Good (60)",        color = color.new(color.lime, 60),  linestyle = hline.style_dashed)
hline(40, "Average (40)",     color = color.new(color.yellow, 60),linestyle = hline.style_dashed)
hline(20, "Weak (20)",        color = color.new(color.red, 60),   linestyle = hline.style_dashed)
bgcolor(compositeScore >= alertScoreThreshold ? color.new(color.green, 90) : na)

// =====================================================================================
// DASHBOARD
// =====================================================================================
f_tablePos(posInput) =>
    string p = posInput == "Top Right" ? position.top_right :
               posInput == "Top Left" ? position.top_left :
               posInput == "Bottom Right" ? position.bottom_right : position.bottom_left
    p

f_tableSize(sizeInput) =>
    string s = sizeInput == "Small" ? size.small : sizeInput == "Large" ? size.large : size.normal
    s

var table dash = table.new(f_tablePos(dashPosition), 2, 10, border_width = 1, border_color = color.new(color.gray, 40), force_overlay = true)

if showDashboard and barstate.islast
    txtSize = f_tableSize(dashSize)
    labelBg = color.new(color.gray, 15)
    table.cell(dash, 0, 0, "Institutional Setup Score", text_color = color.white, bgcolor = color.new(color.gray, 0), text_size = txtSize)
    table.cell(dash, 1, 0, str.tostring(math.round(compositeScore)), text_color = color.black, bgcolor = f_scoreColor(compositeScore), text_size = txtSize)

    table.cell(dash, 0, 1, "Trend Quality", text_color = color.white, bgcolor = labelBg, text_size = txtSize)
    table.cell(dash, 1, 1, str.tostring(math.round(trendScore)), text_color = color.black, bgcolor = f_scoreColor(trendScore), text_size = txtSize)

    table.cell(dash, 0, 2, "Relative Strength", text_color = color.white, bgcolor = labelBg, text_size = txtSize)
    table.cell(dash, 1, 2, str.tostring(math.round(rsScore)), text_color = color.black, bgcolor = f_scoreColor(rsScore), text_size = txtSize)

    table.cell(dash, 0, 3, "Price Structure", text_color = color.white, bgcolor = labelBg, text_size = txtSize)
    table.cell(dash, 1, 3, str.tostring(math.round(structScore)), text_color = color.black, bgcolor = f_scoreColor(structScore), text_size = txtSize)

    table.cell(dash, 0, 4, "Volatility Contraction", text_color = color.white, bgcolor = labelBg, text_size = txtSize)
    table.cell(dash, 1, 4, str.tostring(math.round(volatScore)), text_color = color.black, bgcolor = f_scoreColor(volatScore), text_size = txtSize)

    table.cell(dash, 0, 5, "Volume Quality", text_color = color.white, bgcolor = labelBg, text_size = txtSize)
    table.cell(dash, 1, 5, str.tostring(math.round(volumeScore)), text_color = color.black, bgcolor = f_scoreColor(volumeScore), text_size = txtSize)

    table.cell(dash, 0, 6, "Institutional Accumulation", text_color = color.white, bgcolor = labelBg, text_size = txtSize)
    table.cell(dash, 1, 6, volAdlRising ? "Yes" : "No", text_color = color.white, bgcolor = volAdlRising ? color.new(color.green, 10) : color.new(color.red, 10), text_size = txtSize)

    table.cell(dash, 0, 7, "Breakout Readiness", text_color = color.white, bgcolor = labelBg, text_size = txtSize)
    table.cell(dash, 1, 7, str.tostring(math.round(breakoutScore)), text_color = color.black, bgcolor = f_scoreColor(breakoutScore), text_size = txtSize)

    table.cell(dash, 0, 8, "Higher-Low Count", text_color = color.white, bgcolor = labelBg, text_size = txtSize)
    table.cell(dash, 1, 8, str.tostring(higherLowCount), text_color = color.white, bgcolor = labelBg, text_size = txtSize)

    table.cell(dash, 0, 9, "Breakout Confirmed", text_color = color.white, bgcolor = labelBg, text_size = txtSize)
    table.cell(dash, 1, 9, brkConfirmed ? "Yes" : "No", text_color = color.white, bgcolor = brkConfirmed ? color.new(color.green, 10) : color.new(color.red, 10), text_size = txtSize)

// =====================================================================================
// ALERTS — informational only ("worth watching"), never instructions to trade
// =====================================================================================
alertcondition(ta.crossover(compositeScore, alertScoreThreshold),
     title = "Setup Score Above Threshold",
     message = "{{ticker}}: Institutional Setup Score crossed above the alert threshold. Review for further discretionary analysis.")

alertcondition(compositeScore - compositeScore[5] > alertImprovementPts,
     title = "Significant Setup Improvement",
     message = "{{ticker}}: Setup quality has improved significantly over the last few bars.")

alertcondition(volAdlRising and not volAdlRising[1],
     title = "New Institutional Accumulation Phase",
     message = "{{ticker}}: Accumulation/Distribution trend has turned up — possible new institutional accumulation phase.")

alertcondition(ta.crossover(volumeScore, alertVolumeExceptional),
     title = "Exceptional Volume Behaviour",
     message = "{{ticker}}: Volume/accumulation score crossed above the exceptional threshold.")

alertcondition(ta.crossover(breakoutScore, alertBreakoutHighConf),
     title = "Breakout Readiness High Confidence",
     message = "{{ticker}}: Breakout readiness score reached high-confidence level. Stock deserves attention, not an automatic trade signal.")

alertcondition(brkConfirmed and not brkConfirmed[1],
     title = "Breakout Confirmed With Volume",
     message = "{{ticker}}: Fresh high made with real volume participation, trend alignment and rising relative strength. Worth a look.")

// =====================================================================================
// TESTING / CALIBRATION MARKERS — off by default.
// These simply mark where the composite score crosses the two thresholds above so you
// can visually backtest the scoring engine against price action. They are NOT trade
// signals, stops, or targets — the indicator's stated scope excludes those by design.
// =====================================================================================
testEntrySignal = ta.crossover(compositeScore, testEntryScore)
testExitSignal  = ta.crossunder(compositeScore, testExitScore)

plotshape(testMarkersOn and testEntrySignal, title = "Test Marker: Score Up",
     style = shape.triangleup, location = location.belowbar, color = color.new(color.lime, 0),
     size = size.small, force_overlay = true)

plotshape(testMarkersOn and testExitSignal, title = "Test Marker: Score Down",
     style = shape.triangledown, location = location.abovebar, color = color.new(color.red, 0),
     size = size.small, force_overlay = true)

plotchar(testMarkersOn and brkConfirmed and not brkConfirmed[1], title = "Test Marker: Breakout Confirmed",
     char = "B", location = location.belowbar, color = color.new(color.orange, 0),
     size = size.small, force_overlay = true)
````
