<!-- tradingview-pine-id: PUB;25e99ee831a044ea8ac91104704b9df0 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# XGBoostMini

Source: https://www.tradingview.com/script/SQ2QIdN6-XGBoostMini/

## Description

This advanced library implements a fully functional, optimized, and native XGBoost (Extreme Gradient Boosting) binary classification model, allowing you to train an ensemble of decision trees and perform real-time inference directly on price data and technical indicators.

🔷 XGBoost Extreme Gradient Boosting
XGBoost is one of the most famous, powerful, and widely used machine learning libraries in the world. Is an ensemble learning model. It works by sequentially combining many weak decision trees (weak learners), where each new tree is specifically trained to correct the errors (residuals) made by the preceding trees. It has become the gold standard for solving tabular data problems and is renowned for dominating competitions on the Kaggle platform for years thanks to its extraordinary combination of speed and precision.
[image]https://www.tradingview.com/x/rBABg3Dg/[/image]

🔹 Key Features That Make It Unique

[*]Speed and Efficiency (Parallelization): Unlike traditional Gradient Boosting, which builds trees in a strictly sequential manner, XGBoost leverages multithreading to parallelize tree construction, drastically reducing computation time.
[*]Built-in Regularization (L1 and L2): It includes penalties for model complexity, which helps prevent overfitting (the phenomenon where the model memorizes training data but fails on unseen data).
[*]Missing Values Handling: It features built-in internal logic to automatically determine how to handle missing or NaN data during the splitting phase, without requiring mandatory upfront preprocessing.
[*]Approximate Split Algorithms: For massive datasets, it uses intelligent techniques to find optimal split points without having to evaluate every single value, further accelerating the process.

🔹 What is XGBoost and Where Did It Come From?
XGBoost (eXtreme Gradient Boosting) is one of the most powerful and widely used machine learning algorithms in the world, particularly for structured and tabular data.
It was created in 2014 by Tianqi Chen (then a researcher at the University of Washington) as an open-source research project, and it became a global phenomenon in 2016 following the publication of its landmark paper presented at the SIGKDD conference. Chen aimed to push the concept of Gradient Boosting (sequentially combining weak decision trees, where each new tree corrects the errors of previous ones) beyond the limitations of traditional software at the time. The goal was to build a system that combined extreme computational speed (leveraging parallel hardware) with extraordinary predictive accuracy, introducing advanced techniques such as mathematical regularization to prevent overfitting.

🔹 Why XGBoost is a Brilliant Choice for Financial Time Series Trading
In quantitative trading, financial market data (prices, volumes, and technical indicators like RSI, MACD, and moving averages) almost always comes in a tabular format. Here is why XGBoost frequently outperforms more complex models (such as Neural Networks or Transformers) when analyzing financial time series:

[*]Tabular Data Dominance: Unlike images or text, historical time series structured as indicators and extracted features benefit immensely from decision trees. XGBoost excels at discovering complex threshold rules (e.g., "if the RSI is below 30 and volatility exceeds X, then...").
[*]Noise Management and Regularization: Financial markets are notoriously noisy. XGBoost’s regularization parameters penalize tree complexity, preventing the model from memorizing past data and forcing it to uncover generalizable patterns.
[*]Robustness to Outliers: Flash crashes, sudden volume spikes, or data anomalies do not throw decision trees off balance—unlike linear models or neural networks, which are often sensitive to extreme values.
[*]Interpretability via Feature Importance: In trading, guessing direction is not enough; you must understand why. XGBoost natively computes the importance of each variable (via structural gain), allowing you to discover which technical indicators are genuinely driving strategy performance versus those that are just noise.
[*]Real-Time Inference Speed: Because it relies on simple sequential logical comparisons (inference across shallow decision trees), it is ideal for real-time execution directly on platforms like TradingView without excessive latency.

🔷 1. User-Defined Types (UDTs)
The code leverages Pine Script v6 data structures to define the model architecture:

[*]XGBTreeDepth3: Represents a single weak learner with a fixed depth of 3 levels. It stores feature indices, split thresholds, information gains for each node, and the terminal leaf weights (w0 through w7) for all 8 possible leaf regions.
[*]XGBModel: Encapsulates the entire trained tree ensemble, the best recorded validation loss (best_val_loss), and the optimal number of trees to retain (best_tree_count).
[*]SplitCandidate: An internal helper structure used to evaluate optimal split points during tree growth.

🔷 2. Inference & Analysis Methods

[*]predict_tree: Traverses the depth-3 decision tree by sequentially evaluating feature values against stored thresholds until a terminal leaf node is reached.
[*]predict_probability: Aggregates the raw scores (logits) across all trees in the ensemble, applies the learning rate, and maps the final output to a logistic probability ranging from 0.0 to 1.0 via the Sigmoid function (including numerical protection against overflow/underflow).
[*]calculate_feature_importance: Computes relative feature importance (0.0 to 1.0) by aggregating the structural gain accumulated by each variable across the entire ensemble.

🔷 3. Static Quantile Pre-Binning
The find_split_subset_fast function and the initial training phase implement Static Quantile Pre-Binning: prior to boosting, historical feature values are sorted and binned into quantitative buckets. This dramatically accelerates the search for optimal split points during tree construction, significantly reducing computational overhead.

🔷 4. The Training Pipeline 
This is the core of the library, executing an iterative boosting loop that includes:
1. Row and Column Subsampling: Supports random sampling of instances and features to mitigate overfitting.
2. Gradient Computation: Computes first-order gradients and second-order Hessians based on binary cross-entropy loss.
3. Depth-3 Tree Construction: Progressively identifies optimal splits level by level using XGBoost regularization criteria.
4. Early Stopping & Validation: Automatically carves out a validation subset and halts training if the validation loss fails to improve over a specified number of rounds, subsequently rolling back to the optimal tree count.

🔷 Constraints to Consider

🔹 Architectural & Complexity Limitations (Fixed Depth of 3)
The tree is hardcoded with a fixed depth of 3 (XGBTreeDepth3), meaning it can evaluate a maximum of 3 levels of decisions (up to 8 terminal leaves). This can result in an inability to capture complex interactions. In financial markets, complex patterns often require deeper trees to combine multiple simultaneous conditions. A depth of 3 severely limits the learning capacity for advanced non-linear relationships.

🔹 Computational & Execution Limitations
Training a Gradient Boosting model requires a high volume of computations (nested loops for scanning matrices, calculating quantiles, sorting arrays, and evaluating gradients). Increasing the number of trees, feature matrix size, or number of bins too much will cause the script to abort due to exceeding the maximum execution loop limit allowed per single script (typically a few tens of thousands of operations before timing out).

Validation splits data by simply taking a portion of the rows. In financial time series, this can cause Data Leakage if training and validation data mix without strictly respecting the chronological sequence (the model might "peek" into the future if a Walk-Forward or Time-Series Split approach is not used).

Without a rigorous Out-Of-Sample (OOS) test set, a model trained directly on past prices will easily tend to find spurious correlations (market "noise" rather than real signals), failing miserably when applied to future real-time data.

🔹 Technical Rationale for Design Choices
There are very specific technical reasons why advanced features like dynamic Walk-Forward or continuous Rolling Retraining have not been natively integrated into this library:

[*]The Computational Bottleneck
A true Walk-Forward or Rolling Retraining (retraining the model bar-by-bar or across rolling time blocks) requires repeating the entire training process—quantile calculation, matrix scanning, iterative tree construction—hundreds or thousands of times on massive historical datasets. Continuous retraining would immediately trigger an Execution Timeout error.
[*]Memory & Historical Data Architecture
Managing matrices and historical arrays carries strict performance constraints. Accessing past data from hundreds of bars while applying complex temporal slicing logic rapidly consumes the heap memory allocated for the script, slowing down or freezing the chart.

This is why a "static and lightweight" approach was chosen for this library. The script trains the model once (or on a fixed portion of data) and leverages the speed of pre-compiled trees to perform real-time inference without exceeding computational limits.

---------------------------------------------------------------

Library  "XGBoostMini"
XGBoost Mini Library featuring Static Quantile Pre-Binning, Early Stopping, Subsampling, and Feature Importance.

method predict_tree(self, features)
  Evaluates the raw score (logit sum contribution) of a single depth-3 tree on a feature vector.
Traverses the binary decision tree hardcoded for 3 levels (up to 8 terminal leaves).
  Namespace types: XGBTreeDepth3
  Parameters:
    self (XGBTreeDepth3)
    features (array<float>)

predict_probability(model, features, learning_rate)
  Computes the final Sigmoid probability (0.0 to 1.0) by aggregating the boosted ensemble.
Applies learning rate scaling and numerical overflow/underflow clamping to the raw accumulated score.
  Parameters:
    model (XGBModel)
    features (array<float>)
    learning_rate (float)

calculate_feature_importance(model, n_features)
  Calculates relative Feature Importance (0.0 - 1.0) based on accumulated structural gain across the ensemble.
  Parameters:
    model (XGBModel)
    n_features (int)

train_model(X_matrix, y_target, num_trees, learning_rate, lambda_reg, quantile_bins, min_samples_split, subsample, colsample_bytree, val_ratio, patience)
  Main entry point to train the XGBoost ensemble.
Implements Static Quantile Pre-Binning, Row/Column Subsampling, Binary Cross-Entropy Loss, and Early Stopping.
  Parameters:
    X_matrix (matrix<float>)
    y_target (array<float>)
    num_trees (int)
    learning_rate (float)
    lambda_reg (float)
    quantile_bins (int)
    min_samples_split (int)
    subsample (float)
    colsample_bytree (float)
    val_ratio (float)
    patience (int)

XGBTreeDepth3
  XGBTreeDepth3
  Fields:
    f_r (series int)
    t_r (series float)
    g_r (series float)
    f_l (series int)
    t_l (series float)
    g_l (series float)
    f_right (series int)
    t_right (series float)
    g_right (series float)
    f_ll (series int)
    t_ll (series float)
    g_ll (series float)
    f_lr (series int)
    t_lr (series float)
    g_lr (series float)
    f_rl (series int)
    t_rl (series float)
    g_rl (series float)
    f_rr (series int)
    t_rr (series float)
    g_rr (series float)
    w0 (series float): to w7             Leaf node terminal weights (predictions) for all 8 possible regions of a depth-3 tree.
    w1 (series float)
    w2 (series float)
    w3 (series float)
    w4 (series float)
    w5 (series float)
    w6 (series float)
    w7 (series float)

XGBModel
  XGBModel
  Fields:
    ensemble (array<XGBTreeDepth3>): Array storing all trained XGBTreeDepth3 weak learners.
    best_val_loss (series float): Lowest validation loss achieved (used for tracking convergence).
    best_tree_count (series int): Optimal number of trees retained after early stopping.

---

## Source Code

````pine
//@version=6
// @description XGBoost Mini Library featuring Static Quantile Pre-Binning, Early Stopping, Subsampling, and Feature Importance.
library("XGBoostMini", overlay = false)

// 1. USER-DEFINED DATA TYPES (UDTs)
// @type XGBTreeDepth3
// @field f_r, t_r, g_r         Feature index, split threshold, and gain for the root node.
// @field f_l, t_l, g_l         Feature index, split threshold, and gain for the left child node (depth 1).
// @field f_right, t_right, g_right Feature index, split threshold, and gain for the right child node (depth 1).
// @field f_ll...              Feature indices, thresholds, and gains for the 4 leaf-parent nodes at depth 2.
// @field w0 to w7             Leaf node terminal weights (predictions) for all 8 possible regions of a depth-3 tree.
export type XGBTreeDepth3
    int   f_r
    float t_r
    float g_r
    int   f_l
    float t_l
    float g_l
    int   f_right
    float t_right
    float g_right
    int   f_ll
    float t_ll
    float g_ll
    int   f_lr
    float t_lr
    float g_lr
    int   f_rl
    float t_rl
    float g_rl
    int   f_rr
    float t_rr
    float g_rr
    float w0
    float w1
    float w2
    float w3
    float w4
    float w5
    float w6
    float w7

// @type XGBModel
// @field ensemble             Array storing all trained XGBTreeDepth3 weak learners.
// @field best_val_loss        Lowest validation loss achieved (used for tracking convergence).
// @field best_tree_count      Optimal number of trees retained after early stopping.
export type XGBModel
    array<XGBTreeDepth3> ensemble
    float                best_val_loss
    int                  best_tree_count

// @type SplitCandidate
// Internal UDT to evaluate feature splitting metrics during tree growth.
type SplitCandidate
    int   feature_idx
    float threshold
    float gain
    float weight_left
    float weight_right

// 2. INFERENCE & ANALYSIS METHODS
// @function Evaluates the raw score (logit sum contribution) of a single depth-3 tree on a feature vector.
// Traverses the binary decision tree hardcoded for 3 levels (up to 8 terminal leaves).
export method predict_tree(XGBTreeDepth3 self, array<float> features) =>
    float val_r = array.get(features, self.f_r)
    if val_r < self.t_r
        float val_l = array.get(features, self.f_l)
        if val_l < self.t_l
            float val_ll = array.get(features, self.f_ll)
            val_ll < self.t_ll ? self.w0 : self.w1
        else
            float val_lr = array.get(features, self.f_lr)
            val_lr < self.t_lr ? self.w2 : self.w3
    else
        float val_right = array.get(features, self.f_right)
        if val_right < self.t_right
            float val_rl = array.get(features, self.f_rl)
            val_rl < self.t_rl ? self.w4 : self.w5
        else
            float val_rr = array.get(features, self.f_rr)
            val_rr < self.t_rr ? self.w6 : self.w7

// @function Computes the final Sigmoid probability (0.0 to 1.0) by aggregating the boosted ensemble.
// Applies learning rate scaling and numerical overflow/underflow clamping to the raw accumulated score.
export predict_probability(XGBModel model, array<float> features, float learning_rate) =>
    float raw_score = 0.0
    int size = array.size(model.ensemble)
    if size > 0
        for i = 0 to size - 1
            XGBTreeDataObject = array.get(model.ensemble, i)
            raw_score += learning_rate * XGBTreeDataObject.predict_tree(features)
    // Numerical protection against math.exp overflow/underflow errors
    raw_score := math.max(-20.0, math.min(20.0, raw_score))
    1.0 / (1.0 + math.exp(-raw_score))

// @function Calculates relative Feature Importance (0.0 - 1.0) based on accumulated structural gain across the ensemble.
export calculate_feature_importance(XGBModel model, int n_features) =>
    array<float> importance = array.new_float(n_features, 0.0)
    float total_gain_all = 0.0
    int size = array.size(model.ensemble)

    if size > 0 and n_features > 0
        for i = 0 to size - 1
            tree = array.get(model.ensemble, i)
            if tree.f_r >= 0 and tree.f_r < n_features and tree.g_r > 0.0
                array.set(importance, tree.f_r, array.get(importance, tree.f_r) + tree.g_r)
            if tree.f_l >= 0 and tree.f_l < n_features and tree.g_l > 0.0
                array.set(importance, tree.f_l, array.get(importance, tree.f_l) + tree.g_l)
            if tree.f_right >= 0 and tree.f_right < n_features and tree.g_right > 0.0
                array.set(importance, tree.f_right, array.get(importance, tree.f_right) + tree.g_right)
            if tree.f_ll >= 0 and tree.f_ll < n_features and tree.g_ll > 0.0
                array.set(importance, tree.f_ll, array.get(importance, tree.f_ll) + tree.g_ll)
            if tree.f_lr >= 0 and tree.f_lr < n_features and tree.g_lr > 0.0
                array.set(importance, tree.f_lr, array.get(importance, tree.f_lr) + tree.g_lr)
            if tree.f_rl >= 0 and tree.f_rl < n_features and tree.g_rl > 0.0
                array.set(importance, tree.f_rl, array.get(importance, tree.f_rl) + tree.g_rl)
            if tree.f_rr >= 0 and tree.f_rr < n_features and tree.g_rr > 0.0
                array.set(importance, tree.f_rr, array.get(importance, tree.f_rr) + tree.g_rr)

        for f = 0 to n_features - 1
            total_gain_all += array.get(importance, f)

        if total_gain_all > 0.0
            for f = 0 to n_features - 1
                array.set(importance, f, array.get(importance, f) / total_gain_all)

    importance

// 3. INTERNAL SUPPORT FUNCTIONS
// @function Scans pre-calculated quantile thresholds across active feature subsets to find the optimal split point.
// Maximizes XGBoost structural gain reduction criteria regularized by lambda_reg.
find_split_subset_fast(
    matrix<float> global_thresholds, 
    matrix<float> X_matrix, 
    array<float>  g_arr, 
    array<float>  h_arr, 
    array<int>    subset_indices, 
    array<int>    active_features, 
    float         lambda_reg, 
    int           min_samples_split,
    int           quantile_bins
    ) =>
    
    SplitCandidate best_split = SplitCandidate.new(-1, 0.0, -1e9, 0.0, 0.0)
    int n_subset   = array.size(subset_indices)
    int n_active_f = array.size(active_features)
    
    if n_subset >= min_samples_split and n_active_f > 0
        float G_total = 0.0
        float H_total = 0.0
        for i = 0 to n_subset - 1
            int idx = array.get(subset_indices, i)
            G_total += array.get(g_arr, idx)
            H_total += array.get(h_arr, idx)
            
        float base_score = (G_total * G_total) / (H_total + lambda_reg)
        int min_half = math.max(1, math.floor(min_samples_split / 2))
        
        for f_i = 0 to n_active_f - 1
            int f = array.get(active_features, f_i)
            
            for t_idx = 0 to quantile_bins - 1
                float thresh = matrix.get(global_thresholds, f, t_idx)
                if thresh != 0.0
                    float GL = 0.0, HL = 0.0
                    float GR = 0.0, HR = 0.0
                    int countL = 0, countR = 0
                    
                    for i = 0 to n_subset - 1
                        int idx = array.get(subset_indices, i)
                        float v = matrix.get(X_matrix, idx, f)
                        float g = array.get(g_arr, idx)
                        float h = array.get(h_arr, idx)
                        if v < thresh
                            GL += g
                            HL += h
                            countL += 1
                        else
                            GR += g
                            HR += h
                            countR += 1
                            
                    if countL >= min_half and countR >= min_half
                        float scoreL = (GL * GL) / (HL + lambda_reg)
                        float scoreR = (GR * GR) / (HR + lambda_reg)
                        float gain   = 0.5 * (scoreL + scoreR - base_score)
                        
                        if gain > best_split.gain
                            best_split.gain        := gain
                            best_split.feature_idx  := f
                            best_split.threshold    := thresh
                            best_split.weight_left  := -GL / (HL + lambda_reg)
                            best_split.weight_right := -GR / (HR + lambda_reg)
                            
    best_split

// 4. MAIN TRAINING FUNCTION
// @function Main entry point to train the XGBoost ensemble.
// Implements Static Quantile Pre-Binning, Row/Column Subsampling, Binary Cross-Entropy Loss, and Early Stopping.
export train_model(
    matrix<float> X_matrix, 
    array<float>  y_target, 
    int   num_trees, 
    float learning_rate, 
    float lambda_reg, 
    int   quantile_bins, 
    int   min_samples_split,
    float subsample = 1.0,
    float colsample_bytree = 1.0,
    float val_ratio = 0.2,
    int   patience = 3
    ) =>

    array<XGBTreeDepth3> model_ensemble = array.new<XGBTreeDepth3>(0)
    int n_samples  = matrix.rows(X_matrix)
    int n_features = matrix.columns(X_matrix)
    
    float best_val_loss  = 1e9
    int   best_tree_size = 0
    
    if n_samples >= min_samples_split and n_features > 0
        int n_val   = (val_ratio > 0.0 and val_ratio < 0.5) ? math.floor(n_samples * val_ratio) : 0
        int n_train = n_samples - n_val

        // STATIC QUANTILE PRE-BINNING COMPUTATION
        matrix<float> global_thresholds = matrix.new<float>(n_features, quantile_bins, 0.0)
        
        for f = 0 to n_features - 1
            array<float> feat_vals = array.new_float(0)
            for i = 0 to n_train - 1
                array.push(feat_vals, matrix.get(X_matrix, i, f))
            array.sort(feat_vals)
            
            int n_bins = math.min(quantile_bins, n_train)
            if n_bins > 1
                for q = 1 to n_bins - 1
                    float pct = (q / float(n_bins)) * 100.0
                    float q_val = array.percentile_nearest_rank(feat_vals, pct)
                    matrix.set(global_thresholds, f, q - 1, q_val)

        array<float> F_preds_train = array.new_float(n_train, 0.0)
        array<float> F_preds_val   = array.new_float(n_val, 0.0)

        int no_improve_counter = 0

        float colsample_clamped = math.max(0.1, math.min(1.0, colsample_bytree))
        int num_sub_features    = math.max(1, math.floor(n_features * colsample_clamped))
        
        float subsample_clamped = math.max(0.1, math.min(1.0, subsample))
        int num_sub_samples     = math.max(min_samples_split, math.floor(n_train * subsample_clamped))

        // Sequential Boosting Loop
        for tree_idx = 1 to num_trees
            // 1. Column Subsampling (Feature Randomization)
            array<int> all_feats = array.new_int(n_features)
            for f = 0 to n_features - 1
                array.set(all_feats, f, f)
                
            array<int> active_features = array.new_int(0)
            for f = 0 to num_sub_features - 1
                int rand_pos = math.floor(math.random(f, n_features))
                int temp = array.get(all_feats, f)
                array.set(all_feats, f, array.get(all_feats, rand_pos))
                array.set(all_feats, rand_pos, temp)
                array.push(active_features, array.get(all_feats, f))

            // 2. Row Subsampling (Instance Randomization)
            array<int> all_train_indices = array.new_int(n_train)
            for i = 0 to n_train - 1
                array.set(all_train_indices, i, i)

            array<int> active_train_indices = array.new_int(0)
            for i = 0 to num_sub_samples - 1
                int rand_pos = math.floor(math.random(i, n_train))
                int temp = array.get(all_train_indices, i)
                array.set(all_train_indices, i, array.get(all_train_indices, rand_pos))
                array.set(all_train_indices, rand_pos, temp)
                array.push(active_train_indices, array.get(all_train_indices, i))

            // Calculate First and Second Order Gradients (First/Hessian) with Sigmoid Clamping Security
            array<float> g_arr = array.new_float(0)
            array<float> h_arr = array.new_float(0)
            
            for i = 0 to n_train - 1
                float raw_p = array.get(F_preds_train, i)
                raw_p := math.max(-20.0, math.min(20.0, raw_p))
                float p = 1.0 / (1.0 + math.exp(-raw_p))
                float y = array.get(y_target, i)
                array.push(g_arr, p - y)
                array.push(h_arr, math.max(p * (1.0 - p), 1e-6))
                
            // Build Depth-3 Tree Level by Level
            SplitCandidate r_split = find_split_subset_fast(global_thresholds, X_matrix, g_arr, h_arr, active_train_indices, active_features, lambda_reg, min_samples_split, quantile_bins)
            
            if r_split.feature_idx != -1
                array<int> idx_l = array.new_int(0)
                array<int> idx_r = array.new_int(0)
                for i = 0 to array.size(active_train_indices) - 1
                    int idx = array.get(active_train_indices, i)
                    if matrix.get(X_matrix, idx, r_split.feature_idx) < r_split.threshold
                        array.push(idx_l, idx)
                    else
                        array.push(idx_r, idx)
                
                SplitCandidate l_split = find_split_subset_fast(global_thresholds, X_matrix, g_arr, h_arr, idx_l, active_features, lambda_reg, min_samples_split, quantile_bins)
                SplitCandidate right_s = find_split_subset_fast(global_thresholds, X_matrix, g_arr, h_arr, idx_r, active_features, lambda_reg, min_samples_split, quantile_bins)
                
                array<int> idx_ll = array.new_int(0)
                array<int> idx_lr = array.new_int(0)
                array<int> idx_rl = array.new_int(0)
                array<int> idx_rr = array.new_int(0)
                
                for i = 0 to array.size(idx_l) - 1
                    int idx = array.get(idx_l, i)
                    int feat = l_split.feature_idx != -1 ? l_split.feature_idx : r_split.feature_idx
                    float th = l_split.feature_idx != -1 ? l_split.threshold    : r_split.threshold
                    if matrix.get(X_matrix, idx, feat) < th
                        array.push(idx_ll, idx)
                    else
                        array.push(idx_lr, idx)
                        
                for i = 0 to array.size(idx_r) - 1
                    int idx = array.get(idx_r, i)
                    int feat = right_s.feature_idx != -1 ? right_s.feature_idx : r_split.feature_idx
                    float th = right_s.feature_idx != -1 ? right_s.threshold    : r_split.threshold
                    if matrix.get(X_matrix, idx, feat) < th
                        array.push(idx_rl, idx)
                    else
                        array.push(idx_rr, idx)
                
                SplitCandidate ll_s = find_split_subset_fast(global_thresholds, X_matrix, g_arr, h_arr, idx_ll, active_features, lambda_reg, min_samples_split, quantile_bins)
                SplitCandidate lr_s = find_split_subset_fast(global_thresholds, X_matrix, g_arr, h_arr, idx_lr, active_features, lambda_reg, min_samples_split, quantile_bins)
                SplitCandidate rl_s = find_split_subset_fast(global_thresholds, X_matrix, g_arr, h_arr, idx_rl, active_features, lambda_reg, min_samples_split, quantile_bins)
                SplitCandidate rr_s = find_split_subset_fast(global_thresholds, X_matrix, g_arr, h_arr, idx_rr, active_features, lambda_reg, min_samples_split, quantile_bins)
                
                float w0 = ll_s.feature_idx != -1 ? ll_s.weight_left  : (l_split.feature_idx != -1 ? l_split.weight_left  : r_split.weight_left)
                float w1 = ll_s.feature_idx != -1 ? ll_s.weight_right : (l_split.feature_idx != -1 ? l_split.weight_left  : r_split.weight_left)
                float w2 = lr_s.feature_idx != -1 ? lr_s.weight_left  : (l_split.feature_idx != -1 ? l_split.weight_right : r_split.weight_left)
                float w3 = lr_s.feature_idx != -1 ? lr_s.weight_right : (l_split.feature_idx != -1 ? l_split.weight_right : r_split.weight_left)
                
                float w4 = rl_s.feature_idx != -1 ? rl_s.weight_left  : (right_s.feature_idx != -1 ? right_s.weight_left  : r_split.weight_right)
                float w5 = rl_s.feature_idx != -1 ? rl_s.weight_right : (right_s.feature_idx != -1 ? right_s.weight_left  : r_split.weight_right)
                float w6 = rr_s.feature_idx != -1 ? rr_s.weight_left  : (right_s.feature_idx != -1 ? right_s.weight_right : r_split.weight_right)
                float w7 = rr_s.feature_idx != -1 ? rr_s.weight_right : (right_s.feature_idx != -1 ? right_s.weight_right : r_split.weight_right)

                XGBTreeDepth3 tree = XGBTreeDepth3.new()
                tree.f_r        := r_split.feature_idx
                tree.t_r        := r_split.threshold
                tree.g_r        := math.max(0.0, r_split.gain)

                tree.f_l        := l_split.feature_idx != -1 ? l_split.feature_idx : r_split.feature_idx
                tree.t_l        := l_split.feature_idx != -1 ? l_split.threshold : 0.0
                tree.g_l        := math.max(0.0, l_split.gain)

                tree.f_right    := right_s.feature_idx != -1 ? right_s.feature_idx : r_split.feature_idx
                tree.t_right    := right_s.feature_idx != -1 ? right_s.threshold : 0.0
                tree.g_right    := math.max(0.0, right_s.gain)

                tree.f_ll       := ll_s.feature_idx != -1 ? ll_s.feature_idx : r_split.feature_idx
                tree.t_ll       := ll_s.feature_idx != -1 ? ll_s.threshold : 0.0
                tree.g_ll       := math.max(0.0, ll_s.gain)

                tree.f_lr       := lr_s.feature_idx != -1 ? lr_s.feature_idx : r_split.feature_idx
                tree.t_lr       := lr_s.feature_idx != -1 ? lr_s.threshold : 0.0
                tree.g_lr       := math.max(0.0, lr_s.gain)

                tree.f_rl       := rl_s.feature_idx != -1 ? rl_s.feature_idx : r_split.feature_idx
                tree.t_rl       := rl_s.feature_idx != -1 ? rl_s.threshold : 0.0
                tree.g_rl       := math.max(0.0, rl_s.gain)

                tree.f_rr       := rr_s.feature_idx != -1 ? rr_s.feature_idx : r_split.feature_idx
                tree.t_rr       := rr_s.feature_idx != -1 ? rr_s.threshold : 0.0
                tree.g_rr       := math.max(0.0, rr_s.gain)

                tree.w0         := w0
                tree.w1         := w1
                tree.w2         := w2
                tree.w3         := w3
                tree.w4         := w4
                tree.w5         := w5
                tree.w6         := w6
                tree.w7         := w7

                array.push(model_ensemble, tree)
                
                // Update Training Predictions
                for i = 0 to n_train - 1
                    array.set(F_preds_train, i, array.get(F_preds_train, i) + (learning_rate * tree.predict_tree(matrix.row(X_matrix, i))))

                // Validation & Early Stopping Step
                if n_val > 0
                    float current_val_loss = 0.0
                    
                    for i = 0 to n_val - 1
                        int val_idx = n_train + i
                        float new_pred = array.get(F_preds_val, i) + (learning_rate * tree.predict_tree(matrix.row(X_matrix, val_idx)))
                        array.set(F_preds_val, i, new_pred)
                        
                        float clamped_pred = math.max(-20.0, math.min(20.0, new_pred))
                        float p_val = math.max(1e-6, math.min(1.0 - 1e-6, 1.0 / (1.0 + math.exp(-clamped_pred))))
                        float y_val = array.get(y_target, val_idx)
                        current_val_loss += -(y_val * math.log(p_val) + (1.0 - y_val) * math.log(1.0 - p_val))
                    
                    current_val_loss := current_val_loss / float(n_val)

                    if current_val_loss < best_val_loss
                        best_val_loss      := current_val_loss
                        best_tree_size     := array.size(model_ensemble)
                        no_improve_counter := 0
                    else
                        no_improve_counter += 1
                        if no_improve_counter >= patience
                            break
            else
                break

        // Automatic Rollback to optimal iteration based on Early Stopping
        if n_val > 0 and best_tree_size > 0
            while array.size(model_ensemble) > best_tree_size
                array.pop(model_ensemble)
        else if n_val == 0
            best_tree_size := array.size(model_ensemble)

    XGBModel.new(model_ensemble, best_val_loss, best_tree_size)
````
