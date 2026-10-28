# Equity Forecast Matrix Table

- url: https://www.tradingview.com/script/MYIldolI-Equity-Forecast-Matrix-Table/
- type: indicator
- pine_id: PUB;b10fe267e30c4383919c5bc15a8d2bc8
- version: 1.0

## Description

Publication Summary

Equity Forecast Table is a multi-factor daily and weekly swing-trading dashboard designed for equities. The indicator combines trend regime, price structure, volume behavior, regression positioning, volatility expansion, Fibonacci extensions and a k-nearest neighbors (kNN) forecast model into a compact table.

The purpose of the script is to give traders a structured read on current market bias, probable target zones, invalidation levels and confirmation quality without cluttering the chart with excessive projected lines or labels.

This indicator is intended for swing traders who want a cleaner way to evaluate:

Whether the current setup favors bulls or bears
Whether price structure supports continuation or reversal
Where the highest-probability target zones are located
Whether volume is confirming or weakening the setup
Where the broader forecast thesis becomes invalid
How current price compares to volatility-based and Fibonacci-based projections

The script is designed primarily for daily and weekly equity charts, though it can be applied to other timeframes for context.

Core Features
Multi-Factor Forecast Bias

The table produces a directional forecast bias based on a weighted blend of:

k-nearest neighbors (kNN) forecast
Higher-timeframe trend regime
Internal price structure
Volume confirmation
Regression trend behavior

The result is summarized as a bullish, bearish or neutral forecast bias.

kNN Forecast Model

The k-nearest neighbors (kNN) model compares the current setup against historical analogs and evaluates how similar prior setups resolved. The model uses recent price behavior, trend conditions and structural context to estimate the most likely directional path.

The table displays:

Forecast value
Confidence level
Sample count
Number of neighbors used

This gives the trader a read on both the model’s forecast and the quality of the historical comparison.

Structure Detection

The script evaluates internal market structure using concepts such as:

Break of Structure (BOS)
Change of Character (CHoCH)
Failed breakouts
Higher-low and lower-high behavior

This helps separate strong continuation structures from setups that are starting to weaken.

Volume Confirmation

The model includes volume behavior through:

Relative Volume (RVOL)
On-Balance Volume (OBV)

Volume is used as a confirmation layer. A bullish structure with rising OBV and expanding RVOL is stronger than a bullish structure on weak participation.

Ranked Target Zones

Rather than relying on a single price target, the indicator ranks multiple target zones. These zones are built from a blend of structure, volatility, regression and extension logic.

The table displays:

Ranked Target 1
Ranked Target 2
Ranked Target 3

Each target includes a probability-style score to help traders identify which zones are most relevant.

Invalidation Level

The indicator provides an invalidation level based on structure and Average True Range (ATR).

This level is not intended to be a mandatory stop-loss. It is the level where the broader model thesis is considered structurally wrong.

Volatility and Extension Projections

The table also includes:

ATR expansion target
Measured move target
Fibonacci 1.000 extension
Fibonacci 1.272 extension
Fibonacci 1.618 extension

These levels are intended to provide broader upside or downside context if price continues beyond the ranked target zones.

How to Read the Table

The table is organized into four columns:

Column	Meaning
Metric	The model component being evaluated
Value	The current reading for that metric
Context	Why the model is assigning that reading
Score	The confidence or contribution of that component

The table should be read from top to bottom.

Table Breakdown
Forecast Bias

This is the headline output of the model.

A bullish reading means the weighted model inputs favor upside continuation.
A bearish reading means the weighted model inputs favor downside continuation.
A neutral reading means the evidence is mixed or not strong enough to support a directional edge.

This should be treated as the model’s directional lean, not a standalone trade signal.

kNN Forecast

The k-nearest neighbors (kNN) row shows how the current setup compares to historical analogs.

Key fields:

Field	Meaning
Forecast %	Directional forecast output from similar historical setups
Confidence	Quality of the analog comparison
Samples	Number of historical samples available
Neighbors	Number of closest historical matches used

A higher-confidence reading with a full sample set is more reliable than a low-confidence reading with limited samples.

Structure

The structure row evaluates whether price action is internally bullish, bearish or neutral.

Common context readings include:

Reading	Meaning
Bull Structure	Price is maintaining constructive higher-low or breakout behavior
Bear Structure	Price is maintaining lower-high or breakdown behavior
CHoCH	Change of Character, suggesting trend behavior may be shifting
BOS	Break of Structure, confirming a directional break
Failed BOS	Price attempted to break structure but failed, often supporting the opposite side

Structure is one of the most important confirmation layers in the table.

Volume

The volume row measures whether participation supports the forecast.

Metric	Meaning
Relative Volume (RVOL)	Current volume compared with normal volume
On-Balance Volume (OBV)	Accumulation or distribution pressure

A bullish setup with rising OBV and strong RVOL is stronger than a bullish setup on weak volume.

A bearish setup with falling OBV and elevated RVOL suggests stronger distribution.

Regression

The regression row evaluates trend direction and price extension relative to the current regression path.

A rising regression trend supports bullish setups.
A falling regression trend supports bearish setups.
An extended regression position can warn that price may need to consolidate before continuing.

This row helps avoid chasing extended moves after the highest-quality entry has already passed.

Weekly Regime

The weekly regime row shows whether the higher timeframe supports or conflicts with the current setup.

Reading	Interpretation
Bullish weekly regime	Daily bullish setups have better continuation odds
Bearish weekly regime	Daily bearish setups have better continuation odds
Neutral weekly regime	Higher-timeframe confirmation is limited

This is especially important when using the script on daily charts.

Invalidation

The invalidation row shows the level where the model’s broader thesis is considered broken.

For bullish setups, a move below invalidation suggests the bullish structure has failed.
For bearish setups, a move above invalidation suggests the bearish structure has failed.

This is a model invalidation level, not automatically a trade stop. Traders should still apply their own position sizing, risk rules and execution framework.

Ranked Targets

The ranked target rows show the most relevant price zones based on the model.

Target	Use
Ranked Target 1	Nearest high-probability target or resistance/support zone
Ranked Target 2	Next continuation zone if Target 1 is accepted or broken
Ranked Target 3	Extended continuation zone

The ranked targets should be used as decision zones:

Take partial profits
Tighten risk
Reassess price behavior
Watch for rejection or continuation
Confirm with volume before assuming further extension
Projected High, Mid and Low

These rows estimate a broader forecast range based on the model’s historical analogs.

Projection	Meaning
Projected High	Upper path estimate
Projected Mid	Central path estimate
Projected Low	Lower path estimate

These should not be treated as guaranteed targets. They are scenario boundaries.

ATR Expansion

The Average True Range (ATR) expansion row estimates where price could reasonably move based on current volatility.

This is useful when it aligns with a ranked target. When ATR expansion and a ranked target point to the same area, that zone has stronger confluence.

Measured Move

The measured move row estimates a larger continuation target based on the prior structure range.

This is usually more aggressive than the nearest ranked target and should be treated as a secondary swing objective.

Fibonacci Extensions

The Fibonacci extension rows provide longer-range continuation references.

Common levels include:

Level	Meaning
Fib 1.000	Full measured extension
Fib 1.272	Higher continuation extension
Fib 1.618	Aggressive continuation extension

These levels become more relevant only after price clears nearer ranked targets.

Bull Score and Bear Score

The bull and bear scores summarize the weighted directional evidence.

The model weighting typically includes:

Component	Role
kNN forecast	Historical analog forecast
Regime	Higher-timeframe trend alignment
Structure	Current price action quality
Volume	Participation and confirmation

A strong bull score with a weak bear score favors upside continuation.
A strong bear score with a weak bull score favors downside continuation.
When both scores are close, the setup is mixed and should be treated with caution.

Practical Use

The table is best used as a structured trading checklist:

Start with Forecast Bias to identify the model’s directional lean.
Confirm with Structure to make sure price action supports the bias.
Check Volume to see whether participation confirms the move.
Use Ranked Targets as profit-taking or reassessment zones.
Use Invalidation to know where the broader model thesis is wrong.
Use ATR, measured move and Fibonacci extensions for broader context.

The strongest setups occur when forecast bias, structure, weekly regime and volume are all aligned.

Disclaimer

This script is for educational and informational purposes only. It does not provide financial advice or guarantee future price movement. Traders should use their own risk management, position sizing and trade execution rules. Historical analogs, statistical forecasts and technical levels are probabilistic tools, not certainties.

## Source Code

````pine
//@version=6
// Conceptually adapted from "AiTrend Pattern Matrix for kNN Forecasting"
// Original author: © aibitcointrend
// Original license: CC BY-NC-SA 4.0
//
// Equity rebuild:
// k-nearest neighbors pattern forecast, Break of Structure, Change of Character,
// Relative Volume, Average True Range normalization, weekly regime filter,
// regression context and independent target ranking.
//
// v1.4 table-only:
// All forecast targets, projection levels, invalidation and diagnostics are table-only.
// No projection cones, target lines, boxes, Fibonacci lines or chart labels are drawn.

indicator("Equity Forecast Matrix Table", shorttitle = "Equity Forecast Table", overlay = true, max_lines_count = 50, max_boxes_count = 10, max_labels_count = 50, max_bars_back = 5000)

//====================================================
// Enums
//====================================================

enum knn_weighting
    inverse_distance = "Inverse Distance"
    simple_average = "Simple Average"

enum table_pos
    top_right = "Top Right"
    top_left = "Top Left"
    bottom_right = "Bottom Right"
    bottom_left = "Bottom Left"

//====================================================
// Inputs
//====================================================

groupGeneral   = "General"
groupKnn       = "kNN Pattern Engine"
groupFeatures  = "Equity Features"
groupStructure = "Structure Engine"
groupRegime    = "Regression and Weekly Regime"
groupTargets   = "Target Ranking"
groupTable     = "Table Display"
groupAlerts    = "Alerts"

src = input.source(close, "Primary Forecast Source", group = groupGeneral)
forecastHorizon = input.int(10, "Forecast Horizon, Bars", minval = 2, maxval = 60, group = groupGeneral)
minDirectionalEdge = input.float(6.0, "Minimum Bull/Bear Edge", minval = 0.0, maxval = 30.0, step = 0.5, group = groupGeneral)

patternLength = input.int(20, "Pattern Length", minval = 5, maxval = 80, group = groupKnn)
dictionarySize = input.int(300, "Dictionary Size", minval = 50, maxval = 1000, step = 25, group = groupKnn)
neighbors = input.int(11, "Nearest Neighbors", minval = 1, maxval = 50, group = groupKnn)
weightingMode = input.enum(knn_weighting.inverse_distance, "Neighbor Weighting", group = groupKnn)
smoothPrediction = input.int(3, "Prediction Smoothing", minval = 1, maxval = 20, group = groupKnn)
trainingPurgeBars = input.int(1, "Training Purge Bars", minval = 0, maxval = 30, tooltip = "Adds a gap between the current pattern and newest completed training sample.", group = groupKnn)

atrLen = input.int(50, "ATR Length", minval = 10, maxval = 250, group = groupFeatures)
volLen = input.int(50, "Volume Average Length", minval = 10, maxval = 250, group = groupFeatures)
emaFeatureLen = input.int(20, "Trend Feature EMA", minval = 5, maxval = 100, group = groupFeatures)
useVolumeFeature = input.bool(true, "Use Volume Feature", group = groupFeatures)
useTrendFeature = input.bool(true, "Use Trend Position Feature", group = groupFeatures)

retWeight = input.float(0.30, "Return Feature Weight", minval = 0.0, maxval = 1.0, step = 0.05, group = groupFeatures)
rangeWeight = input.float(0.15, "Range Feature Weight", minval = 0.0, maxval = 1.0, step = 0.05, group = groupFeatures)
bodyWeight = input.float(0.20, "Body Feature Weight", minval = 0.0, maxval = 1.0, step = 0.05, group = groupFeatures)
wickWeight = input.float(0.15, "Wick Feature Weight", minval = 0.0, maxval = 1.0, step = 0.05, group = groupFeatures)
volumeWeight = input.float(0.10, "Volume Feature Weight", minval = 0.0, maxval = 1.0, step = 0.05, group = groupFeatures)
trendWeight = input.float(0.10, "Trend Position Feature Weight", minval = 0.0, maxval = 1.0, step = 0.05, group = groupFeatures)

pivotLen = input.int(5, "Internal Structure Pivot Length", minval = 2, maxval = 25, group = groupStructure)
externalPivotLen = input.int(10, "External Structure Pivot Length", minval = 4, maxval = 50, group = groupStructure)
rvolThreshold = input.float(1.25, "BOS RVOL Confirmation", minval = 0.5, maxval = 5.0, step = 0.05, group = groupStructure)
failedBosBars = input.int(3, "Failed BOS Lookback", minval = 1, maxval = 10, group = groupStructure)

regLen = input.int(80, "Log Regression Length", minval = 20, maxval = 250, group = groupRegime)
regBandMult = input.float(1.25, "Regression Band Multiplier", minval = 0.25, maxval = 3.0, step = 0.05, group = groupRegime)
slopeLookback = input.int(5, "Regression Slope Lookback", minval = 2, maxval = 20, group = groupRegime)
useWeeklyRegime = input.bool(true, "Use Weekly Regime Filter", group = groupRegime)
weeklyTf = input.timeframe("W", "Weekly Regime Timeframe", group = groupRegime)

zoneAtrMult = input.float(0.35, "Target Zone Width ATR Multiplier", minval = 0.05, maxval = 2.0, step = 0.05, group = groupTargets)
invalidationAtrBuffer = input.float(0.35, "Invalidation ATR Buffer", minval = 0.0, maxval = 2.0, step = 0.05, group = groupTargets)
distancePenalty = input.float(4.25, "Target Distance Penalty Per ATR", minval = 0.0, maxval = 12.0, step = 0.25, group = groupTargets)
targetDuplicateAtr = input.float(0.35, "Merge Similar Targets, ATR", minval = 0.05, maxval = 2.0, step = 0.05, group = groupTargets)
highProbabilityThreshold = input.float(72.0, "High Probability Threshold", minval = 50.0, maxval = 95.0, step = 1.0, group = groupAlerts)

selectedTablePos = input.enum(table_pos.top_right, "Table Position", group = groupTable)
compactTable = input.bool(false, "Compact Table", group = groupTable)
showAdvancedRows = input.bool(true, "Show Advanced Projection Rows", group = groupTable)

bullColor = input.color(color.rgb(80, 200, 120), "Bull Color", group = groupTable)
bearColor = input.color(color.rgb(240, 90, 90), "Bear Color", group = groupTable)
neutralColor = input.color(color.rgb(150, 150, 150), "Neutral Color", group = groupTable)

//====================================================
// Helpers
//====================================================

f_clamp(_x, _lo, _hi) =>
    math.min(math.max(_x, _lo), _hi)

f_pos(_p) =>
    switch _p
        table_pos.top_left => position.top_left
        table_pos.bottom_right => position.bottom_right
        table_pos.bottom_left => position.bottom_left
        => position.top_right

f_price(_x) =>
    na(_x) ? "n/a" : str.tostring(_x, format.mintick)

f_pct(_x) =>
    na(_x) ? "n/a" : str.tostring(_x, "#.0") + "%"

f_num(_x) =>
    na(_x) ? "n/a" : str.tostring(_x, "#.00")

f_zone(_target, _zone) =>
    na(_target) ? "n/a" : str.tostring(_target - _zone, format.mintick) + " to " + str.tostring(_target + _zone, format.mintick)

f_add_matrix_row(_m, _row, _maxRows) =>
    if _m.rows() >= _maxRows
        _m.remove_row(0)
    _m.add_row(_m.rows(), _row)

f_push_float(_a, _value, _maxRows) =>
    if array.size(_a) >= _maxRows
        array.shift(_a)
    array.push(_a, _value)

f_cell(_table, _col, _row, _text, _bg, _tc) =>
    table.cell(_table, _col, _row, _text, bgcolor = _bg, text_color = _tc, text_size = size.small)

f_score_target(_price, _sideScore, _knnConfidence, _volumeScore, _regScore, _structScore, _sourceBonus, _weeklyAligned, _atr, _close, _distancePenalty) =>
    if na(_price) or na(_atr) or _atr <= 0
        na
    else
        distAtr = math.abs(_price - _close) / _atr
        distScore = f_clamp(22.0 - distAtr * _distancePenalty, 0.0, 22.0)
        confScore = na(_knnConfidence) ? 50.0 : _knnConfidence
        weeklyAdj = _weeklyAligned ? 4.0 : -5.0
        raw = _sideScore * 0.34 + confScore * 0.18 + _volumeScore * 0.12 + _regScore * 0.12 + _structScore * 0.12 + distScore + _sourceBonus + weeklyAdj
        f_clamp(raw, 5.0, 95.0)

f_add_candidate(_prices, _scores, _names, _price, _name, _score, _isBull, _close, _mergeDistance) =>
    if not na(_price) and not na(_score) and (_isBull ? _price > _close : _price < _close)
        exists = false
        if array.size(_prices) > 0
            for i = 0 to array.size(_prices) - 1
                if math.abs(array.get(_prices, i) - _price) <= _mergeDistance
                    exists := true
                    if _score > array.get(_scores, i)
                        array.set(_prices, i, _price)
                        array.set(_scores, i, _score)
                        array.set(_names, i, _name)
        if not exists
            array.push(_prices, _price)
            array.push(_scores, _score)
            array.push(_names, _name)

f_best_index(array<float> _scores, int _used1, int _used2) =>
    int bestIdx = na
    float bestScore = na

    if array.size(_scores) > 0
        for i = 0 to array.size(_scores) - 1
            skip = i == _used1 or i == _used2
            if not skip
                s = array.get(_scores, i)
                if na(bestScore) or s > bestScore
                    bestScore := s
                    bestIdx := i
    bestIdx

//====================================================
// Core Series
//====================================================

atr = ta.atr(atrLen)
atrPct = atr / close
volAvg = ta.sma(volume, volLen)
rvol = volAvg > 0 ? volume / volAvg : 1.0
emaFeature = ta.ema(close, emaFeatureLen)

logClose = math.log(close)
regLog = ta.linreg(logClose, regLen, 0)
regResid = logClose - regLog
regStd = ta.stdev(regResid, regLen)
regUpper = math.exp(regLog + regStd * regBandMult)
regLower = math.exp(regLog - regStd * regBandMult)
regMid = math.exp(regLog)
regSlope = regLog - regLog[slopeLookback]

obv = ta.cum(close > close[1] ? volume : close < close[1] ? -volume : 0.0)
obvEma = ta.ema(obv, 21)
obvSlope = obvEma - obvEma[5]

//====================================================
// Weekly Regime
//====================================================

weeklyClose = request.security(syminfo.tickerid, weeklyTf, close, barmerge.gaps_off, barmerge.lookahead_off)
weeklyEma10 = request.security(syminfo.tickerid, weeklyTf, ta.ema(close, 10), barmerge.gaps_off, barmerge.lookahead_off)
weeklyEma30 = request.security(syminfo.tickerid, weeklyTf, ta.ema(close, 30), barmerge.gaps_off, barmerge.lookahead_off)

weeklyBull = weeklyClose > weeklyEma10 and weeklyEma10 > weeklyEma30
weeklyBear = weeklyClose < weeklyEma10 and weeklyEma10 < weeklyEma30
weeklyText = weeklyBull ? "Bullish" : weeklyBear ? "Bearish" : "Neutral"

//====================================================
// Feature Builder
//====================================================

f_build_features(_offset, _n) =>
    retArr = array.new<float>(_n, 0.0)
    rangeArr = array.new<float>(_n, 0.0)
    bodyArr = array.new<float>(_n, 0.0)
    wickArr = array.new<float>(_n, 0.0)
    volumeArr = array.new<float>(_n, 0.0)
    trendArr = array.new<float>(_n, 0.0)

    for j = 0 to _n - 1
        k = _offset + j

        atrK = math.max(atr[k], syminfo.mintick)
        closeK = math.max(close[k], syminfo.mintick)
        atrPctK = math.max(atrK / closeK, 0.000001)

        retVal = math.log(close[k] / close[k + 1]) / atrPctK
        rangeVal = (high[k] - low[k]) / atrK
        bodyVal = (close[k] - open[k]) / atrK

        upperWick = high[k] - math.max(open[k], close[k])
        lowerWick = math.min(open[k], close[k]) - low[k]
        wickVal = (upperWick - lowerWick) / atrK

        volBase = math.max(volAvg[k], 1.0)
        rawRvol = volume[k] / volBase
        volDirection = close[k] >= open[k] ? 1.0 : -1.0
        volumeVal = useVolumeFeature ? math.log(math.max(rawRvol, 0.01)) * volDirection : 0.0

        trendVal = useTrendFeature ? (close[k] - emaFeature[k]) / atrK : 0.0

        array.set(retArr, j, retVal)
        array.set(rangeArr, j, rangeVal)
        array.set(bodyArr, j, bodyVal)
        array.set(wickArr, j, wickVal)
        array.set(volumeArr, j, volumeVal)
        array.set(trendArr, j, trendVal)

    [retArr, rangeArr, bodyArr, wickArr, volumeArr, trendArr]

//====================================================
// kNN Storage
//====================================================

var matrix<float> DRet = matrix.new<float>()
var matrix<float> DRange = matrix.new<float>()
var matrix<float> DBody = matrix.new<float>()
var matrix<float> DWick = matrix.new<float>()
var matrix<float> DVolume = matrix.new<float>()
var matrix<float> DTrend = matrix.new<float>()

var array<float> YReturn = array.new<float>()
var array<float> YHigh = array.new<float>()
var array<float> YLow = array.new<float>()

//====================================================
// Distance and kNN
//====================================================

f_run_distance(_qRet, _qRange, _qBody, _qWick, _qVolume, _qTrend) =>
    rows = DRet.rows()
    dist = array.new<float>(rows, 0.0)

    weightSum = math.max(retWeight + rangeWeight + bodyWeight + wickWeight + volumeWeight + trendWeight, 0.000001)

    for i = 0 to rows - 1
        rRet = DRet.row(i)
        rRange = DRange.row(i)
        rBody = DBody.row(i)
        rWick = DWick.row(i)
        rVolume = DVolume.row(i)
        rTrend = DTrend.row(i)

        sumSq = 0.0

        for j = 0 to patternLength - 1
            dRet = array.get(_qRet, j) - array.get(rRet, j)
            dRange = array.get(_qRange, j) - array.get(rRange, j)
            dBody = array.get(_qBody, j) - array.get(rBody, j)
            dWick = array.get(_qWick, j) - array.get(rWick, j)
            dVolume = array.get(_qVolume, j) - array.get(rVolume, j)
            dTrend = array.get(_qTrend, j) - array.get(rTrend, j)

            sumSq += math.pow(dRet, 2.0) * retWeight / weightSum
            sumSq += math.pow(dRange, 2.0) * rangeWeight / weightSum
            sumSq += math.pow(dBody, 2.0) * bodyWeight / weightSum
            sumSq += math.pow(dWick, 2.0) * wickWeight / weightSum
            sumSq += math.pow(dVolume, 2.0) * volumeWeight / weightSum
            sumSq += math.pow(dTrend, 2.0) * trendWeight / weightSum

        array.set(dist, i, math.sqrt(sumSq / patternLength))

    dist

f_knn(_dist, _neighbors, _weighting) =>
    idx = array.sort_indices(_dist)
    nEff = math.min(_neighbors, array.size(idx))

    float sumW = 0.0
    float sumY = 0.0
    float sumH = 0.0
    float sumL = 0.0
    int upCount = 0
    int downCount = 0
    float nearestDist = na

    if nEff > 0
        nearestDist := array.get(_dist, array.get(idx, 0))

        for k = 0 to nEff - 1
            row = array.get(idx, k)
            d = math.max(array.get(_dist, row), 0.000001)
            w = _weighting == knn_weighting.inverse_distance ? 1.0 / d : 1.0

            y = array.get(YReturn, row)
            yh = array.get(YHigh, row)
            yl = array.get(YLow, row)

            sumW += w
            sumY += y * w
            sumH += yh * w
            sumL += yl * w

            if y > 0
                upCount += 1
            else
                downCount += 1

    avgY = nEff > 0 and sumW > 0 ? sumY / sumW : na
    avgH = nEff > 0 and sumW > 0 ? sumH / sumW : na
    avgL = nEff > 0 and sumW > 0 ? sumL / sumW : na
    conf = nEff > 0 ? math.max(upCount, downCount) / nEff * 100.0 : na

    [avgY, avgH, avgL, conf, nearestDist, nEff]

//====================================================
// Update Dictionary and Query
//====================================================

sampleEndOffset = forecastHorizon + trainingPurgeBars
enoughBars = bar_index > patternLength + sampleEndOffset + 200

var float predReturnRaw = na
var float predHighRaw = na
var float predLowRaw = na
var float knnConfidence = na
var float nearestDistance = na
var int effectiveNeighbors = na

if barstate.isconfirmed and enoughBars
    [trainRet, trainRange, trainBody, trainWick, trainVolume, trainTrend] = f_build_features(sampleEndOffset, patternLength)

    futureClose = close[trainingPurgeBars]
    sampleEndClose = close[sampleEndOffset]

    futureHigh = ta.highest(high, forecastHorizon)[trainingPurgeBars]
    futureLow = ta.lowest(low, forecastHorizon)[trainingPurgeBars]

    yRet = math.log(futureClose / sampleEndClose)
    yHigh = math.log(futureHigh / sampleEndClose)
    yLow = math.log(futureLow / sampleEndClose)

    f_add_matrix_row(DRet, trainRet, dictionarySize)
    f_add_matrix_row(DRange, trainRange, dictionarySize)
    f_add_matrix_row(DBody, trainBody, dictionarySize)
    f_add_matrix_row(DWick, trainWick, dictionarySize)
    f_add_matrix_row(DVolume, trainVolume, dictionarySize)
    f_add_matrix_row(DTrend, trainTrend, dictionarySize)

    f_push_float(YReturn, yRet, dictionarySize)
    f_push_float(YHigh, yHigh, dictionarySize)
    f_push_float(YLow, yLow, dictionarySize)

    if DRet.rows() >= math.max(neighbors, 20)
        [qRet, qRange, qBody, qWick, qVolume, qTrend] = f_build_features(0, patternLength)
        dist = f_run_distance(qRet, qRange, qBody, qWick, qVolume, qTrend)
        [avgY, avgH, avgL, conf, nearD, nEff] = f_knn(dist, neighbors, weightingMode)

        predReturnRaw := avgY
        predHighRaw := avgH
        predLowRaw := avgL
        knnConfidence := conf
        nearestDistance := nearD
        effectiveNeighbors := nEff

predReturn = smoothPrediction > 1 ? ta.ema(predReturnRaw, smoothPrediction) : predReturnRaw
predHigh = smoothPrediction > 1 ? ta.ema(predHighRaw, smoothPrediction) : predHighRaw
predLow = smoothPrediction > 1 ? ta.ema(predLowRaw, smoothPrediction) : predLowRaw

projMid = not na(predReturn) ? close * math.exp(predReturn) : na
projHigh = not na(predHigh) ? close * math.exp(predHigh) : na
projLow = not na(predLow) ? close * math.exp(predLow) : na

//====================================================
// Structure Engine
//====================================================

pivHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivLow = ta.pivotlow(low, pivotLen, pivotLen)
extHigh = ta.pivothigh(high, externalPivotLen, externalPivotLen)
extLow = ta.pivotlow(low, externalPivotLen, externalPivotLen)

var float prevSwingHigh = na
var float lastSwingHigh = na
var int lastSwingHighBar = na

var float prevSwingLow = na
var float lastSwingLow = na
var int lastSwingLowBar = na

var float prevExternalHigh = na
var float lastExternalHigh = na
var int lastExternalHighBar = na

var float prevExternalLow = na
var float lastExternalLow = na
var int lastExternalLowBar = na

if not na(pivHigh)
    prevSwingHigh := lastSwingHigh
    lastSwingHigh := pivHigh
    lastSwingHighBar := bar_index - pivotLen

if not na(pivLow)
    prevSwingLow := lastSwingLow
    lastSwingLow := pivLow
    lastSwingLowBar := bar_index - pivotLen

if not na(extHigh)
    prevExternalHigh := lastExternalHigh
    lastExternalHigh := extHigh
    lastExternalHighBar := bar_index - externalPivotLen

if not na(extLow)
    prevExternalLow := lastExternalLow
    lastExternalLow := extLow
    lastExternalLowBar := bar_index - externalPivotLen

internalBullStructure = not na(prevSwingHigh) and not na(prevSwingLow) and not na(lastSwingHigh) and not na(lastSwingLow) and lastSwingHigh > prevSwingHigh and lastSwingLow > prevSwingLow
internalBearStructure = not na(prevSwingHigh) and not na(prevSwingLow) and not na(lastSwingHigh) and not na(lastSwingLow) and lastSwingHigh < prevSwingHigh and lastSwingLow < prevSwingLow

externalBullStructure = not na(prevExternalHigh) and not na(prevExternalLow) and not na(lastExternalHigh) and not na(lastExternalLow) and lastExternalHigh > prevExternalHigh and lastExternalLow > prevExternalLow
externalBearStructure = not na(prevExternalHigh) and not na(prevExternalLow) and not na(lastExternalHigh) and not na(lastExternalLow) and lastExternalHigh < prevExternalHigh and lastExternalLow < prevExternalLow

bullBos = barstate.isconfirmed and not na(lastSwingHigh) and close > lastSwingHigh and close[1] <= lastSwingHigh and rvol >= rvolThreshold
bearBos = barstate.isconfirmed and not na(lastSwingLow) and close < lastSwingLow and close[1] >= lastSwingLow and rvol >= rvolThreshold

bullExternalBos = barstate.isconfirmed and not na(lastExternalHigh) and close > lastExternalHigh and close[1] <= lastExternalHigh and rvol >= rvolThreshold
bearExternalBos = barstate.isconfirmed and not na(lastExternalLow) and close < lastExternalLow and close[1] >= lastExternalLow and rvol >= rvolThreshold

var int structureTrend = 0
priorStructureTrend = nz(structureTrend[1], 0)

bullChoch = (bullBos or bullExternalBos) and (priorStructureTrend == -1 or internalBearStructure or externalBearStructure) and regSlope > 0
bearChoch = (bearBos or bearExternalBos) and (priorStructureTrend == 1 or internalBullStructure or externalBullStructure) and regSlope < 0

if bullBos or bullExternalBos or bullChoch
    structureTrend := 1
else if bearBos or bearExternalBos or bearChoch
    structureTrend := -1
else
    structureTrend := priorStructureTrend

var float activeBullBosLevel = na
var int activeBullBosBar = na
var float activeBearBosLevel = na
var int activeBearBosBar = na

if bullBos or bullExternalBos
    activeBullBosLevel := bullExternalBos ? lastExternalHigh : lastSwingHigh
    activeBullBosBar := bar_index

if bearBos or bearExternalBos
    activeBearBosLevel := bearExternalBos ? lastExternalLow : lastSwingLow
    activeBearBosBar := bar_index

failedBullBos = not na(activeBullBosLevel) and bar_index > activeBullBosBar and bar_index - activeBullBosBar <= failedBosBars and close < activeBullBosLevel
failedBearBos = not na(activeBearBosLevel) and bar_index > activeBearBosBar and bar_index - activeBearBosBar <= failedBosBars and close > activeBearBosLevel

if failedBullBos or (not na(activeBullBosBar) and bar_index - activeBullBosBar > failedBosBars)
    activeBullBosLevel := na
    activeBullBosBar := na

if failedBearBos or (not na(activeBearBosBar) and bar_index - activeBearBosBar > failedBosBars)
    activeBearBosLevel := na
    activeBearBosBar := na

structureText =
     bullChoch ? "Bullish CHoCH" :
     bearChoch ? "Bearish CHoCH" :
     bullExternalBos ? "Bullish External BOS" :
     bearExternalBos ? "Bearish External BOS" :
     bullBos ? "Bullish BOS" :
     bearBos ? "Bearish BOS" :
     failedBearBos ? "Failed Bear BOS" :
     failedBullBos ? "Failed Bull BOS" :
     externalBullStructure ? "External Bull Structure" :
     externalBearStructure ? "External Bear Structure" :
     internalBullStructure ? "Internal Bull Structure" :
     internalBearStructure ? "Internal Bear Structure" :
     structureTrend == 1 ? "Bullish Structure" :
     structureTrend == -1 ? "Bearish Structure" :
     "Neutral"

//====================================================
// Directional Scoring Model
//====================================================

predAtrMultiple = not na(predReturn) and atrPct > 0 ? predReturn / math.max(atrPct * math.sqrt(forecastHorizon), 0.000001) : 0.0
magScore = f_clamp(math.abs(predAtrMultiple) * 22.0, 0.0, 30.0)
confAdj = not na(knnConfidence) ? (knnConfidence - 50.0) * 0.60 : 0.0

bullKnnScore = not na(predReturn) ? (predReturn >= 0 ? 50.0 + magScore + confAdj : 50.0 - magScore - confAdj) : 50.0
bearKnnScore = not na(predReturn) ? (predReturn < 0 ? 50.0 + magScore + confAdj : 50.0 - magScore - confAdj) : 50.0

bullKnnScore := f_clamp(bullKnnScore, 0.0, 100.0)
bearKnnScore := f_clamp(bearKnnScore, 0.0, 100.0)

regPosition = regStd > 0 ? (logClose - regLog) / regStd : 0.0
bullRegScore = f_clamp(50.0 + regSlope / math.max(regStd, 0.000001) * 20.0 - math.max(regPosition, 0.0) * 8.0, 0.0, 100.0)
bearRegScore = f_clamp(50.0 - regSlope / math.max(regStd, 0.000001) * 20.0 + math.min(regPosition, 0.0) * 8.0, 0.0, 100.0)

bullStructScore = f_clamp(
     (structureTrend == 1 ? 45.0 : 30.0) +
     (internalBullStructure ? 8.0 : 0.0) +
     (externalBullStructure ? 12.0 : 0.0) +
     (bullBos ? 10.0 : 0.0) +
     (bullExternalBos ? 16.0 : 0.0) +
     (bullChoch ? 22.0 : 0.0) +
     (failedBearBos ? 18.0 : 0.0),
     0.0, 100.0)

bearStructScore = f_clamp(
     (structureTrend == -1 ? 45.0 : 30.0) +
     (internalBearStructure ? 8.0 : 0.0) +
     (externalBearStructure ? 12.0 : 0.0) +
     (bearBos ? 10.0 : 0.0) +
     (bearExternalBos ? 16.0 : 0.0) +
     (bearChoch ? 22.0 : 0.0) +
     (failedBullBos ? 18.0 : 0.0),
     0.0, 100.0)

bullVolumeScore = f_clamp(
     (rvol >= rvolThreshold ? 25.0 : rvol >= 1.0 ? 15.0 : 5.0) +
     (close > open ? 20.0 : 0.0) +
     (close > close[1] and volume > volume[1] ? 20.0 : 0.0) +
     (obvSlope > 0 ? 25.0 : 0.0) +
     (volume > volAvg ? 10.0 : 0.0),
     0.0, 100.0)

bearVolumeScore = f_clamp(
     (rvol >= rvolThreshold ? 25.0 : rvol >= 1.0 ? 15.0 : 5.0) +
     (close < open ? 20.0 : 0.0) +
     (close < close[1] and volume > volume[1] ? 20.0 : 0.0) +
     (obvSlope < 0 ? 25.0 : 0.0) +
     (volume > volAvg ? 10.0 : 0.0),
     0.0, 100.0)

weeklyBullAdj = useWeeklyRegime ? (weeklyBull ? 5.0 : weeklyBear ? -8.0 : 0.0) : 0.0
weeklyBearAdj = useWeeklyRegime ? (weeklyBear ? 5.0 : weeklyBull ? -8.0 : 0.0) : 0.0

bullScore = f_clamp(bullKnnScore * 0.40 + bullRegScore * 0.20 + bullStructScore * 0.25 + bullVolumeScore * 0.15 + weeklyBullAdj, 0.0, 100.0)
bearScore = f_clamp(bearKnnScore * 0.40 + bearRegScore * 0.20 + bearStructScore * 0.25 + bearVolumeScore * 0.15 + weeklyBearAdj, 0.0, 100.0)

isBullForecast = bullScore >= bearScore
forecastScore = math.max(bullScore, bearScore)

biasText =
     bullScore - bearScore >= minDirectionalEdge ? "Bullish" :
     bearScore - bullScore >= minDirectionalEdge ? "Bearish" :
     isBullForecast ? "Neutral Bullish Lean" : "Neutral Bearish Lean"

//====================================================
// Independent Target Ranking
//====================================================

zoneWidth = atr * zoneAtrMult
mergeDistance = atr * targetDuplicateAtr

swingRange =
     not na(lastExternalHigh) and not na(lastExternalLow) ? math.abs(lastExternalHigh - lastExternalLow) :
     not na(lastSwingHigh) and not na(lastSwingLow) ? math.abs(lastSwingHigh - lastSwingLow) :
     atr * 3.0

atrUpside = close + atr * math.max(1.0, math.sqrt(forecastHorizon) * 0.45)
atrDownside = close - atr * math.max(1.0, math.sqrt(forecastHorizon) * 0.45)

swingUpside =
     not na(lastExternalHigh) and lastExternalHigh > close ? lastExternalHigh :
     not na(lastSwingHigh) and lastSwingHigh > close ? lastSwingHigh :
     na

swingDownside =
     not na(lastExternalLow) and lastExternalLow < close ? lastExternalLow :
     not na(lastSwingLow) and lastSwingLow < close ? lastSwingLow :
     na

measuredUp = close + swingRange * 0.618
measuredDown = close - swingRange * 0.618

fibOne = isBullForecast ? close + swingRange * 1.000 : close - swingRange * 1.000
fib127 = isBullForecast ? close + swingRange * 1.272 : close - swingRange * 1.272
fib618 = isBullForecast ? close + swingRange * 1.618 : close - swingRange * 1.618

fibUp = not na(lastExternalLow) ? lastExternalLow + swingRange * 1.272 : close + atr * 2.0
fibDown = not na(lastExternalHigh) ? lastExternalHigh - swingRange * 1.272 : close - atr * 2.0

weeklyAlignedBull = not useWeeklyRegime or weeklyBull or not weeklyBear
weeklyAlignedBear = not useWeeklyRegime or weeklyBear or not weeklyBull

candidatePrices = array.new_float()
candidateScores = array.new_float()
candidateNames = array.new_string()

sideScore = isBullForecast ? bullScore : bearScore
sideVolumeScore = isBullForecast ? bullVolumeScore : bearVolumeScore
sideRegScore = isBullForecast ? bullRegScore : bearRegScore
sideStructScore = isBullForecast ? bullStructScore : bearStructScore
sideWeeklyAligned = isBullForecast ? weeklyAlignedBull : weeklyAlignedBear

if isBullForecast
    s1 = f_score_target(projMid, sideScore, knnConfidence, sideVolumeScore, sideRegScore, sideStructScore, 11.0, sideWeeklyAligned, atr, close, distancePenalty)
    f_add_candidate(candidatePrices, candidateScores, candidateNames, projMid, "kNN Mid Path", s1, true, close, mergeDistance)

    s2 = f_score_target(projHigh, sideScore, knnConfidence, sideVolumeScore, sideRegScore, sideStructScore, 15.0, sideWeeklyAligned, atr, close, distancePenalty)
    f_add_candidate(candidatePrices, candidateScores, candidateNames, projHigh, "kNN High Path", s2, true, close, mergeDistance)

    s3 = f_score_target(regUpper, sideScore, knnConfidence, sideVolumeScore, sideRegScore, sideStructScore, 9.0, sideWeeklyAligned, atr, close, distancePenalty)
    f_add_candidate(candidatePrices, candidateScores, candidateNames, regUpper, "Regression Upper Band", s3, true, close, mergeDistance)

    s4 = f_score_target(swingUpside, sideScore, knnConfidence, sideVolumeScore, sideRegScore, sideStructScore, 13.0, sideWeeklyAligned, atr, close, distancePenalty)
    f_add_candidate(candidatePrices, candidateScores, candidateNames, swingUpside, "Structure Swing Resistance", s4, true, close, mergeDistance)

    s5 = f_score_target(atrUpside, sideScore, knnConfidence, sideVolumeScore, sideRegScore, sideStructScore, 8.0, sideWeeklyAligned, atr, close, distancePenalty)
    f_add_candidate(candidatePrices, candidateScores, candidateNames, atrUpside, "ATR Expansion", s5, true, close, mergeDistance)

    s6 = f_score_target(measuredUp, sideScore, knnConfidence, sideVolumeScore, sideRegScore, sideStructScore, 12.0, sideWeeklyAligned, atr, close, distancePenalty)
    f_add_candidate(candidatePrices, candidateScores, candidateNames, measuredUp, "Measured Move", s6, true, close, mergeDistance)

    s7 = f_score_target(fibUp, sideScore, knnConfidence, sideVolumeScore, sideRegScore, sideStructScore, 9.0, sideWeeklyAligned, atr, close, distancePenalty)
    f_add_candidate(candidatePrices, candidateScores, candidateNames, fibUp, "Fibonacci Extension", s7, true, close, mergeDistance)
else
    s1 = f_score_target(projMid, sideScore, knnConfidence, sideVolumeScore, sideRegScore, sideStructScore, 11.0, sideWeeklyAligned, atr, close, distancePenalty)
    f_add_candidate(candidatePrices, candidateScores, candidateNames, projMid, "kNN Mid Path", s1, false, close, mergeDistance)

    s2 = f_score_target(projLow, sideScore, knnConfidence, sideVolumeScore, sideRegScore, sideStructScore, 15.0, sideWeeklyAligned, atr, close, distancePenalty)
    f_add_candidate(candidatePrices, candidateScores, candidateNames, projLow, "kNN Low Path", s2, false, close, mergeDistance)

    s3 = f_score_target(regLower, sideScore, knnConfidence, sideVolumeScore, sideRegScore, sideStructScore, 9.0, sideWeeklyAligned, atr, close, distancePenalty)
    f_add_candidate(candidatePrices, candidateScores, candidateNames, regLower, "Regression Lower Band", s3, false, close, mergeDistance)

    s4 = f_score_target(swingDownside, sideScore, knnConfidence, sideVolumeScore, sideRegScore, sideStructScore, 13.0, sideWeeklyAligned, atr, close, distancePenalty)
    f_add_candidate(candidatePrices, candidateScores, candidateNames, swingDownside, "Structure Swing Support", s4, false, close, mergeDistance)

    s5 = f_score_target(atrDownside, sideScore, knnConfidence, sideVolumeScore, sideRegScore, sideStructScore, 8.0, sideWeeklyAligned, atr, close, distancePenalty)
    f_add_candidate(candidatePrices, candidateScores, candidateNames, atrDownside, "ATR Expansion", s5, false, close, mergeDistance)

    s6 = f_score_target(measuredDown, sideScore, knnConfidence, sideVolumeScore, sideRegScore, sideStructScore, 12.0, sideWeeklyAligned, atr, close, distancePenalty)
    f_add_candidate(candidatePrices, candidateScores, candidateNames, measuredDown, "Measured Move", s6, false, close, mergeDistance)

    s7 = f_score_target(fibDown, sideScore, knnConfidence, sideVolumeScore, sideRegScore, sideStructScore, 9.0, sideWeeklyAligned, atr, close, distancePenalty)
    f_add_candidate(candidatePrices, candidateScores, candidateNames, fibDown, "Fibonacci Extension", s7, false, close, mergeDistance)

int idx1 = f_best_index(candidateScores, -1, -1)
int idx1Safe = na(idx1) ? -1 : idx1

int idx2 = f_best_index(candidateScores, idx1Safe, -1)
int idx2Safe = na(idx2) ? -1 : idx2

int idx3 = f_best_index(candidateScores, idx1Safe, idx2Safe)

float target1 = na(idx1) ? na : array.get(candidatePrices, idx1)
float target2 = na(idx2) ? na : array.get(candidatePrices, idx2)
float target3 = na(idx3) ? na : array.get(candidatePrices, idx3)

float targetScore1 = na(idx1) ? na : array.get(candidateScores, idx1)
float targetScore2 = na(idx2) ? na : array.get(candidateScores, idx2)
float targetScore3 = na(idx3) ? na : array.get(candidateScores, idx3)

string targetName1 = na(idx1) ? "n/a" : array.get(candidateNames, idx1)
string targetName2 = na(idx2) ? "n/a" : array.get(candidateNames, idx2)
string targetName3 = na(idx3) ? "n/a" : array.get(candidateNames, idx3)

bullInvalidation =
     not na(lastSwingLow) ? lastSwingLow - atr * invalidationAtrBuffer :
     not na(lastExternalLow) ? lastExternalLow - atr * invalidationAtrBuffer :
     regLower

bearInvalidation =
     not na(lastSwingHigh) ? lastSwingHigh + atr * invalidationAtrBuffer :
     not na(lastExternalHigh) ? lastExternalHigh + atr * invalidationAtrBuffer :
     regUpper

invalidation = isBullForecast ? bullInvalidation : bearInvalidation

targetHit = barstate.isconfirmed and not na(target1) and (isBullForecast ? high >= target1 : low <= target1)
invalidationHit = barstate.isconfirmed and not na(invalidation) and (isBullForecast ? close < invalidation : close > invalidation)

//====================================================
// Table
//====================================================

var table dash = table.new(f_pos(selectedTablePos), 4, 24, border_width = 1)

bgHeader = color.rgb(15, 15, 15)
bgLabel = color.rgb(35, 35, 35)
bgValue = color.rgb(25, 25, 25)
bgBull = color.new(bullColor, 72)
bgBear = color.new(bearColor, 72)
bgNeutral = color.new(neutralColor, 78)
bgWarn = color.rgb(90, 65, 20)
textColor = color.white

biasBg = bullScore - bearScore >= minDirectionalEdge ? bgBull : bearScore - bullScore >= minDirectionalEdge ? bgBear : bgNeutral

if barstate.islast
    f_cell(dash, 0, 0, "Metric", bgHeader, textColor)
    f_cell(dash, 1, 0, "Value", bgHeader, textColor)
    f_cell(dash, 2, 0, "Context", bgHeader, textColor)
    f_cell(dash, 3, 0, "Score", bgHeader, textColor)

    f_cell(dash, 0, 1, "Forecast Bias", bgLabel, textColor)
    f_cell(dash, 1, 1, biasText, biasBg, textColor)
    f_cell(dash, 2, 1, "Highest probability side", biasBg, textColor)
    f_cell(dash, 3, 1, f_pct(forecastScore), biasBg, textColor)

    f_cell(dash, 0, 2, "kNN Forecast", bgLabel, textColor)
    f_cell(dash, 1, 2, not na(predReturn) ? str.tostring(predReturn * 100.0, "#.00") + "%" : "Building", bgValue, textColor)
    f_cell(dash, 2, 2, "Confidence " + f_pct(knnConfidence), bgValue, textColor)
    f_cell(dash, 3, 2, f_pct(isBullForecast ? bullKnnScore : bearKnnScore), bgValue, textColor)

    f_cell(dash, 0, 3, "Samples", bgLabel, textColor)
    f_cell(dash, 1, 3, str.tostring(DRet.rows()) + " / " + str.tostring(dictionarySize), bgValue, textColor)
    f_cell(dash, 2, 3, "Neighbors " + str.tostring(effectiveNeighbors), bgValue, textColor)
    f_cell(dash, 3, 3, "D " + f_num(nearestDistance), bgValue, textColor)

    f_cell(dash, 0, 4, "Structure", bgLabel, textColor)
    f_cell(dash, 1, 4, structureText, structureTrend == 1 ? bgBull : structureTrend == -1 ? bgBear : bgNeutral, textColor)
    f_cell(dash, 2, 4, "BOS CHoCH failed BOS", bgValue, textColor)
    f_cell(dash, 3, 4, f_pct(isBullForecast ? bullStructScore : bearStructScore), bgValue, textColor)

    f_cell(dash, 0, 5, "Volume", bgLabel, textColor)
    f_cell(dash, 1, 5, "RVOL " + f_num(rvol), bgValue, textColor)
    f_cell(dash, 2, 5, obvSlope > 0 ? "OBV rising" : obvSlope < 0 ? "OBV falling" : "OBV flat", bgValue, textColor)
    f_cell(dash, 3, 5, f_pct(isBullForecast ? bullVolumeScore : bearVolumeScore), bgValue, textColor)

    f_cell(dash, 0, 6, "Regression", bgLabel, textColor)
    f_cell(dash, 1, 6, regSlope > 0 ? "Rising" : regSlope < 0 ? "Falling" : "Flat", regSlope > 0 ? bgBull : regSlope < 0 ? bgBear : bgNeutral, textColor)
    f_cell(dash, 2, 6, "Position " + f_num(regPosition), bgValue, textColor)
    f_cell(dash, 3, 6, f_pct(isBullForecast ? bullRegScore : bearRegScore), bgValue, textColor)

    f_cell(dash, 0, 7, "Weekly Regime", bgLabel, textColor)
    f_cell(dash, 1, 7, useWeeklyRegime ? weeklyText : "Disabled", weeklyBull ? bgBull : weeklyBear ? bgBear : bgNeutral, textColor)
    f_cell(dash, 2, 7, weeklyTf, bgValue, textColor)
    f_cell(dash, 3, 7, useWeeklyRegime ? "Active" : "Off", bgValue, textColor)

    f_cell(dash, 0, 8, "Invalidation", bgLabel, textColor)
    f_cell(dash, 1, 8, f_price(invalidation), bgWarn, textColor)
    f_cell(dash, 2, 8, "Structure plus ATR", bgValue, textColor)
    f_cell(dash, 3, 8, isBullForecast ? "Below" : "Above", bgValue, textColor)

    f_cell(dash, 0, 9, "Ranked Target 1", bgLabel, textColor)
    f_cell(dash, 1, 9, f_zone(target1, zoneWidth), isBullForecast ? bgBull : bgBear, textColor)
    f_cell(dash, 2, 9, targetName1, bgValue, textColor)
    f_cell(dash, 3, 9, f_pct(targetScore1), isBullForecast ? bgBull : bgBear, textColor)

    f_cell(dash, 0, 10, "Ranked Target 2", bgLabel, textColor)
    f_cell(dash, 1, 10, f_zone(target2, zoneWidth), isBullForecast ? bgBull : bgBear, textColor)
    f_cell(dash, 2, 10, targetName2, bgValue, textColor)
    f_cell(dash, 3, 10, f_pct(targetScore2), isBullForecast ? bgBull : bgBear, textColor)

    f_cell(dash, 0, 11, "Ranked Target 3", bgLabel, textColor)
    f_cell(dash, 1, 11, f_zone(target3, zoneWidth), isBullForecast ? bgBull : bgBear, textColor)
    f_cell(dash, 2, 11, targetName3, bgValue, textColor)
    f_cell(dash, 3, 11, f_pct(targetScore3), isBullForecast ? bgBull : bgBear, textColor)

    if not compactTable
        f_cell(dash, 0, 12, "Projected High", bgLabel, textColor)
        f_cell(dash, 1, 12, f_price(projHigh), bgBull, textColor)
        f_cell(dash, 2, 12, "kNN high path", bgValue, textColor)
        f_cell(dash, 3, 12, "Range", bgValue, textColor)

        f_cell(dash, 0, 13, "Projected Mid", bgLabel, textColor)
        f_cell(dash, 1, 13, f_price(projMid), bgValue, textColor)
        f_cell(dash, 2, 13, str.tostring(forecastHorizon) + " bars", bgValue, textColor)
        f_cell(dash, 3, 13, "kNN", bgValue, textColor)

        f_cell(dash, 0, 14, "Projected Low", bgLabel, textColor)
        f_cell(dash, 1, 14, f_price(projLow), bgBear, textColor)
        f_cell(dash, 2, 14, "kNN low path", bgValue, textColor)
        f_cell(dash, 3, 14, "Range", bgValue, textColor)

        f_cell(dash, 0, 15, "ATR Expansion", bgLabel, textColor)
        f_cell(dash, 1, 15, isBullForecast ? f_price(atrUpside) : f_price(atrDownside), bgValue, textColor)
        f_cell(dash, 2, 15, "ATR based objective", bgValue, textColor)
        f_cell(dash, 3, 15, f_num(math.abs((isBullForecast ? atrUpside : atrDownside) - close) / atr) + " ATR", bgValue, textColor)

        f_cell(dash, 0, 16, "Measured Move", bgLabel, textColor)
        f_cell(dash, 1, 16, isBullForecast ? f_price(measuredUp) : f_price(measuredDown), bgValue, textColor)
        f_cell(dash, 2, 16, "0.618 structure range", bgValue, textColor)
        f_cell(dash, 3, 16, f_num(swingRange / atr) + " ATR range", bgValue, textColor)

        f_cell(dash, 0, 17, "Fib 1.000", bgLabel, textColor)
        f_cell(dash, 1, 17, f_price(fibOne), bgValue, textColor)
        f_cell(dash, 2, 17, "Structure range", bgValue, textColor)
        f_cell(dash, 3, 17, isBullForecast ? "Upside" : "Downside", bgValue, textColor)

        f_cell(dash, 0, 18, "Fib 1.272", bgLabel, textColor)
        f_cell(dash, 1, 18, f_price(fib127), bgValue, textColor)
        f_cell(dash, 2, 18, "Extension", bgValue, textColor)
        f_cell(dash, 3, 18, isBullForecast ? "Upside" : "Downside", bgValue, textColor)

        f_cell(dash, 0, 19, "Fib 1.618", bgLabel, textColor)
        f_cell(dash, 1, 19, f_price(fib618), bgValue, textColor)
        f_cell(dash, 2, 19, "Extension", bgValue, textColor)
        f_cell(dash, 3, 19, isBullForecast ? "Upside" : "Downside", bgValue, textColor)

        f_cell(dash, 0, 20, "Bull Score", bgLabel, textColor)
        f_cell(dash, 1, 20, f_pct(bullScore), bgBull, textColor)
        f_cell(dash, 2, 20, "kNN Reg Struct Vol", bgValue, textColor)
        f_cell(dash, 3, 20, "40/20/25/15", bgValue, textColor)

        f_cell(dash, 0, 21, "Bear Score", bgLabel, textColor)
        f_cell(dash, 1, 21, f_pct(bearScore), bgBear, textColor)
        f_cell(dash, 2, 21, "kNN Reg Struct Vol", bgValue, textColor)
        f_cell(dash, 3, 21, "40/20/25/15", bgValue, textColor)

        f_cell(dash, 0, 22, "Target Logic", bgLabel, textColor)
        f_cell(dash, 1, 22, "Independent Ranking", bgValue, textColor)
        f_cell(dash, 2, 22, "kNN Reg Struct Vol ATR", bgValue, textColor)
        f_cell(dash, 3, 22, "Table Only", bgValue, textColor)

        f_cell(dash, 0, 23, "Chart Objects", bgLabel, textColor)
        f_cell(dash, 1, 23, "Disabled", bgNeutral, textColor)
        f_cell(dash, 2, 23, "No projected lines", bgValue, textColor)
        f_cell(dash, 3, 23, "Clean chart", bgValue, textColor)

//====================================================
// Alerts
//====================================================

highProbBull = barstate.isconfirmed and isBullForecast and bullScore >= highProbabilityThreshold and bullScore[1] < highProbabilityThreshold
highProbBear = barstate.isconfirmed and not isBullForecast and bearScore >= highProbabilityThreshold and bearScore[1] < highProbabilityThreshold

alertcondition(bullBos, "Bullish BOS", "Bullish Break of Structure confirmed with RVOL.")
alertcondition(bearBos, "Bearish BOS", "Bearish Break of Structure confirmed with RVOL.")
alertcondition(bullChoch, "Bullish CHoCH", "Bullish Change of Character confirmed.")
alertcondition(bearChoch, "Bearish CHoCH", "Bearish Change of Character confirmed.")
alertcondition(failedBullBos, "Failed Bullish BOS", "Failed bullish Break of Structure. Reversal risk increased.")
alertcondition(failedBearBos, "Failed Bearish BOS", "Failed bearish Break of Structure. Reversal risk increased.")
alertcondition(highProbBull, "High Probability Bullish Forecast", "Bullish forecast crossed the high probability threshold.")
alertcondition(highProbBear, "High Probability Bearish Forecast", "Bearish forecast crossed the high probability threshold.")
alertcondition(targetHit, "Ranked Target 1 Hit", "Ranked Target 1 reached.")
alertcondition(invalidationHit, "Forecast Invalidation Hit", "Forecast invalidation level hit.")
````
