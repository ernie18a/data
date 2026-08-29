<!-- tradingview-pine-id: PUB;50b4566eddd04de3be2a3cb031dc4ebd -->
<!-- tradingviewscripts-format: 1 -->
#  Machine Learning RSI ║ BullVision

Source: https://www.tradingview.com/script/sHevuJyQ-Machine-Learning-RSI-BullVision/

## Description

Overview:
Introducing the Machine Learning RSI with KNN Adaptation – a cutting-edge momentum indicator that blends the classic Relative Strength Index (RSI) with machine learning principles. By leveraging K-Nearest Neighbors (KNN), this indicator aims at identifying historical patterns that resemble current market behavior and uses this context to refine RSI readings with enhanced sensitivity and responsiveness.

Unlike traditional RSI models, which treat every market environment the same, this version adapts in real-time based on how similar past conditions evolved, offering an analytical edge without relying on predictive assumptions.

Key Features:
🔁 KNN-Based RSI Refinement
This indicator uses a machine learning algorithm (K-Nearest Neighbors) to compare current RSI and price action characteristics to similar historical conditions. The resulting RSI is weighted accordingly, producing a dynamically adjusted value that reflects historical context.

📈 Multi-Feature Similarity Analysis
Pattern similarity is calculated using up to five customizable features:

[*]RSI level

[*]RSI momentum

[*]Volatility

[*]Linear regression slope

[*]Price momentum

Users can adjust how many features are used to tailor the behavior of the KNN logic.

🧠 Machine Learning Weight Control
The influence of the machine learning model on the final RSI output can be fine-tuned using a simple slider. This lets you blend traditional RSI and machine learning-enhanced RSI to suit your preferred level of adaptation.

🎛️ Adaptive Filtering
Additional smoothing options (Kalman Filter, ALMA, Double EMA) can be applied to the RSI, offering better visual clarity and helping to reduce noise in high-frequency environments.

🎨 Visual & Accessibility Settings
Custom color palettes, including support for color vision deficiencies, ensure that trend coloring remains readable for all users. A built-in neon mode adds high-contrast visuals to improve RSI visibility across dark or light themes.

How It Works:
Similarity Matching with KNN:
At each candle, the current RSI and optional market characteristics are compared to historical bars using a KNN search. The algorithm selects the closest matches and averages their RSI values, weighted by similarity. The more similar the pattern, the greater its influence.

Feature-Based Weighting:
Similarity is determined using normalized values of the selected features, which gives a more refined result than RSI alone. You can choose to use only 1 (RSI) or up to all 5 features for deeper analysis.

Filtering & Blending:
After the machine learning-enhanced RSI is calculated, it can be optionally smoothed using advanced filters to suppress short-term noise or sharp spikes. This makes it easier to evaluate RSI signals in different volatility regimes.

Parameters Explained:
📊 RSI Settings:
Set the base RSI length and select your preferred smoothing method from 10+ moving average types (e.g., EMA, ALMA, TEMA).

🧠 Machine Learning Controls:

[*]Enable or disable the KNN engine

[*]Select how many nearest neighbors to compare (K)

[*]Choose the number of features used in similarity detection

[*]Control how much the machine learning engine affects the RSI calculation

🔍 Filtering Options:
Enable one of several advanced smoothing techniques (Kalman Filter, ALMA, Double EMA) to adjust the indicator’s reactivity and stability.

📏 Threshold Levels:
Define static overbought/oversold boundaries or reference dynamically adjusted thresholds based on historical context identified by the KNN algorithm.

🎨 Visual Enhancements:
Select between trend-following or impulse coloring styles. Customize color palettes to accommodate different types of color blindness. Enable neon-style effects for visual clarity.

Use Cases:
Swing & Trend Traders
Can use the indicator to explore how current RSI readings compare to similar market phases, helping to assess trend strength or potential turning points.

Intraday Traders
Benefit from adjustable filters and fast-reacting smoothing to reduce noise in shorter timeframes while retaining contextual relevance.

Discretionary Analysts
Use the adaptive OB/OS thresholds and visual cues to supplement broader confluence zones or market structure analysis.

Customization Tips:

[*]Higher Volatility Periods: Use more neighbors and enable filtering to reduce noise.

[*]Lower Volatility Markets: Use fewer features and disable filtering for quicker RSI adaptation.

[*]Deeper Contextual Analysis: Increase KNN lookback and raise the feature count to refine pattern recognition.

[*]Accessibility Needs: Switch to Deuteranopia or Monochrome mode for clearer visuals in specific color vision conditions.

Final Thoughts:
The Machine Learning RSI combines familiar momentum logic with statistical context derived from historical similarity analysis. It does not attempt to predict price action but rather contextualizes RSI behavior with added nuance. This makes it a valuable tool for those looking to elevate traditional RSI workflows with adaptive, research-driven enhancements.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// BullVisionCapital

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%+=#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*==+@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@*===+@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#+#@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@#====+@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@==#@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@#=====+%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*===#@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@#========*#%%%@@%%%%%%%%%%%@@@@@@@@@%#+====+@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@#==============*+===========*%@#+========+@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%*=============+=============#@*======+#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%#+========================#@%==+#%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%##+==================+%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+===============================@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%==================*@@@*=======@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@%#*=============++*%#=====%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#==========================+=====*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*==================================+%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@*==========++=========================*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@#==========+@%+====================#+====#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@%+=========+@@@@#===================#@%+==%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@#=========+@@@@@@@@@%%%%%%%*==============@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@#========+@@@@@@@@@@@@@@@@@@@@@#========+@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@%+=======%@@@@@@@@@@@@+@@@@@@@@@@@%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@%+=====*@@@@@@@%@@@%+==#@@@@@@#%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+====#@@@@@@@=@@@%+==#@@@@@===#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#===#@@@@@%*=*%@%+==#@@@@@==*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%*=#@@@@@#+==%@%+==#@@@@+=#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@@@#+==%@%+==#@@@+=%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#+==%@@@=@@@@**@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#+==%@@@#@@@#%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%=%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

//@version=5
indicator(" Machine Learning RSI ║ BullVision",shorttitle = "🤖🧠 Machine Learning RSI ║ BullVision🤖🧠", overlay=false)

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                                                                              ║
// ║ RSI with K-Nearest Neighbors (KNN) Machine Learning                          ║
// ║                                                                              ║
// ║ This indicator enhances the traditional RSI using machine learning.          ║
// ║                                                                              ║
// ║ The KNN algorithm identifies historical situations most similar to current   ║
// ║ market conditions by analyzing multiple features:                            ║
// ║   - RSI value itself                                                         ║
// ║   - Momentum (rate of change)                                                ║
// ║   - Volatility (standard deviation)                                          ║
// ║   - Slope (linear regression)                                                ║
// ║   - Price momentum                                                           ║
// ║                                                                              ║
// ║ Once these similar historical situations are found, their outcomes are       ║
// ║ weighted by similarity to predict how the RSI might behave in the current    ║
// ║ situation, creating a more responsive and accurate indicator.                ║
// ║                                                                              ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

// ===== Import Required Libraries =====
import TradingView/ta/7

// ===== Input Parameters =====

// =====================================================================================
//                                     📊 RSI Base Settings
// =====================================================================================
group_rsi = "📊 ================ RSI Base Settings ================"
rsiLength = input.int(14, "RSI Length", minval=1, group=group_rsi)
useSmoothing = input.bool(true, "Apply Moving Average", group=group_rsi)
smoothingLength = input.int(3, "MA Length", minval=1, group=group_rsi)
maType = input.string("ALMA", "Moving Average Type", options=["SMA", "EMA", "DEMA", "TEMA", "WMA", "VWMA", "SMMA", "HMA", "LSMA", "ALMA"], group=group_rsi)
almaSigma = input.int(4, "ALMA Sigma", minval=1, group=group_rsi)
// =====================================================================================
//                                    📏 Threshold Settings
// =====================================================================================
group_threshold = "📏 ================ Threshold Settings ================"
//useAdaptiveThresholds = input.bool(true, "Use Adaptive Thresholds", tooltip="Automatically adjust overbought/oversold levels based on market conditions", group=group_threshold)
rsiOverbought = input.int(70, " Overbought Level", minval=50, maxval=100, group=group_threshold)
rsiOversold = input.int(30, " Oversold Level", minval=0, maxval=50, group=group_threshold)

// =====================================================================================
//                                   🧠 KNN Machine Learning Parameters
// =====================================================================================
group_knn = "🧠 ================ KNN Machine Learning ================"
useKnn = input.bool(true, "Enable KNN Machine Learning", group=group_knn)
knnNeighbors = input.int(5, "K - Number of Neighbors", minval=1, maxval=50, group=group_knn)
knnLookback = input.int(100, "Historical Period for KNN", minval=20, maxval=500, group=group_knn)
knnWeight = input.float(0.4, "ML Weight vs Standard RSI", minval=0.0, maxval=1.0, step=0.1, group=group_knn)
featureCount = input.int(3, "Number of Features", minval=1, maxval=5, tooltip="Number of characteristics for finding similar market conditions", group=group_knn)
// =====================================================================================
//                                   🔍 Advanced Filtering
// =====================================================================================
group_filter = "🔍 ================ Advanced Filtering ================"
useFilter = input.bool(true, "Apply Additional Smoothing", group=group_filter)
filterMethod = input.string("Kalman", "Smoothing Method", options=["None", "Kalman", "DoubleEMA", "ALMA"], group=group_filter)
filterStrength = input.float(0.3, "Smoothing Parameter", minval=0.01, maxval=1.0,step = 0.01, group=group_filter)
// =====================================================================================
//                                   🎨 Visual Settings
// =====================================================================================
group_visual = "🎨 ================ Visual Settings ================"
neonEffect = input.bool(true, "Neon Effect", tooltip="Enable vibrant neon-like colors", group=group_visual)
colorScheme = input.string("Classic", "Color Palette", ["Classic", "Deuteranopia", "Protanopia", "Tritanopia", "Monochrome"], group=group_visual)
colorMode = input.string("Trend Following", "Coloring Mode", ["None", "Trend Following", "Impulse"], group=group_visual)

// =====================================================================================
//                                   COLOR DEFINITION 
// =====================================================================================
// Colors adapted for different types of color blindness
[bullColor, bearColor] = switch colorScheme
    "Classic"    => [neonEffect ? color.rgb(0, 255, 187) : color.rgb(0, 183, 18), 
                     neonEffect ? color.rgb(255, 17, 0) : color.rgb(195, 0, 16)]
    "Deuteranopia" => [color.rgb(0, 170, 255), color.rgb(255, 204, 0)] // Blue/Yellow for red-green color blindness
    "Protanopia"  => [color.rgb(0, 170, 230), color.rgb(230, 175, 0)]  // Blue/Yellow variant
    "Tritanopia"  => [color.rgb(255, 112, 0), color.rgb(0, 33, 171)]   // Red/Blue for blue-yellow color blindness
    "Monochrome"  => [color.rgb(222, 226, 230), color.rgb(73, 80, 87)] // High contrast grayscale

// =====================================================================================
//                                   RSI Calculation Functions 
// =====================================================================================
// Moving Average wrapper function
// Moving Average wrapper function
calcMovingAverage(type, src, length, sigma) =>
    float result = na
    if type == "SMA"  
        result := ta.sma(src, length)
    else if type == "EMA"  
        result := ta.ema(src, length)
    else if type == "DEMA"  
        // Double EMA implementation
        e1 = ta.ema(src, length)
        e2 = ta.ema(e1, length)
        result := 2 * e1 - e2
    else if type == "TEMA"  
        // Triple EMA implementation
        e1 = ta.ema(src, length)
        e2 = ta.ema(e1, length)
        e3 = ta.ema(e2, length)
        result := 3 * (e1 - e2) + e3
    else if type == "WMA"  
        // Weighted Moving Average implementation
        norm = 0.0
        sum = 0.0
        for i = 0 to length - 1
            weight = (length - i)
            norm := norm + weight
            sum := sum + src[i] * weight
        result := sum / norm
    else if type == "VWMA"
        result := ta.vwma(src, length)
    else if type == "SMMA"
        // Smoothed Moving Average implementation (also known as RMA)
        result := ta.rma(src, length)
    else if type == "HMA"  
        result := ta.hma(src, length)
    else if type == "LSMA"
        // Least Squares Moving Average (Linear Regression)
        result := ta.linreg(src, length, 0)
    else if type == "ALMA"
        result := ta.alma(src, length, 0.85, sigma)
    result

// =====================================================================================
//                                   Calculate base RSI
// =====================================================================================
baseRsi = ta.rsi(close, rsiLength)
smoothedRsi = calcMovingAverage(maType, baseRsi, smoothingLength, almaSigma)
standardRsi = useSmoothing ? smoothedRsi : baseRsi

// =====================================================================================
//                                   FEATURE EXTRACTION FUNCTIONS
// =====================================================================================

// Calculate momentum (rate of change)
getMomentum(source, length) => source - source[length]

// Calculate volatility (standard deviation)
getVolatility(source, length) => ta.stdev(source, length)

// Calculate slope (linear regression difference)
getSlope(source, length) => ta.linreg(source, length, 0) - ta.linreg(source, length, 1)

// Min-max normalization function
normalize(source, length) =>
    maxVal = ta.highest(source, length)
    minVal = ta.lowest(source, length)
    valueRange = maxVal - minVal
    valueRange != 0 ? (source - minVal) / valueRange : 0.5

// Euclidean distance calculation
euclideanDistance(v1, v2) =>
    float sum = 0.0
    for i = 0 to array.size(v1) - 1
        sum := sum + math.pow(array.get(v1, i) - array.get(v2, i), 2)
    math.sqrt(sum)

// =====================================================================================
//                                   ADAPTIVE THRESHOLDS
// =====================================================================================
// Calculates dynamic overbought/oversold levels based on historical RSI distribution
calculateAdaptiveThresholds(src, period, percentile) =>
    var rsiValues = array.new_float(0)
    
    // Reset array when period changes
    if barstate.isfirst or array.size(rsiValues) > period
        array.clear(rsiValues)
    
    array.push(rsiValues, src)
    
    // Keep array size equal to period
    if array.size(rsiValues) > period
        array.shift(rsiValues)
    
    // Sort values for percentile calculation
    sortedValues = array.copy(rsiValues)
    array.sort(sortedValues)
    
    // Find percentile indices
    int lowIndex = math.floor(array.size(sortedValues) * percentile / 100)
    int highIndex = math.floor(array.size(sortedValues) * (100 - percentile) / 100)
    
    // Get threshold values (with safety checks)
    lowVal = array.size(sortedValues) > 0 and lowIndex < array.size(sortedValues) ? array.get(sortedValues, lowIndex) : 30
    highVal = array.size(sortedValues) > 0 and highIndex < array.size(sortedValues) ? array.get(sortedValues, highIndex) : 70
    
    [lowVal, highVal]

// =====================================================================================
//                                   KNN MACHINE LEARNING 
// =====================================================================================
knnEnhancedRsi() =>
    float enhancedRsi = standardRsi
    float knnDivergence = 0.0
    int effectiveK = 0

    // Arrays to collect ML extreme candidates
    var overBoughtCandidates = array.new_float(0)
    var overSoldCandidates = array.new_float(0)
    array.clear(overBoughtCandidates)
    array.clear(overSoldCandidates)

    // Current point features
    var currentPoint = array.new_float(0)
    array.clear(currentPoint)
    array.push(currentPoint, normalize(standardRsi, knnLookback))
    if featureCount >= 2
        array.push(currentPoint, normalize(getMomentum(standardRsi, 3), knnLookback))
    if featureCount >= 3
        array.push(currentPoint, normalize(getVolatility(standardRsi, 10), knnLookback))
    if featureCount >= 4
        array.push(currentPoint, normalize(getSlope(standardRsi, 5), knnLookback))
    if featureCount >= 5
        array.push(currentPoint, normalize(getMomentum(close, 5), knnLookback))

    var distances = array.new_float(0)
    var indices = array.new_int(0)
    array.clear(distances)
    array.clear(indices)

    // Calculate distances to historical points
    for i = 1 to knnLookback
        if i < bar_index
            var historicalPoint = array.new_float(0)
            array.clear(historicalPoint)
            array.push(historicalPoint, normalize(standardRsi[i], knnLookback))
            if featureCount >= 2
                array.push(historicalPoint, normalize(getMomentum(standardRsi[i], 3), knnLookback))
            if featureCount >= 3
                array.push(historicalPoint, normalize(getVolatility(standardRsi[i], 10), knnLookback))
            if featureCount >= 4
                array.push(historicalPoint, normalize(getSlope(standardRsi[i], 5), knnLookback))
            if featureCount >= 5
                array.push(historicalPoint, normalize(getMomentum(close[i], 5), knnLookback))

            if array.size(currentPoint) == array.size(historicalPoint)
                dist = euclideanDistance(currentPoint, historicalPoint)
                array.push(distances, dist)
                array.push(indices, i)

            array.clear(historicalPoint)

    if array.size(distances) > 1
        for i = 0 to array.size(distances) - 2
            for j = 0 to array.size(distances) - 2 - i
                if array.get(distances, j) > array.get(distances, j + 1)
                    tempDist = array.get(distances, j)
                    array.set(distances, j, array.get(distances, j + 1))
                    array.set(distances, j + 1, tempDist)

                    tempIdx = array.get(indices, j)
                    array.set(indices, j, array.get(indices, j + 1))
                    array.set(indices, j + 1, tempIdx)

        float weightedSum = 0.0
        float weightSum = 0.0
        effectiveK := math.min(knnNeighbors, array.size(distances))

        if effectiveK > 0
            for i = 0 to effectiveK - 1
                if i < array.size(distances)
                    idx = array.get(indices, i)
                    dist = array.get(distances, i)
                    weight = dist < 0.0001 ? 1.0 : 1.0 / dist

                    float neighborRsi = na
                    if idx < bar_index
                        neighborRsi := standardRsi[idx - 1]

                        // Sécurité sur futureReturn
                        float futureReturn = na
                        if (idx + 5 < bar_index + 1 and not na(close[idx + 5]) and not na(close[idx]))
                            futureReturn := close[idx + 5] - close[idx]

                        // Identification des zones extrêmes
                        if not na(futureReturn)
                            if futureReturn > close[idx] * 0.02
                                array.push(overBoughtCandidates, standardRsi[idx])
                            if futureReturn < close[idx] * -0.02
                                array.push(overSoldCandidates, standardRsi[idx])

                    if not na(neighborRsi)
                        weightedSum := weightedSum + neighborRsi * weight
                        weightSum := weightSum + weight

            if weightSum > 0.0
                knnRsi = weightedSum / weightSum
                enhancedRsi := (1.0 - knnWeight) * standardRsi + knnWeight * knnRsi
                enhancedRsi := math.max(0.0, math.min(100.0, enhancedRsi))

                float diffSum = 0.0
                int count = 0
                for i = 0 to effectiveK - 1
                    if i < array.size(distances)
                        idx = array.get(indices, i)
                        if idx < bar_index
                            diffSum := diffSum + math.abs(standardRsi - standardRsi[idx])
                            count := count + 1

                knnDivergence := count > 0 ? diffSum / count : 0.0

    adaptiveOverboughtML = array.size(overBoughtCandidates) > 0 ? array.avg(overBoughtCandidates) : 70
    adaptiveOversoldML  = array.size(overSoldCandidates) > 0 ? array.avg(overSoldCandidates) : 30

    [enhancedRsi, knnDivergence, effectiveK, adaptiveOversoldML, adaptiveOverboughtML]


// =====================================================================================
//                                   APPLY ALGORITHMS
// =====================================================================================

// Get enhanced RSI from KNN
[knnRsi, knnDivergence, kEffective, adaptiveOversoldML, adaptiveOverboughtML] = knnEnhancedRsi()

actualOversold = rsiOversold
actualOverbought = rsiOverbought

// Use either standard or KNN-enhanced RSI
mlRsi = useKnn ? knnRsi : standardRsi

// Apply advanced filtering if enabled
filteredRsi = switch filterMethod
    "None" => mlRsi
    "Kalman" =>
        var float kfRsi = na
        kfRsi := na(kfRsi) ? mlRsi : kfRsi + filterStrength * (mlRsi - kfRsi)
        kfRsi
    "DoubleEMA" =>
        var float ema1 = na
        var float ema2 = na
        ema1 := ta.ema(mlRsi, math.round(filterStrength * 10))
        ema2 := ta.ema(ema1, math.round(filterStrength * 5))
        ema2
    "ALMA" =>
        ta.alma(mlRsi, math.round(filterStrength * 20), 0, 6)
    => mlRsi

// Final RSI value after all processing
finalRsi = useFilter ? filteredRsi : mlRsi

// ===== Color Determination =====
color indicatorColor = switch colorMode
    "None"              => na
    "Trend Following"   => finalRsi > 50 ? bullColor : bearColor
    "Impulse"           => finalRsi > actualOverbought ? bullColor : finalRsi < actualOversold ? bearColor : finalRsi < 55 and finalRsi > 45 ? color.white : color.gray


// =====================================================================================
//                                   VIUSALS AND PLOTS
// =====================================================================================
// Variables for transparency
t_ = 20   // Secondary transparency for bar coloring

// Main RSI line
rsiLine = plot(finalRsi, "RSI KNN", finalRsi > 50 ? indicatorColor : indicatorColor, 3)

// Median line (level 50)
midLine = plot(50, "50 Level", color.new(color.white, 70), 1)

// Fill between RSI and median line with gradient

fill(rsiLine, midLine, finalRsi > 50 ? finalRsi : 50, finalRsi > 50 ? 50 : finalRsi, 
     neonEffect ? (finalRsi > 50 ? indicatorColor : #00000000) : #00000000, 
     neonEffect ? (finalRsi > 50 ? #00000000 : indicatorColor) : #00000000)

// Overbought/oversold zones with gradient
// Overbought zone
obUpper = plot(100, "", color.new(bearColor, 0), display=display.none)
obLower = plot(actualOverbought, "", color.new(bearColor, 0), 1)
obMid = plot((100 + actualOverbought) / 2, "", display=display.none)

// Oversold zone
osUpper = plot(actualOversold, "", color.new(bullColor, 0), 1)
osLower = plot(0, "", color.new(bullColor, 0), display=display.none)
osMid = plot(actualOversold / 2, "", display=display.none)

// Chart bar coloring
barcolor(finalRsi > 50 ? color.new(bullColor, t_) : color.new(bearColor, t_))



// =====================================================================================
//                                   TABLE
// =====================================================================================

// =====================================================================================
//                                   TABLE DISPLAY
// =====================================================================================


string modeUsed = colorMode


string context = switch colorMode
    "Trend Following" => finalRsi > 50 ? "Bullish Trend" : "Bearish Trend"
    "Impulse" => finalRsi > actualOverbought ? "Bullish Impulse" :
                 finalRsi < actualOversold ? "Bearish Impulse" : "None"
    => "None"


string mlStatus = useKnn ? "YES" : "NO"


tableColor = #160d0db3
var table myTable = table.new(position = position.top_right,columns = 4, rows = 6,bgcolor = #160d0db3, border_color = #160d0db3,border_width = 1, frame_color = #ffffff, frame_width = 1,force_overlay = true)

if bar_index % 10 == 0  // Met à jour toutes les 10 bougies pour optimiser les perfs
    table.cell(myTable, 0, 0, "Mode", text_color=color.white, bgcolor=tableColor)
    table.cell(myTable, 1, 0, modeUsed, text_color=color.white, bgcolor=tableColor)

    table.cell(myTable, 0, 1, "Detected", text_color=color.white, bgcolor=tableColor)
    table.cell(myTable, 1, 1, context, text_color=color.white, bgcolor=tableColor)

    table.cell(myTable, 0, 2, "Machine Learning", text_color=color.white, bgcolor=tableColor)
    table.cell(myTable, 1, 2, mlStatus, text_color=color.white, bgcolor=tableColor)

    table.cell(myTable, 0, 3, "OB/OS Thresholds", text_color=color.white, bgcolor=tableColor)
    table.cell(myTable, 1, 3, str.tostring(actualOverbought) + " / " + str.tostring(actualOversold), text_color=color.white, bgcolor=color.new(color.black, 70))
````
