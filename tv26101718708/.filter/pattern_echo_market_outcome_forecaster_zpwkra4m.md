# Pattern Echo - Market Outcome Forecaster

- url: https://www.tradingview.com/script/ZPwKRa4m-Pattern-Echo-Market-Outcome-Forecaster/
- type: indicator
- pine_id: PUB;7c41428b0c7f404782b09f25a0a978dc
- version: 5.0

## Description

OVERVIEW

EchoEdge is a historical-analog research indicator that compares the current confirmed market environment with similar conditions previously observed on the same symbol and timeframe.

Rather than producing a conventional buy or sell signal, the indicator asks:

“What happened after this symbol previously displayed comparable technical conditions?”

It identifies independent historical matches, studies their subsequent price behavior, and summarizes those outcomes in an on-chart dashboard and forward projection.

METHODOLOGY

Each historical comparison uses a normalized collection of technical characteristics:

• 20-bar price momentum
• RSI
• ATR-based volatility
• Relative volume
• Distance from the 20-period EMA
• Position within the 52-week price range
• ADX trend strength
• Relative strength versus the selected benchmark
• EMA 20/50/200 trend alignment
• 20-period EMA slope

The script calculates a similarity score between the current confirmed market state and eligible historical observations.

Potential matches are ranked by similarity. A user-adjustable minimum separation prevents neighboring candles from the same historical event from being counted as multiple independent matches.

Historical observations without a completed forward evaluation period are excluded.

DASHBOARD

The dashboard displays:

• Analyzed candle — the confirmed candle being evaluated
• Best similarity — similarity of the closest historical match
• Average similarity — average across all accepted matches
• Independent matches — accepted matches meeting the similarity and spacing requirements
• Target reached first — percentage that reached the selected target before the stop
• Stop reached first — percentage that reached the selected stop before the target
• Neither reached — percentage that reached neither level during the evaluation period
• Median forward return — median closing return after the selected number of bars
• Median maximum upside — median highest favorable excursion
• Median maximum drawdown — median largest adverse excursion
• Entry, target and stop — reference levels derived from user-selected percentages
• Reward/risk — mathematical ratio between the selected target and stop distances
• Historical verdict — descriptive summary of the accepted historical outcomes
• Closest historical dates — dates of the three closest accepted matches

The verdict can be Favorable, Mixed, Unfavorable or Insufficient Matches. It summarizes the selected historical sample and is not a trading recommendation.

CHART COLORS

• Solid blue projection — median path followed by the accepted historical matches
• Dashed green projection — upper-quartile historical path
• Dashed red projection — lower-quartile historical path
• Green dotted horizontal line — user-defined target reference
• Red dotted horizontal line — user-defined stop reference
• Blue “DNA” labels — locations of the five closest historical analogs
• Green dashboard cells — comparatively favorable historical values
• Amber dashboard cells — mixed, intermediate or cautionary values
• Red dashboard cells — comparatively unfavorable historical values
• Gray dashboard cells — neutral, informational or unavailable values

The projected paths are distributions of historical outcomes. They are not forecasts of exact future prices and should not be interpreted as support, resistance or guaranteed destinations.

IMPORTANT LIMITATIONS

Historical similarity does not establish causation and does not ensure that future price behavior will resemble prior outcomes.

Results can vary substantially by symbol, timeframe, available history, benchmark, similarity threshold, forward period, target, stop and minimum match-separation settings.

Small samples may be statistically unreliable. A high similarity score means that the selected technical measurements were alike; it does not mean that the subsequent outcomes will also be alike.

Target-first and stop-first statistics use historical bar highs and lows. When both levels occur within the same candle, their actual intrabar order cannot be determined. The script therefore applies the conservative assumption that the stop occurred first.

The indicator uses standard OHLCV candles for its calculations, even when displayed on a synthetic chart type. When “Use last confirmed candle” is enabled, the current unconfirmed candle is excluded from the analysis.

This indicator does not account for commissions, slippage, bid/ask spreads, liquidity, taxes, news, earnings events or changes in market structure.

DISCLAIMER

EchoEdge is provided solely for educational, informational and historical research purposes. It is not financial, investment, legal or tax advice and does not constitute a recommendation or solicitation to buy or sell any security or financial instrument.

No result, projection, target, stop, similarity score, alert or historical verdict guarantees future performance. Users are responsible for conducting their own research, evaluating risk and determining whether any trade is appropriate for their circumstances.

Past performance and historical analogs are not reliable indicators of future results.

## Source Code

````pine
//@version=6
indicator("Pattern Echo - Market Outcome Forecaster", shorttitle="PatEcho", overlay=true, max_bars_back=5000, max_lines_count=300, max_labels_count=100)

//=============================================================================
// Pattern Echo - Market Outcome Forecaster
// Historical-analog research tool. It compares the current confirmed market
// state with earlier states on the same symbol, then summarizes what occurred
// during the bars that followed the closest matches.
//
// This script does not use lookahead data. Historical candidates without a
// completed forward outcome are excluded. Results are descriptive, not a
// prediction, recommendation, or guarantee of future performance.
//=============================================================================

//=============================================================================
// INPUTS
//=============================================================================
string GROUP_ANALOG = "Historical Analog Engine"
string GROUP_TRADE  = "Outcome Test"
string GROUP_VISUAL = "Display"

benchmarkSymbol = input.symbol("AMEX:SPY", "Relative-strength benchmark", group=GROUP_ANALOG)
historyLookback = input.int(1500, "Historical search bars", minval=250, maxval=3000, group=GROUP_ANALOG)
requestedMatches = input.int(15, "Closest matches", minval=5, maxval=30, group=GROUP_ANALOG)
minimumSimilarity = input.float(60.0, "Minimum similarity %", minval=25.0, maxval=95.0, step=1.0, group=GROUP_ANALOG)
minimumMatchSeparation = input.int(20, "Minimum bars between matches", minval=1, maxval=100, group=GROUP_ANALOG, tooltip="Prevents consecutive candles from the same historical episode from being counted as separate analogs.")
useConfirmedBar = input.bool(true, "Use last confirmed candle", group=GROUP_ANALOG)

forwardBars = input.int(20, "Forward outcome bars", minval=5, maxval=50, group=GROUP_TRADE)
targetPercent = input.float(8.0, "Target above entry %", minval=0.5, maxval=50.0, step=0.5, group=GROUP_TRADE)
stopPercent = input.float(4.0, "Stop below entry %", minval=0.5, maxval=25.0, step=0.5, group=GROUP_TRADE)
stopCoveragePercent = input.int(60, "Analog stop coverage %", minval=50, maxval=90, step=5, group=GROUP_TRADE, tooltip="Sets the historical stop reference deep enough to cover this percentage of accepted analog drawdowns. The 60% default provides a more balanced stop. Higher coverage produces a wider stop.")
minimumMatchesForVerdict = input.int(8, "Minimum matches for verdict", minval=3, maxval=25, group=GROUP_TRADE)
minimumBaselineSamples = input.int(10, "Minimum baseline samples", minval=5, maxval=50, group=GROUP_TRADE)
minimumEdgeForVerdict = input.float(5.0, "Minimum baseline edge %", minval=1.0, maxval=25.0, step=0.5, group=GROUP_TRADE, tooltip="Minimum difference between the analog and ordinary-period target-first rates required for a directional verdict.")

showProjection = input.bool(true, "Show historical outcome cone", group=GROUP_VISUAL)
showMatchMarkers = input.bool(true, "Mark five closest analogs", group=GROUP_VISUAL)
showTradeLevels = input.bool(true, "Show current target and stop", group=GROUP_VISUAL)
projectionWidth = input.int(3, "Median projection width", minval=1, maxval=5, group=GROUP_VISUAL)

//=============================================================================
// COLORS
//=============================================================================
color headerColor = color.rgb(25, 92, 185)
color labelColor = color.rgb(45, 52, 66)
color neutralColor = color.rgb(78, 84, 98)
color bullishColor = color.rgb(20, 145, 85)
color bearishColor = color.rgb(195, 55, 65)
color warningColor = color.rgb(205, 145, 20)
color medianColor = color.rgb(35, 135, 255)
color upperColor = color.rgb(35, 180, 105)
color lowerColor = color.rgb(230, 85, 85)
color textColor = color.white

//=============================================================================
// HELPERS
//=============================================================================
f_adx(int diLength, int smoothing) =>
    [plusDI, minusDI, adxResult] = ta.dmi(diLength, smoothing)
    adxResult

f_clamp(float value, float minimum, float maximum) =>
    math.max(minimum, math.min(maximum, value))

f_safeDifference(float leftValue, float rightValue, float scale) =>
    na(leftValue) or na(rightValue) or scale == 0 ? na : math.min(1.0, math.abs(leftValue - rightValue) / scale)

f_percentile(array<float> values, float percentile) =>
    float result = na
    int valueCount = array.size(values)
    if valueCount > 0
        array<float> sortedValues = array.copy(values)
        array.sort(sortedValues, order.ascending)
        int percentileIndex = int(math.round((valueCount - 1) * percentile))
        result := array.get(sortedValues, percentileIndex)
    result

f_formatPercent(float value) =>
    na(value) ? "N/A" : str.tostring(value, "#.##") + "%"

f_formatPrice(float value) =>
    na(value) ? "N/A" : str.tostring(value, format.mintick)

f_formatNumber(float value) =>
    na(value) ? "N/A" : str.tostring(value, "#.##")

f_cellColor(float value, float bullishThreshold, float bearishThreshold) =>
    na(value) ? neutralColor : value >= bullishThreshold ? bullishColor : value <= bearishThreshold ? bearishColor : warningColor

f_clearLines(array<line> lineIds) =>
    if array.size(lineIds) > 0
        for lineIndex = 0 to array.size(lineIds) - 1
            line.delete(array.get(lineIds, lineIndex))
    array.clear(lineIds)

f_clearLabels(array<label> labelIds) =>
    if array.size(labelIds) > 0
        for labelIndex = 0 to array.size(labelIds) - 1
            label.delete(array.get(labelIds, labelIndex))
    array.clear(labelIds)

//=============================================================================
// STANDARD-CANDLE DATA
// ticker.new() prevents synthetic Heikin-Ashi/Renko/etc. prices from entering
// the similarity model or outcome statistics.
//=============================================================================
standardTickerId = ticker.new(syminfo.prefix, syminfo.ticker)

[standardOpen, standardHigh, standardLow, standardClose, standardVolume, standardRsi, standardAtr, standardEma20, standardEma50, standardEma200, standardAdx, standardHigh252, standardLow252, standardAverageVolume, standardMomentum20, standardEmaSlope] = request.security(
     standardTickerId,
     timeframe.period,
     [open, high, low, close, volume, ta.rsi(close, 14), ta.atr(14), ta.ema(close, 20), ta.ema(close, 50), ta.ema(close, 200), f_adx(14, 14), ta.highest(high, 252), ta.lowest(low, 252), ta.sma(volume, 20), close[20] != 0 ? close / close[20] - 1.0 : na, ta.ema(close, 20)[5] != 0 ? ta.ema(close, 20) / ta.ema(close, 20)[5] - 1.0 : na])

[benchmarkClose, benchmarkMomentum20] = request.security(
     benchmarkSymbol,
     timeframe.period,
     [close, close[20] != 0 ? close / close[20] - 1.0 : na],
     ignore_invalid_symbol=true)

//=============================================================================
// MARKET DNA FEATURE VECTOR
// Each feature is normalized so unlike units can be compared meaningfully.
//=============================================================================
featureMomentum = standardMomentum20
featureRsi = standardRsi / 100.0
featureVolatility = standardClose != 0 ? standardAtr / standardClose : na
featureRelativeVolume = standardAverageVolume != 0 ? standardVolume / standardAverageVolume : na
featureEmaDistance = standardEma20 != 0 ? standardClose / standardEma20 - 1.0 : na
featureRangePosition = standardHigh252 != standardLow252 ? (standardClose - standardLow252) / (standardHigh252 - standardLow252) : na
featureAdx = standardAdx / 100.0
featureRelativeStrength = standardMomentum20 - benchmarkMomentum20
featureTrendAlignment = ((standardClose > standardEma20 ? 1.0 : 0.0) + (standardEma20 > standardEma50 ? 1.0 : 0.0) + (standardEma50 > standardEma200 ? 1.0 : 0.0)) / 3.0
featureEmaSlope = standardEmaSlope

//=============================================================================
// PERSISTENT VISUAL OBJECTS
//=============================================================================
var array<line> medianProjectionLines = array.new<line>()
var array<line> upperProjectionLines = array.new<line>()
var array<line> lowerProjectionLines = array.new<line>()
var array<line> tradeLevelLines = array.new<line>()
var array<label> analogLabels = array.new<label>()

var table dashboard = table.new(position.top_right, 2, 18, border_width=1, border_color=color.rgb(105, 110, 125))
if barstate.isfirst
    table.merge_cells(dashboard, 0, 0, 1, 0)

var bool favorableAlert = false
favorableAlert := false

//=============================================================================
// ANALOG SEARCH AND OUTCOME ANALYSIS
//=============================================================================
if barstate.islast
    f_clearLines(medianProjectionLines)
    f_clearLines(upperProjectionLines)
    f_clearLines(lowerProjectionLines)
    f_clearLines(tradeLevelLines)
    f_clearLabels(analogLabels)

    int analysisOffset = useConfirmedBar and not barstate.isconfirmed ? 1 : 0
    int analysisBarIndex = bar_index - analysisOffset
    float analysisPrice = standardClose[analysisOffset]

    // Store all valid candidates, rank them natively, then remove candidates
    // that are too close to a higher-ranked historical episode.
    array<float> candidateDistances = array.new_float()
    array<int> candidateOffsets = array.new_int()

    int minimumCandidateOffset = forwardBars + analysisOffset + 1
    if historyLookback >= minimumCandidateOffset
        for candidateOffset = minimumCandidateOffset to historyLookback
            float distanceMomentum = f_safeDifference(featureMomentum[analysisOffset], featureMomentum[candidateOffset], 0.20)
            float distanceRsi = f_safeDifference(featureRsi[analysisOffset], featureRsi[candidateOffset], 1.0)
            float distanceVolatility = f_safeDifference(featureVolatility[analysisOffset], featureVolatility[candidateOffset], 0.05)
            float distanceRelativeVolume = f_safeDifference(featureRelativeVolume[analysisOffset], featureRelativeVolume[candidateOffset], 2.0)
            float distanceEma = f_safeDifference(featureEmaDistance[analysisOffset], featureEmaDistance[candidateOffset], 0.15)
            float distanceRange = f_safeDifference(featureRangePosition[analysisOffset], featureRangePosition[candidateOffset], 1.0)
            float distanceAdx = f_safeDifference(featureAdx[analysisOffset], featureAdx[candidateOffset], 1.0)
            float distanceRelativeStrength = f_safeDifference(featureRelativeStrength[analysisOffset], featureRelativeStrength[candidateOffset], 0.20)
            float distanceTrend = f_safeDifference(featureTrendAlignment[analysisOffset], featureTrendAlignment[candidateOffset], 1.0)
            float distanceSlope = f_safeDifference(featureEmaSlope[analysisOffset], featureEmaSlope[candidateOffset], 0.10)

            bool candidateValid = not na(distanceMomentum) and not na(distanceRsi) and not na(distanceVolatility) and not na(distanceRelativeVolume) and not na(distanceEma) and not na(distanceRange) and not na(distanceAdx) and not na(distanceRelativeStrength) and not na(distanceTrend) and not na(distanceSlope) and not na(standardClose[candidateOffset - forwardBars])

            if candidateValid
                float totalDistance = (distanceMomentum * 1.25 + distanceRsi * 1.0 + distanceVolatility * 1.0 + distanceRelativeVolume * 0.75 + distanceEma * 1.25 + distanceRange * 0.75 + distanceAdx * 0.75 + distanceRelativeStrength * 1.25 + distanceTrend * 1.0 + distanceSlope * 1.0) / 10.0

                array.push(candidateDistances, totalDistance)
                array.push(candidateOffsets, candidateOffset)

    // Select the highest-ranked independent episodes. A candidate is accepted
    // only when it is at least minimumMatchSeparation bars from every analog
    // already selected. This prevents one multi-bar event from dominating the
    // target/stop statistics.
    array<float> bestDistances = array.new_float(requestedMatches, 10.0)
    array<int> bestOffsets = array.new_int(requestedMatches, 0)
    int independentMatchCount = 0
    int candidateCount = array.size(candidateDistances)

    if candidateCount > 0
        array<int> rankedCandidateIndices = array.sort_indices(candidateDistances, order.ascending)
        for rankIndex = 0 to candidateCount - 1
            if independentMatchCount < requestedMatches
                int candidateIndex = array.get(rankedCandidateIndices, rankIndex)
                int rankedOffset = array.get(candidateOffsets, candidateIndex)
                float rankedDistance = array.get(candidateDistances, candidateIndex)
                bool farEnoughFromSelected = rankedOffset > 0

                if farEnoughFromSelected and independentMatchCount > 0
                    for selectedIndex = 0 to independentMatchCount - 1
                        int selectedOffset = array.get(bestOffsets, selectedIndex)
                        if math.abs(rankedOffset - selectedOffset) < minimumMatchSeparation
                            farEnoughFromSelected := false

                if farEnoughFromSelected
                    array.set(bestDistances, independentMatchCount, rankedDistance)
                    array.set(bestOffsets, independentMatchCount, rankedOffset)
                    independentMatchCount += 1

    int validMatches = 0
    float similarityTotal = 0.0
    float bestSimilarity = na
    array<float> forwardReturns = array.new_float()
    array<float> maximumUpsides = array.new_float()
    array<float> maximumDrawdowns = array.new_float()
    int targetFirstCount = 0
    int stopFirstCount = 0
    int neitherCount = 0
    string closestDates = ""

    for matchIndex = 0 to requestedMatches - 1
        int matchOffset = array.get(bestOffsets, matchIndex)
        float matchDistance = array.get(bestDistances, matchIndex)
        float matchSimilarity = f_clamp((1.0 - matchDistance) * 100.0, 0.0, 100.0)
        bool matchAccepted = matchOffset > 0 and matchSimilarity >= minimumSimilarity

        if matchAccepted
            validMatches += 1
            similarityTotal += matchSimilarity
            bestSimilarity := na(bestSimilarity) ? matchSimilarity : math.max(bestSimilarity, matchSimilarity)

            if validMatches <= 3
                string matchDate = str.format_time(time[matchOffset], "MMM dd, yyyy", syminfo.timezone)
                closestDates += (validMatches == 1 ? "" : " | ") + matchDate

            float historicalEntry = standardClose[matchOffset]
            float historicalTarget = historicalEntry * (1.0 + targetPercent / 100.0)
            float historicalStop = historicalEntry * (1.0 - stopPercent / 100.0)
            float highestOutcomePrice = historicalEntry
            float lowestOutcomePrice = historicalEntry
            bool outcomeResolved = false

            for outcomeStep = 1 to forwardBars
                float outcomeHigh = standardHigh[matchOffset - outcomeStep]
                float outcomeLow = standardLow[matchOffset - outcomeStep]
                highestOutcomePrice := math.max(highestOutcomePrice, outcomeHigh)
                lowestOutcomePrice := math.min(lowestOutcomePrice, outcomeLow)

                if not outcomeResolved
                    bool stopWasHit = outcomeLow <= historicalStop
                    bool targetWasHit = outcomeHigh >= historicalTarget
                    // Conservative convention: when both occur on the same bar,
                    // the stop is counted first because intrabar order is unknown.
                    if stopWasHit
                        stopFirstCount += 1
                        outcomeResolved := true
                    else if targetWasHit
                        targetFirstCount += 1
                        outcomeResolved := true

            if not outcomeResolved
                neitherCount += 1

            float endingPrice = standardClose[matchOffset - forwardBars]
            array.push(forwardReturns, (endingPrice / historicalEntry - 1.0) * 100.0)
            array.push(maximumUpsides, (highestOutcomePrice / historicalEntry - 1.0) * 100.0)
            array.push(maximumDrawdowns, (lowestOutcomePrice / historicalEntry - 1.0) * 100.0)

            if showMatchMarkers and validMatches <= 5
                label matchLabel = label.new(
                     analysisBarIndex - (matchOffset - analysisOffset),
                     standardHigh[matchOffset],
                     "DNA " + str.tostring(matchSimilarity, "#") + "%",
                     xloc=xloc.bar_index,
                     yloc=yloc.price,
                     style=label.style_label_down,
                     color=color.new(headerColor, 15),
                     textcolor=textColor,
                     size=size.tiny)
                array.push(analogLabels, matchLabel)

    // Deterministic same-symbol baseline. Ordinary historical starting points
    // are spaced far enough apart to avoid overlapping forward test windows.
    // The same target, stop, conservative intrabar convention, and forward
    // horizon used for the analogs are applied to every baseline observation.
    int baselineTargetFirstCount = 0
    int baselineStopFirstCount = 0
    int baselineNeitherCount = 0
    int baselineValidCount = 0
    int baselineSpacing = math.max(forwardBars, minimumMatchSeparation)

    if historyLookback >= minimumCandidateOffset
        for baselineOffset = minimumCandidateOffset to historyLookback
            bool baselineSampleBar = (baselineOffset - minimumCandidateOffset) % baselineSpacing == 0
            bool baselineDataValid = baselineSampleBar and not na(standardClose[baselineOffset]) and not na(standardClose[baselineOffset - forwardBars])

            if baselineDataValid
                baselineValidCount += 1
                float baselineEntry = standardClose[baselineOffset]
                float baselineTarget = baselineEntry * (1.0 + targetPercent / 100.0)
                float baselineStop = baselineEntry * (1.0 - stopPercent / 100.0)
                bool baselineResolved = false

                for baselineStep = 1 to forwardBars
                    if not baselineResolved
                        bool baselineStopHit = standardLow[baselineOffset - baselineStep] <= baselineStop
                        bool baselineTargetHit = standardHigh[baselineOffset - baselineStep] >= baselineTarget
                        if baselineStopHit
                            baselineStopFirstCount += 1
                            baselineResolved := true
                        else if baselineTargetHit
                            baselineTargetFirstCount += 1
                            baselineResolved := true

                if not baselineResolved
                    baselineNeitherCount += 1

    float averageSimilarity = validMatches > 0 ? similarityTotal / validMatches : na
    float targetFirstRate = validMatches > 0 ? targetFirstCount * 100.0 / validMatches : na
    float stopFirstRate = validMatches > 0 ? stopFirstCount * 100.0 / validMatches : na
    float neitherRate = validMatches > 0 ? neitherCount * 100.0 / validMatches : na
    float baselineTargetFirstRate = baselineValidCount > 0 ? baselineTargetFirstCount * 100.0 / baselineValidCount : na
    float baselineStopFirstRate = baselineValidCount > 0 ? baselineStopFirstCount * 100.0 / baselineValidCount : na
    float baselineNeitherRate = baselineValidCount > 0 ? baselineNeitherCount * 100.0 / baselineValidCount : na
    float targetFirstEdge = not na(targetFirstRate) and not na(baselineTargetFirstRate) ? targetFirstRate - baselineTargetFirstRate : na
    float medianForwardReturn = f_percentile(forwardReturns, 0.50)
    float medianMaximumUpside = f_percentile(maximumUpsides, 0.50)
    float medianMaximumDrawdown = f_percentile(maximumDrawdowns, 0.50)
    float analogStopDrawdown = f_percentile(maximumDrawdowns, 1.0 - stopCoveragePercent / 100.0)
    float analogStopDistancePercent = na(analogStopDrawdown) ? na : f_clamp(math.abs(analogStopDrawdown), 0.5, 25.0)
    float rewardRisk = stopPercent != 0 ? targetPercent / stopPercent : na

    // Sample Quality measures the reliability of the historical sample, not
    // whether its direction is bullish or bearish. It combines sample size,
    // similarity, agreement among outcomes, and separation between episodes.
    float matchCoverageScore = requestedMatches > 0 ? f_clamp(validMatches * 100.0 / requestedMatches, 0.0, 100.0) : 0.0
    float similarityQualityScore = na(averageSimilarity) ? 0.0 : f_clamp(averageSimilarity, 0.0, 100.0)
    float outcomeAgreementScore = validMatches > 0 ? math.max(targetFirstRate, math.max(stopFirstRate, neitherRate)) : 0.0
    float independenceScore = forwardBars > 0 ? f_clamp(minimumMatchSeparation * 100.0 / forwardBars, 0.0, 100.0) : 0.0
    float sampleQualityScore = matchCoverageScore * 0.30 + similarityQualityScore * 0.30 + outcomeAgreementScore * 0.25 + independenceScore * 0.15
    string sampleQualityGrade = validMatches < minimumMatchesForVerdict ? "LOW" : sampleQualityScore >= 80 ? "HIGH" : sampleQualityScore >= 65 ? "MODERATE" : "LOW"

    string confidence = validMatches < minimumMatchesForVerdict ? "LOW" : averageSimilarity >= 80 ? "HIGH" : averageSimilarity >= 70 ? "MODERATE" : "LOW"
    bool enoughEvidence = validMatches >= minimumMatchesForVerdict and baselineValidCount >= minimumBaselineSamples
    string verdict = not enoughEvidence ? "INSUFFICIENT DATA" : targetFirstEdge >= minimumEdgeForVerdict and medianForwardReturn > 0 ? "FAVORABLE" : targetFirstEdge <= -minimumEdgeForVerdict and medianForwardReturn < 0 ? "UNFAVORABLE" : "MIXED"
    color verdictColor = verdict == "FAVORABLE" ? bullishColor : verdict == "UNFAVORABLE" ? bearishColor : warningColor

    favorableAlert := barstate.isconfirmed and verdict == "FAVORABLE"

    //-------------------------------------------------------------------------
    // HISTORICAL OUTCOME CONE
    //-------------------------------------------------------------------------
    if showProjection and validMatches >= 3
        float previousMedianPrice = analysisPrice
        float previousUpperPrice = analysisPrice
        float previousLowerPrice = analysisPrice

        for projectionStep = 1 to forwardBars
            array<float> stepReturns = array.new_float()
            for projectionMatchIndex = 0 to requestedMatches - 1
                int projectionOffset = array.get(bestOffsets, projectionMatchIndex)
                float projectionSimilarity = f_clamp((1.0 - array.get(bestDistances, projectionMatchIndex)) * 100.0, 0.0, 100.0)
                if projectionOffset > 0 and projectionSimilarity >= minimumSimilarity
                    float stepReturn = standardClose[projectionOffset - projectionStep] / standardClose[projectionOffset] - 1.0
                    array.push(stepReturns, stepReturn)

            float lowerReturn = f_percentile(stepReturns, 0.25)
            float medianReturn = f_percentile(stepReturns, 0.50)
            float upperReturn = f_percentile(stepReturns, 0.75)
            float lowerPrice = analysisPrice * (1.0 + lowerReturn)
            float medianPrice = analysisPrice * (1.0 + medianReturn)
            float upperPrice = analysisPrice * (1.0 + upperReturn)

            line medianSegment = line.new(analysisBarIndex + projectionStep - 1, previousMedianPrice, analysisBarIndex + projectionStep, medianPrice, xloc=xloc.bar_index, color=medianColor, width=projectionWidth)
            line upperSegment = line.new(analysisBarIndex + projectionStep - 1, previousUpperPrice, analysisBarIndex + projectionStep, upperPrice, xloc=xloc.bar_index, color=color.new(upperColor, 20), width=1, style=line.style_dashed)
            line lowerSegment = line.new(analysisBarIndex + projectionStep - 1, previousLowerPrice, analysisBarIndex + projectionStep, lowerPrice, xloc=xloc.bar_index, color=color.new(lowerColor, 20), width=1, style=line.style_dashed)
            array.push(medianProjectionLines, medianSegment)
            array.push(upperProjectionLines, upperSegment)
            array.push(lowerProjectionLines, lowerSegment)

            previousMedianPrice := medianPrice
            previousUpperPrice := upperPrice
            previousLowerPrice := lowerPrice

    //-------------------------------------------------------------------------
    // CURRENT TARGET AND STOP
    //-------------------------------------------------------------------------
    float currentTarget = analysisPrice * (1.0 + targetPercent / 100.0)
    float currentStop = analysisPrice * (1.0 - stopPercent / 100.0)
    float analogStopPrice = na(analogStopDistancePercent) ? na : analysisPrice * (1.0 - analogStopDistancePercent / 100.0)
    if showTradeLevels
        line targetLine = line.new(analysisBarIndex, currentTarget, analysisBarIndex + forwardBars, currentTarget, xloc=xloc.bar_index, color=bullishColor, width=2, style=line.style_dotted)
        line stopLine = line.new(analysisBarIndex, currentStop, analysisBarIndex + forwardBars, currentStop, xloc=xloc.bar_index, color=bearishColor, width=2, style=line.style_dotted)
        array.push(tradeLevelLines, targetLine)
        array.push(tradeLevelLines, stopLine)
        if not na(analogStopPrice)
            line analogStopLine = line.new(analysisBarIndex, analogStopPrice, analysisBarIndex + forwardBars, analogStopPrice, xloc=xloc.bar_index, color=warningColor, width=2, style=line.style_dashed)
            array.push(tradeLevelLines, analogStopLine)

    //-------------------------------------------------------------------------
    // DASHBOARD
    //-------------------------------------------------------------------------
    table.cell(dashboard, 0, 0, "PATTERN ECHO", text_color=textColor, bgcolor=headerColor, text_size=size.large)
    table.cell(dashboard, 0, 1, "Analyzed candle", text_color=textColor, bgcolor=labelColor)
    table.cell(dashboard, 1, 1, str.format_time(time[analysisOffset], "MMM dd, yyyy HH:mm", syminfo.timezone), text_color=textColor, bgcolor=neutralColor)
    table.cell(dashboard, 0, 2, "Best similarity", text_color=textColor, bgcolor=labelColor)
    table.cell(dashboard, 1, 2, f_formatPercent(bestSimilarity), text_color=textColor, bgcolor=f_cellColor(bestSimilarity, 80, 60))
    table.cell(dashboard, 0, 3, "Average similarity", text_color=textColor, bgcolor=labelColor)
    table.cell(dashboard, 1, 3, f_formatPercent(averageSimilarity) + "  " + confidence, text_color=textColor, bgcolor=f_cellColor(averageSimilarity, 75, 60))
    table.cell(dashboard, 0, 4, "Independent matches", text_color=textColor, bgcolor=labelColor)
    table.cell(dashboard, 1, 4, str.tostring(validMatches) + " / " + str.tostring(requestedMatches), text_color=textColor, bgcolor=validMatches >= minimumMatchesForVerdict ? bullishColor : warningColor)
    table.cell(dashboard, 0, 5, "Sample quality", text_color=textColor, bgcolor=labelColor)
    table.cell(dashboard, 1, 5, str.tostring(sampleQualityScore, "#") + " / 100  " + sampleQualityGrade, text_color=textColor, bgcolor=sampleQualityScore >= 80 and validMatches >= minimumMatchesForVerdict ? bullishColor : sampleQualityScore >= 65 ? warningColor : bearishColor)
    table.cell(dashboard, 0, 6, "Target reached first", text_color=textColor, bgcolor=labelColor)
    table.cell(dashboard, 1, 6, f_formatPercent(targetFirstRate), text_color=textColor, bgcolor=f_cellColor(targetFirstRate, 60, 35))
    table.cell(dashboard, 0, 7, "Target edge vs baseline", text_color=textColor, bgcolor=labelColor)
    table.cell(dashboard, 1, 7, na(targetFirstEdge) ? "N/A" : f_formatPercent(targetFirstEdge) + "  (base " + f_formatPercent(baselineTargetFirstRate) + ", n=" + str.tostring(baselineValidCount) + ")", text_color=textColor, bgcolor=f_cellColor(targetFirstEdge, minimumEdgeForVerdict, -minimumEdgeForVerdict))
    table.cell(dashboard, 0, 8, "Stop reached first", text_color=textColor, bgcolor=labelColor)
    table.cell(dashboard, 1, 8, f_formatPercent(stopFirstRate), text_color=textColor, bgcolor=na(stopFirstRate) ? neutralColor : stopFirstRate <= baselineStopFirstRate ? bullishColor : warningColor)
    table.cell(dashboard, 0, 9, "Neither reached", text_color=textColor, bgcolor=labelColor)
    table.cell(dashboard, 1, 9, f_formatPercent(neitherRate), text_color=textColor, bgcolor=neutralColor)
    table.cell(dashboard, 0, 10, "Median " + str.tostring(forwardBars) + "-bar return", text_color=textColor, bgcolor=labelColor)
    table.cell(dashboard, 1, 10, f_formatPercent(medianForwardReturn), text_color=textColor, bgcolor=f_cellColor(medianForwardReturn, 1.0, -1.0))
    table.cell(dashboard, 0, 11, "Median maximum upside", text_color=textColor, bgcolor=labelColor)
    table.cell(dashboard, 1, 11, f_formatPercent(medianMaximumUpside), text_color=textColor, bgcolor=f_cellColor(medianMaximumUpside, targetPercent, 0))
    table.cell(dashboard, 0, 12, "Median maximum drawdown", text_color=textColor, bgcolor=labelColor)
    table.cell(dashboard, 1, 12, f_formatPercent(medianMaximumDrawdown), text_color=textColor, bgcolor=na(medianMaximumDrawdown) ? neutralColor : medianMaximumDrawdown >= -stopPercent ? bullishColor : bearishColor)
    table.cell(dashboard, 0, 13, "Current entry / target / stop", text_color=textColor, bgcolor=labelColor)
    table.cell(dashboard, 1, 13, f_formatPrice(analysisPrice) + " / " + f_formatPrice(currentTarget) + " / " + f_formatPrice(currentStop), text_color=textColor, bgcolor=neutralColor)
    table.cell(dashboard, 0, 14, "Reward / risk", text_color=textColor, bgcolor=labelColor)
    table.cell(dashboard, 1, 14, f_formatNumber(rewardRisk) + "x", text_color=textColor, bgcolor=rewardRisk >= 2 ? bullishColor : rewardRisk >= 1 ? warningColor : bearishColor)
    table.cell(dashboard, 0, 15, "Analog stop (" + str.tostring(stopCoveragePercent) + "% coverage)", text_color=textColor, bgcolor=labelColor)
    table.cell(dashboard, 1, 15, na(analogStopPrice) ? "N/A" : f_formatPrice(analogStopPrice) + "  (-" + f_formatPercent(analogStopDistancePercent) + ")", text_color=textColor, bgcolor=warningColor)
    table.cell(dashboard, 0, 16, "Historical verdict", text_color=textColor, bgcolor=labelColor)
    table.cell(dashboard, 1, 16, verdict, text_color=textColor, bgcolor=verdictColor, text_size=size.large)
    table.cell(dashboard, 0, 17, "Closest historical dates", text_color=textColor, bgcolor=labelColor)
    table.cell(dashboard, 1, 17, closestDates == "" ? "N/A" : closestDates, text_color=textColor, bgcolor=neutralColor)

alertcondition(favorableAlert, title="Pattern Echo Favorable Historical Outcome", message="Pattern Echo has identified a favorable historical-analog outcome on {{ticker}} {{interval}}.")
````
