# Reversal Probability & Signals

- url: https://www.tradingview.com/script/Vg1GzKm7-Reversal-Probability-Signals/
- type: indicator
- pine_id: PUB;ba812ebcf5384310aea04ddeb7b85b9c
- version: 4.0

## Description

This indicator is designed to forecast critical market turning points by predicting the formation of TOPs (Pivot Highs) and BOTTOMs (Pivot Lows).

To achieve this, the script utilizes a simplified K-Nearest Neighbors (KNN) machine learning algorithm built directly within Pine Script. By analyzing a wide spectrum of Commodity Channel Index (CCI) values, it calculates the real-time probability that the current price action will result in a structural Pivot reversal.

[b]How It Works (The Engine)[/b]
[image]https://www.tradingview.com/x/Jan8JZwU/[/image]
The script functions as a real-time pattern recognition engine. It operates in three main steps:

Feature Extraction: It concurrently calculates 8 different lengths of the CCI (from very short to long-term periods like 10 to 200). This acts as the feature set of the current market momentum.

Data Collection (Training): Whenever the market makes a significant structural Top or Bottom (based on Pivot points), the script records the specific state of those 8 CCIs at that exact moment. It also collects random "non-target" samples to build a balanced historical database.

KNN Classification (Prediction): On every new bar, the algorithm calculates the mathematical Euclidean distance between the current 8 CCI values and the historically saved samples. It looks at the "K" nearest historical neighbors. If the majority of those closest historical neighbors were market bottoms, the indicator outputs a high "Bottom Probability."

[b]Key Features[/b]

Dynamic K-Value Adjustment: To ensure stable and accurate calculations even shortly after applying the indicator (when the historical sample pool is still growing), the "K" value dynamically scales down based on the available data size and automatically adjusts to odd numbers to prevent tie-breaking ambiguity.

Two-Step Smart Signal Logic: To prevent premature entries during strong, ongoing trends, this script uses a dual-threshold confirmation system:

Standby: The probability must first surge above an Upper Threshold (Default: 80%), indicating extreme conditions.

Trigger: The actual signal is only plotted when the probability peaks and subsequently drops below a Lower Threshold (Default: 50%). This confirms that the extreme momentum has broken and the reversal is underway.

Target Selection: Easily switch the engine's focus between predicting a "BOTTOM" or a "TOP" via the settings panel.

Visual Enhancements & Alerts: Includes intuitive dynamic bar coloring (changing based on probability intensity), a clear histogram, distinct signal shapes on the chart, and fully integrated alert conditions for automation.

[b]Settings & Configuration[/b]

Prediction Target: Toggle between BOTTOM (Pivot Lows) and TOP (Pivot Highs).

Feature Parameters (CCI): Customize the 8 periods used for momentum extraction. Default settings range from 10 to 200 to capture micro-fluctuations up to macro-trends.

KNN Model Settings: * K-Value: The baseline number of nearest neighbors to compare.

Max Samples: The memory limit for historical data points (higher = more stability, but heavier computation).

Signal Settings: Customize the Upper and Lower thresholds for the two-step signal generation.

[b]How to Trade with It[/b]

Select your target: Decide if you are looking for long opportunities (BOTTOM) or short opportunities (TOP).

Watch the Buildup: Observe the histogram or candlestick colors. When the probability goes above 80%, the market is showing conditions highly similar to historical reversals. Do not enter yet.

Wait for the Trigger: Wait for the momentum to break. When the probability drops back below the 50% threshold, a triangle shape will appear on the chart. This is your signal that the reversal pattern is executing.

[b]Disclaimer:[/b]
 This script uses historical pattern matching and experimental mathematical models. It does not guarantee future results. Please use it in conjunction with broader market context, other technical indicators, and strict risk management.

## Source Code

````pine
//@version=5
indicator("Reversal Probability & Signals", overlay=false)
//Please contact the author if you intend to use this script beyond the scope of personal use.
// ==========================================
// Prediction Target Settings
// ==========================================
target_type = input.string("BOTTOM", title="Prediction Target", options=["BOTTOM", "TOP"], group="General Settings", tooltip="Select the prediction target. BOTTOM predicts the probability of forming a market bottom (Pivot Low), and TOP predicts a market top (Pivot High).")

// ==========================================
// Feature Parameters (CCI)
// ==========================================
len1 = input.int(20, title="CCI Length 1", group="Feature Parameters (CCI)", tooltip="Set the period for the 1st CCI.")
len2 = input.int(25, title="CCI Length 2", group="Feature Parameters (CCI)", tooltip="Set the period for the 2nd CCI.")
len3 = input.int(30, title="CCI Length 3", group="Feature Parameters (CCI)", tooltip="Set the period for the 3rd CCI.")
len4 = input.int(40, title="CCI Length 4", group="Feature Parameters (CCI)", tooltip="Set the period for the 4th CCI.")
len5 = input.int(50, title="CCI Length 5", group="Feature Parameters (CCI)", tooltip="Set the period for the 5th CCI.")
len6 = input.int(100, title="CCI Length 6", group="Feature Parameters (CCI)", tooltip="Set the period for the 6th CCI.")
len7 = input.int(200, title="CCI Length 7", group="Feature Parameters (CCI)", tooltip="Set the period for the 7th CCI.")
len8 = input.int(400, title="CCI Length 8", group="Feature Parameters (CCI)", tooltip="Set the period for the 8th CCI. Used to capture long-term trends.")

// KNN Algorithm and Population Settings
k_val = input.int(80, title="KNN K-Value", minval=1, maxval=100, tooltip="Specify the number of nearest neighbors to compare in the KNN algorithm. Odd numbers are recommended to prevent ties.", group="KNN Model Settings")
max_samples = input.int(200, title="Max Samples per Class", minval=10, maxval=1000, tooltip="Set the maximum number of samples to keep per class (target/non-target). Higher values increase computation load but stabilize accuracy.", group="KNN Model Settings")

// Pivot (Swing High/Low) Definition Period
left_bars = input.int(5, title="Pivot Left Bars", group="Pivot Definition", tooltip="Specify the number of past bars to reference for Pivot detection.")
right_bars = input.int(10, title="Pivot Right Bars", group="Pivot Definition", tooltip="Specify the number of future bars to reference for Pivot detection. Detection will be delayed by this amount.")

// ==========================================
// Custom CCI Function Definition
// ==========================================
// Custom function to calculate CCI using Simple Moving Average and Mean Absolute Deviation of Typical Price for a specified period (len).
// CCI = (Typical Price - SMA(TP, len)) / (0.015 * Mean Deviation)
custom_cci(src, len) =>
    float sma_val = ta.sma(src[1], len)
    float md = ta.dev(src[1], len) // ta.dev calculates Mean Absolute Deviation
    float cci_val = md == 0 ? 0 : (src - sma_val) / md
    cci_val

// ==========================================
// Feature Calculation
// ==========================================
// Switch calculation source based on prediction target
// Use low as the base (src) for calculation if the target is BOTTOM, and high if the target is TOP.
cci_src = target_type == "BOTTOM" ? low : high

c1 = custom_cci(cci_src, len1)
c2 = custom_cci(cci_src, len2)
c3 = custom_cci(cci_src, len3)
c4 = custom_cci(cci_src, len4)
c5 = custom_cci(cci_src, len5)
c6 = custom_cci(cci_src, len6)
c7 = custom_cci(cci_src, len7)
c8 = custom_cci(cci_src, len8)

// Delay features by right_bars to align with Pivot detection
// Since Pivot detection requires future data equivalent to right_bars, delay (shift) the current CCI values into the past by right_bars to save features at the moment the detection is confirmed.
c1_d = c1[right_bars]
c2_d = c2[right_bars]
c3_d = c3[right_bars]
c4_d = c4[right_bars]
c5_d = c5[right_bars]
c6_d = c6[right_bars]
c7_d = c7[right_bars]
c8_d = c8[right_bars]

// ==========================================
// Target Detection and Data Storage
// ==========================================
// Get Pivot Low / High
// Detect Pivot Low (valley) and Pivot High (peak) based on the specified left and right bars.
float piv_low = ta.pivotlow(low, left_bars, right_bars)
float piv_high = ta.pivothigh(high, left_bars, right_bars)

// Variables to store previous Pivot values
// Variables to store the previously detected Pivot values. The 'var' keyword retains the values across bars.
var float prev_piv_low = na
var float prev_piv_high = na

// Check for LL (Lower Low) / HH (Higher High)
bool is_ll = false
bool is_hh = false

if not na(piv_low)
    // If the currently detected Pivot Low is lower than the previous Pivot Low, determine it as a Lower Low (LL).
    if not na(prev_piv_low) and piv_low < prev_piv_low
        is_ll := true
    prev_piv_low := piv_low

if not na(piv_high)
    // If the currently detected Pivot High is higher than the previous Pivot High, determine it as a Higher High (HH).
    if not na(prev_piv_high) and piv_high > prev_piv_high
        is_hh := true
    prev_piv_high := piv_high

// Target determination (BOTTOM uses only LL, TOP uses only HH)
// Determine the target condition (LL or HH) to save based on the user-set target.
bool is_target = target_type == "BOTTOM" ? is_ll : is_hh

// Array update function
// Function to append new data to the feature arrays and remove the oldest data if the maximum sample size (max_s) is exceeded.
f_update_arrays(c1_d, c2_d, c3_d, c4_d, c5_d, c6_d, c7_d, c8_d, a_c1, a_c2, a_c3, a_c4, a_c5, a_c6, a_c7, a_c8, max_s) =>
    array.push(a_c1, c1_d)
    array.push(a_c2, c2_d)
    array.push(a_c3, c3_d)
    array.push(a_c4, c4_d)
    array.push(a_c5, c5_d)
    array.push(a_c6, c6_d)
    array.push(a_c7, c7_d)
    array.push(a_c8, c8_d)
    if array.size(a_c1) > max_s
        array.shift(a_c1)
        array.shift(a_c2)
        array.shift(a_c3)
        array.shift(a_c4)
        array.shift(a_c5)
        array.shift(a_c6)
        array.shift(a_c7)
        array.shift(a_c8)

// Arrays for saving samples by class (Target / Non-Target)
// Initialize arrays to store features when a target occurs and when it doesn't (non-target).
var a_tgt_c1 = array.new_float(0)
var a_tgt_c2 = array.new_float(0)
var a_tgt_c3 = array.new_float(0)
var a_tgt_c4 = array.new_float(0)
var a_tgt_c5 = array.new_float(0)
var a_tgt_c6 = array.new_float(0)
var a_tgt_c7 = array.new_float(0)
var a_tgt_c8 = array.new_float(0)

var a_ntgt_c1 = array.new_float(0)
var a_ntgt_c2 = array.new_float(0)
var a_ntgt_c3 = array.new_float(0)
var a_ntgt_c4 = array.new_float(0)
var a_ntgt_c5 = array.new_float(0)
var a_ntgt_c6 = array.new_float(0)
var a_ntgt_c7 = array.new_float(0)
var a_ntgt_c8 = array.new_float(0)

// Target Data Collection
// Variable to balance target and non-target data.
var int pending_ntgt = 0

if is_target
    // If the target condition is met, save the delayed features to the target arrays.
    f_update_arrays(c1_d, c2_d, c3_d, c4_d, c5_d, c6_d, c7_d, c8_d, a_tgt_c1, a_tgt_c2, a_tgt_c3, a_tgt_c4, a_tgt_c5, a_tgt_c6, a_tgt_c7, a_tgt_c8, max_samples)
    pending_ntgt += 1 // Increase the quota for non-target data to be saved.
else
    if pending_ntgt > 0
        // Add randomness to prevent saving non-targets in quick succession
        // To prevent saving only data immediately after a target as non-targets, save them randomly with a 10% probability.
        if math.random() <= 0.1
            f_update_arrays(c1_d, c2_d, c3_d, c4_d, c5_d, c6_d, c7_d, c8_d, a_ntgt_c1, a_ntgt_c2, a_ntgt_c3, a_ntgt_c4, a_ntgt_c5, a_ntgt_c6, a_ntgt_c7, a_ntgt_c8, max_samples)
            pending_ntgt -= 1

// ==========================================
// KNN Probability Calculation (Executed on every bar)
// ==========================================
// KNN calculation function
// Function to calculate the probability that the current features belong to the target class using K-Nearest Neighbors (KNN).
f_knn_prob(v_c1, v_c2, v_c3, v_c4, v_c5, v_c6, v_c7, v_c8, a_tgt_c1, a_tgt_c2, a_tgt_c3, a_tgt_c4, a_tgt_c5, a_tgt_c6, a_tgt_c7, a_tgt_c8, a_ntgt_c1, a_ntgt_c2, a_ntgt_c3, a_ntgt_c4, a_ntgt_c5, a_ntgt_c6, a_ntgt_c7, a_ntgt_c8, k, max_s) =>
    // To prevent bias from imbalanced sample sizes between classes, use only an equal number of samples (valid_size) from both classes for comparison.
    int valid_size = math.min(array.size(a_tgt_c1), array.size(a_ntgt_c1))
    float prob = na
    
    // Start calculation if at least 1 sample is collected.
    if valid_size >= 1
        
        // --- Dynamic K calculation logic ---
        // In the early stages when the sample size hasn't reached the maximum, using the specified K as is would pick up too much broad data.
        // Dynamically reduce the K value based on the ratio of the current sample size to the maximum sample size.
        int dynamic_k = k
        if valid_size < max_s
            // If current sample size is less than max size, reduce K proportionally
            float ratio = valid_size / max_s
            dynamic_k := math.max(1, int(math.round(k * ratio)))
            // Force K to be an odd number to prevent tie-breaking ambiguity when distances are equal.
            if dynamic_k % 2 == 0
                dynamic_k := dynamic_k + 1

        array<float> a_dist = array.new_float(0) // Array to store distances.
        array<int> a_label = array.new_int(0)    // Array to store class labels (1: target, 0: non-target).
        
        // Calculate the Euclidean distance between each sample of the target class and the current features.
        int start_tgt = array.size(a_tgt_c1) - valid_size
        for i = start_tgt to array.size(a_tgt_c1) - 1
            float d = math.sqrt(math.pow(v_c1 - array.get(a_tgt_c1, i), 2) + math.pow(v_c2 - array.get(a_tgt_c2, i), 2) + math.pow(v_c3 - array.get(a_tgt_c3, i), 2) + math.pow(v_c4 - array.get(a_tgt_c4, i), 2) + math.pow(v_c5 - array.get(a_tgt_c5, i), 2) + math.pow(v_c6 - array.get(a_tgt_c6, i), 2) + math.pow(v_c7 - array.get(a_tgt_c7, i), 2) + math.pow(v_c8 - array.get(a_tgt_c8, i), 2))
            array.push(a_dist, d)
            array.push(a_label, 1)
            
        // Calculate the Euclidean distance between each sample of the non-target class and the current features.
        int start_ntgt = array.size(a_ntgt_c1) - valid_size
        for i = start_ntgt to array.size(a_ntgt_c1) - 1
            float d = math.sqrt(math.pow(v_c1 - array.get(a_ntgt_c1, i), 2) + math.pow(v_c2 - array.get(a_ntgt_c2, i), 2) + math.pow(v_c3 - array.get(a_ntgt_c3, i), 2) + math.pow(v_c4 - array.get(a_ntgt_c4, i), 2) + math.pow(v_c5 - array.get(a_ntgt_c5, i), 2) + math.pow(v_c6 - array.get(a_ntgt_c6, i), 2) + math.pow(v_c7 - array.get(a_ntgt_c7, i), 2) + math.pow(v_c8 - array.get(a_ntgt_c8, i), 2))
            array.push(a_dist, d)
            array.push(a_label, 0)
            
        // Get the index array to sort by shortest distance.
        array<int> indices = array.sort_indices(a_dist)
        int count_tgt = 0
        int actual_k = math.min(dynamic_k, array.size(indices))
        
        // Check the top actual_k samples by proximity and count how many belong to the target class (label 1).
        if actual_k > 0
            for i = 0 to actual_k - 1
                int idx = array.get(indices, i)
                if array.get(a_label, idx) == 1
                    count_tgt += 1
            // Calculate the percentage of the target class as a probability (%).
            prob := (count_tgt / actual_k) * 100
    prob

float tgt_prob = f_knn_prob(c1, c2, c3, c4, c5, c6, c7, c8, a_tgt_c1, a_tgt_c2, a_tgt_c3, a_tgt_c4, a_tgt_c5, a_tgt_c6, a_tgt_c7, a_tgt_c8, a_ntgt_c1, a_ntgt_c2, a_ntgt_c3, a_ntgt_c4, a_ntgt_c5, a_ntgt_c6, a_ntgt_c7, a_ntgt_c8, k_val, max_samples)

// ==========================================
// Plot Settings and Drawing
// ==========================================
grp_color = "Color Settings"
use_barcolor = input.bool(true, title="Enable Bar Color", group=grp_color, tooltip="Select whether to change the bar colors based on probability.")

bottom_c1 = input.color(color.red, "BOTTOM Prob Color (>=80%)", group=grp_color, tooltip="Set the color when the BOTTOM prediction probability is >= 80%.")
bottom_c2 = input.color(color.new(color.red, 30), "BOTTOM Prob Color (>=50%)", group=grp_color, tooltip="Set the color when the BOTTOM prediction probability is >= 50%.")
bottom_c3 = input.color(color.new(color.red, 60), "BOTTOM Prob Color (>=20%)", group=grp_color, tooltip="Set the color when the BOTTOM prediction probability is >= 20%.")
bottom_label = input.color(color.green, "BOTTOM Signal Color", group=grp_color, tooltip="Set the shape color when a BOTTOM signal occurs.")

top_c1 = input.color(color.blue, "TOP Prob Color (>=80%)", group=grp_color, tooltip="Set the color when the TOP prediction probability is >= 80%.")
top_c2 = input.color(color.new(color.blue, 30), "TOP Prob Color (>=50%)", group=grp_color, tooltip="Set the color when the TOP prediction probability is >= 50%.")
top_c3 = input.color(color.new(color.blue, 60), "TOP Prob Color (>=20%)", group=grp_color, tooltip="Set the color when the TOP prediction probability is >= 20%.")
top_label = input.color(color.red, "TOP Signal Color", group=grp_color, tooltip="Set the shape color when a TOP signal occurs.")

color_gray = input.color(color.new(color.gray, 50), "Low Prob Color (<20%)", group=grp_color, tooltip="Set the color when the probability is less than 20%.")

// Color switching based on selection
c1_color = target_type == "BOTTOM" ? bottom_c1 : top_c1
c2_color = target_type == "BOTTOM" ? bottom_c2 : top_c2
c3_color = target_type == "BOTTOM" ? bottom_c3 : top_c3
lbl_color = target_type == "BOTTOM" ? bottom_label : top_label

f_get_color(prob, c1, c2, c3, c_gray) =>
    na(prob) ? na : prob >= 80 ? c1 : prob >= 50 ? c2 : prob >= 20 ? c3 : c_gray

plot_color = f_get_color(tgt_prob, c1_color, c2_color, c3_color, color_gray)

// Plot Histogram
plot(tgt_prob, title="Probability (%)", color=plot_color, linewidth=2, style=plot.style_histogram)

hline(50, title="50% Threshold", color=color.new(color.white, 40), linestyle=hline.style_dashed)
hline(80, title="80% Level", color=color.new(color.red, 20), linestyle=hline.style_dotted)
hline(20, title="20% Level", color=color.new(color.green, 20), linestyle=hline.style_dotted)

// ==========================================
// Signal & Alert Settings
// ==========================================
grp_signal = "Signal Settings"

upper_threshold = input.float(80.0, title="Signal Upper Threshold", group=grp_signal, tooltip="Set the upper threshold for signal detection. The indicator enters a standby state when the probability exceeds this value.")
lower_threshold = input.float(80.0, title="Signal Lower Threshold", group=grp_signal, tooltip="Set the lower threshold for signal detection. A signal is triggered when the probability drops below this value after being in a standby state.")
atr_offset = input.float(1.0, title="ATR Offset for Signal Plot", group=grp_signal, tooltip="Specify how far to display the signal mark from the candlestick, as a multiple of ATR.")

// Variable to track if the probability was above the upper threshold
// Flag to remember the state where the probability has once exceeded the upper threshold.
var bool was_above_upper = false

// Set flag to true if probability exceeds the upper threshold
// Turn ON the flag if the probability is equal to or greater than the upper threshold.
if tgt_prob >= upper_threshold
    was_above_upper := true

// Signal triggers when it crosses under the lower threshold AFTER being above the upper threshold
// Trigger the signal condition when the probability crosses under the lower threshold while the flag is ON.
signal_cond = ta.crossunder(tgt_prob, lower_threshold) and was_above_upper

// Reset the flag once the signal is triggered
// Reset the flag for the next detection once a signal is generated.
if signal_cond
    was_above_upper := false

// Draw Signal Shapes
// Draw signal shapes where the conditions are met.
atr = ta.atr(10)
plotshape(target_type == "BOTTOM" and signal_cond ? low - atr * atr_offset : na, title="Bottom Return Signal", style=shape.triangleup, location=location.absolute, color=lbl_color, size=size.tiny, force_overlay=true)
plotshape(target_type == "TOP" and signal_cond ? high + atr * atr_offset : na, title="Top Return Signal", style=shape.triangledown, location=location.absolute, color=lbl_color, size=size.tiny, force_overlay=true)

// Alerts
if signal_cond
    alert_msg = target_type == "BOTTOM" ? "CCI KNN Bottom Signal Triggered!" : "CCI KNN Top Signal Triggered!"
    alert(alert_msg, alert.freq_once_per_bar_close)

alertcondition(signal_cond, title="KNN Probability Signal", message="KNN Probability Signal Triggered!")

// ==========================================
// Apply Bar Color
// ==========================================
barcolor(use_barcolor ? plot_color : na)
````
