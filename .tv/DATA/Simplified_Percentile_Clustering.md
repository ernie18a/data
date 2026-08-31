<!-- tradingview-pine-id: PUB;53c863aae2cd439a9d1a24612b29c3d3 -->
<!-- tradingviewscripts-format: 1 -->
# Simplified Percentile Clustering

Source: https://www.tradingview.com/script/mdGJq4j5-Simplified-Percentile-Clustering/

## Description

Simplified Percentile Clustering (SPC) is a clustering system for trend regime analysis.
 Instead of relying on heavy iterative algorithms such as k-means, SPC takes a deterministic approach: it uses percentiles and running averages to form cluster centers directly from the data, producing smooth, interpretable market state segmentation that updates live with every bar.

Most clustering algorithms are designed for offline datasets, they require recomputation, multiple iterations, and fixed sample sizes.
SPC borrows from both statistical normalization and distance-based clustering theory, but simplifies them. Percentiles ensure that cluster centers are resistant to outliers, while the running mean provides a stable mid-point reference.
Unlike iterative methods, SPC’s centers evolve smoothly with time, ideal for charts that must update in real time without sudden reclassification noise.
SPC provides a simple yet powerful clustering heuristic that:

[*]Runs continuously in a charting environment,
[*]Remains interpretable and reproducible,
[*]And allows traders to see how close the current market state is to transitioning between regimes.

Clustering by Percentiles

Traditional clustering methods find centers through iteration. SPC defines them deterministically using three simple statistics within a moving window:

[*]Lower percentile (p_low) → captures the lower basin of feature values.
[*]Upper percentile (p_high) → captures the upper basin.
[*]Mean (mid) → represents the central tendency.

From these, SPC computes stable “centers”:
[pine]// K = 2 → two regimes (e.g., bullish / bearish)
[k0, k1] = [avg(low_pct, mid), avg(high_pct, mid)]
// K = 3 → adds a neutral zone
[k0, k1, k2] = [avg(low_pct, mid), mid, avg(high_pct, mid)][/pine]

These centers move gradually with the market, forming live regime boundaries without ever needing convergence steps.
[image]https://www.tradingview.com/x/RF7WLhW6/[/image]
Two clusters capture directional bias; three clusters add a neutral ‘range’ state.

Multi-Feature Fusion

While SPC can cluster a single feature such as RSI, CCI, Fisher Transform, DMI, Z-Score, or the price-to-MA ratio (MAR), its real strength lies in feature fusion. Each feature adds a unique lens to the clustering system. By toggling features on or off, traders can test how each dimension contributes to the regime structure.
In “Clusters” mode, SPC measures how far the current bar is from each cluster center across all enabled features, averages these distances, and assigns the bar to the nearest combined center. This effectively creates a multi-dimensional regime map, where each feature contributes equally to defining the overall market state.

The fusion distance is computed as:
[pine]dist := (rsi_d * on_off(use_rsi) + cci_d * on_off(use_cci) + fis_d * on_off(use_fis) + dmi_d * on_off(use_dmi) + zsc_d * on_off(use_zsc) + mar_d * on_off(use_mar)) / (on_off(use_rsi) + on_off(use_cci) + on_off(use_fis) + on_off(use_dmi) + on_off(use_zsc) + on_off(use_mar))[/pine]

Because each feature can be standardized (Z-Score), the distances remain comparable across different scales.

[image]https://www.tradingview.com/x/nzA5cfr6/[/image]
Fusion mode combines multiple standardized features into a single smooth regime signal.

Visualizing Proximity - The Transition Gradient

Most indicators show binary or discrete conditions (e.g., bullish/bearish). SPC goes further, it quantifies how close the current value is to flipping into the next cluster.
It measures the distances to the two nearest cluster centers and interpolates between them:
[pine]rel_pos = min_dist / (min_dist + second_min_dist)
real_clust = cluster_val + (second_val - cluster_val) * rel_pos[/pine]

This real_clust output forms a continuous line that moves smoothly between clusters:

[*]Near 0.0 → firmly within the current regime
[*]Around 0.5 → balanced between clusters (transition zone)
[*]Near 1.0 → about to flip into the next regime

[image]https://www.tradingview.com/x/UAmPOjhe/[/image]
Smooth interpolation reveals when the market is close to a regime change.

How to Tune the Parameters
SPC includes intuitive parameters to adapt sensitivity and stability:

[*]K Clusters (2–3): Defines the number of regimes. K = 2 for trend/range distinction, K = 3 for trend/neutral transitions.
[*]Lookback: Determines the number of past bars used for percentile and mean calculations. Higher = smoother, more stable clusters. Lower = faster reaction to new trends.
[*]Lower / Upper Percentiles: Define what counts as “low” and “high” states. Adjust to widen or tighten cluster ranges.

[image]https://www.tradingview.com/x/e0AQ8uhI/[/image]
Shorter lookbacks react quickly to shifts; longer lookbacks smooth the clusters.

Visual Interpretation

In “Clusters” mode, SPC plots:

[*]A colored histogram for each cluster (red, orange, green depending on K)
[*]Horizontal guide lines separating cluster levels
[*]Smooth proximity transitions between states

Each bar’s color also changes based on its assigned cluster, allowing quick recognition of when the market transitions between regimes.

[image]https://www.tradingview.com/x/cmsLVUVN/[/image]
Cluster bands visualize regime structure and transitions at a glance.

Practical Applications

[*]Identify market regimes (bullish, neutral, bearish) in real time
[*]Detect early transition phases before a trend flip occurs
[*]Fuse multiple indicators into a single consistent signal
[*]Engineer interpretable features for machine-learning research
[*]Build adaptive filters or hybrid signals based on cluster proximity

Final Notes
Simplified Percentile Clustering (SPC) provides a balance between mathematical rigor and visual intuition. It replaces complex iterative algorithms with a clear, deterministic logic that any trader can understand, and yet retains the multidimensional insight of a fusion-based clustering system.
Use SPC to study how different indicators align, how regimes evolve, and how transitions emerge in real time. It’s not about predicting; it’s about seeing the structure of the market unfold.

Disclaimer

[*]This indicator is intended for educational and analytical use.
[*]It does not generate buy or sell signals.
[*]Historical regime transitions are not indicative of future performance.
[*]Always validate insights with independent analysis before making trading decisions.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © InvestorUnknown
//
//                                                                                  {||}                   
//                                                       ,                          {||}          
//                                                  ,,,,,                           {||}
//                                                ,,,,,       ,       ,,            {||}       
//                                    ,         ,,,, ,       ,,     ,,,             {||}       
//             .                   , ,         ,,,,  ,     ,,,,   .,,               {||}            ╔╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╗
//             ,,                 ,       ,,   ,,,,,,,  ,  ,      ,                 {||}            ╠╬╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╬╣  
//             ,,                 ,,   ,  ,,  ,,,,,, ,,,,    , ,                    {||}            ╠╣  /$$$$$$                                           /$$                         ╠╣
//              .,         ,      ,,,  ,,,,,,,,,,,,,, ,,  ,,  , ,         ,,        {||}            ╠╣ |_  $$_/                                          | $$                         ╠╣
//                           ,  .  ,, ,,,,,,,,,,,,, ,    ,,, , ,,    ,   ,          {||}            ╠╣   | $$   /$$$$$$$  /$$    /$$ /$$$$$$   /$$$$$$$ /$$$$$$    /$$$$$$   /$$$$$$  ╠╣
//                   ,,           ,,, ,,,,,,,,,,,,,,,,,,,,,,  ,,,   ,,              {||}            ╠╣   | $$  | $$__  $$|  $$  /$$//$$__  $$ /$$_____/|_  $$_/   /$$__  $$ /$$__  $$ ╠╣
//               , ,   ,,,     .,,,,,,,,,,,, ,,,  ,,,,,,,,   ,,,    ,,              {||}            ╠╣   | $$  | $$  \ $$ \  $$/$$/| $$$$$$$$|  $$$$$$   | $$    | $$  \ $$| $$  \__/ ╠╣      
//         .,     , ,,  ,,    ,,, ,,,,,,, ,,  ,,, ,,,,, ,,, ,  ,,   ,,              {||}            ╠╣   | $$  | $$  | $$  \  $$$/ | $$_____/ \____  $$  | $$ /$$| $$  | $$| $$       ╠╣     
//            ,   ,,,,,  ,    ,,,, ,, , ,,,,,,,,,,,,,,,,,,,,,, ,,  ,,               {||}            ╠╣  /$$$$$$| $$  | $$   \  $/  |  $$$$$$$ /$$$$$$$/  |  $$$$/|  $$$$$$/| $$       ╠╣   
//               .    //./ /// ,,,,,,,,,,,,,,,. ,,,,,,,,,,,,,,,,,,                  {||}            ╠╣ |______/|__/  |__/    \_/    \_______/|_______/    \___/   \______/ |__/       ╠╣
//                ,  /         ,., ,,,,,,,,,,, ,,,,,,,   ,,,,,,,                    {||}            ╠╣                                                                                ╠╣
//            .  ,,,  ,/ ///./   ,,,.,,,,,,,,,,,,,,,      ,, , ,                    {||}            ╠╣                                                                                ╠╣
//             ,,,,,,  //./ , /    .,,.,,, ,,,,,, ,.     ,,,,,,,                    {||}            ╠╣                                                                                ╠╣
//              ,,,,   //  *, / / ,,,,,,,,,,,,          ,, ,,,,,                    {||}            ╠╣    /$$   /$$           /$$                                                     ╠╣
//               ,,  // ////.*/// / ,.,,,,,.,, ,,  ,,,, ,,,,,,                      {||}            ╠╣   | $$  | $$          | $$                                                     ╠╣
//                   ,  /////    //  , ,,,,,, ,,,, ,,,,,  ,,, / /.                  {||}            ╠╣   | $$  | $$ /$$$$$$$ | $$   /$$ /$$$$$$$   /$$$$$$  /$$  /$$  /$$ /$$$$$$$    ╠╣
//              ,,   ,         ////// ,,,,,,,,,  ,,,,,,,,/ ///  / //                {||}            ╠╣   | $$  | $$| $$__  $$| $$  /$$/| $$__  $$ /$$__  $$| $$ | $$ | $$| $$__  $$   ╠╣
//                         ///// .// ,,,,,,  ,, ,,,, ,,, ///*  //*///               {||}            ╠╣   | $$  | $$| $$  \ $$| $$$$$$/ | $$  \ $$| $$  \ $$| $$ | $$ | $$| $$  \ $$   ╠╣
//                           //  .           ,, .// ,,      ///, ///                {||}            ╠╣   | $$  | $$| $$  | $$| $$_  $$ | $$  | $$| $$  | $$| $$ | $$ | $$| $$  | $$   ╠╣
//                        //////        ,,,,    ///// ,.        ,                   {||}            ╠╣   |  $$$$$$/| $$  | $$| $$ \  $$| $$  | $$|  $$$$$$/|  $$$$$/$$$$/| $$  | $$   ╠╣
//                   *///////. //              /  */////*                           {||}            ╠╣    \______/ |__/  |__/|__/  \__/|__/  |__/ \______/  \_____/\___/ |__/  |__/   ╠╣ 
//                         .,,  // ,,,,,,,,,, //* ,,,  //////                       {||}            ╠╬╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╦╬╣
//                           ,,,,,   ,,,,,, ,.,,,,,,,                               {||}            ╚╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╝
//                               ,,,,,,,,,,,, ,,                                    {||}          
//                                  ,,,,,,,,,                                       {||}                                                                                                                                  
//                                                                                  {||} 
//                                                                                  {||} 
//
// Indicator Overview
// ------------------
//   A compact, streaming-friendly clustering heuristic intended for trend analysis.
//   It computes simple "cluster centers" per feature using percentiles and the
//   running mean, then assigns each bar to the closest center. Optionally, in
//   "Clusters" (combined) mode it fuses distances across multiple features to
//   compute a multi-dimensional proximity / cluster assignment.
//
// Key design decisions:
//   - K limited to 2 or 3 for stability and interpretability.
//   - Uses percentiles (lower/upper) + running mean to form deterministic centers
//     — a light-weight alternative to iterative clustering (k-means) that is
//     streaming-friendly and cheap to compute.
//   - Allows selective feature fusion (binary on/off) for combined distance.
//   - Produces a `real_clust` value that smoothly interpolates between centers
//     (useful for visualizing 'proximity-to-flip').
//
// Notes:
//   - This is NOT k-means. It's a percentile + mean center heuristic designed to
//     favor stability and low compute on live series.
//   - Good for feature engineering and visual regime detection. If you need
//     centroid updates based on iterative assignment, consider a k-means
//     adaptation (outside the scope of this simplified heuristic).
//
// ----------------------------------------------------------------------------
//@version=6
indicator("Simplified Percentile Clustering", "SPC", overlay = false, max_lines_count=500, max_labels_count=500)

//-#-#-#-#-#- STRINGS -#-#-#-#-#- {
var string g1           = "Feature Settings"
var string g2           = "Clustering Settings"
var string g3           = "Plot Settings"

var string k_tip        = "Number of cluster centers to derive per feature. Each cluster represents a distinct regime.
 Limiting K to 2 or 3 ensures computational stability and interpretability. \n
 Typical values:\n • 2 → Binary states (e.g., Long vs. Short)\n • 3 → Adds a neutral/mid cluster."
var string lookback_tip = "Number of historical bars used for percentile and mean calculations. Controls how far back the algorithm looks when
 estimating cluster centers. Higher values = smoother, more stable clusters; Lower values = faster response to regime changes."
var string p_low_tip    = "Defines the lower boundary of the distribution used to determine
 the lowest cluster center. Increase to make clusters less sensitive to extreme low values."
var string p_high_tip   = "Defines the upper boundary of the distribution used to determine
 the highest cluster center. Decrease to make clusters less sensitive to extreme high values."
var string plot_tip     = "Select which feature or output to visualize:\n
 • Clusters → Combined multi-feature fusion mode showing overall regime proximity.\n
 • RSI, CCI, Fisher, DMI, Z-Score, MAR → Single-feature clustering view.\n
 Use 'Clusters' mode to see how multiple standardized features collectively define regime transitions."
//}

//-#-#-#-#-#- INPUTS -#-#-#-#-#- {
// For each feature the user can enable/disable it and choose whether to
// standardize it using a rolling Z-score (based on `lookback`). Standardizing
// makes features comparable when fused.
use_rsi = input.bool(true, "Use?", group = g1, inline = "L1"), rsi_len = input.int(14, "RSI Length",     group = g1, inline = "L1"), rsi_t = input.bool(true, "Standardize", group = g1, inline = "L1")
use_cci = input.bool(true, "Use?", group = g1, inline = "L2"), cci_len = input.int(20, "CCI Length",     group = g1, inline = "L2"), cci_t = input.bool(true, "Standardize", group = g1, inline = "L2")
use_fis = input.bool(true, "Use?", group = g1, inline = "L3"), fis_len = input.int(9, "Fisher Length",   group = g1, inline = "L3"), fis_t = input.bool(true, "Standardize", group = g1, inline = "L3")
use_dmi = input.bool(true, "Use?", group = g1, inline = "L4"), dmi_len = input.int(9, "DMI Length",      group = g1, inline = "L4"), dmi_t = input.bool(true, "Standardize", group = g1, inline = "L4")
use_zsc = input.bool(true, "Use?", group = g1, inline = "L5"), zsc_len = input.int(20, "Z-Score Length", group = g1, inline = "L5")
use_mar = input.bool(true, "Use?", group = g1, inline = "L6"), mar_len = input.int(14, "MA Length",      group = g1, inline = "L6"), 
 ma_type = input.string("SMA", "", options = ["SMA", "EMA"], group = g1, inline = "L6"), mar_t = input.bool(true, "Standardize", group = g1, inline = "L6")

// --- Clustering parameters ---
// k: number of cluster centers (2 or 3). Lookback: how many historical values are
// kept for percentile/median calculations. Percentiles determine lower/upper
// thresholds from which centers are derived.
simple int k        = input.int(2, "K Clusters", minval=2, maxval=3, group = g2, tooltip = k_tip)
simple int lookback = input.int(1000, "Lookback",                    group = g2, tooltip = lookback_tip)
simple float p_low  = input.float(5.0, "Lower Percentile",           group = g2, tooltip = p_low_tip)
simple float p_high = input.float(95.0, "Upper Percentile",          group = g2, tooltip = p_high_tip)

// --- Plot control ---
// main_plot: which series to visualize. "Clusters" activates the combined
// multi-indicator clustering visualization (the fusion behavior).
simple string main_plot = input.string("Clusters", "Main Plot", options = ["Clusters", "RSI", "CCI", "Fisher", "DMI", "Z-Score", "MAR"], group = g3, tooltip = plot_tip)
simple bool   plot_cl   = input.bool(false, "Plot Cluster Line", group = g3)
//}

//-#-#-#-#-#- HELPER FUNCTIONS -#-#-#-#-#- {

// z_score: rolling z-score standardization.
z_score(src, length) =>
    mean    = ta.sma(src, length)
    stdev   = ta.stdev(src, length)
    (src - mean) / stdev

// get_percentile: returns the value at `pct` percentile from a sorted array.
// Implementation note: the script stores the sliding values in an array, sorts a
// copy and then chooses index floor((n-1)*pct/100). This is a deterministic
// and inexpensive approximation when interpolation isn't required.
get_percentile(arr, pct) =>
    sz      = array.size(arr)
    if sz == 0
        na
    else
        idx = math.floor((sz - 1) * pct / 100)
        array.get(arr, idx)

// round_: safe clamp used by the fisher transform helper to avoid infinite
round_(val) => val > .99 ? .999 : val < -.99 ? -.999 : val

// fisher: fisher transform applied to hl2 over `len` bars.
fisher(len) =>
    high_   = ta.highest(hl2, len)
    low_    = ta.lowest(hl2, len)
    value   = 0.0
    value   := round_(.66 * ((hl2 - low_) / (high_ - low_) - .5) + .67 * nz(value[1]))
    fish1   = 0.0
    fish1   := .5 * math.log((1 + value) / (1 - value)) + .5 * nz(fish1[1])

// dmi_difference: simplified DMI difference that returns (plus - minus).
dmi_difference(len) =>
    up      = ta.change(high)
    down    = -ta.change(low)
    plusDM  = na(up) ? na : (up > down and up > 0 ? up : 0)
    minusDM = na(down) ? na : (down > up and down > 0 ? down : 0)
    trur    = ta.rma(ta.tr, len)
    plus    = fixnan(100 * ta.rma(plusDM, len) / trur)
    minus   = fixnan(100 * ta.rma(minusDM, len) / trur)
    diff    = plus - minus

// on_off: convert boolean to 1/0 for weighted averaging in the combined distance.
on_off(bool t_f) =>
    out     = t_f ? 1 : 0
//}

//-#-#-#-#-#- FEATURE CALCULATIONS -#-#-#-#-#- {
// For each feature we compute either the raw value or the standardized (z-score)
// variant depending on the user's toggle. When standardizing we use the same
// `lookback` as used for percentile center computation so the comparability is
// consistent across features.

rsi         = ta.rsi(close, rsi_len)
rsi_z       = z_score(rsi, lookback)
rsi_val     = rsi_t ? rsi_z : rsi

cci         = ta.cci(close, cci_len)
cci_z       = z_score(cci, lookback)
cci_val     = cci_t ? cci_z : cci

fisher      = fisher(fis_len)
fisher_z    = z_score(fisher, lookback)
fisher_val  = fis_t ? fisher_z : fisher

dmi         = dmi_difference(dmi_len)
dmi_z       = z_score(dmi, lookback)
dmi_val     = dmi_t ? dmi_z : dmi

zsc_val     = z_score(close, zsc_len)   // z-score of price itself (rolling)

ma          = switch ma_type
    "SMA" => ta.sma(close, mar_len)
    "EMA" => ta.ema(close, mar_len)
mar         = close / ma                // price normalized by moving average
mar_z       = z_score(mar, lookback)
mar_val     = mar_t ? mar_z : mar
//}

//-#-#-#-#-#- BUILD & SORT PER-FEATURE ARRAYS -#-#-#-#-#- {
// get_centers: builds a sliding array of historical values for a single
// feature, sorts it (copy), computes lower/upper percentiles and a center
// near the mean. Then derives k centers as:
//   k=2 -> [avg(low_pct, mean), avg(high_pct, mean)]
//   k=3 -> [avg(low_pct, mean), mean, avg(high_pct, mean)]
//
// Rationale:
//   - The lower percentile captures the 'lower basin' of the distribution,
//     the upper percentile the 'upper basin', and the mean approximates a
//     central tendency. Averaging them produces stable and interpretable centers
//     that do not rely on iterative centroid updates.
get_centers(x, lookback, p_high, p_low, k) =>
    var float[] x_arr = array.new_float()
    array.push(x_arr, x)

    // keep array within lookback window
    if array.size(x_arr) > lookback
        array.shift(x_arr)

    // work on a copy to preserve the primary array's insertion order
    x_sorted    = array.copy(x_arr), array.sort(x_sorted)

    x_high      = get_percentile(x_sorted, p_high)
    x_low       = get_percentile(x_sorted, p_low)
    x_mid       = ta.sma(x, lookback)

    x_k0_center = math.avg(x_low, x_mid)
    x_k1_center = math.avg(x_high, x_mid)

    x_centers   = switch k
        2 => array.from(x_k0_center, x_k1_center)
        3 => array.from(x_k0_center, x_mid, x_k1_center)

    x_centers

// compute centers for each feature
rsi_centers = get_centers(rsi_val, lookback, p_high, p_low, k)
cci_centers = get_centers(cci_val, lookback, p_high, p_low, k)
fis_centers = get_centers(fisher_val, lookback, p_high, p_low, k)
dmi_centers = get_centers(dmi_val, lookback, p_high, p_low, k)
zsc_centers = get_centers(zsc_val, lookback, p_high, p_low, k)
mar_centers = get_centers(mar_val, lookback, p_high, p_low, k)
//}

//-#-#-#-#-#- ASSIGN NEAREST CENTER -#-#-#-#-#- {
var string[] cluster_names = array.from("k0", "k1", "k2")

// Pick which feature / centers to visualize based on `main_plot`.
// If main_plot == "Clusters" we operate in combined (multi-feature fusion) mode.
// For single-feature modes, `src_val` is set to that feature value and `centers`
// to its corresponding centers.
float[] centers = na
float src_val   = na

if main_plot == "RSI"
    centers := rsi_centers
    src_val := rsi_val
else if main_plot == "CCI"
    centers := cci_centers
    src_val := cci_val
else if main_plot == "Fisher"
    centers := fis_centers
    src_val := fisher_val
else if main_plot == "DMI"
    centers := dmi_centers
    src_val := dmi_val
else if main_plot == "Z-Score"
    centers := zsc_centers
    src_val := zsc_val
else if main_plot == "MAR"
    centers := mar_centers
    src_val := mar_val
else  // "Clusters" = combined mode
    // base loop reference to make the loop boundaries come from one center array
    centers := rsi_centers
    src_val := na  // placeholder — combined mode computes distances from all features


// initialize distance trackers for picking the closest and second-closest centers
float min_dist          = na
float second_min_dist   = na
string curr_cluster     = na
string second_cluster   = na

// Core loop: compute distance from `src` to each candidate center. In single-
// feature modes we compute the simple absolute difference. In combined mode we
// compute average of feature-wise absolute diffs for selected features.
//
// Important: the combined distance is a fusion of normalized feature distances
// using binary (on/off) weighting derived from `use_*` toggles. This is simple
// and interpretable: chosen features equally influence the fused distance.
for i = 0 to array.size(centers) - 1
    float dist = na

    if main_plot == "RSI"
        dist := math.abs(rsi_val - array.get(rsi_centers, i))
    else if main_plot == "CCI"
        dist := math.abs(cci_val - array.get(cci_centers, i))
    else if main_plot == "Fisher"    
        dist := math.abs(fisher_val - array.get(fis_centers, i))
    else if main_plot == "DMI"
        dist := math.abs(dmi_val - array.get(dmi_centers, i))
    else if main_plot == "Z-Score"
        dist := math.abs(zsc_val - array.get(zsc_centers, i))
    else if main_plot == "MAR"
        dist := math.abs(mar_val - array.get(mar_centers, i))

    else // "Clusters" = combined RSI + CCI + ... distance fusion
        // compute per-feature absolute distances to that feature's center
        rsi_d = math.abs(rsi_val - array.get(rsi_centers, i))
        cci_d = math.abs(cci_val - array.get(cci_centers, i))
        fis_d = math.abs(fisher_val - array.get(fis_centers, i))
        dmi_d = math.abs(dmi_val - array.get(dmi_centers, i))
        zsc_d = math.abs(zsc_val - array.get(zsc_centers, i))
        mar_d = math.abs(mar_val - array.get(mar_centers, i))

        // fused distance: weighted average using on_off toggles as weights.
        // Denominator ensures proper averaging for the number of enabled features.
        dist := (rsi_d * on_off(use_rsi) + cci_d * on_off(use_cci) + fis_d * on_off(use_fis) + dmi_d * on_off(use_dmi) + zsc_d * on_off(use_zsc) + mar_d * on_off(use_mar)) / 
         (on_off(use_rsi) + on_off(use_cci) + on_off(use_fis) + on_off(use_dmi) + on_off(use_zsc) + on_off(use_mar))

    // Maintain the two smallest distances so we can compute relative proximity
    if na(min_dist) or dist < min_dist
        second_min_dist := min_dist
        second_cluster  := curr_cluster

        min_dist        := dist
        curr_cluster    := array.get(cluster_names, i)
    else if na(second_min_dist) or dist < second_min_dist
        second_min_dist := dist
        second_cluster  := array.get(cluster_names, i)


// numeric cluster index (0/1/2) for plotting discrete cluster bands
cluster_val     = curr_cluster == "k0" ? 0 : curr_cluster == "k1" ? 1 : curr_cluster == "k2" ? 2 : na

// Compute normalized proximity between the closest and second closest cluster:
// rel_pos = min_dist / (min_dist + second_min_dist)
// Interpretation:
//   - rel_pos → 0 : current point is very near the chosen (closest) center.
//   - rel_pos → 0.5 : equidistant between chosen and second center (ambiguous).
//   - rel_pos → 1 : nearer to second center than chosen.
// If second_min_dist == 0 we treat rel_pos as 0 to avoid division by zero.
rel_pos         = second_min_dist == 0 ? 0 : min_dist / (min_dist + second_min_dist)

// second cluster numeric index
second_val      = second_cluster == "k0" ? 0 : second_cluster == "k1" ? 1 : 2

// real_clust: a continuous interpolation between the two nearest cluster indices.
// This produces a visually smooth 'track' between centers and helps show how
// close the current point is to flipping cluster.
real_clust      = cluster_val + (second_val - cluster_val) * rel_pos
//}

//-#-#-#-#-#- PLOTTING & COLORS -#-#-#-#-#- {
// get_color: returns plotting color per cluster. Uses k to decide color layout.
// We choose muted transparencies for nice overlay visuals on charts.
get_color(curr_cluster, k) =>
    if k == 2
        curr_color = switch curr_cluster
            "k0" => color.new(color.red, 20)
            "k1" => color.new(color.green, 20)
            => color.new(color.gray, 80)
        curr_color
    else
        curr_color = switch curr_cluster
            "k0" => color.new(color.red, 20)
            "k1" => color.new(color.orange, 20)
            "k2" => color.new(color.green, 20)
            => color.new(color.gray, 80)
        curr_color

curr_color  = get_color(curr_cluster, k)

// plot_val: series to draw depending on main_plot mode. In "Clusters" mode we
// draw `real_clust` (the interpolated numeric representation). For single
// feature modes we draw the raw/standardized feature value itself.
plot_val    = switch main_plot
    "Clusters" => real_clust
    "RSI" => rsi_val
    "CCI" => cci_val
    "Fisher" => fisher_val
    "DMI" => dmi_val
    "Z-Score" => zsc_val
    "MAR" => mar_val
// For visualization we also expose the individual cluster centers as step-plots
// so the user can see how the center levels evolve over time.
plot_k0_center = switch main_plot
    "Clusters" => 0
    "RSI" => array.get(rsi_centers, 0)
    "CCI" => array.get(cci_centers, 0)
    "Fisher" => array.get(fis_centers, 0)
    "DMI" => array.get(dmi_centers, 0)
    "Z-Score" => array.get(zsc_centers, 0)
    "MAR" => array.get(mar_centers, 0)
plot_k1_center = switch main_plot
    "Clusters" => 1
    "RSI" => array.get(rsi_centers, 1)
    "CCI" => array.get(cci_centers, 1)
    "Fisher" => array.get(fis_centers, 1)
    "DMI" => array.get(dmi_centers, 1)
    "Z-Score" => array.get(zsc_centers, 1)
    "MAR" => array.get(mar_centers, 1)
plot_k2_center = switch main_plot
    "Clusters" => k > 2 ? 2 : 0
    "RSI" => k > 2 ? array.get(rsi_centers, 2) : na
    "CCI" => k > 2 ? array.get(cci_centers, 2) : na
    "Fisher" => k > 2 ? array.get(fis_centers, 2) : na
    "DMI" => k > 2 ? array.get(dmi_centers, 2) : na
    "Z-Score" => k > 2 ? array.get(zsc_centers, 2) : na
    "MAR" => k > 2 ? array.get(mar_centers, 2) : na

if na(plot_val)
    curr_color := color.new(color.gray, 80)
barcolor(curr_color)   // color bars according to cluster assignment

// guide lines for cluster rows (only for "Clusters" mode)
plot(not na(plot_val) and main_plot == "Clusters" ? 0.5 : na, color = color.new(color.gray, 70), title = "Guide Line 1")
plot(not na(plot_val) and main_plot == "Clusters" and k == 3 ? 1.5 : na, color = color.new(color.gray, 70), title = "Guide Line 2")

// Plot choices:
// - For single-feature modes: plot the feature (as circles for readability).
// - For "Clusters" we plot the interpolated `real_clust` and separate histograms
//   for each discrete cluster index to emphasize the categorical bands.
plot(main_plot == "Clusters" ? (plot_cl ? plot_val : na) : plot_val, color = color.new(curr_color, 50), title = "Clusers line")
plot(plot_val, color = curr_color, style = plot.style_circles, title = "Cluster Circles")
plot(main_plot == "Clusters" and cluster_val == 0 ? plot_val :  na, color = curr_color, style = plot.style_histogram, histbase = 0)
plot(main_plot == "Clusters" and cluster_val == 1 ? plot_val :  na, color = curr_color, style = plot.style_histogram, histbase = 1)
plot(main_plot == "Clusters" and cluster_val == 2 ? plot_val :  na, color = curr_color, style = plot.style_histogram, histbase = 2)

// show the centers as steplines for visual reference
plot(not na(plot_val) and k >= 1 ? plot_k0_center : na, color=color.new(color.red, 30), style=plot.style_stepline, title="k0 Cluster Center", linewidth = 2)
plot(not na(plot_val) and k >= 2 ? plot_k1_center : na, color=k <= 2 ? color.new(color.green, 30) : color.new(color.orange, 30), style=plot.style_stepline, title="k1 Cluster Center", linewidth = 2)
plot(not na(plot_val) and k == 3 ? plot_k2_center : na, color=color.new(color.green, 30), style=plot.style_stepline, title="k2 Cluster Center", linewidth = 2)
//}

//-#-#-#-#-#- ALERT -#-#-#-#-#- {
if not (curr_cluster == curr_cluster[1])
    alert("SPC: Market regime shifted → Now in cluster " + str.tostring(curr_cluster), freq = alert.freq_once_per_bar_close)
//}

// ----------------------------------------------------------------------------
// FINAL NOTES 
//
// Usage tips:
//  - Use the "Clusters" main_plot with a subset of features enabled to test
//    how individual features affect fused distances and flips.
//  - Increase `lookback` to get more stable percentile centers; decrease to react
//    faster to regime shifts.
//  - The percentile parameters p_low and p_high allow tuning of what constitutes
//    the "lower basin" and "upper basin". Lower p_low makes lower center smaller,
//    higher p_high makes upper center larger.
//
// Final remark:
//  This indicator deliberately trades off strict statistical clustering for a
//  deterministic, streaming-friendly heuristic that is cheap to compute and easy
//  to interpret. It's well-suited for visual regime/trend analysis and feature
//  engineering in lightweight systems.
//
// ----------------------------------------------------------------------------
````
