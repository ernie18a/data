<!-- tradingview-pine-id: PUB;3ef02b63c29d4bfcb2a9fed0c542f1e3 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# kNNLorentzianMachineLearning

Source: https://www.tradingview.com/script/pVSBWUxj-kNNLorentzianMachineLearning/

## Description

A high-performance, quant-grade machine learning library written in Pine Script v6, implementing a k-Nearest Neighbors (kNN) classification engine optimized for algorithmic trading. This library features a zero-data-leakage architecture, dynamic memory pre-allocation, and a specialized distance metric designed to evaluate historical market state similarities efficiently. 

🔷 Introduction
For quantitative and algorithmic traders using TradingView and Pine Script v6, this library provides an institutional-grade machine learning architecture that moves far beyond basic, traditional technical indicators.

When it comes to feature scalability, the engine is designed to handle a dynamic and unrestricted number of features. You simply pass an array of your chosen technical features, and the library automatically adapts its internal matrix structure to accommodate them. The matrix allocates columns for your features while reserving the final column specifically for the historical target direction. For optimal performance and to avoid the curse of dimensionality—where distance metrics lose precision in overly complex spaces—it is best to use a compact, orthogonal set of three to eight features, such as balanced combinations of momentum, volatility, and volume indicators.

A critical advantage for backtesting integrity is the zero-data-leakage design. In quantitative finance, accidentally including contemporaneous or future information in historical calculations invalidates your results. This library forces the historical scanning loop to start at index one instead of zero, completely excluding the active current bar from the distance calculation pool. This eliminates lookahead bias entirely and ensures your backtest results reflect true historical precedents.

To handle market noise, the library uses a Lorentzian distance metric with a logarithmic transformation. Standard Euclidean distance metrics often break down during flash crashes or extreme macroeconomic volatility spikes because outliers heavily distort the results. The logarithmic transformation dampens the impact of extreme values, stabilizing the kNN classification engine during turbulent market regimes.

From a performance and runtime perspective, the library implements advanced memory management. By using pre-allocated temporary matrices, it avoids the heavy heap thrashing caused by constant dynamic resizing. Furthermore, the step-size parameter allows the engine to sample historical bars by skipping intervals, meaning you can run deep historical lookbacks across thousands of bars without hitting Pine Script execution timeouts.

Finally, the engine delivers probabilistic confidence scoring rather than rigid binary signals. It evaluates the top-k nearest neighbors and computes a directional confidence ratio. Signals are only triggered when this confidence score breaches your configured threshold, giving algorithmic traders a reliable filter for risk management. Combined with recursive safety checks that catch missing values before they can crash your script, this library offers a robust foundation for live quantitative execution.

🔷 Key Technical Features

🔹 Robust Min-Max Feature Normalization [f_minmax]

[*]Dynamic Bounding: Computes local maximums and minimums over a configurable lookback window to normalize raw source values.
[*]Edge-Case Safety: Implements strict safeguards against division by zero and na propagation, defaulting to a median scale baseline [50.0] when ranges collapse or data is unavailable.

🔹 Historical Matrix State Management [f_update_history_matrix]

[*]Integrity Validation: Performs deep array inspection to ensure all feature vectors are free of na values before ingestion.
[*]Bounded Rolling Buffer: Automatically maintains a sliding window of historical states, capping memory growth by removing oldest records once the [max_lookback] threshold is exceeded.

🔹 Optimized kNN Classification Engine [f_calc_knn_matrix]

[*]Zero Data Leakage: Explicitly offsets historical iteration starting points (beginning at index 1) to prevent current-bar lookahead bias.
[*]Memory Optimization & Pre-allocation: Reduces runtime overhead through dynamic step-size sampling [step_size] and pre-allocated temporary matrix architecture.
[*]Lorentzian Distance Adaptation: Utilizes a logarithmic transformation metric to compute feature distance matrices, mitigating the distorting effects of market outliers.
[*]Confidence Scoring: Aggregates directional outcomes from the top-k nearest neighbors to output a bounded probability metric and a threshold-filtered trading score [+1, -1, 0].

🔷 Function Signatures & API Reference

🔹 f_minmax(src, len)
Normalizes a data series between 0 and 100 using a rolling lookback window.
Return Type: float
🔹 f_update_history_matrix(hist_matrix, current_features, target_direction, max_lookback)
Appends validated feature vectors and target directions to the historical memory matrix.
Return Type: void
🔹 f_calc_knn_matrix(k_neighbors, threshold, current_features, hist_matrix, step_size)
Executes the kNN distance scan, sorting, and institutional confidence calculation.
Return Type: [int, float]

Below find a script example to quickly test the library. 
[pine]//@version=6
indicator("kNN Lorentzian Library API Example [The Quant Science]", overlay = true)

import thequantscience/kNNLorentzianMachineLearning/5 as knnLib

// INPUTS & CONFIGURATION
k_neighbors  = input.int(8, "k Neighbors", minval=1)
threshold    = input.float(0.6, "Confidence Threshold", minval=0.5, maxval=1.0, step=0.05)
max_lookback = input.int(500, "Max Lookback Window", minval=100)
step_size    = input.int(1, "Scan Step Size", minval=1)
norm_len     = input.int(14, "Normalization Lookback", minval=5)

// FEATURE ENGINEERING & NORMALIZATION
// Extract raw technical indicators and normalize them using the library's f_minmax function
float f1 = knnLib.f_minmax(ta.rsi(close, 14), norm_len)
float f2 = knnLib.f_minmax(ta.cci(close, 14), norm_len)
float f3 = knnLib.f_minmax(ta.mom(close, 10), norm_len)

// Package features into an array
array<float> current_features = array.new_float(0)
array.push(current_features, f1)
array.push(current_features, f2)
array.push(current_features, f3)

// Define the target direction (e.g., did price go up relative to the previous bar?)
float target_direction = close > close[1] ? 1.0 : 0.0

// MATRIX MANAGEMENT & kNN EXECUTION
// Initialize the historical matrix (persisted across bars using 'var')
// Note: matrix columns = number of features + 1 (for the target direction)
var matrix<float> hist_matrix = matrix.new<float>(0, array.size(current_features) + 1, na)

// 1. Update history matrix with current bar's features and target
knnLib.f_update_history_matrix(hist_matrix, current_features, target_direction, max_lookback)

// 2. Execute the kNN classification engine
[raw_signal, confidence] = knnLib.f_calc_knn_matrix(k_neighbors, threshold, current_features, hist_matrix, step_size)

// PLOTTING & VISUAL FEEDBACK
// Plot buy/sell signals on the chart
plotshape(raw_signal == 1, title="Long Signal", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(raw_signal == -1, title="Short Signal", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)[/pine]

-----------------------------------------------------------------------------
f_minmax(src, len)
  Parameters:
    src (float): (float) The raw data series to normalize (e.g., RSI, CCI, Momentum).
    len (int): (int) Lookback period for determining the rolling minimum and maximum.
  Returns: (float) The normalized value scaled from 0 to 100, or a default midpoint (50.0) on structural failure.
-----------------------------------------------------------------------------

f_update_history_matrix(hist_matrix, current_features, target_direction, max_lookback)
  Parameters:
    hist_matrix (matrix<float>): (matrix<float>) The reference matrix storing historical feature rows and targets.
    current_features (array<float>): (array<float>) The current bar's feature vector array to evaluate and ingest.
    target_direction (float): (float) The label/target outcome for the current state (e.g., 1.0 for up, 0.0 for down).
    max_lookback (int): (int) Maximum allowed row capacity for the history buffer to control memory footprint.
  Returns: (void) Mutates the history matrix in place.
-----------------------------------------------------------------------------

f_calc_knn_matrix(k_neighbors, threshold, current_features, hist_matrix, step_size)
  Parameters:
    k_neighbors (int): (int) Number of nearest neighbors to query for classification.
    threshold (float): (float) Confidence probability boundary required to trigger a directional signal (e.g., 0.6).
    current_features (array<float>): (array<float>) The live feature vector evaluated against historical instances.
    hist_matrix (matrix<float>): (matrix<float>) The historical memory matrix containing past states and targets.
    step_size (int): (int) Sampling step size interval to optimize heavy runtime loops.
  Returns: (tuple) Returns [raw_signal, confidence] where signal is 1, -1, or 0, and confidence is a float ratio.
-----------------------------------------------------------------------------

---

## Source Code

````pine
//@version=6
library("kNNLorentzianMachineLearning", overlay = false)

// ============================================================================
// ARCHITECTURE: QUANT-GRADE kNN MATRIX MACHINE LEARNING ENGINE
// Optimized for Pine Script v6 runtime performance, zero data leakage,
// and efficient memory handling via pre-allocated matrix operations.
// ============================================================================

//-----------------------------------------------------------------------------
//@description Normalizes a raw data series between 0.0 and 100.0 using a rolling lookback window.
//@param src   (float) The raw data series to normalize (e.g., RSI, CCI, Momentum).
//@param len   (int) Lookback period for determining the rolling minimum and maximum.
//@returns     (float) The normalized value scaled from 0 to 100, or a default midpoint (50.0) on structural failure.
//-----------------------------------------------------------------------------
export f_minmax(float src, int len) =>
    float minVal = ta.lowest(src, len)
    float maxVal = ta.highest(src, len)
    float rangeVal = maxVal - minVal
    na(src) or na(rangeVal) ? 50.0 : (rangeVal <= 0.00001 ? 50.0 : ((src - minVal) / rangeVal) * 100.0)

//-----------------------------------------------------------------------------
//@description Appends validated feature vectors and target directions to the rolling historical memory matrix.
//@param hist_matrix      (matrix<float>) The reference matrix storing historical feature rows and targets.
//@param current_features (array<float>) The current bar's feature vector array to evaluate and ingest.
//@param target_direction (float) The label/target outcome for the current state (e.g., 1.0 for up, 0.0 for down).
//@param max_lookback     (int) Maximum allowed row capacity for the history buffer to control memory footprint.
//@returns                (void) Mutates the history matrix in place.
//-----------------------------------------------------------------------------
export f_update_history_matrix(matrix<float> hist_matrix, array<float> current_features, float target_direction, int max_lookback) =>
    bool has_na = false
    if not na(target_direction)
        int num_features = array.size(current_features)
        for j = 0 to num_features - 1
            if na(array.get(current_features, j))
                has_na := true
                break
        
        if not has_na
            array<float> new_row = array.copy(current_features)
            array.push(new_row, target_direction)
            
            matrix.add_row(hist_matrix, 0, new_row)
            
            if matrix.rows(hist_matrix) > max_lookback
                matrix.remove_row(hist_matrix, matrix.rows(hist_matrix) - 1)

//-----------------------------------------------------------------------------
//@description Executes a zero-data-leakage kNN classification scan utilizing Lorentzian distance metrics and pre-allocated matrices.
//@param k_neighbors      (int) Number of nearest neighbors to query for classification.
//@param threshold        (float) Confidence probability boundary required to trigger a directional signal (e.g., 0.6).
//@param current_features (array<float>) The live feature vector evaluated against historical instances.
//@param hist_matrix      (matrix<float>) The historical memory matrix containing past states and targets.
//@param step_size        (int) Sampling step size interval to optimize heavy runtime loops.
//@returns                (tuple) Returns [raw_signal, confidence] where signal is 1, -1, or 0, and confidence is a float ratio.
//-----------------------------------------------------------------------------
export f_calc_knn_matrix(int k_neighbors, float threshold, array<float> current_features, matrix<float> hist_matrix, int step_size) =>
    int raw_signal = 0
    float confidence = 0.5
    int total_rows = matrix.rows(hist_matrix)
    int num_features = array.size(current_features)
    int effective_step = math.max(1, step_size)

    if total_rows > k_neighbors + 5
        int estimated_rows = math.floor(total_rows / effective_step)
        
        // Pre-allocated temporary matrix to prevent runtime heap thrashing
        matrix<float> temp_matrix = matrix.new<float>(estimated_rows, 2, na)
        int valid_row_count = 0

        // Start at i = 1 to guarantee ZERO DATA LEAKAGE (exclude current active bar)
        for i = 1 to total_rows - 1 by effective_step
            float total_dist = 0.0
            bool row_has_na = false
            
            for j = 0 to num_features - 1
                float val_curr = array.get(current_features, j)
                float val_hist = matrix.get(hist_matrix, i, j)
                
                if na(val_curr) or na(val_hist)
                    row_has_na := true
                    break
                
                // Lorentzian distance metric with logarithmic dampening on outliers
                total_dist += math.log(1.0 + math.abs(val_curr - val_hist))
            
            if not row_has_na
                float dir = matrix.get(hist_matrix, i, num_features)
                if not na(dir) and valid_row_count < estimated_rows
                    matrix.set(temp_matrix, valid_row_count, 0, total_dist)
                    matrix.set(temp_matrix, valid_row_count, 1, dir)
                    valid_row_count += 1

        if valid_row_count >= k_neighbors
            matrix<float> knn_matrix = matrix.new<float>(valid_row_count, 2, na)
            
            for r = 0 to valid_row_count - 1
                matrix.set(knn_matrix, r, 0, matrix.get(temp_matrix, r, 0))
                matrix.set(knn_matrix, r, 1, matrix.get(temp_matrix, r, 1))

            matrix.sort(knn_matrix, 0, order.ascending)

            int total_up = 0
            for k = 0 to k_neighbors - 1
                float dir = matrix.get(knn_matrix, k, 1)
                if dir == 1.0
                    total_up += 1

            confidence := total_up / float(k_neighbors)

            if confidence >= threshold
                raw_signal := 1
            else if confidence <= (1.0 - threshold)
                raw_signal := -1
            else
                raw_signal := 0

    [raw_signal, confidence]
````
