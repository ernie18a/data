# Polynomial Regression Channel [SMRT Algo]

- url: https://www.tradingview.com/script/4jOIhNhi-Polynomial-Regression-Channel-SMRT-Algo/
- type: indicator
- pine_id: PUB;96e9bfb62abc455ab91fd08ce08aa1bc
- version: 1.0

## Description

Polynomial Regression Channel [SMRT Algo] is a free, open-source chart overlay that combines a rolling polynomial regression centerline, two channel-width measures, momentum-based candle colors, and two-candle reversal markers.

The centerline provides a fitted price reference, the bands show how price is positioned around that reference, and the candle gradient adds momentum context. Reversal markers highlight specific candle patterns after an excursion beyond a deviation band. Each component answers a different question without requiring a separate indicator pane.

[image]https://www.tradingview.com/x/jsABCYb9/[/image]

[b]Key Features[/b]

[list]
[*][b]Rolling polynomial regression:[/b] Choose linear, quadratic, or cubic fitting to adjust the model's flexibility.
[*][b]Two channel measures:[/b] Compare closing-price dispersion with a custom RMS measure built from historical closes and shifted regression estimates.
[*][b]Momentum candle gradient:[/b] Visualize changes in the regression centerline relative to ATR.
[*][b]Two-candle reversal markers:[/b] Identify an opposite-direction candle following a qualifying band excursion.
[*][b]Flexible presentation:[/b] Configure the centerline, band layers, candle coloring, markers, and color palette.
[/list]

[b]1. The Regression Centerline[/b]

On each bar, the indicator fits a polynomial to a window of closing prices and plots the fitted value at that window's most recent endpoint. The connected endpoint values form the centerline you see on the chart.

[list]
[*][b]Degree 1 — Linear:[/b] Fits a straight-line model within each calculation window.
[*][b]Degree 2 — Quadratic:[/b] Allows curvature within the fitted model.
[*][b]Degree 3 — Cubic:[/b] Allows more complex curvature and can respond more sharply to local price changes.
[/list]

Even Degree 1 can produce a bending plotted centerline because the fitted endpoint is recalculated as the window advances. The indicator does not project the fitted curve into future bars.

The default Lookback Period of 20 uses 21 closing prices, including both endpoints. Starting Bar Offset moves the regression's source window into the past; it does not move the plotted line backward on the chart.

[b]2. Understanding the Channel[/b]

Both band systems are centered on the regression endpoint and scaled by Band Multiplier.

[b]Deviation Bands[/b]
The upper and lower deviation bands use the standard deviation of the latest Lookback Period + 1 closing prices. They provide a reference for recent price dispersion around the regression centerline.

[b]Regression Bands[/b]
The layer labeled Regression Bands uses a custom root-mean-square calculation that compares historical closes with regression endpoints from successively shifted historical windows. This is not the conventional residual standard deviation of one fitted polynomial. These boundaries are transparent and are primarily represented through the shaded regions between the two band systems.

Neither band system is a statistical confidence interval. The deviation bands are not necessarily the outermost boundaries, and a band touch does not establish that price must reverse. Starting Bar Offset affects the regression calculations, while the price-deviation width continues to use the latest closes.

[b]3. Centerline Color and Candle Momentum[/b]

The centerline color uses its one-bar change normalized by 0.1 × ATR(14), with Trend Sensitivity defining the neutral threshold. In this version, the mapping is inverse: a sufficiently falling centerline uses the selected bullish color, a sufficiently rising centerline uses the bearish color, and values within the threshold use the neutral color.

Candle coloring uses a separate calculation: the change in the centerline over Momentum Period, divided by ATR(14), scaled by Gradient Sensitivity, and limited to a range of −1 to +1.

[list]
[*]Positive momentum moves candle colors toward the bullish color.
[*]Negative momentum moves candle colors toward the bearish color.
[*]Values near zero use the midpoint blend between those two colors. The Neutral Color setting applies to the centerline, not this candle gradient.
[/list]

Higher Gradient Sensitivity values require a larger ATR-normalized move to reach full color intensity. Candle colors describe regression momentum and can differ from each candle's actual open-to-close direction.

[b]4. Two-Candle Reversal Markers[/b]

The markers use the deviation bands and actual candle prices—not the momentum colors or centerline color.

[list]
[*][b]Bearish ▼:[/b] The previous candle's high exceeds its upper deviation band and that candle closes above its open. The current candle then closes below its open.
[*][b]Bullish ▲:[/b] The previous candle's low falls below its lower deviation band and that candle closes below its open. The current candle then closes above its open.
[/list]

The first candle only needs to trade beyond its band; it does not need to close beyond it. The second candle does not have to close back inside the channel, engulf the previous candle, or break its high or low. Doji candles do not satisfy the required directional conditions.

[image]https://www.tradingview.com/x/3J6alt38/[/image]

In this example, a bearish marker is followed by a brief decline and then a rise. The annotation demonstrates the pattern's conditions rather than a guaranteed change in direction. Read each candle's open and close when checking the rule, because momentum coloring can obscure its usual bullish or bearish appearance.

[b]Settings Guide[/b]

[list]
[*][b]Lookback Period — default 20:[/b] Sets the regression window and price-deviation calculation to the selected value plus one observations. Longer windows use more history and require more computation.
[*][b]Polynomial Degree — default 2:[/b] Selects Degree 1, 2, or 3. Keep Lookback Period at least as large as the degree so the fit has enough observations.
[*][b]Starting Bar Offset — default 0:[/b] Selects how many bars ago the regression source window ends.
[*][b]Band Multiplier — default 2.0:[/b] Scales both channel widths. Higher values widen the bands; zero collapses them to the centerline.
[*][b]Trend Sensitivity — default 0.01:[/b] Sets the threshold used for centerline coloring. With nonnegative values, a higher threshold creates a wider neutral range.
[*][b]Momentum Period — default 14:[/b] Sets the interval over which centerline change is measured for candle coloring.
[*][b]Gradient Sensitivity — default 5.0:[/b] Controls the momentum magnitude needed for full color saturation.
[*][b]Display Settings:[/b] Toggle the centerline, regression-band layer, deviation bands, momentum candles, and reversal markers. Show Band Fills controls the primary translucent fills; the additional gradient fills remain active while both band layers are enabled.
[*][b]Color Settings:[/b] Customize bullish, bearish, and neutral colors.
[/list]

[b]Calculation Behavior and Limitations[/b]

The indicator uses the current chart's price data without higher-timeframe requests or future-bar references. It plots a rolling endpoint series rather than redrawing one newly fitted curve across earlier candles.

Values on the open bar can change as price updates. A reversal marker may appear or disappear before that bar closes, so evaluate completed patterns after the close. Changes to settings or the underlying price data can also alter historical results.

Higher polynomial degrees can react strongly to local price changes. The custom regression-band calculation requires additional historical data and can become computationally expensive at long lookbacks. Allow sufficient history for the selected window and offset.

This is an analytical indicator, not a trading strategy. It includes no built-in alert conditions, automated orders, stop-loss or take-profit rules, or performance backtest.

[i]Free and open source for inspection and learning. The model describes historical price behavior; it does not guarantee future direction or trading results.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SMRTAlgo

//@version=6
indicator("Polynomial Regression Channel [SMRT Algo]", overlay=true)


string GROUP_REG = "01. Regression Settings"
int bars_back = input.int(20, "Lookback Period", minval=2, maxval=500, group=GROUP_REG)
int m         = input.int(2, "Polynomial Degree", minval=1, maxval=3, group=GROUP_REG)
int i         = input.int(0, "Starting Bar Offset", minval=0, maxval=500, group=GROUP_REG)


string GROUP_CHANNEL = "02. Channel Settings"
float kstd = input.float(2.0, "Band Multiplier", minval=0.0, step=0.1, group=GROUP_CHANNEL)


string GROUP_TREND = "03. Trend Settings"
float trendThreshold = input.float(0.01, "Trend Sensitivity", step=0.01, group=GROUP_TREND)


string GROUP_MOM = "04. Momentum Settings"
int momentumPeriod = input.int(14, "Momentum Period", minval=1, group=GROUP_MOM)
float gradientSensitivity = input.float(5.0, "Gradient Sensitivity", minval=0.1, step=0.1, group=GROUP_MOM)


string GROUP_COLOR = "05. Color Settings"
color bullishColor = input.color(color.new(#0DF1C6, 0), "Bullish Color", group=GROUP_COLOR, inline="bull")
color bearishColor = input.color(color.new(#E91E63, 0), "Bearish Color", group=GROUP_COLOR, inline="bear")
color neutralColor = input.color(color.new(color.gray, 0), "Neutral Color", group=GROUP_COLOR)


string GROUP_DISPLAY = "06. Display Settings"
bool showCenter = input.bool(true, "Show Center Line", group=GROUP_DISPLAY)
bool showRegBands = input.bool(true, "Show Regression Bands", group=GROUP_DISPLAY)
bool showStdBands = input.bool(true, "Show Deviation Bands", group=GROUP_DISPLAY)
bool showMomentumBars = input.bool(true, "Color Price Bars by Momentum", group=GROUP_DISPLAY)
bool showReversals = input.bool(true, "Show Reversal Signals", group=GROUP_DISPLAY)
bool showBandFills = input.bool(true, "Show Band Fills", group=GROUP_DISPLAY)

f_cog(int length, int degree, int offset) =>
    float result = na
    int size = degree + 1

    if bar_index >= length + offset
        matrix<float> a = matrix.new<float>(size, size, 0.0)
        array<float> b = array.new_float(size, 0.0)

        // Build normal equations.
        for r = 0 to degree
            for c = 0 to degree
                float s = 0.0
                for j = 0 to length
                    s += math.pow(j, r + c)
                matrix.set(a, r, c, s)

            float sb = 0.0
            for j = 0 to length
                float y = close[length + offset - j]
                sb += y * math.pow(j, r)
            array.set(b, r, sb)

        bool valid = true

        // Gaussian elimination with partial pivoting.
        for col = 0 to degree
            int pivot = col
            float maxval = math.abs(matrix.get(a, col, col))

            if col < degree
                for r = col + 1 to degree
                    if r < size
                        float v = math.abs(matrix.get(a, r, col))
                        if v > maxval
                            maxval := v
                            pivot := r

            if maxval < 1e-12
                valid := false
            else
                if pivot != col
                    for c = 0 to degree
                        float temp = matrix.get(a, col, c)
                        matrix.set(a, col, c, matrix.get(a, pivot, c))
                        matrix.set(a, pivot, c, temp)

                    float tempb = array.get(b, col)
                    array.set(b, col, array.get(b, pivot))
                    array.set(b, pivot, tempb)

                float divisor = matrix.get(a, col, col)

                for c = col to degree
                    matrix.set(a, col, c, matrix.get(a, col, c) / divisor)
                array.set(b, col, array.get(b, col) / divisor)

                for r = 0 to degree
                    if r != col
                        float factor = matrix.get(a, r, col)
                        for c = col to degree
                            matrix.set(a, r, c, matrix.get(a, r, c) - factor * matrix.get(a, col, c))
                        array.set(b, r, array.get(b, r) - factor * array.get(b, col))

        if valid
            result := 0.0
            for r = 0 to degree
                result += array.get(b, r) * math.pow(length, r)

    result

f_residual_std(int length, int degree, int offset) =>
    float result = na
    float total = 0.0
    bool valid = true

    for j = 0 to length
        float fit = f_cog(length, degree, offset + j)
        if na(fit)
            valid := false
        else
            total += math.pow(close[length + offset - j] - fit, 2)

    if valid
        result := math.sqrt(total / (length + 1)) * kstd

    result

float cog = f_cog(bars_back, m, i)
float residualStd = f_residual_std(bars_back, m, i)
float priceStd = ta.stdev(close, bars_back + 1) * kstd

float upperReg = cog + residualStd
float lowerReg = cog - residualStd
float upperStd = cog + priceStd
float lowerStd = cog - priceStd

float atrBase = ta.atr(14)
float base = not na(cog[1]) and atrBase > 0 ? (cog - cog[1]) / (0.1 * atrBase) : 0.0

bool baseUp = base < -trendThreshold
bool baseDown = base > trendThreshold

float momentumValue = not na(cog[momentumPeriod]) and atrBase > 0 ? (cog - cog[momentumPeriod]) / atrBase : 0.0
float normalizedMomentum = math.max(-1.0, math.min(1.0, momentumValue / gradientSensitivity))

color momentumBarColor = color.from_gradient(normalizedMomentum, -1.0, 1.0, bearishColor, bullishColor)
color centerColor = baseUp ? bullishColor : baseDown ? bearishColor : neutralColor

barcolor(showMomentumBars ? momentumBarColor : na)

plot(showCenter ? cog : na, "Regression Center", color=centerColor, linewidth=2)

pUpperReg = plot(showRegBands ? upperReg : na, "Regression Upper Band", color=color.new(bearishColor, 100))
pLowerReg = plot(showRegBands ? lowerReg : na, "Regression Lower Band", color=color.new(bullishColor, 100))

pUpperStd = plot(showStdBands ? upperStd : na, "Deviation Upper Band", color=bearishColor)
pLowerStd = plot(showStdBands ? lowerStd : na, "Deviation Lower Band", color=bullishColor)

// Channel fills.
fill(pUpperReg, pUpperStd, color=showBandFills and showRegBands and showStdBands ? color.new(bearishColor, 85) : na, title="Upper Channel Fill")
fill(pLowerReg, pLowerStd, color=showBandFills and showRegBands and showStdBands ? color.new(bullishColor, 85) : na, title="Lower Channel Fill")


fill(
     pUpperReg,
     pUpperStd,
     upperReg,
     upperStd / 100 * 99,
     chart.bg_color,
     color.new(bearishColor, 0),
     editable = false
)

fill(
     pLowerReg,
     pLowerStd,
     lowerReg,
     lowerStd / 100 * 104,
     chart.bg_color,
     color.new(bullishColor, 0),
     editable = false
)

bool bearishReversalSignal = high[1] > upperStd[1] and close[1] > open[1] and close < open
bool bullishReversalSignal = low[1] < lowerStd[1] and close[1] < open[1] and close > open

plotshape(showReversals and bearishReversalSignal, title="Bearish Reversal", style=shape.triangledown, location=location.abovebar, color=bearishColor, size=size.tiny)
plotshape(showReversals and bullishReversalSignal, title="Bullish Reversal", style=shape.triangleup, location=location.belowbar, color=bullishColor, size=size.tiny)
````
