# Multi Asset Momentum Screener [Pineify]

- url: https://www.tradingview.com/script/a0sBpobx-Multi-Asset-Momentum-Screener-Pineify/
- type: indicator
- pine_id: PUB;ebe9bfc54e474831b7c6bda9313013e9
- version: 1.0

## Description

[b]Overview[/b]
This screener compares twelve markets and ranks volatility-adjusted momentum only when coverage and timing pass. The heat table is primary; the chart-symbol score is the audit trail.

[b]Problem Definition[/b]
A raw return leaderboard hides scale, horizon, and timing. The same move can be ordinary for a volatile asset and unusual for a quiet one. A recent jump may oppose slower momentum, while carried prices from different sessions can appear synchronized. One rank cannot show persistence. The model must normalize risk, expose conflict, reject incomplete or relatively stale rows, and remember rank movement without treating it as a forecast.

[b]Design Rationale[/b]
Each horizon scales log return by one-bar realized volatility and square root of length, replacing raw sorting that favors volatile assets. Normalized weights combine readings; sign disagreement contracts the result, while a 35% floor preserves partial information. The -100 to +100 transform is not a probability. Timestamps and completeness replace blind forward filling. Stability updates only on a new requested-timeframe observation and confirmed chart bar. This delays abrupt rotations but avoids counting one unchanged value repeatedly.

[b]Key Features[/b]
[list]
[*]Twelve symbol slots with invalid-symbol tolerance.

[*]Three risk-scaled horizons with agreement and completeness gates.

[*]Relative freshness, sorted heat table, and rank-stability memory.

[*]Chart-symbol score plus top-rank and rank-change alerts.
[/list]

[b]How It Works[/b]
One-bar log returns feed rolling standard deviation. Each N-bar log return is divided by that deviation times square root of N. Zero or unavailable volatility yields no value, and effective horizons are forced into increasing order.

Available readings enter a normalized weighted average. Agreement is the absolute sign sum divided by the count available. Multiplying by 0.35 plus 0.65 times agreement contracts conflict. For value x, 100 x / (2 + abs(x)) creates the bounded score; completeness is the share of horizons present.

Each request returns its source time. The newest enabled time is the reference; rows outside the lag allowance are STALE. Only enabled, fresh, complete scores receive deterministic ranks. At each new confirmed reference time, normalized rank displacement enters exponential 0-100 stability memory. The chart symbol uses the same model and ranks against valid rows even when absent from the list. Requests use confirmed bars; no future data.

[b]How Multiple Indicators Work Together[/b]
The parts form one chain. Volatility makes returns comparable; three horizons reveal agreement; contraction stops averaging from hiding opposing signs; data gates decide admission; sorting supplies rank; and memory separates persistence from churn. Remove volatility and scale bias returns; remove gates and asynchronous samples mix; remove memory and only a transient leaderboard remains.

[b]Trading Ideas and Insights[/b]
An aligned high positive score describes broad upward risk-adjusted momentum in this model; opposing components reduce coherence and widen the envelope. High stability can separate persistent strength from a brief jump, while falling stability can reveal rotation. Negative readings work symmetrically. Use these states for watchlist triage, not as an entry, exit, position size, holding period, or expected-return instruction.

[b]Unique Aspects[/b]
The contribution is a synchronization-aware rank lattice. Admission depends on completeness and timing relative to the newest symbol, not on a carried value. Momentum strength is separated from rank-path stability, and memory advances only when the requested observation changes. The table exposes component risk units, making the score auditable. Originality lies in normalization, data-state handling, and rank memory rather than renaming momentum.

[b]How to Use[/b]
[list=1]
[*]Choose one timeframe suitable for every enabled market.

[*]Build a meaningful basket and inspect valid count plus Data status.

[*]Read Score with Short, Medium, Long, and Stable; withheld ranks are intentional.

[*]Use the chart spine for comparison; a wider envelope means more disagreement.

[*]Set alerts only after the basket and thresholds match your review.
[/list]

[b]Customization[/b]
Short horizons react faster but amplify gaps; long horizons need more history and lag more. Volatility Window changes the denominator's memory. Horizon weights change the analytical question, not just smoothness. Minimum Completeness decides whether two horizons suffice. Maximum Relative Data Lag controls mixed-session tolerance. Stability Memory trades faster rotation detection for steadier persistence. Visual switches do not alter calculations.

[b]Assumptions and Limitations[/b]
Log returns and rolling deviation may not suit every asset. Scaling does not equalize liquidity, tail risk, leverage, contract rolls, currencies, sessions, or costs. Permissions, holidays, delays, or limited history can make rows WARM or STALE; relative time is not an exchange calendar.

Scores lag one comparison bar. Memory and alerts require confirmation and a new reference time. Inputs or history can recalculate results. Rank is basket-relative, and duplicates can distort it. There is no backtest, probability, accuracy, or profitability evidence.

[b]Conclusion[/b]
Multi Asset Momentum Screener shows risk-adjusted momentum, data readiness, and persistence. Only complete, timely rows rank. It is research, not forecast or instruction.

## Source Code

````pine
//@version=6
indicator("Multi Asset Momentum Screener [Pineify]", overlay = false)

string groupUniverse = "Watchlist"
bool enable1 = input.bool(true, "Enable 1", inline = "s1", group = groupUniverse)
string symbol1 = input.symbol("AMEX:SPY", "Symbol 1", inline = "s1", group = groupUniverse)
bool enable2 = input.bool(true, "Enable 2", inline = "s2", group = groupUniverse)
string symbol2 = input.symbol("NASDAQ:QQQ", "Symbol 2", inline = "s2", group = groupUniverse)
bool enable3 = input.bool(true, "Enable 3", inline = "s3", group = groupUniverse)
string symbol3 = input.symbol("AMEX:IWM", "Symbol 3", inline = "s3", group = groupUniverse)
bool enable4 = input.bool(true, "Enable 4", inline = "s4", group = groupUniverse)
string symbol4 = input.symbol("AMEX:DIA", "Symbol 4", inline = "s4", group = groupUniverse)
bool enable5 = input.bool(true, "Enable 5", inline = "s5", group = groupUniverse)
string symbol5 = input.symbol("AMEX:EEM", "Symbol 5", inline = "s5", group = groupUniverse)
bool enable6 = input.bool(true, "Enable 6", inline = "s6", group = groupUniverse)
string symbol6 = input.symbol("NASDAQ:TLT", "Symbol 6", inline = "s6", group = groupUniverse)
bool enable7 = input.bool(true, "Enable 7", inline = "s7", group = groupUniverse)
string symbol7 = input.symbol("AMEX:GLD", "Symbol 7", inline = "s7", group = groupUniverse)
bool enable8 = input.bool(true, "Enable 8", inline = "s8", group = groupUniverse)
string symbol8 = input.symbol("AMEX:USO", "Symbol 8", inline = "s8", group = groupUniverse)
bool enable9 = input.bool(true, "Enable 9", inline = "s9", group = groupUniverse)
string symbol9 = input.symbol("COINBASE:BTCUSD", "Symbol 9", inline = "s9", group = groupUniverse)
bool enable10 = input.bool(true, "Enable 10", inline = "s10", group = groupUniverse)
string symbol10 = input.symbol("COINBASE:ETHUSD", "Symbol 10", inline = "s10", group = groupUniverse)
bool enable11 = input.bool(true, "Enable 11", inline = "s11", group = groupUniverse)
string symbol11 = input.symbol("OANDA:EURUSD", "Symbol 11", inline = "s11", group = groupUniverse)
bool enable12 = input.bool(true, "Enable 12", inline = "s12", group = groupUniverse)
string symbol12 = input.symbol("TVC:DXY", "Symbol 12", inline = "s12", group = groupUniverse)

string groupModel = "Momentum Model"
string comparisonTimeframeInput = input.timeframe("D", "Comparison Timeframe", options = ["240", "D", "W"], group = groupModel)
int shortLengthInput = input.int(10, "Short Horizon", minval = 2, maxval = 100, group = groupModel)
int mediumLengthInput = input.int(30, "Medium Horizon", minval = 3, maxval = 180, group = groupModel)
int longLengthInput = input.int(90, "Long Horizon", minval = 5, maxval = 300, group = groupModel)
int volatilityLengthInput = input.int(63, "Realized Volatility Window", minval = 10, maxval = 300, group = groupModel)
float shortWeightInput = input.float(0.45, "Short Weight", minval = 0.0, maxval = 1.0, step = 0.05, group = groupModel)
float mediumWeightInput = input.float(0.35, "Medium Weight", minval = 0.0, maxval = 1.0, step = 0.05, group = groupModel)
float longWeightInput = input.float(0.20, "Long Weight", minval = 0.0, maxval = 1.0, step = 0.05, group = groupModel)
float minimumCompletenessInput = input.float(66.0, "Minimum Horizon Completeness %", minval = 34.0, maxval = 100.0, step = 1.0, group = groupModel)
int maximumLagBarsInput = input.int(1, "Maximum Relative Data Lag", minval = 0, maxval = 5, group = groupModel)
int stabilityMemoryInput = input.int(8, "Rank Stability Memory", minval = 2, maxval = 50, group = groupModel)

string groupAlerts = "Alerts"
int topRankInput = input.int(3, "Chart Symbol Top Rank", minval = 1, maxval = 12, group = groupAlerts)
int rankJumpInput = input.int(3, "Chart Symbol Rank Jump", minval = 1, maxval = 11, group = groupAlerts)

string groupVisual = "Visual System"
bool showRankTableInput = input.bool(true, "Show Ranked Heat Table", group = groupVisual)
bool showAgreementEnvelopeInput = input.bool(true, "Show Chart Agreement Envelope", group = groupVisual)
bool showRankMarkersInput = input.bool(true, "Show Confirmed Rank Markers", group = groupVisual)
bool showPaneBackgroundInput = input.bool(true, "Show Chart Score Background", group = groupVisual)

color positiveColor = color.rgb(0, 178, 166)
color negativeColor = color.rgb(238, 86, 92)
color stableColor = color.rgb(84, 155, 255)
color rotationColor = color.rgb(244, 181, 55)
color neutralColor = color.rgb(112, 124, 143)
color unavailableColor = color.rgb(82, 89, 103)

int effectiveShortLength = shortLengthInput
int effectiveMediumLength = math.max(mediumLengthInput, effectiveShortLength + 1)
int effectiveLongLength = math.max(longLengthInput, effectiveMediumLength + 1)
float configuredWeightSum = shortWeightInput + mediumWeightInput + longWeightInput
float effectiveShortWeight = configuredWeightSum > 0.0 ? shortWeightInput / configuredWeightSum : 1.0 / 3.0
float effectiveMediumWeight = configuredWeightSum > 0.0 ? mediumWeightInput / configuredWeightSum : 1.0 / 3.0
float effectiveLongWeight = configuredWeightSum > 0.0 ? longWeightInput / configuredWeightSum : 1.0 / 3.0

f_clamp(float value, float lower, float upper) =>
    math.min(math.max(value, lower), upper)

f_model() =>
    float oneBarReturn = close > 0.0 and close[1] > 0.0 ? math.log(close / close[1]) : na
    float realizedVolatility = ta.stdev(oneBarReturn, volatilityLengthInput)
    float shortRiskMomentum = close > 0.0 and close[effectiveShortLength] > 0.0 and realizedVolatility > 0.0 ? math.log(close / close[effectiveShortLength]) / (realizedVolatility * math.sqrt(float(effectiveShortLength))) : na
    float mediumRiskMomentum = close > 0.0 and close[effectiveMediumLength] > 0.0 and realizedVolatility > 0.0 ? math.log(close / close[effectiveMediumLength]) / (realizedVolatility * math.sqrt(float(effectiveMediumLength))) : na
    float longRiskMomentum = close > 0.0 and close[effectiveLongLength] > 0.0 and realizedVolatility > 0.0 ? math.log(close / close[effectiveLongLength]) / (realizedVolatility * math.sqrt(float(effectiveLongLength))) : na
    int validHorizons = (not na(shortRiskMomentum) ? 1 : 0) + (not na(mediumRiskMomentum) ? 1 : 0) + (not na(longRiskMomentum) ? 1 : 0)
    float availableWeight = (not na(shortRiskMomentum) ? effectiveShortWeight : 0.0) + (not na(mediumRiskMomentum) ? effectiveMediumWeight : 0.0) + (not na(longRiskMomentum) ? effectiveLongWeight : 0.0)
    float weightedMomentum = availableWeight > 0.0 ? ((not na(shortRiskMomentum) ? shortRiskMomentum * effectiveShortWeight : 0.0) + (not na(mediumRiskMomentum) ? mediumRiskMomentum * effectiveMediumWeight : 0.0) + (not na(longRiskMomentum) ? longRiskMomentum * effectiveLongWeight : 0.0)) / availableWeight : na
    float signSum = (not na(shortRiskMomentum) ? math.sign(shortRiskMomentum) : 0.0) + (not na(mediumRiskMomentum) ? math.sign(mediumRiskMomentum) : 0.0) + (not na(longRiskMomentum) ? math.sign(longRiskMomentum) : 0.0)
    float agreement = validHorizons > 0 ? 100.0 * math.abs(signSum) / float(validHorizons) : na
    float completeness = 100.0 * float(validHorizons) / 3.0
    float contractedMomentum = not na(weightedMomentum) and not na(agreement) ? weightedMomentum * (0.35 + 0.65 * agreement / 100.0) : na
    float boundedScore = not na(contractedMomentum) ? 100.0 * contractedMomentum / (2.0 + math.abs(contractedMomentum)) : na
    [boundedScore[1], shortRiskMomentum[1], mediumRiskMomentum[1], longRiskMomentum[1], agreement[1], completeness[1], time[1]]

[score1, short1, medium1, long1, agreement1, completeness1, sourceTime1] = request.security(symbol1, comparisonTimeframeInput, f_model(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
[score2, short2, medium2, long2, agreement2, completeness2, sourceTime2] = request.security(symbol2, comparisonTimeframeInput, f_model(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
[score3, short3, medium3, long3, agreement3, completeness3, sourceTime3] = request.security(symbol3, comparisonTimeframeInput, f_model(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
[score4, short4, medium4, long4, agreement4, completeness4, sourceTime4] = request.security(symbol4, comparisonTimeframeInput, f_model(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
[score5, short5, medium5, long5, agreement5, completeness5, sourceTime5] = request.security(symbol5, comparisonTimeframeInput, f_model(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
[score6, short6, medium6, long6, agreement6, completeness6, sourceTime6] = request.security(symbol6, comparisonTimeframeInput, f_model(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
[score7, short7, medium7, long7, agreement7, completeness7, sourceTime7] = request.security(symbol7, comparisonTimeframeInput, f_model(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
[score8, short8, medium8, long8, agreement8, completeness8, sourceTime8] = request.security(symbol8, comparisonTimeframeInput, f_model(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
[score9, short9, medium9, long9, agreement9, completeness9, sourceTime9] = request.security(symbol9, comparisonTimeframeInput, f_model(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
[score10, short10, medium10, long10, agreement10, completeness10, sourceTime10] = request.security(symbol10, comparisonTimeframeInput, f_model(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
[score11, short11, medium11, long11, agreement11, completeness11, sourceTime11] = request.security(symbol11, comparisonTimeframeInput, f_model(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
[score12, short12, medium12, long12, agreement12, completeness12, sourceTime12] = request.security(symbol12, comparisonTimeframeInput, f_model(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
[chartScoreRaw, chartShort, chartMedium, chartLong, chartAgreement, chartCompleteness, chartSourceTime] = request.security(syminfo.tickerid, comparisonTimeframeInput, f_model(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

array<bool> enabled = array.from(enable1, enable2, enable3, enable4, enable5, enable6, enable7, enable8, enable9, enable10, enable11, enable12)
array<string> symbols = array.from(symbol1, symbol2, symbol3, symbol4, symbol5, symbol6, symbol7, symbol8, symbol9, symbol10, symbol11, symbol12)
array<float> rawScores = array.from(score1, score2, score3, score4, score5, score6, score7, score8, score9, score10, score11, score12)
array<float> shortScores = array.from(short1, short2, short3, short4, short5, short6, short7, short8, short9, short10, short11, short12)
array<float> mediumScores = array.from(medium1, medium2, medium3, medium4, medium5, medium6, medium7, medium8, medium9, medium10, medium11, medium12)
array<float> longScores = array.from(long1, long2, long3, long4, long5, long6, long7, long8, long9, long10, long11, long12)
array<float> agreements = array.from(agreement1, agreement2, agreement3, agreement4, agreement5, agreement6, agreement7, agreement8, agreement9, agreement10, agreement11, agreement12)
array<float> completenessValues = array.from(completeness1, completeness2, completeness3, completeness4, completeness5, completeness6, completeness7, completeness8, completeness9, completeness10, completeness11, completeness12)
array<int> sourceTimes = array.from(sourceTime1, sourceTime2, sourceTime3, sourceTime4, sourceTime5, sourceTime6, sourceTime7, sourceTime8, sourceTime9, sourceTime10, sourceTime11, sourceTime12)

int latestSourceTime = na
for index = 0 to 11
    int candidateTime = array.get(sourceTimes, index)
    if array.get(enabled, index) and not na(candidateTime)
        latestSourceTime := na(latestSourceTime) ? candidateTime : math.max(latestSourceTime, candidateTime)

int comparisonSeconds = timeframe.in_seconds(comparisonTimeframeInput)
int allowedLagMilliseconds = comparisonSeconds * 1000 * maximumLagBarsInput
array<bool> fresh = array.new_bool(12, false)
array<float> scores = array.new_float(12, na)
int enabledCount = 0
int validCount = 0
for index = 0 to 11
    bool isEnabled = array.get(enabled, index)
    float candidateScore = array.get(rawScores, index)
    float candidateCompleteness = array.get(completenessValues, index)
    int candidateTime = array.get(sourceTimes, index)
    bool isFresh = isEnabled and not na(latestSourceTime) and not na(candidateTime) and latestSourceTime - candidateTime <= allowedLagMilliseconds
    bool isValid = isFresh and not na(candidateScore) and candidateCompleteness >= minimumCompletenessInput
    array.set(fresh, index, isFresh)
    array.set(scores, index, isValid ? candidateScore : na)
    enabledCount += isEnabled ? 1 : 0
    validCount += isValid ? 1 : 0

array<int> ranks = array.new_int(12, na)
for index = 0 to 11
    float candidateScore = array.get(scores, index)
    if not na(candidateScore)
        int candidateRank = 1
        for comparisonIndex = 0 to 11
            float comparisonScore = array.get(scores, comparisonIndex)
            if not na(comparisonScore) and (comparisonScore > candidateScore or (comparisonScore == candidateScore and comparisonIndex < index))
                candidateRank += 1
        array.set(ranks, index, candidateRank)

array<int> displayOrder = array.from(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11)
for left = 0 to 10
    for right = left + 1 to 11
        int leftIndex = array.get(displayOrder, left)
        int rightIndex = array.get(displayOrder, right)
        float leftScore = array.get(scores, leftIndex)
        float rightScore = array.get(scores, rightIndex)
        bool leftEnabled = array.get(enabled, leftIndex)
        bool rightEnabled = array.get(enabled, rightIndex)
        bool shouldSwap = (not leftEnabled and rightEnabled) or (leftEnabled and rightEnabled and na(leftScore) and not na(rightScore)) or (not na(leftScore) and not na(rightScore) and rightScore > leftScore)
        if shouldSwap
            array.set(displayOrder, left, rightIndex)
            array.set(displayOrder, right, leftIndex)

var array<float> rankStability = array.new_float(12, na)
var array<int> previousRanks = array.new_int(12, na)
var array<int> rankDeltas = array.new_int(12, 0)
var int lastProcessedSourceTime = na
bool newObservation = barstate.isconfirmed and not na(latestSourceTime) and latestSourceTime != lastProcessedSourceTime
if newObservation
    float stabilityAlpha = 2.0 / (float(stabilityMemoryInput) + 1.0)
    for index = 0 to 11
        int currentRank = array.get(ranks, index)
        int previousRank = array.get(previousRanks, index)
        if not na(currentRank)
            int rankDelta = not na(previousRank) ? previousRank - currentRank : 0
            float instantaneousStability = not na(previousRank) and validCount > 1 ? 100.0 * (1.0 - math.min(math.abs(float(rankDelta)) / float(validCount - 1), 1.0)) : 100.0
            float previousStability = array.get(rankStability, index)
            float updatedStability = na(previousStability) ? instantaneousStability : previousStability + stabilityAlpha * (instantaneousStability - previousStability)
            array.set(rankDeltas, index, rankDelta)
            array.set(rankStability, index, updatedStability)
            array.set(previousRanks, index, currentRank)
        else
            array.set(rankDeltas, index, 0)
    lastProcessedSourceTime := latestSourceTime

bool chartFresh = not na(latestSourceTime) and not na(chartSourceTime) and latestSourceTime - chartSourceTime <= allowedLagMilliseconds
bool chartReady = chartFresh and not na(chartScoreRaw) and chartCompleteness >= minimumCompletenessInput
float chartScore = chartReady ? chartScoreRaw : na
int chartRank = na
if chartReady
    chartRank := 1
    for index = 0 to 11
        float candidateScore = array.get(scores, index)
        if not na(candidateScore) and candidateScore > chartScore
            chartRank += 1

var int previousChartRank = na
bool chartEnteredTop = false
bool chartRankJumped = false
int chartRankDelta = 0
if newObservation and chartReady
    chartRankDelta := not na(previousChartRank) ? previousChartRank - chartRank : 0
    chartEnteredTop := not na(previousChartRank) and chartRank <= topRankInput and previousChartRank > topRankInput
    chartRankJumped := not na(previousChartRank) and math.abs(chartRankDelta) >= rankJumpInput
    previousChartRank := chartRank

float agreementRadius = chartReady ? 3.0 + 15.0 * (1.0 - chartAgreement / 100.0) : na
float envelopeUpper = chartReady ? f_clamp(chartScore + agreementRadius, -100.0, 100.0) : na
float envelopeLower = chartReady ? f_clamp(chartScore - agreementRadius, -100.0, 100.0) : na
color chartScoreColor = chartReady ? color.from_gradient(chartScore, -100.0, 100.0, negativeColor, positiveColor) : unavailableColor
int envelopeTransparency = chartReady ? int(math.round(f_clamp(88.0 - 24.0 * chartCompleteness / 100.0, 60.0, 90.0))) : 90

hline(0.0, "Neutral Axis", color = color.new(neutralColor, 58), linestyle = hline.style_dotted)
hline(50.0, "Positive Momentum Zone", color = color.new(positiveColor, 80), linestyle = hline.style_dashed)
hline(-50.0, "Negative Momentum Zone", color = color.new(negativeColor, 80), linestyle = hline.style_dashed)
hline(100.0, "Upper Bound", color = color.new(neutralColor, 90))
hline(-100.0, "Lower Bound", color = color.new(neutralColor, 90))

upperEnvelopePlot = plot(showAgreementEnvelopeInput ? envelopeUpper : na, "Agreement Envelope Upper", color = color.new(chartScoreColor, 82), linewidth = 1)
lowerEnvelopePlot = plot(showAgreementEnvelopeInput ? envelopeLower : na, "Agreement Envelope Lower", color = color.new(chartScoreColor, 82), linewidth = 1)
fill(upperEnvelopePlot, lowerEnvelopePlot, color = showAgreementEnvelopeInput and chartReady ? color.new(chartScoreColor, envelopeTransparency) : na, title = "Horizon Disagreement Envelope")
plot(chartScore, "Chart Symbol Risk Adjusted Momentum", color = color.new(chartScoreColor, 78), linewidth = 8)
plot(chartScore, "Chart Symbol Score Spine", color = chartScoreColor, linewidth = 3)
bgcolor(showPaneBackgroundInput and chartReady ? color.new(chartScoreColor, 94) : na, title = "Chart Score Background")
plotshape(showRankMarkersInput and chartEnteredTop, title = "Chart Symbol Entered Top Rank", style = shape.triangleup, location = location.bottom, color = positiveColor, size = size.tiny, text = "TOP")
plotshape(showRankMarkersInput and chartRankJumped and chartRankDelta < 0, title = "Chart Symbol Rank Dropped", style = shape.triangledown, location = location.top, color = negativeColor, size = size.tiny, text = "R-")

alertcondition(chartEnteredTop, "Chart Symbol Entered Top Rank", "The chart symbol entered the configured top rank against the enabled watchlist on a confirmed comparison-timeframe observation.")
alertcondition(chartRankJumped, "Chart Symbol Rank Changed", "The chart symbol rank changed by at least the configured number of places on a confirmed comparison-timeframe observation.")

f_status(bool isEnabled, bool isFresh, float completeness, float score) =>
    not isEnabled ? "OFF" : not isFresh ? "STALE" : na(score) or completeness < minimumCompletenessInput ? "WARM" : "READY"

f_metric(float value) =>
    na(value) ? "--" : str.tostring(value, "#.00")

var table screener = table.new(position.top_right, 8, 14, border_width = 1)
if barstate.islast
    table.clear(screener, 0, 0, 7, 13)
    if showRankTableInput
        color headerBackground = color.new(neutralColor, 34)
        table.cell(screener, 0, 0, "MOMENTUM RANK", text_color = chart.fg_color, bgcolor = headerBackground, text_size = size.small)
        table.cell(screener, 1, 0, comparisonTimeframeInput, text_color = chart.fg_color, bgcolor = headerBackground, text_size = size.small)
        table.cell(screener, 2, 0, str.tostring(validCount) + "/" + str.tostring(enabledCount) + " valid", text_color = chart.fg_color, bgcolor = headerBackground, text_size = size.small)
        table.cell(screener, 3, 0, "S " + str.tostring(effectiveShortLength), text_color = chart.fg_color, bgcolor = headerBackground, text_size = size.small)
        table.cell(screener, 4, 0, "M " + str.tostring(effectiveMediumLength), text_color = chart.fg_color, bgcolor = headerBackground, text_size = size.small)
        table.cell(screener, 5, 0, "L " + str.tostring(effectiveLongLength), text_color = chart.fg_color, bgcolor = headerBackground, text_size = size.small)
        table.cell(screener, 6, 0, "Rank memory", text_color = chart.fg_color, bgcolor = headerBackground, text_size = size.small)
        table.cell(screener, 7, 0, barstate.isconfirmed ? "CLOSED" : "LIVE", text_color = chart.fg_color, bgcolor = headerBackground, text_size = size.small)
        table.cell(screener, 0, 1, "#", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(screener, 1, 1, "Symbol", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(screener, 2, 1, "Score", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(screener, 3, 1, "Short", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(screener, 4, 1, "Medium", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(screener, 5, 1, "Long", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(screener, 6, 1, "Stable", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        table.cell(screener, 7, 1, "Data", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 8), text_size = size.tiny)
        int displayRow = 2
        for orderIndex = 0 to 11
            int index = array.get(displayOrder, orderIndex)
            bool isEnabled = array.get(enabled, index)
            if isEnabled
                float rowScore = array.get(scores, index)
                float rowAgreement = array.get(agreements, index)
                float rowCompleteness = array.get(completenessValues, index)
                float rowStability = array.get(rankStability, index)
                int rowRank = array.get(ranks, index)
                bool rowFresh = array.get(fresh, index)
                color scoreColor = not na(rowScore) ? color.from_gradient(rowScore, -100.0, 100.0, negativeColor, positiveColor) : unavailableColor
                color scoreBackground = not na(rowScore) ? color.new(scoreColor, int(math.round(f_clamp(82.0 - 28.0 * rowAgreement / 100.0, 48.0, 84.0)))) : color.new(unavailableColor, 76)
                color stabilityBackground = not na(rowStability) ? color.new(color.from_gradient(rowStability, 0.0, 100.0, rotationColor, stableColor), 66) : color.new(unavailableColor, 78)
                string statusText = f_status(isEnabled, rowFresh, rowCompleteness, rowScore)
                string completenessText = str.tostring(rowCompleteness, "#") + "% " + statusText
                table.cell(screener, 0, displayRow, not na(rowRank) ? str.tostring(rowRank) : "--", text_color = chart.fg_color, bgcolor = scoreBackground, text_size = size.tiny)
                table.cell(screener, 1, displayRow, array.get(symbols, index), text_color = chart.fg_color, bgcolor = scoreBackground, text_size = size.tiny)
                table.cell(screener, 2, displayRow, not na(rowScore) ? str.tostring(rowScore, "#.0") : "--", text_color = chart.fg_color, bgcolor = scoreBackground, text_size = size.tiny)
                table.cell(screener, 3, displayRow, f_metric(array.get(shortScores, index)), text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 10), text_size = size.tiny)
                table.cell(screener, 4, displayRow, f_metric(array.get(mediumScores, index)), text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 10), text_size = size.tiny)
                table.cell(screener, 5, displayRow, f_metric(array.get(longScores, index)), text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 10), text_size = size.tiny)
                table.cell(screener, 6, displayRow, not na(rowStability) ? str.tostring(rowStability, "#") + "%" : "--", text_color = chart.fg_color, bgcolor = stabilityBackground, text_size = size.tiny)
                table.cell(screener, 7, displayRow, completenessText, text_color = rowFresh ? chart.fg_color : rotationColor, bgcolor = color.new(chart.bg_color, 10), text_size = size.tiny)
                displayRow += 1
````
