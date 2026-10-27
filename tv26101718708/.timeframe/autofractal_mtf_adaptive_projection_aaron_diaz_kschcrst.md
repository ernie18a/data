# AutoFractal MTF Adaptive Projection [Aaron Diaz]

- url: https://www.tradingview.com/script/KsCHcrSt/
- type: indicator
- pine_id: PUB;4c4194014e13456280711a0d02e8508e
- version: 1.0

## Description

TITLE

AutoFractal MTF Adaptive Projection [Aaron Diaz]


ENGLISH DESCRIPTION

OVERVIEW

AutoFractal MTF Adaptive Projection searches for historical price structures that resemble a user-defined current structure. The historical search timeframe is independent from the chart timeframe, so a trader can view a daily chart while searching for analogs on 4-hour, 2-hour, daily, or other supported timeframes.

The script is designed as a market-structure comparison and scenario-projection tool. It does not generate buy or sell signals, and its projected path must not be interpreted as a guaranteed forecast.

HOW IT WORKS

1. Historical search range
The user selects a start date, an end date, and a historical source timeframe. The script evaluates candidate structures only inside that selected period.

2. Current target structure
The structure to be matched can be defined using the latest N chart bars or a manual date range on the current chart.

3. Normalized comparison
Historical and current structures are compared using normalized log returns rather than absolute prices. This allows patterns from different price levels and different market regimes to be compared on a proportional basis.

4. Composite similarity score
Each historical candidate receives a score based on:
- Shape and correlation.
- Retracement and Fibonacci behavior.
- Relative amplitude.
- Directional agreement.

Inverse fractals can be enabled when the user wants to compare a bullish structure with an inverted bearish analog, or vice versa.

5. Adaptive projection
After a match is selected, the script uses the historical continuation as an analog scenario. Three adaptation methods are available:
- Percentage: adapts the historical continuation using proportional price movement.
- Fibonacci: adapts the continuation using the relationship between historical and current structural ranges.
- Smart hybrid: combines percentage and Fibonacci adaptation.

The script can automatically adapt both price amplitude and time duration to the current structure.

6. Manual drawing controls
The automatically fitted historical path and future projection can be adjusted independently. Users can change their height, width, horizontal position, and vertical position without changing the historical match itself.

VISUAL OUTPUTS

- Historical match box: marks the selected analog period.
- Fitted historical pattern: overlays the normalized historical structure on the current target.
- Future projection: displays the continuation that followed the historical analog, adapted to the current structure.
- Diagnostics table: shows the search timeframe, matched dates, total score, correlation, retracement score, amplitude scale, time scale, and number of evaluated candidates.

BASIC USE

1. Select the historical search timeframe.
2. Select the historical start and end dates.
3. Define the current target structure.
4. Set the historical pattern length and future projection length.
5. Adjust the minimum score and scoring weights if necessary.
6. Choose Percentage, Fibonacci, or Smart hybrid adaptation.
7. Use the manual drawing controls only after reviewing the automatic fit.

INTERPRETATION

The total score measures similarity under the script's selected criteria. It is not a probability of the projected path occurring. A high score means that the compared structures are mathematically similar according to the configured inputs; it does not mean that market context, liquidity, news, volatility, or order flow are identical.

LIMITATIONS

- Historical analogs can fail and should not be treated as deterministic forecasts.
- Results depend on the selected date range, timeframe, pattern length, score weights, and available historical data.
- Enabling the current unconfirmed bar can cause the selected match and projection to change intrabar.
- Lower-timeframe searches may require more data and processing resources.
- Manual resizing improves visual alignment but does not increase the statistical validity of the match.
- The indicator does not provide entries, exits, stop losses, or position sizing.

OPEN-SOURCE REUSE AND CREDITS

This script is a derivative work based in part on the open-source script "Auto Fractal [theUltimator5]" originally published by TheUltimator5.

Original author and original portions:
TheUltimator5

Substantial redesign, new logic, and additional code:
Aaron Diaz

The derivative adds independent multi-timeframe searching, date-restricted candidate selection, normalized log-return matching, composite scoring, adaptive percentage/Fibonacci projections, time and amplitude scaling, manual fit controls, and expanded diagnostics.

This publication is open-source and retains attribution to the original author under TradingView's open-source reuse rules and the Mozilla Public License 2.0.

DISCLAIMER

This indicator is provided for educational and analytical purposes only. It is not financial advice. Historical similarity does not guarantee future similarity. Users remain responsible for their own analysis, risk management, and trading decisions.


DESCRIPCION EN ESPANOL

RESUMEN

AutoFractal MTF Adaptive Projection busca estructuras historicas del precio que se parezcan a una estructura actual definida por el usuario. La temporalidad historica funciona de manera independiente a la temporalidad visible del grafico, por lo que es posible observar un grafico diario mientras se buscan analogias en 4 horas, 2 horas, diario u otras temporalidades compatibles.

El indicador funciona como una herramienta de comparacion estructural y proyeccion de escenarios. No genera senales de compra o venta y la ruta proyectada no debe interpretarse como una prediccion garantizada.

COMO FUNCIONA

1. Rango historico
El usuario selecciona una fecha inicial, una fecha final y la temporalidad historica. El script evalua candidatos solamente dentro de ese periodo.

2. Estructura actual
La estructura que se quiere comparar puede definirse mediante las ultimas N velas del grafico o mediante un rango manual de fechas.

3. Comparacion normalizada
Las estructuras se comparan mediante rendimientos logaritmicos normalizados y no mediante precios absolutos. Esto permite comparar patrones ocurridos en niveles de precio y condiciones de mercado diferentes.

4. Puntuacion compuesta
Cada candidato recibe una puntuacion basada en:
- Forma y correlacion.
- Retrocesos y comportamiento Fibonacci.
- Amplitud relativa.
- Direccion.

Tambien se pueden permitir fractales inversos.

5. Proyeccion adaptativa
El indicador utiliza la continuacion posterior del fractal historico como un escenario analogo. Existen tres metodos:
- Percentage: adapta porcentualmente el movimiento historico.
- Fibonacci: adapta la continuacion de acuerdo con la relacion entre los rangos historico y actual.
- Smart hybrid: combina ambos metodos.

La amplitud y la duracion temporal pueden adaptarse automaticamente a la estructura actual.

6. Ajuste manual
El patron historico ajustado y la proyeccion futura pueden modificarse por separado en altura, ancho y posicion, sin cambiar el fractal historico seleccionado.

INTERPRETACION Y LIMITACIONES

La puntuacion total mide similitud matematica bajo los parametros elegidos; no representa la probabilidad de que la proyeccion se cumpla. Los resultados pueden cambiar al modificar las fechas, la temporalidad, la longitud, los pesos o al incluir una vela sin cerrar. La herramienta no proporciona entradas, salidas, stop loss ni tamano de posicion.

CREDITOS

Este script es una obra derivada basada parcialmente en el script abierto "Auto Fractal [theUltimator5]", publicado originalmente por TheUltimator5.

Autor original y partes originales:
TheUltimator5

Rediseno sustancial, nueva logica y codigo adicional:
Aaron Diaz

La publicacion se realiza como codigo abierto, conserva la atribucion correspondiente y mantiene la licencia Mozilla Public License 2.0.

AVISO

Este indicador tiene fines educativos y de analisis. No constituye asesoria financiera. La similitud historica no garantiza que el mercado repita el mismo comportamiento.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
//
// OPEN-SOURCE ATTRIBUTION AND DERIVATIVE-WORK NOTICE
// Based in part on the open-source script "Auto Fractal [theUltimator5]"
// originally published by TheUltimator5.
//
// Original author and original portions: TheUltimator5.
// Substantial redesign, new logic, and additional code: Aaron Diaz, 2026.
//
// Major additions in this derivative work:
// - Independent multi-timeframe historical data acquisition.
// - Date-restricted historical candidate search.
// - Normalized log-return pattern comparison.
// - Composite similarity scoring.
// - Percentage, Fibonacci, and hybrid adaptive projections.
// - Automatic amplitude and time scaling.
// - Manual fit and projection sizing/position controls.
// - Diagnostic table and historical-match visualization.
//
// This derivative should be published open-source in accordance with
// TradingView's open-source reuse rules and the MPL 2.0 license.
//
// Copyright (c) TheUltimator5 - original portions.
// Copyright (c) 2026 Aaron Diaz - modifications and new portions.

//@version=6
indicator(
     "AutoFractal MTF Adaptive Projection [Aaron Diaz]",
     shorttitle = "AutoFractal MTF",
     overlay = true,
     max_bars_back = 5000,
     max_lines_count = 500,
     max_boxes_count = 20,
     max_labels_count = 50)

//=============================================================================
// INPUTS
//=============================================================================

groupSource = "1. Historical source"
string sourceTf = input.timeframe("240", "Historical search timeframe", group = groupSource)
int searchFrom = input.time(timestamp("2024-01-01 00:00 +0000"), "Search from", confirm = true, group = groupSource)
int searchTo   = input.time(timestamp("2026-12-31 23:59 +0000"), "Search to", confirm = true, group = groupSource)
int historicalBars = input.int(60, "Historical pattern length (source TF bars)", minval = 8, maxval = 500, group = groupSource)
int historicalFutureBars = input.int(30, "Historical future bars to project", minval = 2, maxval = 250, group = groupSource)
int candidateStep = input.int(1, "Minimum candidate step", minval = 1, maxval = 50, group = groupSource)
int maxCandidates = input.int(2500, "Maximum candidates evaluated", minval = 100, maxval = 10000, group = groupSource)


groupTarget = "2. Current target structure"
string targetMode = input.string("Latest N chart bars", "Current structure mode", options = ["Latest N chart bars", "Date range"], group = groupTarget)
int targetBars = input.int(30, "Current chart bars", minval = 8, maxval = 500, group = groupTarget)
int targetFrom = input.time(timestamp("2026-01-01 00:00 +0000"), "Current structure from", confirm = true, group = groupTarget)
int targetTo = input.time(timestamp("2026-12-31 23:59 +0000"), "Current structure to", confirm = true, group = groupTarget)
bool includeLiveBar = input.bool(true, "Include current unconfirmed bar", group = groupTarget)


groupMatch = "3. Similarity engine"
int samples = input.int(32, "Normalized comparison points", minval = 12, maxval = 80, group = groupMatch)
bool allowInverse = input.bool(false, "Allow inverse fractals", group = groupMatch)
float minScore = input.float(0.70, "Minimum score", minval = 0.0, maxval = 1.0, step = 0.01, group = groupMatch)
float shapeWeight = input.float(0.60, "Weight: shape/correlation", minval = 0.0, maxval = 1.0, step = 0.05, group = groupMatch)
float fibWeight = input.float(0.20, "Weight: retracement/Fibonacci", minval = 0.0, maxval = 1.0, step = 0.05, group = groupMatch)
float amplitudeWeight = input.float(0.10, "Weight: amplitude", minval = 0.0, maxval = 1.0, step = 0.05, group = groupMatch)
float directionWeight = input.float(0.10, "Weight: direction", minval = 0.0, maxval = 1.0, step = 0.05, group = groupMatch)


groupProjection = "4. Adaptation and projection"
string adaptationMode = input.string("Smart hybrid", "Adaptation method", options = ["Percentage", "Fibonacci", "Smart hybrid"], group = groupProjection)
float hybridFibWeight = input.float(0.60, "Fibonacci weight in hybrid mode", minval = 0.0, maxval = 1.0, step = 0.05, group = groupProjection)
float projectionMultiplier = input.float(1.0, "Final projection multiplier", minval = 0.10, maxval = 5.0, step = 0.05, group = groupProjection)
float minAmplitudeScale = input.float(0.35, "Minimum amplitude scale", minval = 0.05, maxval = 2.0, step = 0.05, group = groupProjection)
float maxAmplitudeScale = input.float(2.50, "Maximum amplitude scale", minval = 0.50, maxval = 10.0, step = 0.10, group = groupProjection)
bool adaptTime = input.bool(true, "Adapt time duration", group = groupProjection)


groupManual = "5. Manual drawing adjustment"
float fitHeightMultiplier = input.float(1.0, "Fit height multiplier", minval = 0.10, maxval = 5.0, step = 0.05, group = groupManual)
float fitWidthMultiplier = input.float(1.0, "Fit width/duration multiplier", minval = 0.10, maxval = 5.0, step = 0.05, group = groupManual)
float fitVerticalOffsetPct = input.float(0.0, "Move fit up/down (%)", minval = -50.0, maxval = 50.0, step = 0.10, group = groupManual)
int fitHorizontalOffsetBars = input.int(0, "Move fit left/right (chart bars)", minval = -500, maxval = 500, group = groupManual)

string projectionAnchorMode = input.string(
     "Current target end",
     "Anchor projection from",
     options = ["Current target end", "End of fitted pattern"],
     group = groupManual)

float projectionHeightMultiplier = input.float(1.0, "Projection height multiplier", minval = 0.10, maxval = 5.0, step = 0.05, group = groupManual)
float projectionWidthMultiplier = input.float(1.0, "Projection width/duration multiplier", minval = 0.10, maxval = 5.0, step = 0.05, group = groupManual)
float projectionVerticalOffsetPct = input.float(0.0, "Move projection up/down (%)", minval = -50.0, maxval = 50.0, step = 0.10, group = groupManual)
int projectionHorizontalOffsetBars = input.int(0, "Move projection left/right (chart bars)", minval = -500, maxval = 500, group = groupManual)


groupVisual = "6. Visualization"
bool showHistoricalBox = input.bool(true, "Show historical match box", group = groupVisual)
bool showFit = input.bool(true, "Show fitted historical pattern", group = groupVisual)
bool showProjection = input.bool(true, "Show future projection", group = groupVisual)
bool showTable = input.bool(true, "Show diagnostics table", group = groupVisual)
color fitColor = input.color(color.orange, "Fit color", group = groupVisual)
color projectionColor = input.color(color.fuchsia, "Projection color", group = groupVisual)
color historicalBoxColor = input.color(color.lime, "Historical box color", group = groupVisual)
int lineWidth = input.int(2, "Line width", minval = 1, maxval = 5, group = groupVisual)


groupPerformance = "7. Performance"
int maxStoredSourceBars = input.int(20000, "Maximum stored source bars", minval = 1000, maxval = 100000, group = groupPerformance)
int maxStoredChartBars = input.int(7000, "Maximum stored chart bars", minval = 1000, maxval = 20000, group = groupPerformance)

//=============================================================================
// ARRAYS AND GRAPHICS
//=============================================================================

var array<int> srcTimes = array.new_int()
var array<float> srcClose = array.new_float()
var array<float> srcHigh = array.new_float()
var array<float> srcLow = array.new_float()

var array<int> chartTimes = array.new_int()
var array<float> chartClose = array.new_float()
var array<float> chartHigh = array.new_float()
var array<float> chartLow = array.new_float()

var array<line> fitLines = array.new_line()
var array<line> projectionLines = array.new_line()
var box historicalBox = na
var table infoTable = table.new(position.top_right, 2, 10, border_width = 1)

//=============================================================================
// HELPERS
//=============================================================================

f_clamp(float value, float lowLimit, float highLimit) =>
    math.max(lowLimit, math.min(highLimit, value))

f_push_unique(array<int> times, array<float> closes, array<float> highs, array<float> lows,
              int newTime, float newClose, float newHigh, float newLow, int maxSize) =>
    if not na(newTime) and not na(newClose)
        int sizeNow = array.size(times)
        if sizeNow == 0
            array.push(times, newTime)
            array.push(closes, newClose)
            array.push(highs, newHigh)
            array.push(lows, newLow)
        else
            int lastTime = array.get(times, sizeNow - 1)
            if newTime > lastTime
                array.push(times, newTime)
                array.push(closes, newClose)
                array.push(highs, newHigh)
                array.push(lows, newLow)
            else if newTime == lastTime
                array.set(closes, sizeNow - 1, newClose)
                array.set(highs, sizeNow - 1, newHigh)
                array.set(lows, sizeNow - 1, newLow)
        while array.size(times) > maxSize
            array.shift(times)
            array.shift(closes)
            array.shift(highs)
            array.shift(lows)

f_clear_lines(array<line> lines) =>
    while array.size(lines) > 0
        line.delete(array.pop(lines))

f_first_index_at_or_after(array<int> times, int selectedTime) =>
    int result = na
    int count = array.size(times)
    if count > 0
        for i = 0 to count - 1
            if array.get(times, i) >= selectedTime
                result := i
                break
    result

f_last_index_at_or_before(array<int> times, int selectedTime) =>
    int result = na
    int count = array.size(times)
    if count > 0
        int i = count - 1
        while i >= 0
            if array.get(times, i) <= selectedTime
                result := i
                break
            i -= 1
    result

f_interpolated_price(array<float> values, int startIndex, int length, int sampleIndex, int sampleCount) =>
    float result = na
    if length > 0 and sampleCount > 1
        float position = float(sampleIndex) * float(length - 1) / float(sampleCount - 1)
        int leftIndex = int(math.floor(position))
        int rightIndex = math.min(leftIndex + 1, length - 1)
        float fraction = position - float(leftIndex)
        float leftValue = array.get(values, startIndex + leftIndex)
        float rightValue = array.get(values, startIndex + rightIndex)
        result := leftValue + (rightValue - leftValue) * fraction
    result

f_interpolated_time(array<int> times, int startIndex, int length, int sampleIndex, int sampleCount) =>
    int result = na
    if length > 0 and sampleCount > 1
        float position = float(sampleIndex) * float(length - 1) / float(sampleCount - 1)
        int leftIndex = int(math.floor(position))
        int rightIndex = math.min(leftIndex + 1, length - 1)
        float fraction = position - float(leftIndex)
        int leftTime = array.get(times, startIndex + leftIndex)
        int rightTime = array.get(times, startIndex + rightIndex)
        result := int(math.round(float(leftTime) + float(rightTime - leftTime) * fraction))
    result

f_sample_log_return(array<float> values, int startIndex, int length, int sampleIndex, int sampleCount) =>
    float basePrice = array.get(values, startIndex)
    float sampledPrice = f_interpolated_price(values, startIndex, length, sampleIndex, sampleCount)
    float result = na
    if basePrice > 0 and sampledPrice > 0
        result := math.log(sampledPrice / basePrice)
    result

f_build_normalized(array<float> values, int startIndex, int length, int sampleCount) =>
    array<float> output = array.new_float()
    for i = 0 to sampleCount - 1
        array.push(output, f_sample_log_return(values, startIndex, length, i, sampleCount))
    output

f_array_mean(array<float> values) =>
    float sum = 0.0
    int count = array.size(values)
    if count > 0
        for i = 0 to count - 1
            sum += array.get(values, i)
    count > 0 ? sum / count : na

f_array_range(array<float> values) =>
    float minimum = 1e100
    float maximum = -1e100
    int count = array.size(values)
    if count > 0
        for i = 0 to count - 1
            float value = array.get(values, i)
            minimum := math.min(minimum, value)
            maximum := math.max(maximum, value)
    count > 0 ? maximum - minimum : na

f_retracement_ratio(array<float> values) =>
    int count = array.size(values)
    float ratio = 0.0
    if count > 1
        float firstValue = array.get(values, 0)
        float lastValue = array.get(values, count - 1)
        float rangeValue = f_array_range(values)
        if rangeValue > 0
            if lastValue >= firstValue
                float runningMaximum = -1e100
                float maximumDrawdown = 0.0
                for i = 0 to count - 1
                    float value = array.get(values, i)
                    runningMaximum := math.max(runningMaximum, value)
                    maximumDrawdown := math.max(maximumDrawdown, runningMaximum - value)
                ratio := maximumDrawdown / rangeValue
            else
                float runningMinimum = 1e100
                float maximumBounce = 0.0
                for i = 0 to count - 1
                    float value = array.get(values, i)
                    runningMinimum := math.min(runningMinimum, value)
                    maximumBounce := math.max(maximumBounce, value - runningMinimum)
                ratio := maximumBounce / rangeValue
    ratio

f_candidate_metrics(array<float> sourceValues, int candidateStart, int candidateLength,
                    array<float> targetNormalized, float targetMean, float targetRange,
                    float targetRetracement, int sampleCount, bool permitInverse,
                    float wShape, float wFib, float wAmplitude, float wDirection) =>
    float candidateMean = 0.0
    float candidateMinimum = 1e100
    float candidateMaximum = -1e100

    for i = 0 to sampleCount - 1
        float candidateValue = f_sample_log_return(sourceValues, candidateStart, candidateLength, i, sampleCount)
        candidateMean += candidateValue
        candidateMinimum := math.min(candidateMinimum, candidateValue)
        candidateMaximum := math.max(candidateMaximum, candidateValue)
    candidateMean /= sampleCount

    float covariance = 0.0
    float candidateVariance = 0.0
    float targetVariance = 0.0
    for i = 0 to sampleCount - 1
        float candidateValue = f_sample_log_return(sourceValues, candidateStart, candidateLength, i, sampleCount)
        float targetValue = array.get(targetNormalized, i)
        float candidateDeviation = candidateValue - candidateMean
        float targetDeviation = targetValue - targetMean
        covariance += candidateDeviation * targetDeviation
        candidateVariance += candidateDeviation * candidateDeviation
        targetVariance += targetDeviation * targetDeviation

    float correlation = candidateVariance > 0 and targetVariance > 0 ? covariance / math.sqrt(candidateVariance * targetVariance) : na
    bool inverted = permitInverse and not na(correlation) and correlation < 0
    float correlationScore = na(correlation) ? 0.0 : permitInverse ? math.abs(correlation) : math.max(correlation, 0.0)

    float candidateRange = candidateMaximum - candidateMinimum
    float amplitudeRatio = candidateRange > 0 and targetRange > 0 ? targetRange / candidateRange : 1.0
    float amplitudeScore = amplitudeRatio > 0 ? math.min(amplitudeRatio, 1.0 / amplitudeRatio) : 0.0

    array<float> adjustedCandidate = array.new_float()
    for i = 0 to sampleCount - 1
        float value = f_sample_log_return(sourceValues, candidateStart, candidateLength, i, sampleCount)
        array.push(adjustedCandidate, inverted ? -value : value)

    float candidateRetracement = f_retracement_ratio(adjustedCandidate)
    float fibScore = f_clamp(1.0 - math.abs(candidateRetracement - targetRetracement), 0.0, 1.0)

    float targetNet = array.get(targetNormalized, sampleCount - 1)
    float candidateNet = array.get(adjustedCandidate, sampleCount - 1)
    float directionDenominator = math.max(math.max(math.abs(targetNet), math.abs(candidateNet)), 0.000001)
    float directionScore = f_clamp(1.0 - math.abs(targetNet - candidateNet) / directionDenominator, 0.0, 1.0)

    float weightTotal = math.max(wShape + wFib + wAmplitude + wDirection, 0.000001)
    float totalScore = (correlationScore * wShape + fibScore * wFib + amplitudeScore * wAmplitude + directionScore * wDirection) / weightTotal

    float regressionScale = candidateVariance > 0 ? math.abs(covariance / candidateVariance) : amplitudeRatio
    [totalScore, correlation, fibScore, amplitudeScore, directionScore, candidateRange, regressionScale, inverted]

f_format_date(int selectedTime) =>
    na(selectedTime) ? "n/a" : str.format_time(selectedTime, "dd MMM yyyy HH:mm", syminfo.timezone)

//=============================================================================
// DATA REQUESTS
//=============================================================================

float chartSeconds = timeframe.in_seconds()
float sourceSeconds = timeframe.in_seconds(sourceTf)
bool sourceIsLower = sourceSeconds < chartSeconds

// Reliable lower-timeframe request. Returns arrays of all available intrabars.
[lowerTimes, lowerCloses, lowerHighs, lowerLows] = request.security_lower_tf(
         syminfo.tickerid,
         sourceTf,
         [time, close, high, low],
         ignore_invalid_timeframe = true,
         calc_bars_count = 100000)

// Equal/higher timeframe request. Duplicate timestamps are removed before storage.
[requestedTime, requestedClose, requestedHigh, requestedLow] = request.security(
         syminfo.tickerid,
         sourceTf,
         [time, close, high, low],
         lookahead = barmerge.lookahead_off,
         calc_bars_count = 10000)

// Store chart-timeframe data.
f_push_unique(chartTimes, chartClose, chartHigh, chartLow, time, close, high, low, maxStoredChartBars)

// Store independently selected source-timeframe data.
if sourceIsLower
    int lowerCount = array.size(lowerTimes)
    if lowerCount > 0
        for i = 0 to lowerCount - 1
            f_push_unique(
                 srcTimes,
                 srcClose,
                 srcHigh,
                 srcLow,
                 array.get(lowerTimes, i),
                 array.get(lowerCloses, i),
                 array.get(lowerHighs, i),
                 array.get(lowerLows, i),
                 maxStoredSourceBars)
else
    f_push_unique(srcTimes, srcClose, srcHigh, srcLow, requestedTime, requestedClose, requestedHigh, requestedLow, maxStoredSourceBars)

//=============================================================================
// SEARCH, ADAPTATION AND DRAWING
//=============================================================================

if barstate.islast
    f_clear_lines(fitLines)
    f_clear_lines(projectionLines)
    if not na(historicalBox)
        box.delete(historicalBox)
        historicalBox := na

    if showTable
        table.clear(infoTable, 0, 0, 1, 9)

    int chartCount = array.size(chartTimes)
    int sourceCount = array.size(srcTimes)

    int targetStartIndex = na
    int targetEndIndex = na

    if targetMode == "Latest N chart bars"
        int usableChartCount = includeLiveBar ? chartCount : math.max(chartCount - 1, 0)
        if usableChartCount >= targetBars
            targetEndIndex := usableChartCount - 1
            targetStartIndex := targetEndIndex - targetBars + 1
    else
        targetStartIndex := f_first_index_at_or_after(chartTimes, targetFrom)
        targetEndIndex := f_last_index_at_or_before(chartTimes, targetTo)
        if not includeLiveBar and not na(targetEndIndex) and targetEndIndex == chartCount - 1
            targetEndIndex -= 1

    bool validTarget = not na(targetStartIndex) and not na(targetEndIndex) and targetEndIndex > targetStartIndex
    int targetLength = validTarget ? targetEndIndex - targetStartIndex + 1 : 0

    int searchFirstIndex = f_first_index_at_or_after(srcTimes, searchFrom)
    int searchLastIndex = f_last_index_at_or_before(srcTimes, searchTo)

    bool enoughSource = not na(searchFirstIndex) and not na(searchLastIndex) and sourceCount > 0
    int lastCandidateStart = enoughSource ? searchLastIndex - historicalBars + 1 : na

    float bestScore = na
    float bestCorrelation = na
    float bestFibScore = na
    float bestAmplitudeScore = na
    float bestDirectionScore = na
    float bestCandidateRange = na
    float bestRegressionScale = na
    bool bestInverted = false
    int bestStartIndex = na
    int testedCandidates = 0
    int effectiveStep = candidateStep

    array<float> targetNormalized = array.new_float()
    float targetMean = na
    float targetRange = na
    float targetRetracement = na

    if validTarget and enoughSource and targetLength >= 2 and historicalBars >= 2
        targetNormalized := f_build_normalized(chartClose, targetStartIndex, targetLength, samples)
        targetMean := f_array_mean(targetNormalized)
        targetRange := f_array_range(targetNormalized)
        targetRetracement := f_retracement_ratio(targetNormalized)

        int candidateCountRaw = lastCandidateStart >= searchFirstIndex ? lastCandidateStart - searchFirstIndex + 1 : 0
        effectiveStep := candidateCountRaw > maxCandidates ? math.max(candidateStep, int(math.ceil(float(candidateCountRaw) / float(maxCandidates)))) : candidateStep

        int candidateStart = searchFirstIndex
        while candidateStart <= lastCandidateStart and testedCandidates < maxCandidates
            int futureEndIndex = candidateStart + historicalBars + historicalFutureBars - 1
            if futureEndIndex < sourceCount
                [candidateScore, candidateCorrelation, candidateFibScore, candidateAmplitudeScore, candidateDirectionScore, candidateRange, candidateRegressionScale, candidateInverted] = f_candidate_metrics(
                         srcClose,
                         candidateStart,
                         historicalBars,
                         targetNormalized,
                         targetMean,
                         targetRange,
                         targetRetracement,
                         samples,
                         allowInverse,
                         shapeWeight,
                         fibWeight,
                         amplitudeWeight,
                         directionWeight)

                if not na(candidateScore) and (na(bestScore) or candidateScore > bestScore)
                    bestScore := candidateScore
                    bestCorrelation := candidateCorrelation
                    bestFibScore := candidateFibScore
                    bestAmplitudeScore := candidateAmplitudeScore
                    bestDirectionScore := candidateDirectionScore
                    bestCandidateRange := candidateRange
                    bestRegressionScale := candidateRegressionScale
                    bestInverted := candidateInverted
                    bestStartIndex := candidateStart

            candidateStart += effectiveStep
            testedCandidates += 1

    bool matchFound = not na(bestStartIndex) and not na(bestScore) and bestScore >= minScore

    if matchFound
        int bestPatternEndIndex = bestStartIndex + historicalBars - 1
        int bestFutureEndIndex = bestPatternEndIndex + historicalFutureBars

        int historicalStartTime = array.get(srcTimes, bestStartIndex)
        int historicalEndTime = array.get(srcTimes, bestPatternEndIndex)
        int currentStartTime = array.get(chartTimes, targetStartIndex)
        int currentEndTime = array.get(chartTimes, targetEndIndex)

        float currentStartPrice = array.get(chartClose, targetStartIndex)
        float currentEndPrice = array.get(chartClose, targetEndIndex)
        float historicalEndPrice = array.get(srcClose, bestPatternEndIndex)

        float rangeScale = bestCandidateRange > 0 and targetRange > 0 ? targetRange / bestCandidateRange : 1.0
        float regressionScale = na(bestRegressionScale) ? rangeScale : bestRegressionScale
        float fitScaleRaw = adaptationMode == "Percentage" ? regressionScale : adaptationMode == "Fibonacci" ? rangeScale : (regressionScale * (1.0 - hybridFibWeight) + rangeScale * hybridFibWeight)
        float fitScale = f_clamp(fitScaleRaw, minAmplitudeScale, maxAmplitudeScale)
        float inversionSign = bestInverted ? -1.0 : 1.0

        int historicalDuration = math.max(historicalEndTime - historicalStartTime, 1)
        int currentDuration = math.max(currentEndTime - currentStartTime, 1)
        float timeScale = adaptTime ? float(currentDuration) / float(historicalDuration) : 1.0

        // Manual drawing controls are applied AFTER the automatic adaptation.
        // A value of 1.00 preserves the automatic result.
        float effectiveFitScale = fitScale * fitHeightMultiplier
        float fitVerticalFactor = math.max(0.01, 1.0 + fitVerticalOffsetPct / 100.0)

        int currentBarMs = int(math.round(float(currentDuration) / float(math.max(targetLength - 1, 1))))
        currentBarMs := math.max(currentBarMs, 1)

        int adjustedFitStartTime = currentStartTime + fitHorizontalOffsetBars * currentBarMs
        int adjustedFitEndTime = adjustedFitStartTime + int(math.round(float(currentDuration) * fitWidthMultiplier))

        float fitEndNorm = f_sample_log_return(srcClose, bestStartIndex, historicalBars, samples - 1, samples) * inversionSign
        float adjustedFitEndPrice = currentStartPrice * math.exp(fitEndNorm * effectiveFitScale) * fitVerticalFactor

        float effectiveProjectionTimeScale = timeScale * projectionWidthMultiplier
        float projectionVerticalFactor = math.max(0.01, 1.0 + projectionVerticalOffsetPct / 100.0)

        int projectionAnchorTime = projectionAnchorMode == "End of fitted pattern" ? adjustedFitEndTime : currentEndTime
        projectionAnchorTime += projectionHorizontalOffsetBars * currentBarMs

        float projectionAnchorPrice = projectionAnchorMode == "End of fitted pattern" ? adjustedFitEndPrice : currentEndPrice
        projectionAnchorPrice *= projectionVerticalFactor

        // Draw the historical pattern adapted over the present structure.
        if showFit
            for i = 0 to samples - 2
                float norm1 = f_sample_log_return(srcClose, bestStartIndex, historicalBars, i, samples) * inversionSign
                float norm2 = f_sample_log_return(srcClose, bestStartIndex, historicalBars, i + 1, samples) * inversionSign

                float y1 = currentStartPrice * math.exp(norm1 * effectiveFitScale) * fitVerticalFactor
                float y2 = currentStartPrice * math.exp(norm2 * effectiveFitScale) * fitVerticalFactor

                int rawX1 = f_interpolated_time(chartTimes, targetStartIndex, targetLength, i, samples)
                int rawX2 = f_interpolated_time(chartTimes, targetStartIndex, targetLength, i + 1, samples)

                int x1 = adjustedFitStartTime + int(math.round(float(rawX1 - currentStartTime) * fitWidthMultiplier))
                int x2 = adjustedFitStartTime + int(math.round(float(rawX2 - currentStartTime) * fitWidthMultiplier))

                line newLine = line.new(x1, y1, x2, y2, xloc = xloc.bar_time, color = fitColor, width = lineWidth)
                array.push(fitLines, newLine)

        // Draw the future path using percentage, Fibonacci ratio, or a hybrid.
        if showProjection
            float historicalPatternRange = math.max(bestCandidateRange, 0.000001)
            float presentPatternRange = math.max(targetRange, 0.000001)
            int drawableFuture = math.min(historicalFutureBars, sourceCount - bestPatternEndIndex - 1)

            if drawableFuture >= 2
                for i = 0 to drawableFuture - 2
                    int sourceFutureIndex1 = bestPatternEndIndex + i + 1
                    int sourceFutureIndex2 = bestPatternEndIndex + i + 2

                    float historicalFutureLog1 = math.log(array.get(srcClose, sourceFutureIndex1) / historicalEndPrice) * inversionSign
                    float historicalFutureLog2 = math.log(array.get(srcClose, sourceFutureIndex2) / historicalEndPrice) * inversionSign

                    float percentageLog1 = historicalFutureLog1 * fitScale
                    float percentageLog2 = historicalFutureLog2 * fitScale
                    float fibonacciLog1 = (historicalFutureLog1 / historicalPatternRange) * presentPatternRange
                    float fibonacciLog2 = (historicalFutureLog2 / historicalPatternRange) * presentPatternRange

                    float projectedLog1 = adaptationMode == "Percentage" ? percentageLog1 : adaptationMode == "Fibonacci" ? fibonacciLog1 : percentageLog1 * (1.0 - hybridFibWeight) + fibonacciLog1 * hybridFibWeight
                    float projectedLog2 = adaptationMode == "Percentage" ? percentageLog2 : adaptationMode == "Fibonacci" ? fibonacciLog2 : percentageLog2 * (1.0 - hybridFibWeight) + fibonacciLog2 * hybridFibWeight

                    projectedLog1 *= projectionMultiplier * projectionHeightMultiplier
                    projectedLog2 *= projectionMultiplier * projectionHeightMultiplier

                    float projectedPrice1 = projectionAnchorPrice * math.exp(projectedLog1)
                    float projectedPrice2 = projectionAnchorPrice * math.exp(projectedLog2)

                    int sourceDeltaTime1 = array.get(srcTimes, sourceFutureIndex1) - historicalEndTime
                    int sourceDeltaTime2 = array.get(srcTimes, sourceFutureIndex2) - historicalEndTime
                    int projectedTime1 = projectionAnchorTime + int(math.round(float(sourceDeltaTime1) * effectiveProjectionTimeScale))
                    int projectedTime2 = projectionAnchorTime + int(math.round(float(sourceDeltaTime2) * effectiveProjectionTimeScale))

                    line futureLine = line.new(projectedTime1, projectedPrice1, projectedTime2, projectedPrice2, xloc = xloc.bar_time, color = projectionColor, style = line.style_dotted, width = lineWidth)
                    array.push(projectionLines, futureLine)

        // Historical box uses the actual source-timeframe prices and timestamps.
        if showHistoricalBox
            float historicalTop = -1e100
            float historicalBottom = 1e100
            for i = bestStartIndex to bestPatternEndIndex
                historicalTop := math.max(historicalTop, array.get(srcHigh, i))
                historicalBottom := math.min(historicalBottom, array.get(srcLow, i))
            historicalBox := box.new(
                 left = historicalStartTime,
                 top = historicalTop,
                 right = historicalEndTime,
                 bottom = historicalBottom,
                 xloc = xloc.bar_time,
                 border_color = historicalBoxColor,
                 bgcolor = color.new(historicalBoxColor, 88))

        if showTable
            color scoreColor = bestScore >= 0.85 ? color.new(color.green, 15) : bestScore >= 0.75 ? color.new(color.orange, 10) : color.new(color.red, 10)
            table.cell(infoTable, 0, 0, "AutoFractal", text_color = color.white, bgcolor = color.new(color.black, 0))
            table.cell(infoTable, 1, 0, "Aaron Diaz adaptation", text_color = color.white, bgcolor = color.new(color.black, 0))
            table.cell(infoTable, 0, 1, "Search TF", text_color = color.white)
            table.cell(infoTable, 1, 1, sourceTf, text_color = color.white)
            table.cell(infoTable, 0, 2, "Historical match", text_color = color.white)
            table.cell(infoTable, 1, 2, f_format_date(historicalStartTime) + " → " + f_format_date(historicalEndTime), text_color = color.white)
            table.cell(infoTable, 0, 3, "Total score", text_color = color.white)
            table.cell(infoTable, 1, 3, str.tostring(bestScore * 100.0, "#.0") + "%", text_color = color.white, bgcolor = scoreColor)
            table.cell(infoTable, 0, 4, "Correlation", text_color = color.white)
            table.cell(infoTable, 1, 4, str.tostring(bestCorrelation * 100.0, "#.0") + "%" + (bestInverted ? " inverse" : ""), text_color = color.white)
            table.cell(infoTable, 0, 5, "Fib / retracement", text_color = color.white)
            table.cell(infoTable, 1, 5, str.tostring(bestFibScore * 100.0, "#.0") + "%", text_color = color.white)
            table.cell(infoTable, 0, 6, "Amplitude scale", text_color = color.white)
            table.cell(infoTable, 1, 6, str.tostring(effectiveFitScale, "#.00") + "x", text_color = color.white)
            table.cell(infoTable, 0, 7, "Time scale", text_color = color.white)
            table.cell(infoTable, 1, 7, str.tostring(effectiveProjectionTimeScale, "#.00") + "x", text_color = color.white)
            table.cell(infoTable, 0, 8, "Adaptation", text_color = color.white)
            table.cell(infoTable, 1, 8, adaptationMode, text_color = color.white)
            table.cell(infoTable, 0, 9, "Candidates", text_color = color.white)
            table.cell(infoTable, 1, 9, str.tostring(testedCandidates) + " · step " + str.tostring(effectiveStep), text_color = color.white)
    else
        if showTable
            string reason = not validTarget ? "Invalid current structure" : not enoughSource ? "No source data in selected range" : "No match exceeds the minimum score"
            table.cell(infoTable, 0, 0, "AutoFractal", text_color = color.white, bgcolor = color.new(color.black, 0))
            table.cell(infoTable, 1, 0, "Aaron Diaz adaptation", text_color = color.white, bgcolor = color.new(color.black, 0))
            table.cell(infoTable, 0, 1, "Status", text_color = color.white)
            table.cell(infoTable, 1, 1, reason, text_color = color.white, bgcolor = color.new(color.red, 20))
            table.cell(infoTable, 0, 2, "Search TF", text_color = color.white)
            table.cell(infoTable, 1, 2, sourceTf, text_color = color.white)
            table.cell(infoTable, 0, 3, "Source bars", text_color = color.white)
            table.cell(infoTable, 1, 3, str.tostring(sourceCount), text_color = color.white)
            table.cell(infoTable, 0, 4, "Chart bars", text_color = color.white)
            table.cell(infoTable, 1, 4, str.tostring(chartCount), text_color = color.white)
            table.cell(infoTable, 0, 5, "Best score", text_color = color.white)
            table.cell(infoTable, 1, 5, na(bestScore) ? "n/a" : str.tostring(bestScore * 100.0, "#.0") + "%", text_color = color.white)
````
