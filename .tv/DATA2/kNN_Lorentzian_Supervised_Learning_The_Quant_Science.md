<!-- tradingview-pine-id: PUB;550bdca3f6b846b29eab3d738c616472 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# k-NN Lorentzian Supervised Learning [The Quant Science]

Source: https://www.tradingview.com/script/d6fBXXZa-k-NN-Lorentzian-Supervised-Learning-The-Quant-Science/

## Description

This script uses a Supervised Learning algorithm called k-Nearest Neighbors (k-NN), incorporating a Lorentzian distance metric to estimate future price direction.

Algorithm Overview
Is a classification algorithm where the model answers a binary question: 

💭 "Will the price rise or fall in 2 candles?"

and assigns a class: +1 for Long or -1 Short.

Rather than looking strictly at raw price, it transforms the data into a 4-dimensional feature space (log return, CLV, range width, and volume change).

With every new candle, the algorithm queries historical data to find the patterns that are mathematically or visually most similar to the current one.

This machine learning model falls under the Instance-Based (or lazy learning) category. Unlike neural networks or models like XGBoost, k-NN has no upfront training phase to generate a rigid formula. Instead, it retains historical data in memory and computes predictions on the fly for every single bar.

k-NN in a Nutshell
k-NN operates on the principle of "let's see what happened the last time conditions were identical." Instead of relying on complex mathematical formulas, it takes current market conditions (price, volume, volatility) and scans historical data for the k most similar instances. It then observes whether price moved up or down following those historical setups and takes a majority vote. If most of these "historical twins" were followed by a rally, the algorithm bets on a bullish move today as well.
[image]https://www.tradingview.com/x/ERcSgUP3/[/image]

What is the Lorentzian Classification Model?
In statistics and machine learning, Lorentzian classification refers to a classification algorithm in which the similarity of data points is measured using the Lorentz distance. In short, it is a proximity-based classification system designed to be “insensitive” to interference and extreme noise spikes in the data.
[image]https://www.tradingview.com/x/Jtpdrp8P/[/image]

Lorentz Distance vs Euclidean Distance
In statistics, the distance between data points measures how much two situations differ from one another. When a measurement is completely out of line with the rest, it is referred to as an outlier. In traditional statistical analyses, Euclidean Distance (the classic straight-line distance based on the Pythagorean theorem) is usually employed. However, Euclidean distance squares the differences between variables, making it extremely sensitive to outliers (anomalous or extreme values).

Differences
Classical (Euclidean) distance calculates differences by scaling them up exponentially as they grow larger. If two values differ slightly, the difference is considered small; if they differ significantly, the difference is magnified. Consequently, a single erroneous value carries immense weight in the final result and distorts the entire analysis.

Lorentz distance applies compression to differences. It initially registers small differences normally, but when it encounters very large distances, it stops scaling them up and levels them off.

In this way, outliers are still recognized as "different," but they cannot dominate or derail the overall calculation. The analysis thus focuses on the majority of actual data instead of being skewed by exceptions.

🔑 Key Differences
Compresses Outliers: The logarithmic function grows much slower than a power function. If a single feature exhibits a massive spike, the Lorentzian distance dampens its impact rather than heavily penalizing the entire data point.
Enhanced Robustness to Noise: Is particularly effective on real-world datasets prone to sensor errors or dirty data, ensuring that nearest neighbors (e.g., in k-NN algorithms) are correctly identified.

🧪 Where is frequently used in data science?

[*]Handling Data with Heavy-Tailed Distributions: iIn statistics, many real-world datasets (such as financial, seismic, or network traffic data) do not follow a normal (bell-shaped) distribution, but rather exhibit extreme spikes and frequent rare events. Lorentz distance handles the curvature of these datasets better than classical metrics.
[*]Pattern Recognition in the Presence of Heavy Noise: If a dataset contains substantial "dirty" data or anomalous spikes, a classification algorithm based on Euclidean distance would be distorted by outliers. Lorentzian classification bounds the impact of these spikes, isolating the true underlying signal.
[*]Hyperbolic and Complex Geometric Spaces: In advanced statistics and deep learning, it is used to map and label structured data in non-Euclidean spaces (hyperbolic geometries or Minkowski spaces), where hierarchical relationships among data points are non-linear.

Core Features of Our Script
💎 Powered by Pine Script 6 Matrices
Thanks to the latest updates to Pine Script, we’ve leveraged matrices instead of traditional arrays, creating an ultra-fast, high-performance script that eliminates chart lag. In the past version v5, the use of arrays required continuous dynamic memory allocations for every single bar, significantly slowing down calculations and increasing chart latency when you tried to build a machine learning model. By using Pine v6’s native matrices, we completely remove this bottleneck, achieving speeds up to 3x faster and eliminating repeated dynamic allocations.

💎 Use of Purely Quantitative Metrics
We build this model strictly on quantitative metrics:

[*]Normalized Log-Return: log returns calculated as Close / Close[1], measuring true price velocity without lag
[*]Close Location Value: measures where the price closes relative to its High-Low range, serving as a proxy for buyer/seller pressure within a single bar
[*]True Range Ratio: compares the current range against recent Min-Max ranges
[*]Volume Z-Score: measures how much the current trading volume deviates from the historical average, expressing this difference in standard deviations. It helps determine whether market volumes are normal or whether there is a statistical anomaly

How it works | Step by step process

🧠  [1] Analysis
Engine start monitoring and analyze 4 quantitative metrics for every bar:
Momentum: Log-returns (price velocity)
Structure: Close Location Value (where the candle closes relative to its High and Low)
Volatility: Percentage range width of the candle
Volume: Volume change relative to the previous bar

⬇️

🧠  [2] Data Normalization 
ensuring data comparability across all dimensions.

⬇️

🧠  [3] Lorentzian & k-NN 
compares current data against the last n historical periods, computing the Lorentzian distance metric to identify the most similar historical instances (k-Nearest Neighbors) to the current market setup.

⬇️

🧠 [4] Voting system 
evaluates price action immediately following those historical instances:
🟢 If the majority (80%) of those similar candles resulted in an bullish move, assigns 1
[image]https://www.tradingview.com/x/rmyVxwgs/[/image]
🔴 If the majority (80%) resulted in a bearish move, assigns -1
[image]https://www.tradingview.com/x/wA1EGId8/[/image]

User Interface
[image]https://www.tradingview.com/x/zJRQk2vy/[/image]

Lookback: Represents the model's "historical memory", the number of past bars analyzed to identify patterns similar to the current market setup. A higher value provides more historical instances for comparison, but increases computational load.

k / Number of Neighbors: Represents the number of most similar historical bars (the "neighbors") to consider for the final decision. After calculating the Lorentzian distance between the current bar and the past 200 bars, the algorithm isolates the 8 historical instances that most closely resemble today's setup and performs a majority vote to determine the signal.

Target Horizon: The forward time horizon used to label historical data. It defines the bar offset after which the algorithm evaluates whether price moved up or down. With a value of 2, the algorithm checks price action exactly 2 bars after each identified historical pattern.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © thequantscience

//@version=6
indicator("k-NN Lorentzian Supervised Learning [The Quant Science]", overlay = true, max_bars_back = 1000, max_labels_count = 500)

import thequantscience/kNNLorentzianMachineLearning/1 as ml

int lookback_window = input.int(defval = 500, title = "Lookback Window", minval = 50, maxval = 500, group = "Settings")
int k_neighbors = input.int(defval = 8, title = "Number of Neighbors [k]", minval = 1, maxval = 25, group = "Settings")
int target_feature = input.int(defval = 10, title = "Target Horizon", minval = 1, group = "Settings")
int norm_len = input.int(defval = 30, title = "Normalization Period", minval = 5, group = "Settings")
float threshold = input.float(defval = 0.85, title = "Confidence Threshold", minval = 0.5, maxval = 1.0, step = 0.05, group = "Settings")
int step_size = input.int(defval = 4, title = "Step Size [Performance Optimization]", minval = 1, group = "Settings")

float log_return = math.log(close / close[1])
float clv = (high - low) == 0 ? 0.0 : ((close - low) - (high - close)) / (high - low)
float range_pct = (high - low) / close * 100.0
float vol_delta = volume / volume[1]

float f1 = ml.f_minmax(log_return, norm_len)
float f2 = ml.f_minmax(clv, norm_len)
float f3 = ml.f_minmax(range_pct, norm_len)
float f4 = ml.f_minmax(vol_delta, norm_len)

array<float> current_features = array.new_float(4)
array.set(current_features, 0, f1)
array.set(current_features, 1, f2)
array.set(current_features, 2, f3)
array.set(current_features, 3, f4)

var matrix<float> hist_matrix = matrix.new<float>(0, 5, na)

float target_direction = na
if bar_index >= target_feature
    target_direction := close[target_feature] > close ? 1.0 : 0.0

ml.f_update_history_matrix(hist_matrix, current_features, target_direction, lookback_window)

int raw_signal = 0
float confidence = 0.5

if matrix.rows(hist_matrix) > k_neighbors + 5
    [sig, conf] = ml.f_calc_knn_matrix(k_neighbors, threshold, current_features, hist_matrix, step_size)
    raw_signal := sig
    confidence := conf

int confirmed_signal = raw_signal[1]
var int pos = 0

bool is_long = confirmed_signal == 1 and pos != 1
bool is_short = confirmed_signal == -1 and pos != -1

if is_long
    pos := 1
    label.new(bar_index - 1, low[1], text = "1", style = label.style_none, textcolor = color.rgb(0, 255, 8), yloc = yloc.belowbar, size = size.normal)
if is_short
    pos := -1
    label.new(bar_index - 1, high[1], text = "-1", style = label.style_none, textcolor = color.rgb(255, 39, 39), yloc = yloc.abovebar, size = size.normal)
````
