# SSA & Trend - Post Normalized

- url: https://www.tradingview.com/script/zTKaRvSQ/
- type: indicator
- pine_id: PUB;2e97935e68fc49e6bc7fa6d323a90d72
- version: 1.0

## Description

## SSA Trend with Post-Normalization

This indicator is a modified version of **“End-Pointed SSA of Normalized Price Corridor [Loxx]”** and is based on the original work by Loxx.

The main difference lies in the order of the SSA calculation and normalization.
In the original implementation, the input price is normalized first:
`normalized = (source - ma) / dev`
SSA is then applied to the normalized price series.

However, this normalization method may sometimes produce a misleading trend signal. Even when the actual price is rising, the normalized value may decline if the moving average (`ma`) and standard deviation (`dev`) increase faster than the price itself. As a result, SSA applied to the normalized series may indicate a downward trend while the underlying price trend is still upward.

To reduce this distortion, this version changes the calculation order:
1. Apply SSA directly to the original price series.
2. Reconstruct the smoothed SSA trend.
3. Normalize the reconstructed SSA trend afterward.

In other words:
**Original approach:**
`Price → Normalize → SSA → Trend`
**This version:**
`Price → SSA → Trend → Normalize`
By performing normalization after SSA reconstruction, the indicator aims to preserve the direction of the underlying price trend while still providing a standardized oscillator that can be compared across different markets, price levels, and volatility conditions.

The normalized SSA output can be used to identify:
* The direction of the smoothed trend
* Trend reversals and turning points
* Overextended upward or downward movements
* Momentum weakening after a strong price move
* Potential entry and exit signals based on threshold crossings and trend-color changes
Special thanks to **Loxx** for the original open-source indicator and SSA implementation.
This indicator is intended for research and analytical purposes only and does not constitute financial advice.

## Source Code

````pine
//@version=6
indicator("SSA & Trend - Post Normalized", shorttitle="SSA Post-Norm", overlay=false, max_bars_back=2000)

// The calculation order in this indicator is intentional:
// 1. Run SSA on the original source.
// 2. Build the trend from the previous SSA endpoint.
// 3. Normalize the completed SSA and trend series.

string GROUP_SSA = "SSA Settings"
string GROUP_NORM = "Normalization"
string GROUP_VIEW = "Display"

sourceInput = input.source(close, "Source", group=GROUP_SSA)
lag = input.int(10, "Lag", minval=2, maxval=200, group=GROUP_SSA)
ncomp = input.int(2, "Components", minval=1, maxval=25, group=GROUP_SSA)
numbars = input.int(330, "SSA Window", minval=20, maxval=1000, group=GROUP_SSA)
backbars = input.int(400, "Bars To Calculate", minval=50, maxval=1500, group=GROUP_SSA,
     tooltip="Limits the expensive SSA calculation to the latest bars.")

normPeriod = input.int(50, "Normalization Period", minval=2, group=GROUP_NORM)
sigmaScale = input.float(3.0, "Standard Deviation Scale", minval=0.1, step=0.1, group=GROUP_NORM,
     tooltip="3.0 means (value - mean) / (3 × standard deviation).")

showRaw = input.bool(false, "Show Raw Values In Data Window", group=GROUP_VIEW)
showSignals = input.bool(true, "Show Cross Signals", group=GROUP_VIEW)
colorBars = input.bool(false, "Color Price Bars", group=GROUP_VIEW)

int MAX_NCOMP = 25
int MAX_LAG = 200
int MAX_ARRAY_LENGTH = 1000

fastSingular(array<float> _series, int _lag, int _ncomp) =>
    int n = math.min(array.size(_series), MAX_ARRAY_LENGTH)
    int l = math.max(2, math.min(_lag, math.min(MAX_LAG, n - 1)))
    // TradingView matrices are limited to 100,000 elements.
    while l * (n - l + 1) > 100000 and l > 2
        l -= 1
    int s = math.max(1, math.min(_ncomp, math.min(MAX_NCOMP, l)))
    int k = n - l + 1

    matrix<float> trajectory = matrix.new<float>(l, k, 0.0)
    for i = 0 to l - 1
        for j = 0 to k - 1
            matrix.set(trajectory, i, j, array.get(_series, i + j))

    matrix<float> covariance = matrix.new<float>(l, l, 0.0)
    for i = 0 to l - 1
        for j = 0 to l - 1
            float sum = 0.0
            for m = 0 to k - 1
                sum += matrix.get(trajectory, i, m) * matrix.get(trajectory, j, m)
            matrix.set(covariance, i, j, sum)

    // Extract the leading eigenvectors with power iteration and deflation.
    matrix<float> eigenvectors = matrix.new<float>(s, l, 0.0)
    matrix<float> work = matrix.copy(covariance)
    for component = 0 to s - 1
        array<float> vector = array.new_float(l, 1.0 / math.sqrt(l))
        for iteration = 0 to 24
            array<float> nextVector = array.new_float(l, 0.0)
            float normSquared = 0.0
            for i = 0 to l - 1
                float value = 0.0
                for j = 0 to l - 1
                    value += matrix.get(work, i, j) * array.get(vector, j)
                array.set(nextVector, i, value)
                normSquared += value * value
            float vectorNorm = math.sqrt(normSquared)
            if vectorNorm <= 1e-10
                break
            for i = 0 to l - 1
                array.set(vector, i, array.get(nextVector, i) / vectorNorm)

        float eigenvalue = 0.0
        for i = 0 to l - 1
            float rowDot = 0.0
            for j = 0 to l - 1
                rowDot += matrix.get(work, i, j) * array.get(vector, j)
            eigenvalue += array.get(vector, i) * rowDot
            matrix.set(eigenvectors, component, i, array.get(vector, i))

        for i = 0 to l - 1
            for j = 0 to l - 1
                float deflated = matrix.get(work, i, j) - eigenvalue * array.get(vector, i) * array.get(vector, j)
                matrix.set(work, i, j, deflated)

    // Reconstruct the selected components and apply diagonal averaging.
    array<float> restored = array.new_float(n, 0.0)
    array<int> counts = array.new_int(n, 0)
    for component = 0 to s - 1
        array<float> vector = array.new_float(l, 0.0)
        for i = 0 to l - 1
            array.set(vector, i, matrix.get(eigenvectors, component, i))

        array<float> projection = array.new_float(k, 0.0)
        for column = 0 to k - 1
            float dot = 0.0
            for i = 0 to l - 1
                dot += matrix.get(trajectory, i, column) * array.get(vector, i)
            array.set(projection, column, dot)

        for i = 0 to l - 1
            for j = 0 to k - 1
                int index = i + j
                float contribution = array.get(vector, i) * array.get(projection, j)
                array.set(restored, index, array.get(restored, index) + contribution)
                array.set(counts, index, array.get(counts, index) + 1)

    for i = 0 to n - 1
        int count = array.get(counts, i)
        if count > 0
            array.set(restored, i, array.get(restored, i) / count)
    restored

calcSSAEndpoint(float _source, int _window, int _lag, int _ncomp, int _calculationBars) =>
    float endpoint = na
    bool enoughHistory = bar_index >= _window - 1
    bool insideCalculationRange = last_bar_index - bar_index < _calculationBars
    if enoughHistory and insideCalculationRange
        array<float> values = array.new_float()
        // Index 0 is the current bar; later indexes are progressively older.
        for i = 0 to _window - 1
            array.push(values, _source[i])
        array<float> reconstructed = fastSingular(values, _lag, _ncomp)
        endpoint := array.size(reconstructed) > 0 ? array.get(reconstructed, 0) : na
    endpoint

postNormalize(float _series, int _period, float _sigmaScale) =>
    float mean = ta.sma(_series, _period)
    float deviation = ta.stdev(_series, _period)
    float denominator = deviation * _sigmaScale
    not na(denominator) and denominator > 1e-10 ? (_series - mean) / denominator : na

// Calculate extra history so the normalized plots are already valid at the
// beginning of the visible calculation range.
int requiredCalculationBars = backbars + normPeriod + 1
float ssaRaw = calcSSAEndpoint(sourceInput, numbars, lag, ncomp, requiredCalculationBars)
float trendRaw = ssaRaw[1]

// Post-normalization: neither sourceInput nor the SSA input window is normalized.
float ssaNormalized = postNormalize(ssaRaw, normPeriod, sigmaScale)
float trendNormalized = postNormalize(trendRaw, normPeriod, sigmaScale)

bool isReady = not na(ssaNormalized) and not na(trendNormalized)
bool isUpTrend = isReady and ssaRaw >= trendRaw
bool longSignal = ta.crossover(ssaRaw, trendRaw)
bool shortSignal = ta.crossunder(ssaRaw, trendRaw)
color trendColor = not isReady ? color.gray : isUpTrend ? color.lime : color.red

plot(ssaNormalized, "Normalized SSA", color=trendColor, linewidth=2)
// plot(trendNormalized, "Normalized Trend", color=color.new(color.orange, 10), linewidth=2)
plot(showRaw ? ssaRaw : na, "Raw SSA", color=color.new(color.blue, 100), display=display.data_window)
plot(showRaw ? trendRaw : na, "Raw Trend", color=color.new(color.gray, 100), display=display.data_window)
hline(0.0, "Zero", color=color.new(color.gray, 65))
hline(0.5, "+0.5", color=color.new(color.gray, 65))
hline(-0.5, "-0.5", color=color.new(color.gray, 65))

plotshape(showSignals and longSignal, title="Long", text="L", style=shape.triangleup,
     location=location.bottom, color=color.lime, textcolor=color.white, size=size.tiny)
plotshape(showSignals and shortSignal, title="Short", text="S", style=shape.triangledown,
     location=location.top, color=color.red, textcolor=color.white, size=size.tiny)
barcolor(colorBars and isReady ? trendColor : na)

alertcondition(longSignal, "SSA Long", "Normalized SSA crossed above its normalized trend on {{ticker}}")
alertcondition(shortSignal, "SSA Short", "Normalized SSA crossed below its normalized trend on {{ticker}}")
````
