# K-NN Pattern Forecast

- url: https://www.tradingview.com/script/TiOb6SUA-K-NN-Pattern-Forecast/
- type: indicator
- pine_id: PUB;d54fa48cf7514f65a563895faf1aa44c
- version: 1.0

## Description

K-NN Pattern Forecast

K-NN Pattern Forecast is an educational forecast indicator that uses historical pattern similarity to project a probabilistic future price path.

The indicator compares the most recent confirmed price pattern with similar historical patterns on the same chart. It then calculates the average forward movement of the closest historical matches and displays a projected path, probability estimates, a quality grade, and a dashboard summary.

This is a forecast indicator, not a trading strategy. It does not place trades, does not simulate orders, and does not provide backtested strategy results. The forecast is probabilistic and based only on historical similarity. It should not be interpreted as a guaranteed prediction, financial advice, or an automatic buy/sell signal.

What the indicator does

The script analyzes recent price behavior and searches historical chart data for similar patterns.

It then estimates what happened after those similar historical patterns and uses that information to create a forward projection.

The indicator displays:

* Forecast direction.
* Forecast path.
* Probability of upward movement.
* Probability of downward movement.
* Projected move percentage.
* ±1 standard deviation forecast band.
* Normalized pattern distance.
* Number of historical matches used.
* Quality score.
* A / B / C grade classification.
* Dashboard summary.

Core concept

The indicator uses a K-Nearest Neighbors style approach.

K-NN is a similarity-based method. Instead of using fixed trend rules or moving-average crosses, the script compares the current market pattern to past patterns and studies the forward movement that followed those historical matches.

The logic is based on the idea that similar price structures may sometimes lead to similar short-term outcomes, but the result is never guaranteed.

How the pattern matching works

1. Current pattern construction

The script builds the current pattern from recent confirmed candles.

It uses log returns between consecutive closes rather than raw price values. This helps normalize the pattern so that the comparison focuses more on shape and movement structure than absolute price level.

2. Historical search

The script searches through a selected historical window and builds comparable historical patterns using the same pattern length.

Each historical candidate is compared with the current pattern.

3. Distance calculation

The script calculates the Euclidean distance between the current pattern and each historical pattern.

A smaller distance means the historical pattern is more similar to the current pattern.

4. K nearest matches

The script selects the closest historical matches based on the K Nearest Neighbors setting.

These selected matches are then used to calculate the forecast.

5. Forward projection

For each selected match, the script studies what happened during the selected forecast horizon after that historical pattern.

The average forward movement becomes the main projected forecast path.

6. Forecast band

The script also calculates dispersion around the forecast using a standard deviation band.

The ±1σ band is intended to show uncertainty around the projected path. A wider band means the historical outcomes were more dispersed and less consistent.

Dashboard explanation

The dashboard summarizes the forecast output:

Direction

Shows whether the average projected move is bullish, bearish, or neutral.

Grade

Classifies forecast quality as A Grade, B Grade, or C Grade.

A Grade means the forecast has stronger alignment according to the script’s scoring model.
B Grade means moderate alignment.
C Grade means weak, noisy, or lower-quality alignment.

The grade is not a guarantee of future movement. It is only a quality classification based on the script’s internal probability, distance, and forecast-band criteria.

Score

Shows the total quality score out of 100.

The score combines:

* Directional probability.
* Normalized distance between the current pattern and historical matches.
* Width of the ±1σ forecast band.

Status

Shows a simplified interpretation of the grade:

* Strong Setup.
* Moderate Setup.
* Weak / Noisy.

Projected Move

Shows the average projected percentage move over the selected forecast horizon.

P(up)

Shows the percentage of selected historical matches that moved upward over the forecast horizon.

P(down)

Shows the percentage of selected historical matches that moved downward over the forecast horizon.

±1σ Band

Shows the estimated one-standard-deviation forecast band percentage.

A smaller band suggests that the selected historical outcomes were more clustered. A larger band suggests more uncertainty.

Normalized Distance

Shows the average similarity distance adjusted by pattern length.

Lower values indicate closer historical similarity. Higher values indicate weaker similarity.

Matches

Shows how many historical matches were used compared with the selected K value.

Forecast grading model

The script uses an internal scoring model based on three elements:

1. Direction probability

Higher directional probability receives a higher score.

For example, if most selected historical matches moved in the same direction, the probability component improves.

2. Normalized distance

Lower normalized distance means the selected historical patterns are more similar to the current pattern.

Closer matches improve the score.

3. Forecast band width

A narrower ±1σ band suggests the historical outcomes were more consistent.

A wider band reduces the score because the forecast has more uncertainty.

A Grade / B Grade / C Grade

A Grade

Represents the strongest forecast quality according to the selected scoring thresholds. It usually means the direction probability is stronger, historical matches are closer, and the forecast band is more controlled.

B Grade

Represents a moderate forecast quality. The setup has some useful alignment, but the forecast is not as strong as A Grade.

C Grade

Represents a weaker or noisier forecast. This can happen when historical similarity is poor, probability is not strong, or the forecast band is wide.

Users can choose to hide C Grade forecasts if they want the chart to display only higher-quality forecast conditions.

Important note about the forecast

This indicator is a forecast tool, but it does not know the future.

The forecast is generated from historical similarity only. Market conditions can change, and a pattern that looked similar in the past may behave differently in the future.

The projected path should be treated as a probabilistic scenario, not a price target and not a trade recommendation.

How to use it

A practical workflow is:

1. Choose a liquid symbol and timeframe.
2. Set the Pattern Length to define how many recent bars form the current pattern.
3. Set the History Search Window to define how much past data the script searches.
4. Set K Nearest Neighbors to control how many similar historical patterns are used.
5. Set the Forecast Horizon to define how many bars forward the projection extends.
6. Review the forecast direction and projected move.
7. Check the probability values and the ±1σ band.
8. Give more weight to forecasts with better grades and lower normalized distance.
9. Avoid treating the forecast path as a guaranteed outcome.
10. Combine the forecast with independent market structure, liquidity, volume, risk management, and higher-timeframe analysis.

Inputs

Pattern Matching

* Pattern Length: number of bars used to define the current pattern.
* History Search Window: number of historical bars searched for similar patterns.
* K Nearest Neighbors: number of closest historical matches used in the forecast.
* Forecast Horizon: number of bars projected forward.

Forecast Quality Filter

* Hide C Grade Forecasts: hides lower-quality forecasts from the chart.
* A Grade Min Score: minimum score required for A Grade.
* B Grade Min Score: minimum score required for B Grade.
* Strong Direction Probability %: probability threshold used in the scoring model.
* Good Direction Probability %: secondary probability threshold used in the scoring model.
* Good Normalized Distance: stricter distance threshold for better similarity.
* Medium Normalized Distance: moderate distance threshold for similarity.
* Good ±1σ Band %: stricter band-width threshold.
* Medium ±1σ Band %: moderate band-width threshold.

Display

* Show Forecast Path: shows or hides the projected forecast path.
* Forecast Path Width: controls the forecast line thickness.
* Show ±1σ Confidence Band: shows or hides the forecast uncertainty band.
* Up Forecast Color: color used for bullish forecasts.
* Down Forecast Color: color used for bearish forecasts.
* Band Color: color used for the ±1σ band.

Dashboard Table

* Show Dashboard Table: shows or hides the dashboard.
* Table Position: controls dashboard location.
* Table Size: controls text size.
* Table Background: controls table background color.
* Table Text Color: controls dashboard text color.
* Table Border Color: controls dashboard border color.

Originality and usefulness

This indicator is designed as a historical-similarity forecast framework rather than a standard trend or momentum overlay.

Its usefulness comes from combining:

* Pattern matching using recent confirmed candle behavior.
* K-nearest historical comparison.
* Average forward path projection.
* Directional probability.
* Forecast dispersion using ±1σ band.
* A transparent quality score and grade.
* A dashboard that explains the current forecast state.

The goal is to help traders study whether the current price structure resembles prior market structures and what the average forward behavior looked like after those historical examples.

Limitations

This indicator does not predict future price with certainty.

A bullish forecast does not guarantee price will rise.
A bearish forecast does not guarantee price will fall.
An A Grade forecast does not guarantee a successful trade.
A C Grade forecast does not mean price cannot move strongly.

The forecast can change when new candles close because the current pattern changes.

The indicator uses confirmed candles only, but the displayed projection is recalculated as new confirmed data becomes available.

The quality of the forecast depends heavily on:

* Symbol.
* Timeframe.
* Available historical data.
* Pattern length.
* Search window.
* Number of neighbors.
* Forecast horizon.
* Market regime.
* Volatility conditions.
* Liquidity conditions.

Historical similarity does not guarantee future repetition.

Recommended use

K-NN Pattern Forecast is best used as an educational probabilistic forecast indicator.

It can help traders compare the current price pattern with similar historical patterns and evaluate possible forward scenarios, but it should always be used with independent analysis and proper risk management.

## Source Code

````pine
// This Pine Script© code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ADXAE

//@version=6
indicator("K-NN Pattern Forecast", "K-NN Forecast",
     overlay = true,
     max_lines_count = 500,
     max_labels_count = 50,
     max_bars_back = 3050)

// ============================================================
//  K-NN Pattern Forecast
//  ----------------------------------------------------------
//  Probabilistic historical-similarity forecast.
//  Uses confirmed candles only.
//  Dashboard includes Direction, Grade, Score, Probability,
//  Projected Move, ±1σ Band, Distance, and Matches.
// ============================================================


// -------------------- Inputs --------------------
grpP = "╔═══════ Pattern Matching ═══════╗"

patternLen = input.int(
     10,
     "Pattern Length (bars)",
     minval = 3,
     maxval = 20,
     group = grpP,
     tooltip = "Number of confirmed bars used to build the current price pattern. A shorter length reacts faster but may create noisier forecasts. A longer length requires a more specific historical match and may reduce the number of useful comparisons."
)

lookback = input.int(
     1000,
     "History Search Window",
     minval = 100,
     maxval = 3000,
     group = grpP,
     tooltip = "Number of historical bars searched for similar patterns. A larger window gives the model more examples to compare, but it may also include older market regimes that no longer behave the same way."
)

kNeighbors = input.int(
     15,
     "K Nearest Neighbors",
     minval = 3,
     maxval = 50,
     group = grpP,
     tooltip = "Number of closest historical pattern matches used to build the forecast. Lower values make the forecast more selective but less stable. Higher values make it smoother but may include weaker matches."
)

forecastLen = input.int(
     5,
     "Forecast Horizon (bars)",
     minval = 1,
     maxval = 20,
     group = grpP,
     tooltip = "Number of future bars projected by the forecast path. This does not predict the future with certainty; it estimates the average forward movement after similar historical patterns."
)


// -------------------- Forecast Quality Inputs --------------------
grpQ = "╔═══════ Forecast Quality Filter ═══════╗"

hideCGradeForecasts = input.bool(
     false,
     "Hide C Grade Forecasts",
     group = grpQ,
     tooltip = "When enabled, weak C Grade forecasts are hidden from the chart. The dashboard can still help you understand the forecast quality, but the projected path will not be drawn for low-quality conditions."
)

aScoreMin = input.int(
     75,
     "A Grade Min Score",
     minval = 50,
     maxval = 100,
     group = grpQ,
     tooltip = "Minimum quality score required for an A Grade forecast. A higher value makes A Grade signals stricter and less frequent."
)

bScoreMin = input.int(
     55,
     "B Grade Min Score",
     minval = 30,
     maxval = 90,
     group = grpQ,
     tooltip = "Minimum quality score required for a B Grade forecast. Forecasts below this level are classified as C Grade."
)

strongProb = input.float(
     65.0,
     "Strong Direction Probability %",
     minval = 50,
     maxval = 95,
     step = 0.5,
     group = grpQ,
     tooltip = "Directional probability threshold used for the highest probability score. Example: if most matched historical patterns moved in the same direction, the forecast receives a stronger probability score."
)

goodProb = input.float(
     55.0,
     "Good Direction Probability %",
     minval = 50,
     maxval = 90,
     step = 0.5,
     group = grpQ,
     tooltip = "Secondary probability threshold used for moderate forecast quality. Values above 50% show directional bias, but they should not be treated as guaranteed predictions."
)

goodNormDist = input.float(
     0.060,
     "Good Normalized Distance",
     minval = 0.001,
     maxval = 0.300,
     step = 0.001,
     group = grpQ,
     tooltip = "Strict similarity threshold for historical pattern matching. Lower distance means the current pattern is closer to the selected historical examples."
)

mediumNormDist = input.float(
     0.100,
     "Medium Normalized Distance",
     minval = 0.001,
     maxval = 0.500,
     step = 0.001,
     group = grpQ,
     tooltip = "Moderate similarity threshold. If the normalized distance is below this value, the match quality is considered acceptable but not as strong as the Good threshold."
)

goodBand = input.float(
     12.0,
     "Good ±1σ Band %",
     minval = 0.1,
     maxval = 50.0,
     step = 0.5,
     group = grpQ,
     tooltip = "Strict uncertainty threshold for the one-standard-deviation forecast band. A smaller band means historical outcomes were more clustered and less dispersed."
)

mediumBand = input.float(
     25.0,
     "Medium ±1σ Band %",
     minval = 0.1,
     maxval = 80.0,
     step = 0.5,
     group = grpQ,
     tooltip = "Moderate uncertainty threshold for the forecast band. Wider bands indicate more uncertainty and reduce the forecast quality score."
)


// -------------------- Display Inputs --------------------
grpD = "╔═══════ Display ═══════╗"

showProjection = input.bool(
     true,
     "Show Forecast Path",
     group = grpD,
     tooltip = "Shows or hides the main projected forecast path on the chart. The path represents the average forward movement of the closest historical matches."
)

forecastWidth = input.int(
     3,
     "Forecast Path Width",
     minval = 1,
     maxval = 5,
     group = grpD,
     tooltip = "Line thickness for the main forecast path. Increase this value if the forecast line is difficult to see on your chart."
)

showBands = input.bool(
     true,
     "Show ±1σ Confidence Band",
     group = grpD,
     tooltip = "Shows or hides the upper and lower one-standard-deviation forecast bands. These bands represent uncertainty around the projected path, not guaranteed support or resistance."
)

bandColor = input.color(
     color.new(#607D8B, 35),
     "Band Color",
     group = grpD,
     tooltip = "Color of the ±1σ forecast bands. The default color is designed to be visible on both light and dark chart backgrounds."
)

bandWidth = input.int(
     2,
     "Band Line Width",
     minval = 1,
     maxval = 4,
     group = grpD,
     tooltip = "Line thickness for the ±1σ forecast bands. Increase this value if the band lines appear too light or hard to read."
)

bandStyleInput = input.string(
     "Dashed",
     "Band Line Style",
     options = ["Solid", "Dashed", "Dotted"],
     group = grpD,
     tooltip = "Line style for the ±1σ forecast bands. Solid is the clearest, Dashed is balanced, and Dotted is the lightest visual option."
)

upColor = input.color(
     color.new(#26a69a, 0),
     "Up Forecast Color",
     group = grpD,
     tooltip = "Color used when the projected forecast direction is bullish."
)

dnColor = input.color(
     color.new(#ef5350, 0),
     "Down Forecast Color",
     group = grpD,
     tooltip = "Color used when the projected forecast direction is bearish."
)

bandStyle =
     bandStyleInput == "Solid"  ? line.style_solid :
     bandStyleInput == "Dotted" ? line.style_dotted :
                                  line.style_dashed


// -------------------- Dashboard Inputs --------------------
grpT = "╔═══════ Dashboard Table ═══════╗"

showTable = input.bool(
     true,
     "Show Dashboard Table",
     group = grpT,
     tooltip = "Shows or hides the forecast dashboard. The dashboard summarizes direction, grade, score, probabilities, projected move, uncertainty band, distance, and match count."
)

tablePosInput = input.string(
     "Top Right",
     "Table Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"],
     group = grpT,
     tooltip = "Controls where the dashboard appears on the chart."
)

tableSizeInput = input.string(
     "Small",
     "Table Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group = grpT,
     tooltip = "Controls the text size inside the dashboard. Use Tiny or Small for crowded charts, and Normal or Large for easier reading."
)

tableBgColor = input.color(
     color.new(color.black, 10),
     "Table Background",
     group = grpT,
     tooltip = "Background color of the dashboard rows."
)

tableTextColor = input.color(
     color.white,
     "Table Text Color",
     group = grpT,
     tooltip = "Text color used inside the dashboard."
)

tableBorderColor = input.color(
     color.new(color.gray, 40),
     "Table Border Color",
     group = grpT,
     tooltip = "Border color of the dashboard table."
)


// -------------------- Table Helpers --------------------
getTablePos(posText) =>
    posText == "Top Right"     ? position.top_right :
     posText == "Top Left"     ? position.top_left :
     posText == "Bottom Right" ? position.bottom_right :
     posText == "Bottom Left"  ? position.bottom_left :
     posText == "Middle Right" ? position.middle_right :
                                 position.middle_left

getTextSize(sizeText) =>
    sizeText == "Tiny"   ? size.tiny :
     sizeText == "Small" ? size.small :
     sizeText == "Large" ? size.large :
                           size.normal


// -------------------- Pattern Helpers --------------------
buildPattern(offset) =>
    arr = array.new<float>(patternLen)

    for i = 0 to patternLen - 1
        c1 = close[offset + i]
        c2 = close[offset + i + 1]
        v  = (na(c1) or na(c2) or c2 == 0.0) ? na : math.log(c1 / c2)
        array.set(arr, i, v)

    arr

euclid(a, b) =>
    s = 0.0
    bad = false
    n = array.size(a)

    for i = 0 to n - 1
        x = array.get(a, i)
        y = array.get(b, i)

        if na(x) or na(y)
            bad := true
            break

        d = x - y
        s += d * d

    bad ? na : math.sqrt(s)


// -------------------- Quality Score Helper --------------------
calcScore(dirProb, normDist, sdPct) =>
    probScore =
         dirProb >= strongProb ? 40 :
         dirProb >= goodProb   ? 25 :
         dirProb >= 50         ? 10 :
                                  0

    distScore =
         normDist <= goodNormDist   ? 35 :
         normDist <= mediumNormDist ? 20 :
         normDist <= mediumNormDist * 1.5 ? 10 :
                                             0

    bandScore =
         sdPct <= goodBand   ? 25 :
         sdPct <= mediumBand ? 15 :
         sdPct <= mediumBand * 1.5 ? 5 :
                                      0

    probScore + distScore + bandScore


// -------------------- Drawing Handles --------------------
var array<line> fLines = array.new<line>()
var array<line> uLines = array.new<line>()
var array<line> dLines = array.new<line>()

var table dashTbl = table.new(getTablePos(tablePosInput), 2, 11, border_width = 1, border_color = tableBorderColor)


// -------------------- Clear Helpers --------------------
clearLines(arr) =>
    sz = array.size(arr)

    if sz > 0
        for i = 0 to sz - 1
            line.delete(array.get(arr, i))

        array.clear(arr)

clearDashboard() =>
    txtSize = getTextSize(tableSizeInput)

    for r = 0 to 10
        table.cell(dashTbl, 0, r, "", text_color = tableTextColor, bgcolor = color.new(color.black, 100), text_size = txtSize)
        table.cell(dashTbl, 1, r, "", text_color = tableTextColor, bgcolor = color.new(color.black, 100), text_size = txtSize)

setDashRow(row, leftTxt, rightTxt, bg) =>
    txtSize = getTextSize(tableSizeInput)

    table.cell(dashTbl, 0, row, leftTxt, text_color = tableTextColor, bgcolor = bg, text_size = txtSize)
    table.cell(dashTbl, 1, row, rightTxt, text_color = tableTextColor, bgcolor = bg, text_size = txtSize)


// -------------------- Main Logic --------------------
if barstate.islast
    clearLines(fLines)
    clearLines(uLines)
    clearLines(dLines)

    if showTable
        clearDashboard()

    cur = buildPattern(1)

    minStart = patternLen + forecastLen + 2
    maxStart = math.min(lookback, bar_index - patternLen - 1)

    offsets = array.new<int>()
    dists   = array.new<float>()

    if maxStart >= minStart
        for offset = minStart to maxStart
            cand = buildPattern(offset)
            d    = euclid(cur, cand)

            if not na(d)
                array.push(offsets, offset)
                array.push(dists, d)

    n = array.size(dists)

    if n >= kNeighbors
        sorted = array.copy(dists)
        array.sort(sorted, order.ascending)

        thresh = array.get(sorted, kNeighbors - 1)

        sumFwd   = array.new<float>(forecastLen, 0.0)
        sumSqFwd = array.new<float>(forecastLen, 0.0)

        posLast = 0
        matched = 0
        sumDist = 0.0

        for i = 0 to n - 1
            d = array.get(dists, i)

            if d <= thresh and matched < kNeighbors
                off = array.get(offsets, i)

                for h = 0 to forecastLen - 1
                    fwd = math.log(close[off - 1 - h] / close[off])
                    array.set(sumFwd, h, array.get(sumFwd, h) + fwd)
                    array.set(sumSqFwd, h, array.get(sumSqFwd, h) + fwd * fwd)

                fwdLast = math.log(close[off - forecastLen] / close[off])

                if fwdLast > 0
                    posLast += 1

                sumDist += d
                matched += 1

        if matched > 0
            means = array.new<float>(forecastLen)
            stds  = array.new<float>(forecastLen)

            for h = 0 to forecastLen - 1
                m = array.get(sumFwd, h) / matched
                v = array.get(sumSqFwd, h) / matched - m * m

                array.set(means, h, m)
                array.set(stds, h, math.sqrt(math.max(v, 0.0)))

            anchor    = close[1]
            anchorX   = bar_index - 1
            finalMean = array.get(means, forecastLen - 1)
            lastSd    = array.get(stds, forecastLen - 1)

            projPct  = (math.exp(finalMean) - 1) * 100
            sdPct    = (math.exp(lastSd) - 1) * 100
            upProb   = posLast / matched * 100
            downProb = 100.0 - upProb
            avgD     = sumDist / matched

            normDist = avgD / math.sqrt(patternLen)

            direction = finalMean > 0 ? "Bullish" : finalMean < 0 ? "Bearish" : "Neutral"
            dirProb   = finalMean >= 0 ? upProb : downProb

            score = calcScore(dirProb, normDist, sdPct)

            grade =
                 score >= aScoreMin ? "A Grade" :
                 score >= bScoreMin ? "B Grade" :
                                      "C Grade"

            isWeak = grade == "C Grade"

            status =
                 grade == "A Grade" ? "Strong Setup" :
                 grade == "B Grade" ? "Moderate Setup" :
                                      "Weak / Noisy"

            mainCol = finalMean >= 0 ? upColor : dnColor

            drawForecast = showProjection and (not hideCGradeForecasts or not isWeak)

            if drawForecast
                prevP = anchor
                prevU = anchor
                prevD = anchor

                for h = 0 to forecastLen - 1
                    m  = array.get(means, h)
                    sd = array.get(stds, h)

                    projP = anchor * math.exp(m)
                    upP   = anchor * math.exp(m + sd)
                    dnP   = anchor * math.exp(m - sd)

                    x1 = anchorX + h
                    x2 = anchorX + h + 1

                    array.push(fLines, line.new(x1, prevP, x2, projP,
                         color = mainCol,
                         width = forecastWidth,
                         style = line.style_solid))

                    if showBands
                        array.push(uLines, line.new(x1, prevU, x2, upP,
                             color = bandColor,
                             width = bandWidth,
                             style = bandStyle))

                        array.push(dLines, line.new(x1, prevD, x2, dnP,
                             color = bandColor,
                             width = bandWidth,
                             style = bandStyle))

                    prevP := projP
                    prevU := upP
                    prevD := dnP

            if showTable
                headerBg = finalMean >= 0 ? color.new(#26a69a, 20) : color.new(#ef5350, 20)

                gradeBg =
                     grade == "A Grade" ? color.new(#26a69a, 15) :
                     grade == "B Grade" ? color.new(#ffb300, 15) :
                                          color.new(#ef5350, 15)

                rowBg = tableBgColor

                setDashRow(0, "K-NN Forecast", "Dashboard", headerBg)
                setDashRow(1, "Direction", direction, rowBg)
                setDashRow(2, "Grade", grade, gradeBg)
                setDashRow(3, "Score", str.tostring(score) + " / 100", rowBg)
                setDashRow(4, "Status", status, rowBg)
                setDashRow(5, "Projected Move", str.tostring(projPct, "+0.00;-0.00") + "%", rowBg)
                setDashRow(6, "P(up)", str.tostring(upProb, "0.0") + "%", rowBg)
                setDashRow(7, "P(down)", str.tostring(downProb, "0.0") + "%", rowBg)
                setDashRow(8, "±1σ Band", str.tostring(sdPct, "0.00") + "%", rowBg)
                setDashRow(9, "Norm Distance", str.tostring(normDist, "#.######"), rowBg)
                setDashRow(10, "Matches", str.tostring(matched) + " / " + str.tostring(kNeighbors), rowBg)

    else
        if showTable
            setDashRow(0, "K-NN Forecast", "Dashboard", color.new(color.gray, 40))
            setDashRow(1, "Status", "Not enough data", tableBgColor)
            setDashRow(2, "Required", "More history", tableBgColor)
            setDashRow(3, "Matches", str.tostring(n) + " / " + str.tostring(kNeighbors), tableBgColor)
            setDashRow(4, "Action", "Increase chart history", tableBgColor)
            setDashRow(5, "", "", tableBgColor)
            setDashRow(6, "", "", tableBgColor)
            setDashRow(7, "", "", tableBgColor)
            setDashRow(8, "", "", tableBgColor)
            setDashRow(9, "", "", tableBgColor)
            setDashRow(10, "", "", tableBgColor)
````
