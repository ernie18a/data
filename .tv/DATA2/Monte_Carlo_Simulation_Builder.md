<!-- tradingview-pine-id: PUB;38d80c75263e40a0a5ae129562cd869f -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Monte Carlo Simulation Builder

Source: https://www.tradingview.com/script/JYUzhor2-Monte-Carlo-Simulation-Builder/

## Description

Monte Carlo Simulation Introduction:
Monte Carlo simulation in the context of financial markets is an economic forecasting model that combines stochastics and probability theory to predict potential future price moves. The simulation uses price data that is already available to generate various future price paths. Once the price paths are generated, a probability distribution produces an interval containing the simulated price paths between the minimum and maximum future price returns and defines a mean price return as the most likely expected future price at the point in time defined by the time period utilized in the simulation.

Step-by-Step Guide on Applying the Monte Carlo Simulation Builder:
1.	Choose an underlying symbol and timeframe to simulate: Every symbol that operates with price bars can be simulated. However, for a sufficient simulation, there should be enough bars in the historical period. A stock that just had its IPO some hours or days ago may not have the necessary number of historical bars for a sufficient simulation.

2.	Define the Historical Bar Levels and Projected Bar Levels: For every simulation, the Historical Bar Levels and Projected Bar Levels can be chosen. A smaller amount of Historical Bar Levels would be sufficient for short-term and local trends (choosing a smaller amount of Historical Bar Levels would not be ideal for a long-term simulation). A higher amount of Historical Bar Levels would be more sufficient for middle-to-longer term analysis (Example: A 3-year simulation could be based on 10-year Historical Bar Levels).

3.	Define the Number of Simulations and Path/Curves Display: In the Monte Carlo Simulation Builder, the Number of Simulations defines how many simulations will be calculated. The Path Transparency regulates how transparent the paths will appear in the simulation. A lower Path Transparency will show the simulated price paths in a higher color density. The Path Width regulates how thick the statistical interval curves of the Monte Carlo Simulation will be displayed. The Statistical Curves displayed can also be modified, including which curves should be shown and how thick the curves should be displayed.

4.	Run the Simulation: Once the simulation is played, the visualization of the simulation defines a practical range of the most likely outcomes of the future price action considered for the underlying asset and time period. The Statistical Curves help to define possible outcomes. For example, the minimum curve can be used to calculate the maximum drawdown for the underlying period. You can efficiently modify the simulations and see if a similar range results from different assumptions.

4-Chart Split Screen Demonstration With 4 Selected Monte Carlo Simulations:
https://www.tradingview.com/x/orpDHB0j/

The Statistical Element Results Explained:
Current Price: Price from which the historical returns are calculated and from which the Monte Carlo Simulation will project the future return paths and statistical curves.

Timeframe: Current timeframe perspective for which the indicator uses the historical and predictive bar amounts. (Examples: Monthly timeframe = monthly bars used in simulation, Weekly timeframe = weekly bars used in simulation).

Historical Bar Levels = The number of historical returns represented as bars that are entered in the Monte Carlo Simulation Builder tab.

Projected Bar Levels = The number of future returns represented as bars that are projected in the Monte Carlo Simulation chart price action beginning from the current price.

Mean Return / Bar = The average historical logarithmic returns for all of the bar returns of the historical bar time period (Example: Daily average return of the historical bar time period when a daily timeframe is set).

Volatility / Bar = The historical sample standard deviation of log returns for all bars of the historical time period (Example: Total sample standard deviation of the historical weekly bars when weekly historical bar levels are set).

Historical Period Return = The actual price return of the historical period beginning set by the Historical Bar levels till the current price bar.

Maximum = Highest possible upper price return outcome implied by the Monte Carlo Simulation.
 
95th percentile = Price below which, on average, 95% of the expected upcoming price action predicted by the Monte Carlo Simulation will lie.

75th percentile = Price below which, on average, 75% of the expected upcoming price action predicted by the Monte Carlo Simulation will lie.

Mean = The most likely expected upcoming average price according to the Monte Carlo Simulation.

Median = Half of the expected upcoming prices will lie on or below this value according to the Monte Carlo Simulation.

25th percentile = Price below which, on average, 25% of the expected upcoming price action predicted by the Monte Carlo Simulation will lie.

5th percentile = Price below which, on average, 5% of the expected upcoming price action predicted by the Monte Carlo Simulation will lie.

Minimum = Lowest possible lower price return outcome implied by the Monte Carlo Simulation.

Mean Projected Return = The expected percentage return from the current price to the most likely expected upcoming average price (mean).

Probability > Current = The probability that the upcoming price return implied by the Monte Carlo Simulation will be higher than the current price.

Probability < Current = The probability that the upcoming price return implied by the Monte Carlo Simulation will be lower than the current price.

Summary
The Monte Carlo Simulation Builder is an ideal indicator to simulate future price returns by analyzing historical price returns. It helps traders and investors predict future price scenarios and set up a trading strategy that considers maximum drawdowns, average returns, and the highest possible profits based on historical price returns. By considering the probability of higher or lower prices in the future in comparison to the current underlying symbol price, traders and investors can set up their trading or investing strategy around the potential probabilities.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © VincePrince

//@version=6
indicator("Monte Carlo Simulation Builder", overlay = true, max_bars_back = 5000, max_lines_count = 50, max_labels_count = 50, max_polylines_count = 100)

string group_mc = "1. Monte Carlo Settings"
string group_display = "2. Path Display"
string group_stats = "3. Statistical Curves"

historicalBars = input.int(365, "Historical Lookback (Bar Levels)", minval = 10, maxval = 4990, step = 1, group = group_mc)
projectionBars = input.int(130, "Projection (Bar Levels)", minval = 1, maxval = 500, step = 1, group = group_mc)
simulations = input.int(5000, "Number of Simulations", minval = 100, maxval = 10000, step = 100, group = group_mc)

showPaths = input.bool(true, "Show Monte Carlo Paths", group = group_display)
pathTransparency = input.int(86, "Path Transparency", minval = 0, maxval = 100, group = group_display)
pathWidth = input.int(1, "Path Width", minval = 1, maxval = 3, group = group_display)

showMaxMin = input.bool(true, "Show Maximum / Minimum", group = group_stats)
showPercentiles = input.bool(true, "Show 95th / 5th Percentile", group = group_stats)
showMean = input.bool(true, "Show Mean", group = group_stats)
statLineWidth = input.int(4, "Statistical Curve Width", minval = 1, maxval = 6, group = group_stats)
labelMargin = input.int(2, "Label Margin From Curve End", minval = 1, maxval = 25, step = 1, group = group_stats)

int fixedDisplayedPaths = 90

var float[] historicalReturns = array.new_float()
var float[] zDistribution = array.new_float()
var polyline[] displayedPaths = array.new<polyline>()

var polyline maxCurve = na
var polyline p95Curve = na
var polyline meanCurve = na
var polyline p05Curve = na
var polyline minCurve = na

var label maxLabel = na
var label p95Label = na
var label meanLabel = na
var label p05Label = na
var label minLabel = na

var table statsTable = table.new(position.top_right, 2, 19, border_width = 1, border_color = color.white, frame_width = 1, frame_color = color.white)

percentile(float[] values, float p) =>
    int n = array.size(values)
    float result = na
    if n > 0
        float percentilePosition = p * (n - 1)
        int lowerIndex = int(math.floor(percentilePosition))
        int upperIndex = int(math.ceil(percentilePosition))
        float lowerValue = array.get(values, lowerIndex)
        float upperValue = array.get(values, upperIndex)
        float fraction = percentilePosition - lowerIndex
        result := lowerValue + (upperValue - lowerValue) * fraction
    result

normalRandom(int seedA, int seedB) =>
    float randomU1 = math.random(0.000001, 0.999999, seedA)
    float u1 = math.max(randomU1, 0.000001)
    float u2 = math.random(0.000001, 0.999999, seedB)
    float z = math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2)
    z

simulationPathColor(int number) =>
    int selector = number % 10
    color baseColor = selector == 0 ? color.blue : selector == 1 ? color.red : selector == 2 ? color.green : selector == 3 ? color.purple : selector == 4 ? color.orange : selector == 5 ? color.aqua : selector == 6 ? color.fuchsia : selector == 7 ? color.yellow : selector == 8 ? color.teal : color.lime
    color.new(baseColor, pathTransparency)

gbmPrice(float startPrice, float meanReturn, float volatility, int futureBar, float z) =>
    float logReturn = meanReturn * futureBar + volatility * math.sqrt(futureBar) * z
    float projectedPrice = startPrice * math.exp(logReturn)
    projectedPrice

if barstate.islastconfirmedhistory

    if array.size(displayedPaths) > 0
        for i = 0 to array.size(displayedPaths) - 1
            polyline.delete(array.get(displayedPaths, i))
        array.clear(displayedPaths)

    if not na(maxCurve)
        polyline.delete(maxCurve)

    if not na(p95Curve)
        polyline.delete(p95Curve)

    if not na(meanCurve)
        polyline.delete(meanCurve)

    if not na(p05Curve)
        polyline.delete(p05Curve)

    if not na(minCurve)
        polyline.delete(minCurve)

    if not na(maxLabel)
        label.delete(maxLabel)

    if not na(p95Label)
        label.delete(p95Label)

    if not na(meanLabel)
        label.delete(meanLabel)

    if not na(p05Label)
        label.delete(p05Label)

    if not na(minLabel)
        label.delete(minLabel)

    array.clear(historicalReturns)
    array.clear(zDistribution)

    int usableHistoricalBars = int(math.min(historicalBars, bar_index))

    if usableHistoricalBars > 1
        for i = 0 to usableHistoricalBars - 1
            if not na(close[i]) and not na(close[i + 1])
                float r = math.log(close[i] / close[i + 1])
                array.push(historicalReturns, r)

    int historicalCount = array.size(historicalReturns)

    float meanLogReturn = na
    float historicalVolatility = na

    if historicalCount > 1
        float returnSum = 0.0

        for i = 0 to historicalCount - 1
            returnSum += array.get(historicalReturns, i)

        meanLogReturn := returnSum / historicalCount

        float squaredDeviationSum = 0.0

        for i = 0 to historicalCount - 1
            float deviation = array.get(historicalReturns, i) - meanLogReturn
            squaredDeviationSum += deviation * deviation

        historicalVolatility := math.sqrt(squaredDeviationSum / (historicalCount - 1))

    if historicalCount >= 10 and not na(meanLogReturn) and not na(historicalVolatility)

        int anchorSeed = bar_index * 7919 + historicalBars * 101 + projectionBars * 307 + simulations * 17

        for simulation = 0 to simulations - 1
            int seedA = anchorSeed + simulation * 104729
            int seedB = anchorSeed + simulation * 130363 + 1000003
            float z = normalRandom(seedA, seedB)
            array.push(zDistribution, z)

        array.sort(zDistribution, order.ascending)

        int zCount = array.size(zDistribution)

        float zMin = array.first(zDistribution)
        float z05 = percentile(zDistribution, 0.05)
        float z25 = percentile(zDistribution, 0.25)
        float zMedian = percentile(zDistribution, 0.50)
        float z75 = percentile(zDistribution, 0.75)
        float z95 = percentile(zDistribution, 0.95)
        float zMax = array.last(zDistribution)

        int actualDisplayedPaths = showPaths ? fixedDisplayedPaths : 0

        if actualDisplayedPaths > 0
            for pathNumber = 0 to actualDisplayedPaths - 1

                array<chart.point> pathPoints = array.new<chart.point>()
                float simulatedPathPrice = close

                array.push(pathPoints, chart.point.from_index(bar_index, simulatedPathPrice))

                for futureBar = 1 to projectionBars

                    int pathSeedA = anchorSeed + pathNumber * 32452843 + futureBar * 49999
                    int pathSeedB = anchorSeed + pathNumber * 67867967 + futureBar * 65537 + 700001

                    float pathZ = normalRandom(pathSeedA, pathSeedB)
                    float stepLogReturn = meanLogReturn + historicalVolatility * pathZ

                    simulatedPathPrice := simulatedPathPrice * math.exp(stepLogReturn)

                    array.push(pathPoints, chart.point.from_index(bar_index + futureBar, simulatedPathPrice))

                polyline path = polyline.new(pathPoints, curved = false, closed = false, xloc = xloc.bar_index, line_color = simulationPathColor(pathNumber), line_width = pathWidth)

                array.push(displayedPaths, path)

        array<chart.point> maxPoints = array.new<chart.point>()
        array<chart.point> p95Points = array.new<chart.point>()
        array<chart.point> meanPoints = array.new<chart.point>()
        array<chart.point> p05Points = array.new<chart.point>()
        array<chart.point> minPoints = array.new<chart.point>()

        array.push(maxPoints, chart.point.from_index(bar_index, close))
        array.push(p95Points, chart.point.from_index(bar_index, close))
        array.push(meanPoints, chart.point.from_index(bar_index, close))
        array.push(p05Points, chart.point.from_index(bar_index, close))
        array.push(minPoints, chart.point.from_index(bar_index, close))

        float finalMaximum = na
        float finalP95 = na
        float finalP75 = na
        float finalMean = na
        float finalMedian = na
        float finalP25 = na
        float finalP05 = na
        float finalMinimum = na

        for futureBar = 1 to projectionBars

            float maxPrice = gbmPrice(close, meanLogReturn, historicalVolatility, futureBar, zMax)
            float p95Price = gbmPrice(close, meanLogReturn, historicalVolatility, futureBar, z95)
            float p75Price = gbmPrice(close, meanLogReturn, historicalVolatility, futureBar, z75)
            float medianPrice = gbmPrice(close, meanLogReturn, historicalVolatility, futureBar, zMedian)
            float p25Price = gbmPrice(close, meanLogReturn, historicalVolatility, futureBar, z25)
            float p05Price = gbmPrice(close, meanLogReturn, historicalVolatility, futureBar, z05)
            float minPrice = gbmPrice(close, meanLogReturn, historicalVolatility, futureBar, zMin)

            float meanPrice = close * math.exp((meanLogReturn + 0.5 * historicalVolatility * historicalVolatility) * futureBar)

            int futureX = bar_index + futureBar

            array.push(maxPoints, chart.point.from_index(futureX, maxPrice))
            array.push(p95Points, chart.point.from_index(futureX, p95Price))
            array.push(meanPoints, chart.point.from_index(futureX, meanPrice))
            array.push(p05Points, chart.point.from_index(futureX, p05Price))
            array.push(minPoints, chart.point.from_index(futureX, minPrice))

            if futureBar == projectionBars
                finalMaximum := maxPrice
                finalP95 := p95Price
                finalP75 := p75Price
                finalMean := meanPrice
                finalMedian := medianPrice
                finalP25 := p25Price
                finalP05 := p05Price
                finalMinimum := minPrice

        if showMaxMin
            maxCurve := polyline.new(maxPoints, curved = false, closed = false, xloc = xloc.bar_index, line_color = color.black, line_width = statLineWidth)
            minCurve := polyline.new(minPoints, curved = false, closed = false, xloc = xloc.bar_index, line_color = color.black, line_width = statLineWidth)

        if showPercentiles
            p95Curve := polyline.new(p95Points, curved = false, closed = false, xloc = xloc.bar_index, line_color = color.red, line_width = statLineWidth)
            p05Curve := polyline.new(p05Points, curved = false, closed = false, xloc = xloc.bar_index, line_color = color.red, line_width = statLineWidth)

        if showMean
            meanCurve := polyline.new(meanPoints, curved = false, closed = false, xloc = xloc.bar_index, line_color = color.blue, line_width = statLineWidth)

        int projectionEndX = bar_index + projectionBars
        int remainingFutureBars = math.max(0, 500 - projectionBars)
        int effectiveMargin = math.min(labelMargin, remainingFutureBars)
        int labelX = projectionEndX + effectiveMargin

        color invisibleBackground = color.new(color.white, 100)

        if showMaxMin
            maxLabel := label.new(labelX, finalMaximum, "Max.  " + str.tostring(finalMaximum, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = invisibleBackground, textcolor = color.black, size = size.normal, textalign = text.align_left)

            minLabel := label.new(labelX, finalMinimum, "Min.  " + str.tostring(finalMinimum, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = invisibleBackground, textcolor = color.black, size = size.normal, textalign = text.align_left)

        if showPercentiles
            p95Label := label.new(labelX, finalP95, "95th  " + str.tostring(finalP95, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = invisibleBackground, textcolor = color.black, size = size.normal, textalign = text.align_left)

            p05Label := label.new(labelX, finalP05, "5th  " + str.tostring(finalP05, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = invisibleBackground, textcolor = color.black, size = size.normal, textalign = text.align_left)

        if showMean
            meanLabel := label.new(labelX, finalMean, "Mean  " + str.tostring(finalMean, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = invisibleBackground, textcolor = color.black, size = size.normal, textalign = text.align_left)

        float probabilityAbove = na
        float probabilityBelow = na

        if historicalVolatility > 0

            float breakEvenZ = (-meanLogReturn * projectionBars) / (historicalVolatility * math.sqrt(projectionBars))

            int aboveCount = 0
            int belowCount = 0

            for i = 0 to zCount - 1
                float z = array.get(zDistribution, i)

                if z > breakEvenZ
                    aboveCount += 1
                else
                    belowCount += 1

            probabilityAbove := 100.0 * aboveCount / zCount
            probabilityBelow := 100.0 * belowCount / zCount

        float meanProjectedReturn = (finalMean / close - 1.0) * 100.0

        float historicalTotalReturn = na

        if not na(close[usableHistoricalBars])
            historicalTotalReturn := (close / close[usableHistoricalBars] - 1.0) * 100.0

        color tableHeaderColor = color.rgb(0, 0, 0)
        color tableBodyColor = color.rgb(65, 110, 180)
        color tableTextColor = color.white

        table.clear(statsTable, 0, 0, 1, 18)

        table.cell(statsTable, 0, 0, "Simulation Element", text_color = tableTextColor, bgcolor = tableHeaderColor, text_size = size.small, text_halign = text.align_left)
        table.cell(statsTable, 1, 0, "Value", text_color = tableTextColor, bgcolor = tableHeaderColor, text_size = size.small, text_halign = text.align_left)

        table.cell(statsTable, 0, 1, "Current Price:", text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)
        table.cell(statsTable, 1, 1, str.tostring(close, format.mintick), text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)

        table.cell(statsTable, 0, 2, "Timeframe:", text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)
        table.cell(statsTable, 1, 2, timeframe.period, text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)

        table.cell(statsTable, 0, 3, "Historical Bar Levels:", text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)
        table.cell(statsTable, 1, 3, str.tostring(historicalCount), text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)

        table.cell(statsTable, 0, 4, "Projected Bar Levels:", text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)
        table.cell(statsTable, 1, 4, str.tostring(projectionBars), text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)

        table.cell(statsTable, 0, 5, "Mean Return / Bar:", text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)
        table.cell(statsTable, 1, 5, str.tostring(meanLogReturn * 100.0, "#.##") + "%", text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)

        table.cell(statsTable, 0, 6, "Volatility / Bar:", text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)
        table.cell(statsTable, 1, 6, str.tostring(historicalVolatility * 100.0, "#.##") + "%", text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)

        table.cell(statsTable, 0, 7, "Historical Period Return:", text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)
        table.cell(statsTable, 1, 7, str.tostring(historicalTotalReturn, "#.##") + "%", text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)

        table.cell(statsTable, 0, 8, "Maximum:", text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)
        table.cell(statsTable, 1, 8, str.tostring(finalMaximum, format.mintick), text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)

        table.cell(statsTable, 0, 9, "95th Percentile:", text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)
        table.cell(statsTable, 1, 9, str.tostring(finalP95, format.mintick), text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)

        table.cell(statsTable, 0, 10, "75th Percentile:", text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)
        table.cell(statsTable, 1, 10, str.tostring(finalP75, format.mintick), text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)

        table.cell(statsTable, 0, 11, "Mean:", text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)
        table.cell(statsTable, 1, 11, str.tostring(finalMean, format.mintick), text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)

        table.cell(statsTable, 0, 12, "Median:", text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)
        table.cell(statsTable, 1, 12, str.tostring(finalMedian, format.mintick), text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)

        table.cell(statsTable, 0, 13, "25th Percentile:", text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)
        table.cell(statsTable, 1, 13, str.tostring(finalP25, format.mintick), text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)

        table.cell(statsTable, 0, 14, "5th Percentile:", text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)
        table.cell(statsTable, 1, 14, str.tostring(finalP05, format.mintick), text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)

        table.cell(statsTable, 0, 15, "Minimum:", text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)
        table.cell(statsTable, 1, 15, str.tostring(finalMinimum, format.mintick), text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)

        table.cell(statsTable, 0, 16, "Mean Projected Return:", text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)
        table.cell(statsTable, 1, 16, str.tostring(meanProjectedReturn, "#.##") + "%", text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)

        table.cell(statsTable, 0, 17, "Probability > Current:", text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)
        table.cell(statsTable, 1, 17, str.tostring(probabilityAbove, "#.##") + "%", text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)

        table.cell(statsTable, 0, 18, "Probability < Current:", text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)
        table.cell(statsTable, 1, 18, str.tostring(probabilityBelow, "#.##") + "%", text_color = tableTextColor, bgcolor = tableBodyColor, text_size = size.small, text_halign = text.align_left)
````
